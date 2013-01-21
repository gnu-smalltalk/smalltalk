"======================================================================
|
|   CharacterArray Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2006, 2007, 2008, 2009
| Free Software Foundation, Inc.
| Written by Steve Byrne and Paolo Bonzini.
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



ArrayedCollection subclass: CharacterArray [
    
    <shape: #word>
    <category: 'Collections-Text'>
    <comment: 'My instances represent a generic textual (string) data type.  I provide
accessing and manipulation methods for strings.'>

    CharacterArray class >> fromString: aCharacterArray [
	"Make up an instance of the receiver containing the same characters
	 as aCharacterArray, and answer it."

	<category: 'basic'>
	^(self new: aCharacterArray size)
	    replaceFrom: 1
		to: aCharacterArray size
		with: aCharacterArray
		startingAt: 1;
	    yourself
    ]

    CharacterArray class >> lineDelimiter [
	"Answer a CharacterArray which one can use as a line delimiter.
	 This is meant to be used on subclasses of CharacterArray."

	<category: 'basic'>
	^self with: Character nl
    ]

    CharacterArray class >> isUnicode [
	"Answer whether the receiver stores bytes (i.e. an encoded
	 form) or characters (if true is returned)."

	<category: 'multibyte encodings'>
	self subclassResponsibility
    ]

    = aString [
	"Answer whether the receiver's items match those in aCollection"

	<category: 'comparing'>
	aString isSymbol ifTrue: [^self == aString].
	aString isCharacterArray ifFalse: [^false].
	self encoding == aString encoding 
	    ifFalse: [^self asUnicodeString = aString asUnicodeString].

	"Encoding matches, check the characters."
	self size = aString size ifFalse: [^false].
	self hash == aString hash ifFalse: [^false].
	1 to: self size do: [:i | (self at: i) = (aString at: i) ifFalse: [^false]].
	^true
    ]

    < aCharacterArray [
	"Return true if the receiver is less than aCharacterArray, ignoring case
	 differences."

	<category: 'comparing'>
	^(self caseInsensitiveCompareTo: aCharacterArray) < 0
    ]

    > aCharacterArray [
	"Return true if the receiver is greater than aCharacterArray, ignoring case
	 differences."

	<category: 'comparing'>
	^(self caseInsensitiveCompareTo: aCharacterArray) > 0
    ]

    <= aCharacterArray [
	"Returns true if the receiver is less than or equal to aCharacterArray,
	 ignoring case differences.  If is receiver is an initial substring of
	 aCharacterArray, it is considered to be less than aCharacterArray."

	<category: 'comparing'>
	^(self caseInsensitiveCompareTo: aCharacterArray) <= 0
    ]

    >= aCharacterArray [
	"Returns true if the receiver is greater than or equal to aCharacterArray,
	 ignoring case differences.  If is aCharacterArray is an initial substring of
	 the receiver, it is considered to be less than the receiver."

	<category: 'comparing'>
	^(self caseInsensitiveCompareTo: aCharacterArray) >= 0
    ]

    sameAs: aCharacterArray [
	"Returns true if the receiver is the same CharacterArray as aCharacterArray, ignoring
	 case differences."

	<category: 'comparing'>
	self size ~= aCharacterArray size ifTrue: [^false].
	^(self caseInsensitiveCompareTo: aCharacterArray) = 0
    ]

    match: aCharacterArray [
	"Answer whether aCharacterArray matches the pattern contained in the
	 receiver. # in the receiver means 'match any character', * in
	 receiver means 'match any sequence of characters'."

	<category: 'comparing'>
	| result |
	result := self asLowercase 
		    matchSubstring: 1
		    in: aCharacterArray asLowercase
		    at: 1.
	^result = aCharacterArray size
    ]

    match: aCharacterArray ignoreCase: aBoolean [
	"Answer whether aCharacterArray matches the pattern contained in the
	 receiver. # in the receiver means 'match any character', * in
	 receiver means 'match any sequence of characters'.  The case of
	 alphabetic characters is ignored if aBoolean is true."

	<category: 'comparing'>
	| result |
	aBoolean 
	    ifTrue: 
		[^self asLowercase match: aCharacterArray asLowercase ignoreCase: false].
	result := self 
		    matchSubstring: 1
		    in: aCharacterArray
		    at: 1.
	^result = aCharacterArray size
    ]

    indexOf: aCharacterArray matchCase: aBoolean startingAt: anIndex [
	"Answer an Interval of indices in the receiver which match the aCharacterArray
	 pattern. # in aCharacterArray means 'match any character', * in aCharacterArray means
	 'match any sequence of characters'. The first item of the returned interval
	 is >= anIndex. If aBoolean is false, the search is case-insensitive, 
	 else it is case-sensitive. If no Interval matches the pattern, answer nil."

	<category: 'comparing'>
	| result |
	aBoolean 
	    ifFalse: 
		[^self asLowercase 
		    indexOf: aCharacterArray asLowercase
		    matchCase: true
		    startingAt: anIndex].
	anIndex to: self size
	    do: 
		[:i | 
		result := aCharacterArray 
			    matchSubstring: 1
			    in: self
			    at: i.
		result notNil ifTrue: [^i to: result]].
	^nil
    ]

    isUnicode [
	"Answer whether the receiver stores bytes (i.e. an encoded
	 form) or characters (if true is returned)."

	<category: 'multibyte encodings'>
	^self class isUnicode
    ]

    encoding [
	"Answer the encoding used by the receiver."

	<category: 'multibyte encodings'>
	self subclassResponsibility
    ]

    numberOfCharacters [
	"Answer the number of Unicode characters in the receiver.
	 This is not implemented unless you load the I18N package."

	<category: 'multibyte encodings'>
	self notYetImplemented
    ]

    contractTo: smallSize [
	"Either return myself, or a copy shortened to smallSize characters
	 by inserting an ellipsis (three dots: ...)"

	<category: 'string processing'>
	| leftSize |
	self size <= smallSize ifTrue: [^self].
	smallSize < 5 ifTrue: [^self copyFrom: 1 to: smallSize].
	leftSize := (smallSize - 2) // 2.
	^self 
	    copyReplaceFrom: leftSize + 1
	    to: self size - (smallSize - leftSize - 3)
	    with: '...'	"First N/2 ... last N/2"
    ]

    linesDo: aBlock [
	"Evaluate aBlock once for every newline delimited line in the receiver,
	 passing the line to the block."

	<category: 'string processing'>
	self readStream linesDo: aBlock
    ]

    lines [
	"Answer an Array of Strings each representing one line in the receiver."

	<category: 'string processing'>
	^self readStream lines contents
    ]

    substrings [
	"Answer an OrderedCollection of substrings of the receiver. A new substring
	 start at the start of the receiver, or after every sequence of white space
	 characters.  This message is preserved for backwards compatibility;
	 the ANSI standard mandates `subStrings', with an uppercase s."

	<category: 'string processing'>
	| oc last |
	last := 1.
	oc := OrderedCollection new.
	1 to: self size
	    do: 
		[:i | 
		(self at: i) isSeparator 
		    ifTrue: 
			[last = i ifFalse: [oc addLast: (self copyFrom: last to: i - 1)].
			last := i + 1]].
	last <= self size 
	    ifTrue: [oc addLast: (self copyFrom: last to: self size)].
	^oc
    ]

    subStrings [
	"Answer an OrderedCollection of substrings of the receiver. A new substring
	 start at the start of the receiver, or after every sequence of white space
	 characters"

	<category: 'string processing'>
	| oc last |
	last := 1.
	oc := OrderedCollection new.
	1 to: self size
	    do: 
		[:i | 
		(self at: i) isSeparator 
		    ifTrue: 
			[last = i ifFalse: [oc addLast: (self copyFrom: last to: i - 1)].
			last := i + 1]].
	last <= self size 
	    ifTrue: [oc addLast: (self copyFrom: last to: self size)].
	^oc
    ]

    substrings: sep [
	"Answer an OrderedCollection of substrings of the receiver. A new substring
	 start at the start of the receiver, or after every occurrence of one of the
         characters in sep.  This message is preserved for backwards compatibility;
	 the ANSI standard mandates `subStrings:', with an uppercase s."

	<category: 'string processing'>
	| oc last |
        sep isCharacter ifTrue: [ ^self subStringsChar: sep ].
        sep size = 1 ifTrue: [ ^self subStringsChar: sep first ].
	last := 1.
	oc := OrderedCollection new.
	1 to: self size
	    do: 
		[:i | 
		(sep includes: (self at: i))
		    ifTrue: 
			[last = i ifFalse: [oc addLast: (self copyFrom: last to: i - 1)].
			last := i + 1]].
	last <= self size 
	    ifTrue: [oc addLast: (self copyFrom: last to: self size)].
	^oc
    ]

    subStrings: sep [
	"Answer an OrderedCollection of substrings of the receiver. A new substring
	 start at the start of the receiver, or after every occurrence of one of the
         characters in sep"

	<category: 'string processing'>
	| oc last |
        sep isCharacter ifTrue: [ ^self subStringsChar: sep ].
        sep size = 1 ifTrue: [ ^self subStringsChar: sep first ].
	last := 1.
	oc := OrderedCollection new.
	1 to: self size
	    do: 
		[:i | 
		(sep includes: (self at: i))
		    ifTrue: 
			[last = i ifFalse: [oc addLast: (self copyFrom: last to: i - 1)].
			last := i + 1]].
	last <= self size 
	    ifTrue: [oc addLast: (self copyFrom: last to: self size)].
	^oc
    ]

    subStringsChar: sepChar [
	"Private - Answer an OrderedCollection of substrings of the receiver. A new substring
	 start at the start of the receiver, or after every occurrence of the
         character sepChar."

	<category: 'private-string processing'>
	| oc last |
	last := 1.
	oc := OrderedCollection new.
	1 to: self size
	    do: 
		[:i | 
		(self at: i) = sepChar 
		    ifTrue: 
			[last = i ifFalse: [oc addLast: (self copyFrom: last to: i - 1)].
			last := i + 1]].
	last <= self size 
	    ifTrue: [oc addLast: (self copyFrom: last to: self size)].
	^oc
    ]

    bindWith: s1 [
	"Answer the receiver with every %1 replaced by the displayString of s1"

	<category: 'string processing'>
	^self % {s1}
    ]

    bindWith: s1 with: s2 [
	"Answer the receiver with every %1 or %2 replaced by s1 or s2,
	 respectively.  s1 and s2 are `displayed' (i.e. their
	 displayString is used) upon replacement."

	<category: 'string processing'>
	^self % 
		{s1.
		s2}
    ]

    bindWith: s1 with: s2 with: s3 [
	"Answer the receiver with every %1, %2 or %3 replaced by s1, s2 or s3,
	 respectively.  s1, s2 and s3 are `displayed' (i.e. their
	 displayString is used) upon replacement."

	<category: 'string processing'>
	^self % 
		{s1.
		s2.
		s3}
    ]

    bindWith: s1 with: s2 with: s3 with: s4 [
	"Answer the receiver with every %1, %2, %3 or %4 replaced by s1, s2, s3
	 or s4, respectively.  s1, s2, s3 and s4 are `displayed' (i.e. their
	 displayString is used) upon replacement."

	<category: 'string processing'>
	^self % 
		{s1.
		s2.
		s3.
		s4}
    ]

    bindWithArguments: aCollection [
	"Answer the receiver with special escape sequences replaced by
         elements of aCollection.   %n (1<=n<=9, A<=n<=Z) are replaced by
         the n-th element of aCollection (A being the 10-th element and so on
         until the 35th).  %(string) sequences are accessed as strings, which
         makes sense only if aCollection is a Dictionary or LookupTable.
	 In addition, the special pattern %<trueString|falseString>n
	 or %<trueString|falseString>(string) is replaced with one of
	 the two strings depending on the element of aCollection being
	 true or false.  The replaced elements are `displayed' (i.e. their
	 displayString is used)."

	<category: 'string processing'>
	^self % aCollection
    ]

    % aCollection [
	"Answer the receiver with special escape sequences replaced by
         elements of aCollection.   %n (1<=n<=9, A<=n<=Z) are replaced by
         the n-th element of aCollection (A being the 10-th element and so on
         until the 35th).  %(string) sequences are accessed as strings, which
         makes sense only if aCollection is a Dictionary or LookupTable.
	 In addition, the special pattern %<trueString|falseString>n
	 or %<trueString|falseString>(string) is replaced with one of
	 the two strings depending on the element of aCollection being
	 true or false.  The replaced elements are `displayed' (i.e. their
	 displayString is used)."

	<category: 'string processing'>
	| result wasPercent pattern char trueString falseString key value |
	result := WriteStream on: (self copyEmpty: self size + 20).
	wasPercent := false.
	pattern := ReadStream on: self.
	[pattern atEnd] whileFalse: 
	    [char := pattern next.
            char = $% ifFalse: [result nextPut: char] ifTrue: [
		char := pattern next.
                char = $% ifTrue: [result nextPut: char] ifFalse: [
		char = $< 
		    ifTrue: 
			[trueString := pattern upTo: $|.
			falseString := pattern upTo: $>.
                        char := pattern next].
		key := char = $(
                    ifTrue: [pattern upTo: $)]
                    ifFalse: [char digitValue].
                value := trueString isNil
                    ifTrue: [aCollection at: key]
                    ifFalse: [(aCollection at: key) ifTrue: [trueString] ifFalse: [falseString]].
                trueString := falseString := nil.
		result display: value]]].
	^result contents
    ]

    withShellEscapes [
	"Answer the receiver with special shell characters converted to a
         backslash sequence."

	<category: 'string processing'>
        ^Directory pathSeparator == $\ 
            ifTrue: [ self withWindowsShellEscapes ]
            ifFalse: [ self withUnixShellEscapes ]
    ]

    withWindowsShellEscapes [
	"Answer the receiver with Windows shell characters escaped properly."

	| num result table slashes |
        table := ##(
            | t |
            t := ByteArray new: 256.
            #($% $" $< $> $| $& $^ $ ) do: [ :each | t at: each codePoint put: 1 ].
            t).

        num := 0.
        1 to: self size do: [ :i |
            num := num + (table at: (self valueAt: i) ifAbsent: [0])].

        num = 0 ifTrue: [^self].
        result := self copyEmpty writeStream.
        result nextPut: $".
        slashes := 0.
        self do: [:each|
            (each = $" or: [each = $%])
                ifFalse: [
                    "Backslash is not special per se, but must be treated
                     specially inside quotes."
                    slashes := each = $\ ifTrue: [slashes+1] ifFalse: [0].
                    result nextPut: each]
                ifTrue: [
                    slashes > 0 ifTrue: [result next: slashes put: $\].
                    slashes := 0.
                    result nextPut: $".
                    each = $% ifTrue: [ result nextPut: $% ].
                    result nextPut: $"]].
        result next: slashes put: $\.
        result nextPut: $".

        ^result contents
    ]

    withUnixShellEscapes [
        "Answer the receiver with special shell characters converted to a
         backslash sequence."

        | num result table i j ch |
        table := ##(
            | t |
            t := ByteArray new: 256.
            #($  $' $" $` $| $^ $> $[ $= $< $; $( $) $*
              $& $$ $" $! $# $~ ${ $} $? $\) do: [ :each |
                t at: each codePoint put: 1 ].
            t).

        num := 0.
        1 to: self size do: [ :i |
            num := num + (table at: (self valueAt: i) ifAbsent: [0])].

        num = 0 ifTrue: [^self].
        result := self copyEmpty: self size + num.
        i := 1. j := 0.
        [j < num] whileTrue: [
            ch := self valueAt: i.
            (table at: ch ifAbsent: [0]) = 0 ifFalse: [
                result at: j + i put: $\.
                j := j + 1].
            result valueAt: j + i put: ch.
            i := i + 1].

        result replaceFrom: j+i to: self size + num with: self startingAt: i.
        ^result
    ]

    asNumber [
	"Parse a Number from the receiver until the input character is invalid
	 and answer the result at this point"

	<category: 'converting'>
	^Number readFrom: (ReadStream on: self)
    ]

    asUnicodeString [
	"Answer a UnicodeString whose character's codes are the receiver's contents
	 This is not implemented unless you load the I18N package."

	<category: 'converting'>
	self subclassResponsibility
    ]

    asUppercase [
	"Returns a copy of self as an uppercase CharacterArray"

	<category: 'converting'>
	| newStr |
	newStr := self copyEmpty: self size.
	1 to: self size do: [:i | newStr at: i put: (self at: i) asUppercase].
	^newStr
    ]

    asLowercase [
	"Returns a copy of self as a lowercase CharacterArray"

	<category: 'converting'>
	| newStr |
	newStr := self copyEmpty: self size.
	1 to: self size do: [:i | newStr at: i put: (self at: i) asLowercase].
	^newStr
    ]

    asString [
	"But I already am a String!  Really!"

	<category: 'converting'>
	self subclassResponsibility
    ]

    asGlobalKey [
	"Return the receiver, ready to be put in the Smalltalk dictionary"

	<category: 'converting'>
	^self asSymbol
    ]

    asPoolKey [
	"Return the receiver, ready to be put in a pool dictionary"

	<category: 'converting'>
	^self asSymbol
    ]

    asClassPoolKey [
	"Return the receiver, ready to be put in a class pool dictionary"

	<category: 'converting'>
	^self asSymbol
    ]

    asByteArray [
	"Return the receiver, converted to a ByteArray of ASCII values"

	<category: 'converting'>
	^self asString asByteArray
    ]

    asInteger [
	"Parse an Integer number from the receiver until the input character
	 is invalid and answer the result at this point"

	<category: 'converting'>
	| result i sign ch value |
	self isEmpty ifTrue: [^0].
	ch := self at: 1.
	result := ch codePoint - ##($0 codePoint).
	(result < 0 or: [result > 9]) 
	    ifTrue: 
		[result := 0.
		ch = $- 
		    ifTrue: 
			[2 to: self size
			    do: 
				[:i | 
				ch := self at: i.
				value := ch codePoint - ##($0 codePoint).
				(value < 0 or: [value > 9]) ifTrue: [^result].
				result := result * 10 - value]]]
	    ifFalse: 
		[2 to: self size
		    do: 
			[:i | 
			ch := self at: i.
			value := ch codePoint - ##($0 codePoint).
			(value < 0 or: [value > 9]) ifTrue: [^result].
			result := result * 10 + value]].
	^result
    ]

    fileName [
	"But I don't HAVE a file name!"

	<category: 'converting'>
	^nil
    ]

    filePos [
	"But I don't HAVE a file position!"

	<category: 'converting'>
	^nil
    ]

    isNumeric [
	"Answer whether the receiver denotes a number"

	<category: 'converting'>
	| stream ch |
	stream := ReadStream on: self.
	
	[stream atEnd ifTrue: [^true].
	(ch := stream next) isDigit] whileTrue: [].
	ch = $. ifFalse: [^false].
	
	[ch := stream next.
	ch isDigit ifFalse: [^false].
	stream atEnd] 
		whileFalse.
	^true
    ]

    asSymbol [
	"Returns the symbol corresponding to the CharacterArray"

	<category: 'converting'>
	self subclassResponsibility
    ]

    trimSeparators [
	"Return a copy of the reciever without any spaces on front or back.
	 The implementation is protected against the `all blanks' case."

	"This is not implemented as two while loops, but as two nested
	 #to:do:'s, for speed"

	<category: 'converting'>
	1 to: self size
	    do: 
		[:start | 
		(self at: start) isSeparator 
		    ifFalse: 
			[self size to: start
			    by: -1
			    do: [:stop | (self at: stop) isSeparator ifFalse: [^self copyFrom: start to: stop]]	"to:by:do:"]].	"to:do:"
	^''
    ]

    caseInsensitiveCompareTo: aCharacterArray [
	"Answer a number < 0 if the receiver is less than aCharacterArray,
	 a number > 0 if it is greater, or 0 if they are equal."

	<category: 'private'>
	"Scan self and aCharacterArray until a character is clearly greater or lesser
	 (All preceding characters must have been equal).  If the end is reached,
	 one of the CharacterArrays is a possibly improper initial substring of the other,
	 and for the receiver to be less than aCharacterArray, it must be the initial
	 substring."

	| c1 c2 |
	1 to: (self size min: aCharacterArray size)
	    do: 
		[:i | 
		c1 := (self at: i) asLowercaseValue.
		c2 := (aCharacterArray at: i) asLowercaseValue.
		c1 = c2 ifFalse: [^c1 - c2]].
	^self size - aCharacterArray size
    ]

    matchSubstring: pp in: aCharacterArray at: i [
	"Private - Match the pattern from the pp-th character of the receiver
	 to the characters from the i-th in aCharacterArray. Answer nil if they
	 don't match, else answer the last character making up the pattern"

	<category: 'private'>
	| result s |
	s := i.
	self 
	    from: pp
	    to: self size
	    keysAndValuesDo: 
		[:p :pc | 
		pc = $* 
		    ifTrue: 
			[aCharacterArray size + 1 to: s
			    by: -1
			    do: 
				[:ss | 
				result := self 
					    matchSubstring: p + 1
					    in: aCharacterArray
					    at: ss.
				result notNil ifTrue: [^result]].
			^nil].
		s > aCharacterArray size ifTrue: [^nil].
		pc = $# ifFalse: [pc = (aCharacterArray at: s) ifFalse: [^nil]].
		s := s + 1].
	^s - 1
    ]

    isCharacterArray [
	<category: 'testing functionality'>
	^true
    ]

    valueAt: index [
	"Answer the ascii value of index-th character variable of the receiver"

	<category: 'built ins'>
	| shape size |
	<primitive: VMpr_CharacterArray_valueAt>
	shape := self class shape.
	(shape == #character or: [shape == #utf32]) 
	    ifFalse: [^self subclassResponsibility].
	self class isFixed ifTrue: [^self subclassResponsibility].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index
    ]

    valueAt: anIndex ifAbsent: aBlock [
	"Answer the ascii value of the anIndex-th character of the receiver,
	 or evaluate aBlock and answer the result if the index is out of range."

	<category: 'basic'>
	(anIndex between: 1 and: self size) ifFalse: [^aBlock value].
	^self valueAt: anIndex
    ]

    valueAt: index put: value [
	"Store (Character value: value) in the index-th indexed instance variable
	 of the receiver"

	<category: 'built ins'>
	| shape size |
	<primitive: VMpr_CharacterArray_valueAtPut>
	shape := self class shape.
	(shape == #character or: [shape == #utf32]) 
	    ifFalse: [^self subclassResponsibility].
	self class isFixed ifTrue: [^self subclassResponsibility].
	self isReadOnly ifTrue: [^SystemExceptions.ReadOnlyObject signal].
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: SmallInteger].
	index < 1 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	index > self basicSize 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	value isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: value mustBe: SmallInteger].
	shape == #character 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: value
		    mustBeBetween: 0
		    and: 255].
	^SystemExceptions.ArgumentOutOfRange 
	    signalOn: value
	    mustBeBetween: 0
	    and: 1114111
    ]
]

