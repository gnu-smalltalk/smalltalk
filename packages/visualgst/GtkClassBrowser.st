GtkBrowsingTool subclass: GtkClassBrowser [
    | browserWidget |

    aboutTitle [
	^ 'About Class Browser'
    ]

    windowTitle [
	^ 'Class Browser'
    ]

    browser [
	<category: 'events'>
    ]

    classBrowser [
	<category: 'events'>
    ]

    cancel [
	<category: 'edit events'>

	browserWidget cancel
    ]


    undo [
	<category: 'edit events'>

	browserWidget undo
    ]

    redo [
	<category: 'edit events'>

	browserWidget redo
    ]

    cut [
        <category: 'edit events'>

        browserWidget cut
    ]

    copy [
        <category: 'edit events'>

        browserWidget copy
    ]

    paste [
        <category: 'edit events'>

        browserWidget paste
    ]

    selectAll [
        <category: 'edit events'>

        browserWidget selectAll
    ]

    gtkInspector [
	<category: 'events'>
	
	GtkInspector openOn: self
    ]

    state [
        <category: 'command protocols'>

        ^browserWidget state
    ]

    selectedText [
        <category: 'command protocols'>

        ^browserWidget selectedText
    ]

    selectedMethodSymbol [
        <category: 'tools events'>

        ^browserWidget selectedMethodSymbol
    ]

    hasSelection [
        <category: 'command protocols'>

        ^browserWidget hasSelection
    ]

    sourceCodeWidgetHasFocus [
        <category: 'command protocols'>

        ^browserWidget sourceCodeWidgetHasFocus
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^true
    ]

    fileoutNamespace [
	<category: 'namespace events'>

        browserWidget fileoutNamespace
    ]

    newNamespace [
	<category: 'namespace events'>

	browserWidget newNamespace
    ]

    renameNamespace [
	<category: 'namespace events'>

	browserWidget renameNamespace
    ]

    deleteNamespace [
	<category: 'namespace events'>

	browserWidget deleteNamespace
    ]

    inspectNamespace [
	<category: 'namespace events'>

	browserWidget inspectNamespace
    ]

    fileoutClass [
	<category: 'class events'>

	browserWidget fileoutClass
    ]

    newClass [
        <category: 'class events'>

	browserWidget newClass
    ]

    renameClass [
        <category: 'class events'>

	browserWidget renameClass
    ]

    deleteClass [
        <category: 'class events'>

	browserWidget deleteClass
    ]

    inspectClass [
	<category: 'class events'>

	browserWidget inspectClass
    ]

    newCategory [
	<category: 'category events'>

	browserWidget newCategory
    ]

    renameCategory [
	<category: 'category events'>

	browserWidget renameCategory
    ]

    fileoutCategory [
        <category: 'method events'>

	browserWidget fileoutCategory
    ]

    deleteMethod [
	<category: 'method events'>

	browserWidget deleteMethod
    ]

    inspectMethod [
	<category: 'method events'>

	browserWidget inspectMethod
    ]

    fileoutMethod [
	<category: 'method events'>

	browserWidget fileoutMethod
    ]

    acceptIt [
	<categoyr: 'smalltalk events'>

	browserWidget acceptIt
    ]

    postInitialize [
	<category: 'user interface'>

	super postInitialize.
	browserWidget
		    postInitialize;
		    grabFocus
    ]

    buildCentralWidget [
	<category: 'user interface'>

	^ (browserWidget := GtkClassBrowserWidget new)
			    parentWindow: window;
			    initialize;
			    mainWidget
    ]

    createNamespaceMenus [
	<category: 'user interface'>

	^{GTK.GtkMenuItem menuItem: 'Add a namespace' connectTo: self selector: #newNamespace.
	    GTK.GtkMenuItem menuItem: 'Rename a namespace' connectTo: self selector: #renameNamespace.
	    GTK.GtkMenuItem menuItem: 'Delete a namespace' connectTo: self selector: #deleteNamespace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Inspect a namespace' connectTo: self selector: #inspectNamespace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'File out a namespace' connectTo: self selector: #fileoutNamespace}
    ]

    createClassMenus [
	<category: 'user interface'>

	^{GTK.GtkMenuItem menuItem: 'Add a class' connectTo: self selector: #newClass.
	    GTK.GtkMenuItem menuItem: 'Rename a class' connectTo: self selector: #renameClass.
	    GTK.GtkMenuItem menuItem: 'Delete a class' connectTo: self selector: #deleteClass.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Inspect a class' connectTo: self selector: #inspectClass.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'File out a class' connectTo: self selector: #fileoutClass}
    ]

    createCategoryMenus [
	<category: 'user interface'>

	^{GTK.GtkMenuItem menuItem: 'Add a category' connectTo: self selector: #newCategory.
            GTK.GtkMenuItem menuItem: 'Rename a category' connectTo: self selector: #renameCategory.
	    GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'File out a category' connectTo: self selector: #fileoutCategory}
    ]

    createMethodMenus [
	<category: 'user interface'>

	^{GTK.GtkMenuItem menuItem: 'Delete a method' connectTo: self selector: #deleteMethod.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Inspect a method' connectTo: self selector: #inspectMethod.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'File out a method' connectTo: self selector: #fileoutMethod}
    ]

    createMenus [
	<category: 'user interface'>

	self addMenuItem: 'File' withSubmenu: self createFileMenus.
	self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Namespace' withSubmenu: self createNamespaceMenus.
	self addMenuItem: 'Class' withSubmenu: self createClassMenus.
	self addMenuItem: 'Category' withSubmenu: self createCategoryMenus.
	self addMenuItem: 'Method' withSubmenu: self createMethodMenus.
	self addMenuItem: 'Smalltalk' withSubmenu: self createSmalltalkMenus.
	self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
	self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]

    doIt [
	<category: 'smalltalk events'>

	browserWidget doIt
    ]

    debugIt [
        <category: 'smalltalk events'>

	browserWidget debugIt
    ]

    inspectIt [
        <category: 'smalltalk events'>

	browserWidget inspectIt
    ]

    printIt [
        <category: 'smalltalk events'>

	browserWidget printIt
    ]

    close [
	<category: 'file events'>

	browserWidget doNotCheckCode.
	self saveCodeOr: [ super close ]
    ]

    onDelete: aGtkWidget event: aGdkEvent [
	<category: 'window events'>

	self saveCodeOr: [ window hideAll ].
	^ true
    ]

    selectANamespace: aNamespace [
	<category: 'selection'>

	browserWidget selectANamespace: aNamespace
    ]

    selectAClass: aClass [
	<category: 'selection'>

	browserWidget selectAClass: aClass
    ]

    find [
	<category: 'user interface'>

	browserWidget showFind
    ]

    replace [
	<category: 'user interface'>

	browserWidget showReplace
    ]
]

