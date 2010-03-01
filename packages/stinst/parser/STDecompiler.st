"======================================================================
|
|   Smalltalk bytecode decompiler
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2006 Free Software Foundation, Inc.
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



RBValueToken subclass: STDecompiledValueToken [
    
    <comment: nil>
    <category: 'System-Compiler'>

    length [
	"Always answer 1 (the size of a bytecode)."

	<category: 'overrides'>
	^1
    ]
]



Object subclass: STDecompilationContext [
    | mclass outer method numTemps numArgs tmpNames current jumps instVarNames instVarNamesSet cfg basicBlocks |
    
    <category: 'System-Compiler'>
    <comment: 'This class holds the information about the current decompilation,
including the CFG and the synthetic variable names.

Most of this information is interesting to the decompilers for
the blocks, which is why the sub-contexts hold a pointer to
the outer context.'>

    STDecompilationContext class >> on: aCompiledCodeObject class: aClass outer: outerContext [
	<category: 'instance creation'>
	^self new 
	    initialize: aCompiledCodeObject
	    class: aClass
	    outer: outerContext
    ]

    initialize: aCompiledCodeObject class: aClass outer: outerContext [
	"Initialize the receiver's instance variables with information
	 about decompiling the block or method aCompiledCodeObject, found in
	 the aClass class.  If we are to decompile a block, the context
	 for the outer method is found in outerContext."

	<category: 'initialization'>
	mclass := aClass.
	outer := outerContext.
	method := aCompiledCodeObject.
	numTemps := outer isNil ifTrue: [0] ifFalse: [outer numTemps].
	numArgs := outer isNil ifTrue: [0] ifFalse: [outer numArgs].
	instVarNames := aClass allInstVarNames.
	instVarNamesSet := instVarNames asSet.
	tmpNames := IdentityDictionary new.
	jumps := IdentityDictionary new.
	0 to: self methodNumArgs - 1
	    do: [:index | tmpNames at: index put: self newArgName].
	aCompiledCodeObject dispatchTo: self with: nil.
	self buildCFG
    ]

    buildCFG [
	"Build the control-flow graph of the object to be decompiled."

	<category: 'initialization'>
	| basicBlockBoundaries n |
	basicBlockBoundaries := jumps keys collect: [:each | each + 2].
	basicBlockBoundaries addAll: (jumps values collect: [:each | each value]).
	basicBlockBoundaries add: method size + 2.

	"Build a map from bytecode numbers to basic block ids"
	basicBlocks := OrderedCollection new.
	cfg := OrderedCollection new.
	n := 1.
	basicBlockBoundaries asSortedCollection inject: 1
	    into: 
		[:old :boundary | 
		boundary > old 
		    ifTrue: 
			[boundary - old timesRepeat: [basicBlocks add: n].
			cfg addLast: (STControlFlowGraphNode id: n).
			n := n + 1].
		boundary].

	"Now use it to build the CFG"
	jumps keysAndValuesDo: 
		[:key :each | 
		(self cfgNodeAt: key) 
		    addSuccessor: each key -> (self cfgNodeAt: each value)].

	"Add arcs for falling off the basic block."
	cfg 
	    from: 1
	    to: cfg size - 1
	    do: 
		[:each | 
		each succ isNil 
		    ifTrue: [each addSuccessor: #jump -> (cfg at: each id + 1)].
		(each succ at: 1) key = #jumpTrue 
		    ifTrue: [each addSuccessor: #jumpFalse -> (cfg at: each id + 1)].
		(each succ at: 1) key = #jumpFalse 
		    ifTrue: [each addSuccessor: #jumpTrue -> (cfg at: each id + 1)]].

	"Sort in depth-first order"
	(cfg at: 1) computeDfnums: 1
    ]

    outer [
	"Answer the outer decompilation context"

	<category: 'accessing'>
	^outer
    ]

    mclass [
	"Answer the class in which the method we are decompiling lives"

	<category: 'accessing'>
	^mclass
    ]

    method [
	"Answer the method we are decompiling"

	<category: 'accessing'>
	^method
    ]

    cfg [
	"Answer an Array with all the nodes in the method's control-flow
	 graph."

	<category: 'accessing'>
	^cfg
    ]

    cfgNodeAt: bytecode [
	"Answer the node of the control-flow graph that contains information
	 for the basic block of which the given bytecode index is part"

	<category: 'accessing'>
	^cfg at: (basicBlocks at: bytecode)
    ]

    outerTemporaryAt: anIndex scopes: scopes [
	"Answer the name of the anIndex-th temporary in the scopes-th outer
	 scope"

	<category: 'accessing'>
	^scopes > 0 
	    ifTrue: [self outer outerTemporaryAt: anIndex scopes: scopes - 1]
	    ifFalse: [self temporaryAt: anIndex]
    ]

    instVarNameAt: anIndex [
	"Answer the name of the anIndex-th instance variable of the class
	 in which the decompiled method lives."

	<category: 'accessing'>
	^instVarNames at: anIndex + 1
    ]

    temporaryAt: anIndex [
	"Answer the name of the anIndex-th temporary of the decompiled method."

	<category: 'accessing'>
	^tmpNames at: anIndex
    ]

    temporaryNames [
	"Answer the name of all the temporaries of the decompiled method."

	<category: 'accessing'>
	^tmpNames values
    ]

    methodNumArgs [
	"Answer the number of arguments that the decompiled method receives."

	<category: 'accessing'>
	^method numArgs
    ]

    numArgs [
	"Answer the number of argXXX variables that have been defined so far."

	<category: 'accessing'>
	^numArgs
    ]

    numTemps [
	"Answer the number of tXXX variables that have been defined so far."

	<category: 'accessing'>
	^numTemps
    ]

    newArgName [
	"Answer a new argXXX variable"

	<category: 'accessing'>
	| candidate |
	
	[candidate := 'arg' , (numArgs := numArgs + 1) printString.
	instVarNamesSet includes: candidate] 
		whileTrue.
	^candidate
    ]

    newTemporaryName [
	"Answer a new tXXX variable"

	<category: 'accessing'>
	| candidate |
	
	[candidate := 't' , (numTemps := numTemps + 1) printString.
	instVarNamesSet includes: candidate] 
		whileTrue.
	^candidate
    ]

    invalidOpcode: unused [
	"Signal an error"

	<category: 'analyzing'>
	self error: 'invalid opcode'
    ]

    pushInstVar: anIndex with: unused [
	<category: 'analyzing'>
	
    ]

    storeInstVar: anIndex with: unused [
	<category: 'analyzing'>
	
    ]

    makeDirtyBlock: unused [
	<category: 'analyzing'>
	
    ]

    pushTemporary: anIndex outer: scopes with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	scopes > 0 
	    ifTrue: [self pushTemporary: anIndex with: unused]
	    ifFalse: 
		[outer 
		    pushTemporary: anIndex
		    outer: scopes - 1
		    with: unused]
    ]

    storeTemporary: anIndex outer: scopes with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	scopes > 0 
	    ifTrue: [self storeTemporary: anIndex with: unused]
	    ifFalse: 
		[outer 
		    storeTemporary: anIndex
		    outer: scopes - 1
		    with: unused]
    ]

    pushTemporary: anIndex with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	tmpNames at: anIndex ifAbsentPut: [self newTemporaryName]
    ]

    storeTemporary: anIndex with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	tmpNames at: anIndex ifAbsentPut: [self newTemporaryName]
    ]

    popIntoArray: anIndex with: unused [
	<category: 'analyzing'>
	
    ]

    pushLiteral: anObject with: unused [
	<category: 'analyzing'>
	
    ]

    pushGlobal: anObject with: unused [
	<category: 'analyzing'>
	
    ]

    storeGlobal: anObject with: unused [
	<category: 'analyzing'>
	
    ]

    pushSelf: unused [
	<category: 'analyzing'>
	
    ]

    popStackTop: unused [
	<category: 'analyzing'>
	
    ]

    dupStackTop: unused [
	<category: 'analyzing'>
	
    ]

    exitInterpreter: unused [
	<category: 'analyzing'>
	
    ]

    returnFromContext: unused [
	"Returns are treated as jumps to past the final bytecode"

	<category: 'analyzing'>
	self jumpTo: method size + 1 with: unused
    ]

    returnFromMethod: unused [
	"Returns are treated as jumps to past the final bytecode"

	<category: 'analyzing'>
	self jumpTo: method size + 1 with: unused
    ]

    popJumpIfFalseTo: destination with: unused [
	"Record the jump"

	<category: 'analyzing'>
	jumps at: current put: #jumpFalse -> destination
    ]

    popJumpIfTrueTo: destination with: unused [
	"Record the jump"

	<category: 'analyzing'>
	jumps at: current put: #jumpTrue -> destination
    ]

    jumpTo: destination with: unused [
	"Record the jump"

	<category: 'analyzing'>
	jumps at: current put: #jump -> destination
    ]

    lineNo: n with: unused [
	<category: 'analyzing'>
	
    ]

    superSend: aSymbol numArgs: anInteger with: unused [
	<category: 'analyzing'>
	
    ]

    send: aSymbol numArgs: anInteger with: unused [
	<category: 'analyzing'>
	
    ]

    bytecodeIndex: byte with: unused [
	<category: 'analyzing'>
	current := byte
    ]
]



Magnitude subclass: STControlFlowGraphNode [
    | id dfnum pred succ fallThrough statements stack |
    
    <category: 'System-Compiler'>
    <comment: 'This class is a node in the CFG of a method.  It knows how
to simplify itself to a single node that uses Smalltalk''s
control-structures-as-messages.'>

    STControlFlowGraphNode class >> id: id [
	"Create a new instance of the receiver"

	<category: 'instance creation'>
	^self new id: id
    ]

    printOn: aStream [
	"Print a textual representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self id;
	    nextPutAll: ' df=';
	    print: self dfnum.
	self succ isNil 
	    ifFalse: 
		[aStream 
		    print: (self succ collect: [:each | each key -> each value id]) asArray].
	statements isNil 
	    ifFalse: 
		[statements do: 
			[:each | 
			aStream
			    nl;
			    space: 4;
			    print: each]].
	aStream nl
    ]

    printTreeOn: aStream [
	"Print a textual representation of the receiver and all of its
	 successors on aStream"

	<category: 'printing'>
	(self withAllSuccessors asSortedCollection: [:a :b | a id < b id]) do: 
		[:node | 
		aStream
		    print: node;
		    nl]
    ]

    addPredecessor: node [
	"Private - Add `node' to the set of predecessors of the receiver."

	<category: 'private'>
	pred := pred isNil ifTrue: [{node}] ifFalse: [pred copyWith: node]
    ]

    removeSuccessor: node [
	"Private - Remove `node' from the set of successors of the receiver."

	<category: 'private'>
	succ isNil 
	    ifFalse: 
		[succ := succ reject: [:each | each value = node].
		succ isEmpty ifTrue: [succ := nil]]
    ]

    removePredecessor: node [
	"Private - Remove `node' from the set of predecessors of the receiver."

	<category: 'private'>
	pred isNil 
	    ifFalse: 
		[pred := pred copyWithout: node.
		pred isEmpty ifTrue: [pred := nil]]
    ]

    addAllSuccessorsTo: aSet [
	"Private - Add all the direct and indirect successors of the receiver
	 to aSet."

	<category: 'private'>
	succ isNil ifTrue: [^aSet].
	succ do: 
		[:each | 
		(aSet includes: each value) 
		    ifFalse: 
			[aSet add: each value.
			each value addAllSuccessorsTo: aSet]].
	^aSet
    ]

    computeDfnums: n [
	"Private - Number the receiver and all of its direct and
	 indirect successors in depth-first order, starting from n."

	<category: 'private'>
	| num |
	self dfnum isNil ifFalse: [^n].
	self dfnum: n.
	num := n + 1.
	self succ isNil 
	    ifFalse: [succ do: [:each | num := each value computeDfnums: num]].
	^num
    ]

    < anObject [
	"Sort in depth-first order"

	<category: 'comparison'>
	^self dfnum < anObject dfnum
    ]

    = anObject [
	"Sort in depth-first order"

	<category: 'comparison'>
	^self class == anObject class and: [self dfnum = anObject dfnum]
    ]

    hash [
	"Sort in depth-first order"

	<category: 'comparison'>
	^self dfnum
    ]

    allSuccessors [
	"Answer the set of all direct and indirect successors of
	 the receiver"

	<category: 'accessing'>
	^self addAllSuccessorsTo: Set new
    ]

    withAllSuccessors [
	"Answer the set of all the nodes in the receiver's CFG, that
	 is the node and all of its direct and indirect successors."

	<category: 'accessing'>
	^(self addAllSuccessorsTo: Set new)
	    add: self;
	    yourself
    ]

    dfnum [
	"Answer the progressive number of the receiver in a depth-first
	 visit of the graph."

	<category: 'accessing'>
	^dfnum
    ]

    dfnum: n [
	"Set the progressive number of the receiver in a depth-first
	 visit of the graph."

	<category: 'accessing'>
	dfnum := n
    ]

    id [
	"Answer a numeric identifier for the receiver.  Consecutive indexes
	 represent basic blocks that are adjacent in memory."

	<category: 'accessing'>
	^id
    ]

    id: n [
	"Set the numeric identifier for the receiver.  Consecutive indexes
	 represent basic blocks that are adjacent in memory."

	<category: 'accessing'>
	id := n
    ]

    pred [
	"Answer the set of predecessors of the receiver."

	<category: 'accessing'>
	^pred
    ]

    succ [
	"Answer the set of successors of the receiver."

	<category: 'accessing'>
	^succ
    ]

    succ: newSucc [
	"Set the set of successors of the receiver to be newSucc.
	 newSucc should hold associations that represent the kind
	 of jump (#jump, #jumpTrue, #jumpFalse) in the key, and
	 the destination basic block in the value."

	<category: 'accessing'>
	succ isNil 
	    ifFalse: 
		[succ do: [:each | each value removePredecessor: self].
		succ := nil].
	succ := newSucc.
	succ isNil ifTrue: [^self].
	succ do: [:assoc | assoc value addPredecessor: self]
    ]

    statements [
	"Answer the set of statements executed by the receiver"

	<category: 'accessing'>
	^ statements ifNil: [ #() ]
    ]

    statements: aCollection [
	"Set the set of statements executed by the receiver"

	<category: 'accessing'>
	statements := aCollection
    ]

    stack [
	"Answer the state of the stack after the receiver completes
	 its execution"

	<category: 'accessing'>
	stack isNil ifTrue: [stack := OrderedCollection new].
	^stack
    ]

    stack: aCollection [
	"Set the state of the stack after the receiver completes
	 its execution"

	<category: 'accessing'>
	stack := aCollection
    ]

    fallThroughIfFalse [
	"Answer whether the receiver ends with a `jump if true'
	 bytecode"

	<category: 'accessing'>
	^fallThrough = #jumpFalse
    ]

    fallThroughIfTrue [
	"Answer whether the receiver ends with a `jump if false'
	 bytecode"

	<category: 'accessing'>
	^fallThrough = #jumpTrue
    ]

    addSuccessor: kindBlockAssociation [
	"Add the successor represented by kindBlockAssociation,
	 which should be an association that represents the kind
	 of jump (#jump, #jumpTrue, #jumpFalse) in the key, and
	 the destination basic block in the value."

	<category: 'accessing'>
	kindBlockAssociation value id = (self id + 1) 
	    ifTrue: [fallThrough := kindBlockAssociation key].
	succ := succ isNil 
		    ifTrue: [{kindBlockAssociation}]
		    ifFalse: [succ copyWith: kindBlockAssociation].
	kindBlockAssociation value addPredecessor: self
    ]

    blkNode: statements arguments: args [
	"Private - Answer an RBBlockNode with the given statements
	 and arguments."

	<category: 'simplification'>
	^(RBBlockNode new)
	    body: (self seqNode: statements);
	    arguments: args
    ]

    blkNode: statements [
	"Private - Answer an RBBlockNode with the given statements."

	<category: 'simplification'>
	^(RBBlockNode new)
	    body: (self seqNode: statements);
	    arguments: #()
    ]

    msgNode: arguments receiver: receiver selector: aSymbol [
	"Private - Answer an RBMessageNode with the given arguments,
	 receiver and selector."

	<category: 'simplification'>
	| selParts |
	selParts := aSymbol keywords 
		    collect: [:each | RBValueToken new value: each].
	^(RBMessageNode new)
	    arguments: arguments;
	    receiver: receiver;
	    selectorParts: selParts
    ]

    seqNode: statements [
	"Private - Answer an RBSequenceNode with the given statements."

	<category: 'simplification'>
	^(RBSequenceNode new)
	    temporaries: #();
	    statements: statements;
	    periods: #()
    ]

    disconnect [
	"Disconnect the receiver from the graph (removing
	 all arcs that point to it or depart from it)."

	<category: 'simplification'>
	pred isNil 
	    ifFalse: 
		[pred do: [:each | each removeSuccessor: self].
		pred := nil].
	self succ: nil
    ]

    disconnectSuccessorsAndMerge: newSucc [
	"Disconnect the receiver's successors from the graph (removing
	 all arcs that point to them or depart from them),
	 then try to merge the receiver with its predecessor
	 (if there is only one after the disconnection) and
	 possibly with the new successors, newSucc (if there
	 is only one and it has no other predecessors than the
	 receiver)."

	<category: 'simplification'>
	succ do: [:each | each value disconnect].
	self merge: newSucc
    ]

    merge: succSet [
	"Try to merge the receiver with its predecessor
	 (if there is only one after the disconnection) and
	 possibly with the new successors, succSet (if there
	 is only one and it has no other predecessors than the
	 receiver)."

	<category: 'simplification'>
	| newSelf newSucc theSucc |
	newSucc := succSet.
	newSelf := self.
	self succ: newSucc.
	newSelf pred size = 1 
	    ifTrue: 
		[newSelf := pred at: 1.
		newSelf statements addAllLast: self statements.
		self disconnect.
		newSelf succ: newSucc].
	
	[newSucc size = 1 ifFalse: [^self].
	theSucc := (newSucc at: 1) value.
	theSucc pred size = 1 ifFalse: [^self].
	newSelf statements addAllLast: theSucc statements.
	newSucc := theSucc succ.
	theSucc disconnect] 
		repeat
    ]

    simplify [
	"Recognize simple control structures in the receiver and
	 reduce them to a single basic block that sends the appropriate
	 Smalltalk messages."

	<category: 'simplification'>
	self
	    simplifyRepeat;
	    simplifyIf;
	    simplifyLoop
    ]

    simplifyIf: cond then: arm2 else: arm1 ifTrueIfFalse: ifTrueIfFalse [
	"Simplify a two-way conditional.  cond used to be the
	 last statement of the receiver, arm1 and arm2 are the
	 receiver's successor basic blocks."

	<category: 'simplification'>
	"'resolving if/then/else' displayNl."

	| block1 block2 |
	block2 := self blkNode: arm2 statements.
	block1 := self blkNode: arm1 statements.
	self statements addLast: (self 
		    msgNode: 
			{block1.
			block2}
		    receiver: cond
		    selector: (ifTrueIfFalse 
			    ifTrue: [#ifTrue:ifFalse:]
			    ifFalse: [#ifFalse:ifTrue:]))
    ]

    simplifyIf: cond then: arm ifTrue: ifTrue [
	"Simplify a one-way conditional.  cond used to be the
	 last statement of the receiver, arm is one of the
	 receiver's successor basic blocks."

	<category: 'simplification'>
	"'resolving if/then' displayNl."

	| seq block |
	block := self blkNode: arm statements.
	self statements addLast: (self 
		    msgNode: {block}
		    receiver: cond
		    selector: (ifTrue ifTrue: [#ifTrue:] ifFalse: [#ifFalse:]))
    ]

    simplifyIf [
	"Recognize conditional control structures where the
	 receiver is the header, and simplify them."

	<category: 'simplification'>
	| cond arm1 arm2 |
	succ size < 2 ifTrue: [^false].
	arm1 := (self succ at: 1) value.
	arm2 := (self succ at: 2) value.
	((arm1 succ at: 1) value = (arm2 succ at: 1) value 
	    and: [(arm1 succ at: 1) value ~= self and: [(arm2 succ at: 1) value ~= self]]) 
		ifTrue: 
		    [self
			simplifyIf: self statements removeLast
			    then: arm1
			    else: arm2
			    ifTrueIfFalse: self fallThroughIfFalse;
			disconnectSuccessorsAndMerge: arm1 succ.
		    ^true].
	((arm2 succ at: 1) value = arm1 and: [(arm2 succ at: 1) value ~= self]) 
	    ifTrue: 
		[self
		    simplifyIf: self statements removeLast
			then: arm2
			ifTrue: self fallThroughIfTrue;
		    disconnectSuccessorsAndMerge: arm1 succ.
		^true].
	^false
    ]

    simplifyWhile: body whileTrue: whileTrue [
	"Simplify a #whileTrue: or #whileFalse: control structure
	 where the receiver will be the receiver block, and body
	 the argument block."

	<category: 'simplification'>
	"'resolving while' displayNl."

	| cond block |
	cond := self blkNode: self statements.
	block := self blkNode: body statements.
	self 
	    statements: (OrderedCollection with: (self 
			    msgNode: {block}
			    receiver: cond
			    selector: (whileTrue ifTrue: [#whileTrue:] ifFalse: [#whileFalse:])))
    ]

    simplifyTimesRepeat: body newSucc: newSucc [
	"Simplify a #timesRepeat: control structure."

	<category: 'simplification'>
	"'resolving timesRepeat' displayNl."

	| to block |
	(newSucc statements)
	    removeFirst;
	    removeFirst.
	(self statements)
	    removeLast;
	    removeLast.
	(body statements)
	    removeLast;
	    removeLast.
	((self pred at: 2) statements)
	    removeLast;
	    removeLast.
	to := self statements removeLast.
	block := self blkNode: body statements.
	self statements addLast: (self 
		    msgNode: {block}
		    receiver: to
		    selector: #timesRepeat:)
    ]

    simplifyToByDo: body newSucc: newSucc [
	"Simplify a #to:do: or #to:by:do: control structure."

	<category: 'simplification'>
	| variable from to by block |
	(self statements at: self statements size - 2) isAssignment 
	    ifFalse: [^self simplifyTimesRepeat: body newSucc: newSucc].

	"'resolving to/by/do' displayNl."
	(newSucc statements)
	    removeFirst;
	    removeFirst.
	self statements removeLast.
	to := self statements removeLast.
	from := self statements last value.
	variable := self statements removeLast variable.
	by := body statements removeLast value arguments at: 1.
	(body statements)
	    removeLast;
	    removeLast;
	    removeLast.
	((self pred at: 2) statements)
	    removeLast;
	    removeLast;
	    removeLast;
	    removeLast.
	block := self blkNode: body statements arguments: {variable}.
	self statements addLast: (self 
		    msgNode: (by = 1 
			    ifTrue: 
				[
				{to.
				block}]
			    ifFalse: 
				[
				{to.
				by.
				block}])
		    receiver: from
		    selector: (by = 1 ifFalse: [#to:by:do:] ifTrue: [#to:do:]))
    ]

    simplifyLoop [
	"Recognize looping control structures where the
	 receiver is the dominator, and simplify them."

	<category: 'simplification'>
	| middle bottom |
	succ size < 2 ifTrue: [^false].
	pred isNil ifTrue: [^false].
	bottom := succ detect: [:each | pred includes: each value] ifNone: [^false].
	middle := succ detect: [:each | each ~= bottom].
	middle value statements size = 0 
	    ifFalse: 
		[self simplifyToByDo: bottom value newSucc: middle value.
		self disconnectSuccessorsAndMerge: {middle}]
	    ifTrue: 
		[self simplifyWhile: bottom value whileTrue: self fallThroughIfFalse.
		self disconnectSuccessorsAndMerge: middle value succ].
	^true
    ]

    simplifyRepeat [
	"Recognize and simplify infinite loops (#repeat)."

	<category: 'simplification'>
	| block |
	self succ isNil ifTrue: [^false].
	(self succ at: 1) value = self ifFalse: [^false].

	"'resolving repeat' displayNl."
	block := self blkNode: self statements.
	self statements: 
		{self 
		    msgNode: #()
		    receiver: block
		    selector: #repeat}.
	self merge: nil.
	^true
    ]
]



Object subclass: STDecompiler [
    | context stack statements isBlock current bbList bb |
    
    <category: 'System-Compiler'>
    <comment: 'This class converts bytecodes back to parse trees.'>

    STDecompiler class >> decompile: aSelector in: aClass [
	"Answer the source code for the selector aSelector of the
	 given class"

	<category: 'instance creation'>
	| node |
	node := self parseTreeForMethod: aClass >> aSelector in: aClass.
	^RBFormatter new format: node
    ]

    STDecompiler class >> parseTreeForMethod: aMethod in: aClass [
	"Answer the parse tree for the method aMethod of the
	 given class"

	<category: 'instance creation'>
	^self new decompileMethod: (STDecompilationContext 
		    on: aMethod
		    class: aClass
		    outer: nil)
    ]

    STDecompiler class >> parseTreeForBlock: aBlock from: aDecompilerObject [
	"Answer the parse tree for the block aBlock, considering
	 the information already dug by aDecompilerObject"

	<category: 'instance creation'>
	^self new decompileBlock: (STDecompilationContext 
		    on: aBlock
		    class: aDecompilerObject context mclass
		    outer: aDecompilerObject context)
    ]

    STDecompiler class >> testRepeat [
	"A meaningless method to test #repeat simplification"

	<category: 'test'>
	| c |
	c := 'c'.
	
	[c * 2.
	true ifTrue: [c * c].
	2 * c] repeat
    ]

    STDecompiler class >> testIfTrue [
	"A meaningless method to test #ifTrue: simplification"

	<category: 'test'>
	| a b c |
	a := 'a'.
	b := 'b'.
	c := 'c'.
	a = b ifTrue: [c * c]
    ]

    STDecompiler class >> testWhile [
	"A meaningless method to test #whileTrue: simplification"

	<category: 'test'>
	| a b c |
	a := 'a'.
	b := 'b'.
	c := 'c'.
	
	[b = 1.
	1 = b] whileFalse: 
		    [c * 1.
		    1 * c].
	
	[b = 2.
	2 = b] whileTrue: 
		    [c * 2.
		    2 * c]
    ]

    STDecompiler class >> testToByDo [
	"A meaningless method to test #to:by:do: simplification"

	<category: 'test'>
	| a b c |
	a := 'a'.
	b := 'b'.
	c := 'c'.
	a to: b
	    by: 3
	    do: 
		[:i | 
		a = b.
		c = i]
    ]

    STDecompiler class >> test [
	"Do some tests"

	<category: 'test'>
	(self decompile: #testToByDo in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #testWhile in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #testIfTrue in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #testRepeat in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #path in: VariableBinding) displayNl.
	'' displayNl.
	(self decompile: #bindWith: in: CharacterArray) displayNl.
	'' displayNl.
	(self decompile: #detect: in: Iterable) displayNl.
	'' displayNl.
	(self decompile: #key:value:environment: in: HomedAssociation class) 
	    displayNl.
	'' displayNl.
	(self decompile: #storeOn: in: VariableBinding) displayNl.
	'' displayNl.
	(self decompile: #contents in: MappedCollection) displayNl.
	'' displayNl.
	(self decompile: #collect: in: MappedCollection) displayNl.
	'' displayNl.
	(self decompile: #repeat in: BlockClosure) displayNl.
	'' displayNl.
	(self decompile: #binaryRepresentationObject in: Object) displayNl.
	'' displayNl.
	(self decompile: #whileTrue: in: BlockClosure) displayNl.
	'' displayNl.
	(self decompile: #become: in: Object) displayNl.
	'' displayNl.
	(self decompile: #timesRepeat: in: Integer) displayNl
    ]

    context [
	<category: 'auxiliary'>
	^context
    ]

    source [
	"Answer a dummy source code object to be used to insert
	 primitive names in the decompiled code."

	<category: 'auxiliary'>
	^context method primitive > 0 
	    ifTrue: 
		['<primitive: %1>' % {VMPrimitives keyAtValue: context method primitive}]
	    ifFalse: ['']
    ]

    tags: source [
	<category: 'auxiliary'>
	^source isEmpty ifTrue: [#()] ifFalse: [{1 to: source size}]
    ]

    argumentNames [
	<category: 'auxiliary'>
	^(0 to: context methodNumArgs - 1) 
	    collect: [:each | context temporaryAt: each]
    ]

    arguments [
	<category: 'auxiliary'>
	^self argumentNames collect: [:each | self varNode: each]
    ]

    selectorParts: aSymbol [
	<category: 'auxiliary'>
	^aSymbol keywords 
	    collect: [:each | RBValueToken value: each start: current]
    ]

    temporaries [
	<category: 'auxiliary'>
	^self temporaryNames collect: [:each | self varNode: each]
    ]

    temporaryNames [
	<category: 'auxiliary'>
	^(context temporaryNames asOrderedCollection)
	    removeAll: self argumentNames;
	    yourself
    ]

    litNode: anObject [
	<category: 'auxiliary'>
	| tok |
	anObject class == BlockClosure 
	    ifTrue: [^self class parseTreeForBlock: anObject block from: self].
	tok := anObject class == Association 
		    ifFalse: [RBLiteralToken value: anObject start: current]
		    ifTrue: [RBBindingToken value: anObject path start: current].
	^RBLiteralNode new literalToken: tok
    ]

    varNode: name [
	<category: 'auxiliary'>
	^RBVariableNode new 
	    identifierToken: (STDecompiledValueToken value: name start: current)
    ]

    assignment: name [
	<category: 'auxiliary'>
	^(RBAssignmentNode new)
	    value: stack removeLast;
	    variable: (self varNode: name)
    ]

    decompileBlock: stDecompilationContext [
	<category: 'decompilation'>
	isBlock := true.
	^(RBBlockNode new)
	    body: (self decompileBody: stDecompilationContext);
	    arguments: self arguments;
	    yourself
    ]

    decompileMethod: stDecompilationContext [
	<category: 'decompilation'>
	| parseNode |
	isBlock := false.
	^(parseNode := RBMethodNode new)
	    body: (self decompileBody: stDecompilationContext);
	    selectorParts: (self selectorParts: context method selector);
	    source: self source;
	    tags: (self tags: parseNode source);
	    arguments: self arguments;
	    yourself
    ]

    decompileBody: stDecompilationContext [
	<category: 'decompilation'>
	| seq |
	context := stDecompilationContext.
	stack := OrderedCollection new.
	bbList := SortedCollection new.
	context method dispatchTo: self with: nil.
	self bytecodeIndex: context method size + 1 with: nil.
	self simplify.
	seq := (RBSequenceNode new)
		    temporaries: self temporaries;
		    statements: (context cfg at: 1) statements;
		    periods: #().
	^seq
    ]

    doCascade: send [
	<category: 'decompilation'>
	(stack notEmpty and: [stack last isCascade]) 
	    ifFalse: 
		[stack 
		    addLast: (RBCascadeNode new messages: (OrderedCollection with: send))]
	    ifTrue: 
		[send parent: stack last.
		stack last messages addLast: send]
    ]

    endStatement [
	<category: 'decompilation'>
	statements addLast: stack removeLast
    ]

    invalidOpcode: unused [
	<category: 'analyzing'>
	self error: 'invalid opcode'
    ]

    makeDirtyBlock: unused [
	<category: 'analyzing'>
	
    ]

    pushInstVar: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: (context instVarNameAt: anIndex))
    ]

    storeInstVar: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self assignment: (context instVarNameAt: anIndex))
    ]

    pushTemporary: anIndex outer: scopes with: unused [
	<category: 'analyzing'>
	stack 
	    addLast: (self varNode: (context outerTemporaryAt: anIndex scopes: scopes))
    ]

    storeTemporary: anIndex outer: scopes with: unused [
	<category: 'analyzing'>
	stack addLast: (self 
		    assignment: (context outerTemporaryAt: anIndex scopes: scopes))
    ]

    pushTemporary: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: (context temporaryAt: anIndex))
    ]

    storeTemporary: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self assignment: (context temporaryAt: anIndex))
    ]

    popIntoArray: anIndex with: unused [
	<category: 'analyzing'>
	| value |
	value := stack removeLast.
	anIndex = 0 
	    ifTrue: 
		[stack removeLast.
		stack 
		    addLast: (RBArrayConstructorNode new body: ((RBSequenceNode new)
				    temporaries: #();
				    statements: OrderedCollection new;
				    periods: #()))].
	stack last body addNode: value
    ]

    pushLiteral: anObject with: unused [
	<category: 'analyzing'>
	stack addLast: (self litNode: anObject)
    ]

    pushGlobal: anObject with: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: anObject path)
    ]

    storeGlobal: anObject with: unused [
	<category: 'analyzing'>
	stack addLast: (self assignment: anObject path)
    ]

    pushSelf: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: 'self')
    ]

    isCascadeLast [
	<category: 'analyzing'>
	^stack size >= 2 and: [(stack at: stack size - 1) isCascade]
    ]

    isCascade [
	<category: 'analyzing'>
	(stack size >= 3 and: [(stack at: stack size - 2) isCascade]) 
	    ifTrue: [^true].
	^stack size >= 2 and: 
		[stack last isMessage 
		    and: [(stack at: stack size - 1) == stack last receiver]]
    ]

    popStackTop: unused [
	<category: 'analyzing'>
	| send receiver |
	self isCascade ifFalse: [^self endStatement].

	"There are two possible cases:
	 
	 the receiver		-->	an RBCascadeNode
	 the new message send		the receiver
	 
	 the RBCascadeNode		augmented RBCascadeNode
	 the receiver		-->	the receiver
	 the new message send"
	send := stack removeLast.
	receiver := stack removeLast.
	self doCascade: send.
	stack addLast: receiver
    ]

    dupStackTop: unused [
	<category: 'analyzing'>
	stack addLast: (stack at: stack size)
    ]

    exitInterpreter: unused [
	<category: 'analyzing'>
	
    ]

    returnFromContext: unused [
	<category: 'analyzing'>
	isBlock 
	    ifTrue: [self endStatement]
	    ifFalse: [self returnFromMethod: unused]
    ]

    returnFromMethod: unused [
	<category: 'analyzing'>
	| retVal |
	retVal := stack removeLast.
	stack size timesRepeat: [statements addAllLast: stack removeFirst].
	statements addLast: (RBReturnNode value: retVal)
    ]

    popJumpIfFalseTo: destination with: unused [
	<category: 'analyzing'>
	
    ]

    popJumpIfTrueTo: destination with: unused [
	<category: 'analyzing'>
	
    ]

    jumpTo: destination with: unused [
	<category: 'analyzing'>
	
    ]

    lineNo: n with: unused [
	<category: 'analyzing'>
	
    ]

    superSend: aSymbol numArgs: anInteger with: unused [
	"Pop the class at which we start the search."

	<category: 'analyzing'>
	stack removeLast.
	stack at: stack size - anInteger put: (self varNode: 'super').
	^self 
	    send: aSymbol
	    numArgs: anInteger
	    with: unused
    ]

    send: aSymbol numArgs: anInteger with: unused [
	<category: 'analyzing'>
	"Not a very efficient check, but a rare one indeed (who
	 sends #thisContext?)"

	| args collection msg |
	(aSymbol == #thisContext 
	    and: [stack last = self varNode: ContextPart binding path]) 
		ifTrue: 
		    [stack
			removeLast;
			addLast: (self varNode: 'thisContext').
		    ^self].
	args := Array new: anInteger.
	anInteger to: 1
	    by: -1
	    do: [:each | args at: each put: stack removeLast].
	stack addLast: ((RBMessageNode new)
		    arguments: args;
		    receiver: stack removeLast;
		    selectorParts: (self selectorParts: aSymbol)).

	"If the receiver was over an RBCascadeNode, merge the send
	 with the cascade."
	self isCascadeLast ifTrue: [self doCascade: stack removeLast]
    ]

    bytecodeIndex: byte with: unused [
	<category: 'analyzing'>
	| newBB |
	current := byte.
	newBB := context cfgNodeAt: byte.
	newBB == bb 
	    ifFalse: 
		[self newBasicBlock: newBB.
		statements := OrderedCollection new.
		bb := newBB]
    ]

    newBasicBlock: newBB [
	<category: 'analyzing'>
	bb isNil ifTrue: [^self].
	bb dfnum isNil ifTrue: [^self].
	statements addAllLast: stack.
	bb statements: statements.
	bbList add: bb.
	bb succ do: 
		[:each | 
		each value stack: stack copy.
		each key = #jump ifFalse: [each value stack removeLast]].
	stack := newBB stack
    ]

    simplify [
	<category: 'analyzing'>
	| oldSize goOn |
	bbList := bbList asArray.
	
	[bbList := bbList select: 
			[:each | 
			each succ size >= 2 
			    or: [each succ notNil and: [(each succ at: 1) value id <= each id]]].
	bbList isEmpty] 
		whileFalse: [bbList do: [:each | each simplify]]
    ]
]

