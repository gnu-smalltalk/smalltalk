"======================================================================
|
|   ByteArray Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2008,2009
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



ArrayedCollection subclass: ByteArray [
    
    <shape: #byte>
    <import: CSymbols>
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances are similar to strings in that they are both represented as
a sequence of bytes, but my individual elements are integers, where as
a String''s elements are characters.'>

    ByteArray class >> fromCData: aCObject size: anInteger [
	"Answer a ByteArray containing anInteger bytes starting at the location pointed
	 to by aCObject"

	<category: 'instance creation'>
	<primitive: VMpr_ByteArray_fromCData_size>
	^SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger
    ]

    asString [
	"Answer a String whose character's ASCII codes are the receiver's contents"

	<category: 'converting'>
	| string size |
	size := self size.
	string := String new: size.
	string 
	    replaceFrom: 1
	    to: size
	    withByteArray: self
	    startingAt: 1.
	^string
    ]

    asUnicodeString [
	"Answer a UnicodeString whose character's codes are the receiver's contents.
	 This is not implemented unless you load the I18N package."

	<category: 'converting'>
	self shouldNotImplement
    ]

    isLiteralObject [
	"Answer whether the receiver is expressible as a Smalltalk literal."

	<category: 'storing'>
	^self isReadOnly not
    ]

    storeLiteralOn: aStream [
	"Put a Smalltalk literal evaluating to the receiver on aStream."

	<category: 'storing'>
	self class == ByteArray ifFalse: [ ^super storeLiteralOn: aStream ].
	aStream nextPut: $#.
	aStream nextPut: $[.
	self do: 
		[:elt | 
		aStream
		    print: elt;
		    space].
	aStream nextPut: $]
    ]

    storeOn: aStream [
	"Put Smalltalk code evaluating to the receiver on aStream."

	<category: 'storing'>
	self class == ByteArray ifFalse: [ ^super storeOn: aStream ].
	self storeLiteralOn: aStream.
	self isReadOnly ifFalse: [aStream nextPutAll: ' copy']
    ]

    at: anIndex ifAbsent: aBlock [
	"Answer the index-th indexed instance variable of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAt>
	^self checkIndexableBounds: anIndex ifAbsent: aBlock
    ]

    objectAt: index [
	"Access the Smalltalk object (OOP) at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 9
	    at: index
    ]

    charAt: index [
	"Access the C char at the given index in the receiver. The value is
	 returned as a Smalltalk Character.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 0
	    at: index
    ]

    unsignedCharAt: index [
	"Access the C unsigned char at the given index in the receiver.
	 The value is returned as a Smalltalk Character.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 1
	    at: index
    ]

    ucharAt: index [
	"Access the C unsigned char at the given index in the receiver.
	 The value is returned as a Smalltalk Character.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 1
	    at: index
    ]

    shortAt: index [
	"Access the C short int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 2
	    at: index
    ]

    unsignedShortAt: index [
	"Access the C unsigned short int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 3
	    at: index
    ]

    ushortAt: index [
	"Access the C unsigned short int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 3
	    at: index
    ]

    longAt: index [
	"Access the C long int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 4
	    at: index
    ]

    unsignedLongAt: index [
	"Access the C unsigned long int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 5
	    at: index
    ]

    ulongAt: index [
	"Access the C unsigned long int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 5
	    at: index
    ]

    intAt: index [
	"Access the C int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 10
	    at: index
    ]

    unsignedIntAt: index [
	"Access the C unsigned int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 11
	    at: index
    ]

    uintAt: index [
	"Access the C unsigned int at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 11
	    at: index
    ]

    floatAt: index [
	"Access the C float at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 6
	    at: index
    ]

    doubleAt: index [
	"Access the C double at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 7
	    at: index
    ]

    longDoubleAt: index [
	"Access the C long double at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 12
	    at: index
    ]

    stringAt: index [
	"Access the string pointed by the C `char *' at the given index in the
	 receiver. Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 8
	    at: index
    ]

    objectAt: index put: value [
	"Store a pointer (OOP) to the Smalltalk object identified by `value',
	 at the given index in the receiver.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 9
	    at: index
	    put: value
    ]

    charAt: index put: value [
	"Store as a C char the Smalltalk Character or Integer object
	 identified by `value', at the given index in the receiver, using
	 sizeof(char) bytes - i.e. 1 byte.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 0
	    at: index
	    put: value
    ]

    unsignedCharAt: index put: value [
	"Store as a C char the Smalltalk Character or Integer object
	 identified by `value', at the given index in the receiver, using
	 sizeof(char) bytes - i.e. 1 byte.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 1
	    at: index
	    put: value
    ]

    ucharAt: index put: value [
	"Store as a C char the Smalltalk Character or Integer object
	 identified by `value', at the given index in the receiver, using
	 sizeof(char) bytes - i.e. 1 byte.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 1
	    at: index
	    put: value
    ]

    shortAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(short) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 2
	    at: index
	    put: value
    ]

    unsignedShortAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(short) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 3
	    at: index
	    put: value
    ]

    ushortAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(short) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 3
	    at: index
	    put: value
    ]

    longAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(long) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 4
	    at: index
	    put: value
    ]

    unsignedLongAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(long) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 5
	    at: index
	    put: value
    ]

    ulongAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(long) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 5
	    at: index
	    put: value
    ]

    intAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(int) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 10
	    at: index
	    put: value
    ]

    unsignedIntAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(int) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 11
	    at: index
	    put: value
    ]

    uintAt: index put: value [
	"Store the Smalltalk Integer object identified by `value', at the
	 given index in the receiver, using sizeof(int) bytes.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 11
	    at: index
	    put: value
    ]

    floatAt: index put: value [
	"Store the Smalltalk Float object identified by `value', at the
	 given index in the receiver, writing it like a C float.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 6
	    at: index
	    put: value
    ]

    doubleAt: index put: value [
	"Store the Smalltalk Float object identified by `value', at the
	 given index in the receiver, writing it like a C double.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 7
	    at: index
	    put: value
    ]

    longDoubleAt: index put: value [
	"Store the Smalltalk Float object identified by `value', at the
	 given index in the receiver, writing it like a C double.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 12
	    at: index
	    put: value
    ]

    stringAt: index put: value [
	"Store the Smalltalk String object identified by `value', at the
	 given index in the receiver, writing it like a *FRESHLY
	 ALLOCATED* C string. It is the caller's responsibility to free
	 it if necessary.
	 Indices are 1-based just like for other Smalltalk access."

	<category: 'more advanced accessing'>
	^self 
	    type: 8
	    at: index
	    put: value
    ]

    growSize [
	"Answer the amount by which a ByteArray will grow if necessary.
	 Note - explicit growing of a Collection is a private thing you
	 should not employ"

	<category: 'private'>
	^self size
    ]

    castTo: type [
	"Give access to the receiver as a value with the given CType."

	<category: 'CObject'>
	^(CObject new storage: self) castTo: type
    ]

    type: type at: index [
	"Private - Access in the receiver a value with the given type
         at the given 1-based index."

	<category: 'private'>
	^(CObject new storage: self) at: index - 1 type: type
    ]

    type: type at: index put: value [
	"Private - Write to the receiver a value with the given type
         at the given 1-based index."

	<category: 'private'>
	self isReadOnly ifTrue: [^SystemExceptions.ReadOnlyObject signal].
	^(CObject new storage: self) at: index - 1 put: value type: type
    ]

    byteAt: index [
	"Answer the index-th indexed instance variable of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAt>
	self checkIndexableBounds: index
    ]

    byteAt: index put: value [
	"Store the `value' byte in the index-th indexed instance variable
	 of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAtPut>
	self checkIndexableBounds: index put: value
    ]

    = aCollection [
	"Answer whether the receiver's items match those in aCollection"

	<category: 'basic'>
	<primitive: VMpr_ArrayedCollection_equal>
	^false
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'built ins'>
	<primitive: VMpr_String_hash>
	^0
    ]

    indexOf: anElement startingAt: anIndex ifAbsent: exceptionBlock [
	"Answer the first index > anIndex which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	<primitive: VMpr_ArrayedCollection_indexOfStartingAt>
	"If anIndex is just past the end of the collection, don't raise
	 an error (this is the most generic solution that avoids that
	 #indexOf: fails when the collection is empty."
	^(anIndex < 1 or: [anIndex > (self size + 1)])
	    ifTrue: [self checkIndexableBounds: anIndex]
	    ifFalse: [exceptionBlock value]
    ]

    indexOf: anElement startingAt: anIndex [
	"Answer the first index > anIndex which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	<primitive: VMpr_ArrayedCollection_indexOfStartingAt>
	"If anIndex is just past the end of the collection, don't raise
	 an error (this is the most generic solution that avoids that
	 #indexOf: fails when the collection is empty."
	^(anIndex < 1 or: [anIndex > (self size + 1)])
	    ifTrue: [self checkIndexableBounds: anIndex]
	    ifFalse: [0]
    ]

    replaceFrom: start to: stop withString: aString startingAt: replaceStart [
	"Replace the characters from start to stop with the
	 ASCII codes contained in aString (which, actually, can be
	 any variable byte class), starting at the replaceStart
	 location of aString"

	<category: 'built ins'>
	<primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
	^super 
	    replaceFrom: start
	    to: stop
	    with: aString
	    startingAt: replaceStart
    ]

    replaceFrom: start to: stop with: aByteArray startingAt: replaceStart [
	"Replace the characters from start to stop with the
	 bytes contained in aByteArray (which, actually, can be
	 any variable byte class), starting at the replaceStart
	 location of aByteArray"

	<category: 'built ins'>
	<primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
	^super 
	    replaceFrom: start
	    to: stop
	    with: aByteArray
	    startingAt: replaceStart
    ]

    asCData [
	"Allocate memory with malloc for a copy of the receiver, and return
         a pointer to it as a CByte."

	<category: 'CObject'>
	^self asCData: CByteType
    ]

    asCData: aCType [
	"Allocate memory with malloc for a copy of the receiver, and return
         it converted to a CObject with the given type"

	<category: 'built ins'>
	<primitive: VMpr_ByteArray_asCData>
	^self primitiveFailed
    ]
]

