GtkConcreteWidget subclass: GtkNotebookWidget [
    | currentWidget notebook pages |

    initialize [
	<category: 'initialization'>

	pages := OrderedCollection new.
	self mainWidget: self buildNotebookWidget
    ]

    buildNotebookWidget [
	<category: 'user interface'>

        ^ notebook := GTK.GtkNotebook new
			    connectSignal: 'switch-page'
			    to: self
			    selector: #'switchPageOn:page:number:'
			    userData: nil;
			    setShowTabs: false;
			    yourself
    ]

    addWidget: aWidget labeled: aString [
	<category: 'user interface'>

	self addWidget: aWidget labelWidget: (self buildLabelWidget: aString withIcon: GTK.Gtk gtkStockClose at: aWidget)
    ]

    addPermanentWidget: aWidget labeled: aString [
        <category: 'user interface'>

	self addWidget: aWidget labelWidget: (GTK.GtkLabel new: aString)
    ]

    addWidget: aWidget labelWidget: aLabelWidget [
	<category: 'user interface'>

	currentWidget ifNil: [ currentWidget := aWidget ].
        pages addLast: aWidget.
        notebook
            appendPage: aWidget mainWidget tabLabel: aLabelWidget.
        pages size > 1 ifTrue: [ notebook setShowTabs: true ]
    ]

    buildLabelWidget: aString withIcon: aStockString at: aSmallInteger [
        <category: 'user interface'>

        | image close |
        image := GTK.GtkImage newFromStock: aStockString size: GTK.Gtk gtkIconSizeMenu.
        close := (GTK.GtkButton new)
                    setImage: image;
                    setRelief: GTK.Gtk gtkReliefNone;
                    connectSignal: 'pressed' to: self selector: #'closeIt:at:' userData: aSmallInteger;
                    yourself.
        ^ (GTK.GtkHBox new: false spacing: 0)
            add: (GTK.GtkLabel new: aString);
            add: close;
            showAll;
            yourself
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
        <category: 'notebook events'>

        currentWidget := pages at: anInteger + 1
    ]

    closeIt: aGtkButton  at: aGtkConcreteWidget [
        <category: 'notebook events'>

        | pageNb |
        pageNb := notebook pageNum: aGtkConcreteWidget mainWidget.
	aGtkConcreteWidget close.
        pages remove: aGtkConcreteWidget.
        notebook removePage: pageNb.
	pages size = 1 ifTrue: [ notebook setShowTabs: false ]
    ]

    currentWidget [
	<category: 'accessing'>

	^ currentWidget
    ]

    currentPage [
	<category: 'pages'>

	^ notebook getCurrentPage
    ]

    currentPage: aSmallInteger [
	<category: 'pages'>

	notebook setCurrentPage: aSmallInteger
    ]

    numberOfPages [
	<category: 'pages'>

	^ notebook getNPages
    ]

    closeCurrentPage [
	<category: 'pages'>

	self numberOfPages = 1 ifTrue: [ ^ self ].
        pages removeAtIndex: self currentPage + 1.
	notebook removePage: self currentPage.
	pages size = 1 ifTrue: [ notebook setShowTabs: false ]
    ]
]

