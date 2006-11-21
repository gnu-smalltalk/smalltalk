/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genvm tool - lexical analyzer
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006 Free Software Foundation, Inc.
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

%x C_ARGS
%x C_CODE
%x C_COMMENT
%x C_STRING
%x C_CHAR
%x CPP_CODE

%option nounput
%option noyywrap
%option never-interactive

%{
#include "genvm.h"
#include "genvm-parse.h"

static int from = 0, depth = 0;
#if !defined YY_FLEX_SUBMINOR_VERSION || YY_FLEX_SUBMINOR_VERSION < 31
int yylineno = 1;
#endif
%}

%%

<INITIAL,C_COMMENT>{
  /* All states know how to count lines.  */
  \n+				{
    yylineno += yyleng;
  }

  [ \t\f]+			{
  }
}

<INITIAL>{
  table				return VM_TABLE;
  operation			return VM_OPERATION;
  bytecode			return VM_BYTECODE;

  ^[ \t]*#                     {
    printf ("%s", yytext);
    from = YY_START;
    BEGIN (CPP_CODE);
  }

  "/*"                          {
    from = YY_START;
    BEGIN (C_COMMENT);
  }

  [1-9][0-9]*			|
  0x[0-9A-Fa-f]+		|
  0[0-7]*			{
    yylval.num = strtol(yytext, NULL, 0);
    return (NUMBER);
  }

  \.\.				return VM_DOTS;
  --				return VM_MINUSMINUS;

  [a-zA-Z_][a-zA-Z_0-9]*	yylval.text = strdup (yytext); return ID;

  "("				{
    yylval.ctext = "(";
    if (c_args_on_paren)
      BEGIN (C_ARGS);
    c_args_on_paren = false;
    depth = 1;
    return '(';
  }

  "{"[\n]*			{
    yylineno += yyleng - 1;
    yylval.ctext = "{\n      ";
    if (c_code_on_brace)
      BEGIN (C_CODE);
    c_code_on_brace = false;
    depth = 1;
    return '{';
  }

  .				return *yytext;
}

<C_ARGS,C_CODE>{
  /* Learn how to skip strings.  */
  "'"                           {
    yylval.text =  yytext;
    from = YY_START;
    BEGIN (C_CHAR);
    return (EXPR);
  }

  "\""                          {
    yylval.text =  yytext;
    from = YY_START;
    BEGIN (C_STRING);
    return (EXPR);
  }
}

<C_ARGS>{
  [ \t]*"("             {
    depth++;
    yylval.ctext = yytext;
    return EXPR;
  }

  ","[ \t]*             {
    yylval.ctext = yytext;
    return ',';
  }

  ")"[ \t]*             {
    if (!--depth)
      {
        BEGIN (INITIAL);
        return ')';
      }

    yylval.ctext = yytext;
    return EXPR;
  }

  [^(,)'"\n]*	        {
    yylval.ctext = yytext;
    return (EXPR);
  }
}
  
<C_CODE>{
  [ \t]*"{"             {
    depth++;
    yylval.ctext = yytext;
    return EXPR;
  }

  [ \t]*"}"             {
    if (!--depth)
      {
        BEGIN (INITIAL);
        return '}';
      }

    yylval.ctext = yytext;
    return EXPR;
  }

  \n                    {
    yylineno++;
    yylval.ctext = "\n      ";
    return (EXPR);
  }

  [^{}'"\n]*	        {
    yylval.ctext = yytext;
    return (EXPR);
  }
}
  
<C_CHAR>{
  /* Characters and strings have different terminations...  */
  "'"                           {
    yylval.text =  yytext;
    BEGIN (from);
    return (EXPR);
  }
}

<C_STRING>{
  "\""                          {
    yylval.text =  yytext;
    BEGIN (from);
    return (EXPR);
  }
}

<C_STRING,C_CHAR>{
  /* ... but otherwise they're the same.  */
  \\.                           {
    yylineno += (yytext[1] == '\n');
    yylval.text =  yytext;
    return (EXPR);
  }

  .                             {
    yylineno += (yytext[0] == '\n');
    yylval.text =  yytext;
    return (EXPR);
  }
}

<C_COMMENT>{
  /* And so are comments.  */
  [^*\n]*"*"*\n			{
    yylineno++;
  }

  [^*\n]*"*"+[^/*]		{
  }

  [^*\n]*"*"+"/"		{
    BEGIN (from);
  }
}

<CPP_CODE>{
  /* And preprocessor code; this however is printed to stdout.  */
  [^\n]*"\\"[ \t]*\n?		{
    printf("%s", yytext);
    yylineno += yytext[yyleng - 1] == '\n';
  }
  [^\n]+$			{
    printf("%s", yytext);
  }
  \n+				{
    printf("%s", yytext);
    yylineno += yyleng;
    BEGIN (from);
  }
}

%%
