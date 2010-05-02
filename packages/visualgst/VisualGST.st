GtkMainWindow subclass: VisualGST [
    VisualGST class [ | compileError uniqueInstance | ]

    | browsers outputs saved imageName transcriptWidget windowsMenu systemChangeNotifier |

    VisualGST class >> uniqueInstance [
	<category: 'public'>

	uniqueInstance ifNil: [ self createInstance ].
        ^ uniqueInstance
    ]

    VisualGST class >> uniqueInstance: anObject [
        <category: 'private'>

	(uniqueInstance notNil and: [ anObject notNil ])
	    ifTrue: [ self error: 'cannot override uniqueInstance' ].
        uniqueInstance := anObject
    ]

    VisualGST class >> createInstance [
        <category: 'private'>

        ^(uniqueInstance :=  self basicNew)
            initialize;
            showAll;
            postInitialize;
	    resize: 1024@600;
            yourself
    ]

    VisualGST class >> instanceCreationErrorString [
        <category: 'private'>

        ^ 'This is a singleton implementation, so you are not allowed to create instances yourself. Use #uniqueInstance to access the instance.'
    ]

    VisualGST class >> new [
        <category: 'instance creation'>

        ^ self error: self instanceCreationErrorString
    ]

    VisualGST class >> exit [
	<category: 'exit'>

	GTK.Gtk mainQuit.
	ObjectMemory quit	
    ]
 
    VisualGST class >> open [
	<category: 'user interface'>

        self uniqueInstance
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
	    showModalDestroy
    ]

    browser [
	<category: 'events'>

	windowsMenu append: (GTK.GtkMenuItem label: 'Browser') showAll
    ]

    classBrowser [
	<category: 'tools events'>

	| widget |
	browsers addWidget: (widget := self buildClassBrowserWidget) labeled: 'Browser'.
	^ widget
    ]

    classBrowserInAWindow [
	<category: 'tools events'>

	GtkClassBrowser open
    ]

    newWorkspace [
	<category: 'tools events'>

	| widget |
	widget := self buildWorkspaceWidget showAll.
	outputs addWidget: widget labeled: 'Workspace'.
    ]

    delete: aGtkWidget event: aGdkEvent [
	<category: 'window events'>

	self quit.

	^ true 
    ]

    quit [
	<category: 'file events'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Save the image before exiting?'
				tip: 'The image hosts all the code changes that you made %<since the last save|since starting VisualGST>1.  Unless you exported these changes, not saving the image will lose them.' % {saved}.

        dialog
            addButton: 'Exit without saving' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Save image' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: [ self class exit ].
                res = 1 ifTrue: [ self saveImage.
				  self class exit ].
                dlg destroy ].
    ]

    open [
	<category: 'file events'>

	| file string |
	outputs currentWidget  == transcriptWidget ifTrue: [ self error: 'Can not remove the transcript tab' ].
	(GTK.GtkFileChooserDialog load: 'Load Smalltalk source' parent: window)
	    showModalOnAnswer: [ :dlg :res |
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
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifFalse: [ ^ dlg destroy ].
		file := FileStream open: dlg getFilename mode: FileStream write.
		file nextPutAll: outputs currentWidget text. 
                dlg destroy ]
    ]

    print [
	<category: 'file events'>
    ]

    saveImage [
        <category: 'file events'>

	"ObjectMemory>>#snapshot breaks hard links due to
	 http://bugzilla.kernel.org/show_bug.cgi?id=9138, so we have to
	 check the permission of the directory rather than the file."
	imageName asFile parent isWriteable ifFalse: [ ^ self saveImageAs ].
        self saveImage: [ ObjectMemory snapshot: imageName ]
    ]

    saveImageAs [
	<category: 'file events'>

	(GTK.GtkFileChooserDialog save: 'Save image as...' parent: window)
	    showModalOnAnswer: [ :dlg :res |
		imageName := dlg getFilename.
		dlg destroy.
		res = GTK.Gtk gtkResponseAccept ifTrue: [ self saveImage: [ ObjectMemory snapshot: imageName ] ] ]
    ]

    saveImage: aBlock [
	| oldMessage oldNotifier |
	oldNotifier := self systemChangeNotifier.
	oldMessage := Transcript message.

	Transcript message: stdout->#nextPutAllFlush:.
	SystemChangeNotifier root remove: oldNotifier.
	systemChangeNotifier := nil.
	self class uniqueInstance: nil.

	(saved := aBlock value not) ifTrue: [
            self class uniqueInstance: self.
	    systemChangeNotifier := oldNotifier.
	    SystemChangeNotifier root add: oldNotifier.
	    Transcript message: oldMessage ]
    ]

    workspace [
	<category: 'tools events'>
	
	self newWorkspace
    ]

    systemChangeNotifier [
	<category: 'notifications'>

	^ systemChangeNotifier
    ]

    clearGlobalState [
	<category: 'initialization cleanup'>

	GtkImageModel release
    ]

    initialize [
	<category: 'initialization'>

	super initialize.
	saved := false.
	imageName := File image asString.
        systemChangeNotifier := SystemChangeNotifier new.
        SystemChangeNotifier root add: systemChangeNotifier.
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

	browsers grabFocus.
	window
	    connectSignal: 'key-press-event' to: self selector:  #'keyPressedOn:keyEvent:' userData: nil;
	    connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
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

	self accelGroup append: {{'<Control><shift>Z'. '<GtkLauncher>/Edit/Cancel'}.
	    {'<Control>Z'. '<GtkLauncher>/Edit/Undo'}.
	    {'<Control>R'. '<GtkLauncher>/Edit/Redo'}.
	    {'<Control>X'. '<GtkLauncher>/Edit/Cut'}.
	    {'<Control>C'. '<GtkLauncher>/Edit/Copy'}.
	    {'<Control>V'. '<GtkLauncher>/Edit/Paste'}.
	    {'<Control>A'. '<GtkLauncher>/Edit/SelectAll'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkLauncher>/Edit/Cancel' connectTo: self selector: #cancel.
	    GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkLauncher>/Edit/Undo' connectTo: self selector: #undo.
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
	    {'<Control><Shift>S'. '<GtkLauncher>/File/SaveAs'}.
	    {'<Control>Q'. '<GtkLauncher>/File/Quit'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
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

    createTabsMenus [
	<category: 'user interface'>

       self accelGroup append: {{'<Control><Shift>Tab'. '<GtkLauncher>/Tabs/PreviousTab'}.
	    {'<Control>Tab'. '<GtkLauncher>/Tabs/NextTab'}.
	    {'<Control>w'. '<GtkLauncher>/Tabs/CloseTab'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Previous Tab' accelPath: '<GtkLauncher>/Tabs/PreviousTab' connectTo: self selector: #previousTab.
	GTK.GtkMenuItem menuItem: 'Next Tab' accelPath: '<GtkLauncher>/Tabs/NextTab' connectTo: self selector: #nextTab.
	GTK.GtkMenuItem new.
	GTK.GtkMenuItem menuItem: 'Close Tab' accelPath: '<GtkLauncher>/Tabs/CloseTab' connectTo: self selector: #closeTab.}
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
	    #('Tabs' #createTabsMenus).
	    #('Help' #createHelpMenus)}
    ]

    createStatusBar [
	<category: 'user interface'>

	self statusMessage: 'Gtk Launcher'
    ]

    createToolbar [
	<category: 'user interface'>

	self
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-new')
				connectSignal: 'clicked' to: OpenWorkspaceCommand selector: #execute userData: nil;
				setTooltipText: 'Create a new workspace';
				yourself);
	    appendSeparator;
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-save')
				connectSignal: 'clicked' to: SaveImageCommand selector: #execute userData: nil;
				setTooltipText: 'Save the image';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-save-as')
				connectSignal: 'clicked' to: SaveImageAsCommand selector: #execute userData: nil;
				setTooltipText: 'Save the image as';
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
				yourself)
    ]

    createToolsMenus [
	<category: 'user interface'>

	| menu |
        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/TabbedClassBrowser'}.
	    {'<Control><shift>B'. '<GtkLauncher>/Tools/ClassBrowser'}.
	    {'<Control>M'. '<GtkLauncher>/Tools/Implementors'}.
            {'<Control>N'. '<GtkLauncher>/Tools/Senders'}}.

	menu := {GTK.GtkMenuItem menuItem: 'Browser' accelPath: '<GtkLauncher>/Tools/TabbedClassBrowser' connectTo: OpenTabbedBrowserCommand selector: #execute.
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

    isCurrentWidgetTranscript [
	<category: 'testing'>

	^ outputs currentWidget == transcriptWidget
    ]

    cancel [
	<category: 'edit events'>

	self isCurrentWidgetTranscript ifTrue: [ outputs currentWidget hasFocus ifTrue: [ ^ self ] ].
	self onFocusPerform: #cancel
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

	^ self browserHasFocus 
	    ifTrue: [ browsers currentWidget perform: aSelector ]
	    ifFalse: [ outputs hasFocus 
			    ifTrue: [ outputs currentWidget perform: aSelector ] ].
    ]

    browserHasFocus [
	<category: 'testing'>

	^ browsers hasFocus
    ]

    currentWidgetOfBrowser [
	<category: 'focus'>

	^ browsers currentWidget
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

    back [
	<category: 'history events'>

	browsers currentWidget back
    ]

    forward [
	<category: 'history events'>

	browsers currentWidget forward
    ]

    previousTab [
	<category: 'tabs events'>

	browsers currentPage > 0 
		    ifTrue: [ browsers currentPage: browsers currentPage - 1 ]
		    ifFalse: [ browsers currentPage: browsers numberOfPages - 1 ] 
    ]

    nextTab [
	<category: 'tabs events'>

	browsers currentPage: (browsers currentPage + 1 \\ browsers numberOfPages)
    ]

    closeTab [
	<category: 'tabs events'>

	browsers numberOfPages > 1 ifTrue: [ browsers currentWidget checkCodeWidget ].
	browsers closeCurrentPage
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

    keyPressedOn: aGtkWidget keyEvent: aGdkEventKey [
        <category: 'key event'>

        | event |
        event := aGdkEventKey castTo: GTK.GdkEventKey type.

	(event state value bitAnd: GTK.Gdk gdkControlMask) = 0 ifTrue: [ ^ false ].
	(#(65417 65289 65056) includes: event keyval value) ifFalse: [ ^ false ].
	(event state value bitAnd: GTK.Gdk gdkShiftMask) = 0  
					    ifFalse: [ self previousTab ]
					    ifTrue: [ self nextTab ].
        ^ true
    ]
]

