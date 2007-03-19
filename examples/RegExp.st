"======================================================================
|
|   Regular expressions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #RegularExpression
    instanceVariableNames: 'selectors params noDollar string'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Examples-Useful'!

!RegularExpression class methodsFor: 'instance creation'!

new
    self shouldNotImplement
!

fromString: aString
    ^super new parseString: aString
! !

!RegularExpression class methodsFor: 'parsing'!

match: aString to: regExp
    ^(self fromString: regExp) match: aString
! !

!RegularExpression methodsFor: 'parsing'!

match: aString

    ^self matchStream: (ReadStream on: aString) from: 1
!

matchStream: aStream

    ^self matchStream: aStream from: 1
! !

!RegularExpression methodsFor: 'private'!

parseString: aString
    "Private - Convert a regular expression to its internal representation"

    | regexp endPos |

    params := OrderedCollection new.
    selectors := OrderedCollection new.

    "Zero-length aString is a special case"
    aString size = 0
	ifTrue: [
	    noDollar := true.
	    self addDotAsterisk.
	    ^self
	].

    regexp := ReadStream on: aString.
    noDollar := aString last ~= $$.

    (regexp peekFor: $^)
	ifFalse: [ self addDotAsterisk ]

    endPos := noDollar
	ifTrue: [ aString size ]
	ifFalse: [ aString size - 1 ].

    [ regexp position > endPos ] whileFalse: [ self parseAtom: regexp ]
!

addDotAsterisk

    "Add an implicit .* sequence"
    params addLast: nil.
    selectors addLast: #wild0any:index:
!

parseAtom: regexp
    "Private - Parse an 'atom' of the regular expression. Add to selectors the
     selector to be called to match it, and add to params the first parameter that
     will be passed to this selector"

    | next |
    (next := regexp next) = $\
	ifTrue: [
	    params addLast: regexp next.
	    ^selectors addLast: #char:index:
	].

    (next = $+) & selectors notEmpty
	ifTrue: [
	    ^selectors
		at: selectors size
		put: ('wild1', selectors last) asSymbol
	].

    (next = $*) & selectors notEmpty
	ifTrue: [
	    ^selectors
		at: selectors size
		put: ('wild0', selectors last) asSymbol
	].

    next = $.
	ifTrue: [
	    params addLast: nil.
	    ^selectors addLast: #any:index:
	].

    next = $[
	ifTrue: [
	    (regexp peekFor: $^)
		ifTrue: [ selectors addLast: #notRange:index: ]
		ifFalse: [ selectors addLast: #range:index: ].

	    params addLast: (self parseRange: regexp).
	    ^selectors last
	].

    next = ${
	ifTrue: [
	    params addLast: (self parseOptional: regexp).
	    ^selectors addLast: #optional:index:
	].

    params addLast: next.
    ^selectors addLast: #char:index:
!

parseRange: regexp

    "Private - Parse a 'range atom', that is an atom that can match to seve-
     ral characters."

    | next answerStream |
    answerStream := WriteStream on: (String new: 8).  "Number out of a hat"

    [   (next := regexp next) = $] ] whileFalse: [
	answerStream nextPut: next.
	regexp atEnd ifTrue: [ self errorBadRegexp ].

	(regexp peekFor: $-) ifTrue: [
	    regexp atEnd ifTrue: [ self errorBadRegexp ].

	    next asciiValue + 1 to: regexp next asciiValue do: [:i |
		answerStream nextPut: i asCharacter
	    ]
	]
    ].
    ^answerStream contents!

parseOptional: regexp

    "Private - Parse an 'optional atom', that is an atom that can match to
     several regular expressions."

    | pos next result |
    pos := regexp position.
    result := OrderedCollection new.
    [
	(next := regexp next) = $\
	    ifTrue: [regexp next]
	    ifFalse: [
		next = $| ifTrue: [
		    result addLast: (self class fromString:
			'^', (regexp copyFrom: pos to: regexp position - 2)).
		    pos := regexp position
		].
		next = $} ifTrue: [
		    result addLast: (self class fromString:
			'^', (regexp copyFrom: pos to: regexp position - 2)).
		    ^result
		]
	    ].
	regexp atEnd
    ]   whileFalse: [ ].

    "If we come here, we have found no } : bad regular expression"
    self errorBadRegexp
!

errorBadRegexp

    "Seems like we had some problems parsing the regular expression"
    self error: 'Bad regular expression'
!

char: aCharacter index: dummy

    "Private - Check if the next character matchs to aCharacter"

    ^string atEnd
	ifTrue: [ false ]
	ifFalse: [ aCharacter = string next ]
!

any: dummy index: dummy2

    "Private - If we aren't at the end of the stream, skip a character, else
     answer false"

    ^string atEnd
	ifTrue: [ false ]
	ifFalse: [ string next. true ]
!

range: aString index: dummy

    "Private - Check if the next character is included in aString"

    ^string atEnd
	ifTrue: [ false ]
	ifFalse: [ aString includes: string next ]
!

notRange: aString index: dummy

    "Private - Check if the next character is not included in aString"

    ^string atEnd
	ifTrue: [ false]
	ifFalse: [ (aString includes: string next) not ]
!

optional: listOfRegexp index: dummy

    "Private - Check if the next characters match to any of the RegularExpression
     objects in listOfRegexp"

    | pos |

    string atEnd ifTrue: [^false].

    pos := string position.
    listOfRegexp do: [ :re |
	(re matchStream: string from: 1) ifTrue: [^true].
	string position: pos.
    ].
    ^false
!

wild0any: atLeast1 index: index

    "Private - Match a .* sequence"

    ^self matchWild: #any:index: with: nil following:
	[ self matchStream: string from: index + 1 ]
!

wild1any: atLeast1 index: index

    "Private - Match a .+ sequence"

    (self any: nil index: index) ifFalse: [^false].

    ^self matchWild: #any:index: with: nil following:
	[ self matchStream: string from: index + 1 ]
!

wild0range: aString index: index

    "Private - Match a [...]* sequence"

    ^self matchWild: #range:index: with: aString following:
	[ self matchStream: string from: index + 1 ]
!

wild1range: aString index: index

    "Private - Match a [...]+ sequence"

    (self range: aString index: index) ifFalse: [^false].
    ^self matchWild: #range:index: with: aString following:
	[ self matchStream: string from: index + 1 ]
!

wild0notRange: aString index: index

    "Private - Match a [...]* sequence"

    ^self matchWild: #notRange:index: with: aString following:
	[ self matchStream: string from: index + 1 ]
!

wild1notRange: aString index: index

    "Private - Match a [...]+ sequence"

    (self notRange: aString index: index) ifFalse: [^false].
    ^self matchWild: #notRange:index: with: aString following:
	[ self matchStream: string from: index + 1 ]
!

wild0char: aCharacter index: index

    "Private - Match a x* sequence"

    ^self matchWild: #char:index: with: aCharacter following:
	[ self matchStream: string from: index + 1 ]
!

wild1char: aCharacter index: index

    "Private - Match a x+ sequence"

    (self char: aCharacter index: index) ifFalse: [^false].
    ^self matchWild: #char:index: with: aCharacter following:
	[ self matchStream: string from: index + 1 ]
!

matchWild: aSymbol with: arg following: aBlock

    "Private - Helper function for * sequences (+ sequences are parsed by
     checking for a match and then treating them as * sequences: for example,
     x+ becomes xx*). Try to match as many characters as possible and then
     look if the remaining part of the string matches the rest of the regular
     expression (to do so, aBlock is evaluated): if yes, answer nil; if no,
     try again with one character less. For example, matching [ABC]*AC to the
     string BAC works in this way:
	  - try with the longest run of As, Bs or Cs (BAC). The rest of the
	    string (that is, nothing) doesn't match the regular expression AC, so...
	  - ...try with BA. The rest of the string (that is, C) doesn't match
	    the regular expression AC, so...
	  - ...try with B. The rest of the string (that is, AC) does match the
	    regular expression AC, so we answer nil"

    | first last |
    first := string position.
    last := self findLastWild: aSymbol with: arg.

    last to: first by: -1 do: [ :i |
	(aBlock value == false)
	    ifFalse: [ ^nil ].

	i > 1 ifTrue: [self position: i - 1].
    ].
    ^false
!

findLastWild: aSymbol with: arg
    "Send aSymbol with arg and nil as its parameter until it answers false and
     answer the position of the last character for which aSymbol answered true"

    [   string atEnd ifTrue: [ ^string position ].
	self perform: aSymbol with: arg with: nil ] whileTrue: [ ].

    string skip: -1.
    ^string position
!

matchStream: aStream from: firstIndex

    "Private - Match all the atoms from the firstIndex-th to the string on
     which aStream is streaming. Answer true or false"

    | result oldString |

    oldString := string.
    self string: aStream.

    firstIndex to: self numberOfAtoms do: [ :i |
	" result = true ---> go on; result = false ---> answer false;
	  result = nil ---> answer true"
	result := self matchAtom: i.
	result == true ifFalse: [ string := oldString. ^result isNil ].
    ].
    result := self checkIfAtEnd.
    string := oldString.
    ^result
!

string: aStream

    "Private - Tell the other methods which string is being parsed"

    string := aStream
!

checkIfAtEnd

    "Private - Answer true if there is no $ or if we're at the end of the
     parsed string"

    ^noDollar or: [string atEnd]
!

numberOfAtoms

    "Private - Answer the number of atoms in the receiver"

    ^selectors size
!

matchAtom: index

    "Private - Try to match an atom to string"

    | result |

    "index print. $  print.
     (selectors at: index) print. $  print.
     (params at: index) print. $  print.
     string peek print. $  printNl."

    ^self perform: (selectors at: index) with: (params at: index) with: index
! !
