"======================================================================
|
|   Bag Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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


Collection subclass: #Bag
	   instanceVariableNames: 'contents'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Collections-Unordered'
!

Bag comment:
'My instances are unordered collections of objects.  You can think
of me as a set with a memory; that is, if the same object is added to me
twice, then I will report that that element has been stored twice.'!



!Bag class methodsFor: 'basic'!

new
    "Answer a new instance of the receiver"
    ^self basicNew initContents: 31
!

new: size
    "Answer a new instance of the receiver, with space for size distinct
     objects"
    ^self basicNew initContents: (7 max: size)
! !



!Bag methodsFor: 'adding'!

add: newObject withOccurrences: anInteger
    "If anInteger > 0, add anInteger occurrences of newObject to the
     receiver. If anInteger < 0, remove them. Answer newObject.  Fail
    if newObject is nil."

    | newOccurrences |
    newObject isNil ifTrue: [
        SystemExceptions.InvalidArgument signalOn: newObject reason:
	    'bag elements cannot be nil' ].

    newOccurrences := contents at: newObject
	     put: (self occurrencesOf: newObject) + anInteger.

    newOccurrences <= 0 ifTrue: [ contents removeKey: newObject ].
    ^newObject
!

add: newObject
    "Add an occurrence of newObject to the receiver. Answer newObject.
     Fail if newObject is nil."
    self add: newObject withOccurrences: 1.
    ^newObject 
! !



!Bag methodsFor: 'removing'!

remove: oldObject ifAbsent: anExceptionBlock
    "Remove oldObject from the collection and return it. If can't be
     found, answer instead the result of evaluationg anExceptionBlock"

    | count |
    "Since we're using a dictionary, we need decrement the value until
     it's zero, in which case we can then remove the object from the
     dictionary"
    count := self occurrencesOf: oldObject.
    count = 0 ifTrue: [ ^anExceptionBlock value ].
    count = 1 ifTrue: [ contents removeKey: oldObject ]
    	      ifFalse: [ contents at: oldObject
	      	    	    	  put: count - 1 ].
    ^oldObject
! !


!Bag methodsFor: 'extracting items'!

sortedByCount
    "Answer a collection of counts with elements, sorted by decreasing count."

    | counts |
    counts := SortedCollection sortBlock: [:x :y | x >= y].
    contents keysAndValuesDo: [ :key :count |
	counts add: count -> key].
    
    ^counts asArray! !


!Bag methodsFor: 'testing collections'!

occurrencesOf: anObject
    "Answer the number of occurrences of anObject found in the receiver"
    ^contents at: anObject ifAbsent: [ 0 ]
!

includes: anObject
    "Answer whether we include anObject"
    ^contents includesKey: anObject
!

size
    "Answer the total number of objects found in the receiver"
    | count |
    count := 0.
    contents do: [ :element | count := count + element ].
    ^count
!

hash
    "Answer an hash value for the receiver"
    ^contents hash
!

= aBag
    "Answer whether the receiver and aBag contain the same objects"
    self class == aBag class
	ifFalse: [ ^false ].
    ^contents = aBag contents
! !



!Bag methodsFor: 'enumerating the elements of a collection'!

asSet
    "Answer a set with the elements of the receiver"

    ^contents keys!

do: aBlock
    "Evaluate the block for all members in the collection."
    
    "For Bags, we need to go through the contents dictionary, and
     perform the block for as many occurrences of the objects as there
     are."
    contents keysAndValuesDo:
	[ :key :count | count timesRepeat: [ aBlock value: key ] ]
! !



!Bag methodsFor: 'storing'!

storeOn: aStream
    "Put on aStream some Smalltalk code compiling to the receiver"
    | noElements |
    aStream nextPut: $(;
	nextPutAll: self classNameString;
	nextPutAll: ' new'.
    noElements := true.
    contents keysAndValuesDo:
      [ :key :count | aStream nextPutAll: ' add: ';
		     store: key;
		     nextPutAll: ' withOccurrences: ';
		     store: count;
		     nextPut: $;.
		 noElements := false ].
    noElements ifFalse: [ aStream nextPutAll: '; yourself' ].
    aStream nextPut: $)
! !


!Bag methodsFor: 'printing'!

printOn: aStream
    "Put on aStream a representation of the receiver"

    aStream
	nextPutAll: self classNameString;
	nextPut: $(.

    contents keysAndValuesDo: [ :key :count |
	aStream 
	     print: key;
	     nextPut: $:;
	     print: count;
	     space
    ].
    aStream nextPut: $)
! !


!Bag methodsFor: 'private'!

dictionaryClass
    ^LookupTable
!

initContents: size
    contents := self dictionaryClass new: size
!

contents
    ^contents
! !

