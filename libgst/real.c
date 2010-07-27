/******************************** -*- C -*- ****************************
 *
 *	Simple floating-point data type
 *
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 2009 Free Software Foundation, Inc.
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


#include "gstpriv.h"

#define SIG_ELEM_BITS	(CHAR_BIT * sizeof (((struct real *)0)->sig[0]))
#define NUM_SIG_BITS	(SIGSZ * SIG_ELEM_BITS)
#define SIG_MASK	((1 << SIG_ELEM_BITS) - 1)
#define SIG_MSB		(1 << (SIG_ELEM_BITS - 1))

/* Shift the significant of IN by DELTA bits and store the result into
   OUT.  OUT and IN can overlap.  */
static int rshift_sig (struct real *out, struct real *in, int delta);

/* Normalize the significant of IN so that the most significant bit is 1,
   and store the result into OUT.  OUT and IN can overlap.  */
static void normalize (struct real *out, struct real *in);

/* Denormalize IN to increase its exponent to EXP and store the result
   into OUT.  OUT and IN can overlap.  Return false if OUT would be zero,
   in which case its contents are undefined.  */
static int adjust_exp (struct real *out, struct real *in, int exp);

/* Sum the significands of R and S.  Return the carry.  */
static int add_significands (struct real *r, struct real *s);

/* Compare the significands of R and S and return the result like strcmp.  */
static int cmp_significands (struct real *r, struct real *s);

/* Subtract the significands of R and S.  */
static void sub_significands (struct real *r, struct real *s);

/* Sum S into R.  */
static void do_add (struct real *r, struct real *s);

/* Multiply S into R.  LSB is the least significant nonzero byte of the
   significand of S, and is used to cut the iteration.  */
static void do_mul (struct real *r, struct real *s, int lsb);

/* Divide R by S and store the result into S.  OUT can overlap either R
   or S, but R must not be the same as S.  R is destroyed  */
static void do_div (struct real *out, struct real *r, struct real *s);

/* These routines are not optimized at all.  Maybe I should have bit
   the bullet and required MPFR after all...  */

static int
rshift_sig (struct real *out, struct real *in, int delta)
{
  int i, nonzero = 0;
  int rshift = delta & (SIG_ELEM_BITS - 1);
  int lshift = SIG_ELEM_BITS - rshift;

  delta /= SIG_ELEM_BITS;
  if (rshift)
    {
      for (i = 0; i + delta < SIGSZ - 1; i++)
	{
          out->sig[i] = ((in->sig[i + delta + 1] << lshift)
		         | (in->sig[i + delta] >> rshift));
	  nonzero |= out->sig[i];
	}
      out->sig[i] = in->sig[i + delta] >> rshift;
      nonzero |= out->sig[i];
      i++;
    }
  else
    {
      for (i = 0; i + delta < SIGSZ; i++)
        {
	  out->sig[i] = in->sig[i + delta];
	  nonzero |= out->sig[i];
	}
    }

  while (i < SIGSZ)
    out->sig[i++] = 0;
  return nonzero;
}

static void
normalize (struct real *out, struct real *in)
{
  int i, msb, delta, rshift, lshift;
  int out_exp;

  out_exp = in->exp;
  delta = 0;
  for (i = SIGSZ; --i >= 0 && in->sig[i] == 0; )
    {
      delta++;
      out_exp -= SIG_ELEM_BITS;
    }

  if (i < 0)
    {
      memset (out, 0, sizeof (struct real));
      return;
    }

  /* TODO: convert this to clz.  */
  msb = in->sig[i];
  lshift = 15;
  if (msb & 0xFF00)
    lshift -= 8;
  else
    msb <<= 8;
  if (msb & 0xF000)
    lshift -= 4;
  else
    msb <<= 4;
  if (msb & 0xC000)
    lshift -= 2;
  else
    msb <<= 2;
  if (msb & 0x8000)
    lshift -= 1;

  rshift = 16 - lshift;
  out->exp = out_exp - lshift;
  out->sign = in->sign;
  if (lshift)
    {
      for (i = SIGSZ; --i - delta >= 1; )
        out->sig[i] = ((in->sig[i - delta] << lshift)
		       | (in->sig[i - delta - 1] >> rshift));
      out->sig[i] = in->sig[0] << lshift;
    }
  else
    {
      for (i = SIGSZ; --i - delta >= 0; )
        out->sig[i] = in->sig[i - delta];
    }

  while (--i >= 0)
    out->sig[i] = 0;
}

/* Adjust IN to have exponent EXP by shifting its significand right.
   Put the result into OUT.  The shift can be done in place.  */
static int
adjust_exp (struct real *out, struct real *in, int exp)
{
  int in_exp;
  in_exp = in->exp;
  assert (exp > in_exp);
  if (exp == in_exp)
    return true;
  if (exp - in_exp >= NUM_SIG_BITS)
    return false;

  out->exp = exp;
  return rshift_sig (out, in, exp - in_exp);
}


void
_gst_real_from_int (struct real *out, int s)
{
  memset (out, 0, sizeof (struct real));
  if (s < 0)
    {
      out->sign = -1;
      s = -s;
    }
  else
    out->sign = 1;

  /* TODO: convert this to clz.  */
  if (s & 0xFF00)
    out->exp += 8;
  else
    s <<= 8;
  if (s & 0xF000)
    out->exp += 4;
  else
    s <<= 4;
  if (s & 0xC000)
    out->exp += 2;
  else
    s <<= 2;
  if (s & 0x8000)
    out->exp += 1;
  else
    s <<= 1;

  out->sig[SIGSZ - 1] = s;
}

static int
add_significands (struct real *r, struct real *s)
{
  int i, carry = 0;
  for (i = 0; i < SIGSZ; i++)
    {
      int result = r->sig[i] + s->sig[i] + carry;
      carry = result >> SIG_ELEM_BITS;
      r->sig[i] = result;
    }

  return carry;
}

static int
cmp_significands (struct real *r, struct real *s)
{
  int i;
  for (i = SIGSZ; --i >= 0; )
    if (r->sig[i] != s->sig[i])
      return (r->sig[i] - s->sig[i]);

  return 0;
}

static void
sub_significands (struct real *r, struct real *s)
{
  int i, carry = 0;
  for (i = 0; i < SIGSZ; i++)
    {
      int result = r->sig[i] - s->sig[i] + carry;
      carry = result >> SIG_ELEM_BITS;
      r->sig[i] = result;
    }
}

static void
do_add (struct real *r, struct real *s)
{
  struct real tmp;

  if (r->exp < s->exp)
    {
      if (!adjust_exp (r, r, s->exp))
	{
	  /* Underflow, R+S = S.  */
	  *r = *s;
	  return;
	}
    }

  else if (r->exp > s->exp)
    {
      /* We cannot modify S in place, use a temporary.  */
      if (!adjust_exp (&tmp, s, r->exp))
	return;
      s = &tmp;
    }

  if (add_significands (r, s))
    {
      /* Lose one bit of precision to fit the carry.  */
      rshift_sig (r, r, 1);
      r->exp++;
      r->sig[SIGSZ - 1] |= SIG_MSB;
    }
}

void
_gst_real_add (struct real *r, struct real *s)
{
  if (!s->sign)
    return;
  if (!r->sign)
    memcpy (r, s, sizeof (struct real));
  else if (s->sign == r->sign)
    return do_add (r, s);
  else
    abort ();
}

void
_gst_real_add_int (struct real *r, int s)
{
  struct real s_real;
  if (!s)
    return;

  _gst_real_from_int (&s_real, s);
  if (!r->sign)
    memcpy (r, &s_real, sizeof (struct real));
  else if (s_real.sign == r->sign)
    return do_add (r, &s_real);
  else
    abort ();
}

static void
do_mul (struct real *r, struct real *s, int lsb)
{
  struct real rr;
  unsigned short mask;
  int n;

  r->exp += s->exp;
  r->sign *= s->sign;

  rr = *r;
  mask = SIG_MSB;
  n = SIGSZ - 1;
  assert (s->sig[n] & mask);
  while (n > lsb || (s->sig[n] & (mask - 1)))
    {
      if (!(mask >>= 1))
	{
	  mask = SIG_MSB;
	  n--;
	}

      /* Dividing rr by 2 matches the weight s->sig[n] & mask.  Exit
	 early in case of underflow.  */
      if (!rshift_sig (&rr, &rr, 1))
        break;

      if (s->sig[n] & mask)
	{
          if (add_significands (r, &rr))
	    {
	      /* Lose one bit of precision to fit the carry.  */
	      rshift_sig (r, r, 1);
	      r->sig[SIGSZ - 1] |= SIG_MSB;
	      r->exp++;
	      if (!rshift_sig (&rr, &rr, 1))
		break;
	      rr.exp++;
	    }
	}
    }
}

void
_gst_real_mul (struct real *r, struct real *s)
{
  int i;
  struct real tmp;
  if (r->sign == 0)
    return;
  if (r == s)
    {
      tmp = *s;
      s = &tmp;
    }
  if (s->sign == 0)
     memset (r, 0, sizeof (struct real));

  for (i = 0; i < SIGSZ && s->sig[i] == 0; )
    i++;
  do_mul (r, s, i);
}

void
_gst_real_mul_int (struct real *r, int s)
{
  struct real s_real;

  if (s == 0)
     memset (r, 0, sizeof (struct real));
  if (r->sign == 0)
    return;

  _gst_real_from_int (&s_real, s);
  do_mul (r, &s_real, SIGSZ - 1);
}


void
_gst_real_powi (struct real *out, struct real *r, int s)
{
  int k;
  struct real tmp;
  if (out == r)
    {
      tmp = *r;
      r = &tmp;
    }

  assert (s > 0);
  _gst_real_from_int (out, 1);
  if (!s)
    return;

  for (k = 1;; k <<= 1)
    {
      if (s & k)
        {
          _gst_real_mul (out, r);
          s ^= k;
          if (!s)
	    break;
        }
      _gst_real_mul (r, r);
    }
}

static void
do_div (struct real *out, struct real *r, struct real *s)
{
  struct real v;
  int msb, i;
  int place = SIGSZ-1;
  int bit = SIG_MSB;

  memset (&v, 0, sizeof (struct real));
  v.sign = r->sign * s->sign;
  v.exp = r->exp - s->exp;
  msb = 0;
  goto start;
  do
    {
      /* Get the MSB of U and shift it left by one.  */
      msb = r->sig[SIGSZ-1] & SIG_MSB;
      for (i = SIGSZ; --i >= 1; )
        r->sig[i] = (r->sig[i] << 1) | (r->sig[i - 1] >> 15);
      r->sig[0] <<= 1;

     start:
      if (msb || cmp_significands (r, s) >= 0)
	{
	  sub_significands (r, s);
	  v.sig[place] |= bit;
	}
    }
  while ((bit >>= 1) || (bit = SIG_MSB, --place >= 0));
  normalize (out, &v);
}

void
_gst_real_div (struct real *out, struct real *r, struct real *s)
{
  assert (s->sign);
  if (!r->sign)
    {
      memset (out, 0, sizeof (struct real));
      return;
    }

  if (r == s)
    {
      memset (out, 0, sizeof (struct real));
      out->sign = 1;
      out->sig[SIGSZ-1] = SIG_MSB;
      return;
    }

  if (out == r)
    do_div (out, out, s);
  else
    {
      /* do_div would destroy R, save it.  */
      struct real u = *r;
      do_div (out, &u, s);
    }
}


void
_gst_real_inv (struct real *out, struct real *s)
{
  struct real u;
  assert (s->sign);
  memset (&u, 0, sizeof (struct real));
  u.sign = 1;
  u.sig[SIGSZ-1] = SIG_MSB;
  do_div (out, &u, s);
}


long double
_gst_real_get_ld (struct real *r)
{
  long double result = 0.0;
  int i;

  for (i = SIGSZ; --i >= 0; )
    {
      result *= SIG_MASK + 1;
      result += r->sig[i];
    }

  result = ldexpl (result, r->exp - NUM_SIG_BITS + 1);
  return r->sign == -1 ? -result : result;
}
