/*  -*- Mode: C -*-  */

/* custom.c --- printf clone for argv arrays
 * Copyright (C) 2003 Gary V. Vaughan
 * Originally by Paolo Bonzini, 2002
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

#include <stddef.h>

#ifdef HAVE_WCHAR_H
#  include <wchar.h>
#endif

#include "printf.h"



/**
 * printf_generic_info:
 * @pinfo: the current state information for the format
 * string parser.
 * @n: the number of available slots in the @argtypes array
 * @argtypes: the pointer to the first slot to be filled by the
 * function
 *
 * An example implementation of a %printf_arginfo_function, which
 * takes the basic type from the type given in the %spec_entry
 * and adds flags depending on what was parsed (e.g. %PA_FLAG_SHORT
 * is %pparser->is_short and so on).
 *
 * Return value:
 * Always 1.
 */
int
printf_generic_info (struct printf_info *const pinfo, size_t n, int *argtypes)
{
  int type = pinfo->type;

  if (!n)
    return 1;

  if ((type & PA_TYPE_MASK) == PA_POINTER)
    type |= PA_FLAG_UNSIGNED;

  if (pinfo->is_char)
    type = PA_CHAR;

  if (pinfo->is_short)
    type |= PA_FLAG_SHORT;

  if (pinfo->is_long)
    type |= PA_FLAG_LONG;

  if (pinfo->is_long_double)
    type |= PA_FLAG_LONG_LONG;

  argtypes[0] = type;
  return 1;
}


/**
 * printf_generic:
 * @stream: the stream (possibly a struct printfv_stream appropriately
 * cast) on which to write output.
 * @pinfo: the current state information for the format string parser.
 * @args: the pointer to the first argument to be read by the handler
 *
 * An example implementation of a %printf_function, used to provide easy
 * access to justification, width and precision options.
 *
 * Return value:
 * The number of characters output.
 **/
int
printf_generic (STREAM *stream, struct printf_info *const pinfo, union printf_arg const *args)
{
  int len = 0, count_or_errorcode = SNV_OK;
  char *p = NULL;

  /* Used to interface to the custom function. */
  STREAM *out;
  Filament *fil;
  printf_function *user_func = (printf_function *) pinfo->extra;

  return_val_if_fail (pinfo != NULL, SNV_ERROR);

  /* Read these now to advance the argument pointer appropriately */
  if (pinfo->prec == -1)
    pinfo->prec = 0;

  /* Check for valid pre-state. */
  if (pinfo->prec <= -1)
    {
      PRINTF_ERROR (pinfo, "invalid flags");
      return -1;
    }

  /* Print to a stream using a user-supplied function. */
  fil = filnew (NULL, 0);
  out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  user_func (out, pinfo, args);
  stream_delete (out);
  len = fillen (fil);
  p = fildelete (fil);

  /* Left pad to the width if the supplied argument is less than
     the width specifier.  */
  if (p != NULL && pinfo->prec && pinfo->prec < len)
    len = pinfo->prec;

  if ((len < pinfo->width) && !pinfo->left)
    {
      int padwidth = pinfo->width - len;
      while ((count_or_errorcode >= 0) && (count_or_errorcode < padwidth))
	SNV_EMIT (pinfo->pad, stream, count_or_errorcode);
    }

  /* Fill the buffer with as many characters from the format argument
   * as possible without overflowing or exceeding the precision.
   */
  if ((count_or_errorcode >= 0) && (p != NULL))
    {
      int mark = count_or_errorcode;
      while ((count_or_errorcode >= 0) && *p != '\0'
	     && ((pinfo->prec == 0) || (count_or_errorcode - mark < len)))
	SNV_EMIT (*p++, stream, count_or_errorcode);
    }

  /* Right pad to the width if we still didn't reach the specified
   * width and the left justify flag was set.
   */
  if ((count_or_errorcode < pinfo->width) && pinfo->left)
    while ((count_or_errorcode >= 0)
	   && (count_or_errorcode < pinfo->width))
      SNV_EMIT (pinfo->pad, stream, count_or_errorcode);

  /* Return the number of characters emitted. */
  return count_or_errorcode;
}

