Object subclass: GtkCategorizedClassModel [

    GtkCategorizedClassModel class >> on: aNamespace category: aString [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    namespace: aNamespace category: aString;
	    yourself
    ]

    | category model namespace sorted |

    initialize [
	<category: 'initialize-release'>

	sorted := false.
	self registerNotifier
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(VisualGST uniqueInstance systemChangeNotifier)
	    notify: self ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:'
    ]

    isSorted [
        <category: 'testing'>

        ^ sorted
    ]

    sorted: aBoolean [
        <category: 'accessing'>

        sorted := aBoolean
    ]

    namespace [
	<category: 'accessing'>
    
	^ namespace
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace.
	self refreshModel
    ]

    category: aString [
	<category: 'accessing'>

	category := aString
    ]

    category [
	<category: 'accessing'>

	^ category
    ]

    namespace: aNamespace category: aString [
	<category: 'initialize'>

	self
	    category: aString;
	    namespace: aNamespace
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    refreshModel [
	<category: 'events'>
	
	self gtkModel clear.
	Class subclassesDo: [ :each |
	    self appendClass: each to: nil ]
    ]

    appendClass: aClass to: parentGtkIter [
	<category: 'model builder'>
    
	| iter string |
	aClass environment = self namespace ifTrue: [
	    self category = '' ifTrue: [
		iter := self gtkModel append: parentGtkIter item: { aClass asClass name asString, ' ' } ]
			       ifFalse: [
		self category = aClass category ifTrue: [ iter := self gtkModel append: parentGtkIter item: { aClass asClass name asString, ' ' } ].
		(self namespace displayString, '-', self category) = aClass category ifTrue: [ iter := self gtkModel append: parentGtkIter item: { aClass asClass name asString, ' ' } ]. ] ].

	aClass subclassesDo: [ :each |
	    self appendClass: each to: iter ]
    ]

    buildClassArray: aClass [
        <category: 'item selection'>

        | result class |
        result := OrderedCollection new.
        class := aClass.
        [ class isNil not and: [ class environment = self namespace ] ] whileTrue: [
            result add: (class name asString, ' ').
            class := class superclass ].

        ^ result
    ]

    hasClass: aClass [
	<category: 'item testing'>

	| iter stack parent path pathString number |
        stack := self buildClassArray: aClass.
	stack isEmpty ifTrue: [ ^ false ].
        iter := GTK.GtkTreeIter new.
        path := GTK.GtkTreePath newFirst.
        1 to: stack size do: [ :i | | each |
            each := stack at: (stack size + 1 - i).
            self gtkModel getIter: iter path: path.
            [each = (self gtkModel getOop: iter column: 0)] whileFalse: [
                path next.
                (self gtkModel getIter: iter path: path)  ifFalse: [ ^ false ] ].
            path down ].
        ^ true
    ]

    findIterInAClass: aClass [
        <category: 'item selection'>

	^ self findIterInAClass: aClass ifAbsent: [ self error: aClass name, ' is not found' ]
    ]

    findIterInAClass: aClass ifAbsent: aBlock [
        <category: 'item selection'>

        | iter stack parent path pathString number |
        stack := self buildClassArray: aClass.
	stack isEmpty ifTrue: [ ^ aBlock value ].
        iter := GTK.GtkTreeIter new.
        path := GTK.GtkTreePath newFirst.
        1 to: stack size do: [ :i | | each |
            each := stack at: (stack size + 1 - i).
            self gtkModel getIter: iter path: path.
            [each = (self gtkModel getOop: iter column: 0)] whileFalse: [
                path next.
                (self gtkModel getIter: iter path: path)  ifFalse: [ ^ aBlock value ] ].
            path down ].
        ^ iter
    ]

    at: aGtkIter column: aSmallInteger value: anObject [
        <category: 'item accessing'>

        self gtkModel setOop: aGtkIter column: aSmallInteger value: anObject
    ]

    append: aParentIter column: aSmallInteger value: anObject [
        <category: 'item accessing'>

        | iter |
        iter := GTK.GtkTreeIter new.
        (self gtkModel)
            append: iter parent: aParentIter;
            setOop: iter column: aSmallInteger value: anObject
    ]

    remove: aClass [
	<category: 'item removing'>

	| iter |
	iter := self findIterInAClass: aClass ifAbsent: [ nil ].
	iter isNil ifFalse: [ self gtkModel remove: iter ]
    ]

    addEvent: anEvent [
	<category: 'model event'>

	| parentIter parent |
	anEvent item environment == self namespace ifFalse: [ ^ self ].
	(anEvent item category = self category or: [ self category isEmpty ]) ifFalse: [ ^ self ].
	parentIter := self findIterInAClass: anEvent item superclass ifAbsent: [ nil ].
	self appendClass: anEvent item to: parentIter
    ]

    removeEvent: anEvent [
        <category: 'model event'>

	anEvent item environment == self namespace ifFalse: [ ^ self ].
	(anEvent item category = self category or: [ self category isEmpty ]) ifFalse: [ ^ self ].
	(self hasClass: anEvent item) ifFalse: [ ^ self ].
        self remove: anEvent item
    ]

    recategorizedEvent: anEvent [
        <category: 'model event'>

       | iter |
	anEvent item environment == self namespace ifFalse: [ ^ self ].
	anEvent oldCategory = anEvent item category ifTrue: [ ^ self ].
	(anEvent oldCategory = self category or: [ self category isEmpty ]) ifTrue: [ ^ self remove: anEvent item ].
	(anEvent item category = self category or: [ self category isEmpty ]) ifTrue: [ 
	    iter := self findIterInAClass: anEvent item superclass ifAbsent: [ nil ].
	    self append: iter column: 0 value: (anEvent item name, ' ') ].
    ]
]

