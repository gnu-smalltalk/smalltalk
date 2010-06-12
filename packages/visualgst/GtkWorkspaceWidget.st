GtkTextWidget subclass: GtkWorkspaceWidget [
    | variableTracker object |
    
    popupMenuOn: aGtkWidget menu: aGtkMenu [
	<category: 'events'>

	| menuitem |
    
	menuitem := GTK.GtkMenuItem new.
	menuitem show.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Do It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #doIt userData: nil.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Print It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #printIt userData: nil.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Inspect It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #inspectIt userData: nil.
	aGtkMenu append: menuitem.
	menuitem := GTK.GtkMenuItem newWithLabel: 'Debug It'.
	menuitem
	    show;
	    connectSignal: 'activate' to: self selector: #debugIt userData: nil.
	aGtkMenu append: menuitem
    ]

    initialize [
	<category: 'intialization'>

	super initialize.
	variableTracker := (WorkspaceVariableTracker new)
				initialize;
				yourself.
	object := variableTracker objectClass new.
    ]

    targetObject [
	<category: 'evaluation'>

        ^object
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>

	| text nodes |
	text := self selectedText.
	nodes := STInST.RBParser parseExpression: text onError: [ :s :p | self error: s ].
	variableTracker visitNode: nodes.
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
]
