"======================================================================
|
|   HashedCollection Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2003, 2008, 2009 Free Software Foundation, Inc.
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



Collection subclass: HashedCollection [
    | tally |
    
    <shape: #pointer>
    <category: 'Collections-Unordered'>
    <comment: 'I am an hashed collection that can store objects uniquely and
give fast responses on their presence in the collection.'>

    HashedCollection class >> primNew: realSize [
	<category: 'private-instance creation'>
	^self basicNew: realSize
    ]

    HashedCollection class >> new [
	"Answer a new instance of the receiver with a default size"

	<category: 'instance creation'>
	^self new: 0
    ]

    HashedCollection class >> new: anInteger [
	"Answer a new instance of the receiver with the given capacity"

	<category: 'instance creation'>
	| realSize |
	realSize := 8 max: (anInteger * 4 + 2) // 3.
	(realSize bitAnd: realSize - 1) = 0 
	    ifFalse: [realSize := 1 bitShift: realSize highBit].
	^(self primNew: realSize) initialize: realSize
    ]

    HashedCollection class >> withAll: aCollection [
	"Answer a collection whose elements are all those in aCollection"

	<category: 'instance creation'>
	^(self new: aCollection size * 2)
	    addAll: aCollection;
	    yourself
    ]

    at: index [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    at: index put: value [
	<category: 'accessing'>
	self shouldNotImplement
    ]

    add: newObject [
	"Add newObject to the set, if and only if the set doesn't already contain
	 an occurrence of it. Don't fail if a duplicate is found. Answer anObject"

	<category: 'accessing'>
	| index |
	newObject isNil ifTrue: [^newObject].
	index := self findIndex: newObject.
	(self primAt: index) isNil ifTrue: [
	    self incrementTally ifTrue: [index := self findIndex: newObject].
	    self primAt: index put: newObject].
	^newObject
    ]

    remove: oldObject ifAbsent: anExceptionBlock [
	"Remove oldObject from the set. If it is found, answer oldObject.
	 Otherwise, evaluate anExceptionBlock and answer its value."

	<category: 'removing'>
	| index |
	index := self findIndexOrNil: oldObject.
	index isNil ifTrue: [^anExceptionBlock value].
	self primAt: index put: nil.
	self decrementTally.
	self rehashObjectsAfter: index.
	^oldObject
    ]

    shallowCopy [
	"Returns a shallow copy of the receiver (the instance variables are
	 not copied)"

	<category: 'copying'>
	^(self copyEmpty: self capacity)
	    copyAllFrom: self;
	    yourself
    ]

    deepCopy [
	"Returns a deep copy of the receiver (the instance variables are
	 copies of the receiver's instance variables)"

	<category: 'copying'>
	| newHashedCollection |
	newHashedCollection := self copyEmpty: self capacity.
	self do: [:each | newHashedCollection addWhileGrowing: each copy].
	^newHashedCollection
    ]

    includes: anObject [
	"Answer whether the receiver contains an instance of anObject."

	<category: 'testing collections'>
	^(self findIndexOrNil: anObject) notNil
    ]

    isEmpty [
	"Answer whether the receiver is empty."

	<category: 'testing collections'>
	^tally == 0
    ]

    occurrencesOf: anObject [
	"Return the number of occurrences of anObject.  Since we're a set, this
	 is either 0 or 1.  Nil is never directly in the set, so we special case
	 it (the result is always 1)."

	<category: 'testing collections'>
	anObject isNil ifTrue: [^1].
	^(self includes: anObject) ifTrue: [1] ifFalse: [0]
    ]

    capacity [
	"Answer how many elements the receiver can hold before having to grow."

	<category: 'testing collections'>
	^self primSize * 3 // 4
    ]

    size [
	"Answer the receiver's size"

	<category: 'testing collections'>
	^tally
    ]

    hash [
	"Return the hash code for the members of the set.  Since order is
	 unimportant, we use a commutative operator to compute the hash value."

	<category: 'testing collections'>
	| hashValue |
	hashValue := tally.
	self 
	    do: [:member | hashValue := hashValue bitXor: (self hashFor: member) scramble].
	^hashValue
    ]

    = aHashedCollection [
	"Returns true if the two sets have the same membership, false if not"

	<category: 'testing collections'>
	self class == aHashedCollection class ifFalse: [^false].
	self == aHashedCollection ifTrue: [^true].
	tally = aHashedCollection size ifFalse: [^false].
	self 
	    do: [:element | (aHashedCollection includes: element) ifFalse: [^false]].
	^true
    ]

    do: aBlock [
	"Enumerate all the non-nil members of the set"

	<category: 'enumerating the elements of a collection'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [aBlock value: (self primAt: i)]]
    ]

    storeOn: aStream [
	"Store on aStream some Smalltalk code which compiles to the receiver"

	<category: 'storing'>
	| hasElements |
	aStream
	    nextPut: $(;
	    nextPutAll: self class storeString;
	    nextPutAll: ' new'.
	hasElements := false.
	self do: 
		[:element | 
		aStream nextPutAll: ' add: '.
		element storeOn: aStream.
		aStream nextPut: $;.
		hasElements := true].
	hasElements ifTrue: [aStream nextPutAll: ' yourself'].
	aStream nextPut: $)
    ]

    rehash [
	"Rehash the receiver"

	<category: 'rehashing'>
	| copy n obj |
	copy := Array new: self size.
	self resetTally.
	n := 0.
	1 to: self primSize
	    do: 
		[:i | 
		(obj := self primAt: i) isNil 
		    ifFalse: 
			[copy at: (n := n + 1) put: obj.
			self primAt: i put: nil]].
	copy do: [:each | self addWhileGrowing: each]
    ]

    initialize: anInteger [
	"Private - Instance variable initialization."

	<category: 'private methods'>
	self resetTally
    ]

    resetTally [
	"Private - Reset the tally of elements in the receiver."

	<category: 'private methods'>
	tally := 0
    ]

    incrementTally [
	"Answer whether the collection's size varied"

	<category: 'private methods'>
	| grown |
	(grown := tally >= (self primSize * 3 // 4)) 
	    ifTrue: [self growBy: self capacity].
	tally := tally + 1.
	^grown
    ]

    decrementTally [
	"Answer whether the collection's size varied"

	<category: 'private methods'>
	tally := tally - 1.
	^false
    ]

    addWhileGrowing: value [
	"Private - Add the newObject association to the receiver. Don't check for
	 the set to be full - we want SPEED!."

	<category: 'private methods'>
	self primAt: (self findElementIndex: value) put: value.
	tally := tally + 1.
	^value
    ]

    copyEmpty [
	"Answer an empty copy of the receiver"

	<category: 'private methods'>
	^self copyEmpty: self capacity
    ]

    copyAllFrom: aHashedCollection [
	<category: 'private methods'>
	| value |
	1 to: aHashedCollection primSize
	    do: 
		[:index | 
		value := aHashedCollection primAt: index.
		value isNil ifFalse: [self addWhileGrowing: value]].
	^self
    ]

    rehashObjectsAfter: index [
	"Private - Rehashes all the objects in the collection after index to
	 see if any of them hash to index.  If so, that object is copied to
	 index, and the process repeats with that object's index, until a nil
	 is encountered."

	<category: 'private methods'>
	| i j size element |
	i := index.
	size := self primSize.
	
	[i = size ifTrue: [i := 1] ifFalse: [i := i + 1].
	element := self primAt: i.
	element notNil] 
		whileTrue: 
		    [self primAt: i put: nil.
		    j := self findElementIndex: element.
		    self primAt: j put: element]
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	self subclassResponsibility
    ]

    findElementIndex: anObject [
        "Tries to see where anObject can be placed as an indexed variable.
	 As soon as nil is found, the index of that slot is answered.
	 anObject also comes from an indexed variable."

        <category: 'private methods'>
        | index size element |
        "Sorry for the lack of readability, but I want speed... :-)"
        index := (anObject hash scramble bitAnd: (size := self primSize) - 1) + 1.
   
        [(element := self primAt: index) isNil
            ifTrue: [^index].
        index == size ifTrue: [index := 1] ifFalse: [index := index + 1]]
                repeat
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	self subclassResponsibility
    ]

    findIndexOrNil: anObject [
	"Finds the given object in the set and returns its index.  If the set
	 doesn't contain the object, answer nil."

	<category: 'private methods'>
	| index |
	index := self findIndex: anObject.
	(self primAt: index) isNil ifTrue: [^nil].
	^index
    ]

    grow [
	<category: 'private methods'>
	^self growBy: self capacity
    ]

    growBy: delta [
	"Private - Grow by the receiver by delta places"

	<category: 'private methods'>
	| newSize newHashedCollection |
	newSize := self primSize + delta.
	newHashedCollection := self copyEmpty: self capacity + delta.
	newHashedCollection copyAllFrom: self.
	^self become: newHashedCollection
    ]

    postLoad [
	"Called after loading an object; rehash the collection because identity
	 objects will most likely mutate their hashes."

	<category: 'saving and loading'>
	self rehash
    ]

    postStore [
	"Called after an object is dumped.  Do nothing -- necessary because
	 by default this calls #postLoad by default"

	<category: 'saving and loading'>
	
    ]

    primAt: anIndex [
	"Private - Answer the anIndex-th item of the hash table for the receiver.
	 Using this instead of basicAt: allows for easier changes in the
	 representation"

	<category: 'builtins'>
	<primitive: VMpr_Object_basicAt>
	self checkIndexableBounds: anIndex
    ]

    primAt: anIndex put: value [
	"Private - Store value in the anIndex-th item of the hash table for the
	 receiver. Using this instead of basicAt:put: allows for easier
	 changes in the representation"

	<category: 'builtins'>
	<primitive: VMpr_Object_basicAtPut>
	self checkIndexableBounds: anIndex put: value
    ]

    primSize [
	"Private - Answer the size of the hash table for the receiver.
	 Using this instead of basicSize allows for easier changes
	 in the representation"

	<category: 'builtins'>
	<primitive: VMpr_Object_basicSize>
	
    ]
]

