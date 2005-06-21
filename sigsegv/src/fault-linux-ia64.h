/* Fault handler information.  Linux/IA-64 version.
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

#define SIGSEGV_FAULT_HANDLER_ARGLIST  int sig, siginfo_t *sip, struct sigcontext *scp
#define SIGSEGV_FAULT_ADDRESS  sip->si_addr
#define SIGSEGV_FAULT_CONTEXT  scp

/* IA-64 has two stack pointers, one that grows down, called $r12, and one
   that grows up, called $bsp/$bspstore.  */
#define SIGSEGV_FAULT_STACKPOINTER  scp->sc_gr[12]

/* It would be better to access $bspstore instead of $bsp but I don't know
   where to find it in 'struct sigcontext'.  Anyway, it doesn't matter
   because $bsp and $bspstore never differ by more than ca. 1 KB.  */
#define SIGSEGV_FAULT_BSP_POINTER  scp->sc_ar_bsp
