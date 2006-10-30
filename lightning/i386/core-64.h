/******************************** -*- C -*- ****************************
 *
 *	Platform-independent layer (i386 version)
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



#ifndef __lightning_core_h
#define __lightning_core_h

#include "core-i386.h"

struct jit_local_state {
  int   long_jumps;
  int   nextarg_geti;
  int	argssize;
};

/* 3-parameter operation */
#define jit_qopr_(d, s1, s2, op1d, op2d)				\
	( (s2 == d) ? op1d :						\
	  (  ((s1 == d) ? (void)0 : (void)MOVQrr(s1, d)), op2d )	\
	)

/* 3-parameter operation, with immediate */
#define jit_qop_(d, s1, op2d)				\

#define jit_bra_qr(s1, s2, op)		(CMPQrr(s2, s1), op, _jit.x.pc)
#define _jit_bra_l(rs, is, op)		(CMPQir(is, rs), op, _jit.x.pc)

#define jit_bra_l(rs, is, op) (_s32P((long)(is)) \
                               ? _jit_bra_l(rs, is, op) \
                               : (jit_movi_l(JIT_REXTMP, is), jit_bra_qr(JIT_REXTMP, rs, op)))

/* When CMP with 0 can be replaced with TEST */
#define jit_bra_l0(rs, is, op, op0)					\
	( (is) == 0 ? (TESTQrr(rs, rs), op0, _jit.x.pc) : jit_bra_l(rs, is, op))

/* Used to implement ldc, stc, ... */
#define JIT_CAN_16 0

#define jit_reduceQ(op, is, rs)							\
	(_u8P(is) && jit_check8(rs) ? jit_reduce_(op##Bir(is, jit_reg8(rs))) :	\
	jit_reduce_(op##Qir(is, rs)) )

#define jit_addi_l(d, rs, is)	jit_opi_((d), (rs),       ADDQir((is), (d)), 			LEAQmr((is), (rs), 0, 0, (d))  )
#define jit_addr_l(d, s1, s2)	jit_opo_((d), (s1), (s2), ADDQrr((s2), (d)), ADDQrr((s1), (d)), LEAQmr(0, (s1), (s2), 1, (d))  )
#define jit_andi_l(d, rs, is)	jit_qop_ ((d), (rs),       ANDQir((is), (d)) 		       )
#define jit_andr_l(d, s1, s2)	jit_qopr_((d), (s1), (s2), ANDQrr((s1), (d)), ANDQrr((s2), (d)) )
#define jit_orr_l(d, s1, s2)	jit_qopr_((d), (s1), (s2),  ORQrr((s1), (d)),  ORQrr((s2), (d)) )
#define jit_subr_l(d, s1, s2)	jit_qopr_((d), (s1), (s2), (SUBQrr((s1), (d)), NEGQr(d)),	SUBQrr((s2), (d))	       )
#define jit_xorr_l(d, s1, s2)	jit_qopr_((d), (s1), (s2), XORQrr((s1), (d)), XORQrr((s2), (d)) )

/* These can sometimes use byte or word versions! */
#define jit_ori_i(d, rs, is)	jit_op_ ((d), (rs),        jit_reduce(OR, (is), (d))	       )
#define jit_xori_i(d, rs, is)	jit_op_ ((d), (rs),        jit_reduce(XOR, (is), (d))	       )
#define jit_ori_l(d, rs, is)	jit_qop_ ((d), (rs),        jit_reduceQ(OR, (is), (d))	       )
#define jit_xori_l(d, rs, is)	jit_qop_ ((d), (rs),        jit_reduceQ(XOR, (is), (d))	       )

#define jit_lshi_l(d, rs, is)	((is) <= 3 ?   LEAQmr(0, 0, (rs), 1 << (is), (d))   :   jit_qop_ ((d), (rs), SHLQir((is), (d)) ))
#define jit_rshi_l(d, rs, is)								jit_qop_ ((d), (rs), SARQir((is), (d))  )
#define jit_rshi_ul(d, rs, is)								jit_qop_ ((d), (rs), SHRQir((is), (d))  )
#define jit_lshr_l(d, r1, r2)	jit_replace((r1), (r2), _ECX, 				jit_qop_ ((d), (r1), SHLQrr(_CL,  (d)) ))
#define jit_rshr_l(d, r1, r2)	jit_replace((r1), (r2), _ECX, 				jit_qop_ ((d), (r1), SARQrr(_CL,  (d)) ))
#define jit_rshr_ul(d, r1, r2)	jit_replace((r1), (r2), _ECX, 				jit_qop_ ((d), (r1), SHRQrr(_CL,  (d)) ))

/* Stack */
#define jit_pushr_l(rs)		PUSHQr(rs)
#define jit_popr_l(rs)		POPQr(rs)

#define jit_base_prolog() (PUSHQr(_EBP), MOVQrr(_ESP, _EBP), PUSHQr(_EBX), PUSHQr(_R12), PUSHQr(_R13))
#define jit_prolog(n) (_jitl.nextarg_geti = 0, jit_base_prolog())

/* Stack isn't used for arguments: */
#define jit_prepare_i(ni)	(_jitl.argssize = 0)

#define jit_pusharg_i(rs)	(_jitl.argssize++, MOVQrr(rs, JIT_CALLTMPSTART + _jitl.argssize - 1))
#define jit_finish(sub)        (jit_shift_args(), (void)jit_calli((sub)), jit_restore_locals())
#define jit_reg_is_arg(reg) ((reg == _EDI) || (reg ==_ESI) || (reg == _EDX))
#define jit_finishr(reg)	((jit_reg_is_arg((reg)) ? MOVQrr(reg, JIT_REXTMP) : (void)0), \
                                 jit_shift_args(), \
                                 jit_reg_is_arg((reg)) ? CALQsr((JIT_REXTMP)) : jit_callr((reg)), \
                                 jit_restore_locals())

/* R12 and R13 are callee-save, instead of EDI and ESI.  Can be improved. */
#define jit_shift_args() \
   (MOVQrr(_ESI, _R12), MOVQrr(_EDI, _R13), \
   (_jitl.argssize--  \
    ? (MOVQrr(JIT_CALLTMPSTART + _jitl.argssize, jit_arg_reg_order[0]),  \
       (_jitl.argssize--  \
        ? (MOVQrr(JIT_CALLTMPSTART + _jitl.argssize, jit_arg_reg_order[1]),  \
           (_jitl.argssize--  \
            ? MOVQrr(JIT_CALLTMPSTART, jit_arg_reg_order[2])  \
            : (void)0)) \
        : (void)0)) \
    : (void)0))

#define jit_restore_locals() \
    (MOVQrr(_R12, _ESI), MOVQrr(_R13, _EDI))

#define jit_retval_l(rd)	((void)jit_movr_l ((rd), _EAX))
#define	jit_arg_i()	        (_jitl.nextarg_geti++)
#define	jit_arg_l()	        (_jitl.nextarg_geti++)
#define	jit_arg_p()	        (_jitl.nextarg_geti++)
#define jit_arg_reg(p)          (jit_arg_reg_order[p])
static int jit_arg_reg_order[] = { _EDI, _ESI, _EDX, _ECX };

#define jit_negr_l(d, rs)	jit_opi_((d), (rs), NEGQr(d), (XORQrr((d), (d)), SUBQrr((rs), (d))) )
#define jit_movr_l(d, rs)	((void)((rs) == (d) ? 0 : MOVQrr((rs), (d))))
#define jit_movi_l(d, is)	((is) \
                                 ? (_u32P((long)(is)) \
                                    ? MOVLir((is), (d)) \
                                    : MOVQir((is), (d))) \
                                 : XORLrr ((d), (d)) )

#define jit_bmsr_l(label, s1, s2)	(TESTQrr((s1), (s2)), JNZm(label,0,0,0), _jit.x.pc)
#define jit_bmcr_l(label, s1, s2)	(TESTQrr((s1), (s2)), JZm(label,0,0,0),  _jit.x.pc)
#define jit_boaddr_l(label, s1, s2)	(ADDQrr((s2), (s1)), JOm(label,0,0,0), _jit.x.pc)
#define jit_bosubr_l(label, s1, s2)	(SUBQrr((s2), (s1)), JOm(label,0,0,0), _jit.x.pc)
#define jit_boaddr_ul(label, s1, s2)	(ADDQrr((s2), (s1)), JCm(label,0,0,0), _jit.x.pc)
#define jit_bosubr_ul(label, s1, s2)	(SUBQrr((s2), (s1)), JCm(label,0,0,0), _jit.x.pc)

#define jit_boaddi_l(label, rs, is)	(ADDQir((is), (rs)), JOm(label,0,0,0), _jit.x.pc)
#define jit_bosubi_l(label, rs, is)	(SUBQir((is), (rs)), JOm(label,0,0,0), _jit.x.pc)
#define jit_boaddi_ul(label, rs, is)	(ADDQir((is), (rs)), JCm(label,0,0,0), _jit.x.pc)
#define jit_bosubi_ul(label, rs, is)	(SUBQir((is), (rs)), JCm(label,0,0,0), _jit.x.pc)

#define jit_patch_long_at(jump_pc,v)  (*_PSL((jump_pc) - sizeof(long)) = _jit_SL((jit_insn *)(v)))
#define jit_patch_short_at(jump_pc,v)  (*_PSI((jump_pc) - sizeof(int)) = _jit_SI((jit_insn *)(v) - (jump_pc)))
#define jit_patch_at(jump_pc,v) (_jitl.long_jumps ? jit_patch_long_at((jump_pc)-3, v) : jit_patch_short_at(jump_pc, v))
#define jit_ret() (POPQr(_R13), POPQr(_R12), POPQr(_EBX), POPQr(_EBP), RET_())

#define _jit_ldi_l(d, is)		MOVQmr((is), 0,    0,    0,  (d))
#define jit_ldr_l(d, rs)		MOVQmr(0,    (rs), 0,    0,  (d))
#define jit_ldxr_l(d, s1, s2)		MOVQmr(0,    (s1), (s2), 1,  (d))
#define jit_ldxi_l(d, rs, is)		MOVQmr((is), (rs), 0,    0,  (d))

#define _jit_sti_l(id, rs)		MOVQrm((rs), (id), 0,    0,    0)
#define jit_str_l(rd, rs)		MOVQrm((rs), 0,    (rd), 0,    0)
#define jit_stxr_l(d1, d2, rs)		MOVQrm((rs), 0,    (d1), (d2), 1)
#define jit_stxi_l(id, rd, rs)		MOVQrm((rs), (id), (rd), 0,    0)

#define jit_ldi_l(d, is) (_u32P((long)(is)) ? _jit_ldi_l(d, is) : (jit_movi_l(d, is), jit_ldr_l(d, d)))
#define jit_sti_l(id, rs) (_u32P((long)(id)) ? _jit_sti_l(id, rs) : (jit_movi_l(JIT_REXTMP, id), MOVQrQm(rs, 0, JIT_REXTMP, 0, 0)))

#define jit_blti_l(label, rs, is)	jit_bra_l0((rs), (is), JLm(label, 0,0,0), JSm(label, 0,0,0) )
#define jit_blei_l(label, rs, is)	jit_bra_l ((rs), (is), JLEm(label,0,0,0)		    )
#define jit_bgti_l(label, rs, is)	jit_bra_l ((rs), (is), JGm(label, 0,0,0)		    )
#define jit_bgei_l(label, rs, is)	jit_bra_l0((rs), (is), JGEm(label,0,0,0), JNSm(label,0,0,0) )
#define jit_beqi_l(label, rs, is)	jit_bra_l0((rs), (is), JEm(label, 0,0,0), JEm(label, 0,0,0) )
#define jit_bnei_l(label, rs, is)	jit_bra_l0((rs), (is), JNEm(label,0,0,0), JNEm(label,0,0,0) )
#define jit_blti_ul(label, rs, is)	jit_bra_l ((rs), (is), JBm(label, 0,0,0)		    )
#define jit_blei_ul(label, rs, is)	jit_bra_l0((rs), (is), JBEm(label,0,0,0), JEm(label, 0,0,0) )
#define jit_bgti_ul(label, rs, is)	jit_bra_l0((rs), (is), JAm(label, 0,0,0), JNEm(label,0,0,0) )
#define jit_bgei_ul(label, rs, is)	jit_bra_l ((rs), (is), JAEm(label,0,0,0)		    )
#define jit_bmsi_l(label, rs, is) jit_bmsi_i(label, rs, is)
#define jit_bmci_l(label, rs, is) jit_bmci_i(label, rs, is)

#define jit_pushr_l(rs) jit_pushr_i(rs)
#define jit_popr_l(rs)  jit_popr_i(rs)

#define jit_pusharg_l(rs) jit_pusharg_i(rs)
#define jit_retval_l(rd)	((void)jit_movr_l ((rd), _EAX))
#define jit_bltr_l(label, s1, s2)	jit_bra_qr((s1), (s2), JLm(label, 0,0,0) )
#define jit_bler_l(label, s1, s2)	jit_bra_qr((s1), (s2), JLEm(label,0,0,0) )
#define jit_bgtr_l(label, s1, s2)	jit_bra_qr((s1), (s2), JGm(label, 0,0,0) )
#define jit_bger_l(label, s1, s2)	jit_bra_qr((s1), (s2), JGEm(label,0,0,0) )
#define jit_beqr_l(label, s1, s2)	jit_bra_qr((s1), (s2), JEm(label, 0,0,0) )
#define jit_bner_l(label, s1, s2)	jit_bra_qr((s1), (s2), JNEm(label,0,0,0) )
#define jit_bltr_ul(label, s1, s2)	jit_bra_qr((s1), (s2), JBm(label, 0,0,0) )
#define jit_bler_ul(label, s1, s2)	jit_bra_qr((s1), (s2), JBEm(label,0,0,0) )
#define jit_bgtr_ul(label, s1, s2)	jit_bra_qr((s1), (s2), JAm(label, 0,0,0) )
#define jit_bger_ul(label, s1, s2)	jit_bra_qr((s1), (s2), JAEm(label,0,0,0) )

#endif /* __lightning_core_h */

