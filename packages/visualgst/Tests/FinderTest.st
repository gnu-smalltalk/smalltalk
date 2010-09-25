TestCase subclass: FinderTest [

    | namespace class imethod cmethod |

    selectANamespace: anObject [

	namespace := anObject
    ]

    selectAClass: anObject [

        class := anObject
    ]

    selectAnInstanceMethod: anObject [

	imethod := anObject
    ]

    selectAClassMethod: anObject [

	cmethod := anObject
    ]

    testAbstractFinder [
	<category: 'testing'>

	| finder |
	finder := AbstractFinder new.
	self should: [ finder updateBrowser: nil ] raise: Error.
	self should: [ finder element ] raise: Error
    ]

    testNamespaceFinder [
	<category: 'testing'>

        | finder |
        finder := NamespaceFinder on: Smalltalk.
	self assert: finder displayString = 'Smalltalk'.
        finder updateBrowser: self.
	self assert: namespace == Smalltalk.
	self assert: finder element == Smalltalk.
	finder namespace: Kernel.
	self assert: finder element == Kernel
    ]

    testClassFinder [
        <category: 'testing'>
    
        | finder |
        finder := ClassFinder on: Object.
        self assert: finder displayString = 'Object'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == Object.
        self assert: finder element == Object.
        finder class: String class.
        self assert: finder element == String class
    ]

    testMethodFinder [
        <category: 'testing'>

        | finder |
        finder := MethodFinder on: Object with: #at:.
        self assert: finder displayString = 'Object >> #at:'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == Object.
        self assert: imethod == #at:.
        self assert: finder element == #at:.

        finder := MethodFinder on: String class with: #new:.
        self assert: finder displayString = 'String class >> #new:'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == String.
        self assert: cmethod == #new:.
        self assert: finder element == #new:
    ]
]

