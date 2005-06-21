/* A Bison parser, made from /home/utente/devel-gst-stable/libgst/genpr-parse.y, by GNU bison 1.49b.  */

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
     PRIMITIVE = 258,
     PRIM_ID = 259,
     NUMBER = 260,
     ID = 261,
     LITERAL = 262,
     WSPACE = 263
   };
# endif
  /* POSIX requires `int' for tokens in interfaces.  */
# define YYTOKENTYPE int
#endif /* !YYTOKENTYPE */
#define PRIMITIVE 258
#define PRIM_ID 259
#define NUMBER 260
#define ID 261
#define LITERAL 262
#define WSPACE 263




#ifndef YYSTYPE
#line 95 "genpr-parse.y"
typedef union {
  Filament *fil;
  char *text;
  int id;
} yystype;
/* Line 1292 of /usr/share/bison/yacc.c.  */
#line 65 "genpr-parse.h"
# define YYSTYPE yystype
#endif

extern YYSTYPE yylval;


#endif /* not BISON_Y_TAB_H */

