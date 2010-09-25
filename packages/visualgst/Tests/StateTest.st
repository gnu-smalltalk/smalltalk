TestCase subclass: StateTest [

    testNamespaceState [
	<category: 'testing'>

	| st |
	st := NamespaceState on: self with: Kernel.
	self assert: st hasSelectedNamespace.
	self assert: st hasSelectedClass not.
	self assert: st hasSelectedCategory not.
	self assert: st hasSelectedMethod not.
	self assert: st namespace == Kernel.
	self assert: st classOrMeta isNil.
	self assert: st category isNil.
	self assert: st method isNil
    ]

    testClassState [
        <category: 'testing'>

        | st |
        st := ClassState on: self with: Object.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory not.
        self assert: st hasSelectedMethod not.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category isNil.
        self assert: st method isNil
    ]

    testCategoryState [
        <category: 'testing'>

        | st |
        st := CategoryState on: self with: Object->'foo'.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory.
        self assert: st hasSelectedMethod not.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category = 'foo'.
        self assert: st method isNil
    ]

    testMethodState [
        <category: 'testing'>

        | st |
        st := MethodState on: self with: Object>>#at:.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory.
        self assert: st hasSelectedMethod.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category = 'built ins'.
        self assert: st method == (Object>>#at:)
    ]

    testBrowserState [
	<category: 'testing'>

	| st |
	st := BrowserState on: self with: 123.
        self assert: st hasSelectedNamespace not.
        self assert: st hasSelectedClass not.
        self assert: st hasSelectedCategory not.
        self assert: st hasSelectedMethod not.
        self assert: st namespace isNil.
        self assert: st classOrMeta isNil.
        self assert: st category isNil.
        self assert: st method isNil
    ]
]

