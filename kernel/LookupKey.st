"======================================================================
|
|   LookupKey Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



Magnitude subclass: LookupKey [
    | key |
    
    <category: 'Language-Data types'>
    <comment: 'I represent a key for looking up entries in a data structure. Subclasses
of me, such as Association, typically represent dictionary entries.'>

    LookupKey class >> key: aKey [
	"Answer a new instance of the receiver with the given key and value"

	<category: 'basic'>
	^self new key: aKey
    ]

    key: aKey [
	"Set the receiver's key to aKey"

	<category: 'accessing'>
	key := aKey
    ]

    key [
	"Answer the receiver's key"

	<category: 'accessing'>
	^key
    ]

    < aLookupKey [
	"Answer whether the receiver's key is less than aLookupKey's"

	<category: 'testing'>
	^self key < aLookupKey key
    ]

    = aLookupKey [
	"Answer whether the receiver's key and value are the same as
	 aLookupKey's, or false if aLookupKey is not an instance of
	 the receiver"

	<category: 'testing'>
	^self class == aLookupKey class and: [self key = aLookupKey key]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'testing'>
	^key hash
    ]

    printOn: aStream [
	"Put on aStream a representation of the receiver"

	<category: 'printing'>
	aStream nextPut: $[.
	self key printOn: aStream.
	aStream nextPut: $]
    ]

    storeOn: aStream [
	"Put on aStream some Smalltalk code compiling to the receiver"

	<category: 'storing'>
	aStream nextPut: $(.
	aStream store: self class.
	aStream nextPutAll: ' key: '.
	self key storeOn: aStream.
	aStream nextPut: $)
    ]
]

