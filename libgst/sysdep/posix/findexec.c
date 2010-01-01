/******************************** -*- C -*- ****************************
 *
 * System specific implementation module.
 *
 * This module contains implementations of various operating system
 * specific routines.  This module should encapsulate most (or all)
 * of these calls so that the rest of the code is portable.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006,2007,2008,2009
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
 *
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"

#ifdef HAVE_SYS_PARAM_H
# include <sys/param.h>
#endif

/* Get declaration of _NSGetExecutablePath on MacOS X 10.2 or newer.  */
#if HAVE_MACH_O_DYLD_H
# define ENUM_DYLD_BOOL
# include <mach-o/dyld.h>
#endif

#ifdef __linux__
/* File descriptor of the executable, used for double checking.  */
static int executable_fd = -1;
#endif

/* The path to the executable, derived from argv[0].  */
const char *_gst_executable_path = NULL;

/* Tests whether a given pathname may belong to the executable.  */
static mst_Boolean
maybe_executable (const char *filename)
{
  if (!_gst_file_is_executable (filename))
    return false;

#ifdef __linux__
  if (executable_fd >= 0)
    {
      /* If we already have an executable_fd, check that filename points to
	 the same inode.  */
      struct stat statexe, statfile;

      if (fstat (executable_fd, &statexe) < 0
	  || stat (filename, &statfile) < 0
	  || !(statfile.st_dev
	       && statfile.st_dev == statexe.st_dev
	       && statfile.st_ino == statexe.st_ino))
	return false;

      close (executable_fd);
      executable_fd = -1;
    }
#endif

  return true;
}

/* Determine the full pathname of the current executable, freshly allocated.
   Return NULL if unknown.  Guaranteed to work on Linux and Win32, Mac OS X.
   Likely to work on the other Unixes (maybe except BeOS), under most
   conditions.  */
static char *
find_executable (const char *argv0)
{
#ifdef PATH_MAX
  int path_max = PATH_MAX;
#else
  int path_max = pathconf (name, _PC_PATH_MAX);
  if (path_max <= 0)
    path_max = 1024;
#endif

#if HAVE_MACH_O_DYLD_H && HAVE__NSGETEXECUTABLEPATH
  char *location = alloca (path_max);
  uint32_t length = path_max;
  if (_NSGetExecutablePath (location, &length) == 0 && location[0] == '/')
    return _gst_get_full_file_name (location);

#elif defined __linux__
  /* The executable is accessible as /proc/<pid>/exe.  In newer Linux
     versions, also as /proc/self/exe.  Linux >= 2.1 provides a symlink
     to the true pathname; older Linux versions give only device and ino,
     enclosed in brackets, which we cannot use here.  */
  {
    char buf[6 + 10 + 5];
    char *location = xmalloc (path_max + 1);
    ssize_t n;

    sprintf (buf, "/proc/%d/exe", getpid ());
    n = readlink (buf, location, path_max);
    if (n > 0 && location[0] != '[')
      {
        location[n] = '\0';
        return location;
      }
    if (executable_fd < 0)
      executable_fd = open (buf, O_RDONLY, 0);
  }
#endif

  if (*argv0 == '-')
    argv0++;

  /* Guess the executable's full path.  We assume the executable has been
     called via execlp() or execvp() with properly set up argv[0].
     exec searches paths without slashes in the directory list given
     by $PATH.  */
  if (!strchr (argv0, '/'))
    {
      const char *p_next = getenv ("PATH");
      const char *p;

      while ((p = p_next) != NULL)
	{
	  char *concat_name;

	  p_next = strchr (p, ':');
	  /* An empty PATH element designates the current directory.  */
	  if (p_next == p + 1)
	    concat_name = xstrdup (argv0);
	  else if (!p_next)
	    asprintf (&concat_name, "%s/%s", p, argv0);
	  else
	    asprintf (&concat_name, "%.*s/%s", (int)(p_next++ - p), p, argv0);

	  if (maybe_executable (concat_name))
	    {
	      char *full_path = _gst_get_full_file_name (concat_name);
	      free (concat_name);
	      return full_path;
	    }

	  free (concat_name);
	}
      /* Not found in the PATH, assume the current directory.  */
    }

  if (maybe_executable (argv0))
    return _gst_get_full_file_name (argv0);

  /* No way to find the executable.  */
#ifdef __linux__
  close (executable_fd);
  executable_fd = -1;
#endif
  return NULL;
}

void
_gst_set_executable_path (const char *argv0)
{
  _gst_executable_path = find_executable (argv0);
}
