/******************************* -*- C -*- ****************************
 *
 *	Functions for byte code optimization & analysis
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000,2001,2002,2003,2006,2008,2009 Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"
#include "match.h"

/* Define this to have verbose messages from the JIT compiler's
   basic-block split phase.  */
/* #define DEBUG_JIT_TRANSLATOR */

/* Define this to have verbose messages from the bytecode verifier.  */
/* #define DEBUG_VERIFIER */

/* Define this to disable the peephole bytecode optimizer.  It works
   well for decreasing the footprint and increasing the speed, so
   there's no reason to do that unless you're debugging the compiler.  */
/* #define NO_OPTIMIZE */

/* Define this to disable superoperators in the peephole bytecode
   optimizer.  Some simple optimizations will still be done, making
   the output suitable for searching superoperator candidates.  */
/* #define NO_SUPEROPERATORS */

/* Define this to disable bytecode verification.  */
/* #define NO_VERIFIER */

/* The JIT compiler prefers optimized bytecodes, because they are
   more regular.  */
#ifdef ENABLE_JIT_TRANSLATION
#undef NO_OPTIMIZE
#endif



/* This structure and the following one are used by the bytecode
   peephole optimizer.
   
   This one, in particular, defines where basic blocks start in the
   non- optimized bytecodes. byte is nothing more than an offset in
   those bytecodes; id is used to pair jump bytecodes with their
   destinations: in the initial scan, when we encounter a jump
   bytecode we fill two block_boundaries -- one has positive id and
   represents the destination of the jump, one has negative id (but
   the same absolute value) and represents the jump bytecode
   itself.  */
typedef struct block_boundary
{
  /* Bytecode at the end of the basic block, -1 if not a jump.  */
  int kind;

  /* Start of the basic block.  */
  int start, end;

  /* Destination IP for the jump at the end of the basic block.  */
  int dest;

  /* Destination basic block for the jump at the end of the basic block.  */
  struct block_boundary *dest_bb;

  /* Size of the optimized basic block.  */
  int opt_length;

  /* Offset of the basic block in the optimized method.  */
  int final_byte;
}
block_boundary;

/* Basic block data structure, common to the JIT and the verifier.  */
typedef struct basic_block_item {
  struct basic_block_item *next;
  struct basic_block_item **bb;
  gst_uchar *bp;
  int sp;

  /* Suspended basic blocks are those for which we know the initial
     instruction pointer, but not the initial stack pointer.  Since
     data-flow analysis should walk them, these are put aside
     momentarily.

     They are generated when there is no basic block for the
     bytecode after a jump or a return.  If they are unreachable
     and they follow a jump, they're supposed to have an initial
     SP = 0, else the initial SP is put to the same as the
     return bytecode's SP (this is to accomodate comp.c's
     behavior when emitting "a ifTrue: [ ^1 ] ifFalse: [ ^2 ]").

     However, the initial SP of a suspended block can always be
     overridden if a jump to the block is found, in which case
     the flag is cleared.  Suspended basic blocks are processed
     FIFO, not LIFO like the normal worklist.  */
  mst_Boolean suspended;
  OOP stack[1];
} basic_block_item;

#define ALLOCA_BASIC_BLOCK(dest, depth, bp_, sp_) \
  do \
    { \
      *(dest) = alloca (sizeof (basic_block_item) + \
		        sizeof (OOP) * ((depth) - 1)); \
      (*(dest))->bb = (dest); \
      (*(dest))->bp = (bp_); \
      (*(dest))->sp = (sp_); \
      (*(dest))->suspended = false; \
    } \
  while (0)

#define INIT_BASIC_BLOCK(bb, temps) \
  do \
    { \
      int i; \
      for (i = 0; i < (temps); i++) \
	(bb)->stack[i] = FROM_INT (VARYING); \
      for (; i < (bb)->sp; i++) \
	(bb)->stack[i] = FROM_INT (UNDEFINED); \
    } \
  while (0)


/* Use the hash table and function in superop1.inl to look for a
   superoperator representing bytecode BC1 with argument ARG, followed
   by bytecode BC2.  */
static inline int search_superop_fixed_arg_1 (int bc1,
					      int arg,
					      int bc2);

/* Use the hash table and function in superop1.inl to look for a
   superoperator representing bytecode BC1 followed by bytecode BC2
   with argument ARG.  */
static inline int search_superop_fixed_arg_2 (int bc1,
					      int bc2,
					      int arg);

/* Scan the bytecodes between FROM and TO, performing a handful of
   peephole optimizations and creating superoperators with
   optimize_superoperators.  The optimized bytecodes are written
   starting at FROM.  */
static int optimize_basic_block (gst_uchar * from,
				 gst_uchar * to);

/* Scan the peephole-optimized bytecodes between FROM and TO.  Generate
   superoperators and rewrite in-place starting at FROM.  Return the
   pointer just past the final byte written. */
static gst_uchar *optimize_superoperators (gst_uchar * from,
					   gst_uchar * to);

/* This compares two block_boundary structures according to their
   ending bytecode position.  */
static int compare_blocks (const PTR a, const PTR b) ATTRIBUTE_PURE;

/* And this compares an int (A) with the starting bytecode of block B.  */
static int search_block (const PTR a, const PTR b) ATTRIBUTE_PURE;

/* Computes the length of a jump at distance OFS.  */
static int compute_jump_length (int ofs) ATTRIBUTE_CONST;

/* This answers how the dirtyness of BLOCKOOP affects
   the block that encloses it.  */
static inline int check_inner_block (OOP blockOOP);

/* This fills a table that says to which bytecodes a jump lands.
   Starting from BP, and for a total of SIZE bytes, bytecodes are
   analyzed and on output DEST[i] is non-zero if and
   only if BP[i] is the destination of a jump. It is positive
   for a forward jump and negative for a backward jump.  The number
   of jumps is returned.  */
static int make_destination_table (gst_uchar * bp,
				   int size,
				   char *dest);

/* Helper function to compute the bytecode verifier's `in'
   sets from the `out' sets.  */
static mst_Boolean merge_stacks (OOP *dest,
				 int dest_sp,
				 OOP *src,
				 int src_sp);


int
_gst_is_simple_return (bc_vector bytecodes,
		       OOP *literalOOP)
{
  gst_uchar *bytes;
  int maybe = MTH_NORMAL;
  OOP maybe_object = NULL;
  int i;

  *literalOOP = NULL;
  if (bytecodes == NULL)
    return (MTH_NORMAL);

  bytes = bytecodes->base;

  for (i = 1; i <= 4; i++)
    {
      int should_have_been_return = (maybe != MTH_NORMAL);
      if (bytes == bytecodes->ptr)
        return (MTH_NORMAL);

      MATCH_BYTECODES (IS_SIMPLE_RETURN, bytes, (
        PUSH_SELF { maybe = MTH_RETURN_SELF; }
        PUSH_RECEIVER_VARIABLE { maybe = (n << 8) | MTH_RETURN_INSTVAR; }
        PUSH_LIT_CONSTANT { maybe = (n << 8) | MTH_RETURN_LITERAL; }
        PUSH_INTEGER { maybe_object = FROM_INT (n); maybe = MTH_RETURN_LITERAL; }
        PUSH_SPECIAL {
          maybe = MTH_RETURN_LITERAL;
          switch (n)
	    {
	      case NIL_INDEX: maybe_object = _gst_nil_oop; break;
              case TRUE_INDEX: maybe_object = _gst_true_oop; break;
              case FALSE_INDEX: maybe_object = _gst_false_oop; break;
	      default: abort ();
	    }
        }

        LINE_NUMBER_BYTECODE { }
        RETURN_CONTEXT_STACK_TOP {
	  if (maybe_object)
	    *literalOOP = maybe_object;
	  return maybe;
	}

        STORE_RECEIVER_VARIABLE,
        PUSH_OUTER_TEMP, STORE_OUTER_TEMP,
        JUMP, POP_JUMP_TRUE, POP_JUMP_FALSE,
        PUSH_TEMPORARY_VARIABLE, PUSH_LIT_VARIABLE,
        STORE_TEMPORARY_VARIABLE, STORE_LIT_VARIABLE,
        SEND, POP_INTO_NEW_STACKTOP,
        POP_STACK_TOP, DUP_STACK_TOP,
        SEND_IMMEDIATE, EXIT_INTERPRETER,
        SEND_ARITH, SEND_SPECIAL, MAKE_DIRTY_BLOCK,
        RETURN_METHOD_STACK_TOP { return (MTH_NORMAL); }

        INVALID { abort(); }
      ));

      if (should_have_been_return)
	return (MTH_NORMAL);
    }

  return (MTH_NORMAL);
}

int
_gst_check_kind_of_block (bc_vector bc,
			  OOP * literals)
{
  int status, newStatus;
  gst_uchar *bp, *end;

  status = 0;			/* clean block */
  for (bp = bc->base, end = bc->ptr; bp != end; )
    {
      MATCH_BYTECODES (CHECK_KIND_OF_BLOCK, bp, (
        PUSH_SELF, PUSH_RECEIVER_VARIABLE, 
	STORE_RECEIVER_VARIABLE {
	  if (status == 0)
	    status = 1;
	}

        PUSH_LIT_CONSTANT {
	  newStatus = check_inner_block (literals[n]);
	  if (newStatus > status)
	    {
	      if (newStatus == 31)
		return (31);
	      status = newStatus;
	    }
        }

        PUSH_OUTER_TEMP, STORE_OUTER_TEMP  {
	  if (status < 1 + scopes) status = 1 + scopes;
	  if (status > 31)
	    /* ouch! how deep!! */
	    return (31);
	}

        JUMP,
        POP_JUMP_TRUE,
        POP_JUMP_FALSE,
        PUSH_TEMPORARY_VARIABLE,
        PUSH_LIT_VARIABLE,
        PUSH_SPECIAL,
        PUSH_INTEGER,
        RETURN_CONTEXT_STACK_TOP,
        LINE_NUMBER_BYTECODE,
        STORE_TEMPORARY_VARIABLE,
        STORE_LIT_VARIABLE,
        SEND,
        POP_INTO_NEW_STACKTOP,
        POP_STACK_TOP,
        DUP_STACK_TOP,
        EXIT_INTERPRETER,
        SEND_ARITH,
        SEND_SPECIAL,
        SEND_IMMEDIATE,
	MAKE_DIRTY_BLOCK { }

        RETURN_METHOD_STACK_TOP { return (31); }
        INVALID { abort(); }
      ));
    }
  return (status);
}

int
check_inner_block (OOP blockOOP)
{
  int newStatus;
  gst_compiled_block block;

  if (!IS_CLASS (blockOOP, _gst_compiled_block_class))
    return (0);

  /* Check the cleanness of the inner block and adequately change the status. 
     full block: no way dude -- exit immediately
     clean block: same for us 
     receiver access: same for us
     access to temps in the Xth context: from the perspective of the block
     being checked here, it is like an access to temps in the (X-1)th
     context access to this block's temps: our outerContext can be nil
     either, but for safety we won't be a clean block.  */
  block = (gst_compiled_block) OOP_TO_OBJ (blockOOP);
  newStatus = block->header.clean;
  switch (newStatus)
    {
    case 31:
    case 0:
    case 1:
      return (newStatus);
    default:
      return (newStatus - 1);
    }
}


int
compare_blocks (const PTR a, const PTR b)
{
  const block_boundary *ba = (const block_boundary *) a;
  const block_boundary *bb = (const block_boundary *) b;

  /* Sort by bytecode.  */
  if (ba->end != bb->end)
    return (ba->end - bb->end);

  /* Put first the element representing the jump.  */
  else if (ba->kind != -1 && bb->kind == -1)
    return -1;
  else if (bb->kind != -1 && ba->kind == -1)
    return 1;

  return 0;
}

int
search_block (const PTR a, const PTR b)
{
  const int *ia = (const int *) a;
  const block_boundary *bb = (const block_boundary *) b;

  return (*ia - bb->start);
}

int
compute_jump_length (int ofs)
{
  if (ofs > -256 && ofs < 256)
    return 2;
  else if (ofs > -65536 && ofs < 65536)
    return 4;
  else if (ofs > -16777216 && ofs < 16777216)
    return 6;
  else
    return 8;
}

bc_vector
_gst_optimize_bytecodes (bc_vector bytecodes)
{
#ifdef NO_OPTIMIZE
  return (bytecodes);
#else
  bc_vector old_bytecodes;
  block_boundary *blocks, *block, *last;
  gst_uchar *bp, *end, *first;
  int i;
  mst_Boolean changed;

  bp = bytecodes->base;
  end = bytecodes->ptr;
  blocks = alloca (sizeof (block_boundary) * (end - bp + 1));
  memset (blocks, 0, sizeof (block_boundary) * (end - bp + 1));

  /* 1) Split into basic blocks.  This part cheats so that the final
     fixup also performs jump optimization.  */
  for (last = blocks; bp != end; )
    {
      gst_uchar *dest = bp;
      gst_uchar *dest_ip0;
      mst_Boolean canOptimizeJump, split;
      int kind = 0;
      split = false;

      do
	{
	  dest_ip0 = dest;
	  canOptimizeJump = false;
	  MATCH_BYTECODES (THREAD_JUMPS, dest, (
	    MAKE_DIRTY_BLOCK,
	    SEND_SPECIAL,
	    SEND_ARITH,
	    SEND_IMMEDIATE,
	    PUSH_RECEIVER_VARIABLE,
	    PUSH_TEMPORARY_VARIABLE,
	    PUSH_LIT_CONSTANT,
	    PUSH_LIT_VARIABLE,
	    PUSH_SELF,
	    PUSH_SPECIAL,
	    PUSH_INTEGER,
	    LINE_NUMBER_BYTECODE,
	    STORE_RECEIVER_VARIABLE,
	    STORE_TEMPORARY_VARIABLE,
	    STORE_LIT_VARIABLE,
	    SEND,
	    POP_INTO_NEW_STACKTOP,
	    POP_STACK_TOP,
	    DUP_STACK_TOP,
	    PUSH_OUTER_TEMP,
	    STORE_OUTER_TEMP,
	    EXIT_INTERPRETER { }

	    JUMP {
	      if (ofs == 2
		  && dest[0] == LINE_NUMBER_BYTECODE)
		{
		  /* This could not be optimized to a nop, cause the
		     jump and line number bytecodes lie in different
		     basic blocks! So we rewrite it to a functionally
		     equivalent but optimizable bytecode sequence.  */
		  dest[-2] = dest[0];
		  dest[-1] = dest[1];
		}
	      else if (ofs == 4
		  && IS_PUSH_BYTECODE (dest[0])
		  && dest[2] == POP_STACK_TOP)
		{
		  /* This could not be optimized to a single pop,
		     cause the push and pop bytecodes lie in different
		     basic blocks! Again, rewrite to an optimizable
		     sequence.  */
		  dest[-2] = POP_STACK_TOP;
		  dest[-1] = 0;
		}
	      else
		{
	          /* Don't optimize jumps that have extension bytes.  But if we
		     jump to a return, we can safely optimize: returns are
		     never extended, and the interpreter ignores the extension
		     byte.  TODO: check if this is still true.  */
	          canOptimizeJump = (*IP0 != EXT_BYTE);
		  kind = IP[-2];
	          dest_ip0 = dest = IP0 + ofs;
	          canOptimizeJump |= IS_RETURN_BYTECODE (*dest);
		  split = true;
		}
	    }

	    POP_JUMP_TRUE, POP_JUMP_FALSE {
	      if (ofs == 0)
		{
		  dest[-2] = POP_STACK_TOP;
		  dest[-1] = 0;
		}

	      /* Jumps to CONDITIONAL jumps must not be touched, either because
		 they were unconditional or because they pop the stack top! */
	      else if (dest_ip0 == bp)
		{
		  kind = IP[-2];
		  dest_ip0 = dest = IP0 + ofs;
		  split = true;
		}
	    }

	    RETURN_METHOD_STACK_TOP, RETURN_CONTEXT_STACK_TOP {
	      /* Return bytecodes - patch the original jump to return
	         directly */
	      bp[0] = dest[-2];
	      bp[1] = 0;

	      /* This in fact eliminated the jump, don't split in basic 
	         blocks */
	      split = false;
	    }

	    INVALID { abort (); }
	  ));
	}
      while (canOptimizeJump);

      while (*bp == EXT_BYTE)
	bp += BYTECODE_SIZE;
      bp += BYTECODE_SIZE;

      if (split)
	{
	  assert (bp[-2] == kind);
	  assert (kind == JUMP || kind == JUMP_BACK
	  	  || kind == POP_JUMP_TRUE || kind == POP_JUMP_FALSE);

	  last->dest = -1;
  	  last->end = dest_ip0 - bytecodes->base;
	  last->kind = -1;
	  last++;
	  last->dest = dest_ip0 - bytecodes->base;
	  last->end = bp - bytecodes->base;
	  last->kind = kind;
	  last++;
	}
    }

  last->dest = -1;
  last->end = bp - bytecodes->base;
  last->kind = -1;
  last++;

  /* 2) Get the "real" block boundaries by sorting them according to
     where they happen in the original bytecode; then complete the
     data that was put in BLOCKS by setting the start of the basic
     block, removing the jump bytecode at the end...  */
  qsort (blocks, last - blocks, sizeof (block_boundary), compare_blocks);

  i = 0;
  for (block = blocks; block != last; block++)
    {
      block->start = i;
      if (block->end == i)
	continue;

      i = block->end;
      bp = bytecodes->base + block->end;
      if (bp[-2] == JUMP || bp[-2] == JUMP_BACK
	  || bp[-2] == POP_JUMP_TRUE || bp[-2] == POP_JUMP_FALSE)
	{
	  do
	    block->end -= BYTECODE_SIZE, bp -= BYTECODE_SIZE;
	  while (block->end != block->start && bp[-2] == EXT_BYTE);
	}
    }

  /* ... and computing the destination of the jump as a basic block */
  for (block = blocks; block != last; block++)
    if (block->kind != -1)
      block->dest_bb = bsearch (&block->dest, blocks, last - blocks,
				sizeof (block_boundary), search_block);

  /* Optimize the single basic blocks.  */
  i = 0;
  for (block = blocks; block != last; block++)
    {
      first = bytecodes->base + block->start;
      bp = bytecodes->base + block->end;
      block->opt_length = optimize_basic_block (first, bp);

#ifndef NO_SUPEROPERATORS
      /* Make a superoperator with the last bytecode and the jump.  */
      if (block->kind != -1
          && block->opt_length > 0
	  && !(block->opt_length > 2
	       && first[block->opt_length - 4] == EXT_BYTE))
	{
	  int test = search_superop_fixed_arg_1 (first[block->opt_length - 2],
					         first[block->opt_length - 1],
					         block->kind);
	  if (test != -1)
	    {
	      block->opt_length -= 2;
	      block->kind = test;
	    }
	}
#endif

      block->final_byte = i;
      i += block->opt_length;
    }

  /* Compute the size of the jump bytecodes.  */
  do
    {
      changed = false;
      i = 0;
      for (block = blocks; block != last; block++)
        {
          int jump_length;
          if (block->final_byte != i)
	    {
	      block->final_byte = i;
	      changed = true;
	    }
          if (block->kind != -1)
	    jump_length =
	      compute_jump_length (block->dest_bb->final_byte
				   - (block->final_byte + block->opt_length));
          else
	    jump_length = 0;
          i += block->opt_length + jump_length;
	}
    }
  while (changed);

  /* Put together the whole method.  */
  old_bytecodes = _gst_save_bytecode_array ();
  for (block = blocks; block != last; block++)
    {
      _gst_compile_bytecodes (bytecodes->base + block->start,
			      bytecodes->base + block->start + block->opt_length);
      if (block->kind != -1)
        {
	  int jump_length =
	    compute_jump_length (block->dest_bb->final_byte
				 - (block->final_byte + block->opt_length));
          int ofs = block->dest_bb->final_byte
		    - (block->final_byte + block->opt_length + jump_length);

	  if (ofs < 0)
	    ofs = -ofs;
	  _gst_compile_byte (block->kind, ofs);
	}
    }

  _gst_free_bytecodes (bytecodes);
  bytecodes = _gst_get_bytecodes ();
  _gst_restore_bytecode_array (old_bytecodes);
  return (bytecodes);
#endif
}

static inline int
search_superop_fixed_arg_1(int bc1, int arg, int bc2)
{
  /* ARG is in the range 0..255.  The format of the hash table entries is

     { { BC1, BC2, ARG }, SUPEROP } */

  struct superop_with_fixed_arg_1_type {
    unsigned char bytes[3];
    int superop;
  };

#include "superop1.inl"

  unsigned int key = asso_values[bc1] + asso_values[bc2] + asso_values[arg];

  register const struct superop_with_fixed_arg_1_type *k;

  if (key > MAX_HASH_VALUE)
    return -1;

  k = &keylist[key];
  if (bc1 == k->bytes[0] && bc2 == k->bytes[1] && arg == k->bytes[2])
    return k->superop;
  else
    return -1;
}


static inline int
search_superop_fixed_arg_2(int bc1, int bc2, int arg)
{
  /* ARG is in the range 0..255.  The format of the hash table entries is

     { { BC1, BC2, ARG }, SUPEROP } */

  struct superop_with_fixed_arg_2_type {
    unsigned char bytes[3];
    int superop;
  };

#include "superop2.inl"

  unsigned int key = asso_values[bc1] + asso_values[bc2] + asso_values[arg];

  register const struct superop_with_fixed_arg_2_type *k;

  if (key > MAX_HASH_VALUE)
    return -1;

  k = &keylist[key];
  if (bc1 == k->bytes[0] && bc2 == k->bytes[1] && arg == k->bytes[2])
    return k->superop;
  else
    return -1;
}

int
optimize_basic_block (gst_uchar *from,
		      gst_uchar *to)
{
  /* Points to the optimized bytecodes as they are written.  */
  gst_uchar *opt = from;

  /* Points to the unoptimized bytecodes as they are read.  */
  gst_uchar *bp = from;

  if (from == to)
    return 0;

  do
    {
      /* Perform peephole optimizations.  For simplicity, the optimizations
	 on line number bytecodes don't take into account the possibility
	 that the line number bytecode is extended (>256 lines in
	 a method).  This almost never happens, so we don't bother.  */
      switch (bp[0])
	{
        case PUSH_TEMPORARY_VARIABLE:
        case PUSH_RECEIVER_VARIABLE:
	  /* Leave only the store in store/pop/push sequences.  Don't do this
	     for STORE_LIT_VARIABLE, as it fails if #value: is sent and,
	     for example, self is returned.  */
	  if (opt >= from + 4
	      && (opt == from + 4 || opt[-6] != EXT_BYTE)
	      && opt[-4] == bp[0] + (STORE_TEMPORARY_VARIABLE - PUSH_TEMPORARY_VARIABLE)
	      && opt[-3] == bp[1]
	      && opt[-2] == POP_STACK_TOP
	      && bp[-2] != EXT_BYTE)
	    {
	      opt -= 2;
	      bp += 2;
	      continue;
	    }

	  /* Also rewrite store/pop/line/push to store/line in the middle.  */
	  if (opt >= from + 6
	      && (opt == from + 6 || opt[-8] != EXT_BYTE)
	      && opt[-6] == bp[0] + (STORE_TEMPORARY_VARIABLE - PUSH_TEMPORARY_VARIABLE)
	      && opt[-5] == bp[1]
	      && opt[-4] == POP_STACK_TOP
	      && opt[-2] == LINE_NUMBER_BYTECODE
	      && bp[-2] != EXT_BYTE)
	    {
	      opt[-4] = opt[-2];
	      opt[-3] = opt[-1];
	      opt -= 2;
	      bp += 2;
	      continue;
	    }

	  /* fall through to other pushes.  */

        case PUSH_OUTER_TEMP:
        case PUSH_INTEGER:
        case PUSH_SELF:
        case PUSH_SPECIAL:
        case PUSH_LIT_CONSTANT:
	  /* Remove a push followed by a pop */
          if (bp < to - 2
	      && bp[2] == POP_STACK_TOP)
	    {
	      bp += 4;
	      continue;
	    }

	  /* Remove the pop in a pop/push/return sequence */
          if (opt >= from + 2 && bp < to - 2
	      && bp[2] == RETURN_CONTEXT_STACK_TOP
	      && opt[-2] == POP_STACK_TOP)
	    opt -= 2;

	  /* Rewrite the pop/line number/push sequence to
	     line number/pop/push because this can be better
	     optimized by superoperators (making a superoperator
	     with a nop byte saves on decoding, but not on
	     scheduling the instructions in the interpreter!).  */
	  if (opt >= from + 4
	      && opt[-4] == POP_STACK_TOP
	      && opt[-2] == LINE_NUMBER_BYTECODE)
	    {
	      opt[-4] = LINE_NUMBER_BYTECODE;
	      opt[-3] = opt[-1];
	      opt[-2] = POP_STACK_TOP;
	      opt[-1] = 0;
	    }
	  break;

	case JUMP:
	case JUMP_BACK:
	case POP_JUMP_TRUE:
	case POP_JUMP_FALSE:
	  abort ();

	default:
	  break;
	}

      /* Else, just copy the bytecode to the optimized area.  */
      *opt++ = *bp++;
      *opt++ = *bp++;
    }
  while (bp < to);

#ifndef NO_SUPEROPERATORS
  opt = optimize_superoperators (from, opt);
#endif
  return opt - from;
}

gst_uchar *
optimize_superoperators (gst_uchar * from,
		         gst_uchar * to)
{
  /* Points to the optimized bytecodes that have been written. */
  gst_uchar *opt = from;

  /* Points to the unoptimized bytecodes as they are read.  */
  gst_uchar *bp = from;

  int new_bc;

  if (from == to)
    return from;

  *opt++ = *bp++;
  *opt++ = *bp++;
  while (bp < to)
    {
      /* Copy two bytecodes to the optimized area.  */
      *opt++ = *bp++;
      *opt++ = *bp++;

      do
        {
	  /* Try to match the case when the second argument is fixed.
	     We try this first because
		EXT_BYTE(*), SEND(1)

	     is more beneficial than
		EXT_BYTE(1), SEND(*).  */
	  new_bc = search_superop_fixed_arg_2 (opt[-4], opt[-2], opt[-1]);
	  if (new_bc != -1)
	    {
	      opt[-4] = new_bc;
	      /* opt[-3] is already ok */
	      opt -= 2;

	      /* Look again at the last four bytes.  */
	      continue;
	    }

	  /* If the first bytecode is not extended, try matching it with a
	     fixed argument.  We skip this when the first bytecode is
	     extended because otherwise we might have superoperators like

	       PUSH_OUTER_TEMP(1), SEND(*)

	     Suppose we find

	       EXT_BYTE(1), SUPEROP(2)

	     Now the argument to SEND is 2, but the interpreter receives
	     an argument of 258 and has to decode the argument to extract
	     the real argument of PUSH_OUTER_TEMP (found in the extension
	     byte).  This messes up everything and goes against the very
	     purpose of introducing superoperators.  */
	  if (opt - from == 4 || opt[-6] != EXT_BYTE)
	    {
	      new_bc = search_superop_fixed_arg_1 (opt[-4], opt[-3], opt[-2]);
	      if (new_bc != -1)
		{
		  opt[-4] = new_bc;
		  opt[-3] = opt[-1];
		  opt -= 2;

		  /* Look again at the last four bytes.  */
		  continue;
		}
	    }

	  /* Nothing matched.  Exit. */
	  break;
	}
      while (opt - from >= 4);
    }

  return opt;
}


void
_gst_compute_stack_positions (gst_uchar * bp,
			      int size,
			      PTR * base,
			      PTR ** pos)
{
  basic_block_item **bb_start, *bb_first, *worklist, *susp_head,
	**susp_tail = &susp_head;
  int bc_len;

  bb_start = alloca ((1 + size) * sizeof (basic_block_item *));
  memset (bb_start, 0, (1 + size) * sizeof (basic_block_item *));
  memset (pos, 0, (1 + size) * sizeof (PTR *));

  /* Allocate the first and last basic block specially */
  ALLOCA_BASIC_BLOCK (bb_start, 0, bp, 0);
  ALLOCA_BASIC_BLOCK (bb_start + size, 0, bp + size, 0);
  bb_first = bb_start[0];
  bb_first->next = NULL;

  /* First build the pointers to the basic blocks into BB_START.  Then use
     of a worklist here is only to find a correct order for visiting the
     basic blocks, not because they're visited multiple times.  This
     works transparently when we have a return in the middle of the method.
     Then the basic block is ending, yet it might be that the stack height
     for the next bytecode is already known!!! */
  for (susp_head = NULL, worklist = bb_first; worklist; )
    {
      int curr_sp = worklist->sp;
      bp = worklist->bp;
      bb_start = worklist->bb;
      worklist = worklist->next;

#ifdef DEBUG_JIT_TRANSLATOR
      printf ("Tracing basic block at %d:\n", bb_start - bb_first->bb);
#endif

      do
        {
	  int curr_ip = bb_start - bb_first->bb;
	  int balance;
	  gst_uchar *bp_first = bp;

#ifdef DEBUG_JIT_TRANSLATOR
          printf ("[SP=%3d]%5d:", curr_sp, curr_ip);
          _gst_print_bytecode_name (bp, curr_ip, NULL, "\t");
#endif

	  balance = 0;
	  pos[curr_ip] = base + curr_sp;

	  MATCH_BYTECODES (COMPUTE_STACK_POS, bp, (
	    RETURN_METHOD_STACK_TOP,
	    RETURN_CONTEXT_STACK_TOP {
	      bc_len = bp - bp_first;

	      /* We cannot fill the basic block right now because the
		 stack height might be different.  */
	      if (!bb_start[bc_len])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + bc_len, 0,
				      bp_first + bc_len, curr_sp + balance);
		  bb_start[bc_len]->suspended = true;
		  bb_start[bc_len]->next = NULL;
		  *susp_tail = bb_start[bc_len];
		  susp_tail = &(bb_start[bc_len]->next);
		}
	    }

            POP_INTO_NEW_STACKTOP,
            POP_STACK_TOP { balance--; }

            PUSH_RECEIVER_VARIABLE,
            PUSH_TEMPORARY_VARIABLE,
            PUSH_LIT_CONSTANT,
            PUSH_LIT_VARIABLE,
            PUSH_SELF,
            PUSH_SPECIAL,
            PUSH_INTEGER,
            DUP_STACK_TOP,
            PUSH_OUTER_TEMP { balance++; }

            LINE_NUMBER_BYTECODE,
            STORE_RECEIVER_VARIABLE,
            STORE_TEMPORARY_VARIABLE,
            STORE_LIT_VARIABLE,
            STORE_OUTER_TEMP,
            EXIT_INTERPRETER,
            MAKE_DIRTY_BLOCK { }

            SEND {
	      balance -= super + num_args;
	    }

	    SEND_ARITH {
	      balance -= _gst_builtin_selectors[n].numArgs;
	    }

	    SEND_IMMEDIATE {
	      balance -= super + _gst_builtin_selectors[n].numArgs;
	    }

            SEND_SPECIAL {
	      balance -= _gst_builtin_selectors[n + 16].numArgs;
	    }

            INVALID {
	      abort ();
	    }

            JUMP {
	      bc_len = bp - bp_first;

	      /* We cannot fill the basic block right now because the
		 stack height might be different.  */
	      if (!bb_start[bc_len])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + bc_len, 0,
				      bp_first + bc_len, 0);
		  bb_start[bc_len]->suspended = true;
		  bb_start[bc_len]->next = NULL;
		  *susp_tail = bb_start[bc_len];
		  susp_tail = &(bb_start[bc_len]->next);
		}

	      if (!bb_start[ofs])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + ofs, 0,
				      bp_first + ofs, curr_sp + balance);
		  bb_start[ofs]->next = worklist;
		  worklist = bb_start[ofs];
		}
	      else if (bb_start[ofs]->suspended)
		{
		  bb_start[ofs]->suspended = false;
		  bb_start[ofs]->sp = curr_sp + balance;
		}
	      else if (curr_sp + balance != bb_start[ofs]->sp)
		abort ();
	    }

	    POP_JUMP_TRUE, POP_JUMP_FALSE {
	      balance--;
	      bc_len = bp - bp_first;
	      if (!bb_start[bc_len])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + bc_len, 0,
				      bp_first + bc_len, curr_sp + balance);
		  bb_start[bc_len]->next = worklist;
		  worklist = bb_start[bc_len];
		}
	      else if (bb_start[bc_len]->suspended)
		{
		  bb_start[bc_len]->suspended = false;
		  bb_start[bc_len]->sp = curr_sp + balance;
		}
	      else if (curr_sp + balance != bb_start[bc_len]->sp)
		abort ();

	      if (!bb_start[ofs])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + ofs, 0,
				      bp_first + ofs, curr_sp + balance);
		  bb_start[ofs]->next = worklist;
		  worklist = bb_start[ofs];
		}
              else if (bb_start[ofs]->suspended)
		{
		  bb_start[ofs]->suspended = false;
		  bb_start[ofs]->sp = curr_sp + balance;
		}
	      else if (curr_sp + balance != bb_start[ofs]->sp)
		abort ();
            }
          ));

	  curr_sp += balance;
	  bb_start += bp - bp_first;
	}
      while (!*bb_start);

      if (!worklist && susp_head)
	{
	  worklist = susp_head;
	  susp_head = susp_head->next;
	  worklist->next = NULL;
	  if (!susp_head)
	    susp_tail = &susp_head;
	}
    }
}


void
_gst_analyze_bytecodes (OOP methodOOP,
			 int size,
			 char *dest)
{
  gst_uchar *bp;

  bp = GET_METHOD_BYTECODES (methodOOP);
  make_destination_table (bp, size, dest);

  /* Nothing more for now */
}

int
make_destination_table (gst_uchar * bp,
			int size,
			char *dest)
{
  gst_uchar *end, *bp_first;
  int count;

  memset (dest, 0, sizeof (char) * size);

  for (count = 0, end = bp + size; bp != end;
       dest += bp - bp_first)
    {
      bp_first = bp;
      MATCH_BYTECODES (MAKE_DEST_TABLE, bp, (
        PUSH_RECEIVER_VARIABLE,
        PUSH_TEMPORARY_VARIABLE,
        PUSH_LIT_CONSTANT,
        PUSH_LIT_VARIABLE,
        PUSH_SELF,
        PUSH_SPECIAL,
        PUSH_INTEGER,
        RETURN_METHOD_STACK_TOP,
        RETURN_CONTEXT_STACK_TOP,
        LINE_NUMBER_BYTECODE,
        STORE_RECEIVER_VARIABLE,
        STORE_TEMPORARY_VARIABLE,
        STORE_LIT_VARIABLE,
        SEND,
        POP_INTO_NEW_STACKTOP,
        POP_STACK_TOP,
        DUP_STACK_TOP,
        PUSH_OUTER_TEMP,
        STORE_OUTER_TEMP,
        EXIT_INTERPRETER,
        SEND_ARITH,
        SEND_SPECIAL,
        SEND_IMMEDIATE,
	MAKE_DIRTY_BLOCK { }

        INVALID { abort(); }

        JUMP, POP_JUMP_TRUE, POP_JUMP_FALSE {
          dest[ofs] = ofs > 0 ? 1 : -1;
	  count++;
        }
      ));
    }

  return (count);
}



#define SELF 0
#define VARYING 1
#define UNDEFINED 2

typedef struct partially_constructed_array {
  struct partially_constructed_array *next;
  int sp;
  int size;
} partially_constructed_array;

#define CHECK_LITERAL(n) \
  /* Todo: recurse into BlockClosures! */ \
  last_used_literal = literals[n]; \
  if ((n) >= num_literals) \
    return ("literal out of range");

#define CHECK_TEMP(n) \
  last_used_literal = NULL; \
  if ((n) >= sp - stack) \
    return ("temporary out of range");

#define CHECK_REC_VAR(first, n) \
  last_used_literal = NULL; \
  if ((n) < (first) || (n) >= num_rec_vars) \
    return ("receiver variable out of range");

#define CHECK_LIT_VARIABLE(store, n) \
  CHECK_LITERAL (n); \
  if (IS_INT (literals[(n)]) || \
      !is_a_kind_of (OOP_CLASS (literals[(n)]), _gst_lookup_key_class)) \
    return ("LookupKey expected"); \
  else if (store \
	   && untrusted \
	   && !IS_OOP_UNTRUSTED (literals[(n)])) \
    return ("Invalid global variable access");

#define LIT_VARIABLE_CLASS(n) \
  /* Special case classes because of super and {...} */ \
  (IS_A_CLASS (ASSOCIATION_VALUE (literals[(n)])) \
   ? OOP_CLASS (ASSOCIATION_VALUE (literals[(n)])) \
   : FROM_INT (VARYING))

#define LITERAL_CLASS(n) \
  OOP_INT_CLASS (literals[(n)])

/* Bytecode verification is a dataflow analysis on types.  We perform it
   on basic blocks: `in' is the stack when entering the basic block and
   `out' is the stack upon exit.

   Each member of the stack can be UNDEFINED, a type, or VARYING.  When
   merging two `out' stacks to compute an `in' stack, we have these
   possible situations:
   - the stacks are not the same height, and bytecode verification fails
   - a slot is the same in both stacks, so it has this type in the output too
   - a slot is different in the two stacks, so it is VARYING in the output.

   Bytecode verification proceeds forwards, so the worklist is added all the
   successors of the basic block whenever merging results in a difference.  */

mst_Boolean
merge_stacks (OOP *dest, int dest_sp,
	      OOP *src, int src_sp)
{
  mst_Boolean varied = false;
  assert (dest_sp == src_sp);

  for (; src_sp--; dest++, src++)
    {
      OOP newDest = *src;
      if (newDest != *src)
	{
	  if (*dest != FROM_INT (UNDEFINED))
	    /* If different, mark as overdefined.  */
	    newDest = FROM_INT (VARYING);

	  if (newDest != *dest)
	    {
	      *dest = newDest;
	      varied = true;
	    }
	}
    }

  return (varied);
}

void
_gst_verify_sent_method (OOP methodOOP)
{
  const char *error;
  error = _gst_verify_method (methodOOP, NULL, 0);

  if (error)
    {
      _gst_errorf ("Bytecode verification failed: %s", error);
      if (OOP_CLASS (methodOOP) == _gst_compiled_block_class)
        methodOOP = GET_BLOCK_METHOD (methodOOP);

      _gst_errorf ("Method verification failed for %O>>%O",
                   GET_METHOD_CLASS (methodOOP),
                   GET_METHOD_SELECTOR (methodOOP));

      abort ();
    }
}

const char *
_gst_verify_method (OOP methodOOP, int *num_outer_temps, int depth)
{
#ifndef NO_VERIFIER
  int size, bc_len, num_temps, stack_depth,
    num_literals, num_rec_vars, num_ro_rec_vars;

  mst_Boolean untrusted;
  const char *error;
  gst_uchar *bp;
  OOP *literals, methodClass, last_used_literal;
  basic_block_item **bb_start, *bb_first, *worklist, *susp_head,
    **susp_tail = &susp_head;
  partially_constructed_array *arrays = NULL, *arrays_pool = NULL;

  if (IS_OOP_VERIFIED (methodOOP))
    return (NULL);

  size = NUM_INDEXABLE_FIELDS (methodOOP);
  bp = GET_METHOD_BYTECODES (methodOOP);
  literals = GET_METHOD_LITERALS (methodOOP);
  methodClass = GET_METHOD_CLASS (methodOOP);
  num_literals = NUM_METHOD_LITERALS (methodOOP);
  num_rec_vars = CLASS_FIXED_FIELDS (methodClass);
  untrusted = IS_OOP_UNTRUSTED (methodOOP);

  if (is_a_kind_of (OOP_CLASS (methodOOP), _gst_compiled_method_class))
    {
      method_header header;
      header = GET_METHOD_HEADER (methodOOP);
      num_temps = header.numArgs + header.numTemps;
      stack_depth = header.stack_depth << DEPTH_SCALE;
      switch (header.headerFlag)
        {
	case MTH_NORMAL:
	case MTH_PRIMITIVE:
	case MTH_ANNOTATED:
	case MTH_UNUSED:
	  break;

	case MTH_USER_DEFINED:
	case MTH_RETURN_SELF:
	  methodOOP->flags |= F_VERIFIED;
	  return (NULL);

	case MTH_RETURN_INSTVAR:
	  CHECK_REC_VAR (0, header.primitiveIndex);
	  methodOOP->flags |= F_VERIFIED;
	  return (NULL);

	case MTH_RETURN_LITERAL:
	  CHECK_LITERAL (0);
	  methodOOP->flags |= F_VERIFIED;
	  return (NULL);
        }
    }
  else if (OOP_CLASS (methodOOP) == _gst_compiled_block_class)
    {
      block_header header;
      header = GET_BLOCK_HEADER (methodOOP);

      /* If we're verifying a block but not from a nested call,
	 restart from the top-level method.  */
      if (header.clean != 0 && depth == 0)
	return _gst_verify_method (GET_BLOCK_METHOD (methodOOP), NULL, 0);

      num_temps = header.numArgs + header.numTemps;
      stack_depth = header.depth << DEPTH_SCALE;
    }
  else
    return "invalid class";

  if (untrusted)
    {
       OOP class_oop;
       for (class_oop = methodClass; IS_OOP_UNTRUSTED (class_oop);
            class_oop = SUPERCLASS (class_oop))
         ;

       num_ro_rec_vars = CLASS_FIXED_FIELDS (class_oop);
    }
  else
    num_ro_rec_vars = 0;

#ifdef DEBUG_VERIFIER
  printf ("Verifying %O (max. stack depth = %d):\n", methodOOP, stack_depth);
#endif

  /* Prepare the NUM_OUTER_TEMPS array for the inner blocks.  */
  if (depth)
    {
      int *new_num_outer_temps = alloca (sizeof (int) * (depth + 1));
      memcpy (new_num_outer_temps + 1, num_outer_temps, sizeof (int) * depth);
      new_num_outer_temps[0] = num_temps;
      num_outer_temps = new_num_outer_temps;
    }
  else
    num_outer_temps = &num_temps;

  depth++;

  bb_start = alloca ((1 + size) * sizeof (basic_block_item *));
  memset (bb_start, 0, (1 + size) * sizeof (basic_block_item *));

  /* Allocate the first and last basic block specially */
  ALLOCA_BASIC_BLOCK(bb_start, stack_depth, bp, num_temps);
  ALLOCA_BASIC_BLOCK(bb_start + size, stack_depth, bp + size, num_temps);
  bb_first = bb_start[0];
  bb_first->next = NULL;

  /* First build the pointers to the basic blocks into BB_START.  The use
     of a worklist here is only to find a correct order for visiting the
     basic blocks, not because they're visited multiple times.  This
     works transparently when we have a return in the middle of the method.
     Then the basic block is ending, yet it might be that the stack height
     for the next bytecode is already known!!! */
  for (susp_head = NULL, worklist = bb_first; worklist; )
    {
      int curr_sp = worklist->sp;
      bp = worklist->bp;
      bb_start = worklist->bb;
      worklist = worklist->next;

#ifdef DEBUG_VERIFIER
      printf ("Tracing basic block at %d:\n", bb_start - bb_first->bb);
#endif

      do
        {
	  int curr_ip = bb_start - bb_first->bb;
	  int balance;
	  gst_uchar *bp_first = bp;

#ifdef DEBUG_VERIFIER
          printf ("[SP=%3d]%5d:", curr_sp, curr_ip);
          _gst_print_bytecode_name (bp, curr_ip, literals, "\t");
#endif

	  balance = 0;
	  MATCH_BYTECODES (CREATE_BASIC_BLOCKS, bp, (
	    RETURN_METHOD_STACK_TOP,
	    RETURN_CONTEXT_STACK_TOP {
	      bc_len = bp - bp_first;

	      /* We cannot fill the basic block right now because the
		 stack height might be different.  */
	      if (!bb_start[bc_len])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + bc_len, stack_depth,
				      bp_first + bc_len, curr_sp + balance);
		  bb_start[bc_len]->suspended = true;
		  bb_start[bc_len]->next = NULL;
		  *susp_tail = bb_start[bc_len];
		  susp_tail = &(bb_start[bc_len]->next);
		}
	    }

            POP_STACK_TOP { balance--; }

            PUSH_RECEIVER_VARIABLE,
            PUSH_TEMPORARY_VARIABLE,
            PUSH_LIT_CONSTANT,
            PUSH_LIT_VARIABLE,
            PUSH_SELF,
            PUSH_SPECIAL,
            PUSH_INTEGER,
            PUSH_OUTER_TEMP { balance++; }

            LINE_NUMBER_BYTECODE,
            STORE_RECEIVER_VARIABLE,
            STORE_TEMPORARY_VARIABLE,
            STORE_LIT_VARIABLE,
            STORE_OUTER_TEMP,
            EXIT_INTERPRETER,
            MAKE_DIRTY_BLOCK { }

            SEND {
	      balance -= super + num_args;

	      /* Sends touch the new stack top, so they require an extra slot.  */
	      if (curr_sp + balance < 1)
	        return ("stack underflow");
	    }

	    SEND_ARITH {
	      if (!_gst_builtin_selectors[n].symbol)
		return ("invalid immediate send");

	      balance -= _gst_builtin_selectors[n].numArgs;

	      /* Sends touch the new stack top, so they require an extra slot.  */
	      if (curr_sp + balance < 1)
	        return ("stack underflow");
	    }

            SEND_SPECIAL {
	      if (!_gst_builtin_selectors[n + 16].symbol)
		return ("invalid immediate send");

	      balance -= _gst_builtin_selectors[n + 16].numArgs;

	      /* Sends touch the new stack top, so they require an extra slot.  */
	      if (curr_sp + balance < 1)
	        return ("stack underflow");
	    }

            SEND_IMMEDIATE {
	      if (!_gst_builtin_selectors[n].symbol)
		return ("invalid immediate send");

	      balance -= super + _gst_builtin_selectors[n].numArgs;

	      /* Sends touch the new stack top, so they require an extra slot.  */
	      if (curr_sp + balance < 1)
	        return ("stack underflow");
	    }

            POP_INTO_NEW_STACKTOP {
	      balance--;

	      /* Sends touch the new stack top, so they require an extra slot.  */
	      if (curr_sp + balance < 1)
	        return ("stack underflow");
	    }

            DUP_STACK_TOP {
	      balance++;
	    }

            INVALID {
	      return ("invalid bytecode");
	    }

            JUMP {
	      if (ofs & 1)
		return ("jump to odd offset");

	      if (ofs + curr_ip < 0 || ofs + curr_ip > size)
		return ("jump out of range");

	      if (ofs + curr_ip > 0 && bp_first[ofs - 2] == EXT_BYTE)
		return ("jump skips extension bytecode");

	      bc_len = bp - bp_first;

	      /* We cannot fill the basic block right now because the
		 stack height might be different.  */
	      if (!bb_start[bc_len])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + bc_len, stack_depth,
				      bp_first + bc_len, 0);
		  bb_start[bc_len]->suspended = true;
		  bb_start[bc_len]->next = NULL;
		  *susp_tail = bb_start[bc_len];
		  susp_tail = &(bb_start[bc_len]->next);
		}

	      if (!bb_start[ofs])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + ofs, stack_depth,
				      bp_first + ofs, curr_sp + balance);

		  bb_start[ofs]->next = worklist;
		  worklist = bb_start[ofs];
		  INIT_BASIC_BLOCK (worklist, num_temps);
		}
	      else if (bb_start[ofs]->suspended)
	        {
		  bb_start[ofs]->suspended = false;
		  bb_start[ofs]->sp = curr_sp + balance;
		  INIT_BASIC_BLOCK (bb_start[ofs], num_temps);
		}
	      else if (curr_sp + balance != bb_start[ofs]->sp)
		return ("stack height mismatch");
	    }

	    POP_JUMP_TRUE, POP_JUMP_FALSE {
	      balance--;
	      if (ofs & 1)
		return ("jump to odd offset");

	      if (ofs + curr_ip < 0 || ofs + curr_ip > size)
		return ("jump out of range");

	      if (ofs + curr_ip > 0 && bp_first[ofs - 2] == EXT_BYTE)
		return ("jump skips extension bytecode");

	      bc_len = bp - bp_first;
	      if (!bb_start[bc_len])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + bc_len, stack_depth,
				      bp_first + bc_len, curr_sp + balance);

		  bb_start[bc_len]->next = worklist;
		  worklist = bb_start[bc_len];
		  INIT_BASIC_BLOCK (worklist, num_temps);
		}
              else if (bb_start[bc_len]->suspended)
                {
                  bb_start[bc_len]->suspended = false;
                  bb_start[bc_len]->sp = curr_sp + balance;
		  INIT_BASIC_BLOCK (bb_start[bc_len], num_temps);
                }
	      else if (curr_sp + balance != bb_start[bc_len]->sp)
		return ("stack height mismatch");

	      if (!bb_start[ofs])
		{
		  ALLOCA_BASIC_BLOCK (bb_start + ofs, stack_depth,
				      bp_first + ofs, curr_sp + balance);

		  bb_start[ofs]->next = worklist;
		  worklist = bb_start[ofs];
		  INIT_BASIC_BLOCK (worklist, num_temps);
		}
	      else if (bb_start[ofs]->suspended)
	        {
		  bb_start[ofs]->suspended = false;
		  bb_start[ofs]->sp = curr_sp + balance;
		  INIT_BASIC_BLOCK (bb_start[ofs], num_temps);
		}
	      else if (curr_sp + balance != bb_start[ofs]->sp)
		return ("stack height mismatch");
            }
          ));

	  curr_sp += balance;
	  if (curr_sp >= stack_depth)
	    return ("stack overflow");

	  bb_start += bp - bp_first;
	}
      while (!*bb_start);

      if (!worklist && susp_head)
	{
	  worklist = susp_head;
	  susp_head = susp_head->next;
	  worklist->next = NULL;
	  if (!susp_head)
	    susp_tail = &susp_head;
	}

#ifdef DEBUG_VERIFIER
      printf ("\n");
#endif
    }

  for (worklist = bb_first; worklist; )
    {
      OOP *stack = worklist->stack;
      OOP *sp;

      /* Look for unreachable basic blocks.  */
      if (worklist->sp < 0)
	abort ();

      sp = stack + worklist->sp;
      bp = worklist->bp;
      bb_start = worklist->bb;
      worklist = worklist->next;

#ifdef DEBUG_VERIFIER
      printf ("Executing basic block at %d:\n", bb_start - bb_first->bb);
#endif
      last_used_literal = NULL;

      do
	{
	  gst_uchar *bp_first = bp;

#ifdef DEBUG_VERIFIER
          printf ("[SP=%3d]%5d:", sp - stack, bb_start - bb_first->bb);
          _gst_print_bytecode_name (bp, bb_start - bb_first->bb, literals, "\t");
#endif

	  MATCH_BYTECODES (EXEC_BASIC_BLOCK, bp, (
	    PUSH_RECEIVER_VARIABLE {
	      CHECK_REC_VAR (0, n);
	      *sp++ = FROM_INT (VARYING);
	    }

	    PUSH_TEMPORARY_VARIABLE {
	      CHECK_TEMP (n);
	      *sp++ = stack[n];
	    }

	    PUSH_LIT_CONSTANT {
	      CHECK_LITERAL (n);
	      *sp++ = LITERAL_CLASS (n);
	    }

	    PUSH_LIT_VARIABLE {
	      CHECK_LIT_VARIABLE (false, n);
	      *sp++ = LIT_VARIABLE_CLASS (n);
	    }

	    PUSH_SELF {
	      last_used_literal = NULL;
	      *sp++ = FROM_INT (SELF);
	    }
	    PUSH_SPECIAL {
	      switch (n)
		{
		  case NIL_INDEX: last_used_literal = _gst_nil_oop; break;
	          case TRUE_INDEX: last_used_literal = _gst_true_oop; break;
	          case FALSE_INDEX: last_used_literal = _gst_false_oop; break;
		  default: return "invalid special object index";
		}

	      *sp++ = OOP_CLASS (last_used_literal);
	    }
	    PUSH_INTEGER {
	      last_used_literal = FROM_INT (n);
	      *sp++ = _gst_small_integer_class;
	    }

	    RETURN_METHOD_STACK_TOP {
              block_header header;
	      if (OOP_CLASS (methodOOP) != _gst_compiled_block_class)
		return "invalid return from method";

              header = GET_BLOCK_HEADER (methodOOP);
              if (header.clean != (1 << BLK_CLEAN_BITS) - 1)
		return "invalid return from clean block";

	      break;
	    }
	    RETURN_CONTEXT_STACK_TOP { break; }

	    LINE_NUMBER_BYTECODE { }

	    STORE_RECEIVER_VARIABLE {
	      CHECK_REC_VAR (num_ro_rec_vars, n);
	    }
	    STORE_TEMPORARY_VARIABLE {
	      CHECK_TEMP (n);
	    }
	    STORE_LIT_VARIABLE {
	      CHECK_LIT_VARIABLE (true, n);
	    }

	    SEND {
	      if (super
		  && (!last_used_literal
		      || (!IS_A_CLASS (last_used_literal)
		          && !IS_A_METACLASS (last_used_literal))
		      || !is_a_kind_of (methodClass, last_used_literal)))
		return ("Invalid send to super");

	      last_used_literal = NULL;
	      sp -= super + num_args;
	      if (super && sp[-1] != FROM_INT (SELF))
		return ("Invalid send to super");

	      sp[-1] = FROM_INT (VARYING);
	    }

	    POP_INTO_NEW_STACKTOP {
	      if (sp[-2] != _gst_array_class)
	        return ("Array expected");

	      if (!arrays || &sp[-2] - stack != arrays->sp)
	        return ("Invalid Array constructor");

	      if (n >= arrays->size)
	        return ("Out of bounds Array access");

	      /* Discard arrays whose construction has ended.  */
	      if (n == arrays->size - 1)
	        {
	          partially_constructed_array *next = arrays->next;
	          arrays->next = arrays_pool;
	          arrays_pool = arrays;
	          arrays = next;
	        }

	      last_used_literal = NULL;
	      sp--;
	    }

	    POP_STACK_TOP {
	      last_used_literal = NULL;
	      sp--;
	    }
	    DUP_STACK_TOP {
	      sp++;
	      sp[-1] = sp[-2];
	    }

	    PUSH_OUTER_TEMP {
	      if (scopes == 0 || scopes > depth || n >= num_outer_temps[scopes])
	        return ("temporary out of range");

	      last_used_literal = NULL;
	      *sp++ = FROM_INT (VARYING);
	    }

	    STORE_OUTER_TEMP {
	      if (scopes == 0 || scopes > depth || n >= num_outer_temps[scopes])
	        return ("temporary out of range");
	    }

	    EXIT_INTERPRETER {
	      if (size != 4
		  || IP0 != GET_METHOD_BYTECODES (methodOOP)
		  || *bp != RETURN_CONTEXT_STACK_TOP)
		return ("bad termination method");
	    }

	    JUMP {
	      if (merge_stacks (stack, sp - stack, bb_start[ofs]->stack,
				bb_start[ofs]->sp))
		bb_start[ofs]->next = worklist, worklist = bb_start[ofs];
	    }

	    POP_JUMP_TRUE, POP_JUMP_FALSE {
	      sp--;
	      bc_len = bp - bp_first;
	      if (merge_stacks (stack, sp - stack, bb_start[bc_len]->stack,
				bb_start[bc_len]->sp))
		bb_start[bc_len]->next = worklist, worklist = bb_start[bc_len];

	      if (merge_stacks (stack, sp - stack, bb_start[ofs]->stack,
				bb_start[ofs]->sp))
		bb_start[ofs]->next = worklist, worklist = bb_start[ofs];
	    }

	    SEND_ARITH {
	      sp -= _gst_builtin_selectors[n].numArgs;
	      sp[-1] = FROM_INT (VARYING);
	    }
	    SEND_SPECIAL {
	      sp -= _gst_builtin_selectors[n + 16].numArgs;
	      sp[-1] = FROM_INT (VARYING);
	    }

	    SEND_IMMEDIATE {
	      if (n == NEW_COLON_SPECIAL
		  && IS_INT (last_used_literal)
		  && last_used_literal != FROM_INT (0)
		  && sp[-2] == OOP_CLASS (_gst_array_class))
		{
		  partially_constructed_array *a;
		  sp--;

		  /* If possible, reuse an existing struct, else allocate a new one.  */
		  if (arrays_pool)
		    {
		      a = arrays_pool;
		      arrays_pool = arrays_pool->next;
		    }
		  else
		    a = alloca (sizeof (partially_constructed_array));

		  a->size = TO_INT (last_used_literal);
		  a->sp = &sp[-1] - stack;
		  a->next = arrays;
		  arrays = a;

		  sp[-1] = _gst_array_class;
		}
	      else
	        {
		  if (super
		      && (!last_used_literal
			  || (!IS_A_CLASS (last_used_literal)
			      && !IS_A_METACLASS (last_used_literal))
			  || !is_a_kind_of (methodClass, last_used_literal)))
		    return (_gst_debug (), "Invalid send to super");

		  last_used_literal = NULL;
	          sp -= super + _gst_builtin_selectors[n].numArgs;
	          if (super && sp[-1] != FROM_INT (SELF))
		    return ("Invalid send to super");

	          sp[-1] = FROM_INT (VARYING);
		}
	    }

	    MAKE_DIRTY_BLOCK {
	      if (sp[-1] != _gst_compiled_block_class
		  || !last_used_literal)
		return ("CompiledBlock expected");

	      error = _gst_verify_method (last_used_literal, num_outer_temps, depth);
	      if (error)
	        return (error);
	    }

	    INVALID {
	      abort ();
	    }
	  ));

	  bb_start += bp - bp_first;
	}
      while (!*bb_start);

#ifdef DEBUG_VERIFIER
      printf ("\n");
#endif
    }
#endif /* !NO_VERIFIER */

  methodOOP->flags |= F_VERIFIED;
  return (NULL);
}

