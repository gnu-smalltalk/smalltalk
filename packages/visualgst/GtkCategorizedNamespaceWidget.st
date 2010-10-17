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

	namespacesTree := GtkScrollTreeWidget createTreeWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Namespaces'}}.
	namespacesTree connectToWhenPopupMenu: [ :menu | self buildPopupMenu: menu ].
	namespacesTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(model := GtkTreeModel on: namespacesTree treeView getModel)
                                        item: FakeNamespace;
                                        childrenBlock: [ :each | (each subspaces asArray sort: [ :a :b | a name <= b name ]), (each categories values sort: [ :a :b | a name <= b name ]) ];
                                        contentsBlock: [ :each | {each icon. each name asString} ];
                                        connectSignal: 'row-has-child-toggled' to: self selector: #'childToggled:path:iter:';
                                        refresh.
	^ namespacesTree mainWidget
    ]

    buildPopupMenu: aGtkMenu [
        <category: 'button event'>

        aGtkMenu appendMenuItems: {{'Add a namespace'. self. #newNamespace}.
            {'Rename a namespace'. self. #renameNamespace}.
            {'Delete a namespace'. self. #deleteNamespace}.
            {}.
            {'Inspect a namespace'. self. #inspectNamespace}.
            {}.
            {'File out a namespace'. self. #fileoutNamespace}}
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        namespacesTree treeView getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    selectANamespace: aNamespace [
        <category: 'item selection'>

	namespacesTree treeView select: aNamespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ namespacesTree treeView hasSelectedItem
    ]

    selectedNamespace [
        <category: 'accessing'>

	self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
	^ namespacesTree treeView selection namespace
    ]

    selectedCategory [
        <category: 'accessing'>

        self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
        ^ namespacesTree treeView selection category
    ]

    state [
        <category: 'events'>

        self hasSelectedNamespace ifFalse: [ ^ BrowserState new ].
        ^ (NamespaceState with: self selectedNamespace)
            classCategory: self selectedCategory;
            yourself
    ]

    childToggled: model path: path iter: iter [
	<category: 'signals'>

	namespacesTree treeView collapseRow: path.
	((model at: iter) at: 3) isNamespace ifTrue: [
	    ((model at: iter) at: 3) subspaces isEmpty ifFalse: [
		namespacesTree treeView expandRow: path openAll: false ] ]
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
	(anEvent item category isNil or: [ anEvent item category size = 0 ]) ifTrue: [ ^ self ].
        root := ClassCategory named: anEvent item category into: namespace.
	(model hasItem: root) ifTrue: [ ^ self ].
	[ root parent isNil or: [ (model hasItem: root) ] ] whileFalse: [ 
					toAdd := root.
					root := root parent ].
	root parent ifNil: [ root := namespace ].
	model append: toAdd parent: root
    ]
]

