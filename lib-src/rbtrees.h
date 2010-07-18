/*
  Red-Black Trees
  (C) 1999  Andrea Arcangeli <andrea@suse.de>
  
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

  To use rbtrees you'll have to implement your own insert and search cores.
  This will avoid us to use callbacks and to drop drammatically performances.
  I know it's not the cleaner way,  but in C (not in C++) to get
  performances and genericity...

  Some example of insert and search follows here. The search is a plain
  normal search over an ordered tree. The insert instead must be implemented
  int two steps: as first thing the code must insert the element in
  order as a leaf in the tree, then the support library function
  rb_rebalance() must be called. Such function will do the
  not trivial work to rebalance the rbtree if necessary.

-----------------------------------------------------------------------
static inline struct page *rb_search_page_cache(struct inode *inode,
                                           unsigned long offset)
{
  rb_node_t *n = inode->i_rb_page_cache;
  struct page *page;

  while (n)
  {
     page = (struct page *) n;

     if (offset < page->offset)
        n = n->rb_left;
     else if (offset > page->offset)
        n = n->rb_right;
     else
        return page;
  }
  return NULL;
}

static inline struct page *rb_insert_page_cache(struct inode *inode,
                                                unsigned long offset,
                                                rb_node_t *node)
{
  rb_node_t **p = &inode->i_rb_page_cache;
  rb_node_t *parent = NULL;
  struct page *page;

  while (*p)
  {
     parent = *p;
     page = (struct page *) parent;

     if (offset < page->offset)
        p = &(*p)->rb_left;
     else if (offset > page->offset)
        p = &(*p)->rb_right;
     else
        return page;
  }

  node->rb_parent = parent;
  node->rb_left = node->rb_right = NULL;

  *p = node;

  rb_rebalance(node, &inode->i_rb_page_cache);
  return NULL;
}
-----------------------------------------------------------------------
*/

#ifndef        RBTREES_H
#define        RBTREES_H

#define        RB_RED          0
#define        RB_BLACK        1

typedef struct rb_node_t
{
  struct rb_node_t *rb_parent;
  struct rb_node_t *rb_right;
  struct rb_node_t *rb_left;
  int rb_color;
}
rb_node_t;

typedef struct rb_traverse_t
{
  struct rb_node_t *node;
}
rb_traverse_t;

extern void rb_rebalance(rb_node_t *, rb_node_t **);
extern void rb_erase(rb_node_t *, rb_node_t **);
extern void rb_destroy(rb_node_t *);

extern rb_node_t *rb_first(rb_node_t *, rb_traverse_t *);
extern rb_node_t *rb_next(rb_traverse_t *);

#endif /* RBTREES_H */
