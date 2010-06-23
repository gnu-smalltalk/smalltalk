GtkVisualGSTTool subclass: GtkInspector [
    | object notebookWidget inspectorWidget browserWidget workspaceWidget |

    GtkInspector class >> openOn: anObject [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    object: anObject;
	    showAll;
	    postInitialize;
	    yourself
    ]

    postInitialize [
        <category: 'initialization'>

	super postInitialize.
	browserWidget postInitialize.
	inspectorWidget postInitialize.
	workspaceWidget postInitialize.
    ]

    object: anObject [
	<category: 'accessor'>

	| objectClass |
	object == anObject ifFalse: [
	    object := anObject.
            inspectorWidget object: object.
	    workspaceWidget object: object ].
	objectClass := object isClass ifTrue: [ object ] ifFalse: [ object class ].
	self title: 'Inspector on ', objectClass article, ' ', objectClass name.
	browserWidget
	    selectAClass: objectClass
    ]

    windowTitle [
	<category: 'initialization'>
	
	^'Inspector'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	| trWidget wkWidget |
	notebookWidget := GTK.GtkNotebook new.
	trWidget := self buildInspectorView.
	wkWidget := self buildBrowserWidget mainWidget.
	^ notebookWidget
	    appendPage: trWidget tabLabel: (GTK.GtkLabel new: 'Basic');
	    appendPage: wkWidget tabLabel: (GTK.GtkLabel new: 'Methods');
	    showAll;
	    setCurrentPage: 0;
	    yourself
    ]

    buildInspectorView [
	<category: 'user interface'>

	^ GTK.GtkVPaned new
            pack1: self buildInspectorWidget mainWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: false shrink: true;
            yourself
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ inspectorWidget := (GtkInspectorWidget new)
				parentWindow: window;
				initialize;
				inspector: self;
				showAll;
				yourself
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkInspectorSourceWidget new)
				parentWindow: window;
				initialize;
				showAll;
				yourself
    ]

    buildBrowserWidget [
	<category: 'user interface'>

	^ browserWidget := (GtkInspectorBrowserWidget new)
				parentWindow: window;
				initialize;
				showAll;
				yourself
    ]

    createMenus [
	<category: 'user interface'>

	self addMenuItem: 'File' withSubmenu: self createFileMenus.
	self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Smalltalk' withSubmenu: self createSmalltalkMenus.
	self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
    ]

    focusedWidget [
        <category: 'focus'>

        ^notebookWidget getCurrentPage = 0
            ifTrue: [ workspaceWidget focusedWidget ]
            ifFalse: [ browserWidget focusedWidget ]
    ]

    cancel [
        <category: 'edit events'>

        self onFocusPerform: #cancel
    ]

    undo [
        <category: 'edit events'>

        self onFocusPerform: #undo
    ]

    redo [
        <category: 'edit events'>

        self onFocusPerform: #redo
    ]

    cut [
        <category: 'edit events'>

        self onFocusPerform: #cut
    ]

    copy [
        <category: 'edit events'>

        self onFocusPerform: #copy
    ]

    paste [
        <category: 'edit events'>

        self onFocusPerform: #paste
    ]

    selectAll [
        <category: 'edit events'>

        self onFocusPerform: #selectAll
    ]

    close [
        <category: 'file events'>

        browserWidget doNotCheckCode.
        self saveCodeOr: [ super close ]
    ]

    onDelete [
        <category: 'window events'>

        self saveCodeOr: [ window hideAll ].
        ^ true
    ]

    saveCodeOr: dropBlock [
        <category: 'saving'>

        | dialog |
        self hasChanged ifFalse: [ dropBlock value. ^self ].
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Save the code before exiting?'
                                tip: 'If you do not save, your changes to %1 will be lost...' % {browserWidget state}.

        dialog
            addButton: 'Drop' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Accept' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: [ self acceptIt ].
                res <= 1 ifTrue: dropBlock.
                dlg destroy ].
    ]

    doIt [
        <category: 'smalltalk events'>

        self onFocusPerform: #doIt
    ]

    printIt [
        <category: 'smalltalk events'>

        self onFocusPerform: #printIt
    ]

    inspectIt [
        <category: 'smalltalk events'>

        self onFocusPerform: #inspectIt
    ]

    debugIt [
        <category: 'smalltalk events'>

        self onFocusPerform: #debugIt
    ]

    acceptIt [
        <category: 'smalltalk events'>

        browserWidget acceptIt
    ]

    find [
	<category: 'user interface'>

	self onFocusPerform: #showFind
    ]

    replace [
	<category: 'user interface'>

	self onFocusPerform: #showReplace
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^notebookWidget getCurrentPage = 1
    ]

    sourceCodeWidgetHasFocus [
        <category: 'focus'>

        ^ browserWidget sourceCodeWidgetHasFocus
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^self onFocusPerform: #selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [^false].
        ^widget hasSelection
    ]
]

