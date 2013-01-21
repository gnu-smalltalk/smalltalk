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



CObject subclass: CScalar [
    
    <category: 'Language-C interface'>
    <comment: nil>

    CScalar class >> value: anObject [
	"Answer a newly allocated CObject containing the passed value,
	 anObject. Remember to call #addToBeFinalized if you want the
	 CObject to be automatically freed"

	<category: 'instance creation'>
	| cObject |
	cObject := self type new.
	cObject value: anObject.
	^cObject
    ]

    CScalar class >> gcValue: anObject [
	"Answer a newly allocated CObject containing the passed value,
	 anObject, in garbage-collected storage."

	<category: 'instance creation'>
	| cObject |
	cObject := self type gcNew.
	cObject value: anObject.
	^cObject
    ]

    CScalar class >> type [
	"Answer a CType for the receiver---for example, CByteType if
	 the receiver is CByte."

	<category: 'instance creation'>
	^self environment at: (self name , 'Type') asGlobalKey
    ]

    CScalar class >> cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'private'>
	self subclassResponsibility
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    value [
	"Answer the value the receiver is pointing to. The exact returned
	 value depends on the receiver's class"

	<category: 'accessing'>
	^self at: 0 type: self cObjStoredType
    ]

    value: aValue [
	"Set the receiver to point to the value, aValue. The exact meaning
	 of aValue depends on the receiver's class"

	<category: 'accessing'>
	self 
	    at: 0
	    put: aValue
	    type: self cObjStoredType
    ]
]

