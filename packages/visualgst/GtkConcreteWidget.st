GtkAbstractConcreteWidget subclass: GtkConcreteWidget [
    | child parentWindow popupMenu |

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

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := popupMenu asPopupMenu.
        menu attachToWidget: self treeView detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    connectToWhenPopupMenu: aMenuBuilder [
	<category: 'user interface'>

	popupMenu := aMenuBuilder.
	^ self treeView connectSignal: 'button-press-event' to: self selector: #'onPress:event:'
    ]

    grabFocus [
	<category: 'user interface'>

    ]

    close [
	<category: 'user interface'>
    ]
]
