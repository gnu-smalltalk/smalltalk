"======================================================================
|
|   ByteArray Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006
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


ArrayedCollection variableByteSubclass: #ByteArray
		  instanceVariableNames: ''
		  classVariableNames: ''
		  poolDictionaries: 'CSymbols'
		  category: 'Collections-Sequenceable'
!

ByteArray comment: 
'My instances are similar to strings in that they are both represented as
a sequence of bytes, but my individual elements are integers, where as
a String''s elements are characters.' !



!ByteArray methodsFor: 'converting'!

asString
    "Answer a String whose character's ASCII codes are the receiver's contents"
    | string size |
    size := self size.
    string := String new: size.
    string replaceFrom: 1 to: size withByteArray: self startingAt: 1.
    ^string
!

asUnicodeString
    "Answer a UnicodeString whose character's codes are the receiver's contents.
     This is not implemented unless you load the I18N package."
    self shouldNotImplement
! !



!ByteArray methodsFor: 'more advanced accessing'!

"Note that the types could be given symbolic names and installed in a 
class variable, or could be methods that return the proper values (such as
the priorities for processes)."

objectAt: index 
    "Access the Smalltalk object (OOP) at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 9 at: index size: CPtrSize - 1
!

charAt: index 
    "Access the C char at the given index in the receiver. The value is
     returned as a Smalltalk Character.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 0 at: index size: 0
!

unsignedCharAt: index 
    "Access the C unsigned char at the given index in the receiver.
     The value is returned as a Smalltalk Character.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 1 at: index size: 0
!

ucharAt: index 
    "Access the C unsigned char at the given index in the receiver.
     The value is returned as a Smalltalk Character.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 1 at: index size: 0
!

shortAt: index 
    "Access the C short int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 2 at: index size: CShortSize - 1
!

unsignedShortAt: index 
    "Access the C unsigned short int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 3 at: index size: CShortSize - 1
!

ushortAt: index 
    "Access the C unsigned short int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 3 at: index size: CShortSize - 1
!

longAt: index 
    "Access the C long int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 4 at: index size: CLongSize - 1
!

unsignedLongAt: index 
    "Access the C unsigned long int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 5 at: index size: CLongSize - 1
!

ulongAt: index 
    "Access the C unsigned long int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 5 at: index size: CLongSize - 1
!

intAt: index 
    "Access the C int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 10 at: index size: CIntSize - 1
!

unsignedIntAt: index 
    "Access the C unsigned int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 11 at: index size: CIntSize - 1
!

uintAt: index 
    "Access the C unsigned int at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 11 at: index size: CIntSize - 1
!

floatAt: index 
    "Access the C float at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 6 at: index size: CFloatSize - 1
!

doubleAt: index 
    "Access the C double at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 7 at: index size: CDoubleSize - 1
!

longDoubleAt: index 
    "Access the C long double at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 12 at: index size: CLongDoubleSize - 1
!

stringAt: index 
    "Access the string pointed by the C `char *' at the given index in the
     receiver. Indices are 1-based just like for other Smalltalk access."
    ^self type: 8 at: index size: CPtrSize - 1
! 

"Storing methods"

objectAt: index put: value
    "Store a pointer (OOP) to the Smalltalk object identified by `value',
     at the given index in the receiver.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 9 at: index put: value size: CPtrSize - 1
!

charAt: index put: value
    "Store as a C char the Smalltalk Character or Integer object
     identified by `value', at the given index in the receiver, using
     sizeof(char) bytes - i.e. 1 byte.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 0 at: index put: value size: 0
!

unsignedCharAt: index put: value
    "Store as a C char the Smalltalk Character or Integer object
     identified by `value', at the given index in the receiver, using
     sizeof(char) bytes - i.e. 1 byte.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 1 at: index put: value size: 0
!

ucharAt: index put: value
    "Store as a C char the Smalltalk Character or Integer object
     identified by `value', at the given index in the receiver, using
     sizeof(char) bytes - i.e. 1 byte.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 1 at: index put: value size: 0
!

shortAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(short) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 2 at: index put: value size: CShortSize - 1
!

unsignedShortAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(short) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 3 at: index put: value size: CShortSize - 1
!

ushortAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(short) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 3 at: index put: value size: CShortSize - 1
!

longAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(long) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 4 at: index put: value size: CLongSize - 1
!

unsignedLongAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(long) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 5 at: index put: value size: CLongSize - 1
!

ulongAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(long) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 5 at: index put: value size: CLongSize - 1
!

intAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(int) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 10 at: index put: value size: CIntSize - 1
!

unsignedIntAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(int) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 11 at: index put: value size: CIntSize - 1
!

uintAt: index put: value
    "Store the Smalltalk Integer object identified by `value', at the
     given index in the receiver, using sizeof(int) bytes.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 11 at: index put: value size: CIntSize - 1
!

floatAt: index put: value
    "Store the Smalltalk Float object identified by `value', at the
     given index in the receiver, writing it like a C float.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 6 at: index put: value size: CFloatSize - 1
!

doubleAt: index put: value
    "Store the Smalltalk Float object identified by `value', at the
     given index in the receiver, writing it like a C double.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 7 at: index put: value size: CDoubleSize - 1
!

longDoubleAt: index put: value
    "Store the Smalltalk Float object identified by `value', at the
     given index in the receiver, writing it like a C double.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 12 at: index put: value size: CLongDoubleSize - 1
!

stringAt: index put: value
    "Store the Smalltalk String object identified by `value', at the
     given index in the receiver, writing it like a *FRESHLY
     ALLOCATED* C string. It is the caller's responsibility to free
     it if necessary.
     Indices are 1-based just like for other Smalltalk access."
    ^self type: 8 at: index put: value size: CPtrSize - 1
! !


!ByteArray methodsFor: 'private'!

growSize
    "Answer the amount by which a ByteArray will grow if necessary.
     Note - explicit growing of a Collection is a private thing you
     should not employ"
    ^self size
!

type: type at: index size: size
    "Private - Use Memory class to access in the receiver a value with the
     given type."
    | offset |
    index < 1
       ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    index > (self basicSize - size)
       ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    offset := index + (CLongSize * 2 - 1).		"impl. dependent"
     ^Memory
	 type: type
	 at: (ObjectMemory addressOf: self) + offset
!

type: type at: index put: value size: size
    "Private - Use Memory class to write to the receiver a value with the
     given type."
    | offset |
    self isReadOnly ifTrue: [ ^SystemExceptions.ReadOnlyObject signal ].

    index < 1
       ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    index > (self basicSize - size)
       ifTrue: [ ^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index ].

    offset := index + (CLongSize * 2 - 1).		"impl. dependent"
     ^Memory
	 type: type
	 at: (ObjectMemory addressOf: self) + offset
	 put: value
! !



!ByteArray class methodsFor: 'instance creation'!

fromCData: aCObject size: anInteger
    "Answer a ByteArray containing anInteger bytes starting at the location pointed
     to by aCObject"
    <primitive: VMpr_ByteArray_fromCData_size>
    ^SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger
! !



!ByteArray methodsFor: 'built ins'!

byteAt: index
    "Answer the index-th indexed instance variable of the receiver"
    <primitive: VMpr_Object_basicAt>
    self checkIndexableBounds: index
!

byteAt: index put: value
    "Store the `value' byte in the index-th indexed instance variable
     of the receiver"
    <primitive: VMpr_Object_basicAtPut>

    self checkIndexableBounds: index put: value
!


hash
    "Answer an hash value for the receiver"
    <primitive: VMpr_String_hash>
    ^0
!

replaceFrom: start to: stop withString: aString startingAt: replaceStart
    "Replace the characters from start to stop with the
     ASCII codes contained in aString (which, actually, can be
     any variable byte class), starting at the replaceStart
     location of aString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^super replaceFrom: start to: stop with: aString startingAt: replaceStart
!

replaceFrom: start to: stop with: aByteArray startingAt: replaceStart
    "Replace the characters from start to stop with the
     bytes contained in aByteArray (which, actually, can be
     any variable byte class), starting at the replaceStart
     location of aByteArray"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^super replaceFrom: start to: stop with: aByteArray startingAt: replaceStart
!

primReplaceFrom: start to: stop with: aByteArray startingAt: srcIndex
    "Private - Replace the characters from start to stop with the
     ASCII codes contained in aString (which, actually, can be
     any variable byte class), starting at the srcIndex location of
     aString"
    <primitive: VMpr_ByteArray_replaceFromToWithStartingAt>
    ^self primitiveFailed
!

asCData: aCType
    "Convert the receiver to a CObject with the given type"
    <primitive: VMpr_ByteArray_asCData>
    ^self primitiveFailed
! !

