GtkBrowsingTool subclass: GtkBrowserWrapper [

    | classBrowserWidget imageWidget resultArray resultModel resultTree selector |

    GtkBrowserWrapper class >> openOn: aSelector [
        <category: 'instance creation'>

        ^ self open
            selector: aSelector;
            yourself
    ]

    postInitialize [
        <category: 'initialization'>

        classBrowserWidget postInitialize.
        imageWidget grabFocus.
        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]

    resultModel [
        <category: 'model accessing'>

        ^ resultModel ifNil: [
            resultModel := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    buildFinderList [
        <category: 'user interface'>

        ^ (imageWidget := GtkImageWidget new)
                                    initialize;
                                    whenSelectionChangedSend: #elementSelected to: self;
                                    mainWidget
    ]

    buildResultList [
        <category: 'user interface'>

        resultTree := GTK.GtkTreeView newWithSortedTextColumn: self resultModel title: 'Methods and Classes'.
        (resultTree getColumn: 0) signalEmitByName: 'clicked' args: {}.
        resultTree
            getSelection
                connectSignal: 'changed' to: self selector: #resultSelected userData: nil.
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    buildResultAndClassBrowser [
        <category: 'user interface'>

        ^ GTK.GtkVPaned new
            add1: self buildResultList;
            add2: ((classBrowserWidget := GtkClassBrowserWidget new)
                        parentWindow: window;
                        initialize;
                        mainWidget);
            yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

        self selector isNil ifFalse: [ ^ self buildResultAndClassBrowser ].
        ^ (GTK.GtkHPaned new)
            add1: self buildFinderList;
            add2: self buildResultAndClassBrowser;
            yourself
    ]

    elementSelected [
        <category: 'events'>

        imageWidget hasSelection ifFalse: [ ^ self ].
        self selector: imageWidget selection
    ]

    selector [
        <category: 'accessing'>

        ^ selector
    ]

    selector: aSymbol [
        <category: 'accessing'>

        | iter |
        selector := aSymbol.
        self resultModel clear.
        resultArray := imageWidget matchSelector: aSymbol.
        resultArray keysDo: [ :each |
            iter := GTK.GtkTreeIter new.
            self resultModel append: iter parent: nil.
            self resultModel setOop: iter column: 0 value: each ]
    ]

    doIt [
        <category: 'smalltalk events'>

        classBrowserWidget doIt
    ]

    printIt [
        <category: 'smalltalk events'>

        classBrowserWidget printIt
    ]

    inspectIt [
        <category: 'smalltalk events'>

        classBrowserWidget inspectIt
    ]

    debugIt [
        <category: 'smalltalk events'>

        classBrowserWidget debugIt
    ]

    acceptIt [
        <category: 'smalltalk events'>

        classBrowserWidget acceptIt
    ]

    back [
        <category: 'history events'>

        classBrowserWidget back
    ]

    forward [
        <category: 'history events'>

        classBrowserWidget forward
    ]

    cancel [
        <category: 'edit events'>

        classBrowserWidget cancel
    ]

    undo [
        <category: 'edit events'>

        classBrowserWidget undo
    ]

    redo [
        <category: 'edit events'>

        classBrowserWidget redo
    ]

    cut [
        <category: 'edit events'>

        classBrowserWidget cut
    ]

    copy [
        <category: 'edit events'>

        classBrowserWidget copy
    ]

    paste [
        <category: 'edit events'>

        classBrowserWidget paste
    ]

    selectAll [
        <category: 'edit events'>

        classBrowserWidget selectAll
    ]

    hasChanged [
        <category: 'testing'>

        ^ classBrowserWidget hasChanged
    ]
]

