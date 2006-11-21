/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genprims tool - lexical analyzer
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2006 Free Software Foundation, Inc.
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

%x C_COMMENT
%x C_CHAR
%x C_STRING
%x CPP_CODE
%x C_CODE

%option nounput
%option noyywrap
%option never-interactive

%{
#include "genprims.h"
#include "genpr-parse.h"

static int from = 0, depth = 0;
#if !defined YY_FLEX_SUBMINOR_VERSION || YY_FLEX_SUBMINOR_VERSION < 31
int yylineno = 1;
#endif

/* This file implements a bit more than a lexical analyzer: it also writes
   literal tokens to the output until a reserved word is found.  This is
   done by this macro which decides whether to return the token to yyparse
   and whether to append it to a filament (these two things are not mutually
   exclusive, because braces are both written and returned, for example).

   Note that whitespace should be written to the literal_fil filament,
   but not returned to yyparse when there is no active literal_fil.

   Also note that the ifs are resolved at compile time.  */
#define IS_TOKEN(tok) \
  do { \
    if (literal_fil) \
      { \
        if (tok != PRIMITIVE && tok != PRIM_ID) \
	  filcat (literal_fil, yytext); \
	else \
	  literal_fil = NULL; \
        if (tok == PRIMITIVE || tok == PRIM_ID || tok == '{' || tok == '}') \
	  return tok; \
      } \
    else \
      { \
	if (tok == '{') \
	  literal_fil = stmt_fil; \
	if (tok != WSPACE) \
	  return tok; \
      } \
  } while(0)
%}
%%

<INITIAL,C_COMMENT,C_CHAR,C_STRING,CPP_CODE,C_CODE>{
  \n+				{
    yylval.text = yytext;
    yylineno += yyleng;
    IS_TOKEN (WSPACE);
  }
  [ 	\f]+			{
    yylval.text = yytext;
    IS_TOKEN (WSPACE);
  }

}

<INITIAL>{
  primitive			{
    yylval.text = yytext;
    IS_TOKEN (PRIMITIVE);
  }

  "["				{
    yylval.text = yytext;
    IS_TOKEN ('[');
  }

  "]"				{
    yylval.text = yytext;
    IS_TOKEN (']');
  }

  ","				{
    yylval.text = yytext;
    IS_TOKEN (',');
  }

  "="				{
    yylval.text = yytext;
    IS_TOKEN ('=');
  }

  ":"				{
    yylval.text = yytext;
    IS_TOKEN (':');
  }

  "{"				{
    yylval.text = yytext;
    depth = 1;
    BEGIN (C_CODE);
    IS_TOKEN ('{');
  }

}

<INITIAL,C_CODE>{
  "'"				{
    yylval.text = yytext;
    from = YY_START;
    BEGIN (C_CHAR);
    IS_TOKEN (LITERAL);
  }

  "\""				{
    yylval.text = yytext;
    from = YY_START;
    BEGIN (C_STRING);
    IS_TOKEN (LITERAL);
  }

  "/*"				{
    yylval.text = yytext;
    from = YY_START;
    BEGIN (C_COMMENT);
    IS_TOKEN (WSPACE);
   
  }

  ^[ 	]*#			{
    yylval.text = yytext;
    from = YY_START;
    BEGIN (CPP_CODE);
    IS_TOKEN (LITERAL);
  }

  "("				{
    yylval.text = yytext;
    IS_TOKEN ('(');
  }

  ")"				{
    yylval.text = yytext;
    IS_TOKEN (')');
  }

  prim_id			{
    yylval.text = yytext;
    IS_TOKEN (PRIM_ID);
  }

  [1-9][0-9]*			|
  0x[0-9A-Fa-f]+		|
  0[0-7]+			{
    yylval.text = yytext;
    IS_TOKEN (NUMBER);
  }

  [a-zA-Z_][a-zA-Z0-9_]*	{
    yylval.text = yytext;
    IS_TOKEN (ID);
  }

}

<C_CODE>{
  "{"				{
    yylval.text = yytext;
    depth++;
    IS_TOKEN (LITERAL);
  }

  "}"				{
    yylval.text = yytext;
    if (--depth)
      IS_TOKEN (LITERAL);
    else
      {
        BEGIN (INITIAL);
        IS_TOKEN ('}');
      }
  }

  .				{
    yylval.text = yytext;
    IS_TOKEN (LITERAL);
  }

}

<C_COMMENT>{
  [^*\n]*"*"*\n			{
    yylval.text = yytext;
    yylineno++;
    IS_TOKEN (WSPACE);
  }

  [^*\n]*"*"+[^/*]		{
    yylval.text = yytext;
    IS_TOKEN (WSPACE);
  }

  [^*\n]*"*"+"/"		{
    yylval.text = yytext;
    BEGIN (from);
    IS_TOKEN (WSPACE);
  }

}

<C_CHAR>{
  "'"				{
    yylval.text = yytext;
    BEGIN (from);
    IS_TOKEN (LITERAL);
  }
}

<C_STRING>{
  "\""				{
    yylval.text = yytext;
    BEGIN (from);
    IS_TOKEN (LITERAL);
  }
}

<C_STRING,C_CHAR>{
  \\.				{
    yylineno += (yytext[1] == '\n');
    yylval.text = yytext;
    IS_TOKEN (LITERAL);
  }

  .				{
    yylineno += (yytext[0] == '\n');
    yylval.text = yytext;
    IS_TOKEN (LITERAL);
  }
}

<CPP_CODE>{
  [^\n]*"\\"[ 	]*$		{
    yylval.text = yytext;
    IS_TOKEN (LITERAL);
  }

  [^\n]*$                       {
    yylval.text = yytext;
    BEGIN (from);
    IS_TOKEN (LITERAL);
  }

}
