/******************************** -*- C -*- ****************************
 *
 *	External definitions for the Lexer module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2007,2008
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
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


#ifndef GST_LEX_H
#define GST_LEX_H

/* A structure holding a constant for objects having byte-sized
 *    indexed instance variables (ByteArrays and LargeIntegers).  */
typedef struct byte_object
{
  OOP class;
  int size;
  gst_uchar body[1];
}
 *byte_object;

typedef union YYSTYPE {
  long double          fval;
  intptr_t             ival;
  char                *sval;
  byte_object          boval;
  OOP                  oval;
  struct tree_node    *node;
} YYSTYPE;

typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int64_t file_offset;
} YYLTYPE;


/* True if errors must be reported to the standard error, false if
   errors should instead stored so that they are passed to Smalltalk
   code.  */
extern mst_Boolean _gst_report_errors 
  ATTRIBUTE_HIDDEN;

/* This is set to true by the parser or the compiler if an error
   (respectively, a parse error or a semantic error) is found, and
   avoids that _gst_execute_statements tries to execute the result of
   the compilation.  */
extern mst_Boolean _gst_had_error
  ATTRIBUTE_HIDDEN;

/* This is set to true by the parser if error recovery is going on.
   In this case ERROR_RECOVERY tokens are generated.  */
extern mst_Boolean _gst_error_recovery
  ATTRIBUTE_HIDDEN;

/* The location of the first error reported, stored here so that
   compilation primitives can pass them to Smalltalk code.  */
extern char *_gst_first_error_str 
  ATTRIBUTE_HIDDEN, *_gst_first_error_file 
  ATTRIBUTE_HIDDEN;
extern int _gst_first_error_line 
  ATTRIBUTE_HIDDEN;

/* The obstack containing parse tree nodes.  */
extern struct obstack *_gst_compilation_obstack 
  ATTRIBUTE_HIDDEN;

/* Parse a method from the topmost stream in the stack.  */
extern OOP _gst_parse_method_from_stream (OOP currentClass,
					  OOP currentCategory)
  ATTRIBUTE_HIDDEN;

/* Parse the topmost stream in the stack.  */
extern void _gst_parse_stream (OOP currentNamespace)
  ATTRIBUTE_HIDDEN;

/* Lexer interface to the lexer.  */
extern int _gst_yylex (PTR lvalp, YYLTYPE *llocp) 
  ATTRIBUTE_HIDDEN;

/* Print on file FILE a description of TOKEN, with auxiliary data
   stored in LVAL.  */
extern void _gst_yyprint (FILE * file,
			  int token,
			  PTR lval) 
  ATTRIBUTE_HIDDEN;

/* Negate the semantic value YYLVAL, which must be a numeric token
   of type TOKEN.  Returns true if YYLVAL is positive, false if it
   is negative.  */
extern mst_Boolean _gst_negate_yylval (int token,
				       YYSTYPE *yylval);

#endif /* GST_LEX_H */
