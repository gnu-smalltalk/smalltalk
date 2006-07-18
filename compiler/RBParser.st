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



Object subclass: #RBParser
    instanceVariableNames: 'scanner currentToken nextToken errorBlock tags source '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBParser methodsFor: 'accessing'!

errorBlock: aBlock 
    errorBlock := aBlock.
    scanner notNil ifTrue: [scanner errorBlock: aBlock]!

initializeParserWith: aString type: aSymbol 
    source := aString.
    self scanner: (self scannerClass perform: aSymbol
		with: (ReadStream on: aString)
		with: self errorBlock)!

initializeParserWithStream: aStream type: aSymbol 
    source := nil.
    self scanner: (self scannerClass perform: aSymbol
		with: aStream
		with: self errorBlock)!

parseExpression
    | node |
    node := self parseStatements: false.
    self atEnd ifFalse: [self parserError: 'Unknown input at end'].
    ^node!

parseSmalltalk
    [ self parseDoits ]
        whileTrue: [ self parseMethodDefinitionList ].

    ^self result!

parseMethod: aString 
    | node |
    node := self parseMethod.
    self atEnd ifFalse: [self parserError: 'Unknown input at end'].
    node source: aString.
    ^node!

scannerClass
    ^RBScanner! !

!RBParser methodsFor: 'error handling'!

errorBlock
    ^errorBlock isNil
	ifTrue: [[:message :position | ]]
	ifFalse: [errorBlock]!

errorPosition
    ^currentToken start!

parserWarning: aString 
    "Raise a Warning"

    Warning signal: aString!

parserError: aString 
    "Evaluate the block. If it returns raise an error"

    self errorBlock value: aString value: self errorPosition.
    self error: aString! !

!RBParser methodsFor: 'initialize-release'!

scanner: aScanner 
    scanner := aScanner.
    tags := nil.
    self step! !

!RBParser methodsFor: 'private'!

addCommentsTo: aNode
    aNode comments: scanner getComments!

nextToken
    ^nextToken isNil
	ifTrue: [nextToken := scanner next]
	ifFalse: [nextToken]!

step
    nextToken notNil ifTrue: 
	    [currentToken := nextToken.
	    nextToken := nil.
	    ^currentToken].
    currentToken := scanner next! !

!RBParser methodsFor: 'private-parsing'!

parseArgs
    | args |
    args := OrderedCollection new.
    [currentToken isIdentifier]
	whileTrue: [args add: self parseVariableNode].
    ^args!

parseArrayConstructor
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
    ^node!

parseAssignment
    "Need one token lookahead to see if we have a ':='. This method could 
    make it possible to assign the literals true, false and nil."

    | node position |
    (currentToken isIdentifier and: [self nextToken isAssignment])
	ifFalse: [^self parseCascadeMessage].
    node := self parseVariableNode.
    position := currentToken start.
    self step.
    ^RBAssignmentNode variable: node
	value: self parseAssignment
	position: position!

parseBinaryMessage
    | node |
    node := self parseUnaryMessage.
    
    [ currentToken isBinary]
	    whileTrue: [node := self parseBinaryMessageWith: node].
    ^node!

parseBinaryMessageWith: aNode 
    | binaryToken |
    binaryToken := currentToken.
    self step.
    ^RBMessageNode receiver: aNode
	selectorParts: (Array with: binaryToken)
	arguments: (Array with: self parseUnaryMessage)!

parseBinaryPattern
    | binaryToken |
    currentToken isBinary
	ifFalse: [self parserError: 'Message pattern expected'].
    binaryToken := currentToken.
    self step.
    ^RBMethodNode selectorParts: (Array with: binaryToken)
	arguments: (Array with: self parseVariableNode)!

parseBlock
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
    ^node!

parseBlockArgsInto: node
    | verticalBar args colons |
    args := OrderedCollection new: 2.
    colons := OrderedCollection new: 2.
    verticalBar := false.
    [currentToken isSpecial and: [currentToken value == $:]] whileTrue: 
	    [colons add: currentToken start.
	    self step.    ":"
	    verticalBar := true.
	    args add: self parseVariableNode].
    verticalBar ifTrue: 
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

				    currentToken value: #|;
					start: currentToken start + 1]
				ifFalse: [self parserError: '''|'' expected']]]
		ifFalse: 
		    [(currentToken isSpecial and: [currentToken value == $]])
			ifFalse: [self parserError: '''|'' expected']]].
    node arguments: args;
	colons: colons.
    ^node!

parseCascadeMessage
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
    ^RBCascadeNode messages: messages semicolons: semicolons!

parseDoits
    " Parses the stuff to be executed until a
        ! <class expression> methodsFor: <category string> ! "

    | node |

    [
	self atEnd ifTrue: [ ^false ].
        node := self parseStatements: false.
        self step.           "gobble doit terminating bang"
	node statements size > 0 and: [ self evaluate: node ]
    ]   whileFalse.
    ^true
!

parseKeywordMessage
    ^self parseKeywordMessageWith: self parseBinaryMessage!

parseKeywordMessageWith: node 
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
	    [RBMessageNode receiver: node
		selectorParts: keywords
		arguments: args]
	ifFalse: [node]!

parseKeywordPattern
    | keywords args |
    keywords := OrderedCollection new: 2.
    args := OrderedCollection new: 2.
    [currentToken isKeyword] whileTrue: 
	    [keywords add: currentToken.
	    self step.
	    args add: self parseVariableNode].
    ^RBMethodNode selectorParts: keywords arguments: args!

parseMessagePattern
    ^currentToken isIdentifier
	ifTrue: [self parseUnaryPattern]
	ifFalse: 
	    [currentToken isKeyword
		ifTrue: [self parseKeywordPattern]
		ifFalse: [self parseBinaryPattern]]!

parseMethod
    | methodNode |
    methodNode := self parseMessagePattern.
    self parseResourceTag.
    self addCommentsTo: methodNode.
    methodNode body: (self parseStatements: true).
    methodNode tags: tags.
    ^methodNode!

parseMethodDefinitionList
    "Called after first !, expecting a set of bang terminated
     method definitions, followed by a bang"

    | node start stop |

    [   scanner atEnd or: [ currentToken isSpecial
	   and: [ currentToken value == $! ] ] ] whileFalse: [

	start := currentToken start - 1.
        node := self parseMethod.

        "One -1 accounts for base-1 vs. base-0 (as above), the
         other drops the bang because we have a one-token lookahead."
	stop := currentToken start - 2.
        node source: (scanner stream segmentFrom: start to: stop).

        self step.           "gobble method terminating bang"
        self compile: node
    ].
    self step.
    self endMethodList
!

parseOptimizedExpression
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
    ^node!

parseParenthesizedExpression
    | leftParen node |
    leftParen := currentToken start.
    self step.
    node := self parseAssignment.
    ^(currentToken isSpecial and: [currentToken value == $)])
	ifTrue: 
	    [node addParenthesis: (leftParen to: currentToken start).
	    self step.
	    node]
	ifFalse: [self parserError: ''')'' expected']!

parsePatternBlock
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
    ^node!

parsePrimitiveIdentifier
    | value token |
    token := currentToken.
    value := currentToken value.
    self step.
    value = 'true' ifTrue: 
	    [^RBLiteralNode literalToken: (RBLiteralToken value: true
			start: token start
			stop: token start + 3)].
    value = 'false' ifTrue: 
	    [^RBLiteralNode literalToken: (RBLiteralToken value: false
			start: token start
			stop: token start + 4)].
    value = 'nil' ifTrue: 
	    [^RBLiteralNode literalToken: (RBLiteralToken value: nil
			start: token start
			stop: token start + 2)].
    ^RBVariableNode identifierToken: token!

parsePrimitiveLiteral
    | token |
    token := currentToken.
    self step.
    ^RBLiteralNode literalToken: token!

parsePrimitiveObject
    currentToken isIdentifier ifTrue: [^self parsePrimitiveIdentifier].
    currentToken isLiteral ifTrue: [^self parsePrimitiveLiteral].
    currentToken isSpecial ifTrue: 
	    [currentToken value == $[ ifTrue: [^self parseBlock].
	    currentToken value == ${ ifTrue: [^self parseArrayConstructor].
	    currentToken value == $( ifTrue: [^self parseParenthesizedExpression]].
    currentToken isPatternBlock ifTrue: [^self parsePatternBlock].
    currentToken isOptimized ifTrue: [^self parseOptimizedExpression].
    self parserError: 'Variable expected'!

parseResourceTag
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
	    self step]!

parseStatementList: tagBoolean into: sequenceNode 
    | statements return periods returnPosition node |
    return := false.
    statements := OrderedCollection new.
    periods := OrderedCollection new.
    self addCommentsTo: sequenceNode.
    tagBoolean ifTrue: [self parseResourceTag].

    [self atEnd 
	or: [currentToken isSpecial and: ['!])}' includes: currentToken value]]] 
	    whileFalse: 
		[return ifTrue: [self parserError: 'End of statement list encounted'].
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
		    ifFalse: [ return := true]].
    sequenceNode
	statements: statements;
	periods: periods.
    ^sequenceNode!

parseStatements: tagBoolean 
    | args leftBar rightBar |
    args := #().
    leftBar := rightBar := nil.
    currentToken isBinary ifTrue: [currentToken value == #|
	    ifTrue: 
		[leftBar := currentToken start.
		self step.
		args := self parseArgs.
		(currentToken isBinary and: [currentToken value = #|])
		    ifFalse: [self parserError: '''|'' expected'].
		rightBar := currentToken start.
		self step]
	    ifFalse: [currentToken value == #'||' 
		    ifTrue: 
			[rightBar := (leftBar := currentToken start) + 1.
			self step]]].
    ^self parseStatementList: tagBoolean into: (RBSequenceNode
	    leftBar: leftBar
	    temporaries: args
	    rightBar: rightBar)!

parseUnaryMessage
    | node |
    node := self parsePrimitiveObject.
    [currentToken isIdentifier]
	whileTrue: [node := self parseUnaryMessageWith: node].
    ^node!

parseUnaryMessageWith: aNode 
    | selector |
    selector := currentToken.
    self step.
    ^RBMessageNode receiver: aNode
	selectorParts: (Array with: selector)
	arguments: #()!

parseUnaryPattern
    | selector |
    selector := currentToken.
    self step.
    ^RBMethodNode selectorParts: (Array with: selector) arguments: #()!

parseVariableNode
    | node |
    currentToken isIdentifier
	ifFalse: [self parserError: 'Variable name expected'].
    node := RBVariableNode identifierToken: currentToken.
    self step.
    ^node! !

!RBParser methodsFor: 'overridable - parsing file-ins'!

compile: node
    "do nothing by default"
!

endMethodList
    "do nothing by default"
!

evaluate: node
    "This should be overridden because its result affects the parsing
     process: true means 'start parsing methods', false means 'keep
     evaluating'. By default, always answer false."
    ^false
! !

!RBParser methodsFor: 'testing'!

atEnd
    ^currentToken class == RBToken! !

RBParser class
    instanceVariableNames: ''!



!RBParser class methodsFor: 'accessing'!

parseExpression: aString 
    ^self parseExpression: aString onError: nil!

parseExpression: aString onError: aBlock 
    | node parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWith: aString type: #on:errorBlock:.
    node := parser parseExpression.
    ^(node statements size == 1 and: [node temporaries isEmpty])
	ifTrue: [node statements first]
	ifFalse: [node]!

parseMethod: aString 
    ^self parseMethod: aString onError: nil!

parseMethod: aString onError: aBlock 
    | parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWith: aString type: #on:errorBlock:.
    ^parser parseMethod: aString!

parseRewriteExpression: aString 
    ^self parseRewriteExpression: aString onError: nil!

parseRewriteExpression: aString onError: aBlock 
    | node parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWith: aString type: #rewriteOn:errorBlock:.
    node := parser parseExpression.
    ^(node statements size == 1 and: [node temporaries isEmpty])
	ifTrue: [node statements first]
	ifFalse: [node]!

parseRewriteMethod: aString 
    ^self parseRewriteMethod: aString onError: nil!

parseRewriteMethod: aString onError: aBlock 
    | parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWith: aString type: #rewriteOn:errorBlock:.
    ^parser parseMethod: aString!

parseSmalltalk: aString 
    ^self parseSmalltalk: aString onError: nil!

parseSmalltalk: aString onError: aBlock 
    | parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWith: aString type: #on:errorBlock:.
    parser parseSmalltalk.
    ^parser result!

parseSmalltalkStream: aStream 
    ^self parseSmalltalkStream: aStream onError: nil!

parseSmalltalkStream: aStream onError: aBlock 
    | parser |
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWithStream: aStream type: #on:errorBlock:.
    parser parseSmalltalk.
    ^parser result!

parseSmalltalkFileIn: aFilename
    ^self parseSmalltalkFileIn: aFilename onError: nil!

parseSmalltalkFileIn: aFilename onError: aBlock 
    | parser file |
    file := FileStream open: aFilename mode: FileStream read.
    parser := self new.
    parser errorBlock: aBlock.
    parser initializeParserWithStream: file type: #on:errorBlock:.
    parser parseSmalltalk.
    ^parser result!

!RBParser class methodsFor: 'parsing'!

parseMethodPattern: aString 
    | parser |
    parser := self new.
    parser errorBlock: [:error :position | ^nil].
    parser initializeParserWith: aString type: #on:errorBlock:.
    ^parser parseMessagePattern selector! !


Stream subclass: #RBScanner
    instanceVariableNames: 'stream buffer tokenStart currentCharacter characterType classificationTable saveComments comments extendedLanguage errorBlock '
    classVariableNames: 'ClassificationTable PatternVariableCharacter '
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBScanner methodsFor: 'accessing'!

classificationTable: anObject
    classificationTable := anObject!

contents
    | contentsStream |
    contentsStream := WriteStream on: (Array new: 50).
    self do: [:each | contentsStream nextPut: each].
    ^contentsStream contents!

errorBlock: aBlock 
    errorBlock := aBlock!

extendedLanguage
    ^extendedLanguage!

extendedLanguage: aBoolean 
    extendedLanguage := aBoolean!

flush!

getComments
    | oldComments |
    comments isEmpty ifTrue: [^nil].
    oldComments := comments.
    comments := OrderedCollection new: 1.
    ^oldComments!

ignoreComments
    saveComments := false!

next
    | token |
    buffer reset.
    tokenStart := stream position.
    characterType == #eof ifTrue: [^RBToken start: tokenStart + 1].    "The EOF token should occur after the end of input"
    token := self scanToken.
    self stripSeparators.
    ^token!

nextPut: anObject 
    "Provide an error notification that the receiver does not
    implement this message."

    self shouldNotImplement!

saveComments
    saveComments := true!

scanToken
    "fast-n-ugly. Don't write stuff like this. Has been found to cause cancer in laboratory rats. Basically a 
    case statement. Didn't use Dictionary because lookup is pretty slow."

    characterType == #alphabetic ifTrue: [^self scanIdentifierOrKeyword].
    (characterType == #digit
	or: [currentCharacter == $- and: [(self classify: stream peek) == #digit]])
	    ifTrue: [^self scanNumber].
    characterType == #binary ifTrue: [^self scanBinary: RBBinarySelectorToken].
    characterType == #special ifTrue: [^self scanSpecialCharacter].
    currentCharacter == $' ifTrue: [^self scanLiteralString].
    currentCharacter == $# ifTrue: [^self scanLiteral].
    currentCharacter == $$ ifTrue: [^self scanLiteralCharacter].
    (extendedLanguage and: [currentCharacter == PatternVariableCharacter])
	ifTrue: [^self scanPatternVariable].
    ^self scannerError: 'Unknown character'!

position
    ^stream position!

stream
    ^stream! !

!RBScanner methodsFor: 'error handling'!

errorBlock
    ^errorBlock isNil
	ifTrue: [[:message :position | ]]
	ifFalse: [errorBlock]!

errorPosition
    ^stream position!

scannerError: aString 
    "Evaluate the block. If it returns raise an error"

    self errorBlock value: aString value: self errorPosition.
    self error: aString! !

!RBScanner methodsFor: 'initialize-release'!

on: aStream 
    buffer := WriteStream on: (String new: 60).
    stream := aStream.
    classificationTable := self class classificationTable.
    saveComments := true.
    extendedLanguage := false.
    comments := OrderedCollection new! !

!RBScanner methodsFor: 'private'!

classify: aCharacter 
    | index |
    aCharacter isNil ifTrue: [^nil].
    index := aCharacter asInteger.
    index == 0 ifTrue: [^#separator].
    index > 255 ifTrue: [^nil].
    ^classificationTable at: index!

previousStepPosition
    ^characterType == #eof 
	ifTrue: [stream position]
	ifFalse: [stream position - 1]!

step
    stream atEnd ifTrue: 
	    [characterType := #eof.
	    ^currentCharacter := nil].
    currentCharacter := stream next.
    characterType := self classify: currentCharacter.
    ^currentCharacter! !

!RBScanner methodsFor: 'private-scanning numbers'!

isDigit: aChar base: base
    aChar isNil ifTrue: [ ^false ].

    base <= 10 ifTrue: [
        aChar isDigit ifFalse: [ ^false ].
        ^(aChar value - $0 value) < base
    ].

    ^aChar isUppercase
        ifTrue: [ (aChar value - $A value) < (base - 10) ]
        ifFalse: [ aChar isDigit ]!

scanDigits: ch base: base
    | c num |
    c := ch.
    num := 0.
    [
        [ c == $_ ] whileTrue: [ self step. c := currentCharacter ].
        c notNil and: [ self isDigit: c base: base ]
    ] whileTrue: [
        num := num * base + c digitValue.
        self step.
        c := currentCharacter
    ].
    ^num!

scanExtendedLiterals
    | token |
    self step.
    currentCharacter == $( 
    	ifTrue: 
       	    [self step.
	    ^RBOptimizedToken start: tokenStart].

    self scannerError: 'Expecting parentheses'!

scanFraction: ch num: num base: base return: aBlock
    | c scale result |
    c := ch.
    scale := 0.
    result := num.
    [
        [ c == $_ ] whileTrue: [ self step. c := currentCharacter ].
        c notNil and: [ self isDigit: c base: base ]
    ] whileTrue: [ result := result * base + c digitValue.
        self step.
        c := currentCharacter.
        scale := scale - 1.
    ].
    aBlock value: result value: scale!

scanNumberValue
    | mantissaParsed isNegative base exponent scale ch num |
    mantissaParsed := isNegative := false.

    base := 10.
    exponent := nil.

    currentCharacter == $- ifFalse: [ "could be radix"
        num := self scanDigits: currentCharacter base: 10.
        currentCharacter == $r
            ifTrue: [ base := num truncated.
                      self step. "skip over 'r'" ]
            ifFalse: [ mantissaParsed := true ] ].

    "Here we've either
     a) parsed base, an 'r' and are sitting on the following character
     b) parsed the integer part of the mantissa, and are sitting on the char
        following it, or
     c) parsed nothing and are sitting on a - sign."

    currentCharacter == $- ifTrue: [
        mantissaParsed ifTrue: [ ^num ].
        isNegative := true.
        self step.          "skip '-'"
    ].

    mantissaParsed ifFalse: [
	 (self isDigit: currentCharacter base: base)
	     ifTrue: [ num := self scanDigits: currentCharacter base: base ]
             ifFalse: [ self error: 'malformed number' ]
    ].

    currentCharacter == $. ifTrue: [
        stream peek isDigit
            ifTrue: [
	        self step.
                self scanFraction: currentCharacter
                     num: num
                     base: base
                     return: [ :n :s | num := n. exponent := s ].
            ]
    ].

    isNegative ifTrue: [ num := num negated ].

    currentCharacter == $s ifTrue: [
        self step.

        currentCharacter isNil ifTrue: [ currentCharacter := Character space ].
        currentCharacter isDigit
            ifTrue: [ scale := self scanDigits: ch base: 10 ]
            ifFalse: [
		exponent isNil ifTrue: [ exponent := 0 ].

                "Might sit on the beginning of an identifier such as 123stu,
                 or on a ScaledDecimal literal lacking the scale such as 123s"
                (currentCharacter == $_ or: [ currentCharacter isLetter ])
                    ifTrue: [ stream skip: -1. currentCharacter := $s ]
                    ifFalse: [ scale := exponent negated ]
            ].

        ^num asScaledDecimal: exponent scale: scale
    ].

    currentCharacter == $e ifTrue: [ num := num asFloatE ] ifFalse: [
    currentCharacter == $d ifTrue: [ num := num asFloatD ] ifFalse: [
    currentCharacter == $q ifTrue: [ num := num asFloatQ ] ifFalse: [
	^exponent isNil
	    ifTrue: [ num ]
	    ifFalse: [ num asFloatE * (base raisedToInteger: exponent) ]
    ]]].

    ch := currentCharacter.
    self step.
    currentCharacter isNil ifTrue: [ currentCharacter := Character space ].

    (currentCharacter == $_ or: [ currentCharacter isLetter ])
        ifTrue: [ stream skip: -1. currentCharacter := ch ].

    exponent isNil ifTrue: [ exponent := 0 ].
    currentCharacter == $-
        ifTrue: [
	    self step.
            exponent := exponent -
                (self scanDigits: currentCharacter base: 10).
        ]
        ifFalse: [
    	    currentCharacter isDigit ifTrue: [
                exponent := exponent +
                    (self scanDigits: currentCharacter base: 10).
            ].
        ].

    ^num * (base raisedToInteger: exponent)
! !

!RBScanner methodsFor: 'private-scanning'!

scanAnySymbol
    characterType == #alphabetic ifTrue: [^self scanSymbol].
    characterType == #binary ifTrue: [^self scanBinary: RBLiteralToken].
    ^RBToken new!

scanBinary: aClass 
    "This doesn't parse according to the ANSI draft. It only parses 1 or 2 letter binary tokens."

    | val |
    buffer nextPut: currentCharacter.
    self step.
    (characterType == #binary and: [currentCharacter ~~ $-]) ifTrue: 
	    [buffer nextPut: currentCharacter.
	    self step].
    val := buffer contents.
    val := val asSymbol.
    ^aClass value: val start: tokenStart!

scanByteArray
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
    self step.    "]"
    ^RBLiteralToken 
	value: byteStream contents
	start: tokenStart
	stop: self previousStepPosition!

scanIdentifierOrKeyword
    | tokenType token |
    self scanName.
    token := self scanNamespaceName.

    token isNil
	ifTrue: [
	    tokenType := (currentCharacter == $: and: [stream peek ~~ $=]) 
	        ifTrue: 
	            [buffer nextPut: currentCharacter.
	            self step.    ":"
	            RBKeywordToken]
	        ifFalse: [RBIdentifierToken].

	    token := tokenType value: buffer contents start: tokenStart
	].

    ^token!

scanNamespaceName
    | token |
    currentCharacter == $.
        ifTrue:
            [(stream atEnd or: [(self classify: stream peek) ~~ #alphabetic])
                ifTrue: [^nil]]
        ifFalse:
            [(currentCharacter == $: and: [stream peek == $:])
		ifFalse: [^nil].
	    self step].

    buffer nextPut: $. .
    self step.
    self scanName.

    token := self scanNamespaceName.
    token isNil ifTrue: [
        token := RBIdentifierToken value: buffer contents start: tokenStart ].

    ^token!

scanLiteral
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
    self scannerError: 'Expecting a literal type'!

scanLiteralArray
    | arrayStream start |
    arrayStream := WriteStream on: (Array new: 10).
    self step.
    start := tokenStart.
    
    [self stripSeparators.
    tokenStart := stream position.
    currentCharacter == $)] whileFalse: 
		[arrayStream nextPut: self scanLiteralArrayParts.
		buffer reset].
    self step.
    ^RBLiteralToken 
	value: arrayStream contents
	start: start
	stop: self previousStepPosition!

scanLiteralArrayParts
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
    ^self scannerError: 'Unknown character in literal array'!

scanLiteralCharacter
    | token value char tokenStop |
    self step.    "$"
    tokenStop := stream position.
    char := currentCharacter.
    self step.    "char"
    char = $< ifTrue: [
	self stripSeparators.
	characterType == #digit ifTrue: [
	    value := self scanNumberValue.
	    (value isInteger and: [ value between: 0 and: 16r10FFFF ])
	        ifFalse: [ ^self scannerError: 'Integer between 0 and 16r10FFFF expected'].

	    char := Character codePoint: value.
	    self stripSeparators.
	    tokenStop := stream position.
	    currentCharacter = $>
		ifTrue: [ self step ]
		ifFalse: [ ^self scannerError: '''>'' expected' ] ] ].

    ^RBLiteralToken value: char
	start: tokenStart
	stop: tokenStop!

scanLiteralString
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
	stop: self previousStepPosition!

scanPatternVariable
    buffer nextPut: currentCharacter.
    self step.
    currentCharacter == ${
        ifTrue:
            [self step.
            ^RBPatternBlockToken value: '`{' start: tokenStart].
    [characterType == #alphabetic] whileFalse: 
	    [characterType == #eof ifTrue: [self scannerError: 'Pattern variable expected'].
	    buffer nextPut: currentCharacter.
	    self step].
    ^self scanIdentifierOrKeyword!

scanName
    [characterType == #alphabetic or: [characterType == #digit]] whileTrue: 
	    [buffer nextPut: currentCharacter.
	    self step]!

scanNumber
    ^RBLiteralToken 
	value: self scanNumberValue
	start: tokenStart
	stop: self previousStepPosition!

scanQualifier
    | nameStream |
    self step.    "{"
    nameStream := WriteStream on: (String new: 10).
    [currentCharacter == $}] whileFalse: 
	    [nameStream nextPut: currentCharacter.
	    self step].
    self step.    "}"
    ^RBBindingToken 
	value: nameStream contents
	start: tokenStart
	stop: self previousStepPosition!

scanSpecialCharacter
    | character |
    currentCharacter == $: ifTrue: 
	    [self step.
	    ^currentCharacter == $=
		ifTrue: 
		    [self step.
		    RBAssignmentToken start: tokenStart]
		ifFalse: [RBSpecialCharacterToken value: $: start: tokenStart]].
    character := currentCharacter.
    self step.
    ^RBSpecialCharacterToken value: character start: tokenStart!

scanStringSymbol
    | literalToken |
    literalToken := self scanLiteralString.
    literalToken value: literalToken value asSymbol.
    ^literalToken!

scanSymbol
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
	stop: self previousStepPosition!

stripComment
    | start stop |
    start := stream position.
    [self step == $"] whileFalse: 
	    [characterType == #eof
		ifTrue: [self scannerError: 'Unmatched " in comment.']].
    stop := stream position.
    self step.
    saveComments ifFalse: [^self].
    comments add: (start to: stop)!

stripSeparators
    [[characterType == #separator]
	whileTrue: [self step].
    currentCharacter == $"]
	whileTrue: [self stripComment]! !

!RBScanner methodsFor: 'testing'!

atEnd
    ^characterType == #eof!

isReadable
    ^true!

isWritable
    ^false! !

RBScanner class
    instanceVariableNames: ''!



!RBScanner class methodsFor: 'accessing'!

classificationTable
    ClassificationTable isNil ifTrue: [self initialize].
    ^ClassificationTable!

patternVariableCharacter
    ^PatternVariableCharacter! !

!RBScanner class methodsFor: 'class initialization'!

initialize
    PatternVariableCharacter := $`.
    ClassificationTable := Array new: 255.
    self initializeChars: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_' to: #alphabetic.
    self initializeChars: '01234567890' to: #digit.
    self initializeChars: '%&*+,-/<=>?@\~|' to: #binary.
    self initializeChars: '{}().:;[]^!' to: #special.
    #(9 10 12 13 26 32) do: [:i | ClassificationTable at: i put: #separator]!

initializeChars: characters to: aSymbol 
    characters do: [:c | ClassificationTable at: c asInteger put: aSymbol]! !

!RBScanner class methodsFor: 'instance creation'!

on: aStream
    | str |
    str := self basicNew on: aStream.
    str step.
    str stripSeparators.
    ^str!

on: aStream errorBlock: aBlock 
    | str |
    str := self basicNew on: aStream.
    str errorBlock: aBlock;
	step;
	stripSeparators.
    ^str!

rewriteOn: aStream 
    | str |
    str := self basicNew on: aStream.
    str extendedLanguage: true; ignoreComments.
    str step.
    str stripSeparators.
    ^str!

rewriteOn: aStream errorBlock: aBlock
    | str |
    str := self basicNew on: aStream.
    str extendedLanguage: true;
	ignoreComments;
	errorBlock: aBlock;
	step;
	stripSeparators.
    ^str! !

!RBScanner class methodsFor: 'testing'!

isSelector: aSymbol 
    | scanner token |
    scanner := self basicNew.
    scanner on: (ReadStream on: aSymbol asString).
    scanner step.
    token := scanner scanAnySymbol.
    token isLiteral ifFalse: [^false].
    token value isEmpty ifTrue: [^false].
    ^scanner atEnd!

isVariable: aString 
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
    ^scanner atEnd! !

RBScanner initialize!


!PositionableStream methodsFor: 'compiling'!

name
    "Answer a string that represents what the receiver is streaming on"
    ^'(%1 %2)' bindWith: self species article with: self species name
!

segmentFrom: startPos to: endPos
    "Answer an object that, when sent #asString, will yield the result
     of sending `copyFrom: startPos to: endPos' to the receiver"
    ^self copyFrom: startPos to: endPos
! !

!FileStream methodsFor: 'compiling'!

segmentFrom: startPos to: endPos
    "Answer an object that, when sent #asString, will yield the result
     of sending `copyFrom: startPos to: endPos' to the receiver"
    ^FileSegment
	on: self name
	startingAt: startPos
	for: endPos - startPos + 1.
! !

