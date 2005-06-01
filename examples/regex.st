"======================================================================
|
|   String manipulation and regular expression resolver
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2003, 2005 Free Software Foundation, Inc.
| Written by Dragomir Milevojevic, Paolo Bonzini, Mike Anderson.
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

CStruct subclass: #CRegexRegisters
        declaration: #( (#allocated #int)
			(#numRegs #int)
			(#beg (#ptr #int))
			(#end (#ptr #int)) )
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Regex'
!

Object subclass: #RegexResults
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Regex'
!

RegexResults subclass: #MatchingRegexResults
        instanceVariableNames: 'subject from to registers match cache'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Regex'
!

RegexResults subclass: #FailedMatchRegexResults
        instanceVariableNames: ''
        classVariableNames: 'NotMatched'
        poolDictionaries: ''
        category: 'Regex'
!

!FailedMatchRegexResults class methodsFor: 'private'!

initialize
    NotMatched := self new
!

notMatched
    ^NotMatched
! !

!FailedMatchRegexResults methodsFor: 'testing'!

matched
    ^false
!

ifMatched: oneArgBlock ifNotMatched: zeroArgBlock
    ^zeroArgBlock value
!

ifNotMatched: zeroArgBlock ifMatched: oneArgBlock
    ^zeroArgBlock value
!

ifNotMatched: zeroArgBlock
    ^zeroArgBlock value
!

ifMatched: oneArgBlock
    ^nil
! !

!MatchingRegexResults methodsFor: 'printing'!

printOn: aStream
    "Print a represention of the receiver on aStream."
    | ch |
    aStream
	nextPutAll: self class name;
        nextPut: $:;
        print: self match.
    ch := $(.
    1 to: self size do: [ :each |
	aStream nextPut: ch; print: (self at: each).
    ].
    self size > 0 ifTrue: [ aStream nextPut: $) ].
! !

!MatchingRegexResults methodsFor: 'testing'!

matched
    ^true
!

ifMatched: oneArgBlock ifNotMatched: zeroArgBlock
    ^oneArgBlock value: self
!

ifNotMatched: zeroArgBlock ifMatched: oneArgBlock
    ^oneArgBlock value: self
!

ifNotMatched: zeroArgBlock
    ^nil
!

ifMatched: oneArgBlock
    ^oneArgBlock value: self
! !

!MatchingRegexResults methodsFor: 'accessing'!

size
    ^registers size!

subject
    ^subject!

from
    ^from!

fromAt: anIndex
    | reg |
    anIndex = 0 ifTrue: [ ^from ].
    reg := registers at: anIndex.
    ^reg isNil ifTrue: [ nil ] ifFalse: [ reg first ]!

to
    ^to!

toAt: anIndex
    | reg |
    anIndex = 0 ifTrue: [ ^from ].
    reg := registers at: anIndex.
    ^reg isNil ifTrue: [ nil ] ifFalse: [ reg last ]!

match
    match isNil
	ifTrue: [ match := self subject copyFrom: from to: to ].
    ^match!

matchInterval
    ^from to: to!

at: anIndex
    | reg text |
    anIndex = 0 ifTrue: [ ^self match ].
    (cache at: anIndex) isNil
	ifTrue: [
	    reg := registers at: anIndex.
	    text := reg isNil
		ifTrue: [ nil ]
		ifFalse: [ self subject copyFrom: reg first to: reg last ].
	    cache at: anIndex put: text ].
    ^cache at: anIndex!

intervalAt: anIndex
    ^anIndex = 0
	ifTrue: [ from to: to ]
	ifFalse: [ registers at: anIndex ]!

size
    ^registers size! !

!MatchingRegexResults methodsFor: 'private'!

initialize: regs subject: aString
    from := regs matchBeg.
    to := regs matchEnd.
    registers := (1 to: regs numRegs value - 1) collect: [ :i |
	| beg end |
	beg := (regs begAt: i).
	end := (regs endAt: i).
	end < 0 ifTrue: [ nil ] ifFalse: [ beg to: end ] ].
    cache := Array new: registers size.
    subject := aString! !

    
" --- external function definitions --- "

!Regex class methodsFor: 'C call-outs'!

fromString: aString
    <cCall: 'reh_make_cacheable' returning: #smalltalk args: #(#smalltalk)>!

!String methodsFor: 'C call-outs'!

lengthOfRegexMatch: pattern from: from to: to
    <cCall: 'reh_match' returning: #int
	args: #(#selfSmalltalk #smalltalk #int #int)>!

searchRegexInternal: pattern from: from to: to
    <cCall: 'reh_search' returning: CRegexRegisters type
	args: #(#selfSmalltalk #smalltalk #int #int)>! !

!CRegexRegisters methodsFor: 'C call-outs'!

begAt: i
    ^(self beg value + i) value + 1!

matchBeg
    | begValue matchBeg |
    begValue := self beg value.
    begValue isNil ifTrue: [ ^-1 ].
    matchBeg := begValue value.
    matchBeg = -1 ifTrue: [ ^-1 ].
    ^begValue value + 1!

endAt: i
    ^(self end value + i) value!

matchEnd
    | endValue matchEnd |
    endValue := self end value.
    endValue isNil ifTrue: [ ^-1 ].
    matchEnd := endValue value.
    matchEnd = -1 ifTrue: [ ^-1 ].
    ^endValue value!

free
    <cCall: 'reh_free_registers' returning: #void
	args: #(#self)>! !

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

asRegex
    "Answer the receiver, converted to a Regex object."
    ^Regex fromString: self
!

=~ pattern
    "Answer a RegexResults object for matching the receiver against
     the Regex or String object pattern."
    | regs |
    regs := self searchRegexInternal: pattern from: 1 to: self size.
    ^regs matchBeg = -1
	ifTrue: [
	    regs free.
	    FailedMatchRegexResults notMatched
	]
	ifFalse: [
	    [ MatchingRegexResults new initialize: regs subject: self ]
		ensure: [ regs free ]
	]
!

searchRegex: pattern
    "A synonym for #=~"
    | regs |
    regs := self searchRegexInternal: pattern from: 1 to: self size.
    ^regs matchBeg = -1
	ifTrue: [
	    regs free.
	    FailedMatchRegexResults notMatched
	]
	ifFalse: [
	    [ MatchingRegexResults new initialize: regs subject: self ]
		ensure: [ regs free ]
	]
!

searchRegex: pattern startingAt: anIndex
    | regs |
    regs := self searchRegexInternal: pattern from: anIndex to: self size.
    ^regs matchBeg = -1
	ifTrue: [
	    regs free.
	    FailedMatchRegexResults notMatched
	]
	ifFalse: [
	    [ MatchingRegexResults new initialize: regs subject: self ]
		ensure: [ regs free ]
	]
!

searchRegex: pattern from: from to: to
    | regs |
    regs := self searchRegexInternal: pattern from: from to: to.
    ^regs matchBeg = -1
	ifTrue: [
	    regs free.
	    FailedMatchRegexResults notMatched
	]
	ifFalse: [
	    [ MatchingRegexResults new initialize: regs subject: self ]
		ensure: [ regs free ]
	]
!

indexOfRegex: regexString ifAbsent: excBlock
    "Answer whether an occurrence of the regex is present in the receiver"
    | regs beg end |
    regs := self searchRegexInternal: regexString from: 1 to: self size.
    beg := regs matchBeg.
    end := regs matchEnd.
    regs free.
    ^beg >= 1
	ifTrue: [ beg to: end ]
	ifFalse: [ excBlock value ]
!

indexOfRegex: regexString startingAt: index ifAbsent: excBlock
    | regs beg end |
    regs := self searchRegexInternal: regexString from: index to: self size.
    beg := regs matchBeg.
    end := regs matchEnd.
    regs free.
    ^beg >= 1
	ifTrue: [ beg to: end ]
	ifFalse: [ excBlock value ]
!

indexOfRegex: regexString from: from to: to ifAbsent: excBlock
    | regs beg end |
    regs := self searchRegexInternal: regexString from: from to: to.
    beg := regs matchBeg.
    end := regs matchEnd.
    regs free.
    ^beg >= 1
	ifTrue: [ beg to: end ]
	ifFalse: [ excBlock value ]
!

indexOfRegex: regexString
    | regs beg end |
    regs := self searchRegexInternal: regexString from: 1 to: self size.
    beg := regs matchBeg.
    end := regs matchEnd.
    regs free.
    ^beg >= 1
	ifTrue: [ beg to: end ]
	ifFalse: [ nil ]
!

indexOfRegex: regexString startingAt: index
    | regs beg end |
    regs := self searchRegexInternal: regexString from: index to: self size.
    beg := regs matchBeg.
    end := regs matchEnd.
    regs free.
    ^beg >= 1
	ifTrue: [ beg to: end ]
	ifFalse: [ nil ]
!

indexOfRegex: regexString from: from to: to
    | regs beg end |
    regs := self searchRegexInternal: regexString from: from to: to.
    beg := regs matchBeg.
    end := regs matchEnd.
    regs free.
    ^beg >= 1
	ifTrue: [ beg to: end ]
	ifFalse: [ nil ]
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

    | res idx regex beg end regs |
    regex := pattern asRegex.
    res := 0.
    idx := from.
    [
        regs := self searchRegexInternal: regex from: idx to: to.
        beg := regs matchBeg.
        end := regs matchEnd.
        regs free.
        beg >= 1
    ] whileTrue: [
	idx := end max: beg + 1.
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

    | regs beg end repl res |
    regs := self searchRegex: pattern from: from to: to.

    regs notNil
	ifTrue: [
	    beg := regs from.
	    end := regs to.
	    repl := str bindWithArguments: regs.
	    res := self species new: (to - from) - (end - beg) + repl size.
	    res replaceFrom: 1 to: beg - from with: self startingAt: from.
	    res replaceFrom: beg - from + 1 to: beg - from + repl size with: repl.
	    res replaceFrom: beg - from + repl size + 1 to: res size with: self startingAt: end - from + 2 ]
	ifFalse: [ res := self copyFrom: from to: to ].

    ^res
!

copyReplacingRegex: pattern with: str
    "Searches for pattern and replaces it with another string value"

    ^self copyFrom: 1 to: self size replacingRegex: pattern with: str
!

copyFrom: from to: to replacingAllRegex: pattern with: str
    "Replaces all occurances of pattern between boundaries with specified string"

    | res idx regex beg end regs |
    regex := pattern asRegex.
    res := WriteStream on: (String new: to - from + 1).
    idx := from.
    [
        regs := self searchRegex: regex from: idx to: to.
	regs notNil
    ] whileTrue: [
	beg := regs from.
	end := regs to.
	res next: beg - idx putAll: self startingAt: idx.
	res nextPutAll: (str bindWithArguments: regs).
	idx := end + 1.
	beg > end ifTrue: [ res nextPut: (self at: idx). idx := idx + 1 ].
	idx > self size ifTrue: [ ^res contents ].
    ].
    res next: to - idx + 1 putAll: self startingAt: idx.

    ^res contents
!

copyReplacingAllRegex: pattern with: str
    "Searches for pattern and replaces it with another string value"

    ^self copyFrom: 1 to: self size replacingAllRegex: pattern with: str
!

onOccurrencesOfRegex: pattern from: from to: to do: body
"Searches for pattern and executed passed instruction-body (as a trigger)"

    | idx regex beg end regs |
    regex := pattern asRegex.
    idx := from.
    [
        regs := self searchRegexInternal: regex from: idx to: to.
        beg := regs matchBeg.
        end := regs matchEnd.
        regs free.
        beg >= 1
    ] whileTrue: [
	body value: beg value: end - beg + 1.
	idx := end + 1 max: beg + 1.
    ].
!

onOccurrencesOfRegex: pattern do: body
"Searches for pattern and executed passed instruction-body (as a trigger)"

    ^self onOccurrencesOfRegex: pattern from: 1 to: self size do: body
!

tokenize: pattern from: from to: to
    | res idx regex beg end regs tokStart |
    regex := pattern asRegex.
    res := WriteStream on: (Array new: 10).
    idx := from.
    tokStart := 1.
    [
        regs := self searchRegexInternal: regex from: idx to: to.
        beg := regs matchBeg.
        end := regs matchEnd.
        regs free.
        beg >= 1
    ] whileTrue: [
	res nextPut: (self copyFrom: tokStart to: beg - 1).
	tokStart := end + 1.
	idx := beg + 1 max: end + 1.
    ].

    res nextPut: (self copyFrom: tokStart to: to).
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

FailedMatchRegexResults initialize!
