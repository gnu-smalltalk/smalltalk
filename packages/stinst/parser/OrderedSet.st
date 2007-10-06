"======================================================================
|
|   OrderedSet Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2007 Free Software Foundation, Inc.
| Written by Stephen Compall.
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



OrderedCollection subclass: OrderedSet [
    | unorderedSet |
    
    <shape: #pointer>
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances represent sets of unique objects that may be accessed by
an arbitrary index.  Besides allowing addition, removal, and insertion
of objects at indexed locations in my instances, I impose the
invariant that a particular element cannot appear more than once.

This invariant leads to varying behavior, as in some cases it makes
sense to behave as an OrderedCollection, whereas in others it makes
more sense to behave as a Set.  For example, #collect: may answer an
OrderedSet with fewer elements than the receiver, #at:put: will signal
an error if its put: argument is already present as a different
element, and #with:with: may potentially answer an OrderedSet with
only one element.

I use a Set, called "unordered set", to decide whether an element is
already present.'>

    OrderedSet class >> identityNew: anInteger [
	"Answer an OrderedSet of size anInteger which uses #== to compare its
	 elements."

	<category: 'instance creation'>
	^self on: (IdentitySet new: anInteger)
    ]

    OrderedSet class >> new: anInteger [
	"Answer an OrderedSet of size anInteger."

	<category: 'instance creation'>
	^self on: (Set new: anInteger)
    ]

    OrderedSet class >> on: anEmptySet [
	"Answer an OrderedSet that uses anEmptySet as an unordered set to
	 maintain my set-property."

	<category: 'instance creation'>
	anEmptySet isEmpty ifFalse: [self error: 'expected empty collection'].
	^(super new: anEmptySet basicSize)
	    unorderedSet: anEmptySet;
	    yourself
    ]

    at: anIndex put: anObject [
	"Store anObject at the anIndex-th item of the receiver, answer
	 anObject.  Signal an error if anObject is already present as
	 another element of the receiver."

	<category: 'accessing'>
	| oldElement |
	oldElement := self at: anIndex.
	"Though it is somewhat inefficient to remove then possibly readd
	 the old element, the case is rare enough that the precision of
	 unorderedSet-based comparison is worth it."
	unorderedSet remove: oldElement.
	(unorderedSet includes: anObject) 
	    ifTrue: 
		[unorderedSet add: oldElement.
		^self error: 'anObject is already present'].
	unorderedSet add: anObject.
	^super at: anIndex put: anObject
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	unorderedSet := unorderedSet copy
    ]

    copyEmpty: newSize [
	"Answer an empty copy of the receiver."

	<category: 'copying'>
	^self species on: (unorderedSet copyEmpty: newSize)
    ]

    includes: anObject [
	"Answer whether anObject is one of my elements, according to my
	 'unordered set'."

	<category: 'searching for elements'>
	^unorderedSet includes: anObject
    ]

    occurrencesOf: anObject [
	"Answer how many of anObject I contain.  As I am a set, this is
	 always 0 or 1."

	<category: 'searching for elements'>
	^(self includes: anObject) ifTrue: [1] ifFalse: [0]
    ]

    indexOf: anElement startingAt: anIndex ifAbsent: exceptionBlock [
	"Answer the first index > anIndex which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found."

	<category: 'searching for elements'>
	^((self includes: anElement) 
	    or: [(anIndex between: 1 and: self size + 1) not]) 
		ifTrue: 
		    ["if anIndex isn't valid, super method will catch it.  Also,
		     super method may not find the element, which is fine"

		    super 
			indexOf: anElement
			startingAt: anIndex
			ifAbsent: exceptionBlock]
		ifFalse: [exceptionBlock value]
    ]

    add: anObject [
	"Add anObject in the receiver if it is not already present, and
	 answer it."

	<category: 'adding'>
	(unorderedSet includes: anObject) 
	    ifFalse: 
		[super add: anObject.
		unorderedSet add: anObject].
	^anObject
    ]

    add: newObject afterIndex: i [
	"Add newObject in the receiver just after the i-th, unless it is
	 already present, and answer it.  Fail if i < 0 or i > self size"

	<category: 'adding'>
	(unorderedSet includes: newObject) 
	    ifFalse: 
		[super add: newObject afterIndex: i.
		unorderedSet add: newObject].
	^newObject
    ]

    addAll: aCollection [
	"Add every item of aCollection to the receiver that is not already
	 present, and answer it."

	<category: 'adding'>
	^self addAllLast: aCollection
    ]

    addAll: newCollection afterIndex: i [
	"Add every item of newCollection to the receiver just after
	 the i-th, answer it. Fail if i < 0 or i > self size"

	<category: 'adding'>
	| index |
	(i between: 0 and: self size) 
	    ifFalse: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: i].
	index := i + firstIndex.
	self makeRoomLastFor: newCollection size.
	lastIndex to: index
	    by: -1
	    do: [:i | self basicAt: i + newCollection size put: (self basicAt: i)].
	lastIndex := lastIndex + newCollection size.
	newCollection do: 
		[:each | 
		(unorderedSet includes: each) 
		    ifFalse: 
			[unorderedSet add: each.
			self basicAt: index put: each.
			index := 1 + index]].
	self closeGapFrom: index - firstIndex + 1 to: i + newCollection size.
	^newCollection
    ]

    addAllFirst: aCollection [
	"Add every item of newCollection to the receiver right at the start
	 of the receiver. Answer aCollection"

	<category: 'adding'>
	| index |
	self makeRoomFirstFor: aCollection size.
	firstIndex := index := firstIndex - aCollection size.
	aCollection do: 
		[:elt | 
		(unorderedSet includes: elt) 
		    ifFalse: 
			[self basicAt: index put: elt.
			unorderedSet add: elt.
			index := index + 1]].
	self closeGapFrom: index - firstIndex + 1 to: aCollection size.
	^aCollection
    ]

    addAllLast: aCollection [
	"Add every item of newCollection to the receiver right at the end
	 of the receiver. Answer aCollection"

	<category: 'adding'>
	"might be too big, but probably not too much"

	| index newElements newElementCount |
	self makeRoomLastFor: aCollection size.
	aCollection do: 
		[:element | 
		(unorderedSet includes: element) 
		    ifFalse: 
			[lastIndex := lastIndex + 1.
			self basicAt: lastIndex put: element.
			unorderedSet add: element]].
	^aCollection
    ]

    addFirst: newObject [
	"Add newObject to the receiver right at the start of the receiver,
	 unless it is already present as an element.  Answer newObject"

	<category: 'adding'>
	(unorderedSet includes: newObject) 
	    ifFalse: 
		[unorderedSet add: newObject.
		super addFirst: newObject].
	^newObject
    ]

    addLast: newObject [
	"Add newObject to the receiver right at the end of the receiver,
	 unless it is already present as an element.  Answer newObject"

	<category: 'adding'>
	(unorderedSet includes: newObject) 
	    ifFalse: 
		[unorderedSet add: newObject.
		super addLast: newObject].
	^newObject
    ]

    removeFirst [
	"Remove an object from the start of the receiver. Fail if the receiver
	 is empty"

	<category: 'removing'>
	^unorderedSet remove: super removeFirst
    ]

    removeLast [
	"Remove an object from the end of the receiver. Fail if the receiver
	 is empty."

	<category: 'removing'>
	^unorderedSet remove: super removeLast
    ]

    removeAtIndex: anIndex [
	"Remove the object at index anIndex from the receiver. Fail if the
	 index is out of bounds."

	<category: 'removing'>
	^unorderedSet remove: (super removeAtIndex: anIndex)
    ]

    closeGapFrom: gapStart to: gapEnd [
	"Remove all elements between gapStart and gapEnd, inclusive,
	 without modifying the unordered set.  I simply ignore this
	 message if gapStart or gapEnd is bad."

	<category: 'private methods'>
	"these vars are almost always exactly the current basic gap"

	| realStart realEnd |
	realStart := firstIndex + gapStart - 1.
	realEnd := firstIndex + gapEnd - 1.

	"trivial cases"
	(gapStart <= gapEnd and: 
		[(realStart between: firstIndex and: lastIndex) 
		    and: [realEnd between: firstIndex and: lastIndex]]) 
	    ifFalse: [^self].
	realEnd = lastIndex 
	    ifTrue: 
		[lastIndex := realStart - 1.
		^self].
	realStart = firstIndex 
	    ifTrue: 
		[firstIndex := realEnd + 1.
		^self].

	"shift from before?"
	gapStart - 1 < (lastIndex - realEnd) 
	    ifTrue: 
		[
		[self basicAt: realEnd put: (self basicAt: (realStart := realStart - 1)).
		realEnd := realEnd - 1.
		realStart = firstIndex] 
			whileFalse.
		firstIndex := realEnd + 1]
	    ifFalse: 
		["shift from after"

		
		[self basicAt: realStart put: (self basicAt: (realEnd := realEnd + 1)).
		realStart := realStart + 1.
		realEnd = lastIndex] 
			whileFalse.
		lastIndex := realStart - 1].
	"help the gc"
	realStart to: realEnd do: [:i | self basicAt: i put: nil]
    ]

    growBy: delta shiftBy: shiftCount [
	"This may be private to OrderedCollection, but its inlining of
	 new-instance filling breaks me."

	<category: 'private methods'>
	| uSet |
	uSet := unorderedSet.
	super growBy: delta shiftBy: shiftCount.
	"effectively copy after #become: invocation"
	unorderedSet := uSet
    ]

    unorderedSet: aSet [
	<category: 'private methods'>
	unorderedSet := aSet
    ]
]

