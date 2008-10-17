/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk generic inclusions.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008
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

#ifndef GST_GST_H
#define GST_GST_H

/* AIX is so broken that requires this to be the first thing in the file.  */
#if defined(_AIX)
#pragma alloca
#else
# if !defined(alloca)		/* predefined by HP cc +Olibcalls */
#  ifdef __GNUC__
#   define alloca(size) __builtin_alloca(size)
#  else
#   if HAVE_ALLOCA_H
#    include <alloca.h>
#   else
#    if defined(__hpux)
void *alloca ();
#    else
#     if !defined(__OS2__) && !defined(WIN32)
char *alloca ();
#     else
#      include <malloc.h>	/* OS/2 defines alloca in here */
#     endif
#    endif
#   endif
#  endif
# endif
#endif

/* Some compilers use different win32 definitions. Define WIN32 so we 
   have only to check for one symbol.  */
#if defined(_WIN32) || defined(__CYGWIN32__) || defined(__CYGWIN__) || defined(Win32) || defined(__WIN32)
#ifndef WIN32
#define WIN32 1
#endif
#endif

#ifdef _MSC_VER
/* Visual C++ does not define STDC */
#define __STDC__ 1
#endif

/* Defined as char * in traditional compilers, void * in
   standard-compliant compilers.  */
#ifndef PTR
#if !defined(__STDC__)
#define PTR char *
#else
#define PTR void *
#endif
#endif

/* A boolean type */
#ifdef __cplusplus
typedef bool mst_Boolean;
#else
typedef enum {
  false,
  true
} mst_Boolean;
#endif

/* An indirect pointer to object data.  */
typedef struct oop_s *OOP;

/* A direct pointer to the object data.  */
typedef struct object_s *gst_object, *mst_Object;

/* The contents of an indirect pointer to object data.  */
struct oop_s
{
  gst_object object;
  unsigned long flags;		/* FIXME, use uintptr_t */
};

/* The header of all objects in the system.
   Note how structural inheritance is achieved without adding extra levels of 
   nested structures.  */
#define OBJ_HEADER \
  OOP		objSize; \
  OOP		objClass


/* Just for symbolic use in sizeof's */
typedef struct gst_object_header
{
  OBJ_HEADER;
}
gst_object_header;

#define OBJ_HEADER_SIZE_WORDS	(sizeof(gst_object_header) / sizeof(PTR))

/* A bare-knuckles accessor for real objects */
struct object_s
{
  OBJ_HEADER;
  OOP data[1];			/* variable length, may not be objects, 
				   but will always be at least this
				   big.  */
};

/* Convert an OOP (indirect pointer to an object) to the real object
   data.  */
#define OOP_TO_OBJ(oop) \
  ((oop)->object)

/* Retrieve the class for the object pointed to by OOP.  OOP must be
   a real pointer, not a SmallInteger.  */
#define OOP_CLASS(oop) \
  (OOP_TO_OBJ(oop)->objClass)


/* Answer whether OOP is a SmallInteger or a `real' object pointer.  */
#define IS_INT(oop) \
  ((intptr_t)(oop) & 1)

/* Answer whether both OOP1 and OOP2 are SmallIntegers, or rather at
   least one of them a `real' object pointer.  */
#define ARE_INTS(oop1, oop2) \
  ((intptr_t)(oop1) & (intptr_t)(oop2) & 1)

/* Answer whether OOP is a `real' object pointer or rather a
   SmallInteger.  */
#define IS_OOP(oop) \
  (! IS_INT(oop) )

/* Keep these in sync with _gst_sizes, in dict.c.
   FIXME: these should be exported in a pool dictionary.  */
enum gst_indexed_kind {
  GST_ISP_FIXED = 0,
  GST_ISP_SCHAR = 32,
  GST_ISP_UCHAR = 34,
  GST_ISP_CHARACTER = 36,
  GST_ISP_SHORT = 38,
  GST_ISP_USHORT = 40,
  GST_ISP_INT = 42,
  GST_ISP_UINT = 44,
  GST_ISP_FLOAT = 46,
  GST_ISP_INT64 = 48,
  GST_ISP_UINT64 = 50,
  GST_ISP_DOUBLE = 52,
  GST_ISP_UTF32 = 54,
  GST_ISP_LAST_SCALAR = 54,
  GST_ISP_POINTER = 62,

#if SIZEOF_OOP == 8
  GST_ISP_LONG = GST_ISP_INT64,
  GST_ISP_ULONG = GST_ISP_UINT64,
  GST_ISP_LAST_UNALIGNED = GST_ISP_FLOAT,
#else
  GST_ISP_LONG = GST_ISP_INT,
  GST_ISP_ULONG = GST_ISP_UINT,
  GST_ISP_LAST_UNALIGNED = GST_ISP_USHORT,
#endif
};


/* enum types used by the public APIs.  */
enum gst_file_dir {
  GST_DIR_ABS,
  GST_DIR_KERNEL_SYSTEM,
  GST_DIR_KERNEL,
  GST_DIR_BASE
};

enum gst_var_index {
  GST_DECLARE_TRACING,
  GST_EXECUTION_TRACING,
  GST_EXECUTION_TRACING_VERBOSE,
  GST_GC_MESSAGE,
  GST_VERBOSITY,
  GST_MAKE_CORE_FILE,
  GST_REGRESSION_TESTING
};

enum gst_init_flags {
  GST_REBUILD_IMAGE = 1,
  GST_MAYBE_REBUILD_IMAGE = 2,
  GST_IGNORE_USER_FILES = 4,
  GST_IGNORE_BAD_IMAGE_PATH = 8,
  GST_IGNORE_BAD_KERNEL_PATH = 16,
  GST_NO_TTY = 32,
};

enum gst_vm_hook {
  GST_BEFORE_EVAL,
  GST_AFTER_EVAL,
  GST_RETURN_FROM_SNAPSHOT,
  GST_ABOUT_TO_QUIT,
  GST_ABOUT_TO_SNAPSHOT,
  GST_FINISHED_SNAPSHOT
};

#define INDEXED_WORD(obj, n)   ( ((long *) ((obj) + 1))		    [(n)-1] )
#define INDEXED_BYTE(obj, n)   ( ((char *) ((obj) + 1))		    [(n)-1] )
#define INDEXED_OOP(obj, n)    ( ((OOP  *) ((obj) + 1))		    [(n)-1] )
#define ARRAY_OOP_AT(obj, n)   ( ((OOP  *) ((gst_object) obj)->data) [(n)-1] )
#define STRING_OOP_AT(obj, n)  ( ((char *) ((gst_object) obj)->data) [(n)-1] )

#endif /* GST_GST_H */
