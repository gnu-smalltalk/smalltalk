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



Namespace current: NetClients.NNTP [

NetClient subclass: NNTPClient [
    | currentGroup |
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-NNTP'>

    NNTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^119
    ]

    NNTPClient class >> exampleHelpOn: host [
	"self exampleHelpOn: 'localhost'."

	<category: 'examples'>
	| client answer |
	client := NNTPClient connectToHost: host.
	
	[answer := client help.
	client logout] ensure: [client close].
	^answer
    ]

    NNTPClient class >> exampleOn: host group: groupString [
	"self exampleOn: 'newshost' group: 'comp.lang.smalltalk'."

	<category: 'examples'>
	| subjects client |
	client := NNTPClient connectToHost: host.
	
	[| range |
	range := client activeArticlesInGroup: groupString.
	subjects := Array new: range size.
	client 
	    subjectsOf: groupString
	    from: range first
	    to: range last
	    do: [:n :subject | subjects add: subject].
	client logout] 
		ensure: [client close].
	subjects inspect
    ]

    activeArticlesInGroup: groupString [
	"Answer an active article range in group."

	<category: 'accessing'>
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
	^from to: to
    ]

    activeNewsgroupsDo: aBlock [
	"Answer a list of active newsgroups."

	<category: 'accessing'>
	| line |
	self reconnect.
	self clientPI nntpList.
	[self atEnd or: 
		[line := self nextLine.
		line = '.']] 
	    whileFalse: [aBlock value: line]
    ]

    activeNewsgroups [
	"Answer a list of active newsgroups."

	<category: 'accessing'>
	| stream |
	stream := WriteStream on: Array new.
	self activeNewsgroupsDo: [:each | stream nextPut: each].
	^stream contents
    ]

    articleAt: idOrNumberString into: aStream [
	"Read an article at idOrNumberString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpArticle: idOrNumberString.
	self receiveMessageUntilPeriodInto: aStream
    ]

    articleAtNumber: anInteger group: groupString into: aStream [
	"Read an article at anInteger of a newsgroup named groupString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self articleAt: anInteger printString into: aStream
    ]

    articleMessageAt: idOrNumberString [
	"Answer a message of an article at idOrNumberString."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpArticle: idOrNumberString.
	^MIME.MimeEntity readFrom: self
    ]

    articleMessageAtNumber: anInteger group: groupString [
	"Answer a message of an article at anInteger of a newsgroup named groupString."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	^self articleMessageAt: anInteger printString
    ]

    bodyAt: idOrNumberString into: aStream [
	"Read a body of an article at idOrNumberString into aStream."

	<category: 'accessing'>
	| response |
	self connectIfClosed.
	self clientPI nntpBody: idOrNumberString.
	self receiveMessageUntilPeriodInto: aStream
    ]

    bodyAtNumber: anInteger group: groupString into: aStream [
	"Read a body of an article at anInteger of a newsgroup named groupString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	^self bodyAt: anInteger printString into: aStream
    ]

    connected [
	<category: 'accessing'>
	currentGroup := nil.
    ]

    group: groupString [
	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpGroup: groupString.
	currentGroup := groupString
    ]

    headAt: idOrNumberString into: aStream [
	"Read a header of an article at idOrNumberString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpHead: idOrNumberString.
	self receiveMessageUntilPeriodInto: aStream
    ]

    headAtNumber: anInteger group: groupString into: aStream [
	"Read a header of an article at anInteger of a newsgroup named groupString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	^self headAt: anInteger printString into: aStream
    ]

    help [
	"Answer a help text."

	<category: 'accessing'>
	| write |
	write := WriteStream on: (String new: 1024).
	self connectIfClosed.
	self clientPI nntpHelp.
	self receiveMessageUntilPeriodInto: write.
	^write contents
    ]

    postArticleMessage: aMessage [
	"Post a news article message."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpPost: [aMessage printMessageOnClient: self]
    ]

    postArticleStream: aStream [
	"Post a news article in aStream."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpPost: [self sendMessageWithPeriod: aStream]
    ]

    logout [
	<category: 'accessing'>
	self closed ifTrue: [^self].
	self clientPI nntpQuit.
	self close
    ]

    protocolInterpreter [
	<category: 'private'>
	^NNTPProtocolInterpreter
    ]

    headersAt: keyString group: groupString from: from to: to do: aBlock [
	"Answer a list of article number and value of header field in a range (from to)."

	<category: 'extended accessing'>
	| line |
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI 
	    nntpXhdr: keyString
	    from: from
	    to: to.
	[self atEnd or: 
		[line := self nextLine.
		line = '.']] whileFalse: 
		[| read number string |
		read := line readStream.
		read skipSeparators.
		number := Integer readFrom: read.
		read skipSeparators.
		string := read upToEnd.
		aBlock value: number value: string]
    ]

    headersAt: keyString group: groupString from: from to: to into: aStream [
	"Answer a list of article number and value of header field in a range (from to)."

	<category: 'extended accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI 
	    nntpXhdr: keyString
	    from: from
	    to: to.
	self receiveMessageUntilPeriodInto: aStream
    ]

    messageIdsOf: groupString from: from to: to do: aBlock [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'MESSAGE-ID'
	    group: groupString
	    from: from
	    to: to
	    do: aBlock
    ]

    messageIdsOf: groupString from: from to: to into: aStream [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'MESSAGE-ID'
	    group: groupString
	    from: from
	    to: to
	    into: aStream
    ]

    overviewsOf: groupString from: from to: to do: aBlock [
	"Answer a list of article number and overview of header field in a range (from to)."

	<category: 'extended accessing'>
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
		aBlock value: number value: string]
    ]

    overviewsOf: groupString from: from to: to into: aStream [
	"Answer a list of article number and overview of header field in a range (from to)."

	<category: 'extended accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI nntpXoverFrom: from to: to.
	self receiveMessageUntilPeriodInto: aStream
    ]

    subjectsOf: groupString from: from to: to do: aBlock [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'SUBJECT'
	    group: groupString
	    from: from
	    to: to
	    do: aBlock
    ]

    subjectsOf: groupString from: from to: to into: aStream [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'SUBJECT'
	    group: groupString
	    from: from
	    to: to
	    into: aStream
    ]

    xrefsOf: groupString from: from to: to do: aBlock [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'XREF'
	    group: groupString
	    from: from
	    to: to
	    do: aBlock
    ]

    xrefsOf: groupString from: from to: to into: aStream [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'XREF'
	    group: groupString
	    from: from
	    to: to
	    into: aStream
    ]

    liveAcrossSnapshot [
	<category: 'private-attributes'>
	^true
    ]
]

]



Namespace current: NetClients.NNTP [

NetProtocolInterpreter subclass: NNTPProtocolInterpreter [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-NNTP'>

    connect [
	<category: 'connection'>
	super connect.

	"Skip first general response."
	self checkResponse: self getResponse.

	"Set mode to reader for INN."
	self
	    nextPutAll: 'MODE READER';
	    cr.
	"Ignore error"
	self checkResponse: self getResponse ifError: []
    ]

    nntpArticle: idOrNumberString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'ARTICLE ' , idOrNumberString;
	    cr.
	response := self getResponse.
	response status = 220 
	    ifFalse: 
		["article retrieved - head and body follows"

		^self checkResponse: response]
    ]

    nntpBody: idOrNumberString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'BODY ' , idOrNumberString;
	    cr.
	response := self getResponse.
	response status = 222 
	    ifFalse: 
		["article retrieved - body follows"

		^self checkResponse: response]
    ]

    nntpGroup: groupString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'GROUP ' , groupString;
	    cr.
	response := self getResponse.
	self checkResponse: response.
	^response
    ]

    nntpHead: idOrNumberString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'HEAD ' , idOrNumberString;
	    cr.
	response := self getResponse.
	response status = 221 
	    ifFalse: 
		["article retrieved - head follows"

		^self checkResponse: response]
    ]

    nntpHelp [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'HELP';
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    nntpList [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'LIST';
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    nntpPost: aBlock [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'POST';
	    cr.
	self checkResponse: self getResponse.
	aBlock value.
	self checkResponse: self getResponse
    ]

    nntpQuit [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'QUIT';
	    cr.
	self checkResponse: self getResponse
    ]

    nntpXhdr: keyString from: from to: to [
	"Answer a list of article number and value of header field in a range (from to)."

	<category: 'nntp protocol'>
	self
	    nextPutAll: 'XHDR ' , keyString , ' ' , from printString , '-' 
			, to printString;
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    nntpXoverFrom: from to: to [
	"Answer a list of article number and overview of header field in a range (from to)."

	<category: 'nntp protocol'>
	self
	    nextPutAll: 'XOVER ' , from printString , '-' , to printString;
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    checkResponse: response [
	<category: 'private'>
	| textFollows |
	textFollows := self checkResponse: response
		    ifError: [self errorResponse: response. ^self].
	textFollows ifFalse: [^self].
	self skipMessageUntilPeriod.
	self unexpectedResponse: response
    ]

    checkResponse: response ifError: errorBlock [
	"Answer text follows or not."

	<category: 'private'>
	| status |
	status := response status.

	"Timeout after 7200 seconds, closing connection"
	status = 503 ifTrue: [^self connectionClosedError: response statusMessage].

	"Informative message"
	status = 100 
	    ifTrue: 
		["help text follows"

		^true].
	(status between: 190 and: 199) 
	    ifTrue: 
		["debug output"

		^false].

	"Command ok"
	status = 200 
	    ifTrue: 
		["server ready - posting allowed"

		^false].
	status = 201 
	    ifTrue: 
		["server ready - no posting allowed"

		^false].
	status = 202 
	    ifTrue: 
		["slave status noted"

		^false].
	status = 205 
	    ifTrue: 
		["closing connection - goodbye!"

		^false].
	status = 211 
	    ifTrue: 
		["n f l s group selected"

		^false].
	"### n f l s (n = estimated number of articles in group,
	 f = first article number in the group,
	 l = last article number in the group,
	 s = name of the group.)"
	status = 215 
	    ifTrue: 
		["list of newsgroups follows"

		^true].

	"### n <a> (n = article number, <a> = message-id)"
	status = 220 
	    ifTrue: 
		["article retrieved - head and body follows"

		^true].
	status = 221 
	    ifTrue: 
		["article retrieved - head follows"

		^true].
	status = 222 
	    ifTrue: 
		["article retrieved - body follows"

		^true].
	status = 223 
	    ifTrue: 
		["article retrieved - request text separately"

		^true].
	status = 224 
	    ifTrue: 
		["data follows"

		^true].
	status = 230 
	    ifTrue: 
		["list of new articles by message-id follows"

		^true].
	status = 231 
	    ifTrue: 
		["list of new newsgroups follows"

		^true].
	status = 235 
	    ifTrue: 
		["article transferred ok"

		^false].
	status = 240 
	    ifTrue: 
		["article posted ok"

		^false].

	"Command ok so far, send the rest of it"
	status = 335 
	    ifTrue: 
		["send article to be transferred"

		^false].
	status = 340 
	    ifTrue: 
		["send article to be posted"

		^false].

	"Command was correct, but couldn't be performed for some reason"
	status = 400 
	    ifTrue: 
		["service discontinued"

		^errorBlock value].
	status = 411 
	    ifTrue: 
		["no such news group"

		^errorBlock value].
	status = 412 
	    ifTrue: 
		["no newsgroup has been selected"

		^errorBlock value].
	status = 420 
	    ifTrue: 
		["no current article has been selected"

		^errorBlock value].
	status = 421 
	    ifTrue: 
		["no next article in this group"

		^errorBlock value].
	status = 422 
	    ifTrue: 
		["no previous article in this group"

		^errorBlock value].
	status = 423 
	    ifTrue: 
		["no such article number in this group"

		^errorBlock value].
	status = 430 
	    ifTrue: 
		["no such article found"

		^errorBlock value].
	status = 435 
	    ifTrue: 
		["article not wanted - do not send it"

		^errorBlock value].
	status = 436 
	    ifTrue: 
		["transfer failed - try again later"

		^errorBlock value].
	status = 437 
	    ifTrue: 
		["article rejected - do not try again."

		^errorBlock value].
	status = 440 
	    ifTrue: 
		["posting not allowed"

		^errorBlock value].
	status = 441 
	    ifTrue: 
		["posting failed"

		^errorBlock value].

	"Command unimplemented, or incorrect, or a serious program error occurred"
	status = 500 
	    ifTrue: 
		["command not recognized"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["command syntax error"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["access restriction or permission denied"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["program fault - command not performed"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    checkResponseForFollowingText: response [
	<category: 'private'>
	| textFollows |
	textFollows := self checkResponse: response
		    ifError: [self errorResponse: response. ^self].
	textFollows ifFalse: [self unexpectedResponse: response. ^self]
    ]

    defaultPortNumber [
	<category: 'private-attributes'>
	^119
    ]

    nextPutAll: aString [
	<category: 'stream accessing'>
	| retryCount |
	aString isEmpty ifTrue: [^self].
	retryCount := 0.
	[self connectionStream nextPutAll: (self encode: aString)] on: Error
	    do: 
		[:ex | 
		(retryCount := retryCount + 1) > 1 
		    ifTrue: [ex return]
		    ifFalse: 
			[self reconnect.
			ex restart]]
    ]
]

]

