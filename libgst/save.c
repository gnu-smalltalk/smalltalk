/******************************** -*- C -*- ****************************
 *
 *	Binary image save/restore.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006,2007,2008
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


#include "gstpriv.h"

#define READ_BUFFER_SIZE 524288
#define WRITE_BUFFER_SIZE 65536

/* These flags help defining the flags and checking whether they are
   different between the image we are loading and our environment.  */

#define MASK_ENDIANNESS_FLAG 1
#define MASK_SLOT_SIZE_FLAG 2

#ifdef WORDS_BIGENDIAN
# define LOCAL_ENDIANNESS_FLAG MASK_ENDIANNESS_FLAG
#else
# define LOCAL_ENDIANNESS_FLAG 0
#endif

#if SIZEOF_OOP == 4
# define LOCAL_SLOT_SIZE_FLAG 0
#else /* SIZEOF_OOP == 8 */
# define LOCAL_SLOT_SIZE_FLAG MASK_SLOT_SIZE_FLAG
#endif /* SIZEOF_OOP == 8 */

#define FLAG_CHANGED(flags, whichFlag)	\
  ((flags ^ LOCAL_##whichFlag) & MASK_##whichFlag)

#define FLAGS_WRITTEN		\
  (LOCAL_ENDIANNESS_FLAG | LOCAL_SLOT_SIZE_FLAG)

#define VERSION_REQUIRED	\
  ((ST_MAJOR_VERSION << 16) + (ST_MINOR_VERSION << 8) + ST_EDIT_VERSION)

/* Define to print loads of debugging information.  */
/* #define SNAPSHOT_TRACE */

/* The binary image file has the following format:
	header
	complete oop table
	global oop variable data
	object data */

#define EXECUTE      "#! /usr/bin/env gst -aI\nexec gst -I \"$0\" -a \"$@\"\n"
#define SIGNATURE    "GSTIm"

typedef struct save_file_header
{
  char dummy[64];	/* Bourne shell command to execute image */
  char signature[6];	/* 6+2=8 should be enough to align version! */
  char unused;
  char flags;		/* flags for endianness and sizeof(PTR) */
  size_t version;	/* the Smalltalk version that made this dump */
  size_t oopTableSize;	/* size of the oop table at dump */
  size_t edenSpaceSize;	/* size of new space at dump time */
  size_t survSpaceSize;	/* size of survivor spaces at dump time */
  size_t oldSpaceSize;	/* size of old space at dump time */
  size_t big_object_threshold;
  size_t grow_threshold_percent;
  size_t space_grow_rate;
  size_t num_free_oops;
  intptr_t ot_base;
  intptr_t prim_table_md5[16 / sizeof (intptr_t)]; /* checksum for the primitive table */
}
save_file_header;


/* The buffer that we use for I/O.  */
static char *buf;

/* The position in the buffer.  */
static int buf_pos;

/* The size of the buffer.  */
static int buf_size;

/* The size of the input file (for buffered input only).  */
static off_t file_size;

/* The current position in the file (for buffered input only).  */
static off_t file_pos;

/* Whether we are using mmap to read the file.  */
static mst_Boolean buf_used_mmap;


/* This function tries to write SIZE bytes to FD starting at BUFFER,
   and longjmps out of SAVE_JMPBUF if something goes wrong.  */
static void full_write (int fd,
			PTR buffer,
			size_t size);

/* This function establishes a buffer of size NUMBYTES for writes.  */
static void buffer_write_init (int imageFd,
			       int numBytes);

/* This function flushes and frees the buffer used for writes.  */
static void buffer_write_flush (int imageFd);

/* This function buffers writes to the image file whose descriptor is
   IMAGEFD.  */
static void buffer_write (int imageFd,
			  PTR data,
			  int numBytes);

/* This function establishes a buffer of size NUMBYTES for reads.  The
   base of the buffer is returned if mmap was used.  */
static char *buffer_read_init (int imageFd,
			       int numBytes);

/* This function frees the buffer used for reads.  */
static void buffer_read_free (int imageFd);

/* This function, which only works if memory-mapped I/O is used, advances
   the buffer pointer by NUMBYTES and returns the pointer to the previous
   value of the buffer pointer.  */
static inline PTR buffer_advance (int imageFd,
				  int numBytes);

/* This function buffers reads from the image file whose descriptor
   is IMAGEFD.  Memory-mapped I/O is used is possible.  */
static void buffer_read (int imageFd,
			 PTR data,
			 int numBytes);

/* This function fills the buffer used by buffer_read.  It is used
   internally by buffer_read.  */
static void buffer_fill (int imageFd);

/* This function saves the object pointed to by OOP on the image-file
   whose descriptor is IMAGEFD.  */
static void save_object (int imageFd,
			 OOP oop);

/* This function copies NUMBYTES from SRC to DEST, tweaking some fields
   depending on the class.  */
static inline void fixup_object (OOP oop, gst_object dest, gst_object src,
				 int numBytes);

/* This function inverts the endianness of SIZE long-words, starting at
   BUF.  */
static inline void fixup_byte_order (PTR buf,
			      size_t size);

/* This function loads an OOP table made of OLDSLOTSUSED slots from
   the image file stored in the file whose descriptor is IMAGEFD.
   The fixup gets handled by load_normal_oops.  */
static void load_oop_table (int imageFd);

/* This function loads OBJECTDATASIZE bytes of object data belonging
   to standard (i.e. non built-in OOPs) and fixes the endianness of
   the objects.  Endianness conversion is done in two steps: first
   the non-byte objects (identified by not having the F_BYTE flag),
   including the class objects which are necessary to fix the byte
   objects, then all the byte-objects which also have instance
   variables). 
   Object data is loaded from the IMAGEFD file descriptor.  If
   copy-on-write is used, return the end address of the loaded data.  */
static char *load_normal_oops (int imageFd);

/* Do the bulk of the save to IMAGEFD.  Calling the hooks and reporting
   errors is left to the callers.  */
static void save_to_fd (int imageFd);

/* This function stores the header, HEADERP, of the image file into the file
   whose descriptor is IMAGEFD.  */
static void save_file_version (int imageFd,
			       struct save_file_header *headerp);

/* This function loads into HEADERP the header of the image file
   without checking its validity.
   This data is loaded from the IMAGEFD file descriptor.  */
static mst_Boolean load_file_version (int imageFd,
				      save_file_header * headerp);

/* This function walks the OOP table and adjusts all the OOP addresses,
   to account for the difference between the OOP table address at save
   time and now.  */
static inline void restore_all_pointer_slots (void);

/* This and adjusts all the addresses in OOPto account for the difference
   between the OOP table address at save time and now.  */
static inline void restore_oop_pointer_slots (OOP oop);

/* This function prepares the OOP table to be written to the image
   file.  This contains the object sizes instead of the pointers,
   since addresses will be recalculated upon load.  */
static struct oop_s *make_oop_table_to_be_saved (struct save_file_header *hdr);

/* This function walks the OOP table and saves the data
   onto the file whose descriptor is IMAGEFD.  */
static void save_all_objects (int imageFd);

/* This function is the heart of _gst_load_from_file, which opens
   the file and then passes the descriptor to load_snapshot into
   IMAGEFD.  */
static mst_Boolean load_snapshot (int imageFd);

/* This variable says whether the image we are loading has the
   wrong endianness.  */
static mst_Boolean wrong_endianness;

/* This variable contains the OOP slot index of the highest non-free
   OOP, excluding the built-in ones (i.e., it will always be <
   _gst_mem.ot_size).  This is used for optimizing the size of the
   saved image, and minimizing the load time when restoring the
   system.  */
static int num_used_oops = 0;

/* Delta from the object table address used in the saved image, and
   the one we allocate now.  */
static intptr_t ot_delta;

/* Used when writing the image fails.  */
static jmp_buf save_jmpbuf;

/* Convert from relative offset to actual oop table address.  */
#define OOP_ABSOLUTE(obj) \
  ( (OOP)((intptr_t)(obj) + ot_delta) )


struct oop_s *myOOPTable = NULL;

mst_Boolean
_gst_save_to_file (const char *fileName)
{
  int imageFd;
  int save_errno;
  mst_Boolean success;

  _gst_invoke_hook (GST_ABOUT_TO_SNAPSHOT);
  _gst_global_gc (0);
  _gst_finish_incremental_gc ();

  success = false;
  unlink (fileName);
  imageFd = _gst_open_file (fileName, "w");
  if (imageFd >= 0)
    {
      if (setjmp(save_jmpbuf) == 0)
        {
          save_to_fd (imageFd);
          success = true;
        }

      save_errno = errno;
      close (imageFd);
      if (!success)
        unlink (fileName);
      if (myOOPTable)
        xfree (myOOPTable);
      myOOPTable = NULL;
    }
  else
    save_errno = errno;

  _gst_invoke_hook (GST_FINISHED_SNAPSHOT);
  errno = save_errno;
  return success;
}

void
save_to_fd (int imageFd)
{
  save_file_header header;
  memset (&header, 0, sizeof (header));
  myOOPTable = make_oop_table_to_be_saved (&header);

  buffer_write_init (imageFd, WRITE_BUFFER_SIZE);
  save_file_version (imageFd, &header);

#ifdef SNAPSHOT_TRACE
  printf ("After saving header: %lld\n",
	  lseek (imageFd, 0, SEEK_CUR));
#endif /* SNAPSHOT_TRACE */

  /* save up to the last oop slot in use */
  buffer_write (imageFd, myOOPTable,
		sizeof (struct oop_s) * num_used_oops);

#ifdef SNAPSHOT_TRACE
  printf ("After saving oop table: %lld\n",
	  lseek (imageFd, 0, SEEK_CUR));
#endif /* SNAPSHOT_TRACE */

  xfree (myOOPTable);
  myOOPTable = NULL;

  save_all_objects (imageFd);

#ifdef SNAPSHOT_TRACE
  printf ("After saving all objects: %lld\n",
	  lseek (imageFd, 0, SEEK_CUR));
#endif /* SNAPSHOT_TRACE */

  buffer_write_flush (imageFd);
}


struct oop_s *
make_oop_table_to_be_saved (struct save_file_header *header)
{
  OOP oop;
  struct oop_s *myOOPTable;
  int i;

  num_used_oops = 0;

  for (oop = _gst_mem.ot; oop < &_gst_mem.ot[_gst_mem.ot_size];
       oop++)
    if (IS_OOP_VALID_GC (oop))
      num_used_oops = OOP_INDEX (oop) + 1;

  _gst_mem.num_free_oops = _gst_mem.ot_size - num_used_oops;

#ifdef SNAPSHOT_TRACE
  printf ("there are %d free oops out of %d oops, leaving %d\n",
	  _gst_mem.num_free_oops, _gst_mem.ot_size,
	  _gst_mem.ot_size - _gst_mem.num_free_oops);
#endif /* SNAPSHOT_TRACE */

  myOOPTable = xmalloc (sizeof (struct oop_s) * num_used_oops);

  for (i = 0, oop = _gst_mem.ot; i < num_used_oops; oop++, i++)
    {
      if (IS_OOP_VALID_GC (oop))
	{
	  int numPointers = NUM_OOPS (oop->object);

          myOOPTable[i].flags = (oop->flags & ~F_RUNTIME) | F_OLD;
	  myOOPTable[i].object = (gst_object) TO_INT (oop->object->objSize);
	}
      else
	{
	  myOOPTable[i].flags = 0;
	  header->num_free_oops++;
	}
    }

  return (myOOPTable);
}

void
save_all_objects (int imageFd)
{
  OOP oop;

  for (oop = _gst_mem.ot; oop < &_gst_mem.ot[num_used_oops];
       oop++)
    if (IS_OOP_VALID_GC (oop))
      save_object (imageFd, oop);
}

void
save_object (int imageFd,
	     OOP oop)
{
  gst_object object, saveObject;
  int numBytes;

#ifdef SNAPSHOT_TRACE
  printf (">Save ");
  _gst_display_oop (oop);
#endif

  object = OOP_TO_OBJ (oop);

  if (IS_OOP_FREE (oop))
    abort ();

  numBytes = sizeof (OOP) * TO_INT (object->objSize);
  if (numBytes < 262144)
    {
      saveObject = alloca (numBytes);
      fixup_object (oop, saveObject, object, numBytes);
      buffer_write (imageFd, saveObject, numBytes);
    }
  else
    {
      saveObject = malloc (numBytes);
      fixup_object (oop, saveObject, object, numBytes);
      buffer_write (imageFd, saveObject, numBytes);
      free (saveObject);
    }
}

void
save_file_version (int imageFd, struct save_file_header *headerp)
{
  memcpy (headerp->dummy, EXECUTE, strlen (EXECUTE));
  memcpy (headerp->signature, SIGNATURE, strlen (SIGNATURE));
  headerp->flags = FLAGS_WRITTEN;
  headerp->version = VERSION_REQUIRED;
  headerp->oopTableSize = num_used_oops;
  headerp->edenSpaceSize = _gst_mem.eden.totalSize;
  headerp->survSpaceSize = _gst_mem.surv[0].totalSize;
  headerp->oldSpaceSize = _gst_mem.old->heap_limit;

  headerp->big_object_threshold = _gst_mem.big_object_threshold;
  headerp->grow_threshold_percent = _gst_mem.grow_threshold_percent;
  headerp->space_grow_rate = _gst_mem.space_grow_rate;
  headerp->ot_base = (intptr_t) _gst_mem.ot_base;
  memcpy (&headerp->prim_table_md5, _gst_primitives_md5, sizeof (_gst_primitives_md5));

  buffer_write (imageFd, headerp, sizeof (save_file_header));
}



/***********************************************************************
 *
 *	Binary loading routines.
 *
 ***********************************************************************/

mst_Boolean
_gst_load_from_file (const char *fileName)
{
  mst_Boolean loaded = 0;
  int imageFd;

  imageFd = _gst_open_file (fileName, "r");
  loaded = (imageFd >= 0) && load_snapshot (imageFd);

  close (imageFd);
  return (loaded);
}

mst_Boolean
load_snapshot (int imageFd)
{
  save_file_header header;
  int prim_table_matches;
  char *base, *end;

  base = buffer_read_init (imageFd, READ_BUFFER_SIZE);
  if (!load_file_version (imageFd, &header))
    return false;

#ifdef SNAPSHOT_TRACE
  printf ("After loading header: %lld\n", file_pos + buf_pos);
#endif /* SNAPSHOT_TRACE */

  _gst_init_mem (header.edenSpaceSize, header.survSpaceSize,
		 header.oldSpaceSize, header.big_object_threshold,
		 header.grow_threshold_percent, header.space_grow_rate);

  _gst_init_oop_table ((PTR) header.ot_base,
		       MAX (header.oopTableSize * 2, INITIAL_OOP_TABLE_SIZE));

  ot_delta = (intptr_t) (_gst_mem.ot_base) - header.ot_base;
  num_used_oops = header.oopTableSize;
  _gst_mem.num_free_oops = header.num_free_oops;

  load_oop_table (imageFd);

#ifdef SNAPSHOT_TRACE
  printf ("After loading OOP table: %lld\n", file_pos + buf_pos);
#endif /* SNAPSHOT_TRACE */

  end = load_normal_oops (imageFd);
  if (end)
    {
      _gst_mem.loaded_base = (OOP *) base;
      _gst_mem.loaded_end = (OOP *) end;
    }

#ifdef SNAPSHOT_TRACE
  printf ("After loading objects: %lld\n", file_pos + buf_pos);
#endif /* SNAPSHOT_TRACE */

  if (ot_delta)
    restore_all_pointer_slots ();

  prim_table_matches = !memcmp (header.prim_table_md5, _gst_primitives_md5,
				sizeof (_gst_primitives_md5));
  if (_gst_init_dictionary_on_image_load (prim_table_matches))
    {
#ifdef SNAPSHOT_TRACE
      _gst_dump_oop_table ();
#endif /* SNAPSHOT_TRACE */
      return (true);
    }

  return (false);
}

mst_Boolean
load_file_version (int imageFd,
		   save_file_header * headerp)
{
  buffer_read (imageFd, headerp, sizeof (save_file_header));
  if (strcmp (headerp->signature, SIGNATURE))
    return (false);

  /* different sizeof(PTR) not supported */
  if (FLAG_CHANGED (headerp->flags, SLOT_SIZE_FLAG))
    return (false);

  if UNCOMMON ((wrong_endianness =
         FLAG_CHANGED (headerp->flags, ENDIANNESS_FLAG)))
    {
      headerp->oopTableSize = BYTE_INVERT (headerp->oopTableSize);
      headerp->edenSpaceSize = BYTE_INVERT (headerp->edenSpaceSize);
      headerp->survSpaceSize = BYTE_INVERT (headerp->survSpaceSize);
      headerp->oldSpaceSize = BYTE_INVERT (headerp->oldSpaceSize);
      headerp->big_object_threshold = BYTE_INVERT (headerp->big_object_threshold);
      headerp->grow_threshold_percent = BYTE_INVERT (headerp->grow_threshold_percent);
      headerp->space_grow_rate = BYTE_INVERT (headerp->space_grow_rate);
      headerp->version = BYTE_INVERT (headerp->version);
      headerp->num_free_oops = BYTE_INVERT (headerp->num_free_oops);
      headerp->ot_base = BYTE_INVERT (headerp->ot_base);
      headerp->prim_table_md5[0] = BYTE_INVERT (headerp->prim_table_md5[0]);
      headerp->prim_table_md5[1] = BYTE_INVERT (headerp->prim_table_md5[1]);
#if SIZEOF_OOP == 4
      headerp->prim_table_md5[2] = BYTE_INVERT (headerp->prim_table_md5[2]);
      headerp->prim_table_md5[3] = BYTE_INVERT (headerp->prim_table_md5[3]);
#endif
    }

  /* check for version mismatch; if so this image file is invalid */
  if (headerp->version > VERSION_REQUIRED)
    return (false);

  return (true);
}

void
load_oop_table (int imageFd)
{
  /* Load in the valid OOP slots from previous dump.  The others are already
     initialized to free (0).  */
  buffer_read (imageFd, _gst_mem.ot, sizeof (struct oop_s) * num_used_oops);
  if UNCOMMON (wrong_endianness)
    fixup_byte_order (_gst_mem.ot,
		      sizeof (struct oop_s) * num_used_oops / sizeof (PTR));
}


char *
load_normal_oops (int imageFd)
{
  OOP oop;
  int i;

  gst_object object = NULL;
  size_t size = 0;
  mst_Boolean use_copy_on_write
    =
#ifdef NO_SIGSEGV_HANDLING
      0 &&
#endif 
      buf_used_mmap && ~wrong_endianness && ot_delta == 0;

  /* Now walk the oop table.  Load the data (or get the addresses from the
     mmap-ed area) and fix the byte order.  */

  _gst_mem.last_allocated_oop = &_gst_mem.ot[num_used_oops - 1];
  PREFETCH_START (_gst_mem.ot, PREF_WRITE | PREF_NTA);
  for (oop = _gst_mem.ot, i = num_used_oops; i--; oop++)
    {
      intptr_t flags;

      PREFETCH_LOOP (oop, PREF_WRITE | PREF_NTA);
      flags = oop->flags;
      if (IS_OOP_FREE (oop))
	continue;

      /* FIXME: a small amount of garbage is saved that is produced
         by mourning the ephemerons right before GC.  We should probably
         put the objects to be mourned into a global list and walk it
         with a separate, *global* function _gst_mourn_objects().  This
         way we could save the objects before their mourning (which
         would happen on the image load) and before there is the occasion
	 to create new-space objects.  The solution is not however as neat
	 as possible.  */

      _gst_mem.numOldOOPs++;
      size = sizeof (PTR) * (size_t) oop->object;
      if (use_copy_on_write)
	{
	  oop->flags |= F_LOADED;
	  object = buffer_advance (imageFd, size);
	}

      else
	{
	  if (flags & F_FIXED)
	    {
	      _gst_mem.numFixedOOPs++;
              object = (gst_object) _gst_mem_alloc (_gst_mem.fixed, size);
	    }
          else
            object = (gst_object) _gst_mem_alloc (_gst_mem.old, size);

          buffer_read (imageFd, object, size);
          if UNCOMMON (wrong_endianness)
	    fixup_byte_order (object, 
			      (flags & F_BYTE)
			      ? OBJ_HEADER_SIZE_WORDS
			      : size / sizeof (PTR));

	  /* Would be nice, but causes us to touch every page and lose most
	     of the startup-time benefits of copy-on-write.  So we only
	     do it in the slow case, anyway.  */
	  if (object->objSize != FROM_INT ((size_t) oop->object))
	    abort ();
        }

      oop->object = object;
      if (flags & F_WEAK)
	_gst_make_oop_weak (oop);
    }

  /* NUM_OOPS requires access to the instance spec in the class
     objects. So we start by fixing the endianness of NON-BYTE objects
     (including classes!), for which we can do without NUM_OOPS, then
     do another pass here and fix the byte objects using the now
     correct class objects.  */
  if UNCOMMON (wrong_endianness)
    for (oop = _gst_mem.ot, i = num_used_oops; i--; oop++)
      if (oop->flags & F_BYTE)
	{
	  OOP classOOP;
	  object = OOP_TO_OBJ (oop);
          classOOP = OOP_ABSOLUTE (object->objClass);
	  fixup_byte_order (object->data, CLASS_FIXED_FIELDS (classOOP));
	}

  if (!use_copy_on_write)
    {
      buffer_read_free (imageFd);
      return NULL;
    }
  else
    return ((char *)object) + size;
}


/* Routines to convert to/from relative pointers, shared by
   loading and saving */

void
fixup_object (OOP oop, gst_object dest, gst_object src, int numBytes)
{
  OOP class_oop;
  memcpy (dest, src, numBytes);

  /* Do the heavy work on the objects now rather than at load time, in order
     to make the loading faster.  In general, we should do this as little as
     possible, because it's pretty hard: the three cases below for Process,
     Semaphore and CallinProcess for example are just there to terminate all
     CallinProcess objects.  */

  class_oop = src->objClass;

  if (oop->flags & F_CONTEXT)
    {
      /* this is another quirk; this is not the best place to do
         it. We have to reset the nativeIPs so that we can find
         restarted processes and recompile their methods.  */
      gst_method_context context = (gst_method_context) dest;
      context->native_ip = DUMMY_NATIVE_IP;
    }

  else if (class_oop == _gst_callin_process_class)
    {
      gst_process process = (gst_process) dest;
      process->suspendedContext = _gst_nil_oop;
      process->nextLink = _gst_nil_oop;
      process->myList = _gst_nil_oop;
    }

  else if (class_oop == _gst_process_class)
    {
      /* Find the new next link.  */
      gst_process destProcess = (gst_process) dest;
      gst_process next = (gst_process) src;
      while (OOP_CLASS (next->nextLink) == _gst_callin_process_class)
	next = (gst_process) OOP_TO_OBJ (next->nextLink);

      destProcess->nextLink = next->nextLink;
    }

  else if (class_oop == _gst_semaphore_class)
    {
      /* Find the new first and last link.  */
      gst_semaphore destSem = (gst_semaphore) dest;
      gst_semaphore srcSem = (gst_semaphore) src;
      OOP linkOOP = srcSem->firstLink;

      destSem->firstLink = _gst_nil_oop;
      destSem->lastLink = _gst_nil_oop;
      while (!IS_NIL (linkOOP))
	{
	  gst_process process = (gst_process) OOP_TO_OBJ (linkOOP);
	  if (process->objClass != _gst_callin_process_class)
	    {
	      if (IS_NIL (destSem->firstLink))
		destSem->firstLink = linkOOP;
	      destSem->lastLink = linkOOP;
	    }
	  linkOOP = process->nextLink;
	}
    }

  /* File descriptors are invalidated on resume.  */
  else if (is_a_kind_of (class_oop, _gst_file_descriptor_class))
    {
      gst_file_stream file = (gst_file_stream) dest;
      file->fd = _gst_nil_oop;
    }

  /* The other case is to reset CFunctionDescriptor objects, so that we'll
     relink the external functions when we reload the image.  */
  else if (is_a_kind_of (class_oop, _gst_c_callable_class))
    {
      gst_c_callable desc = (gst_c_callable) dest;
      if (desc->storageOOP == _gst_nil_oop)
        SET_COBJECT_OFFSET_OBJ (desc, 0);
    }

}

void
restore_all_pointer_slots ()
{
  OOP oop;

  for (oop = _gst_mem.ot; oop < &_gst_mem.ot[num_used_oops];
       oop++)
    if (IS_OOP_VALID_GC (oop))
      restore_oop_pointer_slots (oop);
}

void
restore_oop_pointer_slots (OOP oop)
{
  int numPointers;
  gst_object object;
  OOP *i;

  object = OOP_TO_OBJ (oop);
  object->objClass = OOP_ABSOLUTE (object->objClass);

  numPointers = NUM_OOPS (object);
  for (i = object->data; numPointers--; i++)
    if (IS_OOP (*i))
      *i = OOP_ABSOLUTE (*i);
}

void
fixup_byte_order (PTR buf,
		  size_t size)
{
  uintptr_t *p = (uintptr_t *) buf;
  for (; size--; p++)
    *p = BYTE_INVERT (*p);
}

void
buffer_write_init (int imageFd, int numBytes)
{
  buf = xmalloc (numBytes);
  buf_size = numBytes;
  buf_pos = 0;
}

void
full_write (int fd,
	         PTR buffer,
	         size_t size)
{
  char *buf = (char *) buffer;
  ssize_t num = SSIZE_MAX;

  for (; num > 0 && size; buf += num, size -= num)
    num = _gst_write (fd, buf, size);

  if (num == 0)
    {
      errno = ENOSPC;
      num = -1;
    }

  if (num == -1)
    longjmp(save_jmpbuf, 1);
}

void
buffer_write_flush (int imageFd)
{
  full_write (imageFd, buf, buf_pos);
  xfree (buf);
  buf_pos = 0;
}

void
buffer_write (int imageFd,
	      PTR data,
	      int numBytes)
{
  if UNCOMMON (buf_pos + numBytes > buf_size)
    {
      full_write (imageFd, buf, buf_pos);
      buf_pos = 0;
    }

  if UNCOMMON (numBytes > buf_size)
    full_write (imageFd, data, numBytes);
  else
    {
      memcpy (buf + buf_pos, data, numBytes);
      buf_pos += numBytes;
    }
}

void
buffer_fill (int imageFd)
{
  buf_pos = 0;
  read (imageFd, buf, buf_size);
}

char *
buffer_read_init (int imageFd, int numBytes)
{
  struct stat st;
  fstat (imageFd, &st);
  file_size = st.st_size;
  file_pos = 0;

#ifndef WIN32
#ifdef NO_SIGSEGV_HANDLING
  buf = mmap (NULL, file_size, PROT_READ|PROT_WRITE, MAP_PRIVATE, imageFd, 0);
#else
  buf = mmap (NULL, file_size, PROT_READ, MAP_PRIVATE, imageFd, 0);
#endif

  if (buf != (PTR) -1)
    {
      buf_size = file_size;
      buf_used_mmap = true;
      return buf;
    }
#endif /* !WIN32 */

  /* Non-mmaped input.  */
  buf_used_mmap = false;
  buf_size = numBytes;
  buf = xmalloc (buf_size);
  buffer_fill (imageFd);
  return NULL;
}

void
buffer_read_free (int imageFd)
{
  if (buf_used_mmap)
    _gst_osmem_free (buf, buf_size);
  else
    xfree (buf);
}

PTR
buffer_advance (int imageFd,
	        int numBytes)
{
  PTR current_pos = buf + buf_pos;
  buf_pos += numBytes;
  return current_pos;
}

void
buffer_read (int imageFd,
	     PTR pdata,
	     int numBytes)
{
  char *data = (char *) pdata;

  if UNCOMMON (numBytes > buf_size - buf_pos)
    {
      memcpy (data, buf + buf_pos, buf_size - buf_pos);
      data += buf_size - buf_pos;
      numBytes -= buf_size - buf_pos;
      file_pos += buf_size;
      if (numBytes > buf_size)
	{
	  lseek (imageFd, file_pos, SEEK_SET);
	  read (imageFd, data, numBytes & -buf_size);
	  file_pos += numBytes & -buf_size;
          data += numBytes & -buf_size;
	  numBytes -= numBytes & -buf_size;
	}

      /* else fill in the buffer and load the rest */
      buffer_fill (imageFd);
    }

  memcpy (data, buf + buf_pos, numBytes);
  buf_pos += numBytes;
}
