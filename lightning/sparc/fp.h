/******************************** -*- C -*- ****************************
 *
 *	Run-time assembler & support macros for the PowerPC math unit
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

#define _FP1(RD, RS1, OPF, RS2)	_2f((RD), 52, (RS1), (OPF), (RS2))
#define _FP2(RD, RS1, OPF, RS2)	_2f((RD), 53, (RS1), (OPF), (RS2))

#define FITODrr(FRS, FRD)		_FP1((FRD),  0, 200, (FRS))
#define FDTOIrr(FRS, FRD)		_FP1((FRD),  0, 210, (FRS))
#define FSTODrr(FRS, FRD)		_FP1((FRD),  0, 201, (FRS))
#define FDTOSrr(FRS, FRD)		_FP1((FRD),  0, 198, (FRS))
#define FMOVSrr(FRS, FRD)		_FP1((FRD),  0,   1, (FRS))
#define FNEGSrr(FRS, FRD)		_FP1((FRD),  0,   5, (FRS))
#define FABSSrr(FRS, FRD)		_FP1((FRD),  0,   9, (FRS))
#define FSQRTDrr(FRS, FRD)		_FP1((FRD),  0,  74, (FRS))

#define FADDDrrr(FRS1, FRS2, FRD)	_FP1((FRD),  (FRS1),  66, (FRS2))
#define FSUBDrrr(FRS1, FRS2, FRD)	_FP1((FRD),  (FRS1),  70, (FRS2))
#define FMULDrrr(FRS1, FRS2, FRD)	_FP1((FRD),  (FRS1),  82, (FRS2))
#define FDIVDrrr(FRS1, FRS2, FRD)	_FP1((FRD),  (FRS1),  86, (FRS2))

#define FCMPDrr(FRS1, FRS2)		_FP2(0,      (FRS1),  82, (FRS2))

#define LDFxr(RS1, RS2, RD)	_3   ((RD), 32, (RS1), 0, 0, (RS2))
#define LDFmr(RS1, IMM, RD)	_3i  ((RD), 32, (RS1), 1,    (IMM))
#define LDDFxr(RS1, RS2, RD)	_3   ((RD), 35, (RS1), 0, 0, (RS2))
#define LDDFmr(RS1, IMM, RD)	_3i  ((RD), 35, (RS1), 1,    (IMM))
#define STFrx(RS, RD1, RD2)	_3   ((RS), 36, (RD1), 0, 0, (RD2))
#define STFrm(RS, RD1, IMM)	_3i  ((RS), 36, (RD1), 1,    (IMM))
#define STDFrx(RS, RD1, RD2)	_3   ((RS), 39, (RD1), 0, 0, (RD2))
#define STDFrm(RS, RD1, IMM)	_3i  ((RS), 39, (RD1), 1,    (IMM))

#define FBNi(DISP)		_0   (0,  0, 6, (DISP))
#define FBN_Ai(DISP)		_0   (1,  0, 6, (DISP))
#define FBNEi(DISP)		_0   (0,  1, 6, (DISP))
#define FBNE_Ai(DISP)		_0   (1,  1, 6, (DISP))
#define FBLGi(DISP)		_0   (0,  2, 6, (DISP))
#define FBLG_Ai(DISP)		_0   (1,  2, 6, (DISP))
#define FBULi(DISP)		_0   (0,  3, 6, (DISP))
#define FBUL_Ai(DISP)		_0   (1,  3, 6, (DISP))
#define FBLi(DISP)		_0   (0,  4, 6, (DISP))
#define FBL_Ai(DISP)		_0   (1,  4, 6, (DISP))
#define FBUGi(DISP)		_0   (0,  5, 6, (DISP))
#define FBUG_Ai(DISP)		_0   (1,  5, 6, (DISP))
#define FBGi(DISP)		_0   (0,  6, 6, (DISP))
#define FBG_Ai(DISP)		_0   (1,  6, 6, (DISP))
#define FBUi(DISP)		_0   (0,  7, 6, (DISP))
#define FBU_Ai(DISP)		_0   (1,  7, 6, (DISP))
#define FBAi(DISP)		_0   (0,  8, 6, (DISP))
#define FBA_Ai(DISP)		_0   (1,  8, 6, (DISP))
#define FBEi(DISP)		_0   (0,  9, 6, (DISP))
#define FBE_Ai(DISP)		_0   (1,  9, 6, (DISP))
#define FBUEi(DISP)		_0   (0, 10, 6, (DISP))
#define FBUE_Ai(DISP)		_0   (1, 10, 6, (DISP))
#define FBGEi(DISP)		_0   (0, 11, 6, (DISP))
#define FBGE_Ai(DISP)		_0   (1, 11, 6, (DISP))
#define FBUGEi(DISP)		_0   (0, 12, 6, (DISP))
#define FBUGE_Ai(DISP)		_0   (1, 12, 6, (DISP))
#define FBLEi(DISP)		_0   (0, 13, 6, (DISP))
#define FBLE_Ai(DISP)		_0   (1, 13, 6, (DISP))
#define FBULEi(DISP)		_0   (0, 14, 6, (DISP))
#define FBULE_Ai(DISP)		_0   (1, 14, 6, (DISP))
#define FBOi(DISP)		_0   (0, 15, 6, (DISP))
#define FBO_Ai(DISP)		_0   (1, 15, 6, (DISP))

#define FSKIPUG()		_0d  (1, 13, 6, 2)	/* fble,a .+8 */
#define FSKIPUL()		_0d  (1, 11, 6, 2)	/* fbge,a .+8 */

#define jit_add_two(reg0)	FADDDrrr(30 - (reg0) * 2, 28 - (reg0) * 2, 30 - (reg0) * 2)
#define jit_sub_two(reg0)	FSUBDrrr(30 - (reg0) * 2, 28 - (reg0) * 2, 30 - (reg0) * 2)
#define jit_mul_two(reg0)	FMULDrrr(30 - (reg0) * 2, 28 - (reg0) * 2, 30 - (reg0) * 2)
#define jit_div_two(reg0)	FDIVDrrr(30 - (reg0) * 2, 28 - (reg0) * 2, 30 - (reg0) * 2)

#define jit_abs(reg0)		FABSSrr(30 - (reg0) * 2, 30 - (reg0) * 2)
#define jit_neg(reg0)		FNEGSrr(30 - (reg0) * 2, 30 - (reg0) * 2)
#define jit_sqrt(reg0)		FSQRTDrr(30 - (reg0) * 2, 30 - (reg0) * 2)

#define jit_fpimm(reg0, first, second)		\
	(_1(4), NOP(), _L(first), _L(second),	\
	 jit_ldxi_d((reg0), _Ro(7), 8))

#define jit_ldxi_f(reg0, rs, is)	(jit_chk_imm((is), LDFmr((rs), (is), 30 - (reg0) * 2), LDFxr((rs), JIT_BIG, 30 - (reg0) * 2)), FSTODrr(30 - (reg0) * 2, 30 - (reg0) * 2))
#define jit_ldxi_d(reg0, rs, is)	jit_chk_imm((is), LDDFmr((rs), (is), 30 - (reg0) * 2), LDDFxr((rs), JIT_BIG, 30 - (reg0) * 2))
#define jit_ldxr_f(reg0, s1, s2)	(LDFxr((s1), (s2), 30 - (reg0) * 2), FSTODrr(30 - (reg0) * 2, 30 - (reg0) * 2))
#define jit_ldxr_d(reg0, s1, s2)	LDDFxr((s1), (s2), 30 - (reg0) * 2)
#define jit_stxi_f(id, rd, reg0)	(FDTOSrr(30 - (reg0) * 2, 30 - (reg0) * 2), jit_chk_imm((id), STFrm(30 - (reg0) * 2, (rd), (id)), STFrx(30 - (reg0) * 2, (rd),  JIT_BIG)))
#define jit_stxi_d(id, rd, reg0)					  jit_chk_imm((id), STDFrm(30 - (reg0) * 2, (rd), (id)), STDFrx(30 - (reg0) * 2, (rd),  JIT_BIG))
#define jit_stxr_f(d1, d2, reg0)	(FDTOSrr(30 - (reg0) * 2, 30 - (reg0) * 2), STFrx (30 - (reg0) * 2, (d1), (d2)))
#define jit_stxr_d(d1, d2, reg0)					  STDFrx(30 - (reg0) * 2, (d1), (d2))


#define jit_do_round(mode, rd, freg)	(			\
	_1(3),							\
	SETHIir(_HI(mode << 29), JIT_BIG),			\
	NOP(),							\
	STFSRm(_Ro(7), 8),		/* store fsr */		\
	LDmr(_Ro(7), 8, rd),					\
	XORrrr(rd, JIT_BIG, JIT_BIG),	/* adjust mode */	\
	STrm(JIT_BIG, _Ro(7), 8),				\
	LDFSRm(_Ro(7), 8),		/* load fsr */		\
	FDTOIrr(freg, freg), 		/* truncate */		\
	STrm(rd, _Ro(7), 8),		/* load old fsr */	\
	LDFSRm(_Ro(7), 8),					\
	STFrm(freg, _Ro(7), 8),		/* store truncated value */ \
	LDmr(_Ro(7), 8, rd))		/* load it into rd */


/*					 call	delay slot			 data	,--- call lands here */
#define jit_exti_d(reg0, rs)		(_1(3), NOP(), 				 NOP(), STrm((rs), _Ro(7), 8), LDFmr(_Ro(7), 8, 30 - (reg0) * 2), FITODrr(30 - (reg0) * 2, 30 - (reg0) * 2))
#define jit_round(rd, reg0)		(_1(3), FDTOIrr(30 - (reg0) * 2, 30 - (reg0) * 2), NOP(), STFrm(30 - (reg0) * 2, _Ro(7), 8), LDmr(_Ro(7), 8, (rd)))
#define jit_floor(rd, reg0)		jit_do_round(3, (rd), (30 - (reg0) * 2))
#define jit_ceil(rd, reg0)		jit_do_round(2, (rd), (30 - (reg0) * 2))
#define jit_trunc(rd, reg0)		jit_do_round(1, (rd), (30 - (reg0) * 2))

static double jit_zero = 0.0;

#define jit_cmp(le, ge, reg0)		(SETHIir(_HI(_UL(&jit_zero)), (le)), 			\
					 LDDFmr((le), _LO(_UL(&jit_zero)), 28 - (reg0) * 2),	\
					 FCMPDrr(30 - (reg0) * 2, 28 - (reg0) * 2),			\
					 MOVir(0, (le)), MOVir(0, (ge)),			\
					 FSKIPUL(), MOVir(1, (ge)),				\
					 FSKIPUG(), MOVir(1, (le)))

#endif

#endif /* __lightning_asm_fp_h */
