/******************************** -*- C -*- ****************************
 *
 *	Semantic Tree manipulation module.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "gstpriv.h"

char *_gst_nil_name = "(nil)";	/* how to print nil */


/* Make a tree_node made up of the NODETYPE type-tag and a list_node
   representing the head of the list, for NAME and VALUE.  */
static tree_node make_list_node (YYLTYPE *location,
				 node_type nodeType,
				 char *name,
				 tree_node value);

/* Make a expr_node made up of the NODETYPE type-tag and an expr_node
   with given RECEIVER, SELECTOR and EXPRESSION.  */
static tree_node make_expr_node (YYLTYPE *location,
				 node_type nodeType,
				 tree_node receiver,
				 OOP selector,
				 tree_node expression);

/* Allocate from the compilation obstack a node and assign it the
   NODETYPE type-tag.  */
static tree_node make_tree_node (YYLTYPE *location,
				 node_type nodeType);

/* Print the NODE method_node with LEVEL spaces of indentation. */
static void print_method_node (tree_node node,
			       int level);

/* Print the NODE method_node with LEVEL spaces of indentation. */
static void print_block_node (tree_node node,
			      int level);

/* Print the NODE expr_node with LEVEL spaces of indentation. */
static void print_expr_node (tree_node node,
			     int level);

/* Print the NODE list_node with LEVEL spaces of indentation. */
static void print_list_node (tree_node node,
			     int level);

/* Print the NODE const_node with LEVEL spaces of indentation. */
static void print_const_node (tree_node node,
			      int level);

/* Print the NODE list_node with LEVEL spaces of indentation, 
   discarding the NAME of each node (hence the distinction between
   this and print_list_node). */
static void print_array_constructor_node (tree_node node,
					  int level);

/* Print LEVEL spaces of indentation. */
static void indent (int level);


/* These are used only for printing tree node names when debugging */
static char *node_type_names[] = {
  "TREE_METHOD_NODE",		/* TREE_METHOD_NODE */
  "TREE_UNARY_EXPR",		/* TREE_UNARY_EXPR */
  "TREE_BINARY_EXPR",		/* TREE_BINARY_EXPR */
  "TREE_KEYWORD_EXPR",		/* TREE_KEYWORD_EXPR */
  "TREE_VARIABLE_NODE",		/* TREE_VARIABLE_NODE */
  "TREE_KEYWORD_LIST",		/* TREE_KEYWORD_LIST */
  "TREE_VAR_DECL_LIST",		/* TREE_VAR_DECL_LIST */
  "TREE_VAR_ASSIGN_LIST",	/* TREE_VAR_ASSIGN_LIST */
  "TREE_STATEMENT_LIST",	/* TREE_STATEMENT_LIST */
  "TREE_RETURN_EXPR",		/* TREE_RETURN_EXPR */
  "TREE_ASSIGN_EXPR",		/* TREE_ASSIGN_EXPR */
  "TREE_CONST_EXPR",		/* TREE_CONST_EXPR */
  "TREE_SYMBOL_NODE",		/* TREE_SYMBOL_NODE */
  "TREE_ARRAY_ELT_LIST",	/* TREE_ARRAY_ELT_LIST */
  "TREE_BLOCK_NODE",		/* TREE_BLOCK_NODE */
  "TREE_CASCADE_EXPR",		/* TREE_CASCADE_EXPR */
  "TREE_MESSAGE_LIST",		/* TREE_MESSAGE_LIST */
  "TREE_ARRAY_CONSTRUCTOR"	/* TREE_ARRAY_CONSTRUCTOR */
};



tree_node
_gst_make_array_elt (YYLTYPE *location,
		     tree_node elt)
{
  return (make_list_node (location, TREE_ARRAY_ELT_LIST, NULL, elt));
}


tree_node
_gst_make_method (YYLTYPE *location,
		     tree_node selectorExpr,
		  tree_node temporaries,
		  char *primitiveName,
		  tree_node statements)
{
  tree_node result;

  result = make_tree_node (location, TREE_METHOD_NODE);
  result->v_method.selectorExpr = selectorExpr;
  result->v_method.temporaries = temporaries;
  result->v_method.primitiveName = primitiveName;
  result->v_method.statements = statements;
  return (result);
}


tree_node
_gst_make_cascaded_message (YYLTYPE *location,
		     tree_node messageExpr,
			    tree_node cascadedMessages)
{
  return (make_expr_node (location, TREE_CASCADE_EXPR, messageExpr, NULL,
			  cascadedMessages));
}


tree_node
_gst_make_unary_expr (YYLTYPE *location,
		     tree_node receiver,
		      char *unarySelectorExpr)
{
  OOP selector;

  /* selectors, being interned symbols, don't need to be incubated --
     symbols once created are always referenced */
  selector = _gst_intern_string (unarySelectorExpr);
  return (make_expr_node (location, TREE_UNARY_EXPR, receiver, selector, NULL));
}

tree_node
_gst_intern_ident (YYLTYPE *location,
		     char *ident)
{
  return (make_expr_node
	  (location, TREE_SYMBOL_NODE, NULL, _gst_intern_string (ident), NULL));
}

tree_node
_gst_make_return (YYLTYPE *location,
		     tree_node expression)
{
  return (make_expr_node
	  (location, TREE_RETURN_EXPR, expression, _gst_nil_oop, NULL));
}

tree_node
_gst_make_keyword_expr (YYLTYPE *location,
		     tree_node receiver,
			tree_node keywordMessage)
{
  return (make_expr_node
	  (location, TREE_KEYWORD_EXPR, receiver, _gst_nil_oop, keywordMessage));
}

tree_node
_gst_make_assign (YYLTYPE *location,
		     tree_node variables,
		  tree_node expression)
{
  return (make_expr_node
	  (location, TREE_ASSIGN_EXPR, variables, _gst_nil_oop, expression));
}

tree_node
_gst_make_statement_list (YYLTYPE *location,
			  tree_node expression)
{
  return (make_list_node (location, TREE_STATEMENT_LIST, NULL, expression));
}

tree_node
_gst_make_keyword_list (YYLTYPE *location,
		     char *keyword,
			tree_node expression)
{
  return (make_list_node (location, TREE_KEYWORD_LIST, keyword, expression));
}

tree_node
_gst_make_variable_list (YYLTYPE *location,
		     tree_node variable)
{
  /* Actually, we rely on the fact that a variable is represented as a
     tree node of type list_node, so all we do is change the node tag
     to TREE_VAR_DECL_LIST. */
  variable->nodeType = TREE_VAR_DECL_LIST;
  return (variable);
}

tree_node
_gst_make_assignment_list (YYLTYPE *location,
		     tree_node variable)
{
  /* Actually, we rely on the fact that a variable is represented as a
     tree node of type list_node, so all we do is change the node tag
     to TREE_VAR_DECL_LIST. */
  return (make_list_node (location, TREE_VAR_ASSIGN_LIST, NULL, variable));
}


tree_node
_gst_make_binary_expr (YYLTYPE *location,
		     tree_node receiver,
		       char *binaryOp,
		       tree_node argument)
{
  OOP selector;

  selector = _gst_intern_string (binaryOp);
  return (make_expr_node
	  (location, TREE_BINARY_EXPR, receiver, selector, argument));
}

tree_node
_gst_make_message_list (YYLTYPE *location,
		     tree_node messageElt)
{
  return (make_list_node (location, TREE_MESSAGE_LIST, NULL, messageElt));
}

tree_node
_gst_make_block (YYLTYPE *location,
		     tree_node arguments,
		 tree_node temporaries,
		 tree_node statements)
{
  tree_node result;

  result = make_tree_node (location, TREE_BLOCK_NODE);
  result->v_block.arguments = arguments;
  result->v_block.temporaries = temporaries;
  result->v_block.statements = statements;
  return (result);
}

tree_node
_gst_make_variable (YYLTYPE *location,
		     char *name)
{
  return (make_list_node (location, TREE_VARIABLE_NODE, name, NULL));
}


tree_node
_gst_make_int_constant (YYLTYPE *location,
		     long int ival)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_INT;
  result->v_const.val.iVal = ival;

  return (result);
}

tree_node
_gst_make_byte_object_constant (YYLTYPE *location,
		     byte_object boval)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_BYTE_OBJECT;
  result->v_const.val.boVal = boval;

  return (result);
}

tree_node
_gst_make_float_constant (YYLTYPE *location,
		     long double fval, int type)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = type;
  result->v_const.val.fVal = fval;

  return (result);
}

tree_node
_gst_make_string_constant (YYLTYPE *location,
		     char *sval)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_STRING;
  result->v_const.val.sVal = sval;

  return (result);
}

tree_node
_gst_make_oop_constant (YYLTYPE *location,
		     OOP oval)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_OOP;
  result->v_const.val.oopVal = oval;
  INC_ADD_OOP (oval);

  return (result);
}

tree_node
_gst_make_char_constant (YYLTYPE *location,
		     char cval)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_OOP;
  result->v_const.val.oopVal = CHAR_OOP_AT (cval);

  return (result);
}

tree_node
_gst_make_symbol_constant (YYLTYPE *location,
		     tree_node symbolNode)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_OOP;
  if (symbolNode)
    result->v_const.val.oopVal = symbolNode->v_expr.selector;
  else
    result->v_const.val.oopVal = _gst_nil_oop;

  return (result);
}

/* This function converts an gst_array constant's format (linked list of its
 * elements) to a gst_byte_array constant's format (byte_object struct).  The code
 * itself is awful and the list is extremely space inefficient, but consider
 * that:
 * a) it makes the parser simpler (Arrays and ByteArrays are treated in almost
 *    the same way; only, the latter call this function and the former don't).
 * b) a list is indeed an elegant solution because we don't know the size of
 *    the byte array until we have parsed it all (that is, until we call this
 *    function.
 * c) the byte_object is the best format for ByteArrays: first, it is the one
 *    which makes it easiest to make a full-fledged object out of the parse
 *    tree; second, it is logical to choose it since LargeIntegers use it,
 *    and ByteArrays are represented exactly the same as LargeIntegers.
 */
tree_node
_gst_make_byte_array_constant (YYLTYPE *location,
		     tree_node aval)
{
  tree_node arrayElt, ival;
  int len;
  byte_object bo;
  gst_uchar *data;

  for (len = 0, arrayElt = aval; arrayElt;
       len++, arrayElt = arrayElt->v_list.next);

  bo = (byte_object) obstack_alloc (_gst_compilation_obstack,
				    sizeof (struct byte_object) + len);

  bo->class = _gst_byte_array_class;
  bo->size = len;
  data = bo->body;

  /* Now extract the node for each integer constant, storing its value
     into the byte_object */
  for (arrayElt = aval; arrayElt; arrayElt = arrayElt->v_list.next)
    {
      ival = arrayElt->v_list.value;
      *data++ = ival->v_const.val.iVal;
    }

  return (_gst_make_byte_object_constant (location, bo));
}

tree_node
_gst_make_array_constant (YYLTYPE *location,
		     tree_node aval)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_ARRAY;
  result->v_const.val.aVal = aval;

  return (result);
}

tree_node
_gst_make_array_constructor (YYLTYPE *location,
		     tree_node statements)
{
  tree_node result;

  result = make_tree_node (location, TREE_ARRAY_CONSTRUCTOR);
  result->v_const.constType = CONST_ARRAY;
  result->v_const.val.aVal = statements;

  return (result);
}

tree_node
_gst_make_binding_constant (YYLTYPE *location,
		     tree_node variables)
{
  tree_node result;
  OOP assocOOP = _gst_find_variable_binding (variables);

  if (IS_NIL (assocOOP))
    return (NULL);

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_OOP;
  result->v_const.val.oopVal = assocOOP;

  return (result);
}

void
_gst_add_node (tree_node n1,
	       tree_node n2)
{
  n1->location.last_line = n2->location.last_line;
  n1->location.last_column = n2->location.last_column;

  *(n1->v_list.nextAddr) = n2;
  n1->v_list.nextAddr = n2->v_list.nextAddr;
}

void
_gst_free_tree ()
{
  obstack_free (_gst_compilation_obstack, NULL);
  obstack_init (_gst_compilation_obstack);
}





/***********************************************************************
 *
 * Internal tree construction routines.
 *
 ***********************************************************************/


static tree_node
make_list_node (YYLTYPE *location,
		     node_type nodeType,
		char *name,
		tree_node value)
{
  tree_node result;

  result = make_tree_node (location, nodeType);
  result->v_list.name = name;
  result->v_list.value = value;
  result->v_list.next = NULL;
  result->v_list.nextAddr = &result->v_list.next;
  return (result);
}

static tree_node
make_expr_node (YYLTYPE *location,
		     node_type nodeType,
		tree_node receiver,
		OOP selector,
		tree_node expression)
{
  tree_node result;

  result = make_tree_node (location, nodeType);
  result->v_expr.receiver = receiver;
  result->v_expr.selector = selector;
  result->v_expr.expression = expression;
  return (result);
}

static tree_node
make_tree_node (YYLTYPE *location,
		     node_type nodeType)
{
  tree_node result;

  result = (tree_node) obstack_alloc (_gst_compilation_obstack,
				      sizeof (struct tree_node));

  result->nodeType = nodeType;
  result->location = *location;
  return (result);
}



/***********************************************************************
 *
 *	Printing routines.
 *
 ***********************************************************************/
void
_gst_print_tree (tree_node node,
		 int level)
{
  if (node == NULL)
    {
      printf ("%s\n", _gst_nil_name);
      return;
    }

  if (node->nodeType < TREE_FIRST || node->nodeType > TREE_LAST)
    {
      printf ("Unknown tree node type %d\n", node->nodeType);
      return;
    }

  printf ("%s\n", node_type_names[node->nodeType]);

  switch (node->nodeType)
    {
    case TREE_METHOD_NODE:
      print_method_node (node, level + 2);
      break;

    case TREE_BLOCK_NODE:
      print_block_node (node, level + 2);
      break;

    case TREE_SYMBOL_NODE:
    case TREE_UNARY_EXPR:
    case TREE_BINARY_EXPR:
    case TREE_KEYWORD_EXPR:
    case TREE_CASCADE_EXPR:
    case TREE_RETURN_EXPR:
    case TREE_ASSIGN_EXPR:
      print_expr_node (node, level + 2);
      break;

    case TREE_VARIABLE_NODE:
    case TREE_KEYWORD_LIST:
    case TREE_ARRAY_ELT_LIST:
    case TREE_MESSAGE_LIST:
    case TREE_STATEMENT_LIST:
    case TREE_VAR_DECL_LIST:
    case TREE_VAR_ASSIGN_LIST:
      print_list_node (node, level + 2);
      break;

    case TREE_ARRAY_CONSTRUCTOR:
      print_array_constructor_node (node, level + 2);
      break;

    case TREE_CONST_EXPR:
      print_const_node (node, level + 2);
      break;

    default:
      abort ();
    }
}

static void
print_array_constructor_node (tree_node node,
			      int level)
{
  indent (level);
  _gst_print_tree (node->v_const.val.aVal, level);
}

static void
print_list_node (tree_node node,
		 int level)
{
  indent (level);
  printf ("name: %s\n",
	  node->v_list.name ? node->v_list.name : _gst_nil_name);
  indent (level);
  printf ("value: ");
  _gst_print_tree (node->v_list.value, level + 7);
  if (node->v_list.next)
    {
      indent (level - 2);
      _gst_print_tree (node->v_list.next, level - 2);
    }
}

static void
print_expr_node (tree_node node,
		 int level)
{
  indent (level);
  printf ("selector: %#O\n", node->v_expr.selector);
  indent (level);
  printf ("receiver: ");
  _gst_print_tree (node->v_expr.receiver, level + 10);
  /* ??? don't print the expression for unary type things, and don't
     print the receiver for symbol nodes */
  indent (level);
  printf ("expression: ");
  _gst_print_tree (node->v_expr.expression, level + 12);
}

static void
print_method_node (tree_node node,
		   int level)
{
  indent (level);
  printf ("selectorExpr: ");
  _gst_print_tree (node->v_method.selectorExpr, level + 14);
  indent (level);
  printf ("temporaries: ");
  _gst_print_tree (node->v_method.temporaries, level + 13);
  indent (level);
  printf ("statements: ");
  _gst_print_tree (node->v_method.statements, level + 12);
}

static void
print_block_node (tree_node node,
		  int level)
{
  indent (level);
  printf ("arguments: ");
  _gst_print_tree (node->v_block.arguments, level + 11);
  indent (level);
  printf ("temporaries: ");
  _gst_print_tree (node->v_block.temporaries, level + 13);
  indent (level);
  printf ("statements: ");
  _gst_print_tree (node->v_block.statements, level + 12);
}

static void
print_const_node (tree_node node,
		  int level)
{
  indent (level);
  switch (node->v_const.constType)
    {
    case CONST_INT:
      printf ("int: %ld\n", node->v_const.val.iVal);
      break;

    case CONST_FLOATD:
      printf ("floatd: %g\n", (float) node->v_const.val.fVal);
      break;

    case CONST_FLOATE:
      printf ("floate: %g\n", (double) node->v_const.val.fVal);
      break;

    case CONST_FLOATQ:
      printf ("floatq: %Lg\n", node->v_const.val.fVal);
      break;

    case CONST_STRING:
      printf ("string: \"%s\"\n", node->v_const.val.sVal);
      break;

    case CONST_OOP:
      printf ("oop: %O\n", node->v_const.val.oopVal);
      break;

    case CONST_ARRAY:
      printf ("array: ");
      _gst_print_tree (node->v_const.val.aVal, level + 7);
      break;

    default:
      _gst_errorf ("Unknown constant type %d", node->v_const.constType);
    }
}

static void
indent (int level)
{
  printf ("%*s", level, "");
}
