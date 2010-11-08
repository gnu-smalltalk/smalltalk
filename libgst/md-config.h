/******************************** -*- C -*- ****************************
 *
 *	Definitions to squeeze out every % of speed
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 */

#ifndef GST_MD_CONFIG_H
#define GST_MD_CONFIG_H

#if defined(__mips__)
# define REG_AVAILABILITY 2
# define __DECL_REG1 __asm("$16")
# define __DECL_REG2 __asm("$17")
# define __DECL_REG3 __asm("$18")
#endif

#if !defined(__DECL_REG1) && defined(__sparc__)
# define REG_AVAILABILITY 1
# define __DECL_REG1 __asm("%l0")
# define __DECL_REG2 __asm("%l1")
# define __DECL_REG3 __asm("%l2")
#endif

#if !defined(__DECL_REG1) && defined(__alpha__)
# define REG_AVAILABILITY 2
/* Note: REG3 causes compile problems when trying to fit 64-bit stuff in
 * registers.
 */
# ifdef __CRAY__
#  define __DECL_REG1 __asm("r9")
#  define __DECL_REG2 __asm("r10")
#  define __DECL_REG3		/* __asm("r11") */
# else
#  define __DECL_REG1 __asm("$9")
#  define __DECL_REG2 __asm("$10")
#  define __DECL_REG3		/* __asm("$11") */
# endif
# define L1_CACHE_SHIFT 6
#endif

#if !defined(__DECL_REG1) && defined(__i386__)
# define REG_AVAILABILITY 0
# define __DECL_REG1 __asm("%esi")
# define __DECL_REG2 __asm("%edi")
# define __DECL_REG3 /* no more caller-save regs if PIC is in use!  */
#endif

#if !defined(__DECL_REG1) && defined(__x86_64__)
# define REG_AVAILABILITY 1
# define __DECL_REG1 __asm("%r12")
# define __DECL_REG2 __asm("%r13")
# define __DECL_REG3 __asm("%rbx")
# define L1_CACHE_SHIFT 6
#endif

#if !defined(__DECL_REG1) && defined(PPC) || defined(_POWER) || defined(_IBMR2)
# define REG_AVAILABILITY 2
# define __DECL_REG1 __asm("26")
# define __DECL_REG2 __asm("27")
# define __DECL_REG3 __asm("28")
#endif

#if !defined(__DECL_REG1) && defined(__hppa__)
# define REG_AVAILABILITY 2
# define __DECL_REG1 __asm("%r16")
# define __DECL_REG2 __asm("%r17")
# define __DECL_REG3 __asm("%r18")
#endif

#if !defined(__DECL_REG1) && defined(__mc68000__)
/* Has lots of registers, but REG_AVAILABILITY == 1 currently
 * helps on RISC machines only.  Things might change however.  */
# define REG_AVAILABILITY 0
# define __DECL_REG1 __asm("a5")
# define __DECL_REG2 __asm("a4")
# define __DECL_REG3 __asm("d7")
# define L1_CACHE_SHIFT 4
#endif

#if defined(__ia64) && defined(__GNUC__)
# define REG_AVAILABILITY 3
# define BRANCH_REGISTER(name) register void *name __asm("b4")
# define L1_CACHE_SHIFT 7
#endif

#if defined(__s390__)
# define REG_AVAILABILITY 2
# define L1_CACHE_SHIFT 7
#endif

/* Define a way to align cache-sensitive data on the proper boundaries */

#ifndef L1_CACHE_SHIFT
# define L1_CACHE_SHIFT 5
#endif

#if defined(__GNUC__)
# define CACHELINE_ALIGNED __attribute__((__aligned__(1 << L1_CACHE_SHIFT)))
#else
# define CACHELINE_ALIGNED
#endif

/* Some compilers underestimate the use of the local variables and and
   don't put them in hardware registers, or (especially) do unneeded
   spills and reloads.  This slows down the interpreter considerably.
   For GCC, this provides the ability to hand-assign hardware
   registers for several common architectures.  */

#ifndef REG_AVAILABILITY
# define REG_AVAILABILITY 1
#endif

#if !defined(__GNUC__) || !defined(__DECL_REG1) || !defined(__OPTIMIZE__)
# define REGISTER(reg, decl)	register decl
#else
# define __DECL_REG(k)		k
# define REGISTER(reg, decl)	register decl __DECL_REG(__DECL_REG##reg)
#endif

#endif /* GST_MD_CONFIG_H */
