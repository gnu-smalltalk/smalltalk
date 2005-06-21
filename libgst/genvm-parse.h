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
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
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
     ID = 258,
     EXPR = 259,
     NUMBER = 260,
     VM_OPERATION = 261,
     VM_TABLE = 262,
     VM_BYTECODE = 263,
     VM_DOTS = 264,
     VM_MINUSMINUS = 265
   };
#endif
#define ID 258
#define EXPR 259
#define NUMBER 260
#define VM_OPERATION 261
#define VM_TABLE 262
#define VM_BYTECODE 263
#define VM_DOTS 264
#define VM_MINUSMINUS 265




#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 105 "genvm-parse.y"
typedef union YYSTYPE {
  struct operation_list *oplist;
  struct operation_info *op;
  struct table_info *tab;
  struct id_list *id;
  const char *ctext;
  char *text;
  int num;
} YYSTYPE;
/* Line 1240 of yacc.c.  */
#line 67 "genvm-parse.h"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;



