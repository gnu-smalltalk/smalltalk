Command subclass: OpenBrowserCommand [

    extractSingleToken: aToken [
	<category: 'parsing'>

	| result |
        result := Smalltalk at: aToken asSymbol ifAbsent: [ ^ Smalltalk -> Object ].
        result isClass ifTrue: [ ^ Smalltalk -> result ].
        result isNamespace ifTrue: [ ^ result -> nil ].
        ^ Smalltalk -> Object
    ]

    extractMultipleToken: anArray [
	<category: 'parsing'>

	| start |
        start := Smalltalk.
        anArray do: [ :each |
            start := start at: each asSymbol ifAbsent: [ ^ Smalltalk -> Object ] ].
        start isClass ifTrue: [ ^ start environment -> start ].
        start isNamespace ifTrue: [ ^ start -> nil ].
        ^ Smalltalk -> Object
    ]

    extractNamespaceAndClassFrom: aString [
	<category: 'parsing'>

	| node token start |
	[ node := STInST.RBParser parseExpression: aString ] on: Error do: [ ^ Smalltalk->Object ].
	node isVariable ifFalse: [ ^ Smalltalk->Object ].
	token := node name tokenize: '\.'.
	token size = 1 ifTrue: [ ^ self extractSingleToken: token first ].
	^ self extractMultipleToken: token
    ]

    extractSelectedItems [
	<category: ''>

	| result |
	GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelectedClass
                ifTrue: [ result := GtkLauncher uniqueInstance currentWidgetOfBrowser selectedNamespace -> GtkLauncher uniqueInstance currentWidgetOfBrowser selectedClass ]
                ifFalse: [ GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelectedNamespace 
				    ifTrue: [ result := GtkLauncher uniqueInstance currentWidgetOfBrowser selectedNamespace -> nil ]
				    ifFalse: [ result := Smalltalk -> Object ] ].
	^ result 
    ]

    extractFromSelection [
	<category: ''>

	| result |
        (GtkLauncher uniqueInstance notebookHasFocus and:
            [ GtkLauncher uniqueInstance onFocusPerform: #hasSelection ])
                ifTrue: [ result := self extractNamespaceAndClassFrom: (GtkLauncher uniqueInstance onFocusPerform: #selectedText)]
                ifFalse: [ result := Smalltalk->Object ].
	^ result
    ]

    selection [
	<category: 'accessing'>

        ^ GtkLauncher uniqueInstance browserHasFocus
                    ifTrue: [
                        (GtkLauncher uniqueInstance currentWidgetOfBrowser sourceCodeWidgetHasFocus and: [ GtkLauncher uniqueInstance currentWidgetOfBrowser hasSelection ])
                                                            ifTrue: [ self extractNamespaceAndClassFrom: GtkLauncher uniqueInstance currentWidgetOfBrowser selectedText ]
                                                            ifFalse: [ self extractSelectedItems ] ]
                    ifFalse: [ self extractFromSelection ]
    ]
]

