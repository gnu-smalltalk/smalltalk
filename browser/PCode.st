"======================================================================
|
|   Smalltalk GUI wrapper for method source code widgets
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================
"

BLOX.BText subclass:  #BCode
	instanceVariableNames: 'class line highlighted source variables pools temps isMethod highlightBlock '
	classVariableNames: 'Colors Highlight '
	poolDictionaries: ''
	category: 'Graphics-Browser'!

BCode comment: 
nil!

!BCode class methodsFor: 'choosing behavior'!

highlight
    ^Highlight!

highlight: aBoolean 
    Highlight := aBoolean! !

!BCode class methodsFor: 'event handlers'!

colorAt: aSymbol 
    ^Colors at: aSymbol ifAbsent: [nil]!

colorAt: aSymbol put: aColor 
    ^Colors at: aSymbol put: (BTextAttributes foregroundColor: aColor)!

initializeColors
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
	colorAt: #comment put: 'SpringGreen4'! !

!BCode methodsFor: 'event handlers'!

checkLine: unused 
    | oldLine |
    oldLine := line.
    line := self currentLine.
    line ~= oldLine & highlighted not
	ifTrue: [self rehighlight]!

create
    super create.
    self inClass: UndefinedObject.
    highlighted := false.
    self onKeyUpEventSend: #checkLine: to: self.
    self 
	onMouseUpEvent: 1
	send: #checkLine:
	to: self!

invokeCallback
    highlighted ifTrue: [self blackLine].
    super invokeCallback! !

!BCode methodsFor: 'mediating protocol'!

highlightAs: kind from: start to: end 
    highlightBlock 
	value: (BCode colorAt: kind)
	value: start
	value: end!

highlightAs: kind pos: pos 
    pos isNil ifTrue: [^self].
    self 
	highlightAs: kind
	from: pos
	to: pos!

highlightNewVariable: name from: start to: end as: kind 
    temps at: name put: kind.
    self 
	highlightAs: kind
	from: start
	to: end!

highlightVariable: name from: start to: end 
    self 
	highlightAs: (self variableKind: name)
	from: start
	to: end! !

!BCode methodsFor: 'syntax highlighting'!

blackLine
    highlighted := false.
    self removeAttributesFrom: 1 @ line to: 1 @ (line + 1)!

classifyNewVariable: var 
    pools 
	keysAndValuesDo: [:pool :kind | (pool includesKey: var) ifTrue: [^kind]].
    ^(var at: 1) isUppercase ifTrue: [#globalVar] ifFalse: [#undeclaredVar]!

declareVariables: aCollection in: dictionary as: kind 
    aCollection do: [:each | dictionary at: each asString put: kind]!

rehighlight
    self class highlight ifFalse: [^self].
    self removeAttributes; highlight!

highlight
    self class highlight ifFalse: [^self].
    self highlightSyntax.
    highlighted := true!

highlightBlockClosure
    | sourceStream nlPos lineNumber |
    lineNumber := 0.
    sourceStream := ReadStream on: source.
    ^[:color :start :end | 
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
	    to: endPos]!

highlightSyntax
    | parser |
    parser := STInST.RBParser new
	errorBlock: [ :string :pos | ^self ];
	initializeParserWith: source type: #on:errorBlock:;
	yourself.

    isMethod
	ifTrue: [ self highlight: parser parseMethod ]
	ifFalse: [
	    [ parser atEnd ] whileFalse: [
	        self highlight: (parser parseStatements: false).
	        parser step.           "gobble doit terminating bang"
            ]
	]!

highlight: node
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
	    ensure: [temps := highlightBlock := nil]!

inClass: aClass 
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
		do: [:pool | pools at: (class environment at: pool) put: #poolVar]]!

initVariableClassification
    variables := LookupTable new.	"variable String -> its kind"
    pools := IdentityDictionary new.	"Dictionary -> kind of variables in it"
    variables
	at: 'self' put: #specialId;
	at: 'super' put: #specialId;
	at: 'thisContext' put: #specialId!

variableKind: var 
    ^temps at: var ifAbsentPut: [
        variables at: var ifAbsent: [self classifyNewVariable: var]]! !

!BCode methodsFor: 'widget protocol'!

contents: textOrAssociation 
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
	highlight! !


STInST.RBProgramNodeVisitor subclass:  #SyntaxHighlighter
	instanceVariableNames: 'widget '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

SyntaxHighlighter comment: 
nil!

!SyntaxHighlighter class methodsFor: 'instance creation'!

highlight: node in: aBCodeWidget 
    (self new)
	widget: aBCodeWidget;
	visitNode: node! !

!SyntaxHighlighter methodsFor: 'initialize-release'!

widget: aBCodeWidget 
    widget := aBCodeWidget! !

!SyntaxHighlighter methodsFor: 'visitor-double dispatching'!

acceptArrayNode: anArrayNode 
    "widget highlightAs: #special at: anArrayNode left."

    self visitNode: anArrayNode body
    "widget highlightAs: #special at: anArrayNode right"!

acceptAssignmentNode: anAssignmentNode 
    self acceptVariableNode: anAssignmentNode variable.
    "widget highlightAs: #special
	from: anAssignment assignment
	to: anAssignmentNode assignment + 1."
    self visitNode: anAssignmentNode value!

acceptBlockNode: aBlockNode 
    "widget highlightAs: #special at: aBlockNode left."

    aBlockNode colons with: aBlockNode arguments
	do: 
	    [:colonPos :argument | 
	    "widget highlightAs: #special at: colonPos."

	    self highlightNewVariable: argument as: #argument].

    "aBlockNode bar isNil ifFalse: [
        widget highlightAs: #special at: aBlockNode bar.
    ]."
    self visitNode: aBlockNode body
    "widget highlightAs: #special at: aBlockNode right"!

acceptCascadeNode: aCascadeNode 
    | n |
    n := 0.
    self visitNode: aCascadeNode messages first receiver.
    aCascadeNode messages do: 
	    [:each | 
	    self highlightMessageSend: each
	    "separatedBy: [ | semi |
	    semi := aCascadeNode semicolons at: (n := n + 1)
	    widget highlightAs: #special at: semi ]"]!

acceptLiteralNode: aLiteralNode 
    widget 
	highlightAs: #literal
	from: aLiteralNode start
	to: aLiteralNode stop!

acceptMessageNode: aMessageNode 
    self visitNode: aMessageNode receiver.
    self highlightMessageSend: aMessageNode!

acceptMethodNode: aMethodNode 
    "A pity we cannot share this code with highlightMessageSend: ..."

    aMethodNode isUnary 
	ifTrue: 
	    [widget 
		highlightAs: #unaryMsg
		from: aMethodNode selectorParts first start
		to: aMethodNode selectorParts first stop ].

    aMethodNode isBinary 
	ifTrue: 
	    [widget 
		highlightAs: #binaryMsg
		from: aMethodNode selectorParts first start
		to: aMethodNode selectorParts first stop.
	    self highlightNewVariable: aMethodNode arguments first as: #argument ].
    
    aMethodNode isKeyword
    	ifTrue:
	    [aMethodNode selectorParts with: aMethodNode arguments
		do: 
	    	    [:sel :arg | 
	    		widget 
			    highlightAs: #binaryMsg
			    from: sel start
			    to: sel stop.
	   		self highlightNewVariable: arg as: #argument] ].

    self visitNode: aMethodNode body!

acceptOptimizedNode: aBlockNode 
    "widget highlightAs: #special from: aBlockNode left to: aBlockNode + 2."
    self visitNode: aBlockNode body
    "widget highlightAs: #special at: aBlockNode right"!

acceptReturnNode: aReturnNode 
    "widget highlightAs: #special at: anArrayNode start."

    self visitNode: aReturnNode value!

acceptSequenceNode: aSequenceNode 
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
	    widget highlightAs: #special at: period ]"]

    "n < aSequenceNode periods size ifTrue: [
	    widget highlightAs: #special at: aSequenceNode periods last ]."!

acceptVariableNode: aVariableNode 
    widget 
	highlightVariable: aVariableNode name
	from: aVariableNode start
	to: aVariableNode stop!

highlightMessageSend: aMessageNode 
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
	    self visitNode: arg]!

highlightNewVariable: node as: kind 
    widget 
	highlightNewVariable: node name
	from: node start
	to: node stop
	as: kind! !


PText subclass:  #PCode
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Graphics-Browser'!

PCode comment: 
nil!

!PCode class methodsFor: 'instance creation'!

bloxClass
    ^BCode! !

!PCode methodsFor: 'blue button menu'!

compileIt
    super compileIt.
    self blox rehighlight! !

BCode initializeColors!

