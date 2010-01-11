/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genbc tool - parser for definitions
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006, 2009 Free Software Foundation, Inc.
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

/* This parser builds the decision tree for matching the bytecodes.
   This file knows also how to output C code to visit that tree.  */

%{
#include "genbc.h"
#include "avltrees.h"

#define yyparse decl_yyparse
#define yydebug decl_yydebug
#define YYERROR_VERBOSE
#define YYPRINT yyprint

typedef struct bytecode_info {
  avl_node_t avl;
  const char *name;
  struct field_info *fields;
} bytecode_info;

typedef struct field_info {
  struct field_info *next, **pnext;
  const char *name;
} field_info;

typedef struct var_info {
  avl_node_t avl;
  const char *name;
} var_info;

typedef struct opcode {
  struct opcode *next;
  int first;
  int last;
  char *code;
} opcode;

static void define_decl (int first, int last, char *code);
static void define_bytecode (const char *id, field_info *fields);
static void define_var (const char *id);
static void define_field (const char *id, int bits);
static char *extraction_code (int bits);
static void emit_var_names (var_info *node, const char *prefix, const char *suffix, const char *next_prefix);
static int filprintf (Filament *fil, const char *format, ...);
static bytecode_info *get_bytecode (const char *name);

int curr_bit_offset = 0, synthetic = 256;
bytecode_info *bytecode_root, *curr_bytecode;
field_info *curr_field;
var_info *var_root;
opcode *first = NULL, **p_next = &first;
Filament *curr_fil;
char *begin_code, *end_code;

%}

%debug
%defines
%expect 3

%union {
  struct field_info *field;
  const char *ctext;
  char *text;
  int num;
}

%type<field> field_list opt_field_list
%type<text> code
%type<text> c_code
%type<num> bitfield
%type<num> bitfields
%type<num> opt_size

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
%token<ctext> EXPR "expression"

%%

decls:
	decls decl
	| decl
	;

decl:
	ID opt_field_list ';'
	  { define_bytecode ($1, $2); }
	| DECL_BEGIN '{' c_code '}'
	  { begin_code = $3; }
	| DECL_END '{' c_code '}'
	  { end_code = $3; }
	| NUMBER '{' code '}'
	  { define_decl ($1, $1, $3); }
	| NUMBER DECL_DOTS NUMBER '{' code '}'
	  { define_decl ($1, $3, $5); }
	;

opt_field_list:
	'(' field_list ')'
	  { $$ = $2; }
	| /* empty */
	  { $$ = NULL; }
	;

field_list:
	field_list ',' ID
	  { struct field_info *f = malloc (sizeof (struct field_info));
	    define_var ($3);
	    f->name = $3;
	    f->next = NULL;
	    *($1->pnext) = f;
	    $$ = $1;
	    $$->pnext = &(f->next);
	  }
	| ID
	  { struct field_info *f = malloc (sizeof (struct field_info));
	    define_var ($1);
	    f->name = $1;
	    f->next = NULL;
	    $$ = f;
	    $$->pnext = &(f->next);
	  }
	;

c_code:
	  { curr_fil = filnew (NULL, 0); }
	c_code_body
	  { $$ = fildelete (curr_fil); }
	;

c_code_expr_body:
	c_code_expr_body c_code_expr_item
	| /* empty */;

c_code_expr_item:
	'='
	  { filccat (curr_fil, '='); }
	| '('
	  { filccat (curr_fil, '('); }
	  c_code_body ')'
	  { filccat (curr_fil, ')'); }
	| ID
	  { filcat (curr_fil, $1); free ($1); }
	| NUMBER
	  { filprintf (curr_fil, "%d", $1); }
	| EXPR
	  { filcat (curr_fil, $1); }
	;

c_code_body:
	c_code_body c_code_item
	| /* empty */;

c_code_item:
	c_code_expr_item
	| ','
	  { filccat (curr_fil, ','); }
	;

code:
	  { curr_fil = filnew (NULL, 0); }
	code_body
	  { filcat (curr_fil, "  goto MATCH_BYTECODES_END_##name_; ");
	    $$ = fildelete (curr_fil); }
	;

code_body:
	code_body code_item
	| /* empty */;

code_item:
	c_code_item
	| DECL_BREAK
	  { filcat (curr_fil, "goto MATCH_BYTECODES_END_##name_;"); }
	| DECL_CONTINUE
	  { filcat (curr_fil, "goto MATCH_BYTECODES_START_##name_;"); }
	| DECL_DISPATCH ID
	  { filprintf (curr_fil, "do { \\\n"
				 "\topcode_ = %d; \\\n", synthetic);
	    curr_bytecode = get_bytecode ($2);
	    if (!curr_bytecode)
	      {
		curr_field = NULL;
		yyerror ("bad bytecode name");
	      }
	    else
	      curr_field = curr_bytecode->fields;
	  }
	  opt_dispatch_args
	  { if (curr_field)
	      yyerror ("expected field in dispatch");
	    filprintf (curr_fil, "\tgoto MATCH_BYTECODES_##name_##_%s; \\\n", $2);
	    filprintf (curr_fil, "    case %d: \\\n"
				 "\t; \\\n"
				 "      } while (0)", synthetic++);
	    free ($2);
	  }
	| DECL_EXTRACT bitfields
	  { if ($2 % 8)
	      yyerror ("must extract an integer number of bytes");
	    else
	      filprintf (curr_fil, "bp_ = (IP += %d)", $2 / 8);
	  }
	;

opt_dispatch_args:
	'(' dispatch_args ')'
	| /* empty */
	;

dispatch_args:
	dispatch_args ',' dispatch_arg
	| dispatch_arg
	;

dispatch_arg:
	{ if (curr_field)
	    {
	      filprintf (curr_fil, "\t%s = ", curr_field->name);
	      curr_field = curr_field->next;
	    }
	  else
	    yyerror ("extra field in dispatch");
	}
	c_code_expr_body
	{ filprintf (curr_fil, "; \\\n"); }
	;

opt_size:
	'(' NUMBER ')'		{ $$ = $2; }
	| /* empty */		{ $$ = 8; }
	;

bitfields:
	bitfields ',' bitfield	{ $$ = $1 + $3; }
	| bitfield		{ $$ = $1; }
	;

bitfield:
	ID opt_size
	  { define_field ($1, $2); $$ = $2; }
	;

%%

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

/* Advance the pointer by BITS bits and return the code to 
   extract those bits.  */
char *
extraction_code (int bits)
{
  char *s;
  int n_bit = curr_bit_offset % 8;
  int n_byte = curr_bit_offset / 8;

  if (n_bit + bits <= 8)
    {
      int rshift = 8 - (n_bit + bits);
      int mask = (1 << bits) - 1;
      curr_bit_offset += bits;

      if (n_bit && rshift)
        return my_asprintf ("(IP[%d] >> %d) & %d", n_byte, rshift, mask);

      if (rshift)
        return my_asprintf ("IP[%d] >> %d", n_byte, rshift);

      if (n_bit)
        return my_asprintf ("IP[%d] & %d", n_byte, mask);
      else
        return my_asprintf ("IP[%d]", n_byte);
    }

  /* Else, multi-byte extraction.  */
  if (curr_bit_offset % 8)
    /* Complete the current byte...  */
    {
      int n = 8 - (curr_bit_offset % 8);
      s = extraction_code (n);
      bits -= n;
      n_bit = 0;
      n_byte++;
    }
  else
    /* ... or do a new one.  */
    {
      s = my_asprintf ("IP[%d]", n_byte++);
      curr_bit_offset += 8;
      bits -= 8;
    }

  /* Add entire bytes as long as possible.  */
  while (bits >= 8)
    {
      char *new_s = my_asprintf ("((%s) << 8) | IP[%d]", s, n_byte++);
      free (s);
      s = new_s;
      curr_bit_offset += 8;
      bits -= 8;
    }

  /* And finally any spare bits.  */
  if (bits)
    {
      char *new_s = my_asprintf ("((%s) << 8) | %s", s, extraction_code (bits));
      free (s);
      s = new_s;
    }

  return (s);
}

/* Define a bytecode that is used as an operand to dispatch.
   We use an AVL tree to store them so that we can do fast
   searches, and we can detect duplicates.  */
bytecode_info *
get_bytecode (const char *name)
{
  avl_node_t **p = (avl_node_t **) &bytecode_root;
  bytecode_info *bytecode = NULL;

  while (*p)
    {
      int cmp;
      bytecode = (bytecode_info *) *p;

      cmp = strcmp(name, bytecode->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
	return bytecode;
    }

  return NULL;
}

/* Define a bytecode that is used as an operand to dispatch.
   We use an AVL tree to store them so that we can do fast
   searches, and we can detect duplicates.  */
void
define_bytecode (const char *name, field_info *fields)
{
  avl_node_t **p = (avl_node_t **) &bytecode_root;
  bytecode_info *node;
  bytecode_info *bytecode = NULL;

  while (*p)
    {
      int cmp;
      bytecode = (bytecode_info *) *p;

      cmp = strcmp(name, bytecode->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
	{
	  yyerror ("duplicate bytecode name");
          return;
	}
    }

  node = (bytecode_info *) calloc(1, sizeof(struct bytecode_info));
  node->avl.avl_parent = (avl_node_t *) bytecode;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->name = name;
  node->fields = fields;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &bytecode_root);
}

/* Define a variable that is used to pass the operands of the
   bytecode.  We use an AVL tree to store them so that we can
   output them nicely sorted, and we can eliminate duplicates.  */
void
define_var (const char *name)
{
  avl_node_t **p = (avl_node_t **) &var_root;
  var_info *node;
  var_info *var = NULL;

  while (*p)
    {
      int cmp;
      var = (var_info *) *p;

      cmp = strcmp(name, var->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
        return;
    }

  node = (var_info *) calloc(1, sizeof(struct var_info));
  node->avl.avl_parent = (avl_node_t *) var;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->name = name;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &var_root);
}

/* Define an operation that is BITS bits wide and whose opcodes start
   at OPCODE) and does the ID operation.  */
void
define_decl (int first, int last, char *code)
{
  struct opcode *curr = calloc (1, sizeof (struct opcode));
  curr->first = first;
  curr->last = last;
  curr->code = code;

  *p_next = curr;
  p_next = &(curr->next);

  if ((unsigned) (first | last) > 255)
    yyerror ("Invalid opcode specification");

  curr_bit_offset = 0;
}

/* Define a BITS bits-wide operand named NAME of the current bytecode.  */
void
define_field (const char *name, int bits)
{
  char *s = extraction_code (bits);
  define_var (name);
  filprintf (curr_fil, "%s = %s; \\\n      ", name, s);
  free (s);
}

/* Emit the declarations for the variable names.  NODE is the root of
   the tree, PREFIX ("int" or ",") is emitted before the first variable,
   SUFFIX after every variable, NEXT_PREFIX before every variable but
   the first.  */
void
emit_var_names (var_info *node, const char *prefix, const char *suffix, const char *next_prefix)
{
  if (node->avl.avl_left)
    {
      emit_var_names ((var_info *) node->avl.avl_left, prefix, suffix, next_prefix);
      prefix = next_prefix;
    }

  printf ("%s%s%s", prefix, node->name, suffix);

  if (node->avl.avl_right)
    emit_var_names ((var_info *) node->avl.avl_right, next_prefix, suffix, next_prefix);
}

/* Emit the decision tree for the bytecodes.  */
void
emit_opcodes ()
{
  int n;
  struct opcode *op;

  define_var ("opcode_");
  emit_var_names (var_root, "  int ", "", ", ");
  printf ("; \\\n");

  printf ("  unsigned char *IP = bp_; \\\n");
  printf ("  unsigned char ATTRIBUTE_UNUSED *IP0 = bp_; \\\n");

  emit_var_names (var_root, "  ", " ", "= ");
  printf ("= 0; \\\n");
  if (begin_code)
    printf ("  { \\\n"
	    "  %s \\\n"
	    "  } \\\n", begin_code);

  printf ("MATCH_BYTECODES_START_##name_: \\\n"
  	  "  opcode_ = *IP; \\\n"
  	  "MATCH_BYTECODES_SWITCH_##name_: \\\n"
          "  switch (opcode_) { \\\n");

  for (op = first; op; op = op->next)
    {
      int first_val = op->first;
      int last_val = op->last;

      for (n = 0; first_val <= last_val; first_val++, n++)
	{
	  if (!(n & 3))
	    printf ("%s    ", n ? "\\\n" : "");

	  printf ("case %d: ", first_val);
	}

      printf ("\\\n"
              "    %s\\\n", op->code);
    }

  printf ("  } \\\n"
          "  MATCH_BYTECODES_DISPATCH(MATCH_BYTECODES_##name_) \\\n"
          "MATCH_BYTECODES_END_##name_: \\\n"
	  "%s", end_code ? end_code : "  ;");
}
