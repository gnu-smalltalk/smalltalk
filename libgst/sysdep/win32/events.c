/******************************** -*- C -*- ****************************
 *
 *	Asynchronous events from the VM - Win32 version
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2009 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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

/* Note: this code is mostly untested, especially the delicate socket
   handling parts.  However it works decently enough for consoles and
   delays, and it gets rid of many hacks, so I am enabling it already.  */


enum fhev_kind {
  EV_TTY,
  EV_SOCKET,
  EV_PASSIVE_SOCKET,
  EV_EVENT
};

/* This structure defines a list of pairs `struct pollfd'->semaphore
   which map each pollfd that is passed by the OS to the semaphore to
   be signalled when the corresponding I/O situation becomes possible.  */
struct handle_events
{
  volatile LONG refcount;
  enum fhev_kind kind;
  HANDLE handle;
  OOP semaphoreOOP;
  int error;
  struct semaphore_list *list;
  struct handle_events *next;
};

/* This structure defines a list of pairs `struct pollfd'->semaphore
   which map each pollfd that is passed by the OS to the semaphore to
   be signalled when the corresponding I/O situation becomes possible.  */
typedef struct semaphore_list
{
  int mask;
  OOP semaphoreOOP;
  struct semaphore_list *next;
}
semaphore_list;

/* These two variables hold the list of `handle_events' structures.
   Replacing this with a binary tree is not really useful because the
   array of pollfd structures must be scanned and kept sequential
   every time that I/O happens, so it does not bother us very much to
   have to scan the list to find the semaphore that is to be signaled.  */
static struct handle_events *head;
static CRITICAL_SECTION handle_events_cs;

/* Communication with the timer thread.  */
static HANDLE hNewWaitEvent;
static long sleepTime;

/* Communication with sockets.  */
#define hAlarmEvent	handles[0]
#define hSocketEvent	handles[1]
#define hConIn		handles[2]
static HANDLE handles[3];

/* */
static HANDLE hWakeUpEvent;

static const LONG masks[3] = {
  FD_READ | FD_ACCEPT,
  FD_WRITE | FD_CONNECT,
  FD_OOB
};

static inline struct handle_events *
fhev_ref (struct handle_events *ev)
{
  if (ev)
    InterlockedIncrement (&ev->refcount);
  return ev;
}

static inline struct handle_events *
fhev_unref (struct handle_events *ev)
{
  if (ev && InterlockedDecrement (&ev->refcount) != 0)
    return ev;
  
  xfree (ev);
  return NULL;
}

static struct handle_events *
fhev_find (HANDLE handle)
{
  struct handle_events *ev, **p_ev;
  EnterCriticalSection (&handle_events_cs);
  for (p_ev = &head; (ev = *p_ev); p_ev = &ev->next)
    if (ev->handle == handle)
      break;
  fhev_ref (ev);
  LeaveCriticalSection (&handle_events_cs);
  return ev;
}

static struct handle_events *
fhev_delete (HANDLE handle)
{
  struct handle_events *ev, **p_ev;
  EnterCriticalSection (&handle_events_cs);
  for (p_ev = &head; (ev = *p_ev); p_ev = &ev->next)
    if (ev->handle == handle)
      break;
  
  if (ev)
    {
      ev->semaphoreOOP = NULL;
      *p_ev = ev->next;
    }

  LeaveCriticalSection (&handle_events_cs);
  return ev;
}

static struct handle_events *
fhev_new (HANDLE handle, enum fhev_kind kind)
{
  struct handle_events *ev, **p_ev;
  EnterCriticalSection (&handle_events_cs);
  for (p_ev = &head; ; p_ev = &ev->next)
    {
      ev = *p_ev;
      if (!ev)
	{
	  ev = xcalloc (1, sizeof (struct handle_events));
	  ev->refcount = 2;
	  ev->kind = kind;
	  ev->handle = handle;
	  *p_ev = ev;
	  break;
	}
      else if (ev->handle == handle)
	{
	  fhev_ref (ev);
	  break;
	}
    }
  LeaveCriticalSection (&handle_events_cs);
  return ev;
}

static int
poll_console_input (HANDLE fh)
{
  DWORD avail, nbuffer;
  INPUT_RECORD *irbuffer;
  BOOL bRet;
  int i;

  bRet = GetNumberOfConsoleInputEvents (fh, &nbuffer);
  if (!bRet || nbuffer == 0)
    return 0;

  irbuffer = (INPUT_RECORD *) alloca (nbuffer * sizeof (INPUT_RECORD));
  bRet = PeekConsoleInput (fh, irbuffer, nbuffer, &avail);
  if (!bRet || avail == 0)
    return 0;

  for (i = 0; i < avail; i++)
    
    if (irbuffer[i].EventType == KEY_EVENT)
      return 1;
  return 0;
}

int
fhev_poll (struct handle_events *ev)
{
  static struct timeval tv0 = { 0, 0 };
  SOCKET s;
  fd_set rfds, wfds, xfds;

  if (ev->error)
    return FD_CLOSE;

  switch (ev->kind)
    {
    case EV_TTY:
      if (poll_console_input (ev->handle))
	return FD_READ | FD_WRITE;
      else
	return FD_WRITE;

    case EV_SOCKET:
      s = (SOCKET) ev->handle;
      FD_ZERO (&rfds);
      FD_ZERO (&wfds);
      FD_ZERO (&xfds);
      FD_SET (s, &rfds);
      FD_SET (s, &wfds);
      FD_SET (s, &xfds);
      select (0, &rfds, &wfds, &xfds, &tv0);
      return
	((FD_ISSET (s, &rfds) ? FD_READ : 0)
	 | (FD_ISSET (s, &wfds) ? FD_WRITE : 0)
	 | (FD_ISSET (s, &xfds) ? FD_OOB : 0));

    case EV_PASSIVE_SOCKET:
      s = (SOCKET) ev->handle;
      FD_ZERO (&rfds);
      FD_SET (s, &rfds);
      select (0, &rfds, NULL, NULL, &tv0);
      return FD_ISSET (s, &rfds) ? FD_ACCEPT : 0;

    default:
      return FD_READ | FD_WRITE;
    }
}


/* thread for precise alarm callbacks */
static unsigned WINAPI
alarm_thread (LPVOID unused)
{
  WaitForSingleObject (hNewWaitEvent, INFINITE);
  for (;;)
    {
      if (sleepTime > 0)
	{
	  if (WaitForSingleObject (hNewWaitEvent, sleepTime) !=
	      WAIT_TIMEOUT)
	    {
	      /* The old wait was canceled by a new one */
	      continue;
	    }
	}
      SetEvent (hAlarmEvent);
      WaitForSingleObject (hNewWaitEvent, INFINITE);
    }
  return 0;
}

static void
signal_semaphores (struct handle_events *ev, LONG lEvents)
{
  struct semaphore_list *node, **pprev;
  for (node = ev->list, pprev = &ev->list; node; node = *pprev)
    if (ev->error || (lEvents & node->mask) != 0)
      {
	_gst_async_signal_and_unregister (node->semaphoreOOP);
	*pprev = node->next;
	xfree (node);
      }
    else
      pprev = &node->next;
}
	  
static unsigned
WaitForMultipleObjectsDispatchMsg (int nhandles, HANDLE *handles,
				   BOOLEAN bWaitAll, DWORD dwTimeout,
				   DWORD qsMask)
{
  DWORD ret;
  ret = MsgWaitForMultipleObjects (nhandles, handles, FALSE,
                                   INFINITE, QS_ALLINPUT);
  if (ret == WAIT_OBJECT_0 + nhandles)
    {
      /* new input of some other kind */
      BOOL bRet;
      MSG msg;
      while ((bRet = PeekMessage (&msg, NULL, 0, 0, PM_REMOVE)) != 0)
        {
          TranslateMessage (&msg);
          DispatchMessage (&msg);
        }
    }
  return ret;
}

static unsigned WINAPI
polling_thread (LPVOID unused)
{
  struct handle_events *ev;

  for (;;)
    {
      DWORD ret;
      HANDLE *h;
      OOP semOOP;
      int nhandles;
      
      nhandles = hConIn ? 3 : 2;
      ret = WaitForMultipleObjects (nhandles, handles, FALSE, INFINITE);
      h = &handles[ret - WAIT_OBJECT_0];
      EnterCriticalSection (&handle_events_cs);
      if (h == &hSocketEvent)
	{
	  for (ev = head; ev; ev = ev->next)
	    {
	      SOCKET s = (SOCKET) ev->handle;
	      WSANETWORKEVENTS nev;
	      int i;
	      if (ev->kind != EV_SOCKET && ev->kind != EV_PASSIVE_SOCKET)
		continue;
	      if (ev->error)
		continue;
	      
	      WSAEnumNetworkEvents (s, NULL, &nev);
	      if (nev.lNetworkEvents & FD_CLOSE)
		ev->error = WSAESHUTDOWN;
	      else
		for (i = 0; i < FD_CLOSE_BIT; i++)
		  if (nev.lNetworkEvents & (1 << i)
		      && nev.iErrorCode[i] != 0)
		    {
		      ev->error = nev.iErrorCode[i];
		      break;
		    }

	      if (ev->error)
		signal_semaphores (ev, 0);
	      else
		{
		  int r = fhev_poll (ev);
		  if (r)
		    signal_semaphores (ev, r);
		}
	    }
	}

      else if (h == &hAlarmEvent)
	{
	  ev = fhev_find (*h);
	  assert (ev->list == NULL);
	  semOOP = ev ? ev->semaphoreOOP : NULL;
	  if (semOOP)
	    {
	      _gst_async_signal (semOOP);
	      ev->semaphoreOOP = NULL;
	    }
	  fhev_unref (ev);
	}

      else
	{
	  if (poll_console_input (hConIn))
            {
              assert (hConIn && *h == hConIn);
              ev = fhev_find (*h);
              assert (ev);
              signal_semaphores (ev, FD_READ | FD_WRITE);
              fhev_unref (ev);
            }
	}
      LeaveCriticalSection (&handle_events_cs);
    }
  return 0;
}

void
_gst_init_async_events (void)
{
  extern HANDLE WINAPI GetConsoleInputWaitHandle (void);
  DWORD dummy;

  /* Starts as non-signaled, so alarm_thread will wait */
  InitializeCriticalSection (&handle_events_cs);

  hSocketEvent = CreateEvent (NULL, FALSE, FALSE, NULL);
  hNewWaitEvent = CreateEvent (NULL, FALSE, FALSE, NULL);
  hAlarmEvent = CreateEvent (NULL, FALSE, FALSE, NULL);
  hWakeUpEvent = CreateEvent (NULL, FALSE, FALSE, NULL);
  fhev_unref (fhev_new (hAlarmEvent, EV_EVENT));

  hConIn = CreateFile ("CONIN$", GENERIC_READ, FILE_SHARE_READ,
		       NULL, OPEN_EXISTING, 0, NULL);
  if (GetConsoleMode (hConIn, &dummy) == 0)
    hConIn = 0;
  else
    fhev_unref (fhev_new (hConIn, EV_TTY));

  _beginthreadex (NULL, 1024, alarm_thread, NULL, 0, NULL);
  _beginthreadex (NULL, 1024, polling_thread, NULL, 0, NULL);
}

void
_gst_async_timed_wait (OOP semaphoreOOP,
		       int64_t nsTime)
{
  struct handle_events *ev = fhev_find (hAlarmEvent);

  ev->semaphoreOOP = NULL;
  EnterCriticalSection (&handle_events_cs);
  sleepTime = (nsTime - _gst_get_ns_time()) / 1000000;
  SetEvent (hNewWaitEvent);
  ev->semaphoreOOP = semaphoreOOP;
  LeaveCriticalSection (&handle_events_cs);
  fhev_unref (ev);
}

mst_Boolean
_gst_is_timeout_programmed (void)
{
  struct handle_events *ev = fhev_find (hAlarmEvent);
  int result = (ev->semaphoreOOP != NULL);
  fhev_unref (ev);
  return result;
}

void
_gst_register_socket (int fd,
		      mst_Boolean passive)
{
  HANDLE fh = _get_osfhandle (fd);
  struct handle_events *ev = fhev_new (fh, EV_SOCKET);
  if (passive)
    ev->kind = EV_PASSIVE_SOCKET;
  WSAEventSelect ((SOCKET) fh, hSocketEvent,
		  masks[0] | masks[1] | masks[2] | FD_CLOSE);
  fhev_unref (ev);
}

int
_gst_sync_file_polling (int fd,
			int cond)
{
  HANDLE fh = _get_osfhandle (fd);
  struct handle_events *ev;
  LONG lEvents;

  if (cond < 0 || cond > 2)
    return -1;

  ev = fhev_find (fh);
  /* For now, make pipes blocking.  */
  if (!ev)
    return (GetFileType (fh) != 0 || GetLastError () != NO_ERROR) ? 1 : -1;
      
  EnterCriticalSection (&handle_events_cs);
  lEvents = fhev_poll (ev);
  LeaveCriticalSection (&handle_events_cs);
  if (lEvents & FD_CLOSE)
    {
      _gst_set_errno (ev->error);
      fhev_unref (ev);
      return -1;
    }
  else
    {
      fhev_unref (ev);
      return (lEvents & masks[cond]) != 0;
    }
}

void
_gst_remove_fd_polling_handlers (int fd)
{
  HANDLE fh = _get_osfhandle (fd);
  fhev_unref (fhev_delete (fh));
}

int
_gst_get_fd_error (int fd)
{
  HANDLE fh = _get_osfhandle (fd);
  struct handle_events *ev = fhev_find (fh);
  int error;
 
  if (!ev)
    return 0;

  error = ev->error;
  fhev_unref (ev);
  return error;
}

void
_gst_pause (void)
{
  /* Doing an async call between the _gst_have_pending_async_calls and the
     wait will set the event again, so the wait will exit immediately.  */
  ResetEvent (hWakeUpEvent);
  if (!_gst_have_pending_async_calls ())
    WaitForMultipleObjectsDispatchMsg (1, &hWakeUpEvent, FALSE,
                                       INFINITE, QS_ALLINPUT);
}

void
_gst_wakeup (void)
{
  SetEvent (hWakeUpEvent);
}

int
_gst_async_file_polling (int fd,
			 int cond,
			 OOP semaphoreOOP)
{
  HANDLE fh = _get_osfhandle (fd);
  struct handle_events *ev;
  struct semaphore_list *node;
  LONG lEvents;

  if (cond < 0 || cond > 2)
    return -1;

  ev = fhev_find (fh);
  /* For now, make pipes blocking.  */
  if (!ev)
    return (GetFileType (fh) != 0 || GetLastError () != NO_ERROR) ? 1 : -1;
      
  EnterCriticalSection (&handle_events_cs);
  lEvents = fhev_poll (ev);
  if (lEvents & FD_CLOSE)
    {
      _gst_set_errno (ev->error);
      fhev_unref (ev);
      LeaveCriticalSection (&handle_events_cs);
      return -1;
    }
  else if ((lEvents & masks[cond]) != 0)
    {
      fhev_unref (ev);
      LeaveCriticalSection (&handle_events_cs);
      return 1;
    }

  node = (struct semaphore_list *) xcalloc (1, sizeof (struct semaphore_list));
  node->semaphoreOOP = semaphoreOOP;
  node->mask = masks[cond];
  node->next = ev->list;
  ev->list = node;
  
  _gst_register_oop (semaphoreOOP);
  _gst_sync_wait (semaphoreOOP);
  fhev_unref (ev);
  LeaveCriticalSection (&handle_events_cs);
  return 0;
}

void
_gst_wait_for_input (int fd)
{
  HANDLE h = _get_osfhandle (fd);
  DWORD dummy;
  if (GetConsoleMode (h, &dummy) != 0)
    {
      while (!poll_console_input (h))
        WaitForMultipleObjectsDispatchMsg (1, &h, FALSE,
                                           INFINITE, QS_ALLINPUT);
    }
}

