GtkNamespaceWidget subclass: GtkCategorizedNamespaceWidget [
    model [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GtkCategorizedNamespaceModel new
				    initialize;
				    yourself.
	    model gtkModel
		connectSignal: 'row-has-child-toggled' to: self
		selector: #childToggled:path:iter:.

	    model
	 ]
    ]

    selectedNamespace [
	<category: 'accessing'>

	| iter path |
	(self model isIterNamespace: self selectedIter) ifTrue: [ 
	    ^ self model gtkModel getOop: self selectedIter column: 2 ].
	path := self model gtkModel getPath: self selectedIter.
	iter := GTK.GtkTreeIter new.
	[ path up.
	  (self model gtkModel getIter: iter path: path) ifFalse: [ self error: 'Selected category not found' ].
	  (self model isIterNamespace: iter) ] whileFalse.
	^ self model gtkModel getOop: iter column: 2
    ]

    selectedCategory [
	<category: 'accessing'>

	| iter path cat |
	(self model isIterNamespace: self selectedIter) ifTrue: [ ^ '' ].
	path := self model gtkModel getPath: self selectedIter.
        iter := GTK.GtkTreeIter new.
	cat := self model gtkModel getOop: self selectedIter column: 1.
        [ path up.
          (self model gtkModel getIter: iter path: path) ifFalse: [ self error: 'Selected category not found' ].
          (self model isIterNamespace: iter) ] whileFalse:
	      [ cat := (self model gtkModel getOop: iter column: 1), '-', cat ].
	^ cat
    ]

    childToggled: model path: path iter: iter [
	<category: 'signals'>

	namespacesTree collapseRow: path.
	(self model isIterNamespace: iter) ifTrue: [
	    ((self model gtkModel at: iter) at: 3) subspaces isEmpty ifFalse: [
		namespacesTree expandRow: path openAll: false ] ]
    ]
]

