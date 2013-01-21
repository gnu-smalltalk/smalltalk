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



ArrayedCollection subclass: LargeArrayedCollection [
    | storage indices position size |
    
    <category: 'Collections-Sequenceable'>
    <comment: '
I am an abstract class specially designed to save
memory when lots of items have the same value.'>

    LargeArrayedCollection class >> new: anInteger [
	"Answer a new instance of the receiver, with room for anInteger elements."

	<category: 'instance creation'>
	^self basicNew initialize: anInteger
    ]

    at: anIndex [
	"Answer the anIndex-th item of the receiver."

	<category: 'accessing'>
	| subpart |
	self checkIndex: anIndex.
	subpart := self atSubpart: anIndex.
	subpart isNil ifTrue: [^self defaultElement].
	^storage at: anIndex - subpart first + subpart firstIndex
    ]

    at: anIndex put: anObject [
	"Replace the anIndex-th item of the receiver with anObject."

	<category: 'accessing'>
	| subpart |
	self checkIndex: anIndex.

	"Reset compression flag"
	position < 0 ifTrue: [position := position negated].
	subpart := self atPutSubpart: anIndex.
	subpart isNil 
	    ifTrue: 
		[self addToStorage: anObject.
		indices add: (Kernel.LargeArraySubpart 
			    first: anIndex
			    last: anIndex
			    index: position - 1).
		^anObject].

	"The item was not a nil one"
	subpart last >= anIndex 
	    ifTrue: 
		[^storage at: anIndex - subpart first + subpart firstIndex put: anObject].
	self addToStorage: anObject.
	subpart lastIndex = (position - 2) 
	    ifTrue: 
		["Extend the last subpart we created"

		subpart grow]
	    ifFalse: 
		["Create a new subpart."

		indices add: (Kernel.LargeArraySubpart 
			    first: anIndex
			    last: anIndex
			    index: position - 1)].
	^anObject
    ]

    compress [
	"Arrange the representation of the array for maximum memory saving."

	<category: 'accessing'>
	| newStorage newIndices last startOfNils trailingNils |
	position < 0 ifTrue: [^self].
	newStorage := WriteStream on: (self newCollection: self size // 100 + 10).
	newIndices := WriteStream on: (Array new: self size // 1000 + 10).

	"This algorithm is complicated to code but intuitive.  Read it slowly
	 and follow its rhythm..."
	indices do: 
		[:each | 
		"First, do a pass on the indices, searching for spans of nils
		 that can be removed from the array."

		| oldPosition i element |
		startOfNils := i := each firstIndex.
		[i <= each lastIndex] whileTrue: 
			[element := storage at: i.
			i := i + 1.
			element == self defaultElement ifFalse: [startOfNils := i].
			i - startOfNils >= self costOfNewIndex 
			    ifTrue: 
				["Find the end of this run of nil elements, and
				 remove the nils from the start of the subpart"

				[i <= each lastIndex and: [(storage at: i) == self defaultElement]] 
				    whileTrue: [i := i + 1].

				"Create a new part that spans until the start of the nils"
				self 
				    from: each firstIndex
				    to: startOfNils - 1
				    putOn: newStorage.
				last := each cutAt: startOfNils.
				newIndices nextPut: last.
				each removeFirst: i - each firstIndex.
				startOfNils := i]].
		startOfNils <= each lastIndex 
		    ifTrue: [each removeLast: each lastIndex - startOfNils + 1].

		"Now check whether we can merge the last LargeArraySubpart and
		 this one"
		last isNil 
		    ifFalse: 
			[each first - last last <= self costOfNewIndex 
			    ifTrue: 
				[newStorage next: each first - last last - 1 put: self defaultElement.
				last growBy: each last - last last]
			    ifFalse: [last := nil]].

		"Anyway, add the items to the newStorage"
		oldPosition := newStorage position + 1.
		self 
		    from: each firstIndex
		    to: each lastIndex
		    putOn: newStorage.

		"Then add a new LargeArraySubpart if necessary"
		(last isNil and: [each lastIndex >= each firstIndex]) 
		    ifTrue: 
			[each relocateTo: oldPosition.
			newIndices nextPut: each.
			last := each]].
	indices := newIndices contents asSortedCollection.
	storage := newStorage contents.
	position := newStorage size negated
    ]

    = aLargeArray [
	"Answer whether the receiver and aLargeArray have the same contents"

	<category: 'basic'>
	self class == aLargeArray class ifFalse: [^false].
	self == aLargeArray ifTrue: [^true].
	self compress.
	aLargeArray compress.
	^indices = aLargeArray indices and: [storage = aLargeArray storage]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'basic'>
	self compress.
	^storage hash
    ]

    size [
	"Answer the maximum valid index for the receiver"

	<category: 'basic'>
	^size
    ]

    addToStorage: anObject [
	"Add anObject to the storage, possibly growing it if necessary."

	<category: 'private'>
	position > storage size 
	    ifTrue: 
		[storage := (self newCollection: storage size * 2)
			    replaceFrom: 1
				to: storage size
				with: storage
				startingAt: 1;
			    yourself].
	storage at: position put: anObject.
	position := position + 1.
	^anObject
    ]

    atSubpart: index [
	"Private - Perform a binary search on the indices, searching for
	 a LargeArraySubpart referring to index."

	<category: 'private'>
	| i j last mid element |
	i := 1.
	j := last := indices size.
	[i > j] whileFalse: 
		[mid := (i + j + 1) // 2.
		element := indices at: mid.
		index > element last 
		    ifTrue: [i := mid + 1]
		    ifFalse: [index < element first ifTrue: [j := mid - 1] ifFalse: [^element]]].
	^nil
    ]

    atPutSubpart: index [
	"Private - Perform a binary search on the indices, searching for
	 a LargeArraySubpart referring to index or (if it cannot be found)
	 to index - 1."

	<category: 'private'>
	| i j last mid element |
	i := 1.
	j := last := indices size.
	[i > j] whileFalse: 
		[mid := (i + j + 1) // 2.
		element := indices at: mid.
		index > element last 
		    ifTrue: 
			["Answer a LargeArraySubpart to be extended"

			index = (element last + 1) 
			    ifTrue: 
				[(j = last or: [(indices at: mid + 1) first > index]) 
				    ifTrue: [^element]
				    ifFalse: [^indices at: mid + 1]].

			"Discard up to this element"
			i := mid + 1]
		    ifFalse: [index < element first ifTrue: [j := mid - 1] ifFalse: [^element]]].
	^nil
    ]

    checkIndex: index [
	"Check if the given index is valid"

	<category: 'private'>
	index isInteger 
	    ifFalse: [^SystemExceptions.WrongClass signalOn: index mustBe: Integer].
	index < 1 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
	index > self size 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index]
    ]

    from: first to: last putOn: newStorage [
	"Store on newStorage every item of the current storage from the first-th
	 to the last-th"

	<category: 'private'>
	storage 
	    from: first
	    to: last
	    do: [:element | newStorage nextPut: element]
    ]

    indices [
	<category: 'private'>
	^indices
    ]

    storage [
	<category: 'private'>
	^storage
    ]

    costOfNewIndex [
	"Answer the maximum number of consecutive items set to the defaultElement
	 that can be present in a compressed array."

	<category: 'private-abstract'>
	^5
    ]

    defaultElement [
	"Answer the value which is hoped to be the most common in the array"

	<category: 'private-abstract'>
	^nil
    ]

    newCollection: size [
	<category: 'private-abstract'>
	self subclassResponsibility
    ]

    initialize: mySize [
	"Initialize the receiver's state"

	<category: 'private-initialization'>
	indices := SortedCollection new: mySize // 1000 + 10.
	storage := self newCollection: mySize // 100 + 10.
	size := mySize.
	position := -1
    ]
]
