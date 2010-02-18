/******************************** -*- C -*- ****************************
 *
 *	Byte code compiler.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006,2007,2008,2009
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

#include "gstpriv.h"

/* To do: extract the iterative solving of the loop jumps' size.  */

/* Define this if you want declaration tracing to print the bytecodes
   both *before* and *after* the optimizer is ran.  Default behavior
   is to print the bytecodes only after the optimization pass; usually
   it is only needed to debug the optimizer -- when debugging the
   compiler you should turn off optimization entirely (see NO_OPTIMIZE
   in opt.c).  */
/* #define PRINT_BEFORE_OPTIMIZATION */

/* Define this to verify the methods after they are compiled.  This
   is useless because anyway after an image is saved methods are
   re-verified, but is a wonderful way of testing the compiler's
   output for correctness.  */
/* #define VERIFY_COMPILED_METHODS */

#define LITERAL_VEC_CHUNK_SIZE		32


typedef struct method_attributes
{
  struct method_attributes *next;
  int count;
  OOP oop;
} method_attributes;


/* This holds whether the compiler should make the compiled methods
   untrusted.  */
mst_Boolean _gst_untrusted_methods = false;

/* These hold the compiler's notions of the current class for
   compilations, and the current category that compiled methods are to
   be placed into.  */
OOP _gst_this_class = NULL;
OOP _gst_this_category = NULL;
static OOP this_method_category;

/* This holds the gst_compiled_method oop for the most recently
   compiled method.  It is only really valid after a compile: has been
   done, but this is the only place that its used.  */
OOP _gst_latest_compiled_method = NULL;

/* This flag controls whether byte codes are printed after
   compilation.  */
int _gst_declare_tracing = 0;

/* If true, the compilation of a set of methods will be skipped
   completely; only syntax will be checked.  Set by primitive, cleared
   by grammar.  */
mst_Boolean _gst_skip_compilation = false;

/* This is the value most recently returned by
   _gst_execute_statements.  It is used to communicate the returned
   value past a _gst_parse_stream call, without pushing something on
   the called context stack in the case of nested invocations of
   _gst_prepare_execution_environment/_gst_finish_execution_environment.
   Most often, the caller does not care about the returned value,
   since it often is called from a radically different context.  */
OOP _gst_last_returned_value = NULL;



/* Returns true if EXPR represents the symbol "super"; false if not.  */
static mst_Boolean is_super (tree_node expr);

/* Returns true if OOP and CONSTEXPR represent the same literal value.
   Primarily used by the compiler to store a single copy of duplicated
   literals in a method.  Can call itself in the case array
   literals.  */
static mst_Boolean equal_constant (OOP oop,
				   tree_node constExpr);


/* Special case compilation of a #timesRepeat: loop.  EXPR is a node
   for the entire keyword message send.  Returns true if byte codes
   were emitted, false if not.  If the last argument to the message is
   not a block expression, this routine cannot do its job, and so
   returns false to indicate as much.  */
static mst_Boolean compile_times_repeat (tree_node expr);

/* Special case compilation of a while loop whose selector is in
   SELECTOR.  EXPR is a node for the entire unary or keyword message
   send.  Returns true if byte codes were emitted, false if not.  If
   the last argument to the message is not a block expression, this
   routine cannot do its job, and so returns false to indicate as
   much.  */
static mst_Boolean compile_while_loop (OOP selector,
				       tree_node expr);

/* Special case compilation of a 1-argument if (#ifTrue: or #ifFalse:)
   whose selector is in SELECTOR; the default value for the absent
   case is nil.  EXPR is a node for the entire keyword message send.
   Returns true if byte codes were emitted, false if not.  If the last
   argument to the message is not a block expression, this routine
   cannot do its job, and so returns false to indicate as much.  */
static mst_Boolean compile_if_statement (OOP selector,
					 tree_node expr);

/* Special case compilation of a #to:do: (if BY is NULL) or #to:by:do:
   loop.  The starting value for the iteration is given by TO, the block
   is in BLOCK.  Returns true if byte codes were emitted, false if
   not.  If the last argument to the message is not a block expression,
   this routine cannot do its job, and so returns false to indicate as
   much.  */
static mst_Boolean compile_to_by_do (tree_node to,
				     tree_node by,
				     tree_node block);

/* Special case compilation of a #and: or #or: boolean operation; very
   similar to compile_if_statement.  EXPR is a node for the entire
   keyword message send.  Returns true if byte codes were emitted,
   false if not.  If the last argument to the message is not a block
   expression, this routine cannot do its job, and so returns false to
   indicate as much.  */
static mst_Boolean compile_and_or_statement (OOP selector,
					     tree_node expr);

/* Special case compilation of a 2-argument if whose selector is in
   SELECTOR.  EXPR is a node for the entire keyword message send.
   Returns true if byte codes were emitted, false if not.  If the last
   argument to the message is not a block expression, this routine
   cannot do its job, and so returns false to indicate as much.  */
static mst_Boolean compile_if_true_false_statement (OOP selector,
						    tree_node expr);

/* Special case compilation of an infinite loop, given by the parse
   node in RECEIVER.  Returns true if byte codes were emitted, false
   if not.  If the last argument to the message is not a block
   expression, this routine cannot do its job, and so returns false to
   indicate as much.  */
static mst_Boolean compile_repeat (tree_node receiver);

/* Compiles all of the statements in STATEMENTLIST.  If ISBLOCK is
   true, adds a final instruction of the block to return the top of
   stack, if the final statement isn't an explicit return from method
   (^).  Returns whether the last statement was a return (whatever
   the value of ISBLOCK.  */
static mst_Boolean compile_statements (tree_node statementList,
				       mst_Boolean isBlock);

/* Given a tree_node, this routine picks out and concatenates the
   keywords in SELECTOREXPR (if a TREE_KEYWORD_EXPR) or extracts the
   selector (if a TREE_UNARY_EXPR or TREE_BINARY_EXPR).  Then it turns
   them into a symbol OOP and returns that symbol.  */
static OOP compute_selector (tree_node selectorExpr);

/* Creates a new Array object that contains the literals for the
   method that's being compiled and returns it.  As a side effect, the
   currently allocated working literal vector is freed.  If there were
   no literals for the current method, _gst_nil_oop is returned.  */
static OOP get_literals_array (void);

/* Process the attributes in ATTRIBUTELIST, return the primitive number.
   Also record a <category: ...> attribute in this_method_category.  */
static int process_attributes_tree (tree_node attributeList);

/* Process the attribute in MESSAGEOOP, return the primitive number
   (so far, this is the only attribute we honor), -1 for a bad
   primitive number, or 0 for other attributes.  */
static int process_attribute (OOP messageOOP);

/* Creates and returns a CompiledMethod.  The method is completely
   filled in, including the descriptor, the method literals, and the
   byte codes for the method.  */
static OOP method_new (method_header header,
		       OOP literals,
		       bc_vector bytecodes,
		       OOP class,
		       OOP methodDesc);

/* Returns an instance of MethodInfo.  This instance is used in the
   reconstruction of the source code for the method, and holds the
   category that the method belongs to.  */
static OOP method_info_new (OOP class,
			    OOP selector,
			    method_attributes *attrs,
			    OOP sourceCode,
			    OOP categoryOOP);

/* This creates a CompiledBlock for the given BYTECODES.  The bytecodes
   are passed through the peephole optimizer and stored, the header is
   filled according to the given number of arguments ARGS and
   temporaries TEMPS, and to the cleanness of the block.  STACK_DEPTH
   contains the number of stack slots needed by the block except for
   arguments and temporaries.  */
static OOP make_block (int args,
		       int temps,
		       bc_vector bytecodes,
		       int stack_depth);
	
/* Create a BlockClosure for the given CompiledBlock, BLOCKOOP.  */
static OOP make_clean_block_closure (OOP blockOOP);

/* Compiles a block tree node, EXPR, in a separate context and return
   the resulting bytecodes.  The block's argument declarations are
   ignored since they are handled by compile_to_by_do (and are absent
   for other methods like ifTrue:, and:, whileTrue:, etc.); there are
   no temporaries.  It is compiled as a list of statements such that
   the last statement leaves the value that is produced on the stack,
   as the value of the "block".  */
static bc_vector compile_sub_expression (tree_node expr);

/* Like compile_sub_expression, except that after compiling EXPR this
   subexpression always ends with an unconditional branch past
   BRANCHLEN bytecodes.  */
static bc_vector compile_sub_expression_and_jump (tree_node expr,
						  int branchLen);

/* Compile a send with the given RECEIVER (used to check for sends to
   super), SELECTOR and number of arguments NUMARGS.  */
static void compile_send (tree_node receiver,
	                  OOP selector,
	                  int numArgs);

/* Computes and returns the length of a parse tree list, LISTEXPR.  */
static int list_length (tree_node listExpr);

/* Adds OOP to the literals associated with the method being compiled
   and returns the index of the literal slot that was used (0-based).
   Does not check for duplicates.  Automatically puts OOP in the
   incubator.  */
static int add_literal (OOP oop);

/* Compiles STMT, which is a statement expression, including return
   expressions.  */
static void compile_statement (tree_node stmt);

/* Compile EXPR, which is an arbitrary expression, including an
   assignment expression.  */
static void compile_expression (tree_node expr);

/* The basic expression compiler.  Often called recursively,
   dispatches based on the type of EXPR to different routines that
   specialize in compilations for that expression.  */
static void compile_simple_expression (tree_node expr);

/* Compile code to push the value of a variable onto the stack.  The
   special variables, self, true, false, super, and thisContext, are
   handled specially.  For other variables, different code is emitted
   depending on where the variable lives, such as in a global variable
   or in a method temporary.  */
static void compile_variable (tree_node varName);

/* Compile an expression that pushes a constant expression CONSTEXPR
   onto the stack.  Special cases out the constants that the byte code
   interpreter knows about, which are the integers in the range -1 to
   2.  Tries to emit the shortest possible byte sequence.  */
static void compile_constant (tree_node constExpr);

/* Compile the expressions for a block whose parse tree is BLOCKEXPR.
   Also, emits code to push the BlockClosure object, and creates the
   BlockClosure together with its CompiledBlock.  */
static void compile_block (tree_node blockExpr);

/* Compiles all of the statements in arrayConstructor, preceded by
   (Array new: <size of the list>) and with each statement followed
   with a <pop into instance variable of new stack top> instead of a
   simple pop.  */
static void compile_array_constructor (tree_node arrayConstructor);

/* Compile code to evaluate a unary expression EXPR.  Special cases
   sends to "super". Also, checks to see if it's the first part of a
   cascaded message send and if so emits code to duplicate the stack
   top after the evaluation of the receiver for use by the subsequent
   cascaded expressions.  */
static void compile_unary_expr (tree_node expr);

/* Compile code to evaluate a binary expression EXPR.  Special cases
   sends to "super" and open codes whileTrue/whileFalse/repeat when
   the receiver is a block.  Also, checks to see if it's the first
   part of a cascaded message send and if so emits code to duplicate
   the stack top after the evaluation of the receiver for use by the
   subsequent cascaded expressions.  */
static void compile_binary_expr (tree_node expr);

/* Compile code to evaluate a keyword expression EXPR.  Special cases
   sends to "super" and open codes while loops, the 4 kinds of if
   tests, and the conditional #and: and conditional #or: messages,
   #to:do:, and #to:by:do: with an Integer step. Also, checks to see
   if it's the first part of a cascaded message send and if so emits
   code to duplicate the stack top after the evaluation of the
   receiver for use by the subsequent cascaded expressions.  */
static void compile_keyword_expr (tree_node expr);

/* Compiles the code for a cascaded message send.  Due to the fact
   that cascaded sends go to the receiver of the last message before
   the first cascade "operator" (the ";"), the system to perform
   cascaded message sends is a bit kludgy.  We basically turn on a
   flag to the compiler that indicates that the value of the receiver
   of the last message before the cascaded sends is to be duplicated;
   and then compile code for each cascaded expression, throwing away
   the result, and duplicating the original receiver so that it can be
   used by the current message send, and following ones. 

   Note that both the initial receiver and all the subsequent cascaded
   sends can be derived from CASCADEDEXPR.  */
static void compile_cascaded_message (tree_node cascadedExpr);

/* Compiles all the assignments in VARLIST, which is a tree_node of
   type listNode.  The generated code assumes that the value on the
   top of the stack is what's to be used for the assignment.  Since
   this routine has no notion of now the value on top of the stack
   will be used by the calling environment, it makes sure that when
   the assignments are through, that the value on top of the stack
   after the assignment is the same as the value on top of the stack
   before the assignment.  The optimizer should fix this in the
   unnecessary cases.  */
static void compile_assignments (tree_node varList);

/* Compiles a forward jump instruction LEN bytes away (LEN must be >
   0), using the smallest possible number of bytecodes.  JUMPTYPE
   indicates which among the unconditional, "jump if true" and "jump
   if false" opcodes is desired.  Special cases for the short
   unconditional jump and the short false jump that the byte code
   interpreter handles.  */
static void compile_jump (int len,
			  mst_Boolean jumpType);

/* Emit code to evaluate each argument to a keyword message send,
   taking them from the parse tree node LIST.  */
static void compile_keyword_list (tree_node list);

/* Called to grow the literal vector that the compiler is using.  Modifies
   the global variables LITERAL_VEC and LITERAL_VEC_MAX to reflect the
   growth.  */
static void realloc_literal_vec (void);

/* Takes a new CompiledMethod METHODOOP and installs it in the method
   dictionary for the current class.  If the current class does not
   contain a valid method dictionary, one is allocated for it.  */
static void install_method (OOP methodOOP);

/* This caches the OOP of the special UndefinedObject>>#__terminate
   method, which is executed by contexts created with
   _gst_prepare_execution_environment.  */
static OOP termination_method;

/* Used to abort really losing compiles, jumps back to the top level
   of the compiler */
static jmp_buf bad_method;

/* The linked list of attributes that are specified by the method.  */
static method_attributes *method_attrs = NULL;

/* The vector of literals that the compiler uses to accumulate literal
   constants into */
static OOP *literal_vec = NULL;

/* These indicate the first free slot in the vector of literals in the
   method being compiled, and the first slot past the literal vector */
static OOP *literal_vec_curr, *literal_vec_max;

/* This indicates whether we are compiling a block */
static int inside_block;

/* HACK ALERT!! HACK ALERT!!  This variable is used for cascading.
   The tree structure is all wrong for the code in cascade processing
   to find the receiver of the initial message.  What this does is
   when it's true, compile_unary_expr, compile_binary_expr, and
   compile_keyword_expr record its value, and clear the global (to
   prevent propagation to compilation of subnodes).  After compiling
   their receiver, if the saved value of the flag is true, they emit a
   DUP_STACK_TOP, and continue compilation.  Since cascaded sends are
   relatively rare, I figured that this was a better alternative than
   passing useless parameters around all the time.  */
static mst_Boolean dup_message_receiver = false;


/* Exit a really losing compilation */
#define EXIT_COMPILATION()						\
	longjmp(bad_method, 1)

/* Answer whether the BLOCKNODE parse node has temporaries or
   arguments.  */
#define HAS_PARAMS_OR_TEMPS(blockNode) \
  (blockNode->v_block.temporaries || blockNode->v_block.arguments)

/* Answer whether the BLOCKNODE parse node has temporaries and
   has not exactly one argument.  */
#define HAS_NOT_ONE_PARAM_OR_TEMPS(blockNode)		\
  (blockNode->v_block.temporaries			\
   || !blockNode->v_block.arguments			\
   || blockNode->v_block.arguments->v_list.next)


void
_gst_install_initial_methods (void)
{
  const char *methodsForString;

  /* Define the termination method first of all, because
     compiling #methodsFor: will invoke an evaluation
     (to get the argument of the <primitive: ...> attribute.  */
  _gst_set_compilation_class (_gst_undefined_object_class);
  _gst_set_compilation_category (_gst_string_new ("private"));
  _gst_alloc_bytecodes ();
  _gst_compile_byte (EXIT_INTERPRETER, 0);
  _gst_compile_byte (JUMP_BACK, 4);

  /* The zeros are primitive, # of args, # of temps, stack depth */
  termination_method = _gst_make_new_method (0, 0, 0, 0, _gst_nil_oop,
					     _gst_get_bytecodes (),
					     _gst_this_class,
					     _gst_terminate_symbol,
					     _gst_this_category, -1, -1);

  ((gst_compiled_method) OOP_TO_OBJ (termination_method))->header.headerFlag
    = MTH_ANNOTATED;

  install_method (termination_method);

  methodsForString = "\n\
methodsFor: aCategoryString [\n\
    \"Calling this method prepares the parser to receive methods \n\
      to be compiled and installed in the receiver's method dictionary. \n\
      The methods are put in the category identified by the parameter.\" \n\
    <primitive: VMpr_Behavior_methodsFor> \n\
]";
  _gst_set_compilation_class (_gst_behavior_class);
  _gst_set_compilation_category (_gst_string_new ("compiling methods"));
  _gst_push_smalltalk_string (_gst_string_new (methodsForString));
  _gst_parse_stream (true);
  _gst_pop_stream (true);

  _gst_reset_compilation_category ();
}

OOP
_gst_get_termination_method (void)
{
  if (!termination_method)
    {
      termination_method =
	_gst_find_class_method (_gst_undefined_object_class,
				_gst_terminate_symbol);
    }

  return (termination_method);
}

static void
invoke_hook_smalltalk (enum gst_vm_hook hook)
{
  const char *hook_name;
  if (!_gst_kernel_initialized)
    return;

  switch (hook) {
  case GST_BEFORE_EVAL:
    hook_name = "beforeEvaluation";
    break;

  case GST_AFTER_EVAL:
    hook_name = "afterEvaluation";
    break;

  case GST_RETURN_FROM_SNAPSHOT:
    hook_name = "returnFromSnapshot";
    break;

  case GST_ABOUT_TO_QUIT:
    hook_name = "aboutToQuit";
    break;

  case GST_ABOUT_TO_SNAPSHOT:
    hook_name = "aboutToSnapshot";
    break;

  case GST_FINISHED_SNAPSHOT:
    hook_name = "finishedSnapshot";
    break;

  default:
    return;
  }

  _gst_msg_sendf (NULL, "%v %o changed: %S", 
		  _gst_object_memory_class, hook_name);
}

void
_gst_invoke_hook (enum gst_vm_hook hook)
{
  int save_execution;
  save_execution = _gst_execution_tracing;
  if (_gst_execution_tracing == 1)
    _gst_execution_tracing = 0;
  invoke_hook_smalltalk (hook);
  _gst_execution_tracing = save_execution;
}

void
_gst_init_compiler (void)
{
  /* Prepare the literal vector for use.  The literal vector is where the
     compiler will store any literals that are used by the method being
     compiled.  */
  literal_vec = (OOP *) xmalloc (LITERAL_VEC_CHUNK_SIZE * sizeof (OOP));

  literal_vec_curr = literal_vec;
  literal_vec_max = literal_vec + LITERAL_VEC_CHUNK_SIZE;

  _gst_register_oop_array (&literal_vec, &literal_vec_curr);
  _gst_reset_compilation_category ();
}

void
_gst_set_compilation_class (OOP class_oop)
{
  _gst_unregister_oop (_gst_this_class);
  _gst_this_class = class_oop;
  _gst_register_oop (_gst_this_class);

  _gst_untrusted_methods = (IS_OOP_UNTRUSTED (_gst_this_context_oop)
			    || IS_OOP_UNTRUSTED (_gst_this_class));
}

void
_gst_set_compilation_category (OOP categoryOOP)
{
  _gst_unregister_oop (_gst_this_category);
  _gst_this_category = categoryOOP;
  _gst_register_oop (_gst_this_category);

  _gst_untrusted_methods = (IS_OOP_UNTRUSTED (_gst_this_context_oop)
			    || IS_OOP_UNTRUSTED (_gst_this_class));
}

void
_gst_reset_compilation_category ()
{
  _gst_set_compilation_class (_gst_undefined_object_class);
  _gst_set_compilation_category (_gst_nil_oop);
  _gst_untrusted_methods = false;
}



void
_gst_display_compilation_trace (const char *string,
				mst_Boolean category)
{
  if (!_gst_declare_tracing)
    return;

  if (category)
    printf ("%s category %O for %O\n", string,
	    _gst_this_category, _gst_this_class);
  else
    printf ("%s for %O\n", string, _gst_this_class);
}


OOP
_gst_execute_statements (tree_node temps,
			 tree_node statements,
			 enum undeclared_strategy undeclared,
			 mst_Boolean quiet)
{
  tree_node messagePattern;
  int startTime, endTime, deltaTime;
  unsigned long cacheHits;
#ifdef HAVE_GETRUSAGE
  struct rusage startRusage, endRusage;
#endif
  OOP methodOOP;
  OOP oldClass, oldCategory;
  enum undeclared_strategy oldUndeclared;
  inc_ptr incPtr;
  YYLTYPE loc;

  if (_gst_regression_testing
      || _gst_verbosity < 2
      || !_gst_get_cur_stream_prompt ())
    quiet = true;

  oldClass = _gst_this_class;
  oldCategory = _gst_this_category;
  _gst_register_oop (oldClass);
  _gst_register_oop (oldCategory);

  _gst_set_compilation_class (_gst_undefined_object_class);
  _gst_set_compilation_category (_gst_nil_oop);
  loc = _gst_get_location ();

  messagePattern = _gst_make_unary_expr (&statements->location,
					 NULL, "executeStatements");

  _gst_display_compilation_trace ("Compiling doit code", false);

  /* This is a big hack to let doits access the variables and classes
     in the current namespace.  */
  oldUndeclared = _gst_set_undeclared (undeclared);
  SET_CLASS_ENVIRONMENT (_gst_undefined_object_class,
			 _gst_current_namespace);

  if (statements->nodeType != TREE_STATEMENT_LIST)
    statements = _gst_make_statement_list (&statements->location, statements);

  methodOOP =
    _gst_compile_method (_gst_make_method (&statements->location, &loc,
					   messagePattern, temps, NULL,
					   statements, false),
			 true, false);

  SET_CLASS_ENVIRONMENT (_gst_undefined_object_class,
			 _gst_smalltalk_dictionary);
  _gst_set_undeclared (oldUndeclared);

  _gst_set_compilation_class (oldClass);
  _gst_set_compilation_category (oldCategory);
  _gst_unregister_oop (oldClass);
  _gst_unregister_oop (oldCategory);

  if (_gst_had_error)		/* don't execute on error */
    return (NULL);

  incPtr = INC_SAVE_POINTER ();
  INC_ADD_OOP (methodOOP);

  if (!_gst_raw_profile)
    _gst_bytecode_counter = _gst_primitives_executed =
      _gst_self_returns = _gst_inst_var_returns = _gst_literal_returns =
      _gst_sample_counter = 0;

  startTime = _gst_get_milli_time ();
#ifdef HAVE_GETRUSAGE
  getrusage (RUSAGE_SELF, &startRusage);
#endif

  _gst_invoke_hook (GST_BEFORE_EVAL);

  /* send a message to NIL, which will find this synthetic method
     definition in Object and execute it */
  _gst_last_returned_value = _gst_nvmsg_send (_gst_nil_oop, methodOOP, NULL, 0);
  INC_ADD_OOP (_gst_last_returned_value);

  endTime = _gst_get_milli_time ();
#ifdef HAVE_GETRUSAGE
  getrusage (RUSAGE_SELF, &endRusage);
#endif

  _gst_invoke_hook (GST_AFTER_EVAL);

  INC_RESTORE_POINTER (incPtr);

  if (!quiet)
    {
      int save_execution;

      /* Do more frequent flushing to ensure the result are well placed */
      if (_gst_verbosity >= 3)
	{
          printf ("returned value is ");
          fflush(stdout);
	}

      save_execution = _gst_execution_tracing;
      if (_gst_execution_tracing == 1)
        _gst_execution_tracing = 0;
      if (_gst_responds_to (_gst_last_returned_value,
			    _gst_intern_string ("printNl"))
          || _gst_responds_to (_gst_last_returned_value,
			       _gst_does_not_understand_symbol))
        _gst_str_msg_send (_gst_last_returned_value, "printNl", NULL);
      else
	printf ("%O\n", _gst_last_returned_value);

      _gst_execution_tracing = save_execution;
    }
  if (quiet || _gst_verbosity < 3)
    return (_gst_last_returned_value);

  deltaTime = endTime - startTime;
#ifdef ENABLE_JIT_TRANSLATION
  printf ("Execution took %.3f seconds", deltaTime / 1000.0);
#else
  printf ("%lu byte codes executed\nwhich took %.3f seconds",
	  _gst_bytecode_counter, deltaTime / 1000.0);
#endif

#ifdef HAVE_GETRUSAGE
  deltaTime = ((endRusage.ru_utime.tv_sec * 1000) +
	       (endRusage.ru_utime.tv_usec / 1000)) -
    ((startRusage.ru_utime.tv_sec * 1000) +
     (startRusage.ru_utime.tv_usec / 1000));
  printf (" (%.3fs user", deltaTime / 1000.0);

  deltaTime = ((endRusage.ru_stime.tv_sec * 1000) +
	       (endRusage.ru_stime.tv_usec / 1000)) -
    ((startRusage.ru_stime.tv_sec * 1000) +
     (startRusage.ru_stime.tv_usec / 1000));
  printf ("+%.3fs sys)", deltaTime / 1000.0);
#endif
  printf ("\n");

#ifdef ENABLE_JIT_TRANSLATION
  if (!_gst_sample_counter)
    return (_gst_last_returned_value);

  printf
    ("%lu primitives, %lu inline cache misses since last cache cleanup\n",
     _gst_primitives_executed, _gst_sample_counter);
#else
  if (!_gst_bytecode_counter)
    return (_gst_last_returned_value);

  printf ("%lu primitives, percent %.2f\n", _gst_primitives_executed,
	  100.0 * _gst_primitives_executed / _gst_bytecode_counter);
  printf ("self returns %lu, inst var returns %lu, literal returns %lu\n",
          _gst_self_returns, _gst_inst_var_returns, _gst_literal_returns);
  printf ("%lu method cache lookups since last cleanup, percent %.2f\n",
	  _gst_sample_counter,
	  100.0 * _gst_sample_counter / _gst_bytecode_counter);
#endif

  cacheHits = _gst_sample_counter - _gst_cache_misses;
  printf ("%lu method cache hits, %lu misses", cacheHits,
	  _gst_cache_misses);
  if (cacheHits || _gst_cache_misses)
    printf (", %.2f percent hits\n", (100.0 * cacheHits) / _gst_sample_counter);
  else
    printf ("\n");

  return (_gst_last_returned_value);
}



OOP
_gst_compile_method (tree_node method,
		     mst_Boolean returnLast,
		     mst_Boolean install)
{
  tree_node statement;
  OOP selector;
  OOP methodOOP;
  bc_vector bytecodes;
  int primitiveIndex;
  int stack_depth;
  inc_ptr incPtr;
  gst_compiled_method compiledMethod;

  dup_message_receiver = false;
  literal_vec_curr = literal_vec;
  this_method_category = _gst_this_category;
  _gst_unregister_oop (_gst_latest_compiled_method);
  _gst_latest_compiled_method = _gst_nil_oop;

  incPtr = INC_SAVE_POINTER ();

  _gst_alloc_bytecodes ();
  _gst_push_new_scope ();
  inside_block = 0;
  selector = compute_selector (method->v_method.selectorExpr);

  /* When we are reading from stdin, it's better to write line numbers where
     1 is the first line *in the current doit*, because for now the prompt
     does not include the line number.  This might change in the future.

     Also, do not emit line numbers if the method has no statements.  */
  if ((method->location.file_offset != -1 && _gst_get_cur_stream_prompt ())
      || !method->v_method.statements)
    _gst_line_number (method->location.first_line, LN_RESET);
  else
    _gst_line_number (method->location.first_line, LN_RESET | LN_ABSOLUTE);

  INC_ADD_OOP (selector);

  if (_gst_declare_tracing)
    printf ("  class %O, selector %O\n", _gst_this_class, selector);

  if (setjmp (bad_method) == 0)
    {
      if (_gst_declare_arguments (method->v_method.selectorExpr) == -1)
	{
	  _gst_errorf_at (method->location.first_line,
			  "duplicate argument name");
          EXIT_COMPILATION ();
	}

      if (_gst_declare_temporaries (method->v_method.temporaries) == -1)
        {
	  _gst_errorf_at (method->location.first_line,
			  "duplicate temporary variable name");
          EXIT_COMPILATION ();
	}

      primitiveIndex = process_attributes_tree (method->v_method.attributes);

      for (statement = method->v_method.statements; statement; )
	{
	  mst_Boolean wasReturn = statement->v_list.value->nodeType == TREE_RETURN_EXPR;
	  compile_statement (statement->v_list.value);

	  statement = statement->v_list.next;
	  if (wasReturn)
	    continue;

	  if (!statement && returnLast)
	    /* compile a return of the last evaluated value.  Note that in
	       theory the pop above is not necessary in this case 
	       (and in fact older versions did not put it),
	       but having it simplifies the optimizer's task
	       because it reduces the number of patterns it has
	       to look for.  If necessary, the optimizer itself
	       will remove the pop.  */
	    {
	      _gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);
	      break;
	    }

	    /* ignore the result of the last statement if it's not
	       used */
	    SUB_STACK_DEPTH (1);
	    _gst_compile_byte (POP_STACK_TOP, 0);

	    if (!statement)
	      {
	        /* compile a return of self.  Note that in
	           theory the pop above is not necessary in this case 
	           (and in fact older versions did not put it),
	           but having it simplifies the optimizer's task
	           because it reduces the number of patterns it has
	           to look for.  If necessary, the optimizer itself
	           will remove the pop.  */
	        _gst_compile_byte (PUSH_SELF, 0);
	        _gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);
		break;
	      }
	}

      if (method->v_method.statements == NULL)
	{
	  if (returnLast)
	    {
	      /* special case an empty statement body to return nil */
	      _gst_compile_byte (PUSH_SPECIAL, NIL_INDEX);
	      _gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);
	    }
	  else
	    {
	      /* special case an empty statement body to return _gst_self */
	      _gst_compile_byte (PUSH_SELF, 0);
	      _gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);
	    }
	}

      stack_depth = GET_STACK_DEPTH ();
      bytecodes = _gst_get_bytecodes ();

      methodOOP = _gst_make_new_method (primitiveIndex,
					_gst_get_arg_count (),
					_gst_get_temp_count (),
					stack_depth, _gst_nil_oop, bytecodes,
					_gst_this_class, selector,
					_gst_this_category,
					method->location.file_offset,
					method->v_method.endPos);

      compiledMethod = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
      compiledMethod->header.isOldSyntax = method->v_method.isOldSyntax;
      INC_ADD_OOP (methodOOP);

      if (install)
	install_method (methodOOP);

      _gst_latest_compiled_method = methodOOP;	/* reachable by the
						   root set */
      _gst_register_oop (_gst_latest_compiled_method);
    }
  else
    {
      _gst_had_error = true;
      bytecodes = _gst_get_bytecodes ();
      literal_vec_curr = literal_vec;
      _gst_free_bytecodes (bytecodes);
    }

  _gst_pop_all_scopes ();

  INC_RESTORE_POINTER (incPtr);
  return (_gst_latest_compiled_method);
}

void
compile_statement (tree_node stmt)
{
  tree_node receiver;

  if (stmt->nodeType != TREE_RETURN_EXPR)
    {
      compile_expression (stmt);
      return;
    }

  receiver = stmt->v_expr.receiver;
  if (inside_block)
    {
      compile_expression (receiver);
      _gst_compile_byte (RETURN_METHOD_STACK_TOP, 0);
      SUB_STACK_DEPTH (1);
      return;
    }

  compile_expression (receiver);
  _gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);
  SUB_STACK_DEPTH (1);
}

void
compile_expression (tree_node expr)
{
  if (expr->nodeType == TREE_ASSIGN_EXPR)
    {
      compile_simple_expression (expr->v_expr.expression);
      compile_assignments (expr->v_expr.receiver);
    }
  else
    compile_simple_expression (expr);
}

void
compile_simple_expression (tree_node expr)
{
  _gst_line_number (expr->location.first_line, 0);
  switch (expr->nodeType)
    {
    case TREE_VARIABLE_NODE:
      compile_variable (expr);
      break;
    case TREE_CONST_EXPR:
      compile_constant (expr);
      break;
    case TREE_BLOCK_NODE:
      compile_block (expr);
      break;
    case TREE_UNARY_EXPR:
      compile_unary_expr (expr);
      break;
    case TREE_BINARY_EXPR:
      compile_binary_expr (expr);
      break;
    case TREE_KEYWORD_EXPR:
      compile_keyword_expr (expr);
      break;
    case TREE_CASCADE_EXPR:
      compile_cascaded_message (expr);
      break;
    case TREE_ARRAY_CONSTRUCTOR:
      compile_array_constructor (expr);
      break;
    default:
      compile_expression (expr);
    }
}

void
compile_variable (tree_node varName)
{
  symbol_entry variable;

  INCR_STACK_DEPTH ();
  if (!_gst_find_variable (&variable, varName))
    {
      if (varName->v_list.next)
        _gst_errorf_at (varName->location.first_line,
			"invalid scope resolution");
      else
	_gst_errorf_at (varName->location.first_line,
			"undefined variable %s referenced",
		        varName->v_list.name);
      EXIT_COMPILATION ();
    }

  if (variable.scope == SCOPE_SPECIAL)
    switch (variable.varIndex)
      {
      case THIS_CONTEXT_INDEX:
	{
          static OOP contextPartAssociation;
	  if (!contextPartAssociation)
            {
              contextPartAssociation =
	        dictionary_association_at (_gst_smalltalk_dictionary,
				           _gst_intern_string ("ContextPart"));
	    }

          _gst_compile_byte (PUSH_LIT_VARIABLE,
			     _gst_add_forced_object (contextPartAssociation));
          _gst_compile_byte (SEND_IMMEDIATE, THIS_CONTEXT_SPECIAL);
        }
        return;

      case RECEIVER_INDEX:
	_gst_compile_byte (PUSH_SELF, 0);
	return;

      default:
	_gst_compile_byte (PUSH_SPECIAL, variable.varIndex);
        return;
      }

  if (variable.scope != SCOPE_GLOBAL && varName->v_list.next)
    {
      _gst_errorf_at (varName->location.first_line,
		      "invalid scope resolution");
      EXIT_COMPILATION ();
    }

  if (variable.scopeDistance != 0)
    /* must be a temporary from an outer scope */
    _gst_compile_byte (PUSH_OUTER_TEMP,
		       variable.varIndex * 256 + variable.scopeDistance);

  else if (variable.scope == SCOPE_TEMPORARY)
    _gst_compile_byte (PUSH_TEMPORARY_VARIABLE, variable.varIndex);

  else if (variable.scope == SCOPE_RECEIVER)
    _gst_compile_byte (PUSH_RECEIVER_VARIABLE, variable.varIndex);

  else
    _gst_compile_byte (PUSH_LIT_VARIABLE, variable.varIndex);
}

void
compile_constant (tree_node constExpr)
{
  intptr_t intVal;
  int index = -1;
  OOP constantOOP;
  OOP *lit;

  /* Scan the current literal frame, looking for a constant equal
     to the one that is being compiled.  */
  for (lit = literal_vec; lit < literal_vec_curr; lit++)
    if (equal_constant (*lit, constExpr))
      {
	index = lit - literal_vec;
	break;
      }

  /* If not found, check if it can be compiled with a PUSH_INTEGER
     bytecode, or add it to the literals.  */
  if (index == -1)
    {
      constantOOP = _gst_make_constant_oop (constExpr);
      if (IS_INT (constantOOP))
        {
          intVal = TO_INT (constantOOP);
          if (intVal >= 0 && intVal <= 0x7FFFFFFFL)
            {
	      INCR_STACK_DEPTH ();
	      _gst_compile_byte (PUSH_INTEGER, intVal);
	      return;
	    }
        }

      index = add_literal (constantOOP);
    }

  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_LIT_CONSTANT, index);
}

void
compile_block (tree_node blockExpr)
{
  bc_vector current_bytecodes, blockByteCodes;
  int argCount, tempCount;
  int stack_depth;
  OOP blockClosureOOP, blockOOP;
  gst_compiled_block block;
  inc_ptr incPtr;

  current_bytecodes = _gst_save_bytecode_array ();

  _gst_push_new_scope ();
  argCount = _gst_declare_block_arguments (blockExpr->v_block.arguments);
  tempCount = _gst_declare_temporaries (blockExpr->v_block.temporaries);

  if (argCount == -1)
    {
      _gst_errorf_at (blockExpr->location.first_line,
		      "duplicate argument name");
      EXIT_COMPILATION ();
    }

  if (tempCount == -1)
    {
      _gst_errorf_at (blockExpr->location.first_line,
		      "duplicate temporary variable name");
      EXIT_COMPILATION ();
    }

  compile_statements (blockExpr->v_block.statements, true);

  stack_depth = GET_STACK_DEPTH ();
  blockByteCodes = _gst_get_bytecodes ();

  _gst_restore_bytecode_array (current_bytecodes);

  /* Always allocate objects starting from the deepest one! (that is,
     subtle bugs arise if make_block triggers a GC, because
     the pointer in the closure might be no longer valid!) */
  incPtr = INC_SAVE_POINTER ();
  blockOOP = make_block (_gst_get_arg_count (), _gst_get_temp_count (),
			 blockByteCodes, stack_depth);
  INC_ADD_OOP (blockOOP);
  _gst_pop_old_scope ();

  /* emit standard byte sequence to invoke a block: 

        push literal (a BlockClosure)
     or
        push literal (a CompiledBlock)
        make dirty block */

  INCR_STACK_DEPTH ();
  block = (gst_compiled_block) OOP_TO_OBJ (blockOOP);
  if (block->header.clean == 0)
    {
      blockClosureOOP = make_clean_block_closure (blockOOP);
      _gst_compile_byte (PUSH_LIT_CONSTANT, add_literal (blockClosureOOP));
    }
  else
    {
      _gst_compile_byte (PUSH_LIT_CONSTANT, add_literal (blockOOP));
      _gst_compile_byte (MAKE_DIRTY_BLOCK, 0);
    }

  INC_RESTORE_POINTER (incPtr);
}


mst_Boolean
compile_statements (tree_node statementList,
		    mst_Boolean isBlock)
{
  tree_node stmt;

  if (statementList == NULL)
    {
      INCR_STACK_DEPTH ();
      _gst_compile_byte (PUSH_SPECIAL, NIL_INDEX);

      if (isBlock)
	_gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);

      return (false);
    }

  if (isBlock)
    {
      _gst_line_number (statementList->location.first_line, LN_FORCE);
      inside_block++;
    }

  for (stmt = statementList;; stmt = stmt->v_list.next)
    {
      compile_statement (stmt->v_list.value);
      if (!stmt->v_list.next)
	break;

      /* throw away the value on the top of the stack...we don't need
         it for all but the last one.  */
      SUB_STACK_DEPTH (1);
      _gst_compile_byte (POP_STACK_TOP, 0);
    }

  /* stmt is the last statement here.  if it isn't a return, then
     return the value on the stack as the result.  For inlined blocks,
     the returned value is the top of the stack (which is already
     there), so we are already done.  */
  if (stmt->v_list.value->nodeType != TREE_RETURN_EXPR && isBlock)
    _gst_compile_byte (RETURN_CONTEXT_STACK_TOP, 0);

  if (isBlock)
    {
      _gst_line_number (-1, 0);
      inside_block--;
    }

  return (stmt->v_list.value->nodeType == TREE_RETURN_EXPR);
}

void
compile_array_constructor (tree_node arrayConstructor)
{
  tree_node stmt, statementList;
  int i, n;
  static OOP arrayAssociation;

  statementList = arrayConstructor->v_const.val.aVal;
  for (n = 0, stmt = statementList; stmt;
       n++, stmt = stmt->v_list.next);

  if (!arrayAssociation)
    {
      arrayAssociation =
	dictionary_association_at (_gst_smalltalk_dictionary,
				   _gst_intern_string ("Array"));
    }

  ADD_STACK_DEPTH (2);
  _gst_compile_byte (PUSH_LIT_VARIABLE,
		     _gst_add_forced_object (arrayAssociation));
  _gst_compile_byte (PUSH_INTEGER, n);
  _gst_compile_byte (SEND_IMMEDIATE, NEW_COLON_SPECIAL);
  SUB_STACK_DEPTH (1);

  /* compile the values now */
  for (i = 0, stmt = statementList; i < n;
       i++, stmt = stmt->v_list.next)
    {
      compile_statement (stmt->v_list.value);
      _gst_compile_byte (POP_INTO_NEW_STACKTOP, i);

      /* throw away the value on the top of the stack...  */
      SUB_STACK_DEPTH (1);
    }
}


void
compile_unary_expr (tree_node expr)
{
  OOP selector;
  mst_Boolean savedDupFlag;

  savedDupFlag = dup_message_receiver;
  dup_message_receiver = false;

  selector = expr->v_expr.selector;

  /* check for optimized cases of messages to blocks and handle them
     specially */
  if (selector == _gst_while_true_symbol
      || selector == _gst_while_false_symbol)
    {
      if (compile_while_loop (selector, expr))
	return;
    }
  else if (selector == _gst_repeat_symbol)
    {
      if (compile_repeat (expr->v_expr.receiver))
	return;
    }

  if (expr->v_expr.receiver != NULL)
    {
      compile_expression (expr->v_expr.receiver);
      if (savedDupFlag)
	{
	  _gst_compile_byte (DUP_STACK_TOP, 0);
          INCR_STACK_DEPTH ();
	}
    }

  compile_send (expr, selector, 0);
}

void
compile_binary_expr (tree_node expr)
{
  OOP selector;
  mst_Boolean savedDupFlag;

  savedDupFlag = dup_message_receiver;
  dup_message_receiver = false;

  selector = expr->v_expr.selector;

  if (expr->v_expr.receiver != NULL)
    {
      compile_expression (expr->v_expr.receiver);
      if (savedDupFlag)
	{
	  _gst_compile_byte (DUP_STACK_TOP, 0);
          INCR_STACK_DEPTH ();
	}
    }

  if (expr->v_expr.expression)
    compile_expression (expr->v_expr.expression);

  compile_send (expr, selector, 1);
}

void
compile_keyword_expr (tree_node expr)
{
  OOP selector;
  int numArgs;
  mst_Boolean savedDupFlag;

  savedDupFlag = dup_message_receiver;
  dup_message_receiver = false;

  selector = compute_selector (expr);

  /* check for optimized cases of messages to booleans and handle them
     specially */
  if (selector == _gst_while_true_colon_symbol
      || selector == _gst_while_false_colon_symbol)
    {
      if (compile_while_loop (selector, expr))
	return;
    }

  if (expr->v_expr.receiver)
    {
      compile_expression (expr->v_expr.receiver);
      if (savedDupFlag)
	{
	  _gst_compile_byte (DUP_STACK_TOP, 0);
          INCR_STACK_DEPTH ();
	}
    }

  if (selector == _gst_if_true_symbol
      || selector == _gst_if_false_symbol)
    {
      if (compile_if_statement (selector, expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_if_true_if_false_symbol
	   || selector == _gst_if_false_if_true_symbol)
    {
      if (compile_if_true_false_statement
	  (selector, expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_and_symbol
	   || selector == _gst_or_symbol)
    {
      if (compile_and_or_statement (selector, expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_times_repeat_symbol)
    {
      if (compile_times_repeat (expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_to_do_symbol)
    {
      if (compile_to_by_do (expr->v_expr.expression->v_list.value, NULL,
			    expr->v_expr.expression->v_list.next->v_list.value))
	return;
    }
  else if (selector == _gst_to_by_do_symbol)
    {
      if (compile_to_by_do (expr->v_expr.expression->v_list.value,
			    expr->v_expr.expression->v_list.next->v_list.value,
			    expr->v_expr.expression->v_list.next->v_list.next->v_list.value))
	return;
    }

  numArgs = list_length (expr->v_expr.expression);

  compile_keyword_list (expr->v_expr.expression);
  compile_send (expr, selector, numArgs);
}


void
compile_send (tree_node expr,
	      OOP selector,
	      int numArgs)
{
  const char *str = (const char *) OOP_TO_OBJ (selector)->data;
  int len = NUM_INDEXABLE_FIELDS (selector);
  struct builtin_selector *bs = _gst_lookup_builtin_selector (str, len);

  int super = expr->v_expr.receiver
              && is_super (expr->v_expr.receiver);

  if (super && IS_NIL (SUPERCLASS (_gst_this_class)))
    {
      _gst_errorf ("cannot send to super from within a root class\n");
      EXIT_COMPILATION ();
    }

  if (super)
    compile_constant (_gst_make_oop_constant (&expr->location,
					      SUPERCLASS (_gst_this_class)));

  if (!bs)
    {
      int selectorIndex = _gst_add_forced_object (selector);
      _gst_compile_byte (SEND | super, (selectorIndex << 8) | numArgs);
    }
  else if (!super && bs->bytecode < 32)
    _gst_compile_byte (bs->bytecode, 0);
  else
    _gst_compile_byte (SEND_IMMEDIATE | super, bs->bytecode);

  SUB_STACK_DEPTH (numArgs);
}

void
compile_keyword_list (tree_node list)
{
  for (; list; list = list->v_list.next)
    compile_expression (list->v_list.value);
}



mst_Boolean
compile_while_loop (OOP selector,
		    tree_node expr)
{
  int finalJumpLen, finalJumpOfs, jumpAroundLen, jumpAroundOfs,
      oldJumpAroundLen;
  int whileCondLen;
  bc_vector receiverExprCodes, whileExprCodes = NULL;
  mst_Boolean colon, whileTrue;

  colon = (expr->v_expr.expression != NULL);
  whileTrue = (selector == _gst_while_true_colon_symbol)
    || (selector == _gst_while_true_symbol);

  if (expr->v_expr.receiver->nodeType != TREE_BLOCK_NODE ||
      (colon
       && expr->v_expr.expression->v_list.value->nodeType !=
       TREE_BLOCK_NODE))
    return (false);

  if (HAS_PARAMS_OR_TEMPS (expr->v_expr.receiver) ||
      (colon
       && HAS_PARAMS_OR_TEMPS (expr->v_expr.expression->v_list.value)))
    return (false);


  receiverExprCodes = compile_sub_expression (expr->v_expr.receiver);
  whileCondLen = _gst_bytecode_length (receiverExprCodes);
  _gst_compile_and_free_bytecodes (receiverExprCodes);

  if (colon)
    {
      whileExprCodes =
	compile_sub_expression (expr->v_expr.expression->v_list.value);

      jumpAroundOfs = _gst_bytecode_length (whileExprCodes) + 2;
    }
  else
    jumpAroundOfs = 0;

  for (oldJumpAroundLen = finalJumpLen = 0; ; oldJumpAroundLen = jumpAroundLen)
    {
      finalJumpOfs = whileCondLen + 2 + oldJumpAroundLen + jumpAroundOfs;
      finalJumpLen = (finalJumpOfs + finalJumpLen >= 65536 ? 6 :
		      finalJumpOfs + finalJumpLen >= 256 ? 4 : 2);
      finalJumpLen = (finalJumpOfs + finalJumpLen >= 65536 ? 6 :
		      finalJumpOfs + finalJumpLen >= 256 ? 4 : 2);
      jumpAroundLen = (jumpAroundOfs + finalJumpLen >= 65536 ? 6 :
		       jumpAroundOfs + finalJumpLen >= 256 ? 4 : 2);
      if (jumpAroundLen == oldJumpAroundLen)
        break;
    }

  /* skip to the while loop if the receiver block yields the proper 
     value */
  compile_jump (jumpAroundLen, whileTrue);

  /* otherwise, skip to the end, past the pop stack top and 2 byte
     jump and exit the loop */
  _gst_compile_byte (JUMP, jumpAroundOfs + finalJumpLen);

  if (colon)
    {
      _gst_compile_and_free_bytecodes (whileExprCodes);
      _gst_compile_byte (POP_STACK_TOP, 0);	/* we don't care about
						   while expr's value */
      SUB_STACK_DEPTH (1);
    }

  _gst_compile_byte (JUMP_BACK, finalJumpLen + finalJumpOfs);

  /* while loops always return nil (ain't expression languages grand?)
     -- inefficient, but anyway the optimizer deletes this.  */
  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_SPECIAL, NIL_INDEX);
  return (true);
}


mst_Boolean
compile_repeat (tree_node receiver)
{
  int repeatedLoopLen, finalJumpLen;
  bc_vector receiverExprCodes;

  if (receiver->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_PARAMS_OR_TEMPS (receiver))
    return (false);

  receiverExprCodes = compile_sub_expression (receiver);
  repeatedLoopLen = _gst_bytecode_length (receiverExprCodes);

  repeatedLoopLen += 2;
  finalJumpLen = (repeatedLoopLen >= 65536 ? 6 :
		  repeatedLoopLen >= 256 ? 4 : 2);
  finalJumpLen = (repeatedLoopLen + finalJumpLen >= 65536 ? 6 :
		  repeatedLoopLen + finalJumpLen >= 256 ? 4 : 2);
  finalJumpLen = (repeatedLoopLen + finalJumpLen >= 65536 ? 6 :
		  repeatedLoopLen + finalJumpLen >= 256 ? 4 : 2);

  _gst_compile_and_free_bytecodes (receiverExprCodes);
  _gst_compile_byte (POP_STACK_TOP, 0);	/* we don't care about expr's
					   value */
  SUB_STACK_DEPTH (1);
  _gst_compile_byte (JUMP_BACK, finalJumpLen + repeatedLoopLen);

  /* this code is unreachable, it is only here to please the JIT
     compiler */
  _gst_compile_byte (PUSH_SPECIAL, NIL_INDEX);
  INCR_STACK_DEPTH ();
  return (true);
}

mst_Boolean
compile_times_repeat (tree_node expr)
{
  int jumpAroundOfs, oldJumpAroundLen, jumpAroundLen;
  int finalJumpOfs, finalJumpLen;
  bc_vector loopExprCodes;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_PARAMS_OR_TEMPS (expr->v_list.value))
    return (false);

  /* save the receiver for the return value */
  _gst_compile_byte (DUP_STACK_TOP, 0);
  INCR_STACK_DEPTH ();

  loopExprCodes = compile_sub_expression (expr->v_list.value);

  _gst_compile_byte (DUP_STACK_TOP, 0);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_INTEGER, 1);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (GREATER_EQUAL_SPECIAL, 0);
  SUB_STACK_DEPTH (1);

  /* skip the loop if there are no more occurrences */
  jumpAroundOfs = 6 + _gst_bytecode_length (loopExprCodes);
  for (oldJumpAroundLen = finalJumpLen = 0; ; oldJumpAroundLen = jumpAroundLen)
    {
      finalJumpOfs = 6 + oldJumpAroundLen + jumpAroundOfs;
      finalJumpLen = (finalJumpOfs + finalJumpLen > 65536 ? 6 :
		      finalJumpOfs + finalJumpLen > 256 ? 4 : 2);
      finalJumpLen = (finalJumpOfs + finalJumpLen > 65536 ? 6 :
		      finalJumpOfs + finalJumpLen > 256 ? 4 : 2);
      jumpAroundLen = (jumpAroundOfs + finalJumpLen > 65536 ? 6 :
		       jumpAroundOfs + finalJumpLen > 256 ? 4 : 2);
      if (jumpAroundLen == oldJumpAroundLen)
        break;
    }

  compile_jump (jumpAroundOfs + finalJumpLen, false);
  _gst_compile_byte (PUSH_INTEGER, 1);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (MINUS_SPECIAL, 0);
  SUB_STACK_DEPTH (1);

  /* we don't care about block expr's value */
  _gst_compile_and_free_bytecodes (loopExprCodes);
  _gst_compile_byte (POP_STACK_TOP, 0);
  SUB_STACK_DEPTH (1);

  _gst_compile_byte (JUMP_BACK, finalJumpLen + finalJumpOfs);

  /* delete the 0 that remains on the stack */
  _gst_compile_byte (POP_STACK_TOP, 0);
  SUB_STACK_DEPTH (1);
  return (true);
}

mst_Boolean
compile_to_by_do (tree_node to,
		  tree_node by,
		  tree_node block)
{
  int jumpAroundOfs, oldJumpAroundLen, jumpAroundLen;
  int finalJumpOfs, finalJumpLen;
  int index;
  bc_vector loopExprCodes, stepCodes = NULL;	/* initialize to please 
						   gcc */

  if (block->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_NOT_ONE_PARAM_OR_TEMPS (block))
    return (false);

  if (by)
    {
      if (by->nodeType != TREE_CONST_EXPR
	  || by->v_const.constType != CONST_INT)
	return (false);
    }

  index =
    _gst_declare_name (block->v_block.arguments->v_list.name, false, true);
  _gst_compile_byte (STORE_TEMPORARY_VARIABLE, index);

  compile_expression (to);
  _gst_compile_byte (DUP_STACK_TOP, index);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_TEMPORARY_VARIABLE, index);

  if (by)
    {
      bc_vector current_bytecodes;
      current_bytecodes = _gst_save_bytecode_array ();
      compile_expression (by);
      stepCodes = _gst_get_bytecodes ();
      _gst_restore_bytecode_array (current_bytecodes);
      jumpAroundOfs = _gst_bytecode_length (stepCodes);
    }
  else
    jumpAroundOfs = 2;

  loopExprCodes = compile_sub_expression (block);
  jumpAroundOfs += _gst_bytecode_length (loopExprCodes) + 10;

  for (oldJumpAroundLen = jumpAroundLen = finalJumpLen = 0; ; oldJumpAroundLen = jumpAroundLen)
    {
      finalJumpOfs = jumpAroundOfs + jumpAroundLen + 2;
      finalJumpLen = (finalJumpOfs + finalJumpLen > 65536 ? 6 :
		      finalJumpOfs + finalJumpLen > 256 ? 4 : 2);
      finalJumpLen = (finalJumpOfs + finalJumpLen > 65536 ? 6 :
		      finalJumpOfs + finalJumpLen > 256 ? 4 : 2);
      jumpAroundLen = (jumpAroundOfs + finalJumpLen > 65536 ? 6 :
		       jumpAroundOfs + finalJumpLen > 256 ? 4 : 2);
      if (jumpAroundLen == oldJumpAroundLen)
        break;
    }

  /* skip the loop if there are no more occurrences */
  _gst_compile_byte ((!by || by->v_const.val.iVal > 0)
		     ? GREATER_EQUAL_SPECIAL : LESS_EQUAL_SPECIAL, 0);
  SUB_STACK_DEPTH (1);
  compile_jump (jumpAroundOfs + finalJumpLen, false);

  /* we don't care about loop expr's value */
  _gst_compile_and_free_bytecodes (loopExprCodes);
  _gst_compile_byte (POP_STACK_TOP, 0);
  SUB_STACK_DEPTH (1);
  _gst_compile_byte (DUP_STACK_TOP, 0);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_TEMPORARY_VARIABLE, index);
  INCR_STACK_DEPTH ();

  if (by)
    _gst_compile_and_free_bytecodes (stepCodes);
  else
    {
      _gst_compile_byte (PUSH_INTEGER, 1);
      INCR_STACK_DEPTH ();
    }

  _gst_compile_byte (PLUS_SPECIAL, 0);
  SUB_STACK_DEPTH (1);
  _gst_compile_byte (STORE_TEMPORARY_VARIABLE, index);

  _gst_compile_byte (JUMP_BACK, finalJumpOfs + finalJumpLen);

  /* delete the end from the stack */
  _gst_compile_byte (POP_STACK_TOP, 0);
  SUB_STACK_DEPTH (1);
  _gst_undeclare_name ();
  return (true);
}


mst_Boolean
compile_if_true_false_statement (OOP selector,
				 tree_node expr)
{
  bc_vector trueByteCodes, falseByteCodes;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE
      || expr->v_list.next->v_list.value->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_PARAMS_OR_TEMPS (expr->v_list.value)
      || HAS_PARAMS_OR_TEMPS (expr->v_list.next->v_list.value))
    return (false);

  if (selector == _gst_if_true_if_false_symbol)
    {
      falseByteCodes =
	compile_sub_expression (expr->v_list.next->v_list.value);
      trueByteCodes =
	compile_sub_expression_and_jump (expr->v_list.value,
					 _gst_bytecode_length
					 (falseByteCodes));
    }
  else
    {
      falseByteCodes = compile_sub_expression (expr->v_list.value);
      trueByteCodes =
	compile_sub_expression_and_jump (expr->v_list.next->v_list.
					 value,
					 _gst_bytecode_length
					 (falseByteCodes));
    }

  compile_jump (_gst_bytecode_length (trueByteCodes), false);
  _gst_compile_and_free_bytecodes (trueByteCodes);
  _gst_compile_and_free_bytecodes (falseByteCodes);
  return (true);
}

mst_Boolean
compile_if_statement (OOP selector,
		      tree_node expr)
{
  bc_vector thenByteCodes;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE
      || HAS_PARAMS_OR_TEMPS (expr->v_list.value))
    return (false);

  /* The second parameter (2) is the size of a `push nil' bytecode */
  thenByteCodes =
    compile_sub_expression_and_jump (expr->v_list.value, 2);
  compile_jump (_gst_bytecode_length (thenByteCodes),
		selector == _gst_if_false_symbol);
  _gst_compile_and_free_bytecodes (thenByteCodes);

  /* Compare the code produced here with that produced in #and:/#or:
     This produces less efficient bytecodes if the condition is true
     (there are two jumps instead of one).  Actually, the push will 99% 
     of the times be followed by a pop stack top, and the optimizer
     changes 
	0: jump to 4
	2: push nil 
	4: pop stack top

     to a single pop -- so the code ends up being quite efficent. Note
     that instead the result of #and:/#or: will be used (no pop) so we
     use the other possible encoding.  */
  _gst_compile_byte (PUSH_SPECIAL, NIL_INDEX);
  return (true);
}


mst_Boolean
compile_and_or_statement (OOP selector,
			  tree_node expr)
{
  bc_vector blockByteCodes;
  int blockLen;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE
      || HAS_PARAMS_OR_TEMPS (expr->v_list.value))
    return (false);

  blockByteCodes = compile_sub_expression (expr->v_list.value);
  blockLen = _gst_bytecode_length (blockByteCodes);

  _gst_compile_byte (DUP_STACK_TOP, 0);
  compile_jump (blockLen + 2, selector == _gst_or_symbol);
  _gst_compile_byte (POP_STACK_TOP, 0);
  _gst_compile_and_free_bytecodes (blockByteCodes);
  return (true);
}



bc_vector
compile_sub_expression (tree_node expr)
{
  mst_Boolean returns;
  bc_vector current_bytecodes, subExprByteCodes;

  current_bytecodes = _gst_save_bytecode_array ();
  returns = compile_statements (expr->v_block.statements, false);
  if (returns)
    INCR_STACK_DEPTH ();

  subExprByteCodes = _gst_get_bytecodes ();
  _gst_restore_bytecode_array (current_bytecodes);

  return (subExprByteCodes);
}


bc_vector
compile_sub_expression_and_jump (tree_node expr,
				 int branchLen)
{
  bc_vector current_bytecodes, subExprByteCodes;
  mst_Boolean returns;

  current_bytecodes = _gst_save_bytecode_array ();
  returns = compile_statements (expr->v_block.statements, false);
  if (returns)
    INCR_STACK_DEPTH ();

  if (!returns)
    _gst_compile_byte (JUMP, branchLen);

  subExprByteCodes = _gst_get_bytecodes ();
  _gst_restore_bytecode_array (current_bytecodes);

  return (subExprByteCodes);
}

void
compile_jump (int len,
	      mst_Boolean jumpType)
{
  if (len <= 0)
    {
      _gst_errorf ("invalid length jump %d -- internal error\n", len);
      EXIT_COMPILATION ();
    }

  SUB_STACK_DEPTH (1);
  _gst_compile_byte (jumpType ? POP_JUMP_TRUE : POP_JUMP_FALSE, len);
}


void
compile_cascaded_message (tree_node cascadedExpr)
{
  tree_node message;

  dup_message_receiver = true;
  compile_expression (cascadedExpr->v_expr.receiver);

  for (message = cascadedExpr->v_expr.expression; message;
       message = message->v_list.next)
    {
      _gst_compile_byte (POP_STACK_TOP, 0);
      if (message->v_list.next)
	_gst_compile_byte (DUP_STACK_TOP, 0);
      else
	SUB_STACK_DEPTH (1);

      compile_expression (message->v_list.value);
      /* !!! remember that unary, binary and keywordexpr should ignore
         the receiver field if it is nil; that is the case for these
         functions and things work out fine if that's the case.  */
    }
}


void
compile_assignments (tree_node varList)
{
  symbol_entry variable;

  for (; varList; varList = varList->v_list.next)
    {
      tree_node varName = varList->v_list.value;

      _gst_line_number (varList->location.first_line, 0);
      if (!_gst_find_variable (&variable, varName))
	{
          if (varName->v_list.next)
            _gst_errorf_at (varName->location.first_line,
			    "invalid scope resolution");
          else
            _gst_errorf_at (varName->location.first_line,
    	    		    "assignment to undeclared variable %s",
		            varName->v_list.name);
	  EXIT_COMPILATION ();
	}

      if (variable.readOnly)
	{
	  _gst_errorf_at (varName->location.first_line,
                          "invalid assignment to %s %s",
		          _gst_get_scope_kind (variable.scope),
		          varName->v_list.name);

	  EXIT_COMPILATION ();
	}

      /* Here we have several kinds of things to store: receiver
         variable, temporary variable, global variable (reference by 
         association).  */

      if (variable.scope != SCOPE_GLOBAL && varName->v_list.next)
        {
          _gst_errorf_at (varName->location.first_line,
                          "invalid scope resolution");
          EXIT_COMPILATION ();
        }

      if (variable.scopeDistance > 0)
	_gst_compile_byte (STORE_OUTER_TEMP, (variable.varIndex << 8) | variable.scopeDistance);

      else if (variable.scope == SCOPE_TEMPORARY)
	_gst_compile_byte (STORE_TEMPORARY_VARIABLE, variable.varIndex);

      else if (variable.scope == SCOPE_RECEIVER)
	_gst_compile_byte (STORE_RECEIVER_VARIABLE, variable.varIndex);

      else
	{
	  /* This can become a message send, which might not return the
	     value.  Compile it in a way that can be easily peephole
	     optimized. */
	  _gst_compile_byte (STORE_LIT_VARIABLE, variable.varIndex);
	  _gst_compile_byte (POP_STACK_TOP, 0);
	  _gst_compile_byte (PUSH_LIT_VARIABLE, variable.varIndex);
	}
    }
}



mst_Boolean
is_super (tree_node expr)
{
  return (expr->nodeType == TREE_VARIABLE_NODE
	  && _gst_intern_string (expr->v_list.name) ==
	  _gst_super_symbol);
}


mst_Boolean
equal_constant (OOP oop,
		tree_node constExpr)
{
  tree_node arrayElt;
  size_t len, i;

  /* ??? this kind of special casing of the elements of arrays bothers
     me...it should all be in one neat place.  */
  if (constExpr->nodeType == TREE_SYMBOL_NODE)	/* symbol in array
						   constant */
    return (oop == constExpr->v_expr.selector);

  else if (constExpr->nodeType == TREE_ARRAY_ELT_LIST)
    {
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_array_class)
	{
	  for (len = 0, arrayElt = constExpr; arrayElt;
	       len++, arrayElt = arrayElt->v_list.next);

	  if (len == NUM_OOPS (OOP_TO_OBJ (oop)))
	    {
	      for (i = 1, arrayElt = constExpr; i <= len;
		   i++, arrayElt = arrayElt->v_list.next)
		{
		  if (!equal_constant
		      (ARRAY_AT (oop, i), arrayElt->v_list.value))
		    return (false);
		}
	      return (true);
	    }
	}
      return (false);
    }


  switch (constExpr->v_const.constType)
    {
    case CONST_INT:
      if (oop == FROM_INT (constExpr->v_const.val.iVal))
	return (true);
      break;

    case CONST_CHAR:
      if (IS_OOP (oop) && is_a_kind_of (OOP_CLASS (oop), _gst_char_class)
	  && CHAR_OOP_VALUE (oop) == constExpr->v_const.val.iVal)
	return (true);
      break;

    case CONST_FLOATD:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_floatd_class)
	{
	  double d = (double) constExpr->v_const.val.fVal;
	  if (!memcmp (&d, &OOP_TO_OBJ (oop)->data, sizeof (double)))
	    return (true);
	}
      break;

    case CONST_FLOATE:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_floate_class)
	{
	  float f = (float) constExpr->v_const.val.fVal;
	  if (!memcmp (&f, &OOP_TO_OBJ (oop)->data, sizeof (float)))
	    return (true);
	}
      break;

    case CONST_FLOATQ:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_floatq_class)
	{
	  long double ld = (long double) constExpr->v_const.val.fVal;
	  if (!memcmp (&ld, &OOP_TO_OBJ (oop)->data, sizeof (long double)))
	    return (true);
	}
      break;

    case CONST_STRING:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_string_class)
	{
	  len = strlen (constExpr->v_const.val.sVal);
	  if (len == _gst_string_oop_len (oop))
	    {
	      if (strncmp
		  ((char *) OOP_TO_OBJ (oop)->data,
		   constExpr->v_const.val.sVal, len) == 0)
		return (true);
	    }
	}
      break;

    case CONST_DEFERRED_BINDING:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_deferred_variable_binding_class)
	{
	  gst_deferred_variable_binding binding =
	    (gst_deferred_variable_binding) OOP_TO_OBJ (oop);
	  gst_object path = OOP_TO_OBJ (binding->path);
	  int i, size = NUM_OOPS (path);
	  OOP *pKey;
	  tree_node varNode = constExpr->v_const.val.aVal;

	  /* Use <= because we test the key first.  */
	  for (i = 0, pKey = &binding->key; i <= size; pKey = &path->data[i++])
	    {
	      if (!varNode
		  || *pKey != _gst_intern_string (varNode->v_list.name))
		return (false);

	      varNode = varNode->v_list.next;
	      pKey = &path->data[i];
	    }
	}
      break;

    case CONST_BINDING:
      constExpr = _gst_find_variable_binding (constExpr->v_const.val.aVal);
      if (!constExpr)
	return (false);

      assert (constExpr->v_const.constType != CONST_BINDING);
      return equal_constant (oop, constExpr);

    case CONST_OOP:
      if (oop == constExpr->v_const.val.oopVal)
	return (true);
      break;

    case CONST_ARRAY:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_array_class)
	{
	  /* ??? could keep the length in a counter */
	  for (len = 0, arrayElt = constExpr->v_const.val.aVal;
	       arrayElt; len++, arrayElt = arrayElt->v_list.next);
	  if (len == NUM_OOPS (OOP_TO_OBJ (oop)))
	    {
	      for (i = 1, arrayElt = constExpr->v_const.val.aVal;
		   i <= len; i++, arrayElt = arrayElt->v_list.next)
		{
		  if (!equal_constant
		      (ARRAY_AT (oop, i), arrayElt->v_list.value))
		    return (false);
		}
	      return (true);
	    }
	}
      break;

    default:
      break;
    }

  return (false);
}

OOP
_gst_make_constant_oop (tree_node constExpr)
{
  tree_node subexpr;
  int len, i;
  OOP resultOOP, elementOOP;
  inc_ptr incPtr;
  byte_object bo;
  gst_object result;

  if (constExpr == NULL)
    return (_gst_nil_oop);	/* special case empty array literals */

  if (constExpr->nodeType == TREE_SYMBOL_NODE)	/* symbol in array
						   constant */
    return (constExpr->v_expr.selector);

  else if (constExpr->nodeType == TREE_ARRAY_ELT_LIST)
    {
      for (len = 0, subexpr = constExpr; subexpr;
	   len++, subexpr = subexpr->v_list.next);

      incPtr = INC_SAVE_POINTER ();

      /* this might be an uninitialized form of array creation for
         speed; but not now -- with the array temporarily part of the
         root set it must be completely initialized (sigh).  */
      instantiate_with (_gst_array_class, len, &resultOOP);
      INC_ADD_OOP (resultOOP);

      for (i = 0, subexpr = constExpr; i < len;
	   i++, subexpr = subexpr->v_list.next)
	{
	  elementOOP = _gst_make_constant_oop (subexpr->v_list.value);
	  result = OOP_TO_OBJ (resultOOP);
	  result->data[i] = elementOOP;
	}
      MAKE_OOP_READONLY (resultOOP, true);
      INC_RESTORE_POINTER (incPtr);
      return (resultOOP);
    }

  switch (constExpr->v_const.constType)
    {
    case CONST_INT:
      return (FROM_INT (constExpr->v_const.val.iVal));

    case CONST_CHAR:
      return (char_new (constExpr->v_const.val.iVal));

    case CONST_FLOATD:
      return (floatd_new (constExpr->v_const.val.fVal));

    case CONST_FLOATE:
      return (floate_new (constExpr->v_const.val.fVal));

    case CONST_FLOATQ:
      return (floatq_new (constExpr->v_const.val.fVal));

    case CONST_STRING:
      resultOOP = _gst_string_new (constExpr->v_const.val.sVal);
      MAKE_OOP_READONLY (resultOOP, true);
      return (resultOOP);

    case CONST_BYTE_OBJECT:
      bo = constExpr->v_const.val.boVal;
      result = instantiate_with (bo->class, bo->size, &resultOOP);
      memcpy (result->data, bo->body, bo->size);
      MAKE_OOP_READONLY (resultOOP, true);
      return (resultOOP);

    case CONST_DEFERRED_BINDING:
      {
	gst_deferred_variable_binding dvb;
	tree_node varNode = constExpr->v_const.val.aVal;

        incPtr = INC_SAVE_POINTER ();
        dvb = (gst_deferred_variable_binding)
	  instantiate (_gst_deferred_variable_binding_class, &resultOOP);
        INC_ADD_OOP (resultOOP);

	dvb->key = _gst_intern_string (varNode->v_list.name);
	dvb->class = _gst_this_class;
	dvb->defaultDictionary = _gst_get_undeclared_dictionary ();
	dvb->association = _gst_nil_oop;

	varNode = varNode->v_list.next;
	if (varNode)
	  {
	    int i, size = list_length (varNode);
	    OOP arrayOOP;
	    gst_object array =
	      instantiate_with (_gst_array_class, size, &arrayOOP);

	    dvb->path = arrayOOP;
	    for (i = 0; i < size; i++, varNode = varNode->v_list.next)
	      array->data[i] = _gst_intern_string (varNode->v_list.name);
	  }

        return (resultOOP);
      }

    case CONST_BINDING:
      subexpr = _gst_find_variable_binding (constExpr->v_const.val.aVal);
      if (!subexpr)
	{
	  _gst_errorf_at (constExpr->location.first_line,
			  "invalid variable binding");
          EXIT_COMPILATION ();
	}

      assert (subexpr->v_const.constType != CONST_BINDING);
      return _gst_make_constant_oop (subexpr);

    case CONST_OOP:
      return (constExpr->v_const.val.oopVal);

    case CONST_ARRAY:
      for (len = 0, subexpr = constExpr->v_const.val.aVal; subexpr;
	   len++, subexpr = subexpr->v_list.next);

      incPtr = INC_SAVE_POINTER ();
      result = instantiate_with (_gst_array_class, len, &resultOOP);
      INC_ADD_OOP (resultOOP);

      for (i = 0, subexpr = constExpr->v_const.val.aVal; i < len;
	   i++, subexpr = subexpr->v_list.next)
	{
	  elementOOP = _gst_make_constant_oop (subexpr->v_list.value);
	  result = OOP_TO_OBJ (resultOOP);
	  result->data[i] = elementOOP;
	}

      MAKE_OOP_READONLY (resultOOP, true);
      INC_RESTORE_POINTER (incPtr);
      return (resultOOP);
    }

  return (_gst_nil_oop);
}

OOP
make_block (int args,
	    int temps,
	    bc_vector bytecodes,
	    int stack_depth)
{
  OOP blockOOP;

  if (_gst_declare_tracing)
    {
      printf ("  Code for enclosed block:\n");
#ifdef PRINT_BEFORE_OPTIMIZATION
      _gst_print_bytecodes (bytecodes, literal_vec);
#endif
    }
  bytecodes = _gst_optimize_bytecodes (bytecodes);

  if (_gst_declare_tracing)
    _gst_print_bytecodes (bytecodes, literal_vec);

  blockOOP =
    _gst_block_new (args, temps, bytecodes, stack_depth, literal_vec);

  _gst_free_bytecodes (bytecodes);
  return (blockOOP);
}

OOP
make_clean_block_closure (OOP blockOOP)
{
  gst_block_closure closure;
  OOP closureOOP;

  closure = (gst_block_closure) new_instance (_gst_block_closure_class, 
					      &closureOOP);

  /* Use the class as the receiver.  This is blatantly wrong, but
     at least sets the correct trustfulness on the contexts.  If the
     receiver was nil, for example, untrusted clean blocks evaluated
     from a trusted environment would be treated as trusted (because
     nil is trusted).  */
  closure->receiver = _gst_this_class;
  closure->outerContext = _gst_nil_oop;
  closure->block = blockOOP;

  return (closureOOP);
}

OOP
compute_selector (tree_node selectorExpr)
{
  if (selectorExpr->nodeType == TREE_UNARY_EXPR
      || selectorExpr->nodeType == TREE_BINARY_EXPR)
    return (selectorExpr->v_expr.selector);
  else
    return (_gst_compute_keyword_selector (selectorExpr->v_expr.expression));
}

OOP
_gst_compute_keyword_selector (tree_node keywordList)
{
  tree_node keyword;
  int len;
  char *nameBuf, *p;

  len = 0;
  for (keyword = keywordList; keyword != NULL;
       keyword = keyword->v_list.next)
    len += strlen (keyword->v_list.name);

  p = nameBuf = (char *) alloca (len + 1);
  for (keyword = keywordList; keyword != NULL;
       keyword = keyword->v_list.next)
    {
      len = strlen (keyword->v_list.name);
      strcpy (p, keyword->v_list.name);
      p += len;
    }

  *p = '\0';

  return (_gst_intern_string (nameBuf));
}


OOP
_gst_make_attribute (tree_node attribute_keywords)
{
  tree_node keyword;
  OOP selectorOOP, argsArrayOOP, messageOOP;
  gst_object argsArray;
  int i, numArgs;
  inc_ptr incPtr;

  incPtr = INC_SAVE_POINTER ();
  
  if (_gst_had_error)
    return _gst_nil_oop;

  selectorOOP = _gst_compute_keyword_selector (attribute_keywords);
  numArgs = list_length (attribute_keywords);
  argsArray = instantiate_with (_gst_array_class, numArgs, &argsArrayOOP);
  INC_ADD_OOP (argsArrayOOP);

  for (i = 0, keyword = attribute_keywords; keyword != NULL;
       i++, keyword = keyword->v_list.next)
    {
      tree_node value = keyword->v_list.value;
      OOP result;
      if (value->nodeType != TREE_CONST_EXPR)
	{
          result = _gst_execute_statements (NULL, value, UNDECLARED_NONE, true);
          if (!result)
	    {
	      _gst_had_error = true;
	      return _gst_nil_oop;
	    }
	}
      else
	result = _gst_make_constant_oop (value);

      argsArray = OOP_TO_OBJ (argsArrayOOP);
      argsArray->data[i] = result;
    }

  messageOOP = _gst_message_new_args (selectorOOP, argsArrayOOP);
  INC_RESTORE_POINTER (incPtr);

  MAKE_OOP_READONLY (argsArrayOOP, true);
  MAKE_OOP_READONLY (messageOOP, true);
  return (messageOOP);
}


int
process_attributes_tree (tree_node attribute_list)
{
  int primitiveIndex = 0;

  for (; attribute_list; attribute_list = attribute_list->v_list.next)
    {
      tree_node value = attribute_list->v_list.value;
      OOP messageOOP = value->v_const.val.oopVal;
      int result = process_attribute (messageOOP);

      if (result < 0)
	{
	  EXIT_COMPILATION ();
	}

      if (result > 0)
	{
          if (IS_OOP_UNTRUSTED (_gst_this_class))
	    {
	      _gst_errorf ("an untrusted class cannot declare primitives");
	      EXIT_COMPILATION ();
	    }

	  if (primitiveIndex > 0)
	    {
	      _gst_errorf ("duplicate primitive declaration");
	      EXIT_COMPILATION ();
	    }
	  primitiveIndex = result;
	}
    }

  return primitiveIndex;
}

int
_gst_process_attributes_array (OOP arrayOOP)
{
  int primitiveIndex = 0;
  int n = NUM_WORDS (OOP_TO_OBJ (arrayOOP));
  int i;

  if (IS_NIL (arrayOOP))
    return 0;

  for (i = 0; i < n; i++)
    {
      OOP messageOOP = OOP_TO_OBJ (arrayOOP)->data[i];
      int result = process_attribute (messageOOP);

      if (result < 0)
	return (-1);

      if (result > 0)
	{
	  if (primitiveIndex > 0)
	    return (-1);

	  primitiveIndex = result;
	}
    }

  return primitiveIndex;
}

int
process_attribute (OOP messageOOP)
{
  gst_message message = (gst_message) OOP_TO_OBJ (messageOOP);
  OOP selectorOOP = message->selector;
  OOP argumentsOOP = message->args;
  gst_object arguments = OOP_TO_OBJ (argumentsOOP);

  if (selectorOOP == _gst_primitive_symbol)
    {
      if (IS_INT (arguments->data[0]))
	{
	  int primitiveIndex = TO_INT (arguments->data[0]);
	  if (primitiveIndex <= 0 || primitiveIndex >= NUM_PRIMITIVES)
	    {
	      _gst_errorf ("primitive number out of range");
	      return (-1);
	    }

          return (primitiveIndex);
	}
      else
	{
	  _gst_errorf ("bad primitive number, expected SmallInteger");
	  return (-1);
	}
    }
  else if (selectorOOP == _gst_category_symbol)
    {
      this_method_category = arguments->data[0];
      return (0);
    }
  else
    {
      method_attributes *new_attr = (method_attributes *)
        xmalloc (sizeof (method_attributes));

      new_attr->count = method_attrs ? method_attrs->count + 1 : 0;
      new_attr->oop = messageOOP;
      new_attr->next = method_attrs;
      method_attrs = new_attr;

      _gst_register_oop (messageOOP);
      return (0);
    }
}

void
realloc_literal_vec (void)
{
  int size;
  ptrdiff_t delta;

  size = literal_vec_max - literal_vec + LITERAL_VEC_CHUNK_SIZE;
  delta = ((OOP *) xrealloc (literal_vec, size * sizeof (OOP))) - literal_vec;

  literal_vec += delta;
  literal_vec_curr += delta;
  literal_vec_max = literal_vec + size;
}


int
list_length (tree_node listExpr)
{
  tree_node l;
  long len;

  for (len = 0, l = listExpr; l; l = l->v_list.next, len++);

  if (sizeof (int) < sizeof (long) && len > INT_MAX)
    {
      _gst_errorf ("list too long, %ld", len);
      len = INT_MAX;
    }

  return ((int) len);
}



/***********************************************************************
 *
 *	Literal Vector manipulation routines.
 *
 ***********************************************************************/


int
add_literal (OOP oop)
{
  if (literal_vec_curr >= literal_vec_max)
    realloc_literal_vec ();

  *literal_vec_curr++ = oop;
  return (literal_vec_curr - literal_vec - 1);
}

int
_gst_add_forced_object (OOP oop)
{
  OOP *lit;

  for (lit = literal_vec; lit < literal_vec_curr; lit++)
    if (*lit == oop)
      return (lit - literal_vec);

  return (add_literal (oop));
}

OOP
get_literals_array (void)
{
  OOP methodLiteralsOOP;
  gst_object methodLiterals;

  assert (literal_vec_curr > literal_vec);

  methodLiterals = new_instance_with (_gst_array_class, 
				      literal_vec_curr - literal_vec,
		                      &methodLiteralsOOP);

  memcpy (methodLiterals->data, literal_vec, 
	  (literal_vec_curr - literal_vec) * sizeof(OOP));

  literal_vec_curr = literal_vec;

  MAKE_OOP_READONLY (methodLiteralsOOP, true);
  return (methodLiteralsOOP);
}


void
install_method (OOP methodOOP)
{
  OOP oldMethod, selector, methodDictionaryOOP;
  gst_compiled_method method;
  gst_method_info descriptor;
  int num_attrs, i;

  method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
  descriptor = (gst_method_info) OOP_TO_OBJ (method->descriptor);
  num_attrs = NUM_INDEXABLE_FIELDS (method->descriptor);

  for (i = 0; i < num_attrs; i++)
    {
      char *result;
      OOP attributeOOP = descriptor->attributes[i];
      gst_message attribute = (gst_message) OOP_TO_OBJ (attributeOOP);
      OOP handlerBlockOOP = _gst_find_pragma_handler (_gst_this_class,
						      attribute->selector);

      if (!IS_NIL (handlerBlockOOP))
	{
	  _gst_msg_sendf (&result, "%s %o value: %o value: %o",
			  handlerBlockOOP, methodOOP, attributeOOP);
	  if (result != NULL)
	    {
	      _gst_errorf ("%s", result);
	      EXIT_COMPILATION ();
	    }
	}

      method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
      descriptor = (gst_method_info) OOP_TO_OBJ (method->descriptor);
      if (num_attrs != NUM_INDEXABLE_FIELDS (method->descriptor))
	{
	  _gst_errorf ("cannot modify method descriptor in pragma handler");
	  EXIT_COMPILATION ();
	}
    }

  selector = descriptor->selector;

  /* methodDictionaryOOP is held onto by the class, which is already
     reachable by the root set so we don't need to hold onto it
     here.  */
  methodDictionaryOOP =
    _gst_valid_class_method_dictionary (_gst_this_class);

  if (_gst_untrusted_methods)
    {
      oldMethod = _gst_identity_dictionary_at (methodDictionaryOOP,
					       selector);
      if (!IS_NIL (oldMethod) && !IS_OOP_UNTRUSTED (oldMethod))
	{
	  _gst_errorf ("cannot redefine a trusted method as untrusted");
	  EXIT_COMPILATION ();
	}
    }

  MAKE_OOP_READONLY (methodOOP, true);
  oldMethod = _gst_identity_dictionary_at_put (methodDictionaryOOP,
					       selector, methodOOP);

#ifdef ENABLE_JIT_TRANSLATION
  if (oldMethod != _gst_nil_oop)
    _gst_discard_native_code (oldMethod);
#endif

#ifdef VERIFY_COMPILED_METHODS
  _gst_verify_sent_method (methodOOP);
#endif
  _gst_invalidate_method_cache ();
}

OOP
_gst_make_new_method (int primitiveIndex,
		      int numArgs,
		      int numTemps,
		      int maximumStackDepth,
		      OOP literals,
		      bc_vector bytecodes,
		      OOP class,
		      OOP selector,
		      OOP defaultCategoryOOP,
		      int64_t startPos,
		      int64_t endPos)
{
  method_header header;
  int newFlags;
  OOP method, methodDesc, sourceCode, category;
  inc_ptr incPtr;

  maximumStackDepth += numArgs + numTemps;
  memset (&header, 0, sizeof (method_header));

  incPtr = INC_SAVE_POINTER ();
  if (primitiveIndex)
    {
      if (_gst_declare_tracing)
	printf ("  Primitive Index %d\n", primitiveIndex);

      header.headerFlag = MTH_PRIMITIVE;
    }

  else if (method_attrs)
    header.headerFlag = MTH_ANNOTATED;

  /* if returning a literal, we must either use comp.c's literal pool
     (IS_NIL (LITERALS)), get it from a preexisting literal pool
     (LITERAL_VEC_CURR == LITERAL_VEC), or put it into an empty
     pool (NUM_WORDS (...) == 0).  */
  else if (numArgs == 0
	   && numTemps == 0
	   && (newFlags = _gst_is_simple_return (bytecodes)) != 0
	   && (newFlags != MTH_RETURN_LITERAL
	       || IS_NIL (literals)
      	       || NUM_WORDS (OOP_TO_OBJ (literals)) == 0
               || literal_vec_curr == literal_vec))
    {
      header.headerFlag = newFlags & 0xFF;
      /* if returning an instance variable, its index is indicated in
         the primitive index */
      primitiveIndex = newFlags >> 8;
      numTemps = 0;

      _gst_free_bytecodes (bytecodes);
      bytecodes = NULL;

      /* If returning a literal but we have none, it was added with
         _gst_add_forced_object.  */
    }

  else
    header.headerFlag = MTH_NORMAL;

  if (literal_vec_curr > literal_vec)
    {
      literals = get_literals_array ();
      literal_vec_curr = literal_vec;
      INC_ADD_OOP (literals);
    }

  if (bytecodes)
    {
#ifdef PRINT_BEFORE_OPTIMIZATION
      if (_gst_declare_tracing)
	_gst_print_bytecodes (bytecodes, OOP_TO_OBJ (literals)->data);
#endif
      bytecodes = _gst_optimize_bytecodes (bytecodes);
    }

  if (_gst_declare_tracing)
    printf ("  Allocated stack slots %d\n", maximumStackDepth);

  if (_gst_declare_tracing)
    _gst_print_bytecodes (bytecodes, OOP_TO_OBJ (literals)->data);

  maximumStackDepth += (1 << DEPTH_SCALE) - 1;	/* round */
  maximumStackDepth >>= DEPTH_SCALE;
  maximumStackDepth++;		/* just to be sure */

  header.stack_depth = maximumStackDepth;
  header.primitiveIndex = primitiveIndex;
  header.numArgs = numArgs;
  header.numTemps = numTemps;
  header.intMark = 1;

  if (this_method_category)
    {
      category = this_method_category;
      this_method_category = NULL;
    }
  else
    category = defaultCategoryOOP;

  if (IS_NIL (class))
    sourceCode = _gst_nil_oop;
  else
    {
      sourceCode = _gst_get_source_string (startPos, endPos);
      INC_ADD_OOP (sourceCode);
    }

  methodDesc = method_info_new (class, selector, method_attrs,
				sourceCode, category);
  INC_ADD_OOP (methodDesc);

  method = method_new (header, literals, bytecodes, class, methodDesc);
  INC_RESTORE_POINTER (incPtr);
  return (method);
}

OOP
method_new (method_header header,
	    OOP literals,
	    bc_vector bytecodes,
	    OOP class,
	    OOP methodDesc)
{
  int numByteCodes;
  gst_compiled_method method;
  OOP methodOOP;
  gst_object lit;
  int i;

  if (bytecodes != NULL)
    numByteCodes = _gst_bytecode_length (bytecodes);
  else
    numByteCodes = 0;

  method_attrs = NULL;

  method = (gst_compiled_method) instantiate_with (_gst_compiled_method_class,
						   numByteCodes, &methodOOP);

  MAKE_OOP_UNTRUSTED (methodOOP,
		      _gst_untrusted_methods
		      || IS_OOP_UNTRUSTED (_gst_this_context_oop)
		      || IS_OOP_UNTRUSTED (class));

  method->header = header;
  method->descriptor = methodDesc;
  method->literals = literals;

  for (lit = OOP_TO_OBJ (literals), i = NUM_OOPS (lit); i--;)
    {
      OOP blockOOP;
      gst_compiled_block block;
      if (IS_CLASS (lit->data[i], _gst_block_closure_class))
	{
	  gst_block_closure bc;
	  bc = (gst_block_closure) OOP_TO_OBJ (lit->data[i]);
          blockOOP = bc->block;
	}
      else if (IS_CLASS (lit->data[i], _gst_compiled_block_class))
	blockOOP = lit->data[i];
      else
	continue;

      block = (gst_compiled_block) OOP_TO_OBJ (blockOOP);
      if (IS_NIL (block->method))
	{
	  MAKE_OOP_UNTRUSTED (blockOOP, IS_OOP_UNTRUSTED (methodOOP));
	  block->method = methodOOP;
	  block->literals = literals;
	}
    }

  if (bytecodes != NULL)
    {
      _gst_copy_bytecodes (method->bytecodes, bytecodes);
      _gst_free_bytecodes (bytecodes);
    }

  return (methodOOP);
}

OOP
_gst_block_new (int numArgs,
		int numTemps,
		bc_vector bytecodes,
		int maximumStackDepth,
		OOP * literals)
{
  int numByteCodes;
  OOP blockOOP;
  gst_compiled_block block;
  block_header header;

  maximumStackDepth += numArgs + numTemps;
  maximumStackDepth += (1 << DEPTH_SCALE) - 1;	/* round */
  maximumStackDepth >>= DEPTH_SCALE;
  maximumStackDepth++;		/* just to be sure */

  numByteCodes = _gst_bytecode_length (bytecodes);

  memset (&header, 0, sizeof (header));
  header.numArgs = numArgs;
  header.numTemps = numTemps;
  header.depth = maximumStackDepth;
  header.intMark = 1;
  header.clean = _gst_check_kind_of_block (bytecodes, literals);

  block = (gst_compiled_block) instantiate_with (_gst_compiled_block_class, 
						 numByteCodes, &blockOOP);

  block->header = header;
  block->method = block->literals = _gst_nil_oop;
  _gst_copy_bytecodes (block->bytecodes, bytecodes);

  MAKE_OOP_READONLY (blockOOP, true);

  return (blockOOP);
}

OOP
method_info_new (OOP class,
		 OOP selector,
		 method_attributes *attrs,
		 OOP sourceCode,
		 OOP categoryOOP)
{
  method_attributes *next;
  gst_method_info methodInfo;
  OOP methodInfoOOP;

  methodInfo =
    (gst_method_info) new_instance_with (_gst_method_info_class,
					 attrs ? attrs->count + 1 : 0,
					 &methodInfoOOP);

  methodInfo->sourceCode = sourceCode;
  methodInfo->category = categoryOOP;
  methodInfo->class = class;
  methodInfo->selector = selector;

  while (attrs)
    {
      methodInfo->attributes[attrs->count] = attrs->oop;
      next = attrs->next;
      _gst_unregister_oop (attrs->oop);
      free (attrs);
      attrs = next;
    }
			     
  return (methodInfoOOP);
}

