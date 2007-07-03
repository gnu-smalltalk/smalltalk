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
      ret = WaitForSingleObject (handle_array[i], 0);
      if (ret == WAIT_OBJECT_0)
	{
	  FD_SET (handle_fd[i], handle_set[i]);
	  nset++;
	}
    }

  return nset;
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
  BOOL bRet;
  int i, ret, data_available;
  size_t nread;
  INPUT_RECORD *irbuffer;
  DWORD nevents, nbuffer;
  HANDLE h = (HANDLE) _get_osfhandle (fd);
  ret = WaitForSingleObject (h, 0);
  if (ret == WAIT_OBJECT_0)
    data_available = 1;
  else
    data_available = 0;

  if (flags != MSG_PEEK)
    return 0;

  /* MSG_PEEK */
  if (GetFileType (h) != FILE_TYPE_CHAR)
    return (data_available ? 1 : 0);

  /* console (FILE_TYPE_CHAR) */
  nbuffer = nevents = 0;
  bRet = GetNumberOfConsoleInputEvents (h, &nbuffer);
  if (!bRet || nbuffer == 0)
    return 0;

  irbuffer = (INPUT_RECORD *) alloca (nbuffer * sizeof (INPUT_RECORD));
  bRet = PeekConsoleInput (h, irbuffer, nbuffer, &nevents);
  if (!bRet || nevents == 0)
    return 0;

  nread = 0;
  for (i = 0; i < nevents; i++)
    if (irbuffer[i].EventType == KEY_EVENT)
      nread++;

  return nread;
}
#endif
