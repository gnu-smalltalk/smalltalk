GtkClassWidget subclass: GtkClassSUnitWidget [

    classModel [
        <category: 'initialization'>

        ^ GtkClassSUnitModel
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree getSelection countSelectedRows > 0
    ]

    allClassNames [
	| classes names |
	classes := self selectedClasses.
	names := classes collect: [ :each | each name asString ].
	^names fold: [ :a :b | a, ', ', b ]
    ]

    selectedClass [
        <category: 'accessing'>

        | glist string results |
        (glist := classesTree getSelection getSelectedRows: nil) ifNil: [ ^nil ].
	glist do: [ :rawData | | iter path |
	    path := rawData castTo: GTK.GtkTreePath type.
	    iter := self model gtkModel getIter: path.
	    string := ((self model gtkModel getOop: iter column: 0) subStrings: $ ) at: 1.
	    ^self namespace classAt: string asSymbol ].
    ]

    selectedClasses [
        <category: 'accessing'>

        | glist string results |
	results := OrderedCollection new.
        glist := (classesTree getSelection getSelectedRows: nil) ifNil: [ #() ].
	glist do: [ :rawData | | iter path |
	    path := rawData castTo: GTK.GtkTreePath type.
	    iter := self model gtkModel getIter: path.
	    string := ((self model gtkModel getOop: iter column: 0) subStrings: $ ) at: 1.
	    results add: (self namespace classAt: string asSymbol) ].
	^ results
    ]
]

