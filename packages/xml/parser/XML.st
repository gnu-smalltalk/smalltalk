"======================================================================
|
|   VisualWorks XML Framework - DTD model and validating XML parser
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



Object subclass: Pattern [
    | followSet |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
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
    followSet	<OrderedCollection>  A list of the Patterns which may follow this one in an element''s content.'>

    Pattern class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    followSet: aCollection [
	<category: 'initialize'>
	followSet := aCollection
    ]

    initialize [
	<category: 'initialize'>
	followSet := OrderedCollection new: 2
    ]

    addFollow: aNode [
	<category: 'coercing'>
	followSet add: aNode
    ]

    addFollows: aList [
	<category: 'coercing'>
	followSet addAll: aList
    ]

    alternateHeads [
	<category: 'coercing'>
	^self subclassResponsibility
    ]

    followSet [
	<category: 'coercing'>
	^followSet
    ]

    normalize [
	<category: 'coercing'>
	| list done t r result |
	list := OrderedCollection 
		    with: (result := InitialPattern new addFollow: self)
		    with: self
		    with: TerminalPattern new.
	self addFollow: list last.
	done := OrderedCollection new.
	[list isEmpty] whileFalse: 
		[t := list removeFirst.
		r := t pushDownFollowSet.
		r == nil ifTrue: [done add: t] ifFalse: [list addAll: r]].
	list := done.
	done := OrderedCollection new.
	[list isEmpty] whileFalse: 
		[t := list removeFirst.
		t normalizeFollowSet ifTrue: [done add: t] ifFalse: [list add: t]].
	done do: 
		[:p | 
		p isSimple ifFalse: [self error: 'Incomplete translation'].
		p followSet 
		    do: [:p1 | p1 isSimple ifFalse: [self error: 'Incomplete translation']]].
	^result
    ]

    normalizeFollowSet [
	<category: 'coercing'>
	| changed oldFollow newFollow |
	oldFollow := IdentitySet withAll: followSet.
	newFollow := IdentitySet new.
	oldFollow do: [:pat | newFollow addAll: pat alternateHeads].
	changed := newFollow size ~= oldFollow size 
		    or: [(newFollow - oldFollow) size > 0].
	followSet := newFollow asOrderedCollection.
	^changed not
    ]

    normalizeFor: aParser [
	<category: 'coercing'>
	| list done t r result |
	list := OrderedCollection 
		    with: (result := InitialPattern new addFollow: self)
		    with: self
		    with: TerminalPattern new.
	self addFollow: list last.
	done := OrderedCollection new.
	[list isEmpty] whileFalse: 
		[t := list removeFirst.
		r := t pushDownFollowSet.
		done add: t.
		r == nil ifFalse: [list addAll: r]].
	done do: 
		[:nd | 
		| replacements |
		replacements := nd alternateHeads.
		(replacements size = 1 and: [replacements first == nd]) 
		    ifFalse: [done do: [:nd2 | nd2 replaceFollowSet: nd with: replacements]]].
	done := IdentitySet new.
	list := OrderedCollection with: result.
	[list isEmpty] whileFalse: 
		[t := list removeLast.
		t isSimple ifFalse: [aParser malformed: 'Incomplete translation'].
		(self duplicatesNeedTested and: [t hasDuplicatesInFollowSet]) 
		    ifTrue: [aParser warn: 'Nondeterministic content model %1' % {self}].
		done add: t.
		t followSet do: [:t1 | (done includes: t1) ifFalse: [list add: t1]]].
	^result
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	^self subclassResponsibility
    ]

    replaceFollowSet: node with: nodes [
	<category: 'coercing'>
	(followSet includes: node) 
	    ifTrue: 
		[followSet := (IdentitySet withAll: followSet)
			    remove: node;
			    addAll: nodes;
			    asArray]
    ]

    duplicatesNeedTested [
	<category: 'testing'>
	^true
    ]

    isSimple [
	<category: 'testing'>
	^self subclassResponsibility
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	followSet := OrderedCollection new: 2
    ]
]


Pattern subclass: ConcretePattern [
    
    <category: 'XML-XML-Patterns'>
    <comment: '
A subclass of Pattern, this class is the superclass to what are
considered ''simple'' patterns or constraint rules in the element
content declarations.

Subclasses of ConcretePattern include AnyPattern, EmptyPattern,
InitialPattern, NamePattern, PCDATAPattern and TerminalPattern.

Subclasses must implement the following messages:
    testing
    	matches:'>

    followSetDescription [
	<category: 'accessing'>
	| s |
	s := (String new: 32) writeStream.
	s nextPut: $(.
	followSet do: [:n | s nextPutAll: n printString] separatedBy: [s space].
	s nextPut: $).
	^s contents
    ]

    canTerminate [
	<category: 'testing'>
	^followSet contains: [:p | p isTerminator]
    ]

    couldBeText [
	<category: 'testing'>
	^false
    ]

    hasDuplicatesInFollowSet [
	<category: 'testing'>
	1 to: followSet size
	    do: 
		[:i | 
		| p1 p2 ns tp |
		p1 := followSet at: i.
		p1 class == NamePattern 
		    ifTrue: 
			[ns := p1 name namespace.
			tp := p1 name type.
			i + 1 to: followSet size
			    do: 
				[:j | 
				p2 := followSet at: j.
				(p2 class == NamePattern 
				    and: [p2 name type = tp and: [p2 name namespace = ns]]) ifTrue: [^true]]]].
	^false
    ]

    isSimple [
	<category: 'testing'>
	^true
    ]

    isTerminator [
	<category: 'testing'>
	^false
    ]

    matchesTag: aNodeTag [
	<category: 'testing'>
	self subclassResponsibility
    ]

    alternateHeads [
	<category: 'coercing'>
	^Array with: self
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	^nil
    ]

    validateTag: elementTag [
	<category: 'validation'>
	| types |
	types := IdentitySet new.
	self followSet 
	    do: [:i | (i matchesTag: elementTag) ifTrue: [types add: i]].
	^types isEmpty ifTrue: [nil] ifFalse: [types]
    ]

    validateText: characters from: start to: stop testBlanks: testBlanks [
	<category: 'validation'>
	self followSet do: [:i | i couldBeText ifTrue: [^i]].
	testBlanks 
	    ifTrue: 
		[start to: stop do: [:i | (characters at: i) asInteger > 32 ifTrue: [^nil]].
		^self].
	^nil
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self description
    ]
]


ConcretePattern subclass: TerminalPattern [
    
    <category: 'XML-XML-Patterns'>
    <comment: '
Since an element''s content declaration may include multiple
constraint rules or patterns, instances of this class are used to
indicate to the XML parser, the last or terminal rule in the
declaration.'>

    description [
	<category: 'accessing'>
	^'</ close tag >'
    ]

    isTerminator [
	<category: 'testing'>
	^true
    ]

    matchesTag: aNodeTag [
	<category: 'testing'>
	^false
    ]
]


ConcretePattern subclass: InitialPattern [
    | isExternal |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
Since an element''s content declaration may include multiple
constraint rules or patterns, instances of this class are used to
indicate to the XML parser, the initial or first rule in the
declaration.'>

    description [
	<category: 'accessing'>
	^(followSet asArray collect: [:i | i description]) printString
    ]

    isExternal [
	<category: 'accessing'>
	^isExternal
    ]

    isExternal: flag [
	<category: 'accessing'>
	isExternal := flag
    ]
]


ConcretePattern subclass: EmptyPattern [
    
    <category: 'XML-XML-Patterns'>
    <comment: '
A subclass of ConcretePattern, this class represents the EMPTY element
content constraint in an element type declaration.

According to the XML 1.0 specification the EMPTY element declaration
indicates that the element has no content.'>

    alternateHeads [
	<category: 'coercing'>
	^followSet
    ]

    matchesTag: aNodeTag [
	<category: 'testing'>
	^false
    ]

    description [
	<category: 'accessing'>
	^'EMPTY'
    ]
]


ConcretePattern subclass: NamePattern [
    | name |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
This class represents a content constraint in an element type
declaration such that the declaration includes the names of the
element types that may appear as children in the element''s content.

Instance Variables:
    name	<XML.NodeTag>		The tag of the element which is permitted by this pattern to appear in the content of some other element.'>

    NamePattern class >> named: aName [
	<category: 'instance creation'>
	^self new named: aName
    ]

    named: aName [
	<category: 'initialize'>
	name := aName
    ]

    description [
	<category: 'accessing'>
	^'<%1>' % {name}
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    matchesTag: aNodeTag [
	<category: 'testing'>
	^name isLike: aNodeTag
    ]
]


ConcretePattern subclass: PCDATAPattern [
    
    <category: 'XML-XML-Patterns'>
    <comment: '
This class represents a content constraint or pattern in an element
type declaration indicating that the element content includes parsed
character data.

Parsed character data is typically used in mixed content type patterns
and is signified by the presence of the string ''#PCDATA'' in the
element content declaration.'>

    description [
	<category: 'accessing'>
	^'#PCDATA'
    ]

    couldBeText [
	<category: 'testing'>
	^true
    ]

    matchesTag: aNodeTag [
	<category: 'testing'>
	^false
    ]
]


Pattern subclass: ComplexPattern [
    
    <category: 'XML-XML-Patterns'>
    <comment: '
A subclass of Pattern, this class is the superclass to what are
considered ''complex'' patterns or rules in the element content
declarations.

Subclasses of ComplexPattern include ChoicePattern, MixedPattern,
ModifiedPattern and SequencePattern.'>

    isSimple [
	<category: 'testing'>
	^false
    ]
]


ComplexPattern subclass: MixedPattern [
    | items |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
A subclass of ComplexPattern, this class represents the ''mixed''
element content constraint in an element type declaration.

An element type has mixed content when elements of that type may
contain both other child elements and character data (text) as
specified in the element content declaration.

Note: For mixed content type elements, one can''t control the order in
which the child elements, mixed in among the text, appear.

Instance Variables:
    items	<SequenceableCollection>  A list of NamedPatterns (as well as one PCDATAPattern) which can appear as content in the context controlled by the MixedPattern.'>

    MixedPattern class >> on: aList [
	<category: 'instance creation'>
	^self new on: (aList size = 0 ifTrue: [#()] ifFalse: [aList])
    ]

    on: aList [
	<category: 'initialize'>
	items := (Array with: PCDATAPattern new) , aList
    ]

    alternateHeads [
	<category: 'coercing'>
	^items , followSet
    ]

    normalizeFor: aParser [
	"Optimized because lots of the testing needed in
	 the superclass is not needed here."

	<category: 'coercing'>
	| result |
	followSet := OrderedCollection withAll: items.
	followSet add: TerminalPattern new.
	result := InitialPattern new.
	result followSet: followSet.
	items do: [:i | i followSet: followSet].
	^result
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	items do: 
		[:i | 
		i
		    addFollow: self;
		    addFollows: followSet].
	^items
    ]

    duplicatesNeedTested [
	<category: 'testing'>
	^false
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	items := items collect: [:i | i copy]
    ]
]


ComplexPattern subclass: ChoicePattern [
    | items |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
A subclass of ComplexPattern, this class represents the ''choice''
element content constraint in an element type declaration.

According to the XML 1.0 specification, the ''choice'' pattern/rule
signifies that any content particle in a choice list (declared in the
DTD) may appear in the element content at the location where the
choice list appears in the grammar.

Instance Variables:
    items	<Collection>
    			Collection of content particles'>

    ChoicePattern class >> on: aList [
	<category: 'instance creation'>
	^self new on: aList
    ]

    on: aList [
	<category: 'initialize'>
	items := aList
    ]

    alternateHeads [
	<category: 'coercing'>
	^items
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	items do: [:i | i addFollows: followSet].
	^items
    ]

    description [
	<category: 'printing'>
	| str |
	str := String new writeStream.
	str nextPutAll: '('.
	items do: [:ch | str nextPutAll: ch description]
	    separatedBy: [str nextPutAll: ' | '].
	str nextPutAll: ')'.
	^str contents
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self description
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	items := items collect: [:i | i copy]
    ]
]


ComplexPattern subclass: ModifiedPattern [
    | node modification |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
XML element content declarations can have certain optional characters
following an element name or pattern. These characters govern whether
the element or the content particle may occur one or more (+), zero or
more (*), or zero or one (?) times in the element content. This class
represents these patterns or rules.

Instance Variables:
    node			<XML.Pattern>		The base pattern which the ModifiedPattern influences.
    modification	<Character>		Optional character denoting content element occurances'>

    ModifiedPattern class >> on: aNode type: t [
	<category: 'instance creation'>
	^self new on: aNode type: t
    ]

    on: aNode type: t [
	<category: 'initialize'>
	node := aNode.
	modification := t
    ]

    alternateHeads [
	<category: 'coercing'>
	^(modification = $* or: [modification = $?]) 
	    ifTrue: [(followSet copyWith: node) replaceAll: self with: node]
	    ifFalse: [Array with: node]
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	(modification = $+ or: [modification = $*]) ifTrue: [node addFollow: self].
	node addFollows: followSet.
	^Array with: node
    ]

    description [
	<category: 'printing'>
	^node description copyWith: modification
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self description
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	node := node copy
    ]
]


Object subclass: AttributeDef [
    | name default type flags |
    
    <category: 'XML-XML-Attributes'>
    <comment: '
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
    flags	<Integer>				encoding for fixed, implied and required type attributes'>

    default [
	<category: 'accessing'>
	^default
    ]

    default: n [
	<category: 'accessing'>
	flags := 0.
	default := nil.
	n = #required 
	    ifTrue: [flags := 1]
	    ifFalse: 
		[n = #implied 
		    ifTrue: [flags := 2]
		    ifFalse: 
			[n class == Association ifFalse: [self error: 'Invalid default'].
			n key ifTrue: [flags := 4].
			default := n value]]
    ]

    hasDefault [
	<category: 'accessing'>
	^(self isImplied or: [self isRequired]) not
    ]

    isFixed [
	<category: 'accessing'>
	^(flags bitAnd: 4) = 4
    ]

    isImplied [
	<category: 'accessing'>
	^(flags bitAnd: 2) = 2
    ]

    isRequired [
	<category: 'accessing'>
	^(flags bitAnd: 1) = 1
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: n [
	<category: 'accessing'>
	name := n
    ]

    tag [
	<category: 'accessing'>
	^name
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    type: n [
	<category: 'accessing'>
	type := n
    ]

    completeValidationAgainst: aParser [
	<category: 'validating'>
	^self type completeValidationAgainst: aParser from: self
    ]

    selfValidateFor: aParser [
	<category: 'validating'>
	type validateDefinition: self for: aParser
    ]

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	type validateValueOf: anAttribute for: aParser.
	(self isFixed not or: [anAttribute value = self default]) 
	    ifFalse: 
		[aParser 
		    invalid: 'The attribute "%1" was declared FIXED, but the value used in the document ("%2") did not match the default ("%3")' 
			    % 
				{anAttribute tag asString.
				anAttribute value.
				self default}]
    ]

    value [
	<category: 'private'>
	^self default
    ]

    value: str [
	<category: 'private'>
	default := str
    ]
]


ComplexPattern subclass: SequencePattern [
    | items |
    
    <category: 'XML-XML-Patterns'>
    <comment: '
This class represents the ''sequence'' element content constraint in
an element type declaration.

According to the XML 1.0 specification, the ''sequence'' pattern/rule
signifies that content particles occuring in a sequence list (declared
in the DTD) must each appear in the element content in the order given
in the list.

Instance Variables:
    items	<SequenceableCollection>		Collection of content particles'>

    SequencePattern class >> on: aList [
	<category: 'instance creation'>
	^self new on: aList
    ]

    on: aList [
	<category: 'initialize'>
	items := aList
    ]

    alternateHeads [
	<category: 'coercing'>
	^Array with: items first
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	1 to: items size - 1 do: [:i | (items at: i) addFollow: (items at: i + 1)].
	items last addFollows: followSet.
	^items
    ]

    description [
	<category: 'printing'>
	| str |
	str := String new writeStream.
	str nextPutAll: '('.
	items do: [:ch | str nextPutAll: ch description]
	    separatedBy: [str nextPutAll: ' , '].
	str nextPutAll: ')'.
	^str contents
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self description
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	items := items collect: [:i | i copy]
    ]
]


Object subclass: AttributeType [
    | isExternal |
    
    <category: 'XML-XML-Attributes'>
    <comment: '
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
types.'>

    completeValidationAgainst: aParser from: anAttributeDef [
	<category: 'validating'>
	^self
    ]

    simpleValidateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v |
	v := anAttribute value copy.
	v replaceAll: Character cr with: Character space.
	v replaceAll: Character nl with: Character space.
	v replaceAll: Character tab with: Character space.
	anAttribute value: v
    ]

    stringAsTokens: aString [
	<category: 'validating'>
	| list str buffer hasToken |
	list := OrderedCollection new.
	str := aString readStream.
	buffer := (String new: 8) writeStream.
	hasToken := str atEnd not.
	
	[[str atEnd or: [str peek isSeparator]] 
	    whileFalse: [buffer nextPut: str next].
	hasToken 
	    ifTrue: 
		[list add: buffer contents.
		buffer reset].
	str atEnd] 
		whileFalse: 
		    [hasToken := true.
		    str skipSeparators].
	^list
    ]

    validateDefinition: anAttributeDefinition for: aParser [
	<category: 'validating'>
	anAttributeDefinition hasDefault 
	    ifTrue: [self validateValueOf: anAttributeDefinition for: aParser]
    ]

    validateValueOf: anAttribute for: aParser [
	"We're going to do this the hard way for now. Most of this has been
	 done already, except for compressing multiple space characters that
	 were character references."

	<category: 'validating'>
	| v v1 |
	v := anAttribute value.
	
	[v1 := v copyReplaceAll: '  ' with: ' '.
	v1 = v] whileFalse: [v := v1].
	(v size > 1 and: [v first = Character space]) 
	    ifTrue: [v := v copyFrom: 2 to: v size].
	(v size > 1 and: [v last = Character space]) 
	    ifTrue: [v := v copyFrom: 1 to: v size - 1].
	anAttribute value: v
    ]

    isExternal [
	<category: 'testing'>
	^isExternal
    ]

    isID [
	<category: 'testing'>
	^false
    ]

    isExternal: aBoolean [
	<category: 'accessing'>
	isExternal := aBoolean
    ]
]


AttributeType subclass: NOTATION_AT [
    | typeNames |
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the
NOTATION attribute type.

A NOTATION attribute identifies a notation element, declared in the
DTD with associated system and/or public identifiers, to be used in
interpreting the element to which the attribute is attached.

Instance Variables:
    typeNames	<SequenceableCollection>	A list of the legal notation names that may be used for this attribute type.'>

    NOTATION_AT class >> typeNames: list [
	<category: 'instance creation'>
	^self new typeNames: list
    ]

    typeNames [
	<category: 'accessing'>
	^typeNames
    ]

    typeNames: aList [
	<category: 'accessing'>
	typeNames := aList
    ]

    completeValidationAgainst: aParser from: anAttributeDef [
	<category: 'validating'>
	typeNames do: 
		[:nm | 
		aParser dtd notationAt: nm
		    ifAbsent: 
			[aParser 
			    invalid: 'Undeclared Notation "%1" used by attribute type "%2"' % 
					{nm.
					anAttributeDef tag asString}]]
    ]

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(typeNames includes: v) 
	    ifFalse: 
		[aParser 
		    invalid: 'A NOTATION attribute (%1="%2") should have had a value from %3.' 
			    % 
				{anAttribute tag asString v.
				typeNames asArray}]
    ]
]


AttributeType subclass: NMTOKEN_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the
NMTOKEN attribute type.

This is a tokenized type of attribute and for the purposes of
validation, values of NMTOKEN type attributes must match a Nmtoken,
which is any mixture of legal name characters as defined in the XML
1.0 specification.'>

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(v includes: Character space) 
	    ifTrue: [aParser invalid: 'white space must not occur in NMTOKEN attributes'].
	(aParser isValidNmToken: v) 
	    ifFalse: 
		[aParser 
		    invalid: 'An NMTOKEN attribute (%1="%2") does not match the required syntax of an NmToken.' 
			    % 
				{anAttribute tag asString.
				v}]
    ]
]


AttributeType subclass: IDREF_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the IDREF
attribute type.

This is a tokenized type of attribute and for an XML document to be
valid, values of IDREF type attributes must match the value of some ID
attribute on some element in the XML document.

ID and IDREF attributes together provide a simple inside-the-document
linking mechanism with every IDREF attribute required to point to an
ID attribute as stated above.'>

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(v includes: Character space) 
	    ifTrue: [aParser invalid: 'white space must not occur in IDREF attributes'].
	(aParser isValidName: v) 
	    ifFalse: 
		[aParser 
		    invalid: 'An IDREF attribute (%1="%2") does not match the required syntax of a Name.' 
			    % 
				{anAttribute tag asString.
				v}].
	aParser rememberIDREF: v
    ]
]


AttributeType subclass: NMTOKENS_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the
NMTOKENS attribute type.

This is a tokenized type of attribute and for the purposes of
validation, values of each NMTOKENS type attributes must match each
Nmtoken, which is any mixture of legal name characters as defined in
the XML 1.0 specification.'>

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v all |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(all := self stringAsTokens: v) do: 
		[:nm | 
		(aParser isValidNmToken: nm) 
		    ifFalse: 
			[aParser 
			    invalid: 'An NMTOKENS attribute (%1="%2") does not match the required syntax of a list of NmTokens.' 
				    % 
					{anAttribute tag asString.
					v}]].
	all size = 0 
	    ifTrue: [aParser invalid: 'Attribute has empty list of NMTOKENS']
    ]
]


AttributeType subclass: ENTITY_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the ENTITY
attribute type.

This is a tokenized type of attribute that signifies to the XML parser
that for the purposes of validating, the values of entity type
attributes must match the name of an unparsed entity declared in the
document type definition.'>

    completeValidationAgainst: aParser from: anAttributeDef [
	<category: 'validating'>
	^anAttributeDef hasDefault 
	    ifTrue: [self validateValueOf: anAttributeDef for: aParser]
    ]

    validateDefinition: anAttributeDefinition for: aParser [
	<category: 'validating'>
	^self
    ]

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v ent |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(v includes: Character space) 
	    ifTrue: [aParser invalid: 'white space must not occur in ENTITY attributes'].
	(aParser isValidName: v) 
	    ifFalse: 
		[aParser 
		    invalid: 'An ENTITY attribute (%1="%2") does not match the required syntax of a Name.' 
			    % 
				{anAttribute tag asString.
				v}].
	ent := aParser dtd generalEntityAt: v.
	ent == nil 
	    ifTrue: 
		[aParser 
		    invalid: 'Undeclared unparsed entity "%1" used by attribute type "%2"' % 
				{v.
				anAttribute tag asString}]
	    ifFalse: 
		[ent isParsed 
		    ifTrue: 
			[aParser 
			    invalid: 'The entity "%1" used by attribute type "%2" is a parsed entity and should be unparsed' 
				    % 
					{v.
					anAttribute tag asString}]
		    ifFalse: []]
    ]
]


AttributeType subclass: CDATA_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the CDATA
attribute type.

CDATA attributes are genericly typed attributes which, at the level of
interpretation done by XMLParser, have no constraints or semantics
applied to their contents.  '>

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	^self
    ]
]


AttributeType subclass: ID_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
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
ID attribute.'>

    validateDefinition: anAttributeDefinition for: aParser [
	<category: 'validating'>
	anAttributeDefinition hasDefault 
	    ifTrue: 
		[aParser invalid: 'ID attributes must be either #REQUIRED or #IMPLIED']
    ]

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(v includes: Character space) 
	    ifTrue: [aParser invalid: 'white space must not occur in ID attributes'].
	(aParser isValidName: v) 
	    ifFalse: 
		[aParser 
		    invalid: 'An ID attribute (%1="%2") does not match the required syntax of a Name.' 
			    % 
				{anAttribute tag asString.
				v}].
	aParser registerID: anAttribute
    ]

    isID [
	<category: 'testing'>
	^true
    ]
]


AttributeType subclass: Enumeration_AT [
    | values |
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the
Enumeration attribute type.

Enumerated attributes can take one of a list of values provided in the declaration.

Instance Variables:
    values	<Collection>		A list of the possible values which the attribute may have.'>

    Enumeration_AT class >> withAll: list [
	<category: 'instance creation'>
	^self new values: list
    ]

    values [
	<category: 'accessing'>
	^values
    ]

    values: aList [
	<category: 'accessing'>
	values := aList
    ]

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(values includes: v) 
	    ifFalse: 
		[aParser 
		    invalid: 'An attribute (%1="%2") should have had a value from %3.' % 
				{anAttribute tag asString.
				v values asArray}]
    ]
]


AttributeType subclass: IDREFS_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the IDREFS
attribute type.

This is a tokenized type of attribute and for an XML document to be
valid, each of the values of IDREFS type attributes must match each of
the values of some ID attribute on some element in the XML document.'>

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v all |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(all := self stringAsTokens: v) do: 
		[:nm | 
		(aParser isValidName: nm) 
		    ifFalse: 
			[aParser 
			    invalid: 'An IDREFS attribute (%1="%2") does not match the required syntax of a list of Names.' 
				    % 
					{anAttribute tag asString.
					v}].
		aParser rememberIDREF: nm].
	all size = 0 
	    ifTrue: [aParser invalid: 'Attribute has empty list of IDREFS']
    ]
]


AttributeType subclass: ENTITIES_AT [
    
    <category: 'XML-XML-Attributes'>
    <comment: '
A concrete subclass of AttributeType, this class represents the
ENTITIES attribute type.

This is a tokenized type of attribute that signifies to the XML parser
that for the purposes of validating, the values of entities type
attributes must match each of the names of unparsed entities declared
in the document type definition.'>

    completeValidationAgainst: aParser from: anAttributeDef [
	<category: 'validating'>
	^anAttributeDef hasDefault 
	    ifTrue: [self validateValueOf: anAttributeDef for: aParser]
    ]

    validateDefinition: anAttributeDefinition for: aParser [
	<category: 'validating'>
	^self
    ]

    validateValueOf: anAttribute for: aParser [
	<category: 'validating'>
	| v ent all |
	super validateValueOf: anAttribute for: aParser.
	v := anAttribute value.
	(all := self stringAsTokens: v) do: 
		[:nm | 
		(aParser isValidName: nm) 
		    ifFalse: 
			[aParser 
			    invalid: 'An ENTITIES attribute (%1="%2") does not match the required syntax of a list of Names.' 
				    % 
					{anAttribute tag asString.
					v}].
		ent := aParser dtd generalEntityAt: nm.
		ent == nil 
		    ifTrue: 
			[aParser 
			    invalid: 'Undeclared unparsed entity "%1" used by attribute type "%2"' % 
					{nm.
					anAttribute tag asString}]
		    ifFalse: 
			[ent isParsed 
			    ifTrue: 
				[aParser 
				    invalid: 'The entity "%1" used by attribute type "%2" is a parsed entity and should be unparsed' 
					    % 
						{nm.
						anAttribute tag asString}]
			    ifFalse: []]].
	all size = 0 
	    ifTrue: [aParser invalid: 'Attribute has empty list of ENTITIES']
    ]
]


ConcretePattern subclass: AnyPattern [
    
    <category: 'XML-XML-Patterns'>
    <comment: '
A subclass of ConcretePattern, this class represents the ANY element
content constraint in an element type declaration.

According to the XML 1.0 specification the ANY pattern/rule is used to
indicate to the validating parser that the element can contain any
elements in any order, as long as it doesn''t break any of the other
rules of XML and the types of any child elements have been declared.'>

    description [
	<category: 'accessing'>
	^'ANY'
    ]

    alternateHeads [
	<category: 'coercing'>
	^followSet copyWith: self
    ]

    pushDownFollowSet [
	<category: 'coercing'>
	self addFollow: self.
	^nil
    ]

    couldBeText [
	<category: 'testing'>
	^true
    ]

    matchesTag: aNodeTag [
	<category: 'testing'>
	^true
    ]
]


Link subclass: StreamWrapper [
    | stream isInternal resource usedAsExternal entity cr lf parser line column |
    
    <category: 'XML-XML-Parsing'>
    <comment: '
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
    column		<Integer> column number on the current line'>

    StreamWrapper class >> emptyWithExtraSpace: space from: aParser [
	<category: 'instance creation'>
	| txt |
	txt := space ifTrue: ['  '] ifFalse: [''].
	^self 
	    resource: (InputSource 
		    uri: nil
		    encoding: nil
		    stream: txt readStream)
	    entity: nil
	    from: aParser
    ]

    StreamWrapper class >> resource: anInputSource entity: entity from: aParser [
	<category: 'instance creation'>
	^self new 
	    resource: anInputSource
	    entity: entity
	    from: aParser
    ]

    isInternal: aBoolean [
	<category: 'initialize'>
	isInternal := aBoolean
    ]

    resource: anInputSource entity: ent from: aParser [
	<category: 'initialize'>
	resource := anInputSource.
	stream := resource stream.
	isInternal := resource uri == nil.
	entity := ent.
	cr := Character cr.
	lf := Character lf.
	parser := aParser.
	line := 1.
	column := 0
    ]

    usedAsExternal [
	<category: 'initialize'>
	^usedAsExternal
    ]

    usedAsExternal: aBoolean [
	<category: 'initialize'>
	usedAsExternal := aBoolean
    ]

    characterSize: aCharacter [
	<category: 'accessing'>
	^1	"(self stream respondsTo: #encoder)
	 ifTrue: [self stream encoder characterSize: aCharacter]
	 ifFalse: [1]"
    ]

    checkEncoding [
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
	 ifFalse: [stream position: pos]]"

	<category: 'accessing'>
	
    ]

    close [
	<category: 'accessing'>
	stream close
    ]

    column [
	<category: 'accessing'>
	^column
    ]

    column: n [
	<category: 'accessing'>
	column := n
    ]

    contents [
	<category: 'accessing'>
	| s |
	s := (String new: 100) writeStream.
	[self atEnd] whileFalse: [s nextPut: self next].
	^s contents
    ]

    entity [
	<category: 'accessing'>
	^entity
    ]

    line [
	<category: 'accessing'>
	^line
    ]

    line: n [
	<category: 'accessing'>
	line := n
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    uri [
	<category: 'accessing'>
	^resource uri
    ]

    next [
	<category: 'streaming'>
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
		    ifFalse: 
			[ch == lf 
			    ifTrue: 
				[ch := parser eol.
				line := line + 1.
				column := 0]]].
	"Originally we tested ch to make sure it was less than 16r110000,
	 but now CharacterClasses' implementation of #at: answers 0 for
	 large values of ch. If primitive failure code can not be trusted to do
	 this, then the bounds check would have to be added back."
	(ch isNil or: [(CharacterClasses at: ch asInteger + 1) > 0]) 
	    ifFalse: 
		[parser errorHandler fatalError: (BadCharacterSignal new 
			    messageText: 'A character with Unicode value %1 is not legal' 
				    % {ch asInteger})].
	^ch
    ]

    skip: n [
	<category: 'streaming'>
	stream skip: n.
	column := column - 1
    ]

    atEnd [
	<category: 'testing'>
	^stream atEnd
    ]

    isInternal [
	<category: 'testing'>
	^isInternal
    ]

    encodingDecl [
	<category: 'declaration'>
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
		    and: [stream encoding asLowercase ~= encoding asLowercase]) ifTrue: [].
		true]
	    ifFalse: [false]
    ]

    mustFind: str [
	<category: 'declaration'>
	(self skipIf: str) ifFalse: [parser expected: str]
    ]

    quotedString [
	<category: 'declaration'>
	(stream peekFor: $") ifTrue: [^(stream upTo: $") asString].
	(stream peekFor: $') ifTrue: [^(stream upTo: $') asString].
	parser malformed: 'Quoted string expected but not found'
    ]

    sdDecl [
	<category: 'declaration'>
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
	    ifFalse: [false]
    ]

    skipIf: str [
	<category: 'declaration'>
	| p |
	p := stream position.
	1 to: str size
	    do: 
		[:i | 
		(stream peekFor: (str at: i)) 
		    ifFalse: 
			[stream position: p.
			^false]].
	column := column + str size.
	^true
    ]

    skipSpace [
	<category: 'declaration'>
	| space |
	space := false.
	[#(9 10 13 32) includes: self next asInteger] whileTrue: [space := true].
	self skip: -1.
	^space
    ]

    textDecl [
	<category: 'declaration'>
	self checkEncoding.
	^(self skipIf: '<?xml') 
	    ifTrue: 
		[| hasSpace |
		hasSpace := self skipSpace.
		hasSpace 
		    ifTrue: [self versionInfo == nil ifFalse: [hasSpace := self skipSpace]].
		hasSpace 
		    ifTrue: [self encodingDecl ifFalse: [parser expected: 'encoding']]
		    ifFalse: 
			[self encodingDecl 
			    ifTrue: [parser expectedWhitespace]
			    ifFalse: [parser expected: 'encoding']].
		self skipSpace.
		self mustFind: '?>'.
		true]
	    ifFalse: [false]
    ]

    versionInfo [
	<category: 'declaration'>
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
	    ifFalse: [nil]
    ]

    xmlDecl [
	<category: 'declaration'>
	self checkEncoding.
	^(self skipIf: '<?xml') 
	    ifTrue: 
		[| hasSpace version |
		self skipSpace 
		    ifTrue: [version := self versionInfo]
		    ifFalse: [version := nil].
		version = nil ifTrue: [parser expected: 'version'].
		parser xmlVersion: version.
		hasSpace := self skipSpace.
		hasSpace 
		    ifTrue: [self encodingDecl ifTrue: [hasSpace := self skipSpace]]
		    ifFalse: [self encodingDecl ifTrue: [parser expectedWhitespace]].
		hasSpace 
		    ifTrue: [self sdDecl ifTrue: [hasSpace := self skipSpace]]
		    ifFalse: [self sdDecl ifTrue: [parser expectedWhitespace]].
		self mustFind: '?>'.
		true]
	    ifFalse: [false]
    ]
]


LargeByteArray subclass: CharacterTable [
    
    <category: 'XML-XML-Nodes'>
    <comment: '
Class CharacterTable is an optimization of its superclass
(LargeByteArray) that allows a smallish character table to masquerade
as a large table.

When the #at: primitive fails, the failure code checks to see if the
index exceeded the size of the collection. If so, it answers the
collection''s default value, which means that characters whose Unicode
values exceed a particular value will all be classified the same.'>

    at: index [
	"Answer the value of an indexable field in the receiver.  Fail if the
	 argument index is not an Integer or is <= 1."

	<category: 'accessing'>
	^(index > self size and: [index isInteger]) 
	    ifTrue: [(index between: self size + 1 and: 1114112) ifTrue: [1] ifFalse: [0]]
	    ifFalse: [super at: index]
    ]
]


SAXParser subclass: XMLParser [
    | sourceStack dtd hereChar lastSource currentSource unresolvedIDREFs definedIDs latestID elementStack eol buffer nameBuffer |
    
    <category: 'XML-XML-Parsing'>
    <comment: '
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
    dtd                         <XML.DocumentType>      the document type definition for the current document
    hereChar		<Character>  				the current character being parsed
    lastSource		<XML.StreamWrapper>	record of previous source used to check correct nesting
    currentSource	<XML.StreamWrapper>	current input stream (the top of sourceStack)
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
    nameBuffer	<WriteStream>				alternate buffer when "buffer" may be in use'>

    XMLParser class >> characterTable [
	<category: 'class initialization'>
	| ch sets pc nameChars nameStartChars |
	ch := CharacterTable new: 65536.
	nameChars := self nameChars.
	nameStartChars := self nameStartChars.
	sets := Array with: (32 to: 55295) with: (57344 to: 65533).
	pc := XMLParser.
	sets do: 
		[:s | 
		| startS endS |
		startS := s first.
		endS := s last.
		startS to: endS
		    do: 
			[:i | 
			ch at: i + 1
			    put: ((nameStartChars includes: i) 
				    ifTrue: [7]
				    ifFalse: [(nameChars includes: i) ifTrue: [3] ifFalse: [1]])]].
	ch at: 9 + 1 put: 1.
	ch at: 10 + 1 put: 1.
	ch at: 13 + 1 put: 1.
	ch at: $_ asInteger + 1 put: 7.
	ch at: $- asInteger + 1 put: 3.
	ch at: $. asInteger + 1 put: 3.
	^ch
	    compress;
	    yourself
    ]

    XMLParser class >> nameChars [
	<category: 'class initialization'>
	^(Set new: 1024)
	    addAll: (768 to: 837);
	    addAll: (864 to: 865);
	    addAll: (1155 to: 1158);
	    addAll: (1425 to: 1441);
	    addAll: (1443 to: 1465);
	    addAll: (1467 to: 1469);
	    add: 1471;
	    addAll: (1473 to: 1474);
	    add: 1476;
	    addAll: (1611 to: 1618);
	    add: 1648;
	    addAll: (1750 to: 1756);
	    addAll: (1757 to: 1759);
	    addAll: (1760 to: 1764);
	    addAll: (1767 to: 1768);
	    addAll: (1770 to: 1773);
	    addAll: (2305 to: 2307);
	    add: 2364;
	    addAll: (2366 to: 2380);
	    add: 2381;
	    addAll: (2385 to: 2388);
	    addAll: (2402 to: 2403);
	    addAll: (2433 to: 2435);
	    add: 2492;
	    add: 2494;
	    add: 2495;
	    addAll: (2496 to: 2500);
	    addAll: (2503 to: 2504);
	    addAll: (2507 to: 2509);
	    add: 2519;
	    addAll: (2530 to: 2531);
	    add: 2562;
	    add: 2620;
	    add: 2622;
	    add: 2623;
	    addAll: (2624 to: 2626);
	    addAll: (2631 to: 2632);
	    addAll: (2635 to: 2637);
	    addAll: (2672 to: 2673);
	    addAll: (2689 to: 2691);
	    add: 2748;
	    addAll: (2750 to: 2757);
	    addAll: (2759 to: 2761);
	    addAll: (2763 to: 2765);
	    addAll: (2817 to: 2819);
	    add: 2876;
	    addAll: (2878 to: 2883);
	    addAll: (2887 to: 2888);
	    addAll: (2891 to: 2893);
	    addAll: (2902 to: 2903);
	    addAll: (2946 to: 2947);
	    addAll: (3006 to: 3010);
	    addAll: (3014 to: 3016);
	    addAll: (3018 to: 3021);
	    add: 3031;
	    addAll: (3073 to: 3075);
	    addAll: (3134 to: 3140);
	    addAll: (3142 to: 3144);
	    addAll: (3146 to: 3149);
	    addAll: (3157 to: 3158);
	    addAll: (3202 to: 3203);
	    addAll: (3262 to: 3268);
	    addAll: (3270 to: 3272);
	    addAll: (3274 to: 3277);
	    addAll: (3285 to: 3286);
	    addAll: (3330 to: 3331);
	    addAll: (3390 to: 3395);
	    addAll: (3398 to: 3400);
	    addAll: (3402 to: 3405);
	    add: 3415;
	    add: 3633;
	    addAll: (3636 to: 3642);
	    addAll: (3655 to: 3662);
	    add: 3761;
	    addAll: (3764 to: 3769);
	    addAll: (3771 to: 3772);
	    addAll: (3784 to: 3789);
	    addAll: (3864 to: 3865);
	    add: 3893;
	    add: 3895;
	    add: 3897;
	    add: 3902;
	    add: 3903;
	    addAll: (3953 to: 3972);
	    addAll: (3974 to: 3979);
	    addAll: (3984 to: 3989);
	    add: 3991;
	    addAll: (3993 to: 4013);
	    addAll: (4017 to: 4023);
	    add: 4025;
	    addAll: (8400 to: 8412);
	    add: 8417;
	    addAll: (12330 to: 12335);
	    add: 12441;
	    add: 12442;
	    addAll: (48 to: 57);
	    addAll: (1632 to: 1641);
	    addAll: (1776 to: 1785);
	    addAll: (2406 to: 2415);
	    addAll: (2534 to: 2543);
	    addAll: (2662 to: 2671);
	    addAll: (2790 to: 2799);
	    addAll: (2918 to: 2927);
	    addAll: (3047 to: 3055);
	    addAll: (3174 to: 3183);
	    addAll: (3302 to: 3311);
	    addAll: (3430 to: 3439);
	    addAll: (3664 to: 3673);
	    addAll: (3792 to: 3801);
	    addAll: (3872 to: 3881);
	    add: 183;
	    add: 720;
	    add: 721;
	    add: 903;
	    add: 1600;
	    add: 3654;
	    add: 3782;
	    add: 12293;
	    addAll: (12337 to: 12341);
	    addAll: (12445 to: 12446);
	    addAll: (12540 to: 12542);
	    yourself
    ]

    XMLParser class >> nameStartChars [
	<category: 'class initialization'>
	^(Set new: 65536)
	    addAll: (65 to: 90);
	    addAll: (97 to: 122);
	    addAll: (192 to: 214);
	    addAll: (216 to: 246);
	    addAll: (248 to: 255);
	    addAll: (256 to: 305);
	    addAll: (308 to: 318);
	    addAll: (321 to: 328);
	    addAll: (330 to: 382);
	    addAll: (384 to: 451);
	    addAll: (461 to: 496);
	    addAll: (500 to: 501);
	    addAll: (506 to: 535);
	    addAll: (592 to: 680);
	    addAll: (699 to: 705);
	    add: 902;
	    addAll: (904 to: 906);
	    add: 908;
	    addAll: (910 to: 929);
	    addAll: (931 to: 974);
	    addAll: (976 to: 982);
	    add: 986;
	    add: 988;
	    add: 990;
	    add: 992;
	    addAll: (994 to: 1011);
	    addAll: (1025 to: 1036);
	    addAll: (1038 to: 1103);
	    addAll: (1105 to: 1116);
	    addAll: (1118 to: 1153);
	    addAll: (1168 to: 1220);
	    addAll: (1223 to: 1224);
	    addAll: (1227 to: 1228);
	    addAll: (1232 to: 1259);
	    addAll: (1262 to: 1269);
	    addAll: (1272 to: 1273);
	    addAll: (1329 to: 1366);
	    add: 1369;
	    addAll: (1377 to: 1414);
	    addAll: (1488 to: 1514);
	    addAll: (1520 to: 1522);
	    addAll: (1569 to: 1594);
	    addAll: (1601 to: 1610);
	    addAll: (1649 to: 1719);
	    addAll: (1722 to: 1726);
	    addAll: (1728 to: 1742);
	    addAll: (1744 to: 1747);
	    add: 1749;
	    addAll: (1765 to: 1766);
	    addAll: (2309 to: 2361);
	    add: 2365;
	    addAll: (2392 to: 2401);
	    addAll: (2437 to: 2444);
	    addAll: (2447 to: 2448);
	    addAll: (2451 to: 2472);
	    addAll: (2474 to: 2480);
	    add: 2482;
	    addAll: (2486 to: 2489);
	    addAll: (2524 to: 2525);
	    addAll: (2527 to: 2529);
	    addAll: (2544 to: 2545);
	    addAll: (2565 to: 2570);
	    addAll: (2575 to: 2576);
	    addAll: (2579 to: 2600);
	    addAll: (2602 to: 2608);
	    addAll: (2610 to: 2611);
	    addAll: (2613 to: 2614);
	    addAll: (2616 to: 2617);
	    addAll: (2649 to: 2652);
	    add: 2654;
	    addAll: (2674 to: 2676);
	    addAll: (2693 to: 2699);
	    add: 2701;
	    addAll: (2703 to: 2705);
	    addAll: (2707 to: 2728);
	    addAll: (2730 to: 2736);
	    addAll: (2738 to: 2739);
	    addAll: (2741 to: 2745);
	    add: 2749;
	    add: 2784;
	    addAll: (2821 to: 2828);
	    addAll: (2831 to: 2832);
	    addAll: (2835 to: 2856);
	    addAll: (2858 to: 2864);
	    addAll: (2866 to: 2867);
	    addAll: (2870 to: 2873);
	    add: 2877;
	    addAll: (2908 to: 2909);
	    addAll: (2911 to: 2913);
	    addAll: (2949 to: 2954);
	    addAll: (2958 to: 2960);
	    addAll: (2962 to: 2965);
	    addAll: (2969 to: 2970);
	    add: 2972;
	    addAll: (2974 to: 2975);
	    addAll: (2979 to: 2980);
	    addAll: (2984 to: 2986);
	    addAll: (2990 to: 2997);
	    addAll: (2999 to: 3001);
	    addAll: (3077 to: 3084);
	    addAll: (3086 to: 3088);
	    addAll: (3090 to: 3112);
	    addAll: (3114 to: 3123);
	    addAll: (3125 to: 3129);
	    addAll: (3168 to: 3169);
	    addAll: (3205 to: 3212);
	    addAll: (3214 to: 3216);
	    addAll: (3218 to: 3240);
	    addAll: (3242 to: 3251);
	    addAll: (3253 to: 3257);
	    add: 3294;
	    addAll: (3296 to: 3297);
	    addAll: (3333 to: 3340);
	    addAll: (3342 to: 3344);
	    addAll: (3346 to: 3368);
	    addAll: (3370 to: 3385);
	    addAll: (3424 to: 3425);
	    addAll: (3585 to: 3630);
	    add: 3632;
	    addAll: (3634 to: 3635);
	    addAll: (3648 to: 3653);
	    addAll: (3713 to: 3714);
	    add: 3716;
	    addAll: (3719 to: 3720);
	    add: 3722;
	    add: 3725;
	    addAll: (3732 to: 3735);
	    addAll: (3737 to: 3743);
	    addAll: (3745 to: 3747);
	    add: 3749;
	    add: 3751;
	    addAll: (3754 to: 3755);
	    addAll: (3757 to: 3758);
	    add: 3760;
	    addAll: (3762 to: 3763);
	    add: 3773;
	    addAll: (3776 to: 3780);
	    addAll: (3904 to: 3911);
	    addAll: (3913 to: 3945);
	    addAll: (4256 to: 4293);
	    addAll: (4304 to: 4342);
	    add: 4352;
	    addAll: (4354 to: 4355);
	    addAll: (4357 to: 4359);
	    add: 4361;
	    addAll: (4363 to: 4364);
	    addAll: (4366 to: 4370);
	    add: 4412;
	    add: 4414;
	    add: 4416;
	    add: 4428;
	    add: 4430;
	    add: 4432;
	    addAll: (4436 to: 4437);
	    add: 4441;
	    addAll: (4447 to: 4449);
	    add: 4451;
	    add: 4453;
	    add: 4455;
	    add: 4457;
	    addAll: (4461 to: 4462);
	    addAll: (4466 to: 4467);
	    add: 4469;
	    add: 4510;
	    add: 4520;
	    add: 4523;
	    addAll: (4526 to: 4527);
	    addAll: (4535 to: 4536);
	    add: 4538;
	    addAll: (4540 to: 4546);
	    add: 4587;
	    add: 4592;
	    add: 4601;
	    addAll: (7680 to: 7835);
	    addAll: (7840 to: 7929);
	    addAll: (7936 to: 7957);
	    addAll: (7960 to: 7965);
	    addAll: (7968 to: 8005);
	    addAll: (8008 to: 8013);
	    addAll: (8016 to: 8023);
	    add: 8025;
	    add: 8027;
	    add: 8029;
	    addAll: (8031 to: 8061);
	    addAll: (8064 to: 8116);
	    addAll: (8118 to: 8124);
	    add: 8126;
	    addAll: (8130 to: 8132);
	    addAll: (8134 to: 8140);
	    addAll: (8144 to: 8147);
	    addAll: (8150 to: 8155);
	    addAll: (8160 to: 8172);
	    addAll: (8178 to: 8180);
	    addAll: (8182 to: 8188);
	    add: 8486;
	    addAll: (8490 to: 8491);
	    add: 8494;
	    addAll: (8576 to: 8578);
	    addAll: (12353 to: 12436);
	    addAll: (12449 to: 12538);
	    addAll: (12549 to: 12588);
	    addAll: (44032 to: 55203);
	    addAll: (19968 to: 40869);
	    add: 12295;
	    addAll: (12321 to: 12329);
	    yourself
    ]

    XMLParser class >> readFileContents: fn [
	<category: 'utilities'>
	| s p r |
	r := InputSource for: fn.
	p := self new.
	p lineEndLF.
	s := StreamWrapper 
		    resource: r
		    entity: nil
		    from: p.
	^
	[s checkEncoding.
	s contents] ensure: [s close]
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	eol := Character nl.
	buffer := (String new: 32) writeStream.
	nameBuffer := (String new: 16) writeStream
    ]

    lineEndLF [
	<category: 'initialize'>
	eol := Character nl
    ]

    lineEndCR [
	<category: 'initialize'>
	eol := Character cr
    ]

    lineEndNormal [
	<category: 'initialize'>
	eol := Character nl
    ]

    on: dataSource [
	"The dataSource may be a URI, a Filename (or a String
	 which will be treated as a Filename), or an InputSource."

	<category: 'initialize'>
	super on: dataSource.
	sourceStack := self wrapDataSource: dataSource.
	elementStack := OrderedCollection new.
	dtd := DocumentType new.
	unresolvedIDREFs := Set new.
	definedIDs := Set new.
    ]

    wrapDataSource: aDataSource [
	<category: 'initialize'>
	| resource uri |
	resource := (aDataSource isKindOf: Stream) 
		    ifTrue: 
			[uri := [NetClients.URL fromString: aDataSource name] on: Error
				    do: [:ex | ex return: nil].
			InputSource 
			    uri: uri
			    encoding: nil
			    stream: aDataSource]
		    ifFalse: [InputSource for: aDataSource].
	^(StreamWrapper 
	    resource: resource
	    entity: nil
	    from: self) isInternal: false
    ]

    dtd [
	<category: 'accessing'>
	^dtd
    ]

    eol [
	<category: 'accessing'>
	^eol
    ]

    sourceWrapper [
	<category: 'accessing'>
	^sourceStack	"last"
    ]

    hasExpanded: anEntity [
	<category: 'testing'>
	| s |
	s := sourceStack.
	[s == nil] whileFalse: 
		[s entity == anEntity 
		    ifTrue: 
			[self 
			    malformed: 'The %1 entity "%2" invokes itself recursively' % 
					{anEntity entityType.
					anEntity name}].
		s := s nextLink].
	^false
    ]

    shouldTestWFCEntityDeclared [
	<category: 'testing'>
	^self hasDTD not or: 
		[(self hasExternalDTD not and: [self usesParameterEntities not]) 
		    or: [self isDeclaredStandalone]]
    ]

    comment [
	<category: 'api'>
	| str1 |
	str1 := currentSource.
	^(self skipIf: '<!--') 
	    ifTrue: 
		[self completeComment: str1.
		true]
	    ifFalse: [false]
    ]

    docTypeDecl [
	<category: 'api'>
	| nm id hasInternalSubset |
	^(self skipIf: '<!DOCTYPE') 
	    ifTrue: 
		[self forceSpace.
		self noteDTD.
		nm := self getQualifiedName.
		self dtd declaredRoot: nm.
		self skipSpace.
		(id := self externalID: #docType) notNil ifTrue: [self skipSpace].
		self sourceWrapper usedAsExternal: false.
		hasInternalSubset := self skipIf: '['. 
		sax
		    startDoctypeDecl: nm
		    publicID: (id ifNotNil: [ id second ])
		    systemID: (id ifNotNil: [ id first ])
		    hasInternalSubset: hasInternalSubset.
		hasInternalSubset
		    ifTrue: [[self skipIf: ']'] whileFalse: [self dtdEntry]].
		self skipSpace.
		hereChar = $> ifFalse: [self expected: '>'].
		self sourceWrapper usedAsExternal: nil.
		id == nil ifFalse: [self dtdFile: id].
		self mustFind: '>'.
		sax endDoctypeDecl.
		self isValidating ifTrue: [dtd completeValidationAgainst: self].
		true]
	    ifFalse: [false]
    ]

    element [
	"Deprecated, see #parseElement:"

	<category: 'api'>
	^
	[sax startDocumentFragment.
	self getElement.
	sax endDocumentFragment.
	sax document == nil ifTrue: [nil] ifFalse: [sax document elements first]] 
		ifCurtailed: [self closeAllFiles]
    ]

    latestURI [
	<category: 'api'>
	| s |
	s := self fullSourceStack reverse detect: [:i | i uri notNil] ifNone: [nil].
	^s == nil 
	    ifTrue: 
		[NetClients.URL fromString: (Directory working / 'foo')]
	    ifFalse: [s uri]
    ]

    misc [
	<category: 'api'>
	^self atEnd not and: [self skipSpace or: [self comment or: [self pi]]]
    ]

    pi [
	<category: 'api'>
	| str1 |
	str1 := currentSource.
	^(self skipIf: '<?') 
	    ifTrue: 
		[self completePI: str1.
		true]
	    ifFalse: [false]
    ]

    prolog [
	<category: 'api'>
	self sourceWrapper xmlDecl.	"This is optional."
	self getNextChar.
	[self misc] whileTrue.
	self docTypeDecl ifTrue: [[self misc] whileTrue]
    ]

    pushSourceFor: entity [
        <category: 'entities'>
        entity text == nil
            ifTrue: 
                [| str input |
                input := sax resolveEntity: entity publicID
                            systemID: entity systemID.
                input == nil ifTrue: [input := InputSource for: entity systemID].
                self pushSource: input for: entity ]
            ifFalse:
                [self pushSource: (InputSource
                                        uri: nil
                                        encoding: nil
                                        stream: entity text readStream)
                        for: entity]
    ]

    pushSource: anInputSource for: anEntity [
	| str |
        <category: 'api'>
        (self hasExpanded: anEntity) 
            ifTrue: 
                [self malformed: 'Can''t expand this entity; it is defined recursively'].
	str := StreamWrapper
            resource: anInputSource
            entity: anEntity
            from: self.
	self pushSource: str.
	anEntity text isNil ifTrue: [str textDecl].
	self getNextChar
    ]

    pushSource: aStreamWrapper [
	<category: 'api'>
	aStreamWrapper nextLink: sourceStack.
	sourceStack := aStreamWrapper
    ]

    wrapSourceInSpaces [
	| entity source text |
	source := sourceStack.
	entity := sourceStack entity.
	sourceStack := sourceStack nextLink.
	text := ' ', source contents, ' '.
	source close.
        self pushSource: (InputSource
                              uri: nil
                              encoding: nil
                              stream: text readStream)
             for: entity
    ]

    scanDocument [
	<category: 'api'>
	^
	[sax startDocument.
	self prolog.
	self atEnd
	    ifTrue:
		[sax fatalError: (EmptySignal new 
			    messageText: 'Some XML content was expected')]
	    ifFalse:
		[self getElement.
		[self misc] whileTrue].
	self atEnd 
	    ifFalse: 
		[self 
		    malformed: 'A comment or processing instruction, or the end of the document, was expected'].
	self checkUnresolvedIDREFs.
	sax endDocument.
	self document] 
		ensure: [self closeAllFiles]
    ]

    xmlVersion: aString [
	"Do nothing for now"

	<category: 'api'>
	
    ]

    conditionalSect [
	<category: 'DTD processing'>
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
		    ifFalse: [[self skipIf: ']]>'] whileFalse: [self dtdEntry]].
		self ignore: oldIgnore.
		true]
	    ifFalse: [false]
    ]

    dtdEntry [
	<category: 'DTD processing'>
	((self PERef: #dtdEntry) 
	    or: [self markUpDecl or: [self conditionalSect or: [self skipSpace]]]) 
		ifFalse: [self malformed: 'A markup declaration or PE reference was expected']
    ]

    dtdFile: uriList [
	<category: 'DTD processing'>
	| str input |
	self noteExternalDTD.
	currentSource skip: -1.
	"So we don't lose hereChar."
	input := sax resolveEntity: (uriList at: 1) systemID: (uriList at: 2).
	input == nil ifTrue: [input := InputSource for: (uriList at: 2)].
	"TODO: raise skippedEntity here?"
	self pushSource: (str := StreamWrapper 
			    resource: input
			    entity: ((GeneralEntity new)
				    name: '[dtd]';
				    externalFrom: uriList)
			    from: self).
	str usedAsExternal: true.
	str textDecl.
	self getNextChar.
	[self fullSourceStack includes: str] whileTrue: [self dtdEntry]
    ]

    externalID: usage [
	"Usage may be #docType, #entity, or #notation.
	 DocType is treated specially, since PE references are not allowed.
	 Notation is treated specially since the system identifier of the
	 PUBLIC form is optional."

	<category: 'DTD processing'>
	| lit2 lit1 forceSpace skipSpace |
	forceSpace := 
		[usage == #docType ifTrue: [self forceSpace] ifFalse: [self forceSpaceInDTD]].
	skipSpace := 
		[usage == #docType ifTrue: [self skipSpace] ifFalse: [self skipSpaceInDTD]].
	^(self skipIf: 'SYSTEM') 
	    ifTrue: 
		[forceSpace value.
		lit2 := self systemLiteral.
		Array with: nil with: lit2]
	    ifFalse: 
		[(self skipIf: 'PUBLIC') 
		    ifTrue: 
			[forceSpace value.
			lit1 := self pubIdLiteral.
			usage == #notation 
			    ifTrue: 
				[(skipSpace value and: [hereChar = $' or: [hereChar = $"]]) 
				    ifTrue: [lit2 := self systemLiteral]
				    ifFalse: [lit2 := nil]]
			    ifFalse: 
				[forceSpace value.
				lit2 := self systemLiteral].
			Array with: lit1 with: lit2]
		    ifFalse: [nil]]
    ]

    inInternalSubset [
	<category: 'DTD processing'>
	self fullSourceStack 
	    reverseDo: [:str | str usedAsExternal == nil ifFalse: [^str usedAsExternal not]].
	self error: 'Not currently processing the DTD'
    ]

    markUpDecl [
	<category: 'DTD processing'>
	^self elementDecl or: 
		[self attListDecl 
		    or: [self entityDecl or: [self notationDecl or: [self pi or: [self comment]]]]]
    ]

    notationDecl [
	<category: 'DTD processing'>
	| nm id str |
	str := currentSource.
	^(self skipIf: '<!NOTATION') 
	    ifTrue: 
		[self forceSpaceInDTD.
		nm := self getSimpleName.
		self forceSpaceInDTD.
		id := self externalID: #notation.
		self ignore 
		    ifFalse: 
			[id == nil ifTrue: [self malformed: 'Invalid PUBLIC / SYSTEM identifiers'].
			dtd 
			    notationAt: nm
			    put: (Notation new name: nm identifiers: id)
			    from: self.
			sax 
			    notationDecl: nm
			    publicID: (id at: 1)
			    systemID: (id at: 2)].
		self skipSpaceInDTD.
		self mustFind: '>'.
		str == lastSource 
		    ifFalse: 
			[self invalid: 'Improper nesting of declarations within a parameter entity'].
		true]
	    ifFalse: [false]
    ]

    parseIgnore [
	<category: 'DTD processing'>
	| entryCount openIndex closeIndex |
	entryCount := 1.
	openIndex := closeIndex := 1.
	[entryCount = 0] whileFalse: 
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
		self getNextChar]
    ]

    pubIdLiteral [
	<category: 'DTD processing'>
	| str s1 |
	str := self quotedString.
	str do: 
		[:ch | 
		((' -''()+,./:=?;!*#@$_%' includes: ch) or: 
			[ch asInteger = 10 or: 
				[ch asInteger = 13 
				    or: [ch asciiValue < 127 and: [ch isLetter or: [ch isDigit]]]]]) 
		    ifFalse: [self malformed: 'Invalid public id character found']].
	str replaceAll: Character tab with: Character space.
	str replaceAll: Character cr with: Character space.
	str replaceAll: Character nl with: Character space.
	[(s1 := str copyReplaceAll: '  ' with: ' ') = str] whileFalse: [str := s1].
	(str isEmpty not and: [str first = Character space]) 
	    ifTrue: [str := str copyFrom: 2 to: str size].
	(str isEmpty not and: [str last = Character space]) 
	    ifTrue: [str := str copyFrom: 1 to: str size - 1].
	^str
    ]

    systemLiteral [
	<category: 'DTD processing'>
	| lit |
	lit := self quotedString.
	(lit includes: $#) 
	    ifTrue: [self malformed: 'Fragments in System IDs are not supported'].
	^lit isEmpty 
	    ifTrue: [lit]
	    ifFalse: [(self latestURI resolvePath: lit) asString]
    ]

    entityDecl [
	<category: 'entity processing'>
	| nm def str |
	str := currentSource.
	^(self skipIf: '<!ENTITY') 
	    ifTrue: 
		[self forceSpace.
		hereChar = $% 
		    ifTrue: 
			[self
			    getNextChar;
			    forceSpaceInDTD.
			nm := self getSimpleName.
			self forceSpaceInDTD.
			def := self peDef: nm.
			self ignore 
			    ifFalse: 
				[self dtd 
				    parameterEntityAt: nm
				    put: def
				    from: self]]
		    ifFalse: 
			[self skipSpaceInDTD.
			nm := self getSimpleName.
			self forceSpaceInDTD.
			def := self entityDef: nm.
			self ignore 
			    ifFalse: 
				[self dtd 
				    generalEntityAt: nm
				    put: def
				    from: self]].
		self skipSpaceInDTD.
		self mustFind: '>'.
		str == lastSource 
		    ifFalse: 
			[self invalid: 'Improper nesting of declarations within a parameter entity'].
		true]
	    ifFalse: [false]
    ]

    entityDef: name [
	<category: 'entity processing'>
	| val ndata |
	^(val := self entityValue) == nil 
	    ifTrue: 
		[(val := self externalID: #entity) == nil 
		    ifTrue: [self malformed: 'An entity value or external id was expected']
		    ifFalse: 
			[| entity |
			ndata := self nDataDecl.
			entity := (GeneralEntity new)
				    name: name;
				    externalFrom: val;
				    ndata: ndata;
				    isDefinedExternally: self inInternalSubset not.
			ndata == nil 
			    ifFalse: 
				[sax 
				    unparsedEntityDecl: name
				    publicID: entity publicID
				    systemID: entity systemID
				    notationName: ndata].
			entity]]
	    ifFalse: 
		[(GeneralEntity new)
		    name: name;
		    text: val;
		    isDefinedExternally: self inInternalSubset not]
    ]

    entityValue [
	<category: 'entity processing'>
	| aQuote s str1 |
	aQuote := hereChar.
	(aQuote = $' or: [aQuote = $"]) ifFalse: [^nil].
	s := currentSource.
	self getNextChar.
	buffer reset.
	
	[hereChar == nil ifTrue: [self expected: (String with: aQuote)].
	hereChar = aQuote and: [s = currentSource]] 
		whileFalse: 
		    [hereChar = $& 
			ifTrue: 
			    [str1 := currentSource.
			    (self skipIf: '&#') 
				ifTrue: [self charEntity: buffer startedIn: str1]
				ifFalse: 
				    [self
					getNextChar;
					generalEntity: buffer]]
			ifFalse: 
			    [(self PERef: #data) 
				ifFalse: 
				    [buffer nextPut: hereChar.
				    self getNextChar]]].
	self getNextChar.
	^buffer contents
    ]

    generalEntity: str [
	<category: 'entity processing'>
	| nm |
	nm := self getSimpleName.
	hereChar = $; ifFalse: [self malformed: 'A semicolon was expected'].
	str
	    nextPut: $&;
	    nextPutAll: nm;
	    nextPut: $;.
	self getNextChar
    ]

    nDataDecl [
	<category: 'entity processing'>
	^self skipSpaceInDTD 
	    ifTrue: 
		[(self skipIf: 'NDATA') 
		    ifTrue: 
			[self forceSpaceInDTD.
			self getSimpleName]
		    ifFalse: [nil]]
	    ifFalse: [nil]
    ]

    peDef: name [
	<category: 'entity processing'>
	| val |
	^(val := self entityValue) == nil 
	    ifTrue: 
		[(val := self externalID: #entity) == nil 
		    ifTrue: [self malformed: 'An entity value or external id was expected']
		    ifFalse: 
			[(ParameterEntity new)
			    name: name;
			    externalFrom: val]]
	    ifFalse: 
		[(ParameterEntity new)
		    name: name;
		    text: val]
    ]

    PERef: refType [
	<category: 'entity processing'>
	| nm exp |
	^hereChar = $% 
	    ifTrue: 
		[refType = #dtdEntry ifTrue: [self notePEReference].
		self getNextChar.
		(self inInternalSubset and: [refType ~= #dtdEntry]) 
		    ifTrue: 
			[self 
			    malformed: 'Parameter entity references cannot be used in the internal DTD, inside a declaration'].
		nm := self getSimpleName.
		hereChar = $; ifFalse: [self malformed: 'A semicolon was expected'].
		exp := self dtd parameterEntityAt: nm.
		exp == nil 
		    ifTrue: 
			[self isValidating 
			    ifTrue: 
				[self invalid: 'Parameter entity "%%%1" used but not defined' % {nm}.
				self getNextChar]
			    ifFalse: 
				[self skippedEntity: '%', nm.
				self 
				    pushSource: (StreamWrapper emptyWithExtraSpace: refType ~= #data from: self).
				self getNextChar]]
		    ifFalse:
			[self pushSourceFor: exp.
			refType = #data ifFalse: [self wrapSourceInSpaces]].
		(refType ~= #data and: [self sourceWrapper uri notNil]) 
		    ifTrue: [self sourceWrapper usedAsExternal: true].
		true]
	    ifFalse: [false]
    ]

    completeChildren: str [
	<category: 'element def processing'>
	| div items node |
	items := OrderedCollection with: self cp.
	self skipSpaceInDTD.
	div := nil.
	[self skipIf: ')'] whileFalse: 
		[div == nil 
		    ifTrue: 
			[(',|' includes: hereChar) 
			    ifFalse: [self malformed: 'Either , or | was expected'].
			div := hereChar].
		div = hereChar ifFalse: [self expected: (String with: div)].
		self
		    getNextChar;
		    skipSpaceInDTD.
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
	^node
    ]

    completeMixedContent: str [
	"we already have the #PCDATA finished."

	<category: 'element def processing'>
	| names |
	self skipSpaceInDTD.
	names := OrderedCollection new.
	[hereChar = $)] whileFalse: 
		[self mustFind: '|'.
		self skipSpaceInDTD.
		names add: (NamePattern named: self getQualifiedName).
		self skipSpaceInDTD].
	(self isValidating and: [currentSource ~~ str]) 
	    ifTrue: [self invalid: 'Parentheses must nest properly within entities'].
	names size = 0 
	    ifTrue: 
		[self
		    mustFind: ')';
		    skipIf: '*']
	    ifFalse: [self mustFind: ')*'].
	1 to: names size
	    do: 
		[:i | 
		i + 1 to: names size
		    do: 
			[:j | 
			(names at: i) name asString = (names at: j) name asString 
			    ifTrue: 
				[self invalid: 'Duplicate element names in a mixed content specification.'].
			((names at: i) name isLike: (names at: j) name) 
			    ifTrue: 
				[self invalid: 'Duplicate element names in a mixed content specification.']]].
	^MixedPattern on: names
    ]

    contentsSpec [
	<category: 'element def processing'>
	| str |
	^(self skipIf: 'ANY') 
	    ifTrue: [AnyPattern new]
	    ifFalse: 
		[(self skipIf: 'EMPTY') 
		    ifTrue: [EmptyPattern new]
		    ifFalse: 
			[str := currentSource.
			self mustFind: '('.
			self skipSpaceInDTD.
			(self skipIf: '#PCDATA') 
			    ifTrue: [self completeMixedContent: str]
			    ifFalse: [self completeChildren: str]]]
    ]

    cp [
	<category: 'element def processing'>
	| node str |
	str := currentSource.
	^(self skipIf: '(') 
	    ifTrue: 
		[self
		    skipSpaceInDTD;
		    completeChildren: str]
	    ifFalse: 
		[node := NamePattern named: self getQualifiedName.
		('*+?' includes: hereChar) 
		    ifTrue: 
			[node := ModifiedPattern on: node type: hereChar.
			self getNextChar].
		node]
    ]

    elementDecl [
	<category: 'element def processing'>
	| nm cSpec str |
	str := currentSource.
	^(self skipIf: '<!ELEMENT') 
	    ifTrue: 
		[self forceSpaceInDTD.
		nm := self getQualifiedName.
		self forceSpaceInDTD.
		cSpec := self contentsSpec normalizeFor: self.
		cSpec isExternal: self inInternalSubset not.
		self ignore 
		    ifFalse: 
			[self dtd 
			    elementFor: nm
			    put: cSpec
			    from: self].
		self skipSpaceInDTD.
		self mustFind: '>'.
		str == lastSource 
		    ifFalse: 
			[self invalid: 'Improper nesting of declarations within a parameter entity'].
		true]
	    ifFalse: [false]
    ]

    charEntity: data startedIn: str1 [
	<category: 'element processing'>
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
	[hereChar = $;] whileFalse: 
		[d := hereChar digitValue.
		(d >= 0 and: [d < base]) ifFalse: [self malformed: digit].
		n := n * base + d.
		self getNextChar].
	str1 = currentSource 
	    ifFalse: 
		[self 
		    malformed: 'Character entities must nest properly inside other entities'].
	"Originally we tested ch to make sure it was less than 16r110000,
	 but now CharacterClasses' implementation of #at: answers 0 for
	 large values of ch. If primitive failure code can not be trusted to do
	 this, then the bounds check would have to be added back."
	(CharacterClasses at: n + 1) = 0 
	    ifTrue: 
		[sax fatalError: (BadCharacterSignal new 
			    messageText: 'A character with Unicode value %1 is not legal' % {n})].
	data display: (Character codePoint: n).
	self getNextChar
    ]

    closeTag: tag [
	<category: 'element processing'>
	| nm |
	nm := self getQualifiedName.
	nm := self correctTag: nm.
	self skipSpace.
	self mustFind: '>'.
	nm = tag 
	    ifFalse: 
		[self malformed: 'The close tag for %1 was not found' % {tag asString}].
	sax 
	    endElement: nm namespace
	    localName: nm type
	    qName: nm asString.
	elementStack last definesNamespaces 
	    ifTrue: 
		[elementStack last namespaces 
		    keysDo: [:qualifier | sax endPrefixMapping: qualifier]]
    ]

    completeCDATA: str1 [
	<category: 'element processing'>
	| str data size textType |
	buffer reset.
	
	[str := self upToAll: ']>'.
	str last = $]] whileFalse: 
		    [buffer
			nextPutAll: str;
			nextPutAll: ']>'].
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
	    ifTrue: 
		[sax 
		    ignorableWhitespace: data
		    from: 1
		    to: size]
	    ifFalse: 
		[sax 
		    characters: data
		    from: 1
		    to: size]
    ]

    completeComment: str1 [
	<category: 'element processing'>
	| str comment size index |
	buffer reset.
	
	[str := self upToAll: '->'.
	str last = $-] whileFalse: 
		    [buffer
			nextPutAll: str;
			nextPutAll: '->'].
	buffer nextPutAll: (str copyFrom: 1 to: str size - 1).
	comment := buffer collection.
	size := buffer position.
	index := comment indexOfSubCollection: '--' startingAt: 1.
	(index = 0 or: [index >= size]) 
	    ifFalse: [self malformed: 'Doubled hyphens in comments are not permitted'].
	(size > 0 and: [(comment at: size) = $-]) 
	    ifTrue: 
		[self 
		    malformed: 'A hyphen is not permitted as the last character in a comment'].
	lastSource = str1 
	    ifFalse: [self malformed: 'Comments must nest properly in entities'].
	self ignore 
	    ifFalse: 
		[sax 
		    comment: comment
		    from: 1
		    to: size]
    ]

    completePI: str1 [
	<category: 'element processing'>
	| nm pi |
	nm := self getSimpleName.
	nm = 'xml' 
	    ifTrue: 
		[self 
		    malformed: 'An "xml" declaration is not permitted, except at the beginning of the file'].
	nm asLowercase = 'xml' 
	    ifTrue: 
		[self 
		    malformed: '''xml'' is not permitted as the target of a processing instruction'].
	self skipSpace 
	    ifTrue: [pi := self upToAll: '?>']
	    ifFalse: 
		[pi := ''.
		self mustFind: '?>'].
	lastSource = str1 
	    ifFalse: 
		[self malformed: 'Pprogramming instructions must nest properly in entities'].
	self ignore ifFalse: [sax processingInstruction: nm data: pi]
    ]

    elementAtPosition: startPosition [
	<category: 'element processing'>
	| attributes nm str1 |
	str1 := currentSource.
	self mustFind: '<'.
	nm := self getQualifiedName.
	self pushNewTag: nm.
	latestID := nil.
	attributes := self processAttributes: nm.
	nm := self correctTag: nm.
	elementStack last definesNamespaces 
	    ifTrue: 
		[elementStack last namespaces 
		    keysAndValuesDo: [:qualifier :uri | sax startPrefixMapping: qualifier uri: uri]].
	sax 
	    startElement: nm namespace
	    localName: nm type
	    qName: nm asString
	    attributes: (attributes == nil ifTrue: [#()] ifFalse: [attributes]).
	sax sourcePosition: startPosition inStream: str1.
	latestID notNil ifTrue: [sax idOfElement: latestID].
	(self skipIf: '/>') 
	    ifTrue: 
		[str1 = lastSource 
		    ifFalse: [self expected: 'Elements must nest properly within entities'].
		sax 
		    endElement: nm namespace
		    localName: nm type
		    qName: nm asString]
	    ifFalse: 
		[(self skipIf: '>') 
		    ifTrue: 
			[str1 = lastSource 
			    ifFalse: [self expected: 'Elements must nest properly within entities'].
			self elementContent: nm openedIn: str1]
		    ifFalse: [self expected: 'end of start tag']].
	self popTag
    ]

    elementContent: tag openedIn: str [
	<category: 'element processing'>
	| data str1 braceCount size textType |
	braceCount := 0.
	buffer reset.
	
	[hereChar == nil 
	    ifTrue: [self malformed: 'The end tag for <%1> was expected' % {tag}].
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
				[(self isValidating 
				    and: [self isDeclaredStandalone and: [elementStack last isDefinedExternal]]) 
					ifTrue: [self invalid: 'This document is not standalone'].
				sax 
				    ignorableWhitespace: data
				    from: 1
				    to: size]
			    ifFalse: 
				[sax 
				    characters: data
				    from: 1
				    to: size]].
		str1 := currentSource.
		(self skipIf: '</') 
		    ifTrue: 
			[self closeTag: tag.
			str == lastSource 
			    ifFalse: [self malformed: 'Elements must nest properly within entities'].
			^self]
		    ifFalse: 
			[(self skipIf: '<?') 
			    ifTrue: [self completePI: str1]
			    ifFalse: 
				[(self skipIf: '<![CDATA[') 
				    ifTrue: [
					sax startCdataSection.
					self completeCDATA: str1.
					sax endCdataSection]
				    ifFalse: 
					[(self skipIf: '<!--') 
					    ifTrue: [self completeComment: str1]
					    ifFalse: [self getElement]]]].
		buffer reset]
	    ifFalse: 
		[hereChar == $& 
		    ifTrue: 
			[braceCount := 0.
			str1 := currentSource.
			(self skipIf: '&#') 
			    ifTrue: [self charEntity: buffer startedIn: str1]
			    ifFalse: 
				[self
				    getNextChar;
				    generalEntityInText: buffer canBeExternal: true]]
		    ifFalse: 
			[hereChar == $] 
			    ifTrue: [braceCount := braceCount + 1]
			    ifFalse: 
				[(hereChar == $> and: [braceCount >= 2]) 
				    ifTrue: [self malformed: ']]> is not permitted in element content'].
				braceCount := 0].
			buffer nextPut: hereChar.
			self getNextChar]]] 
		repeat
    ]

    generalEntityInText: str canBeExternal: external [
	<category: 'element processing'>
	| exp nm str1 msg |
	str1 := lastSource.
	nm := self getSimpleName.
	hereChar = $; ifFalse: [self malformed: 'A semicolon was expected'].
	currentSource = str1 
	    ifFalse: 
		[self 
		    malformed: 'Entity references must nest properly within other entity references'].
	exp := self dtd generalEntityAt: nm.
	exp == nil 
	    ifTrue: 
		[self isValidating
		    ifTrue: [self invalid: 'The general entity "%1" has not been defined' % {nm}]
		    ifFalse: [sax skippedEntity: nm].
		self shouldTestWFCEntityDeclared 
		    ifTrue: [self malformed: 'General entity used but not defined'].
		"str nextPut: $&; nextPutAll: nm; nextPut: $;."
		self getNextChar]
	    ifFalse: 
		[(external or: [exp isExternal not]) 
		    ifFalse: 
			[self 
			    malformed: 'External entity references are not permitted in attribute values'].
		(self isValidating 
		    and: [self isDeclaredStandalone and: [exp isDefinedExternally]]) 
			ifTrue: [self invalid: 'This document is not standalone'].
		exp isParsed 
		    ifFalse: 
			[self 
			    malformed: 'References to unparsed entities other than in an attribute of type ENTITY are not permitted'].
		self pushSourceFor: exp]
    ]

    getElement [
	<category: 'element processing'>
	| str1 startPosition |
	str1 := currentSource.
	startPosition := str1 stream position - (str1 characterSize: hereChar).
	^self elementAtPosition: startPosition
    ]

    isValidTag: aTag [
	<category: 'element processing'>
	^true
    ]

    popTag [
	<category: 'element processing'>
	self isValidating 
	    ifTrue: 
		[elementStack last canTerminate 
		    ifFalse: 
			[self invalid: 'One of %1 was expected, but none was found' 
				    % {elementStack last followSetDescription}]].
	elementStack removeLast
    ]

    pushNewTag: nm [
	<category: 'element processing'>
	| elm p types |
	self isValidating 
	    ifTrue: 
		[elementStack isEmpty 
		    ifTrue: 
			[(self hasDTD and: [self dtd declaredRoot asString ~= nm asString]) 
			    ifTrue: [self invalid: 'Document type must match type of the root element']]
		    ifFalse: 
			[elm := elementStack last.
			types := self hasDTD ifTrue: [elm validateTag: nm] ifFalse: [nil].
			(types == nil and: [ self hasDTD ])
			    ifTrue: 
				[self 
				    invalid: '"%1" is not permitted at this point in the "%2" node' % 
						{nm asString.
						elm tag asString}].
			elm types: types].
		elementStack addLast: (ElementContext new tag: nm).
		p := self dtd elementFor: nm from: self.
		self hasDTD
		    ifTrue: 
			[p == nil
			    ifTrue: [self invalid: 'Using a tag (%1) without declaring it is not permitted' 
					    % {nm asString}]
			    ifFalse: [elementStack last type: p]]]
	    ifFalse: [elementStack addLast: (ElementContext new tag: nm)]
    ]

    validateText: data from: start to: stop testBlanks: testBlanks [
	<category: 'element processing'>
	| elm textType types |
	textType := #characters.
	stop < start ifTrue: [^textType].
	(self isValidating and: [ self hasDTD ])
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
			elm types: types]]
	    ifFalse: 
		[testBlanks ifFalse: [^#characters].
		textType := #whitespace.
		start to: stop do: [:i | (data at: i) asInteger > 32
		    ifTrue: [^#characters]]].
	^textType
    ]

    attListDecl [
	<category: 'attribute def processing'>
	| nm str1 attr |
	str1 := currentSource.
	^(self skipIf: '<!ATTLIST') 
	    ifTrue: 
		[self forceSpaceInDTD.
		nm := self getQualifiedName.
		
		[self skipSpaceInDTD.
		self skipIf: '>'] whileFalse: 
			    [self skipSpaceInDTD.
			    attr := AttributeDef new name: self getQualifiedName.
			    self forceSpaceInDTD.
			    attr type: self attType.
			    attr type isExternal: self inInternalSubset not.
			    self forceSpaceInDTD.
			    attr default: (self defaultDeclType: attr type).
			    self isValidating ifTrue: [attr selfValidateFor: self].
			    self 
				checkReservedAttributes: attr name asString
				type: attr type
				value: attr default.
			    self ignore 
				ifFalse: 
				    [self dtd 
					attributeFor: nm
					subKey: attr name
					put: attr
					from: self]].
		str1 == lastSource 
		    ifFalse: 
			[self invalid: 'Improper nesting of declarations within a parameter entity'].
		true]
	    ifFalse: [false]
    ]

    attType [
	<category: 'attribute def processing'>
	| nm all type |
	^hereChar = $( 
	    ifTrue: [self enumeration]
	    ifFalse: 
		[nm := self getSimpleName.
		all := #('NOTATION' 'CDATA' 'ID' 'IDREF' 'IDREFS' 'ENTITY' 'ENTITIES' 'NMTOKEN' 'NMTOKENS').
		(all includes: nm) 
		    ifFalse: 
			[self malformed: 'One of %1 was expected, but none was found' % {all}].
		type := #(#{NOTATION_AT} #{CDATA_AT} #{ID_AT} #{IDREF_AT} #{IDREFS_AT} #{ENTITY_AT} #{ENTITIES_AT} #{NMTOKEN_AT} #{NMTOKENS_AT}) 
			    at: (all indexOf: nm).
		nm = 'NOTATION' 
		    ifTrue: [self completeNotationType]
		    ifFalse: [type value new]]
    ]

    completeNotationType [
	<category: 'attribute def processing'>
	| nm |
	self forceSpaceInDTD.
	self mustFind: '('.
	self skipSpaceInDTD.
	nm := OrderedCollection with: self getSimpleName.
	self skipSpaceInDTD.
	[self skipIf: '|'] whileTrue: 
		[self skipSpaceInDTD.
		nm add: self getSimpleName.
		self skipSpaceInDTD].
	self mustFind: ')'.
	^NOTATION_AT typeNames: nm
    ]

    defaultDecl [
	<category: 'attribute def processing'>
	| fixed default |
	^(self skipIf: '#REQUIRED') 
	    ifTrue: [#required]
	    ifFalse: 
		[(self skipIf: '#IMPLIED') 
		    ifTrue: [#implied]
		    ifFalse: 
			[fixed := self skipIf: '#FIXED'.
			fixed ifTrue: [self forceSpaceInDTD].
			default := self attValue.
			default == nil 
			    ifTrue: 
				[self malformed: 'A quoted value was expected for the attribute''s default'].
			fixed -> default]]
    ]

    defaultDeclType: type [
	<category: 'attribute def processing'>
	| fixed default |
	^(self skipIf: '#REQUIRED') 
	    ifTrue: [#required]
	    ifFalse: 
		[(self skipIf: '#IMPLIED') 
		    ifTrue: [#implied]
		    ifFalse: 
			[fixed := self skipIf: '#FIXED'.
			fixed ifTrue: [self forceSpaceInDTD].
			default := self attValue: type inDTD: true.
			default == nil 
			    ifTrue: 
				[self malformed: 'A quoted value was expected for the attribute''s default'].
			fixed -> default]]
    ]

    enumeration [
	<category: 'attribute def processing'>
	| nm |
	self mustFind: '('.
	self skipSpaceInDTD.
	nm := OrderedCollection with: self nmToken.
	self skipSpaceInDTD.
	[self skipIf: '|'] whileTrue: 
		[self skipSpaceInDTD.
		nm add: self nmToken.
		self skipSpaceInDTD].
	self mustFind: ')'.
	^Enumeration_AT withAll: nm
    ]

    attribute [
	<category: 'attribute processing'>
	| nm value |
	nm := self getQualifiedName.
	self skipSpace.
	self mustFind: '='.
	self skipSpace.
	value := self attValue.
	value == nil 
	    ifTrue: 
		[self 
		    malformed: 'A quoted value for the attribute was expected, but not found'].
	self 
	    checkReservedAttributes: nm asString
	    type: nil
	    value: value.
	^Attribute name: nm value: value
    ]

    attributeFor: elementTag [
	<category: 'attribute processing'>
	| nm value |
	nm := self getQualifiedName.
	self skipSpace.
	self mustFind: '='.
	self skipSpace.
	value := self attValue: (self dtd 
			    attributeTypeFor: elementTag
			    subKey: nm
			    from: self)
		    inDTD: false.
	value == nil 
	    ifTrue: 
		[self 
		    malformed: 'A quoted value for the attribute was expected, but not found'].
	self 
	    checkReservedAttributes: nm asString
	    type: nil
	    value: value.
	^Attribute name: nm value: value
    ]

    attValue [
	<category: 'attribute processing'>
	| aQuote s str1 |
	aQuote := hereChar.
	(aQuote = $' or: [aQuote = $"]) ifFalse: [^nil].
	buffer reset.
	s := currentSource.
	self getNextChar.
	[hereChar = aQuote and: [s = currentSource]] whileFalse: 
		[hereChar == nil 
		    ifTrue: [self malformed: 'No close quote found for attribute value'].
		hereChar = $< 
		    ifTrue: [self malformed: '< not permitted in attribute values; use &lt;'].
		hereChar = $& 
		    ifTrue: 
			[str1 := currentSource.
			(self skipIf: '&#') 
			    ifTrue: [self charEntity: buffer startedIn: str1]
			    ifFalse: 
				[self
				    getNextChar;
				    generalEntityInText: buffer canBeExternal: false]]
		    ifFalse: 
			[hereChar asInteger < 32 
			    ifTrue: [buffer space]
			    ifFalse: [buffer nextPut: hereChar].
			self getNextChar]].
	self getNextChar.
	^buffer contents
    ]

    attValue: attType inDTD: isInDTD [
	<category: 'attribute processing'>
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
	[hereChar = aQuote and: [s = currentSource]] whileFalse: 
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
			    ifFalse: 
				[self
				    getNextChar;
				    generalEntityInText: buffer canBeExternal: false]]
		    ifFalse: 
			[(isInDTD and: [self PERef: #data]) 
			    ifFalse: 
				[hereChar asInteger <= 32 
				    ifTrue: 
					[isCDATA 
					    ifTrue: [buffer space]
					    ifFalse: [sawSpace ifFalse: [sawSpace := needsSpace := true]]]
				    ifFalse: 
					[needsSpace ifTrue: [buffer space].
					needsSpace := sawSpace := false.
					buffer nextPut: hereChar].
				count := count + 1.
				self getNextChar]]].
	(self isValidating and: 
		[self isDeclaredStandalone 
		    and: [count ~= buffer position and: [attType isExternal]]]) 
	    ifTrue: [self invalid: 'This document is not standalone'].
	self getNextChar.
	^buffer contents
    ]

    checkCountryCode: code from: value [
	<category: 'attribute processing'>
	code size >= 2 ifFalse: [self illegalLanguageCode: value]
	"code size = 2
	 ifTrue: [self checkIso3166Code: code from: value]
	 ifFalse: [self checkIanaSubcode: code from: value]"
    ]

    checkIanaLanguageCode: code from: value [
	<category: 'attribute processing'>
	^self
    ]

    checkIso639LanguageCode: code from: value [
	<category: 'attribute processing'>
	code size = 2 ifFalse: [self illegalLanguageCode: value]
    ]

    checkLanguageCode: value [
	<category: 'attribute processing'>
	| vals list |
	value == nil ifTrue: [^self].
	value size = 0 ifTrue: [self illegalLanguageCode: value].
	value last = $- ifTrue: [self illegalLanguageCode: value].
	vals := value readStream.
	list := OrderedCollection new.
	[vals atEnd] whileFalse: [list add: (vals upTo: $-) asLowercase].
	list do: 
		[:subcode | 
		subcode size = 0 ifTrue: [self illegalLanguageCode: value].
		subcode 
		    do: [:ch | (ch between: $a and: $z) ifFalse: [self illegalLanguageCode: value]]].
	list first = 'x' 
	    ifTrue: 
		[list size > 1 ifFalse: [self illegalLanguageCode: value].
		^self].
	list first = 'i' 
	    ifTrue: 
		[list size > 1 ifFalse: [self illegalLanguageCode: value].
		self checkIanaLanguageCode: (list at: 2) from: value.
		list size > 2 ifTrue: [self checkCountryCode: (list at: 3) from: value].
		^self].
	self checkIso639LanguageCode: (list at: 1) from: value.
	list size > 1 ifTrue: [self checkCountryCode: (list at: 2) from: value]
    ]

    checkReservedAttributes: nm type: type value: value [
	<category: 'attribute processing'>
	nm = 'xml:lang' ifTrue: [self checkLanguageCode: value].
	nm = 'xml:space' 
	    ifTrue: 
		[(type = nil or: 
			[type class = Enumeration_AT 
			    and: [(type values asSet - #('default' 'preserve') asSet) isEmpty]]) 
		    ifFalse: [self malformed: 'Malformed type definition for xml:space'].
		"The value may be nil if we're checking the ATTLIST definition"
		(value = 'default' or: [value = 'preserve' or: [value == nil]]) 
		    ifFalse: 
			[self malformed: 'xml:space must have a value of "preserve" or "default"']]
    ]

    illegalLanguageCode: value [
	<category: 'attribute processing'>
	self malformed: 'Illegal value (%1) for xml:lang' % {value}
    ]

    isValidName: aTag [
	<category: 'attribute processing'>
	aTag size = 0 ifTrue: [^false].
	(self isValidNameStart: aTag first) ifFalse: [^false].
	2 to: aTag size
	    do: [:i | (self isValidNameChar: (aTag at: i)) ifFalse: [^false]].
	^true
    ]

    isValidNmToken: aTag [
	<category: 'attribute processing'>
	aTag size = 0 ifTrue: [^false].
	1 to: aTag size
	    do: 
		[:i | 
		((self isValidNameChar: (aTag at: i)) or: [(aTag at: i) = $:]) 
		    ifFalse: [^false]].
	^true
    ]

    processAttributes: nm [
	<category: 'attribute processing'>
	| attributes hadSpace |
	attributes := nil.
	
	[hadSpace := self skipSpace.
	self isValidNameStart: hereChar] whileTrue: 
		    [hadSpace 
			ifFalse: [self malformed: 'Attributes must be preceded by white space'].
		    attributes == nil ifTrue: [attributes := OrderedCollection new: 5].
		    attributes addLast: (self attributeFor: nm).
		    (attributes collect: [:i | i tag asString]) asSet size = attributes size 
			ifFalse: 
			    [self 
				malformed: 'The attribute "%1" was used twice in this element''s tag' 
					% {attributes last tag asString}]].
	(self hasDTD and: [ self isValidating ])
	    ifTrue: [attributes := self validateAttributes: attributes for: nm].
	attributes := self resolveNamespaces: attributes.
	^attributes
    ]

    quotedString [
	<category: 'attribute processing'>
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
	self malformed: 'Quoted string expected but not found'
    ]

    validateAttributes: attributes for: tag [
	<category: 'attribute processing'>
	| attr attributeList |
	attr := self dtd attributesFor: tag.
	attributeList := attributes == nil ifTrue: [#()] ifFalse: [attributes].
	attributeList do: 
		[:i | 
		(attr includesKey: i key asString) 
		    ifFalse: 
			[self invalid: 'the attribute %1 was not defined in the DTD' % {i key}]].
	attr do: 
		[:adef | 
		| a |
		a := attributeList detect: [:at | at key isLike: adef name] ifNone: [].
		a == nil 
		    ifTrue: 
			[adef hasDefault 
			    ifTrue: 
				[(self isValidating 
				    and: [self isDeclaredStandalone and: [adef type isExternal]]) 
					ifTrue: [self invalid: 'This document is not standalone'].
				attributeList := attributeList 
					    copyWith: (Attribute name: adef name value: adef default)]
			    ifFalse: 
				[adef isRequired 
				    ifTrue: 
					[self 
					    invalid: '"%1" elements are required to have a "%2" attribute' % 
							{tag asString.
							adef name asString}]]]
		    ifFalse: [adef validateValueOf: a for: self]].
	^attributeList size = 0 ifTrue: [nil] ifFalse: [attributeList]
    ]

    checkUnresolvedIDREFs [
	<category: 'IDs'>
	(self isValidating and: [unresolvedIDREFs isEmpty not]) 
	    ifTrue: 
		[self invalid: 'The IDREFs %1 have not been resolved to IDs' 
			    % {unresolvedIDREFs asSortedCollection asArray}]
    ]

    registerID: attribute [
	<category: 'IDs'>
	latestID := attribute value.
	(definedIDs includes: latestID) 
	    ifTrue: [self invalid: 'The id "%1" was used more than once' % {latestID}].
	definedIDs add: latestID.
	unresolvedIDREFs remove: latestID ifAbsent: []
    ]

    rememberIDREF: anID [
	<category: 'IDs'>
	(definedIDs includes: anID) ifFalse: [unresolvedIDREFs add: anID]
    ]

    atEnd [
	<category: 'streaming'>
	
	[sourceStack == nil ifTrue: [^true].
	sourceStack atEnd] whileTrue: 
		    [sourceStack close.
		    sourceStack := sourceStack nextLink].
	^false
    ]

    forceSpace [
	<category: 'streaming'>
	self skipSpace ifFalse: [self expectedWhitespace]
    ]

    forceSpaceInDTD [
	<category: 'streaming'>
	self skipSpaceInDTD ifFalse: [self expectedWhitespace]
    ]

    getNextChar [
	<category: 'streaming'>
	^hereChar := self nextChar
    ]

    mustFind: str [
	<category: 'streaming'>
	(self skipIf: str) ifFalse: [self expected: str]
    ]

    nextChar [
	<category: 'streaming'>
	| ch |
	self atEnd ifTrue: [^nil].
	lastSource := currentSource.
	currentSource := sourceStack.
	ch := currentSource next.
	^ch
    ]

    skipIf: str [
	<category: 'streaming'>
	| p oc l c |
	hereChar = str first ifFalse: [^false].
	p := self sourceWrapper stream position.
	l := self sourceWrapper line.
	c := self sourceWrapper column.
	oc := hereChar.
	1 to: str size
	    do: 
		[:i | 
		hereChar = (str at: i) 
		    ifFalse: 
			[self sourceWrapper stream position: p.
			(self sourceWrapper)
			    line: l;
			    column: c.
			hereChar := oc.
			^false].
		lastSource := currentSource.
		currentSource := self sourceWrapper.
		hereChar := self sourceWrapper next].
	hereChar == nil ifTrue: [self getNextChar].
	^true
    ]

    skipSpace [
	<category: 'streaming'>
	| n |
	n := 0.
	[hereChar ~~ nil and: [#(9 10 13 32) includes: hereChar asInteger]] 
	    whileTrue: 
		[n := n + 1.
		self getNextChar].
	^n > 0
    ]

    skipSpaceInDTD [
	<category: 'streaming'>
	| space |
	space := self skipSpace.
	[self PERef: #dtd] whileTrue: [space := self skipSpace | space].
	^space
    ]

    upTo: aCharacter [
	"Answer a subcollection from position to the occurrence (if any, exclusive) of anObject.
	 The stream is left positioned after anObject.
	 If anObject is not found answer everything."

	<category: 'streaming'>
	| newStream element |
	newStream := (String new: 64) writeStream.
	[self atEnd] whileFalse: 
		[element := self nextChar.
		element = aCharacter ifTrue: [^newStream contents].
		newStream nextPut: element].
	self expected: (String with: aCharacter).
	^newStream contents
    ]

    upToAll: target [
	"Answer a subcollection from the current position
	 up to the occurrence (if any, not inclusive) of target,
	 and leave the stream positioned before the occurrence.
	 If no occurrence is found, answer the entire remaining
	 stream contents, and leave the stream positioned at the end.
	 We are going to cheat here, and assume that the first
	 character in the target only occurs once in the target, so
	 that we don't have to backtrack."

	<category: 'streaming'>
	| str i |
	(target occurrencesOf: target first) = 1 
	    ifFalse: [self error: 'The target collection is ambiguous.'].
	self sourceWrapper skip: -1.
	str := (String new: 32) writeStream.
	
	[str nextPutAll: (self upTo: target first).
	i := 2.
	[i <= target size and: [self nextChar = (target at: i)]] 
	    whileTrue: [i := i + 1].
	i <= target size] 
		whileTrue: 
		    [str nextPutAll: (target copyFrom: 1 to: i - 1).
		    self sourceWrapper skip: -1].
	self getNextChar.
	^str contents
    ]

    closeAllFiles [
	<category: 'private'>
	self fullSourceStack do: [:str | str close]
    ]

    fullSourceStack [
	<category: 'private'>
	| out s |
	out := OrderedCollection new.
	s := sourceStack.
	[s == nil] whileFalse: 
		[out addFirst: s.
		s := s nextLink].
	^out
    ]

    getQualifiedName [
	<category: 'private'>
	| nm |
	nm := self getSimpleName.
	^hereChar = $: 
	    ifTrue: 
		[self getNextChar.
		NodeTag new 
		    qualifier: nm
		    ns: ''
		    type: self getSimpleName]
	    ifFalse: 
		[NodeTag new 
		    qualifier: ''
		    ns: ''
		    type: nm]
    ]

    getSimpleName [
	<category: 'private'>
	(self isValidNameStart: hereChar) 
	    ifFalse: [^self malformed: 'An XML name was expected'].
	nameBuffer reset.
	nameBuffer nextPut: hereChar.
	
	[self getNextChar.
	hereChar notNil and: [self isValidNameChar: hereChar]] 
		whileTrue: [nameBuffer nextPut: hereChar].
	^nameBuffer contents
    ]

    isValidNameChar: c [
	<category: 'private'>
	^c = $: 
	    ifTrue: [self processNamespaces not]
	    ifFalse: [((CharacterClasses at: c asInteger + 1) bitAnd: 2) = 2]
    ]

    isValidNameStart: c [
	<category: 'private'>
	^c = $: 
	    ifTrue: [self processNamespaces not]
	    ifFalse: [((CharacterClasses at: c asInteger + 1) bitAnd: 4) = 4]
    ]

    nmToken [
	<category: 'private'>
	((self isValidNameChar: hereChar) or: [hereChar = $:]) 
	    ifFalse: [^self malformed: 'An XML NmToken was expected'].
	buffer reset.
	buffer nextPut: hereChar.
	
	[self getNextChar.
	hereChar notNil 
	    and: [(self isValidNameChar: hereChar) or: [hereChar = $:]]] 
		whileTrue: [buffer nextPut: hereChar].
	^buffer contents
    ]

    validateEncoding: encName [
	<category: 'private'>
	| c |
	encName size = 0 
	    ifTrue: [self malformed: 'A non-empty encoding name was expected'].
	c := encName first.
	(c asInteger < 128 and: [c isLetter]) 
	    ifFalse: 
		[self 
		    malformed: 'The first letter of the encoding ("%1") must be an ASCII alphabetic letter' 
			    % {encName}].
	2 to: encName size
	    do: 
		[:i | 
		c := encName at: i.
		(c asInteger < 128 
		    and: [c isLetter or: [c isDigit or: ['._-' includes: c]]]) 
			ifFalse: 
			    [self 
				malformed: 'A letter in the encoding name ("%1") must be ''.'', ''_'', ''-'', or an ASCII letter or digit' 
					% {encName}]]
    ]

    with: list add: node [
	<category: 'private'>
	node isDiscarded ifFalse: [list add: node]
    ]

    flagsComment [
	"The 'flags' instance variable is an integer used
	 as a bit vector of boolean values, either recording
	 state as processing occurs, or recording options
	 that control how the processor is used. The following
	 documents which bits have been assigned and for
	 which purpose.
	 
	 Additional state bits [0..15]
	 0 -- parser is currently inside an <![IGNORE[ section
	 "

	<category: 'flags'>
	^self commentOnly
    ]

    ignore [
	<category: 'flags'>
	^(flags bitAnd: 1) = 1
    ]

    ignore: aBoolean [
	<category: 'flags'>
	^aBoolean 
	    ifTrue: [flags := flags bitOr: 1]
	    ifFalse: [flags := flags bitAnd: 1 bitInvert]
    ]

    correctAttributeTag: attribute [
	<category: 'namespaces'>
	| ns tag qual type |
	qual := attribute tag qualifier.
	qual isEmpty ifTrue: [^self].
	type := attribute tag type.
	ns := self findNamespace: qual.
	tag := NodeTag new 
		    qualifier: qual
		    ns: ns
		    type: type.
	attribute tag: tag
    ]

    correctTag: tag [
	<category: 'namespaces'>
	| ns type qualifier |
	qualifier := tag qualifier.
	type := tag type.
	ns := self findNamespace: qualifier.
	^NodeTag new 
	    qualifier: qualifier
	    ns: ns
	    type: type
    ]

    findNamespace: ns [
	<category: 'namespaces'>
	| nsURI |
	ns = 'xml' ifTrue: [^XML_URI].
	ns = 'xmlns' ifTrue: [^'<!-- xml namespace -->'].
	elementStack size to: 1
	    by: -1
	    do: 
		[:i | 
		nsURI := (elementStack at: i) findNamespace: ns.
		nsURI = nil ifFalse: [^nsURI]].
	^ns = '' 
	    ifTrue: ['']
	    ifFalse: 
		[self 
		    invalid: 'The namespace qualifier %1 has not been bound to a namespace URI' 
			    % {ns}]
    ]

    resolveNamespaces: attributes [
	<category: 'namespaces'>
	| newAttributes showDecls t1 t2 k |
	self processNamespaces ifFalse: [^attributes].
	showDecls := self showNamespaceDeclarations.
	attributes == nil 
	    ifTrue: [newAttributes := #()]
	    ifFalse: 
		[newAttributes := OrderedCollection new: attributes size.
		attributes do: 
			[:attr | 
			| save |
			save := showDecls.
			attr tag qualifier = 'xmlns' 
			    ifTrue: [elementStack last defineNamespace: attr from: self]
			    ifFalse: 
				[(attr tag isLike: 'xmlns') 
				    ifTrue: [elementStack last defineDefaultNamespace: attr]
				    ifFalse: [save := true]].
			save ifTrue: [newAttributes add: attr]].
		newAttributes do: [:attr | self correctAttributeTag: attr].
		1 to: newAttributes size
		    do: 
			[:i | 
			t1 := (newAttributes at: i) tag.
			k := i + 1.
			[k <= newAttributes size] whileTrue: 
				[t2 := (newAttributes at: k) tag.
				(t1 type = t2 type and: [t1 namespace = t2 namespace]) 
				    ifTrue: 
					[self 
					    malformed: 'The attributes "%1" and "%2" have the same namespace and type' 
						    % 
							{t1 asString.
							t2 asString}.
					k := newAttributes size].
				k := k + 1]]].
	elementStack last tag: (self correctTag: elementStack last tag).
	^newAttributes isEmpty ifTrue: [nil] ifFalse: [newAttributes asArray]
    ]

    parseElement [
	<category: 'SAX accessing'>
	^
	[sax startDocumentFragment.
	self getNextChar.
	hereChar = $< ifFalse: [self expected: '<'].
	self getElement.
	sax endDocumentFragment.
	sax document == nil ifTrue: [nil] ifFalse: [sax document elements first]] 
		ifCurtailed: [self closeAllFiles]
    ]

    parseElements [
	<category: 'SAX accessing'>
	^
	[sax startDocumentFragment.
	self prolog.
	[self atEnd] whileFalse: 
		[self getElement.
		[self misc] whileTrue].
	sax endDocumentFragment.
	sax document == nil ifTrue: [nil] ifFalse: [sax document elements]] 
		ifCurtailed: [self closeAllFiles]
    ]
]


ElementContext extend [
    followSetDescription [
        <category: 'accessing'>
        | types |
        self types isNil ifTrue: [ ^'()' ].
        types := IdentitySet new.
        self types do: [:tp | types addAll: tp followSet].
        ^types asArray printString
    ]

    canTerminate [
        <category: 'testing'>
        self types isNil ifTrue: [ ^true ].
        self types do: [:i | i canTerminate ifTrue: [^true]].
        ^false
    ]

    validateTag: nm [
	<category: 'testing'>
	| types |
	types := IdentitySet new.
	self types do: 
		[:i | 
		| t |
		t := i validateTag: nm.
		t == nil ifFalse: [types addAll: t]].
	^types isEmpty ifTrue: [nil] ifFalse: [types asArray]
    ]

    validateText: data from: start to: stop testBlanks: testBlanks [
	<category: 'testing'>
	| types |
	types := IdentitySet new.
	self types do: 
		[:i | 
		| t |
		t := i 
			    validateText: data
			    from: start
			    to: stop
			    testBlanks: testBlanks.
		t == nil ifFalse: [types add: t]].
	^types isEmpty ifTrue: [nil] ifFalse: [types asArray]
    ]
]

GeneralEntity extend [
    completeValidationAgainst: aParser [
	<category: 'validation'>
	ndata isNil 
	    ifFalse: 
		[aParser dtd notationAt: ndata
		    ifAbsent: 
			[aParser 
			    invalid: 'Unparsed entity "%1" uses an undeclared notation "%2"' % 
					{name.
					ndata}]]
    ]
]

DocumentType extend [
    | attributeDefs elementDefs |
    attributeFor: key subKey: k2 from: anErrorReporter [
        <category: 'accessing'>
        | val |
        attributeDefs isNil
            ifTrue:
                [anErrorReporter
                    invalid: 'The attribute "%1 %2" has not been defined' %
                                {key asString.
                                k2 asString}].
        (val := attributeDefs at: key asString ifAbsent: []) == nil
            ifTrue:
                [anErrorReporter
                    invalid: 'The attribute "%1 %2" has not been defined' %
                                {key asString.
                                k2 asString}].
        ^val at: k2 asString
            ifAbsent:
                [anErrorReporter
                    invalid: 'The attribute "%1 %2" has not been defined' %
                                {key asString.
                                k2 asString}]
    ]

    attributeFor: key subKey: k2 put: value from: anErrorReporter [
       <category: 'accessing'>
       | dict |
       dict := self attributesFor: key.
       (dict includesKey: k2 asString) 
           ifTrue: 
               [^anErrorReporter 
                   warn: 'The attribute "%1 %2" has been defined more than once' % 
                               {key asString.
                               k2 asString}].
       (value type isID and: [dict contains: [:attr | attr type isID]]) 
           ifTrue: 
               [^anErrorReporter 
                   invalid: 'The element %1 has two attributes typed as ID' % {key asString}].
       dict at: k2 asString put: value
    ]

    attributeTypeFor: key subKey: k2 from: anErrorReporter [
        | val |
        attributeDefs == nil
            ifTrue: [^CDATA_AT new].
        (val := attributeDefs at: key asString ifAbsent: []) == nil
            ifTrue: [^CDATA_AT new].
        ^(val at: k2 asString
            ifAbsent: [^CDATA_AT new]) type
    ]

    attributesFor: key [
        <category: 'accessing'>
        attributeDefs isNil ifTrue: [attributeDefs := Dictionary new].
        ^attributeDefs at: key asString ifAbsentPut: [Dictionary new]
    ]

    completeValidationAgainst: aParser [
        <category: 'private'>
        generalEntities
            keysAndValuesDo: [:eName :entity | entity completeValidationAgainst: aParser].
        attributeDefs keysAndValuesDo:
                [:eName :attribs |
                attribs
                    keysAndValuesDo: [:aName :attrib | attrib completeValidationAgainst: aParser]]
    ]

    elementFor: key from: anErrorReporter [
        <category: 'accessing'>
        | val |
        elementDefs isNil
            ifTrue:
                [anErrorReporter
                    warn: 'The element "%1" has not been defined' % {key asString}].
        (val := elementDefs at: key asString ifAbsent: []) == nil
            ifTrue:
                [anErrorReporter
                    warn: 'The element "%1" has not been defined' % {key asString}].
        ^val
    ]

    elementFor: key put: value from: anErrorReporter [
        <category: 'accessing'>
        elementDefs isNil
            ifTrue: [elementDefs := Dictionary new].
        (elementDefs includesKey: key asString)
            ifTrue:
                [| msg |
                msg := 'The element "%1" has been defined more than once' % {key asString}.
                anErrorReporter isValidating
                    ifTrue: [anErrorReporter invalid: msg]
                    ifFalse: [anErrorReporter warn: msg]].
        elementDefs at: key asString put: value
    ]
]


Eval [
    XML at: #CharacterClasses put: XMLParser characterTable.
    SAXParser defaultParserClass isNil
	ifTrue: [SAXParser defaultParserClass: XMLParser].
]

