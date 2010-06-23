GtkVisualGSTTool subclass: GtkLauncher [
    GtkLauncher class [ | history uniqueInstance | ]

    | historyWidget browsers outputs saved imageName transcriptWidget windowsMenu systemChangeNotifier |

    GtkLauncher class >> addHistory: aClass [
	<category: 'public'>

	self history 
		add: aClass;
		changed
    ]

    GtkLauncher class >> history [
        <category: 'public'>

        ^ history ifNil: [ history := IdentitySet new ] 
    ]

    GtkLauncher class >> uniqueInstance [
	<category: 'public'>

	uniqueInstance ifNil: [ self createInstance ].
        ^ uniqueInstance
    ]

    GtkLauncher class >> / path [
        <category: 'files'>

        ^ (PackageLoader packageAt: 'VisualGST') / path
    ]

    GtkLauncher class >> uniqueInstance: anObject [
        <category: 'private'>

	(uniqueInstance notNil and: [ anObject notNil ])
	    ifTrue: [ self error: 'cannot override uniqueInstance' ].
        uniqueInstance := anObject
    ]

    GtkLauncher class >> createInstance [
        <category: 'private'>

        ^ (uniqueInstance :=  self basicNew)
            initialize;
            showAll;
            postInitialize;
	    resize: 1024@600;
            yourself
    ]

    GtkLauncher class >> instanceCreationErrorString [
        <category: 'private'>

        ^ 'This is a singleton implementation, so you are not allowed to create instances yourself. Use #uniqueInstance to access the instance.'
    ]

    GtkLauncher class >> new [
        <category: 'instance creation'>

        ^ self error: self instanceCreationErrorString
    ]

    GtkLauncher class >> exit [
	<category: 'exit'>

	GTK.Gtk mainQuit.
	ObjectMemory quit	
    ]
 
    GtkLauncher class >> open [
	<category: 'user interface'>

        self uniqueInstance
    ]

    GtkLauncher class >> version [
	<category: 'accessing'>

	^ '0.7.5'
    ]

    GtkLauncher class >> website [
	<category: 'accessing'>

	^ 'http://visualgst.bioskop.fr/'
    ]
    
    GtkLauncher class >> gstWebsite [
	<category: 'accessing'>

	^ 'http://smalltalk.gnu.org/'
    ]

    GtkLauncher class >> license [
	<category: 'accessing'>

	^
'Permission is hereby granted, free of charge, to any person obtaining
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
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
    ]

    GtkLauncher class >> displayError: title message: error [
        <category: 'error'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: nil
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Error'
                                tip: error.

        dialog
            addButton: 'Ok' responseId: 1;
            showModalOnAnswer: [ :dlg :res | dlg destroy ].
    ]

    GtkLauncher class >> displayError: error [
        ^self displayError: 'Error' message: error
    ]

    classBrowser [
	<category: 'tools events'>

	| widget |
	browsers addWidget: (widget := self buildClassBrowserWidget) labeled: 'Browser'.
        browsers showLastPage.
	widget postInitialize.
	^ widget
    ]

    classBrowserInAWindow [
	<category: 'tools events'>

	GtkClassBrowser open
    ]

    newWorkspace [
	<category: 'tools events'>

        ^self newWorkspaceLabeled: 'Workspace'
    ]

    newWorkspaceLabeled: aString [
	<category: 'tools events'>

	| widget |
	widget := self buildWorkspaceWidget showAll.
	widget postInitialize.
	outputs addWidget: widget labeled: aString.
        outputs showLastPage.
        ^widget
    ]

    onDelete: aGtkWidget event: aGdkEvent [
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
            setDefaultResponse: 2;
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: [ self class exit ].
                res = 1 ifTrue: [ self saveImageAndQuit ].
                dlg destroy ].
    ]

    open [
	<category: 'file events'>

	| file string |
	(GTK.GtkFileChooserDialog load: 'Load Smalltalk source' parent: window)
	    showModalOnAnswer: [ :dlg :res |
		res = GTK.Gtk gtkResponseAccept 
				ifTrue: [ file := File name: dlg getFilename.
                                          FileStream open: dlg getFilename mode: FileStream read.
					  (self newWorkspaceLabeled: file stripPath) text: file contents ].
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
                res = GTK.Gtk gtkResponseAccept 
				ifTrue: [ file := FileStream open: dlg getFilename mode: FileStream write.
					  file nextPutAll: outputs currentWidget text ].
		dlg destroy ]
    ]

    print [
	<category: 'file events'>
    ]

    saveImageAndQuit [
        <category: 'file events'>

        "ObjectMemory>>#snapshot breaks hard links due to
         http://bugzilla.kernel.org/show_bug.cgi?id=9138, so we have to
         check the permission of the directory rather than the file."
        imageName asFile parent isWriteable ifFalse: [ self saveImageAsAndQuit ].
        self saveImage: [ ObjectMemory snapshot: imageName. self class exit ]
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

    saveImageAsAndQuit [
        <category: 'file events'>

        (GTK.GtkFileChooserDialog save: 'Save image as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                imageName := dlg getFilename.
                dlg destroy.
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self saveImage: [ ObjectMemory snapshot: imageName ]. self class exit ] ]
    ]

    saveImage: aBlock [
	| oldMessage oldNotifier oldCatIcon oldNameIcon |
	oldNotifier := self systemChangeNotifier.
	oldMessage := Transcript message.

	oldCatIcon := ClassCategory icon.
	ClassCategory icon: nil.
	oldNameIcon := AbstractNamespace icon.
	AbstractNamespace icon: nil.

	Transcript message: stdout->#nextPutAllFlush:.
	SystemChangeNotifier root remove: oldNotifier.
	systemChangeNotifier := nil.
	self class uniqueInstance: nil.

	(saved := aBlock value not) ifTrue: [
            self class uniqueInstance: self.
	    ClassCategory icon: oldCatIcon.
	    AbstractNamespace icon: oldNameIcon.
	    systemChangeNotifier := oldNotifier.
	    SystemChangeNotifier root add: oldNotifier.
	    Transcript message: oldMessage ]
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

	saved := false.
	imageName := File image asString.
        systemChangeNotifier := SystemChangeNotifier new.
        SystemChangeNotifier root add: systemChangeNotifier.
	self clearGlobalState.
	super initialize.
	window maximize.
    ]

    windowTitle [
        <category: 'widget'>
        ^'VisualGST'
    ]

    browserPostInitialize [
	<category: 'initialization'>

        browsers grabFocus.
        browsers currentWidget postInitialize.
        browsers currentWidget selectANamespace: Smalltalk.
        browsers currentWidget selectAClass: Object.
    ]

    postInitialize [
	<category: 'initialization'>

	super postInitialize.
        self browserPostInitialize.
	1 to: 2 do: [ :i | (outputs widgetAt: i) postInitialize ].
	historyWidget hideAll.
	window
	    connectSignal: 'key-press-event' to: self selector:  #'keyPressedOn:keyEvent:' userData: nil
    ]

    buildNotebookWorkspaceWidget [
	<category: 'user interface'>

	outputs := GtkNotebookWidget new
				initialize;
				parentWindow: window;
				showAll;
				yourself.
	^ outputs
	    addPermanentWidget: (transcriptWidget := self buildTranscriptWidget) labeled: 'Transcript';
	    addWidget: self buildWorkspaceWidget labeled: 'Workspace';
	    yourself
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	^ self buildBrowserAndWorkspaceWidget
    ]

    buildHistoryPaned [
       <category: 'user interface'>

        ^ GTK.GtkHPaned new
            pack1: self buildHistoryView resize: true shrink: false;
            pack2: self buildClassBrowserTabbedWidget mainWidget resize: true shrink: true ;
            showAll;
            yourself
    ]

    buildBrowserAndWorkspaceWidget [
        <category: 'intialize-release'>

        ^ GTK.GtkVPaned new
            pack1: self buildHistoryPaned resize: true shrink: true;
            pack2: self buildNotebookWorkspaceWidget mainWidget resize: true shrink: false;
            yourself
    ]

    buildHistoryView [
       <category: 'user interface'>

        historyWidget := GtkHistoryWidget new
                                    browser: self;
                                    yourself.
        self class history addDependent: historyWidget.
        ^ historyWidget mainWidget
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

	^super createEditMenus, {
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Clear Transcript' connectTo: self selector: #clearTranscriptWidget}
    ]

    createNamespaceMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Add a namespace' connectTo: self selector: #newNamespace.
            GTK.GtkMenuItem menuItem: 'Rename a namespace' connectTo: self selector: #renameNamespace.
            GTK.GtkMenuItem menuItem: 'Delete a namespace' connectTo: self selector: #deleteNamespace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Inspect a namespace' connectTo: self selector: #inspectNamespace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'File out a namespace' connectTo: self selector: #fileoutNamespace}
    ]

    createClassMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Add a class' connectTo: self selector: #newClass.
            GTK.GtkMenuItem menuItem: 'Rename a class' connectTo: self selector: #renameClass.
            GTK.GtkMenuItem menuItem: 'Delete a class' connectTo: self selector: #deleteClass.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Inspect a class' connectTo: self selector: #inspectClass.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'File out a class' connectTo: self selector: #fileoutClass}
    ]

    createCategoryMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Add a category' connectTo: self selector: #newCategory.
            GTK.GtkMenuItem menuItem: 'Rename a category' connectTo: self selector: #renameCategory.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'File out a category' connectTo: self selector: #fileoutCategory}
    ]

    createMethodMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Delete a method' connectTo: self selector: #deleteMethod.
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

	^{GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkLauncher>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #save.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkLauncher>/File/SaveAs' connectTo: self selector: #saveAs.
            GTK.GtkMenuItem new}, super createFileMenus
    ]

    createHistoryMenus [
	<category: 'user interface'>

	self accelGroup append:
            {{'<Alt>Left'. '<GtkLauncher>/History/Back'}.
            {'<Alt>Right'. '<GtkLauncher>/History/Forward'}.
            {'<Control>H'. '<GtkLauncher>/History/showHide'}}.

	^{GTK.GtkMenuItem menuItem: 'Back' accelPath: '<GtkLauncher>/History/Back' connectTo: self selector: #back.
            GTK.GtkMenuItem menuItem: 'Forward' accelPath: '<GtkLauncher>/History/Forward' connectTo: self selector: #forward.
	    GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Show/Hide history pane' accelPath: '<GtkLauncher>/History/showHide' connectTo: self selector: #showHideHistory }
    ]

    createTabsMenus [
	<category: 'user interface'>

       self accelGroup append: {{'<Control><Shift>Tab'. '<GtkLauncher>/Tabs/PreviousTab'}.
	    {'<Control>Tab'. '<GtkLauncher>/Tabs/NextTab'}.
	    {'<Control>w'. '<GtkLauncher>/Tabs/CloseTab'}}.

	^{GTK.GtkMenuItem menuItem: 'Previous Tab' accelPath: '<GtkLauncher>/Tabs/PreviousTab' connectTo: self selector: #previousTab.
	GTK.GtkMenuItem menuItem: 'Next Tab' accelPath: '<GtkLauncher>/Tabs/NextTab' connectTo: self selector: #nextTab.
	GTK.GtkMenuItem new.
	GTK.GtkMenuItem menuItem: 'Close Tab' accelPath: '<GtkLauncher>/Tabs/CloseTab' connectTo: self selector: #closeTab.}
    ]

    createToolbar [
	<category: 'user interface'>

	self
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-new')
				connectSignal: 'clicked' to: self selector: #newWorkspace;
				setTooltipText: 'Create a new workspace';
				yourself).
        super createToolbar
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

    createToolsMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/TabbedClassBrowser'}}.

	^{GTK.GtkMenuItem menuItem: 'Browser' accelPath: '<GtkLauncher>/Tools/TabbedClassBrowser' connectTo: self selector: #newTabbedBrowser},
            super createToolsMenus.
    ]

    newTabbedBrowser [
	<category: 'tools events'>

	OpenTabbedBrowserCommand on: self
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

    find [
	<category: 'edit events'>

	self onFocusPerform: #showFind
    ]

    replace [
	<category: 'edit events'>

	self onFocusPerform: #showReplace
    ]

    clearTranscriptWidget [
	<category: 'edit events'>

	transcriptWidget clear
    ]

    focusedWidget [
	<category: 'focus'>

	^browsers focusedWidget ifNil: [ outputs focusedWidget ]
    ]

    browserHasFocus [
	<category: 'testing'>

	^ browsers hasFocus
    ]

    sourceCodeWidgetHasFocus [
	<category: 'focus'>

	^ browsers currentWidget sourceCodeWidgetHasFocus
    ]

    state [
	<category: 'focus'>

	browsers currentWidget isNil ifTrue: [^BrowserState new].
	^browsers currentWidget state
    ]

    selectedText [
	<category: 'smalltalk events'>

	^self onFocusPerform: #selectedText
    ]

    selectedMethodSymbol [
        <category: 'text editing'>

        ^self onFocusPerform: #selectedMethodSymbol
    ]

    hasSelection [
	<category: 'smalltalk events'>

        | widget |
	widget := self focusedWidget.
	^widget notNil and: [widget hasSelection]
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

    showHideHistory [
	<category: 'history events'>

        historyWidget mainWidget getVisible
            ifTrue: [ historyWidget hideAll ]
            ifFalse: [ historyWidget showAll ]
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

	browsers numberOfPages > 1 
			    ifTrue: [ browsers currentWidget checkCodeWidgetAndUpdate: [ browsers closeCurrentPage ] ]
			    ifFalse: [ browsers closeCurrentPage ].
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

    fileoutCategory [
        <category: 'method events'>

	browsers currentWidget fileoutCategory
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

    notebookHasFocus [
	<category: 'testing'>

	^ outputs hasFocus
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

