/******************************** -*- C -*- ****************************
 *
 *	External definitions for C - Smalltalk interface module
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



#ifndef GST_CINT_H
#define GST_CINT_H

/* Value of errno which is checked by the Smalltalk base classes.  */
extern int _gst_errno;

/* Element type for the name-to-C-function mapping table. */
typedef void (*p_void_func) ();

/* Invokes a C routine.  Arguments passed from Smalltalk are stored starting
   from ARGS, and the object to which the message that called-out was
   sent is RECEIVER.  CFUNCOOP is the C function descriptor used
   to control the mapping of argument types from Smalltalk to C types
   and determines the mapping of the C function's return type into a
   Smalltalk type.  The result is NULL if the call was not successful,
   an OOP holding the result otherwise.  */
extern OOP _gst_invoke_croutine (OOP cFuncOOP,
				 OOP receiver,
				 OOP *args);

/* Defines the mapping between a string function name FUNCNAME and the
   address FUNCADDR of that function, for later use in
   _gst_lookup_function.  The mapping table will expand as needed to
   hold new entries as they are added. */
extern void _gst_define_cfunc (const char *funcName, PTR funcAddr);

/* Adds to the mapping table the standard C functions supported by
   GNU Smalltalk.  */
extern void _gst_init_cfuncs (void);

/* Returns the address of the latest C function which has been
   registered using _gst_define_cfunc with the name FUNCNAME.  Returns
   NULL if there is no such function. */
extern p_void_func _gst_lookup_function (const char *funcName);

/* This routine is called during image loading to restore a C function
   descriptor pointer.  This is because between the time that the image
   was made and now, the executable image may have changed, so any
   reference to the C function address may be invalid.  We therefore just
   perform the function lookup again and use that value.  CFUNCDESCOOP
   is the C function descriptor object to be adjusted, which contains
   the name of the function to be looked up. */
extern void _gst_restore_cfunc_descriptor (OOP cFuncDescOOP);

/* Makes a C based descriptor for a callout method.  Returns a
   gst_cfunc_descriptor object which holds onto the descriptor.  This
   descriptor is subsequently used when the called out function
   FUNCNAMEOOP (a Smalltalk String) is invoked. RETURNOOP is a Symbol
   or CType which indicates the return type and ARGSOOP is a Smalltalk
   Array containing the argument types (as Symbols). */
extern OOP _gst_make_descriptor (OOP funcNameOOP,
				 OOP returnTypeOOP,
				 OOP argsOOP);

/* Set the value of errno which is checked by Smalltalk to be errnum.  */
extern void _gst_set_errno(int errnum);

#endif /* GST_CINT_H */
