"======================================================================
|
|   VisualWorks XML Framework - DOM interface
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


Object subclass: Node [
    | parent flags |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
Class Node is an abstract superclass that represents a logical
component of an XML Document.

Logically, an XML document is composed of declarations, elements,
comments, character references, and processing instructions, all of
which are indicated in the document by explicit markup. The concrete
subclasses of XML.Node represent these various components.

Subclasses must implement the following messages:
    printing
    	printCanonicalOn:
    	printHTMLOn:
    	printNoIndentOn:endSpacing:spacing:

Instance Variables:
    parent	<XML.Node | nil> 			All nodes except for Documents are contained by other nodes--this provides a pointer from the node to the node that contains it.
    flags	<SmallInteger> 			Provides a compact representation for any boolean attributes that the node might have. Likely to be removed in the near future.'>

    Node class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize'>
	flags := 0
    ]

    children [
	<category: 'accessing'>
	^self shouldNotImplement
    ]

    discard [
	<category: 'accessing'>
	self flags: (self flags bitOr: 1)
    ]

    document [
	<category: 'accessing'>
	^parent document
    ]

    expandedName [
	<category: 'accessing'>
	^''
    ]

    flags [
	<category: 'accessing'>
	^flags
    ]

    flags: flagBits [
	<category: 'accessing'>
	flags := flagBits
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aNode [
	<category: 'accessing'>
	parent := aNode
    ]

    selectNodes: aBlock [
	<category: 'accessing'>
	^#()
    ]

    tag [
	<category: 'accessing'>
	^nil
    ]

    canonicalPrintString [
	<category: 'printing'>
	| s |
	s := (String new: 1024) writeStream.
	self printCanonicalOn: s.
	^s contents
    ]

    noIndentPrintString [
	<category: 'printing'>
	| s |
	s := (String new: 1024) writeStream.
	self printNoIndentOn: s.
	^s contents
    ]

    printCanonical: text on: aStream [
	"Print myself on the stream in the form described by James
	 Clark's canonical XML."

	<category: 'printing'>
	| d |
	d := Dictionary new.
	d
	    at: Character cr put: '&#13;';
	    at: Character lf put: '&#10;';
	    at: Character tab put: '&#9;';
	    at: $& put: '&amp;';
	    at: $< put: '&lt;';
	    at: $> put: '&gt;';
	    at: $" put: '&quot;'.
	text do: [:c | aStream nextPutAll: (d at: c ifAbsent: [String with: c])]
    ]

    printCanonicalOn: aStream [
	"Print myself on the stream in the form described by James
	 Clark's canonical XML."

	<category: 'printing'>
	self saxDo: (SAXCanonicalWriter new output: aStream)
    ]

    printHTMLOn: aStream [
	"Print myself on the stream in a form usual for HTML."

	<category: 'printing'>
	self subclassResponsibility
    ]

    printNoIndentOn: aStream [
	"Print myself on the stream with line breaks between adjacent
	 elements, but no indentation."

	<category: 'printing'>
	self 
	    printNoIndentOn: aStream
	    endSpacing: [:node :list | aStream nl]
	    spacing: [:node :list | aStream nl]
    ]

    printOn: aStream [
	<category: 'printing'>
	self printOn: aStream depth: 0
    ]

    printQuoted: text on: aStream [
	"Print myself on the stream in the form described by James
	 Clark's canonical XML."

	<category: 'printing'>
	| d |
	d := Dictionary new.
	d
	    at: $& put: '&amp;';
	    at: $< put: '&lt;';
	    at: $> put: '&gt;'.
	text do: [:c | aStream nextPutAll: (d at: c ifAbsent: [String with: c])]
    ]

    simpleDescription [
	<category: 'printing'>
	^self printString
    ]

    hasAncestor: aNode [
	<category: 'testing'>
	| p |
	p := self parent.
	[p == nil] whileFalse: 
		[p == aNode ifTrue: [^true].
		p := p parent].
	^false
    ]

    hasSubNodes [
	<category: 'testing'>
	^false
    ]

    isAttribute [
	<category: 'testing'>
	^false
    ]

    isBlankText [
	<category: 'testing'>
	^false
    ]

    isComment [
	<category: 'testing'>
	^false
    ]

    isContent [
	<category: 'testing'>
	^false
    ]

    isDiscarded [
	<category: 'testing'>
	^(self flags bitAnd: 1) = 1
    ]

    isDocument [
	<category: 'testing'>
	^false
    ]

    isElement [
	<category: 'testing'>
	^false
    ]

    isLike: aNode [
	<category: 'testing'>
	^self class == aNode class
    ]

    isProcessingInstruction [
	<category: 'testing'>
	^false
    ]

    isText [
	<category: 'testing'>
	^false
    ]

    precedes: aNode [
	<category: 'testing'>
	| n1 n2 |
	aNode document == self document 
	    ifFalse: 
		[self 
		    error: 'These nodes can''t be ordered. They are not in the same document.'].
	aNode == self document ifTrue: [^false].
	self == self document ifTrue: [^true].
	n1 := self.
	n2 := aNode.
	(n2 hasAncestor: n1) ifTrue: [^true].
	(n1 hasAncestor: n2) ifTrue: [^false].
	[n1 parent == n2 parent] whileFalse: 
		[[n1 parent hasAncestor: n2 parent] whileTrue: [n1 := n1 parent].
		[n2 parent hasAncestor: n1 parent] whileTrue: [n2 := n2 parent].
		n1 parent == n2 parent 
		    ifFalse: 
			[n1 := n1 parent.
			n2 := n2 parent]].
	^(n1 parent indexOf: n1) < (n1 parent indexOf: n2)
    ]

    nodesDo: aBlock [
	<category: 'enumerating'>
	aBlock value: self
    ]

    findNamespaceAt: qualifier [
	<category: 'namespaces'>
	| ns node |
	qualifier = 'xml' ifTrue: [^XML_URI].
	ns := nil.
	node := self.
	[node isElement and: [ns == nil]] whileTrue: 
		[ns := node namespaceAt: qualifier.
		node := node parent].
	^ns
    ]

    findQualifierAtNamespace: ns [
	<category: 'namespaces'>
	| qual node |
	qual := nil.
	node := self.
	[node isElement and: [qual == nil]] whileTrue: 
		[qual := node qualifierAtNamespace: ns.
		node := node parent].
	^qual
    ]

    namespaceAt: qualifier [
	<category: 'namespaces'>
	^nil
    ]

    qualifierAtNamespace: ns [
	<category: 'namespaces'>
	^nil
    ]
]


Node subclass: Entity [
    | name text systemID publicID |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
An XML document may consist of one or many storage units called
entities. All XML entities have content and are idententified by name.

Entities may be either parsed or unparsed, i.e., the XML processor is
not required to interpret an unparsed entity. This class and its
subclasses GeneralEntity and ParameterEntity represent parsed
entities. Entity is the abstract superclass for the other two
types. GeneralEntity identifies entities which can be used in the
document''s body, and ParameterEntity identifies those that can only
be used within the DTD. These entities are invoked by name using
entity references and their contents are held in the text instance
variable.

Entities may also be internal or external. If the content of the
entity is given in the declaration (within the document) itself then
the entity is called an internal entity. If the entity is not internal
to the document and is declared elsewhere it''s called an external
entity.

External entities have a system identifier (systemID instance
variable) that is an URI which may be used to retrieve the entity. In
addition to a system identifier, an external entity declaration may
include a public identifier (publicID instance variable). The XML
parser is allowed to try to use the publicID to try to generate an
alternative URI to retrive the entity''s contents.

Subclasses must implement the following messages:
    accessing
    	entityType

Instance Variables:
    name		<XML.NodeTag>  
    					Identifies the entity in an entity reference
    text			<nil | String>
    					The entity''s contents
    systemID	<String>
    					URI used to retrieve an external entity''s contents
    publicID	<String>
    					Alternative URI used to retrieve an external entity''s contents'>

    entityType [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    externalFrom: anArray [
	<category: 'accessing'>
	anArray class == Array 
	    ifFalse: [self error: 'External ID is expected to be an Array'].
	anArray size = 2 
	    ifTrue: 
		[publicID := anArray at: 1.
		systemID := anArray at: 2]
	    ifFalse: [self error: 'External ID has too many or too few identifiers']
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aName [
	<category: 'accessing'>
	name := aName
    ]

    publicID [
	<category: 'accessing'>
	^publicID
    ]

    systemID [
	<category: 'accessing'>
	^systemID
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    text: aString [
	<category: 'accessing'>
	text := aString
    ]

    isExternal [
	<category: 'testing'>
	^publicID notNil or: [systemID notNil]
    ]

    isParsed [
	<category: 'testing'>
	^true
    ]

    printOn: aStream [
	<category: 'printing'>
	self basicPrintOn: aStream.
	text == nil 
	    ifTrue: [aStream nextPutAll: '(' , self systemID , ')']
	    ifFalse: [aStream nextPutAll: '(' , text , ')']
    ]
]


Node subclass: Document [
    | root nodes dtd ids |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
This class represents an XML document entity and serves as the root of
the document entity tree. Each XML document has one entity (root)
called the document entity, which serves as the starting point for the
XML processor and may contain the whole document (nodes collection).

According to the XML 1.0 specification, XML documents may and should
begin with an XML declaration which specifies the version of XML
(xmlVersion instance variable) being used.

The XML document type declaration which must appear before the first
element in a document contains or points to markup declarations that
provide the grammar for this document. This grammar is known as
document type definition or DTD (dtd instance variable). An XML
document is valid if it has an associated document type declaration
and if the document complies with the constraints expressed in it

Instance Variables:
    root	<XML.Element>							The outer-most element of the XML document.
    nodes	<Collection>  							The root Element as well as all other PIs and Comments which precede or follow it.
    dtd		<XML.DocumentType>				Associated document type definition 
    ids		<KeyedCollection | Dictionary>  		Map which converts ID names to Elements, allowing a simple cross reference within the document.'>

    initialize [
	<category: 'initialize'>
	super initialize.
	nodes := OrderedCollection new.
	ids := Dictionary new
    ]

    addNamespaceDefinitions [
	<category: 'accessing'>
	| d tag |
	d := Dictionary new.
	self nodesDo: 
		[:aNode | 
		tag := aNode tag.
		tag isNil 
		    ifFalse: 
			[(d at: tag qualifier ifAbsent: [tag namespace]) = tag namespace 
			    ifFalse: 
				[self 
				    error: 'Using the same tag for multiple namespaces is not currently supported'].
			d at: tag qualifier put: tag namespace]].
	(d at: '' ifAbsent: ['']) = '' ifTrue: [d removeKey: '' ifAbsent: []].
	d removeKey: 'xml' ifAbsent: [].
	d removeKey: 'xmlns' ifAbsent: [].
	self root == nil ifFalse: [self root namespaces: d]
    ]

    addNode: aNode [
	<category: 'accessing'>
	nodes add: aNode.
	aNode parent: self.
	aNode isElement 
	    ifTrue: 
		[root == nil 
		    ifTrue: [root := aNode]
		    ifFalse: 
			[self 
			    error: 'It is illegal to have more than one element node at the top level in a document']]
    ]

    atID: id ifAbsent: aBlock [
	<category: 'accessing'>
	^ids at: id ifAbsent: aBlock
    ]

    atID: id put: element [
	<category: 'accessing'>
	ids at: id put: element
    ]

    children [
	<category: 'accessing'>
	^nodes
    ]

    document [
	<category: 'accessing'>
	^self
    ]

    dtd [
	<category: 'accessing'>
	^dtd
    ]

    dtd: aDTD [
	<category: 'accessing'>
	dtd := aDTD
    ]

    elements [
	<category: 'accessing'>
	^nodes
    ]

    indexOf: aChild [
	<category: 'accessing'>
	aChild parent == self ifFalse: [^nil].
	^self children identityIndexOf: aChild ifAbsent: [nil]
    ]

    root [
	<category: 'accessing'>
	^root
    ]

    selectNodes: aBlock [
	<category: 'accessing'>
	^nodes select: aBlock
    ]

    setRoot: aNode [
	<category: 'accessing'>
	root := aNode
    ]

    hasSubNodes [
	<category: 'testing'>
	^nodes size > 0
    ]

    isContent [
	<category: 'testing'>
	^true
    ]

    isDocument [
	<category: 'testing'>
	^true
    ]

    printHTMLOn: aStream [
	<category: 'printing'>
	nodes do: [:n | n printHTMLOn: aStream]
    ]

    printOn: aStream [
	<category: 'printing'>
	nodes do: 
		[:n | 
		n printOn: aStream.
		aStream nl]
    ]

    printSunCanonicalOn: aStream [
	<category: 'printing'>
	self dtd notNil ifTrue: [self dtd printCanonicalOn: aStream].
	nodes do: [:n | n printCanonicalOn: aStream]
    ]

    nodesDo: aBlock [
	<category: 'enumerating'>
	aBlock value: self.
	1 to: self elements size do: [:i | (self elements at: i) nodesDo: aBlock]
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	aDriver startDocument.
	self dtd == nil ifFalse: [self dtd saxDo: aDriver].
	1 to: self children size do: [:i | (self children at: i) saxDo: aDriver].
	aDriver endDocument
    ]
]


Node subclass: Element [
    | tag attributes namespaces elements userData definition |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
A concrete subclass of XML.Node, this represents a single XML document
element.

XML document element boundaries are either delimited by start-tags and
end-tags, or, for empty elements, by an empty-element tag. Each
element has a type, identified by name, sometimes called its "generic
identifier" (GI), and may have a set of attribute specifications. Each
attribute specification has a name and a value.

Instance Variables:
    tag				<String | NodeTag> 			the tag name of this element
    attributes		<Collection>					A list of the attributes that appeared in the element''s start tag, usually excluding those attributes that define namespace mappings.
    namespaces	<Dictionary>					A map from namespace qualifiers to URIs, used to resolve qualifiers within the scope of this element.
    elements		<SequenceableCollection>	The Element, Text, Comment, and PI nodes that appear within this Element but are not contained by a child Element.
    userData		<Object>						used by clients to add annotations to the element
    definition		<Object>  						suspect this is unused'>

    Element class >> tag: tag [
	<category: 'instance creation'>
	^self new 
	    setTag: tag
	    attributes: nil
	    elements: nil
    ]

    Element class >> tag: tag attributes: attributes elements: elements [
	<category: 'instance creation'>
	^self new 
	    setTag: tag
	    attributes: attributes
	    elements: elements
    ]

    Element class >> tag: tag elements: elements [
	<category: 'instance creation'>
	^self new 
	    setTag: tag
	    attributes: nil
	    elements: elements
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	tag := 'undefined'.
	attributes := #()
    ]

    anyElementNamed: elementName [
	"This will return the receiver if its name matches the requirement."

	<category: 'accessing'>
	| list |
	list := self anyElementsNamed: elementName.
	list size > 1 
	    ifTrue: [self error: 'There is not a unique element with this tag'].
	^list isEmpty ifFalse: [list first]
    ]

    anyElementsNamed: elementName [
	"This includes the receiver as one of the possibilities."

	<category: 'accessing'>
	| list |
	list := OrderedCollection new.
	self nodesDo: 
		[:e | 
		(e isElement and: [e tag isLike: elementName]) ifTrue: [list add: e]].
	^list
    ]

    attributes [
	<category: 'accessing'>
	^attributes == nil ifTrue: [#()] ifFalse: [attributes]
    ]

    characterData [
	<category: 'accessing'>
	| str all |
	all := self elements.
	all size = 0 ifTrue: [^''].
	all size = 1 ifTrue: [^all first characterData].
	str := (String new: 128) writeStream.
	self characterDataOnto: str.
	^str contents
    ]

    characterDataOnto: str [
	<category: 'accessing'>
	self elements do: [:i | i isContent ifTrue: [i characterDataOnto: str]]
    ]

    children [
	<category: 'accessing'>
	^elements == nil ifTrue: [#()] ifFalse: [elements]
    ]

    definition [
	<category: 'accessing'>
	^definition
    ]

    definition: aPattern [
	<category: 'accessing'>
	definition := aPattern
    ]

    description [
	<category: 'accessing'>
	^'an <%1> element' % {tag}
    ]

    elementNamed: elementName [
	<category: 'accessing'>
	| list |
	list := self elementsNamed: elementName.
	list size = 1 
	    ifFalse: [self error: 'There is not a unique element with this tag'].
	^list first
    ]

    elements [
	<category: 'accessing'>
	^elements == nil ifTrue: [#()] ifFalse: [elements]
    ]

    elementsNamed: elementName [
	<category: 'accessing'>
	^self elements select: [:e | e isElement and: [e tag isLike: elementName]]
    ]

    expandedName [
	<category: 'accessing'>
	^tag expandedName
    ]

    indexOf: aChild [
	<category: 'accessing'>
	aChild parent == self ifFalse: [^nil].
	^aChild isAttribute 
	    ifTrue: [-1]
	    ifFalse: [elements identityIndexOf: aChild ifAbsent: [nil]]
    ]

    namespaces: aDictionaryOrNil [
	<category: 'accessing'>
	namespaces := aDictionaryOrNil
    ]

    selectNodes: aBlock [
	<category: 'accessing'>
	^self attributes , self elements select: aBlock
    ]

    tag [
	<category: 'accessing'>
	^tag
    ]

    userData [
	<category: 'accessing'>
	^userData
    ]

    userData: anObject [
	<category: 'accessing'>
	userData := anObject
    ]

    valueOfAttribute: attributeName ifAbsent: aBlock [
	<category: 'accessing'>
	^(self attributes detect: [:a | a tag isLike: attributeName]
	    ifNone: [^aBlock value]) value
    ]

    printHTMLOn: aStream [
	<category: 'printing'>
	| elem |
	self saxDo: (SAXWriter new output: aStream)
	    forBodyDo: 
		[elem := elements == nil 
			    ifTrue: [#()]
			    ifFalse: 
				["reject: [:str | str isBlankText]"

				elements].
		self isHTMLBlock ifTrue: [aStream nl].
		elem do: 
			[:e | 
			e printHTMLOn: aStream.
			self isHTMLBlock ifTrue: [aStream nl]]]
    ]

    printOn: aStream depth: indent [
	<category: 'printing'>
	| elem |
	self saxDo: (SAXWriter new output: aStream)
	    forBodyDo: 
		[elements == nil 
		    ifFalse: 
			[elem := elements reject: [:str | str isText and: [str isStripped]].
			(elem size <= 1 and: [(elem contains: [:n | n isText not]) not]) 
			    ifTrue: [elem do: [:e | e printOn: aStream depth: indent + 1]]
			    ifFalse: 
				[1 to: elem size
				    do: 
					[:i | 
					| e |
					e := elem at: i.
					aStream
					    nl;
					    space: indent + 1.
					e isString 
					    ifTrue: [aStream nextPutAll: e]
					    ifFalse: [e printOn: aStream depth: indent + 1]].
				aStream
				    nl;
				    space: indent]]]
    ]

    simpleDescription [
	<category: 'printing'>
	^'<' , self tag asString , '>'
    ]

    namespaceAt: qualifier [
	<category: 'namespaces'>
	^namespaces == nil 
	    ifTrue: [nil]
	    ifFalse: [namespaces at: qualifier ifAbsent: [nil]]
    ]

    qualifierAtNamespace: ns [
	<category: 'namespaces'>
	^namespaces == nil 
	    ifTrue: [nil]
	    ifFalse: 
		[namespaces 
		    keysAndValuesDo: [:qualifier :namespace | namespace = ns ifTrue: [^qualifier]].
		nil]
    ]

    attributes: a [
	<category: 'private'>
	attributes := a.
	a == nil ifFalse: [a do: [:i | i parent: self]]
    ]

    condenseList [
	<category: 'private'>
	elements == nil 
	    ifFalse: 
		[elements size = 0 
		    ifTrue: [elements := nil]
		    ifFalse: [elements := elements asArray]]
    ]

    condenseText [
	<category: 'private'>
	| elmts str tc |
	elmts := (Array new: elements size) writeStream.
	str := nil.
	elements do: 
		[:elm | 
		elm isText 
		    ifTrue: 
			[str == nil ifTrue: [str := (String new: elm text size) writeStream].
			tc := elm class.
			str nextPutAll: elm text]
		    ifFalse: 
			[str == nil ifFalse: [elmts nextPut: (tc new text: str contents)].
			str := nil.
			elmts nextPut: elm]].
	str == nil ifFalse: [elmts nextPut: (tc new text: str contents)].
	elements := elmts contents
    ]

    elements: e [
	<category: 'private'>
	elements := e.
	self isEmpty 
	    ifFalse: 
		[self condenseText.
		elements do: [:elm | elm parent: self]]
    ]

    setTag: t attributes: a elements: e [
	<category: 'private'>
	tag := t isString 
		    ifTrue: 
			[NodeTag new 
			    qualifier: ''
			    ns: ''
			    type: t]
		    ifFalse: [t].
	self attributes: a.
	self elements: e
    ]

    hasSubNodes [
	<category: 'testing'>
	^elements size > 0 or: [attributes size > 0]
    ]

    isContent [
	<category: 'testing'>
	^true
    ]

    isElement [
	<category: 'testing'>
	^true
    ]

    isEmpty [
	<category: 'testing'>
	^elements == nil
    ]

    isHTMLBlock [
	<category: 'testing'>
	^#('p' 'html' 'head' 'body') includes: tag asLowercase
    ]

    isLike: aNode [
	<category: 'testing'>
	^self class == aNode class and: [self tag isLike: aNode tag]
    ]

    notEmpty [
	<category: 'testing'>
	^elements ~~ nil
    ]

    nodesDo: aBlock [
	<category: 'enumerating'>
	aBlock value: self.
	1 to: self attributes size
	    do: [:i | (self attributes at: i) nodesDo: aBlock].
	1 to: self elements size do: [:i | (self elements at: i) nodesDo: aBlock]
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	namespaces == nil 
	    ifFalse: 
		[namespaces 
		    keysAndValuesDo: [:qual :uri | aDriver startPrefixMapping: qual uri: uri]].
	aDriver 
	    startElement: self tag namespace
	    localName: self tag type
	    qName: self tag asString
	    attributes: self attributes.
	1 to: self children size do: [:i | (self children at: i) saxDo: aDriver].
	aDriver 
	    endElement: self tag namespace
	    localName: self tag type
	    qName: self tag asString.
	namespaces == nil 
	    ifFalse: 
		[namespaces keysAndValuesDo: [:qual :uri | aDriver endPrefixMapping: qual]]
    ]

    saxDo: aDriver forBodyDo: aBlock [
	"a variation on #saxDo: that lets the client
	 control how the body of the element is to be
	 printed."

	<category: 'enumerating'>
	namespaces == nil 
	    ifFalse: 
		[namespaces 
		    keysAndValuesDo: [:qual :uri | aDriver startPrefixMapping: qual uri: uri]].
	aDriver 
	    startElement: self tag namespace
	    localName: self tag type
	    qName: self tag asString
	    attributes: self attributes.
	(aDriver respondsTo: #closeOpenTag) ifTrue: [aDriver closeOpenTag].
	aBlock value.
	aDriver 
	    endElement: self tag namespace
	    localName: self tag type
	    qName: self tag asString.
	namespaces == nil 
	    ifFalse: 
		[namespaces keysAndValuesDo: [:qual :uri | aDriver endPrefixMapping: qual]]
    ]

    addAttribute: aNode [
	<category: 'modifying'>
	attributes isNil ifTrue: [attributes := OrderedCollection new].
	attributes class == OrderedCollection 
	    ifFalse: [attributes := attributes asOrderedCollection].
	attributes add: aNode
    ]

    addNode: aNode [
	<category: 'modifying'>
	aNode parent: self.
	elements == nil 
	    ifTrue: [elements := OrderedCollection new: 5]
	    ifFalse: 
		[elements class == Array ifTrue: [elements := elements asOrderedCollection]].
	elements addLast: aNode
    ]

    removeAttribute: aNode [
	<category: 'modifying'>
	attributes isNil 
	    ifFalse: 
		[attributes class == OrderedCollection 
		    ifFalse: [attributes := attributes asOrderedCollection].
		attributes remove: aNode ifAbsent: [].
		attributes isEmpty ifTrue: [attributes := nil]]
    ]

    removeNode: aNode [
	<category: 'modifying'>
	elements isNil 
	    ifFalse: 
		[elements class == OrderedCollection 
		    ifFalse: [elements := elements asOrderedCollection].
		elements remove: aNode ifAbsent: [].
		elements isEmpty ifTrue: [elements := nil]]
    ]
]


Node subclass: Text [
    | text stripped |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
A subclass of Node, this class represents an XML textual object,
i.e. a sequence of legal characters as defined in the XML 1.0
specification. Instances of XML.Text may represent either markup or
character data.

Instance Variables:
    text			<CharacterArray | nil>	the actual data of the Text.
    stripped	<Boolean>	Will be true if the text contains only white space and if the parser has determined that the client would not be interested in the data.'>

    Text class >> text: aString [
	<category: 'instance creation'>
	^self new text: aString
    ]

    characterData [
	<category: 'accessing'>
	^self text
    ]

    characterDataOnto: str [
	<category: 'accessing'>
	str nextPutAll: self text
    ]

    description [
	<category: 'accessing'>
	^'text'
    ]

    strip: aBoolean [
	<category: 'accessing'>
	stripped := aBoolean
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    text: aText [
	<category: 'accessing'>
	text := aText.
	stripped == nil ifTrue: [stripped := false]
    ]

    printHTMLOn: aStream [
	<category: 'printing'>
	text == nil ifTrue: [^self].
	self isStripped ifFalse: [self printCanonical: text on: aStream]
    ]

    printOn: aStream depth: indent [
	<category: 'printing'>
	text == nil 
	    ifTrue: [aStream nextPutAll: '&nil;']
	    ifFalse: [self printQuoted: text on: aStream]
    ]

    isBlankText [
	<category: 'testing'>
	^(text contains: [:i | i isSeparator not]) not
    ]

    isContent [
	<category: 'testing'>
	^true
    ]

    isStripped [
	<category: 'testing'>
	^stripped
    ]

    isText [
	<category: 'testing'>
	^true
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	aDriver 
	    characters: text
	    from: 1
	    to: text size
    ]
]


Entity subclass: GeneralEntity [
    | ndata definedExternally |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
This class represents a general entity which is a parsed entity for
use within the XML document content.

Instance Variables:
    ndata	<Notation>			Some general entities may have a notation associated with them which identifies how they are to be processed--this instace variable identifies that Notation.'>

    entityType [
	<category: 'accessing'>
	^'generic'
    ]

    isDefinedExternally [
	<category: 'accessing'>
	^definedExternally
    ]

    isDefinedExternally: aBoolean [
	<category: 'accessing'>
	definedExternally := aBoolean
    ]

    ndata: aNotifierNameOrNil [
	<category: 'accessing'>
	ndata := aNotifierNameOrNil
    ]

    isParsed [
	<category: 'testing'>
	^ndata == nil
    ]
]


Entity subclass: ParameterEntity [
    
    <category: 'XML-XML-Nodes'>
    <comment: '
This class represents a parameter entity which is a parsed entity for
use within the document type definition.'>

    entityType [
	<category: 'accessing'>
	^'parameter'
    ]
]


Node subclass: Comment [
    | text |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
A concrete subclass of XML.Node, this class represents an XML comment.

XML comments may appear anywhere in an XML document outside other
markup or within the document type declaration at places allowed by
grammar. XML comments are delimited by the start-tag ''<!--'' and the
end-tag ''-->''.

According to the XML 1.0 specification, for compatibilty,
double-hyphens (the string ''--'') must not occur within comments.

Instance Variables:
    text		<String>  	contents of the comment element'>

    printHTMLOn: aStream [
	<category: 'printing'>
	self printOn: aStream
    ]

    printOn: aStream depth: indent [
	<category: 'printing'>
	aStream 
	    nextPutAll: '<!--' , (text == nil ifTrue: [''] ifFalse: [text]) , '-->'
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    text: aText [
	<category: 'accessing'>
	text := aText
    ]

    isComment [
	<category: 'testing'>
	^true
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	aDriver 
	    comment: text
	    from: 1
	    to: text size
    ]
]


Document subclass: DocumentFragment [
    
    <category: 'XML-XML-Nodes'>
    <comment: '
DocumentFragment is a subclass of Document which can be used to model
documents which do not correctly conform to the XML standard. Such
fragments may contain text that is not contained within any element,
or may contain more than one element at the top level.

At present it is not possible to represent a Document fragment that
contains the start tag but not the end tag of an element, or contains
the end tag but not the start tag.  '>

    addNode: aNode [
	<category: 'accessing'>
	nodes add: aNode.
	aNode parent: self.
	aNode isElement ifTrue: [root == nil ifTrue: [root := aNode]]
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	aDriver startDocumentFragment.
	self dtd == nil ifFalse: [self dtd saxDo: aDriver].
	1 to: self children size do: [:i | (self children at: i) saxDo: aDriver].
	aDriver endDocumentFragment
    ]
]


SAXDriver subclass: DOM_SAXDriver [
    | stack document newNamespaces |
    
    <category: 'XML-XML-SAX'>
    <comment: '
This class represents a specialized type of SAX (Simple API for XML)
processor that follows the ''object model'' for processing XML
documents to build a Document Object Model (DOM) tree from the
processed XML document.

As a way to distinguish between the two, SAX is an event driven API
for reading XML documents. Character groups within the document are
mapped to one or more callbacks to a SAXDriver, but no assumption is
made that any objects will necessarily be created as a result of those
events. DOM, on the other hand, is an object API for reading
XML. Character groups within the document are mapped to subclasses of
Node.

SAX is very useful for speed and memory conservation if the document
can be processed linearly. DOM is very useful if a substantial amount
of non-linear processing is required.

Instance Variables:
    stack				<OrderedCollection>		A stack containing the various elements that contain the current parse position.
    document			<XML.Document>			The Document or DocumentFragment which models the entire XML document being parsed.
    newNamespaces	<Dictionary>				maps qualifiers to namespaces for the next element'>

    comment: data from: start to: stop [
	<category: 'other'>
	document == nil ifTrue: [self startDocument].
	stack last addNode: (Comment new text: (data copyFrom: start to: stop))
    ]

    idOfElement: elementID [
	"Notify the client what was the ID of the latest startElement"

	<category: 'other'>
	document atID: elementID put: stack last
    ]

    characters: aString [
	<category: 'content handler'>
	stack last addNode: (Text text: aString)
    ]

    endDocument [
	<category: 'content handler'>
	document := stack removeLast.
	document isDocument ifFalse: [self error: 'End of Document not expected'].
	stack isEmpty ifFalse: [self error: 'End of Document not expected']
    ]

    endDocumentFragment [
	<category: 'content handler'>
	document := stack removeLast.
	document isDocument ifFalse: [self error: 'End of Document not expected'].
	stack isEmpty ifFalse: [self error: 'End of Document not expected']
    ]

    endElement: namespaceURI localName: localName qName: name [
	"indicates the end of an element. See startElement"

	<category: 'content handler'>
	stack removeLast condenseList
    ]

    ignorableWhitespace: aString [
	<category: 'content handler'>
	stack last addNode: (Text text: aString)
    ]

    processingInstruction: targetString data: dataString [
	<category: 'content handler'>
	document == nil ifTrue: [self startDocument].
	stack last addNode: (PI name: targetString text: dataString)
    ]

    startDocument [
	<category: 'content handler'>
	document := Document new.
	document dtd: DocumentType new.
	stack := OrderedCollection with: document
    ]

    startDocumentFragment [
	<category: 'content handler'>
	document := DocumentFragment new.
	document dtd: DocumentType new.
	stack := OrderedCollection with: document
    ]

    startElement: namespaceURI localName: localName qName: name attributes: attributes [
	<category: 'content handler'>
	| element tag |
	document == nil ifTrue: [self startDocument].
	tag := NodeTag new 
		    name: name
		    ns: namespaceURI
		    type: localName.
	element := Element 
		    tag: tag
		    attributes: attributes
		    elements: OrderedCollection new.
	element namespaces: newNamespaces.
	newNamespaces := nil.
	stack size = 1 ifTrue: [document dtd declaredRoot: name].
	stack last addNode: element.
	stack addLast: element
    ]

    startPrefixMapping: prefix uri: uri [
	<category: 'content handler'>
	newNamespaces == nil ifTrue: [newNamespaces := Dictionary new].
	newNamespaces at: prefix put: uri
    ]

    notationDecl: name publicID: publicID systemID: systemID [
	<category: 'DTD handler'>
	| notation |
	notation := Notation new name: name
		    identifiers: (Array with: publicID with: systemID).
	document dtd 
	    notationAt: name
	    put: notation
	    from: self
    ]

    document [
	<category: 'accessing'>
	^document
    ]

    endElement [
	<category: 'compat'>
	| namespaceURI localName name tag |
	tag := stack last tag.
	tag isString 
	    ifTrue: 
		[localName := name := tag.
		namespaceURI := '']
	    ifFalse: 
		[localName := tag type.
		name := tag asString.
		namespaceURI := tag namespace].
	^self 
	    endElement: namespaceURI
	    localName: localName
	    qName: name
    ]

    startElement: tag atts: attrs [
	<category: 'compat'>
	| namespaceURI localName name attributes |
	tag isString 
	    ifTrue: 
		[localName := name := tag.
		namespaceURI := '']
	    ifFalse: 
		[localName := tag type.
		name := tag asString.
		namespaceURI := tag namespace].
	attributes := attrs == nil ifTrue: [#()] ifFalse: [attrs].
	^self 
	    startElement: namespaceURI
	    localName: localName
	    qName: name
	    attributes: attributes
    ]
]


Eval [
    "yes, we change the superclass.  Gross."
    Node subclass: #Attribute
]


Node subclass: PI [
    | name text |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
A concrete subclass of Node, this class represents the XML Processing
Instruction element.

Processing instructions allow XML documents to contain instructions
for applications.  XML processing instructions are delimited by the
start-tag ''<?'' and the end-tag ''?>''. According to the XML 1.0
specification, the target names "XML", "xml" and so on are reserved
for standardization.

Instance Variables:
    name		<String>
    				the target of this processing instruction, used to identify the application
    				to which this processing instruction is directed.
    text			<String>
    				the processing instructions themselves'>

    PI class >> name: nm text: aString [
	<category: 'instance creation'>
	^self new name: nm text: aString
    ]

    name: nm text: aString [
	<category: 'initialize'>
	name := nm.
	text := aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    printHTMLOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: '<?' , name , ' ' , text , '?>'
    ]

    printOn: aStream depth: indent [
	<category: 'printing'>
	aStream nextPutAll: '<?' , name , ' ' , text , '?>'
    ]

    isLike: aNode [
	<category: 'testing'>
	^self class == aNode class and: [self name isLike: aNode name]
    ]

    isProcessingInstruction [
	<category: 'testing'>
	^true
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	aDriver processingInstruction: name data: text
    ]
]


Node subclass: Notation [
    | name publicID systemID |
    
    <category: 'XML-XML-Nodes'>
    <comment: '
A concrete subclass of Node, this class represents an XML Notation
declaration.

Notations are XML elements/nodes which identify by name the format of
unparsed entities, the format of elements which bear a notation
attribute or the application to which a processing instruction is
addressed.

Notations are delimited in the DTD by the start-tag ''<!NOTATION'' and
end-tag ''>''

The name instance variable provides a name or identifier for the
notation, for use in entity and attribute specifications. The publicID
instance variable provides an external identifier which allows the XML
processor or the client application to locate a helper application
capable of processing data in the given notation. The systemID
variable allows the parser to optionally resolve the publicID into the
system identifier, file name, or other information needed to allow the
application to call a processor for data in the notation.


Instance Variables:
    name		<String>		A unique identifier for the Notation within the document.
    publicID	<String>		The public ID of the Notation, which seems to not be heavily used at present.
    systemID	<String>		A URI for the notation, which can be used to point to an application which can process resources of this notation type, or can be used as a key in a local map to find the application which should be used.'>

    name: aName identifiers: anArray [
	<category: 'initialize'>
	name := aName.
	anArray size = 2 
	    ifTrue: 
		[systemID := anArray at: 2.
		publicID := anArray at: 1]
	    ifFalse: [self error: 'Invalid PUBLIC / SYSTEM identifiers']
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    publicID [
	<category: 'accessing'>
	^publicID
    ]

    systemID [
	<category: 'accessing'>
	^systemID
    ]
]


Object subclass: DocumentType [
    | generalEntities parameterEntities notations declaredRoot |
    
    <category: 'XML-XML-Parsing'>
    <comment: '
This class represents an XML document type definition or DTD.

The document type declaration can point to an external subset
containing markup declarations, or can contain the markup declarations
directly in an internal subset, or can do both. The DTD for a document
consists of both subsets taken together.

Instance Variables:
    generalEntities		<Dictionary>		Definitions for the general entities that can be used in the body of the document.
    parameterEntities	<Dictionary>		Definitions for the parameter entities that can be used in the DTD of the document.
    notations			<Dictionary>		Notations defined in the DTD.
    declaredRoot 		<XML.NodeTag>		The NodeTag which the DTD declares will be the root element of the document--a document cannot be valid if this does not match the tag of the root element.'>

    DocumentType class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize'>
	notations := Dictionary new.
	generalEntities := Dictionary new.
	parameterEntities := Dictionary new
    ]

    declaredRoot [
	<category: 'accessing'>
	^declaredRoot
    ]

    declaredRoot: aTag [
	<category: 'accessing'>
	declaredRoot := aTag
    ]

    generalEntityAt: key [
	"We do some tricks to make sure that, if the value
	 is predefined in the parser, we use the predefined
	 value. We could just store the predefined values
	 in with the general ones, but we don't want to show
	 warnings if the user (very correctly) defines them.
	 An enhancement would be to let the user use his own
	 values rather than the predefined ones, but we know
	 that the predefined ones will be correct--we don't know
	 that his will be."

	<category: 'accessing'>
	| val |
	val := PredefinedEntities at: key ifAbsent: [].
	val == nil ifTrue: [val := generalEntities at: key ifAbsent: []].
	^val
    ]

    generalEntityAt: key put: value [
	<category: 'accessing'>
	generalEntities at: key put: value
    ]

    generalEntityAt: key put: value from: anErrorReporter [
	<category: 'accessing'>
	(generalEntities includesKey: key) 
	    ifTrue: 
		[^anErrorReporter 
		    warn: 'The general entity "%1" has been defined more than once' % {key}].
	generalEntities at: key put: value
    ]

    notationAt: name [
	<category: 'accessing'>
	^notations at: name ifAbsent: [nil]
    ]

    notationAt: name from: anErrorReporter [
	<category: 'accessing'>
	^notations at: name
	    ifAbsent: [anErrorReporter invalid: 'Reference to an undeclared Notation']
    ]

    notationAt: name ifAbsent: aBlock [
	<category: 'accessing'>
	^notations at: name ifAbsent: aBlock
    ]

    notationAt: name put: notation [
	<category: 'accessing'>
	notations at: name put: notation
    ]

    notationAt: name put: notation from: anErrorReporter [
	<category: 'accessing'>
	(notations includesKey: name) 
	    ifTrue: [anErrorReporter invalid: 'Duplicate definitions for a Notation'].
	notations at: name put: notation
    ]

    parameterEntityAt: key [
	<category: 'accessing'>
	^parameterEntities at: key ifAbsent: []
    ]

    parameterEntityAt: key put: value [
	<category: 'accessing'>
	parameterEntities at: key put: value
    ]

    parameterEntityAt: key put: value from: anErrorReporter [
	<category: 'accessing'>
	(parameterEntities includesKey: key) 
	    ifTrue: 
		[^anErrorReporter 
		    warn: 'The parameter entity "%1" has been defined more than once' % {key}].
	parameterEntities at: key put: value
    ]

    printCanonicalOn: aStream [
	"Jumping through hoops to get Notations printed
	 just as Sun desires--Are public IDs really supposed
	 to have their white space normalized? If so, we
	 should move normalization to the parser."

	<category: 'printing'>
	| s s1 |
	notations isEmpty ifTrue: [^self].
	aStream
	    nextPutAll: '<!DOCTYPE ';
	    nextPutAll: declaredRoot asString;
	    nextPutAll: ' [';
	    nl.
	(notations asSortedCollection: [:n1 :n2 | n1 name < n2 name]) do: 
		[:n | 
		aStream
		    nextPutAll: '<!NOTATION ';
		    nextPutAll: n name;
		    space.
		n publicID == nil 
		    ifTrue: [aStream nextPutAll: 'SYSTEM']
		    ifFalse: 
			[s := n publicID copy.
			s replaceAll: Character cr with: Character space.
			s replaceAll: Character nl with: Character space.
			s replaceAll: Character tab with: Character space.
			
			[s1 := s copyReplaceAll: '  ' with: ' '.
			s1 = s] whileFalse: [s := s1].
			aStream
			    nextPutAll: 'PUBLIC ''';
			    nextPutAll: s;
			    nextPut: $'].
		n systemID == nil 
		    ifFalse: 
			[aStream
			    nextPutAll: ' ''';
			    nextPutAll: n systemID;
			    nextPut: $'].
		aStream
		    nextPutAll: '>';
		    nl].
	aStream
	    nextPutAll: ']>';
	    nl
    ]

    saxDo: aDriver [
	<category: 'enumerating'>
	notations == nil 
	    ifFalse: 
		[notations do: 
			[:n | 
			aDriver 
			    notationDecl: n name
			    publicID: n publicID
			    systemID: n systemID]]
    ]
]


SAXDriver extend [
    isValidating [
	"Allows a SAX driver to act like a parser when accessing a DocumentType"

	<category: 'private'>
	^false
    ]

    invalid: aMessage [
	"Allows a SAX driver to act like a parser when accessing a DocumentType"

	<category: 'private'>
	self nonFatalError: (InvalidSignal new messageText: aMessage)
    ]

    malformed: aMessage [
	"Allows a SAX driver to act like a parser when accessing a DocumentType"

	<category: 'private'>
	self fatalError: (MalformedSignal new messageText: aMessage)
    ]

    warn: aMessage [
	"Allows a SAX driver to act like a parser when accessing a DocumentType"

	<category: 'private'>
	self warning: (WarningSignal new messageText: aMessage)
    ]
]


Object subclass: ElementContext [
    | tag type namespaces isExternal |
    
    <category: 'XML-XML-Parsing'>
    <comment: '
This class includes some functionality to support XML namespaces. XML
namespaces provide a simple method for qualifying element and
attribute names used in XML documents

Instance Variables:
    tag				<XML.NodeTag>					The name of the current element.
    type			<nil | XML.ConcretePattern>		A type definition for the current element, used to validate the contents.
    namespaces	<Dictionary>						A map from namespace qualifiers to namespace URIs, which is used to interpret the meaning of namespace qualifiers within the scope of the element.'>

    namespaces [
	<category: 'accessing'>
	namespaces == nil ifTrue: [namespaces := Dictionary new].
	^namespaces
    ]

    tag [
	<category: 'accessing'>
	^tag
    ]

    tag: aTag [
	<category: 'accessing'>
	tag := aTag isString 
		    ifTrue: 
			[NodeTag new 
			    qualifier: ''
			    ns: ''
			    type: aTag]
		    ifFalse: [aTag]
    ]

    type [
	<category: 'accessing'>
	^self shouldNotImplement
    ]

    type: anElementType [
	<category: 'accessing'>
	type := Array with: anElementType.
	isExternal := anElementType isExternal
    ]

    types [
	<category: 'accessing'>
	^type
    ]

    types: anArray [
	<category: 'accessing'>
	type := anArray
    ]

    defineDefaultNamespace: attribute [
	<category: 'namespaces'>
	self namespaces at: '' put: attribute value
    ]

    defineNamespace: attribute from: aParser [
	<category: 'namespaces'>
	(#('xmlns' 'xml') includes: attribute tag type) 
	    ifTrue: 
		[self error: 'It is illegal to redefine the qualifier "%1".' 
			    % {attribute tag type}].
	attribute value isEmpty 
	    ifTrue: 
		[aParser 
		    invalid: 'It is not permitted to have an empty URI as a namespace name'].
	self namespaces at: attribute tag type put: attribute value
    ]

    findNamespace: ns [
	<category: 'namespaces'>
	^namespaces isNil 
	    ifTrue: [nil]
	    ifFalse: [namespaces at: ns ifAbsent: [nil]]
    ]

    definesNamespaces [
	<category: 'testing'>
	^namespaces notNil and: [namespaces isEmpty not]
    ]

    isDefinedExternal [
	<category: 'testing'>
	^isExternal
    ]
]



Eval [
    XML at: #XML_URI put: 'http://www.w3.org/XML/1998/namespace'.
    XML at: #PredefinedEntities
	put: ((Dictionary new)
		at: 'amp'
		    put: ((GeneralEntity new)
			    name: 'amp';
			    text: '&#38;');
		at: 'lt'
		    put: ((GeneralEntity new)
			    name: 'lt';
			    text: '&#60;');
		at: 'gt'
		    put: ((GeneralEntity new)
			    name: 'gt';
			    text: (String with: $>));
		at: 'apos'
		    put: ((GeneralEntity new)
			    name: 'apos';
			    text: (String with: $'));
		at: 'quot'
		    put: ((GeneralEntity new)
			    name: 'quot';
			    text: (String with: $"));
		yourself).
]
