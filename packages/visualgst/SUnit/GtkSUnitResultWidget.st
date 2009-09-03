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
            model := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString} ]
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
	    self model appendItem: {each displayString} ]
    ]
]

