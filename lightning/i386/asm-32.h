/******************************** -*- C -*- ****************************
 *
 *	Run-time assembler for the i386
 *
 ***********************************************************************/


/***********************************************************************
 *
 * Copyright 2006 Free Software Foundation, Inc.
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

/*	OPCODE	+ i		= immediate operand
 *		+ r		= register operand
 *		+ m		= memory operand (disp,base,index,scale)
 *		+ sr/sm		= a star preceding a register or memory
 */

#include "asm-i386.h"

#ifndef LIGHTNING_DEBUG

#define _r_D(	R, D	  )	(_Mrm(_b00,_rN(R),_b101 )		             ,_jit_I((long)(D)))

#define CALLm(D,B,I,S)			((_r0P(B) && _r0P(I)) ? _O_D32	(0xe8			,(long)(D)		) : \
								JITFAIL("illegal mode in direct jump"))

#define JCCim(CC,D,B,I,S)		((_r0P(B) && _r0P(I)) ? _OO_D32	(0x0f80|(CC)		,(long)(D)		) : \
								JITFAIL("illegal mode in conditional jump"))

#define JMPm(D,B,I,S)			((_r0P(B) && _r0P(I)) ? _O_D32	(0xe9			,(long)(D)		) : \
								JITFAIL("illegal mode in direct jump"))

#endif
#endif /* __lightning_asm_h */


