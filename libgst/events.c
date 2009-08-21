/******************************** -*- C -*- ****************************
 *
 *	Asynchronous events from the VM
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2003, 2005, 2006, 2008 Free Software Foundation, Inc.
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
static polling_queue *head, **p_tail_next;

/* This variable holds a variable-sized array of pollfd structures.
   NUM_USED_POLLFDS of the total NUM_TOTAL_POLLFDS items available are
   being used.  */
static struct pollfd *pollfds;
static int num_used_pollfds, num_total_pollfds;

/* Holds the semaphores to be signaled when the operating system sends
   us a C-style signal.  */
static volatile OOP sem_int_vec[NSIG];

/* These are the signal handlers that we install to process
   asynchronous events and pass them to the Smalltalk virtual machine.
   file_polling_handler scans the above array of pollfds and signals
   the corresponding semaphores, while signal_handler signals
   sem_int_vec[SIG] and removes the semaphore from the vector (because
   C-style signal handlers are one-shot).  */
static RETSIGTYPE signal_handler (int sig);
static RETSIGTYPE file_polling_handler (int sig);


void
_gst_init_async_events (void)
{
  int i;

  for (i = 0; i < NSIG; i++)
    sem_int_vec[i] = _gst_nil_oop;

  head = NULL;
  p_tail_next = NULL;
}

RETSIGTYPE
signal_handler (int sig)
{
  _gst_disable_interrupts (true);
  if (!IS_NIL (sem_int_vec[sig]))
    {
      if (IS_CLASS (sem_int_vec[sig], _gst_semaphore_class))
	{
	  _gst_async_signal_and_unregister (sem_int_vec[sig]);
	  sem_int_vec[sig] = _gst_nil_oop;
	}
      else
	{
	  _gst_errorf
	    ("C signal trapped, but no semaphore was waiting");
	  raise (sig);
	}
    }

  _gst_enable_interrupts (true);
  _gst_set_signal_handler (sig, SIG_DFL);
}

void
_gst_async_timed_wait (OOP semaphoreOOP,
		       int delay)
{
  sem_int_vec[TIMER_REAL] = semaphoreOOP;
  _gst_register_oop (semaphoreOOP);
  _gst_signal_after (delay, signal_handler, TIMER_REAL);
}

mst_Boolean
_gst_is_timeout_programmed (void)
{
  return (!IS_NIL (sem_int_vec[TIMER_REAL]));
}

void
_gst_async_interrupt_wait (OOP semaphoreOOP,
			   int sig)
{
  sem_int_vec[sig] = semaphoreOOP;
  _gst_register_oop (semaphoreOOP);
  _gst_set_signal_handler (sig, signal_handler);

  /* should probably package up the old interrupt state here for return
     so that it can be undone */
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
      _gst_disable_interrupts (true);
      _gst_async_call (async_signal_polled_files, NULL);
      _gst_enable_interrupts (true);
    }

  _gst_set_signal_handler (sig, file_polling_handler);
}

void
_gst_pause (void)
{
#ifdef WIN32
  /* Dummy for now.  */
  _gst_usleep (20000);
#else
  _gst_disable_interrupts (false);
  if (!_gst_have_pending_async_calls ())
    {
      /* We use sigsuspend to atomically replace the mask.  pause does
         not allow that.  */
      sigset_t set;
      sigemptyset (&set);
      sigsuspend (&set);
    }
  _gst_enable_interrupts (false);
#endif
}

int
_gst_async_file_polling (int fd,
			 int cond,
			 OOP semaphoreOOP)
{
  int result;
  polling_queue *new;

  result = _gst_sync_file_polling (fd, cond);
  if (result != 0)
    return (result);

  new = (polling_queue *) xmalloc (sizeof (polling_queue));
  new->poll = num_used_pollfds;
  new->semaphoreOOP = semaphoreOOP;
  new->next = NULL;

  if (num_used_pollfds == num_total_pollfds)
    {
      num_total_pollfds += 64;
      pollfds = (struct pollfd *)
	xrealloc (pollfds, num_total_pollfds * sizeof (struct pollfd));
    }

  pollfds[num_used_pollfds].fd = fd;
  switch (cond)
    {
    case 0:
      pollfds[num_used_pollfds].events = POLLIN;
      break;
    case 1:
      pollfds[num_used_pollfds].events = POLLOUT;
      break;
    case 2:
      pollfds[num_used_pollfds].events = POLLPRI;
      break;
    default:
      return -1;
    }
  pollfds[num_used_pollfds].revents = 0;

  _gst_set_file_interrupt (fd, file_polling_handler);

  /* Now check if I/O was made possible while setting up our machinery...
     If so, exit; otherwise, wait on the semaphore and the SIGIO
     will wake us up.  */

  result = _gst_sync_file_polling (fd, cond);
  if (result == 0)
    {
      if (!head)
	head = new;
      else
	*p_tail_next = new;
      p_tail_next = &new->next;

      num_used_pollfds++;
      _gst_register_oop (semaphoreOOP);
      _gst_sync_wait (semaphoreOOP);
    }
  else
    xfree (new);

  return (result);
}
