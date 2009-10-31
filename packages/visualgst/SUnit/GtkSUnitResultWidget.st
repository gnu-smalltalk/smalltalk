GtkConcreteWidget subclass: GtkSUnitResult [
    | model resultTree results |
    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    buildTreeView [
        <category: 'user interface'>

        resultTree := (GTK.GtkTreeView newWithTextColumn: self model title: 'Results')
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    model [
        <category: 'model'>

        ^ model ifNil: [
            model := GTK.GtkTreeStore new: 2 varargs: {GTK.GValue gTypeString. GTK.GLib oopType} ]
    ]

    clearModel [
	<category: 'model'>

	self model clear
    ]

    results: aSet [
	<category: 'accessing'>

	self clearModel.
	results := aSet.
	results do: [ :each |
	    self model appendItem: {each displayString. each} ]
    ]

    onPress: aGtkWidget event: aGdkEvent [
	<category: 'event'>
	| aGdkButtonEvent menu |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Run test'. self. #runTest}.
            "{'Show test'. self. #showTest}"}.
        menu attachToWidget: resultTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true

    ]

    runTest [
	<category: 'event'>
	
        RunTestCommand on: self
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ resultTree hasSelectedItem
    ]

    classOrMetaSelected [
        <category: 'accessing'>

        ^ self selectedResult class
    ]
	
    selectedMethodSymbol [
        <category: 'accessing'>

        ^ self selectedResult selector
    ]

    selectedMethod [
        <category: 'accessing'>

        self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
        ^ self class compiledMethodAt: self selectedMethodSymbol
    ]

    selectedResult [
        <category: 'accessing'>

	| iter |
        (iter := resultTree selectedIter) ifNil: [ self error: 'Nothing is selected' ].
        ^ self model getOop: iter column: 1
    ]


]

