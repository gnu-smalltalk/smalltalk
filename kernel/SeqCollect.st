"======================================================================
|
|   SequenceableCollection Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2006,2007
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


Collection subclass: #SequenceableCollection
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Collections-Sequenceable'
!

SequenceableCollection comment: 
'My instances represent collections of objects that are ordered.  I provide
some access and manipulation methods.' !


!SequenceableCollection class methodsFor: 'instance creation'!

streamContents: aBlock
    "Create a ReadWriteStream on an empty instance of the receiver;
     pass the stream to aBlock, then retrieve its contents and
     answer them."
    | stream |
    stream := ReadWriteStream on: (self new: 10).
    stream truncate.
    aBlock value: stream.
    ^stream contents
!

join: aCollection separatedBy: sepCollection
    "Where aCollection is a collection of SequenceableCollections,
     answer a new instance with all the elements therein, in order,
     each separated by an occurrence of sepCollection."
    | newInst start |
    aCollection isEmpty ifTrue: [ ^self new: 0 ].
    newInst := self new: (aCollection
	inject: sepCollection size * (aCollection size - 1)
	into: [:size :each | size + each size]).

    aCollection
	do: [:subColl | newInst addAll: subColl]
	separatedBy: [ newInst addAll: sepCollection].
    ^newInst
! !


!SequenceableCollection methodsFor: 'testing'!

inspect
    "Print all the instance variables and context of the receiver on the
     Transcript"

    | instVars object output |
    self beConsistent.
    Transcript
	nextPutAll: 'An instance of ';
	print: self class;
	nl.

    instVars := self class allInstVarNames.
    1 to: instVars size do: [ :i |
	object := self instVarAt: i.
    	output := [ object printString ]
		      on: Error
		      do: [ :ex | ex return: ('%1 %2'
				      % { object class article.
				          object class name asString }) ].

	Transcript nextPutAll: '  ';
	    nextPutAll: (instVars at: i);
	    nextPutAll: ': ';
	    nextPutAll: output;
	    nl ].

    Transcript nextPutAll: '  contents: ['; nl.

    self keysAndValuesDo: [ :i :obj || output |
    	output := [ obj printString ]
		      on: Error
		      do: [ :ex | ex return: ('%1 %2'
				      % { obj class article.
				          obj class name asString }) ].
	Transcript 
	    nextPutAll: '    [';
	    print: i;
	    nextPutAll: ']: ';
	    nextPutAll: output;
	    nl
    ].
    Transcript nextPutAll: '  ]'; nl
!


isSequenceable
    "Answer whether the receiver can be accessed by a numeric index with
     #at:/#at:put:."
    ^true
!

= aCollection
    "Answer whether the receiver's items match those in aCollection"

    self class == aCollection class ifFalse: [^false].
    self size = aCollection size ifFalse: [^false].

    1 to: self size do: [ :i |
	(self at: i) = (aCollection at: i) ifFalse: [^false]
    ].
    ^true
!

hash
    "Answer an hash value for the receiver"

    "Don't like this hash function; it can be made much better"
    | hash carry |
    hash := self size.
    self do: [ :element |
	carry := (hash bitAnd: 16r20000000) > 0.
	hash := hash bitAnd: 16r1FFFFFFF.
	hash := hash bitShift: 1.
	carry ifTrue: [ hash := hash bitOr: 1 ].

	hash := hash bitXor: element hash
    ].
    ^hash
! !



!SequenceableCollection methodsFor: 'basic'!

at: anIndex ifAbsent: aBlock
    "Answer the anIndex-th item of the collection, or evaluate aBlock
     and answer the result if the index is out of range"
    (anIndex between: 1 and: self size) ifFalse: [ ^aBlock value ].
    ^self at: anIndex
!

atAll: keyCollection
    "Answer a collection of the same kind returned by #collect:, that
     only includes the values at the given indices. Fail if any of
     the values in keyCollection is out of bounds for the receiver."
    | result |
    result := self copyEmptyForCollect: keyCollection size.
    keyCollection do: [ :key | result add: (self at: key) ].
    ^result!

atAll: aCollection put: anObject
    "Put anObject at every index contained in aCollection"
    aCollection do: [ :index | self at: index put: anObject ]
!

atAllPut: anObject
    "Put anObject at every index in the receiver"
    1 to: self size do: [ :i | self at: i put: anObject ]
!

after: oldObject
    "Return the element after oldObject.  Error if oldObject not found or
    if no following object is available"

    | i |
    i := self indexOf: oldObject.
    i = 0 ifTrue: [
	^SystemExceptions.NotFound signalOn: oldObject what: 'object' ].
    ^self at: i + 1
!

before: oldObject
    "Return the element before oldObject.  Error if oldObject not found or
    if no preceding object is available"

    | i |
    i := self indexOf: oldObject.
    i = 0 ifTrue: [
	^SystemExceptions.NotFound signalOn: oldObject what: 'object' ].
    ^self at: i - 1
!

allButFirst
    "Answer a copy of the receiver without the first object."
    ^self copyFrom: 2
!

allButFirst: n
    "Answer a copy of the receiver without the first n objects."
    ^self copyFrom: n + 1
!

allButLast
    "Answer a copy of the receiver without the last object."
    ^self copyFrom: 1 to: self size - 1
!

allButLast: n
    "Answer a copy of the receiver without the last n objects."
    ^self copyFrom: 1 to: self size - n
!

first
    "Answer the first item in the receiver"
    ^self at: 1
!

second
    "Answer the second item in the receiver"
    ^self at: 2
!

third
    "Answer the third item in the receiver"
    ^self at: 3
!

fourth
    "Answer the fourth item in the receiver"
    ^self at: 4
!

first: n
    "Answer the first n items in the receiver"
    ^self copyFrom: 1 to: n
!

last: n
    "Answer the last n items in the receiver"
    ^self copyFrom: self size - n + 1
!

last
    "Answer the last item in the receiver"
    ^self at: self size
!

includes: anObject
    "Answer whether we include anObject"

    "Reimplemented to avoid an expensive full-block"
    1 to: self size do: [ :index |
	anObject = (self at: index) ifTrue: [ ^true ]
    ].
    ^false
!

identityIncludes: anObject
    "Answer whether we include the anObject object"

    "Reimplemented to avoid an expensive full-block"
    1 to: self size do: [ :index |
	anObject == (self at: index) ifTrue: [ ^true ]
    ].
    ^false
!

indexOfSubCollection: aSubCollection startingAt: anIndex ifAbsent: exceptionBlock
    "Answer the first index > anIndex at which starts a sequence of
     items matching aSubCollection.
     Invoke exceptionBlock and answer its result if no such sequence is found"

    | selfSize subSize |
    subSize  := aSubCollection size.
    selfSize := self size.
    anIndex + subSize - 1 <= selfSize ifTrue: [
	anIndex to: selfSize - subSize + 1 do: [ :index |
	    (self at: index) = (aSubCollection at: 1) ifTrue: [
		(self matchSubCollection: aSubCollection startingAt: index)
		    ifTrue: [^index]
	    ]
	]
    ].
    ^exceptionBlock value
!

indexOfSubCollection: aSubCollection startingAt: anIndex
    "Answer the first index > anIndex at which starts a sequence of
     items matching aSubCollection. Answer 0 if no such sequence is found."

    ^self indexOfSubCollection: aSubCollection startingAt: anIndex
    	ifAbsent: [ ^0 ]
!


indexOf: anElement startingAt: anIndex ifAbsent: exceptionBlock
    "Answer the first index > anIndex which contains anElement.
     Invoke exceptionBlock and answer its result if no item is found"

    (anIndex < 1) | (anIndex > self size) ifTrue: [
	"If anIndex is just past the end of the collection, don't raise
	 an error (this is the most generic solution that avoids that
	 #indexOf: fails when the collection is empty."
	anIndex = (self size + 1)
	    ifTrue: [ ^exceptionBlock value ]
	    ifFalse: [ ^self checkIndexableBounds: anIndex ]
    ].

    anIndex to: self size do: [ :index |
	(self at: index) = anElement ifTrue: [ ^index ].
    ].
    ^exceptionBlock value
!

identityIndexOf: anObject startingAt: anIndex ifAbsent: exceptionBlock
    "Answer the first index > anIndex which contains an object exactly
     identical to anObject.
     Invoke exceptionBlock and answer its result if no item is found"

    (anIndex < 1) | (anIndex > self size) ifTrue: [
	"If anIndex is just past the end of the collection, don't raise
	 an error (this is the most generic solution that avoids that
	 #indexOf: fails when the collection is empty."
	anIndex = (self size + 1)
	    ifTrue: [ ^exceptionBlock value ]
	    ifFalse: [ ^self checkIndexableBounds: anIndex ]
    ].

    anIndex to: self size do: [ :index |
	(self at: index) == anObject ifTrue: [ ^index ].
    ].
    ^exceptionBlock value
!

indexOfSubCollection: aSubCollection
    "Answer the first index > anIndex at which starts a sequence of
     items matching aSubCollection. Answer 0 if no such sequence is found."

    ^self indexOfSubCollection: aSubCollection startingAt: 1
    	ifAbsent: [ ^0 ]
!

indexOfSubCollection: aSubCollection ifAbsent: exceptionBlock
    "Answer the first index > anIndex at which starts a sequence of
     items matching aSubCollection. Answer 0 if no such sequence is found."

    ^self indexOfSubCollection: aSubCollection startingAt: 1
    	ifAbsent: exceptionBlock
!

indexOf: anElement startingAt: anIndex
    "Answer the first index > anIndex which contains anElement.
     Answer 0 if no item is found"
    ^self indexOf: anElement startingAt: anIndex ifAbsent: [ ^0 ]
!

indexOf: anElement ifAbsent: exceptionBlock
    "Answer the index of the first occurrence of anElement in the receiver.
     Invoke exceptionBlock and answer its result if no item is found"
    ^self indexOf: anElement startingAt: 1 ifAbsent: exceptionBlock
!

indexOf: anElement
    "Answer the index of the first occurrence of anElement in the receiver.
     Answer 0 if no item is found"
    ^self indexOf: anElement startingAt: 1 ifAbsent: [ ^0 ]
!

identityIndexOf: anElement startingAt: anIndex
    "Answer the first index > anIndex which contains an object identical
     to anElement. Answer 0 if no item is found"
    ^self identityIndexOf: anElement startingAt: anIndex ifAbsent: [ ^0 ]
!

identityIndexOf: anElement ifAbsent: exceptionBlock
    "Answer the index of the first occurrence of an object identical to
     anElement in the receiver. Invoke exceptionBlock and answer its
     result if no item is found"
    ^self identityIndexOf: anElement startingAt: 1 ifAbsent: exceptionBlock
!

identityIndexOf: anElement
    "Answer the index of the first occurrence of an object identical to
     anElement in the receiver. Answer 0 if no item is found"
    ^self identityIndexOf: anElement startingAt: 1 ifAbsent: [ ^0 ]
! !


!SequenceableCollection methodsFor: 'replacing items'!

replaceAll: anObject with: anotherObject
    "In the receiver, replace every occurrence of anObject with anotherObject."
    1 to: self size do: [ :index |
	(self at: index) = anObject ifTrue: [
	    self at: index put: anotherObject.
	]
    ].
!

replaceFrom: start to: stop with: replacementCollection startingAt: repStart
    "Replace the items from start to stop with replacementCollection's items
     from repStart to repStart+stop-start"

    | delta maxStop minStop |
    minStop := start - 1.
    maxStop := self size min: minStop + replacementCollection size.
    (minStop <= stop and: [ stop <= maxStop ]) ifFalse: [
        ^SystemExceptions.ArgumentOutOfRange
            signalOn: stop
            mustBeBetween: minStop and: maxStop ].

    delta := start - repStart.
    start to: stop do: [ :i |
        self at: i
             put: (replacementCollection at: i - delta)
    ]
!

replaceFrom: start to: stop with: replacementCollection
    "Replace the items from start to stop with replacementCollection's items
     from 1 to stop-start+1 (in unexpected order if the collection is not
     sequenceable)."

    | i |
    i := start - 1.
    stop - i = replacementCollection size
        ifFalse: [ ^SystemExceptions.InvalidSize signalOn: replacementCollection  size ].

    replacementCollection do: [ :each |
        self at: (i := i + 1) put: each
    ]
! 

replaceFrom: anIndex to: stopIndex withObject: replacementObject
    "Replace every item from start to stop with replacementObject."

    (stopIndex < anIndex) ifTrue: [
	^SystemExceptions.ArgumentOutOfRange
	    signalOn: stopIndex
	    mustBeBetween: anIndex and: self size ].

    anIndex to: stopIndex do: [ :index |
	self at: index put: replacementObject.
    ]
! !



!SequenceableCollection methodsFor: 'copying SequenceableCollections'!

copyUpTo: anObject
    "Answer a new collection holding all the elements of the receiver
     from the first up to the first occurrence of anObject, excluded."

    ^self copyFrom: 1 to:
	(self indexOf: anObject ifAbsent: [
	    ^SystemExceptions.NotFound signalOn: anObject what: 'object' ]) - 1.
!

copyReplaceFrom: start to: stop withObject: anObject
    "Answer a new collection of the same class as the receiver that contains the
    same elements as the receiver, in the same order, except for elements from
    index `start' to index `stop'.
    
    If start < stop, these are replaced by stop-start+1 copies of anObject.
    Instead, If start = (stop + 1), then every element of the receiver
    will be present in the answered copy; the operation will be an append if
    stop is equal to the size of the receiver or, if it is not, an insert before
    index `start'."

    | newSize repSize result |
    (stop - start < -1)
	ifTrue: [ ^SystemExceptions.ArgumentOutOfRange signalOn: stop mustBeBetween: start - 1 and: self size ].

    (stop >= start) ifTrue: [ ^self copy atAll: (start to: stop) put: anObject; yourself ].

    newSize := self size - (stop - start).

    result := self copyEmpty: newSize.
    start > 1 ifTrue: [
	self from: 1 to: start - 1 do: [ :each | result add: each ]
    ].
    result add: anObject.
    stop < self size ifTrue: [
	self from: stop + 1 to: self size do: [ :each | result add: each ]
    ].
    ^result
!

, aSequenceableCollection
    "Append aSequenceableCollection at the end of the receiver (using #add:),
     and answer a new collection"

    ^(self copyEmpty: self size + aSequenceableCollection size)
	addAll: self;
	addAll: aSequenceableCollection;
	yourself
!

copyFrom: start
    "Answer a new collection containing all the items in the receiver from the
     start-th."
    ^self copyFrom: start to: self size!

copyFrom: start to: stop
    "Answer a new collection containing all the items in the receiver from the
     start-th and to the stop-th"

    | len coll |
    stop < start ifTrue: [
	stop = (start - 1) ifTrue: [^self copyEmpty: 0].
        ^SystemExceptions.ArgumentOutOfRange
            signalOn: stop
            mustBeBetween: start - 1 and: self size ].

    len := stop - start + 1.
    coll := self copyEmpty: len + 10.
    self from: start to: stop do: [ :each | coll add: each ].
    ^coll
!

copyReplaceAll: oldSubCollection with: newSubCollection
    "Answer a new collection in which all the sequences matching
     oldSubCollection are replaced with newSubCollection"

    | numOld newCollection sizeDifference newSubSize oldSubSize
      oldStart copySize index |
    numOld := self countSubCollectionOccurrencesOf: oldSubCollection.
    newSubSize := newSubCollection size.
    oldSubSize := oldSubCollection size.
    sizeDifference := newSubSize - oldSubSize.
    newCollection := self copyEmpty: self size + (sizeDifference * numOld).
    oldStart := 1.

    [
	index := self indexOfSubCollection: oldSubCollection startingAt: oldStart
	    ifAbsent: [
		"Copy the remaining part of self onto the tail of the new collection."
		self from: oldStart to: self size do: [ :each |
		    newCollection add: each ].
		^newCollection
	    ].

	copySize := index - oldStart.
	self from: oldStart to: oldStart + copySize - 1 do: [ :each |
		    newCollection add: each ].

	newCollection addAll: newSubCollection.
    	oldStart := oldStart + copySize + oldSubSize
    ] repeat
!

copyReplaceFrom: start to: stop with: replacementCollection
    "Answer a new collection of the same class as the receiver that contains the
    same elements as the receiver, in the same order, except for elements from
    index `start' to index `stop'.
    
    If start < stop, these are replaced by the contents of the
    replacementCollection.  Instead, If start = (stop + 1), like in
    `copyReplaceFrom: 4 to: 3 with: anArray', then every element of the receiver
    will be present in the answered copy; the operation will be an append if
    stop is equal to the size of the receiver or, if it is not, an insert before
    index `start'."

    | newSize repSize result |
    (stop - start < -1)
	ifTrue: [ ^SystemExceptions.ArgumentOutOfRange signalOn: stop mustBeBetween: start - 1 and: self size ].

    repSize := replacementCollection size.
    newSize := self size + repSize - (stop - start + 1).

    result := self copyEmpty: newSize.
    start > 1 ifTrue: [
	self from: 1 to: start - 1 do: [ :each | result add: each ]
    ].
    result addAll: replacementCollection.
    stop < self size ifTrue: [
	self from: stop + 1 to: self size do: [ :each | result add: each ]
    ].

    ^result
! !



!SequenceableCollection methodsFor: 'concatenating'!

join
    "Answer a new collection like my first element, with all the
     elements (in order) of all my elements, which should be
     collections.

     I use my first element instead of myself as a prototype because
     my elements are more likely to share the desired properties than
     I am, such as in:

     #('hello, ' 'world') join => 'hello, world'"
    ^self isEmpty ifTrue: [#()]
		  ifFalse: [self first species join: self]
!

join: sepCollection
    "Answer a new collection like my first element, with all the
     elements (in order) of all my elements (which should be
     collections) separated by sepCollection.

     I use my first element instead of myself as a prototype because
     my elements are more likely to share the desired properties than
     I am, such as in:

     #('hello,' 'world') join: ' ' => 'hello, world'"
    ^self isEmpty
	ifTrue: [#()]
	ifFalse: [self first species join: self separatedBy: sepCollection]
! !



!SequenceableCollection methodsFor: 'enumerating'!

readStream
    "Answer a ReadStream streaming on the receiver"
    ^ReadStream on: self
! 

readWriteStream
    "Answer a ReadWriteStream which streams on the receiver"
    ^ReadWriteStream on: self
! 

anyOne
    "Answer an unspecified element of the collection."

    ^self at: 1
!

do: aBlock
    "Evaluate aBlock for all the elements in the sequenceable collection"
    
    1 to: self size do: [ :i | aBlock value: (self at: i) ].
!

do: aBlock separatedBy: sepBlock
    "Evaluate aBlock for all the elements in the sequenceable collection.
    Between each element, evaluate sepBlock without parameters."
    
    self isEmpty ifTrue: [ ^self ].
    aBlock value: (self at: 1).
    2 to: self size do: [ :i | 
	sepBlock value.
	aBlock value: (self at: i)
    ].
!

doWithIndex: aBlock
    "Evaluate aBlock for all the elements in the sequenceable collection,
     passing the index of each element as the second parameter.  This method
     is mantained for backwards compatibility and is not mandated by the
     ANSI standard; use #keysAndValuesDo:"

    1 to: self size do: [ :i | aBlock value: (self at: i) value: i ].
!

fold: binaryBlock
    "First, pass to binaryBlock the first and second elements of the
     receiver; for each subsequent element, pass the result of the previous
     evaluation and an element. Answer the result of the last invocation,
     or the first element if the collection has size 1.  Fail if the collection
     is empty."

    "This method is redefined from Collection for efficiency only"

    | result |
    self isEmpty
	ifTrue: [ ^SystemExceptions.EmptyCollection signalOn: self ].

    result := self at: 1.
    self from: 2 to: self size do: [ :element |
	result := binaryBlock value: result value: element
    ].
    ^result
!

keys
    "Return an Interval corresponding to the valid indices in the receiver."
    ^1 to: self size
!

keysAndValuesDo: aBlock
    "Evaluate aBlock for all the elements in the sequenceable collection,
     passing the index of each element as the first parameter and the
     element as the second."

    1 to: self size do: [ :i | aBlock value: i value: (self at: i) ].
!

from: startIndex to: stopIndex do: aBlock
    "Evaluate aBlock for all the elements in the sequenceable collection whose
     indices are in the range index to stopIndex"

    startIndex to: stopIndex do: [ :i | aBlock value: (self at: i) ].
!

from: startIndex to: stopIndex doWithIndex: aBlock
    "Evaluate aBlock for all the elements in the sequenceable collection whose
     indices are in the range index to stopIndex, passing the index of each
     element as the second parameter.  This method is mantained for backwards
     compatibility and is not mandated by the ANSI standard; use
     #from:to:keysAndValuesDo:"

    startIndex to: stopIndex do: [ :i | aBlock value: (self at: i) value: i ].
!

from: startIndex to: stopIndex keysAndValuesDo: aBlock
    "Evaluate aBlock for all the elements in the sequenceable collection whose
     indices are in the range index to stopIndex, passing the index of each
     element as the first parameter and the element as the second."

    startIndex to: stopIndex do: [ :i | aBlock value: i value: (self at: i) ].
!

findFirst: aBlock
    "Returns the index of the first element of the sequenceable collection
    for which aBlock returns true, or 0 if none"

    self doWithIndex: [ :each :i |
    	(aBlock value: each) ifTrue: [ ^i ].
    ].
    ^0
!

findLast: aBlock
    "Returns the index of the last element of the sequenceable collection
    for which aBlock returns true, or 0 if none does"

    | i |
    i := self size.
    self reverseDo: [ :each |
    	(aBlock value: each) ifTrue: [ ^i ].
    	i := i - 1
    ].
    ^0
!

reverse
    "Answer the receivers' contents in reverse order"
    | result |
    result := self copyEmptyForCollect.
    self reverseDo: [ :each | result add: each ].
    ^result
!

reverseDo: aBlock
    "Evaluate aBlock for all elements in the sequenceable collection, from the
     last to the first."

    self size to: 1 by: -1 do: [ :i | aBlock value: (self at: i) ].
!

with: aSequenceableCollection do: aBlock
    "Evaluate aBlock for each pair of elements took respectively from the re-
     ceiver and from aSequenceableCollection. Fail if the receiver has not
     the same size as aSequenceableCollection."

    self size = aSequenceableCollection size
    	ifFalse: [
	    ^SystemExceptions.InvalidSize signalOn: aSequenceableCollection ].

    1 to: self size do: [ :i |
    	aBlock value: (self at: i) value: (aSequenceableCollection at: i).
    ]
!

with: aSequenceableCollection collect: aBlock
    "Evaluate aBlock for each pair of elements took respectively from the re-
     ceiver and from aSequenceableCollection; answer a collection of the same
     kind of the receiver, made with the block's return values. Fail if the
     receiver has not the same size as aSequenceableCollection."

    | newCollection |
    self size = aSequenceableCollection size
    	ifFalse: [
	    ^SystemExceptions.InvalidSize signalOn: aSequenceableCollection ].

    newCollection := self copyEmptyForCollect.
    1 to: self size do: [ :i |
    	newCollection add:
    	    (aBlock value: (self at: i) value: (aSequenceableCollection at: i)).
    ].
    ^newCollection
! !



!SequenceableCollection methodsFor: 'private methods'!

matchSubCollection: aSubCollection startingAt: anIndex
    "Private - Answer whether the items from index anIndex match those in
     aSubCollection. The first item is ignored"
    | ourIndex |
    ourIndex := anIndex.
    2 to: aSubCollection size do: [ :index |
	ourIndex := ourIndex + 1.
	(self at: ourIndex) = (aSubCollection at: index)
	    ifFalse: [ ^false ].
    ].
    ^true
!

countSubCollectionOccurrencesOf: aSubCollection
    | colIndex subColIndex count |
    colIndex := 1.
    count := 0.
    [ subColIndex := self indexOfSubCollection: aSubCollection
    	    	    	 startingAt: colIndex.
      subColIndex > 0 ] whileTrue:
      	[ count := count + 1.
	  colIndex := subColIndex + aSubCollection size ].
    ^count
!

growSize
    ^self size
! !

