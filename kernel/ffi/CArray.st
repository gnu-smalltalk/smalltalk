"======================================================================
|
|   C object basic data type definitions.
| 
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2004,2008,2009
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



CAggregate subclass: CArray [
    
    <category: 'Language-C interface'>
    <comment: nil>

    sizeof [
	"Answer the receiver's size"

	<category: 'accessing'>
	^self type numberOfElements * self elementType sizeof
    ]

    alignof [
	"Answer the receiver's required aligment"

	<category: 'accessing'>
	^self elementType alignof
    ]

    dereferencedType [
	<category: 'private'>
	^self type elementType
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	"If they want to store the receiver with #at:put:, they store the
	 address (of the first character) without dereferencing the pointer."

	<category: 'private'>
	^CLong cObjStoredType
    ]

    cObjStoredValue [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	"If they want to store the receiver with #at:put:, they
	 store the address without dereferencing the pointer."

	<category: 'private'>
	^self address
    ]
]

