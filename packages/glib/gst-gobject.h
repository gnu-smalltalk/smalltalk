/***********************************************************************
 *
 *  GObject/GNU Smalltalk wrapper library definitions
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2011 Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#ifndef LIB_GST_GLIB_H
#define LIB_GST_GLIB_H 1

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

typedef struct SmalltalkClosure
{
  GClosure closure;
  OOP      receiver;
  OOP      selector;
  OOP      data;
  OOP      widget;
  int      n_params;
} SmalltalkClosure;

extern GQuark q_gst_object;

extern GType G_TYPE_OOP;

/* Add a reference to OBJ and attach the Smalltalk objcet OOP to it, so
   that g_object_get_oop will return it.  */
extern void g_object_attach_oop (GObject *obj, OOP oop);

/* Unref OBJ and detach it from the Smalltalk object that has represented
   it so far.  */
extern void g_object_detach_oop (GObject *obj);

/* If no Smalltalk object has represented OBJ so far, change OOP's class
   to be the correct one, ref the object, mark it as finalizable, and
   answer OOP; otherwise answer the pre-existing object.  */
extern OOP g_object_narrow_oop (GObject *obj,
				OOP oop);

/* Answer a Smalltalk object that can represent OBJ.  This is the same
   as narrow_oop_for_g_object, but creates a new OOP if no Smalltalk
   object has represented OBJ so far.  */
extern OOP g_object_get_oop (GObject *obj);

/* Answer a Smalltalk object that can represent the boxed value OBJ.
   This needs to know the TYPE of the value because GBoxed values don't
   know their type.  */
extern OOP g_boxed_get_oop (gpointer obj,
			    GType type);

/* Store in a quark that OBJ is represented by the Smalltalk object OOP.  */
extern void g_object_attach_oop (GObject *obj,
				    OOP oop);

/* Convert the GValue, VAL, to a Smalltalk object.  */
extern OOP g_value_convert_to_oop (const GValue *val);

/* Store the value represented by OOP into the GValue, VAL.  */
extern void g_value_fill_from_oop (GValue *val,
				   OOP oop);

/* Create a GClosure that invokes the selector, SELECTOR, on the given
   object.  DATA is inserted as the second parameter (or is passed as the
   only one is the closure's arity is 0).  */
extern GClosure *smalltalk_closure_new (OOP receiver,	
					OOP selector,
					OOP data,
					OOP widget,
					int n_params);

/* A wrapper around g_signal_connect_closure that looks up the
   selector and creates a Smalltalk GClosure.  */
extern int g_signal_connect_smalltalk_closure (OOP widget, 
			   char *event_name, 
			   OOP receiver, 
			   OOP selector,
			   OOP user_data,
                           gboolean after);

extern void gst_gobject_init (void);

#endif
