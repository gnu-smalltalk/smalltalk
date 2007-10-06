"======================================================================
|
|   Association Method Definitions
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



LookupKey subclass: Association [
    | value |
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent a mapping between two objects.  Typically, my
"key" object is a symbol, but I don''t require this.  My "value" object has 
no conventions associated with it; it can be any object at all.'>

    Association class >> key: aKey value: aValue [
	"Answer a new association with the given key and value"

	<category: 'basic'>
	^self new key: aKey value: aValue
    ]

    environment [
	"Answer nil.  This is present to achieve polymorphism with
	 instances of VariableBinding."

	<category: 'accessing'>
	^nil
    ]

    environment: aNamespace [
	"Do nothing.  This is present to achieve polymorphism with
	 instances of VariableBinding."

	<category: 'accessing'>
	
    ]

    value: aValue [
	"Set the association's value to aValue"

	<category: 'accessing'>
	value := aValue
    ]

    key: aKey value: aValue [
	"Set the association's key to aKey, and its value to aValue"

	<category: 'accessing'>
	key := aKey.
	value := aValue
    ]

    value [
	"Answer the association's value"

	<category: 'accessing'>
	^value
    ]

    = anAssociation [
	"Answer whether the association's key and value are the same as
	 anAssociation's, or false if anAssociation is not an Association.
	 As a special case, identical values are considered equal even if
	 #= returns false (as is the case for NaN floating-point values)."

	<category: 'testing'>
	self class == anAssociation class ifFalse: [^false].
	self key = anAssociation key ifFalse: [^false].
	self value == anAssociation value ifTrue: [^true].
	^self value = anAssociation value
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'testing'>
	^key hash bitXor: value hash
    ]

    printOn: aStream [
	"Put on aStream a representation of the receiver"

	<category: 'printing'>
	self key printOn: aStream.
	aStream nextPutAll: '->'.
	self value printOn: aStream
    ]

    storeOn: aStream [
	"Put on aStream some Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream nextPut: $(.
	aStream store: self class.
	aStream nextPutAll: ' key: '.
	self key storeOn: aStream.
	aStream nextPutAll: ' value: '.
	self value storeOn: aStream.
	aStream nextPut: $)
    ]

    mourn [
	"Finalize the receiver"

	<category: 'finalization'>
	self key: nil value: nil
    ]
]

