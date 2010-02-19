GtkMainWindow subclass: GtkClassBrowser [
    | browserWidget |

    GtkClassBrowser class >> open [
	<category: 'user interface'>

	^ self openSized: 600@400
    ]

    aboutBrowser [
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
	    setComments: 'This is a system browser for GNU Smalltalk.';
	    "setAuthors: {'Gwenael Casaccio'. 'Nicolas Petton'};"
	    setProgramName: 'GNU Smalltalk Browser';
	    showModalDestroy
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

    initialize [
	<category: 'initialization'>

	super initialize.
	self
	    title: 'GNU Smalltalk Browser';
	    createMenus;
	    createToolbar;
	    createStatusBar;
	    centralWidget: self buildClassBrowserWidget mainWidget
    ]

    postInitialize [
	<category: 'user interface'>

	browserWidget grabFocus.
        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]

    buildClassBrowserWidget [
	<category: 'user interface'>

	^ browserWidget := (GtkClassBrowserWidget new)
			    parentWindow: window;
			    initialize;
			    yourself
    ]

    createEditMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control><Shift>Z'. '<GtkBrowser>/Edit/Cancel'}.
	    {'<Control>Z'. '<GtkBrowser>/Edit/Undo'}.
            {'<Control>R'. '<GtkClassBrowser>/Edit/Redo'}.
            {'<Control>X'. '<GtkClassBrowser>/Edit/Cut'}.
            {'<Control>C'. '<GtkClassBrowser>/Edit/Copy'}.
            {'<Control>V'. '<GtkClassBrowser>/Edit/Paste'}.
            {'<Control>A'. '<GtkClassBrowser>/Edit/SelectAll'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkBrowser>/Edit/Cancel' connectTo: self selector: #cancel.
	    GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkBrowser>/Edit/Undo' connectTo: self selector: #undo.
	    GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkClassBrowser>/Edit/Redo' connectTo: self selector: #redo.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkClassBrowser>/Edit/Cut' connectTo: self selector: #cut.
	    GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkClassBrowser>/Edit/Copy' connectTo: self selector: #copy.
	    GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkClassBrowser>/Edit/Paste' connectTo: self selector: #paste.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkClassBrowser>/Edit/SelectAll' connectTo: self selector: #selectAll}.
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkClassBrowser>/Smalltalk/DoIt'}.
            {'<Control>P'. '<GtkClassBrowser>/Smalltalk/PrintIt'}.
            {'<Control>I'. '<GtkClassBrowser>/Smalltalk/InspectIt'}.
            {'<Control>M'. '<GtkClassBrowser>/Smalltalk/Implementors'}.
            {'<Control>N'. '<GtkClassBrowser>/Smalltalk/Senders'}.
	    {'<Control>S'. '<GtkClassBrowser>/Smalltalk/AcceptIt'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkClassBrowser>/Smalltalk/DoIt' connectTo: self selector: #doIt.
        GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkClassBrowser>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
        GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkClassBrowser>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
        GTK.GtkMenuItem menuItem: 'Debug It' connectTo: self selector: #debugIt.
	GTK.GtkMenuItem new.
	GTK.GtkMenuItem menuItem: 'Accept-It' accelPath: '<GtkClassBrowser>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
    ]

    createFileMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control>O'. '<GtkClassBrowser>/File/Open'}.
            {'<Control><Shift>S'. '<GtkClassBrowser>/File/SaveAs'}.
            {'<Control>Q'. '<GtkClassBrowser>/File/Close'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkClassBrowser>/File/Open' connectTo: self selector: #open.
	    GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #save.
	    GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkClassBrowser>/File/SaveAs' connectTo: self selector: #saveAs.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
	    GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkClassBrowser>/File/Close' connectTo: self selector: #close}
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

    createHelpMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About Class Browser' connectTo: self selector: #aboutBrowser.
	    GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
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

    createStatusBar [
	<category: 'user interface'>

	self statusMessage: 'Gtk Browser'
    ]

    createToolbar [
	<category: 'user interface'>

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
        appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-convert' label: 'Inspet It')
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

