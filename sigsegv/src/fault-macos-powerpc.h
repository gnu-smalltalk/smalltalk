/* Fault handler information.  MacOSX/PowerPC version.
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
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

#include "fault-macos-powerpc.c"

#define SIGSEGV_FAULT_HANDLER_ARGLIST  int sig, int code, struct sigcontext *scp
#define SIGSEGV_FAULT_ADDRESS  (unsigned long) get_fault_addr (scp)
#define SIGSEGV_FAULT_CONTEXT  scp
#if 0
#define SIGSEGV_FAULT_STACKPOINTER  (&((unsigned int *) scp->sc_regs)[2])[1]
#endif
#define SIGSEGV_FAULT_STACKPOINTER  (scp->sc_regs ? ((unsigned int *) scp->sc_regs)[3] : scp->sc_sp)
