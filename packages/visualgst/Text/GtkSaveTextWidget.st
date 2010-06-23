GtkTextPluginWidget subclass: GtkSaveTextWidget [ 
    | label |

    buildDropButton [
	<category: 'user interface'>

        ^(GTK.GtkButton newWithLabel: 'Drop')
	    connectSignal: 'pressed' to: self selector: #cancel;
            yourself
    ]

    buildAcceptButton [
        <category: 'user interface'>

        ^(GTK.GtkButton newWithLabel: 'Accept')
	    connectSignal: 'pressed' to: self selector: #acceptIt;
            yourself
    ]

    hBox [
	<category: 'user interface'>

	^ super hBox
	    packStart: (label := GTK.GtkLabel new: '') expand: false fill: false padding: 2;
	    packEnd: self buildAcceptButton expand: false fill: false padding: 0; 
	    packEnd: self buildDropButton expand: false fill: false padding: 0;
	    yourself
    ]

    label: aString [
	<category: 'state'>

	label setText: aString
    ]

    grabFocus [
	<category: 'focus'>

	closeButton grabFocus
    ]

    acceptIt [
	<category: 'events'>

	textWidget acceptIt
    ]

    cancel [
	<category: 'events'>

	textWidget cancel
    ]
]

