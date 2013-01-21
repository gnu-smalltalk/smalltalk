"======================================================================
|
|   SortedCollection Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2006,2008
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



OrderedCollection subclass: SortedCollection [
    | lastOrdered sorted sortBlock |
    
    <shape: #pointer>
    <category: 'Collections-Sequenceable'>
    <comment: 'I am a collection of objects, stored and accessed according to some
sorting criteria.  I store things using heap sort and quick sort.  My
instances have a comparison block associated with them; this block
takes two arguments and is a predicate which returns true if the first
argument should be sorted earlier than the second.  The default block
is [ :a :b | a <= b ], but I will accept any block that conforms to the
above criteria -- actually any object which responds to #value:value:.'>

    DefaultSortBlock := nil.
    Marker := nil.

    SortedCollection class >> defaultSortBlock [
	"Answer a default sort block for the receiver."

	"This is a clean block, so a single BlockClosure is used all the time."

	<category: 'hacking'>
	^[:a :b | a <= b]
    ]

    SortedCollection class >> new [
	"Answer a new collection with a default size and sort block"

	<category: 'instance creation'>
	^self sortBlock: self defaultSortBlock
    ]

    SortedCollection class >> new: aSize [
	"Answer a new collection with a default sort block and the given size"

	<category: 'instance creation'>
	^(super new: aSize) setSortBlock: self defaultSortBlock
    ]

    SortedCollection class >> sortBlock: aSortBlock [
	"Answer a new collection with a default size and the given sort block"

	<category: 'instance creation'>
	^super new setSortBlock: aSortBlock
    ]

    addFirst: anObject [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    addLast: anObject [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    at: index put: anObject [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    add: anObject afterIndex: i [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    addAll: aCollection afterIndex: i [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    addAllFirst: aCollection [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    addAllLast: aCollection [
	<category: 'disabled'>
	self shouldNotImplement
    ]

    do: aBlock [
        "Evaluate aBlock for all the elements in the collection"

        <category: 'enumerating'>
        self beConsistent.
	super do: aBlock
    ]

    first [
        "Answer the first item of the receiver"

        <category: 'accessing'>
        self beConsistent.
        ^ super first
    ]

    last [
	"Answer the last item of the receiver"

	<category: 'basic'>
	lastOrdered = lastIndex 
	    ifFalse: [sorted ifTrue: [self merge] ifFalse: [self makeHeap]].
	^sorted 
	    ifTrue: [self basicAt: lastIndex]
	    ifFalse: [self basicAt: firstIndex]
    ]

    at: anIndex [
        "Answer the anIndex-th item of the receiver"

        <category: 'accessing'>
        self beConsistent.
        ^ super at: anIndex
    ]

    at: anIndex put: anObject [
        "Store anObject at the anIndex-th item of the receiver, answer anObject"

        <category: 'accessing'>
        self beConsistent.
	super at: anIndex put: anObject
    ]

    removeFirst [
        "Remove an object from the start of the receiver. Fail if the receiver
         is empty"

        <category: 'removing'>
        self beConsistent.
        ^ super removeFirst
    ]

    removeLast [
	"Remove an object from the end of the receiver. Fail if the receiver
	 is empty"

	<category: 'basic'>
	lastOrdered = lastIndex 
	    ifFalse: [sorted ifTrue: [self merge] ifFalse: [self makeHeap]].
	sorted ifFalse: [self percolateDown].
	^self basicRemoveLast
    ]

    sort [
	"Sort the contents of the receiver according to the given
	 sort block, which accepts pair of items and returns true if
	 the first item is less than the second one.  Fails if the
         collections's sort block is not the same as the default sort
         block."
        <category: 'sorting'>
	self sortBlock == self class defaultSortBlock ifTrue: [^self].
	self shouldNotImplement
    ]

    sort: sortBlock [
	"Sort the contents of the receiver according to the given
	 sort block, which accepts pair of items and returns true if
	 the first item is less than the second one.  Fails if the
         sort block is not the same as the collection's sort block."
        <category: 'sorting'>
	self sortBlock == sortBlock ifTrue: [^self].
	self shouldNotImplement
    ]

    sortBlock [
	"Answer the receiver's sort criteria"

	<category: 'basic'>
	^sortBlock
    ]

    sortBlock: aSortBlock [
	"Change the sort criteria for a sorted collection, resort the elements of
	 the collection, and return it."

	<category: 'basic'>
	sortBlock := aSortBlock fixTemps.
	self sortFrom: firstIndex to: lastIndex.
	sorted := true.
	lastOrdered := lastIndex.
	^self
    ]

    postLoad [
	"Restore the default sortBlock if it is nil"

	<category: 'saving and loading'>
	sortBlock isNil ifTrue: [sortBlock := self class defaultSortBlock]
    ]

    preStore [
	"Store the default sortBlock as nil"

	<category: 'saving and loading'>
	sortBlock == self class defaultSortBlock ifTrue: [sortBlock := nil]
    ]

    beConsistent [
	"Prepare the receiver to be walked through with #do: or another
	 enumeration method."

	<category: 'enumerating'>
	lastOrdered < firstIndex 
	    ifTrue: 
		[self sortFrom: firstIndex to: lastIndex.
		sorted := true.
		lastOrdered := lastIndex.
		^self].
	lastOrdered = lastIndex 
	    ifFalse: [sorted ifTrue: [self merge] ifFalse: [self makeHeap]].
	sorted ifFalse: [self sortHeap]
    ]

    indexOf: anObject startingAt: index ifAbsent: aBlock [
	"Answer the first index > anIndex which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'searching'>
	| i j |
	index < 1 | (index > self size) 
	    ifTrue: 
		["If index is just past the end of the collection, don't raise
		 an error (this is the most generic solution that avoids that
		 #indexOf: fails when the collection is empty."

		index = (self size + 1) 
		    ifTrue: [^aBlock value]
		    ifFalse: [^self checkIndexableBounds: index]].
	self beConsistent.
	i := self 
		    binarySearch: anObject
		    low: index + firstIndex - 1
		    high: lastIndex.
	i isNil ifTrue: [^aBlock value].
	j := i - firstIndex + 1.
	[j ~= index and: [(self basicAt: i - 1) = anObject]] whileTrue: 
		[i := i - 1.
		j := j - 1].
	^j
    ]

    includes: anObject [
	"Private - Answer whether the receiver includes an item which is
	 equal to anObject"

	<category: 'searching'>
	self beConsistent.
	^(self 
	    binarySearch: anObject
	    low: firstIndex
	    high: lastIndex) notNil
    ]

    occurrencesOf: anObject [
	"Answer how many occurrences of anObject can be found in the receiver"

	"Find first the index of 'anObject' and then look at the both sides to
	 count repetitions of 'anObject', if there are."

	<category: 'searching'>
	| upper lower max count |
	self beConsistent.
	upper := self 
		    binarySearch: anObject
		    low: firstIndex
		    high: lastIndex.
	upper isNil ifTrue: [^0].
	lower := upper - 1.
	max := self size.
	[lower > 1 and: [(self at: lower) = anObject]] 
	    whileTrue: [lower := lower - 1].
	[upper < max and: [(self at: upper) = anObject]] 
	    whileTrue: [upper := upper + 1].
	^upper - lower - 1
    ]

    copyEmpty: newSize [
	"Answer an empty copy of the receiver, with the same sort block as the
	 receiver"

	<category: 'copying'>
	^(super copyEmpty: newSize) setSortBlock: sortBlock
    ]

    basicRemoveAtIndex: anIndex [
	"Remove the object at index anIndex from the receiver. Fail if the
	 index is out of bounds."

	<category: 'private methods'>
	| answer |
	self beConsistent.
	answer := super basicRemoveAtIndex: anIndex.

	"Ensure the invariant that lastOrdered <= lastIndex, otherwise
	 remove+add would leave lastIndex = lastOrdered even if the add was
	 done out of order.  Unlike lastOrdered := lastOrdered - 1, this works
	 even if there was an exception and execution resumed here."
	lastOrdered := lastIndex.
	^answer
    ]

    copyEmptyForCollect: size [
	"Answer an empty copy of the receiver, with the class answered by the
	 collect: method."

	<category: 'private methods'>
	^OrderedCollection new: size
    ]

    copyEmptyForCollect [
	"Answer an empty copy of the receiver, with the class answered by the
	 collect: method."

	<category: 'private methods'>
	^OrderedCollection new: self basicSize
    ]

    initIndices [
	<category: 'private methods'>
	firstIndex := 1.
	lastIndex := 0.
	sorted := false.
	lastOrdered := 0
    ]

    makeRoomLastFor: n [
	"Private - Make room for n elements at the end of the collection"

	<category: 'private methods'>
	lastIndex + n > self basicSize 
	    ifTrue: [self growBy: (n max: self growSize) shiftBy: 1 - firstIndex]
    ]

    setSortBlock: aSortBlock [
	<category: 'private methods'>
	sortBlock := aSortBlock fixTemps
    ]

    buildHeap [
	"Construct a heap from scratch out of the elements in the collection"

	<category: 'private - heap management'>
	| parentIndex childIndex heapSize parent child childB delta |
	delta := firstIndex - 1.
	heapSize := lastIndex - delta.
	(self size + 1) // 2 to: 1
	    by: -1
	    do: 
		[:start | 
		"Reorder the heap"

		parentIndex := start.
		childIndex := parentIndex + parentIndex.
		parent := self basicAt: delta + parentIndex.
		
		[childIndex > heapSize or: 
			["Pick the greatest of the two children"

			child := self basicAt: delta + childIndex.
			childIndex = heapSize 
			    ifFalse: 
				[childB := self basicAt: delta + childIndex + 1.
				(self sortBlock value: child value: childB) 
				    ifTrue: 
					[child := childB.
					childIndex := childIndex + 1]].
			self sortBlock value: child value: parent]] 
			whileFalse: 
			    ["The parent is less than the child -- so the child is actually
			     meant to be the parent."

			    self basicAt: delta + childIndex put: parent.
			    self basicAt: delta + parentIndex put: child.
			    parentIndex := childIndex.
			    childIndex := childIndex + childIndex]]
    ]

    makeHeap [
	"Construct a heap out of the elements in the collection"

	<category: 'private - heap management'>
	"If k elements are to be added to a n-k elements heap, rebuilding the
	 heap from scratch is O(n) and adding the items is O(k log n)."

	| added size |
	added := lastIndex - lastOrdered.
	size := self size.
	added asFloatD * size asFloatD ln < size 
	    ifTrue: [added timesRepeat: [self percolateUp]]
	    ifFalse: [self buildHeap].
	lastOrdered := lastIndex.
	sorted := false.
	^self
    ]

    sortHeap [
	"Make a sorted collection out of the elements in the heap."

	<category: 'private - heap management'>
	self size - 1 timesRepeat: [self percolateDown].
	lastOrdered := lastIndex.
	sorted := true
    ]

    percolateUp [
	"Increment lastOrdered; put the item at the new lastOrdered index
	 into the heap."

	<category: 'private - heap management'>
	| holeIndex parentIndex parent item |
	lastOrdered := lastOrdered + 1.
	holeIndex := lastOrdered - firstIndex.
	item := self basicAt: lastOrdered.
	
	[holeIndex > 0 and: 
		[parentIndex := (holeIndex - 1) // 2.
		sortBlock value: (parent := self basicAt: firstIndex + parentIndex)
		    value: item]] 
		whileTrue: 
		    [self basicAt: firstIndex + holeIndex put: parent.
		    holeIndex := parentIndex].
	self basicAt: firstIndex + holeIndex put: item
    ]

    percolateDown [
	"Remove the least item in the ordered part of the collection
	 from the heap; decrement lastOrdered and store the item in
	 the previous value of lastOrdered."

	<category: 'private - heap management'>
	"Put the highest item in lastOrdered and decrement the size of the heap"

	| parentIndex childIndex heapSize child childB parent delta |
	self basicSwap: lastOrdered with: firstIndex.
	lastOrdered := lastOrdered - 1.

	"Reorder the heap"
	parentIndex := 1.
	childIndex := 2.
	delta := firstIndex - 1.
	heapSize := lastOrdered - delta.
	parent := self basicAt: delta + parentIndex.
	
	[childIndex > heapSize ifTrue: [^self].

	"Pick the greatest of the two children"
	child := self basicAt: delta + childIndex.
	childIndex = heapSize 
	    ifFalse: 
		[childB := self basicAt: delta + childIndex + 1.
		(self sortBlock value: child value: childB) 
		    ifTrue: 
			[child := childB.
			childIndex := childIndex + 1]].
	self sortBlock value: child value: parent] 
		whileFalse: 
		    ["The parent is less than the child -- so the child is actually
		     meant to be the parent."

		    self basicAt: delta + childIndex put: parent.
		    self basicAt: delta + parentIndex put: child.
		    parentIndex := childIndex.
		    childIndex := childIndex + childIndex]
    ]

    compare: elementA with: elementB [
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

	<category: 'private methods - sorting'>
	| less greater |
	less := sortBlock value: elementA value: elementB.
	greater := sortBlock value: elementB value: elementA.
	^less == greater ifTrue: [0] ifFalse: [less ifTrue: [-1] ifFalse: [1]]
    ]

    basicSwap: indexA ifBefore: indexB [
	<category: 'private methods - sorting'>
	| a b |
	(sortBlock value: (a := self basicAt: indexA)
	    value: (b := self basicAt: indexB)) 
		ifTrue: 
		    [self basicAt: indexA put: b.
		    self basicAt: indexB put: a]
    ]

    basicSwap: indexA ifAfter: indexB [
	<category: 'private methods - sorting'>
	| a b |
	(sortBlock value: (a := self basicAt: indexA)
	    value: (b := self basicAt: indexB)) 
		ifFalse: 
		    [self basicAt: indexA put: b.
		    self basicAt: indexB put: a]
    ]

    basicSwap: anIndex with: anotherIndex [
	"Private - Swap the item at index anIndex with the item at index
	 another index"

	<category: 'private methods - sorting'>
	| saved |
	saved := self basicAt: anIndex.
	self basicAt: anIndex put: (self basicAt: anotherIndex).
	self basicAt: anotherIndex put: saved
    ]

    merge [
	"Add all the elements in aCollection to the receiver in their proper
	 places"

	<category: 'private methods - sorting'>
	| i add aCollection delta |
	self sortFrom: lastOrdered + 1 to: lastIndex.
	aCollection := (lastOrdered + 1 to: lastIndex) 
		    collect: [:each | self basicAt: each].

	"Merge elements into the collection. We do binary searches on the
	 not yet sorted part of the collection to find where to add the
	 element. This economizes on expensive sort block evaluations."
	add := aCollection size.
	i := lastIndex - add.
	(aCollection asSortedCollection: self sortBlock) reverseDo: 
		[:element | 
		| newIndex |
		newIndex := self insertionIndexFor: element upTo: i.
                self primReplaceFrom: newIndex + add to: i + add
                    with: self startingAt: newIndex.
		add := add - 1.
		self basicAt: newIndex + add put: element.
                i := newIndex - 1].
	lastOrdered := lastIndex.
	sorted := true.
	^self
    ]

    median: ia median: ib median: ic [
	"Private - Calculate the middle of a, b and c. Needed for selecting
	 the quicksort's pivot item"

	<category: 'private methods - sorting'>
	| a b c |
	a := self basicAt: ia.
	b := self basicAt: ib.
	c := self basicAt: ic.
	(sortBlock value: a value: b) 
	    ifTrue: 
		[(sortBlock value: b value: c) ifTrue: [^ib].
		(sortBlock value: a value: c) ifTrue: [^ic] ifFalse: [^ia]]
	    ifFalse: 
		[(sortBlock value: a value: c) ifTrue: [^ia].
		(sortBlock value: b value: c) ifTrue: [^ic] ifFalse: [^ib]]
    ]

    sortFrom: first to: last [
	"Private - Perform a quicksort on the indexed variables
	 from the first-th to the last-th (using basicAt: indices!). Recursive."

	<category: 'private methods - sorting'>
	| pivot mid smaller larger |
	last - first < 2 
	    ifTrue: 
		[last > first ifTrue: [self basicSwap: first ifAfter: last].
		^self].

	"First we pick a partititioning element.  We must find one
	 that is approximately the median of the values, but we must do
	 that fast; we use the median of the first, last and middle one,
	 which would require a very weirdly arranged array for worst case
	 performance.
	 We also have to to put it in the middle."
	mid := (first + last) // 2.
	self basicSwap: first ifAfter: mid.
	self basicSwap: mid ifAfter: last.
	self basicSwap: first ifAfter: last.
	pivot := self basicAt: mid.
	smaller := first.
	larger := last.
	
	[
	[smaller <= last and: 
		["self[smaller] <= pivot"

		sortBlock value: (self basicAt: smaller) value: pivot]] 
		whileTrue: [smaller := smaller + 1].
	
	[larger >= first and: 
		["self[larger] >= pivot"

		sortBlock value: pivot value: (self basicAt: larger)]] 
		whileTrue: [larger := larger - 1].
	smaller < larger] 
		whileTrue: 
		    [self basicSwap: smaller with: larger.
		    smaller := smaller + 1.
		    larger := larger - 1].
	smaller > larger 
	    ifFalse: 
		[smaller := smaller + 1.
		larger := larger - 1].
	first < larger ifTrue: [self sortFrom: first to: larger].
	smaller < last ifTrue: [self sortFrom: smaller to: last]
    ]

    binarySearch: anObject low: low high: high [
	"Private - Perform a binary search on the receiver, searching between
	 indexes i and j (indexes are referenced with #basicAt:). If anObject
	 is not found, answer nil, else answer one of the indices containing
	 anObject."

	"I hate this use of exception handling.  Alas, according to the
	 ANSI standard, the methods that use binarySearch must not fail
	 even if the sort block does not support the class of their arguments.
	 In other words, binarySearch must answer nil if there is an error
	 in the sort block."

	<category: 'private methods - searching'>
	^
	[self 
	    doBinarySearch: anObject
	    low: low
	    high: high] 
		on: Error
		do: [:sig | sig return: nil]
    ]

    doBinarySearch: anObject low: low high: high [
	"Private - This is the worker method for #binarySearch:low:high:.
	 The algorithm is complex enough that I preferred to split it in
	 two when exception handling added yet another level of indentation.
	 Besides it also helps speed not having to access arguments in outer
	 contexts."

	<category: 'private methods - searching'>
	| i j mid element compare |
	i := low.
	j := high.
	
	[i > j ifTrue: [^nil].
	mid := (i + j + 1) // 2.
	element := self basicAt: mid.
	compare := self compare: anObject with: element.
	compare = 0] 
		whileFalse: [compare < 0 ifTrue: [j := mid - 1] ifFalse: [i := mid + 1]].

	"We've found an element that is `sort-block-equal' to the one
	 to be searched.  Search in the two directions that is really
	 equal to it"
	mid to: low
	    by: -1
	    do: 
		[:goDown | 
		element := self basicAt: goDown.
		(self compare: anObject with: element) = 0 
		    ifFalse: 
			["Exhausted the sort-block-equal elements in this direction,
			 now look in the other!"

			mid to: high
			    do: 
				[:goUp | 
				element := self basicAt: goUp.
				(self compare: anObject with: element) = 0 ifFalse: [^nil].

				"Another sort-block equal element to test against."
				anObject = element ifTrue: [^goUp]].
			^nil].

		"Another sort-block equal element to test against."
		anObject = element ifTrue: [^goDown]].

	"All the elements in this direction were only sort-block-equal,
	 now look in the other!"
	mid to: high
	    do: 
		[:goUp | 
		element := self basicAt: goUp.
		(self compare: anObject with: element) = 0 ifFalse: [^nil].

		"Another sort-block equal element to test against."
		anObject = element ifTrue: [^goUp]].
	^nil
    ]

    insertionIndexFor: anObject upTo: highestIndex [
	"Private - Perform a binary search on the receiver, searching between
	 indexes firstIndex and highestIndex for an element which comes just
	 after anObject (according to the sort block of course)."

	<category: 'private methods - searching'>
	| low high mid |
	low := firstIndex.
	high := highestIndex.
	
	[mid := (high + low) // 2.
	low > high] whileFalse: 
		    [(sortBlock value: (self basicAt: mid) value: anObject) 
			ifTrue: [low := mid + 1]
			ifFalse: [high := mid - 1]].
	^low
    ]

    examineOn: aStream [
        "Print all the instance variables and objects in the receiver on aStream"

        <category: 'printing'>
        self beConsistent.
	super examineOn: aStream
    ]
]

