"=====================================================================
|
|   Weak collections
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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

Array subclass: #WeakArray
	instanceVariableNames: 'values nilValues'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!

Set variableSubclass: #WeakSet
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!

Dictionary variableSubclass: #WeakKeyDictionary
	instanceVariableNames: 'keys'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!

LookupTable variableSubclass: #WeakValueLookupTable
	instanceVariableNames: 'values'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!

WeakSet variableSubclass: #WeakIdentitySet
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!

WeakKeyDictionary variableSubclass: #WeakKeyIdentityDictionary
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!

WeakValueLookupTable variableSubclass: #WeakValueIdentityDictionary
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Weak'!


WeakArray comment: '
I am similar to a plain array, but my items are stored in a weak object,
so I track which of them are garbage collected.'.

WeakSet comment: '
I am similar to a plain set, but my items are stored in a weak array;
I track which of them are garbage collected and, as soon as I encounter
one of them, I swiftly remove all.'.

WeakKeyDictionary comment: '
I am similar to a plain Dictionary, but my keys are stored
in a weak array; I track which of them are garbage collected and, as
soon as I encounter one of them, I swiftly remove all the associations
for the garbage collected keys'.

WeakValueLookupTable comment: '
I am similar to a plain LookupTable, but my values are stored
in a weak array; I track which of the values are garbage collected and,
as soon as one of them is accessed, I swiftly remove the associations
for the garbage collected values'.

WeakIdentitySet comment: '
I am similar to a plain identity set, but my keys are stored in a weak
array; I track which of them are garbage collected and, as soon as I
encounter one of them, I swiftly remove all the garbage collected keys'.

WeakKeyIdentityDictionary comment: '
I am similar to a plain identity dictionary, but my keys are stored
in a weak array; I track which of them are garbage collected and, as
soon as I encounter one of them, I swiftly remove all the associations
for the garbage collected keys'.

WeakValueIdentityDictionary comment: '
I am similar to a plain identity dictionary, but my values are stored
in a weak array; I track which of the values are garbage collected and,
as soon as one of them is accessed, I swiftly remove the associations
for the garbage collected values'!


!WeakArray class methodsFor: 'instance creation'!

new: size
    "Private - Initialize the values array; plus, make it weak and create
    the ByteArray used to track garbage collected values"

    ^self basicNew
        initialize: size
! !


!WeakArray methodsFor: 'loading'!

postLoad
    "Called after loading an object; must restore it to the state before
     `preStore' was called.  Make it weak again"
    values makeWeak
! !


!WeakArray methodsFor: 'private'!

initialize: size
    "Private - Initialize the values array; plus, make it weak and create
    the ByteArray used to track garbage collected values"
    values := Array new: size.
    values makeWeak.
    nilValues := ByteArray new: size withAll: 1.
!

values: anArray whichAreNil: nilArray
    "Private - Initialize the values array to anArray and make it weak;
    plus, set to a copy of nilArray the ByteArray used to track garbage
    collected values"
    values := anArray.
    values makeWeak.
    nilValues := ByteArray new: anArray size.
    nilValues replaceFrom: 1 to: anArray size with: nilArray startingAt: 1.
! !


!WeakArray methodsFor: 'accessing'!

at: index
    "Answer the index-th item of the receiver, or nil if it has been
     garbage collected."
    ^values at: index
!

atAll: indices put: object
    "Put object at every index contained in the indices collection"
    nilValues atAll: indices put: (object isNil ifTrue: [1] ifFalse: [0]).
    ^values atAll: indices put: object
!

atAllPut: object
    "Put object at every index in the receiver"
    nilValues atAllPut: (object isNil ifTrue: [1] ifFalse: [0]).
    ^values atAllPut: object
!

at: index put: object
    "Store the value associated to the given index; plus,
    store in nilValues whether the object is nil.  nil objects whose
    associated item of nilValues is 1 were touched by the garbage
    collector."
    nilValues at: index put: (object isNil ifTrue: [1] ifFalse: [0]).
    ^values at: index put: object
!

clearGCFlag: index
    "Clear the `object has been garbage collected' flag for the item
    at the given index"
    | object |
    object := values at: index.
    nilValues at: index put: (object isNil ifTrue: [1] ifFalse: [0]).
!

do: aBlock
    "Evaluate aBlock for all the elements in the array, including the 
     garbage collected ones (pass nil for those)."
    values do: aBlock
!

aliveObjectsDo: aBlock
    "Evaluate aBlock for all the elements in the array, excluding the 
     garbage collected ones. Note: a finalized object stays alive until
     the next collection (the collector has no means to see whether it was
     resuscitated by the finalizer), so an object being alive does not mean
     that it is usable."
    | value |
    1 to: self size do: [ :i |
	(value := values at: i) isNil
	    ifFalse: [ aBlock value: value ]
	    ifTrue: [ (nilValues at: i) = 0 ifFalse: [ aBlock value: value ] ]
    ].
!

isAlive: index
    "Answer whether the item at the given index is still alive or has been
     garbage collected. Note: a finalized object stays alive until the next
     collection (the collector has no means to see whether it was resuscitated
     by the finalizer), so an object being alive does not mean that it is
     usable."
    ^(values at: index) notNil or: [ (nilValues at: index) = 1 ]
!

size
    "Answer the number of items in the receiver"
    ^values size
! !


!WeakArray methodsFor: 'conversion'!

asArray
    "Answer a non-weak version of the receiver"
    ^values copy
!

deepCopy
    "Returns a deep copy of the receiver (the instance variables are
     copies of the receiver's instance variables)"
    ^self class basicNew
        values: values deepCopy whichAreNil: nilValues
!

shallowCopy
    "Returns a shallow copy of the receiver (the instance variables are
     not copied)"
    ^self class basicNew
        values: values shallowCopy whichAreNil: nilValues
!

species
    "Answer Array; this method is used in the #copyEmpty: message, which in
     turn is used by all collection-returning methods (collect:, select:,
     reject:, etc.)."
    ^Array
! !


!WeakSet methodsFor: 'accessing'!

add: anObject
    "Add newObject to the set, if and only if the set doesn't already contain
     an occurrence of it. Don't fail if a duplicate is found. Answer anObject"
    super add: ((HomedAssociation key: anObject value: nil environment: self)
	makeEphemeron;
	yourself).
    ^anObject
!

includes: anObject
    "Answer whether I contain anObject."
    ^super includes: (HomedAssociation key: anObject value: nil environment: self)
!

remove: anObject ifAbsent: aBlock
    "Remove oldObject to the set. If it is found, answer oldObject.
     Otherwise, evaluate aBlock and return its value."
    | obj |
    obj := super
	remove: (HomedAssociation key: anObject value: nil environment: self)
	ifAbsent: [ nil ].

    obj isNil ifTrue: [ ^aBlock value ].
    ^anObject
!

do: aBlock
    "Enumerate all the non-nil members of the set"

    1 to: self primSize do: [ :i |
        (self primAt: i) notNil
           ifTrue: [ aBlock value: (self primAt: i) key ].
    ]
! !



!WeakSet methodsFor: 'private'!

mourn: anObject
    "Private - anObject has been found to have a weak key, remove it."

    "What has to be passed to #remove: is the key, not the whole object."
    super mourn: anObject key
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
    index := (anObject key hash scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element key = anObject key ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !



!WeakKeyDictionary methodsFor: 'accessing'!

add: anAssociation
    "Store value as associated to the given key. If any, recycle Associations
     temporarily stored by the compiler inside the `Undeclared' dictionary."
    | assoc |
    assoc := anAssociation.

    ((assoc isKindOf: HomedAssociation) and: [
        assoc environment == self]) ifFalse: [
        assoc := HomedAssociation
            key: assoc key
            value: assoc value
            environment: self.
    ].

    assoc makeEphemeron.
    ^super add: assoc
!

at: key put: value
    "Store value as associated to the given key. If any, recycle Associations
     temporarily stored by the compiler inside the `Undeclared' dictionary."
    | assoc |

    assoc := HomedAssociation
                key: key
                value: value
                environment: self.

    assoc makeEphemeron.
    self add: assoc.
    ^value
! !


!WeakValueLookupTable class methodsFor: 'hacks'!

primNew: realSize
    "Answer a new, uninitialized instance of the receiver with the given size"
    ^self basicNew: realSize! !

!WeakValueLookupTable methodsFor: 'hacks'!

at: key ifAbsent: aBlock
    "Answer the value associated to the given key, or the result of evaluating
    aBlock if the key is not found"

    | result |
    result := super at: key ifAbsent: [ ^aBlock value ].
    result isNil ifFalse: [ ^result ].
    self beConsistent.
    ^super at: key ifAbsent: aBlock
!

at: key ifPresent: aBlock
    "If aKey is absent, answer nil. Else, evaluate aBlock passing the
    associated value and answer the result of the invocation"

    ^aBlock value: (self at: key ifAbsent: [ ^nil ])
!

includesKey: key
    "Answer whether the receiver contains the given key."

    self at: key ifAbsent: [ ^false ].
    ^true
!


!WeakValueLookupTable methodsFor: 'private'!

beConsistent
     "Private - Clean the dictionary of key->(finalized value) pairs"
     | keys key |
     keys := WriteStream on: (Array new: self size // 3 + 1).
     1 to: self primSize do: [ :index |
	"Find values that are nil and should not be"
	(values isAlive: index) ifFalse: [
	    keys nextPut: (self primAt: index).
	    values clearGCFlag: index
	]
     ].

     self removeAllKeys: keys contents ifAbsent: [:key |]
!

initialize: anInteger
    "Private - Initialize the values array; plus, make it weak and create
    the ByteArray used to track garbage collected values"

    super initialize: anInteger.
    values := WeakArray new: self primSize.
!

primSize
    ^self basicSize
!

primAt: index
    ^self basicAt: index
!

primAt: index put: object
    ^self basicAt: index put: object
!

valueAt: index
    ^values at: index
!

valueAt: index put: object
    ^values at: index put: object
! !


!WeakValueLookupTable methodsFor: 'rehashing'!

rehash
    "Rehash the receiver"
    | key val |
    key := Array new: self primSize.
    val := Array new: values size.
    self resetTally.

    1 to: self primSize do: [ :i |
	"Find values that are nil and should not be"
	(key := self primAt: i) notNil ifTrue: [
	     (values isAlive: i) ifTrue: [
		key at: i put: (self primAt: i).
		val at: i put: (self valueAt: i).
	     ]
	].
	self primAt: i put: nil.
	self valueAt: i put: nil.
    ].

    1 to: self primSize do: [:i |
	(key at: i) isNil ifFalse: [
	    self whileGrowingAt: (key at: i) put: (val at: i)
	]
    ].
! !


!WeakIdentitySet methodsFor: 'accessing'!

identityIncludes: anObject
    "Answer whether I include anObject exactly.  As I am an
     identity-set, this is the same as #includes:."
    ^self includes: anObject
! !

!WeakIdentitySet methodsFor: 'private methods'!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject key identityHash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := (anObject key identityHash scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element key == anObject key ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !


!WeakKeyIdentityDictionary methodsFor: 'private methods'!

keysClass
    "Answer the class answered by #keys"
    ^IdentitySet
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject key identityHash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := (anObject identityHash scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element key == anObject ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !


!WeakValueIdentityDictionary methodsFor: 'private methods'!

keysClass
    "Answer the class answered by #keys"
    ^IdentitySet
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject identityHash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := (anObject identityHash scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element == anObject ])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !

