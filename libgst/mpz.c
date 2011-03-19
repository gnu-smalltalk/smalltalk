/******************************** -*- C -*- ****************************
 *
 *	Multiple precision operations for GNU Smalltalk's LargeIntegers
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1991, 2002, 2006, 2007, 2008, 2009 Free Software Foundation, Inc.
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

#include "gstpriv.h"

#if HAVE_GMP
#include <gmp.h>

#define BITS_PER_MP_LIMB (8 * SIZEOF_MP_LIMB_T)

/* Copy NLIMBS *limbs* from SRC to DST.  */
#define MPN_COPY(DST, SRC, NLIMBS) \
  memmove((DST), (SRC), (NLIMBS) * SIZEOF_MP_LIMB_T)

/* Zero NLIMBS *limbs* AT DST.  */
#define MPN_ZERO(DST, NLIMBS) \
  memset((DST), 0, (NLIMBS) * SIZEOF_MP_LIMB_T)

/* Initialize the gst_mpz X with space for NLIMBS limbs.
   X should be a temporary variable, and it will be automatically
   cleared out when the running function returns.  */
#define MPZ_TMP_INIT(X, NLIMBS) \
  do {									\
    (X)->alloc = 0;							\
    (X)->d = (mp_ptr) alloca ((NLIMBS) * SIZEOF_MP_LIMB_T);		\
  } while (0)

/* gst_mpz_realloc -- make the gst_mpz have NEW_SIZE digits allocated.  */
static void *gst_mpz_realloc (gst_mpz *m, mp_size_t new_size);
static void gst_mpz_sub_ui (gst_mpz *dif, const gst_mpz *min, mp_limb_t sub);

static void *
gst_mpz_realloc (gst_mpz *m, mp_size_t new_size)
{
  /* Never allocate zero space.  */
  if (new_size == 0)
    new_size = 1;

  if (new_size > m->alloc)
    {
      m->alloc = new_size;
      m->d = (mp_ptr) xrealloc (m->d, new_size * SIZEOF_MP_LIMB_T);
    }

  return (void *) m->d;
}


/* mpz_sub_ui -- Subtract an unsigned one-word integer from an gst_mpz.  */

static void
gst_mpz_sub_ui (gst_mpz *dif, const gst_mpz *min, mp_limb_t sub)
{
  mp_srcptr minp;
  mp_ptr difp;
  mp_size_t minsize, difsize;
  mp_size_t abs_minsize;

  minsize = min->size;
  abs_minsize = ABS (minsize);

  /* If not space for SUM (and possible carry), increase space.  */
  difsize = abs_minsize + 1;
  if (dif->alloc < difsize)
    gst_mpz_realloc (dif, difsize);

  /* These must be after realloc (ADD1 may be the same as SUM).  */
  minp = min->d;
  difp = dif->d;

  if (sub == 0)
    {
      MPN_COPY (difp, minp, abs_minsize);
      dif->size = minsize;
      return;
    }
  if (abs_minsize == 0)
    {
      difp[0] = sub;
      dif->size = -1;
      return;
    }

  if (minsize < 0)
    {
      difsize = mpn_add_1 (difp, minp, abs_minsize, sub);
      if (difsize != 0)
	difp[abs_minsize] = 1;
      difsize = -(difsize + abs_minsize);
    }
  else
    {
      /* The signs are different.  Need exact comparision to determine
	 which operand to subtract from which.  */
      if (abs_minsize == 1 && minp[0] < sub)
	difsize = -(abs_minsize
		    + mpn_sub_1 (difp, &sub, 1, *minp));
      else
	difsize = (abs_minsize
		   + mpn_sub_1 (difp, minp, abs_minsize, sub));
    }

  dif->size = difsize;
}

void
_gst_mpz_clear (gst_mpz *m)
{
  if (m->alloc)
    xfree (m->d);
}

void
_gst_mpz_add (gst_mpz *sum, const gst_mpz *u, const gst_mpz *v)
{
  mp_srcptr up, vp;
  mp_ptr sump;
  mp_size_t usize, vsize, sumsize;
  mp_size_t abs_usize;
  mp_size_t abs_vsize;

  usize = u->size;
  vsize = v->size;
  abs_usize = ABS (usize);
  abs_vsize = ABS (vsize);

  if (abs_usize < abs_vsize)
    {
      /* Swap U and V.  */
      {const gst_mpz *t = u; u = v; v = t;}
      {mp_size_t t = usize; usize = vsize; vsize = t;}
      {mp_size_t t = abs_usize; abs_usize = abs_vsize; abs_vsize = t;}
    }

  /* True: abs(USIZE) >= abs(VSIZE) */

  /* If not space for sum (and possible carry), increase space.  */
  sumsize = abs_usize + 1;
  if (sum->alloc < sumsize)
    gst_mpz_realloc (sum, sumsize);

  /* These must be after realloc (u or v may be the same as sum).  */
  up = u->d;
  vp = v->d;
  sump = sum->d;

  if (usize >= 0)
    {
      if (vsize >= 0)
	{
	  sumsize = mpn_add (sump, up, abs_usize, vp, abs_vsize);
	  if (sumsize != 0)
	    sump[abs_usize] = 1;
	  sumsize = sumsize + abs_usize;
	}
      else
	{
	  /* The signs are different.  Need exact comparision to determine
	     which operand to subtract from which.  */
	  if (abs_usize == abs_vsize && mpn_cmp (up, vp, abs_usize) < 0)
	    sumsize = -(abs_usize
			+ mpn_sub (sump, vp, abs_usize, up, abs_usize));
	  else
	    sumsize = (abs_usize
		       + mpn_sub (sump, up, abs_usize, vp, abs_vsize));
	}
    }
  else
    {
      if (vsize >= 0)
	{
	  /* The signs are different.  Need exact comparision to determine
	     which operand to subtract from which.  */
	  if (abs_usize == abs_vsize && mpn_cmp (up, vp, abs_usize) < 0)
	    sumsize = (abs_usize
		       + mpn_sub (sump, vp, abs_usize, up, abs_usize));
	  else
	    sumsize = -(abs_usize
			+ mpn_sub (sump, up, abs_usize, vp, abs_vsize));
	}
      else
	{
	  sumsize = mpn_add (sump, up, abs_usize, vp, abs_vsize);
	  if (sumsize != 0)
	    sump[abs_usize] = 1;
	  sumsize = -(sumsize + abs_usize);
	}
    }

  sum->size = sumsize;
}

int
_gst_mpz_cmp (const gst_mpz *u, const gst_mpz *v)
{
  mp_size_t usize = u->size;
  mp_size_t vsize = v->size;
  mp_size_t size;

  if (usize != vsize)
    return usize - vsize;

  if (usize == 0)
    return 0;

  size = ABS (usize);
  if (usize < 0)
    return mpn_cmp (v->d, u->d, size);
  else
    return mpn_cmp (u->d, v->d, size);
}

void
_gst_mpz_com (gst_mpz *dst, const gst_mpz *src)
{
  mp_size_t size = src->size;
  mp_srcptr src_ptr;
  mp_ptr dst_ptr;

  if (size >= 0)
    {
      /* As with infinite precision: one's complement, two's complement.
	 But this can be simplified using the identity -x = ~x + 1.
	 So we're going to compute (~~x) + 1 = x + 1!  */

      if (dst->alloc < size + 1)
	gst_mpz_realloc (dst, size + 1);

      src_ptr = src->d;
      dst_ptr = dst->d;

      if (size == 0)
	{
	  /* Special case, as mpn_add wants the first arg's size >= the
	     second arg's size.  */
	  dst_ptr[0] = 1;
	  dst->size = -1;
	  return;
	}

      {
	int cy;

	cy = mpn_add_1 (dst_ptr, src_ptr, size, 1);
	if (cy)
	  {
	    dst_ptr[size] = cy;
	    size++;
	  }
      }

      /* Store a negative size, to indicate ones-extension.  */
      dst->size = -size;
    }
  else
    {
      /* As with infinite precision: two's complement, then one's complement.
	 But that can be simplified using the identity -x = ~(x - 1).
	 So we're going to compute ~~(x - 1) = x - 1!  */
      size = -size;

      if (dst->alloc < size)
	gst_mpz_realloc (dst, size);

      src_ptr = src->d;
      dst_ptr = dst->d;

      size += mpn_sub_1 (dst_ptr, src_ptr, size, 1);

      /* Store a positive size, to indicate zero-extension.  */
      dst->size = size;
    }
}

void
_gst_mpz_div_2exp (gst_mpz *w, const gst_mpz *u, unsigned cnt)
{
  mp_size_t usize = u->size;
  mp_size_t wsize;
  mp_size_t abs_usize = ABS (usize);
  mp_size_t limb_cnt;

  limb_cnt = cnt / BITS_PER_MP_LIMB;
  wsize = abs_usize - limb_cnt;
  if (wsize <= 0)
    wsize = 0;
  else
    {
      if (w->alloc < wsize)
	gst_mpz_realloc (w, wsize);

      if (cnt % BITS_PER_MP_LIMB)
        mpn_rshift (w->d, u->d + limb_cnt, abs_usize - limb_cnt,
		    cnt % BITS_PER_MP_LIMB);
      else
	MPN_COPY (w->d, u->d + limb_cnt, abs_usize - limb_cnt);

      wsize -= w->d[wsize - 1] == 0;
    }

  w->size = (usize >= 0) ? wsize : -wsize;
}

void
_gst_mpz_tdiv_qr (gst_mpz *quot, gst_mpz *rem, const gst_mpz *num, const gst_mpz *den)
{
  mp_ptr np, dp;
  mp_ptr qp, rp;
  mp_size_t nsize = num->size;
  mp_size_t dsize = den->size;
  mp_size_t qsize;
  mp_size_t sign_remainder = nsize;
  mp_size_t sign_quotient = nsize ^ dsize;

  nsize = ABS (nsize);
  dsize = ABS (dsize);

  /* Ensure space is enough for quotient and remainder.  */

  qsize = nsize - dsize + 1;	/* qsize cannot be bigger than this.  */

  if (qsize <= 0)
    {
      if (num != rem)
	{
	  gst_mpz_realloc (rem, nsize);
	  rem->size = num->size;
	  MPN_COPY (rem->d, num->d, nsize);
	}

      quot->size = 0;
      return;
    }

  if (quot->alloc < qsize)
    gst_mpz_realloc (quot, qsize);

  if (rem->alloc < dsize)
    gst_mpz_realloc (rem, dsize);

  qp = quot->d;
  np = num->d;
  dp = den->d;
  rp = rem->d;

  /* Copy denominator to temporary space if it overlaps with the quotient
     or remainder.  */
  if (dp == rp || dp == qp)
    {
      mp_ptr tp;
      tp = (mp_ptr) alloca (dsize * SIZEOF_MP_LIMB_T);
      MPN_COPY (tp, dp, dsize);
      dp = tp;
    }
  /* Copy numerator to temporary space if it overlaps with the quotient or
     remainder.  */
  if (np == rp || np == qp)
    {
      mp_ptr tp;
      tp = (mp_ptr) alloca (nsize * SIZEOF_MP_LIMB_T);
      MPN_COPY (tp, np, nsize);
      np = tp;
    }

  mpn_tdiv_qr (qp, rp, 0L, np, nsize, dp, dsize);

  qsize -=  qp[qsize - 1] == 0;

  quot->size = sign_quotient >= 0 ? qsize : -qsize;
  rem->size = sign_remainder >= 0 ? dsize : -dsize;
  alloca (0);
}

static void
_gst_mpz_tdiv_q_ui (gst_mpz *quot, const gst_mpz *num, mp_limb_t den)
{
  mp_ptr np;
  mp_ptr qp;
  mp_size_t nsize = num->size;
  mp_size_t sign_quotient = nsize;

  nsize = ABS (nsize);

  if (nsize == 0)
    {
      quot->size = 0;
      return;
    }

  if (quot->alloc < nsize)
    gst_mpz_realloc (quot, nsize);

  qp = quot->d;
  np = num->d;

  /* Copy numerator to temporary space if it overlaps with the quotient.  */
  if (np == qp)
    {
      mp_ptr tp;
      tp = (mp_ptr) alloca (nsize * SIZEOF_MP_LIMB_T);
      MPN_COPY (tp, np, nsize);
      np = tp;
    }

  mpn_divrem_1 (qp, 0L, np, nsize, den);
  nsize -=  qp[nsize - 1] == 0;
  quot->size = sign_quotient >= 0 ? nsize : -nsize;
  alloca (0);
}

mp_limb_t
_gst_mpz_tdiv_qr_si (gst_mpz *quot, const gst_mpz *num, intptr_t den)
{
  mp_ptr np;
  mp_ptr qp;
  mp_size_t nsize = num->size;
  mp_size_t sign_remainder = nsize;
  mp_size_t sign_quotient = nsize ^ den;
  mp_limb_t rem;

  nsize = ABS (nsize);

  if (nsize == 0)
    {
      quot->size = 0;
      return 0;
    }

  if (quot->alloc < nsize)
    gst_mpz_realloc (quot, nsize);

  qp = quot->d;
  np = num->d;

  /* Copy numerator to temporary space if it overlaps with the quotient.  */
  if (np == qp)
    {
      mp_ptr tp;
      tp = (mp_ptr) alloca (nsize * SIZEOF_MP_LIMB_T);
      MPN_COPY (tp, np, nsize);
      np = tp;
    }

  rem = mpn_divrem_1 (qp, 0L, np, nsize, ABS(den));

  nsize -=  qp[nsize - 1] == 0;
  quot->size = sign_quotient >= 0 ? nsize : -nsize;
  alloca (0);
  return sign_remainder >= 0 ? rem : -rem;
}

static inline void
gst_mpz_copy_abs (gst_mpz *d, const gst_mpz *s)
{
  d->size = ABS (s->size);
  if (d != s)
    {
      if (d->alloc < d->size)
	gst_mpz_realloc (d, d->size);
      MPN_COPY (d->d, s->d, d->size);
    }
}

void
_gst_mpz_gcd (gst_mpz *g, const gst_mpz *u, const gst_mpz *v)
{
  int g_zero_bits, u_zero_bits, v_zero_bits;
  mp_size_t g_zero_limbs, u_zero_limbs, v_zero_limbs;
  mp_ptr tp;
  mp_ptr up = u->d;
  mp_size_t usize = ABS (u->size);
  mp_ptr vp = v->d;
  mp_size_t vsize = ABS (v->size);
  mp_size_t gsize;

  /* GCD(0, V) == GCD (U, 1) == V.  */
  if (usize == 0 || (vsize == 1 && vp[0] == 1))
    {
      gst_mpz_copy_abs (g, v);
      return;
    }

  /* GCD(U, 0) == GCD (1, V) == U.  */
  if (vsize == 0 || (usize == 1 && up[0] == 1))
    {
      gst_mpz_copy_abs (g, u);
      return;
    }

  if (usize == 1)
    {
      gst_mpz_realloc (g, 1);
      g->size = 1;
      g->d[0] = mpn_gcd_1 (vp, vsize, up[0]);
      return;
    }

  if (vsize == 1)
    {
      gst_mpz_realloc (g, 1);
      g->size = 1;
      g->d[0] = mpn_gcd_1 (up, usize, vp[0]);
      return;
    }

  /*  Eliminate low zero bits from U and V and move to temporary storage.  */
  u_zero_bits = mpn_scan1 (up, 0);
  u_zero_limbs = u_zero_bits / BITS_PER_MP_LIMB;
  u_zero_bits &= BITS_PER_MP_LIMB - 1;
  up += u_zero_limbs;
  usize -= u_zero_limbs;

  /* Operands could be destroyed for big-endian case, but let's be tidy.  */
  tp = up;
  up = (mp_ptr) alloca (usize * SIZEOF_MP_LIMB_T);
  if (u_zero_bits != 0)
    {
      mpn_rshift (up, tp, usize, u_zero_bits);
      usize -= up[usize - 1] == 0;
    }
  else
    MPN_COPY (up, tp, usize);

  v_zero_bits = mpn_scan1 (vp, 0);
  v_zero_limbs = v_zero_bits / BITS_PER_MP_LIMB;
  v_zero_bits &= BITS_PER_MP_LIMB - 1;
  vp += v_zero_limbs;
  vsize -= v_zero_limbs;

  /* Operands could be destroyed for big-endian case, but let's be tidy.  */
  tp = vp;
  vp = (mp_ptr) alloca (vsize * SIZEOF_MP_LIMB_T);
  if (v_zero_bits != 0)
    {
      mpn_rshift (vp, tp, vsize, v_zero_bits);
      vsize -= vp[vsize - 1] == 0;
    }
  else
    MPN_COPY (vp, tp, vsize);

  if (u_zero_limbs > v_zero_limbs)
    {
      g_zero_limbs = v_zero_limbs;
      g_zero_bits = v_zero_bits;
    }
  else if (u_zero_limbs < v_zero_limbs)
    {
      g_zero_limbs = u_zero_limbs;
      g_zero_bits = u_zero_bits;
    }
  else  /*  Equal.  */
    {
      g_zero_limbs = u_zero_limbs;
      g_zero_bits = MIN (u_zero_bits, v_zero_bits);
    }

  /*  Call mpn_gcd.  The 2nd argument must not have more bits than the 1st.  */
  vsize = (usize < vsize || (usize == vsize && up[usize-1] < vp[vsize-1]))
    ? mpn_gcd (vp, vp, vsize, up, usize)
    : mpn_gcd (vp, up, usize, vp, vsize);

  /*  Here G <-- V << (g_zero_limbs*BITS_PER_MP_LIMB + g_zero_bits).  */
  gsize = vsize + g_zero_limbs;
  if (g_zero_bits != 0)
    {
      mp_limb_t cy_limb;
      gsize += (vp[vsize - 1] >> (BITS_PER_MP_LIMB - g_zero_bits)) != 0;
      if (g->alloc < gsize)
	gst_mpz_realloc (g, gsize);
      MPN_ZERO (g->d, g_zero_limbs);

      tp = g->d + g_zero_limbs;
      cy_limb = mpn_lshift (tp, vp, vsize, g_zero_bits);
      if (cy_limb != 0)
	tp[vsize] = cy_limb;
    }
  else
    {
      if (g->alloc < gsize)
	gst_mpz_realloc (g, gsize);
      MPN_ZERO (g->d, g_zero_limbs);
      MPN_COPY (g->d + g_zero_limbs, vp, vsize);
    }

  g->size = gsize;

  alloca (0);
}


void
_gst_mpz_fdiv_qr (gst_mpz *quot, gst_mpz *rem,
		  const gst_mpz *dividend, const gst_mpz *divisor)
{
  if ((dividend->size ^ divisor->size) >= 0)
    {
      /* When the dividend and the divisor has same sign, this function
	 gives same result as _gst_mpz_tdiv_qr.  */
      _gst_mpz_tdiv_qr (quot, rem, dividend, divisor);
    }
  else
    {
      gst_mpz temp_divisor;	/* N.B.: lives until function returns! */

      /* We need the original value of the divisor after the quotient and
	 remainder have been preliminary calculated.  We have to copy it to
	 temporary space if it's the same variable as either QUOT or REM.  */
      if (quot == divisor || rem == divisor)
	{
	  MPZ_TMP_INIT (&temp_divisor, ABS (divisor->size));
	  _gst_mpz_set (&temp_divisor, divisor);
	  divisor = &temp_divisor;
	}

      _gst_mpz_tdiv_qr (quot, rem, dividend, divisor);
      if (rem->size != 0)
	{
	  gst_mpz_sub_ui (quot, quot, 1);
	  _gst_mpz_add (rem, rem, divisor);
	}
    }
}

mp_limb_t
_gst_mpz_fdiv_qr_si (gst_mpz *quot,
		     const gst_mpz *dividend, intptr_t divisor)
{
  mp_limb_t rem = _gst_mpz_tdiv_qr_si (quot, dividend, divisor);

  /* When the dividend and the divisor has same sign, or if the
     division is exact, this function gives same result as
     _gst_mpz_tdiv_qr_si.  */
  if ((dividend->size ^ divisor) < 0 && rem != 0)
    {
      gst_mpz_sub_ui (quot, quot, 1);
      rem += divisor;
    }

  return rem;
}

void
_gst_mpz_mul (gst_mpz *w, const gst_mpz *u, const gst_mpz *v)
{
  mp_size_t usize = u->size;
  mp_size_t vsize = v->size;
  mp_size_t wsize;
  mp_size_t sign_product;
  mp_ptr up, vp;
  mp_ptr wp;
  mp_ptr free_me = NULL;

  sign_product = usize ^ vsize;
  usize = ABS (usize);
  vsize = ABS (vsize);

  if (usize < vsize)
    {
      /* Swap U and V.  */
      {const gst_mpz *t = u; u = v; v = t;}
      {mp_size_t t = usize; usize = vsize; vsize = t;}
    }

  up = u->d;
  vp = v->d;
  wp = w->d;

  /* Ensure W has space enough to store the result.  */
  wsize = usize + vsize;
  if (w->alloc < wsize)
    {
      if (wp == up || wp == vp)
	free_me = wp;
      else
	xfree (wp);

      w->alloc = wsize;
      wp = (mp_ptr) xmalloc (wsize * SIZEOF_MP_LIMB_T);
      w->d = wp;
    }
  else
    {
      /* Make U and V not overlap with W.  */
      if (wp == up)
	{
	  /* W and U are identical.  Allocate temporary space for U.  */
	  up = (mp_ptr) alloca (usize * SIZEOF_MP_LIMB_T);
	  /* Is V identical too?  Keep it identical with U.  */
	  if (wp == vp)
	    vp = up;
	  /* Copy to the temporary space.  */
	  MPN_COPY (up, wp, usize);
	}
      else if (wp == vp)
	{
	  /* W and V are identical.  Allocate temporary space for V.  */
	  vp = (mp_ptr) alloca (vsize * SIZEOF_MP_LIMB_T);
	  /* Copy to the temporary space.  */
	  MPN_COPY (vp, wp, vsize);
	}
    }

  mpn_mul (wp, up, usize, vp, vsize);
  w->size = sign_product < 0 ? -wsize : wsize;
  if (free_me != NULL)
    xfree (free_me);

  alloca (0);
}

void
_gst_mpz_mul_2exp (gst_mpz *w, const gst_mpz *u, unsigned cnt)
{
  mp_size_t usize = u->size;
  mp_size_t abs_usize = ABS (usize);
  mp_size_t wsize;
  mp_size_t limb_cnt;
  mp_ptr wp;
  mp_limb_t wdigit;

  if (usize == 0)
    {
      w->size = 0;
      return;
    }

  limb_cnt = cnt / BITS_PER_MP_LIMB;
  wsize = abs_usize + limb_cnt + 1;
  if (w->alloc < wsize)
    gst_mpz_realloc (w, wsize);
  wp = w->d;

  if (cnt % BITS_PER_MP_LIMB)
    {
      wdigit = mpn_lshift (wp + limb_cnt, u->d, abs_usize,
			   cnt % BITS_PER_MP_LIMB);
      wsize = abs_usize + limb_cnt;

      if (wdigit != 0)
        {
          wp[wsize] = wdigit;
          wsize++;
        }
    }
  else
    {
      MPN_COPY (wp + limb_cnt, u->d, abs_usize);
      wsize = abs_usize + limb_cnt;
    }

  /* Zero all whole digits at low end.  Do it here and not before calling
     mpn_lshift, not to loose for U == W.  */
  MPN_ZERO (wp, limb_cnt);

  w->size = (usize >= 0) ? wsize : -wsize;
}

void
_gst_mpz_set (gst_mpz *w, const gst_mpz *u)
{
  mp_size_t usize;
  mp_size_t abs_usize;

  usize = u->size;
  abs_usize = ABS (usize);

  /* If not space for sum (and possible carry), increase space.  */
     if (w->alloc < abs_usize)
  gst_mpz_realloc (w, abs_usize);

  w->size = usize;
  MPN_COPY (w->d, u->d, abs_usize);
}

void
_gst_mpz_sub (gst_mpz *w, const gst_mpz *u, const gst_mpz *v)
{
  mp_srcptr up, vp;
  mp_ptr wp;
  mp_size_t usize, vsize, wsize;
  mp_size_t abs_usize;
  mp_size_t abs_vsize;

  usize = u->size;
  vsize = -v->size;		/* The "-" makes the difference from _gst_mpz_add */
  abs_usize = ABS (usize);
  abs_vsize = ABS (vsize);

  if (abs_usize < abs_vsize)
    {
      /* Swap U and V.  */
      {const gst_mpz *t = u; u = v; v = t;}
      {mp_size_t t = usize; usize = vsize; vsize = t;}
      {mp_size_t t = abs_usize; abs_usize = abs_vsize; abs_vsize = t;}
    }

  /* True: abs(USIZE) >= abs(VSIZE) */

  /* If not space for sum (and possible carry), increase space.  */
  wsize = abs_usize + 1;
  if (w->alloc < wsize)
    gst_mpz_realloc (w, wsize);

  /* These must be after realloc (u or v may be the same as w).  */
  up = u->d;
  vp = v->d;
  wp = w->d;

  if (usize >= 0)
    {
      if (vsize >= 0)
	{
	  wsize = mpn_add (wp, up, abs_usize, vp, abs_vsize);
	  if (wsize != 0)
	    wp[abs_usize] = 1;
	  wsize = wsize + abs_usize;
	}
      else
	{
	  /* The signs are different.  Need exact comparision to determine
	     which operand to subtract from which.  */
	  if (abs_usize == abs_vsize && mpn_cmp (up, vp, abs_usize) < 0)
	    wsize = -(abs_usize + mpn_sub (wp, vp, abs_usize, up, abs_usize));
	  else
	    wsize = abs_usize + mpn_sub (wp, up, abs_usize, vp, abs_vsize);
	}
    }
  else
    {
      if (vsize >= 0)
	{
	  /* The signs are different.  Need exact comparision to determine
	     which operand to subtract from which.  */
	  if (abs_usize == abs_vsize && mpn_cmp (up, vp, abs_usize) < 0)
	    wsize = abs_usize + mpn_sub (wp, vp, abs_usize, up, abs_usize);
	  else
	    wsize = -(abs_usize + mpn_sub (wp, up, abs_usize, vp, abs_vsize));
	}
      else
	{
	  wsize = mpn_add (wp, up, abs_usize, vp, abs_vsize);
	  if (wsize != 0)
	    wp[abs_usize] = 1;
	  wsize = -(wsize + abs_usize);
	}
    }

  w->size = wsize;
}

mst_Boolean
_gst_mpz_get_d(const gst_mpz *mpz, double *p_d)
{
  double d, old;
  int n;

  n = mpz->size;
  while (mpz->d[--n] == 0)
    ;

  d = 0.0;
  for (; n >= 0; n--)
    {
      old = ldexp (d, 8 * SIZEOF_MP_LIMB_T);
      d = old + mpz->d[n];

      if (d - old < mpz->d[n])
	/* Lost some bytes of precision, exit now.  */
	return false;
    }

  *p_d = d;
  return true;
}

mst_Boolean
_gst_mpz_get_ld(const gst_mpz *mpz, long double *p_ld)
{
  long double d, old;
  int n;

  n = mpz->size;
  while (mpz->d[--n] == 0)
    ;

  d = 0.0;
  for (; n >= 0; n--)
    {
      old = ldexpl (d, 8 * SIZEOF_MP_LIMB_T);
      d = old + mpz->d[n];

      if (d - old < mpz->d[n])
	/* Lost some bytes of precision, exit now.  */
	return false;
    }

  *p_ld = d;
  return true;
}

void
_gst_mpz_and (gst_mpz *res, const gst_mpz *op1, const gst_mpz *op2)
{
  mp_srcptr op1_ptr, op2_ptr;
  mp_size_t op1_size, op2_size;
  mp_ptr res_ptr;
  mp_size_t res_size;
  mp_size_t i;

  op1_size = op1->size;
  op2_size = op2->size;

  op1_ptr = op1->d;
  op2_ptr = op2->d;
  res_ptr = res->d;

  if (op1_size >= 0)
    {
      if (op2_size >= 0)
	{
	  res_size = MIN (op1_size, op2_size);
	  /* First loop finds the size of the result.  */
	  for (i = res_size - 1; i >= 0; i--)
	    if ((op1_ptr[i] & op2_ptr[i]) != 0)
	      break;
	  res_size = i + 1;

	  /* Handle allocation, now then we know exactly how much space is
	     needed for the result.  */
	  if (res->alloc < res_size)
	    {
	      gst_mpz_realloc (res, res_size);
	      op1_ptr = op1->d;
	      op2_ptr = op2->d;
	      res_ptr = res->d;
	    }

	  /* Second loop computes the real result.  */
	  for (i = res_size - 1; i >= 0; i--)
	    res_ptr[i] = op1_ptr[i] & op2_ptr[i];

	  res->size = res_size;
	  return;
	}
      else /* op2_size < 0 */
	{
	  /* Fall through to the code at the end of the function.  */
	}
    }
  else
    {
      if (op2_size < 0)
	{
	  mp_ptr opx;
	  mp_limb_t cy;
	  mp_size_t res_alloc;

	  /* Both operands are negative, so will be the result.
	     -((-OP1) & (-OP2)) = -(~(OP1 - 1) & ~(OP2 - 1)) =
	     = ~(~(OP1 - 1) & ~(OP2 - 1)) + 1 =
	     = ((OP1 - 1) | (OP2 - 1)) + 1      */

	  /* It might seem as we could end up with an (invalid) result with
	     a leading zero-limb here when one of the operands is of the
	     type 1,,0,,..,,.0.  But some analysis shows that we surely
	     would get carry into the zero-limb in this situation...  */

	  op1_size = -op1_size;
	  op2_size = -op2_size;

	  res_alloc = 1 + MAX (op1_size, op2_size);

	  opx = (mp_ptr) alloca (op1_size * SIZEOF_MP_LIMB_T);
	  mpn_sub_1 (opx, op1_ptr, op1_size, (mp_limb_t) 1);
	  op1_ptr = opx;

	  opx = (mp_ptr) alloca (op2_size * SIZEOF_MP_LIMB_T);
	  mpn_sub_1 (opx, op2_ptr, op2_size, (mp_limb_t) 1);
	  op2_ptr = opx;

	  if (res->alloc < res_alloc)
	    {
	      gst_mpz_realloc (res, res_alloc);
	      res_ptr = res->d;
	      /* Don't re-read OP1_PTR and OP2_PTR.  They point to
		 temporary space--never to the space RES->d used
		 to point to before reallocation.  */
	    }

	  if (op1_size >= op2_size)
	    {
	      MPN_COPY (res_ptr + op2_size, op1_ptr + op2_size,
			op1_size - op2_size);
	      for (i = op2_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] | op2_ptr[i];
	      res_size = op1_size;
	    }
	  else
	    {
	      MPN_COPY (res_ptr + op1_size, op2_ptr + op1_size,
			op2_size - op1_size);
	      for (i = op1_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] | op2_ptr[i];
	      res_size = op2_size;
	    }

	  cy = mpn_add_1 (res_ptr, res_ptr, res_size, (mp_limb_t) 1);
	  if (cy)
	    {
	      res_ptr[res_size] = cy;
	      res_size++;
	    }

	  res->size = -res_size;
	  return;
	}
      else
	{
	  /* We should compute -OP1 & OP2.  Swap OP1 and OP2 and fall
	     through to the code that handles OP1 & -OP2.  */
	  {const gst_mpz *t = op1; op1 = op2; op2 = t;}
	  {const mp_limb_t *t = op1_ptr; op1_ptr = op2_ptr; op2_ptr = t;}
	  {const mp_size_t t = op1_size; op1_size = op2_size; op2_size = t;}
	}

    }

  {
    /* OP1 is positive and zero-extended,
       OP2 is negative and ones-extended.
       The result will be positive.
       OP1 & -OP2 = OP1 & ~(OP2 - 1).  */

    mp_ptr opx;

    op2_size = -op2_size;
    opx = (mp_ptr) alloca (op2_size * SIZEOF_MP_LIMB_T);
    mpn_sub_1 (opx, op2_ptr, op2_size, (mp_limb_t) 1);
    op2_ptr = opx;

    if (op1_size > op2_size)
      {
	/* The result has the same size as OP1, since OP1 is normalized
	   and longer than the ones-extended OP2.  */
	res_size = op1_size;

	/* Handle allocation, now then we know exactly how much space is
	   needed for the result.  */
	if (res->alloc < res_size)
	  {
	    gst_mpz_realloc (res, res_size);
	    res_ptr = res->d;
	    op1_ptr = op1->d;
	    /* Don't re-read OP2_PTR.  It points to temporary space--never
	       to the space RES->d used to point to before reallocation.  */
	  }

	MPN_COPY (res_ptr + op2_size, op1_ptr + op2_size,
		  res_size - op2_size);
	for (i = op2_size - 1; i >= 0; i--)
	  res_ptr[i] = op1_ptr[i] & ~op2_ptr[i];

	res->size = res_size;
      }
    else
      {
	/* Find out the exact result size.  Ignore the high limbs of OP2,
	   OP1 is zero-extended and would make the result zero.  */
	for (i = op1_size - 1; i >= 0; i--)
	  if ((op1_ptr[i] & ~op2_ptr[i]) != 0)
	    break;
	res_size = i + 1;

	/* Handle allocation, now then we know exactly how much space is
	   needed for the result.  */
	if (res->alloc < res_size)
	  {
	    gst_mpz_realloc (res, res_size);
	    res_ptr = res->d;
	    op1_ptr = op1->d;
	    /* Don't re-read OP2_PTR.  It points to temporary space--never
	       to the space RES->d used to point to before reallocation.  */
	  }

	for (i = res_size - 1; i >= 0; i--)
	  res_ptr[i] = op1_ptr[i] & ~op2_ptr[i];

	res->size = res_size;
      }
  }
}

void
_gst_mpz_ior (gst_mpz *res, const gst_mpz *op1, const gst_mpz *op2)
{
  mp_srcptr op1_ptr, op2_ptr;
  mp_size_t op1_size, op2_size;
  mp_ptr res_ptr;
  mp_size_t res_size;
  mp_size_t i;

  op1_size = op1->size;
  op2_size = op2->size;

  op1_ptr = op1->d;
  op2_ptr = op2->d;
  res_ptr = res->d;

  if (op1_size >= 0)
    {
      if (op2_size >= 0)
	{
	  if (op1_size >= op2_size)
	    {
	      if (res->alloc < op1_size)
		{
		  gst_mpz_realloc (res, op1_size);
		  op1_ptr = op1->d;
		  op2_ptr = op2->d;
		  res_ptr = res->d;
		}

	      if (res_ptr != op1_ptr)
		MPN_COPY (res_ptr + op2_size, op1_ptr + op2_size,
			  op1_size - op2_size);
	      for (i = op2_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] | op2_ptr[i];
	      res_size = op1_size;
	    }
	  else
	    {
	      if (res->alloc < op2_size)
		{
		  gst_mpz_realloc (res, op2_size);
		  op1_ptr = op1->d;
		  op2_ptr = op2->d;
		  res_ptr = res->d;
		}

	      if (res_ptr != op2_ptr)
		MPN_COPY (res_ptr + op1_size, op2_ptr + op1_size,
			  op2_size - op1_size);
	      for (i = op1_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] | op2_ptr[i];
	      res_size = op2_size;
	    }

	  res->size = res_size;
	  return;
	}
      else /* op2_size < 0 */
	{
	  /* Fall through to the code at the end of the function.  */
	}
    }
  else
    {
      if (op2_size < 0)
	{
	  mp_ptr opx;
	  mp_limb_t cy;

	  /* Both operands are negative, so will be the result.
	     -((-OP1) | (-OP2)) = -(~(OP1 - 1) | ~(OP2 - 1)) =
	     = ~(~(OP1 - 1) | ~(OP2 - 1)) + 1 =
	     = ((OP1 - 1) & (OP2 - 1)) + 1      */

	  op1_size = -op1_size;
	  op2_size = -op2_size;

	  res_size = MIN (op1_size, op2_size);

	  /* Possible optimization: Decrease mpn_sub precision,
	     as we won't use the entire res of both.  */
	  opx = (mp_ptr) alloca (res_size * SIZEOF_MP_LIMB_T);
	  mpn_sub_1 (opx, op1_ptr, res_size, (mp_limb_t) 1);
	  op1_ptr = opx;

	  opx = (mp_ptr) alloca (res_size * SIZEOF_MP_LIMB_T);
	  mpn_sub_1 (opx, op2_ptr, res_size, (mp_limb_t) 1);
	  op2_ptr = opx;

	  if (res->alloc < res_size)
	    {
	      gst_mpz_realloc (res, res_size);
	      res_ptr = res->d;
	      /* Don't re-read OP1_PTR and OP2_PTR.  They point to
		 temporary space--never to the space RES->d used
		 to point to before reallocation.  */
	    }

	  /* First loop finds the size of the result.  */
	  for (i = res_size - 1; i >= 0; i--)
	    if ((op1_ptr[i] & op2_ptr[i]) != 0)
	      break;
	  res_size = i + 1;

	  if (res_size != 0)
	    {
	      /* Second loop computes the real result.  */
	      for (i = res_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] & op2_ptr[i];

	      cy = mpn_add_1 (res_ptr, res_ptr, res_size, (mp_limb_t) 1);
	      if (cy)
		{
		  res_ptr[res_size] = cy;
		  res_size++;
		}
	    }
	  else
	    {
	      res_ptr[0] = 1;
	      res_size = 1;
	    }

	  res->size = -res_size;
	  return;
	}
      else
	{
	  /* We should compute -OP1 | OP2.  Swap OP1 and OP2 and fall
	     through to the code that handles OP1 | -OP2.  */
	  {const gst_mpz *t = op1; op1 = op2; op2 = t;}
	  {const mp_limb_t *t = op1_ptr; op1_ptr = op2_ptr; op2_ptr = t;}
	  {const mp_size_t t = op1_size; op1_size = op2_size; op2_size = t;}
	}
    }

  {
    mp_ptr opx;
    mp_limb_t cy;
    mp_size_t res_alloc;
    mp_size_t count;

    /* Operand 2 negative, so will be the result.
       -(OP1 | (-OP2)) = -(OP1 | ~(OP2 - 1)) =
       = ~(OP1 | ~(OP2 - 1)) + 1 =
       = (~OP1 & (OP2 - 1)) + 1      */

    op2_size = -op2_size;

    res_alloc = op2_size;

    opx = (mp_ptr) alloca (op2_size * SIZEOF_MP_LIMB_T);
    mpn_sub_1 (opx, op2_ptr, op2_size, (mp_limb_t) 1);
    op2_ptr = opx;
    op2_size -= op2_ptr[op2_size - 1] == 0;

    if (res->alloc < res_alloc)
      {
	gst_mpz_realloc (res, res_alloc);
	op1_ptr = op1->d;
	res_ptr = res->d;
	/* Don't re-read OP2_PTR.  It points to temporary space--never
	   to the space RES->d used to point to before reallocation.  */
      }

    if (op1_size >= op2_size)
      {
	/* We can just ignore the part of OP1 that stretches above OP2,
	   because the result limbs are zero there.  */

	/* First loop finds the size of the result.  */
	for (i = op2_size - 1; i >= 0; i--)
	  if ((~op1_ptr[i] & op2_ptr[i]) != 0)
	    break;
	res_size = i + 1;
	count = res_size;
      }
    else
      {
	res_size = op2_size;

	/* Copy the part of OP2 that stretches above OP1, to RES.  */
	MPN_COPY (res_ptr + op1_size, op2_ptr + op1_size, op2_size - op1_size);
	count = op1_size;
      }

    if (res_size != 0)
      {
	/* Second loop computes the real result.  */
	for (i = count - 1; i >= 0; i--)
	  res_ptr[i] = ~op1_ptr[i] & op2_ptr[i];

	cy = mpn_add_1 (res_ptr, res_ptr, res_size, (mp_limb_t) 1);
	if (cy)
	  {
	    res_ptr[res_size] = cy;
	    res_size++;
	  }
      }
    else
      {
	res_ptr[0] = 1;
	res_size = 1;
      }

    res->size = -res_size;
  }
}

void
_gst_mpz_xor (gst_mpz *res, const gst_mpz *op1, const gst_mpz *op2)
{
  mp_srcptr op1_ptr, op2_ptr;
  mp_size_t op1_size, op2_size;
  mp_ptr res_ptr;
  mp_size_t res_size, res_alloc;
  mp_size_t i;

  op1_size = op1->size;
  op2_size = op2->size;

  op1_ptr = op1->d;
  op2_ptr = op2->d;
  res_ptr = res->d;

  if (op1_size >= 0)
    {
      if (op2_size >= 0)
	{
	  if (op1_size >= op2_size)
	    {
	      if (res->alloc < op1_size)
		{
		  gst_mpz_realloc (res, op1_size);
		  op1_ptr = op1->d;
		  op2_ptr = op2->d;
		  res_ptr = res->d;
		}

	      if (res_ptr != op1_ptr)
		MPN_COPY (res_ptr + op2_size, op1_ptr + op2_size,
			  op1_size - op2_size);
	      for (i = op2_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] ^ op2_ptr[i];
	      res_size = op1_size;
	    }
	  else
	    {
	      if (res->alloc < op2_size)
		{
		  gst_mpz_realloc (res, op2_size);
		  op1_ptr = op1->d;
		  op2_ptr = op2->d;
		  res_ptr = res->d;
		}

	      if (res_ptr != op2_ptr)
		MPN_COPY (res_ptr + op1_size, op2_ptr + op1_size,
			  op2_size - op1_size);
	      for (i = op1_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] ^ op2_ptr[i];
	      res_size = op2_size;
	    }

	  res->size = res_size;
	  return;
	}
      else /* op2_size < 0 */
	{
	  /* Fall through to the code at the end of the function.  */
	}
    }
  else
    {
      if (op2_size < 0)
	{
	  mp_ptr opx;

	  /* Both operands are negative, the result will be positive.
	      (-OP1) ^ (-OP2) =
	     = ~(OP1 - 1) ^ ~(OP2 - 1) =
	     = (OP1 - 1) ^ (OP2 - 1)  */

	  op1_size = -op1_size;
	  op2_size = -op2_size;

	  /* Possible optimization: Decrease mpn_sub precision,
	     as we won't use the entire res of both.  */
	  opx = (mp_ptr) alloca (op1_size * SIZEOF_MP_LIMB_T);
	  mpn_sub_1 (opx, op1_ptr, op1_size, (mp_limb_t) 1);
	  op1_ptr = opx;

	  opx = (mp_ptr) alloca (op2_size * SIZEOF_MP_LIMB_T);
	  mpn_sub_1 (opx, op2_ptr, op2_size, (mp_limb_t) 1);
	  op2_ptr = opx;

	  res_alloc = MAX (op1_size, op2_size);
	  if (res->alloc < res_alloc)
	    {
	      gst_mpz_realloc (res, res_alloc);
	      res_ptr = res->d;
	      /* Don't re-read OP1_PTR and OP2_PTR.  They point to
		 temporary space--never to the space RES->d used
		 to point to before reallocation.  */
	    }

	  if (op1_size > op2_size)
	    {
	      MPN_COPY (res_ptr + op2_size, op1_ptr + op2_size,
			op1_size - op2_size);
	      for (i = op2_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] ^ op2_ptr[i];
	      res_size = op1_size;
	    }
	  else
	    {
	      MPN_COPY (res_ptr + op1_size, op2_ptr + op1_size,
			op2_size - op1_size);
	      for (i = op1_size - 1; i >= 0; i--)
		res_ptr[i] = op1_ptr[i] ^ op2_ptr[i];
	      res_size = op2_size;
	    }

	  res->size = res_size;
	  return;
	}
      else
	{
	  /* We should compute -OP1 ^ OP2.  Swap OP1 and OP2 and fall
	     through to the code that handles OP1 ^ -OP2.  */
	  {const gst_mpz *t = op1; op1 = op2; op2 = t;}
	  {const mp_limb_t *t = op1_ptr; op1_ptr = op2_ptr; op2_ptr = t;}
	  {const mp_size_t t = op1_size; op1_size = op2_size; op2_size = t;}
	}
    }

  {
    mp_ptr opx;
    mp_limb_t cy;

    /* Operand 2 negative, so will be the result.
       -(OP1 ^ (-OP2)) = -(OP1 ^ ~(OP2 - 1)) =
       = ~(OP1 ^ ~(OP2 - 1)) + 1 =
       = (OP1 ^ (OP2 - 1)) + 1      */

    op2_size = -op2_size;

    opx = (mp_ptr) alloca (op2_size * SIZEOF_MP_LIMB_T);
    mpn_sub_1 (opx, op2_ptr, op2_size, (mp_limb_t) 1);
    op2_ptr = opx;

    res_alloc = MAX (op1_size, op2_size) + 1;
    if (res->alloc < res_alloc)
      {
	gst_mpz_realloc (res, res_alloc);
	op1_ptr = op1->d;
	res_ptr = res->d;
	/* Don't re-read OP2_PTR.  It points to temporary space--never
	   to the space RES->d used to point to before reallocation.  */
      }

    if (op1_size > op2_size)
      {
	MPN_COPY (res_ptr + op2_size, op1_ptr + op2_size, op1_size - op2_size);
	for (i = op2_size - 1; i >= 0; i--)
	  res_ptr[i] = op1_ptr[i] ^ op2_ptr[i];
	res_size = op1_size;
      }
    else
      {
	MPN_COPY (res_ptr + op1_size, op2_ptr + op1_size, op2_size - op1_size);
	for (i = op1_size - 1; i >= 0; i--)
	  res_ptr[i] = op1_ptr[i] ^ op2_ptr[i];
	res_size = op2_size;
      }

    cy = mpn_add_1 (res_ptr, res_ptr, res_size, (mp_limb_t) 1);
    if (cy)
      {
	res_ptr[res_size] = cy;
	res_size++;
      }

    res->size = -res_size;
  }
}

#if __GNU_MP_VERSION >= 5
extern void __gmpn_divexact (mp_ptr, mp_srcptr, mp_size_t, mp_srcptr, mp_size_t);
#endif

void
_gst_mpz_divexact (gst_mpz *quot, const gst_mpz *num, const gst_mpz *den)
{
  mp_ptr qp;
  mp_srcptr np, dp;
  mp_size_t nsize, dsize, qsize;
#if __GNU_MP_VERSION < 5
  mp_ptr tp;
  mp_size_t d_zero_limbs;
  int d_zero_bits;
#endif

  nsize = ABS (num->size);
  dsize = ABS (den->size);

  np = num->d;
  dp = den->d;

  if (nsize == 0 || (nsize == 1 && np[0] == 0))
    {
      quot->size = 0;
      return;
    }

  /* Check if newer GMP makes mpn_divexact_1 public.  */
  if (dsize == 1)
    {
      _gst_mpz_tdiv_q_ui (quot, num, dp[0]);
      if (den->size < 0)
	quot->size = -quot->size;
      return;
    }

#if __GNU_MP_VERSION < 5
  /* Avoid quadratic behaviour, but do it conservatively.  */
  if (nsize - dsize > 1500)
    {
      gst_mpz r = { 0, 0, NULL };
      gst_mpz_realloc (&r, dsize + 1);
      _gst_mpz_tdiv_qr (quot, &r, num, den);
      _gst_mpz_clear (&r);
      return;
    }

  /*  QUOT <-- NUM/2^r, T <-- DEN/2^r where = r number of twos in DEN.  */
  d_zero_bits = mpn_scan1 (dp, 0);
  d_zero_limbs = d_zero_bits / BITS_PER_MP_LIMB;
  d_zero_bits &= BITS_PER_MP_LIMB - 1;
  dp += d_zero_limbs;
  dsize -= d_zero_limbs;
  np += d_zero_limbs;
  nsize -= d_zero_limbs;
#endif

  /* Allocate where we place the result.  It must be nsize limbs big
     because it also acts as a temporary area.  */
  if (quot->alloc < nsize)
    gst_mpz_realloc (quot, nsize);
  qp = quot->d;

#if __GNU_MP_VERSION < 5
  if (d_zero_bits != 0)
    {
      tp = (mp_ptr) alloca (dsize * SIZEOF_MP_LIMB_T);
      mpn_rshift (tp, dp, dsize, d_zero_bits);
      mpn_rshift (qp, np, nsize, d_zero_bits);

      dsize -= tp[dsize - 1] == 0;
      nsize -= qp[nsize - 1] == 0;
      dp = tp;
    }
  else
    MPN_COPY(qp, np, nsize);
#endif

  qsize = nsize - dsize + 1;
#if __GNU_MP_VERSION < 5
  mpn_bdivmod (qp, qp, nsize, dp, dsize, qsize * GMP_NUMB_BITS);
#else
  __gmpn_divexact (qp, np, nsize, dp, dsize);
#endif
  quot->size = (num->size ^ den->size) >= 0 ? qsize : -qsize;
}

void
_gst_mpz_from_oop(gst_mpz *mpz, OOP srcOOP)
{
  OOP srcClass;
  gst_byte_array ba;
  mp_limb_t *src, *dest, adjust;
  int n;

  if (IS_INT(srcOOP))
    {
      intptr_t i = TO_INT(srcOOP);
      gst_mpz_realloc (mpz, 1);
      mpz->size = i < 0 ? -1 : 1;
      mpz->d[0] = i < 0 ? -i : i;
      return;
    }

  ba = (gst_byte_array) OOP_TO_OBJ(srcOOP);
  n = TO_INT (ba->objSize) - OBJ_HEADER_SIZE_WORDS;
  srcClass = OOP_CLASS(srcOOP);
  src = (mp_limb_t *) ba->bytes;

  if (srcClass == _gst_large_zero_integer_class)
    {
      gst_mpz_realloc (mpz, 1);
      mpz->size = 1;
      mpz->d[0] = 0;
      return;
    }

  adjust = ((mp_limb_t) ~0UL) >> (8 * (srcOOP->flags & EMPTY_BYTES));

#ifdef WORDS_BIGENDIAN
  /* Big-endian code, we cannot optimize anything...  */
  gst_mpz_realloc(mpz, n);
  dest = mpz->d;
      
  if (srcClass == _gst_large_negative_integer_class)
    {
      mpz->size = -n;
      while (n-- && *src == 0)
	*dest++ = *src++;

      *dest++ = -BYTE_INVERT(*src), src++;
      
      while (n--)
	*dest++ = ~BYTE_INVERT(*src), src++;

    }
  else
    {
      mpz->size =  n;
      while (n--)
	*dest++ = BYTE_INVERT(*src), src++;
    }

#else
  /* Little-endian code, we can optimize positive integers.  */
  if (srcClass == _gst_large_negative_integer_class)
    {
      gst_mpz_realloc(mpz, n);
      mpz->size = -n;
      dest = mpz->d;
      
      while (n-- && *src == 0)
	*dest++ = *src++;

      *dest++ = -*src++;
      
      while (n--)
	*dest++ = ~*src++;
    }
  else if (n % (sizeof (mp_limb_t) / sizeof (PTR)))
    {
      /* We have half a limb in the LargeInteger, so we cannot work
	 directly in the object data.  */

      mpz->size = n;
      while (n--)
	*dest++ = ~*src++;
    }
  else
    {
      /* Point directly in the bytes */
      xfree (mpz->d);
      mpz->alloc = 0;
      mpz->size = n;
      mpz->d = src;
      dest = src + n;
    }
#endif

  /* DEST now points past the limbs in the new gst_mpz.  Don't do
     gratuitous writes to avoid over-GCing.  */
  if (dest[-1] & ~adjust)
    dest[-1] &= adjust;

  /* A few functions require that the most significant limb be >0.  */
  if (mpz->size < 0 && mpz->d[-mpz->size-1] == 0)
    mpz->size++;
  else if (mpz->size > 0 && mpz->d[mpz->size-1] == 0)
    mpz->size--;
}

OOP
_gst_oop_from_mpz(gst_mpz *mpz)
{
  gst_uchar *bytes;
  mp_limb_t *limbs;
  mst_Boolean neg;
  int n;
  OOP oop;
  gst_byte_array ba;

  /* Convert to the absolute value (for ease in referencing mpz->size)
     and remove leading zero bytes.  */

  if (mpz->size < 0)
    {
      mpz->size = -mpz->size;
      neg = true;
    }
  else
    neg = false;

  while (mpz->size && mpz->d[mpz->size-1] == 0)
    mpz->size--;

  if (mpz->size == 0)
    return FROM_INT (0);

  /* Convert to two's complement form and create the object */
  if (neg)
    {
      if (mpz->size == 1 && mpz->d[0] <= (mp_limb_t) -MIN_ST_INT)
	return FROM_INT(-(mp_limb_t) mpz->d[0]);

      n = mpz->size;
      limbs = mpz->d;
      while (n-- && *limbs == 0)
	limbs++;
      *limbs = -*limbs;
      for (limbs++; n--; limbs++)
	*limbs = ~*limbs;
    }
  else
    {
      if (mpz->size == 1 && mpz->d[0] <= (mp_limb_t) MAX_ST_INT)
	return FROM_INT ((mp_limb_t) mpz->d[0]);
    }

#if WORDS_BIGENDIAN
  /* Convert to little-endian */
  for (limbs = mpz->d, n = mpz->size; n--; limbs++)
    *limbs = BYTE_INVERT(*limbs);
#endif

  /* Fill in the object */
  n = SIZEOF_MP_LIMB_T * mpz->size;
  bytes = (gst_uchar *) mpz->d;

  if (neg)
    {
      /* Search where the number really ends -- discard trailing 111... 
	 bytes but remember, the most significant bit of the last digit 
         must be 1! */
      while (bytes[--n] == 255);
      if (bytes[n] < 128)
	n++;

      ba = (gst_byte_array)
        new_instance_with (_gst_large_negative_integer_class, ++n, &oop);
    }
  else
    {
      /* Search where the number really ends -- discard trailing 000... 
         bytes but remember, the most significant bit of the last digit 
         must be 0! */
      while (bytes[--n] == 0);
      if (bytes[n] >= 128)
	n++;

      ba = (gst_byte_array)
        new_instance_with (_gst_large_positive_integer_class, ++n, &oop);
    }

  /* If the last byte was not in our internal object (this is possible,
     for example 16r80000000 fits a single limb but uses a 5-byte object)
     fill in the last byte.  */
  if (n > SIZEOF_MP_LIMB_T * mpz->size)
    ba->bytes[--n] = neg ? 255 : 0;
      
  memcpy (ba->bytes, bytes, n);
  return oop;
}
#endif

