GtkBrowsingTool subclass: GtkDebugger [
    | codeWidget contextWidget debugger inspectorWidget stackInspectorWidget |

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

    windowTitle [
	^ 'Debugger'
    ]

    aboutTitle [
	^ 'About Debugger'
    ]

    postInitialize [
        <category: 'initialization'>

	codeWidget postInitialize.
	inspectorWidget postInitialize.
	stackInspectorWidget postInitialize.
        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
    ]
 
    buildContextWidget [
	<category: 'user interface'>

	^ (contextWidget := GtkContextWidget new)
            parentWindow: window;
	    initialize;
	    whenSelectionChangedSend: #contextChanged to: self;
	    mainWidget
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ (inspectorWidget := GtkInspectorWidget new)
            parentWindow: window;
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
            parentWindow: window;
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

    createExecuteMenus [
	<category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Step' connectTo: self selector: #step.
            GTK.GtkMenuItem menuItem: 'Step into' connectTo: self selector: #stepInto.
            GTK.GtkMenuItem menuItem: 'Step over' connectTo: self selector: #stepOver.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Run' connectTo: self selector: #run}
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

    createToolbar [
	<category: 'user interface'>

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
	    appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (GtkLauncher / 'Icons/go-run.png') file displayString) label: 'Continue')
				connectSignal: 'clicked' to: self selector: #run userData: nil;
				setTooltipText: 'Continue';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (GtkLauncher / 'Icons/go-next.png') file displayString) label: 'Step into')
				connectSignal: 'clicked' to: self selector: #stepInto userData: nil;
				setTooltipText: 'Step into';
				yourself);
	    appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (GtkLauncher / 'Icons/go-jump.png') file displayString) label: 'Step to here')
				connectSignal: 'clicked' to: self selector: #step userData: nil;
				setTooltipText: 'Step to here';
				yourself)
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

    hasSelectedMethod [
	<category: 'method events'>

	^self hasSelectedContext
    ]

    selectedMethod [
	<category: 'method events'>

	^self selectedContext method
    ]

    hasSelectedContext [
        <category: 'method events'>

        ^contextWidget hasSelectedContext
    ]

    selectedContext [
        <category: 'method events'>

        ^contextWidget selectedContext
    ]

    contextChanged [
	<category: 'context events'>

	| iter |
	self checkCodeWidget.
	self hasSelectedContext ifFalse: [ ^ self ].
	codeWidget sourceCode: self selectedContext method methodSourceString.
	codeWidget applyTag: #debug forLine: self selectedContext currentLine.
	self updateInspectorWidget: self selectedContext
    ]

    step [
	<category: 'execute events'>

	| iter |
	iter := contextWidget selectedIter.

	contextWidget numberOfContext = ((contextWidget model getPath: iter) getIndices value + 1)
	    ifTrue: [ debugger myStep ]
	    ifFalse: [ debugger finish: self selectedContext ].
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

    targetObject [
        <category: 'smalltalk event'>

	^self hasSelectedContext ifTrue: [self selectedContext receiver] ifFalse: [nil]
    ]

    focusedWidget [
        <category: 'widget'>

        inspectorWidget hasFocus ifTrue: [^inspectorWidget].
        stackInspectorWidget hasFocus ifTrue: [^stackInspectorWidget].
        ^codeWidget
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        ^self focusedWidget perform: aSymbol
    ]

    doIt: object [
        <category: 'smalltalk event'>

        self focusedWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        self focusedWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        self focusedWidget inspectIt: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        self focusedWidget printIt: object
    ]

    clearUndo [
        <category: 'smalltalk event'>

        codeWidget clearUndo
    ]

    doIt [
        <category: 'smalltalk event'>

        DoItCommand on: self
    ]

    debugIt [
        <category: 'smalltalk event'>

        DebugItCommand on: self
    ]

    inspectIt [
        <category: 'smalltalk event'>

        InspectItCommand on: self
    ]

    printIt [
        <category: 'smalltalk event'>

        PrintItCommand on: self
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
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

]

