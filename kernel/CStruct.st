"======================================================================
|
|   C struct definition support classes.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2008,2009
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



CObject subclass: CCompound [
    
    <shape: #word>
    <category: 'Language-C interface'>
    <comment: nil>

    CCompound class [
	| declaration |
	
    ]

    CCompound class >> gcNew [
	"Allocate a new instance of the receiver, backed by garbage-collected
	 storage."

	<category: 'instance creation'>
	^self gcAlloc: self sizeof
    ]

    CCompound class >> new [
	"Allocate a new instance of the receiver. To free the memory after
	 GC, remember to call #addToBeFinalized."

	<category: 'instance creation'>
	^self alloc: self sizeof
    ]

    CCompound class >> sizeof [
	"Answer 0, the size of an empty struct"

	<category: 'subclass creation'>
	^0
    ]

    CCompound class >> alignof [
	"Answer 1, the alignment of an empty struct"

	<category: 'subclass creation'>
	^1
    ]

    CCompound class >> classPragmas [
	"Return the pragmas that are written in the file-out of this class."

	<category: 'subclass creation'>
	^super classPragmas copyWith: #declaration
    ]

    CCompound class >> newStruct: structName declaration: array [
	"The old way to create a CStruct.  Superseded by #subclass:declaration:..."

	<category: 'subclass creation'>
	^self 
	    subclass: structName
	    declaration: array
	    classVariableNames: ''
	    poolDictionaries: ''
	    category: 'Synthetic Class'
    ]

    CCompound class >> subclass: structName declaration: array classVariableNames: cvn poolDictionaries: pd category: category [
	"Create a new class with the given name that contains code
	 to implement the given C struct.  All the parameters except
	 `array' are the same as for a standard class creation message;
	 see documentation for more information"

	<category: 'subclass creation'>
	| newClass |
	newClass := self 
		    variableWordSubclass: structName asSymbol
		    instanceVariableNames: ''
		    classVariableNames: cvn
		    poolDictionaries: pd
		    category: category.
	newClass declaration: array.
	^newClass
    ]

    CCompound class >> declaration [
	"Return the description of the fields in the receiver class."

	<category: 'subclass creation'>
	declaration isNil ifTrue: [declaration := #()].
	^declaration
    ]

    CCompound class >> declaration: array [
	<category: 'subclass creation'>
	self subclassResponsibility
    ]

    CCompound class >> declaration: array inject: startOffset into: aBlock [
	"Compile methods that implement the declaration in array.  To
	 compute the offset after each field, the value of the
	 old offset plus the new field's size is passed to aBlock,
	 together with the new field's alignment requirements."

	<category: 'subclass creation'>
	| offset maxAlignment inspStr |
	(self declaration notEmpty and: [self declaration ~= array]) 
	    ifTrue: [self error: 'cannot redefine CStruct/CUnion'].
	declaration := array.
	offset := startOffset.
	maxAlignment := self superclass alignof.
	inspStr := WriteStream on: (String new: 8).
	inspStr
	    nextPutAll: 'fieldSelectorList [';
	    nl;
	    nextPutAll: '    ^#('.

	"Iterate through each member, doing alignment, size calculations,
	 and creating accessor methods"
	array do: 
		[:dcl | 
		| typeDecl name str type |
		name := dcl at: 1.
		typeDecl := dcl at: 2.
		self emitFieldNameTo: inspStr for: name.
		type := CType from: typeDecl.
		offset := aBlock value: offset value: type alignof.
		maxAlignment := type alignof max: maxAlignment.
		str := WriteStream on: (String new: 20).
		str
		    nextPutAll: name;
		    nextPutAll: ' [';
		    nl;
		    nextPutAll: '    ^self at: ';
		    print: offset;
		    nextPutAll: ' type: ';
		    store: type;
		    nl;
		    nextPut: $].
		self compile: str classified: 'accessing'.
		offset := offset + type sizeof].
	inspStr nextPut: $); nl; nextPut: $].
	self compile: inspStr contents classified: 'debugging'.
	self compileSize: offset align: maxAlignment
    ]

    CCompound class >> compileSize: size align: alignment [
	"Private - Compile sizeof and alignof methods"

	<category: 'subclass creation'>
	| sizeofMethod alignofMethod |
	sizeofMethod := 'sizeof [
    ^' , (size alignTo: alignment) printString, '
]'.
	alignofMethod := 'alignof [
    ^' , alignment printString, '
]'.
	self compile: sizeofMethod classified: 'accessing'.
	self class compile: sizeofMethod classified: 'accessing'.
	self compile: alignofMethod classified: 'accessing'.
	self class compile: alignofMethod classified: 'accessing'
    ]

    CCompound class >> emitFieldNameTo: str for: name [
	"Private - Emit onto the given stream the code for adding the
	 given selector to the CCompound's #examineOn: method."

	<category: 'subclass creation'>
	str
	    nl;
	    next: 8 put: Character space;
	    nextPut: $#;
	    nextPutAll: name
    ]

    fieldSelectorList [
	"Answer a list of selectors whose return values should be printed
	 by #examineOn:."

	"We can't call subclassResponsibility because #inspect should never
	 fail. So answer an empty array.
	 For subclasses, it will answer an Array of the selectors whose
	 values are to be shown in #examineOn: or a GUI inspector."

	<category: 'debugging'>
	^#()
    ]

    examineOn: aStream [
	"Print the contents of the receiver's fields on aStream"

	"This method applies to every instance of the receiver
	 and their subclasses, which only override #fieldSelectorList."

	<category: 'debugging'>
	aStream print: self; nl.
	self fieldSelectorList do: 
		[:each | 
		Transcript
		    nextPutAll: '    ';
		    nextPutAll: each;
		    nextPutAll: ': ';
		    print: (self perform: each) value;
		    nl]
    ]
]



CCompound subclass: CStruct [
    
    <shape: #word>
    <category: 'Language-C interface'>
    <comment: nil>

    CStruct class >> declaration: array [
	"Compile methods that implement the declaration in array."

	<category: 'subclass creation'>
	self 
	    declaration: array
	    inject: self superclass sizeof
	    into: [:oldOffset :alignment | oldOffset alignTo: alignment]
    ]
]



CCompound subclass: CUnion [
    
    <shape: #word>
    <category: 'Language-C interface'>
    <comment: nil>

    CUnion class >> declaration: array [
	"Compile methods that implement the declaration in array."

	<category: 'subclass creation'>
	self 
	    declaration: array
	    inject: 0
	    into: [:oldOffset :alignment | 0]
    ]
]



Integer extend [

    alignTo: anInteger [
	"Answer the receiver, truncated to the first higher or equal
	 multiple of anInteger (which must be a power of two)"

	<category: 'extension'>
	^self + anInteger - 1 bitClear: anInteger - 1
    ]

]



Eval [
    CCompound initialize
]

