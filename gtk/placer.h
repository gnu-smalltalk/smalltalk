/***********************************************************************
 *
 *  Gtk+ wrappers for GNU Smalltalk - Placer geometry manager
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006 Free Software Foundation, Inc.
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

/* Yes, this might seem blasphemy, but Blox has rubber-sheet geometry
   management and will have it even after it adopts Gtk widgets.  */

#ifndef __GTK_PLACER_H__
#define __GTK_PLACER_H__


#include <gdk/gdk.h>
#include <gtk/gtk.h>


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#define GTK_TYPE_PLACER                  (gtk_placer_get_type ())
#define GTK_PLACER(obj)                  (G_TYPE_CHECK_INSTANCE_CAST ((obj), GTK_TYPE_PLACER, GtkPlacer))
#define GTK_PLACER_CLASS(klass)          (G_TYPE_CHECK_CLASS_CAST ((klass), GTK_TYPE_PLACER, GtkPlacerClass))
#define GTK_IS_PLACER(obj)               (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GTK_TYPE_PLACER))
#define GTK_IS_PLACER_CLASS(klass)       (G_TYPE_CHECK_CLASS_TYPE ((klass), GTK_TYPE_PLACER))
#define GTK_PLACER_GET_CLASS(obj)        (G_TYPE_INSTANCE_GET_CLASS ((obj), GTK_TYPE_PLACER, GtkPlacerClass))


typedef struct _GtkPlacer        GtkPlacer;
typedef struct _GtkPlacerClass   GtkPlacerClass;
typedef struct _GtkPlacerChild   GtkPlacerChild;

struct _GtkPlacer
{
  GtkContainer container;

  GList *children;
};

struct _GtkPlacerClass
{
  GtkContainerClass parent_class;
};

struct _GtkPlacerChild
{
  GtkWidget *widget;
  gint x;
  gint y;
  gint width;
  gint height;
  gint rel_x;
  gint rel_y;
  gint rel_width;
  gint rel_height;
};


GType      gtk_placer_get_type         (void) G_GNUC_CONST;
GtkWidget* gtk_placer_new              (void);
void       gtk_placer_put              (GtkPlacer      *placer,
                                        GtkWidget      *widget,
                                        gint            x,
                                        gint            y,
					gint		width,
					gint		height,
					gint		rel_x,
					gint		rel_y,
					gint		rel_width,
					gint		rel_height);
void       gtk_placer_move             (GtkPlacer      *placer,
                                        GtkWidget      *widget,
                                        gint            x,
                                        gint            y);
void       gtk_placer_resize           (GtkPlacer      *placer,
                                        GtkWidget      *widget,
					gint		width,
					gint		height);
void       gtk_placer_move_rel         (GtkPlacer      *placer,
                                        GtkWidget      *widget,
					gint		rel_x,
					gint		rel_y);
void       gtk_placer_resize_rel       (GtkPlacer      *placer,
                                        GtkWidget      *widget,
					gint		rel_width,
					gint		rel_height);
void       gtk_placer_set_has_window   (GtkPlacer      *placer,
					gboolean        has_window);
gboolean   gtk_placer_get_has_window   (GtkPlacer      *placer);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* __GTK_PLACER_H__ */
