/*
  Red Black Trees
  Copyright 2001, 2002 Free Software Foundation
  (based on code Copyright (C) 1999  Andrea Arcangeli <andrea@suse.de>)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdio.h>
#include "rbtrees.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#endif

static void
rb_rotate_left (rb_node_t * node, rb_node_t ** root)
{
  rb_node_t *right = node->rb_right;

  if ((node->rb_right = right->rb_left))
    right->rb_left->rb_parent = node;
  right->rb_left = node;

  if ((right->rb_parent = node->rb_parent))
    {
      if (node == node->rb_parent->rb_left)
	node->rb_parent->rb_left = right;
      else
	node->rb_parent->rb_right = right;
    }
  else
    *root = right;
  node->rb_parent = right;
}

static void
rb_rotate_right (rb_node_t * node, rb_node_t ** root)
{
  rb_node_t *left = node->rb_left;

  if ((node->rb_left = left->rb_right))
    left->rb_right->rb_parent = node;
  left->rb_right = node;

  if ((left->rb_parent = node->rb_parent))
    {
      if (node == node->rb_parent->rb_right)
	node->rb_parent->rb_right = left;
      else
	node->rb_parent->rb_left = left;
    }
  else
    *root = left;
  node->rb_parent = left;
}

void
rb_rebalance (rb_node_t * node, rb_node_t ** root)
{
  rb_node_t *parent, *gparent;

  node->rb_color = RB_RED;
  while ((parent = node->rb_parent) && parent->rb_color == RB_RED)
    {
      gparent = parent->rb_parent;

      if (parent == gparent->rb_left)
	{
	  {
	    register rb_node_t *uncle = gparent->rb_right;
	    if (uncle && uncle->rb_color == RB_RED)
	      {
		uncle->rb_color = RB_BLACK;
		parent->rb_color = RB_BLACK;
		gparent->rb_color = RB_RED;
		node = gparent;
		continue;
	      }
	  }

	  if (parent->rb_right == node)
	    {
	      register rb_node_t *tmp;
	      rb_rotate_left (parent, root);
	      tmp = parent;
	      parent = node;
	      node = tmp;
	    }

	  parent->rb_color = RB_BLACK;
	  gparent->rb_color = RB_RED;
	  rb_rotate_right (gparent, root);
	}
      else
	{
	  {
	    register rb_node_t *uncle = gparent->rb_left;
	    if (uncle && uncle->rb_color == RB_RED)
	      {
		uncle->rb_color = RB_BLACK;
		parent->rb_color = RB_BLACK;
		gparent->rb_color = RB_RED;
		node = gparent;
		continue;
	      }
	  }

	  if (parent->rb_left == node)
	    {
	      register rb_node_t *tmp;
	      rb_rotate_right (parent, root);
	      tmp = parent;
	      parent = node;
	      node = tmp;
	    }

	  parent->rb_color = RB_BLACK;
	  gparent->rb_color = RB_RED;
	  rb_rotate_left (gparent, root);
	}
    }

  (*root)->rb_color = RB_BLACK;
}


static void
rb_erase_rebalance (rb_node_t * child, rb_node_t * parent, rb_node_t ** root)
{
  rb_node_t *other;

  while ((!child || child->rb_color == RB_BLACK) && child != *root)
    {
      if (parent->rb_left == child)
	{
	  other = parent->rb_right;
	  if (other->rb_color == RB_RED)
	    {
	      other->rb_color = RB_BLACK;
	      parent->rb_color = RB_RED;
	      rb_rotate_left (parent, root);
	      other = parent->rb_right;
	    }
	  if ((!other->rb_left ||
	       other->rb_left->rb_color == RB_BLACK)
	      && (!other->rb_right || other->rb_right->rb_color == RB_BLACK))
	    {
	      other->rb_color = RB_RED;
	      child = parent;
	      parent = child->rb_parent;
	    }
	  else
	    {
	      if (!other->rb_right || other->rb_right->rb_color == RB_BLACK)
		{
		  register rb_node_t *o_left;
		  if ((o_left = other->rb_left))
		    o_left->rb_color = RB_BLACK;
		  other->rb_color = RB_RED;
		  rb_rotate_right (other, root);
		  other = parent->rb_right;
		}
	      other->rb_color = parent->rb_color;
	      parent->rb_color = RB_BLACK;
	      if (other->rb_right)
		other->rb_right->rb_color = RB_BLACK;
	      rb_rotate_left (parent, root);
	      child = *root;
	      break;
	    }
	}
      else
	{
	  other = parent->rb_left;
	  if (other->rb_color == RB_RED)
	    {
	      other->rb_color = RB_BLACK;
	      parent->rb_color = RB_RED;
	      rb_rotate_right (parent, root);
	      other = parent->rb_left;
	    }
	  if ((!other->rb_left ||
	       other->rb_left->rb_color == RB_BLACK)
	      && (!other->rb_right || other->rb_right->rb_color == RB_BLACK))
	    {
	      other->rb_color = RB_RED;
	      child = parent;
	      parent = child->rb_parent;
	    }
	  else
	    {
	      if (!other->rb_left || other->rb_left->rb_color == RB_BLACK)
		{
		  register rb_node_t *o_right;
		  if ((o_right = other->rb_right))
		    o_right->rb_color = RB_BLACK;
		  other->rb_color = RB_RED;
		  rb_rotate_left (other, root);
		  other = parent->rb_left;
		}
	      other->rb_color = parent->rb_color;
	      parent->rb_color = RB_BLACK;
	      if (other->rb_left)
		other->rb_left->rb_color = RB_BLACK;
	      rb_rotate_right (parent, root);
	      child = *root;
	      break;
	    }
	}
    }
  if (child)
    child->rb_color = RB_BLACK;
}


void
rb_erase (rb_node_t * node, rb_node_t ** root)
{
  rb_node_t *child, *parent;
  int color;

  if (!node->rb_left)
    child = node->rb_right;
  else if (!node->rb_right)
    child = node->rb_left;
  else
    {
      rb_node_t *old = node, *left;

      node = node->rb_right;
      while ((left = node->rb_left))
	node = left;
      child = node->rb_right;
      parent = node->rb_parent;
      color = node->rb_color;

      if (child)
	child->rb_parent = parent;
      if (parent)
	{
	  if (parent->rb_left == node)
	    parent->rb_left = child;
	  else
	    parent->rb_right = child;
	}
      else
	*root = child;

      if (node->rb_parent == old)
	parent = node;
      node->rb_parent = old->rb_parent;
      node->rb_color = old->rb_color;
      node->rb_right = old->rb_right;
      node->rb_left = old->rb_left;

      if (old->rb_parent)
	{
	  if (old->rb_parent->rb_left == old)
	    old->rb_parent->rb_left = node;
	  else
	    old->rb_parent->rb_right = node;
	}
      else
	*root = node;

      old->rb_left->rb_parent = node;
      if (old->rb_right)
	old->rb_right->rb_parent = node;

      if (color == RB_BLACK)
	rb_erase_rebalance (child, parent, root);

      return;
    }

  parent = node->rb_parent;
  color = node->rb_color;

  if (child)
    child->rb_parent = parent;
  if (parent)
    {
      if (parent->rb_left == node)
	parent->rb_left = child;
      else
	parent->rb_right = child;
    }
  else
    *root = child;

  if (color == RB_BLACK)
    rb_erase_rebalance (child, parent, root);
}

void
rb_destroy(register rb_node_t *node)
{
  if (node->rb_left)
    rb_destroy (node->rb_left);

  if (node->rb_right)
    rb_destroy (node->rb_right);

  free (node);
}

rb_node_t *
rb_first (register rb_node_t * node, register rb_traverse_t * t)
{
  if (!node)
    return node;

  /* Descend to the left */
  while (node->rb_left)
    node = node->rb_left;

  t->node = node;
  return t->node;
}

rb_node_t *
rb_next (rb_traverse_t * t)
{
  struct rb_node_t *p = t->node;
  struct rb_node_t *q = p->rb_right;

  if (q == NULL)
    {
      while ((q = p->rb_parent) != NULL && p != q->rb_left) 
        p = q;
    }
  else
    {
      while (q->rb_left != NULL) 
        q = q->rb_left;
    } 
  
  t->node = q;
  return t->node;
}
