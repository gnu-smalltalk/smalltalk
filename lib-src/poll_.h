/******************************** -*- C -*- ****************************
 *
 *	Header for poll(2) emulation
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#ifndef GST_POLL_H
#define GST_POLL_H

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#ifdef poll
#define need_poll
#undef poll
#endif

#ifdef HAVE_POLL

/* use vendor poll(2) environment */
#include <sys/poll.h>

#else

/* fake a poll(2) environment */
#define POLLIN      0x0001	/* any readable data available   */
#define POLLPRI     0x0002	/* OOB/Urgent readable data      */
#define POLLOUT     0x0004	/* file descriptor is writeable  */
#define POLLERR     0x0008	/* some poll error occurred      */
#define POLLHUP     0x0010	/* file descriptor was "hung up" */
#define POLLNVAL    0x0020	/* requested events "invalid"    */
#define POLLRDNORM  0x0040
#define POLLRDBAND  0x0080
#define POLLWRNORM  0x0100
#define POLLWRBAND  0x0200
struct pollfd
{
  int fd;			/* which file descriptor to poll */
  short events;			/* events we are interested in   */
  short revents;		/* events found on return        */
};

#endif

#ifdef need_poll
#define poll rpl_poll
#undef need_poll
#endif

#ifndef INFTIM
#define INFTIM      (-1)	/* poll infinite */
#endif

#endif /* GST_POLL_H */
