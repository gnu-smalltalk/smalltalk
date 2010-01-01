"======================================================================
|
|   WriteStream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2007,2009
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



PositionableStream subclass: WriteStream [
    
    <category: 'Streams-Collections'>
    <comment: 'I am the class of writeable streams.  I only allow write operations to
my instances; reading is strictly forbidden.'>

    WriteStream class >> on: aCollection [
	"Answer a new instance of the receiver which streams on aCollection.
	 Every item of aCollection is discarded."

	<category: 'instance creation'>
	^(self basicNew initCollection: aCollection)
	    beWriteOnly;
	    truncate;
	    yourself
    ]

    WriteStream class >> with: aCollection [
	"Answer a new instance of the receiver which streams from the end
	 of aCollection."

	<category: 'instance creation'>
	^(self basicNew initCollection: aCollection)
	    beWriteOnly;
	    moveToEnd;
	    yourself
    ]

    WriteStream class >> with: aCollection from: firstIndex to: lastIndex [
	"Answer a new instance of the receiver which streams from the
	 firstIndex-th item of aCollection to the lastIndex-th. The
	 pointer is moved to the last item in that range."

	<category: 'instance creation'>
	^self with: (aCollection copyFrom: firstIndex to: lastIndex)
    ]

    contents [
	"Returns a collection of the same type that the stream accesses, up to
	 and including the final element."

	<category: 'accessing-writing'>
	^collection copyFrom: 1 to: ptr - 1
    ]

    nextPut: anObject [
	"Store anObject as the next item in the receiver. Grow the
	 collection if necessary"

	"(access bitAnd: 2) = 0
	 ifTrue: [ ^self shouldNotImplement ]."

	<category: 'accessing-writing'>
	ptr > endPtr 
	    ifTrue: 
		[ptr > collection size ifTrue: [self growCollection].
		endPtr := ptr].
	collection at: ptr put: anObject.
	ptr := ptr + 1.
	^anObject
    ]

    next: n putAll: aCollection startingAt: pos [
	"Put n characters or bytes of aCollection, starting at the pos-th,
	 in the collection buffer."

	<category: 'accessing-writing'>
	| end |
	end := ptr + n.
	end > collection size ifTrue: [ self growCollectionTo: end - 1].
	collection 
	    replaceFrom: ptr
	    to: end - 1
	    with: aCollection
	    startingAt: pos.
	ptr := end.
	ptr > endPtr ifTrue: [endPtr := ptr - 1]
    ]

    readStream [
	"Answer a ReadStream on the same contents as the receiver"

	<category: 'accessing-writing'>
	^ReadStream 
	    on: collection
	    from: 1
	    to: ptr - 1
    ]

    reverseContents [
	"Returns a collection of the same type that the stream accesses, up to
	 and including the final element, but in reverse order."

	<category: 'accessing-writing'>
	| newCollection |
	newCollection := self species new: ptr - 1.
	1 to: endPtr do: [:i | newCollection at: i put: (collection at: ptr - i)].
	^newCollection
    ]

    emptyStream [
	"Extension - Reset the stream"

	<category: 'positioning'>
	ptr := 1.
	endPtr := 0
    ]

    initCollection: aCollection [
	<category: 'private methods'>
	collection := aCollection.
	ptr := 1.
	endPtr := 0
    ]

    moveToEnd [
	<category: 'private methods'>
	endPtr := collection size.
	ptr := endPtr + 1
    ]

    growCollection [
	"Private - Double the size of the collection or, if its size < 8,
	 grow it to 8 places"

	<category: 'private methods'>
	| size |
	size := collection size.

	"Guess which collection is which :-)"
	collection := (collection copyEmpty: (size * 2 max: 8))
		    replaceFrom: 1
			to: collection size
			with: collection
			startingAt: 1;
		    yourself
    ]

    growCollectionTo: n [
	"Private - Double the size of the collection or, if its size < 8,
	 grow it to 8 places"

	<category: 'private methods'>
	| size |
	n <= (size := collection size) ifTrue: [ ^self ].
	size * 2 > n ifTrue: [ ^self growCollection ].

	"Guess which collection is which :-)"
	collection := (collection copyEmpty: n)
		    replaceFrom: 1
			to: collection size
			with: collection
			startingAt: 1;
		    yourself
    ]
]

