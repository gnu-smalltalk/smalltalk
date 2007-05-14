/* Determine the virtual memory area of a given address.  Mach version.
   Copyright (C) 2003, 2006  Paolo Bonzini <bonzini@gnu.org>

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
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif
#include <libc.h>
#include <nlist.h>
#include <mach/mach.h>
#ifndef NeXT
#include <mach/machine/vm_param.h>
#endif

#include "stackvma-simple.c"

int
sigsegv_get_vma (unsigned long req_address, struct vma_struct *vma)
{
  unsigned long prev_address = 0, prev_size = 0;
  unsigned long join_address = 0, join_size = 0;
  int more = 1;
  vm_address_t address;
  vm_size_t size;
  mach_port_t object_name;
#ifdef VM_REGION_BASIC_INFO
  task_t task = mach_task_self ();
  struct vm_region_basic_info info;
  mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT;
#else
  task_t task = task_self ();
  vm_prot_t protection, max_protection;
  vm_inherit_t inheritance;
  boolean_t shared;
  vm_offset_t offset;
#endif

  for (address = VM_MIN_ADDRESS; more; address += size)
    {
#ifdef VM_REGION_BASIC_INFO
      more = (vm_region (task, &address, &size, VM_REGION_BASIC_INFO,
                         (vm_region_info_t)&info, &info_count, &object_name)
              == KERN_SUCCESS);
#else
      more = (vm_region (task, &address, &size, &protection, &max_protection,
                         &inheritance, &shared, &object_name, &offset)
              == KERN_SUCCESS);
#endif
      if (!more)
        {
          address = join_address + join_size;
          size = 0;
        }

      if ((unsigned long) address == join_address + join_size)
        join_size += size;
      else
        {
          prev_address = join_address;
          prev_size = join_size;
          join_address = (unsigned long) address;
          join_size = size;
        }

#ifdef VM_REGION_BASIC_INFO
      if (object_name != MACH_PORT_NULL)
        mach_port_deallocate (mach_task_self (), object_name);
      info_count = VM_REGION_BASIC_INFO_COUNT;
#endif

#if STACK_DIRECTION < 0
      if (join_address <= req_address && join_address + join_size > req_address)
        {
          vma->start = join_address;
          vma->end = join_address + join_size;
          vma->prev_end = prev_address + prev_size;
          vma->is_near_this = simple_is_near_this;
          return 0;
        }
#else
      if (prev_address <= req_address && prev_address + prev_size > req_address)
        {
          vma->start = prev_address;
          vma->end = prev_address + prev_size;
          vma->next_start = join_address;
          vma->is_near_this = simple_is_near_this;
          return 0;
        }
#endif
    }

#if STACK_DIRECTION > 0
  if (join_address <= req_address && join_address + size > req_address)
    {
      vma->start = prev_address;
      vma->end = prev_address + prev_size;
      vma->next_start = ~0UL;
      vma->is_near_this = simple_is_near_this;
      return 0;
    }
#endif

  return -1;
}
