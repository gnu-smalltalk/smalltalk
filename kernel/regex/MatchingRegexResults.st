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
