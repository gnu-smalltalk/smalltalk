"======================================================================
|
|   Swazoo 2.1 HTTP request/response reading
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
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


Object subclass: SwazooRequestReader [
    | request stream requestLine |

    <category: 'Swazoo-Messages'>

    SwazooRequestReader class >> readFrom: aSwazooStream [
	<category: 'parsing'>
	| reader |
	reader := self new.
	reader initializeStream: aSwazooStream.
	reader readRequest.
	^reader request
    ]

    initializeStream: aSwazooStream [
	<category: 'initialize'>
	stream := aSwazooStream.
	requestLine := HTTPRequestLine new.
    ]

    readBody [
	<category: 'parsing'>
	self request readFrom: stream
    ]

    readHeaders [
	<category: 'abstract-parsing'>
        self subclassResponsibility
    ]

    readRequest [
	<category: 'parsing'>
	self readRequestLine.
	request := (HTTPRequest classFor: self method) new.
        request requestLine: requestLine.
	self readHeaders.
	self request setTimestamp.
	self readBody
    ]

    readRequestLine [
	<category: 'abstract-parsing'>
        self subclassResponsibility
    ]

    request [
	<category: 'accessing'>
        ^request
    ]

    stream [
	<category: 'accessing'>
        ^stream
    ]

    requestURI [
	<category: 'accessing-request line'>
        ^requestLine requestURI
    ]

    requestURI: aString [
	<category: 'accessing-request line'>
        requestLine requestURI: aString
    ]

    httpVersion [
	<category: 'accessing-request line'>
        ^requestLine httpVersion
    ]

    httpVersion: aString [
	<category: 'accessing-request line'>
        requestLine httpVersion: aString
    ]

    method [
	<category: 'accessing-request line'>
        ^requestLine method
    ]

    method: aString [
	<category: 'accessing-request line'>
        requestLine method: aString
    ]
]



SwazooRequestReader subclass: HTTPReader [

    <category: 'Swazoo-Messages'>

    readHeaderFieldFrom: aString [
	<category: 'parsing'>
        | sourceStream fieldName fieldValue |
        sourceStream := ReadStream on: aString.
        fieldName := sourceStream upTo: $:.
        fieldValue := sourceStream upToEnd.
        ^HeaderField name: fieldName value: fieldValue
    ]

    readHeaders [
	<category: 'parsing'>
        | nextLine field header |

        [nextLine := stream nextUnfoldedLine.
        nextLine isEmpty] whileFalse: [
	    request headers addField: (self readHeaderFieldFrom: nextLine)].
        ^self
    ]

    readRequestLine [
	<category: 'parsing'>
        self skipLeadingBlankLines.
        self method: (stream upTo: Character space asInteger) asString.
        self parseURI.
        self parseHTTPVersion.
    ]

    parseHTTPVersion [
        <category: 'parsing'>
        | major minor |
        self skipSpaces.
        stream upTo: $/ asInteger.
        major := (stream upTo: $. asInteger) asString asNumber.
        minor := (stream upTo: Character cr asInteger) asString asNumber.
        self httpVersion: (Array with: major with: minor).
        stream next.
    ]

    parseURI [
        <category: 'parsing'>
        self skipSpaces.
        self requestURI:
	    (SwazooURI
                fromString: (stream upTo: Character space asInteger) asString).
        ^self
    ]

    skipLeadingBlankLines [
        "^self
         RFC 2616:
         In the interest of robustness, servers SHOULD ignore any empty
         line(s) received where a Request-Line is expected. In other words, if
         the server is reading the protocol stream at the beginning of a
         message and receives a CRLF first, it should ignore the CRLF."

        <category: 'parsing'>
        [stream peek == Character cr asInteger] whileTrue:
                [((stream next: 2) at: 2) == Character lf asInteger
                    ifFalse: [SwazooHTTPParseError raiseSignal: 'CR without LF']].
        ^self
    ]

    skipSpaces [
        <category: 'parsing'>
        [stream peek = Character space] whileTrue: [stream next].
        ^self
    ]
]



Object subclass: SwazooResponsePrinter [
    | stream response |

    <category: 'Swazoo-Messages'>

    SwazooResponsePrinter class >> writeHeadersFor: aResponse to: aSwazooStream [
	<category: 'private-sending'>
	aSwazooStream isNil ifTrue: [ ^self ].
	^self new
	    response: aResponse;
	    stream: aSwazooStream;
	    writeHeader;
	    closeResponse
    ]

    SwazooResponsePrinter class >> writeResponse: aResponse to: aSwazooStream [
	<category: 'private-sending'>
	aSwazooStream isNil ifTrue: [ ^self ].
	^self new
	    response: aResponse;
	    stream: aSwazooStream;
	    writeResponseTo: nil;
	    closeResponse
    ]

    SwazooResponsePrinter class >> writeResponse: aResponse for: aRequest to: aSwazooStream [
	<category: 'private-sending'>
	aSwazooStream isNil ifTrue: [ ^self ].
	^self new
	    response: aResponse;
	    stream: aSwazooStream;
	    writeResponseTo: aRequest;
	    closeResponse
    ]

    response [
	<category: 'accessing'>
	^response
    ]

    response: aResponse [
	<category: 'accessing'>
	response := aResponse
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aSwazooStream [
	<category: 'accessing'>
	stream := aSwazooStream
    ]

    closeResponse [
	<category: 'private-sending'>
	stream closeResponse
    ]

    endHeader [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    printChunkedTransferEncoding [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    printContentLength [
	"it is also added to headers. It is added so late because to be printed last,
	 just before body starts"

	<category: 'sending'>
	self printHeader: response contentLength
    ]

    printHeader: aField [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    printHeaders [
	"^self
	 Write the headers (key-value pairs) to aStream.  The key
	 must be a String."

	<category: 'sending'>
	response headers fields do: 
		[:aField | self printHeader: aField]
    ]

    printStatus [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    writeHeader [
	<category: 'sending'>
	self printStatus.
	self printHeaders.
	(response isStreamed and: [response shouldBeChunked]) 
	    ifTrue: [self printChunkedTransferEncoding]
	    ifFalse: [self printContentLength].
	self endHeader
    ]

    writeResponseTo: aRequest [
	<category: 'sending'>
	stream isNil ifTrue: [^self].
	self writeHeader.
	(aRequest isNil or: [aRequest isHead not]) 
	    ifTrue: [response printEntityOn: self stream].
	stream closeResponse
    ]
]


SwazooResponsePrinter subclass: HTTPPrinter [

    <category: 'Swazoo-Messages'>

    crlf [
	<category: 'private-sending'>
	stream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    endHeader [
	<category: 'private-sending'>
	self crlf
    ]

    printChunkedTransferEncoding [
	<category: 'private-sending'>
	stream nextPutAll: 'Transfer-Encoding: chunked'.
	self crlf
    ]

    printHeader: aField [
	<category: 'private-sending'>
        stream
            nextPutAll: aField name;
            nextPutAll: ': '.
        aField valuesAsStringOn: stream.
	self crlf
    ]

    printStatus [
	<category: 'private-sending'>
	| version |
	version := (response task isNil 
		    or: [response task request isNil or: [response task request isHttp11]]) 
			ifTrue: ['HTTP/1.1 ']
			ifFalse: ['HTTP/1.0 '].
	stream
	    nextPutAll: version;
	    print: response code;
	    space;
	    nextPutAll: response codeText.
	self crlf
    ]
]
