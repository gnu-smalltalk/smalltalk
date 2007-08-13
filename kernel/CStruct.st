"======================================================================
|
|   C struct definition support classes.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002
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


CObject variableWordSubclass: #CCompound
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-C interface'
!

CCompound class instanceVariableNames: 'declaration'!

CCompound variableWordSubclass: #CStruct
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-C interface'
!

CCompound variableWordSubclass: #CUnion
      instanceVariableNames: ''
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Language-C interface'
!


!Integer methodsFor: 'extension'!

alignTo: anInteger
    "Answer the receiver, truncated to the first higher or equal
     multiple of anInteger (which must be a power of two)"
    ^(self + anInteger - 1) bitClear: (anInteger - 1)
! !


!CCompound class methodsFor: 'instance creation'!

new
    "Allocate a new instance of the receiver. To free the memory after
     GC, remember to call #addToBeFinalized."
    ^self alloc: self sizeof
! !


!CCompound class methodsFor: 'subclass creation'!

sizeof
    "Answer 0, the size of an empty struct"
    ^0
!

alignof
    "Answer 1, the alignment of an empty struct"
    ^1
!

classPragmas
    "Return the pragmas that are written in the file-out of this class."
    ^super classPragmas copyWith: #declaration
!

newStruct: structName declaration: array
    "The old way to create a CStruct.  Superseded by #subclass:declaration:..."
    ^self
        subclass: structName
	declaration: array
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Synthetic Class'
!

subclass: structName declaration: array
    classVariableNames: cvn poolDictionaries: pd category: category

    "Create a new class with the given name that contains code
     to implement the given C struct.  All the parameters except
     `array' are the same as for a standard class creation message;
     see documentation for more information"

    | newClass |
    newClass := self variableWordSubclass: structName asSymbol
		       instanceVariableNames: ''
		       classVariableNames: cvn
		       poolDictionaries: pd
		       category: category.

    newClass declaration: array.
    ^newClass
!

declaration
    "Return the description of the fields in the receiver class."
    ^declaration
!

declaration: array
    self subclassResponsibility
!

declaration: array inject: startOffset into: aBlock
    "Compile methods that implement the declaration in array.  To
     compute the offset after each field, the value of the
     old offset plus the new field's size is passed to aBlock,
     together with the new field's alignment requirements."
    | offset maxAlignment inspStr |
    (declaration notNil and: [ declaration ~= array ])
	ifTrue: [ self error: 'cannot redefine CStruct/CUnion' ].

    declaration := array.
    offset := startOffset.
    maxAlignment := self superclass alignof.
    inspStr := WriteStream on: (String new: 8).
    inspStr nextPutAll: 'inspectSelectorList'; nl; nextPutAll: '    ^#('.

    "Iterate through each member, doing alignment, size calculations,
     and creating accessor methods"
    array do: [ :dcl || typeDecl name str type |
	name := dcl at: 1.
	typeDecl := dcl at: 2.
	self emitInspectTo: inspStr for: name.

	type := CType from: typeDecl.
	offset := aBlock value: offset value: type alignof.
	maxAlignment := type alignof max: maxAlignment.

	str := WriteStream on: (String new: 20).
	str nextPutAll: name;
	    nl;
	    nextPutAll: '    ^self at: ';
	    print: offset;
	    nextPutAll: ' type: ';
	    store: type.
	self compile: str classified: 'accessing'.
	offset := offset + type sizeof
    ].

    self compile: inspStr contents, ')' classified: 'debugging'.
    self compileSize: offset align: maxAlignment
!
			
compileSize: size align: alignment
    "Private - Compile sizeof and alignof methods"
    | sizeofMethod alignofMethod |

    sizeofMethod :=  'sizeof
    ^', (size alignTo: alignment) printString.
    alignofMethod := 'alignof
    ^', (alignment printString).

    self compile: sizeofMethod classified: 'accessing'.
    self class compile: sizeofMethod classified: 'accessing'.

    self compile: alignofMethod classified: 'accessing'.
    self class compile: alignofMethod classified: 'accessing'.
!

emitInspectTo: str for: name
    "Private - Emit onto the given stream the code for adding the
     given selector to the CCompound's inspector."

    str nl;
	next: 8 put: Character space;
	nextPut: $#;
	nextPutAll: name
! !


!CCompound methodsFor: 'instance creation'!


inspectSelectorList
    "Answer a list of selectors whose return values should be inspected
     by #inspect."

    "We can't call subclassResponsibility because #inspect should never
     fail - it would lead to recursive walkbacks. So answer an empty
     array.
     For subclasses, it will answer an Array of the selectors whose
     values are to be shown in the inspector."
    ^#()
!
inspect
    "Inspect the contents of the receiver"
    "This inspect method applies to every instance of the receiver
     and their subclasses, which only override #inspectSelectorList."
    self printNl.
    self inspectSelectorList do: [ :each |
	Transcript
	   nextPutAll: '    ';
	   nextPutAll: each;
	   nextPutAll: ': ';
	   print: (self perform: each) value;
	   nl
    ].
! !

!CStruct class methodsFor: 'subclass creation'!

declaration: array
    "Compile methods that implement the declaration in array."
    self
	declaration: array
	inject: self superclass sizeof
	into: [ :oldOffset :alignment | oldOffset alignTo: alignment ]
! !

!CUnion class methodsFor: 'subclass creation'!

declaration: array
    "Compile methods that implement the declaration in array."
    self
	declaration: array
	inject: 0
	into: [ :oldOffset :alignment | 0 ]
! !


CCompound initialize!
