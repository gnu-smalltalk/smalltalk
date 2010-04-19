GtkConcreteWidget subclass: GtkTranscriptWidget [
    | textview |
    
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
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Clear'.
        menuitem 
	    show;
	    connectSignal: 'activate' to: self selector: #clear userData: nil.
        aGtkMenu append: menuitem.
    ]

    initialize [
	<category: 'initialization'>

	Transcript message: self->#update:.
	self mainWidget: self buildTextView
    ]

    update: aString [
	<category: 'updating'>

	textview getBuffer insertAtEnd: aString displayString
    ]

    clear [
	<category: 'updating'>

	textview getBuffer setText: ''
    ]

    buildTextView [
	<category: 'user interface'>

	textview := (GTK.GtkTextView newWithBuffer: GTK.GtkTextBuffer new)
	    setEditable: false;
	    connectSignal: 'populate-popup' to: self selector: #popupMenuOn:menu: userData: nil;
	    yourself.

	^ GTK.GtkScrolledWindow withChild: textview
    ]

    text [
	<category: 'text accessing'>

	^ textview getBuffer text
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
