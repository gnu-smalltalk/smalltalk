"======================================================================
|
|   IdentityDictionary Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002
| Free Software Foundation, Inc.
| Written by Steve Byrne and Paolo Bonzini.
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



LookupTable subclass: IdentityDictionary [
    
    <shape: #pointer>
    <category: 'Collections-Keyed'>
    <comment: 'I am similar to LookupTable, except that I use the object identity
comparision message == to determine equivalence of indices.'>

    keysClass [
	"Answer the class answered by #keys"

	<category: 'private methods'>
	^IdentitySet
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject identityHash
    ]

    findElementIndex: anObject [
        "Tries to see where anObject can be placed as an indexed variable.
	 As soon as nil is found, the index of that slot is answered.
	 anObject also comes from an indexed variable."

        <category: 'private methods'>
        | index size element |
        "Sorry for the lack of readability, but I want speed... :-)"
        index := (anObject identityHash scramble bitAnd: (size := self primSize) - 1) + 1.
   
        [(element := self primAt: index) isNil
            ifTrue: [^index].
        index == size ifTrue: [index := 1] ifFalse: [index := index + 1]]
                repeat
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

