GtkMainWindow subclass: GtkDebugger [
    | state windowsMenu codeWidget contextWidget debugger inspectorWidget stackInspectorWidget selectedContext |

    GtkDebugger class >> openOn: aContext [
	<category: 'user interface'>

	^ (self openSized: 450@375)
	    context: aContext
    ]

    aboutDebugger [
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
	    setProgramName: 'VisualGST Debugger';
	    runBlockingAndDestroy
    ]

    initialize [
	<category: 'initialization'>

	super initialize.
	self
	    title: 'VisualGST Debugger';
	    createMenus;
	    createToolbar;
	    createStatusBar;
	    centralWidget: self buildCentralWidget
    ]
   
    postInitialize [
        <category: 'initialization'>

        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]
 
    buildContextWidget [
	<category: 'user interface'>

	^ (contextWidget := GtkContextWidget new)
	    initialize;
	    whenSelectionChangedSend: #contextChanged to: self;
	    mainWidget
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ (inspectorWidget := GtkInspectorWidget new)
	    initialize;
	    mainWidget
    ]

    buildSourceWidget [
	<category: 'user interface'>

	^ (codeWidget := GtkSourceCodeWidget new)
            initialize;
            mainWidget
    ]

    buildStackInspectorWidget [
	<category: 'user interface'>

	^ (stackInspectorWidget := GtkStackInspector new)
	    initialize;
	    mainWidget
    ]

    buildInspectorsWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
            pack1: self buildInspectorWidget resize: true shrink: false;
            pack2: self buildStackInspectorWidget resize: true shrink: true;
            yourself
    ]

    buildCodeAndStateWidget [
	<category: 'intialize-release'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildSourceWidget resize: true shrink: false;
	    pack2: self buildInspectorsWidget resize: true shrink: true;
	    yourself
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildContextWidget resize: true shrink: false;
	    pack2: self buildCodeAndStateWidget resize: true shrink: true;
	    yourself
    ]

    createEditMenus [
	<category: 'user interface'>

	self accelGroup append: {{'<Control><shift>Z'. '<GtkLauncher>/Edit/Cancel'}.
	    {'<Control>Z'. '<GtkLauncher>/Edit/Undo'. self. #undo}.
	    {'<Control>R'. '<GtkLauncher>/Edit/Redo'. self. #redo}.
	    {'<Control>X'. '<GtkLauncher>/Edit/Cut'. self. #cut}.
	    {'<Control>C'. '<GtkLauncher>/Edit/Copy'. self. #copy}.
	    {'<Control>V'. '<GtkLauncher>/Edit/Paste'. self. #paste}.
	    {'<Control>A'. '<GtkLauncher>/Edit/SelectAll'. self. #selectAll}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkLauncher>/Edit/Cancel' connectTo: self selector: #cancel.
	    GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkLauncher>/Edit/Undo'.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkLauncher>/Edit/Redo'.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkLauncher>/Edit/Cut'.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkLauncher>/Edit/Copy'.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkLauncher>/Edit/Paste'.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkLauncher>/Edit/SelectAll'.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Clear Transcript' accelPath: '<GtkLauncher>/Edit/ClearTranscript'}
    ]

    createFileMenus [
	<category: 'user interface'>

        self accelGroup append: 
	    {{'<Control>O'. '<GtkDebugger>/File/Open'. self. #open}.
	    {'<Control>S'. '<GtkDebugger>/File/Save'. self. #save}.
	    {'<Control><Shift>S'. '<GtkDebugger>/File/SaveAs'. self. #saveAs}.
	    {'<Control>Q'. '<GtkDebugger>/File/Close'. self. #close}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New worskpace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkDebugger>/File/Open'.
            GTK.GtkMenuItem menuItem: 'Save' accelPath: '<GtkDebugger>/File/Save'.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkDebugger>/File/SaveAs'.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #printIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkDebugger>/File/Close' connectTo: self selector: #close}
    ]

    createExecuteMenus [
	<category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Step' connectTo: self selector: #step.
            GTK.GtkMenuItem menuItem: 'Step into' connectTo: self selector: #stepInto.
            GTK.GtkMenuItem menuItem: 'Step over' connectTo: self selector: #stepOver.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Run' connectTo: self selector: #run}
    ]

    createSmalltalkMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkLauncher>/Smalltalk/DoIt'. self. #doIt}.
            {'<Control>P'. '<GtkLauncher>/Smalltalk/PrintIt'. self. #printIt}.
            {'<Control>I'. '<GtkLauncher>/Smalltalk/InspectIt'. self. #inspectIt}.
            {'<Control>M'. '<GtkLauncher>/Smalltalk/Implementors'. self. #implementors}.
            {'<Control>N'. '<GtkLauncher>/Smalltalk/Senders'. self. #senders}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkLauncher>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkLauncher>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkLauncher>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' connectTo: self selector: #debugIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkLauncher>/Smalltalk/Implementors' connectTo: self selector: #implementors.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkLauncher>/Smalltalk/Senders' connectTo: self selector: #senders}
    ]

    createHelpMenus [
	<category: 'user interface'>

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About Launcher' connectTo: self selector: #aboutLauncher.
	    GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
	<category: 'user interface'>

	self createMainMenu: {#('File' #createFileMenus).
	    #('Edit' #createEditMenus).
	    #('Execute' #createExecuteMenus).
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
        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/ClassBrowser'. self. #classBrowserInAWindow}}.

	^ self createNewMenuEntry:  {GTK.GtkMenuItem menuItem: 'Browser' connectTo: self selector: #classBrowser.
	    GTK.GtkMenuItem menuItem: 'Browser window' accelPath: '<GtkLauncher>/Tools/ClassBrowser'.
	    GTK.GtkMenuItem menuItem: 'Workspace' connectTo: self selector: #workspace.
	    GTK.GtkMenuItem menuItem: 'Inspector' connectTo: self selector: #gtkInspector.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Assistant' connectTo: self selector: #gtkAssistant.
	    GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Smallzilla' connectTo: self selector: #webBrowser}
    ]

    debugger: aProcess [
        <category: 'context'>

        debugger := Debugger on: aProcess suspend.
    ]

    updateInspectorWidget: aContext [
	<category: 'context'>

	state := CategoryState on: self with: aContext receiver class -> '*'.
        inspectorWidget object: aContext receiver.
        stackInspectorWidget object: aContext
    ]

    updateContextWidget [
	<category: 'context'>

	contextWidget
            context: debugger suspendedContext;
            selectLastContext.

	self updateInspectorWidget: debugger suspendedContext
    ]

    doItProcess: aProcess [
	<category: 'context'>

	self debugger: aProcess.
	3 timesRepeat: [ debugger step ].
	debugger myStepInto.
	self updateContextWidget
    ]

    process: aProcess [
	<category: 'context'>
	
	self 
	    debugger: aProcess;
	    updateContextWidget
    ]

    contextChanged [
	<category: 'context events'>

	| iter |
	self checkCodeWidget.
	contextWidget hasSelectedContext ifFalse: [ ^ self ].
	iter := contextWidget selectedIter.
	selectedContext := debugger suspendedContext parentContextAt: (contextWidget numberOfContext - ((contextWidget model getPath: iter) getIndices value)).
	codeWidget sourceCode: selectedContext method methodSourceString.

	self updateInspectorWidget: selectedContext
    ]

    step [
	<category: 'execute events'>

	| iter |
	iter := contextWidget selectedIter.
	contextWidget numberOfContext = (contextWidget model getPath: iter) getIndices value
	    ifTrue: [ debugger myStep ]
	    ifFalse: [ debugger finish: selectedContext ].
	self updateContextWidget
    ]

    stepInto [
	<category: 'execute events'>

	debugger myStepInto.
	self updateContextWidget
    ]

    stepOver [
	<category: 'execute events'>

	debugger step.
	self updateContextWidget
    ]

    run [
	<category: 'execute events'>

	self close.
	debugger continue
    ]

    doIt [
        <category: 'smalltalk event'>

        codeWidget
            object: debugger suspendedContext receiver;
            doIt
    ]

    debugIt [
        <category: 'smalltalk event'>

        codeWidget
            object: debugger suspendedContext receiver;
            debugIt
    ]


    inspectIt [
        <category: 'smalltalk event'>

        codeWidget
            object: debugger suspendedContext receiver;
            inspectIt
    ]


    printIt [
        <category: 'smalltalk event'>

        codeWidget
            object: debugger suspendedContext receiver;
            printIt
    ]

    checkCodeWidget [
        <category: 'text editing'>

        codeWidget hasChanged ifFalse: [ codeWidget clearUndo. ^ self ].
	self saveCodeOnSave: [ state saveSource ]
    ]

    close [
        <category: 'file events'>

        codeWidget hasChanged ifFalse: [ ^ super close ].
        self saveCodeOnClose: [ super close ] onSave: [ state saveSource. super close ]
    ]

    delete: aGtkWidget event: aGdkEvent [
        <category: 'window events'>

        codeWidget hasChanged ifFalse: [ ^ window hideAll ].
        self saveCodeOnClose: [ window hideAll ] onSave: [ state saveSource. window hideAll ].
        ^ true
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
            runBlockingAndDo: [ :dlg :res |
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
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
            runBlockingAndDo: [ :dlg :res |
                res = 0 ifTrue: closeEvent.
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]
]

