/******************************** -*- C -*- ****************************
 *
 *	Definitions for GNU Smalltalk's multiple precision functions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1991, 2002 Free Software Foundation, Inc.
 *
 * This file is derived from an absurdly old version of the GNU MP Library.
 *
 * The GNU MP library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2, or (at
 * your option) any later version.
 *
 * The GNU MP Library is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the GNU MP library; see the file COPYING.  If not, write
 * to the Free Software Foundation, 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 ***********************************************************************/

#ifndef GST_MPZ_H
#define GST_MPZ_H

#if HAVE_GMP
#include <gmp.h>

typedef struct
{
  mp_size_t alloc;		/* Number of *limbs* allocated and pointed
				   to by the D field.  */
  mp_size_t size;		/* abs(SIZE) is the number of limbs
				   the last field points to.  If SIZE
				   is negative this is a negative
				   number.  */
  mp_limb_t *d;			/* Pointer to the limbs.  */
} gst_mpz;

/**************** Integer (i.e. Z) routines.  ****************/


/* Add two integers.  */
void _gst_mpz_add (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Compute the two's complement AND of two integers.  */
void _gst_mpz_and (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Compute the two's complement inclusive OR of two integers.  */
void _gst_mpz_ior (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Compute the two's complement XOR of two integers.  */
void _gst_mpz_xor (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Assign the bit-complemented value of an integer to another */
void _gst_mpz_com (gst_mpz *dst, const gst_mpz *src);

/* Subtract two integers.  */
void _gst_mpz_sub (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Multiply two integers.  */
void _gst_mpz_mul (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Floor DIVision, with Quotient and Remainder, i.e. division that
   rounds the quotient towards -infinity, and with the remainder
   non-negative.  */
void _gst_mpz_fdiv_qr (gst_mpz *, gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Floor DIVision by a Signed Integer, with Quotient and Remainder. */
long _gst_mpz_fdiv_qr_si (gst_mpz *quot, const gst_mpz *num, long den);

/* Truncated DIVision, with Quotient and Remainder. */
void _gst_mpz_tdiv_qr (gst_mpz *, gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Truncated DIVision by a Signed Integer, with Quotient and Remainder. */
long _gst_mpz_tdiv_qr_si (gst_mpz *quot, const gst_mpz *num, long den);

/* Greatest Common Divisor of two numbers. */
void _gst_mpz_gcd (gst_mpz *, const gst_mpz *, const gst_mpz *);

/* Compare two integers U, V.  Return positive, zero, or negative
   based on if U > V, U == V, or U < V.  */
int _gst_mpz_cmp (const gst_mpz *, const gst_mpz *);

/* Convert to double */
double _gst_mpz_get_d (const gst_mpz *);

/* Convert to long double */
long double _gst_mpz_get_ld (const gst_mpz *);

/* Multiply an integer by 2**CNT  */
void _gst_mpz_mul_2exp (gst_mpz *, const gst_mpz *, unsigned long int);

/* Divide an integer by 2**CNT  */
void _gst_mpz_div_2exp (gst_mpz *, const gst_mpz *, unsigned long int);

/* Allocate space for an integer if necessary, and assign an integer
   from another one. */
void _gst_mpz_set (gst_mpz *, const gst_mpz *);

/* Free an integer */
void _gst_mpz_clear (gst_mpz *m);

/* Create an integer from an OOP (an instance of a subclass of
   Integer).  Space from the object itself is pointed to on
   little-endian machines, so you should care that no GC's happen
   while we're manipulating integers. */
void _gst_mpz_from_oop (gst_mpz *, OOP);

/* Create an OOP (an instance of a subclass of Integer) from a big
   integer. */
OOP _gst_oop_from_mpz (gst_mpz *);

#endif

#endif /* GST_MPZ_H */
