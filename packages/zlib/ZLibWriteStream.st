"======================================================================
|
|   ZLib module declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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

DLD addModule: 'zlib'!

ZlibStream subclass: #ZlibWriteStream
	instanceVariableNames: 'delta ptr'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

ZlibWriteStream comment: 'This abstract class implements the basic buffering
that is used for communication with zlib in a WriteStream decorator.'!

ZlibWriteStream subclass: #RawDeflateWriteStream
	instanceVariableNames: ''
	classVariableNames: 'DefaultCompressionLevel'
	poolDictionaries: ''
	category: 'Examples-Useful'!

RawDeflateWriteStream comment: 'Instances of this class produce "raw" (PKZIP)
deflated data.'!

RawDeflateWriteStream subclass: #DeflateWriteStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

DeflateWriteStream comment: 'Instances of this class produce "standard"
(zlib, RFC1950) deflated data.'!

RawDeflateWriteStream subclass: #GZipDeflateWriteStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

GZipDeflateWriteStream comment: 'Instances of this class produce GZip (RFC1952)
deflated data.'!


!ZlibWriteStream methodsFor: 'streaming'!

flushBuffer
    "Flush the deflated output to the destination stream."
    self flushBuffer: 0.
!

flush
    "Flush the deflated output to the destination stream, and flush the
     destination stream."
    self flushBuffer: 0.
    self stream flush
!

partialFlush
    "Flush the deflated output to the destination stream using Z_PARTIAL_FLUSH,
     and flush the destination stream."
    self flushBuffer: 1.
    self stream flush
!

syncFlush
    "Flush the deflated output to the destination stream using Z_SYNC_FLUSH,
     and flush the destination stream.  Note that this includes the four
     bytes 0/0/255/255 at the end of the flush."
    self flushBuffer: 2.
    self stream flush
!

flushDictionary
    "Flush the deflated output to the destination stream using Z_FULL_FLUSH,
     and flush the destination stream."
    self flushBuffer: 3.
    self stream flush
!

finish
    "Finish the deflated output to the destination stream using Z_FINISH.
     The destination stream is not flushed."
    self flushBuffer: 4.
    self stream flush
!

close
    "Finish the deflated output to the destination stream using Z_FINISH.
     The destination stream is closed, which implies flushing."
    self finish.
    self stream close.
!

readStream
    "Finish the deflated output to the destination stream using Z_FINISH and
     return a ReadStream on the deflated data (requires the destination
     stream to support #readStream)."
    | result |
    self finish.
    result := self stream readStream.
    self stream close.
    ^result
!

contents
    "Finish the deflated output to the destination stream using Z_FINISH and
     return the deflated data (requires the destination stream to support
     #contents)."
    | result |
    self finish.
    result := self stream contents.
    self stream close.
    ^result!

nextPut: aByte
    "Append a character or byte (depending on whether the destination
     stream works on a ByteArray or String) to the deflation buffer."
    ptr = inBytes size ifTrue: [ self flushBuffer ].
    inBytes at: ptr put: aByte.
    ptr := ptr + 1!

nextPutAll: aCollection
    "Put all the characters or bytes in aCollection in the deflation buffer."

    | n coll written |
    "Just do 'coll := aCollection asString', but avoid expensive operations
     in the common case where aCollection is already a String."
    ptr = inBytes size ifTrue: [ self flushBuffer ].

    coll := aCollection isSequenceable
        ifTrue: [ aCollection ]
        ifFalse: [
            [ aCollection asString ]
                on: MessageNotUnderstood
                do: [ :ex |
                    "If we are in a stream, try to facilitate buffering."
                    [ aCollection atEnd ] whileFalse: [
                        coll := aCollection nextHunk.
                        self next: coll size putAll: coll startingAt: 1 ].
                    ^self ] ].

    self next: coll size putAll: coll startingAt: 1!

next: n putAll: aCollection startingAt: pos
    "Put n characters or bytes of aCollection, starting at the pos-th,
     in the deflation buffer."

    | written amount |
    ptr = inBytes size ifTrue: [ self flushBuffer ].
    written := 0.
    [
        amount := inBytes size - ptr + 1 min: n - written.
        self next: amount bufferAll: aCollection startingAt: pos + written.
        written := written + amount.
        written < n
    ] whileTrue: [ self flushBuffer ]!

position
    "Answer the number of compressed bytes written."
    self flushBuffer.
    ^delta! !



!ZlibWriteStream methodsFor: 'private'!

next: n bufferAll: aCollection startingAt: pos
    "Private - Assuming that the buffer has space for n characters, store
     n characters of aCollection in the buffer, starting from the pos-th."
    n = 0 ifTrue: [ ^self ].
    inBytes
        replaceFrom: ptr
        to: ptr + n - 1
        with: aCollection
        startingAt: pos.

    ptr := ptr + n.
!

initialize: aWriteStream
    super initialize: aWriteStream.
    inBytes := self species new: self class bufferSize.
    outBytes := self species new: self class bufferSize.
    ptr := 1.
    delta := 0!

flushBuffer: flag
    "Fill the output buffer, supplying data to zlib until it exhausts
     the input buffer, and putting the output into the destination stream."
    | endPtr buffer |
    [
	"The module uses the convention of nil-ing out inBytes when its data
	 is completely consumed; this is useless for this class, so undo it."
        buffer := inBytes.
        endPtr := self processInput: flag size: ptr - 1.
        inBytes := buffer.
	ptr := 1.
        endPtr = -1 ifTrue: [ self checkError ].
	endPtr > 0
    ] whileTrue: [
        delta := delta + endPtr.
	self stream next: endPtr putAll: outBytes startingAt: 1
    ]! !


!RawDeflateWriteStream class methodsFor: 'instance creation'!

on: aWriteStream
    "Answer a stream that compresses the data in aStream with the default
     compression level."
    ^self basicNew
	initializeZlibObject: self defaultCompressionLevel;
	initialize: aWriteStream!

on: aWriteStream level: compressionLevel
    "Answer a stream that compresses the data in aStream with the given
     compression level."
    ^self basicNew
	initializeZlibObject: compressionLevel;
	initialize: aWriteStream!


!RawDeflateWriteStream methodsFor: 'private zlib interface'!

initializeZlibObject: level windowSize: winSize
    <cCall: 'gst_deflateInit' returning: #void args: #(#self #int #int)>!

initializeZlibObject: level
    self initializeZlibObject: level windowSize: -15!

destroyZlibObject
    <cCall: 'gst_deflateEnd' returning: #void args: #(#self)>!

processInput: atEnd size: bytes
    <cCall: 'gst_deflate' returning: #int args: #(#self #int #int)>! !


!DeflateWriteStream methodsFor: 'private zlib interface'!

initializeZlibObject: level
    self initializeZlibObject: level windowSize: 15! !


!GZipDeflateWriteStream methodsFor: 'private zlib interface'!

initializeZlibObject: level
    self initializeZlibObject: level windowSize: 31! !

