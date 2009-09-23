"======================================================================
|
|   Expat-based pull parser
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



Object subclass: SAXEventSequence [
    | event next |

    <category: 'XML-Expat'>
    <comment: 'I represent a circular linked list used when expat
communicates more than one event between its resumption and when it
is stopped again.'>

    SAXEventSequence class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    event [
	<category: 'accessing'>
	^event
    ]

    event: anObject [
	<category: 'accessing'>
	event := anObject
    ]

    initialize [
	<category: 'initialization'>
	next := self.
    ]

    isEmpty [
	<category: 'testing'>
	^next == self
    ]

    next [
	<category: 'accessing'>
	^next
    ]

    next: aSAXList [
	<category: 'accessing'>
	next := aSAXList.
    ]
]



CObject subclass: XMLExpatParserObject [

    <category: 'XML-Expat'>
    <comment: 'I wrap an expat XML_Parser object.  The creation is
mediated by the C support module, so that the appropriate event
handlers are set.'>

    XMLExpatParserObject class >> errorString: code [
	<category: 'C callouts'>
	<cCall: 'XML_ErrorString' returning: #string args: #(#int)>
    ]

    XMLExpatParserObject class >> createFor: anObject [
	<category: 'C callouts'>
	<cCall: 'gst_XML_ParserCreate' returning: #{XMLExpatParserObject}
	    args: #(#smalltalk)>
    ]

    externalEntityParser: contextString encoding: aString [
	<category: 'C callouts'>
	<cCall: 'XML_ExternalEntityParserCreate'
	    returning: #{XMLExpatParserObject} args: #(#self #string #unknown)>
    ]

    free [
	<category: 'C callouts'>
	<cCall: 'XML_ParserFree' returning: #void args: #(#self)>
    ]

    parse: aString len: len isFinal: aBoolean [
	<category: 'C callouts'>
	<cCall: 'XML_Parse' returning: #int args: #(#self #string #int #boolean)>
    ]

    errorCode [
	<category: 'C callouts'>
	<cCall: 'XML_GetErrorCode' returning: #int args: #(#self)>
    ]

    errorString [
	<category: 'error reporting'>
	^self class errorString: self errorCode
    ]

    resume [
	<category: 'C callouts'>
	<cCall: 'XML_ResumeParser' returning: #int args: #(#self)>
    ]

    userData [
	<category: 'C macros'>
	^(self castTo: ##(CObject type ptrType)) value
    ]

    userData: aCObject [
	<category: 'C callouts'>
	<cCall: 'XML_SetUserData' returning: #void args: #(#self #unknown)>
    ]
]



SAXExternalDecl subclass: SAXExternalEntityRef [
    | context |

    <category: 'XML-Expat'>
    <comment: 'This is a dummy event used to trigger creation of a
nested parser.  It is never pushed down; it is only used to trigger
the XMLResolveEntityNotification.'>

    neededBy: aParser [
	<category: 'entity resolution'>
	| entity |
        entity := XMLResolveEntityNotification new
	    publicID: self publicID;
	    systemID: self systemID;
	    signal.
	entity isNil ifFalse: [ aParser push: entity stream context: context ].
	^false
    ]

    serializeTo: sax [
	^sax resolveEntity: self publicID systemID: self systemID
    ]
]



XMLPullParser subclass: ExpatXMLPullParser [
    <category: 'XML-Expat'>
    <comment: 'This is a pull parser wrapping the expat library.
expat parsers are "push" style, but we change it to "pull" using
XML_StopParser in order to avoid complicating the code with callbacks
from C to Smalltalk.'>

    | xp nextParser current pending source sourceStack buffer first |

    ExpatXMLPullParser class >> on: source [
	<category: 'instance creation'>
	^self new initialize: source
    ]

    atEnd [
	<category: 'core api'>
	^source isNil
    ]

    current [
	<category: 'core api'>
	^current
    ]

    initialize: aSource [
	<category: 'initialize-release'>
	| input uri |
        input := (aSource isKindOf: Stream)
                    ifTrue:
                        [uri := [NetClients.URL fromString: aSource name] on: Error
                                    do: [:ex | ex return: nil].
                        InputSource
                            uri: uri
                            encoding: nil
                            stream: aSource]
                    ifFalse: [InputSource for: aSource].

	sourceStack := OrderedCollection new.
	source := input stream.

	buffer := String new: 1024.
	xp := XMLExpatParserObject createFor: self.
	self addToBeFinalized.

	"Insert the first event."
	pending := SAXEventSequence new.
	current := SAXStartDocument new.
	first := true.
    ]

    finalize [
	"Free the whole parser chain."

	<category: 'finalization'>
	[ xp isNil ] whileFalse: [ self pop ]
    ]

    push: aStream context: context [
	"Push a new parser for the given stream.  The context comes
	 from the ExternalEntityRefHandler and is passed down to
	 XML_ExternalEntityParserCreate."

	<category: 'entity resolution'>
	| userData |
	sourceStack add: source.
	source := aStream.
	first := true.

	"The userData of suspended parsers constitutes a list of parsers,
	 with nextParser as the head."
	userData := xp userData.
	xp userData: nextParser.
	nextParser := xp.

	xp := xp externalEntityParser: context encoding: nil.

	"Move the suspended parser's userData to the new one."
	xp userData: userData.
    ]

    pop [
	"Switch back to the parent parser of XP, which is stored
	 in nextParser."

	<category: 'entity resolution'>
	| userData oldParser |
	oldParser := xp.
	xp := nextParser.
	xp isNil
	    ifTrue: [
		self removeToBeFinalized.
		source := nil.
		current := SAXEndDocument new ]
	    ifFalse: [
	        source := sourceStack removeLast.
	        nextParser := xp userData ifNotNil: [ :u |
		    u castTo: XMLExpatParserObject type ].
	        xp userData: self ].
	oldParser free.
    ]

    parseMore [
	"Pass data from the source to the XML_Parser."

	<category: 'parsing'>
	| len |
	len := source nextAvailable: buffer size into: buffer startingAt: 1.
	^xp
	    parse: buffer
	    len: len
	    isFinal: source atEnd
    ]

    raiseError [
	"Convert an Expat error to a Smalltalk exception."

	<category: 'parsing'>
	| code |
	code := xp errorCode.
	code = 3
	    ifTrue: [ EmptySignal signal ]
	    ifFalse: [ MalformedSignal signal: (xp class errorString: code) ].

	self removeToBeFinalized; finalize
    ]

    advance [
	"Call the underlying parser, retrieving events and popping the
	 current parser when the data source is exhausted."

	<category: 'private api'>
	| result |
	"First try removing the head of the pending event queue.
	 PENDING points to the tail of a circular list, and is
	 just a sentinel node."
	pending isEmpty ifFalse: [
	    current := pending next event.
	    pending next event: nil.
	    pending next: pending next next.
	    ^self ].

	"See if we're done."
	self atEnd ifTrue: [^self].

	"Start parsing.  On the first call we need to do #parseMore."
	current := nil. 
	result := first
	    ifTrue: [ first := false. self parseMore ]
	    ifFalse: [ xp resume ].

	[ result = 2 ] whileFalse: [
	    result = 0 ifTrue: [ ^self raiseError; current ].
	    result := source atEnd
		ifTrue: [
		    self pop. 
		    current isNil ifFalse: [ 2 ] ifTrue: [ xp resume ] ]
		ifFalse: [ self parseMore ]
	].
	^current
    ]
]
