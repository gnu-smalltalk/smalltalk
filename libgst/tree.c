/******************************** -*- C -*- ****************************
 *
 *	Semantic Tree manipulation module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2006
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

/* Make a tree_node made up of the NODETYPE type-tag and a list_node
   representing the head of the list, for NAME and VALUE.  */
static inline tree_node make_list_node (YYLTYPE *location,
					node_type nodeType,
					const char *name,
					tree_node value);

/* Make a expr_node made up of the NODETYPE type-tag and an expr_node
   with given RECEIVER, SELECTOR and EXPRESSION.  */
static inline tree_node make_expr_node (YYLTYPE *location,
					node_type nodeType,
					tree_node receiver,
					OOP selector,
					tree_node expression);

/* Allocate from the compilation obstack a node and assign it the
   NODETYPE type-tag.  */
static inline tree_node make_tree_node (YYLTYPE *location,
					node_type nodeType);

/* Print the NODE method_node with LEVEL spaces of indentation.  */
static void print_method_node (tree_node node,
			       int level);

/* Print the NODE method_node with LEVEL spaces of indentation.  */
static void print_block_node (tree_node node,
			      int level);

/* Print the NODE expr_node with LEVEL spaces of indentation.  */
static void print_expr_node (tree_node node,
			     int level);

/* Print the NODE list_node with LEVEL spaces of indentation.  */
static void print_list_node (tree_node node,
			     int level);

/* Print the NODE list_node with LEVEL spaces of indentation,
   assuming it is a attribute.  */
static void print_attribute_list_node (tree_node node,
				       int level);

/* Print the NODE const_node with LEVEL spaces of indentation.  */
static void print_const_node (tree_node node,
			      int level);

/* Print the NODE list_node with LEVEL spaces of indentation, 
   discarding the NAME of each node (hence the distinction between
   this and print_list_node).  */
static void print_array_constructor_node (tree_node node,
					  int level);

/* Print LEVEL spaces of indentation.  */
static void indent (int level);



int
_gst_list_length (tree_node listExpr)
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

tree_node
_gst_make_array_elt (YYLTYPE *location,
		     tree_node elt)
{
  return (make_list_node (location, TREE_ARRAY_ELT_LIST, NULL, elt));
}


tree_node
_gst_make_method (YYLTYPE *location,
		  YYLTYPE *endLocation,
		  tree_node selectorExpr,
		  tree_node temporaries,
		  tree_node attributes,
		  tree_node statements,
		  OOP currentEnvironment,
		  OOP currentClass,
		  OOP currentCategory,
		  mst_Boolean untrusted,
		  mst_Boolean isOldSyntax)
{
  tree_node result;

  result = make_tree_node (location, TREE_METHOD_NODE);
  if (!selectorExpr)
    selectorExpr = _gst_make_unary_expr (location,
					 NULL, "executeStatements");

  result->v_method.endPos = endLocation->file_offset;
  result->v_method.selectorExpr = selectorExpr;
  result->v_method.temporaries = temporaries;
  result->v_method.attributes = attributes;
  result->v_method.statements = statements;
  result->v_method.currentEnvironment = currentEnvironment;
  result->v_method.currentClass = currentClass;
  result->v_method.currentCategory = currentCategory;
  result->v_method.untrusted = untrusted;
  result->v_method.isOldSyntax = isOldSyntax;
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
		      const char *unarySelectorExpr)
{
  OOP selector;

  /* selectors, being interned symbols, don't need to be incubated --
     symbols once created are always referenced */
  selector = _gst_intern_string (unarySelectorExpr);
  return (make_expr_node (location, TREE_UNARY_EXPR, receiver, selector, NULL));
}

tree_node
_gst_intern_ident (YYLTYPE *location,
		   const char *ident)
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
_gst_make_attribute_list (YYLTYPE *location,
		          tree_node constant)
{
  return (make_list_node (location, TREE_ATTRIBUTE_LIST, NULL, constant));
}

tree_node
_gst_make_keyword_list (YYLTYPE *location,
			const char *keyword,
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
     to TREE_VAR_DECL_LIST.  */
  variable->nodeType = TREE_VAR_DECL_LIST;
  return (variable);
}

tree_node
_gst_make_assignment_list (YYLTYPE *location,
		     tree_node variable)
{
  /* Actually, we rely on the fact that a variable is represented as a
     tree node of type list_node, so all we do is change the node tag
     to TREE_VAR_DECL_LIST.  */
  return (make_list_node (location, TREE_VAR_ASSIGN_LIST, NULL, variable));
}


tree_node
_gst_make_binary_expr (YYLTYPE *location,
		       tree_node receiver,
		       const char *binaryOp,
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
		    const char *name)
{
  return (make_list_node (location, TREE_VARIABLE_NODE, name, NULL));
}


tree_node
_gst_make_int_constant (YYLTYPE *location,
		     intptr_t ival)
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
		           const char *sval)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_STRING;
  result->v_const.val.sVal = sval;

  return (result);
}

tree_node
_gst_make_deferred_binding_constant (YYLTYPE *location,
				     tree_node varNode)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_DEFERRED_BINDING;
  result->v_const.val.aVal = varNode;

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
_gst_make_char_constant (YYLTYPE *location, int ival)
{
  tree_node result;

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_CHAR;
  result->v_const.val.iVal = ival;

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

  result = make_tree_node (location, TREE_CONST_EXPR);
  result->v_const.constType = CONST_BINDING;
  result->v_const.val.aVal = variables;

  return (result);
}

tree_node
_gst_add_node (tree_node n1,
	       tree_node n2)
{
  if (n1 == NULL)
    return n2;

  *(n1->v_list.nextAddr) = n2;
  n1->v_list.nextAddr = n2->v_list.nextAddr;
  return n1;
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
		const char *name,
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
  const char *name;
  if (node == NULL)
    {
      printf ("(nil)\n");
      return;
    }

  if (node->nodeType < TREE_FIRST || node->nodeType > TREE_LAST)
    {
      printf ("Unknown tree node type %d\n", node->nodeType);
      return;
    }

  switch (node->nodeType)
    {
    case TREE_METHOD_NODE: name = "TREE_METHOD_NODE"; break;
    case TREE_UNARY_EXPR: name = "TREE_UNARY_EXPR"; break;
    case TREE_BINARY_EXPR: name = "TREE_BINARY_EXPR"; break;
    case TREE_KEYWORD_EXPR: name = "TREE_KEYWORD_EXPR"; break;
    case TREE_VARIABLE_NODE: name = "TREE_VARIABLE_NODE"; break;
    case TREE_ATTRIBUTE_LIST: name = "TREE_ATTRIBUTE_LIST"; break;
    case TREE_KEYWORD_LIST: name = "TREE_KEYWORD_LIST"; break;
    case TREE_VAR_DECL_LIST: name = "TREE_VAR_DECL_LIST"; break;
    case TREE_VAR_ASSIGN_LIST: name = "TREE_VAR_ASSIGN_LIST"; break;
    case TREE_STATEMENT_LIST: name = "TREE_STATEMENT_LIST"; break;
    case TREE_RETURN_EXPR: name = "TREE_RETURN_EXPR"; break;
    case TREE_ASSIGN_EXPR: name = "TREE_ASSIGN_EXPR"; break;
    case TREE_CONST_EXPR: name = "TREE_CONST_EXPR"; break;
    case TREE_SYMBOL_NODE: name = "TREE_SYMBOL_NODE"; break;
    case TREE_ARRAY_ELT_LIST: name = "TREE_ARRAY_ELT_LIST"; break;
    case TREE_BLOCK_NODE: name = "TREE_BLOCK_NODE"; break;
    case TREE_CASCADE_EXPR: name = "TREE_CASCADE_EXPR"; break;
    case TREE_MESSAGE_LIST: name = "TREE_MESSAGE_LIST"; break;
    case TREE_ARRAY_CONSTRUCTOR: name = "TREE_ARRAY_CONSTRUCTOR"; break;
    default: abort ();
    }

  printf ("%s\n", name);
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

    case TREE_ATTRIBUTE_LIST:
      print_attribute_list_node (node, level + 2);
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
	  node->v_list.name ? node->v_list.name : "(nil)");
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
  printf ("attributes: ");
  _gst_print_tree (node->v_method.attributes, level + 9);
  indent (level);
  printf ("statements: ");
  _gst_print_tree (node->v_method.statements, level + 12);
  indent (level);
  if (node->v_method.untrusted)
    printf ("untrusted\n");
  else
    printf ("trusted\n");
  if (node->v_method.isOldSyntax)
    printf ("old syntax\n");
  else
    printf ("new syntax\n");
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

    case CONST_DEFERRED_BINDING:
      printf ("deferred variable binding: ");
      _gst_print_tree (node->v_const.val.aVal, level + 27);
      break;

    case CONST_BINDING:
      printf ("variable binding: ");
      _gst_print_tree (node->v_const.val.aVal, level + 18);
      break;

    default:
      _gst_errorf ("Unknown constant type %d", node->v_const.constType);
    }
}

static void
print_attribute_list_node (tree_node node,
			   int level)
{
  tree_node value = node->v_list.value;
  OOP messageOOP = value->v_const.val.oopVal;
  gst_message message = (gst_message) OOP_TO_OBJ (messageOOP);
  OOP selectorOOP = message->selector;
  gst_string selector = (gst_string) OOP_TO_OBJ (selectorOOP);
  OOP argumentsOOP = message->args;
  gst_object arguments = OOP_TO_OBJ (argumentsOOP);

  const char *sel = selector->chars;
  char *name = alloca (oop_num_fields (selectorOOP) + 1);
  int numArgs = oop_num_fields (argumentsOOP);

  int i;
  char sep;

  indent (level);
  printf ("value: ");
  for (sep = '<', i = 0; i < numArgs; sep = ' ', i++)
    {
      /* Find the end of this keyword and print it together with
         its argument.  */
      const char *end = strchr (sel, ':');
      memcpy (name, sel, end - sel);
      name[end - sel] = 0;
      sel = end + 1;
      printf ("%c%s: %O", sep, name, arguments->data[i]);
    }

  printf (">\n");
  if (node->v_list.next)
    {
      indent (level - 2);
      _gst_print_tree (node->v_list.next, level - 2);
    }
}

static void
indent (int level)
{
  printf ("%*s", level, "");
}
