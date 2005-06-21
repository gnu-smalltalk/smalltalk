/******************************** -*- C -*- ****************************
 *
 *	Byte code compiler.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003
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

#include "gstpriv.h"

/* Define this if you want declaration tracing to print the bytecodes
   both *before* and *after* the optimizer is ran.  Default behavior
   is to print the bytecodes only after the optimization pass; usually
   it is only needed to debug the optimizer -- when debugging the
   compiler you should turn off optimization entirely (see NO_OPTIMIZE
   in opt.c). */
/* #define PRINT_BEFORE_OPTIMIZATION */


#define LITERAL_VEC_CHUNK_SIZE		32


typedef enum
{
  JUMP_FALSE,
  JUMP_TRUE,
  JUMP_UNCONDITIONAL
}
jump_type;

typedef struct gst_file_segment
{
  OBJ_HEADER;
  OOP fileName;
  OOP startPos;
  OOP length;
}
 *gst_file_segment;


/* These hold the compiler's notions of the current class for
   compilations, and the current category that compiled methods are to
   be placed into */
OOP _gst_this_class, _gst_this_category;

/* This holds the gst_compiled_method oop for the most recently
   compiled method.  It is only really valid after a compile: has been
   done, but this is the only place that its used. */
OOP _gst_latest_compiled_method;

/* This flag controls whether byte codes are printed after
   compilation. */
mst_Boolean _gst_declare_tracing;

/* If true, the compilation of a set of methods will be skipped
   completely; only syntax will be checked.  Set by primitive, cleared
   by grammar. */
mst_Boolean _gst_skip_compilation = false;

/* This is the value most recently returned by
   _gst_execute_statements.  It is used to communicate the returned
   value past a _gst_parse_stream call, without pushing something on
   the called context stack in the case of nested invocations of
   _gst_prepare_execution_environment/_gst_finish_execution_environment.
   Most often, the caller does not care about the returned value,
   since it often is called from a radically different context. */
OOP _gst_last_returned_value;

/* This is set to true by the parser or the compiler if an error
   (respectively, a parse error or a semantic error) is found, and
   avoids that _gst_execute_statements tries to execute the result of
   the compilation. */
mst_Boolean _gst_had_error = false;



/* Returns true if EXPR represents the symbol "super"; false if not. */
static mst_Boolean is_super (tree_node expr);

/* Returns true if OOP and CONSTEXPR represent the same literal value.
   Primarily used by the compiler to store a single copy of duplicated
   literals in a method.  Can call itself in the case array
   literals. */
static mst_Boolean equal_constant (OOP oop,
				   tree_node constExpr);


/* Special case compilation of a #timesRepeat: loop.  EXPR is a node
   for the entire keyword message send.  Returns true if byte codes
   were emitted, false if not.  If the last argument to the message is
   not a block expression, this routine cannot do its job, and so
   returns false to indicate as much. */
static mst_Boolean compile_times_repeat (tree_node expr);

/* Special case compilation of a while loop whose selector is in
   SELECTOR.  EXPR is a node for the entire unary or keyword message
   send.  Returns true if byte codes were emitted, false if not.  If
   the last argument to the message is not a block expression, this
   routine cannot do its job, and so returns false to indicate as
   much. */
static mst_Boolean compile_while_loop (OOP selector,
				       tree_node expr);

/* Special case compilation of a 1-argument if (#ifTrue: or #ifFalse:)
   whose selector is in SELECTOR; the default value for the absent
   case is nil.  EXPR is a node for the entire keyword message send.
   Returns true if byte codes were emitted, false if not.  If the last
   argument to the message is not a block expression, this routine
   cannot do its job, and so returns false to indicate as much. */
static mst_Boolean compile_if_statement (OOP selector,
					 tree_node expr);

/* Special case compilation of a #to:do: (if BY is NULL) or #to:by:do:
   loop.  The starting value for the iteration is given by TO, the block
   is in BLOCK.  Returns true if byte codes were emitted, false if
   not.  If the last argument to the message is not a block expression,
   this routine cannot do its job, and so returns false to indicate as
   much. */
static mst_Boolean compile_to_by_do (tree_node to,
				     tree_node by,
				     tree_node block);

/* Special case compilation of a #and: or #or: boolean operation; very
   similar to compile_if_statement.  EXPR is a node for the entire
   keyword message send.  Returns true if byte codes were emitted,
   false if not.  If the last argument to the message is not a block
   expression, this routine cannot do its job, and so returns false to
   indicate as much. */
static mst_Boolean compile_and_or_statement (OOP selector,
					     tree_node expr);

/* Special case compilation of a 2-argument if whose selector is in
   SELECTOR.  EXPR is a node for the entire keyword message send.
   Returns true if byte codes were emitted, false if not.  If the last
   argument to the message is not a block expression, this routine
   cannot do its job, and so returns false to indicate as much. */
static mst_Boolean compile_if_true_false_statement (OOP selector,
						    tree_node expr);

/* Special case compilation of an infinite loop, given by the parse
   node in RECEIVER.  Returns true if byte codes were emitted, false
   if not.  If the last argument to the message is not a block
   expression, this routine cannot do its job, and so returns false to
   indicate as much. */
static mst_Boolean compile_repeat (tree_node receiver);

/* Compiles all of the statements in STATEMENTLIST.  If ISBLOCK is
   true, adds a final instruction of the block to return the top of
   stack, if the final statement isn't an explicit return from method
   (^).  Returns whether the last statement was a return (whatever
   the value of ISBLOCK. */
static mst_Boolean compile_statements (tree_node statementList,
				       mst_Boolean isBlock);

/* Given a tree_node of type keywordExprNode, this routine picks out
   and concatenates the keywords in SELECTOREXPR (if a
   TREE_KEYWORD_EXPR) or extracts the selector (if a TREE_UNARY_EXPR or
   TREE_BINARY_EXPR).  Then it turns them into a symbol OOP and returns
   that symbol. */
static OOP compute_selector (tree_node selectorExpr);

/* Given CONSTEXPR, a section of the syntax tree that represents a
   Smalltalk constant, this routine creates and returns an OOP to be
   stored as a method literal in the method that's currently being
   compiled. */
static OOP make_constant_oop (tree_node constExpr);

/* Creates a new Array object that contains the literals for the
   method that's being compiled and returns it.  As a side effect, the
   currently allocated working literal vector is freed.  If there were
   no literals for the current method, _gst_nil_oop is returned. */
static OOP get_literals_array (void);

/* Creates and returns a CompiledMethod.  The method is completely
   filled in, including the descriptor, the method literals, and the
   byte codes for the method. */
static OOP method_new (method_header header,
		       OOP literals,
		       bytecodes bytecodes,
		       OOP class,
		       OOP selector);

/* Returns an instance of MethodInfo.  This instance is used in the
   reconstruction of the source code for the method, and holds the
   category that the method belongs to. */
static OOP method_info_new (OOP class,
			    OOP selector);

/* Returns a FileSegment instance for the currently open compilation
   stream.  FileSegment instances are used record information useful
   in obtaining the source code for a method that's been compiled.
   Depending on whether the input stream is a string or a FileStream,
   the instance variables are different; for a string, the entire
   contents of the string is preserved as the source code for the
   method; for a disk file loaded from within the kernel source
   directory, the file name, byte offset and length are preserved. */
static OOP file_segment_new (void);

/* This create a CompiledBlock for the given BYTECODES.  The bytecodes
   are passed through the peephole optimizer and stored, the header is
   filled according to the given number of arguments ARGS and
   temporaries TEMPS, and to the cleanness of the block.  STACK_DEPTH
   contains the number of stack slots needed by the block except for
   arguments and temporaries.  */
static OOP make_block_closure (int args,
			       int temps,
			       bytecodes bytecodes,
			       int stack_depth);

/* Compiles a block tree node, EXPR, in a separate context and return
   the resulting bytecodes.  The block's argument declarations are
   ignored since they are handled by compile_to_by_do (and are absent
   for other methods like ifTrue:, and:, whileTrue:, etc.); there are
   no temporaries.  It is compiled as a list of statements such that
   the last statement leaves the value that is produced on the stack,
   as the value of the "block". */
static bytecodes compile_sub_expression (tree_node expr);

/* Like compile_sub_expression, except that after compiling EXPR this
   subexpression always ends with an unconditional branch past
   BRANCHLEN bytecodes. */
static bytecodes compile_sub_expression_and_jump (tree_node expr,
						  int branchLen);

/* Like add_constant, this routine adds "selector" to the set of
   selectors for the current method, and returns the index of that
   selector.  If the selector already existed, its index is returned.
   If the selector is a special selector, then the negative of the
   bytecode that's associated with that special selector is
   returned. */
static int add_selector (OOP selector);

/* Looks for special-cased selectors, and returns a bytecode number to
   indicate which selector was chosen.  If the selector isn't one of
   the special-cased ones, 0 is returned. */
static int which_builtin_selector (OOP selector);

/* Computes and returns the length of a parse tree list, LISTEXPR. */
static int list_length (tree_node listExpr);

/* Adds OOP to the literals associated with the method being compiled
   and returns the index of the literal slot that was used (0-based).
   Does not check for duplicates.  Automatically puts OOP in the
   incubator. */
static int add_literal (OOP oop);

/* Compiles STMT, which is a statement expression, including return
   expressions. */
static void compile_statement (tree_node stmt);

/* Compile EXPR, which is an arbitrary expression, including an
   assignment expression. */
static void compile_expression (tree_node expr);

/* The basic expression compiler.  Often called recursively,
   dispatches based on the type of EXPR to different routines that
   specialize in compilations for that expression. */
static void compile_simple_expression (tree_node expr);

/* Compile code to push the value of a variable onto the stack.  The
   special variables, self, true, false, super, and thisContext, are
   handled specially.  For other variables, different code is emitted
   depending on where the variable lives, such as in a global variable
   or in a method temporary. */
static void compile_variable (tree_node varName);

/* Compile an expression that pushes a constant expression CONSTEXPR
   onto the stack.  Special cases out the constants that the byte code
   interpreter knows about, which are the integers in the range -1 to
   2.  Tries to emit the shortest possible byte sequence. */
static void compile_constant (tree_node constExpr);

/* Compiles an instruction to push an Integer constant INTCONST on the
   stack.  Special cases out the literals -128..255, and tries to emit the
   shortest possible byte sequence to get the job done. */
static void compile_push_int_constant (int CONST_INT);

/* Compiles an unconditional long jump LEN bytes away, either forward
   or backward. */
static void compile_long_jump (int len);

/* Compiles an instruction to push the INDEX-th literal in the method
   on the stack.  Tries to emit the shortest possible byte sequence to
   get the job done. */
static void compile_push_literal (int index);

/* Compiles an instruction to push on the stack the global variable
   whose association resides in the INDEX-th slot of the method.
   Tries to emit the shortest possible byte sequence to get the job
   done. */
static void compile_push_global (int index);

/* Compile the expressions for a block whose parse tree is BLOCKEXPR.
   Also, emits code to push the BlockClosure object, and creates the
   BlockClosure together with its CompiledBlock. */
static void compile_block (tree_node blockExpr);

/* Compiles all of the statements in arrayConstructor, preceded by
   (Array new: <size of the list>) and with each statement followed
   with a <pop into instance variable of new stack top> instead of a
   simple pop. */
static void compile_array_constructor (tree_node arrayConstructor);

/* Compile code to evaluate a unary expression EXPR.  Special cases
   sends to "super". Also, checks to see if it's the first part of a
   cascaded message send and if so emits code to duplicate the stack
   top after the evaluation of the receiver for use by the subsequent
   cascaded expressions. */
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
   receiver for use by the subsequent cascaded expressions. */
static void compile_keyword_expr (tree_node expr);

/* Compile a message send byte code.  Tries to use the minimal length
   byte code sequence; does not know about the special messages that
   the interpreter has "wired in"; those should be handled specially
   and this routine should not be called with them (it's ok if it is,
   just not quite as efficient). */
static void compile_send (int selectorIndex,
			  int numArgs);

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
   sends can be derived from CASCADEDEXPR. */
static void compile_cascaded_message (tree_node cascadedExpr);

/* Compiles all the assignments in VARLIST, which is a tree_node of
   type listNode.  The generated code assumes that the value on the
   top of the stack is what's to be used for the assignment.  Since
   this routine has no notion of now the value on top of the stack
   will be used by the calling environment, it makes sure that when
   the assignments are through, that the value on top of the stack
   after the assignment is the same as the value on top of the stack
   before the assignment.  The optimizer should fix this in the
   unnecessary cases. */
static void compile_assignments (tree_node varList);

/* Compiles a forward jump instruction LEN bytes away (LEN must be >
   0), using the smallest possible number of bytecodes.  JUMPTYPE
   indicates which among the unconditional, "jump if true" and "jump
   if false" opcodes is desired.  Special cases for the short
   unconditional jump and the short false jump that the byte code
   interpreter handles. */
static void compile_jump (int len,
			  jump_type jumpType);

/* Emit code to evaluate each argument to a keyword message send,
   taking them from the parse tree node LIST. */
static void compile_keyword_list (tree_node list);

/* Called to grow the literal vector that the compiler is using.  Modifies
   the global variables LITERAL_VEC and LITERAL_VEC_MAX to reflect the
   growth.  */
static void realloc_literal_vec (void);

/* Takes a new CompiledMethod METHODOOP and installs it in the method
   dictionary for the current class.  If the current class does not
   contain a valid method dictionary, one is allocated for it. */
static void install_method (OOP methodOOP);

/* This caches the OOP of the special UndefinedObject>>#__terminate
   method, which is executed by contexts created with
   _gst_prepare_execution_environment. */
static OOP termination_method;

/* Used to number the lines starting from 1.  */
static int line_offset;

/* Used to abort really losing compiles, jumps back to the top level
   of the compiler */
static jmp_buf bad_method;

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
   passing useless parameters around all the time. */
static mst_Boolean dup_message_receiver = false;


/* Exit a really losing compilation */
#define EXIT_COMPILATION()						\
	longjmp(bad_method, 1)

/* Compute bits 6-7 of the multipurpose 2-byte bytecodes from the
   scope information that sym.c saves. */
#define COMPUTE_LOCATION_INDEX(variable) \
  ((variable.scope == SCOPE_RECEIVER) ? RECEIVER_LOCATION : \
    ((variable.scope == SCOPE_TEMPORARY) ? TEMPORARY_LOCATION : LIT_VAR_LOCATION))

/* Answer whether the BLOCKNODE parse node has temporaries or
   arguments. */
#define HAS_PARAMS_OR_TEMPS(blockNode) \
  (blockNode->v_block.temporaries || blockNode->v_block.arguments)

/* Answer whether the BLOCKNODE parse node has temporaries and
   has not exactly one argument. */
#define HAS_NOT_ONE_PARAM_OR_TEMPS(blockNode)		\
  (blockNode->v_block.temporaries			\
   || !blockNode->v_block.arguments			\
   || blockNode->v_block.arguments->v_list.next)


void
_gst_install_initial_methods (void)
{
  char *methodsForString;

  methodsForString = "\
methodsFor: aCategoryString \
    \"Calling this method prepares the parser to receive methods \
      to be compiled and installed in the receiver's method dictionary. \
      The methods are put in the category identified by the parameter.\" \
    <primitive: VMpr_Behavior_methodsFor> \
";
  _gst_compile_code = true;	/* tell the lexer we do internal
				   compiles */

  _gst_set_compilation_class (_gst_behavior_class);
  _gst_set_compilation_category (_gst_string_new ("compiling methods"));
  _gst_push_smalltalk_string (_gst_string_new (methodsForString));
  _gst_parse_stream ();
  _gst_pop_stream (true);

  _gst_set_compilation_class (_gst_undefined_object_class);
  _gst_set_compilation_category (_gst_string_new ("private"));
  _gst_alloc_bytecodes ();
  _gst_compile_byte (EXIT_INTERPRETER);
  _gst_compile_byte (RETURN_CONTEXT_STACK_TOP);

  /* The zeros are primitive, # of args, # of temps, stack depth */
  termination_method = _gst_make_new_method (0, 0, 0, 0, NULL,
					     _gst_get_bytecodes (),
					     _gst_this_class,
					     _gst_terminate_symbol);

  install_method (termination_method);
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

void
_gst_invoke_hook (char *hook)
{
  int save_execution;
  save_execution = _gst_execution_tracing;
  _gst_execution_tracing = _gst_trace_kernel_execution;
  _gst_msg_sendf (NULL, "%v %o changed: %S", 
		  _gst_object_memory_class, hook);
  _gst_execution_tracing = save_execution;
}

void
_gst_init_compiler (void)
{
  /* Prepare the literal vector for use.  The literal vector is where the
     compiler will store any literals that are used by the method being
     compiled. */
  literal_vec = (OOP *) xmalloc (LITERAL_VEC_CHUNK_SIZE * sizeof (OOP));

  literal_vec_curr = literal_vec;
  literal_vec_max = literal_vec + LITERAL_VEC_CHUNK_SIZE;

  _gst_register_oop_array (&literal_vec, &literal_vec_curr);
  _gst_set_compilation_class (_gst_undefined_object_class);
  _gst_set_compilation_category (_gst_nil_oop);
}

void
_gst_set_compilation_class (OOP class_oop)
{
  _gst_unregister_oop (_gst_this_class);
  _gst_this_class = class_oop;
  _gst_register_oop (_gst_this_class);
}

void
_gst_set_compilation_category (OOP categoryOOP)
{
  _gst_unregister_oop (_gst_this_category);
  _gst_this_category = categoryOOP;
  _gst_register_oop (_gst_this_category);
}



void
_gst_display_compilation_trace (char *string,
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
_gst_execute_statements (tree_node temporaries,
			 tree_node statements,
			 mst_Boolean quiet)
{
  tree_node messagePattern;
  unsigned long startTime, endTime, deltaTime, cacheHits;
#ifdef HAVE_GETRUSAGE
  struct rusage startRusage, endRusage;
#endif
  OOP methodOOP;
  OOP oldClass, oldCategory;
  inc_ptr incPtr;

  quiet = quiet || _gst_quiet_execution || _gst_emacs_process
	  || !_gst_get_cur_stream_prompt ();

  quiet = quiet && !_gst_regression_testing;

  oldClass = _gst_this_class;
  oldCategory = _gst_this_category;
  _gst_register_oop (oldClass);
  _gst_register_oop (oldCategory);

  _gst_set_compilation_class (_gst_undefined_object_class);
  _gst_set_compilation_category (_gst_nil_oop);

  messagePattern = _gst_make_unary_expr (&statements->location,
					 NULL,
					 "executeStatements");

  _gst_display_compilation_trace ("Compiling doit code", false);

  /* This is a big hack to let doits access the variables and classes
     in the current namespace. */
  SET_CLASS_ENVIRONMENT (_gst_undefined_object_class,
			 _gst_current_namespace);
  methodOOP =
    _gst_compile_method (_gst_make_method
			 (&statements->location, messagePattern,
			  temporaries, 0, statements),
			 true, false);

  SET_CLASS_ENVIRONMENT (_gst_undefined_object_class,
			 _gst_smalltalk_dictionary);

  _gst_set_compilation_class (oldClass);
  _gst_set_compilation_category (oldCategory);
  _gst_unregister_oop (oldClass);
  _gst_unregister_oop (oldCategory);

  if (_gst_had_error)		/* don't execute on error */
    return (_gst_nil_oop);

  incPtr = INC_SAVE_POINTER ();
  INC_ADD_OOP (methodOOP);

  if (!quiet && (_gst_regression_testing || _gst_verbose))
    printf ("\nExecution begins...\n");

  _gst_bytecode_counter = _gst_primitives_executed =
    _gst_self_returns = _gst_inst_var_returns = _gst_literal_returns =
    0;
  _gst_sample_counter = 0;
  startTime = _gst_get_milli_time ();
#ifdef HAVE_GETRUSAGE
  getrusage (RUSAGE_SELF, &startRusage);
#endif

  if (_gst_kernel_initialized)
    _gst_invoke_hook ("beforeEvaluation");

  /* send a message to NIL, which will find this synthetic method
     definition in Object and execute it */
  _gst_last_returned_value = _gst_nvmsg_send (_gst_nil_oop, methodOOP, NULL, 0);
  INC_ADD_OOP (_gst_last_returned_value);

  endTime = _gst_get_milli_time ();
#ifdef HAVE_GETRUSAGE
  getrusage (RUSAGE_SELF, &endRusage);
#endif

  if (_gst_kernel_initialized)
    _gst_invoke_hook ("afterEvaluation");

  INC_RESTORE_POINTER (incPtr);

  if (quiet)
    return (_gst_last_returned_value);

  /* Do more frequent flushing to ensure the result are well placed */
  if (_gst_regression_testing)
    fflush(stdout);

  if (_gst_regression_testing || _gst_verbose)
    printf ("returned value is ");

  printf ("%O\n", _gst_last_returned_value);

  if (_gst_regression_testing)
    fflush(stdout);

  if (!_gst_verbose)
    return (_gst_last_returned_value);

  deltaTime = endTime - startTime;
  deltaTime += (deltaTime == 0);	/* it could be zero which would 
					   core dump */

#ifdef USE_JIT_TRANSLATION
#define GIVING_X_BYTECODES_PER_SEC
#define BYTECODES_PER_SEC
  printf ("Execution");
#else
#define GIVING_X_BYTECODES_PER_SEC ", giving %lu bytecodes/sec"
#define BYTECODES_PER_SEC , (unsigned long) (_gst_bytecode_counter/ (deltaTime / 1000.0))
  printf ("%lu byte codes executed\nwhich", _gst_bytecode_counter);
#endif

  printf (" took %.3f seconds" GIVING_X_BYTECODES_PER_SEC "\n",
	  deltaTime / 1000.0 BYTECODES_PER_SEC);
#if 0 && defined(HAVE_GETRUSAGE)
  deltaTime = ((endRusage.ru_utime.tv_sec * 1000) +
	       (endRusage.ru_utime.tv_usec / 1000)) -
    ((startRusage.ru_utime.tv_sec * 1000) +
     (startRusage.ru_utime.tv_usec / 1000));
  deltaTime += (deltaTime == 0);	/* it could be zero which would 
					   core dump */
  printf ("(%.3f seconds user time" GIVING_X_BYTECODES_PER_SEC ", ",
	  deltaTime / 1000.0 BYTECODES_PER_SEC);

  deltaTime = ((endRusage.ru_stime.tv_sec * 1000) +
	       (endRusage.ru_stime.tv_usec / 1000)) -
    ((startRusage.ru_stime.tv_sec * 1000) +
     (startRusage.ru_stime.tv_usec / 1000));
  printf ("%.3f seconds system time)\n", deltaTime / 1000.0);

  printf ("(%ld swaps, %ld minor page faults, %ld major page faults)\n",
	  endRusage.ru_nswap - startRusage.ru_nswap,
	  endRusage.ru_minflt - startRusage.ru_minflt,
	  endRusage.ru_majflt - startRusage.ru_majflt);
#endif

#ifdef USE_JIT_TRANSLATION
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
  printf
    ("self returns %lu, inst var returns %lu, literal returns %lu\n",
     _gst_self_returns, _gst_inst_var_returns, _gst_literal_returns);
  printf ("%lu method cache lookups since last cleanup, percent %.2f\n",
	  _gst_sample_counter,
	  100.0 * _gst_sample_counter / _gst_bytecode_counter);
#endif

  cacheHits = _gst_sample_counter - _gst_cache_misses;
  printf ("%lu method cache hits, %lu misses", cacheHits,
	  _gst_cache_misses);
  if (cacheHits || _gst_cache_misses)
    printf (", %.2f percent hits\n",
	    (100.0 * cacheHits) / _gst_sample_counter);
  else
    printf ("\n");

  return (_gst_last_returned_value);
}
#undef GIVING_X_BYTECODES_PER_SEC
#undef BYTECODES_PER_SEC



OOP
_gst_compile_method (tree_node method,
		     mst_Boolean returnLast,
		     mst_Boolean install)
{
  tree_node statement;
  OOP selector;
  OOP methodOOP;
  bytecodes bytecodes;
  int primitiveIndex;
  int stack_depth;
  inc_ptr incPtr;

  dup_message_receiver = false;
  _gst_unregister_oop (_gst_latest_compiled_method);
  _gst_latest_compiled_method = _gst_nil_oop;
  _gst_line_number (-1, true);
  line_offset = method->location.first_line - 1;

  incPtr = INC_SAVE_POINTER ();

  _gst_alloc_bytecodes ();
  _gst_push_new_scope ();
  inside_block = 0;
  _gst_declare_arguments (method->v_method.selectorExpr);
  _gst_declare_temporaries (method->v_method.temporaries);

  selector = compute_selector (method->v_method.selectorExpr);
  INC_ADD_OOP (selector);
  if (_gst_declare_tracing)
    printf ("  class %O, selector %O\n", _gst_this_class, selector);

  if (method->v_method.primitiveName)
    primitiveIndex = _gst_resolve_primitive_name (method->v_method.primitiveName);
  else
    primitiveIndex = 0;

  if (setjmp (bad_method) == 0)
    {
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
	       will remove the pop. */
	    {
	      _gst_compile_byte (RETURN_CONTEXT_STACK_TOP);
	      break;
	    }

	    /* ignore the result of the last statement if it's not
	       used */
	    SUB_STACK_DEPTH (1);
	    _gst_compile_byte (POP_STACK_TOP);

	    if (!statement)
	      {
	        /* compile a return of self.  Note that in
	           theory the pop above is not necessary in this case 
	           (and in fact older versions did not put it),
	           but having it simplifies the optimizer's task
	           because it reduces the number of patterns it has
	           to look for.  If necessary, the optimizer itself
	           will remove the pop. */
	        _gst_compile_byte (RETURN_INDEXED | RECEIVER_INDEX);
		break;
	      }
	}

      if (method->v_method.statements == NULL)
	{
	  if (returnLast)
	    /* special case an empty statement body to return _gst_self */
	    _gst_compile_byte (RETURN_INDEXED | NIL_INDEX);
	  else
	    /* special case an empty statement body to return _gst_self */
	    _gst_compile_byte (RETURN_INDEXED | RECEIVER_INDEX);
	}

      stack_depth = GET_STACK_DEPTH ();
      bytecodes = _gst_get_bytecodes ();

      methodOOP = _gst_make_new_method (primitiveIndex,
					_gst_get_arg_count (),
					_gst_get_temp_count (),
					stack_depth, NULL, bytecodes,
					_gst_this_class, selector);
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
      literal_vec_curr = literal_vec;
      bytecodes = _gst_get_bytecodes ();
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
      _gst_compile_byte (RETURN_METHOD_STACK_TOP);
      SUB_STACK_DEPTH (1);
      return;
    }

  if (receiver->nodeType == TREE_VARIABLE_NODE)
    {
      OOP symbol = _gst_intern_string (receiver->v_list.name);
      symbol_entry variable;

      if (_gst_find_variable (&variable, receiver)
	  && variable.scope == SCOPE_SPECIAL
	  && symbol != _gst_this_context_symbol)
	{
	  _gst_compile_byte (RETURN_INDEXED | variable.varIndex);
	  return;
	}
    }

  compile_expression (receiver);
  _gst_compile_byte (RETURN_CONTEXT_STACK_TOP);
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
  _gst_line_number (expr->location.first_line - line_offset, false);
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
  int location;

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
    {
      _gst_compile_byte (PUSH_SPECIAL + variable.varIndex);
      return;
    }

  if (variable.scope == SCOPE_GLOBAL)
    {
      compile_push_global (variable.varIndex);
      return;
    }

  if (varName->v_list.next)
    {
      _gst_errorf_at (varName->location.first_line,
		      "invalid scope resolution");
      EXIT_COMPILATION ();
    }

  if (variable.scopeDistance != 0)
    {
      /* must be a temporary from an outer scope */
      _gst_compile_byte (OUTER_TEMP_BYTECODE);
      _gst_compile_byte (variable.varIndex | PUSH_VARIABLE);
      _gst_compile_byte (variable.scopeDistance);
    }
  else if (variable.varIndex <= 15)
    {
      if (variable.scope == SCOPE_TEMPORARY)
	_gst_compile_byte (PUSH_TEMPORARY_VARIABLE | variable.varIndex);
      else
	_gst_compile_byte (PUSH_RECEIVER_VARIABLE | variable.varIndex);
    }
  else if (variable.varIndex <= 63)
    {
      _gst_compile_byte (PUSH_INDEXED);
      location = (variable.scope == SCOPE_TEMPORARY)
	? TEMPORARY_LOCATION : RECEIVER_LOCATION;
      _gst_compile_byte (location | variable.varIndex);
    }
  else
    {
      _gst_compile_byte (BIG_INSTANCE_BYTECODE);
      _gst_compile_byte (PUSH_VARIABLE | (variable.varIndex >> 8));
      _gst_compile_byte (variable.varIndex & 255);
    }
}

void
compile_constant (tree_node constExpr)
{
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
      constantOOP = make_constant_oop (constExpr);
      if (IS_INT (constantOOP))
        {
          long intVal = TO_INT (constantOOP);
          if (intVal >= -128 && intVal < 255)
            {
	      INCR_STACK_DEPTH ();
	      compile_push_int_constant(intVal);
              return;
            }
        }
      else
        MAKE_OOP_READONLY (constantOOP, true);

      index = add_literal (constantOOP);
    }

  INCR_STACK_DEPTH ();
  compile_push_literal (index);
}

void
compile_block (tree_node blockExpr)
{
  bytecodes current_bytecodes, blockByteCodes;
  int argCount, tempCount;
  int stack_depth;
  OOP blockClosureOOP;
  gst_block_closure blockClosure;
  gst_compiled_block block;

  INCR_STACK_DEPTH ();
  current_bytecodes = _gst_save_bytecode_array ();

  _gst_push_new_scope ();
  argCount = _gst_declare_block_arguments (blockExpr->v_block.arguments);
  tempCount = _gst_declare_temporaries (blockExpr->v_block.temporaries);
  compile_statements (blockExpr->v_block.statements, true);

  stack_depth = GET_STACK_DEPTH ();
  blockByteCodes = _gst_get_bytecodes ();

  blockClosureOOP =
    make_block_closure (_gst_get_arg_count (), _gst_get_temp_count (),
			blockByteCodes, stack_depth);

  _gst_pop_old_scope ();
  _gst_restore_bytecode_array (current_bytecodes);

  /* emit standard byte sequence to invoke a block: 
     push literal (a BlockClosure)
     push thisContext -> may become push nil when optimizing
     blockCopy send -> may not be there at all when optimizing */
  INCR_STACK_DEPTH ();
  compile_push_literal (add_literal (blockClosureOOP));
  blockClosure = (gst_block_closure) OOP_TO_OBJ (blockClosureOOP);
  block = (gst_compiled_block) OOP_TO_OBJ (blockClosure->block);
  switch (block->header.clean)
    {
    case 0:
      break;

    case 1:
      _gst_compile_byte (PUSH_SPECIAL | NIL_INDEX);
      _gst_compile_byte (BLOCK_COPY_COLON_SPECIAL);
      break;

    default:
      _gst_compile_byte (PUSH_ACTIVE_CONTEXT);
      _gst_compile_byte (BLOCK_COPY_COLON_SPECIAL);
      break;
    }
}


mst_Boolean
compile_statements (tree_node statementList,
		    mst_Boolean isBlock)
{
  tree_node stmt;

  if (statementList == NULL)
    {
      if (isBlock)
	_gst_compile_byte (RETURN_INDEXED | NIL_INDEX);
      else
	{
	  INCR_STACK_DEPTH ();
	  _gst_compile_byte (PUSH_SPECIAL | NIL_INDEX);
	}
      return (false);
    }

  if (isBlock)
    {
      _gst_line_number (statementList->location.first_line - line_offset, true);
      inside_block++;
    }

  for (stmt = statementList;; stmt = stmt->v_list.next)
    {
      compile_statement (stmt->v_list.value);
      if (!stmt->v_list.next)
	break;

      /* throw away the value on the top of the stack...we don't need
         it for all but the last one. */
      SUB_STACK_DEPTH (1);
      _gst_compile_byte (POP_STACK_TOP);
    }

  /* stmt is the last statement here.  if it isn't a return, then
     return the value on the stack as the result.  For inlined blocks,
     the returned value is the top of the stack (which is already
     there), so we are already done. */
  if (stmt->v_list.value->nodeType != TREE_RETURN_EXPR && isBlock)
    _gst_compile_byte (RETURN_CONTEXT_STACK_TOP);

  if (isBlock)
    {
      _gst_line_number (-1, false);
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
  compile_push_global (_gst_add_forced_object (arrayAssociation));
  compile_push_int_constant (n);
  _gst_compile_byte (NEW_COLON_SPECIAL);
  SUB_STACK_DEPTH (1);

  /* compile the values now */
  for (i = 0, stmt = statementList; i < n;
       i++, stmt = stmt->v_list.next)
    {
      compile_statement (stmt->v_list.value);
      _gst_compile_byte (BIG_INSTANCE_BYTECODE);
      _gst_compile_byte (((i >> 8) & 63) | POP_STORE_INTO_ARRAY);
      _gst_compile_byte (i & 255);

      /* throw away the value on the top of the stack... */
      SUB_STACK_DEPTH (1);
    }
}


void
compile_unary_expr (tree_node expr)
{
  OOP selector;
  int selectorIndex;
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

  selectorIndex = add_selector (selector);
  if (expr->v_expr.receiver != NULL)
    {
      compile_expression (expr->v_expr.receiver);
      if (savedDupFlag)
	{
	  _gst_compile_byte (DUP_STACK_TOP);
          INCR_STACK_DEPTH ();
	}

      if (is_super (expr->v_expr.receiver))
	{
	  if (selectorIndex < 0)
	    selectorIndex = _gst_add_forced_object (selector);

	  if (selectorIndex <= 31)
	    {
	      _gst_compile_byte (SEND_SUPER1EXT_BYTE);
	      _gst_compile_byte (selectorIndex);
	    }
	  else if (selectorIndex <= 1023)
	    {
	      _gst_compile_byte (SEND2EXT_BYTE);
	      _gst_compile_byte (EXTENDED_SEND_SUPER_FLAG |
				 ((selectorIndex >> 2) & 192));
	      _gst_compile_byte (selectorIndex);
	    }
	  else
	    {
	      _gst_errorf_at (expr->location.first_line,
			      "message send cannot be represented");
	      EXIT_COMPILATION ();
	    }
	  return;
	}
    }

  if (selectorIndex < 0)
    _gst_compile_byte (-selectorIndex);
  else
    compile_send (selectorIndex, 0);
}

void
compile_binary_expr (tree_node expr)
{
  OOP selector;
  int selectorIndex;
  mst_Boolean savedDupFlag;

  savedDupFlag = dup_message_receiver;
  dup_message_receiver = false;

  selector = expr->v_expr.selector;
  selectorIndex = add_selector (selector);

  if (expr->v_expr.receiver)
    {
      compile_expression (expr->v_expr.receiver);
      if (savedDupFlag)
	{
	  _gst_compile_byte (DUP_STACK_TOP);
          INCR_STACK_DEPTH ();
	}
    }

  if (expr->v_expr.expression)
    compile_expression (expr->v_expr.expression);

  SUB_STACK_DEPTH (1);

  if (expr->v_expr.receiver)
    {
      if (is_super (expr->v_expr.receiver))
	{
	  if (selectorIndex < 0)
	    selectorIndex = _gst_add_forced_object (selector);

	  if (selectorIndex <= 31)
	    {
	      _gst_compile_byte (SEND_SUPER1EXT_BYTE);
	      _gst_compile_byte ((1 << 5) | selectorIndex);
	    }
	  else if (selectorIndex <= 1023)
	    {
	      _gst_compile_byte (SEND2EXT_BYTE);
	      _gst_compile_byte (EXTENDED_SEND_SUPER_FLAG | 1 |
				 ((selectorIndex >> 2) & 192));
	      _gst_compile_byte (selectorIndex);
	    }
	  else
	    {
	      _gst_errorf_at (expr->location.first_line,
	      		      "message send cannot be represented");
	      EXIT_COMPILATION ();
	    }
	  return;
	}
    }

  if (selectorIndex < 0)
    _gst_compile_byte (-selectorIndex);
  else
    compile_send (selectorIndex, 1);
}

void
compile_keyword_expr (tree_node expr)
{
  OOP selector;
  int selectorIndex, numArgs;
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
	  _gst_compile_byte (DUP_STACK_TOP);
          INCR_STACK_DEPTH ();
	}
    }

  if (selector == _gst_if_true_colon_symbol
      || selector == _gst_if_false_colon_symbol)
    {
      if (compile_if_statement (selector, expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_if_true_colon_if_false_colon_symbol
	   || selector == _gst_if_false_colon_if_true_colon_symbol)
    {
      if (compile_if_true_false_statement
	  (selector, expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_and_colon_symbol
	   || selector == _gst_or_colon_symbol)
    {
      if (compile_and_or_statement (selector, expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_times_repeat_colon_symbol)
    {
      if (compile_times_repeat (expr->v_expr.expression))
	return;
    }
  else if (selector == _gst_to_colon_do_colon_symbol)
    {
      if (compile_to_by_do (expr->v_expr.expression->v_list.value, NULL,
			    expr->v_expr.expression->v_list.next->v_list.value))
	return;
    }
  else if (selector == _gst_to_colon_by_colon_do_colon_symbol)
    {
      if (compile_to_by_do (expr->v_expr.expression->v_list.value,
			    expr->v_expr.expression->v_list.next->v_list.value,
			    expr->v_expr.expression->v_list.next->v_list.next->v_list.value))
	return;
    }

  selectorIndex = add_selector (selector);

  numArgs = list_length (expr->v_expr.expression);

  compile_keyword_list (expr->v_expr.expression);
  SUB_STACK_DEPTH (numArgs);

  if (expr->v_expr.receiver)
    {
      if (is_super (expr->v_expr.receiver))
	{
	  if (selectorIndex < 0)
	    selectorIndex = _gst_add_forced_object (selector);

	  if (selectorIndex <= 31 && numArgs <= 7)
	    {
	      _gst_compile_byte (SEND_SUPER1EXT_BYTE);
	      _gst_compile_byte ((numArgs << 5) | selectorIndex);
	    }
	  else if (selectorIndex <= 1023)
	    {
	      _gst_compile_byte (SEND2EXT_BYTE);
	      _gst_compile_byte (EXTENDED_SEND_SUPER_FLAG | numArgs |
				 ((selectorIndex >> 2) & 192));
	      _gst_compile_byte (selectorIndex);
	    }
	  else
	    {
	      _gst_errorf_at (expr->location.first_line,
	      		      "message send cannot be represented");
	      EXIT_COMPILATION ();
	    }
	  return;
	}
    }

  if (selectorIndex < 0)
    _gst_compile_byte (-selectorIndex);
  else
    compile_send (selectorIndex, numArgs);
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
  int whileLoopLen, startLoopLen;
  bytecodes receiverExprCodes, whileExprCodes;
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


  startLoopLen = _gst_current_bytecode_length ();

  receiverExprCodes = compile_sub_expression (expr->v_expr.receiver);
  _gst_compile_and_free_bytecodes (receiverExprCodes);

  if (colon)
    {
      whileExprCodes =
	compile_sub_expression (expr->v_expr.expression->v_list.value);

      /* skip to the while loop if the receiver block yields the proper 
         value */
      compile_jump (2, whileTrue ? JUMP_TRUE : JUMP_FALSE);

      /* otherwise, skip to the end, past the pop stack top and 2 byte
         jump and exit the loop */
      compile_long_jump (_gst_bytecode_length (whileExprCodes) + 3);

      _gst_compile_and_free_bytecodes (whileExprCodes);
      _gst_compile_byte (POP_STACK_TOP);	/* we don't care about
						   while expr's value */
      SUB_STACK_DEPTH (1);
    }
  else
    {
      /* skip to the while loop if the receiver block yields the proper 
         value */
      compile_jump (1, whileTrue ? JUMP_TRUE : JUMP_FALSE);
      compile_jump (2, JUMP_UNCONDITIONAL);
    }

  /* +2 since we're using a 2 byte jump instruction here, so we have to
     skip back over it in addition to the other instructions */
  whileLoopLen = _gst_current_bytecode_length () - startLoopLen + 2;

  /* skip to the beginning if the receiver block yields the proper
     value */
  compile_long_jump (-whileLoopLen);

  /* while loops always return nil (ain't expression languages grand?)
     -- inefficient, but anyway the optimizer deletes this. */
  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_SPECIAL | NIL_INDEX);
  return (true);
}


mst_Boolean
compile_repeat (tree_node receiver)
{
  int repeatedLoopLen;
  bytecodes receiverExprCodes;

  if (receiver->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_PARAMS_OR_TEMPS (receiver))
    return (false);

  receiverExprCodes = compile_sub_expression (receiver);
  repeatedLoopLen = _gst_bytecode_length (receiverExprCodes) + 3;

  _gst_compile_and_free_bytecodes (receiverExprCodes);
  _gst_compile_byte (POP_STACK_TOP);	/* we don't care about expr's
					   value */
  SUB_STACK_DEPTH (1);
  compile_long_jump (-repeatedLoopLen);

  /* this code is unreachable, it is only here to please the JIT
     compiler */
  _gst_compile_byte (PUSH_SPECIAL | NIL_INDEX);
  INCR_STACK_DEPTH ();
  return (true);
}

mst_Boolean
compile_times_repeat (tree_node expr)
{
  int startLoopLen, wholeLoopLen;
  bytecodes loopExprCodes;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_PARAMS_OR_TEMPS (expr->v_list.value))
    return (false);

  /* save the receiver for the return value */
  _gst_compile_byte (DUP_STACK_TOP);
  INCR_STACK_DEPTH ();

  startLoopLen = _gst_current_bytecode_length ();
  loopExprCodes = compile_sub_expression (expr->v_list.value);

  _gst_compile_byte (DUP_STACK_TOP);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (PUSH_ONE);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (GREATER_EQUAL_SPECIAL);
  SUB_STACK_DEPTH (1);

  /* skip the loop if there are no more occurrences */
  compile_jump (_gst_bytecode_length (loopExprCodes) + 5, JUMP_FALSE);
  _gst_compile_byte (PUSH_ONE);
  INCR_STACK_DEPTH ();
  _gst_compile_byte (MINUS_SPECIAL);
  SUB_STACK_DEPTH (1);

  /* we don't care about block expr's value */
  _gst_compile_and_free_bytecodes (loopExprCodes);
  _gst_compile_byte (POP_STACK_TOP);
  SUB_STACK_DEPTH (1);

  /* +2 since we're using a 2 byte jump instruction here, so we have to
     skip back over it in addition to the other instructions */
  wholeLoopLen = _gst_current_bytecode_length () - startLoopLen + 2;

  compile_long_jump (-wholeLoopLen);

  /* delete the 0 that remains on the stack */
  _gst_compile_byte (POP_STACK_TOP);
  SUB_STACK_DEPTH (1);
  return (true);
}

mst_Boolean
compile_to_by_do (tree_node to,
		  tree_node by,
		  tree_node block)
{
  int loopLen, index, startLoopLen, wholeLoopLen;
  bytecodes loopExprCodes, stepCodes = NULL;	/* initialize to please 
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
    _gst_declare_name (block->v_block.arguments->v_list.name, false);
  _gst_compile_byte (STORE_INDEXED);
  _gst_compile_byte (index | TEMPORARY_LOCATION);

  compile_expression (to);
  _gst_compile_byte (DUP_STACK_TOP);
  INCR_STACK_DEPTH ();
  if (index < 15)
    {
      _gst_compile_byte (PUSH_TEMPORARY_VARIABLE | index);
      INCR_STACK_DEPTH ();
    }
  else
    {
      _gst_compile_byte (PUSH_INDEXED);
      _gst_compile_byte (index | TEMPORARY_LOCATION);
      INCR_STACK_DEPTH ();
    }

  loopLen = index > 15 ? 9 : 8;

  if (by)
    {
      bytecodes current_bytecodes;
      current_bytecodes = _gst_save_bytecode_array ();
      compile_expression (by);
      stepCodes = _gst_get_bytecodes ();
      _gst_restore_bytecode_array (current_bytecodes);
      loopLen += _gst_bytecode_length (stepCodes);
    }
  else
    loopLen++;

  startLoopLen = _gst_current_bytecode_length ();
  loopExprCodes = compile_sub_expression (block);
  loopLen += _gst_bytecode_length (loopExprCodes);

  /* skip the loop if there are no more occurrences */
  _gst_compile_byte ((!by || by->v_const.val.iVal > 0)
		     ? GREATER_EQUAL_SPECIAL : LESS_EQUAL_SPECIAL);
  SUB_STACK_DEPTH (1);
  compile_jump (loopLen, JUMP_FALSE);
  SUB_STACK_DEPTH (1);

  /* we don't care about loop expr's value */
  _gst_compile_and_free_bytecodes (loopExprCodes);
  _gst_compile_byte (POP_STACK_TOP);
  SUB_STACK_DEPTH (1);
  _gst_compile_byte (DUP_STACK_TOP);
  INCR_STACK_DEPTH ();
  if (index > 15)
    {
      _gst_compile_byte (PUSH_INDEXED);
      _gst_compile_byte (index | TEMPORARY_LOCATION);
      INCR_STACK_DEPTH ();
    }
  else
    {
      _gst_compile_byte (PUSH_TEMPORARY_VARIABLE | index);
      INCR_STACK_DEPTH ();
    }

  if (by)
    _gst_compile_and_free_bytecodes (stepCodes);
  else
    {
      _gst_compile_byte (PUSH_ONE);
      INCR_STACK_DEPTH ();
    }

  _gst_compile_byte (PLUS_SPECIAL);
  SUB_STACK_DEPTH (1);
  _gst_compile_byte (STORE_INDEXED);
  _gst_compile_byte (index | TEMPORARY_LOCATION);

  /* +2 since we're using a 2 byte jump instruction here, so we have to
     skip back over it in addition to the other instructions */
  wholeLoopLen = _gst_current_bytecode_length () - startLoopLen + 2;

  compile_long_jump (-wholeLoopLen);

  /* delete the end from the stack */
  _gst_compile_byte (POP_STACK_TOP);
  SUB_STACK_DEPTH (1);
  _gst_undeclare_name ();
  return (true);
}


mst_Boolean
compile_if_true_false_statement (OOP selector,
				 tree_node expr)
{
  bytecodes trueByteCodes, falseByteCodes;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE
      || expr->v_list.next->v_list.value->nodeType != TREE_BLOCK_NODE)
    return (false);

  if (HAS_PARAMS_OR_TEMPS (expr->v_list.value)
      || HAS_PARAMS_OR_TEMPS (expr->v_list.next->v_list.value))
    return (false);

  if (selector == _gst_if_true_colon_if_false_colon_symbol)
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

  compile_jump (_gst_bytecode_length (trueByteCodes), JUMP_FALSE);
  _gst_compile_and_free_bytecodes (trueByteCodes);
  _gst_compile_and_free_bytecodes (falseByteCodes);
  return (true);
}

mst_Boolean
compile_if_statement (OOP selector,
		      tree_node expr)
{
  bytecodes thenByteCodes;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE
      || HAS_PARAMS_OR_TEMPS (expr->v_list.value))
    return (false);

  /* The 2nd parameter (1) is the size of a `push nil' bytecode */
  thenByteCodes =
    compile_sub_expression_and_jump (expr->v_list.value, 1);
  compile_jump (_gst_bytecode_length (thenByteCodes),
		(selector ==
		 _gst_if_true_colon_symbol) ? JUMP_FALSE : JUMP_TRUE);
  _gst_compile_and_free_bytecodes (thenByteCodes);

  /* Compare the code produced here with that produced in #and:/#or:
     This produces less efficient bytecodes if the condition is true
     (there are two jumps instead of one).  Actually, the push will 99% 
     of the times be followed by a pop stack top, and the optimizer
     changes 
	0: jump to 2 
	1: push nil 
	2: pop stack top

     to a single pop -- so the code ends up being quite efficent. Note
     that instead the result of #and:/#or: will be used (no pop) so we
     use the other possible encoding. */
  _gst_compile_byte (PUSH_SPECIAL | NIL_INDEX);
  return (true);
}


mst_Boolean
compile_and_or_statement (OOP selector,
			  tree_node expr)
{
  bytecodes blockByteCodes, defaultByteCodes, current_bytecodes;
  int blockLen;

  if (expr->v_list.value->nodeType != TREE_BLOCK_NODE
      || HAS_PARAMS_OR_TEMPS (expr->v_list.value))
    return (false);

  blockByteCodes = compile_sub_expression (expr->v_list.value);
  blockLen = _gst_bytecode_length (blockByteCodes);

  current_bytecodes = _gst_save_bytecode_array ();
  _gst_compile_byte (PUSH_SPECIAL |
		     ((selector ==
		       _gst_and_colon_symbol) ? FALSE_INDEX :
		      TRUE_INDEX));

  compile_jump (blockLen, JUMP_UNCONDITIONAL);
  defaultByteCodes = _gst_get_bytecodes ();
  _gst_restore_bytecode_array (current_bytecodes);

  compile_jump (_gst_bytecode_length (defaultByteCodes),
		(selector ==
		 _gst_and_colon_symbol) ? JUMP_TRUE : JUMP_FALSE);
  _gst_compile_and_free_bytecodes (defaultByteCodes);
  _gst_compile_and_free_bytecodes (blockByteCodes);
  return (true);
}



bytecodes
compile_sub_expression (tree_node expr)
{
  mst_Boolean returns;
  bytecodes current_bytecodes, subExprByteCodes;

  current_bytecodes = _gst_save_bytecode_array ();
  returns = compile_statements (expr->v_block.statements, false);
  if (returns)
    INCR_STACK_DEPTH ();

  subExprByteCodes = _gst_get_bytecodes ();
  _gst_restore_bytecode_array (current_bytecodes);

  return (subExprByteCodes);
}


bytecodes
compile_sub_expression_and_jump (tree_node expr,
				 int branchLen)
{
  bytecodes current_bytecodes, subExprByteCodes;
  mst_Boolean returns;

  current_bytecodes = _gst_save_bytecode_array ();
  returns = compile_statements (expr->v_block.statements, false);
  if (returns)
    INCR_STACK_DEPTH ();

  if (!returns)
    compile_jump (branchLen, JUMP_UNCONDITIONAL);

  subExprByteCodes = _gst_get_bytecodes ();
  _gst_restore_bytecode_array (current_bytecodes);

  return (subExprByteCodes);
}

void
compile_jump (int len,
	      jump_type jumpType)
{
  if (len <= 0)
    {
      _gst_errorf ("invalid length jump %d -- internal error\n", len);
      EXIT_COMPILATION ();
    }

  if (len >= 1024)
    {
      _gst_errorf ("invalid length jump %d -- method too complex\n",
		   len);
      EXIT_COMPILATION ();
    }

  switch (jumpType)
    {
    case JUMP_UNCONDITIONAL:
      if (len <= 8)
	_gst_compile_byte (JUMP_SHORT | (len - 1));
      else
	{
	  _gst_compile_byte (JUMP_LONG | (4 + len / 256));
	  _gst_compile_byte (len & 255);
	}
      break;

    case JUMP_FALSE:
      SUB_STACK_DEPTH (1);
      if (len <= 8)
	_gst_compile_byte (POP_JUMP_FALSE_SHORT | (len - 1));
      else
	{
	  _gst_compile_byte (POP_JUMP_FALSE | (len / 256));
	  _gst_compile_byte (len & 255);
	}
      break;

    case JUMP_TRUE:
      SUB_STACK_DEPTH (1);
      _gst_compile_byte (POP_JUMP_TRUE | (len / 256));
      _gst_compile_byte (len & 255);
      break;
    }
}


void
compile_long_jump (int len)
{
  len += 1024;
  if (len <= 0 || len >= 2048)
    {
      _gst_errorf ("invalid length jump %d -- method too complex\n",
		   len);
      EXIT_COMPILATION ();
    }

  _gst_compile_byte (JUMP_LONG | (len / 256));
  _gst_compile_byte (len & 255);
}

void
compile_push_int_constant (int value)
{
  OOP intOOP;

  if (value == 0 || value == 1)
    {
      _gst_compile_byte (PUSH_ZERO + value);
      return;
    }

  if (value >= 0 && value <= 255)
    {
      _gst_compile_byte (PUSH_UNSIGNED_8);
      _gst_compile_byte (value);
      return;
    }

  if (value >= -128 && value <= 127)
    {
      _gst_compile_byte (PUSH_SIGNED_8);
      _gst_compile_byte (value);
      return;
    }

  intOOP = FROM_INT ((long) value);
  compile_push_literal (_gst_add_forced_object (intOOP));
}


void
compile_send (int selectorIndex,
	      int numArgs)
{
  if (numArgs <= 2 && selectorIndex <= 15)
    {
      switch (numArgs)
	{
	case 0:
	  _gst_compile_byte (SEND_NO_ARG | selectorIndex);
	  break;
	case 1:
	  _gst_compile_byte (SEND_1_ARG | selectorIndex);
	  break;
	case 2:
	  _gst_compile_byte (SEND_2_ARG | selectorIndex);
	  break;
	}
    }
  else if (selectorIndex <= 31 && numArgs <= 7)
    {
      _gst_compile_byte (SEND1EXT_BYTE);
      _gst_compile_byte ((numArgs << 5) | selectorIndex);
    }
  else if (selectorIndex <= 1023)
    {
      _gst_compile_byte (SEND2EXT_BYTE);
      _gst_compile_byte (numArgs | ((selectorIndex >> 2) & 192));
      _gst_compile_byte (selectorIndex);
    }
  else
    {
      _gst_errorf ("message send cannot be represented (yet)");
      EXIT_COMPILATION ();
    }
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
      _gst_compile_byte (POP_STACK_TOP);
      if (message->v_list.next)
	_gst_compile_byte (DUP_STACK_TOP);
      else
	SUB_STACK_DEPTH (1);

      compile_expression (message->v_list.value);
      /* !!! remember that unary, binary and keywordexpr should ignore
         the receiver field if it is nil; that is the case for these
         functions and things work out fine if that's the case. */
    }
}


void
compile_assignments (tree_node varList)
{
  symbol_entry variable;
  int locationIndex;

  for (; varList; varList = varList->v_list.next)
    {
      tree_node varName = varList->v_list.value;

      _gst_line_number (varList->location.first_line - line_offset, false);
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
		          variable.scope ==
		          SCOPE_SPECIAL ? "special variable" : "argument",
		          varName->v_list.name);

	  EXIT_COMPILATION ();
	}

      /* Here we have several kinds of things to store: receiver
         variable, temporary variable, "literal" variable (reference by 
         association). */

      if (variable.scope != SCOPE_GLOBAL && varName->v_list.next)
        {
          _gst_errorf_at (varName->location.first_line,
                          "invalid scope resolution");
          EXIT_COMPILATION ();
        }

      if (variable.scope == SCOPE_TEMPORARY
	  && variable.scopeDistance > 0)
	{
	  /* a store into an outer temporary */
	  _gst_compile_byte (OUTER_TEMP_BYTECODE);
	  _gst_compile_byte (variable.varIndex | STORE_VARIABLE);
	  _gst_compile_byte (variable.scopeDistance);
	}
      else if (variable.varIndex <= 63)
	{
	  locationIndex = COMPUTE_LOCATION_INDEX (variable);
	  _gst_compile_byte (STORE_INDEXED);
	  _gst_compile_byte (locationIndex | variable.varIndex);
	}
      else
	{
	  /* must be literal or instance variable if > 63 */
	  _gst_compile_byte (variable.scope == SCOPE_RECEIVER
			     ? BIG_INSTANCE_BYTECODE :
			     BIG_LITERALS_BYTECODE);
	  _gst_compile_byte (STORE_VARIABLE | (variable.varIndex >> 8));
	  _gst_compile_byte (variable.varIndex & 255);
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
  long len, i;

  /* ??? this kind of special casing of the elements of arrays bothers
     me...it should all be in one neat place. */
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

    case CONST_FLOATD:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_floatd_class
	  && (double) constExpr->v_const.val.fVal == FLOATD_OOP_VALUE (oop))
	return (true);
      break;

    case CONST_FLOATE:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_floate_class
	  && (float) constExpr->v_const.val.fVal == FLOATE_OOP_VALUE (oop))
	return (true);
      break;

    case CONST_FLOATQ:
      if (IS_OOP (oop) && OOP_CLASS (oop) == _gst_floatq_class
	  && constExpr->v_const.val.fVal == FLOATQ_OOP_VALUE (oop))
	return (true);
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
make_constant_oop (tree_node constExpr)
{
  tree_node arrayElt;
  int len, i;
  OOP resultOOP, elementOOP;
  inc_ptr incPtr;
  byte_object bo;
  mst_Object result;

  if (constExpr == NULL)
    return (_gst_nil_oop);	/* special case empty array literals */

  if (constExpr->nodeType == TREE_SYMBOL_NODE)	/* symbol in array
						   constant */
    return (constExpr->v_expr.selector);

  else if (constExpr->nodeType == TREE_ARRAY_ELT_LIST)
    {
      for (len = 0, arrayElt = constExpr; arrayElt;
	   len++, arrayElt = arrayElt->v_list.next);

      incPtr = INC_SAVE_POINTER ();

      /* this might be an uninitialized form of array creation for
         speed; but not now -- with the array temporarily part of the
         root set it must be completely initialized (sigh). */
      instantiate_with (_gst_array_class, len, &resultOOP);
      INC_ADD_OOP (resultOOP);

      for (i = 0, arrayElt = constExpr; i < len;
	   i++, arrayElt = arrayElt->v_list.next)
	{
	  elementOOP = make_constant_oop (arrayElt->v_list.value);
	  result = OOP_TO_OBJ (resultOOP);
	  result->data[i] = elementOOP;
	  if (IS_OOP (elementOOP))
	    MAKE_OOP_READONLY (elementOOP, true);
	}
      INC_RESTORE_POINTER (incPtr);
      return (resultOOP);
    }

  switch (constExpr->v_const.constType)
    {
    case CONST_INT:
      return (FROM_INT (constExpr->v_const.val.iVal));

    case CONST_FLOATD:
      return (floatd_new (constExpr->v_const.val.fVal));

    case CONST_FLOATE:
      return (floate_new (constExpr->v_const.val.fVal));

    case CONST_FLOATQ:
      return (floatq_new (constExpr->v_const.val.fVal));

    case CONST_STRING:
      return (_gst_string_new (constExpr->v_const.val.sVal));

    case CONST_OOP:
      return (constExpr->v_const.val.oopVal);

    case CONST_BYTE_OBJECT:
      bo = constExpr->v_const.val.boVal;
      result = instantiate_with (bo->class, bo->size, &resultOOP);
      memcpy (result->data, bo->body, bo->size);
      return (resultOOP);

    case CONST_ARRAY:
      for (len = 0, arrayElt = constExpr->v_const.val.aVal; arrayElt;
	   len++, arrayElt = arrayElt->v_list.next);

      incPtr = INC_SAVE_POINTER ();
      result = instantiate_with (_gst_array_class, len, &resultOOP);
      INC_ADD_OOP (resultOOP);

      for (i = 0, arrayElt = constExpr->v_const.val.aVal; i < len;
	   i++, arrayElt = arrayElt->v_list.next)
	{
	  elementOOP = make_constant_oop (arrayElt->v_list.value);
	  result = OOP_TO_OBJ (resultOOP);
	  result->data[i] = elementOOP;
	  if (IS_OOP (elementOOP))
	    MAKE_OOP_READONLY (elementOOP, true);
	}

      INC_RESTORE_POINTER (incPtr);
      return (resultOOP);
    }

  return (_gst_nil_oop);
}

OOP
make_block_closure (int args,
		    int temps,
		    bytecodes bytecodes,
		    int stack_depth)
{
  gst_block_closure closure;
  OOP blockOOP, closureOOP;
  inc_ptr incPtr;

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

  /* Always allocate objects starting from the deepest one! (that is,
     subtle bugs arise if _gst_block_new triggers a GC, because
     closure's value might be no longer valid!) */
  incPtr = INC_SAVE_POINTER ();
  blockOOP =
    _gst_block_new (args, temps, bytecodes, stack_depth, literal_vec);
  INC_ADD_OOP (blockOOP);

  closure = (gst_block_closure) new_instance (_gst_block_closure_class, 
					      &closureOOP);
  closure->outerContext = _gst_nil_oop;
  closure->receiver = _gst_nil_oop;
  closure->block = blockOOP;
  INC_RESTORE_POINTER (incPtr);

  _gst_free_bytecodes (bytecodes);
  return (closureOOP);
}

int
add_selector (OOP selector)
{
  int builtin;

  if ((builtin = which_builtin_selector (selector)) != 0)
    return (-builtin);
  else
    return (_gst_add_forced_object (selector));
}

int
which_builtin_selector (OOP selector)
{
  if (selector == _gst_at_colon_symbol)
    return (AT_COLON_SPECIAL);
  else if (selector == _gst_at_colon_put_colon_symbol)
    return (AT_COLON_PUT_COLON_SPECIAL);
  else if (selector == _gst_size_symbol)
    return (SIZE_SPECIAL);
  else if (selector == _gst_next_symbol)
    return (NEXT_SPECIAL);
  else if (selector == _gst_next_put_colon_symbol)
    return (NEXT_PUT_COLON_SPECIAL);
  else if (selector == _gst_at_end_symbol)
    return (AT_END_SPECIAL);
  else if (selector == _gst_class_symbol)
    return (CLASS_SPECIAL);
  else if (selector == _gst_block_copy_colon_symbol)
    return (BLOCK_COPY_COLON_SPECIAL);
  else if (selector == _gst_value_symbol)
    return (VALUE_SPECIAL);
  else if (selector == _gst_value_colon_symbol)
    return (VALUE_COLON_SPECIAL);
  else if (selector == _gst_do_colon_symbol)
    return (DO_COLON_SPECIAL);
  else if (selector == _gst_new_symbol)
    return (NEW_SPECIAL);
  else if (selector == _gst_new_colon_symbol)
    return (NEW_COLON_SPECIAL);
  else if (selector == _gst_plus_symbol)
    return (PLUS_SPECIAL);
  else if (selector == _gst_minus_symbol)
    return (MINUS_SPECIAL);
  else if (selector == _gst_less_than_symbol)
    return (LESS_THAN_SPECIAL);
  else if (selector == _gst_greater_than_symbol)
    return (GREATER_THAN_SPECIAL);
  else if (selector == _gst_less_equal_symbol)
    return (LESS_EQUAL_SPECIAL);
  else if (selector == _gst_greater_equal_symbol)
    return (GREATER_EQUAL_SPECIAL);
  else if (selector == _gst_equal_symbol)
    return (EQUAL_SPECIAL);
  else if (selector == _gst_not_equal_symbol)
    return (NOT_EQUAL_SPECIAL);
  else if (selector == _gst_times_symbol)
    return (TIMES_SPECIAL);
  else if (selector == _gst_divide_symbol)
    return (DIVIDE_SPECIAL);
  else if (selector == _gst_remainder_symbol)
    return (REMAINDER_SPECIAL);
  else if (selector == _gst_at_sign_symbol)
    return (AT_SIGN_SPECIAL);
  else if (selector == _gst_bit_shift_colon_symbol)
    return (BIT_SHIFT_COLON_SPECIAL);
  else if (selector == _gst_integer_divide_symbol)
    return (INTEGER_DIVIDE_SPECIAL);
  else if (selector == _gst_bit_and_colon_symbol)
    return (BIT_AND_COLON_SPECIAL);
  else if (selector == _gst_bit_or_colon_symbol)
    return (BIT_OR_COLON_SPECIAL);
  else if (selector == _gst_same_object_symbol)
    return (SAME_OBJECT_SPECIAL);
  else if (selector == _gst_is_nil_symbol)
    return (IS_NIL_SPECIAL);
  else if (selector == _gst_not_nil_symbol)
    return (NOT_NIL_SPECIAL);
  else
    return (0);
}

OOP
compute_selector (tree_node selectorExpr)
{
  tree_node keyword;
  int len;
  char *nameBuf, *p;

  if (selectorExpr->nodeType == TREE_UNARY_EXPR
      || selectorExpr->nodeType == TREE_BINARY_EXPR)
    return (selectorExpr->v_expr.selector);

  len = 0;
  for (keyword = selectorExpr->v_expr.expression; keyword != NULL;
       keyword = keyword->v_list.next)
    len += strlen (keyword->v_list.name);

  p = nameBuf = (char *) alloca (len + 1);
  for (keyword = selectorExpr->v_expr.expression; keyword != NULL;
       keyword = keyword->v_list.next)
    {
      len = strlen (keyword->v_list.name);
      strcpy (p, keyword->v_list.name);
      p += len;
    }

  *p = '\0';

  return (_gst_intern_string (nameBuf));
}


int
list_length (tree_node listExpr)
{
  tree_node l;
  long len;

  for (len = 0, l = listExpr; l; l = l->v_list.next, len++);

  if (sizeof (int) != 4)
    {
      if (len > (1L << (sizeof (int) * 8 - 1)))
	{
	  _gst_errorf ("list too long, %ld", len);
	  len = 1L << (sizeof (int) * 8 - 1);
	}
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


void
realloc_literal_vec (void)
{
  int size;
  long delta;

  size = literal_vec_max - literal_vec + LITERAL_VEC_CHUNK_SIZE;
  delta = ((OOP *) xrealloc (literal_vec, size * sizeof (OOP))) - literal_vec;

  literal_vec += delta;
  literal_vec_curr += delta;
  literal_vec_max = literal_vec + size;
}


OOP
get_literals_array (void)
{
  OOP methodLiteralsOOP;
  mst_Object methodLiterals;

  if (literal_vec_curr == literal_vec)
    return (_gst_nil_oop);

  methodLiterals = new_instance_with (_gst_array_class, 
				      literal_vec_curr - literal_vec,
		                      &methodLiteralsOOP);

  memcpy (methodLiterals->data, literal_vec, 
	  (literal_vec_curr - literal_vec) * sizeof(OOP));

  literal_vec_curr = literal_vec;
  return (methodLiteralsOOP);
}

void
compile_push_literal (int index)
{
  if (index <= 31)
    _gst_compile_byte (PUSH_LIT_CONSTANT | index);

  else if (index <= 63)
    {
      _gst_compile_byte (PUSH_INDEXED);
      _gst_compile_byte (LIT_CONST_LOCATION | index);
    }
  else
    {
      _gst_compile_byte (BIG_LITERALS_BYTECODE);
      _gst_compile_byte (PUSH_LITERAL | (index >> 8));
      _gst_compile_byte (index & 255);
    }
}

void
compile_push_global (int index)
{
  if (index <= 31)
    _gst_compile_byte (PUSH_LIT_VARIABLE | index);

  else if (index <= 63)
    {
      _gst_compile_byte (PUSH_INDEXED);
      _gst_compile_byte (LIT_VAR_LOCATION | index);
    }
  else
    {
      _gst_compile_byte (BIG_LITERALS_BYTECODE);
      _gst_compile_byte (PUSH_VARIABLE | (index >> 8));
      _gst_compile_byte (index & 255);
    }
}


void
install_method (OOP methodOOP)
{
  OOP oldMethod, selector, methodDictionaryOOP;
  gst_compiled_method method;
  gst_method_info descriptor;

  method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
  descriptor = (gst_method_info) OOP_TO_OBJ (method->descriptor);
  selector = descriptor->selector;

  /* methodDictionaryOOP is held onto by the class, which is already
     reachable by the root set so we don't need to hold onto it
     here. */
  methodDictionaryOOP =
    _gst_valid_class_method_dictionary (_gst_this_class);

  oldMethod = _gst_identity_dictionary_at_put (methodDictionaryOOP,
					       selector, methodOOP);

#ifdef USE_JIT_TRANSLATION
  if (oldMethod != _gst_nil_oop)
    _gst_discard_native_code (oldMethod);
#endif

  _gst_invalidate_method_cache ();
}

OOP
_gst_make_new_method (int primitiveIndex,
		      int numArgs,
		      int numTemps,
		      int maximumStackDepth,
		      OOP literals,
		      bytecodes bytecodes,
		      OOP class,
		      OOP selector)
{
  method_header header;
  int newFlags;
  OOP method;
  inc_ptr incPtr;

  maximumStackDepth += numArgs + numTemps;

  if (primitiveIndex)
    {
      if (_gst_declare_tracing)
	printf ("  Primitive Index %d\n", primitiveIndex);

      header.headerFlag = 4;
    }
  else if (numArgs == 0 && numTemps == 0 &&
	   (newFlags = _gst_is_simple_return (bytecodes)) != 0)
    {
      header.headerFlag = newFlags & 0xFF;
      /* if returning an instance variable, its index is indicated in
         the primitive index */
      primitiveIndex = newFlags >> 8;
      numTemps = 0;

      _gst_free_bytecodes (bytecodes);
      bytecodes = NULL;
      literals = NULL;
    }
  else
    header.headerFlag = 0;

  incPtr = INC_SAVE_POINTER ();
  if (!literals)
    {
      literals = get_literals_array ();
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

  method = method_new (header, literals, bytecodes, class, selector);
  INC_RESTORE_POINTER (incPtr);
  return (method);
}

OOP
method_new (method_header header,
	    OOP literals,
	    bytecodes bytecodes,
	    OOP class,
	    OOP selector)
{
  int numByteCodes;
  gst_compiled_method method;
  OOP methodOOP, methodDesc;
  mst_Object lit;
  int i;

  if (bytecodes != NULL)
    numByteCodes = _gst_bytecode_length (bytecodes);
  else
    numByteCodes = 0;

  methodDesc = method_info_new (class, selector);
  INC_ADD_OOP (methodDesc);

  method = (gst_compiled_method) instantiate_with (_gst_compiled_method_class,
						   numByteCodes, &methodOOP);

  method->header = header;
  method->descriptor = methodDesc;
  method->literals = literals;

  for (lit = OOP_TO_OBJ (literals), i = NUM_OOPS (lit); i--;)
    {
      if (IS_CLASS (lit->data[i], _gst_block_closure_class))
	{
	  gst_block_closure bc;
	  gst_compiled_block block;
	  bc = (gst_block_closure) OOP_TO_OBJ (lit->data[i]);
	  block = (gst_compiled_block) OOP_TO_OBJ (bc->block);
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
		bytecodes bytecodes,
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

  return (blockOOP);
}

OOP
_gst_compiled_method_at (OOP methodOOP,
			 long int index)
{
  gst_compiled_method method;
  OOP oop;

  method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
  oop = OOP_TO_OBJ (method->literals)->data[index - 1];
  return (oop);
}

void
_gst_compiled_method_at_put (OOP methodOOP,
			     long int index,
			     OOP valueOOP)
{
  gst_compiled_method method;

  method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
  OOP_TO_OBJ (method->literals)->data[index - 1] = valueOOP;
}

OOP
method_info_new (OOP class,
		 OOP selector)
{
  gst_method_info methodInfo;
  OOP sourceCode, methodInfoOOP;
  inc_ptr incPtr;

  incPtr = INC_SAVE_POINTER ();
  sourceCode = file_segment_new ();
  INC_ADD_OOP (sourceCode);

  methodInfo = (gst_method_info) new_instance (_gst_method_info_class,
					       &methodInfoOOP);

  methodInfo->sourceCode = sourceCode;
  methodInfo->category = _gst_this_category;
  methodInfo->class = class;
  methodInfo->selector = selector;

  INC_RESTORE_POINTER (incPtr);
  return (methodInfoOOP);
}

OOP
file_segment_new (void)
{
  OOP fileName, stringContents, fileSegmentOOP;
  gst_file_segment fileSegment;
  int startPos;
  inc_ptr incPtr;

  switch (_gst_get_cur_stream_type ())
    {
    case STREAM_UNKNOWN:
    default:
      return (_gst_nil_oop);

    case STREAM_FILE:
      incPtr = INC_SAVE_POINTER ();
      fileName = _gst_get_cur_file_name ();
      INC_ADD_OOP (fileName);

      fileSegment = (gst_file_segment) new_instance (_gst_file_segment_class,
    						 &fileSegmentOOP);

      fileSegment->fileName = fileName;
      startPos = _gst_get_method_start_pos ();
      fileSegment->startPos = FROM_INT (startPos);
      fileSegment->length =
        FROM_INT (_gst_get_cur_file_pos () - startPos - 1);

      INC_RESTORE_POINTER (incPtr);
      return (fileSegmentOOP);

    case STREAM_STRING:
      stringContents = _gst_get_cur_string ();
      return (stringContents);

#ifdef HAVE_READLINE
    case STREAM_READLINE:
      stringContents = _gst_get_cur_readline ();
      return (stringContents);
#endif /* HAVE_READLINE */
    }
}

void _gst_restore_primitive_number (OOP methodOOP, int *map)
{
  gst_compiled_method method;

  method = (gst_compiled_method) OOP_TO_OBJ (methodOOP);
  method->header.primitiveIndex = map[method->header.primitiveIndex];
}
