/***********************************************************************
 *
 *      C interface to BSD sockets.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007,2008,2009
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

#include "gstpriv.h"

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

#ifdef HAVE_SYS_UTSNAME_H
#include <sys/utsname.h>
#endif

#ifdef HAVE_SOCKETS

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
constantFunction (afUnix, AF_UNIX);
constantFunction (pfUnspec, PF_UNSPEC);
constantFunction (pfInet, PF_INET);
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
constantFunction (ipprotoIcmp, IPPROTO_ICMP);
constantFunction (ipprotoUdp, IPPROTO_UDP);
constantFunction (ipprotoTcp, IPPROTO_TCP);
constantFunction (ipprotoIp, IPPROTO_IP);
constantFunction (tcpNodelay, TCP_NODELAY);

#ifdef HAVE_IPV6
constantFunction (afInet6, AF_INET6);
constantFunction (pfInet6, PF_INET6);
constantFunction (ipprotoIcmpv6, IPPROTO_ICMPV6);
#else
constantFunction (afInet6, -1);
constantFunction (pfInet6, -1);
constantFunction (ipprotoIcmpv6, -1);
#endif

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

/* Return 0 if the operation failed and an error can be returned
   by the caller.  */
static inline int
check_have_sock_cloexec (int fh, int expected_errno)
{
  if (have_sock_cloexec == 0 && (fh >= 0 || errno == expected_errno))
    have_sock_cloexec = (fh >= 0 ? 1 : -1);
  return (have_sock_cloexec != 0);
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
  int fd;

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

  fd = (fh == SOCKET_ERROR ? -1 : SOCKET_TO_FD (fh));
  if (fd != SOCKET_ERROR)
    _gst_register_socket (fd, false);
  return fd;
}


/* BSD systems have sa_len, others have not.  Smalltalk will always
   write sockaddr structs as if they had it.  So for Linux and Winsock
   we read the second byte (sa_family on BSD systems) and write it in the
   entire sa_family field. */
static inline void
fix_sockaddr (struct sockaddr *sockaddr, socklen_t len)
{
#ifndef HAVE_STRUCT_SOCKADDR_SA_LEN
  /* Make sure sa_family is a short.  */
  char verify[sizeof (sockaddr->sa_family) == 2 ? 1 : -1];

  if (len >= 2)
    sockaddr->sa_family = ((unsigned char *) sockaddr)[1];
#endif
}

/* Same as connect, but forces the socket to be in non-blocking mode */
static int
myConnect (int fd, struct sockaddr *sockaddr, int len)
{
  SOCKET sock = FD_TO_SOCKET (fd);
  int rc;

#ifdef __MSVCRT__
  unsigned long iMode = 1;
  ioctlsocket (sock, FIONBIO, &iMode);

#elif defined F_GETFL
#ifndef O_NONBLOCK             
#warning Non-blocking I/O could not be enabled
#else
  int oldflags = fcntl (sock, F_GETFL, NULL);
  if (!(oldflags & O_NONBLOCK))
    fcntl (sock, F_SETFL, oldflags | O_NONBLOCK);
#endif
#endif
  
  fix_sockaddr (sockaddr, len);
  rc = connect (sock, sockaddr, len);
  if (rc == 0 || is_socket_error (EINPROGRESS) || is_socket_error (EWOULDBLOCK))
    return 0;
  else
    return -1;
}

static int
myAccept (int fd, struct sockaddr *addr, socklen_t *addrlen)
{
  SOCKET fh = SOCKET_ERROR;
  int new_fd;

  /* Parameters to system calls are not guaranteed to generate a SIGSEGV
     and for this reason we must touch them manually.  */
  _gst_grey_oop_range (addr, *addrlen);

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

  new_fd = (fh == SOCKET_ERROR ? -1 : SOCKET_TO_FD (fh));
  if (new_fd != SOCKET_ERROR)
    _gst_register_socket (new_fd, false);
  return new_fd;
}

static int
myBind (int fd, struct sockaddr *addr, socklen_t addrlen)
{
  fix_sockaddr (addr, addrlen);
  return bind (FD_TO_SOCKET (fd), addr, addrlen);
}

static int
myGetpeername (int fd, struct sockaddr *addr, socklen_t *addrlen)
{
  /* Parameters to system calls are not guaranteed to generate a SIGSEGV
     and for this reason we must touch them manually.  */
  _gst_grey_oop_range (addr, *addrlen);

  return getpeername (FD_TO_SOCKET (fd), addr, addrlen);
}

static int
myGetsockname (int fd, struct sockaddr *addr, socklen_t *addrlen)
{
  /* Parameters to system calls are not guaranteed to generate a SIGSEGV
     and for this reason we must touch them manually.  */
  _gst_grey_oop_range (addr, *addrlen);

  return getsockname (FD_TO_SOCKET (fd), addr, addrlen);
}

static int
myGetsockopt (int fd, int level, int optname, char *optval, socklen_t *optlen)
{
  /* Parameters to system calls are not guaranteed to generate a SIGSEGV
     and for this reason we must touch them manually.  */
  _gst_grey_oop_range (optval, *optlen);

  return getsockopt (FD_TO_SOCKET (fd), level, optname, optval, optlen);
}

static int
myListen (int fd, int backlog)
{
  int r = listen (FD_TO_SOCKET (fd), backlog);
  if (r != SOCKET_ERROR)
    _gst_register_socket (fd, true);
  return r;
}

static int
myRecvfrom (int fd, char *buf, int len, int flags, struct sockaddr *from,
	    socklen_t *fromlen)
{
  int frombufsize = *fromlen;
  int r;

  /* Parameters to system calls are not guaranteed to generate a SIGSEGV
     and for this reason we must touch them manually.  */
  _gst_grey_oop_range (buf, len);
  _gst_grey_oop_range (from, *fromlen);

  r = recvfrom (FD_TO_SOCKET (fd), buf, len, flags, from, fromlen);

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
  fix_sockaddr (to, tolen);
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
  socklen_t size = sizeof (error);
  if ((error = _gst_get_fd_error (fd)) != 0)
    ;

  else if (myGetsockopt (fd, SOL_SOCKET, SO_ERROR, (char *)&error, &size) == -1)
    {
#if defined _WIN32 && !defined __CYGWIN__
      error = WSAGetLastError ();
#else
      error = errno;
#endif
    }

  /* When we get one of these, we don't return an error.  However,
     the primitive still fails and the file/socket is closed by the
     Smalltalk code.  */
  if (error == ESHUTDOWN || error == ECONNRESET
      || error == ECONNABORTED || error == ENETRESET
      || error == EPIPE)
    return 0;
  else
    return error;
}


void
_gst_init_sockets ()
{
#if defined WIN32 && !defined __CYGWIN__
  WSADATA wsaData;
  int iRet;
  iRet = WSAStartup(MAKEWORD(2,2), &wsaData);
  if (iRet != 0) {
    printf("WSAStartup failed (looking for Winsock 2.2): %d\n", iRet);
    return;
  }
#endif /* _WIN32 */

  _gst_define_cfunc ("TCPgetaddrinfo", getaddrinfo);
  _gst_define_cfunc ("TCPfreeaddrinfo", freeaddrinfo);
  _gst_define_cfunc ("TCPgetHostByAddr", myGetHostByAddr);
  _gst_define_cfunc ("TCPgetLocalName", myGetHostName);
  _gst_define_cfunc ("TCPgetAiCanonname", get_aiCanonname);
  _gst_define_cfunc ("TCPgetAiAddr", get_aiAddr);

  _gst_define_cfunc ("TCPaccept", myAccept);
  _gst_define_cfunc ("TCPbind", myBind);
  _gst_define_cfunc ("TCPconnect", myConnect);
  _gst_define_cfunc ("TCPgetpeername", myGetpeername);
  _gst_define_cfunc ("TCPgetsockname", myGetsockname);
  _gst_define_cfunc ("TCPlisten", myListen);
  _gst_define_cfunc ("TCPrecvfrom", myRecvfrom);
  _gst_define_cfunc ("TCPsendto", mySendto);
  _gst_define_cfunc ("TCPsetsockopt", mySetsockopt);
  _gst_define_cfunc ("TCPgetsockopt", myGetsockopt);
  _gst_define_cfunc ("TCPgetSoError", getSoError);
  _gst_define_cfunc ("TCPsocket", mySocket);

  _gst_define_cfunc ("TCPpfUnspec", pfUnspec);
  _gst_define_cfunc ("TCPpfInet", pfInet);
  _gst_define_cfunc ("TCPpfInet6", pfInet6);
  _gst_define_cfunc ("TCPpfUnix", pfUnix);
  _gst_define_cfunc ("TCPafUnspec", afUnspec);
  _gst_define_cfunc ("TCPafInet", afInet);
  _gst_define_cfunc ("TCPafInet6", afInet6);
  _gst_define_cfunc ("TCPafUnix", afUnix);
  _gst_define_cfunc ("TCPipMulticastTtl", ipMulticastTtl);
  _gst_define_cfunc ("TCPipMulticastIf", ipMulticastIf);
  _gst_define_cfunc ("TCPipAddMembership", ipAddMembership);
  _gst_define_cfunc ("TCPipDropMembership", ipDropMembership);
  _gst_define_cfunc ("TCPtcpNodelay", tcpNodelay);
  _gst_define_cfunc ("TCPmsgPeek", msgPeek);
  _gst_define_cfunc ("TCPmsgOOB", msgOOB);
  _gst_define_cfunc ("TCPsolSocket", solSocket);
  _gst_define_cfunc ("TCPsoLinger", soLinger);
  _gst_define_cfunc ("TCPsoReuseAddr", soReuseAddr);
  _gst_define_cfunc ("TCPsockStream", sockStream);
  _gst_define_cfunc ("TCPsockRaw", sockRaw);
  _gst_define_cfunc ("TCPsockRDM", sockRDM);
  _gst_define_cfunc ("TCPsockDgram", sockDgram);
  _gst_define_cfunc ("TCPipprotoIp", ipprotoIp);
  _gst_define_cfunc ("TCPipprotoTcp", ipprotoTcp);
  _gst_define_cfunc ("TCPipprotoUdp", ipprotoUdp);
  _gst_define_cfunc ("TCPipprotoIcmp", ipprotoIcmp);
  _gst_define_cfunc ("TCPipprotoIcmpv6", ipprotoIcmpv6);
  _gst_define_cfunc ("TCPaiAddrconfig", aiAddrconfig);
  _gst_define_cfunc ("TCPaiCanonname", aiCanonname);
  _gst_define_cfunc ("TCPaiAll", aiAll);
  _gst_define_cfunc ("TCPaiV4mapped", aiV4mapped);
}

#else /* !HAVE_SOCKETS */

void
_gst_init_sockets ()
{
}
#endif
