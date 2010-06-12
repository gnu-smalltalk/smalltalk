Command subclass: OpenImplementorCommand [

    openWithSelection [
	<category: 'focus checking'>


        (GtkLauncher uniqueInstance notebookHasFocus and:
	    [ GtkLauncher uniqueInstance onFocusPerform: #hasSelection ])
                ifTrue: [ self openImplementorOn: ( STInST.RBParser selectedSymbol: (GtkLauncher uniqueInstance onFocusPerform: #selectedText)) ]
                ifFalse: [ GtkImplementor open ]
    ]

    focusChecking [
	<category: 'focus checking'>

	GtkLauncher uniqueInstance browserHasFocus
                    ifTrue: [
                        (GtkLauncher uniqueInstance currentWidgetOfBrowser sourceCodeWidgetHasFocus 
			    and: [ GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelection ])
                                                            ifTrue: [
								    self openImplementorOn: ( STInST.RBParser selectedSymbol: 
													    GtkLauncher uniqueInstance currentWidgetOfBrowser selectedText) ]
                                                            ifFalse: [ 
								    GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelectedMethod ifTrue: [
									self openImplementorOn: GtkLauncher uniqueInstance currentWidgetOfBrowser selectedMethodSymbol ]
																      ifFalse: [ GtkImplementor open ] ] ]
                    ifFalse: [ self openWithSelection ]
    ]

    execute [
        <category: 'command'>

        target
            ifNotNil: [ self openImplementorOn: target selectedMethodSymbol ]
            ifNil: [ self focusChecking ]
    ]

    openImplementorOn: aSymbol [
        <comment: 'I check the symbol for nil'>
        aSymbol
            ifNotNil: [ GtkImplementor openOn: aSymbol ]
            ifNil: [ GtkImplementor open ]
    
    ]
]

