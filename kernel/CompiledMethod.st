"======================================================================
|
|   CompiledMethod Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2005,2008,2009
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



CompiledCode subclass: CompiledMethod [
    | descriptor |
    
    <shape: #byte>
    <category: 'Language-Implementation'>
    <comment: 'I represent methods that have been compiled.  I can recompile
methods from their source code, I can invoke Emacs to edit the source code
for one of my instances, and I know how to access components of my
instances.'>

    CompiledMethod class >> literals: lits numArgs: numArg numTemps: numTemp attributes: attrArray bytecodes: bytecodes depth: depth [
	"Answer a full fledged CompiledMethod. Construct the method
	 header from the parameters, and set the literals and bytecodes
	 to the provided ones.  Also, the bytecodes are optimized and
	 any embedded CompiledBlocks modified to refer to these literals
	 and to the newly created CompiledMethod."

	<category: 'instance creation'>
	<primitive: VMpr_CompiledMethod_create>
	attrArray inject: false
	    into: 
		[:found :each | 
		each arguments size ~= each selector numArgs 
		    ifTrue: 
			[SystemExceptions.VerificationError signal: 'invalid number of arguments'].
		each selector == #primitive: 
		    ifFalse: [found]
		    ifTrue: 
			[found 
			    ifTrue: 
				[SystemExceptions.VerificationError 
				    signal: 'duplicate primitive declaration'].
			(each arguments first class == SmallInteger 
			    and: [each arguments first strictlyPositive]) 
				ifFalse: 
				    [SystemExceptions.VerificationError signal: 'invalid primitive declaration'].
			true]]
    ]

    CompiledMethod class >> numArgs: args [
	"Create a user-defined method (one that is sent
	 #valueWithReceiver:withArguments: when it is invoked)
	 with numArgs arguments.  This only makes sense when
	 called for a subclass of CompiledMethod."

	<category: 'instance creation'>
	args isInteger 
	    ifFalse: [SystemExceptions.WrongClass signalOn: args mustBe: Integer].
	(args between: 0 and: 31) 
	    ifFalse: 
		[SystemExceptions.ArgumentOutOfRange 
		    signalOn: args
		    mustBeBetween: 0
		    and: 31].
	^(self new)
	    initialize;
	    header: (6 bitShift: 27) + args literals: #()
    ]

    CompiledMethod class >> cCall: descr numArgs: numArgs attributes: attributesArray [
	"Return a CompiledMethod corresponding to a #cCall:returning:args:
	pragma with the given arguments."
	<category: 'c call-outs'>
	| literals bytecodes |
	"One of these:
	 descr callInto: nil. ^self
	 ^(descr callInto: ValueHolder now) value
	 ^(descr callInto: ValueHolder now) value narrow"
	descr returnType == #void 
	    ifTrue: 
		[literals := {descr}.
		bytecodes := #[179 1 45 0 30 34 66 0]]
	    ifFalse: 
		[literals := {descr.  #{ValueHolder}}.
		bytecodes := (descr returnType isKindOf: CType) 
			    ifTrue: [#[179 1 34 1 30 84 30 34 22 0 30 35 51 0]]
			    ifFalse: [#[179 1 34 1 30 84 30 34 22 0 51 0]]].
	^self
	    literals: literals
	    numArgs: numArgs
	    numTemps: 0
	    attributes: attributesArray
	    bytecodes: bytecodes
	    depth: numArgs + 4
    ]

    CompiledMethod class >> asyncCCall: descr numArgs: numArgs attributes: attributesArray [
	"Return a CompiledMethod corresponding to a #asyncCCall:args:
	pragma with the given arguments."

	<category: 'c call-outs'>
	| literals bytecodes |
	"descr asyncCall. ^self"
	literals := {descr.  #asyncCall}.
	bytecodes := #[179 1 65 1 66 0].
	^self 
	    literals: literals
	    numArgs: numArgs
	    numTemps: 0
	    attributes: attributesArray
	    bytecodes: bytecodes
	    depth: numArgs + 3.
    ]

    CompiledMethod class >> stripSourceCode [
	"Remove all the references to method source code from the system"

	<category: 'lean images'>
	self allInstancesDo: [:each | each stripSourceCode]
    ]

    sourceCodeLinesDelta [
	"Answer the delta from the numbers in LINE_NUMBER bytecodes
	 to source code line numbers."

	<category: 'accessing'>
	| line |
	self allByteCodeIndicesDo: 
		[:each :byte :operand | 
		(self class bytecodeInfoTable at: byte * 4 + 4) >= 128 
		    ifTrue: [^operand - 1]].
	^0
    ]

    methodCategory [
	"Answer the method category"

	<category: 'accessing'>
	^descriptor category
    ]

    methodCategory: aCategory [
	"Set the method category to the given string"

	<category: 'accessing'>
	descriptor category: aCategory
    ]

    methodSourceCode [
	"Answer the method source code (a FileSegment or String or nil)"

	<category: 'source code'>
	^(descriptor sourceCode isNil or: [descriptor sourceFile = 'stdin']) 
	    ifTrue: [nil]
	    ifFalse: [descriptor sourceCode]
    ]

    methodParseNode [
	"Answer the parse tree for the receiver, or nil if there is an error.
	 Requires the Parser package to be loaded."

	<category: 'source code'>
	self notYetImplemented
    ]

    methodFormattedSourceString [
	"Answer the pretty-printed method source code as a string.
	 Requires the Parser package to be loaded."

	<category: 'source code'>
	self notYetImplemented
    ]

    methodRecompilationSourceString [
	"Answer the method source code as a string, ensuring that it is
	 in new syntax (it has brackets)."

	<category: 'source code'>
	^self isOldSyntax
	    ifTrue: [ self methodFormattedSourceString ]
	    ifFalse: [ self methodSourceString trimSeparators ].
    ]

    methodSourceString [
	"Answer the method source code as a string"

	<category: 'source code'>
	^(descriptor sourceCode isNil or: [descriptor sourceFile = 'stdin']) 
	    ifTrue: [nil]
	    ifFalse: [descriptor sourceString]
    ]

    methodSourceFile [
	"Answer the file where the method source code is stored"

	<category: 'source code'>
	^(descriptor sourceCode isNil or: [descriptor sourceFile = 'stdin']) 
	    ifTrue: [nil]
	    ifFalse: [descriptor sourceFile]
    ]

    methodSourcePos [
	"Answer the location where the method source code is stored in
	 the methodSourceFile"

	<category: 'source code'>
	^(descriptor sourceCode isNil or: [descriptor sourceFile = 'stdin']) 
	    ifTrue: [nil]
	    ifFalse: [descriptor sourcePos]
    ]

    = aMethod [
	"Answer whether the receiver and aMethod are equal"

	<category: 'basic'>
	self == aMethod ifTrue: [^true].
	^super = aMethod and: [descriptor = aMethod descriptor]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'basic'>
	^super hash bitXor: descriptor hash
    ]

    method [
	"Answer the receiver, since it is already a method."

	<category: 'accessing'>
	^self
    ]

    methodClass [
	"Answer the class in which the receiver is installed."

	<category: 'accessing'>
	^descriptor methodClass
    ]

    methodClass: methodClass [
	"Set the receiver's class instance variable"

	<category: 'accessing'>
	descriptor methodClass: methodClass
    ]

    allBlocksDo: aBlock [
	"Evaluate aBlock, passing to it all the CompiledBlocks it holds"

	<category: 'accessing'>
	self allLiterals do: 
		[:each | 
		each class == CompiledBlock ifTrue: [aBlock value: each].
		each class == BlockClosure ifTrue: [aBlock value: each block]]
    ]

    withAllBlocksDo: aBlock [
	"Evaluate aBlock, passing the receiver and all the CompiledBlocks it
	 holds"

	<category: 'accessing'>
	aBlock value: self.
	self allBlocksDo: aBlock
    ]

    withNewMethodClass: class [
	"Answer either the receiver or a copy of it, with the method class set
	 to class"

	<category: 'accessing'>
	^self methodClass isNil 
	    ifTrue: 
		[self
		    methodClass: class;
		    yourself]
	    ifFalse: 
		[(self deepCopy)
		    methodClass: class;
		    yourself]
    ]

    withNewMethodClass: class selector: selector [
	"Answer either the receiver or a copy of it, with the method class set
	 to class"

	<category: 'accessing'>
	^(self withNewMethodClass: class)
	    selector: selector;
	    yourself
    ]

    selector: aSymbol [
	"Set the selector through which the method is called"

	<category: 'accessing'>
	descriptor selector: aSymbol
    ]

    selector [
	"Answer the selector through which the method is called"

	<category: 'accessing'>
	^descriptor selector
    ]

    flags [
	"Private - Answer the optimization flags for the receiver"

	<category: 'accessing'>
	^(header bitShift: -27) bitAnd: 7
    ]

    primitive [
	"Answer the primitive called by the receiver"

	<category: 'accessing'>
	^(header bitShift: -17) bitAnd: 511
    ]

    isOldSyntax [
	"Answer whether the method was written with the old (chunk-format)
	 syntax"

	<category: 'accessing'>
	^((header bitShift: -26) bitAnd: 1) == 1
    ]

    noteOldSyntax [
	"Remember that the method is written with the old (chunk-format)
         syntax"

        <category: 'accessing'>
	header := header bitOr: (1 bitShift: 26)
    ]

    allLiterals [
	"Answer the literals referred to by the receiver and all the blocks
	 in it"

	<category: 'accessing'>
	^literals isNil ifTrue: [#()] ifFalse: [literals]
    ]

    numArgs [
	"Answer the number of arguments for the receiver"

	<category: 'accessing'>
	^header bitAnd: 31
    ]

    numTemps [
	"Answer the number of temporaries for the receiver"

	<category: 'accessing'>
	^(header bitShift: -11) bitAnd: 63
    ]

    stackDepth [
	"Answer the number of stack slots needed for the receiver"

	<category: 'accessing'>
	^((header bitShift: -5) bitAnd: 63) * 4
    ]

    valueWithReceiver: anObject withArguments: args [
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

	<category: 'invoking'>
	^self flags = 6 
	    ifTrue: [self subclassResponsibility]
	    ifFalse: [anObject perform: self withArguments: args]
    ]

    recompile [
	"Recompile the method in the scope of the class where it leaves."

	<category: 'compiling'>
        | source category ok |
        ok :=
                [source := self methodRecompilationSourceString.
                category := self methodCategory.
                true]
                        on: Error
                        do: [:ex | ex return: false].
        ok ifFalse: [^nil].
        ^self methodClass compile: source classified: category
    ]

    recompileNotifying: aNotifier [
	"Recompile the method in the scope of the class where it leaves,
	 notifying errors to aNotifier by sending it #error:."

	<category: 'compiling'>
        | source category ok |
        ok :=
                [source := self methodRecompilationSourceString.
                category := self methodCategory.
                true]
                        on: Error
                        do: [:ex | ex return: false].
        ok ifFalse: [^nil].
        ^self methodClass
	    compile: source
	    classified: category
	    notifying: aNotifier
    ]

    isAnnotated [
	"If the receiver has any attributes, answer true."

	<category: 'attributes'>
	| flags |
	flags := self flags.
	^flags == 4 or: [flags == 5]
    ]

    primitiveAttribute [
	"If the receiver defines a primitive, return a Message resembling
	 the attribute that was used to define it."

	<category: 'attributes'>
	| primitive |
	primitive = 0 ifTrue: [^nil].
	^Message selector: #primitive: arguments: {primitive}
    ]

    attributes [
	"Return an Array of Messages, one for each attribute defined by the
	 receiver."

	<category: 'attributes'>
	| attributes numAttr |
	self isAnnotated ifFalse: [^#()].
	numAttr := descriptor size.
	self primitive = 0 ifFalse: [numAttr := numAttr + 1].
	attributes := Array new: numAttr.
	self primitive = 0 
	    ifFalse: [attributes at: numAttr put: self primitiveAttribute].
	1 to: descriptor size do: [:i | attributes at: i put: (descriptor at: i)].
	^attributes
    ]

    attributeAt: aSymbol [
	"Return a Message for the first attribute named aSymbol defined by the
	 receiver, or answer an error if none was found."

	<category: 'attributes'>
	^self attributeAt: aSymbol
	    ifAbsent: [SystemExceptions.NotFound signalOn: aSymbol what: 'attribute']
    ]

    attributeAt: aSymbol ifAbsent: aBlock [
	"Return a Message for the first attribute named aSymbol defined by the
	 receiver, or evaluate aBlock is none was found."

	<category: 'attributes'>
	| primitive attr |
	self isAnnotated ifFalse: [^aBlock value].
	aSymbol == #primitive: 
	    ifTrue: 
		[primitive := self primitiveAttribute.
		^primitive isNil ifTrue: [aBlock value] ifFalse: [primitive]].
	1 to: descriptor size
	    do: 
		[:i | 
		attr := descriptor at: i.
		attr selector = aSymbol ifTrue: [^attr]].
	^aBlock value
    ]

    attributesDo: aBlock [
	"Evaluate aBlock once for each attribute defined by the receiver,
	 passing a Message each time."

	<category: 'attributes'>
	| attr |
	self isAnnotated ifFalse: [^self].
	self primitive = 0 ifFalse: [aBlock value: self primitiveAttribute].
	1 to: descriptor size
	    do: 
		[:i | 
		| attr |
		attr := descriptor at: i.
		aBlock value: attr]
    ]

    storeOn: aStream [
	"Print code to create the receiver on aStream"

	<category: 'printing'>
	aStream
	    nextPutAll: '((';
	    print: self class;
	    nextPutAll: ' literals: ';
	    store: ((1 to: self numLiterals) collect: [:i | self literalAt: i]);
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
    ]

    printHeaderOn: aStream [
	"Private - Disassemble the method header to aStream"

	<category: 'private-printing'>
	aStream
	    nextPutAll: '  Header Flags: ';
	    nl;
	    nextPutAll: '    flags: ';
	    print: self flags;
	    nl;
	    nextPutAll: '    primitive index: ';
	    print: self primitive.
	self flags = 4 
	    ifTrue: 
		[aStream
		    nextPutAll: ' (';
		    nextPutAll: (VMPrimitives keyAtValue: self primitive ifAbsent: ['unknown']);
		    nextPut: $)].
	aStream
	    nl;
	    nextPutAll: '    number of arguments: ';
	    print: self numArgs;
	    nl;
	    nextPutAll: '    number of temporaries: ';
	    print: self numTemps;
	    nl;
	    nextPutAll: '    number of literals: ';
	    print: self numLiterals;
	    nl;
	    nextPutAll: '    needed stack slots: ';
	    print: self stackDepth;
	    nl
    ]

    printOn: aStream [
	"Print the receiver's class and selector on aStream"

	<category: 'printing'>
	descriptor isNil ifTrue: [^super printOn: aStream].
	self methodClass printOn: aStream in: Namespace current.
	aStream
	    nextPutAll: '>>';
	    nextPutAll: self selector
    ]

    postCopy [
	"Private - Make a deep copy of the descriptor and literals.
	 Don't need to replace the method header and bytecodes, since they
	 are integers."

	<category: 'private'>
	super postCopy.
	descriptor := descriptor copy
	"literals := literals deepCopy.
	 self makeLiteralsReadOnly"
    ]

    makeLiteralsReadOnly [
	<category: 'private'>
	literals isNil ifTrue: [^self].
	self makeLiteralsReadOnly: literals
    ]

    makeLiteralsReadOnly: array [
	<category: 'private'>
	array do: 
		[:each | 
		each class == Array ifTrue: [self makeLiteralsReadOnly: each].
		(each class isKindOf: LookupKey) ifFalse: [each makeReadOnly: true]].
    ]

    initialize [
	<category: 'private'>
	descriptor := MethodInfo new
    ]

    descriptor [
	<category: 'private'>
	^descriptor
    ]

    descriptor: aMethodInfo [
	<category: 'private'>
	descriptor := aMethodInfo
    ]

    stripSourceCode [
	<category: 'private'>
	descriptor stripSourceCode
    ]

    isAbstract [
	"Answer whether the receiver is abstract."

	<category: 'testing'>
	^self refersTo: #subclassResponsibility
    ]

    sendsToSuper [
	"Answer whether the receiver or the blocks it contains have
	 sends to super"

	<category: 'testing'>
	self allBlocksDo: [:ccode | ccode sendsToSuper ifTrue: [^true]].
	^super sendsToSuper
    ]

    reads: instVarIndex [
	"Answer whether the receiver or the blocks it contains reads to
	 the instance variable with the given index"

	<category: 'testing'>
	self allBlocksDo: [:ccode | (ccode reads: instVarIndex) ifTrue: [^true]].
	^super reads: instVarIndex
    ]

    assigns: instVarIndex [
	"Answer whether the receiver or the blocks it contains writes to
	 the instance variable with the given index"

	<category: 'testing'>
	self allBlocksDo: [:ccode | (ccode assigns: instVarIndex) ifTrue: [^true]].
	^super assigns: instVarIndex
    ]

    accesses: instVarIndex [
	"Answer whether the receiver or the blocks it contains accesses
	 the instance variable with the given index"

	<category: 'testing'>
	self 
	    allBlocksDo: [:ccode | (ccode accesses: instVarIndex) ifTrue: [^true]].
	^super accesses: instVarIndex
    ]

    binaryRepresentationObject [
	"This method is implemented to allow for a PluggableProxy to be used
	 with CompiledMethods.  Answer a DirectedMessage which sends #>>
	 to the class object containing the receiver."

	<category: 'saving and loading'>
	^DirectedMessage 
	    selector: #>>
	    arguments: (Array with: self selector)
	    receiver: self methodClass
    ]

    isValidCCall [
	"Answer whether I appear to have the valid flags, information,
	 and ops to invoke a C function and answer its result."
	<category: 'c call-outs'>
	^(self bytecodeAt: 1) == 66 and: 
		[(self bytecodeAt: 2) == 0 
		    and: [self numLiterals == 0 and: [self numTemps == 0 and: [self flags == 5]]]]
    ]

    rewriteAsCCall: funcOrDescr for: aClass [
	<category: 'c call-outs'>
	| args newMethod |
	funcOrDescr isString ifFalse: [
	    self isValidCCall ifFalse: [^'C call-out not empty'].
	    newMethod := CompiledMethod
	        cCall: funcOrDescr
	        numArgs: self numArgs
	        attributes: self attributes.
	    newMethod descriptor: self descriptor.
	    self isOldSyntax ifTrue: [ newMethod noteOldSyntax ].
	    self become: newMethod.
	    ^nil].

	args := aClass isMetaclass 
		    ifFalse: 
			[(Array new: self numArgs + 1 withAll: #smalltalk)
			    at: 1 put: #selfSmalltalk;
			    yourself]
		    ifTrue: [Array new: self numArgs withAll: #smalltalk].
	^self 
	    rewriteAsCCall: funcOrDescr
	    returning: #smalltalk
	    args: args
    ]

    rewriteAsCCall: func returning: returnType args: argsArray [
	<category: 'c call-outs'>
	| newMethod descr |
	self isValidCCall ifFalse: [^'C call-out not empty'].
	newMethod := CompiledMethod
	    cCall: (CFunctionDescriptor for: func returning: returnType withArgs: argsArray)
	    numArgs: self numArgs
	    attributes: self attributes.
	newMethod isNil ifTrue: [^'C function not defined'].
	newMethod descriptor: self descriptor.
	self isOldSyntax ifTrue: [ newMethod noteOldSyntax ].
	self become: newMethod.
	^nil
    ]

    rewriteAsAsyncCCall: func args: argsArray [
	<category: 'c call-outs'>
	| newMethod |
	self isValidCCall ifFalse: [^'C call-out not empty'].
	newMethod := CompiledMethod
	    asyncCCall: (CFunctionDescriptor for: func returning: #void withArgs: argsArray)
	    numArgs: self numArgs
	    attributes: self attributes.
	newMethod isNil ifTrue: [^'C function not defined'].
	newMethod descriptor: self descriptor.
	self isOldSyntax ifTrue: [ newMethod noteOldSyntax ].
	self become: newMethod.
	^nil
    ]
]

