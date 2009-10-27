GtkConcreteWidget subclass: GtkCategorizedNamespaceWidget [
    | namespacesTree model |

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    model [
	<category: 'accessing'>

	^ model ifNil: [ model := GtkCategorizedNamespaceModel new
							    initialize;
							    yourself ]
    ]

    buildTreeView [
	<category: 'user interface'>
    
	namespacesTree := (GTK.GtkTreeView newWith: self model gtkModel columns: {'pixbuf'->''. 'text'->'Namespaces'})
			    connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
			    expandAll;
                            yourself.
	namespacesTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	self model isSorted 
	    ifFalse: [ 
		(namespacesTree getColumn: 1) signalEmitByName: 'clicked' args: {}.
		self model sorted: true ].
	^ GTK.GtkScrolledWindow withChild: namespacesTree
    ]

    onPress: aGtkWidget event: aGdkEvent [
	<category: 'button event'>

	| menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
	aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
	menu := GTK.GtkMenu new.
	menu appendMenuItems: {{'Add a namespace'. self. #newNamespace}.
	    {'Rename a namespace'. self. #renameNamespace}.
	    {'Delete a namespace'. self. #deleteNamespace}.
	    {}.
	    {'Inspect a namespace'. self. #inspectNamespace}.
	    {}.
	    {'File out a namespace'. self. #fileoutNamespace}}.
	menu attachToWidget: namespacesTree detacher: nil.
	menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
	menu showAll.
	^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	namespacesTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedNamespace [
	<category: 'testing'>

	^ namespacesTree hasSelectedItem 
    ]

    selectedIter [
	<category: 'accessing'>

	| iter |
        ^ (iter := namespacesTree selectedIter) ifNil: [ self error: 'Nothing is selected' ]
    ]

    selectedNamespace [
	<category: 'accessing'>

	| iter path |
	'N' = (self model gtkModel getOop: self selectedIter column: 3) ifTrue: [ 
	    ^ self model gtkModel getOop: self selectedIter column: 2 ].
	path := self model gtkModel getPath: self selectedIter.
	iter := GTK.GtkTreeIter new.
	[ path up.
	  (self model gtkModel getIter: iter path: path) ifFalse: [ self error: 'Selected category not found' ].
	  'N' = (self model gtkModel getOop: iter column: 3) ] whileFalse.
	^ self model gtkModel getOop: iter column: 2
    ]

    selectedCategory [
	<category: 'accessing'>

	| iter path cat |
	'N' = (self model gtkModel getOop: self selectedIter column: 3) ifTrue: [ ^ '' ].
	path := self model gtkModel getPath: self selectedIter.
        iter := GTK.GtkTreeIter new.
	cat := self model gtkModel getOop: self selectedIter column: 1.
        [ path up.
          (self model gtkModel getIter: iter path: path) ifFalse: [ self error: 'Selected category not found' ].
          'N' = (self model gtkModel getOop: iter column: 3)
				    ifFalse: [ cat := (self model gtkModel getOop: iter column: 1), '-', cat. false ] 
				    ifTrue: [ true ] ] whileFalse.
	^ cat
    ]

    selectANamespace: aNamespace [
	<category: 'item selection'>

	| selection |
	selection := namespacesTree getSelection.
	selection unselectAll.
	selection selectIter: (self findIterInANamespace: aNamespace)
    ]

    findIterInANamespace: aNamespace [
	<category: 'item selection'>

	^ self model findIterInANamespace: aNamespace
    ]
    
    findNamespace: aString [
	<category: 'searching'>

	| result |
	(result := self findNamespace: aString from: Smalltalk) = self ifTrue: [ self error: 'Namespace ', aString, ' not found' ].
	^ result
    ]

    findNamespace: aString from: aNamespace [
	<category: 'searching'>

	aNamespace displayString = aString ifTrue: [ ^ aNamespace ].
	
	aNamespace subspacesDo: [ :each | | result |
	    (result := self findNamespace: aString from: each) = self 
		ifFalse: [ ^ result ] ]
    ]

    newNamespace [
	<category: 'popup events'>

	AddNamespaceCommand on: self
    ]

    renameNamespace [
        <category: 'namespace events'>

        RenameNamespaceCommand on: self
    ]

    deleteNamespace [
        <category: 'namespace events'>

        DeleteNamespaceCommand on: self
    ]

    inspectNamespace [
        <category: 'namespace events'>

	InspectNamespaceCommand on: self
    ]

    fileoutNamespace [
        <category: 'namespace events'>

	FileoutNamespaceCommand on: self selectedNamespace
    ]
]

