/******************************** -*- C -*- ****************************
 *
 *	Emulation for getpagesize
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

#if defined _WIN32 || defined WIN32 || defined __WIN32__ || defined __CYGWIN__ || defined __CYGWIN32__ || defined __MSVCRT__
# define WIN32_LEAN_AND_MEAN
# include <windows.h>
#endif

#ifdef STDC_HEADERS
# include <string.h>
# include <stdlib.h>
#endif /* STDC_HEADERS */

#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif 

#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif

#ifndef HAVE_GETPAGESIZE
size_t
getpagesize(void)
{
#ifdef _SC_PAGE_SIZE
  return sysconf(_SC_PAGE_SIZE);
#else
#ifdef _SC_PAGESIZE
  return sysconf(_SC_PAGESIZE);
#else
#ifdef	PAGESIZE
  return PAGESIZE;
#else	/* no PAGESIZE */
#ifdef	EXEC_PAGESIZE
  return EXEC_PAGESIZE;
#else	/* no EXEC_PAGESIZE */
#ifdef	NBPG
#ifndef	CLSIZE
#define	CLSIZE 1
#endif	/* CLSIZE */
  return NBPG * CLSIZE;
#else	/* no NBPG */
#ifdef	NBPC
  return NBPC;
#else	/* no NBPC */
  return 1024 * sizeof (long);		/* Just punt and use reasonable value */
#endif /* no NBPC */
#endif /* no NBPG */
#endif /* no EXEC_PAGESIZE */
#endif /* no PAGESIZE */
#endif /* no _SC_PAGESIZE */
#endif /* no _SC_PAGE_SIZE */
}
#endif
