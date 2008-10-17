/******************************** -*- C -*- ****************************
 *
 *	Memory allocation for Smalltalk
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2004, 2006, 2007, 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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

#ifndef GST_ALLOC_H
#define GST_ALLOC_H

#define NUM_FREELISTS 47

/* Oh my God, how broken things sometimes are!  */ 
#if defined small
# undef small
#endif

typedef struct heap_freeobj
{
  struct heap_freeobj *next;
}
heap_freeobj;

typedef struct heap_block
{
  size_t size;			 /* Size of objects in this block */
  unsigned mmap_block : 1;	 /* Whether the block was mmap-ed */
  unsigned user : 1;
  unsigned pad : 30;		 /* needed for linux/m68k?  */
  union {
    struct {
      int nr;			 /* Nr of objects in block */
      int avail;		 /* Nr of objects available in block */
      struct heap_freeobj *free; /* Next free sub-block */
      struct heap_block *nfree;	 /* Next block on sub-freelist */
      long double data[1];	 /* Give appropriate alignment */
    } small;
    struct {
      struct heap_block *next;	 /* Next block in freelist */
    } free;
    union {
      long double align;	 /* Give appropriate alignment */
      char data[1];
    } large;
  } var;
}
heap_block;

#define vSmall var.small
#define vLarge var.large
#define vFree  var.free

typedef struct heap_data heap_data;

typedef void (*allocating_hook_t) (heap_data *, heap_block *, size_t);
typedef heap_data *(*nomemory_hook_t) (heap_data *, size_t);

struct heap_data
{
  heap_block *freelist[NUM_FREELISTS];
  int mmap_count;
  size_t heap_total, heap_allocation_size, heap_limit;
  int probes, failures, splits, matches;

  allocating_hook_t after_allocating, before_prim_freeing, after_prim_allocating;
  nomemory_hook_t nomemory;
};


/* Allocate a chunk of N bytes from the independent heap H.  Invoke
   the out-of-memory hook if the heap's limit is reached, and return
   NULL if memory cannot be allocated even after the hook returned.  */
extern PTR _gst_mem_alloc (heap_data *h, size_t n)
  ATTRIBUTE_HIDDEN;

/* Free the memory chunk pointed to by P, which was allocated from the
   independent heap H.  */
extern void _gst_mem_free (heap_data *h, PTR p)
  ATTRIBUTE_HIDDEN;

/* Resize the memory chunk pointed to by P, which was allocated from the
   independent heap H, so that its size becomes N.  Return the new
   pointer.  Invoke the out-of-memory hook if the heap's limit is reached,
   and return NULL if memory cannot be allocated even after the hook
   returned.  */
extern PTR _gst_mem_realloc (heap_data *h, PTR p, size_t n)
  ATTRIBUTE_HIDDEN;

/* Allocate a new, independent heap which allocates from the OS chunks
   of HEAP_ALLOCATION_SIZE bytes, up to a limit of HEAP_LIMIT bytes.  */
extern heap_data *_gst_mem_new_heap (size_t heap_allocation_size,
				     size_t heap_limit)
  ATTRIBUTE_HIDDEN;

/* Allocate a chunk of N bytes using malloc.  Exit if this amount of
   memory cannot be allocated.  */
extern PTR xmalloc (size_t n)
  ATTRIBUTE_HIDDEN;

/* Allocate a chunk of S*N bytes using malloc, clear it and return a pointer
   to its base.  Exit if memory cannot be allocated.  */
extern PTR xcalloc (size_t n, size_t s)
  ATTRIBUTE_HIDDEN;

/* Resize the memory chunk pointed to by P, which was allocated using
   malloc, so that its size becomes N.  Return the new pointer, or exit
   if the memory cannot be allocated.  */
extern PTR xrealloc (PTR p, size_t n)
  ATTRIBUTE_HIDDEN;

/* Allocate memory for a copy of the null-terminated string S using malloc,
   duplicate the contents of S, and return the pointer to the copy.  Exit
   if the memory cannot be allocated.  */
extern char *xstrdup (const char *s)
  ATTRIBUTE_HIDDEN;

/* Free the chunk pointed to by P, which was allocated using malloc.  */
extern void xfree (PTR p)
  ATTRIBUTE_HIDDEN;

/* Print an error message, and exit if FATAL is non-zero.  */
extern void nomemory (int fatal)
  ATTRIBUTE_HIDDEN;

#define obstack_chunk_alloc xmalloc
#define obstack_chunk_free xfree

#endif
