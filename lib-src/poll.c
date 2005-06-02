/******************************** -*- C -*- ****************************
 *
 *	poll(2) emulation
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2003 Free Software Foundation, Inc.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/

#include "config.h"
#include "poll.h"
#include <sys/types.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>
#include <errno.h>

int
rpl_poll (struct pollfd *pfd, int nfd, int timeout)
{
  fd_set rfds, wfds, efds;
  struct timeval tv, *ptv;
  int maxfd, rc, ok;
  unsigned int i;
  char data[64];

  /* poll(2) semantics */
  if (pfd == NULL)
    {
      errno = EFAULT;
      return -1;
    }

  /* convert timeout number into a timeval structure */
  ptv = &tv;
  if (timeout == 0)
    {
      /* return immediately */
      ptv->tv_sec = 0;
      ptv->tv_usec = 0;
    }
  else if (timeout == INFTIM /* (-1) */ )
    {
      /* wait forever */
      ptv = NULL;
    }
  else if (timeout > 0)
    {
      /* return after timeout */
      ptv->tv_sec = timeout / 1000;
      ptv->tv_usec = (timeout % 1000) * 1000;
    }
  else
    {
      errno = EINVAL;
      return -1;
    }

  /* create fd sets and determine max fd */
  maxfd = -1;
  FD_ZERO (&rfds);
  FD_ZERO (&wfds);
  FD_ZERO (&efds);
  for (i = 0; i < nfd; i++)
    {
      if (pfd[i].fd < 0)
	continue;

      if (pfd[i].events & (POLLIN | POLLRDNORM))
	FD_SET (pfd[i].fd, &rfds);

      /* see select(2): "the only exceptional condition detectable
         is out-of-band data received on a socket", hence we push
         POLLWRBAND events onto wfds instead of efds. */
      if (pfd[i].events & (POLLOUT | POLLWRNORM | POLLWRBAND))
	FD_SET (pfd[i].fd, &wfds);
      if (pfd[i].events & (POLLPRI | POLLRDBAND))
	FD_SET (pfd[i].fd, &efds);
      if (pfd[i].fd >= maxfd &&
	  (pfd[i].events & (POLLIN | POLLOUT | POLLPRI |
			    POLLRDNORM | POLLRDBAND |
			    POLLWRNORM | POLLWRBAND)))
	maxfd = pfd[i].fd;
    }
  if (maxfd == -1)
    {
      errno = EINVAL;
      return -1;
    }

  /* examine fd sets */
  rc = select (maxfd + 1, &rfds, &wfds, &efds, ptv);

  /* establish results */
  if (rc > 0)
    {
      rc = 0;
      for (i = 0; i < nfd; i++)
	{
	  ok = 0;
	  pfd[i].revents = 0;
	  if (pfd[i].fd < 0)
	    {
	      pfd[i].revents |= POLLNVAL;
	      continue;
	    }
	  if (FD_ISSET (pfd[i].fd, &rfds))
	    {
	      /* support for POLLHUP */
	      int save_errno = errno;
	      if ((recv (pfd[i].fd, data, 64, MSG_PEEK) == -1)
		  && (errno == ESHUTDOWN || errno == ECONNRESET ||
		      errno == ECONNABORTED || errno == ENETRESET))
		pfd[i].revents |= POLLHUP;
	      else
		{
		  pfd[i].revents |= pfd[i].events & (POLLIN | POLLRDNORM);
		  ok++;
		}

	      errno = save_errno;
	    }
	  if (FD_ISSET (pfd[i].fd, &wfds))
	    {
	      pfd[i].revents |=
		pfd[i].events & (POLLOUT | POLLWRNORM | POLLWRBAND);
	      ok++;
	    }
	  if (FD_ISSET (pfd[i].fd, &efds))
	    {
	      pfd[i].revents |= pfd[i].events & (POLLPRI | POLLRDBAND);
	      ok++;
	    }
	  if (ok)
	    rc++;
	}
    }

  return rc;
}
