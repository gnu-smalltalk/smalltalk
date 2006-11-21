/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genbc tool - lexical analyzer
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

%x DECL
%x DECL_C_CODE
%x IMPL
%x IMPL_C_CODE
%x IMPL_END
%x IMPL_MATCH
%x CPP_CODE
%x C_COMMENT
%x C_STRING
%x C_CHAR

%option nounput
%option noyywrap
%option never-interactive

%{
#include "genbc.h"

static Filament *literal_fil;
static int from = 0, depth = 0;

#if !defined YY_FLEX_SUBMINOR_VERSION || YY_FLEX_SUBMINOR_VERSION < 31
int yylineno = 1;
#endif

static void init_scanner (FILE **pfp, YY_BUFFER_STATE *pbuf, const char *file, int start);

%}

%%

<DECL,IMPL,IMPL_END,IMPL_MATCH,C_COMMENT,CPP_CODE>{
  /* All states know how to count lines and to skip comments.  */
  \n+				{
    yylineno += yyleng;
  }

  [ \t\f]+			{
  }

  "/*"                          {
    from = YY_START;
    BEGIN (C_COMMENT);
  }
}

<DECL>{
  BEGIN				{
    return (DECL_BEGIN);
  }

  END				{
    return (DECL_END);
  }

  ".."				{
    return (DECL_DOTS);
  }

  "{"[\n]*			{
    depth = 1;
    yylineno += yyleng - 1;
    yylval.ctext = "{\n    ";
    BEGIN (DECL_C_CODE);
    return '{';
  }
}

<DECL,DECL_C_CODE>{
  [1-9][0-9]*			|
  0x[0-9A-Fa-f]+		|
  0[0-7]*			{
    yylval.num = strtol(yytext, NULL, 0);
    return (NUMBER);
  }
}

<IMPL>{
  /* Looking for matchers is a no-op until we find MATCH_BYTECODES.  */
  "MATCH_BYTECODES"		{
    BEGIN (IMPL_MATCH);
    return (MATCH_BYTECODES);
  }

  .|[^M\n]*			{
  }
}

<IMPL_END>{
  ")"				{
    BEGIN (IMPL);
    return *yytext;
  }
}

<IMPL_MATCH>{
  /* Parsing a matcher only requires us to find the closing parentheses
     and the opening brace: the rest is included in the catch-all `.' rule.  */
  ")"				{
    BEGIN (IMPL_END);
    return *yytext;
  }

  "{"				{
    depth = 1;
    literal_fil = filnew (NULL, 0);
    filccat (literal_fil, *yytext);
    BEGIN (IMPL_C_CODE);
  }
}

<IMPL,IMPL_MATCH,DECL_C_CODE,IMPL_C_CODE>{
  /* Learn how to skip strings and preprocessor code.  */
  "'"                           {
    from = YY_START;
    BEGIN (C_CHAR);

    if (literal_fil)
      filccat (literal_fil, *yytext);
    else
      {
        yylval.text = yytext;
	return (EXPR);
      }
  }

  "\""                          {
    from = YY_START;
    BEGIN (C_STRING);

    if (literal_fil)
      filccat (literal_fil, *yytext);
    else
      {
        yylval.text = yytext;
	return (EXPR);
      }
  }

  ^[ \t]*#                      {
    if (YY_START != IMPL)
      yyerror ("preprocessor directives inside matchers are invalid");
  }
}

<DECL_C_CODE>{
  extract(" "+)		{
    return (DECL_EXTRACT);
  }

  dispatch(" "+)	{
    return (DECL_DISPATCH);
  }

  break(" "*);		{
    return (DECL_BREAK);
  }

  continue(" "*);	{
    return (DECL_CONTINUE);
  }

  [ \t]*"="[ \t]*	{
    yylval.ctext = yytext;
    return '=';
  }

  [ \t]*"("[ \t]*	{
    yylval.ctext = yytext;
    return '(';
  }

  [ \t]*")"[ \t]*	{
    yylval.ctext = yytext;
    return ')';
  }

  [ \t]*","[ \t]*	{
    yylval.ctext = yytext;
    return ',';
  }

  [ \t]*"{"             {
    depth++;
    yylval.ctext = yytext;
    return EXPR;
  }

  [ \t]*"}"             {
    if (!--depth)
      {
        BEGIN (DECL);
        return '}';
      }

    yylval.ctext = yytext;
    return EXPR;
  }

  \n                    {
    yylineno++;
    yylval.ctext = " \\\n    ";
    return (EXPR);
  }

  [^a-zA-Z_'"{}(),=\n]*       {
    yylval.ctext = yytext;
    return (EXPR);
  }
}
  
<DECL,DECL_C_CODE,IMPL_MATCH>{
  [a-zA-Z_][a-zA-Z0-9_]*	{
    yylval.text = strdup (yytext);
    return (ID);
  }

  /* Put this rule last so that it does not override the others.  */
  .				{
    return *yytext;
  }
}

<IMPL_C_CODE>{
  /* Learn how to balance braces and escape new-lines.  */
  "{"                           {
    depth++;
    filccat (literal_fil, '{');
  }

  "}"                           {
    filccat (literal_fil, '}');
    if (!--depth)
      {
        yylval.text = fildelete (literal_fil);
        literal_fil = NULL;
	BEGIN (IMPL_MATCH);
        return EXPR;
      }
  }

  \n                            {
    yylineno++;
    filcat (literal_fil, " \\\n");
  }

  [^\n{}]*                      {
    filcat (literal_fil, yytext);
  }
}

<C_CHAR>{
  /* Characters and strings have different terminations...  */
  "'"                           {
    BEGIN (from);

    if (literal_fil)
      filccat (literal_fil, *yytext);
    else
      {
        yylval.text = yytext;
	return (EXPR);
      }
  }
}

<C_STRING>{
  "\""                          {
    BEGIN (from);

    if (literal_fil)
      filccat (literal_fil, *yytext);
    else
      {
        yylval.text = yytext;
	return (EXPR);
      }
  }
}

<C_STRING,C_CHAR>{
  /* ... but otherwise they're the same.  */
  \\.                           {
    yylineno += (yytext[1] == '\n');
    if (literal_fil)
      filcat (literal_fil, yytext);
    else
      {
        yylval.text = yytext;
	return (EXPR);
      }
  }

  .                             {
    yylineno += (yytext[0] == '\n');
    if (literal_fil)
      filccat (literal_fil, *yytext);
    else
      {
        yylval.text = yytext;
	return (EXPR);
      }
  }
}

<CPP_CODE>{
  /* Preprocessor directives are just skipped.  */
  [^\n]*"\\"[   ]*$             {
  }

  [^\n]*$                       {
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

%%

void
init_scanner (FILE **pfp, YY_BUFFER_STATE *pbuf, const char *file, int start)
{
  if (!strcmp (file, "-"))
    {
      *pfp = stdin;
      current_file = "stdin";
    }
  else
    {
      *pfp = fopen (file, "r");
      current_file = file;
    }

  *pbuf = yy_create_buffer (*pfp, YY_BUF_SIZE);
  yy_switch_to_buffer (*pbuf);
  yylineno = 1;
  BEGIN (start);
}

void
parse_declarations (const char *file)
{
  YY_BUFFER_STATE buf;
  FILE *fp;
  init_scanner (&fp, &buf, file, DECL);
  decl_yyparse ();
  yy_delete_buffer (buf);
  fclose (fp);
}

void parse_implementation (const char *file)
{
  YY_BUFFER_STATE buf;
  FILE *fp;
  init_scanner (&fp, &buf, file, IMPL);
  impl_yyparse ();
  yy_delete_buffer (buf);
  fclose (fp);
}
