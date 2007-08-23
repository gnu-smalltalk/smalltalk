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

ZlibStream subclass: #ZlibReadStream
	instanceVariableNames: 'delta ptr endPtr'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

ZlibReadStream comment: 'This abstract class implements the basic buffering that is
used for communication with zlib.'!

ZlibReadStream subclass: #RawDeflateStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

RawDeflateStream comment: 'Instances of this class produce "raw" (PKZIP)
deflated data.'!

RawDeflateStream subclass: #DeflateStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

DeflateStream comment: 'Instances of this class produce "standard"
(zlib, RFC1950) deflated data.'!

RawDeflateStream subclass: #GZipDeflateStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

GZipDeflateStream comment: 'Instances of this class produce GZip (RFC1952)
deflated data.'!

ZlibReadStream subclass: #RawInflateStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

RawInflateStream comment: 'Instances of this class reinflate "raw" (PKZIP)
deflated data.'!

RawInflateStream subclass: #InflateStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

InflateStream comment: 'Instances of this class reinflate "standard"
(zlib, RFC1950) deflated data.'!

RawInflateStream subclass: #GZipInflateStream
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

GZipInflateStream comment: 'Instances of this class reinflate GZip (RFC1952)
deflated data.'!


!ZlibReadStream methodsFor: 'streaming'!

atEnd
    "Answer whether the stream has got to an end"
    ptr >= endPtr ifFalse: [ ^false ].
    ^zlibObject isNil or: [
        self fillBuffer.
        zlibObject isNil ]!

next
    "Return the next object (character or byte) in the receiver."
    self atEnd ifTrue: [ ^self pastEnd ].
    ptr := ptr + 1.
    ^outBytes at: ptr!

peekFor: anObject
    "Returns true and gobbles the next element from the stream of it is
     equal to anObject, returns false and doesn't gobble the next element
     if the next element is not equal to anObject."
    | result | 
    self atEnd ifTrue: [ ^self pastEnd ].
    result := (outBytes at: ptr + 1) = anObject.
    result ifTrue: [ ptr := ptr + 1 ].
    ^result!

nextHunk
    "Answer the next buffers worth of stuff in the Stream represented
     by the receiver.  Do at most one actual compression/decompression
     operation."
    | result |
    self atEnd ifTrue: [ ^self pastEnd ].
    result := outBytes copyFrom: ptr + 1 to: endPtr.
    ptr := endPtr.
    ^result!

peek
    "Returns the next element of the stream without moving the pointer.
     Returns nil when at end of stream."
    self atEnd ifTrue: [ ^nil ].
    ^outBytes at: ptr + 1!

position
    "Answer the current value of the stream pointer.  Note that only inflating
     streams support random access to the stream data."
    ^delta + ptr! !



!ZlibReadStream methodsFor: 'private'!

resetBuffer
    ptr := 0.
    delta := 0.
    endPtr := 0!

initialize: aStream
    super initialize: aStream.
    outBytes := self species new: self class bufferSize.
    self resetBuffer!

fillBuffer
    "Fill the output buffer, supplying data to zlib until it can actually
     produce something."
    | flush |
    delta := delta + endPtr.
    ptr := 0.
    [
        (inBytes isNil and: [ self stream atEnd not ])
	    ifTrue: [ inBytes := self stream nextHunk ].

	flush := inBytes isNil ifTrue: [ 4 ] ifFalse: [ 0 ].
        endPtr := self processInput: flush size: inBytes size.
	endPtr = 0 ] whileTrue.

    "End of data, or zlib error encountered."
    endPtr = -1 ifTrue: [ self checkError ]! !



!RawDeflateStream class methodsFor: 'instance creation'!

compressingTo: aStream
    "Answer a stream that receives data via #nextPut: and compresses it onto
     aStream."
    ^RawDeflateWriteStream on: aStream!

compressingTo: aStream level: level
    "Answer a stream that receives data via #nextPut: and compresses it onto
     aStream with the given compression level."
    ^RawDeflateWriteStream on: aStream level: level!

on: aStream
    "Answer a stream that compresses the data in aStream with the default
     compression level."
    ^(super on: aStream)
	initializeZlibObject: self defaultCompressionLevel!

on: aStream level: compressionLevel
    "Answer a stream that compresses the data in aStream with the given
     compression level."
    ^(super on: aStream)
	initializeZlibObject: compressionLevel!


!RawDeflateStream methodsFor: 'private zlib interface'!

initializeZlibObject: level windowSize: winSize
    <cCall: 'gst_deflateInit' returning: #void args: #(#self #int #int)>!

initializeZlibObject: level
    self initializeZlibObject: level windowSize: -15!

destroyZlibObject
    <cCall: 'gst_deflateEnd' returning: #void args: #(#self)>!

processInput: atEnd size: bytes
    <cCall: 'gst_deflate' returning: #int args: #(#self #int #int)>! !



!DeflateStream class methodsFor: 'instance creation'!

compressingTo: aStream
    "Answer a stream that receives data via #nextPut: and compresses it onto
     aStream."
    ^DeflateWriteStream on: aStream!

compressingTo: aStream level: level
    "Answer a stream that receives data via #nextPut: and compresses it onto
     aStream with the given compression level."
    ^DeflateWriteStream on: aStream level: level!

!DeflateStream methodsFor: 'private zlib interface'!

initializeZlibObject: level
    self initializeZlibObject: level windowSize: 15! !


!GZipDeflateStream class methodsFor: 'instance creation'!

compressingTo: aStream
    "Answer a stream that receives data via #nextPut: and compresses it onto
     aStream."
    ^GZipDeflateWriteStream on: aStream!

compressingTo: aStream level: level
    "Answer a stream that receives data via #nextPut: and compresses it onto
     aStream with the given compression level."
    ^GZipDeflateWriteStream on: aStream level: level!

!GZipDeflateStream methodsFor: 'private zlib interface'!

initializeZlibObject: level
    self initializeZlibObject: level windowSize: 31! !



!RawInflateStream methodsFor: 'positioning'!

position: anInteger
    "Set the current position in the stream to anInteger.  Notice that this
     class can only provide the illusion of random access, by appropriately
     rewinding the input stream or skipping compressed data."
    delta > anInteger ifTrue: [ self reset ].
    [ delta + endPtr < anInteger ] whileTrue: [ self fillBuffer ].
    ptr := anInteger - delta!

reset
    "Reset the stream to the beginning of the compressed data."
    self stream reset.
    self destroyZlibObject; initializeZlibObject.
    self resetBuffer!

copyFrom: start to: end
    "Answer the data on which the receiver is streaming, from
     the start-th item to the end-th.  Note that this method is 0-based,
     unlike the one in Collection, because a Stream's #position method
     returns 0-based values.  Notice that this class can only provide
     the illusion of random access, by appropriately rewinding the input
     stream or skipping compressed data."
    | pos |
    pos := self position.
    ^[ self position: start; next: end - start ]
	ensure: [ self position: pos ]!

isPositionable
    "Answer true if the stream supports moving backwards with #skip:."
    ^true!

skip: anInteger
    "Move the current position by anInteger places, either forwards or
     backwards."
    self position: self position + anInteger!

!RawInflateStream methodsFor: 'private zlib interface'!

initialize: aStream
    self initializeZlibObject.
    super initialize: aStream!

initializeZlibObject: windowSize
    <cCall: 'gst_inflateInit' returning: #void args: #(#self #int)>!

initializeZlibObject
    self initializeZlibObject: -15!

destroyZlibObject
    <cCall: 'gst_inflateEnd' returning: #void args: #(#self)>!

processInput: atEnd size: bytes
    <cCall: 'gst_inflate' returning: #int args: #(#self #int #int)>! !



!InflateStream methodsFor: 'private zlib interface'!

initializeZlibObject
    self initializeZlibObject: 15! !

!GZipInflateStream methodsFor: 'private zlib interface'!

initializeZlibObject
    self initializeZlibObject: 31! !

