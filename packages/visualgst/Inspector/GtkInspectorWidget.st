GtkConcreteWidget subclass: GtkInspectorWidget [
    | inspector model object inspectorTree workspaceWidget objectView stack |

    GtkInspectorWidget >> openOn: anObject [
	<category: 'instance creation'>

	^ (super new)
	    initialize;
	    object: anObject;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	stack := OrderedCollection new.
	self mainWidget: self buildView.
	self whenSelectionChangedSend: #onVariableChanged to: self.
    ]

    postInitialize [
	<category: 'initialization'>

	workspaceWidget postInitialize
    ]

    inspector: aGtkInspector [
	<category: 'accessing'>

	inspector := aGtkInspector	
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	objectView := object inspectorView openOn: anObject.
	workspaceWidget object: anObject.
	inspector isNil ifFalse: [ inspector object: anObject ].
	model 
	    item: objectView;
	    refresh
    ]

    buildTreeWidget [
	<category: 'user interface'>

        inspectorTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Variables'}})
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
        (model := GtkListModel on: inspectorTree getModel)
                                        contentsBlock: [ :each | {each displayString} ].
        ^ GTK.GtkScrolledWindow withChild: inspectorTree
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkWorkspaceWidget new)
			    initialize;
			    showAll;
			    yourself
    ]

    buildView [
        <category: 'user interface'>
   
	^ GTK.GtkHPaned new
	    pack1: self buildTreeWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: true shrink: false;
            yourself
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        inspectorTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedValue [
        <category: 'testing'>

        ^ inspectorTree hasSelectedItem 
    ]

    onVariableChanged [
	<category: 'events'>

	self hasSelectedValue ifFalse: [ workspaceWidget text: ''. ^ self ].
	workspaceWidget text: self selectedValue displayString
    ]

    selectedItem [
	<category: 'item selection'>

        self hasSelectedValue ifFalse: [self error: 'Nothing is selected'].
        ^ inspectorTree selection
    ]

    selectedValue [
	<category: 'item selection'>

	^ objectView selectedValue: self selectedItem
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Open a new Inspector'. self. #newInspector}.
            {}.
            {'Dive'. self. #dive}.
	    {'Back'. self. #back}.
            {}.
            {'File out object'. self. #fileoutObject}}.
        menu attachToWidget: inspectorTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    newInspector [
	<category: 'events'>

	GtkInspector openOn: self selectedValue
    ]

    dive [
	<category: 'events'>

	(self selectedItem = 'self' or: [ objectView canDive not ]) ifTrue: [ ^ self ].
	stack addFirst: self object.
        self object: self selectedValue
    ]

    back [
	<category: 'events'>

	stack isEmpty ifTrue: [ ^ self ].
	self object: stack removeFirst
    ]

    doIt: object [
        <category: 'smalltalk event'>

        workspaceWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        workspaceWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        workspaceWidget inspectIt: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        workspaceWidget printIt: object
    ]

    copy [
        <category: 'text editing'>

	workspaceWidget copy
    ]

    cut [
        <category: 'text editing'>

	workspaceWidget cut
    ]

    paste [
        <category: 'text editing'>

	workspaceWidget paste
    ]

    selectAll [
        <category: 'text editing'>

	workspaceWidget selectAll
    ]
 
    hasSelection [
	<category:'text testing'>

	^ workspaceWidget hasSelection
    ]
 
    selectedText [
	<category: 'text editing'>

	^ workspaceWidget selectedText
    ]

]

