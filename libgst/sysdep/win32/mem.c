/******************************** -*- C -*- ****************************
 *
 * System specific implementation module.
 *
 * This module contains implementations of various operating system
 * specific routines.  This module should encapsulate most (or all)
 * of these calls so that the rest of the code is portable.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006,2007,2008,2009
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"

#ifdef WIN32
# define WIN32_LEAN_AND_MEAN /* avoid including junk */
# include <windows.h>
#endif

#ifndef MAP_FAILED
# define MAP_FAILED ((char *) -1)
#endif

int
_gst_mem_protect (PTR addr, size_t len, int prot)
{
  DWORD oldprot;
  int my_prot;

  switch (prot & (PROT_READ | PROT_WRITE | PROT_EXEC))
  {
  case PROT_NONE:
    my_prot = 0; break;

  case PROT_READ:
    my_prot = PAGE_READONLY; break;

  case PROT_WRITE:
  case PROT_READ | PROT_WRITE:
    my_prot = PAGE_READWRITE; break;

  case PROT_EXEC:
    my_prot = PAGE_EXECUTE; break;

  case PROT_EXEC | PROT_READ:
    my_prot = PAGE_EXECUTE_READ; break;

  case PROT_EXEC | PROT_WRITE:
  case PROT_EXEC | PROT_READ | PROT_WRITE:
    my_prot = PAGE_EXECUTE_READWRITE; break;
  
  default:
    return -1;
  }

  if (VirtualProtect (addr, len, my_prot, &oldprot))
    return 0;
  else
    return -1;
}

PTR
_gst_osmem_alloc (size_t size)
{
  PTR addr;
  addr = VirtualAlloc(NULL, size, MEM_RESERVE, PAGE_NOACCESS);
  if (addr)
    {
      PTR result = VirtualAlloc (addr, size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      if (result)
        return result;

      VirtualFree (addr, size, MEM_RELEASE);
    }

  errno = ENOMEM;
  return NULL;
}

void
_gst_osmem_free (PTR ptr, size_t size)
{
  VirtualFree(ptr, size, MEM_DECOMMIT);
  VirtualFree(ptr, size, MEM_RELEASE);
}

PTR
_gst_osmem_reserve (PTR address, size_t size)
{
  PTR base;
  base = VirtualAlloc(address, size, MEM_RESERVE, PAGE_NOACCESS);
  if (!base && address)
    base = VirtualAlloc(NULL, size, MEM_RESERVE, PAGE_NOACCESS);
  if (!base)
    errno = ENOMEM;

  return base;
}

void
_gst_osmem_release (PTR base, size_t size)
{
  VirtualFree(base, size, MEM_RELEASE);
}

PTR
_gst_osmem_commit (PTR base, size_t size)
{
  PTR addr;
  addr = VirtualAlloc (base, size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if (!addr)
    errno = ENOMEM;

  return addr;
}

void
_gst_osmem_decommit (PTR base, size_t size)
{
  VirtualFree(base, size, MEM_DECOMMIT);
}
