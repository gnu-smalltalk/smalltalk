GtkMainWindow subclass: GtkInspector [
    | object notebookWidget inspectorWidget browserWidget workspaceWidget |

    GtkInspector class >> openOn: anObject [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    postInitialize;
	    object: anObject;
	    showAll;
	    yourself
    ]

    postInitialize [
        <category: 'initialization'>

        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]

    object: anObject [
	<category: 'accessor'>

	| objectClass |
	object := anObject.
	objectClass := object isClass ifTrue: [ object ] ifFalse: [ object class ].
	self title: 'Inspector on ', objectClass article, ' ', objectClass name.
	inspectorWidget object: object.
	workspaceWidget object: object.
	browserWidget
	    selectAClass: objectClass
    ]

    initialize [
	<category: 'initialization'>
	
	super initialize.
	self
	    title: 'Inspector';
	    createMenus;
	    createToolbar;
	    createStatusBar;
	    centralWidget: self buildCentralWidget
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

    createEditMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control><shift>Z'. '<GtkInspector>/Edit/Cancel'}.
            {'<Control>Z'. '<GtkInspector>/Edit/Undo'}.
            {'<Control>R'. '<GtkInspector>/Edit/Redo'}.
            {'<Control>X'. '<GtkInspector>/Edit/Cut'}.
            {'<Control>C'. '<GtkInspector>/Edit/Copy'}.
            {'<Control>V'. '<GtkInspector>/Edit/Paste'}.
            {'<Control>A'. '<GtkInspector>/Edit/SelectAll'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkInspector>/Edit/Cancel' connectTo: self selector: #cancel.
            GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkInspector>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkInspector>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkInspector>/Edit/Cut' connectTo: self selector: #cut.
	    GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkInspector>/Edit/Copy' connectTo: self selector: #copy.
	    GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkInspector>/Edit/Paste' connectTo: self selector: #paste.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkInspector>/Edit/SelectAll' connectTo: self selector: #selectAll}
    ]

    createFileMenus [
	<category: 'user interface'>

	self accelGroup append: {{'<Control>O'. '<GtkInspector>/File/Open'}.
            {'<Control><Shift>S'. '<GtkInspector>/File/SaveAs'}.
            {'<Control>Q'. '<GtkInspector>/File/Close'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkInspector>/File/Open' connectTo: self selector: #open.
	    GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #saveImage.
	    GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkInspector>/File/SaveAs' connectTo: self selector: #saveImageAs.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
	    GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkInspector>/File/Close' connectTo: self selector: #close}
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkInspector>/Smalltalk/DoIt'}.
            {'<Control>P'. '<GtkInspector>/Smalltalk/PrintIt'}.
            {'<Control>I'. '<GtkInspector>/Smalltalk/InspectIt'}.
            {'<Alt>D'. '<GtkInspector>/Smalltalk/DebugIt'}.
            {'<Control>S'. '<GtkInspector>/Smalltalk/AcceptIt'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkInspector>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkInspector>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkInspector>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' accelPath: '<GtkInspector>/Smalltalk/DebugIt' connectTo: self selector: #debugIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Accept It' accelPath: '<GtkInspector>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
    ]

    createMenus [
	<category: 'user interface'>

	self addMenuItem: 'File' withSubmenu: self createFileMenus.
	self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Smalltalk' withSubmenu: self createSmalltalkMenus.
	self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
    ]

    createStatusBar [
	<category: 'user interface'>

	self statusMessage: 'Gtk Inspector'
    ]

    createToolbar [
	<category: 'user interface'>

	self
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-cut')
				connectSignal: 'clicked' to: self selector: #cut userData: nil;
				setTooltipText: 'Cut';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-copy')
				connectSignal: 'clicked' to: self selector: #copy userData: nil;
				setTooltipText: 'Copy';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-paste')
				connectSignal: 'clicked' to: self selector: #paste userData: nil;
				setTooltipText: 'Paste';
				yourself);
	    appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-undo')
				connectSignal: 'clicked' to: self selector: #undo userData: nil;
				setTooltipText: 'Undo';
				yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-redo')
				connectSignal: 'clicked' to: self selector: #redo userData: nil;
				setTooltipText: 'Redo';
				yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-execute' label: 'Do It')
				connectSignal: 'clicked' to: self selector: #doIt userData: nil;
				setTooltipText: 'Do It';
				yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-print' label: 'Print It')
				connectSignal: 'clicked' to: self selector: #printIt userData: nil;
				setTooltipText: 'Print It';
				yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-convert' label: 'Inspect It')
				connectSignal: 'clicked' to: self selector: #inspectIt userData: nil;
				setTooltipText: 'Inspect It';
				yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-sort-descending' label: 'Debug It')
				connectSignal: 'clicked' to: self selector: #debugIt userData: nil;
				setTooltipText: 'Debug It';
				yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-apply' label: 'Accept')
				connectSignal: 'clicked' to: self selector: #acceptIt userData: nil;
				setTooltipText: 'Accept';
				yourself)
    ]

   createToolsMenus [
        <category: 'user interface'>

        | menu |
        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/TabbedClassBrowser'}.
            {'<Control><shift>B'. '<GtkLauncher>/Tools/ClassBrowser'}.
            {'<Control>M'. '<GtkLauncher>/Tools/Implementors'}.
            {'<Control>N'. '<GtkLauncher>/Tools/Senders'}}.

        menu := {GTK.GtkMenuItem menuItem: 'Browser' accelPath: '<GtkLauncher>/Tools/TabbedClassBrowser' connectTo: OpenBrowserCommand selector: #execute.
            GTK.GtkMenuItem menuItem: 'Browser window' accelPath: '<GtkLauncher>/Tools/ClassBrowser' connectTo: OpenWindowedBrowserCommand selector: #execute.
            GTK.GtkMenuItem menuItem: 'Workspace' connectTo: OpenWorkspaceCommand selector: #execute.
            GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkLauncher>/Tools/Implementors' connectTo: OpenImplementorCommand selector: #execute.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkLauncher>/Tools/Senders' connectTo: OpenSenderCommand selector: #execute.
            GTK.GtkMenuItem menuItem: 'SUnit' connectTo: OpenSUnitCommand selector: #execute} asOrderedCollection.

        GtkWebView hasWebkit ifTrue: [ menu addAll: {GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Assistant' connectTo: OpenAssistantCommand selector: #execute.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Smallzilla' connectTo: OpenWebBrowserCommand selector: #execute} ].

        ^ self createNewMenuEntry: menu
    ]

    onFocusPerform: aSelector [
        <category: 'focus'>

        ^ notebookWidget getCurrentPage = 0 
            ifTrue: [ workspaceWidget hasFocus
                            ifTrue: [ workspaceWidget perform: aSelector ] ]
            ifFalse: [ browserWidget perform: aSelector ]
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

        browserWidget saveCode
    ]
]

