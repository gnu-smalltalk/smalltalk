/******************************** -*- C -*- ****************************
 *
 *	Memory allocation for Smalltalk
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2003, 2004, 2005, 2006, 2007, 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.  Ideas based on Mike Haertel's malloc.
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

#define	SMALL2FREE(B, N)	((heap_freeobj*)(((char *)(B)->vSmall.data) + (N)*(B)->size))

#define	MEM2BLOCK(M)		((heap_block*)(((intptr_t)(M)) & -pagesize))
#define	MEM2FREE(M)		((heap_freeobj*)(M))

#define	BLOCKEND(B)		((heap_block*)(((unsigned char*)(B)) + (B)->size))

#define	MAX_SMALL_OBJ_SIZE	16384
#define	IS_SMALL_SIZE(S)	((S) <= max_small_object_size)

#define	MEMALIGN		8
#define	ROUNDUPALIGN(V)		(((intptr_t)(V) + MEMALIGN - 1) & -MEMALIGN)
#define	ROUNDUPPAGESIZE(V)	(((intptr_t)(V) + pagesize - 1) & -pagesize)

#define	OBJECT_SIZE(M)		(MEM2BLOCK(M)->size)

#define MMAP_AREA_SIZE		(sizeof (long) << 26)	/* 256/512 Mb */
#define MMAP_THRESHOLD		(sizeof (long) << 15)	/* 128/256 kb */

/* Depending on the architecture, heap_block->vSmall.data could be
   counted as 1 or 4 bytes.  This formula gets it right.  */
#define offset_of(field, type) \
  (((char *) &( ((type *) 8) -> field )) - (char *) 8)

#define SMALL_OBJ_HEADER_SIZE       offset_of (vSmall.data, heap_block)
#define LARGE_OBJ_HEADER_SIZE       offset_of (vLarge.data, heap_block)

static void init_heap (heap_data *h, size_t heap_allocation_size, size_t heap_limit);

#define vSmall var.small
#define vLarge var.large
#define vFree  var.free

static heap_block *heap_small_block (heap_data *h, size_t);
static heap_block *heap_large_block (heap_data *h, size_t);
static void heap_system_alloc (heap_data *h, size_t);

static heap_block *heap_primitive_alloc (heap_data *h, size_t);
static void heap_add_to_free_list (heap_data *h, heap_block *);
static void heap_primitive_free (heap_data *h, heap_block *);
static PTR morecore (size_t);



/* This list was produced by this command 

   echo 'for (i = (4072 + 7) / 32; i >= 1; i--) (4072 / i) / 32 * 32; 0' |
     bc | uniq | sed '$!s/$/,/' | fmt -60

   for 32-bit machines, and similarly with 4064 instead of
   4072 for 64-bit machines.  8 and 16 were added manually.  */

static unsigned short freelist_size[NUM_FREELISTS + 1] = {
  8, 16, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352,
  384, 448, 480, 576, 672, 800, 992, 1344, 2016,
  4096 - SMALL_OBJ_HEADER_SIZE,
  8192 - SMALL_OBJ_HEADER_SIZE,
  16384 - SMALL_OBJ_HEADER_SIZE, 0
};

static unsigned short sztable[MAX_SMALL_OBJ_SIZE + 1];

static heap_block *heap_prim_freelist = NULL;
static size_t max_small_object_size;
static size_t pagesize;


/* Create a new memory heap  */
heap_data *
_gst_mem_new_heap (size_t heap_allocation_size, size_t heap_limit)
{
  heap_data *h = (heap_data *) xcalloc (1, sizeof (*h));
  init_heap (h, heap_allocation_size, heap_limit);
  return h;
}

/* Initialize a memory heap  */
static void
init_heap (heap_data *h, size_t heap_allocation_size, size_t heap_limit)
{
  int sz;
  int i;

  if (!pagesize)
    {
      pagesize = getpagesize ();

      /* Use the preinitialized freelist table to initialize
         the sztable.  */
      for (sz = i = 0; freelist_size[i] > 0 && freelist_size[i] < pagesize; i++)
        for (; sz <= freelist_size[i]; sz++)
          sztable[sz] = i;
      max_small_object_size = sz - 1;
    }

  for (i = 0; freelist_size[i] > 0; i++)
    h->freelist[i] = NULL;

  h->heap_allocation_size = (heap_allocation_size
			     ? ROUNDUPPAGESIZE (heap_allocation_size)
			     : MMAP_THRESHOLD);
  h->heap_limit = heap_limit;
  h->mmap_count = 0;
  h->heap_total = 0;
  h->probes = h->splits = h->matches = h->failures = 0;
  h->after_allocating = NULL;
  h->after_prim_allocating = NULL;
  h->before_prim_freeing = NULL;
  h->nomemory = NULL;
}


/* _gst_mem_alloc
   Allocate a piece of memory.  */
PTR
_gst_mem_alloc (heap_data *h, size_t sz)
{
  size_t lnr;
  heap_freeobj *mem;
  heap_block **mptr;
  heap_block *blk;
  size_t nsz;
  int times;

  times = 0;
rerun:
  times++;
  if (IS_SMALL_SIZE (sz))
    {
      /* Translate size to object free list */
      sz = ROUNDUPALIGN (sz);

      lnr = sztable[sz];
      nsz = freelist_size[lnr];

      /* No available objects? Allocate some more */
      mptr = &h->freelist[lnr];
      blk = *mptr;
      if (!blk)
	{
	  blk = heap_small_block (h, nsz);
	  if (!blk)
	    {
	      nsz = pagesize;
	      goto nospace;
	    }

#ifndef OPTIMIZE
          if (((intptr_t) blk) & (pagesize - 1))
	    abort ();
#endif

	  blk->vSmall.nfree = *mptr;
	  *mptr = blk;
	}

      /* Unlink free one and return it */
      mem = blk->vSmall.free;

#ifndef OPTIMIZE
      if (!blk->vSmall.free || !blk->vSmall.avail)
	abort ();

      if (((intptr_t) mem <= (intptr_t) blk) ||
	  ((intptr_t) mem >= (intptr_t) blk + pagesize))
	abort ();
#endif

      blk->vSmall.free = mem->next;

      /* Once we use all the sub-blocks up, remove the whole block
         from the freelist.  */
      blk->vSmall.avail--;
      if (!blk->vSmall.free)
	*mptr = blk->vSmall.nfree;
    }

  else
    {
      nsz = sz;
      blk = heap_large_block (h, nsz);
      nsz += LARGE_OBJ_HEADER_SIZE;
      nsz = ROUNDUPPAGESIZE (nsz);
      if (blk == 0)
        goto nospace;

      mem = (heap_freeobj *) blk->vLarge.data;
    }

#ifndef OPTIMIZE
  if (OBJECT_SIZE (mem) < sz)
    abort ();
#endif

  if (h->after_allocating)
    h->after_allocating (h, blk, sz);

  return (mem);

nospace:
  /* Failed to find space in any freelists. Must try to get the
     memory from somewhere.  */
  switch (times)
    {
    case 1:
      /* Try asking the program to free some memory, but only if
         it's worth doing.  */
      if (h->heap_limit && h->heap_total <= h->heap_limit
	  && h->heap_total + nsz > h->heap_limit && h->nomemory)
	{
	  h = h->nomemory (h, nsz);
	  if (h)
	    break;
	  else
	    return NULL;
	}

    case 2:
      /* Get from the system */
      if (!h->heap_limit || h->heap_total < h->heap_limit)
        {
	  if (nsz < h->heap_allocation_size)
	    nsz = h->heap_allocation_size;

          heap_system_alloc (h, nsz);
	  h->failures++;
          break;
        }

    default:
      return (NULL);
    }

  /* Try again */
  goto rerun;
}


PTR
_gst_mem_realloc (heap_data *h, PTR mem, size_t size)
{
  heap_block *info;
  int pages_to_free;
  unsigned mmap_block;

  if (mem == NULL)
    return _gst_mem_alloc (h, size);

  if (size == 0)
    {
      _gst_mem_free (h, mem);
      return NULL; 
    }

  info = MEM2BLOCK (mem);

  if (size > info->size)
    {
      PTR p;
      p = _gst_mem_alloc (h, size);
      memcpy (p, mem, info->size);
      _gst_mem_free (h, mem);
      return p;
    }

  if (IS_SMALL_SIZE (info->size))
    return mem;

  mmap_block = info->mmap_block;
  pages_to_free = (info->size - size) / pagesize;
  if (!pages_to_free)
    return mem;

  info->size -= pages_to_free * pagesize;

  /* Split into a busy and a free block */
  info = (heap_block *) &info->vLarge.data[info->size];
  info->size = pages_to_free * pagesize;
  info->mmap_block = mmap_block;
  heap_primitive_free (h, info);

  return mem;
}

/* Free a piece of memory.  */
void
_gst_mem_free (heap_data *h, PTR mem)
{
  heap_block *info;
  heap_freeobj *obj;
  int lnr;
  int msz;

  if (!mem)
    return;

  info = MEM2BLOCK (mem);
  msz = info->size;
  if (IS_SMALL_SIZE (msz))
    {
      lnr = sztable[msz];
      /* If this block contains no free sub-blocks yet, attach
         it to freelist.  */
      if (++info->vSmall.avail == 1)
	{
#ifndef OPTIMIZE
	  if ( ((intptr_t) info) & (pagesize - 1))
	    abort ();
#endif

	  info->vSmall.nfree = h->freelist[lnr];
	  h->freelist[lnr] = info;
	}
      obj = MEM2FREE (mem);
      obj->next = info->vSmall.free;
      info->vSmall.free = obj;

#ifndef OPTIMIZE
      if ((intptr_t) obj < (intptr_t) info ||
	  (intptr_t) obj >= (intptr_t) info + pagesize ||
	  (intptr_t) obj == (intptr_t) (obj->next))
	abort ();

      if (info->vSmall.avail > info->vSmall.nr)
	abort ();
#endif

      /* If we free all sub-blocks, free the block */
      if (info->vSmall.avail == info->vSmall.nr)
	{
	  heap_block **finfo = &h->freelist[lnr];

	  for (;;)
	    {
	      if (*finfo == info)
		{
		  (*finfo) = info->vSmall.nfree;
		  info->size = pagesize;
		  heap_primitive_free (h, info);
		  break;
		}
	      finfo = &(*finfo)->vSmall.nfree;
#ifndef OPTIMIZE
	      if (!*finfo)
		abort ();
#endif
	    }
	}
    }

  else
    {
      /* Calculate true size of block */
      msz += LARGE_OBJ_HEADER_SIZE;
      msz = ROUNDUPPAGESIZE (msz);
      info->size = msz;
      h->mmap_count -= info->mmap_block;
      heap_primitive_free (h, info);
    }
}


/* Allocate a new block of memory.  The block will contain 'nr' objects
   each of 'sz' bytes.  */
static heap_block *
heap_small_block (heap_data *h, size_t sz)
{
  heap_block *info;
  int i;
  int nr;
  info = heap_primitive_alloc (h, pagesize);
  if (!info)
    return (NULL);

  /* Calculate number of objects in this block */
  nr = (pagesize - SMALL_OBJ_HEADER_SIZE) / sz;
  /* Setup the meta-data for the block */
  info->size = sz;
  info->vSmall.nr = nr;
  info->vSmall.avail = nr;

  /* Build the objects into a free list */
  for (i = nr - 1; i >= 0; i--)
    SMALL2FREE (info, i)->next = SMALL2FREE (info, i + 1);

  SMALL2FREE (info, nr - 1)->next = 0;
  info->vSmall.free = SMALL2FREE (info, 0);

  return (info);
}

/* Allocate a new block of memory.  The block will contain one object */
static heap_block *
heap_large_block (heap_data *h, size_t sz)
{
  heap_block *info;
  size_t msz;
  /* Add in management overhead */
  msz = sz + LARGE_OBJ_HEADER_SIZE;
  /* Round size up to a number of pages */
  msz = ROUNDUPPAGESIZE (msz);

  info = heap_primitive_alloc (h, msz);
  if (!info)
    return (NULL);

  info->size = msz - LARGE_OBJ_HEADER_SIZE;
  return (info);
}


/* Allocate a block of memory from the free list or, failing that, the
   system pool.  */
static heap_block *
heap_primitive_alloc (heap_data *h, size_t sz)
{
  heap_block *ptr;
  heap_block **pptr;
  
  /* If we will pass the heap boundary, return 0 to indicate that
     we're run out.  */
  if (h->heap_limit && h->heap_total <= h->heap_limit
      && h->heap_total + sz > h->heap_limit)
    return (NULL);

#ifndef OPTIMIZE
  if (sz & (pagesize - 1))
    abort ();
#endif

  if (sz > MMAP_THRESHOLD)
    {
      ptr = _gst_osmem_alloc (sz);
      if (ptr)
        {
	  if (h->after_prim_allocating)
	    h->after_prim_allocating (h, ptr, sz);

          h->heap_total += sz;
          h->mmap_count++;

	  /* Setup the meta-data for the block */
          ptr->mmap_block = 1;
	  ptr->user = 0;
	  ptr->size = sz;
          if (((intptr_t) ptr) & (pagesize - 1))
	    abort ();

	  return ptr;
	}
    }

  for (pptr = &heap_prim_freelist; (ptr = *pptr); pptr = &(ptr->vFree.next))
    {
      h->probes++;
#ifndef OPTIMIZE
      if (((intptr_t) ptr) & (pagesize - 1))
	abort ();

      if (ptr->size & (pagesize - 1))
	abort ();
#endif

      /* First fit */
      if (sz <= ptr->size)
	{
	  size_t left;
	  /* If there's more than a page left, split it */
	  left = ptr->size - sz;
	  if (left >= pagesize)
	    {
	      heap_block *nptr;
	      ptr->size = sz;
	      nptr = BLOCKEND (ptr);
	      nptr->size = left;
	      nptr->vFree.next = ptr->vFree.next;
	      ptr->vFree.next = nptr;
	      h->splits++;
	    }
	  else
	    h->matches++;

	  *pptr = ptr->vFree.next;

	  ptr->mmap_block = 0;
	  ptr->user = 0;
	  h->heap_total += sz;
	  if (h->after_prim_allocating)
	    h->after_prim_allocating (h, ptr, sz);

	  return (ptr);
	}
    }

  /* Nothing found on free list */
  return (NULL);
}


/* Return a block of memory to the free list.  */
static void
heap_primitive_free (heap_data *h, heap_block *mem)
{
#ifndef OPTIMIZE
  if (mem->size & (pagesize - 1))
    abort ();
#endif

  if (h->before_prim_freeing)
    h->before_prim_freeing (h, mem, mem->size);

  h->heap_total -= mem->size;
  if (mem->mmap_block)
    {
      _gst_osmem_free (mem, mem->size);
      return;
    }

  heap_add_to_free_list (h, mem);
}

static void
heap_add_to_free_list (heap_data *h, heap_block *mem)
{
  heap_block *lptr;
  heap_block *nptr;

#ifndef OPTIMIZE
  if (((intptr_t) mem) & (pagesize - 1))
    abort ();

  if (mem->size & (pagesize - 1))
    abort ();
#endif

  if (mem < heap_prim_freelist || heap_prim_freelist == 0)
    {
      /* If this block is directly before the first block on the
         freelist, merge it into that block.  Otherwise just
         attach it to the beginning.  */
      if (BLOCKEND (mem) == heap_prim_freelist)
	{
	  mem->size += heap_prim_freelist->size;
	  mem->vFree.next = heap_prim_freelist->vFree.next;
	}
      else
	mem->vFree.next = heap_prim_freelist;

      heap_prim_freelist = mem;
      return;
    }

  /* Search the freelist for the logical place to put this block */
  lptr = heap_prim_freelist;
  while (lptr->vFree.next != 0)
    {
#ifndef OPTIMIZE
      if (lptr->size & (pagesize - 1))
	abort ();
#endif

      nptr = lptr->vFree.next;
      if (mem > lptr && mem < nptr)
	{
	  /* Block goes here in the logical scheme of things.
	     Work out how to merge it with those which come
	     before and after.  */
	  if (BLOCKEND (lptr) == mem)
	    {
	      if (BLOCKEND (mem) == nptr)
		{
		  /* Merge with last and next */
		  lptr->size += mem->size + nptr->size;
		  lptr->vFree.next = nptr->vFree.next;
		}
	      else
		/* Merge with last but not next */
		lptr->size += mem->size;
	    }

	  else
	    {
	      if (BLOCKEND (mem) == nptr)
		{
		  /* Merge with next but not last */
		  mem->size += nptr->size;
		  mem->vFree.next = nptr->vFree.next;
		  lptr->vFree.next = mem;
		}
	      else
		{
		  /* Wont merge with either */
		  mem->vFree.next = nptr;
		  lptr->vFree.next = mem;
		}
	    }
	  return;
	}
      lptr = nptr;
    }

  /* If 'mem' goes directly after the last block, merge it in.
     Otherwise, just add in onto the list at the end.  */
  mem->vFree.next = NULL;
  if (BLOCKEND (lptr) == mem)
    lptr->size += mem->size;
  else
    lptr->vFree.next = mem;
}

static void
heap_system_alloc (heap_data *h, size_t sz)
{
  heap_block * mem;
#ifndef OPTIMIZE
  if (sz & (pagesize - 1))
    abort ();
#endif

  mem = (heap_block *) morecore (sz);
  mem->mmap_block = 0;
  mem->size = sz;

  /* Free block into the system */
  heap_add_to_free_list (h, mem);
}

PTR
morecore (size_t size)
{
  heap just_allocated_heap = NULL;

  /* _gst_heap_sbrk is actually the same as sbrk as long as
     current_heap is NULL.  But we cannot do that unless we
     can replace malloc (which we cannot do on MacOS X, see above).  */
  static heap current_heap = NULL;

  if (current_heap == NULL)
    {
      just_allocated_heap = _gst_heap_create (NULL, MMAP_AREA_SIZE);
      if (!just_allocated_heap)
	return (NULL);
      current_heap = just_allocated_heap;
    }

  for (;;)
    {
      char *ptr = _gst_heap_sbrk (current_heap, size);

      if (ptr != (PTR) -1)
	{
          if (((intptr_t) ptr & (pagesize - 1)) > 0)
            {
	      /* Oops, we have to align to a page.  */
	      int missed = pagesize - ((intptr_t) ptr & (pagesize - 1));
	      _gst_heap_sbrk (current_heap, -size + missed);
	      ptr = _gst_heap_sbrk (current_heap, size);
            }

          if (ptr != (PTR) -1)
	    return (ptr);
	}

      /* The data segment we're using might bang against an mmap-ed
	 area (the sbrk segment for example cannot grow more than
	 960M on Linux).  We try using a new mmap-ed area, but be
	 careful not to loop!  */
      if (just_allocated_heap)
	return (NULL);

      just_allocated_heap = _gst_heap_create (NULL, MMAP_AREA_SIZE);
      if (!just_allocated_heap)
	return (NULL);

      current_heap = just_allocated_heap;
    }
}


char *
xstrdup (const char *str)
{
  int  length = strlen (str) + 1;
  char *newstr = (char *) xmalloc (length);
  memcpy(newstr, str, length);
  return (newstr);
}

PTR 
xmalloc (size_t n)
{
  PTR block;

  block = malloc(n);
  if (!block && n)
    nomemory(1);

  return (block);
}

PTR 
xcalloc (size_t n, size_t s)
{
  PTR block;

  block = calloc(n, s);
  if (!block && n && s)
    nomemory(1);

  return (block);
}

PTR 
xrealloc (PTR p, size_t n)
{
  PTR block;

  block = realloc(p, n);
  if (!block && n)
    nomemory(1);

  return (block);
}

void
xfree (PTR p)
{
  if (p)
    free(p);
}

void
nomemory (int fatal)
{
  fputs ("\n\n[Memory allocation failure]"
	 "\nCan't allocate enough memory to continue.\n",
	 stderr);

  if (fatal)
    exit (1);
}

