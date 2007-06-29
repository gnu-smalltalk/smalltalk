"======================================================================
|
|   Refactoring Browser - Smalltalk code pretty-printer
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



RBProgramNodeVisitor subclass: #RBFormatter
    instanceVariableNames: 'codeStream lineStart firstLineLength tabs initialIndent '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!



!RBFormatter methodsFor: 'accessing'!

firstLineLength
    ^firstLineLength isNil
	ifTrue: [codeStream position]
	ifFalse: [firstLineLength]!

formatAll: anArray
    self formatStatements: anArray.
    ^codeStream contents!

format: aNode 
    self visitNode: aNode.
    ^codeStream contents!

initialIndent
    initialIndent isNil ifTrue: [ initialIndent := 0 ].
    ^initialIndent!

initialIndent: anInteger
    initialIndent := anInteger!

isMultiLine
    ^firstLineLength notNil!

lastLineLength
    ^codeStream position - (lineStart max: 0)! !

!RBFormatter methodsFor: 'copying'!

postCopy
    super postCopy.
    lineStart := self lineLength negated.
    codeStream := WriteStream on: (String new: 60).
    firstLineLength := nil! !

!RBFormatter methodsFor: 'initialize-release'!

initialize
    super initialize.
    codeStream := WriteStream on: (String new: 60).
    tabs := 0.
    lineStart := 0! !

!RBFormatter methodsFor: 'private'!

indent
    firstLineLength isNil ifTrue: [firstLineLength := codeStream position].
    codeStream nl.
    tabs // 2 timesRepeat: [codeStream tab].
    tabs odd ifTrue: [ codeStream next: 4 put: Character space ].
    lineStart := codeStream position!

indent: anInteger while: aBlock 
    tabs := tabs + anInteger.
    aBlock value.
    tabs := tabs - anInteger!

indentWhile: aBlock 
    self indent: 1 while: aBlock!

lineLength
    ^codeStream position - lineStart!

lineStart: aPosition 
    lineStart := aPosition!

maximumArgumentsPerLine
    ^2!

maxLineSize
    ^75!

needsParenthesisFor: aNode 
    | parent grandparent |
    aNode isValue ifFalse: [^false].
    parent := aNode parent.
    parent isNil ifTrue: [^false].
    (aNode isMessage and: [parent isMessage and: [parent receiver == aNode]])
	ifTrue: 
	    [grandparent := parent parent.
	    (grandparent notNil and: [grandparent isCascade]) ifTrue: [^true]].
    aNode precedence < parent precedence ifTrue: [^false].
    aNode isAssignment & parent isAssignment ifTrue: [^false].
    aNode isAssignment | aNode isCascade ifTrue: [^true].
    aNode precedence == 0 ifTrue: [^false].
    aNode isMessage ifFalse: [^true].
    aNode precedence = parent precedence ifFalse: [^true].
    aNode isUnary ifTrue: [^false].
    aNode isKeyword ifTrue: [^true].
    parent receiver == aNode ifFalse: [^true].
    ^self precedenceOf: parent selector greaterThan: aNode selector!

precedenceOf: parentSelector greaterThan: childSelector 
    "Put parenthesis around things that are preceived to have 'lower' precedence. For example, 'a + b * c' 
    -> '(a + b) * c' but 'a * b + c' -> 'a * b + c'"

    | childIndex parentIndex operators |
    operators := #(#($| $& $?) #($= $~ $< $>) #($- $+) #($* $/ $% $\) #($@)).
    childIndex := 0.
    parentIndex := 0.
    1 to: operators size
	do: 
	    [:i | 
	    ((operators at: i) includes: parentSelector first) ifTrue: [parentIndex := i].
	    ((operators at: i) includes: childSelector first) ifTrue: [childIndex := i]].
    ^childIndex < parentIndex!

selectorsToLeaveOnLine
    ^#(#to:do: #to:by: #to:by:do:)!

selectorsToStartOnNewLine
    ^#(#ifTrue:ifFalse: #ifFalse:ifTrue: #ifTrue: #ifFalse:)! !

!RBFormatter methodsFor: 'private-formatting'!

formatLiteral: token 
    | isArray aValue |
    
    aValue := token value.

    token isCompileTimeBound ifTrue: 
	    [codeStream nextPutAll: '#{';
		nextPutAll: aValue;
		nextPut: $}.
	    ^self].
	aValue class == Array ifTrue: 
		    [codeStream nextPutAll: '#('.
		    aValue
				do: [:each | self formatLiteral: each]
				separatedBy: [codeStream nextPut: $ ].
		    codeStream nextPut: $).
		    ^self].
	aValue class == ByteArray ifTrue: 
		    [codeStream nextPutAll: '#['.
		    aValue
				do: [:each | codeStream store: each]
				separatedBy: [codeStream nextPut: $ ].
			codeStream nextPut: $].
			^self].
    aValue isSymbol ifTrue: 
	    [self formatSymbol: aValue.
	    ^self].
    aValue class == Character ifTrue: 
	    [codeStream nextPut: $$;
		nextPut: aValue.
	    ^self].
    aValue class == String ifTrue: 
	    [codeStream nextPut: $';
		nextPutAll: (aValue copyReplaceAll: '''' with: '''''');
		nextPut: $'.
	    ^self].
    aValue storeOn: codeStream!

formatMessage: aMessageNode cascade: cascadeBoolean 
    | selectorParts arguments multiLine formattedArgs indentFirst firstArgLength length |
    selectorParts := aMessageNode selectorParts.
    arguments := aMessageNode arguments.
    formattedArgs := OrderedCollection new.
    multiLine := aMessageNode selector numArgs > self maximumArgumentsPerLine.
    length := aMessageNode selector size + arguments size + 1.
    firstArgLength := 0.
    self indentWhile: 
	    [1 to: arguments size
		do: 
		    [:i | 
		    | formatter string |
		    formatter := (self copy) 
				lineStart: (selectorParts at: i) length negated;
				yourself.
		    string := formatter format: (arguments at: i).
		    formattedArgs add: string.
		    i == 1 ifTrue: [firstArgLength := formatter firstLineLength].
		    length := length + string size.
		    multiLine := multiLine or: [formatter isMultiLine]]].
    multiLine := multiLine or: [length + self lineLength > self maxLineSize].
    indentFirst := cascadeBoolean not and: 
		    [multiLine and: 
			    [(self startMessageSendOnNewLine: aMessageNode) or: 
				    [self lineLength + selectorParts first length + 2 + firstArgLength 
					> self maxLineSize]]].
    indentFirst ifTrue: [self indent].
    self 
	formatMessageSelector: selectorParts
	withArguments: formattedArgs
	multiline: multiLine!

formatMessageSelector: selectorParts withArguments: formattedArgs multiline: multiLine 
    formattedArgs isEmpty 
	ifTrue: [codeStream nextPutAll: selectorParts first value]
	ifFalse: 
	    [1 to: formattedArgs size
		do: 
		    [:i | 
		    i ~~ 1 & multiLine not ifTrue: [codeStream nextPut: $ ].
		    codeStream 
			nextPutAll: (selectorParts at: i) value;
			nextPut: $ ;
			nextPutAll: (formattedArgs at: i).
		    (multiLine and: [i < formattedArgs size]) ifTrue: [self indent]]]!

formatComment: aString
    | stream |
    stream := ReadStream on: aString
	from: (aString findFirst: [ :each | each = $" ]) + 1
	to: (aString findLast: [ :each | each = $" ]) - 1.
    stream atEnd ifTrue: [ ^self ].
    codeStream nextPut: $".
    stream linesDo: [ :each |
	codeStream nextPutAll: each trimSeparators.
	stream atEnd ifFalse: [
	    self indent. codeStream space ] ].
    codeStream nextPut: $"!

formatMethodCommentFor: aNode indentBefore: aBoolean 
    | source |
    source := aNode source.
    source isNil ifTrue: [^self].
    aNode comments do: 
	    [:each | 
	    aBoolean ifTrue: [self indent].
	    self formatComment: (aNode source copyFrom: each first to: each last).
	    codeStream nl.
	    aBoolean ifFalse: [self indent]]!

formatMethodPatternFor: aMethodNode 
    | selectorParts arguments |
    selectorParts := aMethodNode selectorParts.
    arguments := aMethodNode arguments.
    arguments isEmpty
	ifTrue: [codeStream nextPutAll: selectorParts first value;
	                    nextPut: $ ]
	ifFalse: 
	    [selectorParts with: arguments
		do: 
		    [:selector :arg | 
		    codeStream nextPutAll: selector value;
			nextPut: $ .
		    self visitArgument: arg.
		    codeStream nextPut: $ ]]!

formatStatementCommentFor: aNode 
    | source |
    source := aNode source.
    source isNil ifTrue: [^self].
    aNode comments do: 
	    [:each | 
	    | crs |
	    crs := self newLinesFor: source startingAt: each first.
	    (crs - 1 max: 0) timesRepeat: [codeStream nl].
	    crs == 0 ifTrue: [codeStream tab] ifFalse: [self indent].
	    self formatComment: (source copyFrom: each first to: each last)]!

formatStatementsFor: aSequenceNode 
    self formatStatements: aSequenceNode statements!

formatStatements: statements
    statements isEmpty ifTrue: [^self].
    1 to: statements size - 1
	do: 
	    [:i | 
	    self visitNode: (statements at: i).
	    codeStream nextPut: $..
	    self formatStatementCommentFor: (statements at: i).
	    self indent].
    self visitNode: statements last.
    self formatStatementCommentFor: statements last!

formatSymbol: aSymbol 
    "Format the symbol, if its not a selector then we must put quotes around it. The and: case below, 
    handles the VisualWorks problem of not accepting two bars as a symbol."

    codeStream nextPut: $#.
    ((RBScanner isSelector: aSymbol) and: [aSymbol ~~ #'||'])
	ifTrue: [codeStream nextPutAll: aSymbol]
	ifFalse: [aSymbol asString printOn: codeStream]!

formatTagFor: aMethodNode 
    | primitiveSources |
    primitiveSources := aMethodNode primitiveSources.
    primitiveSources do: 
	    [:each | 
	    codeStream nextPutAll: each.
	    self indent]!

formatTemporariesFor: aSequenceNode 
    | temps |
    temps := aSequenceNode temporaries.
    temps isEmpty ifTrue: [^self].
    codeStream nextPutAll: '| '.
    temps do: 
	    [:each | 
	    self visitArgument: each.
	    codeStream nextPut: $ ].
    codeStream nextPut: $|.
    self indent!

newLinesFor: aString startingAt: anIndex 
    | count cr lf index char |
    cr := Character value: 13.
    lf := Character value: 10.
    count := 0.
    index := anIndex - 1.
    [index > 0 and: 
	    [char := aString at: index.
	    char isSeparator]] 
	whileTrue: 
	    [char == lf 
		ifTrue: 
		    [count := count + 1.
		    (aString at: (index - 1 max: 1)) == cr ifTrue: [index := index - 1]].
	    char == cr ifTrue: [count := count + 1].
	    index := index - 1].
    ^count! !

!RBFormatter methodsFor: 'testing'!

startMessageSendOnNewLine: aMessageNode 
    (self selectorsToStartOnNewLine includes: aMessageNode selector) 
	ifTrue: [^true].
    (self selectorsToLeaveOnLine includes: aMessageNode selector) ifTrue: [^false].
    ^aMessageNode selector numArgs > self maximumArgumentsPerLine! !

!RBFormatter methodsFor: 'visiting'!

visitNode: aNode 
    | parenthesis |
    parenthesis := self needsParenthesisFor: aNode.
    parenthesis ifTrue: [codeStream nextPut: $(].
    aNode acceptVisitor: self.
    parenthesis ifTrue: [codeStream nextPut: $)]! !

!RBFormatter methodsFor: 'visitor-double dispatching'!

acceptAssignmentNode: anAssignmentNode 
    self indent: 2
	while: 
	    [self visitNode: anAssignmentNode variable.
	    codeStream nextPutAll: ' := '.
	    self visitNode: anAssignmentNode value]!

acceptArrayConstructorNode: anArrayNode 
    | seqNode multiline formattedBody formatter |
    seqNode := anArrayNode body.
    formatter := (self copy) lineStart: 0;
		yourself.
    formattedBody := formatter format: seqNode.
    multiline := self lineLength + formattedBody size > self maxLineSize
		or: [formatter isMultiLine].
    multiline ifTrue: [self indent].
    codeStream nextPut: ${;
	nextPutAll: formattedBody;
	nextPut: $}!

acceptBlockNode: aBlockNode 
    | seqNode multiline formattedBody formatter |
    seqNode := aBlockNode body.
    formatter := (self copy) lineStart: 0;
		yourself.
    formattedBody := formatter format: seqNode.
    multiline := self lineLength + formattedBody size > self maxLineSize
		or: [formatter isMultiLine].
    multiline ifTrue: [self indent].
    codeStream nextPut: $[.
    aBlockNode arguments do: 
	    [:each | 
	    codeStream nextPut: $:.
	    self visitNode: each.
	    codeStream nextPut: $ ].
    aBlockNode arguments isEmpty ifFalse: 
	    [codeStream nextPutAll: '| '.
	    multiline ifTrue: [self indent]].
    codeStream nextPutAll: formattedBody;
	nextPut: $]!

acceptCascadeNode: aCascadeNode 
    | messages |
    messages := aCascadeNode messages.
    self visitNode: messages first receiver.
    self indentWhile: 
	    [messages
		do: 
		    [:each | 
		    self
			indent;
			indentWhile: [self formatMessage: each cascade: true]]
		separatedBy: [codeStream nextPut: $;]]!

acceptLiteralNode: aLiteralNode 
    ^self formatLiteral: aLiteralNode token!

acceptMessageNode: aMessageNode 
    | newFormatter code |
    newFormatter := self copy.
    code := newFormatter format: aMessageNode receiver.
    codeStream nextPutAll: code.
    codeStream nextPut: $ .
    newFormatter isMultiLine
	ifTrue: [lineStart := codeStream position - newFormatter lastLineLength].
    self indent: (newFormatter isMultiLine ifTrue: [2] ifFalse: [1])
	while: [self formatMessage: aMessageNode cascade: false]!

acceptMethodNode: aMethodNode 
    self formatMethodPatternFor: aMethodNode.
    codeStream nextPut: $[.

    self indent: self initialIndent while: [
        self indentWhile: 
	    [self formatMethodCommentFor: aMethodNode indentBefore: true.

            (aMethodNode category isNil)
                 ifFalse: [
		    self indent.
		    codeStream nextPutAll: '<category: ';
                                  print: (aMethodNode category);
                                  nextPut: $> ] .
       
	    self indent.
	    self visitNode: aMethodNode body ].
		
	self indent.
	codeStream nextPut: $] ]!

acceptOptimizedNode: anOptimizedNode 
    codeStream nextPutAll: '##('.
    self visitNode: anOptimizedNode body.
    codeStream nextPut: $)!

acceptReturnNode: aReturnNode 
    codeStream nextPut: $^.
    self visitNode: aReturnNode value!

acceptSequenceNode: aSequenceNode 
    | parent |
    aSequenceNode statements isEmpty ifFalse: [
        self formatMethodCommentFor: aSequenceNode indentBefore: false.
        self formatTemporariesFor: aSequenceNode.
    ].
    parent := aSequenceNode parent.
    (parent notNil and: [parent isMethod]) ifTrue: [self formatTagFor: parent].
    self formatStatementsFor: aSequenceNode!

acceptVariableNode: aVariableNode 
    codeStream nextPutAll: aVariableNode name! !

RBFormatter class
    instanceVariableNames: ''!


