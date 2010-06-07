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

    doIt [
	<category: 'events'>

	| text nodes |
	text := self selectedText.
	nodes := STInST.RBParser parseExpression: text onError: [ :s :p | self error: s ].
	variableTracker visitNode: nodes.
        ^ Behavior
	    evaluate: text
	    to: object
	    ifError: [ :fname :lineNo :errorString | self error: errorString ]
    ]

    debugIt [
	<category: 'events'>

	| nodes |
        nodes := STInST.RBParser parseExpression: self selectedText onError: [ :s :p | self error: s ].
        variableTracker visitNode: nodes.
	object class 
	    compile: ('Doit [ ^ [ ', self selectedText , ' ] value ]')
	    ifError:  [ :fname :lineNo :errorString | 
		self error: errorString ].
	(GtkDebugger open)
	    doItProcess: [ object perform: #Doit ] newProcess
    ]

    printIt [
	<category: 'events'>

	| iter start end result |
	iter := self iterOfSelectedText second.
	result := ' ', (self doIt displayString), ' '.
	self buffer insertInteractive: iter text: result len: result size defaultEditable: true.
	start := self buffer getIterAtOffset: (iter getOffset - result size).
	end := self buffer getIterAtOffset: (iter getOffset).
	self buffer selectRange: start bound: end
    ]

    inspectIt [
	<category: 'events'>

	GtkInspector openOn: self doIt
    ]

    cancel [
        <category: 'edit events'>

        self undo
    ]
]
