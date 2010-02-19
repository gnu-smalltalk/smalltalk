GtkMainWindow subclass: GtkSUnit [
    | state namespaceWidget classWidget methodWidget sourceCodeWidget successfullWidget failedWidget errorWidget namespace class |

    createFileMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Control>O'. '<GtkSUnit>/File/Open'}.
            {'<Control>S'. '<GtkSUnit>/File/Save'}.
            {'<Control><Shift>S'. '<GtkSUnit>/File/SaveAs'}.
            {'<Control>Q'. '<GtkSUnit>/File/Quit'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkSUnit>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' accelPath: '<GtkSUnit>/File/Save' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkSUnit>/File/SaveAs' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkSUnit>/File/Quit' connectTo: self selector: #close}
    ]

    createEditMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control><shift>Z'. '<GtkSUnit>/Edit/Cancel'}.
            {'<Control>Z'. '<GtkSUnit>/Edit/Undo'}.
            {'<Control>R'. '<GtkSUnit>/Edit/Redo'}.
            {'<Control>X'. '<GtkSUnit>/Edit/Cut'}.
            {'<Control>C'. '<GtkSUnit>/Edit/Copy'}.
            {'<Control>V'. '<GtkSUnit>/Edit/Paste'}.
            {'<Control>A'. '<GtkSUnit>/Edit/SelectAll'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkSUnit>/Edit/Cancel' connectTo: self selector: #cancel.
            GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkSUnit>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkSUnit>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkSUnit>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkSUnit>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkSUnit>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkSUnit>/Edit/SelectAll' connectTo: self selector: #selectAll}
    ]

    createRunMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Run test' connectTo: self selector: #runTest}
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

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About SUnit' connectTo: self selector: #aboutSUnit.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Run' withSubmenu: self createRunMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]


    createStatusBar [
        <category: 'user interface'>

        self statusMessage: 'SUnit'
    ]

    createToolbar [
	<category: 'user interface'>

        | package |
        package := PackageLoader packageAt: 'VisualGST'.
	self
	    "appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-new')
				connectSignal: 'clicked' to: OpenWorkspaceCommand selector: #execute userData: nil;
				setTooltipText: 'Create a new workspace';
				yourself);"
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-save')
				connectSignal: 'clicked' to: SaveImageCommand selector: #execute userData: nil;
				setTooltipText: 'Save the image';
				yourself);
	    appendSeparator;
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
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (package / 'Icons/go-run.png') file displayString) label: 'Run test')
                                connectSignal: 'clicked' to: self selector: #runTest userData: nil;
                                setTooltipText: 'Run test';
                                yourself)
    ]

    buildNamespaceAndClassWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
	    pack1: self buildNamespaceWidget resize: true shrink: false;
	    pack2: self buildClassWidget resize: true shrink: false;
	    yourself
    ]

    buildNamespaceAndClassAndMethodWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
	    pack1: self buildNamespaceAndClassWidget resize: true shrink: false;
	    pack2: self buildMethodWidget resize: true shrink: false;
	    yourself
    ]

    buildMiniBrowser [
	<category: 'user interface'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildNamespaceAndClassAndMethodWidget resize: true shrink: false;
	    pack2: self buildSourceCodeWidget resize: true shrink: false;
	    yourself
    ]

    buildResultWidget [
	<category: 'user interface'>

	^ GTK.GtkNotebook new
	    appendPage: self buildSuccesfullWidget tabLabel: (GTK.GtkLabel new: 'Successful Tests');
	    appendPage: self buildFailedWidget tabLabel: (GTK.GtkLabel new: 'Failed Tests');
	    appendPage: self buildErrorWidget tabLabel: (GTK.GtkLabel new: 'Errors Tests');
	    yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildMiniBrowser resize: true shrink: false;
	    pack2: self buildResultWidget resize: true shrink: false;
	    yourself
    ]

    initialize [
        <category: 'initialization'>

	state := NamespaceState on: self with: Smalltalk.
        super initialize.
        self
            title: 'SUnit';
            createMenus;
            createToolbar;
            createStatusBar;
            centralWidget: self buildCentralWidget.
    ]

    postInitialize [
        <category: 'initialization'>

        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]

    aboutSUnit [
        <category: 'events'>

        (GTK.GtkAboutDialog new)
            setVersion: VisualGST version;
            setLicense: 'Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
            setWebsite: VisualGST website;
            setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
            "setAuthors: {'Gwenael Casaccio'. 'Nicolas Petton'};"
            setProgramName: 'GNU Smalltalk SUnit';
            run
    ]

    buildNamespaceWidget [
	<category: 'user interface'>

	namespaceWidget := GtkCategorizedNamespaceWidget showAll 
				whenSelectionChangedSend: #onNamespaceChanged to: self;
				yourself.
	^ namespaceWidget mainWidget
    ]

    buildClassWidget [
	<category: 'user interface'>

	classWidget := GtkClassSUnitWidget showAll 
				selectionMode: GTK.Gtk gtkSelectionMultiple;
				whenSelectionChangedSend: #onClassChanged to: self;
				yourself.
	^ classWidget mainWidget
    ]

    buildMethodWidget [
	<category: 'user interface'>

	methodWidget := GtkMethodSUnitWidget showAll
				whenSelectionChangedSend: #onMethodChanged to: self;
                                yourself.
        ^ methodWidget mainWidget
    ]

    buildSourceCodeWidget [
        <category: 'user interface'>

        sourceCodeWidget := GtkSourceCodeWidget showAll.
	sourceCodeWidget parentWindow: window.
	sourceCodeWidget browser: self.
        ^ sourceCodeWidget mainWidget
    ]

    buildSuccesfullWidget [
	<category: 'user interface'>

	successfullWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ successfullWidget mainWidget
    ]

    buildFailedWidget [
	<category: 'user interface'>

	failedWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ failedWidget mainWidget
    ]

    buildErrorWidget  [
	<category: 'user interface'>

	errorWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ errorWidget mainWidget
    ]

    onNamespaceChanged [
	<category: 'namespace events'>

	self checkCodeWidget.
        namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	self selectANamespace: namespaceWidget selectedNamespace
    ]

    selectANamespace: aNamespace [
	<category: 'browser methods'>

	aNamespace = namespaceWidget selectedNamespace ifFalse: [
            namespaceWidget selectANamespace: aNamespace ].
        namespace := aNamespace.
	aNamespace isNil ifTrue: [ ^self ].
        classWidget namespace: aNamespace.
	state := NamespaceState on: self with: aNamespace
    ]

    onClassChanged [
	<category: 'class events'>

	self checkCodeWidget.
        classWidget hasSelectedClass ifFalse: [ ^ self ].
	self selectAClass: classWidget selectedClass
    ]

    selectAClass: aClass [
	<category: 'browser methods'>

	aClass = classWidget selectedClass ifFalse: [
            classWidget selectAClass: aClass ].
        class := aClass.
	aClass isNil ifTrue: [ ^self ].
	methodWidget class: class withCategory: '*'.
	state := CategoryState on: self with: class -> '*'.
	self selectAnInstanceMethod: nil.
    ]

    onMethodChanged [
	<category: 'method events'>

	self checkCodeWidget.
	self selectAnInstanceMethod: methodWidget selectedMethodSymbol.
    ]

    selectAnInstanceMethod: aSymbol [
	<category: 'browser methods'>

	aSymbol = methodWidget selectedMethodSymbol ifFalse: [
            methodWidget selectAMethod: aSymbol asString ].
	aSymbol isNil ifTrue: [ ^self ].
	sourceCodeWidget sourceCode: methodWidget sourceCode.
	state := MethodState on: self with: class -> methodWidget selectedMethod
    ]

    classOrMetaSelected [
	<category: 'browser methods'>

	^class
    ]

    selectedCategory [
	<category: 'browser methods'>

	^methodWidget selectedMethod
	    ifNil: [ 'unit tests' ]
	    ifNotNil: [ :method | method methodCategory ]
    ]

    runTest [
	<category: 'run events'>

	| suite results name |
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	suite := TestSuite named: classWidget allClassNames.
	classWidget selectedClasses do: [ :elem |
	    elem selectors do: [ :each |
		(each matchRegex: 'test' from: 1 to: 4)
		    ifTrue: [ suite addTest: (elem selector: each) ] ] ].
	suite logPolicy: TestBacktraceLog new.
	results := suite run.

	successfullWidget results: results passed.
	failedWidget results: results failures.
	errorWidget results: results errors.

	results failures do: [ :each | each "logPolicy logStatus inspect" printNl ].
    ]

    onFocusPerform: aSymbol [
	<category: 'events'>

	sourceCodeWidget hasFocus ifTrue: [ sourceCodeWidget perform: aSymbol ]
    ]

    acceptIt [
	<category: 'method events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	AddMethodCommand on: self.
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

        sourceCodeWidget hasChanged ifFalse: [ ^ super close ].
        self saveCodeOnClose: [ super close ] onSave: [ state saveSource. super close ]
    ]

    delete: aGtkWidget event: aGdkEvent [
        <category: 'window events'>

        sourceCodeWidget hasChanged ifFalse: [ ^ window hideAll ].
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

        self hasChanged ifFalse: [ sourceCodeWidget clearUndo. ^ self ].
        self saveCodeOnSave: [ state saveSource ].
        sourceCodeWidget clearUndo
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

        ^ sourceCodeWidget hasChanged
    ]

    sourceCode [
        <category: 'accessing'>

        ^ sourceCodeWidget sourceCode
    ]

    codeSaved [
	<category: 'code saved'>

	sourceCodeWidget codeSaved
    ]

]

