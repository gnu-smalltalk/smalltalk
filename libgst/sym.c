/******************************** -*- C -*- ****************************
*
 *	Symbol Table module.
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
   being the innermost at any point during the compilation. */
typedef struct scope *scope;
struct scope
{
  scope prevScope;
  unsigned int numArguments;
  unsigned int numTemporaries;
  symbol_list symbols;
};


typedef struct symbol_info
{
  OOP *symbolVar;
  const char *value;
}
symbol_info;


OOP _gst_and_colon_symbol, _gst_at_colon_put_colon_symbol,
  _gst_at_colon_symbol, _gst_at_sign_symbol, _gst_at_end_symbol,
  _gst_bit_and_colon_symbol, _gst_bit_or_colon_symbol,
  _gst_bit_shift_colon_symbol, _gst_block_copy_colon_symbol,
  _gst_class_symbol, _gst_is_nil_symbol, _gst_not_nil_symbol,
  _gst_divide_symbol, _gst_do_colon_symbol, _gst_equal_symbol,
  _gst_greater_equal_symbol, _gst_greater_than_symbol,
  _gst_if_false_colon_if_true_colon_symbol, _gst_if_false_colon_symbol,
  _gst_if_true_colon_if_false_colon_symbol, _gst_if_true_colon_symbol,
  _gst_integer_divide_symbol, _gst_less_equal_symbol,
  _gst_less_than_symbol, _gst_minus_symbol, _gst_new_colon_symbol,
  _gst_new_symbol, _gst_next_put_colon_symbol, _gst_next_symbol,
  _gst_not_equal_symbol, _gst_not_same_object_symbol,
  _gst_or_colon_symbol, _gst_plus_symbol, _gst_remainder_symbol,
  _gst_same_object_symbol, _gst_size_symbol, _gst_this_context_symbol,
  _gst_times_symbol,
  _gst_to_colon_do_colon_symbol, _gst_times_repeat_colon_symbol,
  _gst_to_colon_by_colon_do_colon_symbol,
  _gst_value_colon_symbol, _gst_value_colon_value_colon_symbol,
  _gst_value_colon_value_colon_value_colon_symbol,
  _gst_value_with_arguments_colon_symbol, _gst_while_false_symbol,
  _gst_value_symbol, _gst_yourself_symbol, _gst_while_true_symbol,
  _gst_while_false_colon_symbol, _gst_while_true_colon_symbol,
  _gst_bad_return_error_symbol, _gst_super_symbol, _gst_nil_symbol,
  _gst_true_symbol, _gst_false_symbol, _gst_self_symbol,
  _gst_repeat_symbol, _gst_does_not_understand_colon_symbol,
  _gst_must_be_boolean_symbol, _gst_terminate_symbol, _gst_char_symbol,
  _gst_as_scaled_decimal_scale_symbol, _gst_unknown_symbol,
  _gst_string_symbol, _gst_string_out_symbol, _gst_symbol_symbol,
  _gst_int_symbol, _gst_uint_symbol, _gst_long_symbol,
  _gst_ulong_symbol, _gst_float_symbol, _gst_double_symbol,
  _gst_boolean_symbol, _gst_void_symbol, _gst_variadic_symbol,
  _gst_c_object_symbol, _gst_c_object_ptr_symbol, _gst_smalltalk_symbol,
  _gst_byte_array_symbol, _gst_byte_array_out_symbol,
  _gst_undeclared_symbol, _gst_self_smalltalk_symbol,
  _gst_vm_primitives_symbol, _gst_variadic_smalltalk_symbol,
  _gst_start_execution_colon_symbol, _gst_symbol_table,
  _gst_current_namespace;

/* True if undeclared globals can be considered forward references.  */
long _gst_use_undeclared;

/* Answer whether OOP is a Smalltalk String LEN characters long and
   these characters match the first LEN characters of STR (which must
   not have embedded NULs). */
static mst_Boolean is_same_string (const char *str,
				   OOP oop,
				   int len);

/* Answer whether C is considered a white space character in Smalltalk
   programs. */
static mst_Boolean is_white_space (gst_uchar c);

/* Free the list of symbols declared in the given SCOPE. */
static void free_scope_symbols (scope scope);

/* Scans a variable name (letters and digits, initial letter), and
   return a symbol for it. PP is a pointer to a pointer to the start
   of the string to be scanned, which may be pointing at either
   whitespace or start of variable.  At end, it points to the first
   character after the initial whitespace, if any.  ENDP instead is
   initialized by the function to point to first character after the
   parsed variable name, which may be NUL. */
static void parse_variable_name (gst_uchar ** pp,
				 gst_uchar ** endp);

/* This fills ENT's fields with the contents of its parameters. */
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
   Symbol, _gst_nil_oop if no variable name is found. */
static OOP scan_name (gst_uchar ** pp);

/* This creates a Symbol containing LEN bytes starting at STR and puts
   it in the symbol list, or returns an existing one if it is
   found. */
static OOP intern_counted_string (const char *str,
				  int len);

/* This looks for SYMBOL among the instance variables that the current
   class declares, and returns the index of the variable if one is
   found. */
static int instance_variable_index (OOP symbol);

/* This looks for SYMBOL among the arguments and temporary variables
   that the current scope sees, and returns the entry in the symbol
   list for the variable if it is found. */
static symbol_list find_local_var (scope scope,
				   OOP symbol);

/* This looks for SYMBOL among the global variables that the current
   scope sees, including superspaces if any, and returns the entry in
   the symbol list for the variable if it is found. */
static OOP find_class_variable (OOP varName);

static scope cur_scope = NULL;

/* This is an array of symbols which the virtual machine knows about,
   and is used to restore the global variables upon image load. */
static const symbol_info sym_info[] = {
  {&_gst_and_colon_symbol, "and:"},
  {&_gst_as_scaled_decimal_scale_symbol, "asScaledDecimal:scale:"},
  {&_gst_at_colon_put_colon_symbol, "at:put:"},
  {&_gst_at_colon_symbol, "at:"},
  {&_gst_at_end_symbol, "atEnd"},
  {&_gst_at_sign_symbol, "@"},
  {&_gst_bad_return_error_symbol, "badReturnError"},
  {&_gst_bit_and_colon_symbol, "bitAnd:"},
  {&_gst_bit_or_colon_symbol, "bitOr:"},
  {&_gst_bit_shift_colon_symbol, "bitShift:"},
  {&_gst_block_copy_colon_symbol, "blockCopy:"},
  {&_gst_byte_array_symbol, "byteArray"},
  {&_gst_byte_array_out_symbol, "byteArrayOut"},
  {&_gst_boolean_symbol, "boolean"},
  {&_gst_char_symbol, "char"},
  {&_gst_class_symbol, "class"},
  {&_gst_c_object_symbol, "cObject"},
  {&_gst_c_object_ptr_symbol, "cObjectPtr"},
  {&_gst_divide_symbol, "/"},
  {&_gst_do_colon_symbol, "do:"},
  {&_gst_does_not_understand_colon_symbol, "doesNotUnderstand:"},
  {&_gst_float_symbol, "float"},
  {&_gst_double_symbol, "double"},
  {&_gst_equal_symbol, "="},
  {&_gst_false_symbol, "false"},
  {&_gst_start_execution_colon_symbol, "startExecution:"},
  {&_gst_greater_equal_symbol, ">="},
  {&_gst_greater_than_symbol, ">"},
  {&_gst_if_false_colon_if_true_colon_symbol, "ifFalse:ifTrue:"},
  {&_gst_if_false_colon_symbol, "ifFalse:"},
  {&_gst_if_true_colon_if_false_colon_symbol, "ifTrue:ifFalse:"},
  {&_gst_if_true_colon_symbol, "ifTrue:"},
  {&_gst_integer_divide_symbol, "//"},
  {&_gst_int_symbol, "int"},
  {&_gst_uint_symbol, "uInt"},
  {&_gst_is_nil_symbol, "isNil"},
  {&_gst_less_equal_symbol, "<="},
  {&_gst_less_than_symbol, "<"},
  {&_gst_long_symbol, "long"},
  {&_gst_ulong_symbol, "uLong"},
  {&_gst_minus_symbol, "-"},
  {&_gst_must_be_boolean_symbol, "mustBeBoolean"},
  {&_gst_new_colon_symbol, "new:"},
  {&_gst_new_symbol, "new"},
  {&_gst_next_put_colon_symbol, "nextPut:"},
  {&_gst_next_symbol, "next"},
  {&_gst_nil_symbol, "nil"},
  {&_gst_not_equal_symbol, "~="},
  {&_gst_not_nil_symbol, "notNil"},
  {&_gst_not_same_object_symbol, "~~"},
  {&_gst_or_colon_symbol, "or:"},
  {&_gst_plus_symbol, "+"},
  {&_gst_remainder_symbol, "\\"},
  {&_gst_repeat_symbol, "repeat"},
  {&_gst_same_object_symbol, "=="},
  {&_gst_self_symbol, "self"},
  {&_gst_self_smalltalk_symbol, "selfSmalltalk"},
  {&_gst_size_symbol, "size"},
  {&_gst_smalltalk_symbol, "smalltalk"},
  {&_gst_string_out_symbol, "stringOut"},
  {&_gst_string_symbol, "string"},
  {&_gst_super_symbol, "super"},
  {&_gst_symbol_symbol, "symbol"},
  {&_gst_terminate_symbol, "__terminate"},
  {&_gst_this_context_symbol, "thisContext"},
  {&_gst_times_symbol, "*"},
  {&_gst_times_repeat_colon_symbol, "timesRepeat:"},
  {&_gst_to_colon_by_colon_do_colon_symbol, "to:by:do:"},
  {&_gst_to_colon_do_colon_symbol, "to:do:"},
  {&_gst_true_symbol, "true"},
  {&_gst_undeclared_symbol, "Undeclared"},
  {&_gst_unknown_symbol, "unknown"},
  {&_gst_value_colon_symbol, "value:"},
  {&_gst_value_colon_value_colon_symbol, "value:value:"},
  {&_gst_value_colon_value_colon_value_colon_symbol,
   "value:value:value:"},
  {&_gst_value_symbol, "value"},
  {&_gst_value_with_arguments_colon_symbol, "valueWithArguments:"},
  {&_gst_variadic_symbol, "variadic"},
  {&_gst_variadic_smalltalk_symbol, "variadicSmalltalk"},
  {&_gst_vm_primitives_symbol, "VMPrimitives"},
  {&_gst_void_symbol, "void"},
  {&_gst_while_false_colon_symbol, "whileFalse:"},
  {&_gst_while_false_symbol, "whileFalse"},
  {&_gst_while_true_colon_symbol, "whileTrue:"},
  {&_gst_while_true_symbol, "whileTrue"},
  {&_gst_yourself_symbol, "yourself"},
  {NULL, NULL},
};




int
_gst_get_arg_count (void)
{
  return (cur_scope->numArguments);
}

int
_gst_get_temp_count (void)
{
  return (cur_scope->numTemporaries);
}

void
_gst_push_new_scope (void)
{
  scope newScope;
  newScope = (scope) xmalloc (sizeof (*newScope));
  newScope->prevScope = cur_scope;
  newScope->symbols = NULL;
  newScope->numArguments = 0;
  newScope->numTemporaries = 0;
  cur_scope = newScope;
}

void
_gst_pop_old_scope (void)
{
  scope oldScope;

  oldScope = cur_scope;
  cur_scope = cur_scope->prevScope;

  free_scope_symbols (oldScope);
  xfree (oldScope);
}

void
_gst_pop_all_scopes (void)
{
  while (cur_scope)
    _gst_pop_old_scope ();
}


int
_gst_declare_arguments (tree_node args)
{
  if (args->nodeType == TREE_UNARY_EXPR)
    return (0);

  else if (args->nodeType == TREE_BINARY_EXPR)
    _gst_declare_name (args->v_expr.expression->v_list.name, false);

  else
    {
      for (args = args->v_expr.expression; args != NULL;
	   args = args->v_list.next)
	_gst_declare_name (args->v_list.value->v_list.name, false);
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
    _gst_declare_name (temps->v_list.name, true);

  return (n);
}

int
_gst_declare_block_arguments (tree_node args)
{
  for (; args != NULL; args = args->v_list.next)
    _gst_declare_name (args->v_list.name, false);

  /* Arguments are always declared first! */
  cur_scope->numArguments = cur_scope->numTemporaries;
  cur_scope->numTemporaries = 0;
  return (cur_scope->numArguments);
}

void
_gst_undeclare_name (void)
{
  symbol_list oldList;

  oldList = cur_scope->symbols;
  cur_scope->symbols = cur_scope->symbols->prevSymbol;
  xfree (oldList);
}


int
_gst_declare_name (const char *name,
		   mst_Boolean writeable)
{
  symbol_list newList;

  newList = (symbol_list) xmalloc (sizeof (struct symbol_list));
  newList->symbol = _gst_intern_string (name);
  newList->index = cur_scope->numArguments + cur_scope->numTemporaries;
  newList->readOnly = !writeable;
  newList->prevSymbol = cur_scope->symbols;

  /* Arguments are always declared first, so we can assume it is a
     temporary -- if it is not, _gst_declare_arguments and
     _gst_declare_block_arguments will fix it. */
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


OOP
find_class_variable (OOP varName)
{
  OOP class_oop, assocOOP, poolDictionaryOOP;
  OOP myClass;
  int numPools, i;
  gst_class class;

  myClass = _gst_this_class;
  if (OOP_CLASS (myClass) == _gst_metaclass_class)
    {
      /* pretend that metaclasses have the class variables and shared
         pools that their instance classes do */
      myClass = METACLASS_INSTANCE (myClass);
    }
  while (OOP_CLASS (myClass) == _gst_behavior_class
	 || OOP_CLASS (myClass) == _gst_class_description_class)
    {
      /* pretend that lightweight classes have the class variables and
         shared pools that their superclasses have */
      myClass = SUPERCLASS (myClass);
    }

  /* Now search in the class pools */
  for (class_oop = myClass; !IS_NIL (class_oop);
       class_oop = SUPERCLASS (class_oop))
    {
      assocOOP =
	dictionary_association_at (_gst_class_variable_dictionary
				   (class_oop), varName);

      if (!IS_NIL (assocOOP))
	return (assocOOP);
    }

  /* Now search in the `environments' */
  for (class_oop = myClass; !IS_NIL (class_oop);
       class_oop = SUPERCLASS (class_oop))
    {
      class = (gst_class) OOP_TO_OBJ (class_oop);
      assocOOP =
	_gst_find_shared_pool_variable (class->environment, varName);
      if (!IS_NIL (assocOOP))
	return (assocOOP);
    }

  /* and in the shared pools */
  for (class_oop = myClass; !IS_NIL (class_oop);
       class_oop = SUPERCLASS (class_oop))
    {
      class = (gst_class) OOP_TO_OBJ (class_oop);
      numPools = NUM_OOPS (OOP_TO_OBJ (class->sharedPools));
      for (i = 0; i < numPools; i++)
	{
	  poolDictionaryOOP = ARRAY_AT (class->sharedPools, i + 1);
	  assocOOP =
	    _gst_find_shared_pool_variable (poolDictionaryOOP, varName);
	  if (!IS_NIL (assocOOP))
	    return (assocOOP);
	}
    }

  return (_gst_nil_oop);
}


OOP
_gst_find_variable_binding (tree_node list)
{
  OOP symbol, root, assocOOP, undeclaredDictionary;

  symbol = _gst_intern_string (list->v_list.name);
  assocOOP = find_class_variable (symbol);

  while (assocOOP != _gst_nil_oop && (list = list->v_list.next))
    {
      root = ASSOCIATION_VALUE (assocOOP);
      symbol = _gst_intern_string (list->v_list.name);
      assocOOP = _gst_find_shared_pool_variable (root, symbol);
    }

  if (IS_NIL (assocOOP) && !(list->v_list.next))
    {
      gst_uchar *varName;

      varName = STRING_OOP_CHARS (symbol);
      if (!isupper (*varName) || !_gst_use_undeclared)
	return (assocOOP);

      undeclaredDictionary =
	dictionary_at (_gst_smalltalk_dictionary,
		       _gst_undeclared_symbol);

      assocOOP =
	dictionary_association_at (undeclaredDictionary, symbol);

      if (IS_NIL (assocOOP))
	assocOOP =
	  NAMESPACE_AT_PUT (undeclaredDictionary, symbol,
			    _gst_nil_oop);
    }

  return (assocOOP);
}


mst_Boolean
_gst_find_variable (symbol_entry * se,
		    tree_node list)
{
  OOP varAssoc;
  int index;
  unsigned int scopeDistance;
  scope scope;
  symbol_list s;
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
  else if (symbol == _gst_this_context_symbol)
    {
      fill_symbol_entry (se, SCOPE_SPECIAL, true, symbol,
			 THIS_CONTEXT_INDEX, 0);
      return (true);
    }

  for (scope = cur_scope, scopeDistance = 0; scope != NULL;
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
      fill_symbol_entry (se, SCOPE_RECEIVER, false, symbol, index, 0);
      return (true);
    }

  varAssoc = _gst_find_variable_binding (list);
  if (IS_NIL (varAssoc))
    return (false);

  index = _gst_add_forced_object (varAssoc);

  fill_symbol_entry (se, SCOPE_GLOBAL, false, varAssoc, index, 0);
  return (true);
}

static int
instance_variable_index (OOP symbol)
{
  OOP arrayOOP;
  int index, numVars;

  arrayOOP = _gst_instance_variable_array (_gst_this_class);
  numVars = NUM_OOPS (OOP_TO_OBJ (arrayOOP));

  for (index = 1; index <= numVars; index++)
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
_gst_make_instance_variable_array (OOP superclassOOP,
				   gst_uchar * variableString)
{
  OOP arrayOOP, superArrayOOP, name;
  int index, numInstanceVars, superInstanceVars;
  gst_uchar *p;
  inc_ptr incPtr;
  mst_Object array;

  if (variableString == NULL)
    variableString = (gst_uchar *) "";

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
_gst_make_class_variable_dictionary (gst_uchar *variableNames,
				     OOP classOOP)
{
  OOP dictionaryOOP, name;
  gst_uchar *p;
  inc_ptr incPtr;

  if (variableNames == NULL)
    variableNames = (gst_uchar *) "";

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
_gst_make_pool_array (gst_uchar * poolNames)
{
  OOP poolsOOP, name;
  mst_Object pools;
  int numPools, i;
  gst_uchar *p, *e;
  inc_ptr incPtr;

  if (poolNames == NULL)
    poolNames = (gst_uchar *) "";

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
	     it's already held onto. */

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
scan_name (gst_uchar ** pp)
{
  gst_uchar *end, *str;
  long len;

  parse_variable_name (pp, &end);
  len = end - *pp;
  if (len == 0)
    return (_gst_nil_oop);

  str = (gst_uchar *) alloca (len + 1);
  strncpy (str, *pp, len);
  str[len] = '\0';

  *pp = end;

  return (_gst_intern_string (str));
}

static void
parse_variable_name (gst_uchar ** pp,
		     gst_uchar ** endp)
{
  gst_uchar *p, *e;

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
is_white_space (gst_uchar c)
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
     non-moving copy and use that. */
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

static OOP
intern_counted_string (const char *str,
		       int len)
{
  unsigned long index;
  sym_link link;
  gst_symbol symbol;
  OOP symbolOOP, linkOOP;
  inc_ptr incPtr;

  index = scramble (_gst_hash_string (str, len));
  index = (index & (SYMBOL_TABLE_SIZE - 1)) + 1;

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
  symbol = (gst_symbol) new_instance_with (_gst_symbol_class, 
					   (long) len, &symbolOOP);

  memcpy (symbol->symString, str, len);
  symbolOOP->flags |= F_READONLY;
  INC_ADD_OOP (symbolOOP);

  link = (sym_link) new_instance (_gst_sym_link_class, &linkOOP);
  link->nextLink = ARRAY_AT (_gst_symbol_table, index);
  link->symbol = symbolOOP;
  ARRAY_AT_PUT (_gst_symbol_table, index, linkOOP);

  INC_RESTORE_POINTER (incPtr);
  return (symbolOOP);
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

unsigned long
_gst_hash_string (const char *str,
		  int len)
{
  unsigned long hashVal = 1497032417;    /* arbitrary value */

  while (len--)
    {
      hashVal += *str++;
      hashVal += (hashVal << 10);
      hashVal ^= (hashVal >> 6);
    }

  return hashVal & MAX_ST_INT;
}

char *
_gst_symbol_as_string (OOP symbolOOP)
{
  static char stringBuf[256];	/* probably large enough for most
				   symbols */
  unsigned int len;
  gst_symbol symbol;

  symbol = (gst_symbol) OOP_TO_OBJ (symbolOOP);

  len = _gst_string_oop_len (symbolOOP);
  if (len >= sizeof (stringBuf))
    _gst_errorf ("symbol name too long: %d, max is %d", len,
		 sizeof (stringBuf));

  strncpy (stringBuf, symbol->symString, len);
  stringBuf[len] = '\0';
  return (stringBuf);
}



void
_gst_check_symbol_chain (void)
{
  unsigned long i;

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
  unsigned long i;

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
  gst_uchar *bytes;
  int numArgs, len;

  len = _gst_string_oop_len (symbolOOP);
  bytes = (gst_uchar *) (OOP_TO_OBJ (symbolOOP)->data);
  if (bytes[0] < 'A' || bytes[0] > 'z')
    return (1);

  if (bytes[0] > 'Z' && bytes[0] < 'a')
    return (1);

  for (numArgs = 0; len;)
    {
      if (bytes[--len] == ':')
	{
	  numArgs++;
	}
    }
  return (numArgs);
}


void
_gst_init_symbols (void)
{
  const symbol_info *si;

  for (si = sym_info; si->symbolVar; si++)
    *si->symbolVar = _gst_intern_string (si->value);
}

