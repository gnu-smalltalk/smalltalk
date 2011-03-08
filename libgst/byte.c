/******************************** -*- C -*- ****************************
 *
 *	Byte code array utility routines.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006,2008,2009
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/

#include "gstpriv.h"
#include "match.h"

#define BYTECODE_CHUNK_SIZE  64

/* Where the compiled bytecodes go.  */
bc_vector _gst_cur_bytecodes;

/* Reallocate an array of bytecodes, leaving space for DELTA more
   bytes.  */
static void realloc_bytecodes (bc_vector bytecodes,
			       int delta);




bc_vector
_gst_extract_bytecodes (OOP byteArrayOOP)
{
  bc_vector result;
  int len;
  gst_byte_array byteArray;

  byteArray = (gst_byte_array) OOP_TO_OBJ (byteArrayOOP);
  len = oop_num_fields (byteArrayOOP);
  result = (bc_vector) xmalloc (sizeof (struct bytecode_array));

  result->base = (gst_uchar *) xmalloc (len);
  result->ptr = result->base + len;
  result->maxLen = len;
  memcpy (result->base, byteArray->bytes, len);
  return (result);
}

static int next_line_number;

static void
compile_byte (gst_uchar byte, int arg)
{
  int num_bytes;
  long n;

  for (num_bytes = 2, n = arg; n > 255; n >>= 8)
    num_bytes += 2;

  assert (_gst_cur_bytecodes);

  if ((_gst_cur_bytecodes->ptr - _gst_cur_bytecodes->base) >
	   _gst_cur_bytecodes->maxLen - num_bytes)

    realloc_bytecodes (_gst_cur_bytecodes, BYTECODE_CHUNK_SIZE);


  while (num_bytes > 2)
    {
      num_bytes -= 2;
      *_gst_cur_bytecodes->ptr++ = EXT_BYTE;
      *_gst_cur_bytecodes->ptr++ = (arg >> (num_bytes * 4)) & 255;
    }

  *_gst_cur_bytecodes->ptr++ = byte;
  *_gst_cur_bytecodes->ptr++ = arg & 255;
}

void
_gst_line_number (int n, int flags)
{
  if (n > 65535)
    n = 65535;

  if (flags & LN_RESET)
    {
      assert (!(flags & LN_FORCE));
      assert (n > 0);
      if (flags & LN_ABSOLUTE)
	{
	  compile_byte (LINE_NUMBER_BYTECODE, n);
	  _gst_compiler_state->prev_line = n;
	}
      _gst_compiler_state->line_offset = n - 1;
      next_line_number = -1;
    }
  else
    {
      assert (!(flags & LN_ABSOLUTE));
      if (n == -1)
	{
	  _gst_compiler_state->prev_line = -1;
	  next_line_number = -1;
	}
      else
	{
	  assert (n > _gst_compiler_state->line_offset);
	  if ((flags & LN_FORCE) || n != _gst_compiler_state->prev_line)
	    {
	      _gst_compiler_state->prev_line = n;
	      next_line_number = n - _gst_compiler_state->line_offset;
	    }
	}
    }
}

void
_gst_compile_byte (gst_uchar byte, int arg)
{
  if (next_line_number != -1)
    {
      compile_byte (LINE_NUMBER_BYTECODE, next_line_number);
      next_line_number = -1;
    }

  compile_byte (byte, arg);
}

void
_gst_free_bytecodes (bc_vector bytecodes)
{
  if (bytecodes != NULL)
    {
      xfree (bytecodes->base);
      xfree (bytecodes);
    }
}

void
_gst_compile_and_free_bytecodes (bc_vector bytecodes)
{
  _gst_compile_bytecodes (bytecodes->base, bytecodes->ptr);

  /* First add the worst case, then leave the net effect.  */
  ADD_STACK_DEPTH (bytecodes->max_stack_depth);
  SUB_STACK_DEPTH (bytecodes->max_stack_depth - bytecodes->stack_depth);

  _gst_free_bytecodes (bytecodes);
}

bc_vector
_gst_get_bytecodes (void)
{
  bc_vector curBytecodes;

  curBytecodes = _gst_cur_bytecodes;
  _gst_cur_bytecodes = NULL;

  return (curBytecodes);
}


bc_vector
_gst_save_bytecode_array ()
{
  bc_vector curBytecodes;

  curBytecodes = _gst_cur_bytecodes;
  _gst_alloc_bytecodes ();

  return (curBytecodes);
}


void
_gst_restore_bytecode_array (bc_vector bytecodes)
{
  _gst_cur_bytecodes = bytecodes;
}

int
_gst_bytecode_length (bc_vector bytecodes)
{
  if (bytecodes == NULL)
    return (0);

  return (bytecodes->ptr - bytecodes->base);
}


int
_gst_current_bytecode_length (void)
{
  if (_gst_cur_bytecodes == NULL)
    return (0);

  return (_gst_cur_bytecodes->ptr - _gst_cur_bytecodes->base);
}

void
_gst_copy_bytecodes (gst_uchar * dest,
		     bc_vector bytecodes)
{
  memcpy (dest, bytecodes->base, _gst_bytecode_length (bytecodes));
}

void
_gst_truncate_bytecodes (gst_uchar * here,
			 bc_vector bytecodes)
{
  bytecodes->ptr = here;
}



void
_gst_print_bytecodes (bc_vector bytecodes,
		      OOP * literal_vec)
{
  gst_uchar *b;
  int ip;

  if (bytecodes == NULL)
    return;

  for (b = bytecodes->base; b < bytecodes->ptr; )
    {
      ip = b - bytecodes->base;
      printf ("%5d:", ip);
      b = _gst_print_bytecode_name (b, ip, literal_vec, "");
    }
  printf ("\n");
}

gst_uchar *
_gst_print_bytecode_name (gst_uchar * bp,
			  int ip,
			  OOP * literal_vec,
			  const char *pref)
{
  const char *prefix = "";
  gst_uchar b = *bp;

  MATCH_BYTECODES (PRINT_BYTECODE_NAME, bp, (
    PUSH_RECEIVER_VARIABLE {
      printf ("%s\tpush Instance Variable[%d]\n", prefix, n);
      prefix = pref;
    }

    PUSH_TEMPORARY_VARIABLE {
      printf ("%s\tpush Temporary Variable[%d]\n", prefix, n);
      prefix = pref;
    }

    PUSH_LIT_CONSTANT {
      printf ("%s\tpush Literal[%d]", prefix, n);
      if (literal_vec)
	printf (" = %O", literal_vec[n]);
      printf ("\n");
      prefix = pref;
    }

    PUSH_LIT_VARIABLE {
      printf ("%s\tpush Global Variable[%d]", prefix, n);
      if (literal_vec)
	printf (" = %+O", literal_vec[n]);
      printf ("\n");
      prefix = pref;
    }

    PUSH_SELF {
      printf ("%s\tpush self\n", prefix);
      prefix = pref;
    }
    PUSH_SPECIAL {
      switch (n) {
	case TRUE_INDEX: printf ("%s\tpush true\n", prefix); break;
	case FALSE_INDEX: printf ("%s\tpush false\n", prefix); break;
	case NIL_INDEX: printf ("%s\tpush nil\n", prefix); break;
      }
      prefix = pref;
    }
    PUSH_INTEGER {
      printf ("%s\tpush %d\n", prefix, n);
      prefix = pref;
    }

    RETURN_METHOD_STACK_TOP {
      printf ("%s\treturn explicitly from method\n", prefix);
      prefix = pref;
    }
    RETURN_CONTEXT_STACK_TOP {
      printf ("%s\treturn stack top\n", prefix);
      prefix = pref;
    }

    LINE_NUMBER_BYTECODE {
      printf ("%s\tsource line %d\n", prefix, n);
      prefix = pref;
    }

    STORE_RECEIVER_VARIABLE {
      printf ("%s\tstore into Instance Variable[%d]\n", prefix, n);
      prefix = pref;
    }
    STORE_TEMPORARY_VARIABLE {
      printf ("%s\tstore into Temporary Variable[%d]\n", prefix, n);
      prefix = pref;
    }
    STORE_LIT_VARIABLE {
      printf ("%s\tstore into Global Variable[%d]", prefix, n);
      if (literal_vec)
	printf (" = %+O", literal_vec[n]);
      printf ("\n");
      prefix = pref;
    }

    SEND {
      printf ("%s\tsend selector %d%s, %d args", prefix, n, super ? " to super" : "", num_args);
      if (literal_vec)
	printf (" = %O", literal_vec[n]);
      printf ("\n");
      prefix = pref;
    }

    POP_INTO_NEW_STACKTOP {
      printf ("%s\tpop and store into Instance Variable[%d] of new stack top\n", prefix, n);
      prefix = pref;
    }

    POP_STACK_TOP {
      printf ("%s\tpop stack top\n", prefix);
      prefix = pref;
    }
    DUP_STACK_TOP {
      printf ("%s\tduplicate stack top\n", prefix);
      prefix = pref;
    }

    PUSH_OUTER_TEMP {
      printf ("%s\tpush outer var scopes = %d varIndex = %d\n", prefix, scopes, n);
      prefix = pref;
    }
    STORE_OUTER_TEMP {
      printf ("%s\tstore outer var scopes = %d varIndex = %d\n", prefix, scopes, n);
      prefix = pref;
    }

    EXIT_INTERPRETER {
      printf ("%s\tterminate interpreter\n", prefix);
      prefix = pref;
    }

    JUMP {
      printf ("%s\tjump to %d\n", prefix, ip + ofs);
      prefix = pref;
    }
    POP_JUMP_TRUE {
      printf ("%s\tpop and jump to %d if true\n", prefix, ip + ofs);
      prefix = pref;
    }
    POP_JUMP_FALSE {
      printf ("%s\tpop and jump to %d if false\n", prefix, ip + ofs);
      prefix = pref;
    }

    SEND_ARITH {
      printf ("%s\tsend arithmetic message %O\n", prefix,
	      _gst_builtin_selectors[n].symbol);
      prefix = pref;
    }
    SEND_SPECIAL {
      printf ("%s\tsend special message %O\n", prefix,
	      _gst_builtin_selectors[n + 16].symbol);
      prefix = pref;
    }

    MAKE_DIRTY_BLOCK {
      printf ("%s\tmake dirty block\n", prefix);
      prefix = pref;
    }

    SEND_IMMEDIATE {
      printf ("%s\tsend special message %O%s\n", prefix,
	      _gst_builtin_selectors[n].symbol,
	      super ? " to super" : "");
      prefix = pref;
    }

    INVALID {
      printf ("%s\tINVALID BYTECODE %d(%d)\n", prefix, b, arg);
      prefix = pref;
    }
  ));
  return bp;
}

void
_gst_compile_bytecodes (gst_uchar * from,
			gst_uchar * to)
{
  int free;
  assert (_gst_cur_bytecodes);

  free = _gst_cur_bytecodes->maxLen -
    (_gst_cur_bytecodes->ptr - _gst_cur_bytecodes->base);

  if (free < (to - from))
    {
      memcpy (_gst_cur_bytecodes->ptr, from, free);
      _gst_cur_bytecodes->ptr += free;
      from += free;
      realloc_bytecodes (_gst_cur_bytecodes,
		         BYTECODE_CHUNK_SIZE + (to - from));
    }

  memcpy (_gst_cur_bytecodes->ptr, from, to - from);
  _gst_cur_bytecodes->ptr += to - from;
}

void
_gst_alloc_bytecodes ()
{
  bc_vector newBytecodes;

  newBytecodes = (bc_vector) xmalloc (sizeof (struct bytecode_array));
  newBytecodes->base = (gst_uchar *) xmalloc (BYTECODE_CHUNK_SIZE);
  newBytecodes->ptr = newBytecodes->base;
  newBytecodes->maxLen = BYTECODE_CHUNK_SIZE;

  newBytecodes->stack_depth = 0;
  newBytecodes->max_stack_depth = 0;

  _gst_cur_bytecodes = newBytecodes;
}

void
realloc_bytecodes (bc_vector bytecodes,
		   int delta)
{
  int size;

  size = bytecodes->ptr - bytecodes->base;

  bytecodes->base =
    (gst_uchar *) xrealloc (bytecodes->base, bytecodes->maxLen + delta);
  bytecodes->ptr = bytecodes->base + size;
  bytecodes->maxLen += delta;
}
