"======================================================================
|
|   Smalltalk in Smalltalk compiler
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2006,2007,2009 Free Software Foundation, Inc.
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
 ======================================================================"



RBProgramNodeVisitor subclass: STFakeCompiler [
    
    <import: VMOtherConstants>
    <import: VMByteCodeNames>
    <comment: 'I am the Smalltalk equivalent of a wimp. I never do nothing: they tell me
to compile something, and I just return nil...

Actually, I am used when conditionally compiled code has to be skipped.'>
    <category: 'System-Compiler'>

    STFakeCompiler class >> evaluate: aSequenceNode parser: aParser [
	<category: 'evaluation'>
	^nil
    ]

    STFakeCompiler class >> compile: methodDefNode for: aBehavior classified: aString parser: aParser [
	<category: 'compilation'>
	^nil
    ]
]



STFakeCompiler subclass: STCompiler [
    | node destClass symTable parser bytecodes depth maxDepth isInsideBlock |
    
    <comment: 'Unlike my brother STFakeCompiler, I am a real worker. Give me some nodes, and
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
	send message with 0 args, selector = #printOn:'>
    <category: 'System-Compiler'>

    OneNode := nil.
    TrueNode := nil.
    FalseNode := nil.
    NilNode := nil.
    SuperVariable := nil.
    SelfVariable := nil.
    ThisContextVariable := nil.

    STCompiler class >> initialize [
	<category: 'initialize'>
	OneNode := RBLiteralNode value: 1.
	TrueNode := RBLiteralNode value: true.
	FalseNode := RBLiteralNode value: false.
	NilNode := RBLiteralNode value: nil.
	SelfVariable := RBVariableNode named: 'self'.
	SuperVariable := RBVariableNode named: 'super'.
	ThisContextVariable := RBVariableNode named: 'thisContext'
    ]

    STCompiler class >> evaluate: aSequenceNode parser: aParser [
	<category: 'evaluation'>
	| cm methodNode |
	aSequenceNode addReturn.
	methodNode := (RBMethodNode new)
		    arguments: #();
		    body: aSequenceNode;
		    selector: #Doit;
		    source: nil;
		    yourself.
	cm := self 
		    compile: methodNode
		    asMethodOf: UndefinedObject
		    classified: nil
		    parser: aParser
		    environment: Namespace current.
	^nil perform: cm
    ]

    STCompiler class >> canCompile: code [
	"Answer whether I know how to compile the given code directly, on
	 behalf of a Behavior."

	<category: 'compilation'>
	^(code isKindOf: RBProgramNode) and: [code isMethod]
    ]

    STCompiler class >> compile: methodNode for: aBehavior classified: aString parser: aParser [
	<category: 'compilation'>
	^aBehavior addSelector: methodNode selector
	    withMethod: (self 
		    compile: methodNode
		    asMethodOf: aBehavior
		    classified: aString
		    parser: aParser)
    ]

    STCompiler class >> compile: methodNode asMethodOf: aBehavior classified: aString parser: aParser [
	<category: 'compilation'>
	^self 
	    compile: methodNode
	    asMethodOf: aBehavior
	    classified: aString
	    parser: aParser
	    environment: nil
    ]

    STCompiler class >> compile: methodNode asMethodOf: aBehavior classified: aString parser: aParser environment: aNamespace [
	<category: 'compilation'>
	| compiler method |
	compiler := self new.
	compiler class: aBehavior parser: aParser.
	aNamespace isNil ifFalse: [compiler addPool: aNamespace].
	method := compiler visitNode: methodNode.
	aString isNil ifFalse: [ method methodCategory: aString ].
	^method
    ]

    class: aBehavior parser: aParser [
	<category: 'private'>
	destClass := aBehavior.
	symTable := STSymbolTable new.
	parser := aParser.
	bytecodes := WriteStream on: (ByteArray new: 240).
	isInsideBlock := 0.
	symTable declareEnvironment: aBehavior
    ]

    addLiteral: literal [
	<category: 'accessing'>
	^(symTable addLiteral: literal)
    ]

    addPool: aNamespace [
	<category: 'accessing'>
	^symTable addPool: aNamespace
    ]

    bytecodesFor: aBlockNode [
	<category: 'accessing'>
	^self bytecodesFor: aBlockNode atEndDo: []
    ]

    bytecodesFor: aBlockNode atEndDo: aBlock [
	<category: 'accessing'>
	| saveBytecodes result |
	saveBytecodes := bytecodes.
	bytecodes := WriteStream on: (ByteArray new: 240).
	self declareArgumentsAndTemporaries: aBlockNode.
	self compileStatements: aBlockNode body.
	self undeclareArgumentsAndTemporaries: aBlockNode.
	aBlock value.
	result := bytecodes contents.
	bytecodes := saveBytecodes.
	^result
    ]

    checkStore: aVariableName [
	<category: 'accessing'>
	(symTable canStore: aVariableName) 
	    ifFalse: [self compileError: 'cannot store in argument ' , aVariableName]
    ]

    compileError: aString [
	<category: 'accessing'>
	parser parserError: aString
    ]

    compileBackJump: displacement [
	<category: 'accessing'>
	| jumpLen |
	jumpLen := displacement + 2.
	jumpLen := displacement + (self sizeOfJump: jumpLen).
	jumpLen := displacement + (self sizeOfJump: jumpLen).
	self compileByte: JumpBack arg: jumpLen
    ]

    compileJump: displacement if: jmpCondition [
	<category: 'accessing'>
	displacement < 0 
	    ifTrue: 
		["Should not happen"

		^self error: 'Cannot compile backwards conditional jumps'].
	self depthDecr: 1.
	jmpCondition 
	    ifFalse: [self compileByte: PopJumpFalse arg: displacement]
	    ifTrue: [self compileByte: PopJumpTrue arg: displacement]
    ]

    compileWarning: aString [
	<category: 'accessing'>
	parser parserWarning: aString
    ]

    declareTemporaries: node [
	<category: 'accessing'>
	node temporaries do: 
		[:aTemp | 
		symTable 
		    declareTemporary: aTemp name
		    canStore: true
		    for: self]
    ]

    declareArgumentsAndTemporaries: node [
	<category: 'accessing'>
	node arguments do: 
		[:anArg | 
		symTable 
		    declareTemporary: anArg name
		    canStore: false
		    for: self].
	self declareTemporaries: node body
    ]

    maxDepth [
	<category: 'accessing'>
	^maxDepth
    ]

    depthDecr: n [
	<category: 'accessing'>
	depth := depth - n
    ]

    depthIncr [
	<category: 'accessing'>
	depth = maxDepth 
	    ifTrue: 
		[depth := depth + 1.
		maxDepth := maxDepth + 1]
	    ifFalse: [depth := depth + 1]
    ]

    depthSet: n [
	"n can be an integer, or a previously returned value (in which case the
	 exact status at the moment of the previous call is remembered)"

	<category: 'accessing'>
	| oldDepth |
	oldDepth := n -> maxDepth.
	n isInteger 
	    ifTrue: [depth := maxDepth := n]
	    ifFalse: 
		[depth := n key.
		maxDepth := n value].
	^oldDepth
    ]

    literals [
	<category: 'accessing'>
	^symTable literals
    ]

    lookupName: variable [
	<category: 'accessing'>
	| definition |
	definition := symTable lookupName: variable for: self.
	definition isNil 
	    ifTrue: 
		["Might want to declare this puppy as a local and go on
		 notwithstanding the error"

		self 
		    compileError: 'Undefined variable ' , variable printString , ' referenced.'].
	^definition
    ]

    compileByte: aByte [
	<category: 'accessing'>
	self compileByte: aByte arg: 0
    ]

    compileByte: aByte arg: arg [
	<category: 'accessing'>
	| n |
	n := 0.
	[(arg bitShift: n) > 255] whileTrue: [n := n - 8].
	n to: -8
	    by: 8
	    do: 
		[:shift | 
		bytecodes
		    nextPut: ExtByte;
		    nextPut: ((arg bitShift: shift) bitAnd: 255)].
	bytecodes
	    nextPut: aByte;
	    nextPut: (arg bitAnd: 255)
    ]

    compileByte: aByte arg: arg1 arg: arg2 [
	<category: 'accessing'>
	self compileByte: aByte arg: (arg1 bitShift: 8) + arg2
    ]

    nextPutAll: aByteArray [
	<category: 'accessing'>
	bytecodes nextPutAll: aByteArray
    ]

    isInsideBlock [
	<category: 'accessing'>
	^isInsideBlock > 0
    ]

    pushLiteral: value [
	<category: 'accessing'>
	| definition |
	(value isInteger and: [value >= 0 and: [value <= 1073741823]]) 
	    ifTrue: 
		[self compileByte: PushInteger arg: value.
		^self].
        value isNil
            ifTrue:
                [self compileByte: PushSpecial arg: NilIndex.
                ^self].
        value == true
            ifTrue:
                [self compileByte: PushSpecial arg: TrueIndex.
                ^self].
        value == false
            ifTrue:
                [self compileByte: PushSpecial arg: FalseIndex.
                ^self].
	definition := self addLiteral: value.
	self compileByte: PushLitConstant arg: definition
    ]

    pushLiteralVariable: value [
	<category: 'accessing'>
	| definition |
	definition := self addLiteral: value.
	self compileByte: PushLitVariable arg: definition
    ]

    sizeOfJump: distance [
	<category: 'accessing'>
	distance < 256 ifTrue: [^2].
	distance < 65536 ifTrue: [^4].
	distance < 16777216 ifTrue: [^6].
	^8
    ]

    displacementsToJumpAround: jumpAroundOfs and: initialCondLen [
	<category: 'accessing'>
	| jumpAroundLen oldJumpAroundLen finalJumpOfs finalJumpLen |
	jumpAroundLen := oldJumpAroundLen := 0.
	
	[finalJumpOfs := initialCondLen + oldJumpAroundLen + jumpAroundOfs.
	finalJumpLen := self sizeOfJump: finalJumpOfs.
	jumpAroundLen := self sizeOfJump: jumpAroundOfs + finalJumpLen.
	oldJumpAroundLen = jumpAroundLen] 
		whileFalse: [oldJumpAroundLen := jumpAroundLen].
	^finalJumpLen + finalJumpOfs -> (jumpAroundOfs + finalJumpLen)
    ]

    insideNewScopeDo: aBlock [
	<category: 'accessing'>
	| result |
	isInsideBlock := isInsideBlock + 1.
	symTable scopeEnter.
	result := aBlock value.
	symTable scopeLeave.
	isInsideBlock := isInsideBlock - 1.
	^result
    ]

    bindingOf: anOrderedCollection [
	<category: 'accessing'>
	| binding |
	binding := symTable bindingOf: anOrderedCollection for: self.
	binding isNil 
	    ifTrue: 
		[self 
		    compileError: 'Undefined variable binding' 
			    , anOrderedCollection asArray printString , 'referenced.'].
	^binding
    ]

    undeclareTemporaries: aNode [
	<category: 'accessing'>
	aNode temporaries do: [:each | symTable undeclareTemporary: each name]
    ]

    undeclareArgumentsAndTemporaries: aNode [
	<category: 'accessing'>
	self undeclareTemporaries: aNode body.
	aNode arguments do: [:each | symTable undeclareTemporary: each name]
    ]

    acceptSequenceNode: node [
	<category: 'visiting RBSequenceNodes'>
	| statements method |
	node addSelfReturn.
	depth := maxDepth := 0.
	self declareTemporaries: node.
	self compileStatements: node.
	self undeclareTemporaries: node.
	symTable finish.
	method := CompiledMethod 
		    literals: symTable literals
		    numArgs: 0
		    numTemps: symTable numTemps
		    attributes: #()
		    bytecodes: bytecodes contents
		    depth: maxDepth + symTable numTemps.
	(method descriptor)
	    setSourceCode: node source asSourceCode;
	    methodClass: UndefinedObject;
	    selector: #executeStatements.
	^method
    ]

    acceptMethodNode: node [
	<category: 'visiting RBMethodNodes'>
	| statements method attributes |
	node body addSelfReturn.
	depth := maxDepth := 0.
	self declareArgumentsAndTemporaries: node.
	self compileStatements: node body.
	self undeclareArgumentsAndTemporaries: node.
	symTable finish.
	attributes := self compileMethodAttributes: node primitiveSources.
	method := CompiledMethod 
		    literals: symTable literals
		    numArgs: node arguments size
		    numTemps: node body temporaries size
		    attributes: attributes
		    bytecodes: bytecodes contents
		    depth: maxDepth + node body temporaries size + node arguments size.
	(method descriptor)
	    setSourceCode: node source asSourceCode;
	    methodClass: symTable environment;
	    selector: node selector.
	method attributesDo: 
		[:ann | 
		| handler error |
		handler := symTable environment pragmaHandlerFor: ann selector.
		handler notNil 
		    ifTrue: 
			[error := handler value: method value: ann.
			error notNil ifTrue: [self compileError: error]]].
	^method
    ]

    acceptArrayConstructorNode: aNode [
	"STArrayNode is the parse node class for {...} style array constructors.
	 It is compiled like a normal inlined block, but with the statements
	 preceded by (Array new: <size of the array>) and with each statement
	 followed with a <pop into instance variable of new stack top>
	 instead of a simple pop."

	<category: 'visiting RBArrayConstructorNodes'>
	self
	    depthIncr;
	    pushLiteralVariable: (Smalltalk associationAt: #Array);
	    depthIncr;
	    compileByte: PushInteger arg: aNode body statements size;
	    depthDecr: 1;
	    compileByte: SendImmediate arg: NewColonSpecial.
	aNode body statements keysAndValuesDo: 
		[:index :each | 
		each acceptVisitor: self.
		self
		    depthDecr: 1;
		    compileByte: PopStoreIntoArray arg: index - 1]
    ]

    acceptBlockNode: aNode [
	"STBlockNode has a variable that contains a string for each parameter,
	 and one that contains a list of statements. Here is how STBlockNodes
	 are compiled:
	 
	 push BlockClosure or CompiledBlock literal
	 make dirty block                    <--- only if pushed CompiledBlock
	 
	 Statements are put in a separate CompiledBlock object that is referenced
	 by the BlockClosure that the sequence above pushes or creates.
	 
	 compileStatements: creates the bytecodes.  It is this method that is
	 called by STCompiler>>bytecodesFor: and STCompiler>>bytecodesFor:append:"

	<category: 'visiting RBBlockNodes'>
	| bc depth block clean |
	depth := self depthSet: aNode arguments size + aNode body temporaries size.
	aNode body statements isEmpty 
	    ifTrue: [aNode body addNode: (RBLiteralNode value: nil)].
	bc := self insideNewScopeDo: 
			[self bytecodesFor: aNode
			    atEndDo: 
				[aNode body lastIsReturn ifFalse: [self compileByte: ReturnContextStackTop]]].
	block := CompiledBlock 
		    numArgs: aNode arguments size
		    numTemps: aNode body temporaries size
		    bytecodes: bc
		    depth: self maxDepth
		    literals: self literals.
	self depthSet: depth.
	clean := block flags.
	clean == 0 
	    ifTrue: 
		[self 
		    pushLiteral: (BlockClosure block: block receiver: symTable environment).
		^aNode].
	self pushLiteral: block.
	self compileByte: MakeDirtyBlock
    ]

    compileStatements: aNode [
	<category: 'visiting RBBlockNodes'>
	aNode statements keysAndValuesDo: 
		[:index :each | 
		index = 1 
		    ifFalse: 
			[self
			    depthDecr: 1;
			    compileByte: PopStackTop].
		each acceptVisitor: self].
	aNode statements isEmpty 
	    ifTrue: 
		[self
		    depthIncr;
		    compileByte: PushSpecial arg: NilIndex]
    ]

    acceptCascadeNode: aNode [
	"RBCascadeNode holds a collection with one item per message."

	<category: 'visiting RBCascadeNodes'>
	| messages first |
	messages := aNode messages.
	first := messages at: 1.
	first receiver = SuperVariable 
	    ifTrue: 
		[aNode messages do: [:each | self compileSendToSuper: each]
		    separatedBy: 
			[self
			    depthDecr: 1;
			    compileByte: PopStackTop].
		^aNode].
	first receiver acceptVisitor: self.
	self
	    depthIncr;
	    compileByte: DupStackTop.
	self compileMessage: first.
	messages 
	    from: 2
	    to: messages size - 1
	    do: 
		[:each | 
		self
		    compileByte: PopStackTop;
		    compileByte: DupStackTop.
		self compileMessage: each].
	self
	    depthDecr: 1;
	    compileByte: PopStackTop.
	self compileMessage: messages last
    ]

    acceptOptimizedNode: aNode [
	<category: 'visiting RBOptimizedNodes'>
	self depthIncr.
	self pushLiteral: (self class evaluate: aNode body parser: parser)
    ]

    acceptLiteralNode: aNode [
	"STLiteralNode has one instance variable, the token for the literal
	 it represents."

	<category: 'visiting RBLiteralNodes'>
	self depthIncr.
	aNode compiler: self.
	self pushLiteral: aNode value
    ]

    acceptAssignmentNode: aNode [
	"First compile the assigned, then the assignment to the assignee..."

	<category: 'visiting RBAssignmentNodes'>
	aNode value acceptVisitor: self.
	(VMSpecialIdentifiers includesKey: aNode variable name) 
	    ifTrue: [self compileError: 'cannot assign to ' , aNode variable name].
	self compileAssignmentFor: aNode variable
    ]

    acceptMessageNode: aNode [
	"RBMessageNode contains a message send. Its instance variable are
	 a receiver, selector, and arguments."

	<category: 'compiling'>
	| specialSelector |
	aNode receiver = SuperVariable 
	    ifTrue: 
		[self compileSendToSuper: aNode.
		^true].
	specialSelector := VMSpecialMethods at: aNode selector ifAbsent: [nil].
	specialSelector isNil 
	    ifFalse: [(self perform: specialSelector with: aNode) ifTrue: [^false]].
	aNode receiver acceptVisitor: self.
	self compileMessage: aNode
    ]

    compileMessage: aNode [
	"RBMessageNode contains a message send. Its instance variable are
	 a receiver, selector, and arguments.  The receiver has already
	 been compiled."

	<category: 'compiling'>
	| args litIndex |
	aNode arguments do: [:each | each acceptVisitor: self].
	VMSpecialSelectors at: aNode selector
	    ifPresent: 
		[:idx | 
		idx <= LastImmediateSend 
		    ifTrue: [self compileByte: idx arg: 0]
		    ifFalse: [self compileByte: SendImmediate arg: idx].
		^aNode].
	args := aNode arguments size.
	litIndex := self addLiteral: aNode selector.
	self 
	    compileByte: Send
	    arg: litIndex
	    arg: args
    ]

    compileRepeat: aNode [
	"Answer whether the loop can be optimized (that is,
	 whether the only parameter is a STBlockNode)"

	<category: 'compiling'>
	| whileBytecodes |
	aNode receiver isBlock ifFalse: [^false].
	(aNode receiver arguments isEmpty 
	    and: [aNode receiver body temporaries isEmpty]) ifFalse: [^false].
	whileBytecodes := self bytecodesFor: aNode receiver
			    atEndDo: 
				[self
				    compileByte: PopStackTop;
				    depthDecr: 1].
	self nextPutAll: whileBytecodes.
	self compileBackJump: whileBytecodes size.

	"The optimizer might like to see the return value of #repeat."
	self
	    depthIncr;
	    compileByte: PushSpecial arg: NilIndex.
	^true
    ]

    compileWhileLoop: aNode [
	"Answer whether the while loop can be optimized (that is,
	 whether the only parameter is a STBlockNode)"

	<category: 'compiling'>
	| whileBytecodes argBytecodes jumpOffsets |
	aNode receiver isBlock ifFalse: [^false].
	(aNode receiver arguments isEmpty 
	    and: [aNode receiver body temporaries isEmpty]) ifFalse: [^false].
	argBytecodes := #().
	aNode arguments do: 
		[:onlyArgument | 
		onlyArgument isBlock ifFalse: [^false].
		(onlyArgument arguments isEmpty 
		    and: [onlyArgument body temporaries isEmpty]) ifFalse: [^false].
		argBytecodes := self bytecodesFor: onlyArgument
			    atEndDo: 
				[self
				    compileByte: PopStackTop;
				    depthDecr: 1]].
	whileBytecodes := self bytecodesFor: aNode receiver.
	self nextPutAll: whileBytecodes.
	jumpOffsets := self displacementsToJumpAround: argBytecodes size
		    and: whileBytecodes size + 2.	"for jump around jump"

	"The if: clause means: if selector is whileFalse:, compile
	 a 'pop/jump if true'; else compile a 'pop/jump if false'"
	self compileJump: (self sizeOfJump: jumpOffsets value)
	    if: (aNode selector == #whileTrue or: [aNode selector == #whileTrue:]).
	self compileByte: Jump arg: jumpOffsets value.
	argBytecodes isNil ifFalse: [self nextPutAll: argBytecodes].
	self compileByte: JumpBack arg: jumpOffsets key.

	"Somebody might want to use the return value of #whileTrue:
	 and #whileFalse:"
	self
	    depthIncr;
	    compileByte: PushSpecial arg: NilIndex.
	^true
    ]

    compileSendToSuper: aNode [
	<category: 'compiling'>
	| litIndex args |
	self
	    depthIncr;
	    compileByte: PushSelf.
	aNode arguments do: [:each | each acceptVisitor: self].
	self pushLiteral: destClass superclass.
	VMSpecialSelectors at: aNode selector
	    ifPresent: 
		[:idx | 
		self compileByte: SendImmediateSuper arg: idx.
		^aNode].
	litIndex := self addLiteral: aNode selector.
	args := aNode arguments size.
	self 
	    compileByte: SendSuper
	    arg: litIndex
	    arg: args.
	self depthDecr: aNode arguments size
    ]

    compileTimesRepeat: aNode [
	<category: 'compiling'>
	"aNode receiver acceptVisitor: self."

	| block |
	block := aNode arguments first.
	(block arguments isEmpty and: [block body temporaries isEmpty]) 
	    ifFalse: [^false].
	^false
    ]

    compileLoop: aNode [
	<category: 'compiling'>
	"aNode receiver acceptVisitor: self."

	| stop step block |
	aNode arguments do: 
		[:each | 
		stop := step.	"to:"
		step := block.	"by:"
		block := each	"do:"].
	block isBlock ifFalse: [^false].
	(block arguments size = 1 and: [block body temporaries isEmpty]) 
	    ifFalse: [^false].
	stop isNil 
	    ifTrue: 
		[stop := step.
		step := OneNode	"#to:do:"]
	    ifFalse: [step isImmediate ifFalse: [^false]].
	^false
    ]

    compileBoolean: aNode [
	<category: 'compiling'>
	| bc1 ret1 bc2 selector |
	aNode arguments do: 
		[:each | 
		each isBlock ifFalse: [^false].
		(each arguments isEmpty and: [each body temporaries isEmpty]) 
		    ifFalse: [^false].
		bc1 isNil 
		    ifTrue: 
			[bc1 := self bytecodesFor: each.
			ret1 := each body lastIsReturn]
		    ifFalse: [bc2 := self bytecodesFor: each]].
	aNode receiver acceptVisitor: self.
	selector := aNode selector.
	bc2 isNil 
	    ifTrue: 
		["Transform everything into #ifTrue:ifFalse: or #ifFalse:ifTrue:"

		selector == #ifTrue: 
		    ifTrue: 
			[selector := #ifTrue:ifFalse:.
			bc2 := NilIndex	"Push nil"].
		selector == #ifFalse: 
		    ifTrue: 
			[selector := #ifFalse:ifTrue:.
			bc2 := NilIndex	"Push nil"].
		selector == #and: 
		    ifTrue: 
			[selector := #ifTrue:ifFalse:.
			bc2 := FalseIndex	"Push false"].
		selector == #or: 
		    ifTrue: 
			[selector := #ifFalse:ifTrue:.
			bc2 := TrueIndex	"Push true"].
		bc2 := 
			{PushSpecial.
			bc2}.
		^self 
		    compileBoolean: aNode
		    longBranch: bc1
		    returns: ret1
		    shortBranch: bc2
		    longIfTrue: selector == #ifTrue:ifFalse:].
	selector == #ifTrue:ifFalse: 
	    ifTrue: 
		[^self 
		    compileIfTrue: bc1
		    returns: ret1
		    ifFalse: bc2].
	selector == #ifFalse:ifTrue: 
	    ifTrue: 
		[^self 
		    compileIfFalse: bc1
		    returns: ret1
		    ifTrue: bc2].
	^self error: 'bad boolean message selector'
    ]

    compileBoolean: aNode longBranch: bc1 returns: ret1 shortBranch: bc2 longIfTrue: longIfTrue [
	<category: 'compiling'>
	self compileJump: bc1 size + (ret1 ifTrue: [0] ifFalse: [2])
	    if: longIfTrue not.
	self nextPutAll: bc1.
	ret1 ifFalse: [self compileByte: Jump arg: bc2 size].
	self nextPutAll: bc2.
	^true
    ]

    compileIfTrue: bcTrue returns: bcTrueReturns ifFalse: bcFalse [
	<category: 'compiling'>
	| trueSize |
	trueSize := bcTrueReturns 
		    ifTrue: [bcTrue size]
		    ifFalse: [bcTrue size + (self sizeOfJump: bcFalse size)].
	self compileJump: trueSize if: false.
	self nextPutAll: bcTrue.
	bcTrueReturns ifFalse: [self compileByte: Jump arg: bcFalse size].
	self nextPutAll: bcFalse.
	^true
    ]

    compileIfFalse: bcFalse returns: bcFalseReturns ifTrue: bcTrue [
	<category: 'compiling'>
	| falseSize |
	falseSize := bcFalseReturns 
		    ifTrue: [bcFalse size]
		    ifFalse: [bcFalse size + (self sizeOfJump: bcTrue size)].
	self compileJump: falseSize if: true.
	self nextPutAll: bcFalse.
	bcFalseReturns ifFalse: [self compileByte: Jump arg: bcTrue size].
	self nextPutAll: bcTrue.
	^true
    ]

    acceptReturnNode: aNode [
	<category: 'compiling'>
	aNode value acceptVisitor: self.
	self isInsideBlock 
	    ifTrue: [self compileByte: ReturnMethodStackTop]
	    ifFalse: [self compileByte: ReturnContextStackTop]
    ]

    compileAssignmentFor: aNode [
	"RBVariableNode has one instance variable, the name of the variable
	 that it represents."

	<category: 'visiting RBVariableNodes'>
	| definition |
	self checkStore: aNode name.
	definition := self lookupName: aNode name.
	(symTable isTemporary: aNode name) 
	    ifTrue: 
		[^self compileStoreTemporary: definition
		    scopes: (symTable outerScopes: aNode name)].
	(symTable isReceiver: aNode name) 
	    ifTrue: [^self compileByte: StoreReceiverVariable arg: definition].
	self compileByte: StoreLitVariable arg: definition.
	self compileByte: PopStackTop.
	self compileByte: PushLitVariable arg: definition
    ]

    acceptVariableNode: aNode [
	<category: 'visiting RBVariableNodes'>
	| locationType definition |
	self depthIncr.
	VMSpecialIdentifiers at: aNode name
	    ifPresent: 
		[:block | 
		block value: self.
		^aNode].
	definition := self lookupName: aNode name.
	(symTable isTemporary: aNode name) 
	    ifTrue: 
		[^self compilePushTemporary: definition
		    scopes: (symTable outerScopes: aNode name)].
	(symTable isReceiver: aNode name) 
	    ifTrue: 
		[self compileByte: PushReceiverVariable arg: definition.
		^aNode].
	self compileByte: PushLitVariable arg: definition
    ]

    compilePushTemporary: number scopes: outerScopes [
	<category: 'visiting RBVariableNodes'>
	outerScopes = 0 
	    ifFalse: 
		[self 
		    compileByte: PushOuterVariable
		    arg: number
		    arg: outerScopes.
		^self].
	self compileByte: PushTemporaryVariable arg: number
    ]

    compileStoreTemporary: number scopes: outerScopes [
	<category: 'visiting RBVariableNodes'>
	outerScopes = 0 
	    ifFalse: 
		[self 
		    compileByte: StoreOuterVariable
		    arg: number
		    arg: outerScopes.
		^self].
	self compileByte: StoreTemporaryVariable arg: number
    ]

    compileMethodAttributes: attributes [
	<category: 'compiling method attributes'>
	^attributes asArray 
	    collect: [:each | self compileAttribute: (RBScanner on: each readStream)]
    ]

    scanTokenFrom: scanner [
	<category: 'compiling method attributes'>
	scanner atEnd 
	    ifTrue: [^self compileError: 'method attributes must end with ''>'''].
	^scanner next
    ]

    compileAttribute: scanner [
	<category: 'compiling method attributes'>
	| currentToken selectorBuilder selector arguments argParser node |
	currentToken := self scanTokenFrom: scanner.
	(currentToken isBinary and: [currentToken value == #<]) 
	    ifFalse: [^self compileError: 'method attributes must begin with ''<'''].
	selectorBuilder := WriteStream on: String new.
	arguments := WriteStream on: Array new.
	currentToken := self scanTokenFrom: scanner.
	[currentToken isBinary and: [currentToken value == #>]] whileFalse: 
		[currentToken isKeyword 
		    ifFalse: [^self compileError: 'keyword expected in method attribute'].
		selectorBuilder nextPutAll: currentToken value.
		argParser := RBParser new.
		argParser errorBlock: parser errorBlock.
		argParser scanner: scanner.
		node := argParser parseBinaryMessageNoGreater.
		node := RBSequenceNode statements: {node}.
		arguments nextPut: (self class evaluate: node parser: argParser).
		currentToken := argParser currentToken].
	selector := selectorBuilder contents asSymbol.
	^Message selector: selector arguments: arguments contents
    ]
]



Eval [
    STCompiler initialize
]

