GtkAbstractConcreteWidget subclass: GtkConcreteWidget [
    | child parentWindow |

    GtkConcreteWidget class >> parentWindow: aGtkWindow [
	<category: 'instance creation'>

        ^ self new
            parentWindow: aGtkWindow;
            initialize;
            yourself
    ]

    GtkConcreteWidget class >> showAll [
	<category: 'instance creation'>

	^ self new
	    initialize;
	    showAll;
	    yourself
    ]

    initialize [
	<category: 'initialize'>

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

	child ifNotNil: [ child hideAll  ].
	child := aGtkWidget
    ]

    showAll [
	<category: 'user interface'>

	child showAll
    ]

    hideAll [
	<category: 'user interface'>

	child hideAll
    ]

    isVisible [
	<category: 'testing'>

	^ child getVisible
    ]

    hasFocus [
	<category: 'testing'>

        | parent current |
        parent := child.
        [ (current := parent getFocusChild) notNil ] whileTrue: [
            parent := current ].
        ^ self parentWindow getFocus = parent

    ]

    focusedWidget [
	<category: 'focus'>

        self hasFocus ifTrue: [ ^ self ].
        ^ nil
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        ^ self focusedWidget perform: aSymbol
    ]

    grabFocus [
	<category: 'user interface'>

    ]

    close [
	<category: 'user interface'>
    ]
]
