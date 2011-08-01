"======================================================================
|
|   Base class definition for C data type description objects.
| 
|
 ======================================================================"

"======================================================================
|
| Copyright 1990,91,92,94,95,99,2000,2001,2007,2008
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



Object subclass: CType [
    | cObjectType |
    
    <category: 'Language-C interface'>
    <comment: 'I am not part of the standard Smalltalk kernel class hierarchy.
I contain type information used by subclasses of CObject, which represents
external C data items.

My only instance variable, cObjectType, is used to hold onto the CObject
subclass that gets created for a given CType.  Used primarily in the C part
of the interpreter because internally it cannot execute methods to get values,
so it has a simple way to access instance variable which holds the desired
subclass.

My subclasses have instances which represent the actual data types; for the
scalar types, there is only one instance created of each, but for the 
aggregate types, there is at least one instance per base type and/or number of
elements.'>

    TypeMap := nil.

    CType class >> initialize [
	"Initialize the receiver's TypeMap"

	<category: 'initialization'>
	Smalltalk at: #CObjectType put: (CType cObjectType: CObject).
	Smalltalk at: #CCharType put: (CScalarCType cObjectType: CChar).
	Smalltalk at: #CUCharType put: (CScalarCType cObjectType: CUChar).
	Smalltalk at: #CShortType put: (CScalarCType cObjectType: CShort).
       Smalltalk at: #CUShortType put: (CScalarCType cObjectType: CUShort).
       Smalltalk at: #CLongType put: (CScalarCType cObjectType: CLong).
       Smalltalk at: #CULongType put: (CScalarCType cObjectType: CULong).
       Smalltalk at: #CLongLongType put: (CScalarCType cObjectType: CLongLong).
       Smalltalk at: #CULongLongType put: (CScalarCType cObjectType: CULongLong).
       Smalltalk at: #CIntType put: (CScalarCType cObjectType: CInt).
       Smalltalk at: #CUIntType put: (CScalarCType cObjectType: CUInt).
       Smalltalk at: #CSmalltalkType put: (CScalarCType cObjectType: CSmalltalk).
	Smalltalk at: #CFloatType put: (CScalarCType cObjectType: CFloat).
	Smalltalk at: #CDoubleType put: (CScalarCType cObjectType: CDouble).
	Smalltalk at: #CLongDoubleType put: (CScalarCType cObjectType: CLongDouble).
	Smalltalk at: #CStringType put: (CStringCType cObjectType: CString).
	Smalltalk at: #CByteType put: (CScalarCType cObjectType: CByte).
	Smalltalk at: #CBooleanType put: (CScalarCType cObjectType: CBoolean).
       TypeMap := (IdentityDictionary new)
                   at: #long put: CLongType;
                   at: #uLong put: CULongType;
                   at: #longLong put: CLongLongType;
                   at: #uLongLong put: CULongLongType;
                   at: #byte put: CByteType;
                   at: #char put: CCharType;
                   at: #uChar put: CUCharType;
		    at: #uchar put: CUCharType;
		    at: #short put: CShortType;
		    at: #uShort put: CUShortType;
		    at: #ushort put: CUShortType;
		    at: #int put: CIntType;
		    at: #uInt put: CUIntType;
		    at: #uint put: CUIntType;
		    at: #float put: CFloatType;
		    at: #double put: CDoubleType;
		    at: #longDouble put: CLongDoubleType;
		    at: #string put: CStringType;
		    at: #smalltalk put: CSmalltalkType;
		    yourself
    ]

    CType class >> cObjectBinding: aCObjectSubclassBinding [
	"Create a new CType for the given subclass of CObject"

	<category: 'C instance creation'>
	^self basicNew init: aCObjectSubclassBinding
    ]

    CType class >> cObjectType: aCObjectSubclass [
	"Create a new CType for the given subclass of CObject"

	<category: 'C instance creation'>
	^self cObjectBinding: aCObjectSubclass binding
    ]

    CType class >> from: type [
	"Private - Pass the size, alignment, and description of CType for aBlock,
	 given the field description in `type' (the second element of each pair)."

	<category: 'C instance creation'>
	| typeInfo typeString |
	type class == Array ifTrue: [^self computeAggregateType: type].

	"must be a type name, either built in or struct, either a Symbol
	 or an Association"
	type isSymbol ifFalse: [^self cObjectBinding: type].
	^TypeMap at: type ifAbsent: [(Namespace current at: type) type]
    ]

    CType class >> computeAggregateType: type [
	"Private - Called by from: for pointers/arrays.
	 Format of type:
	 (#array #int 3) or
	 (#ptr #{FooStruct})
	 "

	<category: 'C instance creation'>
	| structureType |
	structureType := type at: 1.
	structureType == #array ifTrue: [^CArrayCType from: type].
	structureType == #ptr ifTrue: [^CPtrCType from: type]
    ]

    = anObject [
        "Return whether the receiver and anObject are equal."
	<category: 'basic'>
        ^self class == anObject class and: [
            self cObjectType = anObject cObjectType
        ]
    ]

    hash [
        "Return a hash code for the receiver."
	<category: 'basic'>
        ^self class hash bitXor: self cObjectType hash
    ]

    gcNew [
	"Allocate a new CObject with the type (class) identified by the receiver.
	 The object is movable in memory, but on the other hand it is
	 garbage-collected automatically."

	<category: 'C instance creation'>
	^CObject gcAlloc: self sizeof type: self
    ]

    gcNew: anInteger [
	"Allocate a new CObject with room for anInteger C object of the type
	 (class) identified by the receiver.  The object is movable
	 in memory, but on the other hand it is garbage-collected
	 automatically."

	<category: 'C instance creation'>
	^CObject gcAlloc: self sizeof * anInteger type: self
    ]

    new [
	"Allocate a new CObject with the type (class) identified by the receiver.
	 It is the caller's responsibility to free the memory allocated for it."

	<category: 'C instance creation'>
	^CObject alloc: self sizeof type: self
    ]

    new: anInteger [
	"Allocate a new CObject with room for anInteger C objects of the type
	 (class) identified by the receiver.  It is the caller's
	 responsibility to free the memory allocated for it."

	<category: 'accessing'>
	^CObject alloc: self sizeof * anInteger type: self
    ]

    address: cObjOrInt [
	"Create a new CObject with the type (class) identified by the receiver,
	 pointing to the given address (identified by an Integer or CObject)."

	<category: 'C instance creation'>
	^(self cObjectType basicNew: 1)
	    type: self;
	    address: (cObjOrInt isInteger 
			ifTrue: [cObjOrInt]
			ifFalse: [cObjOrInt address]);
	    yourself
    ]

    arrayType: size [
	"Answer a CArrayCType which represents an array with the given size
	 of CObjects whose type is in turn represented by the receiver"

	<category: 'accessing'>
	^CArrayCType elementType: self numberOfElements: size
    ]

    ptrType [
	"Answer a CPtrCType which represents a pointer to CObjects whose
	 type is in turn represented by the receiver"

	<category: 'accessing'>
	^CPtrCType elementType: self
    ]

    cObjectType [
	"Answer the CObject subclass whose instance is created when new is sent
	 to the receiver"

	<category: 'accessing'>
	^cObjectType value
    ]

    sizeof [
	"Answer the size of the receiver's instances"

	<category: 'accessing'>
	^self cObjectType sizeof
    ]

    alignof [
	"Answer the size of the receiver's instances"

	<category: 'accessing'>
	^self cObjectType alignof
    ]

    valueType [
	"valueType is used as a means to communicate to the interpreter the
	 underlying type of the data.  For anything but scalars, it's just 'self'"

	<category: 'accessing'>
	^self
    ]

    storeOn: aStream [
	"Store Smalltalk code that compiles to the receiver"

	<category: 'storing'>
	aStream
	    nextPut: $(;
	    print: self class;
	    nextPutAll: ' cObjectType: ';
	    print: self cObjectType;
	    nextPut: $)
    ]

    init: aCObjectClass [
	"Initialize the receiver's instance variablers"

	<category: 'private'>
	cObjectType := aCObjectClass
    ]
]



CType subclass: CScalarCType [
    
    <category: 'Language-C interface'>
    <comment: nil>

    storeOn: aStream [
	"Store Smalltalk code that compiles to the receiver"

	<category: 'storing'>
	aStream
	    print: self cObjectType;
	    nextPutAll: 'Type'
    ]

    valueType [
	"valueType is used as a means to communicate to the interpreter the
	 underlying type of the data.  For scalars, it is supplied by the
	 CObject subclass."

	<category: 'accessing'>
	^self cObjectType cObjStoredType
    ]
]



CScalarCType subclass: CStringCType [
    
    <category: 'Language-C interface'>
    <comment: nil>

    elementType [
	"Answer the type of the elements in the receiver's instances"

	<category: 'accessing'>
	^CCharType
    ]
]



CType subclass: CPtrCType [
    | elementType |
    
    <category: 'Language-C interface'>
    <comment: nil>

    CPtrCType class >> from: type [
	"Private - Called by computeAggregateType: for pointers"

	<category: 'instance creation'>
	| subType typeInfo |
	subType := type at: 2.
	typeInfo := CType from: subType.
	^self elementType: typeInfo
    ]

    CPtrCType class >> elementType: aCType [
	"Answer a new instance of CPtrCType that maps pointers to the given CType"

	<category: 'instance creation'>
	^(self cObjectType: CPtr)
	    elementType: aCType;
	    yourself
    ]

    = anObject [
        "Return whether the receiver and anObject are equal."
	<category: 'basic'>
        ^super = anObject and: [self elementType = anObject elementType]
    ]

    hash [
        "Return a hash code for the receiver."
	<category: 'basic'>
        ^super hash bitXor: self elementType hash
    ]

    elementType [
	"Answer the type of the elements in the receiver's instances"

	<category: 'accessing'>
	^elementType
    ]

    storeOn: aStream [
	<category: 'storing'>
	aStream
	    nextPutAll: '(CPtrCType elementType: ';
	    store: self elementType;
	    nextPut: $)
    ]

    elementType: aCType [
	"Initialize the receiver's instance variables"

	<category: 'private'>
	elementType := aCType
    ]
]



CPtrCType subclass: CArrayCType [
    | numElements |
    
    <category: 'Language-C interface'>
    <comment: nil>

    CArrayCType class >> from: type [
	"Private - Called by CType>>from: for arrays"

	<category: 'instance creation'>
	| numElts elementType typeInfo |
	elementType := type at: 2.
	numElts := type at: 3.
	typeInfo := CType from: elementType.
	^self elementType: typeInfo numberOfElements: numElts
    ]

    CArrayCType class >> elementType: aCType [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    CArrayCType class >> elementType: aCType numberOfElements: anInteger [
	"Answer a new instance of CPtrCType that maps an array whose elements
	 are of the given CType, and whose size is exactly anInteger elements
	 (of course, anInteger only matters for allocation, not for access, since
	 no out-of-bounds protection is provided for C objects)."

	<category: 'instance creation'>
	^(self cObjectType: CArray)
	    elementType: aCType;
	    numberOfElements: anInteger;
	    yourself
    ]

    = anObject [
        "Return whether the receiver and anObject are equal."
	<category: 'basic'>
        ^super = anObject and: [
            self numberOfElements = anObject numberOfElements]
    ]

    hash [
        "Return a hash code for the receiver."
	<category: 'basic'>
        ^super hash bitXor: self numberOfElements hash
    ]

    storeOn: aStream [
	"As with super."
	<category: 'storing'>
	aStream
	    nextPutAll: '(CArrayCType elementType: ';
	    store: self elementType;
	    nextPutAll: ' numberOfElements: ';
	    store: numElements asInteger;
	    nextPut: $)
    ]

    sizeof [
	"Answer the size of the receiver's instances"

	<category: 'accessing'>
	^elementType sizeof * numElements
    ]

    alignof [
	"Answer the alignment of the receiver's instances"

	<category: 'accessing'>
	^elementType alignof
    ]

    numberOfElements [
	"Answer the number of elements in the receiver's instances"

	<category: 'accessing'>
	^numElements
    ]

    numberOfElements: anInteger [
	"Initialize the receiver's instance variables"

	<category: 'private'>
	numElements := anInteger
    ]
]



Eval [
    CType initialize
]

