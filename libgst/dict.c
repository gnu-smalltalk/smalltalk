/******************************** -*- C -*- ****************************
 *
 *	Dictionary Support Module.
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

/* this must be big enough that the Smalltalk dictionary does not have to
   grow between the time gst_dictionary is loaded and the time the kernel is
   initialized.  Otherwise some of the methods needed to grow the dictionary
   might not be defined yet!!  */
#define INITIAL_SMALLTALK_SIZE		512

typedef struct class_definition
{
  OOP *classVar;
  OOP *superClassPtr;
  mst_Boolean isPointers;
  mst_Boolean isWords;
  mst_Boolean isIndexable;
  char numFixedFields;
  char *name;
  char *instVarNames;
  char *classVarNames;
  char *sharedPoolNames;
}
class_definition;

/* Primary class variables.  These variables hold the class objects for
   most of the builtin classes in the system */
OOP _gst_object_class, _gst_magnitude_class, _gst_char_class,
  _gst_time_class, _gst_date_class, _gst_fraction_class,
  _gst_context_part_class, _gst_number_class, _gst_float_class,
  _gst_floatd_class, _gst_floate_class, _gst_floatq_class,
  _gst_integer_class, _gst_small_integer_class,
  _gst_object_memory_class, _gst_large_integer_class,
  _gst_large_negative_integer_class, _gst_large_zero_integer_class,
  _gst_large_positive_integer_class, _gst_association_class,
  _gst_homed_association_class, _gst_variable_binding_class,
  _gst_link_class, _gst_process_class, _gst_sym_link_class,
  _gst_callin_process_class,
  _gst_collection_class, _gst_lookup_key_class,
  _gst_sequenceable_collection_class, _gst_linked_list_class,
  _gst_semaphore_class, _gst_character_array_class,
  _gst_arrayed_collection_class, _gst_array_class, _gst_string_class,
  _gst_symbol_class, _gst_byte_array_class, _gst_compiled_method_class,
  _gst_compiled_code_class, _gst_compiled_block_class,
  _gst_interval_class, _gst_ordered_collection_class,
  _gst_sorted_collection_class, _gst_bag_class,
  _gst_mapped_collection_class, _gst_set_class, _gst_dictionary_class,
  _gst_abstract_namespace_class, _gst_binding_dictionary_class,
  _gst_namespace_class, _gst_system_dictionary_class,
  _gst_identity_set_class, _gst_hashed_collection_class,
  _gst_method_dictionary_class, _gst_identity_dictionary_class,
  _gst_undefined_object_class, _gst_boolean_class, _gst_false_class,
  _gst_true_class, _gst_lookup_table_class,
  _gst_processor_scheduler_class, _gst_delay_class,
  _gst_shared_queue_class, _gst_behavior_class,
  _gst_root_namespace_class, _gst_class_description_class,
  _gst_class_class, _gst_metaclass_class, _gst_smalltalk_dictionary,
  _gst_message_class, _gst_directed_message_class,
  _gst_method_context_class,
  _gst_block_context_class, _gst_block_closure_class,
  _gst_byte_stream_class, _gst_stream_class,
  _gst_positionable_stream_class, _gst_read_stream_class,
  _gst_write_stream_class, _gst_read_write_stream_class,
  _gst_file_descriptor_class, _gst_file_stream_class,
  _gst_c_object_class, _gst_c_type_class, _gst_memory_class,
  _gst_random_class, _gst_c_func_descriptor_class,
  _gst_token_stream_class, _gst_method_info_class,
  _gst_file_segment_class, _gst_c_object_type_ctype,
  _gst_processor_oop = NULL;

/* Answer the number of slots that are in a dictionary of
   OLDNUMFIELDS items after growing it. */
static int new_num_fields (int oldNumFields);

/* Instantiate the OOPs that are created before the first classes
   (true, false, nil, the Smalltalk dictionary, the symbol table
   and Processor, the sole instance of ProcessorScheduler. */
static void init_proto_oops (void);

/* Create a new instance of IdentityDictionary and answer it. */
static OOP identity_dictionary_new (int size);

/* Create a new instance of Namespace with the given SIZE, NAME and
   superspace (SUPERSPACEOOP). */
static OOP namespace_new (int size,
			  char *name,
			  OOP superspaceOOP);

/* Create new subclass of SUPERCLASSOOP, whose instances have
   a shape defined by the remaining parameters. */
static OOP new_class (OOP superClassOOP,
		      mst_Boolean isPointers,
		      mst_Boolean isWords,
		      mst_Boolean isIndexable,
		      int numFixedFields);

/* Create a new metaclass for CLASS_OOP; leave space for NUMSUBCLASSES
   classes in the instance variable "subclasses". */
static OOP new_metaclass (OOP class_oop,
			  int numSubClasses);

/* This creates the SystemDictionary called Smalltalk and initializes
   some of the variables in it. */
static void init_smalltalk_dictionary (void);

/* This fills MAP so that it associates primitive numbers in the saved
   image to primitive numbers in this VM. */
static void prepare_primitive_numbers_map (int *map);

/* Add a global named GLOBALNAME and give it the value GLOBALVALUE.
   Return GLOBALVALUE. */
static OOP add_smalltalk (char *globalName,
			  OOP globalValue);

/* Create the class objects, establishing the instance shape and the
   link between a class and its superclass. */
static void create_classes_pass1 (void);

/* Create the subclasses variable of each class (which being an Array
   must be created after the class objects are stored in the global
   variables).  Also create the metaclass hierarchy and make the class
   objects point to it. */
static void create_classes_pass2 (void);

/* Add a subclass SUBCLASSOOP to the subclasses array of
   SUPERCLASSOOP.  Subclasses are stored from the last index to the
   first, and the first slot of the Array indicates the index of the
   last free slot. */
static void add_subclass (OOP superClassOOP,
			  OOP subClassOOP);

/* Adds to Smalltalk a global named FILEOBJECTNAME which is a
   FileStream referring to file descriptor FD. */
static void add_file_stream_object (int fd,
				    int access,
				    char *fileObjectName);

/* Creates the Symbols that the VM knows about, and initializes
   the globals in the Smalltalk dictionary. */
static void init_runtime_objects (void);

/* Creates the VMPrimitives dictionary, which maps primitive names
   to primitive numbers. */
static void init_primitives_dictionary (void);

/* Creates the CSymbols pool dictionary, which gives access from
   Smalltalk to some definitions in float.h and config.h. */
static void init_c_symbols (void);

static const char *feature_strings[] = {
#ifdef MACHINE_DEFINES
  MACHINE_DEFINES
#endif
#ifdef ENABLE_DLD
    "DLD",
#endif
  NULL
};



/* The class definition structure.  From this structure, the initial
   set of Smalltalk classes are defined.  */

static const class_definition class_info[] = {
  {&_gst_object_class, NULL,
   true, false, false, 0,
   "Object", NULL, "Dependencies FinalizableObjects", NULL },

  {&_gst_object_memory_class, &_gst_object_class,
   true, false, false, 34,
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
   true, false, false, 2,
   "Message", "selector args", NULL, NULL },

  {&_gst_directed_message_class, &_gst_message_class,
   true, false, false, 1,
   "DirectedMessage", "receiver", NULL, NULL },

  {&_gst_magnitude_class, &_gst_object_class,
   true, false, false, 0,
   "Magnitude", NULL, NULL, NULL },

  {&_gst_char_class, &_gst_magnitude_class,
   false, true, true, 0,	/* has 1 indexed var */
   "Character", NULL, "Table", NULL },

  {&_gst_time_class, &_gst_magnitude_class,
   true, false, false, 1,
   "Time", "seconds",
   "SecondClockAdjustment ClockOnStartup", NULL },

  {&_gst_date_class, &_gst_magnitude_class,
   true, false, false, 4,
   "Date", "days day month year",
   "DayNameDict MonthNameDict", NULL },

  {&_gst_number_class, &_gst_magnitude_class,
   true, false, false, 0,
   "Number", NULL, NULL, NULL },

  {&_gst_float_class, &_gst_number_class,
   false, false, true, 0,
   "Float", NULL, NULL, "CSymbols" },

  {&_gst_floatd_class, &_gst_float_class,
   false, false, true, 0,
   "FloatD", NULL, NULL, "CSymbols" },

  {&_gst_floate_class, &_gst_float_class,
   false, false, true, 0,
   "FloatE", NULL, NULL, "CSymbols" },

  {&_gst_floatq_class, &_gst_float_class,
   false, false, true, 0,
   "FloatQ", NULL, NULL, "CSymbols" },

  {&_gst_fraction_class, &_gst_number_class,
   true, false, false, 2,
   "Fraction", "numerator denominator", "Zero One", NULL },

  {&_gst_integer_class, &_gst_number_class,
   false, false, false, 0,
   "Integer", NULL, NULL, "CSymbols" },

  {&_gst_small_integer_class, &_gst_integer_class,
   false, false, false, 0,
   "SmallInteger", NULL, NULL, NULL },

  {&_gst_large_integer_class, &_gst_integer_class,	/* these four
							   classes
							   added by */
   false, false, true, 0,	/* pb Sep 10 18:06:49 1998 */
   "LargeInteger", NULL,
   "Zero One ZeroBytes OneBytes LeadingZeros TrailingZeros", NULL },

  {&_gst_large_positive_integer_class, &_gst_large_integer_class,
   false, false, true, 0,
   "LargePositiveInteger", NULL, NULL, NULL },

  {&_gst_large_zero_integer_class, &_gst_large_positive_integer_class,
   false, false, true, 0,
   "LargeZeroInteger", NULL, NULL, NULL },

  {&_gst_large_negative_integer_class, &_gst_large_integer_class,
   false, false, true, 0,
   "LargeNegativeInteger", NULL, NULL, NULL },

  {&_gst_lookup_key_class, &_gst_magnitude_class,
   true, false, false, 1,
   "LookupKey", "key", NULL, NULL },

  {&_gst_association_class, &_gst_lookup_key_class,
   true, false, false, 1,
   "Association", "value", NULL, NULL },

  {&_gst_homed_association_class, &_gst_association_class,
   true, false, false, 1,
   "HomedAssociation", "environment", NULL, NULL },

  {&_gst_variable_binding_class, &_gst_homed_association_class,
   true, false, false, 0,
   "VariableBinding", NULL, NULL, NULL },

  {&_gst_link_class, &_gst_object_class,
   true, false, false, 1,
   "Link", "nextLink", NULL, NULL },

  {&_gst_process_class, &_gst_link_class,
   true, false, false, 7,
   "Process",
   "suspendedContext priority myList name unwindPoints interrupts interruptLock",
   NULL, NULL },

  {&_gst_callin_process_class, &_gst_process_class,
   true, false, false, 1,
   "CallinProcess",
   "returnedValue",
   NULL, NULL },

  {&_gst_sym_link_class, &_gst_link_class,
   true, false, false, 1,
   "SymLink", "symbol", NULL, NULL },

  {&_gst_collection_class, &_gst_object_class,
   true, false, false, 0,
   "Collection", NULL, NULL, NULL },

  {&_gst_sequenceable_collection_class, &_gst_collection_class,
   true, false, false, 0,
   "SequenceableCollection", NULL, NULL, NULL },

  {&_gst_linked_list_class, &_gst_sequenceable_collection_class,
   true, false, false, 2,
   "LinkedList", "firstLink lastLink", NULL, NULL },

  {&_gst_semaphore_class, &_gst_linked_list_class,
   true, false, false, 2,
   "Semaphore", "signals name", NULL, NULL },

  {&_gst_arrayed_collection_class, &_gst_sequenceable_collection_class,
   true, false, true, 0,
   "ArrayedCollection", NULL, NULL, NULL },

  {&_gst_array_class, &_gst_arrayed_collection_class,
   true, false, true, 0,
   "Array", NULL, NULL, NULL },

  {&_gst_character_array_class, &_gst_arrayed_collection_class,
   false, true, true, 0,
   "CharacterArray", NULL, NULL, NULL },

  {&_gst_string_class, &_gst_character_array_class,
   false, false, true, 0,
   "String", NULL, NULL, NULL },

  {&_gst_symbol_class, &_gst_string_class,
   false, false, true, 0,
   "Symbol", NULL, NULL, NULL },

  {&_gst_byte_array_class, &_gst_arrayed_collection_class,
   false, false, true, 0,
   "ByteArray", NULL, NULL, "CSymbols" },

  {&_gst_compiled_code_class, &_gst_arrayed_collection_class,
   false, false, true, 2,
   "CompiledCode", "literals header",
   NULL, NULL },

  {&_gst_compiled_block_class, &_gst_compiled_code_class,
   false, false, true, 1,
   "CompiledBlock", "method",
   NULL, NULL },

  {&_gst_compiled_method_class, &_gst_compiled_code_class,
   false, false, true, 1,
   "CompiledMethod", "descriptor ",
   NULL, NULL },

  {&_gst_interval_class, &_gst_arrayed_collection_class,
   true, false, false, 3,
   "Interval", "start stop step", NULL, NULL },

  {&_gst_ordered_collection_class, &_gst_sequenceable_collection_class,
   true, false, true, 2,
   "OrderedCollection", "firstIndex lastIndex", NULL, NULL },

  {&_gst_sorted_collection_class, &_gst_ordered_collection_class,
   true, false, true, 3,
   "SortedCollection", "lastOrdered sorted sortBlock",
   "DefaultSortBlock",
   NULL },

  {&_gst_bag_class, &_gst_collection_class,
   true, false, false, 1,
   "Bag", "contents", NULL, NULL },

  {&_gst_mapped_collection_class, &_gst_collection_class,
   true, false, false, 2,
   "MappedCollection", "domain map", NULL, NULL },

  {&_gst_hashed_collection_class, &_gst_collection_class,
   true, false, true, 1,
   "HashedCollection", "tally", NULL, NULL },

  {&_gst_set_class, &_gst_hashed_collection_class,
   true, false, true, 0,
   "Set", NULL, NULL, NULL },

  {&_gst_identity_set_class, &_gst_set_class,
   true, false, true, 0,
   "IdentitySet", NULL, NULL, NULL },

  {&_gst_dictionary_class, &_gst_hashed_collection_class,
   true, false, true, 0,
   "Dictionary", NULL, NULL, NULL },

  {&_gst_lookup_table_class, &_gst_dictionary_class,
   true, false, true, 1,
   "LookupTable", "values", NULL, NULL },

  {&_gst_identity_dictionary_class, &_gst_lookup_table_class,
   true, false, true, 0,
   "IdentityDictionary", NULL, NULL, NULL },

  {&_gst_method_dictionary_class, &_gst_lookup_table_class,
   true, false, true, 0,
   "MethodDictionary", NULL, NULL, NULL },

  /* These five MUST have the same structure as dictionary; they're
     used interchangeably within the C portion of the system */
  {&_gst_binding_dictionary_class, &_gst_dictionary_class,
   true, false, true, 1,
   "BindingDictionary", "environment", NULL, NULL },

  {&_gst_abstract_namespace_class, &_gst_binding_dictionary_class,
   true, false, true, 2,
   "AbstractNamespace", "name subspaces", NULL, NULL },

  {&_gst_root_namespace_class, &_gst_abstract_namespace_class,
   true, false, true, 0,
   "RootNamespace", NULL, NULL, NULL },

  {&_gst_namespace_class, &_gst_abstract_namespace_class,
   true, false, true, 0,
   "Namespace", NULL, "Current", NULL },

  {&_gst_system_dictionary_class, &_gst_root_namespace_class,
   true, false, true, 0,
   "SystemDictionary", NULL, NULL, NULL },

  {&_gst_stream_class, &_gst_object_class,
   true, false, false, 0,
   "Stream", NULL, NULL, NULL },

  {&_gst_token_stream_class, &_gst_stream_class,
   true, false, false, 1,
   "TokenStream", "charStream", NULL, NULL },

  {&_gst_positionable_stream_class, &_gst_stream_class,
   true, false, false, 4,
   "PositionableStream", "collection ptr endPtr access", NULL, NULL },

  {&_gst_read_stream_class, &_gst_positionable_stream_class,
   true, false, false, 0,
   "ReadStream", NULL, NULL, NULL },

  {&_gst_write_stream_class, &_gst_positionable_stream_class,
   true, false, false, 0,
   "WriteStream", NULL, NULL, NULL },

  {&_gst_read_write_stream_class, &_gst_write_stream_class,
   true, false, false, 0,
   "ReadWriteStream", NULL, NULL, NULL },

  {&_gst_byte_stream_class, &_gst_read_write_stream_class,
   true, false, false, 0,
   "ByteStream", NULL, NULL, NULL },

  {&_gst_file_descriptor_class, &_gst_byte_stream_class,
   true, false, false, 4,
   "FileDescriptor", "file name isPipe atEnd", NULL, NULL },

  {&_gst_file_stream_class, &_gst_file_descriptor_class,
   true, false, false, 2,
   "FileStream", "writePtr writeEnd", "Verbose Record Includes", NULL },

  {&_gst_random_class, &_gst_stream_class,
   true, false, false, 1,
   "Random", "seed", "Source", NULL },

  {&_gst_undefined_object_class, &_gst_object_class,
   true, false, false, 0,
   "UndefinedObject", NULL, NULL, NULL },

  {&_gst_boolean_class, &_gst_object_class,
   true, false, false, 0,
   "Boolean", NULL, NULL, NULL },

  {&_gst_false_class, &_gst_boolean_class,
   true, false, false, 1,
   "False", "truthValue", NULL, NULL },

  {&_gst_true_class, &_gst_boolean_class,
   true, false, false, 1,
   "True", "truthValue", NULL, NULL },

  {&_gst_processor_scheduler_class, &_gst_object_class,
   true, false, false, 6,
   "ProcessorScheduler",
   "processLists activeProcess idleTasks processTimeslice gcSemaphore gcArray",
   NULL, NULL },

  {&_gst_delay_class, &_gst_object_class,
   true, false, false, 2,
   "Delay", "resumptionTime isRelative",
   "Queue TimeoutSem MutexSem DelayProcess IdleProcess", NULL },

  {&_gst_shared_queue_class, &_gst_object_class,
   true, false, false, 3,
   "SharedQueue", "queueSem valueReady queue", NULL, NULL },

  /* Change this, classDescription, or gst_class, and you must change
     the implementaion of new_metaclass some */
  {&_gst_behavior_class, &_gst_object_class,
   true, false, false, 5,
   "Behavior",
   "superClass subClasses methodDictionary instanceSpec instanceVariables",
   NULL, NULL },

  {&_gst_class_description_class, &_gst_behavior_class,
   true, false, false, 0,
   "ClassDescription", NULL, NULL, NULL },

  {&_gst_class_class, &_gst_class_description_class,
   true, false, false, 6,
   "Class",
   "name comment category environment classVariables sharedPools",
   NULL, NULL },

  {&_gst_metaclass_class, &_gst_class_description_class,
   true, false, false, 1,
   "Metaclass", "instanceClass", NULL, NULL },

  {&_gst_context_part_class, &_gst_object_class,
   true, false, true, 6,
   "ContextPart", "parent nativeIP ip sp receiver method ",
   "UnwindPoints", NULL },

  {&_gst_method_context_class, &_gst_context_part_class,
   true, false, true, 1,
   "MethodContext", "flags ", NULL, NULL },

  {&_gst_block_context_class, &_gst_context_part_class,
   true, false, true, 1,
   "BlockContext", "outerContext ", NULL, NULL },

  {&_gst_block_closure_class, &_gst_object_class,
   true, false, false, 3,
   "BlockClosure", "outerContext block receiver", NULL, NULL },


/***********************************************************************
 *
 *	End of Standard Smalltalk gst_class definitions.  The definitions below are
 *	specific to GNU Smalltalk.
 *
 ***********************************************************************/

  {&_gst_c_object_class, &_gst_object_class,
   false, true, true, 1,	/* leave this this way */
   "CObject", "type", NULL, "CSymbols" },

  {&_gst_c_type_class, &_gst_object_class,
   true, false, false, 1,
   "CType", "cObjectType", NULL, NULL },

  {&_gst_c_func_descriptor_class, &_gst_object_class,
   true, false, true, 4,
   "CFunctionDescriptor",
   "cFunction cFunctionName returnType numFixedArgs",
   NULL, NULL },

  {&_gst_memory_class, &_gst_object_class,
   false, true, true, 0,
   "Memory", NULL, NULL, NULL },

  {&_gst_method_info_class, &_gst_object_class,
   true, false, false, 4,
   "MethodInfo", "sourceCode category class selector", NULL, NULL },

  {&_gst_file_segment_class, &_gst_object_class,
   true, false, false, 3,
   "FileSegment", "file startPos size", NULL, NULL }

/* Classes not defined here (like Point/Rectangle/RunArray) are
   defined after the kernel has been fully initialized. */
};



void
init_proto_oops()
{
  gst_namespace smalltalkDictionary;
  mst_Object symbolTable, processorScheduler;
  int numWords;

  /* We can do this now that the classes are defined */
  _gst_init_builtin_objects_classes ();

  /* Also finish the creation of the OOPs with reserved indices in
     oop.h */

  /* the symbol table ... */
  numWords = OBJ_HEADER_SIZE_WORDS + SYMBOL_TABLE_SIZE;
  symbolTable = _gst_alloc_words (numWords);
  SET_OOP_OBJECT (_gst_symbol_table, symbolTable);

  symbolTable->objClass = _gst_array_class;
  nil_fill (symbolTable->data,
	    numWords - OBJ_HEADER_SIZE_WORDS);

  numWords = OBJ_HEADER_SIZE_WORDS + INITIAL_SMALLTALK_SIZE + 4;

  /* ... now the Smalltalk dictionary ... */
  smalltalkDictionary = (gst_namespace) _gst_alloc_words (numWords);
  SET_OOP_OBJECT (_gst_smalltalk_dictionary, smalltalkDictionary);

  smalltalkDictionary->objClass = _gst_system_dictionary_class;
  smalltalkDictionary->tally = FROM_INT(0);
  smalltalkDictionary->name = _gst_intern_string ("Smalltalk");
  smalltalkDictionary->superspace = _gst_nil_oop;
  smalltalkDictionary->subspaces = _gst_nil_oop;
  nil_fill (smalltalkDictionary->assoc,
	    INITIAL_SMALLTALK_SIZE);

  /* ... and finally Processor */
  numWords = sizeof (struct gst_processor_scheduler) / sizeof (long);
  processorScheduler = _gst_alloc_words (numWords);
  SET_OOP_OBJECT (_gst_processor_oop, processorScheduler);

  processorScheduler->objClass = _gst_processor_scheduler_class;
  nil_fill (processorScheduler->data,
	    numWords - OBJ_HEADER_SIZE_WORDS);
}

void
_gst_init_dictionary (void)
{
  /* The order of this must match the indices defined in oop.h!! */
  _gst_smalltalk_dictionary = alloc_oop (NULL, _gst_mem.active_flag);
  _gst_processor_oop = alloc_oop (NULL, _gst_mem.active_flag);
  _gst_symbol_table = alloc_oop (NULL, _gst_mem.active_flag);

  create_classes_pass1 ();

  init_proto_oops();
  init_smalltalk_dictionary ();

  create_classes_pass2 ();

  add_smalltalk ("KernelFilePath",
		 _gst_string_new (_gst_kernel_file_default_path));

  init_runtime_objects ();

  _gst_tenure_all_survivors ();
}

void
create_classes_pass1 (void)
{
  const class_definition *ci;
  OOP parentClassOOP;

  /* Because all of the classes in class_info are in the root set, we
     never need to validate them */
  for (ci = class_info; 
       ci < class_info + sizeof(class_info) / sizeof(class_definition);
       ci++)
    {
      if (ci->superClassPtr == NULL)
	parentClassOOP = (OOP) NULL;
      else
	parentClassOOP = *ci->superClassPtr;

      *ci->classVar =
	new_class (parentClassOOP, ci->isPointers, ci->isWords,
		   ci->isIndexable, ci->numFixedFields);
    }
}

void
create_classes_pass2 (void)
{
  const class_definition *ci;
  OOP class_oop, superClassOOP;
  gst_class class, superclass;
  mst_Object subClasses;
  long index;

  /* Because all of the classes in class_info are in the root set, we
     never need to validate them */
  for (ci = class_info; 
       ci < class_info + sizeof(class_info) / sizeof(class_definition);
       ci++)
    {
      class_oop = *ci->classVar;
      class = (gst_class) OOP_TO_OBJ (class_oop);
      class->name = _gst_intern_string (ci->name);
      add_smalltalk (ci->name, class_oop);
      class->methodDictionary = _gst_nil_oop;
      index = TO_INT (class->subClasses);
      if (class_oop == _gst_class_class)
	{
	  /* Object class being a subclass of gst_class is not an apparent link,
	     and so the index which is the number of subclasses of the class
	     is off by one.  We correct that here. */
	  index++;
	}

      subClasses = new_instance_with (_gst_array_class, index, &class->subClasses);
      if (index > 0)
	subClasses->data[0] = FROM_INT (index);

      if (class_oop == _gst_class_class)
	/* we don't want the meta class to have a subclass if we're special
	   casing Object class, so back off the number of sub classes for
	   the meta class. */
	index--;

      if (class_oop == _gst_object_class)
	/* _gst_nil_oop wasn't available during pass1, but now it is */
	class->superclass = _gst_nil_oop;
      else
	{
	  /* hack the parent's subclass array */
	  superClassOOP = class->superclass;
	  add_subclass (superClassOOP, class_oop);
	  if (class_oop == _gst_class_class)
	    {
	      /* here's where we patch in Object class is-a-subclass-of 
	         gst_class */
	      superclass =
		(gst_class) OOP_TO_OBJ (OOP_CLASS (_gst_object_class));
	      superclass->superclass = class_oop;
	      add_subclass (class_oop, OOP_CLASS (_gst_object_class));
	    }
	}

      class->objClass = new_metaclass (class_oop, index);
      class->environment = _gst_smalltalk_dictionary;
      class->instanceVariables =
	_gst_make_instance_variable_array (class->superclass,
					   ci->instVarNames);
      class->classVariables =
	_gst_make_class_variable_dictionary (ci->classVarNames, class_oop);
      class->sharedPools = _gst_make_pool_array (ci->sharedPoolNames);

      class->comment = _gst_nil_oop;	/* not used yet. */
      class->category = _gst_nil_oop;	/* not used yet. */
    }
}

OOP
new_metaclass (OOP class_oop,
	       int numSubClasses)
{
  OOP superClassOOP, metaclassOOP;
  gst_metaclass metaclass;
  mst_Object subClasses;

  metaclass = (gst_metaclass) new_instance (_gst_metaclass_class,
					    &metaclassOOP);
  superClassOOP = SUPERCLASS (class_oop);

  if (class_oop == _gst_object_class)
    /* Object case: make this be gst_class to close the circularity */
    metaclass->superclass = _gst_class_class;
  else
    {
      metaclass->superclass = OOP_CLASS (superClassOOP);
      add_subclass (metaclass->superclass, metaclassOOP);
    }

  /* the specifications here should match what a class should have:
     instance variable names, the right number of instance variables,
     etc.  We could take three passes, and use the instance variable
     spec for classes once it's established, but it's easier to create
     them here by hand */
  metaclass->instanceVariables =
    _gst_make_instance_variable_array (_gst_nil_oop,
				       "superclass subClasses methodDictionary instanceSpec \
instanceVariables name comment category environment \
classVariables sharedPools");

  subClasses = new_instance_with (_gst_array_class, numSubClasses,
		     		  &metaclass->subClasses);
  if (numSubClasses > 0)
    subClasses->data[0] = FROM_INT (numSubClasses);

  metaclass->methodDictionary = _gst_nil_oop;
  metaclass->instanceSpec = ISP_INTMARK | ISP_ISPOINTERS |
    (((sizeof (struct gst_class) -
       sizeof (gst_object_header)) /
      sizeof (OOP)) << ISP_NUMFIXEDFIELDS);

  metaclass->instanceClass = class_oop;

  return (metaclassOOP);
}

void
add_subclass (OOP superClassOOP,
	       OOP subClassOOP)
{
  gst_class_description superclass;
  int index;

  superclass = (gst_class_description) OOP_TO_OBJ (superClassOOP);

  if (NUM_WORDS (OOP_TO_OBJ (superclass->subClasses)) > 0)
    {
      index = TO_INT (ARRAY_AT (superclass->subClasses, 1));
      ARRAY_AT_PUT (superclass->subClasses, 1, FROM_INT (index - 1));
      ARRAY_AT_PUT (superclass->subClasses, index, subClassOOP);
    }
  else
    _gst_errorf ("Attempt to add subclass to zero sized class");
}

void
init_smalltalk_dictionary (void)
{
  OOP featuresArrayOOP;
  mst_Object featuresArray;
  char fullVersionString[200];
  int i, numFeatures;

  _gst_current_namespace = _gst_smalltalk_dictionary;
  _gst_c_object_type_ctype = _gst_c_type_new (_gst_c_object_class);

  for (numFeatures = 0; feature_strings[numFeatures]; numFeatures++);

  featuresArray = new_instance_with (_gst_array_class, numFeatures,
		     		     &featuresArrayOOP);

  for (i = 0; i < numFeatures; i++)
    featuresArray->data[i] = _gst_intern_string (feature_strings[i]);

  sprintf (fullVersionString, "GNU Smalltalk version %s", VERSION);

  add_smalltalk ("Smalltalk", _gst_smalltalk_dictionary);
  add_smalltalk ("Version", _gst_string_new (fullVersionString));
  add_smalltalk ("CObjectType", _gst_c_object_type_ctype);
  add_smalltalk ("KernelInitialized", _gst_false_oop);
  add_smalltalk ("SymbolTable", _gst_symbol_table);
  add_smalltalk ("Processor", _gst_processor_oop);
  add_smalltalk ("Features", featuresArrayOOP);

  _gst_init_symbols ();

  /* Add subspaces */
  add_smalltalk ("CSymbols",
    namespace_new (32, "CSymbols", _gst_smalltalk_dictionary));

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
add_smalltalk (char *globalName,
	       OOP globalValue)
{
  NAMESPACE_AT_PUT (_gst_smalltalk_dictionary,
		    _gst_intern_string (globalName), globalValue);

  return globalValue;
}

void
init_runtime_objects (void)
{
  add_smalltalk ("KernelFileSystemPath", _gst_string_new (KERNEL_PATH));
  add_smalltalk ("ModulePath", _gst_string_new (MODULE_PATH));
  add_smalltalk ("KernelFileLocalPath",
		 _gst_string_new (_gst_kernel_file_default_path));
  add_smalltalk ("ImageFilePath",
		 _gst_string_new (_gst_image_file_default_path));
  add_smalltalk ("ImageFileName",
		 _gst_string_new (_gst_binary_image_name));
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
  init_primitives_dictionary ();

  /* Add the root among the roots :-) to the root set */
  _gst_register_oop (_gst_smalltalk_dictionary);
}

void
init_c_symbols ()
{
  OOP cSymbolsOOP = dictionary_at (_gst_smalltalk_dictionary,
				   _gst_intern_string ("CSymbols"));

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
		    FROM_INT (DBL_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleBinaryDigits"),
		    FROM_INT (DBL_MANT_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleMinExp"),
		    FROM_INT (DBL_MIN_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleMaxExp"),
		    FROM_INT (DBL_MAX_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CDoubleAlignment"),
		    FROM_INT (DOUBLE_ALIGNMENT));

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
		    FROM_INT (FLT_DIG));
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
		    FROM_INT (LDBL_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleBinaryDigits"),
		    FROM_INT (LDBL_MANT_DIG));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleMinExp"),
		    FROM_INT (LDBL_MIN_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleMaxExp"),
		    FROM_INT (LDBL_MAX_EXP));
  NAMESPACE_AT_PUT (cSymbolsOOP, _gst_intern_string ("CLongDoubleAlignment"),
		    FROM_INT (LONG_DOUBLE_ALIGNMENT));
}

void
init_primitives_dictionary ()
{
  OOP primDictionaryOOP = identity_dictionary_new (512);
  int i;

  add_smalltalk ("VMPrimitives", primDictionaryOOP);
  for (i = 0; i < NUM_PRIMITIVES; i++)
    {
      prim_table_entry *pte = _gst_get_primitive_attributes (i);

      if (pte->name)
	{
	  OOP keyOOP = _gst_intern_string (pte->name);
	  OOP valueOOP = FROM_INT (i);
	  _gst_identity_dictionary_at_put (primDictionaryOOP, keyOOP, valueOOP);
	}
    }
}

void
add_file_stream_object (int fd,
			int access,
			char *fileObjectName)
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


OOP
new_class (OOP superClassOOP,
	   mst_Boolean isPointers,
	   mst_Boolean isWords,
	   mst_Boolean isIndexable,
	   int numFixedFields)
{
  gst_class class, superclass;
  long superInstanceSpec;
  OOP classOOP;

  if (superClassOOP != (OOP) NULL)
    {
      /* adjust the number of instance variables to account for
         inheritance */
      superInstanceSpec = CLASS_INSTANCE_SPEC (superClassOOP);
      numFixedFields += superInstanceSpec >> ISP_NUMFIXEDFIELDS;
      superclass = (gst_class) OOP_TO_OBJ (superClassOOP);
      superclass->subClasses =
	FROM_INT (TO_INT (superclass->subClasses) + 1);
    }

  class = (gst_class) _gst_alloc_obj (sizeof (struct gst_class), &classOOP);

  class->objClass = NULL;
  class->superclass = superClassOOP;
  class->instanceSpec = ISP_INTMARK |
    (isPointers ? ISP_ISPOINTERS : 0) |
    (isWords ? ISP_ISWORDS : 0) |
    (isIndexable ? ISP_ISINDEXABLE : 0) |
    (numFixedFields << ISP_NUMFIXEDFIELDS);

  class->subClasses = FROM_INT (0);

  return (classOOP);
}


mst_Boolean
_gst_init_dictionary_on_image_load (long numOOPs)
{
  const class_definition *ci;
  OOP oop;
  int primitive_numbers_map[NUM_PRIMITIVES];

  _gst_smalltalk_dictionary = OOP_AT (smalltalkOOPIndex);
  _gst_processor_oop = OOP_AT (processorOOPIndex);
  _gst_symbol_table = OOP_AT (symbolTableOOPIndex);

  if (IS_NIL (_gst_processor_oop) || IS_NIL (_gst_symbol_table)
      || IS_NIL (_gst_smalltalk_dictionary))
    return (false);

  for (ci = class_info; 
       ci < class_info + sizeof(class_info) / sizeof(class_definition);
       ci++)
    {
      *ci->classVar = dictionary_at (_gst_smalltalk_dictionary,
				     _gst_intern_string (ci->name));
      if UNCOMMON (IS_NIL (*ci->classVar))
	return (false);
    }

  _gst_current_namespace =
    dictionary_at (_gst_class_variable_dictionary
		   (_gst_namespace_class),
		   _gst_intern_string ("Current"));

  _gst_c_object_type_ctype = dictionary_at (_gst_smalltalk_dictionary,
					    _gst_intern_string
					    ("CObjectType"));

  _gst_init_builtin_objects_classes ();
  _gst_init_symbols ();

  /* Important: this is called *before* init_runtime_objects
     fills the VMPrimitives dictionary and *after* _gst_init_symbols
     fills in _gst_vm_primitives_symbol! */
  prepare_primitive_numbers_map (primitive_numbers_map);

  init_runtime_objects ();

  for (oop = _gst_mem.ot_base; oop < &_gst_mem.ot[numOOPs]; oop++)
    {
      if (!IS_OOP_VALID_GC (oop))
	continue;

      if UNCOMMON (OOP_CLASS (oop) == _gst_c_func_descriptor_class)
        _gst_restore_cfunc_descriptor (oop); /* in cint.c */
      else if UNCOMMON (OOP_CLASS (oop) == _gst_compiled_method_class)
        _gst_restore_primitive_number (oop, primitive_numbers_map);
      else if UNCOMMON (OOP_CLASS (oop) == _gst_callin_process_class)
        _gst_terminate_process (oop);
    }

  return (true);
}

void
prepare_primitive_numbers_map (int *map)
{
  int i;

  memzero (map, NUM_PRIMITIVES * sizeof (int));
  for (i = 0; i < NUM_PRIMITIVES; i++)
    {
      prim_table_entry *pte = _gst_get_primitive_attributes (i);

      if (pte->name)
	{
	  int old_index = _gst_resolve_primitive_name (pte->name);
	  map[old_index] = i;
	  /* printf ("Old primitive %d is now %d\n", old_index, i); */
	}
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
      OOP identDict;
      mst_Object obj;
      identDict = identity_dictionary_new (32);
      obj = OOP_TO_OBJ (identDict);
      obj->objClass = _gst_method_dictionary_class;
      class = (gst_class) OOP_TO_OBJ (class_oop);
      class->methodDictionary = identDict;
    }

  return (class->methodDictionary);
}

int
_gst_resolve_primitive_name (char *name)
{
  OOP primitivesDictionaryOOP;
  gst_identity_dictionary primitivesDictionary;
  OOP symbolOOP, valueOOP;
  int index;

  symbolOOP = _gst_intern_string (name);

  primitivesDictionaryOOP = dictionary_at (_gst_smalltalk_dictionary, 
					   _gst_vm_primitives_symbol);

  index = identity_dictionary_find_key (primitivesDictionaryOOP,
					symbolOOP);

  if (index < 0)
    {
      _gst_errorf ("bad primitive name");
      return index;
    }

  primitivesDictionary =
    (gst_identity_dictionary) OOP_TO_OBJ (primitivesDictionaryOOP);

  valueOOP = ARRAY_AT (primitivesDictionary->values, index + 1);
  return TO_INT (valueOOP);
}

OOP
_gst_find_class_method (OOP class_oop,
			OOP selector)
{
  gst_class class;
  gst_identity_dictionary methodDictionary;
  OOP method_dictionary_oop;
  int index;

  class = (gst_class) OOP_TO_OBJ (class_oop);
  method_dictionary_oop = class->methodDictionary;
  if (IS_NIL (method_dictionary_oop))
    return (_gst_nil_oop);

  index =
    identity_dictionary_find_key (method_dictionary_oop,
				  selector);

  if (index < 0)
    return (_gst_nil_oop);

  methodDictionary =
    (gst_identity_dictionary) OOP_TO_OBJ (method_dictionary_oop);

#ifndef OPTIMIZE
  if (!IS_OOP_ADDR (ARRAY_AT (methodDictionary->values, index + 1)))
    abort ();
#endif

  return (ARRAY_AT (methodDictionary->values, index + 1));
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
_gst_find_shared_pool_variable (OOP poolOOP,
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


int
new_num_fields (int oldNumFields)
{
  /* Find a power of two that is larger than oldNumFields */

  int n = 1;

  /* Already a power of two? duplicate the size */
  if COMMON ((oldNumFields & (oldNumFields - 1)) == 0)
    return oldNumFields * 2;

  /* Find the next power of two by setting all bits to the right of
     the leftmost 1 bit to 1, and then incrementing. */
  for (; oldNumFields & (oldNumFields + 1); n <<= 1)
    oldNumFields |= oldNumFields >> n;

  return oldNumFields + 1;
}

static int
find_key_or_nil (OOP dictionaryOOP,
		 OOP keyOOP)
{
  long count, numFields, numFixedFields;
  long index;
  mst_Object dictionary;
  OOP associationOOP;
  gst_association association;

  dictionary = (mst_Object) OOP_TO_OBJ (dictionaryOOP);
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

mst_Object
_gst_grow_dictionary (OOP oldDictionaryOOP)
{
  mst_Object oldDictionary, dictionary;
  long oldNumFields, numFields, i, index, numFixedFields;
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
  memcpy (dictionary->data, oldDictionary->data, SIZEOF_LONG * numFixedFields);
  oldDictionary = OOP_TO_OBJ (dictionaryOOP);

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

gst_identity_dictionary
_gst_grow_identity_dictionary (OOP oldIdentityDictionaryOOP)
{
  gst_identity_dictionary oldIdentityDictionary, identityDictionary;
  mst_Object values, oldValues;
  OOP key, valuesOOP, oldValuesOOP, oldOOP, identityDictionaryOOP;
  long oldNumFields, numFields, i, index;
  inc_ptr incPtr;


  oldIdentityDictionary =
    (gst_identity_dictionary) OOP_TO_OBJ (oldIdentityDictionaryOOP);
  oldNumFields =
    NUM_WORDS (oldIdentityDictionary) - 2;

  numFields = new_num_fields (oldNumFields);
  oldValuesOOP = oldIdentityDictionary->values;

  incPtr = INC_SAVE_POINTER ();
  instantiate_with (_gst_array_class, numFields, &valuesOOP);
  INC_ADD_OOP (valuesOOP);

  identityDictionary = (gst_identity_dictionary)
    instantiate_with (OOP_CLASS (oldIdentityDictionaryOOP), numFields,
		      &identityDictionaryOOP);

  oldIdentityDictionary =
    (gst_identity_dictionary) OOP_TO_OBJ (oldIdentityDictionaryOOP);

  identityDictionary->tally = oldIdentityDictionary->tally;
  identityDictionary->values = valuesOOP;

  values = OOP_TO_OBJ (valuesOOP);
  oldValues = OOP_TO_OBJ (oldValuesOOP);

  /* rehash all associations from old dictionary into new one */
  for (i = 0; i < oldNumFields; i++)
    {
      key = oldIdentityDictionary->keys[i];
      if COMMON (!IS_NIL (key))
	{
	  index =
	    identity_dictionary_find_key_or_nil (identityDictionaryOOP,
						 key);
	  identityDictionary->keys[index] = key;
	  oldOOP = oldValues->data[i];
	  values->data[index] = oldOOP;
	}
    }

  INC_RESTORE_POINTER (incPtr);
  _gst_swap_objects (identityDictionaryOOP, oldIdentityDictionaryOOP);
  return ((gst_identity_dictionary) OOP_TO_OBJ (oldIdentityDictionaryOOP));
}


OOP
identity_dictionary_new (int size)
{
  gst_identity_dictionary identityDictionary;
  inc_ptr incPtr;
  OOP valuesOOP, identityDictionaryOOP;

  size = new_num_fields (size);

  incPtr = INC_SAVE_POINTER ();
  instantiate_with (_gst_array_class, size, &valuesOOP);
  INC_ADD_OOP (valuesOOP);

  identityDictionary = (gst_identity_dictionary)
    instantiate_with (_gst_identity_dictionary_class, size,
		      &identityDictionaryOOP);

  identityDictionary->tally = FROM_INT (0);
  identityDictionary->values = valuesOOP;

  INC_RESTORE_POINTER (incPtr);
  return (identityDictionaryOOP);
}

OOP
_gst_identity_dictionary_at_put (OOP identityDictionaryOOP,
				 OOP keyOOP,
				 OOP valueOOP)
{
  gst_identity_dictionary identityDictionary;
  mst_Object valuesArray;
  long index;
  OOP oldValueOOP;

  identityDictionary =
    (gst_identity_dictionary) OOP_TO_OBJ (identityDictionaryOOP);

  /* Never make dictionaries too full! For simplicity, we do this even
     if the key is present in the dictionary (because it will most
     likely resolve some collisions and make things faster). */

  if UNCOMMON (TO_INT (identityDictionary->tally) >
      	       TO_INT (identityDictionary->objSize) * 3 / 4)
    identityDictionary =
      _gst_grow_identity_dictionary (identityDictionaryOOP);

  index =
    identity_dictionary_find_key_or_nil (identityDictionaryOOP, keyOOP);

  if COMMON (IS_NIL (identityDictionary->keys[index]))
    identityDictionary->tally = INCR_INT (identityDictionary->tally);

  identityDictionary->keys[index] = keyOOP;
  valuesArray = OOP_TO_OBJ (identityDictionary->values);
  oldValueOOP = valuesArray->data[index];
  valuesArray->data[index] = valueOOP;

  return (oldValueOOP);
}

OOP
namespace_new (int size, char *name, OOP superspaceOOP)
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
  long index;
  gst_association association;
  mst_Object dictionary;
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
      dictionary = _gst_grow_dictionary (dictionaryOOP);
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
  mst_Object old, new;
  OOP newOOP;
  long numFields;

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
_gst_new_string (int len)
{
  OOP stringOOP;

  new_instance_with (_gst_string_class, len, &stringOOP);
  return (stringOOP);
}

OOP
_gst_string_new (const char *s)
{
  gst_string string;
  int len;
  OOP stringOOP;

  len = strlen (s);
  string = (gst_string) new_instance_with (_gst_string_class, len,
					   &stringOOP);

  strncpy (string->chars, s, len);
  return (stringOOP);
}

OOP
_gst_counted_string_new (const char *s,
			 int len)
{
  gst_string string;
  OOP stringOOP;

  string = (gst_string) new_instance_with (_gst_string_class, len,
					   &stringOOP);

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

char *
_gst_to_cstring (OOP stringOOP)
{
  char *result;
  int len;
  gst_string string;

  string = (gst_string) OOP_TO_OBJ (stringOOP);
  len = oop_num_fields (stringOOP);
  result = (char *) xmalloc (len + 1);
  strncpy (result, string->chars, len);
  result[len] = '\0';

  return (result);
}

OOP
_gst_byte_array_new (const gst_uchar * bytes,
		     int len)
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
  int len;
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
  long len;

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
_gst_directed_message_new_args (OOP receiverOOP,
				OOP selectorOOP,
			        OOP argsArray)
{
  gst_directed_message dirMessage;
  OOP dirMessageOOP;

  dirMessage = (gst_directed_message) new_instance (_gst_directed_message_class,
						    &dirMessageOOP);

  dirMessage->selector = selectorOOP;
  dirMessage->args = argsArray;
  dirMessage->receiver = receiverOOP;

  return (dirMessageOOP);
}

OOP
_gst_c_object_new_typed (PTR cObjPtr,
			 OOP typeOOP)
{
  gst_cobject cObject;
  gst_ctype cType;
  OOP cObjectOOP;

  cType = (gst_ctype) OOP_TO_OBJ (typeOOP);
  cObject = (gst_cobject) new_instance_with (cType->cObjectType, 1, 
		     			     &cObjectOOP);

  cObject->type = typeOOP;
  SET_COBJECT_VALUE_OBJ (cObject, cObjPtr);

  return (cObjectOOP);
}

OOP
_gst_alloc_cobject (OOP class_oop,
		    long unsigned int size)
{
  PTR space;
  OOP typeOOP, cobjOOP;
  inc_ptr incPtr;

  space = (PTR) xmalloc ((int) size);

  incPtr = INC_SAVE_POINTER ();
  typeOOP = _gst_c_type_new (class_oop);
  INC_ADD_OOP (typeOOP);

  cobjOOP = _gst_c_object_new_typed (space, typeOOP);

  INC_RESTORE_POINTER (incPtr);

  return cobjOOP;
}

void
_gst_free_cobject (OOP cObjOOP)
{
  gst_cobject cObject;

  cObject = (gst_cobject) OOP_TO_OBJ (cObjOOP);
  xfree ((PTR) COBJECT_VALUE_OBJ (cObject));

  /* at least make it not point to falsely valid storage */
  SET_COBJECT_VALUE_OBJ (cObject, NULL);
}

OOP
_gst_c_type_new (OOP cObjectSubclassOOP)
{
  gst_ctype cType;
  OOP cTypeOOP;

  cType = (gst_ctype) new_instance (_gst_c_type_class, &cTypeOOP);
  cType->cObjectType = cObjectSubclassOOP;
  return (cTypeOOP);
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
    case O_WRONLY:
      fileStream->access = FROM_INT (2);
    case O_RDWR:
      fileStream->access = FROM_INT (3);
    }

  if (buffered)
    {
      char buffer[1024];
      memzero (buffer, sizeof (buffer));
      fileStream->collection =
	_gst_counted_string_new (buffer, sizeof (buffer));
      fileStream->ptr = FROM_INT (1);
      fileStream->endPtr = FROM_INT (0);
      fileStream->writePtr = _gst_nil_oop;
      fileStream->writeEnd = _gst_nil_oop;
    }
  else
    {
      fileStream->collection = _gst_nil_oop;
      fileStream->ptr = _gst_nil_oop;
      fileStream->endPtr = _gst_nil_oop;
    }

  fileStream->file = FROM_INT (fd);
  fileStream->name = fileNameOOP;
  fileStream->isPipe =
    isPipe == -1 ? _gst_nil_oop :
    isPipe ? _gst_true_oop : _gst_false_oop;
}
