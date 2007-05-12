/* Test that the handler is called, with the right fault address.
   Copyright (C) 2002-2006  Bruno Haible <bruno@clisp.org>

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
#include <stdio.h>

#if HAVE_SIGSEGV_RECOVERY

#include "mmaputil.h"
#include <stdlib.h>

unsigned long page;

volatile int handler_called = 0;

int
handler (void *fault_address, int serious)
{
  handler_called++;
  if (handler_called > 10)
    abort ();
  if (fault_address != (void *)(page + 0x678))
    abort ();
  if (mprotect ((void *) page, 0x4000, PROT_READ_WRITE) == 0)
    return 1;
  return 0;
}

void
crasher (unsigned long p)
{
  *(volatile int *) (p + 0x678) = 42;
}

int
main ()
{
  void *p;

  /* Preparations.  */
#if !HAVE_MMAP_ANON && !HAVE_MMAP_ANONYMOUS && HAVE_MMAP_DEVZERO
  zero_fd = open ("/dev/zero", O_RDONLY, 0644);
#endif

  /* Setup some mmaped memory.  */
  p = mmap_zeromap ((void *) 0x12340000, 0x4000);
  if (p == (void *)(-1))
    {
      fprintf (stderr, "mmap_zeromap failed.\n");
      exit (2);
    }
  page = (unsigned long) p;

  /* Make it read-only.  */
  if (mprotect ((void *) page, 0x4000, PROT_READ) < 0)
    {
      fprintf (stderr, "mprotect failed.\n");
      exit (2);
    }
  /* Test whether it's possible to make it read-write after it was read-only.
     This is not possible on Cygwin.  */
  if (mprotect ((void *) page, 0x4000, PROT_READ_WRITE) < 0
      || mprotect ((void *) page, 0x4000, PROT_READ) < 0)
    {
      fprintf (stderr, "mprotect failed.\n");
      exit (2);
    }

  /* Install the SIGSEGV handler.  */
  sigsegv_install_handler (&handler);

  /* The first write access should invoke the handler and then complete.  */
  crasher (page);
  /* The second write access should not invoke the handler.  */
  crasher (page);

  /* Check that the handler was called only once.  */
  if (handler_called != 1)
    exit (1);
  /* Test passed!  */
  printf ("Test passed.\n");
  return 0;
}

#else

int
main ()
{
  return 77;
}

#endif
