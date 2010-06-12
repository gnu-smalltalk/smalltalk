Command subclass: OpenSenderCommand [

    openWithSelection [
        <category: 'focus checking'>

        (GtkLauncher uniqueInstance notebookHasFocus and:
            [ GtkLauncher uniqueInstance onFocusPerform: #hasSelection ])
                ifTrue: [ GtkSender openOn: ( STInST.RBParser selectedSymbol: (GtkLauncher uniqueInstance onFocusPerform: #selectedText)) ]
                ifFalse: [ GtkSender open ]
    ]

    focusChecking [
        <category: 'focus checking'>

        GtkLauncher uniqueInstance browserHasFocus
                    ifTrue: [
                        (GtkLauncher uniqueInstance currentWidgetOfBrowser sourceCodeWidgetHasFocus
                            and: [ GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelection ])
                                                            ifTrue: [
                                                                    GtkSender openOn: ( STInST.RBParser selectedSymbol:
                                                                                                            GtkLauncher uniqueInstance currentWidgetOfBrowser selectedText) ]
                                                            ifFalse: [
                                                                    GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelectedMethod ifTrue: [
                                                                        GtkSender openOn: GtkLauncher uniqueInstance currentWidgetOfBrowser selectedMethodSymbol ]
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

