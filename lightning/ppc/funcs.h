/******************************** -*- C -*- ****************************
 *
 *	Platform-independent layer inline functions (PowerPC)
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU lightning.
 *
 * GNU lightning is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1, or (at your option)
 * any later version.
 * 
 * GNU lightning is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with GNU lightning; see the file COPYING.LESSER; if not, write to the
 * Free Software Foundation, 59 Temple Place - Suite 330, Boston,
 * MA 02111-1307, USA.
 *
 ***********************************************************************/



#ifndef __lightning_funcs_h
#define __lightning_funcs_h

#if !defined(__GNUC__) && !defined(__GNUG__)
#error Go get GNU C, I do not know how to flush the cache
#error with this compiler.
#else
static void
jit_flush_code(void *start, void *end)
{
#ifndef LIGHTNING_CROSS
  register char *ddest, *idest;

  static int cache_line_size;
  if (cache_line_size == 0) {
    char buffer[8192];
    int i, probe;

    /* Find out the size of a cache line by zeroing one */
    memset(buffer, 0xFF, 8192);
    __asm__ __volatile__ ("dcbz 0,%0" : : "r"(buffer + 4096));

    /* Probe for the beginning of the cache line. */
    for(i = 0, probe = 4096; probe; probe >>= 1)
      if (buffer[i | probe] != 0x00)
        i |= probe;

    /* i is now just before the start of the cache line */
    i++;
    for(cache_line_size = 1; i + cache_line_size < 8192; cache_line_size <<= 1)
      if (buffer[i + cache_line_size] != 0x00)
        break;
  }

  start -= ((long) start) & (cache_line_size - 1);
  end -= ((long) end) & (cache_line_size - 1);

  /* Force data cache write-backs */
  for (ddest = start; ddest <= (char *) end; ddest += cache_line_size) {
    __asm__ __volatile__ ("dcbst 0,%0" : : "r"(ddest));
  }
  __asm__ __volatile__ ("sync" : : );

  /* Now invalidate the instruction cache */
  for (idest = start; idest <= (char *) end; idest += cache_line_size) {
    __asm__ __volatile__ ("icbi 0,%0" : : "r"(idest));
  }
  __asm__ __volatile__ ("isync" : : );
#endif /* !LIGHTNING_CROSS */
}
#endif /* __GNUC__ || __GNUG__ */

#define _jit (*jit)

/* Emit a trampoline for a function.
 * Upon entrance to the trampoline:
 *   - R0      = return address for the function
 *   - LR      = address where the real code for the function lies
 *   - R3-R8   = parameters
 * After jumping to the address pointed to by R10:
 *   - LR      = address where the epilog lies (the function must return there)
 *   - R25-R20 = parameters (order is reversed, 1st argument is R25)
 */
static jit_insn *
_jit_trampoline(jit, n)
     register jit_state *jit;
     register int	n;
{
  static jit_insn	trampolines[200];
  static jit_insn	*p_trampolines[6], *free = trampolines;
  jit_insn		*trampo;
  int			i, ofs, frame_size;

  if (!p_trampolines[n]) {
    _jit.x.pc = trampo = p_trampolines[n] = free;

    frame_size = 24 + (6 + n) * 4;	/* r26..r31 + args		   */
    frame_size += 15;			/* the stack must be quad-word     */
    frame_size &= ~15;			/* aligned			   */

    STWUrm(1, -frame_size, 1);		/* stwu  r1, -x(r1)		   */

    for (ofs = frame_size - (6 + n) * 4, i = 26 - n; i <= 31; ofs += 4, i++) {
      STWrm(i, ofs, 1);			/* stw   rI, ofs(r1)		   */
    }
    STWrm(0, ofs+4, 1);			/* stw   r0, x(r1)		   */
    for (i = 0; i < n; i++) {
      MRrr(25-i, 3+i);			/* save parameters in r25..r20	   */
    }
    BLRL();				/* blrl				   */
    LWZrm(0, ofs+4, 1);			/* lwz   r0, x(r1)  (ret.addr.)    */
    MTLRr(0);				/* mtspr LR, r0			   */

    for (ofs = frame_size - (6 + n) * 4, i = 26 - n; i <= 31; ofs += 4, i++) {
      LWZrm(i, ofs, 1);			/* lwz   rI, ofs(r1)		   */
    }
    ADDIrri(1, 1, frame_size);		/* addi  r1, r1, x		   */
    BLR();				/* blr				   */

    jit_flush_code(trampo, _jit.x.pc);
    free = _jit.x.pc;
  }

  return p_trampolines[n];
}

static void
_jit_prolog(jit, n)
     register jit_state *jit;
     register int	n;
{
  register jit_insn	*save_pc, *trampo;

  save_pc = _jit.x.pc;
  trampo = _jit_trampoline(jit, n);
  _jit.x.pc = save_pc;

  _jitl.nextarg_get = 25;
  MFLRr(0);
  MOVEIri(10, trampo);
  MTLRr(10);
  BLRL();				/* blrl				  */
  MFLRr(31);				/* mflr  r31			  */
}

#undef _jit

#endif /* __lightning_funcs_h */
