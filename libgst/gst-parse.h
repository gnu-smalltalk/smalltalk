/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk language grammar definition
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2005, 2006, 2007, 2008 Free Software Foundation, Inc.
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

#ifndef GST_PARSE_H
#define GST_PARSE_H

#define TOKEN_DEFS \
  TOKEN_DEF (SCOPE_SEPARATOR, 261, "'.' or '::'", -1) \
  TOKEN_DEF (ASSIGNMENT, 262, "'_' or ':='", -1) \
  TOKEN_DEF (SHEBANG, 263, "'#!'", -1) \
  TOKEN_DEF (IDENTIFIER, 264, "identifier", -1) \
  TOKEN_DEF (BINOP, 265, "binary operator", -1) \
  TOKEN_DEF (KEYWORD, 266, "keyword", -1) \
  TOKEN_DEF (STRING_LITERAL, 267, "string literal", -1) \
  TOKEN_DEF (SYMBOL_LITERAL, 268, "symbol literal", -1) \
  TOKEN_DEF (INTEGER_LITERAL, 269, "integer literal", -1) \
  TOKEN_DEF (LARGE_INTEGER_LITERAL, 270, "integer literal", 269) \
  TOKEN_DEF (BYTE_LITERAL, 271, "small integer literal", 269) \
  TOKEN_DEF (FLOATD_LITERAL, 272, "floating-point literal", -1) \
  TOKEN_DEF (FLOATE_LITERAL, 273, "floating-point literal", 272) \
  TOKEN_DEF (FLOATQ_LITERAL, 274, "floating-point literal", 272) \
  TOKEN_DEF (SCALED_DECIMAL_LITERAL, 275, "decimal literal", -1) \
  TOKEN_DEF (CHAR_LITERAL, 276, "character literal", -1) \
  TOKEN_DEF (ERROR_RECOVERY, 277, "newline", -1)

#define FIRST_TOKEN (SCOPE_SEPARATOR)
#define NUM_TOKENS (CHAR_LITERAL - SCOPE_SEPARATOR + 1)

#define TOKEN_DEF(name, val, str, subsume) \
  name = val,

enum yytokentype {
  TOKEN_DEFS
  FIRST_UNUSED_TOKEN
};

#undef TOKEN_DEF

enum parser_state {
  PARSE_METHOD,
  PARSE_METHOD_LIST,
  PARSE_DOIT
};

typedef struct gst_lookahead {
  int token;
  YYSTYPE val;
  YYLTYPE loc;
} gst_lookahead;

typedef struct gst_parser {
  gst_lookahead la [4];
  int la_size;
  int la_first;
  enum parser_state state;
  mst_Boolean untrustedContext;
  pool_list linearized_pools;
  OOP current_namespace;
  OOP currentClass;
  OOP currentCategory;
  OOP lastMethodOOP;
  jmp_buf recover;
} gst_parser;

/* This is necessary so that the grammar knows when it must switch to
   compile mode */
extern gst_parser *_gst_current_parser 
  ATTRIBUTE_HIDDEN;

extern OOP _gst_get_current_namespace (void)
  ATTRIBUTE_HIDDEN;

/* Sets the parser's notion of the class to compile methods into.  */
extern void _gst_set_compilation_class (OOP class_oop) 
  ATTRIBUTE_HIDDEN;

/* Sets the parser's notion of the category to compile methods into.  */
extern void _gst_set_compilation_category (OOP categoryOOP) 
  ATTRIBUTE_HIDDEN;

/* Resets the parser's compilation information.  */
extern void _gst_reset_compilation_category (void) 
  ATTRIBUTE_HIDDEN;

/* Returns whether methods should be created untrusted in the current parse.  */
extern mst_Boolean _gst_untrusted_parse (void) 
  ATTRIBUTE_HIDDEN;

/* Invoke the recursive descent parser.  */
extern OOP _gst_parse_method (OOP currentClass,
                              OOP currentCategory) 
  ATTRIBUTE_HIDDEN;
extern void _gst_parse_chunks (OOP currentNamespace) 
  ATTRIBUTE_HIDDEN;

extern void _gst_print_tokens (gst_parser *p)
  ATTRIBUTE_HIDDEN;

#endif
