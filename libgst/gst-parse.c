/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk language grammar definition
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2005, 2006, 2007, 2008, 2009 Free Software Foundation, Inc.
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

#include "gst.h"
#include "gstpriv.h"
#include "gst-parse.h"
#include <stdio.h>
#include <string.h>

typedef enum expr_kinds {
  EXPR_ASSIGNMENT = 1,
  EXPR_GREATER = 2,
  EXPR_BINOP = 4,
  EXPR_KEYWORD = 8,
  EXPR_CASCADE = 16,
  EXPR_CASCADED = EXPR_GREATER | EXPR_BINOP | EXPR_KEYWORD,
  EXPR_ANY = 31
} expr_kinds;


/* Used to communicate with the #methodsFor: primitive.  */
gst_parser *_gst_current_parser;

static inline mst_Boolean is_unlikely_selector (const char *);

/* Lexer interface.  */

static inline void lex_init (gst_parser *p);
static inline void lex_lookahead (gst_parser *p, int n);
static inline void lex_consume (gst_parser *p, int n);
static inline void lex (gst_parser *p);
static inline int token (gst_parser *p, int n);
static inline YYSTYPE *val (gst_parser *p, int n);
static inline YYLTYPE *loc (gst_parser *p, int n);
static inline void lex_must_be (gst_parser *p, int req_token);
static inline void lex_skip_mandatory (gst_parser *p, int req_token);
static inline mst_Boolean lex_skip_if (gst_parser *p, int req_token, mst_Boolean fail_at_eof);

/* Error recovery.  */

static void expected (gst_parser *p,
		      int token, ...)
  ATTRIBUTE_NORETURN;
static void recover_error (gst_parser *p)
  ATTRIBUTE_NORETURN;
static int filprintf (Filament *fil,
		      const char *format, ...);

/* Transform the ATTRIBUTE_KEYWORDS node (a TREE_ATTRIBUTE_LIST)
   into a Message object, and return it.  Compile the arguments
   in the context of CLASSOOP if not NULL.  */
static OOP make_attribute (gst_parser *p,
                           OOP classOOP,
			   tree_node attribute_keywords);

/* Grammar productions.  */

static void parse_chunks (gst_parser *p);
static void parse_doit (gst_parser *p,
			mst_Boolean fail_at_eof);
static mst_Boolean parse_scoped_definition (gst_parser *p, 
					    tree_node first_stmt);


static void parse_eval_definition (gst_parser *p);

static void parse_and_send_attribute (gst_parser *p,
                                      OOP receiverOOP,
                                      mst_Boolean forClass);
static mst_Boolean parse_namespace_definition (gst_parser *p,
					       tree_node first_stmt);
static mst_Boolean parse_class_definition (gst_parser *p,
					   OOP classOOP,	
					   mst_Boolean extend);
static OOP parse_namespace (gst_parser *p,
			    tree_node name);
static OOP parse_class (gst_parser *p,
			tree_node list);
static void parse_scoped_method (gst_parser *p,
				 OOP classOOP);
static void parse_instance_variables (gst_parser *p,
				      OOP classOOP,	
				      mst_Boolean extend);

static void parse_method_list (gst_parser *p);
static void parse_method (gst_parser *p,
			  int at_end);
static tree_node parse_message_pattern (gst_parser *p);
static tree_node parse_keyword_variable_list (gst_parser *p);
static tree_node parse_variable (gst_parser *p);
static tree_node parse_attributes (gst_parser *p,
				  tree_node prev_attrs);
static tree_node parse_attribute (gst_parser *p);
static tree_node parse_temporaries (gst_parser *p,
				    mst_Boolean implied_pipe);
static tree_node parse_statements (gst_parser *p,
				   tree_node first_stmt,
				   mst_Boolean accept_caret);
static tree_node parse_required_expression (gst_parser *p);
static tree_node parse_expression (gst_parser *p,
				   enum expr_kinds kind);
static tree_node parse_primary (gst_parser *p);
static tree_node parse_variable_primary (gst_parser *p);
static tree_node parse_literal (gst_parser *p,
				mst_Boolean array);
static tree_node parse_array_literal (gst_parser *p);
static tree_node parse_builtin_identifier (gst_parser *p);
static tree_node parse_byte_array_literal (gst_parser *p);
static tree_node parse_binding_constant (gst_parser *p);
static tree_node parse_compile_time_constant (gst_parser *p);
static tree_node parse_array_constructor (gst_parser *p);
static tree_node parse_block (gst_parser *p);
static tree_node parse_block_variables (gst_parser *p);
static tree_node parse_message_expression (gst_parser *p,
					   tree_node receiver,
					   enum expr_kinds kind);
static tree_node parse_cascaded_messages (gst_parser *p);
static tree_node parse_unary_expression (gst_parser *p,
					 tree_node receiver,
					 enum expr_kinds kind);
static tree_node parse_binary_expression (gst_parser *p,
					  tree_node receiver,
					  enum expr_kinds kind);
static tree_node parse_keyword_expression (gst_parser *p,
					   tree_node receiver,
					   enum expr_kinds kind);
static tree_node parse_keyword_list (gst_parser *p,
				     enum expr_kinds kind);



static int 
filprintf (Filament *fil, const char *format, ...)
{
  va_list ap;
  STREAM *out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  int result;
  va_start (ap, format);
  result = stream_vprintf (out, format, ap);
  va_end (ap);
  stream_delete (out);
  return result;
}

/* Lexer interface. Intialize the parser before using it. */

static inline void
lex_init (gst_parser *p)
{
  p->la_first = 0;
  p->la_size = 0;
  lex_lookahead (p, 1);
}

/* Lexer interface.  Get N tokens out of the stream.  */

static inline void 
lex_lookahead (gst_parser *p, int n)
{
  while (p->la_size < n)
    {
      int i = (p->la_first + p->la_size) % 4;
      p->la[i].token = _gst_yylex (&p->la[i].val, &p->la[i].loc);
      p->la_size++;
    }
}

/* Lexer interface. Eat the first N lookahead tokens. */

static inline void 
lex_consume (gst_parser *p, int n)
{
  p->la_first = (p->la_first + n) % 4;
  p->la_size -= n;
}

/* Lexer interface. Eat the last lookahead token and lex the next one */

static inline void
lex (gst_parser *p)
{
  lex_consume (p, 1);
  lex_lookahead (p, 1);
}

/* Lexer interface. Return the N-th lookahead token. */

static inline int 
token (gst_parser *p, int n) 
{
  int i = (p->la_first + n) % 4;
  return p->la[i].token;
}

/* Lexer interface. Return the value of the N-th lookahead token. */

static inline YYSTYPE*
val (gst_parser *p, int n)
{
  int i = (p->la_first + n) % 4;
  return &p->la[i].val;
}


/* Lexer interface. Return the location of the N-th lookahead token. */

static inline YYLTYPE*
loc (gst_parser *p, int n)
{
  int i = (p->la_first + n) % 4;
  return &p->la[i].loc;
}

/* Lexer interface.  Check that the next token is REQ_TOKEN and fail if
   it is not.  */

static inline void
lex_must_be (gst_parser *p, int req_token)
{
  if (token (p, 0) != req_token)
    expected (p, req_token, -1);
}

/* Lexer interface.  Check that the next token is REQ_TOKEN and eat it;
   fail if it does not match.  */

static inline void
lex_skip_mandatory (gst_parser *p, int req_token)
{
  if (token (p, 0) != req_token)
    expected (p, req_token, -1);
  else
    lex (p);
}

/* Lexer interface.  If the next token is REQ_TOKEN, eat it and return true;
   otherwise return false.  */

static inline mst_Boolean
lex_skip_if (gst_parser *p, int req_token, mst_Boolean fail_at_eof)
{
  if (token (p, 0) != req_token)
    {
      if (token (p, 0) == EOF && fail_at_eof)
	expected (p, req_token, -1);
      return false;
    }
  else
    {
      lex (p);
      return true;
    }
}


void
_gst_print_tokens (gst_parser *p)
{
  int i;
  printf ("size: %i\n", p->la_size);
  for (i = 0; i < p->la_size; i++) {
    if (token (p, i) == 264)
      printf ("%i - %i - %s\n", i, token (p, i), val (p, i)->sval); 
    else
      printf ("%i - %i\n", i, token (p, i));
  }
  printf ("\n");
}

OOP
_gst_get_current_namespace (void)
{
  if (_gst_current_parser)
    return _gst_current_parser->current_namespace;

  return _gst_current_namespace;
}

mst_Boolean
_gst_untrusted_parse (void)
{
  if (!_gst_current_parser)
    return false;

  return (_gst_current_parser->untrustedContext
          || IS_OOP_UNTRUSTED (_gst_current_parser->currentClass));
}

void
_gst_set_compilation_class (OOP class_oop)
{
  assert (IS_NIL (_gst_current_parser->currentClass));
  _gst_current_parser->currentClass = class_oop;
  _gst_register_oop (class_oop);
  _gst_compute_linearized_pools (_gst_current_parser, false);
}

void
_gst_set_compilation_category (OOP categoryOOP)
{
  assert (IS_NIL (_gst_current_parser->currentCategory));
  _gst_current_parser->currentCategory = categoryOOP;
  _gst_register_oop (categoryOOP);
}

static OOP
set_compilation_namespace (OOP namespaceOOP)
{
  OOP oldNamespaceOOP = _gst_current_parser->current_namespace;

  _gst_current_parser->current_namespace = namespaceOOP;
  if (!IS_NIL (namespaceOOP))
    {
      if (oldNamespaceOOP != namespaceOOP)
        _gst_register_oop (namespaceOOP);
      if (namespaceOOP != _gst_current_namespace)
        _gst_msg_sendf (NULL, "%v %o current: %o",
                        _gst_namespace_class, namespaceOOP);
    }

  if (!IS_NIL (oldNamespaceOOP))
    {
      if (oldNamespaceOOP != namespaceOOP)
        _gst_unregister_oop (_gst_current_parser->current_namespace);
    }

  return oldNamespaceOOP;
}

void
_gst_reset_compilation_category (void)
{
  if (!IS_NIL (_gst_current_parser->currentClass))
    {
      _gst_unregister_oop (_gst_current_parser->currentClass);
      _gst_current_parser->currentClass = _gst_nil_oop;
      _gst_free_linearized_pools ();
    }
  if (!IS_NIL (_gst_current_parser->currentCategory))
    {
      _gst_unregister_oop (_gst_current_parser->currentCategory);
      _gst_current_parser->currentCategory = _gst_nil_oop;
    }
}

static void
parser_init (gst_parser *p)
{
  memset (p, 0, sizeof(*p));
  p->currentClass = p->currentCategory = _gst_nil_oop;
  /* This should ultimately become _gst_get_current_namespace ().  */
  p->current_namespace = _gst_current_namespace;
}

/* Top of the descent.  */

OOP
_gst_parse_method (OOP currentClass, OOP currentCategory)
{
  gst_parser p, *prev_parser = _gst_current_parser;
  OOP methodOOP;
  inc_ptr incPtr;

  _gst_current_parser = &p;
  incPtr = INC_SAVE_POINTER ();
  parser_init (&p);
  p.state = PARSE_METHOD;
  p.untrustedContext = IS_OOP_UNTRUSTED (_gst_this_context_oop);
  p.current_namespace = _gst_nil_oop;
  _gst_set_compilation_class (currentClass);
  _gst_set_compilation_category (currentCategory);

  lex_init (&p);
  if (setjmp (p.recover) == 0)
    {
      parse_method (&p, ']');
      methodOOP = p.lastMethodOOP;
    }
  else
    {
      _gst_had_error = false;
      methodOOP = _gst_nil_oop;
    }

  _gst_reset_compilation_category ();
  set_compilation_namespace (_gst_nil_oop);
  _gst_current_parser = prev_parser;
  INC_RESTORE_POINTER (incPtr);
  return methodOOP;
}

void
_gst_parse_chunks (OOP currentNamespace)
{
  gst_parser p, *prev_parser = _gst_current_parser;
  inc_ptr incPtr;

  _gst_current_parser = &p;
  incPtr = INC_SAVE_POINTER ();
  parser_init (&p);
  p.untrustedContext = IS_OOP_UNTRUSTED (_gst_this_context_oop);
  if (currentNamespace)
    p.current_namespace = currentNamespace;
  p.state = PARSE_DOIT;

  lex_init (&p);
  if (token (&p, 0) == SHEBANG)
    lex (&p);

  setjmp (p.recover);
  _gst_had_error = false;
  while (token (&p, 0) != EOF)
    parse_chunks (&p);

  _gst_reset_compilation_category ();
  set_compilation_namespace (_gst_nil_oop);
  INC_RESTORE_POINTER (incPtr);
  _gst_current_parser = prev_parser;
}

static void
parse_chunks (gst_parser *p) 
{
  if (lex_skip_if (p, '!', false))
    p->state = PARSE_DOIT;
  else
    {
      OOP oldTemporaries = _gst_push_temporaries_dictionary ();
      jmp_buf old_recover;
      setjmp (p->recover);
      while (token (p, 0) != EOF && token (p, 0) != '!')
        {
          /* Pick the production here, so that subsequent 
	     methods are compiled when we come back from an error above.  */
          if (p->state == PARSE_METHOD_LIST)
	    parse_method_list (p);
          else
	    parse_doit (p, false);
        }

      lex_skip_if (p, '!', false);
      _gst_pop_temporaries_dictionary (oldTemporaries);
      memcpy (p->recover, old_recover, sizeof (p->recover));
    }
}


/* Print an error message and attempt error recovery.  All the parameters
   after P (terminated by -1) are tokens that were expected (possibly a
   subset to make the error message shorter).  */

static void
expected (gst_parser *p, int token, ...)
{
  int named_tokens = 0;
  va_list ap;
  const char *sep = ", expected";
  char *msg;

  Filament *out_fil = filnew (NULL, 0);
  filprintf (out_fil, "parse error");

  va_start (ap, token);
  while (token != -1)
    {
      if (token < 256)
	{
	  filprintf (out_fil, "%s '%c'", sep, token);
	  sep = " or";
	}
      else
	named_tokens |= 1 << (token - FIRST_TOKEN);
      token = va_arg (ap, int);
    }

#define TOKEN_DEF(name, val, str, subsume)				\
  if ((named_tokens & (1 << (val - FIRST_TOKEN))) != 0			\
      && (subsume == -1							\
	  || (named_tokens & (1 << (subsume - FIRST_TOKEN))) == 0))	\
    {									\
      filprintf (out_fil, "%s %s", sep, str);				\
      sep = " or";							\
    }

  TOKEN_DEFS
#undef TOKEN_DEF

    msg = fildelete (out_fil);
  _gst_errorf ("%s", msg);
  free (msg);
  recover_error (p);
}


/* Perform error recovery and longjmp out of the parser.  */

static void
recover_error (gst_parser *p)
{
  if (p->state != PARSE_METHOD)
    {
      _gst_error_recovery = true;

      /* Find the final bang or, if in the REPL, a newline.  */
      while (token (p, 0) != EOF
	     && token (p, 0) != '!'
	     && token (p, 0) != ERROR_RECOVERY)
	lex (p);

      _gst_error_recovery = false;
      lex_skip_if (p, ERROR_RECOVERY, false);
    }

  longjmp (p->recover, 1);
}

static OOP
execute_doit (gst_parser *p, tree_node temps, tree_node stmts,
              OOP receiverOOP,
	      mst_Boolean undeclared, mst_Boolean quiet)
{
  tree_node method;
  mst_Boolean in_class;
  OOP resultOOP;
  inc_ptr incPtr;

  in_class = !IS_NIL (p->currentClass);
  if (!in_class)
    {
      assert (p == _gst_current_parser);
      if (receiverOOP)
        _gst_set_compilation_class (OOP_CLASS (receiverOOP));
      else
        {
          /* Let doits access the variables and classes in the current namespace.  */
          set_compilation_namespace (p->current_namespace);
	  receiverOOP = _gst_nil_oop;
          p->currentClass = _gst_undefined_object_class;
          _gst_register_oop (p->currentClass);
          _gst_compute_linearized_pools (p, true);
        }
    }

  if (stmts->nodeType != TREE_STATEMENT_LIST)
    stmts = _gst_make_statement_list (&stmts->location, stmts);

  method =
    _gst_make_method (&stmts->location, loc(p, 0),
                      NULL, temps, NULL, stmts,
                      _gst_get_current_namespace (),
                      _gst_current_parser->currentClass,
                      _gst_nil_oop,
                      _gst_untrusted_parse (),
                      false);

  resultOOP = _gst_execute_statements (receiverOOP, method, undeclared, quiet);
  incPtr = INC_SAVE_POINTER ();
  INC_ADD_OOP (resultOOP);

  if (!in_class && p->state != PARSE_METHOD_LIST)
    _gst_reset_compilation_category ();

  /* Store Smalltalk's notion of current namespace back to the parser.  */
  set_compilation_namespace (_gst_current_namespace);
  INC_RESTORE_POINTER (incPtr);
  return resultOOP;
}

/* doit: temporaries statements '!' [ method_list '!' ]
   | empty */

static void
parse_doit (gst_parser *p, mst_Boolean fail_at_eof)
{
  tree_node statement = NULL;
  mst_Boolean caret;

  if (token (p, 0) == '|')
    parse_temporaries (p, false);

  if (token (p, 0) == EOF && !fail_at_eof)
    return;

  caret = lex_skip_if (p, '^', false);
  statement = parse_required_expression (p);
  if (!caret && lex_skip_if (p, '[', false))
    {
      if (parse_scoped_definition (p, statement))
        lex_skip_mandatory (p, ']'); 
      else
        {
          while (!lex_skip_if (p, ']', true))
	    lex (p);
	}
    }
  else if (statement)
    {
      execute_doit (p, NULL, statement, NULL, true, false);

      /* Because a '.' could be inserted automagically, the next token
         value might be already on the obstack.  Do not free in that
         case!  */
      if (p->la_size == 0)
        _gst_free_tree ();
    }

  _gst_had_error = false;

  /* Do not lex until after _gst_free_tree, or we lose a token! */
  lex_skip_if (p, '.', false);
}


/* scoped_definition: eval_definition
   | class_definition 
   | namespace_definition */

static mst_Boolean
parse_scoped_definition (gst_parser *p, tree_node first_stmt)
{	
  OOP classOOP = NULL;
  tree_node receiver = first_stmt->v_expr.receiver;
  tree_node expression = first_stmt->v_expr.expression;
  
#if 0
  _gst_print_tree (first_stmt, 0);
#endif
	
  if (first_stmt->nodeType == TREE_VARIABLE_NODE
      && strcmp (first_stmt->v_list.name, "Eval") == 0)
    {
      parse_eval_definition (p);
      return true;
    }	
  
  if (first_stmt->nodeType == TREE_KEYWORD_EXPR
      && receiver->nodeType == TREE_VARIABLE_NODE
      && expression->v_list.value->nodeType == TREE_VARIABLE_NODE
      && expression->v_list.next == NULL)
    {
      if (strcmp (receiver->v_list.name, "Namespace") == 0
	  && strcmp (expression->v_list.name, "current:") == 0)
	return parse_namespace_definition (p, first_stmt);
      
      if (strcmp (expression->v_list.name, "subclass:") == 0
	  && (classOOP = parse_class (p, receiver)) != NULL)
	{
	  const char * name = expression->v_list.value->v_list.name;
	  _gst_msg_sendf (&classOOP, "%o %o subclass: %S environment: %o",
                          classOOP, name, p->current_namespace);
	      
	  if (IS_NIL (classOOP))
	    _gst_had_error = true;
	  else
	    return parse_class_definition (p, classOOP, false);  
	}
    }

  else if (first_stmt->nodeType == TREE_UNARY_EXPR
	   && first_stmt->v_expr.selector == _gst_intern_string ("extend"))
    {
      OOP classOrMetaclassOOP = NULL;
      mst_Boolean ret_value;

      if (receiver->nodeType == TREE_VARIABLE_NODE)
 	{
 	  classOOP = parse_class (p, receiver);
	  classOrMetaclassOOP = classOOP;
 	}
      else if (receiver->nodeType == TREE_UNARY_EXPR
	       && receiver->v_expr.selector == _gst_intern_string ("class"))
 	{
 	  classOOP = parse_class (p, receiver->v_expr.receiver);
	  classOrMetaclassOOP = classOOP ? OOP_CLASS (classOOP) : NULL;
 	}	   
      if (classOrMetaclassOOP != NULL) 
 	{
          inc_ptr incPtr = INC_SAVE_POINTER ();
 	  OOP namespace_new = ((gst_class) OOP_TO_OBJ (classOOP))->environment;
          OOP namespace_old = set_compilation_namespace (namespace_new);
          INC_ADD_OOP (namespace_old);
 	  ret_value = parse_class_definition (p, classOrMetaclassOOP, true);
          set_compilation_namespace (namespace_old);
 	  INC_RESTORE_POINTER (incPtr);
 	  return ret_value;
 	}
    }

  _gst_errorf_at (first_stmt->location.first_line, 
		  "expected Eval, Namespace or class definition"); 
  return false;
}

static void
parse_eval_definition (gst_parser *p)
{
  tree_node tmps = NULL, stmts = NULL;
  OOP oldDictionary = _gst_push_temporaries_dictionary ();
  jmp_buf old_recover;

  assert (IS_NIL (_gst_current_parser->currentClass));
  memcpy (old_recover, p->recover, sizeof (p->recover));
  if (setjmp (p->recover) == 0)
    {
      tmps = parse_temporaries (p, false);
      stmts = parse_statements (p, NULL, true);
      lex_must_be (p, ']');
    }

  if (stmts && !_gst_had_error)
    {
      OOP resultOOP;
      if (_gst_regression_testing)
        {
          printf ("\nExecution begins...\n");
	  fflush (stdout);
	  fflush (stderr);
        }

      resultOOP = execute_doit (p, tmps, stmts, NULL, true,
                                _gst_regression_testing);

      if (_gst_regression_testing)
        {
          if (!_gst_had_error)
            printf ("returned value is %O\n", resultOOP);
	  fflush (stdout);
	  fflush (stderr);
        }

      _gst_had_error = false;
    }

  assert (p->la_size <= 1);
  _gst_free_tree ();
  _gst_pop_temporaries_dictionary (oldDictionary);
  memcpy (p->recover, old_recover, sizeof (p->recover));
  if (_gst_had_error)
    longjmp (p->recover, 1);
}

static OOP
make_attribute (gst_parser *p, OOP classOOP, tree_node attribute_keywords)
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
  numArgs = _gst_list_length (attribute_keywords);
  argsArray = instantiate_with (_gst_array_class, numArgs, &argsArrayOOP);
  INC_ADD_OOP (argsArrayOOP);

  for (i = 0, keyword = attribute_keywords; keyword != NULL;
       i++, keyword = keyword->v_list.next)
    {
      tree_node value = keyword->v_list.value;
      OOP result = execute_doit (p, NULL, value, classOOP, false, true);
      if (!result)
        {
          _gst_had_error = true;
          INC_RESTORE_POINTER (incPtr);
          return _gst_nil_oop;
        }

      argsArray = OOP_TO_OBJ (argsArrayOOP);
      argsArray->data[i] = result;
    }

  messageOOP = _gst_message_new_args (selectorOOP, argsArrayOOP);
  INC_RESTORE_POINTER (incPtr);

  MAKE_OOP_READONLY (argsArrayOOP, true);
  MAKE_OOP_READONLY (messageOOP, true);
  return (messageOOP);
}


static void
parse_and_send_attribute (gst_parser *p, OOP receiverOOP, mst_Boolean forClass)
{
  tree_node keywords;

  lex_skip_mandatory (p, '<');
  keywords = parse_keyword_list (p, EXPR_BINOP);
  if (!_gst_had_error)
    {
      OOP messageOOP;
      messageOOP = make_attribute (p, forClass ? receiverOOP : _gst_nil_oop, keywords);
      if (!IS_NIL (messageOOP))
        {
          OOP selectorOOP = MESSAGE_SELECTOR (messageOOP);
          OOP argsOOP = MESSAGE_ARGS (messageOOP);
	  int numArgs = NUM_OOPS (OOP_TO_OBJ (argsOOP));
          OOP *args = alloca(numArgs * sizeof (OOP));
          memcpy (args, OOP_TO_OBJ (argsOOP)->data, numArgs * sizeof (OOP));
          _gst_nvmsg_send (receiverOOP, selectorOOP, args, numArgs);
        }
    }

  lex_skip_mandatory (p, '>');
}


static mst_Boolean
parse_namespace_definition (gst_parser *p, tree_node first_stmt)
{      
  tree_node expr = first_stmt->v_expr.expression;
  OOP new_namespace = parse_namespace (p, expr->v_list.value);
  
  if (new_namespace)
    {
      inc_ptr incPtr = INC_SAVE_POINTER ();
      OOP old_namespace = set_compilation_namespace (new_namespace);
      INC_ADD_OOP (old_namespace);
      while (token (p, 0) != ']' && token (p, 0) != EOF && token (p, 0) != '!')
	{
	  if (token (p, 0) == '<')
	    parse_and_send_attribute (p, new_namespace, false);
	  else
	    parse_doit (p, true);
	}

      set_compilation_namespace (old_namespace);
      INC_RESTORE_POINTER (incPtr);
      return true;
    } 

  return false;
}

static mst_Boolean
parse_class_definition (gst_parser *p, OOP classOOP, mst_Boolean extend)
{
  mst_Boolean add_inst_vars = extend;

  for (;;)
    {
      int t1, t2, t3;
      if (_gst_had_error)
	break;

      lex_lookahead (p, 1);
      if (token (p, 0) == ']' || token (p, 0) == EOF)
	break;

#if 0
      print_tokens (p);      
#endif
      
      t1 = token (p, 0);

      switch (t1) 
	{	
	case '>':
	case '-':
	case BINOP:
	case KEYWORD:
#if 0
	  printf ("parse method\n");
#endif

	  _gst_set_compilation_class (classOOP);
	  parse_method (p, ']');
	  _gst_reset_compilation_category ();
	  continue;
	  
	case '<':
	  lex_lookahead (p, 2);
	  t2 = token (p, 1);
	  if (t2 == IDENTIFIER) 
	    {
#if 0
	      printf ("parse method\n");
#endif

	      _gst_set_compilation_class (classOOP);
	      parse_method (p, ']');
	      _gst_reset_compilation_category ();
	      continue;
	    }
	  else if (t2 == KEYWORD) 
	    {
	      parse_and_send_attribute (p, classOOP, true);
	      continue;
	    }
	  break;
   
	case IDENTIFIER:
	  lex_lookahead (p, 2);
	  t2 = token (p, 1);
	  if (t2 == ASSIGNMENT)
	    {
#if 0
	      printf ("parse class variable\n");
#endif

 	      OOP name, class_var_dict, result;
	      tree_node stmt;
	      OOP the_class = classOOP;
	      if (IS_A_METACLASS (classOOP))
		the_class = METACLASS_INSTANCE (classOOP);

	      name = _gst_intern_string (val (p, 0)->sval);

	      lex_skip_mandatory (p, IDENTIFIER);
	      lex_skip_mandatory (p, ASSIGNMENT);

	      class_var_dict = _gst_class_variable_dictionary (the_class);
	      if (IS_NIL (class_var_dict))
		{
		  gst_class class;
		  class_var_dict = _gst_binding_dictionary_new (8, the_class);
		  class = (gst_class) OOP_TO_OBJ (the_class);
		  class->classVariables = class_var_dict;
		}

	      stmt = parse_required_expression (p);
	      if (!_gst_had_error)
		{
	          stmt = _gst_make_statement_list (&stmt->location, stmt);
	          result = execute_doit (p, NULL, stmt, the_class, false, true);

	          if (result)
		    DICTIONARY_AT_PUT (class_var_dict, name, result);
		  else
		    _gst_had_error = true;
		}

	      if (token (p, 0) != ']')
		lex_skip_mandatory(p, '.');	      
	      continue;
	    }
	  else if (t2 == BINOP)
	    {
#if 0
	      printf ("parse method\n");
#endif
	      parse_scoped_method (p, classOOP);
	      continue;
	    }
	  else if (t2 == '[')
	    {
#if 0
	      printf ("parse method\n");
#endif

	      _gst_set_compilation_class (classOOP);
	      parse_method (p, ']');
	      _gst_reset_compilation_category ();
	      continue;
	    }
	  else if (t2 == SCOPE_SEPARATOR)
	    {
#if 0 
	      printf ("parse method qualified name\n");
#endif

	      parse_scoped_method (p, classOOP);
	      continue;
	    }
	  else if (t2 == IDENTIFIER)
	    {
	      lex_lookahead (p, 3);
	      t3 = token (p, 2);
	      if (t3 == BINOP) 
		{
#if 0
		  printf ("parse class method\n");
#endif
		  parse_scoped_method (p, classOOP);
		  continue;
		}
	      else if (t3 == '[' && strcmp (val (p, 1)->sval, "class") == 0)
		{
#if 0
		  printf ("parse class protocol\n");
#endif
		  if (_gst_object_is_kind_of (classOOP, _gst_metaclass_class))
		    {
		      _gst_errorf ("already on class side");
		      _gst_had_error = true;
		      continue;
		    }
		  else if (((gst_class) OOP_TO_OBJ (classOOP))->name
			   != _gst_intern_string (val (p, 0)->sval))
		    {
		      _gst_errorf ("`%s class' invalid within %O",
				   val (p, 0)->sval, classOOP);
		      _gst_had_error = true;
		      continue;
		    }
		  else
		    {
		      lex_consume (p, 3);
		      parse_class_definition (p, OOP_CLASS (classOOP), extend);
		      lex_skip_mandatory (p, ']');
		    }
		  continue;
		}
	    }
	  break;
	  
	case '|':
	  lex_lookahead (p, 2);
	  t2 = token (p, 1);
	  if (t2  == '|') 
	    {
#if 0
	      printf ("parse instance variables - ignore\n");
#endif
	      lex_consume (p, 2);
	      continue;
	    }
	  else if (t2 == IDENTIFIER) 
	    {
	      lex_lookahead (p, 3);
	      t3 = token (p, 2);
	      if (t3 == IDENTIFIER || t3 == '|') 
		{
#if 0
		  printf ("parse instance variables\n");
#endif
		  parse_instance_variables (p, classOOP, add_inst_vars);
		  add_inst_vars = true;
		  continue;
		}
	      else if (t3 == '[')
		{
#if 0
		  printf ("parse method\n");
#endif
		  _gst_set_compilation_class (classOOP);
		  parse_method (p, ']');
		  _gst_reset_compilation_category ();
		  continue;
		}
	    }   
	  break;
   
	default:
	  break;
	}

      _gst_errorf ("invalid class body element");
      _gst_had_error = true;
    }

  return !_gst_had_error;
}

static void 
parse_scoped_method (gst_parser *p, OOP classOOP)
{
  OOP class, classInstanceOOP;
  tree_node class_node;
  mst_Boolean class_method = false;

  class_node = parse_variable_primary (p);
  class = parse_class (p, class_node);

  if (OOP_CLASS (classOOP) == _gst_metaclass_class)
    classInstanceOOP = METACLASS_INSTANCE (classOOP);
  else
    classInstanceOOP = classOOP;

  if (token (p, 0) == IDENTIFIER)
    {
      if ((strcmp (val (p, 0)->sval, "class") == 0))
	{
	  class_method = true;
	  lex_skip_mandatory (p, IDENTIFIER);
	}
      else
	_gst_errorf("expected `class' or `>>'");
    }
  
  lex_must_be (p, BINOP);
  if (strcmp (val (p, 0)->sval, ">>") == 0)
    lex_skip_mandatory (p, BINOP);
  else
    _gst_errorf ("expected `>>'");
  
  if (!class_method && OOP_CLASS (classOOP) == _gst_metaclass_class)
    {
      _gst_skip_compilation = true;
      _gst_errorf ("class method expected inside class block");
    }

  else if (!class)
    {
      _gst_skip_compilation = true;
      class = classOOP;
    }

  else if (!_gst_class_is_kind_of (classInstanceOOP, class))
    {
      _gst_skip_compilation = true;
      _gst_errorf ("%#O is not %#O or one of its superclasses",
		   ((gst_class) OOP_TO_OBJ (class))->name,
		   ((gst_class) OOP_TO_OBJ (classOOP))->name);
    }

  else
    {
      if (class_method) 
	class = OOP_CLASS (class);
    }

  _gst_set_compilation_class (class);
  parse_method (p, ']');
  _gst_reset_compilation_category ();
  _gst_skip_compilation = false;
}

static OOP
parse_class (gst_parser *p,
	     tree_node list) 
{
  const char* name;
  OOP currentOOP = p->current_namespace;
  tree_node next; 

  if (strcmp (list->v_list.name, "nil") == 0)
      return _gst_nil_oop;
  
  do
    {
      name = list->v_list.name;
      currentOOP = _gst_namespace_at (currentOOP, _gst_intern_string (name));
	
      if (currentOOP == _gst_nil_oop)
	{
	  _gst_errorf_at (list->location.first_line, "key %s not found", name);
	  return NULL;
	}

      next = list->v_list.next;
      if (next == NULL)
	{
	  if (!_gst_object_is_kind_of (currentOOP, _gst_class_class)) 
	    {
	      _gst_errorf_at (list->location.first_line,
			      "expected class named %s, found %O", 
			   name, OOP_INT_CLASS (currentOOP));
	      return NULL;
	    }
	}
      else
	{
	  if (!_gst_object_is_kind_of (currentOOP, _gst_dictionary_class))
	    {
	      _gst_errorf_at  (list->location.first_line,
			       "expected namespace named %s, found %O", 
			       name, OOP_INT_CLASS (currentOOP));
	      return NULL;
	    }
	}
      list = next;
    }
  while (list != NULL);
		
  return currentOOP;
}

static OOP
parse_namespace (gst_parser *p, tree_node list) 
{
  OOP name, new_namespace, current_namespace;
  const char *namespc;
	
  current_namespace = p->current_namespace;
  while (list->v_list.next != NULL)
    {
      name = _gst_intern_string (list->v_list.name);	
      current_namespace = _gst_namespace_at (current_namespace, name);
		
      if (current_namespace == _gst_nil_oop)
	{
	  _gst_errorf_at (list->location.first_line, 
			  "key %s not found", list->v_list.name);
	  return NULL;
	}
      
      if (!_gst_object_is_kind_of (current_namespace, _gst_dictionary_class))
	{
	  _gst_errorf_at (list->location.first_line, 
			  "expected namespace named %s, found %O", 
			  list->v_list.name, OOP_INT_CLASS (current_namespace));
	  return NULL;
	}

      list = list->v_list.next;
    }
		
  namespc = list->v_list.name;
  name = _gst_intern_string (namespc);
  new_namespace = dictionary_at (current_namespace, name);

  if (new_namespace == _gst_nil_oop) 
    _gst_msg_sendf (&current_namespace, "%o %o addSubspace: %o",
		    current_namespace, name);

  else if (_gst_object_is_kind_of (new_namespace, _gst_dictionary_class))
    current_namespace = new_namespace;

  else
    _gst_errorf_at (list->location.first_line, 
		    "expected namespace named %s, found %O", namespc,
		    OOP_INT_CLASS (new_namespace));

  return current_namespace;
}

/* method_list: method_list method '!'
   | empty */

static void
parse_instance_variables (gst_parser *p, OOP classOOP, mst_Boolean extend)
{
  char *vars;
  Filament *fil = filnew (NULL, 0);
  
  if (extend)
    {
      gst_behavior class = (gst_behavior) OOP_TO_OBJ (classOOP);
      OOP *instVars = OOP_TO_OBJ (class->instanceVariables)->data;
      int n = CLASS_FIXED_FIELDS (classOOP);
      OOP superclassOOP = SUPERCLASS (classOOP);
      if (!IS_NIL (superclassOOP))
	{
	  int superclassVars = CLASS_FIXED_FIELDS (superclassOOP);
	  instVars += superclassVars;
	  n -= superclassVars;
	}
      for (; n--; instVars++)
	{
	  char *s = _gst_to_cstring (*instVars);
          filprintf (fil, "%s ", s);
	  xfree (s);
	}
    }

  lex_skip_mandatory (p, '|');
  while (!lex_skip_if (p, '|', true))
    {
      lex_must_be (p, IDENTIFIER);
      filprintf (fil, "%s ", val (p, 0)->sval);
      lex (p);
    }

  vars = fildelete (fil);
  _gst_msg_sendf (NULL, "%v %o instanceVariableNames: %S", classOOP, vars);
  free (vars);
}

static void
parse_method_list (gst_parser *p)
{
  jmp_buf old_recover;
  memcpy (old_recover, p->recover, sizeof (p->recover));
  if (setjmp (p->recover) == 0)
    {
      while (token (p, 0) != '!')
        parse_method (p, '!');
    }

  memcpy (p->recover, old_recover, sizeof (p->recover));
  _gst_skip_compilation = false;
  _gst_reset_compilation_category ();
  p->state = PARSE_DOIT;
}


/* method: message_pattern temporaries attributes statements */

static void
parse_method (gst_parser *p, int at_end)
{
  tree_node pat, temps, stmts, attrs = NULL;
  YYLTYPE current_pos;
  tree_node method;

  pat = parse_message_pattern (p);

  if (at_end == ']')
    lex_skip_mandatory (p, '[');

  if (token (p, 0) == '<')
    attrs = parse_attributes (p, NULL);

  temps = parse_temporaries (p, false);

  if (token (p, 0) == '<')
    attrs = parse_attributes (p, attrs);

  stmts = parse_statements (p, NULL, true);

  /* Don't lex until _gst_free_tree, or we lose a token.  */
  lex_must_be (p, at_end);

  /* Still, include the ']' in the method source code.  */
  current_pos = _gst_get_location ();
  if (at_end == ']')
    current_pos.file_offset++;

  method = _gst_make_method (&pat->location, &current_pos,
			     pat, temps, attrs, stmts, NULL,
			     _gst_current_parser->currentClass,
			     _gst_current_parser->currentCategory,
			     _gst_untrusted_parse (),
			     at_end != ']');

  if (!_gst_had_error && !_gst_skip_compilation)
    {
      _gst_current_parser->lastMethodOOP =
        _gst_compile_method (method, false, true, false);
      INC_ADD_OOP (_gst_current_parser->lastMethodOOP);
    }

  assert (p->la_size <= 1);
  _gst_free_tree ();
  _gst_had_error = false;
  if (at_end != EOF)
    lex (p);
}


/* message_pattern: unary_pattern
   | binary_pattern
   | keyword_pattern

   unary_pattern: IDENTIFIER
   binary_pattern: binop IDENTIFIER
   keyword_pattern: keyword_pattern KEYWORD IDENTIFIER
   | KEYWORD IDENTIFIER
   binop : BINOP | '<' | '>' | '-' | '|' */

static tree_node
parse_message_pattern (gst_parser *p)
{
  YYLTYPE location = *loc (p, 0);
  tree_node pat, arg;
  char *sval = val(p, 0)->sval;

  switch (token (p, 0))
    {
    case IDENTIFIER:
      lex (p);
      pat = _gst_make_unary_expr (&location, NULL, sval); 
      break;

    case BINOP:
    case '<':
    case '>':
    case '-':
    case '|':
      lex (p);
      arg = parse_variable (p);
      pat = _gst_make_binary_expr (&location, NULL, sval, arg);
      break;

    case KEYWORD:
      pat = parse_keyword_variable_list (p);
      pat = _gst_make_keyword_expr (&location, NULL, pat);
      break;

    default:
      expected (p, IDENTIFIER, BINOP, KEYWORD, -1);
    }

  return pat;
}

static tree_node
parse_keyword_variable_list (gst_parser *p)
{
  YYLTYPE location = *loc (p, 0);
  tree_node pat = NULL, arg;

  do
    {
      char *sval = val(p, 0)->sval;
      lex (p);
      arg = parse_variable (p);
      pat = _gst_add_node (pat, _gst_make_keyword_list (&location, sval, arg));
    }
  while (token (p, 0) == KEYWORD);

  return pat;
}


/* variable: IDENTIFIER */

static tree_node
parse_variable (gst_parser *p)
{
  tree_node var;

  lex_must_be (p, IDENTIFIER);
  var = _gst_make_variable (loc (p, 0), val(p, 0)->sval); 
  lex (p);
  return var;
}


/* attributes: attributes '<' attribute_keywords '>'
   | empty

   attribute_keywords: attribute KEYWORD binary_expr 
   | KEYWORD binary_expr */

static tree_node
parse_attributes (gst_parser *p, tree_node prev_attrs)
{
  while (token (p, 0) == '<')
    {
      tree_node attr = parse_attribute (p);
      if (attr)
	prev_attrs = _gst_add_node (prev_attrs, attr);
    }

  return prev_attrs;
}

static tree_node
parse_attribute (gst_parser *p)
{
  tree_node message, attr, constant;
  OOP attributeOOP, selectorOOP, argsOOP;
  char *sel;
  YYLTYPE location = *loc (p, 0);

  lex_skip_mandatory (p, '<');
  if (token (p, 0) == IDENTIFIER)
    {
      sel = val(p, 0)->sval;
      lex (p);
      selectorOOP = _gst_intern_string (sel);
      new_instance_with (_gst_array_class, 0, &argsOOP);
      MAKE_OOP_READONLY (selectorOOP, true);
      MAKE_OOP_READONLY (argsOOP, true);
      message = _gst_make_unary_expr (&location, NULL, sel);
      attributeOOP = _gst_message_new_args (selectorOOP, argsOOP);
    }
  else
    {
      lex_must_be (p, KEYWORD);
      message = parse_keyword_list (p, EXPR_BINOP);

      /* First convert the TREE_KEYWORD_EXPR into a Message object, then
	 into a TREE_CONST_EXPR, and finally embed this one into a
	 TREE_ATTRIBUTE_LIST.  */
      attributeOOP = make_attribute (p, _gst_nil_oop, message);
    }
  constant = _gst_make_oop_constant (&message->location, attributeOOP);
  attr = _gst_make_attribute_list (&constant->location, constant);
  lex_skip_mandatory (p, '>');
  return attr;
}


/* temporaries: '|' variables '|'
   | empty
   temp_no_pipe: variables '|'
   variables: variables variable
   | empty */

static tree_node
parse_temporaries (gst_parser *p, mst_Boolean implied_pipe)
{
  tree_node temps = NULL;
  if (!implied_pipe && !lex_skip_if (p, '|', false))
    return NULL;

  while (!lex_skip_if (p, '|', true))
    {
      tree_node temp;
      if (token (p, 0) != IDENTIFIER)
	expected (p, '|', IDENTIFIER, -1);
      temp = parse_variable (p);
      temp = _gst_make_variable_list (&temp->location, temp); 
      temps = _gst_add_node (temps, temp);
    }

  return temps;
}


/* statements: statements_no_ret return_statement opt_dot
   | statements_no_ret opt_dot
   statements_no_ret: statements_no_ret '.' statement
   | empty
   opt_dot: '.'
   | empty */

static tree_node
parse_statements (gst_parser *p, tree_node first_stmt, mst_Boolean accept_caret)
{
  tree_node stmts, stmt;
  mst_Boolean caret;

  if (first_stmt)
    {
      stmts = _gst_make_statement_list (&first_stmt->location, first_stmt);
      if (!lex_skip_if (p, '.', false))
	return stmts;
    }
  else
    stmts = NULL;

  do
    {
      caret = accept_caret && lex_skip_if (p, '^', false);
      if (caret)
	{
          stmt = parse_required_expression (p);
	  stmt = _gst_make_return (&stmt->location, stmt);
	}
      else
	{
          stmt = parse_expression (p, EXPR_ANY);
	  if (stmt == NULL)
	    break;
	}

      stmt = _gst_make_statement_list (&stmt->location, stmt);
      stmts = _gst_add_node (stmts, stmt);
    }
  while (lex_skip_if (p, '.', false) && !caret);
  return stmts;
}



/* expression: primary
   | variable ':=' expression
   | message_expression cascaded_messages */

static tree_node
parse_expression (gst_parser *p, enum expr_kinds kind)
{
  tree_node node, assigns = NULL;
  for (;;)
    {
      if (token (p, 0) != IDENTIFIER)
	{
	  node = parse_primary (p);
	  break;
	}
      else
	{
	  node = parse_variable_primary (p);
	  if (!node
	      || (kind & EXPR_ASSIGNMENT) == 0
	      || !lex_skip_if (p, ASSIGNMENT, false))
	    break;
	}

      assigns = _gst_add_node (assigns,
			       _gst_make_assignment_list (&node->location,
							  node));
    }

  if (!node && assigns)
    {
      _gst_errorf ("expected expression");
      recover_error (p);
    }

  if (node)
    {
      node = parse_message_expression (p, node, kind & ~EXPR_ASSIGNMENT);
      assert (node);
    }

  if (assigns)
    node = _gst_make_assign (&assigns->location, assigns, node);

  return node;
}

static tree_node
parse_required_expression (gst_parser *p)
{
  tree_node stmt = parse_expression (p, EXPR_ANY);
  if (!stmt)
    {
      _gst_errorf ("expected expression");
      recover_error (p);
    }
  return stmt;
}

/* primary: variable_primary
   | '(' expression ')'
   | literal
   | block
   | array_constructor */

static tree_node
parse_primary (gst_parser *p)
{
  tree_node node;

  switch (token (p, 0))
    {
    case IDENTIFIER:
      node = parse_variable_primary (p);
      break;

    case STRING_LITERAL:
    case SYMBOL_LITERAL:
    case INTEGER_LITERAL:
    case LARGE_INTEGER_LITERAL:
    case FLOATD_LITERAL:
    case FLOATE_LITERAL:
    case FLOATQ_LITERAL:
    case SCALED_DECIMAL_LITERAL:
    case CHAR_LITERAL:
    case '#':
    case '-':
      node = parse_literal (p, false);
      break;

    case '[':
      node = parse_block (p);
      break;

    case '{':
      node = parse_array_constructor (p);
      break;

    case '(':
      lex (p);
      node = parse_required_expression (p);
      lex_skip_mandatory (p, ')');
      break;

    default:
      return NULL;
    }

  return node;
}


/* variable_primary: variable_primary SCOPE_SEPARATOR IDENTIFIER
   | IDENTIFIER  */

static tree_node
parse_variable_primary_1 (gst_parser *p, YYLTYPE *first_loc,
			  const char *first_val)
{
  tree_node node;
  assert (token (p, 0) == IDENTIFIER);
  node = _gst_make_variable (first_loc, first_val);
  for (;;)
    {
      lex (p);
      if (!lex_skip_if (p, SCOPE_SEPARATOR, false))
	break;

      lex_must_be (p, IDENTIFIER);
      node = _gst_add_node (node, _gst_make_variable (loc (p, 0), val(p, 0)->sval));
    }

  return node;
}

static tree_node
parse_variable_primary (gst_parser *p)
{
  return parse_variable_primary_1 (p, loc (p, 0), val(p, 0)->sval);
}


/* array_literal_elt: array_literal
   | byte_array_literal
   | literal
   | builtin_identifier

   literal: <any literal token>
   | '#' array_literal
   | '#' byte_array_literal
   | '#' binding_constant
   | '#' '#' compile_time_constant */

static tree_node
parse_literal (gst_parser *p, mst_Boolean array)
{
  tree_node node;
  int ival;
  int tok = token (p, 0);

  switch (tok)
    {
    case '-':
      lex (p);
      tok = token (p, 0);
      switch (tok)
	{
	case INTEGER_LITERAL:
	case LARGE_INTEGER_LITERAL:
	case FLOATD_LITERAL:
	case FLOATE_LITERAL:
	case FLOATQ_LITERAL:
	case SCALED_DECIMAL_LITERAL:
          if (_gst_negate_yylval (tok, val (p, 0)))
	    return parse_literal (p, array);
	  else
	    {
	      _gst_errorf ("parse error, expected positive numeric literal");
	      recover_error (p);
	    }

	default:
	  expected (p, INTEGER_LITERAL, FLOATD_LITERAL, SCALED_DECIMAL_LITERAL,
		    -1);
	}
      break;

    case '(':
      assert (array);
      node = parse_array_literal (p);
      return node;

    case '[':
      assert (array);
      node = parse_byte_array_literal (p);
      return node;

    case IDENTIFIER:
      node = parse_builtin_identifier (p);
      return node;

    case STRING_LITERAL:
      node = _gst_make_string_constant (loc (p, 0), val(p, 0)->sval);
      break;

    case SYMBOL_LITERAL:
      node = _gst_intern_ident (loc (p, 0), val(p, 0)->sval);
      node = _gst_make_symbol_constant (loc (p, 0), node); 
      break;

    case INTEGER_LITERAL:
      node = _gst_make_int_constant (loc (p, 0), val(p, 0)->ival);
      break;

    case LARGE_INTEGER_LITERAL:
      node = _gst_make_byte_object_constant (loc (p, 0), val(p, 0)->boval);
      break;

    case FLOATD_LITERAL:
      node = _gst_make_float_constant (loc (p, 0), val(p, 0)->fval, CONST_FLOATD);
      break;

    case FLOATE_LITERAL:
      node = _gst_make_float_constant (loc (p, 0), val(p, 0)->fval, CONST_FLOATE);
      break;

    case FLOATQ_LITERAL:
      node = _gst_make_float_constant (loc (p, 0), val(p, 0)->fval, CONST_FLOATQ);
      break;

    case SCALED_DECIMAL_LITERAL:
      node = _gst_make_oop_constant (loc (p, 0), val(p, 0)->oval);
      break;

    case CHAR_LITERAL:
      ival = val(p, 0)->ival;
      lex (p);

      /* Special case $< INTEGER_LITERAL > where the integer literal
	 is positive.  */
      if (ival == '<' && token (p, 0) == INTEGER_LITERAL && val(p, 0)->ival >= 0)
        {
	  ival = val(p, 0)->ival;
          lex (p);
	  lex_skip_mandatory (p, '>');

          if (ival > 0x10FFFF)
	    {
	      _gst_errorf ("character code point out of range");
	      recover_error (p);
	    }
        }

      return _gst_make_char_constant (loc (p, 0), ival);

    case '#':
      lex (p);
      switch (token (p, 0))
        {
	case '(':
	case '[':
	  return parse_literal (p, true);

	case '#':
	  return parse_compile_time_constant (p);

	case '{':
	  return parse_binding_constant (p);

	default:
	  expected (p, '(', '[', '#', '{', -1);
	}
      break;

    default:
      return NULL;
    }

  lex (p);
  return node;
}


/* array_literal: '(' array_literal_elts ')'
   array_literal_elts: array_literal_elts array_literal_elt
   | empty  */

static tree_node
parse_array_literal (gst_parser *p)
{
  tree_node elts = NULL;
  assert (token (p, 0) == '(');
  lex (p);

  while (!lex_skip_if (p, ')', true))
    {
      tree_node lit = parse_literal (p, true);
      if (lit == NULL)
	return NULL;
      elts = _gst_add_node (elts, _gst_make_array_elt (&lit->location, lit));
    }

  return _gst_make_array_constant (elts ? &elts->location : loc (p, 0), elts);
}


/* builtin_identifier: "true" | "false" | "nil" */

static tree_node
parse_builtin_identifier (gst_parser *p)
{
  OOP symbolOOP;
  tree_node node;
  YYLTYPE location = *loc(p,0);

  assert (token (p, 0) == IDENTIFIER);
  symbolOOP = _gst_intern_string (val(p, 0)->sval);
  if (symbolOOP == _gst_true_symbol)
    node = _gst_make_oop_constant (&location, _gst_true_oop);

  else if (symbolOOP == _gst_false_symbol)
    node = _gst_make_oop_constant (&location, _gst_false_oop);

  else if (symbolOOP == _gst_nil_symbol)
    node = _gst_make_oop_constant (&location, _gst_nil_oop);

  else
    {
      _gst_errorf ("expected true, false or nil");
      recover_error (p);
    }

  lex (p);
  return node;
}


/* byte_array_literal: '[' byte_array_literal_elts ']'
   byte_array_literal_elts: byte_array_literal_elts INTEGER_LITERAL
   | empty  */

static tree_node
parse_byte_array_literal (gst_parser *p)
{
  tree_node elts = NULL;
  assert (token (p, 0) == '[');
  lex (p);

  while (!lex_skip_if (p, ']', true))
    {
      tree_node lit;
      lex_must_be (p, INTEGER_LITERAL);
      if (val(p, 0)->ival < 0 || val(p, 0)->ival > 255)
	{
	  _gst_errorf ("byte constant out of range");
	  recover_error (p);
	}
      lit = _gst_make_int_constant (loc (p, 0), val(p, 0)->ival);
      lex (p);
      elts = _gst_add_node (elts, _gst_make_array_elt (&lit->location, lit));
    }

  return _gst_make_byte_array_constant (elts ? &elts->location : loc (p, 0), elts);
}


/* compile_time_constant: '(' temporaries statements ')' */

static tree_node
parse_compile_time_constant (gst_parser *p)
{
  tree_node temps, statements;
  YYLTYPE location = *loc(p,0);

  assert (token (p, 0) == '#');
  lex (p);
  lex_skip_mandatory (p, '(');
  temps = parse_temporaries (p, false);
  statements = parse_statements (p, NULL, true);
  lex_skip_mandatory (p, ')');

  if (!statements || _gst_had_error)
    return _gst_make_oop_constant (&location, _gst_nil_oop);

  return _gst_make_method (&location, loc(p, 0),
                           NULL, temps, NULL, statements, NULL,
                           _gst_current_parser->currentClass,
                           _gst_nil_oop,
                           _gst_untrusted_parse (),
                           false);
}


/* binding_constant: '{' variable_primary '}' */

static tree_node
parse_binding_constant (gst_parser *p)
{
  tree_node node;

  assert (token (p, 0) == '{');
  lex (p);
  lex_must_be (p, IDENTIFIER);
  node = parse_variable_primary (p);
  lex_skip_mandatory (p, '}');

  return _gst_make_binding_constant (&node->location, node);
}


/* array_constructor: '{' statements_no_ret '}' */

static tree_node
parse_array_constructor (gst_parser *p)
{
  tree_node stmts;
  YYLTYPE location = *loc(p,0);

  assert (token (p, 0) == '{');
  lex (p);

  stmts = parse_statements (p, NULL, false);
  lex_skip_mandatory (p, '}');
  return _gst_make_array_constructor (&location, stmts); 
}


/* block: '[' block_vars '||' temps_no_pipe statements ']'
   | '[' block_vars '|' temporaries statements ']'
   | '[' block_vars ']'
   | '[' temporaries statements ']' */

static tree_node
parse_block (gst_parser *p)
{
  YYLTYPE location = *loc(p,0);
  tree_node vars, temps, stmts;
  mst_Boolean implied_pipe;

  assert (token (p, 0) == '[');
  lex (p);

  if (token (p, 0) == ':')
    {
      vars = parse_block_variables (p);
      if (token (p, 0) == ']')
	implied_pipe = false;
      else if (lex_skip_if (p, '|', true))
	implied_pipe = false;
      else if (token (p, 0) == BINOP
	       && val(p, 0)->sval[0] == '|' && val(p, 0)->sval[1] == '|')
	{
	  implied_pipe = true;
	  lex (p);
	}
      else
	expected (p, ':', '|', ']', -1);
    }
  else
    {
      vars = NULL;
      implied_pipe = false;
    }

  temps = parse_temporaries (p, implied_pipe);
  stmts = parse_statements (p, NULL, true);

  lex_skip_mandatory (p, ']');
  return _gst_make_block (&location, vars, temps, stmts);
}


/* block_vars: ':' IDENTIFIER
   | block_vars ':' IDENTIFIER */

static tree_node
parse_block_variables (gst_parser *p)
{
  tree_node vars = NULL;
  assert (token (p, 0) == ':');

  while (lex_skip_if (p, ':', false))
    vars = _gst_add_node (vars, parse_variable (p));

  return vars;
}


/* message_expression: unary_expression
   | binary_expression
   | keyword_expression

   unary_expression: primary unary_message
   | unary_expression unary_message
   unary_message: IDENTIFIER

   binary_expression: unary_expression binop unary_expression
   | binary_expression binop unary_expression

   keyword_expression: binary_expression KEYWORD binary_expression
   | keyword_expression KEYWORD binary_expression */

static tree_node
parse_message_expression (gst_parser *p, tree_node receiver, enum expr_kinds kind)
{
  tree_node node = receiver;
  int n;
  for (n = 0; ; n++)
    {
      switch (token (p, 0))
	{
	case IDENTIFIER:
	  node = parse_unary_expression (p, node, kind & ~EXPR_CASCADE);
	  break;

	case '>':
	  if ((kind & EXPR_GREATER) == 0)
	    return node;

	case BINOP:
	case '<':
        case '-':
	case '|':
	  if ((kind & EXPR_BINOP) == 0)
	    return node;
	  node = parse_binary_expression (p, node, kind & ~EXPR_CASCADE);
	  break;

	case KEYWORD:
	  if ((kind & EXPR_KEYWORD) == 0)
	    return node;
	  node = parse_keyword_expression (p, node, kind & ~EXPR_CASCADE);
	  break;

	case ';':
	  if (n == 0 || (kind & EXPR_CASCADE) == 0)
	    return node;
	  return _gst_make_cascaded_message (&node->location, node,
					     parse_cascaded_messages (p));

	default:
	  return node;
	}
    }

  abort ();
}


/* cascaded_messages: cascaded_messages ';' message_expression
   | empty */

static tree_node
parse_cascaded_messages (gst_parser *p)
{
  tree_node cascade = NULL;
  while (lex_skip_if (p, ';', false))
    {
      tree_node node;
      switch (token (p, 0))
	{
	case IDENTIFIER:
	  node = parse_unary_expression (p, NULL, EXPR_CASCADED);
	  break;

	case '>':
	case BINOP:
	case '<':
        case '-':
	case '|':
	  node = parse_binary_expression (p, NULL, EXPR_CASCADED);
	  break;

	case KEYWORD:
	  node = parse_keyword_expression (p, NULL, EXPR_CASCADED);
	  break;

	default:
	  /* After a semicolon, we can expect a message send.  */
	  expected (p, IDENTIFIER, BINOP, KEYWORD, -1);
	}

      node = _gst_make_message_list (&node->location, node); 
      cascade = _gst_add_node (cascade, node);
    }

  return cascade;
}


/* See above.  This function only parses one unary expression.  */

static tree_node
parse_unary_expression (gst_parser *p, tree_node receiver, enum expr_kinds kind)
{
  YYLTYPE location = receiver ? receiver->location : *loc(p,0);
  char *sel;
  assert (token (p, 0) == IDENTIFIER);
  sel = val(p, 0)->sval;
  if (is_unlikely_selector (sel))
    _gst_warningf ("sending `%s', most likely you forgot a period", sel);

  lex (p);
  return _gst_make_unary_expr (&location, receiver, sel); 
}


/* See above.  This function only parses one binary expression.  */

static tree_node
parse_binary_expression (gst_parser *p, tree_node receiver, enum expr_kinds kind)
{
  YYLTYPE location = receiver ? receiver->location : *loc(p,0);
  char *sel;
  tree_node arg;
  assert (token (p, 0) == BINOP || token (p, 0) == '|' || token (p, 0) == '<'
	  || token (p, 0) == '-' || token (p, 0) == '>');
  sel = val(p, 0)->sval;
  lex (p);
  arg = parse_expression (p, kind & ~EXPR_KEYWORD & ~EXPR_BINOP);
  if (!arg)
    {
      _gst_errorf ("expected object");
      recover_error (p);
    }

  return _gst_make_binary_expr (&location, receiver, sel, arg); 
}

/* See above.  This function parses a keyword expression with all its
   arguments.  */

static tree_node
parse_keyword_expression (gst_parser *p, tree_node receiver, enum expr_kinds kind)
{
  YYLTYPE location = receiver ? receiver->location : *loc(p,0);
  tree_node list = parse_keyword_list (p, kind);
  return list ? _gst_make_keyword_expr (&location, receiver, list) : NULL;
}

static tree_node
parse_keyword_list (gst_parser *p, enum expr_kinds kind)
{
  tree_node expr = NULL;
  assert (token (p, 0) == KEYWORD);

  do
    {
      YYLTYPE location = *loc(p,0);
      char *sval = val(p, 0)->sval;
      tree_node arg;
      lex (p);
      arg = parse_expression (p, kind & ~EXPR_KEYWORD);
      if (!arg)
	{
	  _gst_errorf ("expected object");
	  recover_error (p);
	}

      expr = _gst_add_node (expr, _gst_make_keyword_list (&location, sval, arg));
    }
  while (token (p, 0) == KEYWORD);

  return expr;
}


/* Based on a hash table produced by gperf version 2.7.2
   Command-line: gperf -tn -F ', false' -j1 -k1,2
   with the following input:

   false
   nil
   self
   super
   thisContext
   true
   fe
   ne
   nh
   sr

   A few negatives have been included in the input to avoid that
   messages like #new or #size require a strcmp (their hash value is
   in range if only the six keywords are included), and the length
   has not been included to make the result depend on selectors
   *starting* with two given letters.  With this hash table and this
   implementation, only selectors starting with "fa", "ni", "se",
   "su", "th", "tr" (which are unavoidable) require a strcmp, which is
   a good compromise.  All the others require three array lookups
   (two for the hash function, one to check for the first character)

   An alternative could have been simple trie-like
   code like this:

   return ((*$1 == 's' &&
   (strcmp ($1+1, "elf") == 0 ||
   strcmp ($1+1, "uper") == 0)) ||
   
   (*$1 == 't' &&
   (strcmp ($1+1, "rue") == 0 ||
   strcmp ($1+1, "hisContext") == 0)) ||
   
   (*$1 == 'f' && strcmp ($1+1, "alse") == 0) ||
   (*$1 == 'n' && strcmp ($1+1, "il") == 0))

   ... but using gperf is more cool :-) */

mst_Boolean
is_unlikely_selector (register const char *str)
{
  /* The first-character table is big enough that
     we skip the range check on the hash value */

  static const char first[31] = 
    "s  s   f  n  tt               ";

  static const char *rest[] =
    {
      "elf",
      NULL,
      NULL,
      "uper",
      NULL,
      NULL,
      NULL,
      "alse",
      NULL,
      NULL,
      "il",
      NULL,
      NULL,
      "hisContext",
      "rue"
    };

  static unsigned char asso_values[] =
    {
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15,  1, 15, 15,
      15,  0,  6, 15,  4,  2, 15, 15, 15, 15,
       8, 15, 15, 15,  5,  0,  9,  3, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
      15, 15, 15, 15, 15, 15
    };

  register int key = asso_values[(unsigned char)str[1]] + 
    asso_values[(unsigned char)str[0]];

  return
    first[key] == *str &&
    !strcmp (str + 1, rest[key]);
}
