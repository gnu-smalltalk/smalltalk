"======================================================================
|
|   Swazoo 2.1 HTTP handling
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2008 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


ReadWriteStream subclass: SwazooBuffer [
    
    <category: 'Swazoo-HTTP'>
    <comment: 'SwazooBuffer is used for efficient buffering of receiving or sending data to TCP socket. Efficiency is achieved with reusing of stream content array instead of initializing it everytime buffer is emptied, as was in previous Swazoo versions. 

SwazooBuffer is a subclass of ReadWriteStream, with additional #clear to empty buffer.

'>

    SwazooBuffer class >> defaultBufferSize [
	"length of buffer at creation. Later not nessesary exactly this number!!"

	<category: 'defaults'>
	^8000	"about 8KB-preamble"
    ]

    SwazooBuffer class >> newRead [
	<category: 'instance creation'>
	^(super on: (ByteArray new: self defaultBufferSize))
		truncate
    ]

    SwazooBuffer class >> newWrite [
	<category: 'instance creation'>
	^(super 
	    on: (ByteArray new: self defaultBufferSize + self preambleSize + 2)) 
		initPreamble	"chunk crlf"
    ]

    SwazooBuffer class >> preambleSize [
	"chunk size line (fixed to 4 hex characters) + crlf"

	<category: 'defaults'>
	^6
    ]

    atEnd [
	<category: 'testing'>
	^super atEnd	"for now"
    ]

    closeChunkTo: aSocket [
	"a zero sized chunk determine and end of chunked data and also response"

	"pack all together to send one TCP packet ony"

	<category: 'writing-chunked'>
	| chunk written |
	chunk := ByteString new: 5.
	chunk at: 1 put: $0.
	chunk at: 2 put: Character cr.	"first crlf ends 0 length line"
	chunk at: 3 put: Character lf.
	chunk at: 4 put: Character cr.	"second crlf ends whole response"
	chunk at: 5 put: Character lf.
	written := aSocket 
		    writeFrom: chunk asByteArray
		    startingAt: 1
		    for: chunk size.
	written = chunk size ifFalse: [self error: 'socket write error']
    ]

    contents [
	"Answer a copy of the receiver's collection, skipping preamble."

	<category: 'accessing'>
	endPtr := endPtr max: ptr.
	^self copyFrom: self class preambleSize - 1 to: endPtr - 1
    ]

    copyBufferTo: anIndex [
	"from current position to desired index"

	<category: 'mime boundary'>
	| start |
	start := ptr.
	ptr := anIndex.
	^self copyFrom: start to: anIndex - 1
    ]

    flushChunkTo: aSocket [
	"a buffer will be sent as a chunk, with hex size in first line then crlf, buffer, then crlf"

	"send a complete chunk in one piece, don't partition TCP sending in too many packets!!"

	<category: 'writing-chunked'>
	| length |
	self size > 65535 ifTrue: [self error: 'chunk too long!'].	"preamble has no room for bigger"
	length := self size printStringRadix: 16.
	SpEnvironment isSqueak 
	    ifTrue: [length := length copyFrom: 4 to: length size].	"trim 16r"
	1 to: length size
	    do: [:inx | collection at: inx put: (length at: inx) asInteger].
	length size + 1 to: 4 do: [:inx | collection at: inx put: $  asInteger].	"add spaces"
	collection at: 5 put: Character cr asInteger.
	collection at: 6 put: Character lf asInteger.
	"add finishing crlf to buffer"
	self nextPut: Character cr asInteger.
	self nextPut: Character lf asInteger.
	self flushTo: aSocket chunked: true	"flush all at once"
    ]

    flushTo: aSocket [
	"actually write to the tcp socket as direclty as possible"

	<category: 'writing'>
	self flushTo: aSocket chunked: false
    ]

    flushTo: aSocket chunked: chunkedBoolean [
	"actually write to the tcp socket as direclty as possible
	 (directly from stream's instvar collection)"

	<category: 'private'>
	| remaining start written |
	remaining := chunkedBoolean 
		    ifTrue: [ptr	"ensure to send preamble too"]
		    ifFalse: [ptr - self class preambleSize].	"skip preamble"
	[remaining > 0] whileTrue: 
		[start := ptr - remaining.
		written := aSocket 
			    writeFrom: collection
			    startingAt: start
			    for: ptr - start.
		remaining := remaining - written].
	self writeClear
    ]

    indexOfBoundary: aBoundaryBytes [
	"index of boundary start, beeing full boundary or part at the end of buffer. 0 if not found"

	<category: 'mime boundary'>
	| inx innerInx firstInx |
	inx := ptr + 1.
	[inx <= endPtr] whileTrue: 
		[innerInx := 1.
		firstInx := inx.
		[(aBoundaryBytes at: innerInx) = (collection at: inx)] whileTrue: 
			[innerInx = aBoundaryBytes size ifTrue: [^firstInx].	"full boundary found"
			inx = endPtr ifTrue: [^firstInx].	"partial boundary at the edge of buffer found"
			inx := inx + 1.
			innerInx := innerInx + 1].
		inx := inx + 1].
	^0
    ]

    initPreamble [
	"make room for possible chunk 'preamble' = length line"

	<category: 'initialize-release'>
	ptr := self class preambleSize
    ]

    isBinary [
	<category: 'testing'>
	^collection class == ByteArray
    ]

    isFull [
	"buffer full or even more"

	<category: 'testing'>
	^ptr >= self class defaultBufferSize
    ]

    readClear [
	"reset as you'd make another one, just don't replace content array"

	<category: 'initialize-release'>
	ptr := 1.
	endPtr := self class defaultBufferSize
    ]

    readContents [
	<category: 'accessing'>
	"whole buffer?"
	^(ptr = 1 and: [endPtr = collection size]) 
	    ifTrue: [collection	"avoid copying for performance"]
	    ifFalse: [collection copyFrom: ptr to: endPtr - 1]
    ]

    refillFrom: aSocket [
	"reset and read from to the tcp socket as direclty as possible
	 (directly from stream's instvar collection)"

	<category: 'reading'>
	aSocket isNil ifTrue: [^self].	"if SwazooStream is used for tests only"
	self readClear.	"just reset pointers, not a collection!!"
	endPtr := aSocket 
		    readInto: collection
		    startingAt: 1
		    for: collection size.	"nr. of actuall bytes read"
	self atEnd 
	    ifTrue: 
		[SwazooStreamNoDataError 
		    raiseSignal: 'No data available.  Socket probably closed']
    ]

    signsOfBoundary: aBoundaryBytes [
	"detect as fast as possible if any if not all MIME part boundary is present in buffer contents"

	"return number of bundary bytes detected, 0 = no boundary"

	<category: 'mime boundary'>
	| first index |
	first := aBoundaryBytes first.
	"fast test"
	((ptr + 1 to: endPtr) 
	    contains: [:inx | (collection at: inx) = first]) ifFalse: [^0].
	"full or partial boundary on the edge of buffer test"
	index := self indexOfBoundary: aBoundaryBytes.	"index of full, or partial boundary at the edge"
	index = 0 ifTrue: [^0].	"no boundary found"
	endPtr - index >= aBoundaryBytes size ifTrue: [^aBoundaryBytes size].	"full boundary detected"
	^endPtr - index + 1	"partial boundary at the end of buffer"
    ]

    size [
	<category: 'accessing'>
	^ptr - self class preambleSize
    ]

    startsWith: aPartialBoundaryBytes [
	"is remaining part of MIME part boundary at the start of buffer?"

	"VW specific!!"

	<category: 'mime boundary'>
	1 to: aPartialBoundaryBytes size
	    do: 
		[:inx | 
		(collection at: ptr + inx) = (aPartialBoundaryBytes at: inx) 
		    ifFalse: [^false]].
	^true
    ]

    writeClear [
	"reset as you'd make another one, just don't replace content array"

	<category: 'initialize-release'>
	self reset.
	endPtr := 0.
	self initPreamble
    ]
]



