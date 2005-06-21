/* Fault handler information.  Linux/ARM version.
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

/* This file supports only kernels >= 2.2.14 or >= 2.3.35.  Support for older
   kernels would be more complicated, see file
   glibc/sysdeps/unix/sysv/linux/arm/bits/armsigctx.h.  */

#include <asm/sigcontext.h>

#define SIGSEGV_FAULT_HANDLER_ARGLIST  int sig, int r1, int r2, int r3, struct sigcontext sc
#define SIGSEGV_FAULT_CONTEXT  &sc
#define SIGSEGV_FAULT_STACKPOINTER  sc.arm_sp
