"======================================================================
|
|   File server plug-in
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2008 Travis Griggs and Ken Treis
| Written by Travis Griggs, Ken Treis and others.
| Port to GNU Smalltalk, enhancements and refactory by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"



WebResponse subclass: FileSystemResponse [
    | file |
    
    <comment: '
A FileSystemResponse, being tied to a File object, knows about its
last modification time.'>
    <category: 'Web-File Server'>

    FileSystemResponse class >> file: aFile [
	<category: 'instance creation'>
	^self new file: aFile
    ]

    file: aFile [
	<category: 'initialize-release'>
	file := aFile
    ]

    modifiedTime [
	<category: 'response'>
	^file lastModifyTime
    ]
]



FileSystemResponse subclass: DirectoryResponse [
    
    <comment: '
A DirectoryResponse formats output of the contents of a Directory object.'>
    <category: 'Web-File Server'>

    chopName: aString [
	<category: 'response'>
	^aString size > self maxNameLength 
	    ifTrue: [(aString copyFrom: 1 to: self maxNameLength - 3) , '...']
	    ifFalse: [aString]
    ]

    maxNameLength [
	<category: 'response'>
	^30
    ]

    maxSizeLength [
	<category: 'response'>
	^6
    ]

    sendMetaHeaders [
	"While caching of file responses is generally desirable (even though
	 it can be incorrect if somebody does some uploading), caching
	 directory responses can be extremely confusing and could yield
	 incorrect uploads (where someone thinks he uploaded something and
	 actually didn't)"

	<category: 'response'>
	self
	    << '<meta http-equiv="Pragma" content="no-cache">';
	    nl.
	self
	    << '<meta http-equiv="Cache-control" content="no-cache">';
	    nl
    ]

    sendBody [
	<category: 'response'>
	self
	    << '<html><head><title>Directory Listing for ';
	    << request uri;
	    << '</title>';
	    nl;
	    sendMetaHeaders;
	    << '</head><body><h1>Directory Contents:</h1><pre>';
	    nl;
	    << 'Name';
	    next: self maxNameLength - 1 put: $ ;
	    << 'Modified on	       Size';
	    nl;
	    << '<hr>';
	    nl.
	(File name: file name) entryNames asSortedCollection 
	    do: [:each | self sendFileProperties: each].
	self << '</pre><hr><FORM ACTION="' << request uri.
	self
	    << '" METHOD="post" ENCTYPE="multipart/form-data">';
	    nl.
	self
	    << '<INPUT TYPE="file" NAME="contents">';
	    nl.
	self
	    << '<INPUT TYPE="submit" VALUE="Upload"></FORM>';
	    nl.
	self << '</body></html>'
    ]

    sendFileProperties: each [
	<category: 'response'>
	| isDirectory choppedName name subDirFile parent slash |
	each = '.' ifTrue: [^self].
	subDirFile := file / each.
	subDirFile isReadable ifFalse: [^self].
	isDirectory := subDirFile isDirectory.
	choppedName := isDirectory 
		    ifTrue: [self chopName: (each copyWith: $/)]
		    ifFalse: [self chopName: each].
	each = '..' 
	    ifTrue: 
		[slash := request uri findLast: [:each | each == $/].
		slash = 1 ifTrue: [^self].
		self << '<a href="' << (request uri copyFrom: 1 to: slash)]
	    ifFalse: [self << '<a href="' << request uri << $/ << each].
	self << '">' << choppedName << '</a>'.
	self next: self maxNameLength - choppedName size + 3 put: $ .
	self sendModifyTimeFor: subDirFile.
	isDirectory ifFalse: [self sendFileSizeFor: subDirFile].
	self nl
    ]

    sendModifyTimeFor: aFile [
	<category: 'response'>
	| date |
	date := aFile lastModifyTime at: 1.
	date day < 10 ifTrue: [self nextPut: $0].
	self << date << '	  '
    ]

    sendFileSizeFor: aFile [
	<category: 'response'>
	| size type printString |
	size := [aFile size] on: Error do: [:ex | ex return: nil].
	size isNil ifTrue: [^self].
	printString := String new: self maxSizeLength withAll: $ .
	type := #('Bytes' 'KB' 'MB' 'GB' 'TB') detect: 
			[:each | 
			| found |
			found := size < 10000.
			found ifFalse: [size := (size + 512) // 1024].
			found]
		    ifNone: 
			[^self
			    next: self maxSizeLength put: $*;
			    << ' huge!'].
	printString := printString , size rounded printString.
	printString := printString 
		    copyFrom: printString size + 1 - self maxSizeLength.
	self
	    << printString;
	    space;
	    << type
    ]
]



DirectoryResponse subclass: UploadResponse [
    
    <comment: '
An UploadResponse formats output of the contents of a Directory object,
and interprets multipart/form-data contents sent by a client that wants
to upload a file.'>
    <category: 'Web-File Server'>

    respondTo: aRequest [
	<category: 'response'>
	self doUpload: aRequest.
	super respondTo: aRequest
    ]

    doUpload: aRequest [
	"This is not a general multipart/form-data parser. The only things
	 it lacks is the ability to parse more than one field (with the
	 last boundary identified by two trailing dashes) and to build a
	 dictionary with the contents of each form field."

	<category: 'multipart'>
	| boundary str i remoteName uploadStream subHeaders |
	request := aRequest.
	boundary := self boundaryString.
	boundary isNil ifTrue: [^self].
	(request stream)
	    skipToAll: boundary;
	    nextLine.
	subHeaders := self getSubHeaders.
	subHeaders isEmpty ifTrue: [^self].
	str := subHeaders at: #'CONTENT-DISPOSITION' ifAbsent: [''].
	i := str indexOfSubCollection: 'filename="' ifAbsent: [0].
	i = 0 ifTrue: [^self].
	i := i + 10.
	(str at: i) == $" ifTrue: [^self].
	remoteName := str copyFrom: i to: (str indexOf: $" startingAt: i) - 1.
	remoteName := URL decode: remoteName.	"### not sure about this..."
	uploadStream := (self localFileFor: remoteName) writeStream.

	"Collect at least 128 bytes of content (of course, stop if we see a
	 boundary).	 We need this quantity because M$ Internet Explorer 4.0
	 for Mac appends 128 bytes of Mac file system info which we must
	 remove."
	boundary := boundary precompileSearch.
	str := self nextChunk.
	
	[i := boundary searchIn: str startingAt: 1.
	i notNil and: [str size < 128]] 
		whileTrue: [str := str , self nextChunk].
	((str at: 1) asciiValue = 0 and: 
		[(str at: 2) asciiValue = remoteName size 
		    and: [(str copyFrom: 3 to: remoteName size + 2) = remoteName]]) 
	    ifTrue: 
		[str := str copyFrom: 129 to: str size.
		i := i - 128].

	"Now do the real work"
	[i > 0] whileFalse: 
		[request stream isPeerAlive 
		    ifFalse: 
			[uploadStream close.
			(self localFileFor: remoteName) remove.
			^self].

		"While we don't encounter a chunk which could contain the
		 boundary, copy at maximum speed."
		
		[i := boundary possibleMatchSearchIn: str startingAt: 5.
		i > 0] 
			whileFalse: 
			    [uploadStream nextPutAll: str.
			    str := self nextChunk].

		"The boundary could be here. We have to look more carefully."
		i := boundary searchIn: str startingAt: i - 4.
		i > 0 
		    ifFalse: 
			["Not found, but it might finish in the next chunk..."

			uploadStream nextPutAll: (str copyFrom: 1 to: i - 5).
			str := (str copyFrom: i - 4 to: str size) , self nextChunk.
			i := boundary searchIn: str startingAt: 1]].

	"Save the last chunk in the file (the first if we didn't go through
	 the while loop."
	i > 5 ifTrue: [uploadStream nextPutAll: (str copyFrom: 1 to: i - 5)].

	"Clean things up..."
	uploadStream close
    ]

    nextChunk [
	<category: 'multipart'>
	
	request stream isPeerAlive ifFalse: [^''].
	^request stream nextAvailable: 1024
    ]

    localFileFor: remoteName [
	<category: 'multipart'>
	| idx fileName |
	idx := remoteName findLast: [:each | ':/\' includes: each].
	fileName := remoteName copyFrom: idx + 1.
	^file at: fileName
    ]

    getSubHeaders [
	<category: 'multipart'>
	| hdr subHeaders line colon |
	subHeaders := LookupTable new.
	
	[line := request stream nextLine.
	colon := line indexOf: $:.
	colon = 0] 
		whileFalse: 
		    [subHeaders at: (line copyFrom: 1 to: colon - 1) asUppercase asSymbol
			put: (line copyFrom: colon + 1) trimSeparators].
	^subHeaders
    ]

    boundaryString [
	"Decode multipart form data boundary information from a
	 header line that looks like the following line:
	 Content-Type: multipart/form-data; boundary=-----"

	<category: 'multipart'>
	| str |
	str := (request at: #'CONTENT-TYPE' ifAbsent: ['']) readStream.
	(str upTo: $;) = 'multipart/form-data' ifFalse: [^nil].
	str skipTo: $=.

	"Boundary lines *always* start with two dashes"
	^'--' , str upToEnd
    ]
]



FileSystemResponse subclass: FileResponse [
    | fileStream |
    
    <comment: '
A FileResponse outputs the contents of a whole file onto an HTTP
data stream.'>
    <category: 'Web-File Server'>

    FileResponse class >> file: aFile [
	<category: 'instance creation'>
	^
	[| fileStream |
	fileStream := aFile readStream.
	(super file: aFile)
	    fileStream: fileStream;
	    yourself] 
		on: Error
		do: [:ex | ex return: ErrorResponse forbidden]
    ]

    mimeType [
	<category: 'accessing'>
	^ContentHandler contentTypeFor: file name
    ]

    respondTo: aRequest [
	<category: 'response'>
	[super respondTo: aRequest] ensure: [fileStream close]
    ]

    sendBody [
	<category: 'response'>
	| size data read |
	size := fileStream size.
	[size > 0] whileTrue: 
		[data := fileStream next: (read := size min: 2000).
		size := size - read.
		self nextPutAll: data]
    ]

    contentLength [
	<category: 'response'>
	^fileStream size
    ]

    sendMimeType [
	<category: 'response'>
	self
	    << 'Content-Type: ';
	    << self mimeType;
	    nl
    ]

    sendStandardHeaders [
	<category: 'response'>
	super sendStandardHeaders.
	self
	    << 'Accept-Ranges: bytes';
	    nl
    ]

    fileStream: aStream [
	<category: 'initialize-release'>
	fileStream := aStream
    ]
]



FileResponse subclass: RangeResponse [
    | range |
    
    <comment: '
A RangeResponse outputs the contents of a single interval of a file
onto an HTTP data stream.'>
    <category: 'Web-File Server'>

    RangeResponse class >> file: aFile range: aRangeSpecification [
	<category: 'response'>
	| response |
	response := self file: aFile.
	^response isErrorResponse 
	    ifTrue: [response]
	    ifFalse: [response range: aRangeSpecification]
    ]

    range: aRangeSpecification [
	<category: 'initialize-release'>
	range := aRangeSpecification.
	range fileSize: fileStream size
    ]

    sendBody [
	<category: 'response'>
	self sendBody: range
    ]

    sendBody: range [
	<category: 'response'>
	| size data read |
	size := range last - range first + 1.
	fileStream position: range first.
	[size > 0] whileTrue: 
		[data := fileStream next: (read := size min: 2000).
		size := size - read.
		self nextPutAll: data]
    ]

    sendStandardHeaders [
	<category: 'response'>
	super sendStandardHeaders.
	range sendStandardHeadersOn: self
    ]

    contentLength [
	<category: 'response'>
	^range last - range first + 1
    ]
]



RangeResponse subclass: MultiRangeResponse [
    | mimeType boundary |
    
    <comment: '
A MultiRangeResponse outputs the contents of more than one interval of a
file onto an HTTP data stream, in multipart/byteranges format.'>
    <category: 'Web-File Server'>

    getBoundary [
	<category: 'caching'>
	^'------%1-!-GST-!-%2' % 
		{Time secondClock.
		Time millisecondClock}
    ]

    mimeType [
	"Cache the MIME type as computed by the FileResponse implementation"

	<category: 'caching'>
	mimeType isNil ifTrue: [mimeType := super mimeType].
	^mimeType
    ]

    sendBody [
	<category: 'response'>
	range do: 
		[:each | 
		self
		    << '--';
		    << boundary;
		    nl.
		self
		    << 'Content-type: ';
		    << self mimeType;
		    nl.
		each
		    sendStandardHeadersOn: self;
		    nl.
		self sendBody: each].
	self
	    << '--';
	    << boundary;
	    << '--';
	    nl
    ]

    sendMimeType [
	<category: 'response'>
	boundary := self getBoundary.
	self
	    << 'Content-type: multipart/byteranges; boundary=';
	    << boundary;
	    nl
    ]

    contentLength [
	<category: 'response'>
	^nil
    ]
]



Object subclass: RangeSpecification [
    
    <category: 'Web-File Server'>
    <comment: '
Subclasses of RangeSpecification contain information on the data requested
in a Range HTTP request header.'>

    RangeSpecification class >> on: aString [
	"Parse the `Range' header field, answer an instance of a subclass of
	 RangeSpecification. From RFC 2068 (HTTP 1.1) -- 1# means comma-separated
	 list with at least one element:
	 byte-ranges-specifier = bytes-unit '=' byte-range-set
	 byte-range-set  = 1#( byte-range-spec | suffix-byte-range-spec )
	 byte-range-spec = first-byte-pos '-' [last-byte-pos]
	 first-byte-pos  = 1*DIGIT
	 last-byte-pos   = 1*DIGIT
	 suffix-byte-range-spec = '-' suffix-length
	 suffix-length = 1*DIGIT'
	 "

	<category: 'parsing'>
	| stream partial current n first which ch |
	stream := ReadStream on: aString.
	partial := nil.
	which := #first.

	"Read the unit"
	(stream upToAll: 'bytes=') isEmpty ifFalse: [^nil].
	stream atEnd ifTrue: [^nil].
	
	[n := nil.
	
	[ch := stream atEnd 
		    ifTrue: [$,	"Fake an empty entry at end"]
		    ifFalse: [stream next].
	ch isDigit] 
		whileTrue: 
		    [n := n isNil ifTrue: [ch digitValue] ifFalse: [n * 10 + ch digitValue]].
	ch == $- 
	    ifTrue: 
		["Check for invalid range specifications"

		which == #last ifTrue: [^nil].
		which := #last.
		first := n].
	ch == $, 
	    ifTrue: 
		["Check for invalid range specifications"

		which == #first ifTrue: [^nil].
		first > n ifTrue: [^nil].
		n = -1 & (first = -1) ifTrue: [^nil].
		which := #first.
		current := SingleRangeSpecification new.
		current
		    first: first;
		    last: n.
		partial := partial isNil ifTrue: [current] ifFalse: [partial , current].
		stream atEnd ifTrue: [^partial]]] 
		repeat
    ]

    , anotherRange [
	<category: 'overridden'>
	self subclassResponsibility
    ]

    do: aBlock [
	<category: 'overridden'>
	self subclassResponsibility
    ]

    fileSize: size [
	<category: 'overridden'>
	self subclassResponsibility
    ]

    sendStandardHeadersOn: aStream [
	<category: 'overridden'>
	
    ]

    printOn: aStream [
	<category: 'printing'>
	self do: [:each | each sendStandardHeadersOn: aStream]
    ]
]



RangeSpecification subclass: SingleRangeSpecification [
    | first last size |
    
    <category: 'Web-File Server'>
    <comment: '
A SingleRangeSpecification contains information that will result in a
Content-Range HTTP header or multipart/byteranges subheader.'>

    first [
	<category: 'accessing'>
	^first
    ]

    last [
	<category: 'accessing'>
	^last
    ]

    first: anInteger [
	<category: 'accessing'>
	first := anInteger
    ]

    last: anInteger [
	<category: 'accessing'>
	last := anInteger
    ]

    , anotherRange [
	<category: 'overridden'>
	^(MultiRangeSpecification with: self)
	    , anotherRange;
	    yourself
    ]

    do: aBlock [
	<category: 'overridden'>
	aBlock value: self
    ]

    fileSize: fSize [
	<category: 'overridden'>
	size := fSize.

	"-500: first = nil, last = 500"
	first isNil 
	    ifTrue: 
		[first := last + size - 1.
		last := size - 1].

	"9500-: first = 9500, last = nil"
	last isNil ifTrue: [last := size - 1]
    ]

    sendStandardHeadersOn: aStream [
	<category: 'overridden'>
	aStream << 'Content-range: bytes ' << first << $- << last << $/ << size.
	aStream nl
    ]

    size [
	<category: 'overridden'>
	^1
    ]
]



RangeSpecification subclass: MultiRangeSpecification [
    | subranges |
    
    <category: 'Web-File Server'>
    <comment: '
A MultiRangeSpecification contains information on a complex Range request
header, that will result in a multipart/byteranges (MultiRangeResponse)
response.'>

    MultiRangeSpecification class >> with: aRange [
	<category: 'instance creation'>
	^(self new initialize)
	    , aRange;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	subranges := OrderedCollection new
    ]

    , anotherRange [
	<category: 'overridden'>
	anotherRange do: [:each | subranges add: each].
	^self
    ]

    do: aBlock [
	<category: 'overridden'>
	subranges do: aBlock
    ]

    fileSize: fSize [
	<category: 'overridden'>
	self do: [:each | each fileSize: fSize]
    ]

    sendStandardHeadersOn: aStream [
	<category: 'overridden'>
	
    ]

    size [
	<category: 'overridden'>
	^subranges size
    ]
]



Servlet subclass: FileWebServer [
    | initialDirectory uploadAuthorizer |
    
    <comment: '
A FileWebServer transforms incoming requests into appropriate FileResponses
and DirectoryResponses.'>
    <category: 'Web-File Server'>

    FileWebServer class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    FileWebServer class >> named: aString directory: dirString [
	<category: 'instance creation'>
	^(self new)
	    name: aString;
	    directory: dirString;
	    yourself
    ]

    FileWebServer class >> new [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    yourself
    ]

    fileResponse: file request: aRequest [
	<category: 'interaction'>
	| range |
	range := aRequest at: #RANGE ifAbsent: [nil].
	range isNil ifTrue: [^FileResponse file: file].
	range := RangeSpecification on: range.
	range size = 1 ifTrue: [^RangeResponse file: file range: range].
	^MultiRangeResponse file: file range: range
    ]

    directoryResponse: aDirectory request: aRequest [
	<category: 'responding'>
	| listable |
	listable := aDirectory isReadable.
	(aRequest action sameAs: 'POST') 
	    ifTrue: 
		[^listable 
		    ifTrue: [self uploadResponse: aDirectory request: aRequest]
		    ifFalse: [ErrorResponse acceptableMethods: #('HEAD' 'GET')]].
	^(self indexResponse: aDirectory request: aRequest) ifNil: 
		[listable 
		    ifTrue: [DirectoryResponse file: aDirectory]
		    ifFalse: [ErrorResponse forbidden]]
    ]

    indexResponse: aDirectory request: aRequest [
	<category: 'interaction'>
	self indexFileNames do: 
		[:each | 
		| indexFile |
		indexFile := aDirectory / each.
		indexFile isReadable 
		    ifTrue: [^self fileResponse: indexFile request: aRequest]].
	^nil
    ]

    respondTo: aRequest [
	<category: 'interaction'>
	| response |
	response := (#('HEAD' 'GET' 'POST') includes: aRequest action asUppercase) 
		    ifTrue: [self responseFor: aRequest]
		    ifFalse: [ErrorResponse acceptableMethods: #('HEAD' 'GET' 'POST')].
	response isNil ifFalse: [response respondTo: aRequest]
    ]

    responseFor: aRequest [
	<category: 'interaction'>
	| file path |
	path := aRequest location.
	file := initialDirectory.
	path 
	    from: self depth
	    to: path size
	    do: 
		[:each | 
		(self isValidName: each) ifFalse: [^ErrorResponse notFound].
		file isDirectory ifFalse: [^ErrorResponse notFound].
		file := file directoryAt: each.
		file isReadable 
		    ifFalse: 
			[^file isDirectory 
			    ifTrue: [ErrorResponse notFound]
			    ifFalse: [ErrorResponse forbidden]]].
	file isDirectory ifTrue: [^self directoryResponse: file request: aRequest].
	^self fileResponse: file request: aRequest
    ]

    directory: aDirectory [
	<category: 'accessing'>
	initialDirectory := File name: aDirectory
    ]

    indexFileNames [
	<category: 'accessing'>
	^#('index.html' 'index.htm' 'default.html' 'default.htm')
    ]

    initialize [
	<category: 'initialize-release'>
	initialDirectory := Directory working.
	uploadAuthorizer := WebAuthorizer new.
	name := 'File'
    ]

    isValidName: aString [
	"Don't allow people to put strange characters or .. in a file directory.
	 If we allowed .., then someone could grab our password file."

	<category: 'testing'>
	^(aString indexOfSubCollection: '..') = 0 and: 
		[aString 
		    conform: [:each | each asInteger >= 32 and: [each asInteger < 127]]]
    ]

    uploadAuthorizer [
	<category: 'accessing'>
	^uploadAuthorizer
    ]

    uploadAuthorizer: aWebAuthorizer [
	<category: 'accessing'>
	uploadAuthorizer := aWebAuthorizer
    ]

    uploadLoginID: aLoginID password: aPassword [
	<category: 'accessing'>
	uploadAuthorizer := WebAuthorizer loginID: aLoginID password: aPassword
    ]

    uploadResponse: aDirectory request: aRequest [
	<category: 'responding'>
	^uploadAuthorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [UploadResponse file: aDirectory]
    ]
]



CharacterArray extend [

    precompileSearch [
	"Compile the receiver into some object that answers
	 #searchIn:startingAt: and #possibleMatchSearchIn:startingAt:"

	<category: 'Boyer-Moore search'>
	| encoding size |
	size := self size.
	encoding := size > 254 
		    ifTrue: [Array new: 513 withAll: size]
		    ifFalse: [ByteArray new: 513 withAll: size].

	"To find the last char of self, moving forwards"
	1 to: size do: [:i | encoding at: 2 + (self valueAt: i) put: size - i].

	"To find the first char of self, moving backwards"
	size to: 1
	    by: -1
	    do: [:i | encoding at: 258 + (self valueAt: i) put: i - 1].
	^Array with: self with: encoding
    ]

    boyerMooreSearch: string encoding: encoding startingAt: minPos [
	<category: 'Boyer-Moore search'>
	| idx searchSize size ofs |
	searchSize := encoding at: 1.
	idx := minPos + searchSize - 1.
	size := self size.
	[idx < size] whileTrue: 
		[ofs := encoding at: 2 + (self valueAt: idx).
		ofs = 0 
		    ifTrue: 
			["Look behind for the full searched string"

			ofs := searchSize.
			
			[(ofs := ofs - 1) == 0 ifTrue: [^idx - searchSize + 1].
			(string at: ofs) == (self at: idx - searchSize + ofs)] 
				whileTrue.

			"Sorry not found... yet"
			ofs := 1].
		idx := idx + ofs].
	^0
    ]

    boyerMoorePossibleMatchSearch: encoding startingAt: minPos [
	<category: 'Boyer-Moore search'>
	| idx searchSize ofs result |
	searchSize := encoding at: 1.
	idx := self size.
	result := 0.
	[idx > minPos] whileTrue: 
		[ofs := encoding at: 258 + (self valueAt: idx).
		ofs = 0 
		    ifTrue: 
			[result := idx.
			ofs := 1].
		idx := idx - ofs].
	^result
    ]

]



ArrayedCollection extend [

    searchIn: aString startingAt: minPos [
	"Same as `aString indexOfSubCollection: ... ifAbsent: [ 0 ]', where
	 the searched string is the string that was precompiled in the
	 receiver.	Optimized for minPos < self size - minPos (otherwise, you're
	 likely to win if you first use #possibleMatchSearchIn:startingAt:)"

	<category: 'Boyer-Moore search'>
	^aString 
	    boyerMooreSearch: (self at: 1)
	    encoding: (self at: 2)
	    startingAt: minPos
    ]

    possibleMatchSearchIn: aString startingAt: minPos [
	"Search for the first possible match starting from the minPos-th
	 item in the string that was precompiled in the receiver.  This
	 is not necessarily the first occurrence of the first character
	 (a later occurrence, or none at all, could be returned if the
	 algorithm discovers that the first cannot be part of a match).
	 Optimized for minPos > self size - minPos (otherwise, you're
	 likely to win if you use #searchIn:startingAt: directly)"

	<category: 'Boyer-Moore search'>
	^aString boyerMoorePossibleMatchSearch: (self at: 2) startingAt: minPos
    ]

]



WebServer class extend [

    publishMyHomeDir [
	"WebServer myHomeDirWiki"

	<category: 'examples'>
	| handler name dir |
	self terminateServer: 8080.
	name := '~' , (File stripPathFrom: Directory home).
	dir := Directory home , '/pub-www'.

	"Add a file server on a particular directory."
	handler := (self initializeServer: 8080) handler.
	handler addComponent: (FileWebServer named: name directory: dir)
    ]

]

