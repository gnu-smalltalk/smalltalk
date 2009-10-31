GtkNamespaceWidget subclass: GtkCategorizedNamespaceWidget [
    model [
	<category: 'accessing'>

	^ model ifNil: [ model := GtkCategorizedNamespaceModel new
							    initialize;
							    yourself ]
    ]

    selectedNamespace [
	<category: 'accessing'>

	| iter path |
	'N' = (self model gtkModel getOop: self selectedIter column: 3) ifTrue: [ 
	    ^ self model gtkModel getOop: self selectedIter column: 2 ].
	path := self model gtkModel getPath: self selectedIter.
	iter := GTK.GtkTreeIter new.
	[ path up.
	  (self model gtkModel getIter: iter path: path) ifFalse: [ self error: 'Selected category not found' ].
	  'N' = (self model gtkModel getOop: iter column: 3) ] whileFalse.
	^ self model gtkModel getOop: iter column: 2
    ]

    selectedCategory [
	<category: 'accessing'>

	| iter path cat |
	'N' = (self model gtkModel getOop: self selectedIter column: 3) ifTrue: [ ^ '' ].
	path := self model gtkModel getPath: self selectedIter.
        iter := GTK.GtkTreeIter new.
	cat := self model gtkModel getOop: self selectedIter column: 1.
        [ path up.
          (self model gtkModel getIter: iter path: path) ifFalse: [ self error: 'Selected category not found' ].
          'N' = (self model gtkModel getOop: iter column: 3)
				    ifFalse: [ cat := (self model gtkModel getOop: iter column: 1), '-', cat. false ] 
				    ifTrue: [ true ] ] whileFalse.
	^ cat
    ]
]

