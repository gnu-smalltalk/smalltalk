"======================================================================
|
|   CompiledMethod Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
| Free Software Foundation, Inc.
| Written by Steve Byrne.
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



CompiledCode variableByteSubclass: #CompiledMethod
       instanceVariableNames: 'descriptor '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

CompiledMethod comment:
'I represent methods that have been compiled.  I can recompile
methods from their source code, I can invoke Emacs to edit the source code
for one of my instances, and I know how to access components of my
instances.' !


!CompiledMethod class methodsFor: 'lean images'!

stripSourceCode
    "Remove all the references to method source code from the system"
    self allInstancesDo: [ :each | each stripSourceCode ]
! !


!CompiledMethod methodsFor: 'basic'!

methodCategory
    "Answer the method category"
    ^descriptor category
!

methodCategory: aCategory
    "Set the method category to the given string"
    descriptor category: aCategory
!

methodSourceCode
    "Answer the method source code (a FileSegment or String or nil)"
    ^(descriptor sourceCode isNil or: [ descriptor sourceFile = 'stdin' ])
	ifTrue: [ nil]
	ifFalse: [ descriptor sourceCode ]
!

methodSourceString
    "Answer the method source code as a string"
    ^(descriptor sourceCode isNil or: [ descriptor sourceFile = 'stdin' ])
	ifTrue: [ nil]
	ifFalse: [ descriptor sourceString ]
!

methodSourceFile
    "Answer the file where the method source code is stored"
    ^(descriptor sourceCode isNil or: [ descriptor sourceFile = 'stdin' ])
	ifTrue: [ nil]
	ifFalse: [ descriptor sourceFile ]
!

methodSourcePos
    "Answer the location where the method source code is stored in
     the methodSourceFile"
    ^(descriptor sourceCode isNil or: [ descriptor sourceFile = 'stdin' ])
	ifTrue: [ nil]
	ifFalse: [ descriptor sourcePos ]
!

= aMethod
    "Answer whether the receiver and aMethod are equal"

    self == aMethod ifTrue: [ ^true ].
    ^super = aMethod and: [
	descriptor = aMethod getDescriptor ]
!

hash
    "Answer an hash value for the receiver"

    ^super hash bitXor: descriptor hash
! !



!CompiledMethod methodsFor: 'accessing'!

methodClass
    "Answer the class in which the receiver is installed."
    ^descriptor methodClass
!

methodClass: methodClass
    "Set the receiver's class instance variable"
    descriptor methodClass: methodClass
!

allBlocksDo: aBlock
    "Evaluate aBlock, passing to it all the CompiledBlocks it holds"
    self allLiterals do: [ :each |
	each class == BlockClosure ifTrue: [
	    aBlock value: each block
	]
    ]
!

withAllBlocksDo: aBlock
    "Evaluate aBlock, passing the receiver and all the CompiledBlocks it
     holds"
    aBlock value: self.
    self allBlocksDo: aBlock
!

withNewMethodClass: class
    "Answer either the receiver or a copy of it, with the method class set
     to class"
    ^self methodClass isNil
	ifTrue: [ self methodClass: class; yourself ]
	ifFalse: [ self deepCopy methodClass: class; yourself ]
!

withNewMethodClass: class selector: selector
    "Answer either the receiver or a copy of it, with the method class set
     to class"
    ^(self withNewMethodClass: class) selector: selector; yourself
!

selector: aSymbol
    "Set the selector through which the method is called"
    descriptor selector: aSymbol.
!

selector
    "Answer the selector through which the method is called"
    ^descriptor selector
!

flags
    "Private - Answer the optimization flags for the receiver"
    ^((header bitShift: -27) bitAnd: 16r7)
!

primitive
    "Answer the primitive called by the receiver"
    ^(header bitShift: -17) bitAnd: 16r3FF
!

allLiterals
    "Answer the literals referred to by the receiver and all the blocks
     in it"

    "We don't use separate literal arrays, so answer literals."
    ^literals isNil ifTrue: [ #() ] ifFalse: [ literals ]
!

numArgs
    "Answer the number of arguments for the receiver"
    ^header bitAnd: 16r1F
!

numTemps
    "Answer the number of temporaries for the receiver"
    ^(header bitShift: -11) bitAnd: 16r3F
!

stackDepth
    "Answer the number of stack slots needed for the receiver"
    ^((header bitShift: -5) bitAnd: 16r3F) * 4
! !



!CompiledMethod methodsFor: 'printing'!

storeOn: aStream
    "Print code to create the receiver on aStream"
    aStream
	nextPutAll: '((';
	print: self class;
	nextPutAll: ' literals: ';
	store: ((1 to: self numLiterals) collect: [ :i | self literalAt: i ]);
	nextPutAll: ' numArgs: ';
	store: self numArgs;
	nextPutAll: ' numTemps: ';
	store: self numTemps;
	nextPutAll: ' primitive: ';
	store: self primitive;
	nextPutAll: ' bytecodes: ';
	store: self asByteArray;
	nextPutAll: ' source: ';
	store: self methodSourceCode;
	nextPutAll: ') makeLiteralsReadOnly; setDescriptor: ';
	store: self getDescriptor;
	nextPutAll: '; yourself)'
! !


!CompiledMethod methodsFor: 'private-printing'!

printHeaderOn: aStream
    "Private - Disassemble the method header to aStream"

    aStream
	nextPutAll: '  Header Flags: ';
	nl;
	nextPutAll: '    flags: ';
	print:      self flags;
	nl;
	nextPutAll: '    primitive index: ';
	print:      self primitive.

    self flags = 4 ifTrue: [
	aStream
	    nextPutAll: ' (';
	    nextPutAll: (VMPrimitives keyAtValue: self primitive ifAbsent: [ 'unknown' ]);
	    nextPut:    $)
    ].

    aStream
	nl;
	nextPutAll: '    number of arguments: ';
	print:      self numArgs;
	nl;
	nextPutAll: '    number of temporaries: ';
	print:      self numTemps;
	nl;
	nextPutAll: '    number of literals: ';
	print:      self numLiterals;
	nl;
	nextPutAll: '    needed stack slots: ';
	print:      self stackDepth;
	nl
! !


!CompiledMethod methodsFor: 'printing'!

printOn: aStream
    "Print the receiver's class and selector on aStream"

    descriptor isNil
	ifTrue: [ ^super printOn: aStream ].

    self methodClass printOn: aStream in: Namespace current.

    aStream
	nextPutAll: '>>#';
	nextPutAll: self selector
! !


!CompiledMethod methodsFor: 'private'!

postCopy
    "Private - Make a deep copy of the descriptor and literals.
     Don't need to replace the method header and bytecodes, since they
     are integers."

    super postCopy.
    descriptor := descriptor copy.
    literals := literals deepCopy.
    self makeLiteralsReadOnly
!

makeLiteralsReadOnly
    ^self makeLiteralsReadOnly: literals
!

makeLiteralsReadOnly: array
    array do: [ :each |
	each class == Array ifTrue: [ self makeLiteralsReadOnly: each ].
	each makeReadOnly: true
    ]
!

initialize
    descriptor := MethodInfo new
!

getDescriptor
    ^descriptor
!

stripSourceCode
    descriptor stripSourceCode
!

header: hdr literals: lits
     "The structure of a method header is as follows (from interp.h)

	3                   2                   1 
      1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |.|.|flg| prim index        | #temps    | depth / 4 | #args   |1|
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

     stackdepth 6 bits 6..11
     temporarycount 6 bits 12..17
     argscount 5 bits 1..5
     primitiveIndex 10 bits 18..27
     flags 2 bits 29..28
     flags 0 -- call the primitive indexed by primIndex or do nothing
     flags 1 -- return self
     flags 2 -- return instance variable in primIndex
     flags 3 -- return first literal"
    header := hdr.
    literals := lits.
    Behavior flushCache
!

numBytecodes
    "Answer the number of bytecodes in the receiver"
    ^(self basicSize) - (self bytecodeStart)
!

bytecodeStart
    "Answer the index where the bytecodes start - 1"
    ^0
! !

!CompiledMethod methodsFor: 'testing'!

reads: instVarIndex
    "Answer whether the receiver or the blocks it contains reads to
     the instance variable with the given index"

    self allBlocksDo: [ :ccode |
	(ccode reads: instVarIndex) ifTrue: [ ^true ].
    ].
    ^super reads: instVarIndex
!

assigns: instVarIndex
    "Answer whether the receiver or the blocks it contains writes to
     the instance variable with the given index"

    self allBlocksDo: [ :ccode |
	(ccode assigns: instVarIndex) ifTrue: [ ^true ].
    ].
    ^super assigns: instVarIndex
!

accesses: instVarIndex
    "Answer whether the receiver or the blocks it contains accesses
     the instance variable with the given index"

    self allBlocksDo: [ :ccode |
	(ccode accesses: instVarIndex) ifTrue: [ ^true ].
    ].
    ^super accesses: instVarIndex
! !

!CompiledMethod methodsFor: 'saving and loading'!

binaryRepresentationObject
    "This method is implemented to allow for a PluggableProxy to be used
     with CompiledMethods.  Answer a DirectedMessage which sends #>>
     to the class object containing the receiver."
    ^DirectedMessage
	selector: #>>
	arguments: (Array with: self selector)
	receiver: self methodClass
! !
