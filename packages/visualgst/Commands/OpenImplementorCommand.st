Command subclass: OpenImplementorCommand [

    openWithSelection [
	<category: 'focus checking'>


        (VisualGST uniqueInstance notebookHasFocus and:
	    [ VisualGST uniqueInstance onFocusPerform: #hasSelection ])
                ifTrue: [ self openImplementorOn: ( STInST.RBParser selectedSymbol: (VisualGST uniqueInstance onFocusPerform: #selectedText)) ]
                ifFalse: [ GtkImplementor open ]
    ]

    focusChecking [
	<category: 'focus checking'>

	VisualGST uniqueInstance browserHasFocus
                    ifTrue: [
                        (VisualGST uniqueInstance currentWidgetOfBrowser sourceCodeWidgetHasFocus 
			    and: [ VisualGST uniqueInstance currentWidgetOfBrowser hasSelection ])
                                                            ifTrue: [
								    self openImplementorOn: ( STInST.RBParser selectedSymbol: 
													    VisualGST uniqueInstance currentWidgetOfBrowser selectedText) ]
                                                            ifFalse: [ 
								    VisualGST uniqueInstance currentWidgetOfBrowser hasSelectedMethod ifTrue: [
									self openImplementorOn: VisualGST uniqueInstance currentWidgetOfBrowser selectedMethodSymbol ]
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

