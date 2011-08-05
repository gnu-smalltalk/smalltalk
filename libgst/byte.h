/******************************** -*- C -*- ****************************
 *
 *	Byte Code definitions.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008,2009
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
 ***********************************************************************/


#ifndef GST_BYTE_H
#define GST_BYTE_H

enum {
  PLUS_SPECIAL = 0,
  MINUS_SPECIAL = 1,
  LESS_THAN_SPECIAL = 2,
  GREATER_THAN_SPECIAL = 3,
  LESS_EQUAL_SPECIAL = 4,
  GREATER_EQUAL_SPECIAL = 5,
  EQUAL_SPECIAL = 6,
  NOT_EQUAL_SPECIAL = 7,
  TIMES_SPECIAL = 8,
  DIVIDE_SPECIAL = 9,
  REMAINDER_SPECIAL = 10,
  BIT_XOR_SPECIAL = 11,
  BIT_SHIFT_SPECIAL = 12,
  INTEGER_DIVIDE_SPECIAL = 13,
  BIT_AND_SPECIAL = 14,
  BIT_OR_SPECIAL = 15,

  AT_SPECIAL = 16,
  AT_PUT_SPECIAL = 17,
  SIZE_SPECIAL = 18,
  CLASS_SPECIAL = 19,
  IS_NIL_SPECIAL = 20,
  NOT_NIL_SPECIAL = 21,
  VALUE_SPECIAL = 22,
  VALUE_COLON_SPECIAL = 23,
  SAME_OBJECT_SPECIAL = 24,
  JAVA_AS_INT_SPECIAL = 25,
  JAVA_AS_LONG_SPECIAL = 26,

  NEW_COLON_SPECIAL = 32,
  THIS_CONTEXT_SPECIAL = 33,

  SEND = 28,
  SEND_SUPER = 29,
  SEND_IMMEDIATE = 30,
  SEND_SUPER_IMMEDIATE = 31,

  PUSH_TEMPORARY_VARIABLE = 32,
  PUSH_OUTER_TEMP = 33,
  PUSH_LIT_VARIABLE = 34,
  PUSH_RECEIVER_VARIABLE = 35,
  STORE_TEMPORARY_VARIABLE = 36,
  STORE_OUTER_TEMP = 37,
  STORE_LIT_VARIABLE = 38,
  STORE_RECEIVER_VARIABLE = 39,
  JUMP_BACK = 40,
  JUMP = 41,
  POP_JUMP_TRUE = 42,
  POP_JUMP_FALSE = 43,
  PUSH_INTEGER = 44,
  PUSH_SPECIAL = 45,
  PUSH_LIT_CONSTANT = 46,
  POP_INTO_NEW_STACKTOP = 47,
  POP_STACK_TOP = 48,
  MAKE_DIRTY_BLOCK = 49,
  RETURN_METHOD_STACK_TOP = 50,
  RETURN_CONTEXT_STACK_TOP = 51,
  DUP_STACK_TOP = 52,
  EXIT_INTERPRETER = 53,
  LINE_NUMBER_BYTECODE = 54,
  EXT_BYTE = 55,
  PUSH_SELF = 56,

  NIL_INDEX = 0,
  TRUE_INDEX = TRUE_OOP_INDEX - NIL_OOP_INDEX,
  FALSE_INDEX = FALSE_OOP_INDEX - NIL_OOP_INDEX,
  THIS_CONTEXT_INDEX = -128,
  RECEIVER_INDEX = -129
};

enum {
  /* Causes _gst_line_number to always emit a line number bytecode.  */
  LN_FORCE = 1,

  /* If LN_ABSOLUTE is also set, causes _gst_line_number to emit an absolute
     ine number and use that line number as the offset.  If not,
     _gst_line_number will emit line numbers relatives to that line.  */
  LN_RESET = 2,

  /* See above for description.  */
  LN_ABSOLUTE = 4
};

typedef struct bytecode_array
{
  gst_uchar *base;		/* base of the byte code array */
  gst_uchar *ptr;		/* current byte+1 of byte code array */
  int maxLen;			/* max allocated len of byte code array */
  int stack_depth;
  int max_stack_depth;
} *bc_vector;

extern bc_vector _gst_cur_bytecodes
  ATTRIBUTE_HIDDEN;

/* Add 1 to the current stack depth and adjust the maximum depth
   accordingly.  */
#define INCR_STACK_DEPTH()      do {                                         \
   if (++_gst_cur_bytecodes->stack_depth >				     \
       _gst_cur_bytecodes->max_stack_depth)				     \
     _gst_cur_bytecodes->max_stack_depth++;				     \
} while (0)

/* Add N to the current stack depth and adjust the maximum depth
   accordingly.  */
#define ADD_STACK_DEPTH(n)      do {                                         \
  _gst_cur_bytecodes->stack_depth += (n);                             	     \
 if (_gst_cur_bytecodes->stack_depth > _gst_cur_bytecodes->max_stack_depth)  \
   _gst_cur_bytecodes->max_stack_depth = _gst_cur_bytecodes->stack_depth;    \
} while (0)

/* Subtract N from the current stack depth.  */
#define SUB_STACK_DEPTH(n)      					     \
  (assert (_gst_cur_bytecodes->stack_depth >= (n)),		             \
   _gst_cur_bytecodes->stack_depth -= (n))

/* Subtract N from the current stack depth.  */
#define GET_STACK_DEPTH()	      					     \
  (_gst_cur_bytecodes->max_stack_depth)

/* Allocate a new array of bytecodes.  */
extern void _gst_alloc_bytecodes () 
  ATTRIBUTE_HIDDEN;

/* Called when byte code compilation is complete, this routine returns
   the set of byte codes that were compiled.  Since compilation is
   complete, this routine also resets the internal state of the byte
   code compiler in preparation for next time.  */
extern bc_vector _gst_get_bytecodes (void) 
  ATTRIBUTE_HIDDEN;

/* Called to save the set of byte codes currently being compiled and
   prepare for a new compilation of byte codes. The current set of
   byte codes being compiled is returned for the caller to keep and to
   later use in a _gst_restore_bytecode_array call.  */
extern bc_vector _gst_save_bytecode_array () 
  ATTRIBUTE_HIDDEN;

/* Restores the internal state of the byte code compiler so that it
   can continue compiling byte codes into the byte code array
   BYTECODES, which should have been returned at some previous point
   from _gst_save_bytecode_array().  Return the TAG that was passed
   to _gst_save_bytecode_array.  */
extern void _gst_restore_bytecode_array (bc_vector)
  ATTRIBUTE_HIDDEN;

/* This copies the byte instance variables out of the Smalltalk
   ByteArray object, BYTEARRAYOOP, and creates a bytecodes structure
   for it.  This is used when a method is created by Smalltalk
   code.  */
extern bc_vector _gst_extract_bytecodes (OOP byteArrayOOP) 
  ATTRIBUTE_HIDDEN;

/* This eliminates all the bytecodes in the array starting at the one
   pointed to by HERE.  */
extern void _gst_truncate_bytecodes (gst_uchar * here,
				     bc_vector bytecodes) 
  ATTRIBUTE_HIDDEN;

/* This compiles a LINE_NUMBER_BYTECODE if line is different from the
   last line we compiled, or if FORCE is true.  */
extern void _gst_line_number (int line, int flags) 
  ATTRIBUTE_HIDDEN;

/* This tacks the bytecode BYTE, with argument ARG, at the end of the
   current bytecode array.  */
extern void _gst_compile_byte (gst_uchar byte, int arg) 
  ATTRIBUTE_HIDDEN;

/* This tacks the contents of the BYTECODES array at the end of the
   current bytecode array, and then frees the array.  */
extern void _gst_compile_and_free_bytecodes (bc_vector bytecodes) 
  ATTRIBUTE_HIDDEN;

/* This tacks the bytes starting at FROM (included) and ending at TO
   (excluded) at the end of the current bytecode array.  */
extern void _gst_compile_bytecodes (gst_uchar * from,
				    gst_uchar * to) 
  ATTRIBUTE_HIDDEN;

/* This frees the BYTECODES data structure.  */
extern void _gst_free_bytecodes (bc_vector bytecodes) 
  ATTRIBUTE_HIDDEN;

/* This copies the contents of the bytecode array, BYTECODES, to the
   memory starting at DEST.  */
extern void _gst_copy_bytecodes (gst_uchar * dest,
				 bc_vector bytecodes) 
  ATTRIBUTE_HIDDEN;

/* This prints the bytecode pointed to by BP, using IP to resolve the
   offsets for the relative jumps.  LITERAL_VEC is used to print the
   literals pointed to by the bytecodes.  The first line is preceded
   by a tab character, subsequent lines are preceded by PREFIX and a
   tab.  */
extern gst_uchar *_gst_print_bytecode_name (gst_uchar * bp,
				            int ip,
				            OOP * literal_vec,
					    const char *prefix) 
  ATTRIBUTE_HIDDEN;

/* This prints the bytecode array, using LITERAL_VEC is used to print
   the literals pointed to by the bytecodes.  */
extern void _gst_print_bytecodes (bc_vector bytecodes,
				  OOP * literal_vec) 
  ATTRIBUTE_HIDDEN;

/* This returns the current number of bytecodes that have been compiled
   (the size of the current bytecode array).  */
extern int _gst_current_bytecode_length (void) 
  ATTRIBUTE_HIDDEN;

/* This returns the number of bytecdoes compiled into the BYTECODES
   array.  */
extern int _gst_bytecode_length (bc_vector bytecodes) 
  ATTRIBUTE_HIDDEN;

/* Returns the size of each bytecode, including the arguments.  */
#define BYTECODE_SIZE			2


#endif /* GST_BYTE_H */
