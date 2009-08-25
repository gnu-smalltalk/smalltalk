"======================================================================
|
|   SandstoneDb.SDAbstractStore class definition
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



Object subclass: SDAbstractStore [
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I''m an abstract store to define what''s necessary to plug in a
    new method of storing active records.  When records are stored, they are
    already sliced out of the graph and have markers for any other references
    placed in them.  The store can serialize however it sees fit, but when
    loading, before returning the version from the store, it should resolve
    the references.'''>

    SDAbstractStore class >> new [
	<category: 'initialize-release'>
	^self basicNew initialize
    ]

    initialize []

    abortChanges: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    commit: aBlock [
	<category: 'actions'>
	self subclassResponsibility
    ]

    ensureDown [
	<category: 'actions'>
	
    ]

    ensureForClass: aClass [
	"at startUp, the store is sent this message to tell it to make sure it's ready to run, a
	 file store for instance may want to make sure it's directories exist"

	<category: 'actions'>
	self subclassResponsibility
    ]

    loadClass: aClass atId: anId [
	"Given a class and an Id, the store is expected to load a fresh copy of the object
	 from it's persistent medium'"

	<category: 'actions'>
	self subclassResponsibility
    ]

    recoverForClass: aClass [
	"The store is expected to loop through all it's stored instances of a class and
	 load them via cachedLoadFrom: on the class which will dispatch back to
	 loadObjectOfClass:atId on the store when a cached version of the object is not found.
	 This happens once per class at system startup"

	<category: 'actions'>
	self subclassResponsibility
    ]

    removeObject: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    storeObject: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    updateObject: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    defaultCacheSize [
	<category: 'defaults'>
	^10000
    ]

    forClass: aClass [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass at: anId ifAbsent: aHandler [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass detect: aBlock ifFound: aHandler [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass detect: aBlock ifNone: aHandler [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass do: aBlock [
	<category: 'delegated queries'>
	
    ]

    forClass: aClass findAll: aBlock [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]
]

