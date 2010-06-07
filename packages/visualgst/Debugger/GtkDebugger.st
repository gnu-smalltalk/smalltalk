GtkBrowsingTool subclass: GtkDebugger [
    | codeWidget contextWidget debugger inspectorWidget stackInspectorWidget selectedContext |

    GtkDebugger class >> open: aString [
	<category: 'user interface'>

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
	selectedContext := debugger suspendedContext parentContextAt: contextWidget positionOfSelectedContext.
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

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    clearUndo [
    ]
]

