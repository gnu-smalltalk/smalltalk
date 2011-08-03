"======================================================================
|
|   ObjectDumper Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2006, 2008, 2009
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Stream subclass: ObjectDumper [
    | toObjects fromObjects stream |
    
    <category: 'Streams-Files'>
    <comment: 'I''m not part of a normal Smalltalk system, but most
Smalltalks provide a similar feature: that is, support for storing objects
in a binary format; there are many advantages in using me instead of #storeOn:
and the Smalltalk compiler.

The data is stored in a very compact format, which has the side effect of
making loading much faster when compared with compiling the Smalltalk code
prepared by #storeOn:.  In addition, my instances support circular references
between objects, while #storeOn: supports it only if you know of such
references at design time and you override #storeOn: to deal with them'>

    SpecialCaseDump := nil.
    SpecialCaseLoad := nil.
    Proxies := nil.

    ObjectDumper class >> example [
	"This is a real torture test: it outputs recursive objects,
	 identical objects multiple times, classes, metaclasses,
	 integers, characters and proxies (which is also a test of more
	 complex objects)!"

	<category: 'testing'>
	| file test dumper method |
	Transcript
	    nextPutAll: 'Must print true without errors.';
	    nl.
	file := FileStream open: 'dumptest' mode: FileStream write.
	test := Array new: 1.
	test at: 1 put: test.
	method := thisContext method.
	(ObjectDumper on: file)
	    dump: 'asdf';
	    dump: #('asdf' 1 2 $a);
	    dump: Array;
	    dump: 'asdf';
	    dump: Array class;
	    dump: test;
	    dump: Processor;
	    dump: Processor;
	    dump: method;
	    dump: method.	"String"	"Array"	"Class"	"String (must be identical to the first)"	"Metaclass"	"Circular reference"	"SingletonProxy"	"SingletonProxy"	"PluggableProxy"	"PluggableProxy"
	file close.
	file := FileStream open: 'dumptest' mode: FileStream read.
	dumper := ObjectDumper on: file.
	((test := dumper load) = 'asdf') printNl.
	(dumper load = #('asdf' 1 2 $a)) printNl.
	(dumper load == Array) printNl.
	(dumper load == test) printNl.
	(dumper load == Array class) printNl.
	test := dumper load.
	(test == (test at: 1)) printNl.
	(dumper load == Processor) printNl.
	(dumper load == Processor) printNl.
	(dumper load == method) printNl.
	(dumper load == method) printNl.
	file close
    ]

    ObjectDumper class >> hasProxyFor: aClass [
	"Answer whether a proxy class has been registered for instances
	 of aClass."

	<category: 'establishing proxy classes'>
	Proxies keysDo: 
		[:any | 
		(aClass inheritsFrom: any) ifTrue: [^true].
		aClass == any ifTrue: [^true]].
	^false
    ]

    ObjectDumper class >> disableProxyFor: aClass [
	"Disable proxies for instances of aClass and its descendants"

	<category: 'establishing proxy classes'>
	self registerProxyClass: NullProxy for: aClass
    ]

    ObjectDumper class >> registerProxyClass: aProxyClass for: aClass [
	"Register the proxy class aProxyClass - descendent of DumperProxy -
	 to be used for instances of aClass and its descendants"

	<category: 'establishing proxy classes'>
	(aProxyClass acceptUsageForClass: aClass) 
	    ifFalse: [self error: 'registration request denied'].
	Proxies at: aClass put: aProxyClass
    ]

    ObjectDumper class >> proxyFor: anObject [
	"Answer a valid proxy for an object, or the object itself if none could
	 be found"

	<category: 'establishing proxy classes'>
	Proxies 
	    keysAndValuesDo: [:key :value | (anObject isKindOf: key) ifTrue: [^value on: anObject]].
	^anObject
    ]

    ObjectDumper class >> proxyClassFor: anObject [
	"Answer the class of a valid proxy for an object, or nil if none could
	 be found"

	<category: 'establishing proxy classes'>
	Proxies 
	    keysAndValuesDo: [:key :value | (anObject isKindOf: key) ifTrue: [^value]].
	^nil
    ]

    ObjectDumper class >> specialCaseIf: aBlock dump: dumpBlock load: loadBlock [
	"Private - This method establishes a condition on which a particular
	 method must be used to save an object.
	 An application should not use this method, since it might cause
	 failure to load file that set the special-case blocks differently;
	 instead, you should use ObjectDumper's higher level proxy feature,
	 i.e. its #registerProxyClass:for: method - which builds on the
	 low-level feature enabled by this method but without its inherent
	 problems."

	<category: 'private - initialization'>
	SpecialCaseDump addLast: aBlock -> dumpBlock.
	SpecialCaseLoad addLast: loadBlock
    ]

    ObjectDumper class >> initialize [
	"Initialize the ObjectDumper class"

	<category: 'private - initialization'>
	Proxies := IdentityDictionary new.
	SpecialCaseDump := OrderedCollection new.
	SpecialCaseLoad := OrderedCollection new.

	"We can only use #isNil, #==, #class here"
	self
	    specialCaseIf: [:object | object == nil]
		dump: [:client :object | ]
		load: [:client | nil];
	    specialCaseIf: [:object | object == true]
		dump: [:client :object | ]
		load: [:client | true];
	    specialCaseIf: [:object | object == false]
		dump: [:client :object | ]
		load: [:client | false];
	    specialCaseIf: [:object | object class == SmallInteger]
		dump: [:client :object | client nextPutLong: object]
		load: [:client | client nextLong];
	    specialCaseIf: [:object | object class == Character]
		dump: [:client :object | client stream nextPut: object]
		load: [:client | client stream next];
	    specialCaseIf: [:object | object class class == Metaclass]
		dump: [:client :object | client storeGlobal: object]
		load: [:client | client loadGlobal];
	    specialCaseIf: [:object | object class == Metaclass]
		dump: [:client :object | client storeGlobal: object asClass]
		load: [:client | client loadGlobal class];
	    specialCaseIf: [:object | object == Smalltalk]
		dump: [:client :object | ]
		load: [:client | Smalltalk];
	    specialCaseIf: [:object | object class == Namespace]
		dump: [:client :object | client storeGlobal: object]
		load: [:client | client loadGlobal];
	    specialCaseIf: [:object | object class == RootNamespace]
		dump: [:client :object | client storeGlobal: object]
		load: [:client | client loadGlobal];
	    specialCaseIf: [:object | object class == Symbol]
		dump: 
		    [:client :object | 
		    client stream nextPutAll: object.
		    client nextPutByte: 0]
		load: [:client | client nextAsciiz asSymbol];
	    specialCaseIf: [:object | self hasProxyFor: object class]
		dump: 
		    [:client :object | 
		    | class |
		    (client lookup: object) 
			ifFalse: 
			    [client storeGlobal: (class := self proxyClassFor: object).
			    (class on: object) dumpTo: client.
			    client register: object]]
		load: 
		    [:client | 
		    "Special-case metaclasses and other objects"

		    | index |
		    index := client nextLong.
		    index = 0 
			ifTrue: [client register: (client loadGlobal loadFrom: client)]
			ifFalse: [client lookupIndex: index]];
	    specialCaseIf: [:object | object class == UnicodeCharacter]
		dump: [:client :object | client nextPutLong: object codePoint]
		load: [:client | client nextLong asCharacter]
    ]

    ObjectDumper class >> on: aFileStream [
	"Answer an ObjectDumper working on aFileStream."

	<category: 'instance creation'>
	^self basicNew initializeStream: aFileStream
    ]

    ObjectDumper class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    ObjectDumper class >> dump: anObject to: aFileStream [
	"Dump anObject to aFileStream. Answer anObject"

	<category: 'shortcuts'>
	^(self on: aFileStream) dump: anObject
    ]

    ObjectDumper class >> loadFrom: aFileStream [
	"Load an object from aFileStream and answer it"

	<category: 'shortcuts'>
	^(self on: aFileStream) load
    ]

    atEnd [
	"Answer whether the underlying stream is at EOF"

	<category: 'stream interface'>
	^stream atEnd
    ]

    next [
	"Load an object from the underlying stream"

	<category: 'stream interface'>
	^self load
    ]

    nextPut: anObject [
	"Store an object on the underlying stream"

	<category: 'stream interface'>
	self dump: anObject
    ]

    dump: anObject [
	"Dump anObject on the stream associated with the receiver. Answer
	 anObject"

	<category: 'loading/dumping objects'>
	(self lookup: anObject) ifTrue: [^anObject].
	(self specialCaseDump: anObject) 
	    ifFalse: 
		[anObject preStore.
		[self primDump: anObject] ensure: [anObject postStore]]
    ]

    load [
	"Load an object from the stream associated with the receiver and answer
	 it"

	<category: 'loading/dumping objects'>
	"Special-case metaclasses and other objects"

	| index class |
	stream atEnd ifTrue: [^self pastEnd].
	index := self nextLong.
	index < 0 ifTrue: [^self specialCaseLoad: index].
	index > 0 ifTrue: [^self lookupIndex: index].
	class := self loadClass.
	^self primLoad: class
    ]

    flush [
	"`Forget' any information on previously stored objects."

	<category: 'accessing'>
	toObjects := OrderedCollection new.
	fromObjects := IdentityDictionary new
    ]

    stream [
	"Answer the ByteStream to which the ObjectDumper will write
	 and from which it will read."

	<category: 'accessing'>
	^stream
    ]

    stream: aByteStream [
	"Set the ByteStream to which the ObjectDumper will write
	 and from which it will read."

	<category: 'accessing'>
	stream := aByteStream
    ]

    lookup: anObject [
	<category: 'private - handling maps'>
	| index |
	index := fromObjects at: anObject ifAbsent: [0].
	self nextPutLong: index.
	^index > 0
    ]

    lookupIndex: index [
	"Private - If index is a valid index into the toObjects map, evaluate
	 return the object associated to it.  Else, fail."

	<category: 'private - handling maps'>
	^toObjects at: index
    ]

    register: anObject [
	"Private - Register the anObject in the fromObjects and toObjects maps.
	 Assumes that anObject is absent in these maps. Answer anObject"

	"(fromObject includesKey: anObject) ifTrue: [
	 ^self error: 'Huh?!? Assertion failed' ]."

	<category: 'private - handling maps'>
	toObjects addLast: anObject.
	fromObjects at: anObject put: toObjects size.
	^anObject
    ]

    dumpContentsOf: anObject [
	"Dump anObject on the stream associated with the receiver. Answer
	 anObject"

	<category: 'private'>
	| index |
	(self lookup: anObject) ifTrue: [^anObject].
	anObject preStore.
	[self primDump: anObject] ensure: [anObject postStore].
	^self register: anObject
    ]

    initializeStream: aStream [
	"Private - Initialize the receiver's instance variables"

	<category: 'private'>
	stream := aStream.
	self flush.
	^self
    ]

    isClass: loadedClass [
	"Private - Answer whether loadedClass is really a class; only use
	 optimized selectors to avoid mess with objects that do not inherit
	 from Object."

	<category: 'private'>
	^loadedClass class class == Metaclass
    ]

    loadClass [
	"Private - Load the next object's class from stream"

	<category: 'private'>
	| isMeta loadedClass |
	isMeta := self nextByte = 0.
	loadedClass := self loadGlobal.
	(self isClass: loadedClass) ifFalse: [^self error: 'Bad class'].
	^isMeta ifTrue: [loadedClass class] ifFalse: [loadedClass]
    ]

    loadGlobal [
	"Private - Load a global object from the stream"

	<category: 'private'>
	| object space index |
	index := self nextLong.
	index > 0 ifTrue: [^self lookupIndex: index].
	space := self load.
	space isNil ifTrue: [space := Smalltalk].
	object := space at: self nextAsciiz asGlobalKey
		    ifAbsent: [^self error: 'Unknown global referenced'].
	^self register: object
    ]

    load: anObject through: aBlock [
	"Private - Fill anObject's indexed instance variables from the stream.
	 To get a variable, evaluate aBlock. Answer anObject"

	<category: 'private'>
	1 to: anObject basicSize do: [:i | anObject basicAt: i put: aBlock value].
	^anObject
	    postLoad;
	    yourself
    ]

    loadFixedPart: class [
	"Private - Load the fixed instance variables of a new instance of class"

	<category: 'private'>
	| object |
	object := class isVariable 
		    ifTrue: [class basicNew: self nextLong]
		    ifFalse: [class basicNew].
	self register: object.
	1 to: class instSize do: [:i | object instVarAt: i put: self load].
	^object
    ]

    nextAsciiz [
	"Private - Get a Null-terminated string from stream and answer it"

	<category: 'private'>
	| ch answer |
	answer := WriteStream on: (String new: 30).	"Hopefully large enough"
	
	[ch := stream next.
	ch asciiValue = 0] whileFalse: [answer nextPut: ch].
	^answer contents
    ]

    primDump: anObject [
	"Private - Basic code to dump anObject on the stream associated with the
	 receiver, without using proxies and the like."

	<category: 'private'>
	| class shape |
	self storeClass: (class := anObject class).
	self register: anObject.
	class isVariable ifTrue: [self nextPutLong: anObject basicSize].
	1 to: class instSize do: [:i | self dump: (anObject instVarAt: i)].
	class isVariable ifFalse: [^self].
	class isPointers 
	    ifTrue: [^self store: anObject through: [:obj | self dump: obj]].
	shape := class shape.
	shape == #character 
	    ifTrue: [^self store: anObject through: [:char | stream nextPut: char]].
	(shape == #byte or: [shape == #int8]) 
	    ifTrue: [^self store: anObject through: [:byte | self nextPutByte: byte]].
	(shape == #short or: [shape == #ushort]) 
	    ifTrue: [^self store: anObject through: [:short | self nextPutShort: short]].
	(shape == #int or: [shape == #int]) 
	    ifTrue: [^self store: anObject through: [:int | self nextPutLong: int]].
	(shape == #int64 or: [shape == #uint64]) 
	    ifTrue: [^self store: anObject through: [:int64 | self nextPutInt64: int64]].
	shape == #utf32 
	    ifTrue: 
		[^self store: anObject through: [:char | self nextPutLong: char codePoint]].
	shape == #float 
	    ifTrue: [^self store: anObject through: [:float | self nextPutFloat: float]].
	shape == #double 
	    ifTrue: 
		[^self store: anObject through: [:double | self nextPutFloat: double]].
	self notYetImplemented
    ]

    loadFromVersion: version fixedSize: instSize index: index [
	"Private - Basic code to load an object from a stream associated with
	 the receiver, calling the class'
	 #convertFromVersion:withFixedVariables:instanceVariables:for: method.
	 version will be the first parameter to that method, while instSize
	 will be the size of the second parameter.  The object returned by
	 that method is registered and returned."

	<category: 'private'>
	| object class realSize size fixed indexed placeholder shape |
	index > 0 ifTrue: [^self lookupIndex: index].
	class := self loadClass.
        version == class binaryRepresentationVersion ifTrue: [ ^ self primLoad: class ].
	self register: (placeholder := Object new).
	class isVariable ifTrue: [size := self nextUlong].
	realSize := instSize isNil 
		    ifTrue: [class nonVersionedInstSize]
		    ifFalse: [instSize].
	fixed := (1 to: realSize) collect: [:i | self load].
	class isVariable 
	    ifTrue: 
		[class isPointers 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self load]].
		shape := class shape.
		shape == #character 
		    ifTrue: [indexed := (1 to: size) collect: [:i | Character value: self nextByte]].
		(shape == #byte and: [indexed isNil]) 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextByte]].
		shape == #int8 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextSignByte]].
		shape == #short 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextShort]].
		shape == #ushort 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextUshort]].
		shape == #int 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextLong]].
		shape == #uint 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextUlong]].
		shape == #int64 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextInt64]].
		shape == #uint64 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextUint64]].
		shape == #utf32 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextLong asCharacter]].
		shape == #float 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextFloat]].
		shape == #double 
		    ifTrue: [indexed := (1 to: size) collect: [:i | self nextDouble]].
		indexed isNil ifTrue: [self shouldNotImplement]].
	placeholder become: (class 
		    convertFromVersion: version
		    withFixedVariables: fixed
		    indexedVariables: indexed
		    for: self).
	^placeholder
    ]

    primLoad: class [
	"Private - Basic code to load an object from the stream associated with the
	 receiver, assuming it doesn't use proxies and the like.  The class of the
	 loaded object is in index"

	<category: 'private'>
	| object shape |
	class isMetaclass ifTrue: [^class instanceClass].
	object := self loadFixedPart: class.
	class isVariable ifFalse: [^object postLoad; yourself].
	class isPointers ifTrue: [^self load: object through: [self load]].
	shape := class shape.
	shape == #character ifTrue: [^self load: object through: [Character value: self nextByte]].
	shape == #byte ifTrue: [^self load: object through: [self nextByte]].
	shape == #int8 ifTrue: [^self load: object through: [self nextSignByte]].
	shape == #short ifTrue: [^self load: object through: [self nextShort]].
	shape == #ushort ifTrue: [^self load: object through: [self nextUshort]].
	shape == #int ifTrue: [^self load: object through: [self nextLong]].
	shape == #uint ifTrue: [^self load: object through: [self nextUlong]].
	shape == #int64 ifTrue: [^self load: object through: [self nextInt64]].
	shape == #uint64 ifTrue: [^self load: object through: [self nextUint64]].
	shape == #utf32 
	    ifTrue: [^self load: object through: [self nextLong asCharacter]].
	shape == #float ifTrue: [^self load: object through: [self nextFloat]].
	shape == #double ifTrue: [^self load: object through: [self nextDouble]].
	self shouldNotImplement
    ]

    specialCaseDump: anObject [
	"Private - Store special-cased objects. These include booleans, integers,
	 nils, characters, classes and Processor. Answer true if object belongs
	 to one of these categories, else do nothing and answer false"

	<category: 'private'>
	SpecialCaseDump keysAndValuesDo: 
		[:index :each | 
		(each key value: anObject) 
		    ifTrue: 
			[stream skip: -4.
			self nextPutLong: index negated.
			each value value: self value: anObject.
			self register: anObject.
			^true]].
	^false
    ]

    specialCaseLoad: index [
	"Private - The first 4 bytes in the file were less than 0.
	 Load the remaining info about the object and answer it."

	<category: 'private'>
	| object |
	index > SpecialCaseLoad size ifTrue: [^self error: 'error in file'].
	object := (SpecialCaseLoad at: index negated) value: self.
	^self register: object
    ]

    storeClass: aClass [
	"Private - Store the aClass class in stream. The format is:
	 - for a metaclass, a 0 followed by the asciiz name of its instance
	 - for a class, a 1 followed by its asciiz name"

	"We don't register metaclasses; instead we register their instance
	 (the class) and use a byte to distinguish between the two cases."

	<category: 'private'>
	aClass isMetaclass 
	    ifTrue: [self nextPutByte: 0]
	    ifFalse: [self nextPutByte: 1].
	self storeGlobal: aClass asClass
    ]

    storeGlobal: anObject [
	<category: 'private'>
	| namespace |
	(self lookup: anObject) ifTrue: [^anObject].
	(anObject respondsTo: #environment) 
	    ifTrue: [namespace := anObject environment]
	    ifFalse: 
		[(anObject respondsTo: #superspace) 
		    ifTrue: [namespace := anObject superspace]
		    ifFalse: [namespace := nil	"read as `Smalltalk' upon load."]].
	self
	    dump: namespace;
	    register: anObject.
	stream nextPutAll: anObject name.
	self nextPutByte: 0
    ]

    store: anObject through: aBlock [
	"Private - Store anObject's indexed instance variables into the stream.
	 To store a variable, pass its value to aBlock."

	<category: 'private'>
	1 to: anObject basicSize do: [:i | aBlock value: (anObject basicAt: i)].
	^anObject
    ]

    nextByte [
	"Return the next byte in the byte array"

	<category: 'private - binary I/O'>
	^stream next asInteger
    ]

    nextByteArray: numBytes [
	"Return the next numBytes bytes in the byte array"

	<category: 'private - binary I/O'>
	^(stream next: numBytes) asByteArray
    ]

    nextSignedByte [
	"Return the next byte in the byte array, interpreted as a 8 bit signed number"

	<category: 'private - binary I/O'>
	^self nextBytes: 1 signed: true
    ]

    nextDouble [
	"Return the next 64-bit float in the byte array"

	<category: 'private - binary I/O'>
	^(FloatD new: 8)
	    at: 1 put: self nextByte;
	    at: 2 put: self nextByte;
	    at: 3 put: self nextByte;
	    at: 4 put: self nextByte;
	    at: 5 put: self nextByte;
	    at: 6 put: self nextByte;
	    at: 7 put: self nextByte;
	    at: 8 put: self nextByte
    ]

    nextFloat [
	"Return the next 32-bit float in the byte array"

	<category: 'private - binary I/O'>
	^(FloatE new: 4)
	    at: 1 put: self nextByte;
	    at: 2 put: self nextByte;
	    at: 3 put: self nextByte;
	    at: 4 put: self nextByte
    ]

    nextUint64 [
	"Return the next 8 bytes in the byte array, interpreted as a 64 bit unsigned int"

	<category: 'private - binary I/O'>
	^self nextBytes: 8 signed: false
    ]

    nextLongLong [
	"Return the next 8 bytes in the byte array, interpreted as a 64 bit signed int"

	<category: 'private - binary I/O'>
	^self nextBytes: 8 signed: true
    ]

    nextUlong [
	"Return the next 4 bytes in the byte array, interpreted as a 32 bit unsigned int"

	<category: 'private - binary I/O'>
	^self nextBytes: 4 signed: false
    ]

    nextLong [
	"Return the next 4 bytes in the byte array, interpreted as a 32 bit signed int"

	<category: 'private - binary I/O'>
	^self nextBytes: 4 signed: true
    ]

    nextUshort [
	"Return the next 2 bytes in the byte array, interpreted as a 16 bit unsigned int"

	<category: 'private - binary I/O'>
	^self nextBytes: 2 signed: false
    ]

    nextShort [
	"Return the next 2 bytes in the byte array, interpreted as a 16 bit signed int"

	<category: 'private - binary I/O'>
	^self nextBytes: 2 signed: true
    ]

    nextPutDouble: aDouble [
	"Store aDouble as a 64-bit float in the byte array"

	<category: 'private - binary I/O'>
	| d |
	d := aDouble asFloatD.
	self nextPutByte: (d at: 1).
	self nextPutByte: (d at: 2).
	self nextPutByte: (d at: 3).
	self nextPutByte: (d at: 4).
	self nextPutByte: (d at: 5).
	self nextPutByte: (d at: 6).
	self nextPutByte: (d at: 7).
	self nextPutByte: (d at: 8)
    ]

    nextPutFloat: aFloat [
	"Return the next 32-bit float in the byte array"

	<category: 'private - binary I/O'>
	| f |
	f := aFloat asFloatE.
	self nextPutByte: (f at: 1).
	self nextPutByte: (f at: 2).
	self nextPutByte: (f at: 3).
	self nextPutByte: (f at: 4)
    ]

    nextPutByte: anInteger [
	"Store anInteger (range: -128..255) on the byte array"

	<category: 'private - binary I/O'>
	| int |
	int := anInteger < 0 
		    ifTrue: [256 + anInteger]
		    ifFalse: [anInteger].
	^stream nextPut: (Character value: int)
    ]

    nextPutByteArray: aByteArray [
	"Store aByteArray on the byte array"

	<category: 'private - binary I/O'>
	^self nextPutAll: aByteArray
    ]

    nextPutInt64: anInteger [
	"Store anInteger (range: -2^63..2^64-1) on the byte array as 4 bytes"

	<category: 'private - binary I/O'>
	self nextPutBytes: 8 of: anInteger
    ]

    nextPutLong: anInteger [
	"Store anInteger (range: -2^31..2^32-1) on the byte array as 4 bytes"

	<category: 'private - binary I/O'>
	self nextPutBytes: 4 of: anInteger
    ]

    nextPutShort: anInteger [
	"Store anInteger (range: -32768..65535) on the byte array as 2 bytes"

	<category: 'private - binary I/O'>
	self nextPutBytes: 2 of: anInteger
    ]

    nextBytes: n signed: signed [
	"Private - Get an integer out of the next anInteger bytes in the stream"

	<category: 'private'>
	| int msb |
	int := 0.
	0 to: n * 8 - 16
	    by: 8
	    do: [:i | int := int + (self nextByte bitShift: i)].
	msb := self nextByte.
	(signed and: [msb > 127]) ifTrue: [msb := msb - 256].
	^int + (msb bitShift: n * 8 - 8)
    ]

    nextPutBytes: n of: anInteger [
	"Private - Store the n least significant bytes of int in little-endian format"

	<category: 'private'>
	| int |
	int := anInteger.
	n timesRepeat: 
		[self nextPutByte: (int bitAnd: 255).
		int := int bitShift: -8.
		(int = 0 and: [anInteger < 0]) ifTrue: [int := 255]]
    ]

]

