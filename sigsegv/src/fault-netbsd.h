/* Fault handler information.  NetBSD version.
   Copyright (C) 2006  Bruno Haible <bruno@clisp.org>

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

#include "fault-posix.h"

/* _UC_MACHINE_SP is a platform independent macro.
   Defined in <machine/mcontext.h>, see
     http://cvsweb.netbsd.org/bsdweb.cgi/src/sys/arch/$arch/include/mcontext.h
   Supported on alpha, amd64, i386, ia64, m68k, mips, powerpc, sparc since
   NetBSD 2.0.
   On i386, _UC_MACHINE_SP is the same as ->uc_mcontext.__gregs[_REG_UESP],
   and apparently the same value as       ->uc_mcontext.__gregs[_REG_ESP]. */
#ifdef _UC_MACHINE_SP
#define SIGSEGV_FAULT_STACKPOINTER  _UC_MACHINE_SP ((ucontext_t *) ucp)
#endif
