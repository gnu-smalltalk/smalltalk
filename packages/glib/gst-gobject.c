/***********************************************************************
 *
 *  GObject/GNU Smalltalk wrapper library
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2003, 2006, 2008, 2009, 2011 Free Software Foundation, Inc.
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
#include "gst-gobject.h"

GType G_TYPE_OOP;
GQuark q_gst_object;

static VMProxy *_glib_vm_proxy;

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
      _glib_vm_proxy->unregisterOOP ((OOP) value->data[0].v_pointer);
}

static void
g_type_oop_value_copy (const GValue *src_value,
                        GValue       *dest_value)
{
  _glib_vm_proxy->registerOOP ((OOP) src_value->data[0].v_pointer);
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

void
set_vm_proxy (VMProxy *vm_proxy)
{
  _glib_vm_proxy =  vm_proxy;
  g_type_init ();
  q_gst_object = g_quark_from_string ("gst_object");
  gtype_oop_info.value_table = &gtype_oop_value_table;
  G_TYPE_OOP = g_type_register_static (G_TYPE_BOXED, "OOP", &gtype_oop_info, 0);

}

/* GObject wrapper.  */
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
  _glib_vm_proxy->strMsgSend (oop, "addToBeFinalized", NULL);
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
  OOP oop = _glib_vm_proxy->cObjectToOOP(obj);
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
      oop = _glib_vm_proxy->cObjectToOOP(obj);
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
      return _glib_vm_proxy->charToOOP(v_char);

    case G_TYPE_BOOLEAN:
      v_boolean = g_value_get_boolean (val);
      return _glib_vm_proxy->boolToOOP(v_boolean);

    case G_TYPE_UCHAR:
      v_int = g_value_get_uchar (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_INT:
      v_int = g_value_get_int (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_UINT:
      v_int = g_value_get_uint (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_LONG:
      v_int = g_value_get_long (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_ULONG:
      v_int = g_value_get_ulong (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_ENUM:
      v_int = g_value_get_enum (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_FLAGS:
      v_int = g_value_get_flags (val);
      return _glib_vm_proxy->intToOOP(v_int);

    case G_TYPE_FLOAT:
      v_float = g_value_get_float (val);
      return _glib_vm_proxy->floatToOOP(v_float);

    case G_TYPE_DOUBLE:
      v_float = g_value_get_double (val);
      return _glib_vm_proxy->floatToOOP(v_float);

    case G_TYPE_STRING:
      v_ptr = (gpointer) g_value_get_string (val);
      return _glib_vm_proxy->stringToOOP(v_ptr);

    case G_TYPE_POINTER:
      v_ptr = g_value_get_pointer (val);
      return _glib_vm_proxy->cObjectToOOP(v_ptr);

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
    _glib_vm_proxy->registerOOP (oop);
    g_value_set_boxed (return_value, (gpointer)oop);
    return ;
  }

  switch (fundamental)
    {
    case G_TYPE_NONE:
    case G_TYPE_INVALID:
      break;

    case G_TYPE_CHAR:
      v_char = _glib_vm_proxy->OOPToChar (oop);
      g_value_set_char (return_value, v_char);
      break;

    case G_TYPE_BOOLEAN:
      v_boolean = _glib_vm_proxy->OOPToBool (oop);
      g_value_set_boolean (return_value, v_boolean);
      break;

    case G_TYPE_UCHAR:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_uchar (return_value, v_int);
      break;

    case G_TYPE_INT:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_int (return_value, v_int);
      break;

    case G_TYPE_UINT:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_uint (return_value, v_int);
      break;

    case G_TYPE_LONG:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_long (return_value, v_int);
      break;

    case G_TYPE_ULONG:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_ulong (return_value, v_int);
      break;

    case G_TYPE_ENUM:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_enum (return_value, v_int);
      break;

    case G_TYPE_FLAGS:
      v_int = _glib_vm_proxy->OOPToInt (oop);
      g_value_set_flags (return_value, v_int);
      break;

    case G_TYPE_FLOAT:
      v_float = _glib_vm_proxy->OOPToFloat (oop);
      g_value_set_float (return_value, v_float);
      break;

    case G_TYPE_DOUBLE:
      v_float = _glib_vm_proxy->OOPToFloat (oop);
      g_value_set_double (return_value, v_float);
      break;

    case G_TYPE_STRING:
      v_ptr = _glib_vm_proxy->OOPToString (oop);
      g_value_set_string_take_ownership (return_value, v_ptr);
      break;

    case G_TYPE_POINTER:
      v_ptr = _glib_vm_proxy->OOPToCObject (oop);
      g_value_set_pointer (return_value, v_ptr);
      break;

    case G_TYPE_BOXED:
      v_ptr = _glib_vm_proxy->OOPToCObject (oop);
      g_value_set_boxed (return_value, v_ptr);
      break;

    case G_TYPE_OBJECT:
    case G_TYPE_INTERFACE:
      v_ptr = _glib_vm_proxy->OOPToCObject (oop);
      g_value_set_object (return_value, v_ptr);
      break;

    default:
      fprintf (stderr, "Invalid type.");
      abort ();
    }
}

static void
finalize_smalltalk_closure (gpointer      data,
			    GClosure     *closure)
{
  SmalltalkClosure *stc = (SmalltalkClosure *) closure;

  _glib_vm_proxy->unregisterOOP (stc->receiver);
  _glib_vm_proxy->unregisterOOP (stc->widget);
  if (stc->data)
    _glib_vm_proxy->unregisterOOP (stc->data);
}

static void
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

  resultOOP = _glib_vm_proxy->nvmsgSend (stc->receiver, stc->selector, args, i);

  /* FIXME Need to init return_value's type? */
  if (return_value)
    fill_g_value_from_oop (return_value, resultOOP);
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

  _glib_vm_proxy->registerOOP (receiver);
  _glib_vm_proxy->registerOOP (widget);
  if (data)
    _glib_vm_proxy->registerOOP (data);

  stc->receiver = receiver;
  stc->selector = selector;
  stc->data = data;
  stc->widget = widget;
  stc->n_params = n_params;

  g_closure_set_marshal (closure, invoke_smalltalk_closure);
  g_closure_add_finalize_notifier (closure, NULL, finalize_smalltalk_closure);
  return closure;
}

/* Signal implementation.  */
int
connect_signal (OOP widget, 
		char *event_name, 
		OOP receiver, 
		OOP selector,
		OOP user_data)
{
  GObject      *gObject = _glib_vm_proxy->OOPToCObject (widget);
  GClosure     *closure;
  GSignalQuery  qry;
  guint         sig_id;
  int		n_params;
  OOP           oop_sel_args;

  /* Check parameters */
  if (!G_IS_OBJECT(gObject))
     return (-1); /* Invalid widget passed */

  sig_id = g_signal_lookup (event_name, G_OBJECT_TYPE(gObject));
  if (sig_id == 0) 
    return (-2); /* Invalid event name */

  g_signal_query (sig_id, &qry);
  oop_sel_args = _glib_vm_proxy->strMsgSend (selector, "numArgs", NULL);
  if (oop_sel_args == _glib_vm_proxy->nilOOP)
    return (-3); /* Invalid selector */ 

  /* Check the number of arguments in the selector against the number of 
     arguments in the event callback */
  /* We can return fewer arguments than are in the event, if the others aren't 
     wanted, but we can't return more, and returning nilOOPs instead is not 
     100% satisfactory, so fail. */
  n_params = _glib_vm_proxy->OOPToInt (oop_sel_args);
  if (n_params - qry.n_params > 2)
    return (-4);

  /* Receiver is assumed to be OK, no matter what it is */
  /* Parameters OK, so carry on and connect the signal */
  
  widget = narrow_oop_for_g_object (gObject, widget);
  closure = create_smalltalk_closure (receiver, selector, user_data,
                                     widget, n_params);

  return g_signal_connect_closure (gObject, event_name, closure, FALSE);
}
