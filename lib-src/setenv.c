/* Copyright (C) 1992,1995-1999,2000-2003,2005,2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. */

#include <config.h>

/* AIX is so broken that requires this to be the first thing in the file.  */
#if defined(_AIX)
#pragma alloca
#else
# if !defined(alloca)		/* predefined by HP cc +Olibcalls */
#  ifdef __GNUC__
#   define alloca(size) __builtin_alloca(size)
#  else
#   if HAVE_ALLOCA_H
#    include <alloca.h>
#   else
#    if defined(__hpux)
void *alloca ();
#    else
#     if !defined(__OS2__) && !defined(WIN32)
char *alloca ();
#     else
#      include <malloc.h>	/* OS/2 defines alloca in here */
#     endif
#    endif
#   endif
#  endif
# endif
#endif

#include <errno.h>
#ifndef __set_errno
# define __set_errno(ev) ((errno) = (ev))
#endif

#include <stdlib.h>
#include <string.h>
#if HAVE_UNISTD_H
# include <unistd.h>
#endif

#ifndef HAVE_ENVIRON_DECL
extern char **environ;
#endif


/* If this variable is not a null pointer we allocated the current
   environment.  */
static char **last_environ;


/* This function is used by `setenv' and `putenv'.  The difference between
   the two functions is that for the former must create a new string which
   is then placed in the environment, while the argument of `putenv'
   must be used directly.  This is all complicated by the fact that we try
   to reuse values once generated for a `setenv' call since we can never
   free the strings.  */
int
setenv (const char *name, const char *value, int replace)
{
  register char **ep;
  register size_t size;
  const size_t namelen = strlen (name);
  const size_t vallen = value != NULL ? strlen (value) + 1 : 0;

  /* We have to get the pointer now that we have the lock and not earlier
     since another thread might have created a new environment.  */
  ep = environ;

  size = 0;
  if (ep != NULL)
    {
      for (; *ep != NULL; ++ep)
	if (!strncmp (*ep, name, namelen) && (*ep)[namelen] == '=')
	  break;
	else
	  ++size;
    }

  if (ep == NULL || *ep == NULL)
    {
      char **new_environ;

      /* We allocated this space; we can extend it.  */
      new_environ =
	(char **) (last_environ == NULL
		   ? malloc ((size + 2) * sizeof (char *))
		   : realloc (last_environ, (size + 2) * sizeof (char *)));
      if (new_environ == NULL)
	return -1;

      new_environ[size] = (char *) malloc (namelen + 1 + vallen);
      if (new_environ[size] == NULL)
	{
	  __set_errno (ENOMEM);
	  return -1;
	}

      memcpy (new_environ[size], name, namelen);
      new_environ[size][namelen] = '=';
      memcpy (&new_environ[size][namelen + 1], value, vallen);

      if (environ != last_environ)
	memcpy ((char *) new_environ, (char *) environ,
		size * sizeof (char *));

      new_environ[size + 1] = NULL;

      last_environ = environ = new_environ;
    }
  else if (replace)
    {
      char *np;

      np = malloc (namelen + 1 + vallen);
      if (np == NULL)
	{
	  __set_errno (ENOMEM);
	  return -1;
	}

      memcpy (np, name, namelen);
      np[namelen] = '=';
      memcpy (&np[namelen + 1], value, vallen);

      *ep = np;
    }

  return 0;
}
