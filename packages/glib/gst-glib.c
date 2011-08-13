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
static GSList *loop_list;
static GPollFD *fds;
static int allocated_nfds, nfds;
static int maxprio;

static void
main_loop_dispatch (void)
{
  GMainContext *context = g_main_loop_get_context (loop);
  if (!g_main_context_acquire (context))
    abort ();

  g_main_context_dispatch (context);
  g_main_context_release (context);
}

static mst_Boolean
main_loop_poll (int ms)
{
  GMainContext *context;
  int timeout;

  if (!loop || !g_main_loop_is_running (loop))
    return FALSE;

  if (!fds)
    {
      fds = g_new (GPollFD, 20);
      allocated_nfds = 20;
    }

  context = g_main_loop_get_context (loop);
  if (!g_main_context_acquire (context))
    abort ();

  timeout = -1;
  g_main_context_prepare (context, &maxprio);
  while ((nfds = g_main_context_query (context, maxprio,
                                       &timeout, fds, allocated_nfds))
         > allocated_nfds)
    {
      g_free (fds);
      fds = g_new (GPollFD, nfds);
      allocated_nfds = nfds;
    }

  if (ms != -1 && (timeout == -1 || timeout > ms))
    timeout = ms;

  g_main_context_release (context);
#ifdef G_WIN32_MSG_HANDLE
  g_poll (fds, nfds, timeout);
#else
  poll ((struct pollfd *) fds, nfds, timeout);
#endif
  return g_main_context_check (context, maxprio, fds, nfds);
}

GMainLoop *
push_main_loop (void)
{
  loop_list = g_slist_prepend (loop_list, loop);
  loop = g_main_loop_new (NULL, TRUE);

  main_loop_poll (0);

  /* Add a second reference that is passed to Smalltalk.  */
  g_main_loop_ref (loop);
  return loop;
}

GMainLoop *
pop_main_loop (void)
{
  GMainLoop *old_loop = loop;
  loop = loop_list->data;
  loop_list = g_slist_delete_link (loop_list, loop_list);

  /* The Smalltalk code should still have a reference.  If not, it
     ought to ignore the return value.  */
  g_main_loop_unref (old_loop);
  return old_loop;
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
  gst_log_set_handler ("GLib-GObject");

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
  _glib_vm_proxy->defineCFunc ("gstGtkPushMainLoop", push_main_loop);
  _glib_vm_proxy->defineCFunc ("gstGtkPopMainLoop", pop_main_loop);
  _glib_vm_proxy->defineCFunc ("gstGtkGetProperty", object_get_property);
  _glib_vm_proxy->defineCFunc ("gstGtkSetProperty", object_set_property);
  _glib_vm_proxy->dlPushSearchPath ();
#include "libs.def"
  _glib_vm_proxy->dlPopSearchPath ();

  _glib_vm_proxy->setEventLoopHandlers(main_loop_poll, main_loop_dispatch);
}
