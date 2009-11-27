GtkConcreteWidget subclass: GtkMethodWidget [
    | column methodTree model class category |

    GtkMethodWidget >> on: aClass withCategory: aCategory [
    ^ (self new)
        initialize;
	class: aClass withCategory: aCategory;
        yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    methodModel [
	<category: 'accessing'>

	^ GtkMethodModel
    ]

    category [
	<category: 'accessing'>

	^ category
    ]

    category: aString [
	<category: 'accessing'>

	category := aString.
	self refreshModel
    ]

    class: aClass withCategory: aString [
	<category: 'accessing'>

	class := aClass.
	self category: aString
    ]

    model [
	<category: 'accessing'>

	
	^ model ifNil: [ model := self methodModel on: self classOrMetaSelected withCategory: self category ]
    ]

    emptyModel [
        <category: 'accessing'>

        methodTree setModel: (GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString})
    ]

    refreshModel [
	<category: 'events'>

	model := self methodModel on: self classOrMetaSelected withCategory: self category.
	methodTree setModel: self model gtkModel.
        self model isSorted
            ifFalse: [
                column signalEmitByName: 'clicked' args: {}.
                self model sorted: true ].
    ]

    buildTreeView [
        <category: 'user interface'>
    
	methodTree := (GTK.GtkTreeView newWithSortedTextColumn: self model gtkModel title: 'Methods')
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
	column := methodTree getColumn: 0.
	methodTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        self model isSorted
            ifFalse: [
                column signalEmitByName: 'clicked' args: {}.
                self model sorted: true ].
	^ GTK.GtkScrolledWindow withChild: methodTree
    ]

    isTestMethod [
	<category: 'button event'>
	^(self classOrMetaSelected inheritsFrom: TestCase)
	    and: [ self selectedMethodSymbol startsWith: 'test' ]
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
	self isTestMethod ifTrue: [
            menu appendMenuItems: {{'Run test'. self. #runTest}} ].
        menu appendMenuItems: {{'Browse senders'. self. #browseSenders}.
	    {'Browse implementors'. self. #browseImplementors}.
	    {}.
	    {'Rename method'. self. #renameMethod}.
            {'Delete method'. self. #deleteMethod}.
            {}.
            {'Inspect method'. self. #inspectMethod}.
            {}.
            {'File out method'. self. #fileoutMethod}}.
        menu attachToWidget: methodTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	methodTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    classOrMetaSelected [
	<category: 'accessing'>

	^ class
    ]

    selectedCategory [
	<category: 'accessing'>

	^ category = '*' 
	    ifTrue: [ nil ]
	    ifFalse: [ category ]
    ]

    hasSelectedMethod [
	<category: 'testing'>

	^ methodTree hasSelectedItem
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        | iter string |
        (iter := methodTree selectedIter) ifNil: [ ^nil ].
        ^ (self model gtkModel getOop: iter column: 0) asSymbol
    ]

    selectedMethod [
	<category: 'accessing'>

	| symbol |
	(symbol := self selectedMethodSymbol) ifNil: [ ^nil ].
	^ self classOrMetaSelected compiledMethodAt: symbol
    ]

    selectAMethod: aString [
        <category: 'item selection'>

        | selection |
        selection := methodTree getSelection.
        selection unselectAll.
        aString ifNil: [ ^ self ].
        selection selectIter: (self findIterInAMethod: aString)
    ]

    findIterInAMethod: aString [
        <category: 'item selection'>

        | result |

        result := self model findIterInAMethod: aString.
        methodTree scrollToCell: (self model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        ^ result
    ]

    sourceCode [
	<category: 'accessing'>

	self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
	^ (self classOrMetaSelected compiledMethodAt: self selectedMethodSymbol) methodRecompilationSourceString
    ]

    deleteMethod [
        <category: 'method events'>

        DeleteMethodCommand on: self
    ]

    inspectMethod [
        <category: 'method events'>

	InspectMethodCommand on: self
    ]

    browseSenders [
        <category: 'method events'>

	OpenSenderCommand on: self
    ]

    browseImplementors [
        <category: 'method events'>

	OpenImplementorCommand on: self
    ]

    runTest [
        <category: 'method events'>

	RunTestCommand on: self
    ]

    fileoutMethod [
        <category: 'method events'>

	FileoutMethodCommand on: self selectedMethod
    ]
]

