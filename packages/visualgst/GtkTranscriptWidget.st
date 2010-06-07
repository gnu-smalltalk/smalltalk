GtkTextWidget subclass: GtkTranscriptWidget [
    
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
	super initialize
    ]

    update: aString [
	<category: 'updating'>

	self buffer insertAtEnd: aString
    ]
]
