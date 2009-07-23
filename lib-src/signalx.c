/******************************** -*- C -*- ****************************
 *
 *      Emulation for systems that don't have all POSIX signals.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/

#include "signalx.h"

#ifdef RPL_NSIG

/* Undefine the names, we need access to the C library's implementation.  */
#undef raise
#undef signal

sighandler_t sigtable[NSIG];
#define SIG_HANDLER(sig) sigtable[(sig) - 1]

static inline int
is_stdlib_signal (int sig)
{
  static const long long int non_stdlib_signals = (0
#ifdef RPL_SIGHUP
	| (1LL << RPL_SIGHUP)
#endif
#ifdef RPL_SIGINT
	| (1LL << RPL_SIGINT)
#endif
#ifdef RPL_SIGQUIT
	| (1LL << RPL_SIGQUIT)
#endif
#ifdef RPL_SIGILL
	| (1LL << RPL_SIGILL)
#endif
#ifdef RPL_SIGTRAP
	| (1LL << RPL_SIGTRAP)
#endif
#ifdef RPL_SIGABRT
	| (1LL << RPL_SIGABRT)
#endif
#ifdef RPL_SIGIOT
	| (1LL << RPL_SIGIOT)
#endif
#ifdef RPL_SIGBUS
	| (1LL << RPL_SIGBUS)
#endif
#ifdef RPL_SIGFPE
	| (1LL << RPL_SIGFPE)
#endif
#ifdef RPL_SIGKILL
	| (1LL << RPL_SIGKILL)
#endif
#ifdef RPL_SIGUSR1
	| (1LL << RPL_SIGUSR1)
#endif
#ifdef RPL_SIGSEGV
	| (1LL << RPL_SIGSEGV)
#endif
#ifdef RPL_SIGUSR2
	| (1LL << RPL_SIGUSR2)
#endif
#ifdef RPL_SIGPIPE
	| (1LL << RPL_SIGPIPE)
#endif
#ifdef RPL_SIGALRM
	| (1LL << RPL_SIGALRM)
#endif
#ifdef RPL_SIGTERM
	| (1LL << RPL_SIGTERM)
#endif
#ifdef RPL_SIGSTKFLT
	| (1LL << RPL_SIGSTKFLT)
#endif
#ifdef RPL_SIGCHLD
	| (1LL << RPL_SIGCHLD)
#endif
#ifdef RPL_SIGCONT
	| (1LL << RPL_SIGCONT)
#endif
#ifdef RPL_SIGSTOP
	| (1LL << RPL_SIGSTOP)
#endif
#ifdef RPL_SIGTSTP
	| (1LL << RPL_SIGTSTP)
#endif
#ifdef RPL_SIGTTIN
	| (1LL << RPL_SIGTTIN)
#endif
#ifdef RPL_SIGTTOU
	| (1LL << RPL_SIGTTOU)
#endif
#ifdef RPL_SIGURG
	| (1LL << RPL_SIGURG)
#endif
#ifdef RPL_SIGXCPU
	| (1LL << RPL_SIGXCPU)
#endif
#ifdef RPL_SIGXFSZ
	| (1LL << RPL_SIGXFSZ)
#endif
#ifdef RPL_SIGVTALRM
	| (1LL << RPL_SIGVTALRM)
#endif
#ifdef RPL_SIGPROF
	| (1LL << RPL_SIGPROF)
#endif
#ifdef RPL_SIGWINCH
	| (1LL << RPL_SIGWINCH)
#endif
#ifdef RPL_SIGIO
	| (1LL << RPL_SIGIO)
#endif
#ifdef RPL_SIGPWR
	| (1LL << RPL_SIGPWR)
#endif
#ifdef RPL_SIGSYS
	| (1LL << RPL_SIGSYS)
#endif
	);

  return (non_stdlib_signals & (1LL << sig)) == 0;
}

int
rpl_raise (int sig)
{
  if (sig >= NSIG)
    return -1;

  if (is_stdlib_signal (sig))
    return raise(sig);
  else
    {
      sighandler_t old_handler = SIG_HANDLER(sig);
      SIG_HANDLER(sig) = SIG_DFL;
      if (old_handler != SIG_DFL && old_handler != SIG_IGN)
        (*old_handler) (sig);

      return 0;
    }
}

sighandler_t
rpl_signal (int sig, sighandler_t handler)
{
  if (sig >= NSIG || handler == SIG_ERR)
    return SIG_ERR;

  if (is_stdlib_signal (sig))
    return signal(sig, handler);
  else
    {
      sighandler_t old_handler = SIG_HANDLER(sig);
      SIG_HANDLER(sig) = handler;
      return old_handler;
    }
}
#endif /* RPL_NSIG */
