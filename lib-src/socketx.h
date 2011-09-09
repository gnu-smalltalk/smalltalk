/******************************** -*- C -*- ****************************
 *
 *      Common layer for BSD and Windows sockets
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003,2006,2007,2008,2009 Free Software Foundation, Inc.
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

#ifndef GST_SOCKETX_H
#define GST_SOCKETX_H

#include "config.h"

#ifdef HAVE_SOCKETS

#ifdef __MSVCRT__
#include <windows.h>
#include <winsock2.h>
#include <io.h>

#define is_socket_error(err)      (WSAGetLastError() == WSA##err)
#define clear_socket_error()      WSASetLastError(0)

#define ESHUTDOWN WSAESHUTDOWN
#define ENOTCONN WSAENOTCONN
#define ECONNRESET WSAECONNRESET
#define ECONNABORTED WSAECONNABORTED
#define ENETRESET WSAENETRESET

typedef int socklen_t;

/* re-define FD_ISSET to avoid a WSA call while we are not using 
 * network sockets */
#undef FD_ISSET
#define FD_ISSET(fd, set) win_fd_isset(fd, set)

static inline int
win_fd_isset (int fd, fd_set * set)
{
  int i;
  if (set == NULL)
    return 0;

  for (i = 0; i < set->fd_count; i++)
    if (set->fd_array[i] == fd)
      return 1;

  return 0;
}

#define FD_TO_SOCKET(fd)   ((SOCKET) _get_osfhandle ((fd)))
#define SOCKET_TO_FD(fh)   (_open_osfhandle ((long) (fh), O_RDWR | O_BINARY))

#undef close
#define close		   win_close

extern int win_close(int filehandle);

#else /* !__MSVCRT__ */

#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

#define is_socket_error(err)      (errno == (err))
#define clear_socket_error()      (errno = 0)

#define FD_TO_SOCKET(fd)	  (fd)
#define SOCKET_TO_FD(fd)	  (fd)
typedef int SOCKET;

#ifndef SOCKET_ERROR
#define SOCKET_ERROR		  (-1)
#endif

#ifndef O_NONBLOCK
#ifdef O_NDELAY
#define O_NONBLOCK O_NDELAY
#else
#ifdef FNDELAY
#define O_NONBLOCK FNDELAY
#endif
#endif
#endif

#endif /* !__MSVCRT__ */

#ifndef SHUT_RDWR
#define SHUT_RD		0
#define SHUT_WR		1
#define SHUT_RDWR	2
#endif

#include "getaddrinfo.h"

#endif /* HAVE_SOCKETS */

#endif /* GST_SOCKETX_H */
