"======================================================================
|
|   MappedCollection Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006,2007,2008
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



Collection subclass: MappedCollection [
    | domain map |
    
    <category: 'Collections-Keyed'>
    <comment: 'I represent collections of objects that are indirectly indexed by names.
There are really two collections involved: domain and a map.  The map maps
between external names and indices into domain, which contains the
real association.  In order to work properly, the domain must be an instance
of a subclass of SequenceableCollection, and the map must be an instance of
Dictionary, or of a subclass of SequenceableCollection.

As an example of using me, consider implenting a Dictionary whose elements
are indexed. The domain would be a SequenceableCollection with n elements,
the map a Dictionary associating each key to an index in the domain. To
access by key, to perform enumeration, etc. you would ask an instance of me;
to access by index, you would access the domain directly.

Another idea could be to implement row access or column access to a matrix
implemented as a single n*m Array: the Array would be the domain, while the
map would be an Interval.
'>

    MappedCollection class >> collection: aCollection map: aMap [
	"Answer a new MappedCollection using the given domain (aCollection)
	 and map"

	<category: 'instance creation'>
	^self basicNew setCollection: aCollection andMap: aMap
    ]

    MappedCollection class >> new [
	"This method should not be used; instead, use #collection:map: to
	 create MappedCollection."

	<category: 'instance creation'>
	SystemExceptions.WrongMessageSent signalOn: #new
	    useInstead: #collection:map:
    ]

    at: key [
	"Answer the object at the given key"

	<category: 'basic'>
	^domain at: (map at: key)
    ]

    atAll: keyCollection [
	"Answer a new MappedCollection that only includes the given keys. The new
	 MappedCollection might use keyCollection or consecutive integers for the
	 keys, depending on the map's type. Fail if any of them is not found in
	 the map."

	<category: 'basic'>
	^self class collection: domain map: (map atAll: keyCollection)
    ]

    at: key put: value [
	"Store value at the given key"

	<category: 'basic'>
	^domain at: (map at: key) put: value
    ]

    domain [
	"Answer the receiver's domain"

	<category: 'basic'>
	^domain
    ]

    map [
	"Answer the receiver's map"

	<category: 'basic'>
	^map
    ]

    size [
	"Answer the receiver's size"

	<category: 'basic'>
	^map size
    ]

    add: anObject [
	<category: 'basic'>
	self shouldNotImplement
    ]

    contents [
	"Answer a bag with the receiver's values"

	<category: 'basic'>
	| aBag |
	aBag := Bag new.
	map do: [:value | aBag add: (domain at: value)].
	^aBag
    ]

    copyFrom: a to: b [
	"Answer a new collection containing all the items in the receiver from the
	 a-th to the b-th."
	<category: 'basic'>
	^domain atAll: (map atAll: (a to: b))
    ]

    do: aBlock [
	"Evaluate aBlock for each object"

	<category: 'basic'>
	map do: [:value | aBlock value: (domain at: value)]
    ]

    keys [
	"Answer the keys that can be used to access this collection."

	<category: 'basic'>
	^map keys
    ]

    keysAndValuesDo: aBlock [
	"Evaluate aBlock passing two arguments, one being a key that can be used to
	 access this collection, and the other one being the value."

	<category: 'basic'>
	map do: [:key | aBlock value: key value: (self at: key)]
    ]

    keysDo: aBlock [
	"Evaluate aBlock on the keys that can be used to access this collection."

	<category: 'basic'>
	map keysDo: aBlock
    ]

    collect: aBlock [
	"Answer a Collection with the same keys as the map, where accessing
	 a key yields the value obtained by passing through aBlock the value
	 accessible from the key in the receiver.  The result need not be
	 another MappedCollection"

	"This is tricky.  Optimize the operation in order to perform the
	 minimal number of evaluation of aBlock"

	<category: 'basic'>
	^domain size > map size 
	    ifTrue: [map collect: [:key | aBlock value: (self at: key)]]
	    ifFalse: [self class collection: (domain collect: aBlock) map: map copy]
    ]

    reject: aBlock [
	"Answer the objects in the domain for which aBlock returns false"

	<category: 'basic'>
	| newMap |
	newMap := newMap reject: [:key | aBlock value: (self at: key)].
	^self class collection: domain map: newMap
    ]

    select: aBlock [
	"Answer the objects in the domain for which aBlock returns true"

	<category: 'basic'>
	| newMap |
	newMap := newMap select: [:key | aBlock value: (self at: key)].
	^self class collection: domain map: newMap
    ]

    setCollection: aCollection andMap: aMap [
	<category: 'private'>
	domain := aCollection.
	map := aMap
    ]

    species [
	<category: 'private'>
	^self class
    ]
]

