/******************************** -*- C -*- ****************************
 *
 *	Run-time assembler & support macros for the i386 math coprocessor
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

#define ESCmi(D,B,I,S,OP)	_O_r_X(0xd8|(OP & 7), (OP >> 3), D,B,I,S)

#define FLDSm(D,B,I,S)		ESCmi(D,B,I,S,001)     /* fld m32real  */
#define FILDLm(D,B,I,S)		ESCmi(D,B,I,S,003)     /* fild m32int  */
#define FLDLm(D,B,I,S)		ESCmi(D,B,I,S,005)     /* fld m64real  */
#define FILDWm(D,B,I,S)		ESCmi(D,B,I,S,007)     /* fild m16int  */
#define FSTSm(D,B,I,S)		ESCmi(D,B,I,S,021)     /* fst m32real  */
#define FISTLm(D,B,I,S)		ESCmi(D,B,I,S,023)     /* fist m32int  */
#define FSTLm(D,B,I,S)		ESCmi(D,B,I,S,025)     /* fst m64real  */
#define FISTWm(D,B,I,S)		ESCmi(D,B,I,S,027)     /* fist m16int  */
#define FSTPSm(D,B,I,S)		ESCmi(D,B,I,S,031)     /* fstp m32real */
#define FISTPLm(D,B,I,S)	ESCmi(D,B,I,S,033)     /* fistp m32int */
#define FSTPLm(D,B,I,S)		ESCmi(D,B,I,S,035)     /* fstp m64real */
#define FISTPWm(D,B,I,S)	ESCmi(D,B,I,S,037)     /* fistp m16int */
#define FLDTm(D,B,I,S)		ESCmi(D,B,I,S,053)     /* fld m80real  */
#define FILDQm(D,B,I,S)		ESCmi(D,B,I,S,057)     /* fild m64int  */
#define FSTPTm(D,B,I,S)		ESCmi(D,B,I,S,073)     /* fstp m80real */
#define FISTPQm(D,B,I,S)	ESCmi(D,B,I,S,077)     /* fistp m64int */


#define jit_add_two(reg0)	_OO(0xdec1)			/* faddp */
#define jit_sub_two(reg0)	_OO(0xdee9)			/* fsubp */
#define jit_mul_two(reg0)	_OO(0xdec9)			/* fmulp */
#define jit_div_two(reg0)	_OO(0xdef9)			/* fdivp */

#define jit_abs(reg0)		_OO(0xd9e1)			/* fabs */
#define jit_sqr(reg0)		_OO(0xdcc8)			/* fmul st */
#define jit_sqrt(reg0)		_OO(0xd9fa)			/* fsqrt */

#define jit_exti_d(reg0, rs)	(PUSHLr((rs)), FILDLm(0, _ESP, 0, 0), POPLr((rs)))

#define jit_neg(reg0)		_OO(0xd9e0)			/* fchs */

#define jit_ldxr_f(reg0, s1, s2)	FLDSm(0, (s1), (s2), 1)
#define jit_ldxi_f(reg0, rs, is)	FLDSm((is), (rs), 0, 0)
#define jit_ldxr_f(reg0, s1, s2)	FLDSm(0, (s1), (s2), 1)
#define jit_ldxi_d(reg0, rs, is)	FLDLm((is), (rs), 0, 0)
#define jit_ldxr_d(reg0, s1, s2)	FLDLm(0, (s1), (s2), 1)
#define jit_ldi_f(reg0, is)		FLDSm((is), 0,    0, 0)
#define jit_ldr_f(reg0, rs)		FLDSm(0,    (rs), 0, 0)
#define jit_ldi_d(reg0, is)		FLDLm((is), 0,    0, 0)
#define jit_ldr_d(reg0, rs)		FLDLm(0,    (rs), 0, 0)
#define jit_stxi_f(id, rd, reg0)	FSTPSm((id), (rd), 0, 0)
#define jit_stxr_f(d1, d2, reg0)	FSTPSm(0, (d1), (d2), 1)
#define jit_stxi_d(id, rd, reg0)	FSTPLm((id), (rd), 0, 0)
#define jit_stxr_d(d1, d2, reg0)	FSTPLm(0, (d1), (d2), 1)
#define jit_sti_f(id, reg0)		FSTPSm((id), 0,    0, 0)
#define jit_str_f(rd, reg0)		FSTPSm(0,    (rd), 0, 0)
#define jit_sti_d(id, reg0)		FSTPLm((id), 0,    0, 0)
#define jit_str_d(rd, reg0)		FSTPLm(0,    (rd), 0, 0)

#define jit_fpimm(reg0, first, second)	\
	(PUSHLi(second),		\
	PUSHLi(first),			\
	FLDLm(0, _ESP, 0, 0),		\
	ADDLir(8, _ESP))


/* Assume round to near mode */
#define jit_floor(rd, reg0)	\
	jit_floor2((rd), ((rd) == _EDX ? _EAX : _EDX))

#define jit_ceil(rd, reg0)	\
	jit_ceil2((rd), ((rd) == _EDX ? _EAX : _EDX))

#define jit_trunc(rd, reg0)	\
	jit_trunc2((rd), ((rd) == _EDX ? _EAX : _EDX))

#define jit_calc_diff(ofs)		\
	FISTLm(ofs, _ESP, 0, 0),	\
	FILDLm(ofs, _ESP, 0, 0),	\
	_OO(0xdee9), /* fsubp */	\
	FSTPSm(4+ofs, _ESP, 0, 0)	\

/* The real meat */
#define jit_floor2(rd, aux)		\
	(PUSHLr(aux),			\
	SUBLir(8, _ESP),		\
	jit_calc_diff(0),		\
	POPLr(rd),			/* floor in rd */ \
	POPLr(aux),			/* x-round(x) in aux */ \
	ADDLir(0x7FFFFFFF, aux),	/* carry if x-round(x) < -0 */ \
	SBBLir(0, rd),			/* subtract 1 if carry */ \
	POPLr(aux))

#define jit_ceil2(rd, aux)		\
	(PUSHLr(aux),			\
	SUBLir(8, _ESP),		\
	jit_calc_diff(0),		\
	POPLr(rd),			/* floor in rd */ \
	POPLr(aux),			/* x-round(x) in aux */ \
	TESTLrr(aux, aux),		\
	SETGr(jit_reg8(aux)),		\
	SHRLir(1, aux),			\
	ADCLir(0, rd),			\
	POPLr(aux))

/* a mingling of the two above */
#define jit_trunc2(rd, aux)			\
	(PUSHLr(aux),				\
	SUBLir(12, _ESP),			\
	FSTSm(0, _ESP, 0, 0),			\
	jit_calc_diff(4),			\
	POPLr(aux),				\
	POPLr(rd),				\
	TESTLrr(aux, aux),			\
	POPLr(aux),				\
	JSSm(_jit.x.pc + 11, 0, 0, 0),		\
	ADDLir(0x7FFFFFFF, aux),	/* 6 */	\
	SBBLir(0, rd),			/* 3 */ \
	JMPSm(_jit.x.pc + 10, 0, 0, 0),	/* 2 */ \
	TESTLrr(aux, aux),		/* 2 */ \
	SETGr(jit_reg8(aux)),		/* 3 */ \
	SHRLir(1, aux),			/* 2 */ \
	ADCLir(0, rd),			/* 3 */ \
	POPLr(aux))

/* the easy one */
#define jit_round(rd, reg0)		\
	(PUSHLr(_EAX),			\
	FISTPLm(0, _ESP, 0, 0),		\
	POPLr((rd)))

#define jit_cmp(le, ge, reg0) (					\
	((le) == _EAX || (ge) == _EAX ? 0 : PUSHLr(_EAX)),	\
	_OO(0xd8d0),			/* fcom st(0) */	\
	_d16(), _OO(0xdfe0),		/* fnstsw ax */		\
	TESTBir(0x40, _AH),					\
	MOVBir(0, ((le) & 15) | 0x10),				\
	MOVBir(0, ((ge) & 15) | 0x10),				\
	JZSm(_jit.x.pc + 12, 0, 0, 0),				\
	_OO(0xd9e4),			/* ftst */	/* 2 */ \
	_d16(), _OO(0xdfe0),		/* fnstsw ax */	/* 3 */ \
	SAHF(),						/* 1 */ \
	SETLEr( ((le) & 15) | 0x10),			/* 3 */ \
	SETGEr( ((ge) & 15) | 0x10),			/* 3 */ \
	ANDLir( 1, (le)),					\
	ANDLir( 1, (ge)),					\
	((le) == _EAX || (ge) == _EAX ? 0 : POPLr(_EAX)) )

#define jitfp_getarg_f(ofs)             jitfp_ldxi_f(JIT_FP,(ofs))
#define jitfp_getarg_d(ofs)             jitfp_ldxi_d(JIT_FP,(ofs))
#define jitfp_pusharg_d(op1)            (jit_subi_i(JIT_SP,JIT_SP,sizeof(double)), jitfp_str_d(JIT_SP,(op1)))
#define jitfp_pusharg_f(op1)            (jit_subi_i(JIT_SP,JIT_SP,sizeof(float)), jitfp_str_f(JIT_SP,(op1)))
#define jitfp_retval(op1)               _jit_emit(&_jit, (op1), JIT_NULL, 0, 0, 0)

#ifdef JIT_TRANSCENDENTAL
#define jit_sin(reg0)		_OO(0xd9fe)			/* fsin */
#define jit_cos(reg0)		_OO(0xd9ff)			/* fcos */
#define jit_tan(reg0)		(_OO(0xd9f2), 			/* fptan */ \
				 _OO(0xddd8))			/* fstp st */
#define jit_atn(reg0)		(_OO(0xd9e8), 			/* fld1 */ \
				 _OO(0xd9f3))			/* fpatan */
#define jit_exp(reg0)		(_OO(0xd9ea), 			/* fldl2e */ \
				 _OO(0xdec9), 			/* fmulp */ \
				 _OO(0xd9c0),			/* fld st */ \
				 _OO(0xd9fc),		 	/* frndint */ \
				 _OO(0xdce9), 			/* fsubr */ \
				 _OO(0xd9c9), 			/* fxch st(1) */ \
				 _OO(0xd9f0), 			/* f2xm1 */ \
				 _OO(0xd9e8), 			/* fld1 */ \
				 _OO(0xdec1), 			/* faddp */ \
				 _OO(0xd9fd), 			/* fscale */ \
				 _OO(0xddd9))			/* fstp st(1) */
#define jit_log(reg0)		(_OO(0xd9ed), 			/* fldln2 */ \
				 _OO(0xd9c9), 			/* fxch st(1) */ \
				 _OO(0xd9f1))			/* fyl2x */
#endif

#endif /* __lightning_asm_h */
