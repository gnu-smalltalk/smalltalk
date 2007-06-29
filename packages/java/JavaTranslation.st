"======================================================================
|
|   Java to Smalltalk bytecode translator
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2006 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

LookupTable variableSubclass: #LiteralTable
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

LiteralTable comment: '
This class is like a LookupTable, but objects that are of different classes
are never merged together even if they are equal.'!

Object subclass: #JavaMethodTranslator
    instanceVariableNames: 'javaMethod localMap basicBlocks literals numTemps
	currentEntryBasicBlock pcToBasicBlockMap compiledMethod exceptionTemp'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaMethodTranslator comment: '
JavaMethodTranslator keeps together the pieces (basic blocks) of a
method that is being compiled.

Instance Variables:
    basicBlocks	<(Collection of: JavaBasicBlock)>
	collection of basic blocks that make up this method.
    currentEntryBasicBlock <JavaEntryBasicBlock>
	the entry point from which we started translating the current batch of basic block
    javaMethod	<JavaClassElement>
	the JavaMethod which is being translated
    compiledMethod	<JavaCompiledMethod>
	the translated method
    literals	<Dictionary>
	literals that are part of the current method
    localMap	<(SequenceableCollection of: Integer)>
	the map from Java local variable slots to Smalltalk temporary variable slots (except for self)
    numTemps	<Integer>
	number of temporaries currently allocated
    pcToBasicBlockMap	<Object>
	an array which associates each program counter value with a basic block that starts there
'!


JavaInstructionInterpreter subclass: #JavaUntypedInterpreter
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaUntypedInterpreter comment: '
JavaUntypedInterpreter is similar to JavaInstructionInterpreter, but
the typed Java instructions are converted to similar yet untyped
instructions.  The size of the argument (2 for doubles and longs, 1
for the rest) is passed, but it can be discarded by subclasses that
are not interested at all in the types (those that manipulate the
stack, are).  '!


JavaUntypedInterpreter subclass: #JavaEdgeCreator
    instanceVariableNames: 'basicBlocks pcToBasicBlockMap currentBasicBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaEdgeCreator comment: '
JavaEdgeCreator reads again the last instruction in each basic block
in order to create the control-flow graph edges between the blocks.

Instance Variables:
    basicBlocks	<(Collection of: JavaBasicBlock)>
	an ordered collection of basic blocks
    currentBasicBlock	<JavaBasicBlock>
	the current basic block
    pcToBasicBlockMap	<Object>
	an array which associates each program counter value with a basic block that starts there

'!


JavaUntypedInterpreter subclass: #JavaBytecodeTranslator
    instanceVariableNames: 'stack spills destination javaMethod minimumStackDepth '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaBytecodeTranslator comment: '
JavaBytecodeTranslator does the translation from Java to Smalltalk
bytecodes.  It symbolically executes bytecodes, creating a stack of
JavaProgramNodes.  The actual emission of the code for the node is
delayed until: a pop or pop2 bytecode ends the current statement; a
dup* bytecode forces the code to be executed so that the result can be
saved in a temporary and repushed; the current basic block ends, in
which case the translator ensures that the (Smalltalk) stack items are
spilled to temporaries and the stack is emptied.  (Non-empty stacks
are the result of the ?: ternary operator).

A single instance of this class is reused for all the basic block in a
method/exception handler/subroutine, so that the same Smalltalk
temporary will be used every time a particular stack slot is spilled,
and also every time the spill has to be restored back on the stack.

Instance Variables:
    destination	<JavaBasicBlock>
	the basic block which is being translated.
    javaMethod	<JavaMethod>
	the method which is being translated.
    minimumStackDepth	<Integer>
	the index of the lowest slot in the stack that is written to
	by the basic block
    spills	<(Array of: JavaSpillNode)>
	an Array holding the nodes used to spill the various stack
	slots.  As noted above, the same node is reused every time a
	particular stack slot is spilled or pushed back on the stack.
    stack	<(OrderedCollection of: JavaProgramNode)>
	the stack for symbolic execution.

'!


Array variableSubclass: #JavaTranslatedExceptionHandlerTable
    instanceVariableNames: 'exceptionTemp'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaTranslatedExceptionHandlerTable comment: '
JavaTranslatedExceptionHandlerTable is the table of exception handlers
in a translated Java method.  It is a different class from Array so
that we can plug it in the #exceptionHandlerSearch:reset: pragma and
define a #value:value:value: method to search in the table.'!

Object subclass: #JavaBasicBlock
    instanceVariableNames: 'startpc length translatedpc translationSize bytecodes methodTranslator outEdge knownPcValues '
    classVariableNames: 'SpecialSelectorMap'
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaBasicBlock comment: '
JavaBasicBlock represents an interval of bytecodes in a Java method
that can only have a single entry and a single exit.

Instance Variables:
    bytecodes	<Stream>
	the Smalltalk bytecodes corresponding to the basic block
    methodTranslator	<JavaMethodTranslator>
	the object that coordinates the translation of the various basic block
    length	<Integer>
	the number of Java bytecodes in this basic block
    outEdge	<JavaEdge>
	an object describing what happens at the end of the basic block
    startpc	<Integer>
	the first Java bytecode in the basic block
    translatedpc	<Integer>
	the first Smalltalk bytecode in the basic block
    translationSize	<Object>
	the number of Smalltalk bytecodes in the basic block, not counting the translation of outEdge
    knownPcValues	<(Array of: Integer)>
	same as above, but also includes the places where a line number starts.
'!


JavaUntypedInterpreter subclass: #JavaBytecodeAnalyzer
    instanceVariableNames: 'javaMethod basicBlocks usedLocals pcToBasicBlockMap nextStartsBasicBlock currentBasicBlock knownBasicBlockStarts knownPcValues '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaBytecodeAnalyzer comment: '
JavaBytecodeAnalyzer splits the Java source code into basic blocks,
then uses a JavaEdgeCreator to connect them.  It also finds out which
local variable slots are never referenced directly (because they are
the second part of a double or a long), and uses this information to
compute a map from Java local variable slots to Smalltalk temporary
variable slots.

Instance Variables:
    basicBlocks	<OrderedCollection>
	an ordered collection of basic blocks
    currentBasicBlock	<JavaBasicBlock>
	the current basic block
    javaMethod	<JavaMethod>
	the JavaMethod which we are analyzing
    knownBasicBlockStarts	<(SortedCollection of: Integer)>
	the pc values at which we know that a basic block starts
    knownPcValues	<(SortedCollection of: Integer)>
	same as above, but also includes the places where a line number starts.
    nextStartsBasicBlock	<Boolean>
	set when a bytecode is found that ends a basic block, to limit operation on knownBasicBlockStarts
    pcToBasicBlockMap	<(Array of: JavaBasicBlock)>
	an array which associates each program counter value with a basic block that starts there
    usedLocals	<ByteArray>
	holds a 1 if a local variable slot is used, 0 if it is not used.

'!


Object subclass: #JavaProgramNode
    instanceVariableNames: 'wordSize '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaProgramNode comment: '
JavaProgramNode is the abstract superclass for nodes of the bytecode
translator''s IR.  The IR is necessary because invokestatic bytecodes
don''t push the receiver (if it were not for them, it would be
possible to do a simple one-bytecode-at-a-time translation!).

Instance Variables:
    wordSize	<Integer>
	1 or 2, depending on how many stack slots the item takes in Java''s stack.

'!


JavaProgramNode subclass: #JavaConstantNode
    instanceVariableNames: 'object '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaConstantNode comment: '
JavaConstantNode is the IR node for pushing a constant object.

Instance Variables:
    object	<Object>
	the literal object being pushed

'!


JavaProgramNode subclass: #JavaLocalNode
    instanceVariableNames: 'id '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaLocalNode comment: '
JavaLocalNode is the IR node for pushing a Java local variable.

Instance Variables:
    id	<Integer>
	Java local variable slot'!


JavaLocalNode subclass: #JavaSpillNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSpillNode comment: '
JavaSpillNode is the IR node for pushing back a Java stack slot that
has been spilled to a Smalltalk temporary variable.  It is a separate
class, a) to easily avoid pushing them and spill them back, and b) in
order to distinguish invokenonvirtual bytecodes which are sends to
super (to the JavaLocalNode for `this''), from those that are sends to
constructors (to the dup''ed result of an instance creation bytecode,
which is a JavaSpillNode).

Instance Variables:
    id	<Integer>
	Smalltalk temporary variable slot'!


JavaProgramNode variableSubclass: #JavaArrayNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaArrayNode comment: '
JavaArrayNode creates an array at run time, similar to the Smalltalk
construction { 1. 2. a. b }.  It is used when multidimensional arrays
are created, as the argument that is passed to the run-time routine
that creates the array.

Indexed instance variables hold JavaProgramNodes for the items of the array.'!


JavaProgramNode variableSubclass: #JavaMessageSendNode
    instanceVariableNames: 'selector '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaMessageSendNode comment: '
JavaMessageSendNode is the IR node for doing a Smalltalk message send.
As Smalltalk programs are almost exclusively made of message sends,
this also implements bytecodes such as monitorenter, or checkcast.
The only message sends that do not pass through a JavaMessageSendNode
are those created by JavaConditionalEdges (that is, by if* bytecodes)
and those created by JavaThrowExceptionEdges (by athrow bytecodes).

Instance Variables:
    selector	<Object>
	description of selector

Indexed instance variables hold JavaProgramNodes for the receiver and arguments of the message send.
'!


JavaMessageSendNode variableSubclass: #JavaSuperMessageSendNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSuperMessageSendNode comment: '
JavaSuperMessageSendNode is the IR node for doing a message send to
super.  '!


JavaBasicBlock subclass: #JavaEntryBasicBlock
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaEntryBasicBlock comment: '
JavaEntryBasicBlock is a special class for basic blocks that are
entry-points of the method, its exception handlers, or its
subroutines.  They are useful to associate jsr instructions with try
and catch blocks (respectively, JavaEntryBasicBlock and
JavaExceptionHandlerBasicBlock -- no need to create a subclass), and to
associate ret instruction with the subroutine they belong to
(represented by a JavaSubroutineEntryBasicBlock).

The reference to the current JavaEntryBasicBlock is maintained by the
JavaMethodTranslator that coordinates the compilation of edges.'!


JavaEntryBasicBlock subclass: #JavaExceptionHandlerBasicBlock
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaExceptionHandlerBasicBlock comment: '
JavaExceptionHandlerBasicBlock provides a single method that
automatically retrieves a one-word item from a special temporary
and puts it on the stack.'!


JavaExceptionHandlerBasicBlock subclass: #JavaFinallyHandlerBasicBlock
    instanceVariableNames: 'exceptionLocal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaFinallyHandlerBasicBlock comment: '
JavaFinallyHandlerBasicBlock represents the block that implements the
implicit exception handler added when a try block has a corresponding
finally.  It assumes that the exception is stored on the stack at the
start of the basic-block, and remembers the local that it was stored
into so that the emulation of jsr can push it back.

Instance Variables:
    exceptionLocal	<Integer>
	the local variable slot in which the exception is stored

'!


JavaEntryBasicBlock subclass: #JavaSubroutineEntryBasicBlock
    instanceVariableNames: 'returnPoint '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSubroutineEntryBasicBlock comment: '
JavaSubroutineEntryBasicBlock represents the entry point of a
subroutine.  When a JavaJumpToFinallyEdge that lives out of an
exception handler is translated, it also stores where to return from.

Note that our translation scheme is wrong if there are two or more
non-exception paths to a finally handlers, which can happen in
the presence of multilevel break or continue statements.

Instance Variables:
    returnPoint	<JavaBasicBlock>
	description of returnPoint
'!


Object subclass: #JavaEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaEdge comment: '
JavaEdge represents the edges out of a JavaBasicBlock in a method''s
control-flow graph.

Subclasses must implement the following messages:
    cfg iteration
	successorsDo:

'!


JavaEdge subclass: #JavaGotoEdge
    instanceVariableNames: 'successor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaGotoEdge comment: '
JavaGotoEdge represents a single edge going out of a JavaBasicBlock in
a method''s control-flow-graph.

Instance Variables:
    successor	<JavaBasicBlock>
	description of successor

'!


JavaGotoEdge subclass: #JavaFallThroughEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaFallThroughEdge comment: '
JavaFallThroughEdge represents a single edge going out of a
JavaBasicBlock in a method''s control-flow-graph.  This edge is added
when there are exception handlers and try-catch blocks, because every
statement in the try-catch block can have more than one successor and
so needs to be treated specially.  '!


JavaGotoEdge subclass: #JavaJumpToFinallyEdge
    instanceVariableNames: 'entryBlock returnPoint '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaJumpToFinallyEdge comment: '
JavaJumpToFinallyEdge represents an edge that jumps to a subroutine.
The subroutine executes the finally block of an exception handler.

Subroutines are emulated in the bytecodes: an exception or nil is
pushed, and a normal jump is executed.  Then, the ret bytecode is
translated by checking if an exception was pushed and if so,
rethrowing it.  Otherwise, we jump back to after the try block.

The successor instance variable of JumpToFinallyEdge points to the
subroutine (a JavaSubroutineEntryBasicBlock), while the returnPoint
instance variable points back to the main flow of execution.  During
the translation of JavaJumpToFinallyEdges that are not coming from an
exception handler, the returnPoint is propagated to the
JavaSubroutineEntryBasicBlock, and from there it will be fetched by
the JavaSubroutineReturnEdge.

Instance Variables:
    entryBlock	<JavaEntryBasicBlock>
	the entry point of the sequence of basic blocks which includes this edge
    returnPoint	<JavaBasicBlock | JavaExceptionHandler | JavaLocalVariable>
	description of returnPoint

'!


JavaEdge subclass: #JavaReturnEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaReturnEdge class instanceVariableNames: 'soleInstance '!

JavaReturnEdge comment: '
JavaReturnEdges are attached to JavaBasicBlocks when they return a
value to the caller.

JavaReturnEdge is a Singleton.'!


JavaReturnEdge subclass: #JavaThrowExceptionEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaThrowExceptionEdge comment: '
JavaThrowExceptionEdge are attached to JavaBasicBlocks when they end
by throwing an exception.

JavaThrowExceptionEdge is a Singleton.'!


JavaEdge subclass: #JavaSwitchStatementEdge
    instanceVariableNames: 'currentLabel jumpTargets basicBlocks defaultSuccessor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSwitchStatementEdge comment: '
JavaSwitchStatementReturnEdges are attached to JavaBasicBlocks that
end with a switch bytecode (tableswitch or lookupswitch).  It includes
code to translated them to a binary search.

Subclasses must implement the following messages:
    accessing
	values

Instance Variables:
    basicBlocks	<SequenceableCollection>
	collection of basic blocks to which the switch statement jumps. basicBlocks size = self values size
    defaultSuccessor	<JavaBasicBlock>
	basic block for the ''default:'' part of the switch statement
    currentLabel	<Integer>
	description of currentLabel
    jumpTargets	<(OrderedCollection of: Integer)>
	description of jumpTargets
'!


JavaSwitchStatementEdge subclass: #JavaTableSwitchStatementEdge
    instanceVariableNames: 'low high '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaTableSwitchStatementEdge comment: '
JavaLookupSwitchStatementReturnEdges are attached to JavaBasicBlocks
that end with a lookupswitch bytecode.

Instance Variables:
    low	<Integer>
	value of the lowest ''case'' label in the switch statement
'!


JavaSwitchStatementEdge subclass: #JavaLookupSwitchStatementEdge
    instanceVariableNames: 'values '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaLookupSwitchStatementEdge comment: '
JavaLookupSwitchStatementReturnEdges are attached to JavaBasicBlocks
that end with a lookupswitch bytecode.

Instance Variables:
    values	<Array>
	values for the ''case'' labels in the switch statement.

'!


JavaReturnEdge subclass: #JavaVoidReturnEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaVoidReturnEdge comment: '
JavaVoidReturnEdges are attached to JavaBasicBlocks in a
void-returning method that return to the caller.

Like JavaReturnEdge, JavaVoidReturnEdge is a Singleton.'!


JavaEdge subclass: #JavaConditionalEdge
    instanceVariableNames: 'condition negated successorTrue successorFalse '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaConditionalEdge comment: '
JavaConditionalEdge represents two edges going out of a JavaBasicBlock
in a method''s control-flow-graph.

Instance Variables:
    condition	<Symbol>
	the condition to be tested on the item(s) at the top of the stack
    negated	<Boolean>
	whether to jump on false
    successorFalse	<JavaBasicBlock>
	the successor when the condition is false
    successorTrue	<JavaBasicBlock>
	the successor when the condition is true

'!


JavaLocalNode subclass: #JavaLocalStoreNode
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaLocalStoreNode comment: '
JavaLocalStoreNode is the IR node for storing a value into a Java
local variable.  Unlike Java''s *store bytecodes, this operation does
not pop the stored value off the stack (because all JavaProgramNodes
have a value).

Instance Variables:
    value	<JavaProgramNode>
	description of value

'!


JavaGotoEdge subclass: #JavaSubroutineReturnEdge
    instanceVariableNames: 'exceptionLocal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSubroutineReturnEdge comment: '
JavaSubroutineReturnEdges are attached to JavaBasicBlocks that are
part of a method''s subroutine and that return to the caller.  These
are converted to gotos, so they are a subclass of JavaGotoEdge.  '!

Object subclass: #TargetInstructionPrinter
    instanceVariableNames: 'literals bytecodes base stream '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

!LiteralTable methodsFor: 'literals'!

keysClass
    "Answer the class answered by #keys"
    ^IdentitySet
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject hash bitXor: anObject class identityHash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := ((self hashFor: anObject) scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element class == anObject class and: [ element = anObject ]])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !

!JavaMethodTranslator methodsFor: 'literals'!

addLiteral: anObject
    ^self literals at: anObject ifAbsentPut: [ self literals size ]
!

literalArray
    | a |
    a := Array new: self literals size.
    self literals keysAndValuesDo: [ :lit :index |
	a at: index + 1 put: lit ].
    ^a
!

printOn: aStream
    self javaMethod printHeadingOn: aStream.
    aStream nl.
    basicBlocks do: [ :each | each printOn: aStream ]
! !

!JavaMethodTranslator methodsFor: 'initializing'!

initialize
    literals := LiteralTable new
! !

!JavaMethodTranslator methodsFor: 'temporaries'!

allocTemporary
    ^(numTemps := numTemps + 1) - 1
!

exceptionTemp
    ^exceptionTemp
!

temporaryAt: local
    ^localMap at: local
! !

!JavaMethodTranslator methodsFor: 'accessing'!

basicBlocks
    ^basicBlocks
!

basicBlocks: bb
    basicBlocks := bb.
    basicBlocks do: [ :each | each methodTranslator: self ]
!

compiledMethod
    ^compiledMethod
!

currentEntryBasicBlock
    ^currentEntryBasicBlock
!

currentEntryBasicBlock: anObject
    currentEntryBasicBlock := anObject
!

javaClass
    ^javaMethod javaClass
!

javaMethod
    ^javaMethod
!

javaMethod: anObject
    | anal |
    javaMethod := anObject.
    anal := JavaBytecodeAnalyzer onMethod: javaMethod.
    self basicBlocks: anal basicBlocks.
    pcToBasicBlockMap := anal pcToBasicBlockMap.
    localMap := anal localMap.
    numTemps := localMap isEmpty ifTrue: [ 0 ] ifFalse: [ localMap last + 1 ].
    javaMethod handlers isEmpty ifFalse: [ exceptionTemp := self allocTemporary ]
!

literals
    ^literals
!

numTemps
    ^numTemps
! !

!JavaMethodTranslator methodsFor: 'translation'!

translate
    | size pc |
    "First, translate the instructions in a block.  Skip isolated
     JavaBasicBlocks."
    basicBlocks do: [:each | each translate].

    pc := 0.
    basicBlocks do: [:each |
	each translatedpc: pc.
        each hasBeenTranslated ifTrue: [ pc := pc + each size ] ].

    size := self translateEdges.
    self buildCompiledMethod: size.
!

translateEdges
    "Translate the CFG edges (jumps) doing as many
     passes as needed for their lengths to converge, plus
     one more to fix the destination addresses (passesLeft is
     always set to 2 except at the start, because the very
     first pass has already been done above, in
     #removeDeadBasicBlock)."
    | passesLeft pc |
    passesLeft := 1.

    [pc := 0.
    passesLeft := passesLeft - 1.
    basicBlocks do: [:each | 
	each translatedpc = pc ifFalse: [passesLeft := 2].
	each translatedpc: pc.
        each hasBeenTranslated ifTrue: [
	    each translateEdge.
	    pc := pc + each size ] ].
    passesLeft = 0] whileFalse.
    ^pc
! !

!JavaMethodTranslator methodsFor: 'building the CompiledMethod'!

attributesForHandlers
    javaMethod handlers isNil ifTrue: [ ^#() ].

    "For now, put nil in the first parameter; it will be patched
     later, after peephole optimization is done by the VM."
    ^Array with: (Message selector: #exceptionHandlerSearch:reset:
	arguments: { nil. [ :context | ] })
!

programCounterMap
    "Use the line number bytecodes put in by JavaBytecodeTranslator
     to build a map from Java program counters to Smalltalk program
     counters.  This is used for exception handlers and finding out
     line numbers."
    | programCounterMap last |
    programCounterMap := Array new: pcToBasicBlockMap size.
    last := 0.
    compiledMethod allByteCodeIndicesDo: [ :pc :bytecode :operand |
        bytecode = 54 ifTrue: [
	    "Hmmm, I really hate all this adjusting of 0-based vs.
	     1-based values."
	    last + 1 to: (last := operand + 1) do: [ :each |
	         programCounterMap at: each put: pc - 1 ] ]
    ].

    ^programCounterMap
!
   
buildCompiledMethod: size
    | mappedHandlers bytecodes |
    bytecodes := ByteArray new: size.
    basicBlocks do: [ :each |
        each hasBeenTranslated
	    ifTrue: [
	        bytecodes
	            replaceFrom: each translatedpc + 1
	            to: each translatedpc + each size
	            with: each bytecodes
	            startingAt: 1 ] ].

    compiledMethod := JavaCompiledMethod
	literals: self literalArray
	numArgs: self javaMethod numArgs
	numTemps: self numTemps
        attributes: self attributesForHandlers
	bytecodes: bytecodes
	depth: self javaMethod maxStack + self numTemps + 1.

    "After the method has been compiled, patch the exception
     handler table."

    compiledMethod descriptor size > 0 ifTrue: [
        mappedHandlers := JavaTranslatedExceptionHandlerTable
	    translateFrom: javaMethod handlers
	    withProgramCounterMap: self programCounterMap.

        mappedHandlers exceptionTemp: self exceptionTemp.
	(compiledMethod descriptor at: 1) arguments
	    at: 1 put: mappedHandlers
    ].
! !

!JavaMethodTranslator methodsFor: 'testing'!

isStatic
    ^self javaMethod isStatic
! !

!JavaMethodTranslator class methodsFor: 'instance creation'!

new
    ^super new initialize
!

onMethod: aJavaMethod
    ^self new
	javaMethod: aJavaMethod; 
	yourself
! !

!JavaUntypedInterpreter methodsFor: 'bytecodes'!

aaload
    self arrayLoad: 1
!

aastore
    self arrayStore: 1
!

aconst: operand 
    self constant: operand size: 1
!

aload: operand
    self load: operand size: 1
!

areturn
    self valueReturn: 1
!

astore: operand 
    self store: operand size: 1
!

baload
    self arrayLoad: 1
!

bastore
    self arrayStore: 1
!

bipush: operand 
    self constant: operand size: 1
!

caload
    self arrayLoad: 1
!

castore
    self arrayStore: 1
!

d2f
    self unary: #asFloatE delta: 1
!

d2i
    self unary: #javaAsInt delta: 1
!

d2l
    self unary: #javaAsLong delta: 0
!

dadd
    self binary: #+ delta: 2
!

daload
    self arrayLoad: 2
!

dastore
    self arrayStore: 2
!

dcmpg
    self binaryCompare: #javaCmpG: delta: 3
!

dcmpl
    self binaryCompare: #javaCmpL: delta: 3
!

dconst: operand 
    self constant: operand size: 2
!

ddiv
    ^self binary: #/ delta: 2
!

dload: operand 
    self load: operand size: 2
!

dmul
    ^self binary: #* delta: 2
!

dneg
    ^self unary: #negated delta: 0
!

drem
    ^self binary: #rem: delta: 2
!

dreturn
    self valueReturn: 2
!

dstore: operand 
    self store: operand size: 2
!

dsub
    self binary: #- delta: 2
!

f2d
    ^self unary: #asFloatD delta: 1
!

f2i
    self unary: #javaAsInt delta: 0
!

f2l
    self unary: #javaAsLong delta: 1
!

fadd
    self binary: #+ delta: 1
!

faload
    self arrayLoad: 1
!

fastore
    self arrayStore: 1
!

fcmpg
    self binaryCompare: #javaCmpG: delta: 1
!

fcmpl
    self binaryCompare: #javaCmpL: delta: 1
!

fconst: operand 
    self constant: operand size: 1
!

fdiv
    ^self binary: #/ delta: 1
!

fload: operand
    self load: operand size: 1
!

fmul
    ^self binary: #* delta: 1
!

fneg
    ^self unary: #negated delta: 0
!

frem
    ^self binary: #rem: delta: 1
!

freturn
    self valueReturn: 1
!

fstore: operand 
    self store: operand size: 1
!

fsub
    self binary: #- delta: 1
!

i2d
    ^self unary: #asFloatD delta: 1
!

i2f
    ^self unary: #asFloatE delta: 0
!

i2l
!

iadd
    self
	binary: #+ delta: 1;
	unary: #javaAsInt delta: 0
!

iaload
    self arrayLoad: 1
!

iand
    self binary: #bitAnd: delta: 1
!

iastore
    self arrayStore: 1
!

iconst: operand 
    self constant: operand size: 1
!

idiv
    ^self binary: #quo: delta: 1
!

ifeq: operand
    self constant: 0 size: 1.
    self if: #= goto: operand
!

ifge: operand
    self constant: 0 size: 1.
    self if: #>= goto: operand
!

ifgt: operand
    self constant: 0 size: 1.
    self if: #> goto: operand
!

ifle: operand
    self constant: 0 size: 1.
    self if: #<= goto: operand
!

iflt: operand
    self constant: 0 size: 1.
    self if: #< goto: operand
!

ifne: operand
    self constant: 0 size: 1.
    self if: #~= goto: operand
!

ifnonnull: operand
    self constant: nil size: 1.
    self if: #~~ goto: operand
!

ifnull: operand
    self constant: nil size: 1.
    self if: #== goto: operand
!

if_acmpeq: operand
    self if: #== goto: operand
!

if_acmpne: operand
    self if: #~~ goto: operand
!

if_icmpeq: operand
    self if: #= goto: operand
!

if_icmpge: operand
    self if: #>= goto: operand
!

if_icmpgt: operand
    self if: #> goto: operand
!

if_icmple: operand
    self if: #<= goto: operand
!

if_icmplt: operand
    self if: #< goto: operand
!

if_icmpne: operand
    self if: #~= goto: operand
!

iinc: operand by: amount 
    self
	load: operand size: 1;
	constant: amount size: 1;
	iadd;
	store: operand size: 1
!

iload: operand
    self load: operand size: 1
!

imul
    ^self
	binary: #* delta: 1;
	unary: #javaAsInt delta: 0
!

ineg
    ^self unary: #negated delta: 0
!

instanceof: operand
    | checkAgainst |
    operand isLoaded ifFalse: [ operand load ].

    checkAgainst := operand isInterface
	ifTrue: [ operand ]
	ifFalse: [ operand asSmalltalkClass ].

    self constant: checkAgainst size: 1.
    ^self binary: #instanceOf: delta: 1
!

int2byte
    self unary: #javaAsByte delta: 0
!

int2char
    self
	constant: 65535 size: 1;
	binary: #bitAnd: delta: 1
!

int2short
    self unary: #javaAsShort delta: 0
!

invokeinterface: operand nargs: args reserved: reserved
    self invoke: operand virtual: true
!

invokenonvirtual: operand
    self invoke: operand virtual: false
!

invokevirtual: operand
    self invoke: operand virtual: true
!

ior
    self binary: #bitOr: delta: 1
!

irem
    ^self binary: #rem: delta: 1
!

ireturn
    self valueReturn: 1
!

ishl
    self
	binary: #bitShift: delta: 1;
	unary: #javaAsInt delta: 0
!

ishr
    self
	unary: #negated delta: 0;
	binary: #bitShift: delta: 1
!

istore: operand 
    self store: operand size: 1
!

isub
    self
	binary: #- delta: 1;
	unary: #javaAsInt delta: 0
!

iushr
    self binary: #javaIushr: delta: 1
!

ixor
    self binary: #bitXor: delta: 1
!

l2d
    ^self unary: #asFloatD delta: 0
!

l2f
    ^self unary: #asFloatE delta: 1
!

l2i
    self unary: #javaAsInt delta: 1
!

ladd
    self binary: #+ delta: 2;
	unary: #javaAsLong delta: 0
!

laload
    self arrayLoad: 2
!

land
    self binary: #bitAnd: delta: 2
!

lastore
    self arrayStore: 2
!

lcmp
    self binaryCompare: #javaCmp: delta: 3
!

lconst: operand 
    self constant: operand size: 2
!

ldc2: operand 
    self constant: operand size: 2
!

ldc: operand 
    self constant: operand size: 1
!

ldiv
    ^self binary: #quo: delta: 2
!

lload: operand 
    self load: operand size: 2
!

lmul
    ^self binary: #* delta: 2;
	unary: #javaAsLong delta: 0
!

lneg
    ^self unary: #negated delta: 0;
	unary: #javaAsLong delta: 0
!

lor
    self binary: #bitOr: delta: 2
!

lrem
    ^self binary: #rem: delta: 1
!

lreturn
    self valueReturn: 2
!

lshl
    self binary: #bitShift: delta: 2;
	unary: #javaAsLong delta: 0
!

lshr
    self
	unary: #negated delta: 0;
	binary: #bitShift: delta: 2
!

lstore: operand 
    self store: operand size: 2
!

lsub
    self binary: #- delta: 2;
	unary: #javaAsLong delta: 0
!

lushr
    self binary: #javaLushr: delta: 2
!

lxor
    self binary: #bitXor: delta: 2
!

saload
    self arrayLoad: 1
!

sastore
    self arrayStore: 1
!

sipush: operand 
    self constant: operand size: 1
! !

!JavaUntypedInterpreter methodsFor: 'untyped bytecodes'!

binaryCompare: selector delta: delta
    ^self binary: selector delta: delta!

arrayLoad: size!
arrayStore: size!
binary: selector delta: delta!
constant: constant size: n!
if: aSelector goto: dest!
invoke: signature virtual: virtual!
load: localSlot size: n!
store: localSlot size: n!
unary: selector delta: delta!
valueReturn: size! !

!JavaEdgeCreator methodsFor: 'untyped bytecodes'!

if: aSelector goto: dest 
    | successorTrue successorFalse |
    successorFalse := self basicBlockAt: self nextPC.
    successorTrue := self basicBlockAt: dest.
    currentBasicBlock outEdge: (JavaConditionalEdge 
	condition: aSelector
	successorTrue: successorTrue
	successorFalse: successorFalse)
!

valueReturn: size
    currentBasicBlock 
	outEdge: JavaReturnEdge soleInstance
! !

!JavaEdgeCreator methodsFor: 'bytecodes'!

athrow
    currentBasicBlock 
	outEdge: JavaThrowExceptionEdge soleInstance
!

goto: operand 
    currentBasicBlock 
	outEdge: (JavaGotoEdge successor: (self basicBlockAt: operand))
!

jsr: operand 
    | destBB fallThroughBB |
    destBB := self basicBlockAt: operand.
    fallThroughBB := self basicBlockAt: self nextPC.
    currentBasicBlock outEdge: (JavaJumpToFinallyEdge successor: destBB returnPoint: fallThroughBB)
!

lookupswitch: default destinations: dest 
    | defaultBB |
    defaultBB := self basicBlockAt: default.
    currentBasicBlock outEdge: (JavaLookupSwitchStatementEdge 
			basicBlocks: (self getLookupSwitchDestinations: dest)
			defaultSuccessor: defaultBB
			values: (self getLookupSwitchValues: dest))
!

ret: operand
    currentBasicBlock 
	outEdge: (JavaSubroutineReturnEdge exceptionLocal: operand)
!

return
    currentBasicBlock 
	outEdge: JavaVoidReturnEdge soleInstance
!

tableswitch: default low: low high: high destinations: addresses
    | defaultBB |
    defaultBB := self basicBlockAt: default.
    currentBasicBlock outEdge: (JavaTableSwitchStatementEdge 
			basicBlocks: (self getTableSwitchDestinations: addresses)
			defaultSuccessor: defaultBB
			low: low)
! !

!JavaEdgeCreator methodsFor: 'edge creation'!

addFallThroughEdge
    "We also need to add the last instruction to the basic block if there is a forced edge"
    currentBasicBlock
	outEdge: (JavaFallThroughEdge
		     successor: (self basicBlockAt: self nextPC))
!

interpret
    basicBlocks do: [:each | 
	self nextPC: each finalpc.
	currentBasicBlock := each.
	self dispatch.

	"Now add the final instruction to the basic block.  We need it
	 for example to generate the second argument of the comparison
	 in icmp* bytecodes."
        currentBasicBlock length: self nextPC - currentBasicBlock startpc.
	currentBasicBlock outEdge isNil
	    ifTrue: [self addFallThroughEdge]].
! !

!JavaEdgeCreator methodsFor: 'accessing'!

basicBlockAt: dest 
    ^pcToBasicBlockMap at: dest + 1
!

basicBlocks
    ^basicBlocks
!

basicBlocks: anObject
    basicBlocks := anObject
!

pcToBasicBlockMap
    ^pcToBasicBlockMap
!

pcToBasicBlockMap: anObject
    pcToBasicBlockMap := anObject
! !

!JavaEdgeCreator methodsFor: 'utilty-switch bytecodes'!

getLookupSwitchDestinations: dest
    ^dest collect: [ :each | self basicBlockAt: each value ]
!

getLookupSwitchValues: dest
    ^dest collect: [ :each | each key ]
!

getTableSwitchDestinations: dest
    ^dest collect: [ :each | self basicBlockAt: each ]
! !

!JavaEdgeCreator class methodsFor: 'interpretation'!

onSameMethodAs: aJavaBytecodeAnalyzer 
    ^(super onSameMethodAs: aJavaBytecodeAnalyzer)
	basicBlocks: aJavaBytecodeAnalyzer basicBlocks;
	pcToBasicBlockMap: aJavaBytecodeAnalyzer pcToBasicBlockMap;
	yourself
! !

!JavaBytecodeTranslator methodsFor: 'accessing'!

javaMethod
    ^javaMethod
!

javaMethod: anObject
    javaMethod := anObject.
    spills := Array new: javaMethod maxStack + 1.

    "Push a dummy node for the pointer to this."
    (javaMethod isStatic not and: [ stack isEmpty ]) ifTrue: [
	self stackPush: (JavaProgramNode new wordSize: 1; yourself).
	minimumStackDepth := 1]
!

stack
    ^stack
!

stack: anObject
    stack := anObject.
    minimumStackDepth := stack size.
!

methodTranslator
    ^destination methodTranslator
! !

!JavaBytecodeTranslator methodsFor: 'initialization'!

initialize
    super initialize.
    stack := OrderedCollection new.
    minimumStackDepth := 0.
! !

!JavaBytecodeTranslator methodsFor: 'untyped bytecodes'!

arrayLoad: n 
    self stackInvokeArray: #at: numArgs: 1 size: n
!

arrayStore: n
    self stackInvokeArray: #at:put: numArgs: 2 size: n; stackPop
!

binaryCompare: selector delta: delta
    "If we are before an iflt/le/ge/gt/eq/ne bytecode, we can
     fold the comparison and the following bytecode into the
     JavaEdge.  This requires some care because of the separate
     dcmpl/dcmpg bytecodes, and this is handled by
     #applyComparison:."
    (stream peek between: 153 and: 158)
	ifTrue: [
	    destination outEdge applyComparison: selector.
	    stream position: destination finalpc.
	    ^self ].

    self binary: selector delta: delta
!
    
binary: selector delta: delta
    | top wordSize |
    top := stack last.
    wordSize := (top wordSize = 1 or: [ delta odd ]) ifTrue: [ 1 ] ifFalse: [ 2 ].
    self stackInvoke: selector numArgs: 1 size: wordSize
!

constant: constant size: n 
    self stackPushConstant: constant size: n
!

invoke: signature virtual: virtual
    | numArgs selector toSuper |
    selector := signature selector.
    numArgs := signature numArgs.
    toSuper := virtual not
	and: [ javaMethod isStatic not
	and: [ signature javaClass ~= javaMethod javaClass
	and: [ (stack at: stack size - numArgs) isLocal
	and: [ (stack at: stack size - numArgs) id = 0 ]]]].

    toSuper 
	ifTrue: [self stackSuperInvoke: selector numArgs: numArgs size: signature returnType wordSize]
	ifFalse: [self stackInvoke: selector numArgs: numArgs size: signature returnType wordSize].

    "Pop the return value for void methods, Smalltalk does not have them."
    signature isVoid ifTrue: [self stackPop]
!

load: localSlot size: n 
    self stackPushLocal: localSlot size: n
!

store: localSlot size: n 
    self stackStoreLocal: localSlot
!

unary: selector delta: delta
    | top wordSize |
    top := stack last.
    wordSize := (top wordSize = 1 or: [ delta < 0 ]) ifTrue: [ 1 ] ifFalse: [ 2 ].
    self stackInvoke: selector numArgs: 0 size: wordSize
! !

!JavaBytecodeTranslator methodsFor: 'bytecodes'!

anewarray: operand
    self stackInvoke: #new: receiver: Array numArgs: 1 size: 1
!

arraylength
    self stackInvoke: #size numArgs: 0 size: 1
!

checkcast: operand
    | checkAgainst |
    operand isLoaded ifFalse: [ operand load ].

    checkAgainst := operand isInterface
	ifTrue: [ operand ]
	ifFalse: [ operand asSmalltalkClass ].

    self stackPushConstant: checkAgainst size: 1.
    self stackInvoke: #checkCast: numArgs: 1 size: 1
!

dup
    | spill |
    self stackSpillAll.
    spill := self stackPop.
    self stackPush: spill.
    self stackPush: spill
!

dup2
    | s1b s1a |
    self stackSpillAll.
    stack last wordSize = 2 
	ifTrue: 
		[s1a := self stackPop.
		self stackPush: s1a.
		self stackPush: s1a]
	ifFalse: 
		[s1b := self stackPop.
		s1a := self stackPop.
		self stackPush: s1a.
		self stackPush: s1b.
		self stackPush: s1a.
		self stackPush: s1b]
!

dup2_x1
    | s1a s2a s2b |
    self stackSpillAll.
    stack last wordSize = 2 
	ifTrue: 
		[s2a := self stackPop.
		s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s1a.
		self stackPush: s2a]
	ifFalse: 
		[s2b := self stackPop.
		s2a := self stackPop.
		s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s2b.
		self stackPush: s1a.
		self stackPush: s2a.
		self stackPush: s2b]
!

dup2_x2
    | s1a s1b s2a s2b |
    self stackSpillAll.
    stack last wordSize = 2 
	ifTrue: 
		[s2a := self stackPop]
	ifFalse: 
		[s2b := self stackPop.
		s2a := self stackPop].

    stack last wordSize = 2 
	ifTrue: 
		[s1a := self stackPop]
	ifFalse: 
		[s1b := self stackPop.
		s1a := self stackPop].

    self stackPush: s2a.
    s2b isNil ifFalse: [self stackPush: s2b].
    self stackPush: s1a.
    s1b isNil ifFalse: [self stackPush: s1b].
    self stackPush: s2a.
    s2b isNil ifFalse: [self stackPush: s2b].
!

dup_x1
    | s1a s2a |
    self stackSpillAll.
    s2a := self stackPop.
    s1a := self stackPop.
    self stackPush: s2a.
    self stackPush: s1a.
    self stackPush: s2a.
!

dup_x2
    | s1a s1b s2a |
    self stackSpillAll.
    s2a := self stackPop.
    s2a wordSize = 2 
	ifTrue: 
		[s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s1a.
		self stackPush: s2a]
	ifFalse: 
		[s1b := self stackPop.
		s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s1a.
		self stackPush: s1b.
		self stackPush: s2a]
!

getfield: operand
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self 
	stackInvoke: operand getSelector
	numArgs: 0
	size: operand wordSize
!

getstatic: operand
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self 
	stackInvoke: operand getSelector
	receiver: operand javaClass asSmalltalkClass
	numArgs: 0
	size: operand wordSize
!

invokestatic: signature 
    | numArgs selector |
    selector := signature selector.
    numArgs := signature numArgs.
    self 
	stackInvoke: selector
	receiver: signature javaClass asSmalltalkClass
	numArgs: numArgs
	size: signature returnType wordSize.

    "Pop the return value for void methods, Smalltalk does not have them."
    signature isVoid ifTrue: [self stackPop]
!

monitorenter
    self
	stackInvoke: #monitorEnter numArgs: 0 size: 1;
	stackPop
!

monitorexit
    self
	stackInvoke: #monitorExit numArgs: 0 size: 1;
	stackPop
!

multianewarray: operand dimensions: dimensions 
    | countsNode primitiveType |
    "Create an array with the dimensions"
    countsNode := JavaArrayNode new: dimensions.
    dimensions to: 1
	by: -1
	do: [:each | countsNode at: each put: stack removeLast].

    self constant: operand size: 1.
    self stackPush: countsNode.
    self constant: 1 size: 1.
    self stackInvoke: #javaMultiNewArray:from: numArgs: 2 size: 1
!

new: operand
    self 
	stackInvoke: #new
	receiver: operand asSmalltalkClass
	numArgs: 0
	size: 1
!

newarray: operand
    self
	stackInvoke: #javaNewArray:
	receiver: operand arrayClass
	numArgs: 1
	size: 1
!

pop
    self stackPop.
!

pop2
    stack last wordSize = 1 ifTrue: [ self stackPop ].
    self stackPop
!

putfield: operand 
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self
	stackInvoke: operand putSelector
		numArgs: 1
		size: operand wordSize;
	stackPop
!

putstatic: operand 
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self
	stackInvoke: operand putSelector
		receiver: operand javaClass asSmalltalkClass
		numArgs: 1
		size: operand wordSize;
	stackPop
!

swap
    | s2 s1 |
    self stackSpillAll.
    s2 := self stackPop.
    s1 := self stackPop.
    self stackPush: s2.
    self stackPush: s1.
! !

!JavaBytecodeTranslator methodsFor: 'translating'!

convertMathSelector: javaSelector
    | s |
    javaSelector == #'sin(D)D' ifTrue: [ ^#sin ].
    javaSelector == #'cos(D)D' ifTrue: [ ^#cos ].
    javaSelector == #'tan(D)D' ifTrue: [ ^#tan ].
    javaSelector == #'asin(D)D' ifTrue: [ ^#arcSin ].
    javaSelector == #'acos(D)D' ifTrue: [ ^#arcCos ].
    javaSelector == #'atan(D)D' ifTrue: [ ^#arcTan ].
    javaSelector == #'atan2(DD)D' ifTrue: [ ^#arcTan: ].
    javaSelector == #'exp(D)D' ifTrue: [ ^#exp ].
    javaSelector == #'log(D)D' ifTrue: [ ^#ln ].
    javaSelector == #'sqrt(D)D' ifTrue: [ ^#sqrt ].
    javaSelector == #'pow(DD)D' ifTrue: [ ^#raisedTo: ].
    javaSelector == #'ceil(D)D' ifTrue: [ ^#ceiling ].
    javaSelector == #'floor(D)D' ifTrue: [ ^#floor ].
    javaSelector == #'rint(D)D' ifTrue: [ ^#rounded ].
    s := javaSelector copyFrom: 1 to: 3.
    s = 'abs' ifTrue: [ ^#abs ].
    s = 'min' ifTrue: [ ^#min: ].
    s = 'max' ifTrue: [ ^#max: ].
    ^nil
!

finishTranslation
    | edgeStackBalance |
    edgeStackBalance := destination outEdge edgeStackBalance.

    "Spill the slots that are part of a message send done elsewhere,
     but not if all the slots are actually consumed by the edge."
    self stackSpillAllButLast: edgeStackBalance.

    "Push on the stack those slots that are needed to translate the edge"
    stack size + edgeStackBalance + 1 to: stack size
	do: [:slot | (stack at: slot) emitForValue: destination].
    edgeStackBalance to: -1 do: [:unused | stack removeLast]
!

translateBasicBlock: aBasicBlock
    | finalpc knownPcValues knownPcIndex pc |
    stream position: aBasicBlock startpc.
    finalpc := aBasicBlock finalpc .
    destination := aBasicBlock.
    knownPcValues := aBasicBlock knownPcValues.
    knownPcIndex := 1.
    [(pc := stream position) < finalpc] whileTrue: [
	(knownPcValues at: knownPcIndex) = pc
	    ifTrue: [
		aBasicBlock lineNumber: pc.
		knownPcIndex := knownPcIndex + 1
	    ].

	self dispatch].

    self finishTranslation
! !

!JavaBytecodeTranslator methodsFor: 'stack manipulation'!

stackInvokeArray: selector numArgs: args size: n
    | invoc index |
    invoc := JavaMessageSendNode new: args + 1.
    args + 1 to: 1
	by: -1
	do: [:each | invoc at: each put: stack removeLast].

    invoc
	wordSize: n;
	selector: selector;
	at: 2 put: (invoc at: 2) incremented.	"first element is the receiver"

    stack addLast: invoc
!

stackInvoke: selector numArgs: args size: n 
    | invoc |
    invoc := JavaMessageSendNode new: args + 1.
    args + 1 to: 1
	by: -1
	do: [:each | invoc at: each put: stack removeLast].
    invoc
	wordSize: n;
	selector: selector.
    stack addLast: invoc
!

stackInvoke: selector receiver: receiver numArgs: args size: n 
    | invoc |
    (receiver == Java.java.lang.Math and: [
	self stackInvokeMath: selector numArgs: args size: n ])
	    ifTrue: [ ^self ].

    invoc := JavaMessageSendNode new: args + 1.
    args + 1 to: 2
	by: -1
	do: [:each | invoc at: each put: stack removeLast].
    invoc
	at: 1 put: (JavaConstantNode object: receiver wordSize: 1);
	wordSize: n;
	selector: selector.
    stack addLast: invoc
!

stackInvokeMath: selector numArgs: args size: n 
    | stSelector |
    stSelector := self convertMathSelector: selector.
    stSelector notNil ifTrue: [
	self stackInvoke: stSelector numArgs: args - 1 size: n.
	^true ].
    ^false
!

stackPop
    "Overall, remove the number of items that is contained
     in the topmost stack item"
    | last |
    last := stack removeLast.
    last emitForEffect: destination.
    stack size < minimumStackDepth ifTrue: [ minimumStackDepth := stack size ].
    ^last
!

stackPush: node
    stack addLast: node
!

stackPushConstant: object size: n 
    stack addLast: (JavaConstantNode object: object wordSize: n)
!

stackPushLocal: num size: n 
    stack addLast: (JavaLocalNode id: num wordSize: n)
!

stackSpill: slot 
    | spill spilledNode |
    spill := spills at: slot.
    spill isNil 
	ifTrue: [spills at: slot put: (spill := self methodTranslator allocTemporary)].
    spilledNode := stack at: slot.

    "If there's already a spill, no need to re-emit it."
    (spilledNode isSpill and: [ spilledNode id = spill ])
	ifTrue: [ ^spilledNode ].

    "Else store it."
    spilledNode emitForValue: destination.
    destination
	storeTemporary: spill;
	popStackTop.
    ^JavaSpillNode id: spill wordSize: spilledNode wordSize
!

stackSpillAll
    minimumStackDepth + 1 to: stack size
	do: [:slot | stack at: slot put: (self stackSpill: slot)]
!

stackSpillAllButLast: edgeStackBalance 
    minimumStackDepth + 1 to: stack size + edgeStackBalance
	do: [:slot | stack at: slot put: (self stackSpill: slot)]
!

stackStoreLocal: num
    | value |
    value := stack removeLast.

    "Spill here, so that
	iload 2
	iinc 2 1
    loads before incrementing."

    self stackSpillAll.
    (JavaLocalStoreNode id: num value: value) emitForEffect: destination
!

stackSuperInvoke: selector numArgs: args size: n 
    | invoc |
    invoc := JavaSuperMessageSendNode new: args + 1.
    args + 1 to: 1 by: -1 do: [ :each | invoc at: each put: stack removeLast ].
    invoc
	wordSize: n;
	selector: selector.
    stack addLast: invoc
! !

!JavaBytecodeTranslator class methodsFor: 'interpretation'!

onMethod: aJavaMethod
    ^(super onMethod: aJavaMethod)
	javaMethod: aJavaMethod
	yourself
! !


!JavaExceptionHandler methodsFor: 'translation'!

mappedThrough: pcMap
    | newStartPC newFinalPC newHandlerPC |
    "We adjust by two the finalpc, because the VM advances the
     program counter *before* executing the instruction."
    newStartPC := (pcMap at: self startpc + 1).
    newFinalPC := (pcMap at: self finalpc + 1) + 2.
    newHandlerPC := (pcMap at: self handlerpc + 1).
    ^JavaExceptionHandler new
        startpc: newStartPC;
        finalpc: newFinalPC;
        handlerpc: newHandlerPC;
        type: (self type isNil ifTrue: [ nil ] ifFalse: [ self type asSmalltalkClass ]);
        yourself
! !


!JavaTranslatedExceptionHandlerTable class methodsFor: 'instance creation'!

translateFrom: excHandlerTable withProgramCounterMap: pcMap
    | result |
    result := self new: excHandlerTable size.
    1 to: result size do: [ :i |
	result
	    at: i
	    put: ((excHandlerTable at: i) mappedThrough: pcMap) ].

    ^result
! !

!JavaTranslatedExceptionHandlerTable methodsFor: 'accessing'!

exceptionTemp
    ^exceptionTemp
!

exceptionTemp: anInteger
    exceptionTemp := anInteger
! !

!JavaBasicBlock methodsFor: 'accessing'!

bytecodes
    ^bytecodes contents
!

finalpc
    ^self startpc + self length
!

initialAStore: local
    "Do nothing; subclasses are interested in astore's to associate each
     subroutines with the return address, and catch blocks with the
     local holding the exception."
!

javaClass
    ^self methodTranslator javaClass
!

javaMethod
    ^self methodTranslator javaMethod
!

knownPcValues
    ^knownPcValues
!

knownPcValues: anObject
    knownPcValues := anObject.
!

length
    ^length
!

length: anObject
    length := anObject
!

outEdge
    ^outEdge
!

outEdge: anObject
    outEdge := anObject
!

size
    ^bytecodes size
!

startpc
    ^startpc
!

startpc: anObject
    startpc := anObject
!

methodTranslator
    ^methodTranslator
!

methodTranslator: anObject
    methodTranslator := anObject
!

translatedpc
    ^translatedpc
!

translatedpc: anObject
    translatedpc := anObject
! !

!JavaBasicBlock methodsFor: 'printing'!

printBytecodesOn: aStream 
    bytecodes isNil ifTrue: [^nil].
    TargetInstructionPrinter 
	print: bytecodes contents
	literals: self methodTranslator literalArray
	base: self translatedpc
	on: aStream
!

printOn: aStream 
    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
!

printPcRangeOn: aStream 
    aStream
	nextPutAll: 'pc ';
	print: self startpc;
	nextPutAll: '..';
	print: self finalpc;
	space;
	print: self outEdge;
	nl
! !

!JavaBasicBlock methodsFor: 'target instruction set'!

compileByte: byte
    bytecodes nextPut: byte; nextPut: 0
!

compileByte: byte with: arg 
    "First emit the extension bytes"
    arg > 16rFF 
	ifTrue: 
		[arg > 16rFFFF 
			ifTrue: 
				[arg > 16rFFFFFF 
					ifTrue: 
						[bytecodes
							nextPut: 55;
							nextPut: (arg bitShift: -24)].
				bytecodes
					nextPut: 55;
					nextPut: ((arg bitShift: -16) bitAnd: 255)].
		bytecodes
			nextPut: 55;
			nextPut: ((arg bitShift: -8) bitAnd: 255)].

    "Then the real opcode."
    bytecodes
	nextPut: byte;
	nextPut: (arg bitAnd: 255)
!

compileByte: byte with: arg with: arg2 
    "First emit the extension bytes"
    arg > 16rFF 
	ifTrue: 
		[arg > 16rFFFF 
			ifTrue: 
				[bytecodes
					nextPut: 55;
					nextPut: (arg bitShift: -16)].
		bytecodes
			nextPut: 55;
			nextPut: ((arg bitShift: -8) bitAnd: 255)].

    "Then the extension byte for the first argument, and the real opcode."
    bytecodes
	nextPut: 55;
	nextPut: (arg bitAnd: 255);
	nextPut: byte;
	nextPut: (arg2 bitAnd: 255)
!

dupStackTop
    self compileByte: 52
!

goto: dest 
    | offset |
    offset := dest - (self translatedpc + bytecodes size) - 2.
    offset < 0 
	ifTrue: 
		[offset <= -256 
			ifTrue: 
				[offset := offset - 2.
				offset <= -65536 
					ifTrue: 
						[offset := offset - 2.
						offset <= -16777216 ifTrue: [offset := offset - 2]]].
		self compileByte: 40 with: offset negated]
	ifFalse:
		[offset >= 256 
			ifTrue: 
				[offset := offset - 2.
				offset >= 65536 
					ifTrue: 
						[offset := offset - 2.
						offset >= 16777216 ifTrue: [offset := offset - 2]]].
		self compileByte: 41 with: offset]
!

lineNumber: line
    self compileByte: 54 with: line
!

popIntoArray: index
    self compileByte: 47 with: index
!

popJumpIfFalseTo: dest 
    self 
	popJumpTo: dest
	conditionBytecode: 43
	inverseBytecode: 42
!

popJumpIfTrueTo: dest 
    self 
	popJumpTo: dest
	conditionBytecode: 42
	inverseBytecode: 43
!

popJumpTo: dest conditionBytecode: jumpForwardBytecode inverseBytecode: jumpAroundBytecode 
    | jumpAroundOfs offset |
    offset := dest - (self translatedpc + bytecodes size) - 2.
    offset < 0 
	ifTrue: 
		[jumpAroundOfs := offset > -254 
					ifTrue: [2]
					ifFalse: 
						[offset > -65534 
							ifTrue: [4]
							ifFalse: [offset > -16777214 ifTrue: [6] ifFalse: [8]]].
		self compileByte: jumpAroundBytecode with: jumpAroundOfs.
		self compileByte: 40 with: offset negated + jumpAroundOfs]
	ifFalse: 
		[offset >= 256 
			ifTrue: 
				[offset := offset - 2.
				offset >= 65536 
					ifTrue: 
						[offset := offset - 2.
						offset >= 16777216 ifTrue: [offset := offset - 2]]].
		self compileByte: jumpForwardBytecode with: offset]
!

popStackTop
    self compileByte: 48
!

pushBlock: object
    object flags = 0 ifTrue: [ ^self pushLiteral: (BlockClosure block: object) ].
    self pushLiteral: object.
    self compileByte: 49
!

pushBoolean: aBoolean 
    ^self compileByte: 45 with: (aBoolean ifTrue: [1] ifFalse: [2])
!

pushGlobal: binding
    | literalIndex |
    literalIndex := self methodTranslator addLiteral: binding.
    self compileByte: 34 with: literalIndex
!

pushInstanceVariable: index
    self compileByte: 35 with: index
!

pushLiteral: object
    | literalIndex |
    (object isInteger and: [ object between: 0 and: 16r3FFFFFFF ])
	ifTrue: [ ^self compileByte: 44 with: object ].

    object isNil ifTrue: [ ^self compileByte: 45 with: 0 ].
    object == true ifTrue: [ ^self compileByte: 45 with: 1 ].
    object == false ifTrue: [ ^self compileByte: 45 with: 2 ].
    literalIndex := self methodTranslator addLiteral: object.
    self compileByte: 46 with: literalIndex
!

pushNil
    ^self compileByte: 45 with: 0
!

pushSelf
    self compileByte: 56
!

pushTemporary: index
    self compileByte: 32 with: index
!

pushTemporary: index outer: scopes 
    self 
	compileByte: 33
	with: index
	with: scopes
!

return
    self compileByte: 51
!

returnFromMethod
    self compileByte: 50
!

send: aSymbol numArgs: numArgs 
    | specialBytecode literalIndex |
    specialBytecode := SpecialSelectorMap at: aSymbol ifAbsent: [nil].
    specialBytecode isNil 
	ifTrue: 
		[literalIndex := self methodTranslator addLiteral: aSymbol.
		self 
			compileByte: 28
			with: literalIndex
			with: numArgs]
	ifFalse: 
		[specialBytecode <= 26 ifTrue: [^self compileByte: specialBytecode].
		self compileByte: 30 with: specialBytecode]
!

storeGlobal: binding
    | literalIndex |
    literalIndex := self methodTranslator addLiteral: binding.
    self compileByte: 38 with: literalIndex
!

storeInstanceVariable: index
    self compileByte: 39 with: index
!

storeTemporary: index
    self compileByte: 36 with: index
!

storeTemporary: index outer: scopes 
    self 
	compileByte: 37
	with: index
	with: scopes
!

superSend: aSymbol numArgs: numArgs 
    | specialBytecode literalIndex |
    self pushLiteral: self javaClass asSmalltalkClass superclass.
    specialBytecode := SpecialSelectorMap at: aSymbol ifAbsent: [nil].
    specialBytecode isNil 
	ifTrue: 
		[literalIndex := self methodTranslator addLiteral: aSymbol.
		self 
			compileByte: 29
			with: literalIndex
			with: numArgs]
	ifFalse: [self compileByte: 31 with: specialBytecode]
! !

!JavaBasicBlock methodsFor: 'translating'!

prepareStackOf: translator
!

translate
    "Do nothing.  All basic blocks should be reached from a
     JavaEntryBasicBlock, else they are dead code."
!

translateEdge
    bytecodes position: translationSize.
    bytecodes truncate.
    self outEdge translateFor: self
!

translateSuccessorsWith: translator 
    | stack |
    stack := translator stack.
    self successorsDo: 
		[:each | 
		translator stack: stack copy.
		each translateWith: translator]
!

translateWith: translator 
    self hasBeenTranslated ifTrue: [ ^self ].
    bytecodes := WriteStream on: (ByteArray new: 16).
    self prepareStackOf: translator.
    translator translateBasicBlock: self.
    translationSize := bytecodes size.
    self outEdge entryBlock: self methodTranslator currentEntryBasicBlock.
    self translateSuccessorsWith: translator
! !

!JavaBasicBlock methodsFor: 'temporaries'!

allocTemporary
    ^self methodTranslator allocTemporary
! !

!JavaBasicBlock methodsFor: 'iterating'!

successorsDo: aBlock
    self outEdge successorsDo: aBlock
! !

!JavaBasicBlock methodsFor: 'testing'!

hasBeenTranslated
    ^bytecodes notNil
! !

!JavaBasicBlock methodsFor: 'java bytecodes'!

pushLocal: localSlot 
    "Static methods in Java do not have a this pointer, so locals
     are 0-based there; instead, they are 1-based in non-static
     methods.  In Smalltalk bytecodes, they are 0-based."

    | tempSlot |
    tempSlot := self javaMethod isStatic 
			ifTrue: [localSlot + 1]
			ifFalse: [localSlot].
    tempSlot = 0 
	ifTrue: [self pushSelf]
	ifFalse: [self pushTemporary: (self methodTranslator temporaryAt: tempSlot) ]
!

storeLocal: localSlot 
    "Static methods in Java do not have a this pointer, so locals
     are 0-based there; instead, they are 1-based in non-static
     methods.  In Smalltalk bytecodes, they are 0-based."

    | tempSlot |
    tempSlot := self javaMethod isStatic 
			ifTrue: [localSlot + 1]
			ifFalse: [localSlot].
    self storeTemporary: (self methodTranslator temporaryAt: tempSlot)
! !

!JavaBasicBlock class methodsFor: 'initialization'!

initialize
    SpecialSelectorMap := LookupTable new.
    CompiledCode specialSelectors keysAndValuesDo: [ :i :each |
	each isNil ifFalse: [SpecialSelectorMap at: each put: i - 1 ]]
! !

!JavaBytecodeAnalyzer methodsFor: 'bytecodes'!

astore: n
    "Identify an astore at the beginning of each subroutine."
    pc = currentBasicBlock startpc
	ifTrue: [ currentBasicBlock initialAStore: n ].

    super astore: n
!

athrow
    nextStartsBasicBlock := true
!

goto: operand
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: operand
!

jsr: operand 
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaSubroutineEntryBasicBlock at: operand
!

lookupswitch: default destinations: dest 
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: default.
    dest do: [:each | 
	self startBasicBlock: JavaBasicBlock at: each value]
!

ret: operand
    self useLocal: operand.
    nextStartsBasicBlock := true
!

return
    nextStartsBasicBlock := true
!

tableswitch: default low: low high: high destinations: addresses 
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: default.
    addresses do: [:each |
	self startBasicBlock: JavaBasicBlock at: each]
! !

!JavaBytecodeAnalyzer methodsFor: 'untyped bytecodes'!

if: aSelector goto: dest
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: dest
!

load: localSlot size: n
    self useLocal: localSlot.
!

store: localSlot size: n 
    self useLocal: localSlot.
!

valueReturn: size
    nextStartsBasicBlock := true
! !

!JavaBytecodeAnalyzer methodsFor: 'accessing'!

basicBlocks
    basicBlocks isEmpty ifTrue: [ self interpret ].
    ^basicBlocks
!

javaMethod
    ^javaMethod
!

localMap
    | last |
    last := 0.
    ^usedLocals collect: [:each | 
	| old |
	old := last.
	last := last + each.
	old]
!

pcToBasicBlockMap
    ^pcToBasicBlockMap
!

useLocal: localSlot
    | tempSlot |
    tempSlot := self javaMethod isStatic 
			ifTrue: [localSlot + 1]
			ifFalse: [localSlot].
    tempSlot > 0 ifTrue: [usedLocals at: tempSlot put: 1]
! !

!JavaBytecodeAnalyzer methodsFor: 'basic block creation'!

addExceptionHandlingBoundaries: aJavaMethod
    aJavaMethod handlers do: 
		[:each || handlerBBClass |
		each handlerpc < each startpc
			ifTrue: [ self error: 'sorry, I''m assuming that try blocks come before exception handlers' ].

		handlerBBClass := each isFinallyHandler
			ifTrue: [ JavaFinallyHandlerBasicBlock ]
			ifFalse: [ JavaExceptionHandlerBasicBlock ].

		self
			startBasicBlock: JavaEntryBasicBlock at: each startpc;
			startBasicBlock: JavaBasicBlock at: each finalpc;
			startBasicBlock: handlerBBClass at: each handlerpc]
!

currentBasicBlock: aBasicBlock 
    basicBlocks add: aBasicBlock.
    currentBasicBlock := aBasicBlock
!

dispatch: op 
    | startBasicBlockAfterThis |
    startBasicBlockAfterThis := nextStartsBasicBlock.
    nextStartsBasicBlock := false.
    super dispatch: op.

    self maybeStartBasicBlock: startBasicBlockAfterThis.
    pcToBasicBlockMap at: pc + 1 put: currentBasicBlock.

    "Note that as a result of this, the jump instruction is not included in a
     basic block.  This is only provisional, the jump is added after the
     JavaEdgeCreator interprets it."
    currentBasicBlock length: pc - currentBasicBlock startpc.
!

interpret
    super interpret.
    self setKnownPcValuesForBasicBlocks.
    (JavaEdgeCreator onSameMethodAs: self) interpret.
!

maybeStartBasicBlock: always
    | class |
    class := always ifTrue: [ JavaBasicBlock ] ifFalse: [ nil ].

    "Always check knownBasicBlockStarts, because it may tell us to
     create a subclass of JavaBasicBlock."
    [knownBasicBlockStarts notEmpty 
	and: [knownBasicBlockStarts first key == pc]] whileTrue: [
		class := knownBasicBlockStarts removeFirst value ].

    class isNil ifFalse: [ self startBasicBlock: class ]
!

pcValueBefore: destPC
    | result |
    result := destPC.
    "Instead of decrementing at the head of the loop, at then
     adding 1 when accessing pcToBasicBlockMap, decrement at
     the bottom of the loop."
    [ (pcToBasicBlockMap at: result) isNil ]
	whileTrue: [ result := result - 1 ].

    ^result - 1
!

setKnownPcValuesForBasicBlocks
    "Go through the knownPcValues, and add a subset of this
     table to each basic block."
    | lastPC lastBB destIndex knownPcValuesArray |
    destIndex := 1.
    knownPcValuesArray := Array new: knownPcValues size + 1.
    lastBB := pcToBasicBlockMap at: 1.

    knownPcValues do: [ :each || bb |
	each = lastPC ifFalse: [
	    knownPcValuesArray at: destIndex put: each.
	    bb := pcToBasicBlockMap at: each + 1.

	    bb == lastBB
		ifFalse: [
		    lastBB knownPcValues: (knownPcValuesArray copyFrom: 1 to: destIndex).
		    lastBB := bb.
		    knownPcValuesArray at: 1 put: each.
		    destIndex := 2 ]
		ifTrue: [
		    destIndex := destIndex + 1 ].

	    lastPC := each.
	]
    ].
    knownPcValuesArray at: destIndex put: lastPC.
    lastBB knownPcValues: (knownPcValuesArray copyFrom: 1 to: destIndex).
!

startBasicBlock: class
    self currentBasicBlock: (class new
	    			startpc: pc;
				length: 0;
				knownPcValues: #[0];
				yourself)
!

startBasicBlock: aClass at: destPC
    | currentBB newBB endPC nextBB |
    currentBB := pcToBasicBlockMap at: destPC + 1.
    knownPcValues add: destPC.

    "It may be a forward reference..."
    currentBB isNil
	ifTrue: [ knownBasicBlockStarts add: destPC->aClass. ^self ].

    "How lucky, we already start a basic block there.  We're done."
    currentBB startpc = destPC
	ifTrue: [ ^self ].

    "Nope, we have to split an existing basic block."
    newBB := aClass new
	startpc: destPC;
	yourself.

    currentBB length = 0
	ifFalse: [
	    newBB length: currentBB finalpc - destPC.
	    endPC := currentBB finalpc ].

    currentBB
	length: (self pcValueBefore: destPC) - currentBB startpc.

    "The new basic block might even be the current one."
    newBB length = ((self pcValueBefore: pc) - destPC)
	ifTrue: [
	    self currentBasicBlock: newBB.
	    endPC := pc ]
	ifFalse: [
	    basicBlocks add: newBB after: currentBB ].

    "Also adjust the pc -> bb map."
    destPC + 1 to: endPC + 1 do: [ :i |
        nextBB := pcToBasicBlockMap at: i.
	nextBB isNil ifFalse: [ pcToBasicBlockMap at: i put: newBB ]].
! !

!JavaBytecodeAnalyzer methodsFor: 'initialization'!

initialize
    super initialize.
    nextStartsBasicBlock := false.
    basicBlocks := OrderedCollection new.
    "Put subclasses after superclasses"
    knownBasicBlockStarts :=
	SortedCollection sortBlock: [:a :b | 
	    a key < b key or: [a key = b key and: [b value inheritsFrom: a value]]]
!

javaMethod: aJavaMethod
    javaMethod := aJavaMethod.
    usedLocals := aJavaMethod isStatic
	ifTrue: [ ByteArray new: aJavaMethod maxLocals ]
	ifFalse: [ ByteArray new: aJavaMethod maxLocals - 1 ].

    self addExceptionHandlingBoundaries: aJavaMethod.

    aJavaMethod lines isNil ifFalse: [
        aJavaMethod lines do: [ :each | knownPcValues add: each key ]
    ]
!

stream: aStream
    knownPcValues := SortedCollection new.
    super stream: aStream.
    pcToBasicBlockMap := Array new: aStream size + 1.
    self startBasicBlock: JavaEntryBasicBlock at: 0
! !

!JavaBytecodeAnalyzer class methodsFor: 'interpretation'!

onMethod: aJavaMethod
    ^(super onMethod: aJavaMethod)
	javaMethod: aJavaMethod;
	yourself
! !

!JavaProgramNode methodsFor: 'accessing'!

wordSize
    ^wordSize
!

wordSize: anObject
    wordSize := anObject
! !

!JavaProgramNode methodsFor: 'translating'!

incremented
    ^(JavaMessageSendNode new: 2)
	at: 1 put: self;
	at: 2 put: (JavaConstantNode new wordSize: self wordSize; object: 1);
	wordSize: self wordSize;
	selector: #+;
	yourself
!

emitForEffect: aJavaBasicBlock
!

emitForValue: aJavaBasicBlock
! !

!JavaProgramNode methodsFor: 'testing'!

isLocal
    ^false
!

isSpill
    ^false
! !

!JavaProgramNode class methodsFor: 'translation'!

emitForValue: destinationBasicBlock
! !

!JavaConstantNode methodsFor: 'accessing'!

object
    ^object
!

object: anObject
    object := anObject
! !

!JavaConstantNode methodsFor: 'translating'!

incremented
    ^JavaConstantNode new
	wordSize: self wordSize;
	object: self object + 1;
	yourself
!

emitForValue: aJavaBasicBlock
    aJavaBasicBlock pushLiteral: self object
! !

!JavaConstantNode class methodsFor: 'instance creation'!

object: anObject wordSize: n
    ^self new object: anObject; wordSize: n; yourself
! !

!JavaLocalNode methodsFor: 'accessing'!

id
    ^id
!

id: anObject
    id := anObject
! !

!JavaLocalNode methodsFor: 'translating'!

emitForValue: aJavaBasicBlock
    aJavaBasicBlock pushLocal: self id
! !

!JavaLocalNode methodsFor: 'testing'!

isLocal
    ^true
! !

!JavaLocalNode class methodsFor: 'instance creation'!

id: anIndex wordSize: n
    ^self new id: anIndex; wordSize: n; yourself
! !

!JavaSpillNode methodsFor: 'translating'!

emitForValue: aJavaBasicBlock
    aJavaBasicBlock pushTemporary: self id
! !

!JavaSpillNode methodsFor: 'testing'!

isLocal
    ^false
!

isSpill
    ^true
! !

!JavaArrayNode methodsFor: 'translation'!

emitForEffect: aBasicBlock
    1 to: self size do: [ :index |
	(self at: index) emitForEffect: aBasicBlock ].
!

emitForValue: aBasicBlock
    aBasicBlock
	pushLiteral: Array;
	pushLiteral: self size;
	send: #new: numArgs: 1.

    1 to: self size do: [ :index |
	(self at: index) emitForValue: aBasicBlock.
	aBasicBlock popIntoArray: index - 1 ].
! !

!JavaMessageSendNode methodsFor: 'translating'!

emitForEffect: aJavaBasicBlock
    self emitForValue: aJavaBasicBlock.
    aJavaBasicBlock popStackTop
!

emitForValue: aJavaBasicBlock
    1 to: self size do: [ :each | (self at: each) emitForValue: aJavaBasicBlock ].
    aJavaBasicBlock send: self selector numArgs: self size - 1
! !

!JavaMessageSendNode methodsFor: 'accessing'!

selector
    ^selector
!

selector: anObject
    selector := anObject
! !

!JavaSuperMessageSendNode methodsFor: 'translating'!

emitForValue: aJavaBasicBlock
    1 to: self size do: [ :each | (self at: each) emitForValue: aJavaBasicBlock ].
    aJavaBasicBlock superSend: self selector numArgs: self size - 1
! !

!JavaEntryBasicBlock methodsFor: 'translating'!

translate
    methodTranslator currentEntryBasicBlock: self.
    self translateWith: (JavaBytecodeTranslator onMethod: self javaMethod)
! !

!JavaEntryBasicBlock methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'entry point, '.
    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
! !

!JavaEntryBasicBlock methodsFor: 'accessing'!

exceptionLocal
    ^nil
! !

!JavaExceptionHandlerBasicBlock methodsFor: 'translating'!

prepareStackOf: translator
    translator stackPush: (JavaSpillNode new
			       id: methodTranslator exceptionTemp;
			       wordSize: 1;
			       yourself)
! !

!JavaFinallyHandlerBasicBlock methodsFor: 'accessing'!

exceptionLocal
    ^exceptionLocal
!

exceptionLocal: anObject
    exceptionLocal := anObject
!

initialAStore: local
    self exceptionLocal: local
! !

!JavaFinallyHandlerBasicBlock methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'catch-all exception handler, '.
    self exceptionLocal isNil 
	ifFalse: 
		[aStream
			nextPutAll: 'exception in ';
			print: self exceptionLocal;
			nextPutAll: ', '].

    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
! !

!JavaSubroutineEntryBasicBlock methodsFor: 'translating'!

prepareStackOf: translator
    "Pushing a JavaProgramNode results in no generated code;
     the push was done for real by the JavaJumpToFinallyEdge,
     and since this compiles to an unconditional jump
     bytecode, this is not in violation of the verification
     constraints (unlike in JavaExceptionHandlerBasicBlocks,
     where the JVM's automatic push of the exception must be
     mapped to a store into a temporary."
    translator stackPush: (JavaProgramNode new wordSize: 1; yourself).
! !

!JavaSubroutineEntryBasicBlock methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'jsr target, '.
    self returnPoint isNil 
	ifFalse: 
		[aStream
			nextPutAll: 'non-exception return to ';
			print: self returnPoint startpc;
			nextPutAll: ', '].

    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
! !

!JavaSubroutineEntryBasicBlock methodsFor: 'accessing'!

returnPoint
    ^returnPoint
!

returnPoint: anObject
    returnPoint := anObject
! !

!JavaEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    self subclassResponsibility
! !

!JavaEdge methodsFor: 'translation'!

edgeStackBalance
    ^0
!

translateFor: aBasicBlock
    self subclassResponsibility
! !

!JavaEdge methodsFor: 'accessing'!

entryBlock: anObject 
    "Do nothing, present for subclasses"
! !

!JavaGotoEdge methodsFor: 'accessing'!

successor
    ^successor
!

successor: anObject
    successor := anObject
! !

!JavaGotoEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    aBlock value: successor
! !

!JavaGotoEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'goto ';
	print: self successor startpc
! !

!JavaGotoEdge methodsFor: 'translation'!

translateFor: aBasicBlock
    aBasicBlock goto: successor translatedpc
! !

!JavaGotoEdge class methodsFor: 'instance creation'!

successor: successor
    ^self new
	successor: successor
! !

!JavaFallThroughEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'fall through to ';
	print: self successor startpc
! !

!JavaFallThroughEdge methodsFor: 'translation'!

translateFor: aBasicBlock
    "Do nothing!"
! !

!JavaJumpToFinallyEdge methodsFor: 'accessing'!

entryBlock
    ^entryBlock
!

entryBlock: anObject 
    entryBlock := anObject.

    "This is a very nice point to complete the initialization of the
     JavaSubroutineEntryBasicBlock: try blocks come before
     handlers, so we set the subroutine's return point only if we are in
     the scope of a try block: then the subroutine will come back to our
     fall-through basic block when there will be no exception."
    self successor returnPoint isNil 
	ifTrue: [self successor returnPoint: self returnPoint]
!

exceptionLocal
    ^self entryBlock exceptionLocal
!

returnPoint
    ^returnPoint
!

returnPoint: anObject
    returnPoint := anObject
! !

!JavaJumpToFinallyEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'jsr ';
	print: self successor startpc.

    self exceptionLocal isNil
	ifTrue: [ aStream nextPutAll: ' fall through to '; print: self returnPoint startpc ]
	ifFalse: [ aStream nextPutAll: ' with exception in '; print: self exceptionLocal ]
! !

!JavaJumpToFinallyEdge methodsFor: 'translation'!

translateFor: aBasicBlock 
    | exceptionLocal |

    "The jump to a `finally' block is actually a jsr.  We mimic it by
     pushing an exception to be thrown at the end of the execution,
     instead of a return address.  Likewise, ret will throw an
     exception instead of jumping to an address (similar to athrow),
     or jump to a single exit-point (the end of the try block) if the
     exception is nil."
    exceptionLocal := self exceptionLocal.
    exceptionLocal isNil
	ifFalse: [aBasicBlock pushLocal: exceptionLocal]
	ifTrue: [aBasicBlock pushLiteral: nil].
    aBasicBlock
	goto: successor translatedpc
! !

!JavaJumpToFinallyEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    self exceptionLocal isNil
	ifTrue: [ aBlock value: self returnPoint ]
! !

!JavaJumpToFinallyEdge class methodsFor: 'instance creation'!

successor: destBB returnPoint: fallThroughBB
    ^(self successor: destBB)
	returnPoint: fallThroughBB;
	yourself
! !

!JavaReturnEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
! !

!JavaReturnEdge methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'return'
! !

!JavaReturnEdge methodsFor: 'translation'!

edgeStackBalance
    ^-1
!

translateFor: aBasicBlock
    aBasicBlock return
! !

!JavaReturnEdge class methodsFor: 'singleton'!

soleInstance
    soleInstance isNil ifTrue: [ soleInstance := self basicNew ].
    ^soleInstance
! !

!JavaReturnEdge class methodsFor: 'instance creation'!

new
    self error: 'this class is a singleton, send #soleInstance to instantiate it.'
! !

!JavaThrowExceptionEdge methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'throw exception'
! !

!JavaThrowExceptionEdge methodsFor: 'translation'!

translateFor: aBasicBlock
    "Use a return bytecode (instead of a pop) to keep the stack
     balanced, so that the optimizer does not combine anything
     after the throw statement."
    aBasicBlock
	send: #throw numArgs: 0;
	return.
! !

!JavaSwitchStatementEdge methodsFor: 'accessing'!

basicBlocks
    ^basicBlocks
!

basicBlocks: anObject
    basicBlocks := anObject
!

defaultSuccessor
    ^defaultSuccessor
!

defaultSuccessor: anObject
    defaultSuccessor := anObject
!

size
    ^basicBlocks size
!

values
    self subclassResponsibility
!

valuesAt: anIndex
    ^self values at: anIndex
! !

!JavaSwitchStatementEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    basicBlocks do: aBlock.
    aBlock value: defaultSuccessor
! !

!JavaSwitchStatementEdge methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: 'switch ';
	print: (self basicBlocks with: self values collect: [:a :b | b -> a startpc]);
	nextPutAll: ', default ';
	print: self defaultSuccessor startpc
! !

!JavaSwitchStatementEdge methodsFor: 'translation'!

edgeStackBalance
    ^-1
!

nextLabel
    currentLabel = jumpTargets size
	ifTrue: [ jumpTargets addLast: nil ].

    ^currentLabel := currentLabel + 1
!

translateFor: aBasicBlock
    jumpTargets isNil ifTrue: [
	jumpTargets := OrderedCollection new: self size].
    currentLabel := 0.
    self translateFor: aBasicBlock between: 1 and: self size
!

translateFor: aBasicBlock between: low and: high 
    "Check if the recursion has ended."

    | label mid midIndex |
    low >= high 
	ifTrue: 
		[self translateFor: aBasicBlock case: low.
		^self].

    "If not, create the bytecodes for a binary search."
    mid := self valuesAt: (midIndex := (low + high) // 2).
    label := self translateSplitFor: aBasicBlock at: mid.

    "Recursively compile the first half,..."
    self 
	translateFor: aBasicBlock
	between: low
	and: midIndex.

    "... set up the label for the next pass, and recursively compile the second half."
    jumpTargets at: label put: aBasicBlock translatedpc + aBasicBlock size.
    self 
	translateFor: aBasicBlock
	between: midIndex + 1
	and: high
!

translateFor: aBasicBlock case: case 
    "Check if the value is really the one we meant, and if so,
     jump to the case; else, jump to the default label."

    | destPC |
    destPC := (self basicBlocks at: case) translatedpc.
    aBasicBlock
	pushLiteral: (self valuesAt: case);
	send: #= numArgs: 1;
	popJumpIfTrueTo: destPC;
	goto: self defaultSuccessor translatedpc
!

translateSplitFor: aBasicBlock at: mid
    | target label |
    label := self nextLabel.
    "Make sure we do not alter the stack height before making the final decision."
    aBasicBlock
	dupStackTop;
	pushLiteral: mid;
	send: #<= numArgs: 1.
    target := jumpTargets at: label.
    target isNil 
	ifTrue: [aBasicBlock popStackTop]
	ifFalse: [aBasicBlock popJumpIfFalseTo: target].
    ^label
! !

!JavaSwitchStatementEdge class methodsFor: 'instance creation'!

basicBlocks: aCollection defaultSuccessor: defaultSuccessor 
    ^self new
	basicBlocks: aCollection;
	defaultSuccessor: defaultSuccessor;
	yourself
! !

!JavaTableSwitchStatementEdge methodsFor: 'accessing'!

high
    ^low + self basicBlocks size - 1
!

low
    ^low
!

low: anObject
    low := anObject.
    high := low + self basicBlocks size - 1
!

values
    ^self low to: self high
!

valuesAt: anIndex
    ^self low + anIndex - 1
! !

!JavaTableSwitchStatementEdge methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: 'table'.
    super printOn: aStream.
! !

!JavaTableSwitchStatementEdge methodsFor: 'translation'!

translateFor: aBasicBlock case: case 
    "For the extrema, add an equality check that jumps to the default label."
    | destPC |
    (case = 1 or: [case = self size]) 
	ifTrue: 
		[super translateFor: aBasicBlock case: case.
		^self].

    "Else we're sure that the values are consecutive: we can jump right to the destination"
    destPC := (self basicBlocks at: case) translatedpc.
    aBasicBlock popStackTop.
    aBasicBlock goto: destPC
! !

!JavaTableSwitchStatementEdge class methodsFor: 'instance creation'!

basicBlocks: aCollection defaultSuccessor: defaultSuccessor low: low
    ^(self basicBlocks: aCollection defaultSuccessor: defaultSuccessor)
	low: low;
	yourself
! !

!JavaLookupSwitchStatementEdge methodsFor: 'accessing'!

values
    ^values
!

values: anObject
    values := anObject
! !

!JavaLookupSwitchStatementEdge methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: 'lookup'.
    super printOn: aStream.
! !

!JavaLookupSwitchStatementEdge class methodsFor: 'instance creation'!

basicBlocks: aCollection defaultSuccessor: defaultSuccessor values: values
    ^(self basicBlocks: aCollection defaultSuccessor: defaultSuccessor)
	values: values;
	yourself
! !

!JavaVoidReturnEdge methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'return void'
! !

!JavaVoidReturnEdge methodsFor: 'translation'!

edgeStackBalance
    ^0
!

translateFor: aBasicBlock
    aBasicBlock pushSelf; return
! !

!JavaConditionalEdge methodsFor: 'accessing'!

applyComparison: aSymbol
    "Modify the condition (inverting the direction of the jump *and*
     the operator) so that NaNs are properly handled when the
     [fd]cmp[lg] bytecodes are stripped.  fcmpl and dcmpl jump if one 
     of the operands is a NaN and their result is examined with iflt/ifle:
     this is the same as jumping if !(a >= b) or !(a > b) respectively.
     On the other hand, fcmpg and dcmpj jump if one of the operands
     is a NaN and their result is examined with ifgt/ifge: this is
     the same as jumping if !(a <= b) or !(a < b) respectively."

    aSymbol == #javaCmpL:
	ifTrue: [
	    condition == #< ifTrue: [ self negate. condition := #>= ].
	    condition == #<= ifTrue: [ self negate. condition := #> ].
	    ^self ].
    aSymbol == #javaCmpG:
	ifTrue: [
	    condition == #> ifTrue: [ self negate. condition := #<= ].
	    condition == #>= ifTrue: [ self negate. condition := #< ].
	    ^self ].
!

condition
    ^condition
!

condition: anObject
    condition := anObject.

    "These are slow in Smalltalk."
    anObject == #~~ ifTrue: [ self negate. condition := #== ].
    anObject == #~= ifTrue: [ self negate. condition := #= ].
!

negated
    ^negated
!

negate
    negated := negated not
!

negated: aBoolean
    negated := aBoolean
!

successorFalse
    ^successorFalse
!

successorFalse: anObject
    successorFalse := anObject
!

successorTrue
    ^successorTrue
!

successorTrue: anObject
    successorTrue := anObject
! !

!JavaConditionalEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    aBlock value: successorTrue.
    aBlock value: successorFalse
! !

!JavaConditionalEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: (self negated ifTrue: [ 'if not ' ] ifFalse: [ 'if ' ]);
	nextPutAll: self condition;
	nextPutAll: ' goto ';
	print: self successorTrue startpc;
	nextPutAll: ' else goto ';
	print: self successorFalse startpc
! !

!JavaConditionalEdge methodsFor: 'translation'!

edgeStackBalance
    ^-2
!

translateFor: aBasicBlock
    aBasicBlock send: condition numArgs: 1.
    negated
	ifFalse: [ aBasicBlock popJumpIfTrueTo: successorTrue translatedpc ]
	ifTrue: [ aBasicBlock popJumpIfFalseTo: successorTrue translatedpc ]
    "Else, fall through to successorFalse"
! !

!JavaConditionalEdge class methodsFor: 'instance creation'!

condition: aSelector successorTrue: successorTrue successorFalse: successorFalse
    ^self new
	negated: false;
	condition: aSelector;
	successorTrue: successorTrue;
	successorFalse: successorFalse;
	yourself
! !

!JavaLocalStoreNode methodsFor: 'accessing'!

value
    ^value
!

value: anObject
    value := anObject
! !

!JavaLocalStoreNode methodsFor: 'translating'!

emitForEffect: aJavaBasicBlock
    self emitForValue: aJavaBasicBlock.
    aJavaBasicBlock popStackTop
!

emitForValue: aJavaBasicBlock
    self value emitForValue: aJavaBasicBlock.
    aJavaBasicBlock storeLocal: self id
! !

!JavaLocalStoreNode class methodsFor: 'instance creation'!

id: anIndex value: aNode
    ^self new id: anIndex; value: aNode; wordSize: aNode wordSize; yourself
! !

!JavaSubroutineReturnEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'return from subroutine '
! !

!JavaSubroutineReturnEdge methodsFor: 'translation'!

entryBlock: aBasicBlock
    "This is a nice place to get the basic block to which we return, because
     it has already been set in the JavaSubroutineEntryBasicBlock by
     the JavaJumpToFinallyEdge in the method's main flow of execution."
    self successor: aBasicBlock returnPoint
!

translateFor: aBasicBlock
    aBasicBlock
	pushLocal: exceptionLocal;
	send: #isNil numArgs: 0;
	popJumpIfTrueTo: self successor translatedpc;
	pushLocal: exceptionLocal;
	send: #throw numArgs: 0;
	return.
! !

!JavaSubroutineReturnEdge methodsFor: 'accessing'!

exceptionLocal
    ^exceptionLocal
!

exceptionLocal: anObject
    exceptionLocal := anObject
! !

!JavaSubroutineReturnEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
! !

!JavaSubroutineReturnEdge class methodsFor: 'instance creation'!

exceptionLocal: exceptionLocal
    ^self new
	exceptionLocal: exceptionLocal
! !

!TargetInstructionPrinter methodsFor: 'printing'!

bytecodeIndex: byte
    "Private - Print the bytecode index for byte"

    | s |
    s := (byte + base) printString.
    stream
        space: 5 - s size;
        nextPut: $[;
        nextPutAll: s;
        nextPut: $].
!

dupStackTop
    stream tab; nextPutAll: 'dup stack top'; nl
!

exitInterpreter
    stream tab; nextPutAll: 'exit interpreter'; nl
!

invalidOpcode
    stream tab; nextPutAll: 'invalid opcode'; nl
!

jumpTo: destination
    stream tab; nextPutAll: 'jump to '; print: (base + destination); nl
!

lineNo: n
    stream tab; nextPutAll: 'source code line number '; print: n; nl
!

makeDirtyBlock
    stream tab; nextPutAll: 'make dirty block'; nl
!

popIntoArray: anIndex
    stream tab; nextPutAll: ('pop and store into array element[%1]' % { anIndex }); nl
!

popJumpIfFalseTo: destination
    stream tab; nextPutAll: 'pop and if false jump to '; print: (base + destination); nl
!

popJumpIfTrueTo: destination
    stream tab; nextPutAll: 'pop and if true jump to '; print: (base + destination); nl
!

popStackTop
    stream tab; nextPutAll: 'pop stack top'; nl
!

printOn: aStream 
    "Disassemble the bytecodes and tell self about them in the form
     of message sends.  param is given as an argument to every message
     send."

    | lastOfs |
    stream := aStream.
    lastOfs := -1.
    self allByteCodeIndicesDo: [:i :byte :arg | 
	lastOfs = i 
	    ifFalse: 
		[self bytecodeIndex: i.
		lastOfs := i].
	self 
	    dispatchByte: byte
	    with: arg
	    at: i].
    stream := nil
!

pushGlobal: anObject
    stream tab; nextPutAll: 'push Global Variable '; print: anObject; nl
!

pushInstVar: anIndex
    stream tab; nextPutAll: ('push Instance Variable[%1]' % { anIndex }); nl
!

pushLiteral: anObject
    | printString |
    printString := [ anObject printString ] on: Error do: [ :ex | ex return: nil ].
    (printString isNil or: [ printString size > 40 ]) ifTrue: [
        printString := anObject isClass
	    ifTrue: [ anObject name displayString ]
	    ifFalse: [ '%1 %2' % { anObject class article. anObject class name } ]].

    stream tab; nextPutAll: 'push '; nextPutAll: printString; nl
!

pushSelf
    stream tab; nextPutAll: 'push self'; nl
!

pushTemporary: anIndex
    stream tab; nextPutAll: ('push Temporary[%1]' % { anIndex }); nl
!

pushTemporary: anIndex outer: scopes
    stream tab; nextPutAll: ('push Temporary[%1] from outer context #%2' % { anIndex. scopes }); nl
!

returnFromContext
    stream tab; nextPutAll: 'return stack top'; nl
!

returnFromMethod
    stream tab; nextPutAll: 'return from method'; nl
!

send: aSymbol numArgs: anInteger
    stream tab; nextPutAll: ('send %2 args message %1' % { aSymbol storeString. anInteger }); nl
!

storeGlobal: anObject
    stream tab; nextPutAll: 'store into Global Variable '; print: anObject; nl
!

storeInstVar: anIndex
    stream tab; nextPutAll: ('store into Instance Variable[%1]' % { anIndex }); nl
!

storeTemporary: anIndex
    stream tab; nextPutAll: ('store into Temporary[%1]' % { anIndex }); nl
!

storeTemporary: anIndex outer: scopes
    stream tab; nextPutAll: ('store into Temporary[%1] from outer context #%2' % { anIndex. scopes }); nl
!

superSend: aSymbol numArgs: anInteger
    stream tab; nextPutAll: ('send %2 args message %1 to super' % { aSymbol. anInteger }); nl
! !

!TargetInstructionPrinter methodsFor: 'decoding bytecodes'!

dispatchByte: byte with: operand at: anIndex
    "Private - Print the byte bytecode (starting at anIndex) on param"

    byte <= 26 ifTrue: [ ^self dispatchSend: 30 with: byte ].
    byte < 32 ifTrue: [ ^self dispatchSend: byte with: operand ].
    byte < 40 ifTrue: [ ^self dispatchVariableOp: byte with: operand ].
    byte < 44 ifTrue: [ ^self dispatchJump: byte at: anIndex ].
    byte < 48 ifTrue: [ ^self dispatchOtherStack: byte with: operand ].
    byte < 54 ifTrue: [ ^self dispatchOneByte: byte ].
    byte = 54 ifTrue: [ ^self lineNo: operand ].
    byte = 56 ifTrue: [ ^self pushSelf ].
    ^self invalidOpcode
!

dispatchJump: byte at: anIndex
    | destination |
    destination := self jumpDestinationAt: anIndex.

    byte < 42 ifTrue: [ ^self jumpTo: destination ].
    byte = 42 ifTrue: [ ^self popJumpIfTrueTo: destination ].
    byte = 43 ifTrue: [ ^self popJumpIfFalseTo: destination ].
!

dispatchOneByte: byte
    byte == 48 ifTrue: [ ^self popStackTop ].
    byte == 49 ifTrue: [ ^self makeDirtyBlock ].
    byte == 50 ifTrue: [ ^self returnFromMethod ].
    byte == 51 ifTrue: [ ^self returnFromContext ].
    byte == 52 ifTrue: [ ^self dupStackTop ].
    byte == 53 ifTrue: [ ^self exitInterpreter ].
!

dispatchOtherStack: byte with: operand
    byte = 44 ifTrue: [ ^self pushLiteral: operand ].
    byte = 46 ifTrue: [ ^self pushLiteral: (literals at: operand + 1) ].
    byte = 47 ifTrue: [ ^self popIntoArray: operand ].
    operand = 0 ifTrue: [ ^self pushLiteral: nil ].
    operand = 1 ifTrue: [ ^self pushLiteral: true ].
    operand = 2 ifTrue: [ ^self pushLiteral: false ].
    ^self invalidOpcode
!

dispatchSend: byte with: operand
    byte = 28 ifTrue: [
        ^self
	    send: (literals at: operand // 256 + 1)
	    numArgs: operand \\ 256
    ].
    byte = 29 ifTrue: [
        ^self
            superSend: (literals at: operand // 256 + 1)
            numArgs: operand \\ 256
    ].
    byte = 30 ifTrue: [
        ^self
            send: (CompiledCode specialSelectors at: operand + 1)
            numArgs: (CompiledCode specialSelectorsNumArgs at: operand + 1)
    ].
    byte = 31 ifTrue: [
        ^self
            superSend: (CompiledCode specialSelectors at: operand + 1)
            numArgs: (CompiledCode specialSelectorsNumArgs at: operand + 1)
    ].
    ^self invalidOpcode
!

dispatchVariableOp: byte with: operand
    byte = 32 ifTrue:
	[ ^self pushTemporary: operand ].
    byte = 33 ifTrue:
	[ ^self pushTemporary: (operand // 256) outer: (operand \\ 256) ].
    byte = 34 ifTrue:
	[ ^self pushGlobal: (literals at: operand + 1) ].
    byte = 35 ifTrue:
	[ ^self pushInstVar: operand ].
    byte = 36 ifTrue:
	[ ^self storeTemporary: operand ].
    byte = 37 ifTrue:
	[ ^self storeTemporary: (operand // 256) outer: (operand \\ 256) ].
    byte = 38 ifTrue:
	[ ^self storeGlobal: (literals at: operand + 1) ].
    byte = 39 ifTrue:
	[ ^self storeInstVar: operand ]
! !

!TargetInstructionPrinter methodsFor: 'accessing'!

base
    ^base
!

base: anObject
    base := anObject - 1.
!

bytecodes
    ^bytecodes
!

bytecodes: anObject
    bytecodes := anObject
!

literals
    ^literals
!

literals: anObject
    literals := anObject
! !

!TargetInstructionPrinter methodsFor: 'private'!

allByteCodeIndicesDo: aBlock
    "Private - Evaluate aBlock passing each of the index where a
     new bytecode instruction starts"

    | i byte operand ofs |
    i := 1.
    [ i <= bytecodes size ] whileTrue: [
        ofs := i.
        operand := 0.
        [
            byte := bytecodes at: i.
            operand := operand * 256 + (bytecodes at: i + 1).
            i := i + 2.
            byte = 55 
        ] whileTrue.

        aBlock
            value: ofs
            value: byte
            value: operand
    ]
!

jumpDestinationAt: anIndex
    "Answer where the jump at bytecode index `anIndex' lands"
    | result ofs byte |
    ofs := anIndex.
    [ anIndex > 2 and: [ (bytecodes at: ofs - 2) = 55 ] ]
    whileTrue: [ ofs := ofs - 2 ].

    result := 0.
    [ result := result * 256 + (bytecodes at: ofs + 1).
      byte := bytecodes at: ofs.
      ofs := ofs + 2.
      byte = 55 ] whileTrue.

    ^byte = 40
        ifTrue: [ ofs - result ]
        ifFalse: [ ofs + result ].
! !

!TargetInstructionPrinter class methodsFor: 'printing'!

print: bytecodes literals: literals base: anInteger on: aStream
    self new
	bytecodes: bytecodes;
	literals: literals;
	base: (anInteger isNil ifTrue: [0] ifFalse: [anInteger]);
	printOn: aStream
!

print: bytecodes literals: literals on: aStream 
    self 
	print: bytecodes
	literals: literals
	base: 0
	on: aStream
! !

JavaBasicBlock initialize!
