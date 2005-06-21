/******************************** -*- C -*- ****************************
 *
 *	Header file for asynchronous events
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002 Free Software Foundation, Inc.
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

#ifndef GST_EVENTS_H
#define GST_EVENTS_H

/* Initialize the data structures used to hold information about
   asynchronous events requested by Smalltalk programs. */
extern void _gst_init_async_events (void);

/* Arrange so that after DELAY milliseconds SEMAPHOREOOP is signaled
   by the virtual machine. Previous waits are discarded. */
extern void _gst_async_timed_wait (OOP semaphoreOOP,
				   int delay);

/* Arrange so that when the SIG signal arrives from the operating
   system, SEMAPHOREOOP is signaled by the virtual machine.  A
   previous wait for the same signal, if any, are discarded. */
extern void _gst_async_interrupt_wait (OOP semaphoreOOP,
				       int sig);

/* Answer whether a timeout has been scheduled and a semaphore was
   passed to the virtual machine, to be signaled when the timer
   fires. */
extern mst_Boolean _gst_is_timeout_programmed (void) ATTRIBUTE_PURE;

/* Check whether I/O is possible on the FD file descriptor; COND is 0
   to check for pending input, 1 to check for the possibility of doing
   non-blocking output, 2 to check for pending exceptional situations
   (such as out-of-band data).  Answer -1 if there is an error, 0 if
   I/O is impossible, 1 if possible. */
extern int _gst_sync_file_polling (int fd,
				   int cond);

/* Check whether I/O is possible on the FD file descriptor; COND is 0
   to check for pending input, 1 to check for the possibility of doing
   non-blocking output, 2 to check for pending exceptional situations
   (such as out-of-band data).  Answer -1 if there is an error, 0 if
   I/O is impossible, 1 if possible.  If 0 is answered, the virtual
   machine arranges things so that when the given condition is true
   SEMAPHOREOOP is signaled. 

   Note: due to lack of support from many kernels, waiting for a
   semaphore to be signaled when *output* is possible is risky and
   known to works for sockets only. */
extern int _gst_async_file_polling (int fd,
				    int cond,
				    OOP semaphoreOOP);

#endif /* GST_EVENTS_H */
