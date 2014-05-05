"======================================================================
|
| GtkDebugger class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

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

        ^ '<Debugger>'
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

        self accelGroup append: {{'F7'. '<Debugger>/StepInto'}}.
        self accelGroup append: {{'F8'. '<Debugger>/StepOver'}}.
        self accelGroup append: {{'<shift>F8'. '<Debugger>/StepOut'}}.
        self accelGroup append: {{'F5'. '<Debugger>/Continue'}}.

        ^{GTK.GtkMenuItem menuItem: 'Restart selected frame' connectTo: self selector: #restartSelectedFrame.
          GTK.GtkMenuItem new.
          GTK.GtkMenuItem menuItem: 'Step into next message send' accelPath: '<Debugger>/StepInto' connectTo: self selector: #stepInto.
          GTK.GtkMenuItem menuItem: 'Step over next message send' accelPath: '<Debugger>/StepOver' connectTo: self selector: #stepOver.
          GTK.GtkMenuItem menuItem: 'Step out current message' accelPath: '<Debugger>/StepOut' connectTo: self selector: #stepOut.
          GTK.GtkMenuItem new.
          GTK.GtkMenuItem menuItem: 'Continue' accelPath: '<Debugger>/Continue' connectTo: self selector: #continue}
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

        "Show meaningful source code to the user."
        [ debugger suspendedContext isInternalExceptionHandlingContext ]
            whileTrue: [ debugger slowFinish ].

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

	debugger suspendedContext ifNil: [ ^ self close ].
	contextWidget
            context: debugger suspendedContext;
            selectFirstContext.

	self updateInspectorWidget: debugger suspendedContext
    ]

    doItProcess: aProcess [
	<category: 'context'>

	self initializeProcess: aProcess.
	4 timesRepeat: [ debugger step ].
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

	self checkCodeWidgetAndUpdate: [
            | line |
	    contextWidget hasSelectedContext ifFalse: [ ^ self ].
	    codeWidget source: (BrowserMethodSource on: contextWidget selectedContext method).
            contextWidget selectedContext currentLine ~= 0
                ifTrue: [ line := contextWidget selectedContext currentLine ]
                ifFalse: [ line := 1 ].
            codeWidget
                applyTag: #debug forLine: line;
                centerViewAtLine: line.
	    self updateInspectorWidget: contextWidget selectedContext ]
    ]

    stepInto [
        <category: 'execute events'>

        self debugWith: [ debugger step ]
    ]

    stepOver [
        <category: 'execute events'>

        self debugWith: [ debugger slowNext ]
    ]

    stepOut [
        <category: 'execute events'>

        self debugWith: [ debugger finish ]
    ]

    finishDangerousContexts [
        | methods |
        "VisualGST is running in the same image as the to be de-bugged
        processed. If the process is suspended in a critical section
        VisualGST might end up in a live-lock. As long as VisualGST is
        running in the same image there is no way we can avoid this."

        "Nothing is suspended."
        debugger suspendedContext ifNil: [^self].

        "Methods we need to finish or bad things will happen."
        methods := {Object>>#removeToBeFinalized. Object>>#addToBeFinalized}.

        (methods includes: debugger suspendedContext method)
            ifTrue: [debugger finish].
    ]

    debugWith: aBlock [
        <category: 'execute events'>

        TaskQueue uniqueInstance add: [
            self isLastContextSelected ifFalse: [ self stepToSelectedContext ].
            aBlock value.
            self finishDangerousContexts.
            self updateContextWidget ]
    ]

    continue [
        <category: 'execute events'>

        self close.
        debugger suspendedContext ifNil: [ ^ self ].
        debugger continue
    ]

    stepToSelectedContext [
       <category: 'execute events'>

        | ctxt |
        ctxt := debugger suspendedContext.
        [ ctxt parentContext == contextWidget selectedContext ] whileFalse: [ ctxt := ctxt parentContext ].
        debugger finish: ctxt
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

        codeWidget hasFocus ifFalse: [ ^ self focusedWidget doIt: object ].
        codeWidget hasSelection ifFalse: [ ^ self ].
        [ debugger eval: codeWidget selectedText ] fork.
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        codeWidget hasFocus ifFalse: [ ^ self focusedWidget debugIt: object ].
        codeWidget hasSelection ifFalse: [ ^ self ].
        debugger eval: 'VisualGST.GtkDebugger open doItProcess: [ ', codeWidget selectedText, ' ] newProcess'
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        codeWidget hasFocus ifFalse: [ ^ self focusedWidget inspectIt: object ].
        codeWidget hasSelection ifFalse: [ ^ self ].
        [ (debugger eval: codeWidget selectedText) gtkInspect ] fork.
    ]

    printIt: object [
        <category: 'smalltalk event'>

        codeWidget hasFocus ifFalse: [ ^ self focusedWidget printIt: object ].
        codeWidget hasSelection ifFalse: [ ^ self ].
        [ codeWidget printString: (debugger eval: codeWidget selectedText) ] fork.
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

    isLastContextSelected [
        <category: 'testing'>

        ^ contextWidget selectedContext == debugger suspendedContext
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

    selectAnInstanceMethod: aMethod [
        <category: 'debugging events'>

        debugger restart: contextWidget selectedContext.
	self updateContextWidget
    ]

    selectAClassMethod: aMethod [
        <category: 'debugging events'>

        debugger restart: contextWidget selectedContext.
	self updateContextWidget
    ]

    restartSelectedFrame [
        <category: 'debugging events'>

        debugger restart: contextWidget selectedContext.
        debugger suspendedContext inspect.
        self updateContextWidget
    ]
]

