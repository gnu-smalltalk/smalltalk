GtkMainWindow subclass: GtkDebugger [
    | state codeWidget contextWidget debugger inspectorWidget stackInspectorWidget selectedContext |

    GtkDebugger class >> open [
	<category: 'user interface'>

	^ super open
	    resize: 1024@600;
	    yourself
    ]

    GtkDebugger class >> open: aString [
	<category: 'user interface'>

        "The current process might be processing an event.  Gtk will
         block inside g_main_loop_dispatch and won't deliver any
         other events until this one is processed.  So, fork into a
         new process and return nil without executing #ensure: blocks."
        Processor activeProcess detach.

	[ :debugger |
	    Processor activeProcess name: 'Notifier/Debugger'.
	    (self openSized: 1024@600)
		title: ('VisualGST Debugger ', aString);
		debugger: debugger ] forkDebugger
    ]
    
    GtkDebugger class >> debuggerClass [
        <category: 'debugging interface'>

        ^ nil
    ]

    GtkDebugger class >> debuggingPriority [
	<category: 'debugging interface'>

	^ 1
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
	    showModalDestroy
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
	    appendTag: #debug
		description: #('paragraph-background' 'grey83' 'foreground' 'black' nil);
	    parentWindow: window;
	    browser: self;
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
	    {'<Control><Shift>S'. '<GtkDebugger>/File/SaveAs'. self. #saveAs}.
	    {'<Control>Q'. '<GtkDebugger>/File/Close'. self. #close}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
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

	| package |
	package := PackageLoader packageAt: 'VisualGST'.
	self
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
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-apply' label: 'Accept It')
				connectSignal: 'clicked' to: self selector: #acceptIt userData: nil;
				setTooltipText: 'Accept It';
				yourself);
	    appendSeparator;
	    appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (package / 'Icons/go-run.png') file displayString) label: 'Continue')
				connectSignal: 'clicked' to: self selector: #run userData: nil;
				setTooltipText: 'Continue';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (package / 'Icons/go-next.png') file displayString) label: 'Step into')
				connectSignal: 'clicked' to: self selector: #stepInto userData: nil;
				setTooltipText: 'Step into';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (package / 'Icons/go-jump.png') file displayString) label: 'Step to here')
				connectSignal: 'clicked' to: self selector: #step userData: nil;
				setTooltipText: 'Step to here';
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

    debugger: aDebugger [
        <category: 'context'>

	debugger := aDebugger.
	self 
	    updateContextWidget
    ]

    skipTopContext [
        <category: 'context'>

        | context lastContext contexts |
        context := debugger suspendedContext.
        lastContext := context environment.
        "stacktrace := OrderedCollection new."
        contexts := OrderedCollection new.

        [ context ~~ lastContext and: [ context isInternalExceptionHandlingContext ] ]
            whileTrue: [ context := context parentContext ].
        [ context == lastContext ] whileFalse:
                [ context isDisabled
                    ifFalse:
                        [ "stacktrace add: context printString."
                        contexts add: context ].
                context := context parentContext ].
    ]

    initializeProcess: aProcess [
        <category: 'context'>

        debugger := Debugger on: aProcess suspend.
    ]

    updateInspectorWidget: aContext [
	<category: 'context'>

	| method |
	method := aContext method method.
	state := MethodState on: self with: method methodClass -> method.
        inspectorWidget object: aContext receiver.
        stackInspectorWidget object: aContext
    ]

    updateContextWidget [
	<category: 'context'>

	contextWidget
            context: debugger suspendedContext;
            selectFirstContext.

	self updateInspectorWidget: debugger suspendedContext
    ]

    doItProcess: aProcess [
	<category: 'context'>

	self initializeProcess: aProcess.
	3 timesRepeat: [ debugger step ].
	debugger myStepInto.
	self updateContextWidget
    ]

    process: aProcess [
	<category: 'context'>
	
	self 
	    initializeProcess: aProcess;
	    updateContextWidget
    ]

    inspectMethod [
	<category: 'method events'>

	InspectMethodCommand on: self
    ]

    selectedMethod [
	<category: 'method events'>

	^selectedContext ifNotNil: [ selectedContext method ].
    ]

    contextChanged [
	<category: 'context events'>

	| iter |
	self checkCodeWidget.
	contextWidget hasSelectedContext ifFalse: [ ^ self ].
	iter := contextWidget selectedIter.
	selectedContext := debugger suspendedContext parentContextAt: ((contextWidget model getPath: iter) getIndices value) + 1.
	codeWidget sourceCode: selectedContext method methodSourceString.
	codeWidget object: selectedContext receiver.
	codeWidget applyTag: #debug forLine: selectedContext currentLine.
	self updateInspectorWidget: selectedContext
    ]

    step [
	<category: 'execute events'>

	| iter |
	iter := contextWidget selectedIter.

	contextWidget numberOfContext = ((contextWidget model getPath: iter) getIndices value + 1)
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

    codeSaved [
	<category: 'method events'>

	codeWidget codeSaved
    ]

    classOrMetaSelected [
	<category: 'method events'>

	^state classOrMetaSelected
    ]

    sourceCode [
	<category: 'method events'>

	^codeWidget sourceCode
    ]

    selectedCategory [
	<category: 'method events'>

	^state selectedCategory
    ]

    acceptIt [
	<category: 'method events'>

	AddMethodCommand on: self.
    ]

    doIt [
        <category: 'smalltalk event'>

        codeWidget doIt
    ]

    debugIt [
        <category: 'smalltalk event'>

        codeWidget debugIt
    ]


    inspectIt [
        <category: 'smalltalk event'>

        codeWidget inspectIt
    ]


    printIt [
        <category: 'smalltalk event'>

        codeWidget printIt
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
            showModalOnAnswer: [ :dlg :res |
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
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: closeEvent.
                res = 1 ifTrue: saveEvent.
                dlg destroy ].
    ]
]

