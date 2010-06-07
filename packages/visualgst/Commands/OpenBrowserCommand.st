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
	VisualGST uniqueInstance currentWidgetOfBrowser hasSelectedClass
                ifTrue: [ result := VisualGST uniqueInstance currentWidgetOfBrowser selectedNamespace -> VisualGST uniqueInstance currentWidgetOfBrowser selectedClass ]
                ifFalse: [ VisualGST uniqueInstance currentWidgetOfBrowser hasSelectedNamespace 
				    ifTrue: [ result := VisualGST uniqueInstance currentWidgetOfBrowser selectedNamespace -> nil ]
				    ifFalse: [ result := Smalltalk -> Object ] ].
	^ result 
    ]

    extractFromSelection [
	<category: ''>

	| result |
        (VisualGST uniqueInstance notebookHasFocus and:
            [ VisualGST uniqueInstance onFocusPerform: #hasSelection ])
                ifTrue: [ result := self extractNamespaceAndClassFrom: (VisualGST uniqueInstance onFocusPerform: #selectedText)]
                ifFalse: [ result := Smalltalk->Object ].
	^ result
    ]

    selection [
	<category: 'accessing'>

        ^ VisualGST uniqueInstance browserHasFocus
                    ifTrue: [
                        (VisualGST uniqueInstance currentWidgetOfBrowser sourceCodeWidgetHasFocus and: [ VisualGST uniqueInstance currentWidgetOfBrowser hasSelection ])
                                                            ifTrue: [ self extractNamespaceAndClassFrom: VisualGST uniqueInstance currentWidgetOfBrowser selectedText ]
                                                            ifFalse: [ self extractSelectedItems ] ]
                    ifFalse: [ self extractFromSelection ]
    ]
]

