/******************************** -*- C -*- ****************************
 *
 *	Definitions for GNU Smalltalk's multiple precision functions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1991, 2002, 2009 Free Software Foundation, Inc.
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
 * to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/

#ifndef GST_MPZ_H
#define GST_MPZ_H

#if HAVE_GMP
#include <gmp.h>

typedef struct
{
  size_t alloc;			/* Number of *limbs* allocated and pointed
				   to by the D field.  */
  ssize_t size;			/* abs(SIZE) is the number of limbs
				   the last field points to.  If SIZE
				   is negative this is a negative
				   number.  */
  mp_limb_t *d;			/* Pointer to the limbs.  */
} gst_mpz;

/**************** Integer (i.e. Z) routines.  ****************/


/* Add two integers.  */
void _gst_mpz_add (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Compute the two's complement AND of two integers.  */
void _gst_mpz_and (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Compute the two's complement inclusive OR of two integers.  */
void _gst_mpz_ior (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Compute the two's complement XOR of two integers.  */
void _gst_mpz_xor (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Assign the bit-complemented value of an integer to another */
void _gst_mpz_com (gst_mpz *dst, const gst_mpz *src) 
  ATTRIBUTE_HIDDEN;

/* Subtract two integers.  */
void _gst_mpz_sub (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Multiply two integers.  */
void _gst_mpz_mul (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Floor DIVision, with Quotient and Remainder, i.e. division that
   rounds the quotient towards -infinity, and with the remainder
   non-negative.  */
void _gst_mpz_fdiv_qr (gst_mpz *, gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Floor DIVision by a Signed Integer, with Quotient and Remainder.  */
mp_limb_t _gst_mpz_fdiv_qr_si (gst_mpz *quot, const gst_mpz *num, intptr_t den) 
  ATTRIBUTE_HIDDEN;

/* Truncated DIVision, with Quotient and Remainder.  */
void _gst_mpz_tdiv_qr (gst_mpz *, gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Truncated DIVision by a Signed Integer, with Quotient and Remainder.  */
mp_limb_t _gst_mpz_tdiv_qr_si (gst_mpz *quot, const gst_mpz *num, intptr_t den) 
  ATTRIBUTE_HIDDEN;

/* Greatest Common Divisor of two numbers.  */
void _gst_mpz_gcd (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Compare two integers U, V.  Return positive, zero, or negative
   based on if U > V, U == V, or U < V.  */
int _gst_mpz_cmp (const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Convert to double */
mst_Boolean _gst_mpz_get_d (const gst_mpz *, double *) 
  ATTRIBUTE_HIDDEN;

/* Convert to long double */
mst_Boolean _gst_mpz_get_ld (const gst_mpz *, long double *) 
  ATTRIBUTE_HIDDEN;

/* Multiply an integer by 2**CNT  */
void _gst_mpz_mul_2exp (gst_mpz *, const gst_mpz *, unsigned) 
  ATTRIBUTE_HIDDEN;

/* Divide an integer by 2**CNT  */
void _gst_mpz_div_2exp (gst_mpz *, const gst_mpz *, unsigned) 
  ATTRIBUTE_HIDDEN;

/* Divide with no remainder.  */
void _gst_mpz_divexact (gst_mpz *, const gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Allocate space for an integer if necessary, and assign an integer
   from another one.  */
void _gst_mpz_set (gst_mpz *, const gst_mpz *) 
  ATTRIBUTE_HIDDEN;

/* Free an integer */
void _gst_mpz_clear (gst_mpz *m) 
  ATTRIBUTE_HIDDEN;

/* Create an integer from an OOP (an instance of a subclass of
   Integer).  Space from the object itself is pointed to on
   little-endian machines, so you should care that no GC's happen
   while we're manipulating integers.  */
void _gst_mpz_from_oop (gst_mpz *, OOP) 
  ATTRIBUTE_HIDDEN;

/* Create an OOP (an instance of a subclass of Integer) from a big
   integer.  */
OOP _gst_oop_from_mpz (gst_mpz *) 
  ATTRIBUTE_HIDDEN;

#endif

#endif /* GST_MPZ_H */
