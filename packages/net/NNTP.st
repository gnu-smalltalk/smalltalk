"======================================================================
|
|   NNTP protocol support
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


NetClients addSubspace: #NNTP!
Namespace current: NetClients.NNTP!

NetClient subclass:  #NNTPClient
	instanceVariableNames: 'currentGroup '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-NNTP'!

NNTPClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetProtocolInterpreter subclass:  #NNTPProtocolInterpreter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-NNTP'!

NNTPProtocolInterpreter comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

!NNTPClient class methodsFor: 'examples'!

exampleHelpOn: host
    "self exampleHelpOn: 'localhost'."

    | client answer |
    client := NNTPProtocolInterpreter connectToHost: host.
    [answer := client help.
    client logout.
    ] ensure: [client close].
    ^answer!

exampleOn: host group: groupString
    "self exampleOn: 'newshost' group: 'comp.lang.smalltalk'."

    | subjects client |
    client := NNTPProtocolInterpreter host: host.
    [| range |
    range := client activeArticlesInGroup: groupString.
    subjects := Array new: range size.
    client
    	subjectsOf: groupString
    	from: range first
    	to: range last
    	do: [:n :subject | subjects add: subject].
    client logout.
    ] ensure: [client close].
    subjects inspect.! !

!NNTPClient methodsFor: 'accessing'!

activeArticlesInGroup: groupString
    "Answer an active article range in group."

    | response read from to |
    self connectIfClosed.
    response := self clientPI nntpGroup: groupString.
    currentGroup := groupString.

    response status = 211 ifFalse: [^0 to: 0].
    "A response is as follows:"
    "211 n f l s (n = estimated number of articles in group,
    			f = first article number in the group,
    			l = last article number in the group,
    			s = name of the group.)"
    read := response statusMessage readStream.
    read skipSeparators.
    Integer readFrom: read.
    read skipSeparators.
    from := Integer readFrom: read.
    read skipSeparators.
    to := Integer readFrom: read.
    ^from to: to!

activeNewsgroupsDo: aBlock
    "Answer a list of active newsgroups."

    | line |
    self reconnect.
    self clientPI nntpList.
    [self atEnd or:
    [line := self nextLine.
    line = '.']] whileFalse:
    	[aBlock value: line]!

activeNewsgroups
    "Answer a list of active newsgroups."

    | stream |
    stream := WriteStream on: (Array new).
    self activeNewsgroupsDo: [ :each | stream nextPut: each ].
    ^stream contents!

articleAt: idOrNumberString into: aStream
    "Read an article at idOrNumberString into aStream."

    self connectIfClosed.
    self clientPI nntpArticle: idOrNumberString.
    self receiveMessageUntilPeriodInto: aStream!

articleAtNumber: anInteger group: groupString into: aStream
    "Read an article at anInteger of a newsgroup named groupString into aStream."

    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    self articleAt: anInteger printString into: aStream!

articleMessageAt: idOrNumberString
    "Answer a message of an article at idOrNumberString."

    self connectIfClosed.
    self clientPI nntpArticle: idOrNumberString.
    ^MIME.MimeEntity readFrom: self!

articleMessageAtNumber: anInteger group: groupString
    "Answer a message of an article at anInteger of a newsgroup named groupString."

    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    ^self articleMessageAt: anInteger printString.!

bodyAt: idOrNumberString into: aStream
    "Read a body of an article at idOrNumberString into aStream."

    | response |
    self connectIfClosed.
    self clientPI nntpBody: idOrNumberString.
    self receiveMessageUntilPeriodInto: aStream!

bodyAtNumber: anInteger group: groupString into: aStream
    "Read a body of an article at anInteger of a newsgroup named groupString into aStream."

    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    ^self bodyAt: anInteger printString into: aStream!

connectToHost: host port: port
    currentGroup := nil.
    super connectToHost: host port: port!

group: groupString
    self connectIfClosed.
    self clientPI nntpGroup: groupString.
    currentGroup := groupString.!

headAt: idOrNumberString into: aStream
    "Read a header of an article at idOrNumberString into aStream."

    self connectIfClosed.
    self clientPI nntpHead: idOrNumberString.
    self receiveMessageUntilPeriodInto: aStream!

headAtNumber: anInteger group: groupString into: aStream
    "Read a header of an article at anInteger of a newsgroup named groupString into aStream."

    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    ^self headAt: anInteger printString into: aStream!

help
    "Answer a help text."

    | write |
    write := WriteStream on: (String new: 1024).
    self connectIfClosed.
    self clientPI nntpHelp.
    self receiveMessageUntilPeriodInto: write.
    ^write contents!

postArticleMessage: aMessage
    "Post a news article message."

    self connectIfClosed.
    self clientPI nntpPost: [ aMessage printMessageOnClient: self ]!

postArticleStream: aStream
    "Post a news article in aStream."

    self connectIfClosed.
    self clientPI nntpPost: [ self sendMessageWithPeriod: aStream ]!

logout
    self closed ifTrue: [^self].
    self clientPI nntpQuit.
    self close! !

!NNTPClient methodsFor: 'private'!

protocolInterpreter
    ^NNTPProtocolInterpreter! !

!NNTPClient methodsFor: 'extended accessing'!

headersAt: keyString group: groupString from: from to: to do: aBlock
    "Answer a list of article number and value of header field in a range (from to)."
    | line |
    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    self clientPI nntpXhdr: keyString from: from to: to.
    [self atEnd or:
    [line := self nextLine.
    line = '.']] whileFalse:
    	[| read number string |
    	read := line readStream.
    	read skipSeparators.
    	number := Integer readFrom: read.
    	read skipSeparators.
    	string := read upToEnd.
    	aBlock value: number value: string]!

headersAt: keyString group: groupString from: from to: to into: aStream
    "Answer a list of article number and value of header field in a range (from to)."

    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    self clientPI nntpXhdr: keyString from: from to: to.
    self receiveMessageUntilPeriodInto: aStream!

messageIdsOf: groupString from: from to: to do: aBlock
    ^self headersAt: 'MESSAGE-ID' group: groupString from: from to: to do: aBlock!

messageIdsOf: groupString from: from to: to into: aStream
    ^self headersAt: 'MESSAGE-ID' group: groupString from: from to: to into: aStream!

overviewsOf: groupString from: from to: to do: aBlock
    "Answer a list of article number and overview of header field in a range (from to)."
    | line |
    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    self clientPI nntpXoverFrom: from to: to.
    [self atEnd or:
    [line := self nextLine.
    line = '.']] whileFalse:
    	[| read number string |
    	read := line readStream.
    	read skipSeparators.
    	number := Integer readFrom: read.
    	read skipSeparators.
    	string := read upToEnd.
    	aBlock value: number value: string]!

overviewsOf: groupString from: from to: to into: aStream
    "Answer a list of article number and overview of header field in a range (from to)."

    self connectIfClosed.
    groupString = currentGroup ifFalse: [self group: groupString].
    self clientPI nntpXoverFrom: from to: to.
    self receiveMessageUntilPeriodInto: aStream!

subjectsOf: groupString from: from to: to do: aBlock
    ^self headersAt: 'SUBJECT' group: groupString from: from to: to do: aBlock!

subjectsOf: groupString from: from to: to into: aStream
    ^self headersAt: 'SUBJECT' group: groupString from: from to: to into: aStream!

xrefsOf: groupString from: from to: to do: aBlock
    ^self headersAt: 'XREF' group: groupString from: from to: to do: aBlock!

xrefsOf: groupString from: from to: to into: aStream
    ^self headersAt: 'XREF' group: groupString from: from to: to into: aStream! !

!NNTPProtocolInterpreter class methodsFor: 'api'!

defaultPortNumber
    ^119!

!NNTPProtocolInterpreter methodsFor: 'connection'!

connect
    super connect.

    "Skip first general response."
    self checkResponse: self getResponse.

    "Set mode to reader for INN."
    self nextPutAll: 'MODE READER'; cr.
    "Ignore error"
    self checkResponse: self getResponse ifError: [].! !

!NNTPProtocolInterpreter methodsFor: 'nntp protocol'!

nntpArticle: idOrNumberString
    | response |
    self nextPutAll: ('ARTICLE ', idOrNumberString); cr.
    response := self getResponse.
    response status = 220 "article retrieved - head and body follows"
    	ifFalse: [^self checkResponse: response]!

nntpBody: idOrNumberString
    | response |
    self nextPutAll: ('BODY ', idOrNumberString); cr.
    response := self getResponse.
    response status = 222 "article retrieved - body follows"
    	ifFalse: [^self checkResponse: response]!

nntpGroup: groupString
    | response |
    self nextPutAll: ('GROUP ', groupString); cr.
    response := self getResponse.
    self checkResponse: response.
    ^response!

nntpHead: idOrNumberString
    | response |
    self nextPutAll: ('HEAD ', idOrNumberString); cr.
    response := self getResponse.
    response status = 221 "article retrieved - head follows"
    	ifFalse: [^self checkResponse: response]!

nntpHelp
    self nextPutAll: 'HELP'; cr.
    self checkResponseForFollowingText: self getResponse!

nntpList
    self nextPutAll: 'LIST'; cr.
    self checkResponseForFollowingText: self getResponse!

nntpPost: aBlock
    self nextPutAll: 'POST'; cr.
    self checkResponse: self getResponse.
    aBlock value.
    self checkResponse: self getResponse.!

nntpQuit
    self nextPutAll: 'QUIT'; cr.
    self checkResponse: self getResponse!

nntpXhdr: keyString from: from to: to
    "Answer a list of article number and value of header field in a range (from to)."

    self nextPutAll: ('XHDR ', keyString, ' ', from printString, '-', to printString); cr.
    self checkResponseForFollowingText: self getResponse!

nntpXoverFrom: from to: to
    "Answer a list of article number and overview of header field in a range (from to)."

    self nextPutAll: ('XOVER ', from printString, '-', to printString); cr.
    self checkResponseForFollowingText: self getResponse! !

!NNTPProtocolInterpreter methodsFor: 'private'!

checkResponse: response
    | textFollows |
    textFollows := self
    				checkResponse: response
    				ifError: [self protocolError: response statusMessage. false].
    textFollows ifFalse: [^self].
    self skipMessageUntilPeriod.
    ^self protocolError: 'Unexpected reply: ', response statusMessage.!

checkResponse: response ifError: errorBlock
    "Answer text follows or not."

    | status |
    status := response status.

    "Timeout after 7200 seconds, closing connection"
    status = 503 ifTrue: [^self connectionClosedError: response statusMessage].

    "Informative message"
    status = 100 "help text follows"					ifTrue: [^true].
    (status between: 190 and: 199) "debug output"			ifTrue: [^false].

    "Command ok"
    status = 200 "server ready - posting allowed"			ifTrue: [^false].
    status = 201 "server ready - no posting allowed"			ifTrue: [^false].
    status = 202 "slave status noted"					ifTrue: [^false].
    status = 205 "closing connection - goodbye!"			ifTrue: [^false].
    status = 211 "n f l s group selected"				ifTrue: [^false].
    "### n f l s (n = estimated number of articles in group,
    			f = first article number in the group,
    			l = last article number in the group,
    			s = name of the group.)"
    status = 215 "list of newsgroups follows"				ifTrue: [^true].

    "### n <a> (n = article number, <a> = message-id)"
    status = 220 "article retrieved - head and body follows"		ifTrue: [^true].
    status = 221 "article retrieved - head follows"			ifTrue: [^true].
    status = 222 "article retrieved - body follows"			ifTrue: [^true].
    status = 223 "article retrieved - request text separately"		ifTrue: [^true].

    status = 224 "data follows"						ifTrue: [^true].

    status = 230 "list of new articles by message-id follows"		ifTrue: [^true].
    status = 231 "list of new newsgroups follows"			ifTrue: [^true].
    status = 235 "article transferred ok"				ifTrue: [^false].
    status = 240 "article posted ok"					ifTrue: [^false].

    "Command ok so far, send the rest of it"
    status = 335 "send article to be transferred"			ifTrue: [^false].
    status = 340 "send article to be posted"				ifTrue: [^false].

    "Command was correct, but couldn't be performed for some reason"
    status = 400 "service discontinued"					ifTrue: [^errorBlock value].
    status = 411 "no such news group"					ifTrue: [^errorBlock value].
    status = 412 "no newsgroup has been selected"			ifTrue: [^errorBlock value].
    status = 420 "no current article has been selected"			ifTrue: [^errorBlock value].
    status = 421 "no next article in this group"			ifTrue: [^errorBlock value].
    status = 422 "no previous article in this group"			ifTrue: [^errorBlock value].
    status = 423 "no such article number in this group"			ifTrue: [^errorBlock value].
    status = 430 "no such article found"				ifTrue: [^errorBlock value].
    status = 435 "article not wanted - do not send it"			ifTrue: [^errorBlock value].
    status = 436 "transfer failed - try again later"			ifTrue: [^errorBlock value].
    status = 437 "article rejected - do not try again."			ifTrue: [^errorBlock value].
    status = 440 "posting not allowed"					ifTrue: [^errorBlock value].
    status = 441 "posting failed"					ifTrue: [^errorBlock value].

    "Command unimplemented, or incorrect, or a serious program error occurred"
    status = 500 "command not recognized"				ifTrue: [^errorBlock value].
    status = 501 "command syntax error"					ifTrue: [^errorBlock value].
    status = 502 "access restriction or permission denied"		ifTrue: [^errorBlock value].
    status = 503 "program fault - command not performed"		ifTrue: [^errorBlock value].

    "Unknown status"
    ^errorBlock value!

checkResponseForFollowingText: response
    | textFollows |
    textFollows := self
			checkResponse: response
			ifError: [self protocolError: response statusMessage. false].
    textFollows
    	ifFalse: [^self protocolError: 'Unexpected reply: ', response statusMessage].! !

!NNTPProtocolInterpreter methodsFor: 'private-attributes'!

defaultPortNumber
    ^119!

liveAcrossSnapshot
    ^true! !

!NNTPProtocolInterpreter methodsFor: 'stream accessing'!

nextPutAll: aString
    | retryCount |
    aString isEmpty ifTrue: [^self].
    retryCount := 0.
    [connectionStream nextPutAll: (self encode: aString)]
	on: Error
    	do: [:ex |
    		(retryCount := retryCount + 1) > 1
    			ifTrue: [ex return]
    			ifFalse: [self reconnect. ex restart]]! !


Namespace current: NetClients!
