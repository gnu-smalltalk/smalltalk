Error subclass: XMLStructureException [
    
    <category: 'XMLPullParser'>
    <comment: nil>

]



SAXParser class extend [
    pullParserFactory [
	<category: 'pull parsing'>
	^XMLGenerativePullParser
    ]
]



Stream subclass: XMLPullParser [
    <category: 'XMLPullParser'>
    <comment: 'This is based on Antony Blakey''s XMLPullParser.'>

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
	^self defaultParserClass pullParserFactory on: source
    ]

    XMLPullParser class >> defaultParserClass [
	<category: 'accessing'>
	^SAXParser defaultParserClass
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

    isEndDocument [
	<category: 'testing event types'>
	^self current isEndDocument
    ]

    isEndTag [
	<category: 'testing event types'>
	^self current isEndTag
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing event types'>
	^self current isEndTag: aStringOrNodeTag
    ]

    isPI [
	<category: 'testing event types'>
	^self current isPI
    ]

    isPI: aString [
	<category: 'testing event types'>
	^self current isPI: aString
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
	^self isText 
	    ifTrue: 
		[| text |
		text := self current text.
		self next.
		text]
	    ifFalse: ['']
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
]



SAXDriver subclass: SAXEventGenerator [
    | generator |

    SAXEventGenerator class >> on: aGenerator [
	<category: 'instance creation'>
	^super new generator: aGenerator
    ]

    comment: data from: start to: stop [
        <category: 'other'>

    ]

    characters: aString [
        <category: 'content handler'>

	generator yield: (SAXText text: aString)
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
        ^self
    ]

    processingInstruction: targetString data: dataString [
        <category: 'content handler'>

	generator yield: (SAXProcessingInstruction target: targetString data: dataString)
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
        ^self
    ]

    notationDecl: nameString publicID: publicIDString systemID: systemIDString [
        <category: 'DTD handler'>

    ]

    unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation [
        <category: 'DTD handler'>
        ^self
    ]

    resolveEntity: publicID systemID: systemID [
        <category: 'entity resolver'>
        ^nil
    ]

    generator: aGenerator [
	<category: 'initialize'>
	generator := aGenerator
    ]
]



XMLPullParser subclass: XMLGenerativePullParser [
    | parser generator |
    
    <category: 'XMLPullParser'>
    <comment: 'This is based on Antony Blakey''s XMLPullParser.'>

    XMLGenerativePullParser class >> on: source [
	^self onParser:
	    (self defaultParserClass on: source)
    ]

    XMLGenerativePullParser class >> onParser: aParser [
	<category: 'instance creation'>
	| class |
	^self new
	    initialize: aParser;
	    yourself
    ]

    XMLGenerativePullParser class >> isCharEscape: aChar [
	<category: 'accessing'>
	^CharEscapes includes: aChar
    ]

    atEnd [
	<category: 'streaming'>
	^self isEndDocument
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

    validate: aBoolean [
	<category: 'core api'>
	parser validate: aBoolean
    ]

    next [
	<category: 'core api'>
	self atEnd ifTrue: [ ^self pastEnd ].
	^generator next; peek
    ]
]
