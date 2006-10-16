"======================================================================
|
|   String Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2006
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


CharacterArray variable: #character subclass: #String
		  instanceVariableNames: ''
		  classVariableNames: ''
		  poolDictionaries: ''
		  category: 'Collections-Text'
!

String comment: 
'My instances represent 8-bit character strings.  Being a very common
case, they are particularly optimized.

Note that, if you care about multilingualization, you should treat
String only as an encoded representation of a UnicodeString.  The I18N
package adds more Unicode-friendliness to the system so that encoding
and decoding is performed automatically in more cases.  In that case,
String represents a case when the encoding is either unknown, irrelevant,
or assumed to be the system default.'!


!String methodsFor: 'basic'!

= aString
    "Answer whether the receiver's items match those in aCollection"

    aString isString ifFalse: [ ^super = aString ].

    "Also a String, no need to check the encoding."
    self size = aString size ifFalse: [ ^false ].
    self hash == aString hash ifFalse: [ ^false ].
    1 to: self size do: [ :i |
        (self at: i) == (aString at: i) ifFalse: [ ^false ]
    ].
    ^true
!

, aString
    "Answer a new instance of an ArrayedCollection containing all the elements
     in the receiver, followed by all the elements in aSequenceableCollection"
    | newString mySize |
    aString class == String ifFalse: [ ^super, aString ].

    newString := self copyEmpty: ((mySize := self size) + aString size).
    newString primReplaceFrom: 1 to: mySize with: self startingAt: 1.
    newString primReplaceFrom: mySize + 1 to: newString size
	      with: aString startingAt: 1.
    ^newString
! !


!String methodsFor: 'storing'!

storeOn: aStream
    "Print Smalltalk code compiling to the receiver on aStream"
    self printOn: aStream
! !


!String methodsFor: 'converting'!

asByteArray
    "Return the receiver, converted to a ByteArray of ASCII values"
    | byteArray size |
    size := self size.
    byteArray := ByteArray new: size.
    byteArray replaceFrom: 1 to: size withString: self startingAt: 1.
    ^byteArray
!

asSymbol
    "Returns the symbol corresponding to the receiver"
    ^Symbol intern: self
!

asString
    "But I already am a String!  Really!"
    ^self
! !



!String methodsFor: 'testing functionality'!

isString
    ^true
! !


!String methodsFor: 'multibyte encodings'!

numberOfCharacters
    "Answer the number of Unicode characters in the receiver.  This is
     not defined for String unless you load the I18N package."
    self shouldNotImplement! !


!String methodsFor: 'printing'!

displayString
    "Answer a String representing the receiver. For most objects
     this is simply its #printString, but for CharacterArrays and characters,
     superfluous dollars or extra pair of quotes are stripped."
    ^self
!

displayOn: aStream
    "Print a representation of the receiver on aStream. Unlike
     #printOn:, this method strips extra quotes."
    aStream nextPutAll: self
!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    aStream nextPut: $'.
    self do:
    	[ :char | char == $' ifTrue: [ aStream nextPut: char ].
	    	  aStream nextPut: char ].
    self isReadOnly ifFalse: [ aStream nextPutAll: ''' copy' ]
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPut: $'.
    self do:
    	[ :char | char == $' ifTrue: [ aStream nextPut: char ].
	    	  aStream nextPut: char ].
    aStream nextPut: $'
! !


!String methodsFor: 'accessing'!

byteAt: index
    "Answer the ascii value of index-th character variable of the receiver"
    ^self valueAt: index
!
 
byteAt: index put: value
    "Store (Character value: value) in the index-th indexed instance variable
     of the receiver"
    ^self valueAt: index put: value
! !

