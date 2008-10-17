/* socketx.c - Extend WinSock functions to handle other objects than sockets
   Contributed by Freddie Akeroyd.

   Copyright 2007, 2008 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include <socketx.h>

#ifdef __MSVCRT__


int
win_close (int fd)
{
  SOCKET sock = _get_osfhandle (fd);
  WSANETWORKEVENTS ev;
   
  ev.lNetworkEvents = 0xDEADBEEF;
  WSAEnumNetworkEvents (sock, NULL, &ev); 
  if (ev.lNetworkEvents != 0xDEADBEEF)
    {
      int r = closesocket (sock);

      /* FIXME: other applications, like squid, use an undocumented
        _free_osfhnd free function.  Instead, here we just close twice
        the handle, once with closesocket and once with CloseHandle.
        I could not get the former to work (pb, Sep 22 2008).  */ 
      _close (fd);
      return r;
    }
  else
    return _close (fd);
}

#endif

