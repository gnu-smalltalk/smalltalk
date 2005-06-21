/* Fault handler information.  HP-UX HPPA version.
   Copyright (C) 2002  Paolo Bonzini <bonzini@gnu.org>
   Copyright (C) 2002-2003  Bruno Haible <bruno@clisp.org>

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

#define USE_64BIT_REGS(mc) \
  (((mc).ss_flags & SS_WIDEREGS) && ((mc).ss_flags & SS_NARROWISINVALID))

/* Extract the cr21 register from an mcontext_t.
   See the comments in /usr/include/machine/save_state.h.  */
#define GET_CR21(mc) \
  (USE_64BIT_REGS(mc) ? (mc).ss_wide.ss_64.ss_cr21 : (mc).ss_narrow.ss_cr21)

/* Extract the stack pointer from an mcontext_t.
   See the comments in /usr/include/machine/save_state.h.  */
#define GET_SP(mc) \
  (USE_64BIT_REGS(mc) ? (mc).ss_wide.ss_64.ss_sp : (mc).ss_narrow.ss_sp)

/* Both of these alternatives work on HP-UX 10.20 and HP-UX 11.00.  */
#if 1

#include "fault-hpux.h"

#define SIGSEGV_FAULT_ADDRESS  GET_CR21 (scp->sc_sl.sl_ss)
#define SIGSEGV_FAULT_STACKPOINTER  GET_SP (scp->sc_ctxt.sl.sl_ss)

#else

#include "fault-posix.h"

#define SIGSEGV_FAULT_STACKPOINTER  GET_SP (((ucontext_t *) ucp)->uc_mcontext)

#endif
