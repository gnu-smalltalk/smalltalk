/* Determine the virtual memory area of a given address.
   Copyright (C) 2002  Bruno Haible <bruno@clisp.org>

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
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

/* Describes a virtual memory area, with some info about the gap between
   it and the next or previous virtual memory area.  */
struct vma_struct
{
  unsigned long start;
  unsigned long end;
#if STACK_DIRECTION < 0
  unsigned long prev_end;
#endif
#if STACK_DIRECTION > 0
  unsigned long next_start;
#endif
};

/* Determines the virtual memory area to which a given address belongs,
   and returns 0.  Returns -1 if it cannot be determined.
   This function is used to determine the stack extent when a fault occurs.  */
extern int sigsegv_get_vma (unsigned long address, struct vma_struct *vma);
