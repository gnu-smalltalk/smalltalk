"======================================================================
|
|   Dictionary Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002
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


HashedCollection variableSubclass: #Dictionary
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Collections-Keyed'
!

Dictionary comment: 
'I implement a dictionary, which is an object that is indexed by
unique objects (typcially instances of Symbol), and associates another
object with that index.  I use the equality operator = to determine
equality of indices.' !



!Dictionary class methodsFor: 'instance creation'!

new
    "Create a new dictionary with a default size"
    "Builtins defines a #new method, so that during bootstrap there is a way
     to create dictionaries.  Unfortunately, this #new method only creates
     dictionaries, so subclasses when trying to use this method, lose big.
     This fixes the problem."
    ^self new: 31
! !



!Dictionary methodsFor: 'accessing'!

add: newObject
    "Add the newObject association to the receiver"
    | index assoc |
    index := self findIndex: newObject key.
    (assoc := self primAt: index) isNil
	ifTrue: [
	    self incrementTally ifTrue: [
	        index := self findIndex: newObject key ].
	    self primAt: index put: newObject.
	]
	ifFalse: [ assoc value: newObject value ].

    ^newObject
!

at: key put: value
    "Store value as associated to the given key"
    | index assoc |
    index := self findIndex: key.
    (assoc := self primAt: index) isNil
	ifTrue: [
	    self incrementTally ifTrue: [
	        index := self findIndex: key ].
	    self primAt: index put: (Association key: key value: value).
	]
	ifFalse: [ assoc value: value ].

    ^value
!

at: key
    "Answer the value associated to the given key. Fail if the key
     is not found"
    ^self
	at: key
	ifAbsent: [ SystemExceptions.NotFound signalOn: key what: 'key' ]
!

at: key ifAbsent: aBlock
    "Answer the value associated to the given key, or the result of evaluating
     aBlock if the key is not found"
    | index |
    index := self findIndexOrNil: key.
    ^index isNil
	ifTrue: [ aBlock value ]
	ifFalse: [ (self primAt: index) value ]
!
    
at: aKey ifAbsentPut: aBlock
    "Answer the value associated to the given key. If the key is not found,
     evaluate aBlock and associate the result to aKey before returning."
    ^self at: aKey ifAbsent: [ self at: aKey put: aBlock value ]
!

at: aKey ifPresent: aBlock
    "If aKey is absent, answer nil. Else, evaluate aBlock passing the
     associated value and answer the result of the invocation"

    | index |
    index := self findIndexOrNil: aKey.
    ^index isNil
	ifTrue: [ nil ]
	ifFalse: [ aBlock value: (self primAt: index) value ]
!

associationAt: key
    "Answer the key/value Association for the given key. Fail if the key
     is not found"
    ^self
	associationAt: key
	ifAbsent: [ SystemExceptions.NotFound signalOn: key what: 'key' ]
!

associationAt: key ifAbsent: aBlock
    "Answer the key/value Association for the given key. Evaluate aBlock
     (answering the result) if the key is not found"
    | index |
    index := self findIndexOrNil: key.
    ^index isNil
	ifTrue: [ aBlock value ]
	ifFalse: [ self primAt: index ]
!

keyAtValue: value ifAbsent: exceptionBlock
    "Answer the key associated to the given value. Evaluate exceptionBlock
     (answering the result) if the value is not found.
     IMPORTANT: == is used to compare values"
    self keysAndValuesDo: [:key :val |
	value == val ifTrue: [^key]
    ].
    ^exceptionBlock value
!

keyAtValue: value
    "Answer the key associated to the given value, or nil if the value is not found"
    ^self
	keyAtValue: value
	ifAbsent: [ nil ]
!

keys
    "Answer a kind of Set containing the keys of the receiver"
    | aSet |
    aSet := self keysClass new: self size * 4 // 3.
    self keysAndValuesDo: [ :key :value | aSet add: key ].
    ^aSet
!

values
    "Answer an Array containing the values of the receiver"
    | result i |
    result := Array new: self size.
    i := 0.
    self keysAndValuesDo: [ :key :value |
	result at: (i := i + 1) put: value
    ].
    ^result
! !



!Dictionary methodsFor: 'dictionary testing'!

includesAssociation: anAssociation
    "Answer whether the receiver contains the key which is
     anAssociation's key and its value is anAssociation's value"

    ^true == (self
	at: anAssociation key
	ifPresent: [ :value | value = anAssociation value ])
!

includesKey: key
    "Answer whether the receiver contains the given key"

    ^super includes: key
!

includes: anObject
    "Answer whether the receiver contains anObject as
     one of its values"
    self do: [ :element | element = anObject ifTrue: [ ^true ] ].
    ^false
!

occurrencesOf: aValue
    "Answer whether the number of occurrences of aValue as
     one of the receiver's values"
    | count |
    count := 0.
    self do: [ :element | element = aValue
    			    ifTrue: [ count := count + 1] ].
    ^count
! !



!Dictionary methodsFor: 'dictionary removing'!

removeAllKeys: keys
    "Remove all the keys in keys, without raising any errors"
    keys do: [ :key |
	self removeKey: key ifAbsent: [ ] ]
!

removeAllKeys: keys ifAbsent: aBlock
    "Remove all the keys in keys, passing the missing keys as parameters
     to aBlock as they're encountered"
    keys do: [ :key |
	self removeKey: key ifAbsent: [ aBlock value: key ] ]
!

remove: anAssociation
    "Remove anAssociation's key from the dictionary"
    | index assoc |
    index := self findIndexOrNil: anAssociation key.
    index isNil
	ifTrue: [ ^SystemExceptions.NotFound signalOn: anAssociation key what: 'key' ].

    assoc := self primAt: index.
    self primAt: index put: nil.
    self decrementTally.
    self rehashObjectsAfter: index.
    ^assoc
!

remove: anAssociation ifAbsent: aBlock
    "Remove anAssociation's key from the dictionary"
    | index assoc |
    index := self findIndexOrNil: anAssociation key.
    index isNil
	ifTrue: [ ^aBlock value ].

    assoc := self primAt: index.
    self primAt: index put: nil.
    self decrementTally.
    self rehashObjectsAfter: index.
    ^assoc
!

removeKey: key
    "Remove the passed key from the dictionary, fail if it is not found"
    ^self removeKey: key ifAbsent: [ SystemExceptions.NotFound signalOn: key what: 'key' ]
!

removeKey: key ifAbsent: aBlock
    "Remove the passed key from the dictionary, answer the result of
     evaluating aBlock if it is not found"
    | index assoc |
    index := self findIndexOrNil: key.
    index isNil ifTrue: [ ^aBlock value ].

    assoc := self primAt: index.
    self primAt: index put: nil.
    self decrementTally.
    self rehashObjectsAfter: index.
    ^assoc value
! !



!Dictionary methodsFor: 'dictionary enumerating'!

associationsDo: aBlock
    "Pass each association in the dictionary to aBlock"
    super do: [ :assoc | aBlock value: assoc ]
!

keysDo: aBlock
    "Pass each key in the dictionary to aBlock"
    super do: [ :assoc | aBlock value: assoc key ]
!

do: aBlock
    "Pass each value in the dictionary to aBlock"
    super do: [ :assoc | aBlock value: assoc value ]
!

keysAndValuesDo: aBlock
    "Pass each key/value pair in the dictionary as two distinct parameters
     to aBlock"
    super do: [ :assoc | aBlock value: assoc key value: assoc value ]
!

collect: aBlock
    "Answer a new dictionary where the keys are the same and the values are
     obtained by passing each value to aBlock and collecting the return values"
    | aDictionary |
    aDictionary := self copyEmpty: self primSize.
    self keysAndValuesDo: [ :key :value |
	aDictionary at: key put: (aBlock value: value) ].
    ^aDictionary
!

select: aBlock
    "Answer a new dictionary containing the key/value pairs for which aBlock
     returns true. aBlock only receives the value part of the pairs."
    | newDict |
    newDict := self copyEmpty: self primSize.
    self associationsDo:
    	[ :assoc | (aBlock value: assoc value)
		     ifTrue: [ newDict add: assoc ] ].
    ^newDict
!

reject: aBlock
    "Answer a new dictionary containing the key/value pairs for which aBlock
     returns false. aBlock only receives the value part of the pairs."
    | newDict |
    newDict := self copyEmpty: self primSize.
    self associationsDo:
    	[ :assoc | (aBlock value: assoc value)
		     ifFalse: [ newDict add: assoc ] ].
    ^newDict
! !



!Dictionary methodsFor: 'testing'!

= aDictionary
    "Answer whether the receiver and aDictionary are equal"
    self class == aDictionary class ifFalse: [ ^false ].
    self == aDictionary ifTrue: [ ^true ].
    self size = aDictionary size ifFalse: [ ^false ].
    self keysAndValuesDo: [:key :val |
	val = (aDictionary at: key ifAbsent: [ ^false ])
	    ifFalse: [ ^false ]
    ].
    ^true
!

hash
    "Answer the hash value for the receiver"
    | hashValue |
    hashValue := tally.
    self associationsDo: [:assoc |
        hashValue := hashValue bitXor: (self hashFor: assoc) scramble.

        "hack needed because the Smalltalk dictionary contains itself"
        assoc value == self ifFalse: [
            hashValue := hashValue bitXor: assoc value hash scramble.
        ]
    ].

    ^hashValue
! !



!Dictionary methodsFor: 'printing'!

inspect
    "Print all the instance variables and objects in the receiver on the
     Transcript"

    | class instVars i |
    self beConsistent.
    class := self class.
    instVars := class allInstVarNames.
    Transcript nextPutAll: 'An instance of '.
    class printNl.
    1 to: instVars size do:
	[ :i | Transcript nextPutAll: '  ';
	    nextPutAll: (instVars at: i);
	    nextPutAll: ': '.
	    (self instVarAt: i)  printNl ].

    Transcript nextPutAll: '  contents: ['; nl.

    self associationsDo: [ :obj |
	Transcript 
	    nextPutAll: '    ';
	    print: obj;
	    nl
    ].
    Transcript nextPutAll: '  ]'; nl
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPutAll: self classNameString , ' (' ; nl.
    self keysAndValuesDo:
    	[ :key :value | aStream tab;
		   print: key;
		   nextPutAll: '->';
		   print: value;
		   nl ].
    aStream nextPut: $)
! !



!Dictionary methodsFor: 'storing'!

storeOn: aStream
    "Print Smalltalk code compiling to the receiver on aStream"
    | hasElements |
    aStream
	nextPutAll: '((', self classNameString, ' new: ';
	print: self size;
	nextPut: $).

    hasElements := false.
    self associationsDo:
    	[ :assoc | aStream nextPutAll: ' at: ';
		       store: assoc key;
		       nextPutAll: ' put: ';
		       store: assoc value;
		       nextPut: $;.
		   hasElements := true ].
    hasElements ifTrue: [ aStream nextPutAll: ' yourself' ].
    aStream nextPut: $)
! !



!Dictionary methodsFor: 'rehashing'!

rehash
    "Rehash the receiver"
    | copy |
    copy := self copy.
    self resetTally.

    1 to: self primSize do: [:i |
	self primAt: i put: nil
    ].

    copy associationsDo: [:each | self addWhileGrowing: each ]
! !


!Dictionary methodsFor: 'private methods'!

rehashObjectsAfter: index
    "Private - Rehashes all the objects in the collection after index to
    see if any of them hash to index.  If so, that object is copied to
    index, and the process repeats with that object's index, until a nil
    is encountered."
    | i j size assoc |
    i := index.
    size := self primSize.
    [   i = size ifTrue: [ i := 1 ] ifFalse: [ i := i + 1 ].
	assoc := self primAt: i.
	assoc notNil
    ]   whileTrue: [
	j := self findIndex: assoc key.
	(self primAt: j) isNil ifTrue: [
	    self primAt: j put: assoc.
	    self primAt: i put: nil
	]
    ]
!

addWhileGrowing: association
    "Private - Add the newObject association to the receiver. Don't check for
     the set to be full - we want SPEED!."
    self
	primAt: (self findIndex: association key)
	put: association.
    tally := tally + 1.
    ^association
!

keysClass
    "Private - Answer the class answered by #keys"
    ^Set
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject key hash
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
            or: [ element key = anObject ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !


!Dictionary methodsFor: 'awful ST-80 compatibility hacks'!

findKeyIndex: key
    "Tries to see if key exists as a the key of an indexed variable. As soon
    as nil or an association with the correct key is found, the index of that
    slot is answered"
    ^self findIndex: key
! !

!Dictionary methodsFor: 'polymorphism hacks'!

withAllSuperspaces
    "This method is needed by the compiler"
    ^{self}
! !
