Object subclass: GtkImageModel [
    GtkImageModel class [ | current | ]

    GtkImageModel class >> current [
	<category: 'accessing'>

	^ current ifNil: [ current := (self new)
					initialize;
					yourself ]
    ]

    GtkImageModel class >> currentModel [
        <category: 'accessing'>

        ^ self current model
    ]

    | finderDic isSorted model |

    initialize [
	<category: 'initialize-release'>

	finderDic := Dictionary new.
	isSorted := false.
	self
	    gtkModel;
            buildNamespaceModel;
            buildClassModel;
            buildMethodModel
    ]

    isSorted [
	<category: 'testing'>

	^ isSorted
    ]

    isSorted: aBoolean [
	<category: 'accessing'>

	isSorted := aBoolean
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    buildNamespaceModel [
        <category: 'model builder'>

        self appendNamespace: Smalltalk
    ]

    appendNamespace: aNamespace [
        <category: 'model builder'>

	| namespace |
        finderDic at: aNamespace displayString ifAbsentPut: [ self appendToModel: aNamespace displayString. Dictionary new ].
	self at: aNamespace displayString addToFinder: (NamespaceFinder on: aNamespace).

        aNamespace subspacesDo: [ :each | self appendNamespace: each ]
    ]

    buildClassModel [
        <category: 'model builder'>

        | class string |
        Class allSubclassesDo: [ :each |
            string := ((each displayString) substrings: $.) last.
            finderDic at: string ifAbsentPut: [ self appendToModel: string. Dictionary new ].
	    self at: string addToFinder: (ClassFinder on: each) ]
    ]

    buildMethodModel [
        <category: 'model builder'>

	| method |
        [ CompiledMethod allInstancesDo: [ :each | | selector |
            selector := each selector asString.
            finderDic at: selector ifAbsentPut: [ self appendToModel: selector. Dictionary new ].
	    self at: selector addToFinder: (MethodFinder on: each methodClass with: each selector) ] ] forkAt: Processor lowIOPriority
    ]

    at: aSelector addToFinder: aFinderObject [
	<category: 'finder accessing'>

	(finderDic at: aSelector)
                at: aFinderObject displayString
                put: aFinderObject
    ]

    appendToModel: aString [
        <category: 'model builder'>

        self gtkModel insertWithValues: nil position: 0 varargs: {0. aString. -1}
    ]

    selectedItem: aGtkIter [
	<category: 'item selection'>

	| string |
	string := (self gtkModel getOop: aGtkIter column: 0).
        ^ finderDic at: string ifAbsent: [ self error: 'Element not found' ].
    ]

    matchRegex: aString [
	<category: 'item selection'>

	| result |
	result := Dictionary new.
	finderDic keysAndValuesDo: [ :key :value |
	    (key matchRegex: aString) ifTrue: [ result at: key put: value ] ].
	^ (self class new)
	    finderTreeAsModel: result;
	    yourself
    ]

    finderTreeAsModel: aDictionary [
	<category: 'model'>

	finderDic := aDictionary.
	finderDic keysDo: [ :each |
	    self appendToModel: each ]
    ]
]
