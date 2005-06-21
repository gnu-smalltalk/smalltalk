/******************************** -*- C -*- ****************************
 *
 *	Byte code interpreter inlines
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


/* Multiply a*b and in case of an overflow, answer OVERFLOWING_INT so
   that we can work it out the same way we do with adds and
   subtracts. */
static inline long mul_with_check (long int a, long int b);

/* using STACK_AT is correct: numArgs == 0 means that there's just the
 * receiver on the stack, at 0.  numArgs = 1 means that at location 0 is
 * the arg, location 1 is the receiver.  And so on. */
#define SEND_MESSAGE(sendSelector, sendArgs, dummy) do {			\
  OOP _receiver;								\
  _receiver = STACK_AT(sendArgs);						\
  _gst_send_message_internal(sendSelector, sendArgs, _receiver, 		\
    IS_INT(_receiver) ? _gst_small_integer_class : OOP_CLASS(_receiver));	\
} while(0)


long
mul_with_check (long int a, long int b)
{

  /* GCC defines a long long to be 64-bit wide, so we can use it
     on 32-bit architectures. */
#if defined(__GNUC__) && SIZEOF_LONG == 4
  long long result = (long long)a * b;
  if UNCOMMON (result > MAX_ST_INT || result < MIN_ST_INT)
    return (OVERFLOWING_INT);
  else
    return (result);

#else /* !__GNUC__ or sizeof(long)>4 */

  /* ISO C99 defines the largest int type in inttypes.h, but we can
     only use it if it is two times the width of a long int. 
     The formula to do this test

        UINTMAX_MAX >= (ULONG_MAX + 1) * (ULONG_MAX + 1) - 1

     was rewritten so that it has no overflow when multiplying; we
     must also have it fail if sizeof(intmax_t) == sizeof(long).

     In the future, we'll use inttypes.h more widely and just
     check for sizeof(uintmax_t >= 2*sizeof(uintptr_t).  */

#if defined(HAVE_INTTYPES_H) && UINTMAX_MAX > ULONG_MAX && UINTMAX_MAX >= (ULONG_MAX * (ULONG_MAX + UINTMAX_C(2)))
  intmax_t result = (intmax_t)a * b;
  if UNCOMMON (result > MAX_ST_INT || result < MIN_ST_INT)
    return (OVERFLOWING_INT);
  else
    return (result);

  /* This fallback method uses a division to do overflow check */
#else /* !HAVE_INTTYPES_H or INTMAX_T too small */
  long result = a * b;
  if COMMON ((a | b) < (1L << (ST_INT_SIZE/2))
	     || b == 0
	     || (result / b == a))
    return (result);
  else
    return (OVERFLOWING_INT);
#endif /* !HAVE_INTTYPES_H or INTMAX_T too small */
#endif /* !__GNUC__ or sizeof(long)>4 */
}
