/* ftruncate replacement for Win32
   Copyright (C) 2003 The GLib team

   This program is free software; you can redistribute it and/or 
   modify it under the terms of the GNU Lesser General Public License
   as published by the Free Software Foundation; either version 2.1,
   or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
   USA.
   
   */

#if defined __MSVCRT__ || defined __CYGWIN__ || defined __CYGWIN32__ || defined WIN32 || defined _WIN32 || defined __WIN32__
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#error Sorry, an alternative ftruncate implementation is only provided for Win32.  Write to help-smalltalk@gnu.org.
#endif

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

int
ftruncate (int fd, unsigned int size)
{
  HANDLE hfile;
  unsigned int curpos;

  if (fd < 0)
    {
      errno = EBADF;
      return -1;
    }

  hfile = (HANDLE) _get_osfhandle (fd);
  curpos = SetFilePointer (hfile, 0, NULL, FILE_CURRENT);
  if (curpos == ~0
      || SetFilePointer (hfile, size, NULL, FILE_BEGIN) == ~0
      || !SetEndOfFile (hfile))
    {
      int error = GetLastError (); 
      switch (error)
	{
	case ERROR_INVALID_HANDLE:
	  errno = EBADF;
	  break;
	default:
	  errno = EIO;
	  break;
	}
      return -1;
    }
  return 0;
}

