/***********************************************************************
 *
 *  Example of using the placer geometry manager
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include <gtk/gtk.h>
#include "placer.h"
#include "placer.c"

gint rel_width = 5461;
gint rel_height = 8191;

void move_button (GtkWidget *widget,
                  GtkWidget *placer)
{
  rel_width = 5461 + 8192 - rel_width;
  rel_height = 8192 + 10922 - rel_height;
  gtk_placer_resize_rel (GTK_PLACER (placer), widget, rel_width, rel_height);
}

int main (int   argc,
          char *argv[])
{
  /* GtkWidget is the storage type for widgets */
  GtkWidget *window;
  GtkWidget *placer;
  GtkWidget *button;
  gint i;

  const int rel_x[4] = { 0, 8192, 16384, 24576 };
  const int rel_y[3] = { 0, 10922, 21844 };
  
  /* Initialise GTK */
  gtk_init (&argc, &argv);
    
  /* Create a new window */
  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_window_set_title (GTK_WINDOW (window), "Placer Container");

  /* Here we connect the "destroy" event to a signal handler */ 
  g_signal_connect (G_OBJECT (window), "destroy",
		    G_CALLBACK (gtk_main_quit), NULL);
 
  /* Sets the border width of the window. */
  gtk_container_set_border_width (GTK_CONTAINER (window), 5);

  /* Create a Placer Container */
  placer = gtk_placer_new ();
  gtk_container_add (GTK_CONTAINER (window), placer);
  gtk_widget_show (placer);
  
  for (i = 0 ; i <= 11 ; i++) {
    /* Creates a new button with the label "Press me" */
    button = gtk_button_new_with_label ("Press me");
  
    /* When the button receives the "clicked" signal, it will call the
     * function move_button() passing it the Fixed Container as its
     * argument. */
    g_signal_connect (G_OBJECT (button), "clicked",
		      G_CALLBACK (move_button), (gpointer) placer);
  
    /* This packs the button into the placer containers window. */
    gtk_placer_put (GTK_PLACER (placer), button,
		    5, 2, -10, -4,
		    rel_x[i % 4], rel_y[i / 4],
		    rel_width, rel_height);
  
    /* The final step is to display this newly created widget. */
    gtk_widget_show (button);
  }

  /* gtk_window_set_default_size (GTK_WINDOW (window), 400, 200); */

  /* Display the window */
  gtk_widget_show (window);
    
  /* Enter the event loop */
  gtk_main ();
    
  return 0;
}
