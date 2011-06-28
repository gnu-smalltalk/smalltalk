"======================================================================
|
|   Set Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001
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



HashedCollection subclass: Set [
    
    <shape: #pointer>
    <category: 'Collections-Unordered'>
    <comment: 'I am the typical set object; I also known how to do arithmetic
on my instances.'>

    & aSet [
	"Compute the set intersection of the receiver and aSet."

	<category: 'arithmetic'>
	| intersectionSet |
	intersectionSet := self copyEmpty: self size.
	self size < aSet size 
	    ifTrue: 
		[self 
		    do: [:elem | (aSet includes: elem) ifTrue: [intersectionSet add: elem]]]
	    ifFalse: 
		[aSet 
		    do: [:elem | (self includes: elem) ifTrue: [intersectionSet add: elem]]].
	^intersectionSet
    ]

    + aSet [
	"Compute the set union of the receiver and aSet."

	<category: 'arithmetic'>
	| unionSet |
	unionSet := self copy.
	unionSet addAll: aSet.
	^unionSet
    ]

    - aSet [
	"Compute the set difference of the receiver and aSet."

	<category: 'arithmetic'>
	| differenceSet |
	differenceSet := self copyEmpty: self size.
	self 
	    do: [:elem | (aSet includes: elem) ifFalse: [differenceSet add: elem]].
	^differenceSet
    ]

    < aSet [
	"Answer whether the receiver is a strict subset of aSet"

	<category: 'comparing'>
	self size < aSet size 
	    ifFalse: [^false]
	    ifTrue: [self do: [:elem | (aSet includes: elem) ifFalse: [^false]]].
	^true
    ]

    <= aSet [
	"Answer whether the receiver is a subset of aSet"

	<category: 'comparing'>
	self size <= aSet size 
	    ifFalse: [^false]
	    ifTrue: [self do: [:elem | (aSet includes: elem) ifFalse: [^false]]].
	^true
    ]

    > aSet [
	"Answer whether the receiver is a strict superset of aSet"

	<category: 'comparing'>
	^aSet < self
    ]

    >= aSet [
	"Answer whether the receiver is a superset of aSet"

	<category: 'comparing'>
	^aSet <= self
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject hash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject hash scramble bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element = anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]

    findObjectIndex: object [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'awful ST-80 compatibility hacks'>
	^self findIndex: object
    ]
]

