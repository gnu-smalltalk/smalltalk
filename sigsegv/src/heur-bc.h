/* Detecting stack overflow.  Version for platforms which supply the
   stack pointer and have sigsegv_get_vma.
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

#if HAVE_GETRLIMIT
# include <sys/types.h>
# include <sys/time.h>
# include <sys/resource.h> /* declares struct rlimit */
#endif

/* Address of the last byte belonging to the stack vma.  */
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
  is_stk_overflow ((unsigned long) (SIGSEGV_FAULT_STACKPOINTER))

static int
is_stk_overflow (int sp)
{
  struct vma_struct vma;

  if (sigsegv_get_vma (stack_top, &vma) < 0)
    return 0;

#if HAVE_GETRLIMIT && defined RLIMIT_STACK
  {
    /* Heuristic BC: If the stack size has reached its maximal size,
       and sp is near the low end, we consider it a stack
       overflow.  */
    struct rlimit rl;

    if (getrlimit (RLIMIT_STACK, &rl) >= 0)
      {
        unsigned long current_stack_size = vma.end - vma.start;
        unsigned long max_stack_size = rl.rlim_cur;
        if (current_stack_size <= max_stack_size - 4096)
          return 0;
      }
  }
#endif

    /* Heuristic BC: If we know sp, and it is neither
       near the low end, nor in the alternate stack, then
       it's probably not a stack overflow.  */
    return (sp >= stk_extra_stack
            && sp <= stk_extra_stack + stk_extra_stack_size)
#if STACK_DIRECTION < 0
           || (sp <= vma.start + 4096 && vma.start <= sp + 4096)
#else
           || (sp <= vma.end + 4096 && vma.end <= sp + 4096)
#endif
           ;
}
