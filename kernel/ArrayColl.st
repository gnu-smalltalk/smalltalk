"======================================================================
|
|   ArrayedCollection Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2007,2008,2009
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



SequenceableCollection subclass: ArrayedCollection [
    
    <shape: #pointer>
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances are objects that are generally fixed size, and are accessed
by an integer index.  The ordering of my instance''s elements is determined 
externally; I will not rearrange the order of the elements.'>

    ArrayedCollection class >> new: size withAll: anObject [
	"Answer a collection with the given size, whose elements are all set to
	 anObject"

	<category: 'instance creation'>
	^(self new: size)
	    atAllPut: anObject;
	    yourself
    ]

    ArrayedCollection class >> streamContents: aBlock [
	"Create a ReadWriteStream on an empty instance of the receiver;
	 pass the stream to aBlock, then retrieve its contents and
	 answer them."

	<category: 'instance creation'>
	| stream |
	stream := ReadWriteStream on: (self new: 10).
	stream truncate.
	aBlock value: stream.
	^stream contents
    ]

    ArrayedCollection class >> withAll: aCollection [
	"Answer a collection whose elements are the same as those in aCollection"

	<category: 'instance creation'>
	| anArrayedCollection index |
	anArrayedCollection := self new: aCollection size.
	index := 1.
	aCollection do: 
		[:each | 
		anArrayedCollection at: index put: each.
		index := index + 1].
	^anArrayedCollection
    ]

    ArrayedCollection class >> with: element1 [
	"Answer a collection whose only element is element1"

	<category: 'instance creation'>
	^(self new: 1)
	    at: 1 put: element1;
	    yourself
    ]

    ArrayedCollection class >> with: element1 with: element2 [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new: 2)
	    at: 1 put: element1;
	    at: 2 put: element2;
	    yourself
    ]

    ArrayedCollection class >> with: element1 with: element2 with: element3 [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new: 3)
	    at: 1 put: element1;
	    at: 2 put: element2;
	    at: 3 put: element3;
	    yourself
    ]

    ArrayedCollection class >> with: element1 with: element2 with: element3 with: element4 [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new: 4)
	    at: 1 put: element1;
	    at: 2 put: element2;
	    at: 3 put: element3;
	    at: 4 put: element4;
	    yourself
    ]

    ArrayedCollection class >> with: element1 with: element2 with: element3 with: element4 with: element5 [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new: 5)
	    at: 1 put: element1;
	    at: 2 put: element2;
	    at: 3 put: element3;
	    at: 4 put: element4;
	    at: 5 put: element5;
	    yourself
    ]

    ArrayedCollection class >> join: aCollection [
	"Where aCollection is a collection of SequenceableCollections,
	 answer a new instance with all the elements therein, in order."

	<category: 'instance creation'>
	| newInst start |
	newInst := self 
		    new: (aCollection inject: 0 into: [:size :each | size + each size]).
	start := 1.
	aCollection do: 
		[:subColl | 
		newInst 
		    replaceFrom: start
		    to: (start := start + subColl size) - 1
		    with: subColl].
	^newInst
    ]

    ArrayedCollection class >> join: aCollection separatedBy: sepCollection [
	"Where aCollection is a collection of SequenceableCollections,
	 answer a new instance with all the elements therein, in order,
	 each separated by an occurrence of sepCollection."

	<category: 'instance creation'>
	| newInst start |
	aCollection isEmpty ifTrue: [^self new: 0].
	newInst := self 
		    new: (aCollection inject: sepCollection size * (aCollection size - 1)
			    into: [:size :each | size + each size]).
	start := 1.
	aCollection do: 
		[:subColl | 
		newInst 
		    replaceFrom: start
		    to: (start := start + subColl size) - 1
		    with: subColl]
	    separatedBy: 
		[newInst 
		    replaceFrom: start
		    to: (start := start + sepCollection size) - 1
		    with: sepCollection].
	^newInst
    ]

    add: value [
	<category: 'basic'>
	self shouldNotImplement
    ]

    , aSequenceableCollection [
	"Answer a new instance of an ArrayedCollection containing all the elements
	 in the receiver, followed by all the elements in aSequenceableCollection"

	<category: 'basic'>
	^(self copyEmpty: self size + aSequenceableCollection size)
	    replaceFrom: 1
		to: self size
		with: self
		startingAt: 1;
	    replaceFrom: self size + 1
		to: self size + aSequenceableCollection size
		with: aSequenceableCollection
		startingAt: 1;
	    yourself
    ]

    atAll: keyCollection [
	"Answer a collection of the same kind returned by #collect:, that
	 only includes the values at the given indices. Fail if any of
	 the values in keyCollection is out of bounds for the receiver."

	<category: 'basic'>
	| result i |
	result := self copyEmptyForCollect: keyCollection size.
	i := 0.
	keyCollection do: [:key | result at: (i := i + 1) put: (self at: key)].
	^result
    ]

    copyFrom: start to: stop [
	"Answer a new collection containing all the items in the receiver from the
	 start-th and to the stop-th"

	<category: 'basic'>
	| len |
	stop < start 
	    ifTrue: 
		[stop = (start - 1) ifTrue: [^self copyEmpty: 0].
		^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: start - 1
		    and: self size].
	len := stop - start + 1.
	^(self copyEmpty: len)
	    replaceFrom: 1
		to: len
		with: self
		startingAt: start;
	    yourself
    ]

    copyWithout: oldElement [
	"Answer a copy of the receiver to which all occurrences of oldElement are
	 removed"

	<category: 'basic'>
	| newCollection numOccurrences i |
	numOccurrences := 0.
	self 
	    do: [:element | element = oldElement ifTrue: [numOccurrences := numOccurrences + 1]].
	newCollection := self copyEmpty: self size - numOccurrences.
	i := 1.
	self do: 
		[:element | 
		element = oldElement 
		    ifFalse: 
			[newCollection at: i put: element.
			i := i + 1]].
	^newCollection
    ]

    copyWith: anElement [
	"Answer a new instance of an ArrayedCollection containing all the elements
	 in the receiver, followed by the single item anElement"

	<category: 'basic'>
	| result |
	^(self copyEmpty: self size + 1)
	    replaceFrom: 1
		to: self size
		with: self
		startingAt: 1;
	    at: self size + 1 put: anElement;
	    yourself
    ]

    select: aBlock [
	"Answer a new instance of an ArrayedCollection containing all the elements
	 in the receiver which, when passed to aBlock, answer true"

	<category: 'enumerating the elements of a collection'>
	| newCollection |
	newCollection := WriteStream on: self copyEmpty.
	self 
	    do: [:element | (aBlock value: element) ifTrue: [newCollection nextPut: element]].
	^newCollection contents
    ]

    reject: aBlock [
	"Answer a new instance of an ArrayedCollection containing all the elements
	 in the receiver which, when passed to aBlock, answer false"

	<category: 'enumerating the elements of a collection'>
	| newCollection |
	newCollection := WriteStream on: self copyEmpty.
	self 
	    do: [:element | (aBlock value: element) ifFalse: [newCollection nextPut: element]].
	^newCollection contents
    ]

    collect: aBlock [
	"Answer a new instance of an ArrayedCollection containing all the results
	 of evaluating aBlock passing each of the receiver's elements"

	<category: 'enumerating the elements of a collection'>
	| newCollection |
	newCollection := self copyEmptyForCollect.
	1 to: self size
	    do: [:i | newCollection at: i put: (aBlock value: (self at: i))].
	^newCollection
    ]

    with: aSequenceableCollection collect: aBlock [
	"Evaluate aBlock for each pair of elements took respectively from the receiver
	 and from aSequenceableCollection; answer a collection of the same
	 kind of the receiver, made with the block's return values. Fail if the
	 receiver has not the same size as aSequenceableCollection."

	<category: 'enumerating the elements of a collection'>
	| newCollection |
	self size = aSequenceableCollection size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: aSequenceableCollection].
	newCollection := self copyEmpty.
	1 to: self size
	    do: 
		[:i | 
		newCollection at: i
		    put: (aBlock value: (self at: i) value: (aSequenceableCollection at: i))].
	^newCollection
    ]

    copyReplaceFrom: start to: stop withObject: anObject [
	"Answer a new collection of the same class as the receiver that contains the
	 same elements as the receiver, in the same order, except for elements from
	 index `start' to index `stop'.
	 
	 If start < stop, these are replaced by stop-start+1 copies of anObject.
	 Instead, If start = (stop + 1), then every element of the receiver
	 will be present in the answered copy; the operation will be an append if
	 stop is equal to the size of the receiver or, if it is not, an insert before
	 index `start'."

	<category: 'copying Collections'>
	| newSize end result |
	stop - start < -1 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: start - 1
		    and: self size].

	end := stop >= start ifTrue: [ stop ] ifFalse: [ start ].
	^(self copyEmpty: (newSize := end + (self size - stop)))
	    replaceFrom: 1 to: start - 1 with: self startingAt: 1;
	    replaceFrom: start to: end withObject: anObject;
	    replaceFrom: end + 1 to: newSize with: self startingAt: stop + 1;
	    yourself
    ]

    copyReplaceAll: oldSubCollection with: newSubCollection [
	"Answer a new collection in which all the sequences matching
	 oldSubCollection are replaced with newSubCollection"

	<category: 'copying Collections'>
	| numOld newCollection sizeDifference newSubSize oldSubSize newStart oldStart copySize index |
	numOld := self countSubCollectionOccurrencesOf: oldSubCollection.
	newSubSize := newSubCollection size.
	oldSubSize := oldSubCollection size.
	sizeDifference := newSubSize - oldSubSize.
	newCollection := self copyEmpty: self size + (sizeDifference * numOld).
	oldStart := newStart := 1.
	
	[index := self 
		    indexOfSubCollection: oldSubCollection
		    startingAt: oldStart
		    ifAbsent: 
			["Copy the remaining part of self onto the tail of the new collection."

			newCollection 
			    replaceFrom: newStart
			    to: newCollection size
			    with: self
			    startingAt: oldStart.
			^newCollection].
	copySize := index - oldStart.
	newCollection 
	    replaceFrom: newStart
	    to: newStart + copySize - 1
	    with: self
	    startingAt: oldStart.
	newStart := newStart + copySize.
	newCollection 
	    replaceFrom: newStart
	    to: newStart + newSubSize - 1
	    with: newSubCollection
	    startingAt: 1.
	oldStart := oldStart + copySize + oldSubSize.
	newStart := newStart + newSubSize] 
		repeat
    ]

    copyReplaceFrom: start to: stop with: replacementCollection [
	"Answer a new collection of the same class as the receiver that contains the
	 same elements as the receiver, in the same order, except for elements from
	 index `start' to index `stop'.
	 
	 If start < stop, these are replaced by the contents of the
	 replacementCollection.  Instead, If start = (stop + 1), like in
	 `copyReplaceFrom: 4 to: 3 with: anArray', then every element of the receiver
	 will be present in the answered copy; the operation will be an append if
	 stop is equal to the size of the receiver or, if it is not, an insert before
	 index `start'."

	<category: 'copying Collections'>
	| newSize repSize |
	stop - start < -1 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: start - 1
		    and: self size].
	repSize := replacementCollection size.
	newSize := self size + repSize - (stop - start + 1).
	^(self copyEmpty: newSize)
	    replaceFrom: 1 to: start - 1 with: self startingAt: 1;
	    replaceFrom: start to: start + repSize - 1 with: replacementCollection;
	    replaceFrom: start + repSize to: newSize with: self startingAt: stop + 1;
	    yourself
    ]

    reverse [
	"Answer the receivers' contents in reverse order"

	<category: 'copying Collections'>
	| result complement |
	result := self copyEmpty.
	complement := self size + 1.
	1 to: self size do: [:i | result at: i put: (self at: complement - i)].
	^result
    ]

    sorted [
	"Return a copy of the receiver sorted according to the default
	 sort block, which uses #<= to compare items."
        <category: 'sorting'>
	^self copyEmpty
	    replaceFrom: 1
	    to: self size
	    with: self asSortedCollection
	    startingAt: 1
    ]

    sorted: sortBlock [
	"Return a copy of the receiver sorted according to the given
	 sort block, which accepts pair of items and returns true if
	 the first item is less than the second one."
        <category: 'sorting'>
	^self copyEmpty
	    replaceFrom: 1
	    to: self size
	    with: (self asSortedCollection: sortBlock)
	    startingAt: 1
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	| index |
	aStream
	    nextPutAll: '((';
	    nextPutAll: self class storeString;
	    nextPutAll: ' basicNew: '.
	self basicSize printOn: aStream.
	aStream nextPut: $).
	index := 1.
	self do: 
		[:element | 
		aStream nextPutAll: ' at: '.
		index printOn: aStream.
		aStream nextPutAll: ' put: '.
		element storeOn: aStream.
		aStream nextPut: $;.
		index := index + 1].
	index > 1 ifTrue: [aStream nextPutAll: ' yourself'].
	aStream nextPut: $)
    ]

    copyEmpty [
	"Answer an empty copy of the receiver"

	<category: 'private'>
	^self copyEmpty: self size
    ]

    grow [
	"Private - Grow by some amount"

	<category: 'private'>
	self growBy: self growSize
    ]

    copyGrowTo: newSize [
	"Private - Answer a copy of the receiver grown to newSize elements"

	<category: 'private'>
	| newCollection |
	newCollection := self copyEmpty: newSize.
	newCollection 
	    replaceFrom: 1
	    to: self size
	    with: self
	    startingAt: 1.
	^newCollection
    ]

    growBy: delta [
	"Private - Make the receiver grow by delta elements"

	<category: 'private'>
	^self become: (self copyGrowTo: self basicSize + delta)
    ]

    growTo: newSize [
	"Private - Make the receiver grow to a size of newSize"

	<category: 'private'>
	^self become: (self copyGrowTo: newSize)
    ]

    writeStream [
	"Answer a WriteStream streaming on the receiver"

	<category: 'streams'>
	^WriteStream on: self
    ]

    size [
	"Answer the size of the receiver"

	<category: 'built ins'>
	<primitive: VMpr_Object_basicSize>
	
    ]
]

