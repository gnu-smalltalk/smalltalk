GtkMainWindow subclass: GtkVisualGSTTool [
    <comment: 'I am the base for various tools of VisualGST.'>

    aboutTitle [
        <category: 'widget-skeleton'>
        <comment: 'I return the visible name for the Help->About entry'>
        ^'About VisualGST...'
    ]

    showAboutDialog [
        (GTK.GtkAboutDialog new)
            setVersion: VisualGST.GtkVisualGSTTool version;
            setLicense: VisualGST.GtkVisualGSTTool license;
            setWebsite: VisualGST.GtkVisualGSTTool website;
            setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
            setProgramName: 'VisualGST'; 
            showModalDestroy
    ] 

    createFileMenus [
        <category: 'user interface'>

        | menu |
        self accelGroup append:
            {{'<Control>W'. '<GtkVisualGSTTool>/File/Close'}.
             {'<Control>Q'. '<GtkVisualGSTTool>/File/Quit'}}.

        menu := OrderedCollection withAll: {
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new}.
        self exitOnClose ifFalse: [
            menu add: (GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkVisualGSTTool>/File/Close' connectTo: self selector: #close) ].
        menu add: (GTK.GtkMenuItem menuItem: 'Quit' accelPath: '<GtkVisualGSTTool>/File/Quit' connectTo: self selector: #quit).
        ^menu
    ]

    exitOnClose [
        <category: 'file events'>

        ^self == GtkLauncher uniqueInstance
    ]

    quit [
        <category: 'file events'>

        GtkLauncher uniqueInstance quit
    ]

    createEditMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control><shift>Z'. '<GtkVisualGSTTool>/Edit/Cancel'}.
            {'<Control>Z'. '<GtkVisualGSTTool>/Edit/Undo'}.
            {'<Control>Y'. '<GtkVisualGSTTool>/Edit/Redo'}.
            {'<Control>X'. '<GtkVisualGSTTool>/Edit/Cut'}.
            {'<Control>C'. '<GtkVisualGSTTool>/Edit/Copy'}.
            {'<Control>V'. '<GtkVisualGSTTool>/Edit/Paste'}.
            {'<Control>F'. '<GtkVisualGSTTool>/Edit/Find'}.
            {'<Control>R'. '<GtkVisualGSTTool>/Edit/Replace'}}.

        ^{GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkVisualGSTTool>/Edit/Cancel' connectTo: self selector: #cancel.
            GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkVisualGSTTool>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkVisualGSTTool>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkVisualGSTTool>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkVisualGSTTool>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkVisualGSTTool>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkVisualGSTTool>/Edit/SelectAll' connectTo: self selector: #selectAll.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Find' accelPath: '<GtkVisualGSTTool>/Edit/Find' connectTo: self selector: #find.
            GTK.GtkMenuItem menuItem: 'Replace' accelPath: '<GtkVisualGSTTool>/Edit/Replace' connectTo: self selector: #replace}
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkVisualGSTTool>/Smalltalk/DoIt'. self. #doIt}.
            {'<Alt>D'. '<GtkVisualGSTTool>/Smalltalk/DebugIt'. self. #printIt}.
            {'<Control>P'. '<GtkVisualGSTTool>/Smalltalk/PrintIt'. self. #printIt}.
            {'<Control>I'. '<GtkVisualGSTTool>/Smalltalk/InspectIt'. self. #inspectIt}.
            "{'<Control>M'. '<GtkVisualGSTTool>/Smalltalk/Implementors'. self. #implementors}.
            {'<Control>N'. '<GtkVisualGSTTool>/Smalltalk/Senders'. self. #senders}."
            {'<Control>S'. '<GtkVisualGSTTool>/Smalltalk/AcceptIt'. self. #acceptIt}}.

        ^{GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkVisualGSTTool>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkVisualGSTTool>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkVisualGSTTool>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' accelPath: '<GtkVisualGSTTool>/Smalltalk/DebugIt' connectTo: self selector: #debugIt.
            GTK.GtkMenuItem new.
            "GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkVisualGSTTool>/Smalltalk/Implementors' connectTo: self selector: #implementors.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkVisualGSTTool>/Smalltalk/Senders' connectTo: self selector: #senders.
            GTK.GtkMenuItem new."
            GTK.GtkMenuItem menuItem: 'Accept' accelPath: '<GtkVisualGSTTool>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
    ]

    createToolsMenus [
        <category: 'user interface'>

        | menu |
        self accelGroup append: {{'<Control><shift>B'. '<GtkVisualGSTTool>/Tools/ClassBrowser'}.
            {'<Control>M'. '<GtkVisualGSTTool>/Tools/Implementors'}.
            {'<Control>N'. '<GtkVisualGSTTool>/Tools/Senders'}}.

        menu := {GTK.GtkMenuItem menuItem: 'Browser window' accelPath: '<GtkVisualGSTTool>/Tools/ClassBrowser' connectTo: self selector: #newClassBrowser.
            GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkVisualGSTTool>/Tools/Implementors' connectTo: self selector: #newImplementorBrowser.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkVisualGSTTool>/Tools/Senders' connectTo: self selector: #newSenderBrowser.
            GTK.GtkMenuItem menuItem: 'SUnit' connectTo: self selector: #newSUnitBrowser} asOrderedCollection.

        GtkWebView hasWebkit ifTrue: [ menu := menu, {GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Assistant' connectTo: OpenAssistantCommand selector: #execute.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Smallzilla' connectTo: OpenWebBrowserCommand selector: #execute} ].

        ^menu
    ]

    state [
	<category: 'tools events'>

	^BrowserState new
    ]

    selectedText [
        <category: 'tools events'>

        "Since #hasSelection returns false, this will never be called."
        self shouldNotImplement
    ]

    selectedMethodSymbol [
        <category: 'tools events'>

        ^STInST.RBParser selectedSymbol: self selectedText
    ]

    hasSelection [
	<category: 'tools events'>

	^false
    ]

    sourceCodeWidgetHasFocus [
	<category: 'tools events'>

	^false
    ]

    browserHasFocus [
	<category: 'tools events'>

	^false
    ]

    newSUnitBrowser [
	<category: 'tools events'>

	OpenSUnitCommand on: self
    ]

    newClassBrowser [
	<category: 'tools events'>

	OpenWindowedBrowserCommand on: self
    ]

    newSenderBrowser [
	<category: 'tools events'>

	OpenSenderCommand on: self
    ]

    newImplementorBrowser [
	<category: 'tools events'>

	OpenImplementorCommand on: self
    ]

    helpContents [
	<category: 'help events'>

	GtkWebBrowser openOn: 'http://smalltalk.gnu.org/documentation'
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Help Contents' connectTo: self selector: #helpContents.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: self aboutTitle connectTo: self selector: #showAboutDialog.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
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

]

