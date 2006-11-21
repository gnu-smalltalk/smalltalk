/******************************** -*- C -*- ****************************
 *
 *	Fast versions of memset(s, 0, n)
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.  Inspired by the Linux source code.
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
 */

#ifndef GST_MEMZERO_H
#define GST_MEMZERO_H

#include "config.h"

/**************************************** not GCC ************************/

#ifndef __GNUC__
/* Fool the preprocessor and make it discard the following code */
#define GST_MEMZERO_DONE
#endif

/******************************************** GCC ************************/

/* GCC optimizes memset(s, 0, n) but not bzero(s, n).
   The optimization is broken before EGCS 1.1.  */
#if GNUC_PREREQ (2, 91)
#define memzero(s, n) __builtin_memset (s, '\0', n)
#define GST_MEMZERO_DONE
#endif

/**************************************** MIPS ***************************/

#if defined(__mips) || defined(mips)
#ifndef GST_MEMZERO_DONE
#define GST_MEMZERO_DONE
static inline void
memzero (PTR s,
	 size_t count)
{
  if (!count)
    return;

  /* hmmm... this zeroes memory a byte at a time... I wonder whether it
     is really faster than the generic version...  */
  __asm__ __volatile__ (".set	noreorder" "\n"
			"1:	sb	%3,(%0)" "\n"
			"	bne	%0,%1,1b" "\n"
			"	addiu	%0,%0,1" "\n"
			"	.set	treorder":"=r" (s),
			"=r" (count):"0" (s),
			"r" (0L),
			"1" (s + count - 1):"memory");
}
#endif
#endif

/**************************************** Intel x86 **********************/

#if defined(__i386__) || defined(__i386) || defined(i386)
#ifndef GST_MEMZERO_DONE
#define GST_MEMZERO_DONE
static inline void
memzero (PTR s,
	 size_t count)
{
  int d0, d1;
  __asm__ __volatile__ ("cld" "\n"
			"	rep ; stosl" "\n"
			"	testb $2,%b3" "\n"
			"	je 1f" "\n"
			"	stosw" "\n"
			"1:	testb $1,%b3" "\n"
			"	je 2f" "\n"
			"	stosb" "\n" "2:":"=&c" (d0),
			"=&D" (d1):"a" (0L),
			"q" (count),
			"0" (count / 4),
			"1" ((intptr_t) s):"memory");
}
#endif
#endif

/**************************************** Default implementation *********/

#if !defined(GST_MEMZERO_DONE) || !defined(__GNUC__)

/* cfr memmove.c -- both files implement a very fast unrolled loop, using
 * approx. the same code (this has only destination, memmove has
 * source+destination).  */
#define COPY(type)  *((type *) dst)++ = (type) 0;

/* This loop ensures that dst is aligned to a power of two 
 * bigger than sizeof(type)
 */
#define LOOP_ALIGN(type)					\
  while(n >= sizeof(type) && ((intptr_t) dst) & sizeof(type) ) {	\
    n -= sizeof(type);						\
    COPY(type);							\
  }								\

/* This loop does as much as possible with the given type.  */
#define LOOP_FINISH(type)					\
  while(n >= sizeof(type)) {					\
    n -= sizeof(type);						\
    COPY(type);							\
  }								\

static inline void
memzero (PTR dst,
	 size_t n)
{
  LOOP_ALIGN (char);
  LOOP_ALIGN (short);
  if (sizeof (long) > sizeof (int))
    {
      LOOP_ALIGN (int);
      LOOP_FINISH (long);
    }
  LOOP_FINISH (int);
  LOOP_FINISH (short);
  LOOP_FINISH (char);
}

#undef LOOP_ALIGN
#undef LOOP_FINISH
#undef COPY
#endif

#undef GST_MEMZERO_DONE

#endif /* GST_MEMZERO_H */
