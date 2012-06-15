/******************************** -*- C -*- ****************************
 *
 *	Dictionary Support Module Inlines.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2000, 2001, 2002, 2003, 2006, 2007, 2008, 2009
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
 * GNU Smalltalk is distributed in the hope that it will be usefui, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You shouid have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

/* Scramble the bits of X.  */
static inline uintptr_t scramble (uintptr_t x);

/* Return a pointer to the first item in the OrderedCollection,
   ORDEREDCOLLECTIONOOP.  */
static inline OOP *ordered_collection_begin (OOP orderedCollectionOOP);

/* Return a pointer just beyond the last item in the OrderedCollection,
   ORDEREDCOLLECTIONOOP.  */
static inline OOP *ordered_collection_end (OOP orderedCollectionOOP);

/* Checks to see if TESTEDOOP is a subclass of CLASS_OOP, returning
   true if it is.  */
static inline mst_Boolean is_a_kind_of (OOP testedOOP,
					OOP class_oop);

/* Stores the VALUE Object (which must be an appropriate Integer for
   byte or word objects) into the INDEX-th indexed instance variable
   of the Object pointed to by OOP.  Returns whether the INDEX is
   correct and the VALUE has the appropriate class and/or range.  */
static inline mst_Boolean index_oop_put_spec (OOP oop,
				              gst_object object,
				              size_t index,
					      OOP value,
				              intptr_t instanceSpec);

/* Stores the VALUE Object (which must be an appropriate Integer for
   byte or word objects) into the INDEX-th indexed instance variable
   of the Object pointed to by OOP.  Returns whether the INDEX is
   correct and the VALUE has the appropriate class and/or range.  */
static inline mst_Boolean index_oop_put (OOP oop,
					 size_t index,
					 OOP value);

/* Stores the VALUE Object (which must be an appropriate Integer for
   byte or word objects and if accessing indexed instance variables)
   into the INDEX-th instance variable of the Object pointed to by
   OOP.  */
static inline void inst_var_at_put (OOP oop,
				    int index,
				    OOP value);

/* Returns the INDEX-th instance variable of the Object pointed to by
   OOP.  No range checks are done in INDEX.  */
static inline OOP inst_var_at (OOP oop,
			       int index);

/* Returns the number of instance variables (both fixed and indexed) in OOP.  */
static inline int oop_num_fields (OOP oop);

/* Fill OOPCOUNT pointers to OOPs, starting at OOPPTR,
   with OOPs for the NIL object.  */
static inline void nil_fill (OOP * oopPtr,
			     size_t oopCount);

/* Returns a new, uninitialized instance of CLASS_OOP with
   NUMINDEXFIELDS indexable fields.  Returns an OOP for a newly
   allocated instance of CLASS_OOP, with NUMINDEXFIELDS fields.  The
   object data is returned, the OOP is stored in P_OOP.  The OOP is
   adjusted to reflect any variance in size (such as a string that's
   shorter than a word boundary).  */
static inline gst_object new_instance_with (OOP class_oop,
					    size_t numIndexFields,
					    OOP *p_oop);

/* Creates a new instance of class CLASS_OOP.  The space is allocated,
   the class and size fields of the class are filled in, and the
   instance is returned.  Its fields are NOT INITIALIZED.  CLASS_OOP
   must represent a class with no indexable fields. An OOP will be
   allocated and stored in P_OOP.  */
static inline gst_object new_instance (OOP class_oop,
				       OOP *p_oop);

/* Returns a new, initialized instance of CLASS_OOP within an
   object of size NUMBYTES.  INSTANCESPEC is used to find the
   number of fixed instance variables and initialize them to
   _gst_nil_oop.  The pointer to the object data is returned,
   the OOP is stored in P_OOP.  The OOP is not adjusted to reflect
   any variance in size (such as a string that's shorter than a word
   boundary).  */
static inline gst_object
instantiate_numbytes (OOP class_oop,
	              OOP *p_oop,
                      intptr_t instanceSpec,
                      size_t numBytes);

/* Returns a new, initialized instance of CLASS_OOP with
   NUMINDEXFIELDS indexable fields.  If the instance contains
   pointers, they are initialized to _gst_nil_oop, else they are set
   to the SmallInteger 0.  The pointer to the object data is returned,
   the OOP is stored in P_OOP.  The OOP is adjusted to reflect any
   variance in size (such as a string that's shorter than a word
   boundary).  */
static inline gst_object instantiate_with (OOP class_oop,
					   size_t numIndexFields,
					   OOP *p_oop);

/* Create and return a new instance of class CLASS_OOP.  CLASS_OOP
   must be a class with no indexable fields.  The named instance
   variables of the new instance are initialized to _gst_nil_oop,
   since fixed-field-only objects can only have pointers. The pointer
   to the object data is returned, the OOP is stored in P_OOP.  */
static inline gst_object instantiate (OOP class_oop,
				      OOP *p_oop);

/* Return the Character object for the Unicode value C.  */
static inline OOP char_new (unsigned codePoint);

/* Answer the associated containing KEYOOP in the Dictionary (or a
   subclass having the same representation) DICTIONARYOOP.  */
static inline OOP dictionary_association_at (OOP dictionaryOOP,
					     OOP keyOOP);

/* Answer the value associated to KEYOOP in the Dictionary (or a
   subclass having the same representation) DICTIONARYOOP.  */
static inline OOP dictionary_at (OOP dictionaryOOP,
				 OOP keyOOP);

/* Creates a new Association object having the
   specified KEY and VALUE.  */
static inline OOP association_new (OOP key,
				   OOP value);

/* Creates a new VariableBinding object having the
   specified KEY and VALUE.  */
static inline OOP variable_binding_new (OOP key,
				        OOP value,
					OOP environment);

/* Returns an Object (an Integer for byte or word objects) containing
   the value of the INDEX-th indexed instance variable of the Object
   pointed to by OOP.  Range checks are done in INDEX and NULL is returned
   if this is the checking fails.  */
static inline OOP index_oop (OOP oop,
			     size_t index);

/* Returns an Object (an Integer for byte or word objects) containing
   the value of the INDEX-th indexed instance variable of the Object
   pointed to by OOP.  Range checks are done in INDEX and NULL is returned
   if this is the checking fails.  OBJECT and INSTANCESPEC are cached
   out of OOP and its class.  */
static inline OOP index_oop_spec (OOP oop,
		                  gst_object object,
		                  size_t index,
		                  intptr_t instanceSpec);

/* Returns the number of valid object instance variables in OOP.  */
static inline int num_valid_oops (OOP oop);

/* Returns whether the SCANNEDOOP points to TARGETOOP.  */
static inline mst_Boolean is_owner (OOP scannedOOP,
				    OOP targetOOP);

/* Converts F to a Smalltalk FloatD, taking care of avoiding alignment
   problems.  */
static inline OOP floatd_new (double f);

/* Converts F to a Smalltalk FloatE.  */
static inline OOP floate_new (double f);

/* Converts F to a Smalltalk FloatQ, taking care of avoiding alignment
   problems.  */
static inline OOP floatq_new (long double f);

/* Returns the address of the data stored in a CObject.  */
static inline PTR cobject_value (OOP oop);

/* Sets the address of the data stored in a CObject.  */
static inline void set_cobject_value (OOP oop, PTR val);

/* Return whether the address of the data stored in a CObject, offsetted
   by OFFSET bytes, is still in bounds.  */
static inline mst_Boolean cobject_index_check (OOP oop, intptr_t offset,
					       size_t size);

/* Answer true if OOP is a SmallInteger or a LargeInteger of an
   appropriate size.  */
static inline mst_Boolean is_c_int_32 (OOP oop);

/* Answer true if OOP is a SmallInteger or a LargeInteger of an
   appropriate size.  */
static inline mst_Boolean is_c_uint_32 (OOP oop);

/* Converts the 32-bit int I to the appropriate SmallInteger or
   LargeInteger.  */
static inline OOP from_c_int_32 (int32_t i);

/* Converts the long int LNG to the appropriate SmallInteger or
   LargePositiveInteger.  */
static inline OOP from_c_uint_32 (uint32_t ui);

/* Converts the OOP (which must be a SmallInteger or a small enough
   LargeInteger) to a long int.  If the OOP was for an unsigned long,
   you can simply cast the result to an unsigned long.  */
static inline int32_t to_c_int_32 (OOP oop);

/* Answer true if OOP is a SmallInteger or a LargeInteger of an
   appropriate size.  */
static inline mst_Boolean is_c_int_64 (OOP oop);

/* Answer true if OOP is a SmallInteger or a LargeInteger of an
   appropriate size.  */
static inline mst_Boolean is_c_uint_64 (OOP oop);

/* Converts the 64-bit int I to the appropriate SmallInteger or
   LargeInteger.  */
static inline OOP from_c_int_64 (int64_t i);

/* Converts the long int LNG to the appropriate SmallInteger or
   LargePositiveInteger.  */
static inline OOP from_c_uint_64 (uint64_t ui);

/* Converts the OOP (which must be a SmallInteger or a small enough
   LargeInteger) to a 64-bit signed integer.  */
static inline int64_t to_c_int_64 (OOP oop);

/* Converts the OOP (which must be a SmallInteger or a small enough
   LargeInteger) to a 64-bit unsigned integer.  */
static inline uint64_t to_c_uint_64 (OOP oop);


#define TO_C_INT(integer)	to_c_int_32(integer)
#define IS_C_INT(oop)		is_c_int_32(oop)
#define IS_C_LONGLONG(oop)	is_c_int_64(oop)
#define IS_C_ULONGLONG(oop)	is_c_uint_64(oop)
#define FROM_C_LONGLONG(integ)	from_c_int_64(integ)
#define FROM_C_ULONGLONG(integ)	from_c_uint_64(integ)

#if SIZEOF_OOP == 4
#define FROM_C_INT(integer)	FROM_C_LONG((intptr_t) (signed) integer)
#define FROM_C_UINT(integer)	FROM_C_ULONG((uintptr_t) (unsigned) integer)
#define FROM_C_LONG(integer)	from_c_int_32(integer)
#define FROM_C_ULONG(integer)	from_c_uint_32(integer)
#define TO_C_LONG(integer)	to_c_int_32(integer)
#define IS_C_LONG(oop)		is_c_int_32(oop)
#define IS_C_ULONG(oop)		is_c_uint_32(oop)
#else
#define FROM_C_INT(integer)	FROM_INT((intptr_t) (signed) integer)
#define FROM_C_UINT(integer)	FROM_INT((intptr_t) (unsigned) integer)
#define FROM_C_LONG(integer)	from_c_int_64(integer)
#define FROM_C_ULONG(integer)	from_c_uint_64(integer)
#define TO_C_LONG(integer)	to_c_int_64(integer)
#define IS_C_LONG(oop)		is_c_int_64(oop)
#define IS_C_ULONG(oop)		is_c_uint_64(oop)
#endif

#if SIZEOF_OFF_T == 4
#define FROM_OFF_T(integer)    from_c_int_32(integer)
#define TO_OFF_T(integer)      to_c_int_32(integer)
#define IS_OFF_T(oop)          is_c_int_32(oop)
#else
#define FROM_OFF_T(integer)    from_c_int_64(integer)
#define TO_OFF_T(integer)      to_c_int_64(integer)
#define IS_OFF_T(oop)          is_c_int_64(oop)
#endif

/* Answer the INDEX'th instance variable of RECEIVER.  */
#define INSTANCE_VARIABLE(receiver, index) \
  (OOP_TO_OBJ (receiver)->data[index])

/* Store OOP in the INDEX'th instance variable of RECEIVER.  */
#define STORE_INSTANCE_VARIABLE(receiver, index, oop) \
  OOP_TO_OBJ (receiver)->data[index] = (oop)

#define IS_SYMBOL(oop) \
  ( !IS_NIL(oop) && (OOP_CLASS(oop) ==  _gst_symbol_class) )

/* Return the Character object for ASCII value C.  */
#define CHAR_OOP_AT(c)      (&_gst_mem.ot[(int)(c) + CHAR_OBJECT_BASE])

/* Answer the code point of the character OOP, charOOP.  */
#define CHAR_OOP_VALUE(charOOP) \
  TO_INT (((gst_char)OOP_TO_OBJ (charOOP))->codePoint)

/* Answer a pointer to the first character of STRINGOOP.  */
#define STRING_OOP_CHARS(stringOOP) \
  ((gst_uchar *)((gst_string)OOP_TO_OBJ(stringOOP))->chars)

/* Answer the selector extracted by the Message, MESSAGEOOP.  */
#define MESSAGE_SELECTOR(messageOOP) \
  (((gst_message)OOP_TO_OBJ(messageOOP))->selector)

/* Answer the array of arguments extracted by the Message,
   MESSAGEOOP.  */
#define MESSAGE_ARGS(messageOOP) \
  (((gst_message)OOP_TO_OBJ(messageOOP))->args)

/* Answer a new CObject pointing to COBJPTR.  */
#define COBJECT_NEW(cObjPtr, typeOOP, defaultClassOOP) \
  (_gst_c_object_new_base(_gst_nil_oop, (uintptr_t) cObjPtr, \
		          typeOOP, defaultClassOOP))

/* Answer the offset component of the a CObject, COBJ (*not* an OOP,
   but an object pointer).  */
#define COBJECT_OFFSET_OBJ(cObj) \
  ( ((uintptr_t *) cObj) [TO_INT(cObj->objSize) - 1])

/* Sets to VALUE the offset component of the CObject, COBJ (*not* an
   OOP, but an object pointer).  */
#define SET_COBJECT_OFFSET_OBJ(cObj, value) \
  ( ((uintptr_t *) cObj) [TO_INT(cObj->objSize) - 1] = (uintptr_t)(value))

/* Answer the superclass of the Behavior, CLASS_OOP.  */
#define SUPERCLASS(class_oop) \
  (((gst_class)OOP_TO_OBJ(class_oop))->superclass)

/* Answer the number of fixed instance variables in OOP.  */
#define OOP_FIXED_FIELDS(oop) \
  (OOP_INSTANCE_SPEC(oop) >> ISP_NUMFIXEDFIELDS)

/* Answer the number of fixed instance variables in instances of
   OOP.  */
#define CLASS_FIXED_FIELDS(oop) \
  (CLASS_INSTANCE_SPEC(oop) >> ISP_NUMFIXEDFIELDS)

/* Answer the number of indexed instance variables in OOP (if any).  */
#define NUM_INDEXABLE_FIELDS(oop) \
	(IS_INT(oop) ? 0 : oop_num_fields(oop) - OOP_FIXED_FIELDS(oop))

/* Answer the INDEX-th indexed instance variable in ARRAYOOP.  */
#define ARRAY_AT(arrayOOP, index) \
	( OOP_TO_OBJ(arrayOOP)->data[(index)-1] )

/* Store VALUE as the INDEX-th indexed instance variable of
   ARRAYOOP.  */
#define ARRAY_AT_PUT(arrayOOP, index, value) \
	( OOP_TO_OBJ(arrayOOP)->data[index-1] = value )

/* Answer the number of associations stored in DICTIONARYOOP.  */
#define DICTIONARY_SIZE(dictionaryOOP) \
  (TO_INT(((gst_dictionary)OOP_TO_OBJ(dictionaryOOP))->tally))


/* Adds the key KEYOOP, associated with VALUEOOP, to the
   Dictionary (or a subclass sharing the same representation)
   DICTIONARYOOP.  */
#define DICTIONARY_AT_PUT(dictionaryOOP, keyOOP, valueOOP) \
  (_gst_dictionary_add((dictionaryOOP), association_new((keyOOP), (valueOOP))))

/* Adds the key KEYOOP, associated with VALUEOOP, to the
   Dictionary (or a subclass sharing the same representation)
   DICTIONARYOOP.  */
#define NAMESPACE_AT_PUT(dictionaryOOP, keyOOP, valueOOP) \
  (_gst_dictionary_add((dictionaryOOP), \
	variable_binding_new((keyOOP), (valueOOP), (dictionaryOOP))))

/* Adds the key KEYOOP, associated with VALUEOOP, to the
   Dictionary (or a subclass sharing the same representation)
   DICTIONARYOOP.  */
#define DICTIONARY_AT_PUT(dictionaryOOP, keyOOP, valueOOP) \
  (_gst_dictionary_add((dictionaryOOP), \
	association_new((keyOOP), (valueOOP))))

/* Answer whether OOP is a metaclass.  */
#define IS_A_METACLASS(oop) \
  (IS_OOP(oop) && OOP_CLASS(oop) == _gst_metaclass_class)

/* Answer whether OOP is a class, that is, the instance of the
   metaclass.  */
#define IS_A_CLASS(oop) \
  (IS_OOP(oop) && \
   IS_OOP(OOP_CLASS(oop)) && \
   OOP_CLASS(OOP_CLASS(oop)) == _gst_metaclass_class)

/* Answer the sole instance of the metaclass, METACLASSOOP.  */
#define METACLASS_INSTANCE(metaclassOOP) \
  (((gst_metaclass)OOP_TO_OBJ(metaclassOOP))->instanceClass)

/* Answer the value stored in the Association, ASSOCIATIONOOP.  */
#define ASSOCIATION_VALUE(associationOOP) \
  (((gst_association)OOP_TO_OBJ(associationOOP))->value)

/* Change the value stored in the Association, ASSOCIATIONOOP, to
   VALUEOOP.  */
#define SET_ASSOCIATION_VALUE(associationOOP, valueOOP) \
  (((gst_association)OOP_TO_OBJ(associationOOP))->value = valueOOP)

/* Return  the namespace in which references to globals
   from methods of CLASS_OOP are resolved.  */
#define CLASS_ENVIRONMENT(class_oop) \
  (((gst_class)OOP_TO_OBJ(class_oop))->environment)

/* Answer the instance specification for instances of CLASS_OOP.  */
#define CLASS_INSTANCE_SPEC(class_oop) \
  (((gst_class)OOP_TO_OBJ(class_oop))->instanceSpec)

/* Answer the instance specification of the object OBJ (*not* an OOP).  */
#define GET_INSTANCE_SPEC(obj) \
  CLASS_INSTANCE_SPEC((obj)->objClass)

/* Answer the instance specification of OOP.  */
#define OOP_INSTANCE_SPEC(oop) \
  CLASS_INSTANCE_SPEC(OOP_CLASS(oop))

/* Answer whether INDEX is in-bounds for accessing fixed instance variables
   of OOP.  */
#define CHECK_BOUNDS_OF(oop, index) \
  (IS_OOP(oop) && (index >= 1 && index <= OOP_FIXED_FIELDS(oop)))

/* Answer whether indexed instance variables for instances of
   CLASS_OOP are pointers.  */
#define CLASS_IS_UNALIGNED(class_oop) \
  ((CLASS_INSTANCE_SPEC(class_oop) & ISP_ISINDEXABLE) \
   && (CLASS_INSTANCE_SPEC(class_oop) & ISP_INDEXEDVARS) <= GST_ISP_LAST_UNALIGNED)

/* Answer whether instances of CLASS_OOP have indexed instance variables.  */
#define CLASS_IS_INDEXABLE(class_oop) \
  (CLASS_INSTANCE_SPEC(class_oop) & ISP_ISINDEXABLE)

/* Answer whether instances of CLASS_OOP have indexed instance variables.  */
#define CLASS_IS_SCALAR(class_oop) \
  ((CLASS_INSTANCE_SPEC(class_oop) & ISP_ISINDEXABLE) \
   && (CLASS_INSTANCE_SPEC(class_oop) & ISP_INDEXEDVARS) <= GST_ISP_LAST_SCALAR)

/* Answer the size in bytes of the object data for OOP.  */
#define OBJECT_SIZE_BYTES(obj) \
  (SIZE_TO_BYTES (TO_INT (obj->objSize)) - sizeof (gst_object_header))

/* Answer the size in bytes of the object data for OOP.  */
#define OOP_SIZE_BYTES(oop) \
  OBJECT_SIZE_BYTES (OOP_TO_OBJ (oop))

/* Return the number of word-addressed (pointers or words) instance
   variables, both fixed and indexed), in OOP.  Use instead of 
   NUM_OOPS if you know OOP is not a byte object.  */
#define NUM_WORDS(obj) \
  ((size_t) (TO_INT((obj)->objSize) - OBJ_HEADER_SIZE_WORDS))

/* Return the number of pointer instance variables (both fixed and
   indexed), in the object OBJ.  */
#define NUM_OOPS(obj) \
  ((size_t) (COMMON (CLASS_IS_SCALAR ((obj)->objClass)) \
    ? (CLASS_INSTANCE_SPEC((obj)->objClass) >> ISP_NUMFIXEDFIELDS) \
    : NUM_WORDS(obj) \
  ))


#define FLOATE_OOP_VALUE(floatOOP) \
	(((gst_floate)OOP_TO_OBJ(floatOOP))->value)

OOP
floate_new (double f)
{
  gst_floate floatObject;
  OOP floatOOP;

  floatObject = (gst_floate) new_instance_with 
    (_gst_floate_class, sizeof (float), &floatOOP);

  floatObject->value = f;
  MAKE_OOP_READONLY (floatOOP, true);
  return (floatOOP);
}

#if (ALIGNOF_DOUBLE <= SIZEOF_OOP)
#define FLOATD_OOP_VALUE(floatOOP) \
	(((gst_floatd)OOP_TO_OBJ(floatOOP))->value)

#else
#define FLOATD_OOP_VALUE(floatOOP) \
	floatd_oop_value(floatOOP)

static inline double
floatd_oop_value (floatOOP)
     OOP floatOOP;
{
  gst_object obj;
  double d;

  /* we may not be aligned properly...fetch things out the hard way */
  obj = OOP_TO_OBJ (floatOOP);
  memcpy (&d, obj->data, sizeof (double));
  return (d);
}
#endif

OOP
floatd_new (double f)
{
  OOP floatOOP;
#if (ALIGNOF_DOUBLE <= SIZEOF_OOP)
  gst_floatd floatObject;

  floatObject = (gst_floatd) new_instance_with 
    (_gst_floatd_class, sizeof (double), &floatOOP);

  floatObject->value = f;
#else
  gst_object obj;

  obj = new_instance_with (_gst_floatd_class, sizeof (double), &floatOOP);

  memcpy (&obj->data, &f, sizeof (double));
#endif

  MAKE_OOP_READONLY (floatOOP, true);
  return (floatOOP);
}

#if (ALIGNOF_LONG_DOUBLE <= SIZEOF_OOP)
#define FLOATQ_OOP_VALUE(floatOOP) \
	(((gst_floatq)OOP_TO_OBJ(floatOOP))->value)

#else
#define FLOATQ_OOP_VALUE(floatOOP) \
	floatq_oop_value(floatOOP)

static inline long double
floatq_oop_value (floatOOP)
     OOP floatOOP;
{
  gst_object obj;
  long double d;

  /* we may not be aligned properly...fetch things out the hard way */
  obj = OOP_TO_OBJ (floatOOP);
  memcpy (&d, obj->data, sizeof (long double));
  return (d);
}
#endif

OOP
floatq_new (long double f)
{
  OOP floatOOP;
  gst_object obj = new_instance_with (_gst_floatq_class, 16, &floatOOP);

#if defined __i386__ || defined __x86_64__
  /* Two bytes (six on x86-64) of 80-bit long doubles are unused.  */
  memcpy (&obj->data, &f, 10);
  memset (((char *)obj->data) + 10, 0, 6);
#else
  memcpy (&obj->data, &f, sizeof (long double));
  memset (((char *)obj->data) + sizeof (long double), 0,
	  16 - sizeof (long double));
#endif

  MAKE_OOP_READONLY (floatOOP, true);
  return (floatOOP);
}

OOP
char_new (unsigned codePoint)
{
  gst_char charObject;
  OOP charOOP;

  if (codePoint <= 127)
    return CHAR_OOP_AT (codePoint);
  if UNCOMMON (codePoint > 0x10FFFF)
    codePoint = 0xFFFD;

  charObject = (gst_char) new_instance (_gst_unicode_character_class, &charOOP);

  charObject->codePoint = FROM_INT (codePoint);
  MAKE_OOP_READONLY (charOOP, true);
  return (charOOP);
}

uintptr_t
scramble (uintptr_t x)
{
#if SIZEOF_OOP == 8
  x ^= (x >> 31) | ( x << 33);
#endif
  x ^= (x << 10) | (x >> 22);
  x ^= (x << 6)  | (x >> 26);
  x ^= (x << 16) | (x >> 16);

  return x & MAX_ST_INT;
}


mst_Boolean
is_a_kind_of (OOP testedOOP,
	      OOP class_oop)
{
  do
    {
      if (testedOOP == class_oop)
	return (true);
      testedOOP = SUPERCLASS (testedOOP);
    }
  while (!IS_NIL (testedOOP));

  return (false);
}


void
nil_fill (OOP * oopPtr,
	  size_t oopCount)
{
  REGISTER (3, OOP nilObj);

  nilObj = _gst_nil_oop;
  while (oopCount >= 8)
    {
      oopPtr[0] = oopPtr[1] = oopPtr[2] = oopPtr[3] =
        oopPtr[4] = oopPtr[5] = oopPtr[6] = oopPtr[7] = nilObj;
      oopPtr += 8;
      oopCount -= 8;
    }

  if (oopCount & 4)
    {
      oopPtr[0] = oopPtr[1] = oopPtr[2] = oopPtr[3] = nilObj;
      oopPtr += 4;
    }

  if (oopCount & 2)
    {
      oopPtr[0] = oopPtr[1] = nilObj;
      oopPtr += 2;
    }

  if (oopCount & 1)
    oopPtr[0] = nilObj;
}

gst_object
new_instance_with (OOP class_oop,
		   size_t numIndexFields,
		   OOP *p_oop)
{
  size_t numBytes, alignedBytes;
  intptr_t instanceSpec;
  gst_object p_instance;

  instanceSpec = CLASS_INSTANCE_SPEC (class_oop);
  numBytes = sizeof (gst_object_header)
    + SIZE_TO_BYTES(instanceSpec >> ISP_NUMFIXEDFIELDS)
    + (numIndexFields << _gst_log2_sizes[instanceSpec & ISP_SHAPE]);

  alignedBytes = ROUNDED_BYTES (numBytes);
  p_instance = _gst_alloc_obj (alignedBytes, p_oop);
  INIT_UNALIGNED_OBJECT (*p_oop, alignedBytes - numBytes);

  p_instance->objClass = class_oop;
  (*p_oop)->flags |= (class_oop->flags & F_UNTRUSTED);

  return p_instance;
}


gst_object
new_instance (OOP class_oop,
	      OOP *p_oop)
{
  size_t numBytes;
  intptr_t instanceSpec;
  gst_object p_instance;

  instanceSpec = CLASS_INSTANCE_SPEC (class_oop);
  numBytes = sizeof (gst_object_header) + 
    SIZE_TO_BYTES(instanceSpec >> ISP_NUMFIXEDFIELDS);

  p_instance = _gst_alloc_obj (numBytes, p_oop);
  p_instance->objClass = class_oop;
  (*p_oop)->flags |= (class_oop->flags & F_UNTRUSTED);

  return p_instance;
}


gst_object
instantiate_numbytes (OOP class_oop,
	              OOP *p_oop,
                      intptr_t instanceSpec,
                      size_t numBytes)
{
  gst_object p_instance;
  int n;
  OOP src, *dest;

  p_instance = _gst_alloc_obj (numBytes, p_oop);
  p_instance->objClass = class_oop;
  (*p_oop)->flags |= (class_oop->flags & F_UNTRUSTED);

  n = instanceSpec >> ISP_NUMFIXEDFIELDS;
  if UNCOMMON (n == 0)
    return p_instance;

  src = _gst_nil_oop;
  dest = p_instance->data;
  dest[0] = src;
  if UNCOMMON (n == 1)
    return p_instance;

  dest[1] = src;
  if UNCOMMON (n == 2)
    return p_instance;

  dest[2] = src;
  if UNCOMMON (n == 3)
    return p_instance;

  dest += 3;
  n -= 3;
  do
    *dest++ = src;
  while (--n > 0);
  return p_instance;
}

gst_object
instantiate_with (OOP class_oop,
		  size_t numIndexFields,
		  OOP *p_oop)
{
  size_t numBytes, indexedBytes, alignedBytes;
  intptr_t instanceSpec;
  gst_object p_instance;

  instanceSpec = CLASS_INSTANCE_SPEC (class_oop);
#ifndef OPTIMIZE
  if (!(instanceSpec & ISP_ISINDEXABLE) && numIndexFields != 0)
    _gst_errorf
      ("class without indexed instance variables passed to instantiate_with");
#endif

  indexedBytes = numIndexFields << _gst_log2_sizes[instanceSpec & ISP_SHAPE];
  numBytes = sizeof (gst_object_header)
    + SIZE_TO_BYTES(instanceSpec >> ISP_NUMFIXEDFIELDS)
    + indexedBytes;

  if COMMON ((instanceSpec & ISP_INDEXEDVARS) == GST_ISP_POINTER)
    {
      p_instance = _gst_alloc_obj (numBytes, p_oop);
      p_instance->objClass = class_oop;
      (*p_oop)->flags |= (class_oop->flags & F_UNTRUSTED);
      nil_fill (p_instance->data,
	        (instanceSpec >> ISP_NUMFIXEDFIELDS) + numIndexFields);
    }
  else
    {
      alignedBytes = ROUNDED_BYTES (numBytes);
      p_instance = instantiate_numbytes (class_oop,
                                         p_oop,
                                         instanceSpec,
                                         alignedBytes);
      INIT_UNALIGNED_OBJECT (*p_oop, alignedBytes - numBytes);
      memset (&p_instance->data[instanceSpec >> ISP_NUMFIXEDFIELDS], 0,
	      indexedBytes);
    }

  return p_instance;
}

gst_object
instantiate (OOP class_oop,
	     OOP *p_oop)
{
  size_t numBytes;
  intptr_t instanceSpec;

  instanceSpec = CLASS_INSTANCE_SPEC (class_oop);
  numBytes = sizeof (gst_object_header) + 
    SIZE_TO_BYTES(instanceSpec >> ISP_NUMFIXEDFIELDS);
  return instantiate_numbytes (class_oop,
                               p_oop,
                               instanceSpec, numBytes);
}


OOP *
ordered_collection_begin (OOP orderedCollectionOOP)
{
  gst_ordered_collection oc;

  oc = (gst_ordered_collection) OOP_TO_OBJ (orderedCollectionOOP);
  return &oc->data[TO_INT (oc->firstIndex) - 1];
}

OOP *
ordered_collection_end (OOP orderedCollectionOOP)
{
  gst_ordered_collection oc;

  oc = (gst_ordered_collection) OOP_TO_OBJ (orderedCollectionOOP);
  return &oc->data[TO_INT (oc->lastIndex)];
}


OOP
dictionary_association_at (OOP dictionaryOOP,
			   OOP keyOOP)
{
  gst_object dictionary;
  size_t index, count, numFields, numFixedFields;
  OOP associationOOP;
  gst_association association;

  if UNCOMMON (IS_NIL (dictionaryOOP))
    return (_gst_nil_oop);

  dictionary = OOP_TO_OBJ (dictionaryOOP);
  numFixedFields = OOP_FIXED_FIELDS (dictionaryOOP);
  numFields = NUM_WORDS (dictionary) - numFixedFields;
  index = scramble (OOP_INDEX (keyOOP));
  count = numFields;

  while (count--)
    {
      index &= numFields - 1;
      associationOOP = dictionary->data[numFixedFields + index];
      if COMMON (IS_NIL (associationOOP))
	return (_gst_nil_oop);

      association = (gst_association) OOP_TO_OBJ (associationOOP);

      if COMMON (association->key == keyOOP)
	return (associationOOP);

      /* linear reprobe -- it is simple and guaranteed */
      index++;
    }

  _gst_errorf
    ("Error - searching Dictionary for nil, but it is full!\n");
  abort ();
}

OOP
dictionary_at (OOP dictionaryOOP,
	       OOP keyOOP)
{
  OOP assocOOP;

  assocOOP = dictionary_association_at (dictionaryOOP, keyOOP);

  if UNCOMMON (IS_NIL (assocOOP))
    return (_gst_nil_oop);
  else
    return (ASSOCIATION_VALUE (assocOOP));
}

OOP
association_new (OOP key,
		 OOP value)
{
  gst_association association;
  OOP associationOOP;

  association = (gst_association) new_instance (_gst_association_class,
						&associationOOP);

  association->key = key;
  association->value = value;

  return (associationOOP);
}

OOP
variable_binding_new (OOP key,
		      OOP value,
		      OOP environment)
{
  gst_variable_binding binding;
  OOP bindingOOP;

  binding = (gst_variable_binding)
    new_instance (_gst_variable_binding_class, &bindingOOP);

  binding->key = key;
  binding->value = value;
  binding->environment = environment;

  return (bindingOOP);
}


int
oop_num_fields (OOP oop)
{
  gst_object object;
  intptr_t instanceSpec;
  size_t words, dataBytes, fixed;

  object = OOP_TO_OBJ (oop);
  words = NUM_WORDS (object);

  if COMMON (!(oop->flags & F_BYTE))
    return words;

  instanceSpec = GET_INSTANCE_SPEC (object);
  fixed = instanceSpec >> ISP_NUMFIXEDFIELDS;
  words -= fixed;
  dataBytes = SIZE_TO_BYTES (words) - (oop->flags & EMPTY_BYTES);
  return fixed + (dataBytes >> _gst_log2_sizes[instanceSpec & ISP_SHAPE]);
}


static int
num_valid_oops (OOP oop)
{
  gst_object object;

  object = OOP_TO_OBJ (oop);
  if UNCOMMON (oop->flags & F_CONTEXT)
    {
      gst_method_context ctx;
      intptr_t methodSP;
      ctx = (gst_method_context) object;
      methodSP = TO_INT (ctx->spOffset);
      return ctx->contextStack + methodSP + 1 - object->data;
    }
  else
    return NUM_OOPS (object);
}


/* Returns whether the SCANNEDOOP points to TARGETOOP.  */
mst_Boolean
is_owner (OOP scannedOOP,
	  OOP targetOOP)
{
  gst_object object;
  OOP *scanPtr;
  int n;

  object = OOP_TO_OBJ (scannedOOP);
  if UNCOMMON (object->objClass == targetOOP)
    return true;

  n = num_valid_oops (scannedOOP);

  /* Peel a couple of iterations for optimization.  */
  if (n--)
    {
      scanPtr = object->data;
      if UNCOMMON (*scanPtr++ == targetOOP)
	return true;

      if (n--)
	do
          if UNCOMMON (*scanPtr++ == targetOOP)
	    return true;
	while (n--);
    }

  return false;
}

OOP
index_oop (OOP oop,
	   size_t index)
{
  gst_object object = OOP_TO_OBJ (oop);
  intptr_t instanceSpec = GET_INSTANCE_SPEC (object);
  return index_oop_spec (oop, object, index, instanceSpec);
}

OOP
index_oop_spec (OOP oop,
		gst_object object,
	        size_t index,
		intptr_t instanceSpec)
{
  size_t maxIndex, maxByte;
  char *src;

  if UNCOMMON (index < 1)
    return (NULL);

  index--;

#define DO_INDEX_OOP(type, dest)					\
    /* Find the number of bytes in the object.  */			\
    maxByte = NUM_WORDS (object) * sizeof (PTR);			\
    if (sizeof (type) <= sizeof (PTR))					\
      maxByte -= (oop->flags & EMPTY_BYTES);				\
									\
    index =								\
      index * sizeof(type)						\
      + (instanceSpec >> ISP_NUMFIXEDFIELDS) * sizeof (PTR);		\
									\
    /* Check that we're on bounds.  */					\
    if UNCOMMON (index + sizeof(type) > maxByte)			\
      return (NULL);							\
									\
    /* Use a cast if unaligned accesses are supported, else memcpy.  */	\
    src = ((char *) object->data) + index;				\
    if (sizeof (type) <= sizeof (PTR))					\
      (dest) = *(type *) src;						\
    else								\
      memcpy ((char *) &(dest), src, sizeof (type));

  switch (instanceSpec & ISP_INDEXEDVARS)
    {
      case GST_ISP_SCHAR: {
        int8_t i;
        DO_INDEX_OOP (int8_t, i);
        return FROM_INT (i);
      }

      case GST_ISP_UCHAR: {
        uint8_t i;
        DO_INDEX_OOP (uint8_t, i);
        return FROM_INT (i);
      }

      case GST_ISP_CHARACTER: {
        uint8_t i;
        DO_INDEX_OOP (uint8_t, i);
        return CHAR_OOP_AT (i);
      }

      case GST_ISP_SHORT: {
        uint16_t i;
        DO_INDEX_OOP (int16_t, i);
        return FROM_INT (i);
      }

      case GST_ISP_USHORT: {
        uint16_t i;
        DO_INDEX_OOP (uint16_t, i);
        return FROM_INT (i);
      }

      case GST_ISP_INT: {
        uint32_t i;
        DO_INDEX_OOP (int32_t, i);
        return from_c_int_32 (i);
      }

      case GST_ISP_UINT: {
        uint32_t i;
        DO_INDEX_OOP (uint32_t, i);
        return from_c_uint_32 (i);
      }

      case GST_ISP_FLOAT: {
        float f;
        DO_INDEX_OOP (float, f);
        return floate_new (f);
      }

      case GST_ISP_INT64: {
        uint64_t i;
        DO_INDEX_OOP (int64_t, i);
        return from_c_int_64 (i);
      }

      case GST_ISP_UINT64: {
        uint64_t i;
        DO_INDEX_OOP (uint64_t, i);
        return from_c_uint_64 (i);
      }

      case GST_ISP_DOUBLE: {
        double d;
        DO_INDEX_OOP (double, d);
        return floatd_new (d);
      }

      case GST_ISP_UTF32: {
        uint32_t i;
        DO_INDEX_OOP (uint32_t, i);
        return char_new (i);
      }

      case GST_ISP_POINTER:
        maxIndex = NUM_WORDS (object);
        index += instanceSpec >> ISP_NUMFIXEDFIELDS;
        if UNCOMMON (index >= maxIndex)
	  return (NULL);

        return (object->data[index]);
    }
#undef DO_INDEX_OOP

  return (NULL);
}

mst_Boolean
index_oop_put (OOP oop,
	       size_t index,
	       OOP value)
{
  gst_object object = OOP_TO_OBJ (oop);
  intptr_t instanceSpec = GET_INSTANCE_SPEC (object);
  return index_oop_put_spec (oop, object, index, value, instanceSpec);
}

mst_Boolean
index_oop_put_spec (OOP oop,
		    gst_object object,
		    size_t index,
		    OOP value,
		    intptr_t instanceSpec)
{
  size_t maxIndex;

  if UNCOMMON (index < 1)
    return (false);

  index--;

#define DO_INDEX_OOP_PUT(type, cond, src)				\
    if COMMON (cond)							\
      {									\
        /* Find the number of bytes in the object.  */			\
        size_t maxByte = NUM_WORDS (object) * sizeof (PTR);		\
        if (sizeof (type) <= sizeof (PTR))				\
          maxByte -= (oop->flags & EMPTY_BYTES);			\
									\
        index =								\
          index * sizeof(type)						\
          + (instanceSpec >> ISP_NUMFIXEDFIELDS) * sizeof (PTR);	\
									\
        /* Check that we're on bounds.  */				\
        if UNCOMMON (index + sizeof(type) > maxByte)			\
          return (false);						\
									\
        /* Use a cast if unaligned accesses are ok, else memcpy.  */	\
        if (sizeof (type) <= sizeof (PTR))				\
	  {								\
	    type *destAddr = (type *) (((char *) object->data) + index);\
            *destAddr = (type) (src);					\
	  }								\
        else								\
	  {								\
	    char *destAddr = ((char *) object->data) + index;		\
	    type src_ = (type) (src);					\
            memcpy (destAddr, (char *) &src_, sizeof (type));		\
	  }								\
        return (true);							\
      }

  switch (instanceSpec & ISP_INDEXEDVARS)
    {
      case GST_ISP_SCHAR: {
        DO_INDEX_OOP_PUT (int8_t,
			  IS_INT (value)
			  && TO_INT (value) >= -128
			  && TO_INT (value) <= 127,
			  TO_INT (value));
        return (false);
      }

      case GST_ISP_UCHAR: {
        DO_INDEX_OOP_PUT (uint8_t,
			  IS_INT (value)
			  && TO_INT (value) >= 0
			  && TO_INT (value) <= 255,
			  TO_INT (value));
        return (false);
      }

      case GST_ISP_CHARACTER: {
        DO_INDEX_OOP_PUT (uint8_t,
			  !IS_INT (value)
			  && OOP_CLASS (value) == _gst_char_class,
			  CHAR_OOP_VALUE (value));
        return (false);
      }

      case GST_ISP_SHORT: {
        DO_INDEX_OOP_PUT (uint16_t,
			  IS_INT (value)
			  && TO_INT (value) >= -32768
			  && TO_INT (value) <= 32767,
			  TO_INT (value));
	return (false);
      }

      case GST_ISP_USHORT: {
        DO_INDEX_OOP_PUT (uint16_t,
			  IS_INT (value)
			  && TO_INT (value) >= 0
			  && TO_INT (value) <= 65535,
			  TO_INT (value));
	return (false);
      }

      case GST_ISP_INT: {
        DO_INDEX_OOP_PUT (int32_t, is_c_int_32 (value), to_c_int_32 (value));
	return (false);
      }

      case GST_ISP_UINT: {
        DO_INDEX_OOP_PUT (uint32_t, is_c_uint_32 (value), to_c_int_32 (value));
	return (false);
      }

      case GST_ISP_FLOAT: {
        DO_INDEX_OOP_PUT (float, IS_INT (value), TO_INT (value));
        DO_INDEX_OOP_PUT (float, OOP_CLASS (value) == _gst_floate_class,
			  FLOATE_OOP_VALUE (value));
        DO_INDEX_OOP_PUT (float, OOP_CLASS (value) == _gst_floatd_class,
			  FLOATD_OOP_VALUE (value));
        DO_INDEX_OOP_PUT (float, OOP_CLASS (value) == _gst_floatq_class,
			  FLOATQ_OOP_VALUE (value));
        return (false);
      }

      case GST_ISP_INT64: {
        DO_INDEX_OOP_PUT (int64_t, is_c_int_64 (value), to_c_int_64 (value));
	return (false);
      }

      case GST_ISP_UINT64: {
        DO_INDEX_OOP_PUT (uint64_t, is_c_uint_64 (value), to_c_uint_64 (value));
	return (false);
      }

      case GST_ISP_DOUBLE: {
        DO_INDEX_OOP_PUT (double, IS_INT (value), TO_INT (value));
        DO_INDEX_OOP_PUT (double, OOP_CLASS (value) == _gst_floatd_class,
			  FLOATD_OOP_VALUE (value));
        DO_INDEX_OOP_PUT (double, OOP_CLASS (value) == _gst_floate_class,
			  FLOATE_OOP_VALUE (value));
        DO_INDEX_OOP_PUT (double, OOP_CLASS (value) == _gst_floatq_class,
			  FLOATQ_OOP_VALUE (value));
        return (false);
      }

      case GST_ISP_UTF32: {
        DO_INDEX_OOP_PUT (uint32_t,
			  !IS_INT (value)
			  && (OOP_CLASS (value) == _gst_unicode_character_class
			      || (OOP_CLASS (value) == _gst_char_class
			          && CHAR_OOP_VALUE (value) <= 127)),
			  CHAR_OOP_VALUE (value));
        return (false);
      }

      case GST_ISP_POINTER:
        maxIndex = NUM_WORDS (object);
        index += instanceSpec >> ISP_NUMFIXEDFIELDS;
        if UNCOMMON (index >= maxIndex)
	  return (false);

        object->data[index] = value;
        return (true);
    }
#undef DO_INDEX_OOP_PUT

  return (false);
}

OOP
inst_var_at (OOP oop,
	     int index)
{
  gst_object object;

  object = OOP_TO_OBJ (oop);
  return (object->data[index - 1]);
}

void
inst_var_at_put (OOP oop,
		 int index,
		 OOP value)
{
  gst_object object;

  object = OOP_TO_OBJ (oop);
  object->data[index - 1] = value;
}


mst_Boolean
is_c_int_32 (OOP oop)
{
  gst_byte_array ba;

  if COMMON (IS_INT (oop))
#if SIZEOF_OOP == 4
    return (true);
#else
    return (TO_INT (oop) >= INT_MIN && TO_INT (oop) < INT_MAX);
#endif

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  if (COMMON (ba->objClass == _gst_large_positive_integer_class)
      || ba->objClass == _gst_large_negative_integer_class)
    return (NUM_INDEXABLE_FIELDS (oop) == 4);

  return (false);
}

mst_Boolean
is_c_uint_32 (OOP oop)
{
  gst_byte_array ba;

  if COMMON (IS_INT (oop))
#if SIZEOF_OOP == 4
    return (TO_INT (oop) >= 0);
#else
    return (TO_INT (oop) >= 0 && TO_INT (oop) < UINT_MAX);
#endif

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  if COMMON (ba->objClass == _gst_large_positive_integer_class)
    {
      switch (NUM_INDEXABLE_FIELDS (oop))
	{
	case 4:
	  return (true);
	case 5:
	  return (ba->bytes[4] == 0);
	}
    }

  return (false);
}

int32_t
to_c_int_32 (OOP oop)
{
  gst_byte_array ba;

  if COMMON (IS_INT (oop))
    return (TO_INT (oop));

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  return ((int32_t) ((((uint32_t) ba->bytes[3]) << 24) +
		     (((uint32_t) ba->bytes[2]) << 16) +
		     (((uint32_t) ba->bytes[1]) << 8) +
		      ((uint32_t) ba->bytes[0])));
}

OOP
from_c_int_32 (int32_t i)
{
  gst_byte_array ba;
  OOP oop;
  const uint32_t ui = (uint32_t) i;

  if COMMON (i >= MIN_ST_INT && i <= MAX_ST_INT)
    return (FROM_INT (i));

  if (i < 0)
    ba = (gst_byte_array) new_instance_with (_gst_large_negative_integer_class, 
					     4, &oop);
  else
    ba = (gst_byte_array) new_instance_with (_gst_large_positive_integer_class, 
					     4, &oop);

  ba->bytes[0] = (gst_uchar) ui;
  ba->bytes[1] = (gst_uchar) (ui >> 8);
  ba->bytes[2] = (gst_uchar) (ui >> 16);
  ba->bytes[3] = (gst_uchar) (ui >> 24);
  return (oop);
}

OOP
from_c_uint_32 (uint32_t ui)
{
  gst_byte_array ba;
  OOP oop;

  if COMMON (ui <= MAX_ST_INT)
    return (FROM_INT (ui));

  if UNCOMMON (((intptr_t) ui) < 0)
    {
      ba = (gst_byte_array) 
        new_instance_with (_gst_large_positive_integer_class, 
			   5, &oop);

      ba->bytes[4] = 0;
    }
  else
    ba = (gst_byte_array) 
      new_instance_with (_gst_large_positive_integer_class, 
	 		 4, &oop);

  ba->bytes[0] = (gst_uchar) ui;
  ba->bytes[1] = (gst_uchar) (ui >> 8);
  ba->bytes[2] = (gst_uchar) (ui >> 16);
  ba->bytes[3] = (gst_uchar) (ui >> 24);

  return (oop);
}


mst_Boolean
is_c_int_64 (OOP oop)
{
  gst_byte_array ba;

  if COMMON (IS_INT (oop))
    return (true);

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  if COMMON (ba->objClass == _gst_large_negative_integer_class
             || ba->objClass == _gst_large_positive_integer_class)
    {
      switch (NUM_INDEXABLE_FIELDS (oop))
	{
	case 4:
	case 5:
	case 6:
	case 7:
	case 8:
	  return (true);
	}
    }

  return (false);
}

mst_Boolean
is_c_uint_64 (OOP oop)
{
  gst_byte_array ba;

  if COMMON (IS_INT (oop))
    return (TO_INT (oop) >= 0);

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  if COMMON (ba->objClass == _gst_large_positive_integer_class)
    {
      switch (NUM_INDEXABLE_FIELDS (oop))
	{
	case 4:
	case 5:
	case 6:
	case 7:
	case 8:
	  return (true);
	case 9:
	  return (ba->bytes[8] == 0);
	}
    }

  return (false);
}

uint64_t
to_c_uint_64 (OOP oop)
{
  gst_byte_array ba;
  uint64_t result, mask;

  if COMMON (IS_INT (oop))
    return (TO_INT (oop));

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  mask = (((uint64_t)2) << (NUM_INDEXABLE_FIELDS (oop) * 8 - 1)) - 1;
  result = ((int64_t) (
	   (((uint64_t) ba->bytes[3]) << 24) +
	   (((uint64_t) ba->bytes[2]) << 16) +
	   (((uint64_t) ba->bytes[1]) << 8) +
	   ((uint64_t) ba->bytes[0])));

  if (NUM_INDEXABLE_FIELDS (oop) > 4)
    result |= mask & ((int64_t) (
		    (((uint64_t) ba->bytes[7]) << 56) +
		    (((uint64_t) ba->bytes[6]) << 48) +
		    (((uint64_t) ba->bytes[5]) << 40) +
		    (((uint64_t) ba->bytes[4]) << 32)));

  return result;
}

int64_t
to_c_int_64 (OOP oop)
{
  gst_byte_array ba;
  int64_t result, mask;

  if COMMON (IS_INT (oop))
    return (TO_INT (oop));

  ba = (gst_byte_array) OOP_TO_OBJ (oop);
  mask = (((uint64_t)2) << (NUM_INDEXABLE_FIELDS (oop) * 8 - 1)) - 1;
  result = (ba->objClass == _gst_large_negative_integer_class) ? ~mask : 0;
  result |= ((int64_t) (
	   (((uint64_t) ba->bytes[3]) << 24) +
	   (((uint64_t) ba->bytes[2]) << 16) +
	   (((uint64_t) ba->bytes[1]) << 8) +
	   ((uint64_t) ba->bytes[0])));

  if (NUM_INDEXABLE_FIELDS (oop) > 4)
    result |= mask & ((int64_t) (
		    (((uint64_t) ba->bytes[7]) << 56) +
		    (((uint64_t) ba->bytes[6]) << 48) +
		    (((uint64_t) ba->bytes[5]) << 40) +
		    (((uint64_t) ba->bytes[4]) << 32)));

  return result;
}

OOP
from_c_int_64 (int64_t i)
{
  gst_byte_array ba;
  OOP oop;
  const uint64_t ui = (uint64_t) i;

  if COMMON (i >= MIN_ST_INT && i <= MAX_ST_INT)
    return (FROM_INT (i));

  if (i < 0)
    ba = (gst_byte_array) new_instance_with (_gst_large_negative_integer_class, 
					     8, &oop);
  else
    ba = (gst_byte_array) new_instance_with (_gst_large_positive_integer_class, 
					     8, &oop);

  ba->bytes[0] = (gst_uchar) ui;
  ba->bytes[1] = (gst_uchar) (ui >> 8);
  ba->bytes[2] = (gst_uchar) (ui >> 16);
  ba->bytes[3] = (gst_uchar) (ui >> 24);
  ba->bytes[4] = (gst_uchar) (ui >> 32);
  ba->bytes[5] = (gst_uchar) (ui >> 40);
  ba->bytes[6] = (gst_uchar) (ui >> 48);
  ba->bytes[7] = (gst_uchar) (ui >> 56);

  return (oop);
}

OOP
from_c_uint_64 (uint64_t ui)
{
  gst_byte_array ba;
  OOP oop;

  if COMMON (ui <= MAX_ST_INT)
    return (FROM_INT (ui));

  if UNCOMMON (((int64_t) ui) < 0)
    {
      ba = (gst_byte_array) 
        new_instance_with (_gst_large_positive_integer_class, 
			   9, &oop);

      ba->bytes[8] = 0;
    }
  else
    ba = (gst_byte_array) 
      new_instance_with (_gst_large_positive_integer_class, 
	 		 8, &oop);

  ba->bytes[0] = (gst_uchar) ui;
  ba->bytes[1] = (gst_uchar) (ui >> 8);
  ba->bytes[2] = (gst_uchar) (ui >> 16);
  ba->bytes[3] = (gst_uchar) (ui >> 24);
  ba->bytes[4] = (gst_uchar) (ui >> 32);
  ba->bytes[5] = (gst_uchar) (ui >> 40);
  ba->bytes[6] = (gst_uchar) (ui >> 48);
  ba->bytes[7] = (gst_uchar) (ui >> 56);

  return (oop);
}

static inline PTR
cobject_value (OOP oop)
{
  gst_cobject cObj = (gst_cobject) OOP_TO_OBJ (oop);
  if (IS_NIL (cObj->storage))
    return (PTR) COBJECT_OFFSET_OBJ (cObj);
  else
    {
      gst_uchar *baseAddr = ((gst_byte_array) OOP_TO_OBJ (cObj->storage))->bytes;
      return (PTR) (baseAddr + COBJECT_OFFSET_OBJ (cObj));
    }
}

/* Sets the address of the data stored in a CObject.  */
static inline void
set_cobject_value (OOP oop, PTR val)
{
  gst_cobject cObj = (gst_cobject) OOP_TO_OBJ (oop);
  cObj->storage = _gst_nil_oop;
  SET_COBJECT_OFFSET_OBJ (cObj, (uintptr_t) val);
}
  

/* Return whether the address of the data stored in a CObject, offsetted
   by OFFSET bytes, is still in bounds.  */
static inline mst_Boolean cobject_index_check (OOP oop, intptr_t offset,
					       size_t size)
{
  gst_cobject cObj = (gst_cobject) OOP_TO_OBJ (oop);
  OOP baseOOP = cObj->storage;
  intptr_t maxOffset;
  if (IS_NIL (baseOOP))
    return true;
  
  offset += COBJECT_OFFSET_OBJ (cObj);
  if (offset < 0)
    return false;

  maxOffset = SIZE_TO_BYTES (NUM_WORDS (OOP_TO_OBJ (baseOOP)));
  if (baseOOP->flags & F_BYTE)
    maxOffset -= (baseOOP->flags & EMPTY_BYTES);

  return (offset + size - 1 < maxOffset);
}
