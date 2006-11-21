/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genbc tool - parser for implementations
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
