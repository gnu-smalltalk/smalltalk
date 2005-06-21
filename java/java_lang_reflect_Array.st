"======================================================================
|
|   Java run-time support.  java.lang.reflect.Array native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.reflect.Array'!

java_lang_reflect_Array_newInstance_java_lang_Class: arg1 int: arg2
    | arrayClass |
    <javaNativeMethod: #'newInstance(Ljava/lang/Class;I)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Array} static: true>
    arg1 == VoidClass ifTrue: [
	^JavaVM throw: Java.java.lang.IllegalArgumentException ].
    arg2 < 0 ifTrue: [
	^JavaVM throw: Java.java.lang.NegativeArraySizeException ].

    arrayClass := arg1 javaType arrayClass.
    ^arrayClass new: arg2!

java_lang_reflect_Array_newInstance_java_lang_Class: arg1 intArray: arg2
    <javaNativeMethod: #'newInstance(Ljava/lang/Class;[I)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Array} static: true>
    (arg1 javaType isArrayType and: [
	(arg1 javaType arrayDimensionality >= arg2 size) ]) ifFalse: [
	    ^JavaVM throw: Java.java.lang.IllegalArgumentException ].

    ^arg1 javaType javaMultiNewArray: arg2 from: 1
!

java_lang_reflect_Array_getLength_java_lang_Object: arg1
    <javaNativeMethod: #'getLength(Ljava/lang/Object;)I'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 isKindOf: JavaObject)
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 size ]
!

java_lang_reflect_Array_get_java_lang_Object: arg1 int: arg2
    | desiredClass |
    <javaNativeMethod: #'get(Ljava/lang/Object;I)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Array} static: true>
    arg1 class == Array
	ifTrue: [ ^arg1 javaAt: arg2 ].

    arg1 class == JavaBooleanArray ifTrue: [
	^(arg1 javaAt: arg2) = 0
	    ifTrue: [ Java.java.lang.Boolean FALSE ]
	    ifFalse: [ Java.java.lang.Boolean TRUE ]].
 
    desiredClass :=
        arg1 class == JavaIntArray ifTrue: [ Java.java.lang.Integer ] ifFalse: [
        arg1 class == JavaShortArray ifTrue: [ Java.java.lang.Short ] ifFalse: [
        arg1 class == JavaByteArray ifTrue: [ Java.java.lang.Byte ] ifFalse: [
        arg1 class == JavaLongArray ifTrue: [ Java.java.lang.Long ] ifFalse: [
        arg1 class == JavaFloatArray ifTrue: [ Java.java.lang.Float ] ifFalse: [
        arg1 class == JavaDoubleArray ifTrue: [ Java.java.lang.Double ] ifFalse: [
        Java.java.lang.Char ]]]]]].

    ^desiredClass new
	perform: #'<init>()V';
	value: (arg1 javaAt: arg2)
!

java_lang_reflect_Array_getChar_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getChar(Ljava/lang/Object;I)C'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == JavaCharArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getByte_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getByte(Ljava/lang/Object;I)B'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == JavaByteArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getShort_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getShort(Ljava/lang/Object;I)S'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaByteArray 
	or: [ arg1 class == JavaShortArray ])
	    ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	    ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getInt_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getInt(Ljava/lang/Object;I)I'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaByteArray 
	or: [ arg1 class == JavaCharArray
	or: [ arg1 class == JavaIntArray
	or: [ arg1 class == JavaShortArray ]]])
	    ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	    ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getLong_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getLong(Ljava/lang/Object;I)J'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray 
	or: [ arg1 class == JavaDoubleArray 
	or: [ arg1 class == JavaFloatArray ]]])
	    ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	    ifFalse: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getFloat_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getFloat(Ljava/lang/Object;I)F'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray 
	or: [ arg1 class == JavaDoubleArray ]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ (arg1 javaAt: arg2) asFloatE ]
!

java_lang_reflect_Array_getDouble_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getDouble(Ljava/lang/Object;I)D'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array or: [ arg1 class == ByteArray ])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ (arg1 javaAt: arg2) asFloatD ]
!

java_lang_reflect_Array_getBoolean_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getBoolean(Ljava/lang/Object;I)Z'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == ByteArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getElementType_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getElementType(Ljava/lang/Object;I)Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Array} static: true>
    self notYetImplemented
!

java_lang_reflect_Array_set_java_lang_Object: arg1 int: arg2 java_lang_Object: arg3 java_lang_Class: arg4
    <javaNativeMethod: #'set(Ljava/lang/Object;ILjava/lang/Object;Ljava/lang/Class;)V'
        for: #{Java.java.lang.reflect.Array} static: true>

    (arg3 isKindOf: arg4 asSmalltalkClass)
	ifFalse: [ ^JavaVM throw: Java.java.lang.IllegalArgumentException ]

    arg1 javaAt: arg2 put: arg3
!

java_lang_reflect_Array_setByte_java_lang_Object: arg1 int: arg2 byte: arg3
    <javaNativeMethod: #'setByte(Ljava/lang/Object;IB)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray
	or: [ arg1 class == JavaCharArray ]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setShort_java_lang_Object: arg1 int: arg2 short: arg3
    <javaNativeMethod: #'setShort(Ljava/lang/Object;IS)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == JavaByteArray
	or: [ arg1 class == ByteArray
	or: [ arg1 class == JavaCharArray ]]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setInt_java_lang_Object: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'setInt(Ljava/lang/Object;II)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaDoubleArray
	or: [ arg1 class == JavaFloatArray
	or: [ arg1 class == JavaIntArray
	or: [ arg1 class == JavaLong Array ]]])
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setLong_java_lang_Object: arg1 int: arg2 long: arg3
    <javaNativeMethod: #'setLong(Ljava/lang/Object;IJ)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaDoubleArray
	or: [ arg1 class == JavaFloatArray
	or: [ arg1 class == JavaLong Array ]])
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setFloat_java_lang_Object: arg1 int: arg2 float: arg3
    <javaNativeMethod: #'setFloat(Ljava/lang/Object;IF)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaDoubleArray or: [ arg1 class == JavaFloatArray ])
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setDouble_java_lang_Object: arg1 int: arg2 double: arg3
    <javaNativeMethod: #'setDouble(Ljava/lang/Object;ID)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == JavaDoubleArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setChar_java_lang_Object: arg1 int: arg2 char: arg3
    <javaNativeMethod: #'setChar(Ljava/lang/Object;IC)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray
	or: [ arg1 class == JavaShortArray
	or: [ arg1 class == JavaCharArray ]]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setBoolean_java_lang_Object: arg1 int: arg2 boolean: arg3
    <javaNativeMethod: #'setBoolean(Ljava/lang/Object;IZ)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == ByteArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
! !

