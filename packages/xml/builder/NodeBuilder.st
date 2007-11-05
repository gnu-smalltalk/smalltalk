"======================================================================
|
|   VisualWorks XML Framework - NodeBuilder interface (obsolete)
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000, 2002 Cincom, Inc.
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


Object subclass: XMLNodeBuilder [
    | tagStack tags |
    
    <category: 'XML-XML-Parsing'>
    <comment: '
XMLNodeBuilder is an abstract superclass used by the XML parser when
distilling an XML document into its component elements.

Since XML elements are tag delimited and nest properly within each
other in a well-formed XML document, this class contains code to
process the tags and build a tree of xml elements.

XMLNodeBuilder is part of an older parser API which we are in the
process of removing. Consider using SAXDriver, which transforms the
XML document into events rather than nodes. SAXDriver has a subclass
named DOM_SAXDriver which can be used in the same way as
XMLNodeBuilder to create a tree of XML nodes.

Instance Variables:
    tagStack		<OrderedCollection>
    		Stack showing the nesting of XML elements within the document at the current stage of parsing.
    tags			<Dictionary>		Currently not used. A map to make sure that within a document, tag identifiers are unique instances in order to save space.'>

    XMLNodeBuilder class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize'>
	tagStack := OrderedCollection new.
	tags := Dictionary new
    ]

    currentTag [
	<category: 'accessing'>
	^tagStack last tag
    ]

    popTag [
	<category: 'accessing'>
	tagStack removeLast
    ]

    pushTag: tag [
	<category: 'accessing'>
	tagStack addLast: (ElementContext new tag: tag)
    ]

    attribute: name value: value [
	<category: 'building'>
	^Attribute name: name value: value
    ]

    comment: aText [
	<category: 'building'>
	^Comment new text: aText
    ]

    makeText: text [
	<category: 'building'>
	^Text text: text
    ]

    notation: name value: val [
	<category: 'building'>
	^Notation new name: name identifiers: val
    ]

    pi: nm text: text [
	<category: 'building'>
	^PI new name: nm text: text
    ]

    tag: tag attributes: attributes elements: elements position: p stream: stream [
	<category: 'building'>
	self subclassResponsibility
    ]
]


XMLNodeBuilder subclass: NodeBuilder [
    
    <category: 'XML-XML-Parsing'>
    <comment: '
A subclass of XMLNodeBuilder, this class is used by the XML parser to
distill an XML document into its component elements.

This NodeBuilder class in particular is used to create instances of
the various XML elements that are included in the scanned-in XML
document or document string.

This class can be subclassed in order to instantiate custom node
types. The main method to override would be
NodeBuilder>>tag:attributes:elements:position:stream:, since most of
the other methods in XMLNodeBuilder''s "building" protocol are very
secondary in importance compared to this method. But consider
subclassing DOM_SAXDriver rather than this class, and using the SAX
protocol to do your parsing.'>

    tag: tag attributes: attributes elements: elements position: p stream: stream [
	<category: 'building'>
	^Element 
	    tag: tag
	    attributes: attributes
	    elements: elements
    ]
]



SAXDriver subclass: SAXBuilderDriver [
    | builder document elementStack newNamespaces |
    
    <category: 'XML-XML-SAX'>
    <comment: '
This class converts SAX events into XMLNodeBuilder events, allowing
old builders to still be used with the new parser.

This is essentially a private class for XMLParser to allow the parser
to pretend to still support the old NodeBuilder API.

Instance Variables:
    builder				<XML.XMLNodeBuilder>		The client''s NodeBuilder, which creates XML Nodes.
    document			<XML.Document>				The Document which models the entire XML document.
    elementStack		<OrderedCollection>			A stack of proxies for the various elements that are in scope at the current stage of parsing.
    newNamespaces	<Dictionary>					maps qualifiers to namespaces for the next element'>

    characters: aString [
	<category: 'content handler'>
	| text |
	text := builder makeText: aString.
	text isDiscarded ifFalse: [elementStack last nodes add: text]
    ]

    endDocument [
	<category: 'content handler'>
	
    ]

    endDocumentFragment [
	<category: 'content handler'>
	^self endDocument
    ]

    endElement: namespaceURI localName: localName qName: name [
	"indicates the end of an element. See startElement"

	<category: 'content handler'>
	| elm element |
	elm := elementStack last.
	element := builder 
		    tag: elm tag
		    attributes: elm attributes
		    elements: (elm nodes isEmpty ifTrue: [nil] ifFalse: [elm nodes asArray])
		    position: elm startPosition
		    stream: elm stream.
	element namespaces: elm namespaces.
	elementStack removeLast.
	elementStack isEmpty 
	    ifTrue: 
		[document addNode: element.
		document dtd declaredRoot: element tag asString]
	    ifFalse: [element isDiscarded ifFalse: [elementStack last nodes add: element]].
	(element isDiscarded not and: [elm id notNil]) 
	    ifTrue: [document atID: elm id put: element].
	builder popTag
    ]

    ignorableWhitespace: aString [
	<category: 'content handler'>
	| text |
	text := builder makeText: aString.
	text isDiscarded ifFalse: [elementStack last nodes add: text]
    ]

    processingInstruction: targetString data: dataString [
	<category: 'content handler'>
	| pi |
	document == nil ifTrue: [self startDocument].
	pi := builder pi: targetString text: dataString.
	elementStack isEmpty 
	    ifTrue: [document addNode: pi]
	    ifFalse: [elementStack last nodes add: pi]
    ]

    startDocument [
	<category: 'content handler'>
	document := Document new.
	document dtd: DocumentType new.
	elementStack := OrderedCollection new
    ]

    startDocumentFragment [
	<category: 'content handler'>
	document := DocumentFragment new.
	document dtd: DocumentType new.
	elementStack := OrderedCollection new
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	| nm |
	document == nil ifTrue: [self startDocument].
	nm := NodeTag new 
		    qualifier: ((name includes: $:) ifTrue: [name copyUpTo: $:] ifFalse: [''])
		    ns: namespaceURI
		    type: localName.
	elementStack addLast: (SAXElementContext new tag: nm).
	(elementStack last)
	    attributes: (attributes collect: [:att | att copy]);
	    nodes: OrderedCollection new;
	    namespaces: newNamespaces.
	newNamespaces := nil.
	builder pushTag: nm
    ]

    startPrefixMapping: prefix uri: uri [
	<category: 'content handler'>
	newNamespaces == nil ifTrue: [newNamespaces := Dictionary new].
	newNamespaces at: prefix put: uri
    ]

    comment: data from: start to: stop [
	<category: 'other'>
	| comment |
	document == nil ifTrue: [self startDocument].
	comment := builder comment: (data copyFrom: start to: stop).
	comment isDiscarded 
	    ifFalse: 
		[elementStack isEmpty 
		    ifTrue: [document addNode: comment]
		    ifFalse: [elementStack last nodes add: comment]]
    ]

    idOfElement: elementID [
	"Notify the client what was the ID of the latest startElement"

	<category: 'other'>
	elementStack last id: elementID
    ]

    sourcePosition: position inStream: streamWrapper [
	"Non-standard API to ease transition from
	 builders to SAX."

	<category: 'other'>
	(elementStack last)
	    startPosition: position;
	    stream: streamWrapper
    ]

    builder: aNodeBuilder [
	<category: 'accessing'>
	builder := aNodeBuilder
    ]

    document [
	<category: 'accessing'>
	^document
    ]

    notationDecl: name publicID: publicID systemID: systemID [
	<category: 'DTD handler'>
	| notation |
	notation := builder notation: name
		    value: (Array with: publicID with: systemID).
	document dtd 
	    notationAt: name
	    put: notation
	    from: self
    ]
]


SAXParser extend [
    builder: anXMLNodeBuilder [
        <category: 'initialize'>
        self saxDriver: (SAXBuilderDriver new builder: anXMLNodeBuilder)
    ]
]


ElementContext subclass: SAXElementContext [
    | attributes nodes stream startPosition id |
    
    <category: 'XML-XML-SAX'>
    <comment: '
This class holds all the descriptive information that SAXBuilderDriver
needs to remember from the startElement until the endElement, to send
the right information to the builder.


Instance Variables:
    attributes	<Collection> 
    nodes	<Array> 
    stream	<XML.StreamWrapper> 
    startPosition	<Integer> 
    id	<nil | String> '>

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    attributes: aCollection [
	<category: 'accessing'>
	attributes := aCollection
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: anID [
	<category: 'accessing'>
	id := anID
    ]

    namespaces: aDictionary [
	<category: 'accessing'>
	namespaces := aDictionary
    ]

    nodes [
	<category: 'accessing'>
	^nodes
    ]

    nodes: aCollection [
	<category: 'accessing'>
	nodes := aCollection
    ]

    startPosition [
	<category: 'accessing'>
	^startPosition
    ]

    startPosition: anInteger [
	<category: 'accessing'>
	^startPosition := anInteger
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	^stream := aStream
    ]
]
