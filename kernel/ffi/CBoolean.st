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



CByte subclass: CBoolean [
    
    <category: 'Language-C interface'>
    <comment: 'I return true if a byte is not zero, false otherwise.'>

    CBoolean class >> type [
	"Answer a CType for the receiver"

	<category: 'conversion'>
	^CBooleanType
    ]

    value [
	"Get the receiver's value - answer true if it is != 0, false if it is 0."

	<category: 'accessing'>
	^super value > 0
    ]

    value: aBoolean [
	"Set the receiver's value - it's the same as for CBytes, but we
	 get a Boolean, not a Character"

	<category: 'accessing'>
	^super value: aBoolean asCBooleanValue
    ]
]

