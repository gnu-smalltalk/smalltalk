/******************************** -*- C -*- ****************************
 *
 *	Platform-independent layer floating-point interface
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

struct jit_fp {
  char	kind;
  char  subkind;
  union {
    struct {
      int   displ;
      char  reg1;
      char  reg2;
    } addr;
    union {
      double number;
      long   split[sizeof(double) / sizeof(long)];
    } imm;
    struct {
      struct jit_fp *lhs, *rhs;
    } ops;
  } d;
};

#ifdef jit_trunc

enum {	JIT_NULL,						/* unused */
        
        JIT_CMP, JIT_FLOOR, JIT_CEIL, JIT_ROUND, JIT_TRUNC,	/* integer */
	
	JIT_XI, JIT_ADD, JIT_XR, JIT_SUB,			/* subkinds */
	JIT_I,  JIT_MUL, JIT_R,  JIT_DIV,
	JIT_INT,
	
	JIT_ABS, JIT_SIN, JIT_COS, JIT_TAN, JIT_ATN,		/* functions */
	JIT_EXP, JIT_LOG, JIT_NEG, JIT_SQRT,
	
	JIT_OP,  JIT_FN,  JIT_LD,  JIT_IMM };			/* kinds */

/* Declarations */

static void _jit_emit(jit_state *, struct jit_fp *,
		      int, int, int, int) JIT_UNUSED;
static struct jit_fp *_jit_op(struct jit_fp *, int, 
			      struct jit_fp *, struct jit_fp *) JIT_UNUSED;
static struct jit_fp *_jit_ld(struct jit_fp *, int, 
			      int, int) JIT_UNUSED;
static struct jit_fp *_jit_fn(struct jit_fp *, int, 
			      struct jit_fp *) JIT_UNUSED;
static struct jit_fp *_jit_imm(struct jit_fp *, double) JIT_UNUSED;

/* Internal function to walk the tree */

void
_jit_emit(jit_state *jit, struct jit_fp *head,
	  int store_kind, int store1, int store2, int reg0)
{
#define _jit (*jit)
  switch (head->kind) {
    case JIT_OP:
      _jit_emit(jit, head->d.ops.lhs, JIT_NULL, 0, 0, reg0);
      _jit_emit(jit, head->d.ops.rhs, JIT_NULL, 0, 0, reg0 + 1);
      switch (head->subkind) {
        case JIT_ADD: jit_add_two(reg0); break;
        case JIT_SUB: jit_sub_two(reg0); break;
        case JIT_MUL: jit_mul_two(reg0); break;
        case JIT_DIV: jit_div_two(reg0); break;
      }
      break;

    case JIT_IMM:
#ifdef JIT_LONG_IS_INT
      jit_fpimm(reg0, head->d.imm.split[0], head->d.imm.split[1]);
#else
      jit_fpimm(reg0, head->d.imm.split[0]);
#endif
      break;

    case JIT_FN:
      _jit_emit(jit, head->d.ops.lhs, JIT_NULL, 0, 0, reg0);
      switch (head->subkind) {
	case JIT_ABS: jit_abs(reg0); break;
	case JIT_NEG: jit_neg(reg0); break;
#ifdef JIT_TRANSCENDENTAL
	case JIT_SIN: jit_sin(reg0); break;
	case JIT_SQRT: jit_sqrt(reg0); break;
	case JIT_COS: jit_cos(reg0); break;
	case JIT_TAN: jit_tan(reg0); break;
	case JIT_ATN: jit_atn(reg0); break;
	case JIT_EXP: jit_exp(reg0); break;
	case JIT_LOG: jit_log(reg0); break;
#endif
      }
      break;

    case JIT_LD:
      switch (head->subkind) {
        case JIT_INT:    jit_exti_d(reg0, head->d.addr.reg1); break;
        case JIT_XI:     jit_ldxi_f(reg0, head->d.addr.reg1, head->d.addr.displ); break;
        case JIT_XR:     jit_ldxr_f(reg0, head->d.addr.reg1, head->d.addr.reg2);  break;
        case JIT_XI | 1: jit_ldxi_d(reg0, head->d.addr.reg1, head->d.addr.displ); break;
        case JIT_XR | 1: jit_ldxr_d(reg0, head->d.addr.reg1, head->d.addr.reg2);  break;
#ifndef JIT_RZERO
        case JIT_I:      jit_ldi_f(reg0, head->d.addr.displ); break;
        case JIT_R:      jit_ldr_f(reg0, head->d.addr.reg1);  break;
        case JIT_I | 1:  jit_ldi_d(reg0, head->d.addr.displ); break;
        case JIT_R | 1:  jit_ldr_d(reg0, head->d.addr.reg1);  break;
#endif
      }
      break;
  }

  switch (store_kind) {
    case JIT_FLOOR:  jit_floor(store1, reg0);		 break;
    case JIT_CEIL:   jit_ceil(store1, reg0);		 break;
    case JIT_TRUNC:  jit_trunc(store1, reg0);		 break;
    case JIT_ROUND:  jit_round(store1, reg0);		 break;
    case JIT_CMP:    jit_cmp(store1, store2, reg0);	 break;
    case JIT_XI:     jit_stxi_f(store2, store1, reg0);   break;
    case JIT_XR:     jit_stxr_f(store2, store1, reg0);   break;
    case JIT_XI | 1: jit_stxi_d(store2, store1, reg0);   break;
    case JIT_XR | 1: jit_stxr_d(store2, store1, reg0);   break;
#ifndef JIT_RZERO
    case JIT_I:      jit_sti_f(store2, reg0);		 break;
    case JIT_R:      jit_str_f(store2, reg0);		 break;
    case JIT_I | 1:  jit_sti_d(store2, reg0);		 break;
    case JIT_R | 1:  jit_str_d(store2, reg0);		 break;
#endif
    case JIT_NULL:   break;
  }
#undef _jit
}

/* Internal functions to build the tree */

struct jit_fp *
_jit_op(struct jit_fp *where, int which, 
	struct jit_fp *op1, struct jit_fp *op2)
{
  where->kind = JIT_OP;
  where->subkind = which;
  where->d.ops.lhs = op1;
  where->d.ops.rhs = op2;
  return (where);
}

struct jit_fp *
_jit_ld(struct jit_fp *where, int which, int op1, int op2)
{
  where->kind = JIT_LD;
  where->subkind = which;
  switch (which & ~1) {
    case JIT_XI: where->d.addr.reg1 = op1;
    case JIT_I:  where->d.addr.displ = op2;	break;
    case JIT_XR: where->d.addr.reg2  = op2;
    case JIT_INT:
    case JIT_R:  where->d.addr.reg1  = op1;	break;
  }
  return (where);
}

struct jit_fp *
_jit_fn(struct jit_fp *where, int which, struct jit_fp *op1)
{
  where->kind = JIT_FN;
  where->subkind = which;
  where->d.ops.lhs = op1;
  return (where);
}

struct jit_fp *
_jit_imm(struct jit_fp *where, double number)
{
  where->kind = JIT_IMM;
  where->d.imm.number = number;
  return (where);
}

#define jitfp_begin(buf)		(_jit.fp = (buf), --_jit.fp)
#define jitfp_add(op1, op2)		_jit_op(++_jit.fp, JIT_ADD, (op1), (op2))
#define jitfp_sub(op1, op2)		_jit_op(++_jit.fp, JIT_SUB, (op1), (op2))
#define jitfp_mul(op1, op2)		_jit_op(++_jit.fp, JIT_MUL, (op1), (op2))
#define jitfp_div(op1, op2)		_jit_op(++_jit.fp, JIT_DIV, (op1), (op2))
#define jitfp_imm(imm)			_jit_imm(++_jit.fp, (imm))
#define jitfp_exti_d(reg1)		_jit_ld(++_jit.fp, JIT_INT, (reg1), 0)
#define jitfp_ldxi_f(reg1, imm)		_jit_ld(++_jit.fp, JIT_XI, (reg1), (long)(imm))
#define jitfp_ldxr_f(reg1, reg2)	_jit_ld(++_jit.fp, JIT_XR, (reg1), (reg2))
#define jitfp_ldxi_d(reg1, imm)		_jit_ld(++_jit.fp, JIT_XI | 1, (reg1), (long)(imm))
#define jitfp_ldxr_d(reg1, reg2)	_jit_ld(++_jit.fp, JIT_XR | 1, (reg1), (reg2))
#define jitfp_abs(op1)	 		_jit_fn(++_jit.fp, JIT_ABS, (op1))
#define jitfp_sqrt(op1)	 		_jit_fn(++_jit.fp, JIT_SQRT, (op1))
#define jitfp_neg(op1)			_jit_fn(++_jit.fp, JIT_NEG, (op1))
#define jitfp_stxi_f(imm, reg1, op1)	_jit_emit(&_jit, (op1), JIT_XI, (reg1), (long)(imm), 0)
#define jitfp_stxr_f(reg1, reg2, op1)	_jit_emit(&_jit, (op1), JIT_XR, (reg1), (reg2), 0)
#define jitfp_stxi_d(imm, reg1, op1)	_jit_emit(&_jit, (op1), JIT_XI | 1, (reg1), (long)(imm), 0)
#define jitfp_stxr_d(reg1, reg2, op1)	_jit_emit(&_jit, (op1), JIT_XR | 1, (reg1), (reg2), 0)
#define jitfp_cmp(regle, regge, op1)	_jit_emit(&_jit, (op1), JIT_CMP, regle, regge, 0)
#define jitfp_floor(reg1, op1)		_jit_emit(&_jit, (op1), JIT_FLOOR, reg1, 0, 0)
#define jitfp_ceil(reg1, op1)		_jit_emit(&_jit, (op1), JIT_CEIL, reg1, 0, 0)
#define jitfp_trunc(reg1, op1)		_jit_emit(&_jit, (op1), JIT_TRUNC, reg1, 0, 0)
#define jitfp_round(reg1, op1)		_jit_emit(&_jit, (op1), JIT_ROUND, reg1, 0, 0)


#ifdef JIT_TRANSCENDENTAL
#define jitfp_sin(op1)			_jit_fn(++_jit.fp, JIT_SIN, (op1))
#define jitfp_cos(op1)			_jit_fn(++_jit.fp, JIT_COS, (op1))
#define jitfp_tan(op1)			_jit_fn(++_jit.fp, JIT_TAN, (op1))
#define jitfp_atn(op1)			_jit_fn(++_jit.fp, JIT_ATN, (op1))
#define jitfp_exp(op1)			_jit_fn(++_jit.fp, JIT_EXP, (op1))
#define jitfp_log(op1)			_jit_fn(++_jit.fp, JIT_LOG, (op1))
#endif

#ifdef JIT_RZERO
#define jitfp_ldi_f(imm)		_jit_ld(++_jit.fp, JIT_XI, JIT_RZERO, (long)(imm))
#define jitfp_ldr_f(reg1)		_jit_ld(++_jit.fp, JIT_XR, JIT_RZERO, (reg1))
#define jitfp_ldi_d(imm)		_jit_ld(++_jit.fp, JIT_XI | 1, JIT_RZERO, (long)(imm))
#define jitfp_ldr_d(reg1)		_jit_ld(++_jit.fp, JIT_XR | 1, JIT_RZERO, (reg1))
#define jitfp_sti_f(imm, op1)		_jit_emit(&_jit, (op1), JIT_XI, JIT_RZERO, (long)(imm), 0)
#define jitfp_str_f(reg1, op1)		_jit_emit(&_jit, (op1), JIT_XR, JIT_RZERO, (reg1), 0)
#define jitfp_sti_d(imm, op1)		_jit_emit(&_jit, (op1), JIT_XI | 1, JIT_RZERO, (long)(imm), 0)
#define jitfp_str_d(reg1, op1)		_jit_emit(&_jit, (op1), JIT_XR | 1, JIT_RZERO, (reg1), 0)
#else
#define jitfp_ldi_f(imm)		_jit_ld(++_jit.fp, JIT_I, 0, (long)(imm))
#define jitfp_ldr_f(reg1)		_jit_ld(++_jit.fp, JIT_R, (reg1), 0)
#define jitfp_ldi_d(imm)		_jit_ld(++_jit.fp, JIT_I | 1, 0, (long)(imm))
#define jitfp_ldr_d(reg1)		_jit_ld(++_jit.fp, JIT_R | 1, (reg1), 0)
#define jitfp_sti_f(imm, op1)		_jit_emit(&_jit, (op1), JIT_I, 0, (long)(imm), 0)
#define jitfp_str_f(reg1, op1)		_jit_emit(&_jit, (op1), JIT_R, 0, (reg1), 0)
#define jitfp_sti_d(imm, op1)		_jit_emit(&_jit, (op1), JIT_I | 1, 0, (long)(imm), 0)
#define jitfp_str_d(reg1, op1)		_jit_emit(&_jit, (op1), JIT_R | 1, 0, (reg1), 0)
#endif


#endif
