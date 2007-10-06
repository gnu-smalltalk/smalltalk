"======================================================================
|
|   ReadWriteStream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2006,2007
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



WriteStream subclass: ReadWriteStream [
    
    <category: 'Streams-Collections'>
    <comment: 'I am the class of streams that may be read and written from simultaneously.
In some sense, I am the best of both ReadStream and WriteStream.'>

    ReadWriteStream class >> on: aCollection [
	"Answer a new stream working on aCollection from its start. The
	 stream starts at the front of aCollection."

	<category: 'instance creation'>
	^(super on: aCollection)
	    beReadWrite;
	    limit: aCollection size
    ]

    ReadWriteStream class >> on: aCollection from: firstIndex to: lastIndex [
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
	^(super on: aCollection)
	    beReadWrite;
	    limit: lastIndex
    ]

    ReadWriteStream class >> with: aCollection [
	"Answer a new instance of the receiver which streams from the end
	 of aCollection."

	<category: 'instance creation'>
	^(super with: aCollection) beReadWrite
    ]

    contents [
	"Unlike WriteStreams, ReadWriteStreams return the whole contents of the
	 underlying collection."

	<category: 'positioning'>
	^collection copyFrom: 1 to: endPtr
    ]

    limit: anInteger [
	"Private - Makes sure that the contents message to this object
	 returns anInteger objects, not just what has been written
	 so far."

	<category: 'private'>
	endPtr := collection size
    ]
]

