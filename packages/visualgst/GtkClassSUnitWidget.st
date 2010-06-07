GtkCategorizedClassWidget subclass: GtkClassSUnitWidget [

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

        ^ (classesTree getSelection getSelectedRows: nil) ~= nil
    ]

    selectedClass [
        <category: 'accessing'>

	^ self selectedClasses first
    ]

    selectedClasses [
        <category: 'accessing'>

	self hasSelectedClass ifFalse: [ self error: 'Nothing is selected' ].
	^ classesTree selections 
    ]

    addEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super addEvent: anEvent
    ]
]

