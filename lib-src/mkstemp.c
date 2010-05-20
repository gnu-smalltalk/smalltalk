/* Copyright (C) 1998,99,2001,2005,2006,2007,2009 Free Software Foundation, Inc.
   This file is derived from the one in the GNU C Library.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as
   published by the Free Software Foundation; either version 2.1 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with GU Smalltalk; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

#if !_LIBC
# include <config.h>
#endif

#include <sys/types.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/time.h>
#include <limits.h>
#include <unistd.h>

#include <errno.h>
#ifndef __set_errno
# define __set_errno(Val) errno = (Val)
#endif

/* These are the characters used in temporary file names.  */
static const char letters[] =
"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

/* Generate a unique temporary file name from TEMPLATE.
   The last six characters of TEMPLATE must be "XXXXXX";
   they are replaced with a string that makes the file name unique.
   Then open the file and return a fd. */
int
mkstemp (template)
     char *template;
{
  int len;
  char *XXXXXX;
  static long long value;
  long long random_time_bits;
  unsigned int count;
  int fd = -1;
  int save_errno = errno;
  struct timeval tv;

  /* A lower bound on the number of temporary files to attempt to
     generate.  The maximum total number of temporary file names that
     can exist for a given template is 62**6.  It should never be
     necessary to try all these combinations.  Instead if a reasonable
     number of names is tried (we define reasonable as 62**3) fail to
     give the system administrator the chance to remove the problems.  */
#define ATTEMPTS_MIN (62 * 62 * 62)

  /* The number of times to attempt to generate a temporary file.  To
     conform to POSIX, this must be no smaller than TMP_MAX.  */
#if defined TMP_MAX
  unsigned int attempts = ATTEMPTS_MIN < TMP_MAX ? TMP_MAX : ATTEMPTS_MIN;
#else
  unsigned int attempts = ATTEMPTS_MIN;
#endif

  len = strlen (template);
  if (len < 6 || strcmp (&template[len - 6], "XXXXXX"))
    {
      __set_errno (EINVAL);
      return -1;
    }

  /* This is where the Xs start.  */
  XXXXXX = &template[len - 6];

  /* Get some more or less random data.  */
  gettimeofday (&tv, NULL);
  random_time_bits = ((long long) tv.tv_usec << 16) ^ tv.tv_sec;
  value += random_time_bits ^ getpid ();

  for (count = 0; count < attempts; value += 7777, ++count)
    {
      long long v = value;

      /* Fill in the random bits.  */
      XXXXXX[0] = letters[v % 62];
      v /= 62;
      XXXXXX[1] = letters[v % 62];
      v /= 62;
      XXXXXX[2] = letters[v % 62];
      v /= 62;
      XXXXXX[3] = letters[v % 62];
      v /= 62;
      XXXXXX[4] = letters[v % 62];
      v /= 62;
      XXXXXX[5] = letters[v % 62];

      fd = open (template, O_RDWR | O_CREAT | O_EXCL, 0600);
      if (fd >= 0)
	{
	  __set_errno (save_errno);
	  return fd;
	}
      else if (errno != EEXIST)
	return -1;
    }

  /* We got out of the loop because we ran out of combinations to try.  */
  __set_errno (EEXIST);
  return -1;
}
