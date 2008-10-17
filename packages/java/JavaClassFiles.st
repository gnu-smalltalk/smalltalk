"======================================================================
|
|   Java .class file loading
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2008 Free Software Foundation, Inc.
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
| You should have received a copy of the GNU General Public License along 
| with the GNU Smalltalk class library; see the file COPYING.  If not, 
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor, 
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #JavaAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaAttribute comment: '
This class is an abstract superclass for attributes read from a .class file.
'!


Array variableSubclass: #JavaConstantPool
    instanceVariableNames: 'complete javaClassReader '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaConstantPool comment: '
JavaConstantPool represents the constant pool in a class file before
it has been loaded completely.  It has two phases, one in which the
constant pool is being build and one afterwards.  When it is being
built, forward references (instances of JavaConstantProxy) return nil;
afterwards, they invoke #resolve: on the JavaConstantProxy object so
that the classes, strings, nameAndTypes and references are put
together correctly.

The use of this class is usually completely transparent.
JavaClassReader uses it temporarily inside #readConstantPool, which in
the end returns a simple (and more efficient) Array.

Instance Variables:
    complete	<Boolean>
	true if the whole constant pool has been filled
    javaClassReader	<Object>
	the javaClassReader which will be passed to JavaConstantPool
'!


JavaAttribute subclass: #JavaConstantValueAttribute
    instanceVariableNames: 'constant '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaConstantValueAttribute comment: '
JavaCodeAttribute is a representation of the ConstantValue attribute
in .class files.  It represents the value of final fields in a class.

Instance Variables:
    constant	<Object>
	the value of the field

'!


Smalltalk.Object subclass: #JavaConstantProxy
    instanceVariableNames: 'message '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaConstantProxy comment: '
JavaConstantProxy is a helper object to resolve forward references in
a .class file''s constant pool.

Instance Variables:
    message	<Message>
	message to be sent to recreate the constant, with constant pool indices instead of arguments

'!


JavaAttribute subclass: #JavaFlagAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaFlagAttribute comment: '
JavaFlagAttribute is an abstract class for attributes that have no
data field attached to them.

'!


JavaFlagAttribute subclass: #JavaSyntheticAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaSyntheticAttribute comment: '
JavaFlagAttribute represents the Synthetic attribute in a .class file.'!


JavaAttribute subclass: #JavaLocalVariableTableAttribute
    instanceVariableNames: 'localVariables '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaLocalVariableTableAttribute comment: '
JavaLocalVariableTableAttribute represents the LocalVariableTable
attribute in a .class file, which maps local variable slots to
variable names in the .java file.

Instance Variables:
    locals	<(Collection of: JavaLocalVariable)>
	the collection of local variable names for the method.

'!


JavaAttribute subclass: #JavaExceptionsAttribute
    instanceVariableNames: 'exceptions '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaExceptionsAttribute comment: '
JavaExceptionsAttribute is a representation of the Exceptions
attribute in .class files.  It represents the exceptions that a method
can throw.

Instance Variables:
    exceptions	<(Collection of: JavaClass)>
	the list of exceptions in the throws clause.

'!


JavaFlagAttribute subclass: #JavaDeprecatedAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaDeprecatedAttribute comment: '
JavaFlagAttribute represents the Deprecated attribute in a .class file.

'!


JavaAttribute subclass: #JavaUnknownAttribute
    instanceVariableNames: 'attributeName bytes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaUnknownAttribute comment: '
JavaUnknownAttribute represents an attribute which is not known to the
system.

Instance Variables:
    attributeName	<String>
	the name of the attribute
    bytes	<ByteArray>
	the raw bytes that compose the attribute

'!


JavaAttribute subclass: #JavaCodeAttribute
    instanceVariableNames: 'maxStack maxLocals bytecodes handlers attributes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaCodeAttribute comment: '
JavaCodeAttribute is a representation of the Code attribute in .class
files.  It includes most of the information about a method, either
directly or through its own subattributes

Instance Variables:
    attributes	<(Collection of: JavaAttribute)>
	description of attributes
    bytecodes	<ByteArray>
	the method''s bytecodes
    handlers	<(Collection of: JavaExceptionHandler)>
	the ranges of program counter values for the method''s exception handlers
    maxLocals	<Integer>
	the number of local variables used by the method
    maxStack	<Integer>
	the number of stack slots used by the method

'!


JavaAttribute subclass: #JavaLineNumberTableAttribute
    instanceVariableNames: 'lines '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaLineNumberTableAttribute comment: '
JavaLineNumberTableAttribute represents the LineNumberTable attribute
in a .class file, which maps program counter values to line numbers in
the .java file.

Instance Variables:
    lines	<(Collection of: (Integer->Integer))>
	associations that map a PC value to a line number

'!


Smalltalk.Object subclass: #JavaStringPrototype
    instanceVariableNames: 'stringValue '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

JavaStringPrototype comment: '
JavaStringPrototype is a placeholder for instances of java.lang.String
that are created before the class is loaded, during system
bootstrap.'!


JavaAttribute subclass: #JavaSourceFileAttribute
    instanceVariableNames: 'fileName '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaSourceFileAttribute comment: '
JavaSourceFileAttribute represents the SourceFile attribute in a .class file.

Instance Variables:
    fileName	<String>
		the file from which the compiled .class file was generated.

'!


JavaReader subclass: #JavaClassFileReader
    instanceVariableNames: ''
    classVariableNames: 'ClassDirectories'
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaClassFileReader comment: '
JavaClassFileReader is an abstract superclass for objects that deal
with Java class files: it has methods for handling attributes and type
descriptors

Subclasses must implement the following messages:
    building-utility
    	typeFromString:

'!


JavaClassFileReader subclass: #JavaClassReader
    instanceVariableNames: 'tag '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaClassReader comment: '
JavaClassReader reads a .class file and invokes its own abstract
methods to communicate the results of reading the file.

Subclasses must implement the following messages:
    building the class
    	accessFlags:
    	attributes:
    	extends:
    	fields:
    	implements:
    	methods:
    	thisClass:
    building-utility
    	class:nameAndType:
    	fieldFromFlags:name:signature:attributes:
    	methodFromFlags:name:signature:attributes:
    	name:type:

'!


JavaClassFileReader subclass: #JavaAttributeReader
    instanceVariableNames: 'classReader '
    classVariableNames: 'AttributeNames'
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaAttributeReader comment: '
JavaAttributeReader mediates between other JavaClassFileReaders and
JavaAttribute for reading attributes.  It handles a table of attribute
names vs. JavaAttribute subclasses, and ensures that these cannot go
beyond the end of the attribute data.

Instance Variables:
    classReader	<JavaClassFileReader>
	the object that asked to read an attribute.

'!


JavaClassReader subclass: #JavaClassBuilder
    instanceVariableNames: 'thisClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaClassBuilder comment: '
JavaClassBuilder uses JavaClassReader''s services to create a
JavaClass (and its containing JavaPackages) from its .class file.

Instance Variables:
    thisClass	<JavaClass>
	description of thisClass

'!






!JavaAttribute methodsFor: 'testing'!

isLineAttribute
    ^false
!

isLocalsAttribute
    ^false
! !

!JavaAttribute class methodsFor: 'reading'!

attributeName
    ^nil
!

readFrom: aJavaClassReader
    ^JavaAttributeReader new readFrom: aJavaClassReader
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    self subclassResponsibility
! !

!JavaConstantPool methodsFor: 'accessing'!

at: anIndex
    | obj |
    obj := super at: anIndex.
    obj class == JavaConstantProxy ifFalse: [ ^obj ].
    self complete ifFalse: [ ^nil ].

    obj := obj resolve: self.
    self at: anIndex put: obj.
    ^obj
!

complete
    ^complete
!

complete: anObject
    complete := anObject
!

javaClassReader
    ^javaClassReader
!

javaClassReader: anObject
    javaClassReader := anObject
! !

!JavaConstantPool methodsFor: 'converting'!

asArray
    | a |
    a := Array new: self size.
    "This automatically resolves everything"
    1 to: self size do: [ :each | a at: each put: (self at: each) ].
    ^a
! !

!JavaConstantPool methodsFor: 'copying'!

copyEmpty
    ^Array new: self size
!

copyEmpty: size
    ^Array new: size
!

species
    ^Array
! !

!JavaConstantPool class methodsFor: 'instance creation'!

new: size
    ^(self basicNew: size)
    	complete: false;
    	yourself
! !

!JavaConstantValueAttribute methodsFor: 'printing'!

printOn: s
    "Print that this is a constant"

    s nextPutAll:'constant value '; print: self constant; nl.
! !

!JavaConstantValueAttribute methodsFor: 'accessing'!

constant
    ^constant
!

constant: i
    "Set the index in the pool we are pointing to"

    constant := i
! !

!JavaConstantValueAttribute class methodsFor: 'instance creation'!

constant: i
    "Return an initialized instance"

    ^self new constant: i
! !

!JavaConstantValueAttribute class methodsFor: 'reading'!

attributeName
    ^'ConstantValue'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | constant |
    constant := aJavaAttributeReader nextConstant.
    ^self constant: constant
! !

!JavaConstantProxy methodsFor: 'resolving'!

resolve: constantPool
    ^constantPool javaClassReader
    	perform: message selector
    	withArguments: (message arguments collect: [ :each | constantPool at: each ])
! !

!JavaConstantProxy methodsFor: 'accessing'!

message
    ^message
!

message: anObject
    message := anObject
! !

!JavaConstantProxy class methodsFor: 'instance creation'!

selector: aSymbol arguments: anArray
    ^self new message: (Message selector: aSymbol arguments: anArray)
! !

!JavaFlagAttribute class methodsFor: 'reading'!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    ^self new
! !

!JavaSyntheticAttribute class methodsFor: 'reading'!

attributeName
    ^'Synthetic'
! !

!JavaLocalVariableTableAttribute methodsFor: 'accessing'!

localVariables
    ^localVariables
!

localVariables: l
    localVariables := l
! !

!JavaLocalVariableTableAttribute methodsFor: 'printing'!

printOn: s
    self localVariables do: [:l | s print: l; nl ]
! !

!JavaLocalVariableTableAttribute methodsFor: 'testing'!

isLocalsAttribute
    ^true
! !

!JavaLocalVariableTableAttribute class methodsFor: 'instance creation'!

localVariables: i
    "Return a new instance with the lines set"

    ^self new localVariables: i
! !

!JavaLocalVariableTableAttribute class methodsFor: 'reading'!

attributeName
    ^'LocalVariableTable'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | vars var |
    vars := Array new: aJavaAttributeReader  nextUshort.
    1 to: vars size do: [ :i |
    var := JavaLocalVariable
        startpc: aJavaAttributeReader nextUshort
        length: aJavaAttributeReader nextUshort
        name: aJavaAttributeReader nextConstant
        type: aJavaAttributeReader nextType
        slot: aJavaAttributeReader nextUshort.

    vars at: i put: var ].
    ^self localVariables: vars
! !

!JavaExceptionsAttribute methodsFor: 'accessing'!

exceptions
    ^exceptions
!

exceptions: e
    "Set the exceptions"

    exceptions := e
! !

!JavaExceptionsAttribute methodsFor: 'printing'!

printOn: s
    "Print the code on the stream"

    s nextPutAll:'exceptions: '; nl.
    exceptions
    do:[:e| e printFullNameOn: s]
    separatedBy: [ s nextPutAll: ', ' ]
! !

!JavaExceptionsAttribute class methodsFor: 'instance creation'!

exceptions: e
    "Return an initialized instance"

    ^self new exceptions: e
! !

!JavaExceptionsAttribute class methodsFor: 'reading'!

attributeName
    ^'Exceptions'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | exceptions |
    exceptions := Array new: aJavaAttributeReader nextUshort.
    1 to: exceptions size do: [ :i |
    exceptions at: i put: aJavaAttributeReader nextConstant ].
    ^self exceptions: exceptions
! !

!JavaDeprecatedAttribute class methodsFor: 'reading'!

attributeName
    ^'Deprecated'
! !

!JavaUnknownAttribute methodsFor: 'printing'!

printOn: s
    "Prit unknown attribute"

    s nextPutAll:'unknown attribute named: '; print: self attributeName; nl.
! !

!JavaUnknownAttribute methodsFor: 'accessing'!

attributeName
    ^attributeName
!

attributeName: n
    "Set the name"

    attributeName := n
!

bytes
    ^bytes
!

bytes: b
    "Set the bytes"

    bytes := b
! !

!JavaUnknownAttribute class methodsFor: 'instance creation'!

name: n bytes: b
    "return an initialized instance"

    ^self new
    	attributeName: n;
    	bytes: b;
    	yourself
! !

!JavaUnknownAttribute class methodsFor: 'reading'!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    ^self name: attributeName bytes: aJavaAttributeReader rawBytes
! !

!JavaCodeAttribute methodsFor: 'printing'!

printOn: s
    s nextPutAll:'bytecodes: '; nl.
    JavaInstructionPrinter print: self bytecodes on: s.
    s nextPutAll:' maxStack: '; print: self maxStack; nextPutAll: ' maxLocals:'; print: self maxLocals; nl.
    self attributes do:[:a|
    	s nextPutAll:' attribute: '; nl; tab.
    	a printOn: s].
! !

!JavaCodeAttribute methodsFor: 'accessing'!

attributes
    ^attributes
!

attributes: a
    "Set the other attributes"

    attributes := a
!

bytecodes
    ^bytecodes
!

bytecodes: anObject
    bytecodes := anObject
!

handlers
    ^handlers
!

handlers: anObject
    handlers := anObject
!

lines
    ^attributes detect: [:a | a isLineAttribute ] ifNone: [nil]
!

localVariables
    ^attributes detect: [:a | a isLocalsAttribute ] ifNone: [nil]
!

maxLocals
    ^maxLocals
!

maxLocals: l
    "Set max locals"

    maxLocals := l.
!

maxStack
    ^maxStack
!

maxStack: m
    "Set max stack"

    maxStack := m
! !

!JavaCodeAttribute class methodsFor: 'instance creation'!

maxStack: ms maxLocals: ml bytecodes: bc handlers: h attributes: a
    "Return a new instance"

    ^self new
    	maxStack: ms;
    	maxLocals: ml;
    	bytecodes: bc;
    	handlers: h;
    	attributes: a;
    	yourself
! !

!JavaCodeAttribute class methodsFor: 'reading'!

attributeName
    ^'Code'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | maxStack maxLocals bytecodes handlers handler attributes |
    maxStack := aJavaAttributeReader nextUshort.
    maxLocals := aJavaAttributeReader nextUshort.
    bytecodes := aJavaAttributeReader nextBytes: aJavaAttributeReader nextUint.
    handlers := Array new: aJavaAttributeReader nextUshort.
    1 to: handlers size do: [ :i |
        handler := JavaExceptionHandler
            startpc: aJavaAttributeReader nextUshort
            finalpc: aJavaAttributeReader nextUshort "+ 1   include final byte"
            handlerpc: aJavaAttributeReader nextUshort
            type: aJavaAttributeReader nextConstant.

        handlers at: i put: handler ].

    attributes := aJavaAttributeReader readAttributes.
    ^self
    	maxStack: maxStack
	maxLocals: maxLocals
	bytecodes: bytecodes
	handlers: handlers
	attributes: attributes.
! !

!JavaLineNumberTableAttribute methodsFor: 'printing'!

printOn: s
    "Print the size of the line numbers on the stream"

    s nextPutAll:'line number table: '; print: self lines; nl.
! !

!JavaLineNumberTableAttribute methodsFor: 'testing'!

isLineAttribute
    ^true
! !

!JavaLineNumberTableAttribute methodsFor: 'accessing'!

lines
    ^lines
!

lines: l
    "Set the lines"

    lines := l
! !

!JavaLineNumberTableAttribute class methodsFor: 'instance creation'!

lines: i
    "Return a new instance with the lines set"

    ^self new lines: i
! !

!JavaLineNumberTableAttribute class methodsFor: 'reading'!

attributeName
    ^'LineNumberTable'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | lines |
    lines := Array new: aJavaAttributeReader  nextUshort.
    1 to: lines size do: [ :i |
    lines at: i put: (aJavaAttributeReader nextUshort -> aJavaAttributeReader nextUshort) ].
    ^self lines: lines
! !

!JavaStringPrototype methodsFor: 'accessing'!

stringValue
    ^stringValue
!

stringValue: anObject
    stringValue := anObject
! !

!JavaStringPrototype methodsFor: 'printing'!

printOn: aStream 
    aStream
    	nextPutAll: '<java.lang.String: ';
    	store: self stringValue;
    	nextPut: $>
! !

!JavaStringPrototype class methodsFor: 'instance creation'!

stringValue: aString
    ^self new stringValue: aString
! !

!JavaSourceFileAttribute methodsFor: 'printing'!

printOn: s
    "Print the name of the source file on the stream"

    s nextPutAll: '// source file: '; print: fileName.
! !

!JavaSourceFileAttribute methodsFor: 'accessing'!

fileName
    ^fileName
!

fileName: anObject
    fileName := anObject
! !

!JavaSourceFileAttribute class methodsFor: 'instance creation'!

filename: i
    "Return an initialized instance"

    ^self new filename: i
! !

!JavaSourceFileAttribute class methodsFor: 'reading'!

attributeName
    ^'SourceFile'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    ^self new fileName: aJavaAttributeReader nextConstant
! !

!JavaClassFileReader class methodsFor: 'class path'!

classDirectories
    ^ClassDirectories
!

classDirectories: aCollection
    ClassDirectories := aCollection
!

classPath
    ^self classDirectories fold: [ :a :b | a, ':', b ]
!

classPath: pathList
    self classDirectories: (pathList subStrings: $:)
!

findClassFile: aClass 
    | path |
    path := (aClass copyReplacing: $. withObject: $/) , '.class'.
    self classDirectories isNil
	ifTrue: [ self error: 'CLASSPATH not set' ].
    self classDirectories do: [:dir || file |
        file := dir / path.
        file exists ifTrue: [ ^file ]].

    ^nil
! !

!JavaClassFileReader methodsFor: 'stream accessing'!

nextType
    ^self typeFromString: self nextConstant
! !

!JavaClassFileReader methodsFor: 'building-utility'!

typeFromString: aString
    self subclassResponsibility
! !

!JavaClassFileReader methodsFor: 'reading structures'!

readAttribute: list 
    ^JavaAttribute readFrom: self
!

readAttributes
    ^self next: (self nextUshort) collect: [ :attrList | self readAttribute: attrList ].
! !

!JavaClassReader methodsFor: 'reading structures'!

readConstantPool
    | cp |
    cp := self 
    	next: self nextUshort - 1
    	collect: [:pool | self readConstant: pool]
    	into: JavaConstantPool.

    "Now resolve the forward references"
    cp
    	complete: true;
    	javaClassReader: self.
    ^cp asArray
!

readField
    ^self 
    	fieldFromFlags: self nextUshort
    	name: self nextConstant
    	signature: self nextType
    	attributes: self readAttributes
!

readFields
    ^self next: (self nextUshort) collect: [ :fieldList | self readField ].
!

readFile
    | accessFlags |
    self magic: self nextUint.
    self minor: self nextUshort major: self nextUshort.

    "These two are before the class name, so we load them into
     a temporary or instance variable."
    self constantPool: self readConstantPool.
    accessFlags := self nextUshort.

    "After creating the class, assign the already-read flags"
    self thisClass: self nextConstant.
    self accessFlags: accessFlags.

    self extends: self nextConstant.
    self implements: self readInterfaces.
    self fields: self readFields.
    self methods: self readMethods.
    self attributes: self readAttributes
!

readInterfaces
    ^self next: (self nextUshort) collect: [ :intfList | self nextConstant ].
!

readMethod
    ^self 
    	methodFromFlags: self nextUshort
    	name: self nextConstant
    	signature: self nextType
    	attributes: self readAttributes
!

readMethods
    ^self next: (self nextUshort) collect: [ :mthList | self readMethod ].
! !

!JavaClassReader methodsFor: 'reading constants'!

readBad: cp
    ^self error: 'invalid constant pool entry'
!

readClass: cp
    | constant index |
    index := self nextUshort.
    constant := cp at: index.
    ^constant isNil
    	ifTrue: [ JavaConstantProxy selector: #classFromString: arguments: (Array with: index) ]
    	ifFalse: [ self classFromString: constant ]
!

readConstant: cp
    | selector |
    "Work around the brainlessness of Java: constant pool entries for
     long and doubles take two slots."
    (tag == 5 or: [ tag == 6 ]) ifTrue: [ tag := nil. ^nil ].

    tag := self nextByte.
    (tag between: 1 and: 12) ifFalse: [ ^self error: 'invalid constant pool entry' ].
    selector := #(#readUTF8String: #readBad: #readInt: #readFloat: #readLong:
    #readDouble: #readClass: #readString: #readRef: #readMethodRef: #readMethodRef:
    #readNameAndType:)
    at: tag.

   ^self perform: selector with: cp
!

readDouble: cp
    ^self nextDouble
!

readFloat: cp
    ^self nextFloat
!

readInt: cp
    ^self nextInt
!

readLong: cp
    ^self nextLong
!

readMethodRef: cp 
    | classConstant nameTypeConstant classIndex nameTypeIndex |
    classIndex := self nextUshort.
    nameTypeIndex := self nextUshort.
    classConstant := cp at: classIndex.
    nameTypeConstant := cp at: nameTypeIndex.
    ^(classConstant isNil or: [nameTypeConstant isNil]) 
    	ifTrue: 
    		[JavaConstantProxy
    			selector: #class:methodNameAndType:
    			arguments: (Array with: classIndex with: nameTypeIndex)]
    	ifFalse:
    		[self
    			class: classConstant
    			methodNameAndType: nameTypeConstant]
!

readNameAndType: cp 
    | nameConstant typeConstant nameIndex typeIndex |
    nameIndex := self nextUshort.
    typeIndex := self nextUshort.
    nameConstant := cp at: nameIndex.
    typeConstant := cp at: typeIndex.
    ^(nameConstant isNil or: [typeConstant isNil]) 
    	ifTrue: 
    		[JavaConstantProxy
    			selector: #nameString:typeString:
    			arguments: (Array with: nameIndex with: typeIndex)]
    	ifFalse:
    		[self
    			nameString: nameConstant
    			typeString: typeConstant]
!

readRef: cp 
    | classConstant nameTypeConstant classIndex nameTypeIndex |
    classIndex := self nextUshort.
    nameTypeIndex := self nextUshort.
    classConstant := cp at: classIndex.
    nameTypeConstant := cp at: nameTypeIndex.
    ^(classConstant isNil or: [nameTypeConstant isNil]) 
    	ifTrue: 
    		[JavaConstantProxy
    			selector: #class:nameAndType:
    			arguments: (Array with: classIndex with: nameTypeIndex)]
    	ifFalse:
    		[self
    			class: classConstant
    			nameAndType: nameTypeConstant]
!

readString: cp
    | constant index |
    index := self nextUshort.
    constant := cp at: index.
    ^constant isNil
    	ifTrue: [ JavaConstantProxy selector: #javaLangString: arguments: (Array with: index) ]
    	ifFalse: [ self javaLangString: constant ]
!

readUTF8String: cp
    ^self nextUTF8String
! !

!JavaClassReader methodsFor: 'building the class'!

accessFlags: flags
    self subclassResponsibility
!

attributes: attributes
    self subclassResponsibility
!

extends: superclass
    self subclassResponsibility
!

fields: fields
    self subclassResponsibility
!

implements: interfaces
    self subclassResponsibility
!

magic
    ^16rCAFEBABE
!

magic: wannabeMagicValue 
    wannabeMagicValue = self magic 
    	ifFalse: [self error: 'invalid class magic value']
!

methods: methods
    self subclassResponsibility
!

minor: minorVersion major: majorVersion
    | version |
    version := majorVersion * 65536 + minorVersion.
    (version between: 45 * 65536 and: 46 * 65536) 
    	ifFalse: [self error: 'unsupported class version']
!

thisClass: aJavaClass
    self subclassResponsibility
! !

!JavaClassReader methodsFor: 'building-utility'!

class: aJavaClass methodNameAndType: nameAndType
    self subclassResponsibility
!

class: aJavaClass nameAndType: nameAndType
    self subclassResponsibility
!

classFromString: aString
    self subclassResponsibility
!

javaLangString: utf8 
    self subclassResponsibility
!

fieldFromFlags: flags name: name signature: signature attributes: attributes 
    self subclassResponsibility
!

methodFromFlags: flags name: name signature: signature attributes: attributes 
    self subclassResponsibility
!

name: aString type: aType
    self subclassResponsibility
!

nameString: nameString typeString: typeString
    ^self
        name: nameString asSymbol
        type: (self typeFromString: typeString)
! !

!JavaAttributeReader methodsFor: 'reading'!

rawBytes
    ^stream upToEnd
!

readFrom: aJavaClassReader
    | attributeName length |
    self classReader: aJavaClassReader.
    self constantPool: aJavaClassReader constantPool.
    attributeName  := self constantPool at: aJavaClassReader nextUshort.
    length := aJavaClassReader nextUint.
    stream := (aJavaClassReader nextBytes: length) readStream.
    ^(AttributeNames at: attributeName ifAbsent: [ JavaUnknownAttribute ])
        readFrom: self name: attributeName length: length
! !

!JavaAttributeReader methodsFor: 'accessing'!

classReader
    ^classReader
!

classReader: anObject
    classReader := anObject
! !

!JavaAttributeReader methodsFor: 'building-utility'!

typeFromString: aString
    ^self classReader typeFromString: aString
! !

!JavaAttributeReader class methodsFor: 'initialization'!

initialize
    "self initialize"
    AttributeNames := LookupTable new: 32.
    JavaAttribute allSubclasses do: [ :each |
    | attributeName |
    attributeName := each attributeName.
    attributeName isNil ifFalse: [ self registerAttribute: attributeName withClass: each ]]
!

registerAttribute: attrName withClass: class
    AttributeNames at: attrName put: class
! !

!JavaClassBuilder methodsFor: 'building the class'!

accessFlags: flags
    thisClass flags: flags
!

attributes: attributes
    thisClass attributes: attributes
!

extends: superclass
    thisClass extends: superclass
!

fields: fields
    thisClass fields: fields
!

implements: interfaces
    thisClass implements: interfaces
!

methods: methods
    thisClass methods: methods
! !

!JavaClassBuilder methodsFor: 'accessing'!

thisClass
    ^thisClass
!

thisClass: aJavaClass 
    thisClass := aJavaClass.
    thisClass constantPool: self constantPool
! !

!JavaClassBuilder methodsFor: 'building-utility'!

class: aJavaClass methodNameAndType: nameAndType
    ^JavaMethodRef
        javaClass: aJavaClass
        nameAndType: nameAndType
!

class: aJavaClass nameAndType: nameAndType
    ^JavaFieldRef
        javaClass: aJavaClass
        nameAndType: nameAndType
!

classFromString: aString
    ^aString first= $[
    	ifTrue: [ JavaArrayType fromString: aString ]
    	ifFalse: [ JavaClass fromString: aString ]
!

javaLangString: utf8 
    ^JavaVM bootstrapped
    	ifFalse: [JavaStringPrototype stringValue: utf8]
    	ifTrue: [utf8 asJavaString]
!

fieldFromFlags: flags name: name signature: signature attributes: attributes 
    ^(JavaField new)
    	flags: flags;
    	name: name;
    	signature: signature;
    	attributes: attributes;
    	yourself
!

methodFromFlags: flags name: name signature: signature attributes: attributes 
    ^(JavaMethod new)
    	flags: flags;
    	name: name;
    	signature: signature;
    	attributes: attributes;
    	yourself
!

name: aSymbol type: aType
    ^JavaNameAndType
        name: aSymbol
        type: aType
!

typeFromString: aString
    aString isNil ifTrue: [ ^nil ].
    ^JavaType fromString: aString
! !

!JavaClass class methodsFor: 'instance creation'!

loadFile: aString
    | stream |
    stream := FileStream open: aString mode: FileStream read.
    ^[ self readFrom: stream ] ensure: [ stream close ]
! !

!JavaClass methodsFor: 'loading'!

load
    self isLoaded ifTrue: [ ^self ].
    self class loadClass: self fullName.
    self extends isNil ifFalse: [ self extends load ].
! !

!JavaClass methodsFor: 'accessing'!

addAttribute: aJavaAttribute
    aJavaAttribute class == JavaSourceFileAttribute
    ifTrue:
    [self sourceFile: aJavaAttribute fileName.
    ^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
! !

!JavaClass class methodsFor: 'instance creation'!

loadClass: aString
    | file stream |
    file := JavaClassFileReader findClassFile: aString.
    file isNil ifTrue: [ self error: 'class not found: ', aString ].
    "Transcript show: 'Loading '; show: aString; nl."
    stream := file readStream.
    ^[ self readFrom: stream ] ensure: [ stream close ]
!

loadFile: aString
    | stream |
    stream := FileStream open: aString mode: FileStream read.
    ^[ self readFrom: stream ] ensure: [ stream close ]
!

readFrom: aStream
    | reader |
    "aStream binary; lineEndTransparent."   "VW requires these."
    reader := JavaClassBuilder on: aStream.
    reader readFile.
    ^reader thisClass
! !

JavaAttributeReader initialize!
