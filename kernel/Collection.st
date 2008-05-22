"======================================================================
|
|   Collection Method Definitions
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



Object subclass: Collection [
    
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
	self removeAll: (self select: aBlock) ifAbsent: [:each | ]
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
	    do: [:element | self remove: element ifAbsent: [aBlock value: element]].
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
	self do: [:each | ^each]
    ]

    beConsistent [
	"This method is private, but it is quite interesting so it is
	 documented. It ensures that a collection is in a consistent
	 state before attempting to iterate on it; its presence reduces
	 the number of overrides needed by collections who try to
	 amortize their execution times.  The default implementation
	 does nothing, so it is optimized out by the virtual machine
	 and so it loses very little on the performance side.  Note
	 that descendants of Collection have to call it explicitly
	 since #do: is abstract in Collection."

	<category: 'enumeration'>
	
    ]

    readStream [
        "Answer a stream that gives elements of the receiver"

	<category: 'enumeration'>
	^Generator on: self do: [ :gen :each | gen yield: each ]
    ]

    do: aBlock [
	"Enumerate each object of the receiver, passing them to aBlock"

	<category: 'enumeration'>
	self subclassResponsibility
    ]

    do: aBlock separatedBy: separatorBlock [
	"Enumerate each object of the receiver, passing them to aBlock.
	 Between every two invocations of aBlock, invoke separatorBlock"

	<category: 'enumeration'>
	| first |
	first := true.
	self do: 
		[:each | 
		first ifTrue: [first := false] ifFalse: [separatorBlock value].
		aBlock value: each]
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

    detect: aBlock ifNone: exceptionBlock [
	"Search the receiver for an element for which aBlock returns true.
	 If some does, answer it. If none does, answer the result of evaluating
	 aBlock"

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^element]].
	^exceptionBlock value
    ]

    count: aBlock [
	"Count the elements of the receiver for which aBlock returns true,
	 and return their number."

	<category: 'enumeration'>
	| count |
	count := 0.
	self do: [:element | (aBlock value: element) ifTrue: [count := count + 1]].
	^count
    ]

    gather: aBlock [
	"Answer a new instance of a Collection containing all the results
	 of evaluating aBlock, joined together.  aBlock should return
	 collections.  The result is the same kind as the first collection,
	 returned by aBlock (as for #join)."

	<category: 'enumeration'>
	^(self collect: aBlock) join
    ]

    allSatisfy: aBlock [
	"Search the receiver for an element for which aBlock returns false.
	 Answer true if none does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifFalse: [^false]].
	^true
    ]

    noneSatisfy: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 Answer true if none does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^false]].
	^true
    ]

    anySatisfy: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 Answer true if some does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^true]].
	^false
    ]

    conform: aBlock [
	"Search the receiver for an element for which aBlock returns false.
	 Answer true if none does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifFalse: [^false]].
	^true
    ]

    contains: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 Answer true if some does, false otherwise."

	<category: 'enumeration'>
	self do: [:element | (aBlock value: element) ifTrue: [^true]].
	^false
    ]

    detect: aBlock [
	"Search the receiver for an element for which aBlock returns true.
	 If some does, answer it. If none does, fail"

	<category: 'enumeration'>
	^self detect: aBlock
	    ifNone: [SystemExceptions.NotFound signal: 'object not found']
    ]

    fold: binaryBlock [
	"First, pass to binaryBlock the first and second elements of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation,
	 or the first element if the collection has size 1.  Fail if the collection
	 is empty."

	<category: 'enumeration'>
	| result marker |
	self isEmpty ifTrue: [^SystemExceptions.EmptyCollection signalOn: self].
	result := marker := Object new.
	self do: 
		[:element | 
		result := result == marker 
			    ifTrue: [element]
			    ifFalse: [binaryBlock value: result value: element]].
	^result
    ]

    inject: thisValue into: binaryBlock [
	"First, pass to binaryBlock thisValue and the first element of the
	 receiver; for each subsequent element, pass the result of the previous
	 evaluation and an element. Answer the result of the last invocation."

	<category: 'enumeration'>
	| result |
	result := thisValue.
	self do: [:element | result := binaryBlock value: result value: element].
	^result
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

    inspect [
	"Print all the instance variables and objects in the receiver on the
	 Transcript"

	<category: 'printing'>
	| instVars output object |
	self beConsistent.
	Transcript
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
		Transcript
		    nextPutAll: '  ';
		    nextPutAll: (instVars at: i);
		    nextPutAll: ': ';
		    nextPutAll: output;
		    nl].
	Transcript
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
		Transcript
		    nextPutAll: '    ';
		    nextPutAll: output;
		    nl].
	Transcript
	    nextPutAll: '  ]';
	    nl
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream nextPutAll: self classNameString.
	aStream nextPutAll: ' ('.
	self do: 
		[:element | 
		element printOn: aStream.
		aStream space].
	aStream nextPut: $)
    ]

    storeOn: aStream [
	"Store Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	| noElements |
	aStream nextPut: $(.
	aStream nextPutAll: self classNameString.
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
