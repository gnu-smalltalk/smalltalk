/******************************** -*- C -*- ****************************
 *
 *	Binary image save/restore.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005
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
static mst_Boolean use_mmap;


/* This function buffers writes to the image file whose descriptor is
   IMAGEFD.  It should be called with DATA == NULL and N > 0 to
   establish the buffer size, with DATA == NULL and N == 0 to flush
   the data and free the buffer, and the same as write(2) to do the
   actual I/O.  */
static void buffer_write (int imageFd,
			  PTR data,
			  int numBytes);

/* This function buffers reads from the image file whose descriptor
   is IMAGEFD.  It should be called with DATA == NULL and N > 0 to
   establish the buffer size, with DATA == NULL and N == 0 to flush
   the data and free the buffer, and the same as write(2) to do the
   actual I/O.  Memory-mapped I/O is used is possible.  */
static void buffer_read (int imageFd,
			 PTR data,
			 int numBytes);

/* This function fills the buffer used by buffer_read.  It is used
   internally by buffer_read.  */
static void buffer_fill (int imageFd);

/* This function saves the object pointed to by OOP on the image-file
   whose descriptor is IMAGEFD.  The object pointers are made relative
   to the beginning of the object data-area.  */
static void save_object (int imageFd,
			 OOP oop);

/* This function converts NUMFIXED absolute addresses at OBJ->data,
   which are instance variables of the object, into relative ones.  */
static inline void fixup_object (mst_Object obj,
			  int numPointers);

/* This function converts NUMFIXED relative addresses at OBJ->data,
   which are instance variables of the object, into absolute ones.  */
static inline void restore_object (mst_Object object,
			    int numPointers);

/* This function inverts the endianness of SIZE long-words, starting at
   BUF.  */
static inline void fixup_byte_order (PTR buf,
			      size_t size);

/* This function converts NUMFIXED relative addresses, starting at
   OBJ->data, back to absolute form.  */
static inline void restore_pointer_slots (mst_Object obj,
				          int numPointers);

/* This function loads an OOP table made of OLDSLOTSUSED slots from
   the image file stored in the file whose descriptor is IMAGEFD.
   The fixup gets handled by load_normal_oops */
static void load_oop_table (int imageFd);

/* This function loads OBJECTDATASIZE bytes of object data belonging
   to standard (i.e. non built-in OOPs) and fixes the endianness of
   the objects, as well as converting to absolute the address of
   their class.  Endianness conversion is done in two steps: first
   the non-byte objects (identified by not having the F_BYTE flag),
   including the class objects which are necessary to fix the byte
   objects, then all the byte-objects which also have instance
   variables). 
   Object data is loaded from the IMAGEFD file descriptor.  */
static void load_normal_oops (int imageFd);

/* This function stores the header of the image file into the file
   whose descriptor is IMAGEFD.  */
static void save_file_version (int imageFd);

/* This function loads into HEADERP the header of the image file
   without checking its validity.
   This data is loaded from the IMAGEFD file descriptor.  */
static void load_file_version (int imageFd,
			       save_file_header * headerp);

/* This function walks the OOP table and converts all the relative
   addresses for the instance variables to absolute ones.  */
static inline void restore_all_pointer_slots (void);

/* This function converts all the relative addresses for OOP's
   instance variables to absolute ones.  */
static inline void restore_oop_pointer_slots (OOP oop);

/* This function prepares the OOP table to be written to the image
   file.  This contains the object sizes instead of the pointers,
   since addresses will be recalculated upon load.  */
static struct OOP *make_oop_table_to_be_saved (void);

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

/* Convert to a relative offset from start of OOP table.  The offset
   is 0 mod pointer-size, so it still looks like a pointer to the
   IS_INT test.  */
#define OOP_RELATIVE(obj) \
  ( (OOP)((intptr_t)(obj) - (intptr_t)_gst_mem.ot) )

/* Convert from relative offset to actual oop table address.  */
#define OOP_ABSOLUTE(obj) \
  ( (OOP)((intptr_t)(obj) + (intptr_t)_gst_mem.ot) )


struct OOP *myOOPTable = NULL;

mst_Boolean
_gst_save_to_file (const char *fileName)
{
  int imageFd;

  imageFd = _gst_open_file (fileName, "w");
  if (imageFd < 0)
    return (false);

  _gst_invoke_hook ("aboutToSnapshot");

  _gst_global_gc (0);
  _gst_finish_incremental_gc ();

  myOOPTable = make_oop_table_to_be_saved ();

  buffer_write (imageFd, NULL, WRITE_BUFFER_SIZE);
  save_file_version (imageFd);

#ifdef SNAPSHOT_TRACE
  printf ("After saving header: %lld\n",
	  lseek (imageFd, 0, SEEK_CUR));
#endif /* SNAPSHOT_TRACE */

  /* save up to the last oop slot in use */
  buffer_write (imageFd, myOOPTable,
		sizeof (struct OOP) * num_used_oops);

#ifdef SNAPSHOT_TRACE
  printf ("After saving oop table: %lld\n",
	  lseek (imageFd, 0, SEEK_CUR));
#endif /* SNAPSHOT_TRACE */

  save_all_objects (imageFd);
  xfree (myOOPTable);

#ifdef SNAPSHOT_TRACE
  printf ("After saving all objects: %lld\n",
	  lseek (imageFd, 0, SEEK_CUR));
#endif /* SNAPSHOT_TRACE */

  buffer_write (imageFd, NULL, 0);
  close (imageFd);

  _gst_invoke_hook ("finishedSnapshot");

  return (true);
}


struct OOP *
make_oop_table_to_be_saved (void)
{
  OOP oop;
  struct OOP *myOOPTable;
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

  myOOPTable = xmalloc (sizeof (struct OOP) * num_used_oops);

  for (i = 0, oop = _gst_mem.ot; i < num_used_oops; oop++, i++)
    {
      if (IS_OOP_VALID_GC (oop))
	{
	  int numPointers;
          myOOPTable[i].flags = oop->flags;
	  numPointers = NUM_OOPS (oop->object);

	  /* Cache the number of indexed instance variables.  We prefer
	     to do more work upon saving (done once) than upon loading
	     (done many times).  */
	  if (numPointers < (F_COUNT >> F_COUNT_SHIFT))
	    myOOPTable[i].flags |= numPointers << F_COUNT_SHIFT;
	  else
	    myOOPTable[i].flags |= F_COUNT;

	  myOOPTable[i].object = (mst_Object) TO_INT (oop->object->objSize);
	}
      else
	myOOPTable[i].flags = F_FREE;
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
  mst_Object object;
  int numPointers, numBytes;

#ifdef SNAPSHOT_TRACE
  printf (">Save ");
  _gst_display_oop (oop);
#endif

  object = OOP_TO_OBJ (oop);
  numPointers = NUM_OOPS (object);

  if (IS_OOP_FREE (oop))
    abort ();

  fixup_object (object, numPointers);
  numBytes = sizeof (OOP) * TO_INT (object->objSize);
  buffer_write (imageFd, object, numBytes);
  restore_object (object, numPointers);
}

void
save_file_version (int imageFd)
{
  save_file_header header;

  memzero (&header, sizeof (header));
  memcpy (header.dummy, EXECUTE, strlen (EXECUTE));
  memcpy (header.signature, SIGNATURE, strlen (SIGNATURE));
  header.flags = FLAGS_WRITTEN;
  header.version = VERSION_REQUIRED;
  header.oopTableSize = num_used_oops;
  header.edenSpaceSize = _gst_mem.eden.totalSize;
  header.survSpaceSize = _gst_mem.surv[0].totalSize;
  header.oldSpaceSize = _gst_mem.old->heap_limit;

  header.big_object_threshold = _gst_mem.big_object_threshold;
  header.grow_threshold_percent = _gst_mem.grow_threshold_percent;
  header.space_grow_rate = _gst_mem.space_grow_rate;
  buffer_write (imageFd, &header, sizeof (save_file_header));
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

  buffer_read (imageFd, NULL, 0);

  close (imageFd);
  return (loaded);
}

mst_Boolean
load_snapshot (int imageFd)
{
  save_file_header header;

  buffer_read (imageFd, NULL, READ_BUFFER_SIZE);
  load_file_version (imageFd, &header);
  if (strcmp (header.signature, SIGNATURE))
    return (false);

  /* different sizeof(PTR) not supported */
  if (FLAG_CHANGED (header.flags, SLOT_SIZE_FLAG))
    return (false);

  if UNCOMMON ((wrong_endianness =
         FLAG_CHANGED (header.flags, ENDIANNESS_FLAG)))
    {
      header.oopTableSize = BYTE_INVERT (header.oopTableSize);
      header.edenSpaceSize = BYTE_INVERT (header.edenSpaceSize);
      header.survSpaceSize = BYTE_INVERT (header.survSpaceSize);
      header.oldSpaceSize = BYTE_INVERT (header.oldSpaceSize);
      header.big_object_threshold = BYTE_INVERT (header.big_object_threshold);
      header.grow_threshold_percent = BYTE_INVERT (header.grow_threshold_percent);
      header.space_grow_rate = BYTE_INVERT (header.space_grow_rate);
      header.version = BYTE_INVERT (header.version);
    }

  /* check for version mismatch; if so this image file is invalid */
  if (header.version > VERSION_REQUIRED)
    return (false);

#ifdef SNAPSHOT_TRACE
  printf ("After loading header: %lld\n", file_pos + buf_pos);
#endif /* SNAPSHOT_TRACE */

  _gst_init_mem (header.edenSpaceSize, header.survSpaceSize,
		 header.oldSpaceSize, header.big_object_threshold,
		 header.grow_threshold_percent, header.space_grow_rate);

  _gst_init_oop_table (MAX (header.oopTableSize * 2,
		       INITIAL_OOP_TABLE_SIZE));

  num_used_oops = header.oopTableSize;
  load_oop_table (imageFd);

#ifdef SNAPSHOT_TRACE
  printf ("After loading OOP table: %lld\n", file_pos + buf_pos);
#endif /* SNAPSHOT_TRACE */

  load_normal_oops (imageFd);

#ifdef SNAPSHOT_TRACE
  printf ("After loading objects: %lld\n", file_pos + buf_pos);
#endif /* SNAPSHOT_TRACE */

  restore_all_pointer_slots ();

  if (_gst_init_dictionary_on_image_load (num_used_oops))
    {
#ifdef SNAPSHOT_TRACE
      _gst_dump_oop_table ();
#endif /* SNAPSHOT_TRACE */
      return (true);
    }

  return (false);
}

void
load_file_version (int imageFd,
		   save_file_header * headerp)
{
  buffer_read (imageFd, headerp, sizeof (save_file_header));
}

void
load_oop_table (int imageFd)
{
  OOP oop;

  /* load in the valid OOP slots from previous dump */
  buffer_read (imageFd, _gst_mem.ot, sizeof (struct OOP) * num_used_oops);
  if UNCOMMON (wrong_endianness)
    fixup_byte_order (_gst_mem.ot,
		      sizeof (struct OOP) * num_used_oops / sizeof (PTR));

  /* mark the remaining ones as available */
  PREFETCH_START (&_gst_mem.ot[num_used_oops], PREF_WRITE | PREF_NTA);
  for (oop = &_gst_mem.ot[num_used_oops];
       oop < &_gst_mem.ot[_gst_mem.ot_size]; oop++)
    {
      PREFETCH_LOOP (oop, PREF_WRITE | PREF_NTA);
      oop->flags = F_FREE;
      oop++;
    }
}


void
load_normal_oops (int imageFd)
{
  OOP oop;
  mst_Object object;

  /* Now walk the oop table.  Start fixing the byte order.  */

  _gst_mem.num_free_oops = _gst_mem.ot_size - num_used_oops;
  _gst_mem.last_allocated_oop = &_gst_mem.ot[num_used_oops - 1];
  PREFETCH_START (_gst_mem.ot, PREF_WRITE | PREF_NTA);
  for (oop = _gst_mem.ot; oop < &_gst_mem.ot[num_used_oops];
       oop++)
    {
      size_t size;

      PREFETCH_LOOP (oop, PREF_WRITE | PREF_NTA);
      if (oop->flags & F_FREE)
	{
	  _gst_mem.num_free_oops++;
	  oop->flags = F_FREE;	/* just free */
	  continue;
	}

      /* FIXME: a small amount of garbage is saved that is produced
         by mourning the ephemerons right before GC.  We should probably
         put the objects to be mourned into a global list and walk it
         with a separate, *global* function _gst_mourn_objects().  This
         way we could save the objects before their mourning (which
         would happen on the image load) and before there is the occasion
	 to create new-space objects.  The solution is not however as neat
	 as possible.  */

      oop->flags &= ~(F_SPACES | F_POOLED);
      oop->flags |= F_OLD;

      _gst_mem.numOldOOPs++;
      if (oop->flags & F_FIXED)
	_gst_mem.numFixedOOPs++;

      size = (size_t) oop->object;
      object = (mst_Object) _gst_mem_alloc (
	(oop->flags & F_FIXED) ? _gst_mem.fixed : _gst_mem.old,
        size * sizeof (PTR));

      buffer_read (imageFd, object, sizeof (PTR) * size);
      if (!IS_INT (object->objSize) || TO_INT (object->objSize) != size)
	abort ();

      object->objClass = OOP_ABSOLUTE (object->objClass);

      /* Remove flags that are invalid after an image has been loaded.  */
      oop->flags &= ~F_RUNTIME;

      oop->object = object;
      if UNCOMMON (wrong_endianness)
	{
	  OOP size = (OOP) BYTE_INVERT ((intptr_t) oop->object->objSize);
	  fixup_byte_order (object, 
			    (oop->flags & F_BYTE)
			      ? OBJ_HEADER_SIZE_WORDS : TO_INT (size));
	}

      if (oop->flags & F_WEAK)
	_gst_make_oop_weak (oop);

      if (oop->flags & F_CONTEXT)
	{
	  /* this is another quirk; this is not the best place to do
	     it. We have to reset the nativeIPs so that we can find
	     restarted processes and recompile their methods.  */
	  gst_method_context context = (gst_method_context) object;
	  context->native_ip = DUMMY_NATIVE_IP;
	}
    }

  /* NUM_OOPS requires access to the instance spec in the class
     objects. So we start by fixing the endianness of NON-BYTE objects
     (including classes!), for which we can do without NUM_OOPS, then
     do another pass here and fix the byte objects using the now
     correct class objects.  */
  if UNCOMMON (wrong_endianness)
    for (oop = _gst_mem.ot; oop < &_gst_mem.ot[num_used_oops];
         oop++)
      if (oop->flags & F_BYTE)
	{
	  object = OOP_TO_OBJ (oop);
	  fixup_byte_order (object->data, NUM_OOPS (object));
	}
}


/* Routines to convert to/from relative pointers, shared by
   loading and saving */

void
fixup_object (mst_Object obj,
	      int numPointers)
{
  OOP instOOP, class_oop, *i;

  class_oop = obj->objClass;
  obj->objClass = OOP_RELATIVE (class_oop);

  for (i = obj->data; numPointers; i++, numPointers--)
    {
      instOOP = *i;
      if (IS_OOP (instOOP))
	*i = OOP_RELATIVE (instOOP);
    }
}

void
restore_object (mst_Object object,
		     int numPointers)
{
  object->objClass = OOP_ABSOLUTE (object->objClass);
  restore_pointer_slots (object, numPointers);
}

void
restore_pointer_slots (mst_Object obj,
		       int numPointers)
{
  OOP instOOP, *i;

  i = obj->data;
  while (numPointers--)
    {
      instOOP = *i;
      if (IS_OOP (instOOP))
	*i = OOP_ABSOLUTE (instOOP);

      i++;
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
  mst_Object object;

  object = OOP_TO_OBJ (oop);
  if UNCOMMON ((oop->flags & F_COUNT) == F_COUNT)
    numPointers = NUM_OOPS (object);
  else
    numPointers = oop->flags >> F_COUNT_SHIFT;

  restore_pointer_slots (object, numPointers);
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
buffer_write (int imageFd,
	      PTR data,
	      int numBytes)
{
  if UNCOMMON (!data)
    {
      if (numBytes)
	{
	  buf = xmalloc (numBytes);
	  buf_size = numBytes;
	}
      else
	{
	  _gst_full_write (imageFd, buf, buf_pos);
	  xfree (buf);
	}

      buf_pos = 0;
      return;
    }

  if UNCOMMON (buf_pos + numBytes > buf_size)
    {
      _gst_full_write (imageFd, buf, buf_pos);
      buf_pos = 0;
    }

  if UNCOMMON (numBytes > buf_size)
    _gst_full_write (imageFd, data, numBytes);
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
  if (use_mmap)
    {
#ifndef WIN32
      if (buf)
	_gst_osmem_free (buf, buf_size);

      buf = mmap (NULL, buf_size, PROT_READ, MAP_SHARED, imageFd, file_pos);

      if (buf != (PTR) -1)
	{
#ifdef HAVE_MADVISE
#ifdef MADV_WILLNEED
	  madvise (buf, buf_size, MADV_WILLNEED);
#endif

	  /* Ahem... this madvise causes a kernel OOPS on my machine!  */
#if 0
#ifdef MADV_SEQUENTIAL
	  madvise (buf, buf_size, MADV_SEQUENTIAL);
#endif
#endif

#endif /* HAVE_MADVISE */
	  return;
	}
#endif /* !WIN32 */

      /* First non-mmaped input operation.  Allocate the buffer.  */
      buf = xmalloc (buf_size);
      use_mmap = false;
    }

  /* Cannot mmap the file, use read(2).  */
  read (imageFd, buf, buf_size);
}

void
buffer_read (int imageFd,
	     PTR pdata,
	     int numBytes)
{
  char *data = (char *) pdata;

  if UNCOMMON (!data)
    {
      if (numBytes)
	{
	  struct stat st;
	  fstat (imageFd, &st);
	  file_size = st.st_size;
	  file_pos = 0;
	  buf_size = numBytes;
	  use_mmap = true;
	  buf = NULL;
	  buffer_fill (imageFd);
	}
      else
	{
	  if (use_mmap)
	    _gst_osmem_free (buf, buf_size);
	  else
	    xfree (buf);
	}

      return;
    }

  /* Avoid triggering a SIGBUS.  */
  if UNCOMMON (numBytes > file_size - file_pos)
    {
      memzero (data + file_size - file_pos, numBytes - (file_size - file_pos));
      numBytes = file_size - file_pos;
    }

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
