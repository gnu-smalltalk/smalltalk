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


Namespace current: Kernel!

Stream subclass: #ConcatenatedStream
       instanceVariableNames: 'streams startPos curPos last lastStart'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

Stream subclass: #FilteringStream
       instanceVariableNames: 'stream block result next atEnd'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

Stream subclass: #CollectingStream
       instanceVariableNames: 'stream block'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

Stream subclass: #PeekableStream
       instanceVariableNames: 'stream haveLookahead lookahead'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

Stream subclass: #LineStream
       instanceVariableNames: 'charStream'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

!ConcatenatedStream class methodsFor: 'all'!

new
    ^#() readStream
!

with: stream1
    ^self basicNew
	streams: { stream1 };
	startPos: 0
!

with: stream1 with: stream2
    ^self basicNew
	streams: { stream1. stream2 };
	startPos: 0
!

withAll: array
    ^self basicNew
	streams: array;
	startPos: 0
! !

!ConcatenatedStream methodsFor: 'all'!

, aStream
    ^self copy addStream: aStream; yourself
!

postCopy
    streams := streams copy
!

atEnd
    [
	streams first atEnd
    ] whileTrue: [
	streams size = 1 ifTrue: [ ^true ].
	lastStart := startPos.
	startPos := startPos + curPos.
	curPos := 0.
	last := streams removeFirst ].
    ^false
!

name
    self atEnd ifTrue: [ ^nil ].
    ^streams first name
!
    
next
    self atEnd ifFalse: [ curPos := curPos + 1 ].
    ^streams first next
!

pastEnd
    ^streams last pastEnd
!

peekFor: aCharacter
    | result |
    self atEnd ifTrue: [ self pastEnd. ^false ].
    result := streams first peekFor: aCharacter.
    result ifTrue: [ curPos := curPos + 1 ].
    ^result
!

peek
    self atEnd ifTrue: [ ^self pastEnd ].
    ^streams first peek
!

position
    self atEnd.
    ^startPos + curPos
!

position: anInteger
    self atEnd ifTrue: [ self pastEnd. ^self ].
    streams first position: anInteger - startPos.
    curPos := anInteger - startPos
!

segmentFrom: start to: end
    "needed to do the documentation"
    | adjust stream |
    self atEnd.
    end + 1 = start ifTrue: [ ^'' ].
    end <= startPos
	ifTrue: [ stream := last. adjust := lastStart ]
	ifFalse: [ stream := streams first. adjust := startPos ].
    ^stream segmentFrom: (start - adjust max: 0) to: end - adjust
!

!ConcatenatedStream methodsFor: 'initializing'!

startPos: anInteger
    startPos := anInteger.
    curPos := 0
!

addStream: stream
    streams addLast: stream
!

streams: arrayOfStreams
    streams := arrayOfStreams asOrderedCollection.
! !

!FilteringStream class methodsFor: 'all'!

on: aStream select: selectBlock
   ^self new initStream: aStream block: selectBlock result: true
!

on: aStream reject: selectBlock
   ^self new initStream: aStream block: selectBlock result: false
! !

!FilteringStream methodsFor: 'initializing'!

initStream: aStream block: selectBlock result: aBoolean
    stream := aStream.
    block := selectBlock.
    result := aBoolean.
    atEnd := false.
    self lookahead
! !

!FilteringStream methodsFor: 'streaming'!

atEnd
    ^atEnd
!

next
    | result |
    atEnd ifTrue: [ self pastEnd. ^nil ].
    result := next.
    self lookahead.
    ^result
!

pastEnd
    ^stream pastEnd
!

peek
    atEnd ifTrue: [ ^nil ].
    ^next
!

peekFor: aCharacter
    atEnd ifTrue: [ self pastEnd. ^false ].
    next == aCharacter ifTrue: [ self lookahead. ^true ].
    ^false
! !

!FilteringStream methodsFor: 'basic'!

species
    ^stream species
! !

!FilteringStream methodsFor: 'private'!

lookahead
    [
	stream atEnd ifTrue: [ atEnd := true. ^self ].
	next := stream next.
	(block value: next) == result
    ] whileFalse
! !

!CollectingStream class methodsFor: 'instance creation'!

on: aStream collect: collectBlock
   ^self new initStream: aStream block: collectBlock
! !

!CollectingStream methodsFor: 'initializing'!

initStream: aStream block: collectBlock
    stream := aStream.
    block := collectBlock.
! !

!CollectingStream methodsFor: 'positioning'!

atEnd
    ^stream atEnd
!

next
    stream atEnd ifTrue: [ ^stream pastEnd ].
    ^block value: stream next
!

pastEnd
    ^stream pastEnd
!

peek
    stream atEnd ifTrue: [ ^nil ].
    ^block value: stream peek
!

peekFor: anObject
    | result |
    stream atEnd ifTrue: [ stream pastEnd. ^false ].
    result := (block value: stream peek) = anObject
    result ifTrue: [ stream next ].
    ^result
!
    
position
    ^stream position
!

position: anInteger
    stream position: anInteger
! !

!CollectingStream methodsFor: 'basic'!

species
    ^stream species
! !

!PeekableStream class methodsFor: 'instance creation'!

on: aStream
    ^self new initStream: aStream
! !

!PeekableStream methodsFor: 'basic'!

next
    | char |
    ^haveLookahead
	ifTrue: [
	    haveLookahead := false.
	    char := lookahead.
	    lookahead := nil.
	    char ]
	ifFalse: [ stream next ].
!

atEnd
    "Answer whether the input stream has no more tokens."
    ^haveLookahead not and: [ stream atEnd ]
!

pastEnd
    ^stream pastEnd
!

peek
    "Returns the next element of the stream without moving the pointer.
     Returns nil when at end of stream."
    haveLookahead ifFalse: [
	stream atEnd ifTrue: [ ^nil ].
	haveLookahead := true. lookahead := self next ].
    ^lookahead
!

peekFor: anObject
    "Answer a new whitespace-separated token from the input stream"
    | result |
    haveLookahead ifFalse: [
	stream atEnd ifTrue: [ self pastEnd. ^false ].
	lookahead := stream next ].

    result := lookahead = anObject.
    result ifTrue: [ lookahead := nil ].
    haveLookahead := result not.
    ^result
! !

!PeekableStream methodsFor: 'private'!

initStream: aStream
    stream := aStream.
    haveLookahead := false
! !

!LineStream class methodsFor: 'instance creation'!

on: aStream
    "Answer a LineStream working on aStream"
    ^self new initStream: aStream
! !

!LineStream methodsFor: 'basic'!

next
    ^charStream nextLine
!

atEnd
    ^charStream atEnd
!

pastEnd
    ^charStream pastEnd
! !

!LineStream methodsFor: 'private'!

initStream: aStream
    charStream := aStream.
! !

Namespace current: Smalltalk!

!Stream methodsFor: 'filtering'!

, aStream
    "Answer a new stream that concatenates the data in the receiver with the
     data in aStream.  Both the receiver and aStream should be readable."
    ^Kernel.ConcatenatedStream with: self with: aStream
!

lines
    "Answer a new stream that answers lines from the receiver."
    ^Kernel.LineStream on: self
!

peek
    "Returns the next element of the stream without moving the pointer.
     Returns nil when at end of stream.  Lookahead is implemented automatically
     for streams that are not positionable but can be copied."
 
    | copy |
    copy := self copy.
    copy == self ifTrue: [ ^self shouldNotImplement ].
    self become: (Kernel.PeekableStream on: copy).
    ^self peek
!

peekFor: aCharacter
    "Returns true and gobbles the next element from the stream of it is
     equal to anObject, returns false and doesn't gobble the next element
     if the next element is not equal to anObject.  Lookahead is implemented
     automatically for streams that are not positionable but can be copied."
 
    | copy |
    copy := self copy.
    copy == self ifTrue: [ ^self shouldNotImplement ].
    self become: (Kernel.PeekableStream on: copy).
    ^self peekFor: aCharacter
!

fold: aBlock
    "First, pass to binaryBlock the first and second elements of the
     receiver; for each subsequent element, pass the result of the previous
     evaluation and an element. Answer the result of the last invocation,
     or the first element if the stream has a single element."

    | result |
    result := self next.
    [ self atEnd ] whileFalse: [
	result := aBlock value: result value: self next ].
    ^result
!

inject: value into: aBlock
    "First, pass to binaryBlock value and the first element of the
     receiver; for each subsequent element, pass the result of the previous
     evaluation and an element. Answer the result of the last invocation,
     or value if the stream is empty."

    | result |
    result := value.
    [ self atEnd ] whileFalse: [
	result := aBlock value: result value: self next ].
    ^result
!

select: aBlock
    "Answer a new stream that only returns those objects for which aBlock
     returns true.  Note that the returned stream will not be positionable."

    "Example: Sieve of Erathostenes.
     GNU Smalltalk does not detect that i escapes, so we need to avoid
     optimizations of #to:do:.

	s := (2 to: 100) readStream.
	(2 to: 10) do: [ :i |
	    s := s reject: [ :n | n > i and: [ n \\ i = 0 ] ] ].
	s contents printNl"

    ^Kernel.FilteringStream on: self select: aBlock
!

reject: aBlock
    "Answer a new stream that only returns those objects for which aBlock
     returns false.  Note that the returned stream will not be positionable."
    ^Kernel.FilteringStream on: self reject: aBlock
!

collect: aBlock
    "Answer a new stream that will pass the returned objects through aBlock,
     and return whatever object is returned by aBlock instead.  Note that when
     peeking in the returned stream, the block will be invoked multiple times,
     with possibly surprising results."
    ^Kernel.CollectingStream on: self collect: aBlock
! !

