GtkConcreteWidget subclass: GtkContextWidget [
    | column contextTree model context |

    GtkContextWidget class >> on: aContext [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    context: aContext;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    context: aContext [
	<category: 'accessing'>

	context := aContext.
	model := nil.
	self refreshModel
    ]

    model [
	<category: 'accessing'>

	^ model ifNil: [ model := (GtkContextModel on: context) model ]
    ]

    refreshModel [
	<category: 'events'>

	contextTree setModel: self model
    ]

    buildTreeView [
        <category: 'user interface'>
    
	contextTree := (GTK.GtkTreeView newWithSortedTextColumn: (GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString}) title: 'Contexts')
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
	column := contextTree getColumn: 0.
	contextTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	^ GTK.GtkScrolledWindow withChild: contextTree
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Add a method'. self. #newMethod}.
            {'Rename a method'. self. #renameMethod}.
            {'Delete a method'. self. #deleteMethod}.
            {}.
            {'Inspect a method'. self. #inspectMethod}.
            {}.
            {'File out a method'. self. #fileoutMethod}}.
        menu attachToWidget: contextTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	contextTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    selectLastContext [
        <category: 'item selection'>

	| selection |
        selection := contextTree getSelection.
        selection unselectAll.
        selection selectIter: self model lastIter
    ]

    selectFirstContext [
        <category: 'item selection'>

        | selection |
        selection := contextTree getSelection.
        selection unselectAll.
        selection selectIter: self model getIterFirst
    ]

    hasSelectedContext [
	<category: 'testing'>

	^ contextTree hasSelectedItem
    ]

    selectedIter [
	<category: 'accessing'>
	
	^ (contextTree selectedIter) ifNil: [ self error: 'Nothing is selected' ].
    ]

    selectedContext [
	<category: 'accessing'>

        | iter string |
        iter := self selectedIter.
        ^ (self model getOop: iter column: 0) asSymbol
    ]

    numberOfContext [
	<category: 'accessing'>

	^ self model iterNChildren: nil.
    ]
]

