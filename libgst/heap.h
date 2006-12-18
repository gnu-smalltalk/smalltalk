/******************************** -*- C -*- ****************************
 *
 *	Header for memory allocation within separate mmap'ed regions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2006 Free Software Foundation, Inc.
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


#ifndef GST_HEAP_H
#define GST_HEAP_H

typedef char *heap;

/* Initialize access to a heap managed region of the given SIZE, trying
   to put it at the specified address.

   On success, returns a "heap descriptor" which is used in subsequent
   calls to other heap package functions.  It is explicitly "char *"
   so that users of the package don't have to worry about the actual
   implementation details.

   On failure returns NULL.  */
extern heap _gst_heap_create (PTR address, int size) 
  ATTRIBUTE_HIDDEN;

/* Terminate access to a heap managed region by unmapping all memory pages
   associated with the region, and closing the file descriptor if it is one
   that we opened.
  
   Returns NULL on success.
  
   Returns the heap descriptor on failure, which can subsequently be used
   for further action.  */
extern heap _gst_heap_destroy (heap hd) 
  ATTRIBUTE_HIDDEN;

/* Get core for the memory region specified by HD, using SIZE as the
   amount to either add to or subtract from the existing region.  Works
   like sbrk(), but using mmap() if HD is not NULL.  */
extern PTR _gst_heap_sbrk (heap hd,
			   size_t size) 
  ATTRIBUTE_HIDDEN;

#endif /* GST_HEAP_H */
