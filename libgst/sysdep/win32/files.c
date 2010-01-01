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

#ifdef WIN32
# define WIN32_LEAN_AND_MEAN /* avoid including junk */
# include <windows.h>
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




char *
_gst_get_full_file_name (const char *name)
{
  char *rpath;
  long int path_max;
  struct stat st;
  DWORD retval;

  path_max = PATH_MAX;

  rpath = malloc (path_max);
  if (rpath == NULL)
    return NULL;

  retval = GetFullPathNameA (name, path_max, rpath, NULL);
  if (retval > path_max)
    {
      rpath = realloc (rpath, retval);
      retval = GetFullPathNameA (name, retval, rpath, NULL);
    }
  if (retval != 0 && stat (rpath, &st) != -1)
    return rpath;

  {
    int saved_errno = errno;
    free (rpath);
    errno = saved_errno;
  }
  return NULL;
}


#define NAMED_PIPE_PREFIX "\\\\..\\pipe\\_gnu_smalltalk_named_pipe"


int
_gst_open_pipe (const char *command,
		const char *mode)
{
  int master, slave;
  int access;
  int result;
  int save_stdin = -1;
  int save_stdout = -1;
  char slavenam[sizeof (NAMED_PIPE_PREFIX) + 25];
  HANDLE hMaster, hSlave;
  static long int id = 0;

  access = strchr (mode, '+') ? O_RDWR :
    (mode[0] == 'r' ? O_RDONLY : O_WRONLY);

  /* Windows 95 only has anonymous pipes, so we prefer them for unidirectional
     pipes; we have no choice but named pipes for bidirectional operation.
     Note that CreatePipe gives two handles, so we open both sides at once
     and store the file descriptor into SLAVE, while CreateNamedPipe has
     to be opened on the slave side separately.  */
  switch (access)
    {
    case O_RDONLY:
      if (!CreatePipe (&hMaster, &hSlave, NULL, 0))
	return -1;

      slave = _open_osfhandle (hSlave, O_WRONLY | O_BINARY);
      break;

    case O_WRONLY:
      if (!CreatePipe (&hSlave, &hMaster, NULL, 0))
	return -1;

      slave = _open_osfhandle (hSlave, O_RDONLY | O_BINARY);
      break;
				
    case O_RDWR:
      sprintf (slavenam, NAMED_PIPE_PREFIX "_%d_%d__", getpid (), id++);
      hMaster = CreateNamedPipe (slavenam,
				 PIPE_ACCESS_DUPLEX, 0, 1, 0, 0, 0, NULL);

      if (!hMaster)
	return -1;

      slave = open (slavenam, O_RDWR | O_BINARY);
      break;
    }

  master = _open_osfhandle (hMaster, access | O_NOINHERIT | O_BINARY);
  if (master == -1 || slave == -1)
    {
      if (master != -1)
	close (master);
      if (slave != -1)
	close (slave);
      return -1;
    }

  /* Duplicate the handles.  Which handles are to be hooked is
     anti-intuitive: remember that ACCESS gives the parent's point 
     of view, not the child's, so `read only' means the child
     should write to the pipe and `write only' means the child
     should read from the pipe.  */
  if (access != O_RDONLY)
    {
      save_stdin = dup (0);
      dup2 (slave, 0);
    }

  if (access != O_WRONLY)
    {
      save_stdout = dup (1);
      dup2 (slave, 1);
    }

  if (slave > 2)
    close (slave);

  result = spawnl (P_NOWAIT, getenv("COMSPEC"), "/C", command, NULL);

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

  if (result == -1)
    {
      int save_errno;
      save_errno = errno;
      close (master);
      errno = save_errno;
      return (-1);
    }
  else
    return (master);
}
