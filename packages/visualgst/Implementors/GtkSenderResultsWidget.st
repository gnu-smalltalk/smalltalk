GtkImageResultsWidget subclass: GtkSenderResultsWidget [

    GtkSenderResultsWidget class [ | LiteralsAndSpecialSelectors | ]

    GtkSenderResultsWidget class >> literalsAndSpecialSelectors [
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

    buildTreeView [
        <category: 'user interface'>

	| widget |
	widget := super buildTreeView.
	model contentsBlock: [ :each | {each displayString} ].
	^ widget
    ]

    appendSenderResults: aDictionary [

	self
	    clear;
	    findInMethod: aDictionary values first element
    ]

    literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^  self class literalsAndSpecialSelectors
    ]

    findInMethod: anObject [
        <category: 'find'>

        (self literalsAndSpecialSelectors at: anObject displaySymbol ifAbsent: [ #() ] ) do: [ :each |
            model append: each ].
    ]

    selectedResult: aBrowser [

        | currentMethod |
	self hasSelectedResult ifFalse: [ ^ self ].
        currentMethod := self selectedResult.

        aBrowser
                selectANamespace: currentMethod methodClass environment;
                selectAClass: (currentMethod methodClass isClass ifTrue: [ currentMethod methodClass ] ifFalse: [ currentMethod methodClass instanceClass ]).
        currentMethod methodClass isClass
                ifTrue: [ aBrowser selectAnInstanceMethod: currentMethod selector ]
                ifFalse: [ aBrowser selectAClassMethod: currentMethod selector  ]
    ]
]

