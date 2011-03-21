"======================================================================
|
|   SMTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2009 Free Software Foundation, Inc.
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



Namespace current: NetClients.SMTP [

NetClient subclass: SMTPClient [
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-SMTP'>

    SMTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^25
    ]

    SMTPClient class >> example2Host: host [
	"self example2Host: 'localhost'."

	<category: 'examples'>
	| user message client |
	user := '%1@%2' % 
			{Smalltalk getenv: 'USER'.
			IPAddress localHostName}.
	message := MIME.MimeEntity 
		    readFrom: ('From: ' , user , '
To: ' , user , '
To: foo' , user , '
Bcc: ' 
			    , user 
				, '
Subject: Test mail from Smalltalk (SMTPClient)

This is a test mail from Smalltalk (SMTPClient).
') 
				readStream.
	client := SMTPClient connectToHost: host.
	
	[[client sendMessage: message] on: SMTPNoSuchRecipientError
	    do: 
		[:ex | 
		ex
		    inspect;
		    return]] 
		ensure: [client close]
    ]

    SMTPClient class >> exampleHost: host [
	"self exampleHost: 'localhost'."

	<category: 'examples'>
	| user message client |
	user := '%1@%2' % 
			{Smalltalk getenv: 'USER'.
			IPAddress localHostName}.
	message := MIME.MimeEntity 
		    readFrom: ('From: ' , user , '
To: ' , user , '
Bcc: ' , user 
			    , '
Subject: Test mail from Smalltalk (SMTPClient)

This is a test mail from Smalltalk (SMTPClient).
') 
				readStream.
	client := SMTPClient connectToHost: host.
	[client sendMessage: message] ensure: [client close]
    ]

    logout [
	<category: 'accessing'>
	self clientPI smtpQuit
    ]

    sendMailStream: aStream sender: sender recipients: recipients [
	<category: 'accessing'>
	self connectIfClosed.
	self clientPI smtpHello: self getHostname.
	(self clientPI isESMTP and: [self username isNil]) ifFalse: [
            self clientPI esmtpAuthLogin: self username.
            self password isNil ifFalse: [
		self clientPI esmtpPassword: self password ]].
	self clientPI smtpMail: sender.
	recipients do: [:addr | self clientPI smtpRecipient: addr].
	self clientPI smtpData: [self clientPI sendMessageWithPeriod: aStream]
    ]

    sendMessage: aMessage [
	<category: 'accessing'>
	| sender recipients |
	aMessage inspect.
	(aMessage sender isNil or: [(sender := aMessage sender addresses) isEmpty]) 
	    ifTrue: [^self error: 'No sender'].
	sender size > 1 ifTrue: [^self error: 'Invalid sender'].
	sender := sender first.
	recipients := aMessage recipients.
	^self 
	    sendMessage: aMessage
	    sender: sender
	    recipients: recipients
    ]

    sendMessage: aMessage sender: sender recipients: recipients [
	<category: 'accessing'>
	self connectIfClosed.
	self clientPI smtpHello: self getHostname.
	(self clientPI isESMTP and: [self username isNil]) ifFalse: [
            self clientPI esmtpAuthLogin: self username.
            self password isNil ifFalse: [
		self clientPI esmtpPassword: self password ]].
	self clientPI smtpMail: sender.
	recipients do: [:addr | self clientPI smtpRecipient: addr].
	self clientPI smtpData: [aMessage printMessageOnClient: self clientPI]
    ]

    getHostname [
	<category: 'private'>
	^IPAddress localHostName
    ]

    protocolInterpreter [
	<category: 'private'>
	^SMTPProtocolInterpreter
    ]
]

]



Namespace current: NetClients.SMTP [

NetProtocolInterpreter subclass: SMTPProtocolInterpreter [
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-SMTP'>

    | esmtp |

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.

	"Positive Completion reply"
	status = 211 
	    ifTrue: 
		["System status, or system help reply"

		^self].
	status = 214 
	    ifTrue: 
		["Help message"

		^self].
	status = 220 
	    ifTrue: 
		["Service ready"

		^self].
	status = 221 
	    ifTrue: 
		["Service closing channel"

		^self].
        status = 235
            ifTrue:
                ["Authentication successful"

                ^self].
	status = 250 
	    ifTrue: 
		["Requested mail action okay"

		^self].
	status = 251 
	    ifTrue: 
		["User not local; will forward"

		^self].

	"Positive Intermediate reply"
        status = 334
            ifTrue:
                ["Authentication password"

                ^self].
	status = 354 
	    ifTrue: 
		["Start mail input"

		^self].

	"Transient Negative Completion reply"
	status = 421 
	    ifTrue: 
		["Service not available"

		^errorBlock value].
	status = 450 
	    ifTrue: 
		["Requested mail action not taken"

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
		["Syntax error in parameters"

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
		["Command parameter not implemented"

		^errorBlock value].
	status = 550 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].
	status = 551 
	    ifTrue: 
		["User not local; please try"

		^errorBlock value].
	status = 552 
	    ifTrue: 
		["Requested mail action aborted"

		^errorBlock value].
	status = 553 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].
	status = 554 
	    ifTrue: 
		["Transaction failed"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    noSuchRecipientNotify: errorString [
	<category: 'private'>
	^SMTPNoSuchRecipientError signal: errorString
    ]

    connect [
	<category: 'smtp protocol'>
	| response |
	super connect.
	response := self getResponse.
	esmtp := response statusMessage ~ 'ESMTP'.
	self checkResponse: response
    ]

    isESMTP [
	<category: 'accssing'>
	^esmtp
    ]

    esmtpAuthLogin: user [
        <category: 'esmtp protocol'>
        self
            nextPutAll: 'AUTH LOGIN ', (self class base64Encode: user);
            nl.
        self checkResponse.
    ]

    esmtpPassword: password [
        <category: 'esmtp protocol'>
        self
            nextPutAll: (self class base64Encode: password);
            nl.
        self checkResponse
    ]

    smtpData: streamBlock [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'DATA';
	    nl.
	self checkResponse.
	streamBlock value.
	self checkResponse
    ]

    smtpExpand: aString [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'EXPN ' , aString;
	    nl.
	self checkResponse
    ]

    smtpHello: domain [
	<category: 'smtp protocol'>
	self
	    nextPutAll: ('%<EHLO|HELO>1 %2' % {esmtp. domain});
	    nl.
	self checkResponse
    ]

    smtpHelp [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'HELP';
	    nl.
	self checkResponse
    ]

    smtpHelp: aString [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'HELP ' , aString;
	    nl.
	self checkResponse
    ]

    smtpMail: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'MAIL FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpNoop [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'NOOP';
	    nl.
	self checkResponse
    ]

    smtpQuit [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'QUIT';
	    nl.
	self checkResponse
    ]

    smtpRecipient: forwardPath [
	<category: 'smtp protocol'>
	| response |
	self
	    nextPutAll: 'RCPT TO: <' , forwardPath displayString , '>';
	    nl.
	response := self getResponse.
	self checkResponse: response
	    ifError: 
		[| status |
		status := response status.
		(status = 550 or: 
			["Requested action not taken"

			status = 551]) 
		    ifTrue: 
			["User not local; please try"

			self noSuchRecipientNotify: forwardPath]
		    ifFalse: [self errorResponse: response]]
    ]

    smtpReset [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'RSET';
	    nl.
	self checkResponse
    ]

    smtpSend: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'SEND FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpSendAndMail: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'SAML FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpSendOrMail: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'SOML FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpTurn [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'TURN';
	    nl.
	self checkResponse
    ]

    smtpVerify: aString [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'VRFY ' , aString;
	    nl.
	self checkResponse
    ]
]

]



Namespace current: NetClients.SMTP [

NetClientError subclass: SMTPNoSuchRecipientError [
    
    <comment: nil>
    <category: 'NetClients-SMTP'>
]

]

