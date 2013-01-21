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

Stream subclass: OneOfEachStream [
    | streams delta |
    
    <category: 'Examples-Useful tools'>
    <comment: nil>

    OneOfEachStream class >> new [
	<category: 'all'>
	^#() readStream
    ]

    OneOfEachStream class >> with: stream1 [
	<category: 'all'>
	^(self basicNew)
	    streams: {stream1}
    ]

    OneOfEachStream class >> with: stream1 with: stream2 [
	<category: 'all'>
	^(self basicNew)
	    streams: 
		    {stream1.
		    stream2}
    ]

    OneOfEachStream class >> with: stream1 with: stream2 with: stream3 [
	<category: 'all'>
	^(self basicNew)
	    streams: 
		    {stream1.
		    stream2.
		    stream3}
    ]

    OneOfEachStream class >> with: stream1 with: stream2 with: stream3 with: stream4 [
	<category: 'all'>
	^(self basicNew)
	    streams: 
		    {stream1.
		    stream2.
		    stream3.
		    stream4}
    ]

    OneOfEachStream class >> withAll: array [
	<category: 'all'>
	^(self basicNew)
	    streams: array
    ]

    atEnd [
	<category: 'all'>
	^streams anySatisfy: [ :each | each atEnd]
    ]

    do: aBlock [
	<category: 'all'>
	[
	    aBlock value:
		(streams collect: [:each |
		    each atEnd ifTrue: [ ^self ].
		    each next ])
	] repeat
    ]

    next [
	<category: 'all'>
	^streams collect: [:each |
	    each atEnd ifTrue: [ ^self pastEnd ] ifFalse: [ each next ]]
    ]

    pastEnd [
	<category: 'all'>
	^streams first pastEnd
    ]

    peekFor: anObject [
	<category: 'all'>
	^self peek = anObject
	    ifTrue: [ streams do: [ :each | streams next ] ];
	    yourself
    ]

    peek [
	<category: 'all'>
	^streams collect: [:each |
	    each atEnd ifTrue: [ ^self pastEnd ] ifFalse: [ each peek ]]
    ]

    position [
	<category: 'all'>
	^streams first position - delta
    ]

    position: anInteger [
	<category: 'all'>
	^self skip: anInteger - self position
    ]

    reset [
	<category: 'all'>
	self position: 0
    ]

    skip: anInteger [
	<category: 'all'>
	streams do: [ :each | each skip: anInteger ]
    ]

    streams: arrayOfStreams [
	<category: 'initializing'>
	streams := arrayOfStreams.
	delta := arrayOfStreams first position.
    ]
]

]
