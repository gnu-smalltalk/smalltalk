/******************************** -*- C -*- ****************************
 *
 *	Declarations for the byte code compiler.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007,2008
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


#ifndef GST_COMP_H
#define GST_COMP_H

/* These next three defines are the number of bits in a method header for
   the number of stack bits, the number of _gst_temporaries, and the number of
   arguments that the method takes.  If the representation is changed, these
   definitions need to be altered too */
#define DEPTH_SCALE		2
#define MAX_DEPTH		(((1 << MTH_DEPTH_BITS) - 1) << DEPTH_SCALE)
#define MAX_NUM_TEMPS		((1 << MTH_TEMPS_BITS) - 1)
#define MAX_NUM_ARGS		((1 << MTH_ARGS_BITS) - 1)
#define NUM_PRIMITIVES		(1 << MTH_PRIM_BITS)

/*
 * This is the organization of a method header.  The 1 bit in the high end of
 * the word indicates that this is an integer, so that the GC won't be tempted
 * to try to scan the contents of this field, and so we can do bitwise operations
 * on this value to extract component pieces.
 * 
 *    3                   2                   1 
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |.|flags| prim index        | #temps    |   depth   | #args   |1|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * 
 * flags (30-28)
 *   flags 0 -- nothing
 *   flags 1 -- return _gst_self
 *   flags 2 -- return instance variable (# in primitive index)
 *   flags 3 -- return literal
 *   flags 4 -- primitive index
 */

#define MTH_DEPTH_BITS		6
#define MTH_TEMPS_BITS		6
#define MTH_ARGS_BITS		5
#define MTH_PRIM_BITS		9
#define MTH_FLAG_BITS		3

#define MTH_NORMAL		0
#define MTH_RETURN_SELF		1
#define MTH_RETURN_INSTVAR	2
#define MTH_RETURN_LITERAL	3
#define MTH_PRIMITIVE		4
#define MTH_ANNOTATED		5
#define MTH_USER_DEFINED	6
#define MTH_UNUSED		7

typedef struct method_header
{
#ifdef WORDS_BIGENDIAN
#if SIZEOF_OOP == 8
  unsigned :32;		/* unused */
#endif
  unsigned :1;			/* sign - must be 0 */
  unsigned headerFlag:MTH_FLAG_BITS;	/* prim _gst_self, etc.  */
  unsigned isOldSyntax:1;
  unsigned primitiveIndex:MTH_PRIM_BITS;	/* index of primitive, or 0 */
  unsigned numTemps:MTH_TEMPS_BITS;
  unsigned stack_depth:MTH_DEPTH_BITS;
  unsigned numArgs:MTH_ARGS_BITS;
  unsigned intMark:1;		/* flag this as an Int */
#else
  unsigned intMark:1;		/* flag this as an Int */
  unsigned numArgs:MTH_ARGS_BITS;
  unsigned stack_depth:MTH_DEPTH_BITS;
  unsigned numTemps:MTH_TEMPS_BITS;
  unsigned primitiveIndex:MTH_PRIM_BITS;	/* index of primitve,
						   or 0 */
  unsigned isOldSyntax:1;
  unsigned headerFlag:MTH_FLAG_BITS;	/* prim _gst_self, etc.  */
  unsigned :1;			/* sign - must be 0 */
#if SIZEOF_OOP == 8
  unsigned :32;		/* unused */
#endif
#endif				/* WORDS_BIGENDIAN */
}
method_header;

typedef struct gst_compiled_method
{
  OBJ_HEADER;
  OOP literals;
  method_header header;
  OOP descriptor;
  gst_uchar bytecodes[1];
}
 *gst_compiled_method;

typedef struct gst_method_info
{
  OBJ_HEADER;
  OOP sourceCode;
  OOP category;
  OOP class;
  OOP selector;
  OOP attributes[1];
}
 *gst_method_info;


/*
 * These definition parallel the above ones, but they are for blocks. Here is
 * the organization of a block header.
 * 
 *    3                   2                   1 
 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * |.|  #args  | #temps  |   depth   |      unused     | clean   |1|
 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 * 
 */

#define BLK_DEPTH_BITS		6
#define BLK_TEMPS_BITS		5
#define BLK_ARGS_BITS		5
#define BLK_CLEAN_BITS		5
#define BLK_UNUSED_BITS		9

typedef struct block_header
{
#ifdef WORDS_BIGENDIAN
#if SIZEOF_OOP == 8
  unsigned :32;		/* unused */
#endif
  unsigned :1;			/* sign - must be 0 */
  unsigned numArgs:BLK_ARGS_BITS;	/* number of arguments we have */
  unsigned numTemps:BLK_TEMPS_BITS;	/* number of _gst_temporaries
					   we have */
  unsigned depth:BLK_DEPTH_BITS;	/* number of stack slots needed 
					 */
  unsigned :BLK_UNUSED_BITS;
  unsigned clean:BLK_CLEAN_BITS;	/* behavior of block */
  unsigned intMark:1;		/* flag this as an Int */
#else
  unsigned intMark:1;		/* flag this as an Int */
  unsigned clean:BLK_CLEAN_BITS;	/* behavior of block */
  unsigned :BLK_UNUSED_BITS;
  unsigned depth:BLK_DEPTH_BITS;	/* number of stack slots needed 
					 */
  unsigned numTemps:BLK_TEMPS_BITS;	/* number of _gst_temporaries
					   we have */
  unsigned numArgs:BLK_ARGS_BITS;	/* number of arguments we have */
  unsigned :1;			/* sign - must be 0 */
#if SIZEOF_OOP == 8
  unsigned :32;		/* unused */
#endif
#endif
}
block_header;

typedef struct gst_compiled_block
{
  OBJ_HEADER;
  OOP literals;
  block_header header;
  OOP method;
  gst_uchar bytecodes[1];
}
 *gst_compiled_block;

typedef struct gst_block_closure
{
  OBJ_HEADER;
  OOP outerContext;		/* the parent gst_block_context or
				   gst_method_context */
  OOP block;			/* the gst_compiled_block */
  OOP receiver;			/* the receiver in which the closure
				   lives */
}
 *gst_block_closure;

typedef struct compiler_state
{
  int line_offset;
  int prev_line;
  scope cur_scope;
  mst_Boolean inside_block;
  mst_Boolean undeclared_temporaries;
  OOP *literal_vec;
  OOP *literal_vec_curr;
  OOP *literal_vec_max;
  jmp_buf bad_method;
} compiler_state;


/* This holds the parse tree for the method being compiled.  */
extern tree_node _gst_curr_method ATTRIBUTE_HIDDEN;

/* This holds other bits of compiler state that needs to be saved
   when the compiler is reentered.  */
extern compiler_state *_gst_compiler_state ATTRIBUTE_HIDDEN;

/* This is the value most recently returned by
   _gst_execute_statements.  It is used to communicate the returned
   value past a _gst_parse_stream call, without pushing something on
   the called context stack in the case of nested invocations of
   _gst_prepare_execution_environment/_gst_finish_execution_environment.
   Most often, the caller does not care about the returned value,
   since it often is called from a radically different context.  */
extern OOP _gst_last_returned_value 
  ATTRIBUTE_HIDDEN;

/* This flag controls whether byte codes are printed after
   compilation.  If > 1, it applies also to code not invoked by
   the user.  */
extern int _gst_declare_tracing 
  ATTRIBUTE_HIDDEN;

/* If true, the compilation of a set of methods will be skipped
   completely; only syntax will be checked.  Set by primitive, cleared
   by grammar.  */
extern mst_Boolean _gst_skip_compilation 
  ATTRIBUTE_HIDDEN;

/* Given a tree_node of type TREE_KEYWORD_LIST, pick out and concatenate
   the keywords, turn them into a symbol OOP and return that symbol.  */
extern OOP _gst_compute_keyword_selector (tree_node selectorExpr)
  ATTRIBUTE_HIDDEN;

/* Given CONSTEXPR, a section of the syntax tree that represents a
   Smalltalk constant, this routine creates and returns an OOP to be
   stored as a method literal in the method that's currently being
   compiled.  */ 
extern OOP _gst_make_constant_oop (tree_node constExpr);

/* Called to compile and execute an "immediate expression"; i.e. a Smalltalk
   statement that is not part of a method definition.  The parse trees are in
   METHOD.  Return the object that was returned by the expression.  */
extern OOP _gst_execute_statements (OOP receiverOOP,
				    tree_node method,
				    mst_Boolean undeclaredTemps,
				    mst_Boolean quiet)
  ATTRIBUTE_HIDDEN;

/* This routine does a very interesting thing.  It installs the inital
   method, which is the primitive for "methodsFor:".  It does this by
   creating a string that contains the method definition and then
   passing this to the parser as an expression to be parsed and
   compiled.  Once this has been installed, we can go ahead and begin
   loading the rest of the Smalltalk method definitions, but until the
   "methodsFor:" method is defined, we cannot begin to deal with

  	!Object methodsFor: 'primitives'!
  
   In addition, we also define the special
   UndefinedObject>>#__terminate method here, because bytecode 143
   cannot be compiled by parsing Smalltalk code.  */
extern void _gst_install_initial_methods (void) 
  ATTRIBUTE_HIDDEN;

/* Clears the compiler's notion of the class and category to compile
   methods into.  */
extern void reset_compilation_category () 
  ATTRIBUTE_HIDDEN;

/* This function will send a message to ObjectMemory (a system
   class) asking it to broadcast the event named HOOK.  */
extern void _gst_invoke_hook (enum gst_vm_hook hook) 
  ATTRIBUTE_HIDDEN;

/* Compile the code for a complete method definition.  This basically
   walks the METHOD parse tree, but in addition it special cases for
   methods that don't return a value explicitly by returning "self".
   Also creates the CompiledMethod object and, if INSTALL is true,
   installs it in the current method dictionary with the selector
   derived from the method expression.  */
extern OOP _gst_compile_method (tree_node method,
				mst_Boolean returnLast,
				mst_Boolean install,
                                mst_Boolean undeclaredTemps) 
  ATTRIBUTE_HIDDEN;

/* Constructs and returns a new CompiledMethod instance.  It computes
   the method header based on its arguments, and on the contents of
   the method's byte codes (setting up the flags to optimize returns).
   LITERALS is a Smalltalk Array containing the literals, or nil if we
   retrieve it from the array internal to comp.c */
extern OOP _gst_make_new_method (int numArgs,
				 int numTemps,
				 int maximumStackDepth,
				 OOP attributes,
				 OOP literals,
				 bc_vector bytecodes,
				 OOP class,
				 OOP selector,
				 OOP defaultCategoryOOP,
				 int64_t startPos,
				 int64_t endPos) 
  ATTRIBUTE_HIDDEN;

/* This function looks for the UndefinedObject>>#__terminate method
   (if it is not cached already) and answers it.  This method is
   executed by contexts created with
   _gst_prepare_execution_environment.  */
extern OOP _gst_get_termination_method (void)
  ATTRIBUTE_PURE 
  ATTRIBUTE_HIDDEN;

/* Creates and returns a CompiledBlock.  The object is not completely
   filled in, as we only know the method literals and enclosing method
   when we create the outer CompiledMethod; the header is however
   filled, analyzing the BYTECODES to check the block's cleanness.  */
extern OOP _gst_block_new (int numArgs,
		  int numTemps,
		  bc_vector bytecodes,
		  int depth,
		  OOP * literals) 
  ATTRIBUTE_HIDDEN;

/* Adds OOP to the literal vector that's being created, unless it's
   already there.  "Already there" is defined as the exact same object
   is present in the literal vector.  The answer is the index into the
   literal vector where the object was stored.  */
extern int _gst_add_forced_object (OOP oop) 
  ATTRIBUTE_HIDDEN;

#endif /* GST_COMP_H */
