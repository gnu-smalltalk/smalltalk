/******************************** -*- C -*- ****************************
 *
 * Asynchronous events handling.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001,2002,2003,2005,2006,2008,2009,2011
 * Free Software Foundation, Inc.
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


#include "gstpriv.h"


/* Holds the semaphores to be signaled when the operating system sends
   us a C-style signal.  */
async_queue_entry _gst_sem_int_vec[NSIG];

/* Signals _gst_sem_int_vec[SIG] and removes the semaphore from the vector
   (because C-style signal handlers are one-shot).  */
static RETSIGTYPE signal_handler (int sig);

#define EVENT_LOOP_POLL_INTERVAL	20

enum event_loop_state {
  /* The timer thread has scheduled an asynchronous call to the
     poll handler.  This happens when GNU Smalltalk is running
     client code and the timer fires.  */
  STATE_POLLING,

  /* GNU Smalltalk is running client code, so the timer thread
     must be scheduling perioding calls.  */
  STATE_RUNNING,

  /* The poll callback returned true, so the event semaphore
     has been signaled.  Before polling again, the Smalltalk
     event loop has to invoke Processor>>#dispatchEvents
     (which will invoke the dispatch callback).  */
  STATE_DISPATCHING,

  /* GNU Smalltalk is idle, so no polling should be scheduled.
     _gst_idle will take care of calling the poll handler
     as necessary.  */
  STATE_IDLE
};

#ifdef _WIN32
#include <windows.h>

/* The synchronization objects for the event loop.  The state_event
   is set if cur_state is STATE_RUNNING.  */
static CRITICAL_SECTION state_cs;
static HANDLE state_event;
#else
#include <pthread.h>
#define INFINITE (-1)

/* The synchronization objects for the event loop.  The condition
   variable is signaled when CUR_STATE becomes STATE_RUNNING.  */
static pthread_mutex_t state_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t state_cond = PTHREAD_COND_INITIALIZER;
#endif

/* Lock or unlock the state_cs/state_mutex, which protect
   CUR_STATE.  */
static void event_loop_lock(void);
static void event_loop_unlock(void);

/* Set CUR_STATE and signal the event or condition variable
   as appropriate.  */
static void set_event_loop_state (enum event_loop_state state);

/* The current state of the event loop.  */
static enum event_loop_state cur_state = STATE_RUNNING;

/* The current event loop handlers.  */
static mst_Boolean (*event_poll) (int);
static void (*event_dispatch) (void);

/* Whether event loop handlers have been set, and the event loop
   thread is running.  */
static int have_event_loop_handlers = false;

/* The next time when the VM thread should interrupt itself for
   polling.  */
static int64_t next_poll_ms;

/* This handler is called asynchronously when the state changes
   to STATE_POLLING, or synchronously when the GNU Smalltalk
   VM becomes idle.  The argument can be true for a blocking
   wait, nil for a non-blocking wait, false to wait until
   next_poll_ms.  */
static void poll_events (OOP blockingOOP);


static void
event_loop_lock(void)
{
#ifdef _WIN32
  EnterCriticalSection (&state_cs);
#else
  pthread_mutex_lock (&state_mutex);
#endif
}

static void
event_loop_unlock(void)
{
#ifdef _WIN32
  LeaveCriticalSection (&state_cs);
#else
  pthread_mutex_unlock (&state_mutex);
#endif
}

static void
set_event_loop_state (enum event_loop_state state)
{
  enum event_loop_state old_state;
  old_state = cur_state;
  if (old_state == state)
    return;

  cur_state = state;

#ifdef _WIN32
  if (have_event_loop_handlers)
    {
      if (state == STATE_RUNNING && old_state != STATE_RUNNING)
        SetEvent(state_event);
      else if (state != STATE_RUNNING && old_state == STATE_RUNNING)
        ResetEvent(state_event);
    }
#endif

  switch (state)
    {
    case STATE_POLLING:
      event_loop_unlock ();
      _gst_async_call (poll_events, _gst_nil_oop);
      event_loop_lock ();
      break;

#ifndef _WIN32
    case STATE_RUNNING:
      if (have_event_loop_handlers)
        pthread_cond_signal (&state_cond);
      break;
#endif
    }
}

static
#ifdef _WIN32
unsigned __stdcall
#else
void *
#endif
poll_timer_thread (void *unused)
{
  event_loop_lock ();
  for (;;)
    {
      unsigned ms;

      /* If running, sleep until the next periodic poll.  Otherwise,
         sleep indefinitely waiting for the VM to require periodic
	 polls.  */
      if (cur_state == STATE_RUNNING)
        {
	  unsigned cur_time;
          cur_time = _gst_get_milli_time ();
          if (cur_time < next_poll_ms)
            ms = MIN(0, next_poll_ms - cur_time);
          else if (cur_time >= next_poll_ms)
            {
              ms = EVENT_LOOP_POLL_INTERVAL;
              next_poll_ms = cur_time + ms;
              set_event_loop_state(STATE_POLLING);
            }
        }
      else
        ms = INFINITE;

#ifdef _WIN32
      event_loop_unlock ();
      WaitForSingleObject (state_event, ms);
      event_loop_lock ();
#else
      if (ms == INFINITE)
        pthread_cond_wait (&state_cond, &state_mutex);
      else if (ms)
        {
          event_loop_unlock ();
          _gst_usleep (ms * 1000);
          event_loop_lock ();
        }
#endif
    }

  return 0;
}

static void
poll_events (OOP blockingOOP)
{
  unsigned ms;
  gst_processor_scheduler processor;
  if (blockingOOP == _gst_nil_oop)
    ms = 0;
  else if (blockingOOP == _gst_true_oop)
    ms = -1;
  else
    ms = MIN(0, next_poll_ms - _gst_get_milli_time ());

  if (event_poll && event_poll (ms))
    {
      /* Polling told us they have events ready.  If available, signal the
         event semaphore and switch to STATE_DISPATCHING.  */
      processor = (gst_processor_scheduler) OOP_TO_OBJ (_gst_processor_oop);
      if (TO_INT (processor->objSize)
          > offsetof (struct gst_processor_scheduler, eventSemaphore) / sizeof(OOP))
        {
          event_loop_lock ();
          set_event_loop_state (STATE_DISPATCHING);
          event_loop_unlock ();
          processor = (gst_processor_scheduler) OOP_TO_OBJ (_gst_processor_oop);
          _gst_sync_signal (processor->eventSemaphore, true);
        }
    }

  event_loop_lock ();
  if (cur_state == STATE_POLLING)
    set_event_loop_state (STATE_RUNNING);
  event_loop_unlock ();
}

void
_gst_dispatch_events (void)
{
  if (event_dispatch)
    event_dispatch ();

  event_loop_lock ();
  set_event_loop_state (STATE_RUNNING);
  event_loop_unlock ();
}

void
_gst_idle (mst_Boolean blocking)
{
  event_loop_lock ();
  set_event_loop_state (STATE_IDLE);
  event_loop_unlock ();

  if (have_event_loop_handlers)
    poll_events (blocking ? _gst_true_oop : _gst_false_oop);
  else if (blocking)
    _gst_pause ();
  else
    _gst_usleep (EVENT_LOOP_POLL_INTERVAL * 1000);
}

mst_Boolean
_gst_set_event_loop_handlers(mst_Boolean (*poll) (int ms),
                             void (*dispatch) (void))
{
  if (!have_event_loop_handlers)
    {
#ifdef _WIN32
      HANDLE hThread;
      hThread = (HANDLE) _beginthreadex(NULL, 0, poll_timer_thread,
                                        NULL, 0, NULL);
      CloseHandle (hThread);
#else
      pthread_attr_t attr;
      pthread_t thread;
      pthread_attr_init(&attr);
      pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
      pthread_create(&thread, &attr, poll_timer_thread, NULL);
#endif
      have_event_loop_handlers = true;
      event_poll = poll;
      event_dispatch = dispatch;
      return true;
    }
  else
    return false;
}

void
_gst_init_event_loop()
{
#ifdef _WIN32
  InitializeCriticalSection(&state_cs);
  state_event = CreateEvent(NULL, TRUE, TRUE, NULL);
#endif
}

RETSIGTYPE
signal_handler (int sig)
{
  if (_gst_sem_int_vec[sig].data)
    {
      if (IS_CLASS (_gst_sem_int_vec[sig].data, _gst_semaphore_class))
        _gst_async_call_internal (&_gst_sem_int_vec[sig]);
      else
	{
	  _gst_errorf
	    ("C signal trapped, but no semaphore was waiting");
	  raise (sig);
	}
    }

  _gst_set_signal_handler (sig, SIG_DFL);
  _gst_wakeup ();
}

void
_gst_async_interrupt_wait (OOP semaphoreOOP,
			   int sig)
{
  if (sig < 0 || sig >= NSIG)
    return;

  _gst_register_oop (semaphoreOOP);
  _gst_sem_int_vec[sig].func = _gst_do_async_signal_and_unregister;
  _gst_sem_int_vec[sig].data = semaphoreOOP;
  _gst_set_signal_handler (sig, signal_handler);

  /* should probably package up the old interrupt state here for return
     so that it can be undone */
}


