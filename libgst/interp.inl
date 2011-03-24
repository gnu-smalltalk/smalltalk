/******************************** -*- C -*- ****************************
 *
 *	Byte code interpreter inlines
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2006 Free Software Foundation, Inc.
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


/* Do an arithmetic operation between A and B and set OVERFLOW to
   false or true depending on overflow.  */
static inline OOP add_with_check (OOP op1, OOP op2,
                                  mst_Boolean *overflow);
static inline OOP sub_with_check (OOP op1, OOP op2,
                                  mst_Boolean *overflow);
static inline OOP mul_with_check (OOP op1, OOP op2,
                                  mst_Boolean *overflow);

/* These do not need overflow checking.  */
static inline OOP tagged_and (OOP op1, OOP op2);
static inline OOP tagged_or (OOP op1, OOP op2);
static inline OOP tagged_xor (OOP op1, OOP op2);

/* using STACK_AT is correct: numArgs == 0 means that there's just the
 * receiver on the stack, at 0.  numArgs = 1 means that at location 0 is
 * the arg, location 1 is the receiver.  And so on.  */
#define SEND_MESSAGE(sendSelector, sendArgs) do {		\
  OOP _receiver;						\
  _receiver = STACK_AT(sendArgs);				\
  _gst_send_message_internal(sendSelector, sendArgs, _receiver,	\
			     OOP_INT_CLASS(_receiver));		\
} while(0)


#if defined __i386__
#define OP_SUFFIX "l"
#define OP_CONSTRAINT "rmi"
#else
#define OP_SUFFIX "q"
#define OP_CONSTRAINT "rme"
#endif

OOP
tagged_and (OOP op1, OOP op2)
{
  intptr_t iop1 = (intptr_t) op1;
  intptr_t iop2 = (intptr_t) op2;
  return (OOP) (iop1 & iop2);
}

OOP
tagged_or (OOP op1, OOP op2)
{
  intptr_t iop1 = (intptr_t) op1;
  intptr_t iop2 = (intptr_t) op2;
  return (OOP) (iop1 | iop2);
}

OOP
tagged_xor (OOP op1, OOP op2)
{
  intptr_t iop1 = (intptr_t) op1;
  intptr_t iop2 = ((intptr_t) op2) - 1;
  return (OOP) (iop1 ^ iop2);
}

OOP
add_with_check (OOP op1, OOP op2, mst_Boolean *overflow)
{
  intptr_t iop1 = (intptr_t) op1;
  intptr_t iop2 = (intptr_t) op2;
  intptr_t iresult;
#if (defined __i386__ || defined __x86_64__) && !defined NO_OPTIMIZED_SMALLINTEGERS
  int of = 0;
  iop2--;
  asm ("add" OP_SUFFIX " %3, %2\n"
       "seto %b1" : "=r" (iresult), "+&q" (of) : "0" (iop1), OP_CONSTRAINT (iop2));

  *overflow = of;
#else
  iresult = no_opt (iop1 + (iop2 - 1));
  *overflow = false;
  if (COMMON ((iop1 ^ iop2) >= 0) && UNCOMMON ((iop1 ^ iresult) < 0))
    *overflow = true;
#endif
  return (OOP) iresult;
}

OOP
sub_with_check (OOP op1, OOP op2, mst_Boolean *overflow)
{
  intptr_t iop1 = (intptr_t) op1;
  intptr_t iop2 = (intptr_t) op2;
  intptr_t iresult;
#if (defined __i386__ || defined __x86_64__) && !defined NO_OPTIMIZED_SMALLINTEGERS
  int of = 0;
  iop2--;
  asm ("sub" OP_SUFFIX " %3, %2\n"
       "seto %b1" : "=r" (iresult), "+&q" (of) : "0" (iop1), OP_CONSTRAINT (iop2));

  *overflow = of;
#else
  iresult = no_opt (iop1 - (iop2 - 1));
  *overflow = false;
  if (UNCOMMON ((iop1 ^ iop2) < 0) && UNCOMMON ((iop1 ^ iresult) < 0))
    *overflow = true;
#endif
  return (OOP) iresult;
}

OOP
mul_with_check (OOP op1, OOP op2, mst_Boolean *overflow)
{
  intptr_t a = TO_INT (op1);
  intptr_t b = TO_INT (op2);
  intmax_t result = (intmax_t)a * b;
  *overflow = false;

  /* We define the largest int type in stdintx.h, but we can
     only use it if it is two times the width of an intptr_t.  */

  if (sizeof (intmax_t) >= 2 * sizeof (intptr_t))
    {
      if UNCOMMON (result > MAX_ST_INT || result < MIN_ST_INT)
        *overflow = true;
      else
        return FROM_INT (result);
    }

  /* This fallback method uses a division to do overflow check */
  else
    {
      if COMMON ((((uintptr_t) (a | b)) < (1L << (ST_INT_SIZE / 2))
	          || b == 0
	          || result / b == a)
                 && !INT_OVERFLOW (result))
        return FROM_INT (result);
      else
        *overflow = true;
    }

  return FROM_INT (0);
}
