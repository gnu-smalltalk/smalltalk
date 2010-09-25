GtkConcreteWidget subclass: GtkEntryWidget [

    GtkEntryWidget class >> labeled: aString [
	<category: 'instance creation'>

	^ self new
	    initialize: aString;
	    yourself
    ]

    | entry label |

    initialize: aString [
        <category: 'initialization'>

	label := aString.
        self mainWidget: self buildMainWidget
    ]

    buildMainWidget [
        <category: 'user interface'>

        entry := GTK.GtkEntry new.
        ^ (GTK.GtkHBox new: true spacing: 3)
			add: (GTK.GtkLabel new: label);
			add: entry;
			yourself
    ]

    completion: aGtkEntryCompletion [

	entry setCompletion: aGtkEntryCompletion
    ]

    text [

	^ entry getText
    ]
]

