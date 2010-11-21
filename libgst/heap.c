/******************************** -*- C -*- ****************************
 *
 *	sbrk-like behavior for separate mmap'ed regions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2003, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini (redisorganization of GNU mmalloc).
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
 ***********************************************************************/


#include "gstpriv.h"

struct heap;

/* Internal structure that defines the format of the heap descriptor.
   This gets written to the base address of the region that we are
   managing.  */
struct heap
{
  size_t areasize;

  /* The base address of the memory region for this malloc heap.  This
     is the location where the bookkeeping data for mmap and for malloc
     begins.  */
  char *base;

  /* The current location in the memory region for this malloc heap
     which represents the end of memory in use.  */
  char *breakval;

  /* The end of the current memory region for this malloc heap.  This
     is the first location past the end of mapped memory.  */
  char *top;
};

/* This is the internal function for heap_sbrk which receives a struct
   heap instead of the pointer to the base location available to
   clients.  */
static PTR heap_sbrk_internal (struct heap *hdp,
			       int size);

/* Cache pagesize-1 for the current host machine.  Note that if the
   host does not readily provide a getpagesize() function, we need to
   emulate it elsewhere, not clutter up this file with lots of kluges
   to try to figure it out.  */
static size_t pageround, pagesize;
#ifndef HAVE_GETPAGESIZE
extern int getpagesize ();
#endif

#define PAGE_ALIGN(addr) ((PTR) (((intptr_t)(addr) + pageround) & ~pageround))

/* We allocate extra pages for the heap descriptor and answer an
   address that is HEAP_DELTA bytes past the actual beginning of the
   allocation.  */
#define HEAP_DELTA	 ((intptr_t) PAGE_ALIGN(sizeof (struct heap)))



heap
_gst_heap_create (PTR address, int size)
{
  struct heap mtemp;
  struct heap *hdp;
  heap hd;

  if (!pageround)
    {
      pagesize = getpagesize ();
      pageround = pagesize - 1;
    }

  if (address)
    address = (char *) address - HEAP_DELTA;

  /* We start off with the heap descriptor allocated on the stack,
     until we build it up enough to call heap_sbrk_internal() to
     allocate the first page of the region and copy it there.  Ensure
     that it is zero'd and then initialize the fields that we know
     values for.  */

  hdp = &mtemp;
  memset ((char *) hdp, 0, sizeof (mtemp));
  hdp->areasize = size;
  hdp->base = _gst_osmem_reserve (address, size);

  if (!hdp->base)
    return NULL;

  /* Now try to map in the first page, copy the heap descriptor
     structure there, and arrange to return a pointer to this new copy. 
     If the mapping fails, then close the file descriptor if it was
     opened by us, and arrange to return a NULL.  */

  hdp->top = hdp->breakval = hdp->base;
  if ((hdp = heap_sbrk_internal (hdp, HEAP_DELTA)) != NULL)
    {
      hd = ((char *) hdp) + HEAP_DELTA;
      memcpy (hdp, &mtemp, sizeof (mtemp));
    }
  else
    {
      hd = NULL;
      _gst_osmem_release (hdp->base, hdp->areasize);
    }

  return hd;
}

heap
_gst_heap_destroy (heap hd)
{
  struct heap mtemp;

  assert (hd);

  /* The heap descriptor that we are using is currently located in
     region we are about to unmap, so we first make a local copy of
     it on the stack and use the copy.  */
  mtemp = *(struct heap *) (hd - HEAP_DELTA);

  /* Now unmap all the pages associated with this region by asking
     for a negative increment equal to the current size of the
     region.  */
  if ((heap_sbrk_internal (&mtemp, mtemp.base - mtemp.top)) == NULL)
    /* Update the original heap descriptor with any changes */
    *(struct heap *) (hd - HEAP_DELTA) = mtemp;
  else
    {
      _gst_osmem_release (mtemp.base, mtemp.areasize);
      hd = NULL;
    }

  return (hd);
}

PTR
_gst_heap_sbrk (heap hd,
		size_t size)
{
  struct heap *hdp;

  assert (hd);
  hdp = (struct heap *) (hd - HEAP_DELTA);
  return heap_sbrk_internal (hdp, size);
}

PTR
heap_sbrk_internal (struct heap * hdp,
		    int size)
{
  char *result = NULL;
  size_t mapbytes;		/* Number of bytes to map */
  char *moveto;			/* Address where we wish to move "break 
				   value" to */
  char *mapto;			/* Address we actually mapped to */

  if (size == 0)
    /* Just return the current "break" value.  */
    result = hdp->breakval;

  else if (size < 0)
    {
      /* We are deallocating memory.  If the amount requested would
         cause us to try to deallocate back past the base of the mmap'd 
         region then do nothing, and return NULL.  Otherwise,
         deallocate the memory and return the old break value.  */
      if (hdp->breakval + size >= hdp->base)
	{
	  result = (PTR) hdp->breakval;
	  hdp->breakval += size;
	  moveto = PAGE_ALIGN (hdp->breakval);
	  _gst_osmem_decommit (moveto, (size_t) (hdp->top - moveto));
	  hdp->top = moveto;
	}
    }
  else if (hdp->breakval + size > hdp->top)
    {
      if (hdp->breakval - hdp->base + size > hdp->areasize)
        {
          if (hdp->breakval - hdp->base == hdp->areasize);
            {
              /* FIXME: a library should never exit!  */
              fprintf (stderr, "gst: out of memory allocating %d bytes\n",
                       size);
              exit (1);
            }
          size = hdp->areasize - (hdp->breakval - hdp->base);
        }

      moveto = PAGE_ALIGN (hdp->breakval + size);
      mapbytes = moveto - hdp->top;
      mapto = _gst_osmem_commit (hdp->top, mapbytes);
      if (!mapto)
	errno = ENOMEM;
      else
	{
	  hdp->top = moveto;
	  result = (PTR) hdp->breakval;
	  hdp->breakval += size;
	}
    }
  else
    {
      result = (PTR) hdp->breakval;
      hdp->breakval += size;
    }

  return (result);
}
