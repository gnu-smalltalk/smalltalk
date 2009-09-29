GtkConcreteWidget subclass: GtkClassWidget [
    | classesTree column model namespace |

    GtkClassWidget >> on: aNamespace [
	^ (self new)
	    initialize;
	    namespace: aNamespace;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    classModel [
	<category: 'initialization'>

	^ GtkClassModel
    ]

    namespace [
	<category: 'accessing'>
    
	^ namespace
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace.
	self refreshModel
    ]

    model [
	<category: 'accessing'>

	^ model ifNil: [ model := self classModel on: self namespace ]
    ]

    refreshModel [
	<category: 'events'>

	model := self classModel on: self namespace.

	classesTree
	    setModel: self model gtkModel;
	    expandAll.
	self model isSorted
            ifFalse: [
                column signalEmitByName: 'clicked' args: {}.
                self model sorted: true ].
    ]

    buildTreeView [
	<category: 'user interface'>
    
	classesTree := (GTK.GtkTreeView newWithSortedTextColumn: self model gtkModel title: 'Classes')
			    connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
			    yourself.
	column := classesTree getColumn: 0.
	classesTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	self model isSorted 
	    ifFalse: [
		column signalEmitByName: 'clicked' args: {}.
		self model sorted: true ].
	^ GTK.GtkScrolledWindow withChild: classesTree
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Add a class'. self. #newClass}.
            {'Rename a class'. self. #renameClass}.
            {'Delete a class'. self. #deleteClass}.
            {}.
            {'Inspect a class'. self. #inspectClass}.
            {}.
            {'File out a class'. self. #fileoutClass}}.
        menu attachToWidget: classesTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    selectionMode: aSelectionMode [
	<category: 'user interface'>

	classesTree getSelection setMode: aSelectionMode.
    ]

    selectedNamespace [
	<category: 'accessing'>

	^ namespace
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree hasSelectedItem
    ]

    selectedClass [
	<category: 'accessing'>

	| iter string |
	(iter := self selectedIter) ifNil: [self error: 'Nothing is selected'].
	string := ((self model gtkModel getOop: iter column: 0) subStrings: $ ) at: 1.
	^ self namespace classAt: string asSymbol
    ]

    selectAClass: aClass [
	<category: 'item selection'>

	| selection |
        selection := classesTree getSelection.
        selection unselectAll.
        selection selectIter: (self findIterInAClass: aClass)
    ]

    findIterInAClass: aClass [
        <category: 'item selection'>

	| result |

	result := self model findIterInAClass: aClass.
	classesTree scrollToCell: (self model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
	^ result 
    ]

    selectedIter [
	<category: 'accessing'>

	^ classesTree selectedIter
    ]

    newClass [
        <category: 'class events'>

        AddClassCommand on: self
    ]

    renameClass [
        <category: 'class events'>

        RenameClassCommand on: self
    ]

    deleteClass [
        <category: 'class events'>

        DeleteClassCommand on: self
    ]

    inspectClass [
        <category: 'class events'>

	InspectClassCommand on: self
    ]

    fileoutClass [
        <category: 'class events'>

	FileoutClassCommand on: self selectedClass
    ]
]

