GtkMainWindow subclass: VisualGST [
    VisualGST class [ | compileError | ]

    | browsers outputs transcriptWidget windowsMenu |

    VisualGST class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    VisualGST class >> version [
	<category: 'accessing'>

	^ '0.6.0'
    ]

    VisualGST class >> website [
	<category: 'accessing'>

	^ 'http://visualgst.bioskop.fr/'
    ]
    
    VisualGST class >> gstWebsite [
	<category: 'accessing'>

	^ 'http://smalltalk.gnu.org/'
    ]

    VisualGST class >> compileError: aString [
	<category: 'accessing'>

	compileError text: aString
    ]

    VisualGST class >> setCompilerError: aWorkspace [
	<category: 'accessing'>

	compileError := aWorkspace
    ]

    aboutLauncher [
	<category: 'help events'>

	(GTK.GtkAboutDialog new)
	    setVersion: self class version;
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
	    setWebsite: self class website;
	    setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
	    "setAuthors: {'Gwenael Casaccio'. 'Nicolas Petton'. nil};"
	    setProgramName: 'VisualGST';
	    runBlockingAndDestroy
    ]

    browser [
	<category: 'events'>

	windowsMenu append: (GTK.GtkMenuItem label: 'Browser') showAll
    ]

    classBrowser [
	<category: 'events'>

	| widget |
	browsers addWidget: self buildClassBrowserWidget labeled: 'Browser'
    ]

    classBrowserInAWindow [
	<category: 'events'>

	GtkClassBrowser open
    ]

    gtkInspector [
	<category: 'events'>
	
	GtkInspector openOn: self
    ]

    newWorkspace [
	<category: 'events'>

	| widget |
	widget := self buildWorkspaceWidget showAll.
	outputs addWidget: widget labeled: 'Workspace'.
    ]

    quit [
	<category: 'file events'>

	GTK.Gtk mainQuit.
	ObjectMemory quit	
    ]

    open [
	<category: 'file events'>

	| file string |
	outputs currentWidget  == transcriptWidget ifTrue: [ self error: 'Can not remove the transcript tab' ].
	(GTK.GtkFileChooserDialog load: 'Load Smalltalk source' parent: window)
	    runNonBlockingAndDo: [ :dlg :res |
		res = GTK.Gtk gtkResponseAccept ifFalse: [ ^ dlg destroy ].
		file := FileStream open: dlg getFilename mode: FileStream read.
		outputs currentWidget text: file upToEnd.
		dlg destroy ]
    ]

    save [
	<category: 'file events'>
    ]

    saveAs [
	<category: 'file events'>

	| file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk source as...' parent: window)
            runNonBlockingAndDo: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifFalse: [ ^ dlg destroy ].
		file := FileStream open: dlg getFilename mode: FileStream write.
		file nextPutAll: outputs currentWidget text. 
                dlg destroy ]
    ]

    print [
	<category: 'file events'>
    ]

    saveImage [
        <category: 'events'>

        (GTK.GtkMessageDialog new: window flags: GTK.Gtk gtkDialogDestroyWithParent type: GTK.Gtk gtkMessageWarning buttons: GTK.Gtk gtkButtonsOk message: 'WARNING : You can loose all the data')
            runBlockingAndDestroy.
        ObjectMemory snapshot
    ]

    saveImageAs [
	<category: 'events'>

	(GTK.GtkMessageDialog new: window flags: GTK.Gtk gtkDialogDestroyWithParent type: GTK.Gtk gtkMessageWarning buttons: GTK.Gtk gtkButtonsOk message: 'WARNING : You can loose all the data')
	    runBlockingAndDestroy.
	(GTK.GtkFileChooserDialog save: 'Save image as...' parent: window)
	    runNonBlockingAndDo: [ :dlg :res |
		res = GTK.Gtk gtkResponseAccept ifTrue: [ | name |
		    name := dlg getFilename.
		    ObjectMemory snapshot: name ].
		dlg destroy ]
    ]

    smallZilla [
	<category: 'events'>

	GtkSmallZilla open
    ]

    workspace [
	<category: 'events'>
	
	self newWorkspace
    ]

    clearGlobalState [
	<category: 'initialization cleanup'>

	GtkNamespaceModel instVarNamed: #current put: nil.
	GtkClassModel instVarNamed: #current put: nil.
	GtkCategoryModel instVarNamed: #current put: nil.
	GtkMethodModel instVarNamed: #current put: nil.
	GtkImageModel instVarNamed: #current put: nil.
    ]

    initialize [
	<category: 'initialization'>

	super initialize.
	window maximize.
	self
	    clearGlobalState;
	    title: 'VisualGST';
	    createMenus;
	    createToolbar;
	    createStatusBar;
	    centralWidget: self buildCentralWidget
    ]

    postInitialize [
	<category: 'initialization'>

	browsers grabFocus
    ]

    buildNotebookWorkspaceWidget [
	<category: 'user interface'>

	| cmp |
	outputs := GtkNotebookWidget new
				initialize;
				parentWindow: window;
				showAll;
				yourself.
	self class setCompilerError: (cmp := self buildWorkspaceWidget).
	^ outputs
	    addPermanentWidget: (transcriptWidget := self buildTranscriptWidget) labeled: 'Transcript';
	    addPermanentWidget: cmp labeled: 'Compiler error(s)';
	    addWidget: self buildWorkspaceWidget labeled: 'Workspace';
	    yourself
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	^ GTK.GtkVPaned new
	    pack1: self buildClassBrowserTabbedWidget mainWidget resize: true shrink: true;
	    pack2: self buildNotebookWorkspaceWidget mainWidget resize: true shrink: false;
	    yourself
    ]

    buildClassBrowserTabbedWidget [
	<category: 'user interface'>

	browsers := GtkNotebookWidget new
					initialize;
					parentWindow: window;
					showAll;
					yourself.
	browsers addWidget: self buildClassBrowserWidget labeled: 'Browser'.
	^ browsers
	    
    ]

    buildClassBrowserWidget [
	<category: 'user interface'>

	^ (GtkClassBrowserWidget new)
	    parentWindow: window;
	    initialize;
	    yourself
    ]

    buildTranscriptWidget [
	<category: 'user interface'>

	^ GtkTranscriptWidget new
	    parentWindow: window;
	    initialize;
	    yourself
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ GtkWorkspaceWidget new
	    parentWindow: window;
	    initialize;
	    yourself
    ]

    createEditMenus [
	<category: 'user interface'>

	self accelGroup append: {{'<Control>Z'. '<GtkLauncher>/Edit/Undo'}.
	    {'<Control>R'. '<GtkLauncher>/Edit/Redo'}.
	    {'<Control>X'. '<GtkLauncher>/Edit/Cut'}.
	    {'<Control>C'. '<GtkLauncher>/Edit/Copy'}.
	    {'<Control>V'. '<GtkLauncher>/Edit/Paste'}.
	    {'<Control>A'. '<GtkLauncher>/Edit/SelectAll'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkLauncher>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkLauncher>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkLauncher>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkLauncher>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkLauncher>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkLauncher>/Edit/SelectAll' connectTo: self selector: #selectAll.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Clear Transcript' connectTo: self selector: #clearTranscriptWidget}
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

    createFileMenus [
	<category: 'user interface'>

        self accelGroup append: 
	    {{'<Control>O'. '<GtkLauncher>/File/Open'}.
	    {'<Control>S'. '<GtkLauncher>/File/Save'}.
	    {'<Control><Shift>S'. '<GtkLauncher>/File/SaveAs'}.
	    {'<Control>Q'. '<GtkLauncher>/File/Quit'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New worskpace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkLauncher>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #save.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkLauncher>/File/SaveAs' connectTo: self selector: #saveAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #printIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Quit' accelPath: '<GtkLauncher>/File/Quit' connectTo: self selector: #quit}
    ]

    createHistoryMenus [
	<category: 'user interface'>

	self accelGroup append:
            {{'<Alt>Left'. '<GtkLauncher>/History/Back'}.
            {'<Alt>Right'. '<GtkLauncher>/History/Forward'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Back' accelPath: '<GtkLauncher>/History/Back' connectTo: self selector: #back.
            GTK.GtkMenuItem menuItem: 'Forward' accelPath: '<GtkLauncher>/History/Forward' connectTo: self selector: #forward}
    ]

    createSmalltalkMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkLauncher>/Smalltalk/DoIt'}.
            {'<Control>P'. '<GtkLauncher>/Smalltalk/PrintIt'}.
            {'<Control>I'. '<GtkLauncher>/Smalltalk/InspectIt'}.
	    {'<Alt>D'. '<GtkLauncher>/Smalltalk/DebugIt'}.
	    {'<Control>S'. '<GtkLauncher>/Smalltalk/AcceptIt'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkLauncher>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkLauncher>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkLauncher>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' accelPath: '<GtkLauncher>/Smalltalk/DebugIt' connectTo: self selector: #debugIt.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Accept It' accelPath: '<GtkLauncher>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
    ]

    createHelpMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Help Contents' connectTo: self selector: #helpcontents.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'About Launcher' connectTo: self selector: #aboutLauncher.
	    GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
	<category: 'user interface'>

	self createMainMenu: {#('File' #createFileMenus).
	    #('Edit' #createEditMenus).
	    #('History' #createHistoryMenus).
	    #('Namespace' #createNamespaceMenus).
	    #('Class' #createClassMenus).
	    #('Category' #createCategoryMenus).
	    #('Method' #createMethodMenus).
	    #('Smalltalk' #createSmalltalkMenus).
	    #('Tools' #createToolsMenus).
	    #('Help' #createHelpMenus)}
    ]

    createStatusBar [
	<category: 'user interface'>

	self statusMessage: 'Gtk Launcher'
    ]

    createToolbar [
	<category: 'user interface'>

	self
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-new');
	    appendSeparator;
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-save');
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-save-as');
	    appendSeparator;
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-cut');
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-copy');
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-paste');
	    appendSeparator;
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-execute')
    ]

    createToolsMenus [
	<category: 'user interface'>
        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/ClassBrowser'}.
	    {'<Control>M'. '<GtkLauncher>/Tools/Implementors'}.
            {'<Control>N'. '<GtkLauncher>/Tools/Senders'}}.

	^ self createNewMenuEntry:  {GTK.GtkMenuItem menuItem: 'Browser' connectTo: self selector: #classBrowser.
	    GTK.GtkMenuItem menuItem: 'Browser window' accelPath: '<GtkLauncher>/Tools/ClassBrowser' connectTo: self selector: #classBrowserInAWindow.
	    GTK.GtkMenuItem menuItem: 'Workspace' connectTo: self selector: #workspace.
            GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkLauncher>/Tools/Implementors' connectTo: self selector: #implementors.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkLauncher>/Tools/Senders' connectTo: self selector: #senders.
	    GTK.GtkMenuItem menuItem: 'SUnit' connectTo: self selector: #sunit.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Assistant' connectTo: self selector: #gtkAssistant.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Smallzilla' connectTo: self selector: #webBrowser}
    ]

    isCurrentWidgetTranscript [
	<category: 'testing'>

	^ outputs currentWidget == transcriptWidget
    ]

    undo [
	<category: 'edit events'>

	self isCurrentWidgetTranscript ifTrue: [ outputs currentWidget hasFocus ifTrue: [ ^ self ] ].
	self onFocusPerform: #undo
    ]

    redo [
	<category: 'edit events'>

	self isCurrentWidgetTranscript ifTrue: [ outputs currentWidget hasFocus ifTrue: [ ^ self ] ].
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

    clearTranscriptWidget [
	<category: 'edit events'>

	transcriptWidget clear
    ]

    onFocusPerform: aSelector [
	<category: 'focus'>

	^ browsers hasFocus 
	    ifTrue: [ browsers currentWidget perform: aSelector ]
	    ifFalse: [ outputs hasFocus 
			    ifTrue: [ outputs currentWidget perform: aSelector ] ].
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

	browsers currentWidget acceptIt
    ]

    implementors [
	<category: 'smalltalk events'>

	GtkImplementor open
    ]

    senders [
	<category: 'smalltalk events'>

	GtkSender open
    ]

    gtkAssistant [
	<category: 'tools events'>

	GtkAssistant open
    ]

    webBrowser [
	<category: 'tools events'>

	GtkWebBrowser open
    ]

    back [
	<category: 'history events'>

	browsers currentWidget back
    ]

    forward [
	<category: 'history events'>

	browsers currentWidget forward
    ]

    helpcontents [
	<category: 'help events'>

	GtkWebBrowser openOn: 'http://smalltalk.gnu.org/documentation'
    ]

    fileoutNamespace [
        <category: 'namespace events'>

	browsers currentWidget fileoutNamespace
    ]

    newNamespace [
        <category: 'namespace events'>

        browsers currentWidget newNamespace
    ]

    renameNamespace [
        <category: 'namespace events'>

        browsers currentWidget renameNamespace
    ]

    deleteNamespace [
        <category: 'namespace events'>

        browsers currentWidget deleteNamespace
    ]

    inspectNamespace [
        <category: 'namespace events'>

        browsers currentWidget inspectNamespace
    ]

    newClass [
        <category: 'class events'>

        browsers currentWidget newClass
    ]

    renameClass [
        <category: 'class events'>

	browsers currentWidget renameClass
    ]

    deleteClass [
        <category: 'class events'>

        browsers currentWidget deleteClass
    ]

    inspectClass [
        <category: 'class events'>

        browsers currentWidget inspectClass
    ]

    fileoutClass [
        <category: 'class events'>

        browsers currentWidget fileoutClass
    ]

    newCategory [
        <category: 'category events'>

        browsers currentWidget newCategory
    ]

    renameCategory [
        <category: 'category events'>

        browsers currentWidget renameCategory
    ]

    deleteCategory [
        <category: 'category events'>

        browsers currentWidget deleteCategory
    ]

    inspectCategory [
        <category: 'category events'>

        browsers currentWidget inspectCategory
    ]

    fileoutCategory [
        <category: 'method events'>

	browsers currentWidget fileoutCategory
    ]

    newMethod [
        <category: 'method events'>

        browsers currentWidget newMethod
    ]

    deleteMethod [
        <category: 'method events'>

        browsers currentWidget deleteMethod
    ]

    inspectMethod [
        <category: 'method events'>

        browsers currentWidget inspectMethod
    ]

    fileoutMethod [
        <category: 'method events'>

	browsers currentWidget fileoutMethod
    ]

    sunit [
	<category: 'tools events'>

	GtkSUnit open
    ]
]

