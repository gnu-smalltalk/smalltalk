/******************************** -*- C -*- ****************************
 *
 *	Interpreter employing a bytecode->native code translator.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2003, 2004, 2006, 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
 *
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/

/* This is basically how the interpreter works.

   The interpreter expects to be called in an environment where there
   already exists a well-defined method context.  The instruction
   pointer, stored in the global variable "native_ip", and the stack
   pointer, stored in the global variable "sp", should be set up to
   point into the current method and gst_method_context.  Other global
   variables, such as "_gst_this_method", _gst_self",
   "_gst_temporaries", etc. should also be setup; see the routine
   _gst_prepare_execution_environment for details.  `_gst_interpret'
   immediately calls `_gst_run_native_code' (coded with GNU lightning in
   xlat.c) and starts executing compiled code.
   
   Every now and then, the compiled code checks to see if any change
   in its state is required, such as switching to a new process,
   dealing with an asynchronous signal and printing out the byte codes
   that are being executed, if that was requested by the user.  If so,
   it returns to `_gst_interpret', telling where to restart execution.
   `_gst_interpret' handles the event and passes control back to the
   compiled code.  Control is returned to `_gst_interpret' also when
   the private #__terminate method is executed.

   When a message send occurs for the first time, an internal routine
   (either doSend or doSuper) is invoked (these routines are coded
   with GNU lightning in xlat.c); this routine calls lookup_native_ip,
   which looks for the method in a cache like the one used by the
   standard interpreter, and if it is not found, asks xlat.c to return
   the address; in turn, xlat.c looks for the code into an hash table
   (which handles collisions unlike lookup_native_ip's cache) before
   compiling it.  doSend then saves the returned address so that it
   will be used the next time the message is sent, then it jumps to
   the address.

   If no selector is found, doSend calls lookup_native_ip again,
   asking for the address of the #doesNotUnderstand: method.  Note
   that lookup_native_ip had modified the stack, pushing a gst_message
   object that embeds information about the original selector and
   arguments.  If #doesNotUnderstand: is not understood, a crash is
   extremely likely; things like this are however to be expected,
   since you're really playing a bad game and going against some
   logical things that the VM assumes for speed.

   After the first time, doSend is not called: instead, the previous
   address is used to guess the likely address where the code to be
   called lies.  Of course, the `guessed' address might be wrong,
   because the receiver's class might have changed.  So the prolog of
   every compiled method checks for this eventuality and, if so,
   performs a standard lookup by jumping back to doSend.  Note that
   this cannot happen with doSuper, because super sends always go to
   the same receiver (which is the `_gst_self' object).

   Methods can be marked as doing special things.  These are returning
   self, returning an instance variable, return a literal object,
   or executing a primitive method definition.  In the first three
   cases, the method does not create a context, and immediately jumps
   back to the caller.  In the latter case, the method calls
   execute_primitive_operation, examines its return value, and
   does one of three things: 
   - jumping back to the caller
   - creating a context and executing the Smalltalk code (failure)
   - load a new native_ip and jump there
 
   BlockClosure>>#value is special-cased in that the new native_ip is
   cached in the same way that doSend caches the address of a method.

   When a method returns, the context that called it is examined to
   restore the interpreter's global variables to the state that they
   were in before the callee was invoked.  After the state has been
   restored, the callee jumps back to the caller, almost oblivious to
   the fact that millions of instructions could have been executed
   since control was left.

   Note that the microprocessor's CALL and RETURN instructions are not
   used.  Instead, once the _gst_run_native_code function is called, control
   threads from one method to another, without creating any stack
   frames, mantaining all the information partly inside ContextPart
   objects and partly inside inline_cache structures (see xlat.c): the
   latter also act as continuations that are passed to the callee, which
   stores the continuation info in the ContextPart.  This allows an
   extremely easy implementation of non-local returns.  */


/* This is the bridge between the interpreter and Just-In-Time code
   generation.  It works the same as _gst_send_message_internal, but
   it only looks up the IP for the native code (compiling the bytecode
   on demand if it is not available yet) and returns it to the caller.
   This is because the caller will often be JIT-compiled code which
   likes to set up the execution contexts and to execute primitives on
   its own.  */
static PTR lookup_native_ip (OOP sendSelector, 
			     int sendArgs,
			     OOP receiver,
			     OOP method_class);

/* This walks the context stack starting at CONTEXTOOP, compiling on
   demand all the methods for which native code is not available yet,
   and restoring the native instruction pointers that are not set (for
   example because the context was restored from a saved image and
   has not been executed since the snapshot was restored).  */
static void refresh_native_ips (OOP contextOOP);

#include "jitpriv.h"

/* The functions that are called by the JIT-compiled code.  */
const internal_func _gst_internal_funcs[] = {
  (internal_func) unwind_context,
  (internal_func) unwind_method,
  (internal_func) activate_new_context,
  (internal_func) prepare_context,
  (internal_func) empty_context_stack,
  (internal_func) lookup_native_ip,
};

#define GET_CONTEXT_IP(ctx) 	((char *) (((uintptr_t) ((ctx)->native_ip)) - 1))
#define GET_NATIVE_IP(ipOffset)	((OOP) (((uintptr_t) ipOffset) + 1))

#define SET_THIS_METHOD(method, ipOffset) {				\
  _gst_this_method = (method);						\
  native_ip = (ipOffset);						\
}


PTR
lookup_native_ip (OOP sendSelector, 
		  int sendArgs,
		  OOP receiver,
		  OOP method_class) /* the class in which to start the
				       search */
{
  REGISTER (1, int hashIndex);
  REGISTER (2, method_cache_entry * methodData);
  REGISTER (3, OOP receiverClass);

  /* hash the selector and the class of the receiver together using
     XOR. Since both are addresses in the object table, and since
     object table entries are 2 longs in size, shift over by 3 bits
     (4 on 64-bit architectures) to remove the useless low order zeros. 
   */

  _gst_sample_counter++;
  hashIndex = METHOD_CACHE_HASH (sendSelector, method_class);
  methodData = &method_cache[hashIndex];

  if (methodData->selectorOOP != sendSelector
      || methodData->startingClassOOP != method_class)
    {
      /* :-( cache miss )-: */
      if (!lookup_method
	  (sendSelector, methodData, sendArgs, method_class))
	return (NULL);
      else
	/* The next test cannot succeed */
	methodData->receiverClass = NULL;
    }

  receiverClass = OOP_INT_CLASS (receiver);
  if (methodData->receiverClass == receiverClass)
    return (methodData->nativeCode);

  methodData->receiverClass = receiverClass;
  methodData->nativeCode =
    _gst_get_native_code (methodData->methodOOP, receiverClass);
  return (methodData->nativeCode);
}

void
_gst_send_message_internal (OOP sendSelector,
			    int sendArgs,
			    OOP receiver,
			    OOP method_class) /* the class in which to start the
						 search */
{
  int hashIndex;
  method_header header;
  REGISTER (1, OOP receiverClass);
  REGISTER (2, method_cache_entry * methodData);

  /* hash the selector and the class of the receiver together using
     XOR. Since both are addresses in the object table, and since
     object table entries are 2 longs in size, shift over by 3 bits
     (4 on 64-bit architectures) to remove the useless low order zeros. 
   */

  _gst_sample_counter++;
  hashIndex = METHOD_CACHE_HASH (sendSelector, method_class);
  methodData = &method_cache[hashIndex];

  if (methodData->selectorOOP != sendSelector
      || methodData->startingClassOOP != method_class)
    {
      /* :-( cache miss )-: */
      if (!lookup_method
	  (sendSelector, methodData, sendArgs, method_class))
	{
	  SEND_MESSAGE (_gst_does_not_understand_symbol, 1);
	  return;
	}
      else
	/* The test on the receiverClass will not succeed */
	methodData->receiverClass = NULL;
    }

  header = methodData->methodHeader;

  receiverClass = OOP_INT_CLASS (receiver);
  if (methodData->receiverClass != receiverClass)
    {
      methodData->receiverClass = receiverClass;
      methodData->nativeCode =
	_gst_get_native_code (methodData->methodOOP, receiverClass);
    }
  native_ip = methodData->nativeCode;
}


void
_gst_send_method (OOP methodOOP)
{
  OOP receiverClass;
  method_header header;
  REGISTER (1, gst_compiled_method method);
  REGISTER (2, OOP receiver);
  REGISTER (3, int sendArgs);

  _gst_sample_counter++;

  method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
  header = method->header;
  sendArgs = header.numArgs;
  receiver = STACK_AT (sendArgs);

  receiverClass = OOP_INT_CLASS (receiver);
  native_ip = _gst_get_native_code (methodOOP, receiverClass);
}

static mst_Boolean
send_block_value (int numArgs, int cull_up_to)
{
  OOP closureOOP;
  OOP receiverClass;
  block_header header;
  REGISTER (2, gst_block_closure closure);

  closureOOP = STACK_AT (numArgs);
  closure = (gst_block_closure) OOP_TO_OBJ (closureOOP);
  header = ((gst_compiled_block) OOP_TO_OBJ (closure->block))->header;

  /* Check numArgs.  Remove up to CULL_UP_TO extra arguments if needed.  */
  if UNCOMMON (numArgs != header.numArgs)
    {
      if (numArgs < header.numArgs || numArgs > header.numArgs + cull_up_to)
        return (true);

      POP_N_OOPS (numArgs - header.numArgs);
      numArgs = header.numArgs;
    }

  receiverClass = IS_INT (closure->receiver)
    ? _gst_small_integer_class
    : OOP_CLASS (closure->receiver);

  native_ip = _gst_get_native_code (closure->block, receiverClass);
  return (false);
}


void
_gst_validate_method_cache_entries (void)
{
  int i;
  method_cache_entry *mc;
  for (i = 0; i < METHOD_CACHE_SIZE; i++)
    {
      mc = &method_cache[i];
      if (mc->selectorOOP && !IS_VALID_IP (mc->nativeCode))
	/* invalidate this entry */
	mc->selectorOOP = NULL;
    }
}


void
refresh_native_ips (OOP contextOOP)
{
  OOP receiver, receiverClass;
  int virtualIP;
  gst_method_context context;
  PTR native_ip;

  context = (gst_method_context) OOP_TO_OBJ (contextOOP);
  do
    {
      receiver = context->receiver;
      receiverClass = OOP_INT_CLASS (receiver);

      if (context->method == _gst_get_termination_method ())
	native_ip = (char *) _gst_return_from_native_code;
      else
	{
	  /* Go get the native IP! */
	  virtualIP = TO_INT (context->ipOffset);
	  native_ip =
	    _gst_map_virtual_ip (context->method, receiverClass, virtualIP);

#ifndef OPTIMIZE
	  if (!native_ip)
	    {
	      /* This problem *might* (I'm not even sure) happen if you
		 restore a non-JITted snapshot with the JIT enabled.  It
		 should be easy to fix the interpreter so that a process
		 can be suspended at message sends only.  */
	      printf ("Context's IP is not a sequence point!");
	      abort ();
	    }
#endif
	}

      context->native_ip = GET_NATIVE_IP (native_ip);

      contextOOP = context->parentContext;
      context = (gst_method_context) OOP_TO_OBJ (contextOOP);
    }
  while (!IS_NIL (contextOOP) && context->native_ip == DUMMY_NATIVE_IP);
}


OOP
_gst_interpret (OOP processOOP)
{
  interp_jmp_buf jb;
  gst_callin_process process;
  push_jmp_buf (&jb, true, processOOP);

  if (setjmp (jb.jmpBuf) == 0)
    for (;;)
      {
        gst_method_context thisContext;

        if (!native_ip)
	  return (_gst_nil_oop);

        native_ip = _gst_run_native_code (native_ip);

        if (!native_ip)
	  {
            OOP activeProcessOOP = get_scheduled_process ();
            gst_callin_process process = (gst_callin_process) OOP_TO_OBJ (activeProcessOOP);
            process->returnedValue = POP_OOP ();
            _gst_terminate_process (activeProcessOOP);
	  }

	SET_EXCEPT_FLAG (false);

        if UNCOMMON (_gst_abort_execution)
	  {
	    OOP selectorOOP;
	    selectorOOP = _gst_intern_string ((char *)_gst_abort_execution);
	    _gst_abort_execution = NULL;
	    SEND_MESSAGE (selectorOOP, 0);
	  }

        /* First, deal with any async signals.  */
        if (async_queue_enabled)
          empty_async_queue ();

        thisContext =
	  (gst_method_context) OOP_TO_OBJ (_gst_this_context_oop);
        thisContext->native_ip = GET_NATIVE_IP (native_ip);

        if UNCOMMON (!IS_NIL (switch_to_process))
	  {
	    change_process_context (switch_to_process);
            if UNCOMMON (single_step_semaphore)
              {
                _gst_async_signal (single_step_semaphore);
                single_step_semaphore = NULL;
              }
	  }

        else if UNCOMMON (time_to_preempt)
	  ACTIVE_PROCESS_YIELD ();

        if (is_process_terminating (processOOP))
          break;

        /* If the native_ip in the context is not valid, this is a
           process that we have not restarted yet! Get a fresh
           native_ip for each context in the chain, recompiling
           methods if needed. */
        thisContext =
	  (gst_method_context) OOP_TO_OBJ (_gst_this_context_oop);

        if (!(_gst_this_method->flags & F_XLAT)
	    || thisContext->native_ip == DUMMY_NATIVE_IP)
	  {
	    refresh_native_ips (_gst_this_context_oop);
	    native_ip = GET_CONTEXT_IP (thisContext);
	  }

        if UNCOMMON (time_to_preempt)
	  set_preemption_timer ();
      }

  if (!IS_NIL (switch_to_process))
    change_process_context (switch_to_process);

  process = (gst_callin_process) OOP_TO_OBJ (processOOP);
  if (pop_jmp_buf ())
    stop_execution ();

  return (process->returnedValue);
}
