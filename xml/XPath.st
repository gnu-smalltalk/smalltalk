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



Namespace current: XML!

Object subclass: #XPathNodeContext
    instanceVariableNames: 'documentOrder nodes index node baseNode variables '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

ReadStream subclass: #XPathReadStream
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

Object subclass: #XPathExpression
    instanceVariableNames: 'predicates child '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathExpression subclass: #XPathUnion
    instanceVariableNames: 'arguments '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathExpression subclass: #XPathStep
    instanceVariableNames: 'axisName baseTest namespace type parent '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathParentNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathPrecedingNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathAncestorNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathChildNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathFollowingNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathExpression subclass: #XPathVariable
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathExpression subclass: #XPathFunction
    instanceVariableNames: 'name arguments valueBlock requiresSort requiresNodeSet '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathFunction class instanceVariableNames: 'functions '!

XPathStep subclass: #XPathPrecedingSiblingNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathRoot
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathExpression subclass: #XPathBinaryExpression
    instanceVariableNames: 'operator argument1 argument2 valueBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathBinaryExpression class instanceVariableNames: 'operators '!

Array variableSubclass: #XPathSortingVector
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathFollowingSiblingNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

Object subclass: #XPathNodeTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathNodeTest subclass: #XPathTypedNodeTest
    instanceVariableNames: 'typeName value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathNodeTest subclass: #XPathTaggedNodeTest
    instanceVariableNames: 'namespace qualifier type '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathTerminator
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathDescendantNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

Object subclass: #XPathParser
    instanceVariableNames: 'pushBack hereChar stack buffer source token tokenType xmlNode functions '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathParser class instanceVariableNames: 'nodeTypes typeTable '!

XPathStep subclass: #XPathAttributeNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

XPathStep subclass: #XPathCurrentNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'XML-XPath'!

!XPathNodeContext methodsFor: 'adding'!

add: aNode
    nodes add: aNode!

addAll: collection
    nodes addAll: collection!

addNodeSet: nodeSet
    nodes addAll: nodeSet unsortedNodes! !

!XPathNodeContext methodsFor: 'enumerating'!

addToXPathHolder: anAssociation for: aNodeContext
    self error: 'Should not happen--a NodeSet is being processed as if it were a single XML node'!

select: aPattern
    | result val |
    aPattern xpathMayRequireSortTopLevel
    	ifTrue: [self checkSorted]
    	ifFalse: [self checkOrdered].
    result := self copy.
    self reset.
    [self atEnd]
    	whileFalse:
    		[val := aPattern xpathEvalIn: self next.
    		(val xpathIsNumber
    				ifTrue: [val = self index]
    				ifFalse: [val xpathAsBoolean])
    			ifTrue: [result add: self node]].
    ^result!

selectMatch: aPattern
    | result |
    result := self copy.
    self reset.
    [self atEnd]
    	whileFalse:
    		[(aPattern match: self next)
    			ifTrue: [result add: self node]].
    ^result! !

!XPathNodeContext methodsFor: 'copying'!

asSingleNode
    ^self copy
    	add: self node;
    	yourself!

copy
    ^self shallowCopy postCopy!

postCopy
    nodes := IdentitySet new.
    index := 0.
    node := nil.
    documentOrder := true.! !

!XPathNodeContext methodsFor: 'streaming'!

atEnd
    ^index = nodes size!

next
    index = nodes size ifTrue: [^nil].
    self index: index + 1.
    node := nodes at: index.
    ^self!

reset
    index := 0.
    node := nil! !

!XPathNodeContext methodsFor: 'accessing'!

baseNode
    ^baseNode!

baseNode: aNode
    baseNode := aNode!

documentOrder
    documentOrder := true!

index
    ^index!

index: n
    self checkSorted.
    (n < 1 or: [n > nodes size])
    	ifTrue: [self error: 'Index out of bounds'].
    index := n.
    node := nodes at: n!

indexForNode: aNode
    self checkSorted.
    index := nodes identityIndexOf: aNode.
    index = 0 ifTrue: [self error: 'No such node found in the list'].
    node := aNode!

inverseDocumentOrder
    documentOrder := false!

node
    ^node!

size
    ^nodes size!

sort: aBlock
    nodes := nodes asSortedCollection: aBlock!

sortedNodes
    ^nodes asSortedCollection: [:n1 :n2 | n1 precedes: n2]!

unsortedNodes
    ^nodes!

variables
    ^variables!

variables: aDictionary
    variables := aDictionary! !

!XPathNodeContext methodsFor: 'initialize'!

checkOrdered
    nodes class == IdentitySet
    	ifTrue: [nodes := nodes asArray].!

checkSorted
    nodes class == IdentitySet
    	ifTrue:
    		[nodes size < 4
    			ifTrue: [nodes := documentOrder
    				ifTrue: [nodes asSortedCollection: [:n1 :n2 | n1 precedes: n2]]
    				ifFalse: [nodes asSortedCollection: [:n1 :n2 | n2 precedes: n1]]]
    			ifFalse:
    				[nodes := nodes asArray collect: [:nd | XPathSortingVector fromXmlNode: nd].
    				nodes := documentOrder
    					ifTrue: [nodes asSortedCollection: [:n1 :n2 | n1 <= n2]]
    					ifFalse: [nodes asSortedCollection: [:n1 :n2 | n2 <= n1]].
    				nodes := nodes collect: [:nd | nd value]]].!

ensureSorted
    nodes class == IdentitySet
    	ifFalse: [self error: 'This collection was already sorted once and may not be in correct sort order'].
    self checkSorted!

initialize
    nodes := IdentitySet new.
    documentOrder := true! !

!XPathNodeContext methodsFor: 'testing'!

contains: aBlock
    | match |
    match := nodes detect: aBlock ifNone: [].
    ^match notNil!

xpathIsNodeSet
    ^true! !

!XPathNodeContext methodsFor: 'printing'!

printOn: aStream
    self basicPrintOn: aStream! !

!XPathNodeContext methodsFor: 'functions'!

sum
    ^(nodes inject: 0.0d into: [:i :nd | i + nd xpathStringData xpathAsNumber])! !

!XPathNodeContext methodsFor: 'coercing'!

xpathAsBoolean
    ^self size > 0!

xpathAsNumber
    ^self xpathAsString xpathAsNumber!

xpathAsString
    | list |
    nodes size = 0 ifTrue: [^''].
    list := nodes asSortedCollection: [:n1 :n2 | n1 precedes: n2].
    ^list first xpathStringData! !

!XPathNodeContext methodsFor: 'comparing'!

xpathCompareEquality: aData using: aBlock
    aData isString
    	ifTrue: [^nodes contains: [:nd | aBlock value: nd xpathStringData value: aData]].
    aData xpathIsNumber
    	ifTrue: [^nodes contains: [:nd | aBlock value: nd xpathStringData xpathAsNumber value: aData]].
    aData xpathIsBoolean
    	ifTrue: [^nodes contains: [:nd | aBlock value: nd xpathStringData xpathAsBoolean value: aData]].
    aData xpathIsNodeSet
    	ifTrue: [^nodes contains: [:nd1 |
    			aData unsortedNodes contains: [:nd2 |
    				aBlock value: nd1 xpathStringData value: nd2 xpathStringData]]].
    self error: ('Can''t compare a %1 with a node set' bindWith: aData class printString)!

xpathCompareOrder: aData using: aBlock
    ^aData xpathIsNodeSet
    	ifTrue: [self unsortedNodes contains: [:nd1 || v |
    				v := nd1 xpathStringData xpathAsNumber.
    				aData unsortedNodes contains: [:nd2 |
    					aBlock value: v value: nd2 xpathStringData xpathAsNumber]]]
    	ifFalse: [| v |
    			v := aData xpathAsNumber.
    			self unsortedNodes contains: [:nd |
    				aBlock value: nd xpathStringData xpathAsNumber value: v]]! !

!XPathNodeContext class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!XPathReadStream methodsFor: 'private'!

pastEnd
    "The receiver has attempted to read past the end, answer nil."

    ^nil! !

!XPathExpression methodsFor: 'accessing'!

addPredicate: aPredicate
    predicates := predicates copyWith: aPredicate!

asUnion
    ^XPathUnion new add: self!

child
    ^child!

child: aStep
    child := aStep!

enumerate: aBlock
    aBlock value: self.
    predicates do: [:p | p enumerate: aBlock].
    child enumerate: aBlock.!

predicates
    ^predicates!

xpathUsedVarNames
    | list |
    list := OrderedCollection new.
    self enumerate: [:exp |
    	(exp isKindOf: XPathVariable)
    		ifTrue: [list add: exp name]].
    ^list! !

!Object methodsFor: 'xpath'!

xpathUsedVarNames
    ^OrderedCollection new! !

!XPathExpression methodsFor: 'matching'!

baseValueIn: aNodeContext
    self subclassResponsibility!

isMatchFor: anXmlNode
    ^self isLocalMatchFor: anXmlNode!

match: aNodeContext
    | base |
    base := self.
    [base child == nil]
    	whileFalse: [base := base child].
    ^base simpleMatchFor: aNodeContext node isComplex: false do:
    	[:root :complex || ns found |
    	complex not or:
    		[ns := aNodeContext copy add: root; index: 1.
    		found := false.
    		self valueIn: ns do: [:nd | nd == aNodeContext node ifTrue: [found := true]].
    		found]]!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    ^self subclassResponsibility!

valueIn: aNodeContext do: aBlock
    | result |
    result := self baseValueIn: aNodeContext.
    result xpathIsNodeSet
    	ifTrue:
    		[1 to: predicates size do: [:i |
    			result := result select: (predicates at: i)].
    		result reset.
    		[result atEnd]
    			whileFalse: [child valueIn: result next do: aBlock]]
    	ifFalse: [(predicates isEmpty and: [child isTerminator])
    		ifTrue: [aBlock value: result]
    		ifFalse: [self error: 'The expression %1 does not represent a node set']].!

xpathEvalIn: aNodeContext
    "This is private protocol--see #xpathValueIn: for the client protocol"

    | nc |
    nc := Association new.
    self valueIn: aNodeContext
    	do: [:x | x addToXPathHolder: nc for: aNodeContext].
    ^nc value == nil
    	ifTrue: [aNodeContext copy]
    	ifFalse: [nc value]!

xpathValueFor: anXmlNode variables: vars
    ^self xpathValueIn: (XPathNodeContext new add: anXmlNode; index: 1; variables: vars)!

xpathValueIn: aNodeContext
    "This is public protocol only--see #xpathEvalIn: for internal clients"

    aNodeContext baseNode: aNodeContext node.
    ^self xpathEvalIn: aNodeContext! !

!XPathExpression methodsFor: 'printing'!

completeChildPrintOn: aStream
    self completePrintOn: aStream.!

completePrintOn: aStream
    self printTestOn: aStream.
    predicates do: [:p | self printPredicate: p on: aStream].
    self child isTerminator
    	ifFalse: [aStream nextPut: $/].
    self child completeChildPrintOn: aStream.!

printOn: aStream
    self completePrintOn: aStream!

printPredicate: p on: aStream
    aStream nextPutAll: '['.
    aStream print: p.
    aStream nextPutAll: ']'!

printTestOn: aStream
    self subclassResponsibility! !

!XPathExpression methodsFor: 'initialize'!

initialize
    predicates := #().
    child := XPathTerminator new.
    child parent: self! !

!XPathExpression methodsFor: 'testing'!

xpathMayRequireNodeSet
    ^self subclassResponsibility!

xpathMayRequireNodeSetTopLevel
    ^self subclassResponsibility!

xpathMayRequireSort
    ^self subclassResponsibility!

xpathMayRequireSortTopLevel
    ^self subclassResponsibility! !

!XPathExpression class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!XPathExpression class methodsFor: 'coercing'!

notANumber
    ^FloatD nan!

stringToNumber: aString
    | s foundDigit numerator denominator ch |
    s := aString readStream.
    s skipSeparators.
    foundDigit := false.
    numerator := 0.
    denominator := 1.
    [(ch := s next) notNil and: [ch isDigit]]
    	whileTrue:
    		[numerator := numerator * 10 + ch digitValue.
    		foundDigit := true].
    ch = $.
    	ifTrue: [[(ch := s next) notNil and: [ch isDigit]]
    		whileTrue:
    			[numerator := numerator * 10 + ch digitValue.
    			denominator := denominator * 10.
    			foundDigit := true]].
    (ch == nil or: [ch isSeparator]) ifFalse: [^self notANumber].
    s skipSeparators.
    s atEnd ifFalse: [^self notANumber].
    foundDigit ifFalse: [^self notANumber].
    ^(numerator / denominator) + 0.0d! !

!XPathUnion methodsFor: 'accessing'!

add: aNode
    arguments := arguments copyWith: aNode!

arguments
    ^arguments!

asUnion
    ^self!

enumerate: aBlock
    super enumerate: aBlock.
    arguments do: [:a | a enumerate: aBlock].! !

!XPathUnion methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nc |
    nc := aNodeContext copy documentOrder.
    1 to: arguments size do: [:a |
    	nc addNodeSet: ((arguments at: a) xpathEvalIn: aNodeContext)].
    ^nc!

match: aNodeContext
    1 to: arguments size do: [:a |
    	((arguments at: a) match: aNodeContext) ifTrue: [^true]].
    ^false! !

!XPathUnion methodsFor: 'initialize'!

initialize
    super initialize.
    arguments := #()! !

!XPathUnion methodsFor: 'printing'!

printTestOn: aStream
    arguments do: [:a | aStream print: a] separatedBy: [aStream nextPutAll: '|'].! !

!XPathStep methodsFor: 'accessing'!

axisName
    ^axisName!

axisName: aName
    axisName := aName!

baseTest
    ^baseTest!

baseTest: aNodeTest
    baseTest := aNodeTest!

child
    ^child!

child: aStep
    child := aStep!

parent
    ^parent!

parent: aStep
    parent := aStep!

startOfPath
    | p |
    p := self.
    [p isStartOfPath]
    	whileFalse: [p := p parent].
    ^p! !

!XPathStep methodsFor: 'testing'!

hasComplexPredicate
    ^predicates inject: false into: [:b :exp | b or: [exp xpathMayRequireNodeSetTopLevel]]!

isStartOfPath
    ^parent == nil!

isTerminator
    ^false!

xpathMayRequireNodeSet
    ^false!

xpathMayRequireNodeSetTopLevel
    ^false!

xpathMayRequireSort
    ^false!

xpathMayRequireSortTopLevel
    ^false! !

!XPathStep methodsFor: 'printing'!

printTestOn: aStream
    aStream nextPutAll: self axisName, '::'.
    baseTest printOn: aStream! !

!XPathStep class methodsFor: 'private'!

axisNames
    ^#()! !

!XPathParentNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | result |
    result := aNodeContext copy documentOrder.
    (baseTest match: aNodeContext node parent)
    	ifTrue: [result add: aNodeContext node parent].
    ^result! !

!XPathParentNode class methodsFor: 'private'!

axisNames
    ^#('parent')! !

!XPathPrecedingNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc |
    nd := aNodeContext node.
    nc := aNodeContext copy inverseDocumentOrder.
    self from: nd do: [:nd1 |
    	(baseTest match: nd1)
    		ifTrue: [nc add: nd1]].
    ^nc!

from: aNode do: aBlock
    | current stack ignoreAll |
    ignoreAll := IdentitySet new.
    stack := OrderedCollection new.
    current := aNode.
    [ignoreAll add: current.
    current isDocument not] whileTrue:
    	[stack addFirst: current parent -> (current parent children indexOf: current).
    	current := current parent].
    current := aNode.
    [current isDocument
    	ifTrue: [^self]
    	ifFalse: [stack last value = 1
    		ifTrue: [current := stack removeLast key]
    		ifFalse:
    			[stack last value: stack last value - 1.
    			current := stack last key children at: stack last value.
    			[current isElement and: [current children isEmpty not]]
    				whileTrue:
    					[stack add: current -> current children size.
    					current := current children last]]].
    (ignoreAll includes: current) ifFalse: [aBlock value: current]] repeat! !

!XPathPrecedingNode class methodsFor: 'private'!

axisNames
    ^#('preceding')! !

!XPathAncestorNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc nextNode |
    nd := aNodeContext node.
    nc := aNodeContext copy inverseDocumentOrder.
    self axisName = 'ancestor-or-self'
    	ifTrue: [nextNode := nd]
    	ifFalse: [nextNode := nd parent].
    [nextNode == nil]
    	whileFalse:
    		[(baseTest match: nextNode)
    			ifTrue: [nc add: nextNode].
    		nextNode := nextNode parent].
    ^nc! !

!XPathAncestorNode class methodsFor: 'private'!

axisNames
    ^#('ancestor' 'ancestor-or-self')! !

!XPathChildNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc |
    nd := aNodeContext node.
    nc := aNodeContext copy documentOrder.
    (nd isElement or: [nd isDocument])
    	ifFalse: [^nc].
    aNodeContext node children do: [:childNode |
    	(baseTest match: childNode)
    		ifTrue: [nc add: childNode]].
    ^nc!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    | hasCP set |
    anXmlNode isAttribute ifTrue: [^false].
    (baseTest match: anXmlNode) ifFalse: [^false].
    (hasCP := self hasComplexPredicate)
    	ifFalse:
    		[set := XPathNodeContext new add: anXmlNode.
    		1 to: predicates size do: [:i |
    			set := set select: (predicates at: i)].
    		set size = 0 ifTrue: [^false]].
    parent == nil ifTrue: [^aBlock value: anXmlNode parent value: complex | hasCP].
    ^parent simpleMatchFor: anXmlNode parent
    	isComplex: complex | hasCP
    	do: aBlock! !

!XPathChildNode methodsFor: 'printing'!

printTestOn: aStream
    axisName == nil
    	ifTrue: [baseTest printOn: aStream]
    	ifFalse: [super printTestOn: aStream]! !

!XPathChildNode class methodsFor: 'private'!

axisNames
    ^#('child')! !

!XPathFollowingNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc |
    nd := aNodeContext node.
    nc := aNodeContext copy documentOrder.
    self from: nd do: [:nd1 |
    	(baseTest match: nd1)
    		ifTrue: [nc add: nd1]].
    ^nc!

from: aNode do: aBlock
    | current stack idx followChildren |
    current := aNode.
    stack := OrderedCollection new.
    current isDocument ifFalse:
    	[[current parent isDocument not] whileTrue:
    		[stack addFirst: current parent -> (current parent children indexOf: current).
    		current := current parent]].
    current := aNode.
    "By setting followChildren to false the first time only, we ignore
    all descendents of aNode."
    followChildren := false.
    [(followChildren and: [(current isElement or: [current isDocument]) and: [current children size > 0]])
    	ifTrue: [stack add: current->1. current := current children at: 1.]
    	ifFalse:
    		[[stack isEmpty ifTrue: [^self].
    		stack last key children size > stack last value]
    			whileFalse:
    				[current := stack removeLast key].
    		stack last value: (idx := stack last value + 1).
    		current := stack last key children at: idx].
    followChildren := true.
    aBlock value: current.] repeat! !

!XPathFollowingNode class methodsFor: 'private'!

axisNames
    ^#('following')! !

!XPathVariable methodsFor: 'matching'!

baseValueIn: aNodeContext
    | var |
    var := aNodeContext variables
    	at: self name
    	ifAbsent: [self error: ('No binding found for the variable $%1' bindWith: self name)].
    ^var! !

!XPathVariable methodsFor: 'accessing'!

name
    ^name!

name: aName
    name := aName! !

!XPathVariable methodsFor: 'printing'!

printTestOn: aStream
    aStream nextPutAll: '$', name! !

!XPathFunction methodsFor: 'accessing'!

addArgument: arg
    arguments := arguments copyWith: arg!

arguments
    ^arguments!

enumerate: aBlock
    super enumerate: aBlock.
    self arguments do: [:i | i enumerate: aBlock].!

name
    ^name!

name: nm
    name := nm!

requiresNodeSet
    ^requiresNodeSet!

requiresNodeSet: bool
    requiresNodeSet := bool!

requiresSort
    ^requiresSort!

requiresSort: bool
    requiresSort := bool! !

!XPathFunction methodsFor: 'testing'!

answersNumber
    ^#('sum' 'round' 'count' 'last' 'position' 'string-length' 'floor' 'ceiling') includes: self name!

xpathMayRequireNodeSet
    ^requiresNodeSet
    	or: [arguments inject: false into: [:b :arg | b or: [arg xpathMayRequireNodeSet]]]!

xpathMayRequireNodeSetTopLevel
    ^self answersNumber or: [self xpathMayRequireNodeSet]!

xpathMayRequireSort
    ^requiresSort
    	or: [arguments inject: false into: [:b :arg | b or: [arg xpathMayRequireSort]]]!

xpathMayRequireSortTopLevel
    ^self answersNumber or: [self xpathMayRequireSort]! !

!XPathFunction methodsFor: 'matching'!

baseValueIn: aNodeContext
    ^valueBlock value: self value: aNodeContext! !

!XPathFunction methodsFor: 'initialize'!

initialize
    super initialize.
    arguments := #().
    requiresSort := false.
    requiresNodeSet := false!

valueBlock: aBlock
    valueBlock := aBlock! !

!XPathFunction methodsFor: 'printing'!

printTestOn: aStream
    aStream nextPutAll: name, '('.
    arguments do: [:a | aStream print: a] separatedBy: [aStream nextPutAll: ','].
    aStream nextPutAll: ')'.! !

!XPathFunction class methodsFor: 'class initialization'!

baseFunctions
    ^functions!

initialize
    "XPathFunction initialize"

    functions == nil
    	ifTrue: [functions := Dictionary new]
    	ifFalse: [functions keys do: [:k | functions removeKey: k]].
    self initializeBoolean.
    self initializeStrings.
    self initializeNodeSets.
    self initializeNumeric.!

initializeBoolean
    functions at: 'boolean' put: (self new
    		name: 'boolean';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'boolean() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathAsBoolean]).
    functions at: 'not' put: (self new
    		name: 'not';
    		valueBlock: [:fn :ns |
    			(fn arguments first xpathEvalIn: ns) xpathAsBoolean not]).
    functions at: 'true' put: (true).
    functions at: 'false' put: (false).!

initializeNodeSets
    functions at: 'count' put: (self new
    		requiresNodeSet: true;
    		name: 'count';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'count() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathIsNodeSet ifFalse: [self error: 'count() requires a nodeset as an argument'].
    				ns2 size]).
    functions at: 'position' put: (self new
    		requiresNodeSet: true;
    		requiresSort: true;
    		name: 'position';
    		valueBlock: [:fn :ns |
    				fn arguments size > 0 ifTrue: [self error: 'position() cannot take any arguments'].
    				ns index]).
    functions at: 'last' put: (self new
    		requiresNodeSet: true;
    		name: 'last';
    		valueBlock: [:fn :ns |
    				fn arguments size > 0 ifTrue: [self error: 'last() cannot take any arguments'].
    				ns size]).
    functions at: 'local-name' put: (self new
    		name: 'local-name';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'local-name() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathIsNodeSet ifFalse: [self error: 'local-name() requires a nodeset as an argument'].
    				ns2 documentOrder; index: 1.
    				(ns2 node isElement or: [ns2 node isAttribute])
    					ifTrue: [ns2 node tag type]
    					ifFalse: ['']]).
    functions at: 'namespace-uri' put: (self new
    		name: 'namespace-uri';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'namespace-uri() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathIsNodeSet ifFalse: [self error: 'namespace-uri() requires a nodeset as an argument'].
    				ns2 documentOrder; index: 1.
    				(ns2 node isElement or: [ns2 node isAttribute])
    					ifTrue: [ns2 node tag namespace]
    					ifFalse: ['']]).
    functions at: 'name' put: (self new
    		name: 'name';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'name() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathIsNodeSet ifFalse: [self error: 'name() requires a nodeset as an argument'].
    				ns2 documentOrder; index: 1.
    				(ns2 node isElement or: [ns2 node isAttribute])
    					ifTrue: [ns2 node tag asString]
    					ifFalse: ['']]).
    functions at: 'id' put: (self new
    		name: 'id';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size ~= 1 ifTrue: [self error: 'id() only takes one argument'].
    				ns2 := fn arguments first xpathEvalIn: ns.
    				ns2 := ns2 xpathAsString.
    				ns copy add: (ns node document atID: ns2 ifAbsent: [self error: 'ID "', ns2, '" not found'])]).
    functions at: 'current' put: (self new
    		requiresNodeSet: true;
    		name: 'current';
    		valueBlock: [:fn :ns |
    				fn arguments size > 0 ifTrue: [self error: 'current() takes no arguments'].
    				ns copy add: ns baseNode; index: 1]).!

initializeNumeric
    functions at: 'number' put: (self new
    		name: 'number';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'number() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathAsNumber]).
    functions at: 'round' put: (self new
    		name: 'round';
    		valueBlock: [:fn :ns |
    				fn arguments size ~= 1 ifTrue: [self error: 'round() only takes one argument'].
    				(fn arguments first xpathEvalIn: ns) xpathAsNumber rounded]).
    functions at: 'floor' put: (self new
    		name: 'floor';
    		valueBlock: [:fn :ns |
    				fn arguments size ~= 1 ifTrue: [self error: 'floor() only takes one argument'].
    				(fn arguments first xpathEvalIn: ns) xpathAsNumber floor]).
    functions at: 'ceiling' put: (self new
    		name: 'ceiling';
    		valueBlock: [:fn :ns |
    				fn arguments size ~= 1 ifTrue: [self error: 'ceiling() only takes one argument'].
    				(fn arguments first xpathEvalIn: ns) xpathAsNumber ceiling]).
    functions at: 'sum' put: (self new
    		name: 'sum';
    		valueBlock: [:fn :ns |
    				fn arguments size ~= 1 ifTrue: [self error: 'sum() only takes one argument'].
    				(fn arguments first xpathEvalIn: ns) sum]).!

initializeStrings
    functions at: 'string' put: (self new
    		name: 'string';
    		valueBlock: [:fn :ns || ns2 |
    				fn arguments size > 1 ifTrue: [self error: 'string() only takes one argument'].
    				ns2 := fn arguments size = 1
    					ifTrue: [fn arguments first xpathEvalIn: ns]
    					ifFalse: [ns asSingleNode].
    				ns2 xpathAsString]).
    functions at: 'concat' put: (self new
    		name: 'concat';
    		valueBlock: [:fn :ns || s |
    			s := ''.
    			fn arguments do: [:exp | s := s, (exp xpathEvalIn: ns) xpathAsString].
    			s]).
    functions at: 'contains' put: (self new
    		name: 'contains';
    		valueBlock: [:fn :ns || s1 s2 i |
    			fn arguments size = 2 ifFalse: [self error: 'contains() takes two arguments'].
    			s1 := (fn arguments at: 1) xpathEvalIn: ns.
    			s2 := (fn arguments at: 2) xpathEvalIn: ns.
    			i := s1 xpathAsString indexOfSubCollection: s2 xpathAsString startingAt: 1.
    			i > 0]).
    functions at: 'translate' put: (self new
    		name: 'translate';
    		valueBlock: [:fn :ns || s1 s2 s3 |
    			fn arguments size = 3 ifFalse: [self error: 'translate() takes three arguments'].
    			s1 := (fn arguments at: 1) xpathEvalIn: ns.
    			s2 := (fn arguments at: 2) xpathEvalIn: ns.
    			s3 := (fn arguments at: 3) xpathEvalIn: ns.
    			(self
    					translate: s1 xpathAsString
    					from: s2 xpathAsString
    					to: s3 xpathAsString)]).
    functions at: 'string-length' put: (self new
    		name: 'string-length';
    		valueBlock: [:fn :ns || s1 |
    			fn arguments size < 2 ifFalse: [self error: 'string-length() takes no more than 1 argument'].
    			s1 := (fn arguments size = 0
    				ifTrue: [ns asSingleNode]
    				ifFalse: [fn arguments first xpathEvalIn: ns]) xpathAsString.
    			s1 size]).
    functions at: 'substring' put: (self new
    		name: 'substring';
    		valueBlock: [:fn :ns || s1 i1 i2 |
    			(fn arguments size between: 2 and: 3) ifFalse: [self error: 'substring() takes two or three arguments'].
    			s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
    			i1 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsNumber.
    			i2 := fn arguments size = 2
    				ifTrue: [1.0d10]
    				ifFalse: [((fn arguments at: 3) xpathEvalIn: ns) xpathAsNumber].
    			i2 := (i1 + i2 - 1) rounded min: s1 size.
    			i1 := i1 rounded max: 1.
    			(s1 copyFrom: i1 to: i2)]).
    functions at: 'starts-with' put: (self new
    		name: 'starts-with';
    		valueBlock: [:fn :ns || s1 s2 |
    			fn arguments size = 2 ifFalse: [self error: 'starts-with() takes two arguments'].
    			s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
    			s2 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
    			(s1 indexOfSubCollection: s2 startingAt: 1) = 1]).
    functions at: 'substring-before' put: (self new
    		name: 'substring-before';
    		valueBlock: [:fn :ns || s1 s2 i |
    			fn arguments size = 2 ifFalse: [self error: 'substring-before() takes two arguments'].
    			s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
    			s2 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
    			i := s1 indexOfSubCollection: s2 startingAt: 1.
    			(i = 0 ifTrue: [''] ifFalse: [s1 copyFrom: 1 to: i - 1])]).
    functions at: 'substring-after' put: (self new
    		name: 'substring-after';
    		valueBlock: [:fn :ns || s1 s2 i |
    			fn arguments size = 2 ifFalse: [self error: 'substring-after() takes two arguments'].
    			s1 := ((fn arguments at: 1) xpathEvalIn: ns) xpathAsString.
    			s2 := ((fn arguments at: 2) xpathEvalIn: ns) xpathAsString.
    			i := s1 indexOfSubCollection: s2 startingAt: 1.
    			(i = 0 ifTrue: [''] ifFalse: [s1 copyFrom: i+s2 size to: s1 size])]).
    functions at: 'normalize-space' put: (self new
    		name: 'normalize-space';
    		valueBlock: [:fn :ns || ns2 |
    				ns2 := fn arguments first xpathEvalIn: ns.
    				ns2 := ns2 xpathAsString.
    				self normalizeWhitespace: ns2]).! !

!XPathFunction class methodsFor: 'function implementations'!

normalizeWhitespace: aString
    | ch str buffer space |
    str := aString readStream.
    buffer := String new writeStream.
    space := false.
    [str skipSeparators; atEnd]
    	whileFalse:
    		[space ifTrue: [buffer space].
    		[(ch := str next) notNil and: [ch isSeparator not]]
    			whileTrue: [buffer nextPut: ch].
    		space := true].
    ^buffer contents!

translate: base from: src to: dest
    | dir result c |
    dir := IdentityDictionary new.
    src size to: 1 by: -1 do: [:i |
    	dir at: (src at: i) put: (i > dest size ifTrue: [nil] ifFalse: [dest at: i])].
    result := (String new: base size) writeStream.
    1 to: base size do: [:i |
    	c := base at: i.
    	c := dir at: c ifAbsent: [c].
    	c == nil ifFalse: [result nextPut: c]].
    ^result contents! !

!XPathPrecedingSiblingNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc list i |
    nd := aNodeContext node.
    nc := aNodeContext copy inverseDocumentOrder.
    list := nd parent children.
    i := list identityIndexOf: nd.
    (list copyFrom: 1 to: i - 1) do: [:childNode |
    	(baseTest match: childNode)
    		ifTrue: [nc add: childNode]].
    ^nc! !

!XPathPrecedingSiblingNode class methodsFor: 'private'!

axisNames
    ^#('preceding-sibling')! !

!XPathRoot methodsFor: 'matching'!

baseValueIn: aNodeContext
    ^aNodeContext copy documentOrder; add: aNodeContext node document!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    ^anXmlNode isDocument
    	and: [aBlock value: anXmlNode value: complex].! !

!XPathRoot methodsFor: 'printing'!

completePrintOn: aStream
    aStream nextPut: $/.
    self child completeChildPrintOn: aStream.! !

!XPathRoot methodsFor: 'testing'!

isStartOfPath
    ^true! !

!XPathBinaryExpression methodsFor: 'accessing'!

arg1
    ^argument1!

arg2
    ^argument2!

enumerate: aBlock
    super enumerate: aBlock.
    self arg1 enumerate: aBlock.
    self arg2 enumerate: aBlock.! !

!XPathBinaryExpression methodsFor: 'matching'!

baseValueIn: aNodeContext
    ^valueBlock value: self value: aNodeContext! !

!XPathBinaryExpression methodsFor: 'initialize'!

operator: op with: arg1 with: arg2
    operator := op.
    argument1 := arg1.
    argument2 := arg2.!

valueBlock: aBlock
    valueBlock := aBlock! !

!XPathBinaryExpression methodsFor: 'printing'!

printTestOn: aStream
    argument1 printOn: aStream.
    aStream space; nextPutAll: operator; space.
    argument2 printOn: aStream.! !

!XPathBinaryExpression methodsFor: 'testing'!

xpathMayRequireNodeSet
    ^self arg1 xpathMayRequireNodeSet or: [self arg2 xpathMayRequireNodeSet]!

xpathMayRequireNodeSetTopLevel
    (#(#'+' #'-' #'*' #'div' #'mod') includes: operator)
    	ifTrue: [^true].
    (#(#'=' #'!=' #'<' #'>' #'<=' #'>=' #'|' #'and' #'or') includes: operator)
    	ifTrue: [^self arg1 xpathMayRequireNodeSet or: [self arg2 xpathMayRequireNodeSet]].
    self notYetImplementedError!

xpathMayRequireSort
    ^self arg1 xpathMayRequireSort or: [self arg2 xpathMayRequireSort]!

xpathMayRequireSortTopLevel
    (#(#'+' #'-' #'*' #'div' #'mod') includes: operator)
    	ifTrue: [^true].
    (#(#'=' #'!=' #'<' #'>' #'<=' #'>=' #'|' #'and' #'or') includes: operator)
    	ifTrue: [^self arg1 xpathMayRequireSort or: [self arg2 xpathMayRequireSort]].
    self notYetImplementedError! !

!XPathBinaryExpression class methodsFor: 'class initialization'!

initialize
    "XPathBinaryExpression initialize"

    operators := Dictionary new.
    self initializeBoolean.
    self initializeComparison.
    self initializeNumeric!

initializeBoolean
    operators at: #and put: (self new
    			operator: #and with: nil with: nil;
    			valueBlock: [:exp :ns || b1 b2 |
    					b1 := (exp arg1 xpathEvalIn: ns) xpathAsBoolean.
    					b2 := (exp arg2 xpathEvalIn: ns) xpathAsBoolean.
    					b1 & b2]).
    operators at: #or put: (self new
    			operator: #or with: nil with: nil;
    			valueBlock: [:exp :ns || b1 b2 |
    					b1 := (exp arg1 xpathEvalIn: ns) xpathAsBoolean.
    					b2 := (exp arg2 xpathEvalIn: ns) xpathAsBoolean.
    					b1 | b2]).!

initializeComparison
    operators at: #= put: (self new
    			operator: #= with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns)
    						xpathCompareEquality: (exp arg2 xpathEvalIn: ns)
    						using: [:v1 :v2 | v1 = v2]]).
    operators at: #'!=' put: (self new
    			operator: #'!=' with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns)
    						xpathCompareEquality: (exp arg2 xpathEvalIn: ns)
    						using: [:v1 :v2 | v1 ~= v2]]).
    operators at: #< put: (self new
    			operator: #< with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns)
    						xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
    						using: [:v1 :v2 | v1 < v2]]).
    operators at: #> put: (self new
    			operator: #> with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns)
    						xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
    						using: [:v1 :v2 | v1 > v2]]).
    operators at: #<= put: (self new
    			operator: #<= with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns)
    						xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
    						using: [:v1 :v2 | v1 <= v2]]).
    operators at: #>= put: (self new
    			operator: #>= with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns)
    						xpathCompareOrder: (exp arg2 xpathEvalIn: ns)
    						using: [:v1 :v2 | v1 >= v2]]).!

initializeNumeric
    operators at: #+ put: (self new
    			operator: #+ with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns) xpathAsNumber +
    						(exp arg2 xpathEvalIn: ns) xpathAsNumber]).
    operators at: #- put: (self new
    			operator: #- with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns) xpathAsNumber -
    						(exp arg2 xpathEvalIn: ns) xpathAsNumber]).
    operators at: #* put: (self new
    			operator: #* with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns) xpathAsNumber *
    						(exp arg2 xpathEvalIn: ns) xpathAsNumber]).
    operators at: #div put: (self new
    			operator: #div with: nil with: nil;
    			valueBlock: [:exp :ns |
    					(exp arg1 xpathEvalIn: ns) xpathAsNumber /
    						(exp arg2 xpathEvalIn: ns) xpathAsNumber]).
    operators at: #mod put: (self new
    			operator: #mod with: nil with: nil;
    			valueBlock: [:exp :ns |
    					((exp arg1 xpathEvalIn: ns) xpathAsNumber rem:
    						(exp arg2 xpathEvalIn: ns) xpathAsNumber)]).! !

!XPathBinaryExpression class methodsFor: 'instance creation'!

operator: op with: arg1 with: arg2
    ^(operators at: op ifAbsent: [self error: ('Not implemented yet %1' bindWith: op)]) copy
	operator: op with: arg1 with: arg2! !

!XPathSortingVector methodsFor: 'sorting'!

<= aVector
    | min v1 v2 |
    min := self size min: aVector size.
    1 to: min do: [:i |
    	v1 := self at: i.
    	v2 := aVector at: i.
    	v1 = v2 ifFalse: [^v1 < v2]].
    ^self size <= aVector size! !

!XPathSortingVector methodsFor: 'accessing'!

value
    ^value!

value: aNode
    value := aNode! !

!XPathSortingVector class methodsFor: 'instance creation'!

fromXmlNode: aNode
    | list node |
    list := OrderedCollection new.
    node := aNode.
    [node isDocument]
    	whileFalse:
    		[list addFirst: (node parent children identityIndexOf: node ifAbsent: [0]).
    		node := node parent].
    ^(self withAll: list) value: aNode! !

!XPathFollowingSiblingNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc list i |
    nd := aNodeContext node.
    nc := aNodeContext copy documentOrder.
    list := nd parent children.
    i := list identityIndexOf: nd.
    (list copyFrom: i + 1 to: list size) do: [:childNode |
    	(baseTest match: childNode)
    		ifTrue: [nc add: childNode]].
    ^nc! !

!XPathFollowingSiblingNode class methodsFor: 'private'!

axisNames
    ^#('following-sibling')! !

!XPathNodeTest methodsFor: 'testing'!

isTrivial
    ^false! !

!XPathTypedNodeTest methodsFor: 'testing'!

isTrivial
    ^typeName = 'node'! !

!XPathTypedNodeTest methodsFor: 'matching'!

match: anXmlNode
    typeName = 'node' ifTrue: [^true].
    typeName = 'text' ifTrue: [^anXmlNode isText].
    typeName = 'comment' ifTrue: [^anXmlNode isComment].
    typeName = 'processing-instruction'
    	ifTrue: [^anXmlNode isProcessingInstruction
    				and: [value == nil
    				or: [value = anXmlNode name]]].
    self notYetImplementedError! !

!XPathTypedNodeTest methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: typeName, '('.
    value == nil ifFalse: [aStream nextPutAll: value].
    aStream nextPutAll: ')'.! !

!XPathTypedNodeTest methodsFor: 'accessing'!

type: aString
    typeName := aString.
    (#('comment' 'text' 'node' 'processing-instruction') includes: typeName)
    	ifFalse: [self error: 'A node test must be one of comment, text, node, or propcessing-instruction'].!

value: aString
    value := aString! !

!XPathTaggedNodeTest methodsFor: 'matching'!

match: anXmlNode
    (anXmlNode isElement or: [anXmlNode isAttribute]) ifFalse: [^false].
    namespace == nil
    	ifFalse: [namespace = anXmlNode tag namespace ifFalse: [^false]].
    ^type = #* or: [type = anXmlNode tag type]! !

!XPathTaggedNodeTest methodsFor: 'accessing'!

namespace
    ^namespace!

namespace: ns
    namespace := ns = '' ifTrue: [nil] ifFalse: [ns].!

type
    ^type!

type: aString
    type := aString! !

!XPathTaggedNodeTest methodsFor: 'printing'!

printOn: aStream
    qualifier == nil ifFalse: [aStream nextPutAll: qualifier, ':'].
    aStream nextPutAll: type! !

!XPathTerminator methodsFor: 'printing'!

completePrintOn: aStream
    ^self!

printOn: aStream
    self basicPrintOn: aStream! !

!XPathTerminator methodsFor: 'accessing'!

enumerate: aBlock
    aBlock value: self! !

!XPathTerminator methodsFor: 'initialize'!

initialize
    predicates := #().! !

!XPathTerminator methodsFor: 'testing'!

isTerminator
    ^true! !

!XPathTerminator methodsFor: 'matching'!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    ^parent simpleMatchFor: anXmlNode isComplex: complex do: aBlock!

valueIn: aNodeContext do: aBlock
    aBlock value: aNodeContext node!

valueOfAllIn: aNodeContext
    ^aNodeContext! !

!XPathDescendantNode methodsFor: 'testing'!

axisName
    ^axisName == nil
    	ifTrue: ['descendant-or-self']
    	ifFalse: [axisName]! !

!XPathDescendantNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc queue nextNode |
    nd := aNodeContext node.
    nc := aNodeContext copy documentOrder.
    queue := OrderedCollection new.
    self axisName = 'descendant-or-self'
    	ifTrue: [queue add: nd]
    	ifFalse: [nd isElement
    		ifTrue: [queue addAll: nd children]].
    nd isDocument
    	ifTrue: [queue add: nd root].
    [queue isEmpty]
    	whileFalse:
    		[nextNode := queue removeFirst.
    		(baseTest match: nextNode)
    			ifTrue: [nc add: nextNode].
    		nextNode isElement
    			ifTrue: [queue addAll: nextNode children]].
    ^nc!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    | startNode hasCP set |
    anXmlNode isAttribute ifTrue: [^false].
    (baseTest match: anXmlNode) ifFalse: [^false].
    (hasCP := self hasComplexPredicate)
    	ifFalse:
    		[set := XPathNodeContext new add: anXmlNode.
    		1 to: predicates size do: [:i |
    			set := set select: (predicates at: i)].
    		set size = 0 ifTrue: [^false halt]].
    startNode := self axisName = 'descendant'
    	ifTrue: [anXmlNode parent]
    	ifFalse: [anXmlNode].
    [parent == nil
    	ifTrue: [aBlock value: anXmlNode value: complex | hasCP]
    	ifFalse: [parent simpleMatchFor: startNode
    			isComplex: complex | hasCP
    			do: aBlock]]
    	whileFalse:
    		[startNode := startNode parent.
    		startNode == nil ifTrue: [^false]].
    ^true! !

!XPathDescendantNode methodsFor: 'printing'!

completeChildPrintOn: aStream
    (baseTest isTrivial
    		and: [predicates isEmpty
    		and: [axisName = 'descendant-or-self']])
    	ifFalse: [^super completePrintOn: aStream].
    aStream nextPut: $/.
    self child completeChildPrintOn: aStream.! !

!XPathDescendantNode class methodsFor: 'private'!

axisNames
    ^#('descendant' 'descendant-or-self')! !

!XPathParser methodsFor: 'construction'!

abbreviatedDescendant
    token = #'/'
    	ifTrue: 
    		[stack add: (XPathDescendantNode new
    					axisName: 'descendant-or-self';
    					baseTest: (XPathTypedNodeTest new type: 'node')).
    		^true].
    ^false!

arg: a1 op: operator arg: a2
    ^XPathBinaryExpression
    	operator: operator asSymbol with: a1 with: a2!

axis: axisName test: test
    | stepClass step |
    stepClass := self class nodeTypes
    			at: axisName
    			ifAbsent: [self error: ('%1 is not an axis' bindWith: axisName)].
    step := stepClass new.
    step axisName: axisName.		"Some classes represent multiple axes, and must be told which"
    step baseTest: test.
    ^step!

connectParent: parent child: child
    | p |
    p := parent.
    [p child isTerminator] whileFalse: [p := p child].
    p child: child.
    child parent: p.
    ^parent!

function: aName
    ^self functionNamed: aName!

function: aFunction arg: anArgument
    ^aFunction addArgument: anArgument!

isNodeType
    | typeName argument ok |
    typeName := stack at: stack size - 1.
    argument := stack at: stack size.
    ok := typeName = 'processing-instruction'
    	ifTrue: [true]
    	ifFalse: [(#('node' 'text' 'comment') includes: typeName)
    		ifTrue: [argument == nil]
    		ifFalse: [false]].
"	ok ifFalse: [stack removeLast]."
    ^ok!

nodeTestQualifier: qualifier type: typeName
    | ns |
    ns := self namespaceAt: qualifier.
    ^XPathTaggedNodeTest new
    	namespace: ns;
    	type: typeName!

nodeTestType: typeName
    ^XPathTaggedNodeTest new
    	type: typeName!

nodeTypeTest: typeName arg: argument
    ^XPathTypedNodeTest new
    	type: typeName;
    	value: argument!

number: aValue
    ^aValue!

selfOrParent
    token = #'.'
    	ifTrue: 
    		[self scanToken.
    		stack add: (XPathCurrentNode new
    					axisName: 'self';
    					baseTest: (XPathTypedNodeTest new type: 'node')).
    		^true].
    token = #'..'
    	ifTrue: 
    		[self scanToken.
    		stack add: (XPathParentNode new
    					axisName: 'parent';
    					baseTest: (XPathTypedNodeTest new type: 'node')).
    		^true].
    ^false!

step: step predicate: predicate
    ^step addPredicate: predicate; yourself!

string: aValue
    ^aValue!

union: path1 with: path2
    ^path1 asUnion add: path2!

variable: aName
    ^XPathVariable new name: aName! !

!XPathParser methodsFor: 'paths'!

absoluteLocationPath
    | root child |
    self scanToken. "#/"
    stack addLast: XPathRoot new.
    hereChar isNil ifTrue: [ ^true ].
    self relativeLocationPath ifFalse: [ ^false ].
    child := stack removeLast.
    root := stack removeLast.
    stack addLast: (self connectParent: root child: child).
    ^true!

anyStep
    self selfOrParent ifTrue: [ ^true ].
    self abbreviatedDescendant ifTrue: [ ^true ].
    ^self stepWithPredicates!

locationPath
    token = #/ ifTrue: [ ^self absoluteLocationPath ].
    ^self relativeLocationPath!

nodeTest
    | word word2 arg |
    token = #* ifTrue: [
        self scanToken.
        stack addLast: (self nodeTestType: #*).
        ^true
    ].

    tokenType = #word ifFalse: [ ^false ].
    word := token.
    self scanToken.

    token = $( ifTrue: [
        self scanToken.
        token = $)
            ifTrue: [ self scanToken. arg := nil ]
            ifFalse: [
                tokenType = #string ifFalse: [ ^false ].
                arg := token.
                self scanToken.
                token = $) ifFalse: [ ^false ].
            ].

        stack addLast: (self nodeTypeTest: word arg: arg).
        ^true
    ].

    (self peekFor: #':') ifFalse: [
        self verifyNotFunction ifTrue: [
            stack addLast: (self nodeTestType: word).
            ^true
        ]
    ].

    self scanToken.
    token = #* ifTrue: [
        self scanToken.
        stack addLast: (self nodeTestQualifier: word).
        ^true
    ].

    tokenType = #word ifFalse: [ ^false ].
    word2 := token.
    self scanToken.
    stack addLast: (self nodeTestQualifier: word type: word2)!

predicate
    (token = $[ and: [
        self scanToken. self expression and: [
            token = $] ]]) ifTrue: [ self scanToken. ^true ].

    ^false!

relativeLocationPath
    | parent child |
    self anyStep ifFalse: [ ^false ].
    [ token = #/ ] whileTrue: [
        self scanToken.
        self anyStep ifFalse: [ ^false ].
        child := stack removeLast.
        parent := stack removeLast.
        stack addLast: (self connectParent: parent child: child).
    ].
    ^true!

stepWithPredicates
    | axis word step predicate position |
    axis := 'child'.
    tokenType = #word ifTrue: [
        axis := token.
        self scanToken.

        "???"
        (token = $( and: [
            (#('node' 'text' 'comment' 'processing-instruction')
                includes: axis) not ]) ifTrue: [

            pushBack := #character -> $(.
            tokenType := #word.
            token := axis.
            ^false
        ].

        (self peekFor: #'::') ifFalse: [
            tokenType isNil ifFalse: [ pushBack := tokenType -> token ].
            tokenType := #word.
            token := axis.
            axis := 'child'
        ].
    ].
    token = #@ ifTrue: [
        self scanToken.
        axis := 'attribute'
    ].
    self nodeTest ifFalse: [ ^false ].

    stack addLast: (self axis: axis test: stack removeLast).

    [ self predicate ] whileTrue: [
        predicate := stack removeLast.
        step := stack removeLast.
        stack addLast: (self step: step predicate: predicate).
    ].

    ^true! !

!XPathParser methodsFor: 'expressions'!

additiveExpr
    | op arg1 arg2 |
    self multiplicativeExpr ifFalse: [ ^false ].
    [
        op := token.
        (token = #+ or: [ token = #- ]) ] whileTrue: [

        self scanToken.
        self multiplicativeExpr ifFalse: [ self error: 'error in operand of +/-' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self arg: arg1 op: op arg: arg2)
    ].
    ^true!

andExpr
    | op arg1 arg2 |
    self equalityExpr ifFalse: [ ^false ].
    [
        op := token.
        token = 'and' ] whileTrue: [

        self scanToken.
        self equalityExpr ifFalse: [ self error: 'error in operand of and' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self arg: arg1 op: op arg: arg2)
    ].
    ^true!

equalityExpr
    | op arg1 arg2 |
    self relationalExpr ifFalse: [ ^false ].
    [
        op := token.
        (token = #= or: [ token = #'!=' ]) ] whileTrue: [

        self scanToken.
        self relationalExpr ifFalse: [ self error: 'error in operand of =/!=' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self arg: arg1 op: op arg: arg2)
    ].
    ^true!

expression
    ^self orExpr!

filterExpr
    | step predicate |
    self primaryExpr ifFalse: [ ^false ].
    [ self predicate ] whileTrue: [
        predicate := stack removeLast.
        step := stack removeLast.
        stack addLast: (self step: step predicate: predicate)
    ].
    ^true!

multiplicativeExpr
    | op arg1 arg2 |
    self unaryExpr ifFalse: [ ^false ].
    [
        op := token.
        (token = #* or: [ token = 'div' or: [ token = 'mod' ]]) ] whileTrue: [

        self scanToken.
        self unaryExpr ifFalse: [ self error: 'error in operand of */div/mod' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self arg: arg1 op: op arg: arg2)
    ].
    ^true!

orExpr
    | op arg1 arg2 |
    self andExpr ifFalse: [ ^false ].
    [
        op := token.
        token = 'or' ] whileTrue: [

        self scanToken.
        self andExpr ifFalse: [ self error: 'error in operand of or' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self arg: arg1 op: op arg: arg2)
    ].
    ^true!

pathExpr
    | parent child |
    self locationPath ifTrue: [ ^true ].
    self filterExpr ifFalse: [ ^false ].

    token = #/ ifFalse: [ ^true ].
    self scanToken.
    self relativeLocationPath ifFalse: [ ^false ].

    child := stack removeLast.
    parent := stack removeLast.
    stack addLast: (self connectParent: parent child: child).
    ^true!

primaryExpr
    | function arg |
    token = $$ ifTrue: [
        self scanToken.
        tokenType = #word ifFalse: [ ^false ].
        stack addLast: (self variable: token).
        self scanToken.
        ^true
    ].
    token = $( ifTrue: [
        self scanToken.
        self expression ifFalse: [ ^false ].
        token = $) ifFalse: [ ^false ].
        self scanToken.
        ^true
    ].
    tokenType = #string ifTrue: [
        stack addLast: (self string: token).
        self scanToken.
        ^true
    ].
    tokenType = #number ifTrue: [
        stack addLast: (self number: token).
        self scanToken.
        ^true
    ].

    tokenType = #word ifTrue: [
        function := token.
        stack addLast: (self function: token).

        self scanToken.
        token = $( ifFalse: [ ^false ].
        self scanToken.
        token = $) ifFalse: [
            [
                self expression ifFalse: [ ^false ].
                arg := stack removeLast.
                function := stack removeLast.
                stack addLast: (self function: function arg: arg).
                token = $,
            ] whileTrue.
            token = $) ifFalse: [ ^false ].
        ].

        self scanToken.
        ^true
    ].

    ^false!

relationalExpr
    | op arg1 arg2 |
    self additiveExpr ifFalse: [ ^false ].
    [
        op := token.
        (token = #< or: [ token = #> or: [ token = #<= or: [ token = #>= ]]]) ] whileTrue: [

        self scanToken.
        self additiveExpr ifFalse: [ self error: 'error in operand of relational operator' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self arg: arg1 op: op arg: arg2)
    ].
    ^true!

unaryExpr
    token = #- ifTrue: [
        self scanToken.
        ^self unaryExpr
            ifTrue: [ stack addLast: (self negated: stack removeLast) ];
            yourself
    ].

    ^self unionExpr!

unionExpr
    | arg1 arg2 |
    self pathExpr ifFalse: [ ^false ].
    [
        token = #| ] whileTrue: [

        self scanToken.
        self pathExpr ifFalse: [ self error: 'error in operand of |' ].

        arg2 := stack removeLast.
        arg1 := stack removeLast.
        stack addLast: (self union: arg1 with: arg2)
    ].
    ^true! !

!XPathParser methodsFor: 'public'!

atEndOfExpression
    ^tokenType == #endOfExpression!

init: streamOrString notifying: nothing failBlock: bah
    self source: streamOrString!

source: streamOrString
    buffer := String new writeStream.
    stack := OrderedCollection new.
    source := streamOrString isString
        ifFalse: [ streamOrString ]
        ifTrue: [ XPathReadStream on: streamOrString asString ].

    self step; scanToken!

parse: string as: construct
    self source: string.
    self perform: construct.
    self pastEnd ifFalse: [self error: 'Extra characters which could not be translated at end of stream'].
    ^self result!

pastEnd
    ^hereChar == nil!

result
    stack size = 1 ifFalse: [self error: 'Parsing logic error, incorrect number of values on the stack'].
    ^stack first!

initScanner
    "Present for compatibility with the parser in VW."!

xmlNode: aNode
    xmlNode := aNode! !

!XPathParser methodsFor: 'private'!

functionNamed: fName
    functions == nil ifTrue: [functions := XPathFunction baseFunctions].
    ^(functions at: fName ifAbsent: [self error: ('Not implemented yet %1()' bindWith: fName)]) copy!

namespaceAt: aQualifier
    | elm ns |
    elm := xmlNode.
    [elm isDocument]
    	whileFalse:
    		[ns := elm namespaceAt: aQualifier.
    		ns == nil ifFalse: [^ns].
    		elm := elm parent].
    aQualifier = 'xml' ifTrue: [^XML_URI].
    self error: ('No namespace binding found for namespace qualifier "%1".'
    		bindWith: aQualifier)!

peekFor: trialValue 
    "Test to see if tokenType matches aType and token equals trialValue. If so, 
    advance to the next token"

    ^token = trialValue
    	ifTrue: 
    		[self scanToken.
    		true]
    	ifFalse: [false]!

unexpectedError
    ^self halt; error: 'syntax error'!

verifyNotFunction
    ^token ~= $(!

scanToken
    | type |
    pushBack isNil ifFalse: [
        tokenType := pushBack key.
        token := pushBack value.
        pushBack := nil.
        ^self
    ].
    hereChar isNil ifFalse: [
        type := self class typeTable at: hereChar asInteger ifAbsent: [ #xDefault ].
        self perform: type.
        ^self
    ].
    tokenType := token := nil
!

step
    hereChar := source next!

xBinary
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
    			ifTrue: [self step. token := Symbol intern: test]
    			ifFalse: [token := Symbol internCharacter: char]]!

xCharacter
    tokenType := #character.
    token := hereChar.
    self step!

xDefault
    self error: 'invalid character ', hereChar asString!

xDelimiter
    source skipSeparators.
    self step.
    self scanToken!

xDigit
    "form a number"

    | numerator denominator |
    tokenType := #number.
    numerator := 0.
    denominator := 1.
    [hereChar notNil and: [hereChar isDigit]]
    	whileTrue:
    		[numerator := numerator * 10 + hereChar digitValue.
    		self step].
    hereChar = $. ifFalse: [^token := numerator + 0.0d0].
    self step.
    [hereChar notNil and: [hereChar isDigit]]
    	whileTrue:
    		[numerator := numerator * 10 + hereChar digitValue.
    		denominator := denominator * 10.
    		self step].
    token := (numerator / denominator) + 0.0d0.!

xEndOfExpression
    tokenType := #endOfExpression.
    token := nil!

xDoubleQuote
    "collect string"

    | char |
    buffer reset.
    [(char := source next) == $"]
    	whileFalse:
    		[char == nil ifTrue: [^self offEnd: 'Unmatched comment quote'].
    		buffer nextPut: char].
    tokenType := #string.
    token := buffer contents.

    "Shorten the buffer if it got unreasonably large."
    buffer position > 200 ifTrue: [buffer := WriteStream on: (String new: 40)].

    self step!

xLetter
    "form a word, keyword, or reserved word"

    | char |
    buffer reset.
    buffer nextPut: hereChar.
    [char := source next.
    char notNil and: [ char isAlphaNumeric or: [ char == $- ]]]
        whileTrue:
                [buffer nextPut: char].

    tokenType := #word.
    hereChar := char.
    token := buffer contents!

xPeriod
    "form a number"

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
    [hereChar notNil and: [hereChar isDigit]]
    	whileTrue:
    		[numerator := numerator * 10 + hereChar digitValue.
    		denominator := denominator * 10.
    		self step].
    token := (numerator / denominator) + 0.0d0.!

xSingleQuote
    "collect string"

    | char |
    buffer reset.
    [(char := source next) == $']
    	whileFalse:
    		[char == nil ifTrue: [^self offEnd: 'Unmatched comment quote'].
    		buffer nextPut: char].
    tokenType := #string.
    token := buffer contents.

    "Shorten the buffer if it got unreasonably large."
    buffer position > 200 ifTrue: [buffer := WriteStream on: (String new: 40)].
    self step! !

!XPathParser methodsFor: 'initialize'!

functions: aDictionary
    functions := aDictionary! !

!XPathParser class methodsFor: 'parsing'!

parse: stringOrStream as: construct
    ^self new parse: stringOrStream as: construct! !

!XPathParser class methodsFor: 'private'!

baseTable
    | newTable c selector |
    newTable := Array new: 255.
    1 to: 255 do: [ :each |
        c := each asCharacter.
        selector := #xDefault.
        c isSeparator ifTrue: [ selector := #xDelimiter ].
        c isDigit ifTrue: [ selector := #xDigit ].
        c isLetter ifTrue: [ selector := #xLetter ].
        c == $. ifTrue: [ selector := #xPeriod ].
        c == $" ifTrue: [ selector := #xDoubleQuote ].
        c == $' ifTrue: [ selector := #xSingleQuote ].
        c == $} ifTrue: [ selector := #xEndOfExpression ].
        (':*/+-@=!<>|' includes: c) ifTrue: [ selector := #xBinary ].
        ('$[]()' includes: c) ifTrue: [ selector := #xCharacter ].
        newTable at: each put: selector
    ].
    ^newTable!

initialize
    "Compute the character type, reserved word tables, and
    keyword flag from the information associated with each method."
    typeTable := self baseTable.
    nodeTypes := Dictionary new.
    XPathStep allSubclassesDo: [:cls |
        cls axisNames do: [:nm | nodeTypes at: nm put: cls]]!

typeTable
    ^typeTable!

nodeTypes
    ^nodeTypes! !

!XPathParser class methodsFor: 'examples'!

examples
    "XPathParser2 examples"

    | samples |
    samples := #('child::para' 'child::*' 'child::text()' 'child::node()'
    		'attribute::name' 'attribute::*' 'descendant::para' 'ancestor::div'
    		'ancestor-or-self::div' 'descendant-or-self::para' 'self::para'
    		'child::chapter/descendant::para' 'child::*/child::para' '/'
    		'/descendant::para' '/descendant::olist/child::item'
    		'child::para[position()=1]' 'child::para[position()=last()]'
    		'child::para[position()=last()-1]' 'child::para[position()>1]'
    		'following-sibling::chapter[position()=1]'
    		'preceding-sibling::chapter[position()=1]'
    		'/descendant::figure[position()=42]'
    		'/child::doc/child::chapter[position()=5]/child::section[position()=2]'
    		'child::para[attribute::type="warning"]'
    		'child::para[attribute::type=''warning''][position()=5]'
    		'child::para[position()=5][attribute::type="warning"]'
    		'child::chapter[child::title=''Introduction'']'
    		'child::chapter[child::title]' 'child::*[self::chapter or self::appendix]'
    		'child::*[self::chapter or self::appendix][position()=last()]').

    samples do: [:str | (self new parse: str as: #locationPath) printNl]! !

!XPathAttributeNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    | nd nc |
    nd := aNodeContext node.
    nc := aNodeContext copy documentOrder.
    nd isElement
    	ifFalse: [^nc].
    nd attributes do: [:childNode |
    	(baseTest match: childNode)
    		ifTrue: [nc add: childNode]].
    ^nc!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    | hasCP set |
    anXmlNode isAttribute ifFalse: [^false].
    (baseTest match: anXmlNode) ifFalse: [^false].
    (hasCP := self hasComplexPredicate)
    	ifFalse:
    		[set := XPathNodeContext new add: anXmlNode.
    		1 to: predicates size do: [:i |
    			set := set select: (predicates at: i)].
    		set size = 0 ifTrue: [^false halt]].
    parent == nil ifTrue: [^aBlock value: anXmlNode parent value: complex | hasCP].
    ^parent simpleMatchFor: anXmlNode parent
    	isComplex: complex | hasCP
    	do: aBlock! !

!XPathAttributeNode methodsFor: 'printing'!

printTestOn: aStream
    axisName == nil
    	ifTrue: [aStream nextPutAll: '@'; print: baseTest]
    	ifFalse: [super printTestOn: aStream]! !

!XPathAttributeNode class methodsFor: 'private'!

axisNames
    ^#('attribute')! !

!XPathCurrentNode methodsFor: 'accessing'!

axisName
    axisName == nil
    	ifTrue: [^'self']
    	ifFalse: [^axisName]! !

!XPathCurrentNode methodsFor: 'matching'!

baseValueIn: aNodeContext
    ^(baseTest match: aNodeContext node)
    	ifTrue: [aNodeContext copy documentOrder; add: aNodeContext node]
    	ifFalse: [aNodeContext copy documentOrder]!

simpleMatchFor: anXmlNode isComplex: complex do: aBlock
    | hasCP set |
    (baseTest match: anXmlNode) ifFalse: [^false].
    (hasCP := self hasComplexPredicate)
    	ifFalse:
    		[set := XPathNodeContext new add: anXmlNode.
    		1 to: predicates size do: [:i |
    			set := set select: (predicates at: i)].
    		set size = 0 ifTrue: [^false halt]].
    parent == nil ifTrue: [^aBlock value: anXmlNode value: complex | hasCP].
    ^parent simpleMatchFor: anXmlNode
    	isComplex: complex | hasCP
    	do: aBlock! !

!XPathCurrentNode methodsFor: 'printing'!

completePrintOn: aStream
    (baseTest isTrivial
    		and: [predicates isEmpty])
    	ifTrue: [self child isTerminator
    		ifTrue: [aStream nextPutAll: '.']
    		ifFalse:
    			[aStream nextPutAll: './'.
    			self child completeChildPrintOn: aStream]]
    	ifFalse: [super completePrintOn: aStream]! !

!XPathCurrentNode methodsFor: 'initialize'!

initialize
    super initialize.
    baseTest := XPathTypedNodeTest new type: 'node'! !

!XPathCurrentNode class methodsFor: 'private'!

axisNames
    ^#('self')! !

!Object methodsFor: 'xml support'!

addToXPathHolder: anAssociation for: aNodeContext
    anAssociation value == nil
    	ifTrue: [^anAssociation value: self].
    anAssociation value xpathIsNodeSet
    	ifTrue: [^self error: 'An XPath expression is answering a combination of Nodes and non-Nodes'].
    self error: 'An XPath expression is answering more than one non-Node value'!

xpathEvalIn: aNodeContext
    "This is private protocol--see #xpathValueIn: for the client protocol"

    ^self!

xpathIsBoolean
    ^false!

xpathIsNodeSet
    ^false!

xpathIsNumber
    ^false!

xpathMayRequireNodeSet
    ^false!

xpathMayRequireNodeSetTopLevel
    ^false!

xpathMayRequireSort
    ^false!

xpathMayRequireSortTopLevel
    ^false!

xpathValueIn: aNodeContext
    "This is public protocol--see #xpathEvalIn: for the private internal protocol"

    ^self! !

!Document methodsFor: 'accessing'!

xpathStringData
    ^self root xpathStringData! !

!Text methodsFor: 'accessing'!

xpathStringData
    ^self characterData! !

!PI methodsFor: 'accessing'!

xpathStringData
    ^self text! !

!Element methodsFor: 'accessing'!

xpathStringData
    ^self characterData! !

!Comment methodsFor: 'accessing'!

xpathStringData
    ^self text! !

!Node methodsFor: 'enumerating'!

addToXPathHolder: anAssociation for: aNodeContext
    anAssociation value == nil
    	ifTrue: [^anAssociation value: (aNodeContext copy add: self)].
    anAssociation value xpathIsNodeSet
    	ifTrue: [^anAssociation value add: self].
    self error: 'An XPath expression is answering a combination of Nodes and non-Nodes'! !

!Node methodsFor: 'accessing'!

xpathStringData
    ^self subclassResponsibility! !

!Boolean methodsFor: 'converting'!

xpathAsBoolean
    ^self!

xpathAsNumber
    ^self ifTrue: [1] ifFalse: [0]!

xpathAsString
    ^self printString! !

!Boolean methodsFor: 'xml support'!

xpathCompareEquality: aData using: aBlock
    aData isString
    	ifTrue: [^aBlock value: self value: aData xpathAsBoolean].
    aData xpathIsNumber
    	ifTrue: [^aBlock value: self value: aData xpathAsBoolean].
    aData xpathIsBoolean
    	ifTrue: [^aBlock value: self value: aData xpathAsBoolean].
    aData xpathIsNodeSet
    	ifTrue: [^aData unsortedNodes contains: [:nd2 |
    				aBlock value: self value: nd2 xpathStringData xpathAsBoolean]].
    self error: ('Can''t compare a %1 with a boolean' bindWith: aData class printString)!

xpathCompareOrder: aData using: aBlock
    | v |
    v := self xpathAsNumber.
    ^aData xpathIsNodeSet
    	ifTrue: [aData unsortedNodes contains: [:nd2 |
    				aBlock value: v value: nd2 xpathStringData xpathAsNumber]]
    	ifFalse: [aBlock value: v value: aData xpathAsNumber]!

xpathIsBoolean
    ^true! !

!Number methodsFor: 'converting'!

xpathAsBoolean
    ^self ~= 0!

xpathAsNumber
    ^self!

xpathAsString
    | str n num delta n2 found |
"	self isZero ifTrue: [^'0']."
    self isFinite not
    	ifTrue: [^self printString].
    str := (String new: 8) writeStream.
    self < 0 ifTrue: [str nextPut: $-].
    n := self abs + 0.0d0.
    num := n truncated.
    str print: num.
    num + 0.0d = n ifTrue:
    	[^str contents].
    delta := 1/10.
    found := false.
    [[n2 := num + delta.
    n2 < n] whileTrue:
    	[num := n2].
    num = n
    	ifTrue: [found := true]
    	ifFalse: [n2 = n
    		ifTrue: [num := n2. found := true]].
    found]
    	whileFalse: [delta := delta / 10].
    num = n ifFalse: [self halt].
    str nextPut: $..
    num := num - num truncated.
    [num = 0]
    	whileFalse:
    		[num := num * 10.
    		str print: num truncated.
    		num := num - num truncated].
    ^str contents! !

!Number methodsFor: 'xml support'!

xpathCompareEquality: aData using: aBlock
    aData isString
    	ifTrue: [^aBlock value: self value: aData xpathAsNumber].
    aData xpathIsNumber
    	ifTrue: [^aBlock value: self value: aData].
    aData xpathIsBoolean
    	ifTrue: [^aBlock value: self xpathAsBoolean value: aData].
    aData xpathIsNodeSet
    	ifTrue: [^aData unsortedNodes contains: [:nd2 |
    				aBlock value: self value: nd2 xpathStringData xpathAsNumber]].
    self error: ('Can''t compare a %1 with a number' bindWith: aData class printString)!

xpathCompareOrder: aData using: aBlock
    | v |
    v := self xpathAsNumber.
    ^aData xpathIsNodeSet
    	ifTrue: [aData unsortedNodes contains: [:nd2 |
    				aBlock value: v value: nd2 xpathStringData xpathAsNumber]]
    	ifFalse: [aBlock value: v value: aData xpathAsNumber]!

xpathIsNumber
    ^true!

xpathMayRequireNodeSetTopLevel
    ^true!

xpathMayRequireSortTopLevel
    ^true! !

!Attribute methodsFor: 'accessing'!

xpathStringData
    ^self characterData! !

!String methodsFor: 'converting'!

xpathAsBoolean
    ^self size > 0!

xpathAsNumber
    | s foundDigit numerator denominator ch |
    s := self readStream.
    s skipSeparators.
    foundDigit := false.
    numerator := 0.
    denominator := (s peekFor: $-) ifTrue: [-1] ifFalse: [1].
    [(ch := s next) notNil and: [ch isDigit]]
    	whileTrue:
    		[numerator := numerator * 10 + ch digitValue.
    		foundDigit := true].
    ch = $.
    	ifTrue: [[(ch := s next) notNil and: [ch isDigit]]
    		whileTrue:
    			[numerator := numerator * 10 + ch digitValue.
    			denominator := denominator * 10.
    			foundDigit := true]].
    (ch == nil or: [ch isSeparator]) ifFalse: [^FloatD nan].
    s skipSeparators.
    s atEnd ifFalse: [^FloatD nan].
    foundDigit ifFalse: [^FloatD nan].
    ^(numerator / denominator) + 0.0d0!

xpathAsString
    ^self! !

!String methodsFor: 'xml support'!

xpathCompareEquality: aData using: aBlock
    aData isString
    	ifTrue: [^aBlock value: self value: aData].
    aData xpathIsNumber
    	ifTrue: [^aBlock value: self xpathAsNumber value: aData].
    aData xpathIsBoolean
    	ifTrue: [^aBlock value: self xpathAsBoolean value: aData].
    aData xpathIsNodeSet
    	ifTrue: [^aData unsortedNodes contains: [:nd2 |
    				aBlock value: self value: nd2 xpathStringData]].
    self error: ('Can''t compare a %1 with a string' bindWith: aData class printString)!

xpathCompareOrder: aData using: aBlock
    | v |
    v := self xpathAsNumber.
    ^aData xpathIsNodeSet
    	ifTrue: [aData unsortedNodes contains: [:nd2 |
    				aBlock value: v value: nd2 xpathStringData xpathAsNumber]]
    	ifFalse: [aBlock value: v value: aData xpathAsNumber]! !

XML.XPathFunction initialize!
XML.XPathParser initialize!
XML.XPathBinaryExpression initialize!

Namespace current: Smalltalk!
