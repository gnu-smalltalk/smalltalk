"======================================================================
|
|   Adds collection-like operations to GNU Smalltalk
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2007 Free Software Foundation, Inc.
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



Namespace current: Kernel [

Stream subclass: ConcatenatedStream [
    | streams startPos curPos last lastStart |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    ConcatenatedStream class >> new [
	<category: 'all'>
	^#() readStream
    ]

    ConcatenatedStream class >> with: stream1 [
	<category: 'all'>
	^(self basicNew)
	    streams: {stream1};
	    startPos: 0
    ]

    ConcatenatedStream class >> with: stream1 with: stream2 [
	<category: 'all'>
	^(self basicNew)
	    streams: 
		    {stream1.
		    stream2};
	    startPos: 0
    ]

    ConcatenatedStream class >> withAll: array [
	<category: 'all'>
	^(self basicNew)
	    streams: array;
	    startPos: 0
    ]

    , aStream [
	<category: 'all'>
	^(self copy)
	    addStream: aStream;
	    yourself
    ]

    postCopy [
	<category: 'all'>
	streams := streams copy
    ]

    atEnd [
	<category: 'all'>
	[streams first atEnd] whileTrue: 
		[streams size = 1 ifTrue: [^true].
		lastStart := startPos.
		startPos := startPos + curPos.
		curPos := 0.
		last := streams removeFirst].
	^false
    ]

    name [
	<category: 'all'>
	self atEnd ifTrue: [^nil].
	^streams first name
    ]

    next [
	<category: 'all'>
	self atEnd ifFalse: [curPos := curPos + 1].
	^streams first next
    ]

    pastEnd [
	<category: 'all'>
	^streams last pastEnd
    ]

    peekFor: aCharacter [
	<category: 'all'>
	| result |
	self atEnd 
	    ifTrue: 
		[self pastEnd.
		^false].
	result := streams first peekFor: aCharacter.
	result ifTrue: [curPos := curPos + 1].
	^result
    ]

    peek [
	<category: 'all'>
	self atEnd ifTrue: [^self pastEnd].
	^streams first peek
    ]

    position [
	<category: 'all'>
	self atEnd.
	^startPos + curPos
    ]

    position: anInteger [
	<category: 'all'>
	self atEnd 
	    ifTrue: 
		[self pastEnd.
		^self].
	streams first position: anInteger - startPos.
	curPos := anInteger - startPos
    ]

    copyFrom: start to: end [
	"needed to do the documentation"

	<category: 'all'>
	| adjust stream |
	self atEnd.
	end + 1 = start ifTrue: [^''].
	end <= startPos 
	    ifTrue: 
		[stream := last.
		adjust := lastStart]
	    ifFalse: 
		[stream := streams first.
		adjust := startPos].
	^stream copyFrom: (start - adjust max: 0) to: end - adjust
    ]

    segmentFrom: start to: end [
	"needed to do the documentation"

	<category: 'all'>
	| adjust stream |
	self atEnd.
	end + 1 = start ifTrue: [^''].
	end <= startPos 
	    ifTrue: 
		[stream := last.
		adjust := lastStart]
	    ifFalse: 
		[stream := streams first.
		adjust := startPos].
	^stream segmentFrom: (start - adjust max: 0) to: end - adjust
    ]

    startPos: anInteger [
	<category: 'initializing'>
	startPos := anInteger.
	curPos := 0
    ]

    addStream: stream [
	<category: 'initializing'>
	streams addLast: stream
    ]

    streams: arrayOfStreams [
	<category: 'initializing'>
	streams := arrayOfStreams asOrderedCollection
    ]
]

]



Namespace current: Kernel [

Stream subclass: FilteringStream [
    | stream block result next atEnd |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    FilteringStream class >> on: aStream select: selectBlock [
	<category: 'all'>
	^self new 
	    initStream: aStream
	    block: selectBlock
	    result: true
    ]

    FilteringStream class >> on: aStream reject: selectBlock [
	<category: 'all'>
	^self new 
	    initStream: aStream
	    block: selectBlock
	    result: false
    ]

    initStream: aStream block: selectBlock result: aBoolean [
	<category: 'initializing'>
	stream := aStream.
	block := selectBlock.
	result := aBoolean.
	atEnd := false.
	self lookahead
    ]

    atEnd [
	<category: 'streaming'>
	^atEnd
    ]

    next [
	<category: 'streaming'>
	| result |
	atEnd 
	    ifTrue: 
		[self pastEnd.
		^nil].
	result := next.
	self lookahead.
	^result
    ]

    pastEnd [
	<category: 'streaming'>
	^stream pastEnd
    ]

    peek [
	<category: 'streaming'>
	atEnd ifTrue: [^nil].
	^next
    ]

    peekFor: aCharacter [
	<category: 'streaming'>
	atEnd 
	    ifTrue: 
		[self pastEnd.
		^false].
	next == aCharacter 
	    ifTrue: 
		[self lookahead.
		^true].
	^false
    ]

    name [
	<category: 'basic'>
	^stream name
    ]

    species [
	<category: 'basic'>
	^stream species
    ]

    lookahead [
	<category: 'private'>
	
	[stream atEnd 
	    ifTrue: 
		[atEnd := true.
		^self].
	next := stream next.
	(block value: next) == result] 
		whileFalse
    ]
]

]



Namespace current: Kernel [

Stream subclass: CollectingStream [
    | stream block |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    CollectingStream class >> on: aStream collect: collectBlock [
	<category: 'instance creation'>
	^self new initStream: aStream block: collectBlock
    ]

    initStream: aStream block: collectBlock [
	<category: 'initializing'>
	stream := aStream.
	block := collectBlock
    ]

    atEnd [
	<category: 'positioning'>
	^stream atEnd
    ]

    next [
	<category: 'positioning'>
	stream atEnd ifTrue: [^stream pastEnd].
	^block value: stream next
    ]

    pastEnd [
	<category: 'positioning'>
	^stream pastEnd
    ]

    peek [
	<category: 'positioning'>
	stream atEnd ifTrue: [^nil].
	^block value: stream peek
    ]

    peekFor: anObject [
	<category: 'positioning'>
	| result |
	stream atEnd 
	    ifTrue: 
		[stream pastEnd.
		^false].
	result := (block value: stream peek) = anObject result 
		    ifTrue: [stream next].
	^result
    ]

    position [
	<category: 'positioning'>
	^stream position
    ]

    position: anInteger [
	<category: 'positioning'>
	stream position: anInteger
    ]

    name [
	<category: 'basic'>
	^stream name
    ]

    species [
	<category: 'basic'>
	^stream species
    ]
]

]



Namespace current: Kernel [

Stream subclass: PeekableStream [
    | stream haveLookahead lookahead |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    PeekableStream class >> on: aStream [
	<category: 'instance creation'>
	^self new initStream: aStream
    ]

    species [
	<category: 'basic'>
	^stream species
    ]

    name [
	<category: 'basic'>
	^stream name
    ]

    next [
	<category: 'basic'>
	| char |
	^haveLookahead 
	    ifTrue: 
		[haveLookahead := false.
		char := lookahead.
		lookahead := nil.
		char]
	    ifFalse: [stream next]
    ]

    atEnd [
	"Answer whether the input stream has no more tokens."

	<category: 'basic'>
	^haveLookahead not and: [stream atEnd]
    ]

    pastEnd [
	<category: 'basic'>
	^stream pastEnd
    ]

    peek [
	"Returns the next element of the stream without moving the pointer.
	 Returns nil when at end of stream."

	<category: 'basic'>
	haveLookahead 
	    ifFalse: 
		[stream atEnd ifTrue: [^nil].
		haveLookahead := true.
		lookahead := stream next].
	^lookahead
    ]

    peekFor: anObject [
	"Answer a new whitespace-separated token from the input stream"

	<category: 'basic'>
	| result |
	haveLookahead 
	    ifFalse: 
		[stream atEnd 
		    ifTrue: 
			[self pastEnd.
			^false].
		lookahead := stream next].
	result := lookahead = anObject.
	result ifTrue: [lookahead := nil].
	haveLookahead := result not.
	^result
    ]

    initStream: aStream [
	<category: 'private'>
	stream := aStream.
	haveLookahead := false
    ]
]

]



Namespace current: Kernel [

Stream subclass: LineStream [
    | charStream |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    LineStream class >> on: aStream [
	"Answer a LineStream working on aStream"

	<category: 'instance creation'>
	^self new initStream: aStream
    ]

    name [
	<category: 'basic'>
	^charStream name
    ]

    next [
	<category: 'basic'>
	^charStream nextLine
    ]

    atEnd [
	<category: 'basic'>
	^charStream atEnd
    ]

    pastEnd [
	<category: 'basic'>
	^charStream pastEnd
    ]

    initStream: aStream [
	<category: 'private'>
	charStream := aStream
    ]
]

]



Stream extend [

    , aStream [
	"Answer a new stream that concatenates the data in the receiver with the
	 data in aStream.  Both the receiver and aStream should be readable."

	<category: 'filtering'>
	^Kernel.ConcatenatedStream with: self with: aStream
    ]

    lines [
	"Answer a new stream that answers lines from the receiver."

	<category: 'filtering'>
	^Kernel.LineStream on: self
    ]

    peek [
	"Returns the next element of the stream without moving the pointer.
	 Returns nil when at end of stream.  Lookahead is implemented automatically
	 for streams that are not positionable but can be copied."

	<category: 'filtering'>
	| copy |
	copy := self copy.
	copy == self ifTrue: [^self shouldNotImplement].
	self become: (Kernel.PeekableStream on: copy).
	^self peek
    ]

    peekFor: aCharacter [
	"Returns true and gobbles the next element from the stream of it is
	 equal to anObject, returns false and doesn't gobble the next element
	 if the next element is not equal to anObject.  Lookahead is implemented
	 automatically for streams that are not positionable but can be copied."

	<category: 'filtering'>
	| copy |
	copy := self copy.
	copy == self ifTrue: [^self shouldNotImplement].
	self become: (Kernel.PeekableStream on: copy).
	^self peekFor: aCharacter
    ]

    fold: aBlock [
	"First, pass to binaryBlock the first and second elements of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation,
	 or the first element if the stream has a single element."

	<category: 'filtering'>
	| result |
	result := self next.
	[self atEnd] whileFalse: [result := aBlock value: result value: self next].
	^result
    ]

    inject: value into: aBlock [
	"First, pass to binaryBlock value and the first element of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation,
	 or value if the stream is empty."

	<category: 'filtering'>
	| result |
	result := value.
	[self atEnd] whileFalse: [result := aBlock value: result value: self next].
	^result
    ]

    select: aBlock [
	"Answer a new stream that only returns those objects for which aBlock
	 returns true.  Note that the returned stream will not be positionable."

	"Example: Sieve of Erathostenes.
	 GNU Smalltalk does not detect that i escapes, so we need to avoid
	 optimizations of #to:do:.
	 
	 s := (2 to: 100) readStream.
	 (2 to: 10) do: [ :i |
	 s := s reject: [ :n | n > i and: [ n \\ i = 0 ] ] ].
	 s contents printNl"

	<category: 'filtering'>
	^Kernel.FilteringStream on: self select: aBlock
    ]

    reject: aBlock [
	"Answer a new stream that only returns those objects for which aBlock
	 returns false.  Note that the returned stream will not be positionable."

	<category: 'filtering'>
	^Kernel.FilteringStream on: self reject: aBlock
    ]

    collect: aBlock [
	"Answer a new stream that will pass the returned objects through aBlock,
	 and return whatever object is returned by aBlock instead.  Note that when
	 peeking in the returned stream, the block will be invoked multiple times,
	 with possibly surprising results."

	<category: 'filtering'>
	^Kernel.CollectingStream on: self collect: aBlock
    ]

]

