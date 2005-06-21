"======================================================================
|
|   Base class definition for C data type description objects.
| 
|
 ======================================================================"



"======================================================================
|
| Copyright 1990,91,92,94,95,99,2000,2001
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


Object subclass: #CType
       instanceVariableNames: 'cObjectType'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
! 

CType comment: 'I am not part of the standard Smalltalk kernel class hierarchy.
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
elements.'!

CType subclass: #CScalarCType
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
! 

CScalarCType subclass: #CStringCType
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
! 

CType subclass: #CPtrCType
       instanceVariableNames: 'elementType'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
! 

CPtrCType subclass: #CArrayCType
       instanceVariableNames: 'numElements'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'
! 



!CType class methodsFor: 'C instance creation'!

cObjectType: aCObjectSubclass
    "Create a new CType for the given subclass of CObject"
    ^self basicNew init: aCObjectSubclass
! !


!CType methodsFor: 'C instance creation'!

new
    "Allocate a new CObject with the type (class) identified by the receiver.
    It is the caller's responsibility to free the memory allocated for it."
    ^CObject alloc: self sizeof type: self
!

address: cObjOrInt
    "Create a new CObject with the type (class) identified by the receiver,
    pointing to the given address (identified by an Integer or CObject)."
    ^(cObjectType basicNew: 1)
	type: self;
	address: (cObjOrInt isInteger
	    ifTrue: [ cObjOrInt ]
	    ifFalse: [ cObjOrInt address ]);
	yourself
! !



!CType methodsFor: 'accessing'!

arrayType: size
    "Answer a CArrayCType which represents an array with the given size
     of CObjects whose type is in turn represented by the receiver"
    ^CArrayCType elementType: self numberOfElements: size
!

ptrType
    "Answer a CPtrCType which represents a pointer to CObjects whose
     type is in turn represented by the receiver"
    ^CPtrCType elementType: self
! ! 


!CType methodsFor: 'accessing'!

cObjectType
    "Answer the CObject subclass whose instance is created when new is sent
     to the receiver"
    ^cObjectType
! 

sizeof
    "Answer the size of the receiver's instances"
    ^cObjectType sizeof
!

alignof
    "Answer the size of the receiver's instances"
    ^cObjectType alignof
!

valueType
    "valueType is used as a means to communicate to the interpreter the 
    underlying type of the data.  For anything but scalars, it's just 'self' "
    ^self
! !


!CType methodsFor: 'storing'!

storeOn: aStream
    "Store Smalltalk code that compiles to the receiver"
    aStream
	nextPut: $(;
	print: self class;
	nextPutAll: ' cObjectType: ';
	print: cObjectType;
	nextPut: $)
! !


!CType methodsFor: 'private'!

init: aCObjectClass
    "Initialize the receiver's instance variablers"
    cObjectType := aCObjectClass
! !



!CScalarCType methodsFor: 'storing'!

storeOn: aStream
    "Store Smalltalk code that compiles to the receiver"
    aStream
	print: cObjectType;
	nextPutAll: 'Type'
! !

!CScalarCType methodsFor: 'accessing'!

valueType
    "valueType is used as a means to communicate to the interpreter the 
    underlying type of the data.  For scalars, it is supplied by the
    CObject subclass."
    ^cObjectType scalarIndex
! !



!CStringCType methodsFor: 'accessing'!

elementType
    "Answer the type of the elements in the receiver's instances"
    ^CCharType
! !



!CPtrCType class methodsFor: 'instance creation'!

elementType: aCType
    "Answer a new instance of CPtrCType that maps pointers to the given CType"
    ^self new init: CPtr; elementType: aCType
! !


!CPtrCType methodsFor: 'accessing'!

elementType
    "Answer the type of the elements in the receiver's instances"
    ^elementType
!

new: size
    "Allocate space for `size' objects like those that the receiver points
    to, and with the type (class) identified by the receiver.
    It is the caller's responsibility to free the memory allocated for it."
    ^CObject alloc: elementType sizeof * size type: self
! !

!CPtrCType methodsFor: 'private'!

elementType: aCType
    "Initialize the receiver's instance variables"
    elementType := aCType.
! !



!CArrayCType class methodsFor: 'instance creation'!

elementType: aCType
    self shouldNotImplement
!

elementType: aCType numberOfElements: anInteger
    "Answer a new instance of CPtrCType that maps an array whose elements
    are of the given CType, and whose size is exactly anInteger elements
    (of course, anInteger only matters for allocation, not for access, since
    no out-of-bounds protection is provided for C objects)."
    ^self new
        init: CArray;
        elementType: aCType;
        numberOfElements: anInteger
! !


!CArrayCType methodsFor: 'accessing'!

sizeof
    "Answer the size of the receiver's instances"
    ^elementType sizeof * numElements
!

alignof
    "Answer the alignment of the receiver's instances"
    ^elementType alignof
!

numberOfElements
    "Answer the number of elements in the receiver's instances"
    ^numElements
! !

!CArrayCType methodsFor: 'private'!

numberOfElements: anInteger
    "Initialize the receiver's instance variables"
    numElements := anInteger.
! !


Smalltalk at: #CCharType	put: (CScalarCType cObjectType: CChar).
Smalltalk at: #CUCharType	put: (CScalarCType cObjectType: CUChar).
Smalltalk at: #CShortType	put: (CScalarCType cObjectType: CShort).
Smalltalk at: #CUShortType	put: (CScalarCType cObjectType: CUShort).
Smalltalk at: #CLongType	put: (CScalarCType cObjectType: CLong).
Smalltalk at: #CULongType	put: (CScalarCType cObjectType: CULong).
Smalltalk at: #CIntType		put: (CScalarCType cObjectType: CInt).
Smalltalk at: #CUIntType	put: (CScalarCType cObjectType: CUInt).
Smalltalk at: #CSmalltalkType	put: (CScalarCType cObjectType: CSmalltalk).
Smalltalk at: #CFloatType	put: (CScalarCType cObjectType: CFloat).
Smalltalk at: #CDoubleType	put: (CScalarCType cObjectType: CDouble).
Smalltalk at: #CStringType	put: (CStringCType cObjectType: CString).
Smalltalk at: #CByteType	put: (CScalarCType cObjectType: CByte).
Smalltalk at: #CBooleanType	put: (CScalarCType cObjectType: CBoolean).
!
