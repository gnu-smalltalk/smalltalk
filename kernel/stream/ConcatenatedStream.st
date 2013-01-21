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
	    yourself
    ]

    ConcatenatedStream class >> with: stream1 with: stream2 [
	<category: 'all'>
	^(self basicNew)
	    streams: {stream1.  stream2};
	    yourself
    ]

    ConcatenatedStream class >> withAll: array [
	<category: 'all'>
	^(self basicNew)
	    streams: array;
	    yourself
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

    stream [
	<category: 'all'>
	| s |
        "This is somewhat performance-sensitive, so avoid testing for an
         empty collection."
	[(s := streams at: 1) atEnd] whileTrue: 
		[curPos > 0 ifTrue: [
                    lastStart := startPos.
                    startPos := startPos + curPos.
                    curPos := 0].
                streams size = 1 ifTrue: [last := streams first. ^nil].
		last := streams removeFirst].
	^s
    ]

    atEnd [
	<category: 'all'>
	^self stream isNil
    ]

    file [
	<category: 'all'>
	self atEnd ifTrue: [^nil].
	^streams first file
    ]

    name [
	<category: 'all'>
	self atEnd ifTrue: [^nil].
	^streams first name
    ]

    next [
	<category: 'all'>
	| s |
	^(s := self stream) isNil
	    ifTrue: [self pastEnd]
	    ifFalse: [curPos := curPos + 1.  s next]
    ]

    pastEnd [
	<category: 'all'>
	^streams last pastEnd
    ]

    peekFor: aCharacter [
	<category: 'all'>
	| s result |
	(s := self stream) isNil
	    ifTrue: 
		[self pastEnd.
		^false].
	result := s peekFor: aCharacter.
	result ifTrue: [curPos := curPos + 1].
	^result
    ]

    peek [
	<category: 'all'>
	| s |
	(s := self stream) isNil ifTrue: [^self pastEnd].
	^s peek
    ]

    position [
	<category: 'all'>
	self stream.
	^startPos + curPos
    ]

    position: anInteger [
	<category: 'all'>
	| s |
	(s := self stream) isNil
	    ifTrue: 
		[self pastEnd.
		^self].
	s position: anInteger - startPos.
	curPos := anInteger - startPos
    ]

    copyFrom: start to: end [
	"needed to do the documentation"

	<category: 'all'>
	| adjust stream |
	stream := self stream.
	end + 1 = start ifTrue: [^''].
	adjust := end <= startPos 
	    ifTrue: [stream := last. lastStart]
	    ifFalse: [startPos].
	^stream copyFrom: (start - adjust max: 0) to: end - adjust
    ]

    addStream: stream [
	<category: 'initializing'>
	streams addLast: stream
    ]

    streams: arrayOfStreams [
	<category: 'initializing'>
	streams := arrayOfStreams asOrderedCollection.
	startPos := curPos := 0
    ]
]

]
