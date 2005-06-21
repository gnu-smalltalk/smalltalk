"======================================================================
|
|   HTTP protocol support
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


Namespace current: NetClients.HTTP!

NetClient subclass:  #HTTPClient
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-HTTP'!

HTTPClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetProtocolInterpreter subclass:  #HTTPProtocolInterpreter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-HTTP'!

HTTPProtocolInterpreter comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetResponse subclass:  #HTTPResponse
	instanceVariableNames: 'version messageHeader preReadBytes '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-HTTP'!

HTTPResponse comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

Notification subclass:  #HTTPRedirection
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-HTTP'!

HTTPRedirection comment: 
nil!


!HTTPClient class methodsFor: 'examples'!

exampleURL: url host: host port: port
    "self exampleURL: 'http://www.gnu.org' host: 'www.gnu.org' port: 80."
    "self exampleURL: 'http://www.gnu.org' host: 'localhost' port: 8080."

    | body headers client |
    client := HTTPClient connectToHost: host port: port.
    [headers := client
	get: url
	requestHeaders: #()
	into: (body := WriteStream on: String new) ]
    	ensure: [client close].
    ^headers -> body contents! !

!HTTPClient methodsFor: 'accessing'!

get: urlString requestHeaders: requestHeaders into: aStream
    ^self clientPI get: urlString requestHeaders: requestHeaders into: aStream!

getBinary: urlString
    | stream |
    stream := WriteStream on: (String new: 1024).
    self
    	get: urlString
    	requestHeaders: Array new
    	into: stream.

    ^stream contents!

getText: urlString
    ^self clientPI decode: (self getBinary: urlString)!

head: urlString requestHeaders: requestHeaders into: aStream
    ^self clientPI head: urlString requestHeaders: requestHeaders into: aStream!

post: urlString type: type data: data binary: binary requestHeaders: requestHeaders into: aStream
    ^self clientPI
	post: urlString
	type: type
	data: data	
	binary: binary
	requestHeaders: requestHeaders
	into: aStream! !

!HTTPClient methodsFor: 'private'!

protocolInterpreter
    ^HTTPProtocolInterpreter! !

!HTTPProtocolInterpreter methodsFor: 'accessing'!

get: urlString requestHeaders: requestHeaders into: aStream
    self connectIfClosed.
    self nextPutAll: 'GET ', urlString, ' HTTP/1.1'; cr.
    self putRequestHeaders: requestHeaders.

    ^self readResponseInto: aStream
!

readResponseInto: aStream
    | response totalByte readStream |
    response := self getResponse.
    self checkResponse: response.

    totalByte := response fieldAt: 'Content-Length' ifAbsent: [nil].
    totalByte notNil ifTrue: [
	totalByte := totalByte value trimSeparators asInteger.
	self reporter totalByte: totalByte ].
    self reporter startTransfer.
    response preReadBytes isEmpty ifFalse:
    	[self reporter readByte: response preReadBytes size.
    	aStream nextPutAll: response preReadBytes].

    readStream := connectionStream stream.
    [totalByte isNil
	ifTrue: [readStream atEnd]
	ifFalse: [totalByte = 0]

    ]	whileFalse:
    		[| data |
    		data := totalByte notNil 
		    ifTrue: [ readStream next: (4096 min: totalByte) ]
		    ifFalse: [ readStream nextHunk ].

    		totalByte notNil
		    ifTrue: [ totalByte := totalByte - data size ].
		self reporter readByte: data size.
    		aStream nextPutAll: data ].

    self reporter endTransfer.
    response keepAlive ifFalse: [ self close ]. 
    ^response!

head: urlString requestHeaders: requestHeaders into: aStream
    | response |
    self connectIfClosed.
    self reporter startTransfer.
    self nextPutAll: 'HEAD ', urlString, ' HTTP/1.1'; cr.
    self putRequestHeaders: requestHeaders.
    response := self getResponse.
    self checkResponse: response.

    self reporter endTransfer.
    response keepAlive ifFalse: [ self close ]. 
    ^response!

putRequestHeaders: requestHeaders
    | host |
    host := false.
    requestHeaders do: [:header |
	('Host:*' match: header) ifTrue: [ host := true ].
	self nextPutAll: header; cr
    ].

    "The Host header is necessary to support virtual hosts"
    host ifFalse: [
	self nextPutAll: 'Host: ', self client hostName; cr
    ].
    self cr!

post: urlString type: type data: data binary: binary requestHeaders: requestHeaders into: aStream
    | readStream response totalByte |
    self connectIfClosed.

    self nextPutAll: 'POST ', urlString, ' HTTP/1.1'; cr.
    self nextPutAll: 'Content-Type: ', type; cr.
    self nextPutAll: 'Content-Length: ', data size printString; cr.
    self putRequestHeaders: requestHeaders.
    binary
    	ifTrue:	[connectionStream stream nextPutAll: data]
    	ifFalse: [self nextPutAll: data].

    ^self readResponseInto: aStream! !

!HTTPProtocolInterpreter methodsFor: 'private'!

checkResponse: response
    ^self
    	checkResponse: response
    	ifError: [self protocolError: response statusMessage]!

checkResponse: response ifError: errorBlock
    | status |
    status := response status.

    "Successful"
    status = 200 "OK"				ifTrue: [^self].
    status = 201 "Created"			ifTrue: [^self].
    status = 202 "Accepted"			ifTrue: [^self].
    status = 203 "Provisional Information"	ifTrue: [^self].
    status = 204 "No Response"			ifTrue: [^self].
    status = 205 "Deleted"			ifTrue: [^self].
    status = 206 "Modified"			ifTrue: [^self].

    "Redirection"
    (status = 301 "Moved Permanently" or:
    [status = 302 "Moved Temporarily"])
    	ifTrue:
    		[| location |
    		location := response fieldAt: 'Location' ifAbsent: [nil].
    		^self redirectionNotify: location value].

    status = 303 "Method"			ifTrue: [^self].
    status = 304 "Not Modified"			ifTrue: [^self].

    "Client Error"
    status = 400 "Bad Request"			ifTrue: [^errorBlock value].
    status = 401 "Unauthorized"			ifTrue: [^errorBlock value].
    status = 402 "Payment Required"		ifTrue: [^errorBlock value].
    status = 403 "Forbidden"			ifTrue: [^errorBlock value].
    status = 404 "Not Found"			ifTrue: [^errorBlock value].
    status = 405 "Method Not Allowed"		ifTrue: [^errorBlock value].
    status = 406 "None Acceptable"		ifTrue: [^errorBlock value].
    status = 407 "Proxy Authent. Required"	ifTrue: [^errorBlock value].
    status = 408 "Request Timeout"		ifTrue: [^errorBlock value].

    "Server Errors"
    status = 500 "Internal Server Error"	ifTrue: [^errorBlock value].
    status = 501 "Not Implemented"		ifTrue: [^errorBlock value].
    status = 502 "Bad Gateway"			ifTrue: [^errorBlock value].
    status = 503 "Service Unavailable"		ifTrue: [^errorBlock value].
    status = 504 "Gateway Timeout"		ifTrue: [^errorBlock value].

    "Unknown status"
    ^errorBlock value!

redirectionNotify: redirectLocation
    ^HTTPRedirection new tag: redirectLocation; signal! !

!HTTPProtocolInterpreter class methodsFor: 'private-attributes'!

defaultPortNumber
    ^80!

defaultResponseClass
    ^HTTPResponse!


!HTTPResponse methodsFor: 'accessing'!

fieldAt: key
    ^messageHeader fieldAt: key!

fieldAt: key ifAbsent: absentBlock
    ^messageHeader fieldAt: key ifAbsent: absentBlock!

keepAlive
    | connection |
    (self fieldAt: 'content-length' ifAbsent: [nil]) isNil
	ifTrue: [ ^false ].

    connection := self fieldAt: 'connection' ifAbsent: [nil].
    connection := connection isNil
	ifTrue: [ '' ]
	ifFalse: [ connection value ].

    "For HTTP/1.0, the default is close and there is a de facto
     standard way to specify keep-alive connections"
    version < 'HTTP/1.1' ifTrue: [
	^'*keep-alive*' match: connection ignoreCase: true
    ].

    "For HTTP/1.1, the default is keep-alive"
    ^('*close*' match: connection ignoreCase: true) not
!

messageHeader
    ^messageHeader!

preReadBytes
    ^preReadBytes isNil
    	ifTrue:	[ #[] ]
    	ifFalse: [ preReadBytes]! !

!HTTPResponse methodsFor: 'parsing'!

parseResponse: aClient
    | messageHeaderParser |
    messageHeader := MIME.MimeEntity new.
    version := aClient nextAvailable: 8.
    ('HTTP/1.#' match: version)
    	ifFalse:	"may be HTTP/0.9"
    		[preReadBytes := version.
    		status := 200.
    		statusMessage := 'OK'.
		version := 'HTTP/0.9'.
    		^self].

    self parseStatusLine: aClient.
    messageHeaderParser := MIME.MimeEntity parser on: aClient connectionStream.
    messageHeader parseFieldsFrom: messageHeaderParser.

    "Empty the lookahead buffer of the parser"
    preReadBytes := String with: messageHeaderParser next! !

!HTTPResponse methodsFor: 'printing'!

printOn: aStream
    self printStatusOn: aStream.
    aStream cr.
    messageHeader printOn: aStream!

printStatusOn: aStream
    aStream nextPutAll: 'HTTP/1.0 '.
    super printStatusOn: aStream! !

!HTTPResponse methodsFor: 'private'!

parseStatusLine: aClient
    | stream |
    stream := aClient nextLine readStream.
    stream skipSeparators.
    status := Integer readFrom: stream.
    stream skipSeparators.
    statusMessage := stream upToEnd! !


Namespace current: Smalltalk!
