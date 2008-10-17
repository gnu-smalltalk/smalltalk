"======================================================================
|
|   Character Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2006,2007,2008
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



Magnitude subclass: Character [
    | codePoint |
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent the 256 characters of the character set.  I provide
messages to translate between integers and character objects, and provide
names for some of the common unprintable characters.

Character is always used (mostly for performance reasons) when referring
to characters whose code point is between 0 and 127.  Above 127, instead,
more care is needed: Character refers to bytes that are used as part of
encoding of a character, while UnicodeCharacter refers to the character
itself.'>

    Table := nil.
    UpperTable := nil.
    LowerTable := nil.

    Character class >> isImmediate [
	"Answer whether, if x is an instance of the receiver, x copy == x"

	<category: 'testing'>
	^true
    ]

    Character class >> initialize [
	"Initialize the lookup table which is used to make case and digit-to-char
	 conversions faster.
	 Indices in Table are ASCII values incremented by one. Indices 1-256
	 classify chars (0 = nothing special, 2 = separator, 48 = digit,
	 55 = uppercase, 3 = lowercase), indices 257-512 map to lowercase chars,
	 indices 513-768 map to uppercase chars."

	<category: 'initializing lookup tables'>
	Table := ByteArray new: 768.
	UpperTable := ByteArray new: 256.
	LowerTable := ByteArray new: 256.
	1 to: 256
	    do: 
		[:value | 
		UpperTable at: value put: value - 1.
		LowerTable at: value put: value - 1.
		(value between: 49 and: 58) ifTrue: [Table at: value put: 48].
		(value between: 66 and: 91) 
		    ifTrue: 
			[Table at: value put: 55.
			LowerTable at: value put: value + 31].
		(value between: 98 and: 123) 
		    ifTrue: 
			[Table at: value put: 3.
			UpperTable at: value put: value - 33]].
	Table
	    at: Character space value + 1 put: 2;
	    at: Character cr value + 1 put: 2;
	    at: Character tab value + 1 put: 2;
	    at: Character nl value + 1 put: 2;
	    at: Character newPage value + 1 put: 2;
	    at: $. value + 1 put: 4;
	    at: $, value + 1 put: 4;
	    at: $: value + 1 put: 4;
	    at: $; value + 1 put: 4;
	    at: $! value + 1 put: 4;
	    at: $? value + 1 put: 4
    ]

    Character class >> codePoint: anInteger [
	"Returns the character object, possibly an UnicodeCharacter, corresponding
	 to anInteger.  Error if anInteger is not an integer, or not in 0..16r10FFFF."

	<category: 'built ins'>
	<primitive: VMpr_UnicodeCharacter_create>
	anInteger isInteger 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger]
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: anInteger
		    mustBeBetween: 0
		    and: 1114111]
    ]

    Character class >> asciiValue: anInteger [
	"Returns the character object corresponding to anInteger.  Error if
	 anInteger is not an integer, or not in 0..127."

	<category: 'built ins'>
	anInteger isInteger 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger].
	^(anInteger between: 0 and: 127) 
	    ifTrue: [self value: anInteger]
	    ifFalse: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: anInteger
		    mustBeBetween: 0
		    and: 127]
    ]

    Character class >> value: anInteger [
	"Returns the character object corresponding to anInteger.  Error if
	 anInteger is not an integer, or not in 0..255."

	<category: 'built ins'>
	<primitive: VMpr_Character_create>
	anInteger isInteger 
	    ifFalse: 
		[SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger]
	    ifTrue: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: anInteger
		    mustBeBetween: 0
		    and: 255]
    ]

    Character class >> backspace [
	"Returns the character 'backspace'"

	<category: 'constants'>
	^##(Character value: 8)
    ]

    Character class >> cr [
	"Returns the character 'cr'"

	<category: 'constants'>
	^##(Character value: 13)
    ]

    Character class >> bell [
	"Returns the character 'bel'"

	<category: 'constants'>
	^##(Character value: 7)
    ]

    Character class >> eof [
	"Returns the character 'eof', also known as 'sub'"

	<category: 'constants'>
	^##(Character value: 26)
    ]

    Character class >> eot [
	"Returns the character 'eot', also known as 'Ctrl-D'"

	<category: 'constants'>
	^##(Character value: 4)
    ]

    Character class >> esc [
	"Returns the character 'esc'"

	<category: 'constants'>
	^##(Character value: 27)
    ]

    Character class >> nul [
	"Returns the character 'nul'"

	<category: 'constants'>
	^##(Character value: 0)
    ]

    Character class >> tab [
	"Returns the character 'tab'"

	<category: 'constants'>
	^##(Character value: 9)
    ]

    Character class >> nl [
	"Returns the character 'nl', also known as 'lf'"

	<category: 'constants'>
	^##(Character value: 10)
    ]

    Character class >> lf [
	"Returns the character 'lf', also known as 'nl'"

	<category: 'constants'>
	^##(Character value: 10)
    ]

    Character class >> newPage [
	"Returns the character 'newPage', also known as 'ff'"

	<category: 'constants'>
	^##(Character value: 12)
    ]

    Character class >> ff [
	"Returns the character 'ff', also known as 'newPage'"

	<category: 'constants'>
	^##(Character value: 12)
    ]

    Character class >> space [
	"Returns the character 'space'"

	<category: 'constants'>
	^$ 
    ]

    Character class >> digitValue: anInteger [
	"Returns a character that corresponds to anInteger.  0-9 map to $0-$9,
	 10-35 map to $A-$Z"

	<category: 'instance creation'>
	^'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' at: anInteger + 1
    ]

    asCharacter [
	"Return the receiver, since it is already a character."

	<category: 'converting'>
	^self
    ]

    digitValue [
	"Returns the value of self interpreted as a digit.  Here, 'digit' means
	 either 0-9, or A-Z, which maps to 10-35."

	<category: 'converting'>
	| result |
	result := Table at: 1 + codePoint ifAbsent: [-1].
	^result > 32 
	    ifTrue: [codePoint - result]
	    ifFalse: 
		[SystemExceptions.InvalidValue signalOn: self
		    reason: 'Not a digit character']
    ]

    < aCharacter [
	"Compare the character's ASCII value. Answer whether the receiver's
	 is the least."

	<category: 'comparing'>
	^codePoint < aCharacter codePoint
    ]

    <= aCharacter [
	"Compare the character's ASCII value. Answer whether the receiver's
	 is the least or their equal."

	<category: 'comparing'>
	^codePoint <= aCharacter codePoint
    ]

    > aCharacter [
	"Compare the character's ASCII value. Answer whether the receiver's
	 is the greatest."

	<category: 'comparing'>
	^codePoint > aCharacter codePoint
    ]

    >= aCharacter [
	"Compare the character's ASCII value. Answer whether the receiver's
	 is the greatest or their equal."

	<category: 'comparing'>
	^codePoint >= aCharacter codePoint
    ]

    isDigit [
	"True if self is a 0-9 digit"

	<category: 'testing'>
	^(Table at: 1 + codePoint ifAbsent: [0]) = 48
    ]

    isLetter [
	"True if self is an upper- or lowercase letter"

	<category: 'testing'>
	^((Table at: 1 + codePoint ifAbsent: [0]) bitAnd: 1) = 1
    ]

    isAlphaNumeric [
	"True if self is a letter or a digit"

	<category: 'testing'>
	^((Table at: 1 + self codePoint ifAbsent: [0]) bitAnd: 17) > 0
    ]

    isLowercase [
	"True if self is a lowercase letter"

	<category: 'testing'>
	^(Table at: 1 + codePoint ifAbsent: [0]) = 3
    ]

    isUppercase [
	"True if self is uppercase"

	<category: 'testing'>
	^(Table at: 1 + codePoint ifAbsent: [0]) = 55
    ]

    isSeparator [
	"Returns true if self is a space, cr, tab, nl, or newPage"

	<category: 'testing'>
	^(Table at: 1 + codePoint ifAbsent: [0]) = 2
    ]

    isPunctuation [
	"Returns true if self is one of '.,:;!?'"

	<category: 'testing'>
	^(Table at: 1 + codePoint ifAbsent: [0]) = 4
    ]

    isPathSeparator [
	"Returns true if self is a path separator ($/ or $\ under Windows,
	 $/ only under Unix systems including Mac OS X)."

	<category: 'testing'>
	^self == $/ or: [self == Directory pathSeparator]
    ]

    isVowel [
	"Returns true if self is a, e, i, o, or u; case insensitive"

	<category: 'testing'>
	"So rare it isn't worth optimization"

	| char |
	char := self asLowercase.
	char = $a ifTrue: [^true].
	char = $e ifTrue: [^true].
	char = $i ifTrue: [^true].
	char = $o ifTrue: [^true].
	char = $u ifTrue: [^true].
	^false
    ]

    isDigit: radix [
	"Answer whether the receiver is a valid character in the given radix."

	<category: 'testing'>
	| result |
	(radix between: 2 and: 36) 
	    ifFalse: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: radix
		    mustBeBetween: 2
		    and: 36].
	result := Table at: 1 + codePoint ifAbsent: [0].
	^result > 32 and: [codePoint - result between: 0 and: radix - 1]
    ]

    asLowercase [
	"Returns self as a lowercase character if it's an uppercase letter,
	 otherwise returns the character unchanged."

	<category: 'coercion methods'>
	^Character value: (LowerTable at: 1 + codePoint ifAbsent: [codePoint])
    ]

    asUppercase [
	"Returns self as a uppercase character if it's an lowercase letter,
	 otherwise returns the character unchanged."

	<category: 'coercion methods'>
	^Character value: (UpperTable at: 1 + codePoint ifAbsent: [codePoint])
    ]

    * aNumber [
	"Returns a String with aNumber occurrences of the receiver."

	<category: 'coercion methods'>
	^String new: aNumber withAll: self
    ]

    asString [
	"Returns the character self as a string.  Only valid if the character
	 is between 0 and 255."

	<category: 'coercion methods'>
	^String with: self
    ]

    asUnicodeString [
	"Returns the character self as a Unicode string."

	<category: 'coercion methods'>
	^UnicodeString with: self
    ]

    asSymbol [
	"Returns the character self as a symbol."

	<category: 'coercion methods'>
	^Symbol internCharacter: self
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #printOn:, this method strips the leading dollar."

	<category: 'printing'>
	(codePoint between: 0 and: 127) 
	    ifTrue: [aStream nextPut: self]
	    ifFalse: 
		[aStream nextPut: $<.
		self printCodePointOn: aStream.
		aStream nextPut: $>]
    ]

    storeLiteralOn: aStream [
	"Store on aStream some Smalltalk code which compiles to the receiver"

	<category: 'printing'>
	self storeOn: aStream
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	self storeOn: aStream
    ]

    isLiteralObject [
	"Answer whether the receiver is expressible as a Smalltalk literal."

	<category: 'storing'>
	^true
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	aStream nextPut: $$.
	(codePoint between: 32 and: 126) 
	    ifTrue: 
		[aStream nextPut: self.
		^self].
	aStream nextPut: $<.
	self printCodePointOn: aStream.
	aStream nextPut: $>
    ]

    printCodePointOn: aStream [
	<category: 'private'>
	codePoint < 32 
	    ifTrue: 
		[aStream print: codePoint.
		^self].
	aStream nextPutAll: '16r'.
	codePoint <= 255 ifTrue: [aStream nextPut: $0].
	codePoint <= 4095 ifTrue: [aStream nextPut: $0].
	aStream nextPutAll: (codePoint printString: 16)
    ]

    asLowercaseValue [
	"Returns the ASCII value of the receiver converted to a lowercase character
	 if it's an uppercase letter, otherwise returns the ASCII value unchanged."

	<category: 'private'>
	^LowerTable at: 1 + codePoint ifAbsent: [codePoint]
    ]

    isCharacter [
	"Answer True. We're definitely characters"

	<category: 'testing functionality'>
	^true
    ]

    = char [
	"Boolean return value; true if the characters are equal"

	<category: 'built ins'>
	<primitive: VMpr_Character_equal>
	
    ]

    asciiValue [
	"Returns the integer value corresponding to self.  #codePoint,
	 #asciiValue, #value, and #asInteger are synonyms."

	<category: 'built ins'>
	^codePoint
    ]

    asInteger [
	"Returns the integer value corresponding to self.  #codePoint,
	 #asciiValue, #value, and #asInteger are synonyms."

	<category: 'built ins'>
	^codePoint
    ]

    codePoint [
	"Returns the integer value corresponding to self.  #codePoint,
	 #asciiValue, #value, and #asInteger are synonyms."

	<category: 'built ins'>
	^codePoint
    ]

    value [
	"Returns the integer value corresponding to self.  #codePoint,
	 #asciiValue, #value, and #asInteger are synonyms."

	<category: 'built ins'>
	^codePoint
    ]
]



Eval [
    Character initialize
]

