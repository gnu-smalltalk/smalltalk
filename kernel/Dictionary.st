"======================================================================
|
|   Dictionary Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2003,2007,2008,2009
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



HashedCollection subclass: Dictionary [
    
    <shape: #pointer>
    <category: 'Collections-Keyed'>
    <comment: 'I implement a dictionary, which is an object that is indexed by
unique objects (typcially instances of Symbol), and associates another
object with that index.  I use the equality operator = to determine
equality of indices.

In almost all places where you would use a plain Dictionary, a
LookupTable would be more efficient; see LookupTable''s comment before
you use it.  I do have a couple of special features that are useful in
certain special cases.'>

    Dictionary class >> from: anArray [
	"Answer a new dictionary created from the keys and values of
	 Associations in anArray, such as {1 -> 2. 3 -> 4}.  anArray
	 should be specified using brace-syntax."

	<category: 'instance creation'>
	| inst |
	inst := self new: anArray size.
	anArray do: [:assoc | inst at: assoc key put: assoc value].
	^inst
    ]

    Dictionary class >> new [
	"Create a new dictionary with a default size"

	"Builtins defines a #new method, so that during bootstrap there is a way
	 to create dictionaries.  Unfortunately, this #new method only creates
	 dictionaries, so subclasses when trying to use this method, lose big.
	 This fixes the problem."

	<category: 'instance creation'>
	^self new: 24
    ]

    add: newObject [
	"Add the newObject association to the receiver"

	<category: 'accessing'>
	| index assoc |
	index := self findIndex: newObject key.
	(assoc := self primAt: index) isNil 
	    ifTrue: 
		[self incrementTally ifTrue: [index := self findIndex: newObject key].
		self primAt: index put: newObject]
	    ifFalse: [assoc value: newObject value].
	^newObject
    ]

    addAll: aCollection [
	"Adds all the elements of 'aCollection' to the receiver, answer
	 aCollection"

	<category: 'accessing'>
	aCollection keysAndValuesDo: [:key :value | self at: key put: value].
	^aCollection
    ]

    associations [
	"Returns the content of a Dictionary as a Set of Associations."

	<category: 'accessing'>
	| array i |
	array := Array new: self size.
	i := 0.
	self associationsDo: [ :each |
	    array at: (i := i + 1) put: each ].
	^array
    ]

    at: key put: value [
	"Store value as associated to the given key"

	<category: 'accessing'>
	| index assoc |
	index := self findIndex: key.
	(assoc := self primAt: index) isNil 
	    ifTrue: 
		[self incrementTally ifTrue: [index := self findIndex: key].
		self primAt: index put: (Association key: key value: value)]
	    ifFalse: [assoc value: value].
	^value
    ]

    atAll: keyCollection [
	"Answer a Dictionary that only includes the given keys. Fail if any of
	 them is not found"

	<category: 'accessing'>
	| result |
	result := self class new: keyCollection size.
	keyCollection do: [:key | result at: key put: (self at: key)].
	^result
    ]

    at: key [
	"Answer the value associated to the given key. Fail if the key
	 is not found"

	<category: 'accessing'>
	^self at: key
	    ifAbsent: [SystemExceptions.NotFound signalOn: key what: 'key']
    ]

    at: key ifAbsent: aBlock [
	"Answer the value associated to the given key, or the result of evaluating
	 aBlock if the key is not found"

	<category: 'accessing'>
	| index |
	index := self findIndexOrNil: key.
	^index isNil ifTrue: [aBlock value] ifFalse: [(self primAt: index) value]
    ]

    at: aKey ifAbsentPut: aBlock [
	"Answer the value associated to the given key. If the key is not found,
	 evaluate aBlock and associate the result to aKey before returning."

	<category: 'accessing'>
	^self at: aKey ifAbsent: [self at: aKey put: aBlock value]
    ]

    at: aKey ifPresent: aBlock [
	"If aKey is absent, answer nil. Else, evaluate aBlock passing the
	 associated value and answer the result of the invocation"

	<category: 'accessing'>
	| index |
	index := self findIndexOrNil: aKey.
	^index isNil 
	    ifTrue: [nil]
	    ifFalse: [aBlock value: (self primAt: index) value]
    ]

    associationAt: key [
	"Answer the key/value Association for the given key. Fail if the key
	 is not found"

	<category: 'accessing'>
	^self associationAt: key
	    ifAbsent: [SystemExceptions.NotFound signalOn: key what: 'key']
    ]

    associationAt: key ifAbsent: aBlock [
	"Answer the key/value Association for the given key. Evaluate aBlock
	 (answering the result) if the key is not found"

	<category: 'accessing'>
	| index |
	index := self findIndexOrNil: key.
	^index isNil ifTrue: [aBlock value] ifFalse: [self primAt: index]
    ]

    keyAtValue: value ifAbsent: exceptionBlock [
	"Answer the key associated to the given value. Evaluate exceptionBlock
	 (answering the result) if the value is not found.
	 IMPORTANT: == is used to compare values"

	<category: 'accessing'>
	self keysAndValuesDo: [:key :val | value == val ifTrue: [^key]].
	^exceptionBlock value
    ]

    keyAtValue: value [
	"Answer the key associated to the given value, or nil if the value is not found"

	<category: 'accessing'>
	^self keyAtValue: value ifAbsent: [nil]
    ]

    keys [
	"Answer a kind of Set containing the keys of the receiver"

	<category: 'accessing'>
	| aSet |
	aSet := self keysClass new: self size * 4 // 3.
	self keysAndValuesDo: [:key :value | aSet add: key].
	^aSet
    ]

    values [
	"Answer an Array containing the values of the receiver"

	<category: 'accessing'>
	| result i |
	result := Array new: self size.
	i := 0.
	self keysAndValuesDo: [:key :value | result at: (i := i + 1) put: value].
	^result
    ]

    includesAssociation: anAssociation [
	"Answer whether the receiver contains the key which is
	 anAssociation's key and its value is anAssociation's value"

	<category: 'dictionary testing'>
	^true == (self at: anAssociation key
		    ifPresent: [:value | value = anAssociation value])
    ]

    includesKey: key [
	"Answer whether the receiver contains the given key"

	<category: 'dictionary testing'>
	^super includes: key
    ]

    includes: anObject [
	"Answer whether the receiver contains anObject as
	 one of its values"

	<category: 'dictionary testing'>
	self do: [:element | element = anObject ifTrue: [^true]].
	^false
    ]

    occurrencesOf: aValue [
	"Answer whether the number of occurrences of aValue as
	 one of the receiver's values"

	<category: 'dictionary testing'>
	| count |
	count := 0.
	self do: [:element | element = aValue ifTrue: [count := count + 1]].
	^count
    ]

    removeAllKeysSuchThat: aBlock [
	"Remove from the receiver all keys for which aBlock returns true."

	<category: 'removing'>
	self removeAllKeys: (self keys select: aBlock) ifAbsent: []
    ]

    removeAllKeys: keys [
	"Remove all the keys in keys, without raising any errors"

	<category: 'dictionary removing'>
	keys do: [:key | self removeKey: key ifAbsent: []]
    ]

    removeAllKeys: keys ifAbsent: aBlock [
	"Remove all the keys in keys, passing the missing keys as parameters
	 to aBlock as they're encountered"

	<category: 'dictionary removing'>
	keys do: [:key | self removeKey: key ifAbsent: [aBlock cull: key]]
    ]

    remove: anAssociation [
	"Remove anAssociation's key from the dictionary"

	<category: 'dictionary removing'>
	| index assoc |
	index := self findIndexOrNil: anAssociation key.
	index isNil 
	    ifTrue: [^SystemExceptions.NotFound signalOn: anAssociation key what: 'key'].
	assoc := self primAt: index.
	self primAt: index put: nil.
	self decrementTally.
	self rehashObjectsAfter: index.
	^assoc
    ]

    remove: anAssociation ifAbsent: aBlock [
	"Remove anAssociation's key from the dictionary"

	<category: 'dictionary removing'>
	| index assoc |
	index := self findIndexOrNil: anAssociation key.
	index isNil ifTrue: [^aBlock value].
	assoc := self primAt: index.
	self primAt: index put: nil.
	self decrementTally.
	self rehashObjectsAfter: index.
	^assoc
    ]

    removeKey: key [
	"Remove the passed key from the dictionary, fail if it is not found"

	<category: 'dictionary removing'>
	^self removeKey: key
	    ifAbsent: [SystemExceptions.NotFound signalOn: key what: 'key']
    ]

    removeKey: key ifAbsent: aBlock [
	"Remove the passed key from the dictionary, answer the result of
	 evaluating aBlock if it is not found"

	<category: 'dictionary removing'>
	| index assoc |
	index := self findIndexOrNil: key.
	index isNil ifTrue: [^aBlock value].
	assoc := self primAt: index.
	self primAt: index put: nil.
	self decrementTally.
	self rehashObjectsAfter: index.
	^assoc value
    ]

    associationsDo: aBlock [
	"Pass each association in the dictionary to aBlock"

	<category: 'dictionary enumerating'>
	super do: aBlock
    ]

    keysDo: aBlock [
	"Pass each key in the dictionary to aBlock"

	<category: 'dictionary enumerating'>
	super do: [:assoc | aBlock value: assoc key]
    ]

    do: aBlock [
	"Pass each value in the dictionary to aBlock"

	<category: 'dictionary enumerating'>
	super do: [:assoc | aBlock value: assoc value]
    ]

    keysAndValuesDo: aBlock [
	"Pass each key/value pair in the dictionary as two distinct parameters
	 to aBlock"

	<category: 'dictionary enumerating'>
	super do: [:assoc | aBlock value: assoc key value: assoc value]
    ]

    collect: aBlock [
	"Answer a new dictionary where the keys are the same and the values are
	 obtained by passing each value to aBlock and collecting the return values"

	<category: 'dictionary enumerating'>
	| aDictionary |
	aDictionary := self copyEmpty: self capacity.
	self 
	    keysAndValuesDo: [:key :value | aDictionary whileGrowingAt: key put: (aBlock value: value)].
	^aDictionary
    ]

    select: aBlock [
	"Answer a new dictionary containing the key/value pairs for which aBlock
	 returns true. aBlock only receives the value part of the pairs."

	<category: 'dictionary enumerating'>
	| newDict |
	newDict := self copyEmpty: self capacity.
	self 
	    associationsDo: [:assoc | (aBlock value: assoc value) ifTrue: [newDict add: assoc]].
	^newDict
    ]

    reject: aBlock [
	"Answer a new dictionary containing the key/value pairs for which aBlock
	 returns false. aBlock only receives the value part of the pairs."

	<category: 'dictionary enumerating'>
	| newDict |
	newDict := self copyEmpty: self capacity.
	self 
	    associationsDo: [:assoc | (aBlock value: assoc value) ifFalse: [newDict add: assoc]].
	^newDict
    ]

    = aDictionary [
	"Answer whether the receiver and aDictionary are equal"

	<category: 'testing'>
	self class == aDictionary class ifFalse: [^false].
	self == aDictionary ifTrue: [^true].
	self size = aDictionary size ifFalse: [^false].
	self keysAndValuesDo: 
		[:key :val | 
		val = (aDictionary at: key ifAbsent: [^false]) ifFalse: [^false]].
	^true
    ]

    hash [
	"Answer the hash value for the receiver"

	<category: 'testing'>
	| hashValue |
	hashValue := tally.
	self associationsDo: 
		[:assoc | 
		hashValue := hashValue bitXor: (self hashFor: assoc) scramble.

		"hack needed because the Smalltalk dictionary contains itself"
		assoc value == self 
		    ifFalse: [hashValue := hashValue bitXor: assoc value hash scramble]].
	^hashValue
    ]

    examineOn: aStream [
	"Print all the instance variables and objects in the receiver on aStream"

	<category: 'printing'>
	| class instVars i |
	class := self class.
	instVars := class allInstVarNames.
	aStream nextPutAll: 'An instance of '.
	aStream print: class; nl.
	1 to: instVars size
	    do: 
		[:i | 
		aStream
		    nextPutAll: '  ';
		    nextPutAll: (instVars at: i);
		    nextPutAll: ': ';
		    print: (self instVarAt: i);
		    nl].
	aStream
	    nextPutAll: '  contents: [';
	    nl.
	self associationsDo: 
		[:obj | 
		aStream
		    nextPutAll: '    ';
		    print: obj;
		    nl].
	aStream
	    nextPutAll: '  ]';
	    nl
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    nextPutAll: self class storeString , ' (';
	    nl.
	self keysAndValuesDo: 
		[:key :value | 
		aStream
		    tab;
		    print: key;
		    nextPutAll: '->';
		    print: value;
		    nl].
	aStream nextPut: $)
    ]

    storeOn: aStream [
	"Print Smalltalk code compiling to the receiver on aStream"

	<category: 'storing'>
	| hasElements |
	aStream
	    nextPutAll: '((' , self class storeString , ' new: ';
	    print: self size;
	    nextPut: $).
	hasElements := false.
	self associationsDo: 
		[:assoc | 
		aStream
		    nextPutAll: ' at: ';
		    store: assoc key;
		    nextPutAll: ' put: ';
		    store: assoc value;
		    nextPut: $;.
		hasElements := true].
	hasElements ifTrue: [aStream nextPutAll: ' yourself'].
	aStream nextPut: $)
    ]

    rehash [
	"Rehash the receiver"

	<category: 'rehashing'>
	| copy |
	copy := self copy.
	self resetTally.
	1 to: self primSize do: [:i | self primAt: i put: nil].
	copy associationsDo: [:each | self addWhileGrowing: each]
    ]

    copyAllFrom: aHashedCollection [
	<category: 'private methods'>
	| assoc |
	1 to: aHashedCollection primSize
	    do: 
		[:index | 
		assoc := aHashedCollection primAt: index.
		assoc isNil
		    ifFalse: [self addWhileGrowing: assoc key -> assoc value]].
	^self
    ]

    whileGrowingAt: key put: value [
	"Private - Add the given key/value association to the receiver. Don't check
	 for the set to be full - we want SPEED!."

	<category: 'private methods'>
	self addWhileGrowing: key -> value
    ]

    deepCopy [
	"Returns a deep copy of the receiver (the keys and values are
	 copies of the receiver's instance variables)"

	<category: 'private methods'>
	| newDictionary |
	newDictionary := self copyEmpty: self capacity.
	self 
	    keysAndValuesDo: [:k :v | newDictionary whileGrowingAt: k put: v copy].
	^newDictionary
    ]

    keysClass [
	"Private - Answer the class answered by #keys"

	<category: 'private methods'>
	^Set
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject key hash
    ]

    findElementIndex: anObject [
        "Tries to see where anObject can be placed as an indexed variable.
	 As soon as nil is found, the index of that slot is answered.
	 anObject also comes from an indexed variable."

        <category: 'private methods'>
        | index size element |
        "Sorry for the lack of readability, but I want speed... :-)"
        index := (anObject key hash scramble bitAnd: (size := self primSize) - 1) + 1.
   
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
	
	[((element := self primAt: index) isNil or: [element key = anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]

    findKeyIndex: key [
	"Tries to see if key exists as a the key of an indexed variable. As soon
	 as nil or an association with the correct key is found, the index of that
	 slot is answered"

	<category: 'awful ST-80 compatibility hacks'>
	^self findIndex: key
    ]

    allSuperspaces [
        "Answer all the receiver's superspaces in a collection"

        <category: 'namespace protocol'>
        | supers |
        supers := OrderedCollection new.
        self allSuperspacesDo: [:superspace | supers addLast: superspace].
        ^supers
    ]

    allSuperspacesDo: aBlock [
        "Evaluate aBlock once for each of the receiver's superspaces (which
	 is none for BindingDictionary)."

        <category: 'namespace protocol'>
    ]

    definedKeys [
        "Answer a kind of Set containing the keys of the receiver"

        <category: 'namespace protocol'>
        | aSet value |
        aSet := self keysClass new: tally * 4 // 3.
        1 to: self primSize
            do:
                [:index |
                value := self primAt: index.
                value isNil ifFalse: [aSet add: value key]].
        ^aSet
    ]

    inheritsFrom: aNamespace [
        "Answer whether aNamespace is one of the receiver's direct and
         indirect superspaces"

        <category: 'namespace protocol'>
        | space |
        space := self.

        [space := space superspace.
        space == aNamespace ifTrue: [^true].
        space notNil]
                whileTrue
    ]

    superspace [
        "Answer the receiver's superspace, which is nil for BindingDictionary."

        <category: 'namespace protocol'>
        ^nil
    ]

    withAllSuperspaces [
        "Answer the receiver and all of its superspaces in a collection,
	 which is none for BindingDictionary"

        <category: 'namespace protocol'>
        | supers |
        supers := OrderedCollection with: self.
        self allSuperspacesDo: [:superspace | supers addLast: superspace].
        ^supers
    ]

    withAllSuperspacesDo: aBlock [
        "Invokes aBlock for the receiver and all superspaces, both direct
         and indirect (though a BindingDictionary does not have any)."

        <category: 'namespace protocol'>
        aBlock value: self.
        self allSuperspacesDo: aBlock
    ]

    definesKey: key [
        "Answer whether the receiver defines the given key. `Defines'
         means that the receiver's superspaces, if any, are not considered."

        <category: 'namespace protocol'>
	^super includes: key
    ]

    hereAssociationAt: key ifAbsent: aBlock [
        "Return the association for the variable named as specified
         by `key' *in this namespace*. If the key is not found search will
         *not* be carried on in superspaces and aBlock will be immediately
         evaluated."
 
        <category: 'namespace protocol'>
	| index |
	index := self findIndexOrNil: key.
	^index isNil ifTrue: [aBlock value] ifFalse: [self primAt: index]
    ]
 
    hereAssociationAt: key [
        "Return the association for the variable named as specified
         by `key' *in this namespace*. If the key is not found search will
         *not* be carried on in superspaces and the method will fail."
 
        <category: 'namespace protocol'>
        ^self hereAssociationAt: key
            ifAbsent: [SystemExceptions.NotFound signalOn: key what: 'key']
    ]

    hereAt: key ifAbsent: aBlock [
        "Return the value associated to the variable named as specified
         by `key' *in this namespace*. If the key is not found search will
         *not* be carried on in superspaces and aBlock will be immediately
         evaluated."

        <category: 'namespace protocol'>
	| index |
	index := self findIndexOrNil: key.
	^index isNil ifTrue: [aBlock value] ifFalse: [(self primAt: index) value]
    ]

    hereAt: key [
        "Return the value associated to the variable named as specified
         by `key' *in this namespace*. If the key is not found search will
         *not* be carried on in superspaces and the method will fail."

        <category: 'namespace protocol'>
        ^self hereAt: key
            ifAbsent: [SystemExceptions.NotFound signalOn: key what: 'key']
    ]

    scopeDictionary [
        "Answer the dictionary that is used when the receiver is before
         a period in Smalltalk source code."
        <category: 'compilation'>
        ^self
    ]
]


