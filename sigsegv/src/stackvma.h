/* Determine the virtual memory area of a given address.
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

#ifndef _STACKVMA_H
#define _STACKVMA_H

/* Describes a virtual memory area, with some info about the gap between
   it and the next or previous virtual memory area.  */
struct vma_struct
{
  unsigned long start;
  unsigned long end;
#if STACK_DIRECTION < 0
  /* Info about the gap between this VMA and the previous one.
     addr must be < vma->start.  */
  int (*is_near_this) (unsigned long addr, struct vma_struct *vma);
  /* Private field, not provided by all sigsegv_get_vma implementations.  */
  unsigned long prev_end;
#endif
#if STACK_DIRECTION > 0
  /* Info about the gap between this VMA and the next one.
     addr must be > vma->end - 1.  */
  int (*is_near_this) (unsigned long addr, struct vma_struct *vma);
  /* Private field, not provided by all sigsegv_get_vma implementations.  */
  unsigned long next_start;
#endif
};

/* Determines the virtual memory area to which a given address belongs,
   and returns 0.  Returns -1 if it cannot be determined.
   This function is used to determine the stack extent when a fault occurs.  */
extern int sigsegv_get_vma (unsigned long address, struct vma_struct *vma);

#endif /* _STACKVMA_H */
