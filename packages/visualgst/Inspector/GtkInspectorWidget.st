GtkConcreteWidget subclass: GtkInspectorWidget [
    | object inspectorTree workspaceWidget objectView stack |

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
	self mainWidget: self buildView
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	objectView := object inspectorView openOn: self object.
	inspectorTree setModel: objectView model.
	self refreshModel
    ]

    model [
	<category: 'accessing'>

        ^ objectView ifNil: [
            objectView := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    clearModel [
        <category: 'accessing'>

        self model clear
    ]

    refreshModel [
	<category: 'events'>
  
	self model refreshModel
    ]

    buildTreeWidget [
	<category: 'user interface'>

	inspectorTree := (GTK.GtkTreeView newWithTextColumn: self model title: 'Variables')
			    connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
			    yourself.
	self whenSelectionChangedSend: #onVariableChanged to: self.
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

    hasSelectedClass [
        <category: 'testing'>

        ^ inspectorTree hasSelectedItem 
    ]

    onVariableChanged [
	<category: 'events'>

	self hasSelectedClass ifFalse: [ workspaceWidget text: ''. ^ self ].
	workspaceWidget text: self selectedValue displayString
    ]

    selectedItem [
	<category: 'item selection'>

	| iter |
        (iter := inspectorTree selectedIter) ifNil: [self error: 'Nothing is selected'].
        ^ self model model getOop: iter column: 0
    ]

    selectedValue [
	<category: 'item selection'>

	^ self model selectedValue: self selectedItem
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
            {'Accept'. self. #accept}.
	    {'Cancel'. self. #cancel}.
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

	(self selectedItem = 'self' or: [ self model canDive not ]) ifTrue: [ ^ self ].
	stack addFirst: self object.
	self object: self selectedValue
    ]

    back [
	<category: 'events'>

	stack isEmpty ifTrue: [ ^ self ].
	self object: stack removeFirst
    ]
]

