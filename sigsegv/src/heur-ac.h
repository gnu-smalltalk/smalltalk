/* Detecting stack overflow.  Version for platforms which supply the
   fault address and have sigsegv_get_vma.
   Copyright (C) 2003  Bruno Haible <bruno@clisp.org>

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

static unsigned long stack_top = 0;

static int
remember_stack_top (void *some_variable_on_stack)
{
  struct vma_struct vma;

  if (stack_top)
    return 0;

  /* Needs to be retrieved once only.  */
  if (sigsegv_get_vma ((unsigned long) some_variable_on_stack, &vma) >= 0)
    {
      stack_top = vma.end - 1;
      return 0;
    }
  else
    return -1;
}

#define IS_STACK_OVERFLOW \
  is_stk_overflow ((unsigned long) SIGSEGV_FAULT_ADDRESS)

static int
is_stk_overflow (unsigned long addr)
{
  struct vma_struct vma;

  if (sigsegv_get_vma (stack_top, &vma) < 0)
    return 0;

#ifdef __ia64
  return (addr >= vma.prev_end && addr <= vma.end - 1);
#else
#if STACK_DIRECTION < 0
  return (addr >= vma.start
          ? (addr <= vma.end - 1)
          : (vma.start - addr < (vma.start - vma.prev_end) / 2));
#else
  return (addr <= vma.end - 1
          ? (addr >= vma.start)
          : (addr - vma.end < (vma.next_start - vma.end) / 2));
#endif
#endif
}

