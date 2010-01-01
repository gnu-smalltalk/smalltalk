"======================================================================
|
|   RunArray Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2009 Free Software Foundation, Inc.
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

"Some of the methods I define (first, last, indexOf:startingAt:ifAbsent:,
 shallowCopy, deepCopy, =, hash) are here only for performance purposes (their
 inherited implementation works, but it is slow)"



OrderedCollection subclass: RunArray [
    | map mapIndex firstInRun lastInRun size |
    
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances are OrderedCollections that automatically
apply Run Length Encoding compression to the things they store. Be careful
when using me: I can provide great space savings, but my instances don''t
grant linear access time. RunArray''s behavior currently is similar to that
of OrderedCollection (you can add elements to RunArrays); maybe it should
behave like an ArrayedCollection.'>

    RunArray class >> new [
	"Answer an empty RunArray"

	<category: 'instance creation'>
	^(self basicNew)
	    map: OrderedCollection new;
	    initialize
    ]

    RunArray class >> new: aSize [
	"Answer a RunArray with space for aSize runs"

	<category: 'instance creation'>
	^(self basicNew)
	    map: (OrderedCollection new: aSize);
	    initialize
    ]

    at: anIndex [
	"Answer the element at index anIndex"

	<category: 'accessing'>
	self updateMapIndexFor: anIndex.
	^(map at: mapIndex) key
    ]

    at: anIndex put: anObject [
	"Replace the element at index anIndex with anObject and answer anObject"

	<category: 'accessing'>
	^self 
	    at: anIndex
	    splitAndPut: anObject
	    decrementBy: 1
    ]

    first [
	"Answer the first element in the receiver"

	<category: 'basic'>
	^(map at: 1) key
    ]

    last [
	"Answer the last element of the receiver"

	<category: 'basic'>
	^(map at: map size) key
    ]

    size [
	"Answer the number of elements in the receiver"

	<category: 'basic'>
	^size
    ]

    addAll: aCollection afterIndex: anIndex [
	"Add all the elements of aCollection after the one at index anIndex. If
	 aCollection is unordered, its elements could be added in an order which is
	 not the #do: order"

	<category: 'adding'>
	| newMap |
	aCollection isEmpty ifTrue: [^self].
	newMap := aCollection asRunArrayMap.
	self updateMapIndexFor: anIndex.
	self splitAt: anIndex decrementBy: 0.
	map addAll: newMap afterIndex: mapIndex.
	self
	    packTwoRuns: mapIndex + newMap size - 1;
	    packTwoRuns: mapIndex.
	size := size + aCollection size
    ]

    addAllFirst: aCollection [
	"Add all the elements of aCollection at the beginning of the receiver. If
	 aCollection is unordered, its elements could be added in an order which is
	 not the #do: order"

	<category: 'adding'>
	^self addAll: aCollection afterIndex: 0
    ]

    addAllLast: aCollection [
	"Add all the elements of aCollection at the end of the receiver. If aCollection
	is unordered, its elements could be added in an order which is not
	 the #do: order"

	<category: 'adding'>
	^self addAll: aCollection afterIndex: self size
    ]

    addFirst: anObject [
	"Add anObject at the beginning of the receiver. Watch out: this operation
	 can cause serious performance pitfalls"

	<category: 'adding'>
	^self add: anObject afterIndex: 0
    ]

    addLast: anObject [
	"Add anObject at the end of the receiver"

	<category: 'adding'>
	^self add: anObject afterIndex: self size
    ]

    add: anObject afterIndex: anIndex [
	"Add anObject after the element at index anIndex"

	<category: 'adding'>
	size := size + 1.
	^self 
	    at: anIndex
	    splitAndPut: anObject
	    decrementBy: 0
    ]

    shallowCopy [
	"Answer a copy of the receiver. The elements are not copied"

	<category: 'copying'>
	^(self species basicNew)
	    map: (map collect: [:assoc | assoc shallowCopy]);
	    initialize
    ]

    deepCopy [
	"Answer a copy of the receiver containing copies of the receiver's elements
	 (#copy is used to obtain them)"

	<category: 'copying'>
	^(self species basicNew)
	    map: (map collect: [:assoc | assoc deepCopy]);
	    initialize
    ]

    objectsAndRunLengthsDo: aBlock [
	"Enumerate all the runs in the receiver, passing to aBlock two parameters
	 for every run: the first is the repeated object, the second is the number
	 of copies"

	<category: 'enumerating'>
	map do: [:each | aBlock value: each key value: each value]
    ]

    do: aBlock [
	"Enumerate all the objects in the receiver, passing each one to aBlock"

	<category: 'enumerating'>
	map do: [:each | each value timesRepeat: [aBlock value: each key]]
    ]

    afterMapIndexAdd: n copiesOf: anObject [
	"Private - Add a run of n copies of anObject after the mapIndex-th run.
	 Answer anObject"

	<category: 'private'>
	map add: (Association key: anObject value: n) afterIndex: mapIndex.
	^anObject
    ]

    at: anIndex splitAndPut: anObject decrementBy: i [
	"Private - Split the run at index anIndex (say it's made of n elements)
	 into two runs for a total of n-i elements; between them, put a one element
	 run for anObject. Answer anObject"

	<category: 'private'>
	| run |
	(self at: (1 max: anIndex)) = anObject 
	    ifTrue: 
		["No need to split, simply update the current run"

		run := map at: mapIndex.
		run value: run value + (1 - i)]
	    ifFalse: 
		[self
		    splitAt: anIndex decrementBy: i;
		    afterMapIndexAdd: 1 copiesOf: anObject].
	^anObject
    ]

    initialize [
	"Private - Initialize mapIndex, firstInRun, lastInRun"

	<category: 'private'>
	map isEmpty 
	    ifTrue: [mapIndex := firstInRun := lastInRun := 0]
	    ifFalse: 
		[mapIndex := firstInRun := 1.
		lastInRun := (map at: 1) value]
    ]

    map [
	"Private - Answer the receiver's map"

	<category: 'private'>
	^map
    ]

    map: anOrderedCollection [
	"Private - Initialize size and set the map to anOrderedCollection"

	<category: 'private'>
	map := anOrderedCollection.
	size := map inject: 0 into: [:sz :assoc | sz + assoc value]
    ]

    packTwoRuns: indexInMap [
	"Private - Check if the two runs at indexes indexInMap and indexInMap + 1
	 are runs for equal elements. If so, pack them in a single run"

	<category: 'private'>
	| run nextRun |
	indexInMap < 1 ifTrue: [^self].
	indexInMap > self size ifTrue: [^self].
	run := map at: indexInMap.
	nextRun := map at: indexInMap + 1.
	run key = nextRun key 
	    ifTrue: 
		[run value: run value + nextRun value.
		map removeAtIndex: indexInMap + 1]
    ]

    splitAt: anIndex decrementBy: i [
	"Private - Split the run at index anIndex (say it's made of n elements)
	 into two runs for a total of n-i elements.
	 You must have already called #at: or #updateMapIndexFor: passing them
	 anIndex"

	<category: 'private'>
	| run |
	anIndex < 1 ifTrue: [^self].
	anIndex > self size ifTrue: [^self].
	run := map at: mapIndex.
	anIndex = firstInRun 
	    ifTrue: 
		[run value: run value - i.

		"Decrement mapIndex, update firstInRun and lastInRun"
		self updateMapIndexFor: anIndex - 1].
	anIndex = lastInRun ifTrue: [run value: run value - i].
	run value: anIndex - firstInRun + (1 - i).
	self afterMapIndexAdd: lastInRun - anIndex copiesOf: run key
    ]

    updateMapIndexFor: anIndex [
	"Private - Update mapIndex so that it points to the run containing the
	 object at index anIndex. To set mapIndex to 0, set anIndex to 0"

	<category: 'private'>
	(anIndex >= firstInRun and: [anIndex <= lastInRun]) ifTrue: [^self].

	"anIndex = 0 is used internally by RunArray"
	anIndex = 0 
	    ifTrue: 
		[mapIndex := firstInRun := lastInRun := 0.
		^self].
	anIndex < 0 
	    ifTrue: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex].
	anIndex > self size 
	    ifTrue: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex].
	anIndex < firstInRun 
	    ifTrue: 
		[
		[mapIndex := mapIndex - 1.
		lastInRun := firstInRun - 1.
		firstInRun := firstInRun - (map at: mapIndex) value.
		anIndex < firstInRun] 
			whileTrue]
	    ifFalse: 
		[
		[mapIndex := mapIndex + 1.
		firstInRun := lastInRun + 1.
		lastInRun := lastInRun + (map at: mapIndex) value.
		lastInRun < anIndex] 
			whileTrue]
    ]

    indexOf: anObject startingAt: anIndex ifAbsent: aBlock [
	"Answer the index of the first copy of anObject in the receiver, starting
	 the search at the element at index anIndex. If no equal object is found,
	 answer the result of evaluating aBlock"

	<category: 'searching'>
	| first last |
	last := 0.
	map do: 
		[:each | 
		first := last + 1.
		last := last + each value.
		(first >= anIndex and: [each key = anIndex]) ifTrue: [^first]].
	^aBlock value
    ]

    removeAtIndex: anIndex [
	"Remove the object at index anIndex from the receiver and answer the
	 removed object"

	<category: 'removing'>
	| run |
	self updateMapIndexFor: anIndex.
	run := map at: mapIndex.
	size := size - 1.
	run value = 1 
	    ifFalse: 
		[run value: run value - 1.
		lastInRun := lastInRun - 1.
		^run key].
	map removeAtIndex: mapIndex.
	mapIndex > map size 
	    ifTrue: 
		[mapIndex := map size.
		lastInRun := self size.
		firstInRun := lastInRun - (map at: map size) value + 1]
	    ifFalse: [lastInRun := firstInRun + (map at: mapIndex) value - 1].
	^run key
    ]

    removeFirst [
	"Remove the first object from the receiver and answer the removed object"

	<category: 'removing'>
	^self removeAtIndex: 1
    ]

    removeLast [
	"Remove the last object from the receiver and answer the removed object"

	<category: 'removing'>
	^self removeAtIndex: self size
    ]

    = anObject [
	"Answer true if the receiver is equal to anObject"

	<category: 'testing'>
	^anObject class == self class and: [anObject map = self map]
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'testing'>
	^map hash
    ]
]



Collection extend [

    asRunArray [
	"Answer the receiver converted to a RunArray. If the receiver is not
	 ordered the order of the elements in the RunArray might not be the #do:
	 order."

	<category: 'converting'>
	^(RunArray basicNew)
	    map: self asRunArrayMap;
	    initialize
    ]

    asRunArrayMap [
	"Private - Answer the receiver converted to an OrderedCollection of
	Associations whose keys are the actual objects and whose values are
	the number of consecutive copies of them"

	"Bags can be easily packed, because they are made of runs of unordered
	 elements like RunArrays. As the #do: order of non-sequenceable collections
	 is undefined, we choose the ordering which yields the best map."

	<category: 'private'>
	^self asBag asRunArrayMap
    ]

]



Bag extend [

    asRunArrayMap [
	"Private - Answer the receiver converted to an OrderedCollection of
	Associations whose keys are the actual objects and whose values are
	the number of consecutive copies of them"

	<category: 'private'>
	| map |
	map := OrderedCollection new: contents size.
	contents associationsDo: [:assoc | map addLast: assoc].
	^map
    ]

]



SequenceableCollection extend [

    asRunArrayMap [
	"Private - Answer the receiver converted to an OrderedCollection of
	Associations whose keys are the actual objects and whose values are
	the number of consecutive copies of them"

	<category: 'private'>
	| map prev startIndex |
	map := OrderedCollection new.
	prev := self at: 1.
	startIndex := 1.
	self 
	    from: 2
	    to: self size
	    keysAndValuesDo: 
		[:currIndex :each | 
		each = prev 
		    ifFalse: 
			[map addLast: (Association key: prev value: currIndex - startIndex).
			prev := each.
			startIndex := currIndex]].
	map addLast: (Association key: prev value: self size + 1 - startIndex).
	^map
    ]

]

