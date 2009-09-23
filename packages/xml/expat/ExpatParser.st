"======================================================================
|
|   Push adaptor for Expat XML Parser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



SAXParser subclass: ExpatXMLParser [
    | pullParser |
    
    <comment: 'A push parser based on Expat.  This uses the pull
parser and serializes the events to the SAX driver.'>
    <category: 'XML-XML-Parsing'>

    ExpatXMLParser class >> pullParserOn: dataSource [
	"Use the expat pull parser directly, without going through
	 pull on push on pull... which we do for the test suite! :-)"

	<category: 'instance creation'>
	^ExpatXMLPullParser on: dataSource
    ]

    on: dataSource [
	"The dataSource may be a URI, a Filename (or a String
	 which will be treated as a Filename), or an InputSource."

	<category: 'initialize'>
	super on: dataSource.

	"As the underlying parser we use the event-based Expat bindings.
	 We need to get all the events in order to pass them to the user's
	 own driver."
	pullParser := ExpatXMLPullParser on: dataSource.
	pullParser needComments: true.
	pullParser needDTDEvents: true.
	pullParser needCdataDelimiters: true.
	pullParser needPrefixMappingEvents: true.
    ]

    scanDocument [
	"Serialize the events from the pull parser to the SAX driver."

	<category: 'api'>
	[pullParser do: [ :event | event serializeTo: sax]]
		on: XMLResolveEntityNotification
		do: [ :e | e resume:
		    (sax resolveEntity: e publicID systemID: e systemID) ];

		on: MalformedSignal, BadCharacterSignal
		do: [ :e | sax fatalError: e ];

		on: InvalidSignal
		do: [ :e | sax nonFatalError: e ];

		on: WarningSignal
		do: [ :e | sax warning: e ]
    ]
]


Eval [
    SAXParser defaultParserClass isNil
	ifTrue: [SAXParser defaultParserClass: ExpatXMLParser].
]

