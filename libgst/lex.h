/******************************** -*- C -*- ****************************
 *
 *	External definitions for the Lexer module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
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
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/


#ifndef GST_LEX_H
#define GST_LEX_H

/* True if errors must be reported to the standard error, false if
   errors should instead stored so that they are passed to Smalltalk
   code. */
extern mst_Boolean _gst_report_errors;

/* The location of the first error reported, stored here so that
   compilation primitives can pass them to Smalltalk code. */
extern char *_gst_first_error_str, *_gst_first_error_file;
extern long _gst_first_error_line;

/* This is necessary so that the grammar knows when it must switch to
   compile mode */
extern mst_Boolean _gst_compile_code;

/* The obstack containing parse tree nodes. */
extern struct obstack *_gst_compilation_obstack;

/* Parse the topmost stream in the stack. */
extern void _gst_parse_stream (void);

/* Lexer interface to the lexer. */
extern int _gst_yylex (PTR lvalp, YYLTYPE *llocp);

/* Print on file FILE a description of TOKEN, with auxiliary data
   stored in LVAL. */
extern void _gst_yyprint (FILE * file,
			  int token,
			  PTR lval);

/* Return the position in the stream where the method had started. */
extern int _gst_get_method_start_pos (void) ATTRIBUTE_PURE;

/* Clear the starting-position state.  As soon as another token is
   lexed, the flag is reinitialized to the starting position of the
   next token. */
extern void _gst_clear_method_start_pos (void);

#endif /* GST_LEX_H */
