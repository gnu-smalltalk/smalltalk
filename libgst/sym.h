/******************************** -*- C -*- ****************************
 *
 *	Symbol Table declarations
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
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


#ifndef GST_SYM_H
#define GST_SYM_H

#define SYMBOL_TABLE_SIZE	512

typedef enum
{
  SCOPE_TEMPORARY,
  SCOPE_RECEIVER,
  SCOPE_GLOBAL,
  SCOPE_SPECIAL
}
scope_type;

typedef struct gst_symbol
{
  OBJ_HEADER;			/* I love inheritance */
  char symString[1];
}
 *gst_symbol;

typedef struct symbol_entry
{
  scope_type scope;
  OOP symbol;
  mst_Boolean readOnly;
  int varIndex;			/* index of receiver or temporary */
  unsigned int scopeDistance;	/* how many frames up the stack is this
				   variable from where we are? */
}
symbol_entry;

/* True if undeclared globals can be considered forward references.  */
extern long _gst_use_undeclared;

extern OOP _gst_and_colon_symbol, _gst_at_colon_put_colon_symbol,
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

/* This walks the list of scopes and of symbols defined for each scope,
   looking for a variable represented by the tree LIST.  Then it looks in
   the instance variables, then in the class variables, and then in the
   pool dictionaries (starting from those declared in the class and going
   up in the hierarchy).

   If the variable is not found anywhere but starts with an uppercase letter,
   it is declared in the Undeclared dictionary and the methods will be fixed
   automatically as soon as it is defined (if it is).

   True is returned, and SE is filled with the information about the
   variable if it is found or it is deemed part of Undeclared.  Else,
   SE is untouched and FALSE is returned. */
extern mst_Boolean _gst_find_variable (symbol_entry * se,
				       tree_node list) ATTRIBUTE_PURE;

/* This converts a C string to a symbol and stores it in the symbol
   table. */
extern OOP _gst_intern_string (const char *str) ATTRIBUTE_PURE;

/* This makes an Array with an element for each instance variable
   declared in VARIABLESTRING, plus those inherited from
   SUPERCLASSOOP. */
extern OOP _gst_make_instance_variable_array (OOP superclassOOP,
					      gst_uchar * variableString);

/* This makes a BindingDictionary whose keys are the class variables
   declared in VARIABLENAMES.  The environment of the dictionary is
   classOOP.  */
extern OOP _gst_make_class_variable_dictionary (gst_uchar * variableNames,
						OOP classOOP);

/* This makes an Array whose elements are the pool dictionaries
   declared in POOLNAMES. */
extern OOP _gst_make_pool_array (gst_uchar * poolNames);

/* This resolves to an Association the variable binding constant expressed
   by the LIST parse tree node. */
extern OOP _gst_find_variable_binding (tree_node list) ATTRIBUTE_PURE;

/* This converts the Smalltalk String STRINGOOP into a Symbol and
   return the converted Symbol. */
extern OOP _gst_intern_string_oop (OOP stringOOP) ATTRIBUTE_PURE;

/* Given a symbol, this routine returns a C string that corresponds to the
   name of the symbol.  The returned value is a pointer to a static area,
   so if it's to be used for anything other than immediate output, the
   caller needs to make a copy of the retured string. */
extern char *_gst_symbol_as_string (OOP symbolOOP);

/* This computes an hash of LEN bytes, starting at STR. */
extern unsigned long _gst_hash_string (const char *str,
				       int len) ATTRIBUTE_PURE;

/* This computes the length of a String object OOP. */
extern int _gst_string_oop_len (OOP oop) ATTRIBUTE_PURE;

/* This returns the number of arguments declared in the current
   scope. */
extern int _gst_get_arg_count (void) ATTRIBUTE_PURE;

/* This returns the number of temporaries declared in the current
   scope. */
extern int _gst_get_temp_count (void) ATTRIBUTE_PURE;

/* This adds the arguments corresponding to the message declaration in
   ARGS to the list of arguments in the current scope.  Note that this
   handles unary, binary and keyword expressions.  Arguments must be
   declared before temporaries, so this resets the number of
   temporaries in the current scope to 0 and absorbs any temporaries
   into the arguments.  The number of arguments is returned. */
extern int _gst_declare_arguments (tree_node args);

/* This adds the declarations in TEMPS to the list of arguments
   in the current scope. */
extern int _gst_declare_temporaries (tree_node temps);

/* This adds the arguments corresponding to the message declaration in
   ARGS to the list of arguments in the current scope.  Note that this
   does not handle unary, binary and keyword expressions, but only
   blocks.  Arguments must be declared before temporaries, so this
   resets the number of temporaries in the current scope to 0 and
   absorbs any temporaries into the arguments.  The number of
   arguments is returned. */
extern int _gst_declare_block_arguments (tree_node args);

/* Declare the argument or temporary variable whose name is pointed to
   by NAME as either WRITEABLE or not.  A Symbol corresponding to NAME
   is created and links a new entry inside the symbol list for the
   currently active scope.  Returns the index of the variable into the
   stack frame. */
extern int _gst_declare_name (const char *name,
			      mst_Boolean writeable);

/* Computes the number of selectors that a message named SYMBOLOOP
   expects. */
extern int _gst_selector_num_args (OOP symbolOOP) ATTRIBUTE_PURE;

/* This removes from the current scope the knowledge of the last
   declared temporary variable. */
extern void _gst_undeclare_name (void);

/* This adds a new scope (corresponding to a level of block nesting)
   to the linked list of scopes. */
extern void _gst_push_new_scope (void);

/* This removes the outermost scope (corresponding to a level of block
   nesting) to the linked list of scopes. */
extern void _gst_pop_old_scope (void);

/* This frees the whole linked list of scopes. */
extern void _gst_pop_all_scopes (void);

/* For debugging purposes, this prints the declaration of ENT. */
extern void _gst_print_symbol_entry (symbol_entry * ent);

/* This routine is used for symbol table debugging only. */
extern void _gst_print_symbols (void);

/* This routine initializes the variables containing the Symbols
   known to the VM. */
extern void _gst_init_symbols (void);

#ifdef HAVE_READLINE
extern void _gst_add_all_symbol_completions (void);
#endif

#endif /* GST_SYM_H */
