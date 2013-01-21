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
