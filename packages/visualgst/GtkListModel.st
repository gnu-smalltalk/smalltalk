Object subclass: GtkListModel [

    GtkListModel class >> on: aGtkListStore [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    gtkModel: aGtkListStore;
	    yourself
    ]

    | contentsBlock item model |

    initialize [
	<category: 'initialization'>

    ]

    gtkModel: aGtkListStore [
	<category: 'accessing'>

	model := aGtkListStore
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

    append: anItem [
	<category: 'model'>

	model appendItem: ((self contentsBlock value: anItem) copyWith: anItem)
    ]

    remove: anObject [
	<category: 'model'>

	| iter |
	(iter := self findIter: anObject) ifNil: [ self error: 'item not found' ].
	model remove: iter
    ]

    clear [
	<category: 'model'>

	model clear
    ]

    refresh [
	<category: 'model'>

	self clear.
	self item ifNil: [ ^ self ].
	self item do: [ :each | self append: each ]
    ]

    hasItem: anObject [
        <category: 'item selection'>

        self findIter: anObject ifAbsent: [ ^ false ].
        ^ true
    ]

    findIter: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	model do: [ :elem :iter |
	    elem last = anObject ifTrue: [ ^ iter ] ].
	aBlock value
    ]

    findIter: anObject [
	<category: 'item selection'>

	^ self findIter: anObject ifAbsent: [ self error: 'Item not found' ]
    ]
]

