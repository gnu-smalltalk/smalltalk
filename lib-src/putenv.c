/******************************** -*- C -*- ****************************
 *
 *	putenv substitute
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000
 * Free Software Foundation, Inc.
 *
 * This file is part of the GNU C Library.
 * 
 * The GNU C Library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of the
 * License, or (at your option) any later version.
 * 
 * The GNU C Library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should receive a copy of the GNU Lesser General Public License
 * along with the GNU C Library; see the file COPYING.LESSER.  If not, write
 * to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "alloc.h"

#include <errno.h>
#if STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif /* STDC_HEADERS */

#ifdef HAVE_UNISTD_H
#include <unistd.h> 
#endif

#ifndef HAVE_PUTENV
 
extern char **environ;
#define	__environ	environ

/* Put STRING, which is of the form "NAME=VALUE", in the environment.  */
int putenv(const char *string)
{
  char *name_end = strchr(string, '=');
  register size_t size;
  register char **ep;

  if (name_end == NULL)
    {
      /* Remove the variable from the environment.  */
      size = strlen(string);
      for (ep = __environ; *ep != NULL; ++ep)
	if (!strncmp(*ep, string, size) && (*ep)[size] == '=')
	  {
	    while (ep[1] != NULL)
	      {
		ep[0] = ep[1];
		++ep;
	      }
	    *ep = NULL;
	    return 0;
	  }
    }

  size = 0;
  for (ep = __environ; *ep != NULL; ++ep)
    if (!strncmp(*ep, string, name_end - string) &&
	(*ep)[name_end - string] == '=')
      break;
    else
      ++size;

  if (*ep == NULL)
    {
      static char **last_environ = NULL;
      char **new_environ = (char **) xmalloc((size + 2) * sizeof(char *));
      if (new_environ == NULL)
	return -1;

      memcpy(new_environ, __environ, size * sizeof(char *));
      ep = &new_environ[size];
      new_environ[size + 1] = NULL;
      if (last_environ != NULL)
	xfree(last_environ);
      last_environ = new_environ;
      __environ = new_environ;
    }
  
  *ep = (char *) strdup(string);

  return 0;
}

#endif
