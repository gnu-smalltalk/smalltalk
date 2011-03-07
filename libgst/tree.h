/******************************** -*- C -*- ****************************
 *
 *	Semantic Tree information declarations.
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



#ifndef GST_TREE_H
#define GST_TREE_H

/* These are the possible types of parse-tree nodes */
typedef enum
{
  TREE_METHOD_NODE,
  TREE_UNARY_EXPR,
  TREE_BINARY_EXPR,
  TREE_KEYWORD_EXPR,
  TREE_VARIABLE_NODE,
  TREE_ATTRIBUTE_LIST,
  TREE_KEYWORD_LIST,
  TREE_VAR_DECL_LIST,
  TREE_VAR_ASSIGN_LIST,
  TREE_STATEMENT_LIST,
  TREE_RETURN_EXPR,
  TREE_ASSIGN_EXPR,
  TREE_CONST_EXPR,
  TREE_SYMBOL_NODE,
  TREE_ARRAY_ELT_LIST,
  TREE_BLOCK_NODE,
  TREE_CASCADE_EXPR,
  TREE_MESSAGE_LIST,
  TREE_ARRAY_CONSTRUCTOR,

  TREE_FIRST = TREE_METHOD_NODE,
  TREE_LAST = TREE_ARRAY_CONSTRUCTOR
}
node_type;

/* A forward declaration.  */
typedef struct tree_node *tree_node;

/* A generic kind of parse-tree node that stores a list of nodes.  In
   particular, NEXTADDR points to the last NEXT pointer in the list so
   that tail adds are easier.  These nodes are also used for variables
   by storing their name in the NAME member and by setting an
   appropriate node type like TREE_VARIABLE_NODE (when the variable is
   an argument or the receiver of a message) or TREE_VAR_DECL_LIST (when
   the nodes is a list of arguments or temporaries).  */
typedef struct list_node
{
  const char *name;
  tree_node value;
  tree_node next;
  tree_node *nextAddr;
}
list_node;

/* A parse-tree node for a message send.  EXPRESSION is a list_node
   containing the arguments.  The same data structure is also used for
   assignments (TREE_ASSIGN_EXPR) and in this case RECEIVER is the list
   of assigned-to variables, SELECTOR is dummy and EXPRESSION is the
   assigned value.  */
typedef struct expr_node
{
  tree_node receiver;
  OOP selector;
  tree_node expression;
}
expr_node;

/* The different kinds of constants that can be stored in a
   const_node.  */
typedef enum
{
  CONST_BYTE_OBJECT,
  CONST_INT,
  CONST_CHAR,
  CONST_FLOATD,
  CONST_FLOATE,
  CONST_FLOATQ,
  CONST_STRING,
  CONST_OOP,
  CONST_BINDING,
  CONST_DEFERRED_BINDING,
  CONST_ARRAY
}
const_type;

/* A parse-tree node holding a constant.  CONSTTYPE identifies which
   kind of constant is stored, the VAL union can include an intptr_t, a
   double, a string (char *), an OOP (typically a Symbol, Association
   or ScaledDecimal), an array (stored as a list_node) or a
   byte_object struct (for ByteArrays and LargeIntegers).  */
typedef struct const_node
{
  const_type constType;
  union
  {
    intptr_t iVal;
    long double fVal;
    const char *sVal;
    OOP oopVal;
    tree_node aVal;
    byte_object boVal;
  }
  val;
}
const_node;

/* A parse-tree node defining a method.  SELECTOREXPR is an expr_node
   with a nil receiver, holding the selector for the method and
   a list_node (of type TREE_VAR_DECL_LIST) for the arguments.  The
   method's temporaries and statements are also held in list_nodes
   (respectively, of course, TEMPORARIES and STATEMENTS).  The final
   field is the ending position of the method in the current stream,
   or -1 if the stream is not file-based.  */
typedef struct method_node
{
  tree_node selectorExpr;
  tree_node temporaries;
  tree_node attributes;
  tree_node statements;
  OOP currentEnvironment;
  OOP currentClass;
  OOP currentCategory;
  int64_t endPos;
  char untrusted;
  char isOldSyntax;
}
method_node;

/* A parse-tree node defining a block.  Not having a name, blocks
   hold arguments in a simple list_node as well.  */
typedef struct block_node
{
  tree_node arguments;
  tree_node temporaries;
  tree_node statements;
}
block_node;


/* A generic parse-tree node has a field marking the kind of
   node (NODETYPE) and a union holding the five different
   kinds of node (list_nodes, expr_nodes, const_node,
   method_nodes and block_nodes).  */
struct tree_node
{
  node_type nodeType;
  YYLTYPE location;
  union
  {
    list_node nvList;
    expr_node nvExpr;
    const_node nvConst;
    method_node nvMethod;
    block_node nvBlock;
  }
  nodeVal;
};

#define v_block		nodeVal.nvBlock
#define v_list		nodeVal.nvList
#define v_expr		nodeVal.nvExpr
#define v_const		nodeVal.nvConst
#define v_method	nodeVal.nvMethod


/* Computes and returns the length of a parse tree list, LISTEXPR.  */
extern int _gst_list_length (tree_node listExpr)
  ATTRIBUTE_HIDDEN;


/* Create a method_node with the given fields (see description under
   struct method_node).  TEMPORARIES can possibly be NULL.  If the
   method has any attributes associated with it, then they are in
   ATTRIBUTES.  */
extern tree_node _gst_make_method (YYLTYPE *startLocation,
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
  ATTRIBUTE_HIDDEN;

/* Create an expr_node to be passed to _gst_make_method for a unary
   selector, or representing a send of a unary message
   UNARYSELECTOREXPR to the object identified by RECEIVER.  */
extern tree_node _gst_make_unary_expr (YYLTYPE *location,
				       tree_node receiver,
				       const char *unarySelectorExpr)
  ATTRIBUTE_HIDDEN;

/* Create an expr_node to be passed to _gst_make_method for
   a binary selector, or representing a send of a binary message
   BINARYOP to the object identified by RECEIVER, with the given
   ARGUMENT.  */
extern tree_node _gst_make_binary_expr (YYLTYPE *location,
				        tree_node receiver,
					const char *binaryOp,
					tree_node argument)
  ATTRIBUTE_HIDDEN;

/* Create an expr_node to be passed to _gst_make_method for a keyword
   selector, or representing a send of a keyword message identified by
   KEYWORDMESSAGE to the object identified by RECEIVER.  The selector
   is split across the different list_nodes making up KEYWORDMESSAGE
   and joined at compilation time.  */
extern tree_node _gst_make_keyword_expr (YYLTYPE *location,
				  	 tree_node receiver,
					 tree_node keywordMessage)
  ATTRIBUTE_HIDDEN;

/* Create a list_node that represents a variable called NAME (it does
   not matter if it is a global, local, or instance variable, or an
   argument).  */
extern tree_node _gst_make_variable (YYLTYPE *location,
				     const char *name)
  ATTRIBUTE_HIDDEN;

/* Create a list_node that represents a part of a keyword selector,
   KEYWORD, together with the corresponding argument EXPRESSION.  */
extern tree_node _gst_make_keyword_list (YYLTYPE *location,
				         const char *keyword,
					 tree_node expression)
  ATTRIBUTE_HIDDEN;

/* Given a constant node, create an ATTRIBUTE_LIST node.  */
extern tree_node _gst_make_attribute_list (YYLTYPE *location,
					   tree_node constant)
  ATTRIBUTE_HIDDEN;

/* Given a variable tree node, convert it to a variable list tree node
   with a NULL next link.  */
extern tree_node _gst_make_variable_list (YYLTYPE *location,
				  	  tree_node variable)
  ATTRIBUTE_HIDDEN;

/* Given a variable tree node, convert it to an assignment list tree node
   with a NULL next link.  */
extern tree_node _gst_make_assignment_list (YYLTYPE *location,
				  	    tree_node variable)
  ATTRIBUTE_HIDDEN;

/* Create an expr_node of type TREE_ASSIGN_EXPR.  */
extern tree_node _gst_make_assign (YYLTYPE *location,
				   tree_node variables,
				   tree_node expression)
  ATTRIBUTE_HIDDEN;

/* Create an expr_node of type TREE_RETURN_EXPR where the returned
   EXPRESSION is stored in the RECEIVER field of the node.  */
extern tree_node _gst_make_return (YYLTYPE *location,
				   tree_node expression)
  ATTRIBUTE_HIDDEN;

/* Create a const_node storing an intptr_t, IVAL.  */
extern tree_node _gst_make_int_constant (YYLTYPE *location,
				  	 intptr_t ival)
  ATTRIBUTE_HIDDEN;

/* Create a const_node storing a double, FVAL.  The type (FloatD,
   FloatE, FloatQ) is given by TYPE.  */
extern tree_node _gst_make_float_constant (YYLTYPE *location,
				  	   long double fval,
					   int type)
  ATTRIBUTE_HIDDEN;

/* Create a const_node storing a char, IVAL.  */
extern tree_node _gst_make_char_constant (YYLTYPE *location,
				  	  int ival)
  ATTRIBUTE_HIDDEN;

/* Create a const_node storing a symbol, pointed to by the 
   SYMBOLNODE's NAME member.  The symbol is interned and the
   const_node is created with its OOP.  */
extern tree_node _gst_make_symbol_constant (YYLTYPE *location,
				  	    tree_node symbolNode)
  ATTRIBUTE_HIDDEN;

/* Create a const_node storing a string, pointed to by SVAL.  */
extern tree_node _gst_make_string_constant (YYLTYPE *location,
				  	    const char *sval)
  ATTRIBUTE_HIDDEN;

/* Create a const_node storing a deferred variable binding, whose key
   is the variable VARNODE.  */
extern tree_node _gst_make_deferred_binding_constant (YYLTYPE *location,
						      tree_node varNode)
  ATTRIBUTE_HIDDEN;

/* Create a const_node for an array whose elements are
   described by the nodes in the list, AVAL.  */
extern tree_node _gst_make_array_constant (YYLTYPE *location,
				  	   tree_node aval)
  ATTRIBUTE_HIDDEN;

/* Create a const_node for the byte_object BOVAL (a LargeInteger).  */
extern tree_node _gst_make_byte_object_constant (YYLTYPE *location,
				  	         byte_object boval)
  ATTRIBUTE_HIDDEN;

/* Create a const_node for a ByteArray object, creating a
   byteObjectConst out of the single elements which are stored in AVAL
   as a list_node.  That is, this method converts from CONST_ARRAY
   format to byteObjectConst format and answer the resulting
   const_node.  */
extern tree_node _gst_make_byte_array_constant (YYLTYPE *location,
				  	        tree_node aval)
  ATTRIBUTE_HIDDEN;

/* Create a const_node for an object, OVAL, which is typically a
   Class or ScaledDecimal.  */
extern tree_node _gst_make_oop_constant (YYLTYPE *location,
				  	 OOP oval)
  ATTRIBUTE_HIDDEN;

/* Create an TREE_ARRAY_CONSTRUCTOR node, that is a const_node whose
   aVal does not contain other constants, but rather statements to be
   evaluated at run-time and whose results are to put each in an
   element of the array.  */
extern tree_node _gst_make_array_constructor (YYLTYPE *location,
				  	      tree_node statements)
  ATTRIBUTE_HIDDEN;

/* Resolve the variable binding to an association and create a
   const_node of CONST_OOP type.  */
extern tree_node _gst_make_binding_constant (YYLTYPE *location,
				  	     tree_node variables)
  ATTRIBUTE_HIDDEN;

/* Create a TREE_SYMBOL_NODE describing an identifier (variable,
   unary/binary selector or symbol constant, it doesn't patter) pointed
   to by IDENT.  */
extern tree_node _gst_intern_ident (YYLTYPE *location,
				    const char *ident)
  ATTRIBUTE_HIDDEN;

/* Create an element of an array constant, which is a list type object.
   Return the element with the next field NILed out and pointing to
   the first element, ELT.  */
extern tree_node _gst_make_array_elt (YYLTYPE *location,
				      tree_node elt)
  ATTRIBUTE_HIDDEN;

/* Creates a block tree node with the given ARGUMENTS, TEMPORARIES and
   STATEMENTS.  */
extern tree_node _gst_make_block (YYLTYPE *location,
				  tree_node arguments,
				  tree_node temporaries,
				  tree_node statements)
  ATTRIBUTE_HIDDEN;

/* Creates a node for holding a list of cascaded messages (basically an
   expr_node that isn't using its symbol.  MESSAGEEXPR is the expression
   invoke first as it computes the receiver.  Then the remaining
   CASCADEDMESSAGES are sent to that same receiver.  */
extern tree_node _gst_make_cascaded_message (YYLTYPE *location,
				   	     tree_node messageExpr,
					     tree_node cascadedMessages)
  ATTRIBUTE_HIDDEN;

/* Create a node of type TREE_STATEMENT_LIST, where the first node is
   EXPRESSION.  */
extern tree_node _gst_make_statement_list (YYLTYPE *location,
					   tree_node expression)
  ATTRIBUTE_HIDDEN;

/* Create a TREE_MESSAGE_LIST which is used as the second parameter to
   _gst_make_cascaded_message -- that is, it represents the sends after
   the first.  */
extern tree_node _gst_make_message_list (YYLTYPE *location,
				   	 tree_node messageElt)
  ATTRIBUTE_HIDDEN;

/* Adds node N2 onto a list of nodes headed by N1.  N1 contains the
   address of the last NEXT field in the chain, so storing N2 into
   there indirectly and then making that NEXT field point to N2's NEXT
   field works properly.  */
extern tree_node _gst_add_node (tree_node n1,
				tree_node n2)
  ATTRIBUTE_HIDDEN;

/* Free the objects on the compilation obstack.  */
extern void _gst_free_tree ()
  ATTRIBUTE_HIDDEN;

/* Print the NODE with LEVEL spaces of indentation.  */
extern void _gst_print_tree (tree_node node,
			     int level)
  ATTRIBUTE_HIDDEN;


#endif /* GST_TREE_H */
