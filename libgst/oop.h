/******************************** -*- C -*- ****************************
 *
 *	Object Table declarations.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007,2008,2009
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



#ifndef GST_OOP_H
#define GST_OOP_H

/* Define this flag to disable blacking of grey pages (that is, the
   entire oldspace is scanned to look for reachable newspace objects).
   This is also necessary to run valgrind on GNU Smalltalk.  */
/* #define NO_SIGSEGV_HANDLING */

/* ... but always define it if libsigsegv does not support this platform.  */
#if !defined HAVE_SIGSEGV_RECOVERY || !(HAVE_SIGSEGV_RECOVERY-0)
#define NO_SIGSEGV_HANDLING
#endif

#define NUM_CHAR_OBJECTS	256
#define NUM_BUILTIN_OBJECTS	3
#define FIRST_OOP_INDEX		(-NUM_CHAR_OBJECTS-NUM_BUILTIN_OBJECTS)
#define CHAR_OBJECT_BASE	FIRST_OOP_INDEX
#define BUILTIN_OBJECT_BASE	(-NUM_BUILTIN_OBJECTS)

/* The number of OOPs in the system.  This is exclusive of Character,
   True, False, and UndefinedObject (nil) oops, which are
   built-ins.  */
#define INITIAL_OOP_TABLE_SIZE	(1024 * 128 + BUILTIN_OBJECT_BASE)
#define MAX_OOP_TABLE_SIZE	(sizeof(struct oop_s) << 20)

/* The number of free OOPs under which we trigger GCs.  0 is not
   enough because _gst_scavenge might still need some oops in
   empty_context_stack!!! */
#define LOW_WATER_OOP_THRESHOLD	(1024 * 2)

#define SMALLTALK_OOP_INDEX	0
#define PROCESSOR_OOP_INDEX	1
#define SYM_TABLE_OOP_INDEX	2
#define NIL_OOP_INDEX		(BUILTIN_OBJECT_BASE + 0)
#define TRUE_OOP_INDEX		(BUILTIN_OBJECT_BASE + 1)
#define FALSE_OOP_INDEX		(BUILTIN_OBJECT_BASE + 2)

/* Given a number of bytes "x", return the number of 32 bit words
   needed to represent that object, rounded up to the nearest 32 bit
   word boundary.  */
#define ROUNDED_WORDS(x) \
  (((x) + sizeof(long) - 1) / sizeof(long))

/* Given a number of bytes "x", round it up to the next multiple of
   sizeof (long).  */
#define ROUNDED_BYTES(x) \
  (((x) + sizeof(long) - 1) & ~(sizeof(long) - 1))

struct gst_character
{
  OBJ_HEADER;
  OOP charVal;
};

struct gst_undefined_object
{
  OBJ_HEADER;
};

struct gst_boolean
{
  OBJ_HEADER;
  OOP booleanValue;
};

typedef struct gst_object_memory
{
  OBJ_HEADER;
  OOP bytesPerOOP, bytesPerOTE,
      edenSize, survSpaceSize, oldSpaceSize, fixedSpaceSize,
      edenUsedBytes, survSpaceUsedBytes, oldSpaceUsedBytes,
      fixedSpaceUsedBytes, rememberedTableEntries,
      numScavenges, numGlobalGCs, numCompactions, numGrowths,
      numOldOOPs, numFixedOOPs, numWeakOOPs, numOTEs, numFreeOTEs,
      timeBetweenScavenges, timeBetweenGlobalGCs, timeBetweenGrowths,
      timeToScavenge, timeToCollect, timeToCompact,
      reclaimedBytesPerScavenge, tenuredBytesPerScavenge,
      reclaimedBytesPerGlobalGC, reclaimedPercentPerScavenge,
      allocFailures, allocMatches, allocSplits, allocProbes;
} *gst_object_memory;

typedef unsigned long inc_ptr;

/* Garbage collector data structures */

typedef struct page_tree
{
  rb_node_t rb;
  OOP *base;
}
page_tree;

typedef struct weak_area_tree
{
  rb_node_t rb;
  OOP oop;			/* Weak OOP */
}
weak_area_tree;

typedef struct new_space {
  OOP *minPtr;			/* points to lowest addr in heap */
  OOP *maxPtr;			/* points to highest addr in heap */
  OOP *allocPtr;		/* new space ptr, starts low, goes up */
  unsigned long totalSize;	/* allocated size */
} new_space;

typedef struct surv_space {
  OOP *tenurePtr;		/* points to oldest object */
  OOP *allocPtr;		/* points to past newest object */
  OOP *minPtr;			/* points to lowest addr in heap */
  OOP *maxPtr;			/* points to highest addr in heap */
  OOP *topPtr;			/* points to highest used addr in heap */
  int  allocated;  		/* bytes allocated in the last scavenge */
  int  filled;  		/* bytes currently used */
  int  totalSize;               /* allocated size */
} surv_space;

typedef struct grey_area_node {
  struct grey_area_node *next;
  OOP *base;
  int n;
  OOP oop;
} grey_area_node;

typedef struct grey_area_list {
  grey_area_node *head, *tail;
} grey_area_list;

typedef struct cheney_scan_state {
  OOP *queue_at;		/* Next scanned object in queue */
  OOP *at;			/* Base of currently scanned object */
  OOP current;			/* Currently scanned object */
} cheney_scan_state;

struct mark_queue
{
  OOP *firstOOP, *endOOP;
};

struct memory_space
{
  heap_data *old, *fixed;
  struct new_space eden;
  struct surv_space surv[2], tenuring_queue;

  struct mark_queue *markQueue, *lastMarkQueue;

  /* The current state of the copying collector's scan phase.  */
  struct cheney_scan_state scan;

  /* The object table.  This contains a pointer to the object, and some flag
     bits indicating whether the object is read-only, reachable and/or pooled.
     Some of the bits indicate the difference between the allocated length
     (stored in the object itself), and the real length, because variable
     byte objects may not be an even multiple of sizeof(PTR).  */
  struct oop_s *ot, *ot_base;

  /* The number of OOPs in the free list and in the full OOP
     table.  num_free_oops is only correct after a GC!  */
  int num_free_oops, ot_size;

  /* The root set of the scavenger.  This includes pages in oldspace that
     were written to, and objects that had to be tenured before they were
     scanned.  */
  grey_area_list grey_pages, grey_areas;
  int rememberedTableEntries;

  /* A list of areas used by weak objects.  */
  weak_area_tree *weak_areas; 

  /* These are the pointer to the first allocated OOP since the last
     completed incremental GC pass, to the last low OOP considered by
     the incremental sweeper, to the first high OOP not considered by
     the incremental sweeper.  */
  OOP last_allocated_oop, last_swept_oop, next_oop_to_sweep;

  /* The active survivor space */
  struct surv_space *active_half;

  /* The beginning and end of the area mmap-ed directly from the image.  */
  OOP *loaded_base, *loaded_end;

  /* The OOP flag corresponding to the active survivor space */
  int active_flag;

  /* The OOP flag corresponding to the inactive survivor space.  */
  int live_flags;

  /* These hold onto the object incubator's state */
  OOP *inc_base, *inc_ptr, *inc_end;

  /* Objects that are at least this big (in bytes) are allocated outside
     the main heap, hoping to provide more locality of reference between
     small objects.  */
  size_t big_object_threshold;

  /* If there is this much space used after a oldspace collection, we need to
     grow the object heap by _gst_space_grow_rate % next time we
     do a collection, so that the storage gets copied into the new, larger
     area.  */
  int grow_threshold_percent;

  /* Grow the object heap by this percentage when the amount of space
     used exceeds _gst_grow_threshold_percent.  */
  int space_grow_rate;

  /* Some statistics are computed using exponential smoothing.  The smoothing
     factor is stored here.  */
  double factor;

  /* Here are the stats.  */
  int numScavenges, numGlobalGCs, numCompactions, numGrowths;
  int numOldOOPs, numFixedOOPs, numWeakOOPs;

  double timeBetweenScavenges, timeBetweenGlobalGCs, timeBetweenGrowths;
  double timeToScavenge, timeToCollect, timeToCompact;
  double reclaimedBytesPerScavenge,
	 tenuredBytesPerScavenge, reclaimedBytesPerGlobalGC,
         reclaimedPercentPerScavenge;
};

/* This is true to show a message whenever a GC happens.  */
extern int _gst_gc_message 
  ATTRIBUTE_HIDDEN;

/* This is true in the middle of a GC.  */
extern int _gst_gc_running 
  ATTRIBUTE_HIDDEN;

/* Finds and returns an instance of the class CLASS_OOP.  Returns "nil"
   if there are no instances present.  */
extern OOP _gst_find_an_instance (OOP class_oop)
  ATTRIBUTE_PURE 
  ATTRIBUTE_HIDDEN;

/* Execute a two-way become operation between OOP1 and OOP2.  */
extern void _gst_swap_objects (OOP oop1,
			       OOP oop2) 
  ATTRIBUTE_HIDDEN;

/* Flip the two survivor spaces.  Starting from the root set, move eden
   objects to survivor space, tenuring objects when the top of the space
   is hit.  Then tell the incremental sweeper not to sweep old objects.  */
extern void _gst_scavenge (void) 
  ATTRIBUTE_HIDDEN;

/* Mark the old objects.  Starting from the root set,
   recursively mark objects as reachable, and tell the incremental
   sweeper to sweep unreachable objects.  Decide whether the heap should
   be compacted or even grown, so that allocating NEXT_ALLOCATION bytes
   leaves it empty enough.  */
extern void _gst_global_gc (int next_allocation) 
  ATTRIBUTE_HIDDEN;

/* Mark, sweep & compact the old objects.  */
extern void _gst_global_compact (void) 
  ATTRIBUTE_HIDDEN;

/* Sweep a bunch of old objects, return whether there are more.  */
extern mst_Boolean _gst_incremental_gc_step (void) 
  ATTRIBUTE_HIDDEN;

/* The incremental collector has done its job.  Update statistics,
   and if it was also sweeping old objects, make it consider all
   objects as alive.  */
extern void _gst_finished_incremental_gc (void) 
  ATTRIBUTE_HIDDEN;

/* Finish the incremental sweep phase of the GC.  */
extern void _gst_finish_incremental_gc (void) 
  ATTRIBUTE_HIDDEN;

/* Move all the object in survivor space to old space.  */
extern void _gst_tenure_all_survivors () 
  ATTRIBUTE_HIDDEN;

/* Initialize the memory allocator.  The memory space is allocated,
   and the various garbage collection flags are set to their initial
   values.  */
extern void _gst_init_mem_default () 
  ATTRIBUTE_HIDDEN;

/* Initialize the memory allocator.  The memory space is allocated,
   and the various garbage collection flags are set to the given
   values.  */
extern void _gst_init_mem (size_t eden, size_t survivor, size_t old,
	                   size_t big_threshold, int grow_threshold_percent,
           	           int space_grow_rate) 
  ATTRIBUTE_HIDDEN;

/* Initialize an OOP table of SIZE bytes, trying at the given address if
   possible.  Initially, all the OOPs are on the free list so that's
   just how we initialize them.  We do as much initialization as we can,
   but we're called before classses are defined, so things that have
   definite classes must wait until the classes are defined.  */
extern void _gst_init_oop_table (PTR address, size_t size) 
  ATTRIBUTE_HIDDEN;

/* Dump the entire contents of the OOP table.  Mainly for debugging
   purposes.  */
extern void _gst_dump_oop_table () 
  ATTRIBUTE_HIDDEN;

/* The almost-depth-first copying collector.  If survivor space is
   full, tenuring of the oldest object is invoked (in a circular fashion).

   This function does not copy children of weak objects, for obvious
   reasons.  */
extern void _gst_copy_an_oop (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Mark the objects pointed to by the list of pointers to OOPs at CUROOP
   (included) and finishing at ATENDOOP (excluded).  */
extern void _gst_mark_oop_range (OOP * curOOP,
			         OOP * atEndOOP) 
  ATTRIBUTE_HIDDEN;

/* Copy the objects pointed to by the list of pointers to OOPs at CUROOP
   (included) and finishing at ATENDOOP (excluded).  */
extern void _gst_copy_oop_range (OOP * curOOP,
			         OOP * atEndOOP) 
  ATTRIBUTE_HIDDEN;

/* Grey the pointers pointed to by the list of pointers to OOPs at FROM
   (included) and for SIZE bytes.  */
extern void _gst_grey_oop_range (PTR from,
			         size_t size) 
  ATTRIBUTE_HIDDEN;

/* Mark OOP and the pointers pointed by that.  */
extern void _gst_mark_an_oop_internal (OOP oop)
  ATTRIBUTE_HIDDEN;

/* Fully initialize the builtin objects, possible after the respective
   classes have been created.  */
extern void _gst_init_builtin_objects_classes (void) 
  ATTRIBUTE_HIDDEN;

/* Create the registry of incubated objects.  */
extern void _gst_inc_init_registry (void) 
  ATTRIBUTE_HIDDEN;

/* Grow the registry of incubated objects when it is full.  */
extern void _gst_inc_grow_registry (void) 
  ATTRIBUTE_HIDDEN;

/* Allocate and return space for an object of SIZE bytes.  This
   basically means moving the allocation pointer for the current space
   up by SIZE bytes, and, if there isn't enough space left, flipping
   the garbage collector after memory is compacted.  The space is
   merely allocated; it is not initialized. 

   The pointer to the object data is returned, the OOP is
   stored in P_OOP.  */
extern gst_object _gst_alloc_obj (size_t size,
				  OOP *p_oop) 
  ATTRIBUTE_HIDDEN;

/* Allocate and return space for an object of SIZE words, without
   creating an OOP.  This is a special operation that is only needed
   at bootstrap time, so it does not care about garbage collection.  */
extern gst_object _gst_alloc_words (size_t size) 
  ATTRIBUTE_HIDDEN;

/* Grows the allocated memory to SPACESIZE bytes, if it's not there
   already.  
   the memory could not be allocated.  Should be called after the
   sweep has occurred so that things are contiguous.  Ensures that the
   OOP table pointers are fixed up to point to the new objects.  */
extern void _gst_grow_memory_to (size_t size) 
  ATTRIBUTE_HIDDEN;

/* Grow the OOP table to NEWSIZE pointers and initialize the newly
   created pointers.  */
extern mst_Boolean _gst_realloc_oop_table (size_t newSize) 
  ATTRIBUTE_HIDDEN;

/* Move OOP to oldspace.  */
extern void _gst_tenure_oop (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Move OOP to fixedspace.  */
extern void _gst_make_oop_fixed (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Make OOP a weak object.  */
extern void _gst_make_oop_weak (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Make OOP a non-weak object.  */
extern void _gst_make_oop_non_weak (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Clear the OOP data related to OOP */
extern void _gst_sweep_oop (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Set the fields of the given ObjectMemory object */
extern void _gst_update_object_memory_oop (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* This variable represents information about the memory space.  _gst_mem
   holds the required information: basically the pointer to the base and
   top of the space, and the pointers into it for allocation and copying.  */
extern struct memory_space _gst_mem 
  ATTRIBUTE_HIDDEN;

#endif /* GST_OOP_H */
