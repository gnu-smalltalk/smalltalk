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



Object subclass: #RBProgramNodeVisitor
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBProgramNodeVisitor comment:
'RBProgramNodeVisitor is an abstract visitor for the RBProgramNodes.

'!


!RBProgramNodeVisitor methodsFor: 'initialize-release'!

initialize! !

!RBProgramNodeVisitor methodsFor: 'visiting'!

visitArgument: each 
    "Here to allow subclasses to detect arguments or temporaries."

    ^self visitNode: each!

visitArguments: aNodeCollection 
    ^aNodeCollection do: [:each | self visitArgument: each]!

visitNode: aNode 
    ^aNode acceptVisitor: self! !

!RBProgramNodeVisitor methodsFor: 'visitor-double dispatching'!

acceptAssignmentNode: anAssignmentNode 
    self visitNode: anAssignmentNode variable.
    self visitNode: anAssignmentNode value!

acceptArrayConstructorNode: anArrayNode 
    self visitNode: anArrayNode body!

acceptBlockNode: aBlockNode 
    self visitArguments: aBlockNode arguments.
    self visitNode: aBlockNode body!

acceptCascadeNode: aCascadeNode 
    aCascadeNode messages do: [:each | self visitNode: each ]!

acceptLiteralNode: aLiteralNode!

acceptMessageNode: aMessageNode 
    self visitNode: aMessageNode receiver.
    aMessageNode arguments do: [:each | self visitNode: each]!

acceptMethodNode: aMethodNode 
    self visitArguments: aMethodNode arguments.
    self visitNode: aMethodNode body!

acceptOptimizedNode: anOptimizedNode 
    self visitNode: anOptimizedNode body!

acceptReturnNode: aReturnNode 
    self visitNode: aReturnNode value!

acceptSequenceNode: aSequenceNode 
    self visitArguments: aSequenceNode temporaries.
    aSequenceNode statements do: [:each | self visitNode: each]!

acceptVariableNode: aVariableNode! !

RBProgramNodeVisitor class
    instanceVariableNames: ''!



!RBProgramNodeVisitor class methodsFor: 'instance creation'!

new
    ^super new initialize! !


Object subclass: #RBProgramNode
    instanceVariableNames: 'parent comments '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBProgramNode comment:
'RBProgramNode is an abstract class that represents an abstract syntax tree node in a Smalltalk program.

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

'!


!RBProgramNode methodsFor: 'accessing'!

allArgumentVariables
    | children |
    children := self children.
    children isEmpty ifTrue: [^#()].
    ^children inject: OrderedCollection new
	into: 
	    [:vars :each | 
	    vars
		addAll: each allArgumentVariables;
		yourself]!

allDefinedVariables
    | children |
    children := self children.
    children isEmpty ifTrue: [^#()].
    ^children inject: OrderedCollection new
	into: 
	    [:vars :each | 
	    vars addAll: each allDefinedVariables;
		yourself]!

allTemporaryVariables
    | children |
    children := self children.
    children isEmpty ifTrue: [^#()].
    ^children inject: OrderedCollection new
	into: 
	    [:vars :each | 
	    vars
		addAll: each allTemporaryVariables;
		yourself]!

asReturn
    "Change the current node to a return node."

    parent isNil ifTrue: [self error: 'Cannot change to a return without a parent node.'].
    parent isSequence ifFalse: [self error: 'Parent node must be a sequence node.'].
    (parent isLast: self)
	ifFalse: [self error: 'Return node must be last.'].
    ^parent addReturn!

blockVariables
    ^parent isNil
	ifTrue: [#()]
	ifFalse: [parent blockVariables]!

children
    ^#()!

comments
    ^comments isNil
	ifTrue: [#()]
	ifFalse: [comments]!

comments: aCollection
    comments := aCollection!

formattedCode
    ^self formatterClass new format: self!

formatterClass
    ^RBFormatter!

parent
    ^parent!

parent: anObject
    parent := anObject!

precedence
    ^6!

source
    ^parent notNil ifTrue: [parent source] ifFalse: [nil]!

sourceInterval
    ^self start to: self stop!

start
    self subclassResponsibility!

stop
    self subclassResponsibility!

temporaryVariables
    ^parent isNil
	ifTrue: [#()]
	ifFalse: [parent temporaryVariables]! !

!RBProgramNode methodsFor: 'comparing'!

equalTo: aNode exceptForVariables: variableNameCollection 
    | dictionary |
    dictionary := Dictionary new.
    (self equalTo: aNode withMapping: dictionary) ifFalse: [^false].
    dictionary keysAndValuesDo: 
	    [:key :value | 
	    (key = value or: [variableNameCollection includes: key]) ifFalse: [^false]].
    ^true!

equalTo: aNode withMapping: aDictionary 
    ^self = aNode! !

!RBProgramNode methodsFor: 'copying'!

copyCommentsFrom: aNode 
    "Add all comments from aNode to us. If we already have the comment, then don't add it."

    | newComments |
    newComments := OrderedCollection new.
    aNode nodesDo: [:each | newComments addAll: each comments].
    self nodesDo: 
	    [:each | 
	    each comments do: [:comment | newComments remove: comment ifAbsent: []]].
    newComments isEmpty ifTrue: [^self].
    newComments := newComments asSortedCollection: [:a :b | a first < b first].
    self comments: newComments! !

!RBProgramNode methodsFor: 'iterating'!

nodesDo: aBlock 
    aBlock value: self.
    self children do: [:each | each nodesDo: aBlock]! !

!RBProgramNode methodsFor: 'enumeration'!

collect: aBlock 
    "Hacked to fit collection protocols"

    ^aBlock value: self!

do: aBlock 
    "Hacked to fit collection protocols"

    aBlock value: self!

size
    "Hacked to fit collection protocols"

    ^1! !

!RBProgramNode methodsFor: 'matching'!

copyInContext: aDictionary
    ^self copy!

copyList: matchNodes inContext: aDictionary 
    | newNodes |
    newNodes := OrderedCollection new.
    matchNodes do: 
	    [:each | 
	    | object |
	    object := each copyInContext: aDictionary.
	    newNodes addAll: object].
    ^newNodes!

match: aNode inContext: aDictionary 
    ^self = aNode!

matchList: matchNodes against: programNodes inContext: aDictionary 
    ^self
	matchList: matchNodes
	index: 1
	against: programNodes
	index: 1
	inContext: aDictionary!

matchList: matchNodes index: matchIndex against: programNodes index: programIndex inContext: aDictionary 
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
					[currentDictionary keysAndValuesDo: [:key :value | aDictionary at: key put: value].
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
	inContext: aDictionary! !

!RBProgramNode methodsFor: 'pattern variable-accessing'!

cascadeListCharacter
    ^$;!

listCharacter
    ^$@!

literalCharacter
    ^$#!

recurseIntoCharacter
    ^$`!

statementCharacter
    ^$.! !

!RBProgramNode methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: self class name;
	nextPut: $(;
	nextPutAll: self formattedCode;
	nextPut: $)! !

!RBProgramNode methodsFor: 'querying'!

bestNodeFor: anInterval 
    | selectedChildren |
    (self intersectsInterval: anInterval) ifFalse: [^nil].
    (self containedBy: anInterval) ifTrue: [^self].
    selectedChildren := self children 
		select: [:each | each intersectsInterval: anInterval].
    ^selectedChildren size == 1 
	ifTrue: [selectedChildren first bestNodeFor: anInterval]
	ifFalse: [self]!

selfMessages
    | searcher |
    searcher := ParseTreeSearcher new.
    searcher matches: 'self `@msg: ``@args'
	do: 
	    [:aNode :answer | 
	    answer
		add: aNode selector;
		yourself].
    ^searcher executeTree: self initialAnswer: Set new!

statementNode
    "Return your topmost node that is contained by a sequence node."

    (parent isNil or: [parent isSequence]) ifTrue: [^self].
    ^parent statementNode!

superMessages
    | searcher |
    searcher := ParseTreeSearcher new.
    searcher matches: 'super `@msg: ``@args'
	do: 
	    [:aNode :answer | 
	    answer
		add: aNode selector;
		yourself].
    ^searcher executeTree: self initialAnswer: Set new!

whichNodeIsContainedBy: anInterval 
    | selectedChildren |
    (self intersectsInterval: anInterval) ifFalse: [^nil].
    (self containedBy: anInterval) ifTrue: [^self].
    selectedChildren := self children 
		select: [:each | each intersectsInterval: anInterval].
    ^selectedChildren size == 1 
	ifTrue: [selectedChildren first whichNodeIsContainedBy: anInterval]
	ifFalse: [nil]!

whoDefines: aName 
    ^(self defines: aName)
	ifTrue: [self]
	ifFalse: [parent notNil
		ifTrue: [parent whoDefines: aName]
		ifFalse: [nil]]! !

!RBProgramNode methodsFor: 'replacing'!

removeDeadCode
    self children do: [:each | each removeDeadCode]!

replaceNode: aNode withNode: anotherNode 
    self error: 'I don''t store other nodes'!

replaceWith: aNode 
    parent isNil ifTrue: [self error: 'This node doesn''t have a parent'].
    parent replaceNode: self withNode: aNode! !

!RBProgramNode methodsFor: 'testing'!

assigns: aVariableName 
    ^(self children detect: [:each | each assigns: aVariableName] ifNone: [nil]) 
	notNil!

containedBy: anInterval 
    ^anInterval first <= self start and: [anInterval last >= self stop]!

containsReturn
    ^(self children detect: [:each | each containsReturn] ifNone: [nil]) 
	notNil!

defines: aName
    ^false!

directlyUses: aNode
    ^true!

evaluatedFirst: aNode 
    self children do: 
	    [:each | 
	    each == aNode ifTrue: [^true].
	    each isImmediate ifFalse: [^false]].
    ^false!

intersectsInterval: anInterval 
    ^(anInterval first between: self start and: self stop) 
	or: [self start between: anInterval first and: anInterval last]!

isAssignment
    ^false!

isBlock
    ^false!

isCascade
    ^false!

isCompileTimeBound
    ^false!

isDirectlyUsed
    "This node is directly used as an argument, receiver, or part of an assignment."

    ^parent isNil
	ifTrue: [false]
	ifFalse: [parent directlyUses: self]!

isEvaluatedFirst
    "Return true if we are the first thing evaluated in this statement."

    ^parent isNil or: [parent isSequence or: [parent evaluatedFirst: self]]!

isImmediate
    ^false!

isLast: aNode 
    | children |
    children := self children.
    ^children isEmpty not and: [children last == aNode]!

isLiteral
    ^false!

isMessage
    ^false!

isMethod
    ^false!

isReturn
    ^false!

isSequence
    ^false!

isUsed
    "Answer true if this node could be used as part of another expression. For example, you could use the 
    result of this node as a receiver of a message, an argument, the right part of an assignment, or the 
    return value of a block. This differs from isDirectlyUsed in that it is conservative since it also includes 
    return values of blocks."

    ^parent isNil
	ifTrue: [false]
	ifFalse: [parent uses: self]!

isValue
    ^false!

isVariable
    ^false!

lastIsReturn
    ^self isReturn!

references: aVariableName 
    ^(self children detect: [:each | each references: aVariableName]
	ifNone: [nil]) notNil!

uses: aNode
    ^true! !

!RBProgramNode methodsFor: 'testing-matching'!

isList
    ^false!

recurseInto
    ^false! !

!RBProgramNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    self subclassResponsibility! !

RBProgramNode class
    instanceVariableNames: ''!



RBProgramNode subclass: #RBSequenceNode
    instanceVariableNames: 'leftBar rightBar statements periods temporaries '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBSequenceNode comment:
'RBSequenceNode is an AST node that represents a sequence of statements. Both RBBlockNodes and RBMethodNodes contain these.

Instance Variables:
    leftBar    <Integer | nil>    the position of the left | in the temporaries definition
    periods    <SequenceableCollection of: Integer>    the positions of all the periods that separate the statements
    rightBar    <Integer | nil>    the position of the right | in the temporaries definition
    statements    <SequenceableCollection of: RBStatementNode>    the statement nodes
    temporaries    <SequenceableCollection of: RBVariableNode>    the temporaries defined

'!


!RBSequenceNode methodsFor: 'accessing'!

addReturn
    | node |
    statements isEmpty ifTrue: [^nil].
    statements last isReturn ifTrue: [^statements last].
    node := RBReturnNode value: statements last.
    statements at: statements size put: node.
    node parent: self.
    ^node!

allDefinedVariables
    ^(self temporaryNames asOrderedCollection) addAll: super allDefinedVariables;
	yourself!

allTemporaryVariables
    ^(self temporaryNames asOrderedCollection)
	addAll: super allTemporaryVariables;
	yourself!

children
    ^(OrderedCollection new) addAll: self temporaries;
	addAll: self statements;
	yourself!

leftBar
    ^leftBar!

periods: anObject
    periods := anObject!

removeTemporaryNamed: aName 
    temporaries := temporaries reject: [:each | each name = aName]!

rightBar
    ^rightBar!

start
    ^leftBar isNil 
	ifTrue: [statements isEmpty ifTrue: [1] ifFalse: [statements first start]]
	ifFalse: [leftBar]!

statements
    ^statements!

statements: stmtCollection 
    statements := stmtCollection.
    statements do: [:each | each parent: self]!

stop
    ^(periods isEmpty
	ifTrue: [0]
	ifFalse: [periods last])
	max: (statements isEmpty
		ifTrue: [0]
		ifFalse: [statements last stop])!

temporaries
    ^temporaries!

temporaries: tempCollection 
    temporaries := tempCollection.
    temporaries do: [:each | each parent: self]!

temporaryNames
    ^temporaries collect: [:each | each name]!

temporaryVariables
    ^(super temporaryVariables asOrderedCollection) addAll: self temporaryNames;
	yourself! !

!RBSequenceNode methodsFor: 'comparing'!

= anObject 
    "Can't send = to the temporaries and statements collection since they might change from arrays to OCs"

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
    ^true!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    self statements size == anObject statements size ifFalse: [^false].
    1 to: self statements size
	do: 
	    [:i | 
	    ((self statements at: i) equalTo: (anObject statements at: i)
		withMapping: aDictionary) ifFalse: [^false]].
    aDictionary values asSet size = aDictionary size ifFalse: [^false].    "Not a one-to-one mapping"
    self temporaries
	do: [:each | aDictionary removeKey: each name ifAbsent: []].
    ^true!

hash
    ^self temporaries hash bitXor: (self statements isEmpty
	    ifTrue: [0]
	    ifFalse: [self statements first hash])! !

!RBSequenceNode methodsFor: 'copying'!

postCopy
    super postCopy.
    temporaries := temporaries collect: [:each | each copy].
    statements := statements collect: [:each | each copy]! !

!RBSequenceNode methodsFor: 'initialize-release'!

leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger 
    leftBar := leftInteger.
    self temporaries: variableNodes.
    rightBar := rightInteger! !

!RBSequenceNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(self class new)
	temporaries: (self copyList: temporaries inContext: aDictionary);
	statements: (self copyList: statements inContext: aDictionary);
	yourself!

match: aNode inContext: aDictionary 
    self class == aNode class ifFalse: [^false].
    ^(self matchList: temporaries
	against: aNode temporaries
	inContext: aDictionary) and: 
		[self matchList: statements
		    against: aNode statements
		    inContext: aDictionary]! !

!RBSequenceNode methodsFor: 'replacing'!

removeDeadCode
    (self isUsed ifTrue: [statements size - 1] ifFalse: [statements size]) 
	to: 1
	by: -1
	do: [:i | (statements at: i) isImmediate ifTrue: [statements removeAtIndex: i]].
    super removeDeadCode!

removeNode: aNode
    self replaceNode: aNode withNodes: #()!

replaceNode: aNode withNode: anotherNode 
    self statements: (statements 
		collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]]).
    self temporaries: (temporaries 
		collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])!

replaceNode: aNode withNodes: aCollection 
    | index newStatements |
    index := self indexOfNode: aNode.
    newStatements := OrderedCollection new: statements size + aCollection size.
    1 to: index - 1 do: [:i | newStatements add: (statements at: i)].
    newStatements addAll: aCollection.
    index + 1 to: statements size
	do: [:i | newStatements add: (statements at: i)].
    aCollection do: [:each | each parent: self].
    statements := newStatements! !

!RBSequenceNode methodsFor: 'private'!

indexOfNode: aNode 
    "Try to find the node by first looking for ==, and then for ="

    ^(1 to: statements size) detect: [:each | each == aNode]
	ifNone: [statements indexOf: aNode]! !

!RBSequenceNode methodsFor: 'testing'!

defines: aName 
    ^(temporaries detect: [:each | each name = aName] ifNone: [nil]) notNil!

directlyUses: aNode 
    ^false!

isLast: aNode 
    | last |
    statements isEmpty ifTrue: [^false].
    last := statements last.
    ^last == aNode or: [last isMessage and: [(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: last selector)
		and: [last arguments inject: false into: [:bool :each | bool or: [each isLast: aNode]]]]]!

isSequence
    ^true!

lastIsReturn
    ^statements isEmpty not and: [statements last lastIsReturn]!

references: aVariableName 
    ^(statements detect: [:each | each references: aVariableName] ifNone: [nil]) 
	notNil!

uses: aNode 
    statements isEmpty ifTrue: [^false].
    aNode == statements last ifFalse: [^false].
    ^self isUsed! !

!RBSequenceNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptSequenceNode: self! !

!RBSequenceNode methodsFor: 'adding nodes'!

addNode: aNode 
    aNode parent: self.
    (statements isEmpty not and: [statements last isReturn])
	ifTrue: [self error: 'Cannot add statement after return node'].
    statements := statements asOrderedCollection add: aNode; yourself!

addNode: aNode before: anotherNode 
    | index |
    index := self indexOfNode: anotherNode.
    index = 0 ifTrue: [^self addNode: aNode].
    statements := (statements asOrderedCollection)
		add: aNode beforeIndex: index;
		yourself.
    aNode parent: self!

addNodeFirst: aNode 
    aNode parent: self.
    statements := (statements asOrderedCollection)
		addFirst: aNode;
		yourself!

addNodes: aCollection 
    aCollection do: [:each | each parent: self].
    (statements isEmpty not and: [statements last isReturn]) 
	ifTrue: [self error: 'Cannot add statement after return node'].
    statements := (statements asOrderedCollection)
		addAll: aCollection;
		yourself!

addNodes: aCollection before: anotherNode 
    aCollection do: [:each | self addNode: each before: anotherNode]!

addNodesFirst: aCollection 
    aCollection do: [:each | each parent: self].
    statements := (statements asOrderedCollection)
		addAllFirst: aCollection;
		yourself!

addSelfReturn
    | node |
    self lastIsReturn ifTrue: [^self].
    node := RBReturnNode value: (RBVariableNode named: 'self').
    self addNode: node!

addTemporariesNamed: aCollection 
    aCollection do: [:each | self addTemporaryNamed: each]!

addTemporaryNamed: aString 
    | variableNode |
    variableNode := RBVariableNode named: aString.
    variableNode parent: self.
    temporaries := temporaries copyWith: variableNode! !

!RBSequenceNode methodsFor: 'querying'!

bestNodeFor: anInterval 
    | node |
    node := super bestNodeFor: anInterval.
    node == self 
	ifTrue: 
	    [(temporaries isEmpty and: [statements size == 1]) 
		ifTrue: [^statements first]].
    ^node!

whichNodeIsContainedBy: anInterval 
    | node |
    node := super whichNodeIsContainedBy: anInterval.
    node == self 
	ifTrue: 
	    [(temporaries isEmpty and: [statements size == 1]) 
		ifTrue: [^statements first]].
    ^node! !

RBSequenceNode class
    instanceVariableNames: ''!



!RBSequenceNode class methodsFor: 'instance creation'!

leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger 
    ^self new
	leftBar: leftInteger
	temporaries: variableNodes
	rightBar: rightInteger!

statements: statementNodes 
    ^self temporaries: #() statements: statementNodes!

temporaries: variableNodes statements: statementNodes 
    ^(self new)
	temporaries: variableNodes;
	statements: statementNodes;
	yourself! !


!Behavior methodsFor: 'RefactoringBrowser'!

parseTreeFor: aSymbol 
    ^RBParser parseMethod: (self sourceCodeAt: aSymbol)
	onError: [:aString :pos | ^nil]! !


RBProgramNode subclass: #RBStatementNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBStatementNode comment:
'RBStatementNode is an abstract class that represents AST nodes that can go in sequence nodes.

'!

RBStatementNode class
    instanceVariableNames: ''!



RBProgramNode subclass: #RBMethodNode
    instanceVariableNames: 'selector selectorParts body source arguments tags '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBMethodNode comment:
'RBMethodNode is the AST that represents a Smalltalk method.

Instance Variables:
    arguments    <SequenceableCollection of: RBVariableNode>    the arguments to the method
    body    <RBSequenceNode>    the body/statements of the method
    selector    <Symbol | nil>    the method name (cached)
    selectorParts    <SequenceableCollection of: RBValueToken>    the tokens for the selector keywords
    source    <String>    the source we compiled
    tag    <Interval | nil>    the source location of any resource/primitive tags

'!


!RBMethodNode methodsFor: 'accessing'!

addNode: aNode 
    ^body addNode: aNode!

addReturn
    body addReturn!

addSelfReturn
    ^body addSelfReturn!

allArgumentVariables
    ^(self argumentNames asOrderedCollection)
	addAll: super allArgumentVariables;
	yourself!

allDefinedVariables
    ^(self argumentNames asOrderedCollection) addAll: super allDefinedVariables;
	yourself!

argumentNames
    ^self arguments collect: [:each | each name]!

arguments
    ^arguments!

arguments: variableNodes 
    arguments := variableNodes.
    arguments do: [:each | each parent: self]!

body
    ^body!

body: stmtsNode 
    body := stmtsNode.
    body parent: self!

children
    ^self arguments copyWith: self body!

primitiveSources
    ^self tags 
	collect: [:each | self source copyFrom: each first to: each last]!

isBinary
    ^(self isUnary or: [self isKeyword]) not!

isKeyword
    ^selectorParts first value last == $:!

isUnary
    ^self arguments isEmpty!

selector
    ^selector isNil
	ifTrue: [selector := self buildSelector]
	ifFalse: [selector]!

selector: aSelector 
    | keywords numArgs |
    keywords := aSelector keywords.
    numArgs := aSelector numArgs.
    numArgs == arguments size ifFalse: 
	    [self error: 'Attempting to assign selector with wrong number of arguments.'].
    selectorParts := numArgs == 0
		ifTrue: [Array with: (RBIdentifierToken value: keywords first start: nil)]
		ifFalse: 
		    [keywords first last == $:
			ifTrue: [keywords collect: [:each | RBKeywordToken value: each start: nil]]
			ifFalse: [Array with: (RBBinarySelectorToken value: aSelector start: nil)]].
    selector := aSelector!

source
    ^source!

source: anObject
    source := anObject!

start
    ^1!

stop
    ^source size!

tags
    ^tags isNil ifTrue: [#()] ifFalse: [tags]!

tags: aCollectionOfIntervals 
    tags := aCollectionOfIntervals! !

!RBMethodNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    (self selector = anObject selector and: [self body = anObject body]) 
	ifFalse: [^false].
    1 to: self arguments size
	do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
    ^true!

equalTo: anObject withMapping: aDictionary 
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
    ^self primitiveSources = anObject primitiveSources!

hash
    ^(self selector hash bitXor: self body hash)
	bitXor: self arguments hash! !

!RBMethodNode methodsFor: 'copying'!

postCopy
    super postCopy.
    body := body copy.
    arguments := arguments collect: [:each | each copy]! !

!RBMethodNode methodsFor: 'initialize-release'!

selectorParts: tokenCollection arguments: variableNodes 
    selectorParts := tokenCollection.
    self arguments: variableNodes! !

!RBMethodNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(self class new)
	selectorParts: (selectorParts collect: [:each | each removePositions]);
	arguments: (arguments collect: [:each | each copyInContext: aDictionary]);
	body: (body copyInContext: aDictionary);
	source: (aDictionary at: '-source-');
	yourself!

match: aNode inContext: aDictionary 
    self class == aNode class ifFalse: [^false].
    aDictionary at: '-source-' put: aNode source.
    self selector == aNode selector ifFalse: [^false].
    ^(self matchList: arguments
	against: aNode arguments
	inContext: aDictionary)
	    and: [body match: aNode body inContext: aDictionary]! !

!RBMethodNode methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: self formattedCode! !

!RBMethodNode methodsFor: 'private'!

buildSelector
    | selectorStream |
    selectorStream := WriteStream on: (String new: 50).
    selectorParts do: [:each | selectorStream nextPutAll: each value].
    ^selectorStream contents asSymbol!

selectorParts
    ^selectorParts!

selectorParts: tokenCollection 
    selectorParts := tokenCollection! !

!RBMethodNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    aNode == body ifTrue: [self body: anotherNode].
    self arguments: (arguments 
		collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])! !

!RBMethodNode methodsFor: 'testing'!

defines: aName 
    ^(arguments detect: [:each | each name = aName] ifNone: [nil]) notNil!

isLast: aNode 
    ^body isLast: aNode!

isMethod
    ^true!

isPrimitive
     ^tags notNil and:
                [tags isEmpty not and:
                        [(self primitiveSources detect: [:each | '*primitive*' match: each]
                                                ifNone: [nil]) notNil]]!


lastIsReturn
    ^body lastIsReturn!

references: aVariableName 
    ^body references: aVariableName!

uses: aNode 
    ^body == aNode and: [aNode lastIsReturn]! !

!RBMethodNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptMethodNode: self! !

RBMethodNode class
    instanceVariableNames: ''!



!RBMethodNode class methodsFor: 'instance creation'!

selector: aSymbol arguments: variableNodes body: aSequenceNode 
    ^(self new)
	arguments: variableNodes;
	selector: aSymbol;
	body: aSequenceNode;
	yourself!

selector: aSymbol body: aSequenceNode 
    ^self 
	selector: aSymbol
	arguments: #()
	body: aSequenceNode!

selectorParts: tokenCollection arguments: variableNodes 
    ^((tokenCollection detect: [:each | each isPatternVariable]
	ifNone: [nil]) notNil
	ifTrue: [RBPatternMethodNode]
	ifFalse: [RBMethodNode]) new selectorParts: tokenCollection arguments: variableNodes! !


RBStatementNode subclass: #RBValueNode
    instanceVariableNames: 'parentheses '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBValueNode comment:
'RBValueNode is an abstract class that represents a node that returns some value.

Instance Variables:
    parentheses    <SequenceableCollection of: Inteval>    the positions of the parethesis around this node. We need a collection of intervals for stupid code such as "((3 + 4))" that has multiple parethesis around the same expression.

'!


!RBValueNode methodsFor: 'accessing'!

addParenthesis: anInterval 
    parentheses isNil ifTrue: [parentheses := OrderedCollection new: 1].
    parentheses add: anInterval!

parentheses
    ^parentheses isNil
	ifTrue: [#()]
	ifFalse: [parentheses]!

start
    ^parentheses isNil 
	ifTrue: [self startWithoutParentheses]
	ifFalse: [parentheses last first]!

startWithoutParentheses
    ^self subclassResponsibility!

stop
    ^parentheses isNil
	ifTrue: [self stopWithoutParentheses]
	ifFalse: [parentheses last last]!

stopWithoutParentheses
    ^self subclassResponsibility! !

!RBValueNode methodsFor: 'testing'!

containedBy: anInterval 
    ^anInterval first <= self startWithoutParentheses 
	and: [anInterval last >= self stopWithoutParentheses]!

hasParentheses
    ^self parentheses isEmpty not!

isValue
    ^true! !

RBValueNode class
    instanceVariableNames: ''!



RBStatementNode subclass: #RBReturnNode
    instanceVariableNames: 'return value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBReturnNode comment:
'RBReturnNode is an AST node that represents a return expression.

Instance Variables:
    return    <Integer>    the position of the ^ character
    value    <RBValueNode>    the value that is being returned

'!


!RBReturnNode methodsFor: 'accessing'!

children
    ^Array with: value!

start
    ^return!

stop
    ^value stop!

value
    ^value!

value: valueNode 
    value := valueNode.
    value parent: self! !

!RBReturnNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    ^self value = anObject value!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    ^self value equalTo: anObject value withMapping: aDictionary!

hash
    ^self value hash! !

!RBReturnNode methodsFor: 'copying'!

postCopy
    super postCopy.
    value := value copy! !

!RBReturnNode methodsFor: 'initialize-release'!

return: returnInteger value: aValueNode 
    return := returnInteger.
    self value: aValueNode! !

!RBReturnNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(self class new) value: (value copyInContext: aDictionary); yourself!

match: aNode inContext: aDictionary 
    aNode class == self class ifFalse: [^false].
    ^value match: aNode value inContext: aDictionary! !

!RBReturnNode methodsFor: 'testing'!

containsReturn
    ^true!

isReturn
    ^true! !

!RBReturnNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptReturnNode: self! !

!RBReturnNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    value == aNode ifTrue: [self value: anotherNode]! !

RBReturnNode class
    instanceVariableNames: ''!



!RBReturnNode class methodsFor: 'instance creation'!

return: returnInteger value: aValueNode 
    ^self new return: returnInteger value: aValueNode!

value: aNode
    ^self return: nil value: aNode! !


RBMethodNode subclass: #RBPatternMethodNode
    instanceVariableNames: 'isList '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBPatternMethodNode comment:
'RBPatternMethodNode is a RBMethodNode that will match other method nodes without their selectors being equal. 

Instance Variables:
    isList    <Boolean>    are we matching each keyword or matching all keywords together (e.g., `keyword1: would match a one argument method whereas `@keywords: would match 0 or more arguments)

'!


!RBPatternMethodNode methodsFor: 'initialize-release'!

selectorParts: tokenCollection arguments: variableNodes 
    super selectorParts: tokenCollection arguments: variableNodes.
    isList := (tokenCollection first value at: 2) == self listCharacter! !

!RBPatternMethodNode methodsFor: 'matching'!

copyInContext: aDictionary 
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
	yourself!

match: aNode inContext: aDictionary 
    aNode class == self matchingClass ifFalse: [^false].
    aDictionary at: '-source-' put: aNode source.
    self isSelectorList ifTrue: 
	    [^(aDictionary at: selectorParts first value ifAbsentPut: [aNode selector])
		= aNode selector and: 
			[(aDictionary at: arguments first ifAbsentPut: [aNode arguments])
			    = aNode arguments and: [body match: aNode body inContext: aDictionary]]].
    ^(self matchArgumentsAgainst: aNode inContext: aDictionary)
	and: [body match: aNode body inContext: aDictionary]!

matchArgumentsAgainst: aNode inContext: aDictionary 
    self arguments size == aNode arguments size ifFalse: [^false].
    (self matchSelectorAgainst: aNode inContext: aDictionary) 
	ifFalse: [^false].
    1 to: arguments size
	do: 
	    [:i | 
	    ((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		ifFalse: [^false]].
    ^true!

matchSelectorAgainst: aNode inContext: aDictionary 
    | keyword |
    1 to: selectorParts size
	do: 
	    [:i | 
	    keyword := selectorParts at: i.
	    (aDictionary at: keyword value
		ifAbsentPut: 
		    [keyword isPatternVariable 
			ifTrue: [(aNode selectorParts at: i) value ]
			ifFalse: [keyword value]]) 
		    = (aNode selectorParts at: i) value ifFalse: [^false]].
    ^true! !

!RBPatternMethodNode methodsFor: 'private'!

matchingClass
    ^RBMethodNode! !

!RBPatternMethodNode methodsFor: 'testing'!

isSelectorList
    ^isList! !

RBPatternMethodNode class
    instanceVariableNames: ''!



RBValueNode subclass: #RBStatementListNode
    instanceVariableNames: 'left right body '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBStatementListNode comment:
'RBStatementListNode is an AST node that represents a block "[...]" or an array constructor "{...}".

Instance Variables:
    body    <RBSequenceNode>    the code inside the block
    left    <Integer>    position of [/{
    right    <Integer>    position of ]/}

'!


!RBStatementListNode class methodsFor: 'instance creation'!

body: aSequenceNode
    ^(self new)
	body: aSequenceNode;
	yourself!

left: leftInteger body: aSequenceNode right: rightInteger 
    ^(self new)
    	left: leftInteger
    		body: aSequenceNode
    		right: rightInteger;
    	yourself! !

!RBStatementListNode methodsFor: 'accessing'!

body
    ^body!

body: stmtsNode 
    body := stmtsNode.
    body parent: self!

children
    ^Array with: body!

left
    ^left!

left: anObject
    left := anObject!

precedence
    ^0!

right
    ^right!

right: anObject
    right := anObject!

startWithoutParentheses
    ^left!

stopWithoutParentheses
    ^right! !

!RBStatementListNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    ^self body = anObject body!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    self arguments size = anObject arguments size ifFalse: [^false].
    ^self body equalTo: anObject body withMapping: aDictionary!

hash
    ^self body hash! !

!RBStatementListNode methodsFor: 'copying'!

postCopy
    super postCopy.
    body := body copy! !

!RBStatementListNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^self class body: (body copyInContext: aDictionary)!

match: aNode inContext: aDictionary 
    aNode class == self class ifFalse: [^false].
    ^body match: aNode body inContext: aDictionary! !

!RBStatementListNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    body == aNode ifTrue: [self body: anotherNode]! !

!RBStatementListNode methodsFor: 'testing'!

directlyUses: aNode 
    ^false!

isLast: aNode 
    ^body isLast: aNode!

references: aVariableName 
    ^body references: aVariableName! !

!RBStatementListNode methodsFor: 'initialize-release'!

left: leftInteger body: aSequenceNode right: rightInteger 
    left := leftInteger.
    self body: aSequenceNode.
    right := rightInteger! !

RBStatementListNode class
    instanceVariableNames: ''!

RBStatementListNode subclass: #RBOptimizedNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Browser-Parser'!

RBOptimizedNode comment: '
RBOptimizedNode is an AST node that represents ##(...) expressions. These expressions are evaluated at compile time and directly inserted into the method.
'!


!RBOptimizedNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptOptimizedNode: self! !

!RBOptimizedNode methodsFor: 'testing'!

isImmediate
    ^true! !

RBValueNode subclass: #RBMessageNode
    instanceVariableNames: 'receiver selector selectorParts arguments '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBMessageNode comment:
'RBMessageNode is an AST node that represents a message send.

Instance Variables:
    arguments    <SequenceableCollection of: RBValueNode>    our argument nodes
    receiver    <RBValueNode>    the receiver''s node
    selector    <Symbol | nil>    the selector we''re sending (cached)
    selectorParts    <SequenceableCollection of: RBValueToken>    the tokens for each keyword

'!


!RBMessageNode methodsFor: 'accessing'!

arguments
    ^arguments isNil
	ifTrue: [#()]
	ifFalse: [arguments]!

arguments: argCollection 
    arguments := argCollection.
    arguments do: [:each | each parent: self]!

children
    ^(OrderedCollection with: self receiver) addAll: self arguments;
	yourself!

precedence
    ^self isUnary ifTrue: [1] ifFalse: [self isKeyword ifTrue: [3] ifFalse: [2]]!

receiver
    ^receiver!

receiver: aValueNode 
    receiver := aValueNode.
    receiver parent: self!

selector
    ^selector isNil
	ifTrue: [selector := self buildSelector]
	ifFalse: [selector]!

selector: aSelector 
    | keywords numArgs |
    keywords := aSelector keywords.
    numArgs := aSelector numArgs.
    numArgs == arguments size ifFalse: 
	    [self error: 'Attempting to assign selector with wrong number of arguments.'].
    selectorParts := numArgs == 0
		ifTrue: [Array with: (RBIdentifierToken value: keywords first start: nil)]
		ifFalse: 
		    [keywords first last == $:
			ifTrue: [keywords collect: [:each | RBKeywordToken value: each start: nil]]
			ifFalse: [Array with: (RBBinarySelectorToken value: aSelector start: nil)]].
    selector := aSelector!

startWithoutParentheses
    ^receiver start!

stopWithoutParentheses
    ^arguments isEmpty 
	ifTrue: [selectorParts first stop]
	ifFalse: [arguments last stop]! !

!RBMessageNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    (self receiver = anObject receiver 
	and: [self selector = anObject selector]) ifFalse: [^false].
    1 to: self arguments size
	do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
    ^true!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    ((self receiver equalTo: anObject receiver withMapping: aDictionary)
	and: [self selector = anObject selector]) ifFalse: [^false].
    1 to: self arguments size
	do: 
	    [:i | 
	    ((self arguments at: i) equalTo: (anObject arguments at: i)
		withMapping: aDictionary) ifFalse: [^false]].
    ^true!

hash
    ^(self receiver hash bitXor: self selector hash)
	bitXor: (self arguments isEmpty ifTrue: [0] ifFalse: [self arguments first hash])! !

!RBMessageNode methodsFor: 'copying'!

postCopy
    super postCopy.
    receiver := receiver copy.
    arguments := arguments collect: [:each | each copy]! !

!RBMessageNode methodsFor: 'initialize-release'!

receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes 
    self receiver: aValueNode.
    selectorParts := keywordTokens.
    self arguments: valueNodes! !

!RBMessageNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(self class new) receiver: (receiver copyInContext: aDictionary);
	selectorParts: (selectorParts collect: [:each | each removePositions]);
	arguments: (arguments collect: [:each | each copyInContext: aDictionary]);
	yourself!

match: aNode inContext: aDictionary 
    aNode class == self class ifFalse: [^false].
    self selector == aNode selector ifFalse: [^false].
    (receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
    1 to: arguments size
	do: 
	    [:i | 
	    ((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary)
		ifFalse: [^false]].
    ^true! !

!RBMessageNode methodsFor: 'private'!

buildSelector
    | selectorStream |
    selectorStream := WriteStream on: (String new: 50).
    selectorParts do: [:each | selectorStream nextPutAll: each value].
    ^selectorStream contents asSymbol!

selectorParts
    ^selectorParts!

selectorParts: tokenCollection 
    selectorParts := tokenCollection! !

!RBMessageNode methodsFor: 'testing'!

isBinary
    ^(self isUnary or: [self isKeyword]) not!

isKeyword
    ^selectorParts first value last == $:!

isMessage
    ^true!

isUnary
    ^arguments isEmpty!

lastIsReturn
    ^(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: self selector) and: 
	    [arguments first isBlock and: 
		    [arguments first body lastIsReturn
			and: [arguments last isBlock and: [arguments last body lastIsReturn]]]]! !

!RBMessageNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptMessageNode: self! !

!RBMessageNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    "If we're inside a cascade node and are changing the receiver, change all the receivers"

    receiver == aNode 
	ifTrue: 
	    [self receiver: anotherNode.
	    (parent notNil and: [parent isCascade]) 
		ifTrue: [parent messages do: [:each | each receiver: anotherNode]]].
    self arguments: (arguments 
		collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])! !

!RBMessageNode methodsFor: 'querying'!

bestNodeFor: anInterval 
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
	    node notNil ifTrue: [^node]]! !

RBMessageNode class
    instanceVariableNames: ''!



!RBMessageNode class methodsFor: 'instance creation'!

receiver: aValueNode selector: aSymbol 
    ^self 
	receiver: aValueNode
	selector: aSymbol
	arguments: #()!

receiver: aValueNode selector: aSymbol arguments: valueNodes 
    ^(self new)
	receiver: aValueNode;
	arguments: valueNodes;
	selector: aSymbol;
	yourself!

receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes 
    ^((keywordTokens detect: [:each | each isPatternVariable] ifNone: [nil])
	notNil ifTrue: [RBPatternMessageNode] ifFalse: [RBMessageNode]) new
	    receiver: aValueNode
	    selectorParts: keywordTokens
	    arguments: valueNodes! !


RBValueNode subclass: #RBCascadeNode
    instanceVariableNames: 'messages semicolons '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBCascadeNode comment:
'RBCascadeNode is an AST node for cascaded messages (e.g., "self print1 ; print2").

Instance Variables:
    messages    <SequenceableCollection of: RBMessageNode>    the messages 
    semicolons    <SequenceableCollection of: Integer>    positions of the ; between messages

'!


!RBCascadeNode methodsFor: 'accessing'!

children
    ^self messages!

messages
    ^messages!

messages: messageNodeCollection 
    messages := messageNodeCollection.
    messages do: [:each | each parent: self]!

precedence
    ^4!

semicolons: anObject
    semicolons := anObject!

startWithoutParentheses
    ^messages first start!

stopWithoutParentheses
    ^messages last stop! !

!RBCascadeNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    self messages size = anObject messages size ifFalse: [^false].
    1 to: self messages size
	do: [:i | (self messages at: i) = (anObject messages at: i) ifFalse: [^false]].
    ^true!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    self messages size == anObject messages size ifFalse: [^false].
    1 to: self messages size
	do: 
	    [:i | 
	    ((self messages at: i) equalTo: (anObject messages at: i)
		withMapping: aDictionary) ifFalse: [^false]].
    ^true!

hash
    ^self messages hash! !

!RBCascadeNode methodsFor: 'copying'!

postCopy
    super postCopy.
    messages := messages collect: [:each | each copy]! !

!RBCascadeNode methodsFor: 'initialize-release'!

messages: messageNodes semicolons: integerCollection 
    self messages: messageNodes.
    semicolons := integerCollection! !

!RBCascadeNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(self class new) messages: (self copyList: messages inContext: aDictionary);
	yourself!

match: aNode inContext: aDictionary 
    aNode class == self class ifFalse: [^false].
    ^self matchList: messages
	against: aNode messages
	inContext: aDictionary! !

!RBCascadeNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    self messages: (messages 
		collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])! !

!RBCascadeNode methodsFor: 'testing'!

directlyUses: aNode 
    ^messages last = aNode and: [self isDirectlyUsed]!

isCascade
    ^true!

uses: aNode 
    ^messages last = aNode and: [self isUsed]! !

!RBCascadeNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptCascadeNode: self! !

!RBCascadeNode methodsFor: 'querying'!

bestNodeFor: anInterval 
    | selectedChildren |
    (self intersectsInterval: anInterval) ifFalse: [^nil].
    (self containedBy: anInterval) ifTrue: [^self].
    messages 
	reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
    selectedChildren := (messages 
		collect: [:each | each bestNodeFor: anInterval]) 
		    reject: [:each | each isNil].
    ^selectedChildren detect: [:each | true] ifNone: [nil]!

whichNodeIsContainedBy: anInterval 
    | selectedChildren |
    (self intersectsInterval: anInterval) ifFalse: [^nil].
    (self containedBy: anInterval) ifTrue: [^self].
    messages 
	reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
    selectedChildren := (messages 
		collect: [:each | each whichNodeIsContainedBy: anInterval]) 
		    reject: [:each | each isNil].
    ^selectedChildren detect: [:each | true] ifNone: [nil]! !

RBCascadeNode class
    instanceVariableNames: ''!



!RBCascadeNode class methodsFor: 'instance creation'!

messages: messageNodes 
    ^self new messages: messageNodes!

messages: messageNodes semicolons: integerCollection 
    ^self new messages: messageNodes semicolons: integerCollection! !


RBValueNode subclass: #RBAssignmentNode
    instanceVariableNames: 'variable assignment value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBAssignmentNode comment:
'RBAssignmentNode is an AST node for assignment statements

Instance Variables:
    assignment    <Integer>    position of the :=
    value    <RBValueNode>    the value that we''re assigning
    variable    <RBVariableNode>    the variable being assigned

'!


!RBAssignmentNode methodsFor: 'accessing'!

assignment
    ^assignment!

children
    ^Array with: value with: variable!

precedence
    ^5!

startWithoutParentheses
    ^variable start!

stopWithoutParentheses
    ^value stop!

value
    ^value!

value: aValueNode 
    value := aValueNode.
    value parent: self!

variable
    ^variable!

variable: varNode 
    variable := varNode.
    variable parent: self! !

!RBAssignmentNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    ^self variable = anObject variable and: [self value = anObject value]!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    ^(self variable equalTo: anObject variable withMapping: aDictionary)
	and: [self value equalTo: anObject value withMapping: aDictionary]!

hash
    ^self variable hash bitXor: self value hash! !

!RBAssignmentNode methodsFor: 'copying'!

postCopy
    super postCopy.
    variable := variable postCopy.
    value := value postCopy! !

!RBAssignmentNode methodsFor: 'initialize-release'!

variable: aVariableNode value: aValueNode position: anInteger 
    self variable: aVariableNode.
    self value: aValueNode.
    assignment := anInteger! !

!RBAssignmentNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(self class new) variable: (variable copyInContext: aDictionary);
	value: (value copyInContext: aDictionary);
	yourself!

match: aNode inContext: aDictionary 
    aNode class == self class ifFalse: [^false].
    ^(variable match: aNode variable inContext: aDictionary)
	and: [value match: aNode value inContext: aDictionary]! !

!RBAssignmentNode methodsFor: 'testing'!

assigns: aVariableName 
    ^variable name = aVariableName or: [value assigns: aVariableName]!

directlyUses: aNode 
    ^aNode = value ifTrue: [true] ifFalse: [self isDirectlyUsed]!

isAssignment
    ^true!

uses: aNode 
    ^aNode = value ifTrue: [true] ifFalse: [self isUsed]! !

!RBAssignmentNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    value == aNode ifTrue: [self value: anotherNode].
    variable == aNode ifTrue: [self variable: anotherNode]! !

!RBAssignmentNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptAssignmentNode: self! !

!RBAssignmentNode methodsFor: 'querying'!

bestNodeFor: anInterval 
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
	    node notNil ifTrue: [^node]]! !

RBAssignmentNode class
    instanceVariableNames: ''!



!RBAssignmentNode class methodsFor: 'instance creation'!

variable: aVariableNode value: aValueNode 
    ^self 
	variable: aVariableNode
	value: aValueNode
	position: nil!

variable: aVariableNode value: aValueNode position: anInteger 
    ^self new
	variable: aVariableNode
	value: aValueNode
	position: anInteger! !


RBValueNode subclass: #RBVariableNode
    instanceVariableNames: 'token '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBVariableNode comment:
'RBVariableNode is an AST node that represent a variable (global, inst var, temp, etc.).

Instance Variables:
    token    <RBValueToken>    the token that contains our name and position

'!


!RBVariableNode methodsFor: 'accessing'!

name
    ^token value!

precedence
    ^0!

startWithoutParentheses
    ^token start!

stopWithoutParentheses
    ^token stop! !

!RBVariableNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class = anObject class ifFalse: [^false].
    ^self name = anObject name!

equalTo: anObject withMapping: aDictionary 
    self class = anObject class ifFalse: [^false].
    ^(aDictionary at: self name ifAbsentPut: [anObject name]) = anObject name!

hash
    ^self name hash! !

!RBVariableNode methodsFor: 'initialize-release'!

identifierToken: anIdentifierToken 
    token := anIdentifierToken! !

!RBVariableNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^self class identifierToken: token removePositions! !

!RBVariableNode methodsFor: 'testing'!

isImmediate
    ^true!

isVariable
    ^true!

references: aVariableName 
    ^self name = aVariableName! !

!RBVariableNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptVariableNode: self! !

RBVariableNode class
    instanceVariableNames: ''!



!RBVariableNode class methodsFor: 'instance creation'!

identifierToken: anIdentifierToken 
    ^(anIdentifierToken isPatternVariable
	ifTrue: [RBPatternVariableNode]
	ifFalse: [RBVariableNode]) new identifierToken: anIdentifierToken!

named: aString 
    ^self identifierToken: (RBIdentifierToken value: aString start: 0)! !


RBValueNode subclass: #RBLiteralNode
    instanceVariableNames: 'token '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBLiteralNode comment:
'RBLiteralNode is an AST node that represents literals (e.g., #foo, #(1 2 3), true, etc.).

Instance Variables:
    token    <RBLiteralToken>    the token that contains the literal value as well as its source positions

'!


!RBLiteralNode methodsFor: 'compile-time binding'!

compiler: compiler
    token compiler: compiler!

isCompileTimeBound
    ^token isCompileTimeBound! !

!RBLiteralNode methodsFor: 'accessing'!

precedence
    ^0!

startWithoutParentheses
    ^token start!

stopWithoutParentheses
    ^token stop!

token
    ^token!

value
    ^token realValue! !

!RBLiteralNode methodsFor: 'comparing'!

= anObject 
    self == anObject ifTrue: [^true].
    self class == anObject class ifFalse: [^false].
    self value class == anObject value class ifFalse: [^false].
    ^self value = anObject value!

hash
    ^self value hash! !

!RBLiteralNode methodsFor: 'initialize-release'!

literalToken: aLiteralToken 
    token := aLiteralToken! !

!RBLiteralNode methodsFor: 'matching'!

copyInContext: aDictionary
    ^self class literalToken: token removePositions! !

!RBLiteralNode methodsFor: 'testing'!

isImmediate
    ^true!

isLiteral
    ^true! !

!RBLiteralNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptLiteralNode: self! !

RBLiteralNode class
    instanceVariableNames: ''!



!RBLiteralNode class methodsFor: 'instance creation'!

literalToken: aLiteralToken 
    ^self new literalToken: aLiteralToken!

value: aValue 
    ^self literalToken: (RBLiteralToken value: aValue)! !


RBStatementListNode subclass: #RBArrayConstructorNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBArrayConstructorNode comment:
'RBArrayConstructorNode is an AST node that represents an array constructor node "{...}".'!

!RBArrayConstructorNode methodsFor: 'testing'!

directlyUses: aNode 
    ^body statements includes: aNode!

uses: aNode 
    ^body statements includes: aNode! !

!RBArrayConstructorNode methodsFor: 'visitor'!

removeDeadCode
    self body children do: [ :each |
	each removeDeadCode
    ]! !

!RBArrayConstructorNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptArrayConstructorNode: self! !



RBStatementListNode subclass: #RBBlockNode
    instanceVariableNames: 'colons arguments bar '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBBlockNode comment:
'RBBlockNode is an AST node that represents a block "[...]".

Instance Variables:
    arguments    <SequenceableCollection of: RBVariableNode>    the arguments for the block
    bar    <Integer | nil>    position of the | after the arguments
    body    <RBSequenceNode>    the code inside the block
    colons    <SequenceableCollection of: Integer>    positions of each : before each argument
    left    <Integer>    position of [
    right    <Integer>    position of ]

'!


!RBBlockNode methodsFor: 'accessing'!

allArgumentVariables
    ^(self argumentNames asOrderedCollection)
	addAll: super allArgumentVariables;
	yourself!

allDefinedVariables
    ^(self argumentNames asOrderedCollection) addAll: super allDefinedVariables;
	yourself!

argumentNames
    ^self arguments collect: [:each | each name]!

arguments
    ^arguments!

arguments: argCollection 
    arguments := argCollection.
    arguments do: [:each | each parent: self]!

bar
    ^bar!

bar: anObject
    bar := anObject!

blockVariables
    | vars |
    vars := super blockVariables asOrderedCollection.
    vars addAll: self argumentNames.
    ^vars!

children
    ^self arguments copyWith: self body!

colons
    ^colons!

colons: anObject
    colons := anObject! !

!RBBlockNode methodsFor: 'comparing'!

= anObject 
    super = anObject ifFalse: [^false].
    self arguments size = anObject arguments size ifFalse: [^false].
    1 to: self arguments size
	do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
    ^true!

equalTo: anObject withMapping: aDictionary 
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
    ^true!

hash
    ^self arguments hash bitXor: super hash! !

!RBBlockNode methodsFor: 'copying'!

postCopy
    super postCopy.
    arguments := arguments collect: [:each | each copy]! !

!RBBlockNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^(super copyInContext: aDictionary)
	arguments: (self copyList: arguments inContext: aDictionary);
	yourself!

match: aNode inContext: aDictionary 
    aNode class == self class ifFalse: [^false].
    ^(super match: aNode inContext: aDictionary) and: [
	self matchList: arguments
	    against: aNode arguments
	    inContext: aDictionary]! !

!RBBlockNode methodsFor: 'replacing'!

replaceNode: aNode withNode: anotherNode 
    super replaceNode: aNode withNode: anotherNode.
    self arguments: (arguments 
		collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])! !

!RBBlockNode methodsFor: 'testing'!

defines: aName 
    ^(arguments detect: [:each | each name = aName] ifNone: [nil]) notNil!

isBlock
    ^true!

isImmediate
    ^true!

uses: aNode 
    aNode = body ifFalse: [^false].
    ^parent isMessage
	ifTrue: [(#(#ifTrue:ifFalse: #ifTrue: #ifFalse: #ifFalse:ifTrue:) includes: parent selector) not or: [parent isUsed]]
	ifFalse: [self isUsed]! !

!RBBlockNode methodsFor: 'visitor'!

acceptVisitor: aProgramNodeVisitor 
    ^aProgramNodeVisitor acceptBlockNode: self! !

RBBlockNode class
    instanceVariableNames: ''!



!RBBlockNode class methodsFor: 'instance creation'!

body: sequenceNode
    ^(super body: sequenceNode)
	arguments: #();
	yourself!

arguments: argNodes body: sequenceNode 
    ^(self body: sequenceNode)
	arguments: argNodes;
	yourself! !



RBBlockNode subclass: #RBPatternBlockNode
        instanceVariableNames: 'valueBlock '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'Refactory-ParseTree Matching'!


!RBPatternBlockNode methodsFor: 'matching'!

addArgumentWithNameBasedOn: aString
    | name index vars |
    name := aString.
    vars := self allDefinedVariables.
    index := 0.
    [vars includes: name] whileTrue:
        [index := index + 1.
        name := name , index printString].
    arguments := arguments copyWith: (RBVariableNode named: name)!

copyInContext: aDictionary
    ^self replacingBlock value: aDictionary!

createBlock
    | source |
    source := self formattedCode.
    ^Behavior evaluate: source!

createMatchingBlock
    self arguments size > 2
        ifTrue:
            [self
                error: 'Search blocks can only contain arguments for the node and matching dictionary'].
    self arguments size == 0
        ifTrue: [self error: 'Search blocks must contain one argument for the node'].
    self arguments size = 1
        ifTrue: [self addArgumentWithNameBasedOn: 'aDictionary'].
    ^self createBlock!

createReplacingBlock
    self arguments size > 1
        ifTrue:
            [self
                error: 'Replace blocks can only contain an argument for the matching dictionary'].
    self arguments size = 0
        ifTrue: [self addArgumentWithNameBasedOn: 'aDictionary'].
    ^self createBlock!

match: aNode inContext: aDictionary
    ^self matchingBlock value: aNode value: aDictionary!

matchingBlock
    ^valueBlock isNil
        ifTrue: [valueBlock := self createMatchingBlock]
        ifFalse: [valueBlock]!

replacingBlock
    ^valueBlock isNil
        ifTrue: [valueBlock := self createReplacingBlock]
        ifFalse: [valueBlock]! !

!RBPatternBlockNode methodsFor: 'accessing'!

sentMessages
    ^OrderedCollection new! !


RBMessageNode subclass: #RBPatternMessageNode
    instanceVariableNames: 'isList isCascadeList '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBPatternMessageNode comment:
'RBPatternMessageNode is a RBMessageNode that will match other message nodes without their selectors being equal. 

Instance Variables:
    isList    <Boolean>    are we matching each keyword or matching all keywords together (e.g., `keyword1: would match a one argument method whereas `@keywords: would match 0 or more arguments)'!


!RBPatternMessageNode methodsFor: 'initialize-release'!

receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes 
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
			ifFalse: [^self]]]! !

!RBPatternMessageNode methodsFor: 'matching'!

copyInContext: aDictionary 
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
	yourself!

match: aNode inContext: aDictionary 
    aNode class == self matchingClass ifFalse: [^false].
    (receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
    self isSelectorList ifTrue: 
	    [^(aDictionary at: selectorParts first value ifAbsentPut: [aNode selector])
		== aNode selector and: 
			[(aDictionary at: arguments first ifAbsentPut: [aNode arguments])
			    = aNode arguments]].
    ^self matchArgumentsAgainst: aNode inContext: aDictionary!

matchArgumentsAgainst: aNode inContext: aDictionary 
    self arguments size == aNode arguments size ifFalse: [^false].
    (self matchSelectorAgainst: aNode inContext: aDictionary) 
	ifFalse: [^false].
    1 to: arguments size
	do: 
	    [:i | 
	    ((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		ifFalse: [^false]].
    ^true!

matchSelectorAgainst: aNode inContext: aDictionary 
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
    ^true! !

!RBPatternMessageNode methodsFor: 'private'!

matchingClass
    ^RBMessageNode! !

!RBPatternMessageNode methodsFor: 'testing-matching'!

isList
    ^isCascadeList and: [parent notNil and: [parent isCascade]]!

isSelectorList
    ^isList! !

RBPatternMessageNode class
    instanceVariableNames: ''!



RBVariableNode subclass: #RBPatternVariableNode
    instanceVariableNames: 'recurseInto isList isLiteral isStatement isAnything '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

RBPatternVariableNode comment:
'RBPatternVariableNode is an AST node that is used to match several other types of nodes (literals, variables, value nodes, statement nodes, and sequences of statement nodes).

The different types of matches are determined by the name of the node. If the name contains a # character, then it will match a literal. If it contains, a . then it matches statements. If it contains no extra characters, then it matches only variables. These options are mutually exclusive.

The @ character can be combined with the name to match lists of items. If combined with the . character, then it will match a list of statement nodes (0 or more). If used without the . or # character, then it matches anything except for list of statements. Combining the @ with the # is not supported.

Adding another ` in the name will cause the search/replace to look for more matches inside the node that this node matched. This option should not be used for top level expressions since that would cause infinite recursion (e.g., searching only for "``@anything").

Instance Variables:
    isList    <Boolean>    can we match a list of items (@)
    isLiteral    <Boolean>    only match a literal node (#)
    isStatement    <Boolean>    only match statements (.)
    recurseInto    <Boolean>    search for more matches in the node we match (`)

'!


!RBPatternVariableNode methodsFor: 'initialize-release'!

identifierToken: anIdentifierToken 
    super identifierToken: anIdentifierToken.
    self initializePatternVariables!

initializePatternVariables
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
					ifFalse: [^self]]]]]! !

!RBPatternVariableNode methodsFor: 'accessing'!

parent: aRBProgramNode 
    "Fix the case where '``@node' should match a single node, not a sequence node."

    super parent: aRBProgramNode.
    parent isSequence 
	ifTrue: 
	    [(self isStatement or: [parent temporaries includes: self]) 
		ifFalse: [isList := false]]! !

!RBPatternVariableNode methodsFor: 'matching'!

copyInContext: aDictionary 
    ^aDictionary at: self!

match: aNode inContext: aDictionary 
    self isAnything ifTrue: [^(aDictionary at: self ifAbsentPut: [aNode]) = aNode].
    self isLiteral ifTrue: [^self matchLiteral: aNode inContext: aDictionary].
    self isStatement
	ifTrue: [^self matchStatement: aNode inContext: aDictionary].
    aNode class == self matchingClass ifFalse: [^false].
    ^(aDictionary at: self ifAbsentPut: [aNode]) = aNode!

matchLiteral: aNode inContext: aDictionary 
    ^aNode class == RBLiteralNode 
	and: [(aDictionary at: self ifAbsentPut: [aNode]) = aNode]!

matchStatement: aNode inContext: aDictionary 
    (aNode parent notNil and: [aNode parent isSequence]) ifFalse: [^false].
    ^(aDictionary at: self ifAbsentPut: [aNode]) = aNode! !

!RBPatternVariableNode methodsFor: 'private'!

matchingClass
    ^RBVariableNode! !

!RBPatternVariableNode methodsFor: 'testing-matching'!

isAnything
    ^isAnything!

isList
    ^isList!

isLiteral
    ^isLiteral!

isStatement
    ^isStatement!

recurseInto
    ^recurseInto! !

RBPatternVariableNode class
    instanceVariableNames: ''!


