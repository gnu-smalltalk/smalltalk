/* Leaving a signal handler executing on the alternate stack.
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
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include <signal.h>
#include <ucontext.h>

void
sigsegv_reset_onstack_flag (void)
{
  ucontext_t uc;

  if (getcontext (&uc) >= 0)
    /* getcontext returns twice.  We are interested in the returned context
       only the first time, i.e. when the SS_ONSTACK bit is set.  */
    if (uc.uc_stack.ss_flags & SS_ONSTACK)
      {
        uc.uc_stack.ss_flags &= ~SS_ONSTACK;
        /* Note that setcontext() does not refill uc.  Therefore if
           setcontext() keeps SS_ONSTACK set in the kernel, either
           setcontext() will return -1 or getcontext() will return a
           second time, with the SS_ONSTACK bit being cleared.  */
        setcontext (&uc);
      }
}
