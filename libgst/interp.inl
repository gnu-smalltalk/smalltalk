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
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


/* Multiply a*b and in case of an overflow, answer OVERFLOWING_INT so
   that we can work it out the same way we do with adds and
   subtracts.  */
static inline intptr_t mul_with_check (intptr_t a, intptr_t b);

/* using STACK_AT is correct: numArgs == 0 means that there's just the
 * receiver on the stack, at 0.  numArgs = 1 means that at location 0 is
 * the arg, location 1 is the receiver.  And so on.  */
#define SEND_MESSAGE(sendSelector, sendArgs) do {		\
  OOP _receiver;						\
  _receiver = STACK_AT(sendArgs);				\
  _gst_send_message_internal(sendSelector, sendArgs, _receiver,	\
			     OOP_INT_CLASS(_receiver));		\
} while(0)


intptr_t
mul_with_check (intptr_t a, intptr_t b)
{
  intmax_t result = (intmax_t)a * b;

  /* We define the largest int type in stdintx.h, but we can
     only use it if it is two times the width of an intptr_t.  */

  if (sizeof (intmax_t) >= 2 * sizeof (intptr_t))
    {
      if UNCOMMON (result > MAX_ST_INT || result < MIN_ST_INT)
        return (OVERFLOWING_INT);
      else
        return (result);
    }

  /* This fallback method uses a division to do overflow check */
  else
    {
      if COMMON ((a | b) < (1L << (ST_INT_SIZE / 2))
	         || b == 0
	         || result / b == a)
        return (result);
      else
        return (OVERFLOWING_INT);
    }
}
