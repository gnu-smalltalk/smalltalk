"=====================================================================
|
|   Weak collections
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2007,2008,2009 Free Software Foundation, Inc.
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



Array subclass: WeakArray [
    | values nilValues |
    
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain array, but my items are stored in a weak object,
so I track which of them are garbage collected.'>

    WeakArray class >> new [
	"Create a new WeakArray of size 0."

	<category: 'instance creation'>
	^self new: 0
    ]

    WeakArray class >> new: size [
	"Create a new WeakArray of the given size."

	<category: 'instance creation'>
	^self basicNew initialize: size
    ]

    postLoad [
	"Called after loading an object; must restore it to the state before
	 `preStore' was called.  Make it weak again"

	<category: 'loading'>
	values makeWeak
    ]

    initialize: size [
	"Private - Initialize the values array; plus, make it weak and create
	 the ByteArray used to track garbage collected values"

	<category: 'private'>
	values := Array new: size.
	values makeWeak.
	nilValues := ByteArray new: size withAll: 1
    ]

    values: anArray whichAreNil: nilArray [
	"Private - Initialize the values array to anArray and make it weak;
	 plus, set to a copy of nilArray the ByteArray used to track garbage
	 collected values"

	<category: 'private'>
	values := anArray.
	values makeWeak.
	nilValues := ByteArray new: anArray size.
	nilValues 
	    replaceFrom: 1
	    to: anArray size
	    with: nilArray
	    startingAt: 1
    ]

    at: index [
	"Answer the index-th item of the receiver, or nil if it has been
	 garbage collected."

	<category: 'accessing'>
	^values at: index
    ]

    atAll: indices put: object [
	"Put object at every index contained in the indices collection"

	<category: 'accessing'>
	nilValues atAll: indices put: (object isNil ifTrue: [1] ifFalse: [0]).
	^values atAll: indices put: object
    ]

    atAllPut: object [
	"Put object at every index in the receiver"

	<category: 'accessing'>
	nilValues atAllPut: (object isNil ifTrue: [1] ifFalse: [0]).
	^values atAllPut: object
    ]

    at: index put: object [
	"Store the value associated to the given index; plus,
	 store in nilValues whether the object is nil.  nil objects whose
	 associated item of nilValues is 1 were touched by the garbage
	 collector."

	<category: 'accessing'>
	nilValues at: index put: (object isNil ifTrue: [1] ifFalse: [0]).
	^values at: index put: object
    ]

    clearGCFlag: index [
	"Clear the `object has been garbage collected' flag for the item
	 at the given index"

	<category: 'accessing'>
	| object |
	object := values at: index.
	nilValues at: index put: (object isNil ifTrue: [1] ifFalse: [0])
    ]

    do: aBlock [
	"Evaluate aBlock for all the elements in the array, including the
	 garbage collected ones (pass nil for those)."

	<category: 'accessing'>
	values do: aBlock
    ]

    aliveObjectsDo: aBlock [
	"Evaluate aBlock for all the elements in the array, excluding the
	 garbage collected ones. Note: a finalized object stays alive until
	 the next collection (the collector has no means to see whether it was
	 resuscitated by the finalizer), so an object being alive does not mean
	 that it is usable."

	<category: 'accessing'>
	| value |
	1 to: self size
	    do: 
		[:i | 
		(value := values at: i) isNil 
		    ifFalse: [aBlock value: value]
		    ifTrue: [(nilValues at: i) = 0 ifFalse: [aBlock value: value]]]
    ]

    isAlive: index [
	"Answer whether the item at the given index is still alive or has been
	 garbage collected. Note: a finalized object stays alive until the next
	 collection (the collector has no means to see whether it was resuscitated
	 by the finalizer), so an object being alive does not mean that it is
	 usable."

	<category: 'accessing'>
	^(values at: index) notNil or: [(nilValues at: index) = 1]
    ]

    size [
	"Answer the number of items in the receiver"

	<category: 'accessing'>
	^values size
    ]

    asArray [
	"Answer a non-weak version of the receiver"

	<category: 'conversion'>
	^values copy
    ]

    deepCopy [
	"Returns a deep copy of the receiver (the instance variables are
	 copies of the receiver's instance variables)"

	<category: 'conversion'>
	^self class basicNew values: values deepCopy whichAreNil: nilValues
    ]

    shallowCopy [
	"Returns a shallow copy of the receiver (the instance variables are
	 not copied)"

	<category: 'conversion'>
	^self class basicNew values: values shallowCopy whichAreNil: nilValues
    ]

    species [
	"Answer Array; this method is used in the #copyEmpty: message, which in
	 turn is used by all collection-returning methods (collect:, select:,
	 reject:, etc.)."

	<category: 'conversion'>
	^Array
    ]
]



Set subclass: WeakSet [
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain set, but my items are stored in a weak array;
I track which of them are garbage collected and, as soon as I encounter
one of them, I swiftly remove all.'>

    add: newObject [
	"Add newObject to the set, if and only if the set doesn't already contain
	 an occurrence of it. Don't fail if a duplicate is found. Answer newObject"

	<category: 'accessing'>
	| index |
	index := self findIndex: newObject.
	(self primAt: index) isNil ifTrue: [
	    self incrementTally ifTrue: [index := self findIndex: newObject].
	    self primAt: index put: (self newAssociation: newObject)].
	^newObject
    ]

    do: aBlock [
	"Enumerate all the non-nil members of the set"

	<category: 'accessing'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [aBlock value: (self primAt: i) key]]
    ]

    postLoad [
	"Called after loading an object; must restore it to the state before
	 `preStore' was called.  Make it weak again"

	<category: 'loading'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [(self primAt: i) makeEphemeron]]
    ]

    shallowCopy [
	"Returns a shallow copy of the receiver (the instance variables are
	 not copied)"

	<category: 'copying'>
	| copy |
	copy := self copyEmpty: self capacity.
	self do: [:each | copy addWhileGrowing: (copy newAssociation: each)].
	^copy
    ]

    deepCopy [
	"Returns a deep copy of the receiver (the instance variables are
	 copies of the receiver's instance variables)"

	<category: 'copying'>
	| copy |
	copy := self copyEmpty: self capacity.
	self do: [:each | copy addWhileGrowing: (copy newAssociation: each copy)].
	^copy
    ]

    newAssociation: key [
	<category: 'private'>
	^(HomedAssociation 
	    key: key
	    value: nil
	    environment: self)
	    makeEphemeron;
	    yourself
    ]

    mourn: anObject [
	"Private - anObject has been found to have a weak key, remove it."

	"What has to be passed to #remove: is the key, not the whole object."

	<category: 'private'>
	super mourn: anObject key
    ]

    findElementIndex: anObject [
        "Tries to see if anObject exists as an indexed variable. As soon as nil
         is found, the index of that slot is answered"

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

	<category: 'private'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element key = anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]



Dictionary subclass: WeakKeyDictionary [
    | keys |
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain Dictionary, but my keys are stored
in a weak array; I track which of them are garbage collected and, as
soon as I encounter one of them, I swiftly remove all the associations
for the garbage collected keys'>

    WeakKeyDictionary class >> postLoad [
	"Called after loading an object; must restore it to the state before
	 `preStore' was called.  Make it weak again"

	<category: 'hacks'>
	1 to: self primSize
	    do: [:i | (self primAt: i) notNil ifTrue: [(self primAt: i) makeEphemeron]]
    ]

    add: anAssociation [
	"Store value as associated to the given key."

	<category: 'accessing'>
	| assoc |
	assoc := anAssociation.
	((assoc isKindOf: HomedAssociation) and: [assoc environment == self]) 
	    ifFalse: 
		[assoc := HomedAssociation 
			    key: assoc key
			    value: assoc value
			    environment: self].
	assoc makeEphemeron.
	^super add: assoc
    ]

    at: key put: value [
	"Store value as associated to the given key."

	<category: 'accessing'>
	| assoc |
	assoc := HomedAssociation 
		    key: key
		    value: value
		    environment: self.
	assoc makeEphemeron.
	self add: assoc.
	^value
    ]
]



LookupTable subclass: WeakValueLookupTable [
    | values |
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain LookupTable, but my values are stored
in a weak array; I track which of the values are garbage collected and,
as soon as one of them is accessed, I swiftly remove the associations
for the garbage collected values'>

    WeakValueLookupTable class >> primNew: realSize [
	"Answer a new, uninitialized instance of the receiver with the given size"

	<category: 'hacks'>
	^self basicNew: realSize
    ]

    at: key ifAbsent: aBlock [
	"Answer the value associated to the given key, or the result of evaluating
	 aBlock if the key is not found"

	<category: 'hacks'>
	| result |
	result := super at: key ifAbsent: [^aBlock value].
	result isNil ifFalse: [^result].
	self beConsistent.
	^super at: key ifAbsent: aBlock
    ]

    at: key ifPresent: aBlock [
	"If aKey is absent, answer nil. Else, evaluate aBlock passing the
	 associated value and answer the result of the invocation"

	<category: 'hacks'>
	^aBlock value: (self at: key ifAbsent: [^nil])
    ]

    includesKey: key [
	"Answer whether the receiver contains the given key."

	<category: 'hacks'>
	self at: key ifAbsent: [^false].
	^true
    ]

    keysDo: aBlock [
        "Pass each key in the LookupTable to aBlock."

        <category: 'enumerating'>
        self beConsistent.
	super keysDo: aBlock
    ]

    do: aBlock [
        "Pass each value in the LookupTable to aBlock."

        <category: 'enumerating'>
        self beConsistent.
	super do: aBlock
    ]

    beConsistent [
	"Private - Clean the dictionary of key->(finalized value) pairs"

	<category: 'private'>
	| keys key |
	keys := WriteStream on: (Array new: self size // 3 + 1).
	1 to: self primSize
	    do: 
		[:index | 
		"Find values that are nil and should not be"

		(values isAlive: index) 
		    ifFalse: 
			[keys nextPut: (self primAt: index).
			values clearGCFlag: index]].
	self removeAllKeys: keys contents ifAbsent: [:key | ]
    ]

    initialize: anInteger [
	"Private - Initialize the values array; plus, make it weak and create
	 the ByteArray used to track garbage collected values"

	<category: 'private'>
	super initialize: anInteger.
	values := WeakArray new: self primSize
    ]

    primSize [
	<category: 'private'>
	^self basicSize
    ]

    primAt: index [
	<category: 'private'>
	^self basicAt: index
    ]

    primAt: index put: object [
	<category: 'private'>
	^self basicAt: index put: object
    ]

    valueAt: index [
	<category: 'private'>
	^values at: index
    ]

    valueAt: index put: object [
	<category: 'private'>
	^values at: index put: object
    ]

    rehash [
	"Rehash the receiver"

	<category: 'rehashing'>
	| key val |
	key := Array new: self primSize.
	val := Array new: values size.
	self resetTally.
	1 to: self primSize
	    do: 
		[:i | 
		"Find values that are nil and should not be"

		(key := self primAt: i) notNil 
		    ifTrue: 
			[(values isAlive: i) 
			    ifTrue: 
				[key at: i put: (self primAt: i).
				val at: i put: (self valueAt: i)]].
		self primAt: i put: nil.
		self valueAt: i put: nil].
	1 to: self primSize
	    do: 
		[:i | 
		(key at: i) isNil 
		    ifFalse: [self whileGrowingAt: (key at: i) put: (val at: i)]]
    ]

    findElementIndex: anObject [
        "Tries to see where anObject can be placed as an indexed variable.
         As soon as nil is found, the index of that slot is answered.
         anObject also comes from an indexed variable."

        <category: 'private methods'>
        self beConsistent.
	^ super findElementIndex: anObject
    ]

    findIndex: anObject [
        "Tries to see if anObject exists as an indexed variable. As soon as nil
         or anObject is found, the index of that slot is answered"

        <category: 'private methods'>
        self beConsistent.
	^ super findIndex: anObject
    ]

    examineOn: aStream [
        "Print all the instance variables and objects in the receiver on aStream"

        <category: 'printing'>
        self beConsistent.
	super examineOn: aStream
    ]
]



WeakSet subclass: WeakIdentitySet [
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain identity set, but my keys are stored in a weak
array; I track which of them are garbage collected and, as soon as I
encounter one of them, I swiftly remove all the garbage collected keys'>

    identityIncludes: anObject [
	"Answer whether I include anObject exactly.  As I am an
	 identity-set, this is the same as #includes:."

	<category: 'accessing'>
	^self includes: anObject
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element key == anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]



WeakKeyDictionary subclass: WeakKeyIdentityDictionary [
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain identity dictionary, but my keys are stored
in a weak array; I track which of them are garbage collected and, as
soon as I encounter one of them, I swiftly remove all the associations
for the garbage collected keys'>

    keysClass [
	"Answer the class answered by #keys"

	<category: 'private methods'>
	^IdentitySet
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject identityHash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element key == anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]



WeakValueLookupTable subclass: WeakValueIdentityDictionary [
    
    <shape: #pointer>
    <category: 'Collections-Weak'>
    <comment: '
I am similar to a plain identity dictionary, but my values are stored
in a weak array; I track which of the values are garbage collected and,
as soon as one of them is accessed, I swiftly remove the associations
for the garbage collected values'>

    keysClass [
	"Answer the class answered by #keys"

	<category: 'private methods'>
	^IdentitySet
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject identityHash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	self beConsistent.

	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject identityHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element == anObject]) 
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]

