"======================================================================
|
|   ZLib module unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



TestCase subclass: ZlibStreamTest [
    | oldBufSize |
    
    <comment: nil>
    <category: 'Examples-Useful'>

    ZlibStreamTest class >> fooVector [
	"Return a long and repetitive string."

	<category: 'testing'>
	| original size answer |
	original := 'The quick brown fox jumps over the lazy dog
'.
	size := original size.
	answer := String new: size * 81.
	1 to: 81
	    do: 
		[:idx | 
		answer 
		    replaceFrom: (idx - 1) * size + 1
		    to: idx * size
		    with: original].
	^answer
    ]

    setUp [
	<category: 'testing'>
	oldBufSize := ZlibStream bufferSize.
	ZlibStream bufferSize: 512
    ]

    tearDown [
	<category: 'testing'>
	ZlibStream bufferSize: oldBufSize
    ]

    assertFooVector: string [
	"SUnit-Assert that string = `self fooVector'."

	<category: 'testing'>
	self assert: string = self fooVector
    ]

    fooVector [
	"Refactored to class."

	<category: 'testing'>
	^self class fooVector
    ]

    doDeflate [
	"Deflate the long string and return the result."

	<category: 'testing'>
	^(DeflateStream on: self fooVector readStream) contents
    ]

    testError [
	"Test whether catching errors works."

	<category: 'testing'>
	self should: [(InflateStream on: #[12 34 56] readStream) contents]
	    raise: ZlibError
    ]

    testSyncFlush [
	"Test flushing the WriteStream version of DeflateStream."

	<category: 'testing'>
	| dest stream contents |
	stream := String new writeStream.
	dest := DeflateStream compressingTo: stream.
	dest
	    nextPutAll: self fooVector;
	    syncFlush.
	contents := stream contents.
	self assert: (contents asByteArray last: 4) = #[0 0 255 255].
	self 
	    assert: (InflateStream on: contents readStream) contents = self fooVector
    ]

    testWrite [
	"Test the WriteStream version of DeflateStream."

	<category: 'testing'>
	| dest |
	dest := DeflateStream compressingTo: String new writeStream.
	dest nextPutAll: self fooVector.
	self assert: dest contents asByteArray = self doDeflate asByteArray
    ]

    testRaw [
	"Test connecting a DeflateStream back-to-back with an InflateStream."

	<category: 'testing'>
	| deflate |
	deflate := RawDeflateStream on: self fooVector readStream.
	self assertFooVector: (RawInflateStream on: deflate) contents
    ]

    testGZip [
	"Test connecting a DeflateStream back-to-back with an InflateStream."

	<category: 'testing'>
	| deflate |
	deflate := GZipDeflateStream on: self fooVector readStream.
	self assertFooVector: (GZipInflateStream on: deflate) contents
    ]

    testDirect [
	"Test connecting a DeflateStream back-to-back with an InflateStream."

	<category: 'testing'>
	| deflate |
	deflate := DeflateStream on: self fooVector readStream.
	self assertFooVector: (InflateStream on: deflate) contents
    ]

    testInflate [
	"Basic compression/decompression test."

	<category: 'testing'>
	self 
	    assertFooVector: (InflateStream on: self doDeflate readStream) contents
    ]

    testNextAvailable [
	"Test accessing data with nextAvailable (needed to file-in compressed data)."

	<category: 'testing'>
	| stream data |
	stream := InflateStream on: self doDeflate readStream.
	data := String new.
	[stream atEnd] whileFalse: [data := data , (stream nextAvailable: 1024) ].
	self assertFooVector: data
    ]

    testNextAvailablePutAllOn [
	"Test accessing data with nextAvailablePutAllOn."

	<category: 'testing'>
	| stream data |
	stream := InflateStream on: self doDeflate readStream.
	data := String new writeStream.
	[stream atEnd] whileFalse: [stream nextAvailablePutAllOn: data].
	self assertFooVector: data contents
    ]

    testRandomAccess [
	"Test random access to deflated data."

	<category: 'testing'>
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
	self assert: (original copyFrom: 515 to: 1024) = (stream next: 510)
    ]
]

