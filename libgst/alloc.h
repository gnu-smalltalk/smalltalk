/******************************** -*- C -*- ****************************
 *
 *	Memory allocation for Smalltalk
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2004 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 ***********************************************************************/

#ifndef GST_ALLOC_H
#define GST_ALLOC_H

#define NUM_FREELISTS 47

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
typedef void (*nomemory_hook_t) (heap_data *, size_t);

struct heap_data
{
  heap_block *freelist[NUM_FREELISTS];
  int mmap_count;
  size_t heap_total, heap_allocation_size, heap_limit;
  int probes, failures, splits, matches;

  allocating_hook_t after_allocating, before_prim_freeing, after_prim_allocating;
  nomemory_hook_t nomemory;
};


PTR _gst_mem_alloc (heap_data *h, size_t);
void _gst_mem_free (heap_data *h, PTR);
PTR _gst_mem_realloc (heap_data *h, PTR, size_t);
heap_data *_gst_mem_new_heap (size_t heap_allocation_size, size_t heap_limit);

PTR xmalloc (register size_t n);
PTR xcalloc (register size_t n, register size_t s);
PTR xrealloc (register PTR p, register size_t n);
char *xstrdup (const char *s);
void xfree (register PTR p);
void nomemory (int fatal);

#define obstack_chunk_alloc xmalloc
#define obstack_chunk_free xfree

#endif
