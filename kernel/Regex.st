"======================================================================
|
|   String manipulation and regular expression resolver
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2003, 2005, 2006 Free Software Foundation, Inc.
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
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


String variable: #character subclass: #Regex
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Text'
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

Object subclass: #RegexResults
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Collections-Text'
!

RegexResults comment: '
I hold the results of a regular expression match, and I can reconstruct
which parts of the matched string were assigned to each subexpression.
Methods such as #=~ return RegexResults objects, while others transform
the string directly without passing the results object back to the
caller.'!


Namespace current: Kernel!

RegexResults subclass: #MatchingRegexResults
        instanceVariableNames: 'subject from to registers match cache'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Collections-Text'
!

RegexResults subclass: #FailedMatchRegexResults
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Collections-Text'
!

FailedMatchRegexResults class
	instanceVariableNames: 'uniqueInstance'!

Namespace current: Smalltalk!

!RegexResults methodsFor: 'testing'!

matched
    "Answer whether the regular expression was matched"
    self subclassResponsibility
!

ifMatched: oneArgBlock ifNotMatched: zeroArgBlock
    "If the regular expression was matched, evaluate oneArgBlock with the
     receiver as the argument.  If it was not, evaluate zeroArgBlock.
     Answer the result of the block's evaluation."
    self subclassResponsibility
!

ifNotMatched: zeroArgBlock ifMatched: oneArgBlock
    "If the regular expression was matched, evaluate oneArgBlock with the
     receiver as the argument.  If it was not, evaluate zeroArgBlock.
     Answer the result of the block's evaluation."
    self subclassResponsibility
!

ifNotMatched: zeroArgBlock
    "If the regular expression was matched, return the receiver.  If it was
     not, evaluate zeroArgBlock and return its result."
    ^self ifNotMatched: zeroArgBlock ifMatched: [ :results | results ]
!

ifMatched: oneArgBlock
    "If the regular expression was matched, pass the receiver to
     oneArgBlock and return its result.  Otherwise, return nil."
    ^self ifNotMatched: [ nil ] ifMatched: oneArgBlock
! !

!RegexResults methodsFor: 'accessing'!

size
    "If the regular expression was matched, return the number
     of subexpressions that were present in the regular expression."
    self subclassResponsibility!

subject
    "If the regular expression was matched, return the text
     that was matched against it."
    self subclassResponsibility!

from
    "If the regular expression was matched, return the index
     of the first character in the successful match."
    self subclassResponsibility!

fromAt: anIndex
    "If the regular expression was matched, return the index of the first
     character of the anIndex-th subexpression in the successful match."
    self subclassResponsibility!

to
    "If the regular expression was matched, return the index
     of the last character in the successful match."
    self subclassResponsibility!

toAt: anIndex
    "If the regular expression was matched, return the index of the last
     character of the anIndex-th subexpression in the successful match."
    self subclassResponsibility!

match
    "If the regular expression was matched, return the text of the
     successful match."
    self subclassResponsibility!

matchInterval
    "If the regular expression was matched, return an Interval for the
     range of indices of the successful match."
    self subclassResponsibility!

at: anIndex
    "If the regular expression was matched, return the text of the
     anIndex-th subexpression in the successful match."
    self subclassResponsibility!

intervalAt: anIndex
    "If the regular expression was matched, return an Interval for the range
     of indices in the anIndex-th subexpression of the successful match."
    self subclassResponsibility! !


!Kernel.FailedMatchRegexResults class methodsFor: 'private'!

uniqueInstance
    ^uniqueInstance isNil
	ifTrue: [ uniqueInstance := self new ]
	ifFalse: [ uniqueInstance ]
! !

!Kernel.FailedMatchRegexResults methodsFor: 'testing'!

matched
    ^false
!

ifMatched: oneArgBlock ifNotMatched: zeroArgBlock
    ^zeroArgBlock value
!

ifNotMatched: zeroArgBlock ifMatched: oneArgBlock
    ^zeroArgBlock value
! !

!Kernel.FailedMatchRegexResults methodsFor: 'accessing'!

size
    self shouldNotImplement!

subject
    self shouldNotImplement!

from
    self shouldNotImplement!

fromAt: anIndex
    self shouldNotImplement!

to
    self shouldNotImplement!

toAt: anIndex
    self shouldNotImplement!

match
    self shouldNotImplement!

matchInterval
    self shouldNotImplement!

at: anIndex
    self shouldNotImplement!

intervalAt: anIndex
    self shouldNotImplement! !


!Kernel.MatchingRegexResults methodsFor: 'printing'!

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

!Kernel.MatchingRegexResults methodsFor: 'testing'!

matched
    ^true
!

ifMatched: oneArgBlock ifNotMatched: zeroArgBlock
    ^oneArgBlock value: self
!

ifNotMatched: zeroArgBlock ifMatched: oneArgBlock
    ^oneArgBlock value: self
! !

!Kernel.MatchingRegexResults methodsFor: 'accessing'!

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
    cache isNil ifTrue: [ cache := Array new: registers size ].
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
	ifFalse: [ registers at: anIndex ]! !


!Regex class methodsFor: 'instance creation'!

fromString: aString
    <cCall: 'reh_make_cacheable' returning: #smalltalk args: #(#smalltalk)>!

new
    self error: 'please use #fromString: to create instances'! !

!Regex methodsFor: 'basic'!

at: anIndex put: anObject
    "Fail.  Regex objects are read-only."
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
    ^(String new: self size)
	replaceFrom: 1 to: self size with: self startingAt: 1;
	yourself
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


!String methodsFor: 'C call-outs'!

lengthOfRegexMatch: pattern from: from to: to
    <cCall: 'reh_match' returning: #int
	args: #(#selfSmalltalk #smalltalk #int #int)>!

searchRegexInternal: pattern from: from to: to
    <cCall: 'reh_search' returning: #smalltalk
	args: #(#selfSmalltalk #smalltalk #int #int)>! !

!String methodsFor: 'regex'!

asRegex
    "Answer the receiver, converted to a Regex object."
    ^Regex fromString: self
!

~ pattern
    "Answer whether the receiver matched against the Regex or String
    object pattern."
    | regs |
    regs := self searchRegexInternal: pattern from: 1 to: self size.
    ^regs notNil
!

=~ pattern
    "Answer a RegexResults object for matching the receiver against
     the Regex or String object pattern."
    | regs |
    regs := self searchRegexInternal: pattern from: 1 to: self size.
    ^regs isNil
	ifTrue: [ Kernel.FailedMatchRegexResults uniqueInstance ]
	ifFalse: [ regs ]
!

searchRegex: pattern
    "A synonym for #=~.  Answer a RegexResults object for matching the receiver
     against the Regex or String object pattern."
    | regs |
    regs := self searchRegexInternal: pattern from: 1 to: self size.
    ^regs isNil
	ifTrue: [ Kernel.FailedMatchRegexResults uniqueInstance ]
	ifFalse: [ regs ]
!

searchRegex: pattern startingAt: anIndex
    "Answer a RegexResults object for matching the receiver
     against the Regex or String object pattern, starting the match
     at index anIndex."
    | regs |
    regs := self searchRegexInternal: pattern from: anIndex to: self size.
    ^regs isNil
	ifTrue: [ Kernel.FailedMatchRegexResults uniqueInstance ]
	ifFalse: [ regs ]
!

searchRegex: pattern from: from to: to
    "Answer a RegexResults object for matching the receiver
     against the Regex or String object pattern, restricting the match
     to the specified range of indices."
    | regs |
    regs := self searchRegexInternal: pattern from: from to: to.
    ^regs isNil
	ifTrue: [ Kernel.FailedMatchRegexResults uniqueInstance ]
	ifFalse: [ regs ]
!

indexOfRegex: regexString ifAbsent: excBlock
    "If an occurrence of the regex is present in the receiver, return
     the Interval corresponding to the leftmost-longest match.  Otherwise,
     evaluate excBlock and return the result."
    | regs |
    regs := self searchRegexInternal: regexString from: 1 to: self size.
    ^regs isNil
	ifFalse: [ regs matchInterval ]
	ifTrue: [ excBlock value ]
!

indexOfRegex: regexString startingAt: index ifAbsent: excBlock
    "If an occurrence of the regex is present in the receiver, return
     the Interval corresponding to the leftmost-longest match starting after
     the given index.  Otherwise, evaluate excBlock and return the result."
    | regs |
    regs := self searchRegexInternal: regexString from: index to: self size.
    ^regs isNil
	ifFalse: [ regs matchInterval ]
	ifTrue: [ excBlock value ]
!

indexOfRegex: regexString from: from to: to ifAbsent: excBlock
    "If an occurrence of the regex is present in the receiver, return the
     Interval corresponding to the leftmost-longest match occurring within
     the given indices.  Otherwise, evaluate excBlock and return the result."
    | regs |
    regs := self searchRegexInternal: regexString from: from to: to.
    ^regs isNil
	ifFalse: [ regs matchInterval ]
	ifTrue: [ excBlock value ]
!

indexOfRegex: regexString
    "If an occurrence of the regex is present in the receiver, return the
     Interval corresponding to the leftmost-longest match.  Otherwise return
     nil."
    | regs |
    regs := self searchRegexInternal: regexString from: 1 to: self size.
    ^regs isNil ifFalse: [ regs matchInterval ]
!

indexOfRegex: regexString startingAt: index
    "If an occurrence of the regex is present in the receiver, return the
     Interval corresponding to the leftmost-longest match starting after
     the given index.  Otherwise return nil."
    | regs |
    regs := self searchRegexInternal: regexString from: index to: self size.
    ^regs isNil ifFalse: [ regs matchInterval ]
!

indexOfRegex: regexString from: from to: to
    "If an occurrence of the regex is present in the receiver, return the
     Interval corresponding to the leftmost-longest match occurring within
     the given range of indices.  Otherwise return nil."
    | regs |
    regs := self searchRegexInternal: regexString from: from to: to.
    ^regs isNil ifFalse: [ regs matchInterval ]
!

matchRegex: pattern
    "Answer whether the receiver is an exact match for the pattern.
     This means that the pattern is implicitly anchored at the beginning
     and the end."
    ^(self lengthOfRegexMatch: pattern from: 1 to: self size) = self size
!

matchRegex: pattern from: from to: to
    "Answer whether the given range of indices is an exact match for the
     pattern.  This means that there is a match starting at from and ending
     at to (which is not necessarily the longest match starting at from)."
    ^(self lengthOfRegexMatch: pattern from: from to: to) = (to - from + 1)
!

occurrencesOfRegex: pattern from: from to: to
    "Return a count of how many times pattern repeats in the receiver within
     the given range of index."

    | res idx regex regs |
    regex := pattern asRegex.
    res := 0.
    idx := from.
    [
        regs := self searchRegexInternal: regex from: idx to: to.
        regs notNil
    ] whileTrue: [
	idx := regs to max: regs from + 1.
	res := res + 1.
    ].

    ^res
!
    
occurrencesOfRegex: pattern startingAt: index
    "Returns count of how many times pattern repeats in the receiver, starting
     the search at the given index."

    ^self occurrencesOfRegex: pattern from: index to: self size.
!

occurrencesOfRegex: pattern
    "Returns count of how many times pattern repeats in the receiver."

    ^self occurrencesOfRegex: pattern from: 1 to: self size.
!

copyFrom: from to: to replacingRegex: pattern with: str
    "Returns the substring of the receiver between from and to.  
     If pattern has a match in that part of the string, the match
     is replaced with str after substituting %n sequences with the 
     captured subexpressions of the match (as in #bindWithArguments:)."
    | regs beg end repl res |
    regs := self searchRegex: pattern from: from to: to.

    regs matched
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
    "Returns the receiver after replacing the first match of pattern (if
     any) with str.  %n sequences present in str are substituted with the 
     captured subexpressions of the match (as in #bindWithArguments:)."

    ^self copyFrom: 1 to: self size replacingRegex: pattern with: str
!

copyFrom: from to: to replacingAllRegex: pattern with: str
    "Returns the substring of the receiver between from and to.  
     Any match of pattern in that part of the string is replaced with
     str after substituting %n sequences with the captured subexpressions
     of the match (as in #bindWithArguments:)."

    | res idx regex beg end regs |
    regex := pattern asRegex.
    res := WriteStream on: (String new: to - from + 1).
    idx := from.
    [
        regs := self searchRegex: regex from: idx to: to.
	regs matched
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
    "Returns the receiver after replacing all the matches of pattern (if
     any) with str.  %n sequences present in str are substituted with the 
     captured subexpressions of the match (as in #bindWithArguments:)."

    ^self copyFrom: 1 to: self size replacingAllRegex: pattern with: str
!

onOccurrencesOfRegex: pattern from: from to: to do: aBlock
    "Find all the matches of pattern within the receiver and within the
     given range of indices.  For each match, pass the RegexResults object 
     to aBlock."

    | idx regex regs |
    regex := pattern asRegex.
    idx := from.
    [
        regs := self searchRegexInternal: regex from: idx to: to.
        regs notNil
    ] whileTrue: [
	aBlock value: regs.
	idx := regs to + 1 max: regs from + 1.
    ].
    regs free.
!

onOccurrencesOfRegex: pattern do: body
    "Find all the matches of pattern within the receiver and, for each match,
     pass the RegexResults object to aBlock."

    ^self onOccurrencesOfRegex: pattern from: 1 to: self size do: body
!

tokenize: pattern from: from to: to
    "Split the receiver at every occurrence of pattern (considering only
     the indices between from and to).  All parts that do not match pattern
     are separated and stored into an Array of Strings that is returned."
    | res idx regex regs tokStart |
    regex := pattern asRegex.
    res := WriteStream on: (Array new: 10).
    idx := from.
    tokStart := 1.
    [
        regs := self searchRegexInternal: regex from: idx to: to.
        regs notNil
    ] whileTrue: [
	res nextPut: (self copyFrom: tokStart to: regs from - 1).
	tokStart := regs to + 1.
	idx := regs to + 1 max: regs from + 1.
    ].

    res nextPut: (self copyFrom: tokStart to: to).
    ^res contents
!

tokenize: pattern
    "Split the receiver at every occurrence of pattern.  All parts that do not
     match pattern are separated and stored into an Array of Strings that is
     returned."
    ^self tokenize: pattern from: 1 to: self size
! !

Kernel.FailedMatchRegexResults initialize!
