"======================================================================
|
|   String Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001
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
		  category: 'Language-Data types'
!

String comment: 
'My instances represent ASCII string data types.  Being a very common
case, they are particularly optimized.' !


!String class methodsFor: 'basic'!

= aString
    "Answer whether the receiver's items match those in aCollection"
    | newString mySize |

    self class == aString class ifFalse: [^false].
    self size = aString size ifFalse: [^false].
    self hash == aString hash ifFalse: [^false].

    1 to: self size do: [ :i |
	(self at: i) == (aString at: i) ifFalse: [^false]
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
    self printOn: aStream.
    self isReadOnly ifFalse: [ aStream nextPutAll: ''' copy' ]
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

