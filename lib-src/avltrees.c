/*
  AVL Trees
  Copyright 2001, 2002 Free Software Foundation
  (based on code Copyright 1993-1999 Bruno Haible)
  
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
#include "avltrees.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#endif

#define HEIGHT(node)   (node ? node->avl_height : 0)

void avl_rebalance (avl_node_t *node, avl_node_t **tree)
{
  node->avl_height = 0;

  while (node) {
    avl_node_t **arc;
    avl_node_t *parent = node->avl_parent;
    avl_node_t *nodeleft = node->avl_left;
    avl_node_t *noderight = node->avl_right;
    unsigned int hgt_left = HEIGHT(nodeleft);
    unsigned int hgt_right = HEIGHT(noderight);
	  
    if (!parent)
      arc = tree;
    else if (parent->avl_left == node)
      arc = &parent->avl_left;
    else
      arc = &parent->avl_right;
	    
    if (hgt_right + 1 < hgt_left) {
      /*                                                      */
      /*                            *                         */
      /*                          /   \                       */
      /*                       n+2      n                     */
      /*                                                      */
      avl_node_t *nodeleftleft = nodeleft->avl_left;
      avl_node_t *nodeleftright = nodeleft->avl_right;
      unsigned int hgt_leftright = HEIGHT(nodeleftright);
      if (HEIGHT(nodeleftleft) >= hgt_leftright) {
	/*                                                        */
	/*                *                    n+2|n+3            */
	/*              /   \                  /    \             */
	/*           n+2      n      -->      /   n+1|n+2         */
	/*           / \                      |    /    \         */
	/*         n+1 n|n+1                 n+1  n|n+1  n        */
	/*                                                        */
        node->avl_left = nodeleftright;
	node->avl_height = 1 + hgt_leftright;
	if (nodeleftright)
	  nodeleftright->avl_parent = node;

	nodeleft->avl_right = node;
	node->avl_parent = nodeleft;
        nodeleft->avl_height = 1 + node->avl_height;
        nodeleft->avl_parent = parent;
        *arc = nodeleft;
      } else {
	/*                                                        */
	/*                *                     n+2               */
	/*              /   \                 /     \             */
	/*           n+2      n      -->    n+1     n+1           */
	/*           / \                    / \     / \           */
	/*          n  n+1                 n   L   R   n          */
	/*             / \                                        */
	/*            L   R                                       */
	/*                                                        */
        nodeleft->avl_right = nodeleftright->avl_left;
        node->avl_left = nodeleftright->avl_right;
        if (nodeleft->avl_right)
	  nodeleft->avl_right->avl_parent = nodeleft;

        if (node->avl_left)
	  node->avl_left->avl_parent = node;

        nodeleftright->avl_left = nodeleft;
        nodeleftright->avl_right = node;
        nodeleft->avl_parent = node->avl_parent = nodeleftright;
        nodeleft->avl_height = node->avl_height = hgt_leftright;
        nodeleftright->avl_height = hgt_left;
        nodeleftright->avl_parent = parent;
        *arc = nodeleftright;
      }

    } else if (hgt_left + 1 < hgt_right) {
      /* similar to the above, just interchange 'left' <--> 'right' */
      avl_node_t *noderightright = noderight->avl_right;
      avl_node_t *noderightleft = noderight->avl_left;
      unsigned int hgt_rightleft = HEIGHT(noderightleft);
      if (HEIGHT(noderightright) >= hgt_rightleft) {
        node->avl_right = noderightleft;
	node->avl_height = 1 + hgt_rightleft;
	if (noderightleft)
	  noderightleft->avl_parent = node;

	noderight->avl_left = node;
	node->avl_parent = noderight;
        noderight->avl_height = 1 + node->avl_height;
	noderight->avl_parent = parent;
        *arc = noderight;
      } else {
        noderight->avl_left = noderightleft->avl_right;
        node->avl_right = noderightleft->avl_left;
        if (noderight->avl_left)
	  noderight->avl_left->avl_parent = noderight;

        if (node->avl_right)
	  node->avl_right->avl_parent = node;

        noderightleft->avl_right = noderight;
        noderightleft->avl_left = node;
        noderight->avl_parent = node->avl_parent = noderightleft;
        noderight->avl_height = node->avl_height = hgt_rightleft;
        noderightleft->avl_height = hgt_right;
	noderightleft->avl_parent = parent;
        *arc = noderightleft;
      }

    } else {
      unsigned int height = (hgt_left < hgt_right ? hgt_right : hgt_left) + 1;
      if (height == node->avl_height) break;
      node->avl_height = height;
    }

    node = parent;
  }
}

void avl_erase (avl_node_t *node, avl_node_t **tree)
{
  avl_node_t *parent = node->avl_parent;
  avl_node_t **arc_to_deleted;
  avl_node_t *newnode;
  avl_node_t *deepest;
	
  if (!parent)
    arc_to_deleted = tree;
  else if (parent->avl_left == node)
    arc_to_deleted = &parent->avl_left;
  else
    arc_to_deleted = &parent->avl_right;

  deepest = node;
  if (!node->avl_left) {
    /* The easy way -- just remove a level from the tree */
    newnode = node->avl_right;
    if (newnode)
      newnode->avl_parent = node->avl_parent;

  } else {
    /* The hard way -- the node we want is the rightmost child in
       the left subtree */

    avl_node_t **arc = &node->avl_left;
    for (;;) {
      newnode = *arc;
      if (!newnode->avl_right) break;
      deepest = newnode;
      arc = &newnode->avl_right;
    }

    /* The trees lose a level here */
    *arc = newnode->avl_left;

    /* Fix all the links to put the node in place */
    newnode->avl_parent = node->avl_parent;
    newnode->avl_left = node->avl_left;
    newnode->avl_right = node->avl_right;
    newnode->avl_height = node->avl_height;

    if (newnode->avl_left)
      newnode->avl_left->avl_parent = newnode;
    if (newnode->avl_right)
      newnode->avl_right->avl_parent = newnode;
  }

  *arc_to_deleted = newnode;
  avl_rebalance(deepest->avl_parent, tree);
}

void
avl_destroy(register avl_node_t *node)
{
  if (node->avl_left)
    avl_destroy (node->avl_left);
  
  if (node->avl_right)
    avl_destroy (node->avl_right);
  
  free (node);
}
  
avl_node_t *
avl_first(register avl_node_t *node, register avl_traverse_t *t)
{
  if (!node)
    return node;

  /* Descend to the left */
  while (node->avl_left)
    node = node->avl_left;

  t->node = node;
  return t->node;
}

avl_node_t *
avl_next(avl_traverse_t *t)
{
  struct avl_node_t *p = t->node;
  struct avl_node_t *q = p->avl_right;

  if (q == NULL)
    {
      while ((q = p->avl_parent) != NULL && p != q->avl_left)
        p = q;
    }
  else
    {
      while (q->avl_left != NULL)
        q = q->avl_left;
    }

  t->node = q;
  return t->node;
}
