/******************************** -*- C -*- ****************************
 *
 *	strtoul substitute
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006
 * Free Software Foundation, Inc.
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
 */

#include <ctype.h>
#include <errno.h>
#include <limits.h>

#ifndef HAVE_STRTOUL

/* Map from ASCII digits to numerical equivalents (99 for non-digit chars). */
static char value[256] = {
  99, 99, 99, 99, 99, 99, 99, 99,		/* control chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* control chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* control chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* control chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* punctuation   */
  99, 99, 99, 99, 99, 99, 99, 99,		/* punctuation   */
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,			/* '0' - '9'     */
  99, 99, 99, 99, 99, 99, 99,			/* punctuation   */
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19,	/* 'A' - 'J'     */
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29,	/* 'K' - 'T'     */
  30, 31, 32, 33, 34, 35,			/* 'U' - 'Z'     */
  99, 99, 99, 99, 99, 99,			/* punctuation   */
  10, 11, 12, 13, 14, 15, 16, 17, 18, 19,	/* 'a' - 'j'     */
  20, 21, 22, 23, 24, 25, 26, 27, 28, 29,	/* 'k' - 't'     */
  30, 31, 32, 33, 34, 35, 			/* 'u' - 'z'     */
  99, 99, 99, 99, 99, 				/* punctuation */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99,		/* 8-bit chars */
  99, 99, 99, 99, 99, 99, 99, 99		/* 8-bit chars */
};

/*
 *----------------------------------------------------------------------
 *
 * strtoul --
 *
 *	Convert an ASCII string into an integer.
 *
 * Results:
 *	The return value is the integer equivalent of string.  If tail
 *	is non-NULL, then *tail is filled in with the character
 *	after the last one that was part of the integer.  If string
 *	doesn't contain a valid integer value, then zero is returned
 *	and *tail is set to string.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

unsigned long int
strtoul(char *string, char **tail, int base)
{
  register unsigned char *p;
  register unsigned long int result = 0, max;
  register unsigned char digit;
  int anyDigits = 0;

  /* Skip any leading blanks. */
  for (p = string; isspace(*p); p++) ;

  /* Parameter checks go here. */
  if (base < 0 || base > 36 || *p == '-') 
    {
      errno = EINVAL;
      if (tail)
	*tail = string;

      return (result);
    }

  /* If no base was provided, pick one from the leading characters
   * of the string. */
  if (base == 0) 
    {
      base = 10;
      if (*p == '0') 
	{
	  p++;
	  if (*p == 'x' || *p == 'X') 
	    {
	      p++;
	      base = 16;
	    } 
	  else
	    {
	      /* Set anyDigits here, otherwise "0" produces a "no digits" error. */
	      anyDigits = 1;
	      base = 8;
	    }
	}
    } 
  else if (base == 16) 
    {
      /* Skip leading "0x" or "0X" from hex numbers. */
      if (p[0] == '0')
	p += (p[1] == 'x' || p[1] == 'X') ? 2 : 1;
    }

  /* Do different things for base 8, 10, 16, and other (for speed). */
  if (base == 10)
    for ( ; (digit = *p - '0') <= 9; p++) 
      {
	anyDigits = 1;
	if (result > (ULONG_MAX / 10 - digit)) 
	  {
	    result = ULONG_MAX;
	    errno = ERANGE;
	  }
	result *= 10; result += digit;
      }
  else if (base == 16) 
    for ( ; (digit = value[*p]) <= 15; p++) 
      {
	anyDigits = 1;
	if (result > ((ULONG_MAX >> 4) - digit)) 
	  {
	    result = ULONG_MAX;
	    errno = ERANGE;
	  }
	result <<= 4; result += digit;
      }
  else if (base == 8) 
    for ( ; (digit = *p - '0') <= 7; p++) 
      {
	anyDigits = 1;
	if (result > ((ULONG_MAX >> 3) - digit)) 
	  {
	    result = ULONG_MAX;
	    errno = ERANGE;
	  }
	result <<= 3; result += digit;
      }
  else
    for ( max = ULONG_MAX / base; (digit = value[*p]) < base; p++) 
      {
	anyDigits = 1;
	if (result > (max - digit)) 
	  {
	    result = ULONG_MAX;
	    errno = ERANGE;
	  }
	result *= base; result += digit;
      }

  if (tail)
    /* See if there were any digits at all. */
    *tail = anyDigits ? (char *)p : string;

  return (result);
}

#endif
