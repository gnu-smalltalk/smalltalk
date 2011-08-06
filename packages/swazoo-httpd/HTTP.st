"======================================================================
|
|   Swazoo 2.1 HTTP handling
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


Object subclass: HTTPConnection [
    | stream loop server task |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    HTTPConnection class >> socket: aSocket [
	<category: 'instance creation'>
	^self new stream: aSocket stream
    ]

    close [
	<category: 'serving'>
	self stream notNil 
	    ifTrue: 
		[self stream close.
		stream := nil].
	self server notNil ifTrue: [self server removeConnection: self].
	self loop notNil 
	    ifTrue: 
		[self loop terminate.
		self loop: nil]
    ]

    getAndDispatchMessages [
	"^self
	 The HTTPRequest is read from my socket stream.  I then pass this request to my server
	 to get a response."

	<category: 'serving'>
	self stream anyDataReady 
	    ifTrue: 
		["wait for data and if anything read, proceed"

		self task: (SwazooTask newOn: self).
		self readRequestFor: self task.
		self produceResponseFor: self task.
		self task request wantsConnectionClose ifTrue: [self close].
		self task request isHttp10 ifTrue: [self close]	"well, we won't complicate here"]
	    ifFalse: 
		[self keepAliveTimeout ifTrue: [^self close].
		(Delay forMilliseconds: 100) wait.	"to finish sending, if any"
		self close]
    ]

    interact [
	"longer description is below method"

	<category: 'serving'>
	| interactionBlock |
	interactionBlock := 
		[
		[[[true] whileTrue: 
			[self getAndDispatchMessages.
			Processor yield]] 
			    ifCurtailed: 
			        [self close]]
		    on: Error
		    do: [:ex |
			(Delay forMilliseconds: 50) wait.	"to finish sending, if any"
			self close]].
	self server isMultiThreading 
	    ifTrue: 
		[self loop: (interactionBlock forkAt: Processor userBackgroundPriority)]
	    ifFalse: [interactionBlock value].
	^self

	"I represent a specifc connection with an HTTP client (a browser, probably) over which will come an HTTP request.  Here, I fork the handling of the request so that the current thread (which is most likely the HTTP server main loop) can carry on with the next request.  This means that more than one request may being handled in the image at a time, and that means that the application developer must worry about thread safety - e.g the problem of a given business object being updated by more than one HTTP request thread.
	 For a GemStone implementation of Swazoo, one may want only one request is handled at a time, multi-threadedness being handled by having multiple gems.  This is a nice option because the application developer does not have to worry about thread safety in this case - GemStone handles the hard stuff.
	 *And* the thing called a loop that was in this method was no such thing.  In all circumstances, >>getAndDispatchMessages handles exactly one requst and then closes the socket!! (very non-HTTP1.1).  Anyway, for now I'm just going to make that explicit.  This needs to be re-visited to support HTTP 1.1."
    ]

    isOpen [
	"not yet closed"

	<category: 'testing'>
	^self stream notNil
    ]

    keepAliveTimeout [
	<category: 'testing'>
	| seconds |
	self task isNil ifTrue: [^false].
	self task request isKeepAlive ifFalse: [^false].
	seconds := self task request keepAlive notNil 
		    ifTrue: [self task request keepAlive asInteger - 10	"to be sure"]
		    ifFalse: [20].	"probably enough?"
	^SpTimestamp now asSeconds - self task request timestamp asSeconds 
	    >= seconds
    ]

    loop [
	<category: 'private'>
	^loop
    ]

    loop: aProcess [
	<category: 'private'>
	loop := aProcess
    ]

    nextPutError: aResponse [
	<category: 'serving-responses'>
	aResponse informConnectionClose.
	self responsePrinterClass writeResponse: aResponse to: self stream.
    ]

    nextPutResponse: aMessage toRequest: aRequest [
	<category: 'serving-responses'>
	aRequest isHead 
	    ifTrue: [self responsePrinterClass writeHeadersFor: aMessage to: self stream]
	    ifFalse: [self responsePrinterClass writeResponse: aMessage to: self stream].
    ]

    produceResponseFor: aSwazooTask [
	"Given the request in aTask I try to make a response.  If there are any unhandled
	 exceptions, respond with an internal server error."

	<category: 'serving'>
	aSwazooTask request isNil ifTrue: [^nil].
	"SpExceptionContext for:
	 ["
	aSwazooTask response: (self server answerTo: aSwazooTask request).
	aSwazooTask request ensureFullRead.	"in case if defered parsing not done in HTTPost"
	aSwazooTask request wantsConnectionClose 
	    ifTrue: [aSwazooTask response informConnectionClose]
	    ifFalse: 
		[aSwazooTask request isKeepAlive 
		    ifTrue: [aSwazooTask response informConnectionKeepAlive]].
	aSwazooTask response isStreamed 
	    ifFalse: 
		["streamed ones did that by themselves"

		self nextPutResponse: aSwazooTask response toRequest: aSwazooTask request]
	    ifTrue: [aSwazooTask response waitClose].	"to be sure all is sent"
	aSwazooTask request isGet 
	    ifFalse: 
		[self close	"to avoid strange 200 bad requests
		 after two consecutive POSTs, but it is really a hack and original reason
		 must be found!!"
		"onAnyExceptionDo:
		 [:ex |
		 self halt.
		 self nextPutError: HTTPResponse internalServerError.
		 ex defaultAction."	"usually raise an UHE window"	"
		 self close]"]
    ]

    readRequestFor: aSwazooTask [
	"I read the next request from my socket and add it to aSwazooTask.  If I have any
	 problems and need to force a bad request (400) response, I add this response to aSwazooTask."

	<category: 'serving'>
	| request |
	SpExceptionContext 
	    for: 
		[request := self requestReaderClass readFrom: self stream.
		request uri port: self server port.
		(request httpVersion last = 1 
		    and: [(request headers includesFieldOfClass: HTTPHostField) not]) 
			ifTrue: [aSwazooTask response: HTTPResponse badRequest].
		[request peer: self stream socket remoteAddress] on: Error do: [:ex | ].
		request
		    ip: self stream socket localAddress hostAddressString;
		    setTimestamp.
		aSwazooTask request: request]
	    on: SpError , HTTPException
	    do: 
		[:ex | 
		aSwazooTask response: HTTPResponse badRequest.
		self nextPutError: aSwazooTask response.
		self close]
    ]

    requestReaderClass [
	<category: 'private'>
	^server requestReaderClass
    ]

    responsePrinterClass [
	<category: 'private'>
	^server responsePrinterClass
    ]

    server [
	<category: 'private'>
	^server
    ]

    server: aServer [
	<category: 'private'>
	server := aServer
    ]

    socket [
	<category: 'private'>
	^self stream socket
    ]

    stream [
	<category: 'private'>
	^stream
    ]

    stream: aSwazooStream [
	<category: 'private'>
	stream := aSwazooStream
    ]

    task [
	"request/response pair, current or last one (until next request)"

	<category: 'private'>
	^task
    ]

    task: aSwazooTask [
	"request/response pair, current or last one (until next request)"

	<category: 'private'>
	task := aSwazooTask
    ]
]



Object subclass: AbstractHTTPServer [
    | connections sites socket loop isMultiThreading |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    AbstractHTTPServer class >> initialize [
	<category: 'intialize-release'>
	SpEnvironment addImageShutdownTask: [self shutDown] for: self
    ]

    AbstractHTTPServer class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    AbstractHTTPServer class >> shutDown [
	"HTTPServer shutDown"

	<category: 'intialize-release'>
	self allInstances do: [:each | each stop].
	SpEnvironment removeShutdownActionFor: self
    ]

    acceptConnection [
	"^self
	 I accept the next inbound TCP/IP connection.  The operating system libraries queue these up for me, so I can just handle one at a time.  I create an HTTPConnection instance to actually handle the interaction with the client - if I am in single threaded mode, the connection will completely handle the request before returning control to me, but in multi-threaded mode the connection forks the work into a sepparate thread in this image and control is immediately returned to me (the application programmer must worry about thread safety in this case."

	<category: 'private'>
	| clientConnection |
	clientConnection := SpExceptionContext 
		    for: [HTTPConnection socket: self socket accept]
		    on: SpError
		    do: 
			[:ex | 
			Transcript
			    show: 'Socket accept error: ' , ex errorString;
			    cr.
			^self].
	self addConnection: clientConnection.
	clientConnection interact.
	^self
    ]

    addConnection: aConnection [
	<category: 'private'>
	self connections add: aConnection.
	aConnection server: self
    ]

    addSite: aSite [
	<category: 'sites'>
	(self sites includesResource: aSite) 
	    ifFalse: [^self sites addResource: aSite]
    ]

    answerTo: aRequest [
	<category: 'serving'>
	| response |
	response := URIResolution resolveRequest: aRequest startingAt: self sites.
	^response isNil ifTrue: [HTTPResponse notFound] ifFalse: [response]
    ]

    connections [
	<category: 'private'>
	connections isNil ifTrue: [self initConnections].
	^connections
    ]

    createSocket [
	<category: 'abstract-start/stop'>
	self subclassResponsibility.
    ]

    hasNoSites [
	<category: 'sites'>
	^self sites hasNoResources
    ]

    initConnections [
	<category: 'private-initialize'>
	connections := OrderedCollection new
    ]

    initSites [
	<category: 'private-initialize'>
	sites := ServerRootComposite new
    ]

    initialize [
	<category: 'private-initialize'>
	self initConnections.
	self initSites
    ]

    isMultiThreading [
	"^a Boolean
	 I return true if each inbound HTTP connection will be handled in its own thread.  See the senders of this message to see where that is important.  Note that the default mode is mult-threaded because this is how Swazoo has worked so far.  This is tricky for the application programmer, though, as they must ensure that they work in a thread safe way (e.g. avoid the many threads updating the same object).  For those deploying to GemStone, you wil find things much easier if you do *not* run multithreaded, but rather run many gems each with a single-threaded Swazoo instance (and your app logic) in each.  Also in GemStone, run the main loop in the foreground, c.f. >>mainLoopInForeground"

	<category: 'multithreading'>
	isMultiThreading isNil ifTrue: [self setMultiThreading].
	^isMultiThreading
    ]

    isServing [
	<category: 'testing'>
	^self loop notNil
    ]

    loop [
	<category: 'private'>
	^loop
    ]

    loop: aProcess [
	<category: 'private'>
	loop := aProcess
    ]

    removeConnection: aConnection [
	<category: 'private'>
	self connections remove: aConnection ifAbsent: [nil]
    ]

    removeSite: aSite [
	<category: 'sites'>
	^self sites removeResource: aSite
    ]

    requestReaderClass [
	<category: 'factories'>
	self subclassResponsibility
    ]

    responsePrinterClass [
	<category: 'factories'>
	self subclassResponsibility
    ]

    restart [
	"usefull after image startup, when socket is probably not valid anymore"

	<category: 'start/stop'>
	self stop.
	self start
    ]

    setMultiThreading [
	"^self
	 I record that this HTTP server is to operate in a multi-threaded mode.  c.f. isMultiThreading"

	<category: 'multithreading'>
	isMultiThreading := true.
	^self
    ]

    setSingleThreading [
	"^self
	 I record that this HTTP server is to operate in a single-threaded mode.  c.f. isMultiThreading"

	<category: 'multithreading'>
	isMultiThreading := false.
	^self
    ]

    sites [
	<category: 'private'>
	sites isNil ifTrue: [self initSites].
	^sites
    ]

    socket [
	<category: 'private'>
	^socket
    ]

    socket: aSocket [
	<category: 'private'>
	socket := aSocket
    ]

    start [
	<category: 'start/stop'>
	self loop isNil 
	    ifTrue: 
		[self socket: self createSocket.
		self loop: ([[self acceptConnection] repeat] 
			    forkAt: Processor userBackgroundPriority)]
    ]

    stop [
	<category: 'start/stop'>
	self loop isNil 
	    ifFalse: 
		[self connections copy do: [:each | each close].
		self loop terminate.
		self loop: nil.
		self socket close.
		self socket: nil]
    ]
]



AbstractHTTPServer subclass: HTTPServer [
    
    | ip port |

    <category: 'Swazoo-HTTP'>
    <comment: nil>

    createSocket [
	<category: 'private-initialize'>
	^(self socketClass serverOnIP: self ipCorrected port: self port)
		listenFor: 50;
		yourself
    ]

    ip [
	<category: 'private-initialize'>
	^ip
    ]

    ip: anIPString [
	<category: 'private-initialize'>
	ip := anIPString
    ]

    ipCorrected [
	"in case of '*' always return '0.0.0.0'"

	<category: 'private-initialize'>
	^self ip = '*' ifTrue: ['0.0.0.0'] ifFalse: [self ip]
    ]

    port [
	<category: 'private-initialize'>
	^port
    ]

    port: aNumber [
	<category: 'private-initialize'>
	port := aNumber
    ]

    requestReaderClass [
	<category: 'factories'>
	^HTTPReader
    ]

    responsePrinterClass [
	<category: 'factories'>
	^HTTPPrinter
    ]

    socketClass [
	"^a Class
	 I use SwazooSocket to wrap the actual socket.  SwazooSocket does some of the byte translation work for me."

	<category: 'private'>
	^SwazooSocket
    ]
]



Object subclass: HTTPString [
    
    <category: 'Swazoo-HTTP'>
    <comment: 'This class contains some utility methods that were previously implemented as extentions to system classes.  This is really a stop-gap until, perhaps, the SwazooStream yeilds HTTPStrings.

'>

    HTTPString class >> decodedHTTPFrom: aCharacterArray [
	"Code taken from the swazoo specific extention to the CharacterArray class"

	<category: 'decoding'>
	| targetStream sourceStream |
	targetStream := WriteStream on: aCharacterArray class new.
	sourceStream := ReadStream on: aCharacterArray.
	[sourceStream atEnd] whileFalse: 
		[| char |
		char := sourceStream next.
		char = $% 
		    ifTrue: 
			[targetStream nextPut: (Character 
				    value: (SpEnvironment integerFromString: '16r' , (sourceStream next: 2)))]
		    ifFalse: 
			[char == $+ 
			    ifTrue: [targetStream nextPut: Character space]
			    ifFalse: [targetStream nextPut: char]]].
	^targetStream contents
    ]

    HTTPString class >> encodedHTTPFrom: aCharacterArray [
	"Code taken from the swazoo specific extention to the CharacterArray class"

	<category: 'decoding'>
	| targetStream |
	targetStream := WriteStream on: aCharacterArray class new.
	aCharacterArray do: 
		[:char | 
		(self isHTTPReservedCharacter: char) 
		    ifTrue: 
			[targetStream nextPut: $%.
			targetStream nextPutAll: (char asInteger 
				    printPaddedWith: $0
				    to: 2
				    base: 16)
			"char asInteger
			 printOn: targetStream
			 paddedWith: $0
			 to: 2
			 base: 16"]
		    ifFalse: [targetStream nextPut: char]].
	^targetStream contents
    ]

    HTTPString class >> isHTTPReservedCharacter: aCharacter [
	"Code taken from the swazoo specific extention to the Character class"

	<category: 'decoding'>
	^(aCharacter isAlphaNumeric or: ['-_.!~*''()' includes: aCharacter]) not
    ]

    HTTPString class >> newRandomString: anInteger [
	<category: 'instance creation'>
	| numbersThroughAlphas targetStream char random |
	numbersThroughAlphas := (48 to: 122) 
		    collect: [:each | Character value: each].
	targetStream := WriteStream on: (String new: anInteger).
	random := Random new.
	[targetStream contents size < anInteger] whileTrue: 
		[char := numbersThroughAlphas 
			    at: (random next * (numbersThroughAlphas size - 1)) rounded + 1.
		char isAlphaNumeric ifTrue: [targetStream nextPut: char]].
	^targetStream contents
    ]

    HTTPString class >> stringFromBytes: aByteArray [
	"^a String
	 In GemStone ['Hello, World' asByteArray asString] returns the string 'aByteArray' !!
	 This is the boring long way of getting a string from a ByteArray - but it does work
	 in GemStone."

	"HTTPString stringFromBytes: ('Hello, World' asByteArray)"

	<category: 'decoding'>
	| targetStream |
	targetStream := WriteStream on: String new.
	aByteArray do: [:aByte | targetStream nextPut: (Character value: aByte)].
	^targetStream contents
    ]

    HTTPString class >> subCollectionsFrom: aCollection delimitedBy: anObject [
	"^an OrderedCollection
	 I return the ordered collection of sub-collections from aCollection, delimited
	 by anObject."

	"HTTPString subCollectionsFrom: 'aaa/bbb/' delimitedBy: $/"

	<category: 'tokens'>
	| subCollections sourceStream |
	subCollections := OrderedCollection new.
	sourceStream := ReadStream on: aCollection.
	[sourceStream atEnd] 
	    whileFalse: [subCollections add: (sourceStream upTo: anObject)].
	(aCollection isEmpty 
	    or: [(sourceStream
		    skip: -1;
		    next) == anObject]) 
		ifTrue: [subCollections add: aCollection class new].
	^subCollections
    ]

    HTTPString class >> trimBlanksFrom: aString [
	"^a String
	 I return a copy of aString with all leading and trailing blanks removed."

	<category: 'decoding'>
	| first last |
	first := 1.
	last := aString size.
	[last > 0 and: [(aString at: last) isSeparator]] 
	    whileTrue: [last := last - 1].
	^last == 0 
	    ifTrue: [String new]
	    ifFalse: 
		[[first < last and: [(aString at: first) isSeparator]] 
		    whileTrue: [first := first + 1].
		aString copyFrom: first to: last]
    ]
]



CompositeResource subclass: ServerRootComposite [
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    helpResolve: aResolution [
	<category: 'accessing'>
	^aResolution resolveServerRoot: self
    ]
]



Object subclass: AbstractSwazooSocket [
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    accept [
	<category: 'server accessing'>
	self subclassResponsibility
    ]

    close [
	<category: 'accessing'>
	self subclassRespnsibility
    ]

    isActive [
	<category: 'testing'>
	self subclassResponsibility
    ]

    listenFor: anInteger [
	<category: 'server accessing'>
	self subclassResponsibility
    ]

    localAddress [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    read: anInteger [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    readInto: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    remoteAddress [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    stream [
	<category: 'private'>
	self subclassResponsibility
    ]

    write: aByteArray [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    writeFrom: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]



AbstractSwazooSocket subclass: SwazooSocket [
    | accessor |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SwazooSocket class >> accessor: aSocketAccessor [
	<category: 'private'>
	^self new accessor: aSocketAccessor
    ]

    SwazooSocket class >> connectTo: aHostString port: anInteger [
	<category: 'instance creation'>
	| newSocket |
	newSocket := SpSocket newTCPSocket.
	newSocket connectTo: (SpIPAddress hostName: aHostString port: anInteger).
	^self accessor: newSocket
    ]

    SwazooSocket class >> connectedPair [
	<category: 'instance creation'>
	^SpSocket newSocketPair collect: [:each | self accessor: each]
    ]

    SwazooSocket class >> serverOnIP: anIPString port: anInteger [
	<category: 'instance creation'>
	| newSocket |
	newSocket := SpSocket newTCPSocket.
	newSocket
	    setAddressReuse: true;
	    bindSocketAddress: (SpIPAddress hostName: anIPString port: anInteger).
	^self accessor: newSocket
    ]

    accept [
	<category: 'server accessing'>
	^self class accessor: self accessor acceptRetryingIfTransientErrors
    ]

    accessor [
	<category: 'private'>
	^accessor
    ]

    accessor: aSocketAccessor [
	<category: 'private'>
	accessor := aSocketAccessor
    ]

    close [
	<category: 'accessing'>
	self accessor close
    ]

    isActive [
	<category: 'testing'>
	^self accessor isActive
    ]

    listenFor: anInteger [
	<category: 'server accessing'>
	self accessor listenBackloggingUpTo: anInteger
    ]

    localAddress [
	<category: 'accessing'>
	^self accessor getSocketName
    ]

    read: anInteger [
	<category: 'accessing'>
	^self accessor read: anInteger
    ]

    readInto: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	^self accessor 
	    readInto: aByteArray
	    startingAt: start
	    for: length
    ]

    remoteAddress [
	<category: 'accessing'>
	^self accessor getPeerName
    ]

    stream [
	<category: 'private'>
	^SwazooStream socket: self
    ]

    write: aByteArray [
	<category: 'accessing'>
	^self accessor write: aByteArray
    ]

    writeFrom: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	^self accessor 
	    writeFrom: aByteArray
	    startingAt: start
	    for: length
    ]
]



Object subclass: SwazooStream [
    | socket readBuffer readPtr readEnd writeBuffer writePtr writeEnd chunked |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SwazooStream class >> preambleSize [
        <category: 'defaults'>
	^6
    ]

    SwazooStream class >> defaultBufferSize [
        <category: 'defaults'>
        ^8000
    ]

    SwazooStream class >> connectedPair [
	<category: 'instance creation'>
	^SwazooSocket connectedPair collect: [:each | self socket: each]
    ]

    SwazooStream class >> on: aString [
	"use only for testing!!"

	<category: 'instance creation'>
	^self new setInputString: aString
    ]

    SwazooStream class >> socket: aSwazooSocket [
	<category: 'instance creation'>
	^self new setSocket: aSwazooSocket
    ]

    copyBufferTo: anIndex [
	"from current position to desired index"

	<category: 'mime boundary'>
	| start |
	start := readPtr.
	readPtr := anIndex.
	^readBuffer copyFrom: start to: anIndex - 1
    ]

    indexOfBoundary: aBoundaryBytes [
	"index of boundary start, beeing full boundary or part at the end of buffer. 0 if not found"

	<category: 'mime boundary'>
	| inx innerInx firstInx |
	inx := readPtr.
	[inx <= readEnd] whileTrue: 
		[innerInx := 1.
		firstInx := inx.
		[(aBoundaryBytes at: innerInx) = (readBuffer at: inx)] whileTrue: 
			[innerInx = aBoundaryBytes size ifTrue: [^firstInx].	"full boundary found"
			inx = readEnd ifTrue: [^firstInx].	"partial boundary at the edge of buffer found"
			inx := inx + 1.
			innerInx := innerInx + 1].
		inx := inx + 1].
	^0
    ]

    signsOfBoundary: aBoundaryBytes [
	"detect as fast as possible if any if not all MIME part boundary is present in buffer contents"

	"return number of bundary bytes detected, 0 = no boundary"

	<category: 'mime boundary'>
	| first index |
	first := aBoundaryBytes first.
	"fast test"
	((readPtr + 1 to: readEnd) 
	    contains: [:inx | (readBuffer at: inx) = first]) ifFalse: [^0].
	"full or partial boundary on the edge of buffer test"
	index := self indexOfBoundary: aBoundaryBytes.	"index of full, or partial boundary at the edge"
	index = 0 ifTrue: [^0].	"no boundary found"
	readEnd - index >= aBoundaryBytes size ifTrue: [^aBoundaryBytes size].	"full boundary detected"
	^readEnd - index + 1	"partial boundary at the end of buffer"
    ]

    startsWith: aPartialBoundaryBytes [
	"is remaining part of MIME part boundary at the start of buffer?"

	<category: 'mime boundary'>
	1 to: aPartialBoundaryBytes size
	    do: 
		[:inx | 
		(readBuffer at: readPtr + inx) = (aPartialBoundaryBytes at: inx) 
		    ifFalse: [^false]].
	^true
    ]

    anyDataReady [
	"wait for data and return true if any data ready. On VW somethimes happen that data
	 receipt is signaled but no data is actually received"

	<category: 'accessing-reading'>
	self fillBuffer.
	^readPtr <= readEnd
    ]

    atEnd [
	"TCP socket data never ends!!"

	<category: 'accessing-reading'>
	^false
    ]

    close [
	"close TCP socket and relase buffers"

	<category: 'initialize-release'>
	self socket close.
	self nilWriteBuffer.
	self nilReadBuffer	"to GC buffers"
    ]

    closeChunk [
        "a zero sized chunk determine and end of chunked data and also response"

	<category: 'chunked encoding'>
        | written |
        "first crlf ends 0 length line, second crlf ends whole response"
        written := self socket
                    writeFrom: #(48 13 10 13 10) asByteArray
                    startingAt: 1
                    for: 5.
        written = 5 ifFalse: [self error: 'socket write error']
    ]

    closeResponse [
	"for chunked response: close it by sending null chunk"

	"do a bit cleanup after response is sent"

	<category: 'initialize-release'>
	self flush.
	self isChunked ifTrue: [self closeChunk; resetChunked].
    ]

    cr [
	<category: 'accessing-writing'>
	self nextPutByte: 13
    ]

    crlf [
	<category: 'accessing-writing'>
	self
	    cr;
	    lf
    ]

    writeDataSize [
	<category: 'private'>

	^writeEnd - writePtr + 1
    ]

    fillBuffer [
	<category: 'private'>
	readPtr > readEnd ifFalse: [^self].
	self socket isNil ifTrue: [^self].	"if SwazooStream is used for tests only"
	readPtr := 1.
        readEnd := self socket
                    readInto: readBuffer
                    startingAt: 1
                    for: readBuffer size.       "nr. of actuall bytes read"
        readEnd = 0
            ifTrue:
                [SwazooStreamNoDataError
                    raiseSignal: 'No data available.  Socket probably closed']
    ]

    fillPreamble [
	<category: 'chunked encoding'>

	| size length start |
	size := self writeDataSize.
	"preamble has no room for bigger chunk..."
        size > 65535 ifTrue: [self error: 'chunk too long!'].
        length := size printStringRadix: 16.

        SpEnvironment isSqueak ifTrue: [length := length copyFrom: 4].     "trim 16r"
	writeBuffer
	    replaceFrom: 1 to: length size
	    with: length
	    startingAt: 1.
	writeBuffer
	    replaceFrom: length size + 1 to: 6
	    with: #[32 32 32 32 13 10]
	    startingAt: length size + 1.
	writePtr := 1
    ]

    flush [
	"actually write to the tcp socket and clear write buffer"

	<category: 'initialize-release'>
	| written |
	self socket isNil ifTrue: [^nil].	"for simulations and tests"

	self isChunked ifTrue: [self fillPreamble].
	[writeEnd < writePtr] whileFalse:
	    [written := self socket
                            writeFrom: writeBuffer
                            startingAt: writePtr
                            for: writeEnd - writePtr + 1.
            writePtr := writePtr + written].
	writePtr := self class preambleSize + 1.
	writeEnd := self class preambleSize.
    ]

    isChunked [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	^chunked notNil and: [chunked]
    ]

    isFull [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	^writeEnd >= writeBuffer size
    ]

    lf [
	<category: 'accessing-writing'>
	self nextPutByte: 10
    ]

    next [
	<category: 'accessing-reading'>
	self fillBuffer.
	^readBuffer at: (readPtr := readPtr + 1) - 1
    ]

    next: anInteger [
	<category: 'accessing-reading'>
	| array at n |
	array := String new: anInteger.
	at := 1.
	[ at <= anInteger ] whileTrue: [
	    self fillBuffer.
	    n := readEnd - readPtr + 1 min: anInteger - at + 1.
	    array replaceFrom: at to: at + n - 1 with: readBuffer startingAt: readPtr.
	    readPtr := readPtr + n.
	    at := at + n].
	^array
    ]

    nextByte [
	<category: 'private-stream'>
	self fillBuffer.
	^readBuffer byteAt: (readPtr := readPtr + 1) - 1
    ]

    nextBytes: anInteger [
	<category: 'private-stream'>
	| array at n |
	array := ByteArray new: anInteger.
	at := 1.
	[ at <= anInteger ] whileTrue: [
	    self fillBuffer.
	    n := readEnd - readPtr + 1 min: anInteger - at + 1.
	    array replaceFrom: at to: at + n - 1 with: readBuffer startingAt: readPtr.
	    readPtr := readPtr + n.
	    at := at + n].
	^array
    ]

    nextLine [
	<category: 'accessing-reading'>
	| stream |
	stream := WriteStream on: (String new: 50).
	self writeNextLineTo: stream.
	^stream contents
    ]

    nextPut: aCharacterOrInteger [
	<category: 'accessing-writing'>
	self isFull ifTrue: [self flush].
	writeBuffer at: (writeEnd := writeEnd + 1) put: aCharacterOrInteger asCharacter. "###"
	^aCharacterOrInteger
    ]

    nextPutAllBufferOn: aStream [
	<category: 'accessing-reading'>
	| n |
	n := readEnd - readPtr + 1.
	aStream next: readEnd - readPtr + 1 putAll: readBuffer startingAt: readPtr.
	readPtr := readEnd + 1.
	^n
    ]

    nextPutAll: aByteStringOrArray [
	<category: 'accessing-writing'>
	| at n |
	at := 1.
	[ at <= aByteStringOrArray size ] whileTrue: [
	    self isFull ifTrue: [self flush].
	    n := writeBuffer size - writeEnd min: aByteStringOrArray size - at + 1.
	    writeBuffer replaceFrom: writeEnd + 1 to: writeEnd + n with: aByteStringOrArray startingAt: at.
	    writeEnd := writeEnd + n.
	    at := at + n].
	^aByteStringOrArray
    ]

    nextPutByte: aByte [
	<category: 'private-stream'>
	self isFull ifTrue: [self flush].
	^writeBuffer byteAt: (writeEnd := writeEnd + 1) put: aByte
    ]

    nextPutBytes: aByteArray [
	<category: 'private-stream'>
	^self nextPutAll: aByteArray
    ]

    nextPutLine: aByteStringOrArray [
	<category: 'accessing-writing'>
	self nextPutAll: aByteStringOrArray.
	self crlf
    ]

    nextUnfoldedLine [
	<category: 'accessing-reading'>
	| stream ch |
	stream := WriteStream on: (String new: 50).
	self writeNextLineTo: stream.
	stream contents isEmpty 
	    ifFalse: 
		[
		[ch := self peek.
		ch notNil and: [ch == Character space or: [ch == Character tab]]] 
			whileTrue: [self writeNextLineTo: stream]].
	^stream contents
    ]

    nilReadBuffer [
	"to release memory"

	<category: 'initialize-release'>
	readBuffer := nil
    ]

    nilWriteBuffer [
	"to release memory"

	<category: 'initialize-release'>
	writeBuffer := nil
    ]

    peek [
	<category: 'accessing-reading'>
	| byte |
	self anyDataReady ifFalse: [^nil].
	^readBuffer at: readPtr
    ]

    peekByte [
	<category: 'private-stream'>
	self anyDataReady ifFalse: [^nil].
	^readBuffer byteAt: readPtr
    ]

    print: anObject [
	<category: 'private'>
	anObject printOn: self
    ]

    readBuffer [
	<category: 'accessing'>
	^readBuffer
    ]

    enlargeReadBuffer: anInteger [
	<category: 'buffer size'>
	anInteger < readBuffer size ifTrue: [ ^self ].
	readBuffer := (readBuffer class new: anInteger)
	    replaceFrom: 1
	        to: readBuffer size
	        with: readBuffer
	        startingAt: 1;
	    yourself
    ]

    readBuffer: aByteArray ready: dataLength [
	<category: 'private'>
	readBuffer := aByteArray.
	readPtr := 1.
	readEnd := dataLength.
    ]

    writeBuffer: aByteArray [
	<category: 'private'>
	writeBuffer := aByteArray.
	writePtr := self class preambleSize + 1.
	writeEnd := self class preambleSize.
    ]

    resetChunked [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	chunked := false
    ]

    setChunked [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	chunked := true
    ]

    setInputString: aCollection [
	<category: 'private'>
	self readBuffer: aCollection asString ready: aCollection size.
	self writeBuffer: (String new: self class defaultBufferSize).
    ]

    setSocket: aSwazooSocket [
	<category: 'private'>
	self socket: aSwazooSocket.
	self readBuffer: (String new: self class defaultBufferSize) ready: 0.
	self writeBuffer: (String new: self class defaultBufferSize).
    ]

    skip: anInteger [
	<category: 'accessing-reading'>
	| n skipped |
	n := anInteger.
	[
	    skipped := n min: (readEnd - readPtr + 1).
	    readPtr := readPtr + skipped.
	    n := n - skipped.
	    n > 0
	] whileTrue: [self fillBuffer]
    ]

    socket [
	<category: 'private'>
	^socket
    ]

    socket: aSocket [
	<category: 'private'>
	socket := aSocket
    ]

    space [
	<category: 'accessing-writing'>
	self nextPutByte: 32
    ]

    upTo: aCharacterOrByte [
	<category: 'accessing-reading'>
	| targetChar result r ws |
	targetChar := aCharacterOrByte asCharacter. "###"
	r := readBuffer indexOf: targetChar startingAt: readPtr ifAbsent: [0].
	r = 0 ifFalse: [result := self next: r - readPtr. self next. ^result].

	ws := String new writeStream.
	[self nextPutAllBufferOn: ws.
	self fillBuffer.
	r := readBuffer indexOf: targetChar startingAt: readPtr ifAbsent: [0].
	r = 0] whileTrue.

	ws next: r putAll: readBuffer startingAt: 1.
	readPtr := r + 1.
	^ws contents
    ]

    writeBufferContents [
	<category: 'accessing-writing'>
	^writeBuffer copyFrom: writePtr to: writeEnd
    ]

    writeNextLineTo: aStream [
	<category: 'accessing-reading'>
	| r |
	[r := readBuffer indexOf: Character cr startingAt: readPtr ifAbsent: [0].
	r = 0] whileTrue: [
	    self nextPutAllBufferOn: aStream.
	    self fillBuffer].

	aStream next: r - readPtr putAll: readBuffer startingAt: readPtr.
	readPtr := r + 1.
	self peekByte = 10	"skip remaining linefeed"
	    ifTrue: [readPtr := readPtr + 1]
	    ifFalse: [SwazooHTTPParseError raiseSignal: 'CR without LF']
    ]
]



Object subclass: SwazooURI [
    | protocol hostname port identifier queries |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SwazooURI class >> fromString: aString [
	<category: 'instance creation'>
	^self new fromString: aString
    ]

    SwazooURI class >> value: aString [
	<category: 'instance creation'>
	^self new value: aString
    ]

    asString [
	<category: 'printing'>
	| targetStream |
	targetStream := WriteStream on: String new.
	self printOn: targetStream.
	^targetStream contents
    ]

    defaultPort [
	<category: 'private'>
	^80
    ]

    fromStream: sourceStream [
	<category: 'initialize-release'>
	self readProtocolFrom: sourceStream.
	self readHostFrom: sourceStream.
	self readPortFrom: sourceStream.
	self readIdentifierFrom: sourceStream.
	self readQueryFrom: sourceStream.
	^self
    ]

    fromString: aString [
	<category: 'initialize-release'>
	| sourceStream |
	sourceStream := ReadStream on: aString.
	self fromStream: sourceStream.
	^self
    ]

    host [
	<category: 'accessing'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: self hostname.
	self port = self defaultPort 
	    ifFalse: 
		[ws nextPut: $:.
		self port printOn: ws].
	^ws contents
    ]

    host: aString [
	<category: 'accessing'>
	| rs |
	rs := ReadStream on: aString.
	self hostname: (rs upTo: $:).
	rs atEnd ifFalse: [self port: rs upToEnd asNumber]
    ]

    hostname [
	<category: 'accessing'>
	^hostname
    ]

    hostname: aHostname [
	<category: 'accessing'>
	hostname := aHostname
    ]

    identifier [
	<category: 'accessing'>
	^identifier
    ]

    identifier: anObject [
	<category: 'accessing'>
	identifier := anObject
    ]

    identifierPath [
	<category: 'accessing'>
	| parts |
	parts := (HTTPString subCollectionsFrom: self identifier delimitedBy: $/) 
		    collect: [:each | HTTPString decodedHTTPFrom: each].
	self identifier first = $/ ifTrue: [parts addFirst: '/'].
	^parts reject: [:each | each isEmpty]
    ]

    includesQuery: aString [
	<category: 'accessing-queries'>
	| result |
	result := self queries detect: [:aQuery | aQuery key = aString]
		    ifNone: [nil].
	^result notNil
    ]

    isDirectory [
	<category: 'testing'>
	^self identifier last = $/
    ]

    port [
	"^an Integer
	 The port number defaults to 80 for HTTP."

	<category: 'accessing'>
	^port isNil ifTrue: [80] ifFalse: [port]
    ]

    port: anInteger [
	<category: 'accessing'>
	port := anInteger
    ]

    printOn: targetStream [
	<category: 'printing'>
	(self hostname notNil and: [self protocol notNil]) 
	    ifTrue: 
		[targetStream
		    nextPutAll: self protocol;
		    nextPutAll: '://'].
	self hostname notNil ifTrue: [targetStream nextPutAll: self hostname].
	(self hostname notNil and: [self port notNil and: [self port ~= 80]]) 
	    ifTrue: 
		[targetStream
		    nextPut: $:;
		    nextPutAll: self port printString].
	self identifier notNil ifTrue: [targetStream nextPutAll: self identifier].
	self printQueriesOn: targetStream.
	^self
    ]

    printQueriesOn: targetStream [
	<category: 'printing'>
	| firstQuery |
	self queries isEmpty 
	    ifFalse: 
		[firstQuery := self queries at: 1.
		targetStream
		    nextPut: $?;
		    nextPutAll: firstQuery key;
		    nextPut: $=;
		    nextPutAll: (HTTPString encodedHTTPFrom: firstQuery value).
		2 to: self queries size
		    do: 
			[:queryIndex | 
			| aQuery |
			aQuery := self queries at: queryIndex.
			targetStream
			    nextPut: $&;
			    nextPutAll: aQuery key;
			    nextPut: $=;
			    nextPutAll: (HTTPString encodedHTTPFrom: aQuery value)]].
	^self
    ]

    protocol [
	<category: 'accessing'>
	protocol isNil ifTrue: [self protocol: 'http'].
	^protocol
    ]

    protocol: aString [
	<category: 'accessing'>
	protocol := aString
    ]

    queries [
	"^an OrderedCollection
	 This is an ordered colleciton of associations.  It can't be a dictionary, because it is legal to have many entries with the same key value."

	<category: 'accessing-queries'>
	queries isNil ifTrue: [queries := OrderedCollection new].
	^queries
    ]

    queries: anOrderedCollection [
	"^self
	 The queries must be an OrderedCollection of Associations c.f. >>queries"

	<category: 'accessing-queries'>
	queries := anOrderedCollection.
	^self
    ]

    queriesNamed: aString [
	<category: 'accessing-queries'>
	^self queries select: [:aQuery | aQuery key = aString]
    ]

    queryAt: aString [
	<category: 'accessing-queries'>
	^self queryAt: aString ifAbsent: [nil]
    ]

    queryAt: aString ifAbsent: aBlock [
	"^aString
	 I return the value of the first query I find with the key aString.  If there are none I execute aBlock."

	<category: 'accessing-queries'>
	| result |
	result := self queries detect: [:aQuery | aQuery key = aString]
		    ifNone: [aBlock].
	^result value
    ]

    readHostFrom: aStream [
	"^self
	 I read the host name from the URI presumed to be in aStream.  The stream should be positioned right at the start, or just after the '//' of the protocol.  The host name is terminated by one of $:, $/, $? or the end of the stream depending on wether there is a port, path, query or nothing following the host.  If the host name is of zero length, I record a nil host name.  The stream is left positioned at the terminating character."

	<category: 'private'>
	| hostnameStream |
	hostnameStream := WriteStream on: String new.
	
	[| nextCharacter |
	nextCharacter := aStream peek.
	#($: $/ $? nil) includes: nextCharacter] 
		whileFalse: [hostnameStream nextPut: aStream next].
	hostnameStream contents isEmpty 
	    ifFalse: [hostname := hostnameStream contents].
	^self
    ]

    readIdentifierFrom: sourceStream [
	<category: 'private'>
	self identifier: (sourceStream upTo: $?).
	^self
    ]

    readPortFrom: aStream [
	"^self
	 I read the port nnumber from the URI presumed to be in aStream.  If a port number has been specified, the stream should be positioned right at before a $: charcter.  So, if the next chacter is a :, we have a port number.  I read up to one of $/, $? or the end of the stream depending on wether there is a path, query or nothing following the host.  The stream is left positioned at the terminating character."

	<category: 'private'>
	| targetStream |
	targetStream := WriteStream on: String new.
	aStream peek == $: 
	    ifTrue: 
		[| terminators |
		terminators := Array 
			    with: $/
			    with: $?
			    with: nil.
		aStream next.
		
		[| nextCharacter |
		nextCharacter := aStream peek.
		terminators includes: nextCharacter] 
			whileFalse: 
			    [| nextDigit |
			    nextDigit := aStream next.
			    nextDigit isDigit ifTrue: [targetStream nextPut: nextDigit]].
		targetStream contents isEmpty 
		    ifFalse: [port := targetStream contents asNumber]].
	^self
    ]

    readProtocolFrom: aStream [
	"^self
	 I read the protocol from the URI presumed to be in aStream.  The protocol preceeds '://' in the URI.  I leave the stream position either right after the '//' if there is a protocol, otherwise I reset the position to the start of the stream."

	<category: 'private'>
	| candidateProtocol |
	candidateProtocol := aStream upTo: $:.
	(aStream size - aStream position >= 2 
	    and: [aStream next == $/ and: [aStream next == $/]]) 
		ifTrue: [self protocol: candidateProtocol]
		ifFalse: [aStream reset].
	^self
    ]

    readQueryFrom: sourceStream [
	<category: 'private'>
	[sourceStream atEnd] whileFalse: 
		[| nameValue name value |
		nameValue := sourceStream upTo: $&.
		name := nameValue copyUpTo: $=.
		value := (nameValue readStream)
			    upTo: $=;
			    upToEnd.	"if any"
		self queries add: name -> (HTTPString decodedHTTPFrom: value)].
	^self
    ]

    value [
	"1 halt: 'Use >>asString or >>printOn: instead'."

	<category: 'accessing'>
	^self asString
    ]
]



Object subclass: URIIdentifier [
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    = anIdentifier [
	<category: 'comparing'>
	^self match: anIdentifier
    ]

    hash [
	<category: 'comparing'>
	^1
    ]

    match: anotherIdentifier [
	<category: 'testing'>
	^(self typeMatch: anotherIdentifier) 
	    and: [self valueMatch: anotherIdentifier]
    ]

    requestMatch: aRequest [
	<category: 'testing'>
	^self valueMatch: aRequest
    ]

    typeMatch: anotherIdentifier [
	<category: 'private'>
	^self class == anotherIdentifier class
    ]

    valueMatch: aRequestOrIdentifier [
	<category: 'private'>
	^self subclassResponsibility
    ]
]



URIIdentifier subclass: SiteIdentifier [
    | ip port host |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SiteIdentifier class >> defaultPort [
	<category: 'accessing'>
	^80
    ]

    SiteIdentifier class >> host: hostName ip: anIP port: aPort [
	<category: 'instance creation'>
	^self new 
	    setIp: anIP
	    port: aPort
	    host: hostName
    ]

    SiteIdentifier class >> ip: anIP port: aPort host: hostName [
	<category: 'obsolete'>
	^self new 
	    setIp: anIP
	    port: aPort
	    host: hostName
    ]

    currentUrl [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents
    ]

    host [
	<category: 'accessing'>
	host isNil ifTrue: [host := '*'].
	^host
    ]

    host: aString [
	<category: 'private'>
	host := aString
    ]

    hostMatch: aSiteIdentifier [
	<category: 'private-comparing'>
	self host asLowercase = aSiteIdentifier host asLowercase ifTrue: [^true].
	(self host = '*' or: [aSiteIdentifier host = '*']) ifTrue: [^true].	"is this always good?"
	^false
    ]

    ip [
	<category: 'accessing'>
	ip isNil ifTrue: [ip := '*'].
	^ip
    ]

    ip: aString [
	<category: 'private'>
	ip := aString
    ]

    ipMatch: aSiteIdentifier [
	"ip can be in numbers or named!!"

	<category: 'private-comparing'>
	| myIP otherIP |
	self ip = aSiteIdentifier ip ifTrue: [^true].
	(self ip = '*' or: [self ip = '0.0.0.0']) ifTrue: [^true].
	(aSiteIdentifier ip = '*' or: [aSiteIdentifier ip = '0.0.0.0']) 
	    ifTrue: [^true].
	"is this always good?"
	myIP := SpIPAddress hostName: self ip port: self port.
	otherIP := SpIPAddress hostName: aSiteIdentifier ip
		    port: aSiteIdentifier port.
	^myIP hostAddress = otherIP hostAddress
    ]

    isEmpty [
	"host ip port empty or nil"

	<category: 'testing'>
	(host isNil or: [host isEmpty]) ifTrue: [^true].
	(ip isNil or: [ip isEmpty]) ifTrue: [^true].
	port isNil ifTrue: [^true].
	^false
    ]

    newServer [
	<category: 'initialize-release'>
	^(HTTPServer new)
	    ip: self ip;
	    port: self port
    ]

    port [
	<category: 'accessing'>
	port isNil ifTrue: [port := self class defaultPort].
	^port
    ]

    port: aNumber [
	<category: 'private'>
	port := aNumber
    ]

    portMatch: aSiteIdentifier [
	"ih host can be anything then same goes for the port of request too"

	<category: 'private-comparing'>
	self port = aSiteIdentifier port ifTrue: [^true].
	(self host = '*' or: [aSiteIdentifier host = '*']) ifTrue: [^true].
	^false
    ]

    printHostPortStringOn: stream [
	<category: 'private'>
	stream nextPutAll: (self host notNil ifTrue: [self host] ifFalse: ['']).
	self port = 80 
	    ifFalse: 
		[stream
		    nextPut: $:;
		    nextPutAll: self port printString]
    ]

    printString [
	<category: 'private'>
	^'a Swazoo.SiteIndentifier
	host: ' 
	    , (self host isNil ifTrue: [''] ifFalse: [self host]) , '
	ip: ' 
	    , (self ip isNil ifTrue: [''] ifFalse: [self ip]) , '
	port: ' 
	    , self port printString
    ]

    printUrlOn: aWriteStream [
	<category: 'private'>
	aWriteStream nextPutAll: 'http://'.
	self printHostPortStringOn: aWriteStream
    ]

    setIp: anIP port: aPort host: hostName [
	<category: 'initialize-release'>
	self ip: anIP.
	self port: aPort.
	self host: hostName
    ]

    valueMatch: aRequestOrIdentifier [
	<category: 'private-comparing'>
	^(self portMatch: aRequestOrIdentifier) 
	    and: [(self ipMatch: aRequestOrIdentifier)
	    and: [self hostMatch: aRequestOrIdentifier]]
    ]
]



Object subclass: URIResolution [
    | position request |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    URIResolution class >> resolveRequest: aRequest startingAt: aResource [
	<category: 'instance creation'>
	^(self new initializeRequest: aRequest) visitResource: aResource
    ]

    advance [
	<category: 'private'>
	self position: self position + 1
    ]

    atEnd [
	<category: 'accessing'>
	^self position = self request uri identifierPath size
    ]

    currentIdentifier [
	<category: 'private'>
	^self currentPath last
    ]

    currentPath [
	<category: 'private'>
	^self request uri identifierPath copyFrom: 1 to: self position
    ]

    fullPath [
	<category: 'accessing'>
	^self request uri identifierPath
    ]

    getAnswerFrom: aResource [
	<category: 'private'>
	^aResource answerTo: self request
    ]

    initializeRequest: aRequest [
	<category: 'private-initialize'>
	self request: aRequest.
	self request resolution: self.
	self position: 1
    ]

    position [
	<category: 'accessing'>
	^position
    ]

    position: anInteger [
	<category: 'private'>
	position := anInteger
    ]

    request [
	<category: 'accessing'>
	^request
    ]

    request: aRequest [
	<category: 'private'>
	request := aRequest
    ]

    resolveCompositeResource: aResource [
	<category: 'resolving'>
	(aResource canAnswer and: [aResource match: self currentIdentifier]) 
	    ifFalse: [^nil].
	^self visitChildrenOf: aResource advancing: true
    ]

    resolveLeafResource: aResource [
	<category: 'resolving'>
	(aResource canAnswer and: [aResource match: self currentIdentifier])
	    ifFalse: [^nil].
	^self getAnswerFrom: aResource
    ]

    resolveServerRoot: aServerRoot [
	<category: 'resolving'>
	^self resolveTransparentComposite: aServerRoot
    ]

    resolveSite: aSite [
	<category: 'resolving'>
	(aSite canAnswer and: [aSite match: self request]) ifFalse: [^nil].
	^self visitChildrenOf: aSite advancing: false
    ]

    resolveTransparentComposite: aCompositeResource [
	<category: 'resolving'>
	^self visitChildrenOf: aCompositeResource advancing: false
    ]

    resourcePath [
	<category: 'accessing'>
	^self request uri identifierPath copyFrom: 1 to: self position
    ]

    retreat [
	<category: 'private'>
	self position: self position - 1.
	^nil
    ]

    siteMatch: aSite [
	<category: 'backwards compatibility'>
	^aSite match: self request
    ]

    tailPath [
	<category: 'accessing'>
	| fullPath |
	fullPath := self fullPath.
	^fullPath copyFrom: self position + 1 to: fullPath size
    ]

    tailStream [
	<category: 'private'>
	^ReadStream on: self tailPath
    ]

    visitChildrenOf: aResource advancing: aBoolean [
	<category: 'resolving'>
	| response |
	self atEnd & aBoolean ifTrue: [^self getAnswerFrom: aResource].
	aBoolean ifTrue: [self advance].
	aResource children do: 
		[:each | 
		response := self visitResource: each.
		response isNil ifFalse: [^response]].
	^aBoolean ifTrue: [self retreat] ifFalse: [nil]
    ]

    visitResource: aResource [
	<category: 'resolving'>
	^aResource helpResolve: self
    ]
]



Eval [
    HTTPServer initialize
]
