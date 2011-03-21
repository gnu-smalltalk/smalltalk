"======================================================================
|
|   POP3 protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002 Free Software Foundation, Inc.
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



Namespace current: NetClients.POP [

NetResponse subclass: POPResponse [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-POP3'>

    printStatusOn: aStream [
	<category: 'printing'>
	status notNil 
	    ifTrue: 
		[status = 1 
		    ifTrue: [aStream nextPutAll: '+OK ']
		    ifFalse: [aStream nextPutAll: '-ERR ']].
	statusMessage notNil ifTrue: [aStream nextPutAll: statusMessage]
    ]

    parseStatusLine: aClient [
	"Returned string is: '+OK ok message' or '-ERR error message'"

	<category: 'private'>
	| stream |
	stream := aClient nextLine readStream.
	"status = 1 (OK), status = 0 (ERR)"
	stream next = $+ ifTrue: [status := 1] ifFalse: [status := 0].
	stream skipTo: Character space.
	stream skipSeparators.
	statusMessage := stream upToEnd
    ]
]

]



Namespace current: NetClients.POP [

NetClient subclass: POPClient [
    | loggedInUser |
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-POP3'>

    POPClient class >> defaultPortNumber [
	<category: 'constants'>
	^110
    ]

    POPClient class >> example2Host: host username: username password: password [
	<category: 'examples'>
	
	[self 
	    exampleHost: host
	    username: username
	    password: password] 
		on: LoginIncorrectError
		do: 
		    [:ex | 
		    'Login incorrect' printNl.
		    ex return]
    ]

    POPClient class >> exampleHost: host username: username password: password [
	<category: 'examples'>
	| client |
	client := POPClient connectToHost: host.
	
	[client username: username password: password.
	client login.
	Transcript showCr: 'New messages: ' , client newMessagesCount printString.
	Transcript showCr: 'bytes ' , client newMessagesSize printString.
	Transcript showCr: 'ids ' , client newMessagesIds printString.
	Transcript showCr: 'sizes ' , client newMessages printString.
	client getNewMailMessages: [:m | m inspect] delete: false] 
		ensure: [client close]
    ]

    login [
	<category: 'accessing'>
	loggedInUser = self user ifTrue: [^self].
	loggedInUser isNil ifFalse: [self logout].
	self connect.
	self clientPI popUser: self username.
	self clientPI popPassword: self password.
	loggedInUser := self user
    ]

    logout [
	<category: 'accessing'>
	self clientPI popQuit
    ]

    newMessagesCount [
	<category: 'accessing'>
	^self clientPI popStatus key
    ]

    newMessagesSize [
	<category: 'accessing'>
	^self clientPI popStatus value
    ]

    newMessagesIds [
	<category: 'accessing'>
	^self clientPI popList keys asSortedCollection asArray
    ]

    newMessages [
	<category: 'accessing'>
	^self clientPI popList
    ]

    sizeAt: id [
	<category: 'accessing'>
	^self clientPI popList: id
    ]

    headersAt: id [
	<category: 'accessing'>
	^self clientPI popTop: id lines: 1
    ]

    at: id [
	<category: 'accessing'>
	^self clientPI popRetrieve: id
    ]

    getNewMailHeaders: messageBlock delete: delete [
	<category: 'accessing'>
	| count entity |
	self login.
	count := self clientPI popStatus key.
	count = 0 
	    ifFalse: 
		[1 to: count
		    do: 
			[:i | 
			entity := self clientPI popTop: i lines: 1.
			messageBlock value: entity].
		delete ifTrue: [1 to: count do: [:i | self clientPI popDelete: i]]]
    ]

    getNewMailMessages: messageBlock delete: delete [
	<category: 'accessing'>
	| count entity |
	self login.
	count := self clientPI popStatus key.
	count = 0 
	    ifFalse: 
		[1 to: count
		    do: 
			[:i | 
			entity := self clientPI popRetrieve: i.
			messageBlock value: entity].
		delete ifTrue: [1 to: count do: [:i | self clientPI popDelete: i]]]
    ]

    getNewMailStreams: streamBlock delete: delete [
	<category: 'accessing'>
	| count |
	self connectIfClosed.
	self clientPI popUser: self username.
	self clientPI popPassword: self password.
	count := self clientPI popStatus.
	count = 0 
	    ifFalse: 
		[1 to: count do: [:i | self clientPI popRetrieve: i into: streamBlock value].
		delete ifTrue: [1 to: count do: [:i | self clientPI popDelete: i]]]
    ]

    protocolInterpreter [
	<category: 'private'>
	^POPProtocolInterpreter
    ]
]

]



Namespace current: NetClients.POP [

NetProtocolInterpreter subclass: POPProtocolInterpreter [
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-POP3'>

    POPProtocolInterpreter class >> defaultResponseClass [
	<category: 'private-attributes'>
	^POPResponse
    ]

    connect [
	<category: 'pop protocol'>
	super connect.
	self checkResponse
    ]

    popDelete: anInteger [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'DELE ' , anInteger printString;
	    cr.
	self checkResponse
    ]

    popList [
	<category: 'pop protocol'>
	| stream dictionary assoc |
	self
	    nextPutAll: 'LIST';
	    cr.
	self checkResponse.
	dictionary := LookupTable new.
	stream := ReadWriteStream on: (String new: 100).
	self receiveMessageUntilPeriodInto: stream.
	stream reset.
	
	[assoc := self parseSizeDataFrom: stream nextLine readStream.
	assoc key > 0] 
		whileTrue: [dictionary add: assoc].
	^dictionary
    ]

    popList: anInteger [
	<category: 'pop protocol'>
	| stream response |
	self
	    nextPutAll: 'LIST ' , anInteger printString;
	    cr.
	response := self getResponse.
	self checkResponse: response.
	response statusMessage == nil ifTrue: [^0].
	stream := response statusMessage readStream.
	^(self parseSizeDataFrom: stream) value
    ]

    popPassword: password [
	<category: 'pop protocol'>
	| response |
	self
	    nextPutAll: 'PASS ' , password;
	    cr.
	response := self getResponse.
	self checkResponse: response
	    ifError: [self loginIncorrectError: response statusMessage]
    ]

    popQuit [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'QUIT';
	    cr.
	self checkResponse
    ]

    popRetrieve: anInteger [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'RETR ' , anInteger printString;
	    cr.
	self checkResponse.
	^MIME.MimeEntity readFromClient: self connectionStream
    ]

    popRetrieve: anInteger into: aStream [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'RETR ' , anInteger printString;
	    cr.
	self checkResponse.
	self receiveMessageUntilPeriodInto: aStream
    ]

    popStatus [
	"Check status and return a number of messages."

	<category: 'pop protocol'>
	| response stream |
	self
	    nextPutAll: 'STAT';
	    cr.
	response := self getResponse.
	self checkResponse: response.
	response statusMessage == nil ifTrue: [^0 -> 0].
	stream := response statusMessage readStream.
	^self parseSizeDataFrom: stream
    ]

    popTop: anInteger lines: linesInteger [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'TOP ' , anInteger printString;
	    nextPutAll: ' ' , linesInteger printString;
	    cr.
	self checkResponse.
	^MIME.MimeEntity readFromClient: self connectionStream
    ]

    popTop: anInteger lines: linesInteger into: aStream [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'TOP ' , anInteger printString;
	    nextPutAll: ' ' , linesInteger printString;
	    cr.
	self checkResponse.
	self receiveMessageUntilPeriodInto: aStream
    ]

    popUser: user [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'USER ' , user;
	    cr.
	self checkResponse
    ]

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.
	status = 1 
	    ifTrue: 
		["OK"

		^self].
	^errorBlock value
    ]

    parseSizeDataFrom: stream [
	<category: 'private'>
	| count size |
	stream skipSeparators.
	count := Integer readFrom: stream.
	stream skipSeparators.
	size := Integer readFrom: stream.
	^count -> size
    ]
]

]

