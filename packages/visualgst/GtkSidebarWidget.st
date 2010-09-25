GtkConcreteWidget subclass: GtkSidebarWidget [
    | activeWidget widgets paned |

    initialize [

	paned := GTK.GtkNotebook new
				setTabPos: GTK.Gtk gtkPosBottom;
				yourself.
	self mainWidget: paned.
	activeWidget := GtkAbstractConcreteWidget new.
	widgets := OrderedCollection new
    ]

    postInitialize [

	self hideAll
    ]

    add: aGtkWidget labeled: aString [

	paned
            appendPage: aGtkWidget tabLabel: (GTK.GtkLabel new: aString).
	widgets add: aGtkWidget
    ]

    addAll: anArray [

	anArray do: [ :each | self add: each key labeled: each value ]
    ]

    show: anIndex [

	activeWidget hideAll.
	self mainWidget showAll.
	self mainWidget setCurrentPage: anIndex - 1.
	activeWidget := (widgets at: anIndex)
					showAll;
					yourself
    ]

    showAll [

	self mainWidget show
    ]

    hideTabs [

	self mainWidget setShowTabs: false
    ]

    hide [

	self hideMainPained
    ]

    hideAll [

	self hideMainPained
    ]

    hideMainPained [

	self mainWidget hideAll
    ]

    panedOrientation [

	^ self subclassResponsibility
    ]
]

