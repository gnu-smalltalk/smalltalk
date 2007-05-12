/* Fault handler information.
   Copyright (C) 2004  Bruno Haible <bruno@clisp.org>

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

/* The included file defines:

     SIGSEGV_EXC_STATE_TYPE
          is a type containing state describing details of an exception,
          excluding the thread state.
     SIGSEGV_EXC_STATE_FLAVOR
          is a macro expanding to a constant int value denoting the
          SIGSEGV_EXC_STATE_TYPE type.
     SIGSEGV_EXC_STATE_COUNT
          is a macro expanding to the number of words of the
          SIGSEGV_EXC_STATE_TYPE type.

     SIGSEGV_THREAD_STATE_TYPE
          is a type containing the state of a (stopped or interrupted) thread.
     SIGSEGV_THREAD_STATE_FLAVOR
          is a macro expanding to a constant int value denoting the
          SIGSEGV_THREAD_STATE_TYPE type.
     SIGSEGV_THREAD_STATE_COUNT
          is a macro expanding to the number of words of the
          SIGSEGV_THREAD_STATE_TYPE type.

     SIGSEGV_FAULT_ADDRESS(thr_state, exc_state)
          is a macro for fetching the fault address.

     SIGSEGV_STACK_POINTER(thr_state)
          is a macro, expanding to an lvalue, for fetching the stackpointer at
          the moment the fault occurred, and for setting the stackpointer in
          effect when the thread continues.

     SIGSEGV_PROGRAM_COUNTER(thr_state)
          is a macro, expanding to an lvalue, for fetching the program counter
          (= instruction pointer) at the moment the fault occurred, and for
          setting the program counter before letting the thread continue.

 */

#include CFG_MACHFAULT
