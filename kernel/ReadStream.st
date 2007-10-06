"======================================================================
|
|   ReadStream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2006
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



PositionableStream subclass: ReadStream [
    
    <category: 'Streams-Collections'>
    <comment: 'I implement the set of read-only stream objects.  You may read from
my objects, but you may not write to them.'>

    ReadStream class >> on: aCollection [
	"Answer a new stream working on aCollection from its start."

	<category: 'instance creation'>
	^(self basicNew initCollection: aCollection limit: aCollection size) 
	    beReadOnly
    ]

    ReadStream class >> on: aCollection from: firstIndex to: lastIndex [
	"Answer an instance of the receiver streaming from
	 the firstIndex-th item of aCollection to the lastIndex-th"

	<category: 'instance creation'>
	firstIndex = 1 
	    ifFalse: 
		[^super 
		    on: aCollection
		    from: firstIndex
		    to: lastIndex].
	lastIndex > aCollection size 
	    ifTrue: 
		[^SystemExceptions.IndexOutOfRange signalOn: self withIndex: lastIndex].
	^(self basicNew initCollection: aCollection limit: lastIndex) beReadOnly
    ]

    initCollection: aCollection limit: anInteger [
	<category: 'private methods'>
	collection := aCollection.
	ptr := 1.
	endPtr := anInteger
    ]
]

