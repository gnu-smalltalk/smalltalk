GtkConcreteWidget subclass: GtkSidebarWidget [
    | activeWidget widgets widgetEvents paned |

    initialize [
	<category: 'initialization'>

	paned := GTK.GtkNotebook new
				setTabPos: GTK.Gtk gtkPosBottom;
				connectSignal: 'switch-page' to: self selector: #'switchPageOn:page:number:';
				yourself.
	self mainWidget: paned.
	widgetEvents := Dictionary new.
	activeWidget := GtkAbstractConcreteWidget new.
	widgets := OrderedCollection new
    ]

    postInitialize [
	<category: 'initialization'>

	self hideAll
    ]

    add: aGtkWidget labeled: aString [
	<category: 'notebook'>

	paned
            appendPage: aGtkWidget tabLabel: (GTK.GtkLabel new: aString).
	widgets add: aGtkWidget
    ]

    addAll: anArray [
	<category: 'notebook'>

	anArray do: [ :each | self add: each key labeled: each value ]
    ]

    show: anIndex [
	<category: 'notebook'>

	activeWidget hideAll.
	self mainWidget showAll.
	self mainWidget setCurrentPage: anIndex - 1.
	activeWidget := (widgets at: anIndex)
					showAll;
					yourself
    ]

    showAll [
	<category: 'notebook'>

	self mainWidget show
    ]

    hideTabs [
	<category: 'notebook'>

	self mainWidget setShowTabs: false
    ]

    hide [
	<category: 'notebook'>

	self hideMainPained
    ]

    hideAll [
	<category: 'notebook'>

	self hideMainPained
    ]

    hideMainPained [
	<category: 'notebook'>

	self mainWidget hideAll
    ]

    panedOrientation [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
        <category: 'notebook events'>

	widgetEvents at: (aGtkNotebook getNthPage: anInteger) ifPresent: [ :msg | msg value ]
    ]

    whenWidgetIsVisible: aGtkWidget send: aSymbol to: anObject [
	<category: 'notebook events'>

	widgetEvents at: aGtkWidget put: (DirectedMessage receiver: anObject selector: aSymbol arguments: #())
    ]
]

