"======================================================================
|
|   Smalltalk GUI wrapper for method source code widgets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2007
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================
"



BLOX.BText subclass: BCode [
    | class line highlighted source variables pools temps isMethod highlightBlock |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Colors := nil.
    Highlight := nil.

    BCode class >> highlight [
	<category: 'choosing behavior'>
	^Highlight
    ]

    BCode class >> highlight: aBoolean [
	<category: 'choosing behavior'>
	Highlight := aBoolean
    ]

    BCode class >> colorAt: aSymbol [
	<category: 'event handlers'>
	^Colors at: aSymbol ifAbsent: [nil]
    ]

    BCode class >> colorAt: aSymbol put: aColor [
	<category: 'event handlers'>
	^Colors at: aSymbol put: (BTextAttributes foregroundColor: aColor)
    ]

    BCode class >> initializeColors [
	<category: 'event handlers'>
	Colors := IdentityDictionary new: 32.
	self highlight: true.
	self
	    colorAt: #classVar put: 'cyan4';
	    colorAt: #globalVar put: 'cyan4';
	    colorAt: #poolVar put: 'cyan4';
	    colorAt: #undeclaredVar put: 'red';
	    colorAt: #instanceVar put: 'black';
	    colorAt: #argument put: 'black';
	    colorAt: #temporary put: 'black';
	    colorAt: #specialId put: 'grey50';
	    colorAt: #literal put: 'grey50';
	    colorAt: #temporaries put: 'magenta';
	    colorAt: #methodHeader put: 'magenta';
	    colorAt: #primitive put: 'magenta';
	    colorAt: #arguments put: 'magenta';
	    colorAt: #special put: 'magenta';
	    colorAt: #unaryMsg put: 'magenta4';
	    colorAt: #binaryMsg put: 'chocolate4';
	    colorAt: #keywordMsg put: 'NavyBlue';
	    colorAt: #comment put: 'SpringGreen4'
    ]

    checkLine: unused [
	<category: 'event handlers'>
	| oldLine |
	oldLine := line.
	line := self currentLine.
	line ~= oldLine & highlighted not ifTrue: [self rehighlight]
    ]

    create [
	<category: 'event handlers'>
	super create.
	self inClass: UndefinedObject.
	highlighted := false.
	self onKeyUpEventSend: #checkLine: to: self.
	self 
	    onMouseUpEvent: 1
	    send: #checkLine:
	    to: self
    ]

    invokeCallback [
	<category: 'event handlers'>
	highlighted ifTrue: [self blackLine].
	super invokeCallback
    ]

    highlightAs: kind from: start to: end [
	<category: 'mediating protocol'>
	highlightBlock 
	    value: (BCode colorAt: kind)
	    value: start
	    value: end
    ]

    highlightAs: kind pos: pos [
	<category: 'mediating protocol'>
	pos isNil ifTrue: [^self].
	self 
	    highlightAs: kind
	    from: pos
	    to: pos
    ]

    highlightNewVariable: name from: start to: end as: kind [
	<category: 'mediating protocol'>
	temps at: name put: kind.
	self 
	    highlightAs: kind
	    from: start
	    to: end
    ]

    highlightVariable: name from: start to: end [
	<category: 'mediating protocol'>
	self 
	    highlightAs: (self variableKind: name)
	    from: start
	    to: end
    ]

    blackLine [
	<category: 'syntax highlighting'>
	highlighted := false.
	self removeAttributesFrom: 1 @ line to: 1 @ (line + 1)
    ]

    classifyNewVariable: var [
	<category: 'syntax highlighting'>
	pools 
	    keysAndValuesDo: [:pool :kind | (pool includesKey: var) ifTrue: [^kind]].
	^(var at: 1) isUppercase ifTrue: [#globalVar] ifFalse: [#undeclaredVar]
    ]

    declareVariables: aCollection in: dictionary as: kind [
	<category: 'syntax highlighting'>
	aCollection do: [:each | dictionary at: each asString put: kind]
    ]

    rehighlight [
	<category: 'syntax highlighting'>
	self class highlight ifFalse: [^self].
	self
	    removeAttributes;
	    highlight
    ]

    highlight [
	<category: 'syntax highlighting'>
	self class highlight ifFalse: [^self].
	self highlightSyntax.
	highlighted := true
    ]

    highlightBlockClosure [
	<category: 'syntax highlighting'>
	| sourceStream nlPos lineNumber |
	lineNumber := 0.
	sourceStream := ReadStream on: source.
	^
	[:color :start :end | 
	| startPos endPos |
	[start > sourceStream position] whileTrue: 
		[lineNumber := lineNumber + 1.
		nlPos := sourceStream position.
		sourceStream skipTo: Character nl].
	startPos := (start - nlPos) @ lineNumber.
	[end > sourceStream position] whileTrue: 
		[lineNumber := lineNumber + 1.
		nlPos := sourceStream position.
		sourceStream skipTo: Character nl].
	endPos := (end - nlPos + 1) @ lineNumber.
	self 
	    setAttributes: color
	    from: startPos
	    to: endPos]
    ]

    parserClass [
	<category: 'syntax highlighting'>
	^STInST.RBBracketedMethodParser
    ]

    highlightSyntax [
	<category: 'syntax highlighting'>
	| parser |
	source = self contents 
	    ifFalse: 
		["FIXME: this is wrong, something is being dropped
		 elsewhere with respect to content updates"
		source := self contents].
	parser := (self parserClass new)
		    errorBlock: [:string :pos | ^self];
		    initializeParserWith: source type: #on:errorBlock:;
		    yourself.
	isMethod 
	    ifTrue: [self highlight: parser parseMethod]
	    ifFalse: 
		[[parser atEnd] whileFalse: 
			[self highlight: (parser parseStatements: false).
			parser step	"gobble doit terminating bang"]]
    ]

    highlight: node [
	<category: 'syntax highlighting'>
	
	[| color commentsNode |
	temps := LookupTable new.
	highlightBlock := self highlightBlockClosure.
	SyntaxHighlighter highlight: node in: self.
	commentsNode := STInST.RBProgramNode new copyCommentsFrom: node.
	commentsNode comments isNil ifTrue: [^self].
	color := BCode colorAt: #comment.
	highlightBlock := self highlightBlockClosure.
	commentsNode comments do: 
		[:each | 
		highlightBlock 
		    value: color
		    value: each first
		    value: each last]] 
		ensure: [temps := highlightBlock := nil]
    ]

    inClass: aClass [
	<category: 'syntax highlighting'>
	class == aClass ifTrue: [^self].
	class := aClass.
	self initVariableClassification.
	self 
	    declareVariables: class allClassVarNames
	    in: variables
	    as: #classVar.
	self 
	    declareVariables: class allInstVarNames
	    in: variables
	    as: #instanceVar.
	class withAllSuperclassesDo: 
		[:each | 
		pools at: class environment put: #globalVar.
		class sharedPools 
		    do: [:pool | pools at: (class environment at: pool) put: #poolVar]]
    ]

    initVariableClassification [
	<category: 'syntax highlighting'>
	variables := LookupTable new.	"variable String -> its kind"
	pools := IdentityDictionary new.	"Dictionary -> kind of variables in it"
	variables
	    at: 'self' put: #specialId;
	    at: 'super' put: #specialId;
	    at: 'thisContext' put: #specialId
    ]

    variableKind: var [
	<category: 'syntax highlighting'>
	^temps at: var
	    ifAbsentPut: [variables at: var ifAbsent: [self classifyNewVariable: var]]
    ]

    contents: textOrAssociation [
	<category: 'widget protocol'>
	| newClass |
	line := 1.
	highlighted := false.
	(textOrAssociation isKindOf: Association) 
	    ifTrue: 
		[source := textOrAssociation value.
		newClass := textOrAssociation key.
		isMethod := true]
	    ifFalse: 
		[source := textOrAssociation.
		newClass := UndefinedObject.
		isMethod := false].
	super contents: source.
	self
	    inClass: newClass;
	    highlight
    ]
]



STInST.STInST.RBProgramNodeVisitor subclass: SyntaxHighlighter [
    | widget |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    SyntaxHighlighter class >> highlight: node in: aBCodeWidget [
	<category: 'instance creation'>
	(self new)
	    widget: aBCodeWidget;
	    visitNode: node
    ]

    widget: aBCodeWidget [
	<category: 'initialize-release'>
	widget := aBCodeWidget
    ]

    acceptArrayNode: anArrayNode [
	"widget highlightAs: #special at: anArrayNode left."

	<category: 'visitor-double dispatching'>
	self visitNode: anArrayNode body
	"widget highlightAs: #special at: anArrayNode right"
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self acceptVariableNode: anAssignmentNode variable.
	"widget highlightAs: #special
	 from: anAssignment assignment
	 to: anAssignmentNode assignment + 1."
	self visitNode: anAssignmentNode value
    ]

    acceptBlockNode: aBlockNode [
	"widget highlightAs: #special at: aBlockNode left."

	<category: 'visitor-double dispatching'>
	aBlockNode colons with: aBlockNode arguments
	    do: 
		[:colonPos :argument | 
		"widget highlightAs: #special at: colonPos."

		self highlightNewVariable: argument as: #argument].

	"aBlockNode bar isNil ifFalse: [
	 widget highlightAs: #special at: aBlockNode bar.
	 ]."
	self visitNode: aBlockNode body
	"widget highlightAs: #special at: aBlockNode right"
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	| n |
	n := 0.
	self visitNode: aCascadeNode messages first receiver.
	aCascadeNode messages do: 
		[:each | 
		self highlightMessageSend: each
		"separatedBy: [ | semi |
		 semi := aCascadeNode semicolons at: (n := n + 1)
		 widget highlightAs: #special at: semi ]"]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	widget 
	    highlightAs: #literal
	    from: aLiteralNode start
	    to: aLiteralNode stop
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver.
	self highlightMessageSend: aMessageNode
    ]

    acceptMethodNode: aMethodNode [
	"A pity we cannot share this code with highlightMessageSend: ..."

	<category: 'visitor-double dispatching'>
	aMethodNode isUnary 
	    ifTrue: 
		[widget 
		    highlightAs: #unaryMsg
		    from: aMethodNode selectorParts first start
		    to: aMethodNode selectorParts first stop].
	aMethodNode isBinary 
	    ifTrue: 
		[widget 
		    highlightAs: #binaryMsg
		    from: aMethodNode selectorParts first start
		    to: aMethodNode selectorParts first stop.
		self highlightNewVariable: aMethodNode arguments first as: #argument].
	aMethodNode isKeyword 
	    ifTrue: 
		[aMethodNode selectorParts with: aMethodNode arguments
		    do: 
			[:sel :arg | 
			widget 
			    highlightAs: #binaryMsg
			    from: sel start
			    to: sel stop.
			self highlightNewVariable: arg as: #argument]].
	self visitNode: aMethodNode body
    ]

    acceptOptimizedNode: aBlockNode [
	"widget highlightAs: #special from: aBlockNode left to: aBlockNode + 2."

	<category: 'visitor-double dispatching'>
	self visitNode: aBlockNode body
	"widget highlightAs: #special at: aBlockNode right"
    ]

    acceptReturnNode: aReturnNode [
	"widget highlightAs: #special at: anArrayNode start."

	<category: 'visitor-double dispatching'>
	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	| n |
	n := 0.
	"widget highlightAs: #special at: aSequenceNode leftBar."
	aSequenceNode temporaries do: 
		[:temporary | 
		"widget highlightAs: #special at: colonPos."

		self highlightNewVariable: temporary as: #temporary].
	"widget highlightAs: #special at: aSequenceNode rightBar."
	aSequenceNode statements do: 
		[:each | 
		self visitNode: each
		"separatedBy: [ | period |
		 period := aSequenceNode periods at: (n := n + 1)
		 widget highlightAs: #special at: period ]"

		"n < aSequenceNode periods size ifTrue: [
		 widget highlightAs: #special at: aSequenceNode periods last ]."]
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	widget 
	    highlightVariable: aVariableNode name
	    from: aVariableNode start
	    to: aVariableNode stop
    ]

    highlightMessageSend: aMessageNode [
	<category: 'visitor-double dispatching'>
	aMessageNode isUnary 
	    ifTrue: 
		[widget 
		    highlightAs: #unaryMsg
		    from: aMessageNode selectorParts first start
		    to: aMessageNode selectorParts first stop.
		^self].
	aMessageNode isBinary 
	    ifTrue: 
		[widget 
		    highlightAs: #binaryMsg
		    from: aMessageNode selectorParts first start
		    to: aMessageNode selectorParts first stop.
		self visitNode: aMessageNode arguments first.
		^self].
	aMessageNode selectorParts with: aMessageNode arguments
	    do: 
		[:sel :arg | 
		widget 
		    highlightAs: #binaryMsg
		    from: sel start
		    to: sel stop.
		self visitNode: arg]
    ]

    highlightNewVariable: node as: kind [
	<category: 'visitor-double dispatching'>
	widget 
	    highlightNewVariable: node name
	    from: node start
	    to: node stop
	    as: kind
    ]
]



PText subclass: PCode [
    
    <import: STInST>
    <comment: nil>
    <category: 'Graphics-Browser'>

    PCode class >> bloxClass [
	<category: 'instance creation'>
	^BCode
    ]

    implementorsFrom: position [
	<category: 'limited parsing'>
	| symbol |
	symbol := self getMessageAt: position.
	symbol isNil 
	    ifTrue: 
		[Blox beep.
		^self].
	MethodSetBrowser implementorsOf: symbol parent: self
    ]

    sendersFrom: position [
	<category: 'limited parsing'>
	| symbol |
	symbol := self getMessageAt: position.
	symbol isNil 
	    ifTrue: 
		[Blox beep.
		^self].
	MethodSetBrowser sendersOf: symbol parent: self
    ]

    getMessageAt: position [
	"This is so easy to do with the Refactoring Browser's
	 parse nodes!!!"

	<category: 'limited parsing'>
	"First, we must map line/row to the actual index in
	 the source code."

	| stream pos parser node |
	stream := ReadStream on: blox contents.
	position y - 1 timesRepeat: [stream nextLine].
	stream skip: position x - 1.
	pos := stream position.
	stream reset.
	parser := RBParser new.
	parser errorBlock: [:message :position | ^nil].
	parser 
	    scanner: (parser scannerClass on: stream errorBlock: parser errorBlock).
	node := parser parseMethod body.
	node := node bestNodeFor: (pos to: pos + 1).
	[node isMessage] whileFalse: 
		[node := node parent.
		node isNil ifTrue: [^nil]].
	^node selector
    ]

    implementors [
	<category: 'blue button menu'>
	^self implementorsFrom: blox currentPosition
    ]

    senders [
	<category: 'blue button menu'>
	^self sendersFrom: blox currentPosition
    ]

    compileIt [
	<category: 'blue button menu'>
	super compileIt.
	self blox rehighlight
    ]
]



Eval [
    BCode initializeColors
]

