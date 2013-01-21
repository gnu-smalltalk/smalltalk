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

    species [
	<category: 'basic'>
	^stream species
    ]
]

]
