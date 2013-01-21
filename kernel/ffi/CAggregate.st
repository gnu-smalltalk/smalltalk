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



CObject subclass: CAggregate [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CAggregate class >> sizeof [
	"Answer the receiver's instances size"

	"This is the closest possible guess for CArrays"

	<category: 'accessing'>
	^CPtrSize
    ]

    CAggregate class >> alignof [
	"Answer the receiver's instances required aligment"

	"This is the closest possible guess for CArrays"

	<category: 'accessing'>
	^CPtrSize
    ]

    elementType [
	"Answer the type over which the receiver is constructed."

	<category: 'accessing'>
	^self type elementType
    ]
]

