Object subclass: GtkTreeModel [

    GtkTreeModel class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]

    | columns childrenBlock contentsBlock findBlock item model sorted |

    initialize [
	<category: 'initialization'>

	sorted := false
    ]

    columns: anInteger [
	<category: 'accessing'>

	columns := anInteger
    ]

    columns [
	<category:' accessing'>

	^ columns
    ]

    item: anObject [
	<category: 'accessing'>

	item := anObject
    ]

    item [
	<category: 'accessing'>

	^ item
    ]

    childrenBlock: aBlock [
	<category: 'accessing'>

	childrenBlock := aBlock
    ]

    childrenBlock [
	<category: 'accessing'>

	^ childrenBlock
    ]

    contentsBlock: aBlock [
	<category: 'accessing'>

	contentsBlock := aBlock
    ]

    contentsBlock [
	<category: 'accessing'>

	^ contentsBlock
    ]

    findBlock: aBlock [
	<category: 'accessing'>

	findBlock := aBlock
    ]

    findBlock [
	<category: 'accessing'>

	^ findBlock
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: self columns size varargs: self columns ]
    ]

    append: anArray parent: aGtkIter [
	<category:' model'>

	^ self gtkModel append: aGtkIter item: anArray
    ]

    append: anArray [
	<category:' model'>

	^ self gtkModel appendItem: anArray
    ]

    remove: anObject [
	<category: 'model'>

	| iter |
	(iter := self findIter: anObject) ifNil: [ self error: 'item not found' ].
	self gtkModel remove: iter
    ]

    clear [
	<category: 'model'>

	self gtkModel clear
    ]

    refresh [
	<category: 'model'>

	self clear.
	self item ifNil: [ ^ self ].
	self refresh: (self childrenBlock value: self item) parent: nil 
    ]

    refresh: anObject parent: aGtkIter [
	<category: 'model'>

	| iter |
	anObject do: [ :each |
	    iter := self append: each key parent: aGtkIter.
	    self refresh: each value parent: iter ]
    ]

    findIter: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	self gtkModel do: [ :elem :iter |
	    (self findBlock value: elem value: anObject) ifTrue: [ ^ iter ] ].
	aBlock value
    ]

    findIter: anObject [
	<category: 'item selection'>

	^ self findIter: anObject ifAbsent: [ self error: 'Item not found' ]
    ]

    hasItem: anObject [
        <category: 'item selection'>

        self findIter: anObject ifAbsent: [ ^ false ].
	^ true 
    ]

    isSorted [
        <category: 'testing'>

        ^ sorted
    ]

    sorted: aBoolean [
        <category: 'accessing'>

        sorted := aBoolean
    ]
]

