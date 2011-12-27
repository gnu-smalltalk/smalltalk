/******************************** -*- C -*- ****************************
 *
 *	Dictionary Support Module.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006,2007,2008,2009
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


#include "gstpriv.h"

/* this must be big enough that the Smalltalk dictionary does not have to
   grow between the time gst_dictionary is loaded and the time the kernel is
   initialized.  Otherwise some of the methods needed to grow the dictionary
   might not be defined yet!!  */
#define INITIAL_SMALLTALK_SIZE		512

typedef struct class_definition
{
  OOP *classVar;
  OOP *superClassPtr;
  intptr_t instanceSpec;
  mst_Boolean reloadAddress;
  int numFixedFields;
  const char *name;
  const char *instVarNames;
  const char *classVarNames;
  const char *sharedPoolNames;
}
class_definition;

/* Primary class variables.  These variables hold the class objects for
   most of the builtin classes in the system */
OOP _gst_abstract_namespace_class = NULL;
OOP _gst_array_class = NULL;
OOP _gst_arrayed_collection_class = NULL;
OOP _gst_association_class = NULL;
OOP _gst_behavior_class = NULL;
OOP _gst_binding_dictionary_class = NULL;
OOP _gst_block_closure_class = NULL;
OOP _gst_block_context_class = NULL;
OOP _gst_boolean_class = NULL;
OOP _gst_byte_array_class = NULL;
OOP _gst_c_callable_class = NULL;
OOP _gst_c_callback_descriptor_class = NULL;
OOP _gst_c_func_descriptor_class = NULL;
OOP _gst_c_object_class = NULL;
OOP _gst_c_type_class = NULL;
OOP _gst_callin_process_class = NULL;
OOP _gst_char_class = NULL;
OOP _gst_character_array_class = NULL;
OOP _gst_class_class = NULL;
OOP _gst_class_description_class = NULL;
OOP _gst_collection_class = NULL;
OOP _gst_compiled_block_class = NULL;
OOP _gst_compiled_code_class = NULL;
OOP _gst_compiled_method_class = NULL;
OOP _gst_context_part_class = NULL;
OOP _gst_continuation_class = NULL;
OOP _gst_date_class = NULL;
OOP _gst_deferred_variable_binding_class = NULL;
OOP _gst_dictionary_class = NULL;
OOP _gst_directed_message_class = NULL;
OOP _gst_message_lookup_class = NULL;
OOP _gst_false_class = NULL;
OOP _gst_file_descriptor_class = NULL;
OOP _gst_file_segment_class = NULL;
OOP _gst_file_stream_class = NULL;
OOP _gst_float_class = NULL;
OOP _gst_floatd_class = NULL;
OOP _gst_floate_class = NULL;
OOP _gst_floatq_class = NULL;
OOP _gst_fraction_class = NULL;
OOP _gst_hashed_collection_class = NULL;
OOP _gst_homed_association_class = NULL;
OOP _gst_identity_dictionary_class = NULL;
OOP _gst_identity_set_class = NULL;
OOP _gst_integer_class = NULL;
OOP _gst_interval_class = NULL;
OOP _gst_iterable_class = NULL;
OOP _gst_large_integer_class = NULL;
OOP _gst_large_negative_integer_class = NULL;
OOP _gst_large_positive_integer_class = NULL;
OOP _gst_large_zero_integer_class = NULL;
OOP _gst_link_class = NULL;
OOP _gst_linked_list_class = NULL;
OOP _gst_lookup_key_class = NULL;
OOP _gst_lookup_table_class = NULL;
OOP _gst_magnitude_class = NULL;
OOP _gst_memory_class = NULL;
OOP _gst_message_class = NULL;
OOP _gst_metaclass_class = NULL;
OOP _gst_method_context_class = NULL;
OOP _gst_method_dictionary_class = NULL;
OOP _gst_method_info_class = NULL;
OOP _gst_namespace_class = NULL;
OOP _gst_number_class = NULL;
OOP _gst_object_class = NULL;
OOP _gst_object_memory_class = NULL;
OOP _gst_ordered_collection_class = NULL;
OOP _gst_permission_class = NULL;
OOP _gst_positionable_stream_class = NULL;
OOP _gst_process_class = NULL;
OOP _gst_processor_scheduler_class = NULL;
OOP _gst_read_stream_class = NULL;
OOP _gst_read_write_stream_class = NULL;
OOP _gst_root_namespace_class = NULL;
OOP _gst_security_policy_class = NULL;
OOP _gst_semaphore_class = NULL;
OOP _gst_sequenceable_collection_class = NULL;
OOP _gst_set_class = NULL;
OOP _gst_small_integer_class = NULL;
OOP _gst_smalltalk_dictionary = NULL;
OOP _gst_sorted_collection_class = NULL;
OOP _gst_stream_class = NULL;
OOP _gst_string_class = NULL;
OOP _gst_sym_link_class = NULL;
OOP _gst_symbol_class = NULL;
OOP _gst_system_dictionary_class = NULL;
OOP _gst_time_class = NULL;
OOP _gst_true_class = NULL;
OOP _gst_undefined_object_class = NULL;
OOP _gst_unicode_character_class = NULL;
OOP _gst_unicode_string_class = NULL;
OOP _gst_variable_binding_class = NULL;
OOP _gst_weak_array_class = NULL;
OOP _gst_weak_set_class = NULL;
OOP _gst_weak_key_dictionary_class = NULL;
OOP _gst_weak_value_lookup_table_class = NULL;
OOP _gst_weak_identity_set_class = NULL;
OOP _gst_weak_key_identity_dictionary_class = NULL;
OOP _gst_weak_value_identity_dictionary_class = NULL;
OOP _gst_write_stream_class = NULL;
OOP _gst_processor_oop = NULL;

/* Called when a dictionary becomes full, this routine replaces the
   dictionary instance that DICTIONARYOOP is pointing to with a new,
   larger dictionary, and returns this new dictionary (the object
   pointer, not the OOP).  */
static gst_object grow_dictionary (OOP dictionaryOOP) 
  ATTRIBUTE_HIDDEN;

/* Called when an IdentityDictionary becomes full, this routine
   replaces the IdentityDictionary instance that IDENTITYDICTIONARYOOP
   is pointing to with a new, larger dictionary, and returns this new
   dictionary (the object pointer, not the OOP).  */
static gst_object grow_identity_dictionary (OOP identityDictionaryOOP) 
  ATTRIBUTE_HIDDEN;

/* Answer the number of slots that are in a dictionary of
   OLDNUMFIELDS items after growing it.  */
static size_t new_num_fields (size_t oldNumFields);

/* Instantiate the OOPs that are created before the first classes
   (true, false, nil, the Smalltalk dictionary, the symbol table
   and Processor, the sole instance of ProcessorScheduler.  */
static void init_proto_oops (void);

/* Look for the index at which KEYOOP resides in IDENTITYDICTIONARYOOP
   and answer it or, if not found, answer -1.  */
static ssize_t identity_dictionary_find_key (OOP identityDictionaryOOP,
					     OOP keyOOP);

/* Look for the index at which KEYOOP resides in IDENTITYDICTIONARYOOP
   or, if not found, find a nil slot which can be replaced by that
   key.  */
static size_t identity_dictionary_find_key_or_nil (OOP identityDictionaryOOP,
						   OOP keyOOP);

/* assume the value is an integer already or key does not exist, increase the
   value by inc or set the value to inc */
static int _gst_identity_dictionary_at_inc (OOP identityDictionaryOOP,
                                            OOP keyOOP,
                                            int inc);

/* Create a new instance of CLASSOOP (an IdentityDictionary subclass)
   and answer it.  */
static OOP identity_dictionary_new (OOP classOOP,
				    int size);

/* Create a new instance of Namespace with the given SIZE, NAME and
   superspace (SUPERSPACEOOP).  */
static OOP namespace_new (int size,
			  const char *name,
			  OOP superspaceOOP);

/* Create new class whose instances have a shape defined by CI.  */
static void create_class (const class_definition *ci);

/* Create a new metaclass for CLASS_OOP; reserve space for NUMSUBCLASSES
   classes in the instance variable "subclasses" of the class, and for
   NUMMETACLASSSUBCLASSES in the instance variable "subclasses" of the
   metaclass.  */
static void create_metaclass (OOP class_oop,
			      int numSubClasses,
			      int numMetaclassSubClasses);

/* Finish initializing the metaclass METACLASSOOP.  */
static void init_metaclass (OOP metaclassOOP);

/* Finish initializing the class CLASSOOP, using information from CI.  */
static void init_class (OOP classOOP, const class_definition *ci);

/* This creates the SystemDictionary called Smalltalk and initializes
   some of the variables in it.  */
static void init_smalltalk_dictionary (void);

/* This fills MAP so that it associates primitive numbers in the saved
   image to primitive numbers in this VM.  */
static void prepare_primitive_numbers_table (void);

/* Add a global named GLOBALNAME and give it the value GLOBALVALUE.
   Return GLOBALVALUE.  */
static OOP add_smalltalk (const char *globalName,
			  OOP globalValue);

/* Create N class objects described in the array starting at CI,
   establishing the instance shape and the link between a class
   and its superclass.  */
static void create_classes_pass1 (const class_definition *ci,
				  int n);

/* Create the subclasses variable of the N classes described in the
   array starting at CI (which being an Array must be created after
   the class objects are stored in the global variables).  Also
   create the metaclass hierarchy and make the class objects point
   to it.  */
static void create_classes_pass2 (const class_definition *ci,
				  int n);

/* Add a subclass SUBCLASSOOP to the subclasses array of
   SUPERCLASSOOP.  Subclasses are stored from the last index to the
   first, and the first slot of the Array indicates the index of the
   last free slot.  */
static void add_subclass (OOP superClassOOP,
			  OOP subClassOOP);

/* Adds to Smalltalk a global named FILEOBJECTNAME which is a
   FileStream referring to file descriptor FD.  */
static void add_file_stream_object (int fd,
				    int access,
				    const char *fileObjectName);

/* Creates the Symbols that the VM knows about, and initializes
   the globals in the Smalltalk dictionary.  */
static void init_runtime_objects (void);

/* Creates the VMPrimitives dictionary, which maps primitive names
   to primitive numbers.  */
static void init_primitives_dictionary (void);

/* Creates the CSymbols pool dictionary, which gives access from
   Smalltalk to some definitions in float.h and config.h.  */
static void init_c_symbols (void);

static const char *feature_strings[] = {
#ifdef ENABLE_DLD
    "DLD",
#endif
  NULL
};



/* The class definition structure.  From this structure, the initial
   set of Smalltalk classes are defined.  */

static const class_definition class_info[] = {
  {&_gst_object_class, &_gst_nil_oop,
   GST_ISP_FIXED, true, 0,
   "Object", NULL, "Dependencies FinalizableObjects", "VMPrimitives" },

  {&_gst_object_memory_class, &_gst_object_class,
   GST_ISP_FIXED, true, 34,
   "ObjectMemory", "bytesPerOOP bytesPerOTE "
   "edenSize survSpaceSize oldSpaceSize fixedSpaceSize "
   "edenUsedBytes survSpaceUsedBytes oldSpaceUsedBytes "
   "fixedSpaceUsedBytes rememberedTableEntries "
   "numScavenges numGlobalGCs numCompactions numGrowths "
   "numOldOOPs numFixedOOPs numWeakOOPs numOTEs numFreeOTEs "
   "timeBetweenScavenges timeBetweenGlobalGCs timeBetweenGrowths "
   "timeToScavenge timeToCollect timeToCompact "
   "reclaimedBytesPerScavenge tenuredBytesPerScavenge "
   "reclaimedBytesPerGlobalGC reclaimedPercentPerScavenge "
   "allocFailures allocMatches allocSplits allocProbes", NULL, NULL },

  {&_gst_message_class, &_gst_object_class,
   GST_ISP_FIXED, true, 2,
   "Message", "selector args", NULL, NULL },

  {&_gst_directed_message_class, &_gst_message_class,
   GST_ISP_FIXED, false, 1,
   "DirectedMessage", "receiver", NULL, NULL },

  {&_gst_message_lookup_class, &_gst_message_class,
   GST_ISP_FIXED, true, 1,
   "MessageLookup", "startingClass", NULL, NULL },

  {&_gst_magnitude_class, &_gst_object_class,
   GST_ISP_FIXED, false, 0,
   "Magnitude", NULL, NULL, NULL },

  {&_gst_char_class, &_gst_magnitude_class,
   GST_ISP_FIXED, true, 1,
   "Character", "codePoint", "Table UpperTable LowerTable", NULL },

  {&_gst_unicode_character_class, &_gst_char_class,
   GST_ISP_FIXED, true, 0,
   "UnicodeCharacter", NULL, NULL, NULL },

  {&_gst_time_class, &_gst_magnitude_class,
   GST_ISP_FIXED, false, 1,
   "Time", "seconds",
   "SecondClockAdjustment ClockOnStartup ClockOnImageSave", NULL },

  {&_gst_date_class, &_gst_magnitude_class,
   GST_ISP_FIXED, false, 4,
   "Date", "days day month year",
   "DayNameDict MonthNameDict", NULL },

  {&_gst_number_class, &_gst_magnitude_class,
   GST_ISP_FIXED, false, 0,
   "Number", NULL, NULL, NULL },

  {&_gst_float_class, &_gst_number_class,
   GST_ISP_UCHAR, true, 0,
   "Float", NULL, NULL, "CSymbols" },

  {&_gst_floatd_class, &_gst_float_class,
   GST_ISP_UCHAR, true, 0,
   "FloatD", NULL, NULL, "CSymbols" },

  {&_gst_floate_class, &_gst_float_class,
   GST_ISP_UCHAR, true, 0,
   "FloatE", NULL, NULL, "CSymbols" },

  {&_gst_floatq_class, &_gst_float_class,
   GST_ISP_UCHAR, true, 0,
   "FloatQ", NULL, NULL, "CSymbols" },

  {&_gst_fraction_class, &_gst_number_class,
   GST_ISP_FIXED, false, 2,
   "Fraction", "numerator denominator", "Zero One", NULL },

  {&_gst_integer_class, &_gst_number_class,
   GST_ISP_FIXED, true, 0,
   "Integer", NULL, NULL, "CSymbols" },

  {&_gst_small_integer_class, &_gst_integer_class,
   GST_ISP_FIXED, true, 0,
   "SmallInteger", NULL, NULL, NULL },

  {&_gst_large_integer_class, &_gst_integer_class,	/* these four
							   classes
							   added by */
   GST_ISP_UCHAR, true, 0,	/* pb Sep 10 18:06:49 1998 */
   "LargeInteger", NULL,
   "Zero One ZeroBytes OneBytes LeadingZeros TrailingZeros", NULL },

  {&_gst_large_positive_integer_class, &_gst_large_integer_class,
   GST_ISP_UCHAR, true, 0,
   "LargePositiveInteger", NULL, NULL, NULL },

  {&_gst_large_zero_integer_class, &_gst_large_positive_integer_class,
   GST_ISP_UCHAR, true, 0,
   "LargeZeroInteger", NULL, NULL, NULL },

  {&_gst_large_negative_integer_class, &_gst_large_integer_class,
   GST_ISP_UCHAR, true, 0,
   "LargeNegativeInteger", NULL, NULL, NULL },

  {&_gst_lookup_key_class, &_gst_magnitude_class,
   GST_ISP_FIXED, true, 1,
   "LookupKey", "key", NULL, NULL },

  {&_gst_deferred_variable_binding_class, &_gst_lookup_key_class,
   GST_ISP_FIXED, true, 4,
   "DeferredVariableBinding", "class defaultDictionary association path",
   NULL, NULL },

  {&_gst_association_class, &_gst_lookup_key_class,
   GST_ISP_FIXED, true, 1,
   "Association", "value", NULL, NULL },

  {&_gst_homed_association_class, &_gst_association_class,
   GST_ISP_FIXED, false, 1,
   "HomedAssociation", "environment", NULL, NULL },

  {&_gst_variable_binding_class, &_gst_homed_association_class,
   GST_ISP_FIXED, true, 0,
   "VariableBinding", NULL, NULL, NULL },

  {&_gst_link_class, &_gst_object_class,
   GST_ISP_FIXED, false, 1,
   "Link", "nextLink", NULL, NULL },

  {&_gst_process_class, &_gst_link_class,
   GST_ISP_FIXED, true, 7,
   "Process",
   "suspendedContext priority myList name environment interrupts interruptLock",
   NULL, NULL },

  {&_gst_callin_process_class, &_gst_process_class,
   GST_ISP_FIXED, true, 1,
   "CallinProcess",
   "returnedValue",
   NULL, NULL },

  {&_gst_sym_link_class, &_gst_link_class,
   GST_ISP_FIXED, true, 1,
   "SymLink", "symbol", NULL, NULL },

  {&_gst_iterable_class, &_gst_object_class,
   GST_ISP_FIXED, false, 0,
   "Iterable", NULL, NULL, NULL },

  {&_gst_collection_class, &_gst_iterable_class,
   GST_ISP_FIXED, false, 0,
   "Collection", NULL, NULL, NULL },

  {&_gst_sequenceable_collection_class, &_gst_collection_class,
   GST_ISP_FIXED, false, 0,
   "SequenceableCollection", NULL, NULL, NULL },

  {&_gst_linked_list_class, &_gst_sequenceable_collection_class,
   GST_ISP_FIXED, false, 2,
   "LinkedList", "firstLink lastLink", NULL, NULL },

  {&_gst_semaphore_class, &_gst_linked_list_class,
   GST_ISP_FIXED, true, 2,
   "Semaphore", "signals name", NULL, NULL },

  {&_gst_arrayed_collection_class, &_gst_sequenceable_collection_class,
   GST_ISP_POINTER, false, 0,
   "ArrayedCollection", NULL, NULL, NULL },

  {&_gst_array_class, &_gst_arrayed_collection_class,
   GST_ISP_POINTER, true, 0,
   "Array", NULL, NULL, NULL },

  {&_gst_weak_array_class, &_gst_array_class,
   GST_ISP_FIXED, false, 2,
   "WeakArray", "values nilValues", NULL, NULL },

  {&_gst_character_array_class, &_gst_arrayed_collection_class,
   GST_ISP_ULONG, false, 0,
   "CharacterArray", NULL, NULL, NULL },

  {&_gst_string_class, &_gst_character_array_class,
   GST_ISP_CHARACTER, true, 0,
   "String", NULL, NULL, NULL },

  {&_gst_unicode_string_class, &_gst_character_array_class,
   GST_ISP_UTF32, true, 0,
   "UnicodeString", NULL, NULL, NULL },

  {&_gst_symbol_class, &_gst_string_class,
   GST_ISP_CHARACTER, true, 0,
   "Symbol", NULL, NULL, NULL },

  {&_gst_byte_array_class, &_gst_arrayed_collection_class,
   GST_ISP_UCHAR, true, 0,
   "ByteArray", NULL, NULL, "CSymbols" },

  {&_gst_compiled_code_class, &_gst_arrayed_collection_class,
   GST_ISP_UCHAR, false, 2,
   "CompiledCode", "literals header",
   NULL, NULL },

  {&_gst_compiled_block_class, &_gst_compiled_code_class,
   GST_ISP_UCHAR, true, 1,
   "CompiledBlock", "method",
   NULL, NULL },

  {&_gst_compiled_method_class, &_gst_compiled_code_class,
   GST_ISP_UCHAR, true, 1,
   "CompiledMethod", "descriptor ",
   NULL, NULL },

  {&_gst_interval_class, &_gst_arrayed_collection_class,
   GST_ISP_FIXED, true, 3,
   "Interval", "start stop step", NULL, NULL },

  {&_gst_ordered_collection_class, &_gst_sequenceable_collection_class,
   GST_ISP_POINTER, false, 2,
   "OrderedCollection", "firstIndex lastIndex", NULL, NULL },

  {&_gst_sorted_collection_class, &_gst_ordered_collection_class,
   GST_ISP_POINTER, false, 3,
   "SortedCollection", "lastOrdered sorted sortBlock",
   "DefaultSortBlock",
   NULL },

  {&_gst_hashed_collection_class, &_gst_collection_class,
   GST_ISP_POINTER, false, 1,
   "HashedCollection", "tally", NULL, NULL },

  {&_gst_set_class, &_gst_hashed_collection_class,
   GST_ISP_POINTER, false, 0,
   "Set", NULL, NULL, NULL },

  {&_gst_weak_set_class, &_gst_set_class,
   GST_ISP_POINTER, false, 0,
   "WeakSet", NULL, NULL, NULL },

  {&_gst_identity_set_class, &_gst_set_class,
   GST_ISP_POINTER, false, 0,
   "IdentitySet", NULL, NULL, NULL },

  {&_gst_weak_identity_set_class, &_gst_weak_set_class,
   GST_ISP_POINTER, false, 0,
   "WeakIdentitySet", NULL, NULL, NULL },

  {&_gst_dictionary_class, &_gst_hashed_collection_class,
   GST_ISP_POINTER, true, 0,
   "Dictionary", NULL, NULL, NULL },

  {&_gst_weak_key_dictionary_class, &_gst_dictionary_class,
   GST_ISP_POINTER, false, 1,
   "WeakKeyDictionary", "keys", NULL, NULL },

  {&_gst_weak_key_identity_dictionary_class, &_gst_weak_key_dictionary_class,
   GST_ISP_POINTER, false, 0,
   "WeakKeyIdentityDictionary", NULL, NULL, NULL },

  {&_gst_lookup_table_class, &_gst_dictionary_class,
   GST_ISP_POINTER, false, 0,
   "LookupTable", NULL, NULL, NULL },

  {&_gst_weak_value_lookup_table_class, &_gst_lookup_table_class,
   GST_ISP_POINTER, false, 1,
   "WeakValueLookupTable", "values", NULL, NULL },

  {&_gst_weak_value_identity_dictionary_class, &_gst_weak_value_lookup_table_class,
   GST_ISP_POINTER, false, 0,
   "WeakValueIdentityDictionary", NULL, NULL, NULL },

  {&_gst_identity_dictionary_class, &_gst_lookup_table_class,
   GST_ISP_POINTER, true, 0,
   "IdentityDictionary", NULL, NULL, NULL },

  {&_gst_method_dictionary_class, &_gst_identity_dictionary_class,
   GST_ISP_POINTER, true, 1,
   "MethodDictionary", "mutex", NULL, NULL },

  /* These five MUST have the same structure as dictionary; they're
     used interchangeably within the C portion of the system */
  {&_gst_binding_dictionary_class, &_gst_dictionary_class,
   GST_ISP_POINTER, true, 1,
   "BindingDictionary", "environment", NULL, NULL },

  {&_gst_abstract_namespace_class, &_gst_binding_dictionary_class,
   GST_ISP_POINTER, true, 3,
   "AbstractNamespace", "name subspaces sharedPools", NULL, NULL },

  {&_gst_root_namespace_class, &_gst_abstract_namespace_class,
   GST_ISP_POINTER, false, 0,
   "RootNamespace", NULL, NULL, NULL },

  {&_gst_namespace_class, &_gst_abstract_namespace_class,
   GST_ISP_POINTER, true, 0,
   "Namespace", NULL, "Current", NULL },

  {&_gst_system_dictionary_class, &_gst_root_namespace_class,
   GST_ISP_POINTER, false, 0,
   "SystemDictionary", NULL, NULL, NULL },

  {&_gst_stream_class, &_gst_iterable_class,
   GST_ISP_FIXED, false, 0,
   "Stream", NULL, NULL, NULL },

  {&_gst_positionable_stream_class, &_gst_stream_class,
   GST_ISP_FIXED, false, 4,
   "PositionableStream", "collection ptr endPtr access", NULL, NULL },

  {&_gst_read_stream_class, &_gst_positionable_stream_class,
   GST_ISP_FIXED, false, 0,
   "ReadStream", NULL, NULL, NULL },

  {&_gst_write_stream_class, &_gst_positionable_stream_class,
   GST_ISP_FIXED, false, 0,
   "WriteStream", NULL, NULL, NULL },

  {&_gst_read_write_stream_class, &_gst_write_stream_class,
   GST_ISP_FIXED, false, 0,
   "ReadWriteStream", NULL, NULL, NULL },

  {&_gst_file_descriptor_class, &_gst_stream_class,
   GST_ISP_FIXED, true, 6,
   "FileDescriptor", "access fd file isPipe atEnd peek", "AllOpenFiles", NULL },

  {&_gst_file_stream_class, &_gst_file_descriptor_class,
   GST_ISP_FIXED, true, 5,
   "FileStream", "collection ptr endPtr writePtr writeEnd", "Verbose Record Includes", NULL },

  {&_gst_undefined_object_class, &_gst_object_class,
   GST_ISP_FIXED, true, 0,
   "UndefinedObject", NULL, NULL, "Smalltalk" },

  {&_gst_boolean_class, &_gst_object_class,
   GST_ISP_FIXED, true, 0,
   "Boolean", NULL, NULL, NULL },

  {&_gst_false_class, &_gst_boolean_class,
   GST_ISP_FIXED, true, 1,
   "False", "truthValue", NULL, NULL },

  {&_gst_true_class, &_gst_boolean_class,
   GST_ISP_FIXED, true, 1,
   "True", "truthValue", NULL, NULL },

  {&_gst_processor_scheduler_class, &_gst_object_class,
   GST_ISP_FIXED, false, 7,
   "ProcessorScheduler",
   "processLists activeProcess idleTasks processTimeslice gcSemaphore gcArray "
   "eventSemaphore",
   NULL, NULL },

  /* Change this, classDescription, or gst_class, and you must change
     the implementaion of new_metaclass some */
  {&_gst_behavior_class, &_gst_object_class,
   GST_ISP_FIXED, true, 5,
   "Behavior",
   "superClass methodDictionary instanceSpec subClasses instanceVariables",
   NULL, NULL },

  {&_gst_class_description_class, &_gst_behavior_class,
   GST_ISP_FIXED, true, 0,
   "ClassDescription", NULL, NULL, NULL },

  {&_gst_class_class, &_gst_class_description_class,
   GST_ISP_FIXED, true, 8,
   "Class",
   "name comment category environment classVariables sharedPools "
   "securityPolicy pragmaHandlers",
   NULL, NULL },

  {&_gst_metaclass_class, &_gst_class_description_class,
   GST_ISP_FIXED, true, 1,
   "Metaclass", "instanceClass", NULL, NULL },

  {&_gst_context_part_class, &_gst_object_class,
   GST_ISP_POINTER, true, 6,
   "ContextPart", "parent nativeIP ip sp receiver method ",
   NULL, NULL },

  {&_gst_method_context_class, &_gst_context_part_class,
   GST_ISP_POINTER, true, 1,
   "MethodContext", "flags ", NULL, NULL },

  {&_gst_block_context_class, &_gst_context_part_class,
   GST_ISP_POINTER, true, 1,
   "BlockContext", "outerContext ", NULL, NULL },

  {&_gst_continuation_class, &_gst_object_class,
   GST_ISP_FIXED, true, 1,
   "Continuation", "stack ", NULL, NULL },

  {&_gst_block_closure_class, &_gst_object_class,
   GST_ISP_FIXED, true, 3,
   "BlockClosure", "outerContext block receiver", NULL, NULL },

  {&_gst_permission_class, &_gst_object_class,
   GST_ISP_FIXED, true, 4,
   "Permission", "name actions target positive", NULL, NULL },

  {&_gst_security_policy_class, &_gst_object_class,
   GST_ISP_FIXED, true, 2,
   "SecurityPolicy", "dictionary owner", NULL, NULL },

  {&_gst_c_object_class, &_gst_object_class,
   GST_ISP_ULONG, true, 2,
   "CObject", "type storage", NULL, "CSymbols" },

  {&_gst_c_type_class, &_gst_object_class,
   GST_ISP_FIXED, true, 1,
   "CType", "cObjectType", NULL, NULL },

  {&_gst_c_callable_class, &_gst_c_object_class,
   GST_ISP_ULONG, true, 2,
   "CCallable",
   "returnType argTypes",
   NULL, NULL },

  {&_gst_c_func_descriptor_class, &_gst_c_callable_class,
   GST_ISP_ULONG, false, 1,
   "CFunctionDescriptor",
   "cFunctionName",
   NULL, NULL },

  {&_gst_c_callback_descriptor_class, &_gst_c_callable_class,
   GST_ISP_ULONG, true, 1,
   "CCallbackDescriptor",
   "block",
   NULL, NULL },

  {&_gst_memory_class, &_gst_object_class,
   GST_ISP_FIXED, false, 0,
   "Memory", NULL, NULL, NULL },

  {&_gst_method_info_class, &_gst_object_class,
   GST_ISP_POINTER, true, 4,
   "MethodInfo", "sourceCode category class selector", NULL, NULL },

  {&_gst_file_segment_class, &_gst_object_class,
   GST_ISP_FIXED, true, 3,
   "FileSegment", "file startPos size", NULL, NULL }

/* Classes not defined here (like Point/Rectangle/RunArray) are
   defined after the kernel has been fully initialized.  */
};

signed char _gst_log2_sizes[32] = {
  0, -1, 0, -1, 0, -1,
  1, -1, 1, -1, 
  2, -1, 2, -1, 2, -1, 
  3, -1, 3, -1, 3, -1,
  2, -1,
  -1, -1, -1, -1, -1, -1,
  sizeof (long) == 4 ? 2 : 3, -1
};





void
init_proto_oops()
{
  gst_namespace smalltalkDictionary;
  gst_object symbolTable, processorScheduler;
  int numWords;

  /* We can do this now that the classes are defined */
  _gst_init_builtin_objects_classes ();

  /* Also finish the creation of the OOPs with reserved indices in
     oop.h */

  /* the symbol table ...  */
  numWords = OBJ_HEADER_SIZE_WORDS + SYMBOL_TABLE_SIZE;
  symbolTable = _gst_alloc_words (numWords);
  SET_OOP_OBJECT (_gst_symbol_table, symbolTable);

  symbolTable->objClass = _gst_array_class;
  nil_fill (symbolTable->data,
	    numWords - OBJ_HEADER_SIZE_WORDS);

  /* 5 is the # of fixed instvars in gst_namespace */
  numWords = OBJ_HEADER_SIZE_WORDS + INITIAL_SMALLTALK_SIZE + 5;

  /* ... now the Smalltalk dictionary ...  */
  smalltalkDictionary = (gst_namespace) _gst_alloc_words (numWords);
  SET_OOP_OBJECT (_gst_smalltalk_dictionary, smalltalkDictionary);

  smalltalkDictionary->objClass = _gst_system_dictionary_class;
  smalltalkDictionary->tally = FROM_INT(0);
  smalltalkDictionary->name = _gst_smalltalk_namespace_symbol;
  smalltalkDictionary->superspace = _gst_nil_oop;
  smalltalkDictionary->subspaces = _gst_nil_oop;
  smalltalkDictionary->sharedPools = _gst_nil_oop;
  nil_fill (smalltalkDictionary->assoc,
	    INITIAL_SMALLTALK_SIZE);

  /* ... and finally Processor */
  numWords = sizeof (struct gst_processor_scheduler) / sizeof (PTR);
  processorScheduler = _gst_alloc_words (numWords);
  SET_OOP_OBJECT (_gst_processor_oop, processorScheduler);

  processorScheduler->objClass = _gst_processor_scheduler_class;
  nil_fill (processorScheduler->data,
	    numWords - OBJ_HEADER_SIZE_WORDS);
}

void
_gst_init_dictionary (void)
{
  memcpy (_gst_primitive_table, _gst_default_primitive_table,
          sizeof (_gst_primitive_table));

  /* The order of this must match the indices defined in oop.h!! */
  _gst_smalltalk_dictionary = alloc_oop (NULL, _gst_mem.active_flag);
  _gst_processor_oop = alloc_oop (NULL, _gst_mem.active_flag);
  _gst_symbol_table = alloc_oop (NULL, _gst_mem.active_flag);

  _gst_init_symbols_pass1 ();

  create_classes_pass1 (class_info, sizeof (class_info) / sizeof (class_info[0]));

  init_proto_oops();
  _gst_init_symbols_pass2 ();
  init_smalltalk_dictionary ();

  create_classes_pass2 (class_info, sizeof (class_info) / sizeof (class_info[0]));

  init_runtime_objects ();
  _gst_tenure_all_survivors ();
}

void
create_classes_pass1 (const class_definition *ci,
		      int n)
{
  OOP superClassOOP;
  int nilSubclasses;
  gst_class classObj, superclass;

  for (nilSubclasses = 0; n--; ci++)
    {
      superClassOOP = *ci->superClassPtr;
      create_class (ci);

      if (IS_NIL (superClassOOP))
	nilSubclasses++;
      else
	{
          superclass = (gst_class) OOP_TO_OBJ (superClassOOP);
          superclass->subClasses =
	    FROM_INT (TO_INT (superclass->subClasses) + 1);
	}
    }

  /* Object class being a subclass of gst_class is not an apparent link,
     and so the index which is the number of subclasses of the class
     is off by the number of subclasses of nil.  We correct that here.

     On the other hand, we don't want the meta class to have a subclass
     (`Class class' and `Class' are unique in that they don't have the
     same number of subclasses), so since we have the information here,
     we special case the Class class and create its metaclass here.  */
  classObj = (gst_class) OOP_TO_OBJ (_gst_class_class);
  create_metaclass (_gst_class_class,
		    TO_INT (classObj->subClasses),
		    TO_INT (classObj->subClasses) + nilSubclasses);
}

void
create_classes_pass2 (const class_definition *ci,
		      int n)
{
  OOP class_oop;
  gst_class class;
  int numSubclasses;

  for (; n--; ci++)
    {
      class_oop = *ci->classVar;
      class = (gst_class) OOP_TO_OBJ (class_oop);

      if (!class->objClass)
	{
          numSubclasses = TO_INT (class->subClasses);
	  create_metaclass (class_oop, numSubclasses, numSubclasses);
	}

      init_metaclass (class->objClass);
      init_class (class_oop, ci);
    }
}

void
create_metaclass (OOP class_oop,
	          int numMetaclassSubClasses,
	          int numSubClasses)
{
  gst_class class;
  gst_metaclass metaclass;
  gst_object subClasses;

  class = (gst_class) OOP_TO_OBJ (class_oop);
  metaclass = (gst_metaclass) new_instance (_gst_metaclass_class,
					    &class->objClass);

  metaclass->instanceClass = class_oop;

  subClasses = new_instance_with (_gst_array_class, numSubClasses,
				  &class->subClasses);
  if (numSubClasses > 0)
    subClasses->data[0] = FROM_INT (numSubClasses);

  subClasses = new_instance_with (_gst_array_class, numMetaclassSubClasses,
		     		  &metaclass->subClasses);
  if (numMetaclassSubClasses > 0)
    subClasses->data[0] = FROM_INT (numMetaclassSubClasses);
}

void
init_metaclass (OOP metaclassOOP)
{
  gst_metaclass metaclass;
  OOP class_oop, superClassOOP;

  metaclass = (gst_metaclass) OOP_TO_OBJ (metaclassOOP);
  class_oop = metaclass->instanceClass;
  superClassOOP = SUPERCLASS (class_oop);

  if (IS_NIL (superClassOOP))
    /* Object case: make this be gst_class to close the circularity */
    metaclass->superclass = _gst_class_class;
  else
    metaclass->superclass = OOP_CLASS (superClassOOP);

  add_subclass (metaclass->superclass, metaclassOOP);

  /* the specifications here should match what a class should have:
     instance variable names, the right number of instance variables,
     etc.  We could take three passes, and use the instance variable
     spec for classes once it's established, but it's easier to create
     them here by hand */
  metaclass->instanceVariables =
    _gst_make_instance_variable_array (_gst_nil_oop,
				       "superClass methodDictionary instanceSpec subClasses "
				       "instanceVariables name comment category environment "
				       "classVariables sharedPools securityPolicy "
				       "pragmaHandlers");

  metaclass->instanceSpec = GST_ISP_INTMARK | GST_ISP_FIXED |
    (((sizeof (struct gst_class) -
       sizeof (gst_object_header)) /
      sizeof (OOP)) << ISP_NUMFIXEDFIELDS);

  metaclass->methodDictionary = _gst_nil_oop;
}

void
init_class (OOP class_oop, const class_definition *ci)
{
  gst_class class;

  class = (gst_class) OOP_TO_OBJ (class_oop);
  class->name = _gst_intern_string (ci->name);
  add_smalltalk (ci->name, class_oop);

  if (!IS_NIL (class->superclass))
    add_subclass (class->superclass, class_oop);

  class->environment = _gst_smalltalk_dictionary;
  class->instanceVariables =
    _gst_make_instance_variable_array (class->superclass, ci->instVarNames);
  class->classVariables =
    _gst_make_class_variable_dictionary (ci->classVarNames, class_oop);

  class->sharedPools = _gst_make_pool_array (ci->sharedPoolNames);

  /* Other fields are set by the Smalltalk code.  */
  class->methodDictionary = _gst_nil_oop;
  class->comment = _gst_nil_oop;
  class->category = _gst_nil_oop;
  class->securityPolicy = _gst_nil_oop;
  class->pragmaHandlers = _gst_nil_oop;
}

void
add_subclass (OOP superClassOOP,
	      OOP subClassOOP)
{
  gst_class_description superclass;
  int index;

  superclass = (gst_class_description) OOP_TO_OBJ (superClassOOP);

#ifndef OPTIMIZE
  if (NUM_WORDS (OOP_TO_OBJ (superclass->subClasses)) == 0)
    {
      _gst_errorf ("Attempt to add subclass to zero sized class");
      abort ();
    }
#endif

  index = TO_INT (ARRAY_AT (superclass->subClasses, 1));
  ARRAY_AT_PUT (superclass->subClasses, 1, FROM_INT (index - 1));
  ARRAY_AT_PUT (superclass->subClasses, index, subClassOOP);
}

void
init_smalltalk_dictionary (void)
{
  OOP featuresArrayOOP;
  gst_object featuresArray;
  char fullVersionString[200];
  int i, numFeatures;

  _gst_current_namespace = _gst_smalltalk_dictionary;
  for (numFeatures = 0; feature_strings[numFeatures]; numFeatures++);

  featuresArray = new_instance_with (_gst_array_class, numFeatures,
		     		     &featuresArrayOOP);

  for (i = 0; i < numFeatures; i++)
    featuresArray->data[i] = _gst_intern_string (feature_strings[i]);

  sprintf (fullVersionString, "GNU Smalltalk version %s",
	   VERSION PACKAGE_GIT_REVISION);

  add_smalltalk ("Smalltalk", _gst_smalltalk_dictionary);
  add_smalltalk ("Version", _gst_string_new (fullVersionString));
  add_smalltalk ("KernelFilePath", _gst_string_new (_gst_kernel_file_path));
  add_smalltalk ("KernelInitialized", _gst_false_oop);
  add_smalltalk ("SymbolTable", _gst_symbol_table);
  add_smalltalk ("Processor", _gst_processor_oop);
  add_smalltalk ("Features", featuresArrayOOP);

  /* Add subspaces */
  add_smalltalk ("CSymbols",
    namespace_new (32, "CSymbols", _gst_smalltalk_dictionary));

  init_primitives_dictionary ();

  add_smalltalk ("Undeclared",
    namespace_new (32, "Undeclared", _gst_nil_oop));
  add_smalltalk ("SystemExceptions",
    namespace_new (32, "SystemExceptions", _gst_smalltalk_dictionary));
  add_smalltalk ("NetClients",
    namespace_new (32, "NetClients", _gst_smalltalk_dictionary));
  add_smalltalk ("VFS",
    namespace_new (32, "VFS", _gst_smalltalk_dictionary));

  _gst_init_process_system ();
}

static OOP
add_smalltalk (const char *globalName,
	       OOP globalValue)
{
  NAMESPACE_AT_PUT (_gst_smalltalk_dictionary,
		    _gst_intern_string (globalName), globalValue);

  return globalValue;
}

static OOP
relocate_path_oop (const char *s)
{
  OOP resultOOP;
  char *path = _gst_relocate_path (s);
  if (path)
    resultOOP = _gst_string_new (path);
  else
    resultOOP = _gst_nil_oop;

  free (path);
  return resultOOP;
}

void
init_runtime_objects (void)
{
  add_smalltalk ("UserFileBasePath", _gst_string_new (_gst_user_file_base_path));

  add_smalltalk ("SystemKernelPath", relocate_path_oop (KERNEL_PATH));
  add_smalltalk ("ModulePath", relocate_path_oop (MODULE_PATH));
  add_smalltalk ("LibexecPath", relocate_path_oop (LIBEXEC_PATH));
  add_smalltalk ("Prefix", relocate_path_oop (PREFIX));
  add_smalltalk ("ExecPrefix", relocate_path_oop (EXEC_PREFIX));
  add_smalltalk ("ImageFilePath", _gst_string_new (_gst_image_file_path));
  add_smalltalk ("ExecutableFileName", _gst_string_new (_gst_executable_path));
  add_smalltalk ("ImageFileName", _gst_string_new (_gst_binary_image_name));
  add_smalltalk ("OutputVerbosity", FROM_INT (_gst_verbosity));
  add_smalltalk ("RegressionTesting",
		 _gst_regression_testing ? _gst_true_oop : _gst_false_oop);

#ifdef WORDS_BIGENDIAN
  add_smalltalk ("Bigendian", _gst_true_oop);
#else
  add_smalltalk ("Bigendian", _gst_false_oop);
#endif

  add_file_stream_object (0, O_RDONLY, "stdin");
  add_file_stream_object (1, O_WRONLY, "stdout");
  add_file_stream_object (2, O_WRONLY, "stderr");

  init_c_symbols ();

  /* Add the root among the roots :-) to the root set */
  _gst_register_oop (_gst_smalltalk_dictionary);
}

void
init_c_symbols ()
{
  OOP cSymbolsOOP = dictionary_at (_gst_smalltalk_dictionary,
				   _gst_intern_string ("CSymbols"));

  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("HostSystem"),
		    _gst_string_new (HOST_SYSTEM));

  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CIntSize"),
		    FROM_INT (sizeof (int)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CShortSize"),
		    FROM_INT (sizeof (short)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongSize"),
		    FROM_INT (sizeof (long)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatSize"),
		    FROM_INT (sizeof (float)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleSize"),
		    FROM_INT (sizeof (double)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleSize"),
		    FROM_INT (sizeof (long double)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CPtrSize"),
		    FROM_INT (sizeof (PTR)));

#ifndef INFINITY
#define INFINITY LDBL_MAX * 2
#endif
#ifndef NAN
#define NAN (0.0 / 0.0)
#endif

#if defined WIN32 && !defined __CYGWIN__
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("PathSeparator"),
		    CHAR_OOP_AT ('\\'));
#else
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("PathSeparator"),
		    CHAR_OOP_AT ('/'));
#endif

  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleMin"),
		    floatd_new (DBL_MIN));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleMax"),
		    floatd_new (DBL_MAX));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoublePInf"),
		    floatd_new ((double) INFINITY));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleNInf"),
		    floatd_new ((double) -INFINITY));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleNaN"),
		    floatd_new ((double) NAN));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleDigits"),
		    FROM_INT (ceil (DBL_MANT_DIG * 0.301029995663981)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleBinaryDigits"),
		    FROM_INT (DBL_MANT_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleMinExp"),
		    FROM_INT (DBL_MIN_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleMaxExp"),
		    FROM_INT (DBL_MAX_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleAlignment"),
		    FROM_INT (ALIGNOF_DOUBLE));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongLongAlignment"),
		    FROM_INT (ALIGNOF_LONG_LONG));

  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatPInf"),
		    floate_new ((float) INFINITY));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatNInf"),
		    floate_new ((float) -INFINITY));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatNaN"),
		    floate_new ((float) NAN));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatMin"),
		    floate_new (FLT_MIN));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatMax"),
		    floate_new (FLT_MAX));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatDigits"),
		    FROM_INT (ceil (FLT_MANT_DIG * 0.301029995663981)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatBinaryDigits"),
		    FROM_INT (FLT_MANT_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatMinExp"),
		    FROM_INT (FLT_MIN_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatMaxExp"),
		    FROM_INT (FLT_MAX_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CFloatAlignment"),
		    FROM_INT (sizeof (float)));

  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoublePInf"),
		    floatq_new ((long double) INFINITY));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleNInf"),
		    floatq_new ((long double) -INFINITY));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleNaN"),
		    floatq_new ((long double) NAN));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleMin"),
		    floatq_new (LDBL_MIN));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleMax"),
		    floatq_new (LDBL_MAX));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleDigits"),
		    FROM_INT (ceil (LDBL_MANT_DIG * 0.301029995663981)));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleBinaryDigits"),
		    FROM_INT (LDBL_MANT_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleMinExp"),
		    FROM_INT (LDBL_MIN_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleMaxExp"),
		    FROM_INT (LDBL_MAX_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleAlignment"),
		    FROM_INT (ALIGNOF_LONG_DOUBLE));
}

void
init_primitives_dictionary ()
{
  OOP primDictionaryOOP = _gst_dictionary_new (512);
  int i;

  add_smalltalk ("VMPrimitives", primDictionaryOOP);
  for (i = 0; i < NUM_PRIMITIVES; i++)
    {
      prim_table_entry *pte = _gst_get_primitive_attributes (i);

      if (pte->name)
	{
	  OOP keyOOP = _gst_intern_string (pte->name);
	  OOP valueOOP = FROM_INT (i);
	  DICTIONARY_AT_PUT (primDictionaryOOP, keyOOP, valueOOP);
	}
    }
}

void
add_file_stream_object (int fd,
			int access,
			const char *fileObjectName)
{
  OOP fileStreamOOP;
  OOP keyOOP;

  keyOOP = _gst_intern_string (fileObjectName);
  fileStreamOOP = dictionary_at (_gst_smalltalk_dictionary, keyOOP);
  if (IS_NIL (fileStreamOOP))
    instantiate (_gst_file_stream_class, &fileStreamOOP);

  _gst_set_file_stream_file (fileStreamOOP, fd,
			     _gst_string_new (fileObjectName),
			     _gst_is_pipe (fd), access, true);

  add_smalltalk (fileObjectName, fileStreamOOP);
}

void
create_class (const class_definition *ci)
{
  gst_class class;
  intptr_t superInstanceSpec;
  OOP classOOP, superClassOOP;
  int numFixedFields;

  numFixedFields = ci->numFixedFields;
  superClassOOP = *ci->superClassPtr;
  if (!IS_NIL (superClassOOP))
    {
      /* adjust the number of instance variables to account for
         inheritance */
      superInstanceSpec = CLASS_INSTANCE_SPEC (superClassOOP);
      numFixedFields += superInstanceSpec >> ISP_NUMFIXEDFIELDS;
    }

  class = (gst_class) _gst_alloc_obj (sizeof (struct gst_class), &classOOP);

  class->objClass = NULL;
  class->superclass = superClassOOP;
  class->instanceSpec = GST_ISP_INTMARK
    | ci->instanceSpec
    | (numFixedFields << ISP_NUMFIXEDFIELDS);

  class->subClasses = FROM_INT (0);

  *ci->classVar = classOOP;
}


mst_Boolean
_gst_init_dictionary_on_image_load (mst_Boolean prim_table_matches)
{
  const class_definition *ci;

  _gst_smalltalk_dictionary = OOP_AT (SMALLTALK_OOP_INDEX);
  _gst_processor_oop = OOP_AT (PROCESSOR_OOP_INDEX);
  _gst_symbol_table = OOP_AT (SYM_TABLE_OOP_INDEX);

  if (IS_NIL (_gst_processor_oop) || IS_NIL (_gst_symbol_table)
      || IS_NIL (_gst_smalltalk_dictionary))
    return (false);

  _gst_restore_symbols ();

  for (ci = class_info; 
       ci < class_info + sizeof(class_info) / sizeof(class_definition);
       ci++)
    if (ci->reloadAddress)
      {
	*ci->classVar = dictionary_at (_gst_smalltalk_dictionary,
				       _gst_intern_string (ci->name));
        if UNCOMMON (IS_NIL (*ci->classVar))
	  return (false);
      }

  _gst_current_namespace =
    dictionary_at (_gst_class_variable_dictionary (_gst_namespace_class),
		   _gst_intern_string ("Current"));

  _gst_init_builtin_objects_classes ();

  /* Important: this is called *after* _gst_init_symbols
     fills in _gst_vm_primitives_symbol! */
  if (prim_table_matches)
    memcpy (_gst_primitive_table, _gst_default_primitive_table,
            sizeof (_gst_primitive_table));
  else
    prepare_primitive_numbers_table ();

  init_runtime_objects ();
  return (true);
}

void
prepare_primitive_numbers_table ()
{
  int i;
  OOP primitivesDictionaryOOP;

  primitivesDictionaryOOP = dictionary_at (_gst_smalltalk_dictionary, 
					   _gst_vm_primitives_symbol);

  for (i = 0; i < NUM_PRIMITIVES; i++)
    _gst_set_primitive_attributes (i, NULL);

  for (i = 0; i < NUM_PRIMITIVES; i++)
    {
      prim_table_entry *pte = _gst_get_primitive_attributes (i);
      OOP symbolOOP, valueOOP;
      int old_index;

      if (!pte->name)
	continue;

      symbolOOP = _gst_intern_string (pte->name);
      valueOOP = dictionary_at (primitivesDictionaryOOP, symbolOOP);

      /* Do nothing if the primitive is unknown to the image.  */
      if (IS_NIL (valueOOP))
        continue;

      old_index = TO_INT (valueOOP);
      _gst_set_primitive_attributes (old_index, pte);
    }
}



OOP
_gst_get_class_symbol (OOP class_oop)
{
  gst_class class;

  class = (gst_class) OOP_TO_OBJ (class_oop);
  return (class->name);
  /* this is the case when we have a metaclass, ??? I don't think that
     this is right, but I don't know what else to do here */
}



OOP
_gst_find_class (OOP classNameOOP)
{
  return (dictionary_at (_gst_smalltalk_dictionary, classNameOOP));
}



OOP
_gst_valid_class_method_dictionary (OOP class_oop)
{
  gst_class class;

  /* ??? check for non-class objects */
  class = (gst_class) OOP_TO_OBJ (class_oop);
  if (IS_NIL (class->methodDictionary))
    {
      OOP methodDictionaryOOP;
      methodDictionaryOOP =
        identity_dictionary_new (_gst_method_dictionary_class, 32);
      class = (gst_class) OOP_TO_OBJ (class_oop);
      class->methodDictionary = methodDictionaryOOP;
    }

  return (class->methodDictionary);
}

OOP
_gst_find_class_method (OOP class_oop,
                       OOP selector)
{
  gst_class class;
  gst_object methodDictionary;
  OOP method_dictionary_oop;
  int index;
  size_t numFixedFields;

  class = (gst_class) OOP_TO_OBJ (class_oop);
  method_dictionary_oop = class->methodDictionary;
  if (IS_NIL (method_dictionary_oop))
    return (_gst_nil_oop);

  index =
    identity_dictionary_find_key (method_dictionary_oop,
				  selector);

  if (index < 0)
    return (_gst_nil_oop);

  methodDictionary = OOP_TO_OBJ (method_dictionary_oop);
  numFixedFields = OOP_FIXED_FIELDS (method_dictionary_oop);

  return (methodDictionary->data[index + numFixedFields]);
}

OOP
_gst_class_variable_dictionary (OOP class_oop)
{
  gst_class class;

  /* ??? check for non-class objects */
  class = (gst_class) OOP_TO_OBJ (class_oop);
  return (class->classVariables);
}

OOP
_gst_instance_variable_array (OOP class_oop)
{
  gst_class class;

  /* ??? check for non-class objects */
  class = (gst_class) OOP_TO_OBJ (class_oop);
  return (class->instanceVariables);
}

OOP
_gst_shared_pool_dictionary (OOP class_oop)
{
  gst_class class;

  /* ??? check for non-class objects */
  class = (gst_class) OOP_TO_OBJ (class_oop);
  return (class->sharedPools);
}


OOP
_gst_namespace_association_at (OOP poolOOP,
			       OOP symbol)
{
  OOP assocOOP;
  gst_namespace pool;

  if (is_a_kind_of (OOP_CLASS (poolOOP), _gst_class_class))
    poolOOP = _gst_class_variable_dictionary (poolOOP);

  for (;;)
    {
      if (!is_a_kind_of (OOP_CLASS (poolOOP), _gst_dictionary_class))
        return (_gst_nil_oop);

      assocOOP = dictionary_association_at (poolOOP, symbol);
      if (!IS_NIL (assocOOP))
        return (assocOOP);

      /* Try to find a super-namespace */
      if (!is_a_kind_of (OOP_CLASS (poolOOP), _gst_abstract_namespace_class))
        return (_gst_nil_oop);

      pool = (gst_namespace) OOP_TO_OBJ (poolOOP);
      poolOOP = pool->superspace;
    }
}

OOP
_gst_namespace_at (OOP poolOOP,
		   OOP symbol)
{
  OOP assocOOP = _gst_namespace_association_at (poolOOP, symbol);
  if (IS_NIL (assocOOP))
    return assocOOP;
  else
    return ASSOCIATION_VALUE (assocOOP);
}


size_t
new_num_fields (size_t oldNumFields)
{
  /* Find a power of two that is larger than oldNumFields */

  int n = 1;

  /* Already a power of two? duplicate the size */
  if COMMON ((oldNumFields & (oldNumFields - 1)) == 0)
    return oldNumFields * 2;

  /* Find the next power of two by setting all bits to the right of
     the leftmost 1 bit to 1, and then incrementing.  */
  for (; oldNumFields & (oldNumFields + 1); n <<= 1)
    oldNumFields |= oldNumFields >> n;

  return oldNumFields + 1;
}

static int
find_key_or_nil (OOP dictionaryOOP,
		 OOP keyOOP)
{
  size_t count, numFields, numFixedFields;
  intptr_t index;
  gst_object dictionary;
  OOP associationOOP;
  gst_association association;

  dictionary = (gst_object) OOP_TO_OBJ (dictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (dictionaryOOP);
  numFields = NUM_WORDS (dictionary) - numFixedFields;
  index = scramble (OOP_INDEX (keyOOP));
  count = numFields;

  for (; count; count--)
    {
      index &= numFields - 1;
      associationOOP = dictionary->data[numFixedFields + index];
      if COMMON (IS_NIL (associationOOP))
	return (index);

      association = (gst_association) OOP_TO_OBJ (associationOOP);

      if (association->key == keyOOP)
	return (index);

      /* linear reprobe -- it is simple and guaranteed */
      index++;
    }

  _gst_errorf
    ("Error - searching dictionary for nil, but it is full!\n");

  abort ();
}

gst_object
grow_dictionary (OOP oldDictionaryOOP)
{
  gst_object oldDictionary, dictionary;
  size_t oldNumFields, numFields, i, index, numFixedFields;
  OOP associationOOP;
  gst_association association;
  OOP dictionaryOOP;

  oldDictionary = OOP_TO_OBJ (oldDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (oldDictionaryOOP);
  oldNumFields = NUM_WORDS (oldDictionary) - numFixedFields;

  numFields = new_num_fields (oldNumFields);

  /* no need to use the incubator here.  We are instantiating just one
     object, the new dictionary itself */

  dictionary = instantiate_with (OOP_CLASS (oldDictionaryOOP), 
				 numFields, &dictionaryOOP);
  memcpy (dictionary->data, oldDictionary->data, sizeof (PTR) * numFixedFields);
  oldDictionary = OOP_TO_OBJ (oldDictionaryOOP);

  /* rehash all associations from old dictionary into new one */
  for (i = 0; i < oldNumFields; i++)
    {
      associationOOP = oldDictionary->data[numFixedFields + i];
      if COMMON (!IS_NIL (associationOOP))
	{
	  association = (gst_association) OOP_TO_OBJ (associationOOP);
	  index = find_key_or_nil (dictionaryOOP, association->key);
	  dictionary->data[numFixedFields + index] = associationOOP;
	}
    }

  _gst_swap_objects (dictionaryOOP, oldDictionaryOOP);
  return (OOP_TO_OBJ (oldDictionaryOOP));
}

gst_object
grow_identity_dictionary (OOP oldIdentityDictionaryOOP)
{
  gst_object oldIdentityDictionary, identityDictionary;
  gst_identity_dictionary oldIdentDict, identDict;
  OOP key, identityDictionaryOOP;
  size_t oldNumFields, numFields, numFixedFields, i, index;

  oldIdentityDictionary = OOP_TO_OBJ (oldIdentityDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (oldIdentityDictionaryOOP);
  oldNumFields = (NUM_WORDS (oldIdentityDictionary) - numFixedFields) / 2;

  numFields = new_num_fields (oldNumFields);

  identityDictionary = 
    instantiate_with (OOP_CLASS (oldIdentityDictionaryOOP), numFields * 2,
                     &identityDictionaryOOP);

  oldIdentityDictionary = OOP_TO_OBJ (oldIdentityDictionaryOOP);
  oldIdentDict = (gst_identity_dictionary) oldIdentityDictionary;
  identDict = (gst_identity_dictionary) identityDictionary;
  identDict->tally = INCR_INT (oldIdentDict->tally);

  /* rehash all associations from old dictionary into new one */
  for (i = 0; i < oldNumFields; i++)
    {
      key = oldIdentityDictionary->data[i * 2 + numFixedFields];
      if COMMON (!IS_NIL (key))
       {
         index =
           identity_dictionary_find_key_or_nil (identityDictionaryOOP,
                                                key);
         identityDictionary->data[index - 1 + numFixedFields] = key;
         identityDictionary->data[index + numFixedFields] = oldIdentityDictionary->data[i * 2 + 1 + numFixedFields];
       }
    }

  _gst_swap_objects (identityDictionaryOOP, oldIdentityDictionaryOOP);
  return (OOP_TO_OBJ (oldIdentityDictionaryOOP));
}


ssize_t
identity_dictionary_find_key (OOP identityDictionaryOOP,
                             OOP keyOOP)
{
  gst_object identityDictionary;
  size_t index, count, numFields, numFixedFields;

  identityDictionary = OOP_TO_OBJ (identityDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (identityDictionaryOOP);

  numFields = NUM_WORDS (identityDictionary) - numFixedFields;
  index = scramble (OOP_INDEX (keyOOP)) * 2;
  count = numFields / 2;
  /* printf ("%d %d %O\n", count, index & numFields - 1, keyOOP); */
  while (count--)
    {
      index &= numFields - 1;

      if COMMON (IS_NIL (identityDictionary->data[index + numFixedFields]))
       return (-1);

      if COMMON (identityDictionary->data[index + numFixedFields] == keyOOP)
       return (index + 1);

      /* linear reprobe -- it is simple and guaranteed */
      index += 2;
    }

  _gst_errorf
    ("Error - searching IdentityDictionary for nil, but it is full!\n");

  abort ();
}



size_t
identity_dictionary_find_key_or_nil (OOP identityDictionaryOOP,
                                    OOP keyOOP)
{
  gst_object identityDictionary;
  size_t index, count, numFields, numFixedFields;

  identityDictionary = OOP_TO_OBJ (identityDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (identityDictionaryOOP);

  numFields = NUM_WORDS (identityDictionary) - numFixedFields;
  index = scramble (OOP_INDEX (keyOOP)) * 2;
  count = numFields / 2;
  /* printf ("%d %d %O\n", count, index & numFields - 1, keyOOP); */
  while (count--)
    {
      index &= numFields - 1;

      if COMMON (IS_NIL (identityDictionary->data[index + numFixedFields]))
       return (index + 1);

      if COMMON (identityDictionary->data[index + numFixedFields] == keyOOP)
       return (index + 1);

      /* linear reprobe -- it is simple and guaranteed */
      index += 2;
    }

  _gst_errorf
    ("Error - searching IdentityDictionary for nil, but it is full!\n");

  abort ();
}

OOP
identity_dictionary_new (OOP classOOP, int size)
{
  gst_identity_dictionary identityDictionary;
  OOP identityDictionaryOOP;

  size = new_num_fields (size);

  identityDictionary = (gst_identity_dictionary)
    instantiate_with (classOOP, size * 2, &identityDictionaryOOP);

  identityDictionary->tally = FROM_INT (0);
  return (identityDictionaryOOP);
}

OOP
_gst_identity_dictionary_at_put (OOP identityDictionaryOOP,
                                OOP keyOOP,
                                OOP valueOOP)
{
  gst_object identityDictionary;
  gst_identity_dictionary identDict;
  intptr_t index;
  OOP oldValueOOP;
  size_t numFixedFields;

  identityDictionary = OOP_TO_OBJ (identityDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (identityDictionaryOOP);

  /* Never make dictionaries too full! For simplicity, we do this even
     if the key is present in the dictionary (because it will most
     likely resolve some collisions and make things faster).  */

  identDict = (gst_identity_dictionary) identityDictionary;
  if UNCOMMON (TO_INT (identDict->tally) >= TO_INT (identDict->objSize) * 3 / 8)
    identityDictionary = grow_identity_dictionary (identityDictionaryOOP);

  index =
    identity_dictionary_find_key_or_nil (identityDictionaryOOP, keyOOP);

  if COMMON (IS_NIL (identityDictionary->data[index - 1 + numFixedFields]))
    {
      identDict = (gst_identity_dictionary) identityDictionary;
      identDict->tally = INCR_INT (identDict->tally);
    }

  identityDictionary->data[index - 1 + numFixedFields] = keyOOP;
  oldValueOOP = identityDictionary->data[index + numFixedFields];
  identityDictionary->data[index + numFixedFields] = valueOOP;

  return (oldValueOOP);
}
OOP
_gst_identity_dictionary_at (OOP identityDictionaryOOP,
                            OOP keyOOP)
{
  gst_object identityDictionary;
  intptr_t index;
  size_t numFixedFields;

  identityDictionary = OOP_TO_OBJ (identityDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (identityDictionaryOOP);

  index =
    identity_dictionary_find_key_or_nil (identityDictionaryOOP, keyOOP);

  return identityDictionary->data[index + numFixedFields];
}

OOP
namespace_new (int size, const char *name, OOP superspaceOOP)
{
  gst_namespace ns;
  OOP namespaceOOP, classOOP;

  size = new_num_fields (size);
  classOOP = IS_NIL (superspaceOOP)
    ? _gst_root_namespace_class : _gst_namespace_class;

  ns = (gst_namespace) instantiate_with (classOOP, size, &namespaceOOP);

  ns->tally = FROM_INT (0);
  ns->superspace = superspaceOOP;
  ns->subspaces = _gst_nil_oop;
  ns->name = _gst_intern_string (name);

  return (namespaceOOP);
}

OOP
_gst_dictionary_new (int size)
{
  gst_dictionary dictionary;
  OOP dictionaryOOP;

  size = new_num_fields (size);
  dictionary = (gst_dictionary)
    instantiate_with (_gst_dictionary_class, size, &dictionaryOOP);

  dictionary->tally = FROM_INT (0);

  return (dictionaryOOP);
}

OOP
_gst_binding_dictionary_new (int size, OOP environmentOOP)
{
  gst_binding_dictionary dictionary;
  OOP dictionaryOOP;

  size = new_num_fields (size);
  dictionary = (gst_binding_dictionary)
    instantiate_with (_gst_binding_dictionary_class, size, &dictionaryOOP);

  dictionary->tally = FROM_INT (0);
  dictionary->environment = environmentOOP;

  return (dictionaryOOP);
}

OOP
_gst_dictionary_add (OOP dictionaryOOP,
		     OOP associationOOP)
{
  intptr_t index;
  gst_association association;
  gst_object dictionary;
  gst_dictionary dict;
  OOP value;
  inc_ptr incPtr;		/* I'm not sure clients are protecting
				   association OOP */

  incPtr = INC_SAVE_POINTER ();
  INC_ADD_OOP (associationOOP);

  association = (gst_association) OOP_TO_OBJ (associationOOP);
  dictionary = OOP_TO_OBJ (dictionaryOOP);
  dict = (gst_dictionary) dictionary;
  if UNCOMMON (TO_INT (dict->tally) >= 
	       TO_INT (dict->objSize) * 3 / 4)
    {
      dictionary = grow_dictionary (dictionaryOOP);
      dict = (gst_dictionary) dictionary;
    }

  index = find_key_or_nil (dictionaryOOP, association->key);
  index += OOP_FIXED_FIELDS (dictionaryOOP);
  if COMMON (IS_NIL (dictionary->data[index]))
    {
      dict->tally = INCR_INT (dict->tally);
      dictionary->data[index] = associationOOP;
    }
  else
    {
      value = ASSOCIATION_VALUE (associationOOP);
      associationOOP = dictionary->data[index];
      SET_ASSOCIATION_VALUE (associationOOP, value);
    }

  INC_RESTORE_POINTER (incPtr);
  return (associationOOP);
}


OOP
_gst_object_copy (OOP oop)
{
  gst_object old, new;
  OOP newOOP;
  size_t numFields;

  if UNCOMMON (IS_INT(oop) || IS_BUILTIN_OOP (oop))
    return (oop);

  numFields = NUM_INDEXABLE_FIELDS (oop);

  new = instantiate_with (OOP_CLASS (oop), numFields, &newOOP);
  old = OOP_TO_OBJ (oop);
  memcpy (new, old, SIZE_TO_BYTES (TO_INT (old->objSize)));

  newOOP->flags |= (oop->flags & F_CONTEXT);
  return (newOOP);
}



OOP
_gst_new_string (size_t len)
{
  OOP stringOOP;

  new_instance_with (_gst_string_class, len, &stringOOP);
  return (stringOOP);
}

OOP
_gst_string_new (const char *s)
{
  gst_string string;
  size_t len;
  OOP stringOOP;

  if (s)
    {
      len = strlen (s);
      string = (gst_string) new_instance_with (_gst_string_class, len,
					       &stringOOP);

      memcpy (string->chars, s, len);
    }
  else
    string = (gst_string) new_instance_with (_gst_string_class, 0,
					     &stringOOP);
  return (stringOOP);
}

OOP
_gst_unicode_string_new (const wchar_t *s)
{
  int i;
  gst_unicode_string string;
  size_t len;
  OOP stringOOP;

  if (s)
    {
      len = wcslen (s);
      string = (gst_unicode_string)
	new_instance_with (_gst_unicode_string_class, len, &stringOOP);

      if (sizeof (wchar_t) == sizeof (string->chars[0]))
	memcpy (string->chars, s, len * sizeof (wchar_t));
      else
	for (i = 0; i < len; i++)
	  string->chars[i] = *s++;
    }
  else
    string = (gst_unicode_string)
      new_instance_with (_gst_unicode_string_class, 0, &stringOOP);

  return (stringOOP);
}

OOP
_gst_counted_string_new (const char *s,
			 size_t len)
{
  gst_string string;
  OOP stringOOP;

  string = (gst_string) new_instance_with (_gst_string_class, len,
					   &stringOOP);

  if (len)
    memcpy (string->chars, s, len);

  return (stringOOP);
}

void
_gst_set_oopstring (OOP stringOOP,
		    const char *s)
{
  OOP newStringOOP;

  newStringOOP = _gst_string_new (s);
  _gst_swap_objects (stringOOP, newStringOOP);
}

void
_gst_set_oop_unicode_string (OOP unicodeStringOOP,
			     const wchar_t *s)
{
  OOP newStringOOP;

  newStringOOP = _gst_unicode_string_new (s);
  _gst_swap_objects (unicodeStringOOP, newStringOOP);
}

char *
_gst_to_cstring (OOP stringOOP)
{
  char *result;
  size_t len;
  gst_string string;

  string = (gst_string) OOP_TO_OBJ (stringOOP);
  len = oop_num_fields (stringOOP);
  result = (char *) xmalloc (len + 1);
  memcpy (result, string->chars, len);
  result[len] = '\0';

  return (result);
}

wchar_t *
_gst_to_wide_cstring (OOP stringOOP)
{
  wchar_t *result, *p;
  size_t len;
  gst_unicode_string string;
  int i;

  string = (gst_unicode_string) OOP_TO_OBJ (stringOOP);
  len = oop_num_fields (stringOOP);
  result = (wchar_t *) xmalloc (len + 1);
  if (sizeof (wchar_t) == 4)
    memcpy (result, string->chars, len * sizeof (wchar_t));
  else
    for (p = result, i = 0; i < len; i++)
      *p++ = string->chars[i];
  result[len] = '\0';

  return (result);
}

OOP
_gst_byte_array_new (const gst_uchar * bytes,
		     size_t len)
{
  gst_byte_array byteArray;
  OOP byteArrayOOP;

  byteArray = (gst_byte_array) new_instance_with (_gst_byte_array_class,
						  len, &byteArrayOOP);

  memcpy (byteArray->bytes, bytes, len);
  return (byteArrayOOP);
}



gst_uchar *
_gst_to_byte_array (OOP byteArrayOOP)
{
  gst_uchar *result;
  size_t len;
  gst_byte_array byteArray;

  byteArray = (gst_byte_array) OOP_TO_OBJ (byteArrayOOP);
  len = oop_num_fields (byteArrayOOP);
  result = (gst_uchar *) xmalloc (len);
  memcpy (result, byteArray->bytes, len);

  return (result);
}

void
_gst_set_oop_bytes (OOP byteArrayOOP,
		    gst_uchar * bytes)
{
  gst_byte_array byteArray;
  size_t len;

  len = oop_num_fields (byteArrayOOP);
  byteArray = (gst_byte_array) OOP_TO_OBJ (byteArrayOOP);
  memcpy (byteArray->bytes, bytes, len);
}



OOP
_gst_message_new_args (OOP selectorOOP,
		       OOP argsArray)
{
  gst_message message;
  OOP messageOOP;

  message = (gst_message) new_instance (_gst_message_class,
					&messageOOP);

  message->selector = selectorOOP;
  message->args = argsArray;

  return (messageOOP);
}

OOP
_gst_c_object_new_base (OOP baseOOP,
		        uintptr_t cObjOfs,
		        OOP typeOOP,
		        OOP defaultClassOOP)
{
  gst_cobject cObject;
  gst_ctype cType;
  OOP cObjectOOP;
  OOP classOOP;

  if (!IS_NIL (typeOOP))
    {
      cType = (gst_ctype) OOP_TO_OBJ (typeOOP);
      classOOP = ASSOCIATION_VALUE (cType->cObjectType);
    }
  else
    classOOP = defaultClassOOP;
    
  cObject = (gst_cobject) instantiate_with (classOOP, 1, &cObjectOOP);
  cObject->type = typeOOP;
  cObject->storage = baseOOP;
  SET_COBJECT_OFFSET_OBJ (cObject, cObjOfs);

  return (cObjectOOP);
}


void
_gst_free_cobject (OOP cObjOOP)
{
  gst_cobject cObject;

  cObject = (gst_cobject) OOP_TO_OBJ (cObjOOP);
  if (!IS_NIL (cObject->storage))
    cObject->storage = _gst_nil_oop;
  else
    xfree ((PTR) COBJECT_OFFSET_OBJ (cObject));

  /* make it not point to falsely valid storage */
  SET_COBJECT_OFFSET_OBJ (cObject, NULL);
}

void
_gst_set_file_stream_file (OOP fileStreamOOP,
			   int fd,
			   OOP fileNameOOP,
			   mst_Boolean isPipe,
			   int access,
			   mst_Boolean buffered)
{
  gst_file_stream fileStream;

  fileStream = (gst_file_stream) OOP_TO_OBJ (fileStreamOOP);

  switch (access & O_ACCMODE)
    {
    case O_RDONLY:
      fileStream->access = FROM_INT (1);
      break;
    case O_WRONLY:
      fileStream->access = FROM_INT (2);
      break;
    case O_RDWR:
      fileStream->access = FROM_INT (3);
      break;
    }

  if (buffered)
    {
      char buffer[1024];
      memset (buffer, 0, sizeof (buffer));
      fileStream->collection =
	_gst_counted_string_new (buffer, sizeof (buffer));
      fileStream->ptr = FROM_INT (1);
      fileStream->endPtr = FROM_INT (0);
      fileStream->writePtr = _gst_nil_oop;
      fileStream->writeEnd = _gst_nil_oop;
    }

  fileStream->fd = FROM_INT (fd);
  fileStream->file = fileNameOOP;
  fileStream->isPipe =
    isPipe == -1 ? _gst_nil_oop :
    isPipe ? _gst_true_oop : _gst_false_oop;
}

/* Profiling callback.  The profiler use a simple data structure
   to store the cost and the call graph, which is a 2 level
   IdentityDictionary. First level keys are the CompiledMethod or
   CompiledBlock, and the second level key is the CompiledMethod or
   CompiledBlock that it calls. Values are the number of calls made. There
   is a special key "true" in the second level whose corresponding value
   is the accumulative cost for this method.  */

void 
_gst_record_profile (OOP oldMethod, OOP newMethod, int ipOffset)
{
  OOP profile;
  inc_ptr incPtr;

  /* Protect oldMethod from GC here to avoid complicating the fast path
     in interp-bc.inl.  */
  incPtr = INC_SAVE_POINTER ();
  INC_ADD_OOP (oldMethod);

  profile = _gst_identity_dictionary_at (_gst_raw_profile, oldMethod);
  if UNCOMMON (IS_NIL (profile))
    {
      profile = identity_dictionary_new (_gst_identity_dictionary_class, 6);
      _gst_identity_dictionary_at_put (_gst_raw_profile, oldMethod, 
                                       profile);
    }

  _gst_identity_dictionary_at_inc (profile, _gst_true_oop, 
                                   _gst_bytecode_counter
				   - _gst_saved_bytecode_counter);
  _gst_saved_bytecode_counter = _gst_bytecode_counter;

  /* if ipOffset is 0 then it is a callin and not a return, so we also record 
     the call.  */
  if (ipOffset == 0) 
    _gst_identity_dictionary_at_inc (profile, newMethod, 1);

  INC_RESTORE_POINTER (incPtr);
}

/* Assume the value for KEYOOP is an integer already or the key does not exist;
   increase the value by INC or set it to INC if it does not exist.  */
int
_gst_identity_dictionary_at_inc (OOP identityDictionaryOOP,
                                OOP keyOOP,
                                int inc)
{
  gst_object identityDictionary;
  gst_identity_dictionary identDict;
  intptr_t index;
  int oldValue;
  size_t numFixedFields;

  identityDictionary = OOP_TO_OBJ (identityDictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (identityDictionaryOOP);

  /* Never make dictionaries too full! For simplicity, we do this even
     if the key is present in the dictionary (because it will most
     likely resolve some collisions and make things faster).  */

  identDict = (gst_identity_dictionary) identityDictionary;
  if UNCOMMON (TO_INT (identDict->tally) >= TO_INT (identDict->objSize) * 3 / 8)
    identityDictionary =
      grow_identity_dictionary (identityDictionaryOOP);
  index =
    identity_dictionary_find_key_or_nil (identityDictionaryOOP, keyOOP);

  if UNCOMMON (IS_NIL (identityDictionary->data[index - 1 + numFixedFields]))
    {
      identDict = (gst_identity_dictionary) identityDictionary;
      identDict->tally = INCR_INT (identDict->tally);
      oldValue = 0;
    }
  else 
    oldValue = TO_INT(identityDictionary->data[index + numFixedFields]);
  
  identityDictionary->data[index - 1 + numFixedFields] = keyOOP;
  identityDictionary->data[index + numFixedFields] = FROM_INT(inc+oldValue);

  return (oldValue);
}
