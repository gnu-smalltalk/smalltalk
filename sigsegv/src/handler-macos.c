/* Fault handler information.  MacOSX version.
   Copyright (C) 1993-1999, 2002-2003  Bruno Haible <bruno@clisp.org>
   Copyright (C) 2003  Paolo Bonzini <bonzini@gnu.org>

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

#include "sigsegv.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>
#if HAVE_SYS_SIGNAL_H
# include <sys/signal.h>
#endif

#include <mach/mach.h>
#include <mach/mach_error.h>
#include <mach/thread_status.h>
#include <mach/exception.h>
#include <mach/task.h>
#include <pthread.h>

/* For MacOSX.  */
#ifndef SS_DISABLE
#define SS_DISABLE SA_DISABLE
#endif

#include "machfault.h"

/* The following sources were used as a *reference* for this exception handling
   code:
      1. Apple's mach/xnu documentation
      2. Timothy J. Wood's "Mach Exception Handlers 101" post to the
         omnigroup's macosx-dev list.
         www.omnigroup.com/mailman/archive/macosx-dev/2000-June/002030.html */

/* This is not defined in any header, although documented.  */

/* http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/exc_server.html says:
   The exc_server function is the MIG generated server handling function
   to handle messages from the kernel relating to the occurrence of an
   exception in a thread. Such messages are delivered to the exception port
   set via thread_set_exception_ports or task_set_exception_ports. When an
   exception occurs in a thread, the thread sends an exception message to its
   exception port, blocking in the kernel waiting for the receipt of a reply.
   The exc_server function performs all necessary argument handling for this
   kernel message and calls catch_exception_raise, catch_exception_raise_state
   or catch_exception_raise_state_identity, which should handle the exception.
   If the called routine returns KERN_SUCCESS, a reply message will be sent,
   allowing the thread to continue from the point of the exception; otherwise,
   no reply message is sent and the called routine must have dealt with the
   exception thread directly.  */
extern boolean_t
       exc_server (mach_msg_header_t *request_msg,
                   mach_msg_header_t *reply_msg);


/* http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/catch_exception_raise.html
   These functions are defined in this file, and called by exc_server.
   FIXME: What needs to be done when this code is put into a shared library? */
kern_return_t
catch_exception_raise (mach_port_t exception_port,
                       mach_port_t thread,
                       mach_port_t task,
                       exception_type_t exception,
                       exception_data_t code,
                       mach_msg_type_number_t code_count);
kern_return_t
catch_exception_raise_state (mach_port_t exception_port,
                             exception_type_t exception,
                             exception_data_t code,
                             mach_msg_type_number_t code_count,
                             thread_state_flavor_t *flavor,
                             thread_state_t in_state,
                             mach_msg_type_number_t in_state_count,
                             thread_state_t out_state,
                             mach_msg_type_number_t *out_state_count);
kern_return_t
catch_exception_raise_state_identity (mach_port_t exception_port,
                                      mach_port_t thread,
                                      mach_port_t task,
                                      exception_type_t exception,
                                      exception_data_t code,
                                      mach_msg_type_number_t codeCnt,
                                      thread_state_flavor_t *flavor,
                                      thread_state_t in_state,
                                      mach_msg_type_number_t in_state_count,
                                      thread_state_t out_state,
                                      mach_msg_type_number_t *out_state_count);


/* The exception port on which our thread listens.  */
static mach_port_t our_exception_port;


/* mach_initialize() status:
   0: not yet called
   1: called and succeeded
   -1: called and failed  */
static int mach_initialized = 0;

/* Communication area for the exception state and thread state.  */
static SIGSEGV_THREAD_STATE_TYPE save_thread_state;

/* Check for reentrant signals.  */
static int emergency = -1;

/* User's stack overflow handler.  */
static stackoverflow_handler_t stk_user_handler = (stackoverflow_handler_t)NULL;
static unsigned long stk_extra_stack;
static unsigned long stk_extra_stack_size;

/* User's fault handler.  */
static sigsegv_handler_t user_handler = (sigsegv_handler_t)NULL;

/* A handler that is called in the faulting thread.  It terminates the thread.  */
static void
terminating_handler ()
{
  /* Dump core.  */
  raise (SIGSEGV);

  /* Seriously.  */
  abort ();
}

/* A handler that is called in the faulting thread, on an alternate stack.
   It calls the user installed stack overflow handler.  */
static void
altstack_handler ()
{
  /* We arrive here when the user refused to handle a fault.  */

  /* Check if it is plausibly a stack overflow, and the user installed
     a stack overflow handler.  */
  if (stk_user_handler)
    {
      emergency++;
      /* Call user's handler.  */
      (*stk_user_handler) (emergency, &save_thread_state);
    }

  /* Else, terminate the thread.  */
  terminating_handler ();
}


/* Handle an exception by invoking the user's fault handler and/or forwarding
   the duty to the previously installed handlers.  */
kern_return_t
catch_exception_raise (mach_port_t exception_port,
                       mach_port_t thread,
                       mach_port_t task,
                       exception_type_t exception,
                       exception_data_t code,
                       mach_msg_type_number_t code_count)
{
#ifdef SIGSEGV_EXC_STATE_TYPE
  SIGSEGV_EXC_STATE_TYPE exc_state;
#endif
  SIGSEGV_THREAD_STATE_TYPE thread_state;
  mach_msg_type_number_t state_count;
  unsigned long addr;
  unsigned long sp;

#ifdef DEBUG_EXCEPTION_HANDLING
  fprintf (stderr, "Exception: 0x%x Code: 0x%x 0x%x in catch....\n",
           exception,
           code_count > 0 ? code[0] : -1,
           code_count > 1 ? code[1] : -1);
#endif

  /* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/thread_get_state.html.  */
#ifdef SIGSEGV_EXC_STATE_TYPE
  state_count = SIGSEGV_EXC_STATE_COUNT;
  if (thread_get_state (thread, SIGSEGV_EXC_STATE_FLAVOR,
                        (void *) &exc_state, &state_count)
      != KERN_SUCCESS)
    {
      /* The thread is supposed to be suspended while the exception handler
         is called. This shouldn't fail. */
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "thread_get_state failed for exception state\n");
#endif
      return KERN_FAILURE;
    }
#endif

  state_count = SIGSEGV_THREAD_STATE_COUNT;
  if (thread_get_state (thread, SIGSEGV_THREAD_STATE_FLAVOR,
                        (void *) &thread_state, &state_count)
      != KERN_SUCCESS)
    {
      /* The thread is supposed to be suspended while the exception handler
         is called. This shouldn't fail. */
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "thread_get_state failed for thread state\n");
#endif
      return KERN_FAILURE;
    }

  addr = (unsigned long) (SIGSEGV_FAULT_ADDRESS (thread_state, exc_state));
  sp = (unsigned long) (SIGSEGV_STACK_POINTER (thread_state));

  /* Got the thread's state. Now extract the address that caused the
     fault and invoke the user's handler.  */
  save_thread_state = thread_state;

  /* If the fault address is near the stack pointer, it's a stack overflow.
     Otherwise, treat it like a normal SIGSEGV.  */
  if (addr <= sp + 4096 && sp <= addr + 4096)
    {
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "Treating as stack overflow, sp = 0x%lx\n", (char *) sp);
#endif
      SIGSEGV_STACK_POINTER (thread_state) =
#if STACK_DIRECTION < 0
        stk_extra_stack + stk_extra_stack_size - 256;
#else
        stk_extra_stack + 256;
#endif
      /* Continue handling this fault in the faulting thread.  (We cannot longjmp while
         in the exception handling thread, so we need to mimic what signals do!)  */
      SIGSEGV_PROGRAM_COUNTER (thread_state) = (unsigned long) altstack_handler;
    }
  else
    {
      if (user_handler)
        {
          int done;
#ifdef DEBUG_EXCEPTION_HANDLING
          fprintf (stderr, "Calling user handler, addr = 0x%lx\n", (char *) addr);
#endif
          done = (*user_handler) ((void *) addr, 1);
#ifdef DEBUG_EXCEPTION_HANDLING
          fprintf (stderr, "Back from user handler\n");
#endif
          if (done)
            return KERN_SUCCESS;
        }
      SIGSEGV_PROGRAM_COUNTER (thread_state) = (unsigned long) terminating_handler;
    }

  /* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/thread_set_state.html.  */
  if (thread_set_state (thread, SIGSEGV_THREAD_STATE_FLAVOR,
                        (void *) &thread_state, state_count)
      != KERN_SUCCESS)
    {
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "thread_set_state failed for altstack state\n");
#endif
      return KERN_FAILURE;
    }
  return KERN_SUCCESS;
}


/* The main function of the thread listening for exceptions.  */
static void *
mach_exception_thread (void *arg)
{
  for (;;)
    {
      /* These two structures contain some private kernel data. We don't need
         to access any of it so we don't bother defining a proper struct. The
         correct definitions are in the xnu source code. */
      /* Buffer for a message to be received.  */
      struct
        {
          mach_msg_header_t head;
          mach_msg_body_t msgh_body;
          char data[1024];
        }
        msg;
      /* Buffer for a reply message.  */
      struct
        {
          mach_msg_header_t head;
          char data[1024];
        }
        reply;

      mach_msg_return_t retval;

#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "Exception thread going to sleep\n");
#endif

      /* Wait for a message on the exception port.  */
      retval = mach_msg (&msg.head, MACH_RCV_MSG | MACH_RCV_LARGE, 0,
                         sizeof (msg), our_exception_port,
                         MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "Exception thread woke up\n");
#endif
      if (retval != MACH_MSG_SUCCESS)
        {
#ifdef DEBUG_EXCEPTION_HANDLING
          fprintf (stderr, "mach_msg receive failed with %d %s\n",
                   (int) retval, mach_error_string (retval));
#endif
          abort ();
        }

      /* Handle the message: Call exc_server, which will call
         catch_exception_raise and produce a reply message.  */
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "Calling exc_server\n");
#endif
      exc_server (&msg.head, &reply.head);
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "Finished exc_server\n");
#endif

      /* Send the reply.  */
      if (mach_msg (&reply.head, MACH_SEND_MSG, reply.head.msgh_size,
                    0, MACH_PORT_NULL,
                    MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL)
          != MACH_MSG_SUCCESS)
        {
#ifdef DEBUG_EXCEPTION_HANDLING
          fprintf (stderr, "mach_msg send failed\n");
#endif
          abort ();
        }
#ifdef DEBUG_EXCEPTION_HANDLING
      fprintf (stderr, "Reply successful\n");
#endif
    }
}


/* Initialize the Mach exception handler thread.
   Return 0 if OK, -1 on error.  */
static int
mach_initialize ()
{
  mach_port_t self;
  exception_mask_t mask;
  pthread_attr_t attr;
  pthread_t thread;

  self = mach_task_self ();

  /* Allocate a port on which the thread shall listen for exceptions.  */
  if (mach_port_allocate (self, MACH_PORT_RIGHT_RECEIVE, &our_exception_port)
      != KERN_SUCCESS)
    return -1;

  /* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_insert_right.html.  */
  if (mach_port_insert_right (self, our_exception_port, our_exception_port,
                              MACH_MSG_TYPE_MAKE_SEND)
      != KERN_SUCCESS)
    return -1;

  /* The exceptions we want to catch.  Only EXC_BAD_ACCESS is interesting
     for us (see above in function catch_exception_raise).  */
  mask = EXC_MASK_BAD_ACCESS;

  /* Create the thread listening on the exception port.  */
  if (pthread_attr_init (&attr) != 0)
    return -1;
  if (pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED) != 0)
    return -1;
  if (pthread_create (&thread, &attr, mach_exception_thread, NULL) != 0)
    return -1;
  pthread_attr_destroy (&attr);

  /* Replace the exception port info for these exceptions with our own.
     Note that we replace the exception port for the entire task, not only
     for a particular thread.  This has the effect that when our exception
     port gets the message, the thread specific exception port has already
     been asked, and we don't need to bother about it.
     See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_set_exception_ports.html.  */
  if (task_set_exception_ports (self, mask, our_exception_port,
                                EXCEPTION_DEFAULT, MACHINE_THREAD_STATE)
      != KERN_SUCCESS)
    return -1;

  return 0;
}


int
sigsegv_install_handler (sigsegv_handler_t handler)
{
  if (!mach_initialized)
    mach_initialized = (mach_initialize () >= 0 ? 1 : -1);
  if (mach_initialized < 0)
    return -1;

  user_handler = handler;

  return 0;
}

void
sigsegv_deinstall_handler (void)
{
  user_handler = (sigsegv_handler_t)NULL;
}

void
sigsegv_leave_handler (void)
{
  emergency--;
}

int
stackoverflow_install_handler (stackoverflow_handler_t handler,
                               void *extra_stack, unsigned long extra_stack_size)
{
  if (!mach_initialized)
    mach_initialized = (mach_initialize () >= 0 ? 1 : -1);
  if (mach_initialized < 0)
    return -1;

  stk_user_handler = handler;
  stk_extra_stack = (unsigned long) extra_stack;
  stk_extra_stack_size = extra_stack_size;
  return 0;
}

void
stackoverflow_deinstall_handler (void)
{
  stk_user_handler = (stackoverflow_handler_t) NULL;
}
