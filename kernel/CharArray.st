"======================================================================
|
|   CharacterArray Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2006 Free Software Foundation, Inc.
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


ArrayedCollection variableWordSubclass: #CharacterArray
		  instanceVariableNames: ''
		  classVariableNames: ''
		  poolDictionaries: ''
		  category: 'Language-Data types'
!

CharacterArray comment: 
'My instances represent a generic textual (string) data type.  I provide
accessing and manipulation methods for strings.' !


!CharacterArray class methodsFor: 'basic'!

fromString: aCharacterArray
    "Make up an instance of the receiver containing the same characters
     as aCharacterArray, and answer it."
    ^(self new: aCharacterArray size)
	replaceFrom: 1
	to: aCharacterArray size
	with: aCharacterArray
	startingAt: 1;

	yourself
!

lineDelimiter
    "Answer a CharacterArray which one can use as a line delimiter."
    ^self with: Character nl
! !


!CharacterArray methodsFor: 'comparing'!

< aCharacterArray
    "Return true if the receiver is less than aCharacterArray, ignoring case
    differences."
    ^(self caseInsensitiveCompareTo: aCharacterArray) < 0
!

> aCharacterArray
    "Return true if the receiver is greater than aCharacterArray, ignoring case
    differences."
    ^(self caseInsensitiveCompareTo: aCharacterArray) > 0
!

<= aCharacterArray
    "Returns true if the receiver is less than or equal to aCharacterArray,
    ignoring case differences.  If is receiver is an initial substring of
    aCharacterArray, it is considered to be less than aCharacterArray."
    ^(self caseInsensitiveCompareTo: aCharacterArray) <= 0
!

>= aCharacterArray
    "Returns true if the receiver is greater than or equal to aCharacterArray,
    ignoring case differences.  If is aCharacterArray is an initial substring of
    the receiver, it is considered to be less than the receiver."
    ^(self caseInsensitiveCompareTo: aCharacterArray) >= 0
!

sameAs: aCharacterArray
    "Returns true if the receiver is the same CharacterArray as aCharacterArray, ignoring
    case differences."
    self size ~= aCharacterArray size ifTrue: [ ^false ].
    ^(self caseInsensitiveCompareTo: aCharacterArray) = 0
!

startsWith: aCharacterArray
    "Returns true if the receiver starts with the same characters as aCharacterArray."
    ^self size >= aCharacterArray size and: [
	aCharacterArray keysAndValuesDo: [ :i :each |
	    (self at: i) = each ifFalse: [ ^false ]].
	true ]
!

match: aCharacterArray
    "Answer whether aCharacterArray matches the pattern contained in the
     receiver. # in the receiver means 'match any character', * in
     receiver means 'match any sequence of characters'. "
    | result |
    result := self asLowercase
	matchSubstring: 1
	in: aCharacterArray asLowercase
	at: 1.

    ^result = aCharacterArray size
!

match: aCharacterArray ignoreCase: aBoolean
    "Answer whether aCharacterArray matches the pattern contained in the
     receiver. # in the receiver means 'match any character', * in
     receiver means 'match any sequence of characters'.  The case of
     alphabetic characters is ignored if aBoolean is true."
    | result |
    aBoolean ifTrue: [
	^self asLowercase
	    match: aCharacterArray asLowercase
	    ignoreCase: false
    ].

    result := self
	matchSubstring: 1
	in: aCharacterArray
	at: 1.

    ^result = aCharacterArray size
!

indexOf: aCharacterArray matchCase: aBoolean startingAt: anIndex
    "Answer an Interval of indices in the receiver which match the aCharacterArray
     pattern. # in aCharacterArray means 'match any character', * in aCharacterArray means
     'match any sequence of characters'. The first item of the returned in-
     terval is >= anIndex. If aBoolean is false, the search is case-insen-
     sitive, else it is case-sensitive.
     If no Interval matches the pattern, answer nil."

    | result |

    aBoolean ifFalse: [
	^self asLowercase
	   indexOf: aCharacterArray asLowercase
	   matchCase: true
	   startingAt: anIndex ].

    anIndex to: self size do: [ :i |
	result := aCharacterArray matchSubstring: 1 in: self at: i.
	result notNil ifTrue: [^i to: result]
    ].
    ^nil
! !


!CharacterArray methodsFor: 'multibyte encodings'!

numberOfCharacters
    "Answer the number of Unicode characters in the receiver."
    self subclassResponsibility! !


!CharacterArray methodsFor: 'string processing'!

contractTo: smallSize
    "Either return myself, or a copy shortened to smallSize characters
     by inserting an ellipsis (three dots: ...)"

    | leftSize |
    self size <= smallSize
	ifTrue: [ ^self ].
    smallSize < 5
	ifTrue: [ ^self copyFrom: 1 to: smallSize ].
    leftSize := smallSize - 2 // 2.
    ^self
	copyReplaceFrom: leftSize + 1		"First N/2 ... last N/2"
	to: self size - (smallSize - leftSize - 3)
	with: '...'
!

substrings
    "Answer an OrderedCollection of substrings of the receiver. A new substring
     start at the start of the receiver, or after every sequence of white space
     characters.  This message is preserved for backwards compatibility;
     the ANSI standard mandates `subStrings', with an uppercase s."
    | oc last |

    last := 1.
    oc := OrderedCollection new.
    1 to: self size do: [:i |
	(self at: i) isSeparator ifTrue: [
	    last = i ifFalse: [
		oc addLast: (self copyFrom: last to: i - 1)
	    ].
	    last := i + 1.
	]
    ].
    last <= self size ifTrue: [
	oc addLast: (self copyFrom: last to: self size)
    ].
    ^oc
!

subStrings
    "Answer an OrderedCollection of substrings of the receiver. A new substring
     start at the start of the receiver, or after every sequence of white space
     characters"
    | oc last |

    last := 1.
    oc := OrderedCollection new.
    1 to: self size do: [:i |
	(self at: i) isSeparator ifTrue: [
	    last = i ifFalse: [
		oc addLast: (self copyFrom: last to: i - 1)
	    ].
	    last := i + 1.
	]
    ].
    last <= self size ifTrue: [
	oc addLast: (self copyFrom: last to: self size)
    ].
    ^oc
!

substrings: aCharacter
    "Answer an OrderedCollection of substrings of the receiver. A new substring
     start at the start of the receiver, or after every sequence of characters
     matching aCharacter.  This message is preserved for backwards compatibility;
     the ANSI standard mandates `subStrings:', with an uppercase s."
    | oc last |

    last := 1.
    oc := OrderedCollection new.
    1 to: self size do: [:i |
	(self at: i) == aCharacter ifTrue: [
	    last = i ifFalse: [
		oc addLast: (self copyFrom: last to: i - 1)
	    ].
	    last := i + 1.
	]
    ].
    last <= self size ifTrue: [
	oc addLast: (self copyFrom: last to: self size)
    ].
    ^oc
!

subStrings: aCharacter
    "Answer an OrderedCollection of substrings of the receiver. A new substring
     start at the start of the receiver, or after every sequence of characters
     matching aCharacter"
    | oc last |

    last := 1.
    oc := OrderedCollection new.
    1 to: self size do: [:i |
	(self at: i) == aCharacter ifTrue: [
	    last = i ifFalse: [
		oc addLast: (self copyFrom: last to: i - 1)
	    ].
	    last := i + 1.
	]
    ].
    last <= self size ifTrue: [
	oc addLast: (self copyFrom: last to: self size)
    ].
    ^oc
!

bindWith: s1
    "Answer the receiver with every %1 replaced by the displayString of s1"
    ^self bindWithArguments: { s1 }
!

bindWith: s1 with: s2
    "Answer the receiver with every %1 or %2 replaced by s1 or s2,
     respectively.  s1 and s2 are `displayed' (i.e. their
     displayString is used) upon replacement."
    ^self bindWithArguments: { s1. s2 }
!

bindWith: s1 with: s2 with: s3
    "Answer the receiver with every %1, %2 or %3 replaced by s1, s2 or s3,
     respectively.  s1, s2 and s3 are `displayed' (i.e. their
     displayString is used) upon replacement."

    ^self bindWithArguments: { s1. s2. s3 }
!

bindWith: s1 with: s2 with: s3 with: s4
    "Answer the receiver with every %1, %2, %3 or %4 replaced by s1, s2, s3
     or s4, respectively.  s1, s2, s3 and s4 are `displayed' (i.e. their
     displayString is used) upon replacement."

    ^self bindWithArguments: { s1. s2. s3. s4 }
!

bindWithArguments: anArray
    "Answer the receiver with every %n (1<=n<=9) replaced by the n-th element
     of anArray.  The replaced elements are `displayed' (i.e. their
     displayString is used).  In addition, the special pattern
     %<trueString|falseString>n is replaced with one of the two
     strings depending on the n-th element of anArray being true or false."

    | result wasPercent pattern char ifTrue ifFalse |
    result := WriteStream on: (self copyEmpty: self size + 20).
    wasPercent := false.
    pattern := ReadStream on: self.
    
    [ pattern atEnd ] whileFalse: [
	char := pattern next.
	wasPercent
	    ifTrue: [
		char = $<
		    ifTrue: [
			ifTrue := pattern upTo: $|.
			ifFalse := pattern upTo: $>.
			result nextPutAll: ((anArray at: pattern next digitValue)
			    ifTrue: [ ifTrue ]
			    ifFalse: [ ifFalse ])
		    ].

		char = $%
		    ifTrue: [ result nextPut: char ].

		char isAlphaNumeric
		    ifTrue: [ result display: (anArray at: char digitValue) ].

		wasPercent := false
	    ]
	    ifFalse: [
		(wasPercent := (char = $%))
		    ifFalse: [ result nextPut: char ]
	    ]
    ].

    ^result contents
! !


!CharacterArray methodsFor: 'converting'!

asNumber
    "Parse a Number from the receiver until the input character is invalid
     and answer the result at this point"

    ^Number readFrom: (ReadStream on: self)
!

asUppercase
    "Returns a copy of self as an uppercase CharacterArray"
    | newStr |
    newStr := self copyEmpty: self size.
    1 to: self size do:
    	[ :i | newStr at: i put: (self at: i) asUppercase ].
    ^newStr
!

asLowercase
    "Returns a copy of self as a lowercase CharacterArray"
    | newStr |
    newStr := self copyEmpty: self size.
    1 to: self size do:
    	[ :i | newStr at: i put: (self at: i) asLowercase ].
    ^newStr
!

asString
    "But I already am a String!  Really!"
    self subclassResponsibility
!

asGlobalKey
    "Return the receiver, ready to be put in the Smalltalk dictionary"
    ^self asSymbol
!

asPoolKey
    "Return the receiver, ready to be put in a pool dictionary"
    ^self asSymbol
!

asClassPoolKey
    "Return the receiver, ready to be put in a class pool dictionary"
    ^self asSymbol
!

asByteArray
    "Return the receiver, converted to a ByteArray of ASCII values"
    ^self asString asByteArray
!

asInteger
    "Parse an Integer number from the receiver until the input character
     is invalid and answer the result at this point"
    | result i sign ch |
    self isEmpty ifTrue: [ ^0 ].

    ch := self at: 1.
    ch = $-
	ifTrue: [
	    sign := -1. result := 0 ]
	ifFalse: [
	    ch isDigit ifFalse: [ ^0 ].
	    sign := 1. result := ch digitValue ].

    2 to: self size do: [ :i |
	ch := self at: i.
	ch isDigit ifFalse: [ ^result ].
	result := result * 10 + (ch digitValue * sign) ].
    ^result
!


fileName
    "But I don't HAVE a file name!"
    ^nil
!

filePos
    "But I don't HAVE a file position!"
    ^nil
!

isNumeric
    "Answer whether the receiver denotes a number"

    | stream ch |
    stream := ReadStream on: self.
    [ stream atEnd ifTrue: [^true].
      (ch := stream next) isDigit ] whileTrue: [
    ].
    ch = $. ifFalse: [^false].

    [   ch := stream next.
	ch isDigit ifFalse: [ ^false ]
	stream atEnd] whileFalse.
    ^true
!

asSymbol
    "Returns the symbol corresponding to the CharacterArray"
    self subclassResponsibility
!

trimSeparators
    "Return a copy of the reciever without any spaces on front or back.
     The implementation is protected against the `all blanks' case."

    "This is not implemented as two while loops, but as two nested
     #to:do:'s, for speed"
    1 to: self size do: [ :start |
	(self at: start) isSeparator ifFalse: [
	    self size to: start by: -1 do: [ :stop |
		(self at: stop) isSeparator ifFalse: [
		    ^self copyFrom: start to: stop
		]
	    ]. "to:by:do:"
	]
    ]. "to:do:"
    ^''
! !



!CharacterArray methodsFor: 'private'!

caseInsensitiveCompareTo: aCharacterArray
    "Answer a number < 0 if the receiver is less than aCharacterArray,
    a number > 0 if it is greater, or 0 if they are equal."

    | c1 c2 |
    " Scan self and aCharacterArray until a character is clearly greater or lesser
      (All preceding characters must have been equal).  If the end is reached,
      one of the CharacterArrays is a possibly improper initial substring of the other,
      and for the receiver to be less than aCharacterArray, it must be the initial
      substring."
    1 to: (self size min: aCharacterArray size) do: [ :i |
    	c1 := (self at: i) asLowercaseValue.
	c2 := (aCharacterArray at: i) asLowercaseValue.
	c1 = c2 ifFalse: [ ^c1 - c2 ].
    ].

    ^self size - aCharacterArray size!

matchSubstring: pp in: aCharacterArray at: i
    "Private - Match the pattern from the pp-th character of the receiver
     to the characters from the i-th in aCharacterArray. Answer nil if they
     don't match, else answer the last character making up the pattern"

    | result s |
    s := i.
    self from: pp to: self size keysAndValuesDo: [ :p :pc |

	pc = $*
	    ifTrue: [
		(aCharacterArray size + 1) to: s by: -1 do: [:ss |
		    result := self matchSubstring: p + 1
			in: aCharacterArray
			at: ss.

		    result notNil ifTrue: [ ^result ].
		].
		^nil ].

	s > aCharacterArray size ifTrue: [ ^nil ].

	pc = $# ifFalse: [
	    pc = (aCharacterArray at: s) ifFalse: [ ^nil ]
	].
	s := s + 1
    ].
    ^s - 1
! !


!CharacterArray methodsFor: 'testing functionality'!

isCharacterArray
    ^true
! !

