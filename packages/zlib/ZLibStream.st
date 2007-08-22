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

Error subclass: #ZlibError
	instanceVariableNames: 'stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Examples-Useful'!

ZlibError comment: 'This exception is raised whenever there is an error
in a compressed stream.'!

Stream subclass: #ZlibStream
	instanceVariableNames: 'inBytes outBytes zlibObject stream'
	classVariableNames: 'BufferSize DefaultCompressionLevel'
	poolDictionaries: ''
	category: 'Examples-Useful'!

ZlibStream comment: 'This abstract class implements the basic interface to
the zlib module.  Its layout matches what is expected by the C code.'!


!ZlibError methodsFor: 'accessing'!

stream
    "Answer the ZlibStream that caused the error."
    ^stream!

stream: anObject
    "Set the ZlibStream that caused the error."
    stream := anObject! !


!ZlibStream class methodsFor: 'accessing'!

bufferSize
    "Answer the size of the output buffers that are passed to zlib.  Each
     zlib stream uses a buffer of this size."
    BufferSize isNil ifTrue: [ BufferSize := 16384 ].
    ^BufferSize!

bufferSize: anInteger
    "Set the size of the output buffers that are passed to zlib.  Each
     zlib stream uses a buffer of this size."
    BufferSize := anInteger!

defaultCompressionLevel
    "Return the default compression level used by deflating streams."
    DefaultCompressionLevel isNil ifTrue: [ DefaultCompressionLevel := 6 ].
    ^DefaultCompressionLevel!

defaultCompressionLevel: anInteger
    "Set the default compression level used by deflating streams.  It
     should be a number between 1 and 9."
    DefaultCompressionLevel := anInteger!


!ZlibStream class methodsFor: 'instance creation'!

new
    self shouldNotImplement!

on: aStream
    "Answer an instance of the receiver that decorates aStream."
    ^self basicNew initialize: aStream!



!ZlibStream methodsFor: 'streaming'!

stream
    "Answer the wrapped stream."
    ^stream!

isExternalStream
    "Answer whether the receiver streams on a file or socket."
    ^stream isExternalStream!

name
    "Return the name of the underlying stream."
    ^stream name
!

species
    "Return the type of the collections returned by #upTo: etc."
    ^stream species! !



!ZlibStream methodsFor: 'private'!

initialize: aStream
    stream := aStream.
    self addToBeFinalized!

finalize
    self destroyZlibObject! !

!ZlibStream methodsFor: 'private zlib interface'!

checkError
    | error |
    error := self getError.
    self finalize; removeToBeFinalized.
    error isNil ifFalse: [
	ZlibError new messageText: error; stream: self; signal ]!

getError
    <cCall: 'gst_zlibError' returning: #string args: #(#self)>!

destroyZlibObject
    self subclassResponsibility!

processInput: atEnd size: bytes
    self subclassResponsibility! !
