/******************************** -*- C -*- ****************************
 *
 *	Public definitions for extensions to Smalltalk.
 *
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/


#ifndef GST_GSTPUB_H
#define GST_GSTPUB_H

/* cfront 1.2 defines "c_plusplus" instead of "__cplusplus" */
#if defined(c_plusplus) && !defined(__cplusplus)
#define __cplusplus c_plusplus
#endif

#ifdef __cplusplus
extern "C"
{
#endif

#include "gst.h"

#ifndef __PROTO
# ifndef __STDC__
#  define __PROTO(args) ()
# else
#  define __PROTO(args) args
# endif
#endif

typedef struct VMProxy
{
  OOP nilOOP, trueOOP, falseOOP;

  OOP (*msgSend) __PROTO ((OOP receiver,
			   OOP selector, 
			   ...));
  OOP (*vmsgSend) __PROTO ((OOP receiver,
			    OOP selector,
			    OOP * args));
  OOP (*nvmsgSend) __PROTO ((OOP receiver,
			     OOP selector,
			     OOP * args,
			     int nargs));
    
  OOP (*strMsgSend) __PROTO ((OOP receiver,
			      const char * selector,
			      ...));
  void (*msgSendf) __PROTO ((PTR resultPtr,
			     const char *fmt,
			     ...));
  OOP (*evalExpr) __PROTO ((const char *str));
  void (*evalCode) __PROTO ((const char *str));

  OOP (*objectAlloc) __PROTO ((OOP classOOP,
			       int size));
  int (*basicSize) __PROTO ((OOP oop));
  
  /* Actually funcAddr is a function pointer, but we don't know the
     returned type so we must declare it as PTR */
  void (*defineCFunc) __PROTO ((const char *funcName,
				PTR funcAddr));
  OOP (*registerOOP) __PROTO ((OOP oop));
  void (*unregisterOOP) __PROTO ((OOP oop));

  /* Convert C datatypes to Smalltalk types */
  
  OOP (*idToOOP) __PROTO ((long i));
  OOP (*intToOOP) __PROTO ((long i));
  OOP (*floatToOOP) __PROTO ((double f));
  OOP (*boolToOOP) __PROTO ((int b));
  OOP (*charToOOP) __PROTO ((char c));
  OOP (*classNameToOOP) __PROTO ((const char *name));
  OOP (*stringToOOP) __PROTO ((const char *str));
  OOP (*byteArrayToOOP) __PROTO ((const char *str,
				  int n));
  OOP (*symbolToOOP) __PROTO ((const char *str));
  OOP (*cObjectToOOP) __PROTO ((PTR co));
  OOP (*typeNameToOOP) __PROTO ((const char *name));
  void (*setCObject) __PROTO ((OOP oop, PTR co));

  /* Convert Smalltalk datatypes to C data types */

  long (*OOPToC) __PROTO ((OOP oop));	/* sometimes answers a PTR */
  long (*OOPToId) __PROTO ((OOP oop));
  long (*OOPToInt) __PROTO ((OOP oop));
  double (*OOPToFloat) __PROTO ((OOP oop));
  int (*OOPToBool) __PROTO ((OOP oop));
  char (*OOPToChar) __PROTO ((OOP oop));
  char *(*OOPToString) __PROTO ((OOP oop));
  char *(*OOPToByteArray) __PROTO ((OOP oop));
  PTR (*OOPToCObject) __PROTO ((OOP oop));

  /* Smalltalk process support */
  void (*asyncSignal) __PROTO ((OOP semaphoreOOP));
  void (*syncWait) __PROTO ((OOP semaphoreOOP));
  void (*asyncSignalAndUnregister) __PROTO ((OOP semaphoreOOP));

  /* Array-of-OOP registry support.  Move these above
     when we break binary compatibility. */
  void (*registerOOPArray) __PROTO ((OOP **first, OOP **last));
  void (*unregisterOOPArray) __PROTO ((OOP **first));
} VMProxy;

#define INDEXED_WORD(obj, n)   ( ((long *) ((obj) + 1))		    [(n)-1] )
#define INDEXED_BYTE(obj, n)   ( ((char *) ((obj) + 1))		    [(n)-1] )
#define INDEXED_OOP(obj, n)    ( ((OOP  *) ((obj) + 1))		    [(n)-1] )
#define ARRAY_OOP_AT(obj, n)   ( ((OOP  *) ((mst_Object) obj)->data) [(n)-1] )
#define STRING_OOP_AT(obj, n)  ( ((char *) ((mst_Object) obj)->data) [(n)-1] )

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
   GNU Smalltalk when the VM is already up and running. */

/* This loads the image and prepares the Smalltalk environment.
   Return -1 if the Smalltalk main loop should not be run but
   without returning an erroneous exit code, 0 if it should be
   run, and >0 if there was an error (such as the inability
   to bootstrap). */
extern int gst_init_smalltalk __PROTO ((void));

/* This sets the arguments to be passed to the Smalltalk library,
   which are the same that are available by the `gst' executable. */
extern void gst_smalltalk_args __PROTO ((int argc,
					 char **argv));

/* This processes files passed to gst_smalltalk_args and, if none
   was passed, stdin is looked for input. */
extern void gst_top_level_loop __PROTO ((void));

/* This is exclusively for programs who link with libgst.a; plugins
   should not use this VMProxy but rather the one they receive in
   gst_initModule. */
extern VMProxy gst_interpreter_proxy;

#ifdef __cplusplus
}
#endif

#undef __PROTO

#endif /* GST_GSTPUB_H */
