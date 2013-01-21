"======================================================================
|
|   Dynamic Loader Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2005,2008,2009
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



Namespace current: Kernel [

Stream subclass: RoundRobinStream [
    | stream first last |
    
    <category: 'Language-C interface'>
    <comment: 'This class implements a peculiar stream that optimizes the order
in which symbols are searched in dynamically linked libraries.
When using #next, the stream will restart from the first element
after returning nil once.  When you use #do:, the stream starts
from the *last* element that was either returned by #next or passed
to #do: in the previous iteration.

Since the #primDefineExternFunc: leaves the #do: in advance if it
succeeds in finding a symbol, the next time it will restart from
the library in which it found a symbol.  Usually symbols have a
very good locality (you find all the symbols in a library, or at
least symbols in the same #methodsFor: come from the same library):
so this avoids looking for symbols in the wrong library.'>

    RoundRobinStream class >> test: s get: n [
	<category: 'demo'>
	n timesRepeat: [s next print].
	Transcript nl
    ]

    RoundRobinStream class >> test: s leaveAfter: n [
	<category: 'demo'>
	| i |
	i := 0.
	s do: 
		[:each | 
		each print.
		(i := i + 1) = n 
		    ifTrue: 
			[Transcript nl.
			^nil]].
	Transcript nl
    ]

    RoundRobinStream class >> testOn: anArray [
	"RoundRobinStream testOn: #(1 2 3 4 5 6)"

	<category: 'demo'>
	| s |
	s := RoundRobinStream on: anArray readStream.
	self test: s get: anArray size + 1.
	self test: s get: anArray size + 1.
	self test: s get: (anArray size + 1) * 2.
	self test: s get: 2.
	self test: s leaveAfter: anArray size + 1.
	self test: s leaveAfter: anArray size + 1.
	self test: s leaveAfter: 1.
	self test: s leaveAfter: 1.
	self test: s leaveAfter: 2.
	self test: s leaveAfter: 2.
	self test: s leaveAfter: anArray size + 1.
	self test: s leaveAfter: anArray size + 1.
	Transcript nl
    ]

    RoundRobinStream class >> on: aStream [
	<category: 'accessing'>
	^self new stream: aStream
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    atEnd [
	<category: 'basic'>
	stream atEnd 
	    ifTrue: 
		[stream reset.
		"If there is no established first, we started iterating from the
		 first element in the stream."
		first isNil ifTrue: [^true]].
	^(last := stream peek) == first
    ]

    next [
	<category: 'basic'>
	^self atEnd 
	    ifTrue: [SystemExceptions.EndOfStream signalOn: self]
	    ifFalse: [stream next]
    ]

    do: aBlock [
	"Iterate on all the items in the Stream.  If it is not the first iteration,
	 and the last item was retrieved with #next or passed to a #do: block *that
	 did a global return*, return from there."

	<category: 'basic'>
	stream atEnd 
	    ifTrue: 
		[stream reset.
		stream atEnd ifTrue: [^self]].

	"Establish the item at which we'll stop iterating.  Start from that one."
	last isNil ifTrue: [last := stream next].
	first := last.
	aBlock value: last.
	super do: aBlock.

	"Make sure we will not restart from the last item we passed to aBlock,
	 because aBlock did not return."
	last := nil
    ]
]

]

