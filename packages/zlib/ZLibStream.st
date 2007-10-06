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



Error subclass: ZlibError [
    | stream |
    
    <category: 'Examples-Useful'>
    <comment: 'This exception is raised whenever there is an error
in a compressed stream.'>

    stream [
	"Answer the ZlibStream that caused the error."

	<category: 'accessing'>
	^stream
    ]

    stream: anObject [
	"Set the ZlibStream that caused the error."

	<category: 'accessing'>
	stream := anObject
    ]
]



Stream subclass: ZlibStream [
    | inBytes outBytes zlibObject stream |
    
    <category: 'Examples-Useful'>
    <comment: 'This abstract class implements the basic interface to
the zlib module.  Its layout matches what is expected by the C code.'>

    BufferSize := nil.
    DefaultCompressionLevel := nil.

    ZlibStream class >> bufferSize [
	"Answer the size of the output buffers that are passed to zlib.  Each
	 zlib stream uses a buffer of this size."

	<category: 'accessing'>
	BufferSize isNil ifTrue: [BufferSize := 16384].
	^BufferSize
    ]

    ZlibStream class >> bufferSize: anInteger [
	"Set the size of the output buffers that are passed to zlib.  Each
	 zlib stream uses a buffer of this size."

	<category: 'accessing'>
	BufferSize := anInteger
    ]

    ZlibStream class >> defaultCompressionLevel [
	"Return the default compression level used by deflating streams."

	<category: 'accessing'>
	DefaultCompressionLevel isNil ifTrue: [DefaultCompressionLevel := 6].
	^DefaultCompressionLevel
    ]

    ZlibStream class >> defaultCompressionLevel: anInteger [
	"Set the default compression level used by deflating streams.  It
	 should be a number between 1 and 9."

	<category: 'accessing'>
	DefaultCompressionLevel := anInteger
    ]

    ZlibStream class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    ZlibStream class >> on: aStream [
	"Answer an instance of the receiver that decorates aStream."

	<category: 'instance creation'>
	^self basicNew initialize: aStream
    ]

    stream [
	"Answer the wrapped stream."

	<category: 'streaming'>
	^stream
    ]

    isExternalStream [
	"Answer whether the receiver streams on a file or socket."

	<category: 'streaming'>
	^stream isExternalStream
    ]

    name [
	"Return the name of the underlying stream."

	<category: 'streaming'>
	^stream name
    ]

    species [
	"Return the type of the collections returned by #upTo: etc."

	<category: 'streaming'>
	^stream species
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream.
	self addToBeFinalized
    ]

    finalize [
	<category: 'private'>
	self destroyZlibObject
    ]

    checkError [
	<category: 'private zlib interface'>
	| error |
	error := self getError.
	self
	    finalize;
	    removeToBeFinalized.
	error isNil 
	    ifFalse: 
		[(ZlibError new)
		    messageText: error;
		    stream: self;
		    signal]
    ]

    getError [
	<category: 'private zlib interface'>
	<cCall: 'gst_zlibError' returning: #string args: #(#self)>
	
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	self subclassResponsibility
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	self subclassResponsibility
    ]
]

