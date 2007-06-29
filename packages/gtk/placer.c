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

/* Shamelessly based on the GtkFixed geometry manager.  */

#include "placer.h"

enum {
  CHILD_PROP_0,
  CHILD_PROP_X,
  CHILD_PROP_Y,
  CHILD_PROP_WIDTH,
  CHILD_PROP_HEIGHT,
  CHILD_PROP_REL_X,
  CHILD_PROP_REL_Y,
  CHILD_PROP_REL_WIDTH,
  CHILD_PROP_REL_HEIGHT,
};

static void gtk_placer_class_init    (GtkPlacerClass    *klass);
static void gtk_placer_init          (GtkPlacer         *placer);
static void gtk_placer_realize       (GtkWidget        *widget);
static void gtk_placer_size_request  (GtkWidget        *widget,
				      GtkRequisition   *requisition);
static void gtk_placer_size_allocate (GtkWidget        *widget,
				      GtkAllocation    *allocation);
static void gtk_placer_add           (GtkContainer     *container,
				      GtkWidget        *widget);
static void gtk_placer_remove        (GtkContainer     *container,
				      GtkWidget        *widget);
static void gtk_placer_forall        (GtkContainer     *container,
				      gboolean 	       include_internals,
				      GtkCallback       callback,
				      gpointer          callback_data);
static GType gtk_placer_child_type   (GtkContainer     *container);

static void gtk_placer_set_child_property (GtkContainer *container,
                                           GtkWidget    *child,
                                           guint         property_id,
                                           const GValue *value,
                                           GParamSpec   *pspec);
static void gtk_placer_get_child_property (GtkContainer *container,
                                           GtkWidget    *child,
                                           guint         property_id,
                                           GValue       *value,
                                           GParamSpec   *pspec);

static GtkContainerClass *parent_class = NULL;


GType
gtk_placer_get_type (void)
{
  static GType placer_type = 0;

  if (!placer_type)
    {
      static const GTypeInfo placer_info =
      {
	sizeof (GtkPlacerClass),
	NULL,		/* base_init */
	NULL,		/* base_finalize */
	(GClassInitFunc) gtk_placer_class_init,
	NULL,		/* class_finalize */
	NULL,		/* class_data */
	sizeof (GtkPlacer),
	0,		/* n_preallocs */
	(GInstanceInitFunc) gtk_placer_init,
      };

      placer_type = g_type_register_static (GTK_TYPE_CONTAINER, "GtkPlacer",
					   &placer_info, 0);
    }

  return placer_type;
}

static void
gtk_placer_class_init (GtkPlacerClass *class)
{
  GtkWidgetClass *widget_class;
  GtkContainerClass *container_class;

  widget_class = (GtkWidgetClass*) class;
  container_class = (GtkContainerClass*) class;

  parent_class = g_type_class_peek_parent (class);

  widget_class->realize = gtk_placer_realize;
  widget_class->size_request = gtk_placer_size_request;
  widget_class->size_allocate = gtk_placer_size_allocate;

  container_class->add = gtk_placer_add;
  container_class->remove = gtk_placer_remove;
  container_class->forall = gtk_placer_forall;
  container_class->child_type = gtk_placer_child_type;

  container_class->set_child_property = gtk_placer_set_child_property;
  container_class->get_child_property = gtk_placer_get_child_property;

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_X,
					      g_param_spec_int ("x",
                                                                "X position",
                                                                "X position of child widget",
                                                                G_MININT,
                                                                G_MAXINT,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_Y,
					      g_param_spec_int ("y",
                                                                "Y position",
								"Y position of child widget",
                                                                G_MININT,
                                                                G_MAXINT,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_WIDTH,
					      g_param_spec_int ("width",
                                                                "Width",
                                                                "Width of child widget",
                                                                G_MININT,
                                                                G_MAXINT,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_HEIGHT,
					      g_param_spec_int ("height",
                                                                "Height",
								"Height of child widget",
                                                                G_MININT,
                                                                G_MAXINT,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_REL_X,
					      g_param_spec_int ("rel_x",
                                                                "X relative position",
                                                                "X relative position in parent widget",
                                                                0,
                                                                32767,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_REL_Y,
					      g_param_spec_int ("rel_y",
                                                                "Y relative position",
								"Y relative position in parent widget",
                                                                0,
                                                                32767,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_REL_WIDTH,
					      g_param_spec_int ("rel_width",
                                                                "Relative width",
                                                                "Relative width in parent widget",
                                                                0,
                                                                32767,
                                                                0,
                                                                G_PARAM_READWRITE));

  gtk_container_class_install_child_property (container_class,
					      CHILD_PROP_REL_HEIGHT,
					      g_param_spec_int ("rel_height",
                                                                "Relative height",
								"Relative height in parent widget",
                                                                0,
                                                                32767,
                                                                0,
                                                                G_PARAM_READWRITE));
}

static GType
gtk_placer_child_type (GtkContainer     *container)
{
  return GTK_TYPE_WIDGET;
}

static void
gtk_placer_init (GtkPlacer *placer)
{
  GTK_WIDGET_SET_FLAGS (placer, GTK_NO_WINDOW);
 
  placer->children = NULL;
}

GtkWidget*
gtk_placer_new (void)
{
  return g_object_new (GTK_TYPE_PLACER, NULL);
}

static GtkPlacerChild*
get_child (GtkPlacer  *placer,
           GtkWidget *widget)
{
  GList *children;
  
  children = placer->children;
  while (children)
    {
      GtkPlacerChild *child;
      
      child = children->data;
      children = children->next;

      if (child->widget == widget)
        return child;
    }

  return NULL;
}

void
gtk_placer_put (GtkPlacer     *placer,
                GtkWidget     *widget,
                gint           x,
                gint           y,
		gint	       width,
	        gint	       height,
		gint	       rel_x,
		gint	       rel_y,
		gint	       rel_width,
		gint	       rel_height)
{
  GtkPlacerChild *child_info;

  g_return_if_fail (GTK_IS_PLACER (placer));
  g_return_if_fail (GTK_IS_WIDGET (placer));
  g_return_if_fail ((rel_x & ~32767) == 0);
  g_return_if_fail ((rel_y & ~32767) == 0);
  g_return_if_fail ((rel_width & ~32767) == 0);
  g_return_if_fail ((rel_height & ~32767) == 0);

  child_info = g_new (GtkPlacerChild, 1);
  child_info->widget = widget;
  child_info->x = x;
  child_info->y = y;
  child_info->width = width;
  child_info->height = height;
  child_info->rel_x = rel_x;
  child_info->rel_y = rel_y;
  child_info->rel_width = rel_width;
  child_info->rel_height = rel_height;

  gtk_widget_set_parent (widget, GTK_WIDGET (placer));

  placer->children = g_list_append (placer->children, child_info);
}

static void
gtk_placer_move_internal (GtkPlacer      *placer,
                          GtkWidget      *widget,
                          gboolean        change_x,
                          gint            x,
                          gboolean        change_y,
                          gint            y,
			  gboolean	  change_width,
			  gint		  width,
			  gboolean	  change_height,
			  gint		  height,
                          gboolean        change_rel_x,
                          gint            rel_x,
                          gboolean        change_rel_y,
                          gint            rel_y,
			  gboolean	  change_rel_width,
			  gint		  rel_width,
			  gboolean	  change_rel_height,
			  gint		  rel_height)
{
  GtkPlacerChild *child;
  
  g_return_if_fail (GTK_IS_PLACER (placer));
  g_return_if_fail (GTK_IS_WIDGET (widget));
  g_return_if_fail (widget->parent == GTK_WIDGET (placer));  
  g_return_if_fail (!change_rel_x || (rel_x & ~32767) == 0);
  g_return_if_fail (!change_rel_y || (rel_y & ~32767) == 0);
  g_return_if_fail (!change_rel_width || (rel_width & ~32767) == 0);
  g_return_if_fail (!change_rel_height || (rel_height & ~32767) == 0);
  
  child = get_child (placer, widget);

  g_assert (child);

  gtk_widget_freeze_child_notify (widget);
  
  if (change_x)
    {
      child->x = x;
      gtk_widget_child_notify (widget, "x");
    }

  if (change_y)
    {
      child->y = y;
      gtk_widget_child_notify (widget, "y");
    }

  if (change_width)
    {
      child->width = width;
      gtk_widget_child_notify (widget, "width");
    }

  if (change_height)
    {
      child->height = height;
      gtk_widget_child_notify (widget, "height");
    }

  if (change_rel_x)
    {
      child->rel_x = rel_x;
      gtk_widget_child_notify (widget, "rel_x");
    }

  if (change_rel_y)
    {
      child->rel_y = rel_y;
      gtk_widget_child_notify (widget, "rel_y");
    }

  if (change_rel_width)
    {
      child->rel_width = rel_width;
      gtk_widget_child_notify (widget, "rel_width");
    }

  if (change_rel_height)
    {
      child->rel_height = rel_height;
      gtk_widget_child_notify (widget, "rel_height");
    }

  gtk_widget_thaw_child_notify (widget);
  
  if (GTK_WIDGET_VISIBLE (widget) && GTK_WIDGET_VISIBLE (placer))
    gtk_widget_queue_resize (GTK_WIDGET (placer));
}

void
gtk_placer_move (GtkPlacer      *placer,
                 GtkWidget      *widget,
                 gint            x,
                 gint            y)
{
  gtk_placer_move_internal (placer, widget,
			    TRUE, x, TRUE, y,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0);
}

void
gtk_placer_resize (GtkPlacer      *placer,
                   GtkWidget      *widget,
                   gint            width,
                   gint            height)
{
  gtk_placer_move_internal (placer, widget,
			    FALSE, 0, FALSE, 0,
			    TRUE, width, TRUE, height,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0);
}

void
gtk_placer_move_rel (GtkPlacer      *placer,
                     GtkWidget      *widget,
                     gint            rel_x,
                     gint            rel_y)
{
  gtk_placer_move_internal (placer, widget,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    TRUE, rel_x, TRUE, rel_y,
			    FALSE, 0, FALSE, 0);
}

void
gtk_placer_resize_rel (GtkPlacer      *placer,
                       GtkWidget      *widget,
                       gint            rel_width,
                       gint            rel_height)
{
  gtk_placer_move_internal (placer, widget,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    TRUE, rel_width, TRUE, rel_height);
}

static void
gtk_placer_set_child_property (GtkContainer    *container,
                              GtkWidget       *child,
                              guint            property_id,
                              const GValue    *value,
                              GParamSpec      *pspec)
{
  int val;
  
  switch (property_id)
    {
    case CHILD_PROP_X:
    case CHILD_PROP_Y:
    case CHILD_PROP_WIDTH:
    case CHILD_PROP_HEIGHT:
    case CHILD_PROP_REL_X:
    case CHILD_PROP_REL_Y:
    case CHILD_PROP_REL_WIDTH:
    case CHILD_PROP_REL_HEIGHT:
      val = g_value_get_int (value);
      gtk_placer_move_internal (GTK_PLACER (container),
                               child,
                               property_id == CHILD_PROP_X, val,
                               property_id == CHILD_PROP_Y, val,
			       property_id == CHILD_PROP_WIDTH, val,
			       property_id == CHILD_PROP_HEIGHT, val,
			       property_id == CHILD_PROP_REL_X, val,
			       property_id == CHILD_PROP_REL_Y, val,
			       property_id == CHILD_PROP_REL_WIDTH, val,
			       property_id == CHILD_PROP_REL_HEIGHT, val);
      break;
    default:
      GTK_CONTAINER_WARN_INVALID_CHILD_PROPERTY_ID (container, property_id, pspec);
      break;
    }
}

static void
gtk_placer_get_child_property (GtkContainer *container,
                              GtkWidget    *child,
                              guint         property_id,
                              GValue       *value,
                              GParamSpec   *pspec)
{
  GtkPlacerChild *placer_child;

  placer_child = get_child (GTK_PLACER (container), child);
  
  switch (property_id)
    {
    case CHILD_PROP_X:
      g_value_set_int (value, placer_child->x);
      break;
    case CHILD_PROP_Y:
      g_value_set_int (value, placer_child->y);
      break;
    case CHILD_PROP_WIDTH:
      g_value_set_int (value, placer_child->width);
      break;
    case CHILD_PROP_HEIGHT:
      g_value_set_int (value, placer_child->height);
      break;
    case CHILD_PROP_REL_X:
      g_value_set_int (value, placer_child->rel_x);
      break;
    case CHILD_PROP_REL_Y:
      g_value_set_int (value, placer_child->rel_y);
      break;
    case CHILD_PROP_REL_WIDTH:
      g_value_set_int (value, placer_child->rel_width);
      break;
    case CHILD_PROP_REL_HEIGHT:
      g_value_set_int (value, placer_child->rel_height);
      break;
    default:
      GTK_CONTAINER_WARN_INVALID_CHILD_PROPERTY_ID (container, property_id, pspec);
      break;
    }
}

static void
gtk_placer_realize (GtkWidget *widget)
{
  GdkWindowAttr attributes;
  gint attributes_mask;

  if (GTK_WIDGET_NO_WINDOW (widget))
    GTK_WIDGET_CLASS (parent_class)->realize (widget);
  else
    {
      GTK_WIDGET_SET_FLAGS (widget, GTK_REALIZED);

      attributes.window_type = GDK_WINDOW_CHILD;
      attributes.x = widget->allocation.x;
      attributes.y = widget->allocation.y;
      attributes.width = widget->allocation.width;
      attributes.height = widget->allocation.height;
      attributes.wclass = GDK_INPUT_OUTPUT;
      attributes.visual = gtk_widget_get_visual (widget);
      attributes.colormap = gtk_widget_get_colormap (widget);
      attributes.event_mask = gtk_widget_get_events (widget);
      attributes.event_mask |= GDK_EXPOSURE_MASK | GDK_BUTTON_PRESS_MASK;
      
      attributes_mask = GDK_WA_X | GDK_WA_Y | GDK_WA_VISUAL | GDK_WA_COLORMAP;
      
      widget->window = gdk_window_new (gtk_widget_get_parent_window (widget), &attributes, 
				       attributes_mask);
      gdk_window_set_user_data (widget->window, widget);
      
      widget->style = gtk_style_attach (widget->style, widget->window);
      gtk_style_set_background (widget->style, widget->window, GTK_STATE_NORMAL);
    }
}

static void
gtk_placer_size_request (GtkWidget      *widget,
			 GtkRequisition *requisition)
{
  GtkPlacer *placer;  
  GtkPlacerChild *child;
  GList *children;
  GtkRequisition child_requisition;
  gint border_width;
  gint height, width;

  placer = GTK_PLACER (widget);
  border_width = GTK_CONTAINER (placer)->border_width;
  requisition->width = 0;
  requisition->height = 0;

  children = placer->children;
  while (children)
    {
      child = children->data;
      children = children->next;

      if (GTK_WIDGET_VISIBLE (child->widget))
	{
          gtk_widget_size_request (child->widget, &child_requisition);

	  /* Start with the widget's requested size and account for
	     the extra space that we reserve (which is empty, and
	     hence added, for negative sizes, and full, and hence
	     subtracted, for positive sizes).  Then ensure that it
	     fits into the requested relative height if there is one;
	     otherwise, if there's a relative position, align the
	     widget to the right (ensure that there is space on the
	     right).  Then add up the relative offset.

	     The formula to ensure that there is space on the right is
	     as follows: if the requested height is 200, and the left
	     border is at 30%, we need at least 200 / (1 - 0.3): this
	     allocates 285 pixels and puts the widgets at pixels 85
	     to 285. */

	  height = child_requisition.height - child->height;
	  width = child_requisition.width - child->width;

	  if (child->rel_height)
	    height = height / (child->rel_height / 32767.0);
	  else
	    height = height / (1.0 - child->rel_y / 32767.0);

	  if (child->rel_width)
	    width = width / (child->rel_width / 32767.0);
	  else
	    width = width / (1.0 - child->rel_x / 32767.0);

	  requisition->height = MAX (height + child->y, requisition->height);
	  requisition->width = MAX (width + child->x, requisition->width);
	}
    }

  requisition->height += border_width * 2;
  requisition->width += border_width * 2;
}

static void
gtk_placer_size_allocate (GtkWidget     *widget,
			 GtkAllocation *allocation)
{
  GtkPlacer *placer;
  GtkPlacerChild *child;
  GtkAllocation child_allocation;
  GtkRequisition child_requisition;
  GList *children;
  guint16 border_width;
  gdouble rel_width_scale, rel_height_scale;

  placer = GTK_PLACER (widget);

  widget->allocation = *allocation;

  if (!GTK_WIDGET_NO_WINDOW (widget))
    {
      if (GTK_WIDGET_REALIZED (widget))
	gdk_window_move_resize (widget->window,
				allocation->x, 
				allocation->y,
				allocation->width, 
				allocation->height);
    }
      
  border_width = GTK_CONTAINER (placer)->border_width;
  rel_width_scale = (allocation->width - 2 * border_width) / 32767.0;
  rel_height_scale = (allocation->height - 2 * border_width) / 32767.0;
  
  children = placer->children;
  while (children)
    {
      child = children->data;
      children = children->next;
      
      if (GTK_WIDGET_VISIBLE (child->widget))
	{
	  gtk_widget_get_child_requisition (child->widget, &child_requisition);
	  child_allocation.x = child->x + border_width
			       + child->rel_x * rel_width_scale;
	  child_allocation.y = child->y + border_width
			       + child->rel_y * rel_height_scale;

	  if (GTK_WIDGET_NO_WINDOW (widget))
	    {
	      child_allocation.x += allocation->x;
	      child_allocation.y += allocation->y;
	    }
	  
	  if (!child->rel_width)
	    child_allocation.width = child_requisition.width;
	  else
	    child_allocation.width = child->rel_width * rel_width_scale;
    
	  if (!child->rel_height)
	    child_allocation.height = child_requisition.height;
	  else
	    child_allocation.height = child->rel_height * rel_height_scale;

	  child_allocation.width += child->width;
	  child_allocation.height += child->height;
	  
	  child_allocation.width = MAX (child_allocation.width, 0);
	  child_allocation.height = MAX (child_allocation.height, 0);
	  gtk_widget_size_allocate (child->widget, &child_allocation);
	}
    }
}

static void
gtk_placer_add (GtkContainer *container,
 	        GtkWidget    *widget)
{
  gtk_placer_put (GTK_PLACER (container), widget, 0, 0, 0, 0, 0, 0, 32767, 32767);
}

static void
gtk_placer_remove (GtkContainer *container,
		   GtkWidget    *widget)
{
  GtkPlacer *placer;
  GtkPlacerChild *child;
  GList *children;

  placer = GTK_PLACER (container);

  children = placer->children;
  while (children)
    {
      child = children->data;

      if (child->widget == widget)
	{
	  gboolean was_visible = GTK_WIDGET_VISIBLE (widget);
	  
	  gtk_widget_unparent (widget);

	  placer->children = g_list_remove_link (placer->children, children);
	  g_list_free (children);
	  g_free (child);

	  if (was_visible && GTK_WIDGET_VISIBLE (container))
	    gtk_widget_queue_resize (GTK_WIDGET (container));

	  break;
	}

      children = children->next;
    }
}

static void
gtk_placer_forall (GtkContainer *container,
		   gboolean	include_internals,
		   GtkCallback   callback,
		   gpointer      callback_data)
{
  GtkPlacer *placer;
  GtkPlacerChild *child;
  GList *children;

  g_return_if_fail (callback != NULL);

  placer = GTK_PLACER (container);

  children = placer->children;
  while (children)
    {
      child = children->data;
      children = children->next;

      (* callback) (child->widget, callback_data);
    }
}

/**
 * gtk_placer_set_has_window:
 * @placer: a #GtkPlacer
 * @has_window: %TRUE if a separate window should be created
 * 
 * Sets whether a #GtkPlacer widget is created with a separate
 * #GdkWindow for widget->window or not. (By default, it will be
 * created with no separate #GdkWindow). This function must be called
 * while the #GtkPlacer is not realized, for instance, immediately after the
 * window is created.
 **/
void
gtk_placer_set_has_window (GtkPlacer *placer,
			   gboolean  has_window)
{
  g_return_if_fail (GTK_IS_PLACER (placer));
  g_return_if_fail (!GTK_WIDGET_REALIZED (placer));

  if (!has_window != GTK_WIDGET_NO_WINDOW (placer))
    {
      if (has_window)
	GTK_WIDGET_UNSET_FLAGS (placer, GTK_NO_WINDOW);
      else
	GTK_WIDGET_SET_FLAGS (placer, GTK_NO_WINDOW);
    }
}

/**
 * gtk_placer_get_has_window:
 * @placer: a #GtkWidget
 * 
 * Gets whether the #GtkPlacer has it's own #GdkWindow.
 * See gdk_placer_set_has_window().
 * 
 * Return value: %TRUE if @placer has its own window.
 **/
gboolean
gtk_placer_get_has_window (GtkPlacer *placer)
{
  g_return_val_if_fail (GTK_IS_PLACER (placer), FALSE);

  return !GTK_WIDGET_NO_WINDOW (placer);
}
