Object subclass: GtkCategoryModel [

    GtkCategoryModel class >> on: aClass [
	<category: 'instance creation'>

        ^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    | model classOrMeta sorted |

    initialize [
        <category: 'initialize-release'>

        sorted := false.
	self registerNotifier
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(VisualGST uniqueInstance systemChangeNotifier)
	    notify: self ofSystemChangesOfItem: #category change: #Added using: #'addEvent:';
	    notify: self ofSystemChangesOfItem: #category change: #Removed using: #'removeEvent:'
    ]

    isSorted [
        <category: 'testing'>

        ^ sorted
    ]

    sorted: aBoolean [
        <category: 'accessing'>

        sorted := aBoolean
    ]

    classOrMeta [
	<category: 'accessing'>
    
	^ classOrMeta
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	classOrMeta := aClass.
	self refreshModel
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    clearModel [
	<category: 'accessing'>

	self gtkModel clear
    ]

    refreshModel [
	<category: 'events'>
   
	self clearModel.
	self classOrMeta isNil ifTrue: [ ^ self ].
	self buildCategory do: [ :each |
	    self appendCategory: each ]
    ]

    buildCategory [
	<category: 'model builder'>

	| category set |
	set := Set new.
	set add: '*'.
	self classOrMeta selectors do: [ :each |
	    category := (self classOrMeta compiledMethodAt: each) methodCategory.
	    set add: category ].
	^ set
    ]

    hasCategory: aString [
        <category: 'item selection'>

        | iter stack parent path pathString number |
        iter := GTK.GtkTreeIter new.
        path := GTK.GtkTreePath newFirst.
        [self gtkModel getIter: iter path: path] whileTrue: [
            self gtkModel getIter: iter path: path.
            (aString = (self gtkModel getOop: iter column: 0))
                ifTrue: [ ^ true  ].
            path next ].
        ^ false
    ]

    findIterInACategory: aString [
        <category: 'item selection'>

	self gtkModel do: [ :elem :iter |
	    elem first = aString ifTrue: [ ^ iter ] ].
	self error: 'Category not found'
    ]

    appendCategory: aString [
	<category: 'model builder'>
    
	self gtkModel appendItem: {aString}
    ]

    removeCategory: aString [
        <category: 'model builder'>

        | iter |
	iter := self findIterInACategory: aString.
        self gtkModel remove: iter
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent itemClass == self classOrMeta) ifFalse: [ ^ self ].
        self appendCategory: anEvent item
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent itemClass == self classOrMeta) ifFalse: [ ^ self ].
	self removeCategory: anEvent item
    ]
]

