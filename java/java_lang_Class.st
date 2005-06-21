"======================================================================
|
|   Java run-time support.  java.lang.Class native methods.
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


!JavaVM methodsFor: 'java.lang.Class'!

convertJavaLangClassToJavaClass
    <javaNativeMethod: #asJavaClass
        for: #{Java.java.lang.Class} static: false>
    ^instVar1 javaClass
!

convertJavaLangClassToJavaType
    <javaNativeMethod: #asJavaType
        for: #{Java.java.lang.Class} static: false>
    ^instVar1
!

convertJavaLangClassToSmalltalkClass
    <javaNativeMethod: #asSmalltalkClass
        for: #{Java.java.lang.Class} static: false>
    ^instVar1 javaClass asSmalltalkClass
!

associateJavaLangClass: aJavaClass
    <javaNativeMethod: #javaClass:
        for: #{Java.java.lang.Class} static: false>
    instVar1 := JavaObjectType javaClass: aJavaClass
!

associateJavaType: aJavaType
    <javaNativeMethod: #javaType:
        for: #{Java.java.lang.Class} static: false>
    instVar1 := aJavaType
!

java_lang_Class_forName_java_lang_String: arg1
    | path |
    <javaNativeMethod: #'forName(Ljava/lang/String;)Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: true>
    path := arg1 asString copyReplacing: $. withObject: $/.
    ^(JavaClass fromString: path) asSmalltalkClass javaLangClass
!

java_lang_Class_forName_java_lang_String: arg1 boolean: arg2 java_lang_ClassLoader: arg3
    <javaNativeMethod: #'forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: true>
    self notYetImplemented
!

java_lang_Class_getClasses
    <javaNativeMethod: #'getClasses()[Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getClassLoader
    <javaNativeMethod: #'getClassLoader()Ljava/lang/ClassLoader;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getComponentType
    <javaNativeMethod: #'getComponentType()Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getConstructor_java_lang_ClassArray: arg1
    <javaNativeMethod: #'getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getConstructors_boolean: arg1
    <javaNativeMethod: #'_getConstructors(Z)[Ljava/lang/reflect/Constructor;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredConstructor_java_lang_ClassArray: arg1
    <javaNativeMethod: #'getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredClasses
    <javaNativeMethod: #'getDeclaredClasses()[Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredField_java_lang_String: arg1
    <javaNativeMethod: #'getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredFields
    <javaNativeMethod: #'getDeclaredFields()[Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getDeclaredMethod_java_lang_String: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'_getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredMethods
    <javaNativeMethod: #'getDeclaredMethods()[Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaringClass
    <javaNativeMethod: #'getDeclaringClass()Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getField_java_lang_String: arg1 int: arg2
    <javaNativeMethod: #'getField(Ljava/lang/String;I)Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getFields_java_lang_reflect_FieldArray: arg1 int: arg2
    <javaNativeMethod: #'_getFields([Ljava/lang/reflect/Field;I)[Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getFields
    <javaNativeMethod: #'getFields()[Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getInterfaces
    <javaNativeMethod: #'getInterfaces()[Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getSignature_java_lang_StringBuffer: arg1
    <javaNativeMethod: #'getSignature(Ljava/lang/StringBuffer;)V'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getSignature_java_lang_ClassArray: arg1 boolean: arg2
    <javaNativeMethod: #'getSignature([Ljava/lang/Class;Z)Ljava/lang/String;'
        for: #{Java.java.lang.Class} static: true>
    self notYetImplemented
!

java_lang_Class__getMethod_java_lang_String: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'_getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getMethods_java_lang_reflect_MethodArray: arg1 int: arg2
    <javaNativeMethod: #'_getMethods([Ljava/lang/reflect/Method;I)I'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getMethods
    <javaNativeMethod: #'getMethods()[Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getModifiers
    <javaNativeMethod: #'getModifiers()I'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getName
    <javaNativeMethod: #'getName()Ljava/lang/String;'
        for: #{Java.java.lang.Class} static: false>
    ^self asSmalltalkClass name asJavaString
!

java_lang_Class_getSuperclass
    <javaNativeMethod: #'getSuperclass()Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    ^self asSmalltalkClass superclass javaLangClass
!

java_lang_Class_isArray
    <javaNativeMethod: #'isArray()Z'
        for: #{Java.java.lang.Class} static: false>
    ^0 "FIXME"
!

java_lang_Class_isAssignableFrom_java_lang_Class: arg1
    | isAssignable type1 type2 |
    <javaNativeMethod: #'isAssignableFrom(Ljava/lang/Class;)Z'
        for: #{Java.java.lang.Class} static: false>

    "Go inside array types."
    type1 := self javaType.
    type2 := arg1 javaType.
    [
	"A type is always assignable from itself."
	self == arg1 ifTrue: [ ^1 ].

	"Trivial case: one is primitive, the other is not."
	type1 isPrimitiveType ifTrue: [ ^0 ].
	type2 isPrimitiveType ifTrue: [ ^0 ].

	type1 isArrayType == type2 isArrayType ifFalse: [ ^0 ].
	type1 isArrayType ] whileTrue: [
	    type1 := type1 subType.
	    type2 := type2 subType ].

    isAssignable := type1 javaClass isInterface
    	ifTrue: [ type1 javaClass implementsInterface: type2 javaClass ]
    	ifFalse: [ type1 javaClass inheritsFrom: type2 javaClass ].

    ^isAssignable ifTrue: [ 1 ] ifFalse: [ 0 ]
!

java_lang_Class_isInstance_java_lang_Object: arg1
    | isInstance |
    <javaNativeMethod: #'isInstance(Ljava/lang/Object;)Z'
        for: #{Java.java.lang.Class} static: false>
    (arg1 class inheritsFrom: JavaObject)
	ifTrue: [ ^self isAssignableFrom: arg1 javaLangClass ].

    self javaType isArrayType ifFalse: [ ^0 ].

    isInstance := false.
    arg1 class == Array ifTrue: [
	isInstance := self javaType subType isPrimitiveType not ].
    arg1 class == JavaByteArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType byte ].
    arg1 class == JavaShortArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType short ].
    arg1 class == JavaIntArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType int ].
    arg1 class == JavaLongArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType long ].
    arg1 class == JavaFloatArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType float ].
    arg1 class == JavaDoubleArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType double ].
    arg1 class == ByteArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType boolean ].
    ^isInstance ifTrue: [ 1 ] ifFalse: [ 0 ]
!

java_lang_Class_isInterface
    <javaNativeMethod: #'isInterface()Z'
        for: #{Java.java.lang.Class} static: false>
    ^self javaClass isInterface
!

java_lang_Class_isPrimitive
    <javaNativeMethod: #'isPrimitive()Z'
        for: #{Java.java.lang.Class} static: false>
    ^self javaType isPrimitiveType
!

java_lang_Class_newInstance
    <javaNativeMethod: #'newInstance()Ljava/lang/Object;'
        for: #{Java.java.lang.Class} static: false>
    ^self asSmalltalkClass new
    	perform: #'<init>()V';
	yourself
!

java_lang_Class_getProtectionDomain0
    <javaNativeMethod: #'getProtectionDomain0()Ljava/security/ProtectionDomain;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_initializeClass
    <javaNativeMethod: #'initializeClass()V'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
! !

