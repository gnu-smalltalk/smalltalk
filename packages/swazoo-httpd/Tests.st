"======================================================================
|
|   Swazoo 2.1 testcases
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2008 the Swazoo team.
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


TestCase subclass: CompositeResourceTest [
    | composite |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    sampleInSite [
	<category: 'testing'>
	| site |
	site := Site new.
	site 
	    host: 'swazoo.org'
	    ip: '127.0.0.1'
	    port: 8200.
	site addResource: composite
    ]

    setUp [
	<category: 'running'>
	composite := CompositeResource uriPattern: '/'
    ]

    testAddResource [
	<category: 'testing'>
	| child |
	composite 
	    addResource: (child := HelloWorldResource uriPattern: 'hello.html').
	self assert: composite children size = 1.
	self assert: composite children first == child.
	self assert: child parent == composite
    ]

    testAddResources [
	<category: 'testing'>
	| child1 child2 |
	child1 := HelloWorldResource uriPattern: 'hello1.html'.
	child2 := HelloWorldResource uriPattern: 'hello2.html'.
	composite addResources: (Array with: child1 with: child2).
	self assert: composite children size = 2.
	composite children do: 
		[:each | 
		self assert: (composite children includes: each).
		self assert: each parent == composite]
    ]

    testCurrentUrl [
	<category: 'testing'>
	| child leaf |
	self sampleInSite.
	self assert: composite currentUrl = 'http://swazoo.org:8200/'.
	composite addResource: (child := CompositeResource uriPattern: 'foo').
	self assert: child currentUrl = 'http://swazoo.org:8200/foo/'.
	child addResource: (leaf := HelloWorldResource uriPattern: 'hi.html').
	self assert: leaf currentUrl = 'http://swazoo.org:8200/foo/hi.html'
    ]

    testEmptyURIPatternInvalid [
	<category: 'testing'>
	composite uriPattern: ''.
	self deny: composite isValidlyConfigured
    ]

    testNilURIPatternDoesNothing [
	<category: 'testing'>
	| pattern |
	pattern := composite uriPattern.
	composite uriPattern: nil.
	self assert: composite uriPattern = pattern
    ]

    testValidlyConfigured [
	<category: 'testing'>
	self assert: composite isValidlyConfigured
    ]
]



TestCase subclass: FileResourceTest [
    | resource |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	| directory firstFile ws |
	directory := SpFilename named: 'fResTest'.
	directory exists ifFalse: [directory makeDirectory].
	firstFile := (SpFilename named: 'fResTest') construct: 'abc.html'.
	ws := firstFile writeStream.
	[ws nextPutAll: 'hello'] ensure: [ws close].
	resource := FileResource uriPattern: 'foo' filePath: 'fResTest'
    ]

    tearDown [
	<category: 'running'>
	((SpFilename named: 'fResTest') construct: 'abc.html') delete.
	(SpFilename named: 'fResTest') delete
    ]

    testContentType [
	<category: 'testing'>
	self assert: (resource contentTypeFor: '.txt') = 'text/plain'.
	self assert: (resource contentTypeFor: '.html') = 'text/html'
    ]

    testDirectoryIndex [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/'.
	resource directoryIndex: 'abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'
    ]

    testETag [
	"Filename etags do not have the leading and trailing double quotes.  Header fields add the quotes as necessary"

	<category: 'testing'>
	| request response etag |
	request := HTTPGet request: 'foo/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self 
	    assert: (etag := (response headers fieldOfClass: HTTPETagField) entityTag) 
		    notNil.
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new addEntityTag: etag).
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 304.
	self 
	    assert: (response headers fieldOfClass: HTTPETagField) entityTag = etag.
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new valueFrom: '"wrong"').
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self 
	    assert: (response headers fieldOfClass: HTTPETagField) entityTag = etag
    ]

    testExistantFile [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'
    ]

    testNonexistantFile [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/notThere.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testRedirection [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo'.
	resource directoryIndex: 'abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 301.
	self assert: (response headers fieldNamed: 'Location') uri asString 
		    = 'http://foo/'.
	self assert: (response headers fieldNamed: 'Location') uri host = 'foo'
    ]

    testRelativeFile [
	"it doesn't work anyway!!
	 | request response |
	 request := HTTPGet request: 'foo/../', resource fileDirectory tail, '/abc.html'.
	 response := URIResolution resolveRequest: request startingAt: resource.
	 self assert: response isNil"

	<category: 'testing'>
	
    ]

    testSafeConstruct [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/../abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	request := HTTPGet request: 'foo/.. /./abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200
    ]
]



TestCase subclass: HTTPRequestTest [
    | request |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    basicGet [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.1';
	    nextPutLine: 'Host: foo.com';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    basicGetHTTP10 [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.0';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    basicGetHTTP10Keepalive [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.0';
	    nextPutLine: 'Connection: Keep-Alive';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    basicHead [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'HEAD / HTTP/1.1';
	    nextPutLine: 'Host: foo.com';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    crlfOn: aStream [
	<category: 'private'>
	aStream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    fileContents [
	"HTTPRequestTest new fileContents"

	<category: 'requests-posts'>
	| stream |
	stream := SwazooStream on: String new.
	stream
	    nextPutLine: 'BEGIN:VCALENDAR';
	    nextPutLine: 'PRODID:-//Squeak-iCalendar//-';
	    nextPutLine: 'VERSION:2.0';
	    nextPutLine: 'X-WR-CALNAME:test';
	    nextPutLine: 'METHOD:PUBLISH';
	    nextPutLine: 'BEGIN:VEVENT';
	    nextPutLine: 'UID:an event with a start date and not date and time';
	    nextPutLine: 'CATEGORIES:category1,category2';
	    nextPutLine: 'CREATED:20050501T110231Z';
	    nextPutLine: 'SEQUENCE:0';
	    nextPutLine: 'SUMMARY:aTitle';
	    nextPutLine: 'PRIORITY:5';
	    nextPutLine: 'DTSTART;VALUE=DATE:20050425';
	    nextPutLine: 'END:VEVENT';
	    nextPutLine: 'END:VCALENDAR'.
	^stream writeBuffer contents asString
    ]

    fullGet [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET /aaa/bbb/ccc.html?foo=bar&baz=quux HTTP/1.1';
	    nextPutLine: 'Connection: Keep-Alive';
	    nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
	    nextPutLine: 'Host: foo.com:8888';
	    nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    getMultiValueHeader [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET /aaa/bbb/ccc.html?foo=bar&baz=quux HTTP/1.1';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= --boundary';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    portedGet [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.1';
	    nextPutLine: 'Host: foo.com:8888';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    postDashes [
	<category: 'requests-posts'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 149';
	    crlf;
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: '----';
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="field2"';
	    crlf;
	    nextPutLine: '- --';
	    nextPutLine: '--boundary--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    postEmpty [
	"post entity with empty value"

	<category: 'requests-posts'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 75';
	    crlf;
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: '';
	    nextPutLine: '--boundary--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    postFile [
	<category: 'requests-posts'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Connection: Keep-Alive';
	    nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= -----------------20752836116568320241700153999';
	    nextPutLine: 'Content-Length: ' 
			, (527 + self fileContents size) printString;
	    crlf;
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: 'main';
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="field2"';
	    crlf;
	    crlf;
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="field7"; filename="event.ical"';
	    nextPutLine: 'Content-Type: application/octet-stream';
	    crlf;
	    nextPutAll: self fileContents;
	    crlf;
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="attach"';
	    crlf;
	    nextPutLine: 'Attach';
	    nextPutLine: '-------------------20752836116568320241700153999--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    postPreambleEpilogue [
	<category: 'requests-posts'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 146';
	    crlf;
	    nextPutLine: 'This is a multi-part message in MIME format';
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: 'main';
	    nextPutLine: '--boundary--';
	    nextPutLine: 'This is the epilogue'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    postSimple [
	<category: 'requests-posts'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 79';
	    crlf;
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: 'main';
	    nextPutLine: '--boundary--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    postUrlEncoded [
	<category: 'requests-posts'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: application/x-www-form-urlencoded';
	    nextPutLine: 'Content-Length: 36';
	    crlf;
	    nextPutAll: 'home=Cosby+one&favorite+flavor=flies'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBuffer contents)
    ]

    test10ConnectionClose [
	<category: 'testing-other'>
	request := self basicGetHTTP10.
	self assert: request wantsConnectionClose
    ]

    test10KeepAliveConnectionClose [
	<category: 'testing-other'>
	request := self basicGetHTTP10Keepalive.
	self deny: request wantsConnectionClose
    ]

    testBasicGet [
	<category: 'testing-gets'>
	request := self basicGet.
	self assert: request isGet.
	self assert: request isHttp11.
	self deny: request isHead.
	self deny: request isPost.
	self deny: request isPut
    ]

    testBasicGetHTTP10 [
	<category: 'testing-gets'>
	request := self basicGetHTTP10.
	self assert: request isGet.
	self assert: request isHttp10.
	self deny: request isHead.
	self deny: request isPost.
	self deny: request isPut
    ]

    testBasicGetHost [
	<category: 'testing-gets'>
	request := self basicGet.
	self assert: request host = 'foo.com'
    ]

    testBasicGetPort [
	<category: 'testing-gets'>
	request := self basicGet.
	self assert: request port = 80
    ]

    testBasicHead [
	<category: 'testing-gets'>
	request := self basicHead.
	self assert: request isHead.
	self deny: request isGet.
	self deny: request isPost.
	self deny: request isPut
    ]

    testConnection [
	<category: 'testing-other'>
	request := self fullGet.
	self assert: request connection = 'Keep-Alive'
    ]

    testGetMultiValueHeader [
	<category: 'testing-gets'>
	| header |
	request := self getMultiValueHeader.
	header := request headerAt: 'Content-Type' ifAbsent: [nil].
	self assert: header mediaType = 'multipart/form-data'.
	self assert: (header transferCodings at: 'boundary') = '--boundary'.
	self 
	    assert: header valuesAsString = 'multipart/form-data boundary=--boundary'

	"'Content-Type: multipart/form-data; boundary= --boundary';"
    ]

    testHeaderAtIfPresent [
	<category: 'testing-other'>
	request := self basicGet.
	self assert: (request headers 
		    fieldOfClass: HTTPIfRangeField
		    ifPresent: [:header | header == (request headers fieldOfClass: HTTPIfRangeField)]
		    ifAbsent: [true]).
	self assert: (request headers 
		    fieldOfClass: HTTPHostField
		    ifPresent: [:header | header == (request headers fieldOfClass: HTTPHostField)]
		    ifAbsent: [false])
    ]

    testMissingContentType [
	<category: 'testing-other'>
	| requestStream result |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST /foobar HTTP/1.0';
	    nextPutLine: 'Host: foo.com';
	    nextPutLine: 'Content-Length: 12';
	    crlf;
	    nextPutLine: 'Hello, World'.
	"nextPutLine: 'Content-Type: text/plain'. <-- this is missing!! - and should be for this test"
	result := SpExceptionContext 
		    for: 
			[(HTTPRequest 
			    readFrom: (SwazooStream on: requestStream writeBuffer contents)) 
				ensureFullRead	"because of defered post data parsing"]
		    on: SpError
		    do: [:ex | ex].
	self assert: result class == SwazooHTTPPostError.
	^self
    ]

    testNo11ConnectionClose [
	<category: 'testing-other'>
	request := self basicGet.
	self deny: request wantsConnectionClose
    ]

    testNoEqualsQueries [
	"The last assert here used to check that 'request queryAt: 'WSDL'' is nil, but a test for an empty string is more consistent with query argument formats."

	<category: 'testing-other'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET /test/typed.asmx?WSDL HTTP/1.1';
	    nextPutLine: 'Host: foo.com:8888';
	    crlf.
	request := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBuffer contents).
	self assert: (request includesQuery: 'WSDL').
	self assert: (request queryAt: 'WSDL') isEmpty
    ]

    testPortedGetPort [
	<category: 'testing-gets'>
	request := self portedGet.
	self assert: request port = 8888
    ]

    testPost10Simple [
	"just one entity"

	<category: 'testing-posts'>
	| post |
	post := self postSimple.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'
    ]

    testPost2Empty [
	"post entity with empty value"

	<category: 'testing-posts'>
	| post |
	post := self postEmpty.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = ''
    ]

    testPost3Dashes [
	"some ---- inside post data"

	<category: 'testing-posts'>
	| post |
	post := self postDashes.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = '----'.
	self assert: (post postDataStringAt: 'field2') = '- --'
    ]

    testPost40File [
	<category: 'testing-posts'>
	| post |
	post := self postFile.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'.
	self assert: (post postDataStringAt: 'field2') = ''.
	self assert: (post postDataAt: 'field7') filename = 'event.ical'.
	self 
	    assert: ((post postDataStringAt: 'field7') readStream upTo: Character cr) 
		    = 'BEGIN:VCALENDAR'.
	self assert: (post postDataStringAt: 'field7') = self fileContents.
	self assert: (post postDataStringAt: 'attach') = 'Attach'
    ]

    testPost41FileStreamed [
	<category: 'testing-posts'>
	| post stream |
	post := self postFile.
	stream := WriteStream on: ByteArray new.
	post postDataAt: 'field7' streamTo: stream.
	self assert: (post isPostDataStreamedAt: 'field7').
	self deny: post postData isParsed.	"post data read from socket defered"
	self assert: (post postDataStringAt: 'id5273') = 'main'.
	self assert: post postData isParsed.	"first access to post data trigger full read and parse"
	self assert: (post postDataAt: 'field7') filename = 'event.ical'.
	self assert: (stream contents asString readStream upTo: Character cr) 
		    = 'BEGIN:VCALENDAR'.
	self assert: stream contents asString = self fileContents.
	self assert: (post postDataStringAt: 'attach') = 'Attach'
    ]

    testPost5UrlEncoded [
	"just one entity"

	<category: 'testing-posts'>
	| post |
	post := self postUrlEncoded.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'home') = 'Cosby one'.
	self assert: (post postDataStringAt: 'favorite flavor') = 'flies'
    ]

    testPostPreambleEpilogue [
	"mime preamble before first part and epilogue at the end. See #postPreambleEpilogue"

	<category: 'testing-posts'>
	| post |
	post := self postPreambleEpilogue.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'
    ]

    testPostRawEntity [
	<category: 'testing-posts'>
	| requestStream post |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST /foobar HTTP/1.0';
	    nextPutLine: 'Host: foo.com';
	    nextPutLine: 'Content-Type: text/plain';
	    nextPutLine: 'Content-Length: 12';
	    crlf;
	    nextPutLine: 'Hello, World'.
	post := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBuffer contents).
	self assert: post isPostDataEmpty.
	self assert: post entityBody = 'Hello, World'
    ]

    testPostReadToBoundary [
	"for MIME multipart parser in HTTPPost"

	<category: 'testing-posts'>
	| boundary stream |
	boundary := '--------23453443421'.
	"just boundary"
	stream := SwazooStream new 
		    readBuffer: ('--' , boundary) asByteArray readStream.
	self assert: nil 
		    = (HTTPPost new nextFrom: stream boundary: boundary asByteArray).
	"text before boundary, just first chr returned"
	stream := SwazooStream new 
		    readBuffer: ('text' , '--' , boundary) asByteArray readStream.
	self assert: 't' 
		    = (HTTPPost new nextFrom: stream boundary: boundary asByteArray) asString.
	"part of boundary"	"NOT YET IMPLEMENTED!!!!!!"
	"stream := SwazooStream new readBuffer: ('---', '--', boundary) asByteArray readStream.
	 self assert: '---' = (HTTPPost new nextFrom: stream boundary: boundary asByteArray) asString."
	"text after boundary"
	stream := SwazooStream new 
		    readBuffer: ('--' , boundary , 'sfsdsg') asByteArray readStream.
	self assert: nil 
		    = (HTTPPost new nextFrom: stream boundary: boundary asByteArray).
	"mixed with one boundary chr"
	stream := SwazooStream new readBuffer: '-1-' asByteArray readStream.
	self assert: '-1' 
		    = (HTTPPost new nextFrom: stream boundary: boundary asByteArray) asString
    ]

    testPostUrlEncodedData [
	<category: 'testing-posts'>
	| requestStream post |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST / HTTP/1.1';
	    nextPutLine: 'Host: foo.com';
	    nextPutLine: 'Content-Type: application/x-www-form-urlencoded';
	    nextPutLine: 'Content-Length: 31';
	    crlf;
	    nextPutLine: 'address=+fs&product=&quantity=1'.
	post := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBuffer contents).
	self assert: (post postDataAt: 'address') value = ' fs'.
	self assert: (post postDataAt: 'product') value = ''.
	self assert: (post postDataAt: 'quantity') value = '1'
    ]

    testReferer [
	<category: 'testing-other'>
	request := self fullGet.
	self 
	    assert: request referer asString = 'http://www.bar.com/takeMeThere.html'
    ]

    testRequestWithCRButNoLF [
	"| requestStream result |
	 requestStream := SwazooStream on: String new.
	 requestStream
	 nextPutAll: 'GET / HTTP/1.1';
	 cr.
	 result := SpExceptionContext
	 for: [HTTPRequest readFrom: (SwazooStream on: requestStream writeBuffer contents)]
	 on: SpError
	 do: [:ex | ex].
	 self assert: result class == SwazooHTTPParseError.
	 ^self"

	<category: 'testing-other'>
	
    ]

    testUserAgent [
	<category: 'testing-other'>
	request := self fullGet.
	self 
	    assert: request userAgent = 'Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)'
    ]
]



TestCase subclass: HTTPResponseTest [
    | response |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    crlf [
	<category: 'private'>
	^String with: Character cr with: Character lf
    ]

    testInternalServerError [
	<category: 'testing'>
	| ws rs |
	response := HTTPResponse internalServerError.
	ws := SwazooStream on: String new.
	response printStatusOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = 'HTTP/1.1 500 Internal Server Error'
    ]

    testOK [
	<category: 'testing'>
	| ws rs |
	response := HTTPResponse ok.
	ws := SwazooStream on: String new.
	response printStatusOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = 'HTTP/1.1 200 OK'
    ]

    testResponseTypes [
	<category: 'testing'>
	self assert: HTTPResponse badRequest isBadRequest.
	self assert: HTTPResponse found isFound.
	self assert: HTTPResponse internalServerError isInternalServerError.
	self assert: HTTPResponse movedPermanently isMovedPermanently.
	self assert: HTTPResponse notFound isNotFound.
	self assert: HTTPResponse notImplemented isNotImplemented.
	self assert: HTTPResponse notModified isNotModified.
	self assert: HTTPResponse ok isOk.
	self assert: HTTPResponse redirectLink isRedirectLink.
	self assert: HTTPResponse seeOther isSeeOther
    ]
]



TestCase subclass: HTTPServerTest [
    | server stream |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	| socket |
	(Delay forMilliseconds: 100) wait.
	server := HTTPServer new.
	
	[server
	    ip: 'localhost';
	    port: 8123.
	server start] fork.
	(Delay forMilliseconds: 100) wait.
	"stream := (SocketAccessor newTCPclientToHost: 'localhost' port: 8123)
	 readAppendStream"
	socket := SpSocket connectToServerOnHost: 'localhost' port: 8123.
	stream := SwazooStream socket: socket
    ]

    tearDown [
	<category: 'running'>
	server stop.
	stream close.
	stream := nil.
	Delay forMilliseconds: 500
    ]

    testServing [
	<category: 'tests'>
	self assert: server isServing
    ]

    testStopServing [
	<category: 'tests'>
	server stop.
	self deny: server isServing
    ]
]



TestCase subclass: HeaderFieldTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    testCombine [
	"Entity tags must be quoted strings - RFC 2616 3.11"

	<category: 'testing'>
	| header1 header2 header3 |
	header1 := HeaderField fromLine: 'If-Match: "a"'.
	header2 := HeaderField fromLine: 'If-Match: "b","c"'.
	header3 := HeaderField fromLine: 'If-Match: "d"'.
	header1 combineWith: header2.
	self assert: header1 valuesAsString = '"a","b","c"'.
	header1 combineWith: header3.
	self assert: header1 valuesAsString = '"a","b","c","d"'
    ]

    testContentTypeMultiple [
	"HTTP/1.1 header field values can be folded onto multiple lines if the
	 continuation line begins with a space or horizontal tab. All linear
	 white space, including folding, has the same semantics as SP. A
	 recipient MAY replace any linear white space with a single SP before
	 interpreting the field value or forwarding the message downstream.
	 
	 LWS            = [CRLF] 1*( SP | HT )"

	<category: 'testing'>
	| requestStream request field |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.1';
	    nextPutLine: 'Host: 127.0.0.1';
	    nextPutLine: 'Content-Type: text/html; ';
	    nextPutLine: ' charset=iso-8859-1';
	    crlf.
	request := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBuffer contents).
	field := request headers fieldNamed: 'content-type'.
	self assert: field name = 'Content-Type'.
	self assert: field mediaType = 'text/html'.
	self assert: (field transferCodings at: 'charset') = 'iso-8859-1'
    ]

    testValues [
	"Entity tags are held internally as simple strings.  Any necessary leading and trailing double quotes are added by the header fields as needed.  Note that it is OK to have a comma in an entity tag - see the second of the group of 3 tags below."

	<category: 'testing'>
	| header |
	header := HeaderField fromLine: 'If-Match: "xyzzy" '.
	self assert: header name = 'If-Match'.
	self assert: header entityTags first = 'xyzzy'.
	header := HeaderField 
		    fromLine: 'If-Match: "xyzzy", "r2d2,xxxx", "c3piozzzz" '.
	self assert: header name = 'If-Match'.
	self assert: header entityTags first = 'xyzzy'.
	self assert: (header entityTags at: 2) = 'r2d2,xxxx'.
	self assert: header entityTags last = 'c3piozzzz'
    ]
]



TestCase subclass: HelloWorldResourceTest [
    | hello |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	hello := HelloWorldResource uriPattern: 'hello.html'
    ]

    testResponse [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'hello.html'.
	response := URIResolution resolveRequest: request startingAt: hello.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'hello.html'
    ]
]



TestCase subclass: HomeResourceTest [
    | resource |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	resource := HomeResource uriPattern: '/' filePath: 'home'
    ]

    testRootFileFor [
	<category: 'running'>
	| request |
	request := HTTPGet request: '/~someUser'.
	URIResolution new initializeRequest: request.
	self assert: (resource rootFileFor: request) asString 
		    = (((SpFilename named: 'home') construct: 'someUser') construct: 'html') 
			    asString
    ]

    testValidateHomePath [
	<category: 'running'>
	self assert: (resource validateHomePath: '~somebody').
	self assert: (resource validateHomePath: '~somebodyElse').
	self deny: (resource validateHomePath: 'someplace').
	self deny: (resource validateHomePath: 'some~body')
    ]
]



TestCase subclass: RedirectionResourceTest [
    | resource |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	resource := RedirectionResource uriPattern: 'foo'
		    targetUri: 'http://abc.def.com'
    ]

    testGetResource [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 301.
	self assert: (response headers fieldNamed: 'Location') uri asString 
		    = 'http://abc.def.com'.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'
    ]
]



TestCase subclass: ResourceTest [
    | resource |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    basicGet: uri [
	<category: 'private'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uri , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: swazoo.org'.
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)
    ]

    basicGetUri: uriString [
	<category: 'private'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uriString , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: swazoo.org'.
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)
    ]

    basicGetUri: uriString host: hostname port: port [
	<category: 'private'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uriString , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: ' , hostname.
	port notNil 
	    ifTrue: 
		[ws
		    nextPut: $:;
		    print: port].
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)
    ]

    crlfOn: aStream [
	<category: 'private'>
	aStream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    setUp [
	<category: 'running'>
	resource := Resource uriPattern: 'foo'
    ]

    testEmptyURIPatternInvalid [
	<category: 'testing'>
	resource uriPattern: ''.
	self deny: resource isValidlyConfigured
    ]

    testEnabledByDefault [
	<category: 'testing'>
	self assert: resource isEnabled
    ]

    testNilURIPatternDoesNothing [
	<category: 'testing'>
	| pattern |
	pattern := resource uriPattern.
	resource uriPattern: nil.
	self assert: resource uriPattern = pattern
    ]

    testValidlyConfigured [
	<category: 'testing'>
	self assert: resource isValidlyConfigured
    ]
]



TestCase subclass: SiteIdentifierTest [
    | identifier |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	identifier := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 80
    ]

    testCaseInsensitiveMatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'lOCaLhOST'
		    ip: '127.0.0.1'
		    port: 80.
	self assert: (identifier match: another)
    ]

    testCurrentUrl [
	<category: 'testing'>
	self assert: identifier currentUrl = 'http://localhost'.
	identifier := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 81.
	self assert: identifier currentUrl = 'http://localhost:81'
    ]

    testHostMismatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'thisIsMyMachine'
		    ip: '127.0.0.1'
		    port: 80.
	self deny: (identifier match: another)
    ]

    testIPMismatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.2'
		    port: 80.
	self deny: (identifier match: another)
    ]

    testMatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 80.
	self assert: (identifier match: another)
    ]

    testPortMismatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 81.
	self deny: (identifier match: another)
    ]
]



TestCase subclass: SiteTest [
    | site |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    addSecondAlias [
	<category: 'running'>
	site addAlias: (SiteIdentifier 
		    host: 'swazoo2.org'
		    ip: '127.0.0.2'
		    port: 8202)
    ]

    setUp [
	<category: 'running'>
	super setUp.
	site := Site new.
	site addAlias: (SiteIdentifier 
		    host: 'swazoo.org'
		    ip: '127.0.0.1'
		    port: 8200)
    ]

    testCurrentUrl [
	<category: 'testing'>
	site currentUrl = 'http://swazoo.org:8200'.
	self addSecondAlias.
	site currentUrl = 'http://swazoo.org:8200'
    ]

    testCurrentUrl80 [
	<category: 'testing'>
	| aSite |
	aSite := Site new.
	aSite addAlias: (SiteIdentifier 
		    host: 'swazoo.org'
		    ip: '127.0.0.1'
		    port: 80).
	aSite currentUrl = 'http://swazoo.org'.
	aSite currentUrl = 'http://swazoo.org'
    ]
]



TestCase subclass: SwazooBaseExtensionsTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    testCharacterArrayTrimBlanks [
	<category: 'testing'>
	self 
	    assert: (HTTPString trimBlanksFrom: '   a b c d e f g') = 'a b c d e f g'.
	self assert: (HTTPString trimBlanksFrom: 'no blanks') = 'no blanks'.
	self assert: (HTTPString trimBlanksFrom: ' leading') = 'leading'.
	self assert: (HTTPString trimBlanksFrom: 'trailing ') = 'trailing'.
	self assert: (HTTPString trimBlanksFrom: '') = ''.
	self 
	    assert: (HTTPString 
		    trimBlanksFrom: (String with: Character cr with: Character lf)) isEmpty
    ]

    testFilenameEtag [
	"The filename etag is a simple string and does not contain double quotes.  Header fields apply double quotes as necessary when writing themselves."

	<category: 'testing'>
	| fn etag1 etag2 |
	fn := SpFilename named: 'etagTest'.
	
	[(fn writeStream)
	    nextPut: $-;
	    close.	"create file"
	etag1 := fn etag.
	(Delay forSeconds: 1) wait.
	(fn appendStream)
	    nextPut: $-;
	    close.	"modify file"
	etag2 := fn etag.
	self assert: (etag1 isKindOf: String).
	self assert: (etag2 isKindOf: String).
	self deny: etag1 = etag2] 
		ensure: [fn delete]
    ]

    testStringNewRandom [
	<category: 'testing'>
	| sizes strings |
	sizes := #(5 20 6127 2 100).
	strings := sizes collect: [:each | HTTPString newRandomString: each].
	strings with: sizes do: [:string :size | self assert: string size = size]
    ]
]



TestCase subclass: SwazooCacheControlTest [
    | resource cacheTarget request cacheControl |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	| directory firstFile ws |
	directory := SpFilename named: 'fResTest'.
	directory exists ifFalse: [directory makeDirectory].
	firstFile := directory construct: 'abc.html'.
	ws := firstFile writeStream.
	[ws nextPutAll: 'hello'] ensure: [ws close].
	resource := FileResource uriPattern: 'foo' filePath: 'fResTest'.
	request := HTTPGet request: 'foo/abc.html'.
	URIResolution resolveRequest: request startingAt: resource.
	cacheControl := SwazooCacheControl new request: request
		    cacheTarget: (cacheTarget := resource fileFor: request)
    ]

    tearDown [
	<category: 'running'>
	((SpFilename named: 'fResTest') construct: 'abc.html') delete.
	(SpFilename named: 'fResTest') delete
    ]

    testIfModifiedSinceModified [
	<category: 'testing'>
	| response timestampInThePast |
	request := HTTPGet request: 'foo/abc.html'.
	timestampInThePast := SpTimestamp fromDate: (Date today subtractDays: 1)
		    andTime: Time now.
	request headers addField: (HTTPIfModifiedSinceField new 
		    valueFrom: timestampInThePast asRFC1123String).
	cacheControl := SwazooCacheControl new request: request
		    cacheTarget: cacheTarget.
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfModifiedSince.
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]

    testIfModifiedSinceNot [
	<category: 'testing'>
	| response |
	request headers addField: (HTTPIfModifiedSinceField new 
		    valueFrom: cacheTarget lastModified asRFC1123String).
	self assert: cacheControl isNotModified.
	self assert: cacheControl isIfModifiedSince not.
	response := HTTPResponse notModified.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]

    testIfNoneMatchHeaderMatch [
	"same etag"

	<category: 'testing'>
	| response |
	request headers 
	    addField: (HTTPIfNoneMatchField new addEntityTag: cacheTarget etag).
	self assert: cacheControl isNotModified.
	self deny: cacheControl isIfNoneMatch.

	"do NOT include last-modified"
	response := HTTPResponse notModified.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self 
	    assert: (response headers fieldNamed: 'Last-Modified' ifNone: [nil]) isNil
    ]

    testIfNoneMatchHeaderNone [
	"same etag"

	<category: 'testing'>
	| response |
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new valueFrom: 'blah').
	cacheControl := SwazooCacheControl new request: request
		    cacheTarget: cacheTarget.
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfNoneMatch.
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]

    testNoHeaders [
	<category: 'testing'>
	| response |
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfNoneMatch.
	self assert: cacheControl isIfModifiedSince.

	"add both"
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]
]



TestCase subclass: SwazooCompilerTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    testEvaluate [
	<category: 'running'>
	self assert: (SwazooCompiler evaluate: '1 + 2 * 3') = 9
    ]

    testEvaluateReceiver [
	<category: 'running'>
	self assert: (SwazooCompiler evaluate: 'self + 2 * 3' receiver: 1) = 9
    ]
]



TestCase subclass: SwazooConfigurationTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    testCompositeResourceSite [
	<category: 'testing'>
	| rs site composite howdy duh hithere |
	rs := ReadStream 
		    on: '<Site>
 <CompositeResource uriPattern: ''/''>
  <HelloWorldResource uriPattern: ''howdy''>
  <CompositeResource uriPattern: ''duh''>
   <HelloWorldResource uriPattern: ''hithere''>
  </CompositeResource>
 </CompositeResource>
</Site>'.
	site := Site new readFrom: rs.
	self assert: site children size = 1.
	composite := site children first.
	self assert: composite class == CompositeResource.
	self assert: composite uriPattern = '/'.
	self assert: composite children size = 2.
	self assert: composite parent == site.
	howdy := composite children first.
	self assert: howdy class == HelloWorldResource.
	self assert: howdy uriPattern = 'howdy'.
	self assert: howdy parent == composite.
	duh := composite children last.
	self assert: duh children size = 1.
	self assert: duh class == CompositeResource.
	self assert: duh uriPattern = 'duh'.
	self assert: duh parent == composite.
	hithere := duh children first.
	self assert: hithere class == HelloWorldResource.
	self assert: hithere uriPattern = 'hithere'.
	self assert: hithere parent == duh
    ]

    testEmptySite [
	<category: 'testing'>
	| rs site alias |
	rs := ReadStream 
		    on: '<Site>
 <SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
</Site>'.
	site := Site new readFrom: rs.
	self assert: site aliases size = 1.
	self assert: site currentUrl = 'http://swazoo.org/'.
	alias := site aliases first.
	self assert: alias host = 'swazoo.org'.
	self assert: alias ip = '192.168.1.66'.
	self assert: alias port = 80
    ]

    testFileResourceSite [
	<category: 'testing'>
	| rs site resource |
	rs := ReadStream 
		    on: '<Site>
<SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
 <FileResource uriPattern: ''/'' filePath: ''files''>
</Site>'.
	site := Site new readFrom: rs.
	self assert: site children size = 1.
	resource := site children first.
	self assert: resource class == FileResource.
	self assert: resource uriPattern = '/'.
	self assert: resource filePath = 'files'.
	self assert: resource parent == site.
	self assert: resource currentUrl = 'http://swazoo.org/'
    ]

    testMultipleResourcesSite [
	<category: 'testing'>
	| rs site resource1 resource2 |
	rs := ReadStream 
		    on: '<Site>
 <HelloWorldResource uriPattern: ''/''>
 <HelloWorldResource uriPattern: ''/''>
</Site>'.
	site := Site new readFrom: rs.
	self assert: site children size = 2.
	resource1 := site children first.
	self assert: resource1 class == HelloWorldResource.
	self assert: resource1 uriPattern = '/'.
	resource2 := site children last.
	self assert: resource2 class == HelloWorldResource.
	self assert: resource2 uriPattern = '/'
    ]

    testMultipleSites [
	<category: 'testing'>
	| rs sites site alias1 alias2 |
	rs := ReadStream 
		    on: '<Site>
 <SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
 <SiteIdentifier ip: ''192.168.1.66'' port: 81 host: ''swazoo.org''>
</Site>
<Site>
</Site>'.
	sites := SwazooServer readSitesFrom: rs.
	self assert: sites size = 2.
	site := sites first.
	self assert: site aliases size = 2.
	alias1 := site aliases first.
	self assert: alias1 host = 'swazoo.org'.
	self assert: alias1 ip = '192.168.1.66'.
	self assert: alias1 port = 80.
	alias2 := site aliases last.
	self assert: alias2 host = 'swazoo.org'.
	self assert: alias2 ip = '192.168.1.66'.
	self assert: alias2 port = 81
    ]

    testSingleResourceSite [
	<category: 'testing'>
	| rs site resource |
	rs := ReadStream 
		    on: '<Site>
<SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
 <HelloWorldResource uriPattern: ''/''>
</Site>'.
	site := Site new readFrom: rs.
	self assert: site children size = 1.
	resource := site children first.
	self assert: resource class == HelloWorldResource.
	self assert: resource uriPattern = '/'.
	self assert: resource parent == site.
	self assert: resource currentUrl = 'http://swazoo.org/'
    ]

    testSiteTag [
	<category: 'testing'>
	| rs config tag |
	rs := ReadStream on: '  <Site>  

</Site>   '.
	config := Site new.
	tag := config nextTagFrom: rs.
	self assert: tag = 'Site'.
	tag := config nextTagFrom: rs.
	self assert: tag = '/Site'.
	self assert: (config nextTagFrom: rs) isNil
    ]
]



TestCase subclass: SwazooServerTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    testAccessingSite [
	<category: 'testing'>
	| site |
	site := (Site new)
		    name: 'aabbcc';
		    host: 'test.org'
			ip: 'localhost'
			port: 8543.
	
	[SwazooServer singleton addSite: site.
	self assert: (SwazooServer siteNamed: 'aabbcc') notNil.
	site := SwazooServer siteNamed: 'aabbcc'.
	self assert: site name = 'aabbcc'.
	self assert: (SwazooServer siteHostnamed: 'test.org') notNil.
	site := SwazooServer siteHostnamed: 'test.org'.
	self assert: site host = 'test.org'] 
		ensure: [SwazooServer singleton removeSite: site]
    ]

    testAddingAllInterfacesSite [
	"site to listen on all IP interfaces but on specified port"

	<category: 'testing-adding sites'>
	| site server |
	server := SwazooServer singleton.
	self assert: (server siteNamed: 'allInterfaces') isNil.
	site := (Site new)
		    name: 'allInterfaces';
		    host: '*'
			ip: '*'
			port: 7261.
	
	[server addSite: site.
	self assert: (server siteNamed: 'allInterfaces') notNil] 
		ensure: [server removeSite: site]
    ]

    testAddingSite [
	<category: 'testing-adding sites'>
	| site server nrSites |
	server := SwazooServer singleton.
	nrSites := server sites size.
	self assert: (server siteNamed: 'aabbcc') isNil.
	self assert: (server siteHostnamed: 'test.org') isNil.
	site := (Site new)
		    name: 'aabbcc';
		    host: 'test.org'
			ip: 'localhost'
			port: 80.
	server addSite: site.
	self assert: (server siteNamed: 'aabbcc') notNil.
	self assert: (server siteHostnamed: 'test.org') notNil.
	server removeSite: site.
	self assert: server sites size = nrSites
    ]

    testAllInterfacesTwoPortSites [
	"two sites can run on all IP interfaces and different port"

	<category: 'testing-adding sites'>
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (Site new)
		    name: 'allInterfaces1';
		    host: '*'
			ip: '*'
			port: 7261.
	site2 := (Site new)
		    name: 'allInterfaces2';
		    host: '*'
			ip: '*'
			port: 7262.
	
	[server addSite: site1.
	self shouldnt: [server addSite: site2] raise: Error] 
		ensure: 
		    [server
			removeSite: site1;
			removeSite: site2]
    ]

    testDuplicateAllInterfacesSite [
	"two sites cannot run on all IP interfaces and same port"

	<category: 'testing-adding sites'>
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (Site new)
		    name: 'allInterfaces1';
		    host: '*'
			ip: '*'
			port: 7261.
	site2 := (Site new)
		    name: 'allInterfaces2';
		    host: '*'
			ip: '*'
			port: 7261.
	
	[server addSite: site1.
	self should: [server addSite: site2] raise: Error] 
		ensure: [server removeSite: site1]
    ]

    testDuplicateNames [
	<category: 'testing-adding sites'>
	| site server |
	server := SwazooServer singleton.
	site := (Site new)
		    name: 'aabbcc';
		    host: 'test.org'
			ip: 'localhost'
			port: 80.
	
	[server addSite: site.
	self should: [site name: 'aabbcc'] raise: Error.
	self shouldnt: [site host: 'test.org'] raise: Error.
	self should: 
		[(Site new)
		    name: 'aabbcc';
		    host: 'test.org'
			ip: 'localhost'
			port: 80]
	    raise: Error] 
		ensure: [server removeSite: site]
    ]

    testStartingOnAPort [
	"and all ip interfaces, any host"

	<category: 'testing'>
	| site server nrServers |
	server := SwazooServer singleton.
	nrServers := server servers size.
	
	[site := server startOn: 4924.
	self assert: site isServing.
	self assert: server servers size = (nrServers + 1).
	server stopOn: 4924.
	self assert: site isServing not.
	self assert: server servers size = nrServers] 
		ensure: 
		    [site stop.
		    server removeSite: site]
    ]

    testStartingOnTwoPorts [
	"and all ip interfaces, any host"

	<category: 'testing'>
	| server nrServers site1 site2 |
	server := SwazooServer singleton.
	nrServers := server servers size.
	
	[site1 := server startOn: 4924.
	site2 := server startOn: 4925.
	self assert: site1 isServing.
	self assert: site2 isServing.
	self assert: server servers size = (nrServers + 2).
	server stopOn: 4924.
	server stopOn: 4925.
	self assert: site1 isServing not.
	self assert: site2 isServing not.
	self assert: server servers size = nrServers] 
		ensure: 
		    [site1 stop.
		    site2 stop.
		    server
			removeSite: site1;
			removeSite: site2]
    ]

    testStartingSite [
	<category: 'testing'>
	| site server nrServers |
	server := SwazooServer singleton.
	nrServers := server servers size.
	site := (Site new)
		    name: 'aabbcc';
		    host: 'test.org'
			ip: 'localhost'
			port: 8765.
	
	[server addSite: site.
	self assert: site isServing not.
	SwazooServer startSite: 'aabbcc'.
	self assert: server servers size = (nrServers + 1).
	self assert: site isServing.
	SwazooServer stopSite: 'aabbcc'.
	self assert: site isServing not.
	self assert: server servers size = nrServers] 
		ensure: 
		    [site stop.
		    server removeSite: site]
    ]
]



TestCase subclass: SwazooSocketTest [
    | input output |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	| pair |
	pair := SwazooSocket connectedPair.
	input := pair first.
	output := pair last
    ]

    tearDown [
	<category: 'running'>
	input close.
	output close
    ]

    testConnectedPair [
	<category: 'testing'>
	(Array with: input with: output) 
	    do: [:each | self assert: (each isKindOf: SwazooSocket)]
    ]

    testNetworkConnection [
	<category: 'testing'>
	| server sem |
	input close.
	output close.
	sem := Semaphore new.
	
	[server := SwazooSocket serverOnIP: '127.0.0.1' port: 65423.
	server listenFor: 50.
	
	[input := server accept.
	sem signal] fork.
	output := SwazooSocket connectTo: 'localhost' port: 65423.
	sem wait.
	self testReadWrite] 
		ensure: [server close]
    ]

    testPartialRead [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray withAll: #(5 4 3).
	self assert: (input write: bytes) = 3.
	self assert: (output read: 5) = bytes
    ]

    testReadTimeout [
	<category: 'testing'>
	input write: (ByteArray withAll: #(1 2 3)).
	self assert: (output read: 3 timeout: 40) = (ByteArray withAll: #(1 2 3)).
	self assert: (output read: 3 timeout: 40) = ByteArray new
    ]

    testReadWrite [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray withAll: #(1 2 3 4 5).
	self assert: (input write: bytes) = 5.
	self assert: (output read: 5) = bytes.
	bytes := ByteArray with: 4.
	self assert: (input write: bytes) = 1.
	self assert: (output read: 1) = bytes
    ]
]



TestCase subclass: SwazooStreamTest [
    | input output |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    crlfOn: aSwazooStream [
	<category: 'running'>
	aSwazooStream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    setUp [
	<category: 'running'>
	| pair |
	pair := SwazooStream connectedPair.
	input := pair first.
	output := pair last
    ]

    tearDown [
	<category: 'running'>
	input close.
	output close
    ]

    testConnectedPair [
	<category: 'testing'>
	(Array with: input with: output) 
	    do: [:each | self assert: (each isKindOf: SwazooStream)]
    ]

    testErrorOnInputClose [
	<category: 'testing'>
	self should: 
		[input close.
		output next]
	    raise: Error
    ]

    testLinesWithDoubleCRLF [
	<category: 'testing-lines'>
	| ws rs comparisonString |
	comparisonString := 'abcd'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	self crlfOn: ws.
	self crlfOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = comparisonString.
	self assert: rs nextLine = ''
    ]

    testNextPut [
	<category: 'testing'>
	#($A $M $Y $b $r $z) do: 
		[:each | 
		self assert: (input nextPut: each) = each.
		input flush.
		self assert: output next = each]
    ]

    testNextPutAll [
	<category: 'testing'>
	#('123' 'abc' 'swazoo') do: 
		[:each | 
		self assert: (input nextPutAll: each) = each.
		input flush.
		self assert: (output next: each size) = each]
    ]

    testNextPutByte [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray 
		    with: 6
		    with: 5
		    with: 0
		    with: 2.
	bytes do: 
		[:each | 
		self assert: (input nextPutByte: each) = each.
		input flush.
		self assert: output nextByte = each]
    ]

    testNextPutBytes [
	<category: 'testing'>
	| bytes1 bytes2 bytes3 |
	bytes1 := ByteArray withAll: #(1 2 3 4).
	bytes2 := ByteArray withAll: #(5 4 3 2 1).
	bytes3 := ByteArray withAll: #(1 1 2 3 5).
	(Array 
	    with: bytes1
	    with: bytes2
	    with: bytes3) do: 
		    [:each | 
		    self assert: (input nextPutBytes: each) = each.
		    input flush.
		    self assert: (output nextBytes: each size) = each]
    ]

    testPeek [
	<category: 'testing'>
	#($K $J $D $j $m $z) do: 
		[:each | 
		input nextPut: each.
		input flush.
		self assert: output peek = each.
		output next]
    ]

    testPeekByte [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray withAll: #(5 2 8 4 11 231).
	bytes do: 
		[:each | 
		input nextPutByte: each.
		input flush.
		self assert: output peekByte = each.
		output nextByte]
    ]

    testSingleLineWithCR [
	<category: 'testing-lines'>
	| ws rs comparisonString errored |
	comparisonString := 'abcd' , (String with: Character cr) , 'efg'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	ws nextPut: Character cr.
	rs := SwazooStream on: ws writeBuffer contents.
	errored := false.
	SpExceptionContext 
	    for: [rs nextLine]
	    on: SpError
	    do: [:ex | errored := true].
	self assert: errored
    ]

    testSingleLineWithCRLF [
	<category: 'testing-lines'>
	| ws rs comparisonString |
	comparisonString := 'abcd'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	self crlfOn: ws.
	rs := SwazooStream on: ws writeBuffer contents.
	self assert: rs nextLine = comparisonString
    ]
]



TestCase subclass: SwazooURITest [
    | fooURI barURI queryURI |
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    setUp [
	<category: 'running'>
	fooURI := SwazooURI fromString: 'www.foo.com/index.html'.
	queryURI := SwazooURI fromString: 'www.foo.com/index.html?foo=1&bar=hi'.
	barURI := SwazooURI fromString: 'www.bar.com:8080/files/'
    ]

    testHostname [
	<category: 'running'>
	self assert: fooURI hostname = 'www.foo.com'.
	self assert: queryURI hostname = 'www.foo.com'.
	self assert: barURI hostname = 'www.bar.com'
    ]

    testIdentifier [
	<category: 'running'>
	self assert: fooURI identifier = '/index.html'.
	self assert: queryURI identifier = '/index.html'.
	self assert: barURI identifier = '/files/'
    ]

    testIdentifierPath [
	<category: 'running'>
	self assert: fooURI identifierPath 
		    = (OrderedCollection with: '/' with: 'index.html').
	self assert: queryURI identifierPath 
		    = (OrderedCollection with: '/' with: 'index.html').
	self 
	    assert: barURI identifierPath = (OrderedCollection with: '/' with: 'files')
    ]

    testIsDirectory [
	<category: 'running'>
	self deny: fooURI isDirectory.
	self deny: queryURI isDirectory.
	self assert: barURI isDirectory
    ]

    testPort [
	<category: 'running'>
	self assert: fooURI port = 80.
	self assert: queryURI port = 80.
	self assert: barURI port = 8080
    ]

    testQueries [
	<category: 'running'>
	self deny: (queryURI includesQuery: 'hi').
	self assert: (queryURI includesQuery: 'foo').
	self assert: (queryURI includesQuery: 'bar').
	self assert: (queryURI queryAt: 'foo') = '1'.
	self assert: (queryURI queryAt: 'bar') = 'hi'
    ]

    testValue [
	<category: 'running'>
	self assert: fooURI value = 'http://www.foo.com/index.html'.
	self assert: queryURI value = 'http://www.foo.com/index.html?foo=1&bar=hi'.
	self assert: barURI value = 'http://www.bar.com:8080/files/'
    ]
]



TestCase subclass: URIParsingTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    test05SimpleFullURI [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com:8080/smith/home.html'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 8080.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com:8080/smith/home.html'
    ]

    test10SimpleFullURIWithQuery [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com:8080/smith/home.html?a=1&b=2'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 8080.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com:8080/smith/home.html?a=1&b=2'
    ]

    test15SimpleFullURIWithPort80 [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com:80/smith/home.html?a=1&b=2'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 80.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com/smith/home.html?a=1&b=2'
    ]

    test20SimpleFullURIWithNoPort [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com/smith/home.html?a=1&b=2'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 80.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com/smith/home.html?a=1&b=2'
    ]
]



TestCase subclass: URIResolutionTest [
    
    <category: 'Swazoo-Tests'>
    <comment: nil>

    testCompositeAnswer [
	<category: 'testing'>
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	resource addResource: (HelloWorldResource uriPattern: 'hi').
	request := HTTPGet request: 'base/hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 2.
	self assert: request resourcePath first = 'base'.
	self assert: request resourcePath last = 'hi'
    ]

    testCompositeItselfCannotAnswer [
	<category: 'testing'>
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	request := HTTPGet request: 'base'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testCompositeNoAnswer [
	<category: 'testing'>
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	resource addResource: (HelloWorldResource uriPattern: 'hi').
	request := HTTPGet request: 'tail/hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testLeafAnswer [
	<category: 'testing'>
	| resource request response |
	resource := HelloWorldResource uriPattern: 'hi'.
	request := HTTPGet request: 'hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'hi'
    ]

    testNoAnswerWhenDisabled [
	<category: 'testing'>
	| resource request response |
	resource := HelloWorldResource uriPattern: 'hi'.
	resource disable.
	request := HTTPGet request: 'hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testResourcePath [
	<category: 'testing'>
	| request resolution |
	request := HTTPGet 
		    request: 'foo/bar/baz/quux'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	resolution := URIResolution new initializeRequest: request.
	self assert: resolution resourcePath = #('foo') asOrderedCollection.
	resolution advance.
	self assert: resolution resourcePath = #('foo' 'bar') asOrderedCollection.
	resolution advance.
	self 
	    assert: resolution resourcePath = #('foo' 'bar' 'baz') asOrderedCollection.
	resolution advance.
	self assert: resolution resourcePath 
		    = #('foo' 'bar' 'baz' 'quux') asOrderedCollection
    ]

    testSiteAnswer [
	<category: 'testing'>
	| resource request response |
	resource := Site new 
		    host: 'foo.com'
		    ip: '1.2.3.4'
		    port: 80.
	resource addResource: (HelloWorldResource uriPattern: '/').
	request := HTTPGet 
		    request: '/'
		    from: 'foo.com'
		    at: '1.2.3.4'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = '/'
    ]

    testSiteMatch [
	<category: 'testing'>
	| request site visitor |
	request := HTTPGet 
		    request: 'foo'
		    from: 'myhosthost:1234'
		    at: '1.2.3.4'.
	visitor := URIResolution new initializeRequest: request.
	site := Site new 
		    host: 'myhosthost'
		    ip: '1.2.3.4'
		    port: 1234.
	self assert: (visitor siteMatch: site)
    ]

    testSiteMismatch [
	<category: 'testing'>
	| request site visitor |
	request := HTTPGet 
		    request: 'foo'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	visitor := URIResolution new initializeRequest: request.
	site := Site new 
		    host: 'remotehost'
		    ip: '1.2.3.4'
		    port: 1234.
	self deny: (visitor siteMatch: site)
    ]

    testStringMatch [
	<category: 'testing'>
	| request visitor resource |
	request := HTTPGet request: 'foo'.
	visitor := URIResolution new initializeRequest: request.
	resource := HelloWorldResource uriPattern: 'foo'.
	self assert: (visitor stringMatch: resource)
    ]

    testStringMismatch [
	<category: 'testing'>
	| request visitor resource |
	request := HTTPGet request: 'foo'.
	visitor := URIResolution new initializeRequest: request.
	resource := HelloWorldResource uriPattern: 'Foo'.
	self deny: (visitor stringMatch: resource)
    ]

    testTailPath [
	<category: 'testing'>
	| request resolution |
	request := HTTPGet 
		    request: 'foo/bar/baz/quux'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	resolution := URIResolution new initializeRequest: request.
	self 
	    assert: resolution tailPath = #('bar' 'baz' 'quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath = #('baz' 'quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath = #('quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath isEmpty
    ]
]



Object subclass: TestPseudoSocket [
    | byteStreamToServer byteStreamFromServer clientWaitSemaphore serverWaitSemaphore ipAddress |
    
    <category: 'Swazoo-Tests'>
    <comment: 'TestPseudoSocket is a drop in replacement for a SwazooSocket that can be used during testing to feed bytes into a running SwazooHTTPServer and grab the responses without having to start a real socket pair.

So, to the HTTP server it must look like a server socket.  To the tester it must look like a write stream (to send bytes to the HTTP server) and a read stream (to read the HTTP responses).'>

    TestPseudoSocket class >> newTCPSocket [
	"^a TestPseudoSocket
	 I simply return a new instance of myself."

	<category: 'instance creation'>
	^self new
    ]

    TestPseudoSocket class >> serverOnIP: host port: port [
	"^self
	 I'm only pretending to be a socket class, so I ignore the host and port."

	<category: 'instance creation'>
	^self new
    ]

    acceptRetryingIfTransientErrors [
	"^another TestSocketThing
	 The sender expects me to block until a request comes in 'over the socket'.  What I really do is wait for someone to ask me to 'send in' a Byte array and then I return myself.  Note that I will only handle one request at a time!!"

	<category: 'socket stuff'>
	self serverWaitSemaphore wait.
	^self
    ]

    bindSocketAddress: anOSkIPAddress [
	"^self
	 This is a no-op for me."

	<category: 'socket stuff'>
	ipAddress := anOSkIPAddress.
	^self
    ]

    byteStreamFromServer [
	<category: 'accessing'>
	^byteStreamFromServer
    ]

    byteStreamFromServer: aByteStream [
	<category: 'accessing'>
	byteStreamFromServer := aByteStream.
	^self
    ]

    byteStreamToServer [
	<category: 'accessing'>
	^byteStreamToServer
    ]

    byteStreamToServer: aByteStream [
	<category: 'accessing'>
	byteStreamToServer := aByteStream.
	^self
    ]

    clientWaitSemaphore [
	"^a Semaphore
	 I return the semaphore I use to control 'client' activity."

	<category: 'accessing'>
	clientWaitSemaphore isNil ifTrue: [clientWaitSemaphore := Semaphore new].
	^clientWaitSemaphore
    ]

    close [
	"^self
	 The server has finished with us at this point, so we signal the semaphore to give the client end chance to grab the response."

	<category: 'socket stuff'>
	self clientWaitSemaphore signal.
	^self
    ]

    flush [
	<category: 'socket stuff'>
	^self
    ]

    getPeerName [
	<category: 'socket stuff'>
	^ipAddress
    ]

    getSocketName [
	<category: 'socket stuff'>
	^ipAddress
    ]

    isActive [
	"^self
	 I am pretending to be a socket, and the sender wants to know if I am active.  Of course I am!!."

	<category: 'socket stuff'>
	^true
    ]

    listenBackloggingUpTo: anInteger [
	"^self
	 This is a no-op for me."

	<category: 'socket stuff'>
	^self
    ]

    listenFor: anInteger [
	"^self
	 This is a no-op for now."

	<category: 'socket stuff'>
	^self
    ]

    next [
	<category: 'stream-toServer'>
	^self byteStreamToServer next
    ]

    nextPut: aCharacter [
	<category: 'stream-fromServer'>
	self byteStreamFromServer nextPut: aCharacter asInteger
    ]

    nextPutAll: aCollection [
	"^self
	 At present it seems that aCollection will always be a string of chacters."

	<category: 'stream-fromServer'>
	^self byteStreamFromServer nextPutAll: aCollection asByteArray
    ]

    nextPutBytes: aByteArray [
	<category: 'stream-fromServer'>
	self byteStreamFromServer nextPutAll: aByteArray
    ]

    peek [
	"^a Character
	 It seems that the HTTP server is expecting Characters not Bytes - this will have to change."

	<category: 'stream-toServer'>
	^byteStreamToServer isNil 
	    ifTrue: [nil]
	    ifFalse: [self byteStreamToServer peek asCharacter]
    ]

    print: anObject [
	<category: 'stream-fromServer'>
	self nextPutAll: anObject printString asByteArray.
	^self
    ]

    read: integerNumberOfBytes [
	"^a ByteArray
	 I read the next numberOfBytes from my underlying stream."

	<category: 'stream-toServer'>
	^byteStreamToServer isNil 
	    ifTrue: [ByteArray new]
	    ifFalse: [self byteStreamToServer nextAvailable: integerNumberOfBytes]
    ]

    serverWaitSemaphore [
	"^a Semaphore
	 I return the semaphore I use to control 'server' activity."

	<category: 'accessing'>
	serverWaitSemaphore isNil ifTrue: [serverWaitSemaphore := Semaphore new].
	^serverWaitSemaphore
    ]

    setAddressReuse: aBoolean [
	"^self
	 This is a no-op for me."

	<category: 'socket stuff'>
	^self
    ]

    socket [
	"^self
	 I am being asked this as if I am a socket stream.  I return myself because I'm pretending to be both the socket and the socket stream."

	<category: 'stream-toServer'>
	^self
    ]

    space [
	<category: 'stream-fromServer'>
	self nextPut: Character space.
	^self
    ]

    stream [
	"^self
	 I have to pretend to be a socket stream too."

	<category: 'socket stuff'>
	^self
    ]

    upTo: aCharacter [
	"a ByteString
	 For some reason, we have to look for a character in a ByteStream - this is a Swazoo thing."

	<category: 'stream-toServer'>
	^(self byteStreamToServer upTo: aCharacter asInteger) asByteString
    ]

    write: aByteArray [
	"^an Integer
	 I write the contents of the sourceByteArray to my underlying Socket.
	 I return the number of bytes written."

	<category: 'stream-fromServer'>
	self byteStreamFromServer nextPutAll: aByteArray.
	^aByteArray size
    ]

    writeBytesToServer: aByteArray [
	"^self
	 This is where we make the bytes available over the pseudo socket.  Unlike a socket this is a one off thing (at least in this implementation of the pseudo socket).  Once the bytes are written, control passes to the server and stays there until the server sends a close to what it thinks is the client socket, but is really me."

	<category: 'actions-client'>
	| results |
	self byteStreamToServer: (ReadStream on: aByteArray).
	self byteStreamFromServer: (WriteStream on: (ByteArray new: 1000)).
	self serverWaitSemaphore signal.
	self clientWaitSemaphore wait.
	results := self byteStreamFromServer contents.
	self byteStreamToServer: nil.
	self byteStreamFromServer: nil.
	^results
    ]
]



