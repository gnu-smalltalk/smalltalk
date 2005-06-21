"======================================================================
|
|   Smalltalk bytecode decompiler
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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


RBValueToken subclass: #STDecompiledValueToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
! 

Object subclass: #STDecompilationContext
       instanceVariableNames: 'mclass outer method numTemps numArgs tmpNames current jumps instVarNames instVarNamesSet cfg basicBlocks '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
! 

STDecompilationContext comment:
'This class holds the information about the current decompilation,
including the CFG and the synthetic variable names.

Most of this information is interesting to the decompilers for
the blocks, which is why the sub-contexts hold a pointer to
the outer context.'!

Magnitude subclass: #STControlFlowGraphNode
       instanceVariableNames: 'id dfnum pred succ fallThrough statements stack '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STControlFlowGraphNode comment:
'This class is a node in the CFG of a method.  It knows how
to simplify itself to a single node that uses Smalltalk''s
control-structures-as-messages.'!

Object subclass: #STDecompiler
       instanceVariableNames: 'context stack statements isBlock current bbList bb '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
! 

STDecompiler comment:
'This class converts bytecodes back to parse trees.'!

!STDecompiledValueToken methodsFor: 'overrides'!

length
    "Always answer 1 (the size of a bytecode)."
    ^1! !

!STDecompilationContext class methodsFor: 'instance creation'!

on: aCompiledCodeObject class: aClass outer: outerContext
    ^self new initialize: aCompiledCodeObject class: aClass outer: outerContext!

!STDecompilationContext methodsFor: 'initialization'!

initialize: aCompiledCodeObject class: aClass outer: outerContext
    "Initialize the receiver's instance variables with information
     about decompiling the block or method aCompiledCodeObject, found in
     the aClass class.  If we are to decompile a block, the context
     for the outer method is found in outerContext."

    mclass := aClass.
    outer := outerContext.
    method := aCompiledCodeObject.
    numTemps := outer isNil ifTrue: [ 0 ] ifFalse: [ outer numTemps ].
    numArgs := outer isNil ifTrue: [ 0 ] ifFalse: [ outer numArgs ].
    instVarNames := aClass allInstVarNames.
    instVarNamesSet := instVarNames asSet.
    tmpNames := IdentityDictionary new.
    jumps := IdentityDictionary new.

    0 to: self methodNumArgs - 1
	do: [ :index | tmpNames at: index put: self newArgName ].

    aCompiledCodeObject dispatchTo: self with: nil.
    self buildCFG.
!

buildCFG
    "Build the control-flow graph of the object to be decompiled."

    | basicBlockBoundaries n |
    basicBlockBoundaries := jumps keys collect: [ :each |
	method nextByteCodeIndex: each ].
    basicBlockBoundaries addAll: (jumps values collect: [ :each |
	each value ]).
    basicBlockBoundaries add: method size + 2.

    "Build a map from bytecode numbers to basic block ids"
    basicBlocks := OrderedCollection new.
    cfg := OrderedCollection new.
    n := 1.
    basicBlockBoundaries asSortedCollection inject: 1 into: [ :old :boundary |
	boundary > old ifTrue: [
	    boundary - old timesRepeat: [ basicBlocks add: n ].
	    cfg addLast: (STControlFlowGraphNode id: n).
	    n := n + 1.
	].
	boundary
    ].

    "Now use it to build the CFG"
    jumps keysAndValuesDo: [ :key :each |
	(self cfgNodeAt: key)
	    addSuccessor: each key -> (self cfgNodeAt: each value).
    ].

    "Add arcs for falling off the basic block."
    cfg from: 1 to: cfg size - 1 do: [ :each |
	each succ isNil ifTrue: [
	    each addSuccessor: #jump -> (cfg at: each id + 1) ].

	(each succ at: 1) key = #jumpTrue ifTrue: [
	    each addSuccessor: #jumpFalse -> (cfg at: each id + 1) ].

	(each succ at: 1) key = #jumpFalse ifTrue: [
	    each addSuccessor: #jumpTrue -> (cfg at: each id + 1) ].
    ].

    "Sort in depth-first order"
    (cfg at: 1) computeDfnums: 1
! !

!STDecompilationContext methodsFor: 'accessing'!

outer
    "Answer the outer decompilation context"
    ^outer!

mclass
    "Answer the class in which the method we are decompiling lives"
    ^mclass!

method
    "Answer the method we are decompiling"
    ^method!

cfg
    "Answer an Array with all the nodes in the method's control-flow
     graph."
    ^cfg!

cfgNodeAt: bytecode
    "Answer the node of the control-flow graph that contains information
     for the basic block of which the given bytecode index is part"

    ^cfg at: (basicBlocks at: bytecode)!

outerTemporaryAt: anIndex scopes: scopes
    "Answer the name of the anIndex-th temporary in the scopes-th outer
     scope"

    ^scopes > 0
	ifTrue: [ self outer outerTemporaryAt: anIndex scopes: scopes - 1 ]
	ifFalse: [ self temporaryAt: anIndex ]!

instVarNameAt: anIndex
    "Answer the name of the anIndex-th instance variable of the class
     in which the decompiled method lives."

    ^instVarNames at: anIndex + 1!

temporaryAt: anIndex
    "Answer the name of the anIndex-th temporary of the decompiled method."

    ^tmpNames at: anIndex!

temporaryNames
    "Answer the name of all the temporaries of the decompiled method."

    ^tmpNames values!

methodNumArgs
    "Answer the number of arguments that the decompiled method receives."

    ^method numArgs!

numArgs
    "Answer the number of argXXX variables that have been defined so far."

    ^numArgs!

numTemps
    "Answer the number of tXXX variables that have been defined so far."

    ^numTemps!

newArgName
    "Answer a new argXXX variable"

    | candidate |
    [
	candidate := 'arg', (numArgs := numArgs + 1) printString.
	instVarNamesSet includes: candidate
    ] whileTrue.
    ^candidate!

newTemporaryName
    "Answer a new tXXX variable"

    | candidate |
    [
	candidate := 't', (numTemps := numTemps + 1) printString.
	instVarNamesSet includes: candidate
    ] whileTrue.
    ^candidate!

!STDecompilationContext methodsFor: 'analyzing'!

invalidOpcode: unused
    "Signal an error"

    self error: 'invalid opcode'!

pushInstVar: anIndex with: unused
!

storeInstVar: anIndex with: unused
!

makeDirtyBlock: unused
!

pushTemporary: anIndex outer: scopes with: unused
    "Create the name of the given temporary"

    scopes > 0
	ifTrue: [ self pushTemporary: anIndex with: unused ]
	ifFalse: [ outer pushTemporary: anIndex outer: scopes - 1 with: unused ]
!

storeTemporary: anIndex outer: scopes with: unused
    "Create the name of the given temporary"

    scopes > 0
	ifTrue: [ self storeTemporary: anIndex with: unused ]
	ifFalse: [ outer storeTemporary: anIndex outer: scopes - 1 with: unused ]
!

pushTemporary: anIndex with: unused
    "Create the name of the given temporary"

    tmpNames at: anIndex ifAbsentPut: [ self newTemporaryName ]!

storeTemporary: anIndex with: unused
    "Create the name of the given temporary"

    tmpNames at: anIndex ifAbsentPut: [ self newTemporaryName ]!

popIntoArray: anIndex with: unused
!

pushLiteral: anObject with: unused
!

pushGlobal: anObject with: unused
!

storeGlobal: anObject with: unused
!

pushSelf: unused
!

popStackTop: unused
!

dupStackTop: unused
!

exitInterpreter: unused
!

returnFromContext: unused
    "Returns are treated as jumps to past the final bytecode"

    self jumpTo: method size + 1 with: unused
!

returnFromMethod: unused
    "Returns are treated as jumps to past the final bytecode"

    self jumpTo: method size + 1 with: unused
!

popJumpIfFalseTo: destination with: unused
    "Record the jump"

    jumps at: current put: #jumpFalse->destination!

popJumpIfTrueTo: destination with: unused
    "Record the jump"

    jumps at: current put: #jumpTrue->destination!

jumpTo: destination with: unused
    "Record the jump"

    jumps at: current put: #jump->destination!

superSend: aSymbol numArgs: anInteger with: unused
!

send: aSymbol numArgs: anInteger with: unused
!

bytecodeIndex: byte with: unused
    current := byte.
! !

!STControlFlowGraphNode class methodsFor: 'instance creation'!

id: id
    "Create a new instance of the receiver"

    ^self new id: id!

!STControlFlowGraphNode methodsFor: 'printing'!

printOn: aStream 
    "Print a textual representation of the receiver on aStream"

    aStream
	print: self id;
	nextPutAll: ' df=';
	print: self dfnum.

    self succ isNil ifFalse: [
	aStream print: (self succ
    	    collect: [ :each | each key -> each value id ]) asArray
    ].
    statements isNil ifFalse: [
        statements do: [ :each |
	    aStream nl; space: 4; print: each
        ]
    ].
    aStream nl!

printTreeOn: aStream 
    "Print a textual representation of the receiver and all of its
     successors on aStream"

    (self withAllSuccessors asSortedCollection: [ :a :b | a id < b id ])
	do: [ :node | aStream print: node; nl ]!

!STControlFlowGraphNode methodsFor: 'private'!

addPredecessor: node
    "Private - Add `node' to the set of predecessors of the receiver."

    pred := pred isNil
	ifTrue: [ {node} ]
	ifFalse: [ pred copyWith: node ]!

removeSuccessor: node
    "Private - Remove `node' from the set of successors of the receiver."

    succ isNil
	ifFalse: [ succ := succ reject: [ :each | each value = node ].
	    succ isEmpty ifTrue: [ succ := nil ]
	]!

removePredecessor: node
    "Private - Remove `node' from the set of predecessors of the receiver."

    pred isNil
	ifFalse: [ pred := pred copyWithout: node.
	    pred isEmpty ifTrue: [ pred := nil ]
	]!

addAllSuccessorsTo: aSet
    "Private - Add all the direct and indirect successors of the receiver
     to aSet."

    succ isNil ifTrue: [ ^aSet ].
    succ do: [ :each |
	(aSet includes: each value) ifFalse: [
	    aSet add: each value.
	    each value addAllSuccessorsTo: aSet ]
    ].
    ^aSet!

computeDfnums: n
    "Private - Number the receiver and all of its direct and
     indirect successors in depth-first order, starting from n."

    | num |
    self dfnum isNil ifFalse: [ ^n ].
    self dfnum: n.
    num := n + 1.
    self succ isNil ifFalse: [
	succ do: [ :each |
	    num := each value computeDfnums: num
	]
    ].
    ^num! !
 
!STControlFlowGraphNode methodsFor: 'comparison'!

< anObject
    "Sort in depth-first order"

    ^self dfnum < anObject dfnum!

= anObject
    "Sort in depth-first order"

    ^self class == anObject class and: [
	self dfnum = anObject dfnum ]!

hash
    "Sort in depth-first order"

    ^self dfnum! !

!STControlFlowGraphNode methodsFor: 'accessing'!

allSuccessors
    "Answer the set of all direct and indirect successors of
     the receiver"
    ^self addAllSuccessorsTo: Set new!

withAllSuccessors
    "Answer the set of all the nodes in the receiver's CFG, that
     is the node and all of its direct and indirect successors."
    ^(self addAllSuccessorsTo: Set new) add: self; yourself!

dfnum
    "Answer the progressive number of the receiver in a depth-first
     visit of the graph."
    ^dfnum!

dfnum: n
    "Set the progressive number of the receiver in a depth-first
     visit of the graph."
    dfnum := n!

id
    "Answer a numeric identifier for the receiver.  Consecutive indexes
     represent basic blocks that are adjacent in memory."

    ^id!

id: n
    "Set the numeric identifier for the receiver.  Consecutive indexes
     represent basic blocks that are adjacent in memory."

    id := n!

pred
    "Answer the set of predecessors of the receiver."
    ^pred!

succ
    "Answer the set of successors of the receiver."
    ^succ!

succ: newSucc
    "Set the set of successors of the receiver to be newSucc.
     newSucc should hold associations that represent the kind
     of jump (#jump, #jumpTrue, #jumpFalse) in the key, and
     the destination basic block in the value."

    succ isNil ifFalse: [
	succ do: [ :each |
	    each value removePredecessor: self
	].
	succ := nil.
    ].
    succ := newSucc.
    succ isNil ifTrue: [ ^self ].
    succ do: [ :assoc |
	assoc value addPredecessor: self ]!

statements
    "Answer the set of statements executed by the receiver"

    ^statements!

statements: aCollection
    "Set the set of statements executed by the receiver"

    statements := aCollection!

stack
    "Answer the state of the stack after the receiver completes
     its execution"

    stack isNil ifTrue: [ stack := OrderedCollection new ].
    ^stack!

stack: aCollection
    "Set the state of the stack after the receiver completes
     its execution"

    stack := aCollection!

fallThroughIfFalse
    "Answer whether the receiver ends with a `jump if true'
     bytecode"
    ^fallThrough = #jumpFalse!

fallThroughIfTrue
    "Answer whether the receiver ends with a `jump if false'
     bytecode"
    ^fallThrough = #jumpTrue!

addSuccessor: kindBlockAssociation
    "Add the successor represented by kindBlockAssociation,
     which should be an association that represents the kind
     of jump (#jump, #jumpTrue, #jumpFalse) in the key, and
     the destination basic block in the value."

    kindBlockAssociation value id = (self id + 1)
	ifTrue: [ fallThrough := kindBlockAssociation key ].

    succ := succ isNil
	ifTrue: [ {kindBlockAssociation} ]
	ifFalse: [ succ copyWith: kindBlockAssociation ].

    kindBlockAssociation value
	addPredecessor: self!

!STControlFlowGraphNode methodsFor: 'simplification'!

blkNode: statements arguments: args
    "Private - Answer an RBBlockNode with the given statements
     and arguments."

    ^RBBlockNode new
	body: (self seqNode: statements);
	arguments: args!

blkNode: statements
    "Private - Answer an RBBlockNode with the given statements."

    ^RBBlockNode new
	body: (self seqNode: statements);
	arguments: #()!

msgNode: arguments receiver: receiver selector: aSymbol
    "Private - Answer an RBMessageNode with the given arguments,
     receiver and selector."

    | selParts |
    selParts := aSymbol keywords
	collect: [ :each | RBValueToken new value: each ].
    
    ^RBMessageNode new
	arguments: arguments;
	receiver: receiver;
	selectorParts: selParts!

seqNode: statements
    "Private - Answer an RBSequenceNode with the given statements."

    ^RBSequenceNode new
	temporaries: #();
	statements: statements;
	periods: #()!

disconnect
    "Disconnect the receiver from the graph (removing
     all arcs that point to it or depart from it)."

    pred isNil ifFalse: [
	pred do: [ :each |
	    each removeSuccessor: self
	].
	pred := nil
    ].
    self succ: nil
!

disconnectSuccessorsAndMerge: newSucc
    "Disconnect the receiver's successors from the graph (removing
     all arcs that point to them or depart from them),
     then try to merge the receiver with its predecessor
     (if there is only one after the disconnection) and
     possibly with the new successors, newSucc (if there
     is only one and it has no other predecessors than the
     receiver)."

    succ do: [ :each | each value disconnect ].
    self merge: newSucc
!

merge: newSucc
     "Try to merge the receiver with its predecessor
     (if there is only one after the disconnection) and
     possibly with the new successors, newSucc (if there
     is only one and it has no other predecessors than the
     receiver)."

    | newSelf |

    self succ: newSucc.
    newSelf := pred size = 1
	ifFalse: [ newSelf := self ]
	ifTrue: [
	    (newSelf := pred at: 1) statements
	        addAllLast: self statements.
	    self disconnect.
	    newSelf succ: newSucc.
	].

    newSucc size = 1 ifFalse: [ ^self ].
    (newSucc at: 1) value pred size = 1
	ifTrue: [ newSelf merge: (newSucc at: 1) value succ ]!

simplify
    "Recognize simple control structures in the receiver and
     reduce them to a single basic block that sends the appropriate
     Smalltalk messages."

    self
	simplifyRepeat;
	simplifyIf;
	simplifyLoop!

simplifyIf: cond then: arm2 else: arm1 ifTrueIfFalse: ifTrueIfFalse
    "Simplify a two-way conditional.  cond used to be the
     last statement of the receiver, arm1 and arm2 are the
     receiver's successor basic blocks."

    | block1 block2 |
    "'resolving if/then/else' displayNl."

    block2 := self blkNode: arm2 statements.
    block1 := self blkNode: arm1 statements.

    self statements addLast: (self
	msgNode: { block1. block2 }
	receiver: cond
	selector: (ifTrueIfFalse
	    ifTrue: [ #ifTrue:ifFalse: ]
	    ifFalse: [ #ifFalse:ifTrue: ]))
!

simplifyIf: cond then: arm ifTrue: ifTrue
    "Simplify a one-way conditional.  cond used to be the
     last statement of the receiver, arm is one of the
     receiver's successor basic blocks."

    | seq block |
    "'resolving if/then' displayNl."

    block := self blkNode: arm statements.

    self statements addLast: (self
	msgNode: { block }
	receiver: cond
	selector: (ifTrue
	    ifTrue: [ #ifTrue: ]
	    ifFalse: [ #ifFalse: ]))
!

simplifyIf
    "Recognize conditional control structures where the
     receiver is the header, and simplify them."

    | cond arm1 arm2 |
    succ size < 2 ifTrue: [ ^false ].

    arm1 := (self succ at: 1) value.
    arm2 := (self succ at: 2) value.

    ((arm1 succ at: 1) value = (arm2 succ at: 1) value
	and: [ (arm1 succ at: 1) value ~= self
	and: [ (arm2 succ at: 1) value ~= self ]])
	    ifTrue: [ self simplifyIf: self statements removeLast
				then: arm1
				else: arm2
				ifTrueIfFalse: self fallThroughIfFalse;
			    disconnectSuccessorsAndMerge: arm1 succ. ^true ].

    ((arm2 succ at: 1) value = arm1
	and: [ (arm2 succ at: 1) value ~= self ])
	    ifTrue: [ self simplifyIf: self statements removeLast
				then: arm2
				ifTrue: self fallThroughIfTrue;
			    disconnectSuccessorsAndMerge: arm1 succ. ^true ].

    ^false
!

simplifyWhile: body whileTrue: whileTrue
    "Simplify a #whileTrue: or #whileFalse: control structure
     where the receiver will be the receiver block, and body
     the argument block."

    | cond block |
    "'resolving while' displayNl."

    cond := self blkNode: self statements.
    block := self blkNode: body statements.

    self statements: (OrderedCollection
	with: (self
	    msgNode: { block }
	    receiver: cond 
	    selector: (whileTrue
	        ifTrue: [ #whileTrue: ]
	        ifFalse: [ #whileFalse: ])))
!

simplifyToByDo: body
    "Simplify a #to:do: or #to:by:do: control structure."

    | variable from to by block |

    "'resolving to/by/do' displayNl."

    self statements removeLast.
    to := self statements removeLast.
    from := self statements last value.
    variable := self statements removeLast variable.
    by := body statements removeLast value arguments at: 1.

    body statements removeLast; removeLast; removeLast.
    (self pred at: 2) statements removeLast; removeLast; removeLast; removeLast.
    block := self blkNode: body statements arguments: { variable }.

    self statements addLast: (self
	msgNode: (by=1
	    ifTrue: [ { to. block } ]
	    ifFalse: [ { to. by. block } ])
	receiver: from
	selector: (by=1
	    ifFalse: [ #to:by:do: ]
	    ifTrue: [ #to:do: ]))
!

simplifyLoop
    "Recognize looping control structures where the
     receiver is the dominator, and simplify them."

    | middle bottom |
    succ size < 2 ifTrue: [ ^false ].
    pred isNil ifTrue: [ ^false ].

    bottom := succ detect: [ :each |
	pred includes: each value ] ifNone: [ ^false ].

    middle := succ detect: [ :each | each ~= bottom ].

    middle value statements size = 0
	ifFalse: [ self simplifyToByDo: bottom value ]
	ifTrue: [ self simplifyWhile: bottom value
			whileTrue: self fallThroughIfFalse ].

    self disconnectSuccessorsAndMerge: middle value succ.
    ^true
!

simplifyRepeat
    "Recognize and simplify infinite loops (#repeat)."

    | block |
    self succ isNil ifTrue: [ ^false ].
    (self succ at: 1) value = self ifFalse: [ ^false ].

    "'resolving repeat' displayNl."

    block := self blkNode: self statements.

    self statements: {self
	msgNode: #()
	receiver: block
	selector: #repeat}.

    self merge: nil.
    ^true
! !

!STDecompiler class methodsFor: 'instance creation'!

decompile: aSelector in: aClass
    "Answer the source code for the selector aSelector of the
     given class"

    | node |
    node := self parseTreeForMethod: aClass >> aSelector in: aClass.

    ^RBFormatter new format: node!

parseTreeForMethod: aMethod in: aClass
    "Answer the parse tree for the method aMethod of the
     given class"

    ^self new decompileMethod:
	(STDecompilationContext on: aMethod class: aClass outer: nil)!

parseTreeForBlock: aBlock from: aDecompilerObject
    "Answer the parse tree for the block aBlock, considering
     the information already dug by aDecompilerObject"

    ^self new
	decompileBlock: (STDecompilationContext
			on: aBlock
			class: aDecompilerObject context mclass
			outer: aDecompilerObject context)! !

!STDecompiler methodsFor: 'auxiliary'!

context
    ^context!

source
    "Answer a dummy source code object to be used to insert
     primitive names in the decompiled code."

    ^context method primitive > 0
	ifTrue: [ '<primitive: %1>' bindWith:
	    (VMPrimitives keyAtValue: context method primitive) asString ]
	ifFalse: [ '' ]!

tags: source
    ^source isEmpty
	ifTrue: [ #() ]
	ifFalse: [ { 1 to: source size } ]!

argumentNames
    ^(0 to: context methodNumArgs - 1)
	collect: [ :each | context temporaryAt: each ]!

arguments
    ^self argumentNames collect: [ :each | self varNode: each ]!

selectorParts: aSymbol
    ^aSymbol keywords
	collect: [ :each | RBValueToken value: each start: current ]!

temporaries
    ^self temporaryNames collect: [ :each | self varNode: each ]!

temporaryNames
    ^context temporaryNames asOrderedCollection
	removeAll: self argumentNames;
	yourself!

litNode: anObject
    | tok |
    anObject class == BlockClosure
	ifTrue: [ ^self class parseTreeForBlock: anObject block from: self ].

    tok := anObject class == Association
	ifFalse: [ RBLiteralToken value: anObject start: current ]
	ifTrue: [ RBBindingToken value: anObject path start: current ].

    ^RBLiteralNode new literalToken: tok!

varNode: name
    ^RBVariableNode new identifierToken:
        (STDecompiledValueToken value: name start: current)!

assignment: name
    ^RBAssignmentNode new
	value: stack removeLast;
	variable: (self varNode: name)! !

!STDecompiler methodsFor: 'decompilation'!

decompileBlock: stDecompilationContext

    isBlock := true.
    ^RBBlockNode new
	body: (self decompileBody: stDecompilationContext);
	arguments: self arguments;
	yourself!

decompileMethod: stDecompilationContext
    | parseNode |

    isBlock := false.
    ^(parseNode := RBMethodNode new)
	body: (self decompileBody: stDecompilationContext);
	selectorParts: (self selectorParts: context method selector);
	source: self source;
	tags: (self tags: parseNode source);
	arguments: self arguments;
	yourself!

decompileBody: stDecompilationContext
    | seq |
    context := stDecompilationContext.
    stack := OrderedCollection new.
    bbList := SortedCollection new.
    context method dispatchTo: self with: nil.

    self bytecodeIndex: context method size + 1 with: nil.
    self simplify.

    seq := RBSequenceNode new
	temporaries: self temporaries;
	statements: (context cfg at: 1) statements;
	periods: #().

    ^seq

!

doCascade: send
    (stack notEmpty and: [ stack last isCascade ])
	ifFalse: [
	    stack addLast: (RBCascadeNode new
		messages: (OrderedCollection with: send)).
	]
	ifTrue: [
	    send parent: stack last.
	    stack last messages addLast: send.
	].
!

endStatement
    statements addLast: stack removeLast
! !

!STDecompiler methodsFor: 'analyzing'!

invalidOpcode: unused
    self error: 'invalid opcode'!

makeDirtyBlock: unused
!

pushInstVar: anIndex with: unused
    stack addLast: (self varNode: (context instVarNameAt: anIndex))!

storeInstVar: anIndex with: unused
    stack addLast: (self assignment: (context instVarNameAt: anIndex))!

pushTemporary: anIndex outer: scopes with: unused
    stack addLast: (self varNode: (context outerTemporaryAt: anIndex scopes: scopes))!

storeTemporary: anIndex outer: scopes with: unused
    stack addLast: (self assignment: (context outerTemporaryAt: anIndex scopes: scopes))!

pushTemporary: anIndex with: unused
    stack addLast: (self varNode: (context temporaryAt: anIndex))!

storeTemporary: anIndex with: unused
    stack addLast: (self assignment: (context temporaryAt: anIndex))!

popIntoArray: anIndex with: unused
    | value |
    value := stack removeLast.
    anIndex = 0 ifTrue: [
	stack removeLast.
	stack addLast: (RBArrayConstructorNode new
	    body: (RBSequenceNode new
		temporaries: #();
		statements: OrderedCollection new;
		periods: #()))
    ].

    stack last body addNode: value!

pushLiteral: anObject with: unused
    stack addLast: (self litNode: anObject)!

pushGlobal: anObject with: unused
    stack addLast: (self varNode: anObject path)!

storeGlobal: anObject with: unused
    stack addLast: (self assignment: anObject path)!

pushSelf: unused
    stack addLast: (self varNode: 'self')!

isCascadeLast
    ^stack size >= 2 and: [
	(stack at: stack size - 1) isCascade ]!

isCascade
    (stack size >= 3 and: [
	(stack at: stack size - 2) isCascade ]) ifTrue: [ ^true ].

    ^stack size >= 2 and: [
	stack last isMessage and: [
	(stack at: stack size - 1) == stack last receiver ]]!

popStackTop: unused
    | send receiver |
    self isCascade ifFalse: [ ^self endStatement ].

    "There are two possible cases:

	 the receiver		-->	an RBCascadeNode
	 the new message send		the receiver

	 the RBCascadeNode		augmented RBCascadeNode
	 the receiver		-->	the receiver
	 the new message send"

    send := stack removeLast.
    receiver := stack removeLast.
    self doCascade: send.
    stack addLast: receiver!

dupStackTop: unused
    stack addLast: (stack at: stack size)!

exitInterpreter: unused
!

returnFromContext: unused
    isBlock
	ifTrue: [ self endStatement ]
	ifFalse: [ self returnFromMethod: unused ]!

returnFromMethod: unused
    stack addLast: (RBReturnNode value: stack removeLast).
    self endStatement!

popJumpIfFalseTo: destination with: unused
!

popJumpIfTrueTo: destination with: unused
!

jumpTo: destination with: unused
!

superSend: aSymbol numArgs: anInteger with: unused
    stack at: stack size - anInteger put: (self varNode: 'super').
    ^self send: aSymbol numArgs: anInteger with: unused!

send: aSymbol numArgs: anInteger with: unused
    | args collection msg |
    "Not a very efficient check, but a rare one indeed (who
     sends #thisContext?)"
    (aSymbol == #thisContext
        and: [ stack last = self varNode: ContextPart binding path ])
        ifTrue: [
	    stack removeLast; addLast: (self varNode: 'thisContext').
	    ^self
        ].

    args := Array new: anInteger.
    anInteger to: 1 by: -1 do: [ :each |
	args at: each put: stack removeLast
    ].

    stack addLast: (RBMessageNode new
	arguments: args;
	receiver: stack removeLast;
	selectorParts: (self selectorParts: aSymbol)).

    "If the receiver was over an RBCascadeNode, merge the send
     with the cascade."
    self isCascadeLast
	ifTrue: [ self doCascade: stack removeLast ]!

bytecodeIndex: byte with: unused
    | newBB |
    current := byte.
    newBB := context cfgNodeAt: byte.
    newBB == bb ifFalse: [
	self newBasicBlock: newBB.
	statements := OrderedCollection new.
	bb := newBB
    ]!

newBasicBlock: newBB
    bb isNil ifTrue: [ ^self ].
    bb dfnum isNil ifTrue: [ ^self ].

    statements addAllLast: stack.
    bb statements: statements.

    bbList add: bb.

    bb succ do: [ :each |
	each value stack: stack copy.
	each key = #jump ifFalse: [
	    each value stack removeLast
	]
    ].

    stack := newBB stack!

simplify
    | oldSize goOn |
    bbList := bbList asArray.

    [
	bbList := bbList select: [ :each |
	    each succ size >= 2 or: [
		each succ notNil and: [
		    (each succ at: 1) value id <= each id ] ]
	].

	bbList isEmpty
    ] whileFalse: [
	bbList do: [ :each | each simplify ].
    ]!

!STDecompiler class methodsFor: 'test'!

testRepeat
    "A meaningless method to test #repeat simplification"
    | c |
    c := 'c'.
    [ c * 2.
      true ifTrue: [ c * c ].
      2 * c ] repeat!

testIfTrue
    "A meaningless method to test #ifTrue: simplification"
    | a b c |
    a := 'a'.
    b := 'b'.
    c := 'c'.
    a = b ifTrue: [ c * c ]!

testWhile
    "A meaningless method to test #whileTrue: simplification"
    | a b c |
    a := 'a'.
    b := 'b'.
    c := 'c'.
    [ b = 1. 1 = b ] whileFalse: [ c * 1. 1 * c ].
    [ b = 2. 2 = b ] whileTrue: [ c * 2. 2 * c ]!

testToByDo
    "A meaningless method to test #to:by:do: simplification"
    | a b c |
    a := 'a'.
    b := 'b'.
    c := 'c'.
    a to: b by: 3 do: [ :i | a = b. c = i ]!

test
    "Do some tests"

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

    (self decompile: #detect: in: Collection) displayNl.
    '' displayNl.

    (self decompile: #key:value:environment: in: VariableBinding class) displayNl.
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

    (self decompile: #timesRepeat: in: Integer) displayNl! !


