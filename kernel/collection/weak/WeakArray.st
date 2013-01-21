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
