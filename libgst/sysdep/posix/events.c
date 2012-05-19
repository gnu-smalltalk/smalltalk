/******************************** -*- C -*- ****************************
 *
 *	Asynchronous events from the VM - POSIX version
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006, 2008, 2009 Free Software Foundation, Inc.
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
#include "lock.h"

#include <poll.h>

#ifdef HAVE_UTIME_H
# include <utime.h>
#endif
#ifdef HAVE_SYS_TIMES_H
# include <sys/times.h>
#endif
#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif
#ifdef HAVE_TERMIOS_H
# include <termios.h>
#endif
#ifdef HAVE_STROPTS_H
# include <stropts.h>
#endif
#ifdef USE_POSIX_THREADS
# include <pthread.h>
#endif

static SigHandler sigio_handler = SIG_IGN;

void
set_file_interrupt (int fd,
		    SigHandler func)
{
  if (func != sigio_handler) 
    {
      sigio_handler = func;

#ifdef SIGPOLL
      _gst_set_signal_handler (SIGPOLL, func);
#else
      _gst_set_signal_handler (SIGIO, func);
#endif
#ifdef SIGURG
      _gst_set_signal_handler (SIGURG, func);
#endif
    }

#if defined F_SETOWN && defined O_ASYNC

  {
    int oldflags;

    oldflags = fcntl (fd, F_GETFL, 0);
    if (((oldflags & O_ASYNC)
	 || (fcntl (fd, F_SETFL, oldflags | O_ASYNC) != -1))
	&& fcntl (fd, F_SETOWN, getpid ()) != -1)
      return;
  }
#endif

#ifdef I_SETSIG
  if (ioctl (fd, I_SETSIG, S_INPUT | S_OUTPUT | S_HIPRI) > -1)
    return;
#endif

#ifdef FIOSSAIOSTAT
#ifdef FIOSSAIOOWN
  {
    int stat_flags = 1;
    int own_flags = getpid();

    if (ioctl (fd, FIOSSAIOSTAT, &stat_flags) != -1
	&& ioctl (fd, FIOSSAIOOWN, &own_flags) != -1)
      return;
  }
#endif
#endif

#ifndef __MSVCRT__
#ifdef FIOASYNC
  {
    int argFIOASYNC = 1;
#if defined SIOCSPGRP
    int argSIOCSPGRP = getpid ();

    if (ioctl (fd, SIOCSPGRP, &argSIOCSPGRP) > -1 ||
        ioctl (fd, FIOASYNC, &argFIOASYNC) > -1)
      return;
#elif defined O_ASYNC
    int oldflags;

    oldflags = fcntl (fd, F_GETFL, 0);
    if (((oldflags & O_ASYNC)
         || (fcntl (fd, F_SETFL, oldflags | O_ASYNC) != -1))
        && ioctl (fd, FIOASYNC, &argFIOASYNC) > -1)
      return;
#else
    if (ioctl (fd, FIOASYNC, &argFIOASYNC) > -1)
      return;
#endif
  }
#endif
#endif /* FIOASYNC */
}


/* This structure defines a list of pairs `struct pollfd'->semaphore
   which map each pollfd that is passed by the OS to the semaphore to
   be signalled when the corresponding I/O situation becomes possible.  */
typedef struct polling_queue
{
  int poll;
  OOP semaphoreOOP;
  struct polling_queue *next;
}
polling_queue;

/* These two variables hold the list of `polling_queue' structures.
   Replacing this with a binary tree is not really useful because the
   array of pollfd structures must be scanned and kept sequential
   every time that I/O happens, so it does not bother us very much to
   have to scan the list to find the semaphore that is to be signaled.  */
static polling_queue *head, **p_tail_next = &head;

/* This variable holds a variable-sized array of pollfd structures.
   NUM_USED_POLLFDS of the total NUM_TOTAL_POLLFDS items available are
   being used.  */
static struct pollfd *pollfds;
static int num_used_pollfds, num_total_pollfds;

/* These are the signal handlers that we install to process
   asynchronous events and pass them to the Smalltalk virtual machine.
   file_polling_handler scans the above array of pollfds and signals
   the corresponding semaphores.  */
static RETSIGTYPE file_polling_handler (int sig);


static RETSIGTYPE
dummy_signal_handler (int sig)
{
}

void
_gst_init_async_events (void)
{
  _gst_set_signal_handler (SIGUSR2, dummy_signal_handler);
}

void
_gst_async_timed_wait (OOP semaphoreOOP,
		       int64_t milliTime)
{
  _gst_async_interrupt_wait (semaphoreOOP, SIGALRM);
  _gst_sigalrm_at (milliTime);
}

mst_Boolean
_gst_is_timeout_programmed (void)
{
  return (!IS_NIL (no_opt (_gst_sem_int_vec[SIGALRM].data)));
}

void
_gst_register_socket (int fd,
		      mst_Boolean passive)
{
}

int
_gst_sync_file_polling (int fd,
			int cond)
{
  int result;
  struct pollfd pfd;

  pfd.fd = fd;
  switch (cond)
    {
    case 0:
      pfd.events = POLLIN;
      break;
    case 1:
      pfd.events = POLLOUT;
      break;
    case 2:
      pfd.events = POLLPRI;
      break;
    default:
      return -1;
    }

  do
    {
      errno = 0;
      pfd.revents = 0;
      result = poll (&pfd, 1, 0);
    }
  while ((result == -1) && (errno == EINTR));

  if (result == -1)
    return -1;

  if (pfd.revents & pfd.events)
    return 1;

  else if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL))
    {
      errno = 0;
      return -1;
    }

  else
    return 0;
}

static void
signal_polled_files (int fd, mst_Boolean try_again)
{
  polling_queue *node, **pprev;
  int n, more;

  if (num_used_pollfds == 0)
    return;

  do
    {
      if (fd == -1)
        do
	  {
	    errno = 0;
	    n = poll (pollfds, num_used_pollfds, 0);
	  }
        while (n == -1 && errno == EINTR);

      num_used_pollfds = 0;
      more = false;
      for (node = head, pprev = &head; node; node = *pprev)
	{
	  struct pollfd *poll = &pollfds[node->poll];

	  if (fd == -1
	      ? (poll->revents & (poll->events | POLLERR | POLLHUP | POLLNVAL))
	      : poll->fd == fd)
	    {
	      more = try_again;
	      poll->events = 0;
	      _gst_sync_signal (node->semaphoreOOP, false);
	      _gst_unregister_oop (node->semaphoreOOP);

	      /* Pass over the current node */
	      *pprev = node->next;
	      if (p_tail_next == &node->next)
		p_tail_next = pprev;

	      xfree (node);
	    }
	  else
	    {
	      poll->revents = 0;
	      node->poll = num_used_pollfds;
	      pollfds[num_used_pollfds++] = *poll;

	      /* Prepare to get the next node */
	      pprev = &(node->next);
	    }
	}
    }
  while (more && num_used_pollfds);
}

int
_gst_get_fd_error (int fd)
{
  return 0;
}

void
_gst_remove_fd_polling_handlers (int fd)
{
  signal_polled_files (fd, false);
}

static void
async_signal_polled_files (OOP unusedOOP)
{
  signal_polled_files (-1, true);
}

RETSIGTYPE
file_polling_handler (int sig)
{
  if (num_used_pollfds > 0)
    {
      static async_queue_entry e = { async_signal_polled_files, NULL, NULL };
      e.data = _gst_nil_oop;
      _gst_async_call_internal (&e);
    }

  _gst_set_signal_handler (sig, file_polling_handler);
  _gst_wakeup ();
}

#ifdef USE_POSIX_THREADS
pthread_t waiting_thread;
#endif

void
_gst_pause (void)
{
#ifdef USE_POSIX_THREADS
  waiting_thread = pthread_self ();
#endif
  _gst_disable_interrupts (false);
  if (!_gst_have_pending_async_calls ())
    {
      /* We use sigsuspend to atomically replace the mask.  pause does
         not allow that.  */
      sigset_t set;
      sigemptyset (&set);
      sigsuspend (&set);
    }
#ifdef USE_POSIX_THREADS
  waiting_thread = 0;
#endif
  _gst_enable_interrupts (false);
}

void
_gst_wakeup (void)
{
#ifdef USE_POSIX_THREADS
  __sync_synchronize ();
  if (waiting_thread && pthread_self () != waiting_thread)
    pthread_kill (waiting_thread, SIGUSR2);
#endif
}

int
_gst_async_file_polling (int fd,
			 int cond,
			 OOP semaphoreOOP)
{
  int result;
  int index;
  polling_queue *new;

  index = num_used_pollfds++;
  result = _gst_sync_file_polling (fd, cond);
  if (result != 0)
    {
      --num_used_pollfds;
      return (result);
    }

  new = (polling_queue *) xmalloc (sizeof (polling_queue));
  new->poll = index;
  new->semaphoreOOP = semaphoreOOP;
  new->next = NULL;

  if (index == num_total_pollfds)
    {
      num_total_pollfds += 64;
      pollfds = (struct pollfd *)
	xrealloc (pollfds, num_total_pollfds * sizeof (struct pollfd));
    }

  pollfds[index].fd = fd;
  switch (cond)
    {
    case 0:
      pollfds[index].events = POLLIN;
      break;
    case 1:
      pollfds[index].events = POLLOUT;
      break;
    case 2:
      pollfds[index].events = POLLPRI;
      break;
    default:
      return -1;
    }
  pollfds[index].revents = 0;

  set_file_interrupt (fd, file_polling_handler);

  /* Even if I/O was made possible while setting up our machinery,
     the list will only be walked before the next bytecode, so there
     is no race.  We incremented num_used_pollfds very early so that
     the async call will be scheduled.  */
  *p_tail_next = new;
  p_tail_next = &new->next;

  _gst_register_oop (semaphoreOOP);
  _gst_sync_wait (semaphoreOOP);
  return (result);
}

void
_gst_wait_for_input (int fd)
{
  int result;

  struct pollfd pfd;
  pfd.fd = fd;
  pfd.events = POLLIN;
  pfd.revents = 0;

  do
    {
      errno = 0;
      result = poll (&pfd, 1, -1); /* Infinite wait */
    }
  while ((result == 0 && (pfd.revents & POLLHUP) == 0)
	 || ((result == -1) && (errno == EINTR)));
}
