/******************************** -*- C -*- ****************************
 *
 *	Asynchronous events from the VM
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2003 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
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
  _gst_set_signal_handler (sig, SIG_DFL);

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
      result = poll (&pfd, 1, 0);
    }
  while ((result == -1) && (errno == EINTR));

  if (pfd.revents & pfd.events)
    return 1;

  else if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL))
    return -1;

  else
    return 0;
}

RETSIGTYPE
file_polling_handler (int sig)
{
  polling_queue *node, **pprev;
  int n;

  _gst_set_signal_handler (sig, file_polling_handler);

  for (;;)
    {
      if (num_used_pollfds == 0)
	return;

      do
	{
	  errno = 0;
	  n = poll (pollfds, num_used_pollfds, 0);
	}
      while (n == -1 && errno == EINTR);

      if (n == 0)
	return;

      num_used_pollfds = 0;
      for (node = head, pprev = &head; node && n; node = *pprev)
	{
	  struct pollfd *poll = &pollfds[node->poll];

	  if (poll->revents &
	      (poll->events | POLLERR | POLLHUP | POLLNVAL))
	    {
	      poll->events = 0;
	      _gst_async_signal_and_unregister (node->semaphoreOOP);

	      /* Pass over the current node */
	      *pprev = node->next;
	      if (p_tail_next == &node->next)
		p_tail_next = pprev;

	      xfree (node);
	      n--;
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

  /* Disable interrupts while playing with global variables */
  _gst_disable_interrupts ();

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

  _gst_enable_interrupts ();
  return (result);
}
