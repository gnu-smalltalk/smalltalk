"======================================================================
|
|   HashedCollection Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2003 Free Software Foundation, Inc.
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


Collection variableSubclass: #HashedCollection
	   instanceVariableNames: 'tally'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Collections-Unordered'
!

HashedCollection comment:
'I am an hashed collection that can store objects uniquely and
give fast responses on their presence in the collection.' !


!HashedCollection class methodsFor: 'instance creation'!

primNew: realSize
    ^self basicNew: realSize
!

new
    "Answer a new instance of the receiver with a default size"
    ^self new: 8
!

new: anInteger
    "Answer a new instance of the receiver with the given size"
    | realSize |
    realSize := 8 max: anInteger.
    (realSize bitAnd: (realSize - 1)) = 0 ifFalse: [
	realSize := 1 bitShift: realSize highBit
    ].

    ^(self primNew: realSize) initialize: realSize
!

withAll: aCollection
    "Answer a collection whose elements are all those in aCollection"
    ^(self new: aCollection size * 2)
	addAll: aCollection;
	yourself

! !


!HashedCollection methodsFor: 'accessing'!

at: index
    self shouldNotImplement
!

at: index put: value
    self shouldNotImplement
!

add: newObject
    "Add newObject to the set, if and only if the set doesn't already contain
     an occurrence of it. Don't fail if a duplicate is found. Answer anObject"
    | index |
    newObject isNil ifTrue: [ ^newObject ].
    index := self findIndex: newObject ifAbsent: [ :index |
	self incrementTally
	    ifTrue: [ self findIndex: newObject ]
	    ifFalse: [ index ]].

    self primAt: index put: newObject.
    ^newObject
! !



!HashedCollection methodsFor: 'removing'!

remove: oldObject ifAbsent: anExceptionBlock
    "Remove oldObject to the set. If it is found, answer oldObject.
     Otherwise, evaluate anExceptionBlock and return its value."

    | index |
    index := self findIndexOrNil: oldObject.
    index isNil ifTrue: [ ^anExceptionBlock value ].
    self primAt: index put: nil.
    self decrementTally.
    self rehashObjectsAfter: index.
    ^oldObject
! !



!HashedCollection methodsFor: 'copying'!

shallowCopy
    "Returns a shallow copy of the receiver (the instance variables are
     not copied)"
    ^(self copyEmpty: self primSize)
        copyAllFrom: self;
        yourself
!

deepCopy
    "Returns a deep copy of the receiver (the instance variables are
     copies of the receiver's instance variables)"
    | newHashedCollection |
    newHashedCollection := self copyEmpty: self primSize.
    self do: [ :each | newHashedCollection addWhileGrowing: each copy ].
    ^newHashedCollection
! !


!HashedCollection methodsFor: 'testing collections'!

includes: anObject
    "Answer whether the receiver contains an instance of anObject."
    ^(self findIndexOrNil: anObject) notNil
!

isEmpty
    "Answer whether the receiver is empty."
    ^tally == 0
!

occurrencesOf: anObject
    "Return the number of occurrences of anObject.  Since we're a set, this
    is either 0 or 1.  Nil is never directly in the set, so we special case
    it (the result is always 1)."
    anObject isNil ifTrue: [ ^1 ].
    ^(self includes: anObject)
    	ifTrue: [ 1 ]
	ifFalse: [ 0 ]
!

capacity
    "Answer how many elements the receiver can hold before having to grow."
    ^self primSize * 3 // 4
!

size
    "Answer the receiver's size"
    ^tally
!

hash
    "Return the hash code for the members of the set.  Since order is
    unimportant, we use a commutative operator to compute the hash value."
    | hashValue |
    hashValue := tally.
    self do: [ :member |
	hashValue := hashValue bitXor: (self hashFor: member) scramble
    ].
    ^hashValue
!

= aHashedCollection
    "Returns true if the two sets have the same membership, false if not"
    self class == aHashedCollection class ifFalse: [ ^false ].
    self == aHashedCollection ifTrue: [ ^true ].
    tally = aHashedCollection size  ifFalse: [ ^false ].
    self do: [ :element | (aHashedCollection includes: element)
    	    	    	    ifFalse: [ ^false ] ].
    ^true
! !



!HashedCollection methodsFor: 'enumerating the elements of a collection'!

do: aBlock
    "Enumerate all the non-nil members of the set"

    self beConsistent.
    1 to: self primSize do: [ :i |
    	(self primAt: i) notNil
	   ifTrue: [ aBlock value: (self primAt: i) ].
    ]
! !



!HashedCollection methodsFor: 'storing'!

storeOn: aStream
    "Store on aStream some Smalltalk code which compiles to the receiver"
    | hasElements |
    aStream nextPut: $(;
	    nextPutAll: self classNameString;
	    nextPutAll: ' new'.

    hasElements := false.
    self do:
    	[ :element | aStream nextPutAll: ' add: '.
		     element storeOn: aStream.
		     aStream nextPut: $;.
		     hasElements := true ].
    hasElements ifTrue: [ aStream nextPutAll: ' yourself' ].
    aStream nextPut: $).
! !



!HashedCollection methodsFor: 'rehashing'!

rehash
    "Rehash the receiver"
    | copy n obj |
    copy := Array new: self size.
    self resetTally.

    n := 0.
    1 to: self primSize do: [:i |
        (obj := self primAt: i) isNil ifFalse: [
            copy at: (n := n + 1) put: obj.
            self primAt: i put: nil
        ]
    ].

    copy do: [:each | self addWhileGrowing: each ]
! !



!HashedCollection methodsFor: 'private methods'!

initialize: anInteger
    "Private - Instance variable initialization."
    self resetTally.
!

resetTally
    "Private - Reset the tally of elements in the receiver."
    tally := 0
!

incrementTally
    "Answer whether the collection's size varied"
    | grown |
    (grown := tally >= (self primSize * 3 // 4))
        ifTrue: [ self growBy: self primSize ].

    tally := tally + 1.
    ^grown
!

decrementTally
    "Answer whether the collection's size varied"
    tally := tally - 1.
    ^false
!

addWhileGrowing: value
    "Private - Add the newObject association to the receiver. Don't check for
     the set to be full - we want SPEED!."
    self
	primAt: (self findIndex: value)
	put: value.
    tally := tally + 1.
    ^value
!

copyEmpty
    "Answer an empty copy of the receiver"
    ^self copyEmpty: self primSize
!

copyAllFrom: aHashedCollection
    | value |
    1 to: aHashedCollection primSize do: [ :index |
	value := aHashedCollection primAt: index.
	value isNil ifFalse: [ self addWhileGrowing: value ].
    ].
    ^self
!

rehashObjectsAfter: index
    "Private - Rehashes all the objects in the collection after index to
     see if any of them hash to index.  If so, that object is copied to
     index, and the process repeats with that object's index, until a nil
     is encountered."
    | i j size element |
    i := index.
    size := self primSize.
    [   i = size ifTrue: [ i := 1 ] ifFalse: [ i := i + 1 ].
	element := self primAt: i.
	element notNil
    ]   whileTrue: [
	j := self findIndex: element.
	(self primAt: j) isNil ifTrue: [
	    self primAt: j put: element.
	    self primAt: i put: nil
	]
    ]
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    self subclassResponsibility
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    self subclassResponsibility
!
    
findIndex: anObject ifAbsent: aBlock
    "Finds the given object in the set and returns its index.  If the set
    doesn't contain the object, aBlock is evaluated passing the index,
    and the result of evaluating aBlock is returned."

    | index |
    index := self findIndex: anObject.
    ^(self primAt: index) isNil
	ifTrue: [ aBlock value: index ]
	ifFalse: [ index ]
!

findIndexOrNil: anObject
    "Finds the given object in the set and returns its index.  If the set
    doesn't contain the object, answer nil."

    | index |
    index := self findIndex: anObject.
    (self primAt: index) isNil ifTrue: [ ^nil ].
    ^index
!

grow
    ^self growBy: self primSize
!

growBy: delta
    "Private - Grow by the receiver by delta places"

    | newSize newHashedCollection |
    newSize := self primSize + delta.
    newHashedCollection := self copyEmpty: self primSize + delta.
    newHashedCollection copyAllFrom: self.
    ^self become: newHashedCollection
! !


!HashedCollection methodsFor: 'saving and loading'!

postLoad
    "Called after loading an object; rehash the collection because identity
     objects will most likely mutate their hashes."
    self rehash
!

postStore
    "Called after an object is dumped.  Do nothing -- necessary because
     by default this calls #postLoad by default"
! !
