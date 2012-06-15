"======================================================================
|
|   URL resolving and on-disk storage support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2008 Free Software Foundation, Inc.
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



Object subclass: URIResolver [
    | url reporter noCache client entity |
    
    <import: Sockets>
    <import: MIME>
    <category: 'NetClients-URIResolver'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.

'>

    URIResolver class >> openOn: aURI ifFail: aBlock [
	"Check if aURI can be fetched from the Internet or from the local system,
	 and if so return a WebEntity with its contents.  If this is not possible,
	 instead, evaluate the zero-argument block aBlock and answer the result
	 of the evaluation."

	<category: 'api'>
	| url body entity |
	url := aURI.
	(url respondsTo: #key) ifTrue: [url := url key , ':/' , url value].
	url isString ifTrue: [url := URL fromString: url].
	
	[entity := (self on: url)
		    noCache: true;
		    contentsNoSignal] 
		on: ProtocolError do: [:sig | sig return: aBlock value]
		on: Error do: [:sig | sig return: aBlock value].
	^entity
    ]

    URIResolver class >> openStreamOn: aURI ifFail: aBlock [
	"Check if aURI can be fetched from the Internet or from the local system,
	 and if so return a Stream with its contents.  If this is not possible,
	 instead, evaluate the zero-argument block aBlock and answer the result
	 of the evaluation."

	<category: 'api'>
	| entity |
	entity := self openOn: aURI ifFail: [^aBlock value].
	^entity stream
    ]

    defaultHeaders [
	"The default headers for HTTP like requests"
	| requestHeaders |
	requestHeaders := OrderedCollection new.
	requestHeaders add: 'User-Agent: GNU-Smalltalk/' , Smalltalk version.
	requestHeaders add: 'Accept: text/html, image/gif, */*; q=0.2'.
	requestHeaders add: 'Host: ' , url host.
	noCache ifTrue: [requestHeaders add: 'Pragma: no-cache'].

	^ requestHeaders
    ]

    connectClient [
	<category: 'private'>
	| host |
	host := url host isNil 
		    ifTrue: [SocketAddress localHostName]
		    ifFalse: [url host].
	self connectClientToHost: host port: url port
    ]

    connectClientToHost: host port: port [
	<category: 'private'>
        client closed ifFalse: [client close].
	client hostName: host; portNumber: port; connect
    ]

    connect [
	<category: 'private'>
	client reporter: self reporter.
	url username isNil 
	    ifFalse: [client username: url username password: url password].
	client reporter statusString: 'Connecting'.
	[client connect] on: ConnectionFailedError
	    do: [:ex | ^self errorContents: ex tag]
    ]

    noCache [
	<category: 'accessing'>
	noCache isNil ifTrue: [noCache := false].
	^noCache
    ]

    noCache: aBoolean [
	<category: 'accessing'>
	noCache := aBoolean
    ]

    reporter [
	<category: 'accessing'>
	^reporter
    ]

    reporter: aReporter [
	<category: 'accessing'>
	reporter := aReporter.
	client isNil ifFalse: [client reporter: self reporter]
    ]

    entity [
	<category: 'accessing'>
	^entity
    ]

    contentsNoSignal [
	<category: 'accessing'>
	| scheme contents |
	(entity notNil and: [noCache not]) ifTrue: [^entity].
	url hasPostData 
	    ifTrue: 
		[contents := (MimeEntity new)
			    addField: ContentTypeField urlEncoded;
			    body: url postData;
			    yourself.
		^self postContentsNoSignal: contents].
	scheme := url scheme.
	scheme = 'http' ifTrue: [client := HTTP.HTTPClient new. ^entity := self getHttpContents].
	scheme = 'https' ifTrue: [client := HTTP.HTTPClient new. client isSSL: true. ^entity := self getHttpContents].
	scheme = 'ftp' ifTrue: [client := FTP.FTPClient new. ^entity := self getFtpContents].
	scheme = 'news' ifTrue: [client := NNTP.NNTPClient new. ^entity := self getNewsContents].
	scheme = 'nntp' ifTrue: [client := NNTP.NNTPClient new. ^entity := self getNntpContents].
	url isFileScheme ifTrue: [^entity := self getFileContents].
	^self errorContents: 'Unsupported protocol'
    ]

    contents [
	<category: 'accessing'>
	| messageText |
	[^self contentsNoSignal] on: Error
	    do: 
		[:ex | 
		messageText := ex messageText.
		ex return].
	^self errorContents: messageText
    ]

    getHeadNoSignal [
	<category: 'accessing'>
	| scheme |
	url hasPostData ifTrue: [^self errorContents: 'Unsupported post'].
	scheme := url scheme.
	scheme = 'http' ifTrue: [client := HTTP.HTTPClient new. ^self getHttpHead].
	scheme = 'https' ifTrue: [client := HTTP.HTTPClient new. client isSSL: true. ^self getHttpHead].
	^self errorContents: 'Unsupported protocol'
    ]

    getHead [
	<category: 'accessing'>
	| messageText |
	[^self getHeadNoSignal] on: Error
	    do: 
		[:ex | 
		messageText := ex messageText.
		ex return].
	^self errorContents: messageText
    ]

    postContents: contents [
	<category: 'accessing'>
	| messageText |
	[^self postContentNoSignal: contents] on: Error
	    do: 
		[:ex | 
		messageText := ex messageText.
		ex return].
	^self errorContents: messageText

	"^self postContentsNoSignal: contents"
    ]

    postContentsNoSignal: contents [
	<category: 'accessing'>
	| scheme |
	scheme := url scheme.
	scheme = 'http' ifTrue: [client := HTTP.HTTPClient new. ^self postHttpContents: contents].
	scheme = 'https' ifTrue: [client := HTTP.HTTPClient new. client isSSL: true. ^self postHttpContents: contents].
	^self errorContents: 'Unsupported protocol'
    ]

    getDirectoryContentsOf: aDirectory [
	<category: 'file accessing'>
	| maxSize stream title contents |
	maxSize := 32.
	stream := ReadWriteStream on: (String new: 512).
	title := 'Directory listing of ' , aDirectory fullName.
	stream 
	    nextPutAll: 'Content-type: text/html

<html>
<head>
<title>' , title 
		    , '</title>
</head>
<body>
<h2>' , title 
		    , '</h2>
'.
	stream
	    nextPutAll: '<pre>';
	    nl.
	stream 
	    nextPutAll: '<a href="file:' , aDirectory path , '" class="upfolder">'.
	stream
	    nextPutAll: 'Up to higher level directory</a>';
	    nl;
	    nl.
	aDirectory entryNames asSortedCollection do: 
		[:name | 
		| file isDirectory fileSize |
		file := aDirectory at: name.
		
		[isDirectory := file isDirectory.
		fileSize := file size] on: Error
			do: 
			    [:ex | 
			    isDirectory := false.
			    fileSize := 0.
			    ex return].
		stream
		    tab;
		    nextPutAll: '<a href="file:' , file fullName , '" class="'.
		isDirectory 
		    ifTrue: [stream nextPutAll: 'folder']
		    ifFalse: [stream nextPutAll: 'document'].
		stream nextPutAll: '">'.
		stream
		    nextPutAll: name;
		    nextPutAll: '</a>'.
		name size <= maxSize 
		    ifFalse: 
			[stream
			    nl;
			    tab;
			    next: maxSize put: $ ]
		    ifTrue: [stream next: maxSize - name size put: $ ].
		fileSize := fileSize printString.
		fileSize size < 8 ifTrue: [stream next: 8 - fileSize size put: $ ].
		stream
		    nextPutAll: fileSize;
		    nextPutAll: ' bytes'.
		stream nl].
	stream
	    nextPutAll: '</pre>';
	    nl.
	stream nextPutAll: '</body>
</html>'.
	stream reset.
	^(WebEntity readFrom: stream)
	    url: url;
	    canCache: false;
	    yourself
    ]

    getFileContents [
	<category: 'file accessing'>
	| file result |
	file := File name: (url path ifNil: '/').
	file exists ifFalse: [^self errorContents: 'No such file'].
	file isReadable ifFalse: [^self errorContents: 'Cannot read'].
	file isDirectory ifTrue: [^self getDirectoryContentsOf: file].
	^(WebEntity new)
	    url: url;
	    canCache: false;
	    localFileName: url path;
	    guessMimeType;
	    yourself
    ]

    getFtpContents [
	<category: 'ftp accessing'>
	| contents path tmpFile type stream |
	contents := self getProxyContentsHost: 'ftpProxyHost' port: 'ftpProxyPort'.
	contents notNil ifTrue: [^contents].
	self connectClient.
	
	[| user mail |
	user := NetUser new.
	url username isNil 
	    ifTrue: [user username: 'anonymous']
	    ifFalse: [user username: url username].
	url password isNil 
	    ifTrue: 
		["Anonymous FTP, send e-mail address as password"

		mail := UserProfileSettings default settingAt: #mailAddress.
		(mail isNil or: ['*@*.*' match: mail]) ifTrue: [mail := 'gst@'].
		user password: mail]
	    ifFalse: [user password: url password].
	client
	    user: user;
	    login] 
		on: NetClientError
		do: 
		    [:ex | 
		    client close.
		    ^self errorContents: ex tag].
	client reporter 
	    statusString: 'Connect: Host contacted. Waiting for reply...'.
	(url path isNil or: [url path isEmpty]) 
	    ifTrue: [path := '/']
	    ifFalse: [path := url path].
	stream := self tmpFile.
	tmpFile := stream file.
	^
	[
	[client 
	    getFile: path
	    type: #binary
	    into: stream] 
		ensure: [stream close].
	(WebEntity new)
	    url: url;
	    canCache: false;
	    localFileName: tmpFile name;
	    guessMimeType;
	    yourself] 
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
		on: FTP.FTPFileNotFoundError
		do: 
		    [:ex | 
		    tmpFile exists ifTrue: [tmpFile remove].
		    stream := ReadWriteStream on: (String new: 512).
		    ^
		    [(path at: path size) = '/' ifFalse: [path := path copyWith: $/].
		    client getList: path into: stream.
		    stream reset.
		    self getFtpDirectoryContentsFrom: stream] 
			    on: FTP.FTPFileNotFoundError
			    do: [:ex | ^self errorContents: ex messageText]]
    ]

    getFtpDirectoryContentsFrom: aStream [
	<category: 'ftp accessing'>
	| baseURL maxSize stream title contents sp read mode ftype fileSize name newURL index |
	baseURL := url copy.
	baseURL path isNil 
	    ifTrue: [baseURL path: '/junk']
	    ifFalse: [baseURL path: (File append: 'junk' to: baseURL path)].
	maxSize := 32.
	stream := ReadWriteStream on: (String new: 512).
	title := 'Directory listing of ' , url printString.
	stream 
	    nextPutAll: 'Content-type: text/html

<html>
<head>
<title>' , title 
		    , '</title>
</head>
<body>
<h2>' , title 
		    , '</h2>
'.

	"-rwxr-xr-x  1 user    group         512 Aug  8 05:57 file"
	"drwxr-xr-x  1 user    group         512 Aug  8 05:57 directory"
	"lrwxrwxrwx  1 user    group         512 Aug  8 05:57 symlink"
	"brwxr-xr-x  1 user    group         0, 1 Aug  8 05:57 block-device"
	"crwxr-xr-x  1 user    group         1, 2 Aug  8 05:57 character-device"
	"p---------  1 user    group         0 Aug  8 05:57 pipe"
	stream
	    nextPutAll: '<pre>';
	    nl.
	baseURL path isNil 
	    ifFalse: 
		[stream
		    nextPutAll: '<a href="';
		    print: (baseURL construct: (URL fromString: '..'));
		    nextPutAll: '" class="upfolder">'].
	stream
	    nextPutAll: 'Up to higher level directory</a>';
	    nl;
	    nl.
	[aStream atEnd] whileFalse: 
		[sp := Character space.
		read := (aStream upTo: Character nl) readStream.
		mode := read upTo: sp.
		mode isEmpty ifTrue: [ftype := nil] ifFalse: [ftype := mode first].
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
			read upTo: sp	"minor"]
		    ifFalse: [fileSize := read upTo: sp].
		read skipSeparators.
		read upTo: sp.	"month"
		read skipSeparators.
		read upTo: sp.	"day"
		read skipSeparators.
		read upTo: sp.	"time"
		read skipSeparators.
		name := read upToEnd trimSeparators.
		(ftype isNil or: [name isEmpty or: [name = '.' or: [name = '..']]]) 
		    ifFalse: 
			[ftype = $l 
			    ifTrue: 
				["symbolic link"

				index := name indexOfSubCollection: ' -> ' startingAt: 1.
				index > 0 
				    ifTrue: 
					[newURL := baseURL 
						    construct: (URL fromString: (name copyFrom: index + 4 to: name size)).
					name := name copyFrom: 1 to: index - 1]
				    ifFalse: [newURL := baseURL construct: (URL fromString: name)]]
			    ifFalse: 
				[(ftype = $- or: [ftype = $d]) 
				    ifTrue: [newURL := baseURL construct: (URL fromString: name)]
				    ifFalse: [newURL := nil]].
			stream tab.
			newURL isNil 
			    ifTrue: [stream nextPutAll: '<span class="']
			    ifFalse: [stream nextPutAll: '<a href="' , newURL printString , '" class="'].
			ftype = $d 
			    ifTrue: [stream nextPutAll: 'folder']
			    ifFalse: 
				[ftype = $l 
				    ifTrue: [stream nextPutAll: 'symlink']
				    ifFalse: [stream nextPutAll: 'document']].
			stream nextPutAll: '">'.
			name size <= maxSize 
			    ifTrue: 
				[stream nextPutAll: name.
				newURL isNil ifFalse: [stream nextPutAll: '</a>'].
				maxSize - name size timesRepeat: [stream space]]
			    ifFalse: 
				[stream nextPutAll: name.
				newURL isNil ifFalse: [stream nextPutAll: '</a>'].
				stream
				    nl;
				    tab.
				maxSize timesRepeat: [stream space]].
			fileSize size < 8 ifTrue: [8 - fileSize size timesRepeat: [stream space]].
			stream
			    nextPutAll: fileSize;
			    nextPutAll: ' bytes'.
			stream nl]].
	stream
	    nextPutAll: '</pre>';
	    nl.
	stream nextPutAll: '</body>
</html>'.
	stream reset.
	^(WebEntity readFrom: stream)
	    url: url;
	    canCache: false;
	    yourself
    ]

    getHttpContents [
	<category: 'http accessing'>
	| contents urlString |
	contents := self getProxyContentsHost: 'httpProxyHost'
		    port: 'httpProxyPort'.
	contents notNil ifTrue: [^contents].
	self connectClient.
	^self requestHttpContents: url requestString
    ]

    doHTTPRequest: requestBlock onSuccess: successBlock [
	<category: 'private'>
	| requestHeaders tmpFile stream protocolError response string |
	requestHeaders := self defaultHeaders.
	client reporter statusString: 'Connecting'.
	protocolError := false.
	client reporter 
	    statusString: 'Connect: Host contacted. Waiting for reply...'.
	stream := self tmpFile.
	tmpFile := stream file.
	
	[
	[
	[response := requestBlock value: requestHeaders value: stream]
		ensure: [client close]] 
		on: ProtocolError
		do: 
		    [:ex | 
		    protocolError := true.
		    ex pass]
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
		on: HTTP.HTTPRedirection
		do: 
		    [:ex | 
		    | location |
		    location := ex location.
		    client reporter statusString: 'Redirecting'.
		    stream close.
		    stream := nil.
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^(self class on: (url construct: (URL fromString: location)))
			noCache: self noCache;
			reporter: self reporter;
			contents]] 
		ensure: [stream isNil ifFalse: [stream close]].
	^protocolError 
	    ifTrue: 
		[string := tmpFile contents.
		tmpFile remove.
		(WebEntity new)
		    body: string;
		    url: url;
		    canCache: false;
		    guessMimeType;
		    yourself]
	    ifFalse: 
		[|ent |
		    ent := (WebEntity new)
			    url: url;
			    localFileName: tmpFile name;
			    canCache: noCache not;
			    guessMimeType;
			    yourself.
		    successBlock value: ent.
		    ent]
    ]

    requestHttpContents: urlString [
	<category: 'http accessing'>
	^ self doHTTPRequest: [:requestHeaders :stream |
		    client  get: urlString requestHeaders: requestHeaders into: stream]
	       onSuccess: [:ent | ]
    ]

    getHttpHead [
	<category: 'http accessing'>
	| contents |
	contents := self getProxyHeadHost: 'httpProxyHost' port: 'httpProxyPort'.
	contents notNil ifTrue: [^contents].
	self connectClient.
	^self requestHttpHead: url requestString
    ]

    requestHttpHead: urlString [
	<category: 'http accessing'>
	| requestHeaders tmpFile stream protocolError response string |
	requestHeaders := self defaultHeaders.
	client reporter statusString: 'Connecting'.
	client reporter 
	    statusString: 'Connect: Host contacted. Waiting for reply...'.
	stream := self tmpFile.
	tmpFile := stream file.
	protocolError := false.
	
	[
	[
	[response := client 
		    head: urlString
		    requestHeaders: requestHeaders
		    into: stream] 
		ensure: [client close]] 
		on: ProtocolError
		do: 
		    [:ex | 
		    protocolError := true.
		    ex pass]
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
		on: HTTP.HTTPRedirection
		do: 
		    [:ex | 
		    | location |
		    location := ex location.
		    client reporter statusString: 'Redirecting'.
		    stream close.
		    stream := nil.
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^(self class on: (url construct: (URL fromString: location)))
			noCache: self noCache;
			reporter: self reporter;
			getHead]] 
		ensure: [stream isNil ifFalse: [stream close]].
	^protocolError 
	    ifTrue: 
		[string := tmpFile contents.
		tmpFile remove.
		(WebEntity new)
		    body: string;
		    url: url;
		    canCache: false;
		    guessMimeTypeFromResponse: response;
		    yourself]
	    ifFalse: 
		[(WebEntity new)
		    url: url;
		    canCache: false;
		    localFileName: tmpFile name;
		    guessMimeTypeFromResponse: response;
		    yourself]
    ]

    postHttpContents: contents [
	<category: 'http accessing'>
	| replyContents |
	replyContents := self 
		    postProxyContents: contents
		    host: 'httpProxyHost'
		    port: 'httpProxyPort'.
	replyContents notNil ifTrue: [^replyContents].
	self connectClient.
	^self postHttpContents: contents urlString: url requestString
    ]

    postHttpContents: contents urlString: urlString [
	<category: 'http accessing'>
	^ self doHTTPRequest: [:requestHeaders :stream |
		    client post: urlString
		    type: contents type
		    data: contents asStringOrByteArray
		    binary: contents isBinary
		    requestHeaders: requestHeaders
		    into: stream] 
		onSuccess: [:ent | ent canCache: false ]
    ]

    emptyMessage [
	<category: 'mailto accessing'>
	| message address fields subject references |
	message := MimeEntity new.
	address := self defaultMailAddress.
	message parseFieldFrom: ('From: ' , address) readStream.
	url query isNil 
	    ifFalse: 
		[fields := url decodedFields.
		subject := fields at: 'subject' ifAbsent: [nil].
		subject isNil 
		    ifFalse: 
			[message parseFieldFrom: ('Subject: ' , subject displayString) readStream].
		references := fields at: 'references' ifAbsent: [nil].
		references isNil 
		    ifFalse: 
			[message 
			    parseFieldFrom: ('References: ' , references displayString) readStream]].
	^message
    ]

    emptyMailMessage [
	<category: 'mailto accessing'>
	| message to |
	message := self emptyMessage.
	to := url path.
	to isNil ifFalse: [message parseFieldFrom: ('To: ' , to) readStream].
	message 
	    parseFieldFrom: ('X-Mailer: GNU-Smalltalk/' , Smalltalk version) readStream.
	^message
    ]

    getNewsArticleContents: articleId [
	<category: 'news accessing'>
	| tmpFile stream contents |
	stream := self tmpFile.
	tmpFile := stream file.
	
	[
	[client articleAt: '<' , articleId , '>' into: stream.
	client quit] 
		ensure: 
		    [stream close.
		    client close]] 
		on: NetClientError
		do: 
		    [:ex | 
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^self errorContents: ex messageText].
	^(WebEntity readFrom: tmpFile contents type: 'message/news')
	    url: url;
	    canCache: false;
	    localFileName: tmpFile name;
	    yourself
    ]

    getNewsArticleContents: articleNo group: group [
	<category: 'news accessing'>
	| tmpFile stream contents |
	stream := self tmpFile.
	tmpFile := stream file.
	
	[
	[client 
	    articleAtNumber: articleNo
	    group: group
	    into: stream.
	client quit] 
		ensure: 
		    [stream close.
		    client close]] 
		on: NetClientError
		do: 
		    [:ex | 
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^self errorContents: ex messageText].
	^(WebEntity readFrom: tmpFile contents type: 'message/news')
	    url: url;
	    canCache: false;
	    localFileName: tmpFile name;
	    yourself
    ]

    getNewsArticleList: from to: to group: group [
	<category: 'news accessing'>
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
	^subjects
    ]

    getNewsArticleListContents: group [
	<category: 'news accessing'>
	| maxRange range from to prevRanges subjects stream pto pfrom |
	maxRange := 100.
	range := client activeArticlesInGroup: group.
	from := range first.
	to := range last.
	prevRanges := OrderedCollection new.
	to - from + 1 > maxRange 
	    ifTrue: 
		[pfrom := from.
		from := to - maxRange + 1.
		pto := from - 1.
		[pto - pfrom + 1 > maxRange] whileTrue: 
			[prevRanges addFirst: (pto - maxRange + 1 to: pto).
			pto := pto - maxRange].
		prevRanges addFirst: (pfrom to: pto)].
	subjects := self 
		    getNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * subjects size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , '</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , '</h1>';
	    nl.
	prevRanges isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<hr>';
		    nl;
		    nextPutAll: '<b>Previous articles</b>';
		    nl;
		    nextPutAll: '<ul>';
		    nl.
		prevRanges do: 
			[:r | 
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/';
			    print: r first;
			    nextPut: $-;
			    print: r last;
			    nextPutAll: '">';
			    print: r first;
			    nextPut: $-;
			    print: r last;
			    nextPutAll: '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl;
		    nextPutAll: '<hr>';
		    nl].
	subjects isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		subjects do: 
			[:array | 
			| n subject |
			n := array at: 1.
			subject := array at: 2.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
			    nl;
			    nextPutAll: subject , '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    getNewsArticleListContents: from to: to group: group [
	<category: 'news accessing'>
	| subjects stream |
	subjects := self 
		    getNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * subjects size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</h1>';
	    nl.
	subjects isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		subjects do: 
			[:array | 
			| n subject |
			n := array at: 1.
			subject := array at: 2.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
			    nl;
			    nextPutAll: subject , '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    getNewsContents [
	<category: 'news accessing'>
	| host string |
	(url hasFragment or: [url hasQuery]) ifTrue: [^self invalidURL].
	host := url host.
	host isNil 
	    ifTrue: 
		[host := UserProfileSettings default settingAt: #nntpHost ifAbsent: [nil]].
	host isNil ifTrue: [^self invalidURL].
	string := url path.
	string isNil ifTrue: [^self invalidURL].
	self connectClient.
	
	[
	[(string indexOf: $@) > 0 
	    ifTrue: 
		["may be article"

		^self getNewsArticleContents: string]
	    ifFalse: 
		["may be newsgroup"

		^self getThreadedNewsArticleListContents: string]] 
		ensure: [client close]] 
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
    ]

    getNntpContents [
	<category: 'news accessing'>
	| host string read group from to |
	(url hasFragment or: [url hasPostData]) ifTrue: [^self invalidURL].
	host := url host.
	host isNil 
	    ifTrue: 
		[host := UserProfileSettings default settingAt: #nntpHost ifAbsent: [nil]].
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
	self connectClient.
	^
	[
	[to isNil 
	    ifTrue: [self getNewsArticleContents: from group: group]
	    ifFalse: 
		[self 
		    getThreadedNewsArticleListContents: from
		    to: to
		    group: group]] 
		ensure: [client close]] 
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
    ]

    getThreadedNewsArticleList: from to: to group: group [
	<category: 'news accessing'>
	| subjects threads |
	subjects := self 
		    getNewsArticleList: from
		    to: to
		    group: group.
	threads := Dictionary new.
	subjects do: 
		[:array | 
		| read stream head tname col |
		read := (array at: 2) readStream.
		stream := WriteStream on: (String new: read size).
		
		[read skipSeparators.
		head := read nextAvailable: 3.
		'Re:' sameAs: head] 
			whileTrue: [].
		stream
		    nextPutAll: head;
		    nextPutAll: read.
		tname := stream contents.
		col := threads at: tname ifAbsent: [nil].
		col notNil 
		    ifTrue: [col add: array]
		    ifFalse: 
			[col := SortedCollection sortBlock: 
					[:x :y | 
					| xn yn xsize ysize |
					xn := x at: 1.
					yn := y at: 1.
					xsize := (x at: 2) size.
					ysize := (y at: 2) size.
					xsize = ysize ifTrue: [xn <= yn] ifFalse: [xsize <= ysize]].
			col add: array.
			threads at: tname put: col]].
	^threads
    ]

    getThreadedNewsArticleListContents: group [
	<category: 'news accessing'>
	| maxRange range from to prevRanges threads stream pto pfrom |
	maxRange := 100.
	range := client activeArticlesInGroup: group.
	from := range first.
	to := range last.
	prevRanges := OrderedCollection new.
	to - from + 1 > maxRange 
	    ifTrue: 
		[pfrom := from.
		from := to - maxRange + 1.
		pto := from - 1.
		[pto - pfrom + 1 > maxRange] whileTrue: 
			[prevRanges addFirst: (pto - maxRange + 1 to: pto).
			pto := pto - maxRange].
		prevRanges addFirst: (pfrom to: pto)].
	threads := self 
		    getThreadedNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * threads size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , '</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , '</h1>';
	    nl.
	prevRanges isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<hr>';
		    nl;
		    nextPutAll: '<b>Previous articles</b>';
		    nl;
		    nextPutAll: '<ul>';
		    nl.
		prevRanges do: 
			[:r | 
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '?' , r first printString , '-' 
					, r last printString , '">';
			    nl;
			    nextPutAll: r first printString , '-' , r last printString , '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl;
		    nextPutAll: '<hr>';
		    nl].
	threads isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		threads keys asSortedCollection do: 
			[:key | 
			| col first |
			col := threads at: key.
			first := col removeFirst.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , (first at: 1) printString 
					, '">';
			    nl;
			    nextPutAll: (first at: 2) , '</a></li>';
			    nl.
			col isEmpty 
			    ifFalse: 
				[stream
				    nextPutAll: '<ul>';
				    nl.
				col do: 
					[:array | 
					| n subject |
					n := array at: 1.
					subject := array at: 2.
					stream
					    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
					    nl;
					    nextPutAll: subject , '</a></li>';
					    nl].
				stream
				    nextPutAll: '</ul>';
				    nl]].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    getThreadedNewsArticleListContents: from to: to group: group [
	<category: 'news accessing'>
	| threads stream |
	threads := self 
		    getThreadedNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * threads size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</h1>';
	    nl.
	threads isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		threads keys asSortedCollection do: 
			[:key | 
			| col first |
			col := threads at: key.
			first := col removeFirst.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , (first at: 1) printString 
					, '">';
			    nl;
			    nextPutAll: (first at: 2) , '</a></li>';
			    nl.
			col isEmpty 
			    ifFalse: 
				[stream
				    nextPutAll: '<ul>';
				    nl.
				col do: 
					[:array | 
					| n subject |
					n := array at: 1.
					subject := array at: 2.
					stream
					    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
					    nl;
					    nextPutAll: subject , '</a></li>';
					    nl].
				stream
				    nextPutAll: '</ul>';
				    nl]].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    emptyNewsMessage [
	<category: 'postto accessing'>
	| message group org |
	message := self emptyMessage.
	group := url path.
	group isNil 
	    ifFalse: [message parseFieldFrom: ('Newsgroups: ' , group) readStream].
	org := UserProfileSettings default settingAt: #organization
		    ifAbsent: [nil].
	org isNil 
	    ifFalse: [message parseFieldFrom: ('Organization: ' , org) readStream].
	message 
	    parseFieldFrom: ('X-Newsreader: GNU-Smalltalk/' , Smalltalk version) 
		    readStream.
	^message
    ]

    defaultMailAddress [
	<category: 'private'>
	^UserProfileSettings default settingAt: #mailAddress
    ]

    errorContents: errorString [
	<category: 'private'>
	| contents |
	contents := WebEntity 
		    readFrom: ('Content-type: text/html

<html>
<body>
<h1>Error</h1>
<p><b>Reason:</b> ' 
			    , errorString , '</p>
</body>
</html>') 
			    readStream.
	contents url: url.
	contents canCache: false.
	^contents
    ]

    getBufferSize [
	<category: 'private'>
	| kbytes |
	kbytes := (UserProfileSettings default settingAt: #bufferSize) asNumber.
	^kbytes * 1024
    ]

    getNoProxyHostNames [
	<category: 'private'>
	| col read stream noProxy ch |
	col := OrderedCollection new.
	noProxy := UserProfileSettings default settingAt: #proxyList.
	noProxy = 'none' ifTrue: [^col].
	read := noProxy readStream.
	stream := WriteStream on: (String new: 64).
	[read atEnd] whileFalse: 
		[read skipSeparators.
		stream reset.
		[read atEnd or: 
			[ch := read next.
			ch isSeparator or: [ch = $,]]] 
		    whileFalse: [stream nextPut: ch].
		stream isEmpty ifFalse: [col addLast: stream contents]].
	stream isEmpty ifFalse: [col addLast: stream contents].
	^col
    ]

    getProxyContentsHost: hostKey port: portKey [
	<category: 'private'>
	| host port |
	(host := url host) isNil 
	    ifTrue: [^self errorContents: 'No host name is specified'].
	(self isNoProxyHost: host) ifTrue: [^nil].
	host := UserProfileSettings default settingAt: hostKey.
	(host isString and: [host notEmpty]) ifFalse: [^nil].
	port := UserProfileSettings default settingAt: portKey.
	port isInteger ifFalse: [^nil].
        client := HTTP.HTTPClient new.
	self connectClientToHost: host port: port.
	^self requestHttpContents: url fullRequestString
    ]

    getProxyHeadHost: hostKey port: portKey [
	<category: 'private'>
	| host port |
	(host := url host) isNil 
	    ifTrue: [^self errorContents: 'No host name is specified'].
	(self isNoProxyHost: host) ifTrue: [^nil].
	host := UserProfileSettings default settingAt: hostKey.
	(host isString and: [host notEmpty]) ifFalse: [^nil].
	port := UserProfileSettings default settingAt: portKey.
	port isInteger ifFalse: [^nil].
        client := HTTP.HTTPClient new.
	self connectClientToHost: host port: port.
	^self requestHttpHead: url fullRequestString
    ]

    invalidURL [
	<category: 'private'>
	^self errorContents: 'Invalid URL'
    ]

    isNoProxyHost: host [
	<category: 'private'>
	self getNoProxyHostNames 
	    do: [:noproxy | ('*' , noproxy , '*' match: host) ifTrue: [^true]].
	^false
    ]

    on: anURL [
	<category: 'private'>
	url := anURL
    ]

    postProxyContents: contents host: hostKey port: portKey [
	<category: 'private'>
	| host port |
	(host := url host) isNil 
	    ifTrue: [^self errorContents: 'No host name is specified'].
	(self isNoProxyHost: host) ifTrue: [^nil].
	host := UserProfileSettings default settingAt: hostKey.
	(host isString and: [host notEmpty]) ifFalse: [^nil].
	port := UserProfileSettings default settingAt: portKey.
	port isInteger ifFalse: [^nil].
        client := HTTP.HTTPClient new.
	self connectClientToHost: host port: port.
	^self postHttpContents: contents urlString: url fullRequestString
    ]

    tmpFile [
	<category: 'private'>
	| dir |
	dir := UserProfileSettings default settingAt: #tmpDir.
	dir = '' ifTrue: [dir := '/tmp/'] ifFalse: [dir := dir , '/'].
	^FileStream openTemporaryFile: dir
    ]
]



MIME.MimeEntity subclass: WebEntity [
    | url canCache localFileName |
    
    <comment: nil>
    <category: 'NetSupport-WWW-Objects'>

    body [
	<category: 'accessing'>
	| stream type file |
	body isNil ifFalse: [^super body].

	"Read it from the file"
	type := (self fieldAt: 'content-type') type.
	file := File name: localFileName.
	stream := self class parser on: file readStream.
	('message/*' match: type) 
	    ifTrue: 
		[self fields removeKey: 'content-type'.
		self readFrom: stream].
	self parseBodyFrom: stream.
	^body
    ]

    stream [
	<category: 'accessing'>
	| body |
	body := self body.
	self canDelete ifTrue: [(File name: self localFileName) remove].
	^body readStream
    ]

    canCache [
	<category: 'accessing'>
	canCache notNil ifTrue: [^canCache].
	^url notNil and: [url canCache]
    ]

    canCache: aBoolean [
	<category: 'accessing'>
	canCache := aBoolean
    ]

    canDelete [
	<category: 'accessing'>
	(url notNil and: [url isFileScheme]) ifTrue: [^false].
	^self isFileContents
    ]

    isFileContents [
	<category: 'accessing'>
	^localFileName notNil
    ]

    localFileName [
	<category: 'accessing'>
	^localFileName
    ]

    localFileName: aString [
	<category: 'accessing'>
	localFileName := aString
    ]

    url [
	<category: 'accessing'>
	^url
    ]

    url: anURL [
	<category: 'accessing'>
	url := anURL
    ]

    urlName [
	<category: 'accessing'>
	^url isNil ifTrue: ['<no URL>'] ifFalse: [url printString]
    ]

    guessMimeTypeFromResponse: aResponse [
	<category: 'mime types'>
	self addField: (self contentTypeFromResponse: aResponse)
    ]

    guessMimeType [
	<category: 'mime types'>
	| mimeType |
	mimeType := self guessedContentType.
	self addField: (ContentTypeField fromLine: 'content-type: ' , mimeType)
    ]

    contentTypeFromResponse: aResponse [
	<category: 'mime types'>
	| mimeType |
	aResponse isNil 
	    ifFalse: 
		[mimeType := aResponse fieldAt: 'content-type' ifAbsent: [nil].
		mimeType isNil ifFalse: [^mimeType]].
	mimeType := self guessedContentType.
	^ContentTypeField fromLine: 'content-type: ' , mimeType
    ]

    contentTypeFromURL [
	<category: 'mime types'>
	| path index |
	path := url path.
	(path isNil or: [path isEmpty]) ifTrue: [^nil].
	^ContentHandler contentTypeFor: url path ifAbsent: [nil]
    ]

    contentTypeFromContents [
	<category: 'mime types'>
	| file stream |
	file := File name: localFileName.
	file exists 
	    ifTrue: 
		[stream := file readStream.
		^[ContentHandler guessContentTypeFor: stream] ensure: [stream close]]
    ]

    guessedContentType [
	<category: 'mime types'>
	| mimeType |
	url isNil 
	    ifFalse: 
		[mimeType := self contentTypeFromURL.
		mimeType isNil ifFalse: [^mimeType]].
	localFileName isNil 
	    ifFalse: 
		["check for well-known magic types"

		^self contentTypeFromContents].
	^'application/octet-stream'
    ]
]



Object subclass: UserProfileSettings [
    | settings |
    
    <category: 'NetClients-URIResolver'>
    <comment: nil>

    UserProfileSettings class [
	| default |
	
    ]

    UserProfileSettings class >> default [
	<category: 'accessing'>
	^default isNil ifTrue: [default := self new] ifFalse: [default]
    ]

    UserProfileSettings class >> default: aSettingsObject [
	<category: 'accessing'>
	default := aSettingsObject
    ]

    UserProfileSettings class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    UserProfileSettings class >> postLoad: aParcel [
	<category: 'parcel load/unload'>
	self initialize
    ]

    settings [
	<category: 'accessing'>
	^settings
    ]

    settings: aValue [
	<category: 'accessing'>
	settings := aValue
    ]

    settingAt: aSymbol [
	<category: 'api'>
	^self settings at: aSymbol ifAbsent: ['']
    ]

    settingFor: aSymbol put: aValue [
	<category: 'api'>
	^self settings at: aSymbol put: aValue
    ]

    initialize [
	<category: 'initialize-release'>
	self settings: IdentityDictionary new.
	self settings at: #tmpDir put: Directory temporary.
	self settings at: #mailer put: 'SMTPClient'.
	self settings at: #bufferSize put: '16'.
	self settings at: #proxyList put: 'none'.
	self settings at: #mailAddress put: nil.
	self settings at: #mailServer put: nil.
	self settings at: #signature put: nil.
	self settings at: #hostKey put: ''.
	self settings at: #portKey put: '80'
    ]
]



Eval [
    UserProfileSettings initialize
]

