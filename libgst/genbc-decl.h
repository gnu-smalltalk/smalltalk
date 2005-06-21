/* A Bison parser, made by GNU Bison 1.875a.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     MATCH_BYTECODES = 258,
     DECL_BEGIN = 259,
     DECL_END = 260,
     DECL_BREAK = 261,
     DECL_CONTINUE = 262,
     DECL_DISPATCH = 263,
     DECL_EXTRACT = 264,
     DECL_DOTS = 265,
     NUMBER = 266,
     ID = 267,
     EXPR = 268
   };
#endif
#define MATCH_BYTECODES 258
#define DECL_BEGIN 259
#define DECL_END 260
#define DECL_BREAK 261
#define DECL_CONTINUE 262
#define DECL_DISPATCH 263
#define DECL_EXTRACT 264
#define DECL_DOTS 265
#define NUMBER 266
#define ID 267
#define EXPR 268




#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 88 "genbc-decl.y"
typedef union YYSTYPE {
  struct field_info *field;
  const char *ctext;
  char *text;
  int num;
} YYSTYPE;
/* Line 1240 of yacc.c.  */
#line 70 "genbc-decl.h"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;



