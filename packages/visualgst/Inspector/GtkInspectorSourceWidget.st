GtkConcreteWidget subclass: GtkInspectorSourceWidget [
    | browser displayBrowserMenu object textview |
    
    GtkInspectorSourceWidget class >> openOn: anObject [
	^ (self new)
	    object: anObject;
	    yourself
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject
    ]

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

	self mainWidget: self buildTextView
    ]

    buildTextView [
	<category: 'user interface'>

	textview := GtkTextWidget new
			initialize;
			connectSignal: 'populate-popup' to: self selector: #'popupMenuOn:menu:' userData: nil;
			yourself.
	^ GTK.GtkScrolledWindow withChild: textview
    ]

    text: aString [
	<category: 'accessing'>

	textview getBuffer setText: aString
    ]

    doIt [
	<category: 'events'>

	| text |
	text := textview getBuffer getHasSelection 
		    ifTrue: [ | iter |
			    iter := textview getBuffer getSelectionBounds ifNil: [^ self].
			    textview getBuffer getText: (iter at: 1) end: (iter at: 2) includeHiddenChars: false ]
		    ifFalse: [ textview getBuffer text ].
        ^ Behavior
	    evaluate: text
	    to: object
	    ifError: [ :fname :lineNo :errorString | "self displayError: errorString at: lineNo + pos" ]
    ]

    printIt [
	<category: 'events'>

	textview getBuffer insertAtCursor: (self doIt displayString) 
    ]

    inspectIt [
	<category: 'events'>

	GtkInspector openOn: self doIt
    ]

    cancel [
        <category: 'buffer events'>

	self undo
    ]

    undo [
        <category: 'buffer events'>

        textview undo
    ]

    redo [
        <category: 'buffer events'>

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

]
