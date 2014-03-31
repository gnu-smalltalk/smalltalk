"======================================================================
|
|   Object Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1990,1991,1992,94,95,99,2000,2001,2002,2003,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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



nil subclass: Object [
    
    <comment: 'I am the root of the Smalltalk class system. 
All classes in the system are subclasses of me.'>
    <category: 'Language-Implementation'>

    Dependencies := nil.
    FinalizableObjects := nil.
    FinalSemaphore := nil.

    Object class >> update: aspect [
	"Do any global tasks for the ObjectMemory events."

	<category: 'initialization'>
	aspect == #returnFromSnapshot ifFalse: [^self].
	ContextPart checkPresenceOfJIT.
	FinalizableObjects := nil
    ]

    Object class >> dependencies [
	"Answer a dictionary that associates an object with its dependents."

	<category: 'initialization'>
	^Dependencies
    ]

    Object class >> dependencies: anObject [
	"Use anObject as the dictionary that associates an object with its dependents."

	<category: 'initialization'>
	Dependencies := anObject
    ]

    Object class >> finalSemaphore [
	<category: 'initialization'>

	FinalSemaphore isNil ifFalse: [ ^FinalSemaphore ].
	^ [
            FinalSemaphore isNil ifTrue: [ FinalSemaphore := Semaphore forMutualExclusion ].
            FinalSemaphore
          ] valueWithoutPreemption
    ]

    Object class >> finalizableObjects [
	"Answer a set of finalizable objects."

	<category: 'initialization'>
	FinalizableObjects isNil ifTrue: [FinalizableObjects := Set new].
	^FinalizableObjects
    ]

    Object class >> initialize [
	"Initialize the Dependencies dictionary to be a WeakKeyIdentityDictionary."

	<category: 'initialization'>
	self == Object ifFalse: [^self].
	self dependencies: WeakKeyIdentityDictionary new.
	ObjectMemory addDependent: self
    ]

    ~= anObject [
	"Answer whether the receiver and anObject are not equal"

	<category: 'relational operators'>
	^self = anObject == false
    ]

    ~~ anObject [
	"Answer whether the receiver and anObject are not the same object"

	<category: 'relational operators'>
	^self == anObject == false
    ]

    isKindOf: aClass [
	"Answer whether the receiver's class is aClass or
	 a subclass of aClass"

	<category: 'testing functionality'>
	^self class == aClass or: [self class inheritsFrom: aClass]
    ]

    isMemberOf: aClass [
	"Returns true if the receiver is an instance of the class 'aClass'"

	<category: 'testing functionality'>
	^self class == aClass
    ]

    respondsTo: aSymbol [
	"Returns true if the receiver understands the given selector"

	<category: 'testing functionality'>
	^self class canUnderstand: aSymbol
    ]

    isNil [
	"Answer whether the receiver is nil"

	<category: 'testing functionality'>
	^false
    ]

    notNil [
	"Answer whether the receiver is not nil"

	<category: 'testing functionality'>
	^true
    ]

    ifNil: nilBlock [
	"Evaluate nilBlock if the receiver is nil, else answer self"

	<category: 'testing functionality'>
	^self
    ]

    ifNil: nilBlock ifNotNil: notNilBlock [
	"Evaluate nilBlock if the receiver is nil, else evaluate
	 notNilBlock, passing the receiver."

	<category: 'testing functionality'>
	^notNilBlock cull: self
    ]

    ifNotNil: notNilBlock [
	"Evaluate notNilBlock if the receiver is not nil, passing the receiver.
	 Else answer nil."

	<category: 'testing functionality'>
	^notNilBlock cull: self
    ]

    ifNotNil: notNilBlock ifNil: nilBlock [
	"Evaluate nilBlock if the receiver is nil, else evaluate
	 notNilBlock, passing the receiver."

	<category: 'testing functionality'>
	^notNilBlock cull: self
    ]

    isCObject [
	<category: 'testing functionality'>
	^false
    ]

    isString [
	<category: 'testing functionality'>
	^false
    ]

    isCharacterArray [
	<category: 'testing functionality'>
	^false
    ]

    isSymbol [
	<category: 'testing functionality'>
	^false
    ]

    isCharacter [
	<category: 'testing functionality'>
	^false
    ]

    isNumber [
	<category: 'testing functionality'>
	^false
    ]

    isFloat [
	<category: 'testing functionality'>
	^false
    ]

    isInteger [
	<category: 'testing functionality'>
	^false
    ]

    isSmallInteger [
	<category: 'testing functionality'>
	^false
    ]

    isNamespace [
	<category: 'testing functionality'>
	^false
    ]

    isClass [
	<category: 'testing functionality'>
	^false
    ]

    isArray [
	<category: 'testing functionality'>
	^false
    ]

    isBehavior [
	<category: 'testing functionality'>
	^false
    ]

    isMeta [
	"Same as isMetaclass"

	<category: 'testing functionality'>
	^self isMetaclass
    ]

    isMetaClass [
	"Same as isMetaclass"

	<category: 'testing functionality'>
	^self isMetaclass
    ]

    isMetaclass [
	<category: 'testing functionality'>
	^false
    ]

    copy [
	"Returns a shallow copy of the receiver (the instance variables are
	 not copied). The shallow copy receives the message postCopy and the
	 result of postCopy is passed back."

	<category: 'copying'>
	^self shallowCopy postCopy
    ]

    postCopy [
	"Performs any changes required to do on a copied object. This is the
	 place where one could, for example, put code to replace objects with
	 copies of the objects"

	<category: 'copying'>
	^self
    ]

    deepCopy [
	"Returns a deep copy of the receiver (the instance variables are
	 copies of the receiver's instance variables)"

	<category: 'copying'>
	| class aCopy num |
	class := self class.
	aCopy := self shallowCopy.
	class isPointers 
	    ifTrue: [num := class instSize + self basicSize]
	    ifFalse: [num := class instSize].

	"copy the instance variables (if any)"
	1 to: num do: [:i | aCopy instVarAt: i put: (self instVarAt: i) copy].
	^aCopy
    ]

    species [
	"This method has no unique definition. Generally speaking, methods which
	 always return the same type usually don't use #class, but #species.
	 For example, a PositionableStream's species is the class of the collection
	 on which it is streaming (used by upTo:, upToAll:, upToEnd). Stream uses
	 species for obtaining the class of next:'s return value, Collection uses
	 it in its #copyEmpty: message, which in turn is used by all collection-returning
	 methods. An Interval's species is Array (used by collect:, select:,
	 reject:, etc.)."

	<category: 'class type methods'>
	^self class
    ]

    yourself [
	"Answer the receiver"

	<category: 'class type methods'>
	^self
    ]

    addDependent: anObject [
	"Add anObject to the set of the receiver's dependents. Important:
	 if an object has dependents, it won't be garbage collected."

	<category: 'dependents access'>
	^(Dependencies at: self ifAbsentPut: [OrderedCollection new]) 
	    add: anObject
    ]

    removeDependent: anObject [
	"Remove anObject to the set of the receiver's dependents. No problem
	 if anObject is not in the set of the receiver's dependents."

	<category: 'dependents access'>
	| dependencies |
	dependencies := Dependencies at: self ifAbsent: [^anObject].
	dependencies remove: anObject ifAbsent: [].
	dependencies size < 1 ifTrue: [
	    Dependencies removeKey: self ifAbsent: []].
	^anObject
    ]

    dependents [
	"Answer a collection of the receiver's dependents."

	<category: 'dependents access'>
	| dependencies |
	dependencies := Dependencies at: self ifAbsent: [^OrderedCollection new].
	^dependencies asOrderedCollection
    ]

    release [
	"Remove all of the receiver's dependents from the set and allow the
	 receiver to be garbage collected."

	<category: 'dependents access'>
	Dependencies removeKey: self ifAbsent: []
    ]

    addToBeFinalized [
	"Arrange things so that #finalize is sent to the object when the garbage
	 collector finds out there are only weak references to it."

	<category: 'finalization'>
	self class finalSemaphore critical: [ self class finalizableObjects add: ((HomedAssociation 
		    key: self
		    value: nil
		    environment: FinalizableObjects)
		    makeEphemeron;
		    yourself) ]
    ]

    removeToBeFinalized [
	"Unregister the object, so that #finalize is no longer sent to the object
	 when the garbage collector finds out there are only weak references to it."

	<category: 'finalization'>
	self class finalSemaphore critical: [ self class finalizableObjects remove: (HomedAssociation 
		    key: self
		    value: nil
		    environment: self class finalizableObjects)
	    ifAbsent: [] ]
    ]

    mourn [
	"This method is sent by the VM to weak and ephemeron objects when one of
	 their fields is found out to be garbage collectable (this means, for weak
	 objects, that there are no references to it from non-weak objects, and
	 for ephemeron objects, that the only paths to the first instance variable
	 pass through other instance variables of the same ephemeron).  The default
	 behavior is to do nothing."

	<category: 'finalization'>
	
    ]

    finalize [
	"Do nothing by default"

	<category: 'finalization'>
	
    ]

    changed [
	"Send update: for each of the receiver's dependents, passing them the
	 receiver"

	<category: 'change and update'>
	self changed: self
    ]

    changed: aParameter [
	"Send update: for each of the receiver's dependents, passing them
	 aParameter"

	<category: 'change and update'>
	| dependencies |
	dependencies := Object dependencies at: self ifAbsent: [nil].
	dependencies notNil 
	    ifTrue: [dependencies do: [:dependent | dependent update: aParameter]]
    ]

    update: aParameter [
	"Default behavior is to do nothing. Called by #changed and #changed:"

	<category: 'change and update'>
	
    ]

    broadcast: aSymbol [
	"Send the unary message aSymbol to each of the receiver's dependents"

	<category: 'change and update'>
	| dependencies |
	dependencies := Object dependencies at: self ifAbsent: [nil].
	dependencies notNil 
	    ifTrue: [dependencies do: [:dependent | dependent perform: aSymbol]]
    ]

    broadcast: aSymbol with: anObject [
	"Send the message aSymbol to each of the receiver's dependents, passing
	 anObject"

	<category: 'change and update'>
	| dependencies |
	dependencies := Object dependencies at: self ifAbsent: [nil].
	dependencies notNil 
	    ifTrue: 
		[dependencies do: [:dependent | dependent perform: aSymbol with: anObject]]
    ]

    broadcast: aSymbol with: arg1 with: arg2 [
	"Send the message aSymbol to each of the receiver's dependents, passing
	 arg1 and arg2 as parameters"

	<category: 'change and update'>
	| dependencies |
	dependencies := Object dependencies at: self ifAbsent: [nil].
	dependencies notNil 
	    ifTrue: 
		[dependencies do: 
			[:dependent | 
			dependent 
			    perform: aSymbol
			    with: arg1
			    with: arg2]]
    ]

    broadcast: aSymbol withBlock: aBlock [
	"Send the message aSymbol to each of the receiver's dependents, passing
	 the result of evaluating aBlock with each dependent as the parameter"

	<category: 'change and update'>
	| dependencies |
	dependencies := Object dependencies at: self ifAbsent: [nil].
	dependencies notNil 
	    ifTrue: 
		[dependencies 
		    do: [:dependent | dependent perform: aSymbol with: (aBlock value: dependent)]]
    ]

    broadcast: aSymbol withArguments: anArray [
	"Send the message aSymbol to each of the receiver's dependents, passing
	 the parameters in anArray"

	<category: 'change and update'>
	| dependencies |
	dependencies := Object dependencies at: self ifAbsent: [nil].
	dependencies notNil 
	    ifTrue: 
		[dependencies 
		    do: [:dependent | dependent perform: aSymbol withArguments: anArray]]
    ]

    -> anObject [
	"Creates a new instance of Association with the receiver being the key
	 and the argument becoming the value"

	<category: 'syntax shortcuts'>
	^Association key: self value: anObject
    ]

    displayString [
	"Answer a String representing the receiver. For most objects
	 this is simply its #printString, but for strings and characters,
	 superfluous dollars or extra pair of quotes are stripped."

	<category: 'printing'>
	| stream |
	stream := WriteStream on: String new.
	self displayOn: stream.
	^stream contents
    ]

    displayOn: aStream [
	"Print a represention of the receiver on aStream. For most objects
	 this is simply its #printOn: representation, but for strings and
	 characters, superfluous dollars or extra pair of quotes are stripped."

	<category: 'printing'>
	self printOn: aStream
    ]

    display [
	"Print a represention of the receiver on the Transcript (stdout the GUI
	 is not active). For most objects this is simply its #print
	 representation, but for strings and characters, superfluous dollars
	 or extra pair of quotes are stripped."

	<category: 'printing'>
	Transcript show: self displayString
    ]

    displayNl [
	"Print a represention of the receiver, then put a new line on
	 the Transcript (stdout the GUI is not active). For most objects this
	 is simply its #printNl representation, but for strings and
	 characters, superfluous dollars or extra pair of quotes are stripped."

	<category: 'printing'>
	Transcript showCr: self displayString
    ]

    printString [
	"Answer a String representing the receiver"

	<category: 'printing'>
	| stream |
	stream := WriteStream on: String new.
	self printOn: stream.
	^stream contents
    ]

    printOn: aStream [
	"Print a represention of the receiver on aStream"

	<category: 'printing'>
	aStream
	    nextPutAll: self class article;
	    space;
	    nextPutAll: self class name
    ]

    basicPrintOn: aStream [
	"Print a represention of the receiver on aStream"

	<category: 'printing'>
	aStream
	    nextPutAll: self class article;
	    space;
	    nextPutAll: self class name
    ]

    print [
	"Print a represention of the receiver on the Transcript (stdout the GUI
	 is not active)"

	<category: 'printing'>
	Transcript show: self printString
    ]

    printNl [
	"Print a represention of the receiver on stdout, put a new line
	 the Transcript (stdout the GUI is not active)"

	<category: 'printing'>
	Transcript showCr: self printString
    ]

    basicPrintNl [
	"Print a basic representation of the receiver, followed by a new line."

	<category: 'printing'>
	stdout flush.
	self basicPrint.
	stdout nextPut: Character nl; flush
    ]

    storeString [
	"Answer a String of Smalltalk code compiling to the receiver"

	<category: 'storing'>
	| stream |
	stream := WriteStream on: String new.
	self storeOn: stream.
	^stream contents
    ]

    storeLiteralOn: aStream [
	"Put a Smalltalk literal compiling to the receiver on aStream"

	<category: 'storing'>
	aStream nextPutAll: '##('.
	self storeOn: aStream.
	aStream nextPut: $)
    ]

    storeOn: aStream [
	"Put Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	| class hasSemi |
	class := self class.
	aStream nextPut: $(.
	aStream nextPutAll: self class storeString.
	hasSemi := false.
	class isVariable 
	    ifTrue: 
		[aStream nextPutAll: ' basicNew: '.
		self basicSize printOn: aStream]
	    ifFalse: [aStream nextPutAll: ' basicNew'].
	1 to: class instSize
	    do: 
		[:i | 
		aStream nextPutAll: ' instVarAt: '.
		i printOn: aStream.
		aStream nextPutAll: ' put: '.
		(self instVarAt: i) storeOn: aStream.
		aStream nextPut: $;.
		hasSemi := true].
	class isVariable 
	    ifTrue: 
		[1 to: self validSize
		    do: 
			[:i | 
			aStream nextPutAll: ' basicAt: '.
			i printOn: aStream.
			aStream nextPutAll: ' put: '.
			(self basicAt: i) storeOn: aStream.
			aStream nextPut: $;.
			hasSemi := true]].
	hasSemi ifTrue: [aStream nextPutAll: ' yourself'].
	aStream nextPut: $)
    ]

    store [
	"Put a String of Smalltalk code compiling to the receiver on
	 the Transcript (stdout the GUI is not active)"

	<category: 'storing'>
	Transcript show: self storeString
    ]

    storeNl [
	"Put a String of Smalltalk code compiling to the receiver, followed by
	 a new line, on the Transcript (stdout the GUI is not active)"

	<category: 'storing'>
	Transcript showCr: self storeString
    ]

    binaryRepresentationObject [
	"This method must be implemented if PluggableProxies are used with
	 the receiver's class.  The default implementation raises an exception."

	<category: 'saving and loading'>
	(ObjectDumper proxyClassFor: self) == PluggableProxy 
	    ifTrue: [self subclassResponsibility]
	    ifFalse: [self shouldNotImplement]
    ]

    postLoad [
	"Called after loading an object; must restore it to the state before
	 `preStore' was called.  Do nothing by default"

	<category: 'saving and loading'>
	
    ]

    postStore [
	"Called after an object is dumped; must restore it to the state before
	 `preStore' was called.  Call #postLoad by default"

	<category: 'saving and loading'>
	self postLoad
    ]

    preStore [
	"Called before dumping an object; it must *change* it (it must not answer
	 a new object) if necessary.  Do nothing by default"

	<category: 'saving and loading'>
	
    ]

    reconstructOriginalObject [
	"Used if an instance of the receiver's class is returned as the
	 #binaryRepresentationObject of another object.  The default implementation
	 raises an exception."

	<category: 'saving and loading'>
	self subclassResponsibility
    ]

    examine [
	"Print all the instance variables of the receiver on the Transcript"

	<category: 'debugging'>
        self examineOn: Transcript
    ]

    inspect [
	"In a GUI environment, this opens a tool to examine and modify the
	 receiver.  In the default image, it just calls #examine."

	<category: 'debugging'>
        self examineOn: Transcript
    ]

    examineOn: aStream [
	"Print all the instance variables of the receiver on aStream"

	<category: 'debugging'>
	| instVars output object |
	aStream
	    nextPutAll: 'An instance of ';
	    print: self class;
	    nl.
	instVars := self class allInstVarNames.
	1 to: instVars size + self validSize
	    do: 
		[:i | 
		object := self instVarAt: i.
		output := [object printString] on: Error
			    do: 
				[:ex | 
				ex 
				    return: '%1 %2' % 
						{object class article.
						object class name asString}].
		i <= instVars size 
		    ifTrue: 
			[aStream
			    nextPutAll: '  ';
			    nextPutAll: (instVars at: i);
			    nextPutAll: ': ']
		    ifFalse: 
			[aStream
			    nextPutAll: '  [';
			    print: i - instVars size;
			    nextPutAll: ']: '].
		aStream
		    nextPutAll: output;
		    nl]
    ]

    validSize [
	"Answer how many elements in the receiver should be inspected"

	<category: 'debugging'>
	^self basicSize
    ]

    allOwners [
	"Return an Array of Objects that point to the receiver."

	<category: 'built ins'>
	<primitive: VMpr_Object_allOwners>
	
    ]

    changeClassTo: aBehavior [
	"Mutate the class of the receiver to be aBehavior.
	 Note: Tacitly assumes that the structure is the same
	 for the original and new class!!"

	<category: 'built ins'>
	<primitive: VMpr_Object_changeClassTo>
	
    ]

    checkIndexableBounds: index ifAbsent: aBlock [
	"Private - Check the reason why an access to the given indexed
	 instance variable failed.  Evaluate aBlock for an invalid index."

	<category: 'built ins'>
	self class isFixed ifTrue: [^SystemExceptions.NotIndexable signalOn: self].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	^aBlock value
    ]

    checkIndexableBounds: index [
	"Private - Check the reason why an access to the given indexed
	 instance variable failed"

	<category: 'built ins'>
	self class isFixed ifTrue: [^SystemExceptions.NotIndexable signalOn: self].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	index < 1 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	index > self basicSize 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index]
    ]

    checkIndexableBounds: index put: object [
	"Private - Check the reason why a store to the given indexed
	 instance variable failed"

	<category: 'built ins'>
	| shape size |
	self class isFixed ifTrue: [^SystemExceptions.NotIndexable signalOn: self].
	self isReadOnly ifTrue: [^SystemExceptions.ReadOnlyObject signal].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	index < 1 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	index > self basicSize 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	shape := self class shape.
	(shape == #float or: [shape == #double]) 
	    ifTrue: 
		[SystemExceptions.WrongClass signalOn: object
		    mustBe: 
			{Float.
			SmallInteger}].
	(object isKindOf: Character) 
	    ifFalse: 
		[(shape == #character or: [shape == #utf32]) 
		    ifTrue: [SystemExceptions.WrongClass signalOn: object mustBe: Character]].
	shape == #character 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: object
		    mustBeBetween: (Character value: 0)
		    and: (Character value: 255)].
	shape == #utf32 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: object
		    mustBeBetween: 0 asCharacter
		    and: 1114111 asCharacter].
	shape == #byte ifTrue: [size := 8].
	shape == #int8 ifTrue: [size := 7].
	shape == #ushort ifTrue: [size := 16].
	shape == #short ifTrue: [size := 15].
	shape == #uint ifTrue: [size := 32].
	shape == #int ifTrue: [size := 31].
	shape == #uint64 ifTrue: [size := 64].
	shape == #int64 ifTrue: [size := 63].
	size isNil ifTrue: [^self primtiveFailed].
	^SystemExceptions.ArgumentOutOfRange 
	    signalOn: object
	    mustBeBetween: (size odd ifTrue: [-1 bitShift: size] ifFalse: [0])
	    and: (1 bitShift: size) - 1
    ]

    at: anIndex [
	"Answer the index-th indexed instance variable of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAt>
	self checkIndexableBounds: anIndex
    ]

    basicAt: anIndex [
	"Answer the index-th indexed instance variable of the receiver.
	 This method must not be overridden, override at: instead"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAt>
	self checkIndexableBounds: anIndex
    ]

    at: anIndex put: value [
	"Store value in the index-th indexed instance variable of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAtPut>
	self checkIndexableBounds: anIndex put: value
    ]

    basicAt: anIndex put: value [
	"Store value in the index-th indexed instance variable of the receiver
	 This method must not be overridden, override at:put: instead"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAtPut>
	self checkIndexableBounds: anIndex put: value
    ]

    size [
	"Answer the number of indexed instance variable in the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicSize>
	
    ]

    basicSize [
	"Answer the number of indexed instance variable in the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicSize>
	
    ]

    becomeForward: otherObject [
	"Change all references to the receiver into references to otherObject.
	 References to otherObject are not transformed into the receiver.
	 Answer the receiver so that it is not lost."

	<category: 'built ins'>
	<primitive: VMpr_Object_becomeForward>
	^SystemExceptions.ReadOnlyObject signal
    ]

    become: otherObject [
	"Change all references to the receiver into references to otherObject.
	 Depending on the implementation, references to otherObject might or
	 might not be transformed into the receiver (respectively,
	 'two-way become' and 'one-way become').
	 Implementations doing one-way become answer the receiver (so that it is
	 not lost). Most implementations doing two-way become answer otherObject,
	 but this is not assured - so do answer the receiver for consistency.
	 GNU Smalltalk does two-way become and answers otherObject, but this
	 might change in future versions: programs should not rely on the behavior
	 and results of #become: ."

	<category: 'built ins'>
	<primitive: VMpr_Object_become>
	^SystemExceptions.ReadOnlyObject signal
    ]

    shallowCopy [
	"Returns a shallow copy of the receiver (the instance variables are
	 not copied)"

	<category: 'built ins'>
	"This is a primitive for speed.  An alternative implementation is
	 found below."

	| class aCopy |
	<primitive: VMpr_Object_shallowCopy>
	class := self class.
	class isVariable 
	    ifTrue: [aCopy := class basicNew: self basicSize]
	    ifFalse: [aCopy := class basicNew].

	"copy the instance variables (if any)"
	1 to: class instSize + self basicSize
	    do: [:i | aCopy instVarAt: i put: (self instVarAt: i)].
	^aCopy
    ]

    makeFixed [
	"Avoid that the receiver moves in memory across garbage collections."

	"We are an integer - fail"

	<category: 'built ins'>
	<primitive: VMpr_Object_makeFixed>
	SystemExceptions.InvalidValue signalOn: self
	    reason: 'Instances of Integer cannot be tenured!'
    ]

    tenure [
	"Move the object to oldspace."

	"We are an integer - they won't notice the difference so don't
	 fail."

	<category: 'built ins'>
	<primitive: VMpr_Object_tenure>
	
    ]

    instVarNamed: aString [
	"Answer the instance variable named aString in the receiver."

	<category: 'introspection'>
	^self instVarAt: (self class indexOfInstVar: aString)
    ]

    instVarNamed: aString put: anObject [
	"Answer the instance variable named aString in the receiver."

	<category: 'introspection'>
	^self instVarAt: (self class indexOfInstVar: aString) put: anObject
    ]

    instVarAt: index [
	"Answer the index-th instance variable of the receiver.
	 This method must not be overridden."

	<category: 'built ins'>
	<primitive: VMpr_Object_instVarAt>
	index < 1 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	index > (self basicSize + self class instSize) 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	^self basicAt: index - self class instSize
    ]

    instVarAt: index put: value [
	"Store value in the index-th instance variable of the receiver.
	 This method must not be overridden."

	<category: 'built ins'>
	<primitive: VMpr_Object_instVarAtPut>
	self isReadOnly ifTrue: [^SystemExceptions.ReadOnlyObject signal].
	index < 1 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	index > (self basicSize + self class instSize) 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	^self basicAt: index - self class instSize put: value
    ]

    isReadOnly [
	"Answer whether the object's indexed instance variables can be
	 written"

	<category: 'built ins'>
	<primitive: VMpr_Object_isReadOnly>
	
    ]

    makeReadOnly: aBoolean [
	"Set whether the object's indexed instance variables can be written"

	<category: 'built ins'>
	<primitive: VMpr_Object_makeReadOnly>
	SystemExceptions.WrongClass signalOn: aBoolean mustBe: Boolean
    ]

    makeWeak [
	"Make the object a 'weak' one. When an object is only referenced by weak
	 objects, it is collected and the slots in the weak objects are changed to
	 nils by the VM; the weak object is then sent the #mourn message."

	<category: 'built ins'>
	<primitive: VMpr_Object_makeWeak>
	
    ]

    makeEphemeron [
	"Make the object an 'ephemeron'.  An ephemeron is marked after all
	 other objects, and if no references are found to the key except from
	 the object itself, it is sent the #mourn message."

	<category: 'built ins'>
	<primitive: VMpr_Object_makeEphemeron>
	SystemExceptions.InvalidValue signalOn: self
	    reason: 'ephemerons should have at least one instance variables'
    ]

    asOop [
	"Answer the object index associated to the receiver. The object
	 index doesn't change when garbage collection is performed."

	"We are an integer - fail"

	<category: 'built ins'>
	<primitive: VMpr_Object_hash>
	SystemExceptions.InvalidValue signalOn: self
	    reason: 'Instances of Integer have no associated OOP!'
    ]

    identityHash [
	"Answer an hash value for the receiver. This method must not be
	 overridden"

	"We are an integer - answer the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_hash>
	^self
    ]

    hash [
	"Answer an hash value for the receiver. This hash value is ok
	 for objects that do not redefine ==."

	"We are an integer - answer the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_hash>
	^self
    ]

    nextInstance [
	"Private - answer another instance of the receiver's class, or
	 nil if the entire object table has been walked"

	<category: 'built ins'>
	<primitive: VMpr_Object_nextInstance>
	^nil
    ]

    perform: selectorOrMessageOrMethod [
	"Send the unary message named selectorOrMessageOrMethod (if a Symbol)
	 to the receiver, or the message and arguments it identifies (if a Message
	 or DirectedMessage), or finally execute the method within the receiver
	 (if a CompiledMethod).  In the last case, the method need not reside on
	 the hierarchy from the receiver's class to Object -- it need not reside
	 at all in a MethodDictionary, in fact -- but doing bad things will
	 compromise stability of the Smalltalk virtual machine (and don't blame
	 anybody but yourself).
	 
	 This method should not be overridden"

	<category: 'built ins'>
	<primitive: VMpr_Object_perform>
	selectorOrMessageOrMethod isSymbol 
	    ifTrue: 
		[(self respondsTo: selectorOrMessageOrMethod) 
		    ifTrue: [^SystemExceptions.WrongArgumentCount signal]
		    ifFalse: 
			[self doesNotUnderstand: (Message selector: selectorOrMessageOrMethod
				    arguments: #())]].
	(selectorOrMessageOrMethod isKindOf: CompiledMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal].
	^selectorOrMessageOrMethod sendTo: self
    ]

    perform: selectorOrMethod with: arg1 [
	"Send the message named selectorOrMethod (if a Symbol) to the receiver,
	 passing arg1 to it, or execute the method within the receiver
	 (if a CompiledMethod).  In the latter case, the method need not reside on
	 the hierarchy from the receiver's class to Object -- it need not reside
	 at all in a MethodDictionary, in fact -- but doing bad things will
	 compromise stability of the Smalltalk virtual machine (and don't blame
	 anybody but yourself).
	 
	 This method should not be overridden"

	<category: 'built ins'>
	<primitive: VMpr_Object_perform>
	(selectorOrMethod isKindOf: CompiledMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal].
	selectorOrMethod isSymbol 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol].
	(self respondsTo: selectorOrMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal]
	    ifFalse: 
		[self 
		    doesNotUnderstand: (Message selector: selectorOrMethod arguments: {arg1})]
    ]

    perform: selectorOrMethod with: arg1 with: arg2 [
	"Send the message named selectorOrMethod (if a Symbol) to the receiver,
	 passing arg1 and arg2 to it, or execute the method within the receiver
	 (if a CompiledMethod).  In the latter case, the method need not reside on
	 the hierarchy from the receiver's class to Object -- it need not reside
	 at all in a MethodDictionary, in fact -- but doing bad things will
	 compromise stability of the Smalltalk virtual machine (and don't blame
	 anybody but yourself).
	 
	 This method should not be overridden"

	<category: 'built ins'>
	<primitive: VMpr_Object_perform>
	(selectorOrMethod isKindOf: CompiledMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal].
	selectorOrMethod isSymbol 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol].
	(self respondsTo: selectorOrMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal]
	    ifFalse: 
		[self doesNotUnderstand: (Message selector: selectorOrMethod
			    arguments: 
				{arg1.
				arg2})]
    ]

    perform: selectorOrMethod with: arg1 with: arg2 with: arg3 [
	"Send the message named selectorOrMethod (if a Symbol) to the receiver,
	 passing the other arguments to it, or execute the method within the
	 receiver (if a CompiledMethod).  In the latter case, the method need not
	 reside on the hierarchy from the receiver's class to Object -- it need
	 not reside at all in a MethodDictionary, in fact -- but doing bad things
	 will compromise stability of the Smalltalk virtual machine (and don't
	 blame anybody but yourself).
	 
	 This method should not be overridden"

	<category: 'built ins'>
	<primitive: VMpr_Object_perform>
	(selectorOrMethod isKindOf: CompiledMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal].
	selectorOrMethod isSymbol 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol].
	(self respondsTo: selectorOrMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal]
	    ifFalse: 
		[self doesNotUnderstand: (Message selector: selectorOrMethod
			    arguments: 
				{arg1.
				arg2.
				arg3})]
    ]

    perform: selectorOrMethod with: arg1 with: arg2 with: arg3 with: arg4 [
	"Send the message named selectorOrMethod (if a Symbol) to the receiver,
	 passing the other arguments to it, or execute the method within the
	 receiver (if a CompiledMethod).  In the latter case, the method need not
	 reside on the hierarchy from the receiver's class to Object -- it need
	 not reside at all in a MethodDictionary, in fact -- but doing bad things
	 will compromise stability of the Smalltalk virtual machine (and don't
	 blame anybody but yourself).
	 
	 This method should not be overridden"

	<category: 'built ins'>
	<primitive: VMpr_Object_perform>
	(selectorOrMethod isKindOf: CompiledMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal].
	selectorOrMethod isSymbol 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol].
	(self respondsTo: selectorOrMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal]
	    ifFalse: 
		[self doesNotUnderstand: (Message selector: selectorOrMethod
			    arguments: 
				{arg1.
				arg2.
				arg3.
				arg4})]
    ]

    perform: selectorOrMethod withArguments: argumentsArray [
	"Send the message named selectorOrMethod (if a Symbol) to the receiver,
	 passing the elements of argumentsArray as parameters, or execute the
	 method within the receiver (if a CompiledMethod).  In the latter case,
	 the method need not reside on the hierarchy from the receiver's class
	 to Object -- it need not reside at all in a MethodDictionary, in
	 fact -- but doing bad things will compromise stability of the Smalltalk
	 virtual machine (and don't blame anybody but yourself).
	 
	 This method should not be overridden"

	<category: 'built ins'>
	<primitive: VMpr_Object_performWithArguments>
	argumentsArray isArray 
	    ifFalse: [SystemExceptions.WrongClass signalOn: argumentsArray mustBe: Array].
	(selectorOrMethod isKindOf: CompiledMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal].
	selectorOrMethod isSymbol 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: selectorOrMethod mustBe: Symbol].
	(self respondsTo: selectorOrMethod) 
	    ifTrue: [SystemExceptions.WrongArgumentCount signal]
	    ifFalse: 
		[self doesNotUnderstand: (Message selector: selectorOrMethod
			    arguments: argumentsArray)]
    ]

    == arg [
	"Answer whether the receiver is the same object as arg. This is a
	 very fast test and is called 'object identity'."

	<category: 'built ins'>
	<primitive: VMpr_Object_identity>
	
    ]

    = arg [
	"Answer whether the receiver is equal to arg. The equality test is
	 by default the same as that for identical objects. = must not fail;
	 answer false if the receiver cannot be compared to arg"

	<category: 'built ins'>
	<primitive: VMpr_Object_identity>
	
    ]

    class [
	"Answer the class to which the receiver belongs"

	<category: 'built ins'>
	<primitive: VMpr_Object_class>
	self primitiveFailed
    ]

    error: message [
	"Stop the execution and/or bring up a debugger. message is an error
	 message to be shown"

	<category: 'built ins'>
	<primitive: VMpr_Object_bootstrapError>
	
    ]

    basicPrint [
	"Print a basic representation of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicPrint>
	
    ]

    halt [
	"Called to enter the debugger"

	<category: 'built ins'>
	^self halt: 'halt encountered'
    ]

    halt: aString [
	"Called to enter the debugger"

	<category: 'built ins'>
	^self error: aString
    ]

    mark: aSymbol [
	"Private - use this method to mark code which needs to be reworked,
	 removed, etc. You can then find all senders of #mark: to find all marked
	 methods or you can look for all senders of the symbol that you sent to
	 #mark: to find a category of marked methods."

	<category: 'built ins'>
	
    ]

    primitiveFailed [
	"Called when a VM primitive fails"

	<category: 'built ins'>
	SystemExceptions.PrimitiveFailed signal
    ]

    shouldNotImplement [
	"Called when objects belonging to a class should not answer a
	 selector defined by a superclass"

	<category: 'built ins'>
	SystemExceptions.ShouldNotImplement signal
    ]

    subclassResponsibility [
	"Called when a method defined by a class should be overridden
	 in a subclass"

	<category: 'built ins'>
	SystemExceptions.SubclassResponsibility signal
    ]

    notYetImplemented [
	"Called when a method defined by a class is not yet implemented,
	 but is going to be"

	<category: 'built ins'>
	SystemExceptions.NotYetImplemented signal
    ]

    doesNotUnderstand: message [
	"Called by the system when a selector was not found. message is a
	 Message containing information on the receiver"

	<category: 'VM callbacks'>
	<primitive: VMpr_Object_bootstrapDNU>
	
    ]

    badReturnError [
	"Called back when a block performs a bad return."

	<category: 'VM callbacks'>
	SystemExceptions.BadReturn signal
    ]

    mustBeBoolean [
	"Called by the system when ifTrue:*, ifFalse:*, and: or or: are sent to
	 anything but a boolean"

	<category: 'VM callbacks'>
	| result |
	result := SystemExceptions.MustBeBoolean signalOn: self.
	result == false ifFalse: [result := true].
	^result
    ]

    noRunnableProcess [
	"Called back when all processes are suspended"

	<category: 'VM callbacks'>
	SystemExceptions.NoRunnableProcess signal
    ]

    userInterrupt [
	"Called back when the user presses Ctrl-Break"

	<category: 'VM callbacks'>
	SystemExceptions.UserInterrupt signal
    ]
]

