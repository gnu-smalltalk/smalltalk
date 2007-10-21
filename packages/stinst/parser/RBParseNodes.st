"======================================================================
|
|   Refactoring Browser - Parse nodes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



Object subclass: RBProgramNodeVisitor [
    
    <category: 'Refactory-Parser'>
    <comment: 'RBProgramNodeVisitor is an abstract visitor for the RBProgramNodes.

'>

    RBProgramNodeVisitor class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    visitArgument: each [
	"Here to allow subclasses to detect arguments or temporaries."

	<category: 'visiting'>
	^self visitNode: each
    ]

    visitArguments: aNodeCollection [
	<category: 'visiting'>
	^aNodeCollection do: [:each | self visitArgument: each]
    ]

    visitNode: aNode [
	<category: 'visiting'>
	^aNode acceptVisitor: self
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
    ]

    acceptArrayConstructorNode: anArrayNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anArrayNode body
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aBlockNode arguments.
	self visitNode: aBlockNode body
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	aCascadeNode messages do: [:each | self visitNode: each]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver.
	aMessageNode arguments do: [:each | self visitNode: each]
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aMethodNode arguments.
	self visitNode: aMethodNode body
    ]

    acceptOptimizedNode: anOptimizedNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anOptimizedNode body
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aSequenceNode temporaries.
	aSequenceNode statements do: [:each | self visitNode: each]
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	
    ]
]



Object subclass: RBProgramNode [
    | parent comments |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBProgramNode is an abstract class that represents an abstract syntax tree node in a Smalltalk program.

Subclasses must implement the following messages:
    accessing
	start
	stop
    visitor
	acceptVisitor:

The #start and #stop methods are used to find the source that corresponds to this node. "source copyFrom: self start to: self stop" should return the source for this node.

The #acceptVisitor: method is used by RBProgramNodeVisitors (the visitor pattern). This will also require updating all the RBProgramNodeVisitors so that they know of the new node.

Subclasses might also want to redefine match:inContext: and copyInContext: to do parse tree searching and replacing.

Subclasses that contain other nodes should override equalTo:withMapping: to compare nodes while ignoring renaming temporary variables, and children that returns a collection of our children nodes.

Instance Variables:
    comments    <Collection of: Interval>    the intervals in the source that have comments for this node
    parent    <RBProgramNode>    the node we''re contained in

'>

    allArgumentVariables [
	<category: 'accessing'>
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
	    into: 
		[:vars :each | 
		vars
		    addAll: each allArgumentVariables;
		    yourself]
    ]

    allDefinedVariables [
	<category: 'accessing'>
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
	    into: 
		[:vars :each | 
		vars
		    addAll: each allDefinedVariables;
		    yourself]
    ]

    allTemporaryVariables [
	<category: 'accessing'>
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
	    into: 
		[:vars :each | 
		vars
		    addAll: each allTemporaryVariables;
		    yourself]
    ]

    asReturn [
	"Change the current node to a return node."

	<category: 'accessing'>
	parent isNil 
	    ifTrue: [self error: 'Cannot change to a return without a parent node.'].
	parent isSequence 
	    ifFalse: [self error: 'Parent node must be a sequence node.'].
	(parent isLast: self) ifFalse: [self error: 'Return node must be last.'].
	^parent addReturn
    ]

    blockVariables [
	<category: 'accessing'>
	^parent isNil ifTrue: [#()] ifFalse: [parent blockVariables]
    ]

    children [
	<category: 'accessing'>
	^#()
    ]

    comments [
	<category: 'accessing'>
	^comments isNil ifTrue: [#()] ifFalse: [comments]
    ]

    comments: aCollection [
	<category: 'accessing'>
	comments := aCollection
    ]

    formattedCode [
	<category: 'accessing'>
	^self formatterClass new format: self
    ]

    formatterClass [
	<category: 'accessing'>
	^RBFormatter
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: anObject [
	<category: 'accessing'>
	parent := anObject
    ]

    precedence [
	<category: 'accessing'>
	^6
    ]

    source [
	<category: 'accessing'>
	^parent notNil ifTrue: [parent source] ifFalse: [nil]
    ]

    sourceInterval [
	<category: 'accessing'>
	^self start to: self stop
    ]

    start [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    stop [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    temporaryVariables [
	<category: 'accessing'>
	^parent isNil ifTrue: [#()] ifFalse: [parent temporaryVariables]
    ]

    equalTo: aNode exceptForVariables: variableNameCollection [
	<category: 'comparing'>
	| dictionary |
	dictionary := Dictionary new.
	(self equalTo: aNode withMapping: dictionary) ifFalse: [^false].
	dictionary keysAndValuesDo: 
		[:key :value | 
		(key = value or: [variableNameCollection includes: key]) ifFalse: [^false]].
	^true
    ]

    equalTo: aNode withMapping: aDictionary [
	<category: 'comparing'>
	^self = aNode
    ]

    copyCommentsFrom: aNode [
	"Add all comments from aNode to us. If we already have the comment, then don't add it."

	<category: 'copying'>
	| newComments |
	newComments := OrderedCollection new.
	aNode nodesDo: [:each | newComments addAll: each comments].
	self nodesDo: 
		[:each | 
		each comments do: [:comment | newComments remove: comment ifAbsent: []]].
	newComments isEmpty ifTrue: [^self].
	newComments := newComments asSortedCollection: [:a :b | a first < b first].
	self comments: newComments
    ]

    nodesDo: aBlock [
	<category: 'iterating'>
	aBlock value: self.
	self children do: [:each | each nodesDo: aBlock]
    ]

    deepCopy [
	"Hacked to fit collection protocols.  We use #deepCopy to obtain a list
	 of copied nodes.  We do already copy for our instance variables
	 through #postCopy, so we redirect #deepCopy to be a normal #copy."

	<category: 'enumeration'>
	^self copy
    ]

    collect: aBlock [
	"Hacked to fit collection protocols"

	<category: 'enumeration'>
	^aBlock value: self
    ]

    do: aBlock [
	"Hacked to fit collection protocols"

	<category: 'enumeration'>
	aBlock value: self
    ]

    size [
	"Hacked to fit collection protocols"

	<category: 'enumeration'>
	^1
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self copy
    ]

    copyList: matchNodes inContext: aDictionary [
	<category: 'matching'>
	| newNodes |
	newNodes := OrderedCollection new.
	matchNodes do: 
		[:each | 
		| object |
		object := each copyInContext: aDictionary.
		newNodes addAll: object].
	^newNodes
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	^self = aNode
    ]

    matchList: matchNodes against: programNodes inContext: aDictionary [
	<category: 'matching'>
	^self 
	    matchList: matchNodes
	    index: 1
	    against: programNodes
	    index: 1
	    inContext: aDictionary
    ]

    matchList: matchNodes index: matchIndex against: programNodes index: programIndex inContext: aDictionary [
	<category: 'matching'>
	| node currentIndex currentDictionary nodes |
	matchNodes size < matchIndex ifTrue: [^programNodes size < programIndex].
	node := matchNodes at: matchIndex.
	node isList 
	    ifTrue: 
		[currentIndex := programIndex - 1.
		
		[currentDictionary := aDictionary copy.
		programNodes size < currentIndex or: 
			[nodes := programNodes copyFrom: programIndex to: currentIndex.
			(currentDictionary at: node ifAbsentPut: [nodes]) = nodes and: 
				[(self 
				    matchList: matchNodes
				    index: matchIndex + 1
				    against: programNodes
				    index: currentIndex + 1
				    inContext: currentDictionary) 
					ifTrue: 
					    [currentDictionary 
						keysAndValuesDo: [:key :value | aDictionary at: key put: value].
					    ^true].
				false]]] 
			whileFalse: [currentIndex := currentIndex + 1].
		^false].
	programNodes size < programIndex ifTrue: [^false].
	(node match: (programNodes at: programIndex) inContext: aDictionary) 
	    ifFalse: [^false].
	^self 
	    matchList: matchNodes
	    index: matchIndex + 1
	    against: programNodes
	    index: programIndex + 1
	    inContext: aDictionary
    ]

    cascadeListCharacter [
	<category: 'pattern variable-accessing'>
	^$;
    ]

    listCharacter [
	<category: 'pattern variable-accessing'>
	^$@
    ]

    literalCharacter [
	<category: 'pattern variable-accessing'>
	^$#
    ]

    recurseIntoCharacter [
	<category: 'pattern variable-accessing'>
	^$`
    ]

    statementCharacter [
	<category: 'pattern variable-accessing'>
	^$.
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self class name;
	    nextPut: $(;
	    nextPutAll: self formattedCode;
	    nextPut: $)
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectedChildren := self children 
		    select: [:each | each intersectsInterval: anInterval].
	^selectedChildren size == 1 
	    ifTrue: [selectedChildren first bestNodeFor: anInterval]
	    ifFalse: [self]
    ]

    selfMessages [
	<category: 'querying'>
	| searcher |
	searcher := ParseTreeSearcher new.
	searcher matches: 'self `@msg: ``@args'
	    do: 
		[:aNode :answer | 
		answer
		    add: aNode selector;
		    yourself].
	^searcher executeTree: self initialAnswer: Set new
    ]

    statementNode [
	"Return your topmost node that is contained by a sequence node."

	<category: 'querying'>
	(parent isNil or: [parent isSequence]) ifTrue: [^self].
	^parent statementNode
    ]

    superMessages [
	<category: 'querying'>
	| searcher |
	searcher := ParseTreeSearcher new.
	searcher matches: 'super `@msg: ``@args'
	    do: 
		[:aNode :answer | 
		answer
		    add: aNode selector;
		    yourself].
	^searcher executeTree: self initialAnswer: Set new
    ]

    whichNodeIsContainedBy: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectedChildren := self children 
		    select: [:each | each intersectsInterval: anInterval].
	^selectedChildren size == 1 
	    ifTrue: [selectedChildren first whichNodeIsContainedBy: anInterval]
	    ifFalse: [nil]
    ]

    whoDefines: aName [
	<category: 'querying'>
	^(self defines: aName) 
	    ifTrue: [self]
	    ifFalse: [parent notNil ifTrue: [parent whoDefines: aName] ifFalse: [nil]]
    ]

    removeDeadCode [
	<category: 'replacing'>
	self children do: [:each | each removeDeadCode]
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	self error: 'I don''t store other nodes'
    ]

    replaceWith: aNode [
	<category: 'replacing'>
	parent isNil ifTrue: [self error: 'This node doesn''t have a parent'].
	parent replaceNode: self withNode: aNode
    ]

    assigns: aVariableName [
	<category: 'testing'>
	^(self children detect: [:each | each assigns: aVariableName] ifNone: [nil]) 
	    notNil
    ]

    containedBy: anInterval [
	<category: 'testing'>
	^anInterval first <= self start and: [anInterval last >= self stop]
    ]

    containsReturn [
	<category: 'testing'>
	^(self children detect: [:each | each containsReturn] ifNone: [nil]) 
	    notNil
    ]

    defines: aName [
	<category: 'testing'>
	^false
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^true
    ]

    evaluatedFirst: aNode [
	<category: 'testing'>
	self children do: 
		[:each | 
		each == aNode ifTrue: [^true].
		each isImmediate ifFalse: [^false]].
	^false
    ]

    intersectsInterval: anInterval [
	<category: 'testing'>
	^(anInterval first between: self start and: self stop) 
	    or: [self start between: anInterval first and: anInterval last]
    ]

    isAssignment [
	<category: 'testing'>
	^false
    ]

    isBlock [
	<category: 'testing'>
	^false
    ]

    isCascade [
	<category: 'testing'>
	^false
    ]

    isCompileTimeBound [
	<category: 'testing'>
	^false
    ]

    isDirectlyUsed [
	"This node is directly used as an argument, receiver, or part of an assignment."

	<category: 'testing'>
	^parent isNil ifTrue: [false] ifFalse: [parent directlyUses: self]
    ]

    isEvaluatedFirst [
	"Return true if we are the first thing evaluated in this statement."

	<category: 'testing'>
	^parent isNil or: [parent isSequence or: [parent evaluatedFirst: self]]
    ]

    isImmediate [
	<category: 'testing'>
	^false
    ]

    isLast: aNode [
	<category: 'testing'>
	| children |
	children := self children.
	^children isEmpty not and: [children last == aNode]
    ]

    isLiteral [
	<category: 'testing'>
	^false
    ]

    isMessage [
	<category: 'testing'>
	^false
    ]

    isMethod [
	<category: 'testing'>
	^false
    ]

    isReturn [
	<category: 'testing'>
	^false
    ]

    isSequence [
	<category: 'testing'>
	^false
    ]

    isUsed [
	"Answer true if this node could be used as part of another expression. For example, you could use the
	 result of this node as a receiver of a message, an argument, the right part of an assignment, or the
	 return value of a block. This differs from isDirectlyUsed in that it is conservative since it also includes
	 return values of blocks."

	<category: 'testing'>
	^parent isNil ifTrue: [false] ifFalse: [parent uses: self]
    ]

    isValue [
	<category: 'testing'>
	^false
    ]

    isVariable [
	<category: 'testing'>
	^false
    ]

    lastIsReturn [
	<category: 'testing'>
	^self isReturn
    ]

    references: aVariableName [
	<category: 'testing'>
	^(self children detect: [:each | each references: aVariableName]
	    ifNone: [nil]) notNil
    ]

    uses: aNode [
	<category: 'testing'>
	^true
    ]

    isList [
	<category: 'testing-matching'>
	^false
    ]

    recurseInto [
	<category: 'testing-matching'>
	^false
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	self subclassResponsibility
    ]
]



RBProgramNode subclass: RBSequenceNode [
    | leftBar rightBar statements periods temporaries |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBSequenceNode is an AST node that represents a sequence of statements. Both RBBlockNodes and RBMethodNodes contain these.

Instance Variables:
    leftBar    <Integer | nil>    the position of the left | in the temporaries definition
    periods    <SequenceableCollection of: Integer>    the positions of all the periods that separate the statements
    rightBar    <Integer | nil>    the position of the right | in the temporaries definition
    statements    <SequenceableCollection of: RBStatementNode>    the statement nodes
    temporaries    <SequenceableCollection of: RBVariableNode>    the temporaries defined

'>

    RBSequenceNode class >> leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger [
	<category: 'instance creation'>
	^self new 
	    leftBar: leftInteger
	    temporaries: variableNodes
	    rightBar: rightInteger
    ]

    RBSequenceNode class >> statements: statementNodes [
	<category: 'instance creation'>
	^self temporaries: #() statements: statementNodes
    ]

    RBSequenceNode class >> temporaries: variableNodes statements: statementNodes [
	<category: 'instance creation'>
	^(self new)
	    temporaries: variableNodes;
	    statements: statementNodes;
	    yourself
    ]

    addReturn [
	<category: 'accessing'>
	| node |
	statements isEmpty ifTrue: [^nil].
	statements last isReturn ifTrue: [^statements last].
	node := RBReturnNode value: statements last.
	statements at: statements size put: node.
	node parent: self.
	^node
    ]

    allDefinedVariables [
	<category: 'accessing'>
	^(self temporaryNames asOrderedCollection)
	    addAll: super allDefinedVariables;
	    yourself
    ]

    allTemporaryVariables [
	<category: 'accessing'>
	^(self temporaryNames asOrderedCollection)
	    addAll: super allTemporaryVariables;
	    yourself
    ]

    children [
	<category: 'accessing'>
	^(OrderedCollection new)
	    addAll: self temporaries;
	    addAll: self statements;
	    yourself
    ]

    leftBar [
	<category: 'accessing'>
	^leftBar
    ]

    periods: anObject [
	<category: 'accessing'>
	periods := anObject
    ]

    removeTemporaryNamed: aName [
	<category: 'accessing'>
	temporaries := temporaries reject: [:each | each name = aName]
    ]

    rightBar [
	<category: 'accessing'>
	^rightBar
    ]

    start [
	<category: 'accessing'>
	^leftBar isNil 
	    ifTrue: [statements isEmpty ifTrue: [1] ifFalse: [statements first start]]
	    ifFalse: [leftBar]
    ]

    statements [
	<category: 'accessing'>
	^statements
    ]

    statements: stmtCollection [
	<category: 'accessing'>
	statements := stmtCollection.
	statements do: [:each | each parent: self]
    ]

    stop [
	<category: 'accessing'>
	^(periods isEmpty ifTrue: [0] ifFalse: [periods last]) 
	    max: (statements isEmpty ifTrue: [0] ifFalse: [statements last stop])
    ]

    temporaries [
	<category: 'accessing'>
	^temporaries
    ]

    temporaries: tempCollection [
	<category: 'accessing'>
	temporaries := tempCollection.
	temporaries do: [:each | each parent: self]
    ]

    temporaryNames [
	<category: 'accessing'>
	^temporaries collect: [:each | each name]
    ]

    temporaryVariables [
	<category: 'accessing'>
	^(super temporaryVariables asOrderedCollection)
	    addAll: self temporaryNames;
	    yourself
    ]

    = anObject [
	"Can't send = to the temporaries and statements collection since they might change from arrays to OCs"

	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self temporaries size = anObject temporaries size ifFalse: [^false].
	1 to: self temporaries size
	    do: 
		[:i | 
		(self temporaries at: i) = (anObject temporaries at: i) ifFalse: [^false]].
	self statements size = anObject statements size ifFalse: [^false].
	1 to: self statements size
	    do: [:i | (self statements at: i) = (anObject statements at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self statements size == anObject statements size ifFalse: [^false].
	1 to: self statements size
	    do: 
		[:i | 
		((self statements at: i) equalTo: (anObject statements at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	aDictionary values asSet size = aDictionary size ifFalse: [^false].	"Not a one-to-one mapping"
	self temporaries 
	    do: [:each | aDictionary removeKey: each name ifAbsent: []].
	^true
    ]

    hash [
	<category: 'comparing'>
	^self temporaries hash bitXor: (self statements isEmpty 
		    ifTrue: [0]
		    ifFalse: [self statements first hash])
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	temporaries := temporaries collect: [:each | each copy].
	statements := statements collect: [:each | each copy]
    ]

    leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger [
	<category: 'initialize-release'>
	leftBar := leftInteger.
	self temporaries: variableNodes.
	rightBar := rightInteger
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    temporaries: (self copyList: temporaries inContext: aDictionary);
	    statements: (self copyList: statements inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	self class == aNode class ifFalse: [^false].
	^(self 
	    matchList: temporaries
	    against: aNode temporaries
	    inContext: aDictionary) and: 
		    [self 
			matchList: statements
			against: aNode statements
			inContext: aDictionary]
    ]

    removeDeadCode [
	<category: 'replacing'>
	(self isUsed ifTrue: [statements size - 1] ifFalse: [statements size]) 
	    to: 1
	    by: -1
	    do: [:i | (statements at: i) isImmediate ifTrue: [statements removeAtIndex: i]].
	super removeDeadCode
    ]

    removeNode: aNode [
	<category: 'replacing'>
	self replaceNode: aNode withNodes: #()
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	self statements: (statements 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]]).
	self temporaries: (temporaries 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    replaceNode: aNode withNodes: aCollection [
	<category: 'replacing'>
	| index newStatements |
	index := self indexOfNode: aNode.
	newStatements := OrderedCollection new: statements size + aCollection size.
	1 to: index - 1 do: [:i | newStatements add: (statements at: i)].
	newStatements addAll: aCollection.
	index + 1 to: statements size
	    do: [:i | newStatements add: (statements at: i)].
	aCollection do: [:each | each parent: self].
	statements := newStatements
    ]

    indexOfNode: aNode [
	"Try to find the node by first looking for ==, and then for ="

	<category: 'private'>
	^(1 to: statements size) detect: [:each | each == aNode]
	    ifNone: [statements indexOf: aNode]
    ]

    defines: aName [
	<category: 'testing'>
	^(temporaries detect: [:each | each name = aName] ifNone: [nil]) notNil
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^false
    ]

    isLast: aNode [
	<category: 'testing'>
	| last |
	statements isEmpty ifTrue: [^false].
	last := statements last.
	^last == aNode or: 
		[last isMessage and: 
			[(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: last selector) and: 
				[last arguments inject: false
				    into: [:bool :each | bool or: [each isLast: aNode]]]]]
    ]

    isSequence [
	<category: 'testing'>
	^true
    ]

    lastIsReturn [
	<category: 'testing'>
	^statements isEmpty not and: [statements last lastIsReturn]
    ]

    references: aVariableName [
	<category: 'testing'>
	^(statements detect: [:each | each references: aVariableName] ifNone: [nil]) 
	    notNil
    ]

    uses: aNode [
	<category: 'testing'>
	statements isEmpty ifTrue: [^false].
	aNode == statements last ifFalse: [^false].
	^self isUsed
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptSequenceNode: self
    ]

    addNode: aNode [
	<category: 'adding nodes'>
	aNode parent: self.
	(statements isEmpty not and: [statements last isReturn]) 
	    ifTrue: [self error: 'Cannot add statement after return node'].
	statements := (statements asOrderedCollection)
		    add: aNode;
		    yourself
    ]

    addNode: aNode before: anotherNode [
	<category: 'adding nodes'>
	| index |
	index := self indexOfNode: anotherNode.
	index = 0 ifTrue: [^self addNode: aNode].
	statements := (statements asOrderedCollection)
		    add: aNode beforeIndex: index;
		    yourself.
	aNode parent: self
    ]

    addNodeFirst: aNode [
	<category: 'adding nodes'>
	aNode parent: self.
	statements := (statements asOrderedCollection)
		    addFirst: aNode;
		    yourself
    ]

    addNodes: aCollection [
	<category: 'adding nodes'>
	aCollection do: [:each | each parent: self].
	(statements isEmpty not and: [statements last isReturn]) 
	    ifTrue: [self error: 'Cannot add statement after return node'].
	statements := (statements asOrderedCollection)
		    addAll: aCollection;
		    yourself
    ]

    addNodes: aCollection before: anotherNode [
	<category: 'adding nodes'>
	aCollection do: [:each | self addNode: each before: anotherNode]
    ]

    addNodesFirst: aCollection [
	<category: 'adding nodes'>
	aCollection do: [:each | each parent: self].
	statements := (statements asOrderedCollection)
		    addAllFirst: aCollection;
		    yourself
    ]

    addSelfReturn [
	<category: 'adding nodes'>
	| node |
	self lastIsReturn ifTrue: [^self].
	node := RBReturnNode value: (RBVariableNode named: 'self').
	self addNode: node
    ]

    addTemporariesNamed: aCollection [
	<category: 'adding nodes'>
	aCollection do: [:each | self addTemporaryNamed: each]
    ]

    addTemporaryNamed: aString [
	<category: 'adding nodes'>
	| variableNode |
	variableNode := RBVariableNode named: aString.
	variableNode parent: self.
	temporaries := temporaries copyWith: variableNode
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	| node |
	node := super bestNodeFor: anInterval.
	node == self 
	    ifTrue: 
		[(temporaries isEmpty and: [statements size == 1]) 
		    ifTrue: [^statements first]].
	^node
    ]

    whichNodeIsContainedBy: anInterval [
	<category: 'querying'>
	| node |
	node := super whichNodeIsContainedBy: anInterval.
	node == self 
	    ifTrue: 
		[(temporaries isEmpty and: [statements size == 1]) 
		    ifTrue: [^statements first]].
	^node
    ]
]





RBProgramNode subclass: RBStatementNode [
    
    <category: 'Refactory-Parser'>
    <comment: 'RBStatementNode is an abstract class that represents AST nodes that can go in sequence nodes.

'>
]



RBProgramNode subclass: RBMethodNode [
    | selector selectorParts body source arguments tags category |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBMethodNode is the AST that represents a Smalltalk method.

Instance Variables:
    arguments    <SequenceableCollection of: RBVariableNode>    the arguments to the method
    body    <RBSequenceNode>    the body/statements of the method
    selector    <Symbol | nil>    the method name (cached)
    selectorParts    <SequenceableCollection of: RBValueToken>    the tokens for the selector keywords
    source    <String>    the source we compiled
    tag    <Interval | nil>    the source location of any resource/primitive tags

'>

    RBMethodNode class >> selector: aSymbol arguments: variableNodes body: aSequenceNode [
	<category: 'instance creation'>
	^(self new)
	    arguments: variableNodes;
	    selector: aSymbol;
	    body: aSequenceNode;
	    yourself
    ]

    RBMethodNode class >> selector: aSymbol body: aSequenceNode [
	<category: 'instance creation'>
	^self 
	    selector: aSymbol
	    arguments: #()
	    body: aSequenceNode
    ]

    RBMethodNode class >> selectorParts: tokenCollection arguments: variableNodes [
	<category: 'instance creation'>
	^((tokenCollection detect: [:each | each isPatternVariable] ifNone: [nil]) 
	    notNil ifTrue: [RBPatternMethodNode] ifFalse: [RBMethodNode]) 
	    new selectorParts: tokenCollection arguments: variableNodes
    ]

    addNode: aNode [
	<category: 'accessing'>
	^body addNode: aNode
    ]

    addReturn [
	<category: 'accessing'>
	body addReturn
    ]

    addSelfReturn [
	<category: 'accessing'>
	^body addSelfReturn
    ]

    allArgumentVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allArgumentVariables;
	    yourself
    ]

    allDefinedVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allDefinedVariables;
	    yourself
    ]

    argumentNames [
	<category: 'accessing'>
	^self arguments collect: [:each | each name]
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    arguments: variableNodes [
	<category: 'accessing'>
	arguments := variableNodes.
	arguments do: [:each | each parent: self]
    ]

    body [
	<category: 'accessing'>
	^body
    ]

    body: stmtsNode [
	<category: 'accessing'>
	body := stmtsNode.
	body parent: self
    ]

    children [
	<category: 'accessing'>
	^self arguments copyWith: self body
    ]

    primitiveSources [
	<category: 'accessing'>
	self tags isEmpty ifTrue: [^#()].
	^self tags collect: [:each | source copyFrom: each first to: each last]
    ]

    isBinary [
	<category: 'accessing'>
	^(self isUnary or: [self isKeyword]) not
    ]

    isKeyword [
	<category: 'accessing'>
	^selectorParts first value last == $:
    ]

    isUnary [
	<category: 'accessing'>
	^self arguments isEmpty
    ]

    selector [
	<category: 'accessing'>
	^selector isNil 
	    ifTrue: [selector := self buildSelector]
	    ifFalse: [selector]
    ]

    selector: aSelector [
	<category: 'accessing'>
	| keywords numArgs |
	keywords := aSelector keywords.
	numArgs := aSelector numArgs.
	numArgs == arguments size 
	    ifFalse: 
		[self 
		    error: 'Attempting to assign selector with wrong number of arguments.'].
	selectorParts := numArgs == 0 
		    ifTrue: [Array with: (RBIdentifierToken value: keywords first start: nil)]
		    ifFalse: 
			[keywords first last == $: 
			    ifTrue: [keywords collect: [:each | RBKeywordToken value: each start: nil]]
			    ifFalse: [Array with: (RBBinarySelectorToken value: aSelector start: nil)]].
	selector := aSelector
    ]

    source [
	<category: 'accessing'>
	^source
    ]

    source: anObject [
	<category: 'accessing'>
	source := anObject
    ]

    start [
	<category: 'accessing'>
	(selectorParts notNil and: [selectorParts first start notNil]) 
	    ifTrue: [^selectorParts first start].
	body start isNil ifFalse: [^body start].
	^1
    ]

    stop [
	<category: 'accessing'>
	^self start + source size - 1
    ]

    tags [
	<category: 'accessing'>
	^tags isNil ifTrue: [#()] ifFalse: [tags]
    ]

    tags: aCollectionOfIntervals [
	<category: 'accessing'>
	tags := aCollectionOfIntervals
    ]

    category [
	<category: 'accessing'>
	^category
    ]

    category: aCategory [
	<category: 'accessing'>
	category := aCategory
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	(self selector = anObject selector and: [self body = anObject body]) 
	    ifFalse: [^false].
	1 to: self arguments size
	    do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	(self selector = anObject selector 
	    and: [self body equalTo: anObject body withMapping: aDictionary]) 
		ifFalse: [^false].
	1 to: self arguments size
	    do: 
		[:i | 
		((self arguments at: i) equalTo: (anObject arguments at: i)
		    withMapping: aDictionary) ifFalse: [^false].
		aDictionary removeKey: (self arguments at: i) name].
	^self primitiveSources = anObject primitiveSources
    ]

    hash [
	<category: 'comparing'>
	^(self selector hash bitXor: self body hash) bitXor: self arguments hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	body := body copy.
	arguments := arguments collect: [:each | each copy]
    ]

    selectorParts: tokenCollection arguments: variableNodes [
	<category: 'initialize-release'>
	selectorParts := tokenCollection.
	self arguments: variableNodes
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    selectorParts: (selectorParts collect: [:each | each removePositions]);
	    arguments: (arguments collect: [:each | each copyInContext: aDictionary]);
	    body: (body copyInContext: aDictionary);
	    source: (aDictionary at: '-source-');
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	self class == aNode class ifFalse: [^false].
	aDictionary at: '-source-' put: aNode source.
	self selector == aNode selector ifFalse: [^false].
	^(self 
	    matchList: arguments
	    against: aNode arguments
	    inContext: aDictionary) 
		and: [body match: aNode body inContext: aDictionary]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self formattedCode
    ]

    buildSelector [
	<category: 'private'>
	| selectorStream |
	selectorStream := WriteStream on: (String new: 50).
	selectorParts do: [:each | selectorStream nextPutAll: each value].
	^selectorStream contents asSymbol
    ]

    selectorParts [
	<category: 'private'>
	^selectorParts
    ]

    selectorParts: tokenCollection [
	<category: 'private'>
	selectorParts := tokenCollection
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	aNode == body ifTrue: [self body: anotherNode].
	self arguments: (arguments 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    defines: aName [
	<category: 'testing'>
	^(arguments detect: [:each | each name = aName] ifNone: [nil]) notNil
    ]

    isLast: aNode [
	<category: 'testing'>
	^body isLast: aNode
    ]

    isMethod [
	<category: 'testing'>
	^true
    ]

    isPrimitive [
	<category: 'testing'>
	^tags notNil and: 
		[tags isEmpty not and: 
			[(self primitiveSources detect: [:each | '*primitive*' match: each]
			    ifNone: [nil]) notNil]]
    ]

    lastIsReturn [
	<category: 'testing'>
	^body lastIsReturn
    ]

    references: aVariableName [
	<category: 'testing'>
	^body references: aVariableName
    ]

    uses: aNode [
	<category: 'testing'>
	^body == aNode and: [aNode lastIsReturn]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptMethodNode: self
    ]
]



RBStatementNode subclass: RBValueNode [
    | parentheses |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBValueNode is an abstract class that represents a node that returns some value.

Instance Variables:
    parentheses    <SequenceableCollection of: Inteval>    the positions of the parethesis around this node. We need a collection of intervals for stupid code such as "((3 + 4))" that has multiple parethesis around the same expression.

'>

    addParenthesis: anInterval [
	<category: 'accessing'>
	parentheses isNil ifTrue: [parentheses := OrderedCollection new: 1].
	parentheses add: anInterval
    ]

    parentheses [
	<category: 'accessing'>
	^parentheses isNil ifTrue: [#()] ifFalse: [parentheses]
    ]

    start [
	<category: 'accessing'>
	^parentheses isNil 
	    ifTrue: [self startWithoutParentheses]
	    ifFalse: [parentheses last first]
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    stop [
	<category: 'accessing'>
	^parentheses isNil 
	    ifTrue: [self stopWithoutParentheses]
	    ifFalse: [parentheses last last]
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    containedBy: anInterval [
	<category: 'testing'>
	^anInterval first <= self startWithoutParentheses 
	    and: [anInterval last >= self stopWithoutParentheses]
    ]

    hasParentheses [
	<category: 'testing'>
	^self parentheses isEmpty not
    ]

    isValue [
	<category: 'testing'>
	^true
    ]
]



RBStatementNode subclass: RBReturnNode [
    | return value |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBReturnNode is an AST node that represents a return expression.

Instance Variables:
    return    <Integer>    the position of the ^ character
    value    <RBValueNode>    the value that is being returned

'>

    RBReturnNode class >> return: returnInteger value: aValueNode [
	<category: 'instance creation'>
	^self new return: returnInteger value: aValueNode
    ]

    RBReturnNode class >> value: aNode [
	<category: 'instance creation'>
	^self return: nil value: aNode
    ]

    children [
	<category: 'accessing'>
	^Array with: value
    ]

    start [
	<category: 'accessing'>
	^return
    ]

    stop [
	<category: 'accessing'>
	^value stop
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: valueNode [
	<category: 'accessing'>
	value := valueNode.
	value parent: self
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self value = anObject value
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	^self value equalTo: anObject value withMapping: aDictionary
    ]

    hash [
	<category: 'comparing'>
	^self value hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	value := value copy
    ]

    return: returnInteger value: aValueNode [
	<category: 'initialize-release'>
	return := returnInteger.
	self value: aValueNode
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    value: (value copyInContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^value match: aNode value inContext: aDictionary
    ]

    containsReturn [
	<category: 'testing'>
	^true
    ]

    isReturn [
	<category: 'testing'>
	^true
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptReturnNode: self
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	value == aNode ifTrue: [self value: anotherNode]
    ]
]



RBMethodNode subclass: RBPatternMethodNode [
    | isList |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBPatternMethodNode is a RBMethodNode that will match other method nodes without their selectors being equal. 

Instance Variables:
    isList    <Boolean>    are we matching each keyword or matching all keywords together (e.g., `keyword1: would match a one argument method whereas `@keywords: would match 0 or more arguments)

'>

    selectorParts: tokenCollection arguments: variableNodes [
	<category: 'initialize-release'>
	super selectorParts: tokenCollection arguments: variableNodes.
	isList := (tokenCollection first value at: 2) == self listCharacter
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	| selectors |
	selectors := self isSelectorList 
		    ifTrue: [(aDictionary at: selectorParts first value) keywords]
		    ifFalse: [selectorParts collect: [:each | aDictionary at: each value]].
	^(RBMethodNode new)
	    selectorParts: (selectors collect: 
			    [:each | 
			    (each last == $: ifTrue: [RBKeywordToken] ifFalse: [RBIdentifierToken]) 
				value: each
				start: nil]);
	    arguments: (self copyList: arguments inContext: aDictionary);
	    body: (body copyInContext: aDictionary);
	    source: (aDictionary at: '-source-');
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self matchingClass ifFalse: [^false].
	aDictionary at: '-source-' put: aNode source.
	self isSelectorList 
	    ifTrue: 
		[^(aDictionary at: selectorParts first value ifAbsentPut: [aNode selector]) 
		    = aNode selector and: 
			    [(aDictionary at: arguments first ifAbsentPut: [aNode arguments]) 
				= aNode arguments and: [body match: aNode body inContext: aDictionary]]].
	^(self matchArgumentsAgainst: aNode inContext: aDictionary) 
	    and: [body match: aNode body inContext: aDictionary]
    ]

    matchArgumentsAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	self arguments size == aNode arguments size ifFalse: [^false].
	(self matchSelectorAgainst: aNode inContext: aDictionary) 
	    ifFalse: [^false].
	1 to: arguments size
	    do: 
		[:i | 
		((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		    ifFalse: [^false]].
	^true
    ]

    matchSelectorAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	| keyword |
	1 to: selectorParts size
	    do: 
		[:i | 
		keyword := selectorParts at: i.
		(aDictionary at: keyword value
		    ifAbsentPut: 
			[keyword isPatternVariable 
			    ifTrue: [(aNode selectorParts at: i) value]
			    ifFalse: [keyword value]]) 
			= (aNode selectorParts at: i) value ifFalse: [^false]].
	^true
    ]

    matchingClass [
	<category: 'private'>
	^RBMethodNode
    ]

    isSelectorList [
	<category: 'testing'>
	^isList
    ]
]



RBValueNode subclass: RBStatementListNode [
    | left right body |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBStatementListNode is an AST node that represents a block "[...]" or an array constructor "{...}".

Instance Variables:
    body    <RBSequenceNode>    the code inside the block
    left    <Integer>    position of [/{
    right    <Integer>    position of ]/}

'>

    RBStatementListNode class >> body: aSequenceNode [
	<category: 'instance creation'>
	^(self new)
	    body: aSequenceNode;
	    yourself
    ]

    RBStatementListNode class >> left: leftInteger body: aSequenceNode right: rightInteger [
	<category: 'instance creation'>
	^(self new)
	    left: leftInteger
		body: aSequenceNode
		right: rightInteger;
	    yourself
    ]

    body [
	<category: 'accessing'>
	^body
    ]

    body: stmtsNode [
	<category: 'accessing'>
	body := stmtsNode.
	body parent: self
    ]

    children [
	<category: 'accessing'>
	^Array with: body
    ]

    left [
	<category: 'accessing'>
	^left
    ]

    left: anObject [
	<category: 'accessing'>
	left := anObject
    ]

    precedence [
	<category: 'accessing'>
	^0
    ]

    right [
	<category: 'accessing'>
	^right
    ]

    right: anObject [
	<category: 'accessing'>
	right := anObject
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^left
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^right
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self body = anObject body
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	^self body equalTo: anObject body withMapping: aDictionary
    ]

    hash [
	<category: 'comparing'>
	^self body hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	body := body copy
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self class body: (body copyInContext: aDictionary)
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^body match: aNode body inContext: aDictionary
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	body == aNode ifTrue: [self body: anotherNode]
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^false
    ]

    isLast: aNode [
	<category: 'testing'>
	^body isLast: aNode
    ]

    references: aVariableName [
	<category: 'testing'>
	^body references: aVariableName
    ]

    left: leftInteger body: aSequenceNode right: rightInteger [
	<category: 'initialize-release'>
	left := leftInteger.
	self body: aSequenceNode.
	right := rightInteger
    ]
]



RBStatementListNode subclass: RBOptimizedNode [
    
    <category: 'Browser-Parser'>
    <comment: '
RBOptimizedNode is an AST node that represents ##(...) expressions. These expressions are evaluated at compile time and directly inserted into the method.
'>

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptOptimizedNode: self
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]
]



RBValueNode subclass: RBMessageNode [
    | receiver selector selectorParts arguments |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBMessageNode is an AST node that represents a message send.

Instance Variables:
    arguments    <SequenceableCollection of: RBValueNode>    our argument nodes
    receiver    <RBValueNode>    the receiver''s node
    selector    <Symbol | nil>    the selector we''re sending (cached)
    selectorParts    <SequenceableCollection of: RBValueToken>    the tokens for each keyword

'>

    RBMessageNode class >> receiver: aValueNode selector: aSymbol [
	<category: 'instance creation'>
	^self 
	    receiver: aValueNode
	    selector: aSymbol
	    arguments: #()
    ]

    RBMessageNode class >> receiver: aValueNode selector: aSymbol arguments: valueNodes [
	<category: 'instance creation'>
	^(self new)
	    receiver: aValueNode;
	    arguments: valueNodes;
	    selector: aSymbol;
	    yourself
    ]

    RBMessageNode class >> receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes [
	<category: 'instance creation'>
	^((keywordTokens detect: [:each | each isPatternVariable] ifNone: [nil]) 
	    notNil ifTrue: [RBPatternMessageNode] ifFalse: [RBMessageNode]) 
	    new 
		receiver: aValueNode
		selectorParts: keywordTokens
		arguments: valueNodes
    ]

    arguments [
	<category: 'accessing'>
	^arguments isNil ifTrue: [#()] ifFalse: [arguments]
    ]

    arguments: argCollection [
	<category: 'accessing'>
	arguments := argCollection.
	arguments do: [:each | each parent: self]
    ]

    children [
	<category: 'accessing'>
	^(OrderedCollection with: self receiver)
	    addAll: self arguments;
	    yourself
    ]

    precedence [
	<category: 'accessing'>
	^self isUnary 
	    ifTrue: [1]
	    ifFalse: [self isKeyword ifTrue: [3] ifFalse: [2]]
    ]

    receiver [
	<category: 'accessing'>
	^receiver
    ]

    receiver: aValueNode [
	<category: 'accessing'>
	receiver := aValueNode.
	receiver parent: self
    ]

    selector [
	<category: 'accessing'>
	^selector isNil 
	    ifTrue: [selector := self buildSelector]
	    ifFalse: [selector]
    ]

    selector: aSelector [
	<category: 'accessing'>
	| keywords numArgs |
	keywords := aSelector keywords.
	numArgs := aSelector numArgs.
	numArgs == arguments size 
	    ifFalse: 
		[self 
		    error: 'Attempting to assign selector with wrong number of arguments.'].
	selectorParts := numArgs == 0 
		    ifTrue: [Array with: (RBIdentifierToken value: keywords first start: nil)]
		    ifFalse: 
			[keywords first last == $: 
			    ifTrue: [keywords collect: [:each | RBKeywordToken value: each start: nil]]
			    ifFalse: [Array with: (RBBinarySelectorToken value: aSelector start: nil)]].
	selector := aSelector
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^receiver start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^arguments isEmpty 
	    ifTrue: [selectorParts first stop]
	    ifFalse: [arguments last stop]
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	(self receiver = anObject receiver 
	    and: [self selector = anObject selector]) ifFalse: [^false].
	1 to: self arguments size
	    do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	((self receiver equalTo: anObject receiver withMapping: aDictionary) 
	    and: [self selector = anObject selector]) ifFalse: [^false].
	1 to: self arguments size
	    do: 
		[:i | 
		((self arguments at: i) equalTo: (anObject arguments at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	^true
    ]

    hash [
	<category: 'comparing'>
	^(self receiver hash bitXor: self selector hash) 
	    bitXor: (self arguments isEmpty 
		    ifTrue: [0]
		    ifFalse: [self arguments first hash])
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	receiver := receiver copy.
	arguments := arguments collect: [:each | each copy]
    ]

    receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes [
	<category: 'initialize-release'>
	self receiver: aValueNode.
	selectorParts := keywordTokens.
	self arguments: valueNodes
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    receiver: (receiver copyInContext: aDictionary);
	    selectorParts: (selectorParts collect: [:each | each removePositions]);
	    arguments: (arguments collect: [:each | each copyInContext: aDictionary]);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	self selector == aNode selector ifFalse: [^false].
	(receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
	1 to: arguments size
	    do: 
		[:i | 
		((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		    ifFalse: [^false]].
	^true
    ]

    buildSelector [
	<category: 'private'>
	| selectorStream |
	selectorStream := WriteStream on: (String new: 50).
	selectorParts do: [:each | selectorStream nextPutAll: each value].
	^selectorStream contents asSymbol
    ]

    selectorParts [
	<category: 'private'>
	^selectorParts
    ]

    selectorParts: tokenCollection [
	<category: 'private'>
	selectorParts := tokenCollection
    ]

    isBinary [
	<category: 'testing'>
	^(self isUnary or: [self isKeyword]) not
    ]

    isKeyword [
	<category: 'testing'>
	^selectorParts first value last == $:
    ]

    isMessage [
	<category: 'testing'>
	^true
    ]

    isUnary [
	<category: 'testing'>
	^arguments isEmpty
    ]

    lastIsReturn [
	<category: 'testing'>
	^(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: self selector) and: 
		[arguments first isBlock and: 
			[arguments first body lastIsReturn 
			    and: [arguments last isBlock and: [arguments last body lastIsReturn]]]]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptMessageNode: self
    ]

    replaceNode: aNode withNode: anotherNode [
	"If we're inside a cascade node and are changing the receiver, change all the receivers"

	<category: 'replacing'>
	receiver == aNode 
	    ifTrue: 
		[self receiver: anotherNode.
		(parent notNil and: [parent isCascade]) 
		    ifTrue: [parent messages do: [:each | each receiver: anotherNode]]].
	self arguments: (arguments 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectorParts do: 
		[:each | 
		((anInterval first between: each start and: each stop) 
		    or: [each start between: anInterval first and: anInterval last]) 
			ifTrue: [^self]].
	self children do: 
		[:each | 
		| node |
		node := each bestNodeFor: anInterval.
		node notNil ifTrue: [^node]]
    ]
]



RBValueNode subclass: RBCascadeNode [
    | messages semicolons |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBCascadeNode is an AST node for cascaded messages (e.g., "self print1 ; print2").

Instance Variables:
    messages    <SequenceableCollection of: RBMessageNode>    the messages 
    semicolons    <SequenceableCollection of: Integer>    positions of the ; between messages

'>

    RBCascadeNode class >> messages: messageNodes [
	<category: 'instance creation'>
	^self new messages: messageNodes
    ]

    RBCascadeNode class >> messages: messageNodes semicolons: integerCollection [
	<category: 'instance creation'>
	^self new messages: messageNodes semicolons: integerCollection
    ]

    children [
	<category: 'accessing'>
	^self messages
    ]

    messages [
	<category: 'accessing'>
	^messages
    ]

    messages: messageNodeCollection [
	<category: 'accessing'>
	messages := messageNodeCollection.
	messages do: [:each | each parent: self]
    ]

    precedence [
	<category: 'accessing'>
	^4
    ]

    semicolons: anObject [
	<category: 'accessing'>
	semicolons := anObject
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^messages first start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^messages last stop
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self messages size = anObject messages size ifFalse: [^false].
	1 to: self messages size
	    do: [:i | (self messages at: i) = (anObject messages at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self messages size == anObject messages size ifFalse: [^false].
	1 to: self messages size
	    do: 
		[:i | 
		((self messages at: i) equalTo: (anObject messages at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	^true
    ]

    hash [
	<category: 'comparing'>
	^self messages hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	messages := messages collect: [:each | each copy]
    ]

    messages: messageNodes semicolons: integerCollection [
	<category: 'initialize-release'>
	self messages: messageNodes.
	semicolons := integerCollection
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    messages: (self copyList: messages inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^self 
	    matchList: messages
	    against: aNode messages
	    inContext: aDictionary
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	self messages: (messages 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^messages last = aNode and: [self isDirectlyUsed]
    ]

    isCascade [
	<category: 'testing'>
	^true
    ]

    uses: aNode [
	<category: 'testing'>
	^messages last = aNode and: [self isUsed]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptCascadeNode: self
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	messages 
	    reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
	selectedChildren := (messages 
		    collect: [:each | each bestNodeFor: anInterval]) 
			reject: [:each | each isNil].
	^selectedChildren detect: [:each | true] ifNone: [nil]
    ]

    whichNodeIsContainedBy: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	messages 
	    reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
	selectedChildren := (messages 
		    collect: [:each | each whichNodeIsContainedBy: anInterval]) 
			reject: [:each | each isNil].
	^selectedChildren detect: [:each | true] ifNone: [nil]
    ]
]



RBValueNode subclass: RBAssignmentNode [
    | variable assignment value |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBAssignmentNode is an AST node for assignment statements

Instance Variables:
    assignment    <Integer>    position of the :=
    value    <RBValueNode>    the value that we''re assigning
    variable    <RBVariableNode>    the variable being assigned

'>

    RBAssignmentNode class >> variable: aVariableNode value: aValueNode [
	<category: 'instance creation'>
	^self 
	    variable: aVariableNode
	    value: aValueNode
	    position: nil
    ]

    RBAssignmentNode class >> variable: aVariableNode value: aValueNode position: anInteger [
	<category: 'instance creation'>
	^self new 
	    variable: aVariableNode
	    value: aValueNode
	    position: anInteger
    ]

    assignment [
	<category: 'accessing'>
	^assignment
    ]

    children [
	<category: 'accessing'>
	^Array with: value with: variable
    ]

    precedence [
	<category: 'accessing'>
	^5
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^variable start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^value stop
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValueNode [
	<category: 'accessing'>
	value := aValueNode.
	value parent: self
    ]

    variable [
	<category: 'accessing'>
	^variable
    ]

    variable: varNode [
	<category: 'accessing'>
	variable := varNode.
	variable parent: self
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self variable = anObject variable and: [self value = anObject value]
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	^(self variable equalTo: anObject variable withMapping: aDictionary) 
	    and: [self value equalTo: anObject value withMapping: aDictionary]
    ]

    hash [
	<category: 'comparing'>
	^self variable hash bitXor: self value hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	variable := variable postCopy.
	value := value postCopy
    ]

    variable: aVariableNode value: aValueNode position: anInteger [
	<category: 'initialize-release'>
	self variable: aVariableNode.
	self value: aValueNode.
	assignment := anInteger
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    variable: (variable copyInContext: aDictionary);
	    value: (value copyInContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^(variable match: aNode variable inContext: aDictionary) 
	    and: [value match: aNode value inContext: aDictionary]
    ]

    assigns: aVariableName [
	<category: 'testing'>
	^variable name = aVariableName or: [value assigns: aVariableName]
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^aNode = value ifTrue: [true] ifFalse: [self isDirectlyUsed]
    ]

    isAssignment [
	<category: 'testing'>
	^true
    ]

    uses: aNode [
	<category: 'testing'>
	^aNode = value ifTrue: [true] ifFalse: [self isUsed]
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	value == aNode ifTrue: [self value: anotherNode].
	variable == aNode ifTrue: [self variable: anotherNode]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptAssignmentNode: self
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	assignment isNil ifTrue: [^super bestNodeFor: anInterval].
	((anInterval first between: assignment and: assignment + 1) 
	    or: [assignment between: anInterval first and: anInterval last]) 
		ifTrue: [^self].
	self children do: 
		[:each | 
		| node |
		node := each bestNodeFor: anInterval.
		node notNil ifTrue: [^node]]
    ]
]



RBValueNode subclass: RBVariableNode [
    | token |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBVariableNode is an AST node that represent a variable (global, inst var, temp, etc.).

Instance Variables:
    token    <RBValueToken>    the token that contains our name and position

'>

    RBVariableNode class >> identifierToken: anIdentifierToken [
	<category: 'instance creation'>
	^(anIdentifierToken isPatternVariable 
	    ifTrue: [RBPatternVariableNode]
	    ifFalse: [RBVariableNode]) new 
	    identifierToken: anIdentifierToken
    ]

    RBVariableNode class >> named: aString [
	<category: 'instance creation'>
	^self identifierToken: (RBIdentifierToken value: aString start: 0)
    ]

    name [
	<category: 'accessing'>
	^token value
    ]

    precedence [
	<category: 'accessing'>
	^0
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^token start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^token stop
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self name = anObject name
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	^(aDictionary at: self name ifAbsentPut: [anObject name]) = anObject name
    ]

    hash [
	<category: 'comparing'>
	^self name hash
    ]

    identifierToken: anIdentifierToken [
	<category: 'initialize-release'>
	token := anIdentifierToken
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self class identifierToken: token removePositions
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]

    isVariable [
	<category: 'testing'>
	^true
    ]

    references: aVariableName [
	<category: 'testing'>
	^self name = aVariableName
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptVariableNode: self
    ]
]



RBValueNode subclass: RBLiteralNode [
    | token |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBLiteralNode is an AST node that represents literals (e.g., #foo, #(1 2 3), true, etc.).

Instance Variables:
    token    <RBLiteralToken>    the token that contains the literal value as well as its source positions

'>

    RBLiteralNode class >> literalToken: aLiteralToken [
	<category: 'instance creation'>
	^self new literalToken: aLiteralToken
    ]

    RBLiteralNode class >> value: aValue [
	<category: 'instance creation'>
	^self literalToken: (RBLiteralToken value: aValue)
    ]

    compiler: compiler [
	<category: 'compile-time binding'>
	token compiler: compiler
    ]

    isCompileTimeBound [
	<category: 'compile-time binding'>
	^token isCompileTimeBound
    ]

    precedence [
	<category: 'accessing'>
	^0
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^token start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^token stop
    ]

    token [
	<category: 'accessing'>
	^token
    ]

    value [
	<category: 'accessing'>
	^token realValue
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class == anObject class ifFalse: [^false].
	self value class == anObject value class ifFalse: [^false].
	^self value = anObject value
    ]

    hash [
	<category: 'comparing'>
	^self value hash
    ]

    literalToken: aLiteralToken [
	<category: 'initialize-release'>
	token := aLiteralToken
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self class literalToken: token removePositions
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]

    isLiteral [
	<category: 'testing'>
	^true
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptLiteralNode: self
    ]
]



RBStatementListNode subclass: RBArrayConstructorNode [
    
    <category: 'Refactory-Parser'>
    <comment: 'RBArrayConstructorNode is an AST node that represents an array constructor node "{...}".'>

    directlyUses: aNode [
	<category: 'testing'>
	^body statements includes: aNode
    ]

    uses: aNode [
	<category: 'testing'>
	^body statements includes: aNode
    ]

    removeDeadCode [
	<category: 'visitor'>
	self body children do: [:each | each removeDeadCode]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptArrayConstructorNode: self
    ]
]



RBStatementListNode subclass: RBBlockNode [
    | colons arguments bar |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBBlockNode is an AST node that represents a block "[...]".

Instance Variables:
    arguments    <SequenceableCollection of: RBVariableNode>    the arguments for the block
    bar    <Integer | nil>    position of the | after the arguments
    body    <RBSequenceNode>    the code inside the block
    colons    <SequenceableCollection of: Integer>    positions of each : before each argument
    left    <Integer>    position of [
    right    <Integer>    position of ]

'>

    RBBlockNode class >> body: sequenceNode [
	<category: 'instance creation'>
	^(super body: sequenceNode)
	    arguments: #();
	    yourself
    ]

    RBBlockNode class >> arguments: argNodes body: sequenceNode [
	<category: 'instance creation'>
	^(self body: sequenceNode)
	    arguments: argNodes;
	    yourself
    ]

    allArgumentVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allArgumentVariables;
	    yourself
    ]

    allDefinedVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allDefinedVariables;
	    yourself
    ]

    argumentNames [
	<category: 'accessing'>
	^self arguments collect: [:each | each name]
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    arguments: argCollection [
	<category: 'accessing'>
	arguments := argCollection.
	arguments do: [:each | each parent: self]
    ]

    bar [
	<category: 'accessing'>
	^bar
    ]

    bar: anObject [
	<category: 'accessing'>
	bar := anObject
    ]

    blockVariables [
	<category: 'accessing'>
	| vars |
	vars := super blockVariables asOrderedCollection.
	vars addAll: self argumentNames.
	^vars
    ]

    children [
	<category: 'accessing'>
	^self arguments copyWith: self body
    ]

    colons [
	<category: 'accessing'>
	^colons
    ]

    colons: anObject [
	<category: 'accessing'>
	colons := anObject
    ]

    = anObject [
	<category: 'comparing'>
	super = anObject ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	1 to: self arguments size
	    do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	1 to: self arguments size
	    do: 
		[:i | 
		((self arguments at: i) equalTo: (anObject arguments at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	(self body equalTo: anObject body withMapping: aDictionary) 
	    ifFalse: [^false].
	self arguments do: [:each | aDictionary removeKey: each name].
	^true
    ]

    hash [
	<category: 'comparing'>
	^self arguments hash bitXor: super hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	arguments := arguments collect: [:each | each copy]
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(super copyInContext: aDictionary)
	    arguments: (self copyList: arguments inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^(super match: aNode inContext: aDictionary) and: 
		[self 
		    matchList: arguments
		    against: aNode arguments
		    inContext: aDictionary]
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	super replaceNode: aNode withNode: anotherNode.
	self arguments: (arguments 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    defines: aName [
	<category: 'testing'>
	^(arguments detect: [:each | each name = aName] ifNone: [nil]) notNil
    ]

    isBlock [
	<category: 'testing'>
	^true
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]

    uses: aNode [
	<category: 'testing'>
	aNode = body ifFalse: [^false].
	^parent isMessage 
	    ifTrue: 
		[(#(#ifTrue:ifFalse: #ifTrue: #ifFalse: #ifFalse:ifTrue:) 
		    includes: parent selector) not 
		    or: [parent isUsed]]
	    ifFalse: [self isUsed]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptBlockNode: self
    ]
]



RBBlockNode subclass: RBPatternBlockNode [
    | valueBlock |
    
    <category: 'Refactory-ParseTree Matching'>
    <comment: nil>

    addArgumentWithNameBasedOn: aString [
	<category: 'matching'>
	| name index vars |
	name := aString.
	vars := self allDefinedVariables.
	index := 0.
	[vars includes: name] whileTrue: 
		[index := index + 1.
		name := name , index printString].
	arguments := arguments copyWith: (RBVariableNode named: name)
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self replacingBlock value: aDictionary
    ]

    createBlock [
	<category: 'matching'>
	| source |
	source := self formattedCode.
	^Behavior evaluate: source
    ]

    createMatchingBlock [
	<category: 'matching'>
	self arguments size > 2 
	    ifTrue: 
		[self 
		    error: 'Search blocks can only contain arguments for the node and matching dictionary'].
	self arguments size == 0 
	    ifTrue: [self error: 'Search blocks must contain one argument for the node'].
	self arguments size = 1 
	    ifTrue: [self addArgumentWithNameBasedOn: 'aDictionary'].
	^self createBlock
    ]

    createReplacingBlock [
	<category: 'matching'>
	self arguments size > 1 
	    ifTrue: 
		[self 
		    error: 'Replace blocks can only contain an argument for the matching dictionary'].
	self arguments size = 0 
	    ifTrue: [self addArgumentWithNameBasedOn: 'aDictionary'].
	^self createBlock
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	^self matchingBlock value: aNode value: aDictionary
    ]

    matchingBlock [
	<category: 'matching'>
	^valueBlock isNil 
	    ifTrue: [valueBlock := self createMatchingBlock]
	    ifFalse: [valueBlock]
    ]

    replacingBlock [
	<category: 'matching'>
	^valueBlock isNil 
	    ifTrue: [valueBlock := self createReplacingBlock]
	    ifFalse: [valueBlock]
    ]

    sentMessages [
	<category: 'accessing'>
	^OrderedCollection new
    ]
]



RBMessageNode subclass: RBPatternMessageNode [
    | isList isCascadeList |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBPatternMessageNode is a RBMessageNode that will match other message nodes without their selectors being equal. 

Instance Variables:
    isList    <Boolean>    are we matching each keyword or matching all keywords together (e.g., `keyword1: would match a one argument method whereas `@keywords: would match 0 or more arguments)'>

    receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes [
	<category: 'initialize-release'>
	| message |
	super 
	    receiver: aValueNode
	    selectorParts: keywordTokens
	    arguments: valueNodes.
	isCascadeList := isList := false.
	message := keywordTokens first value.
	2 to: message size
	    do: 
		[:i | 
		| character |
		character := message at: i.
		character == self listCharacter 
		    ifTrue: [isList := true]
		    ifFalse: 
			[character == self cascadeListCharacter 
			    ifTrue: [isCascadeList := true]
			    ifFalse: [^self]]]
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	| selectors |
	self isList ifTrue: [^aDictionary at: self].
	selectors := self isSelectorList 
		    ifTrue: [(aDictionary at: selectorParts first value) keywords]
		    ifFalse: [selectorParts collect: [:each | aDictionary at: each value]].
	^(RBMessageNode new)
	    receiver: (receiver copyInContext: aDictionary);
	    selectorParts: (selectors collect: 
			    [:each | 
			    (each last == $: ifTrue: [RBKeywordToken] ifFalse: [RBIdentifierToken]) 
				value: each
				start: nil]);
	    arguments: (self copyList: arguments inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self matchingClass ifFalse: [^false].
	(receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
	self isSelectorList 
	    ifTrue: 
		[^(aDictionary at: selectorParts first value ifAbsentPut: [aNode selector]) 
		    == aNode selector and: 
			    [(aDictionary at: arguments first ifAbsentPut: [aNode arguments]) 
				= aNode arguments]].
	^self matchArgumentsAgainst: aNode inContext: aDictionary
    ]

    matchArgumentsAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	self arguments size == aNode arguments size ifFalse: [^false].
	(self matchSelectorAgainst: aNode inContext: aDictionary) 
	    ifFalse: [^false].
	1 to: arguments size
	    do: 
		[:i | 
		((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		    ifFalse: [^false]].
	^true
    ]

    matchSelectorAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	| keyword |
	1 to: selectorParts size
	    do: 
		[:i | 
		keyword := selectorParts at: i.
		(aDictionary at: keyword value
		    ifAbsentPut: 
			[keyword isPatternVariable 
			    ifTrue: [(aNode selectorParts at: i) value]
			    ifFalse: [keyword value]]) 
			= (aNode selectorParts at: i) value ifFalse: [^false]].
	^true
    ]

    matchingClass [
	<category: 'private'>
	^RBMessageNode
    ]

    isList [
	<category: 'testing-matching'>
	^isCascadeList and: [parent notNil and: [parent isCascade]]
    ]

    isSelectorList [
	<category: 'testing-matching'>
	^isList
    ]
]



RBVariableNode subclass: RBPatternVariableNode [
    | recurseInto isList isLiteral isStatement isAnything |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBPatternVariableNode is an AST node that is used to match several other types of nodes (literals, variables, value nodes, statement nodes, and sequences of statement nodes).

The different types of matches are determined by the name of the node. If the name contains a # character, then it will match a literal. If it contains, a . then it matches statements. If it contains no extra characters, then it matches only variables. These options are mutually exclusive.

The @ character can be combined with the name to match lists of items. If combined with the . character, then it will match a list of statement nodes (0 or more). If used without the . or # character, then it matches anything except for list of statements. Combining the @ with the # is not supported.

Adding another ` in the name will cause the search/replace to look for more matches inside the node that this node matched. This option should not be used for top level expressions since that would cause infinite recursion (e.g., searching only for "``@anything").

Instance Variables:
    isList    <Boolean>    can we match a list of items (@)
    isLiteral    <Boolean>    only match a literal node (#)
    isStatement    <Boolean>    only match statements (.)
    recurseInto    <Boolean>    search for more matches in the node we match (`)

'>

    identifierToken: anIdentifierToken [
	<category: 'initialize-release'>
	super identifierToken: anIdentifierToken.
	self initializePatternVariables
    ]

    initializePatternVariables [
	<category: 'initialize-release'>
	| name |
	name := self name.
	isAnything := isList := isLiteral := isStatement := recurseInto := false.
	2 to: name size
	    do: 
		[:i | 
		| character |
		character := name at: i.
		character == self listCharacter 
		    ifTrue: [isAnything := isList := true]
		    ifFalse: 
			[character == self literalCharacter 
			    ifTrue: [isLiteral := true]
			    ifFalse: 
				[character == self statementCharacter 
				    ifTrue: [isStatement := true]
				    ifFalse: 
					[character == self recurseIntoCharacter 
					    ifTrue: [recurseInto := true]
					    ifFalse: [^self]]]]]
    ]

    parent: aRBProgramNode [
	"Fix the case where '``@node' should match a single node, not a sequence node."

	<category: 'accessing'>
	super parent: aRBProgramNode.
	parent isSequence 
	    ifTrue: 
		[(self isStatement or: [parent temporaries includes: self]) 
		    ifFalse: [isList := false]]
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^aDictionary at: self
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	self isAnything 
	    ifTrue: [^(aDictionary at: self ifAbsentPut: [aNode]) = aNode].
	self isLiteral ifTrue: [^self matchLiteral: aNode inContext: aDictionary].
	self isStatement 
	    ifTrue: [^self matchStatement: aNode inContext: aDictionary].
	aNode class == self matchingClass ifFalse: [^false].
	^(aDictionary at: self ifAbsentPut: [aNode]) = aNode
    ]

    matchLiteral: aNode inContext: aDictionary [
	<category: 'matching'>
	^aNode class == RBLiteralNode 
	    and: [(aDictionary at: self ifAbsentPut: [aNode]) = aNode]
    ]

    matchStatement: aNode inContext: aDictionary [
	<category: 'matching'>
	(aNode parent notNil and: [aNode parent isSequence]) ifFalse: [^false].
	^(aDictionary at: self ifAbsentPut: [aNode]) = aNode
    ]

    matchingClass [
	<category: 'private'>
	^RBVariableNode
    ]

    isAnything [
	<category: 'testing-matching'>
	^isAnything
    ]

    isList [
	<category: 'testing-matching'>
	^isList
    ]

    isLiteral [
	<category: 'testing-matching'>
	^isLiteral
    ]

    isStatement [
	<category: 'testing-matching'>
	^isStatement
    ]

    recurseInto [
	<category: 'testing-matching'>
	^recurseInto
    ]
]

