"======================================================================
|
|   Base class definition for C data type description objects.
| 
|
 ======================================================================"

"======================================================================
|
| Copyright 1990,91,92,94,95,99,2000,2001,2007,2008
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



CPtrCType subclass: CArrayCType [
    | numElements |
    
    <category: 'Language-C interface'>
    <comment: nil>

    CArrayCType class >> from: type [
	"Private - Called by CType>>from: for arrays"

	<category: 'instance creation'>
	| numElts elementType typeInfo |
	elementType := type at: 2.
	numElts := type at: 3.
	typeInfo := CType from: elementType.
	^self elementType: typeInfo numberOfElements: numElts
    ]

    CArrayCType class >> elementType: aCType [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    CArrayCType class >> elementType: aCType numberOfElements: anInteger [
	"Answer a new instance of CPtrCType that maps an array whose elements
	 are of the given CType, and whose size is exactly anInteger elements
	 (of course, anInteger only matters for allocation, not for access, since
	 no out-of-bounds protection is provided for C objects)."

	<category: 'instance creation'>
	^(self cObjectType: CArray)
	    elementType: aCType;
	    numberOfElements: anInteger;
	    yourself
    ]

    = anObject [
        "Return whether the receiver and anObject are equal."
	<category: 'basic'>
        ^super = anObject and: [
            self numberOfElements = anObject numberOfElements]
    ]

    hash [
        "Return a hash code for the receiver."
	<category: 'basic'>
        ^super hash bitXor: self numberOfElements hash
    ]

    storeOn: aStream [
	"As with super."
	<category: 'storing'>
	aStream
	    nextPutAll: '(CArrayCType elementType: ';
	    store: self elementType;
	    nextPutAll: ' numberOfElements: ';
	    store: numElements asInteger;
	    nextPut: $)
    ]

    sizeof [
	"Answer the size of the receiver's instances"

	<category: 'accessing'>
	^elementType sizeof * numElements
    ]

    alignof [
	"Answer the alignment of the receiver's instances"

	<category: 'accessing'>
	^elementType alignof
    ]

    numberOfElements [
	"Answer the number of elements in the receiver's instances"

	<category: 'accessing'>
	^numElements
    ]

    numberOfElements: anInteger [
	"Initialize the receiver's instance variables"

	<category: 'private'>
	numElements := anInteger
    ]
]

