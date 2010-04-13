/***********************************************************************
 *
 *  Gtk+ wrappers for GNU Smalltalk
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2003, 2006, 2008, 2009 Free Software Foundation, Inc.
 * Written by Paolo Bonzini, Norman Jordan, Mike S. Anderson.
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

#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <gdk/gdk.h>
#include <gtk/gtk.h>
#include <glib-object.h>
#include <glib.h>

#include <gobject/gvaluecollector.h>

#ifdef G_WIN32_MSG_HANDLE
#include <windows.h>
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

#include "gst-gtk.h"
#include "placer.h"

typedef struct SmalltalkClosure
{
  GClosure closure;
  OOP      receiver;
  OOP      selector;
  OOP      data;
  OOP      widget;
  int      n_params;
} SmalltalkClosure;

static VMProxy *_gst_vm_proxy;

static GQuark q_gst_object = 0;

static GTypeInfo gtype_oop_info = {
  0,                           /* class_size */
  NULL,                        /* base_init */
  NULL,                        /* base_finalize */
  NULL,                        /* class_init */
  NULL,                        /* class_finalize */
  NULL,                        /* class_data */
  0,                           /* instance_size */
  0,                           /* n_preallocs */
  NULL,                        /* instance_init */
  NULL,                        /* value_table */
};

static void
g_type_oop_value_init (GValue *value)
{
  value->data[0].v_pointer = NULL;
}

static void
g_type_oop_value_free (GValue *value)
{
  if (value->data[0].v_pointer)
      _gst_vm_proxy->unregisterOOP ((OOP) value->data[0].v_pointer);
}

static void
g_type_oop_value_copy (const GValue *src_value,
                        GValue       *dest_value)
{
  _gst_vm_proxy->registerOOP ((OOP) src_value->data[0].v_pointer);
  dest_value->data[0].v_pointer = src_value->data[0].v_pointer;
}

static const GTypeValueTable gtype_oop_value_table = {
  g_type_oop_value_init,             /* value_init */
  g_type_oop_value_free,             /* value_free */
  g_type_oop_value_copy,             /* value_copy */
  NULL,                              /* value_peek_pointer */
  NULL,                               /* collect_format */
  NULL,                              /* collect_value */
  NULL,                               /* lcopy_format */
  NULL,                              /* lcopy_value */
};

static GType G_TYPE_OOP;

/* Start the main event loop and then signal OOP.  */
static GMainLoop *create_main_loop_thread (OOP semaphore);

/* Unref OBJ and detach it from the Smalltalk object that has represented
   it so far.  */
static void free_oop_for_g_object (GObject *obj);

/* If no Smalltalk object has represented OBJ so far, change OOP's class
   to be the correct one, ref the object, mark it as finalizable, and
   answer OOP; otherwise answer the pre-existing object.  */
static OOP narrow_oop_for_g_object (GObject *obj,
				    OOP oop);

/* Answer a Smalltalk object that can represent OBJ.  This is the same
   as narrow_oop_for_g_object, but creates a new OOP if no Smalltalk
   object has represented OBJ so far.  */
static OOP get_oop_for_g_object (GObject *obj);

/* Answer a Smalltalk object that can represent the boxed value OBJ.
   This needs to know the TYPE of the value because GBoxed values don't
   know their type.  */
static OOP get_oop_for_g_boxed (gpointer obj,
				GType type);

/* Store in a quark that OBJ is represented by the Smalltalk object OOP.  */
static void associate_oop_to_g_object (GObject *obj,
				       OOP oop);

/* Convert the GValue, VAL, to a Smalltalk object.  */
static OOP convert_g_value_to_oop (const GValue *val);

/* Store the value represented by OOP into the GValue, VAL.  */
static void fill_g_value_from_oop (GValue *val,
				   OOP oop);

/* Create a GClosure that invokes the selector, SELECTOR, on the given
   object.  DATA is inserted as the second parameter (or is passed as the
   only one is the closure's arity is 0).  */
static GClosure *create_smalltalk_closure (OOP receiver,	
					   OOP selector,
					   OOP data,
					   OOP widget,
					   int n_params);

/* The finalization notifier for Smalltalk GClosures.  Unregisters the
   receiver and user data for the CLOSURE.  */
static void finalize_smalltalk_closure (gpointer      data,
				        GClosure     *closure);

/* The marshalling routine for Smalltalk GClosures.  */
static void invoke_smalltalk_closure (GClosure     *closure,
				      GValue       *return_value,
				      guint         n_param_values,
				      const GValue *param_values,
				      gpointer      invocation_hint,
				      gpointer      marshal_data);

/* A wrapper around g_signal_connect_closure that looks up the
   selector and creates a Smalltalk GClosure.  */
static int connect_signal (OOP widget, 
			    char *event_name, 
			    OOP receiver, 
			    OOP selector,
			    OOP user_data);

/* A wrapper around g_signal_connect_closure that looks up the
   selector and creates a Smalltalk GClosure.  */
static int connect_signal_no_user_data (OOP widget, 
					char *event_name, 
					OOP receiver, 
					OOP selector);

/* A wrapper around g_object_get_property that replaces GValues with OOPs.  */
static OOP object_get_property (GObject *anObject,
				const char *aProperty);

/* A wrapper around g_object_set_property that replaces GValues with OOPs.  */
static void object_set_property (GObject *anObject,
				 const char *aProperty,
				 OOP aValue);

/* A wrapper around gtk_container_child_get_property that replaces GValues
   with OOPs.  */
static OOP container_get_child_property (GtkContainer *aParent,
					 GtkWidget *anObject,
					 const char *aProperty);

/* A wrapper around gtk_container_child_set_property that replaces GValues
   with OOPs.  */
static void container_set_child_property (GtkContainer *aParent,
					  GtkWidget *anObject,
					  const char *aProperty,
					  OOP aValue);

/* GObject wrapper.  */
void
register_for_type (OOP oop, GType type)
{
  _gst_vm_proxy->registerOOP (oop);
  g_type_set_qdata (type, q_gst_object, oop);
}

void
free_oop_for_g_object (GObject *obj)
{
  g_object_set_qdata (obj, q_gst_object, NULL);
  g_object_unref (obj);
}

void
associate_oop_to_g_object (GObject *obj, OOP oop)
{
  OOP class = g_type_get_qdata (G_OBJECT_TYPE (obj), q_gst_object);

  if (class)
    OOP_TO_OBJ (oop)->objClass = class;

  g_object_set_qdata (obj, q_gst_object, oop);
  g_object_ref (obj);
  _gst_vm_proxy->strMsgSend (oop, "addToBeFinalized", NULL);
}

OOP
narrow_oop_for_g_object (GObject *obj, OOP oop)
{
  OOP preexistingOOP;
  if (!(preexistingOOP = g_object_get_qdata (obj, q_gst_object)))
    {
      associate_oop_to_g_object (obj, oop);
      return oop;
    }
  else
    return preexistingOOP;
}

OOP
get_oop_for_g_boxed (gpointer obj, GType type)
{
  OOP oop = _gst_vm_proxy->cObjectToOOP(obj);
  OOP class = g_type_get_qdata (type, q_gst_object);

  if (class)
    OOP_TO_OBJ (oop)->objClass = class;

  return oop;
}

OOP
get_oop_for_g_object (GObject *obj)
{
  OOP oop;
  if (!(oop = g_object_get_qdata (obj, q_gst_object)))
    {
      /* We don't have a wrapper for it, so create it.  Get the class
	 from the object's type.  */
      oop = _gst_vm_proxy->cObjectToOOP(obj);
      associate_oop_to_g_object (obj, oop);
    }

  return oop;
}

/* SmalltalkClosure implementation.  */
OOP
convert_g_value_to_oop (const GValue *val)
{
  GType type = G_VALUE_TYPE (val);
  GType fundamental;

  char v_char;
  gboolean v_boolean;
  gpointer v_ptr;
  long v_int;
  double v_float;

  if (G_TYPE_IS_FUNDAMENTAL (type))
    fundamental = type;
  else
    fundamental = G_TYPE_FUNDAMENTAL (type);

  if (type == G_TYPE_OOP) {
      v_ptr = g_value_get_boxed (val);
      return (OOP) v_ptr;
  }

  switch (fundamental)
    {
    case G_TYPE_CHAR:
      v_char = g_value_get_char (val);
      return _gst_vm_proxy->charToOOP(v_char);

    case G_TYPE_BOOLEAN:
      v_boolean = g_value_get_boolean (val);
      return _gst_vm_proxy->boolToOOP(v_boolean);

    case G_TYPE_UCHAR:
      v_int = g_value_get_uchar (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_INT:
      v_int = g_value_get_int (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_UINT:
      v_int = g_value_get_uint (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_LONG:
      v_int = g_value_get_long (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_ULONG:
      v_int = g_value_get_ulong (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_ENUM:
      v_int = g_value_get_enum (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_FLAGS:
      v_int = g_value_get_flags (val);
      return _gst_vm_proxy->intToOOP(v_int);

    case G_TYPE_FLOAT:
      v_float = g_value_get_float (val);
      return _gst_vm_proxy->floatToOOP(v_float);

    case G_TYPE_DOUBLE:
      v_float = g_value_get_double (val);
      return _gst_vm_proxy->floatToOOP(v_float);

    case G_TYPE_STRING:
      v_ptr = (gpointer) g_value_get_string (val);
      return _gst_vm_proxy->stringToOOP(v_ptr);

    case G_TYPE_POINTER:
      v_ptr = g_value_get_pointer (val);
      return _gst_vm_proxy->cObjectToOOP(v_ptr);

    case G_TYPE_BOXED:
      v_ptr = g_value_get_boxed (val);
      return get_oop_for_g_boxed (v_ptr, type);

    case G_TYPE_OBJECT:
    case G_TYPE_INTERFACE:
      v_ptr = g_value_get_object (val);
      if (fundamental == type
	  || G_TYPE_CHECK_INSTANCE_TYPE (v_ptr, type))
	return get_oop_for_g_object (v_ptr);

    default:
      return NULL;
    }
}

void
fill_g_value_from_oop (GValue *return_value, OOP oop)
{
  GType type = G_VALUE_TYPE (return_value);
  GType fundamental;

  char v_char;
  gboolean v_boolean;
  gpointer v_ptr;
  long v_int;
  double v_float;

  if (G_TYPE_IS_FUNDAMENTAL (type))
    fundamental = type;
  else
    fundamental = G_TYPE_FUNDAMENTAL (type);


  if (type == G_TYPE_OOP) {
    _gst_vm_proxy->registerOOP (oop);
    g_value_set_boxed (return_value, (gpointer)oop);
    return ;
  }

  switch (fundamental)
    {
    case G_TYPE_NONE:
    case G_TYPE_INVALID:
      break;

    case G_TYPE_CHAR:
      v_char = _gst_vm_proxy->OOPToChar (oop);
      g_value_set_char (return_value, v_char);
      break;

    case G_TYPE_BOOLEAN:
      v_boolean = _gst_vm_proxy->OOPToBool (oop);
      g_value_set_boolean (return_value, v_boolean);
      break;

    case G_TYPE_UCHAR:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_uchar (return_value, v_int);
      break;

    case G_TYPE_INT:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_int (return_value, v_int);
      break;

    case G_TYPE_UINT:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_uint (return_value, v_int);
      break;

    case G_TYPE_LONG:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_long (return_value, v_int);
      break;

    case G_TYPE_ULONG:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_ulong (return_value, v_int);
      break;

    case G_TYPE_ENUM:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_enum (return_value, v_int);
      break;

    case G_TYPE_FLAGS:
      v_int = _gst_vm_proxy->OOPToInt (oop);
      g_value_set_flags (return_value, v_int);
      break;

    case G_TYPE_FLOAT:
      v_float = _gst_vm_proxy->OOPToFloat (oop);
      g_value_set_float (return_value, v_float);
      break;

    case G_TYPE_DOUBLE:
      v_float = _gst_vm_proxy->OOPToFloat (oop);
      g_value_set_double (return_value, v_float);
      break;

    case G_TYPE_STRING:
      v_ptr = _gst_vm_proxy->OOPToString (oop);
      g_value_set_string_take_ownership (return_value, v_ptr);
      break;

    case G_TYPE_POINTER:
      v_ptr = _gst_vm_proxy->OOPToCObject (oop);
      g_value_set_pointer (return_value, v_ptr);
      break;

    case G_TYPE_BOXED:
      v_ptr = _gst_vm_proxy->OOPToCObject (oop);
      g_value_set_boxed (return_value, v_ptr);
      break;

    case G_TYPE_OBJECT:
    case G_TYPE_INTERFACE:
      v_ptr = _gst_vm_proxy->OOPToCObject (oop);
      g_value_set_object (return_value, v_ptr);
      break;

    default:
      fprintf (stderr, "Invalid type.");
      abort ();
    }
}

GClosure *
create_smalltalk_closure (OOP receiver,	
			  OOP selector,
			  OOP data,
			  OOP widget,
			  int n_params)
{
  GClosure *closure = g_closure_new_simple (sizeof (SmalltalkClosure), NULL);
  SmalltalkClosure *stc = (SmalltalkClosure *) closure;

  _gst_vm_proxy->registerOOP (receiver);
  _gst_vm_proxy->registerOOP (widget);
  if (data)
    _gst_vm_proxy->registerOOP (data);

  stc->receiver = receiver;
  stc->selector = selector;
  stc->data = data;
  stc->widget = widget;
  stc->n_params = n_params;

  g_closure_set_marshal (closure, invoke_smalltalk_closure);
  g_closure_add_finalize_notifier (closure, NULL, finalize_smalltalk_closure);
  return closure;
}

void
finalize_smalltalk_closure (gpointer      data,
			    GClosure     *closure)
{
  SmalltalkClosure *stc = (SmalltalkClosure *) closure;

  _gst_vm_proxy->unregisterOOP (stc->receiver);
  _gst_vm_proxy->unregisterOOP (stc->widget);
  if (stc->data)
    _gst_vm_proxy->unregisterOOP (stc->data);
}

void
invoke_smalltalk_closure (GClosure     *closure,
			  GValue       *return_value,
			  guint         n_param_values,
			  const GValue *param_values,
			  gpointer      invocation_hint,
			  gpointer      marshal_data)
{
  SmalltalkClosure *stc = (SmalltalkClosure *) closure;
  OOP *args = alloca (sizeof (OOP) * stc->n_params);

  OOP resultOOP;
  int i;

  /* Less parameters than the event has, discard the ones in excess.  */
  if (stc->n_params < n_param_values)
    n_param_values = stc->n_params;

  /* Maintain the Gtk order of parameters, even if we end up discarding 
     the sender (first parameter, usually) most of the time */
  for (i = 0; i < n_param_values; i++)
    {
      OOP oop = convert_g_value_to_oop (&param_values[i]);
      if (!oop)
	{
	  fprintf (stderr, "Invalid type, signal discarded.\n");
	  
	  if (return_value->g_type == G_TYPE_NONE)
	    return;
	  else
	    abort ();
	}
      args[i] = oop;
    }

  if (stc->data)
    {
      if (stc->n_params > n_param_values + 1)
        args[i++] = stc->widget;
      if (stc->n_params > n_param_values)
        args[i++] = stc->data;
    }
  else
    {
      if (stc->n_params > n_param_values)
        args[i++] = stc->widget;
    }

  resultOOP = _gst_vm_proxy->nvmsgSend (stc->receiver, stc->selector, args, i);

  /* FIXME Need to init return_value's type? */
  if (return_value)
    fill_g_value_from_oop (return_value, resultOOP);
}

/* Signal implementation.  */
int
connect_signal (OOP widget, 
		char *event_name, 
		OOP receiver, 
		OOP selector,
		OOP user_data)
{
  GtkWidget    *cWidget = _gst_vm_proxy->OOPToCObject (widget);
  GClosure     *closure;
  GSignalQuery  qry;
  guint         sig_id;
  int		n_params;
  OOP           oop_sel_args;

  /* Check parameters */
  if (!G_IS_OBJECT(cWidget))
     return (-1); /* Invalid widget passed */

  sig_id = g_signal_lookup (event_name, G_OBJECT_TYPE(G_OBJECT(cWidget)));
  if (sig_id == 0) 
    return (-2); /* Invalid event name */

  g_signal_query (sig_id, &qry);
  oop_sel_args = _gst_vm_proxy->strMsgSend (selector, "numArgs", NULL);
  if (oop_sel_args == _gst_vm_proxy->nilOOP)
    return (-3); /* Invalid selector */ 

  /* Check the number of arguments in the selector against the number of 
     arguments in the event callback */
  /* We can return fewer arguments than are in the event, if the others aren't 
     wanted, but we can't return more, and returning nilOOPs instead is not 
     100% satisfactory, so fail. */
  n_params = _gst_vm_proxy->OOPToInt (oop_sel_args);
  if (n_params - qry.n_params > 2)
    return (-4);

  /* Receiver is assumed to be OK, no matter what it is */
  /* Parameters OK, so carry on and connect the signal */
  
  widget = narrow_oop_for_g_object (G_OBJECT (cWidget), widget);
  closure = create_smalltalk_closure (receiver, selector, user_data,
                                     widget, n_params);

  return g_signal_connect_closure (cWidget, event_name, closure, FALSE);
}

int
connect_signal_no_user_data (OOP widget, 
			     char *event_name, 
			     OOP receiver, 
			     OOP selector)
{
  return connect_signal (widget, event_name, receiver, selector, NULL);
}

static int
connect_accel_group (OOP accel_group,
                     guint accel_key,
                     GdkModifierType accel_mods,
                     GtkAccelFlags accel_flags,
                     OOP receiver,
                     OOP selector,
		     OOP user_data)
{
  GtkAccelGroup *cObject = _gst_vm_proxy->OOPToCObject (accel_group);
  int n_params;
  GClosure *closure;
  OOP oop_sel_args;

  oop_sel_args = _gst_vm_proxy->strMsgSend (selector, "numArgs", NULL);
  if (oop_sel_args == _gst_vm_proxy->nilOOP)
    return (-3); /* Invalid selector */

  /* Check the number of arguments in the selector against the number of
     arguments in the event callback */

  /* We can return fewer arguments than are in the event, if the others aren't
     wanted, but we can't return more, and returning nilOOPs instead is not
     100% satisfactory, so fail. */
  n_params = _gst_vm_proxy->OOPToInt (oop_sel_args);
  if (n_params > 4)
    return (-4);

  /* Receiver is assumed to be OK, no matter what it is */
  /* Parameters OK, so carry on and connect the signal */

  accel_group = narrow_oop_for_g_object (G_OBJECT (cObject), accel_group);

  closure = create_smalltalk_closure (receiver, selector, NULL,
                                      accel_group, n_params);
  gtk_accel_group_connect (cObject, accel_key, accel_mods, accel_flags, closure);
  return 0;
}

static int
connect_accel_group_no_user_data (OOP accel_group,
		                  guint accel_key,
		                  GdkModifierType accel_mods,
		                  GtkAccelFlags accel_flags,
		                  OOP receiver,
		                  OOP selector)
{
  return connect_accel_group (accel_group, accel_key, accel_mods,
		              accel_flags, receiver, selector, NULL);
}

/* Event loop.  The GTK+ event loop in GNU Smalltalk is split between two
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
gst_gtk_poll (GPollFD *fds,
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
#define gst_gtk_poll g_poll
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

      gst_gtk_poll (fds, nfds, timeout);

      /* Dispatch on the other thread and wait for it to rendez-vous.  */
      g_mutex_lock (mutex);
      queued = true;
      _gst_vm_proxy->asyncSignal (semaphoreOOP);
      
      /* TODO: shouldn't be necessary.  */
      _gst_vm_proxy->wakeUp ();
      while (queued)
        g_cond_wait (cond_dispatch, mutex);
    }

  g_main_loop_unref (loop);
  loop = NULL;
  thread = NULL;
  g_mutex_unlock (mutex);

  /* TODO: Not thread-safe! */
  _gst_vm_proxy->unregisterOOP (semaphoreOOP);
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

  _gst_vm_proxy->registerOOP (semaphore);
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
  return (convert_g_value_to_oop (&result));
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
  fill_g_value_from_oop (&value, aValue);
  g_object_set_property (obj, aProperty, &value);
}

OOP
container_get_child_property (GtkContainer *aParent,
			      GtkWidget *aChild,
			      const char *aProperty)
{
  GParamSpec *spec;
  GValue result = {0,};

  g_return_val_if_fail (GTK_WIDGET (aParent) ==
		        gtk_widget_get_parent (GTK_WIDGET (aChild)),
			_gst_vm_proxy->nilOOP);

  spec = gtk_container_class_find_child_property (G_OBJECT_GET_CLASS (aParent),
					          aProperty);

  g_value_init (&result, spec->value_type);
  gtk_container_child_get_property (aParent, aChild, aProperty, &result);
  return (convert_g_value_to_oop (&result));
}

void
container_set_child_property (GtkContainer *aParent,
			      GtkWidget *aChild,
			      const char *aProperty,
			      OOP aValue)
{
  GParamSpec *spec;
  GValue value = {0,};

  g_return_if_fail (GTK_WIDGET (aParent) ==
		    gtk_widget_get_parent (GTK_WIDGET (aChild)));

  spec = gtk_container_class_find_child_property (G_OBJECT_GET_CLASS (aParent),
						  aProperty);

  g_value_init (&value, spec->value_type);
  fill_g_value_from_oop (&value, aValue);
  gtk_container_child_set_property (aParent, aChild, aProperty, &value);
}

OOP 
tree_model_get_oop (GtkTreeModel *model,
		    GtkTreeIter *iter,
		    int col) 
{ 
  GValue gval = { 0 }; 
  OOP result; 

  gtk_tree_model_get_value (model, iter, col, &gval); 
  result = convert_g_value_to_oop (&gval);
  g_value_unset (&gval);
  return (result); 
} 

void 
list_store_set_oop (GtkListStore *store,
		    GtkTreeIter *iter,
		    int col,
		    OOP value) 
{ 
    GValue gval = { 0 };
    g_value_init (&gval,
		  gtk_tree_model_get_column_type (GTK_TREE_MODEL(store), col));
    fill_g_value_from_oop (&gval, value);
    gtk_list_store_set_value (store, iter, col, &gval); 
    g_value_unset (&gval);
} 

void 
tree_store_set_oop (GtkTreeStore *store,
		    GtkTreeIter *iter,
		    int col,
		    OOP value) 
{ 
    GValue gval = { 0 }; 
    g_value_init (&gval, gtk_tree_model_get_column_type (GTK_TREE_MODEL(store), col));
    fill_g_value_from_oop (&gval, value);
    gtk_tree_store_set_value (store, iter, col, &gval); 
    g_value_unset (&gval);
}


/* Wrappers for macros and missing accessor functions.  */

static GdkWindow *
widget_get_window (GtkWidget *widget)
{
  return widget->window;
}

static int
widget_get_state (GtkWidget *widget)
{
  return GTK_WIDGET_STATE (widget);
}

static int
widget_get_flags (GtkWidget *widget)
{
  return GTK_WIDGET_FLAGS (widget);
}

static void
widget_set_flags (GtkWidget *widget, int flags)
{
  GTK_WIDGET_SET_FLAGS (widget, flags);
}

static void
widget_unset_flags (GtkWidget *widget, int flags)
{
  GTK_WIDGET_UNSET_FLAGS (widget, flags);
}


static GtkAllocation *
widget_get_allocation (GtkWidget *wgt)
{
  return &(GTK_WIDGET(wgt)->allocation);
}

static GtkWidget *
dialog_get_vbox (GtkDialog *dlg)
{
  return (GTK_DIALOG(dlg)->vbox);
}

static GtkWidget *
dialog_get_action_area (GtkDialog *dlg)
{
  return (GTK_DIALOG(dlg)->action_area);
}

static int
scrolled_window_get_hscrollbar_visible (GtkScrolledWindow *swnd)
{
  return (GTK_SCROLLED_WINDOW(swnd)->hscrollbar_visible);
}

static int
scrolled_window_get_vscrollbar_visible (GtkScrolledWindow *swnd)
{
  return (GTK_SCROLLED_WINDOW(swnd)->vscrollbar_visible);
}

static int
adjustment_get_lower (GtkAdjustment *adj)
{
  return (GTK_ADJUSTMENT(adj)->lower);
}

static int
adjustment_get_upper (GtkAdjustment *adj)
{
  return (GTK_ADJUSTMENT(adj)->upper);
}

static int
adjustment_get_page_size (GtkAdjustment *adj)
{
  return (GTK_ADJUSTMENT(adj)->page_size);
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
      _gst_vm_proxy->showBacktrace (stderr);
       break;

    default:
      _gst_vm_proxy->showBacktrace (stdout);
       break;
    }

  if (log_level & G_LOG_FATAL_MASK)
    abort ();
}

int
gst_type_oop ()
{
  return G_TYPE_OOP;
}

/* Initialization.  */
 
static int initialized = 0;

int
gst_gtk_initialized ()
{
  return initialized;
}

void
gst_initModule (proxy)
     VMProxy *proxy;
{
  int argc = 1;
  gchar *argvArray[] = { (char *) "gst", NULL };
  gchar **argv = argvArray;

  initialized = gtk_init_check (&argc, &argv);
  if (initialized && !g_thread_supported ())
    {
      g_thread_init (NULL);
      gdk_threads_init ();
    }

  q_gst_object = g_quark_from_string ("gst_object");
  g_type_init ();
  g_log_set_handler (NULL,
		     G_LOG_LEVEL_WARNING | G_LOG_LEVEL_CRITICAL
		     | G_LOG_LEVEL_ERROR
		     | G_LOG_FLAG_FATAL | G_LOG_FLAG_RECURSION,
		     my_log_handler, NULL);
  g_log_set_handler ("Gtk",
		     G_LOG_LEVEL_WARNING | G_LOG_LEVEL_CRITICAL
		     | G_LOG_LEVEL_ERROR
		     | G_LOG_FLAG_FATAL | G_LOG_FLAG_RECURSION,
		     my_log_handler, NULL);
  g_log_set_handler ("GLib",
		     G_LOG_LEVEL_WARNING | G_LOG_LEVEL_CRITICAL
		     | G_LOG_LEVEL_ERROR
		     | G_LOG_FLAG_FATAL | G_LOG_FLAG_RECURSION,
		     my_log_handler, NULL);

  gtype_oop_info.value_table = &gtype_oop_value_table;
  G_TYPE_OOP = g_type_register_static (G_TYPE_BOXED, "OOP", &gtype_oop_info, 0);

  _gst_vm_proxy = proxy;
  _gst_vm_proxy->defineCFunc ("gtkInitialized", gst_gtk_initialized);
  _gst_vm_proxy->defineCFunc ("gstTypeOOP", gst_type_oop);
  _gst_vm_proxy->defineCFunc ("gstGtkRegisterForType", register_for_type);
  _gst_vm_proxy->defineCFunc ("gstGtkFreeGObjectOOP", free_oop_for_g_object);
  _gst_vm_proxy->defineCFunc ("gstGtkNarrowGObjectOOP", narrow_oop_for_g_object);
  _gst_vm_proxy->defineCFunc ("gstGtkConnectAccelGroup", connect_accel_group);
  _gst_vm_proxy->defineCFunc ("gstGtkConnectAccelGroupNoUserData", connect_accel_group_no_user_data);
  _gst_vm_proxy->defineCFunc ("gstGtkConnectSignal", connect_signal);
  _gst_vm_proxy->defineCFunc ("gstGtkConnectSignalNoUserData", connect_signal_no_user_data);
  _gst_vm_proxy->defineCFunc ("gstGtkMain", create_main_loop_thread);
  _gst_vm_proxy->defineCFunc ("gstGtkMainContextIterate", main_context_iterate);
  _gst_vm_proxy->defineCFunc ("gstGtkGetProperty", object_get_property);
  _gst_vm_proxy->defineCFunc ("gstGtkSetProperty", object_set_property);
  _gst_vm_proxy->defineCFunc ("gstGtkGetChildProperty", container_get_child_property);
  _gst_vm_proxy->defineCFunc ("gstGtkSetChildProperty", container_set_child_property);
  _gst_vm_proxy->defineCFunc ("gstGtkGetState", widget_get_state);
  _gst_vm_proxy->defineCFunc ("gstGtkGetFlags", widget_get_flags);
  _gst_vm_proxy->defineCFunc ("gstGtkSetFlags", widget_set_flags);
  _gst_vm_proxy->defineCFunc ("gstGtkUnsetFlags", widget_unset_flags);
  _gst_vm_proxy->defineCFunc ("gstGtkGetWindow", widget_get_window);
  _gst_vm_proxy->defineCFunc ("gstGtkGetHscrollbarVisible", scrolled_window_get_hscrollbar_visible);
  _gst_vm_proxy->defineCFunc ("gstGtkGetVscrollbarVisible", scrolled_window_get_vscrollbar_visible);
  _gst_vm_proxy->defineCFunc ("gstGtkAdjustmentGetLower", adjustment_get_lower);
  _gst_vm_proxy->defineCFunc ("gstGtkAdjustmentGetUpper", adjustment_get_upper);
  _gst_vm_proxy->defineCFunc ("gstGtkAdjustmentGetPageSize", adjustment_get_page_size);
  _gst_vm_proxy->defineCFunc ("gstGtkTreeModelGetOOP", tree_model_get_oop);
  _gst_vm_proxy->defineCFunc ("gstGtkListStoreSetOOP", list_store_set_oop);
  _gst_vm_proxy->defineCFunc ("gstGtkTreeStoreSetOOP", tree_store_set_oop);
  _gst_vm_proxy->defineCFunc ("gstGtkWidgetGetAllocation", widget_get_allocation);
  _gst_vm_proxy->defineCFunc ("gstGtkDialogGetVBox", dialog_get_vbox);
  _gst_vm_proxy->defineCFunc ("gstGtkDialogGetActionArea", dialog_get_action_area);

  _gst_vm_proxy->defineCFunc ("gtk_placer_get_type", gtk_placer_get_type);
  _gst_vm_proxy->defineCFunc ("gtk_placer_new", gtk_placer_new);
  _gst_vm_proxy->defineCFunc ("gtk_placer_put", gtk_placer_put);
  _gst_vm_proxy->defineCFunc ("gtk_placer_move", gtk_placer_move);
  _gst_vm_proxy->defineCFunc ("gtk_placer_resize", gtk_placer_resize);
  _gst_vm_proxy->defineCFunc ("gtk_placer_move_rel", gtk_placer_move_rel);
  _gst_vm_proxy->defineCFunc ("gtk_placer_resize_rel", gtk_placer_resize_rel);
  _gst_vm_proxy->defineCFunc ("gtk_placer_set_has_window", gtk_placer_set_has_window);
  _gst_vm_proxy->defineCFunc ("gtk_placer_get_has_window", gtk_placer_get_has_window);

  _gst_vm_proxy->dlPushSearchPath ();
#include "libs.def"
  _gst_vm_proxy->dlPopSearchPath ();
}
