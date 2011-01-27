/******************************** -*- C -*- ****************************
 *
 *	Object table module Inlines.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2006, 2009 Free Software Foundation, Inc.
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

static inline OOP alloc_oop (PTR obj, intptr_t flags);

/* Copy the OOP object because it is part of the root set.  Integers
   and already-copied OOPs are not processed silently.  */
#define MAYBE_COPY_OOP(oop) do {			  \
  if (!IS_OOP_COPIED(oop)) {				  \
    _gst_copy_an_oop(oop);				  \
  }							  \
} while(0)

/* Mark the OOP object because it is part of the root set.  Integers
   and already-marked OOPs are not processed silently.  */
#define MAYBE_MARK_OOP(oop) do {			  \
  if (IS_OOP(oop) && !IS_OOP_MARKED(oop)) {		  \
    _gst_mark_an_oop_internal((oop));			  \
  }							  \
} while(0)

#define IS_OOP_COPIED(oop) \
  (IS_INT(oop) || IS_OOP_VALID_GC (oop))

#define IS_OOP_NEW(oop) \
  (((oop)->flags & F_SPACES) != 0)

/* This can only be used at the start or the end of an incremental
   GC cycle.  */
#define IS_OOP_VALID_GC(oop) \
  (((oop)->flags & _gst_mem.live_flags) != 0)

/* After a global GC, the live_flags say that an object is live
   if it is marked reachable.  Old objects that have already survived
   the incremental sweep pass, however, are not marked as reachable.  */
#define IS_OOP_VALID(oop) \
  ((oop)->flags & _gst_mem.live_flags \
   || (((oop)->flags & F_OLD) \
       && ((oop) <= _gst_mem.last_swept_oop \
	   || (oop) > _gst_mem.next_oop_to_sweep)))

#define IS_OOP_MARKED(oop) \
  (((oop)->flags & F_REACHABLE) != 0)

#define IS_OOP_FREE(oop) \
  ((oop)->flags == 0)

/* Checks to see if INDEX (a long index into the OOP table, 1 based
   due to being called from Smalltalk via a primitive) represents a
   valid OOP.  Returns true if so.  */
#define OOP_INDEX_VALID(index) \
  ((index) >= FIRST_OOP_INDEX && (index) < _gst_mem.ot_size)

/* Answer the INDEX-th OOP in the table.  */
#define OOP_AT(index) \
  ( &_gst_mem.ot[index] )

/* Answer the index of OOP in the table.  */
#define OOP_INDEX(oop) \
  ( (OOP)(oop) - _gst_mem.ot )

/* Answer whether OOP is a builtin OOP (a Character, true, false, nil).  */
#define IS_BUILTIN_OOP(oop) \
  ( (OOP)(oop) - _gst_mem.ot < 0 )

/* Set the indirect object pointer OOP to point to OBJ.  */
#define SET_OOP_OBJECT(oop, obj) do {				\
  (oop)->object = (gst_object) (obj);				\
} while(0)

/* Answer whether ADDR is part of the OOP table.  */
#define IS_OOP_ADDR(addr)					\
  ((OOP)(addr) >= _gst_mem.ot_base 	 			\
    && (OOP)(addr) <= _gst_mem.last_allocated_oop		\
    && (((intptr_t)addr & (sizeof (struct oop_s) - 1)) == 0))

/* Answer whether ADDR is part of newspace.  */
#define IS_EDEN_ADDR(addr)					\
  ((OOP *)(addr) >= _gst_mem.eden.minPtr && 			\
   (OOP *)(addr) < _gst_mem.eden.maxPtr)

/* Answer whether ADDR is part of survivor space N.  */
#define IS_SURVIVOR_ADDR(addr, n)				\
  ((OOP *)(addr) >= _gst_mem.surv[(n)].minPtr && 		\
   (OOP *)(addr) < _gst_mem.surv[(n)].maxPtr)

#define INC_ADD_OOP(oop)					\
  ((_gst_mem.inc_ptr >= _gst_mem.inc_end ?			\
    _gst_inc_grow_registry() : (void)0),			\
    *_gst_mem.inc_ptr++ = (oop))

#define INC_SAVE_POINTER()					\
  (_gst_mem.inc_ptr - _gst_mem.inc_base)

#define INC_RESTORE_POINTER(ptr)				\
  _gst_mem.inc_ptr = (ptr) + _gst_mem.inc_base;




static inline void
maybe_release_xlat (OOP oop)
{
#if defined(ENABLE_JIT_TRANSLATION)
  if (oop->flags & F_XLAT)
    {
      if (oop->flags & F_XLAT_REACHABLE)
	/* Reachable, and referenced by active contexts.  Keep it
    	   around.  */
       	oop->flags &= ~F_XLAT_2NDCHANCE;
      else
	{
    	  /* Reachable, but not referenced by active contexts.  We
    	     give it a second chance...  */
	  if (oop->flags & F_XLAT_2NDCHANCE)
    	    _gst_release_native_code (oop);

	  oop->flags ^= F_XLAT_2NDCHANCE;
      	}
    }
#endif
}

/* Given an object OBJ, allocate an OOP table slot for it and returns
   it.  It marks the OOP so that it indicates the object is in new
   space, and that the oop has been referenced on this pass (to keep
   the OOP table reaper from reclaiming this OOP).  */
static inline OOP
alloc_oop (PTR objData, intptr_t flags)
{
  REGISTER (1, OOP oop);
  REGISTER (2, OOP lastOOP);
  oop = _gst_mem.last_swept_oop + 1;
  lastOOP = _gst_mem.next_oop_to_sweep;
  if (COMMON (oop <= lastOOP))
    {
      while (IS_OOP_VALID_GC (oop))
	{
	  maybe_release_xlat (oop);
	  oop->flags &= ~F_REACHABLE;
	  if (oop >= lastOOP)
	    {
	      _gst_finished_incremental_gc ();
	      goto fast;
	    }
	  oop++;
	}
      _gst_sweep_oop (oop);
      if (oop >= lastOOP)
	_gst_finished_incremental_gc ();
    }
  else
    while (IS_OOP_VALID_GC (oop))
      {
       fast:
	oop++;
      }

  _gst_mem.last_swept_oop = oop;
  PREFETCH_LOOP (oop, PREF_READ);

  /* Force a GC as soon as possible if we're low on OOPs.  */
  if UNCOMMON (_gst_mem.num_free_oops-- < LOW_WATER_OOP_THRESHOLD)
    _gst_mem.eden.maxPtr = _gst_mem.eden.allocPtr;
  if (oop > _gst_mem.last_allocated_oop)
    _gst_mem.last_allocated_oop = oop;

  oop->object = (gst_object) objData;
  oop->flags = flags;
  return (oop);
}
