/***********************************************************************
 *
 *      C interface to BSD sockets.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007,2008
 * Free Software Foundation, Inc.
 * Written by Steve Byrne and Paolo Bonzini.
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

#include "config.h"
#include "gstpub.h"

#include <signal.h>
#include <fcntl.h>
#include <errno.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#if __STDC__
#include <string.h>
#include <stdlib.h>
#endif /* STDC_HEADERS */

#include <stdio.h>
#include <errno.h>
#include "socketx.h"

#ifndef HAVE_SOCKETS
#error Sockets not available.
#endif

#ifdef HAVE_SYS_UTSNAME_H
#include <sys/utsname.h>
#endif

#ifndef O_NONBLOCK             
#ifdef O_NDELAY
#define O_NONBLOCK O_NDELAY
#else
#ifdef FNDELAY
#define O_NONBLOCK FNDELAY
#else
#warning Non-blocking I/O could not be enabled
#define O_NONBLOCK 0
#endif
#endif
#endif

#ifndef ntohl
#if WORDS_BIGENDIAN
#define ntohl(x) (x)
#define ntohs(x) (x)
#else
#define ntohl(x) \
        ((unsigned long int)((((unsigned long int)(x) & 0x000000ffU) << 24) | \
                             (((unsigned long int)(x) & 0x0000ff00U) <<  8) | \
                             (((unsigned long int)(x) & 0x00ff0000U) >>  8) | \
                             (((unsigned long int)(x) & 0xff000000U) >> 24)))

#define ntohs(x) \
        ((unsigned short int)((((unsigned short int)(x) & 0x00ff) << 8) | \
                              (((unsigned short int)(x) & 0xff00) >> 8)))
#endif
#endif /* ntohl */



static VMProxy *vmProxy;



static char *
myGetHostByAddr (char *addr, int len, int type)
{
  struct hostent *hostEnt;
  char *result;

#if HAVE_GETIPNODEBYADDR
  int error;
  hostEnt = getipnodebyaddr (addr, len, type, &error);
#else
  hostEnt = gethostbyaddr (addr, len, type);
#endif

  if (hostEnt)
    {
      result = malloc (128);	/* out of a hat */
      strncpy (result, hostEnt->h_name, 128);
#if HAVE_GETIPNODEBYADDR
      freehostent (hostEnt);
#endif
    }
  else
    result = NULL;
  
  return (result);
}

/* The offsets of these two fields are not portable.  */

static char **
get_aiCanonname (struct addrinfo *ai)
{
  return &ai->ai_canonname;
}

static struct sockaddr **
get_aiAddr (struct addrinfo *ai)
{
  return &ai->ai_addr;
}

static char *
myGetHostName (void)
{
  char *result;

  result = malloc (128);
#ifdef HAVE_UNAME
  {
    struct utsname utsname;
    int ret;

    ret = uname (&utsname);
    if (ret < 0)
      return NULL;

    strncpy (result, utsname.nodename, 128);
    result[127] = '\0';
  }
#else
#ifdef HAVE_GETHOSTNAME
  {
    extern int gethostname ();
    gethostname (result, 128);
  }
#else
  strcpy (result, "localhost");	/* terrible guess */
#endif
#endif
  return (result);
}

#define constantFunction(name, constant) \
  static long name(void) { return (constant); }

constantFunction (afUnspec, AF_UNSPEC);
constantFunction (afInet, AF_INET);
constantFunction (afInet6, AF_INET6);
constantFunction (afUnix, AF_UNIX);
constantFunction (pfUnspec, PF_UNSPEC);
constantFunction (pfInet, PF_INET);
constantFunction (pfInet6, PF_INET6);
constantFunction (pfUnix, PF_UNIX);
constantFunction (msgOOB, MSG_OOB);
constantFunction (msgPeek, MSG_PEEK);
constantFunction (solSocket, SOL_SOCKET);
constantFunction (soLinger, SO_LINGER);
constantFunction (soReuseAddr, SO_REUSEADDR);
constantFunction (sockStream, SOCK_STREAM);
constantFunction (sockRaw, SOCK_RAW);
constantFunction (sockRDM, SOCK_RDM);
constantFunction (sockDgram, SOCK_DGRAM);
constantFunction (ipprotoIcmpv6, IPPROTO_ICMPV6);
constantFunction (ipprotoIcmp, IPPROTO_ICMP);
constantFunction (ipprotoUdp, IPPROTO_UDP);
constantFunction (ipprotoTcp, IPPROTO_TCP);
constantFunction (ipprotoIp, IPPROTO_IP);
constantFunction (tcpNodelay, TCP_NODELAY);

#ifdef IP_MULTICAST_TTL
constantFunction (ipMulticastTtl, IP_MULTICAST_TTL);
constantFunction (ipMulticastIf, IP_MULTICAST_IF);
constantFunction (ipAddMembership, IP_ADD_MEMBERSHIP);
constantFunction (ipDropMembership, IP_DROP_MEMBERSHIP);
#else
constantFunction (ipMulticastTtl, -1);
constantFunction (ipMulticastIf, -1);
constantFunction (ipAddMembership, -1);
constantFunction (ipDropMembership, -1);
#endif

#ifndef AI_ADDRCONFIG
#define AI_ADDRCONFIG	0
#endif

#ifndef AI_ALL
#define AI_ALL	0
#endif

#ifndef AI_V4MAPPED
#define AI_V4MAPPED	0
#endif

constantFunction (aiAddrconfig, AI_ADDRCONFIG)
constantFunction (aiCanonname, AI_CANONNAME)
constantFunction (aiAll, AI_ALL)
constantFunction (aiV4mapped, AI_V4MAPPED)



#if defined SOCK_CLOEXEC && !defined __MSVCRT__
/* 0 = unknown, 1 = yes, -1 = no.  */
static mst_Boolean have_sock_cloexec;

static inline int
check_have_sock_cloexec (int fh, int expected_errno)
{
  if (have_sock_cloexec == 0 && (fh >= 0 || errno == expected_errno))
    have_sock_cloexec = (fh >= 0 ? 1 : -1);
  return (have_sock_cloexec == 1);
}
#endif

static void
socket_set_cloexec (SOCKET fh)
{
  if (fh == SOCKET_ERROR)
    return;

#if defined __MSVCRT__
  /* Do not do FD_CLOEXEC under MinGW.  */
  SetHandleInformation ((HANDLE) fh, HANDLE_FLAG_INHERIT, 0);
#else
  fcntl (fh, F_SETFD, fcntl (fh, F_GETFD, 0) | FD_CLOEXEC);
#endif
}

static int
mySocket (int domain, int type, int protocol)
{
  SOCKET fh = SOCKET_ERROR;

#if defined SOCK_CLOEXEC && !defined __MSVCRT__
  if (have_sock_cloexec >= 0)
    {
      fh = socket (domain, type | SOCK_CLOEXEC, protocol);
      if (!check_have_sock_cloexec (fh, EINVAL))
	return -1;
    }
#endif
  if (fh == SOCKET_ERROR)
    {
      fh = socket (domain, type, protocol);
      socket_set_cloexec (fh);
    }

  return fh == SOCKET_ERROR ? -1 : SOCKET_TO_FD (fh);
}


/* BSD systems have sa_len, others have not.  Smalltalk will always
   write sockaddr structs as if they had it.  So for Linux and Winsock
   we read the second byte (sa_family on BSD systems) and write it in the
   entire sa_family field. */
static inline void
fix_sockaddr (struct sockaddr *sockaddr)
{
#ifndef HAVE_STRUCT_SOCKADDR_SA_LEN
  /* Make sure sa_family is a short.  */
  char verify[sizeof (sockaddr->sa_family) == 2 ? 1 : -1];

  sockaddr->sa_family = ((unsigned char *) sockaddr)[1];
#endif
}

/* Same as connect, but forces the socket to be in non-blocking mode */
static void
myConnect (int fd, struct sockaddr *sockaddr, int len)
{
  SOCKET sock = FD_TO_SOCKET (fd);
#ifdef __MSVCRT__
  unsigned long iMode = 1;
  ioctlsocket (sock, FIONBIO, &iMode);

#elif defined F_GETFL
  int oldflags = fcntl (sock, F_GETFL, NULL);

  if (!(oldflags & O_NONBLOCK))
    fcntl (sock, F_SETFL, oldflags | O_NONBLOCK);
#endif
  
  fix_sockaddr (sockaddr);
  connect (sock, sockaddr, len);
  if (is_socket_error (EINPROGRESS) || is_socket_error (EWOULDBLOCK))
    errno = 0;
}

static int
myAccept (int fd, struct sockaddr *addr, int *addrlen)
{
  SOCKET fh = SOCKET_ERROR;
#if defined SOCK_CLOEXEC && defined HAVE_ACCEPT4 && !defined __MSVCRT__
  if (have_sock_cloexec >= 0)
    {
      fh = accept4 (FD_TO_SOCKET (fd), addr, addrlen, SOCK_CLOEXEC);
      if (!check_have_sock_cloexec (fh, ENOSYS))
	return -1;
    }
#endif
  if (fh == SOCKET_ERROR)
    {
      fh = accept (FD_TO_SOCKET (fd), addr, addrlen);
      socket_set_cloexec (fh);
    }

  return fh == SOCKET_ERROR ? -1 : SOCKET_TO_FD (fh);
}

static int
myBind (int fd, struct sockaddr *addr, int addrlen)
{
  fix_sockaddr (addr);
  return bind (FD_TO_SOCKET (fd), addr, addrlen);
}

static int
myGetpeername (int fd, struct sockaddr *addr, int *addrlen)
{
  return getpeername (FD_TO_SOCKET (fd), addr, addrlen);
}

static int
myGetsockname (int fd, struct sockaddr *addr, int *addrlen)
{
  return getsockname (FD_TO_SOCKET (fd), addr, addrlen);
}

static int
myGetsockopt (int fd, int level, int optname, char *optval, int *optlen)
{
  return getsockopt (FD_TO_SOCKET (fd), level, optname, optval, optlen);
}

static int
myListen (int fd, int backlog)
{
  return listen (FD_TO_SOCKET (fd), backlog);
}

static int
myRecvfrom (int fd, char *buf, int len, int flags, struct sockaddr *from,
	    int *fromlen)
{
  int frombufsize = *fromlen;
  int r = recvfrom (FD_TO_SOCKET (fd), buf, len, flags, from, fromlen);

  /* Winsock recvfrom() only returns a valid 'from' when the socket is
     connectionless.  POSIX gives a valid 'from' for all types of sockets.  */
  if (r != SOCKET_ERROR && frombufsize == *fromlen)
    (void) myGetpeername (fd, from, fromlen);

  return r;
}

static int
mySendto (int fd, const char *buf, int len, int flags,
	  struct sockaddr *to, int tolen)
{
  fix_sockaddr (to);
  return sendto (FD_TO_SOCKET (fd), buf, len, flags, to, tolen);
}

static int
mySetsockopt (int fd, int level, int optname, const char *optval, int optlen)
{
  return setsockopt (FD_TO_SOCKET (fd), level, optname, optval, optlen);
}

static int
getSoError (int fd)
{
  int error;
  int size = sizeof (error);
  if (myGetsockopt (fd, SOL_SOCKET, SO_ERROR, (char *)&error, &size) == -1)
    {
#ifdef _WIN32
      error = WSAGetLastError ();
#else
      error = errno;
#endif
    }

  else
    {
      /* When we get one of these, we don't return an error.  However,
         the primitive still fails and the file/socket is closed by the
         Smalltalk code.  */
      if (error == ESHUTDOWN || error == ECONNRESET
	  || error == ECONNABORTED || error == ENETRESET
	  || error == EPIPE)
	return 0;
    }

  return error;
}


void
gst_initModule (VMProxy * proxy)
{
#ifdef _WIN32
  WSADATA wsaData;
  int iRet;
  iRet = WSAStartup(MAKEWORD(2,2), &wsaData);
  if (iRet != 0) {
    printf("WSAStartup failed (looking for Winsock 2.2): %d\n", iRet);
    return;
  }
#endif /* _WIN32 */

  vmProxy = proxy;
  vmProxy->defineCFunc ("TCPgetaddrinfo", getaddrinfo);
  vmProxy->defineCFunc ("TCPfreeaddrinfo", freeaddrinfo);
  vmProxy->defineCFunc ("TCPgetHostByAddr", myGetHostByAddr);
  vmProxy->defineCFunc ("TCPgetLocalName", myGetHostName);
  vmProxy->defineCFunc ("TCPgetAiCanonname", get_aiCanonname);
  vmProxy->defineCFunc ("TCPgetAiAddr", get_aiAddr);

  vmProxy->defineCFunc ("TCPaccept", myAccept);
  vmProxy->defineCFunc ("TCPbind", myBind);
  vmProxy->defineCFunc ("TCPconnect", myConnect);
  vmProxy->defineCFunc ("TCPgetpeername", myGetpeername);
  vmProxy->defineCFunc ("TCPgetsockname", myGetsockname);
  vmProxy->defineCFunc ("TCPlisten", myListen);
  vmProxy->defineCFunc ("TCPrecvfrom", myRecvfrom);
  vmProxy->defineCFunc ("TCPsendto", mySendto);
  vmProxy->defineCFunc ("TCPsetsockopt", mySetsockopt);
  vmProxy->defineCFunc ("TCPgetsockopt", myGetsockopt);
  vmProxy->defineCFunc ("TCPgetSoError", getSoError);
  vmProxy->defineCFunc ("TCPsocket", mySocket);

  vmProxy->defineCFunc ("TCPpfUnspec", pfUnspec);
  vmProxy->defineCFunc ("TCPpfInet", pfInet);
  vmProxy->defineCFunc ("TCPpfInet6", pfInet6);
  vmProxy->defineCFunc ("TCPpfUnix", pfUnix);
  vmProxy->defineCFunc ("TCPafUnspec", afUnspec);
  vmProxy->defineCFunc ("TCPafInet", afInet);
  vmProxy->defineCFunc ("TCPafInet6", afInet6);
  vmProxy->defineCFunc ("TCPafUnix", afUnix);
  vmProxy->defineCFunc ("TCPipMulticastTtl", ipMulticastTtl);
  vmProxy->defineCFunc ("TCPipMulticastIf", ipMulticastIf);
  vmProxy->defineCFunc ("TCPipAddMembership", ipAddMembership);
  vmProxy->defineCFunc ("TCPipDropMembership", ipDropMembership);
  vmProxy->defineCFunc ("TCPtcpNodelay", tcpNodelay);
  vmProxy->defineCFunc ("TCPmsgPeek", msgPeek);
  vmProxy->defineCFunc ("TCPmsgOOB", msgOOB);
  vmProxy->defineCFunc ("TCPsolSocket", solSocket);
  vmProxy->defineCFunc ("TCPsoLinger", soLinger);
  vmProxy->defineCFunc ("TCPsoReuseAddr", soReuseAddr);
  vmProxy->defineCFunc ("TCPsockStream", sockStream);
  vmProxy->defineCFunc ("TCPsockRaw", sockRaw);
  vmProxy->defineCFunc ("TCPsockRDM", sockRDM);
  vmProxy->defineCFunc ("TCPsockDgram", sockDgram);
  vmProxy->defineCFunc ("TCPipprotoIp", ipprotoIp);
  vmProxy->defineCFunc ("TCPipprotoTcp", ipprotoTcp);
  vmProxy->defineCFunc ("TCPipprotoUdp", ipprotoUdp);
  vmProxy->defineCFunc ("TCPipprotoIcmp", ipprotoIcmp);
  vmProxy->defineCFunc ("TCPipprotoIcmpv6", ipprotoIcmpv6);
  vmProxy->defineCFunc ("TCPaiAddrconfig", aiAddrconfig);
  vmProxy->defineCFunc ("TCPaiCanonname", aiCanonname);
  vmProxy->defineCFunc ("TCPaiAll", aiAll);
  vmProxy->defineCFunc ("TCPaiV4mapped", aiV4mapped);
}
