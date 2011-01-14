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

        inspectorTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Variables'}}.
        inspectorTree connectToWhenPopupMenu: (InspectorMenus on: self).
        (model := GtkListModel on: inspectorTree treeView getModel)
                                        contentsBlock: [ :each | {each displayString} ].
        ^ inspectorTree mainWidget
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

        inspectorTree treeView getSelection
            connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedValue [
        <category: 'testing'>

        ^ inspectorTree treeView hasSelectedItem 
    ]

    onVariableChanged [
	<category: 'events'>

	self hasSelectedValue ifFalse: [ workspaceWidget text: ''. ^ self ].
	workspaceWidget text: self selectedValue displayString
    ]

    selectedItem [
	<category: 'item selection'>

        self hasSelectedValue ifFalse: [ self error: 'Nothing is selected' ].
        ^ inspectorTree treeView selection
    ]

    targetObject [

	^ self selectedValue
    ]

    selectedValue [
	<category: 'item selection'>

	^ objectView selectedValue: self selectedItem
    ]

    canDive [
	<category: 'events'>

	^ self hasSelectedValue and: [ self selectedItem ~= 'self' and: [ objectView canDive ] ]
    ]

    isStackEmpty [
	<category: 'events'>

        ^ stack isEmpty
    ]

    dive [
	<category: 'events'>

	stack addFirst: self object.
        self object: self selectedValue
    ]

    back [
	<category: 'events'>

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

        GtkInspector openOn: object
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

