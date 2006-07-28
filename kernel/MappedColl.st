"======================================================================
|
|   MappedCollection Method Definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2006
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


Collection subclass: #MappedCollection
	   instanceVariableNames: 'domain map'
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Collections-Keyed'
!

MappedCollection comment: 
'I represent collections of objects that are indirectly indexed by names.
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
' !


!MappedCollection class methodsFor: 'instance creation'!

collection: aCollection map: aMap
    "Answer a new MappedCollection using the given domain (aCollection)
     and map"
    ^self basicNew setCollection: aCollection andMap: aMap
!

new
    "This method should not be used; instead, use #collection:map: to
     create MappedCollection."
    SystemExceptions.WrongMessageSent signalOn: #new useInstead: #collection:map:
! !



!MappedCollection methodsFor: 'basic'!

at: key
    "Answer the object at the given key"
    ^domain at: (map at: key)
!

at: key put: value
    "Store value at the given key"
    ^domain at: (map at: key) put: value
!

size
    "Answer the receiver's size"
    ^domain size
!

add: anObject
    self shouldNotImplement
!

contents
    "Answer a bag with the receiver's values"
    | aBag |
    aBag := Bag new.
    map do: [ :value | aBag add: (domain at: value) ].
    ^aBag
!

do: aBlock
    "Evaluate aBlock for each object"
    map do: [ :value | aBlock value: (domain at: value) ]
!

domain
    "Answer the domain"
    ^domain
!

keys
    "Answer the keys that can be used to access this collection."
    ^map keys
!

map
    "Answer the map"
    ^map
!

collect: aBlock
    "Answer a MappedCollection with a copy of the receiver's map
     and a domain obtained by passing each object through aBlock"
    | newDomain |
    newDomain := domain collect: aBlock.
    ^self species collection: newDomain map: map copy.
!

reject: aBlock
    "Answer the objects in the domain for which aBlock returns false"

    | aStream map |
    aStream := WriteStream on: (domain copyEmpty: self size).
    self do: [ :value | (aBlock value: value) ifFalse:
    	    	[ aStream nextPut: value ] ].

    ^aStream contents
!

select: aBlock
    "Answer the objects in the domain for which aBlock returns true"

    | aStream |
    aStream := WriteStream on: (domain copyEmpty: self size).
    self do: [ :value | (aBlock value: value) ifFalse:
    	    	[ aStream nextPut: value ] ].

    ^aStream contents
! !



!MappedCollection methodsFor: 'private'!

setCollection: aCollection andMap: aMap
    domain := aCollection.
    map := aMap
!

species
    ^self class
! !
