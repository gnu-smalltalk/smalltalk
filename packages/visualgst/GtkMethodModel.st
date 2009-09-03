Object subclass: GtkMethodModel [
    GtkMethodModel class [ | current | ]

    GtkMethodModel class >> currentOn: aClass withCategory: aCategory [
	<category: 'accessing'>

	current ifNil: [ current := Dictionary new ].
	^ (current at: aClass ifAbsentPut: [ Dictionary new ])
	    at: aCategory ifAbsentPut: [ self on: aClass withCategory: aCategory ]
    ]

    GtkMethodModel class >> on: aClass withCategory: aCategory [
	<category: 'instance creation'>

        ^ (self new)
	    initialize;
	    classOrMeta: aClass withCategory: aCategory;
	    yourself
    ]

    GtkMethodModel class >> addEvent: anEvent [
	<category: 'event'>

	| model |
	model := (current at: anEvent item methodClass ifAbsent: [ ^ self ])
		    at: anEvent item methodCategory ifAbsent: [ ^ self ].
	model appendMethod: anEvent item selector asString
    ]

    GtkMethodModel class >> removeEvent: anEvent [
	<category: 'event'>

        | model |
        model := (current at: anEvent item methodClass ifAbsent: [ ^ self ])
                    at: anEvent item methodCategory ifAbsent: [ ^ self ].
        model removeMethod: anEvent item selector asString
    ]

    | model classOrMeta category sorted |

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

    model [
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

	self model clear.

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

	self model do: [ :elem :iter |
	    elem first = aString ifTrue: [ ^ iter ] ].
        self error: 'Method not found'
    ]

    appendMethod: aString [
	<category: 'model builder'>
    
	self model appendItem: {aString}
    ]

    removeMethod: aString [
        <category: 'model builder'>

        | iter |
        iter := self findIterInAMethod: aString.
        self model remove: iter
    ]
]

