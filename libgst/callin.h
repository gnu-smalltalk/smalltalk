/******************************** -*- C -*- ****************************
 *
 *	External definitions for C callin module
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/



#ifndef GST_CALLIN_H
#define GST_CALLIN_H


/* Sends SELECTOR (which should be a Symbol, otherwise _gst_nil_oop is
   returned) to RECEIVER.  The message arguments should also be OOPs
   (otherwise, an access violation exception is pretty likely) and are
   passed in a NULL-terminated list after the selector.  The value
   returned from the method is passed back as an OOP to the C program
   as the result of the function, or _gst_nil_oop if the number of
   arguments is wrong.  */
extern OOP _gst_msg_send (OOP receiver,
			  OOP selector, ...) 
  ATTRIBUTE_HIDDEN;

/* Sends SELECTOR (which should be a Symbol, otherwise _gst_nil_oop is
   returned) to RECEIVER.  The message arguments should also be OOPs
   (otherwise, an access violation exception is pretty likely) and are
   passed in a NULL-terminated list pointed to by ARGS.  The value
   returned from the method is passed back as an OOP to the C program
   as the result of the function, or _gst_nil_oop if the number of
   arguments is wrong.  */
extern OOP _gst_vmsg_send (OOP receiver,
			   OOP selector,
			   OOP * args) 
  ATTRIBUTE_HIDDEN;

/* Sends the SEL selector to RECEIVER.  The message arguments should
   also be OOPs (otherwise, an access violation exception is pretty
   likely) and are passed in a NULL-terminated list after the
   selector.  The value returned from the method is passed back as an
   OOP to the C program as the result of the function, or _gst_nil_oop
   if the number of arguments is wrong.  */
extern OOP _gst_str_msg_send (OOP receiver, const char * sel, ...) 
  ATTRIBUTE_HIDDEN;

/* See manual; basically it takes care of the conversion from C to
   Smalltalk data types.  */
extern void _gst_msg_sendf (PTR resultPtr, const char * fmt, ...) 
  ATTRIBUTE_HIDDEN;

/* Evaluate the Smalltalk code in STR and return the result as an OOP.
   STR is a Smalltalk method body which can have local variables, but
   no parameters.  This is much like the immediate expression
   evaluation that the command interpreter provides.  */
extern OOP _gst_eval_expr (const char *str) 
  ATTRIBUTE_HIDDEN;

/* Evaluate the Smalltalk code in STR, a Smalltalk method body which
   can have local variables, but no parameters.  This is much like the
   immediate expression evaluation that the command interpreter
   provides.  */
extern void _gst_eval_code (const char *str) 
  ATTRIBUTE_HIDDEN;

/* Puts the given OOP in the registry.  If you register an object
   multiple times, you will need to unregister it the same number of
   times.  You may want to register objects returned by Smalltalk
   call-ins.  */
extern OOP _gst_register_oop (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Removes an occurrence of the given OOP from the registry.  */
extern void _gst_unregister_oop (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Remember that an array of OOPs must be made part of the root set.
   The two parameters, FIRST and LAST, point to two variables
   containing respectively the base and the top of the array: the
   double indirection allows one to move the array freely in memory,
   for example using realloc.  */
extern void _gst_register_oop_array (OOP **first, OOP **last) 
  ATTRIBUTE_HIDDEN;

/* Unregister the given array of OOPs from the root set.  FIRST points
   to a variables containing the base of the array: the double
   indirection allows one to move the array freely in memory, for
   example using realloc.  */
extern void _gst_unregister_oop_array (OOP **first) 
  ATTRIBUTE_HIDDEN;

/* Allocates an OOP for a newly created instance of the class whose
   OOP is passed as the first parameter; if that parameter is not a
   class the results are undefined (for now, read as ``the program
   will most likely core dump'', but that could change in a future
   version).

   The second parameter is used only if the class is an indexable one,
   otherwise it is discarded: it contains the number of indexed
   instance variables in the object that is going to be created.  */
extern OOP _gst_object_alloc (OOP class_oop,
			      int size) 
  ATTRIBUTE_HIDDEN;

/* Returns the number of indexed instance variables in OOP */
extern int _gst_basic_size (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Convert C datatypes to Smalltalk types */
extern OOP _gst_id_to_oop (long i) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_int_to_oop (long i) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_float_to_oop (double f) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_bool_to_oop (int b) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_char_to_oop (char c) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_class_name_to_oop (const char *name) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_string_to_oop (const char *str) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_byte_array_to_oop (const char *str,
				   int n) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_symbol_to_oop (const char *str) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_c_object_to_oop (PTR co) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_type_name_to_oop (const char *name) 
  ATTRIBUTE_HIDDEN;
extern void _gst_set_c_object (OOP oop, PTR co) 
  ATTRIBUTE_HIDDEN;
extern OOP _gst_long_double_to_oop (long double f) 
  ATTRIBUTE_HIDDEN;

/* Convert Smalltalk datatypes to C data types */
extern long _gst_oop_to_c (OOP oop) 
  ATTRIBUTE_HIDDEN;	/* sometimes answers a PTR */
extern long _gst_oop_to_id (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern long _gst_oop_to_int (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern double _gst_oop_to_float (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern int _gst_oop_to_bool (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern char _gst_oop_to_char (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern char *_gst_oop_to_string (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern char *_gst_oop_to_byte_array (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern PTR _gst_oop_to_cobject (OOP oop) 
  ATTRIBUTE_HIDDEN;
extern long double _gst_oop_to_long_double (OOP oop) 
  ATTRIBUTE_HIDDEN;

/* Marks/copies the registered OOPs (they are part of the rootset by
   definition) */
extern void _gst_mark_registered_oops (void) 
  ATTRIBUTE_HIDDEN;
extern void _gst_copy_registered_oops (void) 
  ATTRIBUTE_HIDDEN;

/* Initializes the registry of OOPs which some C code is holding.  */
extern void _gst_init_oopregistry (void) 
  ATTRIBUTE_HIDDEN;

/* Initializes the VMProxy.  */
extern void _gst_init_vmproxy (void) 
  ATTRIBUTE_HIDDEN;

#endif /* GST_CALLIN_H */
