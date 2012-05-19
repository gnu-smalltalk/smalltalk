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

#ifdef HAVE_UTIME_H
# include <utime.h>
#endif

#ifdef HAVE_SYS_TIMES_H
# include <sys/times.h>
#endif

#ifdef HAVE_SYS_TIMEB_H
#include <sys/timeb.h>
#endif

#define TM_YEAR_BASE 1900

/* Yield A - B, measured in seconds.
   This function is copied from the GNU C Library.  */
static int
tm_diff (struct tm *a,
	 struct tm *b)
{
  /* Compute intervening leap days correctly even if year is negative.
     Take care to avoid int overflow in leap day calculations, but it's 
     OK to assume that A and B are close to each other.  */
  int a4 = (a->tm_year >> 2) + (TM_YEAR_BASE >> 2) - !(a->tm_year & 3);
  int b4 = (b->tm_year >> 2) + (TM_YEAR_BASE >> 2) - !(b->tm_year & 3);
  int a100 = a4 / 25 - (a4 % 25 < 0);
  int b100 = b4 / 25 - (b4 % 25 < 0);
  int a400 = a100 >> 2;
  int b400 = b100 >> 2;
  int intervening_leap_days = (a4 - b4) - (a100 - b100) + (a400 - b400);
  int years = a->tm_year - b->tm_year;
  int days = (365 * years + intervening_leap_days
	      + (a->tm_yday - b->tm_yday));
  return (60 * (60 * (24 * days + (a->tm_hour - b->tm_hour))
		+ (a->tm_min - b->tm_min)) + (a->tm_sec - b->tm_sec));
}

time_t
_gst_adjust_time_zone (time_t t)
{
  struct tm save_tm, *decoded_time;
  time_t bias;

#ifdef LOCALTIME_CACHE
  tzset ();
#endif
  decoded_time = localtime (&t);
  save_tm = *decoded_time;
  decoded_time = gmtime (&t);
  bias = tm_diff (&save_tm, decoded_time);

  return (t + bias);
}

long
_gst_current_time_zone_bias (void)
{
  time_t now;
  long bias;
  struct tm save_tm, *decoded_time;

  time (&now);

#ifdef LOCALTIME_CACHE
  tzset ();
#endif

  decoded_time = localtime (&now);
  save_tm = *decoded_time;
  decoded_time = gmtime (&now);
  bias = tm_diff (&save_tm, decoded_time);
  return (bias);
}

time_t
_gst_get_time (void)
{
  time_t now;
  time (&now);

  return (_gst_adjust_time_zone (now));
}

uint64_t
_gst_get_milli_time (void)
{
  return _gst_get_ns_time() / 1000000;
}

