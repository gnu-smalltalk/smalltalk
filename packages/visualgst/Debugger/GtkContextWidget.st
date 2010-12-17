GtkConcreteWidget subclass: GtkContextWidget [
    | column contextTree model context contextList |

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
	model
	    item: self buildListOfContexts;
	    refresh
    ]

    buildListOfContexts [
	<category: 'model'>

	| ctxt |
	contextList := OrderedCollection new.
        ctxt := context.
        [ ctxt isNil ] whileFalse: [
            contextList add: ctxt.
            ctxt := ctxt parentContext ].
	^ contextList
    ]

    buildTreeView [
        <category: 'user interface'>
    
        contextTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Contexts'}}.
        contextTree connectToWhenPopupMenu: (ContextMenus on: self).
        contextTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: contextTree treeView getModel)
                                        contentsBlock: [ :each | {each printString} ].
        ^ contextTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	contextTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    isLastContextSelected [
        <category: 'item selection'>

	^ self selectedContext == context
    ]

    selectLastContext [
        <category: 'item selection'>

	contextTree treeView selectLastItem
    ]

    selectFirstContext [
        <category: 'item selection'>

	contextTree treeView selectFirstItem
    ]

    hasSelectedContext [
	<category: 'testing'>

	^ contextTree treeView hasSelectedItem
    ]

    selectedContext [
	<category: 'accessing'>


	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
        ^ contextTree treeView selection
    ]

    state [
        <category: 'actions'>

        "TODO: add ContextState."
        contextTree treeView hasSelectedItem ifTrue: [
            ^MethodState with: contextTree treeView selection method method ].
        ^BrowserState new
    ]

    positionOfSelectedContext [
	<category: 'accessing'>

	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
	^ contextList findFirst: [ :each | each == self selectedContext ].
    ]
]

