"======================================================================
|
|   CompiledMethod Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005
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


!CompiledMethod class methodsFor: 'instance creation'!

numArgs: args
    "Create a user-defined method (one that is sent
     #valueWithReceiver:withArguments: when it is invoked)
     with numArgs arguments.  This only makes sense when
     called for a subclass of CompiledMethod."

    args isInteger
    	ifFalse: [ SystemExceptions.WrongClass signalOn: args mustBe: Integer ].

    (args between: 0 and: 31)
    	ifFalse: [ SystemExceptions.ArgumentOutOfRange signalOn: args
			mustBeBetween: 0 and: 31 ].

    ^self new
	initialize;
	header: (6 bitShift: 27) + args literals: #()
! !


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
	descriptor = aMethod descriptor ]
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
	each class == CompiledBlock ifTrue: [
	    aBlock value: each
	].
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



!CompiledMethod methodsFor: 'invoking'!

valueWithReceiver: anObject withArguments: args
    "Execute the method within anObject, passing the elements of the args
     Array as parameters.  The method need not reside on the hierarchy
     from the receiver's class to Object -- it need not reside at all in
     a MethodDictionary, in fact -- but doing bad things will compromise
     stability of the Smalltalk virtual machine (and don't blame anybody
     but yourself).
     
     If the flags field of the method header is 6, this method instead
     provides a hook from which the virtual machine can call back whenever
     execution of the method is requested.  In this case, invoking the
     method would cause an infinite loop (the VM asks the method to
     run, the method asks the VM to invoke it, and so on), so this method
     fails with a #subclassResponsibility error."

    self flags = 6
    	ifTrue: [ self subclassResponsibility ]
    	ifFalse: [ anObject perform: self withArguments: args ]
! !


!CompiledMethod methodsFor: 'attributes'!

isAnnotated
    "If the receiver has any attributes, answer true."
    | flags |
    flags := self flags.
    ^flags == 4 or: [ flags == 5 ]
!

primitiveAttribute
    "If the receiver defines a primitive, return a Message resembling
     the attribute that was used to define it."
    | primitive |
    primitive = 0 ifTrue: [ ^nil ].
    ^Message selector: #primitive: arguments: { primitive }
!

attributes
    "Return an Array of Messages, one for each attribute defined by the
     receiver."
    | attributes numAttr |
    self isAnnotated ifFalse: [ ^#() ].
    numAttr := descriptor size.
    self primitive = 0 ifFalse: [ numAttr := numAttr + 1 ].

    attributes := Array new: numAttr.
    self primitive = 0 ifFalse: [
	attributes at: numAttr put: self primitiveAttribute ].

    1 to: descriptor size do: [ :i |
	attributes at: i put: (descriptor at: i) ].

    ^attributes
!

attributeAt: aSymbol
    "Return a Message for the first attribute named aSymbol defined by the
     receiver, or answer an error if none was found."

    ^self
	attributeAt: aSymbol
	ifAbsent: [ SystemExceptions.NotFound signalOn: aSymbol what: 'attribute' ]
!

attributeAt: aSymbol ifAbsent: aBlock
    "Return a Message for the first attribute named aSymbol defined by the
     receiver, or evaluate aBlock is none was found."
    | primitive attr |
    self isAnnotated ifFalse: [ ^aBlock value ].

    aSymbol == #primitive: ifTrue: [
	primitive := self primitiveAttribute.
	^primitive isNil ifTrue: [ aBlock value ] ifFalse: [ primitive ]
    ].

    1 to: descriptor size do: [ :i |
	attr := descriptor at: i.
	attr selector = aSymbol ifTrue: [ ^attr ]
    ].
    ^aBlock value
!

attributesDo: aBlock
    "Evaluate aBlock once for each attribute defined by the receiver,
     passing a Message each time."

    | attr |
    self isAnnotated ifFalse: [ ^self ].

    self primitive = 0
	ifFalse: [ aBlock value: self primitiveAttribute ].

    1 to: descriptor size do: [ :i || attr |
	attr := descriptor at: i.
	aBlock value: attr
    ]
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
	store: self descriptor;
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
    "literals := literals deepCopy.
    self makeLiteralsReadOnly"
!

makeLiteralsReadOnly
    literals isNil ifTrue: [ ^self ].
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

descriptor
    ^descriptor
!

descriptor: aMethodInfo
    descriptor := aMethodInfo
!

stripSourceCode
    descriptor stripSourceCode
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

!CompiledMethod methodsFor: 'c call-outs'!

isValidCCall
    ^(self bytecodeAt: 1) == 67
        and: [ (self bytecodeAt: 2) == 0
        and: [ self numLiterals == 0
        and: [ self numTemps == 0
        and: [ self flags == 5 ]]]]!

rewriteAsCCall: func for: aClass
    | args |
    args := aClass isMetaclass
	ifFalse: [
	     (Array new: self numArgs + 1 withAll: #smalltalk)
		at: 1 put: #selfSmalltalk;
		yourself ]
	ifTrue: [
	     (Array new: self numArgs withAll: #smalltalk) ].
    ^self rewriteAsCCall: func returning: #smalltalk args: args!

rewriteAsCCall: func returning: returnType args: argsArray
    | descr literals bytecodes newMethod |
    self isValidCCall
	ifFalse: [ ^'C call-out not empty' ].
    (CFunctionDescriptor isFunction: func)
	ifFalse: [ ^'C function not defined '].

    descr := CFunctionDescriptor
	for: func
	returning: returnType
	withArgs: argsArray.

    "One of these:
	descr callInto: nil. ^self
	^(descr callInto: ValueHolder now) value
	^(descr callInto: ValueHolder now) value narrow"
    returnType == #void
	ifTrue: [
	    literals := { descr. }.
	    bytecodes := #[ 136 1 45 0 30 34 67 0 ] ]
	ifFalse: [
	    literals := { descr. #{ValueHolder}. }.
	    bytecodes := returnType isSymbol
		ifTrue: [ #[ 136 1 95 1 30 34 22 0 51 0 ] ]
		ifFalse: [ #[ 136 1 95 1 30 34 22 0 30 35 51 0 ] ] ].

    newMethod := CompiledMethod
	literals: literals
	numArgs: self numArgs
	numTemps: self numTemps
	attributes: self attributes
	bytecodes: bytecodes
	depth: self numArgs + 4.

    newMethod descriptor: self descriptor.
    self become: newMethod.
    ^nil!

rewriteAsAsyncCCall: func args: argsArray
    | descr literals bytecodes newMethod |
    self isValidCCall
	ifFalse: [ ^'C call-out not empty' ].
    (CFunctionDescriptor isFunction: func)
	ifFalse: [ ^'C function not defined '].

    descr := CFunctionDescriptor
	for: func
	returning: #void
	withArgs: argsArray.

    "descr asyncCall. ^self"
    literals := { descr. #asyncCall }.
    bytecodes := #[ 136 1 66 1 67 0 ].

    newMethod := CompiledMethod
	literals: literals
	numArgs: self numArgs
	numTemps: self numTemps
	attributes: self attributes
	bytecodes: bytecodes
	depth: self numArgs + 3.

    newMethod descriptor: self descriptor.
    self become: newMethod.
    ^nil! !

