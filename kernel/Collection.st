"======================================================================
|
|   Collection Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2006
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



Object subclass: #Collection
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Collections'
!

Collection comment: 
'I am an abstract class.  My instances are collections of objects.  My
subclasses may place some restrictions or add some definitions to how
the objects are stored or organized; I say nothing about this.  I merely
provide some object creation and access routines for general collections
of objects.' !



!Collection class methodsFor: 'instance creation'!

from: anArray
    "Convert anArray to an instance of the receiver.  anArray is
     structured such that the instance can be conveniently and fully
     specified using brace-syntax, possibly by imposing some
     additional structure on anArray."
    ^self withAll: anArray
!

withAll: aCollection
    "Answer a collection whose elements are all those in aCollection"
    ^self new addAll: aCollection; yourself
!

with: anObject
    "Answer a collection whose only element is anObject"
    ^self new add: anObject; yourself
!

with: firstObject with: secondObject
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    ^self new add: firstObject; add: secondObject; yourself
!

with: firstObject with: secondObject with: thirdObject
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    ^self new add: firstObject; add: secondObject; add: thirdObject; yourself
!

with: firstObject with: secondObject with: thirdObject with: fourthObject
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    ^self new add: firstObject; add: secondObject; add: thirdObject;
    	add: fourthObject; yourself
!

with: firstObject with: secondObject with: thirdObject with: fourthObject with: fifthObject
    "Answer a collection whose only elements are the parameters in the order
     they were passed"
    ^self new add: firstObject; add: secondObject; add: thirdObject;
    	add: fourthObject; add: fifthObject; yourself
! !



!Collection methodsFor: 'adding'!

add: newObject
    "Add newObject to the receiver, answer it"
    self subclassResponsibility
!

addAll: aCollection
    "Adds all the elements of 'aCollection' to the receiver, answer
     aCollection"
    aCollection do: [ :element | self add: element ].
    ^aCollection
! !



!Collection methodsFor: 'removing'!

empty
    "Remove everything from the receiver."

    ^self become: self copyEmpty
!

remove: oldObject ifAbsent: anExceptionBlock
    "Remove oldObject from the receiver. If absent, evaluate anExceptionBlock
     and answer the result, else answer oldObject."

    self subclassResponsibility
!

remove: oldObject
    "Remove oldObject from the receiver. If absent, fail, else
     answer oldObject."

    ^self remove: oldObject
	 ifAbsent: [ SystemExceptions.NotFound signalOn: oldObject what: 'object' ].
!

removeAll: aCollection
    "Remove each object in aCollection, answer aCollection, fail if some
     of them is absent. Warning: this could leave the collection in a
     semi-updated state."

    aCollection do: [ :element | self remove: element ].
    ^aCollection
!

removeAll: aCollection ifAbsent: aBlock
    "Remove each object in aCollection, answer aCollection; if some
     element is absent, pass it to aBlock."

    aCollection do: [ :element |
	self remove: element ifAbsent: [ aBlock value: element ]
    ].
    ^aCollection
! !



!Collection methodsFor: 'testing collections'!

isSequenceable
    "Answer whether the receiver can be accessed by a numeric index with
     #at:/#at:put:."
    ^false
!

capacity
    "Answer how many elements the receiver can hold before having to grow."
    ^self basicSize
!

includes: anObject
    "Answer whether we include anObject"
    self do: [ :element | anObject = element ifTrue: [ ^true ] ].
    ^false
!

identityIncludes: anObject
    "Answer whether we include the anObject object"
    self do: [ :element | anObject == element ifTrue: [ ^true ] ].
    ^false
!

isEmpty
    "Answer whether we are (still) empty"
    ^self size == 0
!

notEmpty
    "Answer whether we include at least one object"
    ^self size > 0
!

occurrencesOf: anObject
    "Answer how many occurrences of anObject we include"
    | count |
    count := 0.
    self do: [ :element | anObject == element ifTrue: [ count := count + 1 ] ].
    ^count
!

size
    "Answer how many objects we include"
    | count |
    count := 0.
    self do: [ :element | count := count + 1].
    ^count
! !



!Collection methodsFor: 'enumeration'!

anyOne
    "Answer an unspecified element of the collection."

    self do: [ :each | ^each ]
!

beConsistent
    "This method is private, but it is quite interesting so it is
     documented. It ensures that a collection is in a consistent
     state before attempting to iterate on it; its presence reduces
     the number of overrides needed by collections who try to
     amortize their execution times.  The default implementation
     does nothing, so it is optimized out by the virtual machine
     and so it loses very little on the performance side.  Note
     that descendants of Collection have to call it explicitly
     since #do: is abstract in Collection."
!

do: aBlock
    "Enumerate each object of the receiver, passing them to aBlock"
    self subclassResponsibility
!

do: aBlock separatedBy: separatorBlock
    "Enumerate each object of the receiver, passing them to aBlock.
     Between every two invocations of aBlock, invoke separatorBlock"
    | first |
    first := true.
    self do: [ :each |
	aBlock value: each.
	first
	    ifTrue: [ first := false ]
	    ifFalse: [ separatorBlock value ]
    ]
!

select: aBlock
    "Answer a new instance of a Collection containing all the elements
     in the receiver which, when passed to aBlock, answer true"

    | newCollection |
    newCollection := self copyEmpty.
    self do: [ :element | (aBlock value: element)
    	    	    	    ifTrue: [ newCollection add: element ]
	     ].
    ^newCollection
!

reject: aBlock
    "Answer a new instance of a Collection containing all the elements
     in the receiver which, when passed to aBlock, don't answer true"

    | newCollection |
    newCollection := self copyEmpty.
    self do: [ :element | (aBlock value: element)
    	    	    	    ifFalse: [ newCollection add: element ]
	     ].
    ^newCollection
!

collect: aBlock
    "Answer a new instance of a Collection containing all the results
     of evaluating aBlock passing each of the receiver's elements"

    | newCollection |
    newCollection := self copyEmptyForCollect.
    self do: [ :element | newCollection add: (aBlock value: element) ].
    ^newCollection
!

detect: aBlock ifNone: exceptionBlock
    "Search the receiver for an element for which aBlock returns true.
     If some does, answer it. If none does, answer the result of evaluating
     aBlock"

    self do: [ :element | (aBlock value: element) ifTrue: [ ^element ] ].
    ^exceptionBlock value    
!
    
allSatisfy: aBlock
    "Search the receiver for an element for which aBlock returns false.
     Answer true if none does, false otherwise."
    self do: [ :element | (aBlock value: element) ifFalse: [ ^false ] ].
    ^true
!

anySatisfy: aBlock
    "Search the receiver for an element for which aBlock returns true.
     Answer true if some does, false otherwise."
    self do: [ :element | (aBlock value: element) ifTrue: [ ^true ] ].
    ^false
!

conform: aBlock
    "Search the receiver for an element for which aBlock returns false.
     Answer true if none does, false otherwise."
    self do: [ :element | (aBlock value: element) ifFalse: [ ^false ] ].
    ^true
!

contains: aBlock
    "Search the receiver for an element for which aBlock returns true.
     Answer true if some does, false otherwise."
    self do: [ :element | (aBlock value: element) ifTrue: [ ^true ] ].
    ^false
!

detect: aBlock
    "Search the receiver for an element for which aBlock returns true.
     If some does, answer it. If none does, fail"
    ^self detect: aBlock
	 ifNone: [ SystemExceptions.NotFound signal: 'object not found' ].
!

fold: binaryBlock
    "First, pass to binaryBlock the first and second elements of the
     receiver; for each subsequent element, pass the result of the previous
     evaluation and an element. Answer the result of the last invocation,
     or the first element if the collection has size 1.  Fail if the collection
     is empty."

    | result marker |
    self isEmpty
	 ifTrue: [ ^SystemExceptions.EmptyCollection signalOn: self ].

    result := marker := Object new.
    self do: [ :element |
	result := result == marker
	    ifTrue: [ element ]
	    ifFalse: [ binaryBlock value: result value: element ]
    ].
    ^result
!

inject: thisValue into: binaryBlock
    "First, pass to binaryBlock thisValue and the first element of the
     receiver; for each subsequent element, pass the result of the previous
     evaluation and an element. Answer the result of the last invocation."

    | result |
    result := thisValue.
    self do: [ :element |
	result := binaryBlock value: result value: element
    ].
    ^result
! !



!Collection methodsFor: 'converting'!

asArray
    "Answer an Array containing all the elements in the receiver"

    ^(Array new: self size)
	replaceFrom: 1 to: self size with: self;
	yourself!

asByteArray
    "Answer a ByteArray containing all the elements in the receiver"

    ^(ByteArray new: self size)
	replaceFrom: 1 to: self size with: self;
	yourself!

asBag
    "Answer a Bag containing all the elements in the receiver"

    ^(Bag new: self size)
	addAll: self;
	yourself!

asSet
    "Answer a Set containing all the elements in the receiver with no
     duplicates"

    ^(Set new: self size * 2)
	addAll: self;
	yourself!

asString
    "Answer a String containing all the elements in the receiver"

    ^(String new: self size)
	replaceFrom: 1 to: self size with: self;
	yourself!

asUnicodeString
    "Answer a UnicodeString containing all the elements in the receiver"

    ^(UnicodeString new: self size)
	replaceFrom: 1 to: self size with: self;
	yourself!

asOrderedCollection
    "Answer an OrderedCollection containing all the elements in the receiver"

    ^(OrderedCollection new: self size * 2)
	addAll: self;
	yourself!

asSortedCollection
    "Answer a SortedCollection containing all the elements in the receiver
     with the default sort block - [ :a :b | a <= b ]"

    ^(SortedCollection new: self size + 10)
	addAll: self;
	yourself
!

asSortedCollection: aBlock
    "Answer a SortedCollection whose elements are the elements of the receiver,
     sorted according to the sort block aBlock"

    ^self asSortedCollection sortBlock: aBlock; yourself
! !



!Collection methodsFor: 'copying Collections'!

copyReplacing: targetObject withObject: newObject
    "Copy replacing each object which is = to targetObject
     with newObject"

    ^self collect: [:each |
	each = targetObject ifFalse: [each] ifTrue: [newObject]
    ]
!

copyWith: newElement
    "Answer a copy of the receiver to which newElement is added"

    ^self copy
       add: newElement;
       yourself
!

copyWithout: oldElement
    "Answer a copy of the receiver to which all occurrences of oldElement are
     removed"

    ^self reject: [ :element | element = oldElement ].
! !



!Collection methodsFor: 'private'!

copyEmpty
    "Answer an empty copy of the receiver"
    ^self copyEmpty: self basicSize
!

copyEmpty: newSize
    "Answer an empty copy of the receiver whose size is newSize"
    ^self species new: newSize
!

copyEmptyForCollect
    "Answer an empty copy of the receiver, with the class answered by the
     collect: method."
    ^self copyEmpty
!

rehash
    "Private - Do nothing, present for consistency in protocol"
! !
    


!Collection methodsFor: 'printing'!

inspect
    "Print all the instance variables and objects in the receiver on the
     Transcript"

    | instVars output object |
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
				      bindWith: object class article
				      with: object class name asString) ].

	Transcript nextPutAll: '  ';
	    nextPutAll: (instVars at: i);
	    nextPutAll: ': ';
	    nextPutAll: output;
	    nl ].

    Transcript nextPutAll: '  contents: ['; nl.

    self do: [ :obj || output |
    	output := [ obj printString ]
		      on: Error
		      do: [ :ex | ex return: ('%1 %2'
				      bindWith: obj class article
				      with: obj class name asString) ].
	Transcript 
	    nextPutAll: '    ';
	    nextPutAll: output;
	    nl
    ].
    Transcript nextPutAll: '  ]'; nl
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPutAll: self classNameString.
    aStream nextPutAll: ' ('.
    self do:
    	[ :element | element printOn: aStream.
		     aStream space ].
    aStream nextPut: $)
! !



!Collection methodsFor: 'storing'!

storeOn: aStream
    "Store Smalltalk code compiling to the receiver on aStream"
    | noElements |
    aStream nextPut: $(.
    aStream nextPutAll: self classNameString.
    aStream nextPutAll: ' new'.
    noElements := true.
    self do:
    	[ :element | aStream nextPutAll: ' add: '.
    	    	     element storeOn: aStream.
		     aStream nextPut: $;.
		     noElements := false ].
    noElements ifFalse: [ aStream nextPutAll: ' yourself' ].
    aStream nextPut: $)
! !


!Collection methodsFor: 'finalization'!

mourn: anObject
    "Private - anObject has been found to have a weak key, remove it
     and possibly finalize the key."

    self remove: anObject ifAbsent: [].
    self == Object finalizableObjects ifTrue: [ anObject key finalize ].
! !

