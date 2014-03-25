/***********************************************************************
 *
 *	Netlink interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2014 Free Software Foundation, Inc.
 * Written by Holger Hans Peter Freyther.
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



#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <linux/netlink.h>
#include <linux/rtnetlink.h>

#include <netinet/in.h>
#include <sys/socket.h>

#include <string.h>
#include <unistd.h>

#include "gstpub.h"

#define NLMSG_TAIL(nmsg) \
        ((struct rtattr *) (((char*) (nmsg)) + NLMSG_ALIGN((nmsg)->nlmsg_len)))

static int
nl_route_source_ipv4(const char *dest, char *source)
{
  int fd, rc;
  struct rtmsg *r;
  struct rtattr *rta;
  struct {
    struct nlmsghdr         n;
    struct rtmsg            r;
    char                    buf[1024];
  } req;

  memset (&req, 0, sizeof (req));

  fd = socket (AF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_ROUTE);
  if (fd < 0)
    return -1;

   /* Send a rtmsg and ask for a response */
  req.n.nlmsg_len = NLMSG_LENGTH (sizeof (struct rtmsg));
  req.n.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
  req.n.nlmsg_type = RTM_GETROUTE;
  req.n.nlmsg_seq = 1;

  /* Prepare the routing request */
  req.r.rtm_family = AF_INET;

  /* set the dest */
  rta = NLMSG_TAIL (&req.n);
  rta->rta_type = RTA_DST;
  rta->rta_len = RTA_LENGTH (sizeof (struct in_addr));
  memcpy (RTA_DATA (rta), dest, sizeof (struct in_addr));

  /* update sizes for dest */
  req.r.rtm_dst_len = sizeof (struct in_addr) * 8;
  req.n.nlmsg_len = NLMSG_ALIGN (req.n.nlmsg_len) + RTA_ALIGN (rta->rta_len);

  rc = send(fd, &req, req.n.nlmsg_len, 0);
  if (rc != req.n.nlmsg_len)
    {
      close (fd);
      return -2;
    }

  /* now receive a response and parse it */
  rc = recv( fd, &req, sizeof(req), 0);
  if (rc <= 0)
    {
      close (fd);
      return -3;
    }

  if (!NLMSG_OK (&req.n, rc) || req.n.nlmsg_type != RTM_NEWROUTE)
    {
      close (fd);
      return -4;
    }

  r = NLMSG_DATA (&req.n);
  rc -= NLMSG_LENGTH (sizeof (*r));
  rta = RTM_RTA (r);
  while (RTA_OK (rta, rc))
    {
      if (rta->rta_type != RTA_PREFSRC)
        {
          rta = RTA_NEXT (rta, rc);
          continue;
        }

      /* Check if there are enough bytes */
      if (RTA_PAYLOAD (rta) != sizeof (struct in_addr))
        continue;

      /* we are done */
      memcpy(source, RTA_DATA (rta), RTA_PAYLOAD (rta));
      close (fd);
      return 0;
    }

  close (fd);
  return -5;
}


/* Module initialization function.  */

void
gst_initModule (VMProxy * proxy)
{
  proxy->defineCFunc ("nl_route_source_ipv4", nl_route_source_ipv4);
}
