/*  -*- Mode: C -*-  */

/* format.c --- printf clone for argv arrays
 * Copyright (C) 1998, 1999, 2000, 2002 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1998
 * This file is part of Snprintfv
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * As a special exception to the GNU General Public License, if you
 * distribute this file as part of a program that also links with and
 * uses the libopts library from AutoGen, you may include it under
 * the same distribution terms used by the libopts library.
 */

/* Code: */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef WITH_DMALLOC
#  include <dmalloc.h>
#endif

#include <float.h>
#include <math.h>
#include <stddef.h>

#ifdef HAVE_WCHAR_H
#  include <wchar.h>
#endif

#include "printf.h"

#ifndef NO_FLOAT_PRINTING
# ifdef HAVE_LONG_DOUBLE
#  ifndef HAVE_FREXPL
static long double frexpl (long double x, int *exp);
#  endif
#  ifndef HAVE_LDEXPL
static long double ldexpl (long double x, int exp);
#  endif
# else
#  define frexpl frexp
#  define ldexpl ldexp
# endif
#endif


static uintmax_t
fetch_uintmax (struct printf_info *pinfo, union printf_arg const *arg)
{
  if (pinfo->is_long_double)
    return (uintmax_t) arg->pa_u_long_long_int;

  if (pinfo->is_long)
    return (uintmax_t) arg->pa_u_long_int;

  if (pinfo->is_short)
    return (uintmax_t) arg->pa_u_short_int;

  if (pinfo->is_char)
    return (uintmax_t) arg->pa_char;

  return (uintmax_t) arg->pa_u_int;
}

static intmax_t
fetch_intmax (struct printf_info *pinfo, union printf_arg const *arg)
{
  if (pinfo->is_long_double)
    return (intmax_t) (signed long long) arg->pa_long_long_int;

  if (pinfo->is_long)
    return (intmax_t) (signed long) arg->pa_long_int;

  if (pinfo->is_short)
    return (intmax_t) (signed short) arg->pa_short_int;

  if (pinfo->is_char)
    return (intmax_t) (signed char) arg->pa_char;

  return (intmax_t) (signed int) arg->pa_int;
}
 
#ifndef NO_FLOAT_PRINTING
static long double
fetch_double (struct printf_info *pinfo, union printf_arg const *arg)
{
  if (pinfo->is_long_double)
    return arg->pa_long_double;
  else
    return (long double) (arg->pa_double);
}
#endif


#ifndef NO_FLOAT_PRINTING
#ifndef HAVE_COPYSIGNL
long double
copysignl (long double x, long double y)
{
#ifdef HAVE_COPYSIGN
  return x * (long double) copysign (1.0, x * y);
#else
  /* If we do not have copysign, assume zero is unsigned (too risky to
     assume we have infinities, which would allow to test with
     (x < 0.0 && 1.0 / x < 0.0).  */
  return (x < 0.0 ^ y < 0.0) ? x * -1.0 : x;
#endif
}
#endif

static long double
ipow (long double base, int n)
{
  int k = 1;
  long double result = 1.0;
  if (n < 0)
    {
      base = 1.0 / base;
      n = -n;
    }

  while (n)
    {
      if (n & k)
	{
	  result *= base;
	  n ^= k;
	}
      base *= base;
      k <<= 1;
    }
  return result;
}

static int
print_float (struct printf_info *pinfo, char *buf, long double n)
{
  /* Print value of n in a buffer in the given base.
     Based upon the algorithm outlined in:
     Robert G. Burger and R. Kent Dybvig
     Printing Floating Point Numbers Quickly and Accurately
     ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
     June 1996.

     This version performs all calculations with long doubles. */

#ifdef HAVE_LONG_DOUBLE
#define OUT_BITS (LDBL_MANT_DIG - 3)
#define BASE 10.0L
#define LOG_BASE 3.3219280948873623478703194294893901758648L
#else
#define OUT_BITS (DBL_MANT_DIG - 3)
#define BASE 10.0
#define LOG_BASE 3.3219280948873623478703194294893901758648
#endif

  int exp, base_exp, d, zeros_dropped = 0, dec_point_count, prec;
  boolean g_format, fixed_format, drop_zeros, tc1, tc2;
  long double m, m_plus, m_minus, significand, round, scale;
  char exp_char, *p = buf;

  /* Parse the specifier and adapt our printing format to it */
  exp_char = pinfo->spec < 'a' ? 'E' : 'e';
  prec = pinfo->prec;
  switch (pinfo->spec)
    {
    case 'e':
    case 'E':
      drop_zeros = FALSE;
      fixed_format = FALSE;
      g_format = FALSE;
      break;

    case 'f':
    case 'F':
      drop_zeros = FALSE;
      fixed_format = TRUE;
      g_format = FALSE;
      break;

    case 'g':
    case 'G':
      prec = pinfo->prec = MAX (1, prec);
      drop_zeros = !pinfo->alt;
      g_format = TRUE;
      break;

    default:
      abort ();
    }

  /* Do the special cases: nans, infinities, zero, and negative numbers. */
  if (n != n)
    {
      /* Not-a-numbers are printed as a simple string. */
      *p++ = pinfo->spec < 'a' ? 'N' : 'n';
      *p++ = pinfo->spec < 'a' ? 'A' : 'a';
      *p++ = pinfo->spec < 'a' ? 'N' : 'n';
      return p - buf;
    }

  /* Zero and infinity also can have a sign in front of them. */
  if (copysignl (1.0, n) < 0.0)
    {
      n = -1.0 * n;
      *p++ = '-';
    }
  else if (pinfo->showsign)
    *p++ = '+';
  else if (pinfo->space)
    *p++ = ' ';

  if (n == 0.0)
    {
      /* Zero is printed as either '0' or '0.00000...' */
      *p++ = '0';

      /* For 'g' and 'G', we printed a significant digit. */
      if (pinfo->spec == 'g' || pinfo->spec == 'G')
	prec--;

      if (!drop_zeros && (prec > 0 || pinfo->alt))
	{
	  *p++ = '.';
	  memset (p, '0', prec);
	  p += prec;
	}

      if (pinfo->spec == 'e' || pinfo->spec == 'E')
	{
	  *p++ = pinfo->spec;
	  *p++ = '+';
	  *p++ = '0';
	  *p++ = '0';
	}

      return p - buf;
    }

  if ((n - n) != (n - n))
    {
      /* Infinities are printed as a simple string. */
      *p++ = pinfo->spec < 'a' ? 'I' : 'i';
      *p++ = pinfo->spec < 'a' ? 'N' : 'n';
      *p++ = pinfo->spec < 'a' ? 'F' : 'f';
      return p - buf;
    }

  /* Do the black magic required to initialize the loop. */
  significand = frexpl (n, &exp);
  base_exp = ceil (exp / LOG_BASE);

  /* The algorithm repeatedly strips off the leading digit
     of the number, prints it, and multiplies by 10 to get
     the next one.  However to avoid overflows when we have
     big numbers or denormals (whose reciprocal is +Inf) we
     have sometimes to work on scaled versions of n.  This
     scaling factor goes into m.

     m_plus and m_minus track the indetermination in the bits
     of n that we print (not n/m in this case) so that we have
     a precise measure of when we have printed a number that
     is equivalent to n.  */

  m = 1.0;
  if (exp >= 0)
    {
      m_plus = ldexpl (1.0, exp - OUT_BITS);
      m_minus = (significand != 1.0) ? m_plus : m_plus / 2.0;
    }
  else
    {
      n = ldexpl (n, OUT_BITS);
      m = ldexpl (m, OUT_BITS);
#ifdef HAVE_LONG_DOUBLE
      m_minus = ldexpl (1.0, MAX (exp, LDBL_MIN_EXP - 3));
      m_plus = (exp == LDBL_MIN_EXP - 2 || significand != 1.0)
	? m_minus : m_minus * 2.0;
#else
      m_minus = ldexpl (1.0, MAX (exp, DBL_MIN_EXP - 3));
      m_plus = (exp == DBL_MIN_EXP - 2 || significand != 1.0)
	? m_minus : m_minus * 2.0;
#endif
    }

  if (base_exp >= 0)
    {
#ifdef HAVE_LONG_DOUBLE
      if (exp == LDBL_MAX_EXP)
#else
      if (exp == DBL_MAX_EXP)
#endif
	{
	  /* Scale down to prevent overflow to Infinity during conversion */
	  n /= BASE;
	  m /= BASE;
	  m_plus /= BASE;
	  m_minus /= BASE;
	  base_exp--;
	}
    }
  else
    {
#ifdef HAVE_LONG_DOUBLE
      if (exp < LDBL_MIN_EXP - 2)
#else
      if (exp < DBL_MIN_EXP - 2)
#endif
	{
	  /* Scale up to prevent denorm reciprocals overflowing to Infinity */
	  d = ceil (53 / LOG_BASE);
	  scale = ipow (BASE, d);
	  n *= scale;
	  m *= scale;
	  m_plus *= scale;
	  m_minus *= scale;
	}
    }

  /* Modify m so that 1 <= n/m < 10 and round the last printed digits.  If
     the precision is high enough, the RHS is too small to actually change
     n, so we still need to check for rounding in the loop below.  */
  m *= ipow (BASE, base_exp);
  base_exp++;

  for (;;)
    {
      /* Decide which format to adopt for %g and %G */
      if (g_format)
        fixed_format = base_exp > -4 && base_exp <= pinfo->prec;
    
      dec_point_count = fixed_format ? base_exp : 1;

      /* For %g/%G, the precision specifies the number of printed
         significant digits, not the number of decimal digits.  */
      if (g_format)
        prec = pinfo->prec - dec_point_count;

      round = m * 5 * ipow (BASE, -dec_point_count - prec);

      if (n + round >= BASE * m)
        m *= BASE, base_exp++;

      else if (n + round + m_plus < m)
        m /= BASE, base_exp--;

      else
	break;
    }

  /* Not in scientific notation.  Print 0.00000's if needed */
  if (fixed_format)
    {
      if (dec_point_count <= 0)
	*p++ = '0';

      if (dec_point_count < 0)
	{
	  *p++ = '.';
	  memset (p, '0', -dec_point_count);
	  p += MIN (prec, -dec_point_count);
	}
    }

  n += round;

  do
    {
      /* Extract the most significant digit and test the
	 two termination conditions corresponding to underflow. */
      d = floor (n / m);
      n -= d * m;

      tc1 = n < m_minus;
      tc2 = n + m_plus >= m;
      if (tc2 && (!tc1 || n * 2.0 >= m))
	/* Check whether printing the correct value requires us
	   to round towards +infinity. */
	d++;

      if (drop_zeros && d == 0 && dec_point_count <= 0)
	/* Keep a count of trailing zeros after the decimal point. */
	zeros_dropped++;
      else
	{
	  /* Write zeros that we thought were trailing. */
	  if (dec_point_count == -zeros_dropped)
	    *p++ = '.';

	  while (zeros_dropped--)
	    *p++ = '0';

	  zeros_dropped = 0;
	  *p++ = d + '0';
	}

      n *= BASE;
      m_plus *= BASE;
      m_minus *= BASE;
    }
  /* Exit when we underflow n, or when we wrote all the
     decimal places we were asked for. */
  while (--dec_point_count > -prec && !tc1 && !tc2);

  /* Write trailing zeros *before* the decimal point. */
  if (dec_point_count > 0)
    {
      memset (p, '0', dec_point_count);
      p += dec_point_count;
      dec_point_count = 0;
    }

  /* Don't put the decimal point if there are no trailing
     zeros, unless %# was given. */
  if (dec_point_count == 0 && (prec > 0 || pinfo->alt))
    *p++ = '.';

  /* If asked for, write trailing zeros *after* the decimal point. */
  if (!drop_zeros && prec + dec_point_count > 0)
    {
      memset (p, '0', prec + dec_point_count);
      p += prec + dec_point_count;
    }

  /* Print the exponent now. */
  if (!fixed_format)
    {
      char x[10], *q = x;
      *p++ = exp_char;
      base_exp--;
      if (base_exp < 0)
	{
	  *p++ = '-';
	  base_exp = -base_exp;
	}
      else
	*p++ = '+';

      if (base_exp < 10)
	/* At least two digits in the exponent please. */
	*p++ = '0';

      do
	{
	  *q++ = base_exp % 10 + '0';
	  base_exp /= 10;
	}
      while (base_exp != 0);

      /* Copy to the main buffer in reverse order */
      while (q > x)
	*p++ = *--q;
    }

  return p - buf;
}
#endif


static int
printf_flag_info (struct printf_info *const pinfo, size_t n, int *argtypes)
{
  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  if (!(pinfo->state & (SNV_STATE_BEGIN | SNV_STATE_FLAG)))
    {
      PRINTF_ERROR (pinfo, "invalid specifier");
      return -1;
    }

  pinfo->state = SNV_STATE_FLAG;

  while (pinfo->state & SNV_STATE_FLAG)
    {
      switch (*pinfo->format)
	{
	case '#':
	  pinfo->alt = TRUE;
	  pinfo->format++;
	  break;

	case '0':
	  if (!pinfo->left)
	    pinfo->pad = '0';
	  pinfo->format++;
	  break;

	case '-':
	  pinfo->pad = ' ';
	  pinfo->left = TRUE;
	  pinfo->format++;
	  break;

	case ' ':
	  pinfo->space = TRUE;
	  pinfo->format++;
	  break;

	case '+':
	  pinfo->showsign = TRUE;
	  pinfo->format++;
	  break;

	case '\'':
	  pinfo->group = TRUE;
	  pinfo->format++;
	  break;

	default:
	  pinfo->state = ~(SNV_STATE_BEGIN | SNV_STATE_FLAG);
	  break;
	}
    }

  pinfo->format--;

  /* Return the number of characters emitted. */
  return 0;
}

/* This function has considerably more freedom than the others in
   playing with pinfo; in particular, it modifies argindex and can
   return completely bogus values whose only purpose is to extend
   the argtypes vector so that it has enough items for the positional
   parameter of the width (in the *n$ case).  It also expects that
   argtypes = (base of argtypes vector) + pinfo->argindex.

   This is messy, suggestion for simplifying it are gladly accepted.  */
static int
printf_numeric_param_info (struct printf_info *const pinfo, size_t n, int *argtypes)
{
  const char *pEnd = NULL;
  int found = 0, allowed_states, new_state;
  int position = 0, skipped_args = 0;
  long value;

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* If we are looking at a ``.'', then this is a precision parameter. */
  if (*pinfo->format == '.')
    {
      pinfo->format++;
      found |= 1;
    }

  /* First we might have a ``*''. */
  if (*pinfo->format == '*')
    {
      pinfo->format++;
      found |= 2;
    }

  /* Parse the number. */
  for (pEnd = pinfo->format, value = 0; *pEnd >= '0' && *pEnd <= '9'; pEnd++)
    value = value * 10 + (*pEnd - '0');

  if (pEnd > pinfo->format)
    {
      pinfo->format = pEnd;
      found |= 4;
    }

  if (value > INT_MAX)
    {
      PRINTF_ERROR (pinfo, "out of range");
      return -1;
    }

  /* And finally a dollar sign. */
  if (*pinfo->format == '$')
    {
      if (value == 0)
	{
          PRINTF_ERROR (pinfo, "invalid position specifier");
          return -1;
	}

      position = value;
      pinfo->format++;
      found |= 8;
    }

  switch (found & 14)
    {
    /* We found a * specification */
    case 2:
      if (pinfo->args)
	value = pinfo->args[pinfo->argindex].pa_int;
      if (n)
	argtypes[0] = PA_INT;
      pinfo->argindex++;
      skipped_args = 1;
      found ^= 6;
      break;

    /* We found a *n$ specification */
    case 14:
      if (n + pinfo->argindex > position - 1)
	argtypes[position - 1 - pinfo->argindex] = PA_INT;

      /* Else there is not enough space, reallocate and retry please...
         ... but we must say how much to skip.  */
      if (position >= pinfo->argindex)
        skipped_args = position - pinfo->argindex;

      if (pinfo->args)
	value = pinfo->args[position - 1].pa_int;
      found ^= 10;
      break;
    }

  switch (found)
    {
    /* We must have read a width specification. */
    case 4:
      allowed_states = SNV_STATE_BEGIN | SNV_STATE_WIDTH;
      new_state = ~(SNV_STATE_BEGIN | SNV_STATE_FLAG | SNV_STATE_WIDTH);

      /* How awful... */
      if (value < 0)
	{
	  pinfo->pad = ' ';
	  pinfo->left = TRUE;
	  value = -value;
	}

      pinfo->width = value;
      break;

    /* We must have read a precision specification. */
    case 5:
      allowed_states = SNV_STATE_PRECISION | SNV_STATE_BEGIN;
      new_state = SNV_STATE_MODIFIER | SNV_STATE_SPECIFIER;
      pinfo->prec = value;
      break;

    /* We must have read a position specification. */
    case 12:
      allowed_states = SNV_STATE_BEGIN;
      new_state = ~SNV_STATE_BEGIN;
      pinfo->dollar = position;
      break;

    /* We must have read something bogus. */
    default:
      PRINTF_ERROR (pinfo, "invalid specifier");
      return -1;
    }

  if (!(pinfo->state & allowed_states))
    {
      PRINTF_ERROR (pinfo, "invalid specifier");
      return -1;
    }

  pinfo->state = new_state;
  pinfo->format--;
  return skipped_args;
}

static int
printf_modifier_info (struct printf_info *const pinfo, size_t n, int *argtypes)
{
  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Check for valid pre-state. */
  if (!(pinfo->state & (SNV_STATE_BEGIN | SNV_STATE_MODIFIER)))
    {
      PRINTF_ERROR (pinfo, "out of range");
      return -1;
    }

  while (pinfo->state != SNV_STATE_SPECIFIER)
    {
      switch (*pinfo->format)
	{
	case 'h':
	  if (*++pinfo->format != 'h')
	    {
	      pinfo->is_short = TRUE;
	      break;
	    }

	  pinfo->is_char = TRUE;
	  pinfo->format++;
	  break;

	case 'z':
	  if (sizeof (size_t) > sizeof (char *))
	    pinfo->is_long_double = TRUE;
	  else
	    pinfo->is_long = TRUE;

	  pinfo->format++;
	  break;

	case 't':
	  if (sizeof (ptrdiff_t) > sizeof (char *))
	    pinfo->is_long_double = TRUE;
	  else
	    pinfo->is_long = TRUE;

	  pinfo->format++;
	  break;

	case 'l':
	  if (*++pinfo->format != 'l')
	    {
	      pinfo->is_long = TRUE;
	      break;
	    }
	 /*NOBREAK*/ 

	case 'j':
	case 'q':
	case 'L':
	  pinfo->is_long_double = TRUE;
	  pinfo->format++;
	  break;

	default:
	  pinfo->state = SNV_STATE_SPECIFIER;
	  pinfo->format--;
	  break;
	}
    }

  /* Return the number of characters emitted. */
  return 0;
}


static int
printf_char (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  int count_or_errorcode = SNV_OK;
  char ch = '\0';

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Check for valid pre-state. */
  if (pinfo->prec != -1
     || pinfo->is_char || pinfo->is_short || pinfo->is_long
     || pinfo->is_long_double || pinfo->pad == '0'
     || pinfo->alt || pinfo->space || pinfo->showsign)
    {
      PRINTF_ERROR (pinfo, "invalid flags");
      return -1;
    }

  /* Extract the correct argument from the arg vector. */
  ch = args->pa_char;

  /* Left pad to the width if the supplied argument is less than
     the width specifier.  */
  if ((pinfo->width > 1) && !pinfo->left)
    {
      int padwidth = pinfo->width - 1;

      while ((count_or_errorcode >= 0) && (count_or_errorcode < padwidth))
	SNV_EMIT (pinfo->pad, stream, count_or_errorcode);
    }

  /* Emit the character argument.  */
  SNV_EMIT (ch, stream, count_or_errorcode);

  /* Right pad to the width if we still didn't reach the specified
     width and the left justify flag was set.  */
  if ((count_or_errorcode < pinfo->width) && pinfo->left)
    while ((count_or_errorcode >= 0)
	   && (count_or_errorcode < pinfo->width))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Return the number of characters emitted. */
  return count_or_errorcode;
}

#ifndef NO_FLOAT_PRINTING
static int
printf_float (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  long double value = 0.0;
  int len, count_or_errorcode = SNV_OK;
#ifdef HAVE_LONG_DOUBLE
  char buffer[LDBL_MAX_10_EXP + 20], *p = buffer;
#else
  char buffer[DBL_MAX_10_EXP + 20], *p = buffer;
#endif

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Check for valid pre-state */
  if (pinfo->prec == -1)
    pinfo->prec = SNV_POINTER_TO_INT (pinfo->extra);

  /* Check for valid pre-state. */
  if (pinfo->prec <= -1
     || pinfo->is_char || pinfo->is_short || pinfo->is_long)
    {
      PRINTF_ERROR (pinfo, "invalid flags");
      return -1;
    }

  /* Extract the correct argument from the arg vector. */
  value = fetch_double (pinfo, args);

  /* Convert the number into a string. */
  len = print_float (pinfo, buffer, value);

  pinfo->width -= len;

  /* Left pad to the remaining width if the supplied argument is less
     than the width specifier, and the padding character is ' '.  */
  if (pinfo->pad == ' ' && !pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Display any sign character. */
  if (count_or_errorcode >= 0)
    {
      if (*p == '+' || *p == '-' || *p == ' ')
	{
	  SNV_EMIT (*p++, stream, count_or_errorcode);
	  len--;
	}
    }

  /* Left pad to the remaining width if the supplied argument is less
     than the width specifier, and the padding character is not ' '.  */
  if (pinfo->pad != ' ' && !pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
	SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Fill the stream buffer with as many characters from the number
     buffer as possible without overflowing.  */
  while ((count_or_errorcode >= 0) && (len-- > 0))
    SNV_EMIT (*p++, stream, count_or_errorcode);

  /* Right pad to the width if we still didn't reach the specified
     width and the left justify flag was set.  */
  if (pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Return the number of characters emitted. */
  return count_or_errorcode;
}
#endif

static int
printf_count (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  if (pinfo->is_char)
    *(char *) (args->pa_pointer) = pinfo->count;

  else if (pinfo->is_short)
    *(short *) (args->pa_pointer) = pinfo->count;

  else if (pinfo->is_long)
    *(long *) (args->pa_pointer) = pinfo->count;

  else if (pinfo->is_long_double)
    *(intmax_t *) (args->pa_pointer) = pinfo->count;

  else
    *(int *) (args->pa_pointer) = pinfo->count;

  return 0;
}

static int
printf_integer (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  static const char digits_lower[] = "0123456789abcdefghijklmnopqrstuvwxyz";
  static const char digits_upper[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const char *digits;

  unsigned base = SNV_POINTER_TO_UINT (pinfo->extra);
  uintmax_t value = 0L;
  int type, count_or_errorcode = SNV_OK;
  char buffer[256], *p, *end;
  boolean is_negative = FALSE;

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Check for valid pre-state. */
  if (!(pinfo->state & (SNV_STATE_BEGIN | SNV_STATE_SPECIFIER)))
    {
      PRINTF_ERROR (pinfo, "out of range");
      return -1;
    }

  /* Upper or lower-case hex conversion? */
  digits = ((pinfo->spec >= 'a') && (pinfo->spec <= 'z'))
    ? digits_lower : digits_upper;

  if (pinfo->prec == -1)
    pinfo->prec = 0;

  /* Check for valid pre-state. */
  if (pinfo->prec < 0)
    {
      PRINTF_ERROR (pinfo, "invalid precision");
      return -1;
    }

  type = pinfo->type;

  /* Extract the correct argument from the arg vector. */
  if (type & PA_FLAG_UNSIGNED)
    {
      value = fetch_uintmax (pinfo, args);
      is_negative = FALSE;
      pinfo->showsign = pinfo->space = FALSE;
    }
  else
    {
      intmax_t svalue = 0L;
      svalue = fetch_intmax (pinfo, args);
      is_negative = (svalue < 0);
      value = (uintmax_t) ABS (svalue);
    }

  /* Convert the number into a string. */
  p = end = &buffer[sizeof (buffer) - 1];

  if (value == 0)
    *p-- = '0';

  else
    while (value > 0)
      {
	*p-- = digits[value % base];
	value /= base;
      }

  pinfo->width -= end - p;
  pinfo->prec -= end - p;

  /* Octal numbers have a leading zero in alterate form. */
  if (pinfo->alt && base == 8)
    {
      *p-- = '0';
      --pinfo->width;
    }

  /* Left pad with zeros to make up the precision. */
  if (pinfo->prec > 0)
    {
      pinfo->width -= pinfo->prec;
      while (pinfo->prec-- > 0)
	*p-- = '0';
    }

  /* Reserve room for leading `0x' for hexadecimal. */
  if (pinfo->alt && base == 16)
    pinfo->width -= 2;

  /* Reserve room for a sign character. */
  if (is_negative || pinfo->showsign || pinfo->space)
    --pinfo->width;

  /* Left pad to the remaining width if the supplied argument is less
   * than the width specifier, and the padding character is ' '.
   */
  if (pinfo->pad == ' ' && !pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Display any sign character. */
  if (count_or_errorcode >= 0)
    {
      if (is_negative)
	SNV_EMIT ('-', stream, count_or_errorcode);
      else if (pinfo->showsign)
	SNV_EMIT ('+', stream, count_or_errorcode);
      else if (pinfo->space)
	SNV_EMIT (' ', stream, count_or_errorcode);
    }

  /* Display `0x' for alternate hexadecimal specifier. */
  if ((count_or_errorcode >= 0) && (base == 16) && pinfo->alt)
    {
      SNV_EMIT ('0', stream, count_or_errorcode);
      SNV_EMIT (digits['X' - 'A' + 10], stream, count_or_errorcode);
    }

  /* Left pad to the remaining width if the supplied argument is less
   * than the width specifier, and the padding character is not ' '.
   */
  if (pinfo->pad != ' ' && !pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Fill the stream buffer with as many characters from the number
   * buffer as possible without overflowing.
   */
  while ((count_or_errorcode >= 0) && (++p < &buffer[sizeof (buffer)]))
    SNV_EMIT (*p, stream, count_or_errorcode);

  /* Right pad to the width if we still didn't reach the specified
   * width and the left justify flag was set.
   */
  if (pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Return the number of characters emitted. */
  return count_or_errorcode;
}

static int
printf_pointer (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  int count_or_errorcode = SNV_OK;

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Read these now to advance the argument pointer appropriately */
  if (pinfo->prec == -1)
    pinfo->prec = 0;

  /* Check for valid pre-state. */
  if (pinfo->prec <= -1
     || pinfo->is_char || pinfo->is_short || pinfo->is_long
     || pinfo->is_long_double)
    {
      PRINTF_ERROR (pinfo, "invalid flags");
      return -1;
    }

  /* Always print 0x. */
  pinfo->alt = 1;
  pinfo->is_long = sizeof(long) == sizeof (char *);
  pinfo->is_long_double = sizeof(intmax_t) == sizeof (char *);

  /* Use the standard routine for numbers for the printing call,
     if the pointer is not NULL.  */

  if (args->pa_pointer != NULL)
    return printf_integer (stream, pinfo, args);

  /* Print a NULL pointer as (nil), appropriately padded.  */
  if ((pinfo->width > 5) && !pinfo->left)
    {
      int padwidth = pinfo->width - 5;
      while ((count_or_errorcode >= 0) && (count_or_errorcode < padwidth))
	SNV_EMIT (pinfo->pad, stream, count_or_errorcode);
    }

  SNV_EMIT ('(', stream, count_or_errorcode);
  SNV_EMIT ('n', stream, count_or_errorcode);
  SNV_EMIT ('i', stream, count_or_errorcode);
  SNV_EMIT ('l', stream, count_or_errorcode);
  SNV_EMIT (')', stream, count_or_errorcode);

  if ((pinfo->width > 5) && pinfo->left)
    while ((count_or_errorcode >= 0)
	   && (count_or_errorcode < pinfo->width))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  return count_or_errorcode;
}

static int
printf_string (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  int len = 0, count_or_errorcode = SNV_OK;
  const char *p = NULL;

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Read these now to advance the argument pointer appropriately */
  if (pinfo->prec == -1)
    pinfo->prec = 0;

  /* Check for valid pre-state. */
  if (pinfo->prec <= -1
     || pinfo->is_char || pinfo->is_short || pinfo->is_long
     || pinfo->is_long_double)
    {
      PRINTF_ERROR (pinfo, "invalid flags");
      return -1;
    }

  /* Extract the correct argument from the arg vector. */
  p = args->pa_string;

  /* Left pad to the width if the supplied argument is less than
     the width specifier.  */
  if (p != NULL)
    {
      len = strlen (p);
      if (pinfo->prec && pinfo->prec < len)
	len = pinfo->prec;
    }

  if ((len < pinfo->width) && !pinfo->left)
    {
      int padwidth = pinfo->width - len;
      while ((count_or_errorcode >= 0) && (count_or_errorcode < padwidth))
	SNV_EMIT (pinfo->pad, stream, count_or_errorcode);
    }

  /* Fill the buffer with as many characters from the format argument
     as possible without overflowing or exceeding the precision.  */
  if ((count_or_errorcode >= 0) && (p != NULL))
    {
      int mark = count_or_errorcode;
      while ((count_or_errorcode >= 0) && *p != '\0'
	     && ((pinfo->prec == 0) || (count_or_errorcode - mark < len)))
	SNV_EMIT (*p++, stream, count_or_errorcode);
    }

  /* Right pad to the width if we still didn't reach the specified
     width and the left justify flag was set.  */
  if ((count_or_errorcode < pinfo->width) && pinfo->left)
    while ((count_or_errorcode >= 0)
	   && (count_or_errorcode < pinfo->width))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Return the number of characters emitted. */
  return count_or_errorcode;
}



/* replacements for frexpl and ldexpl follow */

#ifndef NO_FLOAT_PRINTING
#if defined HAVE_LONG_DOUBLE && !defined HAVE_FREXPL

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
#endif

#if defined HAVE_LONG_DOUBLE && !defined HAVE_LDEXPL

long double
ldexpl(long double x, int exp)
{
  long double factor;
  int bit;

  /* Check for zero, nan and infinity. */
  if (x != x || x + x == x )
    return x;

  if (exp < 0)
    {
      exp = -exp;
      factor = 0.5L;
    }
  else
    factor = 2.0L;

  for (bit = 1; bit <= exp; bit <<= 1, factor *= factor)
    if (exp & bit)
      x *= factor;

  return x;
}
#endif
#endif



/* This is where the parsing of FORMAT strings is handled:

   Each of these functions should inspect PPARSER for parser
   state information;  update PPARSER as necessary based on
   the state discovered;  possibly put some characters in STREAM, in
   which case that number of characters must be returned.  If the
   handler detects that parsing (of the current specifier) is complete,
   then it must set pinfo->state to SNV_STATE_END.  The library will then
   copy characters from the format string to STREAM until another unescaped
   SNV_CHAR_SPEC is detected when the handlers will be called again. */

spec_entry snv_default_spec_table[] = {
  /* ch  type         function */
  {' ', 0, 0, NULL, printf_flag_info, NULL},
  {'#', 0, 0, NULL, printf_flag_info, NULL},
  {'+', 0, 0, NULL, printf_flag_info, NULL},
  {'-', 0, 0, NULL, printf_flag_info, NULL},
  {'\'', 0, 0, NULL, printf_flag_info, NULL},
  {'*', 0, PA_INT, NULL, printf_numeric_param_info, NULL},
  {'$', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'.', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'0', 0, 0, NULL, printf_flag_info, NULL},
  {'1', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'2', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'3', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'4', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'5', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'6', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'7', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'8', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'9', 0, 0, NULL, printf_numeric_param_info, NULL},
  {'c', 0, PA_CHAR, printf_char, NULL, NULL},
  {'d', 0, PA_INT, printf_integer, printf_generic_info, (snv_pointer) 10},
#ifndef NO_FLOAT_PRINTING
  {'e', 0, PA_DOUBLE, printf_float, printf_generic_info, (snv_pointer) 6},
  {'E', 0, PA_DOUBLE, printf_float, printf_generic_info, (snv_pointer) 6},
  {'f', 0, PA_DOUBLE, printf_float, printf_generic_info, (snv_pointer) 6},
  {'F', 0, PA_DOUBLE, printf_float, printf_generic_info, (snv_pointer) 6},
  {'g', 0, PA_DOUBLE, printf_float, printf_generic_info, (snv_pointer) 6},
  {'G', 0, PA_DOUBLE, printf_float, printf_generic_info, (snv_pointer) 6},
#endif
  {'h', 0, 0, NULL, printf_modifier_info, NULL},
  {'i', 0, PA_INT, printf_integer, printf_generic_info, (snv_pointer) 10},
  {'j', 0, 0, NULL, printf_modifier_info, NULL},
  {'l', 0, 0, NULL, printf_modifier_info, NULL},
  {'L', 0, 0, NULL, printf_modifier_info, NULL},
  {'n', 0, PA_INT | PA_FLAG_PTR, printf_count, printf_generic_info, NULL},
  {'o', 0, PA_INT | PA_FLAG_UNSIGNED,
   printf_integer, printf_generic_info, (snv_pointer) 8},
  {'p', 0, PA_POINTER, printf_pointer, NULL, (snv_pointer) 16},
  {'q', 0, 0, NULL, printf_modifier_info, NULL},
  {'s', 0, PA_STRING, printf_string, NULL, NULL},
  {'t', 0, 0, NULL, printf_modifier_info, NULL},
  {'u', 0, PA_INT | PA_FLAG_UNSIGNED,
   printf_integer, printf_generic_info, (snv_pointer) 10},
  {'x', 0, PA_INT | PA_FLAG_UNSIGNED,
   printf_integer, printf_generic_info, (snv_pointer) 16},
  {'X', 0, PA_INT | PA_FLAG_UNSIGNED,
   printf_integer, printf_generic_info, (snv_pointer) 16},
  {'z', 0, 0, NULL, printf_modifier_info, NULL},
  {'\0', 0, PA_LAST, NULL, NULL, NULL}
};

/* format.c ends here */
