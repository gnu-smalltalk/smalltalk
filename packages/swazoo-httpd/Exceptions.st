"======================================================================
|
|   Swazoo 2.1 exceptions
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


Error subclass: HTTPException [
    | response |
    
    <category: 'Swazoo-Exceptions'>
    <comment: 'HTTPException immediatelly returns attached HTTP response to client. That way it is easier to respond with different status codes (like 201 Created). Not only error ones! You can respond somewhere deeply in code of your resource with raising that exception and adding a prepared HTTPResponse. 
This exception is non-resumable!

Example of ways to raise http response (200 Ok):

	HTTPException raiseResponse: (HTTPResponse new code: 200).
	HTTPException raiseResponseCode: 200.
	HTTPException ok.

Instance Variables:
	response	<HTTPResponse>	a response to be sent to client

'>

    HTTPException class >> accepted [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 202)
    ]

    HTTPException class >> badGateway [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 502)
    ]

    HTTPException class >> badRequest [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 400)
    ]

    HTTPException class >> conflict [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 409)
    ]

    HTTPException class >> continue [
	<category: 'responses-informational'>
	^self raiseResponse: (HTTPResponse new code: 100)
    ]

    HTTPException class >> created [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 201)
    ]

    HTTPException class >> expectationFailed [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 416)
    ]

    HTTPException class >> forbidden [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 403)
    ]

    HTTPException class >> found [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 302)
    ]

    HTTPException class >> gatewayTimeout [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 504)
    ]

    HTTPException class >> gone [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 410)
    ]

    HTTPException class >> httpVersionNotSupported [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 505)
    ]

    HTTPException class >> internalServerError [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 500)
    ]

    HTTPException class >> lengthRequired [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 411)
    ]

    HTTPException class >> methodNotAllowed [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 405)
    ]

    HTTPException class >> movedPermanently [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 301)
    ]

    HTTPException class >> multipleChoices [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 300)
    ]

    HTTPException class >> noContent [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 204)
    ]

    HTTPException class >> nonAuthorativeInformation [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 203)
    ]

    HTTPException class >> notAcceptable [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 406)
    ]

    HTTPException class >> notFound [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 404)
    ]

    HTTPException class >> notImplemented [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 501)
    ]

    HTTPException class >> notModified [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 304)
    ]

    HTTPException class >> ok [
	<category: 'responses-succesfull'>
	^self raiseResponse: HTTPResponse ok
    ]

    HTTPException class >> partialContent [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 206)
    ]

    HTTPException class >> paymentRequired [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 402)
    ]

    HTTPException class >> preconditionFailed [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 412)
    ]

    HTTPException class >> proxyAuthenticationRequired [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 407)
    ]

    HTTPException class >> raiseResponseCode: aNumber [
	"Raise an exception to immediatelly return http response with that code"

	<category: 'signalling'>
	^self raiseResponse: (HTTPResponse new code: aNumber)
    ]

    HTTPException class >> requestEntityTooLarge [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 413)
    ]

    HTTPException class >> requestTimeout [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 408)
    ]

    HTTPException class >> requestURITooLong [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 414)
    ]

    HTTPException class >> requestedRangeNotSatisfiable [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 416)
    ]

    HTTPException class >> resetContent [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 205)
    ]

    HTTPException class >> seeOther [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 303)
    ]

    HTTPException class >> serviceUnavailable [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 503)
    ]

    HTTPException class >> switchingProtocols [
	<category: 'responses-informational'>
	^self raiseResponse: (HTTPResponse new code: 101)
    ]

    HTTPException class >> temporaryRedirect [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 307)
    ]

    HTTPException class >> unathorized [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 401)
    ]

    HTTPException class >> unsupportedMediaType [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 415)
    ]

    HTTPException class >> useProxy [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 305)
    ]

    response [
	<category: 'accessing'>
	^response
    ]

    response: aHTTPResponse [
	<category: 'accessing'>
	response := aHTTPResponse
    ]
]



SpError subclass: SwazooHTTPParseError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooHTTPRequestError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SwazooHTTPRequestError subclass: SwazooHTTPPostError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SwazooHTTPRequestError subclass: SwazooHTTPPutError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooHeaderFieldParseError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooSiteError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooStreamNoDataError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



