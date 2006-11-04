"======================================================================
|
|   C object basic data type definitions.
| 
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2004
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

Object variableWordSubclass: #CObject
	    instanceVariableNames: 'type '
	    classVariableNames: ''
	    poolDictionaries: 'CSymbols'
	    category: 'Language-C interface'!

CObject variableWordSubclass: #CScalar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'!

CScalar variableWordSubclass: #CSmalltalk
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CLong
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CULong
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CInt
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CUInt
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CShort
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CUShort
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CChar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CUChar
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CFloat
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CDouble
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CScalar variableWordSubclass: #CLongDouble
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CObject variableWordSubclass: #CAggregate
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'!

CAggregate variableWordSubclass: #CArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CAggregate variableWordSubclass: #CPtr
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CPtr variableWordSubclass: #CString
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Language-C interface'.

CUChar variableWordSubclass: #CByte
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-C interface'!

CByte variableWordSubclass: #CBoolean
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-C interface'!

CObject comment:
'I am not part of the standard Smalltalk kernel class hierarchy.
My instances contain values that are not interpreted by the Smalltalk 
system; they frequently hold "pointers" to data outside of the Smalltalk
environment.  The C callout mechanism allows my instances to be transformed
into their corresponding C values for use in external routines.'.

CString comment:
'Technically, CString is really a pointer to CChar.  However, it can be
very useful as a distinct datatype because it is a separate datatype
in Smalltalk, so we allow developers to express their semantics more
precisely by using a more descriptive type.

Note that like CChar is a pointer to char, CString is actually a *pointer*
to string: a char ** in C terms.  If you need to take a String out of a
char *, use CChar>>#asString.

In general, I behave like a cross between an array of characters and a pointer
to a character.  I provide the protocol for both data types.  My #value
method returns a Smalltalk String, as you would expect for a scalar datatype.
'!

CByte comment: 'You''re a marine.
You adapt -- you improvise -- you overcome

    	    	    	- Gunnery Sgt. Thomas Highway
    	    	    	  Heartbreak Ridge'!

CBoolean comment: 'I return true if a byte is not zero, false otherwise.'!



!CObject class methodsFor: 'instance creation'!

address: anInteger
    "Answer a new object pointing to the passed address, anInteger"
    ^(self basicNew: 1)
	address: anInteger;
	type: self scalarIndex
!

new
    "Answer a new object pointing to NULL."
    ^self address: 0
! !


!CObject class methodsFor: 'conversion'!

scalarIndex
    "Nothing special in the default case - answer a CType for the receiver"
    ^CType cObjectType: self
!

type
    "Nothing special in the default case - answer a CType for the receiver"
    ^CType cObjectType: self
! !


!CObject methodsFor: 'finalization'!

finalize
    "To make the VM call this, use #addToBeFinalized. It frees
     automatically any memory pointed to by the CObject. It is not
     automatically enabled because big trouble hits you if you use
     #free and the receiver doesn't point to the base of a malloc-ed
     area."
    self free
! !


!CObject methodsFor: 'pointer-like behavior'!

addressAt: anIndex
    "Return a new CObject of the element type,
     corresponding to an object that is anIndex places past
     the receiver (remember that CObjects represent pointers
     and that C pointers behave like arrays).
     anIndex is zero-based, just like with all other C-style accessing."
    | dereferencedType |
    dereferencedType := self dereferencedType.
    ^self at: (anIndex * dereferencedType sizeof) type: dereferencedType
!

at: anIndex
    "Dereference a pointer that is anIndex places past
     the receiver (remember that CObjects represent pointers
     and that C pointers behave like arrays).  anIndex is
     zero-based, just like with all other C-style accessing."
    | dereferencedType offset valueType |
    dereferencedType := self dereferencedType.
    offset := anIndex * dereferencedType sizeof.
    valueType := dereferencedType valueType.
    ^valueType isInteger
        ifTrue: [ self at: offset type: valueType ]
        ifFalse: [ (self at: offset type: dereferencedType) value ]
!

at: anIndex put: aValue
    "Store anIndex places past the receiver the passed Smalltalk
     object or CObject `aValue'; if it is a CObject is dereferenced:
     that is, this method is equivalent either to cobj[anIndex]=aValue
     or cobj[anIndex]=*aValue.  anIndex is zero-based, just like with
     all other C-style accessing.

     In both cases, aValue should be of the element type or of the
     corresponding Smalltalk type (that is, a String is ok for an
     array of CStrings) to avoid typing problems which however will
     not be signaled because C is untyped."
    | dereferencedType offset valueType |
    dereferencedType := self dereferencedType.
    offset := anIndex * dereferencedType sizeof.
    valueType := dereferencedType valueType.
    ^valueType isInteger
        ifTrue: [ self at: offset put: aValue type: valueType ]
        ifFalse: [ (self at: offset type: dereferencedType) value: aValue ]
!

incr
    "Adjust the pointer by sizeof(dereferencedType) bytes up (i.e. ++receiver)"
    self adjPtrBy: self dereferencedType sizeof 
!

decr
    "Adjust the pointer by sizeof(dereferencedType) bytes down (i.e. --receiver)"
    self adjPtrBy: self dereferencedType sizeof negated
!

incrBy: anInteger
    "Adjust the pointer by anInteger elements up (i.e. receiver += anInteger)"
    self adjPtrBy: self dereferencedType sizeof * anInteger
!

decrBy: anInteger
    "Adjust the pointer by anInteger elements down (i.e. receiver -= anInteger)"
    self adjPtrBy: self dereferencedType sizeof * anInteger negated
!

+ anInteger
    "Return another instance of the receiver's class which points at
    &receiver[anInteger] (or, if you prefer, what `receiver +
    anInteger' does in C)."

    | dereferencedType |
    dereferencedType := self dereferencedType.
    ^self at: (anInteger * dereferencedType sizeof) type: self type
!

- intOrPtr
    "If intOrPtr is an integer, return another instance of the receiver's
     class pointing at &receiver[-anInteger] (or, if you prefer, what
     `receiver - anInteger' does in C).
     If it is the same class as the receiver, return the difference in
     chars, i.e. in bytes, between the two pointed addresses (or, if
     you prefer, what `receiver - anotherCharPtr' does in C)"
    | dereferencedType |
    intOrPtr isInteger ifTrue: [ ^self + intOrPtr negated ].

    dereferencedType := self dereferencedType.
    intOrPtr dereferencedType = dereferencedType ifFalse: [
	^SystemExceptions.InvalidArgument
	    signalOn: intOrPtr
	    reason: 'arithmetic between pointers to different types' ].

    ^((self addressAt: 0) address -
	(intOrPtr addressAt: 0) address) // dereferencedType sizeof
! !


!CObject methodsFor: 'conversion'!

castTo: aType
    "Answer another CObject, pointing to the same address as the receiver,
     but belonging to the aType CType."
    ^self at: 0 type: aType
!

narrow
    "This method is called on CObjects returned by a C call-out whose
     return type is specified as a CType; it mostly allows one to
     change the class of the returned CObject.  By default it does
     nothing, and that's why it is not called when #cObject is used
     to specify the return type."
!

scalarIndex
    "Nothing special in the default case - answer the receiver's CType"
    ^type
!

type
    "Answer a CType for the receiver"
    ^type
! !


!CObject methodsFor: 'accessing'!

address
    "Answer the address the receiver is pointing to."
    ^self basicAt: self basicSize
!

address: anInteger
    "Set the receiver to point to the passed address, anInteger"
    self basicAt: self basicSize put: anInteger
!

printOn: aStream
    "Print a representation of the receiver"
    aStream
	print: self class;
	nextPut: $(;
	nextPutAll: (self address printStringRadix: 16);
	nextPut: $)
!

type: aCType
    "Set the receiver's type to aCType."
    type := aCType
! !


!CObject methodsFor: 'private'!

adjPtrBy: byteOffset
    self address: self address + byteOffset
!

dereferencedType
    ^self type
!

cObjStoredType
    "Private - Provide a conversion from a CObject to a Smalltalk object
     to be stored by #at:put:"
    ^nil
!

cObjStoredValue
    "Private - Provide a conversion from a CObject to a Smalltalk object
     to be stored by #at:put:"
    ^self value
! !


!CScalar class methodsFor: 'instance creation'!

value: anObject
    "Answer a newly allocated CObject containing the passed value,
     anObject. Remember to call #addToBeFinalized if you want the
     CObject to be automatically freed"
    | cObject |
    cObject := self type new.
    cObject value: anObject.
    ^cObject
!

type
    "Answer a CType for the receiver - for example, CByteType if
     the receiver is CByte."
    ^self environment at: (self name, 'Type') asGlobalKey
! !


!CScalar methodsFor: 'accessing'!

cObjStoredType
    "Private - Provide a conversion from a CObject to a Smalltalk object
     to be stored by #at:put:"
    ^self scalarIndex
!

value
    "Answer the value the receiver is pointing to. The exact returned
     value depends on the receiver's class"
    ^self at: 0 type: self scalarIndex
!

value: aValue
    "Set the receiver to point to the value, aValue. The exact meaning
     of aValue depends on the receiver's class"
    self at: 0 put: aValue type: self scalarIndex
! !



!CSmalltalk class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CPtrSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CPtrSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^9
! !
    

!CSmalltalk methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CPtrSize
!

alignof
    "Answer the receiver's required aligment"
    ^CPtrSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^9
! !



!CLong class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CLongSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CLongSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^4
! !
    

!CLong methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CLongSize
!

alignof
    "Answer the receiver's required aligment"
    ^CLongSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^4
! !



!CULong class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CLongSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CLongSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^5
! !
    
!CULong methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CLongSize
!

alignof
    "Answer the receiver's required aligment"
    ^CLongSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^5
! !


!CInt class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CIntSize
!

alignof
    "Answer the receiver's required aligment"
    ^CIntSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^10
! !
    

!CInt methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CIntSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CIntSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^10
! !



!CUInt class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CIntSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CIntSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^11
! !
    


!CUInt methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CIntSize
!

alignof
    "Answer the receiver's required aligment"
    ^CIntSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^11
! !




!CShort class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CShortSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CShortSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^2
! !
    


!CShort methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CShortSize
!

alignof
    "Answer the receiver's required aligment"
    ^CShortSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^2
! !



!CUShort class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CShortSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CShortSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^3
! !
    

!CUShort methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CShortSize
!

alignof
    "Answer the receiver's required aligment"
    ^CShortSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^3
! !




!CChar class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^1
!

alignof
    "Answer the receiver's instances required aligment"
    ^1
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^0
! !
    

!CChar methodsFor: 'conversion'!

asByteArray: size
    "Convert size bytes pointed to by the receiver to a String"
    ^ByteArray fromCData: self size: size!

asString
    "Convert the data pointed to by the receiver, up to the first NULL byte,
     to a String"
    ^String fromCData: self!

asString: size
    "Convert size bytes pointed to by the receiver to a String"
    ^String fromCData: self size: size! !

!CChar methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^1
!

alignof
    "Answer the receiver's required aligment"
    ^1
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^0
! !





!CUChar class methodsFor: 'getting info'!

sizeof
    "Answer the receiver's instances size"
    ^1
!

alignof
    "Answer the receiver's instances required aligment"
    ^1
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^1
! !

!CUChar methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^1
!

alignof
    "Answer the receiver's required aligment"
    ^1
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^1
! !




!CFloat class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CFloatSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CFloatSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^6
! !
    
!CFloat methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CFloatSize
!

alignof
    "Answer the receiver's required aligment"
    ^CFloatSize
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^6
! !




!CDouble class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CDoubleSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CDoubleAlignment
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^7
! !
    
!CDouble methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CDoubleSize
!

alignof
    "Answer the receiver's required aligment"
    ^CDoubleAlignment
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^7
! !


!CLongDouble class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    ^CLongDoubleSize
!

alignof
    "Answer the receiver's instances required aligment"
    ^CLongDoubleAlignment
!

scalarIndex
    "Private - Answer an index referring to the receiver's instances scalar type"
    ^12
! !
    
!CLongDouble methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CLongDoubleSize
!

alignof
    "Answer the receiver's required aligment"
    ^CLongDoubleAlignment
!

scalarIndex
    "Private - Answer an index referring to the receiver's scalar type"
    ^12
! !


!CAggregate class methodsFor: 'accessing'!

sizeof
    "Answer the receiver's instances size"
    "This is the closest possible guess for CArrays"
    ^CPtrSize
!

alignof
    "Answer the receiver's instances required aligment"
    "This is the closest possible guess for CArrays"
    ^CPtrSize
! !



!CAggregate methodsFor: 'accessing'!

elementType
    "Answer the type over which the receiver is constructed."
    ^self type elementType
! !



!CArray methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^self type numberOfElements * self elementType sizeof
!

alignof
    "Answer the receiver's required aligment"
    ^self elementType alignof
! !

!CArray methodsFor: 'private'!

dereferencedType
    ^self type elementType
!

cObjStoredType
    "Private - Provide a conversion from a CObject to a Smalltalk object
     to be stored by #at:put:"

    "If they want to store the receiver with #at:put:, they store the
     address (of the first character) without dereferencing the pointer."
    ^CLong scalarIndex
!

cObjStoredValue
    "Private - Provide a conversion from a CObject to a Smalltalk object
     to be stored by #at:put:"

    "If they want to store the receiver with #at:put:, they
     store the address without dereferencing the pointer."
    ^self address
! !



!CPtr methodsFor: 'accessing'!

sizeof
    "Answer the receiver's size"
    ^CPtrSize
!

alignof
    "Answer the receiver's required aligment"
    ^CPtrSize
!

value
    "Answer the address of the location pointed to by the receiver."
    ^self derefAt: 0 type: self type elementType
!

value: anObject
    "Set the address of the location pointed to by the receiver
     to anObject, which can be either an Integer or a CObject.
     if anObject is an Integer, it is interpreted as a 32-bit
     or 64-bit address.  If it is a CObject, its address is
     stored."
    anObject isInteger
        ifTrue: [ ^self at: 0 put: anObject type: CLong scalarIndex ].

    self at: 0 put: anObject address type: CLong scalarIndex
! !


"Forward define CType instances"
Smalltalk at: #CCharType put: nil!
Smalltalk at: #CStringType put: nil!


!CString class methodsFor: 'instance creation'!

value: anObject
    "Answer a newly allocated CObject containing the passed value,
     anObject. Remember to call #addToBeFinalized if you want the
     CObject to be automatically freed"
    | cObject |
    cObject := self type new.
    cObject value: anObject.
    ^cObject
!

type
    "Answer a CType for the receiver - for example, CByteType if
     the receiver is CByte."
    ^CStringType
! !


!CString methodsFor: 'accessing'!

cObjStoredType
    "Private - Provide a conversion from a CObject to a Smalltalk object
     to be stored by #at:put:"
    ^8
!

value
    "Answer the value the receiver is pointing to. The exact returned
     value depends on the receiver's class"
    ^self at: 0 type: 8
!

value: aValue
    "Set the receiver to point to the value, aValue. The exact meaning
     of aValue depends on the receiver's class"
    self at: 0 put: aValue type: 8
! !




!CByte class methodsFor: 'conversion'!

scalarIndex
    "Nothing special in the default case - answer a CType for the receiver"
    ^CType cObjectType: self
!

type
    "Nothing special in the default case - answer a CType for the receiver"
    ^CType cObjectType: self
! !


!CByte methodsFor: 'accessing'!

scalarIndex
    "Nothing special in the default case - answer the receiver's CType"
    ^type
!

type
    "Answer a CType for the receiver"
    ^type
!

value
    "Answer the value the receiver is pointing to. The returned value
     is a SmallInteger"
    ^(self at: 0 type: super scalarIndex) value
!

value: aValue
    "Set the receiver to point to the value, aValue (a SmallInteger)."
    self at: 0 put: aValue asCharacter type: super scalarIndex
! !




!CBoolean methodsFor: 'accessing'!

value
    "Get the receiver's value - answer true if it is != 0, false if it is 0."
    ^super value > 0
!

value: aBoolean
    "Set the receiver's value - it's the same as for CBytes, but we
     get a Boolean, not a Character"
    ^super value: aBoolean asCBooleanValue
! !



!UndefinedObject methodsFor: 'CObject interoperability'!

free
    "Do nothing, a NULL pointer can be safely freed."
!

narrow
    "Return the receiver: a NULL pointer is always nil, whatever its type."
    ^self
! !
