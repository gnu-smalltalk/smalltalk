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

    connectSignals [
        <category: 'initialization'>

	super connectSignals.
        self
            connectToWhenPopupMenu: (SimpleWorkspaceMenus on: self).
    ]

    targetObject [
	<category: 'smalltalk event'>

	^object
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]
]
