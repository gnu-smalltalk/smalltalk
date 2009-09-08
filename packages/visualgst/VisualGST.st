GtkMainWindow subclass: VisualGST [
    VisualGST class [ | compileError | ]

    | currentWidget notebook notebookPages transcriptWidget windowsMenu centralBrowser |

    VisualGST class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    VisualGST class >> version [
	<category: 'accessing'>

	^ '0.5.0'
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
	widget := self buildClassBrowserWidget showAll; yourself.
	notebookPages addLast: widget.
        notebook appendPage: widget mainWidget tabLabel: (self buildLabelWidget: 'Class Browser' withIcon: GTK.Gtk gtkStockClose at: widget)
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
	notebookPages addLast: widget.
	notebook appendPage: widget mainWidget tabLabel: (self buildLabelWidget: 'Workspace' withIcon: GTK.Gtk gtkStockClose at: widget)
    ]

    quit [
	<category: 'file events'>

	GTK.Gtk mainQuit.
	ObjectMemory quit	
    ]

    open [
	<category: 'file events'>

	| file string |
	currentWidget == transcriptWidget ifTrue: [ self error: 'Can not remove the transcript tab' ].
	(GTK.GtkFileChooserDialog load: 'Load Smalltalk source' parent: window)
	    runNonBlockingAndDo: [ :dlg :res |
		res = GTK.Gtk gtkResponseAccept ifFalse: [ ^ dlg destroy ].
		file := FileStream open: dlg getFilename mode: FileStream read.
		currentWidget text: file upToEnd.
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
		file nextPutAll: currentWidget text. 
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
	
	self newWorkspace.
	"workspaceWindows add: (GtkWorkspaceWidget new)
				initialize;
				mainWidget.
	windowsMenu append: (GtkMenuItem label: 'workspace') showAll"
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
	notebookPages := OrderedCollection new.
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

	centralBrowser grabFocus
    ]

    buildNotebookWorkspaceWidget [
	<category: 'user interface'>

	| workspaceWidget cmp |
        notebook := GTK.GtkNotebook new
                        connectSignal: 'switch-page' to: self selector: #switchPageOn:page:number: userData: nil.
        currentWidget := transcriptWidget := self buildTranscriptWidget.
	cmp := self buildWorkspaceWidget.
	self class setCompilerError: (cmp := self buildWorkspaceWidget).
	workspaceWidget := self buildWorkspaceWidget.
        notebookPages
            addLast: transcriptWidget;
	    addLast: cmp;
            addLast: workspaceWidget.
        ^ notebook
            appendPage: transcriptWidget mainWidget tabLabel: (self buildLabelWidget: 'Transcript' withIcon: GTK.Gtk gtkStockClose at: transcriptWidget);
	    appendPage: cmp mainWidget tabLabel: (self buildLabelWidget: 'Compiler error(s)' withIcon: GTK.Gtk gtkStockClose at: cmp);
            "setTabDetachable: transcriptWidget mainWidget detachable: true;
            setTabReorderable:  transcriptWidget mainWidget reorderable: true;"
            appendPage: workspaceWidget mainWidget tabLabel: (self buildLabelWidget: 'Workspace' withIcon: GTK.Gtk gtkStockClose at: workspaceWidget);
            "setTabDetachable: workspaceWidget mainWidget detachable: true;
            setTabReorderable:  workspaceWidget mainWidget reorderable: true;"
            setScrollable: true;
            yourself
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

        centralBrowser := self buildClassBrowserWidget showAll; yourself.
	^ GTK.GtkVPaned new
	    pack1: centralBrowser mainWidget resize: true shrink: true;
	    pack2: self buildNotebookWorkspaceWidget resize: true shrink: false;
	    yourself
    ]

    buildLabelWidget: aString withIcon: aStockString at: aSmallInteger [
	<category: 'user interface'>
	
	| image close |
	image := GTK.GtkImage newFromStock: aStockString size: GTK.Gtk gtkIconSizeMenu.
	close := (GTK.GtkButton new)
		    setImage: image;
		    setRelief: GTK.Gtk gtkReliefNone;
		    connectSignal: 'pressed' to: self selector: #'closeIt:at:' userData: aSmallInteger;
		    yourself.
	^ (GTK.GtkHBox new: false spacing: 0)
	    add: (GTK.GtkLabel new: aString);
	    add: close;
	    showAll;
	    yourself
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
            GTK.GtkMenuItem menuItem: 'File out a namespace' connectTo: self selector: #fileoutNamespace.
            GTK.GtkMenuItem menuItem: 'File out in a project' connectTo: self selector: #fileoutProject}
    ]

    createClassMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Add a class' connectTo: self selector: #newClass.
            GTK.GtkMenuItem menuItem: 'Rename a class' connectTo: self selector: #renameClass.
            GTK.GtkMenuItem menuItem: 'Delete a class' connectTo: self selector: #deleteClass.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Inspect a class' connectTo: self selector: #inspectClass.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'File out a class' connectTo: self selector: #fileoutClass.
            GTK.GtkMenuItem menuItem: 'File out in a project' connectTo: self selector: #fileoutClassInProject}
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

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'back' accelPath: '<GtkLauncher>/History/Back' connectTo: self selector: #back.
            GTK.GtkMenuItem menuItem: 'Forward' accelPath: '<GtkLauncher>/History/Forward' connectTo: self selector: #forward}
    ]

    createProjectMenus [
	<category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New project' connectTo: self selector: #newProject.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open project' connectTo: self selector: #openProject.
            GTK.GtkMenuItem menuItem: 'Save project' connectTo: self selector: #saveProject.
            GTK.GtkMenuItem menuItem: 'Save project as...' connectTo: self selector: #saveProjectAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close project' connectTo: self selector: #closeProject}
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
	    GTK.GtkMenuItem menuItem: 'Accept-It' accelPath: '<GtkLauncher>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
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
	    #('Project' #createProjectMenus).
	    #('Namespace' #createNamespaceMenus).
	    #('Class' #createClassMenus).
	    #('Category' #createCategoryMenus).
	    #('Method' #createMethodMenus).
	    #('Smalltalk' #createSmalltalkMenus).
	    #('Tools' #createToolsMenus).
	    #('Windows' #createWindowsMenus).
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
	    GTK.GtkMenuItem menuItem: 'GtkDemo' connectTo: self selector: #gtkDemo.
	    GTK.GtkMenuItem menuItem: 'SqueakZilla' connectTo: self selector: #webBrowser}
    ]

    createWindowsMenus [
	<category: 'user interface'>

	^ windowsMenu := self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Arrange' connectTo: self selector: #arrangeWindows .
	    GTK.GtkMenuItem menuItem: 'Close all' connectTo: self selector: #closeAllWindows}
    ]

    isCurrentWidgetTranscript [
	<category: 'testing'>

	^ currentWidget == transcriptWidget
    ]

    closeIt: aGtkButton  at: aGtkConcreteWidget [
	<category: 'notebook events'>
   
	| page |
	aGtkConcreteWidget = transcriptWidget ifTrue: [ self error: 'Can not remove the transcript tab' ].
	page := notebook pageNum: aGtkConcreteWidget mainWidget.
	notebookPages remove: aGtkConcreteWidget.
	notebook removePage: page
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
	<category: 'notebook events'>

	currentWidget := notebookPages at: anInteger + 1
    ]

    undo [
	<category: 'edit events'>

	self isCurrentWidgetTranscript ifTrue: [ currentWidget hasFocus ifTrue: [ ^ self ] ].
	self onFocusPerform: #undo
    ]

    redo [
	<category: 'edit events'>

	self isCurrentWidgetTranscript ifTrue: [ currentWidget hasFocus ifTrue: [ ^ self ] ].
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

    newProject [
	<category: 'project events'>

	| dlg project file |
	dlg := GtkProjectDialog open.
	dlg hasPressedOk ifFalse: [ ^ self ].
	project := dlg result.
	file := Directory userBase / (project name).
	file exists ifTrue: [ self error: 'Project already exist' ].
	file := FileStream open: file asString mode: FileStream write.
	(ObjectDumper on: file)
	    dump: project.
	file close.
    ]

    onFocusPerform: aSelector [
	<category: 'focus'>

	^ centralBrowser hasFocus 
	    ifTrue: [ centralBrowser perform: aSelector ]
	    ifFalse: [ currentWidget hasFocus 
			    ifTrue: [ currentWidget perform: aSelector ] ].
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

	centralBrowser acceptIt
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

	centralBrowser back
    ]

    forward [
	<category: 'history events'>

	centralBrowser forward
    ]

    helpcontents [
	<category: 'help events'>

	GtkWebBrowser openOn: 'http://smalltalk.gnu.org/documentation'
    ]

    fileoutNamespace [
        <category: 'namespace events'>

	centralBrowser fileoutNamespace
    ]

    fileoutProject [
        <category: 'namespace events'>

        centralBrowser fileoutProject
    ]

    newNamespace [
        <category: 'namespace events'>

        centralBrowser newNamespace
    ]

    renameNamespace [
        <category: 'namespace events'>

        centralBrowser renameNamespace
    ]

    deleteNamespace [
        <category: 'namespace events'>

        centralBrowser deleteNamespace
    ]

    inspectNamespace [
        <category: 'namespace events'>

        centralBrowser inspectNamespace
    ]

    newClass [
        <category: 'class events'>

        centralBrowser newClass
    ]

    renameClass [
        <category: 'class events'>

	centralBrowser renameClass
    ]

    deleteClass [
        <category: 'class events'>

        centralBrowser deleteClass
    ]

    inspectClass [
        <category: 'class events'>

        centralBrowser inspectClass
    ]

    fileoutClass [
        <category: 'class events'>

        centralBrowser fileoutClass
    ]

    newCategory [
        <category: 'category events'>

        centralBrowser newCategory
    ]

    renameCategory [
        <category: 'category events'>

        centralBrowser renameCategory
    ]

    deleteCategory [
        <category: 'category events'>

        centralBrowser deleteCategory
    ]

    inspectCategory [
        <category: 'category events'>

        centralBrowser inspectCategory
    ]

    fileoutCategory [
        <category: 'method events'>

	centralBrowser fileoutCategory
    ]

    newMethod [
        <category: 'method events'>

        centralBrowser newMethod
    ]

    deleteMethod [
        <category: 'method events'>

        centralBrowser deleteMethod
    ]

    inspectMethod [
        <category: 'method events'>

        centralBrowser inspectMethod
    ]

    fileoutMethod [
        <category: 'method events'>

	centralBrowser fileoutMethod
    ]

    sunit [
	<category: 'tools events'>

	GtkSUnit open
    ]
]

