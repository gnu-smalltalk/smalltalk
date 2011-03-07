/******************************** -*- C -*- ****************************
 *
 *	Byte Code optimization & analysis definitions.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2006, 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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


#ifndef GST_OPT_H
#define GST_OPT_H

/* This divides the byte codes of a method in basic blocks, optimizes
   each one, joins the optimized blocks and return a new vector of
   byte codes that contains the stream of optimized byte codes.
   Actual optimization of the basic blocks is optimize_basic_block's
   task; this function takes care of handling basic blocks and
   optimizing jumps (because they span multiple basic blocks). 

   On output, BYTECODES is freed and another vector of bytecodes
   is answered.  */
extern bc_vector _gst_optimize_bytecodes (bc_vector bytecodes) 
  ATTRIBUTE_HIDDEN;

/* This fills a table that says which stack slot is touched by each
   bytecode.  BP points to SIZE bytecodes, POS points to an array that
   is filled with pointers relative to BASE.  In other words, if bp[x]
   writes in the first stack slot, we put pos[x] == &base[0]; if bp[x]
   writes in the second stack slot, we put pos[x] == &base[1], etc.  */
extern void _gst_compute_stack_positions (gst_uchar * bp,
					  int size,
					  PTR * base,
					  PTR ** pos) 
  ATTRIBUTE_HIDDEN;

/* METHODOOP is the OOP for a CompiledMethod or CompiledBlock to be
   analyzed, having SIZE bytecodes.  DEST is an array of SIZE items,
   which on output has non-zero items for jump destinations only: in
   particular, it is positive for a forward jump and negative for a
   backward jump.  */
extern void _gst_analyze_bytecodes (OOP methodOOP,
				    int size,
				    char *dest) 
  ATTRIBUTE_HIDDEN;

/* Look at METHODOOP and checks if it is well formed.  If it is an
   inner block, the external methods are examined.  Abort if the
   process fails.  */
extern void _gst_verify_sent_method (OOP methodOOP) 
  ATTRIBUTE_HIDDEN;

/* Look at METHODOOP and checks if it is well formed.  If it is
   an inner block, DEPTH is the length of the static chain and
   NUM_OUTER_TEMPS is the number of temporaries available in the
   first outer context, the second, and so on; if they are NULL,
   the CompiledMethod that holds the block is verified.  Return
   NULL or an error message.  */
extern const char *_gst_verify_method (OOP methodOOP,
				       int *num_outer_temps,
				       int depth) 
  ATTRIBUTE_HIDDEN;

/* This looks at BYTECODES and checks if they could be replaced
   with an optimized return of self, of an instance variable or of
   a literal.  */
extern int _gst_is_simple_return (bc_vector bytecodes,
				  OOP *literalOOP)
  ATTRIBUTE_HIDDEN;

/* This decides whether the block compiled to the BC bytecodes can be
   optimized; LITERALS contains the literals for the given block, and
   is used to check nested blocks: if there are any, they must already
   have had their cleanness set by a call to _gst_check_kind_of_block.

   The answer is a number that identifies the possibility to optimize
   the block: 0 for clean blocks, 1 for a self-contained block (no
   accesses to outer contexts) which however needs to know about self,
   31 for a block containing a method return or a reference to
   thisContext, and another number N for a block that accesses the
   (N-1)th outer context.  */
extern int _gst_check_kind_of_block (bc_vector bc,
				     OOP * literals) 
  ATTRIBUTE_HIDDEN;

#define IS_RETURN_BYTECODE(b)	((b) == RETURN_METHOD_STACK_TOP || \
		  		 (b) == RETURN_CONTEXT_STACK_TOP)
#define IS_SEND_BYTECODE(b)	((int) (b) < PUSH_TEMPORARY_VARIABLE)
#define IS_PUSH_BYTECODE(b)	(((b) >= PUSH_TEMPORARY_VARIABLE \
				  && (b) <= PUSH_RECEIVER_VARIABLE) \
				 || ((b) >= PUSH_INTEGER \
				     && (b) <= PUSH_LIT_CONSTANT))

#endif /* GST_OPT_H */
