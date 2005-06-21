/***********************************************************************
 *
 *  Gtk+ bindings for GNU Smalltalk
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003 Free Software Foundation, Inc.
 * Written by Norman Jordan.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
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

#ifndef GST_BLOXGTK_H
#define GST_BLOXGTK_H

#include <glib.h>
#include <glib-object.h>
#include <atk/atk.h>
#include <pango/pango.h>
#include <gdk/gdk.h>
#include <gtk/gtk.h>

#include "gstpub.h"

extern VMProxy *_blox_vm_proxy;

GHashTable *_blox_create_callback_hash();

#endif
