"======================================================================
|
|   Swazoo SCGI add-on
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Nicolas Petton
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


AbstractHTTPServer subclass: SCGIServer [
    | port |

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    createSocket [
	<category: 'start/stop'>
	^(self socketClass serverOnIP: self ip port: self port)
	    listenFor: 50;
	    yourself
    ]

    ip [
	<category: 'private-initialize'>
	^'0.0.0.0'
    ]

    port [
	<category: 'private-initialize'>
	^port
    ]

    port: anInteger [
	<category: 'private-initialize'>
	port := anInteger
    ]

    requestReaderClass [
	<category: 'serving'>
	^SCGIReader
    ]

    responsePrinterClass [
	<category: 'serving'>
	^SCGIPrinter
    ]

    socketClass [
	<category: 'serving'>
	^SwazooSocket
    ]
]

URIIdentifier subclass: SCGIIdentifier [
    | port |

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    SCGIIdentifier class >> port: aPort [
	<category: 'instance creation'>
	^self new setPort: aPort
    ]

    SCGIIdentifier class >> host: aString ip: anotherString port: aPort [
	<category: 'instance creation'>
	^self port: aPort
    ]

    currentUrl [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents
    ]

    port [
	<category: 'accessing'>
	^port
    ]

    port: aNumber [
	<category: 'private'>
	port := aNumber
    ]

    ip [
	^'0.0.0.0'
    ]

    isEmpty [
	<category: 'testing'>
	^port isNil
    ]

    newServer [
	<category: 'initialize-release'>
	^SCGIServer new port: self port
    ]

    setPort: aPort [
	<category: 'initialize-release'>
	self port: aPort
    ]

    printString [
	<category: 'private'>
	^'a Swazoo.SCGIIndentifier'
    ]

    printUrlOn: aWriteStream [
	<category: 'private'>
	aWriteStream nextPutAll: '*:' , self port printString
    ]

    portMatch: aSCGIIdentifier [
	<category: 'private-comparing'>
	^self port = aSCGIIdentifier port
    ]

    valueMatch: aRequestOrIdentifier [
	<category: 'private-comparing'>
	^self portMatch: aRequestOrIdentifier
    ]
]

HTTPPrinter subclass: SCGIPrinter [

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    printStatus [
	<category: 'private-sending'>
	stream
	    nextPutAll: 'Status: ';
	    print: response code;
	    space;
	    nextPutAll: response codeText.
	self crlf
    ]
]

SwazooRequestReader subclass: SCGIReader [
    | fields |

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    readNetString [
	<category: '*Swazoo-SCGI'>
	"This method implements the NetString protocol as
	defined by: http://cr.yp.to/proto/netstrings.txt"

	| size c answer |
	size := 0.
	[(c := stream next) >= $0 and: [c <= $9]] whileTrue: [
	    size := (size * 10) + (c value - 48)].

	c = $: ifFalse: [ ^self error: 'invalid net string'].
	answer := stream next: size.
	stream next = $, ifFalse: [ ^self error: 'invalid net string'].
	^answer
    ]

    readHeaders [
	<category: 'parsing'>
	| uriHeader methodHeader |
	self readHeadersFrom: self readNetString.
	uriHeader := fields
	    detect: [:each | each name asUppercase = 'REQUEST-URI']
	    ifNone: [nil].
	self requestURI: (SwazooURI fromString: (uriHeader
	    ifNil: ['']
	    ifNotNil: [uriHeader value])).
	methodHeader := fields
	    detect: [:each | each name asUppercase = 'REQUEST-METHOD']
	    ifNone: [nil].
	self method: (methodHeader
	    ifNil: ['GET']
	    ifNotNil: [methodHeader value]).
    ]

    readHeadersFrom: aString [
	"This is the request parsing code based on Simple CGI standard:
	 http://python.ca/scgi/protocol.txt"
	<category: 'parsing'>

	| zero start end key valueEnd value |
	zero := Character value: 0.
	start := 1.
	fields := OrderedCollection new.

	[end := aString indexOf: zero startingAt: start.
	key := aString copyFrom: start to: end - 1.
	valueEnd := aString indexOf: zero startingAt: end + 1.
	value := aString copyFrom: end + 1 to: valueEnd - 1.
	fields add: (HeaderField
	    name: (self convertFieldName: key)
	    value: value).
	valueEnd = aString size]
	    whileFalse: [start := valueEnd + 1]
    ]

    readRequest [
	<category: 'parsing'>
	self readHeaders.
	request := (HTTPRequest classFor: self method) new.
	self httpVersion: #(0 0).
	fields do: [:each |
	    request headers
		fieldOfClass: each class
		ifNone: [request headers addField: each]].
	request requestLine: requestLine.
	self request setTimestamp.
	self readBody.
    ]

    convertFieldName: aString [
	<category: 'private'>
	^(aString
	    copyReplacingAllRegex: '^HTTP_' with: '')
	    copyReplacingAllRegex: '_' with: '-'
    ]
]

SwazooSite extend [
    scgiPort: aNumber [
	<category: '*Swazoo-SCGI'>
	| identifier |
        identifier := self uriPattern
            detect: [ :each | each isKindOf: SCGIIdentifier ]
            ifNone: [ self uriPattern add: SCGIIdentifier new ].
        identifier port: aNumber
    ]
]
