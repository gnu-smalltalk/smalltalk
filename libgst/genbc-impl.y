/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genbc tool - parser for implementations
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003 Free Software Foundation, Inc.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

/* This parser looks for matchers into the C source files, and uses the
   code in the C source file to create the macros that are pasted after the
   decision tree.  */

%{
#include "genbc.h"
#define yyparse impl_yyparse
#define yydebug impl_yydebug
#define YYERROR_VERBOSE
#define YYPRINT yyprint

char *current_id;
%}

%debug
%defines

%union {
  struct field_info *field;
  const char *ctext;
  char *text;
  int num;
}

%token MATCH_BYTECODES "MATCH_BYTECODES"
%token DECL_BEGIN "BEGIN"
%token DECL_END "END"
%token DECL_BREAK "break"
%token DECL_CONTINUE "continue"
%token DECL_DISPATCH "dispatch"
%token DECL_EXTRACT "extract"
%token DECL_DOTS ".."
%token<num> NUMBER "number"
%token<text> ID "identifier"
%token<text> EXPR "expression"

%%

program:
	program matcher
	| /* empty */
	;

matcher:
	MATCH_BYTECODES '(' ID ',' ID ',' '('
	{
	  current_id = $3;
	  printf ("\n");
#if 0
	  printf ("/* %s:%d */\n", current_file, yylineno);
#endif
	  printf ("#define MATCH_BYTECODES_%s \\\n", $3);
	}
	cases ')' ')'
	{
	  free ($3);
	  printf ("\n");
	};

cases:
	case
	| cases { printf (" \\\n"); } case
	;

case:
	ids EXPR 
	{
	  printf ("  %s \\\n"
		  "  goto MATCH_BYTECODES_SWITCH_%s;",
		  $2, current_id);

	  free ($2);
	};

ids:
	ids ',' id
	| id
	;

id:
	ID
	{
	  printf ("  MATCH_BYTECODES_%s_%s: \\\n", current_id, $1);
	  free ($1);
	};
%%
