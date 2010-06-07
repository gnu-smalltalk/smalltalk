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

    fileoutNamespace [
	<category: 'namespace events'>

        | file |
        (GTK.GtkFileChooserDialog selectFolder: 'Save namespace as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutNamespace: dlg getCurrentFolder ].
                dlg destroy ].
    ]

    fileoutNamespace: aString [
	<category: 'namespace events'>

	browserWidget fileoutNamespace: aString
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

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk class as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutClass: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutClass: aString [
	<category: 'class events'>

	browserWidget fileoutClass: aString
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

    deleteCategory [
	<category: 'category events'>

	browserWidget deleteCategory
    ]

    inspectCategory [
	<category: 'category events'>

	browserWidget inspectCategory
    ]

    fileoutCategory [
        <category: 'method events'>

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk category as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutCategory: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutCategory: aString [
        <category: 'method events'>

        browserWidget fileoutCategory: aString
    ]

    newMethod [
	<category: 'method events'>

	browserWidget newMethod
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

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk method as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutMethod: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutMethod: aString [
        <category: 'method events'>

	browserWidget fileoutMethod: aString
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

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Add a namespace' connectTo: self selector: #newNamespace.
	    GTK.GtkMenuItem menuItem: 'Rename a namespace' connectTo: self selector: #renameNamespace.
	    GTK.GtkMenuItem menuItem: 'Delete a namespace' connectTo: self selector: #deleteNamespace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Inspect a namespace' connectTo: self selector: #inspectNamespace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'File out a namespace' connectTo: self selector: #fileoutNamespace}
    ]

    createClassMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Add a class' connectTo: self selector: #newClass.
	    GTK.GtkMenuItem menuItem: 'Rename a class' connectTo: self selector: #renameClass.
	    GTK.GtkMenuItem menuItem: 'Delete a class' connectTo: self selector: #deleteClass.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Inspect a class' connectTo: self selector: #inspectClass.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'File out a class' connectTo: self selector: #fileoutClass}
    ]

    createCategoryMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Add a category' connectTo: self selector: #newCategory.
            GTK.GtkMenuItem menuItem: 'Rename a category' connectTo: self selector: #renameCategory.
            GTK.GtkMenuItem menuItem: 'Delete a category' connectTo: self selector: #deleteCategory.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Inspect a category' connectTo: self selector: #inspectCategory.
	    GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'File out a category' connectTo: self selector: #fileoutCategory}
    ]

    createMethodMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Add a method' connectTo: self selector: #newMethod.
	    GTK.GtkMenuItem menuItem: 'Rename a method' connectTo: self selector: #renameMethod.
	    GTK.GtkMenuItem menuItem: 'Delete a method' connectTo: self selector: #deleteMethod.
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

	browserWidget hasChanged ifFalse: [ ^ super close ].
	browserWidget doNotCheckCode.
	self saveCodeOnClose: [ super close ] onSave: [ browserWidget saveCode. super close ]
    ]

    delete: aGtkWidget event: aGdkEvent [
	<category: 'window events'>

	browserWidget hasChanged ifFalse: [ ^ window hideAll ].
	self saveCodeOnClose: [ window hideAll ] onSave: [ browserWidget saveCode. window hideAll ].
	^ true
    ]

    saveCodeOnClose: closeEvent onSave: saveEvent [
	<category: 'saving'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Save the code before exiting?'
                                tip: 'If you do not save, your changes to %1 will be lost...' % {browserWidget stateString}.

        dialog
            addButton: 'Close without saving' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Save' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: closeEvent.
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]

    selectANamespace: aNamespace [
	<category: 'selection'>

	browserWidget selectANamespace: aNamespace
    ]

    selectAClass: aClass [
	<category: 'selection'>

	browserWidget selectAClass: aClass
    ]
]

