"======================================================================
|
|   FTP protocol support
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


Namespace current: NetClients.FTP!

Object subclass:  #FTPServerEntity
	instanceVariableNames: 'permissions id owner group sizeInBytes modifiedDate filename isDirectory '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-FTP'!

FTPServerEntity comment: 
nil!

NetClient subclass:  #FTPClient
	instanceVariableNames: 'loggedInUser'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-FTP'!

FTPClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetProtocolInterpreter subclass:  #FTPProtocolInterpreter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: 'TCP'
	category: 'NetClients-FTP'!

FTPClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetClientError subclass:  #FTPFileNotFoundError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-FTP'!

FTPFileNotFoundError comment: 
nil!


!FTPServerEntity methodsFor: 'accessing'!

filename
    ^filename!

filename: aValue
    filename := aValue!

group
    ^group!

group: aValue
    group := aValue!

id
    ^id!

id: aValue
    id := aValue asNumber!

isDirectory
    ^isDirectory!

isDirectory: aValue
    isDirectory := aValue!

modifiedDate
    ^modifiedDate!

modifiedDate: aValue
    modifiedDate := aValue!

owner
    ^owner!

owner: aValue
    owner := aValue!

permissions
    ^permissions!

permissions: aValue
    permissions := aValue!

sizeInBytes
    ^sizeInBytes!

sizeInBytes: aValue
    sizeInBytes := aValue asNumber! !

!FTPServerEntity methodsFor: 'displaying'!

displayString
    | stream |
    stream := Stream on: (String new: 100).
    self isDirectory
    	ifTrue: [stream nextPutAll: ' <D> ' ]
    	ifFalse: [stream space: 5].
    stream nextPutAll: self filename; space: 30 - self filename size.
    stream nextPutAll: self sizeInBytes printString.
    ^stream contents! !

!FTPServerEntity methodsFor: 'initialize-release'!

from: stream
    self permissions: (stream upTo: Character space).
    stream skipSeparators. 
    self id: (stream upTo: Character space).
    stream skipSeparators.
    self owner:  (stream upTo: Character space).
    stream skipSeparators.
    self group: (stream upTo: Character space).
    stream skipSeparators. 
    self sizeInBytes: (stream upTo: Character space).
    stream skipSeparators. 
    self modifiedDate: (self getDateFromNext: 3 on: stream). 
    stream skipSeparators.
    self filename: (stream upTo: Character space). 
    self isDirectory: (self sizeInBytes = 0).! !

!FTPServerEntity methodsFor: 'private'!

getDateFromNext: aNumber on: stream
    | iStream |
    iStream := WriteStream on: (String new: 100).
    aNumber timesRepeat:
    	[iStream nextPutAll: (stream upTo: Character space).
    	iStream nextPut: Character space.
    		stream skipSeparators].
    ^DateTime readFrom: iStream contents readStream! !




!FTPClient class methodsFor: 'examples'!

exampleHost: host
    "self exampleHost: 'localhost'."

    ^self exampleHost: host port: 21!

exampleHost: host port: port
    "self exampleHost: 'localhost' port: 2121."

    | user password stream client |
    user := 'utente'.
    password := 'bonzini'.
    stream := WriteStream on: (String new: 256).
    client := FTPClient connectToHost: host port: port.
    [client username: user password: password; login; getList: '/' into: stream]
    	ensure: [client close].
    ^stream contents!

exampleHost: host fileName: fileName
    "self exampleHost: 'localhost'."

    ^self exampleHost: host port: 21 fileName: fileName!

exampleHost: host port: port fileName: fileName
    "self exampleHost: 'arrow' fileName: '/pub/smallwalker/README'."

    | user password stream client |
    user := 'utente'.
    password := 'bonzini'.
    stream := WriteStream on: (String new: 256).
    client := FTPClient connectToHost: host port: port.
    [client username: user password: password; login; getFile: fileName type: #ascii into: stream]
    	ensure: [client close].
    ^stream contents! !

!FTPClient methodsFor: 'private'!

protocolInterpreter
    ^FTPProtocolInterpreter! !

!FTPClient methodsFor: 'ftp'!

login
    self connectIfClosed.
    loggedInUser = self user ifTrue: [ ^self ].
    self clientPI ftpUser: self user username.
    self clientPI ftpPassword: self user password.
    loggedInUser := self user.
!

logout
    loggedInUser := nil.
    self clientPI ftpQuit; close
!

getFile: fileName type: type into: aStream
    | fname directory tail |

    self login.

    fname := File name: fileName.
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
    			do: [self clientPI ftpRetrieve: tail]]!

getList: pathName into: aStream 
    | fname directory tail |

    self login.

    fname := File name: pathName.
    directory := fname path asString.
    tail := fname stripPath asString.
    self clientPI ftpCwd: directory.
    ^self clientPI
    	getDataWithType: #ascii
    	into: aStream
    	do: [tail isEmpty
    			ifTrue:	[self clientPI ftpList]
    			ifFalse: [self clientPI ftpList: tail].
    		0].!

!FTPProtocolInterpreter class methodsFor: 'accessing'!

defaultPortNumber
    ^21! !

!FTPProtocolInterpreter methodsFor: 'data connection'!

openDataConnectionDo: controlBlock
    | portSocket dataStream |
    "Create a socket.  Set up a queue for a single connection."
    portSocket := ServerSocket 
	reuseAddr: true
	port: 0
	queueSize: 1
	bindTo: nil.

    [
        self ftpPort: portSocket port host: portSocket address asByteArray.

        "issue control command."
        controlBlock value.

        [ (dataStream := portSocket accept) isNil ] whileTrue: [ Processor yield ].
    ] ensure: [portSocket close].

    ^dataStream!

openPassiveDataConnectionDo: controlBlock
    | array dataSocket dataStream |
    "Enter Passive Mode"
    array := self ftpPassive.
    
    dataStream := Socket
	remote: (IPAddress fromBytes: (array at: 1))
	port: (array at: 2).

    "issue control command."
    controlBlock value.

    ^dataStream! !

!FTPProtocolInterpreter methodsFor: 'ftp protocol'!

connect
    super connect.
    self checkResponse!

getDataWithType: type into: aStream do: controlBlock
    | dataStream totalByte |
    (#(#ascii #binary) includes: type)
    	ifFalse: [^self error: 'type must be #ascii or #binary'].
    type == #ascii
    	ifTrue:	[self ftpTypeAscii]
    	ifFalse: [self ftpTypeBinary].

    "dataStream := self openDataConnectionDo: [totalByte := controlBlock value]."
    dataStream := self openPassiveDataConnectionDo: [totalByte := controlBlock value].

    totalByte > 0 ifTrue: [self reporter totalByte: totalByte].
    self reporter startTransfer.

    [[dataStream atEnd]
    	whileFalse:
    		[| byte |
    		byte := dataStream nextHunk.
    		self reporter readByte: byte size.
    		type == #ascii
    			ifTrue:	[aStream nextPutAll: (self decode: byte)]
    			ifFalse: [aStream nextPutAll: byte]]
    ] ensure: [dataStream close].

    self reporter endTransfer!

ftpAbort
    self nextPutAll: 'ABOR'; cr.
    self checkResponse!

ftpCdup
    "Change to Parent Directory"

    self nextPutAll: 'CDUP'; cr.
    self checkResponse!

ftpCwd: directory
    "Change Working Directory"

    self nextPutAll: ('CWD ', directory); cr.
    self checkResponse!

ftpList
    self nextPutAll: 'LIST'; cr.
    self checkResponse!

ftpList: pathName
    self nextPutAll: ('LIST ', pathName); cr.
    self checkResponse!

ftpPassive
    | response stream hostAddress port |
    self nextPutAll: 'PASV'; cr.
    response := self getResponse.
    self checkResponse: response.
    response status = 227 ifFalse: [^self protocolError: response statusMessage].

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
    ^Array with: hostAddress with: port!

ftpPassword: password
    | response |
    self nextPutAll: ('PASS ', password); cr.
    response := self getResponse.
    self
    	checkResponse: response
    	ifError: [self loginIncorrectError: response statusMessage]!

ftpPort: portInteger host: hostAddressBytes
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
    	nextPutAll: ((portInteger bitShift: -8) bitAnd: 16rFF) printString;
    	nextPut: $,;
    	nextPutAll: (portInteger bitAnd: 16rFF) printString;
    	cr.
    self checkResponse!

ftpQuit
    self nextPutAll: 'QUIT'; cr.
    self checkResponse!

ftpRetrieve: fileName
    | response stream |
    self nextPutAll: ('RETR ', fileName); cr.
    response := self getResponse.
    self checkResponse: response.

    "150 Opening data connection for file (398 bytes)."
    stream := response statusMessage readStream.
    stream skipTo: $(.
    stream atEnd ifTrue: [ ^nil ].
    ^Integer readFrom: stream!

ftpStore: fileName
    self nextPutAll: ('STOR ', fileName); cr.
    self checkResponse!

ftpType: type
    self nextPutAll: ('TYPE ', type); cr.
    self checkResponse!

ftpTypeAscii
    ^self ftpType: 'A'!

ftpTypeBinary
    ^self ftpType: 'I'!

ftpUser: user
    self nextPutAll: ('USER ', user); cr.
    self checkResponse! !

!FTPProtocolInterpreter methodsFor: 'private'!

checkResponse: response
    ^self
    	checkResponse: response
    	ifError: [self protocolError: response statusMessage]!

checkResponse: response ifError: errorBlock
    | status |
    status := response status.

    "Positive Preliminary reply"
    status = 110 "Restart marker reply"				ifTrue: [^self].
    status = 120 "Service ready in nnn minutes"			ifTrue: [^self].
    status = 125 "Data connection already open"			ifTrue: [^self].
    status = 150 "File status okay"				ifTrue: [^self].

    "Positive Completion reply"
    status = 200 "OK"						ifTrue: [^self].
    status = 202 "Command not implemented"			ifTrue: [^self].
    status = 211 "System status"				ifTrue: [^self].
    status = 212 "Directory status"				ifTrue: [^self].
    status = 213 "File status"					ifTrue: [^self].
    status = 214 "Help message"					ifTrue: [^self].
    status = 215 "NAME system type"				ifTrue: [^self].
    status = 220 "Service ready for new user"			ifTrue: [^self].
    status = 221 "Service closing control connection"		ifTrue: [^self].
    status = 225 "Data connection open"				ifTrue: [^self].
    status = 226 "Closing data connection"			ifTrue: [^self].
    status = 227 "Entering Passive Mode"			ifTrue: [^self].
    status = 230 "User logged in"				ifTrue: [^self].
    status = 250 "Requested file action okay"			ifTrue: [^self].
    status = 257 "'PATHNAME' created"				ifTrue: [^self].

    "Positive Intermediate reply"
    status = 331 "User name okay"				ifTrue: [^self].
    status = 332 "Need account for login"			ifTrue: [^self].
    status = 350 "Requested file action pending"		ifTrue: [^self].

    "Transient Negative Completion reply"
    status = 421 "Service not available"			ifTrue: [^errorBlock value].
    status = 425 "Can't open data connection"			ifTrue: [^errorBlock value].
    status = 426 "Connection closed"				ifTrue: [^errorBlock value].
    status = 450 "Requested file action not taken"		ifTrue: [^errorBlock value].
    status = 451 "Requested action aborted"			ifTrue: [^errorBlock value].
    status = 452 "Requested action not taken"			ifTrue: [^errorBlock value].

    "Permanent Negative Completion reply"
    status = 500 "Syntax error"					ifTrue: [^errorBlock value].
    status = 501 "Syntax error"					ifTrue: [^errorBlock value].
    status = 502 "Command not implemented"			ifTrue: [^errorBlock value].
    status = 503 "Bad sequence of commands"			ifTrue: [^errorBlock value].
    status = 504 "Command not implemented"			ifTrue: [^errorBlock value].
    status = 530 "Not logged in"				ifTrue: [^self loginIncorrectError: response statusMessage].
    status = 532 "Need account for storing files"		ifTrue: [^errorBlock value].
    status = 550 "Requested action not taken"			ifTrue: [^self fileNotFoundError: response statusMessage].
    status = 551 "Requested action aborted"			ifTrue: [^errorBlock value].
    status = 552 "Requested file action aborted"		ifTrue: [^errorBlock value].
    status = 553 "Requested action not taken"			ifTrue: [^errorBlock value].

    "Unknown status"
    ^errorBlock value!

fileNotFoundError: errorString
    ^FTPFileNotFoundError signal: errorString! !


Namespace current: Smalltalk!
