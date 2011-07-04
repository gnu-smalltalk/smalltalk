/******************************** -*- C -*- ****************************
 *
 * Asynchronous events handling.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001,2002,2003,2005,2006,2008,2009 Free Software Foundation, Inc.
 * Free Software Foundation, Inc.
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


/* Holds the semaphores to be signaled when the operating system sends
   us a C-style signal.  */
async_queue_entry _gst_sem_int_vec[NSIG];

/* Signals _gst_sem_int_vec[SIG] and removes the semaphore from the vector
   (because C-style signal handlers are one-shot).  */
static RETSIGTYPE signal_handler (int sig);


RETSIGTYPE
signal_handler (int sig)
{
  if (_gst_sem_int_vec[sig].data)
    {
      if (IS_CLASS (_gst_sem_int_vec[sig].data, _gst_semaphore_class))
        _gst_async_call_internal (&_gst_sem_int_vec[sig]);
      else
	{
	  _gst_errorf
	    ("C signal trapped, but no semaphore was waiting");
	  raise (sig);
	}
    }

  _gst_set_signal_handler (sig, SIG_DFL);
  _gst_wakeup ();
}

void
_gst_async_interrupt_wait (OOP semaphoreOOP,
			   int sig)
{
  if (sig < 0 || sig >= NSIG)
    return;

  _gst_register_oop (semaphoreOOP);
  _gst_sem_int_vec[sig].func = _gst_do_async_signal_and_unregister;
  _gst_sem_int_vec[sig].data = semaphoreOOP;
  _gst_set_signal_handler (sig, signal_handler);

  /* should probably package up the old interrupt state here for return
     so that it can be undone */
}

