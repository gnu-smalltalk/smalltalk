Object subclass: GtkListModel [

    | columns contentsBlock item model |

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

    contentsBlock: aBlock [
	<category: 'accessing'>

	contentsBlock := aBlock
    ]

    contentsBlock [
	<category: 'accessing'>

	^ contentsBlock
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkListStore new: columns size varargs: columns ]
    ]

    append: anArray [
	<category:' model'>

	self gtkModel append: anArray
    ]

    clear [
	<category: 'model'>

	self gtkModel clear
    ]

    refresh [
	<category: 'model'>

	| elem |
	self clearModel.
	self item ifNil: [ ^ self ].
	self item do: [ :each | self append: self childrenBlock value: each ]
    ]

    findIter: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	self gtkModel do: [ :elem :iter |
	    elem first = anObject ifTrue: [ ^ iter ] ].
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
]

