/* Determine the virtual memory area of a given address.  BeOS version.
   Copyright (C) 2002, 2006  Bruno Haible <bruno@clisp.org>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include "stackvma.h"
#include <OS.h>

#include "stackvma-simple.c"

int
sigsegv_get_vma (unsigned long address, struct vma_struct *vma)
{
  area_info info;
  int32 cookie;
  unsigned long start, end;
#if STACK_DIRECTION < 0
  unsigned long prev;
#endif

#if STACK_DIRECTION < 0
  prev = 0;
#endif
  cookie = 0;
  while (get_next_area_info (0, &cookie, &info) == B_OK)
    {
      start = (unsigned long) info.address;
      end = start + info.size;
      if (address >= start && address <= end - 1)
        {
          vma->start = start;
          vma->end = end;
#if STACK_DIRECTION < 0
          vma->prev_end = prev;
#else
          if (get_next_area_info (0, &cookie, &info) == B_OK)
            vma->next_start = (unsigned long) info.address;
          else
            vma->next_start = 0;
#endif
          vma->is_near_this = simple_is_near_this;
          return 0;
        }
#if STACK_DIRECTION < 0
      prev = end;
#endif
    }

  return -1;
}
