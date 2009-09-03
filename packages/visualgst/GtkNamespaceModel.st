Object subclass: GtkNamespaceModel [
    GtkNamespaceModel class [ | current | ]

    | model sorted |

    GtkNamespaceModel class >> current [
	<category: 'accessing'>

	^ current ifNil: [
	    current := self new
			    initialize;
			    yourself ]
    ]

    GtkNamespaceModel class >> addEvent: anEvent [
	<category: 'model event'>

	self current
		append: (self current findIterInANamespace: anEvent item superspace)
		column: 0
		value: anEvent item displayString
    ]

    GtkNamespaceModel class >> removeEvent: anEvent [
	<category: 'model event'>

	self current remove: anEvent item
    ]

    initialize [
	<category: 'initialize-release'>

	sorted := false
    ]

    isSorted [
	<category: 'testing'>

	^ sorted
    ]

    sorted: aBoolean [
	<category: 'accessing'>
	
	sorted := aBoolean
    ]

    model [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString}.
	    self appendNamespace: Smalltalk to: nil.
	    model ]
    ]

    refresh [
	<category: 'model'>

	self model clear.
	self appendNamespace: Smalltalk to: nil
    ]

    appendNamespace: aNamespace to: parentGtkIter [
	<category: 'model builder'>

	
	| iter |
	iter := self model append: parentGtkIter item: {aNamespace displayString}.	

	aNamespace subspacesDo: [ :each |
	    self appendNamespace: each to: iter ]
    ]

    buildNamespaceArray: aNamespace [
	<category: 'item selection'>

	| result namespace |
        result := OrderedCollection new.
        namespace := aNamespace.
        [ namespace isNil ] whileFalse: [
            result add: namespace displayString.
            namespace := namespace superspace ].

	^ result
    ]

    buildNamespaceArray: aNamespace [
        <category: 'item selection'>

        | result namespace |
        result := OrderedCollection new.
        namespace := aNamespace.
        [ namespace isNil ] whileFalse: [
            result addFirst: namespace displayString.
            namespace := namespace superspace ].

        ^ result
    ]

    findIterInANamespace: aNamespace [
        <category: 'item selection'>

        | iter stack parent path |
        aNamespace = Smalltalk ifTrue: [ ^ self model getIterFirst ].

        stack := self buildNamespaceArray: aNamespace.
        iter := GTK.GtkTreeIter new.
	path := GTK.GtkTreePath newFirst.
        1 to: stack size do: [ :i | | each |
            each := stack at: i.
	    self model getIter: iter path: path.
            [each = (self model getOop: iter column: 0)] whileFalse: [
		path next.
		(self model getIter: iter path: path) ifFalse: [ self error: 'Namespace ', each , ' not found' ] ].
	    path down ].
        ^ iter
    ]

    at: aGtkIter column: aSmallInteger value: anObject [
	<category: 'item accessing'>

	self model setOop: aGtkIter column: aSmallInteger value: anObject
    ]

    append: aParentIter column: aSmallInteger value: anObject [
	<category: 'item accessing'>

	| iter |
	iter := GTK.GtkTreeIter new.
	(self model)
            append: iter parent: aParentIter;
            setOop: iter column: aSmallInteger value: anObject
    ]

    remove: aNamespace [
	<category: 'item removing'>

	 | iter |
        iter := self findIterInANamespace: aNamespace.
        self model remove: iter
    ]
]

