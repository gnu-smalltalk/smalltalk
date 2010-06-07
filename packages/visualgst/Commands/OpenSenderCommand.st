Command subclass: OpenSenderCommand [

    openWithSelection [
        <category: 'focus checking'>

        (VisualGST uniqueInstance notebookHasFocus and:
            [ VisualGST uniqueInstance onFocusPerform: #hasSelection ])
                ifTrue: [ GtkSender openOn: ( STInST.RBParser selectedSymbol: (VisualGST uniqueInstance onFocusPerform: #selectedText)) ]
                ifFalse: [ GtkSender open ]
    ]

    focusChecking [
        <category: 'focus checking'>

        VisualGST uniqueInstance browserHasFocus
                    ifTrue: [
                        (VisualGST uniqueInstance currentWidgetOfBrowser sourceCodeWidgetHasFocus
                            and: [ VisualGST uniqueInstance currentWidgetOfBrowser hasSelection ])
                                                            ifTrue: [
                                                                    GtkSender openOn: ( STInST.RBParser selectedSymbol:
                                                                                                            VisualGST uniqueInstance currentWidgetOfBrowser selectedText) ]
                                                            ifFalse: [
                                                                    VisualGST uniqueInstance currentWidgetOfBrowser hasSelectedMethod ifTrue: [
                                                                        GtkSender openOn: VisualGST uniqueInstance currentWidgetOfBrowser selectedMethodSymbol ]
																      ifFalse: [ GtkSender open ] ] ]
                    ifFalse: [ self openWithSelection ]
    ]

    execute [
        <category: 'command'>

        target
	    ifNotNil: [ GtkSender openOn: target selectedMethodSymbol ]
            ifNil: [ self focusChecking ]
    ]
]

