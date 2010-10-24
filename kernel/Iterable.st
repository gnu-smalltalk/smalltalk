"======================================================================
|
|   Iterable Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



Object subclass: Iterable [
    
    <category: 'Collections'>
    <comment: 'I am an abstract class.  My instances are collections of objects
that can be iterated.  The details on how they can be mutated (if at
all possible) are left to the subclasses.'>

    Iterable class >> isUnicode [
	"Answer true; the receiver is able to store arbitrary
	 Unicode characters."

	<category: 'multibyte encodings'>
	self subclassResponsibility
    ]

    , anIterable [
	"Answer an iterable that enumerates first the elements of the receiver
         and then the elements of anIterable."

	<category: 'enumeration'>
	self subclassResponsibility
    ]

    ifNil: nilBlock ifNotNilDo: iterableBlock [
        "Evaluate nilBlock if the receiver is nil, else evaluate
         iterableBlock with each element of the receiver (which
         should be an Iterable)."

        <category: 'iteration'>
        self do: iterableBlock
    ]

    ifNotNilDo: iterableBlock [
        "Evaluate iterableBlock with each element of the receiver (which
         should be an Iterable) if not nil.  Else answer nil"

        <category: 'iteration'>
        self do: iterableBlock
    ]

    ifNotNilDo: iterableBlock ifNil: nilBlock [
        "Evaluate nilBlock if the receiver is nil, else evaluate
         iterableBlock, passing each element of the receiver (which
         should be an Iterable)."

        <category: 'iteration'>
        self do: iterableBlock
    ]

    do: aBlock [
	"Enumerate each object of the receiver, passing them to aBlock"

	<category: 'enumeration'>
	self subclassResponsibility
    ]

    do: aBlock separatedBy: separatorBlock [
	"Enumerate each object of the receiver, passing them to aBlock.
	 Between every two invocations of aBlock, invoke separatorBlock"

	<category: 'enumeration'>
	| first |
	first := true.
	self do: 
		[:each | 
		first ifTrue: [first := false] ifFalse: [separatorBlock value].
		aBlock value: each]
    ]

    select: aBlock [
	"Answer a new instance of a Collection containing all the elements
	 in the receiver which, when passed to aBlock, answer true"

	<category: 'enumeration'>
	self subclassResponsibility
    ]

    reject: aBlock [
	"Answer a new instance of a Collection containing all the elements
	 in the receiver which, when passed to aBlock, don't answer true"

	<category: 'enumeration'>
	self subclassResponsibility
    ]

    collect: aBlock [
	"Answer a new instance of a Collection containing all the results
	 of evaluating aBlock passing each of the receiver's elements"

	<category: 'enumeration'>
	self subclassResponsibility
    ]

    detect: aBlock ifNone: exceptionBlock [
	"Search the receiver for an element for which aBlock returns true.
	 If some does, answer it. If none does, answer the result of evaluating
	 aBlock"

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^element]].
	^exceptionBlock value
    ]

    count: aBlock [
	"Count the elements of the receiver for which aBlock returns true,
	 and return their number."

	<category: 'enumeration'>
	| count |
	count := 0.
	self do: [:element | (aBlock value: element) ifTrue: [count := count + 1]].
	^count
    ]

    allSatisfy: aBlock [
	"Search the receiver for an element for which aBlock returns false.
	 Answer true if none does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifFalse: [^false]].
	^true
    ]

    noneSatisfy: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 Answer true if none does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^false]].
	^true
    ]

    anySatisfy: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 Answer true if some does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^true]].
	^false
    ]

    conform: aBlock [
	"Search the receiver for an element for which aBlock returns false.
	 Answer true if none does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifFalse: [^false]].
	^true
    ]

    contains: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 Answer true if some does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^true]].
	^false
    ]

    detect: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 If some does, answer it. If none does, fail"

	<category: 'enumeration'>
	^self detect: aBlock
	    ifNone: [SystemExceptions.NotFound signal: 'object not found']
    ]

    fold: binaryBlock [
	"First, pass to binaryBlock the first and second elements of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation,
	 or the first element if the collection has size 1.  Fail if the collection
	 is empty."

	<category: 'enumeration'>
	| result marker |
	self isEmpty ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	result := marker := Object new.
	self do: 
		[:element | 
		result := result == marker 
			    ifTrue: [element]
			    ifFalse: [binaryBlock value: result value: element]].
	^result
    ]

    inject: thisValue into: binaryBlock [
	"First, pass to binaryBlock thisValue and the first element of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation."

	<category: 'enumeration'>
	| result |
	result := thisValue.
	self do: [:element | result := binaryBlock value: result value: element].
	^result
    ]

    nextPutAllOn: aStream [
        "Write all the objects in the receiver to aStream"

	<category: 'streaming'>
	self do: [ :each | aStream nextPut: each ]
    ]

    readStream [
	"Return a stream with the same contents as the receiver."

	<category: 'streaming'>
	self subclassResponsibility
    ]
]
