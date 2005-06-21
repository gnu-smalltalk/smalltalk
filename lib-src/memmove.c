/******************************** -*- C -*- ****************************
 *
 *	memmove substitute
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 */


/* This loop ensures that src and dst are aligned to a power of two
 * bigger than sizeof(type)
 */
#define LOOP_ALIGN(type)					\
  while(n >= sizeof(type) && ((long) dst) & sizeof(type) ) {	\
    n -= sizeof(type);						\
    COPY(type);							\
  }								\

/* This loop does as much as possible with the given type. */
#define LOOP_FINISH(type)					\
  while(n >= sizeof(type)) {					\
    n -= sizeof(type);						\
    COPY(type);							\
  }								\

#if SIZEOF_LONG > SIZEOF_INT
  #define LOOP_ALIGN_TO_LONG					\
    LOOP_ALIGN(int);						\
    LOOP_FINISH(long);	
#else
  #define LOOP_ALIGN_TO_LONG
#endif

#define GO do {							\
  long alignment = ((long) dst) ^ ((long) src);			\
  if ((alignment % sizeof(long)) == 0) {			\
    /* Great, aligned source and destinations! */		\
    LOOP_ALIGN(char);						\
    LOOP_ALIGN(short);						\
    LOOP_ALIGN_TO_LONG;						\
    LOOP_FINISH(int);						\
    LOOP_FINISH(short);						\
  }								\
  LOOP_FINISH(char);						\
} while(0)

#include <stdlib.h>

char *
memmove(char *saveDest, char *src, size_t n)
{
  register char *dst = saveDest;

  if ((dst > src) && (dst < src + n))  {
    src += n;
    dst += n;
#define COPY(type) *--((type *) dst) = *--((type *) src);
    GO;
#undef COPY

  } else {
#define COPY(type)  *((type *) dst)++ = *((type *) src)++;
    GO;
#undef COPY
  }

  return saveDest;
}
