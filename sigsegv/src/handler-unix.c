/* Fault handler information.  Unix version.
   Copyright (C) 1993-1999, 2002-2003  Bruno Haible <bruno@clisp.org>

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

#include "sigsegv.h"

#include <stddef.h> /* needed for NULL on SunOS4 */
#include <stdio.h> /* perror */
#include <stdlib.h>
#include <signal.h>
#if HAVE_SYS_SIGNAL_H
# include <sys/signal.h>
#endif
#include <errno.h>

/* For MacOSX.  */
#ifndef SS_DISABLE
#define SS_DISABLE SA_DISABLE
#endif

#if HAVE_STACK_OVERFLOW_RECOVERY
static stackoverflow_handler_t stk_user_handler = (stackoverflow_handler_t)NULL;
static unsigned long stk_extra_stack;
static unsigned long stk_extra_stack_size;
#endif /* HAVE_STACK_OVERFLOW_RECOVERY */

#if HAVE_SIGSEGV_RECOVERY
/* User's SIGSEGV handler.  */
static sigsegv_handler_t user_handler = (sigsegv_handler_t)NULL;
#endif /* HAVE_SIGSEGV_RECOVERY */


/* Platform dependent:
   Characteristics of the signal handler.  */
#include CFG_FAULT

/* Platform dependent:
   Determining which signals should be trapped.  */
#include CFG_SIGNALS

/* Platform dependent:
   Determine the virtual memory area of a given address.  */
#include "stackvma.h"

/* Platform dependent:
   Leaving a signal handler executing on the alternate stack.  */
#include "leave.h"

/* Platform dependent:
   Determine if a fault is caused by a stack overflow.  */
#include CFG_HEURISTICS

#ifndef SIGSEGV_FAULT_HANDLER_ARGLIST
#define SIGSEGV_FAULT_HANDLER_ARGLIST int sig
#endif

#ifndef SIGSEGV_FAULT_CONTEXT
#define SIGSEGV_FAULT_CONTEXT NULL
#endif

/* Our SIGSEGV handler, with OS dependent argument list.  */
static void
sigsegv_handler (SIGSEGV_FAULT_HANDLER_ARGLIST)
{
#if HAVE_SIGSEGV_RECOVERY
  void *address = (void *) (SIGSEGV_FAULT_ADDRESS);
#endif

#if HAVE_STACK_OVERFLOW_RECOVERY
  /* Did the user install a stack overflow handler?  */
  if (stk_user_handler)
    {

#if HAVE_SIGSEGV_RECOVERY
       /* Call user's handler.  If successful, exit.  */
       if (user_handler && (*user_handler) (address, 0))
         return;
#endif /* HAVE_SIGSEGV_RECOVERY */

       /* Handler declined responsibility.  */

      if (IS_STACK_OVERFLOW)
	{
	  /* Call user's handler.  */
#ifdef SIGSEGV_FAULT_STACKPOINTER
	  unsigned long old_sp = (unsigned long) SIGSEGV_FAULT_STACKPOINTER;
	  int emergency =
	    (old_sp >= stk_extra_stack
	     && old_sp <= stk_extra_stack + stk_extra_stack_size);
#else
	  int emergency = 0;
#endif /* SIGSEGV_FAULT_STACKPOINTER */

	  stackoverflow_context_t context = (SIGSEGV_FAULT_CONTEXT);
	  (*stk_user_handler) (emergency, context);
        }
    }
#endif /* HAVE_STACK_OVERFLOW_RECOVERY */

#if HAVE_SIGSEGV_RECOVERY
  /* Call user's handler again.  If successful, exit.  */
  if (user_handler && (*user_handler) (address, 1))
    return;
#endif /* HAVE_SIGSEGV_RECOVERY */

  /* All handlers declined responsibility for real.  */

  /* Remove ourselves and dump core.  */
  SIGSEGV_FOR_ALL_SIGNALS (sig, signal (sig, SIG_DFL);)
}


static void
install_for (int sig)
{
  struct sigaction action;

#ifdef SIGSEGV_FAULT_ADDRESS_FROM_SIGINFO
  action.sa_sigaction = &sigsegv_handler;
#else
  action.sa_handler = (void (*) (int)) &sigsegv_handler;
#endif
  /* Block most signals while SIGSEGV is being handled.  */
  /* Signals SIGKILL, SIGSTOP cannot be blocked.  */
  /* Signals SIGCONT, SIGTSTP, SIGTTIN, SIGTTOU are not blocked because
     dealing with these signals seems dangerous.  */
  /* Signals SIGILL, SIGABRT, SIGFPE, SIGSEGV, SIGTRAP, SIGIOT, SIGEMT, SIGBUS,
     SIGSYS, SIGSTKFLT are not blocked because these are synchronous signals,
     which may require immediate intervention, otherwise the process may
     starve.  */
  sigemptyset (&action.sa_mask);
#ifdef SIGHUP
  sigaddset (&action.sa_mask,SIGHUP);
#endif
#ifdef SIGINT
  sigaddset (&action.sa_mask,SIGINT);
#endif
#ifdef SIGQUIT
  sigaddset (&action.sa_mask,SIGQUIT);
#endif
#ifdef SIGPIPE
  sigaddset (&action.sa_mask,SIGPIPE);
#endif
#ifdef SIGALRM
  sigaddset (&action.sa_mask,SIGALRM);
#endif
#ifdef SIGTERM
  sigaddset (&action.sa_mask,SIGTERM);
#endif
#ifdef SIGUSR1
  sigaddset (&action.sa_mask,SIGUSR1);
#endif
#ifdef SIGUSR2
  sigaddset (&action.sa_mask,SIGUSR2);
#endif
#ifdef SIGCHLD
  sigaddset (&action.sa_mask,SIGCHLD);
#endif
#ifdef SIGCLD
  sigaddset (&action.sa_mask,SIGCLD);
#endif
#ifdef SIGURG
  sigaddset (&action.sa_mask,SIGURG);
#endif
#ifdef SIGIO
  sigaddset (&action.sa_mask,SIGIO);
#endif
#ifdef SIGPOLL
  sigaddset (&action.sa_mask,SIGPOLL);
#endif
#ifdef SIGXCPU
  sigaddset (&action.sa_mask,SIGXCPU);
#endif
#ifdef SIGXFSZ
  sigaddset (&action.sa_mask,SIGXFSZ);
#endif
#ifdef SIGVTALRM
  sigaddset (&action.sa_mask,SIGVTALRM);
#endif
#ifdef SIGPROF
  sigaddset (&action.sa_mask,SIGPROF);
#endif
#ifdef SIGPWR
  sigaddset (&action.sa_mask,SIGPWR);
#endif
#ifdef SIGLOST
  sigaddset (&action.sa_mask,SIGLOST);
#endif
#ifdef SIGWINCH
  sigaddset (&action.sa_mask,SIGWINCH);
#endif
  /* Note that sigaction() implicitly adds sig itself to action.sa_mask.  */
  /* Ask the OS to provide a structure siginfo_t to the handler.  */
#ifdef SIGSEGV_FAULT_ADDRESS_FROM_SIGINFO
  action.sa_flags = SA_SIGINFO;
#else
  action.sa_flags = 0;
#endif
#if HAVE_STACK_OVERFLOW_RECOVERY && HAVE_SIGALTSTACK /* not BeOS */
  /* Work around Linux 2.2.5 bug: If SA_ONSTACK is specified but sigaltstack()
     has not been called, the kernel will busy loop, eating CPU time.  So
     avoid setting SA_ONSTACK until the user has requested stack overflow
     handling.  */
  if (stk_user_handler)
    action.sa_flags |= SA_ONSTACK;
#endif
  sigaction (sig, &action, (struct sigaction *) NULL);
}

int
sigsegv_install_handler (sigsegv_handler_t handler)
{
#if HAVE_STACK_OVERFLOW_RECOVERY
  int dummy;
  if (remember_stack_top (&dummy) == -1)
    return -1;
#endif

#if HAVE_SIGSEGV_RECOVERY
  user_handler = handler;

  SIGSEGV_FOR_ALL_SIGNALS (sig, install_for (sig);)

  return 0;
#else
  return -1;
#endif
}

void
sigsegv_deinstall_handler (void)
{
#if HAVE_SIGSEGV_RECOVERY
  user_handler = (sigsegv_handler_t)NULL;

#if HAVE_STACK_OVERFLOW_RECOVERY
  if (!stk_user_handler)
#endif
    {
      SIGSEGV_FOR_ALL_SIGNALS (sig, signal (sig, SIG_DFL);)
    }
#endif
}

void
sigsegv_leave_handler (void)
{
#if HAVE_STACK_OVERFLOW_RECOVERY
  /*
   * Reset the system's knowledge that we are executing on the alternate
   * stack. If we didn't do that, siglongjmp would be needed instead of
   * longjmp to leave the signal handler.
   */
  sigsegv_reset_onstack_flag ();
#endif
}

int
stackoverflow_install_handler (stackoverflow_handler_t handler,
                               void *extra_stack, unsigned long extra_stack_size)
{
#if HAVE_STACK_OVERFLOW_RECOVERY
  int dummy;
  if (remember_stack_top (&dummy) == -1)
    return -1;

  stk_user_handler = handler;
  stk_extra_stack = (unsigned long) extra_stack;
  stk_extra_stack_size = extra_stack_size;
#ifdef __BEOS__
  set_signal_stack (extra_stack, extra_stack_size);
#else /* HAVE_SIGALTSTACK */
  {
    stack_t ss;
    ss.ss_sp = extra_stack;
    ss.ss_size = extra_stack_size;
    ss.ss_flags = 0; /* no SS_DISABLE */
    if (sigaltstack (&ss, (stack_t*)0) < 0)
      return -1;
  }
#endif

  /* Install the signal handlers with SA_ONSTACK.  */
  SIGSEGV_FOR_ALL_SIGNALS (sig, install_for (sig);)
  return 0;
#else
  return -1;
#endif
}

void
stackoverflow_deinstall_handler (void)
{
#if HAVE_STACK_OVERFLOW_RECOVERY
  stk_user_handler = (stackoverflow_handler_t) NULL;

#if HAVE_SIGSEGV_RECOVERY
  if (user_handler)
    {
      /* Reinstall the signal handlers without SA_ONSTACK, to avoid Linux
         bug.  */
      SIGSEGV_FOR_ALL_SIGNALS (sig, install_for (sig);)
    }
  else
#endif
    {
      SIGSEGV_FOR_ALL_SIGNALS (sig, signal (sig, SIG_DFL);)
    }

#ifdef __BEOS__
  /* We cannot undo the effect of set_signal_stack.  */
  fprintf (stderr, "libsigsegv (stackoverflow_deinstall_handler): not supported on this platform\n");
#else /* HAVE_SIGALTSTACK */
  {
    stack_t ss;
    ss.ss_flags = SS_DISABLE;
    if (sigaltstack (&ss, (stack_t *) 0) < 0)
      perror ("libsigsegv (stackoverflow_deinstall_handler)");
  }
#endif

#endif
}
