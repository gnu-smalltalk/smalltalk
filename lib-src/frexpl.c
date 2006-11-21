/******************************** -*- C -*- ****************************
 *
 *      Emulation for frexpl
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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

#include <float.h>
#include <math.h>

#include "mathl.h"

/* Binary search.  Quite inefficient but portable. */
long double
frexpl(long double x, int *exp)
{
  long double exponents[20], *next;
  int exponent, bit;

  /* Check for zero, nan and infinity. */
  if (x != x || x + x == x )
    {
      *exp = 0;
      return x;
    }

  if (x < 0)
    return -frexpl(-x, exp);

  exponent = 0;
  if (x > 1.0)
    {
      for (next = exponents, exponents[0] = 2.0L, bit = 1;
	   *next <= x + x;
	   bit <<= 1, next[1] = next[0] * next[0], next++);

      for (; next >= exponents; bit >>= 1, next--)
	if (x + x >= *next)
	  {
	    x /= *next;
	    exponent |= bit;
	  }

    }

  else if (x < 0.5)
    {
      for (next = exponents, exponents[0] = 0.5L, bit = 1;
	   *next > x;
	   bit <<= 1, next[1] = next[0] * next[0], next++);

      for (; next >= exponents; bit >>= 1, next--)
	if (x < *next)
	  {
	    x /= *next;
	    exponent |= bit;
	  }

      exponent = -exponent;
    }

  *exp = exponent;
  return x;
}

#if 0
int
main()
{
  long double x;
  int y;
  x = frexpl(0.0L / 0.0L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(1.0L / 0.0L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(-1.0L / 0.0L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.5L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.75L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(3.6L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(17.8L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(8.0L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.3L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.49L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.049L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.0245L, &y); printf ("%.6Lg %d\n", x, y);
  x = frexpl(0.0625L, &y); printf ("%.6Lg %d\n", x, y);
}
#endif

