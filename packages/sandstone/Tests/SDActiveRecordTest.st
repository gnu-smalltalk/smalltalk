"======================================================================
|
|   SandstoneDb.SDActiveRecordTest class definition
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



TestCase subclass: SDActiveRecordTest [
    | mom kid store |
    
    <comment: 'Part of the reason I did this project was to force myself to
    learn to do more unit testing.  I''m starting to learn to like it.'>
    <category: 'SandstoneDb-Tests'>

    SDActiveRecordTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    defaultStore [
	<category: 'running'>
	self subclassResponsibility
    ]

    flushAndReload [
	<category: 'running'>
	SDPersonMock
	    coolDown;
	    warmUp
    ]

    setUp [
	<category: 'running'>
	store := self defaultStore.
	SDPersonMock setStore: store.
	SDPersonMock warmUp.
	FooObject warmUp.
	SDPersonMock allSubclassesDo: [:each | each warmUp].
	mom := SDPersonMock testPerson.
	kid := SDPersonMock testPerson
    ]

    tearDown [
	<category: 'running'>
	SDPersonMock do: [:each | each delete].
	SDPersonMock coolDown.
	FooObject do: [:each | each delete].
	SDPersonMock allSubclassesDo: [:each | each coolDown].
	ObjectMemory compact
    ]

    testAbort [
	<category: 'running'>
	kid name: 'Joe'.
	kid save.
	kid name: 'Mary'.
	self assert: kid name = 'Mary'.
	kid abortChanges.
	self assert: kid name = 'Joe'
    ]

    testArraySerialization [
	<category: 'running'>
	kid save.
	mom children: {kid}.
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testAtIdSubclasses [
	<category: 'running'>
	| man woman |
	man := SDManMock testPerson save.
	woman := SDWomanMock testPerson save.
	mom save.
	self assert: (SDPersonMock atId: mom id) = mom.
	self assert: (SDPersonMock atId: man id) = man.
	self assert: (SDPersonMock atId: woman id) = woman.
	man delete.
	woman delete
    ]

    testBagSerialization [
	<category: 'running'>
	kid save.
	mom children: (Bag with: kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testBigSave [
	<category: 'running'>
	| commitTime people deleteTime lookupTime |
	people := (1 to: 50) collect: [:it | SDPersonMock testPerson].
	commitTime := Time millisecondsToRun: [people do: [:each | each save]].
	lookupTime := Time millisecondsToRun: [people do: [:each | SDPersonMock atId: each id]].
	deleteTime := Time millisecondsToRun: [people do: [:each | each delete]].
	"Transcript
	    show: commitTime printString;
	    cr;
	    show: deleteTime printString;
	    cr;
	    show: lookupTime printString;
	    cr;
	    cr."
	self assert: commitTime < (4*1000) "seconds".
	self assert: deleteTime < (3*1000) "seconds"
    ]

    testCollectionSerialization [
	<category: 'running'>
	kid save.
	mom children: (OrderedCollection with: kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testCreatedOn [
	<category: 'running'>
	kid save.
	self assert: kid createdOn <= DateTime now
    ]

    testDeepCopy [
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	 at which point the copying stops, and the actual references is returned."

	<category: 'running'>
	| copy obj |
	kid save.
	mom save.
	kid buddy: #not -> (#deeper -> mom).
	obj := Object new.
	kid father: obj.
	copy := kid sandstoneDeepCopy.
	self assert: copy buddy value value == mom.
	self deny: copy father == obj
    ]

    testDelete [
	<category: 'running'>
	kid save.
	self deny: kid isNew.
	self assert: kid version equals: 1.
	kid delete.
	self assert: kid isNew.
	self assert: kid version equals: 0.
	self flushAndReload.
	self assert: (SDPersonMock find: [:each | each id = kid id]) isNil
    ]

    testDeleteAndFind [
	<category: 'running'>
	kid name: 'zorgle'.
	kid save.
	self deny: kid isNew.
	kid delete.
	self assert: (SDPersonMock find: [:e | e name = 'zorgle']) isNil
    ]

    testDeleteSubclass [
	<category: 'running'>
	kid := SDManMock testPerson save.
	self deny: kid isNew.
	self assert: kid version equals: 1.
	kid delete.
	self assert: kid isNew.
	self assert: kid version equals: 0.
	self flushAndReload.
	self assert: (SDManMock find: [:each | each id = kid id]) isNil
    ]

    testDictionarySerialization [
	<category: 'running'>
	kid save.
	mom children: (Dictionary with: #son -> kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children at: #son) equals: kid refreshed
    ]

    testEquality [
	<category: 'running'>
	mom save.
	kid mother: mom.
	kid save.
	self flushAndReload.
	self assert: kid refreshed mother equals: mom refreshed
    ]

    testFind [
	<category: 'running'>
	kid save.
	self flushAndReload.
	self deny: (SDPersonMock find: [:each | each id = kid id]) isNil.
	self assert: (SDPersonMock find: [:each | each id = 'not']) isNil
    ]

    testFindAll [
	<category: 'running'>
	kid save.
	self flushAndReload.
	self assert: (SDPersonMock findAll class = Array).
	self assert: (SDPersonMock findAll: [:each | each id = 'not' ]) class = Array.
    ]

    testFindAllSubclasses [
	<category: 'running'>
	|man woman child grandchild |
	man := SDManMock testPerson save.
	woman := SDWomanMock testPerson save.
	child := SDChildMock testPerson save.
	grandchild := SDGrandChildMock testPerson save.
	mom save.
	self
	    assert: 5
	    equals: SDPersonMock findAll size.
	self assert: (SDPersonMock findAll contains: [:e | e class = SDManMock]).
	self
	    assert: 1
	    equals: SDManMock findAll size.
	self
	    assert: 2
	    equals: SDChildMock findAll size.
	self
	    assert: 1
	    equals: SDGrandChildMock findAll size.
	man delete.
	woman delete.
	child delete.
	grandchild delete
    ]

    testFindById [
	<category: 'running'>
	kid save.
	self deny: (SDPersonMock atId: kid id) isNil
    ]

    testFindIdentity [
	<category: 'running'>
	mom save.
	self flushAndReload.
	self assert: (SDPersonMock atId: mom id) = (SDPersonMock atId: mom id)
    ]

    testFindSubclasses [
	<category: 'running'>
	| man woman child grandchild |
	man := SDManMock testPerson save.
	woman := SDWomanMock testPerson save.
	child := SDChildMock testPerson save.
	grandchild := SDGrandChildMock testPerson save.
	self assert: man = (SDPersonMock find: [:e | e id = man id]).
	self assert: woman= (SDPersonMock find: [:e | e id = woman id]).
	self assert: child = (SDPersonMock find: [:e | e id = child id]).
	self assert: grandchild = (SDPersonMock find: [:e | e id = grandchild id]).
	man delete.
	woman delete.
	child delete.
	grandchild delete
    ]

    testIdentity [
	<category: 'running'>
	mom save.
	kid mother: mom.
	kid save.
	self flushAndReload.
	self assert: kid refreshed mother == mom refreshed
    ]

    testIsNew [
	<category: 'running'>
	self assert: kid isNew.
	kid save.
	self deny: kid isNew.
	kid delete.
	self assert: kid isNew
    ]

    testMarkReferences [
	<category: 'running'>
	kid mother: mom.
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid mother isKindOf: SDRecordMarker)
    ]

    testMarkReferencesCopies [
	<category: 'running'>
	kid save.
	mom children: {kid}.
	mom save.
	self assert: mom children first == kid
    ]

    testMarkReferencesRecursive [
	<category: 'running'>
	kid buddy: #not -> mom.
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeper [
	<category: 'running'>
	kid buddy: #not -> (#deeper -> mom).
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value value isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperInCollection [
	<category: 'running'>
	kid buddy: #not -> {#deeper -> mom}.
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value first value isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperInDictionary [
	<category: 'running'>
	kid buddy: #not -> {Dictionary with: #deeper -> mom}.
	mom save.
	kid sandstoneMarkReferences.
	self 
	    assert: ((kid buddy value first at: #deeper) isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperNestedList [
	<category: 'running'>
	kid buddy: #not -> (Array with: (Array with: mom)).
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value first first isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperNotTouchedInOrig [
	<category: 'running'>
	| otherKid |
	kid buddy: #not -> (#deeper -> mom).
	otherKid := kid sandstoneDeepCopy.
	otherKid buddy value value save.
	otherKid sandstoneMarkReferences.
	self assert: (kid buddy value value isKindOf: mom class)
    ]

    testMarkReferencesStops [
	<category: 'running'>
	| other |
	other := SDManMock testPerson save.
	mom father: other.
	kid buddy: #some -> (#time -> mom).
	mom save.
	kid sandstoneMarkReferences.
	self assert: mom father == other
    ]

    testPeerIdentity [
	<category: 'running'>
	mom save.
	kid mother: mom.
	kid save.
	self flushAndReload.
	self assert: kid refreshed mother = mom refreshed
    ]

    testResolveReferences [
	<category: 'running'>
	mom save.
	kid mother: mom asReferenceMarker.
	kid sandstoneResolveReferences.
	self assert: (kid mother isKindOf: SDActiveRecord)
    ]

    testResolveReferencesRecursive [
	<category: 'running'>
	mom save.
	kid buddy: #not -> mom asReferenceMarker.
	kid sandstoneResolveReferences.
	self assert: (kid buddy value isKindOf: SDActiveRecord)
    ]

    testResolveReferencesRecursiveDeeperNestedList [
	<category: 'running'>
	mom save.
	kid buddy: #not -> (Array with: (Array with: mom asReferenceMarker)).
	kid sandstoneResolveReferences.
	self assert: (kid buddy value first first isKindOf: SDActiveRecord)
    ]

    testSetSerialization [
	<category: 'running'>
	kid save.
	mom children: (Set with: kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testUpdatedOn [
	<category: 'running'>
	kid save.
	self assert: kid updatedOn <= DateTime now
    ]

    testVersion [
	<category: 'running'>
	self assert: kid version equals: 0.
	kid save.
	self assert: kid version equals: 1.
	kid save.
	self assert: kid version equals: 2
    ]

    testDictionaryWithArrays [
	<category: 'testing'>
	| foo |
	3 timesRepeat: [SDManMock new save].
	foo := (FooObject new)
		    dict: ((Dictionary new)
				at: #bar put: SDManMock findAll;
				at: #baz put: SDManMock findAll;
				yourself);
		    yourself.

	"Works fine before saving the object"
	foo dict 
	    keysAndValuesDo: [:key :value | value do: [:each | self assert: (each isKindOf: SDManMock)]].
	foo save.

	"now fails"
	foo dict 
	    keysAndValuesDo: [:key :value | value do: [:each | self assert: (each isKindOf: SDManMock)]]
    ]
]

