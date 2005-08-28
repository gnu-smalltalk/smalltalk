/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk language grammar definition
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2005 Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "gst.h"
#include "gstpriv.h"
#include "gst-parse.h"
#include <stdio.h>
#if defined (STDC_HEADERS)
#include <string.h>
#endif

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

static inline void lex (gst_parser *p);
static inline void lex_must_be (gst_parser *p,
				int req_token);
static inline void lex_skip_mandatory (gst_parser *p,
				       int req_token);
static inline mst_Boolean lex_skip_if (gst_parser *p,
				       int req_token,
				       mst_Boolean fail_at_eof);

/* Error recovery.  */

static void expected (gst_parser *p,
		      int token, ...)
  ATTRIBUTE_NORETURN;
static void recover_error (gst_parser *p)
  ATTRIBUTE_NORETURN;
static int filprintf (Filament *fil,
		      const char *format, ...);

/* Grammar productions.  */

static void parse_doit (gst_parser *p);
static void parse_method_list (gst_parser *p);
static void parse_method (gst_parser *p);
static tree_node parse_message_pattern (gst_parser *p);
static tree_node parse_keyword_variable_list (gst_parser *p);
static tree_node parse_variable (gst_parser *p);
static tree_node parse_attributes (gst_parser *p);
static tree_node parse_temporaries (gst_parser *p,
				    mst_Boolean implied_pipe);
static tree_node parse_statements (gst_parser *p,
				   mst_Boolean accept_caret);
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
static tree_node parse_cascaded_messages (gst_parser *p,
					  enum expr_kinds kind);
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


/* Lexer interface.  Get a token out of the stream.  */

static inline void
lex (gst_parser *p)
{
  p->token = _gst_yylex (&p->val, &p->loc);
}

/* Lexer interface.  Check that the next token is REQ_TOKEN and fail if
   it is not.  */

static inline void
lex_must_be (gst_parser *p, int req_token)
{
  if (p->token != req_token)
    expected (p, req_token, -1);
}

/* Lexer interface.  Check that the next token is REQ_TOKEN and eat it;
   fail if it does not match.  */

static inline void
lex_skip_mandatory (gst_parser *p, int req_token)
{
  if (p->token != req_token)
    expected (p, req_token, -1);
  else
    lex (p);
}

/* Lexer interface.  If the next token is REQ_TOKEN, eat it and return true;
   otherwise return false.  */

static inline mst_Boolean
lex_skip_if (gst_parser *p, int req_token, mst_Boolean fail_at_eof)
{
  if (p->token != req_token)
    {
      if (p->token == EOF && fail_at_eof)
	expected (p, req_token, -1);
      return false;
    }
  else
    {
      lex (p);
      return true;
    }
}

/* Top of the descent.  */

void
_gst_parse_method ()
{
  gst_parser p, *prev_parser = _gst_current_parser;
  _gst_current_parser = &p;
  p.state = PARSE_METHOD;
  lex (&p);
  if (setjmp (p.recover) == 0)
    parse_method (&p);
  else
    _gst_had_error = false;

  _gst_current_parser = prev_parser;
}

void
_gst_parse_chunks ()
{
  gst_parser p, *prev_parser = _gst_current_parser;

  _gst_current_parser = &p;
  p.state = PARSE_DOIT;
  lex (&p);
  if (p.token == SHEBANG)
    lex (&p);

  setjmp (p.recover);
  _gst_had_error = false;
  while (p.token != EOF)
    {
      /* Pick the production here, so that subsequent methods are compiled
	 when we come back from an error above.  */
      if (p.state == PARSE_METHOD_LIST)
	parse_method_list (&p);
      else
        parse_doit (&p);
    }

  _gst_current_parser = prev_parser;
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

#define TOKEN_SEP
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
#undef TOKEN_SEP

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
    for (;;)
      {
	/* Find the final bang.  */
        if (p->token == EOF)
          break;
        if (p->token == '!')
	  {
	    _gst_free_tree ();
            lex (p);
	    break;
	  }
        lex (p);
      }

  longjmp (p->recover, 1);
}


/* doit: temporaries statements '!' [ method_list '!' ]
       | empty */

static void
parse_doit (gst_parser *p)
{
  tree_node temps = parse_temporaries (p, false);
  tree_node statements = parse_statements (p, true);

  if (p->token != EOF && p->token != '!')
    expected (p, '!', -1);

  if (statements && !_gst_had_error)
    _gst_execute_statements (temps, statements, false);

  _gst_free_tree ();
  _gst_had_error = false;

  /* Do not lex until after _gst_free_tree, or we lose a token!  */
  _gst_clear_method_start_pos ();
  lex (p);
}


/* method_list: method_list method '!'
	      | empty */

static void
parse_method_list (gst_parser *p)
{
  while (p->token != '!')
    {
      parse_method (p);
      lex_skip_mandatory (p, '!');
    }

  lex (p);
  _gst_skip_compilation = false;
  _gst_reset_compilation_category ();
  p->state = PARSE_DOIT;
}


/* method: message_pattern temporaries attributes statements */

static void
parse_method (gst_parser *p)
{
  tree_node pat = parse_message_pattern (p);
  tree_node temps = parse_temporaries (p, false);
  tree_node attrs = parse_attributes (p);
  tree_node stmts = parse_statements (p, true);
  tree_node method = _gst_make_method (&pat->location, pat, temps, attrs, stmts);
  if (!_gst_had_error && !_gst_skip_compilation)
    _gst_compile_method (method, false, true);

  _gst_clear_method_start_pos ();
  _gst_free_tree ();
  _gst_had_error = false;
}


/* message_pattern: unary_pattern
		  | binary_pattern
		  | keyword_pattern

   unary_pattern: IDENTIFIER
   binary_pattern: binop IDENTIFIER
   keyword_pattern: keyword_pattern KEYWORD IDENTIFIER
		  | KEYWORD IDENTIFIER
   binop : BINOP | '<' | '>' | '|' */

static tree_node
parse_message_pattern (gst_parser *p)
{
  YYLTYPE loc = p->loc;
  tree_node pat, arg;
  char *sval = p->val.sval;

  switch (p->token)
    {
    case IDENTIFIER:
      lex (p);
      pat = _gst_make_unary_expr (&loc, NULL, sval); 
      break;

    case BINOP:
    case '<':
    case '>':
    case '|':
      lex (p);
      arg = parse_variable (p);
      pat = _gst_make_binary_expr (&loc, NULL, sval, arg);
      break;

    case KEYWORD:
      pat = parse_keyword_variable_list (p);
      pat = _gst_make_keyword_expr (&loc, NULL, pat);
      break;

    default:
      expected (p, IDENTIFIER, BINOP, KEYWORD, -1);
    }

  return pat;
}

static tree_node
parse_keyword_variable_list (gst_parser *p)
{
  YYLTYPE loc = p->loc;
  tree_node pat = NULL, arg;

  do
    {
      char *sval = p->val.sval;
      lex (p);
      arg = parse_variable (p);
      pat = _gst_add_node (pat, _gst_make_keyword_list (&loc, sval, arg));
    }
  while (p->token == KEYWORD);

  return pat;
}


/* variable: IDENTIFIER */

static tree_node
parse_variable (gst_parser *p)
{
  tree_node var;

  lex_must_be (p, IDENTIFIER);
  var = _gst_make_variable (&p->loc, p->val.sval); 
  lex (p);
  return var;
}


/* attributes: attributes '<' attribute '>'
	     | empty

   attribute: attribute KEYWORD binary_expr 
	    | KEYWORD binary_expr */

static tree_node
parse_attributes (gst_parser *p)
{
  tree_node attrs = NULL;

  while (lex_skip_if (p, '<', false))
    {
      tree_node attr = parse_keyword_list (p, EXPR_BINOP);
      attr = _gst_make_attribute_list (&attr->location, attr);
      lex_skip_mandatory (p, '>');
      if (attr)
	attrs = _gst_add_node (attrs, attr);
    }

  return attrs;
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
      if (p->token != IDENTIFIER)
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
parse_statements (gst_parser *p, mst_Boolean accept_caret)
{
  tree_node stmts = NULL, stmt;
  mst_Boolean caret;

  do
    {
      caret = accept_caret && lex_skip_if (p, '^', false);
      stmt = parse_expression (p, EXPR_ANY);
      if (caret)
	{
          if (stmt == NULL)
	    {
	      _gst_errorf ("expected statement after '^'");
	      recover_error (p);
	    }
	  stmt = _gst_make_return (&stmt->location, stmt);
	}
      else
	{
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
      if (p->token != IDENTIFIER)
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

  if (!node)
    return node;

  node = parse_message_expression (p, node, kind & ~EXPR_ASSIGNMENT);
  if (assigns)
    return _gst_make_assign (&assigns->location, assigns, node);
  else
    return node;
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

  switch (p->token)
    {
    case IDENTIFIER:
      node = parse_variable_primary (p);
      break;

    case STRING_LITERAL:
    case SYMBOL_LITERAL:
    case INTEGER_LITERAL:
    case LARGE_INTEGER_LITERAL:
    case BYTE_LITERAL:
    case FLOATD_LITERAL:
    case FLOATE_LITERAL:
    case FLOATQ_LITERAL:
    case SCALED_DECIMAL_LITERAL:
    case CHAR_LITERAL:
    case '#':
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
      node = parse_expression (p, EXPR_ANY);
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
parse_variable_primary (gst_parser *p)
{
  tree_node node;
  assert (p->token == IDENTIFIER);
  node = _gst_make_variable (&p->loc, p->val.sval);
  for (;;)
    {
      lex (p);
      if (!lex_skip_if (p, SCOPE_SEPARATOR, false))
	break;

      lex_must_be (p, IDENTIFIER);
      node = _gst_add_node (node, _gst_make_variable (&p->loc, p->val.sval));
    }

  return node;
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
  switch (p->token)
    {
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
      node = _gst_make_string_constant (&p->loc, p->val.sval);
      break;

    case SYMBOL_LITERAL:
      node = _gst_intern_ident (&p->loc, p->val.sval);
      node = _gst_make_symbol_constant (&p->loc, node); 
      break;

    case INTEGER_LITERAL:
    case BYTE_LITERAL:
      node = _gst_make_int_constant (&p->loc, p->val.ival);
      break;

    case LARGE_INTEGER_LITERAL:
      node = _gst_make_byte_object_constant (&p->loc, p->val.boval);
      break;

    case FLOATD_LITERAL:
      node = _gst_make_float_constant (&p->loc, p->val.fval, CONST_FLOATD);
      break;

    case FLOATE_LITERAL:
      node = _gst_make_float_constant (&p->loc, p->val.fval, CONST_FLOATE);
      break;

    case FLOATQ_LITERAL:
      node = _gst_make_float_constant (&p->loc, p->val.fval, CONST_FLOATQ);
      break;

    case SCALED_DECIMAL_LITERAL:
      node = _gst_make_oop_constant (&p->loc, p->val.oval);
      break;

    case CHAR_LITERAL:
      node = _gst_make_char_constant (&p->loc, p->val.cval);
      break;

    case '#':
      lex (p);
      switch (p->token)
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
  assert (p->token == '(');
  lex (p);

  while (!lex_skip_if (p, ')', true))
    {
      tree_node lit = parse_literal (p, true);
      if (lit == NULL)
	return NULL;
      elts = _gst_add_node (elts, _gst_make_array_elt (&lit->location, lit));
    }

  return _gst_make_array_constant (elts ? &elts->location : &p->loc, elts);
}


/* builtin_identifier: "true" | "false" | "nil" */

static tree_node
parse_builtin_identifier (gst_parser *p)
{
  OOP symbolOOP;
  tree_node node;
  YYLTYPE loc = p->loc;

  assert (p->token == IDENTIFIER);
  symbolOOP = _gst_intern_string (p->val.sval);
  if (symbolOOP == _gst_true_symbol)
    node = _gst_make_oop_constant (&loc, _gst_true_oop);

  else if (symbolOOP == _gst_false_symbol)
    node = _gst_make_oop_constant (&loc, _gst_false_oop);

  else if (symbolOOP == _gst_nil_symbol)
    node = _gst_make_oop_constant (&loc, _gst_nil_oop);

  else
    {
      _gst_errorf ("expected true, false or nil");
      recover_error (p);
    }

  lex (p);
  return node;
}


/* byte_array_literal: '[' byte_array_literal_elts ']'
   byte_array_literal_elts: byte_array_literal_elts BYTE_LITERAL
			  | empty  */

static tree_node
parse_byte_array_literal (gst_parser *p)
{
  tree_node elts = NULL;
  assert (p->token == '[');
  lex (p);

  while (!lex_skip_if (p, ']', true))
    {
      tree_node lit;
      lex_must_be (p, BYTE_LITERAL);
      lit = _gst_make_int_constant (&p->loc, p->val.ival);
      lex (p);
      elts = _gst_add_node (elts, _gst_make_array_elt (&lit->location, lit));
    }

  return _gst_make_byte_array_constant (&elts->location, elts);
}


/* compile_time_constant: '(' temporaries statements ')' */

static tree_node
parse_compile_time_constant (gst_parser *p)
{
  tree_node temps, statements;
  YYLTYPE loc = p->loc;
  OOP result = NULL;

  assert (p->token == '#');
  lex (p);
  lex_skip_mandatory (p, '(');
  temps = parse_temporaries (p, false);
  statements = parse_statements (p, true);
  lex_skip_mandatory (p, ')');

  if (statements && !_gst_had_error)
    result = _gst_execute_statements (temps, statements, true);

  return _gst_make_oop_constant (&loc, result ? result : _gst_nil_oop); 
}


/* binding_constant: '{' variable_primary '}' */

static tree_node
parse_binding_constant (gst_parser *p)
{
  tree_node node;

  assert (p->token == '{');
  lex (p);
  lex_must_be (p, IDENTIFIER);
  node = parse_variable_primary (p);
  lex_skip_mandatory (p, '}');

  if (!(node = _gst_make_binding_constant (&node->location, node)))
    {
      _gst_errorf ("invalid variable binding");
      recover_error (p);
    }
  return node;
}


/* array_constructor: '{' statements_no_ret '}' */

static tree_node
parse_array_constructor (gst_parser *p)
{
  tree_node stmts;

  assert (p->token == '{');
  lex (p);

  stmts = parse_statements (p, false);
  lex_skip_mandatory (p, '}');
  return _gst_make_array_constructor (&stmts->location, stmts); 
}


/* block: block_vars '||' temps_no_pipe statements
	| block_vars '|' temporaries statements
	| temporaries statements */

static tree_node
parse_block (gst_parser *p)
{
  YYLTYPE loc = p->loc;
  tree_node vars, temps, stmts;
  mst_Boolean implied_pipe;

  assert (p->token == '[');
  lex (p);

  if (p->token == ':')
    {
      vars = parse_block_variables (p);
      if (lex_skip_if (p, '|', true))
	implied_pipe = false;
      else if (p->token == BINOP
	       && p->val.sval[0] == '|' && p->val.sval[1] == '|')
	{
	  implied_pipe = true;
	  lex (p);
	}
      else
	expected (p, ':', '|', -1);
    }
  else
    {
      vars = NULL;
      implied_pipe = false;
    }

  temps = parse_temporaries (p, implied_pipe);
  stmts = parse_statements (p, true);

  lex_skip_mandatory (p, ']');
  return _gst_make_block (&loc, vars, temps, stmts);
}


/* block_vars: ':' IDENTIFIER
	     | block_vars ':' IDENTIFIER */

static tree_node
parse_block_variables (gst_parser *p)
{
  tree_node vars = NULL;
  assert (p->token == ':');

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
      switch (p->token)
        {
        case IDENTIFIER:
          node = parse_unary_expression (p, node, kind & ~EXPR_CASCADE);
          break;
  
        case '>':
	  if ((kind & EXPR_GREATER) == 0)
	    return node;

        case BINOP:
        case '<':
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
					     parse_cascaded_messages (p,
						EXPR_CASCADED));

        default:
          return node;
        }
    }

  abort ();
}


/* cascaded_messages: cascaded_messages ';' message_expression
		    | empty */

static tree_node
parse_cascaded_messages (gst_parser *p, enum expr_kinds kind)
{
  tree_node cascade = NULL;
  while (lex_skip_if (p, ';', false))
    {
      tree_node node;
      switch (p->token)
	{
        case IDENTIFIER:
          node = parse_unary_expression (p, NULL, kind);
          break;

        case '>':
	  assert (kind & EXPR_GREATER);
        case BINOP:
        case '<':
        case '|':
	  assert (kind & EXPR_BINOP);
          node = parse_binary_expression (p, NULL, kind);
          break;

        case KEYWORD:
	  assert (kind & EXPR_KEYWORD);
          node = parse_keyword_expression (p, NULL, kind);
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
  YYLTYPE loc = receiver ? receiver->location : p->loc;
  char *sel;
  assert (p->token == IDENTIFIER);
  sel = p->val.sval;
  if (is_unlikely_selector (sel))
    _gst_warningf ("sending `%s', most likely you forgot a period", sel);

  lex (p);
  return _gst_make_unary_expr (&loc, receiver, sel); 
}


/* See above.  This function only parses one binary expression.  */

static tree_node
parse_binary_expression (gst_parser *p, tree_node receiver, enum expr_kinds kind)
{
  YYLTYPE loc = receiver ? receiver->location : p->loc;
  char *sel;
  tree_node arg;
  assert (p->token == BINOP || p->token == '|' || p->token == '<'
	  || p->token == '>');
  sel = p->val.sval;
  lex (p);
  arg = parse_expression (p, kind & ~EXPR_KEYWORD & ~EXPR_BINOP);
  if (!arg)
    {
      _gst_errorf ("expected object");
      recover_error (p);
    }

  return _gst_make_binary_expr (&loc, receiver, sel, arg); 
}

/* See above.  This function parses a keyword expression with all its
   arguments.  */

static tree_node
parse_keyword_expression (gst_parser *p, tree_node receiver, enum expr_kinds kind)
{
  YYLTYPE loc = receiver ? receiver->location : p->loc;
  tree_node list = parse_keyword_list (p, kind);
  return list ? _gst_make_keyword_expr (&loc, receiver, list) : NULL;
}

static tree_node
parse_keyword_list (gst_parser *p, enum expr_kinds kind)
{
  tree_node expr = NULL;

  do
    {
      YYLTYPE loc = p->loc;
      char *sval = p->val.sval;
      tree_node arg;
      lex (p);
      arg = parse_expression (p, kind & ~EXPR_KEYWORD);
      if (!arg)
	{
	  _gst_errorf ("expected object");
	  recover_error (p);
	}

      expr = _gst_add_node (expr, _gst_make_keyword_list (&loc, sval, arg));
    }
  while (p->token == KEYWORD);

  return expr;
}


/* Based on an hash table produced by gperf version 2.7.2
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
   in range if only the six keywords were included), and the length
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
