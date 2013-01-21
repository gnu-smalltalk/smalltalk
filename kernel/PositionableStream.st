"======================================================================
|
|   PositionableStream Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2007,2008,2009
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



Stream subclass: PositionableStream [
    | collection ptr endPtr access |
    
    <category: 'Streams-Collections'>
    <comment: 'My instances represent streams where explicit positioning is permitted.
Thus, my streams act in a manner to normal disk files: you can read
or write sequentially, but also position the file to a particular place
whenever you choose.  Generally, you''ll want to use ReadStream, WriteStream
or ReadWriteStream instead of me to create and use streams.'>

    PositionableStream class >> on: aCollection [
	"Answer an instance of the receiver streaming on the
	 whole contents of aCollection"

	<category: 'instance creation'>
	self subclassResponsibility
    ]

    PositionableStream class >> on: aCollection from: firstIndex to: lastIndex [
	"Answer an instance of the receiver streaming from
	 the firstIndex-th item of aCollection to the lastIndex-th"

	<category: 'instance creation'>
	^self on: (aCollection copyFrom: firstIndex to: lastIndex)
    ]

    close [
	"Disassociate a stream from its backing store."

	<category: 'accessing-reading'>
	self flush.
	collection := nil.
	endPtr := nil.
	ptr := nil.
	access := nil
    ]

    next [
	"Answer the next item of the receiver.  Returns nil when at end of stream."

	<category: 'accessing-reading'>
	| element |
	(access bitAnd: 1) = 0 ifTrue: [^self shouldNotImplement].
	ptr > endPtr ifTrue: [^self pastEnd].
	element := collection at: ptr.
	ptr := ptr + 1.
	^element
    ]

    nextPutAllOn: aStream [
	"Write all the objects in the receiver to aStream."

	| n |
	(access bitAnd: 1) = 0 ifTrue: [^self shouldNotImplement].
	n := endPtr - ptr + 1.
	aStream next: n putAll: collection startingAt: ptr.
	ptr := ptr + n.
    ]

    nextAvailable: anInteger putAllOn: aStream [
        "Copy up to anInteger objects from the receiver into
	 aStream, stopping if no more data is available."

        <category: 'accessing-reading'>
	| n |
	(access bitAnd: 1) = 0 ifTrue: [^self shouldNotImplement].
	n := anInteger min: endPtr - ptr + 1.
	aStream next: n putAll: collection startingAt: ptr.
	ptr := ptr + n.
	^n
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
        "Place up to anInteger objects from the receiver into
	 aCollection, starting from position pos in the collection
	 and stopping if no more data is available."

        <category: 'accessing-reading'>
	| n |
	(access bitAnd: 1) = 0 ifTrue: [^self shouldNotImplement].
	n := anInteger min: endPtr - ptr + 1.
	aCollection
	    replaceFrom: pos
	    to: pos + n - 1
	    with: collection
	    startingAt: ptr.
	ptr := ptr + n.
	^n
    ]

    peek [
	"Returns the next element of the stream without moving the pointer.
	 Returns nil when at end of stream."

	<category: 'accessing-reading'>
	(access bitAnd: 1) = 0 ifTrue: [^self shouldNotImplement].
	ptr > endPtr ifTrue: [^nil].
	^collection at: ptr
    ]

    peekFor: anObject [
	"Returns true and gobbles the next element from the stream of it is
	 equal to anObject, returns false and doesn't gobble the next element
	 if the next element is not equal to anObject."

	<category: 'accessing-reading'>
	self atEnd ifTrue: [^false].
	^self next = anObject 
	    ifTrue: [true]
	    ifFalse: 
		[self skip: -1.
		false]
    ]

    copyFrom: start to: end [
	"Answer the data on which the receiver is streaming, from
	 the start-th item to the end-th.  Note that this method is 0-based,
	 unlike the one in Collection, because a Stream's #position method
	 returns 0-based values."

	<category: 'accessing-reading'>
	^collection copyFrom: start + 1 to: end + 1
    ]

    contents [
	"Returns a collection of the same type that the stream accesses, up to
	 and including the final element."

	<category: 'accessing-reading'>
	^collection copyFrom: 1 to: endPtr
    ]

    readStream [
	"Answer a ReadStream on the same contents as the receiver"

	<category: 'accessing-reading'>
	^ReadStream 
	    on: collection
	    from: 1
	    to: endPtr
    ]

    reverseContents [
	"Returns a collection of the same type that the stream accesses, up to
	 and including the final element, but in reverse order."

	<category: 'accessing-reading'>
	| newCollection |
	newCollection := collection copyEmpty: endPtr.
	1 to: endPtr
	    do: [:i | newCollection at: i put: (collection at: endPtr - i + 1)].
	^newCollection
    ]

    atEnd [
	"Answer whether the objects in the stream have reached an end"

	<category: 'testing'>
	^ptr > endPtr
    ]

    basicAtEnd [
	"Answer whether the objects in the stream have reached an end.
	 This method must NOT be overridden."

	<category: 'testing'>
	^ptr > endPtr
    ]

    isEmpty [
	"Answer whether the stream has no objects"

	<category: 'testing'>
	^endPtr = 0
    ]

    truncate [
	"Truncate the receiver to the current position - only valid
	 for writing streams"

	<category: 'truncating'>
	(access bitAnd: 2) = 0 
	    ifTrue: [self shouldNotImplement]
	    ifFalse: [endPtr := ptr - 1]
    ]

    position [
	"Answer the current value of the stream pointer"

	<category: 'positioning'>
	^ptr - 1
    ]

    position: anInteger [
	"Move the stream pointer to the anInteger-th object"

	<category: 'positioning'>
	(anInteger between: 0 and: self size) 
	    ifTrue: [ptr := anInteger + 1]
	    ifFalse: 
		[SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger]
    ]

    basicPosition: anInteger [
	"Move the stream pointer to the anInteger-th object"

	<category: 'positioning'>
	(anInteger between: 0 and: self size) 
	    ifTrue: [ptr := anInteger + 1]
	    ifFalse: 
		[SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger]
    ]

    reset [
	"Move the stream back to its first element. For write-only streams,
	 the stream is truncated there."

	<category: 'positioning'>
	self position: 0
    ]

    setToEnd [
	"Move the current position to the end of the stream."

	<category: 'positioning'>
	self position: self size
    ]

    size [
	"Answer the size of data on which we are streaming."

	<category: 'positioning'>
	^endPtr
    ]

    isPositionable [
	"Answer true if the stream supports moving backwards with #skip:."

	<category: 'positioning'>
	^true
    ]

    skip: anInteger [
	"Move the current position by anInteger places, either forwards or
	 backwards."

	<category: 'positioning'>
	self position: ((self position + anInteger max: 0) min: endPtr)
    ]

    beReadOnly [
	<category: 'private'>
	access := 1
    ]

    beWriteOnly [
	<category: 'private'>
	access := 2
    ]

    beReadWrite [
	<category: 'private'>
	access := 3
    ]

    collection [
	<category: 'private'>
	^collection
    ]

    status: aString [
	"When working with a stream on strings, this method can be useful!
	 Format of the output:
	 'ABCDEFG'   aString
	 ^"

	<category: 'private'>
	Transcript
	    print: (collection copyFrom: 1 to: endPtr);
	    nextPutAll: '    ';
	    nextPutAll: aString;
	    nl;
	    next: self position put: Character space;
	    nextPut: $^;
	    nl
    ]

    isExternalStream [
	"We stream on a collection residing in the image, so answer false"

	<category: 'class type methods'>
	^false
    ]

    species [
	"Return the type of the collections returned by #upTo: etc., which are the
	 same kind as those returned by the collection with methods such as #select:."

	<category: 'class type methods'>
	^collection species
    ]

    upToEnd [
	"Returns a collection of the same type that the stream accesses,
	 containing the entire rest of the stream's contents."

	<category: 'accessing-reading'>
	^self next: endPtr - ptr + 1.
    ]

    upTo: anObject [
	"Returns a collection of the same type that the stream accesses, up to
	 but not including the object anObject.  Returns the entire rest of the
	 stream's contents if anObject is not present."

	<category: 'accessing-reading'>
	| result r ws |
	r := collection indexOf: anObject startingAt: ptr ifAbsent: [0].
	^r = 0
	    ifTrue: [self upToEnd]
	    ifFalse: [result := self next: r - ptr. self next. ^result].
    ]

]

