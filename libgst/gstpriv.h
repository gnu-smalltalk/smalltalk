/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk generic inclusions.
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

#ifndef GST_GSTPRIV_H
#define GST_GSTPRIV_H

#include "config.h"

#include <sys/types.h>
#include <stdio.h>
#include <stddef.h>
#include <setjmp.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <obstack.h>
#include <fcntl.h>
#include <stdarg.h>
#include <math.h>
#include <float.h>
#include <errno.h>
#include <signal.h>
#include <sys/stat.h>
#include <limits.h>
#include <ctype.h>
#include <wchar.h>
#include <dirent.h>
#include <sys/time.h>
#include <time.h>

#ifdef HAVE_CRT_EXTERNS_H
#include <crt_externs.h>
#endif

#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif

#ifdef HAVE_EXECINFO_H
#include <execinfo.h>
#endif

#ifdef HAVE_SYS_FILE_H
#include <sys/file.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifdef HAVE_SYS_MMAN_H
#include <sys/mman.h>
#endif

#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif

#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif

#ifdef HAVE_SIGSEGV_H
#include "sigsegv.h"
#endif

#include "gst.h"

/* Convenience macros to test the versions of GCC.  Note - they won't
   work for GCC1, since the _MINOR macros were not defined then, but
   we don't have anything interesting to test for that. :-) */
#if defined __GNUC__ && defined __GNUC_MINOR__
# define GNUC_PREREQ(maj, min) \
	((__GNUC__ << 16) + __GNUC_MINOR__ >= ((maj) << 16) + (min))
#else
# define GNUC_PREREQ(maj, min) 0
#endif

/* For internal functions, we can use the ELF hidden attribute to
   improve code generation.  Unluckily, this is only in GCC 3.2 and
   later */
#ifdef HAVE_VISIBILITY_HIDDEN
#define ATTRIBUTE_HIDDEN __attribute__ ((visibility ("hidden")))
#else
#define ATTRIBUTE_HIDDEN
#endif

/* At some point during the GCC 2.96 development the `pure' attribute
   for functions was introduced.  We don't want to use it
   unconditionally (although this would be possible) since it
   generates warnings.

   GCC 2.96 also introduced branch prediction hints for basic block
   reordering.  We use a shorter syntax than the wordy one that GCC
   wants.  */
#if GNUC_PREREQ (2, 96)
#define UNCOMMON(x) (__builtin_expect ((x) != 0, 0))
#define COMMON(x)   (__builtin_expect ((x) != 0, 1))
#else
#define UNCOMMON(x) (x)
#define COMMON(x)   (x)
#endif

/* Prefetching macros.  The NTA version is for a read that has no
   temporal locality.  The second argument is the kind of prefetch
   we want, using the flags that follow (T0, T1, T2, NTA follow
   the names of the instructions in the SSE instruction set).  The
   flags are hints, there is no guarantee that the instruction set
   has the combination that you ask for -- just trust the compiler.

   There are three macros.  PREFETCH_ADDR is for isolated prefetches,
   for example it is used in the garbage collector's marking loop
   to be reasonably sure that OOPs are in the cache before they're
   marked.  PREFETCH_START and PREFETCH_LOOP usually go together, one
   in the header of the loop and one in the middle.  However, you may
   use PREFETCH_START only for small loops, and PREFETCH_LOOP only if
   you know that the loop is invoked often (this is done for alloc_oop,
   for example, to keep the next allocated OOPs in the cache).
   PREF_BACKWARDS is for use with PREFETCH_START/PREFETCH_LOOP.  */
#define PREF_READ 0
#define PREF_WRITE 1
#define PREF_BACKWARDS 2
#define PREF_T0 0
#define PREF_T1 4
#define PREF_T2 8
#define PREF_NTA 12

#if GNUC_PREREQ (3, 1)
#define DO_PREFETCH(x, distance, k) \
  __builtin_prefetch (((char *) (x)) \
		      + (((k) & PREF_BACKWARDS ? -(distance) : (distance)) \
			 << L1_CACHE_SHIFT), \
		      (k) & PREF_WRITE, \
		      3 - (k) / (PREF_NTA / 3))
#else
#define DO_PREFETCH(x, distance, kind) ((void)(x))
#endif

#define PREFETCH_START(x, k) do { \
  const char *__addr = (const char *) (x); \
  DO_PREFETCH (__addr, 0, (k)); \
  if (L1_CACHE_SHIFT >= 7) break; \
  DO_PREFETCH (__addr, 1, (k)); \
  if (L1_CACHE_SHIFT == 6) break; \
  DO_PREFETCH (__addr, 2, (k)); \
  DO_PREFETCH (__addr, 3, (k)); \
} while (0)

#define PREFETCH_LOOP(x, k) \
  DO_PREFETCH ((x), (L1_CACHE_SHIFT >= 7 ? 1 : 128 >> L1_CACHE_SHIFT), (k));

#define PREFETCH_ADDR(x, k) \
  DO_PREFETCH ((x), 0, (k));

/* Synchronization primitives.  */
#define __sync_swap(ptr, val) \
  ({ __typeof__ (*(ptr)) _x; \
   do _x = *(ptr); while (!__sync_bool_compare_and_swap ((ptr), (_x), (val))); \
   _x; })

/* Kill a warning when using GNU C.  Note that this allows using
   break or continue inside a macro, unlike do...while(0) */
#ifdef __GNUC__
#define BEGIN_MACRO ((void) (
#define END_MACRO ))
#else
#define BEGIN_MACRO if (1) 
#define END_MACRO else (void)0
#endif


/* ENABLE_SECURITY enables security checks in the primitives as well as
   special marking of untrusted objects.  Note that the code in the
   class library to perform the security checks will be present
   notwithstanding the setting of this flag, but they will be disabled
   because the corresponding primitives will be made non-working.  We
   define it here with no configure-time options because it causes
   testsuite failures.  */
#define ENABLE_SECURITY

/* OPTIMIZE disables many checks, including consistency checks at GC
   time and bounds checking on instance variable accesses (not on #at:
   and #at:put: which would violate language semantics).  It can a)
   greatly speed up code by simplifying the interpreter's code b) make
   debugging painful because you know of a bug only when it's too
   late.  It is undefined because the Makefiles take care of defining
   it for optimized builds.  Bounds-checking and other errors will
   call abort().  */
/* #define OPTIMIZE */

typedef unsigned char gst_uchar;

#ifdef NO_INLINES
#define inline
#else
#  if defined (__GNUC__)
#    undef inline
#    define inline __inline__	/* let's not lose when --ansi is
				   specified */
#  endif
#endif

/* If they have no const, they're likely to have no volatile, either.  */
#ifdef const
#define volatile
#endif

#ifndef HAVE_STRDUP
extern char *strdup ();
/* else it is in string.h */
#endif


/* Run-time flags are allocated from the top, while those
   that live across image saves/restores are allocated
   from the bottom.

   bit 0-3: reserved for distinguishing byte objects and saving their size.
   bit 4-14: non-volatile bits (special kinds of objects).  Used up to 11.
   bit 15-30: volatile bits (GC/JIT-related).  Used up to 23.
   bit 31: unused to avoid signedness mess. */
enum {
  /* Set if the object is reachable, during the mark phases of oldspace
     garbage collection.  */
  F_REACHABLE = 0x800000U,

  /* Set if a translation to native code is available, when running
     with the JIT compiler enabled.  */
  F_XLAT = 0x400000U,

  /* Set if a translation to native code is used by the currently
     reachable contexts.  */
  F_XLAT_REACHABLE = 0x200000U,

  /* Set if a translation to native code is available but not used by
     the reachable contexts at the time of the last GC.  We give
     another chance to the object, but if the translation is not used
     for two consecutive GCs we discard it.  */
  F_XLAT_2NDCHANCE = 0x100000U,

  /* Set if a translation to native code was discarded for this
     object (either because the programmer asked for this, or because
     the method conflicted with a newly-installed method).  */
  F_XLAT_DISCARDED = 0x80000U,

  /* One of this is set for objects that live in newspace.  */
  F_SPACES = 0x60000U,
  F_EVEN = 0x40000U,
  F_ODD = 0x20000U,

  /* Set if the OOP is allocated by the pools of contexts maintained
     in interp.c (maybe it belongs above...) */
  F_POOLED = 0x10000U,

  /* Set if the bytecodes in the method have been verified. */
  F_VERIFIED = 0x8000U,

  /* The grouping of all the flags which are not valid across image
     saves and loads.  */
  F_RUNTIME = 0x7FFF8000U,

  /* Set if the references to the instance variables of the object
     are weak.  */
  F_WEAK = 0x10U,

  /* Set if the object is read-only.  */
  F_READONLY = 0x20U,

  /* Set if the object is a context and hence its instance variables
     are only valid up to the stack pointer.  */
  F_CONTEXT = 0x40U,

  /* Answer whether we want to mark the key based on references found
     outside the object.  */
  F_EPHEMERON = 0x80U,

  /* Set for objects that live in oldspace.  */
  F_OLD = 0x100U,

  /* Set together with F_OLD for objects that live in fixedspace.  */
  F_FIXED = 0x200U,

  /* Set for untrusted classes, instances of untrusted classes,
     and contexts whose receiver is untrusted.  */
  F_UNTRUSTED = 0x400U,

  /* Set for objects that were loaded from the image.  We never
     garbage collect their contents, only the OOPs.  */
  F_LOADED = 0x800U,

  /* Set to the number of bytes unused in an object with byte-sized
     instance variables.  Note that this field and the following one
     should be initialized only by INIT_UNALIGNED_OBJECT (not really 
     aesthetic but...) */
  EMPTY_BYTES = (sizeof (PTR) - 1),

  /* A bit more than what is identified by EMPTY_BYTES.  Selects some
     bits that are never zero if and only if this OOP identifies an
     object with byte instance variables.  */
  F_BYTE = 15
};

/* Answer whether a method, OOP, has already been verified. */
#define IS_OOP_VERIFIED(oop) \
  (((oop)->flags & F_VERIFIED) != 0)

/* Answer whether an object, OOP, is weak.  */
#define IS_OOP_WEAK(oop) \
  (((oop)->flags & F_WEAK) != 0)

/* Answer whether an object, OOP, is readonly.  */
#define IS_OOP_READONLY(oop) \
  (IS_INT ((oop)) || ((oop)->flags & F_READONLY))

/* Set whether an object, OOP, is readonly or readwrite.  */
#define MAKE_OOP_READONLY(oop, ro) \
  (((oop)->flags &= ~F_READONLY), \
   ((oop)->flags |= (ro) ? F_READONLY : 0))

#ifdef ENABLE_SECURITY

/* Answer whether an object, OOP, is untrusted.  */
#define IS_OOP_UNTRUSTED(oop) \
  (!IS_INT ((oop)) && ((oop)->flags & F_UNTRUSTED))

/* Set whether an object, OOP, is trusted or untrusted.  */
#define MAKE_OOP_UNTRUSTED(oop, untr) \
  (((oop)->flags &= ~F_UNTRUSTED), \
   ((oop)->flags |= (untr) ? F_UNTRUSTED : 0))

#else
#define IS_OOP_UNTRUSTED(oop) (false)
#define MAKE_OOP_UNTRUSTED(oop, untr) ((void)0)
#endif

/* Set whether an object, OOP, has ephemeron semantics.  */
#define MAKE_OOP_EPHEMERON(oop) \
  (oop)->flags |= F_EPHEMERON;


/* the current execution stack pointer */
#ifndef ENABLE_JIT_TRANSLATION
# define sp		_gst_sp
#endif

/* The VM's stack pointer */
extern OOP *sp 
  ATTRIBUTE_HIDDEN;

/* Some useful constants */
extern OOP _gst_nil_oop 
  ATTRIBUTE_HIDDEN, _gst_true_oop 
  ATTRIBUTE_HIDDEN, _gst_false_oop 
  ATTRIBUTE_HIDDEN;

/* Some stack operations */
#define UNCHECKED_PUSH_OOP(oop) \
  (*++sp = (oop))

#define UNCHECKED_SET_TOP(oop) \
  (*sp = (oop))

#ifndef OPTIMIZE
#define PUSH_OOP(oop) \
  do { \
    OOP __pushOOP = (oop); \
    if (IS_OOP (__pushOOP) && !IS_OOP_VALID (__pushOOP)) \
      abort (); \
    UNCHECKED_PUSH_OOP (__pushOOP); \
  } while (0)
#else
#define PUSH_OOP(oop) \
  do { \
    OOP __pushOOP = (oop); \
    UNCHECKED_PUSH_OOP (__pushOOP); \
  } while (0)
#endif

#define POP_OOP() \
  (*sp--)

#define POP_N_OOPS(n) \
  (sp -= (n))

#define UNPOP(n) \
  (sp += (n))

#define STACKTOP() \
  (*sp)

#ifndef OPTIMIZE
#define SET_STACKTOP(oop) \
  do { \
    OOP __pushOOP = (oop); \
    if (IS_OOP (__pushOOP) && !IS_OOP_VALID (__pushOOP)) \
      abort (); \
    UNCHECKED_SET_TOP(__pushOOP); \
  } while (0)
#else
#define SET_STACKTOP(oop) \
  do { \
    OOP __pushOOP = (oop); \
    UNCHECKED_SET_TOP(__pushOOP); \
  } while (0)
#endif

#define SET_STACKTOP_INT(i) \
  UNCHECKED_SET_TOP(FROM_INT(i))

#define SET_STACKTOP_BOOLEAN(exp) \
  UNCHECKED_SET_TOP((exp) ? _gst_true_oop : _gst_false_oop)

#define STACK_AT(i) \
  (sp[-(i)])

#define PUSH_INT(i) \
  UNCHECKED_PUSH_OOP(FROM_INT(i))

#define POP_INT() \
  TO_INT(POP_OOP())

#define PUSH_BOOLEAN(exp) \
  PUSH_OOP((exp) ? _gst_true_oop : _gst_false_oop)


/* Answer whether CLASS is the class that the object pointed to by OOP
   belongs to.  OOP can also be a SmallInteger.  */
#define IS_CLASS(oop, class) \
  (OOP_INT_CLASS(oop) == class)

/* Answer the CLASS that the object pointed to by OOP belongs to.  OOP
   can also be a SmallInteger. */
#define OOP_INT_CLASS(oop) \
  (IS_INT(oop) ? _gst_small_integer_class : OOP_CLASS(oop))


/* Answer whether OOP is nil.  */
#define IS_NIL(oop) \
  ((OOP)(oop) == _gst_nil_oop)


/* This macro should only be used right after an alloc_oop, when the
   emptyBytes field is guaranteed to be zero.

   Note that F_BYTE is a bit more than EMPTY_BYTES, so that if value 
   is a multiple of sizeof (PTR) the flags identified by F_BYTE are
   not zero.  */
#define INIT_UNALIGNED_OBJECT(oop, value) \
    ((oop)->flags |= sizeof (PTR) | (value))


/* Generally useful conversion functions */
#define SIZE_TO_BYTES(size) \
  ((size) * sizeof (PTR))

#define BYTES_TO_SIZE(bytes) \
  ((bytes) / sizeof (PTR))

#ifdef __GNUC__
#define no_opt(x)	({ __typeof__ ((x)) _result; \
			 asm ("" : "=r" (_result) : "0" ((x))); _result; })
#define barrier()       asm ("")
#else
#define no_opt(x)	(x)
#define barrier()
#endif

/* integer conversions and some information on SmallIntegers.  */

#define TO_INT(oop) \
  ((intptr_t)(oop) >> 1)

#define FROM_INT(i) \
  (OOP)( ((intptr_t)(i) << 1) + 1)

#define ST_INT_SIZE        ((sizeof (PTR) * 8) - 2)
#define MAX_ST_INT         ((1L << ST_INT_SIZE) - 1)
#define MIN_ST_INT         ( ~MAX_ST_INT)
#define INT_OVERFLOW(i)    (((i) ^ ((i) << 1)) < 0)
#define OVERFLOWING_INT    (MAX_ST_INT + 1)

#define INCR_INT(i)         ((OOP) (((intptr_t)i) + 2))	/* 1 << 1 */
#define DECR_INT(i)         ((OOP) (((intptr_t)i) - 2))	/* 1 << 1 */

/* Endian conversions, using networking functions if they do
   the correct job (that is, on 32-bit little-endian systems)
   because they are likely to be optimized.  */

#if SIZEOF_OOP == 4
# if !defined(WORDS_BIGENDIAN) && defined (HAVE_SOCKETS)
#  define BYTE_INVERT(x) htonl((x))
# elif defined _OS_OSBYTEORDERPPC_H
#  define BYTE_INVERT(x) OSReadSwapInt32(&(x), 0)
# else
#  define BYTE_INVERT(x) \
        ((uintptr_t)((((uintptr_t)(x) & 0x000000ffU) << 24) | \
                     (((uintptr_t)(x) & 0x0000ff00U) <<  8) | \
                     (((uintptr_t)(x) & 0x00ff0000U) >>  8) | \
                     (((uintptr_t)(x) & 0xff000000U) >> 24)))
# endif

#else /* SIZEOF_OOP == 8 */
# if defined _OS_OSBYTEORDERPPC_H
#  define BYTE_INVERT(x) OSReadSwapInt64(&(x), 0)
# else
#  define BYTE_INVERT(x) \
        ((uintptr_t)((((uintptr_t)(x) & 0x00000000000000ffU) << 56) | \
                     (((uintptr_t)(x) & 0x000000000000ff00U) << 40) | \
                     (((uintptr_t)(x) & 0x0000000000ff0000U) << 24) | \
                     (((uintptr_t)(x) & 0x00000000ff000000U) <<  8) | \
                     (((uintptr_t)(x) & 0x000000ff00000000U) >>  8) | \
                     (((uintptr_t)(x) & 0x0000ff0000000000U) >> 24) | \
                     (((uintptr_t)(x) & 0x00ff000000000000U) >> 40) | \
                     (((uintptr_t)(x) & 0xff00000000000000U) >> 56)))
# endif
#endif /* SIZEOF_OOP == 8 */

/* The standard min/max macros...  */

#ifndef ABS
#define ABS(x) (x >= 0 ? x : -x)
#endif
#ifndef MAX
#define MAX(x, y) 		( ((x) > (y)) ? (x) : (y) )
#endif
#ifndef MIN
#define MIN(x, y) 		( ((x) > (y)) ? (y) : (x) )
#endif

#include "ansidecl.h"
#include "mathl.h"
#include "socketx.h"
#include "strspell.h"
#include "alloc.h"
#include "md-config.h"
#include "avltrees.h"
#include "rbtrees.h"

#include "files.h"
#include "callin.h"
#include "cint.h"
#include "dict.h"
#include "heap.h"
#include "lex.h"
#include "tree.h"
#include "sym.h"
#include "gst-parse.h"
#include "input.h"
#include "oop.h"
#include "byte.h"
#include "comp.h"
#include "interp.h"
#include "events.h"
#include "opt.h"
#include "save.h"
#include "str.h"
#include "sysdep.h"
#include "xlat.h"
#include "mpz.h"
#include "print.h"
#include "security.h"
#include "real.h"
#include "sockets.h"

/* Include this last, it has the bad habit of #defining printf
   and this fools gcc's __attribute__ (format) */
#include "snprintfv/printf.h"

#undef obstack_init
#define obstack_init(h)                                         \
  _obstack_begin ((h), 0, ALIGNOF_LONG_DOUBLE,                \
                  (void *(*) (long)) obstack_chunk_alloc,       \
                  (void (*) (void *)) obstack_chunk_free)

#undef obstack_begin
#define obstack_begin(h, size)                                  \
  _obstack_begin ((h), (size), ALIGNOF_LONG_DOUBLE,           \
                  (void *(*) (long)) obstack_chunk_alloc,       \
                  (void (*) (void *)) obstack_chunk_free)

#include "oop.inl"
#include "dict.inl"
#include "interp.inl"
#include "comp.inl"

#endif /* GST_GSTPRIV_H */
