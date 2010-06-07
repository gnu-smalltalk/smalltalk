GtkBrowserWrapper subclass: GtkSender [
    GtkSender class [ | LiteralsAndSpecialSelectors | ]

    GtkSender class >> literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^ LiteralsAndSpecialSelectors ifNil: [
            LiteralsAndSpecialSelectors := Dictionary new.
            [ CompiledMethod allInstancesDo: [ :each |
                each literalsAndSpecialSelectorsDo: [ :lit |
		    lit isSymbol 
			ifTrue: [ (LiteralsAndSpecialSelectors at: lit ifAbsentPut: [ OrderedCollection new ]) add: each ]
			ifFalse: [  "lit isClass ifTrue: [ lit displayString printNl.
					    (LiteralsAndSpecialSelectors at: lit displayString asSymbol ifAbsentPut: [ OrderedCollection new ]) add: each ]" ]
				 ] ] ] fork.
            LiteralsAndSpecialSelectors ]
    ]

    | currentMethod senderResults |

    selector: aSymbol [
	<category: 'accessor'>

        selector := aSymbol.
        self resultModel clear.
	self findInMethod: (imageWidget matchSelector: aSymbol) values first element.
    ]

    windowTitle [
	^ 'Senders'
    ]

    aboutTitle [
	^ 'About Sender'
    ]

    findInMethod: anObject [
	<category: 'find'>

	| to |	
	senderResults := Dictionary new.
	(self literalsAndSpecialSelectors at: anObject displaySymbol ifAbsent: [ #() ] ) do: [ :each |
	    self resultModel appendItem: {each displayString}.
	    senderResults at: each displayString put: each ].
    ]

    literalsAndSpecialSelectors [
	<category: 'accessing'>

	^ self class literalsAndSpecialSelectors
    ]

    resultSelected [
	<category: 'sender events'>

	| count iter path selectedIter selectedString string |
        (selectedIter := resultTree selectedIter) ifNil: [ ^ self ].
        selectedString := (self resultModel getOop: selectedIter column: 0).
	currentMethod := senderResults at: selectedString ifAbsent: [ ^ self error: selectedString, 'not in the list' ].

        classBrowserWidget
                selectANamespace: currentMethod methodClass environment;
                selectAClass: (currentMethod methodClass isClass ifTrue: [ currentMethod methodClass ] ifFalse: [ currentMethod methodClass instanceClass ]).
        currentMethod methodClass isClass
                ifTrue: [ classBrowserWidget selectAnInstanceMethod: currentMethod selector ]
                ifFalse: [ classBrowserWidget selectAClassMethod: currentMethod selector  ]
    ]

]

