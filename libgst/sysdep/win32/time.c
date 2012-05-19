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

#ifdef HAVE_SYS_TIMEB_H
#include <sys/timeb.h>
#endif

#ifdef WIN32
# define WIN32_LEAN_AND_MEAN /* avoid including junk */
# include <windows.h>
#endif

static inline uint64_t muldiv64(uint64_t a, uint32_t b, uint32_t c)
{
  uint64_t tl = (a & 0xffffffff) * b;
  uint64_t th = (a >> 32) * b + (tl >> 32);
  uint64_t rem = ((th % c) << 32) + (tl & 0xffffffff);
  return ((uint64_t) (th / c) << 32) | (rem / c);
}

uint64_t
_gst_get_ns_time (void)
{
  static long frequency = 0;
  LARGE_INTEGER counter;

  if (!frequency)
    {
      QueryPerformanceFrequency (&counter);
      frequency = counter.LowPart;
    }

  QueryPerformanceCounter (&counter);
  return muldiv64(counter.QuadPart, 1000000000, frequency);
}

char *
_gst_current_time_zone_name (void)
{
  char *zone;
  long bias = _gst_current_time_zone_bias () / 60;
  TIME_ZONE_INFORMATION tzi;
  LPCWSTR name;
  static char buffer[32];
  GetTimeZoneInformation (&tzi);
  zone = buffer;
  name = (bias == (tzi.Bias + tzi.StandardBias))
  	  ? tzi.StandardName : tzi.DaylightName;

  WideCharToMultiByte (CP_ACP, 0, name, lstrlenW (name), zone, 32, NULL, NULL);
  return xstrdup (zone);
}

void
_gst_usleep (int us)
{
  Sleep (us / 1000);
}
