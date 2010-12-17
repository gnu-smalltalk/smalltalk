GtkCategorizedClassWidget subclass: GtkClassSUnitWidget [

    addToModel: aClass [

        (aClass superclass environment == self namespace and: [ (aClass superclass category = self category or: [ self category isEmpty ]) and: [ aClass superclass ~~ Smalltalk.TestCase ] ]) 
                    ifFalse: [ model append: aClass class ]
                    ifTrue: [ model append: aClass class parent: aClass superclass class ]
    ]

    root [
	<category: 'accessing'>

        ^ Smalltalk.TestCase
    ]

    selectionMode [
        <category: 'accessing'>

        ^ GTK.Gtk gtkSelectionMultiple
    ]

    allClassNames [
        <category: 'accessing'>

	| classes names |
	classes := self selectedClasses.
	names := classes collect: [ :each | each name asString ].
	^ names fold: [ :a :b | a, ', ', b ]
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ (classesTree treeView getSelection getSelectedRows: nil) ~= nil
    ]

    selectedClass [
        <category: 'accessing'>

	^ self selectedClasses first
    ]

    selectedClasses [
        <category: 'accessing'>

	self hasSelectedClass ifFalse: [ self error: 'Nothing is selected' ].
	^ classesTree treeView selections collect: [:each| each asClass]
    ]

    recategorizedEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super recategorizedEvent: anEvent
    ]

    addEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super addEvent: anEvent
    ]
]

