"======================================================================
|
|   LookupTable Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2007, 2008
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



Dictionary subclass: LookupTable [
    
    <shape: #pointer>
    <category: 'Collections-Keyed'>
    <comment: 'I am a more efficient variant of Dictionary that cannot be used as a
pool dictionary of variables, as I don''t use Associations to store
key-value pairs.  I also cannot have nil as a key; if you need to be
able to store nil as a key, use Dictionary instead.  I use the object
equality comparison message #= to determine equivalence of indices.'>

    LookupTable class >> primNew: realSize [
	<category: 'private-instance creation'>
	^self basicNew: realSize * 2
    ]

    LookupTable class >> new [
	"Create a new LookupTable with a default size"

	<category: 'instance creation'>
	^self new: 5
    ]

    add: anAssociation [
	"Add the anAssociation key to the receiver"

	<category: 'accessing'>
	self at: anAssociation key put: anAssociation value.
	^anAssociation
    ]

    at: key put: value [
	"Store value as associated to the given key"

	<category: 'accessing'>
	| index |
	index := self findIndex: key.
	(self primAt: index) isNil 
	    ifTrue: 
		[self incrementTally ifTrue: [index := self findIndex: key].
		self primAt: index put: key].
	self valueAt: index put: value.
	^value
    ]

    at: key ifAbsent: aBlock [
	"Answer the value associated to the given key, or the result of evaluating
	 aBlock if the key is not found"

	<category: 'accessing'>
	| index |
	index := self findIndexOrNil: key.
	^index isNil ifTrue: [aBlock value] ifFalse: [self valueAt: index]
    ]

    at: aKey ifPresent: aBlock [
	"If aKey is absent, answer nil. Else, evaluate aBlock passing the
	 associated value and answer the result of the invocation"

	<category: 'accessing'>
	| index |
	index := self findIndexOrNil: aKey.
	^index isNil ifTrue: [nil] ifFalse: [aBlock value: (self valueAt: index)]
    ]

    associationAt: key ifAbsent: aBlock [
	"Answer the key/value Association for the given key. Evaluate aBlock
	 (answering the result) if the key is not found"

	<category: 'accessing'>
	| index |
	index := self findIndexOrNil: key.
	^index isNil 
	    ifTrue: [aBlock value]
	    ifFalse: [Association key: key value: (self valueAt: index)]
    ]

    remove: anAssociation [
	"Remove anAssociation's key from the dictionary"

	<category: 'removing'>
	^anAssociation key -> (self removeKey: anAssociation key)
    ]

    remove: anAssociation ifAbsent: aBlock [
	"Remove anAssociation's key from the dictionary"

	"Inefficient (has a full block) but it is rarely used."

	<category: 'removing'>
	^anAssociation key 
	    -> (self removeKey: anAssociation key ifAbsent: [^aBlock value])
    ]

    removeKey: key ifAbsent: aBlock [
	"Remove the passed key from the LookupTable, answer the result of
	 evaluating aBlock if it is not found"

	<category: 'removing'>
	| index value |
	index := self findIndexOrNil: key.
	index isNil ifTrue: [^aBlock value].
	value := self valueAt: index.
	self primAt: index put: nil.
	self valueAt: index put: nil.
	self decrementTally.
	self rehashObjectsAfter: index.
	^value
    ]

    associationsDo: aBlock [
	"Pass each association in the LookupTable to aBlock."

	<category: 'enumerating'>
	self 
	    keysAndValuesDo: [:key :val | aBlock value: (Association key: key value: val)]
    ]

    keysDo: aBlock [
	"Pass each key in the LookupTable to aBlock."

	<category: 'enumerating'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [aBlock value: (self primAt: i)]]
    ]

    do: aBlock [
	"Pass each value in the LookupTable to aBlock."

	<category: 'enumerating'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [aBlock value: (self valueAt: i)]]
    ]

    keysAndValuesDo: aBlock [
	"Pass each key/value pair in the LookupTable as two distinct parameters
	 to aBlock."

	<category: 'enumerating'>
	1 to: self primSize
	    do: 
		[:i | 
		(self primAt: i) notNil 
		    ifTrue: [aBlock value: (self primAt: i) value: (self valueAt: i)]]
    ]

    rehash [
	"Rehash the receiver"

	<category: 'rehashing'>
	| keys values n key |
	keys := Array new: self size.
	values := Array new: self size.
	self resetTally.
	n := 0.
	1 to: self primSize
	    do: 
		[:i | 
		(key := self primAt: i) isNil 
		    ifFalse: 
			[keys at: (n := n + 1) put: key.
			values at: n put: (self valueAt: i).
			self primAt: i put: nil.
			self valueAt: i put: nil]].
	keys 
	    keysAndValuesDo: [:i :key | self whileGrowingAt: key put: (values at: i)]
    ]

    hash [
	"Answer the hash value for the receiver"

	<category: 'hashing'>
	| hashValue |
	hashValue := tally.
	self keysAndValuesDo: 
		[:key :val | 
		hashValue := hashValue bitXor: (self hashFor: key) scramble.

		"hack needed because the Smalltalk dictionary contains itself"
		val == self ifFalse: [hashValue := hashValue bitXor: val hash scramble]].
	^hashValue
    ]

    storeOn: aStream [
	"Print Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	| hasElements |
	aStream nextPutAll: '(' , self class name , ' new'.
	hasElements := false.
	self keysAndValuesDo: 
		[:key :value | 
		aStream
		    nextPutAll: ' at: ';
		    store: key;
		    nextPutAll: ' put: ';
		    store: value;
		    nextPut: $;.
		hasElements := true].
	hasElements ifTrue: [aStream nextPutAll: ' yourself'].
	aStream nextPut: $)
    ]

    rehashObjectsAfter: index [
	"Rehashes all the objects in the collection after index to see if any of
	 them hash to index.  If so, that object is copied to index, and the
	 process repeats with that object's index, until a nil is encountered."

	<category: 'private methods'>
	| i j size count key |
	i := index.
	size := self primSize.
	
	[i = size ifTrue: [i := 1] ifFalse: [i := i + 1].
	key := self primAt: i.
	key notNil] 
		whileTrue: 
		    [self primAt: i put: nil.
		    j := self findElementIndex: key.
		    self primAt: j put: key.
		    j = i ifFalse: [
			self valueAt: j put: (self valueAt: i).
			self valueAt: i put: nil]]
    ]

    copyAllFrom: aDictionary [
	<category: 'private methods'>
	| key |
	1 to: aDictionary primSize
	    do: 
		[:index | 
		key := aDictionary primAt: index.
		key isNil 
		    ifFalse: [self whileGrowingAt: key put: (aDictionary valueAt: index)]].
	^self
    ]

    addWhileGrowing: association [
	<category: 'private methods'>
	self whileGrowingAt: association key put: association value
    ]

    whileGrowingAt: key put: value [
	"Private - Add the given key/value pair to the receiver. Don't check for
	 the LookupTable to be full nor for the key's presence - we want SPEED!"

	<category: 'private methods'>
	| index |
	self primAt: (index := self findElementIndex: key) put: key.
	self valueAt: index put: value.
	tally := tally + 1.
	^value
    ]

    primSize [
	<category: 'private methods'>
	^self basicSize // 2
    ]

    primAt: index [
	<category: 'private methods'>
	^self basicAt: index + index - 1
    ]

    primAt: index put: object [
	<category: 'private methods'>
	^self basicAt: index + index - 1 put: object
    ]

    valueAt: index [
	<category: 'private methods'>
	^self basicAt: index + index
    ]

    valueAt: index put: object [
	<category: 'private methods'>
	^self basicAt: index + index put: object
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject hash
    ]

    findElementIndex: anObject [
        "Tries to see where anObject can be placed as an indexed variable.
	 As soon as nil is found, the index of that slot is answered.
	 anObject also comes from an indexed variable."

        <category: 'private methods'>
        | index size element |
        "Sorry for the lack of readability, but I want speed... :-)"
        index := (anObject hash scramble bitAnd: (size := self primSize) - 1) + 1.
   
        [(element := self primAt: index) isNil
            ifTrue: [^index].
        index == size ifTrue: [index := 1] ifFalse: [index := index + 1]]
                repeat
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject hash scramble bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element = anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]

