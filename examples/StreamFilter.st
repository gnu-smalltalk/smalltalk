"======================================================================
|
|   Adds collection-like operations to GNU Smalltalk
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2006 Free Software Foundation, Inc.
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

Stream subclass: #LineStream
       instanceVariableNames: 'charStream lookahead'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Useful tools'
!

!ConcatenatedStream class methodsFor: 'all'!

new
    ^self basicNew
	streams: #();
	startPos: 0
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
! !

!ConcatenatedStream methodsFor: 'all'!

, aStream
    ^self copy streams: (streams copyWith: aStream)
!

atEnd
    [
	streams isEmpty ifTrue: [ ^true ].
	streams first atEnd
    ] whileTrue: [
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
    self atEnd ifTrue: [ ^self pastEnd ].
    curPos := curPos + 1.
    ^streams first next
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
    self atEnd ifTrue: [ SystemExceptions.EndOfStream signalOn: self. ^self ].
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

!ConcatenatedStream methodsFor: 'private'!

pastEnd
    "The end of the stream has been reached.  Signal a Notification"

    SystemExceptions.EndOfStream signalOn: self.
    ^nil
! !

!ConcatenatedStream methodsFor: 'initializing'!

startPos: anInteger
    startPos := anInteger.
    curPos := 0
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
    atEnd ifTrue: [ SystemExceptions.EndOfStream signalOn: self. ^nil ].
    result := next.
    self lookahead.
    ^result
!

peek
    atEnd ifTrue: [ ^nil ].
    ^next
!

peekFor: aCharacter
    atEnd ifTrue: [ ^false ].
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
    ^block value: stream next
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

!LineStream class methodsFor: 'instance creation'!

on: aStream
    "Answer a LineStream working on aStream"
    ^self new initStream: aStream
! !

!LineStream methodsFor: 'basic'!

next
    "Answer a new whitespace-separated token from the input stream"
    | char lineStream |
    lineStream := WriteStream on: (String new: 80).

    lookahead isNil
	ifFalse: [
	    char := lookahead.
	    lookahead := true ]
	ifTrue: [
	    charStream atEnd ifTrue: [ SystemExceptions.EndOfStream signalOn: self. ^nil ].
	    char := charStream next ].

    [
	char = Character nl ifTrue: [ ^lineStream contents ].
	char = Character cr ifTrue: [ 
	    charStream atEnd ifFalse: [
		(lookahead := charStream next) = Character nl
		    ifTrue: [ lookahead := nil ].
	    ].
	    ^lineStream contents ].

	lineStream nextPut: char.
        charStream atEnd
    ] whileFalse: [
	char := charStream next
    ].
    ^lineStream contents
!

atEnd
    "Answer whether the input stream has no more tokens."
    ^lookahead isNil and: [ charStream atEnd ]
! !

!LineStream methodsFor: 'private'!

initStream: aStream
    charStream := aStream.
! !

!Stream methodsFor: 'filtering'!

, aStream
    ^ConcatenatedStream with: self with: aStream
!

lines
    ^LineStream on: self
!

inject: value into: aBlock
    | result |
    result := value.
    [ self atEnd ] whileFalse: [
	result := aBlock value: result value: self next ].
    ^result
!

select: aBlock
    ^FilteringStream on: self select: aBlock
!

reject: aBlock
    ^FilteringStream on: self reject: aBlock
!

collect: aBlock
    ^CollectingStream on: self collect: aBlock
! !

