"======================================================================
|
|   Smalltalk in Smalltalk compiler
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


RBProgramNodeVisitor subclass: #STFakeCompiler
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: 'VMOtherConstants VMByteCodeNames'
       category: 'System-Compiler'
! 

STFakeCompiler comment:
'I am the Smalltalk equivalent of a wimp. I never do nothing: they tell me
to compile something, and I just return nil...

Actually, I am used when conditionally compiled code has to be skipped.'!

!STFakeCompiler class methodsFor: 'evaluation'!

evaluate: aSequenceNode parser: aParser
    ^nil
! !

!STFakeCompiler class methodsFor: 'compilation'!

compile: methodDefNode for: aBehavior classified: aString parser: aParser
    ^nil
! !

STFakeCompiler subclass: #STCompiler
       instanceVariableNames: 'node symTable parser bytecodes depth maxDepth isInsideBlock dupReceiver'
       classVariableNames: 'OneNode TrueNode FalseNode NilNode SuperVariable SelfVariable ThisContextVariable DoitToken'
       poolDictionaries: ''
       category: 'System-Compiler'
! 

STCompiler comment:
'Unlike my brother STFakeCompiler, I am a real worker. Give me some nodes, and
I will output a full-fledged CompiledMethod!!

Compilation takes place as a visit of a tree of RBParseNodes, through the
Visitor pattern embodied by the superclass RBParseNodeVisitor.  For
example, when we send the ''true printOn: stdout'' message, the structure
of the tree is:

    RBMessageNode, which contains:
	the receiver, a RBLiteralNode
	the message, a RBMessageNode, which contains
	     the selector
	     the arguments, a Collection which contains a RBVariableNode

#acceptMessageNode: checks if the receiver is super. If so, it tells the message
to compile itself as a send to super. In this case however it tells both the
receiver and the message to compile themselves.
#acceptLiteralNode: will output a ''push true'' bytecode.
#acceptMessageNode:, in turn, asks the parameters to compile themselves, asks
the STSymTable object to add the #printOn: literal, then compiles a ''send
message'' bytecode.
The RBVariableNode which refers to stdout, when it is asked to compile itself,
tells the STCompiler object to add a literal (since it refers to a global
variable) and then compiles either a ''push global variable'' or a ''push
indexed'' bytecode. The resulting stream is

	push true
	push literal corresponding to (#stdout -> stdout)
	send message with 0 args, selector = #printOn:'!

!STCompiler class methodsFor: 'initialize'!

initialize
    OneNode := RBLiteralNode value: 1.
    TrueNode := RBLiteralNode value: true.
    FalseNode := RBLiteralNode value: false.
    NilNode := RBLiteralNode value: nil.
    SelfVariable := RBVariableNode named: 'self'.
    SuperVariable := RBVariableNode named: 'super'.
    ThisContextVariable := RBVariableNode named: 'thisContext'! !

!STCompiler class methodsFor: 'evaluation'!

evaluate: aSequenceNode parser: aParser
    | cm methodNode |
    aSequenceNode addReturn.
    methodNode := RBMethodNode new
	arguments: #();
	body: aSequenceNode;
	selector: #Doit;
	source: nil;
	yourself.

    cm := self new
	class: UndefinedObject parser: aParser;
	visitNode: methodNode.

    ^nil perform: cm
! !

!STCompiler class methodsFor: 'compilation'!

compile: methodNode for: aBehavior classified: aString parser: aParser
    | cm |
    cm := self new
	class: aBehavior parser: aParser;
	visitNode: methodNode.

    cm methodCategory: aString.

    ^aBehavior
	addSelector: methodNode selector
	withMethod: cm
!

compile: methodNode asMethodOf: aBehavior classified: aString parser: aParser
    | cm |
    cm := self new
	class: aBehavior parser: aParser;
	visitNode: methodNode.

    cm methodCategory: aString.

    ^cm
! !

!STCompiler methodsFor: 'private'!

class: aBehavior parser: aParser
    symTable := STSymbolTable new.
    parser := aParser.
    bytecodes := WriteStream on: (ByteArray new: 240).
    dupReceiver := false.
    isInsideBlock := 0.

    symTable declareEnvironment: aBehavior.
! !


!STCompiler methodsFor: 'accessing'!

addLiteral: literal
    ^symTable addLiteral: literal
!

addPool: poolDictionary
    symTable addPool: poolDictionary
!

bytecodeSize
    ^bytecodes position
!

bytecodesFor: aBlockNode
    | saveBytecodes result |
    saveBytecodes := bytecodes.
    bytecodes := WriteStream on: (ByteArray new: 240).
    self compileStatements: aBlockNode.

    result := bytecodes contents.
    bytecodes := saveBytecodes.
    ^result
!

bytecodesFor: aBlockNode atEndDo: aBlock
    | saveBytecodes result |
    saveBytecodes := bytecodes.
    bytecodes := WriteStream on: (ByteArray new: 240).
    self compileStatements: aBlockNode.
    aBlock value.

    result := bytecodes contents.
    bytecodes := saveBytecodes.
    ^result
!

checkStore: aVariableName
    (symTable canStore: aVariableName) ifFalse: [
	self compileError: 'cannot store in argument ', aVariableName
    ]
!

compileBigLiteral: op index: index
    self
	nextPut: BigLiteral;
	nextPut: index // 256 + op;
	nextPut: (index bitAnd: 255)
!

compileBigInstance: op index: index
    self
	nextPut: BigInstance;
	nextPut: index // 256 + op;
	nextPut: (index bitAnd: 255)
!

compileError: aString
    parser parserError: aString
!

compileJump: displacement if: jmpCondition

    jmpCondition isNil ifTrue: [
	"Unconditional"
	^self
	    nextPut: JumpLong + (((displacement + 1024) bitShift: -8) bitAnd: 7);
	    nextPut: (displacement bitAnd: 255).
    ].
    displacement < 0 ifTrue: [
	 "Should not happen"
	 ^self error: 'Cannot compile backwards conditional jumps'.
    ].
    jmpCondition
	ifFalse: [
	    self
		depthDecr: 1;
		nextPut: PopJumpFalse + ((displacement bitShift: -8) bitAnd: 3)
	]
	ifTrue: [
	    self
		depthDecr: 1;
		nextPut: PopJumpTrue + ((displacement bitShift: -8) bitAnd: 3)
	].
    self
	nextPut: (displacement bitAnd: 255)
!

compileWarning: aString
    parser parserWarning: aString
!

declareTemporaries: node
    | result |
    node arguments do: [ :anArg |
	result := symTable
	    declareTemporary: anArg name
	    canStore: false
	    for: self
    ].
    node body temporaries do: [ :aTemp |
	result := symTable
	    declareTemporary: aTemp name
	    canStore: true
	    for: self
    ].
    ^result
!

maxDepth
    ^maxDepth
!

depthDecr: n
    depth := depth - n
!

depthIncr
    depth = maxDepth
	ifTrue: [ depth := depth + 1. maxDepth := maxDepth + 1 ]
	ifFalse: [ depth := depth + 1 ]
!

depthSet: n
    "n can be an integer, or a previously returned value (in which case the
     exact status at the moment of the previous call is remembered)"
    | oldDepth |
    oldDepth := n -> maxDepth.
    n isInteger
	ifTrue: [ depth := maxDepth := n ]
	ifFalse: [ depth := n key. maxDepth := n value ].
    ^oldDepth
!

isReceiver: variable
    ^symTable isReceiver: variable
!

isTemporary: variable
    ^symTable isTemporary: variable
!

literals
    ^symTable literals
!

lookupName: variable
    | definition |
    definition := symTable lookupName: variable for: self.

    definition isNil ifTrue: [
	"Might want to declare this puppy as a local and go on
	 notwithstanding the error"

	 self compileError: 'Undefined variable ', 
	     variable printString, ' referenced.'
    ].
    ^definition
!

nextPut: aByte
    bytecodes nextPut: aByte.
!

nextPutAll: aByteArray
    bytecodes nextPutAll: aByteArray.
!

isInsideBlock
    ^isInsideBlock > 0
!

outerScopes: variable
    ^symTable outerScopes: variable
!

pushLiteral: value
    | definition |
    value isInteger ifTrue: [
	value == 0
	    ifTrue: [ self nextPut: PushSpecial + LiteralZeroIndex. ^self ].
	value == 1
	    ifTrue: [ self nextPut: PushSpecial + LiteralOneIndex. ^self ].

        (value between: -128 and: 255) ifTrue: [
	    self
	        nextPut: (value < 0
			     ifTrue: [ Push8BitSigned ]
			     ifFalse: [ Push8BitUnsigned ]);
	        nextPut: (value bitAnd: 255).

	    ^self
	]
    ].

    definition := self addLiteral: value.

    definition <= 31 ifTrue: [
	self nextPut: (PushLitConstant + definition).
	^self
    ].    
    
    definition > 63 ifTrue: [
	self compileBigLiteral: PushLiteral index: definition.
	^self
    ].
    self
	nextPut: PushIndexed;
	nextPut: (LiteralConstantLocation + definition)
!

pushLiteralVariable: value
    | definition |
    definition := self addLiteral: value.

    definition <= 31 ifTrue: [
	self nextPut: (PushLitVariable + definition).
	^self
    ].    
    
    definition > 63 ifTrue: [
	self compileBigLiteral: PushVariable index: definition.
	^self
    ].
    self
	nextPut: PushIndexed;
	nextPut: (LiteralVariableLocation + definition)
!

sizeOfJump
    ^2
!

insideNewScopeDo: aBlock
    | result |
    isInsideBlock := isInsideBlock + 1.
    symTable scopeEnter.
    result := aBlock value.
    symTable scopeLeave.
    isInsideBlock := isInsideBlock - 1.
    ^result
!

bindingOf: anOrderedCollection
    | binding |
    binding := symTable bindingOf: anOrderedCollection for: self.
    binding isNil ifTrue: [
	 self compileError: 'Undefined variable binding', 
	     anOrderedCollection asArray printString, 'referenced.'
    ].
    ^binding
!

undeclareTemporaries: aNode
    aNode body temporaries do: [ :each | symTable undeclareTemporary: each name ].
    aNode arguments do: [ :each | symTable undeclareTemporary: each name ]
! !

!STCompiler methodsFor: 'visiting RBSequenceNodes'!

acceptSequenceNode: node
    | statements method |
    node addSelfReturn.
    node temporaries do: [ :aTemp |
        symTable
            declareTemporary: aTemp name
            canStore: true
            for: self
    ].

    depth := maxDepth := 0.

    node statements do: [ :each | self visitNode: each ].
    symTable finish.

    method := CompiledMethod
	literals: symTable literals
	numArgs: 0
	numTemps: symTable numTemps
	primitive: 0
	bytecodes: bytecodes contents
	depth: maxDepth + symTable numTemps.

    method getDescriptor setSourceCode: node source.
    ^method
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBMethodNodes'!

acceptMethodNode: node
    | statements method |
    node body addSelfReturn.
    self declareTemporaries: node.

    depth := maxDepth := 0.

    node body statements do: [ :each | self visitNode: each ].
    symTable finish.

    method := CompiledMethod
	literals: symTable literals
	numArgs: node arguments size
	numTemps: node body temporaries size
	primitive: 0
	"primitive: node body primitive FIXME"
	bytecodes: bytecodes contents
	depth: maxDepth + node body temporaries size + node arguments size.

    method getDescriptor setSourceCode: node source.
    ^method
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBArrayConstructorNodes'!

acceptArrayConstructorNode: aNode
    "STArrayNode is the parse node class for {...} style array constructors.
     It is compiled like a normal inlined block, but with the statements
     preceded by (Array new: <size of the array>) and with each statement
     followed with a <pop into instance variable of new stack top>
     instead of a simple pop."

    self
	depthIncr;
	pushLiteralVariable: (Smalltalk associationAt: #Array);
	depthIncr;
	pushLiteral: aNode body statements size;
	depthDecr: 1;
	nextPut: NewColonSpecial.

    aNode body statements doWithIndex: [ :each :index |
	each acceptVisitor: self.
	self
	    depthDecr: 1;
	    compileBigInstance: PopStoreIntoArray index: index.
    ]
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBBlockNodes'!

acceptBlockNode: aNode
    "STBlockNode has a variable that contains a string for each parameter,
     and one that contains a list of statements. Here is how STBlockNodes
     are compiled:

	push BlockClosure literal
	push thisContext (or push nil)      <--- optional
	send #blockCopy:                    <--- optional

     Statements are put in a separate CompiledBlock object that is referenced
     by the BlockClosure.

     compileStatements: creates the bytecodes.  It is this method that is
     called by STCompiler>>bytecodesFor: and STCompiler>>bytecodesFor:append:"

    | bc depth blockClosure clean |
    depth := self depthSet: aNode arguments size + aNode body temporaries size.
   
    aNode body statements isEmpty ifTrue: [
	aNode body addNode: (RBLiteralNode value: nil).
    ].
 
    bc := self insideNewScopeDo: [
	self bytecodesFor: aNode atEndDo: [
	    aNode body lastIsReturn ifFalse: [ self nextPut: ReturnContextStackTop ]
	]
    ].

    blockClosure := BlockClosure
	numArgs: aNode arguments size
	numTemps: aNode body temporaries size
	bytecodes: bc
	depth: self maxDepth
	literals: self literals.

    self
	depthSet: depth;
	pushLiteral: blockClosure.

    clean := blockClosure block flags.
    clean == 0 ifTrue: [ ^aNode ].

    self nextPut: (clean == 1
	ifTrue: [ PushNil ]
	ifFalse: [ PushActiveContext ]).

    self nextPut: BlockCopyColonSpecial
!

compileStatements: aNode

    self declareTemporaries: aNode.

    aNode body statements doWithIndex: [ :each :index |
	index = 1 ifFalse: [
	    self
		depthDecr: 1;
		nextPut: PopStackTop
	].
	each acceptVisitor: self.
    ].
    aNode body statements isEmpty ifTrue: [
	self
	    depthIncr;
	    nextPut: PushNil
    ].
    self undeclareTemporaries: aNode.
! !


"--------------------------------------------------------------------"
!STCompiler methodsFor: 'visiting RBCascadeNodes'!

acceptCascadeNode: aNode
    "RBCascadeNode holds a collection with one item per message."

    | messages first |
    messages := aNode messages.
    first := messages at: 1.
    first receiver = SuperVariable ifTrue: [
	aNode messages
	    do: [ :each | self compileSendToSuper: each ]
	    separatedBy: [ self depthDecr: 1; nextPut: PopStackTop ].

	^aNode
    ].

    dupReceiver := true.
    first acceptVisitor: self.

    messages
	from: 2 to: messages size - 1
	do: [ :each |
	    self nextPut: PopStackTop; nextPut: DupStackTop.
	    each acceptVisitor: self ].

    self nextPut: PopStackTop.
    self depthDecr: 1.
    (messages at: messages size) acceptVisitor: self.
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBOptimizedNodes'!

acceptOptimizedNode: aNode
    self depthIncr.

    self pushLiteral: (self class evaluate: aNode body parser: parser)
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBLiteralNodes'!

acceptLiteralNode: aNode
    "STLiteralNode has one instance variable, the token for the literal
     it represents."
    self depthIncr.

    aNode compiler: self.
    self pushLiteral: aNode value.
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBAssignmentNodes'!

acceptAssignmentNode: aNode
    "First compile the assigned, then the assignment to the assignee..."
    aNode value acceptVisitor: self.
    (VMSpecialIdentifiers includesKey: aNode variable name)
	ifTrue: [
	    self compileError: 'cannot assign to ', aNode variable name
	].

    self compileAssignmentFor: aNode variable.
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'compiling'!

acceptMessageNode: aNode
    "RBMessageNode contains a message send. Its instance variable are
     a receiver, selector, and arguments."
    | dup specialSelector args litIndex |

    dup := dupReceiver. dupReceiver := false.
 
    aNode receiver = SuperVariable ifTrue: [
	self compileSendToSuper: aNode.
	^true
    ].

    (VMSpecialMethods includesKey: aNode selector) ifTrue: [
	specialSelector := VMSpecialMethods at: aNode selector.
	(specialSelector isNil and: [aNode receiver isBlock and: [ dup not ]])
	    ifTrue: [
		(self acceptWhileLoop: aNode) ifTrue: [^false]
	    ]
	].

    aNode receiver acceptVisitor: self.
    dup ifTrue: [ self depthIncr; nextPut: DupStackTop ].
    specialSelector isNil ifFalse: [
	(self perform: specialSelector with: aNode) ifTrue: [^false]
    ].

    aNode arguments do: [ :each | each acceptVisitor: self ].

    VMSpecialSelectors at: aNode selector ifPresent: [ :idx |
	self nextPut: SendSpecial + idx.
	^aNode
    ].

    args := aNode arguments size.
    litIndex := self addLiteral: aNode selector.
    (args <= 2) & (litIndex <= 15)
	ifTrue: [
	    self nextPut: SendSelectorShort + (args * 16) + litIndex
	]
	ifFalse: [
	    self
		emitExtendedSendBytecodesToSuperFlag: 0
		literalIndex: litIndex
		argCount: args
	].

    self depthDecr: aNode arguments size.
!

acceptWhileLoop: aNode
    "Answer whether the while loop can be optimized (that is,
     whether the only parameter is a STBlockNode)"

    | whileBytecodes argBytecodes totBytecodesSize argBytecodesSize |

    (aNode receiver arguments isEmpty and: [
	aNode receiver body temporaries isEmpty ]) ifFalse: [ ^false ].

    argBytecodesSize := 0.
    aNode arguments do: [ :onlyArgument |
	onlyArgument isBlock ifFalse: [ ^false ].
        (onlyArgument arguments isEmpty and: [
	    onlyArgument body temporaries isEmpty ])
		ifFalse: [ ^false ].

	argBytecodes := self bytecodesFor: onlyArgument.

	"+1 accounts for the final pop"
	argBytecodesSize := argBytecodes size + 1.
    ].
    whileBytecodes := self bytecodesFor: aNode receiver.
    self nextPutAll: whileBytecodes.

    totBytecodesSize := whileBytecodes size + self sizeOfJump + argBytecodesSize.
    aNode selector == #repeat ifFalse: [
	"The if: clause means: if selector is whileFalse:, compile
	 a 'pop/jump if true'; else compile a 'pop/jump if false'"
	self
	    compileJump: argBytecodesSize + self sizeOfJump
	    if: (aNode selector == #whileFalse or: [ aNode selector == #whileFalse: ]).

	argBytecodes isNil ifFalse: [
	    self
		nextPutAll: argBytecodes;
		nextPut: PopStackTop;
		depthDecr: 1
	].
	totBytecodesSize := totBytecodesSize + self sizeOfJump.
    ].

    self
	compileJump: totBytecodesSize negated
	if: nil.

    "Somebody might want to use the return value of #whileTrue:
     and #whileFalse:"

    self depthIncr; nextPut: PushNil.
    ^true
!

compileSendToSuper: aNode

    self depthIncr; nextPut: PushSpecial.
    aNode arguments do: [ :each | each acceptVisitor: self ].
    self
	emitExtendedSendBytecodesToSuperFlag: 2
	literalIndex: (self addLiteral: aNode selector)
	argCount: aNode arguments size.

    self depthDecr: aNode arguments size.
!

compileTimesRepeat: aNode
    | block |
    block := aNode arguments first.
    (block arguments isEmpty and: [
	block body temporaries isEmpty ]) ifFalse: [ ^false ].

    ^false
!

compileLoop: aNode
    | stop step block |
    aNode arguments do: [ :each |
	stop := step.			"to:"
	step := block.			"by:"
	block := each.			"do:"
    ].
    (block arguments size = 1 and: [
	block body temporaries isEmpty ]) ifFalse: [ ^false ].

    stop isNil
	ifTrue: [ stop := step. step := OneNode ]	"#to:do:"
	ifFalse: [ step isImmediate ifFalse: [ ^false ] ].

    ^false
!

compileBoolean: aNode
    | bc1 ret1 bc2 selector |
    aNode arguments do: [ :each |
        (each arguments isEmpty and: [
	    each body temporaries isEmpty ]) ifFalse: [ ^false ].

	bc1 isNil
	    ifTrue: [
		bc1 := self bytecodesFor: each.
		ret1 := each isReturn ]
	    ifFalse: [
		bc2 := self bytecodesFor: each ].
    ].

    selector := aNode selector.
    bc2 isNil ifTrue: [
	"Transform everything into #ifTrue:ifFalse: or #ifFalse:ifTrue:"

	selector == #ifTrue: ifTrue: [
	    selector := #ifTrue:ifFalse: . bc2 := #[115]. "Push nil"
	].
	selector == #ifFalse: ifTrue: [
	    selector := #ifFalse:ifTrue: . bc2 := #[115]. "Push nil"
	].
	selector == #and: ifTrue: [
	    selector := #ifTrue:ifFalse: . bc2 := #[114]. "Push false"
	].
	selector == #or: ifTrue: [
	    selector := #ifFalse:ifTrue: . bc2 := #[113]. "Push true"
	].
	^self compileBoolean: aNode
	    longBranch: bc1 returns: ret1 shortBranch: bc2
	    longIfTrue: selector == #ifTrue:ifFalse:
    ].

    selector == #ifTrue:ifFalse: ifTrue: [
	^self compileIfTrue: bc1 returns: ret1 ifFalse: bc2
    ].
    selector == #ifFalse:ifTrue: ifTrue: [
	^self compileIfFalse: bc1 returns: ret1 ifTrue: bc2
    ].
    ^false "What happened?!?"
!

compileBoolean: aNode longBranch: bc1 returns: ret1 shortBranch: bc2
	longIfTrue: longIfTrue

    self
	compileJump: bc1 size + (ret1 ifTrue: [ 0 ] ifFalse: [ 1 ])
	if: longIfTrue not.

    self nextPutAll: bc1.
    ret1 ifFalse: [
	self nextPut: JumpShort + bc2 size - 1.
    ].
    self nextPutAll: bc2.
    ^true
!

compileIfTrue: bcTrue returns: bcTrueReturns ifFalse: bcFalse

    | trueSize |
    trueSize := bcTrueReturns
	ifTrue: [ bcTrue size ]
	ifFalse: [ bcTrue size + self sizeOfJump ].

    self compileJump: trueSize if: false.
    self nextPutAll: bcTrue.
    bcTrueReturns ifFalse: [
	self compileJump: bcFalse size if: nil.
    ].
    self nextPutAll: bcFalse.
    ^true
!

compileIfFalse: bcFalse returns: bcFalseReturns ifTrue: bcTrue

    | falseSize |
    falseSize := bcFalseReturns
	ifTrue: [ bcFalse size ]
	ifFalse: [ bcFalse size + self sizeOfJump ].

    self compileJump: falseSize if: true.
    self nextPutAll: bcFalse.
    bcFalseReturns ifFalse: [
	self compileJump: bcTrue size if: nil.
    ].
    self nextPutAll: bcTrue.
    ^true
!

emitExtendedSendBytecodesToSuperFlag: toSuperFlag literalIndex: litIndex argCount: args

    (args <= 7) & (litIndex <= 31)
	ifTrue: [
	    self
		nextPut: SendSelector1ExtByte + toSuperFlag;
		nextPut: args * 32 + litIndex
	]
	ifFalse: [
	    self
		nextPut: SendSelector2ExtByte;
		nextPut: (litIndex bitAnd: 16r300) // 4 + (toSuperFlag * 32) + args;
		nextPut: (litIndex bitAnd: 16r0FF)
	]
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'compiling'!

acceptReturnNode: aNode
    aNode = TrueNode ifTrue: [ ^self nextPut: ReturnSpecial + 1 ].
    aNode = FalseNode ifTrue: [ ^self nextPut: ReturnSpecial + 2 ].
    aNode = NilNode ifTrue: [ ^self nextPut: ReturnSpecial + 3 ].

    aNode value acceptVisitor: self.
    self isInsideBlock
	ifTrue: [ self nextPut: ReturnMethodStackTop ]
	ifFalse: [ self nextPut: ReturnContextStackTop ]
! !

"--------------------------------------------------------------------"

!STCompiler methodsFor: 'visiting RBVariableNodes'!

compileAssignmentFor: aNode
    "RBVariableNode has one instance variable, the name of the variable
     that it represents."
    | locationType definition |

    definition := self lookupName: aNode name.
    locationType := LiteralVariableLocation.

    (self isTemporary: aNode name) ifTrue: [
	self checkStore: aNode name.
	^self
	    compileStoreTemporary: definition
	    scopes: (self outerScopes: aNode name)
    ].    

    (self isReceiver: aNode name) ifTrue: [
	locationType := ReceiverLocation.
	definition > 63 ifTrue: [
	    self compileBigInstance: StoreVariable index: definition.
	    ^aNode
	]
    ].
    
    definition > 63 ifTrue: [
	self compileBigLiteral: StoreVariable index: definition.
	^aNode
    ].
    self
	nextPut: StoreIndexed;
	nextPut: (locationType + definition)
!

acceptVariableNode: aNode
    | locationType definition |

    self depthIncr.
    VMSpecialIdentifiers at: aNode name ifPresent: [ :encodedValue |
	self nextPut: PushSpecial + encodedValue.
	^aNode
    ].

    definition := self lookupName: aNode name.
    locationType := LiteralVariableLocation.

    (self isTemporary: aNode name) ifTrue: [
	^self
	    compilePushTemporary: definition
	    scopes: (self outerScopes: aNode name)
    ].    
    (self isReceiver: aNode name) ifTrue: [
	locationType := ReceiverLocation.
	definition <= 15 ifTrue: [
	    self nextPut: (PushReceiverVariable + definition).
	    ^aNode
	].
	definition > 63 ifTrue: [
	    self compileBigInstance: PushVariable index: definition.
	    ^aNode
	]
    ].
    definition <= 31 ifTrue: [
	self nextPut: (PushLitVariable + definition).
	^aNode
    ].
    definition > 63 ifTrue: [
	self compileBigLiteral: PushVariable index: definition.
	^aNode
    ].
    
    self
	nextPut: PushIndexed;
	nextPut: (locationType + definition)
!

compilePushTemporary: number scopes: outerScopes
    outerScopes = 0 ifFalse: [ Smalltalk debug.
	self
	    nextPut: OuterVar;
	    nextPut: (number + PushVariable);
	    nextPut: outerScopes.
	^self
    ].
    number < 16 ifTrue: [
	^self nextPut: (PushTemporaryVariable + number).
    ].
    self
	nextPut: PushIndexed;
	nextPut: (TemporaryLocation + number)
!

compileStoreTemporary: number scopes: outerScopes
    outerScopes = 0 ifFalse: [
	^self
	    nextPut: OuterVar;
	    nextPut: number + StoreVariable;
	    nextPut: outerScopes.
    ].
    self
	nextPut: StoreIndexed;
	nextPut: (TemporaryLocation + number)
! !

STCompiler initialize!
