/******************************** -*- C -*- ****************************
 *
 *	Emulation for getdtablesize
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdio.h>

#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif 

#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif

#ifdef HAVE_GETRUSAGE
# include <sys/resource.h>
#endif

#ifndef HAVE_GETDTABLESIZE
int
getdtablesize(void)
{
#ifdef _SC_OPEN_MAX            /* POSIX -- preferred */
  int tableSize = sysconf(_SC_OPEN_MAX);
#else
  int tableSize = -1;
#endif

#ifdef RLIMIT_NOFILE           /* who is non POSIX but has this? */
  struct rlimit res;
  if (tableSize >= 0)
    return tableSize;

  if (getrlimit(RLIMIT_NOFILE, &rlimit) != -1)
    tableSize = rlimit.rlim_max;
#endif

  if (tableSize >= 0)
    return tableSize;

#ifdef OPEN_MAX
  return OPEN_MAX;
#else
#ifdef NOFILE
  return NOFILE;
#else
#ifdef FOPEN_MAX
  return FOPEN_MAX;
#else
  /* If something went wrong, choose a safe >>>hack<<< value */
  return sizeof(short) * 8;
#endif /* FOPEN_MAX */
#endif /* NOFILE */
#endif /* OPEN_MAX */
}
#endif

