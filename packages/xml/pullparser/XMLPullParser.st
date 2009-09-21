"======================================================================
|
|   SAX event-based pull parser
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2009, Antony Blakey
| All rights reserved.
| 
| Redistribution and use in source and binary forms, with or without
| modification, are permitted provided that the following conditions
| are met:
|     * Redistributions of source code must retain the above copyright
|       notice, this list of conditions and the following disclaimer.
|     * Redistributions in binary form must reproduce the above copyright
|       notice, this list of conditions and the following disclaimer in the
|       documentation and/or other materials provided with the distribution.
|     * Neither the name of Antony Blakey nor the names of its contributors
|       may be used to endorse or promote products derived derived from
|       this software without specific prior written permission.
| 
| THIS SOFTWARE IS PROVIDED 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES,
| INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
| AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
| ANTONY BLAKEY BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
| SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
| TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
| PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
| LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
| SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|
 ======================================================================"

Error subclass: XMLStructureException [
    
    <category: 'XMLPullParser'>
    <comment: nil>

]



Notification subclass: XMLResolveEntityNotification [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    | publicID systemID |

    publicID [
	<category: 'accessing'>
	^publicID
    ]

    publicID: aString [
	<category: 'accessing'>
	publicID := aString
    ]

    systemID [
	<category: 'accessing'>
	^systemID
    ]

    systemID: aString [
	<category: 'accessing'>
	systemID := aString
    ]
]



SAXParser class extend [
    pullParserOn: source [
	<category: 'pull parsing'>
	^XMLGenerativePullParser on: source for: self
    ]
]



Stream subclass: XMLPullParser [
    <category: 'XMLPullParser'>
    <comment: 'This is based on Antony Blakey''s XMLPullParser.'>

    | needComments needPrefixMappingEvents needCdataDelimiters needDTDEvents |

    XMLPullParser class >> new [
        <category: 'instance creation'>
        ^super new initialize
    ]

    XMLPullParser class >> onFile: aFilename [
        <category: 'instance creation'>
        ^self on: (FileStream open: aFilename mode: FileStream read)
    ]

    XMLPullParser class >> onString: aString [
        <category: 'instance creation'>
        ^self on: aString readStream
    ]

    XMLPullParser class >> on: source [
	<category: 'instance creation'>
	^SAXParser defaultParserClass pullParserOn: source
    ]

    advance [
	<category: 'core api'>
	self subclassResponsibility
    ]

    at: attName [
	<category: 'delegating accessors'>
	^self current at: attName
    ]

    at: attName ifFound: aFoundBlock ifNone: aBlock [
	<category: 'delegating accessors'>
	^self current 
	    at: attName
	    ifFound: aFoundBlock
	    ifNone: aBlock
    ]

    at: attName ifNone: aBlock [
	<category: 'delegating accessors'>
	^self current at: attName ifNone: aBlock
    ]

    atEnd [
	<category: 'streaming'>
	^self isEndDocument
    ]

    collect: tagName peek: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self while: tagName peek: [result add: (self matchAnyPeek: aBlock)].
	^result
    ]

    collect: tagName take: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self while: tagName peek: [result add: (self matchAnyTake: aBlock)].
	^result
    ]

    collectAnyPeek: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self whileAnyPeek: [result add: (self matchAnyPeek: aBlock)].
	^result
    ]

    collectAnyTake: aBlock [
	<category: 'tag-based api'>
	| result |
	result := OrderedCollection new.
	self whileAnyTake: [result add: (self matchAnyPeek: aBlock)].
	^result
    ]

    consumeEndTag [
	<category: 'consuming events'>
	self mustBeEndTag.
	self next
    ]

    consumeEndTag: tagName [
	<category: 'consuming events'>
	self mustBeEndTag: tagName.
	self next
    ]

    consumeStartDocument [
	<category: 'consuming events'>
	self mustBeStartDocument.
	self next
    ]

    consumeStartTag [
	<category: 'consuming events'>
	self mustBeStartTag.
	self next
    ]

    consumeStartTag: tagName [
	<category: 'consuming events'>
	self mustBeStartTag: tagName.
	self next
    ]

    consumeText [
	<category: 'consuming events'>
	| text |
	self isText 
	    ifTrue: 
		[self mustBeText.
		text := self current text.
		self next.
		^text]
	    ifFalse: [^'']
    ]

    current [
	<category: 'core api'>
	self subclassResponsibility
    ]

    do: aBlock [
	<category: 'core api'>
	self atEnd ifTrue: [^self].
	aBlock value: self current.
	super do: aBlock
    ]

    doctypeName [
	<category: 'delegating accessors'>
	^self isStartDoctypeDecl 
	    ifTrue: 
		[| name |
		name := self current name.
		self needDTDEvents: false.
		self next.
		name asString]
	    ifFalse: [nil]
    ]

    if: tagName peek: aBlock [
	<category: 'tag-based api'>
	(self is: tagName) ifTrue: [self matchAnyPeek: aBlock]
    ]

    if: tagName peek: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^(self is: tagName) 
	    ifTrue: [self matchAnyPeek: aBlock]
	    ifFalse: [elseBlock value]
    ]

    if: tagName take: aBlock [
	<category: 'tag-based api'>
	(self is: tagName) ifTrue: [self matchAnyTake: aBlock]
    ]

    if: tagName take: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^(self is: tagName) 
	    ifTrue: [self matchAnyTake: aBlock]
	    ifFalse: [elseBlock value]
    ]

    ifAnyPeek: aBlock [
	<category: 'tag-based api'>
	self isStartTag ifTrue: [self matchAnyPeek: aBlock]
    ]

    ifAnyPeek: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^self isStartTag 
	    ifTrue: [self matchAnyPeek: aBlock]
	    ifFalse: [elseBlock value]
    ]

    ifAnyTake: aBlock [
	<category: 'tag-based api'>
	self isStartTag ifTrue: [self matchAnyTake: aBlock]
    ]

    ifAnyTake: aBlock else: elseBlock [
	<category: 'tag-based api'>
	^self isStartTag 
	    ifTrue: [self matchAnyTake: aBlock]
	    ifFalse: [elseBlock value]
    ]

    is: tagName [
	<category: 'testing event types'>
	^self isStartTag: tagName
    ]

    isComment [
	<category: 'testing event types'>
	^self current isComment
    ]

    isEndCdataSection [
	<category: 'testing event types'>
	^self current isEndCdataSection
    ]

    isEndDocument [
	<category: 'testing event types'>
	^self current isEndDocument
    ]

    isEndPrefixMapping [
	<category: 'testing event types'>
	^self current isEndPrefixMapping
    ]

    isEndTag [
	<category: 'testing event types'>
	^self current isEndTag
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing event types'>
	^self current isEndTag: aStringOrNodeTag
    ]

    isNotationDecl [
	<category: 'testing event types'>
	^self current isNotationDecl
    ]

    isSkippedEntity [
	<category: 'testing event types'>
	^self current isSkippedEntity
    ]

    isPI [
	<category: 'testing event types'>
	^self current isPI
    ]

    isPI: aString [
	<category: 'testing event types'>
	^self current isPI: aString
    ]

    isStartCdataSection [
	<category: 'testing event types'>
	^self current isStartCdataSection
    ]

    isStartPrefixMapping [
	<category: 'testing event types'>
	^self current isStartPrefixMapping
    ]

    isStartDoctypeDecl [
	<category: 'testing event types'>
	^self current isStartDoctypeDecl
    ]

    isStartDoctypeDecl: aString [
	<category: 'testing event types'>
	^self current isStartDoctypeDecl: aString
    ]

    isStartDocument [
	<category: 'testing event types'>
	^self current isStartDocument
    ]

    isStartTag [
	<category: 'testing event types'>
	^self current isStartTag
    ]

    isStartTag: aStringOrNodeTag [
	<category: 'testing event types'>
	^self current isStartTag: aStringOrNodeTag
    ]

    isText [
	<category: 'testing event types'>
	^self current isText
    ]

    isUnparsedEntityDecl [
	<category: 'testing event types'>
	^self current isUnparsedEntityDecl
    ]

    match: tagName peek: aBlock [
	<category: 'tag-based api'>
	self mustBeStartTag: tagName.
	^self matchAnyPeek: aBlock
    ]

    match: tagName take: aBlock [
	<category: 'tag-based api'>
	self mustBeStartTag: tagName.
	^self matchAnyTake: aBlock
    ]

    matchAnyPeek: aBlock [
	<category: 'tag-based api'>
	self mustBeStartTag.
	^aBlock numArgs = 1 
	    ifTrue: [aBlock value: self current]
	    ifFalse: [aBlock value]
    ]

    matchAnyTake: aBlock [
	<category: 'tag-based api'>
	| result |
	result := aBlock numArgs = 1 
		    ifTrue: 
			[| tag |
			tag := self current.
			self consumeStartTag.
			aBlock value: tag]
		    ifFalse: 
			[self consumeStartTag.
			aBlock value].
	self consumeEndTag.
	^result
    ]

    mustBeEndDocument [
	<category: 'asserting event types'>
	self isEndDocument 
	    ifFalse: [XMLStructureException signal: 'Expected end of document']
    ]

    mustBeEndTag [
	<category: 'asserting event types'>
	self isEndTag 
	    ifFalse: [XMLStructureException signal: 'Expected end tag']
    ]

    mustBeEndTag: tagName [
	<category: 'asserting event types'>
	(self isEndTag: tagName) 
	    ifFalse: [XMLStructureException signal: 'Expected end tag: ' , tagName]
    ]

    mustBePI [
	<category: 'asserting event types'>
	self isPI 
	    ifFalse: [XMLStructureException signal: 'Expected processing instruction']
    ]

    mustBePI: tagName [
	<category: 'asserting event types'>
	(self isPI: tagName) 
	    ifFalse: [XMLStructureException signal: 'Expected processing instruction: ' , tagName]
    ]

    mustBeStartDocument [
	<category: 'asserting event types'>
	self isStartDocument 
	    ifFalse: [XMLStructureException signal: 'Expected start of document']
    ]

    mustBeStartTag [
	<category: 'asserting event types'>
	self isStartTag 
	    ifFalse: [XMLStructureException signal: 'Expected start tag']
    ]

    mustBeStartTag: tagName [
	<category: 'asserting event types'>
	(self isStartTag: tagName) 
	    ifFalse: [XMLStructureException signal: 'Expected start tag: ' , tagName]
    ]

    mustBeText [
	<category: 'asserting event types'>
	self isText ifFalse: [XMLStructureException signal: 'Expected text']
    ]

    next [
	<category: 'core api'>
	| event |
	self atEnd ifTrue: [ ^self pastEnd ].
	[
	    self advance.
	    (event := self current) neededBy: self
	] whileFalse.
	^event
    ]

    pastEnd [
	<category: 'core api'>
	^self current
    ]

    serializeTagContentsTo: serializer [
	<category: 'serializing'>
	self consumeStartTag.
	self serializeUntilEndTagTo: serializer.
	self consumeEndTag
    ]

    serializeTagTo: serializer [
	<category: 'serializing'>
	self mustBeStartTag.
	self current serializeTo: serializer.
	self consumeStartTag.
	self serializeUntilEndTagTo: serializer.
	self current serializeTo: serializer.
	self consumeEndTag
    ]

    serializeUntilEndTagTo: serializer [
	<category: 'serializing'>
	[self isEndTag] whileFalse: 
		[| event |
		event := self current.
		event isText 
		    ifTrue: 
			[event serializeTo: serializer.
			self next]
		    ifFalse: 
			[event isStartTag 
			    ifTrue: [self serializeTagTo: serializer]
			    ifFalse: [XMLStructureException signal: 'Unexpected element']]]
    ]

    skip: tagName [
	<category: 'tag-based api'>
	self consumeStartTag: tagName.
	[self isEndTag] whileFalse: 
		[| event |
		event := self current.
		event isText 
		    ifTrue: [self next]
		    ifFalse: 
			[event isStartTag 
			    ifTrue: [self skipAny]
			    ifFalse: [XMLStructureException signal: 'Unexpected element']]].
	self consumeEndTag: tagName
    ]

    skipAny [
	<category: 'tag-based api'>
	self consumeStartTag.
	[self isEndTag] whileFalse: 
		[| event |
		event := self current.
		event isText 
		    ifTrue: [self next]
		    ifFalse: 
			[event isStartTag 
			    ifTrue: [self skipAny]
			    ifFalse: [XMLStructureException signal: 'Unexpected element']]].
	self consumeEndTag
    ]

    skipIf: tagName [
	<category: 'tag-based api'>
	(self is: tagName) ifTrue: [self skipAny]
    ]

    skipIfAny [
	<category: 'tag-based api'>
	self isStartTag ifTrue: [self skipAny]
    ]

    skipWhile: tagName [
	<category: 'tag-based api'>
	[self is: tagName] whileTrue: [self skipAny]
    ]

    skipWhileAny [
	<category: 'tag-based api'>
	[self isStartTag] whileTrue: [self skipAny]
    ]

    tag [
	<category: 'delegating accessors'>
	^self current tag
    ]

    text [
	<category: 'delegating accessors'>
	| text s |
	self isText ifFalse: [ ^'' ].

	text := self current text.
	self next isText ifFalse: [ ^text ].

	s := WriteStream with: text.
	[s nextPutAll: self current text.
	self next isText] whileTrue.
	^s contents
    ]

    textIf: tagName [
	<category: 'tag-based api'>
	^self 
	    if: tagName
	    take: [self text]
	    else: ['']
    ]

    textIf: tagName else: aBlock [
	<category: 'tag-based api'>
	^self 
	    if: tagName
	    take: [self text]
	    else: [aBlock value]
    ]

    textIfAny [
	<category: 'tag-based api'>
	^self ifAnyTake: [self text] else: ['']
    ]

    textIfAnyElse: aBlock [
	<category: 'tag-based api'>
	^self ifAnyTake: [self text] else: [aBlock value]
    ]

    textOf: tagName [
	<category: 'tag-based api'>
	^self match: tagName take: [self text]
    ]

    textOfAny [
	<category: 'tag-based api'>
	^self matchAnyTake: [self text]
    ]

    while: tagName peek: aBlock [
	<category: 'tag-based api'>
	[self is: tagName] whileTrue: [self matchAnyPeek: aBlock]
    ]

    while: tagName peek: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self is: tagName] whileTrue: 
		[doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		self matchAnyPeek: aBlock]
    ]

    while: tagName take: aBlock [
	<category: 'tag-based api'>
	[self is: tagName] whileTrue: [self matchAnyTake: aBlock]
    ]

    while: tagName take: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self is: tagName] whileTrue: 
		[| tag |
		tag := self current.
		self consumeStartTag.
		doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value].
		self consumeEndTag]
    ]

    whileAnyPeek: aBlock [
	<category: 'tag-based api'>
	[self isStartTag] whileTrue: [self matchAnyPeek: aBlock]
    ]

    whileAnyPeek: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self isStartTag] whileTrue: 
		[| tag |
		tag := self current.
		doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value]]
    ]

    whileAnyTake: aBlock [
	<category: 'tag-based api'>
	[self isStartTag] whileTrue: [self matchAnyTake: aBlock]
    ]

    whileAnyTake: aBlock separatedBy: sepBlock [
	<category: 'tag-based api'>
	| doneFirst |
	doneFirst := false.
	[self isStartTag] whileTrue: 
		[| tag |
		tag := self current.
		self consumeStartTag.
		doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
		aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value].
		self consumeEndTag]
    ]

    validate [
	<category: 'core api'>
	^false
    ]

    validate: aBoolean [
	<category: 'core api'>
	aBoolean ifTrue: [
	    self error: 'this parser does not support XML validation' ]
    ]

    initialize [
	<category: 'initialize'>
	needComments := needPrefixMappingEvents := needCdataDelimiters := false.
	needDTDEvents := true.
    ]

    needCdataDelimiters [
	<category: 'accessing'>
	^needCdataDelimiters
    ]

    needCdataDelimiters: aBoolean [
	<category: 'accessing'>
	needCdataDelimiters := aBoolean
    ]

    needComments [
	<category: 'accessing'>
	^needComments
    ]

    needComments: aBoolean [
	<category: 'accessing'>
	needComments := aBoolean
    ]

    needDTDEvents [
	<category: 'accessing'>
	^needDTDEvents
    ]

    needDTDEvents: aBoolean [
	<category: 'accessing'>
	needDTDEvents := aBoolean
    ]

    needPrefixMappingEvents [
	<category: 'accessing'>
	^needPrefixMappingEvents
    ]

    needPrefixMappingEvents: aBoolean [
	<category: 'accessing'>
	needPrefixMappingEvents := aBoolean
    ]
]



SAXEvent extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^true
    ]
]



SAXEndCdataSection extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needCdataDelimiters
    ]
]





SAXStartCdataSection extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needCdataDelimiters
    ]
]





SAXUnparsedEntityDecl extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needDTDEvents
    ]
]





SAXNotationDecl extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needDTDEvents
    ]
]





SAXEndDoctypeDecl extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needDTDEvents
    ]
]





SAXStartDoctypeDecl extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needDTDEvents
    ]
]





SAXComment extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needComments
    ]
]



SAXEndPrefixMapping extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needPrefixMappingEvents
    ]
]



SAXStartPrefixMapping extend [
    neededBy: aParser [
        <category: 'pull parsing'>

	^aParser needPrefixMappingEvents
    ]
]



SAXDriver subclass: SAXEventGenerator [
    | generator |

    SAXEventGenerator class >> on: aGenerator [
	<category: 'instance creation'>
	^super new generator: aGenerator
    ]

    comment: aString from: start to: stop [
        <category: 'other'>

	generator yield: (SAXComment text: aString from: start to: stop)
    ]

    characters: aString from: start to: stop [
        <category: 'content handler'>

	generator yield: (SAXText text: aString from: start to: stop)
    ]

    endCdataSection [
        <category: 'content handler'>

	generator yield: SAXEndCdataSection new
    ]

    endDoctypeDecl [
        <category: 'content handler'>

	generator yield: SAXEndDoctypeDecl new
    ]

    endDocument [
        <category: 'content handler'>

	generator yield: SAXEndDocument new
    ]

    endElement: namespaceURI localName: localName qName: name [
        "indicates the end of an element. See startElement"

        <category: 'content handler'>
	| tag |
        tag := NodeTag name: name ns: namespaceURI type: localName.
	generator yield: (SAXEndTag tag: tag)

    ]

    endPrefixMapping: prefix [
        <category: 'content handler'>
	generator yield: (SAXEndPrefixMapping prefix: prefix)
    ]

    processingInstruction: targetString data: dataString [
        <category: 'content handler'>

	generator yield: (SAXProcessingInstruction target: targetString data: dataString)
    ]

    skippedEntity: aString [
        <category: 'content handler'>

	generator yield: (SAXSkippedEntity name: aString)
    ]

    startCdataSection [
        <category: 'content handler'>

	generator yield: SAXStartCdataSection new
    ]

    startDoctypeDecl: doctypeName publicID: publicID systemID: systemID hasInternalSubset: aBoolean [
        <category: 'content handler'>

	generator yield: (SAXStartDoctypeDecl
	    name: doctypeName
	    publicID: publicID
	    systemID: systemID
	    hasInternalSubset: aBoolean)
    ]

    startDocument [
        <category: 'content handler'>

	generator yield: SAXStartDocument new
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attrArray [
	| tag attributes |
        tag := NodeTag name: name ns: namespaceURI type: localName.
	generator yield: (SAXStartTag tag: tag attributesArray: attrArray)
    ]

    startPrefixMapping: prefix uri: uri [
        <category: 'content handler'>

	generator yield: (SAXStartPrefixMapping prefix: prefix uri: uri)
    ]

    notationDecl: nameString publicID: publicIDString systemID: systemIDString [
        <category: 'DTD handler'>

	generator yield: (SAXNotationDecl name: nameString publicID: publicIDString systemID: systemIDString)
    ]

    unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation [
        <category: 'DTD handler'>

	generator yield: (SAXUnparsedEntityDecl name: name publicID: publicID systemID: systemID notationName: notation)
    ]

    resolveEntity: publicID systemID: systemID [
        <category: 'entity resolver'>
        ^XMLResolveEntityNotification new
	    publicID: publicID;
	    systemID: systemID;
	    signal
    ]

    generator: aGenerator [
	<category: 'initialize'>
	generator := aGenerator.
    ]
]



XMLPullParser subclass: XMLGenerativePullParser [
    | parser generator |
    
    <category: 'XMLPullParser'>
    <comment: 'This is based on Antony Blakey''s XMLPullParser.'>

    XMLGenerativePullParser class >> on: source [
	<category: 'instance creation'>
	^self on: source for: SAXParser defaultParserClass
    ]

    XMLGenerativePullParser class >> on: source for: aParserClass [
	<category: 'instance creation'>
	^self onParser: (aParserClass on: source)
    ]

    XMLGenerativePullParser class >> onParser: aParser [
	<category: 'instance creation'>
	| class |
	^super new
	    initialize: aParser;
	    yourself
    ]

    current [
	<category: 'core api'>
	^generator peek
    ]

    initialize: aParser [
	<category: 'initialize-release'>
	parser := aParser.
	generator := Generator on: [ :g |
	    parser saxDriver: (SAXEventGenerator on: g).
	    parser scanDocument ].
    ]

    validate [
	<category: 'core api'>
	^parser validate
    ]

    validate: aBoolean [
	<category: 'core api'>
	parser validate: aBoolean
    ]

    advance [
	<category: 'private api'>
	^generator next
    ]
]
