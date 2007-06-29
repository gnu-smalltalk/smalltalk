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
| The rest is copyright 2002 Free Software Foundation, Inc.
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



Namespace current: NetClients!
NetClients at: #LineEndCR put: #cr!
NetClients at: #LineEndLF put: #nl!
NetClients at: #LineEndCRLF put: #crnl!
NetClients at: #LineEndTransparent put: #yourself!

Object subclass:  #NetUser
	instanceVariableNames: 'username password '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

NetUser comment: 
'Instances of this class hold the username and password used to login to a mail server.

Instance Variables:
	username	<String>		username string
	password	<String>		password string'!

Object subclass:  #NetEnvironment
	instanceVariableNames: 'debugStream debugCategories debugClasses trace logFileName '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

NetEnvironment class
	instanceVariableNames: 'uniqueInstance'!

NetEnvironment comment: 
nil!

 
Object subclass:  #NetClient
    instanceVariableNames: 'hostName portNumber user reporter clientPI '
    classVariableNames: ''
    poolDictionaries: 'TCP '
    category: 'NetClients-Framework'!

NetClient comment: 
nil!

Object subclass:  #NetProtocolInterpreter
	instanceVariableNames: 'client connectionStream '
	classVariableNames: ''
	poolDictionaries: 'TCP '
	category: 'NetClients-Framework'!

NetClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

Object subclass:  #NetResponse
	instanceVariableNames: 'status statusMessage '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

NetResponse comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

Object subclass:  #Reporter
        instanceVariableNames: 'totalByte readByte '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'NetClients-URIResolver'!

Reporter comment:
nil!

Reporter subclass:  #PluggableReporter
	instanceVariableNames: 'startTime currentTime totalByte readByte statusBlock '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

PluggableReporter comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

Stream subclass:  #RemoveDotStream
	instanceVariableNames: 'stream ch atStart '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

RemoveDotStream comment: 
nil!

Stream subclass:  #PrependDotStream
	instanceVariableNames: 'stream atStart '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

PrependDotStream comment: 
'A PrependDotStream removes a dot to each line starting with a dot, and
ends when its input has a lonely dot.'!

Stream subclass:  #CrLfStream
	instanceVariableNames: 'stream readStatus eatLf '
	classVariableNames: 'Lf Cr '
	poolDictionaries: ''
	category: 'NetClients-Framework'!

CrLfStream comment: 
'A CrLfStream acts as a pipe which transforms incoming data into LF-separated
lines, and outgoing data into CRLF-separated lines.'!

Error subclass:  #NetClientError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

NetClientError comment: 
nil!


NetClientError subclass:  #ConnectionFailedError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

ConnectionFailedError comment: 
nil!


NetClientError subclass:  #ConnectionClosedError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

ConnectionClosedError comment: 
nil!


NetClientError subclass:  #ProtocolError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

ProtocolError comment: 
nil!


NetClientError subclass:  #LoginIncorrectError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-Framework'!

LoginIncorrectError comment: 
nil!


!NetUser class methodsFor: 'instance creation'!

username: aUsername password: aPassword
	"NetUser username: 'foo' password: 'foo'"

	|user|
	user := self new.
	^user 
		username: aUsername;
		password: aPassword
		yourself! !

!NetUser methodsFor: 'accessing'!

password
	^password!

password: aString 
	password := aString!

username
	^username!

username: aString 
	username := aString! !


!NetEnvironment class methodsFor: 'accessing'!

default

	^uniqueInstance isNil
		ifTrue: [ uniqueInstance := self new ]
		ifFalse: [ uniqueInstance ].! !

!NetEnvironment methodsFor: 'accessing'!

debugCategories

	debugCategories isNil
		ifTrue: [ debugCategories := Set new.
				debugCategories add: #general ].

	^debugCategories!

debugClasses

	^debugClasses isNil
		ifTrue: [ debugClasses  := Set new.]
		ifFalse: [ debugClasses ].!

debugStream

	^debugStream!

debugStream: aStream

	debugStream := aStream!

logFileName

	logFileName isNil
		ifTrue: [ logFileName  := 'NetClientLog.txt'].
	^ logFileName!

logFileName: aString

	logFileName := aString!

trace

	trace isNil
		ifTrue: [ trace := false].
	^ trace!

trace: aBoolean

	 trace := aBoolean! !

!NetEnvironment methodsFor: 'debugging'!

debug: aBlock level: aLevel
	( self trace and: [ self debugCategories includes: aLevel ] ) ifTrue: [ aBlock value]!

log: aStringOrBlock
	
	self log: aStringOrBlock level: #general!

log: aStringOrBlock level: aLevel
	| stream i briefMsg aMsg |

	self 
		debug:
			[(stream := self debugStream) == nil ifTrue: [^self].
			(aStringOrBlock isKindOf: BlockClosure)
				ifTrue: [ aMsg := aStringOrBlock value]
				ifFalse: [ aMsg := aStringOrBlock ].
			i := aMsg size.
			[i > 0 and: [(aMsg at: i) isSeparator]] whileTrue: [i := i - 1].
			briefMsg := aMsg copyFrom: 1 to: i.
			stream cr; nextPutAll: briefMsg; flush]
		level: aLevel!

printTrace: aString
	| stream |
	(stream := self debugStream) == nil ifTrue: [^self].
	stream cr; cr; nextPutAll: ' **** ' asString.
	Date today printOn: stream.
	stream nextPutAll: ' '.	
	Time now printOn: stream.
	stream nextPutAll: ' ', aString, ' ****'; flush.!

traceOff

	self printTrace: 'Stop Trace'.
	self trace: false.!

traceOn

	self trace: true.
	self printTrace: 'Start Trace'.! !

!NetEnvironment methodsFor: 'private'!

addDebugCategory: symbol 

	self debugCategories add: symbol!

removeDebugCategory: symbol 

	self debugCategories remove: symbol!

reset

	self resetDebugClasses.
	self resetDebugCategories.!

resetDebugCategories

	debugCategories := nil!

resetDebugClasses

	debugClasses := nil! !

!NetEnvironment methodsFor: 'registration'!

addToDebug: aClass

	self debugClasses add: aClass.! !


!NetClient class methodsFor: 'instance creation'!

connectToHost: aHostname 
    ^self new connectToHost: aHostname port: nil!

connectToHost: aHostname port: aPort
    ^self new connectToHost: aHostname port: aPort!

loginToHost: aHostName asUser: userString withPassword: passwdString 
    ^self loginToHost: aHostName port: nil asUser: userString withPassword: passwdString!

loginToHost: aHostName port: aNumber asUser: userString withPassword: passwdString 
    ^self new
        loginToHost: aHostName 
        port: aNumber 
        asUser: userString 
        withPassword: passwdString!

loginUser: userString withPassword: passwdString 
    ^self loginUser: userString withPassword: passwdString! !

!NetClient methodsFor: 'accessing'!

user
    ^user!

user: aNetUser
    user := aNetUser!

username
    ^user username!

password
    ^user password!

username: usernameString password: passwdString
    user := NetUser username: usernameString password: passwdString!

clientPI
    ^clientPI!

clientPI: aProtocolInterpreter 
    clientPI := aProtocolInterpreter!

hostName
    ^hostName!

hostName: aString
    hostName := aString!

password

    ^self user password!

portNumber

    portNumber isNil ifTrue: [ ^self protocolInterpreter defaultPortNumber ].
    portNumber = 0 ifTrue: [ ^self protocolInterpreter defaultPortNumber ].
    ^portNumber!

portNumber: aNumber
    portNumber := aNumber!

reporter
    reporter isNil ifTrue: [ reporter := Reporter new ].
    ^reporter!

reporter: aReporter
    reporter := aReporter! !

!NetClient methodsFor: 'abstract'!

protocolInterpreter
    self subclassResponsibility! !

!NetClient methodsFor: 'connection'!

close
    ^self logout!

connect
    self connectToHost: self hostName port: self portNumber!

connectIfClosed
    self clientPI closed 
        ifTrue: [self connect ]!

connectToHost: aString
    "Establish a connection to the host <aString>."

    ^self connectToHost: aString port: nil!

connectToHost: aString port: aNumber 
    "Establish a connection to the host <aString>."

    self hostName: aString.
    self portNumber: aNumber.
    self clientPI: (self protocolInterpreter client: self).
    self clientPI connect!

login
!

logout
!

loginToHost: aHostName asUser: userString withPassword: passwdString 
    ^self
        loginToHost: aHostName
        port: nil
        asUser: userString
        withPassword: passwdString!

loginToHost: aHostName port: aNumber asUser: userString withPassword: passwdString 
    | resp |
    hostName := aHostName.
    portNumber := aNumber.
    self username: userString password: passwdString.
    self connect.
    (resp := self login) completedSuccessfully ifFalse: [ ^nil]!

reconnect
    self clientPI close.
    self connect! !

!NetProtocolInterpreter class methodsFor: 'debugging'!

log: aString level: aLevel

        NetEnvironment default log: aString level: aLevel!

registerToDebug

        NetEnvironment default addToDebug: self! !

!NetProtocolInterpreter class methodsFor: 'instance creation'!

client: aNetClient
    ^self new client: aNetClient!

new
    ^self basicNew initialize! !

!NetProtocolInterpreter methodsFor: 'accessing'!

client
    ^client!

reporter
    ^self client reporter!

receiveMessageUntilPeriod
    "Receive and answer a message until period line."

    | write |
    write := WriteStream on: (String new: 4 * 1024).
    self receiveMessageUntilPeriodInto: write.
    ^write contents!

receiveMessageUntilPeriodInto: aStream
    "Receive a message until period line into aStream."

    self connectIfClosed.
    MIME.MimeEntity new parseSimpleBodyFrom: self onto: aStream!

sendMessageWithPeriod: aStream
    "Send aStream as a message with period."

    self connectIfClosed.
    (PrependDotStream to: self)
	nextPutAll: aStream;
	flush
!

skipMessageUntilPeriod
    "Skip a message until period line."

    self connectIfClosed.
    MIME.MimeEntity new skipSimpleBodyFrom: self! !

!NetProtocolInterpreter methodsFor: 'connection'!

binary
    connectionStream class == CrLfStream
	ifTrue: [ connectionStream := connectionStream stream ]
!

isBinary
    ^connectionStream class ~~ CrLfStream
!

text
    self binary.
    self lineEndConvention = LineEndCRLF ifTrue: [
	connectionStream := CrLfStream on: connectionStream ].
!

close
    self closed ifFalse: [connectionStream close. connectionStream := nil].

    self liveAcrossSnapshot
    	ifTrue: [ObjectMemory removeDependent: self].!

closed
    ^connectionStream == nil!

connectionStream
    ^connectionStream!

connectionStream: aSocket
    connectionStream := aSocket.
    self text.
    self liveAcrossSnapshot
    	ifTrue: [ObjectMemory addDependent: self]!

connect
    | connection messageText |
    connection := [ Socket remote: client hostName port: client portNumber ]
	on: Error
	do: [ :ex | ex. messageText := ex messageText. ex return: nil ].

    connection isNil ifTrue: [^self connectionFailedError: messageText].
    self connectionStream: connection!

connectIfClosed
    self closed ifTrue: [self connect].!

reconnect
    self close; connect! !

!NetProtocolInterpreter methodsFor: 'encoding'!

decode: aString
    ^aString!

encode: aString
    ^aString! !

!NetProtocolInterpreter methodsFor: 'initialize-release'!

client: aNetClient
    client := aNetClient!

initialize!

release
    self close.! !

!NetProtocolInterpreter methodsFor: 'private'!

checkResponse
    self checkResponse: self getResponse
!

checkResponse: response
    self
	checkResponse: response
        ifError: [self protocolError: response statusMessage]!

checkResponse: reponse ifError: errorBlock
!

connectionClosedError: messageText
    ^ConnectionClosedError new
	tag: messageText;
	signal: 'Connection closed: ', messageText!

connectionFailedError: messageText
    ^ConnectionFailedError new
	tag: messageText;
	signal: 'Connection failed: ', messageText!

getResponse
    ^self class defaultResponseClass fromClient: self!

loginIncorrectError: messageText
    ^LoginIncorrectError new
	tag: messageText;
	signal: 'Login incorrect: ', messageText!

protocolError: messageText
    ^ProtocolError new
	tag: messageText;
	signal: 'Protocol error: ', messageText! !

!NetProtocolInterpreter class methodsFor: 'private-attributes'!

defaultPortNumber
    ^nil!

defaultResponseClass
    ^NetResponse!

!NetProtocolInterpreter methodsFor: 'private-attributes'!

lineEndConvention
    ^LineEndCRLF!

liveAcrossSnapshot
    ^false! !

!NetProtocolInterpreter methodsFor: 'stream accessing'!

atEnd
    ^connectionStream atEnd!

contents
    ^self decode: connectionStream contents.!

cr
    | conv |
    conv := self lineEndConvention.
    (conv = LineEndCR or: [conv = LineEndTransparent])
    	ifTrue: [^connectionStream nextPut: Character cr].
    conv = LineEndLF
    	ifTrue: [^connectionStream nextPut: Character nl].
    conv = LineEndCRLF
    	ifTrue: [^connectionStream nextPut: Character cr; nextPut: Character nl].

    self error: 'Undefined line-end convention'.!

flush
    connectionStream flush!

next
    ^connectionStream next!

next: anInteger
    ^self decode: (connectionStream next: anInteger).!

nextAvailable: anInteger
    ^self decode: (connectionStream nextAvailable: anInteger).!

nextLine
    | write byte |
    write := WriteStream on: (String new: 128).
    [connectionStream atEnd] whileFalse: [
    	byte := connectionStream next.
    	byte == Character cr ifTrue:
    		[connectionStream peekFor: Character nl.
		 ^self decode: write contents].
    	byte == Character nl ifTrue:
    		[^self decode: write contents].
    	write nextPut: byte].
    ^self decode: write contents!

nextPut: aCharacter
    connectionStream nextPutAll: (self encode: (String with: aCharacter))!

nextPutAll: aString
    aString isEmpty ifTrue: [^self].
    connectionStream nextPutAll: (self encode: aString)!

nl
    | conv |
    conv := self lineEndConvention.
    conv = LineEndCR
    	ifTrue: [^connectionStream nextPut: Character cr].
    (conv = LineEndLF or: [conv = LineEndTransparent])
    	ifTrue: [^connectionStream nextPut: Character nl].
    conv = LineEndCRLF
    	ifTrue: [^connectionStream nextPut: Character cr; nextPut: Character nl].

    self error: 'Undefined line-end convention'.!

species
    ^connectionStream species!

upTo: aCharacter
    | byte |
    aCharacter = Character cr ifTrue: [^self nextLine].
    byte := self encode: (String with: aCharacter).
    byte size = 1
    	ifTrue:	[^self decode: (connectionStream upTo: byte)]
    	ifFalse:	[^self decode: (connectionStream upToAll: byte)]! !

!NetProtocolInterpreter methodsFor: 'updating'!

update: aSymbol
    "Dependents of ObjectMemory are sent update: 
    #returnFromSnapshot when a snapshot is started."

    self liveAcrossSnapshot
    	ifTrue:
    		[aSymbol == #returnFromSnapshot
    			ifTrue: [self close].
    		"(aSymbol == #aboutToSnapshot or: [aSymbol == #aboutToQuit])
    			ifTrue: [self close]."].

    super update: aSymbol! !


!NetResponse class methodsFor: 'instance creation'!

fromClient: aClient
    | response |
    response := self new.
    response parseResponse: aClient.
    ^response! !

!NetResponse methodsFor: 'accessing'!

status
    ^status!

status: anInteger
    status := anInteger!

statusArray
    | n array |
    status == nil ifTrue: [n := 0] ifFalse: [n := status].
    array := Array new: 3.
    array at: 1 put: (n // 100).
    n := n - ((n // 100) * 100).
    array at: 2 put: (n // 10).
    n := n - ((n // 10) * 10).
    array at: 3 put: n.
    ^array!

statusMessage
    ^statusMessage!

statusMessage: aString
    statusMessage := aString! !

!NetResponse methodsFor: 'parsing'!

parseResponse: aClient
    self parseStatusLine: aClient! !

!NetResponse methodsFor: 'printing'!

printOn: aStream
    self printStatusOn: aStream!

printStatusOn: aStream
    status notNil
    	ifTrue: [aStream print: status; space].
    statusMessage notNil
    	ifTrue: [aStream nextPutAll: statusMessage].! !

!NetResponse methodsFor: 'private'!

parseStatusLine: aClient
    | stream |
    statusMessage := nil.
    [stream := aClient nextLine readStream.
    status := Integer readFrom: stream.
    stream next = $-]
    	whileTrue:
    		[statusMessage == nil
    			ifTrue:	[statusMessage := stream upToEnd]
    			ifFalse:	[statusMessage := statusMessage, (String with: Character cr), stream upToEnd]].
    stream skipSeparators.
    statusMessage == nil
    	ifTrue:	[statusMessage := stream upToEnd]
    	ifFalse:	[statusMessage := statusMessage, (String with: Character cr), stream upToEnd]! !


!Reporter methodsFor: 'accessing'!

readByte
    ^readByte!

readByte: aValue
    readByte := aValue! !

!Reporter methodsFor: 'api'!

endTransfer
    ^self!

startTransfer
    ^self!

statusString: aString
    ^self!

totalByte
    ^totalByte!

totalByte: aNumber
    totalByte := aNumber! !

!PluggableReporter class methodsFor: 'instance creation'!

statusBlock: aBlock
    ^self new statusBlock: aBlock! !

!PluggableReporter methodsFor: 'accessing'!

endTransfer
    self statusString: 'Transferring: Done.'!

readByte: anInteger
    readByte := readByte + anInteger.
    currentTime := Time millisecondClockValue.
    self statusString: self progressStatusString.!

startTransfer
    readByte := 0.
    startTime := currentTime := Time millisecondClockValue.
    self statusString: 'Transferring: Start.'!

statusString: statusString
    statusBlock isNil ifTrue: [^self].
    statusBlock value: statusString.!

totalByte: anInteger
    totalByte := anInteger! !

!PluggableReporter methodsFor: 'private'!

progressStatusString
    | stream |
    stream := WriteStream on: (String new: 128).
    stream print: readByte.
    totalByte == nil ifFalse: [stream nextPut: $/; print: totalByte].
    stream nextPutAll: ' bytes'.
    currentTime = startTime
    	ifFalse:
    		[stream nextPutAll: ' ('.
    		(readByte / (currentTime - startTime)) asFloat printOn: stream digits: 2.
    		stream nextPutAll: ' Kbytes/sec)'].
    ^stream contents!

statusBlock: aBlock
    statusBlock := aBlock! !



!RemoveDotStream class methodsFor: 'instance creation'!

on: aStream
     ^self new initialize: aStream
! !

!RemoveDotStream methodsFor: 'input'!

atEnd
    ch isNil ifFalse: [ ^false ].
    stream isNil ifTrue: [ ^true ].
    stream atEnd ifTrue: [ stream := nil. ^true ].

    ch := stream next.
    (atStart and: [ ch == $. ])
	ifFalse: [
	    atStart := (ch == Character cr or: [ ch == Character nl ]).
	    ^false ].

    atStart := false.

    "Found dot at start of line, discard it"
    stream atEnd ifTrue: [ stream := ch := nil. ^true ].
    ch := stream next.

    "Found lonely dot, we are at end of stream"
    (ch == Character cr or: [ ch == Character nl ])
	ifTrue: [
	    ch == Character cr ifTrue: [ stream next ].
	    stream := ch := nil.
	    ^true ].

    ^false
!

next
    | answer |
    self atEnd ifTrue: [
        self error: 'end of stream reached'
    ].
    answer := ch.
    ch := nil.
    ^answer
!

peek
    self atEnd ifTrue: [ ^nil ].
    ^ch
!

peekFor: aCharacter
    self atEnd ifTrue: [ ^false ].
    ch == aCharacter ifTrue: [ self next. ^true ].
    ^false
! !

!RemoveDotStream methodsFor: 'private'!

initialize: aStream
    stream := aStream.
    atStart := true.
    self atEnd.
!

species
    ^stream species
! !



!PrependDotStream class methodsFor: 'instance creation'!

to: aStream
     ^self new initialize: aStream
! !

!PrependDotStream methodsFor: 'output'!

flush
    atStart ifFalse: [ self nl ].
    stream nextPut: $.; nl
!

nextPut: aChar
    (atStart and: [ aChar == $. ])
	ifTrue: [ stream nextPut: aChar ].

    stream nextPut: aChar.
    atStart := aChar == Character nl.
! !

!PrependDotStream methodsFor: 'private'!

initialize: aStream
    stream := aStream.
    atStart := true
!

species
    ^stream species
! !



!CrLfStream class methodsFor: 'instance creation'!

on: aStream
    Cr := Character cr.
    Lf := Character nl.
    ^self new on: aStream! !

!CrLfStream methodsFor: 'initializing'!

on: aStream
    stream := aStream.
    eatLf := false.
    readStatus := #none! !

!CrLfStream methodsFor: 'stream'!

atEnd
    ^stream atEnd and: [ readStatus == #none ]!

close
    stream close!

flush
    stream flush!

next
    | result |
    readStatus == #none ifFalse: [
	readStatus == Cr ifTrue: [ stream peekFor: Lf ].
	readStatus := #none.
	^Lf ].

    result := stream next.
    ^(result == Cr or: [ result == Lf ])
	ifTrue: [ readStatus := result. Cr ]
	ifFalse: [ result ]!

nextLine
    | line |
    line := self upTo: Cr.
    self next.  "Eat line feed"
    ^line!

nextPut: aCharacter
    eatLf
	ifTrue: [
	    eatLf := false.
	    aCharacter == Lf ifTrue: [ ^self ] ]
	ifFalse: [
	    aCharacter == Lf ifTrue: [
		stream nextPut: Cr; nextPut: Lf; flush.
		^self ] ].

    stream nextPut: aCharacter.
    aCharacter == Cr ifTrue: [
	stream nextPut: Lf; flush.
	eatLf := true.
    ]!

peek
    | result |
    readStatus == #none ifFalse: [
	readStatus == Cr ifTrue: [ stream peekFor: Lf ].
	readStatus := Lf. "peek for LF just once"
	^Lf ].

    result := stream peek.
    ^result == Lf
	ifTrue: [ Cr ]
	ifFalse: [ result ]!

peekFor: aCharacter
    | result success |
    readStatus == #none ifFalse: [
	readStatus == Cr ifTrue: [ stream peekFor: Lf ].
	success := aCharacter == Lf.
	readStatus := success ifTrue: [ #none ] ifFalse: [ Lf ]. "peek for LF just once"
	^success
    ].
    result := stream peek.
    (result == Cr or: [ result == Lf ]) ifTrue: [
	success := aCharacter == Cr.
	success ifTrue: [ readStatus := stream next ].
	^success
    ].
    success := aCharacter == result.
    success ifTrue: [ stream next ].
    ^success!

species
    ^stream species!

stream
    ^stream! !




Namespace current: Smalltalk!
