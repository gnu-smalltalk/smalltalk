/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genprims tool
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002, 2006, 2008, 2009 Free Software Foundation, Inc.
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

%{
#include "genprims.h"
#include "md5.h"

/* This program finds declarations of the form:

      primitive NAME[ATTRS]

   or

      primitive NAME :
          prim_id NAME[ATTRS],
          prim_id NAME[ATTRS],
          prim_id NAME[ATTRS]

   and creates a function for each primitive declaration, and an entry
   in _gst_init_primitives for each prim_id declaration (note that the
   former is just a shorthand for

      primitive NAME :
          prim_id NAME[ATTRS]

   and so creates both the function and an entry).  The brackets are
   literal [ and ], and the name can be an identifier or ID = NUMBER,
   in which case the id that is given to the primitive is set by the
   programmer (this is usually done for primitives inlined by the JIT
   compiler).

   In addition, the C code is examined to see instances of expressions
   like prim_id(NAME), which are replaced with the identifier given
   (either manually or automatically) to the named primitive.
   Everything else is copied verbatim to the output stream.  */

#define YYERROR_VERBOSE 1

static void yyerror (const char *s);
static void gen_proto (const char *s);
static void gen_prim_decl (const char *s);
static void gen_prim_id (const char *name, int id, const char *attrs);
static int lookup_prim_id (const char *s);
static void free_data ();
static void output ();
static char *strtoupper (char *s);

#define YYPRINT(fp, tok, val) fprintf (fp, "%s", val);

Filament *proto_fil, *stmt_fil, *def_fil, *literal_fil;

typedef struct string_list {
  char *name;
  int id;
  struct string_list *next;
} string_list;

static char *current_func_name;
static int prim_no;
static int current_id;
static int errors;
static string_list *current_ids;

#define NOT_FOUND INT_MIN
%}

%debug
%defines

%union {
  Filament *fil;
  char *text;
  int id;
}

/* single definite characters */     
%token <text> PRIMITIVE "primitive"
%token <text> PRIM_ID "prim_id"
%token <text> NUMBER "number"
%token <text> ID "identifier"
%token <text> '[' ']' '(' ')' '{' '}' ',' '=' ':'
%token LITERAL WSPACE

%type <text> primitive_attrs prim_id_decl
%type <fil> primitive_attr_list
%type <id> primitive_number
%type <id> prim_id_ref

%%

input:
	input primitive_decl '{' 
	  {
	    filprintf (stmt_fil, "#line %d \"prims.def\"\n{", yylineno);
	  }
	  body '}'
	  {
	    free_data ();
	  }
	| /* empty */
	  {
	  }
	;

primitive_decl:
	PRIMITIVE ID
	  {
	    current_id = 0;
	    current_func_name = strdup ($2);
	    gen_proto ($2);
	    gen_prim_decl ($2);
	  }
	primitive_decl_2
	  {
	  }
	;

primitive_decl_2: 
        primitive_number primitive_attrs
	  {
	    gen_prim_id (current_func_name, $1, $2);
	    free ($2);
	  }
	| ':' prim_id_decls
	  {
	  }
	;

primitive_number:
	'=' NUMBER
	  {
	    $$ = strtoul ($2, NULL, 10);
	  }
	| /* empty */
	  {
	    $$ = current_id--;
	  }
	;
	
primitive_attrs:
	'[' primitive_attr_list ']'
	  {
	    $$ = fildelete ($2);
	    strtoupper ($$);
	  }
	;
	
primitive_attr_list:
	ID
	  {
	    $$ = filnew ("PRIM_", 5);
	    filcat ($$, $1);
	  }
	| primitive_attr_list ',' ID
	  {
	    $$ = $1;
	    filcat ($$, " | PRIM_");
	    filcat ($$, $3);
	  }
	;
	
prim_id_decls:
	prim_id_decls ',' prim_id_decl
	  {
	  }
	| prim_id_decl
	  {
	  }
	;

prim_id_decl:
	PRIM_ID ID
	  {
	    $<text>$ = strdup($2);
	  }
	  primitive_number primitive_attrs
	  {
	    gen_prim_id ($<text>3, $4, $5);
	    free ($<text>3);
	    free ($5);
	  }
	;

body:
	body prim_id_ref
	  {
	    filprintf (stmt_fil, "%d", $2);
	  }
	| /* empty */
	;

prim_id_ref:
	PRIM_ID '(' ID
	  {
	    $<id>$ = lookup_prim_id ($3);
	    if ($<id>$ == NOT_FOUND)
	      yyerror ("Invalid primitive id");
	  }
	')'
	  {
	    $$ = $<id>4;
	    literal_fil = stmt_fil;
	  }
	;

%%

void
yyerror (const char *s)
{
  errors = 1;
  fprintf (stderr, "prims.def:%d: %s\n", yylineno, s);
}

int
filprintf (Filament *fil, const char *format, ...)
{
  va_list ap;
  STREAM *out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  int result;
  va_start (ap, format);
  result = stream_vprintf (out, format, ap);
  va_end (ap);
  stream_delete (out);
  return result;
}

void
gen_proto (const char *s)
{
  filprintf (proto_fil,
	     "static intptr_t\n"
	     "%s (int id ATTRIBUTE_UNUSED,\n"
	     "%*svolatile int numArgs ATTRIBUTE_UNUSED);\n\n",
	     s, 2 + strlen(s), "");
}

static void
gen_prim_decl (const char *s)
{
  filprintf (stmt_fil,
	     "intptr_t\n"
	     "%s (int id,\n"
	     "%*svolatile int numArgs)\n",
	     s, 2 + strlen(s), "");
}

char *
strtoupper (char *s)
{
  char *base = s;
  while (*s)
    *s = toupper (*s), s++;

  return base;
}

void
gen_prim_id (const char *name, int id, const char *attrs)
{
  string_list *node;
  node = (string_list *) malloc (sizeof (string_list));
  node->name = strdup (name);
  node->id = id;
  node->next = current_ids;
  current_ids = node;

  prim_no++;

  filprintf (def_fil,
	     "  _gst_default_primitive_table[%d].name = \"%s\";\n"
	     "  _gst_default_primitive_table[%d].attributes = %s;\n"
	     "  _gst_default_primitive_table[%d].id = %d;\n"
	     "  _gst_default_primitive_table[%d].func = %s;\n",
	     prim_no, name,
	     prim_no, attrs,
	     prim_no, id,
	     prim_no, current_func_name);
}

int
lookup_prim_id (const char *s)
{
  string_list *node;
  for (node = current_ids;
       node && strcmp (s, node->name); node = node->next);

  return node ? node->id : NOT_FOUND;
}

void
free_data ()
{
  string_list *first, *next;
  if (current_func_name)
    free (current_func_name);

  for (first = current_ids; first; first = next)
    {
      next = first->next;
      free (first->name);
      free (first);
    }

  current_ids = NULL;
}

void
output()
{
  char *proto, *stmt, *def;
  unsigned char md5[16];

  gen_proto ("VMpr_HOLE");

  proto = fildelete (proto_fil);
  stmt = fildelete (stmt_fil);
  def = fildelete (def_fil);

  md5_buffer (def, strlen (def), md5);

  printf ("%s\n"
	  "%s\n"
	  "intptr_t\n"
	  "VMpr_HOLE (int id,\n"
	  "           volatile int numArgs)\n"
	  "{\n"
	  "  _gst_primitives_executed++;\n"
	  "  _gst_errorf (\"Unhandled primitive operation %%d\", id);\n"
	  "\n"
	  "  UNPOP (numArgs);\n"
	  "  PRIM_FAILED;\n"
	  "}\n"
	  "\n"
	  "unsigned char\n"
	  "_gst_primitives_md5[16] = { %d, %d, %d, %d, %d, %d, %d, %d,\n"
	  "                            %d, %d, %d, %d, %d, %d, %d, %d };\n"
	  "\n"
	  "void\n"
	  "_gst_init_primitives()\n"
	  "{\n"
	  "  int i;\n"
	  "%s"
	  "\n"
	  "  for (i = %d; i < NUM_PRIMITIVES; i++)\n"
	  "    {\n"
	  "      _gst_default_primitive_table[i].name = NULL;\n"
	  "      _gst_default_primitive_table[i].attributes = PRIM_FAIL;\n"
	  "      _gst_default_primitive_table[i].id = i;\n"
	  "      _gst_default_primitive_table[i].func = VMpr_HOLE;\n"
	  "    }\n"
	  "}\n"
	  "\n",
	  proto, stmt,
	  md5[0], md5[1], md5[2], md5[3], md5[4], md5[5], md5[6], md5[7],
	  md5[8], md5[9], md5[10], md5[11], md5[12], md5[13], md5[14], md5[15],
	  def, prim_no + 1);

  free (proto);
  free (stmt);
  free (def);
}

int
main ()
{
  proto_fil = filnew (NULL, 0);
  stmt_fil = filnew (NULL, 0);
  def_fil = filnew (NULL, 0);

  literal_fil = proto_fil;
  errors = 0;
  if (yyparse () || errors)
    exit (1);

  output ();
  exit (0);
}
