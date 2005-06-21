"======================================================================
|
|   Metaobjects for Java: types, classes, methods, bytecodes
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

Object subclass: #JavaReader
    instanceVariableNames: 'stream constantPool '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

Java.gnu.smalltalk.JavaReader comment: '
JavaReader is an abstract superclass for objects that deal with Java
data: it has methods for handling a constant pool and to read
big-endian or UTF8 values from a Stream.
 
Instance Variables:
    constantPool	<Collection>
	the constant pool from which to read strings and the like
    stream	<Stream>
	the Stream from which to read bytes

'!


Object subclass: #JavaProgramElement
    instanceVariableNames: 'flags name attributes '
    classVariableNames: 'Final Synthetic Protected FlagsStrings Private
    	Deprecated Volatile Synchronized Abstract Static Native Public
	Interface Transient ThreadSafe'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaProgramElement comment: '
JavaProgramElement represents a Java class, field or method.  It
includes several methods to handle attributes and flags.

Subclasses should override #addAttribute: so that the most common
attributes are stored (more intuitively) in instance variables.

Instance Variables:
    attributes	<IdentityDictionary of: (Symbol -> JavaAttribute)>
	the attributes defined for this program element
    flags	<Integer>
	the access flags attached to this program element.
    name	<Symbol>
	the name of this program element.

'!


Object subclass: #JavaExceptionHandler
    instanceVariableNames: 'startpc length handlerpc type '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

Java.gnu.smalltalk.JavaExceptionHandler comment: '
JavaExceptionHandler represents one of the exception handlers that are
active within a method.

Instance Variables:
    handlerpc	<Integer>
	the program counter value at which the exception handler starts
    length	<Integer>
	the number of bytecodes for which the exception handler stays active.
    startpc	<Integer>
	the program counter value at which the exception handler becomes active.
    type	<JavaType | nil>
	the type of the exception that is caught, or nil for all exceptions

'!


JavaReader subclass: #JavaInstructionInterpreter
    instanceVariableNames: 'pc wide nPairs '
    classVariableNames: 'DecoderTable ArrayTypes'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaInstructionInterpreter comment: '
JavaInstructionInterpreter knows the format of the bytecodes and
dispatches them to its own abstract methods.

Subclasses can override #interpret, for example to interpret only a
few bytecodes (see JavaEdgeCreator), or #dispatch: to execute
operations before and after the method for the bytecode is executed.

Instance Variables:
    nPairs	<Integer>
	used to parse lookupswitch
    pc	<Integer>
	the program counter at which the currently dispatched bytecode starts.
    wide	<Boolean>
	used to parse the ''wide'' opcode

'!


JavaProgramElement subclass: #JavaClass
    instanceVariableNames: 'fullName package extends implements methods fields constantPool sourceFile '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaClass comment: '
This class represent the full information available for a Java class,
read from a .class file.

Instance Variables:
    constantPool	<Array>
	the constant pool of the class, as read from the .class file
    extends	<JavaClass>
	the superclass of the class
    fields	<(Collection of: JavaField)>
	the list of fields in the class
    fullName	<String>
        the cached fully qualified name of the class
    implements	<(Collection of: JavaClass)>
	the list of interfaces that the class implements
    methods	<(Collection of: JavaMethod)>
	the list of methods that the class defines
    package	<JavaPackage>
	the package that holds the class
    sourceFile	<String>
	the Java source file in which the class is defined

'!


JavaProgramElement subclass: #JavaClassElement
    instanceVariableNames: 'signature javaClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaClassElement comment: '
JavaClassElement represents a Java field or method.  These both belong
to a class, and have a type or signature; however, they differ in the
set of supported attributes.

Instance Variables:
    javaClass	<Object>
	the class in which the field or method belongs.
    signature	<JavaType>
	the type or signature of the field or method.

'!


JavaClassElement subclass: #JavaMethod
    instanceVariableNames: 'maxStack maxLocals bytecodes exceptions handlers localVariables lines selector '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaMethod comment: '
JavaMethod represents a Java method.

Instance Variables:
    bytecodes	<ByteArray>
	see JavaCodeAttribute
    exceptions	<(Collection of: JavaClass)>
	see JavaCodeAttribute
    handlers	<(Collection of: JavaExceptionHandler)>
	see JavaCodeAttribute
    lines	<(SequenceableCollection of: Association)>
	see JavaLineNumberTableAttribute
    localVariables	<(Collection of: JavaLocalVariable)>
	see JavaLocalVariableTableAttribute
    maxLocals	<Integer>
	see JavaCodeAttribute
    maxStack	<Integer>
	see JavaCodeAttribute
    selector	<Symbol>
	the selector that is used in Smalltalk bytecodes.
'!


Object subclass: #JavaDescriptor
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaDescriptor comment: '
JavaDescriptor represents the constant-pool entries for names, types
or references to methods/fields.'!


JavaDescriptor subclass: #JavaRef
    instanceVariableNames: 'javaClass nameAndType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaRef comment: '
JavaRef associates the class which defines it to the name and type of
a method or field.

Instance Variables:
    javaClass	<JavaClass>
	the class which defines the method or field
    nameAndType	<JavaDescriptor>
	the name and type of the method or field

'!


JavaRef subclass: #JavaFieldRef
    instanceVariableNames: 'getSelector putSelector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaFieldRef comment: '
JavaFieldRef represents a reference to a Java field made within a method.
They are shared between methods in the same class, so the get/put
selectors are cached.

Instance Variables:
    getSelector		<Symbol>
        the selector used to do read accesses to the field
    putSelector		<Symbol>
        the selector used to do write accesses to the field'!

JavaRef subclass: #JavaMethodRef
    instanceVariableNames: 'selector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaMethodRef comment: '
JavaMethodRef represents a reference to a Java method made from a
method invocation bytecode.

Instance Variables:
    selector		<Symbol>
        the selector used in the translated bytecodes'!

JavaDescriptor subclass: #JavaType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaType comment: '
JavaType is an abstract class for Java types or signatures.

Subclasses must implement the following messages:
    printing
    	printEncodingOn:		print the encoding of the type as found in .class files
'!


JavaType subclass: #JavaObjectType
    instanceVariableNames: 'javaClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaObjectType comment: '
JavaObjectType represents the type of instances of a Java class.

Instance Variables:
    javaClass	<JavaClass>
	the class whose type is represented by the object

'!


JavaType subclass: #JavaMethodType
    instanceVariableNames: 'returnType argTypes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaMethodType comment: '
JavaMethodType represent the signature (types of the arguments, and
returned type) of a Java method.

Instance Variables:
    argTypes	<(Collection of: JavaType)>
	the method''s arguments'' type
    returnType	<JavaType>
	the method''s return type

'!


JavaType subclass: #JavaArrayType
    instanceVariableNames: 'subType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaArrayType comment: '
JavaArrayType represents Java array types.

Instance Variables:
    subType	<JavaType>
	the type of each element of the array.

'!


JavaInstructionInterpreter subclass: #JavaInstructionPrinter
    instanceVariableNames: 'output localVariableTable lineNumberTable '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaInstructionPrinter comment: '
JavaInstructionPrinter can print a commented listing of Java bytecodes
on an output stream.

Instance Variables:
    output	<Stream>
	the stream on which to write
    lineNumberTable	<Stream>
	a stream on a sorted array of pc->line number pairs
    localVariableTable	<Array of: (SortedCollection of: JavaLocalVariable)>
	an array that groups the JavaLocalVariables for the method depending on the slot they refer to

'!


JavaDescriptor subclass: #JavaNameAndType
    instanceVariableNames: 'name type '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaNameAndType comment: '
JavaNameAndType associates the name of a field or method to its type.

Instance Variables:
    name	<Symbol>
	the name of the field or method
    type	<JavaType>
	the type or signature of the field or method

'!


JavaType subclass: #JavaPrimitiveType
    instanceVariableNames: 'id name wordSize zeroValue arrayClass '
    classVariableNames: 'JavaLong JavaShort JavaFloat JavaInt JavaChar
	JavaByte JavaVoid PrimitiveTypes JavaDouble JavaBoolean'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaPrimitiveType comment: '
JavaPrimitiveType represents one of Java''s primitive types.
It has a fixed number of instances, all held in class variables.

Instance Variables:
    id	<Character>
	the one character representation of the type
    name	<String>
	the source code representation of the type (e.g. int)

'!


Object subclass: #JavaLocalVariable
    instanceVariableNames: 'startpc length name type slot '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

Java.gnu.smalltalk.JavaLocalVariable comment: '
JavaLocalVariable represents a local variable''s single liveness range
within a Java method.  If a Java compiler performs live range
splitting, in other words, there might be many JavaLocalVariable
instances for the same variable.

Instance Variables:

Instance Variables:
    length	<Integer>
	the number of bytecodes for which the variable becomes live
    name	<String>
	the name of the local variable
    slot	<Integer>
	the local variable slot in which the variable is stored
    startpc	<Integer>
	the program counter value at which the variable becomes live
    type	<JavaType>
	the type of the variable
'!


Object subclass: #JavaPackage
    instanceVariableNames: 'container contents name '
    classVariableNames: 'Root'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaPackage comment: '
JavaPackage represents a Java package.

Instance Variables:
    container	<JavaPackage | nil>
	the package in which this package is contained
    contents	<Dictionary of: (Symbol -> (JavaPackage | JavaClass))>
	the contents of the package
    name	<Symbol>
	the name of the package

'!


JavaClassElement subclass: #JavaField
    instanceVariableNames: 'constantValue getSelector putSelector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaField comment: '
JavaField represents a Java field within a class.

Instance Variables:
    constantValue	<Object | nil>
	the constant value for final fields, or nil
    getSelector		<Symbol>
        the selector used to do read accesses to the field
    putSelector		<Symbol>
        the selector used to do write accesses to the field'!


!JavaReader methodsFor: 'accessing'!

constantPool
    ^constantPool
!

constantPool: anObject
    constantPool := anObject
!

stream
    ^stream
!

stream: anObject
    stream := anObject.
! !

!JavaReader methodsFor: 'utility'!

next: n collect: aBlock
    ^self next: n collect: aBlock into: Array
!

next: n collect: aBlock into: aClass
    | result |
    result := aClass new: n.
    1 to: n do: [ :i | result at: i put: (aBlock value: result) ].
    ^result
! !

!JavaReader methodsFor: 'stream accessing'!

nextByte
    "Read a 32-bit quantity from the input stream."

    ^stream next asInteger
!

nextBytes: anInteger
    "Read a 32-bit quantity from the input stream."

    | ba |
    ba := ByteArray new: anInteger.
    1 to: anInteger do: [ :i | ba at: i put: stream next asInteger ].
    ^ba
!

nextConstant
    | index |
    index := self nextUshort.
    ^index = 0 ifTrue: [ nil ] ifFalse: [ self constantPool at: index ]
!

nextDouble
    "Read a 64-bit floating-point quantity from the input stream."

    | m1 m2 m3 m4 m5 m6 m7 m8 s e m |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m5 := stream next asInteger.
    m6 := stream next asInteger.
    m7 := stream next asInteger.
    m8 := stream next asInteger.

    "Extract sign and exponent"
    s := m1 > 128 ifTrue: [ -1.0d ] ifFalse: [ 1.0d ].
    e := (m1 bitAnd: 127) * 16 + ((m2 bitAnd: 240) bitShift: -4).

    "Extract mantissa and check for infinity or NaN"
    m := (((((((m2 bitAnd: 15) bitShift: 8) + m3
        bitShift: 8) + m4
        bitShift: 8) + m5
        bitShift: 8) + m6
        bitShift: 8) + m7
        bitShift: 8) + m8.

    e = 16r7FF ifTrue: [
        ^m = 0
	    ifTrue: [ 1.0d / (0.0d * s) ]
	    ifFalse: [ (1.0d / 0.0d) - (1.0d / 0.0d) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r10000000000000 ].

    ^m * s timesTwoPower: e - 1075
!

nextFloat
    "Read a 32-bit floating-point quantity from the input stream."

    | m1 m2 m3 m4 s e m |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.

    "Extract sign and exponent"
    s := m1 > 128 ifTrue: [ -1.0e ] ifFalse: [ 1.0e ].
    e := m1 * 2 + ((m2 bitAnd: 128) bitShift: -7).

    "Extract mantissa and check for infinity or NaN"
    m := (((m2 bitAnd: 127) bitShift: 8) + m3 bitShift: 8) + m4.
    e = 127 ifTrue: [
        ^m = 0
	    ifTrue: [ 1.0e / (0.0e * s) ]
	    ifFalse: [ (1.0e / 0.0e) - (1.0e / 0.0e) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r800000 ].

    ^m * s timesTwoPower: e - 150
!

nextInt
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m1 >= 128 ifTrue: [m1 := m1 - 256].
    ^(((m1 bitShift: 8) + m2
        bitShift: 8) + m3
        bitShift: 8) + m4
!

nextLong
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 m5 m6 m7 m8 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m5 := stream next asInteger.
    m6 := stream next asInteger.
    m7 := stream next asInteger.
    m8 := stream next asInteger.
    m1 >= 128 ifTrue: [m1 := m1 - 256].
    ^(((((((m1 bitShift: 8) + m2
    	bitShift: 8) + m3
    	bitShift: 8) + m4 
    	bitShift: 8) + m5 
    	bitShift: 8) + m6 
    	bitShift: 8) + m7 
    	bitShift: 8) + m8
!

nextShort
    "Answer the next two bytes from the receiver as an Integer."

    | high low |
    high := stream next asInteger.
    low := stream next asInteger.
    high >= 128 ifTrue: [ high := high - 256 ].
    ^(high bitShift: 8) + low
!

nextSignedByte
    "Answer the next two bytes from the receiver as an Integer."

    | byte |
    byte := stream next asInteger.
    ^byte >= 128 ifTrue: [ byte - 256 ] ifFalse: [ byte ]
!

nextUint
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    ^(((((m1 bitShift: 8) + m2) bitShift: 8) + m3) bitShift: 8) + m4
!

nextUlong
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 m5 m6 m7 m8 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m5 := stream next asInteger.
    m6 := stream next asInteger.
    m7 := stream next asInteger.
    m8 := stream next asInteger.
    ^(((((((m1 bitShift: 8) + m2
    	bitShift: 8) + m3
    	bitShift: 8) + m4 
    	bitShift: 8) + m5 
    	bitShift: 8) + m6 
    	bitShift: 8) + m7 
    	bitShift: 8) + m8
!

nextUshort
    "Answer the next two bytes from the receiver as an Integer."

    | high low |
    high := stream next asInteger.
    low := stream next asInteger.
    ^(high bitShift: 8) + low
!

nextUTF8Char
    "Read a 32-bit quantity from the input stream."

    ^self nextUTF8Value asCharacter
!

nextUTF8String
    "Read a 32-bit quantity from the input stream."
    | s bytes finalPosition |
    bytes := self nextUshort.
    s := (String new: bytes) writeStream.
    finalPosition := stream position + bytes.
    [ stream position < finalPosition ] whileTrue: [ s nextPut: self nextUTF8Char ].
    ^s contents
!

nextUTF8Value
    "Read a 32-bit quantity from the input stream."

    | first |
    first := stream next asInteger.
    first <= 2r01111111 ifTrue: [ ^first ].
    first <= 2r11011111 ifTrue: [ ^(first - 2r11000000) * 64 + (stream next asInteger bitAnd: 63) ].
    first <= 2r11101111 ifTrue: [ ^((first - 2r11100000) * 4096) + ((stream next asInteger bitAnd: 63) * 64) + (stream next asInteger bitAnd: 63) ].
    self error: 'invalid UTF-8 character'
! !

!JavaReader class methodsFor: 'instance creation'!

on: aStream
    ^self new
    stream: aStream;
    yourself
! !

!JavaProgramElement methodsFor: 'initializing'!

initialize
    self flags: 0.
! !

!JavaProgramElement methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    aJavaAttribute class == JavaDeprecatedAttribute 
    ifTrue: 
    [self addDeprecated.
    ^aJavaAttribute].
    attributes isNil ifTrue: [attributes := LookupTable new].
    attributes at: aJavaAttribute attributeName put: aJavaAttribute.
    ^aJavaAttribute
!

addFlag: aFlag 
    self flags: (self flags bitOr: aFlag)
!

attributes
    ^attributes
!

attributes: anObject
    attributes := nil.
    anObject do: [ :each | self addAttribute: each ]
!

flags
    ^flags
!

flags: allFlags
    flags := allFlags
!

is: flag
    ^(self flags bitAnd: flag) == flag
!

isAny: flag
    ^(self flags bitAnd: flag) > 0
!

name
    ^name
!

name: anObject
    name := anObject asSymbol
!

removeFlag: aFlag 
    self flags: (self flags bitAnd: aFlag bitInvert)
! !

!JavaProgramElement methodsFor: 'accessing flags'!

addAbstract
    self addFlag: Abstract
!

addDeprecated
    self addFlag: Deprecated
!

addFinal
    self addFlag: Final
!

addNative
    self addFlag: Native
!

addStatic
    self addFlag: Static
!

addSynchronized
    self addFlag: Synchronized
!

addSynthetic
    self addFlag: Synthetic
!

addTransient
    self addFlag: Transient
!

addVolatile
    self addFlag: Volatile
!

beClass
    self removeFlag: Interface
!

beInterface
    self addFlag: Interface
!

bePackageVisible
    self removeFlag: Protected.
    self removeFlag: Private.
    self removeFlag: Public
!

bePrivate
    self removeFlag: Protected.
    self removeFlag: Public.
    self addFlag: Private
!

beProtected
    self removeFlag: Private.
    self removeFlag: Public.
    self addFlag: Protected
!

bePublic
    self removeFlag: Protected.
    self removeFlag: Private.
    self addFlag: Public
!

isAbstract
    ^self is: Abstract
!

isDeprecated
    ^self is: Deprecated
!

isFinal
    ^self is: Final
!

isInterface
    ^self is: Interface
!

isNative
    ^self is: Native
!

isPackageVisible
    ^(self isAny: Protected + Private + Public) not
!

isPrivate
    ^self is: Private
!

isProtected
    ^self is: Protected
!

isPublic
    ^self is: Public
!

isStatic
    ^self is: Static
!

isSynchronized
    ^self is: Synchronized
!

isSynthetic
    ^self is: Synthetic
!

isThreadSafe
    ^self isAny: ThreadSafe
!

isTransient
    ^self is: Transient
!

isVolatile
    ^self is: Volatile
!

removeAbstract
    self removeFlag: Abstract
!

removeDeprecated
    self removeFlag: Deprecated
!

removeFinal
    self removeFlag: Final
!

removeNative
    self removeFlag: Native
!

removeStatic
    self removeFlag: Static
!

removeSynchronized
    self removeFlag: Synchronized
!

removeSynthetic
    self removeFlag: Synthetic
!

removeThreadSafe
    self removeFlag: ThreadSafe
!

removeTransient
    self removeFlag: Transient
!

removeVolatile
    self removeFlag: Volatile
! !

!JavaProgramElement methodsFor: 'printing'!

print: flag on: aStream
    (self is: flag) ifTrue: [
        aStream
            nextPutAll: (FlagsStrings at: flag);
            space
    ]
!

printFlagsOn: aStream 
    | bit |
    bit := 1.
    [FlagsStrings includesKey: bit] whileTrue: 
    		[self print: bit on: aStream.
    		bit := bit * 2]
!

printOn: aStream 
    self printFlagsOn: aStream
! !

!JavaProgramElement class methodsFor: 'initializing'!

initialize
    "self initialize"
    Public := 1.
    Private := 2.
    Protected := 4.
    Static := 8.
    Final := 16.
    Synchronized := 32.
    Volatile := 64.
    ThreadSafe := 96.
    Transient := 128.
    Native := 256.
    Interface := 512.
    Abstract := 1024.
    Synthetic := 2048.
    Deprecated := 4096.
    FlagsStrings := LookupTable new.
    self classPool keysAndValuesDo: [ :k :v |
        v isInteger
            ifTrue: [ FlagsStrings at: v put: k asString asLowercase ]
    ]
! !

!JavaProgramElement class methodsFor: 'instance creation'!

new
    ^self basicNew initialize
! !

!JavaExceptionHandler methodsFor: 'accessing'!

finalpc
    ^self startpc + self length
!

finalpc: anObject
    length := anObject - self startpc
!

handlerpc
    ^handlerpc
!

handlerpc: anObject
    handlerpc := anObject
!

includes: pc
    ^pc >= self startpc
	and: [ pc < (self startpc + self length) ]
!

isFinallyHandler
    ^self type isNil
!

length
    ^length
!

length: anObject
    length := anObject
!

startpc
    ^startpc
!

startpc: anObject
    startpc := anObject
!

type
    ^type
!

type: anObject
    type := anObject
! !

!JavaExceptionHandler methodsFor: 'printing'!

printOn: s
    s nextPutAll: 'handler for '.
    self type isNil
    	ifTrue: [ s nextPutAll: 'all exceptions' ]
	ifFalse: [
	    self type isClass
	    	ifTrue: [ self type storeOn: s ]
		ifFalse: [ self type printFullNameOn: s ] ].

    s nextPutAll: ' at '; print: self handlerpc.
    s nextPutAll: ', active between '; print: self startpc.
    s nextPutAll: ' and '; print: self finalpc
! !

!JavaExceptionHandler class methodsFor: 'instance creation'!

startpc: startpc finalpc: finalpc handlerpc: handlerpc type: type
    ^self new
    startpc: startpc;
    length: finalpc - startpc;
    handlerpc: handlerpc;
    type: type;
    yourself
! !

!JavaInstructionInterpreter methodsFor: 'interpretation'!

dispatch
    pc := stream position.
    self dispatch: self nextByte.
!

dispatch: insn 
    | op spec |
    spec := DecoderTable at: insn + 1 ifAbsent: [nil].
    spec isNil ifTrue: [spec := Array with: #invalid: with: insn].
    op := spec first.
    spec size = 1 
    	ifTrue: 
    		[self perform: op.
    		^op].
    spec size = 2 
    	ifTrue: 
[Smalltalk debug.
    		self perform: op with: (self getArg: (spec at: 2)).
    		^op].
    spec size = 3 
    	ifTrue: 
    		[self 
    			perform: op
    			with: (self getArg: (spec at: 2))
    			with: (self getArg: (spec at: 3)).
    		^op].
    spec size = 4 
    	ifTrue: 
    		[self 
    			perform: op
    			with: (self getArg: (spec at: 2))
    			with: (self getArg: (spec at: 3))
    			with: (self getArg: (spec at: 4)).
    		^op].
    self perform: op
    	withArguments: (Array 
    			with: (self getArg: (spec at: 2))
    			with: (self getArg: (spec at: 3))
    			with: (self getArg: (spec at: 4))
    			with: (self getArg: (spec at: 5))).
    ^op
!

interpret
    [stream atEnd] whileFalse: [self dispatch]
!

nextPC
    ^stream position
!

nextPC: position
    stream position: position
! !

!JavaInstructionInterpreter methodsFor: 'operand decoding'!

arrayTypeByte
    ^ArrayTypes at: self nextByte ifAbsent: [ #bad ]
!

constIndexByte
    ^self constantPool at: self nextByte
!

constIndexShort
    ^self constantPool at: self nextUshort
!

defaultSwitchAddress
    | newPC |
    newPC := pc.
    
    [newPC := newPC + 1.
    newPC \\ 4 > 0] whileTrue: [stream next].
    ^self nextInt + pc
!

getArg: n
    ^n isSymbol
    	ifFalse: [ n ]
    	ifTrue: [ self perform: n ]
!

highValue
    | value |
    value := self nextInt.
    nPairs := value - nPairs + 1.
    ^value
!

localIndexByte
    ^wide ifTrue: [ self nextUshort ] ifFalse: [ self nextByte ]
!

lookupSwitchBytes
    nPairs := self nextUint.
    ^(1 to: nPairs) collect: [ :each | self nextInt -> (self nextInt + pc) ]
!

lowValue
    ^nPairs := self nextInt
!

signedBranchShort
    ^self nextShort + pc
!

signedByte
    ^wide ifTrue: [ self nextShort ] ifFalse: [ self nextSignedByte ]
!

tableSwitchBytes
    ^(1 to: nPairs) collect: [ :each | self nextInt + pc ]
! !

!JavaInstructionInterpreter methodsFor: 'bytecodes'!

aaload!
aastore!
aconst: operand!
aload: operand!
anewarray: operand!
areturn!
arraylength!
astore: operand!
athrow!
baload!
bastore!
bipush: operand!
caload!
castore!
checkcast: operand!
d2f!
d2i!
d2l!
dadd!
daload!
dastore!
dcmpg!
dcmpl!
dconst: operand!
ddiv!
dload: operand!
dmul!
dneg!
drem!
dreturn!
dstore: operand!
dsub!
dup!
dup2!
dup2_x1!
dup2_x2!
dup_x1!
dup_x2!
f2d!
f2i!
f2l!
fadd!
faload!
fastore!
fcmpg!
fcmpl!
fconst: operand!
fdiv!
fload: operand!
fmul!
fneg!
frem!
freturn!
fstore: operand!
fsub!
getfield: operand!
getstatic: operand!
goto: operand!
i2d!
i2f!
i2l!
iadd!
iaload!
iand!
iastore!
iconst: operand!
idiv!
ifeq: operand!
ifge: operand!
ifgt: operand!
ifle: operand!
iflt: operand!
ifne: operand!
ifnonnull: operand!
ifnull: operand!
if_acmpeq: operand!
if_acmpne: operand!
if_icmpeq: operand!
if_icmpge: operand!
if_icmpgt: operand!
if_icmple: operand!
if_icmplt: operand!
if_icmpne: operand!
iinc: operand by: amount!
iload: operand!
imul!
ineg!
instanceof: operand!
int2byte!
int2char!
int2short!
invokeinterface: operand nargs: args reserved: reserved!
invokenonvirtual: operand!
invokestatic: operand!
invokevirtual: operand!
ior!
irem!
ireturn!
ishl!
ishr!
istore: operand!
isub!
iushr!
ixor!
jsr: operand!
l2d!
l2f!
l2i!
ladd!
laload!
land!
lastore!
lcmp!
lconst: operand!
ldc2: operand!
ldc: operand!
ldiv!
lload: operand!
lmul!
lneg!
lookupswitch: default destinations: dest!
lor!
lrem!
lreturn!
lshl!
lshr!
lstore: operand!
lsub!
lushr!
lxor!
monitorenter!
monitorexit!
multianewarray: operand dimensions: dimensions!
new: operand!
newarray: operand!
nop!
pop!
pop2!
putfield: operand!
putstatic: operand!
ret: operand!
return!
saload!
sastore!
sipush: operand!
swap!
tableswitch: default low: low high: high destinations: addresses!

wide
    "Unlike other methods in this protocol, this one need not be overridden by subclasses,
     and in fact subclasses should invoke this implementation ('super wide')"
    wide := true
! !

!JavaInstructionInterpreter methodsFor: 'initialization'!

initialize
    wide := false.
    pc := 0.
! !

!JavaInstructionInterpreter class methodsFor: 'interpreting'!

interpret: aJavaMethod
    (self onMethod: aJavaMethod) interpret
!

new
    ^super new initialize
!

onMethod: aJavaMethod
    ^(self on: aJavaMethod bytecodes readStream)
    	constantPool: aJavaMethod constantPool;
    	yourself
!

onSameMethodAs: aJavaInstructionInterpreter
    ^(self on: aJavaInstructionInterpreter stream copy)
    	constantPool: aJavaInstructionInterpreter constantPool;
    	yourself
! !

!JavaInstructionInterpreter class methodsFor: 'initializing'!

initialize
    ArrayTypes := Array new: 11.
    ArrayTypes at: 1 put: (JavaType fromString: 'Ljava/lang/Object;').
    ArrayTypes at: 4 put: JavaPrimitiveType boolean.
    ArrayTypes at: 5 put: JavaPrimitiveType char.
    ArrayTypes at: 6 put: JavaPrimitiveType float.
    ArrayTypes at: 7 put: JavaPrimitiveType double.
    ArrayTypes at: 8 put: JavaPrimitiveType byte.
    ArrayTypes at: 9 put: JavaPrimitiveType short.
    ArrayTypes at: 10 put: JavaPrimitiveType int.
    ArrayTypes at: 11 put: JavaPrimitiveType long.

    DecoderTable := #(
    (#nop)                                   "0"
    (#aconst: nil)                           "1"
    (#iconst: -1)                             "2"
    (#iconst: 0)                              "3"
    (#iconst: 1)                              "4"
    (#iconst: 2)                              "5"
    (#iconst: 3)                              "6"
    (#iconst: 4)                              "7"
    (#iconst: 5)                              "8"
    (#lconst: 0)                              "9"
    
    (#lconst: 1)                              "10"
    (#fconst: 0)                              "11"
    (#fconst: 1)                              "12"
    (#fconst: 2)                              "13"
    (#dconst: 0)                              "14"
    (#dconst: 1)                              "15"
    (#bipush: #signedByte)                     "16"
    (#sipush: #nextShort)                    "17"
    (#ldc: #constIndexByte)              "18"
    (#ldc: #constIndexShort)             "19"

    (#ldc2: #constIndexShort)            "20"
    (#iload: #localIndexByte)                  "21"
    (#lload: #localIndexByte)                  "22"
    (#fload: #localIndexByte)                  "23"
    (#dload: #localIndexByte)                  "24"
    (#aload: #localIndexByte)                  "25"
    (#iload: 0)                               "26"
    (#iload: 1)                               "27"
    (#iload: 2)                               "28"
    (#iload: 3)                               "29"

    (#lload: 0)                               "30"
    (#lload: 1)                               "31"
    (#lload: 2)                               "32"
    (#lload: 3)                               "33"
    (#fload: 0)                               "34"
    (#fload: 1)                               "35"
    (#fload: 2)                               "36"
    (#fload: 3)                               "37"
    (#dload: 0)                               "38"
    (#dload: 1)                               "39"

    (#dload: 2)                               "40"
    (#dload: 3)                               "41"
    (#aload: 0)                               "42"
    (#aload: 1)                               "43"
    (#aload: 2)                               "44"
    (#aload: 3)                               "45"
    (#iaload)                                "46"
    (#laload)                                "47"
    (#faload)                                "48"
    (#daload)                                "49"

    (#aaload)                                "50"
    (#baload)                                "51"
    (#caload)                                "52"
    (#saload)                                "53"
    (#istore: #localIndexByte)                 "54"
    (#lstore: #localIndexByte)                 "55"
    (#fstore: #localIndexByte)                 "56"
    (#dstore: #localIndexByte)                 "57"
    (#astore: #localIndexByte)                 "58"
    (#istore: 0)                              "59"

    (#istore: 1)                              "60"
    (#istore: 2)                              "61"
    (#istore: 3)                              "62"
    (#lstore: 0)                              "63"
    (#lstore: 1)                              "64"
    (#lstore: 2)                              "65"
    (#lstore: 3)                              "66"
    (#fstore: 0)                              "67"
    (#fstore: 1)                              "68"
    (#fstore: 2)                              "69"

    (#fstore: 3)                              "70"
    (#dstore: 0)                              "71"
    (#dstore: 1)                              "72"
    (#dstore: 2)                              "73"
    (#dstore: 3)                              "74"
    (#astore: 0)                              "75"
    (#astore: 1)                              "76"
    (#astore: 2)                              "77"
    (#astore: 3)                              "78"
    (#iastore)                               "79"

    (#lastore)                               "80"
    (#fastore)                               "81"
    (#dastore)                               "82"
    (#aastore)                               "83"
    (#bastore)                               "84"
    (#castore)                               "85"
    (#sastore)                               "86"
    (#pop)                                   "87"
    (#pop2)                                  "88"
    (#dup)                                   "89"

    (#dup_x1)                                "90"
    (#dup_x2)                                "91"
    (#dup2)                                  "92"
    (#dup2_x1)                               "93"
    (#dup2_x2)                               "94"
    (#swap)                                  "95"
    (#iadd)                                  "96"
    (#ladd)                                  "97"
    (#fadd)                                  "98"
    (#dadd)                                  "99"

    (#isub)                                  "100"
    (#lsub)                                  "101"
    (#fsub)                                  "102"
    (#dsub)                                  "103"
    (#imul)                                  "104"
    (#lmul)                                  "105"
    (#fmul)                                  "106"
    (#dmul)                                  "107"
    (#idiv)                                  "108"
    (#ldiv)                                  "109"

    (#fdiv)                                  "110"
    (#ddiv)                                  "111"
    (#irem)                                  "112"
    (#lrem)                                  "113"
    (#frem)                                  "114"
    (#drem)                                  "115"
    (#ineg)                                  "116"
    (#lneg)                                  "117"
    (#fneg)                                  "118"
    (#dneg)                                  "119"

    (#ishl)                                  "120"
    (#lshl)                                  "121"
    (#ishr)                                  "122"
    (#lshr)                                  "123"
    (#iushr)                                 "124"
    (#lushr)                                 "125"
    (#iand)                                  "126"
    (#land)                                  "127"
    (#ior)                                   "128"
    (#lor)                                   "129"

    (#ixor)                                  "130"
    (#lxor)                                  "131"
    (#iinc:by: #localIndexByte #signedByte)  "132"
    (#i2l)                                   "133"
    (#i2f)                                   "134"
    (#i2d)                                   "135"
    (#l2i)                                   "136"
    (#l2f)                                   "137"
    (#l2d)                                   "138"
    (#f2i)                                   "139"

    (#f2l)                                   "140"
    (#f2d)                                   "141"
    (#d2i)                                   "142"
    (#d2l)                                   "143"
    (#d2f)                                   "144"
    (#int2byte)                              "145"
    (#int2char)                              "146"
    (#int2short)                             "147"
    (#lcmp)                                  "148"
    (#fcmpl)                                 "149"

    (#fcmpg)                                 "150"
    (#dcmpl)                                 "151"
    (#dcmpg)                                 "152"
    (#ifeq: #signedBranchShort)                "153"
    (#ifne: #signedBranchShort)                "154"
    (#iflt: #signedBranchShort)                "155"
    (#ifge: #signedBranchShort)                "156"
    (#ifgt: #signedBranchShort)                "157"
    (#ifle: #signedBranchShort)                "158"
    (#if_icmpeq: #signedBranchShort)           "159"

    (#if_icmpne: #signedBranchShort)           "160"
    (#if_icmplt: #signedBranchShort)           "161"
    (#if_icmpge: #signedBranchShort)           "162"
    (#if_icmpgt: #signedBranchShort)           "163"
    (#if_icmple: #signedBranchShort)           "164"
    (#if_acmpeq: #signedBranchShort)           "165"
    (#if_acmpne: #signedBranchShort)           "166"
    (#goto: #signedBranchShort)                "167"
    (#jsr: #signedBranchShort)                 "168"
    (#ret: #localIndexByte)                    "169"

    (#tableswitch:low:high:destinations: #defaultSwitchAddress #lowValue #highValue #tableSwitchBytes)          "170"
    (#lookupswitch:destinations: #defaultSwitchAddress #lookupSwitchBytes)        "171"
    (#ireturn)                               "172"
    (#lreturn)                               "173"
    (#freturn)                               "174"
    (#dreturn)                               "175"
    (#areturn)                               "176"
    (#return)                                "177"
    (#getstatic: #constIndexShort)               "178"
    (#putstatic: #constIndexShort)               "179"

    (#getfield: #constIndexShort)                 "180"
    (#putfield: #constIndexShort)                 "181"
    (#invokevirtual: #constIndexShort)       "182"
    (#invokenonvirtual: #constIndexShort) "183"
    (#invokestatic: #constIndexShort)         "184"
    (#invokeinterface:nargs:reserved: #constIndexShort #nextByte #nextByte)"185"
    nil                           "186"
    (#new: #constIndexShort)      "187"
    (#newarray: #arrayTypeByte)                "188"
    (#anewarray: #constIndexShort)             "189"

    (#arraylength)                           "190"
    (#athrow)                "191"
    (#checkcast: #constIndexShort)             "192"
    (#instanceof: #constIndexShort)            "193"
    (#monitorenter)                          "194"
    (#monitorexit)                           "195"
    (#wide)                                  "196"
    (#multianewarray:dimensions: #constIndexShort #nextByte) "197"
    (#ifnull:    #signedBranchShort)           "198"
    (#ifnonnull: #signedBranchShort)           "199"

    (#goto: #signedBranchLong)            "200"
    (#jsr: #signedBranchShort))
! !

!JavaClass methodsFor: 'printing'!

fullName
    | stream |
    fullName isNil ifTrue: [
        stream := WriteStream on: (String new: 20).
        self printFullNameOn: stream.
        fullName := stream contents ].

    ^fullName
!

printEncodingOn: aStream
    self package printEncodingOn: aStream.
    aStream nextPut: $/; nextPutAll: self name.
    aStream nextPut: $;
!

printExtendsClauseOn: aStream 
    self isInterface ifTrue: [ ^nil ].
    self extends isNil ifTrue: [ ^nil ].
    aStream
    	nl;
    	nextPutAll: '    extends '.
    self extends printFullNameOn: aStream
!

printFieldsOn: aStream 
    (self fields isNil or: [self fields isEmpty]) ifTrue: [^self].
    aStream nl.
    self fields do: 
    		[:each | 
    		aStream
    			nextPutAll: '    ';
    			print: each]
!

printFullNameOn: aStream
    (self package isNil or: [ self package  == JavaPackage root ]) ifFalse: [
    self package printOn: aStream.
    aStream nextPut: $.
    ].
    aStream nextPutAll: self name
!

printImplementsClauseOn: aStream 
    (self implements isNil or: [self implements isEmpty]) ifTrue: [^self].
    aStream nl.
    self isInterface 
    	ifTrue: [aStream nextPutAll: '    extends ']
    	ifFalse: [aStream nextPutAll: '    implements '].
    self implements do: [:interface | interface printFullNameOn: aStream]
    	separatedBy: [aStream nextPutAll: ', ']
!

printMethodsOn: aStream 
    (self methods isNil or: [self methods isEmpty]) ifTrue: [^self].
    aStream nl.
    self methods do: 
    		[:each | 
    		aStream
    			nextPutAll: '    ';
    			print: each].
!

printOn: aStream 
    self printFlagsOn: aStream.
    self isInterface ifFalse: [aStream nextPutAll: 'class '].
    self printFullNameOn: aStream.
    self printExtendsClauseOn: aStream.
    self printImplementsClauseOn: aStream.
    aStream nl; nextPut: ${.
    self printFieldsOn: aStream.
    self printMethodsOn: aStream.
    aStream nextPut: $}
! !

!JavaClass methodsFor: 'private-accessing'!

package: anObject
    package := anObject
! !

!JavaClass methodsFor: 'accessing'!

classDefiningField: name
    | class |
    "Accesses to static fields of implemented interfaces are compiled as
     getstatic bytecodes for Intf.field, not for ClassImplementingIntf.field,
     so we need the (slower) recursion on the implemented interfaces only
     when we are in an interface."
    self isInterface ifTrue: [ ^self interfaceDefiningField: name ].

    class := self.
    [ class isNil or: [ (class definesField: name) ] ] whileFalse: [
    	class := class extends ].
    ^class
!

interfaceDefiningField: name
    (self definesField: name) ifTrue: [ ^self ].
    ^self implements
    	detect: [ :each | (each interfaceDefiningField: name) notNil ]
	ifNone: [ nil ]
!

implementsInterface: anInterface
    | c |
    c := self.
    [
	(c implements includes: anInterface) ifTrue: [ ^true ].
	(c implements anySatisfy: [ :each |
	     each implementsInterface: anInterface ]) ifTrue: [ ^true ].

	c := c extends.
	c isNil
    ] whileFalse.
    ^false!

constantPool
    ^constantPool
!

constantPool: anObject
    constantPool := anObject
!

extends
    ^extends
!

extends: anObject
    extends := anObject
!

fieldAt: aString
    ^fields at: aString
!

fieldAt: aString ifAbsent: aBlock
    ^fields at: aString ifAbsent: aBlock
!

definesField: aString
    fields isNil ifTrue: [ ^false ].
    ^fields includesKey: aString
!

fields
    ^fields
!

fields: aJavaFieldCollection
    fields := LookupTable new: aJavaFieldCollection size * 3 // 2.
    aJavaFieldCollection do: [ :each |
    	each javaClass: self.
	fields at: each name put: each ]
!

flags: allFlags
    "Reset the ACC_SUPER flag"
    flags := allFlags bitAnd: 32 bitInvert
!

implements
    ^implements
!

implements: anObject
    implements := anObject
!

isJavaClass
    ^true
!

isJavaPackage
    ^false
!

isLoaded
    ^constantPool notNil
!

methodAt: aString
    ^methods at: aString
!

methodAt: aString ifAbsent: aBlock
    ^methods at: aString ifAbsent: aBlock
!

definesMethod: aJavaNameAndType
    methods isNil ifTrue: [ ^false ].
    ^methods includesKey:
    	(JavaMethod
	    selectorFor: aJavaNameAndType name
	    type: aJavaNameAndType type)
!

methods
    ^methods
!

methods: aJavaMethodCollection
    methods := IdentityDictionary new: aJavaMethodCollection size * 3 // 2.
    aJavaMethodCollection do: [ :each |
    	each javaClass: self.
	methods at: each selector put: each ]
!

package
    ^package
!

sourceFile
    ^sourceFile
!

sourceFile: anObject
    sourceFile := anObject
! !

!JavaClass class methodsFor: 'instance creation'!

fromString: aString
    | path symbolName aPackage |
    path := aString subStrings: $/.
    aPackage := JavaPackage root.
    path from: 1 to: path size - 1 do: [ :each |
        aPackage := aPackage packageAt: each asSymbol ].

    symbolName := path last asSymbol.
    ^aPackage classAt: symbolName ifAbsentPut: [self new
        package: aPackage;
        name: symbolName;
        yourself]
!

package: aPackage name: className
    | symbolName |
    symbolName := className asSymbol.
    ^aPackage at: symbolName put: (self new
    package: aPackage;
    name: className;
    yourself)
! !

!JavaClassElement methodsFor: 'comparing'!

= anObject
    ^self class == anObject class and: [
	self flags == anObject flags and: [
	self javaClass == anObject javaClass and: [
	self name = anObject name ]]]
!

hash
    ^self name hash bitXor: self javaClass identityHash
! !

!JavaClassElement methodsFor: 'printing'!

printHeadingOn: aStream 
    self printFlagsOn: aStream.
    self signature printOn: aStream withName: name
!

printOn: aStream 
    self printHeadingOn: aStream
! !

!JavaClassElement methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    aJavaAttribute class == JavaSyntheticAttribute 
    ifTrue: 
	[self addSynthetic.
	^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
!

javaClass
    ^javaClass
!

javaClass: anObject
    javaClass := anObject
!

signature
    ^signature
!

signature: anObject
    signature := anObject
! !

!JavaMethod methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    "This should handle the Code attribute's subattributes as well
     (JavaLineNumberTableAttribute and JavaLocalVariableTableAttribute);
     see also the #code: method."
    aJavaAttribute class == JavaCodeAttribute 
        ifTrue: 
            [self code: aJavaAttribute.
            ^aJavaAttribute].
    aJavaAttribute class == JavaLineNumberTableAttribute 
        ifTrue: 
            [self lines: aJavaAttribute lines.
            ^aJavaAttribute].
    aJavaAttribute class == JavaLocalVariableTableAttribute 
        ifTrue: 
            [self localVariables: aJavaAttribute localVariables.
            ^aJavaAttribute].
    aJavaAttribute class == JavaExceptionsAttribute 
        ifTrue: 
            [self exceptions: aJavaAttribute exceptions.
            ^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
!

argTypes
    ^self signature argTypes
!

bytecodes
    ^bytecodes
!

bytecodes: anObject
    bytecodes := anObject
!

code: aJavaCodeAttribute
    self
        maxLocals: aJavaCodeAttribute maxLocals;
        maxStack: aJavaCodeAttribute maxStack;
        bytecodes: aJavaCodeAttribute bytecodes;
        handlers: aJavaCodeAttribute handlers.

    aJavaCodeAttribute attributes do: [ :each |
        self addAttribute: each ]
!

constantPool
    ^javaClass constantPool
!

exceptions
    ^exceptions
!

exceptions: anObject
    exceptions := anObject
!

handlers
    ^handlers
!

handlers: anObject
    handlers := anObject
!

lines
    ^lines
!

lines: anObject
    lines := anObject
!

localVariables
    ^localVariables
!

localVariables: anObject
    localVariables := anObject
!

maxLocals
    ^maxLocals
!

maxLocals: anObject
    maxLocals := anObject
!

maxStack
    ^maxStack
!

maxStack: anObject
    maxStack := anObject
!

numArgs
    ^self signature numArgs
!

returnType
    ^self signature returnType
! !

!JavaMethod methodsFor: 'printing'!

printBytecodesOn: s 
    s
    	tab;
    	nextPutAll: 'bytecodes: ';
    	nl.
    JavaInstructionPrinter print: self on: s
!

printHandlersOn: s 
    (self handlers notNil and: [self handlers notEmpty]) 
    	ifTrue: 
    		[self handlers do: 
    				[:each | 
    				s
    					tab;
    					print: each;
    					nl]]
!

printHeadingOn: s 
    super printHeadingOn: s.
    self exceptions isNil ifTrue: [^self].
    s
    	nl;
    	tab;
    	nextPutAll: 'throws '.
    self exceptions do: [:each | each printFullNameOn: s]
    	separatedBy: [s nextPutAll: ', ']
!

printLimitsOn: s 
    s
    	tab;
    	nextPutAll: 'maxStack: ';
    	print: self maxStack;
    	nextPutAll: ' maxLocals:';
    	print: self maxLocals;
    	nl
!

printOn: s 
    self printHeadingOn: s.
    self bytecodes isNil
    	ifTrue: 
    		[s nextPut: $;; nl.
    		^self].
    s
    	nextPutAll: ' {';
    	nl.
    self printLimitsOn: s.
    self printHandlersOn: s.
    self printBytecodesOn: s.
    s
    	nextPutAll: '    }';
    	nl
! !

!JavaMethod methodsFor: 'source'!

firstLine
    ^self lines first value
!

lastLine
    ^self lines inject: 0 into: [ :max :assoc | max max: assoc value ]
! !

!JavaMethod methodsFor: 'creating'!

selector
    selector isNil ifTrue: [
    	selector := self class selectorFor: self name type: self signature ].
    ^selector
! !

!JavaMethod class methodsFor: 'creating'!

selectorFor: name type: type
    ^(name, type asString) asSymbol
! !

!JavaDescriptor methodsFor: 'testing'!

isMethodSignature
    ^false
! !

!JavaRef methodsFor: 'accessing'!

isMethodSignature
    ^nameAndType isMethodSignature
!

javaClass
    ^javaClass
!

javaClass: anObject
    javaClass := anObject
!

name
    ^self nameAndType name
!

nameAndType
    ^nameAndType
!

nameAndType: anObject
    nameAndType := anObject
!

type
    ^self nameAndType type
!

wordSize
    ^self type wordSize
! !

!JavaRef methodsFor: 'printing'!

printOn: aStream 
    self nameAndType type
        printOn: aStream
        withName: self javaClass fullName , '.' , self nameAndType name
! !

!JavaRef class methodsFor: 'instance creation'!

javaClass: aJavaClass nameAndType: nameAndType
    ^self new
        javaClass: aJavaClass;
        nameAndType: nameAndType;
        yourself
! !

!JavaFieldRef methodsFor: 'accessing'!

getSelector
    getSelector isNil ifTrue: [
    	getSelector := JavaField
	    getSelectorFor: self name
	    in: (self javaClass classDefiningField: self name) ].
    ^getSelector!

putSelector
    putSelector isNil ifTrue: [
    	putSelector := JavaField
	    putSelectorFor: self name
	    in: (self javaClass classDefiningField: self name) ].
    ^putSelector! !

!JavaMethodRef methodsFor: 'accessing'!

argTypes
    ^self type argTypes
!

isVoid
    ^self returnType isVoid
!

numArgs
    ^self type numArgs
!

returnType
    ^self type returnType
!

selector
    selector isNil ifTrue: [
    	selector := JavaMethod selectorFor: self name type: self type ].
    ^selector
!

wordSize
    ^self returnType wordSize
! !

!JavaType methodsFor: 'accessing'!

initializationValue
    ^nil
!

isArrayType
    ^false
!

isPrimitiveType
    ^false
! !

!JavaType methodsFor: 'printing'!


asString
    | stream |
    stream := WriteStream on: (String new: 20).
    self printEncodingOn: stream.
    ^stream contents
!

fullName
    | stream |
    stream := WriteStream on: (String new: 20).
    self printFullNameOn: stream.
    ^stream contents
!

printEncodingOn: aStream
    self subclassResponsibility
!

printFullNameOn: aStream
    self printOn: aStream.
!

printOn: aStream withName: aString
    aStream print: self; space; nextPutAll: aString.
!

storeOn: aStream
    aStream
    nextPut: $(;
    print: self class;
    nextPutAll: ' fromString: ';
    store: self asString;
    nextPut: $)
! !

!JavaType methodsFor: 'jvm quirks'!

arrayClass
    ^Array
!

wordSize
    self subclassResponsibility
! !

!JavaType methodsFor: 'testing'!

isVoid
    ^false
!

isArrayType
    ^false
! !

!JavaType class methodsFor: 'instance creation'!

fromString: aString
    ^self readFrom: aString readStream
!

readFrom: aStream
    (aStream peek = $() ifTrue: [ ^JavaMethodType readFrom: aStream ].
    (aStream peek = $[) ifTrue: [ ^JavaArrayType readFrom: aStream ].
    (aStream peek = $L) ifTrue: [ ^JavaObjectType readFrom: aStream ].
    ^JavaPrimitiveType readFrom: aStream
! !

!JavaObjectType methodsFor: 'accessing'!

javaClass
    ^javaClass
!

javaClass: anObject
    javaClass := anObject
! !

!JavaObjectType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: $L.
    self javaClass printEncodingOn: aStream.
!

printOn: aStream
    self javaClass printFullNameOn: aStream! !

!JavaObjectType methodsFor: 'jvm quirks'!

wordSize
    ^1
! !

!JavaObjectType class methodsFor: 'instance creation'!

javaClass: aJavaClass
    ^self new javaClass: aJavaClass
!

readFrom: aStream
    (aStream peekFor: $L) ifFalse: [ self error: 'expected L' ].
    ^self javaClass: (JavaClass fromString: (aStream upTo: $;))
! !

!JavaMethodType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: $(.
    self argTypes do: [ :each | each printEncodingOn: aStream ].
    aStream nextPut: $).
    self returnType printEncodingOn: aStream
!

printOn: aStream
    self printOn: aStream withName: '*'
!

printOn: aStream withName: aString
    aStream
    print: self returnType;
    space;
    nextPutAll: aString;
    nextPutAll: ' ('.

    self argTypes
    do: [ :each | aStream print: each ]
    separatedBy: [ aStream nextPutAll: ', ' ].

    aStream nextPut: $)
! !

!JavaMethodType methodsFor: 'accessing'!

argTypes
    ^argTypes
!

argTypes: anObject
    argTypes := anObject
!

numArgs
    ^argTypes size
!

returnType
    ^returnType
!

returnType: anObject
    returnType := anObject
! !

!JavaMethodType methodsFor: 'testing'!

isMethodSignature
    ^true
! !

!JavaMethodType methodsFor: 'jvm quirks'!

wordSize
    self shouldNotImplement
! !

!JavaMethodType class methodsFor: 'instance creation'!

readFrom: aStream
    | argTypes returnType |
    argTypes := OrderedCollection new.
    (aStream peekFor: $() ifFalse: [ self error: 'expected (' ].
    [ aStream peekFor: $) ] whileFalse: [
    argTypes addLast: (JavaType readFrom: aStream) ].

    returnType := JavaType readFrom: aStream.
    ^self new
    argTypes: argTypes asArray;
    returnType: returnType;
    yourself
! !

!JavaArrayType methodsFor: 'accessing'!

arrayDimensionality
    | n t |
    n := 1.
    t := self subType.
    [ t isArrayType ] whileTrue: [
	n := n + 1.
        t := self subType ].
    ^n
!

isArrayType
    ^true
!

subType
    ^subType
!

subType: anObject
    subType := anObject
! !

!JavaArrayType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: $[.
    self subType printEncodingOn: aStream
!

printOn: aStream
    self subType printOn: aStream.
    aStream nextPutAll: '[]'
!

printOn: aStream withName: aString
    self subType printOn: aStream withName: aString.
    aStream nextPutAll: '[]'
! !

!JavaArrayType methodsFor: 'jvm quirks'!

wordSize
    ^1
! !

!JavaArrayType methodsFor: 'testing'!

isArrayType
    ^true
! !

!JavaArrayType class methodsFor: 'instance creation'!

readFrom: aStream
    (aStream peekFor: $[) ifFalse: [ self error: 'expected [' ].
    ^self new subType: (JavaType readFrom: aStream)
! !

!JavaInstructionPrinter methodsFor: 'accessing'!

output
    ^output
!

output: anObject
    output := anObject
! !

!JavaInstructionPrinter methodsFor: 'initialize'!

groupLocalVariables: localVariables 
    localVariables do: [:each || collection |
	(collection := localVariableTable at: each slot + 1) isNil 
    	    ifTrue: 
    		[collection := SortedCollection sortBlock: [:a :b | a startpc < b startpc].
		localVariableTable
		    at: each slot + 1
    		    put: collection ].
	collection add: each]
!

initialize: aJavaMethod 
    | sortedLineNumbers |
    self
    	stream: aJavaMethod bytecodes readStream;
    	constantPool: aJavaMethod constantPool.

    sortedLineNumbers := aJavaMethod lines isNil 
    	ifTrue: [#()]
    	ifFalse: [(aJavaMethod lines asSortedCollection: [:a :b | a value <= b value]) asArray].
    lineNumberTable := sortedLineNumbers readStream.

    localVariableTable := Array new: aJavaMethod maxLocals + 1.
    aJavaMethod localVariables isNil
    	ifFalse: [ self groupLocalVariables: aJavaMethod localVariables ]
! !

!JavaInstructionPrinter methodsFor: 'bytecodes'!

aaload
    output nextPutAll: 'aaload'.
!

aastore
    output nextPutAll: 'aastore'.
!

aconst: operand
    output nextPutAll: 'aconst '; print: operand.
!

aload: operand
    output nextPutAll: 'aload '.
    self printLocalVariable: operand.
!

anewarray: operand
    output nextPutAll: 'anewarray '.
    operand printFullNameOn: output
!

areturn
    output nextPutAll: 'areturn'.
!

arraylength
    output nextPutAll: 'arraylength'.
!

astore: operand
    output nextPutAll: 'astore '.
    self printLocalVariable: operand.
!

athrow
    output nextPutAll: 'athrow'.
!

baload
    output nextPutAll: 'baload'.
!

bastore
    output nextPutAll: 'bastore'.
!

bipush: operand
    output nextPutAll: 'bipush '; print: operand
!

caload
    output nextPutAll: 'caload'.
!

castore
    output nextPutAll: 'castore'.
!

checkcast: operand
    output nextPutAll: 'checkcast '.
    operand printFullNameOn: output
!

d2f
    output nextPutAll: 'd2f'
!

d2i
    output nextPutAll: 'd2i'
!

d2l
    output nextPutAll: 'd2l'
!

dadd
    output nextPutAll: 'dadd'
!

daload
    output nextPutAll: 'daload'.
!

dastore
    output nextPutAll: 'dastore'.
!

dcmpg
    output nextPutAll: 'dcmpg'
!

dcmpl
    output nextPutAll: 'dcmpl'
!

dconst: operand
    output nextPutAll: 'dconst '; print: operand
!

ddiv
    output nextPutAll: 'ddiv'
!

dload: operand
    output nextPutAll: 'dload '.
    self printLocalVariable: operand.
!

dmul
    output nextPutAll: 'dmul'
!

dneg
    output nextPutAll: 'dneg'
!

drem
    output nextPutAll: 'drem'
!

dreturn
    output nextPutAll: 'dreturn'
!

dstore: operand
    output nextPutAll: 'dstore '.
    self printLocalVariable: operand.
!

dsub
    output nextPutAll: 'dsub'
!

dup
    output nextPutAll: 'dup'
!

dup2
    output nextPutAll: 'dup2'
!

dup2_x1
    output nextPutAll: 'dup2_x1'
!

dup2_x2
    output nextPutAll: 'dup2_x2'
!

dup_x1
    output nextPutAll: 'dup_x1'
!

dup_x2
    output nextPutAll: 'dup_x2'
!

f2d
    output nextPutAll: 'f2d'
!

f2i
    output nextPutAll: 'f2i'
!

f2l
    output nextPutAll: 'f2l'
!

fadd
    output nextPutAll: 'fadd'
!

faload
    output nextPutAll: 'faload'.
!

fastore
    output nextPutAll: 'fastore'.
!

fcmpg
    output nextPutAll: 'fcmpg'
!

fcmpl
    output nextPutAll: 'fcmpl'
!

fconst: operand
    output nextPutAll: 'fconst '; print: operand
!

fdiv
    output nextPutAll: 'fdiv'
!

fload: operand
    output nextPutAll: 'fload '.
    self printLocalVariable: operand.
!

fmul
    output nextPutAll: 'fmul'
!

fneg
    output nextPutAll: 'fneg'
!

frem
    output nextPutAll: 'frem'
!

freturn
    output nextPutAll: 'freturn'
!

fstore: operand
    output nextPutAll: 'fstore '.
    self printLocalVariable: operand.
!

fsub
    output nextPutAll: 'fsub'
!

getfield: operand
    output nextPutAll: 'getfield <'; print: operand; nextPut: $>
!

getstatic: operand
    output nextPutAll: 'getstatic <'; print: operand; nextPut: $>
!

goto: operand
    output nextPutAll: 'goto '; print: operand
!

i2d
    output nextPutAll: 'i2d'
!

i2f
    output nextPutAll: 'i2f'
!

i2l
    output nextPutAll: 'i2l'
!

iadd
    output nextPutAll: 'iadd'
!

iaload
    output nextPutAll: 'iaload'.
!

iand
    output nextPutAll: 'iand'
!

iastore
    output nextPutAll: 'iastore'.
!

iconst: operand
    output nextPutAll: 'iconst '; print: operand
!

idiv
    output nextPutAll: 'idiv'
!

ifeq: operand
    output nextPutAll: 'ifeq '; print: operand
!

ifge: operand
    output nextPutAll: 'ifge '; print: operand
!

ifgt: operand
    output nextPutAll: 'ifgt '; print: operand
!

ifle: operand
    output nextPutAll: 'ifle '; print: operand
!

iflt: operand
    output nextPutAll: 'iflt '; print: operand
!

ifne: operand
    output nextPutAll: 'ifne '; print: operand
!

ifnonnull: operand
    output nextPutAll: 'ifnonnull '; print: operand
!

ifnull: operand
    output nextPutAll: 'ifnull '; print: operand
!

if_acmpeq: operand
    output nextPutAll: 'if_acmpeq '; print: operand
!

if_acmpne: operand
    output nextPutAll: 'if_acmpne '; print: operand
!

if_icmpeq: operand
    output nextPutAll: 'if_icmpeq '; print: operand
!

if_icmpge: operand
    output nextPutAll: 'if_icmpge '; print: operand
!

if_icmpgt: operand
    output nextPutAll: 'if_icmpgt '; print: operand
!

if_icmple: operand
    output nextPutAll: 'if_icmple '; print: operand
!

if_icmplt: operand
    output nextPutAll: 'if_icmplt '; print: operand
!

if_icmpne: operand
    output nextPutAll: 'if_icmpne '; print: operand
!

iinc: operand by: amount
    output nextPutAll: 'inc '.
    self printLocalVariable: operand.
    output nextPutAll: ', '; print: amount
!

iload: operand
    output nextPutAll: 'iload '.
    self printLocalVariable: operand.
!

imul
    output nextPutAll: 'imul'
!

ineg
    output nextPutAll: 'ineg'
!

instanceof: operand
    output nextPutAll: 'instanceof '.
    operand printFullNameOn: output
!

int2byte
    output nextPutAll: 'int2byte'
!

int2char
    output nextPutAll: 'int2char'
!

int2short
    output nextPutAll: 'int2short'
!

invokeinterface: operand nargs: args reserved: reserved 
    output
    nextPutAll: 'invokeinterface <';
    print: operand;
    nextPutAll: '> (';
    print: args;
    nextPutAll: ' arguments)'
!

invokenonvirtual: operand
    output nextPutAll: 'invokenonvirtual <'; print: operand; nextPut: $>
!

invokestatic: operand
    output nextPutAll: 'invokestatic <'; print: operand; nextPut: $>
!

invokevirtual: operand
    output nextPutAll: 'invokevirtual <'; print: operand; nextPut: $>
!

ior
    output nextPutAll: 'ior'
!

irem
    output nextPutAll: 'irem'
!

ireturn
    output nextPutAll: 'ireturn'
!

ishl
    output nextPutAll: 'ishl'
!

ishr
    output nextPutAll: 'ishr'
!

istore: operand
    output nextPutAll: 'istore '.
    self printLocalVariable: operand.
!

isub
    output nextPutAll: 'isub'
!

iushr
    output nextPutAll: 'iushr'
!

ixor
    output nextPutAll: 'ixor'
!

jsr: operand
    output nextPutAll: 'jsr '; print: operand
!

l2d
    output nextPutAll: 'l2d'
!

l2f
    output nextPutAll: 'l2f'
!

l2i
    output nextPutAll: 'l2i'
!

ladd
    output nextPutAll: 'ladd'
!

laload
    output nextPutAll: 'laload'.
!

land
    output nextPutAll: 'land'
!

lastore
    output nextPutAll: 'lastore'.
!

lcmp
    output nextPutAll: 'lcmp'.
!

lconst: operand
    output nextPutAll: 'lconst '; print: operand
!

ldc2: operand
    output nextPutAll: 'ldc2 '; print: operand
!

ldc: operand
    output nextPutAll: 'ldc '; print: operand
!

ldiv
    output nextPutAll: 'ldiv'
!

lload: operand
    output nextPutAll: 'lload '.
    self printLocalVariable: operand.
!

lmul
    output nextPutAll: 'lmul'
!

lneg
    output nextPutAll: 'lneg'
!

lookupswitch: default destinations: dest
    output nextPutAll: 'lookupswitch '; print: dest; nextPutAll: ', default '; print: default
!

lor
    output nextPutAll: 'lor'
!

lrem
    output nextPutAll: 'lrem'
!

lreturn
    output nextPutAll: 'lreturn'
!

lshl
    output nextPutAll: 'lshl'
!

lshr
    output nextPutAll: 'lshr'
!

lstore: operand
    output nextPutAll: 'lstore '.
    self printLocalVariable: operand.
!

lsub
    output nextPutAll: 'lsub'
!

lushr
    output nextPutAll: 'lushr'
!

lxor
    output nextPutAll: 'lxor'
!

monitorenter
    output nextPutAll: 'monitorenter'
!

monitorexit
    output nextPutAll: 'monitorexit'
!

multianewarray: operand dimensions: dimensions
    output nextPutAll: 'multianewarray '; print: operand; nextPutAll: ', '; print: dimensions
!

new: operand
    output nextPutAll: 'new '.
    operand printFullNameOn: output
!

newarray: operand
    output nextPutAll: 'newarray '; print: operand
!

nop
    output nextPutAll: 'nop'
!

pop
    output nextPutAll: 'pop'
!

pop2
    output nextPutAll: 'pop2'
!

putfield: operand
    output nextPutAll: 'putfield <'; print: operand; nextPut: $>
!

putstatic: operand
    output nextPutAll: 'putstatic <'; print: operand; nextPut: $>
!

ret: operand
    output nextPutAll: 'ret '; print: operand
!

return
    output nextPutAll: 'return'.
!

saload
    output nextPutAll: 'saload'.
!

sastore
    output nextPutAll: 'sastore'.
!

sipush: operand
    output nextPutAll: 'sipush '; print: operand
!

swap
    output nextPutAll: 'swap'
!

tableswitch: default low: low high: high destinations: addresses 
    ^self lookupswitch: default
    	destinations: ((1 to: high - low + 1) 
    			collect: [:i | low + i - 1 -> (addresses at: i)])
! !

!JavaInstructionPrinter methodsFor: 'interpretation'!

dispatch: insn 
    output
    	tab;
    	print: pc;
    	tab.
    super dispatch: insn.
    self printCurrentLine.
    output nl
!

printCurrentLine
    
    lineNumberTable atEnd ifTrue: [^self].
    lineNumberTable peek key > pc ifTrue: [ ^self ].
    output
    	tab;
    	nextPutAll: '// source line ';
    	print: lineNumberTable next value
!

printLocalVariable: index
    | coll low high mid item |
    index printOn: output.
    coll := localVariableTable at: index + 1.
    low := 1.
    high := coll size.
    
    [mid := (low + high) // 2.
    low > high ifTrue: [^nil].
    item := coll at: mid.
    item includes: pc] 
    		whileFalse: 
    			[item startpc < pc ifTrue: [low := mid + 1] ifFalse: [high := mid - 1]].

    output nextPutAll: ' ('; nextPutAll: item name; nextPut: $)
! !

!JavaInstructionPrinter class methodsFor: 'printing methods'!

print: aJavaMethod on: outputStream
    (self on: aJavaMethod bytecodes readStream)
    initialize: aJavaMethod;
    output: outputStream;
    interpret
! !

!JavaNameAndType methodsFor: 'accessing'!

isMethodSignature
    ^type isMethodSignature
!

name
    ^name
!

name: anObject
    name := anObject
!

type
    ^type
!

type: anObject
    type := anObject
! !

!JavaNameAndType methodsFor: 'printing'!

printOn: aStream
    self type printOn: aStream withName: self name
! !

!JavaNameAndType class methodsFor: 'instance creation'!

name: aSymbol type: aType
    ^self new
    name: aSymbol;
    type: aType;
    yourself
! !

!JavaPrimitiveType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: self id
!

printOn: aStream
    aStream nextPutAll: self name
! !

!JavaPrimitiveType methodsFor: 'accessing'!

arrayClass
    ^arrayClass
!

arrayClass: aClass
    arrayClass := aClass
!

id
    ^id
!

id: anObject
    id := anObject
!

initializationValue
    ^zeroValue
!

isPrimitiveType
    ^true
!

zeroValue: anObject
    zeroValue := anObject
!

name
    ^name
!

name: anObject
    name := anObject
!

wordSize
    ^wordSize
!

wordSize: anObject
    wordSize := anObject
! !

!JavaPrimitiveType methodsFor: 'copying'!

copy
    ^self
!

shallowCopy
    ^self
! !

!JavaPrimitiveType methodsFor: 'testing'!

isVoid
    ^self wordSize == 0
! !

!JavaPrimitiveType class methodsFor: 'initializing'!

initialize
    "self initialize"
    PrimitiveTypes := IdentityDictionary new: 32.
    PrimitiveTypes at: $B put: (JavaByte := self
	id: $B name: 'byte' wordSize: 1 arrayClass: JavaByteArray zeroValue: 0).
    PrimitiveTypes at: $C put: (JavaChar := self
	id: $C name: 'char' wordSize: 1 arrayClass: JavaCharArray zeroValue: 0).
    PrimitiveTypes at: $D put: (JavaDouble := self
	id: $D name: 'double' wordSize: 2 arrayClass: JavaDoubleArray zeroValue: 0.0d).
    PrimitiveTypes at: $F put: (JavaFloat := self
	id: $F name: 'float' wordSize: 1 arrayClass: JavaFloatArray zeroValue: 0.0e).
    PrimitiveTypes at: $I put: (JavaInt := self
	id: $I name: 'int' wordSize: 1 arrayClass: JavaIntArray zeroValue: 0).
    PrimitiveTypes at: $J put: (JavaLong := self
	id: $J name: 'long' wordSize: 2 arrayClass: JavaLongArray zeroValue: 0).
    PrimitiveTypes at: $S put: (JavaShort := self
	id: $S name: 'short' wordSize: 1 arrayClass: JavaShortArray zeroValue: 0).
    PrimitiveTypes at: $V put: (JavaVoid := self
	id: $V name: 'void' wordSize: 0 arrayClass: nil zeroValue: nil).
    PrimitiveTypes at: $Z put: (JavaBoolean := self
	id: $Z name: 'boolean' wordSize: 1 arrayClass: ByteArray zeroValue: 0)
! !

!JavaPrimitiveType class methodsFor: 'instance creation'!

boolean
    ^JavaBoolean
!

byte
    ^JavaByte
!

char
    ^JavaChar
!

double
    ^JavaDouble
!

float
    ^JavaFloat
!

id: aCharacter name: aString wordSize: anInteger arrayClass: aClass zeroValue: anObject
    ^self new
        id: aCharacter;
        name: aString;
        wordSize: anInteger;
	arrayClass: aClass;
	zeroValue: anObject;
        yourself
!

int
    ^JavaInt
!

long
    ^JavaLong
!

readFrom: aStream
    ^PrimitiveTypes at: aStream next
!

short
    ^JavaShort
!

void
    ^JavaVoid
! !

!JavaLocalVariable methodsFor: 'accessing'!

endpc
    ^startpc + length
!

length
    ^length
!

length: anObject
    length := anObject
!

name
    ^name
!

name: anObject
    name := anObject
!

slot
    ^slot
!

slot: anObject
    slot := anObject
!

startpc
    ^startpc
!

startpc: anObject
    startpc := anObject
!

type
    ^type
!

type: anObject
    type := anObject
! !

!JavaLocalVariable methodsFor: 'printing'!

printOn: s 
    self type printOn: s withName: self name.
    s
    	nextPutAll: ' (start pc: ';
    	print: self startpc;
    	nextPutAll: ' end pc: ';
    	print: self startpc + self length;
    	nextPutAll: ' slot: ';
    	print: self slot;
    	nextPut: $)
! !

!JavaLocalVariable methodsFor: 'testing'!

includes: pc
    ^self startpc <= pc and: [ pc < self endpc ]
! !

!JavaLocalVariable class methodsFor: 'instance creation'!

startpc: s length: l name: n type: typ slot: i
    ^self new
        startpc: s;
        length: l;
        name: n;
        type: typ;
        slot: i;
        yourself
! !

!JavaPackage methodsFor: 'printing'!

printEncodingOn: aStream
    self container isNil ifFalse: [
        self container printOn: aStream.
        aStream nextPut: $/
    ].
    aStream nextPutAll: self name
!

printOn: aStream
    (self container isNil or: [ self container == Root ]) ifFalse: [
        self container printOn: aStream.
        aStream nextPut: $.
    ].
    aStream nextPutAll: self name
! !

!JavaPackage methodsFor: 'initializing'!

initialize
    contents := IdentityDictionary new
! !

!JavaPackage methodsFor: 'accessing'!

at: aSymbol
    ^self contents at: aSymbol
!

at: aSymbol ifAbsentPut: aBlock
    ^self contents at: aSymbol ifAbsentPut: aBlock value
!

at: aSymbol put: anObject
    ^self contents at: aSymbol put: anObject
!

classAt: aSymbol
    | value |
    value := self contents at: aSymbol.
    value isJavaClass ifFalse: [ self error: 'class expected, found package' ].
    ^value
!

classAt: aSymbol ifAbsentPut: aBlock
    | value |
    value := self contents at: aSymbol ifAbsentPut: aBlock.
    value isJavaClass ifFalse: [ self error: 'class expected, found package' ].
    ^value
!

container
    ^container
!

container: anObject
    container := anObject
!

contents
    ^contents
!

isJavaClass
    ^false
!

isJavaPackage
    ^true
!

name
    ^name
!

name: anObject
    name := anObject asSymbol
!

packageAt: aSymbol
    | value |
    value := self contents at: aSymbol ifAbsentPut: [ self class name: aSymbol container: self ].
    value isJavaPackage ifFalse: [ self error: 'package expected, found class' ].
    ^value
! !

!JavaPackage class methodsFor: 'instance creation'!

name: aSymbol container: aJavaPackage
    ^self new
        name: aSymbol;
        container: aJavaPackage;
        yourself
!

new
    ^self basicNew initialize
!

root
    ^Root
! !

!JavaPackage class methodsFor: 'initializing'!

initialize
    "self initialize"
    Root := self new.
    Root name: 'JAVA'
! !

!JavaField methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    aJavaAttribute class == JavaConstantValueAttribute ifTrue: 
        [self constantValue: aJavaAttribute constant.
        ^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
!

constantValue
    ^constantValue
!

constantValue: anObject
    constantValue := anObject
! !

!JavaField methodsFor: 'printing'!

printOn: aStream
    self printHeadingOn: aStream.
    self constantValue notNil ifTrue: [
    aStream nextPutAll: ' = '; print: self constantValue ].
    aStream nextPut: $;.
    aStream nl.
! !

!JavaField methodsFor: 'compiling'!

getSelector
    getSelector isNil ifTrue: [
    	getSelector := self class getSelectorFor: self name in: self javaClass ].
    ^getSelector!

putSelector
    putSelector isNil ifTrue: [
    	putSelector := self class putSelectorFor: self name in: self javaClass ].
    ^putSelector! !

!JavaField class methodsFor: 'compiling'!

getSelectorFor: name in: class
    | string className ch |
    className := class fullName.
    string := String new: className size + 1 + name size.
    1 to: className size do: [ :i |
        string
	    at: i
	    put: ((ch := className at: i) = $. ifTrue: [ $$ ] ifFalse: [ ch ]).
    ].
    string
    	at: className size + 1 put: $$.
    string
    	replaceFrom: className size + 2
	to: string size
	with: name
	startingAt: 1.

    ^string asSymbol!

putSelectorFor: name in: class
    | string className ch |
    className := class fullName.
    string := String new: className size + 2 + name size.
    1 to: className size do: [ :i |
        string
	    at: i
	    put: ((ch := className at: i) = $. ifTrue: [ $$ ] ifFalse: [ ch ]).
    ].
    string
    	at: className size + 1 put: $$.
    string
    	replaceFrom: className size + 2
	to: string size - 1
	with: name
	startingAt: 1.
    string
    	at: string size put: $:.

    ^string asSymbol! !

JavaProgramElement initialize!
JavaPrimitiveType initialize!
JavaPackage initialize!
JavaInstructionInterpreter initialize!
