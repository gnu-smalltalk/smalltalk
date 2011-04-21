"======================================================================
|
|   ReadBuffer and WriteBuffer classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2007, 2008, 2009 Free Software Foundation, Inc.
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



WriteStream subclass: WriteBuffer [
    | flushBlock |
    
    <category: 'Examples-Useful tools'>
    <comment: '
I''m a WriteStream that, instead of growing the collection,
evaluates an user defined block and starts over with the same
collection.'>

    flush [
	"Evaluate the flushing block and reset the stream"

	<category: 'buffer handling'>
	flushBlock notNil ifTrue: [flushBlock value: collection value: ptr - 1].
	ptr := 1
    ]

    close [
	<category: 'buffer handling'>
        super close.
        flushBlock := nil
    ]

    flushBlock: block [
	"Set which block will be used to flush the buffer.
	 The block will be evaluated with a collection and
	 an Integer n as parameters, and will have to write
	 the first n elements of the collection."

	<category: 'buffer handling'>
	flushBlock := block
    ]

    growCollection [
	<category: 'private'>
	self flush
    ]

    growCollectionTo: n [
	<category: 'private'>
	self shouldNotImplement
    ]

    isFull [
	<category: 'testing'>
	^self position = self collection size
    ]

    next: n putAll: aCollection startingAt: pos [
        "Put n characters or bytes of aCollection, starting at the pos-th,
         in the collection buffer."

        <category: 'accessing-writing'>

	| end written amount |
	ptr = collection size ifTrue: [self growCollection].
	written := 0.
	
	[end := collection size min: ptr + (n - written - 1).
	end >= ptr 
	    ifTrue: 
		[collection 
		    replaceFrom: ptr
		    to: end
		    with: aCollection
		    startingAt: pos + written.
		written := written + (end - ptr + 1).
		ptr := end + 1].
	written < n] 
		whileTrue: [self growCollection].
    ]

]



ReadStream subclass: ReadBuffer [
    | fillBlock |
    
    <category: 'Examples-Useful tools'>
    <comment: '
I''m a ReadStream that, when the end of the stream is reached,
evaluates an user defined block to try to get some more data.'>

    ReadBuffer class >> on: aCollection [
	"Answer a Stream that uses aCollection as a buffer.  You
	 should ensure that the fillBlock is set before the first
	 operation, because the buffer will report that the data
	 has ended until you set the fillBlock."

	<category: 'instance creation'>
	^(super on: aCollection)
	    setToEnd;
	    yourself	"Force a buffer load soon"
    ]

    close [
	<category: 'buffer handling'>
        super close.
        fillBlock := nil
    ]

    atEnd [
	"Answer whether the data stream has ended."

	<category: 'buffer handling'>
	self basicAtEnd ifFalse: [^false].
	fillBlock isNil ifTrue: [^true].
	endPtr := fillBlock value: collection value: collection size.
	ptr := 1.
	^self basicAtEnd
    ]

    pastEnd [
	"Try to fill the buffer if the data stream has ended."

	<category: 'buffer handling'>
	self atEnd ifTrue: [^super pastEnd].
	"Else, the buffer has been filled."
	^self next
    ]

    bufferContents [
	"Answer the data that is in the buffer, and empty it."

	<category: 'buffer handling'>
	| contents |
	self basicAtEnd ifTrue: [^self species new: 0].
	contents := self collection copyFrom: ptr to: endPtr.
	endPtr := ptr - 1.	"Empty the buffer"
	^contents
    ]

    availableBytes [
        "Answer how many bytes are available in the buffer."

	<category: 'buffer handling'>
	self isEmpty ifTrue: [ self fill ].
	^endPtr + 1 - ptr
    ]

    nextAvailable: anInteger putAllOn: aStream [
	"Copy the next anInteger objects from the receiver to aStream.
	 Return the number of items stored."

	<category: 'accessing-reading'>
	self isEmpty ifTrue: [ self fill ].
	^super nextAvailable: anInteger putAllOn: aStream
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
	"Place the next anInteger objects from the receiver into aCollection,
	 starting at position pos.  Return the number of items stored."

	<category: 'accessing-reading'>
	self isEmpty ifTrue: [ self fill ].
	^super nextAvailable: anInteger into: aCollection startingAt: pos
    ]

    fill [
	"Fill the buffer with more data if it is empty, and answer
	 true if the fill block was able to read more data."

	<category: 'buffer handling'>
	^self atEnd not
    ]

    fillBlock: block [
	"Set the block that fills the buffer. It receives a collection
	 and the number of bytes to fill in it, and must return the number
	 of bytes actually read"

	<category: 'buffer handling'>
	fillBlock := block
    ]

    isEmpty [
	"Answer whether the next input operation will force a buffer fill"

	<category: 'buffer handling'>
	^self basicAtEnd
    ]

    isFull [
	"Answer whether the buffer has been just filled"

	<category: 'buffer handling'>
	^self notEmpty and: [self position = 0]
    ]

    notEmpty [
	"Check whether the next input operation will force a buffer fill
	 and answer true if it will not."

	<category: 'buffer handling'>
	^self basicAtEnd not
    ]

    upToEnd [
	"Returns a collection of the same type that the stream accesses, up to
	 but not including the object anObject.  Returns the entire rest of the
	 stream's contents if anObject is not present."

	<category: 'accessing-reading'>
	| ws |
	ws := String new writeStream.
	[self nextAvailablePutAllOn: ws.
	self atEnd] whileFalse.
	^ws contents
    ]

    upTo: anObject [
	"Returns a collection of the same type that the stream accesses, up to
	 but not including the object anObject.  Returns the entire rest of the
	 stream's contents if anObject is not present."

	<category: 'accessing-reading'>
	| result r ws |
	self atEnd ifTrue: [^collection copyEmpty: 0].
	r := collection indexOf: anObject startingAt: ptr ifAbsent: [0].
	r = 0 ifFalse: [result := self next: r - ptr. self next. ^result].

	ws := String new writeStream.
	[self nextAvailablePutAllOn: ws.
	self atEnd ifTrue: [^ws contents].
	r := collection indexOf: anObject startingAt: ptr ifAbsent: [0].
	r = 0] whileTrue.

	self next: r - 1 putAllOn: ws; next.
	^ws contents
    ]
]

