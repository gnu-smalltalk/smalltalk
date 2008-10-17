/******************************** -*- C -*- ****************************
 *
 *	Header for poll(2) emulation
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2006, 2008 Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
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

typedef int nfds_t;

#ifdef need_poll
#define poll rpl_poll
#undef need_poll
#endif

#ifndef INFTIM
#define INFTIM      (-1)	/* poll infinite */
#endif

#endif /* GST_POLL_H */
