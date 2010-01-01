"======================================================================
|
|   Array Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2008,2009
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



ArrayedCollection subclass: Array [
    
    <shape: #pointer>
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances are objects that have array-like properties: they are directly 
indexable by integers starting at 1, and they are fixed in size.  I inherit
object creation behavior messages such as #with:, as well as iteration
and general access behavior from SequenceableCollection.'>

    Array class >> from: anArray [
	"Answer anArray, which is expected to be an array specified with a
	 brace-syntax expression per my inherited protocol."

	<category: 'instance creation'>
	^anArray
    ]

    at: anIndex ifAbsent: aBlock [
	"Answer the index-th indexed instance variable of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicAt>
	^self checkIndexableBounds: anIndex ifAbsent: aBlock
    ]

    printOn: aStream [
	"Print a representation for the receiver on aStream"

	<category: 'printing'>
	aStream nextPut: $(.
	self do: 
		[:elt | 
		elt printOn: aStream.
		aStream space].
	aStream nextPut: $)
    ]

    isLiteralObject [
	"Answer whether the receiver is expressible as a Smalltalk literal."

	<category: 'printing'>
	^self isReadOnly not
    ]

    replaceFrom: start to: stop with: byteArray startingAt: replaceStart [
	"Replace the characters from start to stop with new characters whose
	 ASCII codes are contained in byteArray, starting at the replaceStart
	 location of byteArray"

	<category: 'built ins'>
	<primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
	^super 
	    replaceFrom: start
	    to: stop
	    with: byteArray
	    startingAt: replaceStart
    ]

    storeLiteralOn: aStream [
	"Store a Smalltalk literal compiling to the receiver on aStream"

	<category: 'printing'>
	self class == Array ifFalse: [ ^super storeLiteralOn: aStream ].
	aStream nextPut: $#.
	aStream nextPut: $(.
	self do: 
		[:elt | 
		elt storeLiteralOn: aStream.
		aStream space].
	aStream nextPut: $)
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'printing'>
	self class == Array ifFalse: [ ^super storeOn: aStream ].
	self storeLiteralOn: aStream.
	self isReadOnly ifFalse: [aStream nextPutAll: ' copy']
    ]

    multiBecome: anArray [
	"Transform every object in the receiver in each corresponding
	 object in anArray. anArray and the receiver must have the same
	 size"

	<category: 'mutating objects'>
	| index |
	index := 0.
	^self collect: 
		[:object | 
		index := index + 1.
		object become: (anArray at: index)]
    ]

    isArray [
	<category: 'testing'>
	^true
    ]
]

