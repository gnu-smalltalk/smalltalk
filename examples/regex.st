"======================================================================
|
|   String manipulation and regular expression resolver
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2003, 2005 Free Software Foundation, Inc.
| Written by Dragomir Milivojevic.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

String variableByteSubclass: #Regex
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Modules'
!

Regex comment: '
A Regex is equivalent to a String, except that it is read-only and that
the regular expression matcher caches a compiled representation of the
most recently used Regexes, thus speeding up matching.  Regex objects
are constructed automatically by methods that expect to match many
times the same regular expression, but can be constructed explicitly
sending #asRegex to a String or Symbol.

Creation of Regex objects inside a loop is of course slower than creating
them outside the loop, but special care is taken so that the same Regex
object is used whenever possible (when converting Strings to Regex, the
cache is sought for an equivalent, already constructed Regex).'.

" --- external function definitions --- "

!Regex class methodsFor: 'C call-outs'!

fromString: aString
    <cCall: 'reh_make_cacheable' returning: #smalltalk args: #(#smalltalk)>!

!String methodsFor: 'C call-outs'!

searchRegex: pattern from: from to: to
    <cCall: 'reh_search' returning: #int
	args: #(#selfSmalltalk #smalltalk #int #int)>!

lengthOfRegexMatch: pattern from: from to: to
    <cCall: 'reh_match' returning: #int
	args: #(#selfSmalltalk #smalltalk #int #int)>! !

"--------------------------------------------------------------------------"

!Regex class methodsFor: 'instance creation'!

new
    self error: 'please use #fromString: to create instances'! !

!Regex methodsFor: 'basic'!

at: anIndex put: anObject
    self shouldNotImplement
!

copy
    "Answer the receiver; instances of Regex are identity objects because
     their only purpose is to ease caching, and we obtain better caching
     if we avoid copying Regex objects"
    ^self
! !

!Regex methodsFor: 'conversion'!

asRegex
    "Answer the receiver, which *is* a Regex!"
    ^self
!

asString
    "Answer the receiver, converted back to a String"
    ^self collect: [ :each | each ]
!

species
    ^String
! !

!Regex methodsFor: 'printing'!

displayString
    "Answer a String representing the receiver. For most objects
     this is simply its #printString, but for strings and characters,
     superfluous dollars or extra pair of quotes are stripped."
    | stream |
    stream := WriteStream on: (String new: 0).
    self displayOn: stream.
    ^stream contents
!

displayOn: aStream
    "Print a represention of the receiver on aStream. For most objects
     this is simply its #printOn: representation, but for strings and
     characters, superfluous dollars or extra pairs of quotes are stripped."
    self printOn: aStream
!

printOn: aStream
    "Print a represention of the receiver on aStream."
    aStream nextPut: $/.
    self do: [ :each |
	each = $/ ifTrue: [ aStream nextPut: $\ ].
	aStream nextPut: each.
    ].
    aStream nextPut: $/.
! !

"--------------------------------------------------------------------------"

!String methodsFor: 'regex'!

=~ regexString
    "Answer whether an occurrence of the regex is present in the receiver"
    ^(self searchRegex: regexString from: 1 to: self size) > 0
!

asRegex
    "Answer the receiver, converted to a Regex object."
    ^Regex fromString: self
!

indexOfRegex: regexString ifAbsent: excBlock
    "Answer whether an occurrence of the regex is present in the receiver"
    | start len |
    start := self searchRegex: regexString from: 1 to: self size.
    start > 0 ifFalse: [ ^excBlock value ].

    len := self lengthOfRegexMatch: regexString from: start to: self size.
    ^start to: start + len - 1
!

indexOfRegex: regexString startingAt: index ifAbsent: excBlock
    | start len |
    start := self searchRegex: regexString from: index to: self size.
    start > 0 ifFalse: [ ^excBlock value ].

    len := self lengthOfRegexMatch: regexString from: start to: self size.
    ^start to: start + len - 1
!

indexOfRegex: regexString from: start to: end ifAbsent: excBlock
    | idx len |
    idx := self searchRegex: regexString from: idx to: end.
    idx > 0 ifFalse: [ ^excBlock value ].
    
    len := self lengthOfRegexMatch: regexString from: idx to: self size.
    ^start to: start + len - 1
!

indexOfRegex: regexString
    "Answer whether an occurrence of the regex is present in the receiver"
    | start len |
    start := self searchRegex: regexString from: 1 to: self size.
    start > 0 ifFalse: [ ^nil ].

    len := self lengthOfRegexMatch: regexString from: start to: self size.
    ^start to: start + len - 1
!

indexOfRegex: regexString startingAt: index
    | start len |
    start := self searchRegex: regexString from: index to: self size.
    start > 0 ifFalse: [ ^nil ].

    len := self lengthOfRegexMatch: regexString from: start to: self size.
    ^start to: start + len - 1
!

indexOfRegex: regexString from: start to: end
    | idx len |
    idx := self searchRegex: regexString from: idx to: end.
    idx > 0 ifFalse: [ ^nil ].
    
    len := self lengthOfRegexMatch: regexString from: start to: self size.
    ^start to: start + len - 1
!

matchRegex: pattern
    ^(self lengthOfRegexMatch: pattern from: 1 to: self size) = self size
!

matchRegex: pattern startingAt: idx
    ^(self lengthOfRegexMatch: pattern from: idx to: self size) > 0
!

matchRegex: pattern from: from to: to
    ^(self lengthOfRegexMatch: pattern from: from to: to) = (to - from + 1)
!

occurrencesOfRegex: pattern from: from to: to
    "Returns count of how many times pattern repeats in string"

    | res idx len regex |
    regex := pattern asRegex.
    res := 0.
    idx := from.
    [
	idx <= to and: [
	    idx := self searchRegex: regex from: idx to: to.
	    idx > 0 ]
    ] whileTrue: [
	
	len := self lengthOfRegexMatch: regex from: idx to: to.
	len = 0 ifTrue: [ len := 1 ].
	
	idx := idx + len.
	res := res + 1.
    ].

    ^res
!
    
occurrencesOfRegex: pattern startingAt: index
    "Returns count of how many times pattern repeats in string"

    ^self occurrencesOfRegex: pattern from: index to: self size.
!

occurrencesOfRegex: pattern
    "Returns count of how many times pattern repeats in string"

    ^self occurrencesOfRegex: pattern from: 1 to: self size.
!

copyFrom: from to: to replacingRegex: pattern with: str
    "Replaces first occurance of pattern with provided string"

    | res idx len |

    idx := self searchRegex: pattern from: from to: to.

    idx > 0 ifTrue: [
	res := self copyFrom: from to: idx - 1.
	res := res, str.

	idx := idx + (self lengthOfRegexMatch: pattern from: idx to: to).

	idx <= to ifTrue: 
	    [ res := res, (self copyFrom: idx to: to) ].

	^ res
    ].
	
    ^self copyFrom: from to: to
!

copyReplacingRegex: pattern with: str
    "Searches for pattern and replaces it with another string value"

    ^self copyFrom: 1 to: self size replacingRegex: pattern with: str
!

copyFrom: from to: to replacingAllRegex: pattern with: str
    "Replaces all occurances of pattern between boundaries with specified string"

    | res oldIdx idx len regex |
    idx := from.
    res := WriteStream on: self copyEmpty.
    regex := pattern asRegex.

    [
	oldIdx := idx.
	idx <= to and: [
	    idx := self searchRegex: regex from: idx to: to.
	    idx > 0 ]
    ] whileTrue: [
	oldIdx to: idx - 1 do: [ :each |
	    res nextPut: (self at: each) ].
	    
	len := self lengthOfRegexMatch: regex from: idx to: to.
	len = 0 ifTrue: [ len := 1 ].
	
	res nextPutAll: str.
	idx := idx + len.
    ].

    oldIdx to: to do: [ :each |
	res nextPut: (self at: each) ].

    ^res contents
!

copyReplacingAllRegex: pattern with: str
    "Searches for pattern and replaces it with another string value"

    ^self copyFrom: 1 to: self size replacingAllRegex: pattern with: str
!

onOccurrencesOfRegex: pattern from: from to: to do: body
"Searches for pattern and executed passed instruction-body (as a trigger)"

    | idx len res regex |
    idx := from.
    regex := pattern asRegex.
    
    [
	idx <= to and: [
	    idx := self searchRegex: regex from: idx to: to.
	    idx > 0 ]
    ] whileTrue: [
	len := self lengthOfRegexMatch: regex from: idx to: to.
	
	body value: idx value: len.
	len = 0 ifTrue: [ len := 1 ].
	idx := idx + len.
    ].
!

onOccurrencesOfRegex: pattern do: body
"Searches for pattern and executed passed instruction-body (as a trigger)"

    ^self onOccurrencesOfRegex: pattern from: 1 to: self size do: body
!

tokenize: pattern from: from to: to

    | res oldIdx idx len regex |
    idx := from.
    res := WriteStream on: (Array new: 10).
    regex := pattern asRegex.
    
    [
	oldIdx := idx.
	idx <= to and: [
	    idx := self searchRegex: regex from: idx to: to.
	    idx > 0 ]
    ] whileTrue: [
	len := self lengthOfRegexMatch: regex from: idx to: to.
	res nextPut: (self copyFrom: oldIdx to: idx - 1).

	len = 0 ifTrue: [ len := 1 ].
	idx := idx + len.
    ].

    oldIdx <= to ifTrue: [
	res nextPut: (self copyFrom: oldIdx to: to)
    ].
    ^res contents
!

tokenizeFrom: from to: to
    ^self tokenize: '[\n\t ]+' from: from to: to
!

tokenize: pattern
    ^self tokenize: pattern from: 1 to: self size
!

tokenize

    ^self tokenize: '[\n\t ]+' from: 1 to: self size
! !

