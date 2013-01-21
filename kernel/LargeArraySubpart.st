"=====================================================================
|
|   Variations on the Array class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2009 Free Software Foundation, Inc.
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



Namespace current: Kernel [

Magnitude subclass: LargeArraySubpart [
    | first last index |
    
    <category: 'Collections-Sequenceable'>
    <comment: '
This class is an auxiliary class used to store information
about a LargeArrayedCollection''s contents.  LargeArrayedCollections
store their items non-contiguously in a separate storage object, and
use a SortedCollection to map between indices in the array and indices
in the storage object; instances of this class represent a block of
indices that is stored contiguously in the storage object.'>

    LargeArraySubpart class >> first: first last: last index: index [
	"Answer a LargeArraySubpart which answers first, last, and index
	 when it is sent (respectively) #first, #last and #firstIndex."

	<category: 'instance creation'>
	^self new 
	    first: first
	    last: last
	    index: index
    ]

    < anObject [
	"Answer whether the receiver points to a part of the array that
	 is before anObject (this makes sense only if the receiver and
	 anObject are two LargeArraySubparts referring to the same
	 LargeArrayedCollection)."

	<category: 'comparing'>
	^self first < anObject first
    ]

    <= anObject [
	"Answer whether the receiver points to a part of the array that
	 is before anObject or starts at the same point (this makes sense
	 only if the receiver and anObject are two LargeArraySubparts
	 referring to the same LargeArrayedCollection)."

	<category: 'comparing'>
	^self first <= anObject first
    ]

    = anObject [
	"Answer whether the receiver and anObject are equal (assuming that
	 the receiver and anObject are two LargeArraySubparts
	 referring to the same LargeArrayedCollection, which the receiver
	 cannot check for)."

	<category: 'comparing'>
	^self first = anObject first
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'comparing'>
	^self first hash
    ]

    first: firstIndex last: lastIndex index: storagePosition [
	"Set up the receiver so that it answers first, last, and index
	 when it is sent (respectively) #first, #last and #firstIndex."

	<category: 'accessing'>
	first := firstIndex.
	last := lastIndex.
	index := storagePosition
    ]

    first [
	"Answer the index of the first item of the LargeArrayedCollection
	 that the receiver refers to."

	<category: 'accessing'>
	^first
    ]

    last [
	"Answer the index of the last item of the LargeArrayedCollection
	 that the receiver refers to."

	<category: 'accessing'>
	^last
    ]

    firstIndex [
	"Answer the index in the collection's storage object of the first
	 item of the LargeArrayedCollection that the receiver refers to."

	<category: 'accessing'>
	^index
    ]

    lastIndex [
	"Answer the index in the collection's storage object of the last
	 item of the LargeArrayedCollection that the receiver refers to."

	<category: 'accessing'>
	^index + last - first
    ]

    cutAt: position [
	"Answer a new LargeArraySubpart whose lastIndex is position - 1,
	 and apply a #removeFirst: to the receiver so that the firstIndex
	 becomes position"

	<category: 'modifying'>
	| newPart newFirst |
	newFirst := first + (position - index).
	newPart := self class 
		    first: first
		    last: newFirst - 1
		    index: index.
	first := newFirst.
	index := position.
	^newPart
    ]

    grow [
	"Add one to last and lastIndex"

	<category: 'modifying'>
	last := last + 1
    ]

    growBy: numberOfElements [
	"Add numberOfElements to last and lastIndex"

	<category: 'modifying'>
	last := last + numberOfElements
    ]

    relocateTo: position [
	"Move the firstIndex to position, and the lastIndex accordingly."

	<category: 'modifying'>
	index := position
    ]

    removeFirst: n [
	"Sum n to first and firstIndex, but leave last/lastIndex untouched"

	<category: 'modifying'>
	first := first + n.
	index := index + n
    ]

    removeLast: n [
	"Subtract n from last and lastIndex, but leave first/firstIndex untouched"

	<category: 'modifying'>
	last := last - n
    ]
]

]
