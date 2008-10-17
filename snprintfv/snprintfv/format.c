/*  -*- Mode: C -*-  */

/* format.c --- printf clone for argv arrays
 * Copyright (C) 1998, 1999, 2000, 2002 Gary V. Vaughan
 * Copyright (C) 2003, 2008 Paolo Bonzini
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
#  ifndef HAVE_ISNANL
#   define isnanl(x) ((x) != (x))
#  endif
#  ifndef HAVE_ISINFL
#   define isinfl(x) isnanl ((x) - (x))
#  endif
#  ifndef HAVE_MODFL
static snv_long_double modfl (long double x, long double *exp);
#  endif
#  ifndef HAVE_COPYSIGNL
static snv_long_double copysignl (long double x, long double y);
#  endif
# else
#  ifdef HAVE_ISNAN
#   define isnanl isnan
#  else
#   define isnanl(x) ((x) != (x))
#  endif
#  ifdef HAVE_ISINF
#   define isinfl isinf
#  else
#   define isinfl(x) isnanl ((x) - (x))
#  endif
#  ifdef HAVE_COPYSIGN
#   define copysignl copysign
#  else
#   define copysign(x, y) (((x) < 0.0 ^ (y) < 0.0) ? (x) * -1.0 : (x));
#  endif
#  define modfl modf
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
static snv_long_double
fetch_double (struct printf_info *pinfo, union printf_arg const *arg)
{
  if (pinfo->is_long_double)
    return (snv_long_double) arg->pa_long_double;
  else
    return (snv_long_double) (arg->pa_double);
}
#endif


#ifndef NO_FLOAT_PRINTING
/* These two routines are cleaned up version of the code in libio 2.95.3
   (actually I got it from the Attic, not from the released tarball).
   The changes were mainly to share code between %f and %g (libio did
   share some code between %e and %g), and to share code between the
   %e and %f when invoked by %g.  Support from infinities and NaNs comes
   from the old snprintfv code.  */

static char *
print_float_round (snv_long_double fract, int *exp, char *start, char *end,
		   char ch, int *signp)
{
  snv_long_double tmp;
  if (fract)
    (void) modfl (fract * 10, &tmp);
  else
    tmp = ch - '0';

  if (tmp > 4)
    for (;; --end)
      {
	if (*end == '.')
	  --end;
	if (end == start)
	  {
	    if (exp) /* e/E; increment exponent */
	      ++end, ++*exp;

	    *end = '1';
	    break;
	  }
	if (++*end <= '9')
	  break;
	*end = '0';
      }

  /* ``"%.3f", (double)-0.0004'' gives you a negative 0. */
  else if (*signp == '-')
    for (;; --end)
      {
	if (*end == '.')
	  --end;
	if (*end != '0')
	  break;
	if (end == start)
	  *signp = 0;
      }
  return (start);
}

static int
print_float (struct printf_info *pinfo, char *startp, char *endp, int *signp, snv_long_double n)
{
  int prec, fmtch;
  char *p, *t;
  snv_long_double fract;
  int expcnt, gformat = 0;
  snv_long_double integer, tmp;
  char expbuf[10];

  prec = pinfo->prec;
  fmtch = pinfo->spec;
  t = startp;
  *signp = 0;

  /* Do the special cases: nans, infinities, zero, and negative numbers. */
  if (isnanl (n))
    {
      /* Not-a-numbers are printed as a simple string. */
      *t++ = fmtch < 'a' ? 'N' : 'n';
      *t++ = fmtch < 'a' ? 'A' : 'a';
      *t++ = fmtch < 'a' ? 'N' : 'n';
      return t - startp;
    }

  /* Zero and infinity also can have a sign in front of them. */
  if (copysignl (1.0, n) < 0.0)
    {
      n = -1.0 * n;
      *signp = '-';
    }

  if (isinfl (n))
    {
      /* Infinities are printed as a simple string. */
      *t++ = fmtch < 'a' ? 'I' : 'i';
      *t++ = fmtch < 'a' ? 'N' : 'n';
      *t++ = fmtch < 'a' ? 'F' : 'f';
      goto set_signp;
    }

  expcnt = 0;
  fract = modfl (n, &integer);

  /* get an extra slot for rounding. */
  *t++ = '0';

  /* get integer portion of number; put into the end of the buffer; the
     .01 is added for modfl (356.0 / 10, &integer) returning .59999999...  */
  for (p = endp - 1; p >= startp && integer; ++expcnt)
    {
      tmp = modfl (integer / 10, &integer);
      *p-- = '0' + ((int) ((tmp + .01L) * 10));
    }

  switch (fmtch)
    {
    case 'g':
    case 'G':
      gformat = 1;

      /* a precision of 0 is treated as a precision of 1. */
      if (!prec)
	pinfo->prec = ++prec;

      /* ``The style used depends on the value converted; style e
         will be used only if the exponent resulting from the
         conversion is less than -4 or greater than the precision.''
                -- ANSI X3J11 */
      if (expcnt > prec || (!expcnt && fract && fract < .0001L))
	{
	  /* g/G format counts "significant digits, not digits of
	     precision; for the e/E format, this just causes an
	     off-by-one problem, i.e. g/G considers the digit
	     before the decimal point significant and e/E doesn't
	     count it as precision.  */
	  --prec;
	  fmtch -= 2;		/* G->E, g->e */
	  goto eformat;
	}
      else
	{
          /* Decrement precision */
          if (n != 0.0L)
	    prec -= (endp - p) - 1;
	  else
	    prec--;

	  goto fformat;
	}

    case 'f':
    case 'F':
    fformat:
      /* reverse integer into beginning of buffer */
      if (expcnt)
	for (; ++p < endp; *t++ = *p);
      else
	*t++ = '0';

      /* If precision required or alternate flag set, add in a
         decimal point.  */
      if (pinfo->prec || pinfo->alt)
	*t++ = '.';

      /* if requires more precision and some fraction left */
      if (fract)
	{
	  if (prec)
	    {
	      /* For %g, if no integer part, don't count initial
	         zeros as significant digits. */
	      do
		{
		  fract = modfl (fract * 10, &tmp);
		  *t++ = '0' + ((int) tmp);
		}
	      while (!tmp && !expcnt && gformat);

	      while (--prec && fract)
		{
		  fract = modfl (fract * 10, &tmp);
		  *t++ = '0' + ((int) tmp);
		}
	    }

	  if (fract)
	    startp =
	      print_float_round (fract, (int *) NULL, startp, t - 1, (char) 0, signp);
	}

      break;

    case 'e':
    case 'E':
    eformat:
      if (expcnt)
	{
	  *t++ = *++p;
	  if (pinfo->prec || pinfo->alt)
	    *t++ = '.';

	  /* if requires more precision and some integer left */
	  for (; prec && ++p < endp; --prec)
	    *t++ = *p;

	  /* if done precision and more of the integer component,
	     round using it; adjust fract so we don't re-round
	     later.  */
	  if (!prec && ++p < endp)
	    {
	      fract = 0;
	      startp = print_float_round ((snv_long_double) 0, &expcnt, startp, t - 1, *p, signp);
	    }

	  /* adjust expcnt for digit in front of decimal */
	  --expcnt;
	}

      /* until first fractional digit, decrement exponent */
      else if (fract)
	{
	  /* adjust expcnt for digit in front of decimal */
	  for (expcnt = -1;; --expcnt)
	    {
	      fract = modfl (fract * 10, &tmp);
	      if (tmp)
		break;
	    }
	  *t++ = '0' + ((int) tmp);
	  if (pinfo->prec || pinfo->alt)
	    *t++ = '.';
	}

      else
	{
	  *t++ = '0';
	  if (pinfo->prec || pinfo->alt)
	    *t++ = '.';
	}

      /* if requires more precision and some fraction left */
      if (fract)
	{
	  if (prec)
	    do
	      {
		fract = modfl (fract * 10, &tmp);
		*t++ = '0' + ((int) tmp);
	      }
	    while (--prec && fract);

	  if (fract)
	    startp = print_float_round (fract, &expcnt, startp, t - 1, (char) 0, signp);
	}
      break;

    default:
      abort ();
    }

  /* %e/%f/%#g add 0's for precision, others trim 0's */
  if (gformat && !pinfo->alt)
    {
      while (t > startp && *--t == '0');
      if (*t != '.')
        ++t;
    }
  else
    for (; prec--; *t++ = '0');

  if (fmtch == 'e' || fmtch == 'E')
    {
      *t++ = fmtch;
      if (expcnt < 0)
        {
          expcnt = -expcnt;
          *t++ = '-';
        }
      else
        *t++ = '+';

      p = expbuf;
      do
        *p++ = '0' + (expcnt % 10);
      while ((expcnt /= 10) > 9);
      *p++ = '0' + expcnt;
      while (p > expbuf)
	*t++ = *--p;
    }

set_signp:
  if (!*signp)
    {
      if (pinfo->showsign)
        *signp = '+';
      else if (pinfo->space)
        *signp = ' ';
    }

  return (t - startp);
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
printf_float (STREAM *stream,
	      struct printf_info *const pinfo,
	      union printf_arg const *args)
{
  snv_long_double value = 0.0;
  int sign, len, count_or_errorcode = SNV_OK;
#ifdef HAVE_LONG_DOUBLE
  char buffer[LDBL_MAX_10_EXP * 2 + 20], *p = buffer;
#else
  char buffer[DBL_MAX_10_EXP * 2 + 20], *p = buffer;
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
  len = print_float (pinfo, buffer, buffer + sizeof (buffer), &sign, value);
  if (*buffer == '0')
    p++, len--;

  /* Compute the size of the padding.  */
  pinfo->width -= len;
  if (sign)
    pinfo->width--;

  /* Left pad to the remaining width if the supplied argument is less
     than the width specifier, and the padding character is ' '.  */
  if (pinfo->pad == ' ' && !pinfo->left)
    while ((count_or_errorcode >= 0) && (pinfo->width-- > 0))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Display any sign character. */
  if (count_or_errorcode >= 0 && sign)
    SNV_EMIT (sign, stream, count_or_errorcode);

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



/* replacements for modfl and copysignl follow.  */

#if !defined NO_FLOAT_PRINTING && defined HAVE_LONG_DOUBLE
# ifndef HAVE_MODFL
static long double modfl (long double x, long double *exp)
{
  /* To compute the integer part of a positive integer (in this case
     abs(X)), sum a big enough integer to the absolute value, so that
     the precision of the floating point number is exactly 1.  Then
     we round towards zero.

     The code in the two branches is the same but it considers -x
     if x is negative.  */

  long double z;
  if (x < 0.0L)
    {
      z = 1.0L / LDBL_EPSILON - x - 1.0 / LDBL_EPSILON;
      if (z + x > 0.0L)
        z = z - 1.0L;

      return (*exp = -z) + x;
    }
  else
    {
      z = 1.0L / LDBL_EPSILON + x - 1.0 / LDBL_EPSILON;
      if (z > x)
        z = z - 1.0L;

      return x - (*exp = z);
    }
}
# endif /* !HAVE_MODFL */

# ifndef HAVE_COPYSIGNL
long double
copysignl (long double x, long double y)
{
#  ifdef HAVE_COPYSIGN
  return x * (long double) copysign (1.0, x * y);
#  else /* !HAVE_COPYSIGN */
  /* If we do not have copysign, assume zero is unsigned (too risky to
     assume we have infinities, which would allow to test with
     (x < 0.0 && 1.0 / x < 0.0).  */
  return (x < 0.0 ^ y < 0.0) ? x * -1.0 : x;
#  endif /* !HAVE_COPYSIGN */
}
# endif /* !HAVE_COPYSIGNL */
#endif /* !NO_FLOAT_PRINTING && HAVE_LONG_DOUBLE */



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
