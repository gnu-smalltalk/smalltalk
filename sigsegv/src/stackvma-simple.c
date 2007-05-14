/* Determine the virtual memory area of a given address.
   Copyright (C) 2006  Bruno Haible <bruno@clisp.org>

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

/* This file contains the proximity test function for the simple cases, where
   the OS has an API for enumerating the mapped ranges of virual memory.  */

#if STACK_DIRECTION < 0

/* Info about the gap between this VMA and the previous one.
   addr must be < vma->start.  */
static int
simple_is_near_this (unsigned long addr, struct vma_struct *vma)
{
  return (vma->start - addr <= (vma->start - vma->prev_end) / 2);
}

#endif
#if STACK_DIRECTION > 0

/* Info about the gap between this VMA and the next one.
   addr must be > vma->end - 1.  */
static int
simple_is_near_this (unsigned long addr, struct vma_struct *vma)
{
  return (addr - vma->end < (vma->next_start - vma->end) / 2);
}

#endif
