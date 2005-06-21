/******************************** -*- C -*- ****************************
 *
 *	OOP printing and debugging declarations
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
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



#ifndef GST_PRINT_H
#define GST_PRINT_H

/* Print a representation of OOP on stdout.  For Strings, Symbols,
   Floats and SmallIntegers, this is the #storeString; for other
   objects it is a generic representation including the pointer to the
   OOP. */
extern void _gst_print_object (OOP oop);

/* Show information about the contents of the pointer ADDR, deciding
   what kind of Smalltalk entity it is.  Mainly provided for
   debugging.  */
void _gst_classify_addr (void *addr);

/* Show information about the contents of the given OOP.
   Mainly provided for debugging.  */
void _gst_display_oop (OOP oop);

/* Show information about the contents of the given OOP without
   dereferencing the pointer to the object data and to the class.
   Mainly provided for debugging.  */
void _gst_display_oop_short (OOP oop);

/* Show information about the contents of the OBJ object.
   Mainly provided for debugging.  */
void _gst_display_object (mst_Object obj);

/* Initialize the snprintfv library with hooks to print GNU Smalltalk
   OOPs. */
extern void _gst_init_snprintfv ();

#endif /* GST_OOP_H */
