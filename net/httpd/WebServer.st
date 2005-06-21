"======================================================================
|
|   Generic web-server framework
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001 Travis Griggs and Ken Treis
| Written by Travis Griggs, Ken Treis and others.
| Port to GNU Smalltalk, enhancements and refactoring by Paolo Bonzini.
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

NetServer subclass:  #WebServer
	instanceVariableNames: 'virtualHosts defaultVirtualHost log '
	classVariableNames: 'Version'
	poolDictionaries: ''
	category: 'Web-Framework'!

WebServer comment:
'A WebServer keeps a socket listening on a port, and dispatches incoming
requests to Servlet objects.  Thus, it is extremely expandable through
`servlets'' which subclass Servlet.  A separate Process is devoted to HTTP
serving.'!

NetSession subclass:  #WebSession
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

WebSession comment:
'A WebSession is the NetSession object created by a WebServer.'!

Object subclass:  #Servlet
	instanceVariableNames: 'name parent '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

Servlet comment: 
'A Servlet handles WebRequests that are given to it. WebRequests 
come from a WebServer, but often a Servlet will pass them on to
other Servlets.  Thus, sometimes there is a tree of Servlets.'!

Servlet subclass:  #CompositeServlet
	instanceVariableNames: 'components rootServlet errorServlet '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

CompositeServlet comment: 
'Handles a request by looking at the next name in the path.  If there is
no name, it uses the root handler. If there is no handler for the name,
uses the error handler.  Names are case sensitive.'!

Servlet subclass:  #ServletList
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

ServletList comment: 
'A ServletList output a list of servlets that are children of its parent.
It is typically used as the root handler of a CompositeServlet.'!

Servlet subclass:  #ErrorServlet
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

ErrorServlet comment: 
'An ErrorServlet gives a 404 (not found) or 503 (unavailable) error,
depending on whether its parent has children or not.  It is typically used
as the error handler of a CompositeServlet.'!

Stream subclass:  #WebResponse
	instanceVariableNames: 'responseStream request'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

WebResponse comment:
'WebResponse is an object that can emit an HTTP entity.  There can be
different subclasses of WebResponse for the various ways a page can be
rendered, such as errors, files from the file system, or Wiki pages.
Although you are not forced to use WebResponse to respond to requests
in your Servlet, doing so means that a good deal of code is already
there for you, including support for emitting headers, distinguishing
HEAD requests, HTTP/1.1 multi-request connections, and If-Modified-Since
queries.

All subclasses must implement sendBody.'!

Object subclass:  #WebRequest
	instanceVariableNames: 'originator stream action clientData postData location uri '
	classVariableNames: 'EndOfLine EndOfRequest'
	poolDictionaries: ''
	category: 'Web-Framework'!

WebRequest comment:
'WebRequests know how to parse HTTP requests, organizing the data
according to the requested header fields and to the form keys
(encoded in the URL for GET requests and in the request for POST
requests).'!

WebResponse subclass:  #ErrorResponse
	instanceVariableNames: 'errorCode additionalHeaders '
	classVariableNames: 'ErrorNames ErrorDescriptions '
	poolDictionaries: ''
	category: 'Web-Framework'!

ErrorResponse comment:
'An ErrorResponse generates responses with 3xx, 4xx or 5xx status codes,
together with their explaining HTML entities.'!

Object subclass: #WebAuthorizer
	instanceVariableNames: 'authorizer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Web-Framework'!

WebAuthorizer comment:
'A WebAuthorizer checks for the correctness login/password couplets in an
HTTP request using the Basic authentication scheme.'!

!WebServer class methodsFor: 'accessing'!

version
    | number |
    Version isNil ifFalse: [ ^Version ].
    number := Smalltalk version substrings
	detect: [ :each | (each at: 1) isDigit ]
	ifNone: [ '0.0' "???" ].

    ^Version := 'GNU-WikiWorks/', number!

!WebServer methodsFor: 'logging'!

log: action uri: location time: time
    "self times nextPut: (Array with: action with: location with: time)"
    Transcript
	print: time; space;
	nextPutAll: action; space;
	print: location; nl!

log
    "self times"
    log isNil ifTrue: [log := WriteStream on: Array new].
    ^log! !

!WebServer methodsFor: 'accessing'!

depth
    ^-1!

addVirtualHost: aServlet
    virtualHosts addComponent: aServlet!

defaultVirtualHost
    ^defaultVirtualHost!

defaultVirtualHost: anHost
    virtualHosts rootServlet: (virtualHosts componentNamed: anHost).
    defaultVirtualHost := anHost!

handler
    ^virtualHosts rootServlet!

handler: aServlet
    aServlet name: self defaultVirtualHost.
    virtualHosts
	addComponent: aServlet;
	rootServlet: aServlet!

respondTo: aRequest
    | host handler |
    host := aRequest at: #'HOST' ifAbsent: [ self defaultVirtualHost ].
    (virtualHosts hasComponentNamed: host)
	ifFalse: [ host := self defaultVirtualHost ].

    (virtualHosts componentNamed: host) respondTo: aRequest
! !

!WebServer methodsFor: 'initialize-release'!

initialize
    super initialize.
    virtualHosts := CompositeServlet new.
    virtualHosts parent: self.
    self
	defaultVirtualHost: TCP.SocketAddress localHostName;
	handler: CompositeServlet new! !

!WebServer methodsFor: 'private'!

uriOn: aStream
    aStream nextPutAll: 'http:/'!

newSession
    ^WebSession new!

!WebSession methodsFor: 'private'!

next
    ^WebRequest for: self socket
!

log: req time: time
    self server log: req action uri: req location time: time.
! !


!Servlet methodsFor: 'accessing'!

depth
    ^parent depth + 1!

name
    ^name!

name: aString
    name := aString!

parent
    ^parent!

parent: anObject
    parent := anObject!

uriOn: aStream
    self printOn: aStream!

printOn: aStream
    parent uriOn: aStream.
    self name isNil ifTrue: [ ^self ].
    aStream nextPut: $/.
    aStream nextPutAll: self name.
! !

!CompositeServlet class methodsFor: 'instance creation'!

new
    ^self onError: ErrorServlet new!

onError: aServlet
    ^self onError: aServlet onRoot: ServletList new!

onError: aServlet onRoot: anotherServlet
    ^super new onError: aServlet onRoot: anotherServlet! !

!CompositeServlet methodsFor: 'accessing'!

errorServlet
    ^errorServlet!

errorServlet: aServlet
    errorServlet := aServlet.
    aServlet parent: self!

rootServlet
    ^rootServlet!

rootServlet: aServlet
    rootServlet := aServlet.
    aServlet parent: self!

addComponent: aServlet
    components at: aServlet name put: aServlet.
    aServlet parent: self!

componentNamed: aString
    ^components at: aString ifAbsent: [errorServlet]!

components
    ^components copy!

hasComponentNamed: aString
    ^components includesKey: aString! !

!CompositeServlet methodsFor: 'initialize release'!

onError: aServlet onRoot: anotherServlet
    components := Dictionary new.
    self errorServlet: aServlet.
    self rootServlet: anotherServlet.
    anotherServlet parent: self.! !

!CompositeServlet methodsFor: 'interaction'!

respondTo: aRequest
    | componentName |
    aRequest location size < self depth
	ifTrue: [^rootServlet respondTo: aRequest].

    componentName := aRequest location at: self depth.
    (self hasComponentNamed: componentName)
	ifFalse: [^errorServlet respondTo: aRequest].

    ^(self componentNamed: componentName) respondTo: aRequest! !


!WebResponse methodsFor: 'streaming'!

<< anObject
    responseStream display: anObject!

nl
    responseStream nl!

nextPut: aCharacter
    responseStream nextPut: aCharacter!

nextPutUrl: aString
    responseStream nextPutAll: (URL encode: aString)!

nextPutAll: aString
    responseStream nextPutAll: aString!

do: aBlock
    self shouldNotImplement!

next
    self shouldNotImplement!

atEnd
    ^true! !

!WebResponse methodsFor: 'testing'!

isErrorResponse
    ^false! !

!WebResponse methodsFor: 'response'!

modifiedTime
    ^DateTime now!

respondTo: aRequest
    responseStream := aRequest stream.
    request := aRequest.
    self notModified
	ifTrue: [ self sendNotModifiedResponse ]
	ifFalse: [
	    self sendHeader.
	    aRequest isHead ifFalse: [ self sendBody ]
	].

    responseStream := request := nil!

notModified
    | ifModSince modTime |
    ifModSince := request at: #'IF-MODIFIED-SINCE' ifAbsent: [ nil ].
    ^ifModSince notNil and: [ self modifiedTime <= ifModSince ]!

request
    ^request!

responseStream
    ^responseStream!

sendBody
!

contentLength
    ^nil!

sendHeader
    | stream |
    stream := responseStream.
    responseStream := CrLfStream on: stream.
    self sendResponseType.
    self sendServerHeaders.
    self sendStandardHeaders.
    self sendModifiedTime.
    self sendMimeType.
    self sendHeaderSeparator.
    
    "Send the body as binary"
    responseStream := stream!

sendHeaderSeparator
    self nl!

sendNotModifiedResponse
    ^self
	nextPutAll: 'HTTP/1.1 304 Not modified';
	sendServerHeaders;
	sendModifiedTime;
	sendHeaderSeparator;
	yourself!

sendMimeType
    self
	nextPutAll: 'Content-Type: text/html'; nl!

sendResponseType
    self
	nextPutAll: 'HTTP/1.1 200 Page follows';
	nl!

sendServerHeaders
    self
	nextPutAll: 'Date: ';
	sendTimestamp: DateTime now;
	nl;
	nextPutAll: 'Server: ';
	nextPutAll: WebServer version;
	nl.
!    

sendStandardHeaders
    | length |
    length := self contentLength.
    length isNil
	ifTrue: [ request moreRequests: false ]
	ifFalse: [ self << 'Content-Length: '; << length; nl ].
	
    self << 'Connection: '; << (request at: #Connection); nl.
!

sendModifiedTime
    self << 'Last-Modified: '; sendTimestamp: self modifiedTime; nl
!

sendTimestamp: aTimestamp
    | utc |
    utc := aTimestamp offset = Duration zero
	ifTrue: [ aTimestamp ]
	ifFalse: [ aTimestamp asUTC ].

    self
	nextPutAll: aTimestamp dayOfWeekAbbreviation;
	nextPutAll: (aTimestamp day < 10 ifTrue: [ ', 0' ] ifFalse: [ ', ' ]);
	print: aTimestamp day;
	space;
	nextPutAll: aTimestamp monthAbbreviation;
	space;
	print: aTimestamp year;
	space;
	print: aTimestamp asTime;
	nextPutAll: ' GMT'! !


!WebResponse methodsFor: 'html'!

lineBreak
    self << '<BR>'; nl!

heading: aBlock
    self heading: aBlock level: 1!

heading: aBlock level: anInteger
    self << '<H' << anInteger << '>'.
    aBlock value.
    self << '</H'; << anInteger; << '>'; nl!

horizontalLine
    self << '<HR>'; nl!

image: fileNameBlock linkTo: urlBlock titled: titleBlock
    self << '<A href="'.
    urlBlock value.
    self << '"><IMG src="'.
    fileNameBlock value.
    self << '" alt="'.
    titleBlock value.
    self << '" border=0></A>'!

image: fileNameBlock titled: titleBlock
    self << '<IMG src="'.
    fileNameBlock value.
    self << '" alt="'.
    titleBlock value.
    self << '">'!

linkTo: urlBlock titled: titleBlock
    self << '<A href="'.
    urlBlock value.
    self << '">'.
    titleBlock value.
    self << '</A>'!

listItem: aBlock
    self << '<LI>'.
    aBlock value.
    self << '</LI>'; nl!

monospace: aBlock
    self << '<PRE>'.
    aBlock value.
    self << '</PRE>'; nl!

para: aBlock
    self << '<P>'.
    aBlock value.
    self << '</P>'; nl!

bold: aBlock
    self << '<B>'.
    aBlock value.
    self << '</B>'; nl!

italic: aBlock
    self << '<I>'.
    aBlock value.
    self << '</I>'; nl!

tr: aBlock
    self << '<TR>'.
    aBlock value.
    self << '</TR>'; nl!

td: aBlock
    self << '<TD>'.
    aBlock value.
    self << '</TD>'; nl! !

!ServletList methodsFor: 'interaction'!

respondTo: aRequest
    | stream |
    stream := aRequest stream.
    parent components isEmpty
	ifTrue: [ ^ErrorResponse unavailable respondTo: aRequest; nl].

    aRequest pageFollows.
    stream nextPutAll: '<HTML><TITLE>Top page</TITLE><BODY>'; nl.
    stream nextPutAll: '<H2>Welcome to my server!!</H2>'; nl.
    stream nextPutAll: 'This server contains the following sites:'; nl.
    stream nextPutAll: '<UL>'; nl.
    parent components keys asSortedCollection do: [:each |
	stream
	    nextPutAll: '  <LI><A HREF="/';
	    nextPutAll: each; nextPutAll: '">';
	    nextPutAll: each; nextPutAll: '</A>';
	    nextPutAll: ', a ';
	    print: (parent componentNamed: each) class;
	    nl].
    stream nextPutAll: '</UL>'; nl.
    
    stream nextPutAll: '</BODY></HTML>'; nl; nl! !


!WebRequest class methodsFor: 'initialization'!

initialize
   EndOfLine := String with: Character cr with: Character nl.
   EndOfRequest := EndOfLine, EndOfLine! !

!WebRequest class methodsFor: 'instance creation'!

for: aClientConnection
    ^self new initConnection: aClientConnection!

new
    ^super new initialize! !

!WebRequest methodsFor: 'accessing'!

action
    ^action!

action: aString
    action := aString.!

at: aSymbol
    ^clientData at: aSymbol!

at: aSymbol ifAbsent: aBlock
    ^clientData at: aSymbol ifAbsent: aBlock!

enumeratePostData: aBlock
    postData keysAndValuesDo: aBlock!

getRequest
    | saveStream version |
    saveStream := stream.
    stream := CrLfStream on: saveStream.
    
    self extractAction.
    self extractLocation.
    version := stream upTo: Character cr.
    stream next.				"Get nl"

    self extractClientData: version.
    (action sameAs: 'POST') ifTrue: [ self extractPostData: version ].
    
    "Get back to binary mode"
    stream := saveStream!

location
    ^location!

isHead
    ^action sameAs: 'HEAD'!

originator
    ^originator!

pageFollows
    WebResponse new respondTo: self!

parseTimestamp: ts
    | tok d m y time |
    tok := ts substrings.
    (tok at: 1) last = $, ifFalse: [ "asctime:  Sun Nov  6 08:49:37 1994"
         ts size = 5 ifFalse: [ ^nil ].
         m := (ts at: 2) asSymbol.
         d := (ts at: 3) asInteger.
         y := (ts at: 5) asInteger.
         time := ts at: 4.
         ^self makeTimestamp: d month: m year: y time: time
    ].
    (tok at: 1) size = 4 ifTrue: [ "RFC 822:  Sun, 06 Nov 1994 08:49:37 GMT"
         ts size = 6 ifFalse: [ ^nil ].
         d := (ts at: 2) asInteger.
         m := (ts at: 3) asSymbol.
         y := (ts at: 4) asInteger.
         time := ts at: 5.
         ^self makeTimestamp: d month: m year: y time: time
    ].
    "RFC 850 (obsolete):  Sunday, 06-Nov-94 08:49:37 GMT"
    ts size = 4 ifFalse: [ ^nil ].
    d := ts at: 2.
    time := ts at: 3.
    d size = 9 ifFalse: [ ^nil ].
    y := (d at: 8) base10DigitValue * 10 + (d at: 9) base10DigitValue + 1900.
    m := (d copyFrom: 4 to: 6) asSymbol.
    d := (d at: 1) base10DigitValue * 10 + (d at: 2) base10DigitValue.
    ^self makeTimestamp: d month: m year: y time: time!

moreRequests
    ^(self at: #Connection) sameAs: 'keep-alive'
!

moreRequests: aBoolean
    self at: #Connection put: (aBoolean
	ifTrue: [ 'Keep-Alive' ]
	ifFalse: [ 'close' ])!

postDataAt: aSymbol
    ^postData at: aSymbol!

postDataAt: aSymbol ifAbsent: aBlock
    ^postData at: aSymbol ifAbsent: aBlock!

stream
    ^stream!

stream: aStream
    stream := aStream.
    originator := stream remoteAddress name!
    
uri
    ^uri!

!WebRequest methodsFor: 'initialize-release'!

initConnection: aClientConnection
    | ec |
    self
	stream: aClientConnection;
	getRequest.!

initialize
    postData := IdentityDictionary new.
    clientData := IdentityDictionary new.
    location := OrderedCollection new!

release
    stream flush.
    self moreRequests ifFalse: [ stream close ].
    ^super release! !

!WebRequest methodsFor: 'private'!

at: aSymbol put: aValue
    ^clientData at: aSymbol put: aValue!

makeTimestamp: d month: m year: y time: t
    | month |
    t size = 8 ifFalse: [ ^nil ].

    month := #(#Jan #Feb #Mar #Apr #May #Jun #Jul #Aug #Sep #Oct #Nov #Dec)
	indexOf: m ifAbsent: [ ^nil ].

    ^(((t at: 1) base10DigitValue * 10 + (t at: 2) base10DigitValue) * 3600)
     + (((t at: 4) base10DigitValue * 10 + (t at: 5) base10DigitValue) * 60)
     + (((t at: 7) base10DigitValue * 10 + (t at: 8) base10DigitValue))
     + (Date newDay: d monthIndex: month year: y) asSeconds!

endOfLine
    ^EndOfLine!

endOfRequest
    ^EndOfRequest!

extractAction
    action := stream upTo: Character space!

extractClientData: clientVersion
    | rs |
    "Default depends on version"
    self at: #Connection put: (clientVersion = '1.0'
	ifTrue: [ 'close' ]
	ifFalse: [ 'keep-alive' ]).

    rs := (stream upToAll: self endOfRequest) readStream.
    [rs atEnd] whileFalse: [
	self
	    at: (rs upTo: $:) asUppercase asSymbol
	    put: (rs upTo: Character cr) trimSeparators
    ]!

extractLocation
    uri := (stream upToAll: 'HTTP/') trimSeparators.
    location := uri substrings: $?.
    location size = 2 ifTrue: [ self extractQueryData: (location at: 2) ].
    location := (location at: 1) substrings: $/.
    location := location collect: [:each | (URL decode: each) ].
    location := location reject: [:each | each isEmpty ]!

extractPostData: clientVersion
    clientVersion ~= '1.0'
	ifTrue: [ stream nextPut: 'HTTP/1.1 100 Continue'; nl; nl ].

    (self at: #'CONTENT-TYPE' ifAbsent: [ nil ]) ~=
	'application/x-www-form-urlencoded' ifTrue: [ ^self ].

    ^self extractQueryData: (stream upTo: Character cr)!

extractQueryData: query
    (query substrings: $&) do: [ :each || pair |
	pair := each substrings: $=.
	self
	    postDataAt: (URL decode: pair first) asSymbol
	    put: (URL decode: pair last)
    ]!

postDataAt: aSymbol put: aValue
    ^postData at: aSymbol put: aValue! !



!ErrorServlet methodsFor: 'interaction'!

respondTo: aRequest
    | response |
    response := parent components isEmpty
	ifFalse: [ ErrorResponse notFound ]
	ifTrue: [ ErrorResponse unavailable ].

    (#('HEAD' 'GET' 'POST') includes: aRequest action)
	ifFalse: [ response := ErrorResponse
	    acceptableMethods: #('HEAD' 'GET' 'POST') ].

    response respondTo: aRequest! !


!ErrorResponse class methodsFor: 'initialize'!

three
    ^#(	(300 'Multiple Choices'
    
'<P>The requested resource corresponds to any one of a set of
representations. You can select a preferred representation.</P>')

	(301 'Moved Permanently'
	
'<P>The requested resource has been assigned a new permanent URL
and any future references to this resource should be done using
one of the returned URLs.</P>')

	(302 'Moved Temporarily'
	
'<P>The requested resource resides temporarily under a different
URI.  This is likely to be a response to a POST request which
has to retrieve a fixed entity, since many clients do not interpret
303 responses (See Other) correctly.</P>')

	(303 'See Other'
	
'<P>The response to the request can be found under a different
URL and should be retrieved using the supplied Location.</P>')

	(304 'Not Modified' '')

	(305 'Use Proxy'
	
'<P>The requested resource must be accessed through the proxy given by
the Location field. </P>'))!

four
    ^#( (400 'Bad Request'

'<P>The request could not be understood by the server due to malformed
syntax.</P>')

	(401 'Unauthorized'

'<P>The request requires user authentication.</P>')

	(402 'Payment Required'

'<P>This code is reserved for future use.</P>')

	(403 'Forbidden'

'<P>The server understood the request, but is refusing to fulfill it.</P>')

	(404 'Not Found'

'<P>The requested URL was not found on this server.</P>')

	(405 'Method Not Allowed'

'<P>The specified method is not allowed for the resource identified by
the specified URL.</P>')

	(406 'Not Acceptable'

'<P>The resource identified by the request is only capable of generating
response entities which have content characteristics not acceptable
according to the accept headers sent in the request.</P>')

	(407 'Proxy Authentication Required'

'<P>To proceed, the client must first authenticate itself with the proxy.</P>')

	(408 'Request Timeout'

'<P>The client did not produce a request within the time that the server
was prepared to wait.</P>')

	(409 'Conflict'

'<P>The request could not be completed due to a conflict with the current
state of the resource. </P>')

	(410 'Gone'

'<P>The requested resource is no longer available at the server and no
forwarding address is known. This condition should be considered
permanent.</P>')

	(411 'Length Required'

'<P>The server refuses to accept the request without a defined
Content-Length header field.</P>')

	(412 'Precondition Failed'

'<P>The precondition given in one or more of the request-header fields
evaluated to false when it was tested on the server.</P>')

	(413 'Request Entity Too Large'

'<P>The server is refusing to process a request because the request
entity is larger than the server is willing or able to process.</P>')

	(414 'Request-URI Too Long'

'<P>The server is refusing to service the request because the requested
URL is longer than the server is willing to interpret. This condition
is most likely due to a client''s improper conversion of a POST request
with long query information to a GET request.</P>')

	(415 'Unsupported Media Type'

'<P>The server is refusing to service the request because the entity of
the request is in a format not supported by the requested resource
for the requested method.</P>'))!

five
    ^#(	(500 'Internal Server Error'

'<P>The server encountered an unexpected condition which prevented it
from fulfilling the request.</P>')

	(501 'Not Implemented'

'<P>The server does not support the functionality required to fulfill the
request. The server does not recognize the request method and is not
capable of supporting it for any resource.</P>')

	(502 'Bad Gateway'

'<P>The server, while acting as a gateway or proxy, received an invalid
response from the upstream server it accessed in attempting to
fulfill the request.</P>')

	(503 'Service Unavailable'

'<P>The server is currently unable to handle the request due to a
temporary overloading or maintenance of the server. This is a temporary
condition.</P>')

	(504 'Gateway Timeout'

'<P>The server, while acting as a gateway or proxy, did not receive a
timely response from the upstream server it accessed in attempting to
complete the request.</P>')

	(505 'HTTP Version Not Supported'

'<P>The server does not support, or refuses to support, the HTTP protocol
version that was used in the request message.</P>'))!

initialize
    ErrorNames := IdentityDictionary new.
    ErrorDescriptions := IdentityDictionary new.
    self initialize: self three.
    self initialize: self four.
    self initialize: self five!

initialize: arrayOfArrays
    arrayOfArrays do: [ :array |
	ErrorNames at: (array at: 1) put: (array at: 2).
	ErrorDescriptions at: (array at: 1) put: (array at: 3)
    ]! !

!ErrorResponse class methodsFor: 'accessing'!

nameAt: error
    ^ErrorNames at: error ifAbsent: [
	(error < 300 or: [ error > 599 ])
	    ifTrue: [ self nameAt: 500 ]
	    ifFalse: [ self nameAt: error // 100 * 100 ]
    ]!

descriptionAt: error
    ^ErrorDescriptions at: error ifAbsent: [
	(error < 300 or: [ error > 599 ])
	    ifTrue: [ self descriptionAt: 500 ]
	    ifFalse: [ self descriptionAt: error // 100 * 100 ]
    ]! !

!ErrorResponse class methodsFor: 'instance creation'!

errorCode: code
    ^self new errorCode: code!

notModified
    ^self errorCode: 304!

noContent
    ^self errorCode: 204!

resetContent
    ^self errorCode: 205!

unavailable
    ^self errorCode: 503!

forbidden
    ^self errorCode: 403!

notFound
    ^self errorCode: 404!

gone
    ^self errorCode: 410!

seeOtherURI: anotherURI
    ^(self errorCode: 303)
	addHeader: 'Location: ', anotherURI;
	yourself!

movedTemporarilyTo: anotherURI
    ^(self errorCode: 302)
	addHeader: 'Location: ', anotherURI;
	yourself!

movedPermanentlyTo: anotherURI
    ^(self errorCode: 301)
	addHeader: 'Location: ', anotherURI;
	yourself!

unauthorized: aString
    ^(self errorCode: 401)
	addHeader: 'WWW-Authenticate: ', aString;
	yourself!

acceptableMethods: anArray
    | header |
    header := String streamContents: [ :s |
	s nextPutAll: 'Allow: '.
	anArray
	    do: [ :each | s nextPutAll: each ]
	    separatedBy: [ s nextPutAll: ', ' ]
    ].
    ^(self errorCode: 405)
	addHeader: header;
	yourself! !


!ErrorResponse methodsFor: 'testing'!

isErrorResponse
    ^true! !

!ErrorResponse methodsFor: 'initialize'!

errorCode: code
    errorCode := code.
    ^self!

addHeader: aString
    additionalHeaders isNil
	ifTrue: [ additionalHeaders := OrderedCollection new ].

    ^additionalHeaders add: aString!

!ErrorResponse methodsFor: 'emit'!

sendResponseType
    self
	<< 'HTTP/1.1 '; << errorCode; space;
	<< (self class nameAt: errorCode); nl
!

sendStandardHeaders
    super sendStandardHeaders.
    additionalHeaders isNil ifTrue: [ ^self ].
    additionalHeaders do: [ :each | self << each; nl ]
!

noMessageBody
    ^#(204 205 304) includes: errorCode
!

sendBody
    | description |
    self noMessageBody ifTrue: [ ^self ].

    description := self class descriptionAt: errorCode.
    description isEmpty ifTrue: [ ^self ].

    self
	<< '<HTML>'; nl;
	<< '<HEAD><TITLE>'; << errorCode; space; << (self class nameAt: errorCode);
	<< '</TITLE></HEAD>'; nl; << '<BODY>'; nl;
	heading: [ self << errorCode; space; << (self class nameAt: errorCode) ];
	<< description;
	<< 'originator: '; << request originator displayString; lineBreak;
	<< 'action: '; << request action displayString; lineBreak;
	<< 'location: '.

    request location do: [:each | self << $/ << each].
    request enumeratePostData: [:key :val | self lineBreak; << key; << ' = '; nl; << val; nl].
    
    self
	lineBreak; horizontalLine; italic: [ self << WebServer version ];
	<< '</BODY></HTML>'! !

!WebAuthorizer class methodsFor: 'private'!

fromString: aString
    ^self new
	authorizer: aString!

loginID: aLoginID password: aPassword
    ^self new
	loginID: aLoginID password: aPassword; yourself! !

!WebAuthorizer methodsFor: 'accessing'!

authorize: aRequest 
    | trial |
    trial := aRequest at: #AUTHORIZATION ifAbsent: [ nil ].
    ^trial = self authorizer!

authorizer
    ^authorizer!

authorizer: aString
    authorizer := aString!

challengeFor: aServlet
    ^'Basic realm="%1"' bindWith: aServlet name!

authorize: aRequest in: aServlet ifAuthorized: aBlock
    ^(self authorize: aRequest)
	ifTrue: [ aBlock value ]
	ifFalse: [ (ErrorResponse unauthorized: (self challengeFor: aServlet))
	    respondTo: aRequest. ^nil ]! !

!WebAuthorizer methodsFor: 'private'!

loginID: aName password: aPassword 
    "(self loginID: 'aName' password: 'aPassword') authorizer = 
    'Basic YU5hbWU6YVBhc3N3b3Jk'"

    | plain plainSize i chars stream |
    aName isNil | aPassword isNil ifTrue: [^nil].
    chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
    plain := (aName , ':' , aPassword) asByteArray.
    plainSize := plain size.
    (plain size \\ 3 = 0)
	ifFalse: [ plain := plain, (ByteArray new: 3 - (plain size \\ 3)) ].

    i := 1.
    stream := WriteStream on: String new.
    stream nextPutAll: 'Basic '.
    [i < plain size]
	whileTrue: 
	    [stream
		nextPut: (chars at: (plain at: i) // 4 + 1);
		nextPut: (chars at: (plain at: i) \\ 4 * 16 + ((plain at: i + 1) // 16) + 1);
		nextPut: (chars at: (plain at: i + 1) \\ 16 * 4 + ((plain at: i + 2) // 64) + 1);
		nextPut: (chars at: (plain at: i + 2) \\ 64 + 1).
	    i := i + 3].
    
    authorizer := stream contents.
    i := authorizer size.
    plain size - plainSize
	timesRepeat: 
	    [authorizer at: i put: $=.
	    i := i - 1]!

!Character methodsFor: 'converting'!

base10DigitValue
    ^self isDigit ifTrue: [ self asciiValue - 48 ] ifFalse: [ 0 ]! !

ErrorResponse initialize!
WebRequest initialize!
