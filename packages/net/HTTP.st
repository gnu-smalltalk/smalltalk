"======================================================================
|
|   HTTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2005 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Namespace current: NetClients.HTTP [

NetClient subclass: HTTPClient [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-HTTP'>

    HTTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^80
    ]

    HTTPClient class >> defaultSSLPortNumber [
	<category: 'constants'>
	^443
    ]

    HTTPClient class >> exampleURL: url host: host port: port [
	"self exampleURL: 'http://www.gnu.org' host: 'www.gnu.org' port: 80."

	"self exampleURL: 'http://www.gnu.org' host: 'localhost' port: 8080."

	<category: 'examples'>
	| body headers client |
	client := HTTPClient connectToHost: host port: port.
	
	[headers := client 
		    get: url
		    requestHeaders: #()
		    into: (body := WriteStream on: String new)] 
		ensure: [client close].
	^headers -> body contents
    ]

    get: urlString requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	^self clientPI 
	    get: urlString
	    requestHeaders: requestHeaders
	    into: aStream
    ]

    getBinary: urlString [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: (String new: 1024).
	self 
	    get: urlString
	    requestHeaders: Array new
	    into: stream.
	^stream contents
    ]

    getText: urlString [
	<category: 'accessing'>
	^self clientPI decode: (self getBinary: urlString)
    ]

    head: urlString requestHeaders: requestHeaders [
	<category: 'accessing'>
	^self clientPI head: urlString requestHeaders: requestHeaders
    ]

    head: urlString requestHeaders: requestHeaders into: aStream [
	"This method is deprecated in favor of #head:requestHeaders:, because the
	 last parameter is effectively unused."

	<category: 'accessing'>
	^self clientPI head: urlString requestHeaders: requestHeaders
    ]

    post: urlString type: type data: data binary: binary requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	^self clientPI 
	    post: urlString
	    type: type
	    data: data
	    binary: binary
	    requestHeaders: requestHeaders
	    into: aStream
    ]

    protocolInterpreter [
	<category: 'private'>
	^HTTPProtocolInterpreter
    ]
]

]



Namespace current: NetClients.HTTP [

NetProtocolInterpreter subclass: HTTPProtocolInterpreter [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-HTTP'>

    HTTPProtocolInterpreter class >> defaultResponseClass [
	<category: 'private-attributes'>
	^HTTPResponse
    ]

    get: urlString requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	self connectIfClosed.
	self
	    nextPutAll: 'GET ' , urlString , ' HTTP/1.1';
	    cr.
	self putRequestHeaders: requestHeaders.
	^self readResponseInto: aStream
    ]

    readResponseStream: aResponseStream into: aStream length: aContentLength [
	<category: 'accessing'>
	| remaining |
	remaining := aContentLength.
	[remaining = 0] whileFalse: 
		[| data |
		data := aResponseStream next: (4096 min: remaining).
		remaining := remaining - data size.
		self reporter readByte: data size.
		aStream nextPutAll: data]
    ]

    readChunkedResponseStream: aResponseStream into: aStream [
	<category: 'accessing'>
	"Happily, aResponseStream should be buffered."

	| cr lf chunkSize chunkExt i remaining s |
	cr := Character cr.
	lf := Character lf.
	
	[aResponseStream atEnd ifTrue: [^self].
        (aResponseStream peek asUppercase isDigit: 16) 
	    ifFalse: 
		[self 
		    error: 'Expecting chunk-size, but found ' 
			    , aResponseStream peek printString , '.'].
	chunkSize := Integer readFrom: aResponseStream radix: 16.

	"Technically, a chunk-extension should start with $;, but we'll
	 ignore everything to the CRLF for simplicity (we don't understand
	 any chunk extensions, so we have to ignore them)."
	[aResponseStream next = cr and: [aResponseStream next = lf]] whileFalse.
	chunkSize = 0] 
		whileFalse: 
		    ["Possibly we should just read it all?"

		    self 
			readResponseStream: aResponseStream
			into: aStream
			length: chunkSize.
		    (aResponseStream next = cr and: [aResponseStream next = lf]) 
			ifFalse: 
			    [self error: 'Expected CRLF but found: ' , s printString
			    "We could try to recover by reading to the next CRLF, I suppose..."].
		    chunkSize = 0].
	aResponseStream peekFor: cr.
	aResponseStream peekFor: lf
	"There shouldn't be a trailer as we didn't say it was acceptable in the request."
    ]

    readResponseInto: aStream [
	<category: 'accessing'>
	| response totalByte readStream |
	response := self getResponse.
	self checkResponse: response.
	totalByte := response fieldAt: 'Content-Length' ifAbsent: [nil].
	totalByte notNil 
	    ifTrue: 
		["#asInteger strips 'Content-Length' from the front of the string."

		totalByte := totalByte value trimSeparators asInteger.
		self reporter totalByte: totalByte].
	self reporter startTransfer.
	readStream := self connectionStream stream.
	response preReadBytes isEmpty 
	    ifFalse: 
		[self reporter readByte: response preReadBytes size.
		readStream := response preReadBytes readStream , readStream].
	totalByte notNil 
	    ifTrue: 
		[self 
		    readResponseStream: readStream
		    into: aStream
		    length: totalByte]
	    ifFalse: 
		[| te s |
		self readChunkedResponseStream: readStream into: aStream.
		"Remove 'chunked' from transfer-encoding header"
		te := response fieldAt: 'transfer-encoding' ifAbsent: [nil].
		te notNil 
		    ifTrue: 
			[s := te value.
			(s 
			    indexOf: 'chunked'
			    matchCase: false
			    startingAt: 1) ifNotNil: 
				    [:i | 
				    te value: (s copyFrom: 1 to: i first - 1) , (s copyFrom: i last + 1)]]].
	self reporter endTransfer.
	response keepAlive ifFalse: [self close].
	^response
    ]

    head: urlString requestHeaders: requestHeaders [
	<category: 'accessing'>
	| response |
	self connectIfClosed.
	self reporter startTransfer.
	self
	    nextPutAll: 'HEAD ' , urlString , ' HTTP/1.1';
	    cr.
	self putRequestHeaders: requestHeaders.
	response := self getResponse.
	self checkResponse: response.
	self reporter endTransfer.
	response keepAlive ifFalse: [self close].
	^response
    ]

    putRequestHeaders: requestHeaders [
	<category: 'accessing'>
	| host |
	host := false.
	requestHeaders do: 
		[:header | 
		('Host:*' match: header) ifTrue: [host := true].
		self
		    nextPutAll: header;
		    cr].

	"The Host header is necessary to support virtual hosts"
	host 
	    ifFalse: 
		[self
		    nextPutAll: 'Host: ' , self client hostName;
		    cr].
	self cr
    ]

    post: urlString type: type data: data binary: binary requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	| readStream response totalByte |
	self connectIfClosed.
	self
	    nextPutAll: 'POST ' , urlString , ' HTTP/1.1';
	    cr.
	self
	    nextPutAll: 'Content-Type: ' , type;
	    cr.
	self
	    nextPutAll: 'Content-Length: ' , data size printString;
	    cr.
	self putRequestHeaders: requestHeaders.
	binary 
	    ifTrue: [(self connectionStream stream) nextPutAll: data; flush]
	    ifFalse: [self nextPutAll: data].
	^self readResponseInto: aStream
    ]

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.

	"Successful"
	status = 200 
	    ifTrue: 
		["OK"

		^self].
	status = 201 
	    ifTrue: 
		["Created"

		^self].
	status = 202 
	    ifTrue: 
		["Accepted"

		^self].
	status = 203 
	    ifTrue: 
		["Provisional Information"

		^self].
	status = 204 
	    ifTrue: 
		["No Response"

		^self].
	status = 205 
	    ifTrue: 
		["Deleted"

		^self].
	status = 206 
	    ifTrue: 
		["Modified"

		^self].

	"Redirection"
	(status = 301 or: 
		["Moved Permanently"

		status = 302	"Moved Temporarily"]) 
	    ifTrue: 
		[^self redirectionNotify: response ifInvalid: errorBlock].
	status = 303 
	    ifTrue: 
		["Method"

		^self].
	status = 304 
	    ifTrue: 
		["Not Modified"

		^self].

	"Client Error"
	status = 400 
	    ifTrue: 
		["Bad Request"

		^errorBlock value].
	status = 401 
	    ifTrue: 
		["Unauthorized"

		^errorBlock value].
	status = 402 
	    ifTrue: 
		["Payment Required"

		^errorBlock value].
	status = 403 
	    ifTrue: 
		["Forbidden"

		^errorBlock value].
	status = 404 
	    ifTrue: 
		["Not Found"

		^errorBlock value].
	status = 405 
	    ifTrue: 
		["Method Not Allowed"

		^errorBlock value].
	status = 406 
	    ifTrue: 
		["None Acceptable"

		^errorBlock value].
	status = 407 
	    ifTrue: 
		["Proxy Authent. Required"

		^errorBlock value].
	status = 408 
	    ifTrue: 
		["Request Timeout"

		^errorBlock value].

	"Server Errors"
	status = 500 
	    ifTrue: 
		["Internal Server Error"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["Not Implemented"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["Bad Gateway"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["Service Unavailable"

		^errorBlock value].
	status = 504 
	    ifTrue: 
		["Gateway Timeout"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    redirectionNotify: aResponse ifInvalid: errorBlock [
	<category: 'private'>
        | ex |
	ex := HTTPRedirection new.
	ex response: aResponse.
        ex location isNil
            ifTrue: [ ^errorBlock value ]
            ifFalse: [
                ex tag: ex location. "backwards compatibility"
	        ex signal ].
    ]
]

]



Namespace current: NetClients.HTTP [

NetResponse subclass: HTTPResponse [
    | version messageHeader preReadBytes |
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-HTTP'>

    fieldAt: key [
	<category: 'accessing'>
	^messageHeader fieldAt: key
    ]

    fieldAt: key ifAbsent: absentBlock [
	<category: 'accessing'>
	^messageHeader fieldAt: key ifAbsent: absentBlock
    ]

    keepAlive [
	<category: 'accessing'>
	| connection |
	(self fieldAt: 'content-length' ifAbsent: [nil]) isNil ifTrue: [^false].
	connection := self fieldAt: 'connection' ifAbsent: [nil].
	connection := connection isNil ifTrue: [''] ifFalse: [connection value].

	"For HTTP/1.0, the default is close and there is a de facto
	 standard way to specify keep-alive connections"
	version < 'HTTP/1.1' 
	    ifTrue: [^'*keep-alive*' match: connection ignoreCase: true].

	"For HTTP/1.1, the default is keep-alive"
	^('*close*' match: connection ignoreCase: true) not
    ]

    messageHeader [
	<category: 'accessing'>
	^messageHeader
    ]

    preReadBytes [
	<category: 'accessing'>
	^preReadBytes isNil ifTrue: [#[]] ifFalse: [preReadBytes]
    ]

    parseResponse: aClient [
	<category: 'parsing'>
	| messageHeaderParser |
	messageHeader := MIME.MimeEntity new.
	version := aClient nextAvailable: 8.
	('HTTP/1.#' match: version) 
	    ifFalse: 
		["may be HTTP/0.9"

		preReadBytes := version.
		status := 200.
		statusMessage := 'OK'.
		version := 'HTTP/0.9'.
		^self].
	self parseStatusLine: aClient.
	messageHeaderParser := MIME.MimeEntity parser on: aClient connectionStream.
	messageHeader parseFieldsFrom: messageHeaderParser.
	messageHeaderParser assertNoLookahead.
	preReadBytes := #().
    ]

    printOn: aStream [
	<category: 'printing'>
	self printStatusOn: aStream.
	aStream cr.
	messageHeader printOn: aStream
    ]

    printStatusOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'HTTP/1.0 '.
	super printStatusOn: aStream
    ]

    parseStatusLine: aClient [
	<category: 'private'>
	| stream |
	stream := aClient nextLine readStream.
	stream skipSeparators.
	status := Integer readFrom: stream.
	stream skipSeparators.
	statusMessage := stream upToEnd
    ]
]

]



Namespace current: NetClients.HTTP [

ProtocolNotification subclass: HTTPRedirection [
    
    <category: 'NetClients-HTTP'>
    <comment: nil>

    | location |

    location [
        location isNil ifFalse: [^location].
        response isNil ifTrue: [^nil].
	location := response fieldAt: 'Location' ifAbsent: [nil].
        location isNil ifFalse: [location := location value].
	^location
    ]
]

]

