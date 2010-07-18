/*
   AVL Trees
   Copyright 1993-1999 Bruno Haible, <haible@clisp.cons.org>
  
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

  To use AVL trees you'll have to implement your own insert and search cores.
  This will avoid us to use callbacks and to drop drammatically performances.
  I know it's not the cleaner way,  but in C (not in C++) to get
  performances and genericity...

  Some example of insert and search follows here. The search is a plain
  normal search over an ordered tree. The insert instead must be implemented
  int two steps: as first thing the code must insert the element in
  order as a leaf in the tree, then the support library function
  avl_rebalance() must be called. Such function will do the
  not trivial work to rebalance the tree if necessary.

-----------------------------------------------------------------------
static inline struct page *avl_search_page_cache(struct inode *inode,
                                           unsigned long offset)
{
  avl_node_t *n = inode->i_avl_page_cache;
  struct page *page;

  while (n)
  {
     page = (struct page *) n;

     if (offset < page->offset)
        n = n->avl_left;
     else if (offset > page->offset)
        n = n->avl_right;
     else
        return page;
  }
  return NULL;
}

static inline struct page *avl_insert_page_cache(struct inode *inode,
                                                unsigned long offset,
                                                avl_node_t *node)
{
  avl_node_t **p = &inode->i_avl_page_cache;
  avl_node_t *parent = NULL;
  struct page *page;

  while (*p)
  {
     parent = *p;
     page = (struct page *) parent;

     if (offset < page->offset)
        p = &(*p)->avl_left;
     else if (offset > page->offset)
        p = &(*p)->avl_right;
     else
        return page;
  }

  node->avl_parent = parent;
  node->avl_left = node->avl_right = NULL;

  *p = node;

  avl_rebalance(node, &inode->i_avl_page_cache);
  return NULL;
}
-----------------------------------------------------------------------
*/

#ifndef        AVLTREES_H
#define        AVLTREES_H

typedef struct avl_node_t
{
  struct avl_node_t *avl_parent;
  struct avl_node_t *avl_right;
  struct avl_node_t *avl_left;
  int avl_height;
}
avl_node_t;

typedef struct avl_traverse_t
{
  struct avl_node_t *node;
}
avl_traverse_t;

extern void avl_rebalance(avl_node_t *, avl_node_t **);
extern void avl_erase(avl_node_t *, avl_node_t **);
extern void avl_destroy(avl_node_t *);

extern avl_node_t *avl_first(avl_node_t *, avl_traverse_t *);
extern avl_node_t *avl_next(avl_traverse_t *);

#endif /* AVLTREES_H */
