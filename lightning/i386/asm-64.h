/******************************** -*- C -*- ****************************
 *
 *	Run-time assembler for the x86-64
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 2006 Matthew Flatt
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




#ifndef __lightning_asm_h
#define __lightning_asm_h

#include "asm-i386.h"

/*	OPCODE	+ i		= immediate operand
 *		+ r		= register operand
 *		+ m		= memory operand (disp,base,index,scale)
 *		+ sr/sm		= a star preceding a register or memory
 */


#ifndef LIGHTNING_DEBUG
#define _R12            0x4C
#define _R13            0x4D
#define JIT_CALLTMPSTART 0x48
#define JIT_REXTMP       0x4B

#define _qMrm(Md,R,M)	_jit_B((_M(Md)<<6)|(_r((R & 0x7))<<3)|_m((M & 0x7)))
#define _r_D(	R, D	  )	(_Mrm(_b00,_rN(R),_b100 ),_SIB(0,_b100,_b101)	     ,_jit_I((long)(D)))
#define _r_Q(	R, D	  )	(_qMrm(_b00,_rN(R),_b100 ),_SIB(0,_b100,_b101)        ,_jit_I((long)(D)))

#define  _REX(R,X,B)                              ( _jit_B(0x48|((R&0x8)>>1)|((X&0x8)>>2)|((B&0x8)>>3)) )
#define  _qO(	     OP, R,X,B			)  ( _REX(R,X,B), _jit_B(  OP	) )
#define  _qOr(	     OP,R			)  ( _REX(0,0,R), _jit_B( (OP)|_r(R&0x7))				  )
#define  _qOs(	     OP, B, R, M	       	)  ( _REX(0, M, R), _Os(OP, B) )

#define ADDQrr(RS, RD)			_qO_Mrm		(0x01		,_b11,_r8(RS),_r8(RD)				)
#define ADDQir(IM, RD)			_qOs_Mrm_sL	(0x81		,_b11,_b000  ,_r8(RD)			,IM	)

#define ANDQrr(RS, RD)			_qO_Mrm		(0x21		,_b11,_r8(RS),_r8(RD)				)
#define ANDQir(IM, RD)			_qOs_Mrm_sL	(0x81		,_b11,_b100  ,_r8(RD)			,IM	)

#define CALLm(D,B,I,S)	                (MOVQir((D), JIT_REXTMP), CALLQsr(JIT_REXTMP))

#define CALLsr(R)			_O_Mrm	(0xff	,_b11,_b010,_r4(R)			)
#define CALLQsr(R)                       _qO_Mrm (0xff	,_b11,_b010,_r8(R))

#define CMPQrr(RS, RD)			_qO_Mrm		(0x39		,_b11,_r8(RS),_r8(RD)				)
#define CMPQir(IM, RD)			_qO_Mrm_L	(0x81		,_b11,_b111  ,_r8(RD)			,IM	)

#define JCCim(CC,D,B,I,S) (!_jitl.long_jumps \
                               ? _OO_D32(0x0f80|(CC), (long)(D) ) \
                               : (_O_D8(0x71^(CC), _jit_UL(_jit.x.pc) + 13), JMPm((long)D, 0, 0, 0)))

#define JMPm(D,B,I,S) (!_jitl.long_jumps \
                       ? _O_D32(0xe9, (long)(D)) \
                       : (MOVQir((D), JIT_REXTMP), _qO_Mrm(0xff,_b11,_b100,_r8(JIT_REXTMP))))

#define LEAQmr(MD, MB, MI, MS, RD)	_qO_r_X		(0x8d		     ,_r8(RD)		,MD,MB,MI,MS		)
#define MOVQmr(MD, MB, MI, MS, RD)	_qO_r_X		(0x8b		     ,_r8(RD)		,MD,MB,MI,MS		)
#define MOVQrm(RS, MD, MB, MI, MS)	_qO_r_X		(0x89		     ,_r8(RS)		,MD,MB,MI,MS		)
#define MOVQrQm(RS, MD, MB, MI, MS)	_qO_r_XB      	(0x89		     ,_r8(RS)		,MD,MB,MI,MS		)
#define MOVQir(IM,  R)			_qOr_Q	        (0xb8,_r8(R)			,IM	)

#define MOVQrr(RS, RD)			_qO_Mrm		(0x89		,_b11,_r8(RS),_r8(RD)				)

#define NEGQr(RD)			_qO_Mrm		(0xf7		,_b11,_b011  ,_r8(RD)				)

#define ORQrr(RS, RD)			_qO_Mrm		(0x09		,_b11,_r8(RS),_r8(RD)				)
#define ORQir(IM, RD)			_qOs_Mrm_sL	(0x81		,_b11,_b001  ,_r8(RD)			,IM	)

#define POPQr(RD)			_qOr		(0x58,_r8(RD)							)

#define PUSHQr(R)			_qOr		(0x50,_r8(R)							)
#define SALQir	SHLQir
#define SALQim	SHLQim
#define SALQrr	SHLQrr
#define SALQrm	SHLQrm

#define SARQir(IM,RD)		(((IM)==1) ?	_qO_Mrm		(0xd1	,_b11,_b111,_r8(RD)				) : \
						_qO_Mrm_B	(0xc1	,_b11,_b111,_r4(RD)			,_u8(IM) ) )
#define SARQrr(RS,RD)		(((RS)==_CL) ?	_qO_Mrm		(0xd3	,_b11,_b111,_r8(RD)				) : \
						JITFAIL		("source register must be CL"				) )


#define SHLQir(IM,RD)		(((IM)==1) ?	_qO_Mrm		(0xd1	,_b11,_b100,_r8(RD)				) : \
						_qO_Mrm_B	(0xc1	,_b11,_b100,_r8(RD)			,_u8(IM) ) )
#define SHLQrr(RS,RD)		(((RS)==_CL) ?	_qO_Mrm		(0xd3	,_b11,_b100,_r8(RD)				) : \
						JITFAIL		("source register must be CL"				) )


#define SHRQir(IM,RD)		(((IM)==1) ?	_qO_Mrm		(0xd1	,_b11,_b101,_r8(RD)				) : \
						_qO_Mrm_B	(0xc1	,_b11,_b101,_r8(RD)			,_u8(IM) ) )
#define SHRQrr(RS,RD)		(((RS)==_CL) ?	_qO_Mrm		(0xd3	,_b11,_b101,_r8(RD)				) : \
						JITFAIL		("source register must be CL"				) )


#define SUBQrr(RS, RD)			_qO_Mrm		(0x29		,_b11,_r8(RS),_r8(RD)				)
#define SUBQir(IM, RD)			_qOs_Mrm_sL	(0x81		,_b11,_b101  ,_r8(RD)			,IM	)

#define TESTQrr(RS, RD)			_qO_Mrm		(0x85		,_b11,_r8(RS),_r8(RD)				)
#define TESTQir(IM, RD)			_qO_Mrm_L	(0xf7		,_b11,_b000  ,_r8(RD)			,IM	)

#define XORQrr(RS, RD)			_qO_Mrm		(0x31		,_b11,_r8(RS),_r8(RD)				)
#define XORQir(IM, RD)			_qOs_Mrm_sL	(0x81		,_b11,_b110  ,_r8(RD)			,IM	)

#endif
#endif /* __lightning_asm_h */


