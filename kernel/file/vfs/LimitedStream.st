"======================================================================
|
|   Virtual File System (new classes)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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

Stream subclass: LimitedStream [
    | stream offset limit |
    
    <category: 'Streams-Files'>
    <comment: 'I provide a view of a part of a substream.'>

    LimitedStream class >> on: aStream from: start to: end [
	<category: 'instance creation'>
	^(self new)
	    stream: aStream;
	    offset: start;
	    limit: end + 1;
	    yourself
    ]

    atEnd [
	<category: 'stream operations'>
	^stream position >= limit or: [stream atEnd]
    ]

    copyFrom: start to: end [
	<category: 'stream operations'>
	(start between: 0 and: limit - offset) 
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: start].
	(end between: 0 and: limit - offset) 
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: end].
	^stream copyFrom: offset + start to: offset + end
    ]

    isPositionable [
	<category: 'stream operations'>
	^true
    ]

    nextAvailable: n into: aCollection startingAt: pos [
	<category: 'stream operations'>
	^stream
	    nextAvailable: (n min: limit - stream position)
	    into: aCollection
	    startingAt: pos
    ]

    next [
	<category: 'stream operations'>
	self atEnd ifTrue: [^self pastEnd].
	^stream next
    ]

    peek [
	<category: 'stream operations'>
	self atEnd ifTrue: [^nil].
	^stream peek
    ]

    peekFor: aCharacter [
	<category: 'stream operations'>
	self atEnd ifTrue: [^false].
	^stream peek
    ]

    position [
	<category: 'stream operations'>
	^stream position - offset
    ]

    position: anInteger [
	<category: 'stream operations'>
	(anInteger between: 0 and: limit - offset) 
	    ifTrue: [stream position: offset + anInteger]
	    ifFalse: 
		[SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger]
    ]

    setToEnd [
	<category: 'stream operations'>
	stream position: limit
    ]

    size [
	<category: 'stream operations'>
	^limit - offset
    ]

    skip: anInteger [
	<category: 'stream operations'>
	self position: anInteger + self position
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    print: stream;
	    nextPut: $[;
	    print: offset;
	    nextPut: $:;
	    print: limit;
	    nextPut: $]
    ]

    file [
	<category: 'accessing'>
	^stream file
    ]

    name [
	<category: 'accessing'>
	^stream name
    ]

    species [
	<category: 'accessing'>
	^stream species
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    limit: anInteger [
	<category: 'accessing'>
	limit := anInteger
    ]

    offset: anInteger [
	<category: 'accessing'>
	offset := anInteger
    ]

    fileIn [
        "File in the contents of the receiver.
         During a file in operation, global variables (starting with an
         uppercase letter) that are not declared don't yield an `unknown
         variable' error. Instead, they are defined as nil in the `Undeclared'
         dictionary (a global variable residing in Smalltalk).
         As soon as you add the variable to a namespace (for example by creating
         a class) the Association will be removed from Undeclared and reused
         in the namespace, so that the old references will automagically point
         to the new value."

        <category: 'built ins'>
        | pos |
        stream isPipe ifTrue: [ ^super fileIn ].
        ^self
            fileInLine: 1
            file: stream file full
            fileName: stream name
            at: self position
    ]

    flush [
	<category: 'stream protocol'>
	stream flush
    ]

    close [
	<category: 'stream protocol'>
	stream close
    ]
]

]

