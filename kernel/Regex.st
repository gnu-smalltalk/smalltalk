"======================================================================
|
|   String manipulation and regular expression resolver
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2005, 2006, 2007, 2008, 2009
| Free Software Foundation, Inc.
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



Object subclass: Regex [
    
    <shape: #character>
    <category: 'Collections-Text'>
    <comment: '
A Regex is a read-only string for which the regular expression matcher
can cache a compiled representation, thus speeding up matching.  Regex
objects are constructed automatically by methods that expect to match many
times the same regular expression, but can also be constructed explicitly
sending #asRegex to a String or Symbol.

Creation of Regex objects inside a loop is of course slower than creating
them outside the loop, but special care is taken so that the same Regex
object is used whenever possible (when converting Strings to Regex, the
cache is sought for an equivalent, already constructed Regex).'>

    Regex class >> fromString: aString [
	"Like `aString asRegex'."
	<category: 'instance creation'>
	<cCall: 'reh_make_cacheable' returning: #smalltalk args: #(#smalltalk)>
	
    ]

    Regex class >> new [
	"Do not send this message."
	<category: 'instance creation'>
	self error: 'please use #fromString: to create instances'
    ]

    at: anIndex put: anObject [
	"Fail.  Regex objects are read-only."

	<category: 'basic'>
	self shouldNotImplement
    ]

    copy [
	"Answer the receiver; instances of Regex are identity objects because
	 their only purpose is to ease caching, and we obtain better caching
	 if we avoid copying Regex objects"

	<category: 'basic'>
	^self
    ]

    asRegex [
	"Answer the receiver, which *is* a Regex!"

	<category: 'conversion'>
	^self
    ]

    asString [
	"Answer the receiver, converted back to a String"

	<category: 'conversion'>
	^(String new: self size)
	    replaceFrom: 1
		to: self size
		with: self
		startingAt: 1;
	    yourself
    ]

    species [
	<category: 'conversion'>
	^String
    ]

    displayString [
	"Answer a String representing the receiver. For most objects
	 this is simply its #printString, but for strings and characters,
	 superfluous dollars or extra pair of quotes are stripped."

	<category: 'printing'>
	| stream |
	stream := WriteStream on: (String new: 0).
	self displayOn: stream.
	^stream contents
    ]

    displayOn: aStream [
	"Print a represention of the receiver on aStream. For most objects
	 this is simply its #printOn: representation, but for strings and
	 characters, superfluous dollars or extra pairs of quotes are stripped."

	<category: 'printing'>
	self printOn: aStream
    ]

    printOn: aStream [
	"Print a represention of the receiver on aStream."

	<category: 'printing'>
	aStream nextPut: $/.
	self asString do: 
		[:each | 
		each = $/ ifTrue: [ aStream nextPut: $\ ].
		aStream nextPut: each].
	aStream nextPut: $/
    ]
]



Object subclass: RegexResults [
    
    <category: 'Collections-Text'>
    <comment: '
I hold the results of a regular expression match, and I can reconstruct
which parts of the matched string were assigned to each subexpression.
Methods such as #=~ return RegexResults objects, while others transform
the string directly without passing the results object back to the
caller.'>

    matched [
	"Answer whether the regular expression was matched"

	<category: 'testing'>
	self subclassResponsibility
    ]

    ifMatched: oneArgBlock ifNotMatched: zeroArgBlock [
	"If the regular expression was matched, evaluate oneArgBlock with the
	 receiver as the argument.  If it was not, evaluate zeroArgBlock.
	 Answer the result of the block's evaluation."

	<category: 'testing'>
	self subclassResponsibility
    ]

    ifNotMatched: zeroArgBlock ifMatched: oneArgBlock [
	"If the regular expression was matched, evaluate oneArgBlock with the
	 receiver as the argument.  If it was not, evaluate zeroArgBlock.
	 Answer the result of the block's evaluation."

	<category: 'testing'>
	self subclassResponsibility
    ]

    ifNotMatched: zeroArgBlock [
	"If the regular expression was matched, return the receiver.  If it was
	 not, evaluate zeroArgBlock and return its result."

	<category: 'testing'>
	^self ifNotMatched: zeroArgBlock ifMatched: []
    ]

    ifMatched: oneArgBlock [
	"If the regular expression was matched, pass the receiver to
	 oneArgBlock and return its result.  Otherwise, return nil."

	<category: 'testing'>
	^self ifNotMatched: [] ifMatched: oneArgBlock
    ]

    size [
	"If the regular expression was matched, return the number
	 of subexpressions that were present in the regular expression."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    asArray [
	"If the regular expression was matched, return an Array with
	 the subexpressions that were present in the regular expression."

	<category: 'accessing'>
	^1 to: self size collect: [ :each | self at: each ]
    ]

    subject [
	"If the regular expression was matched, return the text
	 that was matched against it."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    from [
	"If the regular expression was matched, return the index
	 of the first character in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    fromAt: anIndex [
	"If the regular expression was matched, return the index of the first
	 character of the anIndex-th subexpression in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    to [
	"If the regular expression was matched, return the index
	 of the last character in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    toAt: anIndex [
	"If the regular expression was matched, return the index of the last
	 character of the anIndex-th subexpression in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    match [
	"If the regular expression was matched, return the text of the
	 successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    matchInterval [
	"If the regular expression was matched, return an Interval for the
	 range of indices of the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    at: anIndex [
	"If the regular expression was matched, return the text of the
	 anIndex-th subexpression in the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    intervalAt: anIndex [
	"If the regular expression was matched, return an Interval for the range
	 of indices in the anIndex-th subexpression of the successful match."

	<category: 'accessing'>
	self subclassResponsibility
    ]
]



Namespace current: Kernel [

RegexResults subclass: MatchingRegexResults [
    | subject from to registers match cache |
    
    <category: 'Collections-Text'>
    <comment: nil>

    printOn: aStream [
	"Print a represention of the receiver on aStream."

	<category: 'printing'>
	| ch |
	aStream
	    nextPutAll: self class name;
	    nextPut: $:;
	    print: self match.
	ch := $(.
	1 to: self size
	    do: 
		[:each | 
		aStream
		    nextPut: ch;
		    print: (self at: each).
                ch := $,].
	self size > 0 ifTrue: [aStream nextPut: $)]
    ]

    matched [
	<category: 'testing'>
	^true
    ]

    ifMatched: oneArgBlock ifNotMatched: zeroArgBlock [
	<category: 'testing'>
	^oneArgBlock cull: self
    ]

    ifNotMatched: zeroArgBlock ifMatched: oneArgBlock [
	<category: 'testing'>
	^oneArgBlock cull: self
    ]

    size [
	<category: 'accessing'>
	^registers size
    ]

    subject [
	<category: 'accessing'>
	^subject
    ]

    from [
	<category: 'accessing'>
	^from
    ]

    fromAt: anIndex [
	<category: 'accessing'>
	| reg |
	anIndex = 0 ifTrue: [^from].
	reg := registers at: anIndex.
	^reg isNil ifTrue: [nil] ifFalse: [reg first]
    ]

    to [
	<category: 'accessing'>
	^to
    ]

    toAt: anIndex [
	<category: 'accessing'>
	| reg |
	anIndex = 0 ifTrue: [^from].
	reg := registers at: anIndex.
	^reg isNil ifTrue: [nil] ifFalse: [reg last]
    ]

    match [
	<category: 'accessing'>
	match isNil ifTrue: [match := self subject copyFrom: from to: to].
	^match
    ]

    matchInterval [
	<category: 'accessing'>
	^from to: to
    ]

    at: anIndex [
	<category: 'accessing'>
	| reg text |
	anIndex = 0 ifTrue: [^self match].
	cache isNil ifTrue: [cache := Array new: registers size].
	(cache at: anIndex) isNil 
	    ifTrue: 
		[reg := registers at: anIndex.
		text := reg isNil 
			    ifTrue: [nil]
			    ifFalse: [self subject copyFrom: reg first to: reg last].
		cache at: anIndex put: text].
	^cache at: anIndex
    ]

    intervalAt: anIndex [
	<category: 'accessing'>
	^anIndex = 0 ifTrue: [from to: to] ifFalse: [registers at: anIndex]
    ]
]

]



Namespace current: Kernel [

RegexResults subclass: FailedMatchRegexResults [
    
    <category: 'Collections-Text'>
    <comment: nil>

    FailedMatchRegexResults class [
	| uniqueInstance |
	
    ]

    FailedMatchRegexResults class >> uniqueInstance [
	<category: 'private'>
	^uniqueInstance isNil 
	    ifTrue: [uniqueInstance := self new]
	    ifFalse: [uniqueInstance]
    ]

    matched [
	<category: 'testing'>
	^false
    ]

    ifMatched: oneArgBlock ifNotMatched: zeroArgBlock [
	<category: 'testing'>
	^zeroArgBlock cull: self
    ]

    ifNotMatched: zeroArgBlock ifMatched: oneArgBlock [
	<category: 'testing'>
	^zeroArgBlock cull: self
    ]

    size [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    subject [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    from [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    fromAt: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    to [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    toAt: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    match [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    matchInterval [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    at: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    intervalAt: anIndex [
	<category: 'accessing'>
	self shouldNotImplement
    ]
]

]



String extend [

    lengthOfRegexMatch: pattern from: from to: to [
	<category: 'private-C call-outs'>
	<cCall: 'reh_match' returning: #int
	args: #(#selfSmalltalk #smalltalk #int #int)>
	
    ]

    searchRegexInternal: pattern from: from to: to [
	<category: 'private-C call-outs'>
	<cCall: 'reh_search' returning: #smalltalk
	args: #(#selfSmalltalk #smalltalk #int #int)>
	
    ]

    asRegex [
	"Answer the receiver, converted to a Regex object."

	<category: 'regex'>
	^Regex fromString: self
    ]

    ~ pattern [
	"Answer whether the receiver matched against the Regex or String
	 object pattern."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: pattern
		    from: 1
		    to: self size.
	^regs notNil
    ]

    =~ pattern [
	"Answer a RegexResults object for matching the receiver against
	 the Regex or String object pattern."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: pattern
		    from: 1
		    to: self size.
	^regs isNil 
	    ifTrue: [Kernel.FailedMatchRegexResults uniqueInstance]
	    ifFalse: [regs]
    ]

    searchRegex: pattern [
	"A synonym for #=~.  Answer a RegexResults object for matching the receiver
	 against the Regex or String object pattern."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: pattern
		    from: 1
		    to: self size.
	^regs isNil 
	    ifTrue: [Kernel.FailedMatchRegexResults uniqueInstance]
	    ifFalse: [regs]
    ]

    searchRegex: pattern startingAt: anIndex [
	"Answer a RegexResults object for matching the receiver
	 against the Regex or String object pattern, starting the match
	 at index anIndex."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: pattern
		    from: anIndex
		    to: self size.
	^regs isNil 
	    ifTrue: [Kernel.FailedMatchRegexResults uniqueInstance]
	    ifFalse: [regs]
    ]

    searchRegex: pattern from: from to: to [
	"Answer a RegexResults object for matching the receiver
	 against the Regex or String object pattern, restricting the match
	 to the specified range of indices."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: pattern
		    from: from
		    to: to.
	^regs isNil 
	    ifTrue: [Kernel.FailedMatchRegexResults uniqueInstance]
	    ifFalse: [regs]
    ]

    indexOfRegex: regexString ifAbsent: excBlock [
	"If an occurrence of the regex is present in the receiver, return
	 the Interval corresponding to the leftmost-longest match.  Otherwise,
	 evaluate excBlock and return the result."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: regexString
		    from: 1
		    to: self size.
	^regs isNil ifFalse: [regs matchInterval] ifTrue: [excBlock value]
    ]

    indexOfRegex: regexString startingAt: index ifAbsent: excBlock [
	"If an occurrence of the regex is present in the receiver, return
	 the Interval corresponding to the leftmost-longest match starting after
	 the given index.  Otherwise, evaluate excBlock and return the result."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: regexString
		    from: index
		    to: self size.
	^regs isNil ifFalse: [regs matchInterval] ifTrue: [excBlock value]
    ]

    indexOfRegex: regexString from: from to: to ifAbsent: excBlock [
	"If an occurrence of the regex is present in the receiver, return the
	 Interval corresponding to the leftmost-longest match occurring within
	 the given indices.  Otherwise, evaluate excBlock and return the result."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: regexString
		    from: from
		    to: to.
	^regs isNil ifFalse: [regs matchInterval] ifTrue: [excBlock value]
    ]

    indexOfRegex: regexString [
	"If an occurrence of the regex is present in the receiver, return the
	 Interval corresponding to the leftmost-longest match.  Otherwise return
	 nil."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: regexString
		    from: 1
		    to: self size.
	^regs isNil ifFalse: [regs matchInterval]
    ]

    indexOfRegex: regexString startingAt: index [
	"If an occurrence of the regex is present in the receiver, return the
	 Interval corresponding to the leftmost-longest match starting after
	 the given index.  Otherwise return nil."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: regexString
		    from: index
		    to: self size.
	^regs isNil ifFalse: [regs matchInterval]
    ]

    indexOfRegex: regexString from: from to: to [
	"If an occurrence of the regex is present in the receiver, return the
	 Interval corresponding to the leftmost-longest match occurring within
	 the given range of indices.  Otherwise return nil."

	<category: 'regex'>
	| regs |
	regs := self 
		    searchRegexInternal: regexString
		    from: from
		    to: to.
	^regs isNil ifFalse: [regs matchInterval]
    ]

    matchRegex: pattern [
	"Answer whether the receiver is an exact match for the pattern.
	 This means that the pattern is implicitly anchored at the beginning
	 and the end."

	<category: 'regex'>
	^(self 
	    lengthOfRegexMatch: pattern
	    from: 1
	    to: self size) = self size
    ]

    matchRegex: pattern from: from to: to [
	"Answer whether the given range of indices is an exact match for the
	 pattern.  This means that there is a match starting at from and ending
	 at to (which is not necessarily the longest match starting at from)."

	<category: 'regex'>
	^(self 
	    lengthOfRegexMatch: pattern
	    from: from
	    to: to) = (to - from + 1)
    ]

    occurrencesOfRegex: pattern from: from to: to [
	"Return a count of how many times pattern repeats in the receiver within
	 the given range of index."

	<category: 'regex'>
	| res idx regex regs |
	regex := pattern asRegex.
	res := 0.
	idx := from.
	
	[regs := self 
		    searchRegexInternal: regex
		    from: idx
		    to: to.
	regs notNil] 
		whileTrue: 
		    [idx := regs to max: regs from + 1.
		    res := res + 1].
	^res
    ]

    occurrencesOfRegex: pattern startingAt: index [
	"Returns count of how many times pattern repeats in the receiver, starting
	 the search at the given index."

	<category: 'regex'>
	^self 
	    occurrencesOfRegex: pattern
	    from: index
	    to: self size
    ]

    occurrencesOfRegex: pattern [
	"Returns count of how many times pattern repeats in the receiver."

	<category: 'regex'>
	^self 
	    occurrencesOfRegex: pattern
	    from: 1
	    to: self size
    ]

    allOccurrencesOfRegex: pattern from: from to: to [
	"Find all the matches of pattern within the receiver and within the
	 given range of indices.  Collect them into an OrderedCollection,
	 which is then returned."

	<category: 'regex'>
	| result |
	result := OrderedCollection new.
	self allOccurrencesOfRegex: pattern from: from to: to
	    do: [ :each | result add: each match ].
	^result
    ]

    allOccurrencesOfRegex: pattern [
	"Find all the matches of pattern within the receiver and
	 collect them into an OrderedCollection."

	<category: 'regex'>
	^self 
	    allOccurrencesOfRegex: pattern
	    from: 1
	    to: self size
    ]

    allOccurrencesOfRegex: pattern from: from to: to do: aBlock [
	"Find all the matches of pattern within the receiver and within the
	 given range of indices.  For each match, pass the RegexResults object
	 to aBlock."

	<category: 'regex'>
	| idx regex regs beg end emptyOk |
	regex := pattern asRegex.
	idx := from.
	emptyOk := true.

	[regs := self 
		    searchRegexInternal: regex
		    from: idx
		    to: to.
	regs isNil] 
		whileFalse:
                    [beg := regs from.
                    end := regs to.
                    (beg <= end or: [ beg > idx or: [ emptyOk ]])
                        ifTrue: [
                            aBlock value: regs.
                            emptyOk := false.
                            idx := end + 1]
                        ifFalse: [
                            beg <= to ifFalse: [^self].
                            emptyOk := true.
                            idx := beg + 1]].
    ]

    allOccurrencesOfRegex: pattern do: aBlock [
	"Find all the matches of pattern within the receiver and
	 pass the RegexResults objects to aBlock."

	<category: 'regex'>
	^self 
	    allOccurrencesOfRegex: pattern
	    from: 1
	    to: self size
	    do: aBlock
    ]

    replacingRegex: pattern with: aStringOrBlock [
	"Returns the receiver if the pattern has no match in it.  If it has
	 a match, it is replaced using aStringOrBlock as follows: if it is
	 a block, a RegexResults object is passed, while if it is a string,
	 %n sequences are replaced with the captured subexpressions of the
	 match (as in #%)."

	<category: 'regex'>
	| regs beg end repl res |
	regs := self 
		    searchRegexInternal: pattern
		    from: 1
		    to: self size.
	regs isNil ifTrue: [^self].
	beg := regs from.
	end := regs to.
	repl := aStringOrBlock isString
	    ifTrue: [ aStringOrBlock % regs ]
	    ifFalse: [ aStringOrBlock value: regs ].

	^(res := self species new: self size - (end - beg + 1) + repl size)
	    replaceFrom: 1
		to: beg - 1
		with: self
		startingAt: 1;
	    replaceFrom: beg
		to: beg + repl size - 1
		with: repl
		startingAt: 1;
	    replaceFrom: beg + repl size
		to: res size
		with: self
		startingAt: end + 1
    ]

    replacingAllRegex: pattern with: aStringOrBlock [
	"Returns the receiver if the pattern has no match in it.  Otherwise,
	 any match of pattern in that part of the string is replaced
	 using aStringOrBlock as follows: if it is a block, a RegexResults
	 object is passed, while if it is a string, %n sequences are
	 replaced with the captured subexpressions of the match (as
	 in #%)."

	<category: 'regex'>
	| res idx regex beg end regs repl |
	regex := pattern asRegex.
	regs := self 
		    searchRegexInternal: regex
		    from: 1
		    to: self size.
	regs isNil ifTrue: [^self].
	res := WriteStream on: (String new: self size).
	idx := 1.
	repl := aStringOrBlock isString
	    ifTrue: [ [ :regs | aStringOrBlock % regs ] ]
	    ifFalse: [ aStringOrBlock ].
	
	[beg := regs from.
	end := regs to.
	res 
	    next: beg - idx
	    putAll: self
	    startingAt: idx.
	res nextPutAll: (repl value: regs).
	idx := end + 1.
	beg > end 
	    ifTrue: 
		[res nextPut: (self at: idx).
		idx := idx + 1].
	idx > self size ifTrue: [^res contents].
	regs := self 
		    searchRegexInternal: regex
		    from: idx
		    to: self size.
	regs isNil] 
		whileFalse.
	res 
	    next: self size - idx + 1
	    putAll: self
	    startingAt: idx.
	^res contents
    ]

    copyFrom: from to: to replacingRegex: pattern with: aStringOrBlock [
	"Returns the substring of the receiver between from and to.
	 If pattern has a match in that part of the string, the match
	 is replaced using aStringOrBlock as follows: if it is
	 a block, a RegexResults object is passed, while if it is a string,
	 %n sequences are replaced with the captured subexpressions of the
	 match (as in #%)."

	<category: 'regex'>
	| regs beg end repl res |
	regs := self 
		    searchRegexInternal: pattern
		    from: from
		    to: to.
	regs isNil 
	    ifFalse: 
		[beg := regs from.
		end := regs to.
		repl := aStringOrBlock isString
		    ifTrue: [ aStringOrBlock % regs ]
		    ifFalse: [ aStringOrBlock value: regs ].
		res := self species new: to - from - (end - beg) + repl size.
		res 
		    replaceFrom: 1
		    to: beg - from
		    with: self
		    startingAt: from.
		res 
		    replaceFrom: beg - from + 1
		    to: beg - from + repl size
		    with: repl.
		res 
		    replaceFrom: beg - from + repl size + 1
		    to: res size
		    with: self
		    startingAt: end - from + 2]
	    ifTrue: [res := self copyFrom: from to: to].
	^res
    ]

    copyReplacingRegex: pattern with: aStringOrBlock [
	"Returns the receiver after replacing the first match of pattern (if
	 any) using aStringOrBlock as follows: if it is a block, a
	 RegexResults object is passed, while if it is a string, %n
	 sequences are replaced with the captured subexpressions of the
	 match (as in #%)."

	<category: 'regex'>
	^self 
	    copyFrom: 1
	    to: self size
	    replacingRegex: pattern
	    with: aStringOrBlock
    ]

    copyFrom: from to: to replacingAllRegex: pattern with: aStringOrBlock [
	"Returns the substring of the receiver between from and to.
	 Any match of pattern in that part of the string is replaced
	 using aStringOrBlock as follows: if it is a block, a RegexResults
	 object is passed, while if it is a string, %n sequences are
	 replaced with the captured subexpressions of the match (as in #%)."

	<category: 'regex'>
	| res idx regex beg end regs emptyOk repl |
	regex := pattern asRegex.
	res := WriteStream on: (String new: to - from + 1).
	idx := from.
	emptyOk := true.
	repl := aStringOrBlock isString
	    ifTrue: [ [ :regs | aStringOrBlock % regs ] ]
	    ifFalse: [ aStringOrBlock ].
	
	[regs := self 
		    searchRegexInternal: regex
		    from: idx
		    to: to.
	regs isNil] 
		whileFalse: 
		    [beg := regs from.
		    end := regs to.
		    (beg <= end or: [ beg > idx or: [ emptyOk ]])
			ifTrue: [
			    emptyOk := false.
			    res 
			        next: beg - idx
			        putAll: self
			        startingAt: idx.
		            res nextPutAll: (repl value: regs).
			    idx := end + 1]
			ifFalse: [
			    beg <= to ifFalse: [^res contents].
			    emptyOk := true.
			    res nextPut: (self at: beg).
			    idx := beg + 1]].
	res 
	    next: to - idx + 1
	    putAll: self
	    startingAt: idx.
	^res contents
    ]

    copyReplacingAllRegex: pattern with: aStringOrBlock [
	"Returns the receiver after replacing all the matches of pattern (if
	 any) using aStringOrBlock as follows: if it is a block, a RegexResults
	 object is passed, while if it is a string, %n sequences are
	 replaced with the captured subexpressions of the match (as in #%)."

	<category: 'regex'>
	^self 
	    copyFrom: 1
	    to: self size
	    replacingAllRegex: pattern
	    with: aStringOrBlock
    ]

    onOccurrencesOfRegex: pattern from: from to: to do: aBlock [
	"Find all the matches of pattern within the receiver and within the
	 given range of indices.  For each match, pass the RegexResults object
	 to aBlock."

	<category: 'regex'>
	| idx regex regs |
	regex := pattern asRegex.
	idx := from.
	
	[regs := self 
		    searchRegexInternal: regex
		    from: idx
		    to: to.
	regs notNil] 
		whileTrue: 
		    [aBlock value: regs.
		    idx := regs to + 1 max: regs from + 1].
    ]

    onOccurrencesOfRegex: pattern do: body [
	"Find all the matches of pattern within the receiver and, for each match,
	 pass the RegexResults object to aBlock."

	<category: 'regex'>
	^self 
	    onOccurrencesOfRegex: pattern
	    from: 1
	    to: self size
	    do: body
    ]

    tokenize: pattern from: from to: to [
	"Split the receiver at every occurrence of pattern (considering only
	 the indices between from and to).  All parts that do not match pattern
	 are separated and stored into an Array of Strings that is returned."

	<category: 'regex'>
	| res idx tokStart regex regs beg end emptyOk |
	regex := pattern asRegex.
	res := WriteStream on: (Array new: 10).
	idx := tokStart := from.
	emptyOk := false.
	
	[regs := self 
		    searchRegexInternal: regex
		    from: idx
		    to: to.
	regs notNil] 
		whileTrue: 
		    [beg := regs from.
		    end := regs to.
		    (beg <= end or: [ beg > idx or: [ emptyOk ]])
			ifTrue: [
			    emptyOk := false.
			    res nextPut: (self copyFrom: tokStart to: beg - 1).
			    idx := tokStart := end + 1 ]
			ifFalse: [
			    "If we reach the end of the string exit
			     without adding the token.  tokStart must have been
			     set above to TO + 1 (it was set above just before
			     setting emptyOk to false), so we'd add an empty
			     token we don't want."
			    beg <= to ifFalse: [^res contents].
			    emptyOk := true.

			    "By not updating tokStart we put the character in the
			     next token."
			    idx := beg + 1]].
	(tokStart <= to or: [ emptyOk ])
	    ifTrue: [ res nextPut: (self copyFrom: tokStart to: to) ].
	^res contents
    ]

    tokenize: pattern [
	"Split the receiver at every occurrence of pattern.  All parts that do not
	 match pattern are separated and stored into an Array of Strings that is
	 returned."

	<category: 'regex'>
	^self 
	    tokenize: pattern
	    from: 1
	    to: self size
    ]

    escapeRegex [
	"Answer the receiver with all regex special characters escaped
	 by a backslash."

	^self copyReplacingAllRegex: '([][?*+\\()^$|])' with: '\%1'.
    ]
]



Eval [
    Kernel.FailedMatchRegexResults initialize
]

