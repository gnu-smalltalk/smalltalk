"======================================================================
|
|   CompiledBlock Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2000, 2001, 2003 Free Software Foundation, Inc.
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



CompiledCode variableByteSubclass: #CompiledBlock
       instanceVariableNames: 'method '
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Language-Implementation'
!

CompiledBlock comment:
'I represent a block that has been compiled.' !


!CompiledBlock class methodsFor: 'instance creation'!

new: numBytecodes header: anInteger method: outerMethod
    "Answer a new instance of the receiver with room for the given
     number of bytecodes and the given header."
    ^(self
	new: numBytecodes
	header: anInteger
	literals: outerMethod literals) method: outerMethod
! !
   

!CompiledBlock methodsFor: 'basic'!

methodCategory
    "Answer the method category"
    ^method methodCategory
!

methodCategory: aCategory
    "Set the method category to the given string"
    method methodCategory: aCategory
!

methodSourceCode
    "Answer the method source code (a FileSegment or String or nil)"
    ^method methodSourceCode
!

methodSourceString
    "Answer the method source code as a string"
    ^method methodSourceString
!

methodSourceFile
    "Answer the file where the method source code is stored"
    ^method methodSourceFile
!

methodSourcePos
    "Answer the location where the method source code is stored in
     the methodSourceFile"
    ^method methodSourcePos
!

= aMethod
    "Answer whether the receiver and aMethod are equal"

    self == aMethod ifTrue: [ ^true ].
    ^super = aMethod and: [
	method = aMethod method ]
! !


!CompiledBlock methodsFor: 'accessing'!

method
    "Answer the CompiledMethod in which the receiver lies"
    ^method
!

methodClass
    "Answer the class in which the receiver is installed."
    ^method methodClass
!

methodClass: methodClass
    "Set the receiver's class instance variable"
    method methodClass: methodClass
!

selector: aSymbol
    "Set the selector through which the method is called"
    method selector: aSymbol
!

selector
    "Answer the selector through which the method is called"
    ^method selector
!

flags
    "Answer the `cleanness' of the block. 
     0 = clean;
     1 = access to receiver variables and/or self;
     2-30 = access to variables that are 1-29 contexts away;
     31 = return from method or push thisContext"
    ^header bitAnd: 31
!

numArgs
    "Answer the number of arguments passed to the receiver"
    ^(header bitShift: -25) bitAnd: 31
!

numTemps
    "Answer the number of temporary variables used by the receiver"
    ^(header bitShift: -20) bitAnd: 31
!

stackDepth
    "Answer the number of stack slots needed for the receiver"
    ^((header bitShift: -14) bitAnd: 63) * 4
!

numLiterals
    "Answer the number of literals for the receiver"
    ^literals size
! !



!CompiledBlock methodsFor: 'printing'!

printOn: aStream
    "Print the receiver's class and selector on aStream"

    aStream nextPutAll: '[] in '; print: method
! !


!CompiledBlock methodsFor: 'private-printing'!

printHeaderOn: aStream
    "Private - Disassemble the method header to aStream"

    aStream
	nextPutAll: '    clean-ness flags: ';
	print:      self flags;
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
!

header: hdr literals: lits
    "Implementation note: here is the use of the header bits:
     - bits  0-4  = clean-ness flags
     - bits  5-13 = unused
     - bits 14-19 = stack depth
     - bits 20-24 = number of temps
     - byte 25-29 = number of args"
    header := hdr.
    literals := lits.
    Behavior flushCache
! !

!CompiledBlock methodsFor: 'saving and loading'!

binaryRepresentationObject
    "This method is implemented to allow for a PluggableProxy to be used
     with CompiledBlocks.  Answer a DirectedMessage which sends #blockAt:
     to the CompiledMethod containing the receiver."
    | literalNumber |
    self literals keysAndValuesDo: [ :i :lit |
	lit == self
	    ifTrue: [ ^DirectedMessage
		selector: #blockAt:
		arguments: (Array with: i)
		receiver: self method
	    ].
	(lit class == BlockClosure and: [ lit block == self ])
	    ifTrue: [ ^DirectedMessage
		selector: #blockAt:
		arguments: (Array with: i)
		receiver: self method
	    ]
    ].
    self error: 'object cannot be dumped'
! !
