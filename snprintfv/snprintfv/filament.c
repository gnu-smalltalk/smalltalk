/*  -*- Mode: C -*-  */

/* filament.c --- a bit like a string, but different =)O|
 * Copyright (C) 1999 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1999
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

/* Commentary:
 *
 * Try to exploit usage patterns to optimise string handling, and
 * as a happy consequence handle NUL's embedded in strings properly.
 *
 * o Since finding the length of a (long) string is time consuming and
 *   requires careful coding to cache the result in local scope: We
 *   keep count of the length of a Filament all the time, so finding the
 *   length is O(1) at the expense of a little bookkeeping while
 *   manipulating the Filament contents.
 *
 * o Constantly resizing a block of memory to hold a string is memory
 *   efficient, but slow:  Filaments are only ever expanded in size,
 *   doubling at each step to minimise the number of times the block
 *   needs to be reallocated and the contents copied (this problem is
 *   especially poignant for very large strings).
 *
 * o Most strings tend to be either relatively small and short-lived,
 *   or else long-lived but growing in asymptotically in size: To
 *   care for the former case, Filaments start off with a modest static
 *   buffer for the string contents to avoid any mallocations (except
 *   the initial one to get the structure!); the latter case is handled
 *   gracefully by the resizing algorithm in the previous point.
 *
 * o Extracting a C-style NUL terminated string from the Filament is
 *   an extremely common operation:  We ensure there is always a
 *   terminating NUL character after the last character in the string
 *   so that the conversion can be performed quickly.
 *
 * In summary, Filaments are good where you need to do a lot of length
 * calculations with your strings and/or gradually append more text
 * onto existing strings.  Filaments are also an easy way to get 8-bit
 * clean strings is a more lightweight approach isn't required.
 *
 * They probably don't buy much if you need to do insertions and partial
 * deletions, but optimising for that is a whole other problem!
 */

/* Code: */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef WITH_DMALLOC
#  include <dmalloc.h>
#endif

#include "mem.h"
#include "filament.h"



/**
 * filnew: constructor
 * @init: address of the first byte to copy into the new object.
 * @len:  the number of bytes to copy into the new object.
 *
 * Create a new Filament object, initialised to hold a copy of the
 * first @len bytes starting at address @init.  If @init is NULL, or
 * @len is 0 (or less), then the initialised Filament will return the
 * empty string, "", if its value is queried.
 *
 * Return value:
 * A newly created Filament object is returned.
 **/
Filament *
filnew (const char *const init, size_t len)
{
  Filament *new;

  new = snv_new (Filament, 1);

  new->value = new->buffer;
  new->length = 0;
  new->size = FILAMENT_BUFSIZ;

  return (init || len) ? filinit (new, init, len) : new;
}

/**
 * filinit:
 * @fil: The Filament object to initialise.
 * @init: address of the first byte to copy into the new object.
 * @len:  the number of bytes to copy into the new object.
 *
 * Initialise a Filament object to hold a copy of the first @len bytes
 * starting at address @init.  If @init is NULL, or @len is 0 (or less),
 * then the Filament will be reset to hold the empty string, "".
 *
 * Return value:
 * The initialised Filament object is returned.
 **/
Filament *
filinit (Filament *fil, const char *const init, size_t len)
{
  if (init == NULL || len < 1)
    {
      /* Recycle any dynamic memory assigned to the previous
         contents of @fil, and point back into the static buffer. */
      if (fil->value != fil->buffer)
	snv_delete (fil->value);

      fil->value = fil->buffer;
      fil->length = 0;
      fil->size = FILAMENT_BUFSIZ;
    }
  else
    {
      if (len < FILAMENT_BUFSIZ)
	{
	  /* We have initialisation data which will easily fit into
	     the static buffer: recycle any memory already assigned
	     and initialise in the static buffer. */
	  if (fil->value != fil->buffer)
	    {
	      snv_delete (fil->value);
	      fil->value = fil->buffer;
	      fil->size = FILAMENT_BUFSIZ;
	    }
	}
      else
	{
	  /* If we get to here then we never try to shrink the already
	     allocated dynamic buffer (if any), we just leave it in
	     place all ready to expand into later... */
	  fil_maybe_extend (fil, len, FALSE);
	}

      snv_assert (len < fil->size);

      fil->length = len;
      memcpy (fil->value, init, len);
    }

  return fil;
}

/**
 * fildelete: destructor
 * @fil: The Filament object for recycling.
 *
 * The memory being used by @fil is recycled.
 *
 * Return value:
 * The original contents of @fil are converted to a null terminated
 * string which is returned, either to be freed itself or else used
 * as a normal C string.  The entire Filament contents are copied into
 * this string including any embedded nulls.
 **/
char *
fildelete (Filament *fil)
{
  char *value;

  if (fil->value == fil->buffer)
    {
      value = memcpy (snv_new (char, 1 + fil->length),
		      fil->buffer, 1 + fil->length);
      value[fil->length] = '\0';
    }
  else
    value = filval (fil);

  snv_delete (fil);

  return value;
}

/**
 * _fil_extend:
 * @fil: The Filament object which may need more string space.
 * @len: The length of the data to be stored in @fil.
 * @copy: whether to copy data from the static buffer on reallocation.
 *
 * This function will will assign a bigger block of memory to @fil
 * considering the space left in @fil and @len, the length required
 * for the prospective contents.
 */
void
_fil_extend (Filament *fil, size_t len, boolean copy)
{
  /* Usually we will simply double the amount of space previously
     allocated, but if the extra data is larger than the current
     size it *still* won't fit, so in that case we allocate enough
     room plus some we leave the current free space to expand into. */
  fil->size += MAX (len, fil->size);

  if (fil->value == fil->buffer)
    {
      fil->value = snv_new (char, fil->size);
      if (copy)
	memcpy (fil->value, fil->buffer, fil->length);
    }
  else
    fil->value = snv_renew (char, fil->value, fil->size);
}

/* Filament.c ends here */
