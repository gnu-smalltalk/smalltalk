GtkImageResultsWidget subclass: GtkImplementorResultsWidget [

    buildTreeView [
        <category: 'user interface'>

	| widget |
	widget := super buildTreeView.
	model contentsBlock: [ :each | {each key asString} ].
	^ widget
    ]

    appendImplementorResults: aDictionary [

	self clear.
	aDictionary associationsDo: [ :each | model append: each ]
    ]

    selectedResult: aBrowser [

        self hasSelectedResult ifFalse: [ ^ self ].
        self selectedResult value updateBrowser: aBrowser 
    ]

]

