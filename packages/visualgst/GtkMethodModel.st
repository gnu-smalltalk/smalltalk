Object subclass: GtkMethodModel [

    GtkMethodModel class >> on: aClass withCategory: aCategory [
	<category: 'instance creation'>

        ^ (self new)
	    initialize;
	    classOrMeta: aClass withCategory: aCategory;
	    yourself
    ]

    | model classOrMeta category sorted |

    initialize [
        <category: 'initialize-release'>

        sorted := false.
	self registerNotifier
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(SystemChangeNotifier uniqueInstance)
	    notify: self ofSystemChangesOfItem: #method change: #Added using: #'addEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeEvent:'
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

    category [
	<category: 'accessing'>

	^ category
    ]

    category: aString [
	<category: 'accessing'>

	category := aString.
	self refreshModel
    ]

    classOrMeta: aClass withCategory: aString [
	<category: 'accessing'>

	classOrMeta := aClass.
	self category: aString
    ]

    gtkModel [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    emptyModel [
	<category: 'accessing'>

	^ GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString}
    ]

    refreshModel [
	<category: 'events'>
    
	self classOrMeta ifNil: [ ^ model := self emptyModel ].

	self gtkModel clear.

	self classOrMeta selectors do: [ :each |
	    (((self classOrMeta compiledMethodAt: each) methodCategory = self category) or: [ self category = '*'])
		ifTrue: [ self appendMethod: each asString ] ]
    ]

    buildCategory [
	<category: 'model builder'>

	| category set |
	set := Set new.
	self classOrMeta selectors do: [ :each |
	    category := (self classOrMeta compiledMethodAt: each) methodCategory.
	    set add: category ].
	^ set
    ]

    findIterInAMethod: aString [
        <category: 'item selection'>

	self gtkModel do: [ :elem :iter |
	    elem first = aString ifTrue: [ ^ iter ] ].
        self error: 'Method not found'
    ]

    appendMethod: aString [
	<category: 'model builder'>
    
	self gtkModel appendItem: {aString}
    ]

    removeMethod: aString [
        <category: 'model builder'>

        | iter |
        iter := self findIterInAMethod: aString.
        self gtkModel remove: iter
    ]

    addEvent: anEvent [
	<category: 'event'>

	(anEvent item methodClass == self classOrMeta and: [ anEvent item methodCategory = self category ]) ifFalse: [ ^ self ].
	self appendMethod: anEvent item selector asString
    ]

    removeEvent: anEvent [
	<category: 'event'>

	(anEvent item methodClass == self classOrMeta and: [ anEvent item methodCategory = self category ]) ifFalse: [ ^ self ].
        self removeMethod: anEvent item selector asString
    ]
]

