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

#ifdef HAVE_SYS_TIMES_H
# include <sys/times.h>
#endif

void
_gst_sigvtalrm_every (int deltaMilli,
   		      SigHandler func)
{
#if defined ITIMER_VIRTUAL
  struct itimerval value;
  _gst_set_signal_handler (SIGVTALRM, func);

  value.it_value.tv_sec = value.it_value.tv_usec = 0;
  value.it_interval.tv_sec = deltaMilli / 1000;
  value.it_interval.tv_usec = (deltaMilli % 1000) * 1000;
  setitimer (ITIMER_VIRTUAL, &value, (struct itimerval *) 0);
#endif
}

#ifdef HAVE_TIMER_CREATE
static timer_t timer;
static mst_Boolean have_timer;
#endif

void
_gst_sigalrm_at (int64_t nsTime)
{
#ifdef HAVE_TIMER_CREATE
  if (have_timer)
    {
      struct itimerspec value;

      value.it_interval.tv_sec = value.it_interval.tv_nsec = 0;
      value.it_value.tv_sec = nsTime / 1000000000;
      value.it_value.tv_nsec = nsTime % 1000000000;
      timer_settime (timer, TIMER_ABSTIME, &value, NULL);
    }
  else
#endif
    {
      int64_t deltaMilli = (nsTime - _gst_get_ns_time()) / 1000000;
      struct itimerval value;

      value.it_interval.tv_sec = value.it_interval.tv_usec = 0;
      value.it_value.tv_sec = deltaMilli / 1000;
      value.it_value.tv_usec = (deltaMilli % 1000) * 1000;
      setitimer (ITIMER_REAL, &value, (struct itimerval *) 0);
    }
}

void
_gst_init_sysdep_timer (void)
{ 
#if defined HAVE_TIMER_CREATE && defined _POSIX_MONOTONIC_CLOCK
  struct sigevent sev;
  memset(&sev, 0, sizeof(sev));
  sev.sigev_notify = SIGEV_SIGNAL;
  sev.sigev_signo = SIGALRM;
  if (timer_create (CLOCK_MONOTONIC, &sev, &timer) != -1)
    have_timer = true;
#endif
}

