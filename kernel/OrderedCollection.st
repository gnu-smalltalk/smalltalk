"======================================================================
|
|   OrderedCollection Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2008
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



SequenceableCollection subclass: OrderedCollection [
    | firstIndex lastIndex |
    
    <shape: #pointer>
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances represent ordered collections of arbitrary typed objects which
are not directly accessible by an index.  They can be accessed indirectly
through an index, and can be manipulated by adding to the end or based
on content (such as add:after:)'>

    OrderedCollection class >> new: anInteger [
	"Answer an OrderedCollection of size anInteger"

	<category: 'instance creation'>
	^(self basicNew: anInteger) initIndices
    ]

    OrderedCollection class >> new [
	"Answer an OrderedCollection of default size"

	<category: 'instance creation'>
	^self new: 16
    ]

    do: aBlock [
        "Evaluate aBlock for all the elements in the collection"

        <category: 'enumerating'>
        | index |
        index := firstIndex.
        [ index <= lastIndex ] whileTrue: [
            aBlock value: (self basicAt: index).
            index := index + 1 ]
    ]

    first [
	"Answer the first item of the receiver"

	<category: 'accessing'>
	^lastIndex >= firstIndex
	    ifTrue: [self basicAt: firstIndex]
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: 1]
    ]

    last [
	"Answer the last item of the receiver"

	<category: 'accessing'>
	^lastIndex >= firstIndex
	    ifTrue: [self basicAt: lastIndex]
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: 0]
    ]

    at: anIndex [
	"Answer the anIndex-th item of the receiver"

	<category: 'accessing'>
	| index |
	index := anIndex + firstIndex - 1.
	^(index >= firstIndex and: [index <= lastIndex]) 
	    ifTrue: [self basicAt: index]
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex]
    ]

    at: anIndex put: anObject [
	"Store anObject at the anIndex-th item of the receiver, answer anObject"

	<category: 'accessing'>
	| index |
	index := anIndex + firstIndex - 1.
	(index >= firstIndex and: [index <= lastIndex]) 
	    ifTrue: [^self basicAt: index put: anObject]
	    ifFalse: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex]
    ]

    size [
	"Return the number of objects in the receiver"

	<category: 'accessing'>
	^lastIndex - firstIndex + 1
    ]

    add: anObject [
	"Add anObject in the receiver, answer it"

	<category: 'adding'>
	lastIndex == self basicSize ifTrue: [self growBy: self growSize shiftBy: 0].
	lastIndex := lastIndex + 1.
	^self basicAt: lastIndex put: anObject
    ]

    add: newObject after: oldObject [
	"Add newObject in the receiver just after oldObject, answer it.
	 Fail if oldObject can't be found"

	<category: 'adding'>
	^self add: newObject
	    afterIndex: (self indexOf: oldObject
		    ifAbsent: [^SystemExceptions.NotFound signalOn: oldObject what: 'object'])
    ]

    add: newObject before: oldObject [
	"Add newObject in the receiver just before oldObject, answer it.
	 Fail if oldObject can't be found"

	<category: 'adding'>
	^self add: newObject
	    beforeIndex: (self indexOf: oldObject
		    ifAbsent: [^SystemExceptions.NotFound signalOn: oldObject what: 'object'])
    ]

    add: newObject afterIndex: i [
	"Add newObject in the receiver just after the i-th, answer it.
	 Fail if i < 0 or i > self size"

	<category: 'adding'>
	| index |
	(i between: 0 and: self size) 
	    ifFalse: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: i].
	index := i + firstIndex.
	lastIndex == self basicSize ifTrue: [self growBy: self growSize shiftBy: 0].
	lastIndex to: index
	    by: -1
	    do: [:i | self basicAt: i + 1 put: (self basicAt: i)].
	lastIndex := lastIndex + 1.
	^self basicAt: index put: newObject
    ]

    add: newObject beforeIndex: i [
	"Add newObject in the receiver just before the i-th, answer it.
	 Fail if i < 1 or i > self size + 1"

	<category: 'adding'>
	^self add: newObject afterIndex: i - 1
    ]

    addAll: aCollection [
	"Add every item of aCollection to the receiver, answer it"

	<category: 'adding'>
	| index |
	self makeRoomLastFor: aCollection size.
	index := lastIndex + 1.
	lastIndex := lastIndex + aCollection size.
	aCollection do: 
		[:element | 
		self basicAt: index put: element.
		index := index + 1].
	^aCollection
    ]

    addAll: newCollection after: oldObject [
	"Add every item of newCollection to the receiver just after
	 oldObject, answer it. Fail if oldObject is not found"

	<category: 'adding'>
	^self addAll: newCollection
	    afterIndex: (self indexOf: oldObject
		    ifAbsent: [^SystemExceptions.NotFound signalOn: oldObject what: 'object'])
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
	(1 to: newCollection size) with: newCollection
	    do: [:i :each | self basicAt: index + i - 1 put: each].
	^newCollection
    ]

    addAll: newCollection before: oldObject [
	"Add every item of newCollection to the receiver just before
	 oldObject, answer it. Fail if oldObject is not found"

	<category: 'adding'>
	^self addAll: newCollection
	    beforeIndex: (self indexOf: oldObject
		    ifAbsent: [^SystemExceptions.NotFound signalOn: oldObject what: 'object'])
    ]

    addAll: newCollection beforeIndex: i [
	"Add every item of newCollection to the receiver just before
	 the i-th, answer it. Fail if i < 1 or i > self size + 1"

	<category: 'adding'>
	^self addAll: newCollection afterIndex: i - 1
    ]

    addAllFirst: aCollection [
	"Add every item of newCollection to the receiver right at the start
	 of the receiver. Answer aCollection"

	<category: 'adding'>
	| index |
	self makeRoomFirstFor: aCollection size.
	index := firstIndex := firstIndex - aCollection size.
	aCollection do: 
		[:element | 
		self basicAt: index put: element.
		index := index + 1].
	^aCollection
    ]

    addAllLast: aCollection [
	"Add every item of newCollection to the receiver right at the end
	 of the receiver. Answer aCollection"

	<category: 'adding'>
	| index |
	self makeRoomLastFor: aCollection size.
	index := lastIndex + 1.
	lastIndex := lastIndex + aCollection size.
	aCollection do: 
		[:element | 
		self basicAt: index put: element.
		index := index + 1].
	^aCollection
    ]

    addFirst: newObject [
	"Add newObject to the receiver right at the start of the receiver.
	 Answer newObject"

	<category: 'adding'>
	firstIndex <= 1 ifTrue: [self growBy: self growSize shiftBy: self growSize].
	firstIndex := firstIndex - 1.
	^self basicAt: firstIndex put: newObject
    ]

    addLast: newObject [
	"Add newObject to the receiver right at the end of the receiver.
	 Answer newObject"

	<category: 'adding'>
	lastIndex == self basicSize ifTrue: [self growBy: self growSize shiftBy: 0].
	lastIndex := lastIndex + 1.
	^self basicAt: lastIndex put: newObject
    ]

    removeFirst [
	"Remove an object from the start of the receiver. Fail if the receiver
	 is empty"

	<category: 'removing'>
	| answer |
	lastIndex < firstIndex 
	    ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	answer := self basicAt: firstIndex.	"Get the element"
	self basicAt: firstIndex put: nil.	"Allow it to be garbage collected"
	lastIndex = firstIndex 
	    ifTrue: [self initIndices]
	    ifFalse: [firstIndex := firstIndex + 1].
	self size < self shrinkSize ifTrue: [self shrink].
	^answer
    ]

    removeLast [
	"Remove an object from the end of the receiver. Fail if the receiver
	 is empty"

	<category: 'removing'>
	| answer |
	lastIndex < firstIndex 
	    ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	answer := self basicAt: lastIndex.	"Get the element"
	self basicAt: lastIndex put: nil.	"Allow it to be garbage collected"
	lastIndex = firstIndex 
	    ifTrue: [self initIndices]
	    ifFalse: [lastIndex := lastIndex - 1].
	self size < self shrinkSize ifTrue: [self shrink].
	^answer
    ]

    identityRemove: oldObject [
	"Remove oldObject from the receiver. If absent, fail, else
	 answer oldObject."

	<category: 'removing'>
	^self identityRemove: oldObject
	    ifAbsent: [SystemExceptions.NotFound signalOn: oldObject what: 'object']
    ]

    identityRemove: anObject ifAbsent: aBlock [
	"Remove anObject from the receiver. If it can't be found, answer the
	 result of evaluating aBlock"

	<category: 'removing'>
	^self removeAtIndex: (self 
		    identityIndexOf: anObject
		    startingAt: 1
		    ifAbsent: [^aBlock value])
    ]

    remove: anObject ifAbsent: aBlock [
	"Remove anObject from the receiver. If it can't be found, answer the
	 result of evaluating aBlock"

	<category: 'removing'>
	^self removeAtIndex: (self 
		    indexOf: anObject
		    startingAt: 1
		    ifAbsent: [^aBlock value])
    ]

    removeAtIndex: anIndex [
	"Remove the object at index anIndex from the receiver. Fail if the
	 index is out of bounds."

	<category: 'removing'>
	| answer |
	answer := self basicRemoveAtIndex: anIndex.
	self size < self shrinkSize ifTrue: [self shrink].
	^answer
    ]

    basicRemoveAtIndex: anIndex [
	"Remove the object at index anIndex from the receiver. Fail if the
	 index is out of bounds."

	<category: 'private methods'>
	| answer |
	lastIndex < firstIndex 
	    ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	(anIndex < 1 or: [anIndex > self size]) 
	    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: anIndex].
	answer := self basicAt: anIndex + firstIndex - 1.
        self primReplaceFrom: anIndex + firstIndex - 1 to: lastIndex - 1
            with: self startingAt: anIndex + firstIndex.
	self basicAt: lastIndex put: nil.
	lastIndex = firstIndex 
	    ifTrue: [self initIndices]
	    ifFalse: [lastIndex := lastIndex - 1].
	^answer
    ]

    basicAddLast: newObject [
	"Private - Add to the end of the receiver newObject, answer newObject.
	 Don't override this method!"

	<category: 'private methods'>
	lastIndex == self basicSize ifTrue: [self growBy: self growSize shiftBy: 0].
	lastIndex := lastIndex + 1.
	^self basicAt: lastIndex put: newObject
    ]

    basicAddAllLast: aCollection [
	"Private - Add to the end of the receiver all the items in aCollection,
	 answer newObject. Don't override this method!"

	<category: 'private methods'>
	| index |
	self makeRoomLastFor: aCollection size.
	index := lastIndex + 1.
	lastIndex := lastIndex + aCollection size.
	aCollection do: 
		[:element | 
		self basicAt: index put: element.
		index := index + 1].
	^aCollection
    ]

    basicRemoveFirst [
	"Remove an object from the start of the receiver. Fail if the receiver
	 is empty"

	<category: 'private methods'>
	| answer |
	lastIndex < firstIndex 
	    ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	answer := self basicAt: firstIndex.	"Get the element"
	self basicAt: firstIndex put: nil.	"Allow it to be garbage collected"
	lastIndex = firstIndex 
	    ifTrue: [self initIndices]
	    ifFalse: [firstIndex := firstIndex + 1].
	self size < self shrinkSize ifTrue: [self shrink].
	^answer
    ]

    basicRemoveLast [
	"Remove an object from the end of the receiver. Fail if the receiver
	 is empty"

	<category: 'private methods'>
	| answer |
	lastIndex < firstIndex 
	    ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	answer := self basicAt: lastIndex.	"Get the element"
	self basicAt: lastIndex put: nil.	"Allow it to be garbage collected"
	lastIndex = firstIndex 
	    ifTrue: [self initIndices]
	    ifFalse: [lastIndex := lastIndex - 1].
	self size < self shrinkSize ifTrue: [self shrink].
	^answer
    ]

    initIndices [
	<category: 'private methods'>
	firstIndex := self basicSize // 2 max: 1.
	lastIndex := firstIndex - 1
    ]

    firstIndex: first lastIndex: last [
	<category: 'private methods'>
	firstIndex := first.
	lastIndex := last
    ]

    makeRoomFirstFor: n [
	"Private - Make room for n elements at the start of the collection"

	<category: 'private methods'>
	firstIndex <= n 
	    ifTrue: [self growBy: (n max: self growSize) shiftBy: (n max: self growSize)]
    ]

    makeRoomLastFor: n [
	"Private - Make room for n elements at the end of the collection"

	<category: 'private methods'>
	lastIndex + n > self basicSize 
	    ifTrue: [self growBy: (n max: self growSize) shiftBy: 0]
    ]

    shrinkSize [
	<category: 'private methods'>
	^self basicSize // 3
    ]

    shrink [
	"Decrease the room in the collection by shrinkSize"

	<category: 'private methods'>
	| shift shrink |
	shrink := self shrinkSize.

	"Check that the new firstIndex is >= 1."
	shift := firstIndex - 1 min: shrink // 2.

	"Check that the new lastIndex is <= basicSize."
	shrink := shrink min: self basicSize - (lastIndex - shift).
	self growBy: shrink negated shiftBy: shift negated
    ]

    grow [
	"Make growSize room in the collection, putting the old contents in the
	 middle."

	<category: 'private methods'>
	self growBy: self growSize shiftBy: firstIndex // 2
    ]

    growBy: delta shiftBy: shiftCount [
	"Make room for delta more places in the collection, shifting the old
	 contents by shiftCount places"

	<category: 'private methods'>
	| newOrderedCollection |
	newOrderedCollection := self copyEmpty: self basicSize + delta.
        newOrderedCollection
            primReplaceFrom: firstIndex + shiftCount to: lastIndex + shiftCount
            with: self startingAt: firstIndex.
	newOrderedCollection firstIndex: firstIndex + shiftCount
	    lastIndex: lastIndex + shiftCount.
	self become: newOrderedCollection
    ]

    primReplaceFrom: start to: stop with: byteArray startingAt: replaceStart [
        "Replace the characters from start to stop with new characters whose
         ASCII codes are contained in byteArray, starting at the replaceStart
         location of byteArray"

        <category: 'built ins'>
        <primitive: VMpr_ArrayedCollection_replaceFromToWithStartingAt>
        self primitiveFailed
    ]

]

