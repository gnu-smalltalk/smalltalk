GtkFindWidget subclass: GtkReplaceWidget [
    | replaceWidget replaceButton replaceAllButton |

    replaceEntry [
	<category: 'user interface'>

	^ replaceWidget := GTK.GtkEntry new
			    connectSignal: 'activate' to: self selector: #replacePressed;
			    yourself
    ]

    replaceButton [
        <category: 'user interface'>

	^ replaceButton := (GTK.GtkButton newWithLabel: 'Replace')
			    connectSignal: 'clicked' to: self selector: #replacePressed;
			    yourself
    ]

    replaceAllButton [
        <category: 'user interface'>

	^ replaceAllButton := (GTK.GtkButton newWithLabel: 'Replace All')
			    connectSignal: 'clicked' to: self selector: #replaceAllPressed;
			    yourself
    ]

    replaceBox [
        <category: 'user interface'>

	| hBox |
	^ (GTK.GtkHBox new: false spacing: 3)
            packStart: (GTK.GtkLabel new: 'Replace with:') expand: false fill: false padding: 2;
            packStart: self replaceEntry expand: false fill: false padding: 15;
	    packStart: self replaceButton expand: false fill: false padding: 15;
            packStart: self replaceAllButton expand: false fill: false padding: 15;
	    yourself
    ]

    buildWidget [
	<category: 'user interface'>

	^ super buildWidget
	    packStart: self replaceBox expand: false fill: false padding: 0;
	    yourself

    ]

    replacePressed [
	<category: 'replace events'>

	| i iter |
	self keyPressed.
	textWidget hasSelection ifFalse: [ ^ self ].
	i := textWidget iterOfSelectedText first getOffset.
	textWidget cut.
	iter := textWidget buffer getIterAtOffset: i.
	textWidget buffer insertInteractive: iter text: replaceWidget getText len: replaceWidget getText size defaultEditable: true
    ]

    replaceAllPressed [
        <category: 'replace events'>

	"matching doesn't work now"
	textWidget replace: entry getText by: replaceWidget getText
    ]
]

