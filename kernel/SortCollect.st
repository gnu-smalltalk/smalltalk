"======================================================================
|
|   SortedCollection Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006
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


OrderedCollection variableSubclass: #SortedCollection
		  instanceVariableNames: 'lastOrdered sorted sortBlock'
		  classVariableNames: 'DefaultSortBlock Marker'
		  poolDictionaries: ''
		  category: 'Collections-Sequenceable'
!

SortedCollection comment:
'I am a collection of objects, stored and accessed according to some
sorting criteria.  I store things using heap sort and quick sort.  My
instances have a comparison block associated with them; this block
takes two arguments and is a predicate which returns true if the first
argument should be sorted earlier than the second.  The default block
is [ :a :b | a <= b ], but I will accept any block that conforms to the
above criteria -- actually any object which responds to #value:value:.' !


!SortedCollection class methodsFor: 'hacking'!

defaultSortBlock
    "Answer a default sort block for the receiver."
    "This is a clean block, so a single BlockClosure is used all the time."
    ^[ :a :b | a <= b ]
! !


!SortedCollection class methodsFor: 'instance creation'!

new
    "Answer a new collection with a default size and sort block"
    ^self sortBlock: self defaultSortBlock
!

new: aSize
    "Answer a new collection with a default sort block and the given size"
    ^(super new: aSize) setSortBlock: self defaultSortBlock
!

sortBlock: aSortBlock
    "Answer a new collection with a default size and the given sort block"
    ^super new setSortBlock: aSortBlock

! !



!SortedCollection methodsFor: 'disabled'!

addFirst: anObject
    self shouldNotImplement
!

addLast: anObject
    self shouldNotImplement
!

at: index put: anObject
    self shouldNotImplement
!

add: anObject afterIndex: i
    self shouldNotImplement
!

addAll: aCollection afterIndex: i
    self shouldNotImplement
!

addAllFirst: aCollection
    self shouldNotImplement
!

addAllLast: aCollection
    self shouldNotImplement
! !


!SortedCollection methodsFor: 'basic'!

last
    "Answer the last item of the receiver"
    lastOrdered = lastIndex ifFalse: [
	sorted ifTrue: [ self merge ] ifFalse: [ self makeHeap ].
    ].
    ^sorted
	ifTrue: [ self basicAt: lastIndex ]
	ifFalse: [ self basicAt: firstIndex ]
!

removeLast
    "Remove an object from the end of the receiver. Fail if the receiver
     is empty"

    lastOrdered = lastIndex ifFalse: [
	sorted ifTrue: [ self merge ] ifFalse: [ self makeHeap ].
    ].
    sorted ifFalse: [ self percolateDown ].
    ^self basicRemoveLast
!

sortBlock
    "Answer the receiver's sort criteria"
    ^sortBlock
!

sortBlock: aSortBlock
    "Change the sort criteria for a sorted collection, resort the elements of 
    the collection, and return it."

    sortBlock := aSortBlock fixTemps.
    self sortFrom: firstIndex to: lastIndex.
    sorted := true.
    lastOrdered := lastIndex.
    ^self
! !


!SortedCollection methodsFor: 'saving and loading'!

postLoad
    "Restore the default sortBlock if it is nil"
    sortBlock isNil ifTrue: [ sortBlock := self class defaultSortBlock ]
!

preStore
    "Store the default sortBlock as nil"
    sortBlock == self class defaultSortBlock ifTrue: [ sortBlock := nil ]
! !


!SortedCollection methodsFor: 'enumerating'!

beConsistent
    "Prepare the receiver to be walked through with #do: or another
     enumeration method."
    lastOrdered < firstIndex ifTrue: [
	self sortFrom: firstIndex to: lastIndex.
	sorted := true.
	lastOrdered := lastIndex.
	^self
    ].

    lastOrdered = lastIndex ifFalse: [
	sorted ifTrue: [ self merge ] ifFalse: [ self makeHeap ].
    ].
    sorted ifFalse: [ self sortHeap ].
! !


!SortedCollection methodsFor: 'searching'!

indexOf: anObject startingAt: index ifAbsent: aBlock
    "Answer the first index > anIndex which contains anElement.
     Invoke exceptionBlock and answer its result if no item is found"

    | i j |
    (index < 1) | (index > self size) ifTrue: [
	"If index is just past the end of the collection, don't raise
	 an error (this is the most generic solution that avoids that
	 #indexOf: fails when the collection is empty."
	index = (self size + 1)
	    ifTrue: [ ^aBlock value ]
	    ifFalse: [ ^self checkIndexableBounds: index ]
    ].

    self beConsistent.
    i := self
	binarySearch: anObject
	low: index + firstIndex - 1
	high: lastIndex.

    i isNil ifTrue: [ ^aBlock value ].

    j := i - firstIndex + 1.
    [ j ~= index and: [ (self basicAt: i - 1) = anObject ] ]
	whileTrue: [ i := i - 1. j := j - 1 ].

    ^j
!

includes: anObject
    "Private - Answer whether the receiver includes an item which is
     equal to anObject"

    self beConsistent.

    ^(self
	binarySearch: anObject
	low: firstIndex
	high: lastIndex) notNil
!

occurrencesOf: anObject
    "Answer how many occurrences of anObject can be found in the receiver"

    "Find first the index of 'anObject' and then look at the both sides to
     count repetitions of 'anObject', if there are."

    | upper lower max count |
    self beConsistent.

    upper := self
	binarySearch: anObject
	low: firstIndex
	high: lastIndex.

    upper isNil ifTrue: [ ^0 ].
    lower := upper - 1.
    max := self size.

    [ lower > 1 and: [ (self at: lower) = anObject ] ]
	whileTrue: [ lower := lower - 1 ].

    [ upper < max and: [ (self at: upper) = anObject ] ]
	whileTrue: [ upper := upper + 1 ].

    ^upper - lower - 1
! !


!SortedCollection methodsFor: 'copying'!

copyEmpty: newSize
    "Answer an empty copy of the receiver, with the same sort block as the
     receiver"
    ^(super copyEmpty: newSize) setSortBlock: sortBlock
! !



!SortedCollection methodsFor: 'private methods'!

basicRemoveAtIndex: anIndex
    "Remove the object at index anIndex from the receiver. Fail if the
     index is out of bounds." 

    | answer |
    answer := super basicRemoveAtIndex: anIndex.

    "Ensure the invariant that lastOrdered <= lastIndex, otherwise
     remove+add would leave lastIndex = lastOrdered even if the add was
     done out of order.  Unlike lastOrdered := lastOrdered - 1, this works
     even if there was an exception and execution resumed here."
    lastOrdered := lastIndex.
    ^answer
!

copyEmptyForCollect
    "Answer an empty copy of the receiver, with the class answered by the
     collect: method."
    ^OrderedCollection new: self basicSize
!

initIndices
    firstIndex := 1.
    lastIndex := 0.
    sorted := false.
    lastOrdered := 0.
!

makeRoomLastFor: n
    "Private - Make room for n elements at the end of the collection"

    (lastIndex + n) > self basicSize
	ifTrue: [
	    self
		growBy: (n max: self growSize)
		shiftBy: 1 - firstIndex
	]
!

setSortBlock: aSortBlock
    sortBlock := aSortBlock fixTemps
! !


!SortedCollection methodsFor: 'private - heap management'!

buildHeap
    "Construct a heap from scratch out of the elements in the collection"

    | parentIndex childIndex heapSize parent child childB delta |

    delta := firstIndex - 1.
    heapSize := lastIndex - delta.
    (self size + 1) // 2 to: 1 by: -1 do: [ :start |
	"Reorder the heap"
	parentIndex := start.
	childIndex := parentIndex + parentIndex.
	parent := self basicAt: delta + parentIndex.

	[   childIndex > heapSize or: [
		"Pick the greatest of the two children"
		child := self basicAt: delta + childIndex.
		childIndex = heapSize ifFalse: [
		    childB := self basicAt: delta + childIndex + 1.
		    (self sortBlock value: child value: childB) ifTrue: [
			child := childB.
			childIndex := childIndex + 1
		    ]
		].
	
		self sortBlock value: child value: parent
	]] whileFalse: [
	    "The parent is less than the child -- so the child is actually
	    meant to be the parent."
	    self basicAt: delta + childIndex put: parent.
	    self basicAt: delta + parentIndex put: child.
	    parentIndex := childIndex.
	    childIndex := childIndex + childIndex.
	]
    ]
!

makeHeap
    "Construct a heap out of the elements in the collection"
    | added size |
    
    "If k elements are to be added to a n-k elements heap, rebuilding the
     heap from scratch is O(n) and adding the items is O(k log n)."
    added := lastIndex - lastOrdered.
    size := self size.
    added asFloatD * size asFloatD ln < size
	ifTrue: [ added timesRepeat: [ self percolateUp ] ]
	ifFalse: [ self buildHeap ].

    lastOrdered := lastIndex.
    sorted := false.
    ^self
!

sortHeap
    "Make a sorted collection out of the elements in the heap."
    self size - 1 timesRepeat: [ self percolateDown ].
    lastOrdered := lastIndex.
    sorted := true.
!

percolateUp
    "Increment lastOrdered; put the item at the new lastOrdered index
     into the heap."

    | holeIndex parentIndex parent item |
    lastOrdered := lastOrdered + 1.
    holeIndex := lastOrdered - firstIndex.
    item := self basicAt: lastOrdered.

    [ holeIndex > 0 and: [
	parentIndex := holeIndex // 2.
	sortBlock
	    value: (parent := self basicAt: firstIndex + parentIndex)
	    value: item
    ]]	whileTrue: [
	self basicAt: firstIndex + holeIndex put: parent.
	holeIndex := parentIndex.
    ].

    self basicAt: firstIndex + holeIndex put: item!

percolateDown
    "Remove the least item in the ordered part of the collection
     from the heap; decrement lastOrdered and store the item in
     the previous value of lastOrdered."

    | parentIndex childIndex heapSize child childB parent delta |

    "Put the highest item in lastOrdered and decrement the size of the heap"
    self swap: lastOrdered with: firstIndex.
    lastOrdered := lastOrdered - 1.

    "Reorder the heap"
    parentIndex := 1.
    childIndex := 2.
    delta := firstIndex - 1.
    heapSize := lastOrdered - delta.
    parent := self basicAt: delta + parentIndex.

    [   childIndex > heapSize ifTrue: [ ^self ].
	
	"Pick the greatest of the two children"
	child := self basicAt: delta + childIndex.
	childIndex = heapSize ifFalse: [
	    childB := self basicAt: delta + childIndex + 1.
	    (self sortBlock value: child value: childB) ifTrue: [
		child := childB.
		childIndex := childIndex + 1
	    ]
	].
	
	self sortBlock value: child value: parent
    ] whileFalse: [
	"The parent is less than the child -- so the child is actually
	 meant to be the parent."
	self basicAt: delta + childIndex put: parent.
	self basicAt: delta + parentIndex put: child.
	parentIndex := childIndex.
	childIndex := childIndex + childIndex.
    ]
! !



!SortedCollection methodsFor: 'private methods - sorting'!

compare: elementA with: elementB
    "Compare the two objects according to the sortBlock, answering -1,
     0 or 1 depending on whether elementA sorts before, equally, or after
     elementB.  Looking for equality is important for a correct
     implementation of #includes:; for example try

	| a sc |
	a := #('aa' 'ac' 'ab' 'bc' 'bb' 'ba' 'cc' 'ca' 'cb').
	sc := a asSortedCollection: [ :x :y | x first <= y first ].
	^a allSatisfy: [ :each | sc includes: each ]

     On old versions of GNU Smalltalk (up to 1.96) which used a naive
     binary search, this failed because the sort-block introduced a
     partial ordering: object can be sort-block-equal even if their are
     not equal according to #~=."

    | less greater |
    less := sortBlock value: elementA value: elementB.
    greater := sortBlock value: elementB value: elementA.
    ^less == greater
	ifTrue: [ 0 ]
	ifFalse: [
	    less ifTrue: [ -1 ] ifFalse: [ 1 ] ]
!

swap: indexA ifBefore: indexB
    | a b |
    (sortBlock
	value: (a := self basicAt: indexA)
	value: (b := self basicAt: indexB))
	    ifTrue: [
		self basicAt: indexA put: b.
		self basicAt: indexB put: a
	    ]
!

swap: indexA ifAfter: indexB
    | a b |
    (sortBlock
	value: (a := self basicAt: indexA)
	value: (b := self basicAt: indexB))
	    ifFalse: [
		self basicAt: indexA put: b.
		self basicAt: indexB put: a
	    ]
!

swap: anIndex with: anotherIndex
    "Private - Swap the item at index anIndex with the item at index
     another index"

    | saved |
    saved := self basicAt: anIndex.
    self basicAt: anIndex put: (self basicAt: anotherIndex).
    self basicAt: anotherIndex put: saved
!

merge
    "Add all the elements in aCollection to the receiver in their proper
     places"

    | i add aCollection delta |
    self sortFrom: lastOrdered + 1 to: lastIndex.

    aCollection := (lastOrdered + 1 to: lastIndex)
	collect: [ :each | self basicAt: each ].

    "Merge elements into the collection. We do binary searches on the
     not yet sorted part of the collection to find where to add the
     element. This economizes on expensive sort block evaluations."

    add := aCollection size.
    i := lastIndex - add.
    (aCollection asSortedCollection: self sortBlock) reverseDo: [:element |
	| newIndex |
	newIndex := self insertionIndexFor: element upTo: i.

	[ i >= newIndex ] whileTrue: [
	    self basicAt: i + add put: (self basicAt: i).
	    i := i - 1.
	].
	self basicAt: i + add put: element.
	add := add - 1
    ].

    lastOrdered := lastIndex.
    sorted := true.
    ^self
!

median: ia median: ib median: ic
    "Private - Calculate the middle of a, b and c. Needed for selecting
     the quicksort's pivot item"
    | a b c |
    a := self basicAt: ia.
    b := self basicAt: ib.
    c := self basicAt: ic.
    (sortBlock value: a value: b)
	ifTrue: [
	    (sortBlock value: b value: c) ifTrue: [ ^ib ].
	    (sortBlock value: a value: c) ifTrue: [ ^ic ] ifFalse: [ ^ia ]
	]
	ifFalse: [
	    (sortBlock value: a value: c) ifTrue: [ ^ia ].
	    (sortBlock value: b value: c) ifTrue: [ ^ic ] ifFalse: [ ^ib ]
	]
!

sortFrom: first to: last
    "Private - Perform a quicksort on the indexed variables
     from the first-th to the last-th (using basicAt: indices!). Recursive."
    | pivot mid smaller larger |

    last - first < 2 ifTrue: [
	last > first ifTrue: [ self swap: first ifAfter: last ].
	^self
    ].

    "First we pick a partititioning element.  We must find one
     that is approximately the median of the values, but we must do
     that fast; we use the median of the first, last and middle one,
     which would require a very weirdly arranged array for worst case
     performance.
     We also have to to put it in the middle."

    mid := (first + last) // 2.
    self swap: first ifAfter: mid.
    self swap: mid ifAfter: last.
    self swap: first ifAfter: last.

    pivot := self basicAt: mid.
    smaller := first.
    larger := last.
    [ 
	[ (smaller <= last) and: "self[smaller] <= pivot"
	    [ sortBlock value: (self basicAt: smaller) value: pivot ] ]
	    whileTrue: [ smaller := smaller + 1 ].

	[ (larger >= first) and: "self[larger] >= pivot"
	    [ sortBlock value: pivot value: (self basicAt: larger) ] ]
	    whileTrue: [ larger := larger - 1 ].

	smaller < larger
    ]   whileTrue: [
	self swap: smaller with: larger.
	smaller := smaller + 1.
	larger := larger - 1.
    ].

    smaller > larger ifFalse: [
	smaller := smaller + 1.
	larger := larger - 1.
    ].

    first < larger ifTrue: [ self sortFrom: first to: larger ].
    smaller < last ifTrue: [ self sortFrom: smaller to: last ]
!

moveElementsFrom: i by: add toMerge: element
    "Private - Move by add spaces all the elements before the i-th until
     we have created a place to insert element. Answer the new i (element will
     be inserted at position i + add)."

    | newIndex |

    "First do a binary search to find where to add the element.
     This economizes on expensive sort block evaluations."
    newIndex := self insertionIndexFor: element upTo: i.

    i to: newIndex by: -1 do: [ :index |
	 self basicAt: index + add put: (self basicAt: index).
    ].
    ^newIndex - 1

"   | anObject |
    i to: firstIndex by: -1 do: [ :index |
	anObject := self basicAt: index.
	(sortBlock value: anObject value: element)
	    ifTrue: [ ^index ]
	    ifFalse: [ self basicAt: index + add put: anObject ]
    ].
    ^firstIndex - 1 "
! !


!SortedCollection methodsFor: 'private methods - searching'!

binarySearch: anObject low: low high: high
    "Private - Perform a binary search on the receiver, searching between
     indexes i and j (indexes are referenced with #basicAt:). If anObject
     is not found, answer nil, else answer one of the indices containing
     anObject."

    "I hate this use of exception handling.  Alas, according to the
     ANSI standard, the methods that use binarySearch must not fail
     even if the sort block does not support the class of their arguments.
     In other words, binarySearch must answer nil if there is an error
     in the sort block."

    ^[
	self doBinarySearch: anObject low: low high: high
    ] on: Error do: [ :sig | sig return: nil ]
!

doBinarySearch: anObject low: low high: high
    "Private - This is the worker method for #binarySearch:low:high:.
     The algorithm is complex enough that I preferred to split it in
     two when exception handling added yet another level of indentation.
     Besides it also helps speed not having to access arguments in outer
     contexts."

    | i j mid element compare |
    i := low.
    j := high.

    [ i > j ifTrue: [ ^nil ].

 	mid := (i + j + 1) // 2.
	element := self basicAt: mid.
	compare := self compare: anObject with: element.

	compare = 0
    ] whileFalse: [

	compare < 0
	    ifTrue: [ j := mid - 1]
	    ifFalse: [ i := mid + 1 ].
    ].

    "We've found an element that is `sort-block-equal' to the one
     to be searched.  Search in the two directions that is really
     equal to it"

    mid to: low by: -1 do: [ :goDown | 
	element := self basicAt: goDown.
	(self compare: anObject with: element) = 0
	    ifFalse: [
		"Exhausted the sort-block-equal elements in this direction,
		 now look in the other!"
		mid to: high do: [ :goUp | 
		    element := self basicAt: goUp.
		    (self compare: anObject with: element) = 0
			ifFalse: [ ^nil ].

		    "Another sort-block equal element to test against."
		    anObject = element ifTrue: [ ^goUp ].
		].
		^nil
	    ].

	"Another sort-block equal element to test against."
	anObject = element ifTrue: [ ^goDown ].
    ].

    "All the elements in this direction were only sort-block-equal,
     now look in the other!"
    mid to: high do: [ :goUp | 
	element := self basicAt: goUp.
	(self compare: anObject with: element) = 0
	    ifFalse: [ ^nil ].

	"Another sort-block equal element to test against."
	anObject = element ifTrue: [ ^goUp ].
    ].
    ^nil
!

insertionIndexFor: anObject upTo: highestIndex
    "Private - Perform a binary search on the receiver, searching between
     indexes firstIndex and highestIndex for an element which comes just
     after anObject (according to the sort block of course)."

    | low high mid |

    low := firstIndex.
    high := highestIndex.
    [mid := (high + low) // 2. low > high] whileFalse: [
	(sortBlock value: (self basicAt: mid) value: anObject)
	    ifTrue: [low := mid + 1]
	    ifFalse: [high := mid - 1]
    ].
    ^low
! !
