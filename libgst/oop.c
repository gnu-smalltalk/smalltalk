/******************************** -*- C -*- ****************************
 *
 *	Object Table maintenance module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003
 * Free Software Foundation, Inc.
 * Written by Steve Byrne and Paolo Bonzini.
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

#ifdef HAVE_SIGSEGV_H
#include "sigsegv.h"
#endif

#define	K		1024
#define INIT_NUM_INCUBATOR_OOPS   50
#define INCUBATOR_CHUNK_SIZE	  20

/* The number of OOPs that are swept on each incremental GC step.  */
#define INCREMENTAL_SWEEP_STEP	  100

/* Define this flag to turn on debugging code for OOP table management */
/* #define GC_DEBUGGING */

/* Define this flag to disable incremental garbage collection */
/* #define NO_INCREMENTAL_GC */

/* Define this flag to disable blacking of grey pages (that is, the
   entire oldspace is scanned to look for reachable newspace objects).
   This is also necessary to run valgrind on GNU Smalltalk. */
/* #define NO_SIGSEGV_HANDLING */

/* Define this flag to turn on debugging code for oldspace management */
/* #define MMAN_DEBUGGING */

#if !defined HAVE_SIGSEGV_RECOVERY || !(HAVE_SIGSEGV_RECOVERY-0)
#define NO_SIGSEGV_HANDLING
#endif

#if defined(GC_DEBUGGING)
#undef OPTIMIZE
#endif




/* These are the memory areas within which we mantain object data. */
heap _gst_oop_heap;

/* These are the real OOPS for nil, true, and false */
OOP _gst_nil_oop, _gst_true_oop, _gst_false_oop;

/* This is true to show a message whenever a GC happens. */
mst_Boolean _gst_gc_message = true;

/* This is != 0 in the middle of a GC. */
int _gst_gc_running = 0;

/* This vector holds the storage for all the Character objects in the
   system.  Since all character objects are unique, we pre-allocate
   space for 256 of them, and treat them as special built-ins when
   doing garbage collection.*/
static struct gst_character _gst_char_object_table[NUM_CHAR_OBJECTS];

/* This is "nil" object in the system.  That is, the single instance
   of the UndefinedObject class, which is called "nil". */
static struct gst_undefined_object _gst_nil_object;

/* These represent the two boolean objects in the system, true and
   false.  This is the object storage for those two objects.  
   false == &_gst_boolean_objects[0],
   true == &_gst_boolean_objects[1] */
static struct gst_boolean _gst_boolean_objects[2];

/* This variable represents information about the memory space.
   _gst_mem holds the required information: basically the
   pointer to the base and top of the space, and the pointers into it
   for allocation and copying. */
struct memory_space _gst_mem;

/* Data to compute the statistics in _gst_mem.  */
struct statistical_data
{
  int reclaimedOldSpaceBytesSinceLastGlobalGC;
  unsigned long timeOfLastScavenge, timeOfLastGlobalGC, timeOfLastGrowth,
    timeOfLastCompaction;
} stats;



/* Allocates a table for OOPs of SIZE bytes, and store pointers to the
   builtin OOPs into _gst_nil_oop et al. */
static void alloc_oop_table (size_t);

/* Free N slots from the beginning of the queue Q and return a pointer
   to their base.  */
static OOP *queue_get (surv_space *q, int n);

/* Allocate N slots at the end of the queue Q and return a pointer
   to their base.  */
static OOP *queue_put (surv_space *q, OOP *src, int n);

/* Move an object from survivor space to oldspace. */
static void tenure_one_object ();

/* Initialize an allocation heap with the oldspace hooks set.  */
static heap_data *init_old_space (size_t size);

/* Initialize a surv_space structure.  */
static void init_survivor_space (struct surv_space *space, size_t size);

/* Reset a surv_space structure (same as init, but without allocating 
   memory.  */
static void reset_survivor_space (struct surv_space *space);

/* Restart the incremental collector.  Objects before FIRSTOOP
   are assumed to be alive (currently the base of the OOP table is
   always passed, but you never know).  */
static void reset_incremental_gc (OOP firstOOP);

/* The incremental collector has done its job.  Update statistics,
   and if it was also sweeping old objects, make it consider all
   objects as alive.  */
static void finished_incremental_gc ();

/* Gather statistics.  */
static void update_stats (unsigned long *last, double *between, double *duration);

/* The copying collector. */
static inline void copy_oops (void);

/* Grey ranges are generated in two cases.  The standard one is when we
   write to oldspace; another one is when we copy objects to the destination
   semispace faster than the scanner can go past them.  When this happens,
   tenure_one_object puts the object onto a special list of old objects
   that are to be scanned.  What this function does is to consume this last
   list.  (It also completes the special treatment of ephemeron objects).  */
static void scan_grey_objects ();

/* The treatment of grey pages is different from grey objects.  Since some
   new objects might not be tenured, grey pages might still hold some
   pointers to new objects.  For this reason, and to avoid the cost of
   delivering two signals, a grey page is *not* removed from the tree
   until no new object is found in it.  */
static void scan_grey_pages ();

/* Greys a page worth of pointers starting at BASE.  */
static void add_to_grey_list (OOP *base, int n);

/* Greys the object OOP.  */
static void add_grey_object (OOP oop);
 
/* Do the breadth-first scanning of copied objects.  */
static void cheney_scan (void);

/* Hook that allows pages to be created grey.  */
static void oldspace_after_allocating (heap_data *h, heap_block *blk, size_t sz);

/* Hook that discards freed pages from the remembered table.  */
static void oldspace_before_freeing (heap_data *h, heap_block *blk, size_t sz);

#ifndef NO_SIGSEGV_HANDLING
/* The a global SIGSEGV handler.  */
static int oldspace_sigsegv_handler (void* fault_address, int serious);
#endif

/* Hook that triggers garbage collection. */
static void oldspace_nomemory (heap_data *h, size_t sz);

/* Answer the number of fields to be scanned in the object starting
   at OBJ, with the given FLAGS on its OOP.  */
static int scanned_fields_in (mst_Object obj, int flags) ATTRIBUTE_PURE;

/* The mark phase of oldspace GC. */
static inline void mark_oops (void);

/* Performs special checks on weak and ephemeron objects.  When one
   of the objects pointed to by a weak object have no other
   references, the slot of the weak object is replaced by a zero and
   the #mourn message is sent to it.  Ephemerons' keys are checked for
   reachability after non-ephemerons are marked, and if no objects outside
   the ephemeron refer to it, the ephemeron is sent #mourn as well.  */
static inline void mourn_objects (void);

/* Mark the ephemeron objects.  This is done after other objects
   are marked.  */
static inline void mark_ephemeron_oops (void);

/* Walks the instance variables of weak objects and zeroes out those that are
   not surviving the garbage collection.  Called by preare_for_sweep.  */
static inline void check_weak_refs ();


void
init_survivor_space (struct surv_space *space, size_t size)
{
  space->totalSize = size;
  space->minPtr = (OOP *) xmalloc (size);
  space->maxPtr = (OOP *) ((char *)space->minPtr + size);

  reset_survivor_space (space);
}

heap_data *
init_old_space (size_t size)
{
  heap_data *h = _gst_mem_new_heap (0, size);
  h->after_prim_allocating = oldspace_after_allocating;
  h->before_prim_freeing = oldspace_before_freeing;
  h->nomemory = oldspace_nomemory;

  return h;
}

void
_gst_init_mem_default ()
{
  _gst_init_mem (0, 0, 0, 0, 0, 0);
}

void
_gst_init_mem (size_t eden, size_t survivor, size_t old,
	       size_t big_object_threshold, int grow_threshold_percent,
	       int space_grow_rate)
{
  if (!_gst_mem.old)
    {
#ifndef NO_SIGSEGV_HANDLING
      sigsegv_install_handler (oldspace_sigsegv_handler);
#endif
      if (!eden)
        eden = 300 * K;
      if (!survivor)
        survivor = 60 * K;
      if (!old)
        old = 4 * K * K;
      if (!big_object_threshold)
        big_object_threshold = 4 * K;
      if (!grow_threshold_percent)
        grow_threshold_percent = 80;
      if (!space_grow_rate)
        space_grow_rate = 30;
    }
  else
    {
      if (eden || survivor)
        _gst_scavenge ();

      if (survivor)
        _gst_tenure_all_survivors ();

      if (old && old != _gst_mem.old->heap_total)
        _gst_grow_memory_to (old);
    }

  if (eden)
    {
      _gst_mem.eden.totalSize = eden;
      _gst_mem.eden.minPtr = (OOP *) xmalloc (eden);
      _gst_mem.eden.allocPtr = _gst_mem.eden.minPtr;
      _gst_mem.eden.maxPtr = (OOP *)
        ((char *)_gst_mem.eden.minPtr + eden);
    }

  if (survivor)
    {
      init_survivor_space (&_gst_mem.surv[0], survivor);
      init_survivor_space (&_gst_mem.surv[1], survivor);
      init_survivor_space (&_gst_mem.tenuring_queue,
		           survivor / OBJ_HEADER_SIZE_WORDS);
    }

  if (big_object_threshold)
    _gst_mem.big_object_threshold = big_object_threshold;

  if (_gst_mem.eden.totalSize < _gst_mem.big_object_threshold)
    _gst_mem.big_object_threshold = _gst_mem.eden.totalSize;

  if (grow_threshold_percent)
    _gst_mem.grow_threshold_percent = grow_threshold_percent;

  if (space_grow_rate)
    _gst_mem.space_grow_rate = space_grow_rate;

  if (!_gst_mem.old)
    {
      if (old)
        {
          _gst_mem.old = init_old_space (old);
          _gst_mem.fixed = init_old_space (old);
        }

      _gst_mem.active_half = &_gst_mem.surv[0];
      _gst_mem.active_flag = F_EVEN;
      _gst_mem.live_flags = F_EVEN | F_OLD;

      stats.timeOfLastScavenge = stats.timeOfLastGlobalGC =
        stats.timeOfLastGrowth = stats.timeOfLastCompaction =
        _gst_get_milli_time ();

      _gst_mem.factor = 0.4;

      _gst_inc_init_registry ();
    }

}

void _gst_update_object_memory_oop (OOP oop)
{
  int numScavenges;
  gst_object_memory data;

  /* Ensure the statistics are coherent.  */
  for (;;) {
    numScavenges = _gst_mem.numScavenges;
    data = (gst_object_memory) OOP_TO_OBJ (oop);
    data->bytesPerOOP = FROM_INT (SIZEOF_CHAR_P);
    data->bytesPerOTE = FROM_INT (sizeof (struct OOP) +
				  sizeof (gst_object_header));

    data->edenSize = FROM_INT (_gst_mem.eden.totalSize);
    data->survSpaceSize = FROM_INT (_gst_mem.active_half->totalSize);
    data->oldSpaceSize = FROM_INT (_gst_mem.old->heap_limit);
    data->fixedSpaceSize = FROM_INT (_gst_mem.fixed->heap_limit);
    data->edenUsedBytes = FROM_INT ((char *)_gst_mem.eden.allocPtr -
				    (char *)_gst_mem.eden.minPtr);
    data->survSpaceUsedBytes = FROM_INT (_gst_mem.active_half->filled);
    data->oldSpaceUsedBytes = FROM_INT (_gst_mem.old->heap_total);
    data->fixedSpaceUsedBytes = FROM_INT (_gst_mem.fixed->heap_total);
    data->rememberedTableEntries = FROM_INT (_gst_mem.rememberedTableEntries);
    data->numScavenges = FROM_INT (_gst_mem.numScavenges);
    data->numGlobalGCs = FROM_INT (_gst_mem.numGlobalGCs);
    data->numCompactions = FROM_INT (_gst_mem.numCompactions);
    data->numGrowths = FROM_INT (_gst_mem.numGrowths);
    data->numOldOOPs = FROM_INT (_gst_mem.numOldOOPs);
    data->numFixedOOPs = FROM_INT (_gst_mem.numFixedOOPs);
    data->numWeakOOPs = FROM_INT (_gst_mem.numWeakOOPs);
    data->numOTEs = FROM_INT (_gst_mem.ot_size);
    data->numFreeOTEs = FROM_INT (_gst_mem.num_free_oops);
    data->allocFailures = FROM_INT (_gst_mem.old->failures + _gst_mem.fixed->failures);
    data->allocMatches = FROM_INT (_gst_mem.old->matches + _gst_mem.fixed->matches);
    data->allocSplits = FROM_INT (_gst_mem.old->splits + _gst_mem.fixed->splits);
    data->allocProbes = FROM_INT (_gst_mem.old->probes + _gst_mem.fixed->probes);

    /* Every allocation of a FloatD might cause a garbage
       collection! */
#define SET_FIELD(x) \
	data->x = floatd_new (_gst_mem.x); \
	if (data != (gst_object_memory) OOP_TO_OBJ (oop)) continue;

    SET_FIELD (timeBetweenScavenges);
    SET_FIELD (timeBetweenGlobalGCs);
    SET_FIELD (timeBetweenGrowths);
    SET_FIELD (timeToScavenge);
    SET_FIELD (timeToCollect);
    SET_FIELD (timeToCompact);
    SET_FIELD (reclaimedBytesPerScavenge);
    SET_FIELD (tenuredBytesPerScavenge);
    SET_FIELD (reclaimedBytesPerGlobalGC);
    SET_FIELD (reclaimedPercentPerScavenge);

#undef SET_FIELD

    break;
  }
}

void
_gst_init_oop_table (size_t size)
{
  int i;

  _gst_oop_heap = NULL;
  for (i = MAX_OOP_TABLE_SIZE; i && !_gst_oop_heap; i >>= 1)
    _gst_oop_heap = _gst_heap_create (i * sizeof (struct OOP));

  if (!_gst_oop_heap)
    nomemory (true);

  alloc_oop_table (size);

  _gst_nil_oop->flags = F_READONLY | F_OLD | F_REACHABLE;
  _gst_nil_oop->object = (mst_Object) & _gst_nil_object;
  _gst_nil_object.objSize =
    FROM_INT (ROUNDED_WORDS (sizeof (struct gst_undefined_object)));

  _gst_true_oop->flags = F_READONLY | F_OLD | F_REACHABLE;
  _gst_true_oop->object = (mst_Object) & _gst_boolean_objects[0];
  _gst_false_oop->flags = F_READONLY | F_OLD | F_REACHABLE;
  _gst_false_oop->object = (mst_Object) & _gst_boolean_objects[1];
  _gst_boolean_objects[0].objSize =
    FROM_INT (ROUNDED_WORDS (sizeof (struct gst_boolean)));
  _gst_boolean_objects[1].objSize =
    FROM_INT (ROUNDED_WORDS (sizeof (struct gst_boolean)));
  _gst_boolean_objects[0].booleanValue = _gst_true_oop;
  _gst_boolean_objects[1].booleanValue = _gst_false_oop;

  for (i = 0; i < NUM_CHAR_OBJECTS; i++)
    {
      _gst_char_object_table[i].objSize =
	FROM_INT (ROUNDED_WORDS (sizeof (struct gst_character)));
      _gst_char_object_table[i].charVal = (char) i;
      _gst_mem.ot[i + CHAR_OBJECT_BASE].object =
	(mst_Object) & _gst_char_object_table[i];
      _gst_mem.ot[i + CHAR_OBJECT_BASE].flags =
	F_READONLY | F_OLD | F_REACHABLE;
    }
}


void
alloc_oop_table (size_t size)
{
  long bytes;
  OOP oop;

  _gst_mem.ot_size = size;
  bytes = (size - FIRST_OOP_INDEX) * sizeof (struct OOP);
  _gst_mem.ot_base =
    (struct OOP *) _gst_heap_sbrk (_gst_oop_heap, bytes);
  if (!_gst_mem.ot_base)
    nomemory (true);

  _gst_mem.ot = &_gst_mem.ot_base[-FIRST_OOP_INDEX];
  _gst_nil_oop = &_gst_mem.ot[nilOOPIndex];
  _gst_true_oop = &_gst_mem.ot[trueOOPIndex];
  _gst_false_oop = &_gst_mem.ot[falseOOPIndex];

  _gst_mem.num_free_oops = size;

  /* mark the OOPs as available */
  for (oop = _gst_mem.ot;
       oop < &_gst_mem.ot[_gst_mem.ot_size]; oop++)
    oop->flags = F_FREE;

  _gst_mem.first_allocated_oop = _gst_mem.ot;
  _gst_mem.last_allocated_oop = _gst_mem.last_swept_oop = _gst_mem.ot - 1;
  _gst_mem.highest_swept_oop = _gst_mem.ot;
}

mst_Boolean
_gst_realloc_oop_table (size_t newSize)
{
  long bytes;
  OOP oop;

  bytes = (newSize - _gst_mem.ot_size) * sizeof (struct OOP);
  if (bytes < 0)
    return (true);

  if (!_gst_heap_sbrk (_gst_oop_heap, bytes))
    {
      /* try to recover.  Note that we cannot move the OOP table like
         we do with the object data. */
      nomemory (false);
      return (false);
    }

  /* mark the new OOPs as available */
  for (oop = &_gst_mem.ot[_gst_mem.ot_size];
       oop < &_gst_mem.ot[newSize]; oop++)
    oop->flags = F_FREE;

  _gst_mem.num_free_oops += newSize - _gst_mem.ot_size;
  _gst_mem.ot_size = newSize;
  return (true);
}

void
_gst_dump_oop_table()
{
  OOP oop;

  for (oop = _gst_mem.ot; oop <= _gst_mem.last_allocated_oop; oop++)
    if (!IS_OOP_FREE (oop))
      {
        if (IS_OOP_VALID (oop))
          _gst_display_oop (oop);
        else
          _gst_display_oop_short (oop);
      }
}


void
_gst_init_builtin_objects_classes (void)
{
  int i;

  _gst_nil_object.objClass = _gst_undefined_object_class;
  _gst_boolean_objects[0].objClass = _gst_true_class;
  _gst_boolean_objects[1].objClass = _gst_false_class;

  for (i = 0; i < NUM_CHAR_OBJECTS; i++)
    _gst_char_object_table[i].objClass = _gst_char_class;
}


OOP
_gst_find_an_instance (OOP class_oop)
{
  OOP oop;

  for (oop = _gst_mem.ot;
       oop <= _gst_mem.last_allocated_oop; oop++)
    {
      if (IS_OOP_VALID (oop) && (OOP_CLASS (oop) == class_oop))
	return (oop);
    }

  return (_gst_nil_oop);
}


void
_gst_make_oop_non_weak (OOP oop)
{
  weak_area_tree *entry = _gst_mem.weak_areas;

  oop->flags &= ~F_WEAK;
  _gst_mem.numWeakOOPs--;
  while (entry)
    {
      if (entry->oop == oop)
        {
          rb_erase (&entry->rb, (rb_node_t **) &_gst_mem.weak_areas);
          xfree (entry);
          break;
        }

      entry = (weak_area_tree *)
        (oop < entry->oop ? entry->rb.rb_left : entry->rb.rb_right);
    }
}

void
_gst_make_oop_weak (OOP oop)
{
  weak_area_tree *entry;
  weak_area_tree *node = NULL;
  rb_node_t **p = (rb_node_t **) &_gst_mem.weak_areas;

  /* Weak OOPs must be fixed.  */
  _gst_make_oop_fixed (oop);
  oop->flags |= F_WEAK;
  _gst_mem.numWeakOOPs++;

  while (*p)
    {
      node = (weak_area_tree *) *p;

      if (oop < node->oop)
        p = &(*p)->rb_left;
      else if (oop > node->oop)
        p = &(*p)->rb_right;
      else
        {
	  node->base = (OOP *) oop->object;
	  node->end = (OOP *) oop->object + TO_INT (oop->object->objSize);
	  return;
	}
    }

  entry = (weak_area_tree *) xmalloc (sizeof (weak_area_tree));
  entry->base = (OOP *) oop->object;
  entry->end = (OOP *) oop->object + TO_INT (oop->object->objSize);
  entry->oop = oop;
  entry->rb.rb_parent = &node->rb;
  entry->rb.rb_left = entry->rb.rb_right = NULL;
  *p = &(entry->rb);

  rb_rebalance (&entry->rb, (rb_node_t **) &_gst_mem.weak_areas);
}

void
_gst_swap_objects (OOP oop1,
		   OOP oop2)
{
  struct OOP tempOOP;

  if (oop2->flags & F_WEAK)
    _gst_make_oop_non_weak (oop2);

  if (oop1->flags & F_WEAK)
    _gst_make_oop_non_weak (oop1);

  /* Put the two objects in the same generation.  FIXME: this can be
     a cause of early tenuring, especially since one of them is often
     garbage!  */
  if ((oop1->flags & F_OLD) ^ (oop2->flags & F_OLD))
    _gst_tenure_oop ((oop1->flags & F_OLD) ? oop2 : oop1);

  tempOOP = *oop2;		/* note structure assignment going on here */
  *oop2 = *oop1;
  *oop1 = tempOOP;

  /* If the incremental GC has reached oop1 but not oop2 (or vice versa),
     this flag will end up in the wrong OOP, i.e. in the one that has already
     been scanned by the incremental GC.  Restore things.  */
  if ((oop1->flags & F_REACHABLE) ^ (oop2->flags & F_REACHABLE))
    {
      oop1->flags ^= F_REACHABLE;
      oop2->flags ^= F_REACHABLE;
    }

  if (oop2->flags & F_WEAK)
    _gst_make_oop_weak (oop2);

  if (oop1->flags & F_WEAK)
    _gst_make_oop_weak (oop1);
}


void
_gst_make_oop_fixed (OOP oop)
{
  mst_Object newObj;
  int size;
  if (oop->flags & F_FIXED)
    return;

  size = TO_INT(oop->object->objSize) * SIZEOF_LONG;
  newObj = (mst_Object) _gst_mem_alloc (_gst_mem.fixed, size);
  if (!newObj)
    abort ();

  memcpy (newObj, oop->object, size);
  if (oop->flags & F_OLD)
    _gst_mem_free (_gst_mem.old, oop->object);
  else
    _gst_mem.numOldOOPs++;

  oop->object = newObj;
  oop->flags &= ~(F_SPACES | F_POOLED);
  oop->flags |= F_OLD | F_FIXED;
}

void
_gst_tenure_oop (OOP oop)
{
  mst_Object newObj;
  if (oop->flags & F_OLD)
    return;

  if (!(oop->flags & F_FIXED))
    {
      int size = TO_INT(oop->object->objSize) * SIZEOF_LONG;
      newObj = (mst_Object) _gst_mem_alloc (_gst_mem.old, size);
      if (!newObj)
        abort ();

      memcpy (newObj, oop->object, size);

      _gst_mem.numOldOOPs++;

      oop->object = newObj;
    }

  oop->flags &= ~(F_SPACES | F_POOLED);
  oop->flags |= F_OLD;
}


mst_Object
_gst_alloc_obj (size_t size,
		OOP *p_oop)
{
  OOP *newAllocPtr;
  mst_Object p_instance;

  size = ROUNDED_BYTES (size);

  /* We don't want to have allocPtr pointing to the wrong thing during
     GC, so we use a local var to hold its new value */
  newAllocPtr = _gst_mem.eden.allocPtr + (size >> LONG_SHIFT);

  if UNCOMMON (size >= _gst_mem.big_object_threshold)
    return _gst_alloc_old_obj (size, p_oop);

  if UNCOMMON (newAllocPtr >= _gst_mem.eden.maxPtr)
    {
      _gst_scavenge ();
      newAllocPtr = _gst_mem.eden.allocPtr + size;
    }

  p_instance = (mst_Object) _gst_mem.eden.allocPtr;
  _gst_mem.eden.allocPtr = newAllocPtr;
  *p_oop = alloc_oop (p_instance, _gst_mem.active_flag);
  p_instance->objSize = FROM_INT (size >> LONG_SHIFT);

  return p_instance;
}

mst_Object
_gst_alloc_old_obj (size_t size,
		    OOP *p_oop)
{
  OOP *newAllocPtr;
  mst_Object p_instance;

  size = ROUNDED_BYTES (size);
  newAllocPtr = _gst_mem.eden.allocPtr + (size >> LONG_SHIFT);

  /* If the object is big enough, we put it directly in oldspace.  */
  p_instance = (mst_Object) _gst_mem_alloc (_gst_mem.old, size);
  if COMMON (p_instance)
    goto ok;

  _gst_global_gc (size);
  p_instance = (mst_Object) _gst_mem_alloc (_gst_mem.old, size);
  if COMMON (p_instance)
    goto ok;

  _gst_compact (0);
  p_instance = (mst_Object) _gst_mem_alloc (_gst_mem.old, size);
  if UNCOMMON (!p_instance)
    {
      /* !!! do something more reasonable in the future */
      _gst_errorf ("Cannot recover, exiting...");
      exit (1);
    }

ok:
  *p_oop = alloc_oop (p_instance, F_OLD);
  p_instance->objSize = FROM_INT (size >> LONG_SHIFT);
  return p_instance;
}

mst_Object _gst_alloc_words (size_t size)
{
  OOP *newAllocPtr;
  mst_Object p_instance;

  /* We don't want to have allocPtr pointing to the wrong thing during
     GC, so we use a local var to hold its new value */
  newAllocPtr = _gst_mem.eden.allocPtr + size;

  if UNCOMMON (newAllocPtr >= _gst_mem.eden.maxPtr)
    {
      nomemory (0);
      abort ();
    }

  p_instance = (mst_Object) _gst_mem.eden.allocPtr;
  _gst_mem.eden.allocPtr = newAllocPtr;
  p_instance->objSize = FROM_INT (size);
  return p_instance;
}


void
reset_survivor_space (surv_space *space)
{
  space->allocated = space->filled = 0;
  space->tenurePtr = space->allocPtr = space->topPtr = space->minPtr;
}

void
oldspace_after_allocating (heap_data *h, heap_block *blk, size_t sz)
{
#ifdef MMAN_DEBUGGING
  printf ("Allocating oldspace page at %p (%d)\n", blk, sz);
#endif

  add_to_grey_list ((OOP *) blk, sz / SIZEOF_CHAR_P);
  _gst_mem.rememberedTableEntries++;
}

void
oldspace_before_freeing (heap_data *h, heap_block *blk, size_t sz)
{
  grey_area_node *node, *last, **next;

#ifdef MMAN_DEBUGGING
  printf ("Freeing oldspace page at %p (%d)\n", blk, sz);
#endif
  
  /* Remove related entries from the remembered table.  */
  for (last = NULL, next = &_gst_mem.grey_pages.head; (node = *next); )
    if (node->base >= (OOP *)blk
	&& node->base + node->n <= (OOP *)( ((char *)blk) + sz))
      {
#ifdef MMAN_DEBUGGING
	printf ("  Remembered table entry removed %p..%p\n",
		node->base, node->base+node->n);
#endif
  
        _gst_mem.rememberedTableEntries--;
	*next = node->next;
	xfree (node);
      }
    else
      {
        last = node;
	next = &(node->next);
      }

  _gst_mem.grey_pages.tail = last;
  _gst_mem_protect ((PTR) blk, sz, PROT_READ | PROT_WRITE);
}

void
oldspace_nomemory (heap_data *h, size_t sz)
{
  if (!_gst_gc_running)
    _gst_global_gc (sz);
}

#ifndef NO_SIGSEGV_HANDLING
int oldspace_sigsegv_handler (void* fault_address, int serious)
{
  static int reentering, reentered;
  void *page;
  if UNCOMMON (reentering)
    {
      reentered = 1;
      abort();
    }
  else
   {
     reentered = 0;
     reentering = 1;
   }

  page = (char *) fault_address - ((long) fault_address & (getpagesize() - 1));
  errno = 0;
  if (_gst_mem_protect (page, getpagesize(), PROT_READ | PROT_WRITE) == -1 &&
      (errno == ENOMEM || errno == EFAULT || errno == EACCES || errno == EINVAL))
    {
#if defined (MMAN_DEBUGGING)
      printf ("Plain old segmentation violation -- address = %p\n", page);
#endif
      reentering = 0;
      abort();
    }

  /* Try accessing the page */
  (void) *(volatile char *) fault_address;
  reentering = 0;

#if defined (MMAN_DEBUGGING)
  printf ("Unprotected %p (SIGSEGV at %p)\n", page, fault_address);
#endif

  _gst_mem.rememberedTableEntries++;
  add_to_grey_list ((PTR) page, getpagesize() / SIZEOF_CHAR_P);
  return !reentered;
}
#endif


void
update_stats (unsigned long *last, double *between, double *duration)
{
  unsigned long now = _gst_get_milli_time ();
  unsigned long since = now - *last;
  if (between)
      *between = _gst_mem.factor * *between
	       + (1 - _gst_mem.factor) * since;

  if (duration)
    *duration = _gst_mem.factor * *duration
	      + (1 - _gst_mem.factor) * since;
  else
    *last = now;
}

void
_gst_grow_memory_to (size_t spaceSize)
{
  _gst_compact (spaceSize);
}

void
_gst_grow_memory_no_compact (size_t new_heap_limit)
{
  _gst_mem.old->heap_limit = new_heap_limit;
  _gst_mem.fixed->heap_limit = new_heap_limit;
  _gst_mem.numGrowths++;
  update_stats (&stats.timeOfLastGrowth,
		&_gst_mem.timeBetweenGrowths, NULL);
}

void
_gst_compact (size_t new_heap_limit)
{
  OOP oop;
  grey_area_node *node, *next;
  heap_data *new_heap = init_old_space (
    new_heap_limit ? new_heap_limit : _gst_mem.old->heap_limit);

  if (new_heap_limit)
    {
      _gst_mem.fixed->heap_limit = new_heap_limit;
      _gst_mem.numGrowths++;
      update_stats (&stats.timeOfLastGrowth,
		    &_gst_mem.timeBetweenGrowths, NULL);
      stats.timeOfLastCompaction = stats.timeOfLastGrowth;
    }
  else
    {
      _gst_mem.numCompactions++;
      update_stats (&stats.timeOfLastCompaction, NULL, NULL);
    }

  /* Discard all the grey pages.  */
  for (node = _gst_mem.grey_pages.head; node; node = next)
    {
      next = node->next;
      xfree (node);
    }
  _gst_mem.grey_pages.head = _gst_mem.grey_pages.tail = NULL;
  _gst_mem.rememberedTableEntries = 0;

  _gst_fixup_object_pointers ();

  /* Now do the copying loop which will compact oldspace.  */
  for (oop = _gst_mem.ot;
       oop < &_gst_mem.ot[_gst_mem.ot_size]; oop++)
    if ((oop->flags & (F_OLD | F_FIXED)) == F_OLD)
      {
        mst_Object new;
        size_t size = SIZEOF_LONG * TO_INT (oop->object->objSize);
        new = _gst_mem_alloc (new_heap, size);
        memcpy (new, oop->object, size);
        _gst_mem_free (_gst_mem.old, oop->object);
        oop->object = new;
      }

  xfree (_gst_mem.old);
  _gst_mem.old = new_heap;
  new_heap->nomemory = oldspace_nomemory;

  _gst_restore_object_pointers ();

  update_stats (&stats.timeOfLastCompaction, NULL, &_gst_mem.timeToCompact);
}


void
_gst_global_compact ()
{
  _gst_global_gc (0);
  _gst_finish_incremental_gc ();
  _gst_compact (0);
}

void
_gst_global_gc (int next_allocation)
{
  char *s;
  int old_limit;

  _gst_mem.numGlobalGCs++;

  old_limit = _gst_mem.old->heap_limit;
  _gst_mem.old->heap_limit = 0;
    
  if (!_gst_gc_running++ && _gst_gc_message && !_gst_regression_testing)
    {
      /* print the first part of this message before we finish
         scanning oop table for live ones, so that the delay caused by
         this scanning is apparent.  Note the use of stderr for the
         printed message.  The idea here was that generated output
         could be treated as Smalltalk code, HTML or whatever else you
         want without harm. */
      fflush (stdout);
      fprintf (stderr, "\"Global garbage collection... ");
      fflush (stderr);
    }

  update_stats (&stats.timeOfLastGlobalGC,
		&_gst_mem.timeBetweenGlobalGCs, NULL);

  _gst_finish_incremental_gc ();
  _gst_fixup_object_pointers ();
  copy_oops ();
  _gst_tenure_all_survivors ();
  mark_oops ();
  _gst_mem.live_flags &= ~F_OLD;
  _gst_mem.live_flags |= F_REACHABLE;
  check_weak_refs ();
  _gst_restore_object_pointers ();
  reset_incremental_gc (_gst_mem.ot);

  update_stats (&stats.timeOfLastGlobalGC,
		NULL, &_gst_mem.timeToCollect);

  s = "done";

  /* Compaction and growth tests are only done during the outermost GC (well
     I am not sure that GC's can nest...)  */
  if (old_limit)
    {
      old_limit = MAX (old_limit, _gst_mem.old->heap_total);

      /* Check if it's time to compact the heap.  */
      if UNCOMMON ((next_allocation + _gst_mem.old->heap_total)
	    * 100.0 / old_limit > _gst_mem.grow_threshold_percent)
        {
          s = "done, heap compacted";
          _gst_compact (0);
        }

      /* Check if it's time to grow the heap.  */
      if UNCOMMON ((next_allocation + _gst_mem.old->heap_total)
	    * 100.0 / old_limit > _gst_mem.grow_threshold_percent
         || (next_allocation + _gst_mem.fixed->heap_total)
	    * 100.0 / _gst_mem.fixed->heap_limit > _gst_mem.grow_threshold_percent)
        {
          int grow_amount_to_satisfy_rate = old_limit
               * (100.0 + _gst_mem.space_grow_rate) / 100;
          int grow_amount_to_satisfy_threshold = 
	       (next_allocation + _gst_mem.old->heap_total)
	       * 100.0 /_gst_mem.grow_threshold_percent;

          s = "done, heap grown";
          _gst_grow_memory_no_compact (MAX (grow_amount_to_satisfy_rate,
					    grow_amount_to_satisfy_threshold));
        }
     }

  if (!--_gst_gc_running && _gst_gc_message && !_gst_regression_testing)
    {
      fprintf (stderr, "%s\"\n", s);
      fflush (stderr);
    }

  /* If the heap was grown, don't reset the old limit! */
  if (!_gst_mem.old->heap_limit)
    _gst_mem.old->heap_limit = old_limit;

  mourn_objects ();
}

void
_gst_scavenge (void)
{
  int oldBytes, reclaimedBytes, tenuredBytes, reclaimedPercent;

  /* Force a GC as soon as possible if we're low on OOPs or memory.  */
  if UNCOMMON (_gst_mem.num_free_oops < LOW_WATER_OOP_THRESHOLD
     || _gst_mem.old->heap_total * 100.0 / _gst_mem.old->heap_limit >
	_gst_mem.grow_threshold_percent
     || _gst_mem.fixed->heap_total * 100.0 / _gst_mem.fixed->heap_limit >
	_gst_mem.grow_threshold_percent)
    {
      _gst_global_gc (0);
      _gst_incremental_gc_step ();
      return;
    }

  if (!_gst_gc_running++ && _gst_gc_message && !_gst_regression_testing)
    {
      /* print the first part of this message before we finish
	 scanning oop table for live ones, so that the delay caused by
	 this scanning is apparent.  Note the use of stderr for the
	 printed message.  The idea here was that generated output
	 could be treated as Smalltalk code, HTML or whatever else you
	 want without harm. */
      fflush (stdout);
      fprintf (stderr, "\"Scavenging... ");
      fflush (stderr);
    }

  oldBytes = (char *) _gst_mem.eden.allocPtr - (char *) _gst_mem.eden.minPtr +
    _gst_mem.active_half->filled;

  _gst_mem.numScavenges++;
  update_stats (&stats.timeOfLastScavenge,
		&_gst_mem.timeBetweenScavenges, NULL);

  _gst_finish_incremental_gc ();
  _gst_fixup_object_pointers ();
  copy_oops ();
  check_weak_refs ();
  _gst_restore_object_pointers ();
  reset_incremental_gc (_gst_mem.ot);

  update_stats (&stats.timeOfLastScavenge,
		NULL, &_gst_mem.timeToScavenge);

  reclaimedBytes = oldBytes - _gst_mem.active_half->allocated;
  if (reclaimedBytes < 0)
    reclaimedBytes = 0;

  tenuredBytes = _gst_mem.active_half->allocated - _gst_mem.active_half->filled;
  reclaimedPercent = 100.0 * reclaimedBytes / oldBytes;

  if (!--_gst_gc_running && _gst_gc_message && !_gst_regression_testing)
    {
      fprintf (stderr, "%d%% reclaimed, done\"\n", reclaimedPercent);
      fflush (stderr);
    }

  _gst_mem.reclaimedBytesPerScavenge =
    _gst_mem.factor * reclaimedBytes +
    (1 - _gst_mem.factor) * _gst_mem.reclaimedBytesPerScavenge;

  _gst_mem.reclaimedPercentPerScavenge =
    _gst_mem.factor * reclaimedPercent +
    (1 - _gst_mem.factor) * _gst_mem.reclaimedPercentPerScavenge;

  _gst_mem.tenuredBytesPerScavenge =
    _gst_mem.factor * tenuredBytes +
    (1 - _gst_mem.factor) * _gst_mem.tenuredBytesPerScavenge;

  mourn_objects ();
}




void
_gst_finish_incremental_gc ()
{
  OOP oop, firstOOP;

#if defined (GC_DEBUGGING)
  printf ("Completing sweep (%p...%p), validity flags %x\n", _gst_mem.last_swept_oop,
          _gst_mem.highest_swept_oop, _gst_mem.live_flags);
#endif

  for (oop = _gst_mem.highest_swept_oop, firstOOP = _gst_mem.last_swept_oop;
       --oop > firstOOP; oop->flags &= ~F_REACHABLE)
    if (!IS_OOP_VALID_GC(oop))
      {
        _gst_sweep_oop (oop);
	_gst_mem.num_free_oops++;
        _gst_mem.highest_swept_oop = oop;
        if (oop == _gst_mem.last_allocated_oop)
          _gst_mem.last_allocated_oop--;
      }

  finished_incremental_gc ();
}

void
finished_incremental_gc (void)
{
  _gst_mem.live_flags &= ~F_REACHABLE;
  _gst_mem.live_flags |= F_OLD;

  _gst_mem.reclaimedBytesPerGlobalGC =
    _gst_mem.factor * stats.reclaimedOldSpaceBytesSinceLastGlobalGC +
    (1 - _gst_mem.factor) * _gst_mem.reclaimedBytesPerScavenge;

#ifdef USE_JIT_TRANSLATION
  /* Go and really free the blocks associated to garbage collected
     native code. */
  _gst_free_released_native_code ();
#endif
}

void
_gst_incremental_gc_step ()
{
  OOP oop, firstOOP;
  int i;

  for (i = 0, oop = _gst_mem.highest_swept_oop,
       firstOOP = _gst_mem.last_swept_oop;
       i <= INCREMENTAL_SWEEP_STEP && --oop > firstOOP;
       oop->flags &= ~F_REACHABLE)
    {
      if (--oop > firstOOP)
        {
	  finished_incremental_gc ();
	  break;
	}

      if (!IS_OOP_VALID_GC(oop))
        {
          i++;
          _gst_sweep_oop (oop);
  	_gst_mem.num_free_oops++;
          _gst_mem.highest_swept_oop = oop;
          if (oop == _gst_mem.last_allocated_oop)
            _gst_mem.last_allocated_oop--;
        }
    }
}

void
reset_incremental_gc (OOP firstOOP)
{
  OOP oop;

  /* This loop is the same as that in alloc_oop.  Skip low OOPs
     that are allocated */
  for (oop = firstOOP; IS_OOP_VALID_GC (oop); oop->flags &= ~F_REACHABLE, oop++)
#if defined(USE_JIT_TRANSLATION)
    if (oop->flags & F_XLAT)
      {
        if (oop->flags & F_XLAT_REACHABLE)
          /* Reachable, and referenced by active contexts.  Keep it
             around. */
          oop->flags &= ~F_XLAT_2NDCHANCE;
        else
          {
            /* Reachable, but not referenced by active contexts.  We
               give it a second chance... */
            if (oop->flags & F_XLAT_2NDCHANCE)
              _gst_release_native_code (oop);

            oop->flags ^= F_XLAT_2NDCHANCE;
          }
      }
#else
      ;
#endif

  _gst_mem.first_allocated_oop = oop;

#ifdef NO_INCREMENTAL_GC
  _gst_mem.highest_swept_oop = _gst_mem.last_allocated_oop + 1;
  _gst_finish_incremental_gc ();
#else
  /* Skip high OOPs that are unallocated.  */
  for (oop = _gst_mem.last_allocated_oop; !IS_OOP_VALID_GC (oop); oop--)
    _gst_sweep_oop (oop);

  _gst_mem.last_allocated_oop = oop;
  _gst_mem.highest_swept_oop = oop + 1;
#endif

  _gst_mem.last_swept_oop = _gst_mem.first_allocated_oop - 1;
  _gst_mem.num_free_oops = _gst_mem.ot_size -
    (_gst_mem.last_allocated_oop - _gst_mem.ot);

  /* Check if it's time to grow the OOP table.  */
  if (_gst_mem.num_free_oops * 100.0 / _gst_mem.ot_size <
	100 - _gst_mem.grow_threshold_percent)
    _gst_realloc_oop_table (_gst_mem.ot_size
      * (100 + _gst_mem.space_grow_rate) / 100);

#if defined (GC_DEBUGGING)
  printf ("Found unallocated at OOP %p, last allocated OOP %p\n"
          "Highest OOP swept top to bottom %p, lowest swept bottom to top %p\n",
	  _gst_mem.first_allocated_oop, _gst_mem.last_allocated_oop,
	  _gst_mem.highest_swept_oop, _gst_mem.last_swept_oop);
#endif
}


void
_gst_sweep_oop (OOP oop)
{
  _gst_mem.last_swept_oop = oop;

  if (IS_OOP_FREE (oop))
    return;

#ifdef USE_JIT_TRANSLATION
  if (oop->flags & F_XLAT)
    /* Unreachable, always free the native code.  Note
       it is *not* optional to free the code in this case -- and
       I'm not talking about memory leaks: a different
       method could use the same OOP as this one and the
       old method one would be executed instead of the new
       one! */
    _gst_release_native_code (oop);
#endif

  if UNCOMMON (oop->flags & F_WEAK)
    _gst_make_oop_non_weak (oop);

  /* Free unreachable oldspace objects. */
  if UNCOMMON (oop->flags & F_FIXED)
    {
      _gst_mem.numOldOOPs--;
      stats.reclaimedOldSpaceBytesSinceLastGlobalGC +=
	SIZEOF_LONG * TO_INT (OOP_TO_OBJ (oop)->objSize);
      _gst_mem_free (_gst_mem.fixed, oop->object);
    }
  else if UNCOMMON (oop->flags & F_OLD)
    {
      _gst_mem.numOldOOPs--;
      stats.reclaimedOldSpaceBytesSinceLastGlobalGC +=
	SIZEOF_LONG * TO_INT (OOP_TO_OBJ (oop)->objSize);
      _gst_mem_free (_gst_mem.old, oop->object);
    }

  oop->flags = F_FREE;
}

void
mourn_objects (void)
{
  mst_Object array;
  long size;
  gst_processor_scheduler processor;

  size = _gst_buffer_size () / sizeof (OOP);
  if (!size)
    return;

  processor = (gst_processor_scheduler) OOP_TO_OBJ (_gst_processor_oop);
  if (!IS_NIL (processor->gcArray))
    {
      _gst_errorf ("Too many garbage collections, finalizers missed!");
      _gst_errorf ("This is a bug, please report.");
    }
  else
    {
      /* Copy the buffer */
      array = new_instance_with (_gst_array_class, size, &processor->gcArray);
      _gst_copy_buffer (array->data);
      _gst_async_signal (processor->gcSemaphore);
    }
}


#define IS_QUEUE_SPLIT(q) ((q)->topPtr != (q)->allocPtr)

#define QUEUE_NEXT(q, addr) (IS_QUEUE_SPLIT (q) && (addr) >= (q)->topPtr ? (q)->minPtr : (addr))

OOP *
queue_get (surv_space *q, int n)
{
  OOP *result = q->tenurePtr;
  q->filled -= n * SIZEOF_CHAR_P;
  q->tenurePtr += n;

  /* Check if the read pointer has to wrap.  */
  if (q->tenurePtr == q->topPtr)
    {
      q->tenurePtr = q->minPtr;
      q->topPtr = q->allocPtr;
    }

  return result;
}

OOP *
queue_put (surv_space *q, OOP *src, int n)
{
  OOP *result, *newAlloc;
  for (;;)
    {
      result = q->allocPtr;
      newAlloc = q->allocPtr + n;

#if defined(GC_DEBUGGING)
      printf ("Top %p alloc %p tenure %p\n", q->topPtr, q->allocPtr, q->tenurePtr);
#endif

      if (IS_QUEUE_SPLIT (q) && UNCOMMON (newAlloc > q->tenurePtr))
        /* We tenure old objects as we copy more objects into
           the circular survivor space.  */
        {
#if defined(GC_DEBUGGING)
	  printf ("Tenure: current max %p, needed %p\n", q->tenurePtr, newAlloc);
#endif
	  tenure_one_object();
	  continue;
        }

      if UNCOMMON (newAlloc > q->maxPtr)
        {
#if defined(GC_DEBUGGING)
          printf ("Wrap: survivor space ends at %p, needed %p\n", q->maxPtr, newAlloc);
#endif
          q->topPtr = q->allocPtr;
          result = q->allocPtr = q->minPtr;
          newAlloc = q->allocPtr + n;
	  continue;
        }

      break;
    }

  if (!IS_QUEUE_SPLIT (q))
    /* We are still extending towards the top.  Push further the
       valid area (which is space...topPtr and minPtr...allocPtr
       if topPtr != allocPtr (not circular yet), space...allocPtr
       if topPtr == allocPtr (circular). */
    q->topPtr = newAlloc;

  q->filled += n * SIZEOF_CHAR_P;
  q->allocated += n * SIZEOF_CHAR_P;
  q->allocPtr = newAlloc;
  memcpy (result, src, n * SIZEOF_CHAR_P);
  return result;
}

void
tenure_one_object ()
{
  OOP oop;

  oop = *_gst_mem.tenuring_queue.tenurePtr;
#if defined(GC_DEBUGGING)
  printf ("      ");
  _gst_display_oop (oop);
#endif

  if (_gst_mem.scan.current == oop)
    {
#if defined(GC_DEBUGGING)
      printf ("Tenured OOP %p was being scanned\n", oop);
#endif

      _gst_tenure_oop (oop);
      _gst_mem.scan.at = (OOP *) oop->object;
    }

  /* Ephemerons are treated specially.  Since _gst_copy_an_oop itself
     puts them in the tree of grey areas, we don't need to grey them.  */
  else if (_gst_mem.scan.queue_at == _gst_mem.tenuring_queue.tenurePtr)
    {
#if defined(GC_DEBUGGING)
      printf ("Tenured OOP %p had not been scanned yet\n", oop);
#endif

      _gst_mem.scan.queue_at = QUEUE_NEXT (&_gst_mem.tenuring_queue,
					   _gst_mem.scan.queue_at + 1);
      _gst_tenure_oop (oop);
      add_grey_object (oop);
    }
  else
    _gst_tenure_oop (oop);

  queue_get (&_gst_mem.tenuring_queue, 1);
  queue_get (_gst_mem.active_half, TO_INT (oop->object->objSize));
}

void
_gst_grey_oop_range (PTR from, size_t size)
{
  volatile char *last, *page;

  for (last = ((char *)from) + size,
       page = ((char *)from) - ((long) from & (getpagesize() - 1));
       page < last;
       page += getpagesize())
    *page = *page;
}


void
add_grey_object (OOP oop)
{
  grey_area_node *entry;
  mst_Object obj = OOP_TO_OBJ (oop);
  int numFields = scanned_fields_in (obj, oop->flags);
  OOP *base = &(obj->objClass);

  if (!numFields)
    return;

  /* For ephemeron, skip the first field and the class.  */
  if (oop->flags & F_EPHEMERON)
    {
      numFields -= &(obj->data[1]) - base;
      base = &(obj->data[1]); 
    }

  entry = (grey_area_node *) xmalloc (sizeof (grey_area_node));
  entry->base = base;
  entry->n = numFields;
  entry->oop = oop;
  entry->next = NULL;
  if (_gst_mem.grey_areas.tail)
    _gst_mem.grey_areas.tail->next = entry;
  else
    _gst_mem.grey_areas.head = entry;

  _gst_mem.grey_areas.tail = entry;
}

void
add_to_grey_list (OOP *base, int n)
{
  grey_area_node *entry = (grey_area_node *) xmalloc (sizeof (grey_area_node));
  entry->base = base;
  entry->n = n;
  entry->oop = NULL;
  entry->next = NULL;
  if (_gst_mem.grey_pages.tail)
    _gst_mem.grey_pages.tail->next = entry;
  else
    _gst_mem.grey_pages.head = entry;

  _gst_mem.grey_pages.tail = entry;
}

void
_gst_tenure_all_survivors ()
{
  OOP oop;
  while (_gst_mem.tenuring_queue.filled)
    {
      oop = *queue_get (&_gst_mem.tenuring_queue, 1);
      _gst_tenure_oop (oop);
    }
}

void
check_weak_refs ()
{
  OOP oop = NULL, *field;
  mst_Boolean mourn;

  rb_node_t *node;
  rb_traverse_t t;

  for (node = rb_first(&(_gst_mem.weak_areas->rb), &t);
       node; node = rb_next (&t))
    {
      weak_area_tree *area = (weak_area_tree *) node;

      mourn = false;
      for (field = area->base; field < area->end; field++)
        {
	  oop = *field;
          if (IS_INT (oop))
	    continue;

          if (!IS_OOP_VALID_GC (oop))
            {
              mourn = true;
	      *field = _gst_nil_oop;
	    }
        }

      if (mourn)
        _gst_add_buf_pointer (oop);
    }
}

void
copy_oops (void)
{
  _gst_reset_buffer ();

  /* Do the flip! */
  _gst_mem.live_flags ^= F_SPACES;
  _gst_mem.active_flag ^= F_SPACES;
  _gst_mem.active_half = &_gst_mem.surv[_gst_mem.active_flag == F_ODD];

  reset_survivor_space (_gst_mem.active_half);
  reset_survivor_space (&_gst_mem.tenuring_queue);

  /* And the pointer for Cheney scanning.  */
  _gst_mem.scan.queue_at = _gst_mem.tenuring_queue.tenurePtr;

  /* Do these first, they are more likely to stay around for long,
     so it makes sense to make their tenuring more likely (the first
     copied objects are also tenured first).  */
  scan_grey_pages ();

  _gst_copy_registered_oops ();
  cheney_scan ();

  /* Do these last since they are often alive only till the next
     scavenge.  */
  _gst_copy_processor_registers ();
  cheney_scan ();

  scan_grey_objects ();

  /* Reset the new-space pointers */
  _gst_empty_context_pool ();
  _gst_mem.eden.allocPtr = _gst_mem.eden.minPtr;
}

void
scan_grey_pages ()
{
  grey_area_node *node, **next, *last;
  OOP *pOOP, oop;
  int i, n;

#if defined (MMAN_DEBUGGING)
  printf ("Pages on the grey list: ");
  for (n = 0, node = _gst_mem.grey_pages.head; node; node = node->next, n++)
    {
      if (n & 3)
        printf ("%12p ", node->base);
      else
        printf ("\n%12p ", node->base);
    }

  if (_gst_mem.grey_pages.tail)
    printf ("  (tail = %12p)", _gst_mem.grey_pages.tail->base);

  printf ("\n");
#endif

  for (last = NULL, next = &_gst_mem.grey_pages.head; (node = *next); )
    {
#if defined(GC_DEBUGGING) || defined(MMAN_DEBUGGING)
      printf ("Scanning grey page %p...%p\n", node->base, node->base + node->n);
#endif

      for (n = 0, pOOP = node->base, i = node->n; i--; pOOP++)
        {
          oop = *pOOP;

          /* Not all addresses are known to contain valid OOPs! */
	  if (!IS_OOP_ADDR (oop))
	    continue;

          if (!IS_OOP_NEW (oop))
	    continue;

	  n++;
	  if (!IS_OOP_COPIED (oop))
	    _gst_copy_an_oop (oop);
	}

#if !defined (NO_SIGSEGV_HANDLING)
      if (!n)
	{
          /* The entry was temporary, or we found no new-space
             pointers in it.  Delete it and make the page read-only.  */
#if defined (MMAN_DEBUGGING)
	  printf ("Protecting %p\n", node->base);
#endif
	  _gst_mem.rememberedTableEntries--;
	  _gst_mem_protect ((PTR) node->base, node->n * sizeof(OOP), PROT_READ);
	  *next = node->next;
	  xfree (node);
	}
      else
#endif
	{
	  last = node;
	  next = &(node->next);
	}

      cheney_scan ();
    }

  _gst_mem.grey_pages.tail = last;

#if defined (MMAN_DEBUGGING)
  printf ("Pages left on the grey list: ");
  for (n = 0, node = _gst_mem.grey_pages.head; node; node = node->next, n++)
    {
      if (n & 3)
        printf ("%12p ", node->base);
      else
        printf ("\n%12p ", node->base);
    }

  if (_gst_mem.grey_pages.tail)
    printf ("  (tail = %12p)", _gst_mem.grey_pages.tail->base);

  printf ("\n");
#endif
}

void
scan_grey_objects()
{
  grey_area_node *node, *next;
  OOP oop;
  mst_Object obj;

  for (next = _gst_mem.grey_areas.head; (node = next); )
    {
      oop = node->oop;
      obj = OOP_TO_OBJ (oop);

      if (oop->flags & F_EPHEMERON)
	/* Objects might have moved, so update node->base.  */
	node->base = (OOP *) &obj->data[1];

#if defined(GC_DEBUGGING)
      printf ("Scanning grey range %p...%p (%p)\n", node->base, node->base + node->n, oop);
#endif

      _gst_copy_oop_range (node->base, node->base + node->n);

      if (oop->flags & F_EPHEMERON)
        {
	  OOP key = obj->data[0];

	  /* Copy the key, mourn the object if it was not reachable.  */
	  if (!IS_OOP_COPIED (key))
	    {
	      _gst_copy_an_oop (key);
              _gst_add_buf_pointer (oop);
	    }
	}

      _gst_mem.grey_areas.head = next = node->next;
      xfree (node);
      if (!next)
        _gst_mem.grey_areas.tail = NULL;

      cheney_scan ();

      /* The scan might have greyed more areas.  */
      if (!next)
        next = _gst_mem.grey_areas.head;
    }

}

int
scanned_fields_in (mst_Object object,
		  int flags)
{
  OOP objClass = object->objClass;

  if COMMON (!(flags & (F_WEAK | F_CONTEXT)))
    {
      int size = NUM_OOPS (object);
      if COMMON (size)
	return object->data + size - &object->objClass;
      else
	return UNCOMMON (!IS_OOP_COPIED (objClass));
    }

  if COMMON (flags & F_CONTEXT)
    {
      gst_method_context context;
      long methodSP;
      context = (gst_method_context) object;
      methodSP = TO_INT (context->spOffset);
      return context->contextStack + methodSP + 1 - &context->objClass;
    }
  else
    {
      /* In general, there will be many instances of a class,
	 but only the first time will it need to be copied;
         moreover, classes are often old.  So I'm
	 marking this as uncommon. */
      return UNCOMMON (!IS_OOP_COPIED (objClass));
    }
}

void
cheney_scan (void)
{
#if defined(GC_DEBUGGING)
  printf ("Starting Cheney scan\n");
#endif

  while (_gst_mem.scan.queue_at !=
	   _gst_mem.tenuring_queue.allocPtr)
    {
      OOP oop;
      int i, numFields;

      if (_gst_mem.scan.queue_at >= _gst_mem.tenuring_queue.topPtr)
        _gst_mem.scan.queue_at = _gst_mem.tenuring_queue.minPtr;

      if (_gst_mem.scan.queue_at == _gst_mem.tenuring_queue.allocPtr)
	break;

      oop = *_gst_mem.scan.queue_at;

#if defined(GC_DEBUGGING)
      if (!IS_OOP_ADDR (oop))
	abort();

      printf (">Scan ");
      _gst_display_oop (oop);
#endif

      _gst_mem.scan.current = oop;
      _gst_mem.scan.queue_at++;

      if (oop->flags & F_EPHEMERON)
	continue;

      _gst_mem.scan.at = (OOP *) OOP_TO_OBJ (oop);
      numFields = scanned_fields_in (OOP_TO_OBJ (oop), oop->flags);

      /* The +1 below is to skip the size field.  */
      for (i = 0; i < numFields; i++)
	MAYBE_COPY_OOP (_gst_mem.scan.at[i+1]);
    }

#if defined(GC_DEBUGGING)
  printf ("Ending Cheney scan\n");
#endif
}

void
_gst_copy_oop_range (OOP *curOOP, OOP *atEndOOP)
{
  OOP *pOOP;
  for (pOOP = curOOP; pOOP < atEndOOP; pOOP++)
    MAYBE_COPY_OOP (*pOOP);
}

void
_gst_copy_an_oop (OOP oop)
{
  int i, n;
  do
    {
      mst_Object obj;
      OOP *pData;

      obj = OOP_TO_OBJ (oop);
      pData = (OOP *) obj;

#if defined(GC_DEBUGGING)
      printf (">Copy ");
      _gst_display_oop (oop);
#endif

#if !defined (OPTIMIZE)
      if UNCOMMON (!IS_INT (obj->objSize))
	{
	  printf ("Size not an integer in OOP %p (%p)\n", oop, obj);
	  abort ();
	}

      if UNCOMMON (TO_INT (obj->objSize) < 2)
	{
	  printf ("Invalid size for OOP %p (%p)\n", oop, obj);
	  abort ();
	}
#endif

      if UNCOMMON (oop->flags & F_FREE)
	{
	  printf ("Free OOP %p was referenced\n", oop);
	  /* If we're lucky, we can print some information on it...
	     if we're not, we segfault: not that bad given that
	     we'll abort pretty soon! */
	  oop->flags &= ~F_FREE;
	  _gst_display_oop (oop);
	  abort ();
	}

#if !defined (OPTIMIZE)
      if UNCOMMON ((oop->flags & F_OLD) ||
	  IS_SURVIVOR_ADDR(obj, _gst_mem.active_half == &_gst_mem.surv[1]))
        {
	  printf ("Copying an already copied object\n");
	  abort ();
	  return;
	}
#endif

      queue_put (&_gst_mem.tenuring_queue, &oop, 1);
      obj = oop->object = (mst_Object)
	queue_put (_gst_mem.active_half, pData, TO_INT (obj->objSize));

      oop->flags &= ~(F_SPACES | F_POOLED);
      oop->flags |= _gst_mem.active_flag;

      /* Look for a child that has not been copied and move it
         near the object.  This improves the locality of reference.  
         We do not copy the class (that's the reason for the -1
	 here). */
      n = scanned_fields_in (obj, oop->flags) - 1;
      if (oop->flags & F_EPHEMERON)
	{
	  /* For ephemerons, do the work later.  */
          add_grey_object (oop);
	  return;
	}

      for (i = 0; i < n; i++)
	{
	  OOP newOOP = obj->data[i];
	  if (!IS_OOP_COPIED (newOOP))
	    {
	      oop = newOOP;
	      break;
	    }
	}
    }
  while (i < n);
}


void
mark_oops (void)
{
  _gst_reset_buffer ();
  _gst_mark_registered_oops ();
  _gst_mark_processor_registers ();
  mark_ephemeron_oops ();
}

void
mark_ephemeron_oops (void)
{
  OOP *pOOP, *base;
  int i, size;

  /* Make a local copy of the buffer */
  size = _gst_buffer_size ();
  base = alloca (size);
  _gst_copy_buffer (base);
  _gst_reset_buffer ();
  size /= SIZEOF_CHAR_P;

  /* First pass: distinguish objects whose key was reachable from
     the outside by clearing their F_EPHEMERON bit. */
  for (pOOP = base, i = size; i--; pOOP++)
    {
      OOP oop = *pOOP;
      mst_Object obj = OOP_TO_OBJ(oop);
      OOP key = obj->data[0];

      if (key->flags & F_REACHABLE)
        oop->flags &= ~F_EPHEMERON;

      key->flags |= F_REACHABLE;
    }

  for (pOOP = base, i = size; i--; pOOP++)
    {
      OOP oop = *pOOP;
      mst_Object obj = OOP_TO_OBJ(oop);
      OOP key = obj->data[0];
      int num = NUM_OOPS(obj);
      int j;

      /* Find if the key is reachable from the objects (so that
         we can mourn the ephemeron if this is not so). */
      key->flags &= ~F_REACHABLE;

      for (j = 1; j < num; j++)
        MAYBE_MARK_OOP (obj->data[j]);

      /* Remember that above we cleared F_EPHEMERON is the key
         is alive. */
      if (!IS_OOP_MARKED (key) && (oop->flags & F_EPHEMERON))
        _gst_add_buf_pointer (oop);

      /* Ok, now mark the key. */
      MAYBE_MARK_OOP (key);

      /* Restore the flag in case it was cleared. */
      oop->flags |= F_EPHEMERON;
    }
}

#define TAIL_MARK_OOP(newOOP) BEGIN_MACRO { \
  oop = (newOOP); \
  continue;		/* tail recurse!!! */ \
} END_MACRO

#define TAIL_MARK_OOPRANGE(firstOOP, oopAtEnd) BEGIN_MACRO { \
  curOOP = (OOP *)(firstOOP); \
  atEndOOP = (OOP *)(oopAtEnd); \
  oop = NULL; \
  continue; \
} END_MACRO

void
_gst_mark_an_oop_internal (OOP oop,
			   OOP * curOOP,
			   OOP * atEndOOP)
{
  for (;;)
    {
      if (!oop)
	{			/* in the loop! */
#if !defined (OPTIMIZE)
	  mst_Object obj = (mst_Object) (curOOP - 1);	/* for debugging */
#endif
	iterationLoop:
	  /* in a loop, do next iteration */
	  oop = *curOOP;
	  curOOP++;
	  if (IS_OOP (oop))
	    {
#if !defined (OPTIMIZE)
	      if UNCOMMON (!IS_OOP_ADDR (oop))
		{
		  printf
		    ("Error! Invalid OOP %p was found inside %p!\n",
		     oop, obj);
		  abort ();
		}
	      else
#endif
	      if (!IS_OOP_MARKED (oop))
		{
		  if COMMON (curOOP < atEndOOP)
		    {
		      _gst_mark_an_oop_internal (oop, NULL, NULL);
		      goto iterationLoop;
		    }
		  else
		    /* On the last object in the set, reuse the
		       current invocation. oop is valid, so we go to
		       the single-object case */
		    continue;
		}
	    }
	  /* We reach this point if the object isn't to be marked.  The 
	     code above contains a continue to tail recurse, so we
	     cannot put the loop in a do...while and a goto is
	     necessary here.  Speed is a requirement, so I'm doing it. */
	  if (curOOP < atEndOOP)
	    goto iterationLoop;
	}
      else
	{			/* just starting with this oop */
	  OOP objClass;
	  mst_Object object;
	  unsigned long size;

#if !defined (OPTIMIZE)
	  if UNCOMMON (IS_OOP_FREE (oop))
	    {
	      printf ("Error! Free OOP %p is being marked!\n", oop);
	      abort ();
	      break;
	    }
#endif

#if defined(GC_DEBUGGING)
	  printf (">Mark ");
	  _gst_display_oop (oop);
#endif

	  /* see if the object has pointers, set up to copy them if so. 
	   */
	  oop->flags |= F_REACHABLE;
	  object = OOP_TO_OBJ (oop);
	  objClass = object->objClass;
	  if UNCOMMON (oop->flags & F_CONTEXT)
	    {
	      gst_method_context context = (gst_method_context) object;
	      long methodSP;

	      context = (gst_method_context) object;
	      methodSP = TO_INT (context->spOffset);
	      /* printf("setting up for loop on context %x, sp = %d\n", 
	         context, methodSP); */
	      TAIL_MARK_OOPRANGE (&context->objClass,
				  context->contextStack + methodSP + 1);

	    }
	  else if UNCOMMON (oop->flags & (F_EPHEMERON | F_WEAK))
	    {
	      /* In general, there will be many instances of a class,
		 but only the first time will it be unmarked.  So I'm
		 marking this as uncommon. */
	      if UNCOMMON (!IS_OOP_MARKED (objClass))
		TAIL_MARK_OOP (objClass);

	      if (oop->flags & F_EPHEMERON)
	        _gst_add_buf_pointer (oop);
	    }
	  else
	    {
	      size = NUM_OOPS (object);
	      if COMMON (size)
		TAIL_MARK_OOPRANGE (&object->objClass,
				    object->data + size);

	      else if UNCOMMON (!IS_OOP_MARKED (objClass))
		TAIL_MARK_OOP (objClass);
	    }
	}
      /* This point is reached if and only if nothing has to be marked
         anymore in the current iteration. So exit. */
      break;
    }				/* for(;;) */
}



void
_gst_inc_init_registry (void)
{
  _gst_mem.inc_base =
    (OOP *) xmalloc (INIT_NUM_INCUBATOR_OOPS * sizeof (OOP *));
  _gst_mem.inc_ptr = _gst_mem.inc_base;
  _gst_mem.inc_end =
    _gst_mem.inc_base + INIT_NUM_INCUBATOR_OOPS;

  /* Make the incubated objects part of the root set */
  _gst_register_oop_array (&_gst_mem.inc_base, &_gst_mem.inc_ptr);
}

void
_gst_inc_grow_registry (void)
{
  OOP *oldBase;
  unsigned long oldPtrOffset;
  unsigned long oldRegistrySize, newRegistrySize;

  oldBase = _gst_mem.inc_base;
  oldPtrOffset = _gst_mem.inc_ptr - _gst_mem.inc_base;
  oldRegistrySize = _gst_mem.inc_end - _gst_mem.inc_base;

  newRegistrySize = oldRegistrySize + INCUBATOR_CHUNK_SIZE;

  _gst_mem.inc_base =
    (OOP *) xrealloc (_gst_mem.inc_base,
		      newRegistrySize * sizeof (OOP *));
  _gst_mem.inc_ptr = _gst_mem.inc_base + oldPtrOffset;
  _gst_mem.inc_end = _gst_mem.inc_base + newRegistrySize;
}
