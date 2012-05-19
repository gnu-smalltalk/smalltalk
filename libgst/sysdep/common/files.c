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

#ifdef HAVE_UTIME_H
# include <utime.h>
#endif

#ifdef HAVE_SYS_TIMES_H
# include <sys/times.h>
#endif

#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif

#ifdef HAVE_SYS_TIMEB_H
#include <sys/timeb.h>
#endif

#ifndef F_OK
#define F_OK 0
#define X_OK 1
#define W_OK 2
#define R_OK 4
#endif

#ifndef O_BINARY
#define O_BINARY     0
#endif

#if !defined O_CLOEXEC && defined O_NOINHERIT
#define O_CLOEXEC	O_NOINHERIT
#endif

#ifndef PATH_MAX
#define PATH_MAX  1024		/* max length of a file and path */
#endif

#ifndef MAXSYMLINKS
#define MAXSYMLINKS 5
#endif

char *
_gst_get_cur_dir_name (void)
{
  char *cwd;
  char *ret;
  unsigned path_max;
  int save_errno;

  path_max = (unsigned) PATH_MAX;
  path_max += 2;		/* The getcwd docs say to do this.  */

  cwd = xmalloc (path_max);

  errno = 0;
  do
    {
      ret = getcwd (cwd, path_max);
      if (ret)
	return (cwd);

      if (errno != ERANGE)
	break;

      errno = 0;
      path_max += 128;
      cwd = xrealloc (cwd, path_max);
    }
  while (!errno);

  save_errno = errno;
  xfree (cwd);
  errno = save_errno;
  return (NULL);
}


int
_gst_set_file_access_times (const char *name, long new_atime, long new_mtime)
{
  int result;
#if defined HAVE_UTIMES
  struct timeval times[2];
  times[0].tv_sec = new_atime + 86400 * 10957;
  times[1].tv_sec = new_mtime + 86400 * 10957;
  times[0].tv_usec = times[1].tv_usec = 0;
  result = utimes (name, times);
#elif defined HAVE_UTIME
  struct utimbuf utb;
  utb.actime = new_atime + 86400 * 10957;
  utb.modtime = new_mtime + 86400 * 10957;
  result = utime (name, &utb);
#else
#warning neither utime nor utimes are available.
  errno = ENOSYS;
  result = -1;
#endif
  if (!result)
    errno = 0;
  return (result);
}

mst_Boolean
_gst_file_is_newer (const char *file1, const char *file2)
{
  static char *prev_file1;
  static struct stat st1;
  struct stat st2;

  if (!prev_file1 || strcmp (file1, prev_file1))
    {
      if (prev_file1)
	xfree (prev_file1);
      prev_file1 = xstrdup (file1);

      if (!_gst_file_is_readable (file1))
        return false;
      if (stat (file1, &st1) < 0)
	return false;
    }

  if (!_gst_file_is_readable (file2))
    return true;
  if (stat (file2, &st2) < 0)
    return true;

  if (st1.st_mtime != st2.st_mtime)
    return st1.st_mtime > st2.st_mtime;

  /* 15 years have passed and nothing seems to have changed.  */
#if defined HAVE_STRUCT_STAT_ST_MTIMENSEC
  return st1.st_mtimensec >= st2.st_mtimensec;
#elif defined HAVE_STRUCT_STAT_ST_MTIM_TV_NSEC
  return st1.st_mtim.tv_nsec >= st2.st_mtim.tv_nsec;
#elif defined HAVE_STRUCT_STAT_ST_MTIMESPEC_TV_NSEC
  return st1.st_mtimespec.tv_nsec >= st2.st_mtimespec.tv_nsec;
#else
  /* Say that the image file is newer.  */
  return true;
#endif
}


mst_Boolean
_gst_file_is_readable (const char *fileName)
{
  return (access (fileName, R_OK) == 0);
}

mst_Boolean
_gst_file_is_writeable (const char *fileName)
{
  return (access (fileName, W_OK) == 0);
}

mst_Boolean
_gst_file_is_executable (const char *fileName)
{
  return (access (fileName, X_OK) == 0);
}

char *
_gst_relocate_path (const char *path)
{
  const char *p;
  char *s;

  /* Detect absolute paths.  */
#if defined(MSDOS) || defined(WIN32) || defined(__OS2__)
  if ((path[0] && path[1] == ':')
      || path[0] == '/' || path[0] == '\\')
    return xstrdup (path);
#else
  if (path[0] == '/')
    return xstrdup (path);
#endif

  /* Remove filename from executable path.  */
  p = _gst_executable_path + strlen (_gst_executable_path);
  do
    --p;
  while (p >= _gst_executable_path
         && *p != '/'
#if defined(MSDOS) || defined(WIN32) || defined(__OS2__)
	 && *p != '\\'
#endif
	);
  p++;

  /* Now p points just past the last separator (if any).  */
  s = alloca (p - _gst_executable_path + strlen (path) + 1);
  sprintf (s, "%.*s%s", (int)(p - _gst_executable_path), _gst_executable_path, path);
  return _gst_get_full_file_name (s);
}

int
_gst_open_file (const char *filename,
		const char *mode)
{
  mst_Boolean create = false;
  int oflags = O_BINARY, access = 0;
  int fd, i;

  switch (*mode)
    {
    case 'a':
      access = O_WRONLY;
      oflags |= O_APPEND;
      create = 1;
      break;
    case 'w':
      access = O_WRONLY;
      oflags |= O_TRUNC;
      create = 1;
      break;
    case 'r':
      access = O_RDONLY;
      break;
    default:
      return -1;
    }

  for (i = 1; i < 3; ++i)
    {
      ++mode;
      if (*mode == '\0')
	break;
      else if (*mode == '+')
        create = 1, access = O_RDWR;
      else if (*mode == 'x')
	oflags |= O_EXCL;
    }

#ifdef O_CLOEXEC
  oflags |= O_CLOEXEC;
#endif

  if (create)
    fd = open (filename, oflags | access | O_CREAT, 0666);
  else
    fd = open (filename, oflags | access);

  if (fd < 0)
    return -1;

#ifndef O_CLOEXEC
  fcntl (fd, F_SETFD, fcntl (fd, F_GETFD, 0) | 1);
#endif

  return fd;
}

mst_Boolean
_gst_is_pipe (int fd)
{
  struct stat st;

  fstat (fd, &st);
#ifdef S_IFREG
  return !(st.st_mode & S_IFREG);
#else
  return !S_ISREG (st.st_mode);
#endif
}

ssize_t
_gst_recv (int fd,
	   PTR buffer,
	   size_t size,
	   int flags)
{
#ifdef HAVE_SOCKETS
  ssize_t result;
  int save_errno = errno;

  for (;;)
    {
      result = recvfrom (FD_TO_SOCKET (fd), buffer, size, flags, NULL, NULL);
      if (is_socket_error (EFAULT))
        abort ();

      if (is_socket_error (EINTR))
	clear_socket_error ();
      else
	break;
    }

  if (errno == EINTR)
    errno = save_errno;

  return result;
#else
  errno = ENOSYS;
  return -1;
#endif
}

ssize_t
_gst_send (int fd,
	   PTR buffer,
	   size_t size,
	   int flags)
{
#ifdef HAVE_SOCKETS
  ssize_t result;
  int save_errno = errno;

  for (;;)
    {
      result = send (FD_TO_SOCKET (fd), buffer, size, flags);
      if (is_socket_error (EFAULT))
        abort ();

      if (is_socket_error (EINTR))
	clear_socket_error ();
      else
	break;
    }

  if (errno == EINTR)
    errno = save_errno;

  return result;
#else
  errno = ENOSYS;
  return -1;
#endif
}

ssize_t
_gst_read (int fd,
	   PTR buffer,
	   size_t size)
{
  ssize_t result;
  int save_errno = errno;

  do
    {
      result = read (fd, buffer, size);
      if (errno == EFAULT)
        abort ();
    }
  while (result == -1 && errno == EINTR);
  if (errno == EINTR)
    errno = save_errno;

  return result;
}

ssize_t
_gst_write (int fd,
	    PTR buffer,
	    size_t size)
{
  ssize_t result;
  int save_errno = errno;

  do
    {
      result = write (fd, buffer, size);
      if (errno == EFAULT)
        abort ();
    }
  while (result == -1 && errno == EINTR);
  if (errno == EINTR)
    errno = save_errno;

  return result;
}


void
_gst_init_sysdep (void)
{
  _gst_init_sysdep_timer ();
  tzset ();

#ifdef SIGPIPE
  _gst_set_signal_handler (SIGPIPE, SIG_IGN);
#endif
  _gst_set_signal_handler (SIGFPE, SIG_IGN);
#ifdef SIGPOLL
  _gst_set_signal_handler (SIGPOLL, SIG_IGN);
#elif defined SIGIO
  _gst_set_signal_handler (SIGIO, SIG_IGN);
#endif
#ifdef SIGURG
  _gst_set_signal_handler (SIGURG, SIG_IGN);
#endif
}

void
_gst_debug (void)
{
  fflush (stdout);
  /* abort(); */
  /* raise(SIGTRAP); */
  /* getchar(); */
}
