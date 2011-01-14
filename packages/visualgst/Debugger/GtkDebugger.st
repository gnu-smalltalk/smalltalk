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

    accelPath [
        <category: 'accelerator path'>

        ^ '<VisualGST>'
    ]

    windowTitle [
	^ 'Debugger'
    ]

    aboutTitle [
	^ 'About Debugger'
    ]

    postInitialize [
        <category: 'initialization'>

        super postInitialize.
	codeWidget postInitialize.
	inspectorWidget postInitialize.
	stackInspectorWidget postInitialize.
    ]
 
    buildContextWidget [
	<category: 'user interface'>

	^ contextWidget := (GtkContextWidget parentWindow: window)
				whenSelectionChangedSend: #contextChanged to: self;
				yourself
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ inspectorWidget := GtkInspectorWidget parentWindow: window
    ]

    buildSourceWidget [
	<category: 'user interface'>

	^ codeWidget := (GtkSourceCodeWidget parentWindow: window) 
			    appendTag: #debug description: #('paragraph-background' 'grey83' 'foreground' 'black' nil);
			    browser: self;
			    yourself
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

	^ GTK.GtkHPaned addAll: {self buildInspectorWidget mainWidget. self buildStackInspectorWidget}
    ]

    buildCodeAndStateWidget [
	<category: 'intialize-release'>

	^ GTK.GtkVPaned addAll: {self buildSourceWidget mainWidget. self buildInspectorsWidget}
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	^ GTK.GtkVPaned addAll: {self buildContextWidget mainWidget. self buildCodeAndStateWidget}
    ]

    createExecuteMenus [
	<category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Step' connectTo: self selector: #step.
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

	super createToolbar.
	DebuggerToolbar buildToolbarOn: self
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

    browserHasFocus [
        <category: 'command protocols'>

        ^self focusedWidget == codeWidget
    ]

    sourceCodeWidgetHasFocus [ 
        <category: 'focus'>
        
        ^ codeWidget hasFocus
    ]   
    
    selectedText [
        <category: 'smalltalk events'>
        
        ^codeWidget selectedText
    ]
    
    hasSelection [ 
        <category: 'smalltalk events'>
        
        ^codeWidget hasSelection
    ]

    contextChanged [
	<category: 'context events'>

	| iter |
	self checkCodeWidgetAndUpdate: [
	    contextWidget hasSelectedContext ifFalse: [ ^ self ].
	    codeWidget source: (BrowserMethodSource on: contextWidget selectedContext method).
	    codeWidget applyTag: #debug forLine: contextWidget selectedContext currentLine.
	    self updateInspectorWidget: contextWidget selectedContext ]
    ]

    step [
	<category: 'execute events'>

	contextWidget isLastContextSelected
	    ifTrue: [ debugger myStep ]
	    ifFalse: [ debugger finish: contextWidget selectedContext ].
	self updateContextWidget
    ]

    stepInto [
	<category: 'execute events'>

	contextWidget isLastContextSelected
	    ifTrue: [ debugger myStepInto ]
	    ifFalse: [ debugger finish: contextWidget selectedContext ].
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

    selectedClass [
	<category: 'method events'>

	^ self state classOrMeta
    ]

    sourceCode [
	<category: 'method events'>

	^ codeWidget sourceCode
    ]

    selectedCategory [
	<category: 'method events'>

	^ self state selectedCategory
    ]

    compileError: aString line: line [
        <category: 'method events'>

        codeWidget compileError: aString line: line
    ]

    acceptIt [
	<category: 'method events'>

	AcceptItCommand executeOn: self.
    ]

    targetObject [
        <category: 'smalltalk event'>

        inspectorWidget hasFocus ifTrue: [^inspectorWidget object].

        "TODO: make ContextState so that targetObject can be
         moved to the BrowserState hierarchy."
	^contextWidget hasSelectedContext ifTrue: [contextWidget selectedContext receiver] ifFalse: [nil]
    ]

    focusedWidget [
        <category: 'widget'>

        inspectorWidget hasFocus ifTrue: [ ^ inspectorWidget ].
        stackInspectorWidget hasFocus ifTrue: [ ^ stackInspectorWidget ].
        ^ codeWidget
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

    state [
        <category: 'actions'>

        ^contextWidget state
    ]

    clearUndo [
        <category: 'smalltalk event'>

        codeWidget clearUndo
    ]

    doIt [
        <category: 'smalltalk event'>

        DoItCommand executeOn: self
    ]

    debugIt [
        <category: 'smalltalk event'>

        DebugItCommand executeOn: self
    ]

    inspectIt [
        <category: 'smalltalk event'>

        InspectItCommand executeOn: self
    ]

    printIt [
        <category: 'smalltalk event'>

        PrintItCommand executeOn: self
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

