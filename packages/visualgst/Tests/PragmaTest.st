TestCase subclass: PragmasTest [

    testNamespaceExtend [
	<category: 'testing'>
   
	self assert: Smalltalk namespaceExtends isEmpty.
	self assert: Kernel namespaceExtends isEmpty.
	self assert: Kernel namespaceExtends ~~ Smalltalk namespaceExtends
    ]

    testPragma [
	<category: 'testing'>

	| behavior |
	behavior := Behavior new.
	Smalltalk addSubspace: #Foo.
	behavior superclass: Object.
	behavior compile: 'test [ <namespace: Foo classCategory: ''foo-bar'' category: ''xork''> ]'.
	self assert: (behavior>>#test) methodCategory = 'xork'.
	self assert: (((Smalltalk at: #Foo) namespaceExtends at: 'foo-bar') includes: (behavior>>#test)).
	behavior compile: 'test [ <namespace: Foo category: ''bar''> ]'.
	self assert: (behavior>>#test) methodCategory = 'bar'.
	self assert: (((Smalltalk at: #Foo) namespaceExtends at: '') includes: (behavior>>#test)).
	Smalltalk removeSubspace: #Foo
    ]
]

