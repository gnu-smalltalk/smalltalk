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

    file [
	<category: 'basic'>
	^stream file
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
