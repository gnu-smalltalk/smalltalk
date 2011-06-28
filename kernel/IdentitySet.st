"======================================================================
|
|   IdentitySet Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001 Free Software Foundation, Inc.
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



Set subclass: IdentitySet [
    
    <shape: #pointer>
    <category: 'Collections-Unordered'>
    <comment: 'I am the typical set object; I can store any objects uniquely.  I
use the == operator to determine duplication of objects.'>

    identityIncludes: anObject [
	"Answer whether we include the anObject object; for IdentitySets
	 this is identical to #includes:"

	<category: 'testing'>
	^self includes: anObject
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject identityHash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element == anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]

