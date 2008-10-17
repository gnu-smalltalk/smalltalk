"======================================================================
|
|   ZLib module declarations
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



ZlibStream subclass: ZlibReadStream [
    | delta ptr endPtr |
    
    <comment: 'This abstract class implements the basic buffering that is
used for communication with zlib.'>
    <category: 'Examples-Useful'>

    atEnd [
	"Answer whether the stream has got to an end"

	<category: 'streaming'>
	ptr >= endPtr ifFalse: [^false].
	^zlibObject isNil or: 
		[self fillBuffer.
		zlibObject isNil]
    ]

    next [
	"Return the next object (character or byte) in the receiver."

	<category: 'streaming'>
	self atEnd ifTrue: [^self pastEnd].
	ptr := ptr + 1.
	^outBytes at: ptr
    ]

    peekFor: anObject [
	"Returns true and gobbles the next element from the stream of it is
	 equal to anObject, returns false and doesn't gobble the next element
	 if the next element is not equal to anObject."

	<category: 'streaming'>
	| result |
	self atEnd ifTrue: [^self pastEnd].
	result := (outBytes at: ptr + 1) = anObject.
	result ifTrue: [ptr := ptr + 1].
	^result
    ]

    nextAvailable: anInteger putAllOn: aStream [
        "Copy up to anInteger objects from the receiver to
         aStream, stopping if no more data is available."

        <category: 'accessing-reading'>
        | n |
	self atEnd ifTrue: [^0].
        n := anInteger min: endPtr - ptr.
        aStream
            next: n
            putAll: outBytes
            startingAt: ptr + 1.
        ptr := ptr + n.
        ^n
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
        "Place up to anInteger objects from the receiver into
         aCollection, starting from position pos and stopping if
         no more data is available."

        <category: 'accessing-reading'>
        | n |
	self atEnd ifTrue: [^0].
        n := anInteger min: endPtr - ptr.
        aCollection
            replaceFrom: pos
            to: pos + n - 1
            with: outBytes
            startingAt: ptr + 1.
        ptr := ptr + n.
        ^n
    ]

    peek [
	"Returns the next element of the stream without moving the pointer.
	 Returns nil when at end of stream."

	<category: 'streaming'>
	self atEnd ifTrue: [^nil].
	^outBytes at: ptr + 1
    ]

    position [
	"Answer the current value of the stream pointer.  Note that only inflating
	 streams support random access to the stream data."

	<category: 'streaming'>
	^delta + ptr
    ]

    resetBuffer [
	<category: 'private'>
	ptr := 0.
	delta := 0.
	endPtr := 0
    ]

    initialize: aStream [
	<category: 'private'>
	super initialize: aStream.
	outBytes := self species new: self class bufferSize.
	self resetBuffer
    ]

    fillBuffer [
	"Fill the output buffer, supplying data to zlib until it can actually
	 produce something."

	<category: 'private'>
	| flush |
	delta := delta + endPtr.
	ptr := 0.
	
	"TODO: reuse the inBytes collection."
	[(inBytes isNil and: [self stream atEnd not]) 
	    ifTrue: [inBytes := self stream nextAvailable: 1024].
	flush := inBytes isNil ifTrue: [4] ifFalse: [0].
	endPtr := self processInput: flush size: inBytes size.
	endPtr = 0] 
		whileTrue.

	"End of data, or zlib error encountered."
	endPtr = -1 ifTrue: [self checkError]
    ]
]



ZlibReadStream subclass: RawDeflateStream [
    
    <comment: 'Instances of this class produce "raw" (PKZIP)
deflated data.'>
    <category: 'Examples-Useful'>

    RawDeflateStream class >> compressingTo: aStream [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream."

	<category: 'instance creation'>
	^RawDeflateWriteStream on: aStream
    ]

    RawDeflateStream class >> compressingTo: aStream level: level [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream with the given compression level."

	<category: 'instance creation'>
	^RawDeflateWriteStream on: aStream level: level
    ]

    RawDeflateStream class >> on: aStream [
	"Answer a stream that compresses the data in aStream with the default
	 compression level."

	<category: 'instance creation'>
	^(super on: aStream) initializeZlibObject: self defaultCompressionLevel
    ]

    RawDeflateStream class >> on: aStream level: compressionLevel [
	"Answer a stream that compresses the data in aStream with the given
	 compression level."

	<category: 'instance creation'>
	^(super on: aStream) initializeZlibObject: compressionLevel
    ]

    initializeZlibObject: level windowSize: winSize [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflateInit' returning: #void args: #(#self #int #int)>
	
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: -15
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflateEnd' returning: #void args: #(#self)>
	
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflate' returning: #int args: #(#self #int #int)>
	
    ]
]



RawDeflateStream subclass: DeflateStream [
    
    <comment: 'Instances of this class produce "standard"
(zlib, RFC1950) deflated data.'>
    <category: 'Examples-Useful'>

    DeflateStream class >> compressingTo: aStream [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream."

	<category: 'instance creation'>
	^DeflateWriteStream on: aStream
    ]

    DeflateStream class >> compressingTo: aStream level: level [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream with the given compression level."

	<category: 'instance creation'>
	^DeflateWriteStream on: aStream level: level
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: 15
    ]
]



RawDeflateStream subclass: GZipDeflateStream [
    
    <comment: 'Instances of this class produce GZip (RFC1952)
deflated data.'>
    <category: 'Examples-Useful'>

    GZipDeflateStream class >> compressingTo: aStream [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream."

	<category: 'instance creation'>
	^GZipDeflateWriteStream on: aStream
    ]

    GZipDeflateStream class >> compressingTo: aStream level: level [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream with the given compression level."

	<category: 'instance creation'>
	^GZipDeflateWriteStream on: aStream level: level
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: 31
    ]
]



ZlibReadStream subclass: RawInflateStream [
    
    <comment: 'Instances of this class reinflate "raw" (PKZIP)
deflated data.'>
    <category: 'Examples-Useful'>

    position: anInteger [
	"Set the current position in the stream to anInteger.  Notice that this
	 class can only provide the illusion of random access, by appropriately
	 rewinding the input stream or skipping compressed data."

	<category: 'positioning'>
	delta > anInteger ifTrue: [self reset].
	[delta + endPtr < anInteger] whileTrue: [self fillBuffer].
	ptr := anInteger - delta
    ]

    reset [
	"Reset the stream to the beginning of the compressed data."

	<category: 'positioning'>
	self stream reset.
	self
	    destroyZlibObject;
	    initializeZlibObject.
	self resetBuffer
    ]

    copyFrom: start to: end [
	"Answer the data on which the receiver is streaming, from
	 the start-th item to the end-th.  Note that this method is 0-based,
	 unlike the one in Collection, because a Stream's #position method
	 returns 0-based values.  Notice that this class can only provide
	 the illusion of random access, by appropriately rewinding the input
	 stream or skipping compressed data."

	<category: 'positioning'>
	| pos |
	pos := self position.
	^
	[self
	    position: start;
	    next: end - start] 
		ensure: [self position: pos]
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
	self position: self position + anInteger
    ]

    initialize: aStream [
	<category: 'private zlib interface'>
	self initializeZlibObject.
	super initialize: aStream
    ]

    initializeZlibObject: windowSize [
	<category: 'private zlib interface'>
	<cCall: 'gst_inflateInit' returning: #void args: #(#self #int)>
	
    ]

    initializeZlibObject [
	<category: 'private zlib interface'>
	self initializeZlibObject: -15
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	<cCall: 'gst_inflateEnd' returning: #void args: #(#self)>
	
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	<cCall: 'gst_inflate' returning: #int args: #(#self #int #int)>
	
    ]
]



RawInflateStream subclass: InflateStream [
    
    <comment: 'Instances of this class reinflate "standard"
(zlib, RFC1950) deflated data.'>
    <category: 'Examples-Useful'>

    initializeZlibObject [
	<category: 'private zlib interface'>
	self initializeZlibObject: 15
    ]
]



RawInflateStream subclass: GZipInflateStream [
    
    <comment: 'Instances of this class reinflate GZip (RFC1952)
deflated data.'>
    <category: 'Examples-Useful'>

    initializeZlibObject [
	<category: 'private zlib interface'>
	self initializeZlibObject: 31
    ]
]

