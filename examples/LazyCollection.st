"======================================================================
|
|   Lazy implementation of #select:/#collect:/#reject:
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"

"This example modifies the common iteration protocol for Collections,
 i.e. #select:/#collect:/#reject:, so that no new collection is created.
 The blocks are saved until the collection is absolutely necessary.
 Until you ask something from the collection, no operation is done and
 the chain of selection/collection/rejection operators is kept.  Moreover,
 even iteration with #do:, #fold:, #allSatisfy:, and so on does not create
 a new collection (which can be a mixed blessing of course, because the
 blocks may be evaluated many times).

 To get a collection from the proxy, just send it asCollection."

Object subclass: #CollectionFilter
       instanceVariableNames: 'prev'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

CollectionFilter subclass: #BlockCollectionFilter
       instanceVariableNames: 'block'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

BlockCollectionFilter subclass: #SelectFilter
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

BlockCollectionFilter subclass: #RejectFilter
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

BlockCollectionFilter subclass: #CollectFilter
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

nil subclass: #CollectionProxy
       instanceVariableNames: 'collection filter'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

CollectionProxy subclass: #ArrayedCollectionProxy
       instanceVariableNames: 'stream'
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!

CollectionProxy subclass: #DictionaryProxy
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'Examples-Collections'!


!CollectionFilter class methodsFor: 'instance creation'!

on: anObject
    ^self new initialize: anObject!
	
!CollectionFilter methodsFor: 'applying'!

map: anObject ifRemovedReturn: removedMarker
    | newObject |
    newObject := prev isNil
	ifTrue: [ anObject ]
	ifFalse: [ prev map: anObject ifRemovedReturn: removedMarker ].
    newObject == removedMarker ifTrue: [ ^removedMarker ].
    ^self value: newObject ifRemovedReturn: removedMarker!

value: anObject ifRemovedReturn: removedMarker
    self subclassResponsibility!

sizeFrom: aCollection
    ^nil! !


!CollectionFilter methodsFor: 'querying classes'!

copyEmpty: collection
    ^prev isNil
	ifTrue: [ collection copyEmpty ]
	ifFalse: [ prev copyEmpty: collection ]!

copyEmpty: collection size: size
    ^prev isNil
	ifTrue: [ collection copyEmpty: size ]
	ifFalse: [ prev copyEmpty: collection size: size ]!

!CollectionFilter methodsFor: 'initializing'!

initialize: prevFilter
    prev := prevFilter! !


!BlockCollectionFilter class methodsFor: 'instance creation'!

on: anObject value: aBlock
    ^(self on: anObject) block: aBlock!

!BlockCollectionFilter methodsFor: 'accessing'!

value: anObject ifRemovedReturn: removedMarker
    ^block value: anObject!

!BlockCollectionFilter methodsFor: 'initialization'!

block: aBlock
    block := aBlock! !

!SelectFilter methodsFor: 'applying'!

value: anObject ifRemovedReturn: removedMarker
    ^(super value: anObject ifRemovedReturn: removedMarker)
	ifFalse: [ removedMarker ]
	ifTrue: [ anObject ]! !


!RejectFilter methodsFor: 'applying'!

value: anObject ifRemovedReturn: removedMarker
    ^(super value: anObject ifRemovedReturn: removedMarker)
	ifTrue: [ removedMarker ]
	ifFalse: [ anObject ]! !


!CollectFilter methodsFor: 'applying'!

sizeFrom: aCollection
    ^prev isNil
	ifTrue: [ aCollection size ]
	ifFalse: [ prev sizeFrom: aCollection ]! !


!CollectFilter methodsFor: 'querying classes'!

copyEmpty: collection
    ^collection copyEmptyForCollect!

copyEmpty: collection size: size
    ^collection copyEmptyForCollect: size! !


!CollectionProxy class methodsFor: 'instance creation'!

on: collection filter: filter
    ^self new
	initializeCollection: collection filter: filter;
	yourself! !


!CollectionProxy methodsFor: 'basic object protocol'!

== anObject
    <primitive: VMpr_Object_identity>
!

~~ anObject
    ^(self == anObject) not
!

= anObject
    <primitive: VMpr_Object_identity>
!

~= anObject
    ^(self = anObject) not
!

class
    <primitive: VMpr_Object_class>
    self primitiveFailed
!

hash
    <primitive: VMpr_Object_hash>
!

yourself
    ^self
!

become: otherObject
    <primitive: VMpr_Object_become>
    ^SystemExceptions.ReadOnlyObject signal
!

copy
    ^self!

shallowCopy
    ^self!

deepCopy
    ^self asCollection! !


!CollectionProxy methodsFor: 'proxying'!

doesNotUnderstand: aMessage
    ^self asCollection perform: aMessage!

asCollection
    | builtCollection marker |
    builtCollection := filter copyEmpty: collection.
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ builtCollection add: newObject ] ].
    ^self become: builtCollection!

size
    ^(filter sizeFrom: collection) ifNil: [ self asCollection size ]!


!CollectionProxy methodsFor: 'iterating'!

allSatisfy: aBlock
    | marker |
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ (aBlock value: newObject) ifFalse: [ ^false ] ] ].
    ^true!

anySatisfy: aBlock
    | marker |
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ (aBlock value: newObject) ifTrue: [ ^true ] ] ].
    ^false!

conform: aBlock
    ^self allSatisfy: aBlock!

contains: aBlock
    ^self anySatisfy: aBlock!

detect: aBlock ifNone: exceptionBlock
    | marker |
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ (aBlock value: newObject) ifTrue: [ ^newObject ] ] ].
    ^exceptionBlock value!
    
detect: aBlock
    ^self detect: aBlock
	 ifNone: [ SystemExceptions.NotFound signal: 'object not found' ]!

do: aBlock
    | marker |
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ aBlock value: newObject ] ]!

fold: aBlock
    | obj marker first |
    first := true.
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [
		obj := first
		    ifTrue: [ newObject ]
		    ifFalse: [ aBlock value: obj value: newObject ].
		first := false ] ].

    first ifTrue: [ ^SystemExceptions.EmptyCollection signalOn: self ].
    ^obj!

inject: anObject into: aBlock
    | obj marker |
    obj := anObject.
    marker := Object new.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ obj := aBlock value: obj value: newObject ] ].
    ^obj! !

!CollectionProxy methodsFor: 'nesting'!

select: aBlock
    ^self class
	on: collection filter: (SelectFilter on: filter value: aBlock)!

reject: aBlock
    ^self class
	on: collection filter: (RejectFilter on: filter value: aBlock)!

collect: aBlock
    ^self class
	on: collection filter: (CollectFilter on: filter value: aBlock)! !


!CollectionProxy methodsFor: 'initializing'!

initializeCollection: aCollection filter: aCollectionFilter
    collection := aCollection.
    filter := aCollectionFilter! !
	

!ArrayedCollectionProxy methodsFor: 'proxying'!

readStream
    | stream marker size |
    stream isNil ifTrue: [
	marker := Object new.
	stream := WriteStream on: (filter copyEmpty: collection).
	collection do: [ :each || newObject |
	    newObject := filter map: each ifRemovedReturn: marker.
	    newObject == marker
	        ifFalse: [ stream nextPut: newObject ] ] ].

    ^stream readStream!

asCollection
    | builtCollection marker n size |
    (stream notNil or: [ (size := filter sizeFrom: collection) isNil ])
	ifTrue: [ ^self become: self readStream contents ].

    marker := Object new.
    builtCollection := filter copyEmpty: collection size: size.
    n := 0.
    collection do: [ :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ builtCollection at: (n := n + 1) put: newObject ] ].
    ^self become: builtCollection! !


!DictionaryProxy methodsFor: 'proxying'!

asCollection
    | builtCollection marker |
    builtCollection := filter copyEmpty: collection.
    marker := Object new.
    collection keysAndValuesDo: [ :key :each || newObject |
	newObject := filter map: each ifRemovedReturn: marker.
	newObject == marker
	    ifFalse: [ builtCollection at: key put: newObject ] ].
    ^self become: builtCollection! !


!Collection methodsFor: 'iterating'!

select: aBlock
    ^CollectionProxy
	on: self filter: (SelectFilter on: nil value: aBlock)!

reject: aBlock
    ^CollectionProxy
	on: self filter: (RejectFilter on: nil value: aBlock)!

collect: aBlock
    ^CollectionProxy
	on: self filter: (CollectFilter on: nil value: aBlock)! !


!ArrayedCollection methodsFor: 'iterating'!

select: aBlock
    ^ArrayedCollectionProxy
	on: self filter: (SelectFilter on: nil value: aBlock)!

reject: aBlock
    ^ArrayedCollectionProxy
	on: self filter: (RejectFilter on: nil value: aBlock)!

collect: aBlock
    ^ArrayedCollectionProxy
	on: self filter: (CollectFilter on: nil value: aBlock)! !


!Dictionary methodsFor: 'iterating'!

select: aBlock
    ^DictionaryProxy
	on: self filter: (SelectFilter on: nil value: aBlock)!

reject: aBlock
    ^DictionaryProxy
	on: self filter: (RejectFilter on: nil value: aBlock)!

collect: aBlock
    ^DictionaryProxy
	on: self filter: (CollectFilter on: nil value: aBlock)! !

