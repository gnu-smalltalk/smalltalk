/*************************************************************************
 *
 * $Id: trio.c,v 1.2 2002/12/15 00:03:45 matthiasc Exp $
 *
 * Copyright (C) 1998 Bjorn Reese and Daniel Stenberg.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE AUTHORS AND
 * CONTRIBUTORS ACCEPT NO RESPONSIBILITY IN ANY CONCEIVABLE MANNER.
 *
 ************************************************************************/

void TrioWriteDouble
TRIO_ARGS6 ((self, x, flags, precision),
	    trio_class_t * self,
	    long double x, unsigned long flags, int precision)
{
  long double int_part, frac_part, y;
  int int_digits, frac_digits, exp_digits, int_accuracy, frac_accuracy,
    exponent = 0, i, digit, zeroes = 0, zeroes_count;
  unsigned int exponent_abs;

  long double int_scale, frac_round_scale, int_round, frac_scale;
  int exp_scale;

  int no_significant_digits;
  int keep_trailing_zeroes;
  int keep_decimal_point;

  keep_trailing_zeroes = (!(flags & FLAGS_FLOAT_G) ||
			  (flags & FLAGS_ALTERNATIVE));

  if (flags & FLAGS_FLOAT_G)
    {
      if (precision == 0)
	precision = 1;

      if ((x < 1.0E-4) || (x > ipowl (10.0L, (long double) precision)))
	/* Use scientific notation */
	flags |= FLAGS_FLOAT_E;
      else if (x < 1.0)
	{
	  /* Use normal notation. If the integer part of the number is
	     zero, then adjust the precision to include leading fractional
	     zeros.  */
	  y = log10 (x);
	  if (y < 0.0)
	    y = -y;
	  if (y - floorl (y) < 0.001)
	    y--;
	  zeroes = (int) floorl (y);
	}
    }

  if (flags & FLAGS_FLOAT_E)
    {
      /* Scale the number */
      y = log10 (x);
      exponent = (int) floorl (y);
      x /= ipowl (10.0L, exponent);
    }

  int_part = floorl (x);
  frac_part = x - int_part;

  /* Truncated number.
     Precision is number of significant digits for FLOAT_G
     and number of fractional digits for others.  */
  int_digits = (int_part > LDBL_EPSILON) ? 1 + (int) log10 (int_part) : 1;
  frac_digits = ((flags & FLAGS_FLOAT_G) && (zeroes == 0))
    ? precision - int_digits : zeroes + precision;

  frac_round_scale = ipowl (10.0L, frac_digits);

  y = x + 0.5 / frac_round_scale;
  if (floorl (x) != floorl (y))
    {
      if (flags & FLAGS_FLOAT_E)
	{
	  /* Adjust if number was rounded up one digit (ie. 0.99 to 1.00) */
	  exponent++;
	  y = (x + 0.5 / frac_round_scale) / 10.0L;
	  int_part = floorl (y);
	  frac_part = y - int_part;
	}
      else
	{
	  /* Adjust if number was rounded up one digit (ie. 99 to 100) */
	  int_part = floorl (x + 0.5);
	  frac_part = 0.0;
	  int_digits = (int_part > LDBL_EPSILON)
	    ? 1 + (int) log10 (int_part) : 1;
	}
    }

  /* Estimate accuracy */
  int_round = frac_scale = 0.5;
  if (int_digits > LDBL_DIG)
    {
      int_accuracy = LDBL_DIG;
      frac_digits = 0;
      frac_round_scale = 1.0;
      frac_accuracy = 0;
      precision = 0;		/* Disable decimal-point */
      int_round = ipowl (10.0L, int_digits - int_accuracy - 1);
      frac_scale = 0.0;
    }
  else
    {
      int_accuracy = int_digits;
      frac_accuracy = frac_digits - int_accuracy;
      frac_scale = 1.0;
    }

  frac_scale /= frac_round_scale;
  no_significant_digits =
    (floorl ((frac_part + frac_scale) * frac_round_scale) < LDBL_EPSILON);
  keep_decimal_point = ((flags & FLAGS_ALTERNATIVE)
			|| !((precision == 0)
			     || (!keep_trailing_zeroes
				 && no_significant_digits)));
  exponent_abs = (exponent < 0) ? -exponent : exponent;
  if (flags & FLAGS_FLOAT_E)
    exp_digits = (exponent_abs == 0)
      ? 1 : (int) ceil (log10 ((double) (exponent_abs + 1)));
  else
    exp_digits = 0;

  /* Output the integer part */
  int_scale = 1.0 / ipowl (10.0L, int_digits - 1);
  for (i = 0; i < int_digits; i++)
    {
      y = floorl (((int_part + int_round) * int_scale));
      if (i > int_accuracy)
	/* Beyond accuracy */
	*buf++ = '0';
      else
	*buf++ = '0' + (int) fmodl (y, 10.0L);
      int_scale *= 10.0L;
    }

  /* Insert decimal point and build the fraction part */
  zeroes_count = 0;

  if (keep_decimal_point)
    *buf++ = '.';

  for (i = 0; i < frac_digits; i++)
    {
      if ((int_digits > int_accuracy) || (i > frac_accuracy))
	/* Beyond accuracy */
	zeroes_count++;
      else
	{
	  frac_part *= 10.0L;
	  frac_scale *= 10.0L;
	  y = floorl (frac_part + frac_scale);
	  frac_part -= y;
	  digit = (int) fmodl (y, 10.0L);
	  if (digit == 0)
	    zeroes_count++;
	  else
	    {
	      /* Were not trailing zeroes after all */
	      while (zeroes_count-- > 0)
		*buf++ = '0';

	      *buf++ = '0' + digit;
	    }
	}
    }

  if (keep_trailing_zeroes)
    while (zeroes_count-- > 0)
      *buf++ = '0';

  /* Output exponent */
  if (exp_digits > 0)
    {
      *buf++ = ((flags & FLAGS_UPPER) ? 'E' : 'e');
      *buf++ = (exponent < 0) ? '-' : '+';

      /* The exponent must contain at least two digits */
      if (exp_digits == 1)
	exp_digits = 2;

      exp_scale = (int) ipowl (10.0L, exp_digits - 1);
      for (i = 0; i < exp_digits; i++)
	{
	  *buf++ = '0' + (exponent_abs / exp_scale) % 10;
	  exp_scale /= 10;
	}
    }
}
