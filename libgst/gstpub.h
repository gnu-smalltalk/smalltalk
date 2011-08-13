/******************************** -*- C -*- ****************************
 *
 *	Public definitions for extensions to Smalltalk.
 *
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008,2009
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


#ifndef GST_GSTPUB_H
#define GST_GSTPUB_H

/* cfront 1.2 defines "c_plusplus" instead of "__cplusplus" */
#if defined(c_plusplus) && !defined(__cplusplus)
#define __cplusplus c_plusplus
#endif

#ifdef __cplusplus
#include <cstddef>
#include <cstdio>
extern "C"
{
#else

#include <stddef.h>
#include <stdio.h>
#endif

#include "gst.h"


typedef struct VMProxy
{
  OOP nilOOP, trueOOP, falseOOP;

  OOP (*msgSend) (OOP receiver,
		  OOP selector, 
		  ...);
  OOP (*vmsgSend) (OOP receiver,
		   OOP selector,
		   OOP * args);
  OOP (*nvmsgSend) (OOP receiver,
		    OOP selector,
		    OOP * args,
		    int nargs);
    
  OOP (*strMsgSend) (OOP receiver,
		     const char * selector,
		     ...);
  void (*msgSendf) (PTR resultPtr,
		    const char *fmt,
		    ...);
  OOP (*evalExpr) (const char *str);
  void (*evalCode) (const char *str);

  OOP (*objectAlloc) (OOP classOOP,
		      int size);
  int (*basicSize) (OOP oop);
  
  /* Actually funcAddr is a function pointer, but we don't know the
     returned type so we must declare it as PTR */
  void (*defineCFunc) (const char *funcName,
		       PTR funcAddr);
  OOP (*registerOOP) (OOP oop);
  void (*unregisterOOP) (OOP oop);

  /* Convert C datatypes to Smalltalk types */
  
  OOP (*idToOOP) (long i);
  OOP (*intToOOP) (long i);
  OOP (*floatToOOP) (double f);
  OOP (*boolToOOP) (int b);
  OOP (*charToOOP) (char c);
  OOP (*classNameToOOP) (const char *name);
  OOP (*stringToOOP) (const char *str);
  OOP (*byteArrayToOOP) (const char *str,
			 int n);
  OOP (*symbolToOOP) (const char *str);
  OOP (*cObjectToOOP) (PTR co);
  OOP (*typeNameToOOP) (const char *name);
  void (*setCObject) (OOP oop, PTR co);

  /* Convert Smalltalk datatypes to C data types */

  long (*OOPToC) (OOP oop);	/* sometimes answers a PTR */
  long (*OOPToId) (OOP oop);
  long (*OOPToInt) (OOP oop);
  double (*OOPToFloat) (OOP oop);
  int (*OOPToBool) (OOP oop);
  char (*OOPToChar) (OOP oop);
  char *(*OOPToString) (OOP oop);
  char *(*OOPToByteArray) (OOP oop);
  PTR (*OOPToCObject) (OOP oop);

  /* Smalltalk process support */
  void (*asyncSignal) (OOP semaphoreOOP);
  void (*syncWait) (OOP semaphoreOOP);
  void (*asyncSignalAndUnregister) (OOP semaphoreOOP);

  /* Array-of-OOP registry support.  Move these above
     when we break binary compatibility.  */
  void (*registerOOPArray) (OOP **first, OOP **last);
  void (*unregisterOOPArray) (OOP **first);

  /* More conversions.  */
  long double (*OOPToLongDouble) (OOP oop);
  OOP (*longDoubleToOOP) (long double f);

  /* More functions, added in 2.2.  */
  OOP (*getObjectClass) (OOP oop);
  OOP (*getSuperclass) (OOP oop);
  mst_Boolean (*classIsKindOf) (OOP oop,
				OOP candidate);
  mst_Boolean (*objectIsKindOf) (OOP oop,
				 OOP candidate);
  OOP (*perform) (OOP oop,
		  OOP selector);
  OOP (*performWith) (OOP oop,
		      OOP selector,
		      OOP arg);
  mst_Boolean (*classImplementsSelector) (OOP classOOP,
					  OOP selector);
  mst_Boolean (*classCanUnderstand) (OOP classOOP,
				     OOP selector);
  mst_Boolean (*respondsTo) (OOP oop,
			     OOP selector);
  size_t (*OOPSize) (OOP oop);
  OOP (*OOPAt) (OOP oop,
		size_t index);
  OOP (*OOPAtPut) (OOP oop,
		   size_t index,
		   OOP newOOP);

  /* Some system classes.  */
  OOP objectClass, arrayClass, stringClass, characterClass, smallIntegerClass,
    floatDClass, floatEClass, byteArrayClass, objectMemoryClass, classClass,
    behaviorClass, blockClosureClass, contextPartClass, blockContextClass,
    methodContextClass, compiledMethodClass, compiledBlockClass,
    fileDescriptorClass, fileStreamClass, processClass, semaphoreClass,
    cObjectClass;

  /* More system objects.  */
  OOP processorOOP;

  /* More functions, added in 2.3.  */
  OOP (*wcharToOOP) (wchar_t wc);
  OOP (*wstringToOOP) (const wchar_t *str);
  wchar_t (*OOPToWChar) (OOP oop);
  wchar_t *(*OOPToWString) (OOP oop);

  /* 3.0+ functions.  */
  void (*processStdin) (const char *);
  mst_Boolean (*processFile) (const char *fileName, enum gst_file_dir dir);
  int (*getVar) (enum gst_var_index index);
  int (*setVar) (enum gst_var_index index, int value);
  void (*invokeHook) (enum gst_vm_hook);

  /* 3.1+ functions.  */
  char *(*relocatePath) (const char *);
  void *(*OOPIndexedBase) (OOP oop);
  enum gst_indexed_kind (*OOPIndexedKind) (OOP oop); 
  void (*asyncCall) (void (*func) (OOP), OOP argOOP);
  mst_Boolean (*syncSignal) (OOP semaphoreOOP, mst_Boolean incrIfEmpty);
  void (*showBacktrace) (FILE *fp);

  /* 3.2+ functions.  */
  mst_Boolean (*dlOpen) (const char *filename, mst_Boolean module);
  void (*dlAddSearchDir) (const char *dir);
  void (*dlPushSearchPath) (void);
  void (*dlPopSearchPath) (void);
  void (*wakeUp) (void);

  /* 3.2.5+ functions.  */
  OOP (*uintToOOP) (unsigned long i);

  /* 3.3+ functions.  */
  mst_Boolean (*setEventLoopHandlers)(mst_Boolean (*poll) (int ms),
				      void (*dispatch) (void));
} VMProxy;

/* Compatibility section */
#define indexedWord(obj, n)   INDEXED_WORD(obj, n)
#define indexedByte(obj, n)   INDEXED_BYTE(obj, n)
#define indexedOOP(obj, n)    INDEXED_OOP(obj, n)
#define arrayOOPAt(obj, n)    ARRAY_OOP_AT(obj, n)
#define stringOOPAt(obj, n)   STRING_OOP_AT(obj, n)
#define oopToObj(oop)         OOP_TO_OBJ(oop)
#define oopClass(oop)         OOP_CLASS(oop)
#define isInt(oop)            IS_INT(oop)
#define isOOP(oop)            IS_OOP(oop)

/* These are extern in case one wants to link to libgst.a; these
   are not meant to be called by a module, which is brought up by
   GNU Smalltalk when the VM is already up and running.  */

/* These are the library counterparts of the functions in files.h.  */
extern void gst_smalltalk_args (int argc, const char **argv);
extern int gst_initialize (const char *kernel_dir,
			   const char *image_file,
			   int flags);

/* Functions in input.h.  */
extern void gst_process_stdin (const char *prompt);
extern mst_Boolean gst_process_file (const char *fileName, enum gst_file_dir dir);

/* Functions in interp.h.  */
extern int gst_get_var (enum gst_var_index index);
extern int gst_set_var (enum gst_var_index index, int value);

/* Functions in comp.h.  */
extern void gst_invoke_hook (enum gst_vm_hook);

/* Functions in sysdep.h.  */
extern void gst_set_executable_path (const char *);
extern char *gst_relocate_path (const char *);

/* Functions in cint.h.  */
extern mst_Boolean gst_dlopen (const char *filename, mst_Boolean module);

/* Add DIR at the beginning of the libltdl search path.  */
extern void gst_dladdsearchdir (const char *dir);

/* Push the current libltdl search path.  */
extern void gst_dlpushsearchpath (void);

/* Pop the saved search path into the current libltdl search path.  */
extern void gst_dlpopsearchpath (void);

/* These are the library counterparts of the functions in
   gst_vm_proxy.  */
extern OOP gst_msg_send (OOP receiver, OOP selector, ...);
extern OOP gst_vmsg_send (OOP receiver, OOP selector, OOP * args);
extern OOP gst_nvmsg_send (OOP receiver, OOP selector, OOP * args, int nargs);
extern OOP gst_str_msg_send (OOP receiver, const char * selector, ...);
extern void gst_msg_sendf (PTR result_ptr, const char *fmt, ...);
extern OOP gst_eval_expr (const char *str);
extern void gst_eval_code (const char *str);
extern OOP gst_object_alloc (OOP class_oop, int size);
extern int gst_basic_size (OOP oop);
extern void gst_define_cfunc (const char *func_name, PTR func_addr);
extern OOP gst_register_oop (OOP oop);
extern void gst_unregister_oop (OOP oop);
extern OOP gst_id_to_oop (long i);
extern OOP gst_int_to_oop (long i);
extern OOP gst_uint_to_oop (unsigned long i);
extern OOP gst_float_to_oop (double f);
extern OOP gst_bool_to_oop (int b);
extern OOP gst_char_to_oop (char c);
extern OOP gst_class_name_to_oop (const char *name);
extern OOP gst_string_to_oop (const char *str);
extern OOP gst_byte_array_to_oop (const char *str, int n);
extern OOP gst_symbol_to_oop (const char *str);
extern OOP gst_c_object_to_oop (PTR co);
extern OOP gst_type_name_to_oop (const char *name);
extern void gst_set_c_o_bject (OOP oop, PTR co);
extern long gst_oop_to_c (OOP oop);	/* sometimes answers a PTR */
extern long gst_oop_to_id (OOP oop);
extern long gst_oop_to_int (OOP oop);
extern double gst_oop_to_float (OOP oop);
extern int gst_oop_to_bool (OOP oop);
extern char gst_oop_to_char (OOP oop);
extern char *gst_oop_to_string (OOP oop);
extern char *gst_oop_to_byte_array (OOP oop);
extern PTR gst_oop_to_c_object (OOP oop);
extern void gst_async_signal (OOP semaphore_oop);
extern void gst_async_call (void (*func) (OOP), OOP arg_oop);
extern mst_Boolean gst_sync_signal (OOP semaphore_oop, mst_Boolean incr_if_empty);
extern void gst_sync_wait (OOP semaphore_oop);
extern void gst_wakeup (void);
extern void gst_show_backtrace (FILE *fp);
extern void gst_async_signal_and_unregister (OOP semaphore_oop);
extern void gst_register_oop_array (OOP **first, OOP **last);
extern void gst_unregister_oop_array (OOP **first);
extern long double gst_oop_to_long_double (OOP oop);
extern OOP gst_long_double_to_oop (long double f);
extern OOP gst_get_object_class (OOP oop);
extern OOP gst_get_superclass (OOP oop);
extern mst_Boolean gst_class_is_kind_of (OOP oop, OOP candidate);
extern mst_Boolean gst_object_is_kind_of (OOP oop, OOP candidate);
extern void gst_set_c_object (OOP oop, PTR co);
extern OOP gst_perform (OOP oop, OOP selector);
extern OOP gst_perform_with (OOP oop, OOP selector, OOP arg);
extern mst_Boolean gst_class_implements_selector (OOP class_oop, OOP selector);
extern mst_Boolean gst_class_can_understand (OOP class_oop, OOP selector);
extern mst_Boolean gst_responds_to (OOP oop, OOP selector);
extern size_t gst_oop_size (OOP oop);
extern OOP gst_oop_at (OOP oop, size_t index);
extern OOP gst_oop_at_put (OOP oop, size_t index, OOP new_oop); 
extern void *gst_oop_indexed_base (OOP oop);
extern enum gst_indexed_kind gst_oop_indexed_kind (OOP oop); 
extern OOP gst_wchar_to_oop (wchar_t c);
extern OOP gst_wstring_to_oop (const wchar_t *str);
extern wchar_t gst_oop_to_wchar (OOP oop);
extern wchar_t *gst_oop_to_wstring (OOP oop);

extern mst_Boolean gst_set_event_loop_handlers(mst_Boolean (*poll) (int ms),
					       void (*dispatch) (void));

/* This is exclusively for programs who link with libgst.a; plugins
   should not use this VMProxy but rather the one they receive in
   gst_initModule.  */
extern VMProxy gst_interpreter_proxy;

#ifdef __cplusplus
}
#endif

#endif /* GST_GSTPUB_H */
