/******************************** -*- C -*- ****************************
 *
 *	Lexer Module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003
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
#define SPECIAL_CHAR		8

#if defined(WIN32) || defined(__OS2__) || defined(MSDOS)
#define HAVE_DOS_STYLE_PATH_NAMES
#endif

/* This is necessary so that the grammar knows when it must switch to
   compile mode */
mst_Boolean _gst_compile_code = false;

/* The obstack containing parse tree nodes. */
struct obstack *_gst_compilation_obstack;

/* True if errors must be reported to the standard error, false if
   errors should instead stored so that they are passed to Smalltalk
   code. */
mst_Boolean _gst_report_errors = true;

/* The location of the first error reported, stored here so that
   compilation primitives can pass them to Smalltalk code. */
char *_gst_first_error_str = NULL;
char *_gst_first_error_file = NULL;
long _gst_first_error_line;

/* The starting-position state.  If this is <0, as soon as another
   token is lexed, the flag is reinitialized to the starting position
   of the next token. */
static int method_start_pos = -1;

/* Answer true if IC is a valid base-10 digit. */
static mst_Boolean is_digit (int ic);

/* Answer true if C is a valid base-BASE digit. */
static mst_Boolean is_base_digit (int c,
				  int base);

/* Answer true if the first thing available in the stream is
   the string "primitive:" */
static mst_Boolean parse_primitive (int c,
				    YYSTYPE * lvalp);

/* Parse the fractional part of a Float constant.  Store it in
   NUMPTR.  Read numbers in base-BASE, the first one being C. 
   Answer the scale (number of digits in numPtr).  If LARGEINTEGER
   is not NULL, the digits are stored in the buffer maintained
   by str.c, and LARGEINTEGER is set to true if numPtr does
   not have sufficient precision.  */
static int parse_fraction (int c,
			   int base,
			   long double *numPtr,
			   mst_Boolean *largeInteger);

/* Parse a numeric constant and return it.  Read numbers in
   base-BASE, the first one being C.  If a - was parsed,
   NEGATIVE must be true so that the sign of the result is
   changed accordingly.  If LARGEINTEGER is not NULL, the
   digits are stored in the buffer maintained by str.c,
   and LARGEINTEGER is set to true if the return value does
   not have sufficient precision. */
static long double parse_digits (int c,
			    mst_Boolean negative,
			    int base,
			    mst_Boolean * largeInteger);

/* Parse the large integer constant stored as base-BASE
   digits in the buffer maintained by str.c, adjusting
   the sign if NEGATIVE is true.  Return an embryo of the
   LargeInteger object as a byte_object structure. */
static byte_object parse_large_integer (mst_Boolean negative,
					int base);

/* Raise an error. */
static int invalid (int c,
		    YYSTYPE * lvalp);

/* Parse a comment.  C is '"'.  Return 0 to indicate the lexer
   that this lexeme must be ignored. */
static int comment (int c,
		    YYSTYPE * lvalp);

/* Parse a character literal.  C is '$' */
static int char_literal (int c,
			 YYSTYPE * lvalp);

/* Parse a binary operator.  C is the first symbol in the selector */
static int parse_bin_op (int c,
			 YYSTYPE * lvalp);

/* Parse a string literal.  C is '\'' */
static int string_literal (int c,
			   YYSTYPE * lvalp);

/* Parse a number.  C is the first digit. */
static int parse_number (int c,
			 YYSTYPE * lvalp);

/* Parse an identifier.  C is the first letter. */
static int parse_ident (int c,
			YYSTYPE * lvalp);

/* Try to parse an assignment operator.  C is ':'. */
static int parse_colon (int c,
			YYSTYPE * lvalp);

/* Convert the digit C (if it is a valid base-BASE digit) to its
   value.  Raise an error if it is invalid. */
static int digit_to_int (int c,
			 int base);

/* Raise BASE to the N-th power. */
static inline long double ipowl (long double base,
			         int n);

#ifdef LEXDEBUG
static void print_token (int token
			 YYSTYPE *yylval);
#endif

typedef struct
{
  int (*lexFunc) (int,
		  YYSTYPE *);
  int retToken;
  int _gst_char_class;
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
/*  10 */ {0, 0, WHITE_SPACE},
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
/*   ! */ {0, '!', 0},
/*   " */ {comment, 0, 0},
/*   # */ {0, '#', 0},
/*   $ */ {char_literal, 0, 0},
/*   % */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   & */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   ' */ {string_literal, 0, 0},
/*   ( */ {0, '(', 0},
/*   ) */ {0, ')', 0},
/*   * */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   + */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   , */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   - */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   . */ {0, '.', 0},
/*   / */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   0 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   1 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   2 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   3 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   4 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   5 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   6 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   7 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   8 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   9 */ {parse_number, 0, DIGIT | ID_CHAR},
/*   : */ {parse_colon, 0, 0},
/*   ; */ {0, ';', 0},
/*   < */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   = */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   > */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   ? */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   @ */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   A */ {parse_ident, 0, ID_CHAR},
/*   B */ {parse_ident, 0, ID_CHAR},
/*   C */ {parse_ident, 0, ID_CHAR},
/*   D */ {parse_ident, 0, ID_CHAR},
/*   E */ {parse_ident, 0, ID_CHAR},
/*   F */ {parse_ident, 0, ID_CHAR},
/*   G */ {parse_ident, 0, ID_CHAR},
/*   H */ {parse_ident, 0, ID_CHAR},
/*   I */ {parse_ident, 0, ID_CHAR},
/*   J */ {parse_ident, 0, ID_CHAR},
/*   K */ {parse_ident, 0, ID_CHAR},
/*   L */ {parse_ident, 0, ID_CHAR},
/*   M */ {parse_ident, 0, ID_CHAR},
/*   N */ {parse_ident, 0, ID_CHAR},
/*   O */ {parse_ident, 0, ID_CHAR},
/*   P */ {parse_ident, 0, ID_CHAR},
/*   Q */ {parse_ident, 0, ID_CHAR},
/*   R */ {parse_ident, 0, ID_CHAR},
/*   S */ {parse_ident, 0, ID_CHAR},
/*   T */ {parse_ident, 0, ID_CHAR},
/*   U */ {parse_ident, 0, ID_CHAR},
/*   V */ {parse_ident, 0, ID_CHAR},
/*   W */ {parse_ident, 0, ID_CHAR},
/*   X */ {parse_ident, 0, ID_CHAR},
/*   Y */ {parse_ident, 0, ID_CHAR},
/*   Z */ {parse_ident, 0, ID_CHAR},
/*   [ */ {0, '[', 0},
/*   \ */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   ] */ {0, ']', 0},
/*   ^ */ {0, '^', 0},
/*   _ */ {0, ASSIGNMENT, ID_CHAR},
/*   ` */ {invalid, 0, 0},
/*   a */ {parse_ident, 0, ID_CHAR},
/*   b */ {parse_ident, 0, ID_CHAR},
/*   c */ {parse_ident, 0, ID_CHAR},
/*   d */ {parse_ident, 0, ID_CHAR},
/*   e */ {parse_ident, 0, ID_CHAR},
/*   f */ {parse_ident, 0, ID_CHAR},
/*   g */ {parse_ident, 0, ID_CHAR},
/*   h */ {parse_ident, 0, ID_CHAR},
/*   i */ {parse_ident, 0, ID_CHAR},
/*   j */ {parse_ident, 0, ID_CHAR},
/*   k */ {parse_ident, 0, ID_CHAR},
/*   l */ {parse_ident, 0, ID_CHAR},
/*   m */ {parse_ident, 0, ID_CHAR},
/*   n */ {parse_ident, 0, ID_CHAR},
/*   o */ {parse_ident, 0, ID_CHAR},
/*   p */ {parse_ident, 0, ID_CHAR},
/*   q */ {parse_ident, 0, ID_CHAR},
/*   r */ {parse_ident, 0, ID_CHAR},
/*   s */ {parse_ident, 0, ID_CHAR},
/*   t */ {parse_ident, 0, ID_CHAR},
/*   u */ {parse_ident, 0, ID_CHAR},
/*   v */ {parse_ident, 0, ID_CHAR},
/*   w */ {parse_ident, 0, ID_CHAR},
/*   x */ {parse_ident, 0, ID_CHAR},
/*   y */ {parse_ident, 0, ID_CHAR},
/*   z */ {parse_ident, 0, ID_CHAR},
/*   { */ {0, '{', 0},
/*   | */ {parse_bin_op, 0, SPECIAL_CHAR},
/*   } */ {0, '}', 0},
/*   ~ */ {parse_bin_op, 0, SPECIAL_CHAR},
/*  ^? */ {invalid, 0, 0}
};


#if defined(LEXDEBUG)
static inline int yylex_internal ();

int _gst_yylex (PTR lvalp);
{
  int result;

  result = yylex_internal (lvalp);
  print_token (result, lvalp);
  return (result);
}

#define _gst_yylex yylex_internal
#endif /* LEXDEBUG */

int
_gst_yylex (PTR lvalp, YYLTYPE *llocp)
{
  int ic, result, tokenStartPos = 0;
  const lex_tab_elt *ct;

  if (_gst_compile_code)
    {
      /* The internal token is a trick to make the grammar be
         "conditional". Normally, the allowable syntax for internal
         compilation is that of a single method (without the
         terminating '!').  However, would make for an ambiguous
         grammar since a method declaration could look like an
         immediate expression.  So, when the compiler is called
         internally, we force the first token returned by the lexer to
         be INTERNAL_TOKEN and make the top most production in the
         grammar use INTERNAL_TOKEN as the first token of an internal
         method. The same happens when you have a call to methodsFor:
         - INTERNAL_TOKEN is pushed so that the grammar switches to
         the method_list production. */
      _gst_compile_code = false;
      return (INTERNAL_TOKEN);
    }

  while ((ic = _gst_next_char ()) != EOF)
    {

      ct = CHAR_TAB (ic);
      if ((ct->_gst_char_class & WHITE_SPACE) == 0)
	{
	  _gst_get_location (&llocp->first_column, &llocp->first_line);
	  if (method_start_pos < 0)
	    tokenStartPos = _gst_get_cur_file_pos ();

	  if (ct->lexFunc)
	    {
	      result = (*ct->lexFunc) (ic, (YYSTYPE *) lvalp);
	      _gst_get_location (&llocp->last_column, &llocp->last_line);
	      if (result)
		{
		  if (method_start_pos < 0)
		    /* only do this here to ignore comments */
		    method_start_pos = tokenStartPos - 1;

		  return (result);
		}
	    }
	  else if (ct->retToken)
	    {
	      llocp->last_line = llocp->first_line;
	      llocp->last_column = llocp->first_column;
	      return (ct->retToken);
	    }

	  else
	    {
	      _gst_errorf
		("Unknown character %d in input stream, ignoring", ic);
	      _gst_had_error = true;
	    }
	}
    }
  return (0);			/* keep fussy compilers happy */
}




int
invalid (int c,
	 YYSTYPE * lvalp)
{
  char charName[3], *cp;

  cp = charName;

  if (c < ' ' || c > '~')
    {
      *cp++ = '^';
      c &= 127;			/* strip high bit */
      c ^= 64;			/* uncontrolify */
    }

  *cp++ = c;
  *cp++ = '\0';

  _gst_errorf ("Invalid character %s", charName);
  _gst_had_error = true;

  return (0);			/* tell the lexer to ignore this */
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
      lvalp->cval = ic;
      return (CHAR_LITERAL);
    }
}

int
parse_colon (int c,
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
parse_bin_op (int c,
	      YYSTYPE * lvalp)
{
  char buf[3], *bp;
  int ic;

  bp = buf;
  *bp++ = c;

  ic = _gst_next_char ();
  if (c == '<')
    {
      if (ic == 'p')
	{
	  if (parse_primitive (ic, lvalp))
	    return (PRIMITIVE_START);
	}
    }

  if (ic != EOF && (CHAR_TAB (ic)->_gst_char_class & SPECIAL_CHAR))
    *bp++ = ic;			/* accumulate next char */
  else
    {
      _gst_unread_char (ic);
      if (c == '-' && is_digit (ic))
	return (parse_number ('-', lvalp));
    }

  *bp = '\0';

  lvalp->sval = xstrdup (buf);

  if (strcmp (buf, "|") == 0)
    return ('|');

  else
    return (BINOP);
}

int
string_literal (int c,
		YYSTYPE * lvalp)
{
  int ic;

  _gst_reset_buffer ();

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
      _gst_add_str_buf_char (ic);
    }
  lvalp->sval = _gst_obstack_cur_str_buf (_gst_compilation_obstack);
  return (STRING_LITERAL);
}

mst_Boolean
parse_primitive (int c,
		 YYSTYPE * lvalp)
{
  mst_Boolean result;

  parse_ident (c, lvalp);
  result = (strcmp (lvalp->sval, "primitive:") == 0);
  return (result);
}

int
parse_ident (int c,
	     YYSTYPE * lvalp)
{
  int ic, identType;

  _gst_reset_buffer ();
  _gst_add_str_buf_char (c);

  identType = IDENTIFIER;

  for (;;)
    {
      while (((ic = _gst_next_char ()) != EOF)
	     && (CHAR_TAB (ic)->_gst_char_class & ID_CHAR))
	_gst_add_str_buf_char (ic);

      /* Read a dot as '::' if followed by a letter. */
      if (ic == '.')
	{
	  ic = _gst_next_char ();
	  _gst_unread_char (ic);
	  if (CHAR_TAB (ic)->_gst_char_class == ID_CHAR)
	    {
	      _gst_unread_char (':');
	      _gst_unread_char (':');
            }
	  else
	    _gst_unread_char ('.');

	  break;
        }

      if (ic == ':')
	{
	  ic = _gst_next_char ();
	  _gst_unread_char (ic);
	  if (ic == ':' && identType == IDENTIFIER) /* Namespace if we have foo:: */
	    {
	      _gst_unread_char (':');
              break;
            }

	  if (ic == '=')
	    {			/* if we have 'foo:=' => 'foo :=' */
	      if (identType != IDENTIFIER)
		{
		  _gst_errorf ("Malformed symbol literal");
		  break;
		}
	      _gst_unread_char (':');
	      break;
	    }
	  _gst_add_str_buf_char (':');
	  if (ic == EOF
	      || (CHAR_TAB (ic)->_gst_char_class & ID_CHAR) == 0
	      || (CHAR_TAB (ic)->_gst_char_class & DIGIT) != 0)
	    {
	      if (identType == IDENTIFIER)
		{
		  /* first time through */
		  identType = KEYWORD;
		}
	      break;
	    }
	  identType = SYMBOL_KEYWORD;
	}
      else
	{
	  _gst_unread_char (ic);
	  break;
	}
    }

  lvalp->sval = _gst_obstack_cur_str_buf (_gst_compilation_obstack);

  return (identType);
}


long double
ipowl (long double base, 
       int n)
{
    int k = 1;
    long double result = 1.0;
    while (n)
    {
        if (n & k)
        {
            result *= base;
            n ^= k;
        }
        base *= base;
        k <<= 1;
    }
    return result;
}

int
parse_number (int c,
	      YYSTYPE * lvalp)
{
  OOP numOOP;
  int base, exponent, ic;
  long double num, floatExponent;
  mst_Boolean mantissaParsed = false, isNegative = false,
    largeInteger = false;
  int float_type = 0;

  base = 10;
  exponent = 0;
  ic = c;

  if (ic != '-')
    {
      num = parse_digits (ic, isNegative, 10, &largeInteger);
      ic = _gst_next_char ();
      if (ic == 'r')
	{
	  base = (int) num;
	  if (base > 36 || largeInteger)
	    {
	      _gst_errorf ("Numeric base too large %d", base);
	      _gst_had_error = true;
	    }
	  ic = _gst_next_char ();
	}
      else
	mantissaParsed = true;
    }

  /* 
   * here we've either
   *  a) parsed base, an 'r' and are sitting on the following character
   *  b) parsed the integer part of the mantissa, and are sitting on the char
   *     following it, or
   *  c) parsed nothing and are sitting on a - sign.
   */
  if (!mantissaParsed)
    {
      if (ic == '-')
	{
	  isNegative = true;
	  ic = _gst_next_char ();
	}

      num = parse_digits (ic, isNegative, base, &largeInteger);
      ic = _gst_next_char ();
    }

  if (ic == '.')
    {
      ic = _gst_next_char ();
      if (!is_digit (ic))
	{
	  /* OOPS...we gobbled the '.' by mistake...it was a statement
	     boundary delimiter.  We have an integer that we need to
	     return, and need to push back both the . and the character 
	     that we just read. */
	  _gst_unread_char (ic);
	  ic = '.';
	}
      else
	{
	  float_type = FLOATD_LITERAL;
	  exponent = parse_fraction (ic, base, &num, &largeInteger);
	  ic = _gst_next_char ();
	}
    }

  if (ic == 's')
    do
      {
        /* By default the same as the number of decimal points
	   we used. */
	floatExponent = -exponent;

	ic = _gst_next_char ();
	if (CHAR_TAB (ic)->_gst_char_class & DIGIT)
	  {
	    /* 123s4 format -- parse the exponent */
	    floatExponent = parse_digits (ic, false, 10, NULL);
	  }
	else if (CHAR_TAB (ic)->_gst_char_class & ID_CHAR)
	  {
	    /* 123stuvwxyz sends #stuvwxyz to 123!!! */
	    _gst_unread_char (ic);
	    ic = 's';
	    break;
	  }
	else
	  _gst_unread_char (ic);

        if (isNegative)
          num = -num;

        if (largeInteger || num < MIN_ST_INT || num > MAX_ST_INT)
          {
	    /* Make a LargeInteger constant and create an object out of
	       it.  */
	    byte_object bo = parse_large_integer (isNegative, base);
	    mst_Object result = instantiate_with (bo->class, bo->size, &numOOP);
            memcpy (result->data, bo->body, bo->size);
	  }
        else
          numOOP = FROM_INT(num);

	/* too much of a chore to create a Fraction, so we call-in. We
	   lose the ability to create ScaledDecimals during the very
	   first phases of bootstrapping, but who cares?... 

	   This is equivalent to 
		(num * (10 raisedToInteger: exponent)
		   asScaledDecimal: floatExponent) */
	lvalp->oval =
	  _gst_msg_send (numOOP, _gst_as_scaled_decimal_scale_symbol,
			 FROM_INT (exponent),
			 FROM_INT ((int) floatExponent), 
			 NULL);

	/* incubator is set up by _gst_compile_method */
	INC_ADD_OOP (lvalp->oval);
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
      if (ic == '-')
	{
	  floatExponent =
	    parse_digits (_gst_next_char (), true, 10, NULL);
	  exponent -= (int) floatExponent;
	}
      else if (CHAR_TAB (ic)->_gst_char_class & DIGIT)
	{
	  floatExponent = parse_digits (ic, false, 10, NULL);
	  exponent += (int) floatExponent;
	}
      else if (CHAR_TAB (ic)->_gst_char_class & ID_CHAR)
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

  if (exponent > 0)
    num *= ipowl ((long double) base, exponent);
  else
    num /= ipowl ((long double) base, -exponent);

  if (isNegative)
    num = -num;

#if defined(__FreeBSD__)
  fpsetmask (0);
#endif

  if (float_type)
    {
      lvalp->fval = num;
      return (float_type);
    }
  else if (largeInteger || num < MIN_ST_INT || num > MAX_ST_INT)
    {
      lvalp->boval = parse_large_integer (isNegative, base);
      return (LARGE_INTEGER_LITERAL);
    }
  else if (num >= 0 && num <= 255)
    {
      lvalp->ival = (long) num;
      return (BYTE_LITERAL);
    }
  else
    {
      lvalp->ival = (long) num;
      return (INTEGER_LITERAL);
    }
}

long double
parse_digits (int c,
	      mst_Boolean negative,
	      int base,
	      mst_Boolean * largeInteger)
{
  long double result;
  mst_Boolean oneDigit = false;

  if (largeInteger)
    _gst_reset_buffer ();

  while (c == '_')
    c = _gst_next_char ();

  for (result = 0.0; is_base_digit (c, base); )
    {
      result *= base;
      oneDigit = true;
      result += digit_to_int (c, base);
      if (largeInteger)
	{
	  _gst_add_str_buf_char (digit_to_int (c, base));
	  if (result > -MIN_ST_INT
	      || (!negative && result > MAX_ST_INT))
	    *largeInteger = true;
	}

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
parse_fraction (int c,
		int base,
		long double *numPtr,
		mst_Boolean *largeInteger)
{
  int scale;
  long double num;

  scale = 0;

  while (c == '_')
    c = _gst_next_char ();

  for (num = *numPtr; is_base_digit (c, base); )
    {
      num *= base;
      num += digit_to_int (c, base);
      scale--;

      if (largeInteger)
        {
          _gst_add_str_buf_char (digit_to_int (c, base));
          if (num > MAX_ST_INT)
            *largeInteger = true;
        }

      do
	c = _gst_next_char ();
      while (c == '_');
    }

  _gst_unread_char (c);

  *numPtr = num;
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
  return ((CHAR_TAB (ic)->_gst_char_class & DIGIT) != 0);
}

byte_object
parse_large_integer (mst_Boolean negative,
		     int base)
{
  int i;
  int size, digitsLeft;
  gst_uchar *digits, *result;
  byte_object bo;

  size = _gst_buffer_size ();
  digits = (gst_uchar *) alloca (size);
  _gst_copy_buffer (digits);

  bo =
    (byte_object) obstack_alloc (_gst_compilation_obstack,
				 sizeof (struct byte_object) + size);

  bo->class =
    negative ? _gst_large_negative_integer_class :
    _gst_large_positive_integer_class;
  result = bo->body;
  memzero (result, size);

  /* On each pass, multiply the previous partial result by the base,
     and sum each of the digits as they were retrieved by parse_digits. 
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


void
_gst_parse_stream (void)
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
    extern int _gst_yyparse (void);
    _gst_had_error = false;
    _gst_yyparse ();
#endif /* !NO_PARSE */
  }

  obstack_free (&thisObstack, NULL);
  _gst_compilation_obstack = oldObstack;
}


int
_gst_get_method_start_pos (void)
{
  return (method_start_pos);
}

void
_gst_clear_method_start_pos (void)
{
  method_start_pos = -1;
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
      printf (".\n");
      break;
    case '!':
      printf ("!\n");
      break;
    case ':':
      printf (":\n");
      break;
    case '|':
      printf ("|\n");
      break;
    case '^':
      printf ("^\n");
      break;
    case SCOPE_SEPARATOR:
      printf ("::\n");
      break;
    case ASSIGNMENT:
      printf (":=\n");
      break;
    case '#':
      printf ("#\n");
      break;
    case ';':
      printf (";\n");
      break;
    case '(':
      printf ("(\n");
      break;
    case ')':
      printf (")\n");
      break;
    case PRIMITIVE_START:
      printf ("<primitive:\n");
      break;
    case '[':
      printf ("[\n");
      break;
    case ']':
      printf ("]\n");
      break;
    case '{':
      printf ("{\n");
      break;
    case '}':
      printf ("}\n");
      break;
    case INTERNAL_TOKEN:
      printf ("INTERNAL_TOKEN\n");
      break;
    case IDENTIFIER:
      printf ("IDENTIFIER: %s\n", yylval->sval);
      break;
    case KEYWORD:
      printf ("KEYWORD: %s\n", yylval->sval);
      break;
    case SYMBOL_KEYWORD:
      printf ("SYMBOL_KEYWORD: %s\n", yylval->sval);
      break;
    case LARGE_INTEGER_LITERAL:
      printf ("LARGE_INTEGER_LITERAL\n");
    case INTEGER_LITERAL:
      printf ("INTEGER_LITERAL: %ld\n", yylval->ival);
      break;
    case FLOATING_LITERAL:
      printf ("FLOATING_LITERAL: %g\n", yylval->fval);
      break;
    case CHAR_LITERAL:
      printf ("CHAR_LITERAL: %c\n", yylval->cval);
      break;
    case STRING_LITERAL:
      printf ("STRING_LITERAL: %s\n", yylval->sval);
      break;
    case BINOP:
      printf ("BINOP: %s\n", yylval->sval);
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
    case KEYWORD:
    case SYMBOL_KEYWORD:
    case STRING_LITERAL:
    case BINOP:
      fprintf (file, ": `%s'", yylval->sval);
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
      fprintf (file, ": %c", yylval->cval);
      break;
    default:
      break;
    }
}
