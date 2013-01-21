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



CType subclass: CScalarCType [
    
    <category: 'Language-C interface'>
    <comment: nil>

    storeOn: aStream [
	"Store Smalltalk code that compiles to the receiver"

	<category: 'storing'>
	aStream
	    print: self cObjectType;
	    nextPutAll: 'Type'
    ]

    valueType [
	"valueType is used as a means to communicate to the interpreter the
	 underlying type of the data.  For scalars, it is supplied by the
	 CObject subclass."

	<category: 'accessing'>
	^self cObjectType cObjStoredType
    ]
]

