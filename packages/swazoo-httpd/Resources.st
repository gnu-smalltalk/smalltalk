"======================================================================
|
|   Swazoo 2.1 HTTP response serving
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SwazooCacheControl [
    | request cacheTarget etag lastModified |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    addNotModifedHeaders: aResponse [
	"RFC2616 10.3.5
	 If the conditional GET used a strong cache validator (see section 13.3.3), the response SHOULD NOT include other entity-headers. ... this prevents inconsistencies between cached entity-bodies and updated headers."

	<category: 'operations'>
	self isRequestStrongValidator 
	    ifTrue: [aResponse headers addField: (HTTPETagField new entityTag: self etag)]
	    ifFalse: [self basicAddResponseHeaders: aResponse].
	^aResponse
    ]

    addResponseHeaders: aResponse [
	"Add response headers to the response.
	 We MUST differentiate between 200/302 responses"

	<category: 'operations'>
	^aResponse isNotModified 
	    ifTrue: [self addNotModifedHeaders: aResponse]
	    ifFalse: [self basicAddResponseHeaders: aResponse]
    ]

    basicAddResponseHeaders: aResponse [
	"RFC 2616 13.3.4
	 HTTP/1.1 origin servers:
	 - SHOULD send an entity tag validator unless it is not feasible to generate one.
	 - SHOULD send a Last-Modified value"

	<category: 'operations'>
	aResponse headers addField: (HTTPETagField new entityTag: self etag).
	aResponse headers 
	    addField: (HTTPLastModifiedField new timestamp: self lastModified).
	^aResponse
    ]

    cacheTarget [
	<category: 'accessing'>
	^cacheTarget
    ]

    etag [
	<category: 'accessing'>
	etag isNil ifTrue: [etag := self generateETag].
	^etag
    ]

    etag: aString [
	<category: 'accessing'>
	etag := aString
    ]

    generateETag [
	<category: 'operations'>
	^self cacheTarget etag
    ]

    generateLastModified [
	<category: 'operations'>
	^self cacheTarget lastModified
    ]

    isIfModifiedSince [
	"Answers true if either
	 - the request does not included the header
	 -or there is not a match"

	<category: 'testing'>
	| ifModifiedSince |
	ifModifiedSince := request headers fieldOfClass: HTTPIfModifiedSinceField
		    ifNone: [nil].
	^ifModifiedSince isNil or: [self lastModified > ifModifiedSince date]
    ]

    isIfNoneMatch [
	"Answers true if either
	 - the request does not included the header
	 -or there is not a match"

	<category: 'testing'>
	| field |
	field := request headers fieldOfClass: HTTPIfNoneMatchField ifNone: [nil].
	^field isNil or: [(field entityTags includes: self etag) not]
    ]

    isNotModified [
	"Compare the cacheTarget with the request headers and answer if the client's version is not modified.
	 Takes into account http version, and uses best practices defined by HTTP spec"

	<category: 'testing'>
	^self isIfNoneMatch not or: [self isIfModifiedSince not]
    ]

    isRequestStrongValidator [
	<category: 'testing'>
	| field |
	field := request headers fieldOfClass: HTTPIfNoneMatchField ifNone: [nil].
	^field notNil and: [field entityTags isEmpty not]
    ]

    lastModified [
	<category: 'testing'>
	lastModified isNil ifTrue: [lastModified := self generateLastModified].
	^lastModified
    ]

    lastModified: aRFC1123TimeStampString [
	<category: 'testing'>
	lastModified := aRFC1123TimeStampString
    ]

    request: aHTTPGet cacheTarget: anObject [
	<category: 'accessing'>
	request := aHTTPGet.
	cacheTarget := anObject
    ]
]



Object subclass: SwazooCompiler [
    | accessor |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    SwazooCompiler class >> evaluate: aString [
	<category: 'evaluation'>
	^SpEnvironment 
	    evaluate: aString
	    receiver: SwazooCompiler
	    in: self class environment
    ]

    SwazooCompiler class >> evaluate: aString receiver: anObject [
	<category: 'evaluation'>
	^SpEnvironment 
	    evaluate: aString
	    receiver: anObject
	    in: self class environment
    ]
]



SwazooResource subclass: FileMappingResource [
    | directoryIndex filePath |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    FileMappingResource class >> uriPattern: aString filePath: aFilePath [
	<category: 'instance creation'>
	^(self uriPattern: aString) filePath: aFilePath
    ]

    FileMappingResource class >> uriPattern: aString filePath: aFilePath directoryIndex: anotherString [
	<category: 'instance creation'>
	^(self uriPattern: aString)
	    filePath: aFilePath;
	    directoryIndex: anotherString
    ]

    answerTo: aRequest [
	<category: 'serving'>
	(self checkExistence: aRequest) ifFalse: [^nil].
	(self checkURI: aRequest) 
	    ifFalse: 
		[| response |
		response := HTTPResponse movedPermanently.
		response headers 
		    addField: (HTTPLocationField new uriString: aRequest uri identifier , '/').
		^response].
	^self file: (self fileFor: aRequest) answerTo: aRequest
    ]

    checkExistence: aRequest [
	<category: 'private'>
	(self rootFileFor: aRequest) exists ifFalse: [^false].
	^(self fileFor: aRequest) exists
    ]

    checkURI: aRequest [
	<category: 'private'>
	| needsFinalSlash |
	needsFinalSlash := (self rootFileFor: aRequest) isDirectory 
		    and: [aRequest uri isDirectory not].
	^needsFinalSlash not
    ]

    directoryIndex [
	<category: 'accessing'>
	^directoryIndex
    ]

    directoryIndex: aString [
	<category: 'accessing'>
	directoryIndex := aString
    ]

    file: aFilename answerTo: aRequest [
	<category: 'private'>
	^self subclassResponsibility
    ]

    fileDirectory [
	<category: 'private'>
	^SpFilename named: self filePath
    ]

    fileFor: aRequest [
	<category: 'private'>
	| fn |
	fn := self rootFileFor: aRequest.
	fn isDirectory ifTrue: [fn := fn construct: self directoryIndex].
	^fn
    ]

    filePath [
	<category: 'accessing'>
	^filePath
    ]

    filePath: aString [
	<category: 'accessing'>
	filePath := aString
    ]

    initialize [
	<category: 'private-initialize'>
	super initialize.
	self directoryIndex: 'index.html'
    ]

    rootFileFor: aRequest [
	<category: 'private'>
	^aRequest tailPath inject: self fileDirectory
	    into: 
		[:subPath :each | 
		(#('.' '..') includes: (HTTPString trimBlanksFrom: each)) 
		    ifTrue: [subPath]
		    ifFalse: [subPath construct: each]]
    ]
]



FileMappingResource subclass: FileResource [
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    ContentTypes := nil.

    FileResource class >> initialize [
	"self initialize"

	<category: 'class initialization'>
	ContentTypes := (Dictionary new)
		    add: '.txt' -> 'text/plain';
		    add: '.html' -> 'text/html';
		    add: '.htm' -> 'text/html';
		    add: '.css' -> 'text/css';
		    add: '.png' -> 'image/png';
		    add: '.gif' -> 'image/gif';
		    add: '.jpg' -> 'image/jpeg';
		    add: '.m3u' -> 'audio/mpegurl';
		    add: '.ico' -> 'image/x-icon';
		    add: '.pdf' -> 'application/pdf';
		    yourself
    ]

    contentTypeFor: aString [
	<category: 'private'>
	^ContentTypes at: aString ifAbsent: ['application/octet-stream']
    ]

    file: aFilename answerTo: aRequest [
	<category: 'private'>
	| cacheControl response |
	cacheControl := SwazooCacheControl new request: aRequest
		    cacheTarget: aFilename.
	response := cacheControl isNotModified 
		    ifTrue: [HTTPResponse notModified]
		    ifFalse: 
			[FileResponse ok entity: ((MimeObject new)
				    value: aFilename;
				    contentType: (self contentTypeFor: aFilename extension))].
	cacheControl addResponseHeaders: response.
	^response
    ]
]



FileResource subclass: HomeResource [
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    answerTo: aRequest [
	<category: 'accessing'>
	aRequest tailPath isEmpty ifTrue: [^nil].
	(self validateHomePath: aRequest tailPath first) ifFalse: [^nil].
	^super answerTo: aRequest
    ]

    rootFileFor: aRequest [
	<category: 'private'>
	| homeKey file |
	homeKey := aRequest tailPath first copyFrom: 2
		    to: aRequest tailPath first size.
	file := (self fileDirectory construct: homeKey) construct: 'html'.
	(aRequest tailPath copyFrom: 2 to: aRequest tailPath size) 
	    do: [:each | each = '..' ifFalse: [file := file construct: each]].
	^file
    ]

    validateHomePath: aString [
	<category: 'private'>
	^aString first = $~
    ]
]



SwazooResource subclass: HelloWorldResource [
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    answerTo: aRequest [
	<category: 'serving'>
	| response |
	response := HTTPResponse ok.
	response
	    contentType: 'text/html';
	    entity: '<html><head><title>Hello World</title></head><body>Hello World!</body></html>'.
	^response
    ]
]



SwazooResource subclass: RedirectionResource [
    | targetUri |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    RedirectionResource class >> uriPattern: aString targetUri: bString [
	<category: 'instance creation'>
	^(self uriPattern: aString) targetUri: bString
    ]

    answerTo: aRequest [
	<category: 'serving'>
	| answer |
	answer := HTTPResponse movedPermanently.
	answer headers addField: (HTTPLocationField new uriString: self targetUri).
	^answer
    ]

    targetUri [
	<category: 'private-initialize'>
	^targetUri
    ]

    targetUri: aString [
	<category: 'private-initialize'>
	targetUri := aString
    ]
]



Eval [
    FileResource initialize
]
