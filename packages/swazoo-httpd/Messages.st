"======================================================================
|
|   Swazoo 2.1 HTTP request/response framework
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


Object subclass: HTTPMessage [
    | task headers |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    addInitialHeaders [
	"^self
	 This is a no-op.  My subclasses may wish to add some initial headers."

	<category: 'initialize-release'>
	^self
    ]

    headers [
	<category: 'accessing'>
	headers isNil ifTrue: [self initHeaders].
	^headers
    ]

    initHeaders [
	<category: 'initialize-release'>
	headers := HTTPHeaders new.
	self addInitialHeaders
    ]

    task [
	"on which task (request/response pair) this message belongs"

	"to get a connection on which this task belongs, use task connection"

	<category: 'accessing'>
	^task
    ]

    task: aSwazooTask [
	<category: 'accessing'>
	task := aSwazooTask
    ]
]



HTTPMessage subclass: HTTPRequest [
    | requestLine peer timestamp ip environmentData resolution encrypted authenticated host |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    HTTPRequest class >> allMethodNames [
	"...of all request methods we support there"

	<category: 'accessing'>
	self subclasses collect: [:each | each methodName]
    ]

    HTTPRequest class >> methodName [
	"HTTP method used for a request"

	<category: 'accessing'>
	^self subclassResponsibility
    ]

    HTTPRequest class >> classFor: aString [
	"to support an additional http method, simply subclass a HTTPRequest!!"

	<category: 'instance creation'>
	aString = 'GET' ifTrue: [^HTTPGet	"most used anyway"].
	aString = 'POST' ifTrue: [^HTTPPost	"second most used"].

	^self subclasses detect: [:each | each methodName = aString]
	    ifNone: [^HTTPException notImplemented].
    ]

    HTTPRequest class >> readFrom: aSwazooStream [
	"For testing only (I'm guessing / hoping!!)."

	<category: 'tests support'>
	^HTTPReader readFrom: aSwazooStream
    ]

    HTTPRequest class >> request: aUriString [
	"For testing only (I'm guessing / hoping!!).  The idea to to create a request for a resource with the URI 'someHost/aUriString'."

	<category: 'tests support'>
	^self 
	    request: aUriString
	    from: 'someHost'
	    at: 'someIP'
    ]

    HTTPRequest class >> request: aUriString from: aHostString at: anIPString [
	"For testing only (I'm guessing / hoping!!).
	 A request is manufactured that has a request line method of >>methodName and a request line URI with an identifier of aUriString.  A Host header is added to the headers and the ip address is set to anIP string.
	 This may result in a corrupt or invalid request, but that's the natutre of testing, I guess."

	<category: 'tests support'>
	^self new 
	    request: aUriString
	    from: aHostString
	    at: anIPString
    ]

    authenticated [
	<category: 'private'>
	^authenticated
    ]

    conditionalHeaderFields [
	"^an OrderedCollection
	 I return my collection of conditional header fields.  A conditional GET requires that each of these is checked against the current state of the target resource."

	<category: 'services'>
	^self headers fields select: [:aField | aField isConditional]
    ]

    connection [
	<category: 'accessing-headers'>
	^(self headers fieldOfClass: HTTPConnectionField ifNone: [^nil]) 
	    connectionToken
    ]

    contentLength [
	<category: 'accessing-headers'>
	^(self headers fieldOfClass: HTTPContentLengthField) contentLength
    ]

    cookie [
	<category: 'accessing-headers'>
	| field |
	field := self headers fields at: 'COOKIE' ifAbsent: [^nil].
	^field value

	"field := self headers fieldOfClass: HTTPCookieField ifNone: [nil].
	 ^field isNil ifTrue: [nil] ifFalse: [field valuesAsString]"
    ]

    encrypted [
	<category: 'private'>
	^encrypted
    ]

    ensureFullRead [
	"that is, that everything is read from a socket stream. Importanf for HTTPost
	 and defered parsing of postData"

	<category: 'private'>
	
    ]

    environmentAt: aKey [
	<category: 'accessing'>
	^self environmentAt: aKey ifAbsent: [nil]
    ]

    environmentAt: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	^self environmentData at: aKey ifAbsent: aBlock
    ]

    environmentAt: aKey put: aValue [
	<category: 'accessing'>
	self environmentData at: aKey put: aValue
    ]

    environmentData [
	<category: 'private'>
	environmentData isNil ifTrue: [self initEnvironmentData].
	^environmentData
    ]

    requestLine: aRequestLine [
	"^self
	 I parse my headers from aStream and update my URI and HTTP version information from aRequest line.  I need to parse the headers first because, for some reason, the URI insists on knowing the host, and this is taken from the Host: header field."

	<category: 'initialize-release'>
	requestLine := aRequestLine.
    ]

    hasCookie [
	"check if  Cookie:  was in request header"

	"it is GenericHeaderField!!"

	<category: 'testing'>
	^self headers fields includesKey: 'COOKIE'

	"^self headers includesFieldOfClass: HTTPCookieField"
    ]

    headerAt: aKey ifAbsent: aBlock [
	<category: 'accessing-headers'>
	^self headers fieldNamed: aKey ifNone: aBlock
    ]

    host [
	<category: 'accessing-headers'>
        host isNil ifTrue: [host := self computeHost].
        ^host
    ]

    computeHost [
	<category: 'private'>
	| value |
        value := self headers
	    fieldOfClass: HTTPHostField
	    ifPresent: [:field | field hostName]
	    ifAbsent: [self requestLine requestURI hostname].

        ^value notNil ifTrue: [value] ifFalse: ['']
    ]

    httpVersion [
	<category: 'accessing'>
	^self requestLine httpVersion
    ]

    includesQuery: aString [
	<category: 'accessing-queries'>
	^self uri includesQuery: aString
    ]

    initEnvironmentData [
	<category: 'initialize-release'>
	environmentData := Dictionary new
    ]

    initRequestLine [
	<category: 'initialize-release'>
	requestLine := HTTPRequestLine new
    ]

    ip [
	<category: 'accessing'>
	^ip
    ]

    ip: anObject [
	<category: 'private'>
	ip := anObject
    ]

    isAuthenticated [
	<category: 'testing'>
	^self authenticated isNil not
    ]

    isClose [
	<category: 'testing'>
	| connectionField |
	connectionField := self headers fieldOfClass: HTTPConnectionField
		    ifNone: [nil].
	^connectionField notNil and: [connectionField connectionTokenIsClose]
    ]

    isDelete [
	<category: 'testing'>
	^false
    ]

    isEncrypted [
	<category: 'testing'>
	^self encrypted isNil not
    ]

    isFromLinux [
	<category: 'testing'>
	^self userAgent notNil and: ['*Linux*' match: self userAgent]
    ]

    isFromMSIE [
	<category: 'testing'>
	^self userAgent notNil and: ['*MSIE*' match: self userAgent]
    ]

    isFromNetscape [
	"NS>7.0 or Mozilla or Firefox"

	<category: 'testing'>
	^self userAgent notNil and: ['*Gecko*' match: self userAgent]
    ]

    isFromWindows [
	<category: 'testing'>
	^self userAgent notNil and: ['*Windows*' match: self userAgent]
    ]

    isGet [
	<category: 'testing'>
	^false
    ]

    isHead [
	<category: 'testing'>
	^false
    ]

    isHttp10 [
	"Version of requests's HTTP protocol is 1.0"

	<category: 'testing'>
	^self requestLine isHttp10
    ]

    isHttp11 [
	"Version of requests's HTTP protocol is 1.0"

	<category: 'testing'>
	^self requestLine isHttp11
    ]

    isKeepAlive [
	<category: 'testing'>
	| header |
	header := self connection.
	header isNil ifTrue: [^false].
	^'*Keep-Alive*' match: header
    ]

    isOptions [
	<category: 'testing'>
	^false
    ]

    isPost [
	<category: 'testing'>
	^false
    ]

    isPut [
	<category: 'testing'>
	^false
    ]

    isTrace [
	<category: 'testing'>
	^false
    ]

    keepAlive [
	"how many seconds a connection must be kept alive"

	<category: 'accessing-headers'>
	^(self headers fieldNamed: 'KeepAlive' ifNone: [^nil]) value
    ]

    methodName [
	"HTTP method used for a request"

	<category: 'accessing'>
	^self class methodName
    ]

    peer [
	<category: 'accessing'>
	^peer
    ]

    peer: anObject [
	<category: 'private'>
	peer := anObject
    ]

    port [
	"^an Integer
	 I return the port number to which the request was directed."

	<category: 'accessing-headers'>
	| host |
	host := self headers fieldOfClass: HTTPHostField.
	^(host notNil and: [(self httpVersion at: 2) = 1]) 
	    ifTrue: [host portNumber]
	    ifFalse: [self requestLine requestURI port]
    ]

    printOn: aStream [
	<category: 'private'>
	aStream nextPutAll: 'a HTTPRequest ' , self methodName.
	self isHttp10 ifTrue: [aStream nextPutAll: ' HTTP/1.0'].
	self peer notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' from: ';
		    nextPutAll: self peer hostAddressString].
	aStream
	    cr;
	    tab;
	    nextPutAll: ' at: '.
	aStream nextPutAll: self timestamp printString.
	aStream
	    cr;
	    tab;
	    nextPutAll: ' host: ';
	    nextPutAll: (self headerAt: 'Host' ifAbsent: ['']) hostName.
	aStream
	    cr;
	    tab;
	    nextPutAll: ' url: '.
	self uri printOn: aStream.
	self userAgent notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' browser: ';
		    nextPutAll: self userAgent].
	self connection notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' connection: ';
		    nextPutAll: self connection].
	self keepAlive notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' keep-alive: ';
		    nextPutAll: self keepAlive].
	^self
    ]

    queries [
	<category: 'private'>
	^self uri queries
    ]

    queryAt: aKey [
	<category: 'accessing-queries'>
	^self uri queryAt: aKey
    ]

    queryAt: aKey ifAbsent: aBlock [
	<category: 'accessing-queries'>
	^self uri queryAt: aKey ifAbsent: aBlock
    ]

    queryData [
	<category: 'accessing-queries'>
	^self uri queryData
    ]

    readFrom: aSwazooStream [
	<category: 'parsing'>
    ]

    referer [
	<category: 'accessing-headers'>
	| field |
	field := self headers fieldOfClass: HTTPRefererField ifNone: [nil].
	^field isNil ifTrue: [nil] ifFalse: [field uri asString]
    ]

    request: aUriString from: aHostString at: anIPString [
	"For testing only (I'm guessing / hoping!!).
	 A request is manufactured that has a request line method of >>methodName and a request line URI with an identifier of aUriString.  A Host header is added to the headers and the ip address is set to anIP string.  I also set the HTTP version to #(1 1).
	 This may result in a corrupt or invalid request, but that's the natutre of testing, I guess."

	<category: 'private'>
	requestLine := (HTTPRequestLine new)
		    method: self class methodName;
		    requestURI: ((SwazooURI new)
				identifier: aUriString;
				yourself);
		    httpVersion: #(1 1);
		    yourself.
	self headers addField: (HTTPHostField newWithValueFrom: aHostString).
	self ip: anIPString.
	^self
    ]

    requestLine [
	"^an HTTPRequestLine"

	<category: 'accessing'>
	requestLine isNil ifTrue: [self initRequestLine].
	^requestLine
    ]

    resolution [
	<category: 'accessing'>
	^resolution
    ]

    resolution: anObject [
	<category: 'accessing'>
	resolution := anObject
    ]

    resourcePath [
	<category: 'accessing'>
	^self resolution resourcePath
    ]

    respondUsing: responseBlock [
	"^an HTTPResponse
	 By default, I let aBlock handle creating the response by passing myself as the agrument to the block.  My subclasses may override this method and directly respond.  This is most likely for Unsupported requests and for things like OPTIONS requsts.  c.f. HTTPServer>>answerTo:"

	<category: 'services'>
	^responseBlock value: self
    ]

    session [
	<category: 'accessing'>
	^self environmentAt: #session
    ]

    session: aSession [
	<category: 'accessing'>
	self environmentAt: #session put: aSession
    ]

    setAuthenticated [
	<category: 'private'>
	authenticated := true
    ]

    setEncrypted [
	<category: 'private'>
	encrypted := true
    ]

    setTimestamp [
	<category: 'initialize-release'>
	timestamp := SpTimestamp now
    ]

    streamedResponse [
	"prepares (if not already) and return a streamed response"

	"necessary because we need an output stream to stream into"

	<category: 'accessing-response'>
	self task response isNil 
	    ifTrue: 
		[self task response: (HTTPStreamedResponse on: self task
			    stream: self task connection stream)].
	self task response class == HTTPStreamedResponse 
	    ifFalse: [self error: 'not streamed response?'].	"this can happen if resp. is from before"
	^self task response
    ]

    tailPath [
	<category: 'accessing'>
	^self resolution tailPath
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    uri [
	<category: 'accessing'>
	^self requestLine requestURI
    ]

    uriString [
	<category: 'accessing'>
	^self uri identifier
    ]

    urlString [
	<category: 'accessing'>
	^self uri value
    ]

    userAgent [
	<category: 'accessing-headers'>
	| userAgentField |
	userAgentField := self headers fieldOfClass: HTTPUserAgentField
		    ifNone: [nil].
	^userAgentField isNil ifTrue: [nil] ifFalse: [userAgentField productTokens]
    ]

    wantsConnectionClose [
	<category: 'testing'>
	self isClose ifTrue: [^true].
	^self isHttp10 and: [self isKeepAlive not]
    ]
]



HTTPRequest subclass: HTTPDelete [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPDelete 

rfc26216 section 9.7

The DELETE method requests that the origin server delete the resource
   identified by the Request-URI. This method MAY be overridden by human
   intervention (or other means) on the origin server. The client cannot
   be guaranteed that the operation has been carried out, even if the
   status code returned from the origin server indicates that the action
   has been completed successfully. However, the server SHOULD NOT
   indicate success unless, at the time the response is given, it
   intends to delete the resource or move it to an inaccessible
   location.
 ...
'>

    HTTPDelete class >> methodName [
	"HTTP method used for a request"

	<category: 'accessing'>
	^'DELETE'
    ]

    isDelete [
	<category: 'testing'>
	^true
    ]
]



HTTPRequest subclass: HTTPGet [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPGet 

rfc26216 section 9.3

   The GET method means retrieve whatever information (in the form of an
   entity) is identified by the Request-URI. If the Request-URI refers
   to a data-producing process, it is the produced data which shall be
   returned as the entity in the response and not the source text of the
   process, unless that text happens to be the output of the process.
'>

    HTTPGet class >> methodName [
	<category: 'accessing'>
	^'GET'
    ]

    isGet [
	<category: 'testing'>
	^true
    ]
]



HTTPRequest subclass: HTTPHead [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPHead

rfc26216 section 9.4

   The HEAD method is identical to GET except that the server MUST NOT
   return a message-body in the response. The metainformation contained
   in the HTTP headers in response to a HEAD request SHOULD be identical
   to the information sent in response to a GET request. This method can
   be used for obtaining metainformation about the entity implied by the
   request without transferring the entity-body itself. This method is
   often used for testing hypertext links for validity, accessibility,
   and recent modification.

'>

    HTTPHead class >> methodName [
	<category: 'accessing'>
	^'HEAD'
    ]

    isHead [
	<category: 'testing'>
	^true
    ]
]



HTTPRequest subclass: HTTPOptions [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPOptions

rfc26216 section 9.2

   The OPTIONS method represents a request for information about the
   communication options available on the request/response chain
   identified by the Request-URI. This method allows the client to
   determine the options and/or requirements associated with a resource,
   or the capabilities of a server, without implying a resource action
   or initiating a resource retrieval.

'>

    HTTPOptions class >> methodName [
	<category: 'accessing'>
	^'OPTIONS'
    ]

    isOptions [
	<category: 'testing'>
	^true
    ]

    respondUsing: responseBlock [
	"^an HTTPResponse
	 I represent a request for the options supported by this server.  I respond with a 200 (OK) and a list of my supported methods in an Allow: header.  I ignore the responseBlock."

	<category: 'services'>
	| response allowField |
	response := HTTPResponse ok.
	allowField := HTTPAllowField new.
	allowField methods addAll: self class allMethodNames.
	response headers addField: allowField.
	^response
    ]
]



HTTPRequest subclass: HTTPPost [
    | postData entityBody readPosition |
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPPost 

rfc26216 section 9.5

   The POST method is used to request that the origin server accept the
   entity enclosed in the request as a new subordinate of the resource
   identified by the Request-URI in the Request-Line.

Instance Variables:
	entityBody	<>	
	postData	<HTTPPostDataArray>	

'>

    HTTPPost class >> methodName [
	<category: 'accessing'>
	^'POST'
    ]

    applicationOctetStreamFrom: aStream [
	"^self
	 rfc 2046 says:
	 The recommended action for an implementation that receives an 'application/octet-stream' entity is to simply offer to put the data in a file, with any Content-Transfer-Encoding undone, or perhaps to use it as input to a user-specified process.
	 This method used to do a crlf -> cr conversion on the octet-stream, but was not clear why."

	<category: 'private'>
	self entityBody: (HTTPString 
		    stringFromBytes: (aStream nextBytes: self contentLength)).
	^self
    ]

    blockStreamingFrom: aSwazooStream to: outStream until: boundary [
	"detected"

	"copy by 8k blocks for optimal performance until a boundary of MIME part is detected"

	"Finish appropriatelly streaming at the end (skip crlf etc.)"

	<category: 'private-parsing support'>
	| start nrOfBoundary contents inPrevious remainingBoundary boundaryIndex |
	start := self readPosition.
	[true] whileTrue: 
		[nrOfBoundary := 0.
		[nrOfBoundary = 0] whileTrue: 
			[nrOfBoundary := aSwazooStream signsOfBoundary: boundary.
			nrOfBoundary = 0 
			    ifTrue: 
				["no boundary in current buffer content"
				self incReadPosition:
					(aSwazooStream nextPutAllBufferOn: outStream).
				self checkToEnlargeBufferIn: aSwazooStream from: start.	"for effective streaming"
				aSwazooStream fillBuffer]].
		"copy and stream out content up to potential boundary"
		boundaryIndex := aSwazooStream indexOfBoundary: boundary.
		inPrevious := aSwazooStream copyBufferTo: boundaryIndex.
		outStream 
		    nextPutAll: (inPrevious copyFrom: 1 to: (inPrevious size - 2 max: 0)).	"without potential crlf"
		self incReadPosition: inPrevious size.	"potential crlf included!!"
		nrOfBoundary = boundary size 
		    ifTrue: 
			["full boundary detected, lets finish here"

			aSwazooStream skip: boundary size.	"skip boundary"
			self incReadPosition: boundary size.
			^true].	"streaming complete"
		self incReadPosition: nrOfBoundary.
		aSwazooStream fillBuffer.	"let's get next buffer"
		remainingBoundary := boundary copyFrom: nrOfBoundary + 1 to: boundary size.
		(aSwazooStream startsWith: remainingBoundary) 
		    ifTrue: 
			["bound. ends in next buff?"

			aSwazooStream skip: remainingBoundary size + 2.	"skip remaining bound. and crlf"
			self incReadPosition: remainingBoundary size + 2.
			^true].	"streaming complete"
		outStream
		    nextPutAll: (inPrevious copyFrom: inPrevious size - 2 to: inPrevious size);
		    nextPutAll: (boundary copyFrom: 1 to: nrOfBoundary)	"potential crlf"	"boundary part in prev.buff."]	"continue from the start"
    ]

    checkToEnlargeBufferIn: aSwazooStream from: startPosition [
	"enlarge buffer to 1MB (if not already) if more than 100KB already read"

	<category: 'private-parsing support'>
	aSwazooStream readBuffer size > 100000 ifTrue: [^nil].
	self readPosition - startPosition > 100000 
	    ifTrue: [aSwazooStream enlargeReadBuffer: 1000000]
    ]

    containsHeaderNecessaryFields [
	"content type and (content length or chunked transfer encoding)"

	<category: 'private-parsing support'>
	(self headers includesFieldOfClass: ContentTypeField) ifFalse: [^false].
	(self headers includesFieldOfClass: HTTPContentLengthField) 
	    ifTrue: [^true].
	^(self headers fieldNamed: 'Transfer-encoding' ifNone: [^false]) value 
	    = 'chunked'
    ]

    emptyData [
	<category: 'accessing'>
	self ensureFullRead.
	^self postData select: [:each | each value isEmpty]
    ]

    ensureFullRead [
	"that is, everything is read from a socket stream. Important because of defered parsing
	 of postData"

	<category: 'parsing'>
	self postData isParsed 
	    ifFalse: 
		[self parsePostDataFrom: self postData stream.
		self postData setParsed]
    ]

    entityBody [
	<category: 'accessing'>
	^entityBody
    ]

    entityBody: aString [
	<category: 'private'>
	entityBody := aString
    ]

    readFrom: aSwazooStream [
	<category: 'parsing'>
	self initPostDataFor: aSwazooStream
	"self parsePostDataFrom: aSwazooStream."	"defered until first access of postData!!"
    ]

    incReadPosition [
	<category: 'private'>
	self readPosition: self readPosition + 1
    ]

    incReadPosition: anInteger [
	<category: 'private'>
	self readPosition: self readPosition + anInteger
    ]

    initPostDataFor: aSwazooStream [
	<category: 'initialize-release'>
	postData := HTTPPostDataArray newOn: aSwazooStream
    ]

    isPost [
	<category: 'testing'>
	^true
    ]

    isPostDataEmpty [
	<category: 'testing'>
	self ensureFullRead.
	^self postData isEmpty
    ]

    isPostDataStreamedAt: aKey [
	<category: 'testing'>
	^(self postData at: aKey ifAbsent: [^false]) isStreamed
    ]

    multipartDataFrom: aSwazooStream [
	"read all mime parts and put them in postData"

	"read directly from stream, without intermediate buffers"

	<category: 'private-parsing'>
	| contentTypeField boundary part |
	contentTypeField := self headers fieldOfClass: ContentTypeField
		    ifNone: [^aSwazooStream nextBytes: self contentLength].	"just skip"
	boundary := contentTypeField transferCodings at: 'boundary'
		    ifAbsent: [^aSwazooStream nextBytes: self contentLength].	"just skip"
	self skipMimePreambleAndBoundary: boundary from: aSwazooStream.
	part := #something.
	[part notNil] whileTrue: 
		[part := self partFromStream: aSwazooStream boundary: boundary.
		part notNil ifTrue: [self postDataAt: part key put: part value]].
	self skipMimeEpilogueFrom: aSwazooStream.	"all to the end  as defined by contentLegth"
	aSwazooStream nilReadBuffer.
    ]

    parsePostDataFrom: aSwazooStream [
	<category: 'parsing'>
	| mediaType |
	self containsHeaderNecessaryFields 
	    ifFalse: 
		[^SwazooHTTPPostError 
		    raiseSignal: 'Content-Type and Content-Length or chunked needed'].
	mediaType := (self headers fieldOfClass: ContentTypeField) mediaType.
	mediaType = 'application/x-www-form-urlencoded' 
	    ifTrue: [^self urlencodedDataFrom: aSwazooStream].
	mediaType = 'multipart/form-data' 
	    ifTrue: [^self multipartDataFrom: aSwazooStream].
	^self applicationOctetStreamFrom: aSwazooStream
    ]

    partFromStream: aSwazooStream boundary: aBoundaryBytes [
	"one mime part from a stream. Nil if no more multipart data"

	"Squeak specific"

	<category: 'private-parsing'>
	| bytes name filename datum contentType |
	bytes := aSwazooStream nextBytes: 2.
	self incReadPosition: 2.
	bytes = '--' asByteArray ifTrue: [^nil].	"end of multipart data"
	name := nil.
	datum := nil.
	contentType := nil.	"just to avoid compilation warning"
	[true] whileTrue: 
		["read all lines and at the end a body of that part"

		| line |
		line := 
			[(aSwazooStream upTo: Character cr asInteger) asString	"Squeak specific"] 
				on: Error
				do: [:ex | ''].	"usually nothing to read anymore), why happen this anyway?"
		self readPosition: self readPosition + line size + 1.	"cr"
		line := bytes asString , line.
		bytes := ''.
		aSwazooStream peekByte = Character lf asInteger 
		    ifTrue: 
			["this is a name line"

			| field |
			aSwazooStream nextByte.
			self incReadPosition.	"skip linefeed"
			line isEmpty 
			    ifTrue: 
				["empty line indicates start of entity"

				name isNil ifTrue: [^nil].	"name must be read in previous circle"
				datum contentType: contentType.	"completes datum's contentType read in a prev step"
				^name -> (self 
					    readEntityFrom: aSwazooStream
					    datum: datum
					    boundary: aBoundaryBytes)].
			field := HeaderField fromLine: line.
			field isContentDisposition 
			    ifTrue: 
				[name := (field parameterAt: 'name') copyWithout: $".
				datum := (self isPostDataStreamedAt: name) 
					    ifTrue: [self postData at: name	"streamed datum must exist before"]
					    ifFalse: [HTTPPostDatum new].
				contentType notNil ifTrue: [datum contentType: contentType].	"if read in prev.circle"
				filename := field parameterAt: 'filename'.	"only for file uploads"
				filename notNil ifTrue: [datum filename: (filename copyWithout: $")]].
			field isContentType ifTrue: [contentType := field mediaType]]]
    ]

    postData [
	<category: 'private'>
	^postData
    ]

    postDataAt: aKey [
	<category: 'accessing'>
	^self postDataAt: aKey ifAbsent: [nil]
    ]

    postDataAt: aKey beforeStreamingDo: aBlockClosure [
	"announce that you want to receive post data directly to a binary stream, which will be set
	 by aBlockClosure. That block must receive and argument, which is a HTTPostDatum and
	 here it can set a writeStream"

	"Fails if post data is already read"

	<category: 'accessing'>
	self postData isParsed 
	    ifTrue: 
		[^self error: 'HTTPost already parsed, streaming not possible anymore!'].
	^self postDataAt: aKey put: (HTTPPostDatum new writeBlock: aBlockClosure)
    ]

    postDataAt: aKey do: aBlock [
	<category: 'accessing'>
	| val |
	self ensureFullRead.	"defered parsing of postData"
	val := self postData at: aKey ifAbsent: [nil].
	val isNil ifFalse: [aBlock value: val]
    ]

    postDataAt: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	self ensureFullRead.	"defered parsing of postData"
	^self postData at: aKey ifAbsent: aBlock
    ]

    postDataAt: aKey put: aPostDatum [
	"for testing purposes"

	<category: 'accessing'>
	self postData at: aKey put: aPostDatum
    ]

    postDataAt: aKey putString: aString [
	"for testing purposes"

	<category: 'accessing'>
	self postDataAt: aKey put: (HTTPPostDatum new value: aString)
    ]

    postDataAt: aKey streamTo: aWriteStream [
	"announce that you want to receive post data directly to aWriteStream,
	 which must be binary. Fails if post data is already read"

	<category: 'accessing'>
	self postData isParsed 
	    ifTrue: 
		[^self error: 'HTTPost already parsed, streaming not possible anymore!'].
	^self postDataAt: aKey put: (HTTPPostDatum new writeStream: aWriteStream)
    ]

    postDataKeys [
	<category: 'accessing'>
	self ensureFullRead.	"defered parsing of postData"
	^self postData keys
    ]

    postDataStringAt: aKey [
	<category: 'accessing'>
	^(self postDataAt: aKey ifAbsent: [^nil]) value
    ]

    postKeysAndValuesDo: aTwoArgBlock [
	<category: 'accessing'>
	self ensureFullRead.	"defered parsing of postData"
	self postData 
	    keysAndValuesDo: [:key :each | aTwoArgBlock value: key value: each value]
    ]

    readEntityFrom: aSwazooStream datum: aDatum boundary: aBoundaryBytes [
	"read one entity from a stream and put into datum. Stream it if streamed. Also call a block
	 (if any) just before start of streaming, with a datum as parameter. This block can then set
	 a write stream in datum (for instance open a output file and stream on it)"

	<category: 'private-parsing'>
	| outStream |
	aDatum writeBlock notNil ifTrue: [aDatum writeBlock value: aDatum].	"this should set writeStream if not already!!"
	outStream := (aDatum isStreamed and: [aDatum writeStream notNil]) 
		    ifTrue: [aDatum writeStream]
		    ifFalse: [WriteStream on: ByteArray new].
	self 
	    blockStreamingFrom: aSwazooStream
	    to: outStream
	    until: '--' , aBoundaryBytes.	"efficient streaming"
	aDatum isStreamed not 
	    ifTrue: 
		["otherwise entity is already streamed to the output"

		aDatum value: outStream contents asString].
	^aDatum
    ]

    readPosition [
	"position in a read stream. just temporary"

	<category: 'private'>
	readPosition isNil ifTrue: [^1].
	^readPosition
    ]

    readPosition: aNumber [
	<category: 'private'>
	readPosition := aNumber
    ]

    skipMimeEpilogueFrom: aSwazooStream [
	"skip a mime epilogue until end of post data defined by contentLength"

	"example:
	 --boundary--
	 This is the epilogue.  It is also to be ignored
	 "

	<category: 'private-parsing support'>
	[self readPosition < self contentLength] whileTrue: 
		[aSwazooStream next.	"just skip"
		self incReadPosition]
    ]

    skipMimePreambleAndBoundary: aBoundaryBytes from: aSwazooStream [
	"skip a mime preamble until first boundary starts then skip that boundary too"

	"example:
	 Content-type: multipart/mixed; boundary=''boundary''
	 
	 This is the preamble.  It is to be ignored, though it is
	 a handy place to include an explanatory note to non-MIME compliant readers.
	 --boundary
	 ..."

	<category: 'private-parsing support'>
	| dummy |
	dummy := WriteStream on: ByteArray new.
	self 
	    blockStreamingFrom: aSwazooStream
	    to: dummy
	    until: '--' , aBoundaryBytes
    ]

    urlencodedDataFrom: aStream [
	<category: 'private-parsing'>
	| entity tokens |
	(self headers includesFieldOfClass: HTTPContentLengthField) 
	    ifFalse: [^self].
	entity := aStream nextBytes: self contentLength.
	tokens := HTTPString 
		    subCollectionsFrom: (HTTPString stringFromBytes: entity)
		    delimitedBy: $&.
	(tokens 
	    collect: [:each | HTTPString subCollectionsFrom: each delimitedBy: $=]) 
		do: 
		    [:keyVal | 
		    | datum key |
		    datum := HTTPPostDatum new.
		    datum 
			value: (HTTPString decodedHTTPFrom: (keyVal last 
					collect: [:char | char = $+ ifTrue: [Character space] ifFalse: [char]])).
		    key := HTTPString decodedHTTPFrom: (keyVal first 
					collect: [:char | char = $+ ifTrue: [Character space] ifFalse: [char]]).
		    self postDataAt: key put: datum]
    ]
]



HTTPRequest subclass: HTTPPut [
    | putData |
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPPut 

rfc26216 section 9.6

   The PUT method requests that the enclosed entity be stored under the
   supplied Request-URI. If the Request-URI refers to an already
   existing resource, the enclosed entity SHOULD be considered as a
   modified version of the one residing on the origin server. If the
   Request-URI does not point to an existing resource, and that URI is
   capable of being defined as a new resource by the requesting user
   agent, the origin server can create the resource with that URI. If a
   new resource is created, the origin server MUST inform the user agent
   via the 201 (Created) response. If an existing resource is modified,
   either the 200 (OK) or 204 (No Content) response codes SHOULD be sent
   to indicate successful completion of the request. If the resource
   could not be created or modified with the Request-URI, an appropriate
   error response SHOULD be given that reflects the nature of the
   problem. The recipient of the entity MUST NOT ignore any Content-*
   (e.g. Content-Range) headers that it does not understand or implement
   and MUST return a 501 (Not Implemented) response in such cases.

Instance Variables:
	putData	<>	

'>

    HTTPPut class >> methodName [
	<category: 'accessing'>
	^'PUT'
    ]

    isPut [
	<category: 'testing'>
	^true
    ]

    octetDataFrom: aStream [
	<category: 'reading'>
	self headers fieldOfClass: HTTPContentLengthField
	    ifNone: [^SwazooHTTPPutError raiseSignal: 'Missing Content-Length'].
	self putData: (aStream nextBytes: self contentLength)
    ]

    putData [
	<category: 'accessing'>
	^putData
    ]

    putData: aString [
	<category: 'private'>
	putData := aString
    ]

    readFrom: aStream [
	<category: 'reading'>
	| contentTypeField |
	contentTypeField := self headers fieldOfClass: ContentTypeField
		    ifNone: [SwazooHTTPPutError raiseSignal: 'Missing Content-Type'].
	contentTypeField mediaType = 'application/octet-stream' 
	    ifTrue: [self octetDataFrom: aStream]
	    ifFalse: [self urlencodedDataFrom: aStream].
	^self
    ]
]



HTTPRequest subclass: HTTPTrace [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPTrace 

rfc26216 section 9.8

   The TRACE method is used to invoke a remote, application-layer loop-
   back of the request message. The final recipient of the request
   SHOULD reflect the message received back to the client as the
   entity-body of a 200 (OK) response
'>

    HTTPTrace class >> methodName [
	<category: 'accessing'>
	^'TRACE'
    ]

    isTrace [
	<category: 'testing'>
	^true
    ]
]



HTTPMessage subclass: HTTPResponse [
    | code entity |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    StatusCodes := nil.

    HTTPResponse class >> badRequest [
	<category: 'response types'>
	^super new code: 400
    ]

    HTTPResponse class >> forbidden [
	<category: 'response types'>
	^(super new)
	    code: 403;
	    entity: '<HTML>
<HEAD><TITLE>Forbidden</TITLE></HEAD>
<BODY>
<H1>403 Forbidden</H1>
<P>Access to the requested resource is forbidden.</P>
</BODY></HTML>'
    ]

    HTTPResponse class >> found [
	<category: 'response types'>
	^super new code: 302
    ]

    HTTPResponse class >> initialize [
	"self initialize"

	<category: 'class initialization'>
	StatusCodes := (Dictionary new)
		    add: 100 -> 'Continue';
		    add: 101 -> 'Switching Protocols';
		    add: 200 -> 'OK';
		    add: 201 -> 'Created';
		    add: 202 -> 'Accepted';
		    add: 203 -> 'Non-Authoritative Information';
		    add: 204 -> 'No Content';
		    add: 205 -> 'Reset Content';
		    add: 206 -> 'Partial Content';
		    add: 300 -> 'Multiple Choices';
		    add: 301 -> 'Moved Permanently';
		    add: 302 -> 'Found';
		    add: 303 -> 'See Other';
		    add: 304 -> 'Not Modified';
		    add: 305 -> 'Use Proxy';
		    add: 307 -> 'Temporary Redirect';
		    add: 400 -> 'Bad Request';
		    add: 401 -> 'Unauthorized';
		    add: 402 -> 'Payment Required';
		    add: 403 -> 'Forbidden';
		    add: 404 -> 'Not Found';
		    add: 405 -> 'Method Not Allowed';
		    add: 406 -> 'Not Acceptable';
		    add: 407 -> 'Proxy Authentication Required';
		    add: 408 -> 'Request Time-out';
		    add: 409 -> 'Conflict';
		    add: 410 -> 'Gone';
		    add: 411 -> 'Length Required';
		    add: 412 -> 'Precondition Failed';
		    add: 413 -> 'Request Entity Too Large';
		    add: 414 -> 'Request-URI Too Large';
		    add: 415 -> 'Unsupported Media Type';
		    add: 416 -> 'Requested range not satisfiable';
		    add: 417 -> 'Expectation Failed';
		    add: 500 -> 'Internal Server Error';
		    add: 501 -> 'Not Implemented';
		    add: 502 -> 'Bad Gateway';
		    add: 503 -> 'Service Unavailable';
		    add: 504 -> 'Gateway Time-out';
		    add: 505 -> 'HTTP Version not supported';
		    yourself.
	self postInitialize
    ]

    HTTPResponse class >> internalServerError [
	<category: 'response types'>
	^(super new)
	    code: 500;
	    entity: '<HTML>
<HEAD><TITLE>Not Found</TITLE></HEAD>
<BODY>
<H1>500 Internal Server Error</H1>
<P>The server experienced an error while processing this request.  If this problem persists, please contact the webmaster.</P>
</BODY></HTML>'
    ]

    HTTPResponse class >> methodNotAllowed [
	"c.f. RFC 2616  10.4.6
	 The method specified in the Request-Line is not allowed for the
	 resource identified by the Request-URI. The response MUST include an
	 Allow header containing a list of valid methods for the requested
	 resource."

	<category: 'response types'>
	^super new code: 405
    ]

    HTTPResponse class >> movedPermanently [
	<category: 'response types'>
	^super new code: 301
    ]

    HTTPResponse class >> notFound [
	<category: 'response types'>
	^(super new)
	    code: 404;
	    entity: '<HTML>
<HEAD><TITLE>Not Found</TITLE></HEAD>
<BODY>
<H1>404 Not Found</H1>
<P>The requested resource was not found on this server.</P>
</BODY></HTML>'
    ]

    HTTPResponse class >> notImplemented [
	<category: 'response types'>
	^super new code: 501
    ]

    HTTPResponse class >> notModified [
	<category: 'response types'>
	^super new code: 304
    ]

    HTTPResponse class >> ok [
	<category: 'response types'>
	^super new code: 200
    ]

    HTTPResponse class >> postInitialize [
	"extend it with your own codes"

	<category: 'class initialization'>
	
    ]

    HTTPResponse class >> redirectLink [
	"^an HTTPResponse
	 Note that 302 is really the 'found' response.  This code should really be 303 (>>seeOther).  However, because many clients take 302 & 303 to be the same and because older clients don't understand 303, 302 is commonly used in this case.  See RFC 2616 10.3.4."

	<category: 'response types'>
	^super new code: 302
    ]

    HTTPResponse class >> seeOther [
	"^an HTTPResponse
	 The response to the request can be found under a different URI and SHOULD be retrieved using a GET method on that resource. This method exists primarily to allow the output of a POST-activated script to redirect the user agent to a selected resource.
	 See RFC 2616 10.3.4."

	<category: 'response types'>
	^super new code: 303
    ]

    HTTPResponse class >> statusTextForCode: aNumber [
	<category: 'accessing'>
	^StatusCodes at: aNumber ifAbsent: [
	    "if some new status codes was added later"
	    self class initialize.
	    StatusCodes at: aNumber ifAbsent: ['']]
    ]

    HTTPResponse class >> unauthorized [
	<category: 'response types'>
	^super new code: 401
    ]

    addDateHeader [
	"^self
	 Note that the server must have it's clock set to GMT"

	<category: 'initialize-release'>
	self headers addField: (HTTPDateField new date: SpTimestamp now).
	^self
    ]

    addDefaultBody [
	<category: 'initialize-release'>
	self 
	    entity: '<HTML>
<HEAD><TITLE>' 
		    , (StatusCodes at: self code ifAbsent: [self code printString]) 
			, '</TITLE></HEAD>
  <BODY>
   <H2>' , self code printString 
		    , ' ' , (StatusCodes at: self code ifAbsent: [self code printString]) 
		    , '</H2>
   <P>The server experienced an error while processing this request. <BR>
   If this problem persists, please contact the webmaster.</P>
  <P>Swazoo Smalltalk Web Server</P>
  </BODY>
</HTML>'
    ]

    addHeaderName: aNameString value: aValueString [
	<category: 'accessing-headers'>
	^self headers addField: (GenericHeaderField newForFieldName: aNameString
		    withValueFrom: aValueString)
    ]

    addInitialHeaders [
	<category: 'initialize-release'>
	self addServerHeader.
	self addDateHeader
    ]

    addServerHeader [
	<category: 'initialize-release'>
	^self headers 
	    addField: (HTTPServerField new productTokens: SwazooServer swazooVersion)
    ]

    cacheControl: aString [
	"example: 'no-store, no-cache, must-revalidate'"

	<category: 'accessing-headers'>
	self headers addField: (HTTPCacheControlField new directives: aString)
    ]

    code [
	<category: 'accessing'>
	^code
    ]

    code: anInteger [
	<category: 'initialize-release'>
	code := anInteger.
	(#(200) includes: code) ifFalse: [self addDefaultBody]
    ]

    codeText [
	<category: 'accessing'>
	^self class statusTextForCode: self code
    ]

    contentLength [
	^self headers
	    fieldNamed: 'Content-length'
	    ifNone: [
		| field |
		field := HTTPContentLengthField new contentLength: self contentSize.
		self headers addField: field.
		field ]
    ]

    contentSize [
	<category: 'accessing'>
	^self entity notNil ifTrue: [self entity size] ifFalse: [0]
    ]

    contentType [
	"^a String
	 Return the media type from my Content-Type header field."

	<category: 'accessing-headers'>
	^self headers 
	    fieldOfClass: ContentTypeField
	    ifPresent: [:field | field mediaType]
	    ifAbsent: ['application/octet-stream']
    ]

    contentType: aString [
	<category: 'accessing-headers'>
	self headers addField: (ContentTypeField new mediaType: aString).
	^self
    ]

    cookie: aString [
	<category: 'accessing-headers'>
	| newField |
	newField := HTTPSetCookieField new.
	newField addCookie: aString.
	self headers addField: newField.
	^self
    ]

    entity [
	<category: 'accessing'>
	^entity
    ]

    entity: anEntity [
	<category: 'accessing'>
	entity := anEntity asByteArray	"if not already"
    ]

    printEntityOn: aStream [
	<category: 'sending'>
	self entity isNil ifFalse: [aStream nextPutBytes: self entity]
    ]

    expires: aSpTimestamp [
	"from SPort"

	<category: 'accessing-headers'>
	self headers addField: (HTTPExpiresField new timestamp: aSpTimestamp).
	^self
    ]

    informConnectionClose [
	<category: 'private'>
	self headers 
	    fieldOfClass: HTTPConnectionField
	    ifPresent: [:field | field setToClose]
	    ifAbsent: [self headers addField: HTTPConnectionField new setToClose].
	^self
    ]

    informConnectionKeepAlive [
	<category: 'private'>
	self headers 
	    fieldOfClass: HTTPConnectionField
	    ifPresent: [:field | field setToKeepAlive]
	    ifAbsent: [self headers addField: HTTPConnectionField new setToKeepAlive].
	^self
    ]

    isBadRequest [
	<category: 'testing'>
	^self code = 400
    ]

    isFound [
	<category: 'testing'>
	^self code = 302
    ]

    isHttp10 [
	"we are responding by old HTTP/1.0 protocol"

	<category: 'testing'>
	^self task request isHttp10
    ]

    isHttp11 [
	"we are responding by HTTP/1.1 protocol"

	<category: 'testing'>
	^self task request isHttp11
    ]

    isInternalServerError [
	<category: 'testing'>
	^self code = 500
    ]

    isMovedPermanently [
	<category: 'testing'>
	^self code = 301
    ]

    isNotFound [
	<category: 'testing'>
	^self code = 404
    ]

    isNotImplemented [
	<category: 'testing'>
	^self code = 501
    ]

    isNotModified [
	<category: 'testing'>
	^self code = 304
    ]

    isOk [
	<category: 'testing'>
	^self code = 200
    ]

    isRedirectLink [
	<category: 'testing'>
	^self code = 302
    ]

    isSeeOther [
	<category: 'testing'>
	^self code = 303
    ]

    isStreamed [
	<category: 'testing'>
	^false
    ]

    isUnauthorized [
	<category: 'testing'>
	^self code = 401
    ]

    lastModified: aSpTimestamp [
	"from SPort"

	<category: 'accessing-headers'>
	self headers addField: (HTTPLastModifiedField new timestamp: aSpTimestamp).
	^self
    ]

    location: aString [
	<category: 'accessing-headers'>
	self headers addField: (HTTPLocationField new uriString: aString).
	^self
    ]
]


HTTPResponse subclass: FileResponse [
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    contentType [
	<category: 'accessing-headers'>
	^self entity contentType
    ]

    entity: aMimeObject [
	<category: 'accessing'>
	entity := aMimeObject.
	self contentType: self entity contentType.
    ]

    contentSize [
	<category: 'private-printing'>
	^self entity notNil ifTrue: [self entity value fileSize] ifFalse: [0]
    ]

    printEntityOn: aStream [
	<category: 'private-printing'>
	| rs |
	self entity isNil 
	    ifFalse: 
		[rs := self entity value readStream.
		rs lineEndTransparent.
		SpExceptionContext 
		    for: 
			[[[rs atEnd] whileFalse: [aStream nextPutAll: (rs nextAvailable: 2000)]] 
			    ensure: [rs close]]
		    on: SpError
		    do: [:ex | ex return]]
    ]
]



HTTPResponse subclass: HTTPStreamedResponse [
    | stream count length state semaphore |
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPStreamedResponse 

HTTP/1.1 	no length   	chunked
HTTP/1.1	length		streamed directly, with contentLength
HTTP/1.0	no length   	simulated streaming: into entity first, then sent as normal response (not yet impl.)
HTTP/1.0  	length 		streamed directly, with content length

Instance Variables:
	stream		<SwazooStream> where to stream a response
	count		<Integer> 		how many bytes already streamed
	length		<Integer>		announced length of response, optional
	state		<Symbol>		#header #streaming #closed			
	semaphore	<Semaphore>	to signal end of response

'>

    HTTPStreamedResponse class >> on: aSwazooTask stream: aSwazooStream [
	<category: 'instance creation'>
	^(super ok)
	    task: aSwazooTask;
	    stream: aSwazooStream;
	    initialize
    ]

    close [
	"mandatory!! It signals that streaming is finished and response can end"

	<category: 'initialize-release'>
	self testForUnderflow.	"if streamed but not chunked: all data sent?"
	self stream closeResponse.
	self setClosed.
	self stream: nil.	"to avoid unintential writing"
	self semaphore signal	"to signal close to all waiting processes"
    ]

    contentSize [
	<category: 'accessing'>
	self length notNil ifTrue: [^self length].
	self entity notNil ifTrue: [self entity size].
	^nil
    ]

    count [
	"how many bytes already streamed"

	<category: 'accessing'>
	count isNil ifTrue: [self count: 0].
	^count
    ]

    count: aNumber [
	<category: 'private'>
	count := aNumber
    ]

    flush [
	"force sending to a TCP socket"

	<category: 'accessing-stream'>
	self stream flush
    ]

    initSemaphore [
	<category: 'initialize-release'>
	semaphore := Semaphore new
    ]

    initialize [
	<category: 'initialize-release'>
	self setHeader
    ]

    isClosed [
	"is response closed?. No streaming or anything else possible anymore"

	<category: 'private-state'>
	^state = #closed
    ]

    isHeader [
	"is response in header state?. this is initial one"

	<category: 'private-state'>
	^state = #header
    ]

    isStreamed [
	<category: 'testing'>
	^true
    ]

    isStreaming [
	"is response in streaming state? All nextPut to stream is sent in chunked format to browser"

	<category: 'private-state'>
	^state = #streaming
    ]

    length [
	"how many bytes response is expected to have.
	 This is optional, if set before streaming begin, then we stream without chunking (and
	 therefore we can stream on HTTP 1.0 !!)"

	<category: 'accessing'>
	^length
    ]

    length: aNumber [
	<category: 'accessing'>
	length := aNumber
    ]

    nextPut: aCharacterOrByte [
	<category: 'accessing-stream'>
	self isHeader ifTrue: [self sendHeaderAndStartStreaming].
	self count: self count + 1.
	self testForOverflow.
	^self stream nextPut: aCharacterOrByte
    ]

    nextPutAll: aByteStringOrArray [
	<category: 'accessing-stream'>
	self isHeader ifTrue: [self sendHeaderAndStartStreaming].
	self count: self count + aByteStringOrArray size.
	self testForOverflow.
	^self stream nextPutAll: aByteStringOrArray
    ]

    semaphore [
	"semahore to signal end of streaming = all data sent"

	<category: 'private'>
	semaphore isNil ifTrue: [self initSemaphore].
	^semaphore
    ]

    sendHeaderAndStartStreaming [
	<category: 'private'>
	self shouldSimulateStreaming 
	    ifTrue: [self error: 'simulated streaming not yet implemented!'].
	self writeHeaderTo: self stream.
	self stream flush.	"to push sending of header immediately"
	self shouldBeChunked ifTrue: [self stream setChunked].
	self setStreaming
    ]

    setClosed [
	"response is closed. No streaming or anything else possible anymore"

	<category: 'private-state'>
	state := #closed
    ]

    setHeader [
	"response in header state. this is initial one"

	<category: 'private-state'>
	state := #header
    ]

    setStreaming [
	"response in streaming state. All nextPut to stream is sent in chunked format to browser"

	<category: 'private-state'>
	state := #streaming
    ]

    shouldBeChunked [
	<category: 'testing'>
	^self isHttp11 and: [self length isNil]
    ]

    shouldSimulateStreaming [
	"stream to entity first then send all at once (because only now we
	 know the length of response)"

	<category: 'testing'>
	^self isHttp10 and: [self length isNil]
    ]

    stream [
	<category: 'private'>
	^stream
    ]

    stream: aSwazooStream [
	<category: 'private'>
	stream := aSwazooStream
    ]

    testForOverflow [
	"if streaming but not chunking, then count must never be larger than announced length"

	<category: 'private'>
	(self length notNil and: [self count > self length]) 
	    ifTrue: [self error: 'streaming overflow']
    ]

    testForUnderflow [
	"if streaming but not chunking, then count must be exactly the announced
	 length at the end"

	<category: 'private'>
	(self length notNil and: [self count ~= self length]) 
	    ifTrue: [self error: 'not enough data streamed ']
    ]

    waitClose [
	"wait until all data is sent-streamed out and response is closed"

	<category: 'waiting'>
	^self semaphore wait
    ]
]



Object subclass: HTTPPostDataArray [
    | underlyingCollection stream parsed |
    
    <category: 'Swazoo-Messages'>
    <comment: 'Introduced the HTTPPostDataArray to hold post data in an HTTPRequest in place of a Dictionary.  This is because it is legal for there to be more than one entry with the same name (key) and using a Dictionary  looses data (!).

Instance Variables:
	underlyingCollection	<>	

'>

    HTTPPostDataArray class >> newOn: aSwazooStream [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    stream: aSwazooStream
    ]

    allAt: aKey [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation key = aKey].
	^candidates collect: [:anAssociation | anAssociation value]
    ]

    allNamesForValue: aString [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation value value = aString].
	^candidates collect: [:anAssociation | anAssociation key]
    ]

    associations [
	<category: 'accessing'>
	^self underlyingCollection
    ]

    at: aKey [
	<category: 'accessing'>
	^(self allAt: aKey) last
    ]

    at: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation key = aKey].
	^candidates isEmpty ifTrue: [aBlock value] ifFalse: [candidates last value]
    ]

    at: key put: anObject [
	<category: 'accessing'>
	self underlyingCollection add: (Association key: key value: anObject).
	^anObject
    ]

    clearParsed [
	<category: 'accessing'>
	parsed := false
    ]

    includesKey: aKey [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation key = aKey].
	^candidates notEmpty
    ]

    includesValue: aString [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation value value = aString].
	^candidates notEmpty
    ]

    initialize [
	<category: 'initialize-release'>
	self clearParsed
    ]

    isEmpty [
	<category: 'testing'>
	^self underlyingCollection isEmpty
    ]

    isParsed [
	"postdata is already read and parsed from a request"

	<category: 'testing'>
	^parsed
    ]

    keys [
	"^a Set
	 I mimick the behavior of a Dictionay which I replace.  I return a set of the keys in my underlying collection of associations."

	<category: 'accessing'>
	^(self underlyingCollection collect: [:anAssociation | anAssociation key]) 
	    asSet
    ]

    keysAndValuesDo: aTwoArgumentBlock [
	<category: 'enumerating'>
	self underlyingCollection 
	    do: [:anAssociation | aTwoArgumentBlock value: anAssociation key value: anAssociation value]
    ]

    nameForValue: aString [
	<category: 'accessing'>
	^(self allNamesForValue: aString) last
    ]

    printOn: aStream [
	<category: 'private'>
	aStream nextPutAll: 'a Swazoo.HttpPostDataArray 
	'.
	self underlyingCollection do: 
		[:each | 
		aStream 
		    nextPutAll: each key printString , '->' , each value value printString 
			    , '
	']
    ]

    select: aBlock [
	"^an Object
	 I run the select on the values of the associations in my underlying collection.  This mimicks the behavior when a Dictionary was used in my place."

	<category: 'enumerating'>
	^self underlyingCollection 
	    select: [:anAssociation | aBlock value: anAssociation value]
    ]

    setParsed [
	<category: 'accessing'>
	parsed := true
    ]

    stream [
	<category: 'private'>
	^stream
    ]

    stream: aSwazooStream [
	"needed for defered postData parsing"

	<category: 'private'>
	stream := aSwazooStream
    ]

    underlyingCollection [
	<category: 'private'>
	underlyingCollection isNil 
	    ifTrue: [underlyingCollection := OrderedCollection new].
	^underlyingCollection
    ]
]



Object subclass: HTTPRequestLine [
    | method requestURI httpVersion |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    httpVersion [
	<category: 'accessing'>
	^httpVersion
    ]

    httpVersion: anArray [
	<category: 'private'>
	httpVersion := anArray.
	^self
    ]

    isHttp10 [
	<category: 'testing'>
	^self httpVersion last = 0
    ]

    isHttp11 [
	<category: 'testing'>
	^self httpVersion last = 1
    ]

    method [
	<category: 'accessing'>
	^method
    ]

    method: aString [
	<category: 'private'>
	method := aString.
	^self
    ]

    requestURI [
	<category: 'accessing'>
	^requestURI
    ]

    requestURI: aString [
	<category: 'private'>
	requestURI := aString.
	^self
    ]
]



Object subclass: MimeObject [
    | contentType value |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    contentType [
	<category: 'accessing'>
	^contentType isNil ifTrue: [self defaultContentType] ifFalse: [contentType]
    ]

    contentType: anObject [
	<category: 'accessing'>
	contentType := anObject
    ]

    defaultContentType [
	<category: 'private-accessing'>
	^'application/octet-stream'
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]
]



MimeObject subclass: HTTPPostDatum [
    | filename writeStream writeBlock |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    defaultContentType [
	<category: 'private-accessing'>
	^'text/plain'
    ]

    filename [
	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	<category: 'accessing'>
	filename := aString
    ]

    filenameWithoutPath [
	"M$ Internet Explorer includes full path in filename of uploaded file!!"

	<category: 'accessing'>
	self filename isNil ifTrue: [^nil].
	^(self filename includes: $\) 
	    ifTrue: 
		[self filename copyFrom: (self filename lastIndexOf: $\) + 1
		    to: self filename size]
	    ifFalse: [self filename]
    ]

    isStreamed [
	"this postDatum is streamed - it has an output stream to receive data into or a block
	 which will set it"

	<category: 'testing'>
	^self writeStream notNil or: [self writeBlock notNil]
    ]

    writeBlock [
	<category: 'accessing'>
	^writeBlock
    ]

    writeBlock: aBlockClosure [
	"this block will be called just before start of streaming to writeStream. It can be used to
	 open the writeStream, because on that time we already know the filename of uploaded file.
	 As a parameter this postDatum is sent"

	<category: 'accessing'>
	writeBlock := aBlockClosure
    ]

    writeStream [
	<category: 'accessing'>
	^writeStream
    ]

    writeStream: aWriteStream [
	"a binary stream where to put directly a post data"

	<category: 'accessing'>
	writeStream := aWriteStream
    ]
]



Object subclass: SwazooTask [
    | connection request response |
    
    <category: 'Swazoo-Messages'>
    <comment: 'A SwazooTask is simply a request-response pair.  This class just makes the task (ha!) of dealing with requests and responses a bit easier.'>

    SwazooTask class >> newOn: aHTTPConnection [
	<category: 'instance creation'>
	^super new connection: aHTTPConnection
    ]

    connection [
	<category: 'accessing'>
	^connection
    ]

    connection: aHTTPConnection [
	<category: 'accessing'>
	connection := aHTTPConnection
    ]

    request [
	<category: 'accessing'>
	^request
    ]

    request: aHTTPRequest [
	<category: 'accessing'>
	request := aHTTPRequest.
	aHTTPRequest task: self
    ]

    response [
	<category: 'accessing'>
	^response
    ]

    response: aHTTPResponse [
	<category: 'accessing'>
	response := aHTTPResponse.
	aHTTPResponse notNil ifTrue: [aHTTPResponse task: self]
    ]
]



Eval [
    HTTPResponse initialize
]
