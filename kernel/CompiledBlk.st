"======================================================================
|
|   CompiledBlock Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2003, 2008 Free Software Foundation, Inc.
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



CompiledCode subclass: CompiledBlock [
    | method |
    
    <shape: #byte>
    <category: 'Language-Implementation'>
    <comment: 'I represent a block that has been compiled.'>

    CompiledBlock class >> numArgs: args numTemps: temps bytecodes: bytecodes depth: depth literals: literalArray [
	"Answer an (almost) full fledged CompiledBlock.  To make it complete,
	 you must either set the new object's `method' variable, or put it
	 into a BlockClosure and put the BlockClosure into a CompiledMethod's
	 literals.  The clean-ness of the block is automatically computed."

	<category: 'instance creation'>
	<primitive: VMpr_CompiledBlock_create>
	self primitiveFailed
    ]

    CompiledBlock class >> new: numBytecodes header: anInteger method: outerMethod [
	"Answer a new instance of the receiver with room for the given
	 number of bytecodes and the given header."

	<category: 'instance creation'>
	^(self 
	    new: numBytecodes
	    header: anInteger
	    literals: outerMethod literals) method: outerMethod
    ]

    methodCategory [
	"Answer the method category"

	<category: 'basic'>
	^method methodCategory
    ]

    sourceCodeLinesDelta [
	"Answer the delta from the numbers in LINE_NUMBER bytecodes
	 to source code line numbers."

	<category: 'accessing'>
	^method sourceCodeLinesDelta
    ]

    sourceCodeMap [
	"Answer an array which maps bytecode indices to source code
	 line numbers.  0 values represent invalid instruction
	 pointer indices."

	<category: 'accessing'>
	| map line |
	map := ByteArray new: self size.
	line := 1.
	self allByteCodeIndicesDo: 
		[:each :byte :operand | 
		(self class bytecodeInfoTable at: byte * 4 + 4) >= 128 
		    ifTrue: 
			[line := operand.
			operand > 255 ifTrue: [map := map asArray]].
		map at: each put: line].
	^map
    ]

    methodCategory: aCategory [
	"Set the method category to the given string"

	<category: 'basic'>
	method methodCategory: aCategory
    ]

    methodSourceCode [
	"Answer the method source code (a FileSegment or String or nil)"

	<category: 'basic'>
	^method methodSourceCode
    ]

    methodSourceString [
	"Answer the method source code as a string"

	<category: 'basic'>
	^method methodSourceString
    ]

    methodSourceFile [
	"Answer the file where the method source code is stored"

	<category: 'basic'>
	^method methodSourceFile
    ]

    methodSourcePos [
	"Answer the location where the method source code is stored in
	 the methodSourceFile"

	<category: 'basic'>
	^method methodSourcePos
    ]

    = aMethod [
	"Answer whether the receiver and aMethod are equal"

	<category: 'basic'>
	self == aMethod ifTrue: [^true].
	^super = aMethod and: [method = aMethod method]
    ]

    method [
	"Answer the CompiledMethod in which the receiver lies"

	<category: 'accessing'>
	^method
    ]

    methodClass [
	"Answer the class in which the receiver is installed."

	<category: 'accessing'>
	^method methodClass
    ]

    methodClass: methodClass [
	"Set the receiver's class instance variable"

	<category: 'accessing'>
	method methodClass: methodClass
    ]

    selector: aSymbol [
	"Set the selector through which the method is called"

	<category: 'accessing'>
	method selector: aSymbol
    ]

    selector [
	"Answer the selector through which the method is called"

	<category: 'accessing'>
	^method selector
    ]

    flags [
	"Answer the `cleanness' of the block.
	 0 = clean;
	 1 = access to receiver variables and/or self;
	 2-30 = access to variables that are 1-29 contexts away;
	 31 = return from method or push thisContext"

	<category: 'accessing'>
	^header bitAnd: 31
    ]

    numArgs [
	"Answer the number of arguments passed to the receiver"

	<category: 'accessing'>
	^(header bitShift: -25) bitAnd: 31
    ]

    numTemps [
	"Answer the number of temporary variables used by the receiver"

	<category: 'accessing'>
	^(header bitShift: -20) bitAnd: 31
    ]

    stackDepth [
	"Answer the number of stack slots needed for the receiver"

	<category: 'accessing'>
	^((header bitShift: -14) bitAnd: 63) * 4
    ]

    numLiterals [
	"Answer the number of literals for the receiver"

	<category: 'accessing'>
	^literals size
    ]

    printOn: aStream [
	"Print the receiver's class and selector on aStream"

	<category: 'printing'>
	aStream
	    nextPutAll: '[] in ';
	    print: method
    ]

    printHeaderOn: aStream [
	"Private - Disassemble the method header to aStream"

	<category: 'private-printing'>
	aStream
	    nextPutAll: '    clean-ness flags: ';
	    print: self flags;
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

    header: hdr literals: lits [
	"Implementation note: here is the use of the header bits:
	 - bits  0-4  = clean-ness flags
	 - bits  5-13 = unused
	 - bits 14-19 = stack depth
	 - bits 20-24 = number of temps
	 - byte 25-29 = number of args"

	<category: 'private-printing'>
	header := hdr.
	literals := lits.
	Behavior flushCache
    ]

    binaryRepresentationObject [
	"This method is implemented to allow for a PluggableProxy to be used
	 with CompiledBlocks.  Answer a DirectedMessage which sends #blockAt:
	 to the CompiledMethod containing the receiver."

	<category: 'saving and loading'>
	| literalNumber |
	self literals keysAndValuesDo: 
		[:i :lit | 
		lit == self 
		    ifTrue: 
			[^DirectedMessage 
			    selector: #blockAt:
			    arguments: (Array with: i)
			    receiver: self method].
		(lit class == BlockClosure and: [lit block == self]) 
		    ifTrue: 
			[^DirectedMessage 
			    selector: #blockAt:
			    arguments: (Array with: i)
			    receiver: self method]].
	self error: 'object cannot be dumped'
    ]
]

