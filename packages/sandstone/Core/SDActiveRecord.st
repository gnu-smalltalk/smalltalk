"======================================================================
|
|   SandstoneDb.SDActiveRecord class definition
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


"PORTING : GST doesn't seem to have Monitors. Use RecursionLock instead..."


Object subclass: SDActiveRecord [
    | id createdOn updatedOn version isNew |
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I''m the core of a simple object database based upon a mix of
    several patterns intended for use with *small* Seaside based web
    applications.  I am not meant to scale to millions of records, just tens
    of thousands, but for prototyping and small office applications where the
    number of records are in the thousands and the number of concurrent users
    can be handled by a single Squeak image.  To use me, simply subclass me and
    restart your image that''s it.  For more information see
    http://onsmalltalk.com/programming/smalltalk/sandstonedb-simple-activerecord-style-persistence-in-squeak/'>

    SDActiveRecord class [
	| locks |
	
    Store := nil.
    ]

    SDActiveRecord class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    SDActiveRecord class >> atId: anId [
	"hitting this in a tight loop for a class with subclasses can be very
	expensive because allCaches has to concatenate all the subclasses
	caches into a new copy that contains all subclass records"
	<category: 'queries'>

	^self atId: anId ifAbsent: [nil]
    ]

    SDActiveRecord class >> atId: anId ifAbsent: aHandler [
	"hitting this in a tight loop for a class with subclasses can be very
	expensive because allCaches has to concatenate all the subclasses
	caches into a new copy that contains all subclass records"
	<category: 'queries'>

	^Store 
	    forClass: self
	    at: anId
	    ifAbsent: aHandler
    ]

    SDActiveRecord class >> do: aBlock [
	"do on a copy in case the do modifies the collection I'm trying
	to iterate'"
	<category: 'queries'>

	Store forClass: self do: aBlock
    ]

    SDActiveRecord class >> find: aBlock [
	<category: 'queries'>
	^self find: aBlock ifAbsent: [nil]
    ]

    SDActiveRecord class >> find: aBlock ifAbsent: aHandler [
	<category: 'queries'>
	^Store 
	    forClass: self
	    detect: aBlock
	    ifNone: aHandler
    ]

    SDActiveRecord class >> find: aBlock ifPresent: aHandler [
	<category: 'queries'>
	^Store 
	    forClass: self
	    detect: aBlock
	    ifFound: aHandler
    ]

    SDActiveRecord class >> findAll [
	<category: 'queries'>
	^(Store forClass: self) values
    ]

    SDActiveRecord class >> findAll: aBlock [
	<category: 'queries'>
	^(Store forClass: self findAll: aBlock) values
    ]

    SDActiveRecord class >> commit: aBlock [
	<category: 'actions'>
	^Store commit: aBlock
    ]

    SDActiveRecord class >> coolDown [
	<category: 'actions'>
	locks := nil.
	self ensureReady
    ]

    SDActiveRecord class >> resetStoreForLoad [
	<category: 'actions'>
	self setStore: self store class new
    ]

    SDActiveRecord class >> warmUp [
	<category: 'actions'>
	| loadTime |
	loadTime := Time millisecondsToRun: [
	    Store ensureForClass: self.
	    self ensureReady.
	    Store recoverForClass: self].
	"Transcript
	    show: self name , ' loaded in ' , loadTime printString;
	    cr"
    ]

    SDActiveRecord class >> warmUpAllClasses [
	<categroy: 'actions'>
	self allSubclassesDo: [:each | self store ensureForClass: each].
	self allSubclassesDo: [:each | each warmUp]
    ]

    SDActiveRecord class >> defaultStore [
	<category: 'defaults'>
	^SDFileStore new
    ]

    SDActiveRecord class >> ensureReady [
	<category: 'actions private'>
	locks 
	    ifNil: [locks := SDConcurrentDictionary on: (WeakKeyDictionary new: 10000)]
    ]

    SDActiveRecord class >> defaultDictionary [
	<categroy: 'defaults'>
	^Dictionary
    ]
   
    SDActiveRecord class >> defaultHashSize [
	<category: 'defaults'>
	^100
    ]

    SDActiveRecord class >> defaultIdentityDictionary [
	<category: 'defaults'>
	^IdentityDictionary
    ]
    
    SDActiveRecord class >> initialize [
	<category: 'initialization'>
	Store := self defaultStore
    ]

    SDActiveRecord class >> setStore: aStore [
	<category: 'initialization'>
	Store ifNotNil: [Store ensureDown].
	Store := aStore
    ]

    SDActiveRecord class >> lockFor: anInstance [
	<category: 'queries private'>
	^locks at: anInstance id ifAbsentPut: [RecursionLock new]
    ]

    SDActiveRecord class >> store [
	<category: 'accessing'>
	^Store
    ]

    initialize [
	<category: 'initialize-release'>
	id := UUID new printString.
	createdOn := updatedOn := DateTime now.
	version := 0.
	isNew := true
    ]

    = anObject [
	"asking the object isMemberOf ensures that if it's a proxy that message
	 will be forwarded to the real object.  Checking this condition in reverse
	 anObject class, will fail because anObject class will be the ProxyClass"
	<category: 'comparing'>

	^(anObject isMemberOf: self class) and: [id = anObject id]
    ]

    hash [
	<category: 'comparing'>
	^id hash
    ]

    abortChanges [
	"Rollback object to the last saved version"
	<category: 'actions'>

	Store abortChanges: self
    ]

    critical: aBlock [
	<category: 'actions'>
	^(self class lockFor: self) critical: aBlock
    ]

    delete [
	"I'm using monitors for locking so this can be wrapped in larger critical
	 in your application code if you want more scope on the critical'"
	<category: 'actions'>

	self critical: 
		[self onBeforeDelete.
		Store removeObject: self.
		self onAfterDelete.
		self initialize]
    ]

    save [
	"I'm using monitors for locking so this can be wrapped in larger critical
	 in your application code if you want more scope on the critical'"
	<category: 'actions'>

	| isFirstSave |
	self critical: 
		[self validate.
		isFirstSave := isNew.
		isFirstSave ifTrue: [self onBeforeFirstSave].
		self onBeforeSave.
		isFirstSave 
		    ifTrue: [Store storeObject: self]
		    ifFalse: [Store updateObject: self].
		isFirstSave ifTrue: [self onAfterFirstSave].
		self onAfterSave.
		^self]
    ]

    save: aBlock [
	<category: 'actions'>
	self critical: 
		[aBlock value.
		^self save]
    ]

    validate [
	"for subclasses to override and throw exceptions to prevent saves"
	<category: 'actions'>

	
    ]

    asReferenceMarker [
	<category: 'converting'>
	isNew 
	    ifTrue: 
		["Programmers may reach this point several times until they
		get the intended use of this solution. This is expected **by
		design** to make atomic saves really small and consistent.
		Commits of active records which have other active records as
		parts (at any deep) are restricted intentionally. They only are
		allowed when all its sub active records are previously commited.
		Only the programmer knows the proper logical commit order for
		his data!! This is not a relational database, if you absolutely
		need several objects to be atomically saved, then you should
		make them all part of a single aggregate, all of your objects
		should not be active records, only your aggregate roots are
		active records...
		http://domaindrivendesign.org/discussion/messageboardarchive/Aggregates.html'"

		SDCommitError 
		    signal: 'An object is being saved while referencing an unsaved peer of type ' 
			    , self class name , '.  You must save that record first!'].
	^(SDRecordMarker new)
	    id: id;
	    className: self class name;
	    environment: self class environment;
	    yourself
    ]

    createdOn [
	<category: 'accessing'>
	^createdOn
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    indexString [
	"All instance variable's asStrings as a single delimeted string for
	easy searching"
	<category: 'accessing'>

	^String streamContents: 
		[:s | 
		self class allInstVarNames do: 
			[:each | 
			(self instVarNamed: each) ifNotNil: 
				[:value | 
				s
				    nextPutAll: value asString;
				    nextPutAll: '~~']]]
    ]

    updatedOn [
	<category: 'accessing'>
	^updatedOn
    ]

    version [
	<category: 'accessing'>
	^version
    ]

    isNew [
	"Only answers true before an objects first save."
	<category: 'testing'>

	^isNew ifNil: [isNew := true]
    ]

    isSandstoneActiveRecord [
	"Answers true if the receiver is a Sandstone Active Record."
	<category: 'testing'>

	^true
    ]

    onAfterDelete [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onAfterFirstSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onAfterSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onBeforeDelete [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onBeforeFirstSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	createdOn := DateTime now
    ]

    onBeforeSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	updatedOn := DateTime now.
	version := version + 1.
	isNew := false
    ]
]



Eval [
    SDActiveRecord initialize
]

