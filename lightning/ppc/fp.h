/******************************** -*- C -*- ****************************
 *
 *	Run-time assembler & support macros for the Sparc math unit
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 2000, 2001, 2002 Free Software Foundation, Inc.
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




#ifndef __lightning_asm_fp_h
#define __lightning_asm_fp_h

#if 0

/* dummy for now */

#define jit_add_two(reg0)	FADDrrr(13 - (reg0), 13 - (reg0), 12 - (reg0))
#define jit_sub_two(reg0)	FSUBrrr(13 - (reg0), 13 - (reg0), 12 - (reg0))
#define jit_mul_two(reg0)	FMULrrr(13 - (reg0), 13 - (reg0), 12 - (reg0))
#define jit_div_two(reg0)	FDIVrrr(13 - (reg0), 13 - (reg0), 12 - (reg0))

#define jit_abs(reg0)		FABSr(13 - (reg0))
#define jit_sqrt(reg0)		FSQRTr(13 - (reg0))
#define jit_neg(reg0)		FNEGr(13 - (reg0))

#define jit_ldxi_f(reg0, rs, is) 0
#define jit_ldxr_f(reg0, s1, s2) 0
#define jit_ldxi_d(reg0, rs, is) 0
#define jit_ldxr_d(reg0, s1, s2) 0
#define jit_ldi_f(reg0, is) 0
#define jit_ldr_f(reg0, rs) 0
#define jit_ldi_d(reg0, is) 0
#define jit_ldr_d(reg0, rs) 0
#define jit_stxi_f(id, rd, reg0) 0
#define jit_stxr_f(d1, d2, reg0) 0
#define jit_stxi_d(id, rd, reg0) 0
#define jit_stxr_d(d1, d2, reg0) 0
#define jit_sti_f(id, reg0) 0
#define jit_str_f(rd, reg0) 0
#define jit_sti_d(id, reg0) 0
#define jit_str_d(rd, reg0) 0

/* Make space for 1 or 2 words, store address in REG */
#define jit_data(REG, D1)	(_FBA	(18, 8, 0, 1), _L(D1), MFLRr(REG))
#define jit_data2(REG, D1, D2)	(_FBA	(18, 12, 0, 1), _L(D1), _L(D2), MFLRr(REG))

#define jit_fpimm(reg0, first, second)		\
	(jit_data2(JIT_AUX, (first), (second)),	\
	 jit_ldxi_d((reg0), JIT_AUX, 0))

#define jit_floor(rd, reg0)	jit_call_fp((rd), (reg0), floor)
#define jit_ceil(rd, reg0)	jit_call_fp((rd), (reg0), ceil)

#define jit_call_fp(rd, reg0, fn)						\
	jit_fail(#fn " not supported", __FILE__, __LINE__, __FUNCTION__)
/*	pass reg0 as first parameter of rd
	bl	fn
	mr	r3, rd */

#define jit_trunc(rd, reg0)	(jit_data((rd), 0), 				\
				FCTIWZrr(13 - (reg0), 13 - (reg0)),		\
				STFIWXrrr(13 - (reg0), 0, (rd)),			\
				LWZrm((rd), 0, (rd)))

#define jit_round(rd, reg0)	(jit_data((rd), 0),				\
				FCTIWrr(13 - (reg0), 13 - (reg0)),		\
				STFIWXrrr(13 - (reg0), 0, (rd)),			\
				LWZrm((rd), 0, (rd)))
				
#define jit_cmp(le, ge, reg0)	(FCMPOirr(7, 13 - (reg0), 0),	   	   \
				CRORiii(28 + _gt, 28 + _gt, 28 + _eq),	   \
				CRORiii(28 + _lt, 28 + _lt, 28 + _eq),	   \
				MFCRr((ge)), 				   \
				EXTRWIrrii((le), (ge), 1, 28 + _lt),	   \
				EXTRWIrrii((ge), (ge), 1, 28 + _gt))

#endif

#endif /* __lightning_asm_h */
