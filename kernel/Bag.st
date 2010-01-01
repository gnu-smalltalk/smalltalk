"======================================================================
|
|   Bag Method Definitions
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



Collection subclass: Bag [
    | contents |
    
    <category: 'Collections-Unordered'>
    <comment: 'My instances are unordered collections of objects.  You can think
of me as a set with a memory; that is, if the same object is added to me
twice, then I will report that that element has been stored twice.'>

    Bag class >> new [
	"Answer a new instance of the receiver"

	<category: 'basic'>
	^self basicNew initContents: 31
    ]

    Bag class >> new: size [
	"Answer a new instance of the receiver, with space for size distinct
	 objects"

	<category: 'basic'>
	^self basicNew initContents: (7 max: size)
    ]

    add: newObject withOccurrences: anInteger [
	"If anInteger > 0, add anInteger occurrences of newObject to the
	 receiver. If anInteger < 0, remove them. Answer newObject.  Fail
	 if newObject is nil."

	<category: 'adding'>
	| newOccurrences |
	newObject isNil 
	    ifTrue: 
		[SystemExceptions.InvalidArgument signalOn: newObject
		    reason: 'bag elements cannot be nil'].
	newOccurrences := contents at: newObject
		    put: (self occurrencesOf: newObject) + anInteger.
	newOccurrences <= 0 ifTrue: [contents removeKey: newObject].
	^newObject
    ]

    add: newObject [
	"Add an occurrence of newObject to the receiver. Answer newObject.
	 Fail if newObject is nil."

	<category: 'adding'>
	self add: newObject withOccurrences: 1.
	^newObject
    ]

    remove: oldObject ifAbsent: anExceptionBlock [
	"Remove oldObject from the collection and return it. If can't be
	 found, answer instead the result of evaluationg anExceptionBlock"

	<category: 'removing'>
	"Since we're using a dictionary, we need decrement the value until
	 it's zero, in which case we can then remove the object from the
	 dictionary"

	| count |
	count := self occurrencesOf: oldObject.
	count = 0 ifTrue: [^anExceptionBlock value].
	count = 1 
	    ifTrue: [contents removeKey: oldObject]
	    ifFalse: [contents at: oldObject put: count - 1].
	^oldObject
    ]

    sortedByCount [
	"Answer a collection of counts with elements, sorted by decreasing count."

	<category: 'extracting items'>
	| counts |
	counts := SortedCollection sortBlock: [:x :y | x >= y].
	contents keysAndValuesDo: [:key :count | counts add: count -> key].
	^counts asArray
    ]

    occurrencesOf: anObject [
	"Answer the number of occurrences of anObject found in the receiver"

	<category: 'testing collections'>
	^contents at: anObject ifAbsent: [0]
    ]

    includes: anObject [
	"Answer whether we include anObject"

	<category: 'testing collections'>
	^contents includesKey: anObject
    ]

    size [
	"Answer the total number of objects found in the receiver"

	<category: 'testing collections'>
	| count |
	count := 0.
	contents do: [:element | count := count + element].
	^count
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'testing collections'>
	^contents hash
    ]

    = aBag [
	"Answer whether the receiver and aBag contain the same objects"

	<category: 'testing collections'>
	self class == aBag class ifFalse: [^false].
	^contents = aBag contents
    ]

    asSet [
	"Answer a set with the elements of the receiver"

	<category: 'enumerating the elements of a collection'>
	^contents keys
    ]

    do: aBlock [
	"Evaluate the block for all members in the collection."

	"For Bags, we need to go through the contents dictionary, and
	 perform the block for as many occurrences of the objects as there
	 are."

	<category: 'enumerating the elements of a collection'>
	contents 
	    keysAndValuesDo: [:key :count | count timesRepeat: [aBlock value: key]]
    ]

    storeOn: aStream [
	"Put on aStream some Smalltalk code compiling to the receiver"

	<category: 'storing'>
	| noElements |
	aStream
	    nextPut: $(;
	    nextPutAll: self class storeString;
	    nextPutAll: ' new'.
	noElements := true.
	contents keysAndValuesDo: 
		[:key :count | 
		aStream
		    nextPutAll: ' add: ';
		    store: key;
		    nextPutAll: ' withOccurrences: ';
		    store: count;
		    nextPut: $;.
		noElements := false].
	noElements ifFalse: [aStream nextPutAll: '; yourself'].
	aStream nextPut: $)
    ]

    printOn: aStream [
	"Put on aStream a representation of the receiver"

	<category: 'printing'>
	aStream
	    nextPutAll: self class storeString;
	    nextPut: $(.
	contents keysAndValuesDo: 
		[:key :count | 
		aStream
		    print: key;
		    nextPut: $:;
		    print: count;
		    space].
	aStream nextPut: $)
    ]

    dictionaryClass [
	<category: 'private'>
	^LookupTable
    ]

    initContents: size [
	<category: 'private'>
	contents := self dictionaryClass new: size
    ]

    valuesAndCounts [
        "Answer a dictionary whose keys are distinct elements of the receiver
         and whose values are the number of occurrences of each element."
	<category: 'private'>
	^contents copy
    ]

    contents [
	<category: 'private'>
	^contents
    ]
]

