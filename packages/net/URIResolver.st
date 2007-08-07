"======================================================================
|
|   URL resolving and on-disk storage support
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


Object subclass:  #URIResolver
	instanceVariableNames: 'url reporter noCache client entity '
	classVariableNames: ''
	poolDictionaries: 'TCP MIME '
	category: 'NetClients-URIResolver'!

URIResolver comment: 
'
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.

'!

MIME.MimeEntity subclass:  #WebEntity
	instanceVariableNames: 'url canCache localFileName '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetSupport-WWW-Objects'!

WebEntity comment: 
nil!

Object subclass:  #UserProfileSettings
	instanceVariableNames: 'settings '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'NetClients-URIResolver'!

UserProfileSettings class
	instanceVariableNames: 'default'!

UserProfileSettings comment: 
nil!


!URIResolver class methodsFor: 'api'!

openOn: aURI ifFail: aBlock
    "Check if aURI can be fetched from the Internet or from the local system,
     and if so return a WebEntity with its contents.  If this is not possible,
     instead, evaluate the zero-argument block aBlock and answer the result
     of the evaluation."

    | url body entity |
    url := aURI.
    (url respondsTo: #key) ifTrue: [ url := url key, ':/', url value ].
    url isString ifTrue: [ url := URL fromString: url ].

    [ entity := (self on: url)
	noCache: true;
	contentsNoSignal ] on: Error do: [ :sig | sig return: aBlock value ].

    ^entity!

openStreamOn: aURI ifFail: aBlock
    "Check if aURI can be fetched from the Internet or from the local system,
     and if so return a Stream with its contents.  If this is not possible,
     instead, evaluate the zero-argument block aBlock and answer the result
     of the evaluation."

    | entity |
    entity := self openOn: aURI ifFail: [ ^aBlock value ].
    ^entity stream!

!URIResolver methodsFor: 'private'!

createClient: class
    | host |
    host := url host isNil ifTrue: [SocketAddress localHostName] ifFalse: [url host].
    client := class connectToHost: host port: url port.
!

createClient: class host: host port: port
    client := class connectToHost: host port: port.
!

connect
    client reporter: self reporter.
    url username isNil
	ifFalse: [ client username: url username password: url password ].

    client reporter statusString: 'Connecting'.

    [client connect]
	on: ConnectionFailedError
	do: [:ex | ^self errorContents: ex tag].

! !

!URIResolver methodsFor: 'accessing'!

noCache
    noCache isNil ifTrue: [ noCache := false ].
    ^noCache
!

noCache: aBoolean
    noCache := aBoolean
!

reporter
    ^reporter
!

reporter: aReporter
    reporter := aReporter.
    client isNil ifFalse: [ client reporter: self reporter ]!

entity
    ^entity
!

contentsNoSignal
    | scheme contents |
    (entity notNil and: [ noCache not ]) ifTrue: [ ^entity ].

    url hasPostData ifTrue:
	[contents := MimeEntity new
		addField: ContentTypeField urlEncoded;
		body: url postData;
		yourself.

	^self postContentsNoSignal: contents].

    scheme := url scheme.

    scheme = 'http'	ifTrue: [^entity := self getHttpContents].
    scheme = 'ftp'	ifTrue: [^entity := self getFtpContents].
    scheme = 'mailto'	ifTrue: [^entity := self getMailToContents].
    scheme = 'news'	ifTrue: [^entity := self getNewsContents].
    scheme = 'nntp'	ifTrue: [^entity := self getNntpContents].
    scheme = 'postto'	ifTrue: [^entity := self getPostToContents].

    url isFileScheme		ifTrue: [^entity := self getFileContents].

    ^self errorContents: 'Unsupported protocol'!

contents
    | messageText |

    [^self contentsNoSignal]
	on: Error
	do: [:ex | messageText := ex messageText. ex return].

    ^self errorContents: messageText!

getHeadNoSignal
    | scheme |
    url hasPostData ifTrue:
	[^self errorContents: 'Unsupported post'].

    scheme := url scheme.
    scheme = 'http'		ifTrue: [^self getHttpHead].
    ^self errorContents: 'Unsupported protocol'!

getHead
    | messageText |

    [^self getHeadNoSignal]
	on: Error
	do: [:ex | messageText := ex messageText. ex return].

    ^self errorContents: messageText!

postContents: contents
    | messageText |

    [^self postContentNoSignal: contents]
	on: Error
	do: [:ex | messageText := ex messageText. ex return].

    ^self errorContents: messageText.

    "^self postContentsNoSignal: contents "!

postContentsNoSignal: contents 
    | scheme |

    scheme := url scheme.
    scheme = 'http'	ifTrue: [^self postHttpContents: contents].
    scheme = 'mailto'	ifTrue: [^self postMailToContents: contents].
    scheme = 'postto'	ifTrue: [^self postPostToContents: contents].

    ^self errorContents: 'Unsupported protocol'! !

!URIResolver methodsFor: 'file accessing'!

getDirectoryContentsOf: aDirectory
    | maxSize stream title contents |
    maxSize := 32.
    stream := ReadWriteStream on: (String new: 512).
    title := 'Directory listing of ', aDirectory fullName.
    stream nextPutAll:
'Content-type: text/html

<html>
<head>
<title>', title, '</title>
</head>
<body>
<h2>', title, '</h2>
'.

    stream nextPutAll: '<pre>'; nl.
    stream nextPutAll: '<a href="file:', aDirectory path, '" class="upfolder">'.
    stream nextPutAll: 'Up to higher level directory</a>'; nl; nl.

    aDirectory contents asSortedCollection do: [:name |
	| file isDirectory fileSize |
	file := aDirectory at: name. 
	[isDirectory := file isDirectory.
	 fileSize := file size]
		on: Error
		do: [:ex |
			isDirectory := false.
			fileSize := 0.
			ex return].

	stream tab; nextPutAll: '<a href="file:', file fullName, '" class="'.

	isDirectory
		ifTrue: [stream nextPutAll: 'folder']
		ifFalse: [stream nextPutAll: 'document'].

	stream nextPutAll: '">'.

	stream nextPutAll: name; nextPutAll: '</a>'.
	name size <= maxSize 
	    ifFalse: [ stream nl; tab; next: maxSize put: $ ]
	    ifTrue: [ stream next: maxSize - name size put: $ ].

	fileSize := fileSize printString.
	fileSize size < 8
	    ifTrue: [stream next: 8 - fileSize size put: $ ].

	stream nextPutAll: fileSize; nextPutAll: ' bytes'.
	stream nl
    ].

    stream nextPutAll: '</pre>'; nl.
    stream nextPutAll:
'</body>
</html>'.

    stream reset.
    ^(WebEntity readFrom: stream)
	url: url;
        canCache: false;
	yourself!

getFileContents
    | file result |

    file := url path isNil
	ifTrue: [ File name: '/' ]
	ifFalse: [ File name: url path ].

    file exists not
	ifTrue: [^self errorContents: 'No such file'].

    file isReadable
	ifFalse: [^self errorContents: 'Cannot read'].

    file isDirectory
	ifTrue: [^self getDirectoryContentsOf: (Directory name: file name) ].

    ^WebEntity new
	url: url;
        canCache: false;
	localFileName: url path;
	guessMimeType;
	yourself! !

!URIResolver methodsFor: 'ftp accessing'!

getFtpContents
    | contents path tmpFile type stream |
    contents := self
			getProxyContentsHost: 'ftpProxyHost'
			port: 'ftpProxyPort'.

    contents notNil ifTrue: [^contents].

    self createClient: FTP.FTPClient.

    [| user mail |
	user := NetUser new.
	url username isNil
	    ifTrue: [ user username: 'anonymous' ]
	    ifFalse: [ user username: url username ].

	url password isNil
	    ifTrue: [
		"Anonymous FTP, send e-mail address as password"
		mail := UserProfileSettings default settingAt: #mailAddress.
		(mail isNil or: [ '*@*.*' match: mail ]) ifTrue: [ mail := 'gst@' ].

		user password: mail]
	    ifFalse: [
		user password: url password ].

	client user: user; login
    ]
	on: NetClientError
	do: [:ex | client close. ^self errorContents: ex tag].

    client reporter statusString: 'Connect: Host contacted. Waiting for reply...'.

    (url path isNil or: [url path isEmpty])
	ifTrue: [path := '/']
	ifFalse: [path := url path].

    stream := self tmpFile.
    tmpFile := File name: stream name.

    ^[
	[
	    client
	        getFile: path
	        type: #binary
	        into: stream
	 ] ensure: [ stream close ].

	 WebEntity new
	     url: url;
             canCache: false;
	     localFileName: tmpFile name;
	     guessMimeType;
	     yourself.
     ]
	on: NetClientError
        do: [:ex | ^self errorContents: ex messageText ]

        on: FTP.FTPFileNotFoundError
	do: [:ex |
	    tmpFile exists ifTrue: [tmpFile remove].
	    stream := ReadWriteStream on: (String new: 512).

	    ^[
		(path at: path size) = '/'
		    ifFalse: [ path := path copyWith: $/ ].

	        client
		    getList: path
		    into: stream.

		stream reset.
		self getFtpDirectoryContentsFrom: stream
	    ]   on: FTP.FTPFileNotFoundError
		do: [:ex | ^self errorContents: ex messageText ].
	]!

getFtpDirectoryContentsFrom: aStream
    | baseURL maxSize stream title contents sp read mode ftype fileSize name
      newURL index |
    baseURL := url copy.
    baseURL path isNil
	ifTrue: [baseURL path: '/junk']
	ifFalse: [baseURL path: (Directory append: 'junk' to: baseURL path)].

    maxSize := 32.
    stream := ReadWriteStream on: (String new: 512).
    title := 'Directory listing of ', url printString.

    stream nextPutAll:
'Content-type: text/html

<html>
<head>
<title>', title, '</title>
</head>
<body>
<h2>', title, '</h2>
'.

    "-rwxr-xr-x  1 user    group         512 Aug  8 05:57 file"
    "drwxr-xr-x  1 user    group         512 Aug  8 05:57 directory"
    "lrwxrwxrwx  1 user    group         512 Aug  8 05:57 symlink"
    "brwxr-xr-x  1 user    group         0, 1 Aug  8 05:57 block-device"
    "crwxr-xr-x  1 user    group         1, 2 Aug  8 05:57 character-device"
    "p---------  1 user    group         0 Aug  8 05:57 pipe"


    stream nextPutAll: '<pre>'; nl.
    baseURL path isNil ifFalse: [
        stream
	    nextPutAll: '<a href="';
	    print: (baseURL construct: (URL fromString: '..'));
	    nextPutAll: '" class="upfolder">'
    ].

    stream nextPutAll: 'Up to higher level directory</a>'; nl; nl.
    [aStream atEnd] whileFalse:
	[sp := Character space.
	read := (aStream upTo: Character nl) readStream.
	mode := read upTo: sp.
	mode isEmpty
		ifTrue: [ftype := nil]
		ifFalse: [ftype := mode first].
	read skipSeparators.
	read upTo: sp.	"nlink"
	read skipSeparators.
	read upTo: sp.	"user"
	read skipSeparators.
	read upTo: sp.	"group"
	read skipSeparators.
	(ftype = $b or: [ftype = $c])
		ifTrue:
			[fileSize := '0'.
			read upTo: sp.	"major"
			read skipSeparators.
			read upTo: sp.	"minor"]
		ifFalse:
			[fileSize := read upTo: sp].

	read skipSeparators.
	read upTo: sp.	"month"
	read skipSeparators.
	read upTo: sp.	"day"
	read skipSeparators.
	read upTo: sp.	"time"
	read skipSeparators.
	name := read upToEnd trimSeparators.

	(ftype isNil or: [name isEmpty or: [name = '.' or: [name = '..']]]) ifFalse:
		[ftype = $l
			ifTrue: "symbolic link"
				[index := name indexOfSubCollection: ' -> ' startingAt: 1.
				index > 0
					ifTrue:
						[newURL := baseURL construct: (URL fromString: (name copyFrom: index + 4 to: name size)).
						name := name copyFrom: 1 to: index - 1]
					ifFalse:
						[newURL := baseURL construct: (URL fromString: name)]]

			ifFalse:
				[(ftype = $- or: [ftype = $d])
					ifTrue: [newURL := baseURL construct: (URL fromString: name)]
					ifFalse: [newURL := nil]].

		stream tab.
		newURL isNil
			ifTrue: [stream nextPutAll: '<span class="']
			ifFalse: [stream nextPutAll: '<a href="', newURL printString, '" class="'].

		ftype = $d
			ifTrue: [stream nextPutAll: 'folder']
			ifFalse: [ftype = $l
				ifTrue: [stream nextPutAll: 'symlink']
				ifFalse: [stream nextPutAll: 'document']].

		stream nextPutAll: '">'.

		name size <= maxSize
			ifTrue: [stream nextPutAll: name.
					newURL isNil ifFalse: [stream nextPutAll: '</a>'].
					maxSize - name size timesRepeat: [stream space]]

			ifFalse: [stream nextPutAll: name.
					newURL isNil ifFalse: [stream nextPutAll: '</a>'].
					stream nl; tab.
					maxSize timesRepeat: [stream space]].

		fileSize size < 8
			ifTrue: [8 - fileSize size timesRepeat: [stream space]].

		stream nextPutAll: fileSize; nextPutAll: ' bytes'.
		stream nl].

    ].

    stream nextPutAll: '</pre>'; nl.
    stream nextPutAll:
'</body>
</html>'.

    stream reset.
    ^(WebEntity readFrom: stream)
	url: url;
	canCache: false;
	yourself! !

!URIResolver methodsFor: 'http accessing'!

getHttpContents
    | contents urlString |

    contents := self
			getProxyContentsHost: 'httpProxyHost'
			port: 'httpProxyPort'.

    contents notNil ifTrue: [^contents].
    self createClient: HTTP.HTTPClient.
    ^self requestHttpContents: url requestString!

requestHttpContents: urlString
    | requestHeaders tmpFile stream protocolError response type string |

    requestHeaders := OrderedCollection new.
    requestHeaders add: ('User-Agent: GNU-Smalltalk/', Smalltalk version).
    requestHeaders add: ('Accept: text/html, image/gif, */*; q=0.2').
    requestHeaders add: ('Host: ', url host).

    noCache ifTrue:
	[requestHeaders add: ('Pragma: no-cache')].

    client reporter statusString: 'Connecting'.
    protocolError := false.

    client reporter statusString: 'Connect: Host contacted. Waiting for reply...'.

    stream := self tmpFile.
    tmpFile := File name: stream name.
    [
	[
	    [response := client
			     get: urlString
			     requestHeaders: requestHeaders
			     into: stream
	    ] ensure: [client close]
        ]
	    on: NetClientError
	    do: [:ex | ^self errorContents: ex messageText]

	    on: ProtocolError
	    do: [:ex | protocolError := true. ex return]

	    on: HTTP.HTTPRedirection
	    do: [:ex |
		| location |
		location := ex tag.
		location isNil
			ifTrue: [^self errorContents: 'Moved elsewhere']
			ifFalse: [client reporter statusString: 'Redirecting'.
				  stream close. stream := nil.
				  tmpFile exists ifTrue: [tmpFile remove].
				  ^(self class on: (url construct: (URL fromString: location)))
					noCache: self noCache;
					reporter: self reporter;
					contents]]

    ] ensure: [stream isNil ifFalse: [stream close]].

    ^protocolError
	ifTrue: [
		string := tmpFile contents.
		tmpFile remove.

	        (WebEntity readFrom: string readStream type: type)
		    url: url;
		    canCache: false;
	            guessMimeType;
		    yourself]

	ifFalse: [
	        WebEntity new
		    url: url;
		    canCache: noCache not;
		    localFileName: tmpFile name;
	            guessMimeType;
		    yourself]!

getHttpHead
    | contents |
    contents := self
			getProxyHeadHost: 'httpProxyHost'
			port: 'httpProxyPort'.

    contents notNil ifTrue: [^contents].
    self createClient: HTTP.HTTPClient.

    ^self requestHttpHead: url requestString!

requestHttpHead: urlString
    | requestHeaders tmpFile stream protocolError response type string |
    requestHeaders := OrderedCollection new.
    requestHeaders add: ('User-Agent: GNU-Smalltalk/', Smalltalk version).
    requestHeaders add: ('Accept: text/html, image/gif, */*; q=0.2').
    requestHeaders add: ('Host: ', url host).

    noCache ifTrue:
	[requestHeaders add: ('Pragma: no-cache')].

    client reporter statusString: 'Connecting'.

    client reporter statusString: 'Connect: Host contacted. Waiting for reply...'.

    stream := self tmpFile.
    tmpFile := File name: stream name.
    protocolError := false.

    [
	[
	    [
		response := client
		    head: urlString
		    requestHeaders: requestHeaders
		    into: stream
	    ] ensure: [client close]
	]
	    on: NetClientError
	    do: [:ex | ^self errorContents: ex messageText]

	    on: ProtocolError
	    do: [:ex | protocolError := true. ex return]

	    on: HTTP.HTTPRedirection
	    do: [:ex |
		| location |
		location := ex tag.
		location isNil
			ifTrue: [^self errorContents: 'Moved elsewhere']
			ifFalse: [client reporter statusString: 'Redirecting'.
				  stream close. stream := nil.
				  tmpFile exists ifTrue: [tmpFile remove].
				  ^(self class on: (url construct: (URL fromString: location)))
						noCache: self noCache;
						reporter: self reporter;
						getHead]]

    ] ensure: [stream isNil ifFalse: [stream close]].

    ^protocolError
	ifTrue: [
		string := tmpFile contents.
		tmpFile remove.

	        (WebEntity readFrom: string readStream type: type)
		    url: url;
		    canCache: false;
		    guessMimeTypeFromResponse: response;
		    yourself]

	ifFalse: [
	        WebEntity new
		    url: url;
		    canCache: false;
		    localFileName: tmpFile name;
		    guessMimeTypeFromResponse: response;
		    yourself]!

postHttpContents: contents
    | replyContents |
    replyContents := self
	postProxyContents: contents
	host: 'httpProxyHost'
	port: 'httpProxyPort'.

    replyContents notNil ifTrue: [^replyContents].
    self createClient: HTTP.HTTPClient.
    ^self
	postHttpContents: contents
	urlString: url requestString!

postHttpContents: contents urlString: urlString
    | requestHeaders tmpFile stream protocolError response type string |

    requestHeaders := OrderedCollection new.
    requestHeaders add: ('User-Agent: GNU-Smalltalk/', Smalltalk version).
    requestHeaders add: ('Accept: text/html, image/gif, */*; q=0.2').

    noCache ifTrue:
	[requestHeaders add: ('Pragma: no-cache')].

    client reporter statusString: 'Connect: Host contacted. Waiting for reply...'.

    stream := self tmpFile.
    tmpFile := File name: stream name.

    protocolError := false.
    [
	[
	    [response := client
			    post: urlString
			    type: contents type
			    data: contents asStringOrByteArray
			    binary: contents isBinary
			    requestHeaders: requestHeaders
			    into: stream
	    ] ensure: [client close]
	]
	    on: NetClientError
	    do: [:ex | ^self errorContents: ex messageText]

	    on: ProtocolError
	    do: [:ex | protocolError := true. ex return]

            on: HTTP.HTTPRedirection
	    do: [:ex |
		| location |
		location := ex tag.
		location isNil
			ifTrue: [^self errorContents: 'Moved elsewhere']
			ifFalse: [client reporter statusString: 'Redirecting'.
				  stream close. stream := nil.
				  tmpFile exists ifTrue: [tmpFile remove].
				  ^(self class on: (url construct: (URL fromString: location)))
						noCache: self noCache;
						reporter: self reporter;
						contents]]

    ] ensure: [stream isNil ifFalse: [stream close]].

    ^protocolError
	ifTrue: [
		string := tmpFile contents.
		tmpFile remove.

	        (WebEntity readFrom: string readStream type: type)
		    url: url;
		    canCache: false;
		    guessMimeTypeFromResponse: response;
		    yourself]

	ifFalse:
		[
	        WebEntity new
		    url: url;
		    canCache: false;
		    localFileName: tmpFile name;
		    guessMimeTypeFromResponse: response;
		    yourself]! !

!URIResolver methodsFor: 'mailto accessing'!

emptyMessage
    | message address fields subject references |
    message := MimeEntity new.
    address := self defaultMailAddress.
    message parseFieldFrom: ('From: ', address) readStream.

    url query isNil ifFalse: [
        fields := url decodedFields.
        subject := fields at: 'subject' ifAbsent: [ nil ].
        subject isNil ifFalse: [
            message parseFieldFrom: ('Subject: ', subject displayString) readStream
        ].
        references := fields at: 'references' ifAbsent: [ nil ].
        references isNil ifFalse: [
            message parseFieldFrom: ('References: ', references displayString) readStream
        ].
    ].
    ^message!

emptyMailMessage
    | message to |
    message := self emptyMessage.

    to := url path.
    to isNil ifFalse: [
	message parseFieldFrom: ('To: ', to) readStream.
    ].

    message parseFieldFrom: ('X-Mailer: GNU-Smalltalk/', Smalltalk version) readStream.
    ^message!

getMailToContents
    ^self emptyMailMessage
        body: (String with: Character nl),
		(UserProfileSettings default settingAt: #signature);
        yourself!

postMailToContents: contents
    | message |
    message := self emptyMailMessage.
    message parseFieldFrom: ('MIME-Version: 1.0') readStream.
    message parseFieldFrom: ('Content-Type: ', contents contentType) readStream.
    message body: contents asString.
    ^message! !

!URIResolver methodsFor: 'news accessing'!

getNewsArticleContents: articleId
    | tmpFile stream contents |

    stream := self tmpFile.
    tmpFile := File name: stream name.

    [[client articleAt: '<', articleId, '>' into: stream.
		client quit]
			ensure: [stream close. client close]]
	on: NetClientError
	do: [:ex |
		tmpFile exists ifTrue: [tmpFile remove].
		^self errorContents: ex messageText].

    ^(WebEntity readFrom: tmpFile contents type: 'message/news')
	url: url;
	canCache: false;
	localFileName: tmpFile name;
	yourself!

getNewsArticleContents: articleNo group: group
    | tmpFile stream contents |

    stream := self tmpFile.
    tmpFile := File name: stream name.

    [[client articleAtNumber: articleNo group: group into: stream.
		client quit]
			ensure: [stream close. client close]]
	on: NetClientError
	do: [:ex |
		tmpFile exists ifTrue: [tmpFile remove].
		^self errorContents: ex messageText].

    ^(WebEntity readFrom: tmpFile contents type: 'message/news')
	url: url;
	canCache: false;
	localFileName: tmpFile name;
	yourself!

getNewsArticleList: from to: to group: group
    | subjects index |
    subjects := Array new: to - from + 1.
    index := 0.
    client
	subjectsOf: group
	from: from
	to: to
	do: [:n :subject | subjects at: (index := index + 1) put: (Array with: n with: subject)].

    index = 0 ifTrue: [^Array new].
    index < subjects size ifTrue: [subjects := subjects copyFrom: 1 to: index].
    ^subjects!

getNewsArticleListContents: group
    | maxRange range from to prevRanges subjects stream pto pfrom |
    maxRange := 100.
    range := client activeArticlesInGroup: group.
    from := range first.
    to := range last.
    prevRanges := OrderedCollection new.
    (to - from + 1) > maxRange ifTrue:
	[pfrom := from.
	from := to - maxRange + 1.
	pto := from - 1.
	[(pto - pfrom + 1) > maxRange] whileTrue:
		[prevRanges addFirst: (pto - maxRange + 1 to: pto).
		pto := pto - maxRange].
	prevRanges addFirst: (pfrom to: pto)].

    subjects := self getNewsArticleList: from to: to group: group.
    client quit; close.

    stream := ReadWriteStream on: (String new: 80 * subjects size).
    stream
	nextPutAll: 'Content-type: text/html'; nl; nl;
	nextPutAll: '<html>'; nl;
	nextPutAll: '<title>Newsgroup: ', group, '</title>'; nl;
	nextPutAll: '<h1>Newsgroup: ', group, '</h1>'; nl.

    prevRanges isEmpty ifFalse:
	[stream
		nextPutAll: '<hr>'; nl;
		nextPutAll: '<b>Previous articles</b>'; nl;
		nextPutAll: '<ul>'; nl.

	prevRanges do: [:r |
		stream
			nextPutAll: '<li><a href="nntp:/', group, '/';
			print: r first;
			nextPut: $-;
			print: r last;
			nextPutAll: '">';
			print: r first;
			nextPut: $-;
			print: r last;
			nextPutAll: '</a></li>'; nl].

	stream
		nextPutAll: '</ul>'; nl;
		nextPutAll: '<hr>'; nl].

    subjects isEmpty ifFalse:
	[stream nextPutAll: '<ul>'; nl.
	subjects do: [:array |
		| n subject |
		n := array at: 1.
		subject := array at: 2.
		stream
			nextPutAll: '<li><a href="nntp:/', group, '/', n printString, '">'; nl;
			nextPutAll: subject, '</a></li>'; nl].

	stream nextPutAll: '</ul>'; nl].
    stream nextPutAll: '</html>'; nl.

    stream reset.
    ^(WebEntity readFrom: stream)
	url: url!

getNewsArticleListContents: from to: to group: group
    | subjects stream |
    subjects := self getNewsArticleList: from to: to group: group.
    client quit; close.

    stream := ReadWriteStream on: (String new: 80 * subjects size).
    stream
	nextPutAll: 'Content-type: text/html'; nl; nl;
	nextPutAll: '<html>'; nl;
	nextPutAll: '<title>Newsgroup: ', group, ' (', from printString, '-', to printString, ')</title>'; nl;
	nextPutAll: '<h1>Newsgroup: ', group, ' (', from printString, '-', to printString, ')</h1>'; nl.

    subjects isEmpty ifFalse:
	[stream nextPutAll: '<ul>'; nl.
	subjects do: [:array |
		| n subject |
		n := array at: 1.
		subject := array at: 2.
		stream
			nextPutAll: '<li><a href="nntp:/', group, '/', n printString, '">'; nl;
			nextPutAll: subject, '</a></li>'; nl].

	stream nextPutAll: '</ul>'; nl].

    stream nextPutAll: '</html>'; nl.
    stream reset.

    ^(WebEntity readFrom: stream)
	url: url!

getNewsContents
    | host string |
    (url hasFragment or: [url hasQuery])
	ifTrue: [^self invalidURL].

    host := url host.
    host isNil ifTrue: [host := UserProfileSettings default settingAt: 'nntpHost' ifAbsent: [nil]].
    host isNil ifTrue: [^self invalidURL].

    string := url path.
    string isNil ifTrue: [^self invalidURL].

    self createClient: NNTP.NNTPClient.
    [[(string indexOf: $@) > 0
			ifTrue: "may be article"
				[^self getNewsArticleContents: string]

			ifFalse: "may be newsgroup"
				[^self getThreadedNewsArticleListContents: string]

		] ensure: [client close]]
	    on: NetClientError
	    do: [:ex | ^self errorContents: ex messageText]
!

getNntpContents
    | host string read group from to |

    (url hasFragment or: [url hasPostData])
	ifTrue: [^self invalidURL].

    host := url host.
    host isNil ifTrue: [host := UserProfileSettings default settingAt: 'nntpHost' ifAbsent: [nil]].
    host isNil ifTrue: [^self invalidURL].

    string := url path.
    string isNil ifTrue: [^self invalidURL].

    read := string readStream.
    read atEnd ifTrue: [^self invalidURL].
    read peek = $/ ifTrue: [read next].
    group := read upTo: $/.

    url hasQuery
	ifTrue:
		[read := url query readStream.
		read atEnd ifTrue: [^self invalidURL].
		from := Integer readFrom: read.
		from = 0 ifTrue: [^self invalidURL].
		read next = $- ifFalse: [^self invalidURL].
		to := Integer readFrom: read.
		to = 0 ifTrue: [^self invalidURL]]

	ifFalse:
		[read atEnd ifTrue: [^self invalidURL].
		from := Integer readFrom: read.
		from = 0 ifTrue: [^self invalidURL].
		to := nil].

    self createClient: NNTP.NNTPClient.
    ^[
	[
	    to isNil
		ifTrue: [ self getNewsArticleContents: from group: group ]
		ifFalse: [ self getThreadedNewsArticleListContents: from to: to group: group]
	] ensure: [client close]]
	on: NetClientError
	do: [:ex | ^self errorContents: ex messageText]
!

getThreadedNewsArticleList: from to: to group: group
    | subjects threads |
    subjects := self getNewsArticleList: from to: to group: group.
    threads := Dictionary new.
    subjects do: [:array |
	| read stream head tname col |
	read := (array at: 2) readStream.
	stream := WriteStream on: (String new: read size).
	[read skipSeparators.
	head := read nextAvailable: 3.
	('Re:' sameAs: head)]
		whileTrue: [].

	stream nextPutAll: head; nextPutAll: read.
	tname := stream contents.
	col := threads at: tname ifAbsent: [nil].
	col notNil
		ifTrue: [col add: array]
		ifFalse: [col := SortedCollection sortBlock: [:x : y |
							| xn yn xsize ysize |
							xn := x at: 1.
							yn := y at: 1.
							xsize := (x at: 2) size.
							ysize := (y at: 2) size.
							xsize = ysize
								ifTrue: [xn <= yn]
								ifFalse: [xsize <= ysize]].

				col add: array.
				threads at: tname put: col]].

    ^threads!

getThreadedNewsArticleListContents: group
    | maxRange range from to prevRanges threads stream pto pfrom |
    maxRange := 100.
    range := client activeArticlesInGroup: group.
    from := range first.
    to := range last.
    prevRanges := OrderedCollection new.

    (to - from + 1) > maxRange ifTrue:
	[pfrom := from.
	from := to - maxRange + 1.
	pto := from - 1.
	[(pto - pfrom + 1) > maxRange] whileTrue:
		[prevRanges addFirst: (pto - maxRange + 1 to: pto).
		pto := pto - maxRange].

	prevRanges addFirst: (pfrom to: pto)].

    threads := self getThreadedNewsArticleList: from to: to group: group.
    client quit; close.

    stream := ReadWriteStream on: (String new: 80 * threads size).
    stream
	nextPutAll: 'Content-type: text/html'; nl; nl;
	nextPutAll: '<html>'; nl;
	nextPutAll: '<title>Newsgroup: ', group, '</title>'; nl;
	nextPutAll: '<h1>Newsgroup: ', group, '</h1>'; nl.

    prevRanges isEmpty ifFalse:
	[stream
		nextPutAll: '<hr>'; nl;
		nextPutAll: '<b>Previous articles</b>'; nl;
		nextPutAll: '<ul>'; nl.

	prevRanges do: [:r |
		stream
			nextPutAll: '<li><a href="nntp:/', group, '?', r first printString, '-', r last printString, '">'; nl;
			nextPutAll: r first printString, '-', r last printString, '</a></li>'; nl].
	stream
		nextPutAll: '</ul>'; nl;
		nextPutAll: '<hr>'; nl].

    threads isEmpty ifFalse:
	[stream nextPutAll: '<ul>'; nl.
	threads keys asSortedCollection do: [:key |
		| col first |
		col := threads at: key.
		first := col removeFirst.
		stream
			nextPutAll: '<li><a href="nntp:/', group, '/', (first at: 1) printString, '">'; nl;
			nextPutAll: (first at: 2), '</a></li>'; nl.

		col isEmpty ifFalse:
			[stream nextPutAll: '<ul>'; nl.
			col do: [:array |
				| n subject |
				n := array at: 1.
				subject := array at: 2.
				stream
					nextPutAll: '<li><a href="nntp:/', group, '/', n printString, '">'; nl;
					nextPutAll: subject, '</a></li>'; nl].

			stream nextPutAll: '</ul>'; nl]].

	stream nextPutAll: '</ul>'; nl].

    stream nextPutAll: '</html>'; nl.
    stream reset.

    ^(WebEntity readFrom: stream)
	url: url!

getThreadedNewsArticleListContents: from to: to group: group
    | threads stream |
    threads := self getThreadedNewsArticleList: from to: to group: group.
    client quit; close.
    stream := ReadWriteStream on: (String new: 80 * threads size).
    stream
	nextPutAll: 'Content-type: text/html'; nl; nl;
	nextPutAll: '<html>'; nl;
	nextPutAll: '<title>Newsgroup: ', group, ' (', from printString, '-', to printString, ')</title>'; nl;
	nextPutAll: '<h1>Newsgroup: ', group, ' (', from printString, '-', to printString, ')</h1>'; nl.

    threads isEmpty ifFalse:
	[stream nextPutAll: '<ul>'; nl.
	threads keys asSortedCollection do: [:key |
		| col first |
		col := threads at: key.
		first := col removeFirst.
		stream
			nextPutAll: '<li><a href="nntp:/', group, '/', (first at: 1) printString, '">'; nl;
			nextPutAll: (first at: 2), '</a></li>'; nl.

		col isEmpty ifFalse:
			[stream nextPutAll: '<ul>'; nl.
			col do: [:array |
				| n subject |
				n := array at: 1.
				subject := array at: 2.
				stream
					nextPutAll: '<li><a href="nntp:/', group, '/', n printString, '">'; nl;
					nextPutAll: subject, '</a></li>'; nl].

			stream nextPutAll: '</ul>'; nl]].

	stream nextPutAll: '</ul>'; nl].

    stream nextPutAll: '</html>'; nl.
    stream reset.

    ^(WebEntity readFrom: stream)
	url: url! !

!URIResolver methodsFor: 'postto accessing'!

emptyNewsMessage
    | message group org |
    message := self emptyMessage.

    group := url path.
    group isNil ifFalse: [
        message parseFieldFrom: ('Newsgroups: ', group) readStream.
    ].

    org := UserProfileSettings default settingAt: 'organization' ifAbsent: [nil].
    org isNil ifFalse: [
	message parseFieldFrom: ('Organization: ', org) readStream
    ].

    message parseFieldFrom: ('X-Newsreader: GNU-Smalltalk/', Smalltalk version) readStream.
    ^message
!

getPostToContents
    ^self emptyNewsMessage
	 body: (String with: Character nl),
		(UserProfileSettings default settingAt: 'signature' ifAbsent: [String new]);
	 yourself!

postPostToContents: contents
    | message |
    message := self emptyNewsMessage.
    message parseFieldFrom: ('MIME-Version: 1.0') readStream.
    message parseFieldFrom: ('Content-Type: ', contents contentType) readStream.
    message body: contents asString.
    ^message! !

!URIResolver methodsFor: 'private'!

defaultMailAddress
    ^UserProfileSettings default settingAt: #mailAddress!

errorContents: errorString
    | contents |
    contents := WebEntity readFrom: (
'Content-type: text/html

<html>
<body>
<h1>Error</h1>
<p><b>Reason:</b> ', errorString, '</p>
</body>
</html>') readStream.

    contents url: url.
    contents canCache: false.
    ^contents!

getBufferSize
    | kbytes |
    kbytes := (UserProfileSettings default settingAt: #bufferSize) asNumber.
    ^kbytes * 1024!

getNoProxyHostNames
    | col read stream noProxy ch |
    col := OrderedCollection new.
    noProxy := UserProfileSettings default settingAt: #proxyList.
    noProxy = 'none'
	ifTrue: [^col].
    
    read := noProxy readStream.
    stream := WriteStream on: (String new: 64).
    [read atEnd] whileFalse:
	[read skipSeparators.
	stream reset.
	[read atEnd or:
	[ch := read next.
	(ch isSeparator or: [ch = $,])]]
		whileFalse:
			[stream nextPut: ch].
	stream isEmpty ifFalse: [col addLast: stream contents]].
    stream isEmpty ifFalse: [col addLast: stream contents].
    ^col!

getProxyContentsHost: hostKey port: portKey
    | host port |
    (host := url host) isNil
	ifTrue: [^self errorContents: 'No host name is specified'].
    (self isNoProxyHost: host)
	ifTrue: [^nil].
    host := UserProfileSettings default settingAt: hostKey.
    (host isString and: [ host notEmpty ]) ifFalse: [^nil].
    port := UserProfileSettings default settingAt: portKey.
    port isInteger ifFalse: [^nil].

    self createClient: HTTP.HTTPClient host: host port: port.
    ^self requestHttpContents: url fullRequestString!

getProxyHeadHost: hostKey port: portKey
    | host port |
    (host := url host) isNil
	ifTrue: [^self errorContents: 'No host name is specified'].
    (self isNoProxyHost: host)
	ifTrue: [^nil].
    host := UserProfileSettings default settingAt: hostKey.
    (host isString and: [ host notEmpty ]) ifFalse: [^nil].
    port := UserProfileSettings default settingAt: portKey.
    port isInteger ifFalse: [^nil].

    self createClient: HTTP.HTTPClient host: host port: port.
    ^self requestHttpHead: url fullRequestString!

invalidURL
    ^self errorContents: 'Invalid URL'!

isNoProxyHost: host
    self getNoProxyHostNames do: [:noproxy |

	(('*', noproxy, '*') match: host) ifTrue: [^true]].

    ^false!

on: anURL
    url := anURL!

postProxyContents: contents host: hostKey port: portKey
    | host port |
    (host := url host) isNil
	ifTrue: [^self errorContents: 'No host name is specified'].
    (self isNoProxyHost: host)
	ifTrue: [^nil].
    host := UserProfileSettings default settingAt: hostKey.
    (host isString and: [ host notEmpty ]) ifFalse: [^nil].
    port := UserProfileSettings default settingAt: portKey.
    port isInteger ifFalse: [^nil].

    self createClient: HTTP.HTTPClient host: host port: port.
    ^self
	postHttpContents: contents
	urlString: url fullRequestString!

tmpFile
    | dir |
    dir := UserProfileSettings default settingAt: 'tmpDir'.
    dir = '' ifTrue: [dir := '/tmp/'] ifFalse: [ dir := dir, '/' ].
    ^FileStream openTemporaryFile: dir! !


!WebEntity methodsFor: 'accessing'!

body
    | stream type file |
    body isNil ifFalse: [ ^super body ].

    "Read it from the file"
    type := (self fieldAt: 'content-type') type.
    file := File name: localFileName.
    stream := self class parser on: file readStream.

    ('message/*' match: type) ifTrue: [
	self fields removeKey: 'content-type'.
	self readFrom: stream ].

    self parseBodyFrom: stream.
    ^body!

stream
    | body |
    body := self body.
    self canDelete ifTrue: [
    	(File name: self localFileName) remove
    ].
    ^body readStream!

canCache
    canCache notNil ifTrue: [^canCache].
    ^url notNil and: [url canCache]!

canCache: aBoolean
    canCache := aBoolean!

canDelete
    (url notNil and: [url isFileScheme]) ifTrue: [^false].
    ^self isFileContents!

isFileContents
    ^localFileName notNil!

localFileName
    ^localFileName!

localFileName: aString
    localFileName := aString!

url
    ^url!

url: anURL
    url := anURL!

urlName
    ^url isNil
	ifTrue: [ '<no URL>' ]
	ifFalse: [ url printString ]! !

!WebEntity methodsFor: 'mime types'!

guessMimeTypeFromResponse: aResponse
    self addField: (self contentTypeFromResponse: aResponse)!

guessMimeType
    | mimeType |
    mimeType := self guessedContentType.
    self addField: (ContentTypeField fromLine: 'content-type: ', mimeType)!

contentTypeFromResponse: aResponse
    | mimeType |
    aResponse isNil ifFalse:
	[mimeType := aResponse fieldAt: 'content-type' ifAbsent: [nil].
	mimeType isNil ifFalse: [^mimeType]].

    mimeType := self guessedContentType.
    ^ContentTypeField fromLine: 'content-type: ', mimeType!

contentTypeFromURL
    | path index |
    path := url path.
    (path isNil or: [path isEmpty]) ifTrue: [^nil].
    ^ContentHandler contentTypeFor: url path ifAbsent: [ nil ]!

contentTypeFromContents
    | file stream |
    file := File name: localFileName.
    file exists ifTrue: [
	stream := file readStream.
	^[ ContentHandler guessContentTypeFor: stream ]
	     ensure: [ stream close ]
    ]!

guessedContentType
    | mimeType |
    url isNil ifFalse: [
	mimeType := self contentTypeFromURL.
	mimeType isNil ifFalse: [ ^mimeType ]
    ].

    localFileName isNil ifFalse: [
	"check for well-known magic types"
	^self contentTypeFromContents
    ].

    ^'application/octet-stream'! !

!UserProfileSettings class methodsFor: 'accessing'!

default
    ^default isNil
	ifTrue: [ default := self new ]
	ifFalse: [ default ]!

default: aSettingsObject
    default := aSettingsObject! !

!UserProfileSettings class methodsFor: 'instance creation'!

new
    ^self basicNew initialize! !

!UserProfileSettings class methodsFor: 'parcel load/unload'!

postLoad: aParcel
    self initialize! !

!UserProfileSettings methodsFor: 'accessing'!

settings
    ^settings!

settings: aValue
    settings := aValue! !

!UserProfileSettings methodsFor: 'api'!

settingAt: aSymbol
    ^self settings at: aSymbol ifAbsent: ['']!

settingFor: aSymbol put: aValue
    ^self settings at: aSymbol put: aValue! !

!UserProfileSettings methodsFor: 'initialize-release'!

initialize
    self settings: IdentityDictionary new.
    self settings at: #tmpDir put: (Smalltalk getenv: 'TEMP').
    self settings at: #mailer put: 'SMTPClient'.
    self settings at: #bufferSize put: '16'.
    self settings at: #proxyList put: 'none'.
    self settings at: #mailAddress put: nil.
    self settings at: #mailServer put: nil.
    self settings at: #signature put: nil.
    self settings at: #hostKey put: ''.
    self settings at: #portKey put: '80'! !


UserProfileSettings initialize!
