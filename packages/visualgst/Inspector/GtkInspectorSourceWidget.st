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

    doIt [
	<category: 'events'>

	| text |
	text := self buffer getHasSelection 
		    ifTrue: [ | iter |
			    iter := self buffer getSelectionBounds ifNil: [^ self].
			    self buffer getText: (iter at: 1) end: (iter at: 2) includeHiddenChars: false ]
		    ifFalse: [ self buffer text ].
        ^ Behavior
	    evaluate: text
	    to: object
	    ifError: [ :fname :lineNo :errorString | ]
    ]

    printIt [
	<category: 'events'>

	self buffer insertAtCursor: (self doIt displayString) 
    ]

    inspectIt [
	<category: 'events'>

	GtkInspector openOn: self doIt
    ]
]
