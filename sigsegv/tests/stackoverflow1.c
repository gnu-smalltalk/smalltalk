/* Test the stack overflow handler.
   Copyright (C) 2002-2006  Bruno Haible <bruno@clisp.org>

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

#include "sigsegv.h"
#include <stdio.h>
#include <limits.h>

#if HAVE_STACK_OVERFLOW_RECOVERY

#if defined _WIN32 && !defined __CYGWIN__
  /* Windows doesn't have sigset_t.  */
  typedef int sigset_t;
# define sigemptyset(set)
# define sigprocmask(how,set,oldset)
#else
  /* Unix */
# include "config.h"
#endif

#include <stddef.h> /* needed for NULL on SunOS4 */
#include <stdlib.h> /* for abort, exit */
#include <signal.h>
#include <setjmp.h>
#if HAVE_SETRLIMIT
# include <sys/types.h>
# include <sys/time.h>
# include <sys/resource.h>
#endif
#ifndef SIGSTKSZ
# define SIGSTKSZ 16384
#endif

jmp_buf mainloop;
sigset_t mainsigset;

volatile int pass = 0;

void
stackoverflow_handler (int emergency, stackoverflow_context_t scp)
{
  pass++;
  printf ("Stack overflow %d caught.\n", pass);
  sigprocmask (SIG_SETMASK, &mainsigset, NULL);
  sigsegv_leave_handler ();
  longjmp (mainloop, emergency ? -1 : pass);
}

volatile int *
recurse_1 (int n, volatile int *p)
{
  if (n < INT_MAX)
    *recurse_1 (n + 1, p) += n;
  return p;
}

volatile int
recurse (volatile int n)
{
  return *recurse_1 (n, &n);
}

int
main ()
{
  /* glibc says: Users should use SIGSTKSZ as the size of user-supplied
     buffers.  */
  char mystack[SIGSTKSZ];
  sigset_t emptyset;

#if HAVE_SETRLIMIT && defined RLIMIT_STACK
  /* Before starting the endless recursion, try to be friendly to the user's
     machine.  On some Linux 2.2.x systems, there is no stack limit for user
     processes at all.  We don't want to kill such systems.  */
  struct rlimit rl;
  rl.rlim_cur = rl.rlim_max = 0x100000; /* 1 MB */
  setrlimit (RLIMIT_STACK, &rl);
#endif

  /* Install the stack overflow handler.  */
  if (stackoverflow_install_handler (&stackoverflow_handler,
                                     mystack, sizeof (mystack))
      < 0)
    exit (2);

  /* Save the current signal mask.  */
  sigemptyset (&emptyset);
  sigprocmask (SIG_BLOCK, &emptyset, &mainsigset);

  /* Provoke two stack overflows in a row.  */
  switch (setjmp (mainloop))
    {
    case -1:
      printf ("emergency exit\n"); exit (1);
    case 0: case 1:
      printf ("Starting recursion pass %d.\n", pass + 1);
      recurse (0);
      printf ("no endless recursion?!\n"); exit (1);
    case 2:
      break;
    default:
      abort ();
    }

  printf ("Test passed.\n");
  exit (0);
}

#else

int
main ()
{
  return 77;
}

#endif
