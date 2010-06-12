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
    
        contextTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Contexts'}})
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
                            yourself.
        contextTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: contextTree getModel)
                                        contentsBlock: [ :each | {each printString} ].
        ^ GTK.GtkScrolledWindow withChild: contextTree
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Add a method'. self. #newMethod}.
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

	contextTree selectLastItem
    ]

    selectFirstContext [
        <category: 'item selection'>

	contextTree selectFirstItem
    ]

    hasSelectedContext [
	<category: 'testing'>

	^ contextTree hasSelectedItem
    ]

    selectedContext [
	<category: 'accessing'>


	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
        ^ contextTree selection
    ]

    positionOfSelectedContext [
	<category: 'accessing'>

	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
	^ contextList findFirst: [ :each | each == self selectedContext ].
    ]
]

