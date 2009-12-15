Object subclass: GtkListModel [

    GtkListModel class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]

    | columns contentsBlock item model |

    initialize [
	<category: 'initialization'>

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
	    model := GTK.GtkListStore new: self columns size varargs: self columns ]
    ]

    append: anArray [
	<category:' model'>

	self gtkModel appendItem: anArray
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
	(self contentsBlock value: self item) do: [ :each | self append: each ].
	"self item do: [ :each | self append: (self contentsBlock value: each) ]"
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

