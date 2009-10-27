GtkConcreteWidget subclass: GtkWorkspaceWidget [
    | textview variableTracker object |
    
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

	self mainWidget: self buildTextView.
	variableTracker := (WorkspaceVariableTracker new)
				initialize;
				yourself.
	object := variableTracker objectClass new
    ]

    buildTextView [
	<category: 'user interface'>

	textview := (GtkTextWidget newWithBuffer: GTK.GtkTextBuffer new)
			initialize;
			connectSignal: 'populate-popup' to: self selector: #'popupMenuOn:menu:' userData: nil;
			yourself.
	^ GTK.GtkScrolledWindow withChild: textview
    ]

    text: aString [
	<category: 'text accessing'>

	textview getBuffer setText: aString
    ]

    text [
	<category: 'text accessing'>

	^ textview getBuffer text
    ]

    selectedText [
	<category: 'text accessing'>

	^ textview getBuffer selectedText
    ]

    iterOfSelectedText [
	<category: 'text accessing'>

	^ textview getBuffer iterOfSelectedText
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
	textview getBuffer insertInteractive: iter text: result len: result size defaultEditable: true.
	start := textview getBuffer getIterAtOffset: (iter getOffset - result size).
	end := textview getBuffer getIterAtOffset: (iter getOffset).
	textview getBuffer selectRange: start bound: end
    ]

    inspectIt [
	<category: 'events'>

	GtkInspector openOn: self doIt
    ]

    cancel [
        <category: 'edit events'>

        self undo
    ]

    undo [
        <category: 'edit events'>

        textview undo
    ]

    redo [
        <category: 'edit events'>

        textview redo
    ]

    copy [
        <category: 'text editing'>

        textview signalEmitByName: 'copy-clipboard' args: {}
    ]

    cut [
        <category: 'text editing'>

        textview signalEmitByName: 'cut-clipboard' args: {}
    ]

    paste [
        <category: 'text editing'>

        textview signalEmitByName: 'paste-clipboard' args: {}.
    ]

    selectAll [
        <category: 'text editing'>

        textview signalEmitByName: 'select-all' args: {true}.
    ]

    textview [
	<category: 'accessing'>

	^ textview
    ]
]
