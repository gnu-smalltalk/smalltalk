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

static long pending_sigs = 0;
static SigHandler saved_handlers[NSIG];

static RETSIGTYPE
dummy_signal_handler (int sig)
{
  pending_sigs |= 1L << sig;
  signal (sig, SIG_IGN);
}

int _gst_signal_count;

void
_gst_disable_interrupts (mst_Boolean from_signal_handler)
{
  __sync_synchronize ();
  if (_gst_signal_count++ == 0)
    {
      __sync_synchronize ();
      saved_handlers[SIGINT] = signal (SIGINT, dummy_signal_handler);
      saved_handlers[SIGBREAK] = signal (SIGBREAK, dummy_signal_handler);
      saved_handlers[SIGTERM] = signal (SIGTERM, dummy_signal_handler);
    }
}

void
_gst_enable_interrupts (mst_Boolean from_signal_handler)
{
  int i;
  long local_pending_sigs;

  __sync_synchronize ();
  if (--_gst_signal_count == 0)
    {
      __sync_synchronize ();
      signal (SIGINT, saved_handlers[SIGINT]);
      signal (SIGBREAK, saved_handlers[SIGBREAK]);
      signal (SIGTERM, saved_handlers[SIGTERM]);
      local_pending_sigs = pending_sigs;
      pending_sigs = 0;
      for (i = 0; local_pending_sigs; local_pending_sigs >>= 1, i++)
      	if (local_pending_sigs & 1)
	  raise (i);
    }
}

SigHandler
_gst_set_signal_handler (int signum,
			 SigHandler handlerFunc)
{
  return signal (signum, handlerFunc);
}
