GtkConcreteWidget subclass: GtkImageWidget [

    | imageTree image model searchEntry |


    initialize [
	<category: 'initialization'>

	self mainWidget: self buildMainWidget
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
			    connectSignal: 'activate' to: self selector: #searchValidate;
			    yourself.
        ^ (GTK.GtkHBox new: true spacing: 3)
            add: (GTK.GtkLabel new: 'Class or method :');
            add: searchEntry;
            yourself
    ]

    buildClassAndMethodList [
        <category: 'user interface'>

        imageTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Methods and Classes'}}).
        imageTree setSearchEntry: searchEntry.
        [ (model := GtkListModel on: imageTree getModel)
					item: (image := GtkImage new);
                                        contentsBlock: [ :each | {each displayString} ];
					refresh ] fork.
        ^ GTK.GtkScrolledWindow withChild: imageTree
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        imageTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    whenTextChangedSend: aSelector to: anObject [
	<category: 'events'>

        searchEntry connectSignal: 'activate' to: anObject selector: aSelector
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

	searchEntry getText isEmpty 
		    ifTrue: [ model item: image ]
		    ifFalse: [ model item: (image matchRegex: searchEntry getText) ].
	model refresh
    ]

    hasSelection [
	<category: 'accessing'>

	^ imageTree hasSelectedItem
    ]

    selection [
	<category: 'accessing'>

        self hasSelection ifFalse: [ ^ self error: 'Nothing is selected' ].
        ^ imageTree selection
    ]

    matchSelector: aSymbol [
	<category: 'matching'>

	^ image matchSelector: aSymbol
    ]
]

