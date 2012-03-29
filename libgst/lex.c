/******************************** -*- C -*- ****************************
 *
 *	Lexer Module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,
 * 2004,2005,2006,2007,2008,2009 Free Software Foundation, Inc.
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


#include "gstpriv.h"

#if defined(__FreeBSD__)
#include <floatingpoint.h>
#endif

/* Define this if you want the lexer to print all the tokens that it scans,
 * before passing them to the parser.
 */
/* #define LEXDEBUG */

/* Define this if you're debugging the lexer and you don't want the parser
 * to be ran -- only lexical scanning will take place.
 */
/* #define NO_PARSE */



#define WHITE_SPACE		1
#define DIGIT			2
#define ID_CHAR			4
#define BIN_OP_CHAR		8
#define SYMBOL_CHAR		16

/* The obstack containing parse tree nodes.  */
struct obstack *_gst_compilation_obstack = NULL;

/* True if errors must be reported to the standard error, false if
   errors should instead stored so that they are passed to Smalltalk
   code.  */
mst_Boolean _gst_report_errors = true;

/* This is set to true by the parser or the compiler if an error
   (respectively, a parse error or a semantic error) is found, and
   avoids that _gst_execute_statements tries to execute the result of
   the compilation.  */
mst_Boolean _gst_had_error = false;

/* This is set to true by the parser if error recovery is going on.
   In this case ERROR_RECOVERY tokens are generated.  */
mst_Boolean _gst_error_recovery = false;

/* The location of the first error reported, stored here so that
   compilation primitives can pass them to Smalltalk code.  */
char *_gst_first_error_str = NULL;
char *_gst_first_error_file = NULL;
int _gst_first_error_line = 0;

/* Last returned token.  */
static int last_token;

/* Balance of parentheses.  Used to turn a newline into a period.  */
static int parenthesis_depth;

/* Answer true if IC is a valid base-10 digit.  */
static mst_Boolean is_digit (int ic);

/* Answer true if C is a valid base-BASE digit.  */
static mst_Boolean is_base_digit (int c,
				  int base);

/* Parse the fractional part of a Float constant.  Store it in
   NUMPTR.  Read numbers in base-BASE, the first one being C.  Answer the
   scale (number of digits in numPtr).  If LARGEINTEGER is not NULL,
   the digits are stored in an obstack, and LARGEINTEGER is set to true
   if numPtr does not have sufficient precision.  */
static int scan_fraction (int c,
			  mst_Boolean negative,
			  unsigned base,
			  uintptr_t *intNumPtr,
			  struct real *numPtr,
			  mst_Boolean *largeInteger);

/* Parse a numeric constant and return it.  Read numbers in
   base-BASE, the first one being C.  If a - was parsed, NEGATIVE
   must be true so that the sign of the result is changed accordingly.
   If LARGEINTEGER is not NULL, the digits are stored in an obstack,
   and LARGEINTEGER is set to true if the return value does not have
   sufficient precision.  */
static uintptr_t scan_digits (int c,
			      mst_Boolean negative,
			      unsigned base,
			      struct real * n,
			      mst_Boolean * largeInteger);

/* Parse the large integer constant stored as base-BASE
   digits in the buffer maintained by str.c, adjusting
   the sign if NEGATIVE is true.  Return an embryo of the
   LargeInteger object as a byte_object structure.  */
static byte_object scan_large_integer (mst_Boolean negative,
					int base);

/* Raise an error.  */
static int invalid (int c,
		    YYSTYPE * lvalp);

/* Parse a comment.  C is '"'.  Return 0 to indicate the lexer
   that this lexeme must be ignored.  */
static int comment (int c,
		    YYSTYPE * lvalp);

/* Parse a character literal.  C is '$' */
static int char_literal (int c,
			 YYSTYPE * lvalp);

/* Remember the current balance of open/close parentheses, used to treat
   newlines as periods.  */
static int scan_open_paren (int c,
			    YYSTYPE * lvalp);

/* Remember the current balance of open/close parentheses, used to treat
   newlines as periods.  */
static int scan_close_paren (int c,
			     YYSTYPE * lvalp);

/* Remember the current balance of open/close parentheses, used to treat
   newlines as periods.  */
static int scan_reset_paren (int c,
			     YYSTYPE * lvalp);

/* If the current balance of open/close parentheses is zero, and the
   last token was not a period or bang, treat the newline as a period.  */
static int scan_newline (int c,
			 YYSTYPE * lvalp);

/* Parse a binary operator.  C is the first symbol in the selector */
static int scan_bin_op (int c,
			YYSTYPE * lvalp);

/* Actual work for scan_bin_op is done here.  MAYBE_NUMBER is false if
   we cannot parse a negative number in this context.  */ 
static int scan_bin_op_1 (int c,
			  YYSTYPE * lvalp,
			  mst_Boolean maybe_number);


/* Parse a string literal.  C is '\'' */
static int string_literal (int c,
			   YYSTYPE * lvalp);

/* Parse a number.  C is the first digit.  */
static int scan_number (int c,
			 YYSTYPE * lvalp);

/* Parse an identifier.  C is the first letter.  */
static int scan_ident (int c,
			YYSTYPE * lvalp);

/* Try to parse an assignment operator or namespace separator.  C is ':'.  */
static int scan_colon (int c,
			YYSTYPE * lvalp);

/* Try to parse a symbol constant, or return '#'.  C is '#'.  */
static int scan_symbol (int c,
			 YYSTYPE * lvalp);

/* Convert the digit C (if it is a valid base-BASE digit) to its
   value.  Raise an error if it is invalid.  */
static int digit_to_int (int c,
			 int base);

#ifdef LEXDEBUG
static void print_token (int token,
			 YYSTYPE *yylval);
#endif

typedef struct
{
  int (*lexFunc) (int,
		  YYSTYPE *);
  int retToken;
  int char_class;
}
lex_tab_elt;

/* This macro is needed to properly handle 8-bit characters */
#define CHAR_TAB(x)		((x) < 128 ? char_table + (x) : char_table)

static const lex_tab_elt char_table[128] = {
/*   0 */ {invalid, 0, 0},
/*   1 */ {invalid, 0, 0},
/*   2 */ {invalid, 0, 0},
/*   3 */ {invalid, 0, 0},
/*   4 */ {invalid, 0, 0},
/*   5 */ {invalid, 0, 0},
/*   6 */ {invalid, 0, 0},
/*   7 */ {invalid, 0, 0},
/*   8 */ {invalid, 0, 0},
/*   9 */ {0, 0, WHITE_SPACE},
/*  10 */ {scan_newline, 0, 0},
/*  11 */ {invalid, 0, 0},
/*  12 */ {0, 0, WHITE_SPACE},
/*  13 */ {0, 0, WHITE_SPACE},
/*  14 */ {invalid, 0, 0},
/*  15 */ {invalid, 0, 0},
/*  16 */ {invalid, 0, 0},
/*  17 */ {invalid, 0, 0},
/*  18 */ {invalid, 0, 0},
/*  19 */ {invalid, 0, 0},
/*  20 */ {invalid, 0, 0},
/*  21 */ {invalid, 0, 0},
/*  22 */ {invalid, 0, 0},
/*  23 */ {invalid, 0, 0},
/*  24 */ {invalid, 0, 0},
/*  25 */ {invalid, 0, 0},
/*  26 */ {invalid, 0, 0},
/*  27 */ {invalid, 0, 0},
/*  28 */ {invalid, 0, 0},
/*  29 */ {invalid, 0, 0},
/*  30 */ {invalid, 0, 0},
/*  31 */ {invalid, 0, 0},
/*     */ {0, 0, WHITE_SPACE},
/*   ! */ {scan_reset_paren, 0, 0},
/*   " */ {comment, 0, 0},
/*   # */ {scan_symbol, 0, 0},
/*   $ */ {char_literal, 0, ID_CHAR | SYMBOL_CHAR},
/*   % */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   & */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   ' */ {string_literal, 0, 0},
/*   ( */ {scan_open_paren, 0, 0},
/*   ) */ {scan_close_paren, 0, 0},
/*   * */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   + */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   , */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   - */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   . */ {0, '.', 0},
/*   / */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   0 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   1 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   2 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   3 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   4 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   5 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   6 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   7 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   8 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   9 */ {scan_number, 0, DIGIT | ID_CHAR | SYMBOL_CHAR},
/*   : */ {scan_colon, 0, SYMBOL_CHAR},
/*   ; */ {0, ';', 0},
/*   < */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   = */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   > */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   ? */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   @ */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   A */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   B */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   C */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   D */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   E */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   F */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   G */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   H */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   I */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   J */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   K */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   L */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   M */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   N */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   O */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   P */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   Q */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   R */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   S */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   T */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   U */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   V */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   W */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   X */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   Y */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   Z */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   [ */ {scan_open_paren, 0, 0},
/*   \ */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   ] */ {scan_close_paren, 0, 0},
/*   ^ */ {0, '^', 0},
/*   _ */ {0, ASSIGNMENT, ID_CHAR | SYMBOL_CHAR},
/*   ` */ {invalid, 0, 0},
/*   a */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   b */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   c */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   d */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   e */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   f */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   g */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   h */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   i */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   j */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   k */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   l */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   m */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   n */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   o */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   p */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   q */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   r */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   s */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   t */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   u */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   v */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   w */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   x */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   y */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   z */ {scan_ident, 0, ID_CHAR | SYMBOL_CHAR},
/*   { */ {scan_open_paren, 0, 0},
/*   | */ {scan_bin_op, 0, BIN_OP_CHAR},
/*   } */ {scan_close_paren, 0, 0},
/*   ~ */ {scan_bin_op, 0, BIN_OP_CHAR},
/*  ^? */ {invalid, 0, 0}
};


#if defined(LEXDEBUG)
static inline int yylex_internal ();

int
_gst_yylex (PTR lvalp, YYLTYPE *llocp)
{
  int result;

  result = yylex_internal (lvalp, llocp);
  print_token (result, lvalp);
  return (result);
}

#define _gst_yylex yylex_internal
#endif /* LEXDEBUG */

int
_gst_yylex (PTR lvalp, YYLTYPE *llocp)
{
  int ic, result;
  const lex_tab_elt *ct;

  while ((ic = _gst_next_char ()) != EOF)
    {
      ct = CHAR_TAB (ic);
      if ((ct->char_class & WHITE_SPACE) == 0)
	{
	  *llocp = _gst_get_location ();
	  assert (ct->lexFunc || ct->retToken);
	  if (ct->lexFunc)
	    result = (*ct->lexFunc) (ic, (YYSTYPE *) lvalp);
	  else
	    result = ct->retToken;

	  if (result)
	    {
	      if (_gst_get_cur_stream_prompt ())
		last_token = result;
	      return (result);
	    }
	}
    }

  *llocp = _gst_get_location ();
  return (EOF);
}




int
invalid (int c,
	 YYSTYPE * lvalp)
{
  char cp[5];

  if (c < ' ' || c == 127)
    {
      cp[0] = '^';
      cp[1] = c ^ 64;		/* uncontrolify */
      cp[2] = '\0';
    }
  else if (c & 128)
    sprintf (cp, "%#02x", c & 255);
  else
    {
      cp[0] = c;
      cp[1] = '\0';
    }

  _gst_errorf ("Invalid character %s", cp);
  _gst_had_error = true;
  return (0);			/* tell the lexer to ignore this */
}


int
scan_reset_paren (int c,
	         YYSTYPE * lvalp)
{
  if (_gst_get_cur_stream_prompt ())
    parenthesis_depth = 0;
  return c;
}

int
scan_open_paren (int c,
	         YYSTYPE * lvalp)
{
  if (_gst_get_cur_stream_prompt ())
    parenthesis_depth++;
  return c;
}

int
scan_close_paren (int c,
	          YYSTYPE * lvalp)
{
  if (_gst_get_cur_stream_prompt ())
    parenthesis_depth--;
  return c;
}

int
scan_newline (int c,
	      YYSTYPE * lvalp)
{
  if (_gst_get_cur_stream_prompt ())
    {
      /* Newline is special-cased in the REPL.  */
      if (_gst_error_recovery)
        return ERROR_RECOVERY;

      if (parenthesis_depth == 0
          && last_token != 0
          && last_token != '.' && last_token != '!' && last_token != KEYWORD
          && last_token != BINOP && last_token != '|' && last_token != '<'
          && last_token != '>' && last_token != ';'
          && last_token != ASSIGNMENT && last_token != SCOPE_SEPARATOR)
        return ('.');
    }

  return 0;
}


int
comment (int c,
	 YYSTYPE * lvalp)
{
  int ic;

  do
    {
      ic = _gst_next_char ();
      if (ic == EOF)
	{
	  _gst_errorf ("Unterminated comment, attempting recovery");
	  _gst_had_error = true;
	  break;
	}
    }
  while (ic != c);
  return (0);
}

int
char_literal (int c,
	      YYSTYPE * lvalp)
{
  int ic;

  ic = _gst_next_char ();
  if (ic == EOF)
    {
      _gst_errorf
	("Unterminated character literal, attempting recovery");
      _gst_unread_char (ic);
      _gst_had_error = true;
      return (0);
    }
  else
    {
      if (ic > 127)
        {
          _gst_errorf
	    ("Invalid character literal, only character codes from 0 to 127 are valid");
          _gst_had_error = true;
        }
      lvalp->ival = ic;
      return (CHAR_LITERAL);
    }
}

int
scan_colon (int c,
	     YYSTYPE * lvalp)
{
  int ic;

  ic = _gst_next_char ();
  if (ic == '=')
    return (ASSIGNMENT);
  else if (ic == ':')
    return (SCOPE_SEPARATOR);
  else
    _gst_unread_char (ic);

  return (':');
}


int
scan_symbol (int c,
	      YYSTYPE *lvalp)
{
  int ic;

  ic = _gst_next_char ();
  if (ic == EOF)
    return '#';

  /* Look for a shebang (#! /).  */
  if (ic == '!')
    {
      YYLTYPE loc = _gst_get_location ();
      if (loc.first_line == 1 && loc.first_column == 2)
        {
          while (((ic = _gst_next_char ()) != EOF)
                 && ic != '\r' && ic != '\n')
            continue;
          return (SHEBANG);
        }
    }

  /* We can read a binary operator and return a SYMBOL_LITERAL,... */
  if (CHAR_TAB (ic)->char_class & BIN_OP_CHAR)
    {
      scan_bin_op_1 (ic, lvalp, false);
      return SYMBOL_LITERAL;
    }

  if (ic == '\'')
    {
      string_literal (ic, lvalp);
      return SYMBOL_LITERAL;
    }

  /* ...else, we can absorb identifier characters and colons, but
     discard anything else. */
  if ((CHAR_TAB (ic)->char_class & (DIGIT | SYMBOL_CHAR)) != SYMBOL_CHAR)
    {
      _gst_unread_char (ic);
      return '#';
    }

  obstack_1grow (_gst_compilation_obstack, ic);

  while (((ic = _gst_next_char ()) != EOF)
         && (CHAR_TAB (ic)->char_class & SYMBOL_CHAR))
    obstack_1grow (_gst_compilation_obstack, ic);

  _gst_unread_char (ic);
  obstack_1grow (_gst_compilation_obstack, '\0');
  lvalp->sval = obstack_finish (_gst_compilation_obstack);
  return SYMBOL_LITERAL;
}


int
scan_bin_op_1 (int c,
	       YYSTYPE *lvalp,
	       mst_Boolean maybe_number)
{
  char buf[3];
  int ic;

  buf[0] = c;

  ic = _gst_next_char ();
  if (ic != EOF && (CHAR_TAB (ic)->char_class & BIN_OP_CHAR))
    {
      buf[1] = ic, buf[2] = 0;	/* temptatively accumulate next char */

      /* This may be a two-character binary operator, except if
         the second character is a - and is followed by a digit.  */
      if (ic == '-')
	{
	  ic = _gst_next_char ();
	  _gst_unread_char (ic);
	  if (is_digit (ic))
	    {
	      _gst_unread_char ('-');
	      buf[1] = '\0';
	    }
	}
    }
  else
    {
      _gst_unread_char (ic);
      buf[1] = 0;
    }

  lvalp->sval = xstrdup (buf);

  if ((buf[0] == '|' || buf[0] == '<' || buf[0] == '>' || buf[0] == '-')
      && buf[1] == '\0')
    return (buf[0]);

  else
    return (BINOP);
}

int
scan_bin_op (int c,
	     YYSTYPE *lvalp)
{
  return scan_bin_op_1 (c, lvalp, true);
}

int
string_literal (int c,
		YYSTYPE * lvalp)
{
  int ic;

  for (;;)
    {
      ic = _gst_next_char ();
      if (ic == EOF)
	{
	  _gst_errorf ("Unterminated string, attempting recovery");
	  _gst_had_error = true;
	  break;
	}
      if (ic == c)
	{
	  /* check for doubled delimiters */
	  ic = _gst_next_char ();
	  if (ic != c)
	    {
	      _gst_unread_char (ic);
	      break;
	    }
	}
      obstack_1grow (_gst_compilation_obstack, ic);
    }
  obstack_1grow (_gst_compilation_obstack, '\0');
  lvalp->sval = obstack_finish (_gst_compilation_obstack);
  return (STRING_LITERAL);
}

int
scan_ident (int c,
	     YYSTYPE * lvalp)
{
  int ic, identType;

  obstack_1grow (_gst_compilation_obstack, c);

  identType = IDENTIFIER;

  while (((ic = _gst_next_char ()) != EOF)
	 && (CHAR_TAB (ic)->char_class & ID_CHAR))
    obstack_1grow (_gst_compilation_obstack, ic);

  /* Read a dot as '::' if followed by a letter.  */
  if (ic == '.')
    {
      ic = _gst_next_char ();
      _gst_unread_char (ic);
      if (ic != EOF && (CHAR_TAB (ic)->char_class & ID_CHAR))
	{
	  _gst_unread_char (':');
	  _gst_unread_char (':');
        }
      else
	_gst_unread_char ('.');
    }

  else if (ic == ':')
    {
      ic = _gst_next_char ();
      _gst_unread_char (ic);
      if (ic == ':' || ic == '=') /* foo:: and foo:= split before colon */
	_gst_unread_char (':');
      else
	{
          obstack_1grow (_gst_compilation_obstack, ':');
          identType = KEYWORD;
	}
    }

  else
    _gst_unread_char (ic);

  obstack_1grow (_gst_compilation_obstack, '\0');
  lvalp->sval = obstack_finish (_gst_compilation_obstack);
  return (identType);
}


/* TODO: We track the number in *three* formats: struct real, uintptr_t,
 * and just save the bytes for large integers.  We should just save
 * the bytes and work on those.  */

int
scan_number (int c,
	      YYSTYPE * lvalp)
{
  OOP intNumOOP;
  int base, exponent, ic;
  uintptr_t intNum;
  struct real num, dummy;
  int floatExponent;
  mst_Boolean isNegative = false, largeInteger = false;
  int float_type = 0;

  base = 10;
  exponent = 0;
  ic = c;

  assert (ic != '-');
  intNum = scan_digits (ic, false, 10, &num, &largeInteger);
  ic = _gst_next_char ();
  if (ic == 'r')
    {
      char *p = obstack_finish (_gst_compilation_obstack);
      obstack_free (_gst_compilation_obstack, p);

      if (intNum > 36 || largeInteger)
        {
          _gst_errorf ("Numeric base too large %d", base);
          _gst_had_error = true;
        }
      else
        base = intNum;
      ic = _gst_next_char ();

      /* Having to support things like 16r-123 is a pity :-) because we
	 actually incorrectly accept -16r-0.  */
      if (ic == '-')
	{
	  isNegative = true;
	  ic = _gst_next_char ();
	}

      intNum = scan_digits (ic, isNegative, base, &num, &largeInteger);
      ic = _gst_next_char ();
    }

  if (ic == '.')
    {
      ic = _gst_next_char ();
      if (!is_base_digit (ic, base))
	{
	  /* OOPS...we gobbled the '.' by mistake...it was a statement
	     boundary delimiter.  We have an integer that we need to
	     return, and need to push back both the . and the character 
	     that we just read.  */
	  _gst_unread_char (ic);
	  ic = '.';
	}
      else
	{
	  float_type = FLOATD_LITERAL;
	  exponent = scan_fraction (ic, isNegative, base, &intNum, &num, &largeInteger);
	  ic = _gst_next_char ();
	}
    }

  if (ic == 's')
    do
      {
        /* By default the same as the number of decimal points
	   we used.  */
	floatExponent = -exponent;

	ic = _gst_next_char ();
	if (ic == EOF)
	  ;
	else if (CHAR_TAB (ic)->char_class & DIGIT)
	  {
	    /* 123s4 format -- parse the exponent */
	    floatExponent = scan_digits (ic, false, 10, &dummy, NULL);
	  }
	else if (CHAR_TAB (ic)->char_class & ID_CHAR)
	  {
	    /* 123stuvwxyz sends #stuvwxyz to 123!!! */
	    _gst_unread_char (ic);
	    ic = 's';
	    break;
	  }
	else
	  _gst_unread_char (ic);

        if (largeInteger)
          {
	    /* Make a LargeInteger constant and create an object out of
	       it.  */
	    byte_object bo = scan_large_integer (isNegative, base);
	    gst_object result = instantiate_with (bo->class, bo->size, &intNumOOP);
            memcpy (result->data, bo->body, bo->size);
	  }
        else
          intNumOOP = FROM_INT((intptr_t) (isNegative ? -intNum : intNum));

	/* too much of a chore to create a Fraction, so we call-in. We
	   lose the ability to create ScaledDecimals during the very
	   first phases of bootstrapping, but who cares?... 

	   This is equivalent to 
		(intNumOOP * (10 raisedToInteger: exponent)
		   asScaledDecimal: floatExponent) */
	lvalp->oval =
	  _gst_msg_send (intNumOOP, _gst_as_scaled_decimal_radix_scale_symbol,
			 FROM_INT (exponent),
			 FROM_INT (base),
			 FROM_INT ((int) floatExponent), 
			 NULL);

	/* incubator is set up by _gst_compile_method */
	INC_ADD_OOP (lvalp->oval);
	MAKE_OOP_READONLY (lvalp->oval, true);
	return (SCALED_DECIMAL_LITERAL);
      }
    while (0);

  if (ic == 'e' || ic == 'd' || ic == 'q')
    {
      int exp_char = ic;

      switch (ic) {
	case 'e': float_type = FLOATE_LITERAL; break;
	case 'd': float_type = FLOATD_LITERAL; break;
	case 'q': float_type = FLOATQ_LITERAL; break;
      }

      ic = _gst_next_char ();
      if (ic == EOF) 
        ;
      else if (ic == '-') {
	  floatExponent =
	    scan_digits (_gst_next_char (), true, 10, &dummy, NULL);
	  exponent -= (int) floatExponent;
	}
      else if (CHAR_TAB (ic)->char_class & DIGIT)
	{
	  floatExponent = scan_digits (ic, false, 10, &dummy, NULL);
	  exponent += (int) floatExponent;
	}
      else if (CHAR_TAB (ic)->char_class & ID_CHAR)
	{
	  /* 123def sends #def to 123!!! */
	  _gst_unread_char (ic);
	  ic = exp_char;
	}
      else
	_gst_unread_char (ic);

    }
  else
    _gst_unread_char (ic);

  if (float_type)
    {
      char *p = obstack_finish (_gst_compilation_obstack);
      obstack_free (_gst_compilation_obstack, p);

      if (exponent)
	{
	  struct real r;
	  _gst_real_from_int (&r, base);
	  _gst_real_powi (&r, &r, exponent < 0 ? -exponent : exponent);
	  if (exponent < 0)
	    _gst_real_div (&num, &num, &r);
	  else
	    _gst_real_mul (&num, &r);
	}
      lvalp->fval = _gst_real_get_ld (&num);
      if (isNegative)
	lvalp->fval = -lvalp->fval;
      return (float_type);
    }
  else if (largeInteger)
    {
      lvalp->boval = scan_large_integer (isNegative, base);
      return (LARGE_INTEGER_LITERAL);
    }
  else
    {
      char *p = obstack_finish (_gst_compilation_obstack);
      obstack_free (_gst_compilation_obstack, p);
      lvalp->ival = (intptr_t) (isNegative ? -intNum : intNum);
      return (INTEGER_LITERAL);
    }
}

uintptr_t
scan_digits (int c,
	     mst_Boolean negative,
	     unsigned base,
	     struct real * n,
	     mst_Boolean * largeInteger)
{
  uintptr_t result;
  mst_Boolean oneDigit = false;

  while (c == '_')
    c = _gst_next_char ();

  memset (n, 0, sizeof (*n));
  for (result = 0.0; is_base_digit (c, base); )
    {
      unsigned  value = digit_to_int (c, base);
      if (largeInteger)
	{
	  obstack_1grow (_gst_compilation_obstack, digit_to_int (c, base));
	  if (result >
	      (negative
	       /* We want (uintptr_t) -MIN_ST_INT, but it's the same.  */
	       ? (uintptr_t) MIN_ST_INT - value
	       : (uintptr_t) MAX_ST_INT - value) / base)
	    *largeInteger = true;
	}

      _gst_real_mul_int (n, base);
      _gst_real_add_int (n, value);
      oneDigit = true;
      result *= base;
      result += value;
      do
	c = _gst_next_char ();
      while (c == '_');
    }

  if (!oneDigit)
    {
      _gst_errorf ("Unexpected EOF while scanning number");
      _gst_had_error = true;
    }

  _gst_unread_char (c);

  return (result);
}

int
scan_fraction (int c,
	       mst_Boolean negative,
	       unsigned base,
	       uintptr_t *intNumPtr,
	       struct real *numPtr,
	       mst_Boolean *largeInteger)
{
  uintptr_t intNum;
  int scale;

  scale = 0;

  while (c == '_')
    c = _gst_next_char ();

  for (intNum = *intNumPtr; is_base_digit (c, base); )
    {
      unsigned value = digit_to_int (c, base);
      if (largeInteger)
	{
	  obstack_1grow (_gst_compilation_obstack, digit_to_int (c, base));
	  if (intNum >
	      (negative
	       /* We want (uintptr_t) -MIN_ST_INT, but it's the same.  */
	       ? (uintptr_t) MIN_ST_INT - value
	       : (uintptr_t) MAX_ST_INT - value) / base)
	    *largeInteger = true;
	}

      _gst_real_mul_int (numPtr, base);
      _gst_real_add_int (numPtr, value);
      intNum *= base;
      intNum += value;
      scale--;

      do
	c = _gst_next_char ();
      while (c == '_');
    }

  _gst_unread_char (c);

  *intNumPtr = intNum;
  return scale;
}


int
digit_to_int (int c,
	      int base)
{
  if (c < '0' || (c > '9' && c < 'A') || c > 'Z')
    {
      _gst_errorf ("Invalid digit %c in number", c);
      _gst_had_error = true;
      return (0);
    }

  if (c >= 'A')
    c = c - 'A' + 10;

  else
    c -= '0';

  if (c >= base)
    {
      _gst_errorf ("Digit '%c' too large for base %d", c, base);
      _gst_had_error = true;
      return (0);
    }

  return (c);
}

mst_Boolean
is_base_digit (int c,
	       int base)
{
  if (c < '0' || (c > '9' && c < 'A') || c > 'Z')
    return (false);

  if (c >= 'A')
    c = c - 'A' + 10;

  else
    c -= '0';

  return (c < base);
}


mst_Boolean
is_digit (int ic)
{
  return (ic != EOF && (CHAR_TAB (ic)->char_class & DIGIT) != 0);
}

byte_object
scan_large_integer (mst_Boolean negative,
		     int base)
{
  int i;
  int size, digitsLeft;
  gst_uchar *digits, *result;
  byte_object bo;

  /* Copy the contents of the currently grown obstack on the stack.  */
  size = obstack_object_size (_gst_compilation_obstack);
  digits = (gst_uchar *) alloca (size);
  memcpy (digits, obstack_base (_gst_compilation_obstack), size);

  /* And reuse the area on the obstack for a struct byte_object.  */
  obstack_blank (_gst_compilation_obstack, sizeof (struct byte_object));
  bo = (byte_object) obstack_finish (_gst_compilation_obstack);

  bo->class =
    negative ? _gst_large_negative_integer_class :
    _gst_large_positive_integer_class;
  result = bo->body;
  memset (result, 0, size);

  /* On each pass, multiply the previous partial result by the base,
     and sum each of the digits as they were retrieved by scan_digits. 
   */
  for (digitsLeft = size; digitsLeft--;)
    {
      int total, carry;

      total = result[0] * base + *digits++;
      carry = total >> 8;
      result[0] = (gst_uchar) total;
      for (i = 1; i < size; i++)
	{
	  total = result[i] * base + carry;
	  carry = total >> 8;
	  result[i] = (gst_uchar) total;
	}
    }

  if (negative)
    {
      /* Do two's complement -- first invert, then increment with carry 
       */
      for (i = 0; i < size; i++)
	result[i] ^= 255;

      for (i = 0; (++result[i]) == 0; i++);

      /* Search where the number really ends -- discard trailing 111... 
         bytes but remember, the most significant bit of the last digit
         must be 1! */
      for (; size > 0 && result[size - 1] == 255; size--);
      if (result[size - 1] < 128)
	size++;
    }
  else
    {
      /* Search where the number really ends -- discard trailing 000... 
         bytes but remember, the most significant bit of the last digit 
         must be 0! */
      for (; size > 0 && result[size - 1] == 0; size--);
      if (result[size - 1] > 127)
	size++;
    }

  /* Only now can we set the size! */
  bo->size = size;
  return (bo);
}


OOP
_gst_parse_method_from_stream (OOP currentClass, OOP currentCategory)
{
  struct obstack thisObstack, *oldObstack;
  OOP methodOOP;

  /* Allow re-entrancy by allocating a different obstack every time
     _gst_parse_stream is called */
  oldObstack = _gst_compilation_obstack;
  _gst_compilation_obstack = &thisObstack;
  obstack_init (&thisObstack);

  {
#ifdef NO_PARSE
    YYSTYPE yylval;
    while (_gst_yylex (&yylval));
    methodOOP = _gst_nil_oop;
#else /* !NO_PARSE */
    _gst_had_error = false;
    methodOOP = _gst_parse_method (currentClass, currentCategory);
#endif /* !NO_PARSE */
  }

  obstack_free (&thisObstack, NULL);
  _gst_compilation_obstack = oldObstack;
  return methodOOP;
}

void
_gst_parse_stream (OOP currentNamespace)
{
  struct obstack thisObstack, *oldObstack;

  /* Allow re-entrancy by allocating a different obstack every time
     _gst_parse_stream is called */
  oldObstack = _gst_compilation_obstack;
  _gst_compilation_obstack = &thisObstack;
  obstack_init (&thisObstack);

  {
#ifdef NO_PARSE
    YYSTYPE yylval;
    while (_gst_yylex (&yylval));
#else /* !NO_PARSE */
    _gst_had_error = false;
    _gst_parse_chunks (currentNamespace);
#endif /* !NO_PARSE */
  }

  obstack_free (&thisObstack, NULL);
  _gst_compilation_obstack = oldObstack;
}



#ifdef LEXDEBUG
void
print_token (token,
	     yylval)
     int token;
     YYSTYPE *yylval;
{
  switch (token)
    {
    case 0:
      break;
    case '.':
    case '!':
    case ':':
    case '|':
    case '^':
    case '#':
    case ';':
    case '(':
    case ')':
    case '[':
    case ']':
    case '{':
    case '}':
      printf ("%c\n", token);
      break;
    case SCOPE_SEPARATOR:
      printf ("::\n");
      break;
    case ASSIGNMENT:
      printf (":=\n");
      break;
    case IDENTIFIER:
      printf ("IDENTIFIER: `%s'\n", yylval->sval);
      break;
    case KEYWORD:
      printf ("KEYWORD: `%s'\n", yylval->sval);
      break;
    case SYMBOL_LITERAL:
      printf ("SYMBOL_LITERAL: #'%s'\n", yylval->sval);
      break;
    case LARGE_INTEGER_LITERAL:
      printf ("LARGE_INTEGER_LITERAL\n");
    case INTEGER_LITERAL:
      printf ("INTEGER_LITERAL: %ld\n", yylval->ival);
      break;
    case FLOATD_LITERAL:
      printf ("FLOATD_LITERAL: %g\n", (double) yylval->fval);
      break;
    case FLOATE_LITERAL:
      printf ("FLOATE_LITERAL: %g\n", (float) yylval->fval);
      break;
    case FLOATQ_LITERAL:
      printf ("FLOATQ_LITERAL: %Lg\n", yylval->fval);
      break;
    case CHAR_LITERAL:
      printf ("CHAR_LITERAL: %d", yylval->ival, 
      if (yylval->ival >= 32 && yylval->ival <= 126)
	printf (" ($%c)", (char) yylval->ival);
      printf ("\n");
      break;
    case STRING_LITERAL:
      printf ("STRING_LITERAL: '%s'\n", yylval->sval);
      break;
    case BINOP:
      printf ("BINOP: `%s'\n", yylval->sval);
      break;
    }
}
#endif

void
_gst_yyprint (FILE * file,
	      int token,
	      PTR lval)
{
  YYSTYPE *yylval = (YYSTYPE *) lval;

  switch (token)
    {
    case IDENTIFIER:
    case BINOP:
    case KEYWORD:
      fprintf (file, ": `%s'", yylval->sval);
      break;
    case SYMBOL_LITERAL:
      fprintf (file, ": #'%s'", yylval->sval);
      break;
    case STRING_LITERAL:
      fprintf (file, ": '%s'", yylval->sval);
      break;
    case INTEGER_LITERAL:
      fprintf (file, ": %ld", yylval->ival);
      break;
    case FLOATD_LITERAL:
      fprintf (file, ": %g", (double) yylval->fval);
      break;
    case FLOATE_LITERAL:
      fprintf (file, ": %g", (float) yylval->fval);
      break;
    case FLOATQ_LITERAL:
      fprintf (file, ": %Lg", yylval->fval);
      break;
    case CHAR_LITERAL:
      fprintf (file, ": %d", yylval->ival);
      if (yylval->ival >= 32 && yylval->ival <= 126)
	fprintf (file, " ($%c)", (char) yylval->ival);
      fprintf (file, "\n");
      break;
    default:
      break;
    }
}

mst_Boolean
_gst_negate_yylval (int token, YYSTYPE *yylval)
{
  switch (token)
    {
    case INTEGER_LITERAL:
      if (yylval->ival < 0)
	return false;
      yylval->ival = -yylval->ival;
      break;
    case FLOATD_LITERAL:
    case FLOATE_LITERAL:
    case FLOATQ_LITERAL:
      if (yylval->fval < 0)
	return false;
      yylval->fval = -yylval->fval;
      break;

    case SCALED_DECIMAL_LITERAL:
      {
	int sign;
        _gst_msg_sendf (&sign, "%i %o sign", yylval->oval);
	if (sign < 0)
	  return false;

        _gst_msg_sendf (&yylval->oval, "%o %o negated", yylval->oval);
        INC_ADD_OOP (yylval->oval);
        MAKE_OOP_READONLY (yylval->oval, true);
        break;
      }

    case LARGE_INTEGER_LITERAL:
      {
        byte_object bo = yylval->boval;
        gst_uchar *digits = bo->body;
        int size = bo->size;
        int i;
	
	/* The input value must be positive.  */
        if (digits[size - 1] >= 128)
	  return false;

        /* Do two's complement -- first invert, then increment with carry */
        for (i = 0; i < size; i++)
	  digits[i] ^= 255;

        for (i = 0; (++digits[i]) == 0; i++);

        /* Search where the number really ends -- discard trailing 111... 
           bytes but remember, the most significant bit of the last digit
           must be 1! */
        for (; size > 0 && digits[size - 1] == 255; size--);
        if (digits[size - 1] < 128)
	  size++;

        assert (size <= bo->size);
	bo->size = size;
	bo->class = _gst_large_negative_integer_class;
	break;
      }

    default:
      abort ();
    }

  return true;
}
