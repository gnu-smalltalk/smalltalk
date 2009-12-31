Object subclass: GtkImageModel [
    GtkImageModel class [ | current | ]

    GtkImageModel class >> release [
	<category: 'accessing'>

	current := nil.
        super release
    ]

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
	    registerNotifier;
            buildNamespaceModel;
            buildClassModel;
            buildMethodModel.
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(VisualGST uniqueInstance systemChangeNotifier)
	    notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addNamespaceEvent:';
	    notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeNamespaceEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Added using: #'addClassEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeClassEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Added using: #'addMethodEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeMethodEvent:'
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

    matchSelector: aSymbol [
	<category: 'item selection'>

        ^ finderDic at: aSymbol asString ifAbsent: [ self error: 'Element not found' ].
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
    
    addNamespaceEvent: anEvent [
	<category: 'events'>

        finderDic at: anEvent item displayString ifAbsentPut: [ self appendToModel: anEvent item displayString. Dictionary new ].
	self at: anEvent item displayString addToFinder: (NamespaceFinder on: anEvent item).
    ]

    removeNamespaceEvent: anEvent [
	<category: 'events'>
    ]

    addClassEvent: anEvent [
	<category: 'events'>

	| string |
        string := ((anEvent item displayString) substrings: $.) last.
        finderDic at: string ifAbsentPut: [ self appendToModel: string. Dictionary new ].
	self at: string addToFinder: (ClassFinder on: anEvent item) 
    ]

    removeClassEvent: anEvent [
	<category: 'events'>
    ]

    addMethodEvent: anEvent [
	<category: 'events'>
    ]

    removeMethodEvent: anEvent [
	<category: 'events'>
    ]
]
