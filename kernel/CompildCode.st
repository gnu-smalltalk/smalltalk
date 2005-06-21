"======================================================================
|
|   CompiledCode Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001, 2002, 2003 Free Software Foundation, Inc.
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



ArrayedCollection variableByteSubclass: #CompiledCode
       instanceVariableNames: 'literals header '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

CompiledCode comment:
'I represent code that has been compiled.  I am an abstract
superclass for blocks and methods' !


!CompiledCode class methodsFor: 'instance creation'!

newMethod: numBytecodes header: anInteger numLiterals: numLiterals
    "Answer a new CompiledMethod with room for the given bytes and the
     given header"
    ^(self new: numBytecodes)
	header: anInteger
	literals: (Array new: numLiterals)
!

newMethod: numBytecodes header: anInteger literals: literals
    "Answer a new CompiledMethod with room for the given bytes and the
     given header"
    ^(self new: numBytecodes)
	header: anInteger
	literals: literals
! !
   

!CompiledCode methodsFor: 'basic'!

methodCategory
    "Answer the method category"
    self subclassResponsibility
!

methodCategory: aCategory
    "Set the method category to the given string"
    self subclassResponsibility
!

methodSourceCode
    "Answer the method source code (a FileSegment or String or nil)"
    self subclassResponsibility
!

methodSourceString
    "Answer the method source code as a string"
    self subclassResponsibility
!

methodSourceFile
    "Answer the file where the method source code is stored"
    self subclassResponsibility
!

methodSourcePos
    "Answer the location where the method source code is stored in
     the methodSourceFile"
    self subclassResponsibility
!

= aMethod
    "Answer whether the receiver and aMethod are equal"

    self == aMethod ifTrue: [ ^true ].
    self class == aMethod class ifFalse: [ ^false ].
    header = aMethod getHeader ifFalse: [ ^false ].
    1 to: self numLiterals do:
    	[ :i |  (self literalAt: i) = (aMethod literalAt: i)
	    	    ifFalse: [ ^false ] ].
    1 to: self numBytecodes do:
    	[ :i | (self bytecodeAt: i) = (aMethod bytecodeAt: i)
	    	    ifFalse: [ ^false ] ].
    ^true
!

hash
    "Answer an hash value for the receiver"

    | hashValue |
    hashValue :=
    	(header hash bitAnd: 16r1FFFFFFF) +
    	(literals hash bitAnd: 16r1FFFFFFF).

    1 to: self basicSize do:
    	[ :i | hashValue := ((hashValue bitShift: 1) bitAnd: 16r1FFFFFFF) +
    	    	    	    (self basicAt: i) ].
    ^hashValue
! !



!CompiledCode methodsFor: 'accessing'!

at: anIndex put: aBytecode
    "Store aBytecode as the anIndex-th bytecode"
    self basicAt: anIndex put: aBytecode.
    CompiledMethod flushTranslatorCache.
    ^aBytecode
!

blockAt: anIndex
    "Answer the CompiledBlock attached to the anIndex-th literal,
     assuming that the literal is a BlockClosure."
    ^(literals at: anIndex) block
!

methodClass
    "Answer the class in which the receiver is installed."
    self subclassResponsibility
!

methodClass: methodClass
    "Set the receiver's class instance variable"
    self subclassResponsibility
!

selector: aSymbol
    "Set the selector through which the method is called"
    self subclassResponsibility
!

selector
    "Answer the selector through which the method is called"
    self subclassResponsibility
!

literals
    ^literals
!

literalAt: anIndex
    "Answer the anIndex-th literal"
    ^literals at: anIndex
!

literalAt: anInteger put: aValue
    "Store aValue as the anIndex-th literal"
    ^literals at: anInteger put: aValue
!

bytecodeAt: anIndex
    "Answer the anIndex-th bytecode"
    ^self basicAt: (anIndex + self bytecodeStart)
!

bytecodeAt: anIndex put: aBytecode
    "Store aBytecode as the anIndex-th bytecode"
    self basicAt: (anIndex + self bytecodeStart) put: aBytecode.
    CompiledMethod flushTranslatorCache.
    ^aBytecode
!

flags
    "Private - Answer the optimization flags for the receiver"
    ^0
!

primitive
    "Answer the primitive called by the receiver"
    ^0
!

numArgs
    "Answer the number of arguments for the receiver"
    self subclassResponsibility
!

numTemps
    "Answer the number of temporaries for the receiver"
    self subclassResponsibility
!

stackDepth
    "Answer the number of stack slots needed for the receiver"
    self subclassResponsibility
!

numLiterals
    "Answer the number of literals for the receiver"
    ^literals size
! !



!CompiledCode methodsFor: 'copying'!

deepCopy
    "Answer a deep copy of the receiver"
    ^self shallowCopy postCopy
! !



!CompiledCode methodsFor: 'debugging'!

inspect
    "Print the contents of the receiver in a verbose way."

    | class instVars lit |
    class := self class.
    instVars := class allInstVarNames.
    Transcript
	nextPutAll: 'An instance of ';
	print: class;
	nl.

    2 to: instVars size do: [ :i | 
    	Transcript
    	    nextPutAll: '  ';
    	    nextPutAll: (instVars at: i);
    	    nextPutAll: ': ';
    	    print: (self instVarAt: i);
    	    nl.
				   
	i = 2 ifTrue: [ self printHeaderOn: Transcript ].
    ].
    

    self numLiterals > 0
    	ifTrue: [ Transcript nextPutAll: '  literals: ['; nl.
		  1 to: self numLiterals do:
		      [ :i | Transcript
				 nextPutAll: '    [';
				 print: (i - 1);
				 nextPutAll: ']: '.

			     lit := self literalAt: i.
			     lit printNl.
		      ].
		  Transcript nextPutAll: '  ]'; nl ].
    Transcript nextPutAll: '  byte codes: ['; nl.
    self printByteCodesOn: Transcript.
    Transcript nextPutAll: '  ]'; nl.
! !



!CompiledCode methodsFor: 'testing accesses'!

containsLiteral: anObject
    "Answer if the receiver contains a literal which is equal to anObject."
    | lit |
    1 to: self numLiterals do: [ :i |
	lit := self literalAt: i.
	lit = anObject ifTrue: [^true ].
    ].
    ^false
!

refersTo: anObject
    "Answer whether the receiver refers to the given object"
    | byte |
    (self containsLiteral: anObject) ifTrue: [ ^true ].

    "Look for symbols referenced to by special message sends"
    byte := #(#+    	 #-   	    #<		#>
	     #<=     	 #>=  	    #=		#~=
	     #*	    	 #/   	    #\\		#@
	     #bitShift:	 #//  	    #bitAnd:	#bitOr:
	     #at:    	 #at:put:   #size	#next
	     #nextPut:	 #atEnd	    #==		#class
	     #blockCopy: #value	    #value:	#do:
	     #new	 #new:	    #isNil	#notNil)

	indexOf: anObject ifAbsent: [ ^false ].

    byte := byte + 175.
    self allByteCodeIndicesDo: [ :i :bytecode |
	byte = bytecode ifTrue: [^true].
    ].
    ^false
!

hasBytecode: byte between: firstIndex and: lastIndex
    "Answer whether the receiver includes the `byte' bytecode in any
     of the indices between firstIndex and lastIndex."
    self allByteCodeIndicesDo: [ :i :bytecode |
	i > lastIndex ifTrue: [ ^false ].
	(i >= firstIndex and: [ byte = bytecode ])
	    ifTrue: [^true].
    ].
    ^false
!

sourceCodeMap
    "Answer an array which maps bytecode indices to source code
     line numbers.  0 values represent invalid instruction
     pointer indices."

    | map line |
    map := ByteArray new: self size.
    line := 1.
    self allByteCodeIndicesDo: [ :each :byte |
        byte = 127 ifTrue: [
            line := (self bytecodeAt: each + 1) * 256 +
                    (self bytecodeAt: each + 2).

            line > 255 ifTrue: [ map := map asArray ]
        ].

        map at: each put: line
    ].

    ^map!

jumpDestinationAt: anIndex
    "Answer where the jump at bytecode index `anIndex' lands"
    | byte ofs |
    byte := self bytecodeAt: anIndex.
    ofs := anIndex + 2.
    byte <= 159 ifTrue: [ ^(byte bitAnd: 7) + ofs].

    ofs := (byte bitAnd: 3) * 256 + ofs.
    byte <= 163 ifTrue: [ ofs := ofs - 1024 ].

    ^(self bytecodeAt: anIndex + 1) + ofs
!

reads: instVarIndex
    "Answer whether the receiver reads the instance variable with the given
     index"

    | byte nextByte |
    self flags = 2
	ifTrue: [ ^((header bitShift: -6) bitAnd: 16r1F) = instVarIndex].

    instVarIndex >= 64 ifTrue: [
        self allByteCodeIndicesDo: [ :i :byte |
	    (byte = 134 and: [
		((self byteCodeAt: i + 1) between: 64 and: 127) and: [
		(self byteCodeAt: i + 1) - 64 = (instVarIndex // 256) and: [
		(self byteCodeAt: i + 2) = (instVarIndex \\ 256) ]]])
		    ifTrue: [ ^true ].

	].
	^false
    ].

    self allByteCodeIndicesDo: [ :i :byte |
	(byte < 16) & (byte = instVarIndex) ifTrue: [^true].   "push"

	(#[128 142] includes: byte) ifTrue: [ "2 byte stack operation"
	    (self bytecodeAt: i + 1) = instVarIndex ifTrue: [^true]
	]
    ].
    ^false
!

assigns: instVarIndex
    "Answer whether the receiver writes to the instance variable with the given
     index"

    | byte nextByte |
    self flags = 2
	ifTrue: [ ^((header bitShift: -6) bitAnd: 16r1F) = instVarIndex].

    instVarIndex >= 64 ifTrue: [
        self allByteCodeIndicesDo: [ :i :byte |
	    (byte = 134 and: [
		((self byteCodeAt: i + 1) >= 128) and: [
		(self byteCodeAt: i + 1) \\ 64 = (instVarIndex // 256) and: [
		(self byteCodeAt: i + 2) = (instVarIndex \\ 256) ]]])
		    ifTrue: [ ^true ].

	].
	^false
    ].

    self allByteCodeIndicesDo: [ :i :byte |
	(byte >= 96) & (byte < 104) & (byte - 96 = instVarIndex)
	    ifTrue: [^true].    "pop"
	    
	(#[129 130] includes: byte) ifTrue: [ "2 byte stack operation"
	    "This deserves an explanation. The correct test would be
	     (nextByte < 64) & ((nextByte bitAnd: 63) = instVarIndex,
	     but: a) if the next byte is < 64 the bitwise and has no effect;
	     b) instVarIndex must be < 64, so the next byte must be < 64 too
	     for it to be equal to instVarIndex... OUCH!!"

	    (self bytecodeAt: i + 1) = instVarIndex ifTrue: [^true]
	]
    ].
    ^false
!

accesses: instVarIndex
    "Answer whether the receiver accesses the instance variable with the given
     index"

    | byte nextByte |
    self flags = 2
	ifTrue: [ ^((header bitShift: -6) bitAnd: 16r1F) = instVarIndex].

    instVarIndex >= 64 ifTrue: [
        self allByteCodeIndicesDo: [ :i :byte |
	    (byte = 134 and: [
		(self byteCodeAt: i + 1) >= 64 and: [
		(self byteCodeAt: i + 1) \\ 64 = (instVarIndex // 256) and: [
		(self byteCodeAt: i + 2) = (instVarIndex \\ 256) ]]])
		    ifTrue: [ ^true ].

	].
	^false
    ].

    self allByteCodeIndicesDo: [ :i :byte |
	(byte < 16) & (byte = instVarIndex) ifTrue: [^true].   "push"

	(byte >= 96) & (byte < 104) & (byte - 96 = instVarIndex)
	    ifTrue: [^true].    "pop"
	    
	(#[128 129 130 142] includes: byte) ifTrue: [ "2 byte stack operation"
	    "This deserves an explanation. The correct test would be
	     (nextByte < 64) & ((nextByte bitAnd: 63) = instVarIndex,
	     but: a) if the next byte is < 64 the bitwise and has no effect;
	     b) instVarIndex must be < 64, so the next byte must be < 64 too
	     for it to be equal to instVarIndex... OUCH!!"

	    (self bytecodeAt: i + 1) = instVarIndex ifTrue: [^true]
	]
    ].
    ^false
! !

!CompiledCode methodsFor: 'decoding bytecodes'!

dispatchTo: anObject with: param
    "Disassemble the bytecodes and tell anObject about them in the form
     of message sends.  param is given as an argument to every message
     send."
    self allByteCodeIndicesDo: [ :i :byte |
	anObject bytecodeIndex: i with: param.
	self dispatchByte: byte at: i to: anObject with: param
    ]
! !

!CompiledCode methodsFor: 'private-decoding bytecodes'!

arithmeticSelectors
    ^#(#+	    	#-   	    #<	    	#>
       #<=     		#>=  	    #=	    	#~=
       #*	    	#/   	    #\\	    	#@
       #bitShift:	#//  	    #bitAnd: 	#bitOr:)!

specialSelectors
    ^#(#at:	    	#at:put:    #size    	#next
       #nextPut:	#atEnd	    #==	    	#class
       #blockCopy:	#value	    #value:     #do:
       #new		#new:       #isNil      #notNil)!

specialSelectorsNumArgs
    ^#(1 2 0 0     1 0 1 0     1 0 1 1     0 1 0 0)!

dispatchByte: byte at: anIndex to: anObject with: param
    "Private - Print the byte bytecode (starting at anIndex) on param"

    byte < 95 ifTrue:
	[ ^self dispatchIndexedAt: anIndex to: anObject with: param ].
    (byte between: 96 and: 111) ifTrue:
	[ ^self dispatchSimplePop: byte to: anObject with: param ].
    byte == 116 ifTrue:
	[ ^self dispatch8BitPushAt: anIndex + 1 max: 127 to: anObject with: param ].
    byte == 117 ifTrue:
	[ ^self dispatch8BitPushAt: anIndex + 1 max: 255 to: anObject with: param ].
    (byte between: 112 and: 125) ifTrue: 
	[ ^self dispatchBuiltin: byte to: anObject with: param ].
    byte == 126 ifTrue: 
	[ ^self dispatch3ByteOp:
    		#(#pushLiteral:with: #pushGlobal:with: #storeGlobal:with: #popStoreGlobal:with:)
		deref: true at: anIndex + 1 to: anObject with: param ].
    byte == 127 ifTrue: 
	[ ^self dispatchLineNoBytecodeAt: anIndex + 1 to: anObject with: param ].
    byte == 128 ifTrue: 
	[ ^self dispatch2ByteStackOp: 
		#(#pushInstVar:with: #pushTemporary:with: #pushLiteral:with: #pushGlobal:with:)
		at: anIndex to: anObject with: param ].
    byte == 129 ifTrue: 
	[ ^self dispatch2ByteStoreOp: 
		#(#storeInstVar:with: #storeTemporary:with: nil #storeGlobal:with:)
		at: anIndex to: anObject with: param ].
    byte == 130 ifTrue: 
	[ ^self dispatch2ByteStoreOp: 
		#(#popStoreInstVar:with: #popStoreTemporary:with: nil #popStoreGlobal:with:)
		at: anIndex to: anObject with: param ].
    (byte between: 131 and: 133) ifTrue: 
	[ ^self dispatchIndexedSend: anIndex to: anObject with: param ].
    byte == 134 ifTrue:
	[ ^self dispatch3ByteOp:
    		#(#popIntoArray:with: #pushInstVar:with:
		#storeInstVar:with: #popStoreInstVar:with:)
		deref: false at: anIndex + 1 to: anObject with: param ].
    byte == 135 ifTrue:
	[ ^anObject popStackTop: param ].
    byte == 136 ifTrue:
	[ ^anObject dupStackTop: param ].
    byte == 137 ifTrue: 
	[ ^anObject pushThisContext: param ].
    byte == 138 ifTrue: 
	[ ^self dispatchOuterStackOp: anIndex + 1 to: anObject with: param ].
    byte == 139 ifTrue: 
	[ ^anObject noOperation: param ].
    byte == 140 ifTrue: 
	[ ^anObject setTopSelf: param ].
    byte == 141 ifTrue: 
	[ ^anObject setTopLiteral: 1 with: param ].
    byte == 142 ifTrue: 
	[ ^self dispatch2ByteStackOp: 
		#(#setTopInstVar:with: #setTopTemporary:with:
		  #setTopLiteral:with: #setTopGlobal:with:)
		at: anIndex to: anObject with: param ].
    byte == 143 ifTrue:
	[ ^anObject exitInterpreter: param ].
    (byte between: 144 and: 175) ifTrue:
	[ ^self dispatchJump: anIndex to: anObject with: param ].
    (byte between: 176 and: 191) ifTrue:
	[ ^anObject send: (self arithmeticSelectors at: byte - 175)
	           numArgs: 1 with: param ].
    (byte between: 192 and: 207) ifTrue:
	[ ^anObject send: (self specialSelectors at: byte - 191)
	           numArgs: (self specialSelectorsNumArgs at: byte - 191)
		   with: param ].
    (byte between: 208 and: 255) ifTrue:
	[ ^self dispatchSmallArgSend: byte to: anObject with: param ].
!	

dispatchIndexedAt: anIndex to: anObject with: param
    "Private - Print the push bytecode starting at anIndex on param,
     byte<=95"

    | byte index |
    byte := self bytecodeAt: anIndex.
    byte <= 15 ifTrue:
    	[ ^anObject pushInstVar: (byte bitAnd: 15) with: param ].
    byte <= 31 ifTrue:
	[ ^anObject pushTemporary: (byte bitAnd: 15) with: param ].
    byte <= 63 ifTrue:
	[ ^anObject pushLiteral: (self literalAt: 1 + (byte bitAnd: 31)) with: param ].

    ^anObject pushGlobal: (self literalAt: 1 + (byte bitAnd: 31)) with: param
!

dispatchSimplePop: byte to: anObject with: param
    "Private - Print the byte bytecode (a pop) on param, 96<=byte<=111"
    (byte between: 96 and: 103) ifTrue:
	[ ^anObject popStoreInstVar: (byte bitAnd: 7) with: param ].
    (byte between: 104 and: 111) ifTrue:
	[ ^anObject popStoreTemporary: (byte bitAnd: 7) with: param ].
!

badDispatchBuiltin: byte to: anObject with: param
    "Private - Print the byte bytecode (a special push or a return) on
     param, 112<=byte<=125"
    byte == 112 ifTrue: [ ^anObject pushSelf: param ].
    byte == 113 ifTrue: [ ^anObject pushLiteral: true with: param ].
    byte == 114 ifTrue: [ ^anObject pushLiteral: false with: param ].
    byte == 115 ifTrue: [ ^anObject pushLiteral: nil with: param ].
    byte == 118 ifTrue: [ ^anObject pushLiteral: 0 with: param ].
    byte == 119 ifTrue: [ ^anObject pushLiteral: 1 with: param ].
    byte == 120 ifTrue: [ ^anObject returnSelf: param ].
    byte == 121 ifTrue: [ ^anObject returnLiteral: true with: param ].
    byte == 122 ifTrue: [ ^anObject returnLiteral: false with: param ].
    byte == 123 ifTrue: [ ^anObject returnLiteral: nil with: param ].
    byte == 124 ifTrue: [ ^anObject returnFromMethod: param ].
    byte == 125 ifTrue: [ ^anObject returnFromContext: param ].
!

dispatchBuiltin: byte to: anObject with: param
    "Private - Print the byte bytecode (a special push or a return) on
     param, 112<=byte<=125"
    byte == 112 ifTrue: [ ^anObject pushSelf: param ].
    byte == 113 ifTrue: [ ^anObject pushLiteral: true with: param ].
    byte == 114 ifTrue: [ ^anObject pushLiteral: false with: param ].
    byte == 115 ifTrue: [ ^anObject pushLiteral: nil with: param ].
    byte == 118 ifTrue: [ ^anObject pushLiteral: 0 with: param ].
    byte == 119 ifTrue: [ ^anObject pushLiteral: 1 with: param ].
    byte == 120 ifTrue: [ ^anObject returnSelf: param ].
    byte == 121 ifTrue: [ ^anObject returnLiteral: true with: param ].
    byte == 122 ifTrue: [ ^anObject returnLiteral: false with: param ].
    byte == 123 ifTrue: [ ^anObject returnLiteral: nil with: param ].
    byte == 124 ifTrue: [ ^anObject returnFromMethod: param ].
    ^anObject returnFromContext: param.
!

dispatch8BitPushAt: index max: max to: anObject with: param 
    | num |
    num := self bytecodeAt: index.
    num > max ifTrue: [ num := num - 256 ].
    anObject pushLiteral: num with: param
!

dispatchLineNoBytecodeAt: index to: anObject with: param 
    | num |
    num := self bytecodeAt: index.
    num := num * 256 + (self bytecodeAt: index + 1).
    anObject lineNo: num with: param
!

dispatch3ByteOp: symbols deref: deref at: index to: anObject with: param 
    "Private - Decode the 3-byte push literal bytecode (126) onto param"
    | what arg |
    what := self bytecodeAt: index.
    arg := self bytecodeAt: index + 1.
    arg := what * 256 + arg.
    what := what // 64.
    deref ifTrue: [ arg := self literalAt: 1 + arg ].
    anObject
	perform: (symbols at: what + 1)
	with: arg
	with: param.
!

dispatch2ByteStackOp: symbols at: anIndex to: anObject with: param
    | nextByte arg locIndex |
    nextByte := self bytecodeAt: anIndex + 1.
    locIndex := nextByte bitShift: -6.
    arg := nextByte bitAnd: 63.
    locIndex >= 2 ifTrue: [ arg := self literalAt: 1 + arg ].
    anObject
	perform: (symbols at: locIndex + 1)
	with: arg
	with: param.
!

dispatch2ByteStoreOp: symbols at: anIndex to: anObject with: param
    | nextByte arg locIndex |
    nextByte := self bytecodeAt: anIndex + 1.
    locIndex := nextByte bitShift: -6.
    arg := nextByte bitAnd: 63.
    locIndex = 2 ifTrue: [ ^anObject invalidOpcode: param ].
    locIndex = 3 ifTrue: [ arg := self literalAt: 1 + arg ].
    anObject
	perform: (symbols at: locIndex + 1)
	with: arg
	with: param.
!

dispatchOuterStackOp: anIndex to: anObject with: param
    "Private - Decode the 3-byte outer-temporary bytecode (138) onto param"
    | what num scopes |
    what := self bytecodeAt: anIndex.
    num := what bitAnd: 63.
    what := what // 64.
    scopes := self bytecodeAt: anIndex + 1.

    what == 0 ifTrue: [ ^anObject invalidOpcode: param ].
    what == 1 ifTrue: [ ^anObject pushTemporary: num outer: scopes with: param ].
    what == 2 ifTrue: [ ^anObject popStoreTemporary: num outer: scopes with: param ].
    what == 3 ifTrue: [ ^anObject storeTemporary: num outer: scopes with: param ].
!

dispatchIndexedSend: anIndex to: anObject with: param
    | byte byte1 byte2 index |
    byte := self bytecodeAt: anIndex.
    byte1 := self bytecodeAt: anIndex + 1.
    byte = 132 ifTrue: [
	byte2 := self bytecodeAt: anIndex + 2.
	byte2 := byte2 + (byte1 * 4 bitAnd: 768).
	byte1 := byte1 bitAnd: 63.
	^byte1 > 32
	    ifTrue: [ anObject superSend: (self literalAt: 1 + byte2) numArgs: byte1 - 32 with: param ]
	    ifFalse: [ anObject send: (self literalAt: 1 + byte2) numArgs: byte1 with: param ].
    ].
    index := byte1 bitAnd: 31.
    byte1 := byte1 bitShift: -5.
    byte = 133
	ifTrue: [ anObject superSend: (self literalAt: 1 + index) numArgs: byte1 with: param ]
	ifFalse: [ anObject send: (self literalAt: 1 + index) numArgs: byte1 with: param ].
!


dispatchJump: anIndex to: anObject with: param
    | byte destination |
    byte := self bytecodeAt: anIndex.
    destination := self jumpDestinationAt: anIndex.

    byte <= 151 ifTrue:
	[ ^anObject jumpTo: destination with: param ].
    byte <= 159 ifTrue:
	[ ^anObject popJumpIfFalseTo: destination with: param ].
    byte <= 167 ifTrue:
	[ ^anObject jumpTo: destination with: param ].
    byte <= 171 ifTrue:
	[ ^anObject popJumpIfTrueTo: destination with: param ].
    byte <= 175 ifTrue:
	[ ^anObject popJumpIfFalseTo: destination with: param ].
!

dispatchSmallArgSend: byte to: anObject with: param
    anObject
	send: (self literalAt: 1 + (byte bitAnd: 15))
	numArgs: (byte - 208) // 16
	with: param
! !


!CompiledCode methodsFor: 'private-printing'!

printHeaderOn: aStream
    "Private - Disassemble the method header to aStream"

    self subclassResponsibility
!

printByteCodesOn: aStream
    "Private - Disassemble the bytecode instructions to aStream"

    self dispatchTo: self with: aStream
!

invalidOpcode: aStream
    aStream nextPutAll: 'invalid opcode'; nl!

pushInstVar: anIndex with: aStream
    aStream nextPutAll: ('push Instance Variable[%1]' bindWith: anIndex); nl!

storeInstVar: anIndex with: aStream
    aStream nextPutAll: ('store into Instance Variable[%1]' bindWith: anIndex); nl!

popStoreInstVar: anIndex with: aStream
    aStream nextPutAll: ('pop and store into Instance Variable[%1]' bindWith: anIndex); nl!

popIntoArray: anIndex with: aStream
    aStream nextPutAll: ('pop and store into array element[%1]' bindWith: anIndex); nl!

setTopInstVar: anIndex with: aStream
    aStream nextPutAll: ('set stack top to Instance Variable[%1]' bindWith: anIndex); nl!

pushTemporary: anIndex outer: scopes with: aStream
    aStream nextPutAll: ('push Temporary[%1] from outer context #%2' bindWith: anIndex with: scopes); nl!

storeTemporary: anIndex outer: scopes with: aStream
    aStream nextPutAll: ('store into Temporary[%1] from outer context #%2' bindWith: anIndex with: scopes); nl!

popStoreTemporary: anIndex outer: scopes with: aStream
    aStream nextPutAll: ('pop and store into Temporary[%1] from outer context #%2' bindWith: anIndex with: scopes); nl!

pushTemporary: anIndex with: aStream
    aStream nextPutAll: ('push Temporary[%1]' bindWith: anIndex); nl!

storeTemporary: anIndex with: aStream
    aStream nextPutAll: ('store into Temporary[%1]' bindWith: anIndex); nl!

popStoreTemporary: anIndex with: aStream
    aStream nextPutAll: ('pop and store into Temporary[%1]' bindWith: anIndex); nl!

setTopTemporary: anIndex with: aStream
    aStream nextPutAll: ('set stack top to Temporary[%1]' bindWith: anIndex); nl!

pushLiteral: anObject with: aStream
    | printString |
    printString := anObject printString.
    printString size > 30
	ifTrue: [ printString := '%1 %2' bindWith: anObject class article with: anObject class name asString ].

    aStream nextPutAll: 'push '; nextPutAll: printString; nl!

setTopLiteral: anObject with: aStream
    | printString |
    printString := anObject printString.
    printString size > 30
	ifTrue: [ printString := anObject class article, anObject class name ].

    aStream nextPutAll: 'set stack top to '; nextPutAll: printString; nl!

pushGlobal: anObject with: aStream
    aStream nextPutAll: 'push Global Variable '; print: anObject; nl!

storeGlobal: anObject with: aStream
    aStream nextPutAll: 'store into Global Variable '; print: anObject; nl!

popStoreGlobal: anObject with: aStream
    aStream nextPutAll: 'pop and store into Global Variable '; print: anObject; nl!

setTopGlobal: anObject with: aStream
    aStream nextPutAll: 'set stack top to Global Variable '; print: anObject; nl!

pushSelf: aStream
    aStream nextPutAll: 'push self'; nl!

returnSelf: aStream
    aStream nextPutAll: 'return self'; nl!

setTopSelf: aStream
    aStream nextPutAll: 'set stack top to self'; nl!

pushThisContext: aStream
    aStream nextPutAll: 'push thisContext'; nl!

popStackTop: aStream
    aStream nextPutAll: 'pop stack top'; nl!

lineNo: n with: aStream
    aStream nextPutAll: 'source code line number '; print: n; nl!

dupStackTop: aStream
    aStream nextPutAll: 'dup stack top'; nl!

exitInterpreter: aStream
    aStream nextPutAll: 'exit interpreter'; nl!

noOperation: aStream
    aStream nextPutAll: 'no operation'; nl!

returnLiteral: anObject with: aStream
    aStream nextPutAll: 'return '; print: anObject; nl!

returnFromContext: aStream
    aStream nextPutAll: 'return from context'; nl!

returnFromMethod: aStream
    aStream nextPutAll: 'return from method'; nl!

popJumpIfFalseTo: destination with: aStream
    aStream nextPutAll: 'pop and if false jump to '; print: destination; nl!

popJumpIfTrueTo: destination with: aStream
    aStream nextPutAll: 'pop and if true jump to '; print: destination; nl!

jumpTo: destination with: aStream
    aStream nextPutAll: 'jump to '; print: destination; nl!

superSend: aSymbol numArgs: anInteger with: aStream
    aStream nextPutAll: ('send %2 args message %1 to super' bindWith: aSymbol with: anInteger); nl!

send: aSymbol numArgs: anInteger with: aStream
    aStream nextPutAll: ('send %2 args message %1' bindWith: aSymbol with: anInteger); nl!

bytecodeIndex: byte with: aStream
    "Private - Print the bytecode index for byte"

    aStream
	nextPutAll: '    [';
	print: byte;
	nextPutAll: ']: '.
! !


!CompiledCode methodsFor: 'private'!

postCopy
    "Private - Make a deep copy of the literals.
     Don't need to replace the method header and bytecodes, since they
     are integers."

    super postCopy.
    literals := literals deepCopy.
!

nextByteCodeIndex: byte
    "Private - Answer the index of the bytecode after the one at
     index `byte'"

    ^byte + (self bytecodeSizeAt: byte)
!

allByteCodeIndicesDo: aBlock
    "Private - Evaluate aBlock passing each of the index where a
     new bytecode instruction starts"

    | numBytes i byte |
    i := 1.
    numBytes := self numBytecodes.
    [ i <= numBytes ] whileTrue: [
	byte := self bytecodeAt: i.
	aBlock value: i value: byte.

	i := i + (self bytecodeSizeAt: i)
    ]
!

bytecodeSizeAt: anIndex
    "Private - Answer the size of the bytecode instruction starting at anIndex"

    | byte |
    byte := self bytecodeAt: anIndex.

    byte == 126 ifTrue: [ ^3 ].
    byte == 127 ifTrue: [ ^3 ].
    byte == 116 ifTrue: [ ^2 ].
    byte == 117 ifTrue: [ ^2 ].
    byte < 128 ifTrue: [^1].
    byte > 175 ifTrue: [^1].
    byte == 128 ifTrue: [ ^2].
    byte == 129 ifTrue: [ ^2].
    byte == 130 ifTrue: [ ^2].
    byte < 135 ifTrue: [^(byte - 131) bitOr: 2].   "2 or 3"
    byte == 138 ifTrue: [^3].
    byte == 142 ifTrue: [^2].
    byte < 160 ifTrue: [^1].
    ^2
!

header: hdr literals: lits
    header := hdr.
    literals := lits.
    Behavior flushCache
!

getHeader
    ^header
!

numBytecodes
    "Answer the number of bytecodes in the receiver"
    ^(self basicSize) - (self bytecodeStart)
!

bytecodeStart
    "Answer the index where the bytecodes start - 1"
    ^0
! !
