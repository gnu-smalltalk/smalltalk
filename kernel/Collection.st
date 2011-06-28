"======================================================================
|
|   Collection Method Definitions
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



Iterable subclass: Collection [
    
    <category: 'Collections'>
    <comment: 'I am an abstract class.  My instances are collections of objects.  My
subclasses may place some restrictions or add some definitions to how
the objects are stored or organized; I say nothing about this.  I merely
provide some object creation and access routines for general collections
of objects.'>

    Collection class >> from: anArray [
	"Convert anArray to an instance of the receiver.  anArray is
	 structured such that the instance can be conveniently and fully
	 specified using brace-syntax, possibly by imposing some
	 additional structure on anArray."

	<category: 'instance creation'>
	^self withAll: anArray
    ]

    Collection class >> withAll: aCollection [
	"Answer a collection whose elements are all those in aCollection"

	<category: 'instance creation'>
	^(self new)
	    addAll: aCollection;
	    yourself
    ]

    Collection class >> with: anObject [
	"Answer a collection whose only element is anObject"

	<category: 'instance creation'>
	^(self new)
	    add: anObject;
	    yourself
    ]

    Collection class >> with: firstObject with: secondObject [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new)
	    add: firstObject;
	    add: secondObject;
	    yourself
    ]

    Collection class >> with: firstObject with: secondObject with: thirdObject [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new)
	    add: firstObject;
	    add: secondObject;
	    add: thirdObject;
	    yourself
    ]

    Collection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new)
	    add: firstObject;
	    add: secondObject;
	    add: thirdObject;
	    add: fourthObject;
	    yourself
    ]

    Collection class >> with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject [
	"Answer a collection whose only elements are the parameters in the order
	 they were passed"

	<category: 'instance creation'>
	^(self new)
	    add: firstObject;
	    add: secondObject;
	    add: thirdObject;
	    add: fourthObject;
	    add: fifthObject;
	    yourself
    ]

    Collection class >> join: aCollection [
	"Answer a collection formed by treating each element in
	 aCollection as a `withAll:' argument collection to be added to a
	 new instance."

	<category: 'instance creation'>
	| newInst |
	newInst := self 
		    new: (aCollection inject: 0 into: [:size :each | size + each size]).
	aCollection do: [:each | newInst addAll: each].
	^newInst
    ]

    Collection class >> isUnicode [
	"Answer true; the receiver is able to store arbitrary
	 Unicode characters."

	<category: 'multibyte encodings'>
	^true
    ]

    , anIterable [
	"Append anIterable at the end of a copy of the receiver (using #add:),
	 and answer a new collection"

	<category: 'copying SequenceableCollections'>
	^(self copyEmpty: self size + anIterable size)
	    addAll: self;
	    addAll: anIterable;
	    yourself
    ]

    add: newObject [
	"Add newObject to the receiver, answer it"

	<category: 'adding'>
	self subclassResponsibility
    ]

    addAll: aCollection [
	"Adds all the elements of 'aCollection' to the receiver, answer
	 aCollection"

	<category: 'adding'>
	aCollection do: [:element | self add: element].
	^aCollection
    ]

    empty [
	"Remove everything from the receiver."

	<category: 'removing'>
	^self become: self copyEmpty
    ]

    removeAllSuchThat: aBlock [
	"Remove from the receiver all objects for which aBlock returns true."

	<category: 'removing'>
	self removeAll: (self select: aBlock) ifAbsent: []
    ]

    remove: oldObject ifAbsent: anExceptionBlock [
	"Remove oldObject from the receiver. If absent, evaluate anExceptionBlock
	 and answer the result, else answer oldObject."

	<category: 'removing'>
	self subclassResponsibility
    ]

    remove: oldObject [
	"Remove oldObject from the receiver. If absent, fail, else
	 answer oldObject."

	<category: 'removing'>
	^self remove: oldObject
	    ifAbsent: [SystemExceptions.NotFound signalOn: oldObject what: 'object']
    ]

    removeAll: aCollection [
	"Remove each object in aCollection, answer aCollection, fail if some
	 of them is absent. Warning: this could leave the collection in a
	 semi-updated state."

	<category: 'removing'>
	aCollection do: [:element | self remove: element].
	^aCollection
    ]

    removeAll: aCollection ifAbsent: aBlock [
	"Remove each object in aCollection, answer aCollection; if some
	 element is absent, pass it to aBlock."

	<category: 'removing'>
	aCollection 
	    do: [:element | self remove: element ifAbsent: [aBlock cull: element]].
	^aCollection
    ]

    isSequenceable [
	"Answer whether the receiver can be accessed by a numeric index with
	 #at:/#at:put:."

	<category: 'testing collections'>
	^false
    ]

    capacity [
	"Answer how many elements the receiver can hold before having to grow."

	<category: 'testing collections'>
	^self basicSize
    ]

    includesAllOf: aCollection [
	"Answer whether we include all of the objects in aCollection"

	<category: 'testing collections'>
	^self allSatisfy: [:element | aCollection includes: element ]
    ]

    includesAnyOf: aCollection [
	"Answer whether we include any of the objects in aCollection"

	<category: 'testing collections'>
	^self anySatisfy: [:element | aCollection includes: element ]
    ]

    includes: anObject [
	"Answer whether we include anObject"

	<category: 'testing collections'>
	self do: [:element | anObject = element ifTrue: [^true]].
	^false
    ]

    identityIncludes: anObject [
	"Answer whether we include the anObject object"

	<category: 'testing collections'>
	self do: [:element | anObject == element ifTrue: [^true]].
	^false
    ]

    isEmpty [
	"Answer whether we are (still) empty"

	<category: 'testing collections'>
	^self size == 0
    ]

    notEmpty [
	"Answer whether we include at least one object"

	<category: 'testing collections'>
	^self size > 0
    ]

    occurrencesOf: anObject [
	"Answer how many occurrences of anObject we include"

	<category: 'testing collections'>
	| count |
	count := 0.
	self do: [:element | anObject == element ifTrue: [count := count + 1]].
	^count
    ]

    size [
	"Answer how many objects we include"

	<category: 'testing collections'>
	| count |
	count := 0.
	self do: [:element | count := count + 1].
	^count
    ]

    anyOne [
	"Answer an unspecified element of the collection."

	<category: 'enumeration'>
	self do: [:each | ^each].
	^SystemExceptions.EmptyCollection signalOn: self
    ]

    join [
	"Answer a new collection like my first element, with all the
	 elements (in order) of all my elements, which should be
	 collections.
	 
	 I use my first element instead of myself as a prototype because
	 my elements are more likely to share the desired properties than
	 I am, such as in:
	 
	 #('hello, ' 'world') join => 'hello, world'"

	<category: 'concatenating'>
	^self isEmpty ifTrue: [#()] ifFalse: [self anyOne species join: self]
    ]

    readStream [
        "Answer a stream that gives elements of the receiver"

	<category: 'enumeration'>
	^Generator on: self do: [ :gen :each | gen yield: each ]
    ]

    select: aBlock [
	"Answer a new instance of a Collection containing all the elements
	 in the receiver which, when passed to aBlock, answer true"

	<category: 'enumeration'>
	| newCollection |
	newCollection := self copyEmpty.
	self 
	    do: [:element | (aBlock value: element) ifTrue: [newCollection add: element]].
	^newCollection
    ]

    reject: aBlock [
	"Answer a new instance of a Collection containing all the elements
	 in the receiver which, when passed to aBlock, don't answer true"

	<category: 'enumeration'>
	| newCollection |
	newCollection := self copyEmpty.
	self 
	    do: [:element | (aBlock value: element) ifFalse: [newCollection add: element]].
	^newCollection
    ]

    collect: aBlock [
	"Answer a new instance of a Collection containing all the results
	 of evaluating aBlock passing each of the receiver's elements"

	<category: 'enumeration'>
	| newCollection |
	newCollection := self copyEmptyForCollect.
	self do: [:element | newCollection add: (aBlock value: element)].
	^newCollection
    ]

    gather: aBlock [
	"Answer a new instance of a Collection containing all the results
	 of evaluating aBlock, joined together.  aBlock should return
	 collections.  The result is the same kind as the first collection,
	 returned by aBlock (as for #join)."

	<category: 'enumeration'>
	^(self collect: aBlock) join
    ]

    asArray [
	"Answer an Array containing all the elements in the receiver"

	<category: 'converting'>
	^(Array new: self size)
	    replaceFrom: 1
		to: self size
		with: self;
	    yourself
    ]

    asByteArray [
	"Answer a ByteArray containing all the elements in the receiver"

	<category: 'converting'>
	^(ByteArray new: self size)
	    replaceFrom: 1
		to: self size
		with: self;
	    yourself
    ]

    asBag [
	"Answer a Bag containing all the elements in the receiver"

	<category: 'converting'>
	^(Bag new: self size)
	    addAll: self;
	    yourself
    ]

    asSet [
	"Answer a Set containing all the elements in the receiver with no
	 duplicates"

	<category: 'converting'>
	^(Set new: self size * 2)
	    addAll: self;
	    yourself
    ]

    asString [
	"Answer a String containing all the elements in the receiver"

	<category: 'converting'>
	^(String new: self size)
	    replaceFrom: 1
		to: self size
		with: self;
	    yourself
    ]

    asUnicodeString [
	"Answer a UnicodeString containing all the elements in the receiver"

	<category: 'converting'>
	^(UnicodeString new: self size)
	    replaceFrom: 1
		to: self size
		with: self;
	    yourself
    ]

    asOrderedCollection [
	"Answer an OrderedCollection containing all the elements in the receiver"

	<category: 'converting'>
	^(OrderedCollection new: self size * 2)
	    addAll: self;
	    yourself
    ]

    sorted [
	"Return a sequenceable collection with the contents of the receiver
         sorted according to the default sort block, which uses #<=
         to compare items."
        <category: 'sorting'>
	^(Array new: self size)
	    replaceFrom: 1
	    to: self size
	    with: self asSortedCollection
	    startingAt: 1
    ]

    sorted: sortBlock [
	"Return a sequenceable collection with the contents of the receiver
         sorted according to the given sort block, which accepts pair of items
         and returns true if the first item is less than the second one."
        <category: 'sorting'>
	^(Array new: self size)
	    replaceFrom: 1
	    to: self size
	    with: (self asSortedCollection: sortBlock)
	    startingAt: 1
    ]

    asSortedCollection [
	"Answer a SortedCollection containing all the elements in the receiver
	 with the default sort block - [ :a :b | a <= b ]"

	<category: 'converting'>
	^(SortedCollection new: self size + 10)
	    addAll: self;
	    yourself
    ]

    asSortedCollection: aBlock [
	"Answer a SortedCollection whose elements are the elements of the receiver,
	 sorted according to the sort block aBlock"

	<category: 'converting'>
	^(self asSortedCollection)
	    sortBlock: aBlock;
	    yourself
    ]

    copyReplacing: targetObject withObject: newObject [
	"Copy replacing each object which is = to targetObject
	 with newObject"

	<category: 'copying Collections'>
	^self 
	    collect: [:each | each = targetObject ifFalse: [each] ifTrue: [newObject]]
    ]

    copyWith: newElement [
	"Answer a copy of the receiver to which newElement is added"

	<category: 'copying Collections'>
	^(self copy)
	    add: newElement;
	    yourself
    ]

    copyWithout: oldElement [
	"Answer a copy of the receiver to which all occurrences of oldElement are
	 removed"

	<category: 'copying Collections'>
	^self reject: [:element | element = oldElement]
    ]

    copyEmpty [
	"Answer an empty copy of the receiver"

	<category: 'private'>
	^self copyEmpty: self basicSize
    ]

    copyEmpty: newSize [
	"Answer an empty copy of the receiver whose size is newSize"

	<category: 'private'>
	^self species new: newSize
    ]

    copyEmptyForCollect: size [
	"Answer an empty copy of the receiver, with the class answered by the
	 collect: method."

	<category: 'private'>
	^self copyEmpty: size
    ]

    copyEmptyForCollect [
	"Answer an empty copy of the receiver, with the class answered by the
	 collect: method."

	<category: 'private'>
	^self copyEmpty
    ]

    rehash [
	"Private - Do nothing, present for consistency in protocol"

	<category: 'private'>
	
    ]

    examineOn: aStream [
	"Print all the instance variables and objects in the receiver on aStream"

	<category: 'printing'>
	| instVars output object |
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
	self do: 
		[:obj | 
		| output |
		output := [obj printString] on: Error
			    do: 
				[:ex | 
				ex 
				    return: '%1 %2' % 
						{obj class article.
						obj class name asString}].
		aStream
		    nextPutAll: '    ';
		    nextPutAll: output;
		    nl].
	aStream
	    nextPutAll: '  ]';
	    nl
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream nextPutAll: self class storeString.
	aStream nextPutAll: ' ('.
	self do: 
		[:element | 
		element printOn: aStream.
		aStream space].
	aStream nextPut: $)
    ]

    displayLines [
	"Print each element of the receiver to a line on standard output."

	<category: 'printing'>
	self do: [:each | Transcript display: each; nl]
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	| noElements |
	aStream nextPut: $(.
	aStream nextPutAll: self class storeString.
	aStream nextPutAll: ' new'.
	noElements := true.
	self do: 
		[:element | 
		aStream nextPutAll: ' add: '.
		element storeOn: aStream.
		aStream nextPut: $;.
		noElements := false].
	noElements ifFalse: [aStream nextPutAll: ' yourself'].
	aStream nextPut: $)
    ]

    mourn: anObject [
	"Private - anObject has been found to have a weak key, remove it
	 and possibly finalize the key."

	<category: 'finalization'>
	self remove: anObject ifAbsent: [].
	self == Object finalizableObjects ifTrue: [anObject key finalize]
    ]
]
