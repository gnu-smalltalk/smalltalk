GtkConcreteWidget subclass: GtkImageResultsWidget [
    | result resultTree model |

    initialize [
        <category: 'initialization'>

        self mainWidget: self buildTreeView
    ]

    buildTreeView [
        <category: 'user interface'>

        resultTree := GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Methods and Classes'}}.
        resultTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: resultTree getModel)
                                        contentsBlock: [ :each | {each asString} ].
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        resultTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    hasSelectedResult [
        <category: 'testing'>

        ^ resultTree hasSelectedItem
    ]

    selectedResult [
        <category: 'accessing'>

        self hasSelectedResult ifFalse: [ ^ self error: 'nothing is selected' ].
        ^ resultTree selection
    ]

    appendResults: aDictionary [

    ]

]

