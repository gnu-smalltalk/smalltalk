"======================================================================
|
|   IMAP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000 Leslie A. Tyrrell
| Copyright (c) 2009 Free Software Foundation
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



Namespace current: NetClients.IMAP [

Object subclass: IMAPCommand [
    | client sequenceID name arguments status responses completionResponse promise |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    ResponseRegistry := nil.

    IMAPCommand class >> initialize [
	"IMAPCommand initialize"

	<category: 'class initialization'>
	(ResponseRegistry := Dictionary new)
	    at: 'FETCH' put: #('FETCH' 'OK' 'NO' 'BAD');
	    at: 'SEARCH' put: #('SEARCH' 'OK' 'NO' 'BAD');
	    at: 'SELECT' put: #('FLAGS' 'EXISTS' 'RECENT' 'OK' 'NO' 'BAD');
	    at: 'EXAMINE' put: #('FLAGS' 'EXISTS' 'RECENT' 'OK' 'NO' 'BAD');
	    at: 'LIST' put: #('LIST' 'OK' 'NO' 'BAD');
	    at: 'LSUB' put: #('LSUB' 'OK' 'NO' 'BAD');
	    at: 'STATUS' put: #('STATUS');
	    at: 'EXPUNGE' put: #('EXPUNGE' 'OK' 'NO' 'BAD');
	    at: 'STORE' put: #('FETCH' 'OK' 'NO' 'BAD');
	    at: 'UID' put: #('FETCH' 'SEARCH' 'OK' 'NO' 'BAD');
	    at: 'CAPABILITY' put: #('CAPABILITY' 'OK' 'BAD');
	    at: 'STORE' put: #('FETCH');
	    at: 'LOGOUT' put: #('BYE' 'OK' 'BAD');
	    at: 'CLOSE' put: #('OK' 'NO' 'BAD');
	    at: 'CHECK' put: #('OK' 'NO');
	    at: 'APPEND' put: #('OK' 'NO' 'BAD');
	    at: 'SUBSCRIBE' put: #('OK' 'NO' 'BAD');
	    at: 'RENAME' put: #('OK' 'NO' 'BAD');
	    at: 'DELETE' put: #('OK' 'NO' 'BAD');
	    at: 'CREATE' put: #('OK' 'NO' 'BAD');
	    at: 'LOGIN' put: #('OK' 'NO' 'BAD');
	    at: 'AUTHENTICATE' put: #('OK' 'NO' 'BAD');
	    at: 'NOOP' put: #('OK' 'BAD')
    ]

    IMAPCommand class >> definedResponsesAt: aName [
	<category: 'defined responses'>
	^self responseRegistry at: aName asUppercase
	    ifAbsentPut: [IdentityDictionary new]
    ]

    IMAPCommand class >> responseRegistry [
	<category: 'defined responses'>
	^ResponseRegistry
    ]

    IMAPCommand class >> forClient: anIMAPPI name: aString arguments: arguments [
	"The intention here is to let users specify the complete string of command arguments. Because this string may contain atom-specials like $(, etc., this line may be sent as quoted string, which would be wrong. So we fool the printing logic to view this string as an atom. It is a hack, but seems like a convenient one"

	<category: 'instance creation'>
	| args |
	args := arguments isCharacters 
		    ifTrue: [#atom -> arguments]
		    ifFalse: [arguments].
	^self new 
	    forClient: anIMAPPI
	    name: aString
	    arguments: args
    ]

    IMAPCommand class >> login: aNameString password: aPassString [
	<category: 'instance creation'>
	^self name: 'login'
	    arguments: (Array with: #string -> aNameString with: #string -> aPassString)
    ]

    IMAPCommand class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    IMAPCommand class >> parse: scanner [
	"Read and parse next command from a stream. This is mainly useful for testing previously stored
	 exchange logs"

	<category: 'instance creation'>
	^self new parse: scanner
    ]

    IMAPCommand class >> readFrom: aStream [
	"Read and parse next command from a stream. This is mainly useful for testing previously stored exchange logs"

	<category: 'instance creation'>
	^self parse: (IMAPScanner on: aStream)
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    arguments: anObject [
	<category: 'accessing'>
	arguments := anObject
    ]

    client [
	<category: 'accessing'>
	^client
    ]

    client: anObject [
	<category: 'accessing'>
	client := anObject
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: anObject [
	<category: 'accessing'>
	name := anObject
    ]

    sequenceID [
	<category: 'accessing'>
	^sequenceID
    ]

    sequenceID: anObject [
	<category: 'accessing'>
	sequenceID := anObject
    ]

    completionResponse [
	<category: 'completion response'>
	^completionResponse
    ]

    completionResponse: anObject [
	<category: 'completion response'>
	completionResponse := anObject.
	self beDone
    ]

    execute [
	"Prepend the given command and send it to the server."

	<category: 'execute'>
	self sendOn: client connectionStream.
	self client connectionStream nl.
	self beSent
    ]

    wait [
	<category: 'execute'>
	^promise value
    ]

    definedResponses [
	<category: 'handle responses'>
	^self class definedResponsesAt: self name asUppercase
    ]

    handle: aResponse [
	<category: 'handle responses'>
	(aResponse hasTag: self sequenceID) 
	    ifTrue: 
		[self completionResponse: aResponse.
		^true].
	(self isDefinedResponse: aResponse) 
	    ifTrue: 
		[self responses add: aResponse.
		^true].
	^self notifyClientIfNeeded: aResponse
    ]

    isDefinedResponse: aResponse [
	<category: 'handle responses'>
	^self definedResponses includes: aResponse cmdName
    ]

    needsClientNotification: aResponse [
	<category: 'handle responses'>
	^false
	"^client isInterestedIn: aResponse"
    ]

    notifyClientIfNeeded: aResponse [
	<category: 'handle responses'>
	^(self needsClientNotification: aResponse) 
	    ifTrue: [client handle: aResponse]
	    ifFalse: [false]
    ]

    registerResponse: aResponse [
	<category: 'handle responses'>
	aResponse isCompletionResponse 
	    ifTrue: [self completionResponse: aResponse]
	    ifFalse: [self responses add: aResponse]
    ]

    responses [
	<category: 'handle responses'>
	^responses notNil 
	    ifTrue: [responses]
	    ifFalse: [responses := OrderedCollection new]
    ]

    forClient: anIMAPPI name: aString arguments: args [
	<category: 'initialization'>
	self client: anIMAPPI.
	self name: aString.
	self arguments: (self canonicalizeArguments: args)
    ]

    initialize [
	<category: 'initialization'>
	promise := Promise new.
	responses := OrderedCollection new: 1
    ]

    completedSuccessfully [
	<category: 'obsolete'>
	^self successful
    ]

    parse: scanner [
	"Read and parse next command from a stream. This is mainly useful for testing previously stored
	 exchange logs"

	<category: 'parsing'>
	| tokens |
	tokens := scanner deepTokenizeAsAssociation.
	self
	    sequenceID: tokens first value;
	    name: (tokens at: 2) value;
	    arguments: (tokens copyFrom: 3 to: tokens size)
    ]

    printCompletionResponseOn: aStream indent: level [
	<category: 'printing'>
	self completionResponse notNil 
	    ifTrue: [self completionResponse printOn: aStream indent: level]
    ]

    printOn: aStream [
	<category: 'printing'>
	self scanner printTokenList: self asTokenList on: aStream
    ]

    printResponseOn: aStream indent: level [
	<category: 'printing'>
	(self responces isNil or: [self responces isEmpty]) ifTrue: [^String new].
	self responses do: 
		[:eachResponse | 
		aStream nl.
		eachResponse printOn: aStream indent: level]
    ]

    scanner [
	<category: 'printing'>
	^IMAPScanner
    ]

    sendOn: aClient [
	"aClient is a IMAPProtocolInterpreter"

	<category: 'printing'>
	self client sendTokenList: self asTokenList
    ]

    asTokenList [
	<category: 'private'>
	| list |
	list := OrderedCollection with: #atom -> self sequenceID
		    with: #atom -> name.
	self arguments notNil ifTrue: [list addAll: self arguments].
	^list
    ]

    canonicalizeArguments: arguments [
	"Arguments can one of: integer, string or array of thereof, potentially nested. Scalars are
	 converted into array with this scalar as a sole element"

	<category: 'private'>
	arguments isNil ifTrue: [^Array new].
	^(arguments isCharacters or: [arguments isSequenceable not]) 
	    ifTrue: [^Array with: arguments]
	    ifFalse: [arguments]
    ]

    promise [
	<category: 'private'>
	^promise
    ]

    commandResponse [
	<category: 'responses'>
	| coll |
	^(coll := self commandResponses) isEmpty 
	    ifTrue: [nil]
	    ifFalse: [coll first]
    ]

    commandResponses [
	<category: 'responses'>
	^self responses select: [:resp | resp cmdName match: self name]
    ]

    commandResponseValue [
	<category: 'responses'>
	| resp |
	^(resp := self commandResponse) isNil ifTrue: [nil] ifFalse: [resp value]
    ]

    statusResponses [
	<category: 'responses'>
	^self responses select: [:eachResponse | eachResponse isStatusResponse]
    ]

    beDone [
	<category: 'status'>
	self status: #done.
	self client commandIsDone: self.
	self value: self completionResponse
    ]

    beSent [
	<category: 'status'>
	self status: #sent.
	self client commandIsInProgress: self
    ]

    status [
	<category: 'status'>
	^status
    ]

    status: anObject [
	<category: 'status'>
	status := anObject
    ]

    value [
	<category: 'status'>
	^promise value
    ]

    value: anObject [
	<category: 'status'>
	promise value: status
    ]

    failed [
	<category: 'testing'>
	^self successful not
    ]

    isDone [
	<category: 'testing'>
	^self status = #done
    ]

    isSent [
	<category: 'testing'>
	^self status = #sent
    ]

    successful [
	<category: 'testing'>
	^self isDone and: [self completionResponse isOK]
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPFetchedItem [
    | name |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPFetchedItem class >> canBe: aName [
	<category: 'instance creation'>
	^false
    ]

    IMAPFetchedItem class >> defaultFetchedItemClass [
	<category: 'instance creation'>
	^IMAPFetchedItem
    ]

    IMAPFetchedItem class >> named: aName [
	<category: 'instance creation'>
	^(self properSubclassForItemNamed: aName) new name: aName
    ]

    IMAPFetchedItem class >> properSubclassForItemNamed: aName [
	<category: 'instance creation'>
	^IMAPFetchedItem allSubclasses detect: [:each | each canBe: aName]
	    ifNone: [self defaultFetchedItemClass]
    ]

    extractContentFrom: tokenStream [
	<category: 'building'>
	self subclassResponsibility
    ]

    name [
	<category: 'name'>
	^name
    ]

    name: aName [
	<category: 'name'>
	name := aName
    ]
]

]



Namespace current: NetClients.IMAP [

NetProtocolInterpreter subclass: IMAPProtocolInterpreter [
    | responseStream commandSequencer mutex readResponseSemaphore continuationPromise commandsInProgress queuedCommands |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    commandPrefix: aString [
	<category: 'accessing'>
	commandSequencer prefix: aString
    ]

    responseStream [
	<category: 'accessing'>
	^responseStream
    ]

    connect [
	<category: 'connection'>
	super connect.
	self resetCommandSequence.
	responseStream := self connectionStream.
	commandSequencer reset.
	self getResponse
    ]

    defaultCommandPrefix [
	<category: 'constants and defaults'>
	^'imapv4_'
    ]

    defaultResponseClass [
	<category: 'constants and defaults'>
	^IMAPResponse
    ]

    lineEndConvention [
	<category: 'constants and defaults'>
	^LineEndCRLF
    ]

    commandIsDone: command [
	<category: 'events'>
	mutex critical: 
		[commandsInProgress remove: command ifAbsent: [^self].
		readResponseSemaphore wait]
    ]

    commandIsInProgress: command [
	<category: 'events'>
	mutex critical: 
		[commandsInProgress addFirst: command.
		readResponseSemaphore signal]
    ]

    commandIsQueued: command [
	<category: 'events'>
	
    ]

    connectionIsReady [
	<category: 'events'>
	
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	mutex := Semaphore forMutualExclusion.
	readResponseSemaphore := Semaphore new.
	queuedCommands := SharedQueue new.
	commandsInProgress := OrderedCollection new: 4.
	commandSequencer := IMAPCommandSequencer 
		    newPrefix: self defaultCommandPrefix.
	self commandReaderLoop fork.
	self responseReaderLoop fork
    ]

    commandReaderLoop [
	<category: 'private'>
	| command |
	^
	[
	[command := queuedCommands next.
	self class log: ['----------------------------------'] level: #IMAPClient.
	self class log: ['C: ' , command printString] level: #IMAPClient.
	command execute] 
		repeat]
    ]

    commandsInProgress [
	<category: 'private'>
	^commandsInProgress
    ]

    nextCommandSequenceNumber [
	<category: 'private'>
	^commandSequencer next
    ]

    queuedCommands [
	<category: 'private'>
	^queuedCommands
    ]

    resetCommandSequence [
	<category: 'private'>
	commandSequencer reset
    ]

    responseReaderLoop [
	<category: 'private'>
	^
	[
	[readResponseSemaphore
	    wait;
	    signal.
	self handleNextResponse] 
		whileTrue]
    ]

    responseStream: stream [
	"This is ONLY for debugging purposes"

	<category: 'private'>
	responseStream := stream
    ]

    executeCommand: aCommand [
	<category: 'public'>
	aCommand sequenceID isNil 
	    ifTrue: [aCommand sequenceID: self nextCommandSequenceNumber].
	queuedCommands nextPut: aCommand.
	self commandIsQueued: aCommand
    ]

    getResponse [
	<category: 'responses'>
	| resp |
	resp := self defaultResponseClass readFrom: self responseStream.
	self class log: ['  S: ' , resp printLog] level: #IMAPServer.
	^resp
    ]

    handle: aResponse [
	<category: 'responses'>
	^self client handle: aResponse
    ]

    handleContinuationResponse: aResponse [
	<category: 'responses'>
	| promise |
	promise := continuationPromise.
	continuationPromise := nil.
	readResponseSemaphore wait.
	promise value: aResponse
    ]

    handleNextResponse [
	<category: 'responses'>
	| resp |
	resp := self getResponse.
	resp isNil ifTrue: [^false].
	(self waitingForContinuation and: [resp isContinuationResponse]) 
	    ifTrue: 
		[self handleContinuationResponse: resp.
		^true].
	commandsInProgress detect: [:command | command handle: resp]
	    ifNone: [self handle: resp].
	^true
    ]

    waitForContinuation [
	<category: 'responses'>
	| promise |
	continuationPromise isNil ifTrue: [continuationPromise := Promise new].
	promise := continuationPromise.
	readResponseSemaphore signal.
	^promise value
    ]

    waitingForContinuation [
	<category: 'responses'>
	^continuationPromise notNil
    ]

    argumentAsAssociation: argument [
	<category: 'sending tokens'>
	(argument isKindOf: Association) ifTrue: [^argument].
	argument isNil ifTrue: [^'NIL'].
	argument isCharacters ifTrue: [^#string -> argument].
	(argument isKindOf: Number) ifTrue: [^#number -> argument].
	argument isSequenceable ifTrue: [^#parenthesizedList -> argument].
	^argument
    ]

    sendLiteralString: string [
	<category: 'sending tokens'>
	IMAPScanner printLiteralStringLength: string on: self connectionStream.
	self waitForContinuation.
	IMAPScanner printLiteralStringContents: string on: self connectionStream
    ]

    sendToken: token tokenType: tokenType [
	<category: 'sending tokens'>
	tokenType = #literalString 
	    ifTrue: [self sendLiteralString: token]
	    ifFalse: 
		[IMAPScanner 
		    printToken: token
		    tokenType: tokenType
		    on: self connectionStream]
    ]

    sendTokenList: listOfTokens [
	<category: 'sending tokens'>
	| assoc |
	listOfTokens do: 
		[:arg | 
		assoc := self argumentAsAssociation: arg.
		self sendToken: assoc value tokenType: assoc key]
	    separatedBy: [self connectionStream space]
    ]
]

]



Namespace current: NetClients.IMAP [

NetClient subclass: IMAPClient [
    | state |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    IMAPClient class >> defaultPortNumber [
	<category: 'constants'>
	^143
    ]

    protocolInterpreter [
	<category: 'accessing'>
	^IMAPProtocolInterpreter
    ]

    state [
	<category: 'accessing'>
	^state
    ]

    state: aState [
	<category: 'accessing'>
	state := aState.
	state client: self
    ]

    connected [
	"Establish a connection to the host <aString>."

	<category: 'connection'>
	self state: IMAPNonAuthenticatedState new
    ]

    append: message to: aMailboxName [
	<category: 'commands'>
	^self state 
	    append: message
	    to: aMailboxName
	    flags: nil
	    date: nil
    ]

    append: message to: aMailboxName flags: flags date: dateString [
	<category: 'commands'>
	^self state 
	    append: message
	    to: aMailboxName
	    flags: flags
	    date: dateString
    ]

    capability [
	<category: 'commands'>
	^self state capability
    ]

    check [
	<category: 'commands'>
	^self state check
    ]

    close [
	<category: 'commands'>
	^self state close
    ]

    create: aMailBoxName [
	<category: 'commands'>
	^self state create: aMailBoxName
    ]

    delete: aMailBoxName [
	<category: 'commands'>
	^self state delete: aMailBoxName
    ]

    examine: aMailBoxName [
	<category: 'commands'>
	^self state examine: aMailBoxName
    ]

    expunge [
	<category: 'commands'>
	^self state expunge
    ]

    fetch: aCriteria [
	<category: 'commands'>
	^self state fetch: aCriteria
    ]

    fetch: messageNumbers retrieve: criteria [
	<category: 'commands'>
	^self state fetch: messageNumbers retrieve: criteria
    ]

    fetchRFC822Messages: messageNumbers [
	<category: 'commands'>
	| result dict |
	result := self state fetch: messageNumbers retrieve: 'rfc822'.
	dict := Dictionary new: 4.
	^result successful 
	    ifTrue: 
		[result commandResponses 
		    do: [:resp | dict at: resp value put: (resp parameters at: 'RFC822')].
		dict]
	    ifFalse: [nil]
    ]

    list: refName mailbox: name [
	<category: 'commands'>
	^self state list: refName mailbox: name
    ]

    login [
	<category: 'commands'>
	^self state login
    ]

    logout [
	<category: 'commands'>
	^self state logout
    ]

    lsub: refName mailbox: name [
	<category: 'commands'>
	^self state lsub: refName mailbox: name
    ]

    noop [
	<category: 'commands'>
	^self state noop
    ]

    rename: oldMailBox newName: newMailBox [
	<category: 'commands'>
	^self state rename: oldMailBox newName: newMailBox
    ]

    search: aCriteria [
	<category: 'commands'>
	^self state search: aCriteria
    ]

    select: aMailBoxName [
	<category: 'commands'>
	^self state select: aMailBoxName
    ]

    status: aMailBoxNameWithArguments [
	<category: 'commands'>
	^self state status: aMailBoxNameWithArguments
    ]

    store: args [
	<category: 'commands'>
	^self state store: args
    ]

    subscribe: aMailBoxName [
	<category: 'commands'>
	^self state subscribe: aMailBoxName
    ]

    uid: aString [
	<category: 'commands'>
	^self state uid: aString
    ]

    unsubscribe: aMailBoxName [
	<category: 'commands'>
	^self state unsubscribe: aMailBoxName
    ]

    commandClassFor: cmdName [
	<category: 'create&execute command'>
	^self class commandClassFor: cmdName
    ]

    createCommand: aString [
	<category: 'create&execute command'>
	^self createCommand: aString arguments: nil
    ]

    createCommand: aString arguments: anArray [
	<category: 'create&execute command'>
	^IMAPCommand 
	    forClient: clientPI
	    name: aString
	    arguments: anArray
    ]

    execute: cmd arguments: args changeStateTo: aStateBlock [
	<category: 'create&execute command'>
	^self execute: [self createCommand: cmd arguments: args]
	    changeStateTo: aStateBlock
    ]

    execute: aBlock changeStateTo: aStateBlock [
	<category: 'create&execute command'>
	| command |
	command := aBlock value.
	self executeCommand: command.
	command wait.
	command completedSuccessfully ifTrue: [self state: aStateBlock value].
	^command
    ]

    executeAndWait: aString [
	<category: 'create&execute command'>
	^self executeAndWait: aString arguments: nil
    ]

    executeAndWait: aString arguments: anArray [
	<category: 'create&execute command'>
	| command |
	command := self createCommand: aString arguments: anArray.
	self executeCommand: command.
	command wait.
	^command
    ]

    executeCommand: aCommand [
	<category: 'create&execute command'>
	^self clientPI executeCommand: aCommand
    ]

    canonicalizeMailboxName: aMailboxName [
	"#todo. Mailbox names are encoded in UTF-7 format. Add encoding logic here when available"

	<category: 'private'>
	^aMailboxName
    ]

    messageSetAsString: messageNumbers [
	<category: 'private'>
	| stream |
	stream := (String new: 64) writeStream.
	messageNumbers do: [:messageNumber | stream nextPutAll: messageNumber]
	    separatedBy: [stream nextPut: $,].
	^stream contents
    ]

    handle: aResponse [
	"^aResponse"

	<category: 'responses'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPCommandSequencer [
    | prefix value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPCommandSequencer class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    IMAPCommandSequencer class >> newPrefix: prefix [
	<category: 'instance creation'>
	^(self new)
	    prefix: prefix;
	    yourself
    ]

    next [
	<category: 'accessing'>
	self increment.
	^self prefix , self value printString
    ]

    prefix [
	<category: 'accessing'>
	^prefix
    ]

    prefix: aValue [
	<category: 'accessing'>
	prefix := aValue
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	<category: 'accessing'>
	value := aValue
    ]

    initialize [
	<category: 'initialization'>
	value := 0
    ]

    reset [
	<category: 'initialization'>
	self value: 0
    ]

    increment [
	<category: 'private'>
	self value: self value + 1
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPFetchedItemSectionSpecification [
    | specName parameters span rawContent |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPFetchedItemSectionSpecification class >> readFrom: tokenStream [
	<category: 'instance creation'>
	| specName |
	specName := tokenStream next.
	specName isNil ifTrue: [specName := 'Empty'].
	^((self properSubclassFor: specName) new)
	    specName: specName;
	    readFrom: tokenStream
    ]

    IMAPFetchedItemSectionSpecification class >> canBe: aName [
	<category: 'matching'>
	^#('TEXT' 'MIME') includes: aName asUppercase
    ]

    IMAPFetchedItemSectionSpecification class >> defaultClass [
	<category: 'matching'>
	^IMAPFetchedItemSectionSpecification
    ]

    IMAPFetchedItemSectionSpecification class >> properSubclassFor: aName [
	<category: 'matching'>
	^IMAPFetchedItemSectionSpecification withAllSubclasses 
	    detect: [:each | each canBe: aName]
	    ifNone: [self defaultClass]
    ]

    specName [
	<category: 'accessing'>
	^specName
    ]

    specName: aName [
	<category: 'accessing'>
	specName := aName
    ]

    extractContentFrom: tokenStream [
	"
	 Check for a partial fetch- this would include a range specification given in angle brackets.
	 Otherwise, there should only be a single token containing the requested content.
	 "

	<category: 'content'>
	| peekStream |
	peekStream := tokenStream peek readStream.
	peekStream peek = $< 
	    ifTrue: [self extractSpannedContentSpanFrom: tokenStream]
	    ifFalse: [rawContent := tokenStream next]
    ]

    extractSpannedContentSpanFrom: tokenStream [
	"we've lost some information- we need the bytecount, but it is gone.  Must revisit this!!"

	<category: 'content'>
	| startPoint |
	startPoint := ((tokenStream next readStream)
		    next;
		    upTo: $>) asNumber.
	rawContent := tokenStream next.

	"we're going to try to simply use the length of the raw content as the span length- however, this is not actually correct, though it is close."
	span := startPoint @ rawContent size
    ]

    rawContent [
	<category: 'content'>
	^rawContent
    ]

    readFrom: tokenStream [
	"
	 The section spec will be either numeric (if the message is MIME this is oK) or one of the following:
	 'HEADER'
	 'HEADER.FIELDS'
	 'HEADER.FIELDS.NOT'
	 'MIME'
	 'TEXT'
	 
	 Some examples would be:
	 
	 1
	 1.HEADER
	 
	 HEADER
	 HEADER.FIELDS
	 
	 3.2.3.5.HEADER.FIELDS (to fetch header fields for part 3.2.3.5)
	 "

	"the numeric part could be pulled out at this point as the position spec, followed by the section spec, then followed by optional? parameters."

	"positionSpec := ?"

	<category: 'instance creation'>
	parameters := tokenStream next
    ]

    pvtFullSpan [
	<category: 'span'>
	^0 to: self rawContent size
    ]

    span [
	"Items are not always requested in their entirety.  The span tells us which part of the desired content was retrieved."

	<category: 'span'>
	^span notNil ifTrue: [span] ifFalse: [self pvtFullSpan]
    ]

    span: anInterval [
	"Items are not always requested in their entirety.  The span tells us which part of the desired content was retrieved."

	<category: 'span'>
	span := anInterval
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPResponse [
    | source cmdName value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPResponse class >> defaultResponseClass [
	<category: 'parsing, general'>
	^IMAPResponse
    ]

    IMAPResponse class >> parse: scanner [
	<category: 'parsing, general'>
	| theToken theResponse |
	theToken := scanner nextToken.
	theToken isNil ifTrue: [^nil].

	"
	 IMAP Server responses are classified as either tagged or untagged.
	 Untagged responses begin with either the asterisk or plus sign, while tagged responses begin with the command id.
	 "
	theResponse := (#($* '+') includes: theToken) 
		    ifTrue: [self parseUntagged: scanner withStar: theToken == $*]
		    ifFalse: [self parseTagged: scanner withTag: theToken].
	scanner upTo: Character nl.
	^theResponse
	    source: scanner sourceTrail;
	    yourself
    ]

    IMAPResponse class >> parserForUntaggedResponse: responseName [
	<category: 'parsing, general'>
	| properSubclass |
	properSubclass := IMAPResponse allSubclasses 
		    detect: [:each | each canParse: responseName]
		    ifNone: [self defaultResponseClass].
	^properSubclass new
    ]

    IMAPResponse class >> parserTypeForTaggedStatus: status [
	<category: 'parsing, general'>
	^IMAPResponseTagged
    ]

    IMAPResponse class >> parseTagged: scanner withTag: tag [
	<category: 'parsing, general'>
	| status |
	status := scanner nextToken.
	^(self parserTypeForTaggedStatus: status) 
	    parse: scanner
	    tag: tag
	    status: status
    ]

    IMAPResponse class >> parseContinuationResponse: scanner [
	<category: 'parsing, general'>
	^IMAPContinuationResponse new
    ]

    IMAPResponse class >> parseUntagged: scanner withStar: isStar [
	<category: 'parsing, general'>
	"An untagged responses might be a continuation responses.
	 These begin with the plus sign rather than the asterisk."

	| token token2 |
	isStar ifFalse: [^self parseContinuationResponse: scanner].
	token := scanner nextToken.

	"At this point, we know the response is untagged, but IMAP's untagged responses are not well designed.
	 Some responses provide numeric data first, response or condition name second, while others do it the other way around.
	 What we are doing here is determining what order these things are in, and then doing the parsing accordingly."
	^token first isLetter 
	    ifTrue: [(self parserForUntaggedResponse: token) parse: scanner with: token]
	    ifFalse: 
		[token2 := scanner nextToken.
		(self parserForUntaggedResponse: token2) 
		    parse: scanner
		    forCommandOrConditionNamed: token2
		    withValue: token]
    ]

    IMAPResponse class >> readFrom: stream [
	<category: 'parsing, general'>
	^self parse: (self scannerOn: stream)
    ]

    IMAPResponse class >> scannerOn: stream [
	<category: 'parsing, general'>
	^IMAPScanner on: stream
    ]

    IMAPResponse class >> canParse: responseName [
	<category: 'testing'>
	^false
    ]

    cmdName [
	<category: 'accessing'>
	^cmdName
    ]

    cmdName: aString [
	<category: 'accessing'>
	cmdName := aString
    ]

    source [
	<category: 'accessing'>
	^source
    ]

    source: aString [
	<category: 'accessing'>
	source := aString
    ]

    tag [
	<category: 'accessing'>
	^nil
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	<category: 'accessing'>
	value := aValue
    ]

    parse: scanner [
	<category: 'parsing, general'>
	self value: scanner deepTokenize
    ]

    parse: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue [
	<category: 'parsing, general'>
	self cmdName: commandOrConditionName.
	self value: codeValue.
	self parse: scanner
    ]

    parse: scanner with: commandConditionOrStatusName [
	<category: 'parsing, general'>
	self cmdName: commandConditionOrStatusName.
	self parse: scanner
    ]

    scanFrom: scanner [
	<category: 'parsing, general'>
	self value: scanner deepTokenize
    ]

    scanFrom: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue [
	<category: 'parsing, general'>
	self cmdName: commandOrConditionName.
	self value: codeValue.
	self scanFrom: scanner
    ]

    scanFrom: scanner with: commandConditionOrStatusName [
	<category: 'parsing, general'>
	self cmdName: commandConditionOrStatusName.
	self scanFrom: scanner
    ]

    printLog [
	<category: 'printing'>
	^self source
    ]

    printOn: stream [
	<category: 'printing'>
	source notNil ifTrue: [stream nextPutAll: source]
    ]

    hasTag: aString [
	<category: 'testing'>
	^false
    ]

    isContinuationResponse [
	<category: 'testing'>
	^false
    ]

    isStatusResponse [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPContinuationResponse [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    isContinuationResponse [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPState [
    | client |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPState class >> forClient: client [
	<category: 'instance creation'>
	^self new client: client
    ]

    client [
	<category: 'accessing'>
	^client
    ]

    capability [
	<category: 'any state valid commands'>
	^client executeAndWait: 'capability'
    ]

    logout [
	<category: 'any state valid commands'>
	| command |
	(command := client executeAndWait: 'logout') completedSuccessfully 
	    ifTrue: [client state: IMAPState new].
	^command
    ]

    noop [
	<category: 'any state valid commands'>
	^client executeAndWait: 'noop'
    ]

    append [
	<category: 'commands'>
	self signalError
    ]

    check: aClient [
	<category: 'commands'>
	self signalError
    ]

    close: aClient [
	<category: 'commands'>
	self signalError
    ]

    copy [
	<category: 'commands'>
	self signalError
    ]

    create: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    delete: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    examine: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    expunge: aClient [
	<category: 'commands'>
	self signalError
    ]

    fetch: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    list: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    login: pi [
	<category: 'commands'>
	self signalError
    ]

    lsub: aClient arguments: aLIst [
	<category: 'commands'>
	self signalError
    ]

    rename: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    search: aClient arguments: aLIst [
	<category: 'commands'>
	self signalError
    ]

    select: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    status [
	<category: 'commands'>
	self signalError
    ]

    store: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    subscribe: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    uid: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    unsubscribe: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    signalError [
	<category: 'errors'>
	^WrongStateError signal
    ]

    client: aValue [
	<category: 'initialize-release'>
	client := aValue
    ]

    capability: aClient [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'capability') completedSuccessfully 
	    ifTrue: [command]
	    ifFalse: [false]
    ]

    logout: aClient [
	<category: 'obsolete'>
	| command |
	(command := aClient executeAndWait: 'logout') completedSuccessfully 
	    ifTrue: [aClient state: IMAPState new].
	^command
    ]

    noop: client [
	<category: 'obsolete'>
	| command |
	^(command := client executeAndWait: 'noop') completedSuccessfully 
	    ifTrue: [command]
	    ifFalse: [false]
    ]

    isAuthenticated [
	<category: 'testing'>
	^false
    ]

    isSelected [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPDataResponse [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponse class >> canParse: responseName [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPState subclass: IMAPAuthenticatedState [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    append: message to: aMailboxName flags: flags date: dateString [
	<category: 'commands'>
	| args |
	args := OrderedCollection 
		    with: (client canonicalizeMailboxName: aMailboxName).
	flags notNil ifTrue: [args add: flags].
	dateString notNil ifTrue: [args add: #atom -> dateString].
	args add: #literalString -> message.
	^client executeAndWait: 'append' arguments: args
    ]

    create: aMailboxName [
	<category: 'commands'>
	^client 
	    execute: 'create'
	    arguments: aMailboxName
	    changeStateTo: [IMAPSelectedState new]
    ]

    delete: aMailboxName [
	<category: 'commands'>
	^client executeAndWait: 'delete' arguments: aMailboxName
    ]

    examine: aMailBoxName [
	<category: 'commands'>
	^client 
	    execute: 'examine'
	    arguments: aMailBoxName
	    changeStateTo: [IMAPSelectedState new]
    ]

    list: refName mailbox: name [
	<category: 'commands'>
	^client executeAndWait: 'list' arguments: (Array with: refName with: name)
    ]

    lsub: refName mailbox: name [
	<category: 'commands'>
	^client executeAndWait: 'lsub' arguments: (Array with: refName with: name)
    ]

    rename: oldMailBox newName: newMailBox [
	<category: 'commands'>
	^client executeAndWait: 'rename'
	    arguments: (Array with: oldMailBox with: newMailBox)
    ]

    select: aMailBoxName [
	<category: 'commands'>
	^client 
	    execute: 'select'
	    arguments: aMailBoxName
	    changeStateTo: [IMAPSelectedState new]
    ]

    status: aMailBoxNameWithArguments [
	<category: 'commands'>
	^client executeAndWait: 'status' arguments: aMailBoxNameWithArguments

	"arguments: (Array with: aMailBoxNameWithArguments)"
    ]

    subscribe: aMailBoxName [
	<category: 'commands'>
	^client executeAndWait: 'subscribe' arguments: (Array with: aMailBoxName)
    ]

    unsubscribe: aMailBoxName [
	<category: 'commands'>
	^client executeAndWait: 'unsubscribe' arguments: (Array with: aMailBoxName)
    ]

    create: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'create' arguments: aList) 
	    completedSuccessfully 
		ifTrue: 
		    [aClient state: IMAPSelectedState new.
		    command]
		ifFalse: [false]
    ]

    delete: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'delete' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    examine: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'examine' arguments: aList) 
	    completedSuccessfully 
		ifTrue: 
		    [aClient state: IMAPSelectedState new.
		    command]
		ifFalse: [nil]
    ]

    list: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'list' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    lsub: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'lsub' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    rename: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'rename' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    select: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'select' arguments: aList) 
	    completedSuccessfully 
		ifTrue: 
		    [aClient state: IMAPSelectedState new.
		    command]
		ifFalse: [nil]
    ]

    subscribe: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'subscribe' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    unsubscribe: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'unsubscribe' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    isAuthenticated [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPStatusResponse [
    | text status |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPStatusResponse class >> canParse: commandOrConditionName [
	<category: 'testing'>
	^#('OK' 'NO' 'BAD' 'BYE') includes: commandOrConditionName
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    status: aStatus [
	<category: 'accessing'>
	status := aStatus
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    parse: scanner [
	<category: 'parsing, general'>
	| val key |
	scanner skipWhiteSpace.
	(scanner peekFor: $[) 
	    ifTrue: 
		[self value: OrderedCollection new.
		scanner flagBracketSpecial: true.
		key := scanner nextToken asUppercase.
		(#('UIDVALIDITY' 'UNSEEN') includes: key) 
		    ifTrue: [val := scanner nextToken asNumber].
		'PERMANENTFLAGS' = key ifTrue: [val := scanner deepNextToken].
		'NEWNAME' = key 
		    ifTrue: 
			[| old new |
			old := scanner nextToken.
			new := scanner nextToken.
			val := Array with: old with: new].
		[scanner nextToken ~~ $] and: [scanner tokenType ~= #doIt]] whileTrue.
		scanner flagBracketSpecial: false].
	text := scanner scanText.
	(#('ALERT' 'PARSE' 'TRYCREATE' 'READ-ONLY' 'READ-WRITE') includes: key) 
	    ifTrue: [val := text].
	self value: key -> val
    ]

    parse: scanner with: commandConditionOrStatusName [
	<category: 'parsing, general'>
	self cmdName: commandConditionOrStatusName.
	self status: commandConditionOrStatusName.
	self parse: scanner
    ]

    isBad [
	<category: 'testing, imap'>
	^self status = 'BAD'
    ]

    isNotAccepted [
	<category: 'testing, imap'>
	^self status = 'NO'
    ]

    isOK [
	<category: 'testing, imap'>
	^self status = 'OK'
    ]

    isStatusResponse [
	<category: 'testing, response type'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPCommandCompletionResponse [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodySectionFetchedItem [
    | sectionSpec |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodySectionFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?  This is not as straightforward as it ought to be.
	 IMAPv4 uses 'BODY' fetches in two very different ways, so we will have to be careful about that.
	 For now, we are not making the distinction, so we will have to revisit this in the future.
	 Also, note that we don't include 'RFC822.SIZE'.  Such a fetch does not return anything complex- it's actually just a simple metadata fetch.
	 "

	"^#(
	 'BODY'
	 'BODY.PEEK'
	 'RFC822'
	 'RFC822.HEADER'
	 'RFC822.TEXT'
	 ) includes: aName."

	<category: 'matching'>
	^false
    ]

    sectionSpec [
	<category: 'accessing'>
	^sectionSpec
    ]

    extractContentFrom: tokenStream [
	"
	 For the body parts extraction case, tokens will be something like:
	 $[
	 'HEADER.FIELDS'
	 #('FIELD1' 'FIELD2')
	 $]
	 '...content as described above...'
	 
	 Whereas for the body (structure) case, the tokens will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 
	 What a screwed up spec.
	 "

	"devel thought: It might would be good if the reciever could tell what had been requested, and what had been recieved."

	<category: 'building'>
	| specTokens |
	specTokens := tokenStream
		    upTo: $[;
		    upTo: $].
	(self sectionSpecificationFrom: specTokens) 
	    extractContentFrom: tokenStream
    ]

    sectionSpecificationFrom: tokens [
	<category: 'building'>
	^sectionSpec := IMAPFetchedItemSectionSpecification 
		    readFrom: tokens readStream
    ]

    headerFieldNamed: aName ifAbsent: aBlock [
	"hmm... need a more compex example here."

	<category: 'header fields'>
	self halt
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPState subclass: IMAPNonAuthenticatedState [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    authenticate [
	<category: 'commands'>
	
    ]

    login [
	<category: 'commands'>
	^client 
	    execute: 'login'
	    arguments: (Array with: client user username with: client user password)
	    changeStateTo: [IMAPAuthenticatedState new]
    ]

    login: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	command := aClient executeAndWait: 'login' arguments: aList.
	command completedSuccessfully 
	    ifTrue: [aClient state: IMAPAuthenticatedState new].
	^command
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPMessageEnvelopeFetchedItem [
    | envelope |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPMessageEnvelopeFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?
	 Note that we include 'RFC822.SIZE' .
	 This is just a simple metadata fetch, unlike such things as 'RFC822' or 'RFC822.HEADER' .
	 "

	<category: 'matching'>
	^'ENVELOPE' = aName
    ]

    bccLine [
	<category: 'accessing'>
	^self envelope at: 8
    ]

    ccLine [
	<category: 'accessing'>
	^self envelope at: 7
    ]

    dateLine [
	<category: 'accessing'>
	^self envelope at: 1
    ]

    fromAuthor [
	<category: 'accessing'>
	^(self fromLine at: 1) at: 1
    ]

    fromLine [
	<category: 'accessing'>
	^self envelope at: 3
    ]

    inReplyToLine [
	<category: 'accessing'>
	^self envelope at: 9
    ]

    replyToAuthor [
	<category: 'accessing'>
	^(self replyToLine at: 1) at: 1
    ]

    replyToLine [
	<category: 'accessing'>
	^self envelope at: 5
    ]

    senderAuthor [
	<category: 'accessing'>
	^(self senderLine at: 1) at: 1
    ]

    senderLine [
	<category: 'accessing'>
	^self envelope at: 4
    ]

    subjectLine [
	<category: 'accessing'>
	^self envelope at: 2
    ]

    toLine [
	<category: 'accessing'>
	^self envelope at: 6
    ]

    uniqueMessageIDLine [
	<category: 'accessing'>
	^self envelope at: 10
    ]

    extractContentFrom: tokenStream [
	"the envelope is an array of message metadata- we'll come back to this for interpretation later."

	<category: 'building'>
	self envelope: tokenStream next
    ]

    envelope [
	<category: 'envelope'>
	^envelope
    ]

    envelope: anArray [
	"We have yet to interpret the contents of the given array... we shall need to get to that later."

	<category: 'envelope'>
	envelope := anArray
    ]

    printDevelOn: aStream indent: level [
	<category: 'printing'>
	aStream
	    crtab: level;
	    nextPutAll: 'Date: ';
	    nextPutAll: self dateLine;
	    crtab: level;
	    nextPutAll: 'Subject: ';
	    nextPutAll: self subjectLine;
	    crtab: level;
	    nextPutAll: 'From: ';
	    print: self fromAuthor;
	    crtab: level;
	    nextPutAll: 'Sender: ';
	    print: self senderAuthor;
	    crtab: level;
	    nextPutAll: 'ReplyTo: ';
	    print: self replyToAuthor;
	    crtab: level;
	    nextPutAll: 'To: ';
	    print: self toLine;
	    crtab: level;
	    nextPutAll: 'In Reply To: ';
	    print: self inReplyToLine;
	    crtab: level;
	    nextPutAll: 'Message ID: ';
	    nextPutAll: self uniqueMessageIDLine;
	    crtab: level;
	    nextPutAll: 'Bcc: ';
	    print: self bccLine;
	    crtab: level;
	    nextPutAll: 'Cc: ';
	    print: self ccLine;
	    yourself
    ]

    printOn: aStream [
	<category: 'printing'>
	self printDevelOn: aStream indent: 0
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodyRFC822FetchedItem [
    | value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodyRFC822FetchedItem class >> canBe: aName [
	"
	 Note that we don't include 'RFC822.SIZE'.
	 Such a fetch does not return anything complex- it's actually just a simple metadata fetch.
	 "

	<category: 'matching'>
	^#('RFC822' 'RFC822.HEADER' 'RFC822.TEXT') includes: aName
    ]

    extractContentFrom: tokenStream [
	"
	 Cases:
	 RFC822
	 RFC822.Header
	 RFC822.Text
	 "

	<category: 'building'>
	value := tokenStream next
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPMessageMetadataFetchedItem [
    | value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPMessageMetadataFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?
	 Note that we include 'RFC822.SIZE' .
	 This is just a simple metadata fetch, unlike such things as 'RFC822' or 'RFC822.HEADER' .
	 "

	<category: 'matching'>
	^#('FLAGS' 'INTERNALDATE' 'RFC822.SIZE' 'UID') includes: aName
    ]

    extractContentFrom: tokenStream [
	<category: 'building'>
	self value: tokenStream next
    ]

    value [
	<category: 'value'>
	^value
    ]

    value: anObject [
	<category: 'value'>
	value := anObject
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItemSectionSpecification subclass: IMAPFetchedItemHeaderSectionSpecification [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPFetchedItemHeaderSectionSpecification class >> canBe: aName [
	<category: 'matching'>
	^'HEADER*' match: aName ignoreCase: true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodyStructureFetchedItem [
    | structure |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodyStructureFetchedItem class >> canBe: aName [
	<category: 'matching'>
	^'BODYSTRUCTURE' = aName
    ]

    structure [
	<category: 'accessing'>
	^structure
    ]

    structure: aStructure [
	<category: 'accessing'>
	structure := aStructure
    ]

    extractContentFrom: tokenStream [
	"
	 The structure will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 "

	<category: 'building'>
	self structure: tokenStream next
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodyFetchedItem [
    | parts |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodyFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?  This is not as straightforward as it ought to be.
	 IMAPv4 uses 'BODY' fetches in two very different ways, so we will have to be careful about that.
	 For now, we are not making the distinction, so we will have to revisit this in the future.
	 "

	<category: 'matching'>
	^#('BODY' 'BODY.PEEK') includes: aName
    ]

    extractBodySectionContentFrom: tokenStream [
	<category: 'building'>
	self parts 
	    add: (IMAPBodySectionFetchedItem new extractContentFrom: tokenStream)
    ]

    extractContentFrom: tokenStream [
	"
	 For the body parts extraction case, tokens will be something like:
	 $[
	 'HEADER.FIELDS'
	 #('FIELD1' 'FIELD2')
	 $]
	 '...content as described above...'
	 
	 Whereas for the body (structure) case, the tokens will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 
	 What a screwed up spec.
	 "

	"devel thought: It might would be good if the reciever could tell what had been requested, and what had been recieved."

	"First off, are we talking about a body section fetch, or a short-form body structure fetch? Bastards!!"

	<category: 'building'>
	tokenStream peek = $[ 
	    ifTrue: [self extractBodySectionContentFrom: tokenStream]
	    ifFalse: [self extractShortFormBodyStructureFrom: tokenStream]
    ]

    extractShortFormBodyStructureFrom: tokenStream [
	"
	 Whereas for the body (structure) case, the tokens will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 "

	<category: 'building'>
	self parts 
	    add: (IMAPBodyStructureFetchedItem new extractContentFrom: tokenStream)
    ]

    parts [
	<category: 'parts'>
	^parts notNil ifTrue: [parts] ifFalse: [parts := OrderedCollection new]
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponse subclass: IMAPDataResponseFetch [
    | fetchedItems metaResponses |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseFetch class >> canParse: responseName [
	<category: 'testing'>
	^'FETCH' = responseName

	"^false"
    ]

    bodyFetch [
	<category: 'fetchable items'>
	^self fetchedItemNamed: 'body' ifAbsent: [nil]
    ]

    bodyText [
	<category: 'fetchable items'>
	^(self fetchedItemNamed: 'body') parts first sectionSpec rawContent
    ]

    envelope [
	<category: 'fetchable items'>
	^self fetchedItemNamed: 'envelope' ifAbsent: [nil]
    ]

    extractFetchedItemsFrom: tokenStream [
	<category: 'fetchable items'>
	
	[tokenStream atEnd not 
	    and: [self fetchableItemNames includes: tokenStream peek]] 
		whileTrue: 
		    [(self newFetchedItemNamed: tokenStream next) 
			extractContentFrom: tokenStream]
    ]

    fetchableItemNames [
	<category: 'fetchable items'>
	^#('ALL' 'BODY' 'BODY.PEEK' 'BODYSTRUCTURE' 'ENVELOPE' 'FAST' 'FULL' 'FLAGS' 'INTERNALDATE' 'RFC822' 'RFC822.HEADER' 'RFC822.SIZE' 'RFC822.TEXT' 'UID')	"actually, there are two forms represented by this name- see the spec."
    ]

    fetchedHeaderNamed: aHeaderName ifAbsent: aBlock [
	<category: 'fetchable items'>
	^self headerFetch fieldNamed: aHeaderName ifAbsent: [aBlock value]
    ]

    fetchedItemNamed: aName [
	<category: 'fetchable items'>
	^self fetchedItemNamed: aName ifAbsent: [nil]
    ]

    fetchedItemNamed: aName ifAbsent: aBlock [
	<category: 'fetchable items'>
	| seekName |
	seekName := aName asLowercase.
	^self fetchedItems at: seekName ifAbsent: [aBlock value]
    ]

    fetchedItems [
	<category: 'fetchable items'>
	^fetchedItems notNil 
	    ifTrue: [fetchedItems]
	    ifFalse: [fetchedItems := Dictionary new]
    ]

    hasUID [
	<category: 'fetchable items'>
	^self fetchedItems includesKey: 'uid'
    ]

    hasUniqueMessageID [
	<category: 'fetchable items'>
	^self hasFetchedItemHaving: 'message-ID'
    ]

    itemHolding: anItemName [
	<category: 'fetchable items'>
	^self fetchedItems traverse: [:eachItem | eachItem]
	    seeking: [:eachItem | eachItem holds: anItemName]
    ]

    newFetchedItemNamed: aName [
	<category: 'fetchable items'>
	^self fetchedItems at: aName asLowercase
	    put: (IMAPFetchedItem named: aName)
    ]

    rawUniqueMessageID [
	"If available, answer the unique message ID as provided within the message's headers."

	<category: 'fetchable items'>
	^self bodyFetch headerFieldNamed: 'message-ID' ifAbsent: [nil]
    ]

    uid [
	"The UID is an item that may or not have been fetched by the reciever."

	<category: 'fetchable items'>
	| uidRaw |
	uidRaw := self fetchedItemNamed: 'UID' ifAbsent: [nil].
	^uidRaw notNil ifTrue: [uidRaw value asNumber] ifFalse: [nil]
    ]

    messageNumber [
	<category: 'message number'>
	^self sequenceNumber
    ]

    messageNumber: aNumber [
	<category: 'message number'>
	self sequenceNumber: aNumber
    ]

    messageSequenceNumber [
	<category: 'message number'>
	^self sequenceNumber
    ]

    sequenceNumber [
	<category: 'message number'>
	^self fetchedItemNamed: 'sequence_number'
    ]

    sequenceNumber: aNumber [
	<category: 'message number'>
	^self fetchedItems at: 'sequence_number' put: aNumber
    ]

    metaResponses [
	<category: 'meta responses'>
	^metaResponses
    ]

    metaResponses: statusResponses [
	<category: 'meta responses'>
	metaResponses := statusResponses
    ]

    parse: scanner [
	<category: 'parsing, general'>
	| tokens |
	scanner flagBracketSpecial: true.
	tokens := scanner deepNextToken.
	scanner flagBracketSpecial: false.
	self extractFetchedItemsFrom: tokens readStream
    ]

    value: aNumber [
	<category: 'parsing, general'>
	self sequenceNumber: (value := aNumber)
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPStatusResponse subclass: IMAPResponseMailboxStatus [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPResponseMailboxStatus class >> canParse: conditionName [
	"should be more- I need to check this."

	<category: 'testing'>
	^#('UNSEEN' 'EXISTS') includes: conditionName
    ]

    parse: scanner [
	<category: 'parsing, general'>
	self halt.
	super parse: scanner
    ]

    parse: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue [
	<category: 'parsing, general'>
	self cmdName: commandOrConditionName.
	self value: codeValue
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPStatusResponse subclass: IMAPResponseTagged [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPResponseTagged class >> parse: scanner tag: tag status: status [
	<category: 'parsing, general'>
	^self new 
	    parse: scanner
	    tag: tag
	    status: status
    ]

    IMAPResponseTagged class >> scanFrom: scanner tag: tag status: status [
	<category: 'parsing, general'>
	^self new 
	    scanFrom: scanner
	    tag: tag
	    status: status
    ]

    IMAPResponseTagged class >> canParse: cmdName [
	<category: 'testing'>
	^false
    ]

    tag [
	<category: 'accessing'>
	^self cmdName
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    parse: scanner tag: tag status: statusString [
	<category: 'parsing, general'>
	self cmdName: tag.
	self status: statusString.
	^self parse: scanner
    ]

    hasTag: tagString [
	<category: 'testing'>
	^self tag match: tagString
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponse subclass: IMAPDataResponseSearch [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseSearch class >> canParse: responseName [
	<category: 'testing'>
	^'SEARCH' = responseName
    ]

    basicIDSequences [
	<category: 'id sequences'>
	| intervals currentStart currentStop currentInterval |
	intervals := OrderedCollection new.
	currentInterval := -1 -> -1.
	self numericIDs do: 
		[:eachNumericID | 
		eachNumericID = (currentInterval value + 1) 
		    ifTrue: [currentInterval value: eachNumericID]
		    ifFalse: 
			[currentStop := currentStart := eachNumericID.
			intervals add: (currentInterval := currentStart -> currentStop)]].
	^intervals collect: 
		[:eachInterval | 
		eachInterval key = eachInterval value 
		    ifTrue: [eachInterval key printString]
		    ifFalse: [eachInterval key printString , ':' , eachInterval value printString]]
    ]

    idSequences [
	"
	 This would be a good place to further condense the basic id sequences.
	 Currently we offer a series of ranges, but these ranges could be combined, eg:
	 #('1:123' '231:321'  etc...)
	 could become:
	 #('1:123, 231:321' etc...)
	 This would reduce the number of fetch requests that would be needed to retrieve the messages identified by the search response.
	 "

	<category: 'id sequences'>
	^self basicIDSequences
    ]

    numericIDs [
	<category: 'id sequences'>
	^self rawIDs collect: [:eachRawID | eachRawID asNumber]
    ]

    rawIDs [
	<category: 'id sequences'>
	^self value
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPAuthenticatedState subclass: IMAPSelectedState [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    check [
	<category: 'commands'>
	^client executeAndWait: 'check'
    ]

    close [
	<category: 'commands'>
	^client 
	    execute: 'close'
	    arguments: nil
	    changeStateTo: [IMAPAuthenticatedState new]
    ]

    copy [
	<category: 'commands'>
	
    ]

    expunge [
	<category: 'commands'>
	^client executeAndWait: 'expunge'
    ]

    fetch: aCriteria [
	<category: 'commands'>
	^client executeAndWait: 'fetch' arguments: aCriteria
    ]

    fetch: messageNumbers retrieve: criteria [
	<category: 'commands'>
	| msgString args |
	msgString := client messageSetAsString: messageNumbers.
	args := OrderedCollection with: msgString.
	criteria notNil 
	    ifTrue: 
		[criteria isCharacters 
		    ifTrue: [args add: criteria]
		    ifFalse: [args addAll: criteria]].
	^client executeAndWait: 'fetch' arguments: args
    ]

    search: aCriteria [
	<category: 'commands'>
	^client executeAndWait: 'search' arguments: aCriteria
    ]

    store: args [
	<category: 'commands'>
	^client executeAndWait: 'store' arguments: args
    ]

    uid: aString [
	<category: 'commands'>
	^client executeAndWait: 'uid' arguments: aString
    ]

    check: aClient [
	<category: 'obsolete'>
	^client executeAndWait: 'check'
    ]

    close: aClient [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'close') completedSuccessfully 
	    ifTrue: 
		[aClient state: IMAPAuthenticatedState new.
		command]
	    ifFalse: [nil]
    ]

    expunge: aClient [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'expunge') completedSuccessfully 
	    ifTrue: [command]
	    ifFalse: [nil]
    ]

    fetch: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'fetch' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    search: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'search' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    store: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'store' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    isSelected [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponse subclass: IMAPDataResponseList [
    | mbAttributes mbDelimiter mbName |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseList class >> canParse: cmdName [
	<category: 'testing'>
	^'LIST' = cmdName
    ]

    mbAttributes [
	<category: 'accessing'>
	^mbAttributes
    ]

    mbDelimeter [
	<category: 'accessing'>
	^mbDelimiter
    ]

    mbName [
	<category: 'accessing'>
	^mbName
    ]

    parse: scanner [
	"Parse message attributes"

	"(\NOSELECT)  '/'  ~/Mail/foo"

	<category: 'parsing, general'>
	| tokens |
	tokens := scanner deepTokenize.
	mbAttributes := tokens at: 1.
	mbDelimiter := tokens at: 2.
	mbName := tokens at: 3
    ]
]

]



Namespace current: NetClients.IMAP [

MIME.MailScanner subclass: IMAPScanner [
    | flagBracketSpecial |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    TextMask := nil.
    QuotedTextMask := nil.
    QuotedPairChar := nil.
    AtomMask := nil.

    IMAPScanner class >> atomSpecials [
	"These characters cannot occur inside an atom"

	<category: 'character classification'>
	^'( ){%*"\'
    ]

    IMAPScanner class >> specials [
	<category: 'character classification'>
	^self atomSpecials
    ]

    IMAPScanner class >> initClassificationTable [
	<category: 'class initialization'>
	super initClassificationTable.
	self initClassificationTableWith: TextMask when: [:c | c ~~ Character cr].
	self initClassificationTableWith: AtomMask
	    when: [:c | c > Character space and: [(self atomSpecials includes: c) not]].
	self initClassificationTableWith: QuotedTextMask
	    when: [:c | c ~~ $" and: [c ~~ $\ and: [c ~~ Character cr]]]
    ]

    IMAPScanner class >> initialize [
	"IMAPScanner initialize"

	<category: 'class initialization'>
	self
	    initializeConstants;
	    initClassificationTable
    ]

    IMAPScanner class >> initializeConstants [
	<category: 'class initialization'>
	AtomMask := 256.
	QuotedTextMask := 4096.
	TextMask := 8192
    ]

    IMAPScanner class >> defaultTokenType [
	<category: 'printing'>
	^#string
    ]

    IMAPScanner class >> printAtom: atom on: stream [
	<category: 'printing'>
	atom isNil 
	    ifTrue: [stream nextPutAll: 'NIL']
	    ifFalse: [stream nextPutAll: atom	"asUppercase"]
    ]

    IMAPScanner class >> printIMAPString: value on: stream [
	"Print string as either atom or quoted text"

	<category: 'printing'>
	value isNil ifTrue: [self printNilOn: stream].
	(self shouldBeQuoted: value) 
	    ifTrue: [self printQuotedText: value on: stream]
	    ifFalse: [self printAtom: value on: stream]
    ]

    IMAPScanner class >> printLiteralString: aString on: stream [
	"Note that this method is good for printing but not for sending.
	 IMAP requires sender to send string length, then wait for continuation response"

	<category: 'printing'>
	self printLiteralStringLength: aString on: stream.
	self printLiteralStringContents: aString on: stream
    ]

    IMAPScanner class >> printLiteralStringContents: aString on: stream [
	<category: 'printing'>
	stream nextPutAll: aString
    ]

    IMAPScanner class >> printLiteralStringLength: aString on: stream [
	<category: 'printing'>
	stream nextPut: ${.
	aString size printOn: stream.
	stream
	    nextPut: $};
	    nl
    ]

    IMAPScanner class >> printNilOn: stream [
	<category: 'printing'>
	stream nextPutAll: 'NIL'
    ]

    IMAPScanner class >> printParenthesizedList: arrayOfAssociations on: stream [
	"In order to accurately print parenthesized list, we need to know
	 token types of every element. This is applied recursively"

	<category: 'printing'>
	stream nextPut: $(.
	self printTokenList: arrayOfAssociations on: stream.
	stream nextPut: $)
    ]

    IMAPScanner class >> printToken: value tokenType: aSymbol on: stream [
	<category: 'printing'>
	aSymbol = #string ifTrue: [^self printIMAPString: value on: stream].
	aSymbol = #literalString 
	    ifTrue: [^self printLiteralString: value on: stream].
	aSymbol = #atom ifTrue: [^self printAtom: value on: stream].
	aSymbol = #quotedText ifTrue: [^self printQuotedText: value on: stream].
	aSymbol = #nil ifTrue: [^self printNilOn: stream].
	aSymbol = #parenthesizedList 
	    ifTrue: [^self printParenthesizedList: value on: stream].	"Invalid token type"
	aSymbol = #special ifTrue: [^stream nextPut: value].
	self halt
    ]

    IMAPScanner class >> stringAsAssociation: string [
	<category: 'printing'>
	(self shouldBeQuoted: string) ifFalse: [^#atom -> string].
	(string first == $\ and: 
		[string size > 1 
		    and: [self shouldBeQuoted: (string copyFrom: 2 to: string size) not]]) 
	    ifTrue: [^#atom -> string].
	^#quotedText -> string
    ]

    IMAPScanner class >> tokenAsAssociation: token [
	<category: 'printing'>
	(token isKindOf: Association) ifTrue: [^token].
	token isNil ifTrue: [^'NIL'].
	token isCharacters ifTrue: [^self stringAsAssociation: token].
	(token isKindOf: Number) ifTrue: [^#number -> token].
	token isSequenceable ifTrue: [^#parenthesizedList -> token].
	^token
    ]

    IMAPScanner class >> isAtomChar: char [
	<category: 'testing'>
	^((self classificationTable at: char asInteger + 1) bitAnd: AtomMask) ~= 0
    ]

    IMAPScanner class >> shouldBeQuoted: string [
	<category: 'testing'>
	^(string detect: [:char | (self isAtomChar: char) not] ifNone: [nil]) 
	    notNil
    ]

    flagBracketSpecial [
	<category: 'accessing'>
	flagBracketSpecial isNil ifTrue: [flagBracketSpecial := false].
	^flagBracketSpecial
    ]

    flagBracketSpecial: aBoolean [
	<category: 'accessing'>
	flagBracketSpecial := aBoolean
    ]

    doSpecialScanProcessing [
	"Hacks that require special handling of IMAP tokens go here.
	 The most frustrating one for us was handling of message/mailbox flags that have format \<atom> as
	 in \Seen. The problem is that $\ is not an atom-char, so these flags are tokenized as #($\ 'Seen').
	 We make heuristical decision here if current token is $\ immediately followed by a letter. We will
	 then read next token and merge $\ and next token answering a string. This is ONLY applied inside a
	 parenthesized list"

	<category: 'multi-character scans'>
	(token == $\ 
	    and: [(self classificationMaskFor: self peek) anyMask: AlphabeticMask]) 
		ifTrue: 
		    [self nextToken.
		    token := '\' , token.
		    tokenType := #string]
    ]

    scanAtom [
	"atom = 1*<any CHAR except atom-specials (which includes atomSpecials, space and CTLs)>"

	<category: 'multi-character scans'>
	token := self scanWhile: 
			[(self isBracketSpecial: hereChar) not 
			    and: [self matchCharacterType: AtomMask]].
	(token match: 'NIL') 
	    ifTrue: 
		["RFC2060 defines NIL as a special atom type, atoms are not case-sensitive"

		token := nil.
		tokenType := #nil]
	    ifFalse: [tokenType := #atom].
	^token
    ]

    scanLiteralText [
	"<{> nnn <}> <CRLF> <nnn bytes>"

	<category: 'multi-character scans'>
	| nbytes string |
	nbytes := self scanLiteralTextLength.
	string := self nextBytesAsString: nbytes.
	token := string 
		    copyReplaceAll: (String with: Character cr with: Character nl)
		    with: (String with: Character nl).
	tokenType := #literalString.
	^token
    ]

    scanLiteralTextLength [
	"<{> nnn <}> <CRLF>"

	"We are positioned at the first brace character"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: [self matchCharacterType: DigitMask]
		    delimitedBy: '{}'
		    notify: 'Malformed literal length'.
	self upTo: Character nl.
	^Integer readFrom: token readStream
    ]

    scanParenthesizedList [
	<category: 'multi-character scans'>
	| stream |
	stream := (Array new: 4) writeStream.
	self mustMatch: $( notify: 'Parenthesized list should begin with ('.
	self deepTokenizeUntil: [token == $)]
	    do: 
		[self doSpecialScanProcessing.
		stream nextPut: token].
	token ~~ $) ifTrue: [self notify: 'Non-terminated parenthesized list'].
	token := stream contents.
	tokenType := #parenthesizedList.
	^token
    ]

    scanParenthesizedListAsAssociation [
	<category: 'multi-character scans'>
	| stream |
	stream := (Array new: 4) writeStream.
	self mustMatch: $( notify: 'Parenthesized list should begin with ('.
	self deepTokenizeAsAssociationUntil: [token == $)]
	    do: 
		[:assoc | 
		self doSpecialScanProcessing.
		stream nextPut: tokenType -> token].
	token ~~ $) ifTrue: [self notify: 'Non-terminated parenthesized list'].
	token := stream contents.
	tokenType := #parenthesizedList.
	^tokenType -> token
    ]

    scanQuotedChar [
	"Scan possible quoted character. If the current char is $\, read in next character and make it a quoted
	 string character"

	<category: 'multi-character scans'>
	^hereChar == $\ 
	    ifTrue: 
		[self step.
		classificationMask := QuotedTextMask.
		true]
	    ifFalse: [false]
    ]

    scanQuotedText [
	"quoted-string = <"

	"> *(quoted_char / quoted-pair) <"

	">
	 quoted_char    =  <any CHAR except <"

	"> and <\>"

	"We are positioned at the first double quote character"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: 
			[self
			    scanQuotedChar;
			    matchCharacterType: QuotedTextMask]
		    delimitedBy: '""'
		    notify: 'Unmatched quoted text'.
	tokenType := #quotedText.
	^token
    ]

    scanText [
	"RFC822: text = <Any CHAR, including bare CR & bare LF, but not including CRLF. This is a 'catchall' category and cannot be tokenized. Text is used only to read values of unstructured fields"

	<category: 'multi-character scans'>
	^self
	    skipWhiteSpace;
	    scanWhile: [(self matchCharacterType: CRLFMask) not]
    ]

    printLiteralString: aString on: stream [
	<category: 'printing'>
	self class printLiteralStringLength: aString on: stream.
	self class printLiteralStringContents: aString on: stream
    ]

    isBracketSpecial: char [
	<category: 'private'>
	^self flagBracketSpecial and: ['[]' includes: char]
    ]

    nextBytesAsString: nbytes [
	<category: 'private'>
	| str |
	^source isExternalStream 
	    ifTrue: 
		[
		[self binary.
		str := (source next: nbytes) asString.
		self sourceTrailNextPutAll: str.
		str] 
			ensure: [self text]]
	    ifFalse: [super next: nbytes]
    ]

    nextIMAPToken [
	<category: 'private'>
	| char |
	self skipWhiteSpace.
	char := self peek.
	char isNil 
	    ifTrue: 
		["end of input"

		tokenType := #doIt.
		^token := nil].
	char == $" ifTrue: [^self scanQuotedText].
	char == ${ ifTrue: [^self scanLiteralText].
	(char < Character space 
	    or: [(self specials includes: char) or: [self isBracketSpecial: char]]) 
		ifTrue: 
		    ["Special character. Make it token value and set token type"

		    tokenType := #special.
		    token := self next.
		    ^token].
	(self matchCharacterType: AtomMask) ifTrue: [^self scanAtom].
	tokenType := #doIt.
	token := char.
	^token
    ]

    deepNextToken [
	<category: 'tokenization'>
	^self nextToken == $( 
	    ifTrue: 
		[self
		    stepBack;
		    scanParenthesizedList]
	    ifFalse: [token]
    ]

    deepNextTokenAsAssociation [
	<category: 'tokenization'>
	^self nextToken == $( 
	    ifTrue: 
		[self
		    stepBack;
		    scanParenthesizedListAsAssociation]
	    ifFalse: [tokenType -> token]
    ]

    deepTokenize [
	<category: 'tokenization'>
	| stream |
	stream := (Array new: 4) writeStream.
	
	[self deepNextToken.
	tokenType = #doIt or: [token == Character cr or: [token == Character nl]]] 
		whileFalse: [stream nextPut: token].
	token == Character cr ifTrue: [self stepBack].
	token == Character nl ifTrue: [self stepBack].
	^stream contents
    ]

    deepTokenizeAsAssociation [
	<category: 'tokenization'>
	| stream assoc |
	stream := (Array new: 4) writeStream.
	
	[assoc := self deepNextTokenAsAssociation.
	assoc key = #doIt] 
		whileFalse: [stream nextPut: assoc].
	^stream contents
    ]

    deepTokenizeAsAssociationUntil: aBlock do: actionBlock [
	<category: 'tokenization'>
	| assoc |
	
	[self skipWhiteSpace.
	assoc := self deepNextTokenAsAssociation.
	assoc key = #doIt or: aBlock] 
		whileFalse: [actionBlock value: assoc]
    ]

    deepTokenizeUntil: aBlock do: actionBlock [
	<category: 'tokenization'>
	
	[self
	    skipWhiteSpace;
	    deepNextToken.
	tokenType == #doIt or: aBlock] 
		whileFalse: [actionBlock value]
    ]

    nextToken [
	<category: 'tokenization'>
	^self nextIMAPToken
    ]

    specials [
	<category: 'tokenization'>
	^self class atomSpecials
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponseList subclass: IMAPDataResponseLSub [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseLSub class >> canParse: cmdName [
	<category: 'testing'>
	^'LSUB' = cmdName
    ]
]

]



Namespace current: NetClients.IMAP [
    IMAPCommand initialize.
    IMAPScanner initialize
]

