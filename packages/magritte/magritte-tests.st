Object subclass: MAAccessorMock [
    
    <category: 'Magritte-Tests-Accessor'>
    <comment: nil>
]



Object subclass: MAMockAddress [
    | place street plz |
    
    <category: 'Magritte-Tests-Mocks'>
    <comment: nil>

    MAMockAddress class >> descriptionPlace [
	<category: 'descriptions'>
	^(MAStringDescription new)
	    autoAccessor: 'place';
	    label: 'Place';
	    yourself
    ]

    MAMockAddress class >> descriptionPlz [
	<category: 'descriptions'>
	^(MANumberDescription new)
	    autoAccessor: 'plz';
	    label: 'PLZ';
	    yourself
    ]

    MAMockAddress class >> descriptionStreet [
	<category: 'descriptions'>
	^(MAStringDescription new)
	    autoAccessor: 'street';
	    label: 'Street';
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^self species = anObject species and: 
		[self street = anObject street 
		    and: [self plz = anObject plz and: [self place = anObject place]]]
    ]

    hash [
	<category: 'comparing'>
	^self street hash
    ]

    place [
	<category: 'accessing-generated'>
	^place
    ]

    place: anObject [
	<category: 'accessing-generated'>
	place := anObject
    ]

    plz [
	<category: 'accessing-generated'>
	^plz
    ]

    plz: anObject [
	<category: 'accessing-generated'>
	plz := anObject
    ]

    street [
	<category: 'accessing-generated'>
	^street
    ]

    street: anObject [
	<category: 'accessing-generated'>
	street := anObject
    ]
]



TestCase subclass: MAAdaptiveModelTest [
    | scaffolder |
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    descriptions [
	<category: 'accessing'>
	^self scaffolder description children
    ]

    scaffolder [
	<category: 'accessing'>
	^scaffolder
    ]

    setUp [
	<category: 'running'>
	scaffolder := MAAdaptiveModel new.
	(scaffolder description)
	    add: MAStringDescription new;
	    add: MANumberDescription new.
	scaffolder write: 'foo' using: self descriptions first.
	scaffolder write: 123 using: self descriptions second
    ]

    testRead [
	<category: 'testing'>
	self assert: (self scaffolder readUsing: self descriptions first) = 'foo'.
	self assert: (self scaffolder readUsing: self descriptions second) = 123
    ]

    testWrite [
	<category: 'testing'>
	self scaffolder write: 'bar' using: self descriptions first.
	self scaffolder write: 321 using: self descriptions second.
	self assert: (self scaffolder readUsing: self descriptions first) = 'bar'.
	self assert: (self scaffolder readUsing: self descriptions second) = 321
    ]
]



TestCase subclass: MADescriptionBuilderTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Utility'>

    MADescriptionBuilderTest class >> descriptionContainer [
	<category: 'mock-descriptions'>
	^super descriptionContainer label: 'mock'
    ]

    MADescriptionBuilderTest class >> descriptionContainer: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #bar put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionContainerFoo: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #foo put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionDescription [
	<category: 'mock-descriptions'>
	^MAToOneRelationDescription new label: 'foo'
    ]

    MADescriptionBuilderTest class >> descriptionDescription: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #foo put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionDescriptionBar: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #bar put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionDescriptionRec: aDescription [
	<category: 'mock-descriptions'>
	^aDescription reference: self description
    ]

    testContainer [
	<category: 'testing'>
	self assert: self description label = 'mock'.
	self assert: (self description hasProperty: #foo).
	self assert: (self description hasProperty: #bar)
    ]

    testDescription [
	<category: 'testing'>
	self assert: self description size = 1.
	self assert: self description children first label = 'foo'.
	self assert: (self description children first hasProperty: #foo).
	self assert: (self description children first hasProperty: #bar)
    ]

    testRecursive [
	<category: 'testing'>
	self assert: self description children first reference = self description
    ]
]



TestCase subclass: MADynamicObjectTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Utility'>

    testCalculated [
	<category: 'testing'>
	| object dummy |
	object := MADynamicObject on: [Time millisecondClockValue].
	dummy := object yourself.
	(Delay forMilliseconds: 2) wait.
	self assert: dummy < object yourself
    ]

    testCollection [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [OrderedCollection with: 1 with: 2].
	self assert: object size = 2.
	self assert: object first = 1.
	self assert: object second = 2.
	object add: 3.
	self assert: object size = 2.
	self assert: object first = 1.
	self assert: object second = 2
    ]

    testConstant [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [self].
	self assert: object = self.
	object := MADynamicObject on: [123].
	self assert: object = 123
    ]

    testCopy [
	<category: 'testing'>
	| object first second |
	object := (MADynamicObject on: [Time millisecondClockValue]) copy.
	first := object yourself.
	(Delay forMilliseconds: 2) wait.
	second := object yourself.
	self assert: first < second
    ]

    testCounter [
	<category: 'testing'>
	| object counter |
	counter := nil.
	object := MADynamicObject 
		    on: [counter := counter isNil ifTrue: [1] ifFalse: [counter := counter + 1]].
	self assert: object = 1.
	self assert: object yourself = 2.
	self assert: object yourself yourself = 3
    ]

    testDynamic [
	<category: 'testing'>
	| object collection |
	collection := nil.
	object := MADynamicObject on: 
			[collection isNil 
			    ifTrue: [collection := OrderedCollection with: 1 with: 2]
			    ifFalse: [collection]].
	self assert: object size = 2.
	self assert: object first = 1.
	self assert: object second = 2.
	object add: 3.
	self assert: object size = 3.
	self assert: object first = 1.
	self assert: object second = 2.
	self assert: object third = 3
    ]

    testException [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [1 / 0].
	self should: [object asString] raise: ZeroDivide.
	object := MADynamicObject on: [Halt signal].
	self assert: object asString = 'nil'
    ]

    "testNilOrNotNil [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [1].
	self deny: object isNil.
	self assert: object notNil.
	object := MADynamicObject on: [nil].
	self assert: object isNil.
	self deny: object notNil
    ]"
]



TestCase subclass: MAExtensionsTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Utility'>

    testCopyWithAll [
	<category: 'testing-collection'>
	| col res |
	col := #(#a #b).
	res := col copyWithAll: #(#c #d).
	self assert: res = #(#a #b #c #d).
	self deny: col == res.
	col := Set with: #a with: #b.
	res := col copyWithAll: #(#c #d).
	self assert: res size = 4.
	self assert: (res includes: #a).
	self assert: (res includes: #b).
	self assert: (res includes: #c).
	self assert: (res includes: #d).
	self deny: col == res.
	col := OrderedCollection with: #a with: #b.
	res := col copyWithAll: #(#c #d).
	self 
	    assert: res = (OrderedCollection 
			    with: #a
			    with: #b
			    with: #c
			    with: #d).
	self deny: col == res
    ]

    testCopyWithoutFirst [
	<category: 'testing-collection'>
	| col res |
	col := #(#a #b #a #c).
	res := col copyWithoutFirst: #a.
	self assert: res = #(#b #a #c).
	self deny: col == res.
	col := Set 
		    with: #a
		    with: #b
		    with: #c.
	res := col copyWithoutFirst: #a.
	self assert: res size = 2.
	self assert: (res includes: #b).
	self assert: (res includes: #c).
	self deny: col == res
    ]

    testFileSize [
	<category: 'testing-integer'>
	self assert: 1000 asFileSize = '1000 B'.
	self assert: 1024 asFileSize = '1 KB'.
	self assert: (1000 * 1000) asFileSize = '976 KB'.
	self assert: (1024 * 1024) asFileSize = '1 MB'.
	self assert: (1000 * 1000 * 1000) asFileSize = '953 MB'.
	self assert: (1024 * 1024 * 1024) asFileSize = '1 GB'.
	self assert: (1000 * 1000 * 1000 * 1000) asFileSize = '931 GB'.
	self assert: (1024 * 1024 * 1024 * 1024) asFileSize = '1 TB'

	"etc"
    ]

    testMatches [
	<category: 'testing-string'>
	self assert: ('' matches: '').
	self assert: ('zort' matches: '').
	self assert: ('zort' matches: 'o').
	self assert: ('zort' matches: 'O').
	self assert: ('zort' matches: '*').
	self assert: ('mobaz' matches: '*baz').
	self deny: ('mobazo' matches: '*baz').
	self assert: ('mobazo' matches: '*baz*').
	self deny: ('mozo' matches: '*baz*').
	self assert: ('foozo' matches: 'foo*').
	self deny: ('bozo' matches: 'foo*').
	self assert: ('foo23baz' matches: 'foo*baz').
	self assert: ('foobaz' matches: 'foo*baz').
	self deny: ('foo23bazo' matches: 'foo*baz').
	self assert: ('Foo' matches: 'foo').
	self deny: ('foobazort' matches: 'foo*baz*zort').
	self assert: ('foobazzort' matches: 'foo*baz*zort').
	self assert: ('afoo3zortthenfoo3zort' matches: '*foo#zort').
	self assert: ('afoodezortorfoo3zort' matches: '*foo*zort')
    ]

    testMoveDown [
	<category: 'testing-collection'>
	| col |
	col := Array 
		    with: 1
		    with: 2
		    with: 3.
	self assert: (col moveDown: 1) = 2.
	self assert: col = #(2 1 3).
	self assert: (col moveDown: 1) = 3.
	self assert: col = #(2 3 1).
	self assert: (col moveDown: 1) = 3.
	self assert: col = #(2 3 1).
	self assert: (col moveDown: 0) = 0.
	self assert: col = #(2 3 1)
    ]

    testMoveUp [
	<category: 'testing-collection'>
	| col |
	col := Array 
		    with: 1
		    with: 2
		    with: 3.
	self assert: (col moveUp: 3) = 2.
	self assert: col = #(1 3 2).
	self assert: (col moveUp: 3) = 1.
	self assert: col = #(3 1 2).
	self assert: (col moveUp: 3) = 1.
	self assert: col = #(3 1 2).
	self assert: (col moveUp: 0) = 0.
	self assert: col = #(3 1 2)
    ]

    testReduce [
	<category: 'testing-collection'>
	self assert: (#() reduce: [:a :b | a]) isNil.
	self assert: ((1 to: 9) reduce: [:a :b | a]) = 1.
	self assert: ((1 to: 9) reduce: [:a :b | b]) = 9.
	self assert: ((1 to: 9) reduce: [:a :b | a + b]) = 45.
	self assert: ((1 to: 9) reduce: [:a :b | a * b]) = 362880.
	self assert: (#('a' 'b' 'c') reduce: [:a :b | a , ' ' , b]) = 'a b c'.
	self assert: (#('a' 'b' 'c') reduce: [:a :b | b , ' ' , a]) = 'c b a'
    ]

    testValidationError [
	<category: 'testing-errors'>
	| result |
	result := [MARequiredError signal: 'some message'] on: MARequiredError
		    do: [:err | err displayString].
	self assert: result = 'some message'.
	result := 
		[MARequiredError description: ((MAStringDescription new)
			    label: 'label';
			    yourself)
		    signal: 'some message'] 
			on: MARequiredError
			do: [:err | err displayString].
	self assert: result = 'label: some message'
    ]
]



TestCase subclass: MAFileModelTest [
    | model |
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    MAFileModelTest class >> isAbstract [
	<category: 'testing'>
	^self name = #MAFileModelTest
    ]

    actualClass [
	<category: 'private'>
	^self subclassResponsibility
    ]

    setUp [
	<category: 'running'>
	super setUp.
	model := self actualClass new
    ]

    tearDown [
	<category: 'running'>
	model finalize
    ]

    testComparing [
	<category: 'testing'>
	| other |
	other := self actualClass new.
	other
	    filename: 'something.dat';
	    contents: (ByteArray 
			with: 1
			with: 2
			with: 3).
	self assert: model = model.
	self deny: model = other.
	self deny: other = model.
	other finalize	"should be in tearDown;  for now, at least let's discard when we pass"
    ]

    testContents [
	<category: 'testing'>
	self assert: model contents isEmpty.
	model contents: (ByteArray 
		    with: 1
		    with: 2
		    with: 3).
	self 
	    assert: model contents = (ByteArray 
			    with: 1
			    with: 2
			    with: 3).
	self assert: model filesize = 3
    ]

    testFilename [
	<category: 'testing'>
	self assert: model filename = 'unknown'.
	self assert: model extension isEmpty.
	model filename: 'test.txt'.
	self assert: model filename = 'test.txt'.
	self assert: model extension = 'txt'
    ]

    testIsEmpty [
	<category: 'testing'>
	self assert: model isEmpty.
	model filename: 'foo.txt'.
	self assert: model isEmpty.
	model mimetype: 'text/plain'.
	self assert: model isEmpty.
	model contents: 'hello'.
	self deny: model isEmpty
    ]

    testMimetype [
	<category: 'testing'>
	self assert: model mimetype = 'application/octet-stream'.
	self assert: model maintype = 'application'.
	self assert: model subtype = 'octet-stream'.
	model mimetype: 'text/html'.
	self assert: model mimetype = 'text/html'.
	self assert: model maintype = 'text'.
	self assert: model subtype = 'html'
    ]

    testMimetypeApplication [
	<category: 'testing'>
	model mimetype: 'application/pdf'.
	self assert: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeAudio [
	<category: 'testing'>
	model mimetype: 'audio/mpeg'.
	self deny: model isApplication.
	self assert: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeDefault [
	<category: 'testing'>
	self assert: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeImage [
	<category: 'testing'>
	model mimetype: 'image/png'.
	self deny: model isApplication.
	self deny: model isAudio.
	self assert: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeText [
	<category: 'testing'>
	model mimetype: 'text/xml'.
	self deny: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self assert: model isText.
	self deny: model isVideo
    ]

    testMimetypeVideo [
	<category: 'testing'>
	model mimetype: 'video/mpeg'.
	self deny: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self assert: model isVideo
    ]
]



MAFileModelTest subclass: MAExternalFileModelTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    actualClass [
	<category: 'private'>
	^MAExternalFileModel
    ]
]



MAFileModelTest subclass: MAMemoryFileModelTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    actualClass [
	<category: 'private'>
	^MAMemoryFileModel
    ]
]



TestCase subclass: MAObjectTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Core'>

    MAObjectTest class >> buildTestClassFor: aClass [
	"self buildTestClassFor: MAObject"

	<category: 'building'>
	| thisName thisClass thisCategory parentClass |
	thisName := (aClass name , 'Test') asSymbol.
	(thisName beginsWith: 'MA') ifFalse: [^self].
	thisClass := MACompatibility classNamed: thisName.
	thisCategory := 'Magritte-Tests-' , (aClass category copyAfterLast: $-).
	parentClass := self = thisClass 
		    ifTrue: [self superclass]
		    ifFalse: 
			[MACompatibility classNamed: (aClass superclass name , 'Test') asSymbol].
	thisClass := parentClass 
		    subclass: thisName
		    instanceVariableNames: (thisClass isNil 
			    ifFalse: [thisClass instanceVariablesString]
			    ifTrue: [String new])
		    classVariableNames: ''
		    poolDictionaries: ''
		    category: thisCategory.
	thisClass compile: 'actualClass
	^ ' , aClass name classified: #private.
	thisClass class compile: 'isAbstract
	^ ' , aClass isAbstract asString
	    classified: #testing.
	aClass subclassesDo: [:each | self buildTestClassFor: each]
    ]

    MAObjectTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MAObjectTest class >> shouldInheritSelectors [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAObject
    ]

    instance [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    testCopy [
	<category: 'testing-copying'>
	self assert: self instance = self instance copy.
	self deny: self instance == self instance copy
    ]

    testCopyProperties [
	<category: 'testing-copying'>
	self deny: self instance properties == self instance copy properties
    ]

    testEqual [
	<category: 'testing-comparing'>
	self assert: self instance = self instance.
	self assert: self instance = self instance copy.
	self assert: self instance copy = self instance.
	self deny: self instance = 123.
	self deny: self instance = String new
    ]

    testHash [
	<category: 'testing-comparing'>
	self assert: self instance hash isInteger.
	self assert: self instance hash = self instance hash.
	self assert: self instance hash = self instance copy hash
    ]

    testIsDescription [
	<category: 'testing-testing'>
	self deny: self instance isDescription
    ]

    testProperties [
	<category: 'testing-properties'>
	self assert: self instance properties notNil.
	self instance instVarNamed: 'properties' put: nil.
	self instance propertyAt: #foo put: #bar.
	self instance instVarNamed: 'properties' put: nil.
	self instance propertyAt: #foo ifAbsent: [nil].
	self instance instVarNamed: 'properties' put: nil.
	self instance propertyAt: #foo ifAbsentPut: [#bar].
	self instance instVarNamed: 'properties' put: nil.
	self instance hasProperty: #foo.
	self instance instVarNamed: 'properties' put: nil
    ]

    testPropertiesAt [
	<category: 'testing-properties'>
	self assert: (self instance propertyAt: #foo put: 'bar') = 'bar'.
	self assert: (self instance propertyAt: #foo) = 'bar'.
	self should: [self instance propertyAt: #bar] raise: MAPropertyError
    ]

    testPropertiesAtIfAbsent [
	<category: 'testing-properties'>
	self assert: (self instance propertyAt: #foo put: 'bar') = 'bar'.
	self assert: (self instance propertyAt: #foo ifAbsent: ['baz']) = 'bar'.
	self assert: (self instance propertyAt: #bar ifAbsent: ['baz']) = 'baz'
    ]

    testPropertiesAtIfAbsentPut [
	<category: 'testing-properties'>
	self assert: (self instance propertyAt: #foo put: 'bar') = 'bar'.
	self assert: (self instance propertyAt: #foo ifAbsentPut: ['baz']) = 'bar'.
	self assert: (self instance propertyAt: #foo) = 'bar'.
	self assert: (self instance propertyAt: #bar ifAbsentPut: ['baz']) = 'baz'.
	self assert: (self instance propertyAt: #bar) = 'baz'
    ]

    testPropertiesAtIfPresent [
	<category: 'testing-properties'>
	self 
	    assert: (self instance propertyAt: #foo
		    ifPresent: [:value | self assert: false]) isNil.
	self instance propertyAt: #foo put: 1.
	self 
	    assert: (self instance propertyAt: #foo
		    ifPresent: 
			[:value | 
			self assert: value = 1.
			2]) = 2
    ]

    testPropertiesAtPut [
	<category: 'testing-properties'>
	self instance propertyAt: #foo put: 'bar'.
	self assert: (self instance propertyAt: #foo) = 'bar'.
	self instance propertyAt: #foo put: 'baz'.
	self assert: (self instance propertyAt: #foo) = 'baz'
    ]

    testPropertiesHas [
	<category: 'testing-properties'>
	self deny: (self instance hasProperty: #foo).
	self instance propertyAt: #foo put: 'bar'.
	self assert: (self instance hasProperty: #foo).
	self deny: (self instance hasProperty: #bar)
    ]

    testSanity [
	"If this test case fails, there is something wrong with the setup of the test-case."

	<category: 'testing'>
	self assert: self actualClass isAbstract not
	    description: 'Unable to test abstract class.'.
	self assert: self instance class = self actualClass
	    description: 'Invalid test instance.'
    ]
]



MAObjectTest subclass: MAAccessorTest [
    | accessor value |
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAAccessorTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    accessor [
	<category: 'accessing'>
	^accessor
    ]

    accessorInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    actualClass [
	<category: 'private'>
	^MAAccessor
    ]

    instance [
	<category: 'accessing'>
	^accessor
    ]

    setUp [
	<category: 'running'>
	super setUp.
	accessor := self accessorInstance
    ]

    testAsAccessor [
	<category: 'testing-identity'>
	self assert: self instance asAccessor = self instance.
	self assert: self instance asAccessor == self instance
    ]

    testCanRead [
	<category: 'testing-testing'>
	self subclassResponsibility
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self subclassResponsibility
    ]

    testRead [
	<category: 'testing'>
	self subclassResponsibility
    ]

    testStore [
	<category: 'testing-identity'>
	self 
	    assert: (Behavior
		    evaluate: self accessor storeString) = self accessor
    ]

    testWrite [
	<category: 'testing'>
	self subclassResponsibility
    ]

    value [
	<category: 'accessing-model'>
	^value
    ]

    value: anObject [
	<category: 'accessing-model'>
	value := anObject
    ]
]



MAAccessorTest subclass: MADelegatorAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MADelegatorAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass on: (MASelectorAccessor selector: #value)
    ]

    actualClass [
	<category: 'private'>
	^MADelegatorAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor next readSelector: #zork.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor next writeSelector: #zork:.
	self deny: (self accessor canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '123'.
	self assert: (self accessor read: self) = '123'
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MADelegatorAccessorTest subclass: MAChainAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAChainAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass accessors: #(#holder #contents #value)
    ]

    actualClass [
	<category: 'private'>
	^MAChainAccessor
    ]

    holder [
	<category: 'private'>
	^(ValueHolder new)
	    contents: self;
	    yourself
    ]

    testAccessor [
	<category: 'testing'>
	self accessor accessor: self.
	self assert: self accessor accessor = self
    ]

    testAsAccessor [
	<category: 'testing'>
	super testAsAccessor.
	accessor := #(#value) asAccessor.
	self assert: (accessor isKindOf: MASelectorAccessor).
	self assert: accessor selector = #value.
	accessor := #(#value #contents) asAccessor.
	self assert: (accessor isKindOf: MAChainAccessor).
	self assert: (accessor next isKindOf: MASelectorAccessor).
	self assert: accessor next selector = #value.
	self assert: (accessor accessor isKindOf: MASelectorAccessor).
	self assert: accessor accessor selector = #contents
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor accessor accessor readSelector: #zork.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor accessor accessor writeSelector: #zork.
	self deny: (self accessor canWrite: self)
    ]

    testKind [
	<category: 'testing'>
	self assert: self accessor class = MAChainAccessor.
	self assert: self accessor next class = MASelectorAccessor.
	self assert: self accessor accessor class = MAChainAccessor.
	self assert: self accessor accessor next class = MASelectorAccessor.
	self assert: self accessor accessor accessor class = MASelectorAccessor
    ]

    testNext [
	<category: 'testing'>
	| next |
	next := #foo asAccessor.
	self accessor next: next.
	self assert: self accessor next = next
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testSelector [
	<category: 'testing'>
	self assert: self accessor next selector = #holder.
	self assert: self accessor accessor next selector = #contents.
	self assert: self accessor accessor accessor selector = #value
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MAAccessorTest subclass: MADictionaryAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MADictionaryAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass key: #value
    ]

    actualClass [
	<category: 'private'>
	^MADictionaryAccessor
    ]

    at: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	^aKey = #value ifTrue: [value] ifFalse: [aBlock value]
    ]

    at: aKey put: aValue [
	<category: 'accessing'>
	self assert: aKey = #value.
	^value := aValue
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor key: #zork.
	self assert: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self)
    ]

    testKey [
	<category: 'testing'>
	self accessor key: #other.
	self assert: self accessor key = #other
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MAAccessorTest subclass: MAIdentityAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAIdentityAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass new
    ]

    actualClass [
	<category: 'private'>
	^MAIdentityAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self deny: (self accessor canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self assert: (self accessor read: 123) = 123
    ]

    testWrite [
	<category: 'testing'>
	self should: [self accessor write: 123 to: self] raise: MAWriteError.
	self assert: self value isNil
    ]
]



MAAccessorTest subclass: MANullAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MANullAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass new
    ]

    actualClass [
	<category: 'private'>
	^MANullAccessor
    ]

    testAsAccessor [
	<category: 'testing-identity'>
	super testAsAccessor.
	self assert: (nil asAccessor isKindOf: self actualClass)
    ]

    testCanRead [
	<category: 'testing-testing'>
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self deny: (self accessor canWrite: nil)
    ]

    testRead [
	<category: 'testing'>
	self should: [self accessor read: self] raise: MAReadError
    ]

    testWrite [
	<category: 'testing'>
	self should: [self accessor write: 123 to: self] raise: MAWriteError.
	self assert: self value isNil
    ]
]



MAAccessorTest subclass: MAPluggableAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAPluggableAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass read: [:model | model value]
	    write: [:model :object | model value: object]
    ]

    actualClass [
	<category: 'private'>
	^MAPluggableAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self instance canRead: self).
	self instance readBlock: nil.
	self deny: (self instance canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self instance canWrite: nil).
	self assert: (self instance canWrite: 123).
	self assert: (self instance canWrite: self).
	self instance writeBlock: nil.
	self deny: (self instance canWrite: nil).
	self deny: (self instance canWrite: 123).
	self deny: (self instance canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testReadBlock [
	<category: 'testing'>
	self accessor readBlock: 
		[:model | 
		self assert: model = self.
		123].
	self assert: (self accessor read: self) = 123
    ]

    testStore [
	"The class BlockContext is not serializeable, ignore this test."

	<category: 'testing-identity'>
	
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]

    testWriteBlock [
	<category: 'testing'>
	self accessor writeBlock: 
		[:model :object | 
		self assert: model = self.
		self assert: object = 123].
	self accessor write: 123 to: self
    ]
]



MAAccessorTest subclass: MASelectorAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MASelectorAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass selector: #value
    ]

    actualClass [
	<category: 'private'>
	^MASelectorAccessor
    ]

    testAsAccessor [
	<category: 'testing-identity'>
	super testAsAccessor.
	self assert: #value asAccessor = self instance.
	self deny: #value asAccessor == self instance
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor readSelector: #zork.
	self deny: (self accessor canRead: self).
	self accessor readSelector: nil.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor writeSelector: #zork:.
	self deny: (self accessor canWrite: self).
	self accessor writeSelector: nil.
	self deny: (self accessor canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testReadSelector [
	<category: 'testing'>
	self accessor readSelector: #contents.
	self assert: self accessor selector = #contents.
	self assert: self accessor readSelector = #contents.
	self assert: self accessor writeSelector = #value:
    ]

    testSelector [
	<category: 'testing'>
	self accessor selector: #contents.
	self assert: self accessor selector = #contents.
	self assert: self accessor readSelector = #contents.
	self assert: self accessor writeSelector = #contents:
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]

    testWriteSelector [
	<category: 'testing'>
	self accessor writeSelector: #contents:.
	self assert: self accessor selector = #value.
	self assert: self accessor readSelector = #value.
	self assert: self accessor writeSelector = #contents:
    ]
]



MASelectorAccessorTest subclass: MAAutoSelectorAccessorTest [
    | mock foo |
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAAutoSelectorAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAAutoSelectorAccessor
    ]

    foo: anObject [
	<category: 'accessing-generated'>
	foo := anObject
    ]

    mock [
	<category: 'accessing'>
	^mock
    ]

    mockInstance [
	<category: 'private'>
	^MAAccessorMock new
    ]

    runCase [
	<category: 'running'>
	mock := self mockInstance.
	super runCase
    ]

    tearDown [
	<category: 'running'>
	super tearDown.

	"remove methods and category"
	(self mock class selectors
	    select: [ :each | (self mock class >> each) methodCategory = self accessor categoryName ])
		do: [:each | self mock class removeSelector: each].

	"remove instance variables"
	self mock class instVarNames 
	    do: [:each | self mock class removeInstVarName: each]
    ]

    testAsAccessor [
	"noop"

	<category: 'testing-identity'>
	
    ]

    testReadFirst [
	<category: 'testing'>
	self accessor selector: #foo.
	self assert: (self accessor read: self mock) isNil.
	self accessor write: 123 to: self mock.
	self assert: (self accessor read: self mock) = 123
    ]

    testWriteFirst [
	<category: 'testing'>
	self accessor selector: #foo.
	self accessor write: 123 to: self mock.
	self assert: (self accessor read: self mock) = 123
    ]
]



MAAccessorTest subclass: MAVariableAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAVariableAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass name: 'value'
    ]

    actualClass [
	<category: 'private'>
	^MAVariableAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor name: 'zork'.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor name: 'zork'.
	self deny: (self accessor canWrite: self)
    ]

    testName [
	<category: 'testing'>
	self accessor name: 'other'.
	self assert: self accessor name = 'other'
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MAObjectTest subclass: MADescriptionTest [
    | description |
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MADescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MADescriptionTest class >> shouldInheritSelectors [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MADescription
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    descriptionInstance [
	<category: 'private'>
	^(self actualClass new)
	    accessor: MANullAccessor new;
	    yourself
    ]

    instance [
	<category: 'accessing'>
	^description
    ]

    setUp [
	<category: 'running'>
	super setUp.
	description := self descriptionInstance.
	self assert: description accessor notNil
    ]

    testAccessor [
	<category: 'testing-accessing'>
	self description accessor: (MASelectorAccessor selector: #foo).
	self assert: self description accessor selector = #foo
    ]

    testAsContainer [
	<category: 'testing-converting'>
	self subclassResponsibility
    ]

    testComment [
	<category: 'testing-accessing'>
	self description comment: 'bar'.
	self assert: self description comment = 'bar'
    ]

    testCopyAccessor [
	<category: 'testing-copying'>
	self assert: self description copy accessor = self description accessor.
	self deny: self description copy accessor == self description accessor
    ]

    testDictionaryKey [
	<category: 'testing-identity'>
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: self instance put: 1.
	self assert: (dictionary at: self instance) = 1.
	dictionary at: self instance put: 2.
	self assert: (dictionary at: self instance) = 2
    ]

    testGroup [
	<category: 'testing-accessing'>
	self assert: self description group isNil.
	self description group: 'foo'.
	self assert: self description group = 'foo'
    ]

    testHasChildren [
	<category: 'testing-testing'>
	self deny: self description hasChildren
    ]

    testHasComment [
	<category: 'testing-testing'>
	self description comment: nil.
	self deny: self description hasComment.
	self description comment: ''.
	self deny: self description hasComment.
	self description comment: 'comment'.
	self assert: self description hasComment
    ]

    testHasLabel [
	<category: 'testing-testing'>
	self description label: nil.
	self deny: self description hasLabel.
	self description label: ''.
	self deny: self description hasLabel.
	self description label: 'label'.
	self assert: self description hasLabel
    ]

    testIsContainer [
	<category: 'testing-testing'>
	self deny: self description isContainer
    ]

    testIsDescription [
	<category: 'testing-testing'>
	self assert: self description isDescription
    ]

    testLabel [
	<category: 'testing-accessing'>
	self description label: 'foo'.
	self assert: self description label = 'foo'
    ]

    testPriority [
	<category: 'testing-accessing'>
	self description priority: 123.
	self assert: self description priority = 123
    ]

    testReadonly [
	<category: 'testing-actions'>
	self description beReadonly.
	self assert: self description readonly.
	self assert: self description isReadonly.
	self description beWriteable.
	self deny: self description readonly.
	self deny: self description isReadonly
    ]

    testRequired [
	<category: 'testing-actions'>
	self description beRequired.
	self assert: self description required.
	self assert: self description isRequired.
	self description beOptional.
	self deny: self description required.
	self deny: self description isRequired
    ]

    testSetElement [
	<category: 'testing-identity'>
	| set |
	set := Set new.
	set add: self instance.
	self assert: set size = 1.
	self assert: (set includes: self instance).
	set add: self instance.
	self assert: set size = 1.
	self assert: (set includes: self instance)
    ]

    testVisible [
	<category: 'testing-actions'>
	self description beHidden.
	self deny: self description visible.
	self deny: self description isVisible.
	self description beVisible.
	self assert: self description visible.
	self assert: self description isVisible
    ]
]



MADescriptionTest subclass: MAContainerTest [
    | child1 child2 child3 |
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAContainerTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAContainer
    ]

    child1 [
	<category: 'accessing'>
	^child1 ifNil: 
		[child1 := (MAStringDescription new)
			    accessor: #child1;
			    label: 'child1';
			    priority: 1;
			    yourself]
    ]

    child2 [
	<category: 'accessing'>
	^child2 ifNil: 
		[child2 := (MAStringDescription new)
			    accessor: #child2;
			    label: 'child2';
			    priority: 2;
			    yourself]
    ]

    child3 [
	<category: 'accessing'>
	^child3 ifNil: 
		[child3 := (MAStringDescription new)
			    accessor: #child3;
			    label: 'child3';
			    priority: 3;
			    yourself]
    ]

    exampleInstance [
	<category: 'private'>
	^(MACachedMemento new)
	    setDescription: self description;
	    setCache: ((Dictionary new)
			at: self child1 put: nil;
			at: self child2 put: nil;
			at: self child3 put: nil;
			yourself);
	    yourself
    ]

    testAdd [
	<category: 'testing-adding'>
	self description add: self child1.
	self assert: self description size = 1.
	self assert: (self description includes: self child1).
	self description add: self child2.
	self assert: self description size = 2.
	self assert: (self description includes: self child1).
	self assert: (self description includes: self child2)
    ]

    testAddAll [
	<category: 'testing-adding'>
	self description addAll: (Array with: self child1 with: self child2).
	self assert: self description size = 2.
	self assert: (self description includes: self child1).
	self assert: (self description includes: self child2)
    ]

    testAsContainer [
	<category: 'testing-converting'>
	self assert: self description asContainer = self description.
	self assert: self description asContainer == self description
    ]

    testChildren [
	<category: 'testing-accessing'>
	self assert: self description children isCollection.
	self assert: self description children isEmpty
    ]

    testCollect [
	<category: 'testing-enumerating'>
	| collected |
	(self description)
	    add: self child1;
	    add: self child2.
	collected := self description collect: [:each | each].
	self assert: self description = collected.
	self deny: self description == collected.
	collected := self description collect: [:each | each copy].
	self assert: self description = collected.
	self deny: self description == collected.
	collected := self description collect: 
			[:each | 
			(each copy)
			    accessor: (MASelectorAccessor selector: #foo);
			    yourself].
	self deny: self description = collected.
	self deny: self description == collected
    ]

    testConcatenate [
	<category: 'testing-operators'>
	| concatenate |
	concatenate := self child1 , self child2.
	self assert: concatenate size = 2.
	self assert: concatenate children first = self child1.
	self assert: concatenate children second = self child2.
	concatenate := self child1 , self child2 , self child3.
	self assert: concatenate size = 3.
	self assert: concatenate children first = self child1.
	self assert: concatenate children second = self child2.
	self assert: concatenate children third = self child3
    ]

    testCopy [
	<category: 'testing-copying'>
	(self description)
	    add: self child1;
	    add: self child2.
	super testCopy.
	self deny: self description copy children == self description children.
	self assert: self description copy children first 
		    = self description children first.
	self assert: self description copy children second 
		    = self description children second
    ]

    testCopyEmpty [
	<category: 'testing-copying'>
	(self description)
	    add: self child1;
	    add: self child2.
	self assert: self description copyEmpty isEmpty
    ]

    testCopyFromTo [
	<category: 'testing-copying'>
	| copied |
	(self description)
	    add: self child1;
	    add: self child2;
	    add: self child3.
	copied := self description copyFrom: 2 to: 3.
	self assert: copied ~= self description.
	self assert: copied size = 2.
	self assert: copied children first = self child2.
	self assert: copied children second = self child3
    ]

    testDetect [
	<category: 'testing-enumerating'>
	self description add: self child1.
	self assert: (self description detect: [:each | self child1 = each]) 
		    = self child1.
	self should: [self description detect: [:each | self child2 = each]]
	    raise: Error
    ]

    testDetectIfNone [
	<category: 'testing-enumerating'>
	self description add: self child1.
	self 
	    assert: (self description detect: [:each | self child1 = each] ifNone: [123]) 
		    = self child1.
	self 
	    assert: (self description detect: [:each | self child2 = each] ifNone: [123]) 
		    = 123
    ]

    testDo [
	<category: 'testing-enumerating'>
	| collection |
	collection := self description class defaultCollection.
	(self description)
	    add: self child1;
	    add: self child2.
	self description do: [:each | collection add: each].
	self assert: (self description children hasEqualElements: collection)
    ]

    testDoSepratedBy [
	<category: 'testing-enumerating'>
	| collection |
	collection := OrderedCollection new.
	(self description)
	    add: self child1;
	    add: self child2.
	self description do: [:each | collection add: each]
	    separatedBy: [collection add: nil].
	self assert: collection size = 3.
	self assert: collection first = self child1.
	self assert: collection second isNil.
	self assert: collection third = self child2
    ]

    testEmpty [
	<category: 'testing-testing'>
	self assert: self description isEmpty.
	self description add: self child1.
	self deny: self description isEmpty
    ]

    testHasChildren [
	<category: 'testing-testing'>
	super testHasChildren.
	self description add: self child1.
	self assert: self description hasChildren
    ]

    testIncludes [
	<category: 'testing-testing'>
	self deny: (self description includes: self child1).
	self description add: self child1.
	self assert: (self description includes: self child1)
    ]

    testInjectInto [
	<category: 'testing-enumerating'>
	(self description)
	    add: self child1;
	    add: self child2.
	self 
	    assert: (self description inject: 'start'
		    into: [:result :each | result , ' ' , each label]) = 'start child1 child2'
    ]

    testIntersection [
	<category: 'testing-operators'>
	| a b union |
	a := self child1 , self child2.
	b := self child2 , self child3.
	union := a intersection: b.
	self assert: union size = 1.
	self deny: (union includes: self child1).
	self assert: (union includes: self child2).
	self deny: (union includes: self child3)
    ]

    testIsContainer [
	<category: 'testing-testing'>
	self assert: self description isContainer
    ]

    testKeysAndValuesDo [
	<category: 'testing-enumerating'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description keysAndValuesDo: 
		[:index :each | 
		index = 1 
		    ifTrue: [self assert: self child1 = each]
		    ifFalse: 
			[index = 2 
			    ifTrue: [self assert: self child2 = each]
			    ifFalse: [self assert: false]]]
    ]

    testMoveDown [
	<category: 'testing-moving'>
	(self description)
	    add: self child1;
	    add: self child2.
	self assert: self description children first = self child1.
	self assert: self description children second = self child2.
	self description moveDown: self child1.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1.
	self description moveDown: self child1.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1
    ]

    testMoveUp [
	<category: 'testing-moving'>
	(self description)
	    add: self child1;
	    add: self child2.
	self assert: self description children first = self child1.
	self assert: self description children second = self child2.
	self description moveUp: self child2.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1.
	self description moveUp: self child2.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1
    ]

    testNoFailingValidation [
	<category: 'testing-validating'>
	| example |
	(self description)
	    add: self child1;
	    add: self child2.
	example := self exampleInstance.
	self shouldnt: [example validate] raise: MAValidationError
    ]

    testNotEmpty [
	<category: 'testing-testing'>
	self deny: self description notEmpty.
	self description add: self child1.
	self assert: self description notEmpty
    ]

    testOneFailingValidation [
	<category: 'testing-validating'>
	| example |
	(self description)
	    add: self child1;
	    add: ((self child2)
			addCondition: [:v | self fail];
			beRequired;
			yourself).
	example := self exampleInstance.
	self should: [example validate] raise: MAValidationError.
	[example validate] on: MAValidationError
	    do: 
		[:err | 
		self assert: err class = MARequiredError.
		self assert: err tag = self child2.
		self assert: err isResumable.
		err resume]
    ]

    testReject [
	<category: 'testing-enumerating'>
	| rejected |
	(self description)
	    add: self child1;
	    add: self child2.
	rejected := self description reject: [:each | false].
	self assert: self description = rejected.
	rejected := self description reject: [:each | true].
	self assert: rejected isEmpty
    ]

    testRemove [
	<category: 'testing-removing'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description remove: self child1.
	self assert: self description size = 1.
	self deny: (self description includes: self child1).
	self assert: (self description includes: self child2).
	self description remove: self child2.
	self assert: self description isEmpty
    ]

    testRemoveAll [
	<category: 'testing-removing'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description removeAll.
	self assert: self description isEmpty
    ]

    testSelect [
	<category: 'testing-enumerating'>
	| selected |
	(self description)
	    add: self child1;
	    add: self child2.
	selected := self description select: [:each | true].
	self assert: self description = selected.
	selected := self description select: [:each | false].
	self assert: selected isEmpty
    ]

    testSize [
	<category: 'testing-accessing'>
	self assert: self description size = 0.
	self description add: self child1.
	self assert: self description size = 1.
	self description add: self child2.
	self assert: self description size = 2.
	self description add: self child3.
	self assert: self description size = 3
    ]

    testTwoFailingValidation [
	<category: 'testing-validating'>
	| example step |
	(self description)
	    add: ((self child1)
			addCondition: [:v | self fail];
			beRequired;
			yourself);
	    add: ((self child2)
			addCondition: [:v | self fail];
			beRequired;
			yourself).
	example := self exampleInstance.
	step := 1.
	self should: [example validate] raise: MAValidationError.
	[example validate] on: MAValidationError
	    do: 
		[:err | 
		self assert: err class = MARequiredError.
		self assert: err isResumable.
		step = 1 ifTrue: [self assert: err tag = self child1].
		step = 2 ifTrue: [self assert: err tag = self child2].
		step = 3 ifTrue: [self fail].
		step := step + 1.
		err resume]
    ]

    testUnion [
	<category: 'testing-operators'>
	| a b union |
	a := self child1 , self child2.
	b := self child2 , self child3.
	union := a union: b.
	self assert: union size = 3.
	self assert: (union includes: self child1).
	self assert: (union includes: self child2).
	self assert: (union includes: self child3)
    ]

    testWithDo [
	<category: 'testing-enumerating'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description with: self description children
	    do: [:first :second | self assert: first = second]
    ]
]



MAContainerTest subclass: MAPriorityContainerTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAPriorityContainerTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAPriorityContainer
    ]

    testMoveDown [
	<category: 'testing-moving'>
	self should: [super testMoveDown] raise: Error
    ]

    testMoveUp [
	<category: 'testing-moving'>
	self should: [super testMoveUp] raise: Error
    ]
]



MADescriptionTest subclass: MAElementDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAElementDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAElementDescription
    ]

    emptyInstance [
	<category: 'private'>
	^String new
    ]

    includedInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    includedInstanceString [
	<category: 'private'>
	^MAStringWriter write: self includedInstance
	    description: self descriptionInstance
    ]

    invalidInstance [
	<category: 'private'>
	^Object new
    ]

    invalidInstanceString [
	<category: 'private'>
	^self invalidInstance asString
    ]

    nullInstance [
	<category: 'private'>
	^nil
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^false
    ]

    testAddCondition [
	<category: 'testing-validation'>
	self description addCondition: [:value | value isNil].
	self assert: self description conditions size = 1.
	self assert: self description conditions first value isString
    ]

    testAddConditionLabelled [
	<category: 'testing-validation'>
	self description addCondition: [:value | value isNil]
	    labelled: 'ist net nil'.
	self assert: self description conditions size = 1.
	self assert: self description conditions first value = 'ist net nil'
    ]

    testAsContainer [
	<category: 'testing-converting'>
	self assert: self description asContainer size = 1.
	self assert: (self description asContainer includes: self description)
    ]

    testConcatenation [
	<category: 'testing-operators'>
	| child1 child2 concatenate |
	child1 := self description copy.
	child2 := self description copy.
	concatenate := child1 , child2.
	self assert: concatenate size = 2.
	self assert: concatenate children first = child1.
	self assert: concatenate children second = child2.
	concatenate := child1 , concatenate.
	self assert: concatenate size = 3.
	self assert: concatenate children first = child1.
	self assert: concatenate children second = child1.
	self assert: concatenate children third = child2
    ]

    testCopy [
	<category: 'testing-copying'>
	super testCopy.
	self assert: self description copy default = self description default
    ]

    testDefault [
	<category: 'testing-accessing'>
	self description default: self includedInstance.
	self assert: self description default = self includedInstance
    ]

    testFromString [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description fromString: self includedInstanceString) 
		    = self includedInstance.
	self 
	    assert: (self description fromString: self includedInstanceString
		    reader: self description stringReader) = self includedInstance.
	self 
	    assert: (self description fromString: self includedInstanceString
		    reader: self description stringReader new) = self includedInstance
    ]

    testFromStringCollection [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self 
	    assert: (self description 
		    fromStringCollection: (Array with: self includedInstanceString
			    with: self includedInstanceString)) 
			= (Array with: self includedInstance with: self includedInstance).
	self 
	    assert: (self description 
		    fromStringCollection: (Array with: self includedInstanceString
			    with: self includedInstanceString)
		    reader: self description stringReader) 
			= (Array with: self includedInstance with: self includedInstance)
    ]

    testFromStringEvaluated [
	"This ensures that the parsing algorithm doesn't compile the input, what would cause a  security hole in the framework."

	<category: 'testing-strings'>
	| error |
	error := nil.
	self shouldSkipStringTests ifTrue: [^self].
	[self description fromString: '1 / 0. nil'] on: Exception
	    do: [:err | error := err].
	self deny: (error isKindOf: ZeroDivide)
    ]

    testFromStringInvalid [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self should: [self description fromString: self invalidInstanceString]
	    raise: MAReadError
    ]

    testFromStringNull [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description fromString: self emptyInstance) isNil.
	self 
	    assert: (self description fromString: self emptyInstance
		    reader: self description stringReader) isNil.
	self 
	    assert: (self description fromString: self emptyInstance
		    reader: self description stringReader new) isNil
    ]

    testKind [
	<category: 'testing-accessing'>
	self assert: (self includedInstance isKindOf: self description kind)
    ]

    testKindErrorMessage [
	<category: 'testing-validation'>
	self assert: self description kindErrorMessage notEmpty.
	self description kindErrorMessage: 'zork'.
	self assert: self description kindErrorMessage = 'zork'.
	[self description validateKind: self invalidInstance] on: MAKindError
	    do: [:err | self assert: self description kindErrorMessage = err messageText]
    ]

    testRequiredErrorMessage [
	<category: 'testing-validation'>
	self assert: self description requiredErrorMessage notEmpty.
	self description requiredErrorMessage: 'zork'.
	self assert: self description requiredErrorMessage = 'zork'.
	
	[(self description)
	    beRequired;
	    validateRequired: self nullInstance] 
		on: MARequiredError
		do: [:err | self assert: self description requiredErrorMessage = err messageText]
    ]

    testSatisfied [
	<category: 'testing-testing'>
	self assert: (self description isSatisfiedBy: self includedInstance).
	self assert: (self description isSatisfiedBy: self nullInstance).
	self deny: (self description isSatisfiedBy: self invalidInstance)
    ]

    testStringReader [
	<category: 'testing-accessing'>
	| object |
	self description stringReader: (object := MAStringReader new).
	self assert: self description stringReader = object
    ]

    testStringWriter [
	<category: 'testing-accessing'>
	| object |
	self description stringWriter: (object := MAStringWriter new).
	self assert: self description stringWriter = object
    ]

    testToString [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description toString: self includedInstance) 
		    = self includedInstanceString.
	self 
	    assert: (self description toString: self includedInstance
		    writer: self description stringWriter) = self includedInstanceString.
	self 
	    assert: (self description toString: self includedInstance
		    writer: self description stringWriter new) = self includedInstanceString
    ]

    testToStringCollection [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self 
	    assert: (self description 
		    toStringCollection: (Array with: self includedInstance
			    with: self includedInstance)) 
			= (Array with: self includedInstanceString with: self includedInstanceString).
	self 
	    assert: (self description 
		    toStringCollection: (Array with: self includedInstance
			    with: self includedInstance)
		    writer: self description stringWriter) 
			= (Array with: self includedInstanceString with: self includedInstanceString)
    ]

    testToStringFromString [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self 
	    assert: (self description 
		    fromString: (self description toString: self includedInstance)) 
			= self includedInstance.
	self 
	    assert: (self description 
		    fromString: (self description toString: self includedInstance
			    writer: self description stringWriter)
		    reader: self description stringReader) = self includedInstance.
	self 
	    assert: (self description 
		    fromString: (self description toString: self includedInstance
			    writer: self description stringWriter new)
		    reader: self description stringReader new) = self includedInstance
    ]

    testToStringNull [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description toString: self nullInstance) 
		    = self description undefined.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter) = self description undefined.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter new) = self description undefined
    ]

    testToStringUndefined [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self description undefined: 'n/a'.
	self assert: (self description toString: self nullInstance) = 'n/a'.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter) = 'n/a'.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter new) = 'n/a'
    ]

    testUndefined [
	<category: 'testing-accessing'>
	self description undefined: 'nop'.
	self assert: self description undefined = 'nop'
    ]

    testValidate [
	<category: 'testing-validation'>
	self description beRequired.
	self shouldnt: [self description validate: self includedInstance]
	    raise: MAValidationError.
	self should: [self description validate: self invalidInstance]
	    raise: MAKindError.
	self should: [self description validate: self nullInstance]
	    raise: MARequiredError
    ]

    testValidateConditions [
	"This test might fail for MADateDescriptionTest, since there is a bug in Squeak."

	<category: 'testing-validation'>
	| object |
	object := self includedInstance.
	self description addCondition: [:value | object == value]
	    labelled: 'included instance test'.
	self shouldnt: [self description validate: object] raise: MAConditionError.
	self should: [self description validate: object copy]
	    raise: MAConditionError
    ]

    testValidateKind [
	<category: 'testing-validation'>
	self should: [self description validateKind: self invalidInstance]
	    raise: MAKindError.
	self shouldnt: [self description validateKind: self includedInstance]
	    raise: MAKindError
    ]

    testValidateRequired [
	<category: 'testing-validation'>
	self description beOptional.
	self shouldnt: [self description validateRequired: self nullInstance]
	    raise: MARequiredError.
	self shouldnt: [self description validateRequired: self includedInstance]
	    raise: MARequiredError.
	self description beRequired.
	self should: [self description validateRequired: self nullInstance]
	    raise: MARequiredError.
	self shouldnt: [self description validateRequired: self includedInstance]
	    raise: MARequiredError
    ]

    testValidateSpecific [
	<category: 'testing-validation'>
	self shouldnt: [self description validate: self includedInstance]
	    raise: MARequiredError
    ]
]



MAElementDescriptionTest subclass: MABooleanDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MABooleanDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MABooleanDescription
    ]

    includedInstance [
	<category: 'private'>
	^true
    ]

    testValidateConditions [
	<category: 'testing-validation'>
	
    ]
]



MAElementDescriptionTest subclass: MAClassDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAClassDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAClassDescription
    ]

    includedInstance [
	<category: 'private'>
	^String
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]
]



MAElementDescriptionTest subclass: MAFileDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAFileDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAFileDescription
    ]

    includedInstance [
	<category: 'private'>
	^(MAMemoryFileModel new)
	    contents: 'Lukas Renggli';
	    filename: 'author.txt';
	    yourself
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]
]



MAElementDescriptionTest subclass: MAMagnitudeDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAMagnitudeDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAMagnitudeDescription
    ]

    excludedInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    maxInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    minInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    testInfToInf [
	<category: 'testing'>
	self assert: self description min isNil.
	self assert: self description max isNil.
	self assert: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self assert: (self description isSatisfiedBy: self maxInstance)
    ]

    testInfToVal [
	<category: 'testing'>
	self description max: self includedInstance.
	self assert: self description min isNil.
	self assert: self description max = self includedInstance.
	self assert: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self deny: (self description isSatisfiedBy: self maxInstance)
    ]

    testMax [
	<category: 'testing-accessing'>
	self description max: self maxInstance.
	self assert: self description max = self maxInstance
    ]

    testMin [
	<category: 'testing-accessing'>
	self description min: self minInstance.
	self assert: self description min = self minInstance
    ]

    testMinMax [
	<category: 'testing-accessing'>
	self description min: self minInstance max: self maxInstance.
	self assert: self description min = self minInstance.
	self assert: self description max = self maxInstance
    ]

    testRangeErrorMessage [
	<category: 'testing-validation'>
	(self description)
	    min: self minInstance;
	    max: self maxInstance.
	self assert: self description rangeErrorMessage notEmpty.
	self description rangeErrorMessage: 'zork'.
	self assert: self description rangeErrorMessage = 'zork'.
	[self description validate: self excludedInstance] on: MARangeError
	    do: [:err | self assert: self description rangeErrorMessage = err messageText]
    ]

    testRangeErrorMessageGenerated [
	<category: 'testing-validation'>
	self description min: nil max: nil.
	self assert: self description rangeErrorMessage isNil.
	self description min: nil max: self maxInstance.
	self assert: self description rangeErrorMessage notEmpty.
	self description min: self minInstance max: nil.
	self assert: self description rangeErrorMessage notEmpty.
	self description min: self minInstance max: self maxInstance.
	self assert: self description rangeErrorMessage notEmpty
    ]

    testValToInf [
	<category: 'testing'>
	self description min: self includedInstance.
	self assert: self description min = self includedInstance.
	self assert: self description max isNil.
	self deny: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self assert: (self description isSatisfiedBy: self maxInstance)
    ]

    testValToVal [
	<category: 'testing'>
	self description min: self includedInstance.
	self description max: self includedInstance.
	self assert: self description min = self includedInstance.
	self assert: self description max = self includedInstance.
	self deny: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self deny: (self description isSatisfiedBy: self maxInstance)
    ]

    testValidateSpecific [
	<category: 'testing-validation'>
	super testValidateSpecific.
	(self description)
	    min: self minInstance;
	    max: self maxInstance.
	self shouldnt: [self description validate: self includedInstance]
	    raise: MARangeError.
	self should: [self description validate: self excludedInstance]
	    raise: MARangeError
    ]
]



MAMagnitudeDescriptionTest subclass: MADateDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MADateDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MADateDescription
    ]

    excludedInstance [
	<category: 'private'>
	^Date 
	    newDay: 1
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]

    includedInstance [
	<category: 'private'>
	^Date 
	    newDay: 11
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]

    maxInstance [
	<category: 'private'>
	^Date 
	    newDay: 12
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]

    minInstance [
	<category: 'private'>
	^Date 
	    newDay: 10
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]
]



MAMagnitudeDescriptionTest subclass: MADurationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MADurationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MADurationDescription
    ]

    excludedInstance [
	<category: 'private'>
	^Duration 
	    days: 0
	    hours: 0
	    minutes: 0
	    seconds: 2
    ]

    includedInstance [
	<category: 'private'>
	^Duration 
	    days: 1
	    hours: 2
	    minutes: 3
	    seconds: 4
    ]

    maxInstance [
	<category: 'private'>
	^Duration 
	    days: 2
	    hours: 2
	    minutes: 3
	    seconds: 4
    ]

    minInstance [
	<category: 'private'>
	^Duration 
	    days: 0
	    hours: 2
	    minutes: 3
	    seconds: 4
    ]
]



MAMagnitudeDescriptionTest subclass: MANumberDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MANumberDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MANumberDescription
    ]

    excludedInstance [
	<category: 'private'>
	^0.618
    ]

    includedInstance [
	<category: 'private'>
	^2.7182
    ]

    maxInstance [
	<category: 'private'>
	^3.1415
    ]

    minInstance [
	<category: 'private'>
	^1.618
    ]

    testFromString [
	"We do some special tests here because #visitNumberDescription: in
	 MAStringReader works around problems with Number>>readFrom."

	<category: 'private'>
	self shouldSkipStringTests ifTrue: [^self].
	super testFromString.
	self 
	    should: [self description fromString: 'xyz']
	    raise: MAReadError
	    description: 'Non-numeric string should raise an error'.
	self 
	    should: [self description fromString: '12-234']
	    raise: MAReadError
	    description: 'Non-numeric string should raise an error'.
	self 
	    should: [self description fromString: '1.4.2007']
	    raise: MAReadError
	    description: 'Non-numeric string should raise an error'.
	self assert: (self description fromString: '') isNil
	    description: 'Empty string should be parsed to nil'.
	self assert: (self description fromString: '-20') = -20
	    description: 'Negative numbers should be accepted'
    ]

    testValidateConditions [
	<category: 'tests'>
	
    ]
]



MAMagnitudeDescriptionTest subclass: MATimeDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATimeDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATimeDescription
    ]

    excludedInstance [
	<category: 'private'>
	^Time 
	    hour: 9
	    minute: 33
	    second: 12
    ]

    includedInstance [
	<category: 'private'>
	^Time 
	    hour: 11
	    minute: 33
	    second: 12
    ]

    maxInstance [
	<category: 'private'>
	^Time 
	    hour: 12
	    minute: 33
	    second: 12
    ]

    minInstance [
	<category: 'private'>
	^Time 
	    hour: 10
	    minute: 33
	    second: 12
    ]
]



MAMagnitudeDescriptionTest subclass: MATimeStampDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATimeStampDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATimeStampDescription
    ]

    excludedInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 1
	    day: 11
	    hour: 11
	    minute: 38
	    second: 12
    ]

    includedInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 6
	    day: 11
	    hour: 11
	    minute: 38
	    second: 12
    ]

    maxInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 6
	    day: 12
	    hour: 11
	    minute: 38
	    second: 12
    ]

    minInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 6
	    day: 10
	    hour: 11
	    minute: 38
	    second: 12
    ]
]



MAElementDescriptionTest subclass: MAReferenceDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAReferenceDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAReferenceDescription
    ]

    referenceInstance [
	<category: 'private'>
	^MAStringDescription new
    ]

    setUp [
	<category: 'running'>
	super setUp.
	self description reference: self referenceInstance.
	self assert: self description reference accessor notNil
    ]

    testCopyReference [
	<category: 'testing-copying'>
	self assert: self description copy reference = self description reference.
	self deny: self description copy reference == self description reference
    ]
]



MAReferenceDescriptionTest subclass: MAOptionDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAOptionDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAOptionDescription
    ]

    optionInstances [
	<category: 'private'>
	^Array 
	    with: 'foo'
	    with: 'bar'
	    with: 'zork'
    ]

    setUp [
	<category: 'running'>
	super setUp.
	self description options: self optionInstances
    ]

    testAllOptions [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    beSorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(#a #b #c).
	(self description)
	    beRequired;
	    beUnsorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(#c #b #a)
    ]

    testAllOptionsWithExisting [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    options: #(#a #b #c).
	self assert: (self description allOptionsWith: #a) = #(#a #b #c)
    ]

    testAllOptionsWithNil [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    options: #(#a #b #c).
	self assert: (self description allOptionsWith: nil) = #(#a #b #c)
    ]

    testCopyOptions [
	<category: 'testing-copying'>
	self deny: self description copy options == self description options.
	self assert: self description copy options = self description options
    ]

    testFromStringInvalid [
	"There is no invalid string input."

	<category: 'testing-strings'>
	
    ]

    testOptions [
	<category: 'testing-accessing'>
	self description options: #(#a #b #c).
	self assert: self description options = #(#a #b #c)
    ]

    testOptionsAndLabels [
	<category: 'testing-strings'>
	self description reference: MANumberDescription new.
	self assert: (self description labelForOption: 1) = '1'.
	self description 
	    optionsAndLabels: (Array with: 1 -> 'one' with: 2 -> 'two').
	self assert: (self description labelForOption: 1) = 'one'.
	self assert: (self description labelForOption: 2) = 'two'.
	self assert: (self description labelForOption: 3) = '3'
    ]

    testReferencePrinting [
	<category: 'testing'>
	self description reference: MAStringDescription new.
	self assert: (self description labelForOption: 1) = '1'.
	self assert: (self description labelForOption: 1 @ 2) = '1@2'.
	self assert: (self description labelForOption: 1 -> 2) = '1->2'
    ]

    testSorted [
	<category: 'testing-properties'>
	self description beSorted.
	self assert: self description isSorted.
	self assert: self description sorted.
	self description beUnsorted.
	self deny: self description isSorted.
	self deny: self description sorted
    ]
]



MAOptionDescriptionTest subclass: MAMultipleOptionDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAMultipleOptionDescriptionTest class >> defaultUnique [
	<category: 'accessing-default'>
	^false
    ]

    MAMultipleOptionDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAMultipleOptionDescription
    ]

    includedInstance [
	<category: 'private'>
	^self optionInstances copyFrom: 1 to: 2
    ]

    testOrdered [
	<category: 'testing-properties'>
	self description beOrdered.
	self assert: self description isOrdered.
	self assert: self description ordered.
	self description beUnordered.
	self deny: self description isOrdered.
	self deny: self description ordered
    ]

    testSorted [
	<category: 'testing-properties'>
	self description beDistinct.
	self assert: self description isDistinct.
	self assert: self description distinct.
	self description beIndefinite.
	self deny: self description isDistinct.
	self deny: self description distinct
    ]
]



MAOptionDescriptionTest subclass: MASingleOptionDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MASingleOptionDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MASingleOptionDescription
    ]

    includedInstance [
	<category: 'private'>
	^self optionInstances first
    ]

    testAllOptionsOptional [
	<category: 'testing-accessing'>
	(self description)
	    beOptional;
	    beSorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(nil #a #b #c).
	(self description)
	    beOptional;
	    beUnsorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(nil #c #b #a)
    ]

    testAllOptionsWithExtensible [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    beUnsorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#c #d #a).
	(self description)
	    beRequired;
	    beUnsorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#c #d #a #b).
	(self description)
	    beRequired;
	    beSorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#a #c #d).
	(self description)
	    beRequired;
	    beSorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#a #b #c #d)
    ]

    testAllOptionsWithOptional [
	<category: 'testing-accessing'>
	(self description)
	    beOptional;
	    beSorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #a #b #c #d).
	(self description)
	    beOptional;
	    beSorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #a #c #d).
	(self description)
	    beOptional;
	    beUnsorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #c #d #a #b).
	(self description)
	    beOptional;
	    beUnsorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #c #d #a)
    ]

    testExtensible [
	<category: 'testing-properties'>
	self description beExtensible.
	self assert: self description isExtensible.
	self assert: self description extensible.
	self description beLimited.
	self deny: self description isExtensible.
	self deny: self description extensible
    ]

    testGroupBy [
	<category: 'testing-properties'>
	self deny: self description isGrouped.
	self description groupBy: #grouping.
	self assert: self description isGrouped
    ]

    testGroupOf [
	<category: 'testing-properties'>
	self assert: MADateDescription grouping = 'Magnitude'
    ]
]



MAReferenceDescriptionTest subclass: MARelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MARelationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MARelationDescription
    ]

    addressInstance1 [
	<category: 'private'>
	^(MAMockAddress new)
	    street: 'Tillierstrasse 17';
	    plz: 3005;
	    place: 'Bern';
	    yourself
    ]

    addressInstance2 [
	<category: 'private'>
	^(MAMockAddress new)
	    street: 'In der Au';
	    plz: 8765;
	    place: 'Engi';
	    yourself
    ]

    setUp [
	<category: 'running'>
	super setUp.
	(self description)
	    reference: MAMockAddress description;
	    classes: (Array with: MAMockAddress)
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]

    testCopyClasses [
	<category: 'testing-copying'>
	self assert: self description copy classes = self description classes.
	self deny: self description copy classes == self description classes
    ]
]



MARelationDescriptionTest subclass: MAToManyRelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAToManyRelationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAToManyRelationDescription
    ]

    includedInstance [
	<category: 'private'>
	^Array with: self addressInstance1 with: self addressInstance2
    ]

    testDefinitive [
	<category: 'testing-properties'>
	self description beDefinitive.
	self assert: self description isDefinitive.
	self assert: self description definitive.
	self description beModifiable.
	self deny: self description isDefinitive.
	self deny: self description definitive
    ]

    testOrdered [
	<category: 'testing-properties'>
	self description beOrdered.
	self assert: self description isOrdered.
	self assert: self description ordered.
	self description beUnordered.
	self deny: self description isOrdered.
	self deny: self description ordered
    ]

    testSorted [
	<category: 'testing-properties'>
	self description beSorted.
	self assert: self description isSorted.
	self assert: self description sorted.
	self description beUnsorted.
	self deny: self description isSorted.
	self deny: self description sorted
    ]
]



MAToManyRelationDescriptionTest subclass: MAToManyScalarRelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    actualClass [
	<category: 'private'>
	^MAToManyScalarRelationDescription
    ]

    includedInstance [
	<category: 'private'>
	^Array with: '1' with: '2'
    ]

    setUp [
	<category: 'running'>
	super setUp.
	(self description)
	    reference: ((MAStringDescription new)
			accessor: MANullAccessor new;
			yourself);
	    classes: (Array with: String)
    ]
]



MARelationDescriptionTest subclass: MAToOneRelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAToOneRelationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAToOneRelationDescription
    ]

    includedInstance [
	<category: 'private'>
	^self addressInstance1
    ]
]



MAReferenceDescriptionTest subclass: MATableDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATableDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATableDescription
    ]

    includedInstance [
	<category: 'private'>
	^MATableModel 
	    rows: 3
	    columns: 3
	    contents: #('1' '2' '3' '2' '4' '6' '3' '6' '9')
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]
]



MAReferenceDescriptionTest subclass: MATokenDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATokenDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATokenDescription
    ]

    includedInstance [
	<category: 'private'>
	^#('foo' 'bar')
    ]

    testFromStringInvalid [
	"There is no invalid string input."

	<category: 'testing-strings'>
	
    ]
]



MAElementDescriptionTest subclass: MAStringDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAStringDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAStringDescription
    ]

    includedInstance [
	<category: 'private'>
	^'Lukas Renggli'
    ]

    testFromStringInvalid [
	"There is no invalid string input."

	<category: 'testing-strings'>
	
    ]
]



MAStringDescriptionTest subclass: MAMemoDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    actualClass [
	<category: 'private'>
	^MAMemoDescription
    ]

    testLineCount [
	<category: 'testing-properties'>
	self description lineCount: 123.
	self assert: self description lineCount = 123
    ]
]



MAStringDescriptionTest subclass: MAPasswordDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAPasswordDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAPasswordDescription
    ]

    testIsObfuscated [
	<category: 'testing'>
	self deny: (self description isObfuscated: '').
	self deny: (self description isObfuscated: nil).
	self deny: (self description isObfuscated: 123).
	self deny: (self description isObfuscated: '**1').
	self assert: (self description isObfuscated: '******')
    ]

    testObfuscated [
	<category: 'testing'>
	self assert: (self description obfuscated: nil) = ''.
	self assert: (self description obfuscated: 'zork') = '****'.
	self assert: (self description obfuscated: 'foobar') = '******'
    ]
]



MAStringDescriptionTest subclass: MASymbolDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MASymbolDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MASymbolDescription
    ]

    includedInstance [
	<category: 'private'>
	^#magritte
    ]

    testValidateConditions [
	<category: 'testing-validation'>
	
    ]
]



MAObjectTest subclass: MAMementoTest [
    | description memento value |
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MAMementoTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAMemento
    ]

    defaultInstance [
	<category: 'private'>
	^'Lukas Renggli'
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    descriptionInstance [
	<category: 'private'>
	^MAContainer with: ((MAStringDescription new)
		    default: self defaultInstance;
		    accessor: #value;
		    yourself)
    ]

    descriptionValue [
	<category: 'accessing'>
	^self description children first
    ]

    includedInstance [
	<category: 'private'>
	^'Rene Magritte'
    ]

    instance [
	<category: 'accessing'>
	^memento
    ]

    invalidInstance [
	<category: 'private'>
	^31415
    ]

    memento [
	<category: 'accessing'>
	^memento
    ]

    mementoInstance [
	<category: 'private'>
	^self actualClass model: self modelInstance
    ]

    modelInstance [
	<category: 'private'>
	^self
    ]

    nullInstance [
	<category: 'private'>
	^nil
    ]

    otherInstance [
	<category: 'private'>
	^'Ursula Freitag'
    ]

    read [
	<category: 'accessing-memento'>
	^self memento readUsing: self descriptionValue
    ]

    setUp [
	<category: 'running'>
	super setUp.
	description := self descriptionInstance.
	memento := self mementoInstance
    ]

    testCommit [
	<category: 'testing-actions'>
	self subclassResponsibility
    ]

    testDescription [
	<category: 'testing-accessing'>
	self assert: self memento description = self description.
	self assert: self memento description = self descriptionInstance
    ]

    testModel [
	<category: 'testing-accessing'>
	self assert: self memento model = self modelInstance
    ]

    testRead [
	<category: 'testing-basic'>
	self subclassResponsibility
    ]

    testReset [
	<category: 'testing-actions'>
	self subclassResponsibility
    ]

    testValidateIncluded [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self shouldnt: [self memento validate] raise: MAValidationError
    ]

    testValidateInvalid [
	<category: 'testing-actions'>
	self write: self invalidInstance.
	self should: [self memento validate] raise: MAValidationError
    ]

    testValidateRequired [
	<category: 'testing-actions'>
	self descriptionValue beRequired.
	self write: self nullInstance.
	self should: [self memento validate] raise: MAValidationError
    ]

    testWrite [
	<category: 'testing-basic'>
	self subclassResponsibility
    ]

    value [
	<category: 'accessing-model'>
	^value
    ]

    value: anObject [
	<category: 'accessing-model'>
	value := anObject
    ]

    write: anObject [
	<category: 'accessing-memento'>
	self memento write: anObject using: self descriptionValue
    ]
]



MAMementoTest subclass: MACachedMementoTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MACachedMementoTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MACachedMemento
    ]

    testCache [
	<category: 'testing-accessing'>
	self assert: self memento cache size = self description size
    ]

    testCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self value = self nullInstance.
	self assert: self memento hasChanged.
	self memento commit.
	self assert: self read = self includedInstance.
	self assert: self value = self includedInstance.
	self deny: self memento hasChanged
    ]

    testRead [
	<category: 'testing-basic'>
	self assert: self read = self defaultInstance.
	self value: self includedInstance.
	self assert: self read = self defaultInstance
    ]

    testReset [
	<category: 'testing-actions'>
	self value: self defaultInstance.
	self write: self includedInstance.
	self assert: self memento hasChanged.
	self memento reset.
	self assert: self read = self defaultInstance.
	self assert: self value = self defaultInstance.
	self deny: self memento hasChanged
    ]

    testWrite [
	<category: 'testing-basic'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self value = self nullInstance.
	self write: self defaultInstance.
	self assert: self read = self defaultInstance.
	self assert: self value = self nullInstance
    ]
]



MACachedMementoTest subclass: MACheckedMementoTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MACheckedMementoTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MACheckedMemento
    ]

    testConflictCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self deny: self memento hasConflict.
	self value: self otherInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self assert: self memento hasConflict.
	self memento commit.
	self assert: self read = self includedInstance.
	self assert: self value = self includedInstance.
	self deny: self memento hasChanged.
	self deny: self memento hasConflict
    ]

    testConflictReset [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self deny: self memento hasConflict.
	self value: self otherInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self assert: self memento hasConflict.
	self memento reset.
	self assert: self read = self otherInstance.
	self assert: self value = self otherInstance.
	self deny: self memento hasChanged.
	self deny: self memento hasConflict
    ]

    testOriginal [
	<category: 'testing-accessing'>
	self assert: self memento original size = self description size
    ]

    testValidateConflictCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self shouldnt: [self memento validate] raise: MAValidationError.
	self value: self otherInstance.
	self should: [self memento validate] raise: MAValidationError.
	self memento commit.
	self shouldnt: [self memento validate] raise: MAValidationError
    ]

    testValidateConflictReset [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self shouldnt: [self memento validate] raise: MAValidationError.
	self value: self otherInstance.
	self should: [self memento validate] raise: MAValidationError.
	self memento reset.
	self shouldnt: [self memento validate] raise: MAValidationError
    ]
]



MAMementoTest subclass: MAStraitMementoTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MAStraitMementoTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAStraitMemento
    ]

    testCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self value = self includedInstance.
	self assert: self read = self includedInstance.
	self memento commit.
	self assert: self value = self includedInstance.
	self assert: self read = self includedInstance
    ]

    testRead [
	<category: 'testing-basic'>
	self assert: self read = self defaultInstance.
	self value: self includedInstance.
	self assert: self read = self includedInstance.
	self value: self defaultInstance.
	self assert: self read = self defaultInstance
    ]

    testReset [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self memento reset.
	self assert: self read = self includedInstance
    ]

    testValidateRequired [
	<category: 'testing-actions'>
	
    ]

    testWrite [
	<category: 'testing-basic'>
	self write: self includedInstance.
	self assert: self value = self includedInstance.
	self write: self defaultInstance.
	self assert: self value = self defaultInstance.
	self write: self nullInstance.
	self assert: self value = self nullInstance
    ]
]



TestCase subclass: MATableModelTest [
    | table |
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    setUp [
	<category: 'running'>
	table := (MATableModel rows: 3 columns: 4) 
		    collect: [:row :col :value | row raisedTo: col]
    ]

    testAtAt [
	<category: 'testing-accessing'>
	self assert: (table at: 1 at: 1) = 1.
	self assert: (table at: 2 at: 3) = 8.
	self assert: (table at: 3 at: 2) = 9.
	self assert: (table at: 3 at: 4) = 81
    ]

    testAtAtAbsent [
	<category: 'testing-accessing'>
	self should: [table at: 0 at: 1] raise: Error.
	self should: [table at: 1 at: 0] raise: Error.
	self should: [table at: 4 at: 4] raise: Error.
	self should: [table at: 3 at: 5] raise: Error
    ]

    testAtAtPut [
	<category: 'testing-accessing'>
	self assert: (table 
		    at: 1
		    at: 1
		    put: -1) = -1.
	self assert: (table 
		    at: 2
		    at: 3
		    put: -8) = -8.
	self assert: (table 
		    at: 3
		    at: 2
		    put: -9) = -9.
	self assert: (table 
		    at: 3
		    at: 4
		    put: -81) = -81.
	self assert: (table at: 1 at: 1) = -1.
	self assert: (table at: 2 at: 3) = -8.
	self assert: (table at: 3 at: 2) = -9.
	self assert: (table at: 3 at: 4) = -81
    ]

    testAtAtPutAbsent [
	<category: 'testing-accessing'>
	self should: 
		[table 
		    at: 0
		    at: 1
		    put: 0]
	    raise: Error.
	self should: 
		[table 
		    at: 1
		    at: 0
		    put: 0]
	    raise: Error.
	self should: 
		[table 
		    at: 4
		    at: 4
		    put: 0]
	    raise: Error.
	self should: 
		[table 
		    at: 3
		    at: 5
		    put: 0]
	    raise: Error
    ]

    testCollect [
	<category: 'testing-enumerating'>
	table := table collect: [:row :col :val | row + col + val].
	table 
	    do: [:row :col :val | self assert: (row raisedTo: col) = (val - row - col)]
    ]

    testContents [
	<category: 'testing-accessing'>
	self assert: table contents = #(1 1 1 1 2 4 8 16 3 9 27 81)
    ]

    testCopy [
	<category: 'testing-copying'>
	self assert: table copy rowCount = table rowCount.
	self assert: table copy columnCount = table columnCount.
	self assert: table copy contents = table contents.
	self deny: table copy contents == table contents
    ]

    testCopyEmpty [
	<category: 'testing-copying'>
	self assert: table copyEmpty rowCount = table rowCount.
	self assert: table copyEmpty columnCount = table columnCount.
	self assert: (table copyEmpty contents allSatisfy: [:each | each isNil])
    ]

    testCopyRowsColumns [
	<category: 'testing-copying'>
	self assert: (table copyRows: 1 columns: 2) rowCount = 1.
	self assert: (table copyRows: 1 columns: 2) columnCount = 2.
	self assert: (table copyRows: 1 columns: 2) contents = #(1 1).
	self assert: (table copyRows: 4 columns: 3) rowCount = 4.
	self assert: (table copyRows: 4 columns: 3) columnCount = 3.
	self assert: (table copyRows: 4 columns: 3) contents 
		    = #(1 1 1 2 4 8 3 9 27 nil nil nil)
    ]

    testCoumnCount [
	<category: 'testing-accessing'>
	self assert: table columnCount = 4
    ]

    testDo [
	<category: 'testing-enumerating'>
	table do: [:row :col :val | self assert: (row raisedTo: col) = val]
    ]

    testEqual [
	<category: 'testing-comparing'>
	self assert: table = table.
	self assert: table = table copy.
	self assert: table copy = table.
	self assert: table copy = table copy.
	self deny: table = (table copy 
			    at: 1
			    at: 2
			    put: 3).
	self deny: table = (table copyRows: 3 columns: 3).
	self deny: table = (table copyRows: 4 columns: 4)
    ]

    testHash [
	<category: 'testing-comparing'>
	self assert: table hash = table hash.
	self assert: table hash = table copy hash.
	self assert: table copy hash = table hash.
	self assert: table copy hash = table copy hash
    ]

    testRowCount [
	<category: 'testing-accessing'>
	self assert: table rowCount = 3
    ]

    testSetup [
	<category: 'testing'>
	self assert: table rowCount = 3.
	self assert: table columnCount = 4.
	self assert: table contents = #(1 1 1 1 2 4 8 16 3 9 27 81)
    ]
]

