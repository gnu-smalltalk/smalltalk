/*  -*- Mode: C -*-  */

/* stream-test.c --- test Snprintfv streams
 * Copyright (C) 1999 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1999
 * This file is part of Snprintfv.
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv is distributed in the hope that it will be useful,
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
#  include "config.h"
#endif

/* Usually, this is taken care of by AC_SNPRINTFV_INSTALLABLE.  */
#define LIBSNPRINTFV_DLL_IMPORT 1

#include <stdio.h>

#if defined(STDC_HEADERS) || defined(HAVE_STDLIB_H)
#  include <stdlib.h>
#else
extern char *getenv ();
#endif

#ifdef HAVE_STRING_H
#  include <string.h>
#else
#  ifdef HAVE_STRINGS_H
#    include <strings.h>
#  else
extern int strncmp ();
#  endif
#endif

#include "printf.h"		/* for snv_bufputc() */
#include "snprintfv/stream.h"

#ifndef EXIT_SUCCESS
#  define EXIT_SUCCESS  0
#  define EXIT_FAILURE  1
#endif

#ifndef EOS
#define EOS '\0'
#endif

#ifndef DIR_SEPARATOR
#define DIR_SEPARATOR '/'
#endif

static int stream_print (STREAM * stream, char *string);

static const char *progname;

/* Put characters from STRING into STREAM until the the end of the
   string is reached or the stream is full. */
static int
stream_print (STREAM *stream, char *string)
{
  int count = 0;

  while ((string[count] != EOS) && (count >= 0))
    {
      int status = stream_put (string[count], stream);
      if (status < 0)
	{
	  count = status;
	  break;
	}
      count++;
    }

  return count;
}

int
main (int argc, char *argv[])
{
  static char string[] = "foo*Fnord";
  FILE *verbose = NULL;
  STREAM *out;
  char buffer[4], *p = buffer;
  int count;

  progname = argv[0] + strlen (argv[0]);
  while (progname > argv[0] && *(progname - 1) != DIR_SEPARATOR)
    progname--;

  if (getenv ("VERBOSE"))
    verbose = stdout;
  else
    verbose = fopen ("/dev/null", "w");

  fprintf (verbose, "=== running test %s\n", progname);

  (void) strcpy (buffer, "123");

  /* We can't portably pass the address of the buffer in directly,
     because the snv_bufputc function increments that address after
     each byte is written. */
  out = stream_new (&p, 3, NULL, snv_bufputc);

  count = stream_print (out, string);
  if ((count != 9) || strncmp (buffer, string, strlen (buffer))
      || buffer[3] != '\0')
    return EXIT_FAILURE;

  return EXIT_SUCCESS;
}

/* stream-test.c ends here */
