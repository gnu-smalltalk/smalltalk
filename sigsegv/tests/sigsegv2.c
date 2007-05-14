/* Test the dispatcher.
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

static sigsegv_dispatcher dispatcher;

static volatile unsigned int logcount = 0;
static volatile unsigned long logdata[10];

static int
area_handler (void *fault_address, void *user_arg)
{
  unsigned long area = *(unsigned long *)user_arg;
  logdata[logcount++] = area;
  if (logcount >= sizeof (logdata) / sizeof (logdata[0]))
    abort ();
  if (!((unsigned long)fault_address >= area
        && (unsigned long)fault_address - area < 0x4000))
    abort ();
  if (mprotect ((void *) area, 0x4000, PROT_READ_WRITE) == 0)
    return 1;
  return 0;
}

static int
handler (void *fault_address, int serious)
{
  return sigsegv_dispatch (&dispatcher, fault_address);
}

static void
barrier ()
{
}

int
main ()
{
  void *p;
  unsigned long area1;
  unsigned long area2;
  unsigned long area3;

  /* Preparations.  */
#if !HAVE_MMAP_ANON && !HAVE_MMAP_ANONYMOUS && HAVE_MMAP_DEVZERO
  zero_fd = open ("/dev/zero", O_RDONLY, 0644);
#endif
  sigsegv_init (&dispatcher);
  sigsegv_install_handler (&handler);

  /* Setup some mmaped memory.  */

  p = mmap_zeromap ((void *) 0x12340000, 0x4000);
  if (p == (void *)(-1))
    {
      fprintf (stderr, "mmap_zeromap failed.\n");
      exit (2);
    }
  area1 = (unsigned long) p;
  sigsegv_register (&dispatcher, (void *) area1, 0x4000, &area_handler, &area1);
  if (mprotect ((void *) area1, 0x4000, PROT_NONE) < 0)
    {
      fprintf (stderr, "mprotect failed.\n");
      exit (2);
    }

  p = mmap_zeromap ((void *) 0x0BEE0000, 0x4000);
  if (p == (void *)(-1))
    {
      fprintf (stderr, "mmap_zeromap failed.\n");
      exit (2);
    }
  area2 = (unsigned long) p;
  sigsegv_register (&dispatcher, (void *) area2, 0x4000, &area_handler, &area2);
  if (mprotect ((void *) area2, 0x4000, PROT_READ) < 0)
    {
      fprintf (stderr, "mprotect failed.\n");
      exit (2);
    }
  if (mprotect ((void *) area2, 0x4000, PROT_READ_WRITE) < 0
      || mprotect ((void *) area2, 0x4000, PROT_READ) < 0)
    {
      fprintf (stderr, "mprotect failed.\n");
      exit (2);
    }

  p = mmap_zeromap ((void *) 0x06990000, 0x4000);
  if (p == (void *)(-1))
    {
      fprintf (stderr, "mmap_zeromap failed.\n");
      exit (2);
    }
  area3 = (unsigned long) p;
  sigsegv_register (&dispatcher, (void *) area3, 0x4000, &area_handler, &area3);
  mprotect ((void *) area3, 0x4000, PROT_READ);

  /* This access should call the handler.  */
  ((volatile int *)area2)[230] = 22;
  /* This access should call the handler.  */
  ((volatile int *)area3)[412] = 33;
  /* This access should not give a signal.  */
  ((volatile int *)area2)[135] = 22;
  /* This access should call the handler.  */
  ((volatile int *)area1)[612] = 11;

  barrier();

  /* Check that the handler was called three times.  */
  if (logcount != 3)
    exit (1);
  if (!(logdata[0] == area2 && logdata[1] == area3 && logdata[2] == area1))
    exit (1);
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
