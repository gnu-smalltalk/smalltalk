/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk language grammar definition
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2005, 2006 Free Software Foundation, Inc.
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

#ifndef GST_PARSE_H
#define GST_PARSE_H

#define TOKEN_DEFS \
  TOKEN_DEF (SCOPE_SEPARATOR, 261, "'.' or '::'", -1) TOKEN_SEP \
  TOKEN_DEF (ASSIGNMENT, 262, "'_' or ':='", -1) TOKEN_SEP \
  TOKEN_DEF (SHEBANG, 263, "'#!'", -1) TOKEN_SEP \
  TOKEN_DEF (IDENTIFIER, 264, "identifier", -1) TOKEN_SEP \
  TOKEN_DEF (BINOP, 265, "binary operator", -1) TOKEN_SEP \
  TOKEN_DEF (KEYWORD, 266, "keyword", -1) TOKEN_SEP \
  TOKEN_DEF (STRING_LITERAL, 267, "string literal", -1) TOKEN_SEP \
  TOKEN_DEF (SYMBOL_LITERAL, 268, "symbol literal", -1) TOKEN_SEP \
  TOKEN_DEF (INTEGER_LITERAL, 269, "integer literal", -1) TOKEN_SEP \
  TOKEN_DEF (LARGE_INTEGER_LITERAL, 270, "integer literal", 269) TOKEN_SEP \
  TOKEN_DEF (BYTE_LITERAL, 271, "small integer literal", 269) TOKEN_SEP \
  TOKEN_DEF (FLOATD_LITERAL, 272, "floating-point literal", -1) TOKEN_SEP \
  TOKEN_DEF (FLOATE_LITERAL, 273, "floating-point literal", 272) TOKEN_SEP \
  TOKEN_DEF (FLOATQ_LITERAL, 274, "floating-point literal", 272) TOKEN_SEP \
  TOKEN_DEF (SCALED_DECIMAL_LITERAL, 275, "decimal literal", -1) TOKEN_SEP \
  TOKEN_DEF (CHAR_LITERAL, 276, "character literal", -1)

#define FIRST_TOKEN (SCOPE_SEPARATOR)
#define NUM_TOKENS (CHAR_LITERAL - SCOPE_SEPARATOR + 1)

#define TOKEN_SEP ,
#define TOKEN_DEF(name, val, str, subsume) \
  name = val

enum yytokentype {
  TOKEN_DEFS
};

#undef TOKEN_SEP
#undef TOKEN_DEF

typedef union YYSTYPE {
  long double	       fval;
  intptr_t	       ival;
  char		      *sval;
  byte_object	       boval;
  OOP		       oval;
  tree_node	       node;
} YYSTYPE;

typedef struct YYLTYPE
{
  int first_line;
  int first_column;
} YYLTYPE;

enum parser_state {
  PARSE_METHOD,
  PARSE_METHOD_LIST,
  PARSE_DOIT
};

typedef struct gst_parser {
  int token;
  YYSTYPE val;
  YYLTYPE loc;
  enum parser_state state;
  jmp_buf recover;
} gst_parser;

/* This is necessary so that the grammar knows when it must switch to
   compile mode */
extern gst_parser *_gst_current_parser 
  ATTRIBUTE_HIDDEN;

/* Invoke the recursive descent parser.  */
extern void _gst_parse_method (void) 
  ATTRIBUTE_HIDDEN;
extern void _gst_parse_chunks (void) 
  ATTRIBUTE_HIDDEN;

#endif
