"======================================================================
|
|   ZLib module unit tests
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Stephen Compall
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

TestCase subclass: #ZlibStreamTest
	 instanceVariableNames: 'oldBufSize'
	 classVariableNames: ''
	 poolDictionaries: ''
	 category: 'Examples-Useful'!

!ZlibStreamTest class methodsFor: 'testing'!

fooVector
    "Return a long and repetitive string."
    | original size answer |
    original := 'The quick brown fox jumps over the lazy dog
'.
    size := original size.
    answer := String new: size * 81.
    1 to: 81 do: [:idx |
	answer replaceFrom: (idx - 1) * size + 1 to: idx * size
	       with: original].
    ^answer! !

!ZlibStreamTest methodsFor: 'testing'!

setUp
    oldBufSize := ZlibStream bufferSize.
    ZlibStream bufferSize: 512!

tearDown
    ZlibStream bufferSize: oldBufSize!

assertFooVector: string
    "SUnit-Assert that string = `self fooVector'."
    self assert: string = self fooVector!

fooVector
    "Refactored to class."
    ^self class fooVector!

doDeflate
    "Deflate the long string and return the result."
    ^(DeflateStream on: self fooVector readStream) contents!

testError
    "Test whether catching errors works."
    self should: [ (InflateStream on: #[12 34 56] readStream) contents ]
	 raise: ZlibError!

testSyncFlush
    "Test flushing the WriteStream version of DeflateStream."
    | dest stream contents |
    stream := String new writeStream.
    dest := DeflateStream compressingTo: stream.
    dest nextPutAll: self fooVector; syncFlush.
    contents := stream contents.
    self assert: (contents asByteArray last: 4) = #[0 0 255 255].
    self assert: (InflateStream on: contents readStream) contents = self fooVector!

testWrite
    "Test the WriteStream version of DeflateStream."
    | dest |
    dest := DeflateStream compressingTo: String new writeStream.
    dest nextPutAll: self fooVector.
    self assert: dest contents asByteArray = self doDeflate asByteArray!

testRaw
    "Test connecting a DeflateStream back-to-back with an InflateStream."
    | deflate |
    deflate := RawDeflateStream on: self fooVector readStream.
    self assertFooVector: (RawInflateStream on: deflate) contents!

testGZip
    "Test connecting a DeflateStream back-to-back with an InflateStream."
    | deflate |
    deflate := GZipDeflateStream on: self fooVector readStream.
    self assertFooVector: (GZipInflateStream on: deflate) contents!

testDirect
    "Test connecting a DeflateStream back-to-back with an InflateStream."
    | deflate |
    deflate := DeflateStream on: self fooVector readStream.
    self assertFooVector: (InflateStream on: deflate) contents!

testInflate
    "Basic compression/decompression test."
    self assertFooVector: (InflateStream on: self doDeflate readStream) contents!

testNextHunk
    "Test accessing data with nextHunk (needed to file-in compressed data)."
    | stream data |
    stream := InflateStream on: self doDeflate readStream.

    data := String new.
    [ stream atEnd ] whileFalse: [ data := data, stream nextHunk ].
    self assertFooVector: data!

testRandomAccess
    "Test random access to deflated data."
    | original stream data ok |
    original := self fooVector.
    stream := InflateStream on: self doDeflate readStream.
    stream contents.

    stream position: 0.
    self assert: (original copyFrom: 1 to: 512) = (stream next: 512).
    stream position: 512.
    self assert: (original copyFrom: 513 to: 1024) = (stream next: 512).
    stream position: 1536.
    self assert: (original copyFrom: 1537 to: 2048) = (stream next: 512).
    stream position: 1.
    self assert: (original copyFrom: 2 to: 512) = (stream next: 511).
    stream position: 514.
    self assert: (original copyFrom: 515 to: 1024) = (stream next: 510)! !
