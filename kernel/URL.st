"======================================================================
|
|   URL class and basic support for resolving URLs
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, in the public domain
| Copyright (c) 2002, 2003, 2008, 2008, 2009 Free Software Foundation, Inc.
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



Namespace current: NetClients [

Object subclass: URL [
    | scheme username password host port path query hasPostData fragment hash |
    
    <category: 'NetClients-URIResolver'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.

'>

    NoPercentEncoding := nil.

    URL class >> decode: aString [
	"Decode a text/x-www-form-urlencoded String into a text/plain String."

	<category: 'encoding URLs'>
	| result in ch |
	result := WriteStream on: (String new: aString size).
	in := ReadStream on: aString.
	[in atEnd] whileFalse: 
		[(ch := in next) = $+ 
		    ifTrue: [result nextPut: $ ]
		    ifFalse: 
			[ch = $% 
			    ifFalse: [result nextPut: ch]
			    ifTrue: 
				[ch := in next digitValue * 16 + in next digitValue.
				result nextPut: ch asCharacter]]].
	^result contents
    ]

    URL class >> encode: anURL [
	"Encode a text/plain into a text/x-www-form-urlencoded String (those
	 things with lots of % in them)."

	<category: 'encoding URLs'>
	| result value |
	result := WriteStream on: (String new: anURL size + 10).
	anURL do: 
		[:each | 
		each = $  
		    ifTrue: [result nextPut: $+]
		    ifFalse: 
			[value := each value.
			(NoPercentEncoding at: value + 1) = 1 
			    ifTrue: [result nextPut: each]
			    ifFalse: 
				[result
				    nextPut: $%;
				    nextPut: ('0123456789ABCDEF' at: value // 16 + 1);
				    nextPut: ('0123456789ABCDEF' at: value \\ 16 + 1)]]].
	^result contents
    ]

    URL class >> initialize [
	"Initialize the receiver's class variables."

	<category: 'encoding URLs'>
	NoPercentEncoding := ByteArray new: 256.
	'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -_.*0123456789' 
	    do: [:each | NoPercentEncoding at: each value + 1 put: 1]
    ]

    URL class >> fromString: aString [
	"Parse the given URL and answer an URL object based on it."

	"URL fromString: 'http://www/dir/file.html'."
	"URL fromString: 'http://www:10080/dir/file.html'."
	"URL fromString: 'http://www:10080/dir/file.html?x=100'."
	"URL fromString: 'http://www:10080/dir/file.html#section'."
	"URL fromString: 'ftp://ftp/pub/smalltalk'."
	"URL fromString: 'ftp://ftp:21/pub/smalltalk'."
	"URL fromString: 'ftp://user@ftp:21/pub/smalltalk'."
	"URL fromString: 'ftp://user@ftp/pub/smalltalk'."
	"URL fromString: 'ftp://user:passwd@ftp:21/pub/smalltalk'."
	"URL fromString: 'news:fj.lang.smalltalk'."
	"URL fromString: '/dir/file.html'."
	"URL fromString: 'file.html'."

	<category: 'instance creation'>
	"check fragment and query parts"

	| fragmentIndex queryIndex limit fragmentLimit queryLimit urlString url |
	urlString := aString asString.
	urlString == aString ifFalse: [ ^self fromString: urlString ].

	limit := aString size + 1.
	(queryIndex := aString indexOf: $?) ~= 0 
	    ifTrue: 
		[limit := queryIndex.
		queryLimit := aString 
			    indexOf: $#
			    startingAt: queryIndex + 1
			    ifAbsent: [aString size + 1]].
	(fragmentIndex := aString indexOf: $#) ~= 0 
	    ifTrue: 
		[limit := limit min: fragmentIndex.
		fragmentLimit := aString 
			    indexOf: $?
			    startingAt: fragmentIndex + 1
			    ifAbsent: [aString size + 1]].
	urlString := aString copyFrom: 1 to: limit - 1.
	url := self fromURLString: urlString.
	queryIndex > 0 
	    ifTrue: [url query: (aString copyFrom: queryIndex + 1 to: queryLimit - 1)].
	fragmentIndex > 0 
	    ifTrue: 
		[url fragment: (aString copyFrom: fragmentIndex + 1 to: fragmentLimit - 1)].
	^url
    ]

    URL class >> new [
	"Answer a 'blank' URL."

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    URL class >> scheme: schemeString username: userString password: passwordString host: hostString port: portNumber path: pathString [
	"Answer an URL object made from all the parts passed as arguments."

	<category: 'instance creation'>
	^(self new)
	    scheme: schemeString;
	    username: userString;
	    password: passwordString;
	    host: hostString;
	    port: portNumber;
	    path: pathString;
	    yourself
    ]

    URL class >> scheme: schemeString host: hostString port: portNumber path: pathString [
	"Answer an URL object made from all the parts passed as arguments."

	<category: 'instance creation'>
	^(self new)
	    scheme: schemeString;
	    host: hostString;
	    port: portNumber;
	    path: pathString;
	    yourself
    ]


    URL class >> scheme: schemeString host: hostString path: pathString [
	"Answer an URL object made from all the parts passed as arguments."

	<category: 'instance creation'>
	^(self new)
	    scheme: schemeString;
	    host: hostString;
	    port: 0;
	    path: pathString;
	    yourself
    ]

    URL class >> scheme: schemeString path: pathString [
	"Answer an URL object made from all the parts passed as arguments."

	<category: 'instance creation'>
	^(self new)
	    scheme: schemeString;
	    host: nil;
	    port: 0;
	    path: pathString;
	    yourself
    ]

    URL class >> fromURLString: aString [
	"URL fromString: 'http://www/dir/file.html'."
	"URL fromString: 'http://www:10080/dir/file.html'."
	"URL fromString: 'ftp://ftp/pub/smalltalk'."
	"URL fromString: 'ftp://ftp:21/pub/smalltalk'."
	"URL fromString: 'ftp://user@ftp:21/pub/smalltalk'."
	"URL fromString: 'ftp://user@ftp/pub/smalltalk'."
	"URL fromString: 'ftp://user:passwd@ftp:21/pub/smalltalk'."
	"URL fromString: 'news:fj.lang.smalltalk'."
	"URL fromString: '/dir/file.html'."
	"URL fromString: '//host/dir/file.html'."
	"URL fromString: 'file.html'."

	<category: 'private'>
	"defPath := String with: $/."

	| defPath read write ch scheme username password host port path pos try |
	defPath := nil.
	read := aString readStream.
	write := WriteStream on: (String new: aString size).

	"parse scheme"
	[read atEnd or: [
	    (ch := read next) isAlphaNumeric not
	    and: [ch ~= $+]]] 
	    whileFalse: [write nextPut: ch].
	(write isEmpty or: [ch ~= $:]) 
	    ifTrue: 
		["no scheme"

		read reset.
		scheme := nil

		"aString isEmpty
		 ifTrue:	[path := defPath]
		 ifFalse:	[path := aString]."

		"It's may be a file name."
		"^self scheme: nil path: path"]
	    ifFalse: [scheme := write contents].
	write reset.
	pos := read position.
	(read nextAvailable: 2) = '//' 
	    ifFalse: 
		["no host and port"

		read position: pos.
		path := read upToEnd.
		path isEmpty ifTrue: [path := defPath].
		^self scheme: scheme path: path].

	"parse host and port (and user and password)."
	try := true.
	[try] whileTrue: 
		[[read atEnd or: [(ch := read next) = $/ or: [ch = $: or: [ch = $@]]]] 
		    whileFalse: [write nextPut: ch].
		write isEmpty ifFalse: [host := write contents].
		write reset.
		ch = $: 
		    ifTrue: 
			["parse port or passwd"

			[read atEnd or: [(ch := read next) = $/ or: [ch = $@]]] 
			    whileFalse: [write nextPut: ch].
			write isEmpty ifFalse: [port := write contents].
			write reset].
		ch = $@ 
		    ifFalse: [try := false]
		    ifTrue: 
			["re-parse host"

			host notNil 
			    ifTrue: 
				[username := host.
				host := nil].
			port notNil 
			    ifTrue: 
				[password := port.
				port := nil]]].
	port := port isNil ifTrue: [0] ifFalse: [port asInteger].
	read atEnd 
	    ifTrue: [path := defPath]
	    ifFalse: 
		[write
		    nextPut: ch;
		    nextPutAll: read.
		path := write contents].
	^self 
	    scheme: scheme
	    username: username
	    password: password
	    host: host
	    port: port
	    path: path
    ]

    = anURL [
	"Answer whether the two URLs are equal.  The file and anchor
	 are converted to full 8-bit ASCII (contrast with urlencoded)
	 and the comparison is case-sensitive; on the other hand,
	 the protocol and host are compared without regard to case."

	<category: 'comparing'>
	self class == anURL class ifFalse: [^false].
	self hash = anURL hash ifFalse: [^false].
	self scheme == anURL scheme 
	    ifFalse: [(self scheme sameAs: anURL scheme) ifFalse: [^false]].
	self host == anURL host 
	    ifFalse: [(self host sameAs: anURL host) ifFalse: [^false]].
	^self port = anURL port and: 
		[self decodedFile = anURL decodedFile 
		    and: [self decodedFragment = anURL decodedFragment]]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'comparing'>
	hash isNil ifTrue: [hash := (URL decode: self printString) hash].
	^hash
    ]

    canCache [
	"Answer whether the URL is cacheable.  The current implementation considers
	 file URLs not to be cacheable, and everything else to be."

	<category: 'testing'>
	^self isFileScheme not
    ]

    hasFragment [
	"Answer whether the URL points to a particular fragment (anchor) of the
	 resource."

	<category: 'testing'>
	^fragment notNil
    ]

    hasQuery [
	"Answer whether the URL includes query arguments to be submitted when
	 retrieving the resource."

	<category: 'testing'>
	^query notNil
    ]

    isFileScheme [
	"Answer whether the URL is a file URL."

	<category: 'testing'>
	^scheme isNil or: [scheme = 'file']
    ]

    isFragmentOnly [
	"Answer whether the URL only includes the name of a particular fragment (anchor)
	 of the resource to which it refers."

	<category: 'testing'>
	^fragment notNil 
	    and: [scheme isNil and: [host isNil and: [port = 0 and: [path isNil]]]]
    ]

    add: key to: dict value: value [
	"Add the key->value pair to dict; if the key is specified multiple times,
	 make an OrderedCollection with all the values"

	<category: 'private'>
	| values |
	values := dict at: key ifAbsent: [^dict at: key put: value].
	values isString ifFalse: [^values add: value].

	"Make the OrderedCollection"
	dict at: key put: (OrderedCollection with: values with: value).
	^value
    ]

    clearAuxiliaryParts [
	<category: 'private'>
	hasPostData := false.
	fragment := query := nil
    ]

    clearFragment [
	<category: 'private'>
	fragment := nil
    ]

    constructPath: path1 with: path2 [
	<category: 'private'>
	| sep dirStack read p write |
	sep := $/.
	dirStack := OrderedCollection new.
	(path2 isEmpty not and: [path2 first = sep]) 
	    ifFalse: 
		[read := path1 readStream.
		[read atEnd] whileFalse: 
			[p := read upTo: sep.
			(p isEmpty or: [p = '.']) 
			    ifFalse: 
				[p = '..' 
				    ifTrue: [dirStack isEmpty ifFalse: [dirStack removeLast]]
				    ifFalse: [dirStack addLast: p]]].
		(path1 isEmpty not and: [path1 last = sep]) 
		    ifFalse: 
			["trim path tail (file name)."

			dirStack isEmpty ifFalse: [dirStack removeLast]]].
	read := path2 readStream.
	[read atEnd] whileFalse: 
		[p := read upTo: sep.
		(p isEmpty or: [p = '.']) 
		    ifFalse: 
			[p = '..' 
			    ifTrue: [dirStack isEmpty ifFalse: [dirStack removeLast]]
			    ifFalse: [dirStack addLast: p]]].
	dirStack isEmpty ifTrue: [^String with: sep].
	write := WriteStream on: (String new: path1 size + path2 size).
	[dirStack isEmpty] whileFalse: 
		[write
		    nextPut: sep;
		    nextPutAll: dirStack removeFirst].
	(path2 isEmpty not and: [path2 last = sep]) ifTrue: [write nextPut: sep].
	^write contents
    ]

    construct: anURL [
	"Construct an absolute URL based on the relative URL anURL and the base path
	 represented by the receiver"

	"(URL fromString: 'http://www/dir/file.html') construct: (URL fromString: 'subdir/image.gif')."

	"(URL fromString: 'http://www/dir1/file.html') construct: (URL fromString: '/dir2/image.gif')."

	"(URL fromString: 'http://www/dir1/file.html') construct: (URL fromString: '~kyasu/')."

	"(URL fromString: 'http://www/dir/file.html') construct: (URL fromString: '#introduction')."

	"(URL fromString: 'http://www/dir/file.html') construct: (URL fromString: '/cgi-bin/perl.pl?dest=/other')."

	"(URL fromString: 'http://www/dir/file.html') construct: (URL fromString: 'http:/cgi-bin/perl.pl?dest=/other')."

	"(URL fromString: 'http://www-s2.rsl.crl.fujixerox.co.jp/~kyasu/') construct: (URL fromString: 'http://arrow')."

	"(URL fromString: 'gopher://www.com') construct: (URL fromString: '//www.com:70/ParcBenchMain')."

	"(URL fromString: 'http://www/some.html') construct: (URL fromString: 'http://www/')."

	"(URL fromString: '../tmp/table.html') construct: (URL fromString: 'kyasu.gif')."

	<category: 'utilities'>
	| newURL |
	anURL scheme notNil 
	    ifTrue: 
		[scheme ~= anURL scheme ifTrue: [^anURL].
		anURL host notNil ifTrue: [^anURL]
		"(anURL host notNil and: [host ~= anURL host]) ifTrue: [^anURL].
		 (anURL port notNil and: [port ~= anURL port]) ifTrue: [^anURL]"].
	newURL := self copyWithoutAuxiliaryParts.
	anURL path notNil 
	    ifTrue: 
		[self isFileScheme 
		    ifTrue: 
			[(path isNil or: [anURL path isEmpty not and: [anURL path first = $/]]) 
			    ifTrue: [newURL path: anURL path]
			    ifFalse: 
				[(path isEmpty not and: [path first = $/]) 
				    ifTrue: [newURL path: (self constructPath: path with: anURL path)]
				    ifFalse: 
					[newURL path: (path asFilename directory constructString: anURL path)]]]
		    ifFalse: 
			[path isNil 
			    ifTrue: [newURL path: (self constructPath: '/' with: anURL path)]
			    ifFalse: [newURL path: (self constructPath: path with: anURL path)]]].
	newURL
	    query: anURL query;
	    hasPostData: anURL hasPostData;
	    fragment: anURL fragment.
	^newURL
    ]

    copyWithoutAuxiliaryParts [
	"Answer a copy of the receiver where the fragment and query
	 parts of the URL have been cleared."

	<category: 'copying'>
	^self shallowCopy clearAuxiliaryParts postCopy
    ]

    copyWithoutFragment [
	"Answer a copy of the receiver where the fragment
	 parts of the URL has been cleared."

	<category: 'copying'>
	^self shallowCopy clearFragment postCopy
    ]

    postCopy [
	"All the variables are copied when an URL object is copied."

	<category: 'copying'>
	super postCopy.
	scheme := scheme copy.
	username := username copy.
	password := password copy.
	host := host copy.
	port := port copy.
	path := path copy.
	fragment := fragment copy.
	query := query copy
    ]

    decodedFields [
	"Convert the form fields to a Dictionary, answer
	 nil if no question mark is found in the URL."

	<category: 'accessing'>
	| query dict |
	query := self query.
	query isNil ifTrue: [^nil].
	dict := LookupTable new.
	(query substrings: $&) do: 
		[:keyValue | 
		| i key value |
		i := keyValue indexOf: $=
			    ifAbsent: 
				[value := nil.
				keyValue size + 1].
		key := keyValue copyFrom: 1 to: i - 1.
		i < keyValue size 
		    ifTrue: 
			[value := keyValue copyFrom: i + 1 to: value size.
			value := URL decode: value].
		self 
		    add: key
		    to: dict
		    value: value].
	^dict
    ]

    decodedFragment [
	"Answer the fragment part of the URL, decoding it from x-www-form-urlencoded
	 format."

	<category: 'accessing'>
	^URL decode: self fragment
    ]

    decodedFile [
	"Answer the file part of the URL, decoding it from x-www-form-urlencoded
	 format."

	<category: 'accessing'>
	^URL decode: self file
    ]

    fragment [
	"Answer the fragment part of the URL, leaving it in x-www-form-urlencoded
	 format."

	<category: 'accessing'>
	^fragment
    ]

    fragment: aString [
	"Set the fragment part of the URL, which should be in x-www-form-urlencoded
	 format."

	<category: 'accessing'>
	fragment := aString
    ]

    asString [
	"Answer the full request string corresponding to the URL.  This is how
	 the URL would be printed in the address bar of a web browser, except that
	 the query data is printed even if it is to be sent through a POST request."

	<category: 'accessing'>
	^self printString
    ]

    fullRequestString [
	"Answer the full request string corresponding to the URL.  This is how
	 the URL would be printed in the address bar of a web browser, except that
	 the query data is printed even if it is to be sent through a POST request."

	<category: 'accessing'>
	^self printString
    ]

    hasPostData [
	"Answer whether the URL has a query part but is actually for an HTTP POST
	 request and not really part of the URL (as it would be for the HTTP
	 GET request)."

	<category: 'accessing'>
	^hasPostData and: [query notNil]
    ]

    hasPostData: aBoolean [
	"Set whether the query part of the URL is actually the data for an HTTP POST
	 request and not really part of the URL (as it would be for the HTTP
	 GET request)."

	<category: 'accessing'>
	hasPostData := aBoolean
    ]

    host [
	"Answer the host part of the URL."

	<category: 'accessing'>
	^host
    ]

    host: aString [
	"Set the host part of the URL to aString."

	<category: 'accessing'>
	host := aString
    ]

    newsGroup [
	"If the receiver is an nntp url, return the news group."

	<category: 'accessing'>
	((scheme = 'nntp' | scheme) = 'news' and: [path notNil]) 
	    ifTrue: 
		[^path copyFrom: 2
		    to: (path 
			    indexOf: $/
			    startingAt: 2
			    ifAbsent: [path size + 1]) - 1].
	^nil
    ]

    password [
	"Answer the password part of the URL."

	<category: 'accessing'>
	^password
    ]

    password: aString [
	"Set the password part of the URL to aString."

	<category: 'accessing'>
	password := aString
    ]

    path [
	"Answer the path part of the URL."

	<category: 'accessing'>
	^path
    ]

    path: aString [
	"Set the path part of the URL to aString."

	<category: 'accessing'>
	path := aString
    ]

    port [
	"Answer the port number part of the URL."

	<category: 'accessing'>
	^port
    ]

    port: anInteger [
	"Set the port number part of the URL to anInteger."

	<category: 'accessing'>
	port := anInteger
    ]

    postData [
	"Answer whether the URL has a query part and it is meant for an HTTP POST
	 request, answer it.  Else answer nil."

	<category: 'accessing'>
	self hasPostData ifTrue: [^query].
	^nil
    ]

    postData: aString [
	"Associate to the URL some data that is meant to be sent through an HTTP POST
	 request, answer it."

	<category: 'accessing'>
	query := aString.
	hasPostData := true
    ]

    requestString [
	"Answer the URL as it would be sent in an HTTP stream (that is, the
	 path and the query data, the latter only if it is to be sent with
	 an HTTP POST request)."

	<category: 'accessing'>
	| stream |
	stream := WriteStream on: (String new: 128).
	path isNil ifTrue: [stream nextPut: $/] ifFalse: [stream nextPutAll: path].
	(self hasQuery and: [self hasPostData not]) 
	    ifTrue: 
		[stream
		    nextPut: $?;
		    nextPutAll: query].
	^stream contents
    ]

    scheme [
	"Answer the URL's scheme."

	<category: 'accessing'>
	^scheme
    ]

    scheme: aString [
	"Set the URL's scheme to be aString."

	<category: 'accessing'>
	scheme := aString
    ]

    username [
	"Answer the username part of the URL."

	<category: 'accessing'>
	^username
    ]

    username: aString [
	"Set the username part of the URL to aString."

	<category: 'accessing'>
	username := aString
    ]

    query [
	"Answer the query data associated to the URL."

	<category: 'accessing'>
	^query
    ]

    query: aString [
	"Set the query data associated to the URL to aString."

	<category: 'accessing'>
	query := aString
    ]

    initialize [
	"Initialize the object to a consistent state."

	<category: 'initialize-release'>
	self clearAuxiliaryParts
    ]

    printOn: stream [
	"Print a representation of the URL on the given stream."

	<category: 'printing'>
	scheme notNil 
	    ifTrue: 
		[stream
		    nextPutAll: scheme;
		    nextPut: $:].
	host notNil 
	    ifTrue: 
		[scheme notNil ifTrue: [stream nextPutAll: '//'].
		username notNil 
		    ifTrue: 
			[stream nextPutAll: username.
			password notNil 
			    ifTrue: 
				[stream
				    nextPut: $:;
				    nextPutAll: password].
			stream nextPut: $@].
		stream nextPutAll: host.
		port > 0 
		    ifTrue: 
			[stream
			    nextPut: $:;
			    print: port]].
	path isNil ifTrue: [stream nextPut: $/] ifFalse: [stream nextPutAll: path].
	self hasQuery 
	    ifTrue: 
		[stream
		    nextPut: $?;
		    nextPutAll: query].
	self hasFragment 
	    ifTrue: 
		[stream
		    nextPut: $#;
		    nextPutAll: fragment]
    ]

    contents [
	<contents: 'streaming'>
	| s |
	^[ (s := self readStream) contents ] ensure: [
	    s ifNotNil: [ s close ] ]
    ]

    entity [
	<contents: 'streaming'>
	^NetClients.URIResolver openOn: self ifFail: [
	    SystemExceptions.FileError signal: 'could not open %1' % {self} ]
    ]

    readStream [
	<contents: 'streaming'>
	^NetClients.URIResolver openStreamOn: self ifFail: [
	    SystemExceptions.FileError signal: 'could not open %1' % {self} ]
    ]

    resolvePath: newName [
	<category: 'private'>
	^NetClients.URIResolver resolve: newName from: self
    ]
]

]



Namespace current: NetClients [

Object subclass: URIResolver [
    
    <category: 'NetClients-URIResolver'>
    <comment: '
This class publishes methods to download files from the Internet.'>

    URIResolver class >> on: anURL [
	"Answer a new URIResolver that will do its best to fetch the data for
	 anURL from the Internet."

	<category: 'instance creation'>
	^self new on: anURL
    ]

    URIResolver class >> openStreamOn: aURI ifFail: aBlock [
	"Check if aURI can be fetched from the Internet or from the local system,
	 and if so return a Stream with its contents.  If this is not possible,
	 instead, evaluate the zero-argument block aBlock and answer the result
	 of the evaluation."

	<category: 'api'>
	| url name body |
	url := aURI.
	(url respondsTo: #key) ifTrue: [url := url key , ':/' , url value].
	url isString ifTrue: [url := URL fromString: url].
	url scheme = 'file' ifFalse: [^aBlock value].
	name := url path copy.
	name replaceAll: $/ with: Directory pathSeparator.
	^FileStream 
	    fopen: name
	    mode: FileStream read
	    ifFail: aBlock
    ]

    URIResolver class >> openOn: aURI ifFail: aBlock [
	"Always evaluate aBlock and answer the result if the additional NetClients
	 package is not loaded.  If it is, instead, return a WebEntity with the
	 contents of the resource specified by anURI, and only evaluate the block
	 if loading the resource fails."

	<category: 'api'>
	^aBlock value
    ]

    URIResolver class >> openStreamOn: aURI [
	"Check if aURI can be fetched from the Internet or from the local system,
	 and if so return a Stream with its contents.  If this is not possible,
	 raise an exception."

	<category: 'api'>
	^self openStreamOn: aURI
	    ifFail: 
		[SystemExceptions.FileError signal: 'could not open ' , aURI printString]
    ]

    URIResolver class >> openOn: aURI [
	"Always raise an error, as this method is not supported
	 without loading the additional NetClients package."

	<category: 'api'>
	^self openOn: aURI
	    ifFail: 
		[SystemExceptions.FileError signal: 'could not open ' , aURI printString]
    ]

    URIResolver class >> resolve: newName from: oldURI [
	<category: 'private'>
	| url newURI |
	url := oldURI.
	(url respondsTo: #key) ifTrue: [url := url key , ':/' , url value].
	url isString ifTrue: [url := URL fromString: url].
	url := url construct: (URL fromString: newName).
	newURI := url printString.
	^url
    ]
]

]



Namespace current: NetClients [
    URL initialize
]

