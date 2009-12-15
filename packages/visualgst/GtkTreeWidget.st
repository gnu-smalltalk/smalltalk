GtkConcreteWidget subclass: GtkTreeWidget [

    | listWidget model |

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildListView
    ]

    buildListView [
        <category: 'user interface'>

	| column |
        listWidget := (GTK.GtkTreeView newWith: self model gtkModel pack: self viewedItems title: self title)
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
			    expandAll;
                            yourself.
        listWidget getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        ^ GTK.GtkScrolledWindow withChild: listWidget 
    ]

    model [
        <category: 'accessing'>

        ^ self subclassResponsibility 
    ]

    sortedColumn [
	<category: 'accessing'>

	^ 0 
    ]

    clear [
	<category: 'model event'>

	self model clear
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
	menu := self buildPopupMenu.
        menu attachToWidget: listWidget detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    hasSelection [
	<category: 'testing'>

	^ listWidget hasSelectedItem
    ]

    selectedIter [
	<category: 'testing'>

        ^ listWidget selectedIter ifNil: [ self error: 'Nothing is selected' ].
    ]

    unselectAll [
        <category: 'selection'>

        listWidget getSelection unselectAll
    ]

    selection [
        <category: 'selection'>

        ^ self model gtkModel at: self selectedIter 
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'selection'>

        listWidget getSelection
            connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    select: anObject [
	<category: 'selection'>

        | selection |
        selection := listWidget getSelection.
        selection unselectAll.
        anObject ifNil: [ ^ self ].
        selection selectIter: (self model findIter: anObject)
    ]

    findIter: anObject [
	<category: 'searching'>

        | result |
        result := self model findIter: anObject.
        listWidget scrollToCell: (self model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        ^ result
    ]

    hasItem: aString [
        <category: 'testing'>

        ^ self model hasItem: aString
    ]

    title [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    viewedItems [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]
]

