"======================================================================
|
|   Refactoring Browser - Smalltalk parser and scanner
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



Object subclass: RBParser [
    | scanner currentToken nextToken errorBlock tags source methodCategory |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBParser class >> parseExpression: aString [
	<category: 'accessing'>
	^self parseExpression: aString onError: nil
    ]

    RBParser class >> parseExpression: aString onError: aBlock [
	<category: 'accessing'>
	| node parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #on:errorBlock:.
	node := parser parseExpression.
	^(node statements size == 1 and: [node temporaries isEmpty]) 
	    ifTrue: [node statements first]
	    ifFalse: [node]
    ]

    RBParser class >> parseMethod: aString [
	<category: 'accessing'>
	^self 
	    parseMethod: aString
	    category: nil
	    onError: nil
    ]

    RBParser class >> parseMethod: aString category: aCategory [
	<category: 'accessing'>
	^self 
	    parseMethod: aString
	    category: aCategory
	    onError: nil
    ]

    RBParser class >> parseMethod: aString onError: aBlock [
	<category: 'accessing'>
	^self 
	    parseMethod: aString
	    category: nil
	    onError: aBlock
    ]

    RBParser class >> parseMethod: aString category: aCategory onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser methodCategory: aCategory.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #on:errorBlock:.
	^parser parseMethod: aString
    ]

    RBParser class >> parseRewriteExpression: aString [
	<category: 'accessing'>
	^self parseRewriteExpression: aString onError: nil
    ]

    RBParser class >> parseRewriteExpression: aString onError: aBlock [
	<category: 'accessing'>
	| node parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #rewriteOn:errorBlock:.
	node := parser parseExpression.
	^(node statements size == 1 and: [node temporaries isEmpty]) 
	    ifTrue: [node statements first]
	    ifFalse: [node]
    ]

    RBParser class >> parseRewriteMethod: aString [
	<category: 'accessing'>
	^self parseRewriteMethod: aString onError: nil
    ]

    RBParser class >> parseRewriteMethod: aString onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #rewriteOn:errorBlock:.
	^parser parseMethod: aString
    ]

    RBParser class >> parseMethodPattern: aString [
	<category: 'parsing'>
	| parser |
	parser := self new.
	parser errorBlock: [:error :position | ^nil].
	parser initializeParserWith: aString type: #on:errorBlock:.
	^parser parseMessagePattern selector
    ]

    methodCategory [
	<category: 'accessing'>
	^methodCategory
    ]

    methodCategory: aCategory [
	<category: 'accessing'>
	methodCategory := aCategory
    ]

    errorBlock: aBlock [
	<category: 'accessing'>
	errorBlock := aBlock.
	scanner notNil ifTrue: [scanner errorBlock: aBlock]
    ]

    initializeParserWith: aString type: aSymbol [
	<category: 'accessing'>
	source := aString.
	self scanner: (self scannerClass 
		    perform: aSymbol
		    with: (ReadStream on: aString)
		    with: self errorBlock)
    ]

    initializeParserWithStream: aStream type: aSymbol [
	<category: 'accessing'>
	source := nil.
	self scanner: (self scannerClass 
		    perform: aSymbol
		    with: aStream
		    with: self errorBlock)
    ]

    parseExpression [
	<category: 'accessing'>
	| node |
	node := self parseStatements: false.
	self atEnd ifFalse: [self parserError: 'Unknown input at end'].
	^node
    ]

    parseMethod: aString [
	<category: 'accessing'>
	| node |
	node := self parseMethod.
	self atEnd ifFalse: [self parserError: 'Unknown input at end'].
	node source: aString.
	^node
    ]

    scannerClass [
	<category: 'accessing'>
	^RBScanner
    ]

    errorBlock [
	<category: 'error handling'>
	^errorBlock isNil ifTrue: [[:message :position | ]] ifFalse: [errorBlock]
    ]

    errorFile [
	<category: 'error handling'>
	^scanner stream name
    ]

    errorLine [
	<category: 'error handling'>
	^(scanner stream copyFrom: 1 to: self errorPosition) readStream lines 
	    contents size
    ]

    errorPosition [
	<category: 'error handling'>
	^currentToken start
    ]

    parserWarning: aString [
	"Raise a Warning"

	<category: 'error handling'>
	Warning signal: aString
    ]

    parserError: aString [
	"Evaluate the block. If it returns raise an error"

	<category: 'error handling'>
	self errorBlock value: aString value: self errorPosition.
	self 
	    error: '%1:%2: %3' % 
			{self errorFile.
			self errorLine.
			aString}
    ]

    scanner: aScanner [
	<category: 'initialize-release'>
	scanner := aScanner.
	tags := nil.
	self step
    ]

    addCommentsTo: aNode [
	<category: 'private'>
	aNode comments: scanner getComments
    ]

    currentToken [
	<category: 'private'>
	^currentToken
    ]

    nextToken [
	<category: 'private'>
	^nextToken isNil ifTrue: [nextToken := scanner next] ifFalse: [nextToken]
    ]

    step [
	<category: 'private'>
	nextToken notNil 
	    ifTrue: 
		[currentToken := nextToken.
		nextToken := nil.
		^currentToken].
	currentToken := scanner next
    ]

    parseArgs [
	<category: 'private-parsing'>
	| args |
	args := OrderedCollection new.
	[currentToken isIdentifier] whileTrue: [args add: self parseVariableNode].
	^args
    ]

    parseArrayConstructor [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := RBArrayConstructorNode new.
	node left: position.
	node body: (self parseStatements: false).
	(currentToken isSpecial and: [currentToken value == $}]) 
	    ifFalse: [self parserError: '''}'' expected'].
	node right: currentToken start.
	self step.
	^node
    ]

    parseAssignment [
	"Need one token lookahead to see if we have a ':='. This method could
	 make it possible to assign the literals true, false and nil."

	<category: 'private-parsing'>
	| node position |
	(currentToken isIdentifier and: [self nextToken isAssignment]) 
	    ifFalse: [^self parseCascadeMessage].
	node := self parseVariableNode.
	position := currentToken start.
	self step.
	^RBAssignmentNode 
	    variable: node
	    value: self parseAssignment
	    position: position
    ]

    parseBinaryMessage [
	<category: 'private-parsing'>
	| node |
	node := self parseUnaryMessage.
	[currentToken isBinary] 
	    whileTrue: [node := self parseBinaryMessageWith: node].
	^node
    ]

    parseBinaryMessageNoGreater [
	<category: 'private-parsing'>
	| node |
	node := self parseUnaryMessage.
	[currentToken isBinary and: [currentToken value ~~ #>]] 
	    whileTrue: [node := self parseBinaryMessageWith: node].
	^node
    ]

    parseBinaryMessageWith: aNode [
	<category: 'private-parsing'>
	| binaryToken |
	binaryToken := currentToken.
	self step.
	^RBMessageNode 
	    receiver: aNode
	    selectorParts: (Array with: binaryToken)
	    arguments: (Array with: self parseUnaryMessage)
    ]

    parseBinaryPattern [
	<category: 'private-parsing'>
	| binaryToken |
	currentToken isBinary 
	    ifFalse: [self parserError: 'Message pattern expected'].
	binaryToken := currentToken.
	self step.
	^RBMethodNode selectorParts: (Array with: binaryToken)
	    arguments: (Array with: self parseVariableNode)
    ]

    parseBlock [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := self parseBlockArgsInto: RBBlockNode new.
	node left: position.
	node body: (self parseStatements: false).
	(currentToken isSpecial and: [currentToken value == $]]) 
	    ifFalse: [self parserError: ''']'' expected'].
	node right: currentToken start.
	self step.
	^node
    ]

    parseBlockArgsInto: node [
	<category: 'private-parsing'>
	| verticalBar args colons |
	args := OrderedCollection new: 2.
	colons := OrderedCollection new: 2.
	verticalBar := false.
	[currentToken isSpecial and: [currentToken value == $:]] whileTrue: 
		[colons add: currentToken start.
		self step.	":"
		verticalBar := true.
		args add: self parseVariableNode].
	verticalBar 
	    ifTrue: 
		[currentToken isBinary 
		    ifTrue: 
			[node bar: currentToken start.
			currentToken value == #| 
			    ifTrue: [self step]
			    ifFalse: 
				[currentToken value == #'||' 
				    ifTrue: 
					["Hack the current token to be the start
					 of temps bar"

					currentToken
					    value: #|;
					    start: currentToken start + 1]
				    ifFalse: [self parserError: '''|'' expected']]]
		    ifFalse: 
			[(currentToken isSpecial and: [currentToken value == $]]) 
			    ifFalse: [self parserError: '''|'' expected']]].
	node
	    arguments: args;
	    colons: colons.
	^node
    ]

    parseCascadeMessage [
	<category: 'private-parsing'>
	| node receiver messages semicolons |
	node := self parseKeywordMessage.
	(currentToken isSpecial 
	    and: [currentToken value == $; and: [node isMessage]]) ifFalse: [^node].
	receiver := node receiver.
	messages := OrderedCollection new: 3.
	semicolons := OrderedCollection new: 3.
	messages add: node.
	[currentToken isSpecial and: [currentToken value == $;]] whileTrue: 
		[semicolons add: currentToken start.
		self step.
		messages add: (currentToken isIdentifier 
			    ifTrue: [self parseUnaryMessageWith: receiver]
			    ifFalse: 
				[currentToken isKeyword 
				    ifTrue: [self parseKeywordMessageWith: receiver]
				    ifFalse: 
					[| temp |
					currentToken isBinary ifFalse: [self parserError: 'Message expected'].
					temp := self parseBinaryMessageWith: receiver.
					temp == receiver ifTrue: [self parserError: 'Message expected'].
					temp]])].
	^RBCascadeNode messages: messages semicolons: semicolons
    ]

    parseKeywordMessage [
	<category: 'private-parsing'>
	^self parseKeywordMessageWith: self parseBinaryMessage
    ]

    parseKeywordMessageWith: node [
	<category: 'private-parsing'>
	| args isKeyword keywords |
	args := OrderedCollection new: 3.
	keywords := OrderedCollection new: 3.
	isKeyword := false.
	[currentToken isKeyword] whileTrue: 
		[keywords add: currentToken.
		self step.
		args add: self parseBinaryMessage.
		isKeyword := true].
	^isKeyword 
	    ifTrue: 
		[RBMessageNode 
		    receiver: node
		    selectorParts: keywords
		    arguments: args]
	    ifFalse: [node]
    ]

    parseKeywordPattern [
	<category: 'private-parsing'>
	| keywords args |
	keywords := OrderedCollection new: 2.
	args := OrderedCollection new: 2.
	[currentToken isKeyword] whileTrue: 
		[keywords add: currentToken.
		self step.
		args add: self parseVariableNode].
	^RBMethodNode selectorParts: keywords arguments: args
    ]

    parseMessagePattern [
	<category: 'private-parsing'>
	^currentToken isIdentifier 
	    ifTrue: [self parseUnaryPattern]
	    ifFalse: 
		[currentToken isKeyword 
		    ifTrue: [self parseKeywordPattern]
		    ifFalse: [self parseBinaryPattern]]
    ]

    parseMethod [
	<category: 'private-parsing'>
	| methodNode |
	methodNode := self parseMessagePattern.
	^self parseMethodInto: methodNode
    ]

    parseMethodInto: methodNode [
	<category: 'private-parsing'>
	tags := nil.
	self parseResourceTag.
	self addCommentsTo: methodNode.
	methodNode body: (self parseStatements: true).
	methodNode tags: tags.
	methodNode category: methodCategory.
	^methodNode
    ]

    parseOptimizedExpression [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := RBOptimizedNode 
		    left: position
		    body: (self parseStatements: false)
		    right: currentToken start.
	(currentToken isSpecial and: [currentToken value == $)]) 
	    ifFalse: [self parserError: ''')'' expected'].
	self step.
	^node
    ]

    parseParenthesizedExpression [
	<category: 'private-parsing'>
	| leftParen node |
	leftParen := currentToken start.
	self step.
	node := self parseAssignment.
	^(currentToken isSpecial and: [currentToken value == $)]) 
	    ifTrue: 
		[node addParenthesis: (leftParen to: currentToken start).
		self step.
		node]
	    ifFalse: [self parserError: ''')'' expected']
    ]

    parsePatternBlock [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := self parseBlockArgsInto: RBPatternBlockNode new.
	node left: position.
	node body: (self parseStatements: false).
	(currentToken isSpecial and: [currentToken value == $}]) 
	    ifFalse: [self parserError: '''}'' expected'].
	node right: currentToken start.
	self step.
	^node
    ]

    parsePrimitiveIdentifier [
	<category: 'private-parsing'>
	| value token |
	token := currentToken.
	value := currentToken value.
	self step.
	value = 'true' 
	    ifTrue: 
		[^RBLiteralNode literalToken: (RBLiteralToken 
			    value: true
			    start: token start
			    stop: token start + 3)].
	value = 'false' 
	    ifTrue: 
		[^RBLiteralNode literalToken: (RBLiteralToken 
			    value: false
			    start: token start
			    stop: token start + 4)].
	value = 'nil' 
	    ifTrue: 
		[^RBLiteralNode literalToken: (RBLiteralToken 
			    value: nil
			    start: token start
			    stop: token start + 2)].
	^RBVariableNode identifierToken: token
    ]

    parseNegatedNumber [
	<category: 'private-parsing'>
	| token |
	self step.
	token := currentToken.
	(token value respondsTo: #negated) ifFalse: [
	    ^self parserError: 'Number expected' ].
	token value negative ifTrue: [
	    ^self parserError: 'Positive number expected' ].
	token value: token value negated.
	self step.
	^RBLiteralNode literalToken: token
    ]

    parsePrimitiveLiteral [
	<category: 'private-parsing'>
	| token |
	token := currentToken.
	self step.
	^RBLiteralNode literalToken: token
    ]

    parsePrimitiveObject [
	<category: 'private-parsing'>
	currentToken isIdentifier ifTrue: [^self parsePrimitiveIdentifier].
	currentToken isLiteral ifTrue: [^self parsePrimitiveLiteral].
	(currentToken isBinary and: [ currentToken value == #- ])
	    ifTrue: [^self parseNegatedNumber].
	currentToken isSpecial 
	    ifTrue: 
		[currentToken value == $[ ifTrue: [^self parseBlock].
		currentToken value == ${ ifTrue: [^self parseArrayConstructor].
		currentToken value == $( ifTrue: [^self parseParenthesizedExpression]].
	currentToken isPatternBlock ifTrue: [^self parsePatternBlock].
	currentToken isOptimized ifTrue: [^self parseOptimizedExpression].
	self parserError: 'Variable expected'
    ]

    parseResourceTag [
	<category: 'private-parsing'>
	| start |
	[currentToken isBinary and: [currentToken value == #<]] whileTrue: 
		[start := currentToken start.
		self step.
		[scanner atEnd or: [currentToken isBinary and: [currentToken value == #>]]] 
		    whileFalse: [self step].
		(currentToken isBinary and: [currentToken value == #>]) 
		    ifFalse: [self parserError: '''>'' expected'].
		tags isNil 
		    ifTrue: [tags := OrderedCollection with: (start to: currentToken stop)]
		    ifFalse: [tags add: (start to: currentToken stop)].
		self step]
    ]

    parseStatementList: tagBoolean into: sequenceNode [
	<category: 'private-parsing'>
	| statements return periods returnPosition node |
	return := false.
	statements := OrderedCollection new.
	periods := OrderedCollection new.
	self addCommentsTo: sequenceNode.
	tagBoolean ifTrue: [self parseResourceTag].
	
	[self atEnd 
	    or: [currentToken isSpecial and: ['!])}' includes: currentToken value]]] 
		whileFalse: 
		    [return ifTrue: [self parserError: 'End of statement list encountered'].
		    (currentToken isSpecial and: [currentToken value == $^]) 
			ifTrue: 
			    [returnPosition := currentToken start.
			    self step.
			    node := RBReturnNode return: returnPosition value: self parseAssignment.
			    self addCommentsTo: node.
			    statements add: node.
			    return := true]
			ifFalse: 
			    [node := self parseAssignment.
			    self addCommentsTo: node.
			    statements add: node].
		    (currentToken isSpecial and: [currentToken value == $.]) 
			ifTrue: 
			    [periods add: currentToken start.
			    self step]
			ifFalse: [return := true]].
	sequenceNode
	    statements: statements;
	    periods: periods.
	^sequenceNode
    ]

    parseStatements: tagBoolean [
	<category: 'private-parsing'>
	| args leftBar rightBar |
	args := #().
	leftBar := rightBar := nil.
	currentToken isBinary 
	    ifTrue: 
		[currentToken value == #| 
		    ifTrue: 
			[leftBar := currentToken start.
			self step.
			args := self parseArgs.
			(currentToken isBinary and: [currentToken value = #|]) 
			    ifFalse: [self parserError: '''|'' expected'].
			rightBar := currentToken start.
			self step]
		    ifFalse: 
			[currentToken value == #'||' 
			    ifTrue: 
				[rightBar := (leftBar := currentToken start) + 1.
				self step]]].
	^self parseStatementList: tagBoolean
	    into: (RBSequenceNode 
		    leftBar: leftBar
		    temporaries: args
		    rightBar: rightBar)
    ]

    parseUnaryMessage [
	<category: 'private-parsing'>
	| node |
	node := self parsePrimitiveObject.
	[currentToken isIdentifier] 
	    whileTrue: [node := self parseUnaryMessageWith: node].
	^node
    ]

    parseUnaryMessageWith: aNode [
	<category: 'private-parsing'>
	| selector |
	selector := currentToken.
	self step.
	^RBMessageNode 
	    receiver: aNode
	    selectorParts: (Array with: selector)
	    arguments: #()
    ]

    parseUnaryPattern [
	<category: 'private-parsing'>
	| selector |
	selector := currentToken.
	self step.
	^RBMethodNode selectorParts: (Array with: selector) arguments: #()
    ]

    parseVariableNode [
	<category: 'private-parsing'>
	| node |
	currentToken isIdentifier 
	    ifFalse: [self parserError: 'Variable name expected'].
	node := RBVariableNode identifierToken: currentToken.
	self step.
	^node
    ]

    atEnd [
	<category: 'testing'>
	^currentToken class == RBToken
    ]
]



Stream subclass: RBScanner [
    | stream buffer tokenStart currentCharacter characterType classificationTable saveComments comments extendedLanguage errorBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    ClassificationTable := nil.
    PatternVariableCharacter := nil.

    RBScanner class >> classificationTable [
	<category: 'accessing'>
	ClassificationTable isNil ifTrue: [self initialize].
	^ClassificationTable
    ]

    RBScanner class >> patternVariableCharacter [
	<category: 'accessing'>
	^PatternVariableCharacter
    ]

    RBScanner class >> initialize [
	<category: 'class initialization'>
	PatternVariableCharacter := $`.
	ClassificationTable := Array new: 255.
	self 
	    initializeChars: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'
	    to: #alphabetic.
	self initializeChars: '01234567890' to: #digit.
	self initializeChars: '%&*+,-/<=>?@\~|' to: #binary.
	self initializeChars: '{}().:;[]^!' to: #special.
	#(9 10 12 13 26 32) do: [:i | ClassificationTable at: i put: #separator]
    ]

    RBScanner class >> initializeChars: characters to: aSymbol [
	<category: 'class initialization'>
	characters do: [:c | ClassificationTable at: c asInteger put: aSymbol]
    ]

    RBScanner class >> on: aStream [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str step.
	str stripSeparators.
	^str
    ]

    RBScanner class >> on: aStream errorBlock: aBlock [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str
	    errorBlock: aBlock;
	    step;
	    stripSeparators.
	^str
    ]

    RBScanner class >> rewriteOn: aStream [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str
	    extendedLanguage: true;
	    ignoreComments.
	str step.
	str stripSeparators.
	^str
    ]

    RBScanner class >> rewriteOn: aStream errorBlock: aBlock [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str
	    extendedLanguage: true;
	    ignoreComments;
	    errorBlock: aBlock;
	    step;
	    stripSeparators.
	^str
    ]

    RBScanner class >> isSelector: aSymbol [
	<category: 'testing'>
	| scanner token |
	scanner := self basicNew.
	scanner on: (ReadStream on: aSymbol asString).
	scanner step.
	token := scanner scanAnySymbol.
	token isLiteral ifFalse: [^false].
	token value isEmpty ifTrue: [^false].
	^scanner atEnd
    ]

    RBScanner class >> isVariable: aString [
	<category: 'testing'>
	| scanner token |
	aString isString ifFalse: [^false].
	aString isEmpty ifTrue: [^false].
	(ClassificationTable at: aString first asInteger) == #alphabetic 
	    ifFalse: [^false].
	scanner := self basicNew.
	scanner on: (ReadStream on: aString asString).
	scanner errorBlock: [:s :p | ^false].
	scanner step.
	token := scanner scanIdentifierOrKeyword.
	token isKeyword ifTrue: [^false].
	^scanner atEnd
    ]

    classificationTable: anObject [
	<category: 'accessing'>
	classificationTable := anObject
    ]

    contents [
	<category: 'accessing'>
	| contentsStream |
	contentsStream := WriteStream on: (Array new: 50).
	self do: [:each | contentsStream nextPut: each].
	^contentsStream contents
    ]

    errorBlock: aBlock [
	<category: 'accessing'>
	errorBlock := aBlock
    ]

    extendedLanguage [
	<category: 'accessing'>
	^extendedLanguage
    ]

    extendedLanguage: aBoolean [
	<category: 'accessing'>
	extendedLanguage := aBoolean
    ]

    flush [
	<category: 'accessing'>
	
    ]

    getComments [
	<category: 'accessing'>
	| oldComments |
	comments isEmpty ifTrue: [^nil].
	oldComments := comments.
	comments := OrderedCollection new: 1.
	^oldComments
    ]

    ignoreComments [
	<category: 'accessing'>
	saveComments := false
    ]

    next [
	<category: 'accessing'>
	| token |
	buffer reset.
	tokenStart := stream position.
	characterType == #eof ifTrue: [^RBToken start: tokenStart + 1].	"The EOF token should occur after the end of input"
	token := self scanToken.
	self stripSeparators.
	^token
    ]

    nextPut: anObject [
	"Provide an error notification that the receiver does not
	 implement this message."

	<category: 'accessing'>
	self shouldNotImplement
    ]

    saveComments [
	<category: 'accessing'>
	saveComments := true
    ]

    scanToken [
	"fast-n-ugly. Don't write stuff like this. Has been found to cause cancer in laboratory rats. Basically a
	 case statement. Didn't use Dictionary because lookup is pretty slow."

	<category: 'accessing'>
	characterType == #alphabetic ifTrue: [^self scanIdentifierOrKeyword].
	characterType == #digit ifTrue: [^self scanNumber].
	characterType == #binary ifTrue: [^self scanBinary: RBBinarySelectorToken].
	characterType == #special ifTrue: [^self scanSpecialCharacter].
	currentCharacter == $' ifTrue: [^self scanLiteralString].
	currentCharacter == $# ifTrue: [^self scanLiteral].
	currentCharacter == $$ ifTrue: [^self scanLiteralCharacter].
	(extendedLanguage and: [currentCharacter == PatternVariableCharacter]) 
	    ifTrue: [^self scanPatternVariable].
	^self scannerError: 'Unknown character'
    ]

    position [
	<category: 'accessing'>
	^stream position
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    errorBlock [
	<category: 'error handling'>
	^errorBlock isNil ifTrue: [[:message :position | ]] ifFalse: [errorBlock]
    ]

    errorPosition [
	<category: 'error handling'>
	^stream position
    ]

    scannerError: aString [
	"Evaluate the block. If it returns raise an error"

	<category: 'error handling'>
	self errorBlock value: aString value: self errorPosition.
	self error: aString
    ]

    on: aStream [
	<category: 'initialize-release'>
	buffer := WriteStream on: (String new: 60).
	stream := aStream.
	classificationTable := self class classificationTable.
	saveComments := true.
	extendedLanguage := false.
	comments := OrderedCollection new
    ]

    classify: aCharacter [
	<category: 'private'>
	| index |
	aCharacter isNil ifTrue: [^nil].
	index := aCharacter asInteger.
	index == 0 ifTrue: [^#separator].
	index > 255 ifTrue: [^nil].
	^classificationTable at: index
    ]

    previousStepPosition [
	<category: 'private'>
	^characterType == #eof 
	    ifTrue: [stream position]
	    ifFalse: [stream position - 1]
    ]

    step [
	<category: 'private'>
	stream atEnd 
	    ifTrue: 
		[characterType := #eof.
		^currentCharacter := nil].
	currentCharacter := stream next.
	characterType := self classify: currentCharacter.
	^currentCharacter
    ]

    isDigit: aChar base: base [
	<category: 'private-scanning numbers'>
	aChar isNil ifTrue: [^false].
	base <= 10 
	    ifTrue: 
		[aChar isDigit ifFalse: [^false].
		^aChar value - $0 value < base].
	^aChar isUppercase 
	    ifTrue: [aChar value - $A value < (base - 10)]
	    ifFalse: [aChar isDigit]
    ]

    scanDigits: ch base: base [
	<category: 'private-scanning numbers'>
	| c num |
	c := ch.
	num := 0.
	
	[[c == $_] whileTrue: 
		[self step.
		c := currentCharacter].
	c notNil and: [self isDigit: c base: base]] 
		whileTrue: 
		    [num := num * base + c digitValue.
		    self step.
		    c := currentCharacter].
	^num
    ]

    scanExtendedLiterals [
	<category: 'private-scanning numbers'>
	| token |
	self step.
	currentCharacter == $( 
	    ifTrue: 
		[self step.
		^RBOptimizedToken start: tokenStart].
	self scannerError: 'Expecting parentheses'
    ]

    scanFraction: ch num: num base: base return: aBlock [
	<category: 'private-scanning numbers'>
	| c scale result |
	c := ch.
	scale := 0.
	result := num.
	
	[[c == $_] whileTrue: 
		[self step.
		c := currentCharacter].
	c notNil and: [self isDigit: c base: base]] 
		whileTrue: 
		    [result := result * base + c digitValue.
		    self step.
		    c := currentCharacter.
		    scale := scale - 1].
	aBlock value: result value: scale
    ]

    scanNumberValue [
	<category: 'private-scanning numbers'>
	| isNegative base exponent scale ch num |
	isNegative := false.
	exponent := nil.

	"could be radix or base-10 mantissa"
	num := self scanDigits: currentCharacter base: 10.
	currentCharacter == $r 
	    ifTrue: 
		[base := num truncated.
		self step	"skip over 'r'".
		currentCharacter == $- 
		    ifTrue: 
			[isNegative := true.
			self step	"skip '-'"].
		(self isDigit: currentCharacter base: base) 
		    ifTrue: [num := self scanDigits: currentCharacter base: base]
		    ifFalse: [self error: 'malformed number']]
	    ifFalse: [base := 10].

	"Here we've either
	 a) parsed base, an 'r' and are sitting on the following character
	 b) parsed the integer part of the mantissa, and are sitting on the char
	 following it, or
	 c) parsed nothing and are sitting on a - sign."
	currentCharacter == $. 
	    ifTrue: 
		[(self isDigit: stream peek base: base)
		    ifTrue: 
			[self step.
			self 
			    scanFraction: currentCharacter
			    num: num
			    base: base
			    return: 
				[:n :s | 
				num := n.
				exponent := s]]].
	isNegative ifTrue: [num := num negated].
	currentCharacter == $s 
	    ifTrue: 
		[self step.
		currentCharacter isNil ifTrue: [currentCharacter := Character space].
		exponent isNil ifTrue: [exponent := 0].
		currentCharacter isDigit 
		    ifTrue: [scale := self scanDigits: currentCharacter base: 10]
		    ifFalse: 
			["Might sit on the beginning of an identifier such as 123stu,
			 or on a ScaledDecimal literal lacking the scale such as 123s"
			(currentCharacter == $_ or: [currentCharacter isLetter]) 
			    ifTrue: 
				[stream skip: -1.
				currentCharacter := $s]
			    ifFalse: [scale := exponent negated]].
		^num asScaledDecimal: exponent radix: base scale: scale].
	currentCharacter == $e 
	    ifTrue: [num := num asFloatE]
	    ifFalse: 
		[currentCharacter == $d 
		    ifTrue: [num := num asFloatD]
		    ifFalse: 
			[currentCharacter == $q 
			    ifTrue: [num := num asFloatQ]
			    ifFalse: 
				[^exponent isNil 
				    ifTrue: [num]
				    ifFalse: [num asFloat * (base raisedToInteger: exponent)]]]].
	ch := currentCharacter.
	self step.
	currentCharacter isNil ifTrue: [currentCharacter := Character space].
	(currentCharacter == $_ or: [currentCharacter isLetter]) 
	    ifTrue: 
		[stream skip: -1.
		currentCharacter := ch].
	exponent isNil ifTrue: [exponent := 0].
	currentCharacter == $- 
	    ifTrue: 
		[self step.
		exponent := exponent - (self scanDigits: currentCharacter base: 10)]
	    ifFalse: 
		[currentCharacter isDigit 
		    ifTrue: [exponent := exponent + (self scanDigits: currentCharacter base: 10)]].
	^num * (base raisedToInteger: exponent)
    ]

    scanAnySymbol [
	<category: 'private-scanning'>
	characterType == #alphabetic ifTrue: [^self scanSymbol].
	characterType == #binary ifTrue: [^self scanBinary: RBLiteralToken].
	^RBToken new
    ]

    scanBinary: aClass [
	"This doesn't parse according to the ANSI draft. It only parses 1 or 2 letter binary tokens."

	<category: 'private-scanning'>
	| val |
	buffer nextPut: currentCharacter.
	self step.
	(characterType == #binary and: [currentCharacter ~~ $-]) 
	    ifTrue: 
		[buffer nextPut: currentCharacter.
		self step].
	val := buffer contents.
	val := val asSymbol.
	^aClass value: val start: tokenStart
    ]

    scanByteArray [
	<category: 'private-scanning'>
	| byteStream number |
	byteStream := WriteStream on: (ByteArray new: 100).
	self step.
	
	[self stripSeparators.
	characterType == #digit] whileTrue: 
		    [number := self scanNumber value.
		    (number isInteger and: [number between: 0 and: 255]) 
			ifFalse: [self scannerError: 'Expecting 8-bit integer'].
		    byteStream nextPut: number].
	currentCharacter == $] ifFalse: [self scannerError: ''']'' expected'].
	self step.	"]"
	^RBLiteralToken 
	    value: byteStream contents
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanIdentifierOrKeyword [
	<category: 'private-scanning'>
	| tokenType token |
	currentCharacter == $_ ifTrue: [^self scanAssignment].
	self scanName.
	token := self scanNamespaceName.
	token isNil 
	    ifTrue: 
		[tokenType := (currentCharacter == $: and: [stream peek ~~ $=]) 
			    ifTrue: 
				[buffer nextPut: currentCharacter.
				self step.	":"
				RBKeywordToken]
			    ifFalse: [RBIdentifierToken].
		token := tokenType value: buffer contents start: tokenStart].
	^token
    ]

    scanNamespaceName [
	<category: 'private-scanning'>
	| token |
	currentCharacter == $. 
	    ifTrue: 
		[(stream atEnd or: [(self classify: stream peek) ~~ #alphabetic]) 
		    ifTrue: [^nil]]
	    ifFalse: 
		[(currentCharacter == $: and: [stream peek == $:]) ifFalse: [^nil].
		self step].
	buffer nextPut: $..
	self step.
	self scanName.
	token := self scanNamespaceName.
	token isNil 
	    ifTrue: [token := RBIdentifierToken value: buffer contents start: tokenStart].
	^token
    ]

    scanLiteral [
	<category: 'private-scanning'>
	self step.
	self stripSeparators.
	characterType == #alphabetic ifTrue: [^self scanSymbol].
	characterType == #binary 
	    ifTrue: [^(self scanBinary: RBLiteralToken) stop: self previousStepPosition].
	currentCharacter == $' ifTrue: [^self scanStringSymbol].
	currentCharacter == $( ifTrue: [^self scanLiteralArray].
	currentCharacter == $[ ifTrue: [^self scanByteArray].
	currentCharacter == ${ ifTrue: [^self scanQualifier].
	currentCharacter == $# ifTrue: [^self scanExtendedLiterals].
	self scannerError: 'Expecting a literal type'
    ]

    scanLiteralArray [
	<category: 'private-scanning'>
	| arrayStream start |
	arrayStream := WriteStream on: (Array new: 10).
	self step.
	start := tokenStart.
	
	[self stripSeparators.
	tokenStart := stream position.
	currentCharacter == $)] 
		whileFalse: 
		    [arrayStream nextPut: self scanLiteralArrayParts.
		    buffer reset].
	self step.
	^RBLiteralToken 
	    value: arrayStream contents
	    start: start
	    stop: self previousStepPosition
    ]

    scanLiteralArrayParts [
	<category: 'private-scanning'>
	currentCharacter == $# ifTrue: [^self scanLiteral].
	characterType == #alphabetic 
	    ifTrue: 
		[| token value |
		token := self scanSymbol.
		value := token value.
		value == #nil ifTrue: [token value: nil].
		value == #true ifTrue: [token value: true].
		value == #false ifTrue: [token value: false].
		^token].
	(characterType == #digit 
	    or: [currentCharacter == $- and: [(self classify: stream peek) == #digit]]) 
		ifTrue: [^self scanNumber].
	characterType == #binary 
	    ifTrue: [^(self scanBinary: RBLiteralToken) stop: self previousStepPosition].
	currentCharacter == $' ifTrue: [^self scanLiteralString].
	currentCharacter == $$ ifTrue: [^self scanLiteralCharacter].
	currentCharacter == $( ifTrue: [^self scanLiteralArray].
	currentCharacter == $[ ifTrue: [^self scanByteArray].
	^self scannerError: 'Unknown character in literal array'
    ]

    scanLiteralCharacter [
	<category: 'private-scanning'>
	| token value char tokenStop |
	self step.	"$"
	tokenStop := stream position.
	char := currentCharacter.
	self step.	"char"
	char = $< 
	    ifTrue: 
		[self stripSeparators.
		characterType == #digit 
		    ifTrue: 
			[value := self scanNumberValue.
			(value isInteger and: [value between: 0 and: 1114111]) 
			    ifFalse: [^self scannerError: 'Integer between 0 and 16r10FFFF expected'].
			char := Character codePoint: value.
			self stripSeparators.
			tokenStop := stream position.
			currentCharacter = $> 
			    ifTrue: [self step]
			    ifFalse: [^self scannerError: '''>'' expected']]].
	^RBLiteralToken 
	    value: char
	    start: tokenStart
	    stop: tokenStop
    ]

    scanLiteralString [
	<category: 'private-scanning'>
	self step.
	
	[currentCharacter isNil 
	    ifTrue: [self scannerError: 'Unmatched '' in string literal.'].
	currentCharacter == $' and: [self step ~~ $']] 
		whileFalse: 
		    [buffer nextPut: currentCharacter.
		    self step].
	^RBLiteralToken 
	    value: buffer contents
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanPatternVariable [
	<category: 'private-scanning'>
	buffer nextPut: currentCharacter.
	self step.
	currentCharacter == ${ 
	    ifTrue: 
		[self step.
		^RBPatternBlockToken value: '`{' start: tokenStart].
	[characterType == #alphabetic] whileFalse: 
		[characterType == #eof 
		    ifTrue: [self scannerError: 'Pattern variable expected'].
		buffer nextPut: currentCharacter.
		self step].
	^self scanIdentifierOrKeyword
    ]

    scanName [
	<category: 'private-scanning'>
	[characterType == #alphabetic or: [characterType == #digit]] whileTrue: 
		[buffer nextPut: currentCharacter.
		self step]
    ]

    scanNumber [
	<category: 'private-scanning'>
	^RBLiteralToken 
	    value: self scanNumberValue
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanQualifier [
	<category: 'private-scanning'>
	| nameStream |
	self step.	"{"
	nameStream := WriteStream on: (String new: 10).
	[currentCharacter == $}] whileFalse: 
		[nameStream nextPut: currentCharacter.
		self step].
	self step.	"}"
	^RBBindingToken 
	    value: nameStream contents
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanAssignment [
	<category: 'private-scanning'>
	self step.
	^RBAssignmentToken start: tokenStart
    ]

    scanSpecialCharacter [
	<category: 'private-scanning'>
	| character |
	currentCharacter == $: 
	    ifTrue: 
		[self step.
		^currentCharacter == $= 
		    ifTrue: [self scanAssignment]
		    ifFalse: [RBSpecialCharacterToken value: $: start: tokenStart]].
	character := currentCharacter.
	self step.
	^RBSpecialCharacterToken value: character start: tokenStart
    ]

    scanStringSymbol [
	<category: 'private-scanning'>
	| literalToken |
	literalToken := self scanLiteralString.
	literalToken value: literalToken value asSymbol.
	^literalToken
    ]

    scanSymbol [
	<category: 'private-scanning'>
	| lastPosition hasColon value startPosition |
	hasColon := false.
	startPosition := lastPosition := stream position.
	[characterType == #alphabetic] whileTrue: 
		[self scanName.
		currentCharacter == $: 
		    ifTrue: 
			[buffer nextPut: $:.
			hasColon := true.
			lastPosition := stream position.
			self step]].
	value := buffer contents.
	(hasColon and: [value last ~~ $:]) 
	    ifTrue: 
		[stream position: lastPosition.
		self step.
		value := value copyFrom: 1 to: lastPosition - startPosition + 1].
	^RBLiteralToken 
	    value: value asSymbol
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    stripComment [
	<category: 'private-scanning'>
	| start stop |
	start := stream position.
	[self step == $"] whileFalse: 
		[characterType == #eof 
		    ifTrue: [self scannerError: 'Unmatched " in comment.']].
	stop := stream position.
	self step.
	saveComments ifFalse: [^self].
	comments add: (start to: stop)
    ]

    stripSeparators [
	<category: 'private-scanning'>
	
	[[characterType == #separator] whileTrue: [self step].
	currentCharacter == $"] 
		whileTrue: [self stripComment]
    ]

    atEnd [
	<category: 'testing'>
	^characterType == #eof
    ]

    isReadable [
	<category: 'testing'>
	^true
    ]

    isWritable [
	<category: 'testing'>
	^false
    ]
]



RBParser subclass: RBBracketedMethodParser [

    <category: 'Refactory-Parser'>
    <comment: 'A subclass of RBParser that discards a pair of brackets around
methods.'>

    skipToken: tokenValue [
        currentToken isValue ifFalse: [^false].
        (currentToken value = tokenValue)
            ifTrue: [self step. ^true]
            ifFalse: [^false]
    ]

    skipExpectedToken: tokenValue [
        (self skipToken: tokenValue)
            ifFalse: [self parserError: ('expected ' , tokenValue asSymbol)]
    ]

    parseMethodInto: methodNode [
        <category: 'private-parsing'>
        self skipExpectedToken: $[.
       super parseMethodInto: methodNode.
        self skipExpectedToken: $].
        ^methodNode
    ]
]


Eval [
    RBScanner initialize
]
