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

#ifndef GST_SIGNALX_H
#define GST_SIGNALX_H

#include "config.h"
#include <signal.h>

#ifndef SIGHUP
#define SIGHUP          1       /* Hangup (POSIX).  */
#define RPL_SIGHUP      1
#define RPL_NSIG        2
#endif

#ifndef SIGINT
#define SIGINT          2       /* Interrupt (ANSI).  */
#define RPL_SIGINT      2
#undef RPL_NSIG
#define RPL_NSIG        3
#endif

#ifndef SIGQUIT
#define SIGQUIT         3       /* Quit (POSIX).  */
#define RPL_SIGQUIT     3
#undef RPL_NSIG
#define RPL_NSIG        4
#endif

#ifndef SIGILL
#define SIGILL          4       /* Illegal instruction (ANSI).  */
#define RPL_SIGILL      4
#undef RPL_NSIG
#define RPL_NSIG        5
#endif

#ifndef SIGTRAP
#define SIGTRAP         5       /* Trace trap (POSIX).  */
#define RPL_SIGTRAP     5
#undef RPL_NSIG
#define RPL_NSIG        6
#endif

#ifndef SIGABRT
#define SIGABRT         6       /* Abort (ANSI).  */
#define RPL_SIGABRT     6
#undef RPL_NSIG
#define RPL_NSIG        7
#endif

#ifndef SIGIOT
#define SIGIOT          6       /* IOT trap (4.2 BSD).  */
#define RPL_SIGIOT      6
#undef RPL_NSIG
#define RPL_NSIG        7
#endif

#ifndef SIGBUS
#define SIGBUS          7       /* BUS error (4.2 BSD).  */
#define RPL_SIGBUS      7
#undef RPL_NSIG
#define RPL_NSIG        8
#endif

#ifndef SIGFPE
#define SIGFPE          8       /* Floating-point exception (ANSI).  */
#define RPL_SIGFPE      8
#undef RPL_NSIG
#define RPL_NSIG        9
#endif

#ifndef SIGKILL
#define SIGKILL         9       /* Kill, unblockable (POSIX).  */
#define RPL_SIGKILL     9
#undef RPL_NSIG
#define RPL_NSIG        10
#endif

#ifndef SIGUSR1
#define SIGUSR1         10      /* User-defined signal 1 (POSIX).  */
#define RPL_SIGUSR1     10
#undef RPL_NSIG
#define RPL_NSIG        11
#endif

#ifndef SIGSEGV
#define SIGSEGV         11      /* Segmentation violation (ANSI).  */
#define RPL_SIGSEGV     11
#undef RPL_NSIG
#define RPL_NSIG        12
#endif

#ifndef SIGUSR2
#define SIGUSR2         12      /* User-defined signal 2 (POSIX).  */
#define RPL_SIGUSR2     12
#undef RPL_NSIG
#define RPL_NSIG        13
#endif

#ifndef SIGPIPE
#define SIGPIPE         13      /* Broken pipe (POSIX).  */
#define RPL_SIGPIPE     13
#undef RPL_NSIG
#define RPL_NSIG        14
#endif

#ifndef SIGALRM
#define SIGALRM         14      /* Alarm clock (POSIX).  */
#define RPL_SIGALRM     14
#undef RPL_NSIG
#define RPL_NSIG        15
#endif

#ifndef SIGTERM
#define SIGTERM         15      /* Termination (ANSI).  */
#define RPL_SIGTERM     15
#undef RPL_NSIG
#define RPL_NSIG        16
#endif

#ifndef SIGSTKFLT
#define SIGSTKFLT       16      /* Stack fault.  */
#define RPL_SIGSTKFLT   16
#undef RPL_NSIG
#define RPL_NSIG        17
#endif

#ifndef SIGCLD
#define SIGCLD          SIGCHLD /* Same as SIGCHLD (System V).  */
#endif

#ifndef SIGCHLD
#define SIGCHLD         17      /* Child status has changed (POSIX).  */
#define RPL_SIGCHLD     17
#undef RPL_NSIG
#define RPL_NSIG        18
#endif

#ifndef SIGCONT
#define SIGCONT         18      /* Continue (POSIX).  */
#define RPL_SIGCONT     18
#undef RPL_NSIG
#define RPL_NSIG        19
#endif

#ifndef SIGSTOP
#define SIGSTOP         19      /* Stop, unblockable (POSIX).  */
#define RPL_SIGSTOP     19
#undef RPL_NSIG
#define RPL_NSIG        20
#endif

#ifndef SIGTSTP
#define SIGTSTP         20      /* Keyboard stop (POSIX).  */
#define RPL_SIGTSTP     20
#undef RPL_NSIG
#define RPL_NSIG        21
#endif

/* 21 and 22 used by mingw, work around.  */
#if STDLIB_NSIG > RPL_NSIG
#define SIG_DELTA	(STDLIB_NSIG - 21)
#else
#define SIG_DELTA	0
#endif

#ifndef SIGTTIN
#define SIGTTIN         (21 + SIG_DELTA)      /* Background read from tty (POSIX).  */
#define RPL_SIGTTIN     (21 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (22 + SIG_DELTA)
#endif

#ifndef SIGTTOU
#define SIGTTOU         (22 + SIG_DELTA)      /* Background write to tty (POSIX).  */
#define RPL_SIGTTOU     (22 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (23 + SIG_DELTA)
#endif

#ifndef SIGURG
#define SIGURG          (23 + SIG_DELTA)      /* Urgent condition on socket (4.2 BSD).  */
#define RPL_SIGURG      (23 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (24 + SIG_DELTA)
#endif

#ifndef SIGXCPU
#define SIGXCPU         (24 + SIG_DELTA)      /* CPU limit exceeded (4.2 BSD).  */
#define RPL_SIGXCPU     (24 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (25 + SIG_DELTA)
#endif

#ifndef SIGXFSZ
#define SIGXFSZ         (25 + SIG_DELTA)      /* File size limit exceeded (4.2 BSD).  */
#define RPL_SIGXFSZ     (25 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (26 + SIG_DELTA)
#endif

#ifndef SIGVTALRM
#define SIGVTALRM       (26 + SIG_DELTA)      /* Virtual alarm clock (4.2 BSD).  */
#define RPL_SIGVTALRM   (26 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (27 + SIG_DELTA)
#endif

#ifndef SIGPROF
#define SIGPROF         (27 + SIG_DELTA)      /* Profiling alarm clock (4.2 BSD).  */
#define RPL_SIGPROF     (27 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (28 + SIG_DELTA)
#endif

#ifndef SIGWINCH
#define SIGWINCH        (28 + SIG_DELTA)      /* Window size change (4.3 BSD, Sun).  */
#define RPL_SIGWINCH    (28 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (29 + SIG_DELTA)
#endif

#ifndef SIGPOLL
#define SIGPOLL         SIGIO   /* Pollable event occurred (System V).  */
#endif

#ifndef SIGIO
#define SIGIO           (29 + SIG_DELTA)      /* I/O now possible (4.2 BSD).  */
#define RPL_SIGIO       (29 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (30 + SIG_DELTA)
#endif

#ifndef SIGPWR
#define SIGPWR          (30 + SIG_DELTA)      /* Power failure restart (System V).  */
#define RPL_SIGPWR      (30 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (31 + SIG_DELTA)
#endif

#ifndef SIGSYS
#define SIGSYS          (31 + SIG_DELTA)      /* Bad system call.  */
#define RPL_SIGSYS      (31 + SIG_DELTA)
#undef RPL_NSIG
#define RPL_NSIG        (32 + SIG_DELTA)
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
