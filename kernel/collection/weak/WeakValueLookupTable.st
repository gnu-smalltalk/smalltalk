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
