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
#include "gst-gobject.h"

#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <gdk/gdk.h>
#include <gtk/gtk.h>
#include <glib-object.h>
#include <glib.h>
#include <atk/atk.h>
#include <pango/pango.h>

#include <gobject/gvaluecollector.h>

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

#include "placer.h"

static VMProxy *_gtk_vm_proxy;

static int
connect_accel_group (OOP accel_group,
                     guint accel_key,
                     GdkModifierType accel_mods,
                     GtkAccelFlags accel_flags,
                     OOP receiver,
                     OOP selector,
		     OOP user_data)
{
  GtkAccelGroup *cObject = _gtk_vm_proxy->OOPToCObject (accel_group);
  int n_params;
  GClosure *closure;
  OOP oop_sel_args;

  oop_sel_args = _gtk_vm_proxy->strMsgSend (selector, "numArgs", NULL);
  if (oop_sel_args == _gtk_vm_proxy->nilOOP)
    return (-3); /* Invalid selector */

  /* Check the number of arguments in the selector against the number of
     arguments in the event callback */

  /* We can return fewer arguments than are in the event, if the others aren't
     wanted, but we can't return more, and returning nilOOPs instead is not
     100% satisfactory, so fail. */
  n_params = _gtk_vm_proxy->OOPToInt (oop_sel_args);
  if (n_params > 4)
    return (-4);

  /* Receiver is assumed to be OK, no matter what it is */
  /* Parameters OK, so carry on and connect the signal */

  closure = smalltalk_closure_new (receiver, selector, NULL,
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

OOP
container_get_child_property (GtkContainer *aParent,
			      GtkWidget *aChild,
			      const char *aProperty)
{
  GParamSpec *spec;
  GValue result = {0,};

  g_return_val_if_fail (GTK_WIDGET (aParent) ==
		        gtk_widget_get_parent (GTK_WIDGET (aChild)),
			_gtk_vm_proxy->nilOOP);

  spec = gtk_container_class_find_child_property (G_OBJECT_GET_CLASS (aParent),
					          aProperty);

  g_value_init (&result, spec->value_type);
  gtk_container_child_get_property (aParent, aChild, aProperty, &result);
  return (g_value_convert_to_oop (&result));
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
  g_value_fill_from_oop (&value, aValue);
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
  result = g_value_convert_to_oop (&gval);
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
    g_value_fill_from_oop (&gval, value);
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
    g_value_fill_from_oop (&gval, value);
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

  _gtk_vm_proxy = proxy;
  _gtk_vm_proxy->defineCFunc ("gstGtkConnectAccelGroup", connect_accel_group);
  _gtk_vm_proxy->defineCFunc ("gstGtkConnectAccelGroupNoUserData", connect_accel_group_no_user_data);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetChildProperty", container_get_child_property);
  _gtk_vm_proxy->defineCFunc ("gstGtkSetChildProperty", container_set_child_property);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetState", widget_get_state);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetFlags", widget_get_flags);
  _gtk_vm_proxy->defineCFunc ("gstGtkSetFlags", widget_set_flags);
  _gtk_vm_proxy->defineCFunc ("gstGtkUnsetFlags", widget_unset_flags);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetWindow", widget_get_window);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetHscrollbarVisible", scrolled_window_get_hscrollbar_visible);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetVscrollbarVisible", scrolled_window_get_vscrollbar_visible);
  _gtk_vm_proxy->defineCFunc ("gstGtkAdjustmentGetLower", adjustment_get_lower);
  _gtk_vm_proxy->defineCFunc ("gstGtkAdjustmentGetUpper", adjustment_get_upper);
  _gtk_vm_proxy->defineCFunc ("gstGtkAdjustmentGetPageSize", adjustment_get_page_size);
  _gtk_vm_proxy->defineCFunc ("gstGtkTreeModelGetOOP", tree_model_get_oop);
  _gtk_vm_proxy->defineCFunc ("gstGtkListStoreSetOOP", list_store_set_oop);
  _gtk_vm_proxy->defineCFunc ("gstGtkTreeStoreSetOOP", tree_store_set_oop);
  _gtk_vm_proxy->defineCFunc ("gstGtkWidgetGetAllocation", widget_get_allocation);
  _gtk_vm_proxy->defineCFunc ("gstGtkDialogGetVBox", dialog_get_vbox);
  _gtk_vm_proxy->defineCFunc ("gstGtkDialogGetActionArea", dialog_get_action_area);

  _gtk_vm_proxy->defineCFunc ("gtk_placer_get_type", gtk_placer_get_type);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_new", gtk_placer_new);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_put", gtk_placer_put);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_move", gtk_placer_move);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_resize", gtk_placer_resize);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_move_rel", gtk_placer_move_rel);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_resize_rel", gtk_placer_resize_rel);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_set_has_window", gtk_placer_set_has_window);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_get_has_window", gtk_placer_get_has_window);

  _gtk_vm_proxy->dlPushSearchPath ();
#include "libs.def"
  _gtk_vm_proxy->dlPopSearchPath ();
}
