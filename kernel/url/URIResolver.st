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

