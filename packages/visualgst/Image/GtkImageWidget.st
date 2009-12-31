GtkConcreteWidget subclass: GtkImageWidget [
    | imageTree model searchEntry |

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildMainWidget
    ]

    model [
        <category: 'accessing'>

        ^ model ifNil: [ model := GtkImageModel current ]
    ]

    buildMainWidget [
        <category: 'user interface'>

        ^ GTK.GtkVPaned new
            add1: self buildFinderEntry;
            add2: self buildClassAndMethodList;
            yourself
    ]

    buildFinderEntry [
        <category: 'user interface'>

        searchEntry := GTK.GtkEntry new
			    connectSignal: 'activate' to: self selector: #searchValidate userData: nil;
			    yourself.
        ^ (GTK.GtkHBox new: true spacing: 3)
            add: (GTK.GtkLabel new: 'Class or method :');
            add: searchEntry;
            yourself
    ]

    buildClassAndMethodList [
        <category: 'user interface'>

        imageTree := GTK.GtkTreeView newWithSortedTextColumn: self model gtkModel title: 'Methods and Classes'.
        self model isSorted ifFalse: [
            (imageTree getColumn: 0) signalEmitByName: 'clicked' args: {}.
            self model isSorted: true ].
        imageTree setSearchEntry: searchEntry.
        ^ GTK.GtkScrolledWindow withChild: imageTree
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        imageTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    whenTextChangedSend: aSelector to: anObject [
	<category: 'events'>

        searchEntry connectSignal: 'activate' to: anObject selector: aSelector userData: nil
    ]

    grabFocus [
	<category: 'focus events'>

	searchEntry grabFocus
    ]

    text [
	<category: 'accessing'>

	^ searchEntry getText
    ]

    searchValidate [
	<category: 'search entry events'>

        searchEntry getText isEmpty ifTrue: [ ^ imageTree setModel: (model := GtkImageModel current) gtkModel ].
        imageTree setModel: (model := (GtkImageModel current matchRegex: searchEntry getText)) gtkModel
    ]

    selection [
	<category: 'accessing'>

        | iter string |
        (iter := imageTree selectedIter) ifNil: [ ^ self error: 'Nothing is selected' ].
        ^ (self model gtkModel at: iter) first
    ]
]

