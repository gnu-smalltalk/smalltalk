/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genvm tool
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


%{
#include "avltrees.h"
#include "genvm.h"
#include "genvm-parse.h"

#define YYERROR_VERBOSE 1

typedef struct id_list {
  struct id_list *next;
  struct id_list **pnext;
  char id[1];
} id_list;

typedef struct operation_info {
  avl_node_t avl;
  const char *name;
  struct id_list *args;
  struct id_list *in, *out, *read;
  int n_in, n_out, n_read;
  int needs_prepare_stack;
  int needs_branch_label;
  int instantiations;
  const char *code;
} operation_info;

typedef struct operation_list {
  struct operation_list *next;
  struct operation_list **pnext;
  operation_info *op;
  id_list *args;
} operation_list;

typedef struct table_info {
  char *name;
  char *entry[256];
  id_list *pool;
} table_info;

#define YYPRINT(fp, tok, val) yyprint (fp, tok, &val)

static int filprintf (Filament *fil, const char *format, ...);
static void yyprint (FILE *fp, int tok, const YYSTYPE *val);
static void yyerror (const char *s);
static operation_info *define_operation (const char *name);
static void set_curr_op_stack (id_list *in, id_list *out);
static operation_list *append_to_operation_list (operation_list *list, const char *name, id_list *args);
static id_list *append_to_id_list (id_list *list, const char *id);
static int emit_id_list (const id_list *list, const char *sep, const char *before, const char *after);
static void set_table (table_info *t, int from, int to, char *value);
static void free_id_list (id_list *list);
static void emit_var_declarations (const char *base, const char *type, int i, int n);
static void emit_var_defines (id_list *list, int sp);
static void emit_operation_invocation (operation_info *op, id_list *args, int sp, int deepest_write);
static void emit_operation_list (operation_list *list);
static void emit_stack_update (int sp, int deepest_write, const char *before, const char *after);
static void free_operation_list (operation_list *list);
static table_info *define_table (char *name);
static void emit_table (table_info *t);
static void free_table (table_info *t);

int counter = 0;
int c_code_on_brace = 0;
int c_args_on_paren = 0;
int errors = 0;
Filament *curr_fil, *out_fil;
operation_info *curr_op, *op_root;
table_info *curr_table;
int from, to;

%}

%debug
%defines

%union {
  struct operation_list *oplist;
  struct operation_info *op;
  struct table_info *tab;
  struct id_list *id;
  const char *ctext;
  char *text;
  int num;
}

/* single definite characters */     
%token <text> ID "identifier"
%token <text> EXPR "C expression"
%token <num> NUMBER "number"
%token VM_OPERATION "operation"
%token VM_TABLE "table"
%token VM_BYTECODE "bytecode"
%token VM_DOTS ".."
%token VM_MINUSMINUS "--"

%type <id> ids c_args opt_c_args
%type <text> opt_id c_arg bytecode
%type <tab> table
%type <oplist> operation_list
%type <op> operation

%%

script: script table
	| script operation
	| script bytecode
	  { free ($2); }
	| /* empty */
	;

table: VM_TABLE ID
	  { curr_table = define_table ($2); }
	'{' table_items '}'
	  { emit_table (curr_table); free_table (curr_table); }
	;

table_items: table_items.label
	| table_items.descr
	;

table_items.label: table_items.label ',' label
	| table_items.descr label
	| label
	;

table_items.descr: table_items.label ',' description
	| table_items.descr description
	| description
	;

subscripts: NUMBER '='
	  { from = to = $1;
	    if (from < 0 || from > 255)
	      {
		yyerror ("invalid table index");
		from = 0, to = -1;
	      }
	   }
	| NUMBER VM_DOTS NUMBER '='
	  { from = $1, to = $3;
	    if (from < 0 || to < 0 || from > 255 || to > 255)
	      {
		yyerror ("invalid table index");
		from = 0, to = -1;
	      }
	   }
	;

label: subscripts ID
	  { set_table (curr_table, from, to, $2);
	    free ($2);
	  }
	;

description: subscripts bytecode
	  { set_table (curr_table, from, to, $2);
	    free ($2);
	  }

bytecode: VM_BYTECODE opt_id
	  { filprintf (out_fil, "%s:\n", $2); }
	  '{' operation_list '}'
	  { emit_operation_list ($5);
	    free_operation_list ($5);
	    filprintf (out_fil, "  NEXT_BC;\n");
	    $$ = $2;
	  }
	;

operation_list: operation_list ID { c_args_on_paren = 1; } '(' opt_c_args ')' ';'
	  { $$ = append_to_operation_list ($1, $2, $5); }
	| /* empty */
	  { $$ = NULL; }
	;
	
opt_c_args: c_args
          { $$ = $1; }
	| /* empty */
          { $$ = NULL; }
	;

c_args: 
	c_args ',' c_arg
        { $$ = append_to_id_list ($1, $3); free ($3); }
	| c_arg
        { $$ = append_to_id_list (NULL, $1); free ($1); }
	;

c_arg:
          { curr_fil = filnew (NULL, 0); }
        c_arg_body
          { $$ = fildelete (curr_fil); }
        ;

c_arg_body: c_arg_body EXPR
          { filcat (curr_fil, $2); }
	| EXPR
          { filcat (curr_fil, $1); }
	| c_arg_body '(' 
          { filcat (curr_fil, "("); }
	  c_arg_body ')'
          { filcat (curr_fil, ")"); }
	;

opt_id: ID
	  { $$ = $1; }
	| /* empty */
	  { asprintf (&$$, "label%d", ++counter); }
	;

operation: 
	VM_OPERATION ID
	  { curr_op = define_operation ($2); c_code_on_brace = true; }
	ids stack_balance 
          { curr_fil = filnew (NULL, 0);
	    filprintf (curr_fil, "#line %d \"vm.def\"\n      ", yylineno + 1);
	  }
	'{' c_code '}'
	  { filprintf (curr_fil, "\n#line __oline__ \"vm.inl\"");
	    if (curr_op)
	      {
	        curr_op->args = $4;
	        curr_op->code = fildelete (curr_fil);
	        curr_op->needs_prepare_stack = strstr(curr_op->code,
					              "PREPARE_STACK") != NULL;
	        curr_op->needs_branch_label = strstr(curr_op->code,
					             "BRANCH_LABEL") != NULL;
	      }
	    $$ = curr_op;
	  }
	;

ids: ids ID
	{ $$ = append_to_id_list ($1, $2); free ($2); }
	| /* empty */
	{ $$ = NULL; }
	;

stack_balance: '(' ids VM_MINUSMINUS ids ')'
	{ set_curr_op_stack ($2, $4); }

c_code: c_code EXPR
	  { filcat (curr_fil, $2); }
	| /* empty */
	;

%%

void yyprint (FILE *fp, int tok, const YYSTYPE *val)
{
  switch (tok)
    {
      case NUMBER:
        fprintf (fp, "%d", (val)->num);
        break;
      case ID:
      case EXPR:
        fprintf (fp, "%s", (val)->text);
        break;
    }
}

void
yyerror (const char *s)
{
  errors = 1;
  fprintf (stderr, "vm.def:%d: %s\n", yylineno, s);
}

/* Define an operation that is used into a bytecode declaration.
   We use an AVL tree to store them so that we can do fast
   searches, and we can detect duplicates.  */
operation_info *
define_operation (const char *name)
{
  avl_node_t **p = (avl_node_t **) &op_root;
  operation_info *node;
  operation_info *operation = NULL;

  while (*p)
    {
      int cmp;
      operation = (operation_info *) *p;

      cmp = strcmp(name, operation->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
        {
          yyerror ("duplicate operation");
          return NULL;
        }
    }

  node = (operation_info *) calloc(1, sizeof(operation_info));
  node->avl.avl_parent = (avl_node_t *) operation;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->name = name;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &op_root);
  return node;
}

operation_info *
get_operation (const char *name)
{
  avl_node_t **p = (avl_node_t **) &op_root;
  operation_info *operation = NULL;

  while (*p)
    {
      int cmp;
      operation = (operation_info *) *p;

      cmp = strcmp(name, operation->name);
      if (cmp < 0)
        p = &(*p)->avl_left;
      else if (cmp > 0)
        p = &(*p)->avl_right;
      else
        return operation;
    }

  return NULL;
}

operation_list *
append_to_operation_list (operation_list *list, const char *name, id_list *args)
{
  operation_list *node, *result;
  operation_info *op = get_operation (name);

  if (!op)
    {
      yyerror ("undefined operation");
      return list;
    }

  node = calloc (1, sizeof (operation_list));
  if (!list)
    result = node;
  else
    {
      result = list;
      *(result->pnext) = node;
    }

  node->op = op;
  node->args = args;
  result->pnext = &(node->next);
  return result;
}

id_list *
append_to_id_list (id_list *list, const char *name)
{
  int len = strlen (name);
  id_list *node = calloc (1, sizeof (id_list) + len);
  id_list *result;
  memcpy (node->id, name, len);

  if (!list)
    result = node;
  else
    {
      result = list;
      *(result->pnext) = node;
    }

  result->pnext = &(node->next);
  return result;
}

int
emit_id_list (const id_list *list, const char *sep, const char *before, const char *after)
{
  int n = 0;
  if (!list)
    return 0;

  filcat (out_fil, before);
  while (list)
    {
      filcat (out_fil, list->id);
      list = list->next;
      filcat (out_fil, list ? sep : after);
      n++;
    }

  return n;
}

void
free_id_list (id_list *list)
{
  id_list *next;
  while (list)
    {
      next = list->next;
      free (list);
      list = next;
    }
}

void
set_curr_op_stack (id_list *in, id_list *out)
{
  id_list *read = in;
  id_list *list;
  id_list *last_read = NULL;
  if (!curr_op)
    return;

  /* Find the names that are a common prefix for the input and output
     stack, and move them to the READ list.  */
  while (in && out && !strcmp (in->id, out->id))
    {
      id_list *next;
      next = out->next;
      free (out);
      out = next;

      /* The in nodes are still referenced through READ. */
      last_read = in;
      in = in->next;
    }

  if (last_read)
    {
      if (in)
        in->pnext = read->pnext;
      last_read->next = NULL;
      read->pnext = &(last_read->next);
    }
  else
    /* The slots are all read and written, none is just read.  */
    read = NULL;

  curr_op->in = in;
  curr_op->out = out;
  curr_op->read = read;

  /* Compute and save the count, we'll use it to combine the
     stack effects.  */
  for (curr_op->n_in = 0, list = curr_op->in; list; list = list->next, curr_op->n_in++);
  for (curr_op->n_out = 0, list = curr_op->out; list; list = list->next, curr_op->n_out++);
  for (curr_op->n_read = 0, list = curr_op->read; list; list = list->next, curr_op->n_read++);
}

void
free_operation_list (operation_list *list)
{
  operation_list *next;
  while (list)
    {
      next = list->next;
      free_id_list (list->args);
      free (list);
      list = next;
    }
}

void
emit_var_declarations (const char *base, const char *type, int first, int n)
{
  int i;
  if (!n)
    return;

  for (i = first; n--; i++)
    filprintf (out_fil, "%s %s%d", i == first ? type : ",", base, i);

  filprintf (out_fil, ";\n");
}

void
emit_var_defines (id_list *list, int sp)
{
  for (; list; list = list->next, sp++)
    filprintf (out_fil, "#define %s %s%d\n", list->id,
	       (sp <= 0 ? "_stack" : "_extra"), (sp < 0 ? -sp : sp));
}

void
emit_operation_list (operation_list *oplist)
{
  operation_list *list;
  int deepest_read = 0, deepest_write = 0, sp,
      max_height = 0, deepest_write_so_far = 0, i;

  if (!oplist)
    return;

  filprintf (out_fil, "  {\n");

  /* Compute the overall effect on the stack of the superoperator.
     The number of elements that are read is usually op->n_read + op->n_in,
     but in the presence of many operations we need to adjust this for
     the balance left by previous operations; the same also holds for
     the number of written elements, which is usually op->in.

     We also track the maximum height of the stack which is the number
     of _EXTRA variables that we need.  */
  for (sp = 0, list = oplist; list; list = list->next)
    {
      operation_info *op = list->op;
      int balance = op->n_out - op->n_in;
      deepest_read = MAX (deepest_read, op->n_read + op->n_in - sp);
      deepest_write = MAX (deepest_write, op->n_in - sp);
      sp += balance;
      max_height = MAX (max_height, sp);
    }

  /* Declare the variables.  */
  emit_var_declarations ("_stack", "    OOP", 0, deepest_read);
  emit_var_declarations ("_extra", "    OOP", 1, max_height);

  /* Read the input items from the stack.  */
  for (i = deepest_read; --i >= 0; )
    filprintf (out_fil, "    _stack%d = STACK_AT (%d);\n", i, i);

  /* We keep track of the stack effect here too: we pass the current balance
     to emit_operation_invocation so that it can assign the correct
     _STACK/_EXTRA variables to the operands of OP, and we pass the
     number of dirty _STACK variables (tracked by DEEPEST_WRITE_SO_FAR)
     so that it can emit the PREPARE_STACK macro if necessary.  */
  for (sp = 0, list = oplist; list; list = list->next)
    {
      operation_info *op = list->op;
      int balance = op->n_out - op->n_in;
      emit_operation_invocation (op, list->args, sp, deepest_write_so_far);
      deepest_write_so_far = MAX (deepest_write_so_far, op->n_in - sp);
      sp += balance;
    }

  /* Write back to the stack the items that were overwritten, and
     emit pushes/pops if the height of the stack has changed.  */
  emit_stack_update (sp, deepest_write, "    ", ";");

  filprintf (out_fil, "  }\n");
}

void
emit_operation_invocation (operation_info *op, struct id_list *args, int sp, int deepest_write)
{
  id_list *list, *actual;

  filprintf (out_fil, "    /* %s (", op->name);
  emit_id_list (op->read, " ", " ", " |");
  emit_id_list (op->in, " ", " ", "");
  filprintf (out_fil, " --");
  emit_id_list (op->read, " ", " ", " |");
  emit_id_list (op->out, " ", " ", "");
  filprintf (out_fil, " ) */\n");

  filprintf (out_fil, "    do\n");
  filprintf (out_fil, "      {\n");

  /* Evaluate the arguments.  */
  for (list = op->args, actual = args; list && actual;
       list = list->next, actual = actual->next)
    filprintf (out_fil, "\tint %s = %s;\n", list->id, actual->id);

  if (list)
    yyerror ("too few parameters");
  if (actual)
    yyerror ("too many parameters");

  if (op->needs_prepare_stack)
    {
      filprintf (out_fil, "#define PREPARE_STACK() do { \\\n");
      emit_stack_update (sp, deepest_write, "    ", "; \\");
      filprintf (out_fil, "  } while (0)\n");
    }

  if (op->needs_branch_label)
    filprintf (out_fil,
	       "#define BRANCH_LABEL(local_label) %s_%d_##local_label\n",
	       op->name, op->instantiations++);

  /* Associate the temporary variables to the stack positions.  */
  emit_var_defines (op->read, sp - op->n_read - op->n_in + 1);
  emit_var_defines (op->in, sp - op->n_in + 1);
  emit_var_defines (op->out, sp - op->n_in + 1);

  filprintf (out_fil, "%s\n", op->code);

  /* Leave things clean.  */
  if (op->needs_branch_label)
    filprintf (out_fil, "#undef BRANCH_LABEL\n\n");

  if (op->needs_prepare_stack)
    filprintf (out_fil, "#undef PREPARE_STACK\n");

  emit_id_list (op->read, "\n#undef ", "#undef ", "\n");
  emit_id_list (op->in, "\n#undef ", "#undef ", "\n");
  emit_id_list (op->out, "\n#undef ", "#undef ", "\n");

  filprintf (out_fil, "      }\n");
  filprintf (out_fil, "    while (0);\n");
}

void
emit_stack_update (int sp, int deepest_write, const char *before, const char *after)
{
  int i;

  for (i = deepest_write; --i >= MAX(0, -sp); )
    filprintf (out_fil, "%sSTACK_AT (%d) = _stack%d%s\n", before, i, i, after);

  /* Either pop the input items in excess, or push the output ones.  */
  if (sp < 0)
    filprintf (out_fil, "%sPOP_N_OOPS (%d)%s\n", before, -sp, after);
  else
    for (i = 1; i <= sp; i++)
      filprintf (out_fil, "%sPUSH_OOP (_extra%d)%s\n", before, i, after);
}
 
void
emit_table (table_info *t)
{
  int i;
  printf ("  static void *%s[256] = {\n", t->name);
  for (i = 0; i < 256; i += 4)
    printf ("    %s%s, %s%s, %s%s, %s%s%c  /* %3d */\n",
	    t->entry[i] ? "&&" : "",
	    t->entry[i] ? t->entry[i] : "NULL",
	    t->entry[i+1] ? "&&" : "",
	    t->entry[i+1] ? t->entry[i+1] : "NULL",
	    t->entry[i+2] ? "&&" : "",
	    t->entry[i+2] ? t->entry[i+2] : "NULL",
	    t->entry[i+3] ? "&&" : "",
	    t->entry[i+3] ? t->entry[i+3] : "NULL",
	    i + 4 == 256 ? ' ' : ',', i);

  printf ("  };\n\n");
}

table_info *
define_table (char *name)
{
  table_info *t = (table_info *) calloc(1, sizeof(table_info));
  t->name = name;

  return t;  
}

void
set_table (table_info *t, int from, int to, char *value)
{
  int i;
  id_list **p_last = t->pool ? t->pool->pnext : &t->pool;
  id_list *last;
  t->pool = append_to_id_list (t->pool, value);
  last = *p_last;

  for (i = from; i <= to; i++)
    t->entry[i] = last->id;
}

void
free_table (table_info *t)
{
  free_id_list (t->pool);
  free (t->name);
  free (t);
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

int
main ()
{
  char *code;
  errors = 0;

  printf ("/* Automatically generated by genvm, do not edit!  */\n");

  out_fil = filnew (NULL, 0);
  if (yyparse () || errors)
    exit (1);

  printf ("  goto jump_around;\n");
  code = fildelete (out_fil);
  fputs (code, stdout);
  printf ("jump_around:\n  ;\n");

  exit (0);
}
