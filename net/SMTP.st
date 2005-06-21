"======================================================================
|
|   SMTP protocol support
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


Namespace current: NetClients.SMTP!

NetClient subclass:  #SMTPClient
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: 'MIME '
	category: 'NetClients-SMTP'!

SMTPClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetClient subclass:  #SMTPClient
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: 'MIME '
	category: 'NetClients-SMTP'!

SMTPClient comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetProtocolInterpreter subclass:  #SMTPProtocolInterpreter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: 'MIME '
	category: 'NetClients-SMTP'!

SMTPProtocolInterpreter comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'!

NetClientError subclass:  #SMTPNoSuchRecipientError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-SMTP'!

SMTPNoSuchRecipientError comment: 
nil!


!SMTPClient class methodsFor: 'examples'!

example2Host: host
    "self example2Host: 'localhost'."

    | user message client |
    user := '%1@%2'
	bindWith: (Smalltalk getenv: 'USER')
	with: IPAddress localHostName.

    message := MIME.MimeEntity readFrom:
('From: ', user, '
To: ', user, '
To: foo', user, '
Bcc: ', user, '
Subject: Test mail from Smalltalk (SMTPClient)

This is a test mail from Smalltalk (SMTPClient).
') readStream.
    client := SMTPClient connectToHost: host.
    [[client sendMessage: message]
	on: SMTPNoSuchRecipientError
    	do: [:ex | ex inspect; return]
    ] ensure: [client close].!

exampleHost: host
    "self exampleHost: 'localhost'."

    | user message client |
    user := '%1@%2'
	bindWith: (Smalltalk getenv: 'USER')
	with: IPAddress localHostName.
    message := MIME.MimeEntity readFrom:
('From: ', user, '
To: ', user, '
Bcc: ', user, '
Subject: Test mail from Smalltalk (SMTPClient)

This is a test mail from Smalltalk (SMTPClient).
') readStream.
    client := SMTPClient connectToHost: host.
    [client sendMessage: message]
    	ensure: [client close].! !

!SMTPClient methodsFor: 'accessing'!

logout
    self clientPI smtpQuit!

sendMailStream: aStream sender: sender recipients: recipients
    self connectIfClosed.
    self clientPI smtpHello: self getHostname.
    self clientPI smtpMail: sender.
    recipients do: [:addr | self clientPI smtpRecipient: addr].
    self clientPI smtpData: [
        self clientPI sendMessageWithPeriod: aStream ]!

sendMessage: aMessage
    | sender recipients |
    aMessage inspect.
    (aMessage sender isNil or: [
        (sender := aMessage sender addresses) isEmpty ])
	    ifTrue: [^self error: 'No sender'].

    sender size > 1 ifTrue: [^self error: 'Invalid sender'].
    sender := sender first.
    recipients := aMessage recipients.
    ^self sendMessage: aMessage sender: sender recipients: recipients!

sendMessage: aMessage sender: sender recipients: recipients
    self connectIfClosed.
    self clientPI smtpHello: self getHostname.
    self clientPI smtpMail: sender.
    recipients do: [:addr | self clientPI smtpRecipient: addr].
    self clientPI smtpData: [
        aMessage printMessageOnClient: self clientPI ]! !

!SMTPClient methodsFor: 'private'!

getHostname
    ^IPAddress localHostName!

protocolInterpreter
    ^SMTPProtocolInterpreter! !

!SMTPProtocolInterpreter class methodsFor: 'private-attributes'!

defaultPortNumber
    ^25! !

!SMTPProtocolInterpreter methodsFor: 'private'!

checkResponse: response ifError: errorBlock
    | status |
    status := response status.

    "Positive Completion reply"
    status = 211 "System status, or system help reply"	ifTrue: [^self].
    status = 214 "Help message"						ifTrue: [^self].
    status = 220 "Service ready"						ifTrue: [^self].
    status = 221 "Service closing channel"			ifTrue: [^self].
    status = 250 "Requested mail action okay"			ifTrue: [^self].
    status = 251 "User not local; will forward"			ifTrue: [^self].

    "Positive Intermediate reply"
    status = 354 "Start mail input"						ifTrue: [^self].

    "Transient Negative Completion reply"
    status = 421 "Service not available"				ifTrue: [^errorBlock value].
    status = 450 "Requested mail action not taken"		ifTrue: [^errorBlock value].
    status = 451 "Requested action aborted"			ifTrue: [^errorBlock value].
    status = 452 "Requested action not taken"			ifTrue: [^errorBlock value].

    "Permanent Negative Completion reply"
    status = 500 "Syntax error"						ifTrue: [^errorBlock value].
    status = 501 "Syntax error in parameters"			ifTrue: [^errorBlock value].
    status = 502 "Command not implemented"			ifTrue: [^errorBlock value].
    status = 503 "Bad sequence of commands"		ifTrue: [^errorBlock value].
    status = 504 "Command parameter not implemented"	ifTrue: [^errorBlock value].

    status = 550 "Requested action not taken"			ifTrue: [^errorBlock value].
    status = 551 "User not local; please try"			ifTrue: [^errorBlock value].
    status = 552 "Requested mail action aborted"		ifTrue: [^errorBlock value].
    status = 553 "Requested action not taken"			ifTrue: [^errorBlock value].
    status = 554 "Transaction failed"					ifTrue: [^errorBlock value].

    "Unknown status"
    ^errorBlock value!

noSuchRecipientNotify: errorString
    ^SMTPNoSuchRecipientError signal: errorString.! !

!SMTPProtocolInterpreter methodsFor: 'smtp protocol'!

connect
    super connect.
    self checkResponse!

smtpData: streamBlock
    self nextPutAll: 'DATA'; nl.
    self checkResponse.
    streamBlock value.
    self checkResponse!

smtpExpand: aString
    self nextPutAll: ('EXPN ', aString); nl.
    self checkResponse!

smtpHello: domain
    self nextPutAll: ('HELO ', domain); nl.
    self checkResponse!

smtpHelp
    self nextPutAll: 'HELP'; nl.
    self checkResponse!

smtpHelp: aString
    self nextPutAll: ('HELP ', aString); nl.
    self checkResponse!

smtpMail: reversePath
    self nextPutAll: ('MAIL FROM: <', reversePath displayString, '>'); nl.
    self checkResponse!

smtpNoop
    self nextPutAll: 'NOOP'; nl.
    self checkResponse!

smtpQuit
    self nextPutAll: 'QUIT'; nl.
    self checkResponse!

smtpRecipient: forwardPath
    | response |
    self nextPutAll: ('RCPT TO: <', forwardPath displayString, '>'); nl.
    response := self getResponse.
    self
    	checkResponse: response
    	ifError:
    		[| status |
    		status := response status.
    		(status = 550 or:	"Requested action not taken"
    		 [status = 551])	"User not local; please try"
    			ifTrue:	[self noSuchRecipientNotify: forwardPath]
    			ifFalse:	[self protocolError: response statusMessage]]!

smtpReset
    self nextPutAll: 'RSET'; nl.
    self checkResponse!

smtpSend: reversePath
    self nextPutAll: ('SEND FROM: <', reversePath displayString, '>'); nl.
    self checkResponse!

smtpSendAndMail: reversePath
    self nextPutAll: ('SAML FROM: <', reversePath displayString, '>'); nl.
    self checkResponse!

smtpSendOrMail: reversePath
    self nextPutAll: ('SOML FROM: <', reversePath displayString, '>'); nl.
    self checkResponse!

smtpTurn
    self nextPutAll: 'TURN'; nl.
    self checkResponse!

smtpVerify: aString
    self nextPutAll: ('VRFY ', aString); nl.
    self checkResponse! !


Namespace current: Smalltalk!
