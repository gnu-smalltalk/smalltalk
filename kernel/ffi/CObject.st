"======================================================================
|
|   C object basic data type definitions.
| 
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2004,2008,2009
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



Object subclass: CObject [
    | type storage |
    
    <shape: #word>
    <import: CSymbols>
    <category: 'Language-C interface'>
    <comment: 'I am not part of the standard Smalltalk kernel class hierarchy.
My instances contain values that are not interpreted by the Smalltalk 
system; they frequently hold "pointers" to data outside of the Smalltalk
environment.  The C callout mechanism allows my instances to be transformed
into their corresponding C values for use in external routines.'>

    CObject class [
	| defaultType |
	
    ]

    CObject class >> inheritShape [
	"Answer whether subclasses will have by default the same shape as
	 this class.  The default is true for the CObject hierarchy."
	<category: 'subclass creation'>
	^true
    ]

    CObject class >> alloc: nBytes type: cTypeObject [
	"Allocate nBytes bytes and return a CObject of the given type"

	<category: 'primitive allocation'>
	<primitive: VMpr_CObject_allocType>
	nBytes isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: nBytes mustBe: SmallInteger].
	^SystemExceptions.WrongClass signalOn: cTypeObject mustBe: CType
    ]

    CObject class >> gcAlloc: nBytes type: cTypeObject [
	"Allocate nBytes bytes and return a CObject of the given type"

	<category: 'primitive allocation'>
	| class |
	class := cTypeObject isNil
	    ifTrue: [ self ]
	    ifFalse: [ cTypeObject cObjectType ].

	^(class address: 0)
	    type: cTypeObject;
	    storage: (ByteArray new: nBytes);
	    yourself
    ]

    CObject class >> alloc: nBytes [
	"Allocate nBytes bytes and return an instance of the receiver"

	<category: 'instance creation'>
	^self alloc: nBytes type: nil
    ]

    CObject class >> gcAlloc: nBytes [
	"Allocate nBytes bytes and return an instance of the receiver"

	<category: 'instance creation'>
	^self gcAlloc: nBytes type: nil
    ]

    CObject class >> gcNew: nBytes [
	"Allocate nBytes bytes and return an instance of the receiver"

	<category: 'instance creation'>
	^self gcAlloc: nBytes type: nil
    ]

    CObject class >> new: nBytes [
	"Allocate nBytes bytes and return an instance of the receiver"

	<category: 'instance creation'>
	^self alloc: nBytes type: nil
    ]

    CObject class >> address: anInteger [
	"Answer a new object pointing to the passed address, anInteger"

	<category: 'instance creation'>
	^(self basicNew: 1) address: anInteger
    ]

    CObject class >> new [
	"Answer a new object pointing to NULL."

	<category: 'instance creation'>
	^self address: 0
    ]

    CObject class >> type [
	"Nothing special in the default case - answer a CType for the receiver"

	<category: 'conversion'>
	defaultType isNil ifTrue: [defaultType := CType cObjectType: self].
	^defaultType
    ]

    CObject class >> cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'private'>
	^nil
    ]

    = anObject [
	"Return true if the receiver and aCObject are equal."

	<category: 'basic'>
	^self class == anObject class and: [
	    self type = anObject type and: [
	    self storage == anObject storage and: [
	    self address = anObject address ]]]
    ]

    hash [
	"Return a hash value for anObject."

	<category: 'basic'>
	| addr |
	addr := self address bitAnd: SmallInteger largest.
	^self type hash
	    bitXor: (self storage identityHash * self storage size + addr)
    ]

    finalize [
	"To make the VM call this, use #addToBeFinalized. It frees
	 automatically any memory pointed to by the CObject. It is not
	 automatically enabled because big trouble hits you if you use
	 #free and the receiver doesn't point to the base of a malloc-ed
	 area."

	<category: 'finalization'>
	self free
    ]

    addressAt: anIndex [
	"Return a new CObject of the element type,
	 corresponding to an object that is anIndex places past
	 the receiver (remember that CObjects represent pointers
	 and that C pointers behave like arrays).
	 anIndex is zero-based, just like with all other C-style accessing."

	<category: 'pointer-like behavior'>
	| dereferencedType |
	dereferencedType := self dereferencedType.
	^self at: anIndex * dereferencedType sizeof type: dereferencedType
    ]

    at: anIndex [
	"Dereference a pointer that is anIndex places past
	 the receiver (remember that CObjects represent pointers
	 and that C pointers behave like arrays).  anIndex is
	 zero-based, just like with all other C-style accessing."

	<category: 'pointer-like behavior'>
	| dereferencedType offset valueType |
	dereferencedType := self dereferencedType.
	offset := anIndex * dereferencedType sizeof.
	valueType := dereferencedType valueType.
	^valueType isInteger 
	    ifTrue: [self at: offset type: valueType]
	    ifFalse: [(self at: offset type: dereferencedType) value]
    ]

    at: anIndex put: aValue [
	"Store anIndex places past the receiver the passed Smalltalk
	 object or CObject `aValue'; if it is a CObject is dereferenced:
	 that is, this method is equivalent either to cobj[anIndex]=aValue
	 or cobj[anIndex]=*aValue.  anIndex is zero-based, just like with
	 all other C-style accessing.
	 
	 In both cases, aValue should be of the element type or of the
	 corresponding Smalltalk type (that is, a String is ok for an
	 array of CStrings) to avoid typing problems which however will
	 not be signaled because C is untyped."

	<category: 'pointer-like behavior'>
	| dereferencedType offset valueType |
	dereferencedType := self dereferencedType.
	offset := anIndex * dereferencedType sizeof.
	valueType := dereferencedType valueType.
	valueType isInteger 
	    ifTrue: 
		[self 
		    at: offset
		    put: aValue
		    type: valueType]
	    ifFalse: [(self at: offset type: dereferencedType) value: aValue].
	^aValue
    ]

    isNull [
	"Return true if the receiver points to NULL."

	<category: 'testing'>
	^self address = 0 and: [ self isAbsolute ]
    ]

    isCObject [
	<category: 'testing functionality'>
	^true
    ]

    incr [
	"Adjust the pointer by sizeof(dereferencedType) bytes up (i.e. ++receiver)"

	<category: 'pointer-like behavior'>
	self adjPtrBy: self dereferencedType sizeof
    ]

    decr [
	"Adjust the pointer by sizeof(dereferencedType) bytes down (i.e. --receiver)"

	<category: 'pointer-like behavior'>
	self adjPtrBy: self dereferencedType sizeof negated
    ]

    incrBy: anInteger [
	"Adjust the pointer by anInteger elements up (i.e. receiver += anInteger)"

	<category: 'pointer-like behavior'>
	self adjPtrBy: self dereferencedType sizeof * anInteger
    ]

    decrBy: anInteger [
	"Adjust the pointer by anInteger elements down (i.e. receiver -= anInteger)"

	<category: 'pointer-like behavior'>
	self adjPtrBy: self dereferencedType sizeof * anInteger negated
    ]

    + anInteger [
	"Return another instance of the receiver's class which points at
	 &receiver[anInteger] (or, if you prefer, what `receiver +
	 anInteger' does in C)."

	<category: 'pointer-like behavior'>
	| dereferencedType |
	dereferencedType := self dereferencedType.
	^self at: anInteger * dereferencedType sizeof type: self type
    ]

    - intOrPtr [
	"If intOrPtr is an integer, return another instance of the receiver's
	 class pointing at &receiver[-anInteger] (or, if you prefer, what
	 `receiver - anInteger' does in C).
	 If it is the same class as the receiver, return the difference in
	 chars, i.e. in bytes, between the two pointed addresses (or, if
	 you prefer, what `receiver - anotherCharPtr' does in C)"

	<category: 'pointer-like behavior'>
	| dereferencedType |
	intOrPtr isInteger ifTrue: [^self + intOrPtr negated].
	dereferencedType := self dereferencedType.
	intOrPtr dereferencedType = dereferencedType 
	    ifFalse: 
		[^SystemExceptions.InvalidArgument signalOn: intOrPtr
		    reason: 'arithmetic between pointers to different types'].
	^((self addressAt: 0) address - (intOrPtr addressAt: 0) address) 
	    // dereferencedType sizeof
    ]

    castTo: aType [
	"Answer another CObject, pointing to the same address as the receiver,
	 but belonging to the aType CType."

	<category: 'conversion'>
	^self at: 0 type: aType
    ]

    narrow [
	"This method is called on CObjects returned by a C call-out whose
	 return type is specified as a CType; it mostly allows one to
	 change the class of the returned CObject.  By default it does
	 nothing, and that's why it is not called when #cObject is used
	 to specify the return type."

	<category: 'conversion'>
	
    ]

    type [
	"Answer a CType for the receiver"

	<category: 'conversion'>
	type isNil ifTrue: [type := self class type].
	^type
    ]

    isAbsolute [
	"Answer whether the object points into a garbage-collected Smalltalk
	 storage, or it is an absolute address."

	<category: 'accessing'>
	^storage isNil
    ]

    storage [
	"Answer the storage that the receiver is pointing into, or nil
	 if the address is absolute."

	<category: 'accessing'>
	^storage
    ]

    storage: anObject [
	"Change the receiver to point to the storage of anObject."

	<category: 'accessing'>
	storage := anObject.
    ]

    address [
	"Answer the address the receiver is pointing to.  The address can
	 be absolute if the storage is nil, or relative to the Smalltalk
	 object in #storage.  In this case, an address of 0 corresponds to
	 the first instance variable."

	<category: 'accessing'>
	<primitive: VMpr_CObject_address>
	^self basicAt: self basicSize
    ]

    address: anInteger [
	"Set the receiver to point to the passed address, anInteger"

	<category: 'accessing'>
	<primitive: VMpr_CObject_addressColon>
	SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer
    ]

    printOn: aStream [
	"Print a representation of the receiver"

	<category: 'accessing'>
	aStream
	    print: self class;
	    nextPut: $(.

	self isAbsolute
	    ifTrue: [ aStream nextPutAll: (self address printStringRadix: 16) ]
	    ifFalse: [
		self storage do: [ :each | aStream print: each; space ].
		aStream nextPutAll: '@ '; print: self address ].
	
	aStream nextPut: $)
    ]

    type: aCType [
	"Set the receiver's type to aCType."

	<category: 'accessing'>
	type := aCType
    ]

    adjPtrBy: byteOffset [
	<category: 'private'>
	self address: self address + byteOffset
    ]

    dereferencedType [
	<category: 'private'>
	^self type
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'private'>
	^nil
    ]

    cObjStoredValue [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'private'>
	^self value
    ]

    at: byteOffset type: aType [
	"Answer some data of the given type from byteOffset bytes after
	 the pointer stored in the receiver"

	<category: 'C data access'>
	<primitive: VMpr_CObject_at>
	byteOffset isInteger 
	    ifFalse: 
		[^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger].
	(self isAbsolute not and: [ aType isInteger ]) ifTrue: [
	    ^SystemExceptions.InvalidArgument signalOn: self address + byteOffset
		reason: 'offset out of range' ].

	^SystemExceptions.WrongClass signalOn: aType
    ]

    at: byteOffset put: aValue type: aType [
	"Store aValue as data of the given type from byteOffset bytes after
	 the pointer stored in the receiver"

	<category: 'C data access'>
	| type |
	<primitive: VMpr_CObject_atPut>

	(self isAbsolute not and: [ aValue isCObject not ]) ifTrue: [
	    ^SystemExceptions.InvalidArgument signalOn: self address + byteOffset
		reason: 'offset out of range' ].

	type := aValue cObjStoredType.

	"Attempt to store something meaningful from another CObject"
	type isNil ifTrue: [type := aType].
	^self 
	    at: byteOffset
	    noCObjectsPut: aValue cObjStoredValue
	    type: type
    ]

    free [
	"Free the receiver's pointer and set it to null. Big trouble hits
	 you if the receiver doesn't point to the base of a malloc-ed area."

	<category: 'C data access'>
	<primitive: VMpr_CObject_free>
	^self primitiveFailed
    ]

    at: byteOffset noCObjectsPut: aValue type: aType [
	"Private - Store aValue as data of the given type from byteOffset bytes
	 after the pointer stored in the receiver. This version refuses CObjects
	 for `aValue'."

	<category: 'private'>
	<primitive: VMpr_CObject_atPut>
	byteOffset isInteger 
	    ifFalse: 
		[^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger].
	(aType isInteger or: [aType isKindOf: CType]) 
	    ifFalse: 
		[^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger].
	^SystemExceptions.WrongClass signalOn: aValue
    ]

    derefAt: byteOffset type: aType [
	<category: 'private'>
	<primitive: VMpr_CObject_derefAt>
	byteOffset isInteger 
	    ifFalse: 
		[^SystemExceptions.WrongClass signalOn: byteOffset mustBe: SmallInteger].
	^SystemExceptions.WrongClass signalOn: aType
    ]
]

