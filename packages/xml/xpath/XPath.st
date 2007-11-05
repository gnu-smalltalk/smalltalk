"======================================================================
|
|   VisualWorks XPath Framework
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



Namespace current: XML [

Object subclass: XPathNodeContext [
    | documentOrder nodes index node baseNode variables |
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathNodeContext class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    add: aNode [
	<category: 'adding'>
	nodes add: aNode
    ]

    addAll: collection [
	<category: 'adding'>
	nodes addAll: collection
    ]

    addNodeSet: nodeSet [
	<category: 'adding'>
	nodes addAll: nodeSet unsortedNodes
    ]

    addToXPathHolder: anAssociation for: aNodeContext [
	<category: 'enumerating'>
	self 
	    error: 'Should not happen--a NodeSet is being processed as if it were a single XML node'
    ]

    select: aPattern [
	<category: 'enumerating'>
	| result val |
	aPattern xpathMayRequireSortTopLevel 
	    ifTrue: [self checkSorted]
	    ifFalse: [self checkOrdered].
	result := self copy.
	self reset.
	[self atEnd] whileFalse: 
		[val := aPattern xpathEvalIn: self next.
		(val xpathIsNumber ifTrue: [val = self index] ifFalse: [val xpathAsBoolean]) 
		    ifTrue: [result add: self node]].
	^result
    ]

    selectMatch: aPattern [
	<category: 'enumerating'>
	| result |
	result := self copy.
	self reset.
	[self atEnd] 
	    whileFalse: [(aPattern match: self next) ifTrue: [result add: self node]].
	^result
    ]

    asSingleNode [
	<category: 'copying'>
	^(self copy)
	    add: self node;
	    yourself
    ]

    copy [
	<category: 'copying'>
	^self shallowCopy postCopy
    ]

    postCopy [
	<category: 'copying'>
	nodes := IdentitySet new.
	index := 0.
	node := nil.
	documentOrder := true
    ]

    atEnd [
	<category: 'streaming'>
	^index = nodes size
    ]

    next [
	<category: 'streaming'>
	index = nodes size ifTrue: [^nil].
	self index: index + 1.
	node := nodes at: index.
	^self
    ]

    reset [
	<category: 'streaming'>
	index := 0.
	node := nil
    ]

    baseNode [
	<category: 'accessing'>
	^baseNode
    ]

    baseNode: aNode [
	<category: 'accessing'>
	baseNode := aNode
    ]

    documentOrder [
	<category: 'accessing'>
	documentOrder := true
    ]

    index [
	<category: 'accessing'>
	^index
    ]

    index: n [
	<category: 'accessing'>
	self checkSorted.
	(n < 1 or: [n > nodes size]) ifTrue: [self error: 'Index out of bounds'].
	index := n.
	node := nodes at: n
    ]

    indexForNode: aNode [
	<category: 'accessing'>
	self checkSorted.
	index := nodes identityIndexOf: aNode.
	index = 0 ifTrue: [self error: 'No such node found in the list'].
	node := aNode
    ]

    inverseDocumentOrder [
	<category: 'accessing'>
	documentOrder := false
    ]

    node [
	<category: 'accessing'>
	^node
    ]

    size [
	<category: 'accessing'>
	^nodes size
    ]

    sort: aBlock [
	<category: 'accessing'>
	nodes := nodes asSortedCollection: aBlock
    ]

    sortedNodes [
	<category: 'accessing'>
	^nodes asSortedCollection: [:n1 :n2 | n1 precedes: n2]
    ]

    unsortedNodes [
	<category: 'accessing'>
	^nodes
    ]

    variables [
	<category: 'accessing'>
	^variables
    ]

    variables: aDictionary [
	<category: 'accessing'>
	variables := aDictionary
    ]

    checkOrdered [
	<category: 'initialize'>
	nodes class == IdentitySet ifTrue: [nodes := nodes asArray]
    ]

    checkSorted [
	<category: 'initialize'>
	nodes class == IdentitySet 
	    ifTrue: 
		[nodes size < 4 
		    ifTrue: 
			[nodes := documentOrder 
				    ifTrue: [nodes asSortedCollection: [:n1 :n2 | n1 precedes: n2]]
				    ifFalse: [nodes asSortedCollection: [:n1 :n2 | n2 precedes: n1]]]
		    ifFalse: 
			[nodes := nodes asArray collect: [:nd | XPathSortingVector fromXmlNode: nd].
			nodes := documentOrder 
				    ifTrue: [nodes asSortedCollection: [:n1 :n2 | n1 <= n2]]
				    ifFalse: [nodes asSortedCollection: [:n1 :n2 | n2 <= n1]].
			nodes := nodes collect: [:nd | nd value]]]
    ]

    ensureSorted [
	<category: 'initialize'>
	nodes class == IdentitySet 
	    ifFalse: 
		[self 
		    error: 'This collection was already sorted once and may not be in correct sort order'].
	self checkSorted
    ]

    initialize [
	<category: 'initialize'>
	nodes := IdentitySet new.
	documentOrder := true
    ]

    contains: aBlock [
	<category: 'testing'>
	| match |
	match := nodes detect: aBlock ifNone: [].
	^match notNil
    ]

    xpathIsNodeSet [
	<category: 'testing'>
	^true
    ]

    printOn: aStream [
	<category: 'printing'>
	self basicPrintOn: aStream
    ]

    sum [
	<category: 'functions'>
	^nodes inject: 0.0 into: [:i :nd | i + nd xpathStringData xpathAsNumber]
    ]

    xpathAsBoolean [
	<category: 'coercing'>
	^self size > 0
    ]

    xpathAsNumber [
	<category: 'coercing'>
	^self xpathAsString xpathAsNumber
    ]

    xpathAsString [
	<category: 'coercing'>
	| list |
	nodes size = 0 ifTrue: [^''].
	list := nodes asSortedCollection: [:n1 :n2 | n1 precedes: n2].
	^list first xpathStringData
    ]

    xpathCompareEquality: aData using: aBlock [
	<category: 'comparing'>
	aData isString 
	    ifTrue: 
		[^nodes contains: [:nd | aBlock value: nd xpathStringData value: aData]].
	aData xpathIsNumber 
	    ifTrue: 
		[^nodes 
		    contains: [:nd | aBlock value: nd xpathStringData xpathAsNumber value: aData]].
	aData xpathIsBoolean 
	    ifTrue: 
		[^nodes 
		    contains: [:nd | aBlock value: nd xpathStringData xpathAsBoolean value: aData]].
	aData xpathIsNodeSet 
	    ifTrue: 
		[^nodes contains: 
			[:nd1 | 
			aData unsortedNodes 
			    contains: [:nd2 | aBlock value: nd1 xpathStringData value: nd2 xpathStringData]]].
	self error: 'Can''t compare a %1 with a node set' % {aData class}
    ]

    xpathCompareOrder: aData using: aBlock [
	<category: 'comparing'>
	^aData xpathIsNodeSet 
	    ifTrue: 
		[self unsortedNodes contains: 
			[:nd1 | 
			| v |
			v := nd1 xpathStringData xpathAsNumber.
			aData unsortedNodes 
			    contains: [:nd2 | aBlock value: v value: nd2 xpathStringData xpathAsNumber]]]
	    ifFalse: 
		[| v |
		v := aData xpathAsNumber.
		self unsortedNodes 
		    contains: [:nd | aBlock value: nd xpathStringData xpathAsNumber value: v]]
    ]
]

]



Namespace current: XML [

ReadStream subclass: XPathReadStream [
    
    <category: 'XML-XPath'>
    <comment: nil>

    pastEnd [
	"The receiver has attempted to read past the end, answer nil."

	<category: 'private'>
	^nil
    ]
]

]



Namespace current: XML [

Object subclass: XPathExpression [
    | predicates child |
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathExpression class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    XPathExpression class >> notANumber [
	<category: 'coercing'>
	^FloatD nan
    ]

    XPathExpression class >> stringToNumber: aString [
	<category: 'coercing'>
	| s foundDigit numerator denominator ch |
	s := aString readStream.
	s skipSeparators.
	foundDigit := false.
	numerator := 0.
	denominator := 1.
	[(ch := s next) notNil and: [ch isDigit]] whileTrue: 
		[numerator := numerator * 10 + ch digitValue.
		foundDigit := true].
	ch = $. 
	    ifTrue: 
		[[(ch := s next) notNil and: [ch isDigit]] whileTrue: 
			[numerator := numerator * 10 + ch digitValue.
			denominator := denominator * 10.
			foundDigit := true]].
	(ch == nil or: [ch isSeparator]) ifFalse: [^self notANumber].
	s skipSeparators.
	s atEnd ifFalse: [^self notANumber].
	foundDigit ifFalse: [^self notANumber].
	^numerator / denominator + 0.0
    ]

    addPredicate: aPredicate [
	<category: 'accessing'>
	predicates := predicates copyWith: aPredicate
    ]

    asUnion [
	<category: 'accessing'>
	^XPathUnion new add: self
    ]

    child [
	<category: 'accessing'>
	^child
    ]

    child: aStep [
	<category: 'accessing'>
	child := aStep
    ]

    enumerate: aBlock [
	<category: 'accessing'>
	aBlock value: self.
	predicates do: [:p | p enumerate: aBlock].
	child enumerate: aBlock
    ]

    predicates [
	<category: 'accessing'>
	^predicates
    ]

    xpathUsedVarNames [
	<category: 'accessing'>
	| list |
	list := OrderedCollection new.
	self 
	    enumerate: [:exp | (exp isKindOf: XPathVariable) ifTrue: [list add: exp name]].
	^list
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	self subclassResponsibility
    ]

    isMatchFor: anXmlNode [
	<category: 'matching'>
	^self isLocalMatchFor: anXmlNode
    ]

    match: aNodeContext [
	<category: 'matching'>
	| base |
	base := self.
	[base child == nil] whileFalse: [base := base child].
	^base 
	    simpleMatchFor: aNodeContext node
	    isComplex: false
	    do: 
		[:root :complex | 
		| ns found |
		complex not or: 
			[ns := (aNodeContext copy)
				    add: root;
				    index: 1.
			found := false.
			self valueIn: ns
			    do: [:nd | nd == aNodeContext node ifTrue: [found := true]].
			found]]
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	^self subclassResponsibility
    ]

    valueIn: aNodeContext do: aBlock [
	<category: 'matching'>
	| result |
	result := self baseValueIn: aNodeContext.
	result xpathIsNodeSet 
	    ifTrue: 
		[1 to: predicates size
		    do: [:i | result := result select: (predicates at: i)].
		result reset.
		[result atEnd] whileFalse: [child valueIn: result next do: aBlock]]
	    ifFalse: 
		[(predicates isEmpty and: [child isTerminator]) 
		    ifTrue: [aBlock value: result]
		    ifFalse: [self error: 'The expression %1 does not represent a node set']]
    ]

    xpathEvalIn: aNodeContext [
	"This is private protocol--see #xpathValueIn: for the client protocol"

	<category: 'matching'>
	| nc |
	nc := Association new.
	self valueIn: aNodeContext
	    do: [:x | x addToXPathHolder: nc for: aNodeContext].
	^nc value == nil ifTrue: [aNodeContext copy] ifFalse: [nc value]
    ]

    xpathValueFor: anXmlNode variables: vars [
	<category: 'matching'>
	^self xpathValueIn: ((XPathNodeContext new)
		    add: anXmlNode;
		    index: 1;
		    variables: vars)
    ]

    xpathValueIn: aNodeContext [
	"This is public protocol only--see #xpathEvalIn: for internal clients"

	<category: 'matching'>
	aNodeContext baseNode: aNodeContext node.
	^self xpathEvalIn: aNodeContext
    ]

    completeChildPrintOn: aStream [
	<category: 'printing'>
	self completePrintOn: aStream
    ]

    completePrintOn: aStream [
	<category: 'printing'>
	self printTestOn: aStream.
	predicates do: [:p | self printPredicate: p on: aStream].
	self child isTerminator ifFalse: [aStream nextPut: $/].
	self child completeChildPrintOn: aStream
    ]

    printOn: aStream [
	<category: 'printing'>
	self completePrintOn: aStream
    ]

    printPredicate: p on: aStream [
	<category: 'printing'>
	aStream nextPutAll: '['.
	aStream print: p.
	aStream nextPutAll: ']'
    ]

    printTestOn: aStream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'initialize'>
	predicates := #().
	child := XPathTerminator new.
	child parent: self
    ]

    xpathMayRequireNodeSet [
	<category: 'testing'>
	^self subclassResponsibility
    ]

    xpathMayRequireNodeSetTopLevel [
	<category: 'testing'>
	^self subclassResponsibility
    ]

    xpathMayRequireSort [
	<category: 'testing'>
	^self subclassResponsibility
    ]

    xpathMayRequireSortTopLevel [
	<category: 'testing'>
	^self subclassResponsibility
    ]
]

]



Namespace current: XML [

XPathExpression subclass: XPathUnion [
    | arguments |
    
    <category: 'XML-XPath'>
    <comment: nil>

    add: aNode [
	<category: 'accessing'>
	arguments := arguments copyWith: aNode
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    asUnion [
	<category: 'accessing'>
	^self
    ]

    enumerate: aBlock [
	<category: 'accessing'>
	super enumerate: aBlock.
	arguments do: [:a | a enumerate: aBlock]
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nc |
	nc := aNodeContext copy documentOrder.
	1 to: arguments size
	    do: [:a | nc addNodeSet: ((arguments at: a) xpathEvalIn: aNodeContext)].
	^nc
    ]

    match: aNodeContext [
	<category: 'matching'>
	1 to: arguments size
	    do: [:a | ((arguments at: a) match: aNodeContext) ifTrue: [^true]].
	^false
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	arguments := #()
    ]

    printTestOn: aStream [
	<category: 'printing'>
	arguments do: [:a | aStream print: a]
	    separatedBy: [aStream nextPutAll: '|']
    ]
]

]



Namespace current: XML [

XPathExpression subclass: XPathStep [
    | axisName baseTest namespace type parent |
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathStep class >> axisNames [
	<category: 'private'>
	^#()
    ]

    axisName [
	<category: 'accessing'>
	^axisName
    ]

    axisName: aName [
	<category: 'accessing'>
	axisName := aName
    ]

    baseTest [
	<category: 'accessing'>
	^baseTest
    ]

    baseTest: aNodeTest [
	<category: 'accessing'>
	baseTest := aNodeTest
    ]

    child [
	<category: 'accessing'>
	^child
    ]

    child: aStep [
	<category: 'accessing'>
	child := aStep
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aStep [
	<category: 'accessing'>
	parent := aStep
    ]

    startOfPath [
	<category: 'accessing'>
	| p |
	p := self.
	[p isStartOfPath] whileFalse: [p := p parent].
	^p
    ]

    hasComplexPredicate [
	<category: 'testing'>
	^predicates inject: false
	    into: [:b :exp | b or: [exp xpathMayRequireNodeSetTopLevel]]
    ]

    isStartOfPath [
	<category: 'testing'>
	^parent == nil
    ]

    isTerminator [
	<category: 'testing'>
	^false
    ]

    xpathMayRequireNodeSet [
	<category: 'testing'>
	^false
    ]

    xpathMayRequireNodeSetTopLevel [
	<category: 'testing'>
	^false
    ]

    xpathMayRequireSort [
	<category: 'testing'>
	^false
    ]

    xpathMayRequireSortTopLevel [
	<category: 'testing'>
	^false
    ]

    printTestOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self axisName , '::'.
	baseTest printOn: aStream
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathParentNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathParentNode class >> axisNames [
	<category: 'private'>
	^#('parent')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| result |
	result := aNodeContext copy documentOrder.
	(baseTest match: aNodeContext node parent) 
	    ifTrue: [result add: aNodeContext node parent].
	^result
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathPrecedingNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathPrecedingNode class >> axisNames [
	<category: 'private'>
	^#('preceding')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc |
	nd := aNodeContext node.
	nc := aNodeContext copy inverseDocumentOrder.
	self from: nd do: [:nd1 | (baseTest match: nd1) ifTrue: [nc add: nd1]].
	^nc
    ]

    from: aNode do: aBlock [
	<category: 'matching'>
	| current stack ignoreAll |
	ignoreAll := IdentitySet new.
	stack := OrderedCollection new.
	current := aNode.
	
	[ignoreAll add: current.
	current isDocument not] whileTrue: 
		    [stack 
			addFirst: current parent -> (current parent children indexOf: current).
		    current := current parent].
	current := aNode.
	
	[current isDocument 
	    ifTrue: [^self]
	    ifFalse: 
		[stack last value = 1 
		    ifTrue: [current := stack removeLast key]
		    ifFalse: 
			[stack last value: stack last value - 1.
			current := stack last key children at: stack last value.
			[current isElement and: [current children isEmpty not]] whileTrue: 
				[stack add: current -> current children size.
				current := current children last]]].
	(ignoreAll includes: current) ifFalse: [aBlock value: current]] 
		repeat
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathAncestorNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathAncestorNode class >> axisNames [
	<category: 'private'>
	^#('ancestor' 'ancestor-or-self')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc nextNode |
	nd := aNodeContext node.
	nc := aNodeContext copy inverseDocumentOrder.
	self axisName = 'ancestor-or-self' 
	    ifTrue: [nextNode := nd]
	    ifFalse: [nextNode := nd parent].
	[nextNode == nil] whileFalse: 
		[(baseTest match: nextNode) ifTrue: [nc add: nextNode].
		nextNode := nextNode parent].
	^nc
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathChildNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathChildNode class >> axisNames [
	<category: 'private'>
	^#('child')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc |
	nd := aNodeContext node.
	nc := aNodeContext copy documentOrder.
	(nd isElement or: [nd isDocument]) ifFalse: [^nc].
	aNodeContext node children 
	    do: [:childNode | (baseTest match: childNode) ifTrue: [nc add: childNode]].
	^nc
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	| hasCP set |
	anXmlNode isAttribute ifTrue: [^false].
	(baseTest match: anXmlNode) ifFalse: [^false].
	(hasCP := self hasComplexPredicate) 
	    ifFalse: 
		[set := XPathNodeContext new add: anXmlNode.
		1 to: predicates size do: [:i | set := set select: (predicates at: i)].
		set size = 0 ifTrue: [^false]].
	parent == nil 
	    ifTrue: [^aBlock value: anXmlNode parent value: complex | hasCP].
	^parent 
	    simpleMatchFor: anXmlNode parent
	    isComplex: complex | hasCP
	    do: aBlock
    ]

    printTestOn: aStream [
	<category: 'printing'>
	axisName == nil 
	    ifTrue: [baseTest printOn: aStream]
	    ifFalse: [super printTestOn: aStream]
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathFollowingNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathFollowingNode class >> axisNames [
	<category: 'private'>
	^#('following')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc |
	nd := aNodeContext node.
	nc := aNodeContext copy documentOrder.
	self from: nd do: [:nd1 | (baseTest match: nd1) ifTrue: [nc add: nd1]].
	^nc
    ]

    from: aNode do: aBlock [
	<category: 'matching'>
	| current stack idx followChildren |
	current := aNode.
	stack := OrderedCollection new.
	current isDocument 
	    ifFalse: 
		[[current parent isDocument not] whileTrue: 
			[stack 
			    addFirst: current parent -> (current parent children indexOf: current).
			current := current parent]].
	current := aNode.
	"By setting followChildren to false the first time only, we ignore
	 all descendents of aNode."
	followChildren := false.
	
	[(followChildren and: 
		[(current isElement or: [current isDocument]) 
		    and: [current children size > 0]]) 
	    ifTrue: 
		[stack add: current -> 1.
		current := current children at: 1]
	    ifFalse: 
		[
		[stack isEmpty ifTrue: [^self].
		stack last key children size > stack last value] 
			whileFalse: [current := stack removeLast key].
		stack last value: (idx := stack last value + 1).
		current := stack last key children at: idx].
	followChildren := true.
	aBlock value: current] 
		repeat
    ]
]

]



Namespace current: XML [

XPathExpression subclass: XPathVariable [
    | name |
    
    <category: 'XML-XPath'>
    <comment: nil>

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| var |
	var := aNodeContext variables at: self name
		    ifAbsent: [self error: 'No binding found for the variable $%1' % {self name}].
	^var
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aName [
	<category: 'accessing'>
	name := aName
    ]

    printTestOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: '$' , name
    ]
]

]



Namespace current: XML [

XPathExpression subclass: XPathFunction [
    | name arguments valueBlock requiresSort requiresNodeSet |
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathFunction class [
	| functions |
	
    ]

    XPathFunction class >> baseFunctions [
	<category: 'class initialization'>
	^functions
    ]

    XPathFunction class >> initialize [
	"XPathFunction initialize"

	<category: 'class initialization'>
	functions == nil 
	    ifTrue: [functions := Dictionary new]
	    ifFalse: [functions keys do: [:k | functions removeKey: k]].
	self initializeBoolean.
	self initializeStrings.
	self initializeNodeSets.
	self initializeNumeric
    ]

    XPathFunction class >> initializeBoolean [
	<category: 'class initialization'>
	functions at: 'boolean'
	    put: ((self new)
		    name: 'boolean';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'boolean() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathAsBoolean]).
	functions at: 'not'
	    put: ((self new)
		    name: 'not';
		    valueBlock: [:fn :ns | (fn arguments first xpathEvalIn: ns) xpathAsBoolean not]).
	functions at: 'true' put: true.
	functions at: 'false' put: false
    ]

    XPathFunction class >> initializeNodeSets [
	<category: 'class initialization'>
	functions at: 'count'
	    put: ((self new)
		    requiresNodeSet: true;
		    name: 'count';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'count() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathIsNodeSet 
				ifFalse: [self error: 'count() requires a nodeset as an argument'].
			    ns2 size]).
	functions at: 'position'
	    put: ((self new)
		    requiresNodeSet: true;
		    requiresSort: true;
		    name: 'position';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size > 0 
				ifTrue: [self error: 'position() cannot take any arguments'].
			    ns index]).
	functions at: 'last'
	    put: ((self new)
		    requiresNodeSet: true;
		    name: 'last';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size > 0 
				ifTrue: [self error: 'last() cannot take any arguments'].
			    ns size]).
	functions at: 'local-name'
	    put: ((self new)
		    name: 'local-name';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'local-name() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathIsNodeSet 
				ifFalse: [self error: 'local-name() requires a nodeset as an argument'].
			    ns2
				documentOrder;
				index: 1.
			    (ns2 node isElement or: [ns2 node isAttribute]) 
				ifTrue: [ns2 node tag type]
				ifFalse: ['']]).
	functions at: 'namespace-uri'
	    put: ((self new)
		    name: 'namespace-uri';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'namespace-uri() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathIsNodeSet 
				ifFalse: [self error: 'namespace-uri() requires a nodeset as an argument'].
			    ns2
				documentOrder;
				index: 1.
			    (ns2 node isElement or: [ns2 node isAttribute]) 
				ifTrue: [ns2 node tag namespace]
				ifFalse: ['']]).
	functions at: 'name'
	    put: ((self new)
		    name: 'name';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'name() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathIsNodeSet 
				ifFalse: [self error: 'name() requires a nodeset as an argument'].
			    ns2
				documentOrder;
				index: 1.
			    (ns2 node isElement or: [ns2 node isAttribute]) 
				ifTrue: [ns2 node tag asString]
				ifFalse: ['']]).
	functions at: 'id'
	    put: ((self new)
		    name: 'id';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size ~= 1 
				ifTrue: [self error: 'id() only takes one argument'].
			    ns2 := fn arguments first xpathEvalIn: ns.
			    ns2 := ns2 xpathAsString.
			    ns copy add: (ns node document atID: ns2
					ifAbsent: [self error: 'ID "' , ns2 , '" not found'])]).
	functions at: 'current'
	    put: ((self new)
		    requiresNodeSet: true;
		    name: 'current';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size > 0 ifTrue: [self error: 'current() takes no arguments'].
			    (ns copy)
				add: ns baseNode;
				index: 1])
    ]

    XPathFunction class >> initializeNumeric [
	<category: 'class initialization'>
	functions at: 'number'
	    put: ((self new)
		    name: 'number';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'number() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathAsNumber]).
	functions at: 'round'
	    put: ((self new)
		    name: 'round';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size ~= 1 
				ifTrue: [self error: 'round() only takes one argument'].
			    (fn arguments first xpathEvalIn: ns) xpathAsNumber rounded]).
	functions at: 'floor'
	    put: ((self new)
		    name: 'floor';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size ~= 1 
				ifTrue: [self error: 'floor() only takes one argument'].
			    (fn arguments first xpathEvalIn: ns) xpathAsNumber floor]).
	functions at: 'ceiling'
	    put: ((self new)
		    name: 'ceiling';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size ~= 1 
				ifTrue: [self error: 'ceiling() only takes one argument'].
			    (fn arguments first xpathEvalIn: ns) xpathAsNumber ceiling]).
	functions at: 'sum'
	    put: ((self new)
		    name: 'sum';
		    valueBlock: 
			    [:fn :ns | 
			    fn arguments size ~= 1 
				ifTrue: [self error: 'sum() only takes one argument'].
			    (fn arguments first xpathEvalIn: ns) sum])
    ]

    XPathFunction class >> initializeStrings [
	<category: 'class initialization'>
	functions at: 'string'
	    put: ((self new)
		    name: 'string';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    fn arguments size > 1 
				ifTrue: [self error: 'string() only takes one argument'].
			    ns2 := fn arguments size = 1 
					ifTrue: [fn arguments first xpathEvalIn: ns]
					ifFalse: [ns asSingleNode].
			    ns2 xpathAsString]).
	functions at: 'concat'
	    put: ((self new)
		    name: 'concat';
		    valueBlock: 
			    [:fn :ns | 
			    | s |
			    s := ''.
			    fn arguments do: [:exp | s := s , (exp xpathEvalIn: ns) xpathAsString].
			    s]).
	functions at: 'contains'
	    put: ((self new)
		    name: 'contains';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 s2 i |
			    fn arguments size = 2 
				ifFalse: [self error: 'contains() takes two arguments'].
			    s1 := (fn arguments at: 1) xpathEvalIn: ns.
			    s2 := (fn arguments at: 2) xpathEvalIn: ns.
			    i := s1 xpathAsString indexOfSubCollection: s2 xpathAsString startingAt: 1.
			    i > 0]).
	functions at: 'translate'
	    put: ((self new)
		    name: 'translate';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 s2 s3 |
			    fn arguments size = 3 
				ifFalse: [self error: 'translate() takes three arguments'].
			    s1 := (fn arguments at: 1) xpathEvalIn: ns.
			    s2 := (fn arguments at: 2) xpathEvalIn: ns.
			    s3 := (fn arguments at: 3) xpathEvalIn: ns.
			    self 
				translate: s1 xpathAsString
				from: s2 xpathAsString
				to: s3 xpathAsString]).
	functions at: 'string-length'
	    put: ((self new)
		    name: 'string-length';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 |
			    fn arguments size < 2 
				ifFalse: [self error: 'string-length() takes no more than 1 argument'].
			    s1 := (fn arguments size = 0 
					ifTrue: [ns asSingleNode]
					ifFalse: [fn arguments first xpathEvalIn: ns]) xpathAsString.
			    s1 size]).
	functions at: 'substring'
	    put: ((self new)
		    name: 'substring';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 i1 i2 |
			    (fn arguments size between: 2 and: 3) 
				ifFalse: [self error: 'substring() takes two or three arguments'].
			    s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
			    i1 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsNumber.
			    i2 := fn arguments size = 2 
					ifTrue: [10000000000.0]
					ifFalse: [((fn arguments at: 3) xpathEvalIn: ns) xpathAsNumber].
			    i2 := (i1 + i2 - 1) rounded min: s1 size.
			    i1 := i1 rounded max: 1.
			    s1 copyFrom: i1 to: i2]).
	functions at: 'starts-with'
	    put: ((self new)
		    name: 'starts-with';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 s2 |
			    fn arguments size = 2 
				ifFalse: [self error: 'starts-with() takes two arguments'].
			    s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
			    s2 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
			    (s1 indexOfSubCollection: s2 startingAt: 1) = 1]).
	functions at: 'substring-before'
	    put: ((self new)
		    name: 'substring-before';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 s2 i |
			    fn arguments size = 2 
				ifFalse: [self error: 'substring-before() takes two arguments'].
			    s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
			    s2 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
			    i := s1 indexOfSubCollection: s2 startingAt: 1.
			    i = 0 ifTrue: [''] ifFalse: [s1 copyFrom: 1 to: i - 1]]).
	functions at: 'substring-after'
	    put: ((self new)
		    name: 'substring-after';
		    valueBlock: 
			    [:fn :ns | 
			    | s1 s2 i |
			    fn arguments size = 2 
				ifFalse: [self error: 'substring-after() takes two arguments'].
			    s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
			    s2 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
			    i := s1 indexOfSubCollection: s2 startingAt: 1.
			    i = 0 ifTrue: [''] ifFalse: [s1 copyFrom: i + s2 size to: s1 size]]).
	functions at: 'normalize-space'
	    put: ((self new)
		    name: 'normalize-space';
		    valueBlock: 
			    [:fn :ns | 
			    | ns2 |
			    ns2 := fn arguments first xpathEvalIn: ns.
			    ns2 := ns2 xpathAsString.
			    self normalizeWhitespace: ns2])
    ]

    XPathFunction class >> normalizeWhitespace: aString [
	<category: 'function implementations'>
	| ch str buffer space |
	str := aString readStream.
	buffer := String new writeStream.
	space := false.
	
	[str
	    skipSeparators;
	    atEnd] whileFalse: 
		    [space ifTrue: [buffer space].
		    [(ch := str next) notNil and: [ch isSeparator not]] 
			whileTrue: [buffer nextPut: ch].
		    space := true].
	^buffer contents
    ]

    XPathFunction class >> translate: base from: src to: dest [
	<category: 'function implementations'>
	| dir result c |
	dir := IdentityDictionary new.
	src size to: 1
	    by: -1
	    do: 
		[:i | 
		dir at: (src at: i)
		    put: (i > dest size ifTrue: [nil] ifFalse: [dest at: i])].
	result := (String new: base size) writeStream.
	1 to: base size
	    do: 
		[:i | 
		c := base at: i.
		c := dir at: c ifAbsent: [c].
		c == nil ifFalse: [result nextPut: c]].
	^result contents
    ]

    addArgument: arg [
	<category: 'accessing'>
	arguments := arguments copyWith: arg
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    enumerate: aBlock [
	<category: 'accessing'>
	super enumerate: aBlock.
	self arguments do: [:i | i enumerate: aBlock]
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: nm [
	<category: 'accessing'>
	name := nm
    ]

    requiresNodeSet [
	<category: 'accessing'>
	^requiresNodeSet
    ]

    requiresNodeSet: bool [
	<category: 'accessing'>
	requiresNodeSet := bool
    ]

    requiresSort [
	<category: 'accessing'>
	^requiresSort
    ]

    requiresSort: bool [
	<category: 'accessing'>
	requiresSort := bool
    ]

    answersNumber [
	<category: 'testing'>
	^#('sum' 'round' 'count' 'last' 'position' 'string-length' 'floor' 'ceiling') 
	    includes: self name
    ]

    xpathMayRequireNodeSet [
	<category: 'testing'>
	^requiresNodeSet or: 
		[arguments inject: false
		    into: [:b :arg | b or: [arg xpathMayRequireNodeSet]]]
    ]

    xpathMayRequireNodeSetTopLevel [
	<category: 'testing'>
	^self answersNumber or: [self xpathMayRequireNodeSet]
    ]

    xpathMayRequireSort [
	<category: 'testing'>
	^requiresSort or: 
		[arguments inject: false into: [:b :arg | b or: [arg xpathMayRequireSort]]]
    ]

    xpathMayRequireSortTopLevel [
	<category: 'testing'>
	^self answersNumber or: [self xpathMayRequireSort]
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	^valueBlock value: self value: aNodeContext
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	arguments := #().
	requiresSort := false.
	requiresNodeSet := false
    ]

    valueBlock: aBlock [
	<category: 'initialize'>
	valueBlock := aBlock
    ]

    printTestOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: name , '('.
	arguments do: [:a | aStream print: a]
	    separatedBy: [aStream nextPutAll: ','].
	aStream nextPutAll: ')'
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathPrecedingSiblingNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathPrecedingSiblingNode class >> axisNames [
	<category: 'private'>
	^#('preceding-sibling')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc list i |
	nd := aNodeContext node.
	nc := aNodeContext copy inverseDocumentOrder.
	list := nd parent children.
	i := list identityIndexOf: nd.
	(list copyFrom: 1 to: i - 1) 
	    do: [:childNode | (baseTest match: childNode) ifTrue: [nc add: childNode]].
	^nc
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathRoot [
    
    <category: 'XML-XPath'>
    <comment: nil>

    baseValueIn: aNodeContext [
	<category: 'matching'>
	^(aNodeContext copy)
	    documentOrder;
	    add: aNodeContext node document
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	^anXmlNode isDocument and: [aBlock value: anXmlNode value: complex]
    ]

    completePrintOn: aStream [
	<category: 'printing'>
	aStream nextPut: $/.
	self child completeChildPrintOn: aStream
    ]

    isStartOfPath [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: XML [

XPathExpression subclass: XPathBinaryExpression [
    | operator argument1 argument2 valueBlock |
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathBinaryExpression class [
	| operators |
	
    ]

    XPathBinaryExpression class >> initialize [
	"XPathBinaryExpression initialize"

	<category: 'class initialization'>
	operators := Dictionary new.
	self initializeBoolean.
	self initializeComparison.
	self initializeNumeric
    ]

    XPathBinaryExpression class >> initializeBoolean [
	<category: 'class initialization'>
	operators at: #and
	    put: ((self new)
		    operator: #and
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    | b1 b2 |
			    b1 := (exp arg1 xpathEvalIn: ns) xpathAsBoolean.
			    b2 := (exp arg2 xpathEvalIn: ns) xpathAsBoolean.
			    b1 & b2]).
	operators at: #or
	    put: ((self new)
		    operator: #or
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    | b1 b2 |
			    b1 := (exp arg1 xpathEvalIn: ns) xpathAsBoolean.
			    b2 := (exp arg2 xpathEvalIn: ns) xpathAsBoolean.
			    b1 | b2])
    ]

    XPathBinaryExpression class >> initializeComparison [
	<category: 'class initialization'>
	operators at: #=
	    put: ((self new)
		    operator: #=
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) 
				xpathCompareEquality: (exp arg2 xpathEvalIn: ns)
				using: [:v1 :v2 | v1 = v2]]).
	operators at: #'!='
	    put: ((self new)
		    operator: #'!='
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) 
				xpathCompareEquality: (exp arg2 xpathEvalIn: ns)
				using: [:v1 :v2 | v1 ~= v2]]).
	operators at: #<
	    put: ((self new)
		    operator: #<
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
				using: [:v1 :v2 | v1 < v2]]).
	operators at: #>
	    put: ((self new)
		    operator: #>
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
				using: [:v1 :v2 | v1 > v2]]).
	operators at: #<=
	    put: ((self new)
		    operator: #<=
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
				using: [:v1 :v2 | v1 <= v2]]).
	operators at: #>=
	    put: ((self new)
		    operator: #>=
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
				using: [:v1 :v2 | v1 >= v2]])
    ]

    XPathBinaryExpression class >> initializeNumeric [
	<category: 'class initialization'>
	operators at: #+
	    put: ((self new)
		    operator: #+
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathAsNumber 
				+ (exp arg2 xpathEvalIn: ns) xpathAsNumber]).
	operators at: #-
	    put: ((self new)
		    operator: #-
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathAsNumber 
				- (exp arg2 xpathEvalIn: ns) xpathAsNumber]).
	operators at: #*
	    put: ((self new)
		    operator: #*
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathAsNumber 
				* (exp arg2 xpathEvalIn: ns) xpathAsNumber]).
	operators at: #div
	    put: ((self new)
		    operator: #div
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathAsNumber 
				/ (exp arg2 xpathEvalIn: ns) xpathAsNumber]).
	operators at: #mod
	    put: ((self new)
		    operator: #mod
			with: nil
			with: nil;
		    valueBlock: 
			    [:exp :ns | 
			    (exp arg1 xpathEvalIn: ns) xpathAsNumber 
				rem: (exp arg2 xpathEvalIn: ns) xpathAsNumber])
    ]

    XPathBinaryExpression class >> operator: op with: arg1 with: arg2 [
	<category: 'instance creation'>
	^(operators at: op ifAbsent: [self error: 'Not implemented yet %1' % {op}]) 
	    copy 
		operator: op
		with: arg1
		with: arg2
    ]

    arg1 [
	<category: 'accessing'>
	^argument1
    ]

    arg2 [
	<category: 'accessing'>
	^argument2
    ]

    enumerate: aBlock [
	<category: 'accessing'>
	super enumerate: aBlock.
	self arg1 enumerate: aBlock.
	self arg2 enumerate: aBlock
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	^valueBlock value: self value: aNodeContext
    ]

    operator: op with: arg1 with: arg2 [
	<category: 'initialize'>
	operator := op.
	argument1 := arg1.
	argument2 := arg2
    ]

    valueBlock: aBlock [
	<category: 'initialize'>
	valueBlock := aBlock
    ]

    printTestOn: aStream [
	<category: 'printing'>
	argument1 printOn: aStream.
	aStream
	    space;
	    nextPutAll: operator;
	    space.
	argument2 printOn: aStream
    ]

    xpathMayRequireNodeSet [
	<category: 'testing'>
	^self arg1 xpathMayRequireNodeSet or: [self arg2 xpathMayRequireNodeSet]
    ]

    xpathMayRequireNodeSetTopLevel [
	<category: 'testing'>
	(#(#+ #- #* #div #mod) includes: operator) ifTrue: [^true].
	(#(#= #'!=' #< #> #<= #>= #| #and #or) includes: operator) 
	    ifTrue: 
		[^self arg1 xpathMayRequireNodeSet or: [self arg2 xpathMayRequireNodeSet]].
	self notYetImplementedError
    ]

    xpathMayRequireSort [
	<category: 'testing'>
	^self arg1 xpathMayRequireSort or: [self arg2 xpathMayRequireSort]
    ]

    xpathMayRequireSortTopLevel [
	<category: 'testing'>
	(#(#+ #- #* #div #mod) includes: operator) ifTrue: [^true].
	(#(#= #'!=' #< #> #<= #>= #| #and #or) includes: operator) 
	    ifTrue: [^self arg1 xpathMayRequireSort or: [self arg2 xpathMayRequireSort]].
	self notYetImplementedError
    ]
]

]



Namespace current: XML [

Array subclass: XPathSortingVector [
    | value |
    
    <shape: #pointer>
    <category: 'XML-XPath'>
    <comment: nil>

    XPathSortingVector class >> fromXmlNode: aNode [
	<category: 'instance creation'>
	| list node |
	list := OrderedCollection new.
	node := aNode.
	[node isDocument] whileFalse: 
		[list addFirst: (node parent children identityIndexOf: node ifAbsent: [0]).
		node := node parent].
	^(self withAll: list) value: aNode
    ]

    <= aVector [
	<category: 'sorting'>
	| min v1 v2 |
	min := self size min: aVector size.
	1 to: min
	    do: 
		[:i | 
		v1 := self at: i.
		v2 := aVector at: i.
		v1 = v2 ifFalse: [^v1 < v2]].
	^self size <= aVector size
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aNode [
	<category: 'accessing'>
	value := aNode
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathFollowingSiblingNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathFollowingSiblingNode class >> axisNames [
	<category: 'private'>
	^#('following-sibling')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc list i |
	nd := aNodeContext node.
	nc := aNodeContext copy documentOrder.
	list := nd parent children.
	i := list identityIndexOf: nd.
	(list copyFrom: i + 1 to: list size) 
	    do: [:childNode | (baseTest match: childNode) ifTrue: [nc add: childNode]].
	^nc
    ]
]

]



Namespace current: XML [

Object subclass: XPathNodeTest [
    
    <category: 'XML-XPath'>
    <comment: nil>

    isTrivial [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: XML [

XPathNodeTest subclass: XPathTypedNodeTest [
    | typeName value |
    
    <category: 'XML-XPath'>
    <comment: nil>

    isTrivial [
	<category: 'testing'>
	^typeName = 'node'
    ]

    match: anXmlNode [
	<category: 'matching'>
	typeName = 'node' ifTrue: [^true].
	typeName = 'text' ifTrue: [^anXmlNode isText].
	typeName = 'comment' ifTrue: [^anXmlNode isComment].
	typeName = 'processing-instruction' 
	    ifTrue: 
		[^anXmlNode isProcessingInstruction 
		    and: [value == nil or: [value = anXmlNode name]]].
	self notYetImplementedError
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: typeName , '('.
	value == nil ifFalse: [aStream nextPutAll: value].
	aStream nextPutAll: ')'
    ]

    type: aString [
	<category: 'accessing'>
	typeName := aString.
	(#('comment' 'text' 'node' 'processing-instruction') includes: typeName) 
	    ifFalse: 
		[self 
		    error: 'A node test must be one of comment, text, node, or propcessing-instruction']
    ]

    value: aString [
	<category: 'accessing'>
	value := aString
    ]
]

]



Namespace current: XML [

XPathNodeTest subclass: XPathTaggedNodeTest [
    | namespace qualifier type |
    
    <category: 'XML-XPath'>
    <comment: nil>

    match: anXmlNode [
	<category: 'matching'>
	(anXmlNode isElement or: [anXmlNode isAttribute]) ifFalse: [^false].
	namespace == nil 
	    ifFalse: [namespace = anXmlNode tag namespace ifFalse: [^false]].
	^type = #* or: [type = anXmlNode tag type]
    ]

    namespace [
	<category: 'accessing'>
	^namespace
    ]

    namespace: ns [
	<category: 'accessing'>
	namespace := ns = '' ifTrue: [nil] ifFalse: [ns]
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    type: aString [
	<category: 'accessing'>
	type := aString
    ]

    printOn: aStream [
	<category: 'printing'>
	qualifier == nil ifFalse: [aStream nextPutAll: qualifier , ':'].
	aStream nextPutAll: type
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathTerminator [
    
    <category: 'XML-XPath'>
    <comment: nil>

    completePrintOn: aStream [
	<category: 'printing'>
	^self
    ]

    printOn: aStream [
	<category: 'printing'>
	self basicPrintOn: aStream
    ]

    enumerate: aBlock [
	<category: 'accessing'>
	aBlock value: self
    ]

    initialize [
	<category: 'initialize'>
	predicates := #()
    ]

    isTerminator [
	<category: 'testing'>
	^true
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	^parent 
	    simpleMatchFor: anXmlNode
	    isComplex: complex
	    do: aBlock
    ]

    valueIn: aNodeContext do: aBlock [
	<category: 'matching'>
	aBlock value: aNodeContext node
    ]

    valueOfAllIn: aNodeContext [
	<category: 'matching'>
	^aNodeContext
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathDescendantNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathDescendantNode class >> axisNames [
	<category: 'private'>
	^#('descendant' 'descendant-or-self')
    ]

    axisName [
	<category: 'testing'>
	^axisName == nil ifTrue: ['descendant-or-self'] ifFalse: [axisName]
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc queue nextNode |
	nd := aNodeContext node.
	nc := aNodeContext copy documentOrder.
	queue := OrderedCollection new.
	self axisName = 'descendant-or-self' 
	    ifTrue: [queue add: nd]
	    ifFalse: [nd isElement ifTrue: [queue addAll: nd children]].
	nd isDocument ifTrue: [queue add: nd root].
	[queue isEmpty] whileFalse: 
		[nextNode := queue removeFirst.
		(baseTest match: nextNode) ifTrue: [nc add: nextNode].
		nextNode isElement ifTrue: [queue addAll: nextNode children]].
	^nc
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	| startNode hasCP set |
	anXmlNode isAttribute ifTrue: [^false].
	(baseTest match: anXmlNode) ifFalse: [^false].
	(hasCP := self hasComplexPredicate) 
	    ifFalse: 
		[set := XPathNodeContext new add: anXmlNode.
		1 to: predicates size do: [:i | set := set select: (predicates at: i)].
		set size = 0 ifTrue: [^false halt]].
	startNode := self axisName = 'descendant' 
		    ifTrue: [anXmlNode parent]
		    ifFalse: [anXmlNode].
	
	[parent == nil 
	    ifTrue: [aBlock value: anXmlNode value: complex | hasCP]
	    ifFalse: 
		[parent 
		    simpleMatchFor: startNode
		    isComplex: complex | hasCP
		    do: aBlock]] 
		whileFalse: 
		    [startNode := startNode parent.
		    startNode == nil ifTrue: [^false]].
	^true
    ]

    completeChildPrintOn: aStream [
	<category: 'printing'>
	(baseTest isTrivial 
	    and: [predicates isEmpty and: [axisName = 'descendant-or-self']]) 
		ifFalse: [^super completePrintOn: aStream].
	aStream nextPut: $/.
	self child completeChildPrintOn: aStream
    ]
]

]



Namespace current: XML [

Object subclass: XPathParser [
    | pushBack hereChar stack buffer source token tokenType xmlNode functions |
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathParser class [
	| nodeTypes typeTable |
	
    ]

    XPathParser class >> parse: stringOrStream as: construct [
	<category: 'parsing'>
	^self new parse: stringOrStream as: construct
    ]

    XPathParser class >> baseTable [
	<category: 'private'>
	| newTable c selector |
	newTable := Array new: 255.
	1 to: 255
	    do: 
		[:each | 
		c := each asCharacter.
		selector := #xDefault.
		c isSeparator ifTrue: [selector := #xDelimiter].
		c isDigit ifTrue: [selector := #xDigit].
		c isLetter ifTrue: [selector := #xLetter].
		c == $. ifTrue: [selector := #xPeriod].
		c == $" ifTrue: [selector := #xDoubleQuote].
		c == $' ifTrue: [selector := #xSingleQuote].
		c == $} ifTrue: [selector := #xEndOfExpression].
		(':*/+-@=!<>|' includes: c) ifTrue: [selector := #xBinary].
		('$[]()' includes: c) ifTrue: [selector := #xCharacter].
		newTable at: each put: selector].
	^newTable
    ]

    XPathParser class >> initialize [
	"Compute the character type, reserved word tables, and
	 keyword flag from the information associated with each method."

	<category: 'private'>
	typeTable := self baseTable.
	nodeTypes := Dictionary new.
	XPathStep 
	    allSubclassesDo: [:cls | cls axisNames do: [:nm | nodeTypes at: nm put: cls]]
    ]

    XPathParser class >> typeTable [
	<category: 'private'>
	^typeTable
    ]

    XPathParser class >> nodeTypes [
	<category: 'private'>
	^nodeTypes
    ]

    XPathParser class >> examples [
	"XPathParser2 examples"

	<category: 'examples'>
	| samples |
	samples := #('child::para' 'child::*' 'child::text()' 'child::node()' 'attribute::name' 'attribute::*' 'descendant::para' 'ancestor::div' 'ancestor-or-self::div' 'descendant-or-self::para' 'self::para' 'child::chapter/descendant::para' 'child::*/child::para' '/' '/descendant::para' '/descendant::olist/child::item' 'child::para[position()=1]' 'child::para[position()=last()]' 'child::para[position()=last()-1]' 'child::para[position()>1]' 'following-sibling::chapter[position()=1]' 'preceding-sibling::chapter[position()=1]' '/descendant::figure[position()=42]' '/child::doc/child::chapter[position()=5]/child::section[position()=2]' 'child::para[attribute::type="warning"]' 'child::para[attribute::type=''warning''][position()=5]' 'child::para[position()=5][attribute::type="warning"]' 'child::chapter[child::title=''Introduction'']' 'child::chapter[child::title]' 'child::*[self::chapter or self::appendix]' 'child::*[self::chapter or self::appendix][position()=last()]').
	samples do: [:str | (self new parse: str as: #locationPath) printNl]
    ]

    abbreviatedDescendant [
	<category: 'construction'>
	token = #/ 
	    ifTrue: 
		[stack add: ((XPathDescendantNode new)
			    axisName: 'descendant-or-self';
			    baseTest: (XPathTypedNodeTest new type: 'node')).
		^true].
	^false
    ]

    arg: a1 op: operator arg: a2 [
	<category: 'construction'>
	^XPathBinaryExpression 
	    operator: operator asSymbol
	    with: a1
	    with: a2
    ]

    axis: axisName test: test [
	<category: 'construction'>
	| stepClass step |
	stepClass := self class nodeTypes at: axisName
		    ifAbsent: [self error: '%1 is not an axis' % {axisName}].
	step := stepClass new.
	step axisName: axisName.	"Some classes represent multiple axes, and must be told which"
	step baseTest: test.
	^step
    ]

    connectParent: parent child: child [
	<category: 'construction'>
	| p |
	p := parent.
	[p child isTerminator] whileFalse: [p := p child].
	p child: child.
	child parent: p.
	^parent
    ]

    function: aName [
	<category: 'construction'>
	^self functionNamed: aName
    ]

    function: aFunction arg: anArgument [
	<category: 'construction'>
	^aFunction addArgument: anArgument
    ]

    isNodeType [
	<category: 'construction'>
	| typeName argument ok |
	typeName := stack at: stack size - 1.
	argument := stack at: stack size.
	ok := typeName = 'processing-instruction' 
		    ifTrue: [true]
		    ifFalse: 
			[(#('node' 'text' 'comment') includes: typeName) 
			    ifTrue: [argument == nil]
			    ifFalse: [false]].
	"ok ifFalse: [stack removeLast]."
	^ok
    ]

    nodeTestQualifier: qualifier type: typeName [
	<category: 'construction'>
	| ns |
	ns := self namespaceAt: qualifier.
	^(XPathTaggedNodeTest new)
	    namespace: ns;
	    type: typeName
    ]

    nodeTestType: typeName [
	<category: 'construction'>
	^XPathTaggedNodeTest new type: typeName
    ]

    nodeTypeTest: typeName arg: argument [
	<category: 'construction'>
	^(XPathTypedNodeTest new)
	    type: typeName;
	    value: argument
    ]

    number: aValue [
	<category: 'construction'>
	^aValue
    ]

    selfOrParent [
	<category: 'construction'>
	token = #'.' 
	    ifTrue: 
		[self scanToken.
		stack add: ((XPathCurrentNode new)
			    axisName: 'self';
			    baseTest: (XPathTypedNodeTest new type: 'node')).
		^true].
	token = #'..' 
	    ifTrue: 
		[self scanToken.
		stack add: ((XPathParentNode new)
			    axisName: 'parent';
			    baseTest: (XPathTypedNodeTest new type: 'node')).
		^true].
	^false
    ]

    step: step predicate: predicate [
	<category: 'construction'>
	^step
	    addPredicate: predicate;
	    yourself
    ]

    string: aValue [
	<category: 'construction'>
	^aValue
    ]

    union: path1 with: path2 [
	<category: 'construction'>
	^path1 asUnion add: path2
    ]

    variable: aName [
	<category: 'construction'>
	^XPathVariable new name: aName
    ]

    absoluteLocationPath [
	<category: 'paths'>
	| root child |
	self scanToken.	"#/"
	stack addLast: XPathRoot new.
	hereChar isNil ifTrue: [^true].
	self relativeLocationPath ifFalse: [^false].
	child := stack removeLast.
	root := stack removeLast.
	stack addLast: (self connectParent: root child: child).
	^true
    ]

    anyStep [
	<category: 'paths'>
	self selfOrParent ifTrue: [^true].
	self abbreviatedDescendant ifTrue: [^true].
	^self stepWithPredicates
    ]

    locationPath [
	<category: 'paths'>
	token = #/ ifTrue: [^self absoluteLocationPath].
	^self relativeLocationPath
    ]

    nodeTest [
	<category: 'paths'>
	| word word2 arg |
	token = #* 
	    ifTrue: 
		[self scanToken.
		stack addLast: (self nodeTestType: #*).
		^true].
	tokenType = #word ifFalse: [^false].
	word := token.
	self scanToken.
	token = $( 
	    ifTrue: 
		[self scanToken.
		token = $) 
		    ifTrue: 
			[self scanToken.
			arg := nil]
		    ifFalse: 
			[tokenType = #string ifFalse: [^false].
			arg := token.
			self scanToken.
			token = $) ifFalse: [^false]].
		stack addLast: (self nodeTypeTest: word arg: arg).
		^true].
	(self peekFor: #':') 
	    ifFalse: 
		[self verifyNotFunction 
		    ifTrue: 
			[stack addLast: (self nodeTestType: word).
			^true]].
	self scanToken.
	token = #* 
	    ifTrue: 
		[self scanToken.
		stack addLast: (self nodeTestQualifier: word).
		^true].
	tokenType = #word ifFalse: [^false].
	word2 := token.
	self scanToken.
	stack addLast: (self nodeTestQualifier: word type: word2)
    ]

    predicate [
	<category: 'paths'>
	(token = $[ and: 
		[self scanToken.
		self expression and: [token = $]]]) 
	    ifTrue: 
		[self scanToken.
		^true].
	^false
    ]

    relativeLocationPath [
	<category: 'paths'>
	| parent child |
	self anyStep ifFalse: [^false].
	[token = #/] whileTrue: 
		[self scanToken.
		self anyStep ifFalse: [^false].
		child := stack removeLast.
		parent := stack removeLast.
		stack addLast: (self connectParent: parent child: child)].
	^true
    ]

    stepWithPredicates [
	<category: 'paths'>
	| axis word step predicate position |
	axis := 'child'.
	tokenType = #word 
	    ifTrue: 
		[axis := token.
		self scanToken.

		"???"
		(token = $( and: 
			[(#('node' 'text' 'comment' 'processing-instruction') includes: axis) not]) 
		    ifTrue: 
			[pushBack := #character -> $(.
			tokenType := #word.
			token := axis.
			^false].
		(self peekFor: #'::') 
		    ifFalse: 
			[tokenType isNil ifFalse: [pushBack := tokenType -> token].
			tokenType := #word.
			token := axis.
			axis := 'child']].
	token = #@ 
	    ifTrue: 
		[self scanToken.
		axis := 'attribute'].
	self nodeTest ifFalse: [^false].
	stack addLast: (self axis: axis test: stack removeLast).
	[self predicate] whileTrue: 
		[predicate := stack removeLast.
		step := stack removeLast.
		stack addLast: (self step: step predicate: predicate)].
	^true
    ]

    additiveExpr [
	<category: 'expressions'>
	| op arg1 arg2 |
	self multiplicativeExpr ifFalse: [^false].
	
	[op := token.
	token = #+ or: [token = #-]] whileTrue: 
		    [self scanToken.
		    self multiplicativeExpr ifFalse: [self error: 'error in operand of +/-'].
		    arg2 := stack removeLast.
		    arg1 := stack removeLast.
		    stack addLast: (self 
				arg: arg1
				op: op
				arg: arg2)].
	^true
    ]

    andExpr [
	<category: 'expressions'>
	| op arg1 arg2 |
	self equalityExpr ifFalse: [^false].
	
	[op := token.
	token = 'and'] whileTrue: 
		    [self scanToken.
		    self equalityExpr ifFalse: [self error: 'error in operand of and'].
		    arg2 := stack removeLast.
		    arg1 := stack removeLast.
		    stack addLast: (self 
				arg: arg1
				op: op
				arg: arg2)].
	^true
    ]

    equalityExpr [
	<category: 'expressions'>
	| op arg1 arg2 |
	self relationalExpr ifFalse: [^false].
	
	[op := token.
	token = #= or: [token = #'!=']] whileTrue: 
		    [self scanToken.
		    self relationalExpr ifFalse: [self error: 'error in operand of =/!='].
		    arg2 := stack removeLast.
		    arg1 := stack removeLast.
		    stack addLast: (self 
				arg: arg1
				op: op
				arg: arg2)].
	^true
    ]

    expression [
	<category: 'expressions'>
	^self orExpr
    ]

    filterExpr [
	<category: 'expressions'>
	| step predicate |
	self primaryExpr ifFalse: [^false].
	[self predicate] whileTrue: 
		[predicate := stack removeLast.
		step := stack removeLast.
		stack addLast: (self step: step predicate: predicate)].
	^true
    ]

    multiplicativeExpr [
	<category: 'expressions'>
	| op arg1 arg2 |
	self unaryExpr ifFalse: [^false].
	
	[op := token.
	token = #* or: [token = 'div' or: [token = 'mod']]] 
		whileTrue: 
		    [self scanToken.
		    self unaryExpr ifFalse: [self error: 'error in operand of */div/mod'].
		    arg2 := stack removeLast.
		    arg1 := stack removeLast.
		    stack addLast: (self 
				arg: arg1
				op: op
				arg: arg2)].
	^true
    ]

    orExpr [
	<category: 'expressions'>
	| op arg1 arg2 |
	self andExpr ifFalse: [^false].
	
	[op := token.
	token = 'or'] whileTrue: 
		    [self scanToken.
		    self andExpr ifFalse: [self error: 'error in operand of or'].
		    arg2 := stack removeLast.
		    arg1 := stack removeLast.
		    stack addLast: (self 
				arg: arg1
				op: op
				arg: arg2)].
	^true
    ]

    pathExpr [
	<category: 'expressions'>
	| parent child |
	self locationPath ifTrue: [^true].
	self filterExpr ifFalse: [^false].
	token = #/ ifFalse: [^true].
	self scanToken.
	self relativeLocationPath ifFalse: [^false].
	child := stack removeLast.
	parent := stack removeLast.
	stack addLast: (self connectParent: parent child: child).
	^true
    ]

    primaryExpr [
	<category: 'expressions'>
	| function arg |
	token = $$ 
	    ifTrue: 
		[self scanToken.
		tokenType = #word ifFalse: [^false].
		stack addLast: (self variable: token).
		self scanToken.
		^true].
	token = $( 
	    ifTrue: 
		[self scanToken.
		self expression ifFalse: [^false].
		token = $) ifFalse: [^false].
		self scanToken.
		^true].
	tokenType = #string 
	    ifTrue: 
		[stack addLast: (self string: token).
		self scanToken.
		^true].
	tokenType = #number 
	    ifTrue: 
		[stack addLast: (self number: token).
		self scanToken.
		^true].
	tokenType = #word 
	    ifTrue: 
		[function := token.
		stack addLast: (self function: token).
		self scanToken.
		token = $( ifFalse: [^false].
		self scanToken.
		token = $) 
		    ifFalse: 
			[
			[self expression ifFalse: [^false].
			arg := stack removeLast.
			function := stack removeLast.
			stack addLast: (self function: function arg: arg).
			token = $,] 
				whileTrue.
			token = $) ifFalse: [^false]].
		self scanToken.
		^true].
	^false
    ]

    relationalExpr [
	<category: 'expressions'>
	| op arg1 arg2 |
	self additiveExpr ifFalse: [^false].
	
	[op := token.
	token = #< or: [token = #> or: [token = #<= or: [token = #>=]]]] 
		whileTrue: 
		    [self scanToken.
		    self additiveExpr 
			ifFalse: [self error: 'error in operand of relational operator'].
		    arg2 := stack removeLast.
		    arg1 := stack removeLast.
		    stack addLast: (self 
				arg: arg1
				op: op
				arg: arg2)].
	^true
    ]

    unaryExpr [
	<category: 'expressions'>
	token = #- 
	    ifTrue: 
		[self scanToken.
		^(self unaryExpr)
		    ifTrue: [stack addLast: (self negated: stack removeLast)];
		    yourself].
	^self unionExpr
    ]

    unionExpr [
	<category: 'expressions'>
	| arg1 arg2 |
	self pathExpr ifFalse: [^false].
	[token = #|] whileTrue: 
		[self scanToken.
		self pathExpr ifFalse: [self error: 'error in operand of |'].
		arg2 := stack removeLast.
		arg1 := stack removeLast.
		stack addLast: (self union: arg1 with: arg2)].
	^true
    ]

    atEndOfExpression [
	<category: 'public'>
	^tokenType == #endOfExpression
    ]

    init: streamOrString notifying: nothing failBlock: bah [
	<category: 'public'>
	self source: streamOrString
    ]

    source: streamOrString [
	<category: 'public'>
	buffer := String new writeStream.
	stack := OrderedCollection new.
	source := streamOrString isString 
		    ifFalse: [streamOrString]
		    ifTrue: [XPathReadStream on: streamOrString asString].
	self
	    step;
	    scanToken
    ]

    parse: string as: construct [
	<category: 'public'>
	self source: string.
	self perform: construct.
	self pastEnd 
	    ifFalse: 
		[self 
		    error: 'Extra characters which could not be translated at end of stream'].
	^self result
    ]

    pastEnd [
	<category: 'public'>
	^hereChar == nil
    ]

    result [
	<category: 'public'>
	stack size = 1 
	    ifFalse: 
		[self error: 'Parsing logic error, incorrect number of values on the stack'].
	^stack first
    ]

    initScanner [
	"Present for compatibility with the parser in VW."

	<category: 'public'>
	
    ]

    xmlNode: aNode [
	<category: 'public'>
	xmlNode := aNode
    ]

    functionNamed: fName [
	<category: 'private'>
	functions == nil ifTrue: [functions := XPathFunction baseFunctions].
	^(functions at: fName
	    ifAbsent: [self error: 'Not implemented yet %1()' % {fName}]) copy
    ]

    namespaceAt: aQualifier [
	<category: 'private'>
	| elm ns |
	elm := xmlNode.
	[elm isDocument] whileFalse: 
		[ns := elm namespaceAt: aQualifier.
		ns == nil ifFalse: [^ns].
		elm := elm parent].
	aQualifier = 'xml' ifTrue: [^XML_URI].
	self error: 'No namespace binding found for namespace qualifier "%1".' 
		    % {aQualifier}
    ]

    peekFor: trialValue [
	"Test to see if tokenType matches aType and token equals trialValue. If so,
	 advance to the next token"

	<category: 'private'>
	^token = trialValue 
	    ifTrue: 
		[self scanToken.
		true]
	    ifFalse: [false]
    ]

    unexpectedError [
	<category: 'private'>
	^self
	    halt;
	    error: 'syntax error'
    ]

    verifyNotFunction [
	<category: 'private'>
	^token ~= $(
    ]

    scanToken [
	<category: 'private'>
	| type |
	pushBack isNil 
	    ifFalse: 
		[tokenType := pushBack key.
		token := pushBack value.
		pushBack := nil.
		^self].
	hereChar isNil 
	    ifFalse: 
		[type := self class typeTable at: hereChar asInteger ifAbsent: [#xDefault].
		self perform: type.
		^self].
	tokenType := token := nil
    ]

    step [
	<category: 'private'>
	hereChar := source next
    ]

    xBinary [
	<category: 'private'>
	| char test |
	tokenType := #binary.
	char := hereChar.
	self step.
	char = $. ifTrue: [self halt].
	hereChar == nil 
	    ifTrue: [token := Symbol internCharacter: char]
	    ifFalse: 
		[test := String with: char with: hereChar.
		(#('::' '<=' '>=' '!=') includes: test) 
		    ifTrue: 
			[self step.
			token := Symbol intern: test]
		    ifFalse: [token := Symbol internCharacter: char]]
    ]

    xCharacter [
	<category: 'private'>
	tokenType := #character.
	token := hereChar.
	self step
    ]

    xDefault [
	<category: 'private'>
	self error: 'invalid character ' , hereChar asString
    ]

    xDelimiter [
	<category: 'private'>
	source skipSeparators.
	self step.
	self scanToken
    ]

    xDigit [
	"form a number"

	<category: 'private'>
	| numerator denominator |
	tokenType := #number.
	numerator := 0.
	denominator := 1.
	[hereChar notNil and: [hereChar isDigit]] whileTrue: 
		[numerator := numerator * 10 + hereChar digitValue.
		self step].
	hereChar = $. ifFalse: [^token := numerator + 0.0].
	self step.
	[hereChar notNil and: [hereChar isDigit]] whileTrue: 
		[numerator := numerator * 10 + hereChar digitValue.
		denominator := denominator * 10.
		self step].
	token := numerator / denominator + 0.0
    ]

    xEndOfExpression [
	<category: 'private'>
	tokenType := #endOfExpression.
	token := nil
    ]

    xDoubleQuote [
	"collect string"

	<category: 'private'>
	| char |
	buffer reset.
	[(char := source next) == $"] whileFalse: 
		[char == nil ifTrue: [^self offEnd: 'Unmatched comment quote'].
		buffer nextPut: char].
	tokenType := #string.
	token := buffer contents.

	"Shorten the buffer if it got unreasonably large."
	buffer position > 200 ifTrue: [buffer := WriteStream on: (String new: 40)].
	self step
    ]

    xLetter [
	"form a word, keyword, or reserved word"

	<category: 'private'>
	| char |
	buffer reset.
	buffer nextPut: hereChar.
	
	[char := source next.
	char notNil and: [char isAlphaNumeric or: [char == $-]]] 
		whileTrue: [buffer nextPut: char].
	tokenType := #word.
	hereChar := char.
	token := buffer contents
    ]

    xPeriod [
	"form a number"

	<category: 'private'>
	| numerator denominator |
	self step.
	hereChar = $. 
	    ifTrue: 
		[self step.
		token := #'..'.
		tokenType := #binary.
		^self].
	(hereChar notNil and: [hereChar isDigit]) 
	    ifFalse: 
		[token := #'.'.
		tokenType := #binary.
		^self].
	tokenType := #number.
	numerator := 0.
	denominator := 1.
	[hereChar notNil and: [hereChar isDigit]] whileTrue: 
		[numerator := numerator * 10 + hereChar digitValue.
		denominator := denominator * 10.
		self step].
	token := numerator / denominator + 0.0
    ]

    xSingleQuote [
	"collect string"

	<category: 'private'>
	| char |
	buffer reset.
	[(char := source next) == $'] whileFalse: 
		[char == nil ifTrue: [^self offEnd: 'Unmatched comment quote'].
		buffer nextPut: char].
	tokenType := #string.
	token := buffer contents.

	"Shorten the buffer if it got unreasonably large."
	buffer position > 200 ifTrue: [buffer := WriteStream on: (String new: 40)].
	self step
    ]

    functions: aDictionary [
	<category: 'initialize'>
	functions := aDictionary
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathAttributeNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathAttributeNode class >> axisNames [
	<category: 'private'>
	^#('attribute')
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	| nd nc |
	nd := aNodeContext node.
	nc := aNodeContext copy documentOrder.
	nd isElement ifFalse: [^nc].
	nd attributes 
	    do: [:childNode | (baseTest match: childNode) ifTrue: [nc add: childNode]].
	^nc
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	| hasCP set |
	anXmlNode isAttribute ifFalse: [^false].
	(baseTest match: anXmlNode) ifFalse: [^false].
	(hasCP := self hasComplexPredicate) 
	    ifFalse: 
		[set := XPathNodeContext new add: anXmlNode.
		1 to: predicates size do: [:i | set := set select: (predicates at: i)].
		set size = 0 ifTrue: [^false halt]].
	parent == nil 
	    ifTrue: [^aBlock value: anXmlNode parent value: complex | hasCP].
	^parent 
	    simpleMatchFor: anXmlNode parent
	    isComplex: complex | hasCP
	    do: aBlock
    ]

    printTestOn: aStream [
	<category: 'printing'>
	axisName == nil 
	    ifTrue: 
		[aStream
		    nextPutAll: '@';
		    print: baseTest]
	    ifFalse: [super printTestOn: aStream]
    ]
]

]



Namespace current: XML [

XPathStep subclass: XPathCurrentNode [
    
    <category: 'XML-XPath'>
    <comment: nil>

    XPathCurrentNode class >> axisNames [
	<category: 'private'>
	^#('self')
    ]

    axisName [
	<category: 'accessing'>
	axisName == nil ifTrue: [^'self'] ifFalse: [^axisName]
    ]

    baseValueIn: aNodeContext [
	<category: 'matching'>
	^(baseTest match: aNodeContext node) 
	    ifTrue: 
		[(aNodeContext copy)
		    documentOrder;
		    add: aNodeContext node]
	    ifFalse: [aNodeContext copy documentOrder]
    ]

    simpleMatchFor: anXmlNode isComplex: complex do: aBlock [
	<category: 'matching'>
	| hasCP set |
	(baseTest match: anXmlNode) ifFalse: [^false].
	(hasCP := self hasComplexPredicate) 
	    ifFalse: 
		[set := XPathNodeContext new add: anXmlNode.
		1 to: predicates size do: [:i | set := set select: (predicates at: i)].
		set size = 0 ifTrue: [^false halt]].
	parent == nil ifTrue: [^aBlock value: anXmlNode value: complex | hasCP].
	^parent 
	    simpleMatchFor: anXmlNode
	    isComplex: complex | hasCP
	    do: aBlock
    ]

    completePrintOn: aStream [
	<category: 'printing'>
	(baseTest isTrivial and: [predicates isEmpty]) 
	    ifTrue: 
		[self child isTerminator 
		    ifTrue: [aStream nextPutAll: '.']
		    ifFalse: 
			[aStream nextPutAll: './'.
			self child completeChildPrintOn: aStream]]
	    ifFalse: [super completePrintOn: aStream]
    ]

    initialize [
	<category: 'initialize'>
	super initialize.
	baseTest := XPathTypedNodeTest new type: 'node'
    ]
]

]



Object extend [

    xpathUsedVarNames [
	<category: 'xpath'>
	^OrderedCollection new
    ]

    addToXPathHolder: anAssociation for: aNodeContext [
	<category: 'xml support'>
	anAssociation value == nil ifTrue: [^anAssociation value: self].
	anAssociation value xpathIsNodeSet 
	    ifTrue: 
		[^self 
		    error: 'An XPath expression is answering a combination of Nodes and non-Nodes'].
	self 
	    error: 'An XPath expression is answering more than one non-Node value'
    ]

    xpathEvalIn: aNodeContext [
	"This is private protocol--see #xpathValueIn: for the client protocol"

	<category: 'xml support'>
	^self
    ]

    xpathIsBoolean [
	<category: 'xml support'>
	^false
    ]

    xpathIsNodeSet [
	<category: 'xml support'>
	^false
    ]

    xpathIsNumber [
	<category: 'xml support'>
	^false
    ]

    xpathMayRequireNodeSet [
	<category: 'xml support'>
	^false
    ]

    xpathMayRequireNodeSetTopLevel [
	<category: 'xml support'>
	^false
    ]

    xpathMayRequireSort [
	<category: 'xml support'>
	^false
    ]

    xpathMayRequireSortTopLevel [
	<category: 'xml support'>
	^false
    ]

    xpathValueIn: aNodeContext [
	"This is public protocol--see #xpathEvalIn: for the private internal protocol"

	<category: 'xml support'>
	^self
    ]

]



Document extend [

    xpathStringData [
	<category: 'accessing'>
	^self root xpathStringData
    ]

]



Text extend [

    xpathStringData [
	<category: 'accessing'>
	^self characterData
    ]

]



PI extend [

    xpathStringData [
	<category: 'accessing'>
	^self text
    ]

]



Element extend [

    xpathStringData [
	<category: 'accessing'>
	^self characterData
    ]

]



Comment extend [

    xpathStringData [
	<category: 'accessing'>
	^self text
    ]

]



Node extend [

    addToXPathHolder: anAssociation for: aNodeContext [
	<category: 'enumerating'>
	anAssociation value == nil 
	    ifTrue: [^anAssociation value: (aNodeContext copy add: self)].
	anAssociation value xpathIsNodeSet 
	    ifTrue: [^anAssociation value add: self].
	self 
	    error: 'An XPath expression is answering a combination of Nodes and non-Nodes'
    ]

    xpathStringData [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

]



Boolean extend [

    xpathAsBoolean [
	<category: 'converting'>
	^self
    ]

    xpathAsNumber [
	<category: 'converting'>
	^self ifTrue: [1] ifFalse: [0]
    ]

    xpathAsString [
	<category: 'converting'>
	^self printString
    ]

    xpathCompareEquality: aData using: aBlock [
	<category: 'xml support'>
	aData isString ifTrue: [^aBlock value: self value: aData xpathAsBoolean].
	aData xpathIsNumber 
	    ifTrue: [^aBlock value: self value: aData xpathAsBoolean].
	aData xpathIsBoolean 
	    ifTrue: [^aBlock value: self value: aData xpathAsBoolean].
	aData xpathIsNodeSet 
	    ifTrue: 
		[^aData unsortedNodes 
		    contains: [:nd2 | aBlock value: self value: nd2 xpathStringData xpathAsBoolean]].
	self error: 'Can''t compare a %1 with a boolean' % {aData class}
    ]

    xpathCompareOrder: aData using: aBlock [
	<category: 'xml support'>
	| v |
	v := self xpathAsNumber.
	^aData xpathIsNodeSet 
	    ifTrue: 
		[aData unsortedNodes 
		    contains: [:nd2 | aBlock value: v value: nd2 xpathStringData xpathAsNumber]]
	    ifFalse: [aBlock value: v value: aData xpathAsNumber]
    ]

    xpathIsBoolean [
	<category: 'xml support'>
	^true
    ]

]



Number extend [

    xpathAsBoolean [
	<category: 'converting'>
	^self ~= 0
    ]

    xpathAsNumber [
	<category: 'converting'>
	^self
    ]

    xpathAsString [
	<category: 'converting'>
	"self isZero ifTrue: [^'0']."

	| str n num delta n2 found |
	self isFinite not ifTrue: [^self printString].
	str := (String new: 8) writeStream.
	self < 0 ifTrue: [str nextPut: $-].
	n := self abs + 0.0.
	num := n truncated.
	str print: num.
	num + 0.0 = n ifTrue: [^str contents].
	delta := 1 / 10.
	found := false.
	
	[
	[n2 := num + delta.
	n2 < n] whileTrue: [num := n2].
	num = n 
	    ifTrue: [found := true]
	    ifFalse: 
		[n2 = n 
		    ifTrue: 
			[num := n2.
			found := true]].
	found] 
		whileFalse: [delta := delta / 10].
	num = n ifFalse: [self halt].
	str nextPut: $..
	num := num - num truncated.
	[num = 0] whileFalse: 
		[num := num * 10.
		str print: num truncated.
		num := num - num truncated].
	^str contents
    ]

    xpathCompareEquality: aData using: aBlock [
	<category: 'xml support'>
	aData isString ifTrue: [^aBlock value: self value: aData xpathAsNumber].
	aData xpathIsNumber ifTrue: [^aBlock value: self value: aData].
	aData xpathIsBoolean 
	    ifTrue: [^aBlock value: self xpathAsBoolean value: aData].
	aData xpathIsNodeSet 
	    ifTrue: 
		[^aData unsortedNodes 
		    contains: [:nd2 | aBlock value: self value: nd2 xpathStringData xpathAsNumber]].
	self error: 'Can''t compare a %1 with a number' % {aData class}
    ]

    xpathCompareOrder: aData using: aBlock [
	<category: 'xml support'>
	| v |
	v := self xpathAsNumber.
	^aData xpathIsNodeSet 
	    ifTrue: 
		[aData unsortedNodes 
		    contains: [:nd2 | aBlock value: v value: nd2 xpathStringData xpathAsNumber]]
	    ifFalse: [aBlock value: v value: aData xpathAsNumber]
    ]

    xpathIsNumber [
	<category: 'xml support'>
	^true
    ]

    xpathMayRequireNodeSetTopLevel [
	<category: 'xml support'>
	^true
    ]

    xpathMayRequireSortTopLevel [
	<category: 'xml support'>
	^true
    ]

]



Attribute extend [

    xpathStringData [
	<category: 'accessing'>
	^self characterData
    ]

]



String extend [

    xpathAsBoolean [
	<category: 'converting'>
	^self size > 0
    ]

    xpathAsNumber [
	<category: 'converting'>
	| s foundDigit numerator denominator ch |
	s := self readStream.
	s skipSeparators.
	foundDigit := false.
	numerator := 0.
	denominator := (s peekFor: $-) ifTrue: [-1] ifFalse: [1].
	[(ch := s next) notNil and: [ch isDigit]] whileTrue: 
		[numerator := numerator * 10 + ch digitValue.
		foundDigit := true].
	ch = $. 
	    ifTrue: 
		[[(ch := s next) notNil and: [ch isDigit]] whileTrue: 
			[numerator := numerator * 10 + ch digitValue.
			denominator := denominator * 10.
			foundDigit := true]].
	(ch == nil or: [ch isSeparator]) ifFalse: [^FloatD nan].
	s skipSeparators.
	s atEnd ifFalse: [^FloatD nan].
	foundDigit ifFalse: [^FloatD nan].
	^numerator / denominator + 0.0
    ]

    xpathAsString [
	<category: 'converting'>
	^self
    ]

    xpathCompareEquality: aData using: aBlock [
	<category: 'xml support'>
	aData isString ifTrue: [^aBlock value: self value: aData].
	aData xpathIsNumber 
	    ifTrue: [^aBlock value: self xpathAsNumber value: aData].
	aData xpathIsBoolean 
	    ifTrue: [^aBlock value: self xpathAsBoolean value: aData].
	aData xpathIsNodeSet 
	    ifTrue: 
		[^aData unsortedNodes 
		    contains: [:nd2 | aBlock value: self value: nd2 xpathStringData]].
	self error: 'Can''t compare a %1 with a string' % {aData class}
    ]

    xpathCompareOrder: aData using: aBlock [
	<category: 'xml support'>
	| v |
	v := self xpathAsNumber.
	^aData xpathIsNodeSet 
	    ifTrue: 
		[aData unsortedNodes 
		    contains: [:nd2 | aBlock value: v value: nd2 xpathStringData xpathAsNumber]]
	    ifFalse: [aBlock value: v value: aData xpathAsNumber]
    ]

]



Namespace current: XML [
    XML.XPathFunction initialize.
    XML.XPathParser initialize.
    XML.XPathBinaryExpression initialize
]

