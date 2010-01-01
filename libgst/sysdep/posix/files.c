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

#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#ifndef O_BINARY
#define O_BINARY     0
#endif

#ifdef HAVE_SPAWNL
#include <process.h>
#ifndef P_WAIT
#define P_WAIT       0
#define P_NOWAIT     1
#define P_OVERLAY    2
#define P_NOWAITO    3
#define P_DETACH     4
#endif /* !P_WAIT */
#endif /* HAVE_SPAWNL */

#if defined FASYNC && !defined O_ASYNC
#define O_ASYNC FASYNC
#endif

#ifndef PATH_MAX
#define PATH_MAX  1024		/* max length of a file and path */
#endif

#ifndef MAXSYMLINKS
#define MAXSYMLINKS 5
#endif

char *
_gst_get_full_file_name (const char *name)
{
  char *rpath, *dest;
  const char *start, *end, *rpath_limit;
  long int path_max;
#ifdef HAVE_READLINK
  int num_links = 0;
  char *extra_buf = NULL;
#endif

#ifdef PATH_MAX
  path_max = PATH_MAX;
#else
  path_max = pathconf (name, _PC_PATH_MAX);
  if (path_max <= 0)
    path_max = 1024;
#endif

  rpath = malloc (path_max);
  if (rpath == NULL)
    return NULL;
  rpath_limit = rpath + path_max;

  if (name[0] != '/')
    {
      if (!getcwd (rpath, path_max))
	goto error;

      dest = strchr (rpath, '\0');
    }
  else
    {
      rpath[0] = '/';
      dest = rpath + 1;
    }

  for (start = end = name; *start; start = end)
    {
      struct stat st;

      /* Skip sequence of multiple path-separators.  */
      while (*start == '/')
	++start;

      /* Find end of path component.  */
      for (end = start; *end && *end != '/'; ++end)
	/* Nothing.  */;

      if (end - start == 0)
	break;
      else if (end - start == 1 && start[0] == '.')
	/* nothing */;
      else if (end - start == 2 && start[0] == '.' && start[1] == '.')
	{
	  /* Back up to previous component, ignore if at root already.  */
	  if (dest > rpath + 1)
	    while ((--dest)[-1] != '/');
	}
      else
	{
	  size_t new_size;

	  if (dest[-1] != '/')
	    *dest++ = '/';

	  if (dest + (end - start) >= rpath_limit)
	    {
	      ptrdiff_t dest_offset = dest - rpath;
	      char *new_rpath;

	      new_size = rpath_limit - rpath;
	      if (end - start + 1 > path_max)
		new_size += end - start + 1;
	      else
		new_size += path_max;
	      new_rpath = (char *) realloc (rpath, new_size);
	      if (new_rpath == NULL)
		goto error;
	      rpath = new_rpath;
	      rpath_limit = rpath + new_size;

	      dest = rpath + dest_offset;
	    }

	  memcpy (dest, start, end - start);
	  dest += end - start;
	  *dest = '\0';

	  if (lstat (rpath, &st) < 0)
	    goto error;

#if HAVE_READLINK
	  if (S_ISLNK (st.st_mode))
	    {
	      char *buf;
	      size_t len;
	      int n;

	      if (++num_links > MAXSYMLINKS)
		{
		  errno = ELOOP;
		  goto error;
		}

	      buf = alloca (path_max);
	      n = readlink (rpath, buf, path_max - 1);
	      if (n < 0)
		{
		  int saved_errno = errno;
		  errno = saved_errno;
		  goto error;
		}
	      buf[n] = '\0';
	      if (!extra_buf)
		extra_buf = alloca (path_max);

	      len = strlen (end);
	      if ((long int) (n + len) >= path_max)
		{
		  errno = ENAMETOOLONG;
		  goto error;
		}

	      /* Careful here, end may be a pointer into extra_buf... */
	      memmove (&extra_buf[n], end, len + 1);
	      name = end = memcpy (extra_buf, buf, n);

	      if (buf[0] == '/')
		dest = rpath + 1;	/* It's an absolute symlink */
	      else
		/* Back up to previous component, ignore if at root already: */
		if (dest > rpath + 1)
		  while ((--dest)[-1] != '/');
	    }
#endif
	}
    }
  if (dest > rpath + 1 && dest[-1] == '/')
    --dest;
  *dest = '\0';
  return rpath;

error:
  {
    int saved_errno = errno;
    free (rpath);
    errno = saved_errno;
  }
  return NULL;
}


static void
sigchld_handler (int signum)
{
#ifdef HAVE_WAITPID
  int pid, status, serrno;
  serrno = errno;
  do
    pid = waitpid (-1, &status, WNOHANG);
  while (pid > 0);
  errno = serrno;
#endif

  /* Pass it to the SIGIO handler, it might reveal a POLLHUP event.  */
  raise (SIGIO);
  _gst_set_signal_handler (SIGCHLD, sigchld_handler);
}

/* Use sockets or pipes.  */
int
_gst_open_pipe (const char *command,
		const char *mode)
{
  int fd[2];
  int our_fd, child_fd;
  int access;
  int result;

  _gst_set_signal_handler (SIGCHLD, sigchld_handler);
  access = strchr (mode, '+') ? O_RDWR :
    (mode[0] == 'r' ? O_RDONLY : O_WRONLY);

  if (access == O_RDWR)
    {
      result = socketpair (AF_UNIX, SOCK_STREAM, 0, fd);
      our_fd = fd[1];
      child_fd = fd[0];
    }
  else
    {
      result = pipe (fd);
      our_fd = access == O_RDONLY ? fd[0] : fd[1];
      child_fd = access == O_RDONLY ? fd[1] : fd[0];
    }

  if (result == -1)
    return -1;

  _gst_set_signal_handler (SIGPIPE, SIG_DFL);
  _gst_set_signal_handler (SIGFPE, SIG_DFL);

#ifdef HAVE_SPAWNL
  {
    /* Prepare file descriptors, saving the old ones so that we can keep
       them.  */
    int save_stdin = -1, save_stdout = -1, save_stderr = -1;
    if (access != O_WRONLY)
      {
        save_stdout = dup (1);
        save_stderr = dup (2);
        dup2 (child_fd, 1);
        dup2 (child_fd, 2);
      }
    if (access != O_RDONLY)
      {
        save_stdin = dup (0);
        dup2 (child_fd, 0);
      }

    result = spawnl (P_NOWAIT, "/bin/sh", "/bin/sh", "-c", command, NULL);

    if (save_stdin != -1)
      {
        dup2 (save_stdin, 0);
        close (save_stdin);
      }

    if (save_stdout != -1)
      {
        dup2 (save_stdout, 1);
        close (save_stdout);
      }

    if (save_stderr != -1)
      {
        dup2 (save_stderr, 2);
        close (save_stderr);
      }
  }
#else /* !HAVE_SPAWNL */
  /* We suppose it is a system that has fork.  */
  result = fork ();
  if (result == 0)
    {
      /* Child process */
      close (our_fd);
      if (access != O_WRONLY)
	dup2 (child_fd, 1);
      if (access != O_RDONLY)
        dup2 (child_fd, 0);

      _exit (system (command) >= 0);
      /*NOTREACHED*/
    }

#endif /* !HAVE_SPAWNL */

  close (child_fd);
  _gst_set_signal_handler (SIGPIPE, SIG_IGN);
  _gst_set_signal_handler (SIGFPE, SIG_IGN);

  if (result == -1)
    {
      int save_errno;
      save_errno = errno;
      close (our_fd);
      errno = save_errno;
      return (-1);
    }
  else
    return (our_fd);
}

