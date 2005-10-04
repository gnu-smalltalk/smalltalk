#line 1 "../../../snprintfv/snprintfv/filament.in"
/*  -*- Mode: C -*-  */

/* filament.h --- a bit like a string but different =)O|
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

#ifndef FILAMENT_H
#define FILAMENT_H 1

#include <snprintfv/compat.h>

#ifdef __cplusplus
extern "C"
{
#if 0
/* This brace is so that emacs can still indent properly: */ }
#endif
#endif				/* __cplusplus */

#define FILAMENT_BUFSIZ       512

/**
 * Filament:
 * Opaque data type used to hold 8-bit clean dynamic strings which know
 * their own length and resize themselves to avoid buffer overruns.
 **/
typedef struct filament Filament;

struct filament
{
  char *value;                  /* pointer to the start of the string */
  size_t length;                /* length of the string */
  size_t size;                  /* total memory allocated */
  char buffer[FILAMENT_BUFSIZ]; /* usually string == &buffer[0] */
};

/**
 * filnew:  constructor 
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
extern Filament * filnew (const char *const init, size_t len);


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
extern Filament * filinit (Filament *fil, const char *const init, size_t len);


/**
 * fildelete:  destructor 
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
extern char * fildelete (Filament *fil);


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
extern void _fil_extend (Filament *fil, size_t len, boolean copy);


#line 61 "../../../snprintfv/snprintfv/filament.in"

/* Save the overhead of a function call in the great majority of cases. */
#define fil_maybe_extend(fil, len, copy)  \
  (((len)>=(fil)->size) ? _fil_extend((fil), (len), (copy)) : (void)0)

/**
 * filval:
 * @fil: The Filament object being queried.
 *
 * Return value:
 * A pointer to the null terminated string held by the Filament
 * object is returned.  Since the @fil may contain embedded nulls, it
 * is not entirely safe to use the strfoo() API to examine the contents
 * of the return value.
 **/
SNV_INLINE char *
filval (Filament *fil)
{
  /* Because we have been careful to ensure there is always at least
     one spare byte of allocated memory, it is safe to set it here. */
  fil->value[fil->length] = '\0';
  return (char *) (fil->value);
}

/**
 * fillen:
 * @fil: The Filament object being queried.
 *
 * Return value:
 * The length of @fil, including any embedded nulls, but excluding the
 * terminating null, is returned.
 **/
SNV_INLINE size_t
fillen (Filament *fil)
{
  return fil->length;
}

/**
 * filelt:
 * @fil: The Filament being queried.
 * @n: A zero based index into @fil.
 *
 * This function looks for the @n'th element of @fil.
 *
 * Return value:
 * If @n is an index inside the Filament @fil, then the character stored
 * at that index cast to an int is returned, otherwise @n is outside
 * this range and -1 is returned.
 **/
SNV_INLINE int
filelt (Filament *fil, ssize_t n)
{
  if ((n >= 0) && (n < fil->length))
    return (int) fil->value[n];
  else
    return -1;
}

/**
 * filncat:
 * @fil: The destination Filament of the concatenation.
 * @str: The address of the source bytes for concatenation.
 * @n: The number of bytes to be copied from @str.
 *
 * @n bytes starting with the byte at address @str are destructively
 * concatenated to @fil.  If necessary, @fil is dynamically reallocated
 * to make room for this operation.
 *
 * Return value:
 * A pointer to the (not null terminated) string which is the result
 * of this concatenation is returned.
 **/
SNV_INLINE char *
filncat (Filament *fil, const char *str, size_t n)
{
  fil_maybe_extend (fil, n + fil->length, TRUE);
  memcpy (fil->value + fil->length, str, n);
  fil->length += n;
  return fil->value;
}

/**
 * filcat:
 * @fil: The destination Filament of the concatenation.
 * @str: The address of the source bytes for concatenation.
 *
 * The bytes starting at address @str upto and including the first null
 * byte encountered are destructively concatenated to @fil.  If
 * necessary @fil is dynamically reallocated to make room for this
 * operation.
 *
 * Return value:
 * A pointer to the (not null terminated) string which is the result
 * of this concatenation is returned.
 **/
SNV_INLINE char *
filcat (Filament *fil, const char *str)
{
  size_t length = strlen (str);
  return filncat (fil, str, length);
}

/**
 * filccat:
 * @fil: The destination Filament of the concatenation.
 * @c: The character to append to @fil.
 *
 * @c is destructively concatenated to @fil.  If necessary, @fil is
 * dynamically reallocated to make room for this operation.  When used
 * repeatedly this function is less efficient than %filncat,
 * since it must check whether to extend the filament before each
 * character is appended.
 *
 * Return value:
 * A pointer to the (not null terminated) string which is the result
 * of this concatenation is returned.
 **/
SNV_INLINE char *
filccat (Filament *fil, int c)
{
  fil_maybe_extend (fil, 1 + fil->length, TRUE);
  fil->value[fil->length++] = c;
  return fil->value;
}

#ifdef __cplusplus
#if 0
/* This brace is so that emacs can still indent properly: */
{
#endif
}
#endif /* __cplusplus */

#endif /* FILAMENT_H */

/* filament.h ends here */
