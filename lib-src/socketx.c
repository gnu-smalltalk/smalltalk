/* socketx.c - Extend WinSock functions to handle other objects than sockets
   Contributed by Freddie Akeroyd.

   Copyright 2007 Free Software Foundation, Inc.

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
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include <socketx.h>

#ifdef __MSVCRT__
#include <stdio.h>
#include <conio.h>

#define MAX_WIN_HANDLES	300	/* max number of fd we can handle */
#define CONSOLE_HUP -1

static int get_number_of_console_key_events (HANDLE h);

/* n = maxfd + 1 */
int
win_select (int n, fd_set * rfds, fd_set * wfds, fd_set * efds,
	    struct timeval *ptv)
{
  HANDLE handle_array[MAX_WIN_HANDLES];
  int handle_fd[MAX_WIN_HANDLES];
  fd_set *handle_set[MAX_WIN_HANDLES];
  DWORD ret, ret0, wait_timeout, nhandles;
  int i, nset;
  BOOL bRet;
  MSG msg;

  _flushall ();
  nhandles = 0;
  for (i = 0; i < n; i++)
    {
      if ((efds != NULL) && FD_ISSET (i, efds))
	FD_CLR (i, efds);	/* assume no exceptions */

      if ((wfds != NULL) && FD_ISSET (i, wfds))
	{
	  handle_array[nhandles] = (HANDLE) _get_osfhandle (i);
	  handle_fd[nhandles] = i;
	  handle_set[nhandles] = wfds;
	  nhandles++;
	  FD_CLR (i, wfds);	/* we will set it later if there is output */
	}

      if ((rfds != NULL) && FD_ISSET (i, rfds))
	{
	  handle_array[nhandles] = (HANDLE) _get_osfhandle (i);
	  handle_fd[nhandles] = i;
	  handle_set[nhandles] = rfds;
	  nhandles++;
	  FD_CLR (i, rfds);	/* we will set it later if there is input */
	}
    }

  if (ptv == NULL)
    wait_timeout = INFINITE;
  else
    wait_timeout = ptv->tv_sec * 1000 + ptv->tv_usec / 1000;

  for (;;)
    {
      ret =
	MsgWaitForMultipleObjects (nhandles, handle_array, FALSE,
				   wait_timeout, QS_ALLINPUT);
      ret0 = ret - WAIT_OBJECT_0;
      if (ret0 != nhandles)
	break;

      /* new input of some other kind */
      while ((bRet = PeekMessage (&msg, NULL, 0, 0, PM_REMOVE)) != 0)
	{
	  TranslateMessage (&msg);
	  DispatchMessage (&msg);
	}
    }

  /* now do a quick poll of all handles to see how many are ready */
  nset = 0;
  for (i = 0; i < nhandles; i++)
    {
      HANDLE h = handle_array[i];
      ret = WaitForSingleObject (h, 0);
      if (ret != WAIT_OBJECT_0)
	continue;

      /* Discard non-key events.  */
      if (GetFileType (h) == FILE_TYPE_CHAR
	  && get_number_of_console_key_events (h) == 0)
	 continue;

      FD_SET (handle_fd[i], handle_set[i]);
      nset++;
    }

  return nset;
}

int
get_number_of_console_key_events (HANDLE h)
{
  BOOL bRet;
  int i, ret, data_available;
  size_t nread;
  INPUT_RECORD *irbuffer;
  DWORD nevents, nbuffer;

  nbuffer = nevents = 0;
  bRet = GetNumberOfConsoleInputEvents (h, &nbuffer);
  if (!bRet || nbuffer == 0)
    return CONSOLE_HUP;

  irbuffer = (INPUT_RECORD *) alloca (nbuffer * sizeof (INPUT_RECORD));
  bRet = PeekConsoleInput (h, irbuffer, nbuffer, &nevents);
  if (!bRet || nevents == 0)
    return CONSOLE_HUP;

  nread = 0;
  for (i = 0; i < nevents; i++)
    if (irbuffer[i].EventType == KEY_EVENT)
      nread++;

  return nread;
}

/*
 * This only gets called with the MSG_PEEK flag by poll.c when a read is ready
 * It does not need to indicate the real
 * number of characters available ... only return values of 1 and 0
 * are currently tested for by poll.c
 * TODO: return real number of characters available
 */
int
win_recv (int fd, void *buffer, int n, int flags)
{
  HANDLE h;
  int ret;

  if (flags != MSG_PEEK)
    return 0;

  h = (HANDLE) _get_osfhandle (fd);
  ret = WaitForSingleObject (h, 0);
  if (ret != WAIT_OBJECT_0)
    return 0;

  if (GetFileType (h) != FILE_TYPE_CHAR)
    return 1;

  else
    {
      int keys = get_number_of_console_key_events (h);
      return (keys == CONSOLE_HUP ? 0 : keys);
    }
}


/* internal to Microsoft CRTLIB */
typedef struct
{
  long osfhnd;		/* underlying OS file HANDLE */
  char osfile;		/* attributes of file (e.g., open in text mode?) */
  char pipech;		/* one char buffer for handles opened on pipes */
#ifdef _MT
  int lockinitflag;
  CRITICAL_SECTION lock;
#endif				/* _MT */
} ioinfo;

#define IOINFO_L2E          5
#define IOINFO_ARRAY_ELTS   (1 << IOINFO_L2E)
#define _pioinfo(i)	    ( __pioinfo[(i) >> IOINFO_L2E] + \
			     ((i) & (IOINFO_ARRAY_ELTS - 1)) )
#define _osfile(i)	    (_pioinfo(i)->osfile)
#define _osfhnd(i)	    (_pioinfo(i)->osfhnd)

#define FOPEN  		    0x01

#ifdef __declspec
extern __attribute__ ((dllimport)) ioinfo * __pioinfo[];
#else
extern __declspec(dllimport) ioinfo * __pioinfo[];
#endif

static int
my_free_osfhnd (int filehandle)
{
  if ((_osfile (filehandle) & FOPEN) &&
      (_osfhnd (filehandle) != (long) INVALID_HANDLE_VALUE))
    {
      switch (filehandle)
	{
	case 0:
	  SetStdHandle (STD_INPUT_HANDLE, NULL);
	  break;
	case 1:
	  SetStdHandle (STD_OUTPUT_HANDLE, NULL);
	  break;
	case 2:
	  SetStdHandle (STD_ERROR_HANDLE, NULL);
	  break;
	}
      _osfhnd (filehandle) = (long) INVALID_HANDLE_VALUE;
      return (0);
    }
  else
    {
      errno = EBADF;		/* bad handle */
      _doserrno = 0L;		/* not an OS error */
      return -1;
    }
}

int
win_close (int filehandle)
{
  char buf[sizeof (int)];
  int bufsize = sizeof (buf);
  SOCKET sock = _get_osfhandle (fd);

  if (getsockopt (sock, SOL_SOCKET, SO_TYPE, buf, &bufsize) == 0)
    {
      int result = 0;
      if (closesocket (sock) == SOCKET_ERROR)
	result = -1;

      my_free_osfhnd (fd);
      _osfile (fd) = 0;
      return result;
    }
  else
    return _close (fd);
}

#endif

