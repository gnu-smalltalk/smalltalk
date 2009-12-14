Object subclass: GtkNamespaceModel [
    | model sorted |

    initialize [
	<category: 'initialize-release'>

	sorted := false.
	self registerNotifier
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(VisualGST uniqueInstance systemChangeNotifier)
	    notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addEvent:';
	    notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeEvent:'
    ]

    isSorted [
	<category: 'testing'>

	^ sorted
    ]

    sorted: aBoolean [
	<category: 'accessing'>
	
	sorted := aBoolean
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    refresh [
	<category: 'model'>

	self gtkModel clear.
	self appendNamespace: Smalltalk to: nil
    ]

    appendNamespace: aNamespace to: parentGtkIter [
	<category: 'model builder'>

	
	| iter |
	iter := self gtkModel append: parentGtkIter item: {aNamespace displayString}.	

	aNamespace subspacesDo: [ :each |
	    self appendNamespace: each to: iter ]
    ]

    findIterInANamespace: aNamespace [
        <category: 'item selection'>

        | iter stack parent path namespace |
        aNamespace = Smalltalk ifTrue: [ ^ self gtkModel getIterFirst ].

        stack := OrderedCollection new.
        namespace := aNamespace.
        [ namespace isNil ] whileFalse: [
            stack addFirst: namespace displayString.
            namespace := namespace superspace ].

        iter := GTK.GtkTreeIter new.
	path := GTK.GtkTreePath newFirst.
        stack do: [ :each |
	    self gtkModel getIter: iter path: path.
            [each = (self gtkModel getOop: iter column: 0)] whileFalse: [
		path next.
		(self gtkModel getIter: iter path: path) ifFalse: [ self error: 'Namespace ', each , ' not found' ] ].
	    path down ].
        ^ iter
    ]

    append: aParentIter column: aSmallInteger value: anObject [
	<category: 'item accessing'>

	| iter |
	iter := GTK.GtkTreeIter new.
	(self gtkModel)
            append: iter parent: aParentIter;
            setOop: iter column: aSmallInteger value: anObject
    ]

    remove: aNamespace [
	<category: 'item removing'>

	 | iter |
        iter := self findIterInANamespace: aNamespace.
        self gtkModel remove: iter
    ]

    addEvent: anEvent [
	<category: 'model event'>

	self
	    append: (self findIterInANamespace: anEvent item superspace)
	    column: 0
	    value: anEvent item displayString
    ]

    removeEvent: anEvent [
	<category: 'model event'>

	self remove: anEvent item
    ]
]

