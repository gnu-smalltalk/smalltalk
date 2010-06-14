GtkConcreteWidget subclass: GtkCategorizedNamespaceWidget [
    | namespacesTree model |

    initialize [
        <category: 'initialization'>

        self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'classRecategorizedEvent:'
    ]

    buildTreeView [
        <category: 'user interface'>

        namespacesTree := (GTK.GtkTreeView createTreeWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Namespaces'}})
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
                            yourself.
        namespacesTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkTreeModel on: namespacesTree getModel)
                                        item: FakeNamespace;
                                        childrenBlock: [ :each | (each subspaces asArray sort: [ :a :b | a name <= b name ]), (each categories values sort: [ :a :b | a name <= b name ]) ];
                                        contentsBlock: [ :each | {each icon. each name asString} ];
					connectSignal: 'row-has-child-toggled' to: self selector: #'childToggled:path:iter:';
					refresh.
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
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    selectANamespace: aNamespace [
        <category: 'item selection'>

	namespacesTree select: aNamespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ namespacesTree hasSelectedItem
    ]

    selectedNamespace [
        <category: 'accessing'>

	self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
	^ namespacesTree selection namespace
    ]

    selectedCategory [
        <category: 'accessing'>

        self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
        ^ namespacesTree selection category fullname
    ]

    childToggled: model path: path iter: iter [
	<category: 'signals'>

	namespacesTree collapseRow: path.
	((model at: iter) at: 3) isNamespace ifTrue: [
	    ((model at: iter) at: 3) subspaces isEmpty ifFalse: [
		namespacesTree expandRow: path openAll: false ] ]
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

        FileoutNamespaceCommand on: self
    ]

    addEvent: anEvent [
        <category: 'model event'>

	model append: anEvent item parent: anEvent item superspace
    ]

    removeEvent: anEvent [
        <category: 'model event'>

        model remove: anEvent item
    ]

    classRecategorizedEvent: anEvent [
        <category: 'model event'>

        | namespace root toAdd |
        namespace := anEvent item environment.
        root := ClassCategory named: anEvent item category into: namespace.
	(model hasItem: root) ifTrue: [ ^ self ].
	[ root parent isNil or: [ (model hasItem: root) ] ] whileFalse: [ 
					toAdd := root.
					root := root parent ].
	root parent ifNil: [ root := namespace ].
	model append: toAdd parent: root
    ]
]

