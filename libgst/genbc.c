/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genbc tool
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
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "genbc.h"

int errors = 0;
const char *current_file;

void
yyprint (FILE *file, int type, YYSTYPE yylval)
{
  switch (type)
    {
    case NUMBER:
      fprintf (file, "%d", yylval.num);
      break;
    case ID:
    case EXPR:
      fprintf (file, "%s", yylval.text);
      break;
    default:
      break;
    }
}

void
yyerror (const char *s)
{
  errors = 1;
  fprintf (stderr, "%s:%d: %s\n", current_file, yylineno, s);
}

/* Same as asprintf, but return the allocated string directly.  */
char *
my_asprintf (const char *fmt, ...)
{
  va_list ap;
  char *s;
  va_start (ap, fmt);
  vasprintf (&s, fmt, ap);
  va_end (ap);
  return s;
}

int
main(int argc, char **argv)
{
  int i;

  if (argc < 2)
    {
      fprintf (stderr, "Usage: genbc <def-file> <impl-file>...\n");
      errors = 1;
    }
  else
    {
      parse_declarations (argv[1]);

      if (errors)
	exit (errors);

      /* Emit the header guard.  */
      printf ("#ifndef GST_MATCH_H\n");
      printf ("#define GST_MATCH_H\n\n");

      /* Matchers are invoked by expanding a macro.  The code for the
	 matcher itself is similar enough to C that the preprocessor is
	 not upset -- and the compiler never sees it.

	 The MATCH_BYTECODES macro expands to the decoding code (which is
	 common to all invocations of MATCH_BYTECODES), followed (via
	 MATCH_BYTECODES_DISPATCH) by the action code that is specific to
	 each occurrence of MATCH_BYTECODES.  */
      printf ("#define MATCH_BYTECODES(name_, bp_, code_) BEGIN_MACRO { \\\n");
      emit_opcodes ();
      printf ("} END_MACRO\n");
      printf ("\n");
      printf ("#define MATCH_BYTECODES_DISPATCH(name) name\n");

      for (i = 2; i < argc && !errors; i++)
        parse_implementation (argv[i]);

      /* End the header guard.  */
      printf ("#endif\n");
    }

  exit (errors);
}
