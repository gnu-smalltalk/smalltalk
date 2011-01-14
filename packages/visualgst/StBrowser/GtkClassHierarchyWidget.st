GtkConcreteWidget subclass: GtkClassHierarchyWidget [
    | root dic classesTree model classOrMeta |

    GtkClassHierarchyWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	dic := Dictionary new.
	self 
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

       " (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:'
   " ]

    classOrMeta [
	<category: 'accessing'>
    
	^ classOrMeta
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	classOrMeta := aClass.
	dic := Dictionary new.
	self buildSuperclasses.
	model 
	    item: #root;
	    refresh.
	
	classesTree 
		expandAll;
		select: aClass
    ]

    emptyModel [
        classesTree getSelection unselectAll
    ]

    buildSuperclasses [
	| parent |

	parent := self classOrMeta asClass.
	[ parent isNil ] whileFalse: [
	    dic at: (parent superclass ifNil: [ #root ]) put: {parent}.
	    root := parent.
	    parent := parent superclass ].
    ]

    buildTreeView [
	<category: 'user interface'>
   
        classesTree := GTK.GtkTreeView createTreeWithModel: {{GtkColumnTextType title: 'Classes'}}.
        classesTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkTreeModel on: classesTree getModel)
                                        item: #root;
                                        childrenBlock: [ :each |
					    dic at: each ifAbsent: [ | col |
                                                        col := SortedCollection sortBlock: [ :a :b | a asClass name <= b asClass name ].
							col addAll: each subclasses.
                                            col ] ];
                                        contentsBlock: [ :each | {each asClass name asString, ' '} ].
        ^ GTK.GtkScrolledWindow withChild: classesTree 
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree hasSelectedItem
    ]

    selectedClass [
	<category: 'accessing'>

	self hasSelectedClass ifFalse: [ ^ self classOrMeta " self error: 'Nothing is selected' " ].
	^ classesTree selection asClass
    ]

    state [
        <category: 'testing'>

        self hasSelectedClass ifTrue: [ ^ ClassState with: self selectedClass ].
        ^ BrowserState new
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

	self hasSelectedClass ifFalse: [ ^ self ].
	aGtkClassBrowserWidget updateClassHierarchyWidget
    ]
]

