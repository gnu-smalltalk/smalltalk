/******************************** -*- C -*- ****************************
 *
 *	Functions for byte code optimization & analysis
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"


/* Define this to disable the peephole bytecode optimizer.  It works
   well and increases a bit performance, so there's no reason to do that
   unless you're debugging the compiler. */
/* #define NO_OPTIMIZE */

/* The JIT compiler prefers optimized bytecodes, because they are
   more regular. */
#ifdef USE_JIT_TRANSLATION
#undef NO_OPTIMIZE
#endif

/* This specifies which bytecodes are pushes */
const int _gst_is_push_table[256] = {
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 0 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 16 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 32 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 48 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 64 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 80 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 96 */
  1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,	/* 112 */
  1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0,	/* 128 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 144 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 160 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 176 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 192 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 208 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 224 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};				/* 240 */

/* This specifies which bytecodes are message sends */
const int _gst_is_send_table[256] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 0 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 16 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 32 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 48 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 64 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 80 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 96 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 112 */
  0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 128 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 144 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,	/* 160 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 176 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 192 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 208 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	/* 224 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
};				/* 240 */

/* This specifies the stack balance of bytecodes  */
static const int stack_balance_table[256] = {
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,		  /* 0 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,		  /* 16 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,		  /* 32 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,		  /* 48 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,		  /* 64 */
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,		  /* 80 */
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 96 */
  1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 255, 0,		  /* 112 */
  1, 0, -1, 255, 255, 255, 255, -1, 1, 1, 255, 0, 0, 0, 0, 0,	  /* 128 */
  0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1,	  /* 144 */
  0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1,	  /* 160 */
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 176 */
  -1, -2, 0, 0, -1, 0, -1, 0, -1, 0, -1, -1, 0, -1, 0, 0,	  /* 192 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,		  /* 208 */
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 224 */
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2  /* 240 */
};

/* The offsets for 2-byte jump bytecodes.  The final offset
   is jump_offsets[FIRST_BYTE & 15] + SECOND_BYTE */
static const int jump_offsets[16] = {
  -1022, -766, -510, -254, 2, 258, 514, 770,
  2, 258, 514, 770, 2, 258, 514, 770
};


/* This structure and the following one are used by the bytecode
   peephole optimizer.
   
   This one, in particular, defines where basic blocks start in the
   non- optimized bytecodes. byte is nothing more than an offset in
   those bytecodes; id is used to pair jump bytecodes with their
   destinations: in the initial scan, when we encounter a jump
   bytecode we fill two block_boundaries -- one has positive id and
   represents the destination of the jump, one has negative id (but
   the same absolute value) and represents the jump bytecode
   itself. */
typedef struct block_boundary
{
  short byte;
  short id;
}
block_boundary;

/* This structure defines how to fix the jumps after the optimized
   basic blocks are put together.  Everything is done after the
   peephole pass because this allows us to handle forward jumps and
   backward jumps in the same way.

   When single blocks are optimized, the sorted block_boundaries are
   examined one at a time.  As we process blocks, we fill an array of
   jump structures with offsets in the optimized bytecode.  We fill a
   single field at a time -- the id's sign in the block_boundary says
   which field is to be filled, the absolute value gives which jump
   structure is to be filled.  In the end, block_boundaries whose id's
   absolute value is the same are all paired. */
typedef struct jump
{
  int from;			/* where the jump bytecode lies */
  int dest;			/* where the jump bytecode lands */
}
jump;


/* Scan the bytecodes between FROM and TO. As they are
   scanned, they are overwritten with an optimized version; in
   the end, _gst_compile_bytecodes() is used to append them to the
   stream of optimized bytecodes.  The return value indicates
   whether at least a bytecode was generated.  */
static mst_Boolean optimize_basic_block (gst_uchar * from,
					 gst_uchar * to);


/* This compares two block_boundary structures according to their
   bytecode position. */
static int compare_blocks (const PTR a, const PTR b) ATTRIBUTE_PURE;

/* This answers how the dirtyness of BLOCKCLOSUREOOP affects
   the block that encloses it.  */
static inline int check_inner_block (OOP blockClosureOOP);

/* This fills a table that says to which bytecodes a jump lands.
   Starting from BP, and for a total of SIZE bytes, bytecodes are
   analyzed and on output DEST[i] is non-zero if and
   only if BP[i] is the destination of a jump. It is positive
   for a forward jump and negative for a backward jump.  The number
   of jumps is returned.  */
static int make_destination_table (gst_uchar * bp,
				   int size,
				   char *dest);

int
_gst_is_simple_return (bytecodes bytecodes)
{
  gst_uchar *bytes;
  long byteCodeLen;

  if (bytecodes == NULL)
    return (0);

  byteCodeLen = _gst_bytecode_length (bytecodes);
  bytes = bytecodes->base;

  if (bytes[0] == LINE_NUMBER_BYTECODE)
    {
      byteCodeLen -= 3;
      bytes += 3;
    }

  if (byteCodeLen == 2)
    {
      if (bytes[1] != RETURN_CONTEXT_STACK_TOP)
	return (0);

      /* check for ^INSTANCE_VARIABLE */
      if ((bytes[0] & ~15) == PUSH_RECEIVER_VARIABLE)
	return (((bytes[0] & 0x0F) << 8) | 2);

      /* check for ^LITERAL */
      else if (bytes[0] == PUSH_LIT_CONSTANT)
	return (3);

      else if (bytes[0] == PUSH_ZERO)
	{
	  _gst_add_forced_object (FROM_INT (0));
	  return (3);
	}
      else if (bytes[0] == PUSH_ONE)
	{
	  _gst_add_forced_object (FROM_INT (1));
	  return (3);
	}
      else
	return (0);

    }

  else if (byteCodeLen == 3)
    {
      if (bytes[2] != RETURN_CONTEXT_STACK_TOP)
	return (0);

      /* check for ^INSTANCE_VARIABLE */
      if (bytes[0] == PUSH_INDEXED
	  && (bytes[1] & LOCATION_MASK) == RECEIVER_LOCATION)
	return (((bytes[1] & ~LOCATION_MASK) << 8) | 2);

      /* check for ^LITERAL */
      else if (bytes[0] == PUSH_SIGNED_8)
	{
	  _gst_add_forced_object (FROM_INT ((signed char) bytes[1]));
	  return (3);
	}

      else if (bytes[0] == PUSH_UNSIGNED_8)
	{
	  _gst_add_forced_object (FROM_INT ((unsigned char) bytes[1]));
	  return (3);
	}
      else
	return (0);
    }

  /* check for ^LITERAL */
  if (byteCodeLen == 1)
    {
      /* check for ^self */
      if (bytes[0] == (RETURN_INDEXED | RECEIVER_INDEX))
        return (1);

      if (bytes[0] == (RETURN_INDEXED | TRUE_INDEX))
	{
	  _gst_add_forced_object (_gst_true_oop);
	  return (3);
	}
      else if (bytes[0] == (RETURN_INDEXED | FALSE_INDEX))
	{
	  _gst_add_forced_object (_gst_false_oop);
	  return (3);
	}
      else if (bytes[0] == (RETURN_INDEXED | NIL_INDEX))
	{
	  _gst_add_forced_object (_gst_nil_oop);
	  return (3);
	}
      else
	return (0);
    }

  return (0);
}

int
_gst_check_kind_of_block (bytecodes bc,
			  OOP * literals)
{
  int status, newStatus;
  gst_uchar *bp, *end;
  OOP blockClosureOOP;

  status = 0;			/* clean block */
  for (bp = bc->base, end = bc->ptr; bp != end;
       bp += BYTECODE_SIZE (*bp))
    {
      switch (*bp)
	{
	case 134:
	  if ((bp[1] & 63) == POP_STORE_INTO_ARRAY)
	    break;

	  /* operation on instance variables - fall through */

	case 0:
	case 1:
	case 2:
	case 3:		/* push instance variable */
	case 4:
	case 5:
	case 6:
	case 7:
	case 8:
	case 9:
	case 10:
	case 11:
	case 12:
	case 13:
	case 14:
	case 15:
	case 96:
	case 97:
	case 98:
	case 99:		/* pop into instance var */
	case 100:
	case 101:
	case 102:
	case 103:
	case 112:
	case 120:
	case 140:		/* push self/return/set top */
	  if (status == 0)
	    status = 1;

	  break;

	case 32:
	case 33:
	case 34:
	case 35:		/* push literal constant */
	case 36:
	case 37:
	case 38:
	case 39:
	case 40:
	case 41:
	case 42:
	case 43:
	case 44:
	case 45:
	case 46:
	case 47:
	case 48:
	case 49:
	case 50:
	case 51:
	case 52:
	case 53:
	case 54:
	case 55:
	case 56:
	case 57:
	case 58:
	case 59:
	case 60:
	case 61:
	case 62:
	case 63:
	  newStatus = check_inner_block (literals[*bp & 31]);
	  if (newStatus > status)
	    {
	      if (newStatus == 31)
		{
		  return (31);
		}
	      status = newStatus;
	    }
	  break;

	case 124:		/* return from method */
	  return (31);

	case 126:		/* big literal operations */
	  if ((bp[1] & LOCATION_MASK) != PUSH_LITERAL)
	    continue;

	  blockClosureOOP =
	    literals[((bp[1] & ~LOCATION_MASK) << 6) | bp[2]];
	  newStatus = check_inner_block (blockClosureOOP);
	  if (newStatus > status)
	    {
	      if (newStatus == 31)
		return (31);

	      status = newStatus;
	    }
	  break;

	case 137:		/* push this context */
	  if (bp[1] != BLOCK_COPY_COLON_SPECIAL)
	    return (31);

	  break;

	case 128:
	case 129:
	case 130:
	case 142:		/* 2-byte stack ops */
	  if ((bp[1] & LOCATION_MASK) == RECEIVER_LOCATION
	      && status == 0)
	    status = 1;

	  else if ((bp[1] & LOCATION_MASK) == LIT_CONST_LOCATION)
	    {
	      newStatus =
		check_inner_block (literals[bp[1] & ~LOCATION_MASK]);
	      if (newStatus > status)
		{
		  if (newStatus == 31)
		    return (31);

		  status = newStatus;
		}
	    }
	  break;

	case 138:		/* outer temp operation */
	  if (status < (1 + bp[2]))
	    {
	      status = 1 + bp[2];
	      if (status > 31)	/* ouch! how deep!! */
		return (31);
	    }
	  break;
	}
    }
  return (status);
}

int
check_inner_block (OOP blockClosureOOP)
{
  int newStatus;
  gst_block_closure blockClosure;
  gst_compiled_block block;

  if (!IS_CLASS (blockClosureOOP, _gst_block_closure_class))
    return (0);

  /* This case is the most complicated -- we must check the cleanness
     of the inner block and adequately change the status. 
     full block: no way dude -- exit immediately
     clean block: same for us 
     receiver access: same for us
     access to temps in the Xth context: from the perspective of the block
     being checked here, it is like an access to temps in the (X-1)th
     context access to this block's temps: our outerContext can be nil
     either, but for safety we won't be a clean block. */
  blockClosure = (gst_block_closure) OOP_TO_OBJ (blockClosureOOP);
  block = (gst_compiled_block) OOP_TO_OBJ (blockClosure->block);
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

  return (ba->byte - bb->byte);
}

bytecodes
_gst_optimize_bytecodes (bytecodes bytecodes)
{
  block_boundary *blocks, *current;
  jump *jumps;
  gst_uchar *bp;
  gst_uchar *end, *first;
  int num;

#ifdef NO_OPTIMIZE
  return (bytecodes);
#endif

  bp = bytecodes->base;
  end = bytecodes->ptr;
  blocks = alloca (sizeof (block_boundary) * (end - bp + 1));
  memset (blocks, 0, sizeof (block_boundary) * (end - bp + 1));

  /* 1) Split into basic blocks.  This part cheats so that the final
     fixup also performs jump optimization. */
  for (current = blocks, num = 0; bp != end; bp += BYTECODE_SIZE (*bp))
    {
      gst_uchar *dest = bp;
      mst_Boolean canOptimizeJump;
      do
	{
	  canOptimizeJump = false;
	  switch (*dest)
	    {
	      /* short jump */
	    case JUMP_SHORT:
	      if (dest[2] == POP_STACK_TOP)
		{
		  /* The bytecodes can only be those produced by
		     #ifTrue:/#ifFalse: 
			     0: jump to 2 
			     1: push nil 
			     2: pop stack top 

		     This could not be optimized to a single
		     pop, cause bytecodes 1 and 2 lie in different
		     basic blocks! So we rewrite it to a functionally
		     equivalent but optimizable bytecode sequence. */
		  *dest = POP_STACK_TOP;
		  break;
		}
	      /* Fall through */

	    case JUMP_SHORT | 1:
	    case JUMP_SHORT | 2:
	    case JUMP_SHORT | 3:
	    case JUMP_SHORT | 4:
	    case JUMP_SHORT | 5:
	    case JUMP_SHORT | 6:
	    case JUMP_SHORT | 7:
	      /* If bp == dest, we could end up writing a 2-byte jump
	         bytecode where space was only reserved for a 1-byte
	         jump bytecode! But if we jump to a return, we can
	         safely optimize -- returns are always one byte */
	      canOptimizeJump = (bp != dest);
	      dest += *dest;
	      dest -= 142;
	      canOptimizeJump |= (*dest >= 120 && *dest <= 125);
	      break;

	      /* pop and short jump if false */
	    case POP_JUMP_FALSE_SHORT:
	    case POP_JUMP_FALSE_SHORT | 1:
	    case POP_JUMP_FALSE_SHORT | 2:
	    case POP_JUMP_FALSE_SHORT | 3:
	    case POP_JUMP_FALSE_SHORT | 4:
	    case POP_JUMP_FALSE_SHORT | 5:
	    case POP_JUMP_FALSE_SHORT | 6:
	    case POP_JUMP_FALSE_SHORT | 7:
	      /* UNCONDITIONAL jumps to CONDITIONAL jumps must not be
	         touched! */
	      if (bp == dest)
		{
		  dest += *dest;
		  dest -= 150;
		}
	      break;

	      /* long jump, pop and long jump if true, pop and long
	         jump if false */
	    case JUMP_LONG:
	    case JUMP_LONG | 1:
	    case JUMP_LONG | 2:
	    case JUMP_LONG | 3:
	    case JUMP_LONG | 4:
	    case JUMP_LONG | 5:
	    case JUMP_LONG | 6:
	    case JUMP_LONG | 7:
	      /* 2-byte unconditional jump, we can indeed optimize it */
	      canOptimizeJump = true;
	      dest += ((signed int) dest[1]) + jump_offsets[*dest & 15];
	      break;

	    case POP_JUMP_TRUE:
	    case POP_JUMP_TRUE | 1:
	    case POP_JUMP_TRUE | 2:
	    case POP_JUMP_TRUE | 3:
	    case POP_JUMP_FALSE:
	    case POP_JUMP_FALSE | 1:
	    case POP_JUMP_FALSE | 2:
	    case POP_JUMP_FALSE | 3:
	      /* UNCONDITIONAL jumps to CONDITIONAL jumps must not be
	         touched! */
	      if (bp == dest)
		dest +=
		  ((signed int) dest[1]) + jump_offsets[*dest & 15];

	      break;

	    case RETURN_INDEXED:
	    case RETURN_INDEXED | 1:
	    case RETURN_INDEXED | 2:
	    case RETURN_INDEXED | 3:
	    case RETURN_METHOD_STACK_TOP:
	    case RETURN_CONTEXT_STACK_TOP:
	      /* Return bytecodes - patch the original jump to return
	         directly */
	      if (*bp >= JUMP_LONG)
		{
		  bp[0] = NOP_BYTECODE;
		  bp[1] = *dest;	/* fill both bytes */
		}
	      else
		*bp = *dest;

	      /* This in fact eliminated the jump, don't split in basic 
	         blocks */
	      dest = bp;
	      break;
	    }
	}
      while (canOptimizeJump);
      if (bp != dest)
	{
	  current->byte = dest - bytecodes->base;
	  current->id = ++num;
	  current++;
	  current->byte = bp - bytecodes->base;
	  current->id = -num;
	  current++;
	}
    }

  /* 2) Get the "real" block boundaries by sorting them according to
     where they happen in the original bytecode.  Note that a simple
     bucket sort is not enough because multiple jumps could end on the
     same bytecode, and the same bytecode could be both the start and
     the destination of a jump! */
  qsort (blocks, current - blocks, sizeof (block_boundary),
	 compare_blocks);

  /* 3) Optimize the single basic blocks, and reorganize into `jumps'
     the data that was put in blocks */
  jumps = alloca (sizeof (jump) * num);

  _gst_alloc_bytecodes ();
  for (bp = bytecodes->base; blocks != current; blocks++)
    {
      first = bp;
      bp = bytecodes->base + blocks->byte;
      optimize_basic_block (first, bp);
      if (blocks->id > 0)
	jumps[blocks->id - 1].dest = _gst_current_bytecode_length ();

      else
	jumps[-blocks->id - 1].from = _gst_current_bytecode_length ();
    }
  optimize_basic_block (bp, end);

  _gst_free_bytecodes (bytecodes);
  bytecodes = _gst_get_bytecodes ();

  /* 4) Fix the jumps so that they correctly point to the start of the
     same basic block */
  for (; num--; jumps++)
    {
      short offset;

      bp = bytecodes->base + jumps->from;
      offset = jumps->dest - jumps->from - 2;
      if (offset == -1)
	{			/* jump to following bytecode do */
	  if (*bp >= JUMP_LONG)	/* NOT exist - use other bytecodes */
	    bp[1] = NOP_BYTECODE;	/* 2 byte jumps = nop+nop or
					   pop+nop */

	  if (*bp & 8)
	    *bp = POP_STACK_TOP;	/* pop stack top for
					   conditionals */
	  else
	    *bp = NOP_BYTECODE;	/* nop for unconditional jumps */

	  continue;
	}
      switch (*bp & ~7)
	{
	  /* short jumps */
	case JUMP_SHORT:
	  *bp = JUMP_SHORT | offset;
	  continue;
	case POP_JUMP_FALSE_SHORT:
	  *bp = POP_JUMP_FALSE_SHORT | offset;
	  continue;

	  /* long jumps */
	case JUMP_LONG:
	  *bp = JUMP_LONG | 4;
	  break;
	case POP_JUMP_TRUE:
	  *bp &= ~3;
	  break;
	}
      *bp++ += offset >> 8;
      *bp = offset & 255;
    }

  return (bytecodes);
}

mst_Boolean
optimize_basic_block (gst_uchar * from,
		      gst_uchar * to)
{
#define NEXT(size) BEGIN_MACRO {	\
  n = size;				\
  opt += size;				\
  continue;				\
} END_MACRO

#define REPLACE(size) BEGIN_MACRO {	\
  n = size;				\
  continue;				\
} END_MACRO

#define COPY BEGIN_MACRO {		\
  n = BYTECODE_SIZE(byte);		\
  opt++;				\
  if(n != 1) *opt++ = *bp++;		\
  if(n == 3) *opt++ = *bp++;		\
  continue;				\
} END_MACRO

#define BEGIN	     if(0) {
#define BYTECODE(n)  } else if(byte == (n)) {
#define RANGE(a, b)  } else if((unsigned char)(byte - (a)) <= ((b) - (a))) {
#define EITHER(a, b) } else if(byte == (a) b) {
#define OR(b)  		       || byte == (b)
#define CONDITION(c) } else if(c) {
#define NO_MATCH     } else {
#define END	     }


  gst_uchar byte, *bp, *opt;
  int n;

  bp = opt = from;
  n = 0;
  while (bp != to)
    {
      byte = *opt = *bp++;
      BEGIN
	RANGE (RETURN_INDEXED, RETURN_CONTEXT_STACK_TOP) 
	  opt++;
          break;		/* this `break' performs unreachable
				   code elimination! */

	BYTECODE (NOP_BYTECODE) 
	  REPLACE (n);

        BYTECODE (NOT_EQUAL_SPECIAL) 
	  if (!n)
	    NEXT (1);
	  if (opt[-n] == (PUSH_SPECIAL | NIL_INDEX))
	    {			/* x ~= nil */
	      opt[-n] = NOT_NIL_SPECIAL;
	      REPLACE (1);
	    }
	  NEXT (1);

	EITHER (SAME_OBJECT_SPECIAL, OR (EQUAL_SPECIAL)) 
	  if (!n)
	    NEXT (1);
	  if (opt[-n] == (PUSH_SPECIAL | NIL_INDEX))
	    {			/* x = nil, x == nil */
	      opt[-n] = IS_NIL_SPECIAL;
	      REPLACE (1);
	    }
	  NEXT (1);

        BYTECODE (POP_STACK_TOP) 
	  if (n)
	    {
	      byte = opt[-n];
	      BEGIN 
		CONDITION (IS_PUSH_BYTECODE (byte))	/* push/pop */
		  opt -= n;
	          NEXT (0);

		BYTECODE (STORE_INDEXED)	/* store/pop */
		  byte = *--opt;	/* get data byte */
		  opt--;		/* move to opcode */
		  if (byte < 8)
		    {
		      *opt = POP_RECEIVER_VARIABLE | byte;
		      NEXT (1);
		    }
		  else if (byte >= 64 && byte < 72)
		    {
		      *opt = POP_TEMPORARY_VARIABLE | (byte & 63);
		      NEXT (1);
		    }
		  else
		    {
		      *opt = POP_STORE_INDEXED;
		      NEXT (2);
		    }
		  
		EITHER (BIG_LITERALS_BYTECODE, 
			OR (BIG_INSTANCE_BYTECODE) 
			OR (OUTER_TEMP_BYTECODE))

		  byte = opt[-2];	/* get second byte */
		  if (byte < POP_STORE_VARIABLE)
		    {
		      opt -= n;		/* push/pop */
		      NEXT (0);
		    }
		  else if (byte >= STORE_VARIABLE)
		    {
		      opt[-2] ^= (POP_STORE_VARIABLE ^ STORE_VARIABLE);
		      REPLACE (3);
		    }
	      END;
	    }

	  if (bp != to && (*bp & ~3) == RETURN_INDEXED)
	    {
	      *opt++ = *bp++;	/* pop/return */
	      break;		/* kill unreachable code */
	    }
	  NEXT (1);

	CONDITION (IS_PUSH_BYTECODE (byte))	/* push/push -> dup */
	  if (!n)
	    COPY;
	  if (opt[-n] == *opt)
	    {
	      if (n == 1)
		{
		  *opt = DUP_STACK_TOP;
		  NEXT (1);
		}
	      else if (opt[-1] == *bp)
		{
		  *opt = DUP_STACK_TOP;
		  bp++;
		  NEXT (1);
		}
	    }

	  BEGIN			/* pop-store/push -> store */
	    RANGE (PUSH_RECEIVER_VARIABLE, PUSH_RECEIVER_VARIABLE | 7)
	      if (opt[-n] == (POP_RECEIVER_VARIABLE | (byte & 15)))
		{
		  opt[-1] = STORE_INDEXED;
		  *opt++ = RECEIVER_LOCATION | (byte & 15);
		  REPLACE (2);
		}
	      if (opt[-n] == POP_STACK_TOP)
	        {			/* pop/push -> replace */
		  opt--;
		  *opt++ = REPLACE_INDEXED;
		  *opt++ = RECEIVER_LOCATION | (byte & 15);
		  REPLACE (2);
		}

	    RANGE (PUSH_RECEIVER_VARIABLE | 8, PUSH_RECEIVER_VARIABLE | 15)
	      if (opt[-n] == POP_STORE_INDEXED
		  && opt[-1] == (RECEIVER_LOCATION | (byte & 15)))
		{
		  opt[-2] = STORE_INDEXED;
		  REPLACE (2);
		}
	      if (opt[-n] == POP_STACK_TOP)
		{
		  opt--;
		  *opt++ = REPLACE_INDEXED;
		  *opt++ = RECEIVER_LOCATION | (byte & 15);
		  REPLACE (2);
		}

	    RANGE (PUSH_TEMPORARY_VARIABLE, PUSH_TEMPORARY_VARIABLE | 7)
	      if (opt[-n] == (POP_TEMPORARY_VARIABLE | (byte & 15)))
		{
		  opt[-1] = STORE_INDEXED;
		  *opt++ = TEMPORARY_LOCATION | (byte & 15);
		  REPLACE (2);
		}
	      if (opt[-n] == POP_STACK_TOP)
		{
		  opt--;
		  *opt++ = REPLACE_INDEXED;
		  *opt++ = TEMPORARY_LOCATION | (byte & 15);
		  REPLACE (2);
		}

	    RANGE (PUSH_TEMPORARY_VARIABLE | 8, PUSH_TEMPORARY_VARIABLE | 15)
	      if (opt[-n] == POP_STORE_INDEXED
		  && opt[-1] == (TEMPORARY_LOCATION | (byte & 15)))
		{
		  opt[-2] = STORE_INDEXED;
		  REPLACE (2);
		}
	      if (opt[-n] == POP_STACK_TOP)
	        {
		  opt--;
		  *opt++ = REPLACE_INDEXED;
		  *opt++ = TEMPORARY_LOCATION | (byte & 15);
		  REPLACE (2);
		}

	    RANGE (PUSH_LIT_VARIABLE, PUSH_LIT_VARIABLE | 31)
	      if (opt[-n] == POP_STORE_INDEXED
		  && opt[-1] == (LIT_VAR_LOCATION | (byte & 31)))
		{
		  opt[-2] = STORE_INDEXED;
		  REPLACE (2);
		}
	      if (opt[-n] == POP_STACK_TOP)
		{
		  opt--;
		  *opt++ = REPLACE_INDEXED;
		  *opt++ = LIT_VAR_LOCATION | (byte & 31);
		  REPLACE (2);
		}

	    RANGE (PUSH_LIT_CONSTANT, PUSH_LIT_CONSTANT | 31)
	      if (opt[-n] == POP_STACK_TOP)
		{
		  opt--;
		  *opt++ = REPLACE_INDEXED;
		  *opt++ = LIT_CONST_LOCATION | (byte & 31);
		  REPLACE (2);
		}

	    BYTECODE (PUSH_SPECIAL | RECEIVER_INDEX)
	      if (opt[-n] == POP_STACK_TOP)
		{
		  opt[-1] = REPLACE_SELF;
		  REPLACE (1);
		}

	    BYTECODE (PUSH_ONE)
	      if (opt[-n] == POP_STACK_TOP)
		{
		  opt[-1] = REPLACE_ONE;
		  REPLACE (1);
		}

	    BYTECODE (PUSH_INDEXED)
	      byte = *bp++;
	      if (opt[-n] == POP_STORE_INDEXED)
		{
		  opt[-2] = STORE_INDEXED;
		  if (opt[-1] == byte)
		    REPLACE (2);
		  else
		    *opt = REPLACE_INDEXED;
		}
	      else if (opt[-n] == POP_STACK_TOP)
		*--opt = REPLACE_INDEXED;

	      opt[1] = byte;
	      NEXT (2);

	  END;
	  COPY;

        BYTECODE (BIG_INSTANCE_BYTECODE) 
	  if (!n || opt[-n] != byte)
	    COPY;

          byte = opt[-2];		/* get second byte */
	  if (byte < PUSH_VARIABLE)
	    ;	  /* do nothing */
	  else if (byte < POP_STORE_VARIABLE)
	    {
	      if (byte == *bp && opt[-1] == bp[1])
		{			/* push/push -> dup */
		  *opt = DUP_STACK_TOP;
		  bp += 2;
		  NEXT (1);
		}
	    }
	  else if (byte < STORE_VARIABLE)
	    {			/* pop-store/push -> store */
	      if ((byte & 63) == (*bp & 63) && opt[-1] == bp[1])
		{
		  opt[-2] ^= (POP_STORE_VARIABLE ^ STORE_VARIABLE);
		  bp += 2;
		  REPLACE (3);
		}
	    }
	  
	  opt++;
	  *opt++ = *bp++;
	  *opt++ = *bp++;
	  REPLACE (3);

        EITHER (BIG_LITERALS_BYTECODE,
	        OR (OUTER_TEMP_BYTECODE)) 
	  if (!n || opt[-n] != byte)
	    COPY;

          byte = opt[-2];		/* get second byte */
	  if (byte < POP_STORE_VARIABLE)
	    {
	      if (byte == *bp && opt[-1] == bp[1])
		{			/* push/push -> dup */
		  *opt = DUP_STACK_TOP;
		  bp += 2;
		  NEXT (1);
		}
	    }
	  else if (byte < STORE_VARIABLE)
	    {			/* pop-store/push -> store */
	      if ((byte & 63) == (*bp & 63) && opt[-1] == bp[1])
		{
		  opt[-2] ^= (POP_STORE_VARIABLE ^ STORE_VARIABLE);
		  bp += 2;
		  REPLACE (3);
		}
	    }
	  
	  opt++;
	  *opt++ = *bp++;
	  *opt++ = *bp++;
	  REPLACE (3);

	NO_MATCH
	  COPY;
      END;
    }

  _gst_compile_bytecodes (from, opt);
  return (opt != from);
}


void
_gst_compute_stack_positions (gst_uchar * bp,
			      int size,
			      PTR * base,
			      PTR ** pos)
{
  gst_uchar *end;
  int balance, ofs;
  static const int stackOpBalanceTable[16] = {
    1, 1, -1, 0,		/* 126 (push, push, pop/store, store) */
    0, 0, 0, 0,			/* unused */
    -1, 1, -1, 0,		/* 134 (pop/store, push, pop/store,
				   store) */
    255, 1, -1, 0,		/* 138 (invalid, push, pop/store,
				   store) */
  };

  memzero (pos, sizeof (PTR *) * (1 + size));

  pos[0] = base;
  for (end = bp + size; bp != end;
       pos += BYTECODE_SIZE (*bp), bp += BYTECODE_SIZE (*bp))
    {

      switch (*bp)
	{
	  /* 3-byte stack operations */
	case BIG_LITERALS_BYTECODE:
	case BIG_INSTANCE_BYTECODE:
	case OUTER_TEMP_BYTECODE:
	  balance = stackOpBalanceTable[(*bp - 126) | (bp[1] >> 6)];
	  break;

	  /* 1-byte sends */
	case SEND1EXT_BYTE:
	case SEND_SUPER1EXT_BYTE:
	  balance = -(bp[1] >> 5);
	  break;

	  /* 2-byte send */
	case SEND2EXT_BYTE:
	  balance = -(bp[1] & 31);
	  break;

	  /* Everything else */
	default:
	  balance = stack_balance_table[*bp];
	  if (*bp >= JUMP_SHORT)
	    {
	      if (*bp < JUMP_LONG)
		{
		  /* short jumps */
		  ofs = (*bp & 7) + 2;
		  pos[ofs] = pos[0] + balance;
		}
	      else if (*bp < PLUS_SPECIAL)
		{
		  /* long jumps */
		  ofs = ((signed int) bp[1]) + jump_offsets[*bp & 15];
		  if (ofs > 0)
		    pos[ofs] = pos[0] + balance;
		}
	    }
	}

      if (balance == 255)
	{
	  _gst_errorf
	    ("Invalid bytecode encountered during bytecode analysis");
	  balance = 0;
	}

      if (!pos[BYTECODE_SIZE (*bp)])
	pos[BYTECODE_SIZE (*bp)] = pos[0] + balance;
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
  gst_uchar *end;
  int n;

  memzero (dest, sizeof (char) * size);

  for (n = 0, end = bp + size; bp != end;
       dest += BYTECODE_SIZE (*bp), bp += BYTECODE_SIZE (*bp))
    {

      if (*bp >= JUMP_SHORT)
	{
	  if (*bp < JUMP_LONG)
	    {
	      /* short jumps */
	      dest[(*bp & 7) + 2] = 1;
	      n++;
	    }
	  else if (*bp < PLUS_SPECIAL)
	    {
	      int ofs;
	      ofs = ((signed int) bp[1]) + jump_offsets[*bp & 15];
	      /* long jumps */
	      dest[ofs] = (ofs <= 0) ? -1 : 1;
	      n++;
	    }
	}
    }

  return (n);
}
