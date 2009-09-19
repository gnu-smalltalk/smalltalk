Smalltalk.Object subclass: GtkConcreteWidget [
    | child parentWindow |

    GtkConcreteWidget class >> showAll [
	<category: 'instance creation'>

	^ self new
	    initialize;
	    showAll;
	    yourself
    ]

    parentWindow: aGtkWindow [
        <category: 'accessing'>

        parentWindow := aGtkWindow
    ]
    
    parentWindow [
	<category: 'accessing'>

	^ parentWindow
    ]

    mainWidget [
	<category: 'accessing'>

	^ child
    ]

    mainWidget: aGtkWidget [
	<category: 'accessing'>

	child ifNotNil: [child hideAll].
	child := aGtkWidget
    ]

    showAll [
	<category: 'user interface'>

	child showAll
    ]

    hasFocus [
	<category: 'testing'>

	^ child focusChildFor: self parentWindow
    ]

    grabFocus [
	<category: 'user interface'>

    ]

    close [
	<category: 'user interface'>
    ]
]
