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



CPtr subclass: CString [
    
    <category: 'Language-C interface'>
    <comment: 'Technically, CString is really a pointer to CChar.  However, it can be
very useful as a distinct datatype because it is a separate datatype
in Smalltalk, so we allow developers to express their semantics more
precisely by using a more descriptive type.

Note that like CChar is a pointer to char, CString is actually a *pointer*
to string: a char ** in C terms.  If you need to take a String out of a
char *, use CChar>>#asString.

In general, I behave like a cross between an array of characters and a pointer
to a character.  I provide the protocol for both data types.  My #value
method returns a Smalltalk String, as you would expect for a scalar datatype.
'>

    CString class >> value: anObject [
	"Answer a newly allocated CObject containing the passed value,
	 anObject. Remember to call #addToBeFinalized if you want the
	 CObject to be automatically freed"

	<category: 'instance creation'>
	| cObject |
	cObject := self type new.
	cObject value: anObject.
	^cObject
    ]

    CString class >> type [
	"Answer a CType for the receiver---for example, CByteType if
	 the receiver is CByte."

	<category: 'instance creation'>
	^CStringType
    ]

    CString class >> cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'accessing'>
	^8
    ]

    cObjStoredType [
	"Private - Provide a conversion from a CObject to a Smalltalk object
	 to be stored by #at:put:"

	<category: 'accessing'>
	^8
    ]

    value [
	"Answer the value the receiver is pointing to. The exact returned
	 value depends on the receiver's class"

	<category: 'accessing'>
	^self at: 0 type: 8
    ]

    value: aValue [
	"Set the receiver to point to the value, aValue. The exact meaning
	 of aValue depends on the receiver's class"

	<category: 'accessing'>
	self 
	    at: 0
	    put: aValue
	    type: 8
    ]
]

