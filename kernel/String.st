"======================================================================
|
|   String Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2006,2008,2009
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



CharacterArray subclass: String [
    
    <shape: #character>
    <category: 'Collections-Text'>
    <comment: 'My instances represent 8-bit character strings.  Being a very common
case, they are particularly optimized.

Note that, if you care about multilingualization, you should treat
String only as an encoded representation of a UnicodeString.  The I18N
package adds more Unicode-friendliness to the system so that encoding
and decoding is performed automatically in more cases.  In that case,
String represents a case when the encoding is either unknown, irrelevant,
or assumed to be the system default.'>

    String class >> fromCData: aCObject [
	"Answer a String containing the bytes starting at the location pointed
	 to by aCObject, up to the first NUL character."

	<category: 'instance creation'>
	<primitive: VMpr_String_fromCData>
	^self primitiveFailed
    ]

    String class >> fromCData: aCObject size: anInteger [
	"Answer a String containing anInteger bytes starting at the location pointed
	 to by aCObject"

	<category: 'instance creation'>
	<primitive: VMpr_String_fromCData_size>
	^SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger
    ]

    String class >> isUnicode [
	"Answer false; the receiver stores bytes (i.e. an encoded
	 form), not characters."

	<category: 'multibyte encodings'>
	^false
    ]

    = aCollection [
	"Answer whether the receiver's items match those in aCollection"

	<category: 'basic'>
	<primitive: VMpr_ArrayedCollection_equal>
	^super = aCollection
    ]

    , aString [
	"Answer a new instance of an ArrayedCollection containing all the elements
	 in the receiver, followed by all the elements in aSequenceableCollection"

	<category: 'basic'>
	| newString mySize |
	aString class == String ifFalse: [^super , aString].
	newString := self copyEmpty: (mySize := self size) + aString size.
	newString 
	    replaceFrom: 1
	    to: mySize
	    with: self
	    startingAt: 1.
	newString 
	    replaceFrom: mySize + 1
	    to: newString size
	    with: aString
	    startingAt: 1.
	^newString
    ]

    encoding [
	"Answer the encoding of the receiver.  This is not implemented unless
	 you load the Iconv package."

	<category: 'converting'>
	self notYetImplemented
    ]

    asByteArray [
	"Return the receiver, converted to a ByteArray of ASCII values"

	<category: 'converting'>
	| byteArray size |
	size := self size.
	byteArray := ByteArray new: size.
	byteArray 
	    replaceFrom: 1
	    to: size
	    withString: self
	    startingAt: 1.
	^byteArray
    ]

    asSymbol [
	"Returns the symbol corresponding to the receiver"

	<category: 'converting'>
	^Symbol intern: self
    ]

    asString [
	"But I already am a String!  Really!"

	<category: 'converting'>
	^self
    ]

    isString [
	<category: 'testing functionality'>
	^true
    ]

    displayString [
	"Answer a String representing the receiver. For most objects
	 this is simply its #printString, but for CharacterArrays and characters,
	 superfluous dollars or extra pair of quotes are stripped."

	<category: 'printing'>
	^self
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #printOn:, this method strips extra quotes."

	<category: 'printing'>
	aStream nextPutAll: self
    ]

    isLiteralObject [
	"Answer whether the receiver is expressible as a Smalltalk literal."

	<category: 'printing'>
	^self isReadOnly not
    ]

    storeLiteralOn: aStream [
	"Store a Smalltalk literal compiling to the receiver on aStream"

	<category: 'printing'>
	aStream nextPut: $'.
	self do: 
		[:char | 
		char == $' ifTrue: [aStream nextPut: char].
		aStream nextPut: char].
	aStream nextPut: $'
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'printing'>
	self storeLiteralOn: aStream.
	self isReadOnly ifFalse: [aStream nextPutAll: ' copy']
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream nextPut: $'.
	self do: 
		[:char | 
		char == $' ifTrue: [aStream nextPut: char].
		aStream nextPut: char].
	aStream nextPut: $'
    ]

    byteAt: index [
	"Answer the ascii value of index-th character variable of the receiver"

	<category: 'accessing'>
	^self valueAt: index
    ]

    byteAt: index put: value [
	"Store (Character value: value) in the index-th indexed instance variable
	 of the receiver"

	<category: 'accessing'>
	^self valueAt: index put: value
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'built ins'>
	<primitive: VMpr_String_hash>
	^0
    ]

    similarityTo: aString [
	"Answer a number that denotes the similarity between aString and
	 the receiver.  0 indicates equality, negative numbers indicate
	 some difference.  Implemented as a primitive for speed."

	<category: 'built ins'>
	<primitive: VMpr_String_similarityTo>
	^SystemExceptions.WrongClass signalOn: aString mustBe: String
    ]

    size [
	"Answer the size of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicSize>
	^self primitiveFailed
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

    replaceFrom: start to: stop withByteArray: byteArray startingAt: replaceStart [
	"Replace the characters from start to stop with new characters whose
	 ASCII codes are contained in byteArray, starting at the replaceStart
	 location of byteArray"

	<category: 'built ins'>
	<primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
	^super 
	    replaceFrom: start
	    to: stop
	    with: byteArray asString
	    startingAt: replaceStart
    ]

    replaceFrom: start to: stop with: aString startingAt: replaceStart [
	"Replace the characters from start to stop with new characters whose
	 ASCII codes are contained in aString, starting at the replaceStart
	 location of aString"

	<category: 'built ins'>
	<primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
	^super 
	    replaceFrom: start
	    to: stop
	    with: aString
	    startingAt: replaceStart
    ]

    at: anIndex ifAbsent: aBlock [
	"Answer the index-th indexed instance variable of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAt>
	^self checkIndexableBounds: anIndex ifAbsent: aBlock
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

    asCData [
	"Allocate memory with malloc for a NULL-terminated copy of the
         receiver, and return a pointer to it as a CChar."

	<category: 'CObject'>
	^self asCData: CCharType
    ]

    asCData: aCType [
	"Allocate memory with malloc for a NULL-terminated copy of the
        receiver, and return a pointer to it as a CObject of the given type."

	<category: 'built ins'>
	<primitive: VMpr_String_asCData>
	^self primitiveFailed
    ]
]

