"======================================================================
|
|   FTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2008 Free Software Foundation, Inc.
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



Namespace current: NetClients.FTP [

Object subclass: FTPServerEntity [
    | permissions id owner group sizeInBytes modifiedDate filename isDirectory |
    
    <category: 'NetClients-FTP'>
    <comment: nil>

    filename [
	<category: 'accessing'>
	^filename
    ]

    filename: aValue [
	<category: 'accessing'>
	filename := aValue
    ]

    group [
	<category: 'accessing'>
	^group
    ]

    group: aValue [
	<category: 'accessing'>
	group := aValue
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: aValue [
	<category: 'accessing'>
	id := aValue asNumber
    ]

    isDirectory [
	<category: 'accessing'>
	^isDirectory
    ]

    isDirectory: aValue [
	<category: 'accessing'>
	isDirectory := aValue
    ]

    modifiedDate [
	<category: 'accessing'>
	^modifiedDate
    ]

    modifiedDate: aValue [
	<category: 'accessing'>
	modifiedDate := aValue
    ]

    owner [
	<category: 'accessing'>
	^owner
    ]

    owner: aValue [
	<category: 'accessing'>
	owner := aValue
    ]

    permissions [
	<category: 'accessing'>
	^permissions
    ]

    permissions: aValue [
	<category: 'accessing'>
	permissions := aValue
    ]

    sizeInBytes [
	<category: 'accessing'>
	^sizeInBytes
    ]

    sizeInBytes: aValue [
	<category: 'accessing'>
	sizeInBytes := aValue asNumber
    ]

    displayString [
	<category: 'displaying'>
	| stream |
	stream := Stream on: (String new: 100).
	self isDirectory 
	    ifTrue: [stream nextPutAll: ' <D> ']
	    ifFalse: [stream space: 5].
	stream
	    nextPutAll: self filename;
	    space: 30 - self filename size.
	stream nextPutAll: self sizeInBytes printString.
	^stream contents
    ]

    from: stream [
	<category: 'initialize-release'>
	self permissions: (stream upTo: Character space).
	stream skipSeparators.
	self id: (stream upTo: Character space).
	stream skipSeparators.
	self owner: (stream upTo: Character space).
	stream skipSeparators.
	self group: (stream upTo: Character space).
	stream skipSeparators.
	self sizeInBytes: (stream upTo: Character space).
	stream skipSeparators.
	self modifiedDate: (self getDateFromNext: 3 on: stream).
	stream skipSeparators.
	self filename: (stream upTo: Character space).
	self isDirectory: self sizeInBytes = 0
    ]

    getDateFromNext: aNumber on: stream [
	<category: 'private'>
	| iStream |
	iStream := WriteStream on: (String new: 100).
	aNumber timesRepeat: 
		[iStream nextPutAll: (stream upTo: Character space).
		iStream nextPut: Character space.
		stream skipSeparators].
	^DateTime readFrom: iStream contents readStream
    ]
]

]



Namespace current: NetClients.FTP [

NetClient subclass: FTPClient [
    | loggedInUser |
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-FTP'>

    FTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^21
    ]

    FTPClient class >> exampleHost: host [
	"self exampleHost: 'localhost'."

	<category: 'examples'>
	^self exampleHost: host port: 21
    ]

    FTPClient class >> exampleHost: host port: port [
	"self exampleHost: 'localhost' port: 2121."

	<category: 'examples'>
	| user password stream client |
	user := 'utente'.
	password := 'bonzini'.
	stream := WriteStream on: (String new: 256).
	client := FTPClient connectToHost: host port: port.
	
	[client
	    username: user password: password;
	    login;
	    getList: '/' into: stream] 
		ensure: [client close].
	^stream contents
    ]

    FTPClient class >> exampleHost: host fileName: fileName [
	"self exampleHost: 'localhost'."

	<category: 'examples'>
	^self 
	    exampleHost: host
	    port: 21
	    fileName: fileName
    ]

    FTPClient class >> exampleHost: host port: port fileName: fileName [
	"self exampleHost: 'arrow' fileName: '/pub/smallwalker/README'."

	<category: 'examples'>
	| user password stream client |
	user := 'utente'.
	password := 'bonzini'.
	stream := WriteStream on: (String new: 256).
	client := FTPClient connectToHost: host port: port.
	
	[client
	    username: user password: password;
	    login;
	    getFile: fileName
		type: #ascii
		into: stream] 
		ensure: [client close].
	^stream contents
    ]

    protocolInterpreter [
	<category: 'private'>
	^FTPProtocolInterpreter
    ]

    login [
	<category: 'ftp'>
	self connectIfClosed.
	loggedInUser = self user ifTrue: [^self].
	self clientPI ftpUser: self user username.
	self clientPI ftpPassword: self user password.
	loggedInUser := self user
    ]

    logout [
	<category: 'ftp'>
	loggedInUser := nil.
	(self clientPI)
	    ftpQuit;
	    close
    ]

    getFile: fileName type: type into: aStream [
	<category: 'ftp'>
	| fname directory tail |
	self login.
	fname := File path: fileName.
	directory := fname path asString.
	tail := fname stripPath asString.
	tail isEmpty 
	    ifTrue: 
		[^self clientPI 
		    getDataWithType: type
		    into: aStream
		    do: [self clientPI ftpRetrieve: fileName]]
	    ifFalse: 
		[self clientPI ftpCwd: directory.
		^self clientPI 
		    getDataWithType: type
		    into: aStream
		    do: [self clientPI ftpRetrieve: tail]]
    ]

    getList: pathName into: aStream [
	<category: 'ftp'>
	| fname directory tail |
	self login.
	fname := File path: pathName.
	directory := fname path asString.
	tail := fname stripPath asString.
	self clientPI ftpCwd: directory.
	^self clientPI 
	    getDataWithType: #ascii
	    into: aStream
	    do: 
		[tail isEmpty 
		    ifTrue: [self clientPI ftpList]
		    ifFalse: [self clientPI ftpList: tail].
		0]
    ]
]

]



Namespace current: NetClients.FTP [

NetProtocolInterpreter subclass: FTPProtocolInterpreter [
    
    <import: Sockets>
    <comment: nil>
    <category: 'NetClients-FTP'>

    openDataConnectionDo: controlBlock [
	<category: 'data connection'>
	"Create a socket.  Set up a queue for a single connection."

	| portSocket dataStream |
	portSocket := ServerSocket 
		    reuseAddr: true
		    port: 0
		    queueSize: 1
		    bindTo: nil.
	
	[self ftpPort: portSocket port host: portSocket address asByteArray.

	"issue control command."
	controlBlock value.
	[(dataStream := portSocket accept) isNil] whileTrue: [Processor yield]] 
		ensure: [portSocket close].
	^dataStream
    ]

    openPassiveDataConnectionDo: controlBlock [
	<category: 'data connection'>
	"Enter Passive Mode"

	| array dataSocket dataStream |
	array := self ftpPassive.
	dataStream := Socket remote: (IPAddress fromBytes: (array at: 1))
		    port: (array at: 2).

	"issue control command."
	controlBlock value.
	^dataStream
    ]

    connect [
	<category: 'ftp protocol'>
	super connect.
	self checkResponse
    ]

    getDataWithType: type into: aStream do: controlBlock [
	<category: 'ftp protocol'>
	| dataStream totalByte coll |
	(#(#ascii #binary) includes: type) 
	    ifFalse: [^self error: 'type must be #ascii or #binary'].
	type == #ascii ifTrue: [self ftpTypeAscii] ifFalse: [self ftpTypeBinary].

	"dataStream := self openDataConnectionDo: [totalByte := controlBlock value]."
	dataStream := self 
		    openPassiveDataConnectionDo: [totalByte := controlBlock value].
	totalByte > 0 ifTrue: [self reporter totalByte: totalByte].
	self reporter startTransfer.
	
	[[dataStream atEnd] whileFalse: 
		[| byte |
		byte := dataStream nextAvailable: 1024.
		self reporter readByte: byte size.
		type == #ascii 
		    ifTrue: [aStream nextPutAll: (self decode: byte)]
		    ifFalse: [aStream nextPutAll: byte]]] 
		ensure: [dataStream close].
	self reporter endTransfer
    ]

    ftpAbort [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'ABOR';
	    cr.
	self checkResponse
    ]

    ftpCdup [
	"Change to Parent Directory"

	<category: 'ftp protocol'>
	self
	    nextPutAll: 'CDUP';
	    cr.
	self checkResponse
    ]

    ftpCwd: directory [
	"Change Working Directory"

	<category: 'ftp protocol'>
	self
	    nextPutAll: 'CWD ' , directory;
	    cr.
	self checkResponse
    ]

    ftpList [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'LIST';
	    cr.
	self checkResponse
    ]

    ftpList: pathName [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'LIST ' , pathName;
	    cr.
	self checkResponse
    ]

    ftpPassive [
	<category: 'ftp protocol'>
	| response stream hostAddress port |
	self
	    nextPutAll: 'PASV';
	    cr.
	response := self getResponse.
	self checkResponse: response.
	response status = 227 
	    ifFalse: [^self unexpectedResponse: response].

	"227 Entering Passive Mode (h1,h2,h3,h4,p1,p2)"
	stream := response statusMessage readStream.
	hostAddress := ByteArray new: 4.
	stream upTo: $(.
	hostAddress at: 1 put: (Integer readFrom: stream).
	stream skip: 1.
	hostAddress at: 2 put: (Integer readFrom: stream).
	stream skip: 1.
	hostAddress at: 3 put: (Integer readFrom: stream).
	stream skip: 1.
	hostAddress at: 4 put: (Integer readFrom: stream).
	stream skip: 1.
	port := Integer readFrom: stream.
	stream skip: 1.
	port := (port bitShift: 8) + (Integer readFrom: stream).
	^Array with: hostAddress with: port
    ]

    ftpPassword: password [
	<category: 'ftp protocol'>
	| response |
	self
	    nextPutAll: 'PASS ' , password;
	    cr.
	response := self getResponse.
	self checkResponse: response
	    ifError: [self loginIncorrectError: response statusMessage]
    ]

    ftpPort: portInteger host: hostAddressBytes [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'PORT ';
	    nextPutAll: (hostAddressBytes at: 1) printString;
	    nextPut: $,;
	    nextPutAll: (hostAddressBytes at: 2) printString;
	    nextPut: $,;
	    nextPutAll: (hostAddressBytes at: 3) printString;
	    nextPut: $,;
	    nextPutAll: (hostAddressBytes at: 4) printString;
	    nextPut: $,;
	    nextPutAll: ((portInteger bitShift: -8) bitAnd: 255) printString;
	    nextPut: $,;
	    nextPutAll: (portInteger bitAnd: 255) printString;
	    cr.
	self checkResponse
    ]

    ftpQuit [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'QUIT';
	    cr.
	self checkResponse
    ]

    ftpRetrieve: fileName [
	<category: 'ftp protocol'>
	| response stream |
	self
	    nextPutAll: 'RETR ' , fileName;
	    cr.
	response := self getResponse.
	self checkResponse: response.

	"150 Opening data connection for file (398 bytes)."
	stream := response statusMessage readStream.
	stream skipTo: $(.
	stream atEnd ifTrue: [^nil].
	^Integer readFrom: stream
    ]

    ftpStore: fileName [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'STOR ' , fileName;
	    cr.
	self checkResponse
    ]

    ftpType: type [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'TYPE ' , type;
	    cr.
	self checkResponse
    ]

    ftpTypeAscii [
	<category: 'ftp protocol'>
	^self ftpType: 'A'
    ]

    ftpTypeBinary [
	<category: 'ftp protocol'>
	^self ftpType: 'I'
    ]

    ftpUser: user [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'USER ' , user;
	    cr.
	self checkResponse
    ]

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.

	"Positive Preliminary reply"
	status = 110 
	    ifTrue: 
		["Restart marker reply"

		^self].
	status = 120 
	    ifTrue: 
		["Service ready in nnn minutes"

		^self].
	status = 125 
	    ifTrue: 
		["Data connection already open"

		^self].
	status = 150 
	    ifTrue: 
		["File status okay"

		^self].

	"Positive Completion reply"
	status = 200 
	    ifTrue: 
		["OK"

		^self].
	status = 202 
	    ifTrue: 
		["Command not implemented"

		^self].
	status = 211 
	    ifTrue: 
		["System status"

		^self].
	status = 212 
	    ifTrue: 
		["Directory status"

		^self].
	status = 213 
	    ifTrue: 
		["File status"

		^self].
	status = 214 
	    ifTrue: 
		["Help message"

		^self].
	status = 215 
	    ifTrue: 
		["NAME system type"

		^self].
	status = 220 
	    ifTrue: 
		["Service ready for new user"

		^self].
	status = 221 
	    ifTrue: 
		["Service closing control connection"

		^self].
	status = 225 
	    ifTrue: 
		["Data connection open"

		^self].
	status = 226 
	    ifTrue: 
		["Closing data connection"

		^self].
	status = 227 
	    ifTrue: 
		["Entering Passive Mode"

		^self].
	status = 230 
	    ifTrue: 
		["User logged in"

		^self].
	status = 250 
	    ifTrue: 
		["Requested file action okay"

		^self].
	status = 257 
	    ifTrue: 
		["'PATHNAME' created"

		^self].

	"Positive Intermediate reply"
	status = 331 
	    ifTrue: 
		["User name okay"

		^self].
	status = 332 
	    ifTrue: 
		["Need account for login"

		^self].
	status = 350 
	    ifTrue: 
		["Requested file action pending"

		^self].

	"Transient Negative Completion reply"
	status = 421 
	    ifTrue: 
		["Service not available"

		^errorBlock value].
	status = 425 
	    ifTrue: 
		["Can't open data connection"

		^errorBlock value].
	status = 426 
	    ifTrue: 
		["Connection closed"

		^errorBlock value].
	status = 450 
	    ifTrue: 
		["Requested file action not taken"

		^errorBlock value].
	status = 451 
	    ifTrue: 
		["Requested action aborted"

		^errorBlock value].
	status = 452 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].

	"Permanent Negative Completion reply"
	status = 500 
	    ifTrue: 
		["Syntax error"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["Syntax error"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["Command not implemented"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["Bad sequence of commands"

		^errorBlock value].
	status = 504 
	    ifTrue: 
		["Command not implemented"

		^errorBlock value].
	status = 530 
	    ifTrue: 
		["Not logged in"

		^self loginIncorrectError: response statusMessage].
	status = 532 
	    ifTrue: 
		["Need account for storing files"

		^errorBlock value].
	status = 550 
	    ifTrue: 
		["Requested action not taken"

		^self fileNotFoundError: response statusMessage].
	status = 551 
	    ifTrue: 
		["Requested action aborted"

		^errorBlock value].
	status = 552 
	    ifTrue: 
		["Requested file action aborted"

		^errorBlock value].
	status = 553 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    fileNotFoundError: errorString [
	<category: 'private'>
	^FTPFileNotFoundError signal: errorString
    ]
]

]



Namespace current: NetClients.FTP [

NetClientError subclass: FTPFileNotFoundError [
    
    <comment: nil>
    <category: 'NetClients-FTP'>
]

]

