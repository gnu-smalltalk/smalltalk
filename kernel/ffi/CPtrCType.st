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



CType subclass: CPtrCType [
    | elementType |
    
    <category: 'Language-C interface'>
    <comment: nil>

    CPtrCType class >> from: type [
	"Private - Called by computeAggregateType: for pointers"

	<category: 'instance creation'>
	| subType typeInfo |
	subType := type at: 2.
	typeInfo := CType from: subType.
	^self elementType: typeInfo
    ]

    CPtrCType class >> elementType: aCType [
	"Answer a new instance of CPtrCType that maps pointers to the given CType"

	<category: 'instance creation'>
	^(self cObjectType: CPtr)
	    elementType: aCType;
	    yourself
    ]

    = anObject [
        "Return whether the receiver and anObject are equal."
	<category: 'basic'>
        ^super = anObject and: [self elementType = anObject elementType]
    ]

    hash [
        "Return a hash code for the receiver."
	<category: 'basic'>
        ^super hash bitXor: self elementType hash
    ]

    elementType [
	"Answer the type of the elements in the receiver's instances"

	<category: 'accessing'>
	^elementType
    ]

    storeOn: aStream [
	<category: 'storing'>
	aStream
	    nextPutAll: '(CPtrCType elementType: ';
	    store: self elementType;
	    nextPut: $)
    ]

    elementType: aCType [
	"Initialize the receiver's instance variables"

	<category: 'private'>
	elementType := aCType
    ]
]

