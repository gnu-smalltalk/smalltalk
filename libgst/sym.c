/******************************** -*- C -*- ****************************
*
 *	Symbol Table module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,
 * 2005,2006,2007,2008,2009 Free Software Foundation, Inc.
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
#include "pointer-set.h"

typedef struct
{
  OBJ_HEADER;
  OOP nextLink;
  OOP symbol;
}
 *sym_link;

typedef struct symbol_list *symbol_list;

struct symbol_list
{
  OOP symbol;
  mst_Boolean readOnly;
  int index;
  symbol_list prevSymbol;
};

/* Represents all the identifiers, both arguments and temporaries,
   which are declared in a given scope.  Nested scopes result in
   nested instances of the scope struct, with the current scope always
   being the innermost at any point during the compilation.  */
struct scope
{
  scope prevScope;
  unsigned int numArguments;
  unsigned int numTemporaries;
  symbol_list symbols;
};

/* Represents all the pools (namespaces) which are declared in the
   current scope.  This information is relatively complex to compute,
   so it's kept cached.  */
struct pool_list
{
  OOP poolOOP;
  pool_list next;
};


typedef struct symbol_info
{
  OOP *symbolVar;
  const char *value;
}
symbol_info;


/* These variables hold various symbols needed mostly by the compiler
   and the C interface.  It is important that these symbols are *not*
   included in the builtin selectors list (builtins.gperf) because
   of the way we create symbols in _gst_init_symbols_pass1.  */

OOP _gst_and_symbol = NULL;
OOP _gst_as_scaled_decimal_radix_scale_symbol = NULL;
OOP _gst_bad_return_error_symbol = NULL;
OOP _gst_boolean_symbol = NULL;
OOP _gst_byte_array_out_symbol = NULL;
OOP _gst_byte_array_symbol = NULL;
OOP _gst_c_object_ptr_symbol = NULL;
OOP _gst_c_object_symbol = NULL;
OOP _gst_category_symbol = NULL;
OOP _gst_char_symbol = NULL;
OOP _gst_does_not_understand_symbol = NULL;
OOP _gst_double_symbol = NULL;
OOP _gst_false_symbol = NULL;
OOP _gst_float_symbol = NULL;
OOP _gst_if_false_if_true_symbol = NULL;
OOP _gst_if_false_symbol = NULL;
OOP _gst_if_true_if_false_symbol = NULL;
OOP _gst_if_true_symbol = NULL;
OOP _gst_int_symbol = NULL;
OOP _gst_long_double_symbol = NULL;
OOP _gst_long_symbol = NULL;
OOP _gst_must_be_boolean_symbol = NULL;
OOP _gst_nil_symbol = NULL;
OOP _gst_or_symbol = NULL;
OOP _gst_permission_symbol = NULL;
OOP _gst_primitive_symbol = NULL;
OOP _gst_repeat_symbol = NULL;
OOP _gst_self_smalltalk_symbol = NULL;
OOP _gst_self_symbol = NULL;
OOP _gst_short_symbol = NULL;
OOP _gst_smalltalk_symbol = NULL;
OOP _gst_smalltalk_namespace_symbol = NULL;
OOP _gst_start_execution_symbol = NULL;
OOP _gst_string_out_symbol = NULL;
OOP _gst_string_symbol = NULL;
OOP _gst_super_symbol = NULL;
OOP _gst_symbol_symbol = NULL;
OOP _gst_symbol_out_symbol = NULL;
OOP _gst_symbol_table = NULL;
OOP _gst_terminate_symbol = NULL;
OOP _gst_times_repeat_symbol = NULL;
OOP _gst_to_by_do_symbol = NULL;
OOP _gst_to_do_symbol = NULL;
OOP _gst_true_symbol = NULL;
OOP _gst_uchar_symbol = NULL;
OOP _gst_uint_symbol = NULL;
OOP _gst_ulong_symbol = NULL;
OOP _gst_ushort_symbol = NULL;
OOP _gst_undeclared_symbol = NULL;
OOP _gst_unknown_symbol = NULL;
OOP _gst_value_with_rec_with_args_symbol = NULL;
OOP _gst_variadic_smalltalk_symbol = NULL;
OOP _gst_variadic_symbol = NULL;
OOP _gst_vm_primitives_symbol = NULL;
OOP _gst_void_symbol = NULL;
OOP _gst_wchar_symbol = NULL;
OOP _gst_wstring_symbol = NULL;
OOP _gst_wstring_out_symbol = NULL;
OOP _gst_while_false_colon_symbol = NULL;
OOP _gst_while_false_symbol = NULL;
OOP _gst_while_true_colon_symbol = NULL;
OOP _gst_while_true_symbol = NULL;
OOP _gst_current_namespace = NULL;

OOP temporaries_dictionary = NULL;

/* The list of selectors for the send immediate bytecode.  */
struct builtin_selector _gst_builtin_selectors[256] = {};

/* Answer whether OOP is a Smalltalk String LEN characters long and
   these characters match the first LEN characters of STR (which must
   not have embedded NULs).  */
static mst_Boolean is_same_string (const char *str,
				   OOP oop,
				   int len);

/* Allocate memory for a symbol of length LEN and whose contents are STR.
   This function does not fill in the object's class because it is called
   upon image loading, when the classes have not been initialized yet.  */
static OOP alloc_symbol_oop (const char *str, int len);

/* Link SYMBOLOOP into the symbol table (using the given hash table index),
   and fill the class slot of the symbol.  */
static OOP alloc_symlink (OOP symbolOOP, uintptr_t index);

/* Answer whether C is considered a white space character in Smalltalk
   programs.  */
static mst_Boolean is_white_space (char c);

/* Free the list of symbols declared in the given SCOPE.  */
static void free_scope_symbols (scope scope);

/* Scans a variable name (letters and digits, initial letter), and
   return a symbol for it. PP is a pointer to a pointer to the start
   of the string to be scanned, which may be pointing at either
   whitespace or start of variable.  At end, it points to the first
   character after the initial whitespace, if any.  ENDP instead is
   initialized by the function to point to first character after the
   parsed variable name, which may be NUL.  */
static void parse_variable_name (const char ** pp,
				 const char ** endp);

/* This fills ENT's fields with the contents of its parameters.  */
static void fill_symbol_entry (symbol_entry * ent,
			       scope_type scope,
			       mst_Boolean readOnly,
			       OOP symbol,
			       int index,
			       unsigned int scopeDistance);

/* Scans a variable name (letters and digits, initial letter), and
   return a symbol for it. PP is a pointer to a pointer to the start
   of the string to be scanned.  May be pointing at either whitespace
   or start of variable.  At end, points to first character after the
   parsed variable name, which may be NUL.  The output is a Smalltalk
   Symbol, _gst_nil_oop if no variable name is found.  */
static OOP scan_name (const char ** pp);

/* This creates a Symbol containing LEN bytes starting at STR and puts
   it in the symbol list, or returns an existing one if it is
   found.  */
static OOP intern_counted_string (const char *str,
				  int len);

/* This is a hack.  It is the same as _gst_intern_string except that,
   if the given symbol is pointed to by PTESTOOP, we increment
   PTESTOOP and return the old value.  This works and speeds up image
   loading, because we are careful to create the same symbols in
   _gst_init_symbols_passN and _gst_restore_symbols.  */
static inline OOP
intern_string_fast (const char *str, OOP *pTestOOP);

/* This looks for SYMBOL among the instance variables that the current
   class declares, and returns the index of the variable if one is
   found.  */
static int instance_variable_index (OOP symbol);

/* This checks if the INDEX-th instance variable among those that the
   current class declares is read-only.  Read-only index variables are
   those that are declared by a trusted super-class of an untrusted
   subclass.  */
static mst_Boolean is_instance_variable_read_only (int index);

/* This looks for SYMBOL among the arguments and temporary variables
   that the current scope sees, and returns the entry in the symbol
   list for the variable if it is found.  */
static symbol_list find_local_var (scope scope,
				   OOP symbol);

/* This looks for SYMBOL among the global variables that the current
   scope sees, including superspaces if any, and returns the entry in
   the symbol list for the variable if it is found.  */
static OOP find_class_variable (OOP varName);

/* This is an array of symbols which the virtual machine knows about,
   and is used to restore the global variables upon image load.  */
static const symbol_info sym_info[] = {
  {&_gst_and_symbol, "and:"},
  {&_gst_as_scaled_decimal_radix_scale_symbol, "asScaledDecimal:radix:scale:"},
  {&_gst_bad_return_error_symbol, "badReturnError"},
  {&_gst_byte_array_symbol, "byteArray"},
  {&_gst_byte_array_out_symbol, "byteArrayOut"},
  {&_gst_boolean_symbol, "boolean"},
  {&_gst_c_object_symbol, "cObject"},
  {&_gst_c_object_ptr_symbol, "cObjectPtr"},
  {&_gst_category_symbol, "category:"},
  {&_gst_char_symbol, "char"},
  {&_gst_uchar_symbol, "uChar"},
  {&_gst_does_not_understand_symbol, "doesNotUnderstand:"},
  {&_gst_float_symbol, "float"},
  {&_gst_double_symbol, "double"},
  {&_gst_false_symbol, "false"},
  {&_gst_if_false_if_true_symbol, "ifFalse:ifTrue:"},
  {&_gst_if_false_symbol, "ifFalse:"},
  {&_gst_if_true_if_false_symbol, "ifTrue:ifFalse:"},
  {&_gst_if_true_symbol, "ifTrue:"},
  {&_gst_int_symbol, "int"},
  {&_gst_uint_symbol, "uInt"},
  {&_gst_long_double_symbol, "longDouble"},
  {&_gst_long_symbol, "long"},
  {&_gst_ulong_symbol, "uLong"},
  {&_gst_must_be_boolean_symbol, "mustBeBoolean"},
  {&_gst_nil_symbol, "nil"},
  {&_gst_or_symbol, "or:"},
  {&_gst_primitive_symbol, "primitive:"},
  {&_gst_repeat_symbol, "repeat"},
  {&_gst_self_symbol, "self"},
  {&_gst_self_smalltalk_symbol, "selfSmalltalk"},
  {&_gst_short_symbol, "short"},
  {&_gst_ushort_symbol, "uShort"},
  {&_gst_smalltalk_symbol, "smalltalk"},
  {&_gst_smalltalk_namespace_symbol, "Smalltalk"},
  {&_gst_start_execution_symbol, "startExecution:"},
  {&_gst_string_out_symbol, "stringOut"},
  {&_gst_string_symbol, "string"},
  {&_gst_super_symbol, "super"},
  {&_gst_symbol_symbol, "symbol"},
  {&_gst_symbol_out_symbol, "symbolOut"},
  {&_gst_terminate_symbol, "__terminate"},
  {&_gst_times_repeat_symbol, "timesRepeat:"},
  {&_gst_to_by_do_symbol, "to:by:do:"},
  {&_gst_to_do_symbol, "to:do:"},
  {&_gst_true_symbol, "true"},
  {&_gst_undeclared_symbol, "Undeclared"},
  {&_gst_unknown_symbol, "unknown"},
  {&_gst_value_with_rec_with_args_symbol, "valueWithReceiver:withArguments:"},
  {&_gst_variadic_symbol, "variadic"},
  {&_gst_variadic_smalltalk_symbol, "variadicSmalltalk"},
  {&_gst_vm_primitives_symbol, "VMPrimitives"},
  {&_gst_void_symbol, "void"},
  {&_gst_wchar_symbol, "wchar"},
  {&_gst_wstring_symbol, "wstring"},
  {&_gst_wstring_out_symbol, "wstringOut"},
  {&_gst_while_false_colon_symbol, "whileFalse:"},
  {&_gst_while_false_symbol, "whileFalse"},
  {&_gst_while_true_colon_symbol, "whileTrue:"},
  {&_gst_while_true_symbol, "whileTrue"},
  {NULL, NULL},
};


const char *
_gst_get_scope_kind (scope_type scope)
{
  switch (scope)
    {
    case SCOPE_TEMPORARY: return "argument";
    case SCOPE_RECEIVER: return "instance variable";
    case SCOPE_GLOBAL: return "global variable";
    case SCOPE_SPECIAL: return "special variable";
    default: abort ();
    }
}

int
_gst_get_arg_count (void)
{
  return (_gst_compiler_state->cur_scope->numArguments);
}

int
_gst_get_temp_count (void)
{
  return (_gst_compiler_state->cur_scope->numTemporaries);
}

void
_gst_push_new_scope (void)
{
  scope newScope;
  newScope = (scope) xmalloc (sizeof (*newScope));
  newScope->prevScope = _gst_compiler_state->cur_scope;
  newScope->symbols = NULL;
  newScope->numArguments = 0;
  newScope->numTemporaries = 0;
  _gst_compiler_state->cur_scope = newScope;
}

void
_gst_pop_old_scope (void)
{
  scope oldScope;

  oldScope = _gst_compiler_state->cur_scope;
  _gst_compiler_state->cur_scope = oldScope->prevScope;

  free_scope_symbols (oldScope);
  xfree (oldScope);
}

void
_gst_pop_all_scopes (void)
{
  while (_gst_compiler_state->cur_scope)
    _gst_pop_old_scope ();
}

void
_gst_free_linearized_pools ()
{
  pool_list next;

  while (_gst_current_parser->linearized_pools)
    {
      next = _gst_current_parser->linearized_pools->next;
      xfree (_gst_current_parser->linearized_pools);
      _gst_current_parser->linearized_pools = next;
    }
}


int
_gst_declare_arguments (tree_node args)
{
  scope cur_scope = _gst_compiler_state->cur_scope;

  if (args->nodeType == TREE_UNARY_EXPR)
    return (0);

  else if (args->nodeType == TREE_BINARY_EXPR)
    _gst_declare_name (args->v_expr.expression->v_list.name, false, false);

  else
    {
      for (args = args->v_expr.expression; args != NULL;
	   args = args->v_list.next)
	if (_gst_declare_name (args->v_list.value->v_list.name, false, false) == -1)
	  return -1;
    }

  /* Arguments are always declared first! */
  cur_scope->numArguments = cur_scope->numTemporaries;
  cur_scope->numTemporaries = 0;
  return (cur_scope->numArguments);
}

int
_gst_declare_temporaries (tree_node temps)
{
  int n;
  for (n = 0; temps != NULL; n++, temps = temps->v_list.next)
    if (_gst_declare_name (temps->v_list.name, true, false) == -1)
      return -1;

  return (n);
}

int
_gst_declare_block_arguments (tree_node args)
{
  scope cur_scope = _gst_compiler_state->cur_scope;

  for (; args != NULL; args = args->v_list.next)
    if (_gst_declare_name (args->v_list.name, false, false) == -1)
      return -1;

  /* Arguments are always declared first! */
  cur_scope->numArguments = cur_scope->numTemporaries;
  cur_scope->numTemporaries = 0;
  return (cur_scope->numArguments);
}

void
_gst_undeclare_name (void)
{
  symbol_list oldList;
  scope cur_scope = _gst_compiler_state->cur_scope;

  oldList = cur_scope->symbols;
  cur_scope->symbols = cur_scope->symbols->prevSymbol;
  xfree (oldList);
}


int
_gst_declare_name (const char *name,
		   mst_Boolean writeable,
		   mst_Boolean allowDup)
{
  symbol_list newList;
  OOP symbol = _gst_intern_string (name);
  scope cur_scope = _gst_compiler_state->cur_scope;

  if (!allowDup && find_local_var (cur_scope, symbol) != NULL)
    return -1;

  newList = (symbol_list) xmalloc (sizeof (struct symbol_list));
  newList->symbol = symbol;
  newList->index = cur_scope->numArguments + cur_scope->numTemporaries;
  newList->readOnly = !writeable;
  newList->prevSymbol = cur_scope->symbols;

  /* Arguments are always declared first, so we can assume it is a
     temporary -- if it is not, _gst_declare_arguments and
     _gst_declare_block_arguments will fix it.  */
  cur_scope->numTemporaries++;
  cur_scope->symbols = newList;
  return (newList->index);
}


static void
free_scope_symbols (scope scope)
{
  symbol_list oldList;

  for (oldList = scope->symbols; oldList != NULL;
       oldList = scope->symbols)
    {
      scope->symbols = oldList->prevSymbol;
      xfree (oldList);
    }
}

/* Here are some notes on the design of the shared pool resolution order,
   codenamed "TwistedPools".

   The design should maintain a sense of containment within namespaces,
   while still allowing reference to all inherited environments, as is
   traditionally expected.

   The fundamental problem is that when a subclass is not in the same
   namespace as the superclass, we want to give a higher priority to
   the symbols in the namespaces imported by the subclass, than to the
   symbols in the superclass namespaces.  As such, no simple series of
   walks up the inheritance tree paired with pool-adds will give us a
   good search order.  Instead, we build a complete linearization of
   the namespaces (including the superspaces) and look up a symbol in
   each namespace locally, without looking at the superspaces.

   This is the essential variable search algorithm for TwistedPools.

   1. Given a class, starting with the method-owning class:

      a. Search the class pool.

      b. Search this class's shared pools in topological order,
         left-to-right, skipping any pools that are any of
         this class's namespace or superspaces.

      c. Search this class's namespace and each superspace in turn
         before first encounter of a namespace that contains, directly or
         indirectly, the superclass. This means that if the superclass is
         in the same namespace or a subspace, no namespaces are searched.

   2. Move to the superclass, and repeat from #1.

   Combination details
   ===================

   While the add-namespaces step above could be less eager to add namespaces,
   by allowing any superclass to stop the namespace crawl, rather than
   just the direct superclasses, it is already less eager than the shared
   pool manager. The topological sort is an obviously good choice, but
   why not allow superclasses' namespaces to provide deletions as well
   as the pool-containing class? While both alternatives have benefits,
   an eager import of all superspaces, besides those that already contain
   the pool-containing class, would most closely match what's expected.

   An argument could also be made that by adding a namespace to shared pools,
   you expect all superspaces to be included. However, consider the usual
   case of namespaces in shared pools: imports. While you would want it to
   completely load an alternate namespace hierarchy, I think you would not
   want it to inject Smalltalk early into the variable search. Consider
   this diagram:

               Smalltalk
                   |
               MyCompany
               /      \
              /        \
         MyProject     MyLibrary
            /            /    \
           /           ModA   ModB
     MyLibModule

    If you were to use ModB as a pool in a class in MyLibModule, I think
    it is most reasonable that ModB and MyLibrary be immediately imported,
    but MyCompany and Smalltalk wait until you reach that point in the
    namespace walk.  In other words, pools only add that part of themselves,
    which would not be otherwise reachable via the class environment.

    (Note that, as a side effect, adding MyCompany as a pool will have
    no effect). 

    Another argument could be made to delay further the namespace walk,
    waiting to resolve until no superclass is contained in a given namespace,
    based on the idea of exiting a namespace hierarchy while walking
    superclasses, then reentering it. Disregarding the unlikelihood of such
    an organization, it probably would be less confusing to resolve the
    hierarchy being left first, in case the interloping hierarchy introduces
    conflicting symbols of its own.

    There is no objective argument regarding the above points of
    contention, and no formal proofs, because convenient global name
    resolution is entirely a matter of feeling, because a formal
    programmer could always explicitly spell out the path to every
    variable.

    Namespaces also have imports (shared pools) of their own, thereby
    allowing users to import external namespaces for every class in a
    namespace, rather than each class.  These shared pools should also
    twist nicely.

    Here is how I think it would best work: after searching any
    namespace, combine its shared pools as classes' shared pools are
    combined, removing all elements that are any of this namespace or
    its superspaces, and search the combination from left to right.

    There is one important difference between namespace-sharedpools
    and class-sharedpools: while class sharedpools export their
    imports to subclasses, namespaces should not reexport bindings
    made available by way of shared pools.  As such, the bindings
    provided by a namespace are only available when compiling methods
    that actually exist in that namespace (including its subspaces).  */


OOP
_gst_get_class_object (OOP classOOP)
{
  if (OOP_CLASS (classOOP) == _gst_metaclass_class)
    classOOP = METACLASS_INSTANCE (classOOP);

  while (OOP_CLASS (classOOP) == _gst_behavior_class
	 || OOP_CLASS (classOOP) == _gst_class_description_class)
    classOOP = SUPERCLASS (classOOP);

  return classOOP;
}


/* Add poolOOP after the node whose next pointer is in P_END.  Return
   the new next node (actually its next pointer).  */

static pool_list *
add_pool (OOP poolOOP, pool_list *p_end)
{
  pool_list entry;
  if (IS_NIL (poolOOP))
    return p_end;

  entry = xmalloc (sizeof (struct pool_list));
  entry->poolOOP = poolOOP;
  entry->next = NULL;

  *p_end = entry;
  return &entry->next;
}


/* Make a pointer set with POOLOOP and all of its superspaces.  */

static struct pointer_set_t *
make_with_all_superspaces_set (OOP poolOOP)
{
  struct pointer_set_t *pset = pointer_set_create ();
  if (is_a_kind_of (OOP_CLASS (poolOOP), _gst_class_class))
    poolOOP = _gst_class_variable_dictionary (poolOOP);

  while (is_a_kind_of (OOP_CLASS (poolOOP), _gst_abstract_namespace_class))
    {
      gst_namespace pool;
      pointer_set_insert (pset, poolOOP);
      pool = (gst_namespace) OOP_TO_OBJ (poolOOP);
      poolOOP = pool->superspace;
    }

  /* Add the last if not nil.  */
  if (is_a_kind_of (OOP_CLASS (poolOOP), _gst_dictionary_class))
    pointer_set_insert (pset, poolOOP);
  return pset;
}

/* predeclared for add_namespace */
static pool_list *combine_local_pools
  (OOP sharedPoolsOOP, struct pointer_set_t *white, pool_list *p_end);

/* Add, after the node whose next pointer is in P_END, the namespace
   POOLOOP and all of its superspaces except those in EXCEPT.
   The new last node is returned (actually its next pointer).  */

static pool_list *
add_namespace (OOP poolOOP, struct pointer_set_t *except, pool_list *p_end)
{
  if (is_a_kind_of (OOP_CLASS (poolOOP), _gst_class_class))
    poolOOP = _gst_class_variable_dictionary (poolOOP);

  for (;;)
    {
      gst_namespace pool;
      OOP importsOOP;
      if (!is_a_kind_of (OOP_CLASS (poolOOP), _gst_dictionary_class))
        return p_end;

      if (!except || !pointer_set_contains (except, poolOOP))
        p_end = add_pool (poolOOP, p_end);

      /* Add imports and try to find a super-namespace */
      if (!is_a_kind_of (OOP_CLASS (poolOOP), _gst_abstract_namespace_class))
        return p_end;

      pool = (gst_namespace) OOP_TO_OBJ (poolOOP);
      importsOOP = pool->sharedPools;
      if (NUM_OOPS (OOP_TO_OBJ (importsOOP)))
	{
	  struct pointer_set_t *pset;
	  pset = make_with_all_superspaces_set (poolOOP);
	  p_end = combine_local_pools (importsOOP, pset, p_end);
	  pointer_set_destroy (pset);
	}

      poolOOP = pool->superspace;
    }
}


/* Add POOLOOP and all of its superspaces to the list in the right order:

   1. Start a new list.

   2. From right to left, descend into each given pool not visited.

   3. Recursively visit the superspace, then...

   4. Mark this pool as visited, and add to the beginning of #1's list.

   5. After all recursions exit, the list is appended at the end of the
      linearized list of pools.

   This function takes care of 3-4.  These two steps implement
   a topological sort on the reverse of the namespace tree; it is
   explicitly modeled after CLOS class precedence.  */

static void
visit_pool (OOP poolOOP, struct pointer_set_t *grey,
	    struct pointer_set_t *white,
	    pool_list *p_head, pool_list *p_tail)
{
  pool_list entry;

  if (is_a_kind_of (OOP_CLASS (poolOOP), _gst_class_class))
    poolOOP = _gst_class_variable_dictionary (poolOOP);
  if (!is_a_kind_of (OOP_CLASS (poolOOP), _gst_dictionary_class))
    return;

  if (pointer_set_contains (white, poolOOP))
    return;

  if (pointer_set_contains (grey, poolOOP))
    {
      _gst_errorf ("circular dependency in pool dictionaries");
      return;
    }

  /* Visit the super-namespace first, this amounts to processing the
     hierarchy in reverse order (see Class>>#allSharedPoolDictionariesDo:). */
  pointer_set_insert (grey, poolOOP);
  if (is_a_kind_of (OOP_CLASS (poolOOP), _gst_abstract_namespace_class))
    {
      gst_namespace pool = (gst_namespace) OOP_TO_OBJ (poolOOP);
      if (!IS_NIL (pool->superspace))
	visit_pool (pool->superspace, grey, white, p_head, p_tail);
    }
  pointer_set_insert (white, poolOOP);

  /* Add an entry for this one at the beginning of the list.  We need
     to maintain the tail too, because combine_local_pools must return
     it.  */
  entry = xmalloc (sizeof (struct pool_list));
  entry->poolOOP = poolOOP;
  entry->next = *p_head;
  *p_head = entry;
  if (!*p_tail)
    *p_tail = entry;
}

/* Run visit_pool on all the shared pools, starting with WHITE as
   the visited set so that those are not added.  The resulting
   list is built separately, and at the end all of the namespaces
   in the list are tacked after the node whose next pointer is
   in P_END.  The new last node is returned (actually its next pointer).  */

static pool_list *
combine_local_pools (OOP sharedPoolsOOP, struct pointer_set_t *white, pool_list *p_end)
{
  struct pointer_set_t *grey = pointer_set_create ();
  pool_list head = NULL;
  pool_list tail = NULL;
  int numPools, i;

  /* Visit right-to-left because visit_pool adds to the beginning.  */
  numPools = NUM_OOPS (OOP_TO_OBJ (sharedPoolsOOP));
  for (i = numPools; --i >= 0; )
    {
      OOP poolDictionaryOOP = ARRAY_AT (sharedPoolsOOP, i + 1);
      visit_pool (poolDictionaryOOP, grey, white, &head, &tail);
    }

  pointer_set_destroy (grey);
  if (head)
    {
      /* If anything was found, tack the list after P_END and return
	 the new tail.  */
      *p_end = head;
      return &tail->next;
    }
  else
    return p_end;
}


/* Add the list of resolved pools for CLASS_OOP.  This includes:
   1) its class pool; 2) its shared pools as added by
   combine_local_pools, and excluding those found from the
   environment; 3) the environment and its superspaces,
   excluding those reachable also from the environment of
   the superclass.  */

static pool_list *
add_shared_pool_resolution (OOP class_oop, OOP environmentOOP, pool_list *p_end)
{
  gst_class class;
  struct pointer_set_t *pset;

  /* Then in all the imports not reachable from the environment.  */
  pset = make_with_all_superspaces_set (environmentOOP);
  class = (gst_class) OOP_TO_OBJ (class_oop);
  p_end = combine_local_pools (class->sharedPools, pset, p_end);
  pointer_set_destroy (pset);

  /* Then search in the `environments', except those that are already
     reachable from the superclass. */
  class_oop = SUPERCLASS (class_oop);
  if (!IS_NIL (class_oop))
    pset = make_with_all_superspaces_set (CLASS_ENVIRONMENT (class_oop));
  else
    pset = NULL;
  
  p_end = add_namespace (environmentOOP, pset, p_end);
  if (pset)
    pointer_set_destroy (pset);
  return p_end;
}

void
_gst_compute_linearized_pools (gst_parser *parser, mst_Boolean forDoit)
{
  pool_list *p_end = &_gst_current_parser->linearized_pools;
  OOP myClass, classOOP;
  OOP environmentOOP = parser->current_namespace;

  if (IS_NIL (parser->currentClass))
    myClass = _gst_undefined_object_class;
  else
    myClass = _gst_get_class_object (parser->currentClass);

  assert (_gst_current_parser->linearized_pools == NULL);

  /* Add pools separately for each class.  */
  for (classOOP = myClass; !IS_NIL (classOOP); classOOP = SUPERCLASS (classOOP))
    {
      /* First search in the class pool.  */
      p_end = add_pool (_gst_class_variable_dictionary (classOOP), p_end);

      /* Override CLASSOOP's environment with ENVIRONMENTOOP if it is not
         NULL.  */
      p_end = add_shared_pool_resolution
	      (classOOP, 
	       forDoit ? environmentOOP : CLASS_ENVIRONMENT (classOOP),
	       p_end);
    }
}

OOP
find_class_variable (OOP varName)
{
  pool_list pool;
  OOP assocOOP;

  for (pool = _gst_current_parser->linearized_pools; pool; pool = pool->next)
    {
      assocOOP =
	dictionary_association_at (pool->poolOOP, varName);

      if (!IS_NIL (assocOOP))
	return (assocOOP);
    }

  return (_gst_nil_oop);
}


OOP
_gst_push_temporaries_dictionary (void)
{
  OOP old = temporaries_dictionary;
  temporaries_dictionary = _gst_dictionary_new (8);
  _gst_register_oop (temporaries_dictionary);
  return old;
}

void
_gst_pop_temporaries_dictionary (OOP dictionaryOOP)
{
  _gst_unregister_oop (temporaries_dictionary);
  temporaries_dictionary = dictionaryOOP;
}


tree_node
_gst_find_variable_binding (tree_node list)
{
  OOP symbol, root, assocOOP;
  tree_node elt;

  symbol = _gst_intern_string (list->v_list.name);
  assocOOP = find_class_variable (symbol);

  for (elt = list; assocOOP != _gst_nil_oop && (elt = elt->v_list.next); )
    {
      root = ASSOCIATION_VALUE (assocOOP);
      symbol = _gst_intern_string (elt->v_list.name);
      assocOOP = _gst_namespace_association_at (root, symbol);
    }

  if (!IS_NIL (assocOOP))
    return _gst_make_oop_constant (&list->location, assocOOP);

  /* For temporaries, make a deferred binding so that we can try using
     a global variable.  Unlike namespaces, the temporaries dictionary
     does not know anything about Undeclared.  */
  if (_gst_compiler_state->undeclared_temporaries)
    return _gst_make_deferred_binding_constant (&list->location, list);

  if (!elt->v_list.next 
      && isupper (*STRING_OOP_CHARS (symbol)))
    {
      OOP dictOOP = dictionary_at (_gst_smalltalk_dictionary,
				   _gst_undeclared_symbol);
      assocOOP = _gst_namespace_association_at (dictOOP, symbol);
      if (IS_NIL (assocOOP))
        assocOOP = NAMESPACE_AT_PUT (dictOOP, symbol, _gst_nil_oop);
      return _gst_make_oop_constant (&list->location, assocOOP);
    }

  return NULL;
}

OOP
_gst_get_undeclared_dictionary ()
{
  assert (_gst_compiler_state->undeclared_temporaries);
  return temporaries_dictionary;
}

mst_Boolean
_gst_find_variable (symbol_entry * se,
		    tree_node list)
{
  tree_node resolved;
  int index;
  unsigned int scopeDistance;
  scope scope;
  symbol_list s;
  OOP varAssoc;
  OOP symbol;

  symbol = _gst_intern_string (list->v_list.name);
  if (symbol == _gst_self_symbol || symbol == _gst_super_symbol)
    {
      fill_symbol_entry (se, SCOPE_SPECIAL, true, symbol, RECEIVER_INDEX,
			 0);
      return (true);
    }
  else if (symbol == _gst_true_symbol)
    {
      fill_symbol_entry (se, SCOPE_SPECIAL, true, symbol, TRUE_INDEX, 0);
      return (true);
    }
  else if (symbol == _gst_false_symbol)
    {
      fill_symbol_entry (se, SCOPE_SPECIAL, true, symbol, FALSE_INDEX,
			 0);
      return (true);
    }
  else if (symbol == _gst_nil_symbol)
    {
      fill_symbol_entry (se, SCOPE_SPECIAL, true, symbol, NIL_INDEX, 0);
      return (true);
    }
  else if (symbol == _gst_builtin_selectors[THIS_CONTEXT_SPECIAL].symbol)
    {
      fill_symbol_entry (se, SCOPE_SPECIAL, true, symbol,
			 THIS_CONTEXT_INDEX, 0);
      return (true);
    }

  for (scope = _gst_compiler_state->cur_scope, scopeDistance = 0; scope != NULL;
       scope = scope->prevScope, scopeDistance++)
    {
      s = find_local_var (scope, symbol);
      if (s)
	{
	  fill_symbol_entry (se, SCOPE_TEMPORARY,
			     s->readOnly, symbol, s->index,
			     scopeDistance);
	  return (true);
	}
    }

  index = instance_variable_index (symbol);
  if (index >= 0)
    {
      fill_symbol_entry (se, SCOPE_RECEIVER, 
			 is_instance_variable_read_only (index),
			 symbol, index, 0);
      return (true);
    }

  resolved = _gst_find_variable_binding (list);
  if (!resolved)
    return (false);

  varAssoc = _gst_make_constant_oop (resolved);
  index = _gst_add_forced_object (varAssoc);

  fill_symbol_entry (se, SCOPE_GLOBAL, 
		     (_gst_curr_method->v_method.untrusted
		      && !IS_OOP_UNTRUSTED (varAssoc)),
		     varAssoc, index, 0);
  return (true);
}

static mst_Boolean
is_instance_variable_read_only (int index)
{
  int numVars;
  OOP class_oop;

  if (!_gst_curr_method->v_method.untrusted)
    return (false);

  for (class_oop = _gst_curr_method->v_method.currentClass;
       IS_OOP_UNTRUSTED (class_oop);
       class_oop = SUPERCLASS (class_oop))
    ;

  numVars = CLASS_FIXED_FIELDS (class_oop);
  return index + 1 <= numVars;
}

static int
instance_variable_index (OOP symbol)
{
  OOP arrayOOP;
  int index, numVars;

  arrayOOP = _gst_instance_variable_array
    (_gst_curr_method->v_method.currentClass);
  numVars = NUM_OOPS (OOP_TO_OBJ (arrayOOP));

  for (index = numVars; index >= 1; index--)
    if (ARRAY_AT (arrayOOP, index) == symbol)
      return (index - 1);

  return (-1);
}


static symbol_list
find_local_var (scope scope,
		OOP symbol)
{
  symbol_list s;

  for (s = scope->symbols; s != NULL && symbol != s->symbol;
       s = s->prevSymbol);

  return (s);
}

static void
fill_symbol_entry (symbol_entry * ent,
		   scope_type scope,
		   mst_Boolean readOnly,
		   OOP symbol,
		   int index,
		   unsigned int scopeDistance)
{
  ent->scope = scope;
  ent->readOnly = readOnly;
  ent->symbol = symbol;
  ent->varIndex = index;
  ent->scopeDistance = scopeDistance;
}

void
_gst_print_symbol_entry (symbol_entry * ent)
{
  printf ("%#O", ent->symbol);
  switch (ent->scope)
    {
    case SCOPE_RECEIVER:
      printf (" (inst.var. #%d)", ent->varIndex);
      break;

    case SCOPE_GLOBAL:
      printf (" (global)");
      break;

    case SCOPE_TEMPORARY:
      printf (" (temp.var. #");
      if (ent->scopeDistance)
	printf ("%d.", ent->scopeDistance);

      printf ("%d)", ent->varIndex);
      break;

    case SCOPE_SPECIAL:
      printf (" (special)");
      break;
    }
}



OOP
_gst_find_pragma_handler (OOP classOOP,
			  OOP symbolOOP)
{
  OOP class_oop, myClass;

  myClass = _gst_get_class_object (_gst_curr_method->v_method.currentClass);

  /* Now search in the class pools */
  for (class_oop = myClass; !IS_NIL (class_oop);
       class_oop = SUPERCLASS (class_oop))
    {
      gst_class class = (gst_class) OOP_TO_OBJ (class_oop);
      OOP handlerOOP;

      if (IS_NIL (class->pragmaHandlers))
	continue;

      handlerOOP = _gst_identity_dictionary_at (class->pragmaHandlers,
                                                symbolOOP);
      if (!IS_NIL (handlerOOP))
	return handlerOOP;
    }

  return (_gst_nil_oop);
}

OOP
_gst_make_instance_variable_array (OOP superclassOOP,
				   const char * variableString)
{
  OOP arrayOOP, superArrayOOP, name;
  int index, numInstanceVars, superInstanceVars;
  const char *p;
  inc_ptr incPtr;
  gst_object array;

  if (variableString == NULL)
    variableString = "";

  if (IS_NIL (superclassOOP))
    {
      superArrayOOP = _gst_nil_oop;
      superInstanceVars = numInstanceVars = 0;
    }
  else
    {
      superArrayOOP = _gst_instance_variable_array (superclassOOP);
      superInstanceVars = numInstanceVars =
	NUM_OOPS (OOP_TO_OBJ (superArrayOOP));
    }

  for (p = variableString; *p;)
    {
      /* skip intervening whitespace */
      name = scan_name (&p);
      if (!IS_NIL (name))
	numInstanceVars++;
    }

  if (numInstanceVars == 0)
    return (_gst_nil_oop);	/* no instances here */

  incPtr = INC_SAVE_POINTER ();

  array = instantiate_with (_gst_array_class, numInstanceVars, &arrayOOP);
  INC_ADD_OOP (arrayOOP);

  /* inherit variables from parent */
  for (index = 1; index <= superInstanceVars; index++)
    array->data[index - 1] = ARRAY_AT (superArrayOOP, index);

  /* now add our own variables */
  for (p = variableString; *p; index++)
    {
      /* skip intervening whitespace */
      name = scan_name (&p);
      /* don't need to add name to incubator -- it's a symbol so it's
         already held onto */

      array = OOP_TO_OBJ (arrayOOP);
      if (!IS_NIL (name))
	array->data[index - 1] = name;
    }

  INC_RESTORE_POINTER (incPtr);
  return (arrayOOP);
}

OOP
_gst_make_class_variable_dictionary (const char *variableNames,
				     OOP classOOP)
{
  OOP dictionaryOOP, name;
  const char *p;
  inc_ptr incPtr;

  if (variableNames == NULL)
    variableNames = "";

  incPtr = INC_SAVE_POINTER ();

  dictionaryOOP = _gst_nil_oop;
  for (p = variableNames; *p;)
    {
      name = scan_name (&p);
      if (!IS_NIL (name))
	{
	  if (IS_NIL (dictionaryOOP))
	    {
	      dictionaryOOP = _gst_binding_dictionary_new (8, classOOP);
	      INC_ADD_OOP (dictionaryOOP);
	    }

	  /* ### error if already exists */
	  /* don't need to add name to incubator -- it's a symbol so
	     it's already held onto */
	  NAMESPACE_AT_PUT (dictionaryOOP, name, _gst_nil_oop);
	}
    }

  INC_RESTORE_POINTER (incPtr);
  return (dictionaryOOP);
}

OOP
_gst_make_pool_array (const char * poolNames)
{
  OOP poolsOOP, name;
  gst_object pools;
  int numPools, i;
  const char *p, *e;
  inc_ptr incPtr;

  if (poolNames == NULL)
    poolNames = (char *) "";

  /* count the number of new pool names */
  for (p = poolNames, numPools = 0; *p;)
    {
      parse_variable_name (&p, &e);
      if (p != e)
	{
	  numPools++;
	  p = e;
	}
    }

  incPtr = INC_SAVE_POINTER ();

  poolsOOP = _gst_nil_oop;	/* ### maybe change this to leave empty 
				   array */

  for (p = poolNames, i = 0; *p; i++)
    {
      name = scan_name (&p);
      if (!IS_NIL (name))
	{
	  /* don't need to add name to incubator -- it's a symbol so
	     it's already held onto.  */

	  /* ### error if already exists in parent?, or if value isn't
	     a dictionary */
	  /* ### should I keep these as names? or associations? Should
	     I look up the names somewhere other than in the smalltalk
	     dictionary? Need to check for undefineds? */
	  if (poolsOOP == _gst_nil_oop)
	    {
	      instantiate_with (_gst_array_class, numPools, &poolsOOP);
	      INC_ADD_OOP (poolsOOP);
	    }

	  pools = OOP_TO_OBJ (poolsOOP);
	  pools->data[i] = dictionary_at (_gst_smalltalk_dictionary,
					  name);
	}
    }


  INC_RESTORE_POINTER (incPtr);
  return (poolsOOP);
}



static OOP
scan_name (const char ** pp)
{
  const char *end;
  char *str;
  size_t len;

  parse_variable_name (pp, &end);
  len = end - *pp;
  if (len == 0)
    return (_gst_nil_oop);

  str = (char *) alloca (len + 1);
  strncpy (str, *pp, len);
  str[len] = '\0';

  *pp = end;

  return (_gst_intern_string (str));
}

static void
parse_variable_name (const char ** pp,
		     const char ** endp)
{
  const char *p, *e;

  p = *pp;
  while (is_white_space (*p))
    p++;
  *pp = p;

  /* check for non-null here and not alnum; we've jammed on a bogus 
     char and it's an error */

  if (isalpha (*p)) {
    /* variable name extends from p to e-1 */
    for (e = p; *e; e++)
      if (!isalnum (*e) && *e != '_')
	break;

    *endp = e;
  } else
    *endp = p;
}

static mst_Boolean
is_white_space (char c)
{
  return (c == ' ' || c == '\r' || c == '\t' || c == '\n' || c == '\f');
}



OOP
_gst_intern_string_oop (OOP stringOOP)
{
  unsigned int len;
  char copyBuf[100], *copyPtr;
  OOP symbolOOP;

  len = _gst_string_oop_len (stringOOP);

  /* do this slightly more complicated bit of code because: 1) we don't 
     want to call malloc/free if we can help it 2) if we just used
     STRING_OOP_CHARS (as we used to), we pass the *dereferenced* value 
     of the stringOOP.  intern_counted_string can do allocations.  If
     it allocates, and the gc runs, stringOOP can move, meaning the
     dereferenced set of chars becomes invalid.  So instead we make a
     non-moving copy and use that.  */
  if (len < sizeof (copyBuf))
    copyPtr = copyBuf;
  else
    copyPtr = (char *) xmalloc (len);

  memcpy (copyPtr, STRING_OOP_CHARS (stringOOP), len);

  symbolOOP = intern_counted_string (copyPtr, len);

  if (len >= sizeof (copyBuf))
    xfree (copyPtr);

  return symbolOOP;
}

OOP
_gst_intern_string (const char *str)
{
  int len;

  len = strlen (str);
  return (intern_counted_string (str, len));
}

static uintptr_t
hash_symbol (const char *str, int len)
{
  uintptr_t index = scramble (_gst_hash_string (str, len));
  return (index & (SYMBOL_TABLE_SIZE - 1)) + 1;
}

static OOP
alloc_symlink (OOP symbolOOP, uintptr_t index)
{
  gst_symbol symbol;
  sym_link link;
  OOP linkOOP;

  symbol = (gst_symbol) OOP_TO_OBJ (symbolOOP);
  symbol->objClass = _gst_symbol_class;

  link = (sym_link) new_instance (_gst_sym_link_class, &linkOOP);
  link->nextLink = ARRAY_AT (_gst_symbol_table, index);
  link->symbol = symbolOOP;
  ARRAY_AT_PUT (_gst_symbol_table, index, linkOOP);

  return (symbolOOP);
}

static OOP
intern_counted_string (const char *str,
		       int len)
{
  uintptr_t index;
  OOP symbolOOP, linkOOP;
  sym_link link;
  inc_ptr incPtr;

  index = hash_symbol (str, len);
  for (linkOOP = ARRAY_AT (_gst_symbol_table, index); !IS_NIL (linkOOP);
       linkOOP = link->nextLink)
    {
      link = (sym_link) OOP_TO_OBJ (linkOOP);
      if (is_same_string (str, link->symbol, len))
	return (link->symbol);
    }

  /* no match, have to add it to head of list */
#ifdef HAVE_READLINE
  _gst_add_symbol_completion (str, len);
#endif

  incPtr = INC_SAVE_POINTER ();
  symbolOOP = alloc_symbol_oop (str, len);
  INC_ADD_OOP (symbolOOP);

  alloc_symlink (symbolOOP, index);
  INC_RESTORE_POINTER (incPtr);

  return (symbolOOP);
}

static OOP
alloc_symbol_oop (const char *str, int len)
{
  int numBytes, alignedBytes;
  gst_symbol symbol;
  OOP symbolOOP;

  numBytes = sizeof(gst_object_header) + len;
  alignedBytes = ROUNDED_BYTES (numBytes);
  symbol = (gst_symbol) _gst_alloc_obj (alignedBytes, &symbolOOP);
  INIT_UNALIGNED_OBJECT (symbolOOP, alignedBytes - numBytes);

  memcpy (symbol->symString, str, len);
  symbolOOP->flags |= F_READONLY;
  return symbolOOP;
}

static mst_Boolean
is_same_string (const char *str,
		OOP oop,
		int len)
{
  if (_gst_string_oop_len (oop) == len)
    return (strncmp
	    (str, ((gst_symbol) OOP_TO_OBJ (oop))->symString,
	     len) == 0);

  return (false);
}

int
_gst_string_oop_len (OOP oop)
{
  return (OOP_SIZE_BYTES (oop) - (oop->flags & EMPTY_BYTES));
}

uintptr_t
_gst_hash_string (const char *str,
		  int len)
{
  uintptr_t hashVal = 1497032417;    /* arbitrary value */

  while (len--)
    {
      hashVal += *str++;
      hashVal += (hashVal << 10);
      hashVal ^= (hashVal >> 6);
    }

  return hashVal & MAX_ST_INT;
}


void
_gst_check_symbol_chain (void)
{
  int i;

  for (i = 1; i <= SYMBOL_TABLE_SIZE; i++)
    {
      sym_link link;
      OOP linkOOP;
      for (linkOOP = ARRAY_AT (_gst_symbol_table, i); !IS_NIL (linkOOP);
	   linkOOP = link->nextLink)
	{
	  link = (sym_link) OOP_TO_OBJ (linkOOP);
	  if (OOP_CLASS (linkOOP) != _gst_sym_link_class ||
	      OOP_CLASS (link->symbol) != _gst_symbol_class)
	    {
	      printf ("Bad symbol %p\n", linkOOP);
	      abort ();
	    }
	}
    }
}

#ifdef HAVE_READLINE
void
_gst_add_all_symbol_completions (void)
{
  int i;

  for (i = 1; i <= SYMBOL_TABLE_SIZE; i++)
    {
      sym_link link;
      OOP linkOOP;
      char *string;
      int len;
      for (linkOOP = ARRAY_AT (_gst_symbol_table, i); !IS_NIL (linkOOP);
	   linkOOP = link->nextLink)
	{
	  link = (sym_link) OOP_TO_OBJ (linkOOP);
	  string = _gst_to_cstring (link->symbol);
	  len = _gst_string_oop_len (link->symbol);
	  _gst_add_symbol_completion (string, len);
	  xfree (string);
	}
    }
}
#endif



int
_gst_selector_num_args (OOP symbolOOP)
{
  char *bytes;
  int numArgs, len;

  len = _gst_string_oop_len (symbolOOP);
  bytes = (char *) (OOP_TO_OBJ (symbolOOP)->data);
  if ((bytes[0] >= 'A' && bytes[0] <= 'Z')
      || (bytes[0] >= 'a' && bytes[0] <= 'z')
      || bytes[0] == '_')
    {
      for (numArgs = 0; len;)
        if (bytes[--len] == ':')
          numArgs++;
    }
  else
    numArgs = 1;

  return (numArgs);
}

#include "builtins.inl"

void
_gst_init_symbols_pass1 (void)
{
  const symbol_info *si;
  struct builtin_selector *bs;

  for (si = sym_info; si->symbolVar; si++)
    *si->symbolVar = alloc_symbol_oop (si->value, strlen (si->value));

  /* Complete gperf's generated table with each symbol's OOP,
     and prepare a kind of reverse mapping from the 256 bytecodes
     to the hash table entries.  */
  for (bs = _gst_builtin_selectors_hash;
       bs - _gst_builtin_selectors_hash <
	 sizeof (_gst_builtin_selectors_hash) / sizeof (_gst_builtin_selectors_hash[0]);
       bs++)
    if (bs->offset != -1)
      {
	const char *name = bs->offset + _gst_builtin_selectors_names;
	bs->symbol = alloc_symbol_oop (name, strlen (name));
        _gst_builtin_selectors[bs->bytecode] = *bs;
      }
}

void
_gst_init_symbols_pass2 (void)
{
  const symbol_info *si;
  struct builtin_selector *bs;

  for (si = sym_info; si->symbolVar; si++)
    alloc_symlink (*si->symbolVar, hash_symbol (si->value, strlen (si->value)));

  /* Complete gperf's generated table with each symbol's OOP,
     and prepare a kind of reverse mapping from the 256 bytecodes
     to the hash table entries.  */
  for (bs = _gst_builtin_selectors_hash;
       bs - _gst_builtin_selectors_hash <
	 sizeof (_gst_builtin_selectors_hash) / sizeof (_gst_builtin_selectors_hash[0]);
       bs++)
    if (bs->offset != -1)
      {
	const char *name = bs->offset + _gst_builtin_selectors_names;
	alloc_symlink (bs->symbol, hash_symbol (name, strlen (name)));
      }
}

static inline OOP
intern_string_fast (const char *str, OOP *pTestOOP)
{
  int len = strlen (str);
  OOP testOOP = *pTestOOP;

  if (is_same_string (str, testOOP, len))
    {
      (*pTestOOP)++;
      return testOOP;
    }
  else
    return intern_counted_string (str, len);
}

void
_gst_restore_symbols (void)
{
  const symbol_info *si;
  struct builtin_selector *bs;
  OOP currentOOP = _gst_symbol_table + 1;

  for (si = sym_info; si->symbolVar; si++)
    *si->symbolVar = intern_string_fast (si->value, &currentOOP);

  /* Complete gperf's generated table with each symbol's OOP,
     and prepare a kind of reverse mapping from the 256 bytecodes
     to the hash table entries.  */
  for (bs = _gst_builtin_selectors_hash;
       bs - _gst_builtin_selectors_hash <
	 sizeof (_gst_builtin_selectors_hash) / sizeof (_gst_builtin_selectors_hash[0]);
       bs++)
    if (bs->offset != -1)
      {
	const char *name = bs->offset + _gst_builtin_selectors_names;
	bs->symbol = intern_string_fast (name, &currentOOP);
        _gst_builtin_selectors[bs->bytecode] = *bs;
      }
}
