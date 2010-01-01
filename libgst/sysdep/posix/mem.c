/******************************** -*- C -*- ****************************
 *
 * System specific implementation module.
 *
 * This module contains implementations of various operating system
 * specific routines.  This module should encapsulate most (or all)
 * of these calls so that the rest of the code is portable.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006,2007,2008,2009
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
 *
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"

#if defined MAP_ANONYMOUS && !defined MAP_ANON
# define MAP_ANON MAP_ANONYMOUS
#endif

#ifndef MAP_FAILED
# define MAP_FAILED ((char *) -1)
#endif

int
_gst_mem_protect (PTR addr, size_t len, int prot)
{
#ifdef HAVE_MPROTECT
  return mprotect (addr, len, prot);
#else
  return -1;
#endif
}

/* We have three possible implementations: Win32, mmap-ing /dev/zero
   or using anonymous mmaps, and anonymous mmaps with MAP_NORESERVE. 
   There is support for providing fallback implementations, but it
   is not used currently.  */

typedef struct heap_implementation {
  mst_Boolean (*check) ();
  PTR (*reserve) (PTR, size_t);
  void (*release) (PTR, size_t);
  PTR (*commit) (PTR, size_t);
  void (*decommit) (PTR, size_t);
} heap_implementation;

#if defined MAP_AUTORESRV && !defined MAP_NORESERVE
# define MAP_NORESERVE MAP_AUTORESRV
#endif
#ifdef MAP_NORESERVE
static PTR noreserve_reserve (PTR, size_t);
static void noreserve_decommit (PTR, size_t);
#endif
static mst_Boolean anon_mmap_check (void);
static PTR anon_mmap_reserve (PTR, size_t);
static void anon_mmap_release (PTR, size_t);
static PTR anon_mmap_commit (PTR, size_t);

struct heap_implementation heap_impl_tab[] = {
#ifdef MAP_NORESERVE
  { NULL, noreserve_reserve, _gst_osmem_free, anon_mmap_commit, noreserve_decommit },
#endif
  { anon_mmap_check, anon_mmap_reserve, anon_mmap_release, anon_mmap_commit, _gst_osmem_free },
  { NULL, NULL, NULL, NULL, NULL }
};

static heap_implementation *impl;


PTR
_gst_osmem_reserve (PTR address, size_t size)
{
  if (!impl)
    {
      /* Find an implementation of heaps that is ok for this machine.
         The check is done at run-time because it is cheap.  */
      for (impl = heap_impl_tab; impl->reserve; impl++)
        if (!impl->check || impl->check ())
	  return impl->reserve (address, size);

      /* Not found, check again the next time just in case and return
         ENOMEM.  */
      impl = NULL;
      errno = ENOMEM;
      return (NULL);
    }
  else
    return impl->reserve (address, size);
}

void
_gst_osmem_release (PTR base, size_t size)
{
  impl->release (base, size);
}

PTR
_gst_osmem_commit (PTR base, size_t size)
{
  return impl->commit (base, size);
}

void
_gst_osmem_decommit (PTR base, size_t size)
{
  impl->decommit (base, size);
}

PTR
_gst_osmem_alloc (size_t size)
{
  PTR addr;
  addr = mmap (NULL, size,
   	       PROT_READ | PROT_WRITE | PROT_EXEC,
   	       MAP_ANON | MAP_PRIVATE, -1, 0);

  return addr == MAP_FAILED ? NULL : addr;
}

void
_gst_osmem_free (PTR ptr, size_t size)
{
  munmap (ptr, size);
}

#ifdef MAP_NORESERVE
/* Implementation of the four basic primitives when MAP_NORESERVE
   is available.  */

PTR
noreserve_reserve (PTR address, size_t size)
{
  PTR result = mmap (address, size, PROT_NONE,
   		     MAP_ANON | MAP_PRIVATE | MAP_NORESERVE, -1, 0);

  return result == MAP_FAILED ? NULL : result;
}

void
noreserve_decommit (PTR base, size_t size)
{
  mmap (base, size, PROT_NONE,
	MAP_ANON | MAP_PRIVATE | MAP_NORESERVE | MAP_FIXED, -1, 0);
}
#endif

/* Implementation of the four basic primitives when MAP_NORESERVE
   is not available.  Not foolproof, but we try to keep the balance
   between simplicity and usefulness.  */

static char *baseaddr;

PTR
anon_mmap_reserve (PTR address, size_t size)
{
  PTR base;

  /* We must check for overflows in baseaddr!  Note that we ignore address.  */
  if (((uintptr_t) baseaddr) + size < (uintptr_t) baseaddr)
    {
      errno = ENOMEM;
      return NULL;
    }
  else
    {
      base = baseaddr;
      baseaddr += size;
      return base;
    }
}

void
anon_mmap_release (PTR base, size_t size)
{
  if ((char *) baseaddr == (char *) base + size)
    baseaddr = base;
}

PTR
anon_mmap_commit (PTR base, size_t size)
{
  PTR result = mmap (base, size,
   		     PROT_READ | PROT_WRITE | PROT_EXEC,
		     MAP_ANON | MAP_PRIVATE | MAP_FIXED, -1, 0);

  return UNCOMMON (result == MAP_FAILED) ? NULL : result;
}

/* This is hairy and a hack.  We have to find a place for our heaps...  */

/* This signal handler is used if it is the only means to decide if
   a page is mapped into memory.  We intercept SIGSEGV and decide
   that the heap can be allocated at a given location only if we
   receive a signal.

   We also try access(2) and EFAULT, but it is not ensured that it
   works because the whole EFAULT business is quite unclear; however
   it is worth doing because debugging is way more painful if we
   have SIGSEGV's as part of the normal initialization sequence.  */

static RETSIGTYPE not_mapped (int sig);
static jmp_buf already_mapped;

RETSIGTYPE
not_mapped (sig)
     int sig;
{
  _gst_set_signal_handler (sig, not_mapped);
  longjmp (already_mapped, 1);
}

mst_Boolean
anon_mmap_check (void)
{
  volatile char *mmapGuess, *higher, *lower;	/* reference addresses */
  volatile char *first = NULL, *second;	/* probed addresses */
  volatile const int *step;

  static const int steps[] = {
    true, 256, 256, 0,		/* try 256 Mb after the higher address */
    true, 128, 256, 0,		/* try 128 Mb after the higher address */
    true, 64, 256, 0,		/* try 64 Mb after the higher address */
    false, 256, 256, 512,	/* try 256 Mb after the lower address */
    false, 128, 256, 384,	/* try 128 Mb after the lower address */
    false, 64, 256, 320,	/* try 64 Mb after the lower address */
    true, 32, 256, 0,		/* try 32 Mb after the higher address */
    true, 32, 128, 0,		/* again, for a smaller heap */
    false, 64, 128, 192,	/* this has a smaller heap too */
    -1
  };

  volatile int test, *testPtr = &test;
  volatile SigHandler oldSegvHandler;
  int pagesize = getpagesize();

  if (baseaddr)
    return (true);

  /* Placate GNU C's warnings about clobbered variables */
  testPtr = (volatile int *) &higher;
  testPtr = (volatile int *) &lower;
  testPtr = (volatile int *) &first;
  testPtr = (volatile int *) &step;
  testPtr = (volatile int *) &test;

  /* Install custom signal handlers to detect failed memory accesses */
  oldSegvHandler = _gst_set_signal_handler (SIGSEGV, not_mapped);

  /* Get two reference addresses which we will base ourselves on */
  mmapGuess = higher = _gst_osmem_alloc (pagesize);
  lower = sbrk (0);

  if (higher < lower)
    {
      higher = lower;
      lower = mmapGuess;
    }

  /* Now try each of the possibilities...  */
  for (step = steps; *step > -1; step += 4)
    {
      if (higher > lower + (step[3] << 20))
	{
	  first = ((step[0] ? higher : lower) + (step[1] << 20));
	  second = (first + (step[2] << 20));
	  assert ( ((intptr_t)first & (pagesize-1)) == 0);
	  assert ( ((intptr_t)second & (pagesize-1)) == 0);

	  /* Try reading the two locations */
	  if (setjmp (already_mapped) == 0)
	    {
	      errno = 0;
	      access ((char *) first, F_OK);
	      if (errno != EFAULT)
		{
		  *testPtr = *first;
	          continue;
		}
	    }
	  if (setjmp (already_mapped) == 0)
	    {
	      errno = 0;
	      access ((char *) second, F_OK);
	      if (errno != EFAULT)
		{
		  *testPtr = *second;
	          continue;
		}
	    }

	  /* Try mmap-ing them */
	  if (!anon_mmap_commit ((char *) first, pagesize))
	    continue;

	  _gst_osmem_free ((char *) first, pagesize);
	  if (!anon_mmap_commit ((char *) second, pagesize))
	    continue;

	  /* Were not readable and could be mmap-ed.  We're done.  */
	  _gst_osmem_free ((char *) second, pagesize);
	  break;
	}
    }

  /* Restore things...  */
  _gst_set_signal_handler (SIGSEGV, oldSegvHandler);

  munmap ((char *) mmapGuess, pagesize);

  if (first == NULL || *step == -1)
    return (false);
  else
    {
      baseaddr = (PTR) first;
      return (true);
    }
}
