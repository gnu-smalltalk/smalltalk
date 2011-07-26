/******************************** -*- C -*- ****************************
 *
 *	Symbol Table declarations
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006,2008
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

typedef struct scope *scope;
typedef struct pool_list *pool_list;

/* Establish a new dictionary that will host local variables of the
   evaluations; return the old one.  */
extern OOP _gst_push_temporaries_dictionary (void)
  ATTRIBUTE_HIDDEN;

/* Switch back to a previously used dictionary to host local variables of the
   evaluations.  */
extern void _gst_pop_temporaries_dictionary (OOP dictionaryOOP)
  ATTRIBUTE_HIDDEN;

extern OOP _gst_and_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_as_scaled_decimal_radix_scale_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_bad_return_error_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_boolean_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_byte_array_out_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_byte_array_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_c_object_ptr_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_c_object_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_category_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_char_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_does_not_understand_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_double_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_false_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_float_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_if_false_if_true_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_if_false_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_if_true_if_false_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_if_true_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_int_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_long_double_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_long_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_must_be_boolean_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_nil_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_or_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_permission_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_primitive_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_repeat_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_self_smalltalk_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_self_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_short_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_ushort_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_smalltalk_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_smalltalk_namespace_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_start_execution_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_string_out_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_string_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_super_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_symbol_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_symbol_out_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_terminate_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_this_context_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_times_repeat_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_to_by_do_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_to_do_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_true_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_uchar_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_uint_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_ulong_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_undeclared_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_unknown_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_value_with_rec_with_args_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_variadic_smalltalk_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_variadic_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_vm_primitives_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_void_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_wchar_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_wstring_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_wstring_out_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_while_false_colon_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_while_false_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_while_true_colon_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_while_true_symbol ATTRIBUTE_HIDDEN;
extern OOP _gst_symbol_table ATTRIBUTE_HIDDEN;
extern OOP _gst_current_namespace ATTRIBUTE_HIDDEN;

/* This returns the name of the given scope (instance variable, temporary, ...). */
extern const char *_gst_get_scope_kind (scope_type scope)
  ATTRIBUTE_CONST
  ATTRIBUTE_HIDDEN;

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
   SE is untouched and FALSE is returned.  */
extern mst_Boolean _gst_find_variable (symbol_entry * se,
				       tree_node list)
  ATTRIBUTE_HIDDEN;

/* Compute linearized pool order for PARSER.  If FORDOIT is true,
   temporarily use the parser's current namespace instead of the environment
   of the compilation class.  */
struct gst_parser;
extern void _gst_compute_linearized_pools (struct gst_parser *parser,
                                           mst_Boolean forDoit)
  ATTRIBUTE_HIDDEN;

/* Free linearized pool order that was computed last.  */
extern void _gst_free_linearized_pools (void)
  ATTRIBUTE_HIDDEN;

/* This converts a C string to a symbol and stores it in the symbol
   table.  */
extern OOP _gst_intern_string (const char *str)
  ATTRIBUTE_HIDDEN;

/* This makes an Array with an element for each instance variable
   declared in VARIABLESTRING, plus those inherited from
   SUPERCLASSOOP.  */
extern OOP _gst_make_instance_variable_array (OOP superclassOOP,
					      const char * variableString)
  ATTRIBUTE_HIDDEN;

/* This makes a BindingDictionary whose keys are the class variables
   declared in VARIABLENAMES.  The environment of the dictionary is
   classOOP.  */
extern OOP _gst_make_class_variable_dictionary (const char * variableNames,
						OOP classOOP)
  ATTRIBUTE_HIDDEN;

/* This makes an Array whose elements are the pool dictionaries
   declared in POOLNAMES.  */
extern OOP _gst_make_pool_array (const char * poolNames)
  ATTRIBUTE_HIDDEN;

/* This resolves the variable binding constant expressed by the LIST parse
   tree node.  Unless DECLARE_TEMPORARY is false, temporary variables
   may be automatically declared.  */
extern tree_node _gst_find_variable_binding (tree_node list)
  ATTRIBUTE_HIDDEN;

/* This returns the dictionary in which to define an undeclared variable
   binding.  */
extern OOP _gst_get_undeclared_dictionary ()
  ATTRIBUTE_PURE
  ATTRIBUTE_HIDDEN;

/* This converts the Smalltalk String STRINGOOP into a Symbol and
   return the converted Symbol.  */
extern OOP _gst_intern_string_oop (OOP stringOOP)
  ATTRIBUTE_HIDDEN;

/* This computes an hash of LEN bytes, starting at STR.  */
extern uintptr_t _gst_hash_string (const char *str,
				   int len)
  ATTRIBUTE_PURE
  ATTRIBUTE_HIDDEN;

/* This computes the length of a String object OOP.  */
extern int _gst_string_oop_len (OOP oop)
  ATTRIBUTE_PURE
  ATTRIBUTE_HIDDEN;

/* This returns the number of arguments declared in the current
   scope.  */
extern int _gst_get_arg_count (void)
  ATTRIBUTE_PURE
  ATTRIBUTE_HIDDEN;

/* This returns the number of temporaries declared in the current
   scope.  */
extern int _gst_get_temp_count (void)
  ATTRIBUTE_PURE
  ATTRIBUTE_HIDDEN;

/* This adds the arguments corresponding to the message declaration in
   ARGS to the list of arguments in the current scope.  Note that this
   handles unary, binary and keyword expressions.  Arguments must be
   declared before temporaries, so this resets the number of
   temporaries in the current scope to 0 and absorbs any temporaries
   into the arguments.  The number of arguments is returned.  */
extern int _gst_declare_arguments (tree_node args)
  ATTRIBUTE_HIDDEN;

/* This adds the declarations in TEMPS to the list of arguments
   in the current scope.  */
extern int _gst_declare_temporaries (tree_node temps)
  ATTRIBUTE_HIDDEN;

/* This adds the arguments corresponding to the message declaration in
   ARGS to the list of arguments in the current scope.  Note that this
   does not handle unary, binary and keyword expressions, but only
   blocks.  Arguments must be declared before temporaries, so this
   resets the number of temporaries in the current scope to 0 and
   absorbs any temporaries into the arguments.  The number of
   arguments is returned.  */
extern int _gst_declare_block_arguments (tree_node args)
  ATTRIBUTE_HIDDEN;

/* Declare the argument or temporary variable whose name is pointed to
   by NAME as either WRITEABLE or not.  A Symbol corresponding to NAME
   is created and links a new entry inside the symbol list for the
   currently active scope.  Unless ALLOWDUP is true, search for a
   variable with the same name in the currently active scope and return
   -1 if one is found; otherwise, return the index of the variable into
   the activation record.  */
extern int _gst_declare_name (const char *name,
			      mst_Boolean writeable,
			      mst_Boolean allowDup)
  ATTRIBUTE_HIDDEN;

/* Computes the number of arguments that a message named SYMBOLOOP
   expects.  */
extern int _gst_selector_num_args (OOP symbolOOP)
  ATTRIBUTE_PURE
  ATTRIBUTE_HIDDEN;

/* This removes from the current scope the knowledge of the last
   declared temporary variable.  */
extern void _gst_undeclare_name (void)
  ATTRIBUTE_HIDDEN;

/* This adds a new scope (corresponding to a level of block nesting)
   to the linked list of scopes.  */
extern void _gst_push_new_scope (void)
  ATTRIBUTE_HIDDEN;

/* Convert a lightweight class (instance of Behavior) or a Metaclass
   into the corresponding Class object.  */
extern OOP _gst_get_class_object (OOP classOOP)
  ATTRIBUTE_HIDDEN;

/* Find a pragma handler for the given selector into the class and its
   superclasses.  */
extern OOP _gst_find_pragma_handler (OOP classOOP, OOP symbolOOP)
  ATTRIBUTE_HIDDEN;

/* This removes the outermost scope (corresponding to a level of block
   nesting) to the linked list of scopes.  */
extern void _gst_pop_old_scope (void)
  ATTRIBUTE_HIDDEN;

/* This frees the whole linked list of scopes.  */
extern void _gst_pop_all_scopes (void)
  ATTRIBUTE_HIDDEN;

/* For debugging purposes, this prints the declaration of ENT.  */
extern void _gst_print_symbol_entry (symbol_entry * ent)
  ATTRIBUTE_HIDDEN;

/* This routine is used for symbol table debugging only.  */
extern void _gst_print_symbols (void)
  ATTRIBUTE_HIDDEN;

/* This routine initializes the variables containing the Symbols
   known to the VM.  This one creates the symbol OOPs, which have to
   be consecutive in order to speed up the load.  */
extern void _gst_init_symbols_pass1 (void)
  ATTRIBUTE_HIDDEN;

/* This one creates the SymLink OOPs for the Symbols previously
   created.  */
extern void _gst_init_symbols_pass2 (void)
  ATTRIBUTE_HIDDEN;

/* This routine reloads the variables containing the Symbols
   known to the VM.  It is invocated upon image load.  */
extern void _gst_restore_symbols (void)
  ATTRIBUTE_HIDDEN;


extern void _gst_check_symbol_chain (void)
  ATTRIBUTE_HIDDEN;

#ifdef HAVE_READLINE
extern void _gst_add_all_symbol_completions (void)
  ATTRIBUTE_HIDDEN;
#endif

struct builtin_selector {
  int offset;
  OOP symbol;
  int numArgs;
  int bytecode;
};

extern struct builtin_selector _gst_builtin_selectors[256]
  ATTRIBUTE_HIDDEN;

extern struct builtin_selector *_gst_lookup_builtin_selector (const char *str,
							      unsigned int len)
  ATTRIBUTE_HIDDEN;

#endif /* GST_SYM_H */
