/******************************** -*- C -*- ****************************
 *
 *	External definitions for the input module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2003 Free Software Foundation, Inc.
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
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/


#ifndef GST_INPUT_H
#define GST_INPUT_H

typedef enum
{
  STREAM_UNKNOWN,
  STREAM_FILE,
  STREAM_STRING,
  STREAM_OOP
#ifdef HAVE_READLINE
    , STREAM_READLINE
#endif				/* HAVE_READLINE */
}
stream_type;

/* If true, the normal execution information is supressed, and the
   prompt is emitted with a special marker character ahead of it to
   let the process filter know that the execution has completed. */
extern mst_Boolean _gst_emacs_process;

/* Pass file descriptor FD, printed as file name FILENAME, to the
   parser. */
extern void _gst_push_unix_file (int fd,
				 const char *fileName);

/* Return the current line and column into Y and X, respectively.  */
extern void _gst_get_location (int *x, int *y);

/* Pass the OOP to the parser; it must respond to #nextHunk. */
extern void _gst_push_stream_oop (OOP oop);

/* Pass the contents of the Smalltalk String STRINGOOP to the parser.
   While the String is being parsed, it can change because it is
   saved.  The String should not contain nulls. */
extern void _gst_push_smalltalk_string (OOP stringOOP);

/* Pass the contents of the null-terminated String STRING to the
   parser.  While the String is being parsed, it can change because it
   is saved. */
extern void _gst_push_cstring (const char *string);

/* Pass the contents of stdin (either through the readline interface
   or as a vanilla file descriptor) to the parser.  The readline
   interface is used if the Emacs interface is not active and stdin is
   a tty. */
extern void _gst_push_stdin_string (void);

/* Restores the previous stream on the stack, optionally closing the
   topmost one if CLOSEIT is true. */
extern void _gst_pop_stream (mst_Boolean closeIt);

/* This function resets the file type information for the current
   stream.  It is typically used by fileIn type methods when filing in
   a subsection of a real file via a temporary file what the real
   source of the text is. */
extern void _gst_set_stream_info (int line,
				  const char *fileName,
				  int fileOffset);

/* Opens the changelog for append. */
extern void _gst_init_changes_stream (void);

/* Resets the changes file to be zero length. */
extern void _gst_reset_changes_file (void);

/* Emits a warning, with the current file and line in front of it, on
   the standard error descriptor. */
extern void _gst_warningf (const char *str,
			   ...) ATTRIBUTE_PRINTF_1;

/* Emits a warning, with the current file and the given LINE in front
   of it, on the standard error descriptor. */
extern void _gst_warningf_at (int line,
			      const char *str,
			      ...) ATTRIBUTE_PRINTF_2;

/* Emits an error, with the current file and line in front of it, on
   the standard error descriptor. */
extern void _gst_errorf (const char *str,
			 ...) ATTRIBUTE_PRINTF_1;

/* Emits an error, with the current file and the given LINE in front
   of it, on the standard error descriptor. */
extern void _gst_errorf_at (int line,
			    const char *str,
			    ...) ATTRIBUTE_PRINTF_2;

/* Interface to the Bison-generated parser. */
extern void _gst_yyerror (const char *s);

/* Push character 'ic' back into the input queue.  Allows for two
   character pushback currently.  This solves the problem of lexing
   3. and then finding out that what we should have lexed was 3
   followed by . as a statement terminator. */
extern void _gst_unread_char (int ic);

/* Return the next character from the topmost stream in the stack. */
extern int _gst_next_char (void);

/* Return whether the topmost stream is an interactive one. */
extern mst_Boolean _gst_get_cur_stream_prompt (void) ATTRIBUTE_PURE;

/* Return the type of the topmost stream in the stack. */
extern stream_type _gst_get_cur_stream_type (void) ATTRIBUTE_PURE;

/* The name of the changelog file. */
extern char *_gst_change_file_name;

/* Return the name of the topmost stream in the stack if it is of type
   STREAM_FILE; nil otherwise. */
extern OOP _gst_get_cur_file_name (void) ATTRIBUTE_PURE;

/* Return the file position in the topmost stream in the stack if it
   is of type STREAM_FILE; -1 otherwise. */
extern int _gst_get_cur_file_pos (void) ATTRIBUTE_PURE;

/* Returns an OOP containing the string of the topmost stream if it is
   of type STREAM_STRING; nil otherwise. */
extern OOP _gst_get_cur_string (void) ATTRIBUTE_PURE;

#ifdef HAVE_READLINE
/* Initialize the completion interface for Readline. */
extern void _gst_initialize_readline (void);

/* Look at the first LEN bytes starting at STR, and add the
   colon-separated keywords, or the whole string if it starts with an
   uppercase character AND it contains no colons. */
extern void _gst_add_symbol_completion (const char *str,
					int len);

/* Returns a Smalltalk String for the data read by the Readline
   interface, or nil if the stream does not have type
   STREAM_READLINE. */
extern OOP _gst_get_cur_readline (void) ATTRIBUTE_PURE;

/* Add 1 to the completion-enabling flag.  The flag starts at 1
   (completions are active) and completions are enabled until the flag
   falls below this value. */
extern void _gst_enable_completion (void);

/* Subtract 1 from the completion-enabling flag.  The flag starts at 1
   (completions are active) and if completions are disabled, they are
   not enabled while the flag is below this value. */
extern void _gst_disable_completion (void);


#endif /* GST_INPUT_H */


#endif
