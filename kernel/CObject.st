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



CObject subclass: CScalar [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CScalar class >> value: anObject [
	"Answer a newly allocated CObject containing the passed value,
	 anObject. Remember to call #addToBeFinalized if you want the
	 CObject to be automatically freed"

	<category: 'instance creation'>
	| cObject |
	cObject := self type new.
	cObject value: anObject.
	^cObject
    ]

    CScalar class >> gcValue: anObject [
	"Answer a newly allocated CObject containing the passed value,
	 anObject, in garbage-collected storage."

	<category: 'instance creation'>
	| cObject |
	cObject := self type gcNew.
	cObject value: anObject.
	^cObject
    ]

    CScalar class >> type [
	"Answer a CType for the receiver---for example, CByteType if
	 the receiver is CByte."

	<category: 'instance creation'>
	^self environment at: (self name , 'Type') asGlobalKey
    ]

    CScalar class >> cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'private'>
	self subclassResponsibility
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    value [
	"Answer the value the receiver is pointing to. The exact returned
	 value depends on the receiver's class"

	<category: 'accessing'>
	^self at: 0 type: self cObjStoredType
    ]

    value: aValue [
	"Set the receiver to point to the value, aValue. The exact meaning
	 of aValue depends on the receiver's class"

	<category: 'accessing'>
	self 
	    at: 0
	    put: aValue
	    type: self cObjStoredType
    ]
]



CScalar subclass: CSmalltalk [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CSmalltalk class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CPtrSize
    ]

    CSmalltalk class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CPtrSize
    ]

    CSmalltalk class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^9
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CPtrSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CPtrSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^9
    ]
]


CScalar subclass: CLongLong [

    <category: 'Language-C interface'>
    <comment: nil>

    CLongLong class >> sizeof [
       "Answer the receiver's instances size"

       <category: 'accessing'>
       ^8
    ]

    CLongLong class >> alignof [
       "Answer the receiver's instances required aligment"

       <category: 'accessing'>
       ^CLongLongAlignment
    ]

    CLongLong class >> cObjStoredType [
       "Private - Answer an index referring to the receiver's instances scalar type"

       <category: 'accessing'>
       ^30
    ]

    sizeof [
       "Answer the receiver's size"

       <category: 'accessing'>
       ^8
    ]

    alignof [
       "Answer the receiver's required aligment"

       <category: 'accessing'>
       ^CLongLongAlignment
    ]

    cObjStoredType [
       "Private - Answer an index referring to the receiver's scalar type"

       <category: 'accessing'>
       ^30
    ]                                                          
]


CScalar subclass: CULongLong [

    <category: 'Language-C interface'>
    <comment: nil>

    CULongLong class >> sizeof [
       "Answer the receiver's instances size"

       <category: 'accessing'>
       ^8
    ]

    CULongLong class >> alignof [
       "Answer the receiver's instances required aligment"

       <category: 'accessing'>
       ^CLongLongAlignment
    ]

    CULongLong class >> cObjStoredType [
       "Private - Answer an index referring to the receiver's instances scalar type"

       <category: 'accessing'>
       ^31
    ]

    sizeof [
       "Answer the receiver's size"

       <category: 'accessing'>
       ^8
    ]

    alignof [
       "Answer the receiver's required aligment"

       <category: 'accessing'>
       ^CLongLongAlignment
    ]

    cObjStoredType [
       "Private - Answer an index referring to the receiver's scalar type"

       <category: 'accessing'>
       ^31
    ]                                                          
]


CScalar subclass: CLong [
    <category: 'Language-C interface'>
    <comment: nil>

    CLong class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CLongSize
    ]

    CLong class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CLongSize
    ]

    CLong class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^4
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CLongSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CLongSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^4
    ]
]



CScalar subclass: CULong [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CULong class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CLongSize
    ]

    CULong class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CLongSize
    ]

    CULong class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^5
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CLongSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CLongSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^5
    ]
]



CScalar subclass: CInt [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CInt class >> sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CIntSize
    ]

    CInt class >> alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CIntSize
    ]

    CInt class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^10
    ]

    sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CIntSize
    ]

    alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CIntSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^10
    ]
]



CScalar subclass: CUInt [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CUInt class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CIntSize
    ]

    CUInt class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CIntSize
    ]

    CUInt class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^11
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CIntSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CIntSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^11
    ]
]



CScalar subclass: CShort [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CShort class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CShortSize
    ]

    CShort class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CShortSize
    ]

    CShort class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^2
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CShortSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CShortSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^2
    ]
]



CScalar subclass: CUShort [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CUShort class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CShortSize
    ]

    CUShort class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CShortSize
    ]

    CUShort class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^3
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CShortSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CShortSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^3
    ]
]



CScalar subclass: CChar [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CChar class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^1
    ]

    CChar class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^1
    ]

    CChar class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^0
    ]

    asByteArray: size [
	"Convert size bytes pointed to by the receiver to a String"

	<category: 'conversion'>
	^ByteArray fromCData: self size: size
    ]

    asString [
	"Convert the data pointed to by the receiver, up to the first NULL byte,
	 to a String"

	<category: 'conversion'>
	^String fromCData: self
    ]

    asString: size [
	"Convert size bytes pointed to by the receiver to a String"

	<category: 'conversion'>
	^String fromCData: self size: size
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^1
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^1
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^0
    ]
]



CScalar subclass: CUChar [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CUChar class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'getting info'>
	^1
    ]

    CUChar class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'getting info'>
	^1
    ]

    CUChar class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'getting info'>
	^1
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^1
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^1
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^1
    ]
]



CScalar subclass: CFloat [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CFloat class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CFloatSize
    ]

    CFloat class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CFloatSize
    ]

    CFloat class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^6
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CFloatSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CFloatSize
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^6
    ]
]



CScalar subclass: CDouble [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CDouble class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CDoubleSize
    ]

    CDouble class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CDoubleAlignment
    ]

    CDouble class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^7
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CDoubleSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CDoubleAlignment
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^7
    ]
]



CScalar subclass: CLongDouble [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CLongDouble class >> sizeof [
	"Answer the receiver's instances size"

	<category: 'accessing'>
	^CLongDoubleSize
    ]

    CLongDouble class >> alignof [
	"Answer the receiver's instances required aligment"

	<category: 'accessing'>
	^CLongDoubleAlignment
    ]

    CLongDouble class >> cObjStoredType [
	"Private - Answer an index referring to the receiver's instances scalar type"

	<category: 'accessing'>
	^12
    ]

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CLongDoubleSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CLongDoubleAlignment
    ]

    cObjStoredType [
	"Private - Answer an index referring to the receiver's scalar type"

	<category: 'accessing'>
	^12
    ]
]



CObject subclass: CAggregate [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CAggregate class >> sizeof [
	"Answer the receiver's instances size"

	"This is the closest possible guess for CArrays"

	<category: 'accessing'>
	^CPtrSize
    ]

    CAggregate class >> alignof [
	"Answer the receiver's instances required aligment"

	"This is the closest possible guess for CArrays"

	<category: 'accessing'>
	^CPtrSize
    ]

    elementType [
	"Answer the type over which the receiver is constructed."

	<category: 'accessing'>
	^self type elementType
    ]
]



CAggregate subclass: CArray [
    
    <category: 'Language-C interface'>
    <comment: nil>

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^self type numberOfElements * self elementType sizeof
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^self elementType alignof
    ]

    dereferencedType [
	<category: 'private'>
	^self type elementType
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	"If they want to store the receiver with #at:put:, they store the
	 address (of the first character) without dereferencing the pointer."

	<category: 'private'>
	^CLong cObjStoredType
    ]

    cObjStoredValue [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	"If they want to store the receiver with #at:put:, they
	 store the address without dereferencing the pointer."

	<category: 'private'>
	^self address
    ]
]



CAggregate subclass: CPtr [
    
    <category: 'Language-C interface'>
    <comment: nil>

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^CPtrSize
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^CPtrSize
    ]

    value [
	"Answer the address of the location pointed to by the receiver."

	<category: 'accessing'>
	^self derefAt: 0 type: self type elementType
    ]

    value: anObject [
	"Set the address of the location pointed to by the receiver
	 to anObject, which can be either an Integer or a CObject.
	 if anObject is an Integer, it is interpreted as a 32-bit
	 or 64-bit address.  If it is a CObject, its address is
	 stored."

	<category: 'accessing'>
	anObject isInteger 
	    ifTrue: 
		[^self 
		    at: 0
		    put: anObject
		    type: CLong cObjStoredType].
	self 
	    at: 0
	    put: anObject address
	    type: CLong cObjStoredType
    ]
]



CPtr subclass: CString [
    
    <category: 'Language-C interface'>
    <comment: 'Technically, CString is really a pointer to CChar.  However, it can be
very useful as a distinct datatype because it is a separate datatype
in Smalltalk, so we allow developers to express their semantics more
precisely by using a more descriptive type.

Note that like CChar is a pointer to char, CString is actually a *pointer*
to string: a char ** in C terms.  If you need to take a String out of a
char *, use CChar>>#asString.

In general, I behave like a cross between an array of characters and a pointer
to a character.  I provide the protocol for both data types.  My #value
method returns a Smalltalk String, as you would expect for a scalar datatype.
'>

    CString class >> value: anObject [
	"Answer a newly allocated CObject containing the passed value,
	 anObject. Remember to call #addToBeFinalized if you want the
	 CObject to be automatically freed"

	<category: 'instance creation'>
	| cObject |
	cObject := self type new.
	cObject value: anObject.
	^cObject
    ]

    CString class >> type [
	"Answer a CType for the receiver---for example, CByteType if
	 the receiver is CByte."

	<category: 'instance creation'>
	^CStringType
    ]

    CString class >> cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'accessing'>
	^8
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'accessing'>
	^8
    ]

    value [
	"Answer the value the receiver is pointing to. The exact returned
	 value depends on the receiver's class"

	<category: 'accessing'>
	^self at: 0 type: 8
    ]

    value: aValue [
	"Set the receiver to point to the value, aValue. The exact meaning
	 of aValue depends on the receiver's class"

	<category: 'accessing'>
	self 
	    at: 0
	    put: aValue
	    type: 8
    ]
]



CUChar subclass: CByte [
    
    <category: 'Language-C interface'>
    <comment: 'You know what a byte is, don''t you?!?'>

    CByte class >> cObjStoredType [
	"Nothing special in the default case - answer a CType for the receiver"

	<category: 'conversion'>
	^self type
    ]

    CByte class >> type [
	"Answer a CType for the receiver"

	<category: 'conversion'>
	^CByteType
    ]

    cObjStoredType [
	"Nothing special in the default case - answer the receiver's CType"

	<category: 'accessing'>
	^self type
    ]

    value [
	"Answer the value the receiver is pointing to. The returned value
	 is a SmallInteger"

	<category: 'accessing'>
	^(self at: 0 type: super cObjStoredType) value
    ]

    value: aValue [
	"Set the receiver to point to the value, aValue (a SmallInteger)."

	<category: 'accessing'>
	self 
	    at: 0
	    put: (Character value: aValue)
	    type: super cObjStoredType
    ]
]



CByte subclass: CBoolean [
    
    <category: 'Language-C interface'>
    <comment: 'I return true if a byte is not zero, false otherwise.'>

    value [
	"Get the receiver's value - answer true if it is != 0, false if it is 0."

	<category: 'accessing'>
	^super value > 0
    ]

    value: aBoolean [
	"Set the receiver's value - it's the same as for CBytes, but we
	 get a Boolean, not a Character"

	<category: 'accessing'>
	^super value: aBoolean asCBooleanValue
    ]
]



"Forward define CType instances"



Eval [
    Smalltalk at: #CCharType put: nil.
    Smalltalk at: #CStringType put: nil
]



UndefinedObject extend [

    free [
	"Do nothing, a NULL pointer can be safely freed."

	<category: 'CObject interoperability'>
	
    ]

    narrow [
	"Return the receiver: a NULL pointer is always nil, whatever its type."

	<category: 'CObject interoperability'>
	^self
    ]

]

