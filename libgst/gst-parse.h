/* A Bison parser, made from /home/utente/devel-gst-stable/libgst/gst-parse.y, by GNU bison 1.49b.  */

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
   Boston, MA 02110-1301, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

#ifndef BISON_Y_TAB_H
# define BISON_Y_TAB_H

/* Tokens.  */
#ifndef YYTOKENTYPE
# if defined (__STDC__) || defined (__cplusplus)
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PRIMITIVE_START = 258,
     INTERNAL_TOKEN = 259,
     SCOPE_SEPARATOR = 260,
     ASSIGNMENT = 261,
     IDENTIFIER = 262,
     KEYWORD = 263,
     STRING_LITERAL = 264,
     SYMBOL_KEYWORD = 265,
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
# endif
  /* POSIX requires `int' for tokens in interfaces.  */
# define YYTOKENTYPE int
#endif /* !YYTOKENTYPE */
#define PRIMITIVE_START 258
#define INTERNAL_TOKEN 259
#define SCOPE_SEPARATOR 260
#define ASSIGNMENT 261
#define IDENTIFIER 262
#define KEYWORD 263
#define STRING_LITERAL 264
#define SYMBOL_KEYWORD 265
#define BINOP 266
#define INTEGER_LITERAL 267
#define BYTE_LITERAL 268
#define FLOATD_LITERAL 269
#define FLOATE_LITERAL 270
#define FLOATQ_LITERAL 271
#define CHAR_LITERAL 272
#define SCALED_DECIMAL_LITERAL 273
#define LARGE_INTEGER_LITERAL 274




#ifndef YYSTYPE
#line 52 "gst-parse.y"
typedef union {
  char		cval;
  long double	fval;
  long		ival;
  char		*sval;
  byte_object	boval;
  OOP		oval;
  tree_node	node;
} yystype;
/* Line 1292 of /usr/share/bison/yacc.c.  */
#line 91 "gst-parse.h"
# define YYSTYPE yystype
#endif



#ifndef YYLTYPE
typedef struct yyltype
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} yyltype;
# define YYLTYPE yyltype
#endif



#endif /* not BISON_Y_TAB_H */

