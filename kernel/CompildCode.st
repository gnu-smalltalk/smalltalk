"======================================================================
|
|   CompiledCode Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000,2001,2002,2003,2004,2005,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



ArrayedCollection subclass: CompiledCode [
    | literals header |
    
    <shape: #byte>
    <category: 'Language-Implementation'>
    <comment: 'I represent code that has been compiled.  I am an abstract
superclass for blocks and methods'>

    CompiledCode class >> specialSelectors [
	"Answer an array of message names that don't need to be in
	 literals to be sent in a method.  Their position here
	 reflects their integer code in bytecode."
	<category: 'tables'>
	^#(#+ #- #< #> #<= #>= #= #~= #* #/ #\\ #bitXor: #bitShift: #// #bitAnd: #bitOr: #at: #at:put: #size #class #isNil #notNil #value #value: #== #javaAsInt #javaAsLong nil nil nil nil nil #new: #thisContext #callInto: #narrow #nextPutAll: #yourself #, #on: #subclassResponsibility #add: #nl #printString #contents #name #isEmpty #properties #container #error: #first #tclEval: #collect: #tclResult #key #asTkString #abs #basicNew #negated #not #close #includes: #at:ifAbsent: #asSymbol #with: #copy #copyFrom:to: #print: #last #initialize #tclEval:with:with: #assert: #primitiveFailed #initialize: #asString #cr #should: #arguments #x #readStream #y #tclEval:with:with:with: #asInteger #space #new #shouldNotImplement #-> #numArgs #with:with: #species #blox #step #signal #parent #selector #at:ifPresent: #to: #addLast: #squared #generality #signalOn:mustBe: #ensure: #body #max: #keysAndValuesDo: #printOn: #isKindOf: #visitNode: #addAll: #isInteger #name: #hash #sqrt #beep #primAt: #environment #position #at:ifAbsentPut: #signal: #postCopy #readFrom: #coefficients: #clientPI #flush #value:value: #asFloatD #on:do: #basicAt:put: #primSize #evaluate #connected #reset #copyEmpty: #start #signalOn: #basicAt: #asClass #ln #implementation #checkResponse #average #upTo: #receiver #peek #basicSize #x:y: #foregroundColor: #rows: #text #exp #statements #body: #| #sizeof #includesKey: #pi #completedSuccessfully #writeStream #superclass #arguments: #state #truncated #inject:into: #replaceFrom:to:with:startingAt: #current #between:and: #retryRelationalOp:coercing: #connectIfClosed #detect:ifNone: #checkError #executeAndWait:arguments: #min: #width #parentContext #removeLast #zero #bindWith:with: #temporaries #asOop #width:height: #methodDictionary #accumulate: #count #asLowercase #asArray #exists #signalOn:what: #select: #parent: #selector: #signalOn:withIndex: #bind:to:of:parameters: #return: #~~ #changeState: #sign #variance #asVector #getResponse #wait #instanceClass #asOrderedCollection #keys #asFloat #random #origin #superspace #stop #perform: #backgroundColor: #login #data: #nextToken #primAt:put: #method #allSatisfy: #position: #default #atAllPut: #asSortedCollection #invalidArgsError: #nameIn: #allSubclassesDo: #signalError #height #source #asNumber #primitive #store: #updateViews #errorContents: #displayString #skipSeparators #origin:corner: #activeProcess #bindWith: #beConsistent #at:type: #skip: #days #tclEval:with: #fromSeconds: #& #upToEnd #variable #become: #with:do: #findIndexOrNil: #asSeconds #copyWith: #background #status #selectors:receiver:argument: #create: #coerce: #bytecodeAt:)
    ]

    CompiledCode class >> specialSelectorsNumArgs [
	"Answer a harmoniously-indexed array of arities for the
	 messages answered by #specialSelectors."
	<category: 'tables'>
	^#[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 0 0 0 0 0 1 1 0 0 255 255 255 255 255 1 0 1 0 1 0 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0 1 2 0 1 0 2 1 0 0 3 1 0 1 0 0 1 0 0 0 0 4 0 0 0 0 1 0 2 0 0 0 0 0 0 2 1 1 0 0 2 1 0 1 1 1 1 1 1 0 1 0 0 0 1 0 0 2 1 0 1 1 0 0 2 0 2 2 0 0 0 0 1 0 1 1 0 0 0 0 0 1 0 0 0 2 1 1 0 0 0 1 1 0 1 0 0 0 0 1 0 0 2 4 0 2 2 0 2 0 2 1 0 0 0 0 2 0 0 2 0 1 0 0 0 0 2 1 1 1 2 4 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 1 0 2 0 1 1 0 1 0 1 1 1 0 0 0 0 0 1 0 1 0 0 2 0 1 0 2 1 0 2 1 1 0 0 1 2 1 0 1 0 0 3 1 1 1]
    ]

    CompiledCode class >> bytecodeInfoTable [
	"Return a ByteArray which defines some properties of the bytecodes.
	 For each bytecode, 4 bytes are reserved.  The fourth byte is a
	 flag byte: bit 7 means that the argument is a line number to be
	 used in creating the bytecode->line number map.
	 
	 The first three have a meaning only for those bytecodes that
	 represent a combination of operations: the combination can be
	 BC1 ARG BC2 OPERAND      if the fourth byte's bit 0 = 0
	 or  BC1 OPERAND BC2 ARG      if the fourth byte's bit 0 = 1
	 
	 where BC1 is the first byte, BC2 is the second, ARG is the third
	 and OPERAND is the bytecode argument as it appears in the bytecode
	 stream."

	"Automatically generated by superops.  Do not modify this definition!"

	<category: 'tables'>
	^#[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 128 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 55 28 1 1 55 28 0 1 56 51 0 0 54 56 0 129 54 48 0 129 54 32 0 129 46 49 0 1 55 28 2 1 48 52 0 0 32 30 0 0 56 65 0 0 45 51 0 1 56 30 0 0 55 33 1 1 36 48 0 1 56 32 0 0 39 66 0 1 44 0 0 1 54 34 0 129 32 32 0 0 32 28 0 0 54 32 1 129 20 43 0 0 44 6 0 1 55 28 3 1 32 64 0 0 67 28 0 129 32 51 0 1 46 30 36 1 24 43 0 0 46 64 1 1 68 56 0 129 72 54 0 128 32 65 0 0 32 30 1 0 46 6 0 1 44 1 0 1 52 43 0 0 48 54 0 128 44 30 32 1 32 18 0 1 56 28 0 0 54 32 2 129 48 30 0 0 32 81 1 1 54 35 0 129 46 30 38 1 44 16 0 1 54 35 1 129 32 46 0 0 52 42 0 0 32 16 0 1 32 30 2 0 46 30 49 1 36 68 1 128 32 64 1 0 39 48 0 1 55 37 1 1 44 30 96 1 48 32 0 0 35 51 0 1 68 32 1 129 68 32 0 129 67 46 0 129 46 51 0 1 56 18 0 0 20 42 0 0 32 17 0 1 54 34 1 129 32 0 0 1 48 40 0 0 48 34 0 0 44 36 1 0 46 64 2 1 54 32 3 129 54 33 1 129 35 28 0 1 44 3 0 1 32 22 0 1 32 1 0 1 46 64 3 1 45 93 0 0 36 68 2 128 24 42 0 0 44 8 0 1 54 35 2 129 44 2 0 1 46 17 0 1 55 33 2 1 67 84 1 129 79 64 0 0 67 30 40 129 32 32 3 1 36 54 1 128 69 28 0 129 44 14 0 1 32 65 2 0 83 28 1 0 67 32 0 129 54 35 3 129 32 64 2 0 21 43 0 0 36 54 2 128 36 68 3 128 46 30 1 0 32 6 0 1 72 108 0 0 56 64 0 0 36 68 0 128 52 54 0 128 56 117 0 0 48 35 0 0 67 30 84 129 54 34 2 129 70 64 3 1 54 46 0 129 52 92 0 0 54 77 1 129 44 13 0 1 70 30 1 0 32 30 3 0 54 75 0 129 54 35 5 129 70 64 2 1 32 23 0 1 44 51 0 1 32 71 0 0 32 100 1 1 56 46 0 0 54 35 4 129 33 30 1 0 67 65 1 129 33 64 1 0 32 30 4 0 44 30 41 1 55 28 4 1 32 32 2 1 56 19 0 0 32 28 1 0 79 64 1 0 46 64 4 1 44 28 1 1 35 18 0 1 32 71 1 0 83 71 1 0 32 47 0 1 70 64 5 1 55 29 1 1 70 64 4 1 35 30 1 0 121 51 0 1 102 30 37 129 67 19 0 129 32 65 1 0 67 30 130 129 35 30 0 0 32 34 0 0 36 54 0 128 35 30 2 0 67 65 2 129 68 32 2 129 70 64 6 1 45 50 0 1 44 5 0 1 68 35 1 129 54 34 3 129 46 30 2 0 55 29 0 1 45 39 0 0 79 28 1 1 68 91 0 129 46 24 0 1 70 64 1 1 68 32 3 129 72 30 0 0 46 131 0 1 52 108 0 0 54 32 4 129 102 34 1 129 52 94 0 0 47 64 1 0 68 91 1 129 36 54 3 128 52 65 0 0 39 51 0 1 67 65 3 129 21 101 0 0 52 46 0 0 69 51 0 129 44 17 0 1 32 19 0 1 54 77 2 129]
    ]

    CompiledCode class >> new: numBytecodes header: anInteger numLiterals: numLiterals [
	"Answer a new instance of the receiver with room for the given
	 number of bytecodes and the given header"

	<category: 'instance creation'>
	^self 
	    new: numBytecodes
	    header: anInteger
	    literals: (Array new: numLiterals)
    ]

    CompiledCode class >> new: numBytecodes header: anInteger literals: literals [
	"Answer a new instance of the receiver with room for the given
	 number of bytecodes and the given header"

	<category: 'instance creation'>
	anInteger isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: anInteger mustBe: Integer].
	^(self new: numBytecodes)
	    initialize;
	    header: anInteger literals: literals
    ]

    CompiledCode class >> flushTranslatorCache [
	"Answer any kind of cache mantained by a just-in-time code translator
	 in the virtual machine (if any).  Do nothing for now."

	<category: 'cache flushing'>
	
    ]

    methodCategory [
	"Answer the method category"

	<category: 'basic'>
	self subclassResponsibility
    ]

    methodCategory: aCategory [
	"Set the method category to the given string"

	<category: 'basic'>
	self subclassResponsibility
    ]

    methodSourceCode [
	"Answer the method source code (a FileSegment or String or nil)"

	<category: 'basic'>
	self subclassResponsibility
    ]

    methodSourceString [
	"Answer the method source code as a string"

	<category: 'basic'>
	self subclassResponsibility
    ]

    methodSourceFile [
	"Answer the file where the method source code is stored"

	<category: 'basic'>
	self subclassResponsibility
    ]

    methodSourcePos [
	"Answer the location where the method source code is stored in
	 the methodSourceFile"

	<category: 'basic'>
	self subclassResponsibility
    ]

    = aMethod [
	"Answer whether the receiver is the same object as arg.  Testing
         for equality could break the browser, since it's possible to put
         arbitrary objects via ##(...), so this is safer."

	<category: 'basic'>
	<primitive: VMpr_Object_identity>
	
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'basic'>
	| hashValue |
	hashValue := header hash bitAnd: 536870911
		    + (literals size hash bitAnd: 536870911).
	1 to: self basicSize
	    do: 
		[:i | 
		hashValue := ((hashValue bitShift: 1) bitAnd: 536870911) 
			    + (self basicAt: i)].
	^hashValue
    ]

    allLiteralSymbolsDo: aBlock [
	"As with #allLiteralsDo:, but only call aBlock with found Symbols."
	<category: 'literals - iteration'>
	literals isNil ifTrue: [^self].
	self traverseLiteral: literals
	    with: [:each | each isSymbol ifTrue: [aBlock value: each]]
    ]

    allLiteralsDo: aBlock [
	"Walk my literals, descending into Arrays and Messages,
	 invoking aBlock with each touched object."
	<category: 'literals - iteration'>
	literals isNil ifTrue: [^self].
	self traverseLiteral: literals with: aBlock
    ]

    traverseLiteral: anArray with: aBlock [
	<category: 'private-literals - iteration'>
	anArray do: 
		[:each | 
		aBlock value: each.
		each class == Array ifTrue: [self traverseLiteral: each with: aBlock].
		each class == Message 
		    ifTrue: 
			[aBlock value: each selector.
			self traverseLiteral: each arguments with: aBlock]]
    ]

    literalsDo: aBlock [
	"Invoke aBlock with each object immediately in my list of literals."
	<category: 'literals - iteration'>
	literals isNil ifTrue: [^self].
	literals do: aBlock
    ]

    at: anIndex put: aBytecode [
	"Store aBytecode as the anIndex-th bytecode"

	<category: 'accessing'>
	self basicAt: anIndex put: aBytecode.
	CompiledMethod flushTranslatorCache.
	^aBytecode
    ]

    blockAt: anIndex [
	"Answer the CompiledBlock attached to the anIndex-th literal,
	 assuming that the literal is a CompiledBlock or a BlockClosure."

	<category: 'accessing'>
	| lit |
	lit := literals at: anIndex.
	lit class == BlockClosure ifTrue: [lit := lit block].
	^lit
    ]

    methodClass [
	"Answer the class in which the receiver is installed."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    methodClass: methodClass [
	"Set the receiver's class instance variable"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    selector: aSymbol [
	"Set the selector through which the method is called"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    selector [
	"Answer the selector through which the method is called"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    isAnnotated [
	<category: 'accessing'>
	^false
    ]

    literals [
	"Answer the literals referenced by my code or any CompiledCode
	 instances I own."
	<category: 'accessing'>
	^literals isNil ifTrue: [#()] ifFalse: [literals]
    ]

    literalAt: anIndex [
	"Answer the anIndex-th literal"

	<category: 'accessing'>
	^literals at: anIndex
    ]

    literalAt: anInteger put: aValue [
	"Store aValue as the anIndex-th literal"

	<category: 'accessing'>
	^literals at: anInteger put: aValue
    ]

    bytecodeAt: anIndex [
	"Answer the anIndex-th bytecode"

	<category: 'accessing'>
	^self basicAt: anIndex + self bytecodeStart
    ]

    bytecodeAt: anIndex put: aBytecode [
	"Store aBytecode as the anIndex-th bytecode"

	<category: 'accessing'>
	self basicAt: anIndex + self bytecodeStart put: aBytecode.
	CompiledMethod flushTranslatorCache.
	^aBytecode
    ]

    flags [
	"Private - Answer the optimization flags for the receiver"

	<category: 'accessing'>
	^0
    ]

    primitive [
	"Answer the primitive called by the receiver"

	<category: 'accessing'>
	^0
    ]

    numArgs [
	"Answer the number of arguments for the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    numTemps [
	"Answer the number of temporaries for the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    stackDepth [
	"Answer the number of stack slots needed for the receiver"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    method [
	"Answer the parent method for the receiver, or self if it is a method."

	<category: 'accessing'>
	^self
    ]

    numLiterals [
	"Answer the number of literals for the receiver"

	<category: 'accessing'>
	^literals size
    ]

    deepCopy [
	"Answer a deep copy of the receiver"

	<category: 'copying'>
	^self shallowCopy postCopy
    ]

    examineOn: aStream [
	"Print the contents of the receiver in a verbose way."

	<category: 'debugging'>
	| instVars lit object output |
	instVars := self class allInstVarNames.
	aStream
	    nextPutAll: 'An instance of ';
	    print: self class;
	    nl.
	2 to: instVars size
	    do: 
		[:i | 
		object := self instVarAt: i.
		output := [object printString] on: Error
			    do: 
				[:ex | 
				ex 
				    return: '%1 %2' % 
						{object class article.
						object class name asString}].
		aStream
		    nextPutAll: '  ';
		    nextPutAll: (instVars at: i);
		    nextPutAll: ': ';
		    nextPutAll: output;
		    nl.
		i = 2 ifTrue: [self printHeaderOn: aStream]].
	self numLiterals > 0 
	    ifTrue: 
		[aStream
		    nextPutAll: '  literals: [';
		    nl.
		1 to: self numLiterals
		    do: 
			[:i | 
			self bytecodeIndex: i with: aStream.
			aStream tab.
			lit := self literalAt: i.
			aStream print: lit; nl].
		aStream
		    nextPutAll: '  ]';
		    nl].
	self numBytecodes > 0 
	    ifTrue: 
		[aStream
		    nextPutAll: '  byte codes: [';
		    nl.
		self printByteCodesOn: aStream.
		aStream
		    nextPutAll: '  ]';
		    nl]
    ]

    containsLiteral: anObject [
	"Answer if the receiver contains a literal which is equal to anObject."

	<category: 'testing accesses'>
	self allLiteralsDo: [:lit | lit = anObject ifTrue: [^true]].
	^false
    ]

    refersTo: anObject [
	"Answer whether the receiver refers to the given object"

	<category: 'testing accesses'>
	| byte |
	(self containsLiteral: anObject) ifTrue: [^true].
	anObject isSymbol ifFalse: [^false].

	"Look for symbols referenced to by special message sends"
	byte := self class specialSelectors indexOf: anObject.
	byte = 0 ifTrue: [^false].
	byte := byte - 1.
	self allByteCodeIndicesDo: 
		[:i :bytecode :operand | 
		(byte <= 26 and: [byte = bytecode]) ifTrue: [^true].
		((byte bitAnd: 254) = 30 and: [byte = operand]) ifTrue: [^true]].
	^false
    ]

    hasBytecode: byte between: firstIndex and: lastIndex [
	"Answer whether the receiver includes the `byte' bytecode in any
	 of the indices between firstIndex and lastIndex."

	<category: 'testing accesses'>
	self allByteCodeIndicesDo: 
		[:i :bytecode :operand | 
		i > lastIndex ifTrue: [^false].
		(i >= firstIndex and: [byte = bytecode]) ifTrue: [^true]].
	^false
    ]

    sourceCodeLinesDelta [
	"Answer the delta from the numbers in LINE_NUMBER bytecodes
	 to source code line numbers."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    sourceCodeMap [
	"Answer an array which maps bytecode indices to source code
	 line numbers.  0 values represent invalid instruction
	 pointer indices."

	<category: 'testing accesses'>
	| map line first |
	map := ByteArray new: self size.
	line := 1.
	first := true.
	self allByteCodeIndicesDo: 
		[:each :byte :operand | 
		(self class bytecodeInfoTable at: byte * 4 + 4) >= 128 
		    ifTrue: 
			[first ifFalse: [line := operand].
			first := false.
			operand > 255 ifTrue: [map := map asArray]].
		map at: each put: line].
	^map
    ]

    jumpDestinationAt: anIndex forward: aBoolean [
	"Answer where the jump at bytecode index `anIndex' lands"

	<category: 'testing accesses'>
	| result ofs byte |
	ofs := anIndex.
	[anIndex > 2 and: [(self bytecodeAt: ofs - 2) = 55]] 
	    whileTrue: [ofs := ofs - 2].
	result := 0.
	
	[result := result * 256 + (self bytecodeAt: ofs + 1).
	byte := self bytecodeAt: ofs.
	ofs := ofs + 2.
	byte = 55] 
		whileTrue.
	^aBoolean ifFalse: [ofs - result] ifTrue: [ofs + result]
    ]

    sendsToSuper [
	"Answer whether the receiver includes a send to super."

	<category: 'testing accesses'>
	self allByteCodeIndicesDo: 
		[:i :byte :operand | 
		(byte = 29 or: [ byte = 31 ]) ifTrue: [^true]].
	^false
    ]

    reads: instVarIndex [
	"Answer whether the receiver reads the instance variable with the given
	 index"

	<category: 'testing accesses'>
	self flags = 2 
	    ifTrue: [^((header bitShift: -6) bitAnd: 31) = instVarIndex].
	self allByteCodeIndicesDo: 
		[:i :byte :operand | 
		(byte = 35 and: [operand = instVarIndex]) ifTrue: [^true]].
	^false
    ]

    assigns: instVarIndex [
	"Answer whether the receiver writes to the instance variable with the given
	 index"

	<category: 'testing accesses'>
	self allByteCodeIndicesDo: 
		[:i :byte :operand | 
		(byte = 39 and: [operand = instVarIndex]) ifTrue: [^true]].
	^false
    ]

    accesses: instVarIndex [
	"Answer whether the receiver accesses the instance variable with the given
	 index"

	<category: 'testing accesses'>
	| byte nextByte |
	self flags = 2 
	    ifTrue: [^((header bitShift: -6) bitAnd: 31) = instVarIndex].
	self allByteCodeIndicesDo: 
		[:i :byte :operand | 
		((byte = 35 or: [byte = 39]) and: [operand = instVarIndex]) 
		    ifTrue: [^true]].
	^false
    ]

    dispatchTo: anObject with: param [
	"Disassemble the bytecodes and tell anObject about them in the form
	 of message sends.  param is given as an argument to every message
	 send."

	<category: 'decoding bytecodes'>
	| lastOfs |
	self allByteCodeIndicesDo: 
		[:i :byte :arg | 
		lastOfs = i 
		    ifFalse: 
			[anObject bytecodeIndex: i with: param.
			lastOfs := i].
		self 
		    dispatchByte: byte
		    with: arg
		    at: i
		    to: anObject
		    with: param]
    ]

    dispatchByte: byte with: operand at: anIndex to: anObject with: param [
	"Private - Print the byte bytecode (starting at anIndex) on param"

	<category: 'private-decoding bytecodes'>
	byte <= 26 
	    ifTrue: 
		[^self 
		    dispatchSend: 30
		    with: byte
		    to: anObject
		    with: param].
	byte < 32 
	    ifTrue: 
		[^self 
		    dispatchSend: byte
		    with: operand
		    to: anObject
		    with: param].
	byte < 40 
	    ifTrue: 
		[^self 
		    dispatchVariableOp: byte
		    with: operand
		    to: anObject
		    with: param].
	byte < 44 
	    ifTrue: 
		[^self 
		    dispatchJump: byte
		    at: anIndex
		    to: anObject
		    with: param].
	byte < 48 
	    ifTrue: 
		[^self 
		    dispatchOtherStack: byte
		    with: operand
		    to: anObject
		    with: param].
	byte < 54 
	    ifTrue: 
		[^self 
		    dispatchOneByte: byte
		    to: anObject
		    with: param].
	byte = 54 ifTrue: [^anObject lineNo: operand with: param].
	byte = 56 ifTrue: [^anObject pushSelf: param].
	^anObject invalidOpcode: param
    ]

    dispatchSuperoperator: byte with: operand at: ofs to: aBlock [
	"Private - Split the superoperator and call back to aBlock for
	 the two components (recursive calls are possible to several
	 levels)."

	<category: 'private-decoding bytecodes'>
	| index bc1 bc2 arg1 arg2 arg kind |
	index := byte * 4.
	bc1 := self class bytecodeInfoTable at: index + 1.
	bc2 := self class bytecodeInfoTable at: index + 2.
	arg := self class bytecodeInfoTable at: index + 3.
	kind := self class bytecodeInfoTable at: index + 4.
	kind \\ 2 = 0 
	    ifTrue: 
		[arg1 := arg.
		arg2 := operand]
	    ifFalse: 
		[arg1 := operand.
		arg2 := arg].
	bc1 = 55 
	    ifTrue: [arg2 := arg1 * 256 + arg2]
	    ifFalse: 
		[bc1 < 64 
		    ifTrue: 
			[aBlock 
			    value: ofs
			    value: bc1
			    value: arg1]
		    ifFalse: 
			[self 
			    dispatchSuperoperator: bc1
			    with: arg1
			    at: ofs
			    to: aBlock]].
	bc2 < 64 
	    ifTrue: 
		[aBlock 
		    value: ofs
		    value: bc2
		    value: arg2]
	    ifFalse: 
		[self 
		    dispatchSuperoperator: bc2
		    with: arg2
		    at: ofs
		    to: aBlock]
    ]

    dispatchSend: byte with: operand to: anObject with: param [
	<category: 'private-decoding bytecodes'>
	byte = 28 
	    ifTrue: 
		[^anObject 
		    send: (self literalAt: operand // 256 + 1)
		    numArgs: operand \\ 256
		    with: param].
	byte = 29 
	    ifTrue: 
		[^anObject 
		    superSend: (self literalAt: operand // 256 + 1)
		    numArgs: operand \\ 256
		    with: param].
	byte = 30 
	    ifTrue: 
		[^anObject 
		    send: (self class specialSelectors at: operand + 1)
		    numArgs: (self class specialSelectorsNumArgs at: operand + 1)
		    with: param].
	byte = 31 
	    ifTrue: 
		[^anObject 
		    superSend: (self class specialSelectors at: operand + 1)
		    numArgs: (self class specialSelectorsNumArgs at: operand + 1)
		    with: param].
	^anObject invalidOpcode: param
    ]

    dispatchVariableOp: byte with: operand to: anObject with: param [
	<category: 'private-decoding bytecodes'>
	byte = 32 ifTrue: [^anObject pushTemporary: operand with: param].
	byte = 33 
	    ifTrue: 
		[^anObject 
		    pushTemporary: operand // 256
		    outer: operand \\ 256
		    with: param].
	byte = 34 
	    ifTrue: [^anObject pushGlobal: (self literalAt: operand + 1) with: param].
	byte = 35 ifTrue: [^anObject pushInstVar: operand with: param].
	byte = 36 ifTrue: [^anObject storeTemporary: operand with: param].
	byte = 37 
	    ifTrue: 
		[^anObject 
		    storeTemporary: operand // 256
		    outer: operand \\ 256
		    with: param].
	byte = 38 
	    ifTrue: [^anObject storeGlobal: (self literalAt: operand + 1) with: param].
	byte = 39 ifTrue: [^anObject storeInstVar: operand with: param]
    ]

    dispatchOneByte: byte to: anObject with: param [
	<category: 'private-decoding bytecodes'>
	byte == 48 ifTrue: [^anObject popStackTop: param].
	byte == 49 ifTrue: [^anObject makeDirtyBlock: param].
	byte == 50 ifTrue: [^anObject returnFromMethod: param].
	byte == 51 ifTrue: [^anObject returnFromContext: param].
	byte == 52 ifTrue: [^anObject dupStackTop: param].
	byte == 53 ifTrue: [^anObject exitInterpreter: param]
    ]

    dispatchOtherStack: byte with: operand to: anObject with: param [
	<category: 'private-decoding bytecodes'>
	byte = 44 ifTrue: [^anObject pushLiteral: operand with: param].
	byte = 46 
	    ifTrue: [^anObject pushLiteral: (self literalAt: operand + 1) with: param].
	byte = 47 ifTrue: [^anObject popIntoArray: operand with: param].
	operand = 0 ifTrue: [^anObject pushLiteral: nil with: param].
	operand = 1 ifTrue: [^anObject pushLiteral: true with: param].
	operand = 2 ifTrue: [^anObject pushLiteral: false with: param].
	^anObject invalidOpcode: param
    ]

    dispatchJump: byte at: anIndex to: anObject with: param [
	<category: 'private-decoding bytecodes'>
	| destination |
	destination := self jumpDestinationAt: anIndex forward: byte > 40.
	byte < 42 ifTrue: [^anObject jumpTo: destination with: param].
	byte = 42 ifTrue: [^anObject popJumpIfTrueTo: destination with: param].
	byte = 43 ifTrue: [^anObject popJumpIfFalseTo: destination with: param]
    ]

    printHeaderOn: aStream [
	"Private - Disassemble the method header to aStream"

	<category: 'private-printing'>
	self subclassResponsibility
    ]

    printByteCodesOn: aStream [
	"Private - Disassemble the bytecode instructions to aStream"

	<category: 'private-printing'>
	self dispatchTo: self with: aStream
    ]

    invalidOpcode: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'invalid opcode';
	    nl
    ]

    pushInstVar: anIndex with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'push Instance Variable[%1]' % {anIndex};
	    nl
    ]

    storeInstVar: anIndex with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'store into Instance Variable[%1]' % {anIndex};
	    nl
    ]

    popIntoArray: anIndex with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'pop and store into array element[%1]' % {anIndex};
	    nl
    ]

    pushTemporary: anIndex outer: scopes with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'push Temporary[%1] from outer context #%2' % 
			    {anIndex.
			    scopes};
	    nl
    ]

    storeTemporary: anIndex outer: scopes with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'store into Temporary[%1] from outer context #%2' % 
			    {anIndex.
			    scopes};
	    nl
    ]

    pushTemporary: anIndex with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'push Temporary[%1]' % {anIndex};
	    nl
    ]

    storeTemporary: anIndex with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'store into Temporary[%1]' % {anIndex};
	    nl
    ]

    pushLiteral: anObject with: aStream [
	<category: 'private-printing'>
	| printString |
	printString := anObject printString.
	(anObject isClass not and: [printString size > 30]) 
	    ifTrue: 
		[printString := '%1 %2' % 
				{anObject class article.
				anObject class name asString}].
	aStream
	    tab;
	    nextPutAll: 'push ';
	    nextPutAll: printString;
	    nl
    ]

    pushGlobal: anObject with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'push Global Variable ';
	    print: anObject;
	    nl
    ]

    storeGlobal: anObject with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'store into Global Variable ';
	    print: anObject;
	    nl
    ]

    pushSelf: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'push self';
	    nl
    ]

    popStackTop: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'pop stack top';
	    nl
    ]

    makeDirtyBlock: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'make dirty block';
	    nl
    ]

    lineNo: n with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'source code line number ';
	    print: n;
	    nl
    ]

    dupStackTop: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'dup stack top';
	    nl
    ]

    exitInterpreter: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'exit interpreter';
	    nl
    ]

    returnFromContext: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'return stack top';
	    nl
    ]

    returnFromMethod: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'return from method';
	    nl
    ]

    popJumpIfFalseTo: destination with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'pop and if false jump to ';
	    print: destination;
	    nl
    ]

    popJumpIfTrueTo: destination with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'pop and if true jump to ';
	    print: destination;
	    nl
    ]

    jumpTo: destination with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'jump to ';
	    print: destination;
	    nl
    ]

    superSend: aSymbol numArgs: anInteger with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'send %2 args message %1 to super' % 
			    {aSymbol.
			    anInteger};
	    nl
    ]

    send: aSymbol numArgs: anInteger with: aStream [
	<category: 'private-printing'>
	aStream
	    tab;
	    nextPutAll: 'send %2 args message %1' % 
			    {aSymbol.
			    anInteger};
	    nl
    ]

    bytecodeIndex: byte with: aStream [
	"Private - Print the bytecode index for byte"

	<category: 'private-printing'>
	| s |
	s := byte printString.
	aStream
	    space: 5 - s size;
	    nextPut: $[;
	    nextPutAll: s;
	    nextPut: $]
    ]

    nextBytecodeIndex: anIndex [
	"Private - Answer the index of the bytecode after the one at
	 index `anIndex'"

	<category: 'private'>
	| byte ofs |
	ofs := anIndex.
	
	[byte := self bytecodeAt: ofs.
	ofs := ofs + 2.
	byte = 55] whileTrue.
	^ofs
    ]

    allByteCodeIndicesDo: aBlock [
	"Private - Evaluate aBlock passing each of the index where a
	 new bytecode instruction starts"

	<category: 'private'>
	| numBytes i byte operand ofs |
	i := 1.
	numBytes := self numBytecodes.
	[i <= numBytes] whileTrue: 
		[ofs := i.
		operand := 0.
		
		[byte := self bytecodeAt: i.
		operand := operand * 256 + (self bytecodeAt: i + 1).
		i := i + 2.
		byte = 55] 
			whileTrue.
		byte >= 64 
		    ifTrue: 
			[self 
			    dispatchSuperoperator: byte
			    with: operand
			    at: ofs
			    to: aBlock]
		    ifFalse: 
			[aBlock 
			    value: ofs
			    value: byte
			    value: operand]]
    ]

    bytecodeSizeAt: anIndex [
	"Private - Answer the size of the bytecode instruction starting at anIndex"

	<category: 'private'>
	^(self nextBytecodeIndex: anIndex) - anIndex
    ]

    header: hdr literals: lits [
	<category: 'private'>
	| oldHeader |
	oldHeader := header.
	header := hdr.
	literals := lits.
	oldHeader isNil ifFalse: [Behavior flushCache]
    ]

    initialize [
	"Do nothing"

	<category: 'private'>
	
    ]

    getHeader [
	<category: 'private'>
	^header
    ]

    numBytecodes [
	"Answer the number of bytecodes in the receiver"

	<category: 'private'>
	^self basicSize - self bytecodeStart
    ]

    bytecodeStart [
	"Answer the index where the bytecodes start - 1"

	<category: 'private'>
	^0
    ]

    discardTranslation [
	"Flush the just-in-time translated code for the receiver (if any)."

	<category: 'translation'>
	<primitive: VMpr_CompiledCode_discardTranslation>
	
    ]

    verificationResult [
	"Answer the result of verifying the bytecodes for the receiver."

	<category: 'private'>
	<primitive: VMpr_CompiledCode_verificationResult>
	
    ]

    verify [
	"Verify the bytecodes for the receiver, and raise an exception if
	 the verification process failed."

	<category: 'security'>
	| result |
	result := self verificationResult.
	result isNil ifFalse: [SystemExceptions.VerificationError signal: result]
    ]
]

