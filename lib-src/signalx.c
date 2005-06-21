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

#include "signalx.h"

#ifdef RPL_NSIG

/* Undefine the names, we need access to the C library's implementation.  */
#undef raise
#undef signal

sighandler_t sigtable[RPL_NSIG];
#define SIG_HANDLER(sig) sigtable[-(sig) - 1]

int
rpl_raise (int sig)
{
  if (sig < -RPL_NSIG || sig > NSIG)
    return -1;

  if (sig < 0)
    {
      sighandler_t old_handler = SIG_HANDLER(sig);
      SIG_HANDLER(sig) = SIG_DFL;
      if (old_handler != SIG_DFL && old_handler != SIG_IGN)
        (*old_handler) (sig);

      return 0;
    }
  else
    return raise(sig);
}

sighandler_t
rpl_signal (int sig, sighandler_t handler)
{
  if (sig < -RPL_NSIG || sig > NSIG || handler == SIG_ERR)
    return SIG_ERR;

  if (sig < 0)
    {
      sighandler_t old_handler = SIG_HANDLER(sig);
      SIG_HANDLER(sig) = handler;
      return old_handler;
    }
  else
    return signal(sig, handler);
}
#endif /* RPL_NSIG */
