/* Fault handler information.  FreeBSD/i386 version.
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
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

#define SIGSEGV_FAULT_HANDLER_ARGLIST  int sig, int code, struct sigcontext *scp, void *addr
#define SIGSEGV_FAULT_ADDRESS  addr
#define SIGSEGV_FAULT_CONTEXT  scp
#define SIGSEGV_FAULT_STACKPOINTER  scp->sc_esp
