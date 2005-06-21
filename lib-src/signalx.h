/******************************** -*- C -*- ****************************
 *
 *      Emulation for systems that don't have all POSIX signals.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
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

#ifndef GST_SIGNALX_H
#define GST_SIGNALX_H

#include <signal.h>

#ifndef SIGHUP
#define SIGHUP          -1       /* Hangup (POSIX).  */
#define RPL_NSIG        1
#endif

#ifndef SIGINT
#define SIGINT          -2       /* Interrupt (ANSI).  */
#undef RPL_NSIG
#define RPL_NSIG        2
#endif

#ifndef SIGQUIT
#define SIGQUIT         -3       /* Quit (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        3
#endif

#ifndef SIGILL
#define SIGILL          -4       /* Illegal instruction (ANSI).  */
#undef RPL_NSIG
#define RPL_NSIG        4
#endif

#ifndef SIGTRAP
#define SIGTRAP         -5       /* Trace trap (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        5
#endif

#ifndef SIGABRT
#define SIGABRT         -6       /* Abort (ANSI).  */
#undef RPL_NSIG
#define RPL_NSIG        6
#endif

#ifndef SIGIOT
#define SIGIOT          -6       /* IOT trap (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        6
#endif

#ifndef SIGBUS
#define SIGBUS          -7       /* BUS error (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        7
#endif

#ifndef SIGFPE
#define SIGFPE          -8       /* Floating-point exception (ANSI).  */
#undef RPL_NSIG
#define RPL_NSIG        8
#endif

#ifndef SIGKILL
#define SIGKILL         -9       /* Kill, unblockable (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        9
#endif

#ifndef SIGUSR1
#define SIGUSR1         -10      /* User-defined signal 1 (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        10
#endif

#ifndef SIGSEGV
#define SIGSEGV         -11      /* Segmentation violation (ANSI).  */
#undef RPL_NSIG
#define RPL_NSIG        11
#endif

#ifndef SIGUSR2
#define SIGUSR2         -12      /* User-defined signal 2 (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        12
#endif

#ifndef SIGPIPE
#define SIGPIPE         -13      /* Broken pipe (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        13
#endif

#ifndef SIGALRM
#define SIGALRM         -14      /* Alarm clock (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        14
#endif

#ifndef SIGTERM
#define SIGTERM         -15      /* Termination (ANSI).  */
#undef RPL_NSIG
#define RPL_NSIG        15
#endif

#ifndef SIGSTKFLT
#define SIGSTKFLT       -16      /* Stack fault.  */
#undef RPL_NSIG
#define RPL_NSIG        16
#endif

#ifndef SIGCLD
#define SIGCLD          SIGCHLD /* Same as SIGCHLD (System V).  */
#endif

#ifndef SIGCHLD
#define SIGCHLD         -17      /* Child status has changed (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        17
#endif

#ifndef SIGCONT
#define SIGCONT         -18      /* Continue (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        18
#endif

#ifndef SIGSTOP
#define SIGSTOP         -19      /* Stop, unblockable (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        19
#endif

#ifndef SIGTSTP
#define SIGTSTP         -20      /* Keyboard stop (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        20
#endif

#ifndef SIGTTIN
#define SIGTTIN         -21      /* Background read from tty (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        21
#endif

#ifndef SIGTTOU
#define SIGTTOU         -22      /* Background write to tty (POSIX).  */
#undef RPL_NSIG
#define RPL_NSIG        22
#endif

#ifndef SIGURG
#define SIGURG          -23      /* Urgent condition on socket (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        23
#endif

#ifndef SIGXCPU
#define SIGXCPU         -24      /* CPU limit exceeded (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        24
#endif

#ifndef SIGXFSZ
#define SIGXFSZ         -25      /* File size limit exceeded (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        25
#endif

#ifndef SIGVTALRM
#define SIGVTALRM       -26      /* Virtual alarm clock (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        26
#endif

#ifndef SIGPROF
#define SIGPROF         -27      /* Profiling alarm clock (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        27
#endif

#ifndef SIGWINCH
#define SIGWINCH        -28      /* Window size change (4.3 BSD, Sun).  */
#undef RPL_NSIG
#define RPL_NSIG        28
#endif

#ifndef SIGPOLL
#define SIGPOLL         SIGIO   /* Pollable event occurred (System V).  */
#endif

#ifndef SIGIO
#define SIGIO           -29      /* I/O now possible (4.2 BSD).  */
#undef RPL_NSIG
#define RPL_NSIG        29
#endif

#ifndef SIGPWR
#define SIGPWR          -30      /* Power failure restart (System V).  */
#undef RPL_NSIG
#define RPL_NSIG        30
#endif

#ifndef SIGSYS
#define SIGSYS          -31      /* Bad system call.  */
#undef RPL_NSIG
#define RPL_NSIG        31
#endif

#ifdef RPL_NSIG

/* Signals are missing, define alternative implementations.  */
#define sighandler_t rpl_sighandler_t
#define raise rpl_raise
#define signal rpl_signal

typedef void (*sighandler_t) (int);
int raise (int sig);
sighandler_t signal (int sig, sighandler_t handler);

#if NSIG < RPL_NSIG
#undef NSIG
#define NSIG RPL_NSIG
#endif

#endif /* RPL_NSIG */

#endif /* GST_SIGNALX_H */
