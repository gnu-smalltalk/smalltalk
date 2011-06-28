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



Object subclass: RBReadBeforeWrittenTester [
    | read checkNewTemps scopeStack searcher |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBReadBeforeWrittenTester class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    RBReadBeforeWrittenTester class >> isVariable: aString readBeforeWrittenIn: aBRProgramNode [
	<category: 'accessing'>
	^(self isVariable: aString writtenBeforeReadIn: aBRProgramNode) not
    ]

    RBReadBeforeWrittenTester class >> isVariable: aString writtenBeforeReadIn: aBRProgramNode [
	<category: 'accessing'>
	^(self readBeforeWritten: (Array with: aString) in: aBRProgramNode) 
	    isEmpty
    ]

    RBReadBeforeWrittenTester class >> readBeforeWritten: varNames in: aParseTree [
	<category: 'accessing'>
	^(self new)
	    checkNewTemps: false;
	    initializeVars: varNames;
	    executeTree: aParseTree;
	    read
    ]

    RBReadBeforeWrittenTester class >> variablesReadBeforeWrittenIn: aParseTree [
	<category: 'accessing'>
	^(self new)
	    executeTree: aParseTree;
	    read
    ]

    checkNewTemps: aBoolean [
	<category: 'initialize-release'>
	checkNewTemps := aBoolean
    ]

    createSearchTrees [
	<category: 'initialize-release'>
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
	    matchesAnyOf: #('[| `@temps | ``@.Statements] whileTrue: ``@block' '[| `@temps | ``@.Statements] whileTrue' '[| `@temps | ``@.Statements] whileFalse: ``@block' '[| `@temps | ``@.Statements] whileFalse')
		do: [:aNode :ans | ans];
	    matchesAnyOf: #('`@condition ifTrue: [| `@tTemps | `@.trueBlock] ifFalse: [| `@fTemps| `@.falseBlock]' '`@condition ifFalse: [| `@fTemps | `@.falseBlock] ifTrue: [| `@tTemps | `@.trueBlock]')
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
		ans]
    ]

    initialize [
	<category: 'initialize-release'>
	scopeStack := OrderedCollection with: Dictionary new.
	read := Set new.
	checkNewTemps := true.
	self createSearchTrees
    ]

    initializeVars: varNames [
	<category: 'initialize-release'>
	varNames do: [:each | self currentScope at: each put: nil]
    ]

    executeTree: aParseTree [
	<category: 'accessing'>
	^searcher executeTree: aParseTree
    ]

    read [
	<category: 'accessing'>
	self currentScope 
	    keysAndValuesDo: [:key :value | value == true ifTrue: [read add: key]].
	^read
    ]

    copyDictionary: aDictionary [
	"We could send aDictionary the copy message, but that doesn't copy the associations."

	<category: 'private'>
	| newDictionary |
	newDictionary := Dictionary new: aDictionary size.
	aDictionary 
	    keysAndValuesDo: [:key :value | newDictionary at: key put: value].
	^newDictionary
    ]

    createScope [
	<category: 'private'>
	scopeStack add: (self copyDictionary: scopeStack last)
    ]

    currentScope [
	<category: 'private'>
	^scopeStack last
    ]

    processBlock: aNode [
	<category: 'private'>
	| newScope |
	self createScope.
	self executeTree: aNode body.
	newScope := self removeScope.
	newScope keysAndValuesDo: 
		[:key :value | 
		(value == true and: [(self currentScope at: key) isNil]) 
		    ifTrue: [self currentScope at: key put: value]]
    ]

    processIfTrueIfFalse: aNode [
	<category: 'private'>
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
				    ifTrue: [self currentScope at: key put: true]]]]
    ]

    processStatementNode: aNode [
	<category: 'private'>
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
			    ifTrue: [self currentScope at: key put: value]]]
    ]

    removeScope [
	<category: 'private'>
	^scopeStack removeLast
    ]

    variableRead: aNode [
	<category: 'private'>
	(self currentScope includesKey: aNode name) 
	    ifTrue: 
		[(self currentScope at: aNode name) isNil 
		    ifTrue: [self currentScope at: aNode name put: true]]
    ]

    variableWritten: aNode [
	<category: 'private'>
	(self currentScope includesKey: aNode variable name) 
	    ifTrue: 
		[(self currentScope at: aNode variable name) isNil 
		    ifTrue: [self currentScope at: aNode variable name put: false]]
    ]
]



Object subclass: RBParseTreeRule [
    | searchTree owner |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBParseTreeRule class >> methodSearch: aString [
	<category: 'instance creation'>
	^(self new)
	    methodSearchString: aString;
	    yourself
    ]

    RBParseTreeRule class >> new [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    yourself
    ]

    RBParseTreeRule class >> search: aString [
	<category: 'instance creation'>
	^(self new)
	    searchString: aString;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    methodSearchString: aString [
	<category: 'initialize-release'>
	searchTree := RBParser parseRewriteMethod: aString
    ]

    owner: aParseTreeSearcher [
	<category: 'initialize-release'>
	owner := aParseTreeSearcher
    ]

    searchString: aString [
	<category: 'initialize-release'>
	searchTree := RBParser parseRewriteExpression: aString
    ]

    canMatch: aProgramNode [
	<category: 'matching'>
	^true
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	^aProgramNode
    ]

    performOn: aProgramNode [
	<category: 'matching'>
	self context empty.
	^((searchTree match: aProgramNode inContext: self context) 
	    and: [self canMatch: aProgramNode]) 
		ifTrue: 
		    [owner recusivelySearchInContext.
		    self foundMatchFor: aProgramNode]
		ifFalse: [nil]
    ]

    context [
	<category: 'private'>
	^owner context
    ]
]



LookupTable subclass: RBSmallDictionary [
    
    <shape: #pointer>
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBSmallDictionary class >> new [
	<category: 'instance creation'>
	^self new: 2
    ]

    RBSmallDictionary class >> new: anInteger [
	<category: 'instance creation'>
	^(self primNew: anInteger) initialize: anInteger
    ]

    capacity [
	<category: 'private'>
	^super primSize
    ]

    whileGrowingAt: key put: value [
	<category: 'private'>
	tally := tally + 1.
	self primAt: self size put: key.
	self valueAt: self size put: value
    ]

    incrementTally [
	<category: 'private'>
	tally := tally + 1.
	^(tally > self primSize)
	    ifTrue: [self grow];
	    yourself
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private'>
	| element |
	1 to: self size
	    do: 
		[:i | 
		element := self primAt: i.
		(element isNil or: [element = anObject]) ifTrue: [^i]].
	tally = self primSize ifTrue: [self grow].
	^self size + 1
    ]
]



RBProgramNodeVisitor subclass: ParseTreeSearcher [
    | searches answer argumentSearches context |
    
    <comment: 'ParseTreeSearcher walks over a normal source code parse tree using the visitor pattern, and then matches these nodes against the meta-nodes using the match:inContext: methods defined for the meta-nodes.

Instance Variables:
    answer    <Object>    the "answer" that is propagated between matches
    argumentSearches    <Collection of: (Association key: RBProgramNode value: BlockClosure)>    argument searches (search for the RBProgramNode and perform the BlockClosure when its found)
    context    <RBSmallDictionary>    a dictionary that contains what each meta-node matches against. This could be a normal Dictionary that is created for each search, but is created once and reused (efficiency).
    searches    <Collection of: (Association key: RBProgramNode value: BlockClosure)>    non-argument searches (search for the RBProgramNode and perform the BlockClosure when its found)'>
    <category: 'Refactory-Parser'>

    ParseTreeSearcher class >> treeMatching: aString in: aParseTree [
	<category: 'accessing'>
	(self new)
	    matches: aString do: [:aNode :answer | ^aNode];
	    executeTree: aParseTree.
	^nil
    ]

    ParseTreeSearcher class >> treeMatchingStatements: aString in: aParseTree [
	<category: 'accessing'>
	| notifier tree lastIsReturn |
	notifier := self new.
	tree := RBParser parseExpression: aString.
	lastIsReturn := tree lastIsReturn.
	notifier matches: (lastIsReturn 
		    ifTrue: ['| `@temps | `@.S1. ' , tree formattedCode]
		    ifFalse: ['| `@temps | `@.S1. ' , tree formattedCode , '. `@.S2'])
	    do: [:aNode :answer | ^tree].
	notifier executeTree: aParseTree.
	^nil
    ]

    ParseTreeSearcher class >> getterMethod: aVarName [
	<category: 'instance creation'>
	^(self new)
	    matchesMethod: '`method ^' , aVarName do: [:aNode :ans | aNode selector];
	    yourself
    ]

    ParseTreeSearcher class >> justSendsSuper [
	<category: 'instance creation'>
	^(self new)
	    matchesAnyMethodOf: #('`@method: `@Args ^super `@method: `@Args' '`@method: `@Args super `@method: `@Args')
		do: [:aNode :ans | true];
	    yourself
    ]

    ParseTreeSearcher class >> returnSetterMethod: aVarName [
	<category: 'instance creation'>
	^(self new)
	    matchesMethod: '`method: `Arg ^' , aVarName , ' := `Arg'
		do: [:aNode :ans | aNode selector];
	    yourself
    ]

    ParseTreeSearcher class >> setterMethod: aVarName [
	<category: 'instance creation'>
	^(self new)
	    matchesAnyMethodOf: (Array with: '`method: `Arg ' , aVarName , ' := `Arg'
			with: '`method: `Arg ^' , aVarName , ' := `Arg')
		do: [:aNode :ans | aNode selector];
	    yourself
    ]

    ParseTreeSearcher class >> buildSelectorString: aSelector [
	<category: 'private'>
	| stream keywords |
	aSelector numArgs = 0 ifTrue: [^aSelector].
	stream := WriteStream on: String new.
	keywords := aSelector keywords.
	1 to: keywords size
	    do: 
		[:i | 
		stream
		    nextPutAll: (keywords at: i);
		    nextPutAll: ' ``@arg';
		    nextPutAll: i printString;
		    nextPut: $ ].
	^stream contents
    ]

    ParseTreeSearcher class >> buildSelectorTree: aSelector [
	<category: 'private'>
	^RBParser parseRewriteExpression: '``@receiver ' 
		    , (self buildSelectorString: aSelector)
	    onError: [:err :pos | ^nil]
    ]

    ParseTreeSearcher class >> buildTree: aString method: aBoolean [
	<category: 'private'>
	^aBoolean 
	    ifTrue: [RBParser parseRewriteMethod: aString]
	    ifFalse: [RBParser parseRewriteExpression: aString]
    ]

    addArgumentRule: aParseTreeRule [
	<category: 'accessing'>
	argumentSearches add: aParseTreeRule.
	aParseTreeRule owner: self
    ]

    addArgumentRules: ruleCollection [
	<category: 'accessing'>
	ruleCollection do: [:each | self addArgumentRule: each]
    ]

    addRule: aParseTreeRule [
	<category: 'accessing'>
	searches add: aParseTreeRule.
	aParseTreeRule owner: self
    ]

    addRules: ruleCollection [
	<category: 'accessing'>
	ruleCollection do: [:each | self addRule: each]
    ]

    answer [
	<category: 'accessing'>
	^answer
    ]

    context [
	<category: 'accessing'>
	^context
    ]

    executeMethod: aParseTree initialAnswer: anObject [
	<category: 'accessing'>
	answer := anObject.
	searches detect: [:each | (each performOn: aParseTree) notNil] ifNone: [].
	^answer
    ]

    executeTree: aParseTree [
	"Save our current context, in case someone is performing another search inside a match."

	<category: 'accessing'>
	| oldContext |
	oldContext := context.
	context := RBSmallDictionary new.
	self visitNode: aParseTree.
	context := oldContext.
	^answer
    ]

    executeTree: aParseTree initialAnswer: aValue [
	<category: 'accessing'>
	answer := aValue.
	^self executeTree: aParseTree
    ]

    answer: anObject [
	<category: 'initialize-release'>
	answer := anObject
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	context := RBSmallDictionary new.
	searches := OrderedCollection new.
	argumentSearches := OrderedCollection new: 0.
	answer := nil
    ]

    matches: aString do: aBlock [
	<category: 'searching'>
	self addRule: (RBSearchRule searchFor: aString thenDo: aBlock)
    ]

    matchesAnyArgumentOf: stringCollection do: aBlock [
	<category: 'searching'>
	stringCollection do: [:each | self matchesArgument: each do: aBlock]
    ]

    matchesAnyMethodOf: aStringCollection do: aBlock [
	<category: 'searching'>
	aStringCollection do: [:each | self matchesMethod: each do: aBlock]
    ]

    matchesAnyOf: aStringCollection do: aBlock [
	<category: 'searching'>
	aStringCollection do: [:each | self matches: each do: aBlock]
    ]

    matchesAnyTreeOf: treeCollection do: aBlock [
	<category: 'searching'>
	treeCollection do: [:each | self matchesTree: each do: aBlock]
    ]

    matchesArgument: aString do: aBlock [
	<category: 'searching'>
	self addArgumentRule: (RBSearchRule searchFor: aString thenDo: aBlock)
    ]

    matchesArgumentTree: aRBProgramNode do: aBlock [
	<category: 'searching'>
	self 
	    addArgumentRule: (RBSearchRule searchForTree: aRBProgramNode thenDo: aBlock)
    ]

    matchesMethod: aString do: aBlock [
	<category: 'searching'>
	self addRule: (RBSearchRule searchForMethod: aString thenDo: aBlock)
    ]

    matchesTree: aRBProgramNode do: aBlock [
	<category: 'searching'>
	self addRule: (RBSearchRule searchForTree: aRBProgramNode thenDo: aBlock)
    ]

    foundMatch [
	<category: 'private'>
	
    ]

    lookForMoreMatchesInContext: oldContext [
	<category: 'private'>
	oldContext keysAndValuesDo: 
		[:key :value | 
		(key isString not and: [key recurseInto]) 
		    ifTrue: [value do: [:each | self visitNode: each]]]
    ]

    performSearches: aSearchCollection on: aNode [
	<category: 'private'>
	| value |
	1 to: aSearchCollection size
	    do: 
		[:i | 
		value := (aSearchCollection at: i) performOn: aNode.
		value notNil 
		    ifTrue: 
			[self foundMatch.
			^value]].
	^nil
    ]

    recusivelySearchInContext [
	"We need to save the matched context since the other searches might overwrite it."

	<category: 'private'>
	| oldContext |
	oldContext := context.
	context := RBSmallDictionary new.
	self lookForMoreMatchesInContext: oldContext.
	context := oldContext
    ]

    visitArgument: aNode [
	<category: 'visiting'>
	| value |
	value := self performSearches: argumentSearches on: aNode.
	^value isNil 
	    ifTrue: 
		[aNode acceptVisitor: self.
		aNode]
	    ifFalse: [value]
    ]

    visitNode: aNode [
	<category: 'visiting'>
	| value |
	value := self performSearches: searches on: aNode.
	^value isNil 
	    ifTrue: 
		[aNode acceptVisitor: self.
		aNode]
	    ifFalse: [value]
    ]

    addArgumentSearch: aSearchCondition [
	<category: 'obsolete'>
	self addArgumentRule: (self buildParseTreeRuleFor: aSearchCondition)
    ]

    addArgumentSearches: aSearchCondition [
	<category: 'obsolete'>
	aSearchCondition key 
	    do: [:each | self addArgumentSearch: each -> aSearchCondition value]
    ]

    addMethodSearch: aSearchCondition [
	<category: 'obsolete'>
	self addRule: (self buildMethodParseTreeRuleFor: aSearchCondition)
    ]

    addMethodSearches: aSearchCondition [
	<category: 'obsolete'>
	aSearchCondition key 
	    do: [:each | self addMethodSearch: each -> aSearchCondition value]
    ]

    addSearch: aSearchCondition [
	<category: 'obsolete'>
	self addRule: (self buildParseTreeRuleFor: aSearchCondition)
    ]

    addSearches: aSearchCondition [
	<category: 'obsolete'>
	aSearchCondition key 
	    do: [:each | self addSearch: each -> aSearchCondition value]
    ]

    buildMethodParseTreeRuleFor: aSearchCondition [
	<category: 'obsolete'>
	^(aSearchCondition key isKindOf: RBProgramNode) 
	    ifTrue: 
		[RBSearchRule searchForTree: aSearchCondition key
		    thenDo: aSearchCondition value]
	    ifFalse: 
		[RBSearchRule searchForMethod: aSearchCondition key
		    thenDo: aSearchCondition value]
    ]

    buildParseTreeRuleFor: aSearchCondition [
	<category: 'obsolete'>
	^(aSearchCondition key isKindOf: RBProgramNode) 
	    ifTrue: 
		[RBSearchRule searchForTree: aSearchCondition key
		    thenDo: aSearchCondition value]
	    ifFalse: 
		[RBSearchRule searchFor: aSearchCondition key thenDo: aSearchCondition value]
    ]
]



RBParseTreeRule subclass: RBSearchRule [
    | answerBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBSearchRule class >> searchFor: aString thenDo: aBlock [
	<category: 'instance creation'>
	^self new searchFor: aString thenDo: aBlock
    ]

    RBSearchRule class >> searchForMethod: aString thenDo: aBlock [
	<category: 'instance creation'>
	^self new searchForMethod: aString thenDo: aBlock
    ]

    RBSearchRule class >> searchForTree: aRBProgramNode thenDo: aBlock [
	<category: 'instance creation'>
	^self new searchForTree: aRBProgramNode thenDo: aBlock
    ]

    searchFor: aString thenDo: aBlock [
	<category: 'initialize-release'>
	self searchString: aString.
	answerBlock := aBlock
    ]

    searchForMethod: aString thenDo: aBlock [
	<category: 'initialize-release'>
	self methodSearchString: aString.
	answerBlock := aBlock
    ]

    searchForTree: aRBProgramNode thenDo: aBlock [
	<category: 'initialize-release'>
	searchTree := aRBProgramNode.
	answerBlock := aBlock
    ]

    canMatch: aProgramNode [
	<category: 'testing'>
	owner answer: (answerBlock value: aProgramNode value: owner answer).
	^true
    ]
]



RBParseTreeRule subclass: RBReplaceRule [
    | verificationBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    initialize [
	<category: 'initialize-release'>
	super initialize.
	verificationBlock := [:aNode | true]
    ]

    canMatch: aProgramNode [
	<category: 'matching'>
	^verificationBlock value: aProgramNode
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	self subclassResponsibility
    ]
]



ParseTreeSearcher subclass: ParseTreeRewriter [
    | tree |
    
    <comment: 'ParseTreeRewriter walks over and transforms its RBProgramNode (tree). If the tree is modified, then answer is set to true, and the modified tree can be retrieved by the #tree method.

Instance Variables:
    tree    <RBProgramNode>    the parse tree we''re transforming'>
    <category: 'Refactory-Parser'>

    ParseTreeRewriter class >> replace: code with: newCode in: aParseTree [
	<category: 'accessing'>
	^(self 
	    replace: code
	    with: newCode
	    method: false)
	    executeTree: aParseTree;
	    tree
    ]

    ParseTreeRewriter class >> replace: code with: newCode in: aParseTree onInterval: anInterval [
	<category: 'accessing'>
	| rewriteRule |
	rewriteRule := self new.
	^rewriteRule
	    replace: code
		with: newCode
		when: [:aNode | aNode intersectsInterval: anInterval];
	    executeTree: aParseTree;
	    tree
    ]

    ParseTreeRewriter class >> replaceStatements: code with: newCode in: aParseTree onInterval: anInterval [
	<category: 'accessing'>
	| tree searchStmt replaceStmt |
	tree := self buildTree: code method: false.
	tree lastIsReturn 
	    ifTrue: 
		[searchStmt := '| `@temps | `@.Statements. ' , code.
		replaceStmt := '| `@temps | `@.Statements. ^' , newCode]
	    ifFalse: 
		[searchStmt := '| `@temps | `@.Statements1. ' , code , '.  `@.Statements2'.
		replaceStmt := '| `@temps | `@.Statements1. ' , newCode 
			    , '.  `@.Statements2'].
	^self 
	    replace: searchStmt
	    with: replaceStmt
	    in: aParseTree
	    onInterval: anInterval
    ]

    ParseTreeRewriter class >> classVariable: aVarName getter: getMethod setter: setMethod [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: aVarName , ' := ``@object'
		with: 'self class ' , setMethod , ' ``@object';
	    replace: aVarName with: 'self class ' , getMethod.
	^rewriteRule
    ]

    ParseTreeRewriter class >> removeTemporaryNamed: aName [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule replace: '| `@temps1 ' , aName , ' `@temps2 | ``@.Statements'
	    with: '| `@temps1  `@temps2 | ``@.Statements'.
	^rewriteRule
    ]

    ParseTreeRewriter class >> rename: varName to: newVarName [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: varName with: newVarName;
	    replaceArgument: varName with: newVarName.
	^rewriteRule
    ]

    ParseTreeRewriter class >> rename: varName to: newVarName handler: aBlock [
	"Rename varName to newVarName, evaluating aBlock if there is a
	 temporary variable with the same name as newVarName. This
	 does not change temporary variables with varName."

	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: varName with: newVarName;
	    replaceArgument: newVarName
		withValueFrom: 
		    [:aNode | 
		    aBlock value.
		    aNode].
	^rewriteRule
    ]

    ParseTreeRewriter class >> replace: code with: newCode method: aBoolean [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	aBoolean 
	    ifTrue: [rewriteRule replaceMethod: code with: newCode]
	    ifFalse: [rewriteRule replace: code with: newCode].
	^rewriteRule
    ]

    ParseTreeRewriter class >> replaceLiteral: literal with: newLiteral [
	<category: 'instance creation'>
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
	^rewriteRule
    ]

    ParseTreeRewriter class >> variable: aVarName getter: getMethod setter: setMethod [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: aVarName , ' := ``@object'
		with: 'self ' , setMethod , ' ``@object';
	    replace: aVarName with: 'self ' , getMethod.
	^rewriteRule
    ]

    ParseTreeRewriter class >> replaceLiteral: literal with: newLiteral inToken: literalToken [
	<category: 'private'>
	| value |
	value := literalToken realValue.
	value == literal 
	    ifTrue: 
		[literalToken 
		    value: newLiteral
		    start: nil
		    stop: nil.
		^true].
	^value class == Array and: 
		[literalToken value inject: false
		    into: 
			[:bool :each | 
			bool | (self 
				    replaceLiteral: literal
				    with: newLiteral
				    inToken: each)]]
    ]

    executeTree: aParseTree [
	<category: 'accessing'>
	| oldContext |
	oldContext := context.
	context := RBSmallDictionary new.
	answer := false.
	tree := self visitNode: aParseTree.
	context := oldContext.
	^answer
    ]

    tree [
	<category: 'accessing'>
	^tree
    ]

    replace: searchString with: replaceString [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule searchFor: searchString
		    replaceWith: replaceString)
    ]

    replace: searchString with: replaceString when: aBlock [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceString
		    when: aBlock)
    ]

    replace: searchString withValueFrom: replaceBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule searchFor: searchString
		    replaceWith: replaceBlock)
    ]

    replace: searchString withValueFrom: replaceBlock when: conditionBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceBlock
		    when: conditionBlock)
    ]

    replaceArgument: searchString with: replaceString [
	<category: 'replacing'>
	self addArgumentRule: (RBStringReplaceRule searchFor: searchString
		    replaceWith: replaceString)
    ]

    replaceArgument: searchString with: replaceString when: aBlock [
	<category: 'replacing'>
	self addArgumentRule: (RBStringReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceString
		    when: aBlock)
    ]

    replaceArgument: searchString withValueFrom: replaceBlock [
	<category: 'replacing'>
	self addArgumentRule: (RBBlockReplaceRule searchFor: searchString
		    replaceWith: replaceBlock)
    ]

    replaceArgument: searchString withValueFrom: replaceBlock when: conditionBlock [
	<category: 'replacing'>
	self addArgumentRule: (RBBlockReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceBlock
		    when: conditionBlock)
    ]

    replaceMethod: searchString with: replaceString [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule searchForMethod: searchString
		    replaceWith: replaceString)
    ]

    replaceMethod: searchString with: replaceString when: aBlock [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule 
		    searchForMethod: searchString
		    replaceWith: replaceString
		    when: aBlock)
    ]

    replaceMethod: searchString withValueFrom: replaceBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule searchForMethod: searchString
		    replaceWith: replaceBlock)
    ]

    replaceMethod: searchString withValueFrom: replaceBlock when: conditionBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule 
		    searchForMethod: searchString
		    replaceWith: replaceBlock
		    when: conditionBlock)
    ]

    replaceTree: searchTree withTree: replaceTree [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule searchForTree: searchTree
		    replaceWith: replaceTree)
    ]

    replaceTree: searchTree withTree: replaceTree when: aBlock [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule 
		    searchForTree: searchTree
		    replaceWith: replaceTree
		    when: aBlock)
    ]

    foundMatch [
	<category: 'private'>
	answer := true
    ]

    lookForMoreMatchesInContext: oldContext [
	<category: 'private'>
	oldContext keysAndValuesDo: 
		[:key :value | 
		| newValue |
		(key isString not and: [key recurseInto]) 
		    ifTrue: 
			["Of course, the following statement does nothing without the `deepCopy'
			 which fixes the bug."

			newValue := oldContext at: key put: value deepCopy.	"<<<"
			self visitNodes: newValue
			    onMatch: [:newValue | oldContext at: key put: newValue]]]
    ]

    visitNode: aNode [
	<category: 'visiting'>
	^self 
	    visitNode: aNode
	    searches: searches
	    onMatch: [:newNode | ]
    ]

    visitNode: aNode onMatch: aBlock [
	<category: 'visiting'>
	^self 
	    visitNode: aNode
	    searches: searches
	    onMatch: aBlock
    ]

    visitNodes: aNodeList [
	<category: 'visiting'>
	^self visitNodes: aNodeList onMatch: [:newNodes | ]
    ]

    visitNodes: aNodeList onMatch: aBlock [
	<category: 'visiting'>
	^self 
	    visitNodes: aNodeList
	    searches: searches
	    onMatch: aBlock
    ]

    visitArgument: aNode [
	<category: 'visiting'>
	^self 
	    visitNode: aNode
	    searches: argumentSearches
	    onMatch: [:newNode | ]
    ]

    visitArguments: aNodeList [
	<category: 'visiting'>
	^self visitArguments: aNodeList onMatch: [:newNodes | ]
    ]

    visitArguments: aNodeList onMatch: aBlock [
	<category: 'visiting'>
	^self 
	    visitNodes: aNodeList
	    searches: argumentSearches
	    onMatch: aBlock
    ]

    visitNode: aNode searches: theseSearches onMatch: aBlock [
	"Visit aNode, sending visitNode:'s answer to aBlock if
	 performSearches:on: finds a match."

	<category: 'visiting'>
	| newNode |
	newNode := self performSearches: theseSearches on: aNode.
	^newNode isNil 
	    ifTrue: 
		[aNode acceptVisitor: self.
		aNode]
	    ifFalse: 
		[aBlock value: newNode.
		newNode]
    ]

    visitNodes: aNodeList searches: theseSearches onMatch: aBlock [
	"Answer aNodeList but with each element replaced by the result of
	 visitNode:onMatch: with said element (and a block of my own).  If
	 any matches occur, I'll call aBlock afterwards with the
	 replacement of aNodeList before answering it."

	<category: 'visiting'>
	| replacementList rlHasMatch |
	rlHasMatch := false.
	replacementList := aNodeList collect: 
			[:eltNode | 
			self 
			    visitNode: eltNode
			    searches: theseSearches
			    onMatch: [:newElt | rlHasMatch := true]].
	^rlHasMatch 
	    ifTrue: 
		[aBlock value: replacementList.
		replacementList]
	    ifFalse: [aNodeList]
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anAssignmentNode variable
	    onMatch: [:newField | anAssignmentNode variable: newField].
	self visitNode: anAssignmentNode value
	    onMatch: [:newField | anAssignmentNode value: newField]
    ]

    acceptArrayConstructorNode: anArrayNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anArrayNode body
	    onMatch: [:newField | anArrayNode body: newField]
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aBlockNode arguments
	    onMatch: [:newField | aBlockNode arguments: newField].
	self visitNode: aBlockNode body
	    onMatch: [:newField | aBlockNode body: newField]
    ]

    searchCascadeNodeMessage: aMessageNode messagesTo: newMessages [
	"Helper for acceptCascadeNode: -- descend to aMessageNode, but no
	 further.  Add the resulting message or cascade of messages from
	 the tree rule's foundMatchFor: to newMessages and answer said
	 result if a match is found.  Add aMessageNode to newMessages and
	 answer nil otherwise."

	<category: 'visitor-double dispatching'>
	| answer newNode |
	answer := self performSearches: searches on: aMessageNode.
	newNode := answer ifNil: [aMessageNode].
	newNode isCascade 
	    ifTrue: [newMessages addAll: newNode messages]
	    ifFalse: 
		[newMessages add: (newNode isMessage 
			    ifTrue: [newNode]
			    ifFalse: 
				[Warning 
				    signal: 'Cannot replace message node inside of cascaded node with non-message node'.
				answer := nil.	"<<<"
				aMessageNode])].
	^answer
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	| newMessages notFound |
	newMessages := OrderedCollection new: aCascadeNode messages size.
	notFound := OrderedCollection new: aCascadeNode messages size.
	aCascadeNode messages do: 
		[:each | 
		(self searchCascadeNodeMessage: each messagesTo: newMessages) isNil 
		    ifTrue: [notFound add: each]].

	"Rewrite the receiver once and distribute it among the messages if
	 no replacements were made."
	notFound size == aCascadeNode messages size 
	    ifTrue: 
		[self visitNode: aCascadeNode messages first receiver
		    onMatch: [:receiver | newMessages do: [:each | each receiver: receiver]]].
	notFound do: 
		[:each | 
		self visitNodes: each arguments
		    onMatch: [:newArgs | each arguments: newArgs]].
	aCascadeNode messages: newMessages
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver
	    onMatch: [:newField | aMessageNode receiver: newField].
	self visitNodes: aMessageNode arguments
	    onMatch: [:newField | aMessageNode arguments: newField]
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aMethodNode arguments
	    onMatch: [:newField | aMethodNode arguments: newField].
	self visitNode: aMethodNode body
	    onMatch: [:newField | aMethodNode body: newField]
    ]

    acceptOptimizedNode: anOptimizedNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anOptimizedNode body
	    onMatch: [:newField | anOptimizedNode body: newField]
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aReturnNode value
	    onMatch: [:newField | aReturnNode value: newField]
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aSequenceNode temporaries
	    onMatch: [:newField | aSequenceNode temporaries: newField].
	self visitNodes: aSequenceNode statements
	    onMatch: [:newField | aSequenceNode statements: newField]
    ]
]



RBReplaceRule subclass: RBStringReplaceRule [
    | replaceTree |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBStringReplaceRule class >> searchFor: searchString replaceWith: replaceString [
	<category: 'instance creation'>
	^self new searchFor: searchString replaceWith: replaceString
    ]

    RBStringReplaceRule class >> searchFor: searchString replaceWith: replaceString when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchFor: searchString
	    replaceWith: replaceString
	    when: aBlock
    ]

    RBStringReplaceRule class >> searchForMethod: searchString replaceWith: replaceString [
	<category: 'instance creation'>
	^self new searchForMethod: searchString replaceWith: replaceString
    ]

    RBStringReplaceRule class >> searchForMethod: searchString replaceWith: replaceString when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchForMethod: searchString
	    replaceWith: replaceString
	    when: aBlock
    ]

    RBStringReplaceRule class >> searchForTree: searchString replaceWith: replaceString [
	<category: 'instance creation'>
	^self new searchForTree: searchString replaceWith: replaceString
    ]

    RBStringReplaceRule class >> searchForTree: searchString replaceWith: replaceString when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchForTree: searchString
	    replaceWith: replaceString
	    when: aBlock
    ]

    methodReplaceString: replaceString [
	<category: 'initialize-release'>
	replaceTree := RBParser parseRewriteMethod: replaceString
    ]

    replaceString: replaceString [
	<category: 'initialize-release'>
	replaceTree := RBParser parseRewriteExpression: replaceString.
	searchTree isSequence = replaceTree isSequence 
	    ifFalse: 
		[searchTree isSequence 
		    ifTrue: [replaceTree := RBSequenceNode statements: (Array with: replaceTree)]
		    ifFalse: [searchTree := RBSequenceNode statements: (Array with: searchTree)]]
    ]

    searchFor: searchString replaceWith: replaceString [
	<category: 'initialize-release'>
	self searchString: searchString.
	self replaceString: replaceString
    ]

    searchFor: searchString replaceWith: replaceString when: aBlock [
	<category: 'initialize-release'>
	self searchFor: searchString replaceWith: replaceString.
	verificationBlock := aBlock
    ]

    searchForMethod: searchString replaceWith: replaceString [
	<category: 'initialize-release'>
	self methodSearchString: searchString.
	self methodReplaceString: replaceString
    ]

    searchForMethod: searchString replaceWith: replaceString when: aBlock [
	<category: 'initialize-release'>
	self searchForMethod: searchString replaceWith: replaceString.
	verificationBlock := aBlock
    ]

    searchForTree: aRBProgramNode replaceWith: replaceNode [
	<category: 'initialize-release'>
	searchTree := aRBProgramNode.
	replaceTree := replaceNode
    ]

    searchForTree: aRBProgramNode replaceWith: replaceString when: aBlock [
	<category: 'initialize-release'>
	self searchForTree: aRBProgramNode replaceWith: replaceString.
	verificationBlock := aBlock
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	| newTree |
	newTree := replaceTree copyInContext: self context.
	newTree copyCommentsFrom: aProgramNode.
	^newTree
    ]
]



RBReplaceRule subclass: RBBlockReplaceRule [
    | replaceBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBBlockReplaceRule class >> searchFor: searchString replaceWith: replaceBlock [
	<category: 'instance creation'>
	^self new searchFor: searchString replaceWith: replaceBlock
    ]

    RBBlockReplaceRule class >> searchFor: searchString replaceWith: replaceBlock when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchFor: searchString
	    replaceWith: replaceBlock
	    when: aBlock
    ]

    RBBlockReplaceRule class >> searchForMethod: searchString replaceWith: replaceBlock [
	<category: 'instance creation'>
	^self new searchForMethod: searchString replaceWith: replaceBlock
    ]

    RBBlockReplaceRule class >> searchForMethod: searchString replaceWith: replaceBlock when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchForMethod: searchString
	    replaceWith: replaceBlock
	    when: aBlock
    ]

    RBBlockReplaceRule class >> searchForTree: searchString replaceWith: replaceBlock [
	<category: 'instance creation'>
	^self new searchForTree: searchString replaceWith: replaceBlock
    ]

    RBBlockReplaceRule class >> searchForTree: searchString replaceWith: replaceBlock when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchFor: searchString
	    replaceWith: replaceBlock
	    when: aBlock
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	replaceBlock := [:aNode | aNode]
    ]

    searchFor: searchString replaceWith: aBlock [
	<category: 'initialize-release'>
	self searchString: searchString.
	replaceBlock := aBlock
    ]

    searchFor: searchString replaceWith: replBlock when: verifyBlock [
	<category: 'initialize-release'>
	self searchFor: searchString replaceWith: replBlock.
	verificationBlock := verifyBlock
    ]

    searchForMethod: searchString replaceWith: aBlock [
	<category: 'initialize-release'>
	self methodSearchString: searchString.
	replaceBlock := aBlock
    ]

    searchForMethod: searchString replaceWith: replBlock when: verifyBlock [
	<category: 'initialize-release'>
	self searchForMethod: searchString replaceWith: replBlock.
	verificationBlock := verifyBlock
    ]

    searchForTree: aRBProgramNode replaceWith: aBlock [
	<category: 'initialize-release'>
	searchTree := aRBProgramNode.
	replaceBlock := aBlock
    ]

    searchForTree: aRBProgramNode replaceWith: replBlock when: verifyBlock [
	<category: 'initialize-release'>
	self searchForTree: aRBProgramNode replaceWith: replBlock.
	verificationBlock := verifyBlock
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	^replaceBlock value: aProgramNode
    ]
]

