/* A Bison parser, made by GNU Bison 1.875.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INTERNAL_TOKEN = 258,
     SCOPE_SEPARATOR = 259,
     ASSIGNMENT = 260,
     SHEBANG = 261,
     IDENTIFIER = 262,
     KEYWORD = 263,
     STRING_LITERAL = 264,
     SYMBOL_LITERAL = 265,
     BINOP = 266,
     INTEGER_LITERAL = 267,
     BYTE_LITERAL = 268,
     FLOATD_LITERAL = 269,
     FLOATE_LITERAL = 270,
     FLOATQ_LITERAL = 271,
     CHAR_LITERAL = 272,
     SCALED_DECIMAL_LITERAL = 273,
     LARGE_INTEGER_LITERAL = 274
   };
#endif
#define INTERNAL_TOKEN 258
#define SCOPE_SEPARATOR 259
#define ASSIGNMENT 260
#define SHEBANG 261
#define IDENTIFIER 262
#define KEYWORD 263
#define STRING_LITERAL 264
#define SYMBOL_LITERAL 265
#define BINOP 266
#define INTEGER_LITERAL 267
#define BYTE_LITERAL 268
#define FLOATD_LITERAL 269
#define FLOATE_LITERAL 270
#define FLOATQ_LITERAL 271
#define CHAR_LITERAL 272
#define SCALED_DECIMAL_LITERAL 273
#define LARGE_INTEGER_LITERAL 274




#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 52 "gst-parse.y"
typedef union YYSTYPE {
  char		cval;
  long double	fval;
  intptr_t	ival;
  char		*sval;
  byte_object	boval;
  OOP		oval;
  tree_node	node;
} YYSTYPE;
/* Line 1248 of yacc.c.  */
#line 84 "gst-parse.h"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



#if ! defined (YYLTYPE) && ! defined (YYLTYPE_IS_DECLARED)
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif




