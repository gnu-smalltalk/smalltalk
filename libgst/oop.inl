/******************************** -*- C -*- ****************************
 *
 *	Object table module Inlines.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
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

/* Mark the OOPs starting at STARTOOP (included) and ending at ENDOOP
   (excluded).  */
#define COPY_OOP_RANGE(startOOP, endOOP) do {		  \
  if ((startOOP) < (endOOP)) {				  \
    _gst_copy_oop_range((startOOP), (endOOP));		  \
  }							  \
} while(0)

/* Mark the OOP object because it is part of the root set.  Integers
   and already-marked OOPs are not processed silently.  */
#define MAYBE_MARK_OOP(oop) do {			  \
  if (IS_OOP(oop) && !IS_OOP_MARKED(oop)) {		  \
    _gst_mark_an_oop_internal((oop), NULL, NULL);	  \
  }							  \
} while(0)

/* Mark the OOPs starting at STARTOOP (included) and ending at ENDOOP
   (excluded).  */
#define MARK_OOP_RANGE(startOOP, endOOP) do {		  \
  if ((startOOP) < (endOOP)) {				  \
    _gst_mark_an_oop_internal(NULL, (startOOP), (endOOP));\
  }							  \
} while(0)

#define IS_OOP_COPIED(oop) \
  (IS_INT(oop) || IS_OOP_VALID_GC (oop))

#define IS_OOP_NEW(oop) \
  ((oop)->flags & F_SPACES)

/* This can only be used at the start or the end of an incremental
   GC cycle.  */
#define IS_OOP_VALID_GC(oop) \
  ((oop)->flags & _gst_mem.live_flags)

/* After a global GC, the live_flags say that an object is live
   if it is marked reachable.  Old objects that have already survived
   the incremental sweep pass, however, are not marked as reachable.  */
#define IS_OOP_VALID(oop) \
  ((oop)->flags & _gst_mem.live_flags \
   || ((oop) <= _gst_mem.last_swept_oop && !IS_OOP_NEW (oop)))

#define IS_OOP_MARKED(oop) \
  ((oop)->flags & F_REACHABLE)

#define IS_OOP_FREE(oop) \
  ((oop)->flags & F_FREE)

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
  (oop)->object = (mst_Object) (obj);				\
} while(0)

/* Answer whether ADDR is part of the OOP table.  */
#define IS_OOP_ADDR(addr)					\
  ((OOP)(addr) >= _gst_mem.ot_base 	 			\
    && (OOP)(addr) <= _gst_mem.last_allocated_oop		\
    && (((intptr_t)addr & (sizeof (struct OOP) - 1)) == 0))

/* Answer whether ADDR is part of newspace.  */
#define IS_EDEN_ADDR(addr)					\
  ((OOP *)(addr) >= _gst_mem.eden.minPtr && 			\
   (OOP *)(addr) < _gst_mem.eden.maxPtr)

/* Answer whether ADDR is part of survivor space N.  */
#define IS_SURVIVOR_ADDR(addr, n)				\
  ((OOP *)(addr) >= _gst_mem.surv[(n)].minPtr && 		\
   (OOP *)(addr) < _gst_mem.surv[(n)].maxPtr)

/* Return the Character object for ASCII value C.  */
#define CHAR_OOP_AT(c)      (&_gst_mem.ot[(c) + CHAR_OBJECT_BASE])

/* Return the ASCII value corresponding to the Character object
   OOP.  */
#define CHAR_OOP_VALUE(oop) ((oop) - &_gst_mem.ot[CHAR_OBJECT_BASE])

#define INC_ADD_OOP(oop)					\
  ((_gst_mem.inc_ptr >= _gst_mem.inc_end ?			\
    _gst_inc_grow_registry() : (void)0),			\
    *_gst_mem.inc_ptr++ = (oop))

#define INC_SAVE_POINTER()					\
  (_gst_mem.inc_ptr - _gst_mem.inc_base)

#define INC_RESTORE_POINTER(ptr)				\
  _gst_mem.inc_ptr = (ptr) + _gst_mem.inc_base;




/* Given an object OBJ, allocate an OOP table slot for it and returns
   it.  It marks the OOP so that it indicates the object is in new
   space, and that the oop has been referenced on this pass (to keep
   the OOP table reaper from reclaiming this OOP).  */
static inline OOP
alloc_oop (PTR objData, intptr_t flags)
{
  REGISTER (1, OOP oop);
  mst_Object obj;

  obj = (mst_Object) objData;

  if UNCOMMON (_gst_mem.last_allocated_oop ==
		_gst_mem.last_swept_oop)
    {
      oop = ++_gst_mem.last_allocated_oop;
      ++_gst_mem.last_swept_oop;
    }
  else
    {
      for (oop = _gst_mem.last_swept_oop;
           ++oop, IS_OOP_VALID (oop);
	   oop->flags &= ~F_REACHABLE)
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
#else
        ;
#endif

      if (oop > _gst_mem.last_allocated_oop)
        _gst_mem.last_allocated_oop = oop;

      _gst_sweep_oop (oop);
      PREFETCH_LOOP (oop, PREF_READ);
    }

  /* Force a GC as soon as possible if we're low on OOPs.  */
  if UNCOMMON (_gst_mem.num_free_oops-- < LOW_WATER_OOP_THRESHOLD)
    _gst_mem.eden.maxPtr = _gst_mem.eden.allocPtr;

  oop->object = obj;
  oop->flags = flags;

  return (oop);
}
