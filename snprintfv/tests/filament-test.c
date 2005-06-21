/*  -*- Mode: C -*-  */

/* filament-test.c --- test Snprintfv filaments
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

#include "snprintfv/filament.h"

#ifndef DIR_SEPARATOR
#define DIR_SEPARATOR '/'
#endif

static const char *progname;

static inline void
fildump (stream, pfil)
     FILE *stream;
     Filament *pfil;
{
  fprintf (stream, "%p (%u): \"%s\"\n",
	   filval (pfil), fillen (pfil), filval (pfil));
}

int
main (argc, argv)
     int argc;
     char *argv[];
{
  static char string[] = "0123456789XX";
  FILE *stream = NULL;
  Filament *pfil;
  int i;
  char *pval;

  progname = argv[0] + strlen (argv[0]);
  while (progname > argv[0] && *(progname - 1) != DIR_SEPARATOR)
    progname--;

  if (getenv ("VERBOSE"))
    stream = stdout;
  else
    stream = fopen ("/dev/null", "w");

  fprintf (stream, "=== running test %s\n", progname);

  pfil = filnew ("Hello, World!", 13);
  fildump (stream, pfil);
  fildelete (pfil);

  /* 51 lots of string is 510 chars, 2 less than FILAMENT_BUFSIZ. */
  pfil = filnew (string, 10);
  pval = filval (pfil);
  for (i = 0; i < 50; i++)
    {
      if (filncat (pfil, string, 10) == NULL)
	{
	  fildump (stream, pfil);
	  return EXIT_FAILURE;
	}
      snv_fassert (stream, filval (pfil) == pval);
      snv_fassert (stream, strlen (filval (pfil)) == fillen (pfil));
      snv_fassert (stream, fillen (pfil) == 10 + (1 + i) * 10);
    }
  fildump (stream, pfil);

  /* overflow the internal buffer to force a reallocation */
  if (filncat (pfil, "Hello, World!", 13) == NULL)
    {
      fildump (stream, pfil);
      return EXIT_FAILURE;
    }
  snv_fassert (stream, filval (pfil) != pval);
  snv_fassert (stream, strlen (filval (pfil)) == fillen (pfil));
  snv_fassert (stream, fillen (pfil) == (51 * 10) + 13);
  fildump (stream, pfil);

  return EXIT_SUCCESS;
}

/* filament-test.c ends here */
