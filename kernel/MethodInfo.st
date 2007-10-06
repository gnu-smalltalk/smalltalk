"======================================================================
|
|   MethodInfo Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003
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



Object subclass: MethodInfo [
    | sourceCode category class selector |
    
    <shape: #pointer>
    <category: 'Language-Implementation'>
    <comment: 'I provide information about particular methods.  I can produce the category
that a method was filed under, and can be used to access the source
code of the method.'>

    category [
	"Answer the method category"

	<category: 'accessing'>
	category isNil ifTrue: [category := 'still unclassified'].
	^category
    ]

    category: aCategory [
	"Set the method category"

	<category: 'accessing'>
	category := aCategory
    ]

    methodClass [
	"Answer the class in which the method is defined"

	<category: 'accessing'>
	^class
    ]

    methodClass: aClass [
	"Set the class in which the method is defined"

	<category: 'accessing'>
	class := aClass
    ]

    selector [
	"Answer the selector through which the method is called"

	<category: 'accessing'>
	^selector
    ]

    selector: aSymbol [
	"Set the selector through which the method is called"

	<category: 'accessing'>
	selector := aSymbol
    ]

    stripSourceCode [
	"Remove the reference to the source code for the method"

	<category: 'accessing'>
	sourceCode := nil
    ]

    sourceCode [
	"Answer a FileSegment or String or nil containing the method source code"

	<category: 'accessing'>
	^sourceCode
    ]

    sourceString [
	"Answer a String containing the method source code"

	<category: 'accessing'>
	^sourceCode asString
    ]

    sourceFile [
	"Answer the name of the file where the method source code is"

	<category: 'accessing'>
	^sourceCode fileName
    ]

    sourcePos [
	"Answer the starting position of the method source code in the sourceFile"

	<category: 'accessing'>
	^sourceCode filePos
    ]

    = aMethodInfo [
	"Compare the receiver and aMethodInfo, answer whether they're equal"

	<category: 'equality'>
	self class == aMethodInfo class ifFalse: [^false].
	self == aMethodInfo ifTrue: [^true].
	self sourceString = aMethodInfo sourceString ifFalse: [^false].
	^category = aMethodInfo category
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'equality'>
	^sourceCode hash bitXor: category hash
    ]

    setSourceCode: source [
	<category: 'private'>
	sourceCode := source
    ]
]

