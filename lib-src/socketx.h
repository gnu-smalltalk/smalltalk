/******************************** -*- C -*- ****************************
 *
 *      Common layer for BSD and Windows sockets
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003 Free Software Foundation, Inc.
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

#ifndef GST_SOCKETX_H
#define GST_SOCKETX_H

#ifdef HAVE_INET_SOCKETS

#ifdef __MSVCRT__
#include <winsock2.h>
#define is_socket_error(err)      (WSAGetLastError() == WSA##err)
#define clear_socket_error()      WSASetLastError(0)
#else /* !__MSVCRT__ */
#include <errno.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#define closesocket(x)            close(x)
#define is_socket_error(err)      (errno == (err))
#define clear_socket_error()      (errno = 0)
#endif /* !__MSVCRT__ */

#endif /* HAVE_INET_SOCKETS */

#endif /* GST_SOCKETX_H */
