"======================================================================
|
|   IMAP protocol unit tests
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

TestCase subclass: IMAPProtocolInterpreterTest [
    | pi |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    setUp [
	<category: 'running'>
	pi := IMAPProtocolInterpreter new.
	pi client: IMAPClient new
    ]

    testScript1 [
	<category: 'Testing'>
	self 
	    executeCompleteTestScript: 'C: abcd CAPABILITY
S: * CAPABILITY IMAP4rev1 AUTH=KERBEROS_V4
S: abcd OK CAPABILITY completed
' 
		    readStream
    ]

    testScript2 [
	<category: 'Testing'>
	| stream |
	stream := 'C: A003 APPEND saved-messages (\Seen) {309}
S: + Ready for additional command text
C: Date: Mon, 7 Feb 1994 21:52:25 -0800 (PST)
C: From: Fred Foobar <foobar@Blurdybloop.COM>
C: Subject: afternoon meeting
C: To: mooch@owatagu.siam.edu
C: Message-Id: <B27397-0100000@Blurdybloop.COM>
C: MIME-Version: 1.0
C: Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
C: 
C: Hello Joe, do you think we can meet at 3:30 tomorrow?
C: 1234567
S: A003 OK APPEND completed' 
		    readStream.
	self executeCompleteTestScript: stream
    ]

    executeCompleteTestScript: aStream [
	"Execute script respresenting complete execution of one or more commands.
	 At the end of the script all commands must have been completed, so there will be
	 no queued or outstanding commands and all returned commands will be in 'done' state"

	<category: 'utility'>
	| cmds |
	cmds := self executeTestScript: aStream.
	cmds last value.	"Wait for the last command"
	self assert: pi queuedCommands size = 0.
	self assert: pi commandsInProgress size = 0.
	cmds do: [:cmd | self assert: cmd isDone].
	^cmds
    ]

    executeTestScript: aStream [
	"Execute script is the form:
	 C: abcd CAPABILITY
	 S: * CAPABILITY IMAP4rev1 AUTH=KERBEROS_V4
	 S: abcd OK CAPABILITY completed
	 Lines starting with 'C: ' are client commands, lines starting with 'S: ' are server responses"

	<category: 'utility'>
	| cmd cmdStream respStream line |
	cmdStream := (String new: 64) writeStream.
	respStream := (String new: 64) writeStream.
	[aStream atEnd] whileFalse: 
		[cmd := aStream peek asUppercase.
		line := aStream
			    next: 3;
			    upTo: Character nl.
		cmd == $C 
		    ifTrue: 
			[cmdStream
			    nextPutAll: line;
			    nl]
		    ifFalse: 
			[respStream
			    nextPutAll: line;
			    nl]].
	pi responseStream: respStream contents readStream.
	^self sendCommandsFrom: cmdStream contents readStream
    ]

    sendCommandFrom: stream [
	<category: 'utility'>
	| cmd |
	cmd := IMAPCommand readFrom: stream.
	cmd client: pi.
	pi executeCommand: cmd.
	^cmd
    ]

    sendCommandsFrom: aStream [
	"Assumption currently is, every command occupies one line. This is because
	 IMAPComand>>readFrom reads until end of stream. So we will read command's line
	 from the stream and feed it to the command as a separate stream.
	 Answers ordered collection of commands sent"

	<category: 'utility'>
	| cmds |
	cmds := OrderedCollection new.
	pi connectionStream: (String new: 256) writeStream.
	[aStream atEnd] 
	    whileFalse: [cmds addLast: (self sendCommandFrom: aStream)].
	^cmds
    ]
]

]



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPResponseTest [
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    testFetch [
	<category: 'Testing'>
	| scanner resp str |
	str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	scanner := IMAPScanner on: str readStream.
	resp := IMAPResponse parse: scanner.
	self assert: (resp isKindOf: IMAPDataResponseFetch).
	self assert: resp cmdName = 'FETCH'.
	self assert: resp messageNumber = '12'.
	self assert: (resp bodyFetch parts isKindOf: SequenceableCollection).
	self assert: (resp bodyFetch parts 
		    allSatisfy: [:each | each sectionSpec specName = 'HEADER'])
    ]

    testResponseHandling [
	<category: 'Testing'>
	| command str |
	command := (IMAPCommand new)
		    sequenceID: 'a_1';
		    name: 'FETCH';
		    yourself.
	command client: IMAPProtocolInterpreter new.
	[command value] fork.
	self 
	    assert: (command handle: (IMAPResponse 
			    readFrom: '* FLAGS (\Seen \Answered \Deleted)' readStream)) 
		    not.
	self 
	    assert: (command handle: (IMAPResponse readFrom: 'a_2 OK bla' readStream)) 
		    not.
	self assert: command isDone not.
	str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	self assert: (command handle: (IMAPResponse readFrom: str readStream)).
	self assert: (command 
		    handle: (IMAPResponse readFrom: 'a_1 OK FETCH completed' readStream)).
	self assert: command isDone.
	self assert: command completionResponse status = 'OK'.
	self assert: command promise hasValue
    ]

    testTaggedMessages [
	<category: 'Testing'>
	| scanner resp |
	scanner := IMAPScanner on: 'oasis_1 OK LOGIN completed' readStream.
	resp := IMAPResponse parse: scanner.
	self assert: (resp isKindOf: IMAPResponseTagged).
	self assert: resp tag = 'oasis_1'.
	self assert: resp status = 'OK'.
	self assert: resp text = 'LOGIN completed'
    ]

    testUnTaggedMessages [
	<category: 'Testing'>
	| scanner resp |
	scanner := IMAPScanner on: '* FLAGS (\Seen \Answered \Deleted)' readStream.
	resp := IMAPResponse parse: scanner.
	self assert: resp cmdName = 'FLAGS'.
	self assert: resp value first = #('\Seen' '\Answered' '\Deleted')
    ]
]

]



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPTest [
    | client |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    login [
	"establish a socket connection to the IMAP server and log me in"

	<category: 'Running'>
	client := IMAPClient 
		    loginToHost: 'SKIPPER'
		    asUser: 'itktest'
		    withPassword: 'Cincom*062000'.
	self assert: (client isKindOf: IMAPClient)
    ]

    logout [
	<category: 'Running'>
	client logout
    ]

    testAppend [
	<category: 'Testing'>
	| message |
	self login.
	message := 'Date: Mon, 7 Feb 1994 21:52:25 -0800 (PST)
From: Fred Foobar <foobar@Blurdybloop.COM>
Subject: afternoon meeting
To: mooch@owatagu.siam.edu
Message-Id: <B27397-0100000@Blurdybloop.COM>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

Hello Joe, do you think we can meet at 3:30 tomorrow?'.
	client append: message to: 'inbox'.
	self logout
    ]

    testCreateRenameDelete [
	<category: 'Testing'>
	| comm box box1 |
	box := 'mybox'.
	box1 := 'myBoxRenamed'.
	self login.
	
	[comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client rename: box newName: box1.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: 
		    [client delete: box1.
		    self logout]
    ]

    testExamine [
	<category: 'Testing'>
	| box comm |
	self login.
	box := 'inbox'.
	comm := client examine: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self logout
    ]

    testList [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client list: 'news/' mailbox: 'mail/*'.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self assert: comm responses first mbName asUppercase = box asUppercase] 
		ensure: [comm := client delete: box].
	self logout
    ]

    testNoopCapability [
	<category: 'Testing'>
	| comm |
	self login.
	comm := client noop.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client capability.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self logout
    ]

    testSelectCheck [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client select: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client check.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: [comm := client delete: box]
    ]

    testSelectClose [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client select: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client close.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: [comm := client delete: box]
    ]

    testSelectExpunge [
	"Test case doesn't return untagged response: EXPUNGE as expected"

	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	box := 'inbox' asString.
	comm := client select: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client expunge.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully
    ]

    testSelectFetch [
	<category: 'Testing'>
	| box comm |
	self login.
	box := 'inbox' asString.
	client select: box.
	comm := client fetch: '2:3 (flags internaldate uid RFC822)'.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.



	"comm := client fetch: '2,4 (flags internaldate uid BODY.PEEK[header])'."
	"client fetch: '1:4 (uid Body.Peek[Header.Fields (Subject Date From Message-Id)])'."
	"client fetch: '1:2 (flags internaldate uid RFC822)'."
	"client fetch: '1 (Body.Peek[header])'."
	"comm := client fetch: '3 (BodyStructure)'."


	"client fetch: '2 full'."
	self logout
    ]

    testSelectSearch [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue: [ ^box]."

	| box |
	self login.
	box := 'inbox' asString.
	client select: box.
	client search: 'undeleted unanswered from "Kogan, Tamara"'.
	self logout
    ]

    testSelectStore [
	"| box |
	 
	 self login.
	 box := 'inbox' asString.
	 self assert: ((client select: box) == true).
	 (client store: '1:1 +FLAGS (\Deleted)') inspect.
	 (client store: '1:1 -FLAGS (\Deleted)') inspect.
	 
	 self logout."

	<category: 'Testing'>
	
    ]

    testSelectUID [
	"No expected response    | box |
	 
	 self login.
	 box := 'inbox' asString.
	 self assert: ((client select: box) == true).
	 (client uid: 'fetch 1:1 FLAGS') inspect.
	 self logout."

	<category: 'Testing'>
	
    ]

    testSubscribeUnsubLSUB [
	<category: 'Testing'>
	| box comm |
	box := nil.
	box isNil ifTrue: [^nil].
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client subscribe: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client lsub: 'news/' mailbox: 'mail/*'.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self assert: comm responses first mbName asUppercase = box asUppercase.
	comm := client unsubscribe: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: [comm := client delete: box].
	self logout
    ]
]

]



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPScannerTest [
    | parser |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    setUp [
	<category: 'running'>
	parser := IMAPScanner new
    ]

    stream6 [
	<category: 'running'>
	| str |
	str := (String new: 512) writeStream.
	str
	    nextPutAll: '* 12 FETCH (FLAGS (\Seen) INTERNALDATE "17-Jul-1996 02:44:25 -0700"
 RFC822.SIZE 4286 ENVELOPE ("Wed, 17 Jul 1996 02:23:25 -0700 (PDT)"
 "IMAP4rev1 WG mtg summary and minutes"
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 ((NIL NIL "imap" "cac.washington.edu"))
 ((NIL NIL "minutes" "CNRI.Reston.VA.US")
 ("John Klensin" NIL "KLENSIN" "INFOODS.MIT.EDU")) NIL NIL
 "<B27397-0100000@cac.washington.edu>")
  BODY ("TEXT" "PLAIN" ("CHARSET" "US-ASCII") NIL NIL "7BIT" 3028 92))
';
	    nl.
	^str
    ]

    testDeepTokenize [
	<category: 'testing'>
	| tokens |
	tokens := parser
		    on: '* FLAGS (\Seen \Answered \Flagged \Deleted XDraft)' readStream;
		    deepTokenize.
	self assert: tokens 
		    = #($* 'FLAGS' #('\Seen' '\Answered' '\Flagged' '\Deleted' 'XDraft')).
	self assert: parser atEnd
    ]

    testDeepTokenize1 [
	<category: 'testing'>
	| tokens |
	tokens := parser
		    on: '(BODYSTRUCTURE (("TEXT" "PLAIN" ("charset" "iso-8859-1") NIL nil "QUOTED-PRINTABLE" 7 2 NIL NIL NIL)("APPLICATION" "OCTET-STREAM" ("name" "StoreErrorDialog.st") NiL NIL "BASE64" 4176 NIL NIL NIL) "mixed" ("boundary" "=_STAMPed_MAIL_=") NIL NIL))' 
				readStream;
		    deepTokenize.
	self assert: tokens 
		    = #(#('BODYSTRUCTURE' #(#('TEXT' 'PLAIN' #('charset' 'iso-8859-1') nil nil 'QUOTED-PRINTABLE' '7' '2' nil nil nil) #('APPLICATION' 'OCTET-STREAM' #('name' 'StoreErrorDialog.st') nil nil 'BASE64' '4176' nil nil nil) 'mixed' #('boundary' '=_STAMPed_MAIL_=') nil nil))).
	self assert: parser atEnd.
	tokens := parser
		    on: '(BODYSTRUCTURE (("TEXT" "PLAIN" ("charset" "iso-8859-1") NIL NIL "QUOTED-PRINTABLE" 7 2 NIL NIL NIL)("APPLICATION" "OCTET-STREAM" ("name" "StoreErrorDialog.st") NIL NIL "BASE64" 4176 NIL NIL NIL) "mixed" ("boundary" "=_STAMPed_MAIL_=") NIL NIL))' 
				readStream;
		    deepTokenizeAsAssociation
    ]

    testDeepTokenizeAsAssoc [
	<category: 'testing'>
	| tokens str |
	str := '* 12 "FETCH" ((a b nil) BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	tokens := parser
		    on: str readStream;
		    deepTokenizeAsAssociation.
	self assert: tokens first = (#special -> $*).
	self assert: (tokens at: 2) = (#atom -> '12').
	self assert: (tokens at: 3) = (#quotedText -> 'FETCH').
	self assert: (tokens at: 4) 
		    = (#parenthesizedList -> (Array 
				    with: #parenthesizedList -> (Array 
						    with: #atom -> 'a'
						    with: #atom -> 'b'
						    with: #nil -> nil)
				    with: #atom -> 'BODY[HEADER]'
				    with: #literalString 
					    -> 'Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

')).
	self assert: parser atEnd
    ]

    testLiteralStrings [
	<category: 'testing'>
	| tokens str |
	str := '* 12 FETCH (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.	"Extra char for every cr -- will be different in external streams"
	tokens := parser
		    on: str readStream;
		    deepTokenize.
	self assert: tokens 
		    = #($* '12' 'FETCH' #('BODY[HEADER]' 'Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

')).
	self assert: parser atEnd
    ]

    testSourceTrail [
	<category: 'testing'>
	| str trail |
	str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	parser
	    on: str readStream;
	    sourceTrailOn;
	    deepTokenizeAsAssociation.
	trail := parser sourceTrail.
	self assert: trail = str.
	self assert: parser sourceTrail isNil.
	self assert: parser atEnd
    ]

    testTaggedResponses [
	<category: 'testing'>
	| tokens |
	tokens := parser
		    on: 'oasis_3 OK FETCH completed.' readStream;
		    tokenize.
	self assert: tokens = #('oasis_3' 'OK' 'FETCH' 'completed.').
	self assert: parser atEnd
    ]
]

]
