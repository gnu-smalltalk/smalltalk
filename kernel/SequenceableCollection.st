"======================================================================
|
|   SequenceableCollection Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2006,2007,2008,2009
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



Collection subclass: SequenceableCollection [
    
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances represent collections of objects that are ordered.  I provide
some access and manipulation methods.'>

    SequenceableCollection class >> join: aCollection separatedBy: sepCollection [
	"Where aCollection is a collection of SequenceableCollections,
	 answer a new instance with all the elements therein, in order,
	 each separated by an occurrence of sepCollection."

	<category: 'instance creation'>
	| newInst start |
	aCollection isEmpty ifTrue: [^self new: 0].
	newInst := self 
		    new: (aCollection inject: sepCollection size * (aCollection size - 1)
			    into: [:size :each | size + each size]).
	aCollection do: [:subColl | newInst addAll: subColl]
	    separatedBy: [newInst addAll: sepCollection].
	^newInst
    ]

    examineOn: aStream [
	"Print all the instance variables and context of the receiver on aStream"

	<category: 'testing'>
	| instVars object output |
	aStream
	    nextPutAll: 'An instance of ';
	    print: self class;
	    nl.
	instVars := self class allInstVarNames.
	1 to: instVars size
	    do: 
		[:i | 
		object := self instVarAt: i.
		output := [object printString] on: Error
			    do: 
				[:ex | 
				ex 
				    return: '%1 %2' % 
						{object class article.
						object class name asString}].
		aStream
		    nextPutAll: '  ';
		    nextPutAll: (instVars at: i);
		    nextPutAll: ': ';
		    nextPutAll: output;
		    nl].
	aStream
	    nextPutAll: '  contents: [';
	    nl.
	self keysAndValuesDo: 
		[:i :obj | 
		| output |
		output := [obj printString] on: Error
			    do: 
				[:ex | 
				ex 
				    return: '%1 %2' % 
						{obj class article.
						obj class name asString}].
		aStream
		    nextPutAll: '    [';
		    print: i;
		    nextPutAll: ']: ';
		    nextPutAll: output;
		    nl].
	aStream
	    nextPutAll: '  ]';
	    nl
    ]

    isSequenceable [
	"Answer whether the receiver can be accessed by a numeric index with
	 #at:/#at:put:."

	<category: 'testing'>
	^true
    ]

    = aCollection [
	"Answer whether the receiver's items match those in aCollection"

	<category: 'testing'>
	self class == aCollection class ifFalse: [^false].
	self size = aCollection size ifFalse: [^false].
	1 to: self size
	    do: [:i | (self at: i) = (aCollection at: i) ifFalse: [^false]].
	^true
    ]

    hash [
	"Answer an hash value for the receiver"

	"Don't like this hash function; it can be made much better"

	<category: 'testing'>
	| hash carry |
	hash := self size.
	self do: 
		[:element | 
		carry := (hash bitAnd: 536870912) > 0.
		hash := hash bitAnd: 536870911.
		hash := hash bitShift: 1.
		carry ifTrue: [hash := hash bitOr: 1].
		hash := hash bitXor: element hash].
	^hash
    ]

    endsWith: aSequenceableCollection [
	"Returns true if the receiver ends with the same characters as aSequenceableCollection."

	<category: 'comparing'>
	| delta |
	delta := self size - aSequenceableCollection size.
	delta >= 0 ifFalse: [ ^false ].
	aSequenceableCollection 
	    keysAndValuesDo: [:i :each |
		(self at: i + delta) = each ifFalse: [^false]].
	^true
    ]

    startsWith: aSequenceableCollection [
	"Returns true if the receiver starts with the same characters as aSequenceableCollection."

	<category: 'comparing'>
	self size >= aSequenceableCollection size ifFalse: [ ^false ].
	aSequenceableCollection 
	    keysAndValuesDo: [:i :each |
		(self at: i) = each ifFalse: [^false]].
	^true
    ]

    at: anIndex ifAbsent: aBlock [
	"Answer the anIndex-th item of the collection, or evaluate aBlock
	 and answer the result if the index is out of range"

	<category: 'basic'>
	(anIndex between: 1 and: self size) ifFalse: [^aBlock value].
	^self at: anIndex
    ]

    atRandom [
	"Return a random item of the receiver."

	<category: 'basic'>
	^self at: (Random between: 1 and: self size)
    ]

    atAll: keyCollection [
	"Answer a collection of the same kind returned by #collect:, that
	 only includes the values at the given indices. Fail if any of
	 the values in keyCollection is out of bounds for the receiver."

	<category: 'basic'>
	| result |
	result := self copyEmptyForCollect: keyCollection size.
	keyCollection do: [:key | result add: (self at: key)].
	^result
    ]

    atAll: aCollection put: anObject [
	"Put anObject at every index contained in aCollection"

	<category: 'basic'>
	aCollection do: [:index | self at: index put: anObject]
    ]

    atAllPut: anObject [
	"Put anObject at every index in the receiver"

	<category: 'basic'>

        | to size |
        "Unroll completely for small collections..."
        (size := self size) = 0 ifTrue: [ ^self ].
        self at: 1 put: anObject. size = 1 ifTrue: [ ^self ].
        self at: 2 put: anObject. size = 2 ifTrue: [ ^self ].
        self at: 3 put: anObject. size = 3 ifTrue: [ ^self ].
        self at: 4 put: anObject. to := 4.

        "... and use memcpy repeatedly for larger ones."
        [ size > to ] whileTrue: [
            self
                replaceFrom: to + 1
                to: ((to := to + to) min: size)
                with: self
                startingAt: 1 ].
    ]

    after: oldObject [
	"Return the element after oldObject.  Error if oldObject not found or
	 if no following object is available"

	<category: 'basic'>
	| i |
	i := self indexOf: oldObject.
	i = 0 
	    ifTrue: [^SystemExceptions.NotFound signalOn: oldObject what: 'object'].
	^self at: i + 1
    ]

    before: oldObject [
	"Return the element before oldObject.  Error if oldObject not found or
	 if no preceding object is available"

	<category: 'basic'>
	| i |
	i := self indexOf: oldObject.
	i = 0 
	    ifTrue: [^SystemExceptions.NotFound signalOn: oldObject what: 'object'].
	^self at: i - 1
    ]

    allButFirst [
	"Answer a copy of the receiver without the first object."

	<category: 'basic'>
	^self copyFrom: 2
    ]

    allButFirst: n [
	"Answer a copy of the receiver without the first n objects."

	<category: 'basic'>
	^self copyFrom: n + 1
    ]

    allButLast [
	"Answer a copy of the receiver without the last object."

	<category: 'basic'>
	^self copyFrom: 1 to: self size - 1
    ]

    allButLast: n [
	"Answer a copy of the receiver without the last n objects."

	<category: 'basic'>
	^self copyFrom: 1 to: self size - n
    ]

    first [
	"Answer the first item in the receiver"

	<category: 'basic'>
	^self at: 1
    ]

    second [
	"Answer the second item in the receiver"

	<category: 'basic'>
	^self at: 2
    ]

    third [
	"Answer the third item in the receiver"

	<category: 'basic'>
	^self at: 3
    ]

    fourth [
	"Answer the fourth item in the receiver"

	<category: 'basic'>
	^self at: 4
    ]

    first: n [
	"Answer the first n items in the receiver"

	<category: 'basic'>
	^self copyFrom: 1 to: n
    ]

    last: n [
	"Answer the last n items in the receiver"

	<category: 'basic'>
	^self copyFrom: self size - n + 1
    ]

    last [
	"Answer the last item in the receiver"

	<category: 'basic'>
	^self at: self size
    ]

    includes: anObject [
	"Answer whether we include anObject"

	"Reimplemented to avoid an expensive full-block"

	<category: 'basic'>
	1 to: self size do: [:index | anObject = (self at: index) ifTrue: [^true]].
	^false
    ]

    identityIncludes: anObject [
	"Answer whether we include the anObject object"

	"Reimplemented to avoid an expensive full-block"

	<category: 'basic'>
	1 to: self size do: [:index | anObject == (self at: index) ifTrue: [^true]].
	^false
    ]

    indexOfSubCollection: aSubCollection startingAt: anIndex ifAbsent: exceptionBlock [
	"Answer the first index > anIndex at which starts a sequence of
	 items matching aSubCollection.
	 Invoke exceptionBlock and answer its result if no such sequence is found"

	<category: 'basic'>
	| selfSize subSize |
	subSize := aSubCollection size.
        subSize = 0 ifTrue: [ ^anIndex ].
	selfSize := self size.
	anIndex + subSize - 1 <= selfSize 
	    ifTrue: 
		[anIndex to: selfSize - subSize + 1
		    do: 
			[:index | 
			(self at: index) = (aSubCollection at: 1) 
			    ifTrue: 
				[(self matchSubCollection: aSubCollection startingAt: index) 
				    ifTrue: [^index]]]].
	^exceptionBlock value
    ]

    indexOfSubCollection: aSubCollection startingAt: anIndex [
	"Answer the first index > anIndex at which starts a sequence of
	 items matching aSubCollection. Answer 0 if no such sequence is found."

	<category: 'basic'>
	^self 
	    indexOfSubCollection: aSubCollection
	    startingAt: anIndex
	    ifAbsent: [^0]
    ]

    indexOf: anElement startingAt: anIndex ifAbsent: exceptionBlock [
	"Answer the first index > anIndex which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	anIndex < 1 | (anIndex > self size) 
	    ifTrue: 
		["If anIndex is just past the end of the collection, don't raise
		 an error (this is the most generic solution that avoids that
		 #indexOf: fails when the collection is empty."

		anIndex = (self size + 1) 
		    ifTrue: [^exceptionBlock value]
		    ifFalse: [^self checkIndexableBounds: anIndex]].
	anIndex to: self size
	    do: [:index | (self at: index) = anElement ifTrue: [^index]].
	^exceptionBlock value
    ]

    identityIndexOf: anObject startingAt: anIndex ifAbsent: exceptionBlock [
	"Answer the first index > anIndex which contains an object exactly
	 identical to anObject.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	anIndex < 1 | (anIndex > self size) 
	    ifTrue: 
		["If anIndex is just past the end of the collection, don't raise
		 an error (this is the most generic solution that avoids that
		 #indexOf: fails when the collection is empty."

		anIndex = (self size + 1) 
		    ifTrue: [^exceptionBlock value]
		    ifFalse: [^self checkIndexableBounds: anIndex]].
	anIndex to: self size
	    do: [:index | (self at: index) == anObject ifTrue: [^index]].
	^exceptionBlock value
    ]

    indexOfSubCollection: aSubCollection [
	"Answer the first index > anIndex at which starts a sequence of
	 items matching aSubCollection. Answer 0 if no such sequence is found."

	<category: 'basic'>
	^self 
	    indexOfSubCollection: aSubCollection
	    startingAt: 1
	    ifAbsent: [^0]
    ]

    indexOfSubCollection: aSubCollection ifAbsent: exceptionBlock [
	"Answer the first index > anIndex at which starts a sequence of
	 items matching aSubCollection. Answer 0 if no such sequence is found."

	<category: 'basic'>
	^self 
	    indexOfSubCollection: aSubCollection
	    startingAt: 1
	    ifAbsent: exceptionBlock
    ]

    indexOf: anElement startingAt: anIndex [
	"Answer the first index > anIndex which contains anElement.
	 Answer 0 if no item is found"

	<category: 'basic'>
	^self 
	    indexOf: anElement
	    startingAt: anIndex
	    ifAbsent: [^0]
    ]

    identityIndexOfLast: anElement ifAbsent: exceptionBlock [
	"Answer the last index which contains an object identical to anElement.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	self size to: 1 by: -1
	    do: [:index | (self at: index) == anElement ifTrue: [^index]].
	^exceptionBlock value
    ]

    indexOfLast: anElement ifAbsent: exceptionBlock [
	"Answer the last index which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	self size to: 1 by: -1
	    do: [:index | (self at: index) = anElement ifTrue: [^index]].
	^exceptionBlock value
    ]

    indexOf: anElement ifAbsent: exceptionBlock [
	"Answer the index of the first occurrence of anElement in the receiver.
	 Invoke exceptionBlock and answer its result if no item is found"

	<category: 'basic'>
	^self 
	    indexOf: anElement
	    startingAt: 1
	    ifAbsent: exceptionBlock
    ]

    indexOf: anElement [
	"Answer the index of the first occurrence of anElement in the receiver.
	 Answer 0 if no item is found"

	<category: 'basic'>
	^self 
	    indexOf: anElement
	    startingAt: 1
	    ifAbsent: [^0]
    ]

    identityIndexOf: anElement startingAt: anIndex [
	"Answer the first index > anIndex which contains an object identical
	 to anElement. Answer 0 if no item is found"

	<category: 'basic'>
	^self 
	    identityIndexOf: anElement
	    startingAt: anIndex
	    ifAbsent: [^0]
    ]

    identityIndexOf: anElement ifAbsent: exceptionBlock [
	"Answer the index of the first occurrence of an object identical to
	 anElement in the receiver. Invoke exceptionBlock and answer its
	 result if no item is found"

	<category: 'basic'>
	^self 
	    identityIndexOf: anElement
	    startingAt: 1
	    ifAbsent: exceptionBlock
    ]

    identityIndexOf: anElement [
	"Answer the index of the first occurrence of an object identical to
	 anElement in the receiver. Answer 0 if no item is found"

	<category: 'basic'>
	^self 
	    identityIndexOf: anElement
	    startingAt: 1
	    ifAbsent: [^0]
    ]

    replaceAll: anObject with: anotherObject [
	"In the receiver, replace every occurrence of anObject with anotherObject."

	<category: 'replacing items'>
	1 to: self size
	    do: [:index | (self at: index) = anObject ifTrue: [self at: index put: anotherObject]]
    ]

    replaceFrom: start to: stop with: replacementCollection startingAt: repStart [
	"Replace the items from start to stop with replacementCollection's items
	 from repStart to repStart+stop-start"

	<category: 'replacing items'>
	| delta maxStop minStop |
	minStop := start - 1.
	maxStop := self size min: minStop + replacementCollection size.
	(minStop <= stop and: [stop <= maxStop]) 
	    ifFalse: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: minStop
		    and: maxStop].
	delta := start - repStart.
	repStart > start
	    ifTrue: [
		start to: stop do: [:i |
		    self at: i put: (replacementCollection at: i - delta)] ]
	    ifFalse: [
		stop to: start by: -1 do: [:i |
		    self at: i put: (replacementCollection at: i - delta)] ]
    ]

    replaceFrom: start to: stop with: replacementCollection [
	"Replace the items from start to stop with replacementCollection's items
	 from 1 to stop-start+1 (in unexpected order if the collection is not
	 sequenceable)."

	<category: 'replacing items'>
	| i |
	i := start - 1.
	stop - i = replacementCollection size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: replacementCollection size].
        replacementCollection isSequenceable ifTrue: [
	    ^self replaceFrom: start to: stop with: replacementCollection startingAt: 1 ].

	replacementCollection do: [:each | self at: (i := i + 1) put: each]
    ]

    replaceFrom: anIndex to: stopIndex withObject: replacementObject [
	"Replace every item from start to stop with replacementObject."

	<category: 'replacing items'>
	stopIndex - anIndex < -1
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stopIndex
		    mustBeBetween: anIndex
		    and: self size].
	anIndex to: stopIndex do: [:index | self at: index put: replacementObject]
    ]

    copyAfter: anObject [
	"Answer a new collection holding all the elements of the receiver
	 after the first occurrence of anObject, up to the last."

	<category: 'copying SequenceableCollections'>
	^self copyFrom: (self indexOf: anObject ifAbsent: [self size]) + 1
    ]

    copyAfterLast: anObject [
	"Answer a new collection holding all the elements of the receiver
	 after the last occurrence of anObject, up to the last."

	<category: 'copying SequenceableCollections'>
	^self copyFrom: (self indexOfLast: anObject ifAbsent: [self size]) + 1
    ]

    copyUpTo: anObject [
	"Answer a new collection holding all the elements of the receiver
	 from the first up to the first occurrence of anObject, excluded."

	<category: 'copying SequenceableCollections'>
	^self copyFrom: 1
	    to: (self indexOf: anObject
		    ifAbsent: [self size + 1]) - 1
    ]

    copyUpToLast: anObject [
	"Answer a new collection holding all the elements of the receiver
	 from the first up to the last occurrence of anObject, excluded."

	<category: 'copying SequenceableCollections'>
	^self copyFrom: 1
	    to: (self indexOfLast: anObject
		    ifAbsent: [self size + 1]) - 1
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

	<category: 'copying SequenceableCollections'>
	| newSize repSize result |
	stop - start < -1 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: start - 1
		    and: self size].
	stop >= start 
	    ifTrue: 
		[^(self copy)
		    atAll: (start to: stop) put: anObject;
		    yourself].
	newSize := self size - (stop - start).
	result := self copyEmpty: newSize.
	start > 1 
	    ifTrue: 
		[self 
		    from: 1
		    to: start - 1
		    do: [:each | result add: each]].
	result add: anObject.
	stop < self size 
	    ifTrue: 
		[self 
		    from: stop + 1
		    to: self size
		    do: [:each | result add: each]].
	^result
    ]

    copyWithFirst: anObject [
	"Answer a new collection holding all the elements of the receiver
	 after the first occurrence of anObject, up to the last."

	<category: 'copying SequenceableCollections'>
	^self copyReplaceFrom: 1 to: 0 withObject: anObject
    ]

    copyFrom: start [
	"Answer a new collection containing all the items in the receiver from the
	 start-th."

	<category: 'copying SequenceableCollections'>
	^self copyFrom: start to: self size
    ]

    copyFrom: start to: stop [
	"Answer a new collection containing all the items in the receiver from the
	 start-th and to the stop-th"

	<category: 'copying SequenceableCollections'>
	| len coll |
	stop < start 
	    ifTrue: 
		[stop = (start - 1) ifTrue: [^self copyEmpty: 0].
		^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: start - 1
		    and: self size].
	len := stop - start + 1.
	coll := self copyEmpty: len + 10.
	self 
	    from: start
	    to: stop
	    do: [:each | coll add: each].
	^coll
    ]

    copyReplaceAll: oldSubCollection with: newSubCollection [
	"Answer a new collection in which all the sequences matching
	 oldSubCollection are replaced with newSubCollection"

	<category: 'copying SequenceableCollections'>
	| numOld newCollection sizeDifference newSubSize oldSubSize oldStart copySize index |
	numOld := self countSubCollectionOccurrencesOf: oldSubCollection.
	newSubSize := newSubCollection size.
	oldSubSize := oldSubCollection size.
	sizeDifference := newSubSize - oldSubSize.
	newCollection := self copyEmpty: self size + (sizeDifference * numOld).
	oldStart := 1.
	
	[index := self 
		    indexOfSubCollection: oldSubCollection
		    startingAt: oldStart
		    ifAbsent: 
			["Copy the remaining part of self onto the tail of the new collection."

			self 
			    from: oldStart
			    to: self size
			    do: [:each | newCollection add: each].
			^newCollection].
	copySize := index - oldStart.
	self 
	    from: oldStart
	    to: oldStart + copySize - 1
	    do: [:each | newCollection add: each].
	newCollection addAll: newSubCollection.
	oldStart := oldStart + copySize + oldSubSize] 
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

	<category: 'copying SequenceableCollections'>
	| newSize repSize result |
	stop - start < -1 
	    ifTrue: 
		[^SystemExceptions.ArgumentOutOfRange 
		    signalOn: stop
		    mustBeBetween: start - 1
		    and: self size].
	repSize := replacementCollection size.
	newSize := self size + repSize - (stop - start + 1).
	result := self copyEmpty: newSize.
	start > 1 
	    ifTrue: 
		[self 
		    from: 1
		    to: start - 1
		    do: [:each | result add: each]].
	result addAll: replacementCollection.
	stop < self size 
	    ifTrue: 
		[self 
		    from: stop + 1
		    to: self size
		    do: [:each | result add: each]].
	^result
    ]

    join: sepCollection [
	"Answer a new collection like my first element, with all the
	 elements (in order) of all my elements (which should be
	 collections) separated by sepCollection.
	 
	 I use my first element instead of myself as a prototype because
	 my elements are more likely to share the desired properties than
	 I am, such as in:
	 
	 #('hello,' 'world') join: ' ' => 'hello, world'"

	<category: 'concatenating'>
	^self isEmpty 
	    ifTrue: [#()]
	    ifFalse: [self first species join: self separatedBy: sepCollection]
    ]

    nextPutAllOn: aStream [
	"Write all the objects in the receiver to aStream"

	aStream next: self size putAll: self startingAt: 1
    ]

    readStream [
	"Answer a ReadStream streaming on the receiver"

	<category: 'enumerating'>
	^ReadStream on: self
    ]

    readWriteStream [
	"Answer a ReadWriteStream which streams on the receiver"

	<category: 'enumerating'>
	^ReadWriteStream on: self
    ]

    anyOne [
	"Answer an unspecified element of the collection."

	<category: 'enumerating'>
	^self first
    ]

    do: aBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection"

	<category: 'enumerating'>
	1 to: self size do: [:i | aBlock value: (self at: i)]
    ]

    do: aBlock separatedBy: sepBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection.
	 Between each element, evaluate sepBlock without parameters."

	<category: 'enumerating'>
	self isEmpty ifTrue: [^self].
	aBlock value: (self at: 1).
	2 to: self size
	    do: 
		[:i | 
		sepBlock value.
		aBlock value: (self at: i)]
    ]

    doWithIndex: aBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection,
	 passing the index of each element as the second parameter.  This method
	 is mantained for backwards compatibility and is not mandated by the
	 ANSI standard; use #keysAndValuesDo:"

	<category: 'enumerating'>
	1 to: self size do: [:i | aBlock value: (self at: i) value: i]
    ]

    fold: binaryBlock [
	"First, pass to binaryBlock the first and second elements of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation,
	 or the first element if the collection has size 1.  Fail if the collection
	 is empty."

	"This method is redefined from Collection for efficiency only"

	<category: 'enumerating'>
	| result |
	self isEmpty ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	result := self at: 1.
	self 
	    from: 2
	    to: self size
	    do: [:element | result := binaryBlock value: result value: element].
	^result
    ]

    keys [
	"Return an Interval corresponding to the valid indices in the receiver."

	<category: 'enumerating'>
	^1 to: self size
    ]

    keysAndValuesDo: aBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection,
	 passing the index of each element as the first parameter and the
	 element as the second."

	<category: 'enumerating'>
	1 to: self size do: [:i | aBlock value: i value: (self at: i)]
    ]

    from: startIndex to: stopIndex do: aBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection whose
	 indices are in the range index to stopIndex"

	<category: 'enumerating'>
	startIndex to: stopIndex do: [:i | aBlock value: (self at: i)]
    ]

    from: startIndex to: stopIndex doWithIndex: aBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection whose
	 indices are in the range index to stopIndex, passing the index of each
	 element as the second parameter.  This method is mantained for backwards
	 compatibility and is not mandated by the ANSI standard; use
	 #from:to:keysAndValuesDo:"

	<category: 'enumerating'>
	startIndex to: stopIndex do: [:i | aBlock value: (self at: i) value: i]
    ]

    from: startIndex to: stopIndex keysAndValuesDo: aBlock [
	"Evaluate aBlock for all the elements in the sequenceable collection whose
	 indices are in the range index to stopIndex, passing the index of each
	 element as the first parameter and the element as the second."

	<category: 'enumerating'>
	startIndex to: stopIndex do: [:i | aBlock value: i value: (self at: i)]
    ]

    findFirst: aBlock [
	"Returns the index of the first element of the sequenceable collection
	 for which aBlock returns true, or 0 if none"

	<category: 'enumerating'>
	self doWithIndex: [:each :i | (aBlock value: each) ifTrue: [^i]].
	^0
    ]

    findLast: aBlock [
	"Returns the index of the last element of the sequenceable collection
	 for which aBlock returns true, or 0 if none does"

	<category: 'enumerating'>
	| i |
	i := self size.
	self reverseDo: 
		[:each | 
		(aBlock value: each) ifTrue: [^i].
		i := i - 1].
	^0
    ]

    reverse [
	"Answer the receivers' contents in reverse order"

	<category: 'enumerating'>
	| result |
	result := self copyEmptyForCollect.
	self reverseDo: [:each | result add: each].
	^result
    ]

    reverseDo: aBlock [
	"Evaluate aBlock for all elements in the sequenceable collection, from the
	 last to the first."

	<category: 'enumerating'>
	self size to: 1
	    by: -1
	    do: [:i | aBlock value: (self at: i)]
    ]

    with: aSequenceableCollection do: aBlock [
	"Evaluate aBlock for each pair of elements took respectively from
	 the receiver and from aSequenceableCollection. Fail if the receiver
	 has not the same size as aSequenceableCollection."

	<category: 'enumerating'>
	self size = aSequenceableCollection size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: aSequenceableCollection].
	1 to: self size
	    do: [:i | aBlock value: (self at: i) value: (aSequenceableCollection at: i)]
    ]

    with: aSequenceableCollection collect: aBlock [
	"Evaluate aBlock for each pair of elements took respectively from
	 the receiver and from aSequenceableCollection; answer a collection of
	 the same kind of the receiver, made with the block's return values. 
	 Fail if the receiver has not the same size as aSequenceableCollection."

	<category: 'enumerating'>
	| newCollection |
	self size = aSequenceableCollection size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: aSequenceableCollection].
	newCollection := self copyEmptyForCollect.
	1 to: self size
	    do: 
		[:i | 
		newCollection 
		    add: (aBlock value: (self at: i) value: (aSequenceableCollection at: i))].
	^newCollection
    ]

    with: aSequenceableCollection [
	"Return an Array with the same size as the receiver and
	 aSequenceableCollection, each element of which is a 2-element
	 Arrays including one element from the receiver and one from
	 aSequenceableCollection."
	<category: 'concatenating'>
	self size = aSequenceableCollection size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: aSequenceableCollection].
	^1 to: self size collect: [ :each |
	    { self at: each. aSequenceableCollection at: each } ]
    ]

    with: seqColl1 with: seqColl2 [
	"Return an Array with the same size as the receiver and
	 the arguments, each element of which is a 3-element
	 Arrays including one element from the receiver and one from
	 each argument."
	<category: 'concatenating'>
	self size = seqColl1 size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: seqColl1].
	self size = seqColl2 size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: seqColl2].
	^1 to: self size collect: [ :each |
	    { self at: each. seqColl1 at: each. seqColl2 at: each } ]
    ]

    with: seqColl1 with: seqColl2 with: seqColl3 [
	"Return an Array with the same size as the receiver and
	 the arguments, each element of which is a 4-element
	 Arrays including one element from the receiver and one from
	 each argument."
	<category: 'concatenating'>
	self size = seqColl1 size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: seqColl1].
	self size = seqColl2 size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: seqColl2].
	self size = seqColl3 size 
	    ifFalse: [^SystemExceptions.InvalidSize signalOn: seqColl3].
	^1 to: self size collect: [ :each |
	    { self at: each. seqColl1 at: each. seqColl2 at: each.
	      seqColl3 at: each } ]
    ]

    sorted [
	"Return a copy of the receiver sorted according to the default
	 sort block, which uses #<= to compare items."
        <category: 'sorting'>
	^(self copyEmptyForCollect: self size)
	    addAll: self asSortedCollection;
	    yourself
    ]

    sorted: sortBlock [
	"Return a copy of the receiver sorted according to the given
	 sort block, which accepts pair of items and returns true if
	 the first item is less than the second one."
        <category: 'sorting'>
	^(self copyEmptyForCollect: self size)
	    addAll: (self asSortedCollection: sortBlock);
	    yourself
    ]

    sort [
	"Sort the contents of the receiver according to the default
	 sort block, which uses #<= to compare items."
        <category: 'sorting'>
	self
	    replaceFrom: 1
	    to: self size
	    with: self asSortedCollection
	    startingAt: 1
    ]

    sort: sortBlock [
	"Sort the contents of the receiver according to the given
	 sort block, which accepts pair of items and returns true if
	 the first item is less than the second one."
        <category: 'sorting'>
	self
	    replaceFrom: 1
	    to: self size
	    with: (self asSortedCollection: sortBlock)
	    startingAt: 1
    ]

    matchSubCollection: aSubCollection startingAt: anIndex [
	"Private - Answer whether the items from index anIndex match those in
	 aSubCollection. The first item is ignored"

	<category: 'private methods'>
	| ourIndex |
	ourIndex := anIndex.
	2 to: aSubCollection size
	    do: 
		[:index | 
		ourIndex := ourIndex + 1.
		(self at: ourIndex) = (aSubCollection at: index) ifFalse: [^false]].
	^true
    ]

    countSubCollectionOccurrencesOf: aSubCollection [
	<category: 'private methods'>
	| colIndex subColIndex count |
	colIndex := 1.
	count := 0.
	
	[subColIndex := self indexOfSubCollection: aSubCollection
		    startingAt: colIndex.
	subColIndex > 0] 
		whileTrue: 
		    [count := count + 1.
		    colIndex := subColIndex + aSubCollection size].
	^count
    ]

    size [
	"Answer a dummy size of 0, so that SequenceableCollection>>#do: works."

	<category: 'testing collections'>
	^0
    ]

    growSize [
	<category: 'private methods'>
	^(self size max: 8)
    ]

    swap: anIndex with: anotherIndex [
	"Swap the item at index anIndex with the item at index
	 another index"

	<category: 'manipulation'>
	| saved |
	saved := self at: anIndex.
	self at: anIndex put: (self at: anotherIndex).
	self at: anotherIndex put: saved
    ]

]

