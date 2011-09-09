/*
 * Copyright (C) 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008,
 * 2009, 2010  Free Software Foundation, Inc.
 *
 * Based on the gnutls-cli.c file distributed with GnuTLS.
 *
 * GNU Smalltalk is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include "socketx.h"

#if defined HAVE_GNUTLS && (defined O_NONBLOCK || defined FIONBIO)
#include <gnutls/gnutls.h>

#define MAX_BUF 4096

/* Returns zero if the error code was successfully handled.
 */
static int
handle_error (gnutls_session_t session, int err)
{
  if (err == GNUTLS_E_REHANDSHAKE)
    gnutls_alert_send (session, GNUTLS_AL_WARNING, GNUTLS_A_NO_RENEGOTIATION);

  if (err < 0 && gnutls_error_is_fatal (err))
    return err;
  else
    return 0;
}

static int
do_handshake (gnutls_session_t session)
{
  int ret;

  do
    {
      ret = gnutls_handshake (session);
      if (ret < 0)
        handle_error (session, ret);
    }
  while (ret < 0 && gnutls_error_is_fatal (ret) == 0);

  if (ret != 0)
    gnutls_alert_send_appropriate (session, ret);

  return ret;
}

static int
socket_open (const char *hostname, const char *service)
{
  struct addrinfo hints, *res, *ptr;
  int fd, err;

  /* get server name */
  memset (&hints, 0, sizeof (hints));
  hints.ai_socktype = SOCK_STREAM;
  if (getaddrinfo (hostname, service, &hints, &res) != 0)
    exit (1);

  fd = -1;
  for (ptr = res; ptr != NULL; ptr = ptr->ai_next)
    {
      fd = socket (ptr->ai_family, ptr->ai_socktype, ptr->ai_protocol);
      if (fd != -1)
	break;
    }

  if (fd == -1)
    exit (1);

  err = connect (fd, ptr->ai_addr, ptr->ai_addrlen);
  if (err < 0)
    exit (1);

  freeaddrinfo (res);
  return fd;
}

static void
sockets_init ()
{
#if defined WIN32 && !defined __CYGWIN__
  WSADATA wsaData;
  int iRet;
  iRet = WSAStartup (MAKEWORD(2,2), &wsaData);
  if (iRet != 0)
    exit (1);
#endif /* _WIN32 */
}

int
main (int argc, char **argv)
{
  int err, ret, fd;
  char buffer[MAX_BUF + 1];
  fd_set rset;
  int user_term = 0, retval = 0;
  ssize_t bytes;

  const char *hostname;
  const char *service;

  gnutls_session_t session;
  gnutls_anon_client_credentials_t anon_cred;
  gnutls_certificate_credentials_t xcred;

  if (gnutls_global_init () < 0)
    exit (1);

  if (argc < 3)
    {
      fprintf (stderr, "No hostname or port given\n");
      exit (1);
    }

  hostname = argv[1];
  service = argv[2];

#ifdef _WIN32
  sockets_init ();
#endif

#ifndef _WIN32
  signal (SIGPIPE, SIG_IGN);
#endif

  sockets_init ();
  gnutls_init (&session, GNUTLS_CLIENT);
  gnutls_set_default_priority (session);

  gnutls_anon_allocate_client_credentials (&anon_cred);
  gnutls_credentials_set (session, GNUTLS_CRD_ANON, anon_cred);

  gnutls_certificate_allocate_credentials (&xcred);
  gnutls_credentials_set (session, GNUTLS_CRD_CERTIFICATE, xcred);

  fd = socket_open (hostname, service);
  gnutls_transport_set_ptr (session, (gnutls_transport_ptr_t) (long) fd);

  ret = do_handshake (session);

  if (ret < 0)
    {
      gnutls_perror (ret);
      retval = 1;
      goto out;
    }

  fflush (stdout);
  fflush (stderr);

  {
#ifdef __MSVCRT__
    unsigned long iMode = 1;
    ioctlsocket (fd, FIONBIO, &iMode);
#else
    int oldflags = fcntl (fd, F_GETFL, NULL);
    fcntl (fd, F_SETFL, oldflags | O_NONBLOCK);
#endif
  }

  for (;;)
    {
      FD_ZERO (&rset);
      FD_SET (STDIN_FILENO, &rset);
      FD_SET (fd, &rset);

      err = select (fd + 1, &rset, NULL, NULL, NULL);
      if (err < 0)
	continue;

      if (FD_ISSET (fd, &rset))
	{
	  memset (buffer, 0, MAX_BUF + 1);
          do
            ret = gnutls_record_recv (session, buffer, MAX_BUF);
          while (ret == GNUTLS_E_INTERRUPTED || ret == GNUTLS_E_AGAIN);

	  if (ret == 0)
            break;

	  if (handle_error (session, ret) < 0)
	    {
	      retval = 1;
	      break;
	    }

	  if (ret > 0)
	    {
              fwrite (buffer, ret, 1, stdout);
	      fflush (stdout);
	    }
	}

      if (FD_ISSET (STDIN_FILENO, &rset))
	{
	  if ((bytes = read (STDIN_FILENO, buffer, MAX_BUF - 1)) <= 0)
	    {
              user_term = 1;
              break;
	    }

          do
            ret = gnutls_record_send (session, buffer, bytes);
          while (ret == GNUTLS_E_AGAIN || ret == GNUTLS_E_INTERRUPTED);
	  if (ret <= 0)
	    handle_error (session, ret);
	}
    }

  if (user_term != 0)
    {
      do
        ret = gnutls_bye (session, GNUTLS_SHUT_WR);
      while (ret == GNUTLS_E_INTERRUPTED || ret == GNUTLS_E_AGAIN);
      gnutls_deinit (session);
    }
  else
    gnutls_deinit (session);

 out:
  shutdown (fd, SHUT_RDWR);	/* shutdown now, close on exit */
  gnutls_anon_free_client_credentials (anon_cred);
  gnutls_certificate_free_credentials (xcred);
  gnutls_global_deinit ();
  return retval;
}
#else
int
main (int argc, char **argv)
{
  return 1;
}
#endif
