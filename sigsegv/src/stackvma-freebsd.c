/* Determine the virtual memory area of a given address.  FreeBSD version.
   Copyright (C) 2002-2003  Bruno Haible <bruno@clisp.org>

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
#include <stdio.h>

int
sigsegv_get_vma (unsigned long address, struct vma_struct *vma)
{
  FILE *fp;
  int c;
  /* The stack appears as multiple adjacents segments, therefore we
     merge adjacent segments.  */
  unsigned long next_start, next_end, curr_start, curr_end;
#if STACK_DIRECTION < 0
  unsigned long prev_end;
#endif

  /* Open the current process' maps file.  It describes one VMA per line.  */
  fp = fopen ("/proc/curproc/map", "r");
  if (!fp)
    return -1;

#if STACK_DIRECTION < 0
  prev_end = 0;
#endif
  for (curr_start = curr_end = 0; ;)
    {
      if (fscanf (fp, "0x%lx 0x%lx", &next_start, &next_end) != 2)
        break;
      while (c = getc (fp), c != EOF && c != '\n')
        continue;
      if (next_start == curr_end)
        {
          /* Merge adjacent segments.  */
          curr_end = next_end;
        }
      else
        {
          if (curr_start < curr_end
              && address >= curr_start && address <= curr_end-1)
            goto found;
#if STACK_DIRECTION < 0
          prev_end = curr_end;
#endif
          curr_start = next_start; curr_end = next_end;
        }
    }
  if (address >= curr_start && address <= curr_end-1)
    found:
    {
      vma->start = curr_start;
      vma->end = curr_end;
#if STACK_DIRECTION < 0
      vma->prev_end = prev_end;
#else
      if (fscanf (fp, "0x%lx 0x%lx", &vma->next_start, &next_end) != 2)
        vma->next_start = 0;
#endif
      fclose (fp);
      return 0;
    }
  fclose (fp);
  return -1;
}
