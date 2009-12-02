GtkConcreteWidget subclass: GtkClassHierarchyWidget [
    | classesTree model classOrMeta |

    GtkClassHierarchyWidget >> on: aClass [
	^ (self new)
	    initialize;
	    class: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
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

    model [
	<category: 'accessing'>

	^ model ifNil: [
	    model := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    emptyModel [
	<category: 'accessing'>

	self model clear
    ]

    refreshModel [
	<category: 'events'>

	| iter |
	
	self model clear.
	iter := self buildSuperClassHierarchy.
	self classOrMeta class subclassesDo: [ :each |
		self appendClass: each to: iter].

	classesTree expandAll
    ]

    buildSuperClassHierarchy [
	<category: 'model builder'>

	| iter res parent parentGtkIter |
	parent := self classOrMeta.
	res := OrderedCollection new.
	[parent isNil] whileFalse: [
	    res addFirst: parent displayString.
	    parent := parent superclass ].

	res do: [ :each |
	    iter := GTK.GtkTreeIter new.
	    self model append: iter parent: parentGtkIter.
	    self model setOop: iter column: 0 value: each.
	    parentGtkIter := iter ].

	^ iter
    ]

    appendClass: aClass to: parentGtkIter [
	<category: 'model builder'>
    
	| iter |
	iter := GTK.GtkTreeIter new.
	self model append: iter parent: parentGtkIter.
	self model setOop: iter column: 0 value: (aClass instanceClass displayString).

	aClass subclassesDo: [ :each |
	    self appendClass: each to: iter ]
    ]

    buildTreeView [
	<category: 'user interface'>
    
	^ GTK.GtkScrolledWindow withChild: (classesTree := GTK.GtkTreeView newWithTextColumn: self model title: 'Class')
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree hasSelectedItem
    ]

    selectedClass [
	<category: 'accessing'>

	| iter string |
	(iter := classesTree selectedIter) ifNil: [ ^ self classOrMeta " self error: 'Nothing is selected' " ].
	string := ((self model getOop: iter column: 0) subStrings: $ ) at: 1.

	^ self lookFor: 1 inside: Smalltalk with: (string subStrings: $.) 
    ]

    lookFor: anInteger inside: aNamespace with: anArray [
	<category: 'private'>

	anInteger < anArray size
	    ifTrue: [ aNamespace subspacesDo: [ :each |
		each name = (anArray at: anInteger) asSymbol
		    ifTrue: [ ^ self lookFor: anInteger + 1 inside: each with: anArray ] ].
		self error: 'Namespace not found' ]
	    ifFalse: [ ^ aNamespace at: (anArray at: anInteger) asSymbol ifAbsent: [ self error: 'Class not found' ] ]
    ]
]

