GtkClassWidget subclass: GtkClassSUnitWidget [

    classModel [
        <category: 'initialization'>

        ^ GtkClassSUnitModel
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree getSelection countSelectedRows > 0
    ]

    selectedClass [
        <category: 'accessing'>

        | glist string results |
        (glist := classesTree getSelection getSelectedRows: nil) ifNil: [ self error: 'Nothing is selected' ].
	results := OrderedCollection new.
	glist do: [ :rawData | | iter path |
	    path := rawData castTo: GTK.GtkTreePath type.
	    iter := self model gtkModel getIter: path.
	    string := ((self model gtkModel getOop: iter column: 0) subStrings: $ ) at: 1.
	    results add: (self namespace classAt: string asSymbol) ].
	^ results
    ]
]

