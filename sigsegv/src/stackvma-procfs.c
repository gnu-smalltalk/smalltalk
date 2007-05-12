/* Determine the virtual memory area of a given address.
   Copyright (C) 2002, 2006  Bruno Haible <bruno@clisp.org>

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

#include "stackvma.h"
#include <stdio.h> /* sprintf */
#include <unistd.h> /* open, close */
#include <fcntl.h> /* open */
#include <stdlib.h> /* malloc, free */
#include <sys/procfs.h> /* PIOC*, prmap_t */

#include "stackvma-simple.c"

#if HAVE_MINCORE
# define sigsegv_get_vma mincore_get_vma
# define STATIC static
# include "stackvma-mincore.c"
# undef sigsegv_get_vma
#endif

int
sigsegv_get_vma (unsigned long address, struct vma_struct *vma)
{
  char fname[6+10+1];
  int fd;
  int nmaps;
  prmap_t* maps;
  prmap_t* mp;
  unsigned long start, end;
#if STACK_DIRECTION < 0
  unsigned long prev;
#endif

  sprintf (fname,"/proc/%u", (unsigned int) getpid ());
  fd = open (fname, O_RDONLY);
  if (fd < 0)
    goto failed;

  if (ioctl (fd, PIOCNMAP, &nmaps) < 0)
    goto fail2;

  /* Use malloc here, not alloca, because we are low on stack space.  */
  maps = (prmap_t *) malloc ((nmaps + 10) * sizeof (prmap_t));
  if (maps == NULL)
    goto fail2;

  if (ioctl (fd, PIOCMAP, maps) < 0)
    goto fail1;

#if STACK_DIRECTION < 0
  prev = 0;
#endif
  for (mp = maps;;)
    {
      start = (unsigned long) mp->pr_vaddr;
      end = start + mp->pr_size;
      if (start == 0 && end == 0)
        break;
      mp++;
      if (address >= start && address <= end - 1)
        {
          vma->start = start;
          vma->end = end;
#if STACK_DIRECTION < 0
          vma->prev_end = prev;
#else
          vma->next_start = (unsigned long) mp->pr_vaddr;
#endif
          free (maps);
          close (fd);
          vma->is_near_this = simple_is_near_this;
          return 0;
        }
#if STACK_DIRECTION < 0
      prev = end;
#endif
    }

 fail1:
  free (maps);
 fail2:
  close (fd);
 failed:
#if HAVE_MINCORE
  return mincore_get_vma (address, vma);
#else
  return -1;
#endif
}
