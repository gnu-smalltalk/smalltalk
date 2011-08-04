/***********************************************************************
 *
 *  GLib wrappers for GNU Smalltalk
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2003, 2006, 2008, 2009, 2011 Free Software Foundation, Inc.
 * Written by Paolo Bonzini, Norman Jordan, Mike S. Anderson, Gwenael Casaccio.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "config.h"
#include "gstpub.h"
#include "gst-gobject.h"

#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <glib-object.h>
#include <glib.h>

#include <gobject/gvaluecollector.h>

#ifdef G_WIN32_MSG_HANDLE
#include <windows.h>
#else
#include "poll.h"
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

static VMProxy *_glib_vm_proxy;

static void
register_for_type (OOP oop, GType type)
{
  _glib_vm_proxy->registerOOP (oop);
  g_type_set_qdata (type, q_gst_object, oop);
}

int
connect_signal (OOP widget, 
                char *event_name, 
                OOP receiver, 
                OOP selector,
                OOP user_data)
{
  return g_signal_connect_smalltalk_closure (widget, event_name, receiver,
                                             selector, user_data, FALSE);
}

int
connect_signal_no_user_data (OOP widget, 
                             char *event_name, 
                             OOP receiver, 
                             OOP selector)
{
  return connect_signal (widget, event_name, receiver, selector, NULL);
}

int
connect_signal_after (OOP widget, 
                      char *event_name, 
                      OOP receiver, 
                      OOP selector,
                      OOP user_data)
{
  return g_signal_connect_smalltalk_closure (widget, event_name, receiver,
                                             selector, user_data, TRUE);
}

int
connect_signal_after_no_user_data (OOP widget, 
                                   char *event_name, 
                                   OOP receiver, 
                                   OOP selector)
{
  return connect_signal_after (widget, event_name, receiver, selector, NULL);
}

/* Event loop.  The Glib event loop in GNU Smalltalk is split between two
   operating system threads using the low-level g_main_context functions
   (http://library.gnome.org/devel/glib/unstable/glib-The-Main-Event-Loop.html).

   Everything except dispatching occurs in a separate thread than the one
   executing Smalltalk code.  After check(), however, the thread releases
   the context and waits on a condition variable for the Smalltalk code to
   finish the dispatch phase.

   This ensures that all GTK+ code executes in a single OS thread (avoiding
   complicated usage of gdk_threads_{enter,leave}) and at the same time
   allows Smalltalk processes to run in the background while GTK+ events
   are polled.  */

static GMainLoop *loop;
static GThread *thread; 
static GMutex *mutex;
static GCond *cond;
static GCond *cond_dispatch;
static volatile gboolean queued;

#ifdef G_WIN32_MSG_HANDLE
static gint
gst_glib_poll (GPollFD *fds,
	      guint    nfds,
	      gint     timeout)
{
  HANDLE handles[MAXIMUM_WAIT_OBJECTS];
  gint win32_timeout;
  gint poll_msgs = -1;
  GPollFD *f;
  DWORD ready;
  gint nhandles = 0;

  for (f = fds; f < &fds[nfds]; ++f)
      {
        HANDLE h;
        assert (f->fd >= 0);
        if (f->fd == G_WIN32_MSG_HANDLE)
          {
            assert (poll_msgs == -1 && nhandles == f - fds);
            poll_msgs = nhandles;
#if 1
            continue;
#else
	    /* Once the VM will host the event loop, it will be possible to
	       have a MsgWaitForMultipleObjects call in the VM thread and use
	       the result to wake up this side of the loop.  For now resort
	       to polling; messages are checked by the VM thread every 20ms
	       (in the GTK check function, called by g_main_context_check).  */
            h = hWokenUpEvent;
#endif
          }
        else
          h = (HANDLE) f->fd;
        if (nhandles == MAXIMUM_WAIT_OBJECTS)
          {
            g_warning (G_STRLOC ": Too many handles to wait for!\n");
            break;
          }
        handles[nhandles++] = (HANDLE) f->fd;
      }

  if (nhandles == 0)
    {
      /* Wait for nothing (huh?) */
      return 0;
    }

  /* If the VM were idling, it could in principle use MsgWaitForMultipleObjects
     and tell us when it gets a message on its queue.  This would remove the
     need for polling.  However, we cannot implement this until the main
     loop is moved inside the VM.  */
  if (poll_msgs != -1 /* && !idle */ )
    win32_timeout = (timeout == -1 || timeout > 20) ? 20 : timeout;
  else
    win32_timeout = (timeout == -1) ? INFINITE : timeout;

  ready = WaitForMultipleObjects (nhandles, handles, FALSE, win32_timeout);
  if (ready == WAIT_FAILED)
    {
      gchar *emsg = g_win32_error_message (GetLastError ());
      g_warning (G_STRLOC ": WaitForMultipleObjects() failed: %s", emsg);
      g_free (emsg);
    }

  for (f = fds; f < &fds[nfds]; ++f)
    f->revents = 0;

#if 1
  if (poll_msgs != -1)
    {
      if (ready >= WAIT_OBJECT_0 + poll_msgs
	  && ready <= WAIT_OBJECT_0 + nhandles)
        ready++;

      else if (ready == WAIT_TIMEOUT
	       && win32_timeout != INFINITE)
        ready = WAIT_OBJECT_0 + poll_msgs;
    }
#endif

  if (ready == WAIT_FAILED)
    return -1;
  if (ready == WAIT_TIMEOUT)
    return 0;

  f = &fds[ready - WAIT_OBJECT_0];
  if (f->events & (G_IO_IN | G_IO_OUT))
    {
      if (f->events & G_IO_IN)
        f->revents |= G_IO_IN;
      else
        f->revents |= G_IO_OUT;
    }

  return 1;
}

#if 0
/* libgst should have something like this: */

static gint
_gst_pause ()
{
  idle = true;
  ResetEvent (hWakeUpEvent);
  MsgWaitForMultipleObjects (1, &hWakeUpEvent, FALSE, INFINITE, QS_ALLEVENTS);
  SetEvent (hWokenUpEvent);
}

static gint
_gst_wakeup ()
{
  idle = false;
  SetEvent (hWakeUpEvent);
}
#endif
#else
#define gst_glib_poll g_poll
#endif


static void
main_context_acquire_wait (GMainContext *context)
{
  while (!g_main_context_wait (context, cond, mutex));
}

static void
main_context_signal (GMainContext *context)
{
  /* Restart the polling thread.  Note that #iterate is asynchronous, so
     this might execute before the Smalltalk code finishes running!  This
     allows debugging GTK+ signal handlers.  */
  g_mutex_lock (mutex);
  queued = false;
  g_cond_broadcast (cond_dispatch);
  g_mutex_unlock (mutex);
}

static GPollFD *fds;
static int allocated_nfds, nfds;
static int maxprio;

static void
main_context_iterate (GMainContext *context)
{
  g_mutex_lock (mutex);
  if (!fds)
    {
      g_mutex_unlock (mutex);
      return;
    }

  /* No need to keep the mutex except during g_main_context_acquire_wait
     and g_main_context_release_signal, i.e. except while we operate on
     cond.  */
  main_context_acquire_wait (context);
  g_mutex_unlock (mutex);
  g_main_context_check (context, maxprio, fds, nfds);
  g_main_context_dispatch (context);
  g_main_context_release (context);
  main_context_signal (context);
}

static gpointer
main_loop_thread (gpointer semaphore)
{
  OOP semaphoreOOP = semaphore;
  GMainContext *context = g_main_loop_get_context (loop);

  if (!fds)
    {
      fds = g_new (GPollFD, 20);
      allocated_nfds = 20;
    }

  /* Mostly based on g_main_context_iterate (a static function in gmain.c)
     except that we have to use our own mutex and that g_main_context_dispatch
     is replaced by signaling semaphoreOOP.  */

  g_mutex_lock (mutex);
  while (g_main_loop_is_running (loop))
    {
      int timeout;

      main_context_acquire_wait (context);
      g_main_context_prepare (context, &maxprio);
      while ((nfds = g_main_context_query (context, maxprio,
                                           &timeout, fds, allocated_nfds))
             > allocated_nfds)
        {
          g_free (fds);
          fds = g_new (GPollFD, nfds);
          allocated_nfds = nfds;
        }

      /* Release the context so that the other thread can dispatch while
         this one polls.  g_main_context_release unlocks the mutex for us.  */
      g_mutex_unlock (mutex);
      g_main_context_release (context);

      gst_glib_poll (fds, nfds, timeout);

      /* Dispatch on the other thread and wait for it to rendez-vous.  */
      g_mutex_lock (mutex);
      queued = true;
      _glib_vm_proxy->asyncSignal (semaphoreOOP);
      
      /* TODO: shouldn't be necessary.  */
      _glib_vm_proxy->wakeUp ();
      while (queued)
        g_cond_wait (cond_dispatch, mutex);
    }

  g_main_loop_unref (loop);
  loop = NULL;
  thread = NULL;
  g_mutex_unlock (mutex);

  /* TODO: Not thread-safe! */
  _glib_vm_proxy->unregisterOOP (semaphoreOOP);
  return NULL;
}

GMainLoop *
create_main_loop_thread (OOP semaphore)
{
  if (!mutex)
    {
      /* One-time initialization.  */
      mutex = g_mutex_new ();
      cond = g_cond_new ();
      cond_dispatch = g_cond_new ();
    }

  g_mutex_lock (mutex);
  if (loop)
    {
      /* A loop exists.  If it is exiting, wait for it, otherwise
         leave immediately.  */
      GThread *loop_thread = thread;
      gboolean exiting = g_main_loop_is_running (loop);
      g_mutex_unlock (mutex);
      if (!exiting)
        return NULL;
      if (loop_thread)
        g_thread_join (loop_thread);
    }
  else
    g_mutex_unlock (mutex);

  _glib_vm_proxy->registerOOP (semaphore);
  loop = g_main_loop_new (NULL, TRUE);

  /* Add a second reference to be released when the thread exits.  The first
     one is passed to Smalltalk ("return loop" below).  */
  g_main_loop_ref (loop);
  thread = g_thread_create (main_loop_thread, semaphore, TRUE, NULL);
  if (!thread)
    {
      /* Destroy both references, since the thread won't have any occasion
         to release his.  */
      g_main_loop_unref (loop);
      g_main_loop_unref (loop);
      return NULL;
    }

  return loop;
}

/* Wrappers for GValue users.  */
OOP
object_get_property (GObject *anObject,
		     const char *aProperty)
{
  GParamSpec *spec;
  GValue result = {0,};
  GObject *obj;

  obj = G_OBJECT (anObject);
  spec = g_object_class_find_property (G_OBJECT_GET_CLASS(obj), aProperty);
  g_value_init (&result, spec->value_type);
  g_object_get_property (obj, aProperty, &result);
  return (g_value_convert_to_oop (&result));
}

void
object_set_property (GObject *anObject,
		     const char *aProperty,
		     OOP aValue)
{
  GParamSpec *spec;
  GObject *obj;
  GValue value = {0,};

  obj = G_OBJECT (anObject);
  spec = g_object_class_find_property (G_OBJECT_GET_CLASS(obj), aProperty);
  g_value_init (&value, spec->value_type);
  g_value_fill_from_oop (&value, aValue);
  g_object_set_property (obj, aProperty, &value);
}

void my_log_handler (const gchar * log_domain,
		     GLogLevelFlags log_level,
		     const gchar * message, gpointer unused_data)
{
  /* Do not pass fatal flags so that we can show the backtrace.  */
  g_log_default_handler (log_domain, log_level & G_LOG_LEVEL_MASK, message,
			 unused_data);

  switch ((log_level & G_LOG_FATAL_MASK) ? G_LOG_LEVEL_ERROR : log_level)
    {
    case G_LOG_LEVEL_ERROR:
    case G_LOG_LEVEL_CRITICAL:
    case G_LOG_LEVEL_WARNING:
    case G_LOG_LEVEL_MESSAGE:
      _glib_vm_proxy->showBacktrace (stderr);
       break;

    default:
      _glib_vm_proxy->showBacktrace (stdout);
       break;
    }

  if (log_level & G_LOG_FATAL_MASK)
    abort ();
}

/* Initialization.  */
 
static int initialized = 0;

int
gst_gtk_initialized ()
{
  return initialized;
}

static void
gst_log_set_handler(const gchar *component)
{
  g_log_set_handler (component,
		     G_LOG_LEVEL_WARNING | G_LOG_LEVEL_CRITICAL
		     | G_LOG_LEVEL_ERROR
		     | G_LOG_FLAG_FATAL | G_LOG_FLAG_RECURSION,
		     my_log_handler, NULL);
}

int
gst_type_oop ()
{
  return G_TYPE_OOP;
}

void
gst_initModule (proxy)
     VMProxy *proxy;
{
  if (initialized && !g_thread_supported ())
    g_thread_init (NULL);

  gst_gobject_init ();
  gst_log_set_handler (NULL);
  gst_log_set_handler ("Gtk");
  gst_log_set_handler ("GLib");

  _glib_vm_proxy = proxy;
  _glib_vm_proxy->defineCFunc ("gtkInitialized", gst_gtk_initialized);
  _glib_vm_proxy->defineCFunc ("gstTypeOOP", gst_type_oop);
  _glib_vm_proxy->defineCFunc ("gstGtkRegisterForType", register_for_type);
  _glib_vm_proxy->defineCFunc ("gstGtkFreeGObjectOOP", g_object_detach_oop);
  _glib_vm_proxy->defineCFunc ("gstGtkNarrowGObjectOOP", g_object_narrow_oop);
  _glib_vm_proxy->defineCFunc ("gstGtkConnectSignal", connect_signal);
  _glib_vm_proxy->defineCFunc ("gstGtkConnectSignalNoUserData", connect_signal_no_user_data);
  _glib_vm_proxy->defineCFunc ("gstGtkConnectSignalAfter", connect_signal_after);
  _glib_vm_proxy->defineCFunc ("gstGtkConnectSignalAfterNoUserData", connect_signal_after_no_user_data);
  _glib_vm_proxy->defineCFunc ("gstGtkMain", create_main_loop_thread);
  _glib_vm_proxy->defineCFunc ("gstGtkMainContextIterate", main_context_iterate);
  _glib_vm_proxy->defineCFunc ("gstGtkGetProperty", object_get_property);
  _glib_vm_proxy->defineCFunc ("gstGtkSetProperty", object_set_property);
  _glib_vm_proxy->dlPushSearchPath ();
#include "libs.def"
  _glib_vm_proxy->dlPopSearchPath ();
}
