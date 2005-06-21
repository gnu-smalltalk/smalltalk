/* Dispatch signal to right virtual memory area.
   Copyright (C) 1993-1999, 2002-2003  Bruno Haible <bruno@clisp.org>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include "sigsegv.h"

#include <stddef.h> /* needed for NULL on SunOS4 */
#include <stdlib.h>
#ifdef _WIN32
#include <malloc.h>
#endif

/*
 * A dispatcher contains an AVL tree of non-empty intervals, sorted according
 * to their starting address.
 */
typedef
struct node_t
{
  /* AVL tree management.  */
  struct node_t *left;
  struct node_t *right;
  unsigned int height;
  /* Representation of interval.  */
  unsigned long address;
  unsigned long len;
  /* User handler.  */
  sigsegv_area_handler_t handler;
  void *handler_arg;
}
node_t;

#define empty  ((node_t *) 0)
#define heightof(tree)  ((tree) == empty ? 0 : (tree)->height)
#define MAXHEIGHT  41

static void
rebalance (node_t ***nodeplaces_ptr, unsigned int count)
{
  if (count > 0)
    do
      {
        node_t **nodeplace = *--nodeplaces_ptr;
        node_t *node = *nodeplace;
        node_t *nodeleft = node->left;
        node_t *noderight = node->right;
        unsigned int heightleft = heightof (nodeleft);
        unsigned int heightright = heightof (noderight);
        if (heightright + 1 < heightleft)
          {
            node_t *nodeleftleft = nodeleft->left;
            node_t *nodeleftright = nodeleft->right;
            unsigned int heightleftright = heightof (nodeleftright);
            if (heightof (nodeleftleft) >= heightleftright)
              {
                node->left = nodeleftright; nodeleft->right = node;
                nodeleft->height = 1 + (node->height = 1 + heightleftright);
                *nodeplace = nodeleft;
              }
            else
              {
                nodeleft->right = nodeleftright->left;
                node->left = nodeleftright->right;
                nodeleftright->left = nodeleft;
                nodeleftright->right = node;
                nodeleft->height = node->height = heightleftright;
                nodeleftright->height = heightleft;
                *nodeplace = nodeleftright;
              }
          }
        else if (heightleft + 1 < heightright)
          {
            node_t *noderightright = noderight->right;
            node_t *noderightleft = noderight->left;
            unsigned int heightrightleft = heightof (noderightleft);
            if (heightof (noderightright) >= heightrightleft)
              {
                node->right = noderightleft; noderight->left = node;
                noderight->height = 1 + (node->height = 1 + heightrightleft);
                *nodeplace = noderight;
              }
            else
              {
                noderight->left = noderightleft->right;
                node->right = noderightleft->left;
                noderightleft->right = noderight;
                noderightleft->left = node;
                noderight->height = node->height = heightrightleft;
                noderightleft->height = heightright;
                *nodeplace = noderightleft;
              }
          }
        else
          {
            unsigned int height =
              (heightleft<heightright ? heightright : heightleft) + 1;
            if (height == node->height)
              break;
            node->height = height;
          }
      }
    while (--count > 0);
}

static node_t *
insert (node_t *new_node, node_t *tree)
{
  unsigned long key = new_node->address;
  node_t **nodeplace = &tree;
  node_t **stack[MAXHEIGHT];
  unsigned int stack_count = 0;
  node_t ***stack_ptr = &stack[0];
  for (;;)
    {
      node_t *node = *nodeplace;
      if (node == empty)
        break;
      *stack_ptr++ = nodeplace; stack_count++;
      if (key < node->address)
        nodeplace = &node->left;
      else
        nodeplace = &node->right;
    }
  new_node->left = empty;
  new_node->right = empty;
  new_node->height = 1;
  *nodeplace = new_node;
  rebalance (stack_ptr, stack_count);
  return tree;
}

static node_t *
delete (node_t *node_to_delete, node_t *tree)
{
  unsigned long key = node_to_delete->address;
  node_t **nodeplace = &tree;
  node_t **stack[MAXHEIGHT];
  unsigned int stack_count = 0;
  node_t ***stack_ptr = &stack[0];
  for (;;)
    {
      node_t *node = *nodeplace;
      if (node == empty)
        return tree;
      *stack_ptr++ = nodeplace; stack_count++;
      if (key == node->address)
        {
          if (node != node_to_delete)
            abort ();
          break;
        }
      if (key < node->address)
        nodeplace = &node->left;
      else
        nodeplace = &node->right;
    }
  {
    node_t **nodeplace_to_delete = nodeplace;
    if (node_to_delete->left == empty)
      {
        *nodeplace_to_delete = node_to_delete->right;
        stack_ptr--; stack_count--;
      }
    else
      {
        node_t ***stack_ptr_to_delete = stack_ptr;
        node_t **nodeplace = &node_to_delete->left;
        node_t *node;
        for (;;)
          {
            node = *nodeplace;
            if (node->right == empty)
              break;
            *stack_ptr++ = nodeplace; stack_count++;
            nodeplace = &node->right;
          }
        *nodeplace = node->left;
        node->left = node_to_delete->left;
        node->right = node_to_delete->right;
        node->height = node_to_delete->height;
        *nodeplace_to_delete = node;
        *stack_ptr_to_delete = &node->left;
      }
  }
  rebalance (stack_ptr, stack_count);
  return tree;
}

void
sigsegv_init (sigsegv_dispatcher *dispatcher)
{
  dispatcher->tree = empty;
}

void *
sigsegv_register (sigsegv_dispatcher *dispatcher,
                  void *address, unsigned long len,
                  sigsegv_area_handler_t handler, void *handler_arg)
{
  if (len == 0)
    return NULL;
  else
    {
      node_t *new_node = (node_t *) malloc (sizeof (node_t));
      new_node->address = (unsigned long) address;
      new_node->len = len;
      new_node->handler = handler;
      new_node->handler_arg = handler_arg;
      dispatcher->tree = insert (new_node, (node_t *) dispatcher->tree);
      return new_node;
    }
}

void
sigsegv_unregister (sigsegv_dispatcher *dispatcher, void *ticket)
{
  if (ticket != NULL)
    {
      node_t *node_to_delete = (node_t *) ticket;
      dispatcher->tree = delete (node_to_delete, (node_t *) dispatcher->tree);
      free (node_to_delete);
    }
}

int
sigsegv_dispatch (sigsegv_dispatcher *dispatcher, void *fault_address)
{
  unsigned long key = (unsigned long) fault_address;
  node_t *tree = (node_t *) dispatcher->tree;
  for (;;)
    {
      if (tree == empty)
        return 0;
      if (key < tree->address)
        tree = tree->left;
      else if (key - tree->address >= tree->len)
        tree = tree->right;
      else
        break;
    }
  return (*tree->handler) (fault_address, tree->handler_arg);
}
