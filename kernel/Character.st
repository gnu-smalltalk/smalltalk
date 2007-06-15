"======================================================================
|
|   Character Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2006
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

Magnitude subclass: #Character 
	  instanceVariableNames: 'codePoint'
	  classVariableNames: 'Table UpperTable LowerTable'
	  poolDictionaries: ''
	  category: 'Language-Data types'
!

Character comment: 
'My instances represent the 256 characters of the character set.  I provide
messages to translate between integers and character objects, and provide
names for some of the common unprintable characters.

Character is always used (mostly for performance reasons) when referring
to characters whose code point is between 0 and 127.  Above 127, instead,
more care is needed: Character refers to bytes that are used as part of
encoding of a character, while UnicodeCharacter refers to the character
itself.' !


!Character class methodsFor: 'testing'!

isImmediate
    "Answer whether, if x is an instance of the receiver, x copy == x"
    ^true
! !


!Character class methodsFor: 'initializing lookup tables'!

initialize
    "Initialize the lookup table which is used to make case and digit-to-char
     conversions faster.
     Indices in Table are ASCII values incremented by one. Indices 1-256
     classify chars (0 = nothing special, 2 = separator, 48 = digit,
     55 = uppercase, 3 = lowercase), indices 257-512 map to lowercase chars,
     indices 513-768 map to uppercase chars."

    Table := ByteArray new: 768.
    UpperTable := ByteArray new: 256.
    LowerTable := ByteArray new: 256.

    1 to: 256 do: [ :value |
	UpperTable at: value put: value - 1.
	LowerTable at: value put: value - 1.

	(value between: 49 and: 58)
	    ifTrue: [ Table at: value put: 48 ].

	(value between: 66 and: 91)
	    ifTrue: [ Table at: value put: 55. LowerTable at: value put: value + 31 ].

	(value between: 98 and: 123)
	    ifTrue: [ Table at: value put: 3. UpperTable at: value put: value - 33 ]
    ].
    Table
	at: Character space	value + 1 put: 2;
	at: Character cr	value + 1 put: 2;
	at: Character tab	value + 1 put: 2;
	at: Character nl	value + 1 put: 2;
	at: Character newPage	value + 1 put: 2;
	at: $.			value + 1 put: 4;
	at: $,			value + 1 put: 4;
	at: $:			value + 1 put: 4;
	at: $;			value + 1 put: 4;
	at: $!			value + 1 put: 4;
	at: $?			value + 1 put: 4.
! !


!Character class methodsFor: 'built ins'!

codePoint: anInteger
    "Returns the character object, possibly an UnicodeCharacter, corresponding
     to anInteger.  Error if anInteger is not an integer, or not in 0..16r10FFFF."
     <primitive: VMpr_UnicodeCharacter_create>

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ]
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 16r10FFFF ]
!

asciiValue: anInteger
    "Returns the character object corresponding to anInteger.  Error if
     anInteger is not an integer, or not in 0..127."

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ].

    ^(anInteger between: 0 and: 127)
	ifTrue: [ self value: anInteger ]
	ifFalse: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 127 ]
!

value: anInteger
    "Returns the character object corresponding to anInteger.  Error if
     anInteger is not an integer, or not in 0..255."
     <primitive: VMpr_Character_create>

    anInteger isInteger
	ifFalse: [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ]
	ifTrue: [ SystemExceptions.ArgumentOutOfRange signalOn: anInteger mustBeBetween: 0 and: 255 ]
! !



!Character class methodsFor: 'constants'!

backspace
    "Returns the character 'backspace'"
    ^##(Character value: 8)
!

cr
    "Returns the character 'cr'"
    ^##(Character value: 13)
!

bell
    "Returns the character 'bel' "
    ^##(Character value: 7)
!

eof
    "Returns the character 'eof', also known as 'sub' "
    ^##(Character value: 26)
!

eot
    "Returns the character 'eot', also known as 'Ctrl-D' "
    ^##(Character value: 4)
!

esc
    "Returns the character 'esc'"
    ^##(Character value: 27)
!

nul
    "Returns the character 'nul'"
    ^##(Character value: 0)
!

tab
    "Returns the character 'tab'"
    ^##(Character value: 9)
!

nl
    "Returns the character 'nl', also known as 'lf'"
    ^##(Character value: 10)
!

lf
    "Returns the character 'lf', also known as 'nl'"
    ^##(Character value: 10)
!

newPage
    "Returns the character 'newPage', also known as 'ff'"
    ^##(Character value: 12)
!

space
    "Returns the character 'space'"
    ^($ )
! !



!Character class methodsFor: 'instance creation'!

digitValue: anInteger
    "Returns a character that corresponds to anInteger.  0-9 map to $0-$9,
    10-35 map to $A-$Z"
    ^'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' at: anInteger + 1
! !



!Character methodsFor: 'converting'!

asCharacter
    "Return the receiver, since it is already a character."
    ^self
!

digitValue
    "Returns the value of self interpreted as a digit.  Here, 'digit' means
    either 0-9, or A-Z, which maps to 10-35."
    | result |
    result := Table at: 1 + codePoint ifAbsent: [ -1 ].
    ^result > 32
	ifTrue: [ codePoint - result ]
	ifFalse: [ SystemExceptions.InvalidValue signalOn: self reason: 'Not a digit character' ]
! !



!Character methodsFor: 'comparing'!

< aCharacter
    "Compare the character's ASCII value. Answer whether the receiver's
     is the least."
    ^codePoint < aCharacter codePoint
!

<= aCharacter
    "Compare the character's ASCII value. Answer whether the receiver's
     is the least or their equal."
    ^codePoint <= aCharacter codePoint
!

> aCharacter
    "Compare the character's ASCII value. Answer whether the receiver's
     is the greatest."
    ^codePoint > aCharacter codePoint
!

>= aCharacter
    "Compare the character's ASCII value. Answer whether the receiver's
     is the greatest or their equal."
    ^codePoint >= aCharacter codePoint
! !



!Character methodsFor: 'testing'!

isDigit
    "True if self is a 0-9 digit"
    ^(Table at: 1 + codePoint ifAbsent: [ 0 ]) = 48
!

isLetter
    "True if self is an upper- or lowercase letter"
    ^((Table at: 1 + codePoint ifAbsent: [ 0 ]) bitAnd: 1) = 1
!

isAlphaNumeric
    "True if self is a letter or a digit"
    ^((Table at: 1 + self codePoint ifAbsent: [ 0 ]) bitAnd: 17) > 0
!

isLowercase
    "True if self is a lowercase letter"
    ^(Table at: 1 + codePoint ifAbsent: [ 0 ]) = 3
!

isUppercase
    "True if self is uppercase"
    ^(Table at: 1 + codePoint ifAbsent: [ 0 ]) = 55
!

isSeparator
    "Returns true if self is a space, cr, tab, nl, or newPage"
    ^(Table at: 1 + codePoint ifAbsent: [ 0 ]) = 2
!

isPunctuation
    "Returns true if self is one of '.,:;!?'"
    ^(Table at: 1 + codePoint ifAbsent: [ 0 ]) = 4
!

isPathSeparator
    "Returns true if self is a path separator ($/ or $\ under Windows,
     $/ only under Unix systems including Mac OS X).
    ^self == $/ or: [ self == Directory pathSeparator ]
!

isVowel
    "Returns true if self is a, e, i, o, or u; case insensitive"
    | char |
    "So rare it isn't worth optimization"
    char := self asLowercase.
    char = $a ifTrue: [ ^true ].    
    char = $e ifTrue: [ ^true ].    
    char = $i ifTrue: [ ^true ].    
    char = $o ifTrue: [ ^true ].    
    char = $u ifTrue: [ ^true ].    
    ^false
! 

isDigit: radix
    "Answer whether the receiver is a valid character in the given radix."
    | result |
    (radix between: 2 and: 36)
	ifFalse: [ SystemExceptions.ArgumentOutOfRange signalOn: radix mustBeBetween: 2 and: 36 ].
    result := Table at: 1 + codePoint ifAbsent: [ 0 ].
    ^result > 32 and: [ codePoint - result between: 0 and: radix - 1 ]
! !


!Character methodsFor: 'coercion methods'!

asLowercase
    "Returns self as a lowercase character if it's an uppercase letter,
     otherwise returns the character unchanged."
    ^Character value: (LowerTable at: 1 + codePoint ifAbsent: [ codePoint ])
!

asUppercase
    "Returns self as a uppercase character if it's an lowercase letter,
     otherwise returns the character unchanged."
    ^Character value: (UpperTable at: 1 + codePoint ifAbsent: [ codePoint ])
!

asString
    "Returns the character self as a string.  Only valid if the character
     is between 0 and 255."
    ^String with: self
!

asUnicodeString
    "Returns the character self as a Unicode string."
    ^UnicodeString with: self
!

asSymbol
    "Returns the character self as a symbol."
    ^Symbol internCharacter: self
! !



!Character methodsFor: 'printing'!

displayOn: aStream
    "Print a representation of the receiver on aStream. Unlike
     #printOn:, this method strips the leading dollar."
    (codePoint between: 0 and: 127)
	ifTrue: [ aStream nextPut: self ]
	ifFalse: [
	    aStream nextPut: $<.
	    self printCodePointOn: aStream.
	    aStream nextPut: $> ]!

printOn: aStream
    "Print a representation of the receiver on aStream"
    self storeOn: aStream! !



!Character methodsFor: 'storing'!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    aStream nextPut: $$.
    (codePoint between: 32 and: 126)
	ifTrue: [ aStream nextPut: self. ^self ].
    aStream nextPut: $<.
    self printCodePointOn: aStream.
    aStream nextPut: $>
! !


!Character methodsFor: 'private'!

printCodePointOn: aStream
    codePoint < 32 ifTrue: [ aStream print: codePoint. ^self ].
    aStream nextPutAll: '16r'.
    codePoint <= 255 ifTrue: [ aStream nextPut: $0 ].
    codePoint <= 4095 ifTrue: [ aStream nextPut: $0 ].
    aStream nextPutAll: (codePoint printString: 16)!

asLowercaseValue
    "Returns the ASCII value of the receiver converted to a lowercase character
     if it's an uppercase letter, otherwise returns the ASCII value unchanged."
    ^LowerTable at: 1 + codePoint ifAbsent: [ codePoint ]
! !


!Character methodsFor: 'testing functionality'!

isCharacter
    "Answer True. We're definitely characters"
    ^true
! !

!Character methodsFor: 'built ins'!

= char
    "Boolean return value; true if the characters are equal"
    <primitive: VMpr_Character_equal>
!

asciiValue
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
!

asInteger
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
!

codePoint
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
!

value
    "Returns the integer value corresponding to self.  #codePoint,
     #asciiValue, #value, and #asInteger are synonyms."
    ^codePoint
! !



Character initialize!
