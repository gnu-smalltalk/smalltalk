/******************************** -*- C -*- ****************************
 *
 *	External definitions for C - Smalltalk interface module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008,2009
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



#ifndef GST_CINT_H
#define GST_CINT_H

typedef enum
{				/* types for C parameters */
  CDATA_CHAR,
  CDATA_UCHAR,
  CDATA_SHORT,
  CDATA_USHORT,
  CDATA_LONG,
  CDATA_ULONG,
  CDATA_FLOAT,
  CDATA_DOUBLE,
  CDATA_STRING,
  CDATA_OOP,			/* no conversion to-from C (OOP) */
  CDATA_INT,
  CDATA_UINT,
  CDATA_LONG_DOUBLE,

  CDATA_UNKNOWN,		/* when there is no type a priori */
  CDATA_STRING_OUT,		/* for things that modify string params */
  CDATA_SYMBOL,
  CDATA_BYTEARRAY,
  CDATA_BYTEARRAY_OUT,
  CDATA_BOOLEAN,
  CDATA_VOID,			/* valid only as a return type */
  CDATA_VARIADIC,		/* for parameters, this param is an
				   array to be interpreted as
				   arguments.  Note that only simple
				   conversions are performed in this
				   case.  */
  CDATA_VARIADIC_OOP,		/* for parameters, this param is an
				   array whose elements are OOPs to be
				   passed.  */
  CDATA_COBJECT,		/* a C object is being passed */
  CDATA_COBJECT_PTR,		/* a C object pointer is being passed */
  CDATA_SELF,			/* pass self as the corresponding
				   argument */
  CDATA_SELF_OOP,		/* pass self as an OOP */
  CDATA_WCHAR,
  CDATA_WSTRING,
  CDATA_WSTRING_OUT,
  CDATA_SYMBOL_OUT,
  CDATA_LONGLONG,
  CDATA_ULONGLONG
}
cdata_type;

/* Value of errno which is checked by the Smalltalk base classes.  */
extern int _gst_errno 
  ATTRIBUTE_HIDDEN;

typedef struct gst_c_callable
{
  OBJ_HEADER;
  OOP typeOOP;		        /* CObject fields */ 
  OOP storageOOP;	        /* CObject fields */ 
  OOP returnTypeOOP;            /* Smalltalk return type */
  OOP argTypesOOP;		/* array of argument types */
  OOP blockOOP;			/* only for CCallbackDescriptor */
}
 *gst_c_callable;

/* Returns the size of an object passed to a C routine with type TYPE.  */
extern int _gst_c_type_size (int type);

/* Called after GC to invalidate the cache for the libffi representation
   of CFunctionDescriptors.  */
extern void _gst_invalidate_croutine_cache (void);

/* Invokes a C routine.  Arguments passed from Smalltalk are stored starting
   from ARGS, and the object to which the message that called-out was
   sent is RECEIVER.  CFUNCOOP is the C function descriptor used
   to control the mapping of argument types from Smalltalk to C types
   and determines the mapping of the C function's return type into a
   Smalltalk type.  The result is NULL if the call was not successful,
   an OOP holding the result otherwise.  */
extern OOP _gst_invoke_croutine (OOP cFuncOOP,
				 OOP receiver,
				 OOP *args) 
  ATTRIBUTE_HIDDEN;

/* Defines the mapping between a string function name FUNCNAME and the
   address FUNCADDR of that function, for later use in
   lookup_function.  The mapping table will expand as needed to
   hold new entries as they are added.  */
extern void _gst_define_cfunc (const char *funcName, PTR funcAddr) 
  ATTRIBUTE_HIDDEN;

/* Adds to the mapping table the standard C functions supported by
   GNU Smalltalk.  */
extern void _gst_init_cfuncs (void) 
  ATTRIBUTE_HIDDEN;

/* Set the value of errno which is checked by Smalltalk to be errnum.  */
extern void _gst_set_errno(int errnum) 
  ATTRIBUTE_HIDDEN;

/* Returns the address for the latest C function which has been
   registered using _gst_define_cfunc with the name FUNCNAME.  Returns
   NULL if there is no such function.  */
extern PTR _gst_lookup_function (const char *funcName)
  ATTRIBUTE_HIDDEN;

/* Creates a closure for the CCallbackDescriptor CALLBACKOOP and stores it
   in the object.  */
extern void _gst_make_closure (OOP callbackOOP)
  ATTRIBUTE_HIDDEN;

/* Frees the info for the closure in the CCallbackDescriptor CALLBACKOOP.  */
extern void _gst_free_closure (OOP callbackOOP)
  ATTRIBUTE_HIDDEN;

/* Call lt_dlopenext with FILENAME, and invoke gst_initModule if it is
   found in the library.  If MODULE is false, add the file to the list
   of libraries that Smalltalk searches for external symbols.  */
extern mst_Boolean _gst_dlopen (const char *filename, mst_Boolean module);

/* Add DIR at the beginning of the libltdl search path.  */
extern void _gst_dladdsearchdir (const char *dir)
  ATTRIBUTE_HIDDEN;

/* Push the current libltdl search path.  */
extern void _gst_dlpushsearchpath (void)
  ATTRIBUTE_HIDDEN;

/* Pop the saved search path into the current libltdl search path.  */
extern void _gst_dlpopsearchpath (void)
  ATTRIBUTE_HIDDEN;

#endif /* GST_CINT_H */
