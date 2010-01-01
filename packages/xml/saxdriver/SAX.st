"======================================================================
|
|   VisualWorks XML Framework - SAX interface
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000, 2002 Cincom, Inc.
| Copyright (c) 2009 Free Software Foundation, Inc.
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



Object subclass: SAXDriver [
    | locator |
    
    <category: 'XML-XML-SAX'>
    <comment: '
This class includes supports for the Simple API for XML (SAX), an
event-driven API for parsing XML documents.

All methods defined in this class, other than those defined in the
"private" protocol, are Smalltalk-equivalent bindings of the SAX 2.0
API, and can be overridden according to the needs of subclasses.

Instance Variables:
    locator	<nil> place holder for SAX''s Locator, which allows better error recovery.'>

    comment: data from: start to: stop [
	<category: 'other'>
	
    ]

    idOfElement: elementID [
	"Notify the client what was the ID of the latest startElement"

	<category: 'other'>
	
    ]

    sourcePosition: position inStream: streamWrapper [
	"Non-standard API to ease transition from
	 builders to SAX."

	<category: 'other'>
	
    ]

    characters: aString [
	<category: 'content handler'>
	
    ]

    characters: aString from: start to: stop [
	<category: 'content handler'>
	^self characters: (aString copyFrom: start to: stop)
    ]

    endCdataSection [
	<category: 'content handler'>
	
    ]

    endDoctypeDecl [
	<category: 'DTD handler'>
	
    ]

    endDocument [
	<category: 'content handler'>
	
    ]

    endDocumentFragment [
	"Nonstandard extension to SAX"

	<category: 'content handler'>
	
    ]

    endElement: namespaceURI localName: localName qName: name [
	"indicates the end of an element. See startElement"

	<category: 'content handler'>
	
    ]

    endPrefixMapping: prefix [
	"End the scope of a prefix-URI mapping.
	 
	 See startPrefixMapping for details. This event will always
	 occur after the corresponding endElement event, but the
	 order of endPrefixMapping events is not otherwise
	 guaranteed.
	 
	 Parameters:
	 prefix - The prefix that was being mapped.
	 "

	<category: 'content handler'>
	^self
    ]

    ignorableWhitespace: aString [
	<category: 'content handler'>
	
    ]

    ignorableWhitespace: aString from: start to: stop [
	<category: 'content handler'>
	^self ignorableWhitespace: (aString copyFrom: start to: stop)
    ]

    processingInstruction: targetString data: dataString [
	<category: 'content handler'>
	
    ]

    setDocumentLocator: aLocator [
	<category: 'content handler'>
	locator := aLocator
    ]

    skippedEntity: name [
	"Receive notification of a skipped entity.
	 
	 The Parser will invoke this method once for each entity skipped.
	 Non-validating processors may skip entities if they have not seen
	 the declarations (because, for example, the entity was declared
	 in an external DTD subset).
	 
	 Parameters:
	 name - The name of the skipped entity. If it is a parameter
	 entity, the name will begin with '%', and if it is the external
	 DTD subset, it will be the string '[dtd]'.
	 "

	<category: 'content handler'>
	^self
    ]

    startCdataSection [
	<category: 'content handler'>
	
    ]

    startDoctypeDecl: doctypeName publicID: publicID systemID: systemID hasInternalSubset: aBoolean [
	<category: 'DTD handler'>
	
    ]

    startDocument [
	<category: 'content handler'>
	
    ]

    startDocumentFragment [
	"Nonstandard extension to SAX"

	<category: 'content handler'>
	
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	"Receive notification of the beginning of an element.
	 
	 Parameters:
	 namespaceURI <String> The Namespace URI, Nil if the element has no Namespace URI
	 localName <String> The local name of the element (without prefix)
	 name <String> Literal name of the element as it appears, nil if processing namespaces.
	 attributes <SequenceableCollection of: XML.Attribute> The attributes attached to the element.
	 
	 Example
	 <doc xmlns='http://www.doc.org/' xmlns:other='http://www.other.com/'>
	 <a>A text</a>
	 <other:b>BA text</other:b>
	 <c other:cat='meow'>C text</c>
	 <d xmlns='http:/nested/'></d>
	 </doc>
	 
	 Parameter values to this method for each element of the above XML:
	 
	 local name: 'doc' namespace: 'http://www.doc.org/' name: 'doc'
	 local name: 'a' namespace: 'http://www.doc.org/' name: 'a'
	 local name: 'b' namespace: 'http://www.other.com/' name: 'other:b'
	 local name: 'c' namespace: 'http://www.doc.org/' name: 'c'
	 local name: 'd' namespace: 'http:/nested/' name: 'd'
	 
	 Note the attribute object also have namespaces"

	<category: 'content handler'>
	
    ]

    startPrefixMapping: prefix uri: uri [
	"Begin the scope of a prefix-URI Namespace mapping.
	 The information from this event is not necessary for
	 normal Namespace processing: the SAX XML reader will
	 automatically replace prefixes for element and attribute
	 names when the http://xml.org/sax/features/namespaces
	 feature is true (the default).
	 
	 There are cases, however, when applications need to use
	 prefixes in character data or in attribute values, where
	 they cannot safely be expanded automatically; the
	 start/endPrefixMapping event supplies the information to
	 the application to expand prefixes in those contexts itself,
	 if necessary.
	 
	 Note that start/endPrefixMapping events are not
	 guaranteed to be properly nested relative to each-other:
	 all startPrefixMapping events will occur before the
	 corresponding startElement event, and all
	 endPrefixMapping events will occur after the
	 corresponding endElement event, but their order is not
	 otherwise guaranteed.
	 
	 There should never be start/endPrefixMapping events for
	 the 'xml' prefix, since it is predeclared and immutable.
	 
	 Parameters:
	 prefix - The Namespace prefix being declared.
	 uri - The Namespace URI the prefix is mapped to.
	 "

	<category: 'content handler'>
	^self
    ]

    fatalError: anException [
	<category: 'error handler'>
	anException signal
    ]

    nonFatalError: anException [
	<category: 'error handler'>
	anException signal
    ]

    warning: anException [
	<category: 'error handler'>
	Transcript
	    nl;
	    show: anException messageText
    ]

    notationDecl: nameString publicID: publicIDString systemID: systemIDString [
	"Receive notification of a notation declaration event.
	 
	 It is up to the application to record the notation for later
	 reference, if necessary.
	 
	 If a system identifier is present, and it is a URL, the SAX
	 parser must resolve it fully before passing it to the application."

	<category: 'DTD handler'>
	
    ]

    unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation [
	"Receive notification of an unparsed entity declaration
	 event.
	 
	 Note that the notation name corresponds to a notation
	 reported by the notationDecl event. It is up to the
	 application to record the entity for later reference, if
	 necessary.
	 
	 If the system identifier is a URL, the parser must resolve it
	 fully before passing it to the application.
	 "

	<category: 'DTD handler'>
	^self
    ]

    resolveEntity: publicID systemID: systemID [
	<category: 'entity resolver'>
	^nil
    ]

    contentHandler [
	<category: 'accessing'>
	^self
    ]

    document [
	<category: 'accessing'>
	^nil
    ]

    dtdHandler [
	<category: 'accessing'>
	^self
    ]

    entityResolver [
	<category: 'accessing'>
	^self
    ]

    errorHandler [
	<category: 'accessing'>
	^self
    ]
]


SAXDriver subclass: DOM_SAXDriver [
    <category: 'XML-XML-DOM'>
    startElement [
	self notYetImplemented
    ]
]


SAXDriver subclass: SAXDispatcher [
    | contentHandler dtdHandler entityResolver errorHandler |
    
    <category: 'XML-XML-SAX'>
    <comment: '
SAXDispatcher allows the SAX implementation to support mixing and
matching of event handlers. For example, the same contentHandler could
be used with different errorHandlers for different ciecumstances, or
with different entityResolvers depending on what transport protocols
are loaded.

This class is primarily private, used by such methods as
XMLParser>>contentHandler:, but its use by client code is not
discouraged. To use it, create a SAXDispatcher, fill in its various
handler types with instances of other SAXDrivers, and then store the
SAXDispatcher in the parser using the #handlers: message.

Instance Variables:
    contentHandler	<XML.SAXDriver> 		handles all content events
    dtdHandler			<XML.SAXDriver> 		handles entity and notation declarations
    entityResolver		<XML.SAXDriver>		handles resolution of PUBLIC and SYSTEM paths,
    											to allow non-standard resolution
    errorHandler		<XML.SAXDriver>		handles all errors
'>

    SAXDispatcher class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    contentHandler [
	<category: 'accessing'>
	^contentHandler
    ]

    contentHandler: aSAXDriver [
	<category: 'accessing'>
	contentHandler := aSAXDriver
    ]

    document [
	<category: 'accessing'>
	^contentHandler document
    ]

    dtdHandler [
	<category: 'accessing'>
	^dtdHandler
    ]

    dtdHandler: aSAXDriver [
	<category: 'accessing'>
	dtdHandler := aSAXDriver
    ]

    entityResolver [
	<category: 'accessing'>
	^entityResolver
    ]

    entityResolver: aSAXDriver [
	<category: 'accessing'>
	entityResolver := aSAXDriver
    ]

    errorHandler [
	<category: 'accessing'>
	^errorHandler
    ]

    errorHandler: aSAXDriver [
	<category: 'accessing'>
	errorHandler := aSAXDriver
    ]

    comment: data from: start to: stop [
	<category: 'other'>
	contentHandler 
	    comment: data
	    from: start
	    to: stop
    ]

    idOfElement: elementID [
	<category: 'other'>
	contentHandler idOfElement: elementID
    ]

    sourcePosition: position inStream: stream [
	<category: 'other'>
	contentHandler sourcePosition: position inStream: stream
    ]

    characters: aString from: start to: stop [
	<category: 'content handler'>
	contentHandler 
	    characters: aString
	    from: start
	    to: stop
    ]

    endDocument [
	<category: 'content handler'>
	contentHandler endDocument
    ]

    endDocumentFragment [
	<category: 'content handler'>
	contentHandler endDocumentFragment
    ]

    endElement: namespaceURI localName: localName qName: name [
	<category: 'content handler'>
	contentHandler 
	    endElement: namespaceURI
	    localName: localName
	    qName: name
    ]

    endPrefixMapping: prefix [
	<category: 'content handler'>
	contentHandler endPrefixMapping: prefix
    ]

    ignorableWhitespace: aString from: start to: stop [
	<category: 'content handler'>
	contentHandler 
	    ignorableWhitespace: aString
	    from: start
	    to: stop
    ]

    processingInstruction: targetString data: dataString [
	<category: 'content handler'>
	contentHandler processingInstruction: targetString data: dataString
    ]

    setDocumentLocator: aLocator [
	<category: 'content handler'>
	contentHandler setDocumentLocator: aLocator
    ]

    skippedEntity: name [
	<category: 'content handler'>
	contentHandler skippedEntity: name
    ]

    startDocument [
	<category: 'content handler'>
	contentHandler startDocument
    ]

    startDocumentFragment [
	<category: 'content handler'>
	contentHandler startDocumentFragment
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	contentHandler 
	    startElement: namespaceURI
	    localName: localName
	    qName: name
	    attributes: attributes
    ]

    startPrefixMapping: prefix uri: uri [
	<category: 'content handler'>
	contentHandler startPrefixMapping: prefix uri: uri
    ]

    notationDecl: nameString publicID: publicIDString systemID: systemIDString [
	<category: 'DTD handler'>
	dtdHandler 
	    notationDecl: nameString
	    publicID: publicIDString
	    systemID: systemIDString
    ]

    unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation [
	<category: 'DTD handler'>
	dtdHandler 
	    unparsedEntityDecl: name
	    publicID: publicID
	    systemID: systemID
	    notationName: notation
    ]

    initialize [
	<category: 'initialize'>
	contentHandler := NullSAXDriver new.
	dtdHandler := contentHandler.
	entityResolver := contentHandler.
	errorHandler := contentHandler
    ]

    resolveEntity: publicID systemID: systemID [
	<category: 'entity resolver'>
	^entityResolver resolveEntity: publicID systemID: systemID
    ]

    fatalError: anException [
	<category: 'error handler'>
	errorHandler fatalError: anException
    ]

    nonFatalError: anException [
	<category: 'error handler'>
	errorHandler nonFatalError: anException
    ]

    warning: anException [
	<category: 'error handler'>
	errorHandler warning: anException
    ]
]


Error subclass: SAXException [
    | wrappedException |
    
    <category: 'XML-XML-Exceptions'>
    <comment: '
A special exception indicating an error in a SAX-compliant parser.

All errors when parsing XML *should* be converted to
SAXExceptions. Errors generated by the parser will usually be
instances of subclasses of SAXException. Errors generated by user
code, if caught, will usually be instances of other types of
Exception, and will be wrapped in an instance of SAXException to
simplify the task of an exception handler outside the parser.

Instance Variables:
    wrappedException	<Exception>  another exception, which has been wrapped so that a handler for SAXException will catch it.'>

    SAXException class >> mayResume [
	<category: 'testing'>
	^true
    ]

    wrappedException [
	<category: 'accessing'>
	^wrappedException
    ]

    wrappedException: anException [
	<category: 'accessing'>
	wrappedException := anException
    ]
]


SAXDispatcher subclass: XMLFilter [
    | parent |
    
    <category: 'XML-XML-SAX'>
    <comment: '
XMLFilter allows a parser to be wrapped in a SAX event handler such
that any attempt to get or set the parser''s properties, or start a
parse, can be intercepted by the event handler. It can thus add new
features or properties, or change how the features are implemented, or
modify the events coming back from the parser.

One example of how this might be used is that a feature (such as
namespace processing), if it were not implement in the parser, could
be implemented as a SAXDriver. By letting that driver masquerade as a
parser, we can let that driver be composed with other kinds of
SAXDrivers in a chain, and thus compose independent features together.

Instance Variables:
    parent	<XML.XMLParser | XML.XMLFilter>  the wrapped parser, which may itself be a filter
'>

    XMLFilter class >> on: aParserOrFilter [
	<category: 'instance creation'>
	^self new parent: aParserOrFilter
    ]

    atFeature: aURIstring [
	<category: 'accessing'>
	^parent atFeature: aURIstring
    ]

    atFeature: aURIstring put: aBoolean [
	<category: 'accessing'>
	^parent atFeature: aURIstring put: aBoolean
    ]

    atProperty: aURIstring [
	<category: 'accessing'>
	^parent atProperty: aURIstring
    ]

    atProperty: aURIstring put: anOvbject [
	<category: 'accessing'>
	^parent atProperty: aURIstring put: anOvbject
    ]

    handlers: aSAXDriver [
	<category: 'accessing'>
	self contentHandler: aSAXDriver.
	self dtdHandler: aSAXDriver.
	self errorHandler: aSAXDriver.
	self entityResolver: aSAXDriver
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aParserOrFilter [
	<category: 'accessing'>
	parent := aParserOrFilter.
	parent handlers: self
    ]

    parse: dataSource [
	<category: 'accessing'>
	^parent parse: dataSource
    ]

    parseElement: dataSource [
	<category: 'accessing'>
	^parent parseElement: dataSource
    ]

    parseElements: dataSource [
	<category: 'accessing'>
	^parent parseElements: dataSource
    ]
]


SAXDriver subclass: NullSAXDriver [
    
    <category: 'XML-XML-SAX'>
    <comment: '
The XML parser requires some sort of SAXDriver to receive events. If
the client desires to simply do syntax checking on the document
without further processing, and wants minimal overhead, NullSAXDriver
will do the minimal possible processing while implementing the entire
SAX API.'>

    characters: aString from: start to: stop [
	<category: 'content handler'>
	^self
    ]

    ignorableWhitespace: aString from: start to: stop [
	<category: 'content handler'>
	^self
    ]
]


Object subclass: Locator [
    | parser |
    
    <category: 'XML-XML-SAX'>
    <comment: '
Locators allow SAX drivers to ask the parser where we are in the
current parse, for error reporting.

Instance Variables:
    parser			<XML.XMLParser>  the current parser'>

    column [
	<category: 'processing'>
	^self externalWrapper column
    ]

    line [
	<category: 'processing'>
	^self externalWrapper line
    ]

    publicID [
	<category: 'processing'>
	| ent |
	ent := self externalWrapper entity.
	^ent == nil ifTrue: [nil] ifFalse: [ent publicID]
    ]

    systemID [
	<category: 'processing'>
	| ent |
	ent := self externalWrapper entity.
	^ent == nil ifTrue: [nil] ifFalse: [ent systemID]
    ]

    parser: aParser [
	<category: 'accessing'>
	parser := aParser
    ]

    externalWrapper [
	<category: 'private'>
	^parser fullSourceStack reverse detect: [:s | s isInternal not]
	    ifNone: [parser fullSourceStack first]
    ]
]


SAXDriver subclass: SAXWriter [
    | output textMap attrMap hasOpenTag normalizeText notations newNamespaces |
    
    <category: 'XML-XML-SAX'>
    <comment: '
SAXWriter is a kind of SAXDriver that converts SAX events back into
textual XML documents.

Instance Variables:
    attrMap	<Dictionary>	Lists the characters that are not allowed to appear literally in attributes, and maps them to their quoted form.
    hasOpenTag	<Boolean>	True if we are inside an element that has no content as yet. This allows us to know when we reach the end tag whether we can write the element as <x/> rather than <x></x>.
    newNamespaces	<nil | Dictionary>	Maps namespace qualifiers to URIs, for namespaces which the current element defines differently than its parent.
    normalizeText	<Boolean>	Should be true in almost all cases--can be false only if the "XML" document being parsed is actually not XML, in which case it may be legal to not quote characters such as $<.
    notations	<Collection>	List of notations defined in the document being parsed.
    output	<Stream>	Stream on which the XML is rendered as text.
    textMap	<Dictionary>	Lists the characters that are not allowed to appear literally in text, and maps them to their quoted form.

'>

    characters: aString from: start to: stop [
	<category: 'content handler'>
	| ch mapped |
	self closeOpenTag.
	normalizeText 
	    ifTrue: 
		[start to: stop
		    do: 
			[:i | 
			ch := aString at: i.
			mapped := textMap at: ch ifAbsent: [nil].
			mapped == nil 
			    ifTrue: [output nextPut: ch]
			    ifFalse: [output nextPutAll: mapped]]]
	    ifFalse: 
		[output 
		    next: stop + 1 - start
		    putAll: aString
		    startingAt: start]
    ]

    comment: data from: start to: stop [
	<category: 'content handler'>
	output
	    nextPutAll: '<!--';
	    next: stop + 1 - start
		putAll: data
		startingAt: start;
	    nextPutAll: '-->'
    ]

    endElement: namespaceURI localName: localName qName: name [
	<category: 'content handler'>
	hasOpenTag == true 
	    ifTrue: [output nextPutAll: '/>']
	    ifFalse: [output nextPutAll: '</' , name , '>'].
	hasOpenTag := false
    ]

    processingInstruction: targetString data: dataString [
	<category: 'content handler'>
	output
	    nextPutAll: '<?';
	    nextPutAll: targetString;
	    space;
	    nextPutAll: dataString;
	    nextPutAll: '?>'
    ]

    startDocument [
	<category: 'content handler'>
	hasOpenTag := false
    ]

    startDocumentFragment [
	"Nonstandard extension to SAX"

	<category: 'content handler'>
	hasOpenTag := false
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	| val |
	notations == nil ifFalse: [self emitDTD: name].
	self closeOpenTag.
	output nextPutAll: '<'.
	output nextPutAll: name.
	(self sort: attributes) do: 
		[:att | 
		output space.
		output nextPutAll: att tag asString.
		output nextPutAll: '="'.
		1 to: att value size
		    do: 
			[:i | 
			| ch mapped |
			ch := att value at: i.
			mapped := attrMap at: ch ifAbsent: [nil].
			mapped == nil 
			    ifTrue: [output nextPut: ch]
			    ifFalse: [output nextPutAll: mapped]].
		output nextPutAll: '"'].
	newNamespaces == nil 
	    ifFalse: 
		[newNamespaces keys asSortedCollection do: 
			[:key | 
			output space.
			output 
			    nextPutAll: (key isEmpty ifTrue: ['xmlns'] ifFalse: ['xmlns:' , key]).
			output nextPutAll: '="'.
			val := newNamespaces at: key.
			1 to: val size
			    do: 
				[:i | 
				| ch mapped |
				ch := val at: i.
				mapped := attrMap at: ch ifAbsent: [nil].
				mapped == nil 
				    ifTrue: [output nextPut: ch]
				    ifFalse: [output nextPutAll: mapped]].
			output nextPutAll: '"']].
	newNamespaces := nil.
	hasOpenTag := true
    ]

    startPrefixMapping: prefix uri: uri [
	<category: 'content handler'>
	newNamespaces == nil ifTrue: [newNamespaces := Dictionary new].
	newNamespaces at: prefix put: uri
    ]

    minimalCharacterMapping [
	<category: 'initialize'>
	textMap := (Dictionary new)
		    at: $< put: '&lt;';
		    at: $& put: '&amp;';
		    yourself.
	attrMap := (Dictionary new)
		    at: $< put: '&lt;';
		    at: $& put: '&amp;';
		    at: $" put: '&quot;';
		    yourself
    ]

    normalizeText: aBoolean [
	<category: 'initialize'>
	normalizeText := aBoolean
    ]

    output: aStream [
	<category: 'initialize'>
	output := aStream.
	normalizeText := true.
	notations := nil.
	textMap == nil ifTrue: [self minimalCharacterMapping]
    ]

    notationDecl: nameString publicID: publicIDString systemID: systemIDString [
	<category: 'DTD handler'>
	notations == nil ifTrue: [notations := OrderedCollection new].
	notations add: (Array 
		    with: nameString
		    with: publicIDString
		    with: systemIDString)
    ]

    closeOpenTag [
	<category: 'private'>
	hasOpenTag == true 
	    ifTrue: 
		[output nextPutAll: '>'.
		hasOpenTag := false]
    ]

    emitDTD: name [
	<category: 'private'>
	| list |
	output
	    nextPutAll: '<!DOCTYPE ';
	    nextPutAll: name;
	    nextPutAll: ' [';
	    nl.
	list := notations asSortedCollection: [:a1 :a2 | a1 first < a2 first].
	list do: 
		[:notation | 
		self emitNotation: notation.
		output nl].
	output
	    nextPutAll: ']>';
	    nl.
	notations := nil
    ]

    emitNotation: array [
	<category: 'private'>
	output
	    nextPutAll: '<!NOTATION ';
	    nextPutAll: (array at: 1);
	    space;
	    nextPutAll: ((array at: 2) == nil ifTrue: ['SYSTEM'] ifFalse: ['PUBLIC']).
	(array at: 2) == nil 
	    ifFalse: 
		[output
		    nextPutAll: ' ''';
		    nextPutAll: (array at: 2);
		    nextPutAll: ''''].
	(array at: 3) == nil 
	    ifFalse: 
		[output
		    nextPutAll: ' ''';
		    nextPutAll: (array at: 3);
		    nextPutAll: ''''].
	output nextPutAll: '>'
    ]

    sort: attributes [
	<category: 'private'>
	^attributes 
	    asSortedCollection: [:a1 :a2 | a1 tag asString < a2 tag asString]
    ]
]


SAXWriter subclass: SAXCanonicalWriter [
    | baseURI |
    
    <category: 'XML-XML-SAX'>
    <comment: '
SAXCanonicalWriter is a subclass of SAXWriter that translates XML into
a textual form conforming to the Sun Canonical XML specification used
by the OASIS (http://www.oasis-open.org/) consortium in their XML
conformance tests.

Instance Variables:
    baseURI	<URI>	When parsing, this remembers the URI of the document so that relative URIs (in Notations, for example) can be resolved to absolute URIs.

'>

    comment: data from: start to: stop [
	"Canonical XML surpresses comments"

	<category: 'content handler'>
	^self
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	super 
	    startElement: namespaceURI
	    localName: localName
	    qName: name
	    attributes: attributes.
	self closeOpenTag
    ]

    emitNotation: array [
	<category: 'private'>
	| sysID frag |
	sysID := array at: 3.
	sysID == nil ifTrue: [^super emitNotation: array].
	sysID size to: 2
	    by: -1
	    do: 
		[:i | 
		frag := sysID copyFrom: i to: sysID size.
		frag replaceAll: $: with: $/.
		frag replaceAll: $\ with: $/.
		([(baseURI resolvePath: frag) asString = sysID] on: Error
		    do: [:x | x return: false]) 
			ifTrue: 
			    [^super emitNotation: ((array copy)
					at: 3 put: frag;
					yourself)]].
	super emitNotation: array
    ]

    baseURI: url [
	<category: 'initialize'>
	baseURI := url
    ]

    minimalCharacterMapping [
	<category: 'initialize'>
	textMap := (Dictionary new)
		    at: $< put: '&lt;';
		    at: $> put: '&gt;';
		    at: $" put: '&quot;';
		    at: $& put: '&amp;';
		    at: (Character value: 9) put: '&#9;';
		    at: (Character value: 10) put: '&#10;';
		    at: (Character value: 13) put: '&#13;';
		    yourself.
	attrMap := (Dictionary new)
		    at: $< put: '&lt;';
		    at: $> put: '&gt;';
		    at: $& put: '&amp;';
		    at: $" put: '&quot;';
		    at: (Character value: 9) put: '&#9;';
		    at: (Character value: 10) put: '&#10;';
		    at: (Character value: 13) put: '&#13;';
		    yourself
    ]
]
SAXException subclass: SAXParseException [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>
]

SAXParseException subclass: MalformedSignal [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>
]

SAXParseException subclass: InvalidSignal [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>
]

SAXException subclass: SAXNotSupportedException [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>
]

SAXParseException subclass: WarningSignal [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>

    isResumable [ ^true ]
]


MalformedSignal subclass: EmptySignal [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>

    isResumable [ ^true ]
]

MalformedSignal subclass: BadCharacterSignal [
    
    <category: 'XML-XML-Exceptions'>
    <comment: nil>
]


Object subclass: InputSource [
    | uri encoding stream |
    
    <category: 'XML-XML-Resources'>
    <comment: '
An InputSource represents a data source which may have been fetched
locally or from the net, and which has various properties. An
InputSource may be created by a SAXDriver in response to the
#resolveEntity:systemID: message.

In release 5i.4, we record the URI and the data, and if possible the
encoding. In future we may want to also incorporate things like the
MIME type or other attributes.

Instance Variables:
    uri				<nil | NetClients.URL>	The URI of the data source, if known
    encoding		<nil | Symbol> 		If the transport protocol specified an encoding,
    									this should take precedence over the encoding
    									contained in the <?xml?> declaration
    stream			<Stream>			the data source'>

    InputSource class >> for: uri [
	<category: 'private'>
	| stream |
	stream := NetClients.URIResolver openStreamOn: uri.
	^self 
	    uri: (uri isString ifTrue: [NetClients.URL fromString: uri] ifFalse: [uri])
	    encoding: nil
	    stream: stream
    ]

    InputSource class >> uri: aURI encoding: anEncodingName stream: aStream [
	<category: 'instance creation'>
	^self new 
	    uri: aURI
	    encoding: anEncodingName
	    stream: aStream
    ]

    uri: aURI encoding: anEncodingName stream: aStream [
	<category: 'initialize'>
	uri := aURI.
	encoding := anEncodingName.
	stream := aStream
    ]

    encoding [
	<category: 'accessing'>
	^encoding
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]
]


Object subclass: Attribute [
    | name value |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
XML elements may have name-value pairs called attributes associated
with them. This class instantiates a single XML attribute. Attribute
is a subclass of Node, both because the W3C DOM model defines it that
way, and because it provides a uniform API for applications such as
XSLT that want to do similar sorts of processing on attributes and
other node types.

Instance Variables:
    name	<XML.Node | XML.NodeTag>		tag name
    value	<Object>							tag value'>

    Attribute class >> name: nm value: val [
	<category: 'instance creation'>
	^self new name: nm value: val
    ]

    name: nm value: val [
	<category: 'initialize'>
	name := nm isString 
		    ifTrue: 
			[NodeTag new 
			    qualifier: ''
			    ns: ''
			    type: nm]
		    ifFalse: [nm].
	value := val
    ]

    tag: aTag [
	<category: 'initialize'>
	name := aTag
    ]

    characterData [
	<category: 'accessing'>
	^self value
    ]

    expandedName [
	<category: 'accessing'>
	^name expandedName
    ]

    key [
	<category: 'accessing'>
	^name
    ]

    tag [
	<category: 'accessing'>
	^name
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	<category: 'accessing'>
	value := aValue
    ]

    printCanonicalOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self tag asString , '="'.
	self printCanonical: value on: aStream.
	aStream nextPutAll: '"'
    ]

    printOn: aStream [
	<category: 'printing'>
	self printCanonicalOn: aStream
    ]

    simpleDescription [
	<category: 'printing'>
	^'@' , self key
    ]

    isAttribute [
	<category: 'testing'>
	^true
    ]

    isLike: aNode [
	<category: 'testing'>
	^self class == aNode class and: [self tag isLike: aNode tag]
    ]
]



Magnitude subclass: NodeTag [
    | namespace type qualifier |
    
    <category: 'XML-XML-Parsing'>
    <comment: '
NodeTag is used as the "tag" of an Element or Attribute. It acts as
the name or identifier of its owner. It is subclassed from Magnitude
as a convenience to allow NodeTags to easily understand sorting
protocol.

In XML all elements or nodes are delimited by start and end tags (or
empty-element tags) and instances of this class are used to represent
these element tags. The name of the tag (type instance variable) gives
the element type.


Instance Variables:
    namespace	<String>		A URI in string form that uniquely identifies the XML namespace to which the type belongs. May be an empty string if the type is outside all namespaces.
    type			<String>		Name of tag, used to indicate element or attribute type.
    qualifier		<String>		In XML documents, the namespace is mapped to a qualifier, which is used as a prefix for the type. The namespace is assumed to be unique across all documents, but is quite clumsy. The qualifier is not unique across documents, but is unambiguous at the point where it is used and is short enough to be convenient. The qualifier may be the empty string if the namespace is empty or if the namespace is the current default namespace.'>

    NodeTag class >> qualifier: q ns: ns type: typeStr [
	<category: 'initialize'>
	^self new qualifier: q ns: ns type: typeStr
    ]

    NodeTag class >> name: name ns: ns type: typeStr [
	<category: 'initialize'>
	^self new name: name ns: ns type: typeStr 
    ]

    name: name ns: ns type: typeStr [
	<category: 'initialize'>
        namespace := ns.
        type := typeStr.
        qualifier := (name includes: $:) ifTrue: [name copyUpTo: $:] ifFalse: [''].
    ]

    qualifier: q ns: ns type: typeStr [
	<category: 'initialize'>
	namespace := ns.
	type := typeStr.
	qualifier := q
    ]

    expandedName [
	<category: 'accessing'>
	^namespace isEmpty ifTrue: [type] ifFalse: [namespace , '#' , type]
    ]

    namespace [
	<category: 'accessing'>
	^namespace
    ]

    qualifier [
	<category: 'accessing'>
	^qualifier
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    name [
	<category: 'converting'>
	^qualifier isEmpty ifTrue: [type] ifFalse: [qualifier , ':' , type]
    ]

    asString [
	<category: 'converting'>
	^self name
    ]

    isLike: aName [
	<category: 'testing'>
	^aName isString 
	    ifTrue: [namespace isEmpty and: [type = aName]]
	    ifFalse: [namespace = aName namespace and: [type = aName type]]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: '{' , self asString , '}'
    ]

    < aNodeTag [
	"Answer whether the receiver is less than the argument."

	<category: 'comparing'>
	^self asString < aNodeTag asString
    ]

    = aNodeTag [
	<category: 'comparing'>
	^self class = aNodeTag class and: 
		[self type = aNodeTag type and: 
			[self namespace == nil 
			    ifTrue: [self qualifier = aNodeTag qualifier]
			    ifFalse: [self namespace = aNodeTag namespace]]]
    ]

    hash [
	"The hash value is not dependent on either the namespace
	 or the qualifier, but equality is dependent on this. We think
	 this will not be a problem because collisions between tags
	 that have the same type but different namespaces or qualifiers
	 should be rare in the majority of cases."

	<category: 'comparing'>
	^self type hash
    ]
]


