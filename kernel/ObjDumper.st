"======================================================================
|
|   ObjectDumper Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2006 Free Software Foundation, Inc.
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


Stream subclass: #ObjectDumper
    instanceVariableNames: 'toObjects fromObjects stream'
    classVariableNames: 'SpecialCaseDump SpecialCaseLoad Proxies'
    poolDictionaries: ''
    category: 'Streams-Files'!

Object subclass: #DumperProxy
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Streams-Files'!

DumperProxy subclass: #AlternativeObjectProxy
    instanceVariableNames: 'object'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Streams-Files'!

AlternativeObjectProxy subclass: #NullProxy
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Streams-Files'!

AlternativeObjectProxy subclass: #PluggableProxy
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Streams-Files'!

NullProxy subclass: #VersionableObjectProxy
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Streams-Files'!

AlternativeObjectProxy subclass: #SingletonProxy
    instanceVariableNames: ''
    classVariableNames: 'Singletons'
    poolDictionaries: ''
    category: 'Streams-Files'!

ObjectDumper comment: 'I''m not part of a normal Smalltalk system, but most
Smalltalks provide a similar feature: that is, support for storing objects
in a binary format; there are many advantages in using me instead of #storeOn:
and the Smalltalk compiler.

The data is stored in a very compact format, which has the side effect of
making loading much faster when compared with compiling the Smalltalk code
prepared by #storeOn:.  In addition, my instances support circular references
between objects, while #storeOn: supports it only if you know of such
references at design time and you override #storeOn: to deal with them'.

DumperProxy comment: 'I am an helper class for ObjectDumper. When an
object cannot be saved in the standard way, you can register a subclass of me
to provide special means to save that object.'.

AlternativeObjectProxy comment: 'I am a proxy that uses the same ObjectDumper
to store an object which is not the object to be dumped, but from which the
dumped object can be reconstructed.  I am an abstract class, using me would
result in infinite loops because by default I try to store the same object
again and again.  See the method comments for more information'.

NullProxy comment: 'I am a proxy that does no special processing on the object
to be saved. I can be used to disable proxies for particular subclasses.  My
subclasses add to the stored information, but share the fact that the format
is about the same as that of #dump: without a proxy.'.

PluggableProxy comment: 'I am a proxy that stores a different object
and, upon load, sends #reconstructOriginalObject to that object (which
can be a DirectedMessage, in which case the message is sent).  The
object to be stored is retrieved by sending #binaryRepresentationObject to
the object.'.

VersionableObjectProxy comment: 'I am a proxy that stores additional
information to allow different versions of an object''s representations
to be handled by the program.  VersionableObjectProxies are backwards
compatible, that is you can support versioning even if you did not use
a VersionableObjectProxy for that class when the object was originarily
dumped.  VersionableObjectProxy does not support classes that changed
shape across different versions.  See the method comments for more
information.'.

SingletonProxy comment: 'I am a proxy that stores the class of an
object rather than the object itself, and pretends that a registered
instance (which most likely is a singleton instance of the stored class)
was stored instead.'!


!ObjectDumper class methodsFor: 'testing'!

example
    "This is a real torture test: it outputs recursive objects,
     identical objects multiple times, classes, metaclasses,
     integers, characters and proxies (which is also a test of more
     complex objects)!"

    | file test dumper method |
    Transcript nextPutAll: 'Must print true without errors.'; nl.
    file := FileStream open: 'dumptest' mode: FileStream write.
    test := Array new: 1. test at: 1 put: test.
    method := thisContext method.

    (ObjectDumper on: file)
	dump: 'asdf';		"String"
	dump: #('asdf' 1 2 $a);	"Array"
	dump: Array;		"Class"
	dump: 'asdf';		"String (must be identical to the first)"
	dump: Array class;	"Metaclass"
	dump: test;		"Circular reference"
	dump: Processor;	"SingletonProxy"
	dump: Processor;	"SingletonProxy"
	dump: method;		"PluggableProxy"
	dump: method.		"PluggableProxy"
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
! !


!ObjectDumper class methodsFor: 'establishing proxy classes'!

hasProxyFor: aClass
    "Answer whether a proxy class has been registered for instances
     of aClass."
    Proxies keysDo: [ :any |
	(aClass inheritsFrom: any) ifTrue: [ ^true ].
	aClass == any ifTrue: [ ^true ]
    ].
    ^false
!

disableProxyFor: aClass
    "Disable proxies for instances of aClass and its descendants"
    self registerProxyClass: NullProxy for: aClass
!

registerProxyClass: aProxyClass for: aClass
    "Register the proxy class aProxyClass - descendent of DumperProxy -
     to be used for instances of aClass and its descendants"
    (aProxyClass acceptUsageForClass: aClass)
	ifFalse: [ self error: 'registration request denied' ].

    Proxies at: aClass put: aProxyClass
!

proxyFor: anObject
    "Answer a valid proxy for an object, or the object itself if none could
     be found"
    Proxies keysAndValuesDo: [ :key :value |
	(anObject isKindOf: key) ifTrue: [ ^value on: anObject ]
    ].
    ^anObject
!

proxyClassFor: anObject
    "Answer the class of a valid proxy for an object, or nil if none could
     be found"
    Proxies keysAndValuesDo: [ :key :value |
	(anObject isKindOf: key) ifTrue: [ ^value ]
    ].
    ^nil
! !


!ObjectDumper class methodsFor: 'private - initialization'!

specialCaseIf: aBlock dump: dumpBlock load: loadBlock
    "Private - This method establishes a condition on which a particular
     method must be used to save an object.
     An application should not use this method, since it might cause
     failure to load file that set the special-case blocks differently;
     instead, you should use ObjectDumper's higher level proxy feature,
     i.e. its #registerProxyClass:for: method - which builds on the
     low-level feature enabled by this method but without its inherent
     problems."

    SpecialCaseDump addLast: aBlock -> dumpBlock.
    SpecialCaseLoad addLast: loadBlock
!

initialize
    "Initialize the ObjectDumper class"
    Proxies := IdentityDictionary new.
    SpecialCaseDump := OrderedCollection new.
    SpecialCaseLoad := OrderedCollection new.

    "We can only use #isNil, #==, #class here"
    self
	specialCaseIf: [ :object | object == nil ]
	dump: [ :client :object | ]
	load: [ :client | nil ];

	specialCaseIf: [ :object | object == true ]
	dump: [ :client :object | ]
	load: [ :client | true ];

	specialCaseIf: [ :object | object == false ]
	dump: [ :client :object | ]
	load: [ :client | false ];

	specialCaseIf: [ :object | object class == SmallInteger ]
	dump: [ :client :object | client stream nextPutLong: object ]
	load: [ :client | client stream nextLong ];

	specialCaseIf: [ :object | object class == Character ]
	dump: [ :client :object | client stream nextPut: object ]
	load: [ :client | client stream next ];

	specialCaseIf: [ :object | object class class == Metaclass ]
	dump: [ :client :object | client storeGlobal: object ]
	load: [ :client | client loadGlobal ];

	specialCaseIf: [ :object | object class == Metaclass ]
	dump: [ :client :object | client storeGlobal: object asClass ]
	load: [ :client | client loadGlobal class ];

	specialCaseIf: [ :object | object == Smalltalk ]
	dump: [ :client :object | ]
	load: [ :client | Smalltalk ];

	specialCaseIf: [ :object | object class == Namespace ]
	dump: [ :client :object | client storeGlobal: object ]
	load: [ :client | client loadGlobal ];

	specialCaseIf: [ :object | object class == RootNamespace ]
	dump: [ :client :object | client storeGlobal: object ]
	load: [ :client | client loadGlobal ];

	specialCaseIf: [ :object | object class == Symbol ]
	dump: [ :client :object | client stream nextPutAll: object; nextPutByte: 0 ]
	load: [ :client | client nextAsciiz asSymbol ];

	specialCaseIf: [ :object | self hasProxyFor: object class ]
	dump: [ :client :object || class |
	    (client lookup: object) ifFalse: [
		client storeGlobal: (class := self proxyClassFor: object).
		(class on: object) dumpTo: client.
		client register: object
	    ]
	]
	load: [ :client || index |

	    "Special-case metaclasses and other objects"
	    index := client stream nextLong.
	    index = 0
		ifTrue: [ client register: (client loadGlobal loadFrom: client) ]
		ifFalse: [ client lookupIndex: index ]
	];

	specialCaseIf: [ :object | object class == UnicodeCharacter ]
	dump: [ :client :object | client stream nextPutLong: object codePoint ]
	load: [ :client | client stream nextLong asCharacter ]
! !


!ObjectDumper class methodsFor: 'instance creation'!

on: aFileStream
    "Answer an ObjectDumper working on aFileStream."

    ^self basicNew initializeStream: aFileStream
!

new
    self shouldNotImplement
! !


!ObjectDumper class methodsFor: 'shortcuts'!

dump: anObject to: aFileStream
    "Dump anObject to aFileStream. Answer anObject"

    ^(self on: aFileStream) dump: anObject
!

loadFrom: aFileStream
    "Load an object from aFileStream and answer it"

    ^(self on: aFileStream) load
! !


!ObjectDumper methodsFor: 'stream interface'!

atEnd
    "Answer whether the underlying stream is at EOF"
    ^stream atEnd
!

next
    "Load an object from the underlying stream"
    ^self load
!

nextPut: anObject
    "Store an object on the underlying stream"
    self dump: anObject
! !


!ObjectDumper methodsFor: 'loading/dumping objects'!

dump: anObject
    "Dump anObject on the stream associated with the receiver. Answer
     anObject"

    (self lookup: anObject) ifTrue: [ ^anObject ].
    (self specialCaseDump: anObject) ifFalse: [
	anObject preStore.
	[ self primDump: anObject ] ensure: [ anObject postStore ]
    ].
!

load
    "Load an object from the stream associated with the receiver and answer
     it"

    | index |

    "Special-case metaclasses and other objects"
    index := stream nextLong.
    ^index < 0
	ifTrue: [ self specialCaseLoad: index ]
	ifFalse: [ self primLoad: index ]
! !


!ObjectDumper methodsFor: 'accessing'!

flush
    "`Forget' any information on previously stored objects."
    toObjects := OrderedCollection new.
    fromObjects := IdentityDictionary new.
!

stream
    "Answer the ByteStream to which the ObjectDumper will write
     and from which it will read."
    ^stream
!

stream: aByteStream
    "Set the ByteStream to which the ObjectDumper will write
     and from which it will read."
    stream := aByteStream
! !


!ObjectDumper methodsFor: 'private - handling maps'!

lookup: anObject
    | index |
    index := fromObjects at: anObject ifAbsent: [ 0 ].
    stream nextPutLong: index.
    ^index > 0!

lookupIndex: index
    "Private - If index is a valid index into the toObjects map, evaluate
     return the object associated to it.  Else, fail."

    ^toObjects at: index
!

register: anObject
    "Private - Register the anObject in the fromObjects and toObjects maps.
     Assumes that anObject is absent in these maps. Answer anObject"

    "(fromObject includesKey: anObject) ifTrue: [
	^self error: 'Huh?!? Assertion failed' ].   "

    toObjects addLast: anObject.
    fromObjects at: anObject put: toObjects size.
    ^anObject
! !


!ObjectDumper methodsFor: 'private'!

dumpContentsOf: anObject
    "Dump anObject on the stream associated with the receiver. Answer
     anObject"

    | index |
    (self lookup: anObject) ifTrue: [ ^anObject ].

    anObject preStore.
    [ self primDump: anObject ] ensure: [ anObject postStore ].
    ^self register: anObject
!

initializeStream: aStream
    "Private - Initialize the receiver's instance variables"

    stream := aStream.
    self flush.
    ^self
!

isClass: loadedClass
    "Private - Answer whether loadedClass is really a class; only use
    optimized selectors to avoid mess with objects that do not inherit
    from Object."

    ^loadedClass class class == Metaclass
!

loadClass
    "Private - Load the next object's class from stream"

    | isMeta loadedClass |

    isMeta := stream nextByte = 0.
    loadedClass := self loadGlobal.
    (self isClass: loadedClass) ifFalse: [ ^self error: 'Bad class'. ].
    ^isMeta 
	ifTrue: [ loadedClass class ]
	ifFalse: [ loadedClass ]
!

loadGlobal
    "Private - Load a global object from the stream"

    | object space index |
    index := stream nextLong.
    index > 0 ifTrue: [ ^self lookupIndex: index ].

    space := self load.
    space isNil ifTrue: [ space := Smalltalk ].

    object := space
	at: self nextAsciiz asGlobalKey
	ifAbsent: [ ^self error: 'Unknown global referenced' ].

    ^self register: object
!

load: anObject through: aBlock
    "Private - Fill anObject's indexed instance variables from the stream.
     To get a variable, evaluate aBlock. Answer anObject"

    1 to: anObject basicSize do: [ :i |
	anObject
	    basicAt: i
	    put: aBlock value
    ].
    ^anObject postLoad; yourself
!

loadFixedPart: class
    "Private - Load the fixed instance variables of a new instance of class"

    | object |
    object := class isVariable
	ifTrue: [ class basicNew: stream nextLong ]
	ifFalse: [ class basicNew ].

    self register: object.

    1 to: class instSize do: [ :i |
	object instVarAt: i put: self load
    ].
    ^object
!

nextAsciiz
    "Private - Get a Null-terminated string from stream and answer it"

    | ch answer |
    answer := WriteStream on: (String new: 30). "Hopefully large enough"

    [
	ch := stream next. ch asciiValue = 0 ] whileFalse: [
	answer nextPut: ch
    ].
    ^answer contents
!

primDump: anObject
    "Private - Basic code to dump anObject on the stream associated with the
     receiver, without using proxies and the like."

    | class shape |
    self storeClass: (class := anObject class).
    self register: anObject.

    class isVariable ifTrue: [ stream nextPutLong: anObject basicSize ].

    1 to: class instSize do: [ :i |
	self dump: (anObject instVarAt: i)
    ].

    class isVariable ifFalse: [ ^self ].
    class isPointers
	ifTrue: [ ^self store: anObject through: [ :obj | self dump: obj ] ].

    shape := class shape.
    shape == #character
	ifTrue: [ ^self store: anObject through: [ :char | stream nextPut: char ] ].

    (shape == #byte or: [ shape == #int8 ])
	ifTrue: [ ^self store: anObject through: [ :byte | stream nextPutByte: byte ] ].

    (shape == #short or: [ shape == #ushort ])
	ifTrue: [ ^self store: anObject through: [ :short | stream nextPutShort: short ] ].

    (shape == #int or: [ shape == #int ])
	ifTrue: [ ^self store: anObject through: [ :int | stream nextPutLong: int ] ].

    (shape == #int64 or: [ shape == #uint64 ])
	ifTrue: [ ^self store: anObject through: [ :int64 | stream nextPutInt64: int64 ] ].

    shape == #utf32
	ifTrue: [ ^self store: anObject through: [ :char | stream nextPutLong: char codePoint ] ].

    shape == #float
	ifTrue: [ ^self store: anObject through: [ :float | stream nextPutFloat: float ] ].

    shape == #double
	ifTrue: [ ^self store: anObject through: [ :double | stream nextPutFloat: double ] ].

    self notYetImplemented
!

loadFromVersion: version fixedSize: instSize
    "Private - Basic code to load an object from a stream associated with
     the receiver, calling the class'
     #convertFromVersion:withFixedVariables:instanceVariables:for: method.
     version will be the first parameter to that method, while instSize
     will be the size of the second parameter.  The object returned by
     that method is registered and returned."

    | object class realSize size fixed indexed placeholder index shape |
    index := stream nextLong.
    index > 0 ifTrue: [ ^self lookupIndex: index ].

    self register: (placeholder := Object new).
    class := self loadClass.
    class isVariable ifTrue: [ size := stream nextUlong ].

    realSize := instSize isNil
	ifTrue: [ class nonVersionedInstSize ]
	ifFalse: [ instSize ].

    (1 to: realSize) collect: [ :i | self load ].

    class isVariable ifTrue: [
	class isPointers
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | self load ] ].

	shape := class shape.
	shape == #character
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream next ] ].

	(shape == #byte and: [ indexed isNil ])
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextByte ] ].

        shape == #int8
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextSignByte ] ].

        shape == #short
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextShort ] ].

        shape == #ushort
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextUshort ] ].

        shape == #int
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextLong ] ].

        shape == #uint
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextUlong ] ].

        shape == #int64
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextInt64 ] ].

        shape == #uint64
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextUint64 ] ].

	shape == #utf32
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextLong asCharacter ] ].

        shape == #float
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextFloat ] ].

        shape == #double
	    ifTrue: [ indexed := (1 to: size) collect: [ :i | stream nextDouble ] ].

	indexed isNil ifTrue: [ self shouldNotImplement ]
    ].

    placeholder become: (class
	convertFromVersion: version
	withFixedVariables: fixed
	indexedVariables: indexed
	for: self).

    ^placeholder!

primLoad: index
    "Private - Basic code to load an object from the stream associated with the
     receiver, assuming it doesn't use proxies and the like.  The first four
     bytes of the encoding are in index"

    | object class shape |
    index > 0 ifTrue: [ ^self lookupIndex: index ].

    class := self loadClass.
    class isMetaclass ifTrue: [ ^class instanceClass ].

    object := self loadFixedPart: class.

    class isVariable ifFalse: [ ^object ].

    class isPointers
	ifTrue: [ ^self load: object through: [ self load ] ].

    shape := class shape.
    shape == #character
	ifTrue: [ ^self load: object through: [ stream next ] ].

    shape == #byte
	ifTrue: [ ^self load: object through: [ stream nextByte ] ].

    shape == #int8
	ifTrue: [ ^self load: object through: [ stream nextSignByte ] ].

    shape == #short
	ifTrue: [ ^self load: object through: [ stream nextShort ] ].

    shape == #ushort
	ifTrue: [ ^self load: object through: [ stream nextUshort ] ].

    shape == #int
	ifTrue: [ ^self load: object through: [ stream nextLong ] ].

    shape == #uint
	ifTrue: [ ^self load: object through: [ stream nextUlong ] ].

    shape == #int64
	ifTrue: [ ^self load: object through: [ stream nextInt64 ] ].

    shape == #uint64
	ifTrue: [ ^self load: object through: [ stream nextUint64 ] ].

    shape == #utf32
	ifTrue: [ ^self load: object through: [ stream nextLong asCharacter ] ].

    shape == #float
	ifTrue: [ ^self load: object through: [ stream nextFloat ] ].

    shape == #double
	ifTrue: [ ^self load: object through: [ stream nextDouble ] ].

    self shouldNotImplement 
!

specialCaseDump: anObject
    "Private - Store special-cased objects. These include booleans, integers,
     nils, characters, classes and Processor. Answer true if object belongs
     to one of these categories, else do nothing and answer false"

    SpecialCaseDump keysAndValuesDo: [ :index :each |
	((each key) value: anObject) ifTrue: [
	    stream skip: -4; nextPutLong: index negated.
	    (each value) value: self value: anObject.
	    self register: anObject.
	    ^true
	]
    ].
    ^false
!

specialCaseLoad: index

    "Private - The first 4 bytes in the file were less than 0.
     Load the remaining info about the object and answer it."

    | object |
    index > SpecialCaseLoad size ifTrue: [ ^self error: 'error in file' ].

    object := (SpecialCaseLoad at: index negated) value: self.
    ^self register: object
!

storeClass: aClass
    "Private - Store the aClass class in stream. The format is:
	- for a metaclass, a 0 followed by the asciiz name of its instance
	- for a class, a 1 followed by its asciiz name"

    "We don't register metaclasses; instead we register their instance
     (the class) and use a byte to distinguish between the two cases."

    aClass isMetaclass
	ifTrue: [ stream nextPutByte: 0 ]
	ifFalse: [ stream nextPutByte: 1 ].

    self storeGlobal: aClass asClass
!

storeGlobal: anObject
    | namespace |
    (self lookup: anObject) ifTrue: [ ^anObject ].

    (anObject respondsTo: #environment)
	ifTrue: [ namespace := anObject environment ]

	ifFalse: [
	    (anObject respondsTo: #superspace)
		ifTrue: [ namespace := anObject superspace ]
		ifFalse: [ namespace := nil "read as `Smalltalk' upon load." ]
	].

    self
	dump: namespace;
	register: anObject.

    stream
	nextPutAll: anObject name;
	nextPutByte: 0
!

store: anObject through: aBlock
    "Private - Store anObject's indexed instance variables into the stream.
     To store a variable, pass its value to aBlock."

    1 to: anObject basicSize do: [ :i |
	aBlock value: (anObject basicAt: i)
    ].
    ^anObject
! !


!DumperProxy class methodsFor: 'accessing'!

loadFrom: anObjectDumper
    "Reload a proxy stored in anObjectDumper and reconstruct the object"
    ^anObjectDumper load object
!

acceptUsageForClass: aClass
    "The receiver was asked to be used as a proxy for the class aClass.
     Answer whether the registration is fine.  By default, answer true"
    ^true
! !

!DumperProxy class methodsFor: 'instance creation'!

on: anObject
    "Answer a proxy to be used to save anObject. This method
    MUST be overridden and anObject must NOT be stored in the
    object's instance variables unless you override #dumpTo:,
    because that would result in an infinite loop!"
    self subclassResponsibility
! !

!DumperProxy methodsFor: 'saving and restoring'!

dumpTo: anObjectDumper
    "Dump the proxy to anObjectDumper -- the #loadFrom: class method
     will reconstruct the original object."
    
    anObjectDumper dump: self
!

object
    "Reconstruct the object stored in the proxy and answer it"
    self subclassResponsibility
! !


!AlternativeObjectProxy class methodsFor: 'instance creation'!

acceptUsageForClass: aClass
    "The receiver was asked to be used as a proxy for the class aClass.
     Answer whether the registration is fine.  By default, answer true
     except if AlternativeObjectProxy itself is being used."
    ^self ~~ AlternativeObjectProxy
! !

!AlternativeObjectProxy class methodsFor: 'instance creation'!

on: anObject
    "Answer a proxy to be used to save anObject. IMPORTANT: this method
    MUST be overridden so that the overridden version sends #on: to super
    passing an object that is NOT the same as anObject (alternatively,
    you can override #dumpTo:, which is what NullProxy does), because that
    would result in an infinite loop!  This also means that
    AlternativeObjectProxy must never be used directly -- only as
    a superclass."
    ^self new object: anObject
! !

!AlternativeObjectProxy methodsFor: 'accessing'!

object
    "Reconstruct the object stored in the proxy and answer it.  A
     subclass will usually override this"
    ^object
!

primObject
    "Reconstruct the object stored in the proxy and answer it.  This
     method must not be overridden"
    ^object
!

object: theObject
    "Set the object to be dumped to theObject.  This should not be
     overridden."
    object := theObject
! !


!NullProxy class methodsFor: 'instance creation'!

loadFrom: anObjectDumper
    "Reload the object stored in anObjectDumper"
    ^anObjectDumper load
! !

!NullProxy methodsFor: 'accessing'!

dumpTo: anObjectDumper
    "Dump the object stored in the proxy to anObjectDumper"
    
    anObjectDumper dumpContentsOf: self object
! !


!PluggableProxy class methodsFor: 'accessing'!

on: anObject
    "Answer a proxy to be used to save anObject.  The proxy
     stores a different object obtained by sending to anObject
     the #binaryRepresentationObject message (embedded
     between #preStore and #postStore as usual)."

    anObject preStore.
    ^[ super on: anObject binaryRepresentationObject ]
	ensure: [ anObject postStore ].
! !

!PluggableProxy methodsFor: 'saving and restoring'!

object
    "Reconstruct the object stored in the proxy and answer it;
     the binaryRepresentationObject is sent the
     #reconstructOriginalObject message, and the resulting
     object is sent the #postLoad message."
    ^super object reconstructOriginalObject
	postLoad;
	yourself
! !


!VersionableObjectProxy class methodsFor: 'saving and restoring'!

loadFrom: anObjectDumper
    "Retrieve the object.  If the version number doesn't match the
     #binaryRepresentationVersion answered by the class, call the class'
     #convertFromVersion:withFixedVariables:instanceVariables:for: method.
     The stored version number will be the first parameter to that method
     (or nil if the stored object did not employ a VersionableObjectProxy),
     the remaining parameters will be respectively the fixed instance
     variables, the indexed instance variables (or nil if the class is
     fixed), and the ObjectDumper itself.
     If no VersionableObjectProxy, the class is sent #nonVersionedInstSize
     to retrieve the number of fixed instance variables stored for the
     non-versioned object."

    | version object instSize |
    version := anObjectDumper stream nextLong.
    version := version >= 0
	ifTrue: [
	    "The version was actually an object index -- move back in the stream."
	    anObjectDumper stream skip: -4.
	    instSize := nil.
	    nil ]
	ifFalse: [
	    instSize := anObjectDumper stream nextUlong.
	    -1 - version
	].
	    
    ^version == self object class binaryRepresentationVersion
	ifTrue: [ anObjectDumper load ]
	ifFalse: [ anObjectDumper loadFromVersion: version fixedSize: instSize ]
!

!VersionableObjectProxy methodsFor: 'saving and restoring'!

dumpTo: anObjectDumper
    "Save the object with extra versioning information."
    anObjectDumper stream
	nextPutLong: -1 - self object class binaryRepresentationVersion;
	nextPutLong: self object class instSize.

    super dumpTo: anObjectDumper
! !


!SingletonProxy class methodsFor: 'accessing'!

acceptUsageForClass: aClass
    "The receiver was asked to be used as a proxy for the class aClass.
     The registration is fine if the class is actually a singleton."
    | singleton |
    singleton := aClass someInstance.
    singleton nextInstance isNil ifFalse: [ ^false ].
    Singletons isNil ifTrue: [ Singletons := IdentityDictionary new ].
    Singletons at: aClass put: singleton.
    ^true
! !


!SingletonProxy class methodsFor: 'instance creation'!

on: anObject
    "Answer a proxy to be used to save anObject.  The proxy
     stores the class and restores the object by looking into
     a dictionary of class -> singleton objects."

    (Singletons includesKey: anObject class)
	ifTrue: [ ^super on: anObject class ].

    self error: 'class not registered within SingletonProxy'
! !

!SingletonProxy methodsFor: 'saving and restoring'!

object
    "Reconstruct the object stored in the proxy and answer it;
     the binaryRepresentationObject is sent the
     #reconstructOriginalObject message, and the resulting
     object is sent the #postLoad message."

    ^Singletons at: super object ifAbsent: [
	self error: 'class not registered within SingletonProxy' ]
! !

ObjectDumper
    initialize;
    registerProxyClass: PluggableProxy for: CompiledMethod;
    registerProxyClass: PluggableProxy for: CompiledBlock;
    registerProxyClass: SingletonProxy for: Processor class!
