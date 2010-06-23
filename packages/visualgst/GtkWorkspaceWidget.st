GtkTextWidget subclass: GtkWorkspaceWidget [
    | variableWidget variableTracker object |
    
    popupMenuOn: aGtkWidget menu: aGtkMenu [
	<category: 'events'>

	| menuitem |
    
	menuitem := GTK.GtkMenuItem new.
	menuitem show.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Do It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #doIt.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Print It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #printIt.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Inspect It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #inspectIt.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Debug It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #debugIt.
	aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Show/Hide workspace variable(s)'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #showIVar.
        aGtkMenu append: menuitem.
    ]

    initialize [
	<category: 'intialization'>

	variableTracker := (WorkspaceVariableTracker new)
				initialize;
				yourself.
	object := variableTracker objectClass new.
	super initialize.
    ]

    postInitialize [
        <category: 'initialize'>

	variableWidget hideAll.
	super postInitialize
    ]

    buildWidget [
        <category: 'user interface'>

        ^ (GTK.GtkHPaned new)
		    add1: (variableWidget := GtkVariableTrackerWidget on: object) mainWidget;
		    add2: super buildWidget;
                    yourself
    ]

    object: anObject [
	<category: 'evaluation'>

        variableTracker := nil.
        object := anObject printNl.
    ]

    targetObject [
	<category: 'evaluation'>

        ^ object
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>

	| text nodes |
        variableTracker isNil ifTrue: [^self].
	text := self selectedText.
	nodes := STInST.RBParser parseExpression: text onError: [ :s :p | self error: s ].
	variableTracker visitNode: nodes
    ]

    afterEvaluation [
        <category: 'smalltalk event'>

	variableWidget refresh
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand on: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand on: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand on: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand on: self
    ]

    showIVar [
	<category: 'smalltalk event'>

	variableWidget mainWidget getVisible 
		ifFalse: [ variableWidget showAll ]
		ifTrue: [ variableWidget hideAll ].
    ]

]
