"======================================================================
|
|   LookupTable Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002
| Free Software Foundation, Inc.
| Written by Steve Byrne and Paolo Bonzini.
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

Dictionary variableSubclass: #LookupTable
	   instanceVariableNames: 'values'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Collections-Keyed'
!

LookupTable comment:
'I am similar to Dictionary, except that my representation is
different (more efficient, but not useful to store a variable
binding). I use the object equality comparison message #=
to determine equivalence of indices.' !


!LookupTable class methodsFor: 'instance creation'!

new
    "Create a new LookupTable with a default size"
    ^self new: 5
! !



!LookupTable methodsFor: 'accessing'!

add: anAssociation
    "Add the anAssociation key to the receiver"
    self at: anAssociation key put: anAssociation value.
    ^anAssociation
!

at: key put: value
    "Store value as associated to the given key"
    | index |
    index := self findIndex: key.
    (self primAt: index) isNil ifTrue: [
	self incrementTally ifTrue: [ index := self findIndex: key ].
	self primAt: index put: key.
    ].
    
    self valueAt: index put: value.
    ^value
!

at: key ifAbsent: aBlock
    "Answer the value associated to the given key, or the result of evaluating
     aBlock if the key is not found"
    | index |
    index := self findIndexOrNil: key.
    ^index isNil
	ifTrue: [ aBlock value ]
	ifFalse: [ self valueAt: index ]
!    
    
at: aKey ifPresent: aBlock
    "If aKey is absent, answer nil. Else, evaluate aBlock passing the
     associated value and answer the result of the invocation"
    | index |
    index := self findIndexOrNil: aKey.
    ^index isNil
	ifTrue: [ nil ]
	ifFalse: [ aBlock value: (self valueAt: index) ]
!

associationAt: key ifAbsent: aBlock
    "Answer the key/value Association for the given key. Evaluate aBlock
     (answering the result) if the key is not found"
    | index |
    index := self findIndexOrNil: key.
    ^index isNil
	ifTrue: [ aBlock value ]
	ifFalse: [ Association key: key value: (self valueAt: index) ]
! !


!LookupTable methodsFor: 'hashing'!

hash
    "Answer the hash value for the receiver"
    | hashValue |
    hashValue := tally.
    self keysAndValuesDo: [:key :val |
        hashValue := hashValue bitXor: (self hashFor: key) scramble.

        "hack needed because the Smalltalk dictionary contains itself"
        val == self ifFalse: [
            hashValue := hashValue bitXor: val hash scramble.
        ]
    ].

    ^hashValue
! !


!LookupTable methodsFor: 'copying'!

deepCopy
    "Returns a deep copy of the receiver (the instance variables are
     copies of the receiver's instance variables)"
    | key newDict |
    newDict := self copyEmpty: self primSize.
    1 to: self primSize do: [ :index |
	key := self primAt: index.
	key isNil
	    ifFalse: [ newDict whileGrowingAt: key put: (self valueAt: index) ]
    ].
    ^self
! !



!LookupTable methodsFor: 'removing'!

remove: anAssociation
    "Remove anAssociation's key from the dictionary"
    ^anAssociation key -> (self removeKey: anAssociation key)
!

remove: anAssociation ifAbsent: aBlock
    "Remove anAssociation's key from the dictionary"

    "Inefficient (has a full block) but it is rarely used."
    ^anAssociation key -> (self removeKey: anAssociation key
				ifAbsent: [ ^aBlock value ])
!

removeKey: key ifAbsent: aBlock
    "Remove the passed key from the LookupTable, answer the result of
     evaluating aBlock if it is not found"
    | index value |
    index := self findIndexOrNil: key.
    index isNil ifTrue: [ ^aBlock value ].

    value := self valueAt: index.
    self primAt: index put: nil.
    self valueAt: index put: nil.
    self decrementTally.
    self rehashObjectsAfter: index.
    ^ value
! !



!LookupTable methodsFor: 'enumerating'!

associationsDo: aBlock
    "Pass each association in the LookupTable to aBlock"
    self keysAndValuesDo: [ :key :val | aBlock value:
	(Association key: key value: val)
    ]
!

keysAndValuesDo: aBlock
    "Pass each key/value pair in the LookupTable as two distinct parameters
     to aBlock"

    1 to: self primSize do: [:i |
	(self primAt: i) notNil
	    ifTrue: [ aBlock value: (self primAt: i) value: (self valueAt: i) ]
    ]
! !



!LookupTable methodsFor: 'rehashing'!

rehash
    "Rehash the receiver"
    | keys values n key |
    keys := Array new: self size.
    values := Array new: self size.
    self resetTally.

    n := 0.
    1 to: self primSize do: [:i |
        (key := self primAt: i) isNil ifFalse: [
            keys at: (n := n + 1) put: key.
            values at: n put: (self valueAt: i).
            self primAt: i put: nil.
            self valueAt: i put: nil
        ]
    ].

    keys keysAndValuesDo: [ :i :key |
        self whileGrowingAt: key put: (values at: i)
    ]
! !



!LookupTable methodsFor: 'storing'!

storeOn: aStream
    "Print Smalltalk code compiling to the receiver on aStream"
    | hasElements |
    aStream nextPutAll: '(', self class name , ' new'.
    hasElements := false.
    self keysAndValuesDo:
    	[ :key :value | aStream nextPutAll: ' at: ';
		   store: key;
		   nextPutAll: ' put: ';
		   store: value;
		   nextPut: $;.
	       hasElements := true ].
    hasElements ifTrue: [ aStream nextPutAll: ' yourself' ].
    aStream nextPut: $)
! !



!LookupTable methodsFor: 'private methods'!

initialize: anInteger
    "Private - Instance variable initialization."
    super initialize: anInteger.
    self initValues
!

initValues
    "Private - Initialize the values instance variable."
    values := Array new: self primSize
!

rehashObjectsAfter: index
    "Rehashes all the objects in the collection after index to see if any of
    them hash to index.  If so, that object is copied to index, and the
    process repeats with that object's index, until a nil is encountered."

    | i j size count key |
    i := index.
    size := self primSize.
    [   i = size ifTrue: [ i := 1 ] ifFalse: [ i := i + 1 ].
	key := self primAt: i.
	key notNil
    ]   whileTrue: [
	j := self findIndex: key.
	(self primAt: j) isNil ifTrue: [
	    self primAt: j put: key.
	    self valueAt: j put: (self valueAt: i).
	    self primAt: i put: nil.
	    self valueAt: i put: nil
	]
    ]
!

copyAllFrom: aDictionary
    | key |
    1 to: aDictionary primSize do: [ :index |
	key := aDictionary primAt: index.
	key isNil
	    ifFalse: [ self whileGrowingAt: key put: (aDictionary valueAt: index) ]
    ].
    ^self
!

addWhileGrowing: association
    self whileGrowingAt: association key put: association value
!

whileGrowingAt: key put: value
    "Private - Add the given key/value pair to the receiver. Don't check for
     the LookupTable to be full nor for the key's presence - we want SPEED!"
    | index |
    self
	primAt: (index := self findIndex: key)
	put: key.
    
    self valueAt: index put: value.
    tally := tally + 1.
    ^value
!

valueAt: index
    ^values at: index
!

valueAt: index put: object
    ^values at: index put: object
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject hash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := (anObject hash scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element = anObject ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !
