"======================================================================
|
|   Refactoring Browser - Parse tree searching and rewriting
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



Object subclass: #RBReadBeforeWrittenTester
    instanceVariableNames: 'read checkNewTemps scopeStack searcher '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBReadBeforeWrittenTester methodsFor: 'initialize-release'!

checkNewTemps: aBoolean 
    checkNewTemps := aBoolean!

createSearchTrees
    searcher := ParseTreeSearcher new.

    "Case 1 - Set the values, depending on whether we matched an assignment"
    searcher
	matches: '`var := `@object'
	    do: 
		[:aNode :ans | 
		searcher executeTree: aNode value.
		self variableWritten: aNode.
		ans];
	matches: '`var'
	    do: 
		[:aNode :ans | 
		self variableRead: aNode.
		ans].

    "Handle the special while* and ifTrue:ifFalse: blocks separately"
    searcher
	matchesAnyOf: 
		#('[| `@temps | ``@.Statements] whileTrue: ``@block' 
		'[| `@temps | ``@.Statements] whileTrue' 
		'[| `@temps | ``@.Statements] whileFalse: ``@block' 
		'[| `@temps | ``@.Statements] whileFalse')
	    do: [:aNode :ans | ans];
	matchesAnyOf: 
		#('`@condition ifTrue: [| `@tTemps | `@.trueBlock] ifFalse: [| `@fTemps| `@.falseBlock]' 
		'`@condition ifFalse: [| `@fTemps | `@.falseBlock] ifTrue: [| `@tTemps | `@.trueBlock]')
	    do: 
		[:aNode :ans | 
		searcher executeTree: aNode receiver.
		self processIfTrueIfFalse: aNode.
		ans].

    "Case 2 - Recursive call yourself on the body of the block node just matched"
    searcher matches: '[:`@args | | `@temps | `@.Statements]'
	do: 
	    [:aNode :ans | 
	    self processBlock: aNode.
	    ans].
    searcher matches: '| `@temps | `@.Stmts'
	do: 
	    [:aNode :ans | 
	    self processStatementNode: aNode.
	    ans]!

initialize
    scopeStack := OrderedCollection with: Dictionary new.
    read := Set new.
    checkNewTemps := true.
    self createSearchTrees!

initializeVars: varNames 
    varNames do: [:each | self currentScope at: each put: nil]! !

!RBReadBeforeWrittenTester methodsFor: 'accessing'!

executeTree: aParseTree 
    ^searcher executeTree: aParseTree!

read
    self currentScope
	keysAndValuesDo: [:key :value | value == true ifTrue: [read add: key]].
    ^read! !

!RBReadBeforeWrittenTester methodsFor: 'private'!

copyDictionary: aDictionary 
    "We could send aDictionary the copy message, but that doesn't copy the associations."

    | newDictionary |
    newDictionary := Dictionary new: aDictionary size.
    aDictionary
	keysAndValuesDo: [:key :value | newDictionary at: key put: value].
    ^newDictionary!

createScope
    scopeStack add: (self copyDictionary: scopeStack last)!

currentScope
    ^scopeStack last!

processBlock: aNode 
    | newScope |
    self createScope.
    self executeTree: aNode body.
    newScope := self removeScope.
    newScope keysAndValuesDo: 
	    [:key :value | 
	    (value == true and: [(self currentScope at: key) isNil]) 
		ifTrue: [self currentScope at: key put: value]]!

processIfTrueIfFalse: aNode 
    | trueScope falseScope |
    self createScope.
    self executeTree: aNode arguments first body.
    trueScope := self removeScope.
    self createScope.
    self executeTree: aNode arguments last body.
    falseScope := self removeScope.
    self currentScope keysAndValuesDo: 
	    [:key :value | 
	    value isNil 
		ifTrue: 
		    [(trueScope at: key) == (falseScope at: key) 
			ifTrue: [self currentScope at: key put: (trueScope at: key)]
			ifFalse: 
			    [((trueScope at: key) == true or: [(falseScope at: key) == true]) 
				ifTrue: [self currentScope at: key put: true]]]]!

processStatementNode: aNode 
    | temps |
    (checkNewTemps not or: [aNode temporaries isEmpty]) 
	ifTrue: 
	    [aNode statements do: [:each | self executeTree: each].
	    ^self].
    self createScope.
    temps := aNode temporaries collect: [:each | each name].
    self initializeVars: temps.
    aNode statements do: [:each | self executeTree: each].
    self removeScope keysAndValuesDo: 
	    [:key :value | 
	    (temps includes: key) 
		ifTrue: [value == true ifTrue: [read add: key]]
		ifFalse: 
		    [(self currentScope at: key) isNil 
			ifTrue: [self currentScope at: key put: value]]]!

removeScope
    ^scopeStack removeLast!

variableRead: aNode 
    (self currentScope includesKey: aNode name) ifTrue: 
	    [(self currentScope at: aNode name) isNil
		ifTrue: [self currentScope at: aNode name put: true]]!

variableWritten: aNode 
    (self currentScope includesKey: aNode variable name) ifTrue: 
	    [(self currentScope at: aNode variable name) isNil
		ifTrue: [self currentScope at: aNode variable name put: false]]! !

RBReadBeforeWrittenTester class
    instanceVariableNames: ''!



!RBReadBeforeWrittenTester class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!RBReadBeforeWrittenTester class methodsFor: 'accessing'!

isVariable: aString readBeforeWrittenIn: aBRProgramNode
    ^(self isVariable: aString writtenBeforeReadIn: aBRProgramNode) not!

isVariable: aString writtenBeforeReadIn: aBRProgramNode
    ^(self readBeforeWritten: (Array with: aString) in: aBRProgramNode)
        isEmpty!

readBeforeWritten: varNames in: aParseTree 
    ^(self new)
	checkNewTemps: false;
	initializeVars: varNames;
	executeTree: aParseTree;
	read!

variablesReadBeforeWrittenIn: aParseTree 
    ^(self new)
	executeTree: aParseTree;
	read! !


Object subclass: #RBParseTreeRule
    instanceVariableNames: 'searchTree owner '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBParseTreeRule methodsFor: 'initialize-release'!

initialize!

methodSearchString: aString 
    searchTree := RBParser parseRewriteMethod: aString!

owner: aParseTreeSearcher
    owner := aParseTreeSearcher!

searchString: aString 
    searchTree := RBParser parseRewriteExpression: aString! !

!RBParseTreeRule methodsFor: 'matching'!

canMatch: aProgramNode 
    ^true!

foundMatchFor: aProgramNode
    ^aProgramNode!

performOn: aProgramNode 
    self context empty.
    ^((searchTree match: aProgramNode inContext: self context) 
	and: [self canMatch: aProgramNode]) 
	    ifTrue: 
		[owner recusivelySearchInContext.
		self foundMatchFor: aProgramNode]
	    ifFalse: [nil]! !

!RBParseTreeRule methodsFor: 'private'!

context
    ^owner context! !

RBParseTreeRule class
    instanceVariableNames: ''!



!RBParseTreeRule class methodsFor: 'instance creation'!

methodSearch: aString 
    ^(self new)
	methodSearchString: aString;
	yourself!

new
    ^(super new)
	initialize;
	yourself!

search: aString 
    ^(self new)
	searchString: aString;
	yourself! !


LookupTable variableSubclass: #RBSmallDictionary
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!


!RBSmallDictionary methodsFor: 'private'!

capacity
    ^super primSize!

whileGrowingAt: key put: value
    tally := tally + 1.
    self primAt: self size put: key.
    self valueAt: self size put: value!

incrementTally
    tally := tally + 1.
    ^tally > self primSize
	ifTrue: [ self grow ];
	yourself!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | element |
    self beConsistent.
    1 to: self size do: [ :i |
        element := self primAt: i.
        (element isNil or: [ element = anObject ])
            ifTrue: [ ^i ]
    ].
    tally = self primSize ifTrue: [ self grow ].
    ^self size + 1! !

RBSmallDictionary class
    instanceVariableNames: ''!

!RBSmallDictionary class methodsFor: 'instance creation'!

new
    ^self new: 2!

new: anInteger
    ^(self primNew: anInteger) initialize: anInteger! !


RBProgramNodeVisitor subclass: #ParseTreeSearcher
    instanceVariableNames: 'searches answer argumentSearches context '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

ParseTreeSearcher comment:
'ParseTreeSearcher walks over a normal source code parse tree using the visitor pattern, and then matches these nodes against the meta-nodes using the match:inContext: methods defined for the meta-nodes.

Instance Variables:
    answer    <Object>    the "answer" that is propagated between matches
    argumentSearches    <Collection of: (Association key: RBProgramNode value: BlockClosure)>    argument searches (search for the RBProgramNode and perform the BlockClosure when its found)
    context    <RBSmallDictionary>    a dictionary that contains what each meta-node matches against. This could be a normal Dictionary that is created for each search, but is created once and reused (efficiency).
    searches    <Collection of: (Association key: RBProgramNode value: BlockClosure)>    non-argument searches (search for the RBProgramNode and perform the BlockClosure when its found)'!


!ParseTreeSearcher methodsFor: 'accessing'!

addArgumentRule: aParseTreeRule 
    argumentSearches add: aParseTreeRule.
    aParseTreeRule owner: self!

addArgumentRules: ruleCollection 
    ruleCollection do: [:each | self addArgumentRule: each]!

addRule: aParseTreeRule 
    searches add: aParseTreeRule.
    aParseTreeRule owner: self!

addRules: ruleCollection 
    ruleCollection do: [:each | self addRule: each]!

answer
    ^answer!

context
    ^context!

executeMethod: aParseTree initialAnswer: anObject 
    answer := anObject.
    searches detect: [:each | (each performOn: aParseTree) notNil] ifNone: [].
    ^answer!

executeTree: aParseTree 
    "Save our current context, in case someone is performing another search inside a match."

    | oldContext |
    oldContext := context.
    context := RBSmallDictionary new.
    self visitNode: aParseTree.
    context := oldContext.
    ^answer!

executeTree: aParseTree initialAnswer: aValue 
    answer := aValue.
    ^self executeTree: aParseTree! !

!ParseTreeSearcher methodsFor: 'initialize-release'!

answer: anObject
    answer := anObject!

initialize
    super initialize.
    context := RBSmallDictionary new.
    searches := OrderedCollection new.
    argumentSearches := OrderedCollection new: 0.
    answer := nil! !

!ParseTreeSearcher methodsFor: 'searching'!

matches: aString do: aBlock 
    self addRule: (RBSearchRule searchFor: aString thenDo: aBlock)!

matchesAnyArgumentOf: stringCollection do: aBlock 
    stringCollection do: [:each | self matchesArgument: each do: aBlock]!

matchesAnyMethodOf: aStringCollection do: aBlock 
    aStringCollection do: [:each | self matchesMethod: each do: aBlock]!

matchesAnyOf: aStringCollection do: aBlock 
    aStringCollection do: [:each | self matches: each do: aBlock]!

matchesAnyTreeOf: treeCollection do: aBlock 
    treeCollection do: [:each | self matchesTree: each do: aBlock]!

matchesArgument: aString do: aBlock 
    self addArgumentRule: (RBSearchRule searchFor: aString thenDo: aBlock)!

matchesArgumentTree: aRBProgramNode do: aBlock 
    self 
	addArgumentRule: (RBSearchRule searchForTree: aRBProgramNode thenDo: aBlock)!

matchesMethod: aString do: aBlock 
    self addRule: (RBSearchRule searchForMethod: aString thenDo: aBlock)!

matchesTree: aRBProgramNode do: aBlock 
    self addRule: (RBSearchRule searchForTree: aRBProgramNode thenDo: aBlock)! !

!ParseTreeSearcher methodsFor: 'private'!

foundMatch!

lookForMoreMatchesInContext: oldContext 
    oldContext keysAndValuesDo: 
	    [:key :value | 
	    (key isString not and: [key recurseInto]) 
		ifTrue: [value do: [:each | self visitNode: each]]]!

performSearches: aSearchCollection on: aNode 
    | value |
    1 to: aSearchCollection size
	do: 
	    [:i | 
	    value := (aSearchCollection at: i) performOn: aNode.
	    value notNil 
		ifTrue: 
		    [self foundMatch.
		    ^value]].
    ^nil!

recusivelySearchInContext
    "We need to save the matched context since the other searches might overwrite it."

    | oldContext |
    oldContext := context.
    context := RBSmallDictionary new.
    self lookForMoreMatchesInContext: oldContext.
    context := oldContext! !

!ParseTreeSearcher methodsFor: 'visiting'!

visitArgument: aNode 
    | value |
    value := self performSearches: argumentSearches on: aNode.
    ^value isNil 
	ifTrue: 
	    [aNode acceptVisitor: self.
	    aNode]
	ifFalse: [value]!

visitNode: aNode 
    | value |
    value := self performSearches: searches on: aNode.
    ^value isNil 
	ifTrue: 
	    [aNode acceptVisitor: self.
	    aNode]
	ifFalse: [value]! !

!ParseTreeSearcher methodsFor: 'obsolete'!

addArgumentSearch: aSearchCondition 
    self addArgumentRule: (self buildParseTreeRuleFor: aSearchCondition)!

addArgumentSearches: aSearchCondition 
    aSearchCondition key do: [:each | self addArgumentSearch: each -> aSearchCondition value]!

addMethodSearch: aSearchCondition 
    self addRule: (self buildMethodParseTreeRuleFor: aSearchCondition)!

addMethodSearches: aSearchCondition 
    aSearchCondition key do: [:each | self addMethodSearch: each -> aSearchCondition value]!

addSearch: aSearchCondition 
    self addRule: (self buildParseTreeRuleFor: aSearchCondition)!

addSearches: aSearchCondition 
    aSearchCondition key do: [:each | self addSearch: each -> aSearchCondition value]!

buildMethodParseTreeRuleFor: aSearchCondition 
    ^(aSearchCondition key isKindOf: RBProgramNode) 
	ifTrue: 
	    [RBSearchRule searchForTree: aSearchCondition key
		thenDo: aSearchCondition value]
	ifFalse: 
	    [RBSearchRule searchForMethod: aSearchCondition key
		thenDo: aSearchCondition value]!

buildParseTreeRuleFor: aSearchCondition 
    ^(aSearchCondition key isKindOf: RBProgramNode) 
	ifTrue: 
	    [RBSearchRule searchForTree: aSearchCondition key
		thenDo: aSearchCondition value]
	ifFalse: 
	    [RBSearchRule searchFor: aSearchCondition key thenDo: aSearchCondition value]! !

ParseTreeSearcher class
    instanceVariableNames: ''!



!ParseTreeSearcher class methodsFor: 'accessing'!

treeMatching: aString in: aParseTree 
    (self new)
	matches: aString do: [:aNode :answer | ^aNode];
	executeTree: aParseTree.
    ^nil!

treeMatchingStatements: aString in: aParseTree 
    | notifier tree lastIsReturn |
    notifier := self new.
    tree := RBParser parseExpression: aString.
    lastIsReturn := tree lastIsReturn.
    notifier matches: (lastIsReturn 
		ifTrue: ['| `@temps | `@.S1. ' , tree formattedCode]
		ifFalse: ['| `@temps | `@.S1. ' , tree formattedCode , '. `@.S2'])
	do: [:aNode :answer | ^tree].
    notifier executeTree: aParseTree.
    ^nil! !

!ParseTreeSearcher class methodsFor: 'instance creation'!

getterMethod: aVarName 
    ^(self new)
	matchesMethod: '`method ^' , aVarName do: [:aNode :ans | aNode selector];
	yourself!

justSendsSuper
    ^(self new)
	matchesAnyMethodOf: 
		#('`@method: `@Args ^super `@method: `@Args' 
		'`@method: `@Args super `@method: `@Args')
	    do: [:aNode :ans | true];
	yourself!

returnSetterMethod: aVarName 
    ^(self new)
	matchesMethod: '`method: `Arg ^' , aVarName , ' := `Arg'
	    do: [:aNode :ans | aNode selector];
	yourself!

setterMethod: aVarName 
    ^(self new)
	matchesAnyMethodOf: (Array with: '`method: `Arg ' , aVarName , ' := `Arg'
		    with: '`method: `Arg ^' , aVarName , ' := `Arg')
	    do: [:aNode :ans | aNode selector];
	yourself! !

!ParseTreeSearcher class methodsFor: 'private'!

buildSelectorString: aSelector 
    | stream keywords |
    aSelector numArgs = 0 ifTrue: [^aSelector].
    stream := WriteStream on: String new.
    keywords := aSelector keywords.
    1 to: keywords size
	do: 
	    [:i | 
	    stream nextPutAll: (keywords at: i);
		nextPutAll: ' ``@arg';
		nextPutAll: i printString;
		nextPut: $ ].
    ^stream contents!

buildSelectorTree: aSelector 
    ^RBParser parseRewriteExpression: '``@receiver ' 
		, (self buildSelectorString: aSelector)
	onError: [:err :pos | ^nil]!

buildTree: aString method: aBoolean 
    ^aBoolean
	ifTrue: [RBParser parseRewriteMethod: aString]
	ifFalse: [RBParser parseRewriteExpression: aString]! !


RBParseTreeRule subclass: #RBSearchRule
    instanceVariableNames: 'answerBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBSearchRule methodsFor: 'initialize-release'!

searchFor: aString thenDo: aBlock 
    self searchString: aString.
    answerBlock := aBlock!

searchForMethod: aString thenDo: aBlock 
    self methodSearchString: aString.
    answerBlock := aBlock!

searchForTree: aRBProgramNode thenDo: aBlock 
    searchTree := aRBProgramNode.
    answerBlock := aBlock! !

!RBSearchRule methodsFor: 'testing'!

canMatch: aProgramNode 
    owner answer: (answerBlock value: aProgramNode value: owner answer).
    ^true! !

RBSearchRule class
    instanceVariableNames: ''!



!RBSearchRule class methodsFor: 'instance creation'!

searchFor: aString thenDo: aBlock 
    ^self new searchFor: aString thenDo: aBlock!

searchForMethod: aString thenDo: aBlock 
    ^self new searchForMethod: aString thenDo: aBlock!

searchForTree: aRBProgramNode thenDo: aBlock 
    ^self new searchForTree: aRBProgramNode thenDo: aBlock! !


RBParseTreeRule subclass: #RBReplaceRule
    instanceVariableNames: 'verificationBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBReplaceRule methodsFor: 'initialize-release'!

initialize
    super initialize.
    verificationBlock := [:aNode | true]! !

!RBReplaceRule methodsFor: 'matching'!

canMatch: aProgramNode 
    ^verificationBlock value: aProgramNode!

foundMatchFor: aProgramNode 
    self subclassResponsibility! !

RBReplaceRule class
    instanceVariableNames: ''!



ParseTreeSearcher subclass: #ParseTreeRewriter
    instanceVariableNames: 'tree '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

ParseTreeRewriter comment:
'ParseTreeRewriter walks over and transforms its RBProgramNode (tree). If the tree is modified, then answer is set to true, and the modified tree can be retrieved by the #tree method.

Instance Variables:
    tree    <RBProgramNode>    the parse tree we''re transforming'!


!ParseTreeRewriter methodsFor: 'accessing'!

executeTree: aParseTree 
    | oldContext |
    oldContext := context.
    context := RBSmallDictionary new.
    answer := false.
    tree := self visitNode: aParseTree.
    context := oldContext.
    ^answer!

tree
    ^tree! !

!ParseTreeRewriter methodsFor: 'replacing'!

replace: searchString with: replaceString 
    self addRule: (RBStringReplaceRule searchFor: searchString
		replaceWith: replaceString)!

replace: searchString with: replaceString when: aBlock 
    self addRule: (RBStringReplaceRule 
		searchFor: searchString
		replaceWith: replaceString
		when: aBlock)!

replace: searchString withValueFrom: replaceBlock 
    self addRule: (RBBlockReplaceRule searchFor: searchString
		replaceWith: replaceBlock)!

replace: searchString withValueFrom: replaceBlock when: conditionBlock 
    self addRule: (RBBlockReplaceRule 
		searchFor: searchString
		replaceWith: replaceBlock
		when: conditionBlock)!

replaceArgument: searchString with: replaceString 
    self addArgumentRule: (RBStringReplaceRule searchFor: searchString
		replaceWith: replaceString)!

replaceArgument: searchString with: replaceString when: aBlock 
    self addArgumentRule: (RBStringReplaceRule 
		searchFor: searchString
		replaceWith: replaceString
		when: aBlock)!

replaceArgument: searchString withValueFrom: replaceBlock 
    self addArgumentRule: (RBBlockReplaceRule searchFor: searchString
		replaceWith: replaceBlock)!

replaceArgument: searchString withValueFrom: replaceBlock when: conditionBlock 
    self addArgumentRule: (RBBlockReplaceRule 
		searchFor: searchString
		replaceWith: replaceBlock
		when: conditionBlock)!

replaceMethod: searchString with: replaceString 
    self addRule: (RBStringReplaceRule searchForMethod: searchString
		replaceWith: replaceString)!

replaceMethod: searchString with: replaceString when: aBlock 
    self addRule: (RBStringReplaceRule 
		searchForMethod: searchString
		replaceWith: replaceString
		when: aBlock)!

replaceMethod: searchString withValueFrom: replaceBlock 
    self addRule: (RBBlockReplaceRule searchForMethod: searchString
		replaceWith: replaceBlock)!

replaceMethod: searchString withValueFrom: replaceBlock when: conditionBlock 
    self addRule: (RBBlockReplaceRule 
		searchForMethod: searchString
		replaceWith: replaceBlock
		when: conditionBlock)!

replaceTree: searchTree withTree: replaceTree 
    self addRule: (RBStringReplaceRule searchForTree: searchTree
		replaceWith: replaceTree)!

replaceTree: searchTree withTree: replaceTree when: aBlock 
    self addRule: (RBStringReplaceRule 
		searchForTree: searchTree
		replaceWith: replaceTree
		when: aBlock)! !

!ParseTreeRewriter methodsFor: 'private'!

foundMatch
    answer := true!

lookForMoreMatchesInContext: oldContext 
    oldContext keysAndValuesDo: [:key :value || newValue |
	(key isString not and: [key recurseInto]) ifTrue: [
	    "Of course, the following statement does nothing without the `deepCopy'
	     which fixes the bug."
	    newValue := oldContext at: key put: value deepCopy "<<<".
	    self visitNodes: newValue
	         onMatch: [:newValue |
		     oldContext at: key put: newValue]]]! !

!ParseTreeRewriter methodsFor: 'visiting'!

visitNode: aNode
    ^self visitNode: aNode searches: searches onMatch: [:newNode |]!

visitNode: aNode onMatch: aBlock
    ^self visitNode: aNode searches: searches onMatch: aBlock!

visitNodes: aNodeList
    ^self visitNodes: aNodeList onMatch: [:newNodes |]!

visitNodes: aNodeList onMatch: aBlock
    ^self visitNodes: aNodeList searches: searches onMatch: aBlock!

visitArgument: aNode
    ^self visitNode: aNode searches: argumentSearches onMatch: [:newNode |]!

visitArguments: aNodeList
    ^self visitArguments: aNodeList onMatch: [:newNodes |]!

visitArguments: aNodeList onMatch: aBlock
    ^self visitNodes: aNodeList searches: argumentSearches onMatch: aBlock!

visitNode: aNode searches: theseSearches onMatch: aBlock
    "Visit aNode, sending visitNode:'s answer to aBlock if
     performSearches:on: finds a match."
    | newNode |
    newNode := self performSearches: theseSearches on: aNode.
    ^newNode isNil ifTrue: [aNode acceptVisitor: self.  aNode]
		   ifFalse: [aBlock value: newNode.  newNode]!

visitNodes: aNodeList searches: theseSearches onMatch: aBlock
    "Answer aNodeList but with each element replaced by the result of
     visitNode:onMatch: with said element (and a block of my own).  If
     any matches occur, I'll call aBlock afterwards with the
     replacement of aNodeList before answering it."
    | replacementList rlHasMatch |
    rlHasMatch := false.
    replacementList := aNodeList collect: [:eltNode |
	self visitNode: eltNode
	     searches: theseSearches
	     onMatch: [:newElt | rlHasMatch := true]].
    ^rlHasMatch
	ifTrue: [aBlock value: replacementList.  replacementList]
	ifFalse: [aNodeList]! !

!ParseTreeRewriter methodsFor: 'visitor-double dispatching'!

acceptAssignmentNode: anAssignmentNode 
    self visitNode: anAssignmentNode variable
	 onMatch: [:newField | anAssignmentNode variable: newField].
    self visitNode: anAssignmentNode value
	 onMatch: [:newField | anAssignmentNode value: newField]!

acceptArrayConstructorNode: anArrayNode 
    self visitNode: anArrayNode body
	 onMatch: [:newField | anArrayNode body: newField]!

acceptBlockNode: aBlockNode 
    self visitArguments: aBlockNode arguments
	 onMatch: [:newField | aBlockNode arguments: newField].
    self visitNode: aBlockNode body
	 onMatch: [:newField | aBlockNode body: newField]!

searchCascadeNodeMessage: aMessageNode messagesTo: newMessages
    "Helper for acceptCascadeNode: -- descend to aMessageNode, but no
     further.  Add the resulting message or cascade of messages from
     the tree rule's foundMatchFor: to newMessages and answer said
     result if a match is found.  Add aMessageNode to newMessages and
     answer nil otherwise."
    | answer newNode |
    answer := self performSearches: searches on: aMessageNode.
    newNode := answer ifNil: [aMessageNode].
    newNode isCascade
	ifTrue: [newMessages addAll: newNode messages]
	ifFalse: [newMessages add:
		      (newNode isMessage ifTrue: [newNode]
					 ifFalse: [Warning signal: 'Cannot replace message node inside of cascaded node with non-message node'.
					           answer := nil. "<<<"
						   aMessageNode])].
    ^answer!

acceptCascadeNode: aCascadeNode 
    | newMessages notFound |
    newMessages := OrderedCollection new: aCascadeNode messages size.
    notFound := OrderedCollection new: aCascadeNode messages size.
    aCascadeNode messages do: [:each | 
	(self searchCascadeNodeMessage: each
	      messagesTo: newMessages)
	    isNil ifTrue: [notFound add: each]].

    "Rewrite the receiver once and distribute it among the messages if
     no replacements were made."
    notFound size == aCascadeNode messages size 
	ifTrue: 
	    [self visitNode: aCascadeNode messages first receiver
		  onMatch: [:receiver |
		      newMessages do: [:each | each receiver: receiver]]].
    notFound 
	do: [:each | self visitNodes: each arguments
			  onMatch: [:newArgs | each arguments: newArgs]].
    aCascadeNode messages: newMessages!

acceptMessageNode: aMessageNode 
    self visitNode: aMessageNode receiver
	 onMatch: [:newField | aMessageNode receiver: newField].
    self visitNodes: aMessageNode arguments
	 onMatch: [:newField | aMessageNode arguments: newField]!

acceptMethodNode: aMethodNode 
    self visitArguments: aMethodNode arguments
	 onMatch: [:newField | aMethodNode arguments: newField].
    self visitNode: aMethodNode body
	 onMatch: [:newField | aMethodNode body: newField]!

acceptOptimizedNode: anOptimizedNode 
    self visitNode: anOptimizedNode body
	 onMatch: [:newField | anOptimizedNode body: newField]!

acceptReturnNode: aReturnNode 
    self visitNode: aReturnNode value
	 onMatch: [:newField | aReturnNode value: newField]!

acceptSequenceNode: aSequenceNode 
    self visitArguments: aSequenceNode temporaries
	 onMatch: [:newField | aSequenceNode temporaries: newField].
    self visitNodes: aSequenceNode statements
	 onMatch: [:newField | aSequenceNode statements: newField]! !

ParseTreeRewriter class
    instanceVariableNames: ''!



!ParseTreeRewriter class methodsFor: 'accessing'!

replace: code with: newCode in: aParseTree 
    ^(self 
	replace: code
	with: newCode
	method: false)
	executeTree: aParseTree;
	tree!

replace: code with: newCode in: aParseTree onInterval: anInterval 
    | rewriteRule |
    rewriteRule := self new.
    ^rewriteRule
	replace: code
	    with: newCode
	    when: [:aNode | aNode intersectsInterval: anInterval];
	executeTree: aParseTree;
	tree!

replaceStatements: code with: newCode in: aParseTree onInterval: anInterval 
    | tree searchStmt replaceStmt |
    tree := self buildTree: code method: false.
    tree lastIsReturn
	ifTrue: 
	    [searchStmt := '| `@temps | `@.Statements. ' , code.
	    replaceStmt := '| `@temps | `@.Statements. ^' , newCode]
	ifFalse: 
	    [searchStmt := '| `@temps | `@.Statements1. ' , code , '.  `@.Statements2'.
	    replaceStmt := '| `@temps | `@.Statements1. ' , newCode , '.  `@.Statements2'].
    ^self
	replace: searchStmt
	with: replaceStmt
	in: aParseTree
	onInterval: anInterval! !

!ParseTreeRewriter class methodsFor: 'instance creation'!

classVariable: aVarName getter: getMethod setter: setMethod 
    | rewriteRule |
    rewriteRule := self new.
    rewriteRule
	replace: aVarName , ' := ``@object'
	    with: 'self class ' , setMethod , ' ``@object';
	replace: aVarName with: 'self class ' , getMethod.
    ^rewriteRule!

removeTemporaryNamed: aName 
    | rewriteRule |
    rewriteRule := self new.
    rewriteRule replace: '| `@temps1 ' , aName , ' `@temps2 | ``@.Statements'
	with: '| `@temps1  `@temps2 | ``@.Statements'.
    ^rewriteRule!

rename: varName to: newVarName 
    | rewriteRule |
    rewriteRule := self new.
    rewriteRule
	replace: varName with: newVarName;
	replaceArgument: varName with: newVarName.
    ^rewriteRule!

rename: varName to: newVarName handler: aBlock 
    "Rename varName to newVarName, evaluating aBlock if there is a 
    temporary variable with the same name as newVarName. This 
    does not change temporary variables with varName."

    | rewriteRule |
    rewriteRule := self new.
    rewriteRule
	replace: varName with: newVarName;
	replaceArgument: newVarName
	    withValueFrom: 
		[:aNode | 
		aBlock value.
		aNode].
    ^rewriteRule!

replace: code with: newCode method: aBoolean 
    | rewriteRule |
    rewriteRule := self new.
    aBoolean 
	ifTrue: [rewriteRule replaceMethod: code with: newCode]
	ifFalse: [rewriteRule replace: code with: newCode].
    ^rewriteRule!

replaceLiteral: literal with: newLiteral 
    | rewriteRule |
    rewriteRule := self new.
    rewriteRule 
	replace: '`#literal'
	withValueFrom: [:aNode | aNode]
	when: 
	    [:aNode | 
	    self 
		replaceLiteral: literal
		with: newLiteral
		inToken: aNode token].
    ^rewriteRule!

variable: aVarName getter: getMethod setter: setMethod 
    | rewriteRule |
    rewriteRule := self new.
    rewriteRule
	replace: aVarName , ' := ``@object'
	    with: 'self ' , setMethod , ' ``@object';
	replace: aVarName with: 'self ' , getMethod.
    ^rewriteRule! !

!ParseTreeRewriter class methodsFor: 'private'!

replaceLiteral: literal with: newLiteral inToken: literalToken 
    | value |
    value := literalToken realValue.
    value == literal ifTrue: 
	    [literalToken value: newLiteral
		start: nil
		stop: nil.
	    ^true].
    ^value class == Array and: 
	    [literalToken value inject: false
		into: 
		    [:bool :each | 
		    bool | (self replaceLiteral: literal
				with: newLiteral
				inToken: each)]]! !


RBReplaceRule subclass: #RBStringReplaceRule
    instanceVariableNames: 'replaceTree '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBStringReplaceRule methodsFor: 'initialize-release'!

methodReplaceString: replaceString 
    replaceTree := RBParser parseRewriteMethod: replaceString!

replaceString: replaceString 
    replaceTree := RBParser parseRewriteExpression: replaceString.
    searchTree isSequence = replaceTree isSequence 
	ifFalse: 
	    [searchTree isSequence 
		ifTrue: [replaceTree := RBSequenceNode statements: (Array with: replaceTree)]
		ifFalse: [searchTree := RBSequenceNode statements: (Array with: searchTree)]]!

searchFor: searchString replaceWith: replaceString 
    self searchString: searchString.
    self replaceString: replaceString!

searchFor: searchString replaceWith: replaceString when: aBlock 
    self searchFor: searchString replaceWith: replaceString.
    verificationBlock := aBlock!

searchForMethod: searchString replaceWith: replaceString 
    self methodSearchString: searchString.
    self methodReplaceString: replaceString!

searchForMethod: searchString replaceWith: replaceString when: aBlock 
    self searchForMethod: searchString replaceWith: replaceString.
    verificationBlock := aBlock!

searchForTree: aRBProgramNode replaceWith: replaceNode 
    searchTree := aRBProgramNode.
    replaceTree := replaceNode!

searchForTree: aRBProgramNode replaceWith: replaceString when: aBlock 
    self searchForTree: aRBProgramNode replaceWith: replaceString.
    verificationBlock := aBlock! !

!RBStringReplaceRule methodsFor: 'matching'!

foundMatchFor: aProgramNode 
    | newTree |
    newTree := replaceTree copyInContext: self context.
    newTree copyCommentsFrom: aProgramNode.
    ^newTree! !

RBStringReplaceRule class
    instanceVariableNames: ''!



!RBStringReplaceRule class methodsFor: 'instance creation'!

searchFor: searchString replaceWith: replaceString 
    ^self new searchFor: searchString replaceWith: replaceString!

searchFor: searchString replaceWith: replaceString when: aBlock 
    ^self new 
	searchFor: searchString
	replaceWith: replaceString
	when: aBlock!

searchForMethod: searchString replaceWith: replaceString
    ^self new searchForMethod: searchString replaceWith: replaceString!

searchForMethod: searchString replaceWith: replaceString when: aBlock 
    ^self new 
	searchForMethod: searchString
	replaceWith: replaceString
	when: aBlock!

searchForTree: searchString replaceWith: replaceString 
    ^self new searchForTree: searchString replaceWith: replaceString!

searchForTree: searchString replaceWith: replaceString when: aBlock 
    ^self new 
	searchForTree: searchString
	replaceWith: replaceString
	when: aBlock! !


RBReplaceRule subclass: #RBBlockReplaceRule
    instanceVariableNames: 'replaceBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBBlockReplaceRule methodsFor: 'initialize-release'!

initialize
    super initialize.
    replaceBlock := [:aNode | aNode]!

searchFor: searchString replaceWith: aBlock 
    self searchString: searchString.
    replaceBlock := aBlock!

searchFor: searchString replaceWith: replBlock when: verifyBlock 
    self searchFor: searchString replaceWith: replBlock.
    verificationBlock := verifyBlock!

searchForMethod: searchString replaceWith: aBlock 
    self methodSearchString: searchString.
    replaceBlock := aBlock!

searchForMethod: searchString replaceWith: replBlock when: verifyBlock 
    self searchForMethod: searchString replaceWith: replBlock.
    verificationBlock := verifyBlock!

searchForTree: aRBProgramNode replaceWith: aBlock 
    searchTree := aRBProgramNode.
    replaceBlock := aBlock!

searchForTree: aRBProgramNode replaceWith: replBlock when: verifyBlock 
    self searchForTree: aRBProgramNode replaceWith: replBlock.
    verificationBlock := verifyBlock! !

!RBBlockReplaceRule methodsFor: 'matching'!

foundMatchFor: aProgramNode 
    ^replaceBlock value: aProgramNode! !

RBBlockReplaceRule class
    instanceVariableNames: ''!



!RBBlockReplaceRule class methodsFor: 'instance creation'!

searchFor: searchString replaceWith: replaceBlock 
    ^self new searchFor: searchString replaceWith: replaceBlock!

searchFor: searchString replaceWith: replaceBlock when: aBlock 
    ^self new 
	searchFor: searchString
	replaceWith: replaceBlock
	when: aBlock!

searchForMethod: searchString replaceWith: replaceBlock 
    ^self new searchForMethod: searchString replaceWith: replaceBlock!

searchForMethod: searchString replaceWith: replaceBlock when: aBlock 
    ^self new 
	searchForMethod: searchString
	replaceWith: replaceBlock
	when: aBlock!

searchForTree: searchString replaceWith: replaceBlock 
    ^self new searchForTree: searchString replaceWith: replaceBlock!

searchForTree: searchString replaceWith: replaceBlock when: aBlock 
    ^self new 
	searchFor: searchString
	replaceWith: replaceBlock
	when: aBlock! !

