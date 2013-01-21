"======================================================================
|
|   Adds collection-like operations to GNU Smalltalk streams
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
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



Stream extend [

    , anIterable [
	"Answer a new stream that concatenates the data in the receiver with the
	 data in aStream.  Both the receiver and aStream should be readable."

	<category: 'filtering'>
	^Kernel.ConcatenatedStream with: self with: anIterable readStream
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

    skipSeparators [
	"Advance the receiver until we find a character that is not a
	 separator.  Answer false if we reach the end of the stream,
	 else answer true; in this case, sending #next will return the
	 first non-separator character (possibly the same to which the
	 stream pointed before #skipSeparators was sent)."

	<category: 'positioning'>
	| ch |
	
	[(ch := self peek) isNil ifTrue: [^false].
	ch isSeparator] 
		whileTrue: [self next].
	^true
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

    with: aStream [
	"Return a new Stream whose elements are 2-element
	 Arrays, including one element from the receiver and one from
	 aStream."
	<category: 'concatenating'>
	^Kernel.OneOfEachStream with: self with: aStream
    ]

    with: stream1 with: stream2 [
	"Return a new Stream whose elements are 3-element
	 Arrays, including one element from the receiver and one from
	 each argument."
	<category: 'concatenating'>
	^Kernel.OneOfEachStream with: self with: stream1 with: stream2
    ]

    with: stream1 with: stream2 with: stream3 [
	"Return a new Stream whose elements are 3-element
	 Arrays, including one element from the receiver and one from
	 each argument."
	<category: 'concatenating'>
	^Kernel.OneOfEachStream
	    with: self with: stream1 with: stream2 with: stream3
    ]
]

