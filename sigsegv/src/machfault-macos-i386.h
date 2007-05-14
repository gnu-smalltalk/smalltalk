/* Fault handler information.  MacOSX/i386 version.
   Copyright (C) 2003-2004, 2006  Bruno Haible <bruno@clisp.org>

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

#define SIGSEGV_THREAD_STATE_TYPE                   i386_thread_state_t
#define SIGSEGV_THREAD_STATE_FLAVOR                 i386_THREAD_STATE
#define SIGSEGV_THREAD_STATE_COUNT                  i386_THREAD_STATE_COUNT
#define SIGSEGV_EXC_STATE_TYPE                      i386_exception_state_t
#define SIGSEGV_EXC_STATE_FLAVOR                    i386_EXCEPTION_STATE
#define SIGSEGV_EXC_STATE_COUNT                     i386_EXCEPTION_STATE_COUNT
#define SIGSEGV_FAULT_ADDRESS(thr_state,exc_state)  (exc_state).faultvaddr
#define SIGSEGV_STACK_POINTER(thr_state)            (thr_state).esp
#define SIGSEGV_PROGRAM_COUNTER(thr_state)          (thr_state).eip
