"======================================================================
|
|   SandstoneDb.SDMemoryStore class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDCachedStore subclass: SDMemoryStore [
    | cache |
    
    <comment: 'I''m a store for persisting active records directly to a
    dictionary to show what a minimal implementation of a store must to
    do pass the unit tests.'>
    <category: 'SandstoneDb-Store'>

    Cache := nil.

    SDMemoryStore class >> initialize [
	"self initialize"
	<category: 'initialization'>

	Cache := Dictionary new.
    ]

     SDMemoryStore class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    abortChanges: anObject [
	<category: 'actions'>
	| diskVersion |
	anObject critical: 
		[self removeCachedOfClass: anObject class from: anObject id.
		diskVersion := self cachedLoadOfClass: anObject class from: anObject id.
		diskVersion ifNil: 
			[self 
			    addCachedOfClass: anObject class
			    at: anObject id
			    put: anObject]
		    ifNotNil: [anObject become: diskVersion]]
    ]

    addCachedOfClass: aClass at: anId put: anObject [
	<category: 'actions'>
	(cache at: aClass) at: anId put: anObject
    ]

    cachedLoadOfClass: aClass from: anId [
	<category:'actions'>
	^(cache at: aClass) at: anId
	    ifAbsent: 
		[([self loadClass: aClass atId: anId] on: SDLoadError do: [nil]) 
		    ifNotNil: 
			[:it | 
			"seems I have to make sure to cache the object before I can resolve
			 it's references so any backreferences to it don't try and load from
			 disk again''"

			(cache at: aClass) at: anId put: it.
			it sandstoneResolveReferences]]
    ]

    commit: aBlock [
	<category: 'actions'>
	self shouldNotImplement
    ]

    ensureForClass: aClass [
	<category: 'actions'>
	cache at: aClass ifAbsentPut: [Dictionary new: self defaultCacheSize]
    ]

    initialize [
	<category: 'actions'>
	super initialize.
	Cache := SDActiveRecord defaultDictionary new.
	cache := SDActiveRecord defaultDictionary new.
    ]

    loadClass: aClass atId: anId [
	<category: 'actions'>
	^(Cache at: anId) sandstoneResolveReferences
    ]

    recoverForClass: aClass [
	<category: 'actions'>
	Cache keysDo: [:e | self cachedLoadOfClass: aClass from: e]
    ]

    removeCachedOfClass: aClass from: anId [
	<category: 'actions'>
	^(cache at: aClass) removeKey: anId
	    ifAbsent: ["SDError signal: 'Deleted or new objects cannot be aborted'" nil]
    ]

    removeObject: anObject [
	<category: 'actions'>
	self removeCachedOfClass: anObject class from: anObject id.
	Cache removeKey: anObject id ifAbsent: []
    ]

    storeObject: anObject [
	<category: 'actions'>
	self 
	    addCachedOfClass: anObject class
	    at: anObject id
	    put: anObject.
	Cache at: anObject id
	    put: anObject sandstoneDeepCopy sandstoneMarkReferences
    ]

    updateObject: anObject [
	<category: 'actions'>
	self storeObject: anObject
    ]

    familyForClass: aClass [
	"I'm returing raw cache dictionary here because this read only copy
	 doesn't need concurrency protection, just a naked dictionary''"

	<category: 'queries'>
	^aClass allSubclasses inject: (cache at: aClass)
	    into: [:sum :subclass | sum addAll: (cache at: subclass). sum]
    ]
]


Eval [
    SDMemoryStore initialize
]

