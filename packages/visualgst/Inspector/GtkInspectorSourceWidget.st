GtkTextWidget subclass: GtkInspectorSourceWidget [
    | object |
    
    GtkInspectorSourceWidget class >> openOn: anObject [
	<category: 'instance creation'>

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

    targetObject [
	<category: 'smalltalk event'>

	^object
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
