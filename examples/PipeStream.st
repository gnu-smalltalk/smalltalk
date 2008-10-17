"======================================================================
|
|   PipeStream class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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


PositionableStream subclass: #PipeStream
	instanceVariableNames: 'full data empty contents'
	classVariableNames: 'BufferSize'
	poolDictionaries: ''
	category: 'Examples-Processes'!

PipeStream comment:
'The PipeStream provides two pieces of functionality.  The first
is to provide a dual-ended FIFO stream, which can be read and
written by independent processes.  The second is to provide a
WriteStream-to-ReadStream adaptor, where the data is written to
the PipeStream (the writing side), fueled to an object expecting a
ReadStream (possibly as a decorator), and taken from there into the
destination stream.  The effect is to turn a ReadStream decorator into
a WriteStream decorator.'!

!PipeStream class methodsFor: 'accessing'!

bufferSize
    "Answer the size of the internal buffer.  Each PipeStream uses a
     buffer of this size."
    BufferSize isNil ifTrue: [ BufferSize := 1024 ].
    ^BufferSize!

bufferSize: anInteger
    "Set the size of the internal buffer. Each PipeStream uses a
     uses a buffer of this size."
    BufferSize := anInteger!

!PipeStream class methodsFor: 'instance creation'!

on: aCollection 
    "Answer a new stream using aCollection as its buffer."
    aCollection size = 0 ifTrue: [ self halt ].
    ^self basicNew initCollection: aCollection!

connectedTo: writeStream via: aBlock
    "Create a PipeStream that acts as a WriteStream to ReadStream adaptor.
     The pipe is passed to the 1-parameter block aBlock, which should use
     the pipe as a ReadStream and return another ReadStream.  The data that
     will be written to the pipe will go through the return value of aBlock,
     and then written to aStream.

     Example:
	dest := PipeStream on: fileStream via: [ :r | DeflateStream on: r ].
	dest next: 100 put: $A."

    ^(self on: (writeStream species new: self bufferSize))
	connectTo: writeStream via: aBlock;
	yourself!

on: aCollection via: aBlock
    "Create a PipeStream that acts as a WriteStream to ReadStream adaptor.
     The pipe is passed to the 1-parameter block aBlock, which should use
     the pipe as a ReadStream and return another ReadStream.  The data that
     will be written to the pipe will be placed into aCollection, and can
     be retrieved using the #contents method of the PipeStream.

     Example:
	dest := PipeStream on: String new via: [ :r | DeflateStream on: r ].
	dest next: 100 put: $A.
        dest contents printNl"

    ^self connectedTo: aCollection writeStream via: aBlock!

!PipeStream methodsFor: 'instance creation'!

close
    "Close the pipe, causing all blocked reads and writes to terminate
     immediately."
    | sema |
    sema := full.
    full := nil.
    sema notifyAll.

    sema := empty.
    empty := nil.
    sema notifyAll.

    sema := data.
    data := nil.
    sema notifyAll!

notConnected
    "Answer whether the communication channel has been closed."
    ^full isNil!

isConnected
    "Answer whether the communication channel is still open."
    ^full notNil!

atEnd
    "Answer whether the communication channel is closed and there is no
     data in the buffer."
    ^super atEnd and: [ self notConnected ]!

isEmpty
    "Answer whether there is data in the buffer."
    ^super atEnd!

isFull
    "Answer whether there is room in the buffer."
    ^endPtr = collection size!

next
    "Retrieve the next byte of data from the pipe, blocking if there is none."
    | result |
    [ self isEmpty ] whileTrue: [
	self isConnected ifFalse: [ ^self pastEnd ].
	data wait ].
    result := super next.
    empty notifyAll.
    ^result!

peek
    "Retrieve the next byte of data from the pipe, without gobbling it and
     blocking if there is none."
    [ self isEmpty ] whileTrue: [
	self isConnected ifFalse: [ ^self pastEnd ].
	data wait ].
    ^super peek!

nextPut: anObject
    "Put anObject in the pipe, blocking if it is full."
    [ self isFull ] whileTrue: [
	self isConnected ifFalse: [ ^self pastEnd ].
	empty wait ].
    endPtr := endPtr + 1.
    collection at: endPtr put: anObject.
    data notifyAll.
    self isFull ifTrue: [ full notifyAll ].
    ^anObject!

nextAvailable: anInteger putAllOn: aStream
    "Return a buffer worth of data, blocking until it is full or the pipe
     is closed."
    | n |
    [ self isEmpty and: [ self isConnected ] ] whileTrue: [ full wait ].

    "Here, the buffer is full and all writers are locked, so there is no
     contention between the writer and the reader."
    n := anInteger min: endPtr - ptr + 1.
    aStream next: n putAll: collection startingAt: ptr.
    ^n!

nextAvailable: anInteger into: aCollection startingAt: pos
    "Return a buffer worth of data, blocking until it is full or the pipe
     is closed."
    | n |
    [ self isEmpty and: [ self isConnected ] ] whileTrue: [ full wait ].

    "Here, the buffer is full and all writers are locked, so there is no
     contention between the writer and the reader."
    n := anInteger min: endPtr - ptr + 1.
    aCollection replaceFrom: pos to: pos + n - 1 with: collection startingAt: ptr.
    ^n!

nextAvailablePutAllOn: aStream
    "Return a buffer worth of data, blocking until it is full or the pipe
     is closed."
    [ self isEmpty and: [ self isConnected ] ] whileTrue: [ full wait ].

    "Here, the buffer is full and all writers are locked, so there is no
     contention between the writer and the reader."
    aStream next: endPtr - ptr + 1 putAll: collection startingAt: ptr!

contents
    "Close the channel and return the full contents of the stream.  For
     pipes created with #on:, #contents closes the stream and returns the
     leftover contents of buffer."
    self close.
    ^contents isNil
	ifTrue: [ self bufferContents ]
        ifFalse: [ contents value value ]!

readStream
    "Close the channel and return a readStream on the full contents of
     the stream.  For pipes created with #on:, the stream is created on the
     leftover contents of buffer."
    ^self contents readStream!

reset
    "Drop all data currently in the buffer.  This should not be used
     concurrently with other next or nextPut: operations."

    endPtr := 0.
    ptr := 1.
    empty notifyAll!

!PipeStream methodsFor: 'private methods'!

bufferContents
    "Return the current contents of the buffer and empty it.  This is private
     because it requires a lock even in presence of a single reader and a single
     writer."
    | result |
    result := collection copyFrom: ptr to: endPtr.
    self reset.
    ^result!

connectTo: writeStream via: aBlock
    "Establish a channel as explained in the class method #to:via:."

    "Overwrite the block with a Promise object, so that we complete processing
     and return the entire contents of the underlying stream."
    contents := Promise new.
    [
	| readStream |
	readStream := aBlock value: self.
	[
	    "This blocks the reader process if there is no data in the buffer."
	    writeStream nextPutAll: readStream nextHunk.
	    self isConnected and: [ readStream atEnd not ] ] whileTrue.
        writeStream nextPutAll: readStream contents.

	"Don't evaluate unless requested."
        contents value: [ writeStream contents ] ] fork!

initCollection: aCollection
    collection := aCollection.
    ptr := 1.
    endPtr := 0.
    data := Semaphore new.
    empty := Semaphore new.
    full := Semaphore new.
    contents := nil.
! !
