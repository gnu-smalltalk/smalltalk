/******************************** -*- C -*- ****************************
 *
 *	Byte Code definitions.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
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
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


#ifndef GST_BYTE_H
#define GST_BYTE_H

enum {
  PUSH_RECEIVER_VARIABLE = 0,
  PUSH_TEMPORARY_VARIABLE = 16,
  PUSH_LIT_CONSTANT = 32,
  PUSH_LIT_VARIABLE = 64,
  POP_RECEIVER_VARIABLE = 96,
  POP_TEMPORARY_VARIABLE = 104,
  PUSH_SPECIAL = 112,
  PUSH_SIGNED_8 = 116,
  PUSH_UNSIGNED_8 = 117,
  PUSH_ZERO = 118,
  PUSH_ONE = 119,
  RETURN_INDEXED = 120,
  RETURN_METHOD_STACK_TOP = 124,
  RETURN_CONTEXT_STACK_TOP = 125,
  BIG_LITERALS_BYTECODE = 126,
  LINE_NUMBER_BYTECODE = 127,
  PUSH_INDEXED = 128,
  STORE_INDEXED = 129,
  POP_STORE_INDEXED = 130,
  SEND1EXT_BYTE = 131,
  SEND2EXT_BYTE = 132,
  SEND_SUPER1EXT_BYTE = 133,
  BIG_INSTANCE_BYTECODE = 134,
  POP_STACK_TOP = 135,
  DUP_STACK_TOP = 136,
  PUSH_ACTIVE_CONTEXT = 137,
  OUTER_TEMP_BYTECODE = 138,
  NOP_BYTECODE = 139,
  REPLACE_SELF = 140,
  REPLACE_ONE = 141,	/* chosen for `1 to: ... do:' */
  REPLACE_INDEXED = 142,
  EXIT_INTERPRETER = 143,
  JUMP_SHORT = 144,
  POP_JUMP_FALSE_SHORT = 152,
  JUMP_LONG = 160,
  POP_JUMP_TRUE = 168,
  POP_JUMP_FALSE = 172,
  PLUS_SPECIAL = 176,
  MINUS_SPECIAL = 177,
  LESS_THAN_SPECIAL = 178,
  GREATER_THAN_SPECIAL = 179,
  LESS_EQUAL_SPECIAL = 180,
  GREATER_EQUAL_SPECIAL = 181,
  EQUAL_SPECIAL = 182,
  NOT_EQUAL_SPECIAL = 183,
  TIMES_SPECIAL = 184,
  DIVIDE_SPECIAL = 185,
  REMAINDER_SPECIAL = 186,
  AT_SIGN_SPECIAL = 187,
  BIT_SHIFT_COLON_SPECIAL = 188,
  INTEGER_DIVIDE_SPECIAL = 189,
  BIT_AND_COLON_SPECIAL = 190,
  BIT_OR_COLON_SPECIAL = 191,
  AT_COLON_SPECIAL = 192,
  AT_COLON_PUT_COLON_SPECIAL = 193,
  SIZE_SPECIAL = 194,
  NEXT_SPECIAL = 195,
  NEXT_PUT_COLON_SPECIAL = 196,
  AT_END_SPECIAL = 197,
  SAME_OBJECT_SPECIAL = 198,
  CLASS_SPECIAL = 199,
  BLOCK_COPY_COLON_SPECIAL = 200,
  VALUE_SPECIAL = 201,
  VALUE_COLON_SPECIAL = 202,
  DO_COLON_SPECIAL = 203,
  NEW_SPECIAL = 204,
  NEW_COLON_SPECIAL = 205,
  IS_NIL_SPECIAL = 206,
  NOT_NIL_SPECIAL = 207,
  SEND_NO_ARG = 208,
  SEND_1_ARG = 224,
  SEND_2_ARG = 240,

  RECEIVER_INDEX = 0,
  TRUE_INDEX = 1,
  FALSE_INDEX = 2,
  NIL_INDEX = 3,
  THIS_CONTEXT_INDEX = (PUSH_ACTIVE_CONTEXT - PUSH_SPECIAL),

  RECEIVER_LOCATION = (0 << 6),
  TEMPORARY_LOCATION = (1 << 6),
  LIT_CONST_LOCATION = (2 << 6),
  LIT_VAR_LOCATION = (3 << 6),

  LOCATION_MASK = (3 << 6),
  OPERATION_MASK = (3 << 6),

  PUSH_LITERAL = (0 << 6),
  POP_STORE_INTO_ARRAY = (0 << 6),
  PUSH_VARIABLE = (1 << 6),
  POP_STORE_VARIABLE = (2 << 6),
  STORE_VARIABLE = (3 << 6),

  EXTENDED_SEND_SUPER_FLAG = 32
};

typedef struct bytecode_array
{
  gst_uchar *base;		/* base of the byte code array */
  gst_uchar *ptr;		/* current byte+1 of byte code array */
  int maxLen;			/* max allocated len of byte code array */
  int stack_depth;
  int max_stack_depth;
} *bytecodes;

extern bytecodes _gst_cur_bytecodes;

/* Add 1 to the current stack depth and adjust the maximum depth
   accordingly. */
#define INCR_STACK_DEPTH()      do {                                         \
   if (++_gst_cur_bytecodes->stack_depth >				     \
       _gst_cur_bytecodes->max_stack_depth)				     \
     _gst_cur_bytecodes->max_stack_depth++;				     \
} while (0)

/* Add N to the current stack depth and adjust the maximum depth
   accordingly. */
#define ADD_STACK_DEPTH(n)      do {                                         \
  _gst_cur_bytecodes->stack_depth += (n);                             	     \
 if (_gst_cur_bytecodes->stack_depth > _gst_cur_bytecodes->max_stack_depth)  \
   _gst_cur_bytecodes->max_stack_depth = _gst_cur_bytecodes->stack_depth;    \
} while (0)

/* Subtract N from the current stack depth. */
#define SUB_STACK_DEPTH(n)      					     \
  (assert (_gst_cur_bytecodes->stack_depth >= (n)),		             \
   _gst_cur_bytecodes->stack_depth -= (n))

/* Subtract N from the current stack depth. */
#define GET_STACK_DEPTH()	      					     \
  (_gst_cur_bytecodes->max_stack_depth)

/* Allocate a new array of bytecodes. */
extern void _gst_alloc_bytecodes ();

/* Called when byte code compilation is complete, this routine returns
   the set of byte codes that were compiled.  Since compilation is
   complete, this routine also resets the internal state of the byte
   code compiler in preparation for next time. */
extern bytecodes _gst_get_bytecodes (void);

/* Called to save the set of byte codes currently being compiled and
   prepare for a new compilation of byte codes. The current set of
   byte codes being compiled is returned for the caller to keep and to
   later use in a _gst_restore_bytecode_array call.  */
extern bytecodes _gst_save_bytecode_array ();

/* Restores the internal state of the byte code compiler so that it
   can continue compiling byte codes into the byte code array
   BYTECODES, which should have been returned at some previous point
   from _gst_save_bytecode_array().  Return the TAG that was passed
   to _gst_save_bytecode_array.  */
extern void _gst_restore_bytecode_array ();

/* This copies the byte instance variables out of the Smalltalk
   ByteArray object, BYTEARRAYOOP, and creates a bytecodes structure
   for it.  This is used when a method is created by Smalltalk
   code. */
extern bytecodes _gst_extract_bytecodes (OOP byteArrayOOP);

/* This eliminates all the bytecodes in the array starting at the one
   pointed to by HERE. */
extern void _gst_truncate_bytecodes (gst_uchar * here,
				     bytecodes bytecodes);

/* This compiles a LINE_NUMBER_BYTECODE if line is different from the
   last line we compiled, or if FORCE is true. */
extern void _gst_line_number (int line, mst_Boolean force);

/* This tacks BYTE at the end of the current bytecode array. */
extern void _gst_compile_byte (gst_uchar byte);

/* This tacks the contents of the BYTECODES array at the end of the
   current bytecode array, and then frees the array. */
extern void _gst_compile_and_free_bytecodes (bytecodes bytecodes);

/* This tacks the bytes starting at FROM (included) and ending at TO
   (excluded) at the end of the current bytecode array. */
extern void _gst_compile_bytecodes (register gst_uchar * from,
				    register gst_uchar * to);

/* This frees the BYTECODES data structure. */
extern void _gst_free_bytecodes (bytecodes bytecodes);

/* This copies the contents of the bytecode array, BYTECODES, to the
   memory starting at DEST. */
extern void _gst_copy_bytecodes (gst_uchar * dest,
				 bytecodes bytecodes);

/* This prints the bytecode pointed to by BP, using IP to resolve the
   offsets for the relative jumps.  LITERAL_VEC is used to print the
   literals pointed to by the bytecodes. */
extern void _gst_print_bytecode_name (gst_uchar * bp,
				      int ip,
				      OOP * literal_vec);

/* This prints the bytecode array, using LITERAL_VEC is used to print
   the literals pointed to by the bytecodes. */
extern void _gst_print_bytecodes (bytecodes bytecodes,
				  OOP * literal_vec);

/* This returns the current number of bytecodes that have been compiled
   (the size of the current bytecode array). */
extern int _gst_current_bytecode_length (void);

/* This returns the number of bytecdoes compiled into the BYTECODES
   array. */
extern int _gst_bytecode_length (bytecodes bytecodes);

/* A table of the sizes of each bytecode. */
extern const int _gst_bytecode_size_table[];

/* Returns the size of the bytecode B. */
#define BYTECODE_SIZE(b)		_gst_bytecode_size_table[(gst_uchar) b]


/*    Interpretation of the virtual machine byte codes

0-15    push receiver variable 	0000iiii
16-31   push temporary location	0001iiii
32-63   push literal constant	001iiiii
64-95   push literal variable	010iiiii
96-103  pop & store rec var	01100iii
104-111 pop & store temp loc	01101iii
112-119 push indexed		01110iii receiver true false nil -1 0 1 2
120-123 return indexed		011110ii receiver true false nil
124-125 return st top from	0111110i method, current context
126	literal > 63 operation  01111110 yyxxxxxx xxxxxxxx: xx...xx index;
						 yy = op: push const, push
						 var, store var, pop/store var
127     breakpoint patch        01111111 send #breakpoint:return:, reexecute
128	push indir		10000000 jjkkkkkk jj = receiver var, temp loc,
						  lit const, lit var; #kkkkkk
129	store indir		10000001 jjkkkkkk (rv, tl, invalid, lv)
130	pop & store indir	10000010 jjkkkkkk (like store indir)
131	send lit selector	10000011 jjjkkkkk sel #kkkkk with jjj args
132	send lit selector	10000100 kksjjjjj kkkkkkkk (as 131, s=super)
133	send lit sel to super	10000101 jjjkkkkk as 131
134	inst.var> 63 operation  01111110 yyxxxxxx xxxxxxxx: xx...xx index;
						 yy = op: pop/store into new
						 stack top, push, store, pop/store
135	pop stack top		10000111
136	duplicate stack top	10001000
137	push active context	10001001
138	outer var operation	10001010 yyindex- scopes-- yy op
					(invalid, push, store, pop/store)
139	nop-needed by optimizer	10001011
140	stack top = _gst_self	10001100
141	stack top = one		10001101
142	indir replace stack top	10001100 jjkkkkkk (like push indir)
143	unused
144-151	jmp (short)		10010iii 	  ofs=iii+1
152-159	pop & jmp false (short)	10011iii 	  ofs=iii+1
160-167	jmp (long)		10100iii jjjjjjjj ofs=(iii-4)*256+jjjjjjjj
168-171 pop & jmp on true	101010ii jjjjjjjj ofs=ii*256+jjjjjjjj
172-175 pop & jmp on false	101011ii jjjjjjjj like 168
176-191 send arith message	1011iiii
192-207	send special message	1100iiii
208-223 send lit sel #iiii	1101iiii with no arguments
224-239 send lit sel #iiii	1110iiii with 1 argument
240-255 send lit sel #iiii	1111iiii with 2 arguments
*/

#endif /* GST_BYTE_H */
