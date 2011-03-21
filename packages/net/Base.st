"======================================================================
|
|   Abstract NetClient framework
|
|
 ======================================================================"

"======================================================================
|
| NetUser and NetEnvironment are Copyright 2000 Cincom, Inc.
| NetResponse, PluggableReporter and *Error are (c) 1995 Kazuki Yasumatsu
| and in the public domain.
|
| The rest is copyright 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
| and written by Paolo Bonzini.
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



Eval [
    NetClients at: #LineEndCR put: #cr.
    NetClients at: #LineEndLF put: #nl.
    NetClients at: #LineEndCRLF put: #crnl.
    NetClients at: #LineEndTransparent put: #yourself
]



Object subclass: NetUser [
    | username password |
    
    <category: 'NetClients-Framework'>
    <comment: 'Instances of this class hold the username and password used to login to a mail server.

Instance Variables:
	username	<String>		username string
	password	<String>		password string'>

    NetUser class >> username: aUsername password: aPassword [
	"NetUser username: 'foo' password: 'foo'"

	<category: 'instance creation'>
	| user |
	user := self new.
	^user
	    username: aUsername;
	    password: aPassword yourself
    ]

    password [
	<category: 'accessing'>
	^password
    ]

    password: aString [
	<category: 'accessing'>
	password := aString
    ]

    username [
	<category: 'accessing'>
	^username
    ]

    username: aString [
	<category: 'accessing'>
	username := aString
    ]
]



Object subclass: NetEnvironment [
    | debugStream debugCategories debugClasses trace logFileName |
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    NetEnvironment class [
	| uniqueInstance |
	
    ]

    NetEnvironment class >> default [
	<category: 'accessing'>
	^uniqueInstance isNil 
	    ifTrue: [uniqueInstance := self new]
	    ifFalse: [uniqueInstance]
    ]

    debugCategories [
	<category: 'accessing'>
	debugCategories isNil 
	    ifTrue: 
		[debugCategories := Set new.
		debugCategories add: #general].
	^debugCategories
    ]

    debugClasses [
	<category: 'accessing'>
	^debugClasses isNil 
	    ifTrue: [debugClasses := Set new]
	    ifFalse: [debugClasses]
    ]

    debugStream [
	<category: 'accessing'>
	^debugStream
    ]

    debugStream: aStream [
	<category: 'accessing'>
	debugStream := aStream
    ]

    logFileName [
	<category: 'accessing'>
	logFileName isNil ifTrue: [logFileName := 'NetClientLog.txt'].
	^logFileName
    ]

    logFileName: aString [
	<category: 'accessing'>
	logFileName := aString
    ]

    trace [
	<category: 'accessing'>
	trace isNil ifTrue: [trace := false].
	^trace
    ]

    trace: aBoolean [
	<category: 'accessing'>
	trace := aBoolean
    ]

    debug: aBlock level: aLevel [
	<category: 'debugging'>
	(self trace and: [self debugCategories includes: aLevel]) 
	    ifTrue: [aBlock value]
    ]

    log: aStringOrBlock [
	<category: 'debugging'>
	self log: aStringOrBlock level: #general
    ]

    log: aStringOrBlock level: aLevel [
	<category: 'debugging'>
	| stream i briefMsg aMsg |
	self debug: 
		[(stream := self debugStream) == nil ifTrue: [^self].
		(aStringOrBlock isKindOf: BlockClosure) 
		    ifTrue: [aMsg := aStringOrBlock value]
		    ifFalse: [aMsg := aStringOrBlock].
		i := aMsg size.
		[i > 0 and: [(aMsg at: i) isSeparator]] whileTrue: [i := i - 1].
		briefMsg := aMsg copyFrom: 1 to: i.
		stream
		    cr;
		    nextPutAll: briefMsg;
		    flush]
	    level: aLevel
    ]

    printTrace: aString [
	<category: 'debugging'>
	| stream |
	(stream := self debugStream) == nil ifTrue: [^self].
	stream
	    cr;
	    cr;
	    nextPutAll: ' **** ' asString.
	Date today printOn: stream.
	stream nextPutAll: ' '.
	Time now printOn: stream.
	stream
	    nextPutAll: ' ' , aString , ' ****';
	    flush
    ]

    traceOff [
	<category: 'debugging'>
	self printTrace: 'Stop Trace'.
	self trace: false
    ]

    traceOn [
	<category: 'debugging'>
	self trace: true.
	self printTrace: 'Start Trace'
    ]

    addDebugCategory: symbol [
	<category: 'private'>
	self debugCategories add: symbol
    ]

    removeDebugCategory: symbol [
	<category: 'private'>
	self debugCategories remove: symbol
    ]

    reset [
	<category: 'private'>
	self resetDebugClasses.
	self resetDebugCategories
    ]

    resetDebugCategories [
	<category: 'private'>
	debugCategories := nil
    ]

    resetDebugClasses [
	<category: 'private'>
	debugClasses := nil
    ]

    addToDebug: aClass [
	<category: 'registration'>
	self debugClasses add: aClass
    ]
]



Object subclass: NetClient [
    | hostName portNumber user reporter clientPI connectionStream isSSL |
    
    <import: Sockets>
    <category: 'NetClients-Framework'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>

    NetClient class >> defaultPortNumber [
	<category: 'constants'>
	self subclassResponsibility
    ]

    NetClient class >> defaultSSLPortNumber [
	<category: 'constants'>
	self subclassResponsibility
    ]

    NetClient class >> connectToHost: aHostname [
	<category: 'instance creation'>
	^self new hostName: aHostname; connect
    ]

    NetClient class >> connectToHost: aHostname port: aPort [
	<category: 'instance creation'>
	^self new hostName: aHostname; portNumber: aPort; connect
    ]

    NetClient class >> loginToHost: aHostName asUser: userString withPassword: passwdString [
	<category: 'instance creation'>
	^self 
	    loginToHost: aHostName
	    port: nil
	    asUser: userString
	    withPassword: passwdString
    ]

    NetClient class >> loginToHost: aHostName port: aNumber asUser: userString withPassword: passwdString [
	<category: 'instance creation'>
	^self new 
	    loginToHost: aHostName
	    port: aNumber
	    asUser: userString
	    withPassword: passwdString
    ]

    NetClient class >> loginUser: userString withPassword: passwdString [
	<category: 'instance creation'>
	^self loginUser: userString withPassword: passwdString
    ]

    user [
	<category: 'accessing'>
	^user
    ]

    user: aNetUser [
	<category: 'accessing'>
	user := aNetUser
    ]

    username [
	<category: 'accessing'>
	^user username
    ]

    password [
	<category: 'accessing'>
	^self user password
    ]

    username: usernameString password: passwdString [
	<category: 'accessing'>
	user := NetUser username: usernameString password: passwdString
    ]

    clientPI [
	<category: 'accessing'>
	clientPI isNil ifTrue: [
            self clientPI: (self protocolInterpreter client: self)].
	^clientPI
    ]

    clientPI: aProtocolInterpreter [
	<category: 'accessing'>
	clientPI := aProtocolInterpreter
    ]

    hostName [
	<category: 'accessing'>
	^hostName
    ]

    hostName: aString [
	<category: 'accessing'>
	hostName := aString
    ]

    isSSL [
	<category: 'accessing'>
	isSSL isNil ifTrue: [isSSL := false].
	^isSSL
    ]

    isSSL: aBoolean [
	<category: 'accessing'>
	isSSL := aBoolean
    ]

    defaultPortNumber [
	<category: 'accessing'>
	^self isSSL
            ifFalse: [self class defaultPortNumber]
	    ifTrue: [self class defaultSSLPortNumber]
    ]

    portNumber [
	<category: 'accessing'>
	portNumber isNil ifTrue: [^self defaultPortNumber].
	portNumber = 0 ifTrue: [^self defaultPortNumber].
	^portNumber
    ]

    portNumber: aNumber [
	<category: 'accessing'>
	portNumber := aNumber
    ]

    reporter [
	<category: 'accessing'>
	reporter isNil ifTrue: [reporter := Reporter new].
	^reporter
    ]

    reporter: aReporter [
	<category: 'accessing'>
	reporter := aReporter
    ]

    protocolInterpreter [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    binary [
	<category: 'connection'>
	connectionStream class == CrLfStream 
	    ifTrue: [connectionStream := connectionStream stream]
    ]

    isBinary [
	<category: 'connection'>
	^connectionStream class ~~ CrLfStream
    ]

    text [
	<category: 'connection'>
	self binary.
	self clientPI lineEndConvention = LineEndCRLF 
	    ifTrue: [connectionStream := CrLfStream on: connectionStream]
    ]

    close [
	<category: 'connection'>
	^self logout
    ]

    closeConnection [
	<category: 'connection'>
	self closed 
	    ifFalse: 
		[connectionStream close.
		connectionStream := nil].
	self liveAcrossSnapshot ifTrue: [ObjectMemory removeDependent: self]
    ]

    closed [
	<category: 'connection'>
	^connectionStream == nil
    ]

    connect [
	<category: 'connection'>
	| connection messageText |
	[connection := self createSocket]
		    on: Error
		    do: 
			[:ex | 
			ex.
			messageText := ex messageText.
			ex return: nil].
	connection isNil ifTrue: [^self clientPI connectionFailedError: messageText].
	self connectionStream: connection.
	self clientPI connected.
    ]

    connectIfClosed [
	<category: 'connection'>
	self closed ifTrue: [self connect]
    ]

    createSSLWrapper [
	<category: 'connection'>
	| connection messageText |
        (self hostName anySatisfy: [ :ch |
            '''"\${}()*?' includes: ch ])
                 ifTrue: [ self error: 'invalid host name' ].
        (self portNumber isInteger not and: [self anySatisfy: [ :ch |
            '''"\${}()*?' includes: ch ]])
                 ifTrue: [ self error: 'invalid port name' ].
        Directory libexec isNil
            ifTrue: [ self error: 'cannot find gnutls-wrapper' ].
	^FileDescriptor
            popen: '%1 %2 %3' % { Directory libexec / 'gnutls-wrapper'.
                self hostName. self portNumber }
            dir: 'r+'
    ]

    createSocket [
	<category: 'connection'>
	| connection messageText |
        self isSSL ifTrue: [ ^self createSSLWrapper ].
	^Socket remote: self hostName port: self portNumber
    ]

    connectionStream [
	<category: 'connection'>
	^connectionStream
    ]

    connectionStream: aSocket [
	<category: 'connection'>
	connectionStream := aSocket.
	self text.
	self liveAcrossSnapshot ifTrue: [ObjectMemory addDependent: self]
    ]

    liveAcrossSnapshot [
	<category: 'private-attributes'>
	^false
    ]

    login [
	<category: 'connection'>
	
    ]

    logout [
	<category: 'connection'>
	
    ]

    loginToHost: aHostName asUser: userString withPassword: passwdString [
	<category: 'connection'>
	^self 
	    loginToHost: aHostName
	    port: nil
	    asUser: userString
	    withPassword: passwdString
    ]

    loginToHost: aHostName port: aNumber asUser: userString withPassword: passwdString [
	<category: 'connection'>
	| resp |
	hostName := aHostName.
	portNumber := aNumber.
	self username: userString password: passwdString.
	self connect.
	(resp := self login) completedSuccessfully ifFalse: [^nil]
    ]

    reconnect [
	<category: 'connection'>
	self closeConnection.
	self connect
    ]
]



Object subclass: NetProtocolInterpreter [
    | client |
    
    <import: TCP>
    <category: 'NetClients-Framework'>
    <comment: nil>

    NetProtocolInterpreter class >> base64Encode: aString [
	| i j outSize c1 c2 c3 out b64string chars |
	chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
	outSize := aString size // 3 * 4.
	(aString size \\ 3) = 0 ifFalse: [ outSize := outSize + 4 ].
	b64string := String new: outSize.

	i := 1.
	1 to: outSize by: 4 do: [ :j |
	    c1 := aString valueAt: i ifAbsent: [0].
	    c2 := aString valueAt: i+1 ifAbsent: [0].
	    c3 := aString valueAt: i+2 ifAbsent: [0].

            out := c1 bitShift: -2.
            b64string at: j put: (chars at: out + 1).

            out := ((c1 bitAnd: 3) bitShift: 4) bitOr: (c2 bitShift: -4).
            b64string at: j+1 put: (chars at: out + 1).

            out := ((c2 bitAnd: 15) bitShift: 2) bitOr: (c3 bitShift: -6).
            b64string at: j+2 put: (chars at: out + 1).

            out := c3 bitAnd: 63.
            b64string at: j+3 put: (chars at: out + 1).

            i := i + 3.
        ].

	b64string
	    replaceFrom: outSize - (i - aString size) + 2
	    to: outSize withObject: $=.

       ^b64string
    ]

    NetProtocolInterpreter class >> log: aString level: aLevel [
	<category: 'debugging'>
	NetEnvironment default log: aString level: aLevel
    ]

    NetProtocolInterpreter class >> registerToDebug [
	<category: 'debugging'>
	NetEnvironment default addToDebug: self
    ]

    NetProtocolInterpreter class >> client: aNetClient [
	<category: 'instance creation'>
	^self new client: aNetClient
    ]

    NetProtocolInterpreter class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    NetProtocolInterpreter class >> defaultResponseClass [
	<category: 'private-attributes'>
	^NetResponse
    ]

    NetProtocolInterpreter class >> base64Encode: aString [
	| chars i j n t1 t2 t3 ch aStringSize b64Size b64String |
	chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.

	aStringSize := aString size.
	b64Size := aStringSize // 3 * 4.
	(aStringSize \\ 3 ~= 0) ifTrue: [b64Size := b64Size + 4].
	b64String := String new: b64Size withAll: $=.

	i := j := 1.
	[i <= aStringSize] whileTrue: [
	    t1 := (aString at: i ifAbsent: [Character nul]) asInteger.
	    t2 := (aString at: i + 1 ifAbsent: [Character nul]) asInteger.
	    t3 := (aString at: i + 2 ifAbsent: [Character nul]) asInteger.
	    n := 3 min: aStringSize - i + 1.

	    ch := t1 bitShift: -2.
	    b64String at: j put: (chars at: ch + 1).

	    ch := ((t1 bitAnd: 3) bitShift: 4) bitOr: (t2 bitShift: -4).
	    b64String at: j + 1 put: (chars at: ch + 1).

	    n >= 2 ifTrue: [
		ch := ((t2 bitAnd: 15) bitShift: 2) bitOr: (t2 bitShift: -6).
		b64String at: j + 2 put: (chars at: ch + 1).
	    ].

	    n >= 3 ifTrue: [
		ch := t3 bitAnd: 63.
		b64String at: j + 3 put: (chars at: ch + 1).
	    ].

	    i := i + 3.
	    j := j + 4.
	].

	^b64String
    ]

    client [
	<category: 'accessing'>
	^client
    ]

    reporter [
	<category: 'accessing'>
	^self client reporter
    ]

    receiveMessageUntilPeriod [
	"Receive and answer a message until period line."

	<category: 'accessing'>
	| write |
	write := WriteStream on: (String new: 4 * 1024).
	self receiveMessageUntilPeriodInto: write.
	^write contents
    ]

    receiveMessageUntilPeriodInto: aStream [
	"Receive a message until period line into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	MIME.MimeEntity new parseSimpleBodyFrom: self onto: aStream
    ]

    sendMessageWithPeriod: aStream [
	"Send aStream as a message with period."

	<category: 'accessing'>
	self connectIfClosed.
	(PrependDotStream to: self)
	    nextPutAll: aStream;
	    flush
    ]

    skipMessageUntilPeriod [
	"Skip a message until period line."

	<category: 'accessing'>
	self connectIfClosed.
	MIME.MimeEntity new skipSimpleBodyFrom: self
    ]

    binary [
	<category: 'connection'>
	client binary
    ]

    isBinary [
	<category: 'connection'>
	^client isBinary
    ]

    text [
	<category: 'connection'>
	client text
    ]

    close [
	<category: 'connection'>
        client closeConnection
    ]

    closed [
	<category: 'connection'>
	^client closed
    ]

    connectionStream [
	<category: 'connection'>
	^client connectionStream
    ]

    connectionStream: aSocket [
	<category: 'connection'>
	client connectionStream: aSocket
    ]

    connected [
	<category: 'callbacks'>
    ]

    connect [
	<category: 'connection'>
	client connect
    ]

    connectIfClosed [
	<category: 'connection'>
	client connectIfClosed
    ]

    reconnect [
	<category: 'connection'>
	client reconnect
    ]

    decode: aString [
	<category: 'encoding'>
	^aString
    ]

    encode: aString [
	<category: 'encoding'>
	^aString
    ]

    client: aNetClient [
	<category: 'initialize-release'>
	client := aNetClient
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    release [
	<category: 'initialize-release'>
	self close
    ]

    checkResponse [
	<category: 'private'>
	self checkResponse: self getResponse
    ]

    checkResponse: response [
	<category: 'private'>
	self checkResponse: response
	    ifError: [self errorResponse: response]
    ]

    checkResponse: reponse ifError: errorBlock [
	<category: 'private'>
	
    ]

    connectionClosedError: messageText [
	<category: 'private'>
	^(ConnectionClosedError new)
	    tag: messageText;
	    signal: 'Connection closed: ' , messageText
    ]

    connectionFailedError: messageText [
	<category: 'private'>
	^(ConnectionFailedError new)
	    tag: messageText;
	    signal: 'Connection failed: ' , messageText
    ]

    getResponse [
	<category: 'private'>
	^self class defaultResponseClass fromClient: self
    ]

    loginIncorrectError: messageText [
	<category: 'private'>
	^(LoginIncorrectError new)
	    tag: messageText;
	    signal: 'Login incorrect: ' , messageText
    ]

    errorResponse: aResponse [
	<category: 'private'>
	^(ProtocolError new)
	    response: aResponse;
	    signal
    ]

    unexpectedResponse: aResponse [
	<category: 'private'>
	^(UnexpectedResponseError new)
	    response: aResponse;
	    signal
    ]

    lineEndConvention [
	<category: 'private-attributes'>
	^LineEndCRLF
    ]

    atEnd [
	<category: 'stream accessing'>
	^self connectionStream atEnd
    ]

    contents [
	<category: 'stream accessing'>
	^self decode: self connectionStream contents
    ]

    cr [
	<category: 'stream accessing'>
	| conv |
	conv := self lineEndConvention.
	(conv = LineEndCR or: [conv = LineEndTransparent]) 
	    ifTrue: [^self connectionStream nextPut: Character cr].
	conv = LineEndLF ifTrue: [^self connectionStream nextPut: Character nl].
	conv = LineEndCRLF 
	    ifTrue: 
		[^self connectionStream
		    nextPut: Character cr;
		    nextPut: Character nl].
	self error: 'Undefined line-end convention'
    ]

    flush [
	<category: 'stream accessing'>
	self connectionStream flush
    ]

    next [
	<category: 'stream accessing'>
	^self connectionStream next
    ]

    next: anInteger [
	<category: 'stream accessing'>
	^self decode: (self connectionStream next: anInteger)
    ]

    nextAvailable: anInteger [
	<category: 'stream accessing'>
	^self decode: (self connectionStream nextAvailable: anInteger)
    ]

    nextLine [
	<category: 'stream accessing'>
	| write byte |
	write := WriteStream on: (String new: 128).
	[self connectionStream atEnd] whileFalse: 
		[byte := self connectionStream next.
		byte == Character cr 
		    ifTrue: 
			[self connectionStream peekFor: Character nl.
			^self decode: write contents].
		byte == Character nl ifTrue: [^self decode: write contents].
		write nextPut: byte].
	^self decode: write contents
    ]

    nextPut: aCharacter [
	<category: 'stream accessing'>
	self connectionStream nextPutAll: (self encode: (String with: aCharacter))
    ]

    nextPutAll: aString [
	<category: 'stream accessing'>
	aString isEmpty ifTrue: [^self].
	self connectionStream nextPutAll: (self encode: aString)
    ]

    nl [
	<category: 'stream accessing'>
	| conv |
	conv := self lineEndConvention.
	conv = LineEndCR ifTrue: [^self connectionStream nextPut: Character cr].
	(conv = LineEndLF or: [conv = LineEndTransparent]) 
	    ifTrue: [^self connectionStream nextPut: Character nl].
	conv = LineEndCRLF 
	    ifTrue: 
		[^self connectionStream
		    nextPut: Character cr;
		    nextPut: Character nl].
	self error: 'Undefined line-end convention'
    ]

    species [
	<category: 'stream accessing'>
	^self connectionStream species
    ]

    upTo: aCharacter [
	<category: 'stream accessing'>
	| byte |
	aCharacter = Character cr ifTrue: [^self nextLine].
	byte := self encode: (String with: aCharacter).
	byte size = 1 
	    ifTrue: [^self decode: (self connectionStream upTo: byte)]
	    ifFalse: [^self decode: (self connectionStream upToAll: byte)]
    ]

    update: aSymbol [
	"Dependents of ObjectMemory are sent update:
	 #returnFromSnapshot when a snapshot is started."

	<category: 'updating'>
	self liveAcrossSnapshot 
	    ifTrue: 
		[aSymbol == #returnFromSnapshot ifTrue: [self close]
		"(aSymbol == #aboutToSnapshot or: [aSymbol == #aboutToQuit])
		 ifTrue: [self close]."].
	super update: aSymbol
    ]
]



Object subclass: NetResponse [
    | status statusMessage |
    
    <category: 'NetClients-Framework'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>

    NetResponse class >> fromClient: aClient [
	<category: 'instance creation'>
	| response |
	response := self new.
	response parseResponse: aClient.
	^response
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    status: anInteger [
	<category: 'accessing'>
	status := anInteger
    ]

    statusArray [
	<category: 'accessing'>
	| n array |
	status == nil ifTrue: [n := 0] ifFalse: [n := status].
	array := Array new: 3.
	array at: 1 put: n // 100.
	n := n - (n // 100 * 100).
	array at: 2 put: n // 10.
	n := n - (n // 10 * 10).
	array at: 3 put: n.
	^array
    ]

    statusMessage [
	<category: 'accessing'>
	^statusMessage
    ]

    statusMessage: aString [
	<category: 'accessing'>
	statusMessage := aString
    ]

    parseResponse: aClient [
	<category: 'parsing'>
	self parseStatusLine: aClient
    ]

    printOn: aStream [
	<category: 'printing'>
	self printStatusOn: aStream
    ]

    printStatusOn: aStream [
	<category: 'printing'>
	status notNil 
	    ifTrue: 
		[aStream
		    print: status;
		    space].
	statusMessage notNil ifTrue: [aStream nextPutAll: statusMessage]
    ]

    parseStatusLine: aClient [
	<category: 'private'>
	| stream |
	statusMessage := nil.
	
	[stream := aClient nextLine readStream.
	status := Integer readFrom: stream.
	stream next = $-] 
		whileTrue: 
		    [statusMessage == nil 
			ifTrue: [statusMessage := stream upToEnd]
			ifFalse: 
			    [statusMessage := statusMessage , (String with: Character cr) 
					, stream upToEnd]].
	stream skipSeparators.
	statusMessage == nil 
	    ifTrue: [statusMessage := stream upToEnd]
	    ifFalse: 
		[statusMessage := statusMessage , (String with: Character cr) 
			    , stream upToEnd]
    ]
]



Object subclass: Reporter [
    | totalByte readByte startTime currentTime |
    
    <category: 'NetClients-URIResolver'>
    <comment: nil>

    readByte [
	<category: 'accessing'>
	^readByte
    ]

    readByte: anInteger [
	<category: 'accessing'>
	readByte := readByte + anInteger.
	currentTime := Time millisecondClockValue.
    ]

    endTransfer [
	<category: 'api'>
	^self
    ]

    startTransfer [
	<category: 'api'>
	readByte := 0.
	startTime := currentTime := Time millisecondClockValue.
	^self
    ]

    statusString: aString [
	<category: 'api'>
	^self
    ]

    totalByte [
	<category: 'api'>
	^totalByte
    ]

    totalByte: aNumber [
	<category: 'api'>
	totalByte := aNumber
    ]

    transferSpeed [
	<category: 'api'>
	currentTime = startTime ifTrue: [^nil].
        ^readByte / ((currentTime - startTime) / 1000)
    ]
]



Reporter subclass: PluggableReporter [
    | statusBlock |
    
    <category: 'NetClients-Framework'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>

    PluggableReporter class >> statusBlock: aBlock [
	<category: 'instance creation'>
	^self new statusBlock: aBlock
    ]

    endTransfer [
	<category: 'accessing'>
	self statusString: 'Transferring: Done.'
    ]

    readByte: anInteger [
	<category: 'accessing'>
        super readByte: anInteger.
	self statusString: self progressStatusString
    ]

    startTransfer [
	<category: 'accessing'>
        super startTransfer.
	self statusString: 'Transferring: Start.'
    ]

    statusString: statusString [
	<category: 'accessing'>
	statusBlock isNil ifTrue: [^self].
	statusBlock value: statusString
    ]

    progressStatusString [
	<category: 'private'>
	| stream speed |
	stream := WriteStream on: (String new: 128).
	stream print: readByte.
	totalByte == nil 
	    ifFalse: 
		[stream
		    nextPut: $/;
		    print: totalByte].
	stream nextPutAll: ' bytes'.
        speed := self transferSpeed.
	speed == nil
	    ifFalse: 
		[stream nextPutAll: ' ('.
		stream display: (self transferSpeed / 1024 asScaledDecimal: 2).
		stream nextPutAll: ' Kbytes/sec)'].
	^stream contents
    ]

    statusBlock: aBlock [
	<category: 'private'>
	statusBlock := aBlock
    ]
]



Stream subclass: RemoveDotStream [
    | stream ch atStart |
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    RemoveDotStream class >> on: aStream [
	<category: 'instance creation'>
	^self new initialize: aStream
    ]

    atEnd [
	<category: 'input'>
	ch isNil ifFalse: [^false].
	stream isNil ifTrue: [^true].
	stream atEnd 
	    ifTrue: 
		[stream := nil.
		^true].
	ch := stream next.
	(atStart and: [ch == $.]) 
	    ifFalse: 
		[atStart := ch == Character cr or: [ch == Character nl].
		^false].
	atStart := false.

	"Found dot at start of line, discard it"
	stream atEnd 
	    ifTrue: 
		[stream := ch := nil.
		^true].
	ch := stream next.

	"Found lonely dot, we are at end of stream"
	(ch == Character cr or: [ch == Character nl]) 
	    ifTrue: 
		[ch == Character cr ifTrue: [stream next].
		stream := ch := nil.
		^true].
	^false
    ]

    next [
	<category: 'input'>
	| answer |
	self atEnd ifTrue: [self error: 'end of stream reached'].
	answer := ch.
	ch := nil.
	^answer
    ]

    peek [
	<category: 'input'>
	self atEnd ifTrue: [^nil].
	^ch
    ]

    peekFor: aCharacter [
	<category: 'input'>
	self atEnd ifTrue: [^false].
	ch == aCharacter 
	    ifTrue: 
		[self next.
		^true].
	^false
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream.
	atStart := true.
	self atEnd
    ]

    species [
	<category: 'private'>
	^stream species
    ]
]



Stream subclass: PrependDotStream [
    | stream atStart |
    
    <category: 'NetClients-Framework'>
    <comment: 'A PrependDotStream removes a dot to each line starting with a dot, and
ends when its input has a lonely dot.'>

    PrependDotStream class >> to: aStream [
	<category: 'instance creation'>
	^self new initialize: aStream
    ]

    flush [
	<category: 'output'>
	atStart ifFalse: [self nl].
	stream
	    nextPut: $.;
	    nl
    ]

    nextPut: aChar [
	<category: 'output'>
	(atStart and: [aChar == $.]) ifTrue: [stream nextPut: aChar].
	stream nextPut: aChar.
	atStart := aChar == Character nl
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream.
	atStart := true
    ]

    species [
	<category: 'private'>
	^stream species
    ]
]



Stream subclass: CrLfStream [
    | stream readStatus eatLf |
    
    <category: 'NetClients-Framework'>
    <comment: 'A CrLfStream acts as a pipe which transforms incoming data into LF-separated
lines, and outgoing data into CRLF-separated lines.'>

    Lf := nil.
    Cr := nil.

    CrLfStream class >> on: aStream [
	<category: 'instance creation'>
	Cr := Character cr.
	Lf := Character nl.
	^self new on: aStream
    ]

    on: aStream [
	<category: 'initializing'>
	stream := aStream.
	eatLf := false.
	readStatus := #none
    ]

    atEnd [
	<category: 'stream'>
	^stream atEnd and: [readStatus == #none]
    ]

    close [
	<category: 'stream'>
	stream close
    ]

    flush [
	<category: 'stream'>
	stream flush
    ]

    next [
	<category: 'stream'>
	| result |
	readStatus == #none 
	    ifFalse: 
		[readStatus == Cr ifTrue: [stream peekFor: Lf].
		readStatus := #none.
		^Lf].
	result := stream next.
	^(result == Cr or: [result == Lf]) 
	    ifTrue: 
		[readStatus := result.
		Cr]
	    ifFalse: [result]
    ]

    nextLine [
	<category: 'stream'>
	| line |
	line := self upTo: Cr.
	self next.	"Eat line feed"
	^line
    ]

    nextPut: aCharacter [
	<category: 'stream'>
	eatLf 
	    ifTrue: 
		[eatLf := false.
		aCharacter == Lf ifTrue: [^self]]
	    ifFalse: 
		[aCharacter == Lf 
		    ifTrue: 
			[stream
			    nextPut: Cr;
			    nextPut: Lf;
			    flush.
			^self]].
	stream nextPut: aCharacter.
	aCharacter == Cr 
	    ifTrue: 
		[stream
		    nextPut: Lf;
		    flush.
		eatLf := true]
    ]

    peek [
	<category: 'stream'>
	| result |
	readStatus == #none 
	    ifFalse: 
		[readStatus == Cr ifTrue: [stream peekFor: Lf].
		readStatus := Lf.	"peek for LF just once"
		^Lf].
	result := stream peek.
	^result == Lf ifTrue: [Cr] ifFalse: [result]
    ]

    peekFor: aCharacter [
	<category: 'stream'>
	| result success |
	readStatus == #none 
	    ifFalse: 
		[readStatus == Cr ifTrue: [stream peekFor: Lf].
		success := aCharacter == Lf.
		readStatus := success ifTrue: [#none] ifFalse: [Lf].	"peek for LF just once"
		^success].
	result := stream peek.
	(result == Cr or: [result == Lf]) 
	    ifTrue: 
		[success := aCharacter == Cr.
		success ifTrue: [readStatus := stream next].
		^success].
	success := aCharacter == result.
	success ifTrue: [stream next].
	^success
    ]

    species [
	<category: 'stream'>
	^stream species
    ]

    stream [
	<category: 'stream'>
	^stream
    ]
]



Error subclass: NetClientError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>
]



NetClientError subclass: ConnectionFailedError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'The connection attempt failed.'
    ]
]



NetClientError subclass: ConnectionClosedError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'The server closed the connection.'
    ]
]



Notification subclass: ProtocolNotification [
    
    | response |

    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
	<category: 'exception handling'>
	^'Protocol Notification'
    ]

    response [
	<category: 'exception handling'>
	^response
    ]

    response: aResponse [
	<category: 'exception handling'>
	response := aResponse.
        self messageText: '%1: %2' % {self description. response statusMessage}
    ]

    isResumable [
	<category: 'exception handling'>
	^true
    ]
]



NetClientError subclass: ProtocolError [
    
    | response |

    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
	<category: 'exception handling'>
	^'Protocol Error'
    ]

    response [
	<category: 'exception handling'>
	^response
    ]

    response: aResponse [
	<category: 'exception handling'>
	response := aResponse.
        self messageText: '%1: %2' % {self description. response statusMessage}
    ]

    isResumable [
	<category: 'exception handling'>
	^true
    ]
]



NetClientError subclass: UnexpectedResponseError [
    
    | response |

    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
	<category: 'exception handling'>
	^'Unexpected Response'
    ]

    isResumable [
	<category: 'exception handling'>
	^false
    ]
]



NetClientError subclass: LoginIncorrectError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'The server rejected your login attempt.'
    ]
]


NetClientError subclass: WrongStateError [
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'This command cannot be executed in the client''s current state.'
    ]
]

