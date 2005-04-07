"======================================================================
|
|   VisualWorks XML Framework
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
| 330, Boston, MA 02111-1307, USA.
|
 ======================================================================"



Smalltalk addSubspace: #XML!
XML addSubspace: #SAX!

Namespace current: XML!

Object subclass: #XMLNodeBuilder
    instanceVariableNames: 'tagStack tags '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

XMLNodeBuilder comment: '
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
    tags			<Dictionary>		Currently not used. A map to make sure that within a document, tag identifiers are unique instances in order to save space.'!


Object subclass: #Node
    instanceVariableNames: 'parent flags '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Node comment: '
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
    flags	<SmallInteger> 			Provides a compact representation for any boolean attributes that the node might have. Likely to be removed in the near future.'!


Node subclass: #Entity
    instanceVariableNames: 'name text systemID publicID '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Entity comment: '
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
    					Alternative URI used to retrieve an external entity''s contents'!


Node subclass: #Document
    instanceVariableNames: 'root nodes dtd ids '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Document comment: '
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
    ids		<KeyedCollection | Dictionary>  		Map which converts ID names to Elements, allowing a simple cross reference within the document.'!


Node subclass: #Element
    instanceVariableNames: 'tag attributes namespaces elements userData definition '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Element comment: '
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
    definition		<Object>  						suspect this is unused'!


Node subclass: #Text
    instanceVariableNames: 'text stripped '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Text comment: '
A subclass of Node, this class represents an XML textual object,
i.e. a sequence of legal characters as defined in the XML 1.0
specification. Instances of XML.Text may represent either markup or
character data.

Instance Variables:
    text			<CharacterArray | nil>	the actual data of the Text.
    stripped	<Boolean>	Will be true if the text contains only white space and if the parser has determined that the client would not be interested in the data.'!


Entity subclass: #GeneralEntity
    instanceVariableNames: 'ndata definedExternally '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

GeneralEntity comment: '
This class represents a general entity which is a parsed entity for
use within the XML document content.

Instance Variables:
    ndata	<Notation>			Some general entities may have a notation associated with them which identifies how they are to be processed--this instace variable identifies that Notation.'!


Object subclass: #SAXDriver
    instanceVariableNames: 'locator '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

SAXDriver comment: '
This class includes supports for the Simple API for XML (SAX), an
event-driven API for parsing XML documents.

All methods defined in this class, other than those defined in the
"private" protocol, are Smalltalk-equivalent bindings of the SAX 2.0
API, and can be overridden according to the needs of subclasses.

Instance Variables:
    locator	<nil> place holder for SAX''s Locator, which allows better error recovery.'!


SAXDriver subclass: #SAXDispatcher
    instanceVariableNames: 'contentHandler dtdHandler entityResolver errorHandler '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

SAXDispatcher comment: '
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
    entityResolver		<XML.SAXDriver>		handles resolution of PUBLIC and SYSTEM paths
    											into InputSources, to allow non-standard resolution
    errorHandler		<XML.SAXDriver>		handles all errors
'!


Error subclass: #SAXException
    instanceVariableNames: 'wrappedException '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

SAXException comment: '
A special exception indicating an error in a SAX-compliant parser.

All errors when parsing XML *should* be converted to
SAXExceptions. Errors generated by the parser will usually be
instances of subclasses of SAXException. Errors generated by user
code, if caught, will usually be instances of other types of
Exception, and will be wrapped in an instance of SAXException to
simplify the task of an exception handler outside the parser.

Instance Variables:
    wrappedException	<Exception>  another exception, which has been wrapped so that a handler for SAXException will catch it.'!


Node subclass: #PI
    instanceVariableNames: 'name text '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

PI comment: '
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
    				the processing instructions themselves'!


Node subclass: #Notation
    instanceVariableNames: 'name publicID systemID '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Notation comment: '
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
    systemID	<String>		A URI for the notation, which can be used to point to an application which can process resources of this notation type, or can be used as a key in a local map to find the application which should be used.'!


SAXDriver subclass: #SAXBuilderDriver
    instanceVariableNames: 'builder document elementStack newNamespaces '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

SAXBuilderDriver comment: '
This class converts SAX events into XMLNodeBuilder events, allowing
old builders to still be used with the new parser.

This is essentially a private class for XMLParser to allow the parser
to pretend to still support the old NodeBuilder API.

Instance Variables:
    builder				<XML.XMLNodeBuilder>		The client''s NodeBuilder, which creates XML Nodes.
    document			<XML.Document>				The Document which models the entire XML document.
    elementStack		<OrderedCollection>			A stack of proxies for the various elements that are in scope at the current stage of parsing.
    newNamespaces	<Dictionary>					maps qualifiers to namespaces for the next element'!


Object subclass: #Pattern
    instanceVariableNames: 'followSet '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

Pattern comment: '
The element structure of an XML document may, for validation purposes,
be constrained using element type and attribute-list declarations. An
element type declaration constrains the element''s content by
constraining which element types can appear as children of the
element. The constraint includes a content model, a simple grammar or
pattern governing the allowed types of child elements and the order in
which they are allowed to appear. These content models are represented
by this XML.Pattern class and its subclasses.

Constraint rules or patterns may be complex (ComplexPattern and its
subclasses) or simple (ConcretePattern and its subclasses).
 
Subclasses must implement the following protocol:
    coercing
    	alternateHeads
    	pushDownFollowSet
    testing
    	isSimple

Instance Variables:
    followSet	<OrderedCollection>  A list of the Patterns which may follow this one in an element''s content.'!


Pattern subclass: #ConcretePattern
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

ConcretePattern comment: '
A subclass of Pattern, this class is the superclass to what are
considered ''simple'' patterns or constraint rules in the element
content declarations.

Subclasses of ConcretePattern include AnyPattern, EmptyPattern,
InitialPattern, NamePattern, PCDATAPattern and TerminalPattern.

Subclasses must implement the following messages:
    testing
    	matches:'!


ConcretePattern subclass: #TerminalPattern
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

TerminalPattern comment: '
Since an element''s content declaration may include multiple
constraint rules or patterns, instances of this class are used to
indicate to the XML parser, the last or terminal rule in the
declaration.'!


ConcretePattern subclass: #InitialPattern
    instanceVariableNames: 'isExternal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

InitialPattern comment: '
Since an element''s content declaration may include multiple
constraint rules or patterns, instances of this class are used to
indicate to the XML parser, the initial or first rule in the
declaration.'!


ConcretePattern subclass: #EmptyPattern
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

EmptyPattern comment: '
A subclass of ConcretePattern, this class represents the EMPTY element
content constraint in an element type declaration.

According to the XML 1.0 specification the EMPTY element declaration
indicates that the element has no content.'!


ConcretePattern subclass: #NamePattern
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

NamePattern comment: '
This class represents a content constraint in an element type
declaration such that the declaration includes the names of the
element types that may appear as children in the element''s content.

Instance Variables:
    name	<XML.NodeTag>		The tag of the element which is permitted by this pattern to appear in the content of some other element.'!


ConcretePattern subclass: #PCDATAPattern
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

PCDATAPattern comment: '
This class represents a content constraint or pattern in an element
type declaration indicating that the element content includes parsed
character data.

Parsed character data is typically used in mixed content type patterns
and is signified by the presence of the string ''#PCDATA'' in the
element content declaration.'!


Node subclass: #Attribute
    instanceVariableNames: 'name value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Attribute comment: '
XML elements may have name-value pairs called attributes associated
with them. This class instantiates a single XML attribute. Attribute
is a subclass of Node, both because the W3C DOM model defines it that
way, and because it provides a uniform API for applications such as
XSLT that want to do similar sorts of processing on attributes and
other node types.

Instance Variables:
    name	<XML.Node | XML.NodeTag>		tag name
    value	<Object>							tag value'!


Link subclass: #StreamWrapper
    instanceVariableNames: 'stream isInternal resource usedAsExternal entity cr lf parser line column '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

StreamWrapper comment: '
This class is used by the XML parser to wrap both internal and
external streams with proper encoding before handing them to the
parser for processing.

The streams passed to the parser may be either EncodedStreams or
simple text streams (such as a ReadStream on a String). If they are
EncodedStreams, this wrapper class silently checks the <?xml?>
declaration at the beginning of the stream to make sure that the
EncodedStream is using the right encoding, and if not, it changes the
encoding of the stream.

Instance Variables:
    stream			<EncodedStream>  stream being wrapped
    isInternal		<Boolean>  true if the stream is internal and hencer doesn''t need careful line-end treatment
    resource		<XML.InputSource> source of the data being parsed
    usedAsExternal	<Boolean>  flag used to override protocol and say how stream is being used?
    entity			<Entity | nil>  if wrapping on behalf of an Entity this is it?
    cr				<Character>  cache of Character cr
    lf				<Character>  cache of Character lf
    parser		<XML.XMLParser> the parser reading this stream
    line		<Integer> line number of the current parse location
    column		<Integer> column number on the current line'!


SAXDispatcher subclass: #XMLFilter
    instanceVariableNames: 'parent '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

XMLFilter comment: '
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
'!


Pattern subclass: #ComplexPattern
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

ComplexPattern comment: '
A subclass of Pattern, this class is the superclass to what are
considered ''complex'' patterns or rules in the element content
declarations.

Subclasses of ComplexPattern include ChoicePattern, MixedPattern,
ModifiedPattern and SequencePattern.'!


ComplexPattern subclass: #MixedPattern
    instanceVariableNames: 'items '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

MixedPattern comment: '
A subclass of ComplexPattern, this class represents the ''mixed''
element content constraint in an element type declaration.

An element type has mixed content when elements of that type may
contain both other child elements and character data (text) as
specified in the element content declaration.

Note: For mixed content type elements, one can''t control the order in
which the child elements, mixed in among the text, appear.

Instance Variables:
    items	<SequenceableCollection>  A list of NamedPatterns (as well as one PCDATAPattern) which can appear as content in the context controlled by the MixedPattern.'!


ComplexPattern subclass: #ChoicePattern
    instanceVariableNames: 'items '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

ChoicePattern comment: '
A subclass of ComplexPattern, this class represents the ''choice''
element content constraint in an element type declaration.

According to the XML 1.0 specification, the ''choice'' pattern/rule
signifies that any content particle in a choice list (declared in the
DTD) may appear in the element content at the location where the
choice list appears in the grammar.

Instance Variables:
    items	<Collection>
    			Collection of content particles'!


ComplexPattern subclass: #ModifiedPattern
    instanceVariableNames: 'node modification '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

ModifiedPattern comment: '
XML element content declarations can have certain optional characters
following an element name or pattern. These characters govern whether
the element or the content particle may occur one or more (+), zero or
more (*), or zero or one (?) times in the element content. This class
represents these patterns or rules.

Instance Variables:
    node			<XML.Pattern>		The base pattern which the ModifiedPattern influences.
    modification	<Character>		Optional character denoting content element occurances'!


SAXDriver subclass: #NullSAXDriver
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

NullSAXDriver comment: '
The XML parser requires some sort of SAXDriver to receive events. If
the client desires to simply do syntax checking on the document
without further processing, and wants minimal overhead, NullSAXDriver
will do the minimal possible processing while implementing the entire
SAX API.'!


Entity subclass: #ParameterEntity
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

ParameterEntity comment: '
This class represents a parameter entity which is a parsed entity for
use within the document type definition.'!


Object subclass: #Locator
    instanceVariableNames: 'parser '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

Locator comment: '
Locators allow SAX drivers to ask the parser where we are in the
current parse, for error reporting.

Instance Variables:
    parser			<XML.XMLParser>  the current parser'!


Object subclass: #XMLParser
    instanceVariableNames: 'sourceStack hereChar lastSource currentSource dtd unresolvedIDREFs definedIDs latestID sax elementStack validating flags eol buffer nameBuffer '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

XMLParser comment: '
XMLParser represents the main XML processor in the VisualWorks
environment.

As an XML processor, an instance of XMLParser is typically created by
a Smalltalk application, and then used to scan and process an XML
document, providing the application with access to its content and
structure.

Class XMLParser tries to follow the guidelines laid out in the W3C XML
Version 1.0 specification.

Instance Variables:
    sourceStack	<XML.StreamWrapper>	stack of input streams that handles inclusion.
    hereChar		<Character>  				the current character being parsed
    lastSource		<XML.StreamWrapper>	record of previous source used to check correct nesting
    currentSource	<XML.StreamWrapper>	current input stream (the top of sourceStack)
    dtd				<XML.DocumentType>	the document type definition for the current document
    unresolvedIDREFs		<Set>				collection of IDREfs that have yet to be resolved.
    											Used for validation
    definedIDs		<Set>						IDs that have already been seen.
    latestID		<nil | String>				the ID of the last start tag we found.
    sax				<XML.SAXDriver>			the output
    elementStack	<OrderedCollection>		a list of the elements that enclose the current parse location
    											(bookkeeping info)
    validating	<Boolean>						if true then the parse validates the XML
    flags		<SmallInteger>				sundry boolean values that are not accessed often enough
    											to need separate instance variables.
    eol			<Character>					the end-of-line character in the source stream
    buffer		<WriteStream>					temporary storage for data read from the input,
    											to save reallocating the stream
    nameBuffer	<WriteStream>				alternate buffer when "buffer" may be in use'!


SAXException subclass: #SAXParseException
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

SAXParseException subclass: #MalformedSignal
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

SAXParseException subclass: #InvalidSignal
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

SAXException subclass: #SAXNotSupportedException
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

Node subclass: #Comment
    instanceVariableNames: 'text '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

Comment comment: '
A concrete subclass of XML.Node, this class represents an XML comment.

XML comments may appear anywhere in an XML document outside other
markup or within the document type declaration at places allowed by
grammar. XML comments are delimited by the start-tag ''<!--'' and the
end-tag ''-->''.

According to the XML 1.0 specification, for compatibilty,
double-hyphens (the string ''--'') must not occur within comments.

Instance Variables:
    text		<String>  	contents of the comment element'!


SAXParseException subclass: #WarningSignal
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

Object subclass: #AttributeDef
    instanceVariableNames: 'name default type flags '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

AttributeDef comment: '
XML documents may contain attribute-list declarations that are used to
define the set of attributes pertaining to a given element type. These
attribute-list declarations are also used to establish type
constraints for the attributes and to provide default values for
attributes. Attribute-list declarations contain attribute definitions
and this class is used to instantiate these definitions.

An attribute definition in a DTD specifies the name (in an
AttributeDef instance, this is the name instance variable) of the
attribute, the data type of the attribute (type instance variable) and
an optional default value (default instance variable) for the
attribute.

Instance Variables:
    name	<XML.NodeTag> 		name of attribute
    default	<Object>  				default value, if any
    type	<XML.AttributeType>	type used for validation
    flags	<Integer>				encoding for fixed, implied and required type attributes'!


Document subclass: #DocumentFragment
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

DocumentFragment comment: '
DocumentFragment is a subclass of Document which can be used to model
documents which do not correctly conform to the XML standard. Such
fragments may contain text that is not contained within any element,
or may contain more than one element at the top level.

At present it is not possible to represent a Document fragment that
contains the start tag but not the end tag of an element, or contains
the end tag but not the start tag.  '!


SAXDriver subclass: #DOM_SAXDriver
    instanceVariableNames: 'stack document newNamespaces '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

DOM_SAXDriver comment: '
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
    newNamespaces	<Dictionary>				maps qualifiers to namespaces for the next element'!


ComplexPattern subclass: #SequencePattern
    instanceVariableNames: 'items '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

SequencePattern comment: '
This class represents the ''sequence'' element content constraint in
an element type declaration.

According to the XML 1.0 specification, the ''sequence'' pattern/rule
signifies that content particles occuring in a sequence list (declared
in the DTD) must each appear in the element content in the order given
in the list.

Instance Variables:
    items	<SequenceableCollection>		Collection of content particles'!


MalformedSignal subclass: #BadCharacterSignal
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

Magnitude subclass: #NodeTag
    instanceVariableNames: 'namespace type qualifier '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

NodeTag comment: '
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
    qualifier		<String>		In XML documents, the namespace is mapped to a qualifier, which is used as a prefix for the type. The namespace is assumed to be unique across all documents, but is quite clumsy. The qualifier is not unique across documents, but is unambiguous at the point where it is used and is short enough to be convenient. The qualifier may be the empty string if the namespace is empty or if the namespace is the current default namespace.'!


SAXException subclass: #SAXNotRecognizedException
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Exceptions'!

Object subclass: #DocumentType
    instanceVariableNames: 'attributeDefs elementDefs generalEntities parameterEntities notations declaredRoot '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

DocumentType comment: '
This class represents an XML document type definition or DTD.

The document type declaration can point to an external subset
containing markup declarations, or can contain the markup declarations
directly in an internal subset, or can do both. The DTD for a document
consists of both subsets taken together.

Instance Variables:
    attributeDefs		<Dictionary>			Type definitions of the attributes for each element.
    elementDefs		<Dictionary>		Type definitions for the elements that are legal in the document.
    generalEntities		<Dictionary>		Definitions for the general entities that can be used in the body of the document.
    parameterEntities	<Dictionary>		Definitions for the parameter entities that can be used in the DTD of the document.
    notations			<Dictionary>		Notations defined in the DTD.
    declaredRoot 		<XML.NodeTag>		The NodeTag which the DTD declares will be the root element of the document--a document cannot be valid if this does not match the tag of the root element.'!


Object subclass: #AttributeType
    instanceVariableNames: 'isExternal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

AttributeType comment: '
AttributeType is an abstract superclass that represents the type of an
XML attribute.

The XML 1.0 specification specifies that XML attribute types are of
three kinds: a string type, a set of tokenized types, and enumerated
types. The string type may take any literal string as a value, the
tokenized types have varying lexical and semantic constraints and the
enumerated type attibutes can take one of a list of values provided in
the declaration.

Subclasses of AttributeType represent the various types of XML
attributes, e.g., CDATA, for string types, and ID for tokenized
types.'!


AttributeType subclass: #NOTATION_AT
    instanceVariableNames: 'typeNames '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

NOTATION_AT comment: '
A concrete subclass of AttributeType, this class represents the
NOTATION attribute type.

A NOTATION attribute identifies a notation element, declared in the
DTD with associated system and/or public identifiers, to be used in
interpreting the element to which the attribute is attached.

Instance Variables:
    typeNames	<SequenceableCollection>	A list of the legal notation names that may be used for this attribute type.'!


AttributeType subclass: #NMTOKEN_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

NMTOKEN_AT comment: '
A concrete subclass of AttributeType, this class represents the
NMTOKEN attribute type.

This is a tokenized type of attribute and for the purposes of
validation, values of NMTOKEN type attributes must match a Nmtoken,
which is any mixture of legal name characters as defined in the XML
1.0 specification.'!


AttributeType subclass: #IDREF_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

IDREF_AT comment: '
A concrete subclass of AttributeType, this class represents the IDREF
attribute type.

This is a tokenized type of attribute and for an XML document to be
valid, values of IDREF type attributes must match the value of some ID
attribute on some element in the XML document.

ID and IDREF attributes together provide a simple inside-the-document
linking mechanism with every IDREF attribute required to point to an
ID attribute as stated above.'!


AttributeType subclass: #NMTOKENS_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

NMTOKENS_AT comment: '
A concrete subclass of AttributeType, this class represents the
NMTOKENS attribute type.

This is a tokenized type of attribute and for the purposes of
validation, values of each NMTOKENS type attributes must match each
Nmtoken, which is any mixture of legal name characters as defined in
the XML 1.0 specification.'!


AttributeType subclass: #ENTITY_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

ENTITY_AT comment: '
A concrete subclass of AttributeType, this class represents the ENTITY
attribute type.

This is a tokenized type of attribute that signifies to the XML parser
that for the purposes of validating, the values of entity type
attributes must match the name of an unparsed entity declared in the
document type definition.'!


AttributeType subclass: #CDATA_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

CDATA_AT comment: '
A concrete subclass of AttributeType, this class represents the CDATA
attribute type.

CDATA attributes are genericly typed attributes which, at the level of
interpretation done by XMLParser, have no constraints or semantics
applied to their contents.  '!


AttributeType subclass: #ID_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

ID_AT comment: '
A concrete subclass of AttributeType, this class represents the ID
attribute type. This is also a tokenized type of attribute and values
of ID type attributes must match legal names as defined in the XML 1.0
specification.

For an XML document to be valid, ID values must uniquely identify the
elements which bear them; i.e. a name must not appear more than once
in an XML document as a value of this type. Also for validity
purposes, an ID attribute must have a declared default of #IMPLIED or
#REQUIRED in the DTD.

ID and IDREF attributes together provide a simple inside-the-document
linking mechanism with every IDREF attribute required to point to an
ID attribute.'!


AttributeType subclass: #Enumeration_AT
    instanceVariableNames: 'values '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

Enumeration_AT comment: '
A concrete subclass of AttributeType, this class represents the
Enumeration attribute type.

Enumerated attributes can take one of a list of values provided in the declaration.

Instance Variables:
    values	<Collection>		A list of the possible values which the attribute may have.'!


AttributeType subclass: #IDREFS_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

IDREFS_AT comment: '
A concrete subclass of AttributeType, this class represents the IDREFS
attribute type.

This is a tokenized type of attribute and for an XML document to be
valid, each of the values of IDREFS type attributes must match each of
the values of some ID attribute on some element in the XML document.'!


AttributeType subclass: #ENTITIES_AT
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Attributes'!

ENTITIES_AT comment: '
A concrete subclass of AttributeType, this class represents the
ENTITIES attribute type.

This is a tokenized type of attribute that signifies to the XML parser
that for the purposes of validating, the values of entities type
attributes must match each of the names of unparsed entities declared
in the document type definition.'!


ConcretePattern subclass: #AnyPattern
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Patterns'!

AnyPattern comment: '
A subclass of ConcretePattern, this class represents the ANY element
content constraint in an element type declaration.

According to the XML 1.0 specification the ANY pattern/rule is used to
indicate to the validating parser that the element can contain any
elements in any order, as long as it doesn''t break any of the other
rules of XML and the types of any child elements have been declared.'!


LargeByteArray subclass: #CharacterTable
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Nodes'!

CharacterTable comment: '
Class CharacterTable is an optimization of its superclass
(LargeByteArray) that allows a smallish character table to masquerade
as a large table.

When the #at: primitive fails, the failure code checks to see if the
index exceeded the size of the collection. If so, it answers the
collection''s default value, which means that characters whose Unicode
values exceed a particular value will all be classified the same.'!


XMLNodeBuilder subclass: #NodeBuilder
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

NodeBuilder comment: '
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
protocol to do your parsing.'!


Object subclass: #ElementContext
    instanceVariableNames: 'tag type namespaces isExternal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Parsing'!

ElementContext comment: '
This class includes some functionality to support XML namespaces. XML
namespaces provide a simple method for qualifying element and
attribute names used in XML documents

Instance Variables:
    tag				<XML.NodeTag>					The name of the current element.
    type			<nil | XML.ConcretePattern>		A type definition for the current element, used to validate the contents.
    namespaces	<Dictionary>						A map from namespace qualifiers to namespace URIs, which is used to interpret the meaning of namespace qualifiers within the scope of the element.'!


ElementContext subclass: #SAXElementContext
    instanceVariableNames: 'attributes nodes stream startPosition id '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

SAXElementContext comment: '
This class holds all the descriptive information that SAXBuilderDriver
needs to remember from the startElement until the endElement, to send
the right information to the builder.


Instance Variables:
    attributes	<Collection> 
    nodes	<Array> 
    stream	<XML.StreamWrapper> 
    startPosition	<Integer> 
    id	<nil | String> '!


Object subclass: #InputSource
    instanceVariableNames: 'uri encoding stream '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-Resources'!

InputSource comment: '
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
    stream			<Stream>			the data source'!


SAXDriver subclass: #SAXWriter
    instanceVariableNames: 'output textMap attrMap hasOpenTag normalizeText notations newNamespaces '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

SAXWriter comment: '
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

'!


SAXWriter subclass: #SAXCanonicalWriter
    instanceVariableNames: 'baseURI '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XML-SAX'!

SAXCanonicalWriter comment: '
SAXCanonicalWriter is a subclass of SAXWriter that translates XML into
a textual form conforming to the Sun Canonical XML specification used
by the OASIS (http://www.oasis-open.org/) consortium in their XML
conformance tests.

Instance Variables:
    baseURI	<URI>	When parsing, this remembers the URI of the document so that relative URIs (in Notations, for example) can be resolved to absolute URIs.

'!


!XMLNodeBuilder methodsFor: 'initialize'!

initialize
    tagStack := OrderedCollection new.
    tags := Dictionary new.! !

!XMLNodeBuilder methodsFor: 'accessing'!

currentTag
    ^tagStack last tag!

popTag
    tagStack removeLast!

pushTag: tag
    tagStack addLast: (ElementContext new tag: tag).! !

!XMLNodeBuilder methodsFor: 'building'!

attribute: name value: value
    ^Attribute name: name value: value!

comment: aText
    ^Comment new text: aText!

makeText: text
    ^Text text: text!

notation: name value: val
    ^Notation new name: name identifiers: val!

pi: nm text: text
    ^PI new name: nm text: text! !

!XMLNodeBuilder class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!Node methodsFor: 'initialize'!

initialize
    flags := 0.! !

!Node methodsFor: 'accessing'!

children
    ^self shouldNotImplement!

discard
    self flags: (self flags bitOr: 1)!

document
    ^parent document!

expandedName
    ^''!

flags
    ^flags!

flags: flagBits
    flags := flagBits!

parent
    ^parent!

parent: aNode
    parent := aNode!

selectNodes: aBlock
    ^#()!

tag
    ^nil! !

!Node methodsFor: 'printing'!

canonicalPrintString
    | s |
    s := (String new: 1024) writeStream.
    self printCanonicalOn: s.
    ^s contents!

noIndentPrintString
    | s |
    s := (String new: 1024) writeStream.
    self printNoIndentOn: s.
    ^s contents!

printCanonical: text on: aStream
    "Print myself on the stream in the form described by James
    Clark's canonical XML."

    | d |
    d := Dictionary new.
    d at: Character cr put: '&#13;';
    	at: Character lf put: '&#10;';
    	at: Character tab put: '&#9;';
    	at: $& put: '&amp;';
    	at: $< put: '&lt;';
    	at: $> put: '&gt;';
    	at: $" put: '&quot;'.
    text do: [:c |
    	aStream nextPutAll: (d at: c ifAbsent: [String with: c])].!

printCanonicalOn: aStream
    "Print myself on the stream in the form described by James
    Clark's canonical XML."

    self saxDo: (SAXCanonicalWriter new output: aStream).!

printHTMLOn: aStream
    "Print myself on the stream in a form usual for HTML."

    self subclassResponsibility!

printNoIndentOn: aStream
    "Print myself on the stream with line breaks between adjacent
    elements, but no indentation."

    self printNoIndentOn: aStream
    	endSpacing: [:node :list | aStream nl]
    	spacing: [:node :list | aStream nl]!

printOn: aStream
    self printOn: aStream depth: 0!

printQuoted: text on: aStream
    "Print myself on the stream in the form described by James
    Clark's canonical XML."

    | d |
    d := Dictionary new.
    d at: $& put: '&amp;';
    	at: $< put: '&lt;';
    	at: $> put: '&gt;'.
    text do: [:c |
    	aStream nextPutAll: (d at: c ifAbsent: [String with: c])].!

simpleDescription
    ^self printString! !

!Node methodsFor: 'testing'!

hasAncestor: aNode
    | p |
    p := self parent.
    [p == nil] whileFalse:
    	[p == aNode ifTrue: [^true].
    	p := p parent].
    ^false!

hasSubNodes
    ^false!

isAttribute
    ^false!

isBlankText
    ^false!

isComment
    ^false!

isContent
    ^false!

isDiscarded
    ^(self flags bitAnd: 1) = 1!

isDocument
    ^false!

isElement
    ^false!

isLike: aNode
    ^self class == aNode class!

isProcessingInstruction
    ^false!

isText
    ^false!

precedes: aNode
    | n1 n2 |
    aNode document == self document
    	ifFalse: [self error: 'These nodes can''t be ordered. They are not in the same document.'].
    aNode == self document
    	ifTrue: [^false].
    self == self document
    	ifTrue: [^true].
    n1 := self.
    n2 := aNode.
    (n2 hasAncestor: n1) ifTrue: [^true].
    (n1 hasAncestor: n2) ifTrue: [^false].
    [n1 parent == n2 parent] whileFalse:
    	[[n1 parent hasAncestor: n2 parent] whileTrue: [n1 := n1 parent].
    	[n2 parent hasAncestor: n1 parent] whileTrue: [n2 := n2 parent].
    	n1 parent == n2 parent
    		ifFalse: [n1 := n1 parent. n2 := n2 parent]].
    ^(n1 parent indexOf: n1) < (n1 parent indexOf: n2)! !

!Node methodsFor: 'enumerating'!

nodesDo: aBlock
    aBlock value: self! !

!Node methodsFor: 'namespaces'!

findNamespaceAt: qualifier
    | ns node |
    qualifier = 'xml' ifTrue: [^XML_URI].
    ns := nil.
    node := self.
    [node isElement and: [ns == nil]]
    	whileTrue:
    		[ns := node namespaceAt: qualifier.
    		node := node parent].
    ^ns!

findQualifierAtNamespace: ns
    | qual node |
    qual := nil.
    node := self.
    [node isElement and: [qual == nil]]
    	whileTrue:
    		[qual := node qualifierAtNamespace: ns.
    		node := node parent].
    ^qual!

namespaceAt: qualifier
    ^nil!

qualifierAtNamespace: ns
    ^nil! !

!Node class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!Entity methodsFor: 'accessing'!

entityType
    ^self subclassResponsibility!

externalFrom: anArray
    anArray class == Array
    	ifFalse: [self error: 'External ID is expected to be an Array'].
    anArray size = 2
    	ifTrue:
    		[publicID := anArray at: 1.
    		systemID := anArray at: 2]
    	ifFalse:
    		[self error: 'External ID has too many or too few identifiers']!

name
    ^name!

name: aName
    name := aName!

publicID
    ^publicID!

streamFor: aParser
    (aParser hasExpanded: self)
    	ifTrue: [aParser malformed: 'Can''t expand this entity; it is defined recursively'].
    text == nil
    	ifTrue:
    		[| str input |
    		input := aParser saxDriver
    			resolveEntity: self publicID
    			systemID: self systemID.
    		input == nil ifTrue: [input := InputSource for: self systemID].
    		aParser pushSource: (str := StreamWrapper
    							resource: input
    							entity: self
    							from: aParser).
    		str textDecl.
    		aParser getNextChar]
    	ifFalse:
    		[aParser pushSource: (StreamWrapper
    							resource: (InputSource uri: nil encoding: nil stream: text readStream)
    							entity: self
    							from: aParser).
    		aParser getNextChar].!

systemID
    ^systemID!

text: aString
    text := aString! !

!Entity methodsFor: 'testing'!

isExternal
    ^publicID notNil or: [systemID notNil]!

isParsed
    ^true! !

!Entity methodsFor: 'printing'!

printOn: aStream
    self basicPrintOn: aStream.
    text == nil
    	ifTrue: [aStream nextPutAll: '(',self systemID,')']
    	ifFalse: [aStream nextPutAll: '(',text,')']! !

!Document methodsFor: 'initialize'!

initialize
    super initialize.
    nodes := OrderedCollection new.
    ids := Dictionary new! !

!Document methodsFor: 'accessing'!

addNamespaceDefinitions
    | d tag |
    d := Dictionary new.
    self nodesDo: [:aNode |
    	tag := aNode tag.
    	tag isNil
    		ifFalse:
    			[(d at: tag qualifier ifAbsent: [tag namespace]) = tag namespace
    				ifFalse: [self error: 'Using the same tag for multiple namespaces is not currently supported'].
    			d at: tag qualifier put: tag namespace]].
    (d at: '' ifAbsent: ['']) = ''
    	ifTrue: [d removeKey: '' ifAbsent: []].
    d removeKey: 'xml' ifAbsent: [].
    d removeKey: 'xmlns' ifAbsent: [].
    self root == nil ifFalse: [self root namespaces: d]!

addNode: aNode
    nodes add: aNode.
    aNode parent: self.
    aNode isElement
    	ifTrue: [root == nil
    		ifTrue: [root := aNode]
    		ifFalse: [self error: 'It is illegal to have more than one element node at the top level in a document']]!

atID: id ifAbsent: aBlock
    ^ids at: id ifAbsent: aBlock!

atID: id put: element
    ids at: id put: element!

children
    ^nodes!

document
    ^self!

dtd
    ^dtd!

dtd: aDTD
    dtd := aDTD!

elements
    ^nodes!

indexOf: aChild
    aChild parent == self ifFalse: [^nil].
    ^self children identityIndexOf: aChild ifAbsent: [nil]!

root
    ^root!

selectNodes: aBlock
    ^nodes select: aBlock!

setRoot: aNode
    root := aNode! !

!Document methodsFor: 'testing'!

hasSubNodes
    ^nodes size > 0!

isContent
    ^true!

isDocument
    ^true! !

!Document methodsFor: 'printing'!

printHTMLOn: aStream
    nodes do: [:n | n printHTMLOn: aStream]!

printOn: aStream
    nodes do: [:n | n printOn: aStream. aStream nl]!

printSunCanonicalOn: aStream
    self dtd notNil
    	ifTrue: [self dtd printCanonicalOn: aStream].
    nodes do: [:n | n printCanonicalOn: aStream]! !

!Document methodsFor: 'enumerating'!

nodesDo: aBlock
    aBlock value: self.
    1 to: self elements size do: [:i |
    	(self elements at: i) nodesDo: aBlock]!

saxDo: aDriver
    aDriver startDocument.
    self dtd == nil ifFalse: [self dtd saxDo: aDriver].
    1 to: self children size do: [:i |
    	(self children at: i) saxDo: aDriver].
    aDriver endDocument! !

!Element methodsFor: 'initialize'!

initialize
    super initialize.
    tag := 'undefined'.
    attributes := #().! !

!Element methodsFor: 'accessing'!

anyElementNamed: elementName
    "This will return the receiver if its name matches the requirement."

    | list |
    list := self anyElementsNamed: elementName.
    list size > 1 ifTrue: [self error: 'There is not a unique element with this tag'].
    ^list isEmpty ifFalse: [list first]!

anyElementsNamed: elementName
    "This includes the receiver as one of the possibilities."

    | list |
    list := OrderedCollection new.
    self nodesDo: [:e |
    	(e isElement and: [e tag isLike: elementName])
    		ifTrue: [list add: e]].
    ^list!

attributes
    ^attributes == nil
    	ifTrue: [#()]
    	ifFalse: [attributes]!

characterData
    | str all |
    all := self elements.
    all size = 0 ifTrue: [^''].
    all size = 1 ifTrue: [^all first characterData].
    str := (String new: 128) writeStream.
    self characterDataOnto: str.
    ^str contents!

characterDataOnto: str
    self elements do: [:i |
    	i isContent ifTrue: [i characterDataOnto: str]].!

children
    ^elements == nil
    	ifTrue: [#()]
    	ifFalse: [elements]!

definition
    ^definition!

definition: aPattern
    definition := aPattern!

description
    ^'an <%1> element' bindWith: tag!

elementNamed: elementName
    | list |
    list := self elementsNamed: elementName.
    list size = 1 ifFalse: [self error: 'There is not a unique element with this tag'].
    ^list first!

elements
    ^elements == nil
    	ifTrue: [#()]
    	ifFalse: [elements]!

elementsNamed: elementName
    ^self elements select: [:e | e isElement and: [e tag isLike: elementName]]!

expandedName
    ^tag expandedName!

indexOf: aChild
    aChild parent == self ifFalse: [^nil].
    ^aChild isAttribute
    	ifTrue: [-1]
    	ifFalse: [elements identityIndexOf: aChild ifAbsent: [nil]]!

namespaces: aDictionaryOrNil
    namespaces := aDictionaryOrNil!

selectNodes: aBlock
    ^self attributes, self elements select: aBlock!

tag
    ^tag!

userData
    ^userData!

userData: anObject
    userData := anObject!

valueOfAttribute: attributeName ifAbsent: aBlock
    ^(self attributes
    	detect: [:a | a tag isLike: attributeName]
    	ifNone: [^aBlock value]) value! !

!Element methodsFor: 'printing'!

printHTMLOn: aStream
    | elem |
    self saxDo: (SAXWriter new output: aStream)
    	forBodyDo:
    		[elem := elements == nil
    			ifTrue: [#()]
    			ifFalse: [elements" reject: [:str | str isBlankText]"].
    		self isHTMLBlock ifTrue: [aStream nl].
    		elem do: [:e |
    			e printHTMLOn: aStream.
    			self isHTMLBlock ifTrue: [aStream nl]]]!

printOn: aStream depth: indent
    | elem |
    self saxDo: (SAXWriter new output: aStream)
    	forBodyDo:
    		[elements == nil
    			ifFalse:
    				[elem := elements reject: [:str | str isText and: [str isStripped]].
    				(elem size <= 1 and: [(elem contains: [:n | n isText not]) not])
    					ifTrue: [elem do: [:e |
    								e printOn: aStream depth: indent + 1]]
    					ifFalse:
    						[1 to: elem size do: [:i | | e |
    							e := elem at: i.
    							aStream nl; space: indent + 1.
    							e isString 
    								ifTrue: [aStream nextPutAll: e]
    								ifFalse: [e printOn: aStream depth: indent + 1]].
    						aStream nl; space: indent]]]!

simpleDescription
    ^'<', self tag asString, '>'! !

!Element methodsFor: 'namespaces'!

namespaceAt: qualifier
    ^namespaces == nil
    	ifTrue: [nil]
    	ifFalse: [namespaces at: qualifier ifAbsent: [nil]]!

qualifierAtNamespace: ns
    ^namespaces == nil
    	ifTrue: [nil]
    	ifFalse:
    		[namespaces keysAndValuesDo: 
    			[:qualifier :namespace | namespace = ns ifTrue: [^qualifier]].
    		nil]! !

!Element methodsFor: 'private'!

attributes: a
    attributes := a.
    a == nil ifFalse: [a do: [:i | i parent: self]].!

condenseList
    elements == nil
    	ifFalse: [elements size = 0
    		ifTrue: [elements := nil]
    		ifFalse: [elements := elements asArray]]!

condenseText
    | elmts str tc |
    elmts := (Array new: elements size) writeStream.
    str := nil.
    elements do: [:elm |
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
    elements := elmts contents.!

elements: e
    elements := e.
    self isEmpty
    	ifFalse:
    		[self condenseText.
    		elements do: [:elm | elm parent: self]]!

setTag: t attributes: a elements: e
    tag := t isString
    		ifTrue: [NodeTag new qualifier: '' ns: '' type: t]
    		ifFalse: [t].
    self attributes: a.
    self elements: e! !

!Element methodsFor: 'testing'!

hasSubNodes
    ^elements size > 0 or: [attributes size > 0]!

isContent
    ^true!

isElement
    ^true!

isEmpty
    ^elements == nil!

isHTMLBlock
    ^#('p' 'html' 'head' 'body') includes: tag asLowercase!

isLike: aNode
    ^self class == aNode class
    	and: [self tag isLike: aNode tag]!

notEmpty
    ^elements ~~ nil! !

!Element methodsFor: 'enumerating'!

nodesDo: aBlock
    aBlock value: self.
    1 to: self attributes size do: [:i |
    	(self attributes at: i) nodesDo: aBlock].
    1 to: self elements size do: [:i |
    	(self elements at: i) nodesDo: aBlock]!

saxDo: aDriver
    namespaces == nil
    	ifFalse: [namespaces keysAndValuesDo: [:qual :uri |
    		aDriver startPrefixMapping: qual uri: uri]].
    aDriver startElement: self tag namespace
    		localName: self tag type
    		qName: self tag asString
    		attributes: self attributes.
    1 to: self children size do: [:i |
    	(self children at: i) saxDo: aDriver].
    aDriver endElement: self tag namespace
    		localName: self tag type
    		qName: self tag asString.
    namespaces == nil
    	ifFalse: [namespaces keysAndValuesDo: [:qual :uri |
    		aDriver endPrefixMapping: qual]].!

saxDo: aDriver forBodyDo: aBlock
    "a variation on #saxDo: that lets the client
    control how the body of the element is to be
    printed."

    namespaces == nil
    	ifFalse: [namespaces keysAndValuesDo: [:qual :uri |
    		aDriver startPrefixMapping: qual uri: uri]].
    aDriver startElement: self tag namespace
    		localName: self tag type
    		qName: self tag asString
    		attributes: self attributes.
    (aDriver respondsTo: #closeOpenTag) ifTrue: [aDriver closeOpenTag].
    aBlock value.
    aDriver endElement: self tag namespace
    		localName: self tag type
    		qName: self tag asString.
    namespaces == nil
    	ifFalse: [namespaces keysAndValuesDo: [:qual :uri |
    		aDriver endPrefixMapping: qual]].! !

!Element methodsFor: 'modifying'!

addAttribute: aNode
    attributes isNil ifTrue: [
        attributes := OrderedCollection new ].
    (attributes class == OrderedCollection)
        ifFalse: [ attributes := attributes asOrderedCollection ].

    attributes add: aNode!

addNode: aNode
    aNode parent: self.
    elements == nil
    	ifTrue: [elements := OrderedCollection new: 5]
    	ifFalse: [elements class == Array
    		ifTrue: [elements := elements asOrderedCollection]].
    elements addLast: aNode!

removeAttribute: aNode
    attributes isNil ifFalse: [
        (attributes class == OrderedCollection)
            ifFalse: [ attributes := attributes asOrderedCollection ].
        attributes remove: aNode ifAbsent: [ ].
        attributes isEmpty ifTrue: [ attributes := nil ]
    ]!

removeNode: aNode
    elements isNil ifFalse: [
        (elements class == OrderedCollection)
            ifFalse: [ elements := elements asOrderedCollection ].
        elements remove: aNode ifAbsent: [ ].
        elements isEmpty ifTrue: [ elements := nil ]
    ]! !

!Element class methodsFor: 'instance creation'!

tag: tag
    ^self new setTag: tag attributes: nil elements: nil!

tag: tag attributes: attributes elements: elements
    ^self new setTag: tag attributes: attributes elements: elements!

tag: tag elements: elements
    ^self new setTag: tag attributes: nil elements: elements! !

!Text methodsFor: 'accessing'!

characterData
    ^self text!

characterDataOnto: str
    str nextPutAll: self text!

description
    ^'text'!

strip: aBoolean
    stripped := aBoolean.!

text
    ^text!

text: aText
    text := aText.
    stripped == nil ifTrue: [stripped := false].! !

!Text methodsFor: 'printing'!

printHTMLOn: aStream
    text == nil ifTrue: [^self].
    self isStripped
    	ifFalse: [self printCanonical: text on: aStream.]!

printOn: aStream depth: indent
    text == nil
    	ifTrue: [aStream nextPutAll: '&nil;']
    	ifFalse: [self printQuoted: text on: aStream].! !

!Text methodsFor: 'testing'!

isBlankText
    ^(text contains: [:i | i isSeparator not]) not!

isContent
    ^true!

isStripped
    ^stripped!

isText
    ^true! !

!Text methodsFor: 'enumerating'!

saxDo: aDriver
    aDriver characters: text from: 1 to: text size! !

!Text class methodsFor: 'instance creation'!

text: aString
    ^self new text: aString! !

!GeneralEntity methodsFor: 'accessing'!

entityType
    ^'generic'!

isDefinedExternally
    ^definedExternally!

isDefinedExternally: aBoolean
    definedExternally := aBoolean!

ndata: aNotifierNameOrNil
    ndata := aNotifierNameOrNil! !

!GeneralEntity methodsFor: 'testing'!

isParsed
    ^ndata == nil! !

!GeneralEntity methodsFor: 'validation'!

completeValidationAgainst: aParser
    ndata isNil
    	ifFalse: [aParser dtd notationAt: ndata ifAbsent:
    			[aParser invalid: ('Unparsed entity "%1" uses an undeclared notation "%2"'
    					bindWith: name
    					with: ndata)]]! !

!SAXDriver methodsFor: 'other'!

comment: data from: start to: stop!
idOfElement: elementID
    "Notify the client what was the ID of the latest startElement"!

sourcePosition: position inStream: streamWrapper
    "Non-standard API to ease transition from
    builders to SAX."! !

!SAXDriver methodsFor: 'content handler'!

characters: aString!
characters: aString from: start to: stop
    ^self characters: (aString copyFrom: start to: stop)!

endDocument!
endDocumentFragment
    "Nonstandard extension to SAX"!

endElement: namespaceURI localName: localName qName: name
    "indicates the end of an element. See startElement"!

endPrefixMapping: prefix 
    "End the scope of a prefix-URI mapping.

    See startPrefixMapping for details. This event will always 
    occur after the corresponding endElement event, but the 
    order of endPrefixMapping events is not otherwise 
    guaranteed. 
    
    Parameters: 
    prefix - The prefix that was being mapped.
    "

    ^self!

ignorableWhitespace: aString!
ignorableWhitespace: aString from: start to: stop
    ^self ignorableWhitespace: (aString copyFrom: start to: stop)!

processingInstruction: targetString data: dataString!
setDocumentLocator: aLocator
    locator := aLocator!

skippedEntity: name 
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

    ^self!

startDocument!
startDocumentFragment
    "Nonstandard extension to SAX"!

startElement: namespaceURI localName: localName qName: name attributes: attributes
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

    Note the attribute object also have namespaces
"!

startPrefixMapping: prefix uri: uri 
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

    ^self! !

!SAXDriver methodsFor: 'error handler'!


fatalError: anException
    anException signal!

nonFatalError: anException
    anException signal!

warning: anException
    Transcript nl; show: anException messageText! !

!SAXDriver methodsFor: 'DTD handler'!

notationDecl: nameString publicID: publicIDString systemID: systemIDString 
    "Receive notification of a notation declaration event. 
    
    It is up to the application to record the notation for later
    reference, if necessary. 
    
    If a system identifier is present, and it is a URL, the SAX
    parser must resolve it fully before passing it to the application."!

unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation 
    "Receive notification of an unparsed entity declaration 
    event. 
    
    Note that the notation name corresponds to a notation 
    reported by the notationDecl event. It is up to the 
    application to record the entity for later reference, if 
    necessary. 
    
    If the system identifier is a URL, the parser must resolve it 
    fully before passing it to the application.
    "

    ^self! !

!SAXDriver methodsFor: 'entity resolver'!

resolveEntity: publicID systemID: systemID
    ^nil! !

!SAXDriver methodsFor: 'accessing'!

contentHandler
    ^self!

document
    ^nil!

dtdHandler
    ^self!

entityResolver
    ^self!

errorHandler
    ^self! !

!SAXDriver methodsFor: 'private'!

invalid: aMessage
    "Allows a SAX driver to act like a parser when accessing a DocumentType"

    self nonFatalError: (InvalidSignal new messageText: aMessage)!

isValidating
    "Allows a SAX driver to act like a parser when accessing a DocumentType"

    ^false!

malformed: aMessage
    "Allows a SAX driver to act like a parser when accessing a DocumentType"

    self fatalError: (MalformedSignal new messageText: aMessage)!

warn: aMessage
    "Allows a SAX driver to act like a parser when accessing a DocumentType"

    self warning: (WarningSignal new messageText: aMessage)! !

!SAXDispatcher methodsFor: 'accessing'!

contentHandler
    ^contentHandler!

contentHandler: aSAXDriver
    contentHandler := aSAXDriver!

document
    ^contentHandler document!

dtdHandler
    ^dtdHandler!

dtdHandler: aSAXDriver
    dtdHandler := aSAXDriver!

entityResolver
    ^entityResolver!

entityResolver: aSAXDriver
    entityResolver := aSAXDriver!

errorHandler
    ^errorHandler!

errorHandler: aSAXDriver
    errorHandler := aSAXDriver! !

!SAXDispatcher methodsFor: 'other'!

comment: data from: start to: stop
    contentHandler comment: data from: start to: stop!

idOfElement: elementID
    contentHandler idOfElement: elementID!

sourcePosition: position inStream: stream
    contentHandler sourcePosition: position inStream: stream! !

!SAXDispatcher methodsFor: 'content handler'!

characters: aString from: start to: stop
    contentHandler characters: aString from: start to: stop!

endDocument
    contentHandler endDocument!

endDocumentFragment
    contentHandler endDocumentFragment!

endElement: namespaceURI localName: localName qName: name
    contentHandler endElement: namespaceURI localName: localName qName: name!

endPrefixMapping: prefix
    contentHandler endPrefixMapping: prefix!

ignorableWhitespace: aString from: start to: stop
    contentHandler ignorableWhitespace: aString from: start to: stop!

processingInstruction: targetString data: dataString
    contentHandler processingInstruction: targetString data: dataString!

setDocumentLocator: aLocator
    contentHandler setDocumentLocator: aLocator!

skippedEntity: name
    contentHandler skippedEntity: name!

startDocument
    contentHandler startDocument!

startDocumentFragment
    contentHandler startDocumentFragment!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    contentHandler startElement: namespaceURI localName: localName qName: name attributes: attributes!

startPrefixMapping: prefix uri: uri
    contentHandler startPrefixMapping: prefix uri: uri! !

!SAXDispatcher methodsFor: 'DTD handler'!

notationDecl: nameString publicID: publicIDString systemID: systemIDString
    dtdHandler notationDecl: nameString publicID: publicIDString systemID: systemIDString!

unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation
    dtdHandler unparsedEntityDecl: name publicID: publicID systemID: systemID notationName: notation! !

!SAXDispatcher methodsFor: 'initialize'!

initialize
    contentHandler := NullSAXDriver new.
    dtdHandler := contentHandler.
    entityResolver := contentHandler.
    errorHandler := contentHandler.! !

!SAXDispatcher methodsFor: 'entity resolver'!

resolveEntity: publicID systemID: systemID
    ^entityResolver resolveEntity: publicID systemID: systemID! !

!SAXDispatcher methodsFor: 'error handler'!

fatalError: anException
    errorHandler fatalError: anException!

nonFatalError: anException
    errorHandler nonFatalError: anException!

warning: anException
    errorHandler warning: anException! !

!SAXDispatcher class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!SAXException methodsFor: 'accessing'!

wrappedException
    ^wrappedException!

wrappedException: anException
    wrappedException := anException! !

!SAXException class methodsFor: 'testing'!

mayResume
    ^true! !

!PI methodsFor: 'initialize'!

name: nm text: aString
    name := nm.
    text := aString! !

!PI methodsFor: 'accessing'!

name
    ^name!

text
    ^text! !

!PI methodsFor: 'printing'!

printHTMLOn: aStream
    aStream nextPutAll: '<?', name, ' ', text, '?>'!

printOn: aStream depth: indent
    aStream nextPutAll: '<?', name, ' ', text, '?>'! !

!PI methodsFor: 'testing'!

isLike: aNode
    ^self class == aNode class
    	and: [self name isLike: aNode name]!

isProcessingInstruction
    ^true! !

!PI methodsFor: 'enumerating'!

saxDo: aDriver
    aDriver processingInstruction: name data: text! !

!PI class methodsFor: 'instance creation'!

name: nm text: aString
    ^self new name: nm text: aString! !

!Notation methodsFor: 'initialize'!

name: aName identifiers: anArray
    name := aName.
    anArray size = 2
    	ifTrue:
    		[systemID := anArray at: 2.
    		publicID := anArray at: 1]
    	ifFalse: [self error: 'Invalid PUBLIC / SYSTEM identifiers']! !

!Notation methodsFor: 'accessing'!

name
    ^name!

publicID
    ^publicID!

systemID
    ^systemID! !

!SAXBuilderDriver methodsFor: 'content handler'!

characters: aString
    | text |
    text := builder makeText: aString.
    text isDiscarded
    	ifFalse: [elementStack last nodes add: text].!

endDocument!
endDocumentFragment
    ^self endDocument!

endElement: namespaceURI localName: localName qName: name
    "indicates the end of an element. See startElement"

    | elm element |
    elm := elementStack last.
    element := builder
    		tag: elm tag
    		attributes: elm attributes
    		elements: (elm nodes isEmpty
    				ifTrue: [nil]
    				ifFalse: [elm nodes asArray])
    		position: elm startPosition
    		stream: elm stream.
    element namespaces: elm namespaces.
    elementStack removeLast.
    elementStack isEmpty
    	ifTrue:
    		[document addNode: element.
    		document dtd declaredRoot: element tag asString]
    	ifFalse: [element isDiscarded
    		ifFalse: [elementStack last nodes add: element]].
    (element isDiscarded not and: [elm id notNil])
    	ifTrue: [document atID: elm id put: element].
    builder popTag!

ignorableWhitespace: aString
    | text |
    text := builder makeText: aString.
    text isDiscarded
    	ifFalse: [elementStack last nodes add: text].!

processingInstruction: targetString data: dataString
    | pi |
    document == nil ifTrue: [self startDocument].
    pi := builder pi: targetString text: dataString.
    elementStack isEmpty
    	ifTrue: [document addNode: pi]
    	ifFalse: [elementStack last nodes add: pi]!

startDocument
    document := Document new.
    document dtd: DocumentType new.
    elementStack := OrderedCollection new.!

startDocumentFragment
    document := DocumentFragment new.
    document dtd: DocumentType new.
    elementStack := OrderedCollection new.!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    | nm |
    document == nil ifTrue: [self startDocument].
    nm := NodeTag new
    	qualifier: ((name includes: $:)
    			ifTrue: [name copyUpTo: $:]
    			ifFalse: [''])
    	ns: namespaceURI
    	type: localName.
    elementStack addLast: (SAXElementContext new tag: nm).
    elementStack last
    	attributes: (attributes collect: [:att | att copy]);
    	nodes: OrderedCollection new;
    	namespaces: newNamespaces.
    newNamespaces := nil.
    builder pushTag: nm.!

startPrefixMapping: prefix uri: uri 
    newNamespaces == nil
    	ifTrue: [newNamespaces := Dictionary new].
    newNamespaces at: prefix put: uri.! !

!SAXBuilderDriver methodsFor: 'other'!

comment: data from: start to: stop
    | comment |
    document == nil ifTrue: [self startDocument].
    comment := builder comment: (data copyFrom: start to: stop).
    comment isDiscarded
    	ifFalse: [elementStack isEmpty
    		ifTrue: [document addNode: comment]
    		ifFalse: [elementStack last nodes add: comment]].!

idOfElement: elementID
    "Notify the client what was the ID of the latest startElement"

    elementStack last id: elementID!

sourcePosition: position inStream: streamWrapper
    "Non-standard API to ease transition from
    builders to SAX."

    elementStack last
    	startPosition: position;
    	stream: streamWrapper! !

!SAXBuilderDriver methodsFor: 'accessing'!

builder: aNodeBuilder
    builder := aNodeBuilder!

document
    ^document! !

!SAXBuilderDriver methodsFor: 'DTD handler'!

notationDecl: name publicID: publicID systemID: systemID
    | notation |
    notation := builder notation: name value: (Array with: publicID with: systemID).
    document dtd notationAt: name put: notation from: self! !

!Pattern methodsFor: 'initialize'!

followSet: aCollection
    followSet := aCollection!

initialize
    followSet := OrderedCollection new: 2! !

!Pattern methodsFor: 'coercing'!

addFollow: aNode
    followSet add: aNode!

addFollows: aList
    followSet addAll: aList!

alternateHeads
    ^self subclassResponsibility!

followSet
    ^followSet!

normalize
    | list done t r result |
    list := OrderedCollection
    		with: (result := InitialPattern new addFollow: self)
    		with: self
    		with: TerminalPattern new.
    self addFollow: list last.
    done := OrderedCollection new.
    [list isEmpty]
    	whileFalse:
    		[t := list removeFirst.
    		r := t pushDownFollowSet.
    		r == nil
    			ifTrue: [done add: t]
    			ifFalse: [list addAll: r]].
    list := done.
    done := OrderedCollection new.
    [list isEmpty]
    	whileFalse:
    		[t := list removeFirst.
    		t normalizeFollowSet
    			ifTrue: [done add: t]
    			ifFalse: [list add: t]].
    done do: [:p |
    	p isSimple ifFalse: [self error: 'Incomplete translation'].
    	p followSet do: [:p1 |
    		p1 isSimple ifFalse: [self error: 'Incomplete translation']]].
    ^result!

normalizeFollowSet
    | changed oldFollow newFollow |
    oldFollow := IdentitySet withAll: followSet.
    newFollow := IdentitySet new.
    oldFollow do: [:pat |
    	newFollow addAll: pat alternateHeads].
    changed := newFollow size ~= oldFollow size or: [(newFollow - oldFollow) size > 0].
    followSet := newFollow asOrderedCollection.
    ^changed not!

normalizeFor: aParser
    | list done t r result |
    list := OrderedCollection
    		with: (result := InitialPattern new addFollow: self)
    		with: self
    		with: TerminalPattern new.
    self addFollow: list last.
    done := OrderedCollection new.
    [list isEmpty]
    	whileFalse:
    		[t := list removeFirst.
    		r := t pushDownFollowSet.
    		done add: t.
    		r == nil
    			ifFalse: [list addAll: r]].
    done do: [:nd || replacements |
    	replacements := nd alternateHeads.
    	(replacements size = 1 and: [replacements first == nd])
    		ifFalse: [done do: [:nd2 |
    			nd2 replaceFollowSet: nd with: replacements]]].
    done := IdentitySet new.
    list := OrderedCollection with: result.
    [list isEmpty]
    	whileFalse:
    		[t := list removeLast.
    		t isSimple
    			ifFalse: [aParser malformed: 'Incomplete translation'].
    		(self duplicatesNeedTested and: [t hasDuplicatesInFollowSet])
    			ifTrue: [aParser warn: ('Nondeterministic content model %1'
    							bindWith: self printString)].
    		done add: t.
    		t followSet do: [:t1 |
    			(done includes: t1) ifFalse: [list add: t1]]].
    ^result!

pushDownFollowSet
    ^self subclassResponsibility!

replaceFollowSet: node with: nodes
    (followSet includes: node)
    	ifTrue: [followSet := (IdentitySet withAll: followSet)
    					remove: node;
    					addAll: nodes;
    					asArray].! !

!Pattern methodsFor: 'testing'!

duplicatesNeedTested
    ^true!

isSimple
    ^self subclassResponsibility! !

!Pattern methodsFor: 'copying'!

postCopy
    super postCopy.
    followSet := OrderedCollection new: 2.! !

!Pattern class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!ConcretePattern methodsFor: 'accessing'!

followSetDescription
    | s |
    s := (String new: 32) writeStream.
    s nextPut: $(.
    followSet do: [:n | s nextPutAll: n printString]
    	separatedBy: [s space].
    s nextPut: $).
    ^s contents! !

!ConcretePattern methodsFor: 'testing'!

canTerminate
    ^followSet contains: [:p | p isTerminator]!

couldBeText
    ^false!

hasDuplicatesInFollowSet
    1 to: followSet size do: [:i || p1 p2 ns tp |
    	p1 := followSet at: i.
    	p1 class == NamePattern
    		ifTrue:
    			[ns := p1 name namespace.
    			tp := p1 name type.
    			i + 1 to: followSet size do: [:j |
    				p2 := followSet at: j.
    				(p2 class == NamePattern and:
    						[p2 name type = tp and:
    						[p2 name namespace = ns]])
    					ifTrue: [^true]]]].
    ^false!

isSimple
    ^true!

isTerminator
    ^false!

matchesTag: aNodeTag
    self subclassResponsibility! !

!ConcretePattern methodsFor: 'coercing'!

alternateHeads
    ^Array with: self!

pushDownFollowSet
    ^nil! !

!ConcretePattern methodsFor: 'validation'!

validateTag: elementTag
    | types |
    types := IdentitySet new.
    self followSet do: [:i |
    	(i matchesTag: elementTag)
    		ifTrue: [types add: i]].
    ^types isEmpty
    	ifTrue: [nil]
    	ifFalse: [types]!

validateText: characters from: start to: stop testBlanks: testBlanks
    self followSet do: [:i |
    	i couldBeText
    		ifTrue: [^i]].
    testBlanks
    	ifTrue:
    		[start to: stop do: [:i |
    			(characters at: i) asInteger > 16r0020
    				ifTrue: [^nil]].
    		^self].
    ^nil! !

!ConcretePattern methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: self description! !

!TerminalPattern methodsFor: 'accessing'!

description
    ^'</ close tag >'! !

!TerminalPattern methodsFor: 'testing'!

isTerminator
    ^true!

matchesTag: aNodeTag
    ^false! !

!InitialPattern methodsFor: 'accessing'!

description
    ^(followSet asArray collect: [:i | i description]) printString!

isExternal
    ^isExternal!

isExternal: flag
    isExternal := flag! !

!EmptyPattern methodsFor: 'coercing'!

alternateHeads
    ^followSet! !

!EmptyPattern methodsFor: 'testing'!

matchesTag: aNodeTag
    ^false! !

!EmptyPattern methodsFor: 'accessing'!

description
    ^'EMPTY'! !

!NamePattern methodsFor: 'initialize'!

named: aName
    name := aName! !

!NamePattern methodsFor: 'accessing'!

description
    ^'<%1>' bindWith: name!

name
    ^name! !

!NamePattern methodsFor: 'testing'!

matchesTag: aNodeTag
    ^name isLike: aNodeTag! !

!NamePattern class methodsFor: 'instance creation'!

named: aName
    ^self new named: aName! !

!PCDATAPattern methodsFor: 'accessing'!

description
    ^'#PCDATA'! !

!PCDATAPattern methodsFor: 'testing'!

couldBeText
    ^true!

matchesTag: aNodeTag
    ^false! !

!Attribute methodsFor: 'initialize'!

name: nm value: val
    name := nm isString
    		ifTrue: [NodeTag new qualifier: '' ns: '' type: nm]
    		ifFalse: [nm].
    value := val!

tag: aTag
    name := aTag! !

!Attribute methodsFor: 'accessing'!

characterData
    ^self value!

expandedName
    ^name expandedName!

key
    ^name!

tag
    ^name!

value
    ^value!

value: aValue
    value := aValue! !

!Attribute methodsFor: 'printing'!

printCanonicalOn: aStream
    aStream nextPutAll: self tag asString, '="'.
    self printCanonical: value on: aStream.
    aStream nextPutAll: '"'.!

printOn: aStream
    self printCanonicalOn: aStream!

simpleDescription
    ^'@', self key! !

!Attribute methodsFor: 'testing'!

isAttribute
    ^true!

isLike: aNode
    ^self class == aNode class
    	and: [self tag isLike: aNode tag]! !

!Attribute class methodsFor: 'instance creation'!

name: nm value: val
    ^self new name: nm value: val! !

!StreamWrapper methodsFor: 'initialize'!

isInternal: aBoolean
    isInternal := aBoolean!

resource: anInputSource entity: ent from: aParser
    resource := anInputSource.
    stream := resource stream.
    isInternal := resource uri == nil.
    entity := ent.
    cr := Character cr.
    lf := Character lf.
    parser := aParser.
    line := 1.
    column := 0.!

usedAsExternal
    ^usedAsExternal!

usedAsExternal: aBoolean
    usedAsExternal := aBoolean! !

!StreamWrapper methodsFor: 'accessing'!

characterSize: aCharacter
    ^1 "(self stream respondsTo: #encoder)
    	ifTrue: [self stream encoder characterSize: aCharacter]
    	ifFalse: [1]"!

checkEncoding
    "| encoding |
    encoding := [stream encoding] on: Error do: [:ex | ex returnWith: #null].
    encoding = #'UTF-8'
    	ifTrue:
    		[| c1 c2 pos |
    		pos := stream position.
    		stream setBinary: true.
    		c1 := stream next.
    		c2 := stream next.
    		stream setBinary: false.
    		(c2 notNil and: [c1 * c2 = 16rFD02])
    			ifTrue: [stream encoder: (UTF16StreamEncoder new
    								forByte1: c1 byte2: c2)]
    			ifFalse: [stream position: pos]]"!

close
    stream close!

column
    ^column!

column: n
    column := n!

contents
    | s |
    s := (String new: 100) writeStream.
    [self atEnd]
    	whileFalse: [s nextPut: self next].
    ^s contents!

entity
    ^entity!

line
    ^line!

line: n
    line := n!

stream
    ^stream!

uri
    ^resource uri! !

!StreamWrapper methodsFor: 'streaming'!

next
    | ch |
    ch := stream next.
    isInternal
    	ifFalse:
    		[lf == nil ifTrue: [self halt].
    		column := column + 1.
    		ch == cr
    			ifTrue:
    				[stream peekFor: lf.
    				ch := parser eol.
    				line := line + 1.
    				column := 0]
    			ifFalse: [ch == lf
    				ifTrue:
    					[ch := parser eol.
    					line := line + 1.
    					column := 0]]].
    "Originally we tested ch to make sure it was less than 16r110000,
    but now CharacterClasses' implementation of #at: answers 0 for
    large values of ch. If primitive failure code can not be trusted to do
    this, then the bounds check would have to be added back."
    (ch isNil or: [(CharacterClasses at: ch asInteger + 1) > 0])
    	ifFalse: [parser errorHandler fatalError: (BadCharacterSignal new messageText:('A character with Unicode value %1 is not legal' bindWith: ch asInteger))].
    ^ch!

skip: n
    stream skip: n.
    column := column - 1.! !

!StreamWrapper methodsFor: 'testing'!

atEnd
    ^stream atEnd!

isInternal
    ^isInternal! !

!StreamWrapper methodsFor: 'declaration'!

encodingDecl
    | enc |
    ^stream peek = $e
    	ifTrue:
    		[| encoding |
    		self mustFind: 'encoding'.
    		self skipSpace.
    		self mustFind: '='.
    		self skipSpace.
    		encoding := self quotedString.
    		parser validateEncoding: encoding.
    		((stream respondsTo: #encoding)
    				and: [stream encoding asLowercase ~= encoding asLowercase])
    			ifTrue:
    				["enc := (StreamEncoder new: encoding asSymbol)
    							initializeForFiles.
    				stream encoder: enc"].
    		true]
    	ifFalse: [false]!

mustFind: str
    (self skipIf: str)
    	ifFalse: [parser expected: str].!

quotedString
    (stream peekFor: $")
    	ifTrue: [^(stream upTo: $") asString].
    (stream peekFor: $')
    	ifTrue: [^(stream upTo: $') asString].
    parser malformed: 'Quoted string expected but not found'!

sdDecl
    ^stream peek = $s
    	ifTrue:
    		[| word |
    		self mustFind: 'standalone'.
    		self skipSpace.
    		self mustFind: '='.
    		self skipSpace.
    		word := self quotedString.
    		(#('yes' 'no') includes: word)
    			ifFalse: [parser malformed: '"yes" or "no" expected, but not found'].
    		parser declaredStandalone: word = 'yes'.
    		true]
    	ifFalse: [false]!

skipIf: str
    | p |
    p := stream position.
    1 to: str size do: [:i |
    	(stream peekFor: (str at: i))
    		ifFalse:
    			[stream position: p.
    			^false]].
    column := column+str size.
    ^true!

skipSpace
    | space |
    space := false.
    [#(9 10 13 32) includes: self next asInteger]
    	whileTrue: [space := true].
    self skip: -1.
    ^space!

textDecl
    self checkEncoding.
    ^(self skipIf: '<?xml')
    	ifTrue:
    		[| hasSpace |
    		hasSpace := self skipSpace.
    		hasSpace
    			ifTrue: [self versionInfo == nil
    				ifFalse: [hasSpace := self skipSpace]].
    		hasSpace
    			ifTrue: [self encodingDecl
    				ifFalse: [parser expected: 'encoding']]
    			ifFalse: [self encodingDecl
    				ifTrue: [parser expectedWhitespace]
    				ifFalse: [parser expected: 'encoding']].
    		self skipSpace.
    		self mustFind: '?>'.
    		true]
    	ifFalse: [false]!

versionInfo
    | version |
    ^stream peek = $v
    	ifTrue:
    		[self mustFind: 'version'.
    		self skipSpace.
    		self mustFind: '='.
    		self skipSpace.
    		version := self quotedString.
    		version = '1.0' ifFalse: [parser malformed: 'XML version 1.0 expected'].
    		version]
    	ifFalse: [nil]!

xmlDecl
    self checkEncoding.
    ^(self skipIf: '<?xml')
    	ifTrue:
    		[| hasSpace version |
    		(self skipSpace)
    			ifTrue: [version := self versionInfo]
    			ifFalse: [version := nil].
    		version = nil ifTrue: [parser expected: 'version'].
    		parser xmlVersion: version.
    		hasSpace := self skipSpace.
    		hasSpace
    			ifTrue: [self encodingDecl
    				ifTrue: [hasSpace := self skipSpace]]
    			ifFalse: [self encodingDecl
    				ifTrue: [parser expectedWhitespace]].
    		hasSpace
    			ifTrue: [self sdDecl
    				ifTrue: [hasSpace := self skipSpace]]
    			ifFalse: [self sdDecl
    				ifTrue: [parser expectedWhitespace]].
    		self mustFind: '?>'.
    		true]
    	ifFalse: [false]! !

!StreamWrapper class methodsFor: 'instance creation'!

emptyWithExtraSpace: space from: aParser
    | txt |
    txt := space ifTrue: ['  '] ifFalse: [''].
    ^self resource: (InputSource uri: nil encoding: nil stream: txt readStream)
    		entity: nil
    		from: aParser!

resource: anInputSource entity: entity from: aParser
    ^self new resource: anInputSource entity: entity from: aParser! !

!XMLFilter methodsFor: 'accessing'!

atFeature: aURIstring
    ^parent atFeature: aURIstring!

atFeature: aURIstring put: aBoolean
    ^parent atFeature: aURIstring put: aBoolean!

atProperty: aURIstring
    ^parent atProperty: aURIstring!

atProperty: aURIstring put: anOvbject
    ^parent atProperty: aURIstring put: anOvbject!

handlers: aSAXDriver
    self contentHandler: aSAXDriver.
    self dtdHandler: aSAXDriver.
    self errorHandler: aSAXDriver.
    self entityResolver: aSAXDriver!

parent
    ^parent!

parent: aParserOrFilter
    parent := aParserOrFilter.
    parent handlers: self.!

parse: dataSource
    ^parent parse: dataSource!

parseElement: dataSource
    ^parent parseElement: dataSource!

parseElements: dataSource
    ^parent parseElements: dataSource! !

!XMLFilter class methodsFor: 'instance creation'!

on: aParserOrFilter
    ^self new parent: aParserOrFilter! !

!ComplexPattern methodsFor: 'testing'!

isSimple
    ^false! !

!MixedPattern methodsFor: 'initialize'!

on: aList
    items := (Array with: PCDATAPattern new), aList! !

!MixedPattern methodsFor: 'coercing'!

alternateHeads
    ^items, followSet!

normalizeFor: aParser
    "Optimized because lots of the testing needed in
    the superclass is not needed here."

    | result |
    followSet := OrderedCollection withAll: items.
    followSet add: TerminalPattern new.
    result := InitialPattern new.
    result followSet: followSet.
    items do: [:i | i followSet: followSet].
    ^result!

pushDownFollowSet
    items do: [:i | i addFollow: self; addFollows: followSet].
    ^items! !

!MixedPattern methodsFor: 'testing'!

duplicatesNeedTested
    ^false! !

!MixedPattern methodsFor: 'copying'!

postCopy
    super postCopy.
    items := items collect: [:i | i copy].! !

!MixedPattern class methodsFor: 'instance creation'!

on: aList
    ^self new on: (aList size = 0 ifTrue: [#()] ifFalse: [aList])! !

!ChoicePattern methodsFor: 'initialize'!

on: aList
    items := aList! !

!ChoicePattern methodsFor: 'coercing'!

alternateHeads
    ^items!

pushDownFollowSet
    items do: [:i | i addFollows: followSet].
    ^items! !

!ChoicePattern methodsFor: 'printing'!

description
    | str |
    str := String new writeStream.
    str nextPutAll: '('.
    items do: [:ch | str nextPutAll: ch description] separatedBy: [str nextPutAll: ' | '].
    str nextPutAll: ')'.
    ^str contents!

printOn: aStream
    aStream nextPutAll: self description! !

!ChoicePattern methodsFor: 'copying'!

postCopy
    super postCopy.
    items := items collect: [:i | i copy].! !

!ChoicePattern class methodsFor: 'instance creation'!

on: aList
    ^self new on: aList! !

!ModifiedPattern methodsFor: 'initialize'!

on: aNode type: t
    node := aNode.
    modification := t.! !

!ModifiedPattern methodsFor: 'coercing'!

alternateHeads
    ^(modification = $* or: [modification = $?])
    	ifTrue: [(followSet copyWith: node) replaceAll: self with: node]
    	ifFalse: [Array with: node]!

pushDownFollowSet
    (modification = $+ or: [modification = $*])
    	ifTrue: [node addFollow: self].
    node addFollows: followSet.
    ^Array with: node! !

!ModifiedPattern methodsFor: 'printing'!

description
    ^node description copyWith: modification!

printOn: aStream
    aStream nextPutAll: self description! !

!ModifiedPattern methodsFor: 'copying'!

postCopy
    super postCopy.
    node := node copy! !

!ModifiedPattern class methodsFor: 'instance creation'!

on: aNode type: t
    ^self new on: aNode type: t! !

!NullSAXDriver methodsFor: 'content handler'!

characters: aString from: start to: stop
    ^self!

ignorableWhitespace: aString from: start to: stop
    ^self! !

!ParameterEntity methodsFor: 'accessing'!

entityType
    ^'parameter'!

streamFor: aParser addSpaces: spaces
    | myText textStr input |
    (aParser hasExpanded: self)
    	ifTrue: [aParser malformed: 'Can''t expand this entity; it is defined recursively'].
    text == nil
    	ifTrue:
    		[| str |
    		input := aParser saxDriver
    			resolveEntity: self publicID
    			systemID: self systemID.
    		input == nil ifTrue: [input := InputSource for: self systemID].
    		str := StreamWrapper
    					resource: input
    					entity: self
    					from: aParser.
    		str textDecl.
    		textStr := (String new: 32) writeStream.
    		[str atEnd] whileFalse: [textStr nextPut: str next].
    		text := textStr contents.
    		str close].
    myText := text.
    spaces ifTrue: [myText := ' ', text, ' '].
    aParser pushSource: (StreamWrapper
    					resource: (InputSource uri: nil encoding: nil stream: myText readStream)
    					entity: self
    					from: aParser).
    aParser getNextChar.! !

!Locator methodsFor: 'processing'!

column
    ^self externalWrapper column!

line
    ^self externalWrapper line!

publicID
    | ent |
    ent := self externalWrapper entity.
    ^ent == nil
    	ifTrue: [nil]
    	ifFalse: [ent publicID]!

systemID
    | ent |
    ent := self externalWrapper entity.
    ^ent == nil
    	ifTrue: [nil]
    	ifFalse: [ent systemID]! !

!Locator methodsFor: 'accessing'!

parser: aParser
    parser := aParser! !

!Locator methodsFor: 'private'!

externalWrapper
    ^parser fullSourceStack reverse
    	detect: [:s | s isInternal not]
    	ifNone: [parser fullSourceStack first]! !

!XMLParser methodsFor: 'initialize'!

builder: anXMLNodeBuilder
    self saxDriver: (SAXBuilderDriver new builder: anXMLNodeBuilder)!

initialize
    validating := true.
    self saxDriver: DOM_SAXDriver new.
    flags := 0.
    self processNamespaces: true.
    eol := Character nl.
    buffer := (String new: 32) writeStream.
    nameBuffer := (String new: 16) writeStream.!

lineEndLF
    eol := Character nl!

lineEndCR
    eol := Character cr!

lineEndNormal
    eol := Character nl!

on: dataSource
    "The dataSource may be a URI, a Filename (or a String
    which will be treated as a Filename), or an InputSource."

    sourceStack := self wrapDataSource: dataSource.
    elementStack := OrderedCollection new.
    dtd := DocumentType new.
    unresolvedIDREFs := Set new.
    definedIDs := Set new.
    	"Clear those flags that keep track of the
    	state of the parse, but retain those that
    	relate to options."
    flags := flags bitAnd: 16rFFFF bitInvert!

saxDriver: aSAXDriver
    sax := aSAXDriver.
    sax setDocumentLocator: (Locator new parser: self)!

wrapDataSource: aDataSource
    | resource uri |
    resource := (aDataSource isKindOf: Stream)
    	ifTrue:
    		[uri := [NetClients.URL fromString: aDataSource name ]
		    on: Error do: [ :ex | ex return: nil ].

		InputSource uri: uri encoding: nil stream: aDataSource]
    	ifFalse: [InputSource for: aDataSource].

    ^(StreamWrapper
    	resource: resource
    	entity: nil
    	from: self)
    	isInternal: false! !

!XMLParser methodsFor: 'accessing'!

document
    ^sax document!

dtd
    ^dtd!

eol
    ^eol!

saxDriver
    ^sax!

sourceWrapper
    ^sourceStack "last"!

validate: aBoolean
    validating := aBoolean! !

!XMLParser methodsFor: 'testing'!

hasExpanded: anEntity
    | s |
    s := sourceStack.
    [s == nil] whileFalse:
    	[s entity == anEntity
    		ifTrue: [self malformed: ('The %1 entity "%2" invokes itself recursively'
    					bindWith: anEntity entityType
    					with: anEntity name)].
    	s := s nextLink].
    ^false!

isValidating
    ^validating!

shouldTestWFCEntityDeclared
    ^self hasDTD not
    	or: [(self hasExternalDTD not
    		and: [self usesParameterEntities not])
    	or: [self isDeclaredStandalone]]! !

!XMLParser methodsFor: 'api'!

comment
    | str1 |
    str1 := currentSource.
    ^(self skipIf: '<!--')
    	ifTrue:
    		[self completeComment: str1.
    		true]
    	ifFalse: [false]!

docTypeDecl
    | nm id |
    ^(self skipIf: '<!DOCTYPE')
    	ifTrue:
    		[self forceSpace.
    		self noteDTD.
    		nm := self getQualifiedName.
    		self dtd declaredRoot: nm.
    		self skipSpace.
    		(id := self externalID: #docType) notNil ifTrue: [self skipSpace].
    		self sourceWrapper usedAsExternal: false.
    		(self skipIf: '[')
    			ifTrue: [[self skipIf: ']']
    				whileFalse: [self dtdEntry]].
    		self skipSpace.
    		hereChar = $> ifFalse: [self expected: '>'].
    		self sourceWrapper usedAsExternal: nil.
    		id == nil ifFalse: [self dtdFile: id].
    		self mustFind: '>'.
    		self isValidating ifTrue: [dtd completeValidationAgainst: self].
    		true]
    	ifFalse: [false]!

element
    "Deprecated, see #parseElement:"

    ^[sax startDocumentFragment.
    self getElement.
    sax endDocumentFragment.
    sax document == nil
    	ifTrue: [nil]
    	ifFalse: [sax document elements first]]
    	ifCurtailed: [self closeAllFiles]!

latestURI
    | s |
    s := self fullSourceStack reverse detect: [:i | i uri notNil] ifNone: [nil].
    ^s == nil
    	ifTrue: [NetClients.URL fromString: (Directory append: 'foo' to: Directory working)]
    	ifFalse: [s uri]!

misc
    ^self atEnd not and: [self skipSpace or: [self comment or: [self pi]]]!

pi
    | str1 |
    str1 := currentSource.
    ^(self skipIf: '<?')
    	ifTrue:
    		[self completePI: str1.
    		true]
    	ifFalse: [false]!

prolog
    self sourceWrapper xmlDecl.        "This is optional."
    self getNextChar.
    [self misc] whileTrue.
    self docTypeDecl
    	ifTrue: [[self misc] whileTrue].!

pushSource: aStreamWrapper
    aStreamWrapper nextLink: sourceStack.
    sourceStack := aStreamWrapper!

scanDocument
    ^[sax startDocument.
    self prolog.
    self atEnd ifTrue: [self malformed: 'Some XML content was expected'].
    self getElement.
    [self misc] whileTrue.
    self atEnd ifFalse: [self malformed: 'A comment or processing instruction, or the end of the document, was expected'].
    self checkUnresolvedIDREFs.
    sax endDocument.
    self document]
    	ensure: [self closeAllFiles]!

xmlVersion: aString
    "Do nothing for now"! !

!XMLParser methodsFor: 'DTD processing'!

conditionalSect
    | nm oldIgnore |
    hereChar = $< ifFalse: [^false].
    self inInternalSubset ifTrue: [^false].
    ^(self skipIf: '<![')
    	ifTrue:
    		[self skipSpaceInDTD.
    		nm := self getSimpleName.
    		(#('INCLUDE' 'IGNORE') includes: nm)
    			ifFalse: [self malformed: 'INCLUDE or IGNORE was expected'].
    		oldIgnore := self ignore.
    		self ignore: (oldIgnore or: [nm = 'IGNORE']).
    		self skipSpaceInDTD.
    		self mustFind: '['.
    		self ignore
    			ifTrue: [self parseIgnore]
    			ifFalse: [[self skipIf: ']]>']
    					whileFalse: [self dtdEntry]].
    		self ignore: oldIgnore.
    		true]
    	ifFalse: [false]!

dtdEntry
    ((self PERef: #dtdEntry) or:
    		[self markUpDecl or:
    		[self conditionalSect or:
    		[self skipSpace]]])
    	ifFalse: [self malformed: 'A markup declaration or PE reference was expected']!

dtdFile: uriList
    | str input |
    self noteExternalDTD.
    currentSource skip: -1.
    	"So we don't lose hereChar."
    input := sax
    	resolveEntity: (uriList at: 1)
    	systemID: (uriList at: 2).
    input == nil ifTrue: [input := InputSource for: (uriList at: 2)].
    self pushSource: (str := StreamWrapper
    					resource: input
    					entity: (GeneralEntity new
    							name: '[dtd]';
    							externalFrom: uriList)
    					from: self).
    str usedAsExternal: true.
    str textDecl.
    self getNextChar.
    [self fullSourceStack includes: str]
    	whileTrue: [self dtdEntry].!

externalID: usage
    "Usage may be #docType, #entity, or #notation.
    DocType is treated specially, since PE references are not allowed.
    Notation is treated specially since the system identifier of the
    	PUBLIC form is optional."

    | lit2 lit1 forceSpace skipSpace |
    forceSpace := [usage == #docType
    				ifTrue: [self forceSpace]
    				ifFalse: [self forceSpaceInDTD]].
    skipSpace := [usage == #docType
    				ifTrue: [self skipSpace]
    				ifFalse: [self skipSpaceInDTD]].
    ^(self skipIf: 'SYSTEM')
    	ifTrue:
    		[forceSpace value.
    		lit2 := self systemLiteral.
    		Array with: nil with: lit2]
    	ifFalse: [(self skipIf: 'PUBLIC')
    		ifTrue:
    			[forceSpace value.
    			lit1 := self pubIdLiteral.
    			usage == #notation
    				ifTrue:
    					[(skipSpace value and:
    							[hereChar = $' or: [hereChar = $"]])
    						ifTrue: [lit2 := self systemLiteral]
    						ifFalse: [lit2 := nil]]
    				ifFalse:
    					[forceSpace value.
    					lit2 := self systemLiteral].
    			Array with: lit1 with: lit2]
    		ifFalse:
    			[nil]]!

inInternalSubset
    self fullSourceStack reverseDo:
    	[:str |
    	str usedAsExternal == nil
    		ifFalse: [^str usedAsExternal not]].
    self error: 'Not currently processing the DTD'!

markUpDecl
    ^self elementDecl
    	or: [self attListDecl
    	or: [self entityDecl
    	or: [self notationDecl
    	or: [self pi
    	or: [self comment]]]]]!

notationDecl
    | nm id str |
    str := currentSource.
    ^(self skipIf: '<!NOTATION')
    	ifTrue:
    		[self forceSpaceInDTD.
    		nm := self getSimpleName.
    		self forceSpaceInDTD.
    		id := self externalID: #notation.
    		self ignore ifFalse:
    			[id == nil
    				ifTrue: [self malformed: 'Invalid PUBLIC / SYSTEM identifiers'].
    			dtd notationAt: nm put: (Notation new name: nm identifiers: id) from: self.
    			sax notationDecl: nm
    				publicID: (id at: 1)
    				systemID: (id at: 2)].
    		self skipSpaceInDTD.
    		self mustFind: '>'.
    		str == lastSource
    			ifFalse: [self invalid: 'Improper nesting of declarations within a parameter entity'].
    		true]
    	ifFalse: [false]!

parseIgnore
    | entryCount openIndex closeIndex |
    entryCount := 1.
    openIndex := closeIndex := 1.
    [entryCount = 0]
    	whileFalse:
    		[hereChar == nil ifTrue: [self expected: ']]>'].
    		hereChar = ('<![' at: openIndex)
    			ifTrue:
    				[openIndex := openIndex + 1.
    				openIndex = 4
    					ifTrue:
    						[entryCount := entryCount + 1.
    						openIndex := 1]]
    			ifFalse: [openIndex := 1].
    		hereChar = (']]>' at: closeIndex)
    			ifTrue:
    				[closeIndex := closeIndex + 1.
    				closeIndex = 4
    					ifTrue:
    						[entryCount := entryCount - 1.
    						closeIndex := 1]]
    			ifFalse: [closeIndex := 1].
    		self getNextChar].!

pubIdLiteral
    | str s1 |
    str := self quotedString.
    str do: [:ch |
    	((' -''()+,./:=?;!*#@$_%' includes: ch)
    			or: [ch asInteger = 10
    			or: [ch asInteger = 13
    			or: [ch asciiValue < 127
    			and: [ch isLetter or: [ch isDigit]]]]])
    		ifFalse: [self malformed: 'Invalid public id character found']].
    str replaceAll: Character tab with: Character space.
    str replaceAll: Character cr with: Character space.
    str replaceAll: Character nl with: Character space.
    [(s1 := str copyReplaceAll: '  ' with: ' ') = str]
    	whileFalse: [str := s1].
    (str isEmpty not and: [str first = Character space])
    	ifTrue: [str := str copyFrom: 2 to: str size].
    (str isEmpty not and: [str last = Character space])
    	ifTrue: [str := str copyFrom: 1 to: str size - 1].
    ^str!

systemLiteral
    | lit |
    lit := self quotedString.
    (lit includes: $#)
    	ifTrue: [self malformed: 'Fragments in System IDs are not supported'].
    ^lit isEmpty
    	ifTrue: [lit]
    	ifFalse: [(self latestURI resolvePath: lit) asString]! !

!XMLParser methodsFor: 'entity processing'!

entityDecl
    | nm def str |
    str := currentSource.
    ^(self skipIf: '<!ENTITY')
    	ifTrue:
    		[self forceSpace.
    		hereChar = $%
    			ifTrue:
    				[self getNextChar; forceSpaceInDTD.
    				nm := self getSimpleName.
    				self forceSpaceInDTD.
    				def := self peDef: nm.
    				self ignore ifFalse: [self dtd parameterEntityAt: nm put: def from: self]]
    			ifFalse:
    				[self skipSpaceInDTD.
    				nm := self getSimpleName.
    				self forceSpaceInDTD.
    				def := self entityDef: nm.
    				self ignore ifFalse: [self dtd generalEntityAt: nm put: def from: self]].
    		self skipSpaceInDTD.
    		self mustFind: '>'.
    		str == lastSource
    			ifFalse: [self invalid: 'Improper nesting of declarations within a parameter entity'].
    		true]
    	ifFalse: [false]!

entityDef: name
    | val ndata |
    ^(val := self entityValue) == nil
    	ifTrue: [(val := self externalID: #entity) == nil
    		ifTrue: [self malformed: 'An entity value or external id was expected']
    		ifFalse:
    			[| entity |
    			ndata := self nDataDecl.
    			entity := GeneralEntity new
    				name: name;
    				externalFrom: val;
    				ndata: ndata;
    				isDefinedExternally: self inInternalSubset not.
    			ndata == nil
    				ifFalse: [sax unparsedEntityDecl: name
    						publicID: entity publicID
    						systemID: entity systemID
    						notationName: ndata].
    			entity]]
    	ifFalse: [GeneralEntity new
    				name: name;
    				text: val;
    				isDefinedExternally: self inInternalSubset not]!

entityValue
    | aQuote s str1 |
    aQuote := hereChar.
    (aQuote = $' or: [aQuote = $"]) ifFalse: [^nil].
    s := currentSource.
    self getNextChar.
    buffer reset.
    [hereChar == nil
    	ifTrue: [self expected: (String with: aQuote)].
    (hereChar = aQuote and: [s = currentSource])]
    	whileFalse:
    		[hereChar = $&
    			ifTrue:
    				[str1 := currentSource.
    				(self skipIf: '&#')
    					ifTrue: [self charEntity: buffer startedIn: str1]
    					ifFalse: [self getNextChar; generalEntity: buffer]]
    			ifFalse: [(self PERef: #data)
    				ifFalse:
    					[buffer nextPut: hereChar.
    					self getNextChar]]].
    self getNextChar.
    ^buffer contents!

generalEntity: str
    | nm |
    nm := self getSimpleName.
    hereChar = $;
    	ifFalse: [self malformed: 'A semicolon was expected'].
    str nextPut: $&; nextPutAll: nm; nextPut: $;.
    self getNextChar!

nDataDecl
    ^self skipSpaceInDTD
    	ifTrue: [(self skipIf: 'NDATA')
    		ifTrue:
    			[self forceSpaceInDTD.
    			self getSimpleName]
    		ifFalse: [nil]]
    	ifFalse: [nil]!

peDef: name
    | val |
    ^(val := self entityValue) == nil
    	ifTrue: [(val := self externalID: #entity) == nil
    		ifTrue: [self malformed: 'An entity value or external id was expected']
    		ifFalse:
    			[ParameterEntity new
    				name: name;
    				externalFrom: val]]
    	ifFalse: [ParameterEntity new name: name; text: val]!

PERef: refType
    | nm exp |
    ^(hereChar = $%)
    	ifTrue:
    		[refType = #dtdEntry ifTrue: [self notePEReference].
    		self getNextChar.
    		(self inInternalSubset and: [refType ~= #dtdEntry])
    			ifTrue: [self malformed: 'Parameter entity references cannot be used in the internal DTD, inside a declaration'].
    		nm := self getSimpleName.
    		hereChar = $; ifFalse: [self malformed: 'A semicolon was expected'].
    		exp := self dtd parameterEntityAt: nm.
    		exp == nil
    			ifTrue: [self warn: ('The parameter entity "%1" has not been defined'
    						bindWith: nm)].
    		exp == nil
    			ifTrue: [self isValidating
    				ifTrue:
    					[self invalid: 'Parameter entity used but not defined'.
    					self getNextChar]
    				ifFalse:
    					[self pushSource: (StreamWrapper
    							emptyWithExtraSpace: refType ~= #data
    							from: self).
    					self getNextChar]]
    			ifFalse:
    				[exp streamFor: self addSpaces: refType ~= #data].
    		(refType ~= #data and: [self sourceWrapper uri notNil])
    			ifTrue: [self sourceWrapper usedAsExternal: true].
    		true]
    	ifFalse: [false]! !

!XMLParser methodsFor: 'element def processing'!

completeChildren: str
    | div items node |
    items := OrderedCollection with: self cp.
    self skipSpaceInDTD.
    div := nil.
    [self skipIf: ')']
    	whileFalse:
    		[div == nil ifTrue:
    			[(',|' includes: hereChar) ifFalse: [self malformed: 'Either , or | was expected'].
    			div := hereChar].
    		div = hereChar ifFalse: [self expected: (String with: div)].
    		self getNextChar; skipSpaceInDTD.
    		items add: self cp.
    		self skipSpaceInDTD].
    (self isValidating and: [lastSource ~~ str])
    	ifTrue: [self invalid: 'Parentheses must nest properly within entities'].
    div == nil ifTrue: [div := $,].
    div = $,
    	ifTrue: [node := SequencePattern on: items]
    	ifFalse: [node := ChoicePattern on: items].
    ('*+?' includes: hereChar)
    	ifTrue:
    		[node := ModifiedPattern on: node type: hereChar.
    		self getNextChar].
    ^node!

completeMixedContent: str
    "we already have the #PCDATA finished."
    | names |
    self skipSpaceInDTD.
    names := OrderedCollection new.
    [hereChar = $)]
    	whileFalse:
    		[self mustFind: '|'.
    		self skipSpaceInDTD.
    		names add: (NamePattern named: self getQualifiedName).
    		self skipSpaceInDTD].
    (self isValidating and: [currentSource ~~ str])
    	ifTrue: [self invalid: 'Parentheses must nest properly within entities'].
    names size = 0
    	ifTrue: [self mustFind: ')'; skipIf: '*']
    	ifFalse: [self mustFind: ')*'].
    1 to: names size do: [:i |
    	i + 1 to: names size do: [:j |
    		((names at: i) name asString = (names at: j) name asString)
    			ifTrue: [self invalid: 'Duplicate element names in a mixed content specification.'].
    		((names at: i) name isLike: (names at: j) name)
    			ifTrue: [self invalid: 'Duplicate element names in a mixed content specification.'].
    		]].
    ^MixedPattern on: names!

contentsSpec
    | str |
    ^(self skipIf: 'ANY')
    	ifTrue: [AnyPattern new]
    	ifFalse: [(self skipIf: 'EMPTY')
    		ifTrue: [EmptyPattern new]
    		ifFalse:
    			[str := currentSource.
    			self mustFind: '('.
    			self skipSpaceInDTD.
    			(self skipIf: '#PCDATA')
    				ifTrue: [self completeMixedContent: str]
    				ifFalse: [self completeChildren: str]]]!

cp
    | node str |
    str := currentSource.
    ^(self skipIf: '(')
    	ifTrue: [self skipSpaceInDTD; completeChildren: str]
    	ifFalse:
    		[node := NamePattern named: self getQualifiedName.
    		('*+?' includes: hereChar)
    			ifTrue:
    				[node := ModifiedPattern on: node type: hereChar.
    				self getNextChar].
    		node]!

elementDecl
    | nm cSpec str |
    str := currentSource.
    ^(self skipIf: '<!ELEMENT')
    	ifTrue:
    		[self forceSpaceInDTD.
    		nm := self getQualifiedName.
    		self forceSpaceInDTD.
    		cSpec := self contentsSpec normalizeFor: self.
    		cSpec isExternal: self inInternalSubset not.
    		self ignore ifFalse: [self dtd elementFor: nm put: cSpec from: self].
    		self skipSpaceInDTD.
    		self mustFind: '>'.
    		str == lastSource
    			ifFalse: [self invalid: 'Improper nesting of declarations within a parameter entity'].
    		true]
    	ifFalse: [false]! !

!XMLParser methodsFor: 'element processing'!

charEntity: data startedIn: str1
    | base digit n d |
    hereChar = $x
    	ifTrue:
    		[base := 16.
    		digit := 'Expected to find a hex digit'.
    		self getNextChar]
    	ifFalse:
    		[base := 10.
    		digit := 'Expected to find a digit'].
    n := 0.
    [hereChar = $;]
    	whileFalse:
    		[d := hereChar digitValue.
    		(d >= 0 and: [d < base]) ifFalse: [self malformed: digit].
    		n := n * base + d.
    		self getNextChar].
    str1 = currentSource
    	ifFalse: [self malformed: 'Character entities must nest properly inside other entities'].
    "Originally we tested ch to make sure it was less than 16r110000,
    but now CharacterClasses' implementation of #at: answers 0 for
    large values of ch. If primitive failure code can not be trusted to do
    this, then the bounds check would have to be added back."
    (CharacterClasses at: n + 1) = 0
    	ifTrue: [sax fatalError: (BadCharacterSignal new messageText:('A character with Unicode value %1 is not legal' bindWith: n))].
    data nextPut: (Character value: n).
    self getNextChar!

closeTag: tag
    | nm |
    nm := self getQualifiedName.
    nm := self correctTag: nm.
    self skipSpace.
    self mustFind: '>'.
    nm = tag
    	ifFalse: [self malformed: ('The close tag for %1 was not found' bindWith: tag asString)].
    sax endElement: nm namespace localName: nm type qName: nm asString.
    elementStack last definesNamespaces
    	ifTrue: [elementStack last namespaces
    		keysDo: [:qualifier |
    			sax endPrefixMapping: qualifier]].!

completeCDATA: str1
    | str data size textType |
    buffer reset.
    [str := self upToAll: ']>'.
    str last = $]]
    	whileFalse:
    		[buffer nextPutAll: str; nextPutAll: ']>'].
    lastSource = str1
    	ifFalse: [self malformed: 'CDATA sections must nest properly in entities'].
    buffer nextPutAll: (str copyFrom: 1 to: str size - 1).
    data := buffer collection.	"Not necessarily portable, but faster than #contents"
    "If CDATA that contains only whiteSpace should not
    be allowed in an element that has an element-only
    content model, change the 'testBlanks:' parameter to
    false."
    size := buffer position.
    textType := self
    	validateText: data
    	from: 1
    	to: size
    	testBlanks: false.
    textType == #whitespace
    	ifTrue: [sax ignorableWhitespace: data from: 1 to: size]
    	ifFalse: [sax characters: data from: 1 to: size].!

completeComment: str1
    | str comment size index |
    buffer reset.
    [str := self upToAll: '->'.
    str last = $-]
    	whileFalse:
    		[buffer nextPutAll: str; nextPutAll: '->'].
    buffer nextPutAll: (str copyFrom: 1 to: str size - 1).
    comment := buffer collection.
    size := buffer position.
    index := comment indexOfSubCollection: '--' startingAt: 1.
    (index = 0 or: [index >= size])
    	ifFalse: [self malformed: 'Doubled hyphens in comments are not permitted'].
    (size > 0 and: [(comment at: size) = $-])
    	ifTrue: [self malformed: 'A hyphen is not permitted as the last character in a comment'].
    lastSource = str1
    	ifFalse: [self malformed: 'Comments must nest properly in entities'].
    self ignore ifFalse:
    	[sax comment: comment from: 1 to: size]!

completePI: str1
    | nm pi |
    nm := self getSimpleName.
    nm = 'xml' ifTrue: [self malformed: 'An "xml" declaration is not permitted, except at the beginning of the file'].
    nm asLowercase = 'xml' ifTrue: [self malformed: '''xml'' is not permitted as the target of a processing instruction'].
    self skipSpace
    	ifTrue:
    		[pi := self upToAll: '?>']
    	ifFalse:
    		[pi := ''.
    		self mustFind: '?>'].
    lastSource = str1
    	ifFalse: [self malformed: 'Pprogramming instructions must nest properly in entities'].
    self ignore ifFalse: [sax processingInstruction: nm data: pi].!

elementAtPosition: startPosition
    | attributes nm str1 |
    str1 := currentSource.
    self mustFind: '<'.
    nm := self getQualifiedName.
    self pushNewTag: nm.
    latestID := nil.
    attributes := self processAttributes: nm.
    nm := self correctTag: nm.
    elementStack last definesNamespaces
    	ifTrue: [elementStack last namespaces
    		keysAndValuesDo: [:qualifier :uri |
    			sax startPrefixMapping: qualifier uri: uri]].
    sax startElement: nm namespace
    	localName: nm type
    	qName: nm asString
    	attributes: (attributes == nil ifTrue: [#()] ifFalse: [attributes]).
    sax sourcePosition: startPosition inStream: str1.
    latestID notNil ifTrue: [sax idOfElement: latestID].
    (self skipIf: '/>')
    	ifTrue: 
    		[str1 = lastSource ifFalse: [self expected: 'Elements must nest properly within entities'].
    		sax endElement: nm namespace
    			localName: nm type
    			qName: nm asString]
    	ifFalse: [(self skipIf: '>')
    		ifTrue: 
    			[str1 = lastSource ifFalse: [self expected: 'Elements must nest properly within entities'].
    			self elementContent: nm
    				openedIn: str1]
    		ifFalse: [self expected: 'end of start tag']].
    self popTag!

elementContent: tag openedIn: str
    | data str1 braceCount size textType |
    braceCount := 0.
    buffer reset.
    [hereChar == nil
    	ifTrue: [self malformed: ('The end tag for <%1> was expected' bindWith: tag)].
    hereChar == $<
    	ifTrue:
    		[braceCount := 0.
    		buffer position > 0
    			ifTrue:
    				[data := buffer collection.	"Not necessarily portable, but faster than #contents"
    				size := buffer position.
    				textType := self
    					validateText: data
    					from: 1
    					to: size
    					testBlanks: true.
    				textType == #whitespace
    					ifTrue:
    						[(self isValidating and: [self isDeclaredStandalone and: [elementStack last isDefinedExternal]])
    							ifTrue: [self invalid: 'This document is not standalone'].
    						sax ignorableWhitespace: data from: 1 to: size]
    					ifFalse: [sax characters: data from: 1 to: size]].
    		str1 := currentSource.
    		(self skipIf: '</')
    			ifTrue:
    				[self closeTag: tag.
    				str == lastSource
    					ifFalse: [self malformed: 'Elements must nest properly within entities'].
    				^self]
    			ifFalse: [(self skipIf: '<?')
    				ifTrue: [self completePI: str1]
    				ifFalse: [(self skipIf: '<![CDATA[')
    					ifTrue: [self completeCDATA: str1]
    					ifFalse: [(self skipIf: '<!--')
    						ifTrue: [self completeComment: str1]
    						ifFalse: [self getElement]]]].
    		buffer reset]
    	ifFalse: [hereChar == $&
    		ifTrue:
    			[braceCount := 0.
    			str1 := currentSource.
    			(self skipIf: '&#')
    				ifTrue: [self charEntity: buffer startedIn: str1]
    				ifFalse: [self getNextChar; generalEntityInText: buffer canBeExternal: true]]
    		ifFalse:
    			[hereChar == $]
    				ifTrue: [braceCount := braceCount + 1]
    				ifFalse:
    					[(hereChar == $> and: [braceCount >= 2])
    						ifTrue: [self malformed: ']]> is not permitted in element content'].
    					braceCount := 0].
    			buffer nextPut: hereChar.
    			self getNextChar]]] repeat!

generalEntityInText: str canBeExternal: external
    | exp nm str1 msg |
    str1 := lastSource.
    nm := self getSimpleName.
    hereChar = $;
    	ifFalse: [self malformed: 'A semicolon was expected'].
    currentSource = str1
    	ifFalse: [self malformed: 'Entity references must nest properly within other entity references'].
    exp := self dtd generalEntityAt: nm.
    exp == nil
    	ifTrue:
    		[msg := 'The general entity "%1" has not been defined'
    						bindWith: nm.
    		self isValidating
    			ifTrue: [self invalid: msg]
    			ifFalse: [self warn: msg].
    		self shouldTestWFCEntityDeclared
    			ifTrue: [self malformed: 'General entity used but not defined'].
    		"str nextPut: $&; nextPutAll: nm; nextPut: $;."
    		self getNextChar]
    	ifFalse:
    		[(external or: [exp isExternal not])
    			ifFalse: [self malformed: 'External entity references are not permitted in attribute values'].
    		(self isValidating and: [self isDeclaredStandalone
    				and: [exp isDefinedExternally]])
    			ifTrue: [self invalid: 'This document is not standalone'].
    		exp isParsed
    			ifFalse: [self malformed: 'References to unparsed entities other than in an attribute of type ENTITY are not permitted'].
    		exp streamFor: self].!

getElement
    | str1 startPosition |
    str1 := currentSource.
    startPosition := str1 stream position - (str1 characterSize: hereChar).
    ^self elementAtPosition: startPosition!

isValidTag: aTag
    ^true!

popTag
    self isValidating
    	ifTrue:
    		[elementStack last canTerminate
    			ifFalse: [self invalid: ('One of %1 was expected, but none was found' bindWith: elementStack last followSetDescription)]].
    elementStack removeLast.!

pushNewTag: nm
    | elm p types |
    self isValidating
    	ifTrue:
    		[elementStack isEmpty
    			ifTrue: [(self hasDTD
    					and: [self dtd declaredRoot asString = nm asString])
    				ifFalse: [self invalid: 'Document type must match type of the root element']]
    			ifFalse:
    				[elm := elementStack last.
    				types := elm validateTag: nm.
    				types == nil
    					ifTrue: [self invalid:
    						('"%1" is not permitted at this point in the "%2" node'
    							bindWith: nm asString
    							with: elm tag asString)].
    				elm types: types].
    		elementStack addLast: (ElementContext new tag: nm).
    		p := self dtd elementFor: nm from: self.
    		p == nil
    			ifTrue: [self invalid: ('Using a tag (%1) without declaring it is not permitted' bindWith: nm asString)].
    		elementStack last type: p]
    	ifFalse:
    		[elementStack addLast: (ElementContext new tag: nm)]!

validateText: data from: start to: stop testBlanks: testBlanks
    | elm textType types |
    textType := #characters.
    stop < start ifTrue: [^textType].
    self isValidating
    	ifTrue:
    		[elm := elementStack last.
    		types := elm
    			validateText: data
    			from: start
    			to: stop
    			testBlanks: testBlanks.
    		types == nil
    			ifTrue: [self invalid: 'The DTD does not permit text here']
    			ifFalse:
    				[(types contains: [:n | n couldBeText]) ifFalse: [textType := #whitespace].
    				elm types: types]].
    ^textType! !

!XMLParser methodsFor: 'attribute def processing'!

attListDecl
    | nm str1 attr |
    str1 := currentSource.
    ^(self skipIf: '<!ATTLIST')
    	ifTrue:
    		[self forceSpaceInDTD.
    		nm := self getQualifiedName.
    		[self skipSpaceInDTD.
    		self skipIf: '>']
    			whileFalse:
    				[self skipSpaceInDTD.
    				attr := AttributeDef new name: self getQualifiedName.
    				self forceSpaceInDTD.
    				attr type: self attType.
    				attr type isExternal: self inInternalSubset not.
    				self forceSpaceInDTD.
    				attr default: (self defaultDeclType: attr type).
    				self isValidating ifTrue: [attr selfValidateFor: self].
    				self checkReservedAttributes: attr name asString
    					type: attr type
    					value: attr default.
    				self ignore ifFalse: [self dtd attributeFor: nm subKey: attr name put: attr from: self]].
    		str1 == lastSource
    			ifFalse: [self invalid: 'Improper nesting of declarations within a parameter entity'].
    		true]
    	ifFalse: [false]!

attType
    | nm all type |
    ^hereChar = $(
    	ifTrue: [self enumeration]
    	ifFalse:
    		[nm := self getSimpleName.
    		all := #('NOTATION' 'CDATA' 'ID'
    					'IDREF' 'IDREFS'
    					'ENTITY' 'ENTITIES'
    					'NMTOKEN' 'NMTOKENS').
    		(all includes: nm)
    			ifFalse: [self malformed: ('One of %1 was expected, but none was found' bindWith: all storeString)].
    		type := #(#{NOTATION_AT} #{CDATA_AT} #{ID_AT}
    					#{IDREF_AT} #{IDREFS_AT}
    					#{ENTITY_AT} #{ENTITIES_AT}
    					#{NMTOKEN_AT} #{NMTOKENS_AT})
    				at: (all indexOf: nm).
    		nm = 'NOTATION'
    			ifTrue: [self completeNotationType]
    			ifFalse: [type value new]].!

completeNotationType
    | nm |
    self forceSpaceInDTD.
    self mustFind: '('.
    self skipSpaceInDTD.
    nm := OrderedCollection with: self getSimpleName.
    self skipSpaceInDTD.
    [self skipIf: '|']
    	whileTrue:
    		[self skipSpaceInDTD.
    		nm add: self getSimpleName.
    		self skipSpaceInDTD].
    self mustFind: ')'.
    ^NOTATION_AT typeNames: nm!

defaultDecl
    | fixed default |
    ^(self skipIf: '#REQUIRED')
    	ifTrue: [#required]
    	ifFalse: [(self skipIf: '#IMPLIED')
    		ifTrue: [#implied]
    		ifFalse:
    			[fixed := self skipIf: '#FIXED'.
    			fixed ifTrue:
    				[self forceSpaceInDTD].
    			default := self attValue.
    			default == nil ifTrue: [self malformed: 'A quoted value was expected for the attribute''s default'].
    			fixed -> default]]!

defaultDeclType: type
    | fixed default |
    ^(self skipIf: '#REQUIRED')
    	ifTrue: [#required]
    	ifFalse: [(self skipIf: '#IMPLIED')
    		ifTrue: [#implied]
    		ifFalse:
    			[fixed := self skipIf: '#FIXED'.
    			fixed ifTrue:
    				[self forceSpaceInDTD].
    			default := self attValue: type inDTD: true.
    			default == nil ifTrue: [self malformed: 'A quoted value was expected for the attribute''s default'].
    			fixed -> default]]!

enumeration
    | nm |
    self mustFind: '('.
    self skipSpaceInDTD.
    nm := OrderedCollection with: self nmToken.
    self skipSpaceInDTD.
    [self skipIf: '|']
    	whileTrue:
    		[self skipSpaceInDTD.
    		nm add: self nmToken.
    		self skipSpaceInDTD].
    self mustFind: ')'.
    ^Enumeration_AT withAll: nm! !

!XMLParser methodsFor: 'attribute processing'!

attribute
    | nm value |
    nm := self getQualifiedName.
    self skipSpace.
    self mustFind: '='.
    self skipSpace.
    value := self attValue.
    value == nil ifTrue: [self malformed: 'A quoted value for the attribute was expected, but not found'].
    self checkReservedAttributes: nm asString
    	type: nil
    	value: value.
    ^Attribute name: nm value: value!

attributeFor: elementTag
    | nm value |
    nm := self getQualifiedName.
    self skipSpace.
    self mustFind: '='.
    self skipSpace.
    value := self attValue: (self dtd attributeTypeFor: elementTag subKey: nm from: self)
    		inDTD: false.
    value == nil ifTrue: [self malformed: 'A quoted value for the attribute was expected, but not found'].
    self checkReservedAttributes: nm asString
    	type: nil
    	value: value.
    ^Attribute name: nm value: value!

attValue
    | aQuote s str1 |
    aQuote := hereChar.
    (aQuote = $' or: [aQuote = $"]) ifFalse: [^nil].
    buffer reset.
    s := currentSource.
    self getNextChar.
    [(hereChar = aQuote and: [s = currentSource])]
    	whileFalse:
    		[hereChar == nil
    			ifTrue: [self malformed: 'No close quote found for attribute value'].
    		hereChar = $<
    			ifTrue: [self malformed: '< not permitted in attribute values; use &lt;'].
    		hereChar = $&
    			ifTrue:
    				[str1 := currentSource.
    				(self skipIf: '&#')
    					ifTrue: [self charEntity: buffer startedIn: str1]
    					ifFalse: [self getNextChar; generalEntityInText: buffer canBeExternal: false]]
    			ifFalse:
    				[hereChar asInteger < 16r20
    					ifTrue: [buffer space]
    					ifFalse: [buffer nextPut: hereChar].
    				self getNextChar]].
    self getNextChar.
    ^buffer contents!

attValue: attType inDTD: isInDTD
    | aQuote s str1 sawSpace needsSpace isCDATA count |
    isCDATA := attType class == CDATA_AT.
    aQuote := hereChar.
    (aQuote = $' or: [aQuote = $"]) ifFalse: [^nil].
    buffer reset.
    s := currentSource.
    self getNextChar.
    count := 0.
    sawSpace := true.
    needsSpace := false.
    [(hereChar = aQuote and: [s = currentSource])]
    	whileFalse:
    		[hereChar == nil
    			ifTrue: [self malformed: 'No close quote found for attribute value'].
    		hereChar = $<
    			ifTrue: [self malformed: '< not permitted in attribute values; use &lt;'].
    		hereChar = $&
    			ifTrue:
    				[str1 := currentSource.
    				(self skipIf: '&#')
    					ifTrue:
    						[needsSpace ifTrue: [buffer space].
    						needsSpace := sawSpace := false.
    						count := count + 1.
    						self charEntity: buffer startedIn: str1]
    					ifFalse: [self getNextChar; generalEntityInText: buffer canBeExternal: false]]
    			ifFalse: [(isInDTD and: [self PERef: #data])
    				ifFalse:
    					[hereChar asInteger <= 16r20
    						ifTrue: [isCDATA
    							ifTrue: [buffer space]
    							ifFalse: [sawSpace ifFalse: [sawSpace := needsSpace := true]]]
    						ifFalse:
    							[needsSpace ifTrue: [buffer space].
    							needsSpace := sawSpace := false.
    							buffer nextPut: hereChar].
    					count := count + 1.
    					self getNextChar]]].
    (self isValidating and: [self isDeclaredStandalone
    		and: [count ~= buffer position and: [attType isExternal]]])
    	ifTrue: [self invalid: 'This document is not standalone'].
    self getNextChar.
    ^buffer contents!

checkCountryCode: code from: value
    code size >= 2
    	ifFalse: [self illegalLanguageCode: value].
    "code size = 2
    	ifTrue: [self checkIso3166Code: code from: value]
    	ifFalse: [self checkIanaSubcode: code from: value]"!

checkIanaLanguageCode: code from: value
    ^self!

checkIso639LanguageCode: code from: value
    code size = 2
    	ifFalse: [self illegalLanguageCode: value].!

checkLanguageCode: value
    | vals list |
    value == nil ifTrue: [^self].
    value size = 0
    	ifTrue: [self illegalLanguageCode: value].
    value last = $-
    	ifTrue: [self illegalLanguageCode: value].
    vals := value readStream.
    list := OrderedCollection new.
    [vals atEnd] whileFalse: [list add: (vals upTo: $-) asLowercase].
    list do: [:subcode |
    	subcode size = 0
    		ifTrue: [self illegalLanguageCode: value].
    	subcode do: [:ch |
    		(ch between: $a and: $z)
    			ifFalse: [self illegalLanguageCode: value]]].
    list first = 'x'
    	ifTrue:
    		[list size > 1
    			ifFalse: [self illegalLanguageCode: value].
    		^self].
    list first = 'i'
    	ifTrue:
    		[list size > 1
    			ifFalse: [self illegalLanguageCode: value].
    		self checkIanaLanguageCode: (list at: 2) from: value.
    		list size > 2
    			ifTrue: [self checkCountryCode: (list at: 3) from: value].
    		^self].
    self checkIso639LanguageCode: (list at: 1) from: value.
    list size > 1
    	ifTrue: [self checkCountryCode: (list at: 2) from: value].!

checkReservedAttributes: nm type: type value: value
    nm = 'xml:lang'
    	ifTrue: [self checkLanguageCode: value].
    nm = 'xml:space'
    	ifTrue:
    		[(type = nil
    				or: [type class = Enumeration_AT
    				and: [(type values asSet - #('default' 'preserve') asSet) isEmpty]])
    			ifFalse: [self malformed: 'Malformed type definition for xml:space'].
    		"The value may be nil if we're checking the ATTLIST definition"
    		(value = 'default' or: [value = 'preserve' or: [value == nil]])
    			ifFalse: [self malformed: 'xml:space must have a value of "preserve" or "default"']].!

illegalLanguageCode: value
    self malformed: ('Illegal value (%1) for xml:lang' bindWith: value)!

isValidName: aTag
    aTag size = 0 ifTrue: [^false].
    (self isValidNameStart: aTag first)
    	ifFalse: [^false].
    2 to: aTag size do: [:i |
    	(self isValidNameChar: (aTag at: i))
    		ifFalse: [^false]].
    ^true!

isValidNmToken: aTag
    aTag size = 0 ifTrue: [^false].
    1 to: aTag size do: [:i |
    	((self isValidNameChar: (aTag at: i)) or: [(aTag at: i) = $:])
    		ifFalse: [^false]].
    ^true!

processAttributes: nm
    | attributes hadSpace |
    attributes := nil.
    [hadSpace := self skipSpace.
    self isValidNameStart: hereChar]
    	whileTrue:
    		[hadSpace ifFalse: [self malformed: 'Attributes must be preceded by white space'].
    		attributes == nil ifTrue: [attributes := OrderedCollection new: 5].
    		attributes addLast: (self attributeFor: nm).
    		(attributes collect: [:i | i tag asString]) asSet size = attributes size
    			ifFalse: [self malformed: ('The attribute "%1" was used twice in this element''s tag'
    							bindWith: attributes last tag asString)]].
    self isValidating
    	ifTrue: [attributes := self validateAttributes: attributes for: nm].
    attributes := self resolveNamespaces: attributes.
    ^attributes!

quotedString
    | string |
    hereChar = $"
    	ifTrue:
    		[string := self upTo: $".
    		self getNextChar.
    		^string].
    hereChar = $'
    	ifTrue:
    		[string := self upTo: $'.
    		self getNextChar.
    		^string].
    self malformed: 'Quoted string expected but not found'!

validateAttributes: attributes for: tag
    | attr attributeList |
    attr := self dtd attributesFor: tag.
    attributeList := attributes == nil ifTrue: [#()] ifFalse: [attributes].
    attributeList do: [:i |
    	(attr includesKey: i key asString)
    		ifFalse: [self invalid: ('the attribute %1 was not defined in the DTD'
    							bindWith: i key)]].
    attr do: [:adef | | a |
    	a := attributeList detect: [:at | at key isLike: adef name] ifNone: [].
    	a == nil
    		ifTrue: [adef hasDefault
    			ifTrue:
    				[(self isValidating and: [self isDeclaredStandalone and: [adef type isExternal]])
    					ifTrue: [self invalid: 'This document is not standalone'].
    				attributeList := attributeList copyWith:
    						(Attribute name: adef name value: adef default)]
    			ifFalse: [adef isRequired
    				ifTrue: [self invalid: ('"%1" elements are required to have a "%2" attribute'
    								bindWith: tag asString
    								with: adef name asString)]]]
    		ifFalse: [adef validateValueOf: a for: self]].
    ^attributeList size = 0
    	ifTrue: [nil]
    	ifFalse: [attributeList]! !

!XMLParser methodsFor: 'IDs'!

checkUnresolvedIDREFs
    (self isValidating and: [unresolvedIDREFs isEmpty not])
    	ifTrue: [self invalid: ('The IDREFs %1 have not been resolved to IDs' bindWith: unresolvedIDREFs asSortedCollection asArray)]!

registerID: attribute
    latestID := attribute value.
    (definedIDs includes: latestID)
    	ifTrue: [self invalid: ('The id "%1" was used more than once' bindWith: latestID)].
    definedIDs add: latestID.
    unresolvedIDREFs remove: latestID ifAbsent: []!

rememberIDREF: anID
    (definedIDs includes: anID) ifFalse: [unresolvedIDREFs add: anID]! !

!XMLParser methodsFor: 'streaming'!

atEnd
    [sourceStack == nil ifTrue: [^true].
    sourceStack atEnd]
    	whileTrue:
    		[sourceStack close.
    		sourceStack := sourceStack nextLink].
    ^false!

forceSpace
    self skipSpace ifFalse: [self expectedWhitespace].!

forceSpaceInDTD
    self skipSpaceInDTD ifFalse: [self expectedWhitespace].!

getNextChar
    ^hereChar := self nextChar!

mustFind: str
    (self skipIf: str)
    	ifFalse: [self expected: str]!

nextChar
    | ch |
    self atEnd ifTrue: [^nil].
    lastSource := currentSource.
    currentSource := sourceStack.
    ch := currentSource next.
    ^ch!

skipIf: str
    | p oc l c |
    hereChar = str first ifFalse: [^false].
    p := self sourceWrapper stream position.
    l := self sourceWrapper line.
    c := self sourceWrapper column.
    oc := hereChar.
    1 to: str size do: [:i |
    	hereChar = (str at: i)
    		ifFalse:
    			[self sourceWrapper stream position: p.
    			self sourceWrapper line: l; column: c.
    			hereChar := oc.
    			^false].
    	lastSource := currentSource.
    	currentSource := self sourceWrapper.
    	hereChar := self sourceWrapper next].
    hereChar == nil
    	ifTrue: [self getNextChar].
    ^true!

skipSpace
    | n |
    n := 0.
    [hereChar ~~ nil and: [#(9 10 13 32) includes: hereChar asInteger]] whileTrue:
    	[n := n + 1.
    	self getNextChar].
    ^n > 0!

skipSpaceInDTD
    | space |
    space := self skipSpace.
    [self PERef: #dtd]
    	whileTrue: [space := self skipSpace | space].
    ^space!

upTo: aCharacter
    "Answer a subcollection from position to the occurrence (if any, exclusive) of anObject.
     The stream is left positioned after anObject.
    If anObject is not found answer everything."

    | newStream element |
    newStream := (String new: 64) writeStream.
    [self atEnd]
    	whileFalse:
    		[element := self nextChar.
    		element = aCharacter
    			ifTrue: [^newStream contents].
    		newStream nextPut: element.].
    self expected: (String with: aCharacter).
    ^newStream contents!

upToAll: target
    " Answer a subcollection from the current position
    up to the occurrence (if any, not inclusive) of target,
    and leave the stream positioned before the occurrence.
    If no occurrence is found, answer the entire remaining
    stream contents, and leave the stream positioned at the end.
    We are going to cheat here, and assume that the first
    character in the target only occurs once in the target, so
    that we don't have to backtrack."

    | str i |
    (target occurrencesOf: target first) = 1
    	ifFalse: [self error: 'The target collection is ambiguous.'].
    self sourceWrapper skip: -1.
    str := (String new: 32) writeStream.
    [str nextPutAll: (self upTo: target first).
    i := 2.
    [i <= target size and:
    		[self nextChar = (target at: i)]]
    	whileTrue:
    		[i := i + 1].
    i <= target size]
    	whileTrue:
    		[str nextPutAll: (target copyFrom: 1 to: i - 1).
    		self sourceWrapper skip: -1].
    self getNextChar.
    ^str contents! !

!XMLParser methodsFor: 'private'!

closeAllFiles
    self fullSourceStack do: [:str | str close]!

documentNode
    ^self document!

expected: string
    self malformed: ('%1 expected, but not found' bindWith: string)!

expectedWhitespace
    self malformed: 'White space expected but not found'!

fullSourceStack
    | out s |
    out := OrderedCollection new.
    s := sourceStack.
    [s == nil]
    	whileFalse:
    		[out addFirst: s.
    		s := s nextLink].
    ^out!

getQualifiedName
    | nm |
    nm := self getSimpleName.
    ^hereChar = $:
    	ifTrue:
    		[self getNextChar.
    		NodeTag new qualifier: nm ns: '' type: self getSimpleName]
    	ifFalse:
    		[NodeTag new qualifier: '' ns: '' type: nm]!

getSimpleName
    (self isValidNameStart: hereChar) ifFalse: [^self malformed: 'An XML name was expected'].
    nameBuffer reset.
    nameBuffer nextPut: hereChar.
    [self getNextChar.
    hereChar notNil and: [self isValidNameChar: hereChar]]
    	whileTrue: [nameBuffer nextPut: hereChar].
    ^nameBuffer contents!

invalid: aMessage
    sax nonFatalError: (InvalidSignal new messageText: aMessage)!

isValidNameChar: c
    ^c = $:
    	ifTrue: [self processNamespaces not]
    	ifFalse: [((CharacterClasses at: c asInteger + 1) bitAnd: 2) = 2]!

isValidNameStart: c
    ^c = $:
    	ifTrue: [self processNamespaces not]
    	ifFalse: [((CharacterClasses at: c asInteger + 1) bitAnd: 4) = 4]!

malformed: aMessage
    sax fatalError: (MalformedSignal new messageText: aMessage)!

nmToken
    ((self isValidNameChar: hereChar) or: [hereChar = $:])
    	ifFalse: [^self malformed: 'An XML NmToken was expected'].
    buffer reset.
    buffer nextPut: hereChar.
    [self getNextChar.
    hereChar notNil and: [(self isValidNameChar: hereChar) or: [hereChar = $:]]]
    	whileTrue: [buffer nextPut: hereChar].
    ^buffer contents!

validateEncoding: encName
    | c |
    encName size = 0 ifTrue: [self malformed: 'A non-empty encoding name was expected'].
    c := encName first.
    (c asInteger < 128 and: [c isLetter])
    	ifFalse: [self malformed: ('The first letter of the encoding ("%1") must be an ASCII alphabetic letter'
    					bindWith: encName)].
    2 to: encName size do: [:i |
    	c := encName at: i.
    	(c asInteger < 128 and: [c isLetter or: [c isDigit or: ['._-' includes: c]]])
    		ifFalse: [self malformed: ('A letter in the encoding name ("%1") must be ''.'', ''_'', ''-'', or an ASCII letter or digit'
    					bindWith: encName)]]!

warn: aMessage
    sax warning: (WarningSignal new messageText: aMessage)!

with: list add: node
    node isDiscarded
    	ifFalse: [list add: node]! !

!XMLParser methodsFor: 'flags'!

declaredStandalone: aBoolean
    ^aBoolean
    	ifTrue: [flags := flags bitOr: 2]
    	ifFalse: [flags := flags bitAnd: 2 bitInvert]!

flagsComment
    "The 'flags' instance variable is an integer used
    as a bit vector of boolean values, either recording
    state as processing occurs, or recording options
    that control how the processor is used. The following
    documents which bits have been assigned and for
    which purpose.

    State bits [0..15]
    	0 -- parser is currently inside an <![IGNORE[ section
    	1 -- document has standalone='yes' declaration
    	2 -- document has a DTD
    	3 -- document has an externalDTD
    	4 -- document uses parameter entity references to define part of the DTD

    Option bits [16..29]
    	16 -- do namespace attributes
    	17 -- pass namespace declarations on to the client
    "

    ^self commentOnly!

hasDTD
    ^(flags bitAnd: 4) = 4!

hasExternalDTD
    ^(flags bitAnd: 8) = 8!

ignore
    ^(flags bitAnd: 1) = 1!

ignore: aBoolean
    ^aBoolean
    	ifTrue: [flags := flags bitOr: 1]
    	ifFalse: [flags := flags bitAnd: 1 bitInvert]!

isDeclaredStandalone
    ^(flags bitAnd: 2) = 2!

noteDTD
    flags := (flags bitOr: 4)!

noteExternalDTD
    flags := (flags bitOr: 8)!

notePEReference
    flags := (flags bitOr: 16r10)!

processNamespaces
    ^(flags bitAnd: 16r10000) = 16r10000!

processNamespaces: aBoolean
    ^aBoolean
    	ifTrue: [flags := flags bitOr: 16r10000]
    	ifFalse: [flags := flags bitAnd: 16r10000 bitInvert]!

showNamespaceDeclarations
    ^(flags bitAnd: 16r20000) = 16r20000!

showNamespaceDeclarations: aBoolean
    ^aBoolean
    	ifTrue: [flags := flags bitOr: 16r20000]
    	ifFalse: [flags := flags bitAnd: 16r20000 bitInvert]!

usesParameterEntities
    ^(flags bitAnd: 16r10) = 16r10! !

!XMLParser methodsFor: 'namespaces'!

correctAttributeTag: attribute
    | ns tag qual type |
    qual := attribute tag qualifier.
    qual isEmpty
    	ifTrue: [^self].
    type := attribute tag type.
    ns := self findNamespace: qual.
    tag := NodeTag new qualifier: qual ns: ns type: type.
    attribute tag: tag!

correctTag: tag
    | ns type qualifier |
    qualifier := tag qualifier.
    type := tag type.
    ns := self findNamespace: qualifier.
    ^NodeTag new qualifier: qualifier ns: ns type: type!

findNamespace: ns
    | nsURI |
    ns = 'xml' ifTrue: [^XML_URI].
    ns = 'xmlns' ifTrue: [^'<!-- xml namespace -->'].
    elementStack size to: 1 by: -1 do: [:i |
    	nsURI := (elementStack at: i) findNamespace: ns.
    	nsURI = nil ifFalse: [^nsURI]].
    ^ns = ''
    	ifTrue: ['']
    	ifFalse: [self invalid: ('The namespace qualifier %1 has not been bound to a namespace URI' bindWith: ns)]!

resolveNamespaces: attributes
    | newAttributes showDecls t1 t2 k |
    self processNamespaces ifFalse: [^attributes].
    showDecls := self showNamespaceDeclarations.
    attributes == nil
    	ifTrue: [newAttributes := #()]
    	ifFalse:
    		[newAttributes := OrderedCollection new: attributes size.
    		attributes do: [:attr || save |
    			save := showDecls.
    			attr tag qualifier = 'xmlns'
    				ifTrue: [elementStack last defineNamespace: attr from: self]
    				ifFalse: [(attr tag isLike: 'xmlns')
    					ifTrue: [elementStack last defineDefaultNamespace: attr]
    					ifFalse: [save := true]].
    			save ifTrue:
    				[newAttributes add: attr]].
    		newAttributes do: [:attr | self correctAttributeTag: attr].
    		1 to: newAttributes size do: [:i |
    			t1 := (newAttributes at: i) tag.
    			k := i + 1.
    			[k <= newAttributes size]
    				whileTrue:
    					[t2 := (newAttributes at: k) tag.
    					(t1 type = t2 type and: [t1 namespace = t2 namespace])
    						ifTrue:
    							[self malformed: ('The attributes "%1" and "%2" have the same namespace and type'
    									bindWith: t1 asString
    									with: t2 asString).
    							k := newAttributes size].
    					k := k + 1]]].
    elementStack last tag: (self correctTag: elementStack last tag).
    ^newAttributes isEmpty
    	ifTrue: [nil]
    	ifFalse: [newAttributes asArray]! !

!XMLParser methodsFor: 'SAX accessing'!

atFeature: aURIstring
    aURIstring = SAXValidate
    	ifTrue: [^self isValidating].
    aURIstring = SAXNamespace
    	ifTrue: [^self processNamespaces].
    aURIstring = SAXNamespacePrefixes
    	ifTrue: [^self showNamespaceDeclarations].
    aURIstring = SAXExternalGeneralEntities
    	ifTrue: [^SAXNotSupportedException signal].
    aURIstring = SAXExternalParameterEntities
    	ifTrue: [^SAXNotSupportedException signal].
    SAXNotRecognizedException new signal
!

atFeature: aURIstring put: aBoolean
    aURIstring = SAXValidate
    	ifTrue: [^self validate: aBoolean].
    aURIstring = SAXNamespace
    	ifTrue: [^self processNamespaces: aBoolean].
    aURIstring = SAXNamespacePrefixes
    	ifTrue: [^self showNamespaceDeclarations: aBoolean].
    aURIstring = SAXExternalGeneralEntities
    	ifTrue: [^SAXNotSupportedException signal].
    aURIstring = SAXExternalParameterEntities
    	ifTrue: [^SAXNotSupportedException signal].
    SAXNotRecognizedException new signal
!

atProperty: aURIstring
    SAXNotRecognizedException new signal
!

atProperty: aURIstring put: anObject
    SAXNotRecognizedException new signal
!

contentHandler
    ^sax contentHandler!

contentHandler: aSAXDriver
    | newSax |
    newSax := sax class == SAXDispatcher
    	ifTrue: [sax]
    	ifFalse: [SAXDispatcher new handlers: sax].
    newSax contentHandler: aSAXDriver.
    self saxDriver: newSax!

dtdHandler
    ^sax dtdHandler!

dtdHandler: aSAXDriver
    | newSax |
    newSax := sax class == SAXDispatcher
    	ifTrue: [sax]
    	ifFalse: [SAXDispatcher new handlers: sax].
    newSax dtdHandler: aSAXDriver.
    self saxDriver: newSax!

entityResolver
    ^sax entityResolver!

entityResolver: aSAXDriver
    | newSax |
    newSax := sax class == SAXDispatcher
    	ifTrue: [sax]
    	ifFalse: [SAXDispatcher new handlers: sax].
    newSax entityResolver: aSAXDriver.
    self saxDriver: newSax!

errorHandler
    ^sax errorHandler!

errorHandler: aSAXDriver
    | newSax |
    newSax := sax class == SAXDispatcher
    	ifTrue: [sax]
    	ifFalse: [SAXDispatcher new handlers: sax].
    newSax errorHandler: aSAXDriver.
    self saxDriver: newSax!

handlers: aSAXDriver
    self saxDriver: aSAXDriver!

parse: dataSource
    self on: dataSource.
    ^self scanDocument!

parseElement
    ^[sax startDocumentFragment.
    self getNextChar.
    hereChar = $<
    	ifFalse: [self expected: '<'].
    self getElement.
    sax endDocumentFragment.
    sax document == nil
    	ifTrue: [nil]
    	ifFalse: [sax document elements first]]
    	ifCurtailed: [self closeAllFiles]!

parseElement: dataSource
    self validate: false.
    self on: dataSource.
    ^self parseElement!

parseElements
    ^[sax startDocumentFragment.
      self prolog.
      [self atEnd] whileFalse:
    		[self getElement.
    		[self misc] whileTrue].
      sax endDocumentFragment.
      sax document == nil
    		ifTrue: [nil]
    		ifFalse: [sax document elements]]
    	ifCurtailed: [self closeAllFiles]!

parseElements: dataSource
    self validate: false.
    self on: dataSource.
    ^self parseElements! !

!XMLParser class methodsFor: 'class initialization'!

characterTable
    | ch sets pc nameChars nameStartChars |
    ch := CharacterTable new: 16r10000.
    nameChars := self nameChars.
    nameStartChars := self nameStartChars.
    sets := Array with: (16r20 to: 16rD7FF)
                  with: (16rE000 to: 16rFFFD).
    
    pc := XMLParser.
    sets do: [:s || startS endS |
        startS := s first.
        endS := s last.
        startS to: endS do: [:i |
            ch at: i + 1 put: ((nameStartChars includes: i)
		ifTrue: [ 7 ]
		ifFalse: [ (nameChars includes: i)
		     ifTrue: [ 3 ]
		     ifFalse: [ 1 ]])
        ].
    ].

    ch at: 9+1 put: 1.
    ch at: 10+1 put: 1.
    ch at: 13+1 put: 1.
    ch at: $_ asInteger + 1 put: 7.
    ch at: $- asInteger + 1 put: 3.
    ch at: $. asInteger + 1 put: 3.
    ^ch compress; yourself!

nameChars
    ^(Set new: 1024)
            addAll: (16r0300 to: 16r0345);
            addAll: (16r0360 to: 16r0361);
            addAll: (16r0483 to: 16r0486);
            addAll: (16r0591 to: 16r05A1);
            addAll: (16r05A3 to: 16r05B9);
            addAll: (16r05BB to: 16r05BD);
            add: 16r05BF;
            addAll: (16r05C1 to: 16r05C2);
            add: 16r05C4;
            addAll: (16r064B to: 16r0652);
            add: 16r0670;
            addAll: (16r06D6 to: 16r06DC);
            addAll: (16r06DD to: 16r06DF);
            addAll: (16r06E0 to: 16r06E4);
            addAll: (16r06E7 to: 16r06E8);
            addAll: (16r06EA to: 16r06ED);
            addAll: (16r0901 to: 16r0903);
            add: 16r093C;
            addAll: (16r093E to: 16r094C);
            add: 16r094D;
            addAll: (16r0951 to: 16r0954);
            addAll: (16r0962 to: 16r0963);
            addAll: (16r0981 to: 16r0983);
            add: 16r09BC;
            add: 16r09BE;
            add: 16r09BF;
            addAll: (16r09C0 to: 16r09C4);
            addAll: (16r09C7 to: 16r09C8);
            addAll: (16r09CB to: 16r09CD);
            add: 16r09D7;
            addAll: (16r09E2 to: 16r09E3);
            add: 16r0A02;
            add: 16r0A3C;
            add: 16r0A3E;
            add: 16r0A3F;
            addAll: (16r0A40 to: 16r0A42);
            addAll: (16r0A47 to: 16r0A48);
            addAll: (16r0A4B to: 16r0A4D);
            addAll: (16r0A70 to: 16r0A71);
            addAll: (16r0A81 to: 16r0A83);
            add: 16r0ABC;
            addAll: (16r0ABE to: 16r0AC5);
            addAll: (16r0AC7 to: 16r0AC9);
            addAll: (16r0ACB to: 16r0ACD);
            addAll: (16r0B01 to: 16r0B03);
            add: 16r0B3C;
            addAll: (16r0B3E to: 16r0B43);
            addAll: (16r0B47 to: 16r0B48);
            addAll: (16r0B4B to: 16r0B4D);
            addAll: (16r0B56 to: 16r0B57);
            addAll: (16r0B82 to: 16r0B83);
            addAll: (16r0BBE to: 16r0BC2);
            addAll: (16r0BC6 to: 16r0BC8);
            addAll: (16r0BCA to: 16r0BCD);
            add: 16r0BD7;
            addAll: (16r0C01 to: 16r0C03);
            addAll: (16r0C3E to: 16r0C44);
            addAll: (16r0C46 to: 16r0C48);
            addAll: (16r0C4A to: 16r0C4D);
            addAll: (16r0C55 to: 16r0C56);
            addAll: (16r0C82 to: 16r0C83);
            addAll: (16r0CBE to: 16r0CC4);
            addAll: (16r0CC6 to: 16r0CC8);
            addAll: (16r0CCA to: 16r0CCD);
            addAll: (16r0CD5 to: 16r0CD6);
            addAll: (16r0D02 to: 16r0D03);
            addAll: (16r0D3E to: 16r0D43);
            addAll: (16r0D46 to: 16r0D48);
            addAll: (16r0D4A to: 16r0D4D);
            add: 16r0D57;
            add: 16r0E31;
            addAll: (16r0E34 to: 16r0E3A);
            addAll: (16r0E47 to: 16r0E4E);
            add: 16r0EB1;
            addAll: (16r0EB4 to: 16r0EB9);
            addAll: (16r0EBB to: 16r0EBC);
            addAll: (16r0EC8 to: 16r0ECD);
            addAll: (16r0F18 to: 16r0F19);
            add: 16r0F35;
            add: 16r0F37;
            add: 16r0F39;
            add: 16r0F3E;
            add: 16r0F3F;
            addAll: (16r0F71 to: 16r0F84);
            addAll: (16r0F86 to: 16r0F8B);
            addAll: (16r0F90 to: 16r0F95);
            add: 16r0F97;
            addAll: (16r0F99 to: 16r0FAD);
            addAll: (16r0FB1 to: 16r0FB7);
            add: 16r0FB9;
            addAll: (16r20D0 to: 16r20DC);
            add: 16r20E1;
            addAll: (16r302A to: 16r302F);
            add: 16r3099;
            add: 16r309A;
            addAll: (16r0030 to: 16r0039);
            addAll: (16r0660 to: 16r0669);
            addAll: (16r06F0 to: 16r06F9);
            addAll: (16r0966 to: 16r096F);
            addAll: (16r09E6 to: 16r09EF);
            addAll: (16r0A66 to: 16r0A6F);
            addAll: (16r0AE6 to: 16r0AEF);
            addAll: (16r0B66 to: 16r0B6F);
            addAll: (16r0BE7 to: 16r0BEF);
            addAll: (16r0C66 to: 16r0C6F);
            addAll: (16r0CE6 to: 16r0CEF);
            addAll: (16r0D66 to: 16r0D6F);
            addAll: (16r0E50 to: 16r0E59);
            addAll: (16r0ED0 to: 16r0ED9);
            addAll: (16r0F20 to: 16r0F29);
            add: 16r00B7;
            add: 16r02D0;
            add: 16r02D1;
            add: 16r0387;
            add: 16r0640;
            add: 16r0E46;
            add: 16r0EC6;
            add: 16r3005;
            addAll: (16r3031 to: 16r3035);
            addAll: (16r309D to: 16r309E);
            addAll: (16r30FC to: 16r30FE);
	    yourself!

nameStartChars
    ^(Set new: 65536)
            addAll: (16r0041 to: 16r005A);
            addAll: (16r0061 to: 16r007A);
            addAll: (16r00C0 to: 16r00D6);
            addAll: (16r00D8 to: 16r00F6);
            addAll: (16r00F8 to: 16r00FF);
            addAll: (16r0100 to: 16r0131);
            addAll: (16r0134 to: 16r013E);
            addAll: (16r0141 to: 16r0148);
            addAll: (16r014A to: 16r017E);
            addAll: (16r0180 to: 16r01C3);
            addAll: (16r01CD to: 16r01F0);
            addAll: (16r01F4 to: 16r01F5);
            addAll: (16r01FA to: 16r0217);
            addAll: (16r0250 to: 16r02A8);
            addAll: (16r02BB to: 16r02C1);
            add: 16r0386;
            addAll: (16r0388 to: 16r038A);
            add: 16r038C;
            addAll: (16r038E to: 16r03A1);
            addAll: (16r03A3 to: 16r03CE);
            addAll: (16r03D0 to: 16r03D6);
            add: 16r03DA;
            add: 16r03DC;
            add: 16r03DE;
            add: 16r03E0;
            addAll: (16r03E2 to: 16r03F3);
            addAll: (16r0401 to: 16r040C);
            addAll: (16r040E to: 16r044F);
            addAll: (16r0451 to: 16r045C);
            addAll: (16r045E to: 16r0481);
            addAll: (16r0490 to: 16r04C4);
            addAll: (16r04C7 to: 16r04C8);
            addAll: (16r04CB to: 16r04CC);
            addAll: (16r04D0 to: 16r04EB);
            addAll: (16r04EE to: 16r04F5);
            addAll: (16r04F8 to: 16r04F9);
            addAll: (16r0531 to: 16r0556);
            add: 16r0559;
            addAll: (16r0561 to: 16r0586);
            addAll: (16r05D0 to: 16r05EA);
            addAll: (16r05F0 to: 16r05F2);
            addAll: (16r0621 to: 16r063A);
            addAll: (16r0641 to: 16r064A);
            addAll: (16r0671 to: 16r06B7);
            addAll: (16r06BA to: 16r06BE);
            addAll: (16r06C0 to: 16r06CE);
            addAll: (16r06D0 to: 16r06D3);
            add: 16r06D5;
            addAll: (16r06E5 to: 16r06E6);
            addAll: (16r0905 to: 16r0939);
            add: 16r093D;
            addAll: (16r0958 to: 16r0961);
            addAll: (16r0985 to: 16r098C);
            addAll: (16r098F to: 16r0990);
            addAll: (16r0993 to: 16r09A8);
            addAll: (16r09AA to: 16r09B0);
            add: 16r09B2;
            addAll: (16r09B6 to: 16r09B9);
            addAll: (16r09DC to: 16r09DD);
            addAll: (16r09DF to: 16r09E1);
            addAll: (16r09F0 to: 16r09F1);
            addAll: (16r0A05 to: 16r0A0A);
            addAll: (16r0A0F to: 16r0A10);
            addAll: (16r0A13 to: 16r0A28);
            addAll: (16r0A2A to: 16r0A30);
            addAll: (16r0A32 to: 16r0A33);
            addAll: (16r0A35 to: 16r0A36);
            addAll: (16r0A38 to: 16r0A39);
            addAll: (16r0A59 to: 16r0A5C);
            add: 16r0A5E;
            addAll: (16r0A72 to: 16r0A74);
            addAll: (16r0A85 to: 16r0A8B);
            add: 16r0A8D;
            addAll: (16r0A8F to: 16r0A91);
            addAll: (16r0A93 to: 16r0AA8);
            addAll: (16r0AAA to: 16r0AB0);
            addAll: (16r0AB2 to: 16r0AB3);
            addAll: (16r0AB5 to: 16r0AB9);
            add: 16r0ABD;
            add: 16r0AE0;
            addAll: (16r0B05 to: 16r0B0C);
            addAll: (16r0B0F to: 16r0B10);
            addAll: (16r0B13 to: 16r0B28);
            addAll: (16r0B2A to: 16r0B30);
            addAll: (16r0B32 to: 16r0B33);
            addAll: (16r0B36 to: 16r0B39);
            add: 16r0B3D;
            addAll: (16r0B5C to: 16r0B5D);
            addAll: (16r0B5F to: 16r0B61);
            addAll: (16r0B85 to: 16r0B8A);
            addAll: (16r0B8E to: 16r0B90);
            addAll: (16r0B92 to: 16r0B95);
            addAll: (16r0B99 to: 16r0B9A);
            add: 16r0B9C;
            addAll: (16r0B9E to: 16r0B9F);
            addAll: (16r0BA3 to: 16r0BA4);
            addAll: (16r0BA8 to: 16r0BAA);
            addAll: (16r0BAE to: 16r0BB5);
            addAll: (16r0BB7 to: 16r0BB9);
            addAll: (16r0C05 to: 16r0C0C);
            addAll: (16r0C0E to: 16r0C10);
            addAll: (16r0C12 to: 16r0C28);
            addAll: (16r0C2A to: 16r0C33);
            addAll: (16r0C35 to: 16r0C39);
            addAll: (16r0C60 to: 16r0C61);
            addAll: (16r0C85 to: 16r0C8C);
            addAll: (16r0C8E to: 16r0C90);
            addAll: (16r0C92 to: 16r0CA8);
            addAll: (16r0CAA to: 16r0CB3);
            addAll: (16r0CB5 to: 16r0CB9);
            add: 16r0CDE;
            addAll: (16r0CE0 to: 16r0CE1);
            addAll: (16r0D05 to: 16r0D0C);
            addAll: (16r0D0E to: 16r0D10);
            addAll: (16r0D12 to: 16r0D28);
            addAll: (16r0D2A to: 16r0D39);
            addAll: (16r0D60 to: 16r0D61);
            addAll: (16r0E01 to: 16r0E2E);
            add: 16r0E30;
            addAll: (16r0E32 to: 16r0E33);
            addAll: (16r0E40 to: 16r0E45);
            addAll: (16r0E81 to: 16r0E82);
            add: 16r0E84;
            addAll: (16r0E87 to: 16r0E88);
            add: 16r0E8A;
            add: 16r0E8D;
            addAll: (16r0E94 to: 16r0E97);
            addAll: (16r0E99 to: 16r0E9F);
            addAll: (16r0EA1 to: 16r0EA3);
            add: 16r0EA5;
            add: 16r0EA7;
            addAll: (16r0EAA to: 16r0EAB);
            addAll: (16r0EAD to: 16r0EAE);
            add: 16r0EB0;
            addAll: (16r0EB2 to: 16r0EB3);
            add: 16r0EBD;
            addAll: (16r0EC0 to: 16r0EC4);
            addAll: (16r0F40 to: 16r0F47);
            addAll: (16r0F49 to: 16r0F69);
            addAll: (16r10A0 to: 16r10C5);
            addAll: (16r10D0 to: 16r10F6);
            add: 16r1100;
            addAll: (16r1102 to: 16r1103);
            addAll: (16r1105 to: 16r1107);
            add: 16r1109;
            addAll: (16r110B to: 16r110C);
            addAll: (16r110E to: 16r1112);
            add: 16r113C;
            add: 16r113E;
            add: 16r1140;
            add: 16r114C;
            add: 16r114E;
            add: 16r1150;
            addAll: (16r1154 to: 16r1155);
            add: 16r1159;
            addAll: (16r115F to: 16r1161);
            add: 16r1163;
            add: 16r1165;
            add: 16r1167;
            add: 16r1169;
            addAll: (16r116D to: 16r116E);
            addAll: (16r1172 to: 16r1173);
            add: 16r1175;
            add: 16r119E;
            add: 16r11A8;
            add: 16r11AB;
            addAll: (16r11AE to: 16r11AF);
            addAll: (16r11B7 to: 16r11B8);
            add: 16r11BA;
            addAll: (16r11BC to: 16r11C2);
            add: 16r11EB;
            add: 16r11F0;
            add: 16r11F9;
            addAll: (16r1E00 to: 16r1E9B);
            addAll: (16r1EA0 to: 16r1EF9);
            addAll: (16r1F00 to: 16r1F15);
            addAll: (16r1F18 to: 16r1F1D);
            addAll: (16r1F20 to: 16r1F45);
            addAll: (16r1F48 to: 16r1F4D);
            addAll: (16r1F50 to: 16r1F57);
            add: 16r1F59;
            add: 16r1F5B;
            add: 16r1F5D;
            addAll: (16r1F5F to: 16r1F7D);
            addAll: (16r1F80 to: 16r1FB4);
            addAll: (16r1FB6 to: 16r1FBC);
            add: 16r1FBE;
            addAll: (16r1FC2 to: 16r1FC4);
            addAll: (16r1FC6 to: 16r1FCC);
            addAll: (16r1FD0 to: 16r1FD3);
            addAll: (16r1FD6 to: 16r1FDB);
            addAll: (16r1FE0 to: 16r1FEC);
            addAll: (16r1FF2 to: 16r1FF4);
            addAll: (16r1FF6 to: 16r1FFC);
            add: 16r2126;
            addAll: (16r212A to: 16r212B);
            add: 16r212E;
            addAll: (16r2180 to: 16r2182);
            addAll: (16r3041 to: 16r3094);
            addAll: (16r30A1 to: 16r30FA);
            addAll: (16r3105 to: 16r312C);
            addAll: (16rAC00 to: 16rD7A3);
            addAll: (16r4E00 to: 16r9FA5);
            add: 16r3007;
            addAll: (16r3021 to: 16r3029);
	    yourself! !

!XMLParser class methodsFor: 'instance creation'!

new
    ^super new initialize!

on: aDataSource
    "The dataSource may be a URI, a Filename (or a String
    which will be treated as a Filename), or an InputSource."

    ^self new on: aDataSource!

processDocumentInFilename: aFilename 
    ^self processDocumentInFilename: aFilename beforeScanDo: [:parser | ]!

processDocumentInFilename: aFilename beforeScanDo: aBlock
    | stream p |
    stream := FileStream open: aFilename mode: FileStream read.
    p := self on: stream.
    aBlock value: p.
    ^p scanDocument!

processDocumentString: aString
    ^self processDocumentString: aString beforeScanDo: [:parser | ]!

processDocumentString: aString beforeScanDo: aBlock
    | p |
    p := self on: aString readStream.
    aBlock value: p.
    ^p scanDocument! !

!XMLParser class methodsFor: 'utilities'!

mapEncoding: anEncoding
    | enc |
    enc := anEncoding asLowercase.
    enc = 'utf-8' ifTrue: [^'UTF_8'].
    enc = 'utf-16' ifTrue: [^'UTF_16'].
    enc = 'iso-8859-1' ifTrue: [^'ISO8859_1'].
    ^enc!

readFileContents: fn
    | s p r |
    r := InputSource for: fn.
    p := self new.
    p lineEndLF.
    s := StreamWrapper
    		resource: r
    		entity: nil
    		from: p.
    ^[s checkEncoding.
    s contents]
    	ensure: [s close]! !

!Comment methodsFor: 'printing'!

printHTMLOn: aStream
    self printOn: aStream!

printOn: aStream depth: indent
    aStream nextPutAll: '<!--', (text == nil ifTrue: [''] ifFalse: [text]), '-->'! !

!Comment methodsFor: 'accessing'!

text
    ^text!

text: aText
    text := aText! !

!Comment methodsFor: 'testing'!

isComment
    ^true! !

!Comment methodsFor: 'enumerating'!

saxDo: aDriver
    aDriver comment: text from: 1 to: text size! !

!AttributeDef methodsFor: 'accessing'!

default
    ^default!

default: n
    flags := 0.
    default := nil.
    n = #required
    	ifTrue: [flags := 1]
    	ifFalse: [n = #implied
    		ifTrue: [flags := 2]
    		ifFalse:
    			[n class == Association
    				ifFalse: [self error: 'Invalid default'].
    			n key ifTrue: [flags := 4].
    			default := n value]]!

hasDefault
    ^(self isImplied or: [self isRequired]) not!

isFixed
    ^(flags bitAnd: 4) = 4!

isImplied
    ^(flags bitAnd: 2) = 2!

isRequired
    ^(flags bitAnd: 1) = 1!

name
    ^name!

name: n
    name := n!

tag
    ^name!

type
    ^type!

type: n
    type := n! !

!AttributeDef methodsFor: 'validating'!

completeValidationAgainst: aParser
    ^self type completeValidationAgainst: aParser from: self!

selfValidateFor: aParser
    type validateDefinition: self for: aParser!

validateValueOf: anAttribute for: aParser
    type validateValueOf: anAttribute for: aParser.
    (self isFixed not or: [anAttribute value = self default])
    	ifFalse: [aParser invalid: ('The attribute "%1" was declared FIXED, but the value used in the document ("%2") did not match the default ("%3")'
    					bindWith: anAttribute tag asString
    					with: anAttribute value
    					with: self default)].! !

!AttributeDef methodsFor: 'private'!

value
    ^self default!

value: str
    default := str! !

!DocumentFragment methodsFor: 'accessing'!

addNode: aNode
    nodes add: aNode.
    aNode parent: self.
    aNode isElement
    	ifTrue: [root == nil
    		ifTrue: [root := aNode]]! !

!DocumentFragment methodsFor: 'enumerating'!

saxDo: aDriver
    aDriver startDocumentFragment.
    self dtd == nil ifFalse: [self dtd saxDo: aDriver].
    1 to: self children size do: [:i |
    	(self children at: i) saxDo: aDriver].
    aDriver endDocumentFragment! !

!DOM_SAXDriver methodsFor: 'other'!

comment: data from: start to: stop
    document == nil ifTrue: [self startDocument].
    stack last addNode: (Comment new text: (data copyFrom: start to: stop))!

idOfElement: elementID
    "Notify the client what was the ID of the latest startElement"

    document atID: elementID put: stack last! !

!DOM_SAXDriver methodsFor: 'content handler'!

characters: aString
    stack last addNode: (Text text: aString)!

endDocument
    document := stack removeLast.
    document isDocument ifFalse: [self error: 'End of Document not expected'].
    stack isEmpty ifFalse: [self error: 'End of Document not expected'].!

endDocumentFragment
    document := stack removeLast.
    document isDocument ifFalse: [self error: 'End of Document not expected'].
    stack isEmpty ifFalse: [self error: 'End of Document not expected'].!

endElement: namespaceURI localName: localName qName: name
    "indicates the end of an element. See startElement"

    stack removeLast condenseList!

ignorableWhitespace: aString
    stack last addNode: (Text text: aString)!

processingInstruction: targetString data: dataString
    document == nil ifTrue: [self startDocument].
    stack last addNode: (PI name: targetString text: dataString)!

startDocument
    document := Document new.
    document dtd: DocumentType new.
    stack := OrderedCollection with: document!

startDocumentFragment
    document := DocumentFragment new.
    document dtd: DocumentType new.
    stack := OrderedCollection with: document!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    | element tag |
    document == nil ifTrue: [self startDocument].
    tag := NodeTag new
    	qualifier: ((name includes: $:)
    			ifTrue: [name copyUpTo: $:]
    			ifFalse: [''])
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
    stack addLast: element!

startPrefixMapping: prefix uri: uri 
    newNamespaces == nil
    	ifTrue: [newNamespaces := Dictionary new].
    newNamespaces at: prefix put: uri.! !

!DOM_SAXDriver methodsFor: 'DTD handler'!

notationDecl: name publicID: publicID systemID: systemID
    | notation |
    notation := Notation new name: name identifiers: (Array with: publicID with: systemID).
    document dtd notationAt: name put: notation from: self! !

!DOM_SAXDriver methodsFor: 'accessing'!

document
    ^document! !

!DOM_SAXDriver methodsFor: 'compat'!

endElement
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
    ^self endElement: namespaceURI localName: localName qName: name!

startElement: tag atts: attrs
    | namespaceURI localName name attributes |
    tag isString
    	ifTrue:
    		[localName := name := tag.
    		namespaceURI := '']
    	ifFalse:
    		[localName := tag type.
    		name := tag asString.
    		namespaceURI := tag namespace].
    attributes := attrs == nil
    	ifTrue: [#()]
    	ifFalse: [attrs].
    ^self startElement: namespaceURI localName: localName qName: name attributes: attributes! !

!SequencePattern methodsFor: 'initialize'!

on: aList
    items := aList! !

!SequencePattern methodsFor: 'coercing'!

alternateHeads
    ^Array with: items first!

pushDownFollowSet
    1 to: items size - 1 do: [:i |
    	(items at: i) addFollow: (items at: i + 1)].
    items last addFollows: followSet.
    ^items! !

!SequencePattern methodsFor: 'printing'!

description
    | str |
    str := String new writeStream.
    str nextPutAll: '('.
    items do: [:ch | str nextPutAll: ch description] separatedBy: [str nextPutAll: ' , '].
    str nextPutAll: ')'.
    ^str contents!

printOn: aStream
    aStream nextPutAll: self description! !

!SequencePattern methodsFor: 'copying'!

postCopy
    super postCopy.
    items := items collect: [:i | i copy].! !

!SequencePattern class methodsFor: 'instance creation'!

on: aList
    ^self new on: aList! !

!NodeTag methodsFor: 'initialize'!

qualifier: q ns: ns type: typeStr
    namespace := ns.
    type := typeStr.
    qualifier := q! !

!NodeTag methodsFor: 'accessing'!

expandedName
    ^namespace isEmpty
    	ifTrue: [type]
    	ifFalse: [namespace, '#', type]!

namespace
    ^namespace!

qualifier
    ^qualifier!

type
    ^type! !

!NodeTag methodsFor: 'converting'!

asString
    ^qualifier isEmpty
    	ifTrue: [type]
    	ifFalse: [qualifier, ':', type]! !

!NodeTag methodsFor: 'testing'!

isLike: aName
    ^aName isString
    	ifTrue: [namespace isEmpty and: [type = aName]]
    	ifFalse: [namespace = aName namespace and: [type = aName type]]! !

!NodeTag methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: '{', self asString, '}'! !

!NodeTag methodsFor: 'comparing'!

< aNodeTag 
    "Answer whether the receiver is less than the argument."

    ^self asString < aNodeTag asString!

= aNodeTag
    ^self class = aNodeTag class
    	and: [self type = aNodeTag type
    	and: [self namespace == nil
    		ifTrue: [self qualifier = aNodeTag qualifier]
    		ifFalse: [self namespace = aNodeTag namespace]]]!

hash
    "The hash value is not dependent on either the namespace
    or the qualifier, but equality is dependent on this. We think
    this will not be a problem because collisions between tags
    that have the same type but different namespaces or qualifiers
    should be rare in the majority of cases."

    ^self type hash! !

!DocumentType methodsFor: 'initialize'!

initialize
    notations := Dictionary new.
    elementDefs := Dictionary new.
    attributeDefs := Dictionary new.
    generalEntities := Dictionary new.
    parameterEntities := Dictionary new.! !

!DocumentType methodsFor: 'accessing'!

attributeFor: key subKey: k2 from: anErrorReporter
    | val |
    (val := attributeDefs at: key asString ifAbsent: []) == nil
    	ifTrue: [anErrorReporter invalid: ('The attribute "%1 %2" has not been defined'
    						bindWith: key asString
    						with: k2 asString)].
    ^val at: k2 asString
    	ifAbsent: [anErrorReporter invalid: ('The attribute "%1 %2" has not been defined'
    						bindWith: key asString
    						with: k2 asString)]!

attributeFor: key subKey: k2 put: value from: anErrorReporter
    | dict |
    dict := attributeDefs at: key asString ifAbsentPut: [Dictionary new].
    (dict includesKey: k2 asString)
    	ifTrue: [^anErrorReporter warn: ('The attribute "%1 %2" has been defined more than once'
    				bindWith: key asString
    				with: k2 asString)].
    (value type isID and: [dict contains: [:attr | attr type isID]])
    	ifTrue: [^anErrorReporter invalid: ('The element %1 has two attributes typed as ID' bindWith: key asString)].
    dict at: k2 asString put: value!

attributesFor: key
    ^attributeDefs at: key asString ifAbsent: [Dictionary new]!

attributeTypeFor: key subKey: k2 from: anErrorReporter
    | val |
    (val := attributeDefs at: key asString ifAbsent: []) == nil
    	ifTrue: [^CDATA_AT new].
    ^(val at: k2 asString
    	ifAbsent: [^CDATA_AT new]) type!

declaredRoot
    ^declaredRoot!

declaredRoot: aTag
    declaredRoot := aTag!

elementFor: key from: anErrorReporter
    | val |
    (val := elementDefs at: key asString ifAbsent: []) == nil
    	ifTrue: [anErrorReporter warn: ('The element "%1" has not been defined'
    						bindWith: key asString)].
    ^val!

elementFor: key put: value from: anErrorReporter
    (elementDefs includesKey: key asString)
    	ifTrue:
    		[| msg |
    		msg := ('The element "%1" has been defined more than once'
    					bindWith: key asString).
    		anErrorReporter isValidating
    			ifTrue: [anErrorReporter invalid: msg]
    			ifFalse: [anErrorReporter warn: msg]].
    elementDefs at: key asString put: value!

generalEntityAt: key
    "We do some tricks to make sure that, if the value
    is predefined in the parser, we use the predefined
    value. We could just store the predefined values
    in with the general ones, but we don't want to show
    warnings if the user (very correctly) defines them.
    An enhancement would be to let the user use his own
    values rather than the predefined ones, but we know
    that the predefined ones will be correct--we don't know
    that his will be."

    | val |
    val := PredefinedEntities at: key ifAbsent: [].
    val == nil
    	ifTrue: [val := generalEntities at: key ifAbsent: []].
    ^val!

generalEntityAt: key put: value from: anErrorReporter
    (generalEntities includesKey: key)
    	ifTrue: [^anErrorReporter warn: ('The general entity "%1" has been defined more than once'
    					bindWith: key)].
    generalEntities at: key put: value!

notationAt: name from: anErrorReporter
    ^notations at: name ifAbsent: [anErrorReporter invalid: 'Reference to an undeclared Notation']!

notationAt: name ifAbsent: aBlock
    ^notations at: name ifAbsent: aBlock!

notationAt: name put: notation from: anErrorReporter
    (notations includesKey: name)
    	ifTrue: [anErrorReporter invalid: 'Duplicate definitions for a Notation'].
    notations at: name put: notation!

parameterEntityAt: key
    ^parameterEntities at: key ifAbsent: []!

parameterEntityAt: key put: value from: anErrorReporter
    (parameterEntities includesKey: key)
    	ifTrue: [^anErrorReporter warn: ('The parameter entity "%1" has been defined more than once'
    					bindWith: key)].
    parameterEntities at: key put: value! !

!DocumentType methodsFor: 'private'!

completeValidationAgainst: aParser
    generalEntities keysAndValuesDo: [:eName :entity |
    	entity completeValidationAgainst: aParser].
    attributeDefs keysAndValuesDo: [:eName :attribs |
    	attribs keysAndValuesDo: [:aName :attrib |
    		attrib completeValidationAgainst: aParser]]! !

!DocumentType methodsFor: 'printing'!

printCanonicalOn: aStream
    "Jumping through hoops to get Notations printed
    just as Sun desires--Are public IDs really supposed
    to have their white space normalized? If so, we
    should move normalization to the parser."

    | s s1 |
    notations isEmpty ifTrue: [^self].
    aStream nextPutAll: '<!DOCTYPE ';
    	nextPutAll: declaredRoot asString;
    	nextPutAll: ' ['; nl.
    (notations asSortedCollection: [:n1 :n2 | n1 name < n2 name])
    	do: [:n |
    		aStream nextPutAll: '<!NOTATION ';
    			nextPutAll: n name; space.
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
    			ifFalse: [aStream
    					nextPutAll: ' ''';
    					nextPutAll: n systemID;
    					nextPut: $'].
    		aStream nextPutAll: '>'; nl].
    aStream nextPutAll: ']>'; nl.! !

!DocumentType methodsFor: 'enumerating'!

saxDo: aDriver
    notations == nil
    	ifFalse: [notations do: [:n |
    				aDriver notationDecl: n name publicID: n publicID systemID: n systemID]]! !

!DocumentType class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!AttributeType methodsFor: 'validating'!

completeValidationAgainst: aParser from: anAttributeDef
    ^self!

simpleValidateValueOf: anAttribute for: aParser
    | v |
    v := anAttribute value copy.
    v replaceAll: Character cr with: Character space.
    v replaceAll: Character nl with: Character space.
    v replaceAll: Character tab with: Character space.
    anAttribute value: v!

stringAsTokens: aString
    | list str buffer hasToken |
    list := OrderedCollection new.
    str := aString readStream.
    buffer := (String new: 8) writeStream.
    hasToken := str atEnd not.
    [[str atEnd or: [str peek isSeparator]]
    	whileFalse: [buffer nextPut: str next].
    hasToken ifTrue: [list add: buffer contents. buffer reset].
    str atEnd]
    		whileFalse:
    			[hasToken := true.
    			str skipSeparators].
    ^list!

validateDefinition: anAttributeDefinition for: aParser
    anAttributeDefinition hasDefault
    	ifTrue: [self validateValueOf: anAttributeDefinition for: aParser]!

validateValueOf: anAttribute for: aParser
    "We're going to do this the hard way for now. Most of this has been
    done already, except for compressing multiple space characters that
    were character references."

    | v v1 |
    v := anAttribute value.
    [v1 := v copyReplaceAll: '  ' with: ' '.
    v1 = v] whileFalse: [v := v1].
    (v size > 1 and: [v first = Character space])
    	ifTrue: [v := v copyFrom: 2 to: v size].
    (v size > 1 and: [v last = Character space])
    	ifTrue: [v := v copyFrom: 1 to: v size - 1].
    anAttribute value: v! !

!AttributeType methodsFor: 'testing'!

isExternal
    ^isExternal!

isID
    ^false! !

!AttributeType methodsFor: 'accessing'!

isExternal: aBoolean
    isExternal := aBoolean! !

!NOTATION_AT methodsFor: 'accessing'!

typeNames
    ^typeNames!

typeNames: aList
    typeNames := aList! !

!NOTATION_AT methodsFor: 'validating'!

completeValidationAgainst: aParser from: anAttributeDef
    typeNames do: [:nm |
    	aParser dtd notationAt: nm ifAbsent:
    		[aParser invalid: ('Undeclared Notation "%1" used by attribute type "%2"'
    						bindWith: nm
    						with: anAttributeDef tag asString)]]!

validateValueOf: anAttribute for: aParser
    | v |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (typeNames includes: v)
    	ifFalse: [aParser invalid: ('A NOTATION attribute (%1="%2") should have had a value from %3.'
    				bindWith: anAttribute tag asString
    				with: v
    				with: typeNames asArray)].! !

!NOTATION_AT class methodsFor: 'instance creation'!

typeNames: list
    ^self new typeNames: list! !

!NMTOKEN_AT methodsFor: 'validating'!

validateValueOf: anAttribute for: aParser
    | v |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (v includes: Character space)
    	ifTrue: [aParser invalid: 'white space must not occur in NMTOKEN attributes'].
    (aParser isValidNmToken: v)
    	ifFalse: [aParser invalid: ('An NMTOKEN attribute (%1="%2") does not match the required syntax of an NmToken.'
    				bindWith: anAttribute tag asString
    				with: v)]! !

!IDREF_AT methodsFor: 'validating'!

validateValueOf: anAttribute for: aParser
    | v |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (v includes: Character space)
    	ifTrue: [aParser invalid: 'white space must not occur in IDREF attributes'].
    (aParser isValidName: v)
    	ifFalse: [aParser invalid: ('An IDREF attribute (%1="%2") does not match the required syntax of a Name.'
    				bindWith: anAttribute tag asString
    				with: v)].
    aParser rememberIDREF: v! !

!NMTOKENS_AT methodsFor: 'validating'!

validateValueOf: anAttribute for: aParser
    | v all |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (all := self stringAsTokens: v) do: [:nm |
    	(aParser isValidNmToken: nm)
    		ifFalse: [aParser invalid: ('An NMTOKENS attribute (%1="%2") does not match the required syntax of a list of NmTokens.'
    				bindWith: anAttribute tag asString
    				with: v)]].
    all size = 0 ifTrue: [aParser invalid: 'Attribute has empty list of NMTOKENS'].! !

!ENTITY_AT methodsFor: 'validating'!

completeValidationAgainst: aParser from: anAttributeDef
    ^anAttributeDef hasDefault
    	ifTrue: [self validateValueOf: anAttributeDef for: aParser]!

validateDefinition: anAttributeDefinition for: aParser
    ^self!

validateValueOf: anAttribute for: aParser
    | v ent |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (v includes: Character space)
    	ifTrue: [aParser invalid: 'white space must not occur in ENTITY attributes'].
    (aParser isValidName: v)
    	ifFalse: [aParser invalid: ('An ENTITY attribute (%1="%2") does not match the required syntax of a Name.'
    				bindWith: anAttribute tag asString
    				with: v)].
    ent := aParser dtd generalEntityAt: v.
    ent == nil
    	ifTrue: [aParser invalid: ('Undeclared unparsed entity "%1" used by attribute type "%2"'
    					bindWith: v
    					with: anAttribute tag asString)]
    	ifFalse: [ent isParsed
    		ifTrue: [aParser invalid: ('The entity "%1" used by attribute type "%2" is a parsed entity and should be unparsed'
    						bindWith: v
    						with: anAttribute tag asString)]
    		ifFalse: []]! !

!CDATA_AT methodsFor: 'validating'!

validateValueOf: anAttribute for: aParser
    ^self! !

!ID_AT methodsFor: 'validating'!

validateDefinition: anAttributeDefinition for: aParser
    anAttributeDefinition hasDefault
    	ifTrue: [aParser invalid: 'ID attributes must be either #REQUIRED or #IMPLIED']!

validateValueOf: anAttribute for: aParser
    | v |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (v includes: Character space)
    	ifTrue: [aParser invalid: 'white space must not occur in ID attributes'].
    (aParser isValidName: v)
    	ifFalse: [aParser invalid: ('An ID attribute (%1="%2") does not match the required syntax of a Name.'
    				bindWith: anAttribute tag asString
    				with: v)].
    aParser registerID: anAttribute! !

!ID_AT methodsFor: 'testing'!

isID
    ^true! !

!Enumeration_AT methodsFor: 'accessing'!

values
    ^values!

values: aList
    values := aList! !

!Enumeration_AT methodsFor: 'validating'!

validateValueOf: anAttribute for: aParser
    | v |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (values includes: v)
    	ifFalse: [aParser invalid: ('An attribute (%1="%2") should have had a value from %3.'
    				bindWith: anAttribute tag asString
    				with: v
    				with: values asArray)]! !

!Enumeration_AT class methodsFor: 'instance creation'!

withAll: list
    ^self new values: list! !

!IDREFS_AT methodsFor: 'validating'!

validateValueOf: anAttribute for: aParser
    | v all |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (all := self stringAsTokens: v) do: [:nm |
    	(aParser isValidName: nm)
    		ifFalse: [aParser invalid: ('An IDREFS attribute (%1="%2") does not match the required syntax of a list of Names.'
    				bindWith: anAttribute tag asString
    				with: v)].
    	aParser rememberIDREF: nm].
    all size = 0 ifTrue: [aParser invalid: 'Attribute has empty list of IDREFS'].! !

!ENTITIES_AT methodsFor: 'validating'!

completeValidationAgainst: aParser from: anAttributeDef
    ^anAttributeDef hasDefault
    	ifTrue: [self validateValueOf: anAttributeDef for: aParser]!

validateDefinition: anAttributeDefinition for: aParser
    ^self!

validateValueOf: anAttribute for: aParser
    | v ent all |
    super validateValueOf: anAttribute for: aParser.
    v := anAttribute value.
    (all := self stringAsTokens: v) do: [:nm |
    	(aParser isValidName: nm)
    		ifFalse: [aParser invalid: ('An ENTITIES attribute (%1="%2") does not match the required syntax of a list of Names.'
    				bindWith: anAttribute tag asString
    				with: v)].
    	ent := aParser dtd generalEntityAt: nm.
    	ent == nil
    		ifTrue: [aParser invalid: ('Undeclared unparsed entity "%1" used by attribute type "%2"'
    					bindWith: nm
    					with: anAttribute tag asString)]
    		ifFalse: [ent isParsed
    			ifTrue: [aParser invalid: ('The entity "%1" used by attribute type "%2" is a parsed entity and should be unparsed'
    						bindWith: nm
    						with: anAttribute tag asString)]
    			ifFalse: []]].
    all size = 0 ifTrue: [aParser invalid: 'Attribute has empty list of ENTITIES'].! !

!AnyPattern methodsFor: 'accessing'!

description
    ^'ANY'! !

!AnyPattern methodsFor: 'coercing'!

alternateHeads
    ^followSet copyWith: self!

pushDownFollowSet
    self addFollow: self.
    ^nil! !

!AnyPattern methodsFor: 'testing'!

couldBeText
    ^true!

matchesTag: aNodeTag
    ^true! !

!CharacterTable methodsFor: 'accessing'!

at: index
    "Answer the value of an indexable field in the receiver.  Fail if the
     argument index is not an Integer or is <= 1."

    ^(index > self size and: [ index isInteger ])
    	ifTrue: [(index between: self size + 1 and: 16r110000) ifTrue: [1] ifFalse: [0]]
    	ifFalse: [super at: index]! !

!NodeBuilder methodsFor: 'building'!

tag: tag attributes: attributes elements: elements position: p stream: stream
    ^Element tag: tag attributes: attributes elements: elements! !

!ElementContext methodsFor: 'accessing'!

followSetDescription
    | types |
    types := IdentitySet new.
    self types do: [:tp |
    	types addAll: tp followSet].
    ^types asArray printString!

namespaces
    namespaces == nil ifTrue: [namespaces := Dictionary new].
    ^namespaces!

tag
    ^tag!

tag: aTag
    tag := aTag isString
    		ifTrue: [NodeTag new qualifier: '' ns: '' type: aTag]
    		ifFalse: [aTag].!

type
    ^self shouldNotImplement!

type: anElementType
    type := Array with: anElementType.
    isExternal := anElementType isExternal!

types
    ^type!

types: anArray
    type := anArray! !

!ElementContext methodsFor: 'namespaces'!

defineDefaultNamespace: attribute
    self namespaces at: '' put: attribute value!

defineNamespace: attribute from: aParser
    (#('xmlns' 'xml') includes: attribute tag type)
    	ifTrue: [self error: ('It is illegal to redefine the qualifier "%1".' bindWith: attribute tag type)].
    attribute value isEmpty ifTrue: [aParser invalid: 'It is not permitted to have an empty URI as a namespace name'].
    self namespaces at: attribute tag type put: attribute value!

findNamespace: ns
    ^namespaces isNil
    	ifTrue: [nil]
    	ifFalse: [namespaces at: ns ifAbsent: [nil]]! !

!ElementContext methodsFor: 'testing'!

canTerminate
    self types do: [:i |
    	i canTerminate ifTrue: [^true]].
    ^false!

definesNamespaces
    ^namespaces notNil and: [namespaces isEmpty not]!

isDefinedExternal
    ^isExternal!

validateTag: nm
    | types |
    types := IdentitySet new.
    self types do: [:i || t |
    	t := i validateTag: nm.
    	t == nil ifFalse: [types addAll: t]].
    ^types isEmpty
    	ifTrue: [nil]
    	ifFalse: [types asArray]!

validateText: data from: start to: stop testBlanks: testBlanks
    | types |
    types := IdentitySet new.
    self types do: [:i || t |
    	t := i validateText: data from: start to: stop testBlanks: testBlanks.
    	t == nil ifFalse: [types add: t]].
    ^types isEmpty
    	ifTrue: [nil]
    	ifFalse: [types asArray]! !

!SAXElementContext methodsFor: 'accessing'!

attributes
    ^attributes!

attributes: aCollection
    attributes := aCollection!

id
    ^id!

id: anID
    id := anID!

namespaces: aDictionary
    namespaces := aDictionary!

nodes
    ^nodes!

nodes: aCollection
    nodes := aCollection!

startPosition
    ^startPosition!

startPosition: anInteger
    ^startPosition := anInteger!

stream
    ^stream!

stream: aStream
    ^stream := aStream! !

!InputSource class methodsFor: 'private'!

for: uri
    | stream |
    stream := NetClients.URIResolver openStreamOn: uri.

    ^self
	uri: (uri isString ifTrue: [ NetClients.URL fromString: uri ] ifFalse: [ uri ])
	encoding: nil
	stream: stream!

!InputSource methodsFor: 'initialize'!

uri: aURI encoding: anEncodingName stream: aStream
    uri := aURI.
    encoding := anEncodingName.
    stream := aStream! !

!InputSource methodsFor: 'accessing'!

encoding
    ^encoding!

stream
    ^stream!

uri
    ^uri! !

!InputSource class methodsFor: 'instance creation'!

uri: aURI encoding: anEncodingName stream: aStream
    ^self new uri: aURI encoding: anEncodingName stream: aStream! !

!SAXWriter methodsFor: 'content handler'!

characters: aString from: start to: stop
    | ch mapped |
    self closeOpenTag.
    normalizeText
    	ifTrue: [start to: stop do: [:i |
    			ch := aString at: i.
    			mapped := textMap at: ch ifAbsent: [nil].
    			mapped == nil
    				ifTrue: [output nextPut: ch]
    				ifFalse: [output nextPutAll: mapped]]]
    	ifFalse: [output next: stop + 1-start putAll: aString startingAt: start]!

comment: data from: start to: stop
    output nextPutAll: '<!--';
    	next: stop + 1-start putAll: data startingAt: start;
    	nextPutAll: '-->'!

endElement: namespaceURI localName: localName qName: name
    hasOpenTag == true
    	ifTrue: [output nextPutAll: '/>']
    	ifFalse: [output nextPutAll: '</', name, '>'].
    hasOpenTag := false.!

processingInstruction: targetString data: dataString
    output nextPutAll: '<?';
    	nextPutAll: targetString;
    	space;
    	nextPutAll: dataString;
    	nextPutAll: '?>'!

startDocument
    hasOpenTag := false!

startDocumentFragment
    "Nonstandard extension to SAX"

    hasOpenTag := false!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    | val |
    notations == nil ifFalse: [self emitDTD: name].
    self closeOpenTag.
    output nextPutAll: '<'.
    output nextPutAll: name.
    (self sort: attributes) do: [:att |
    	output space.
    	output nextPutAll: att tag asString.
    	output nextPutAll: '="'.
    	1 to: att value size do: [:i || ch mapped |
    		ch := att value at: i.
    		mapped := attrMap at: ch ifAbsent: [nil].
    		mapped == nil
    			ifTrue: [output nextPut: ch]
    			ifFalse: [output nextPutAll: mapped]].
    	output nextPutAll: '"'].
    newNamespaces == nil
    	ifFalse: [newNamespaces keys asSortedCollection do: [:key |
    			output space.
    			output nextPutAll: (key isEmpty ifTrue: ['xmlns'] ifFalse: ['xmlns:', key]).
    			output nextPutAll: '="'.
    			val := newNamespaces at: key.
    			1 to: val size do: [:i || ch mapped |
    				ch := val at: i.
    				mapped := attrMap at: ch ifAbsent: [nil].
    				mapped == nil
    					ifTrue: [output nextPut: ch]
    					ifFalse: [output nextPutAll: mapped]].
    			output nextPutAll: '"']].
    newNamespaces := nil.
    hasOpenTag := true!

startPrefixMapping: prefix uri: uri 
    newNamespaces == nil
    	ifTrue: [newNamespaces := Dictionary new].
    newNamespaces at: prefix put: uri.! !

!SAXWriter methodsFor: 'initialize'!

minimalCharacterMapping
    textMap := Dictionary new
    	at: $< put: '&lt;';
    	at: $& put: '&amp;';
    	yourself.
    attrMap := Dictionary new
    	at: $< put: '&lt;';
    	at: $& put: '&amp;';
    	at: $" put: '&quot;';
    	yourself.!

normalizeText: aBoolean
    normalizeText := aBoolean!

output: aStream
    output := aStream.
    normalizeText := true.
    notations := nil.
    textMap == nil ifTrue: [self minimalCharacterMapping].! !

!SAXWriter methodsFor: 'DTD handler'!

notationDecl: nameString publicID: publicIDString systemID: systemIDString 
    notations == nil ifTrue: [notations := OrderedCollection new].
    notations add: (Array with: nameString with: publicIDString with: systemIDString)! !

!SAXWriter methodsFor: 'private'!

closeOpenTag
    hasOpenTag == true
    	ifTrue:
    		[output nextPutAll: '>'.
    		hasOpenTag := false].!

emitDTD: name
    | list |
    output nextPutAll: '<!DOCTYPE ';
    	nextPutAll: name;
    	nextPutAll: ' [';
    	nl.
    list := notations asSortedCollection: [:a1 :a2 | a1 first < a2 first].
    list do: [:notation |
    	self emitNotation: notation.
    	output nl].
    output nextPutAll: ']>'; nl.
    notations := nil.!

emitNotation: array
    output nextPutAll: '<!NOTATION ';
    	nextPutAll: (array at: 1);
    	space;
    	nextPutAll: ((array at: 2) == nil ifTrue: ['SYSTEM'] ifFalse: ['PUBLIC']).
    (array at: 2) == nil
    	ifFalse: [output nextPutAll: ' ''';
    			nextPutAll: (array at: 2);
    			nextPutAll: ''''].
    (array at: 3) == nil
    	ifFalse: [output nextPutAll: ' ''';
    			nextPutAll: (array at: 3);
    			nextPutAll: ''''].
    output nextPutAll: '>'.!

sort: attributes
    ^attributes asSortedCollection: [:a1 :a2 | a1 tag asString < a2 tag asString]! !

!SAXCanonicalWriter methodsFor: 'content handler'!

comment: data from: start to: stop
    "Canonical XML surpresses comments"

    ^self!

startElement: namespaceURI localName: localName qName: name attributes: attributes
    super startElement: namespaceURI localName: localName qName: name attributes: attributes.
    self closeOpenTag.! !

!SAXCanonicalWriter methodsFor: 'private'!

emitNotation: array
    | sysID frag |
    sysID := array at: 3.
    sysID == nil ifTrue: [^super emitNotation: array].
    sysID size to: 2 by: -1 do: [:i |
    	frag := sysID copyFrom: i to: sysID size.
    	frag replaceAll: $: with: $/.
    	frag replaceAll: $\ with: $/.
    	([(baseURI resolvePath: frag) asString = sysID] on: Error do: [:x | x return: false])
    		ifTrue: [^super emitNotation: (array copy at: 3 put: frag; yourself)]].
    super emitNotation: array! !

!SAXCanonicalWriter methodsFor: 'initialize'!

baseURI: url
    baseURI := url!

minimalCharacterMapping
    textMap := Dictionary new
    	at: $< put: '&lt;';
    	at: $> put: '&gt;';
    	at: $" put: '&quot;';
    	at: $& put: '&amp;';
    	at: (Character value: 9) put: '&#9;';
    	at: (Character value: 10) put: '&#10;';
    	at: (Character value: 13) put: '&#13;';
    	yourself.
    attrMap := Dictionary new
    	at: $< put: '&lt;';
    	at: $> put: '&gt;';
    	at: $& put: '&amp;';
    	at: $" put: '&quot;';
    	at: (Character value: 9) put: '&#9;';
    	at: (Character value: 10) put: '&#10;';
    	at: (Character value: 13) put: '&#13;';
    	yourself.! !

XML at: #CharacterClasses put: XML.XMLParser characterTable!

XML at: #PredefinedEntities put: (Dictionary new
    at: 'amp' put: (GeneralEntity new name: 'amp'; text: '&#38;');
    at: 'lt' put: (GeneralEntity new name: 'lt'; text: '&#60;');
    at: 'gt' put: (GeneralEntity new name: 'gt'; text: (String with: $>));
    at: 'apos' put: (GeneralEntity new name: 'apos'; text: (String with: $'));
    at: 'quot' put: (GeneralEntity new name: 'quot'; text: (String with: $"));
    yourself)!

XML at: #XML_URI put: 'http://www.w3.org/XML/1998/namespace'!

XML.SAX
    at: #SAXExternalParameterEntities
    put: 'http://xml.org/sax/features/external-parameter-entities';

    at: #SAXValidate
    put: 'http://xml.org/sax/features/validation';

    at: #SAXNamespacePrefixes
    put: 'http://xml.org/sax/features/namespace-prefixes';

    at: #SAXNamespace
    put: 'http://xml.org/sax/features/namespaces';

    at: #XMLSignal
    put: XML.SAXException;

    at: #SAXExternalGeneralEntities
    put: 'http://xml.org/sax/features/external-general-entities'!

Namespace current: Smalltalk!
