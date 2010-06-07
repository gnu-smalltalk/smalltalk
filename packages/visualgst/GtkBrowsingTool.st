GtkMainWindow subclass: GtkBrowsingTool [
    <comment: 'I am the base for various tools of VisualGST.'>

    | state |

    initialize [
        <category: 'initialization'>

        super initialize.
        self
            title: self windowTitle;
            createMenus;
            createToolbar;
            createStatusBar;
            centralWidget: self buildCentralWidget.
    ]

    windowTitle [
        <category: 'widget-skeleton'>
        <comment: 'I return the visible name of the window.'>
        self subclassResponcibility
    ]

    aboutTitle [
        <category: 'widget-skeleton'>
        <comment: 'I return the visible name for the Help->About entry'>
        self subclassResponcibility
    ]

    showAboutDialog [
	| gst |

	gst := VisualGST.
	(gst isKindOf: Namespace)
	    ifTrue: [gst := gst classAt: 'VisualGST'].

        (GTK.GtkAboutDialog new)
            setVersion: gst version;
            setLicense: gst license;
            setWebsite: gst website;
            setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
            setProgramName: 'VisualGST ', self windowTitle; 
            showModalDestroy
    ] 

    createFileMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Control>O'. '<GtkBrowsingTool>/File/Open'}.
            {'<Control>S'. '<GtkBrowsingTool>/File/Save'}.
            {'<Control><Shift>S'. '<GtkBrowsingTool>/File/SaveAs'}.
            {'<Control>Q'. '<GtkBrowsingTool>/File/Quit'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkBrowsingTool>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' accelPath: '<GtkBrowsingTool>/File/Save' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkBrowsingTool>/File/SaveAs' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkBrowsingTool>/File/Quit' connectTo: self selector: #close}
    ]

    createEditMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control><shift>Z'. '<GtkBrowsingTool>/Edit/Cancel'}.
            {'<Control>Z'. '<GtkBrowsingTool>/Edit/Undo'}.
            {'<Control>R'. '<GtkBrowsingTool>/Edit/Redo'}.
            {'<Control>X'. '<GtkBrowsingTool>/Edit/Cut'}.
            {'<Control>C'. '<GtkBrowsingTool>/Edit/Copy'}.
            {'<Control>V'. '<GtkBrowsingTool>/Edit/Paste'}.
            {'<Control>A'. '<GtkBrowsingTool>/Edit/SelectAll'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkBrowsingTool>/Edit/Cancel' connectTo: self selector: #cancel.
            GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkBrowsingTool>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkBrowsingTool>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkBrowsingTool>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkBrowsingTool>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkBrowsingTool>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkBrowsingTool>/Edit/SelectAll' connectTo: self selector: #selectAll}
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkLauncher>/Smalltalk/DoIt'. self. #doIt}.
            {'<Control>P'. '<GtkLauncher>/Smalltalk/PrintIt'. self. #printIt}.
            {'<Control>I'. '<GtkLauncher>/Smalltalk/InspectIt'. self. #inspectIt}.
            {'<Control>M'. '<GtkLauncher>/Smalltalk/Implementors'. self. #implementors}.
            {'<Control>N'. '<GtkLauncher>/Smalltalk/Senders'. self. #senders}.
            {'<Control>S'. '<GtkLauncher>/Smalltalk/AcceptIt'. self. #acceptIt}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkLauncher>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkLauncher>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkLauncher>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' connectTo: self selector: #debugIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkLauncher>/Smalltalk/Implementors' connectTo: self selector: #implementors.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkLauncher>/Smalltalk/Senders' connectTo: self selector: #senders.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Accept' accelPath: '<GtkLauncher>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
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

    createHelpMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: self aboutTitle connectTo: self selector: #showAboutDialog.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]

    createStatusBar [
        <category: 'user interface'>

        self statusMessage: 'SUnit'
    ]

    createToolbar [
        <category: 'user interface'>

        self
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-save')
                                connectSignal: 'clicked' to: SaveImageCommand selector: #execute;
                                setTooltipText: 'Save the image';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-cut')
                                connectSignal: 'clicked' to: self selector: #cut;
                                setTooltipText: 'Cut';
                               yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-copy')
                                connectSignal: 'clicked' to: self selector: #copy;
                                setTooltipText: 'Copy';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-paste')
                                connectSignal: 'clicked' to: self selector: #paste;
                                setTooltipText: 'Paste';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-undo')
                                connectSignal: 'clicked' to: self selector: #undo;
                                setTooltipText: 'Undo';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-redo')
                                connectSignal: 'clicked' to: self selector: #redo;
                                setTooltipText: 'Redo';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-execute' label: 'Do It')
                                connectSignal: 'clicked' to: self selector: #doIt;
                                setTooltipText: 'Do It';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-print' label: 'Print It')
                                connectSignal: 'clicked' to: self selector: #printIt;
                                setTooltipText: 'Print It';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-convert' label: 'Inspect It')
                                connectSignal: 'clicked' to: self selector: #inspectIt;
                                setTooltipText: 'Inspect It';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-sort-descending' label: 'Debug It')
                                connectSignal: 'clicked' to: self selector: #debugIt;
                                setTooltipText: 'Debug It';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-apply' label: 'Accept')
                                connectSignal: 'clicked' to: self selector: #acceptIt;
                                setTooltipText: 'Accept';
                                yourself)
    ]

    postInitialize [
        <category: 'initialization'>

        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]

    delete: aGtkWidget event: aGdkEvent [
        <category: 'window events'>

        self hasChanged ifFalse: [ ^ window hideAll ].
        self saveCodeOnClose: [ window hideAll ] onSave: [ state saveSource. window hideAll ].
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
                                tip: 'If you do not save, your changes to %1 will be lost...' % {state}.

        dialog
            addButton: 'Close without saving' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Save' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: closeEvent.
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]

    checkCodeWidget [
        <category: 'text editing'>

        self hasChanged ifFalse: [ self clearUndo. ^ self ].
        self saveCodeOnSave: [ state saveSource ].
        self clearUndo
    ]

    saveCodeOnSave: saveEvent [
        <category: 'saving'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Save changes to this method?'
                                tip: 'If you do not save, your changes to %1 will be lost...' % {state}.

        dialog
            addButton: 'Cancel' responseId: 0;
            addButton: 'Save' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]

    hasChanged [
        <category: 'testing'>

        self subclassResponcibility
    ]

    clearUndo [
	<category: 'undo'>

	
        self subclassResponcibility
    ]

]

