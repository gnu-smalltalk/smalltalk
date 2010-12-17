GtkBrowsingTool subclass: GtkSUnit [
    | namespaceWidget classWidget methodWidget sourceCodeWidget successfullWidget failedWidget errorWidget namespace class state |

    accelPath [
        <category: 'accelerator path'>

        ^ '<SUnit>'
    ]

    createRunMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Load tests' connectTo: self selector: #loadTests.
	  GTK.GtkMenuItem menuItem: 'Run test' connectTo: self selector: #runTest.
	  GTK.GtkMenuItem menuItem: 'Debug test' connectTo: self selector: #debugTest}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Run' withSubmenu: self createRunMenus.
        self addMenuItem: 'Smalltalk' withSubmenu: self createSmalltalkMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]


    createToolbar [
	<category: 'user interface'>

	super createToolbar.
	self
	    appendSeparator;
            appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (GtkLauncher / 'Icons/go-run.png') file displayString) label: 'Run test')
                                connectSignal: 'clicked' to: self selector: #runTest userData: nil;
                                setTooltipText: 'Run test';
                                yourself)
    ]

    buildNamespaceAndClassWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
	    pack1: self buildNamespaceWidget resize: true shrink: false;
	    pack2: self buildClassWidget resize: true shrink: false;
	    yourself
    ]

    buildNamespaceAndClassAndMethodWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
	    pack1: self buildNamespaceAndClassWidget resize: true shrink: false;
	    pack2: self buildMethodWidget resize: true shrink: false;
	    yourself
    ]

    buildMiniBrowser [
	<category: 'user interface'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildNamespaceAndClassAndMethodWidget resize: true shrink: false;
	    pack2: self buildSourceCodeWidget resize: true shrink: false;
	    yourself
    ]

    buildResultWidget [
	<category: 'user interface'>

	^ GTK.GtkNotebook new
	    appendPage: self buildSuccesfullWidget tabLabel: (GTK.GtkLabel new: 'Successful Tests');
	    appendPage: self buildFailedWidget tabLabel: (GTK.GtkLabel new: 'Failed Tests');
	    appendPage: self buildErrorWidget tabLabel: (GTK.GtkLabel new: 'Errors Tests');
	    yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildMiniBrowser resize: true shrink: false;
	    pack2: self buildResultWidget resize: true shrink: false;
	    yourself
    ]

    initialize [
        <category: 'initialization'>

        super initialize.
	state := NamespaceState on: self with: Smalltalk
    ]

    postInitialize [
        <category: 'initialization'>

	super postInitialize.
	sourceCodeWidget postInitialize
    ]

    windowTitle [
	^ 'SUnit'
    ]

    aboutTitle [
	^ 'About SUnit'
    ]

    buildNamespaceWidget [
	<category: 'user interface'>

	namespaceWidget := GtkCategorizedNamespaceWidget showAll 
				whenSelectionChangedSend: #onNamespaceChanged to: self;
				yourself.
	^ namespaceWidget mainWidget
    ]

    buildClassWidget [
	<category: 'user interface'>

	classWidget := GtkClassSUnitWidget showAll 
				selectionMode: GTK.Gtk gtkSelectionMultiple;
				whenSelectionChangedSend: #onClassChanged to: self;
				yourself.
	^ classWidget mainWidget
    ]

    buildMethodWidget [
	<category: 'user interface'>

	methodWidget := GtkMethodSUnitWidget showAll
				whenSelectionChangedSend: #onMethodChanged to: self;
                                yourself.
        ^ methodWidget mainWidget
    ]

    buildSourceCodeWidget [
        <category: 'user interface'>

        sourceCodeWidget := GtkSourceCodeWidget showAll.
	sourceCodeWidget parentWindow: window.
	sourceCodeWidget browser: self.
        ^ sourceCodeWidget mainWidget
    ]

    buildSuccesfullWidget [
	<category: 'user interface'>

	successfullWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ successfullWidget mainWidget
    ]

    buildFailedWidget [
	<category: 'user interface'>

	failedWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ failedWidget mainWidget
    ]

    buildErrorWidget  [
	<category: 'user interface'>

	errorWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ errorWidget mainWidget
    ]

    onNamespaceChanged [
	<category: 'namespace events'>

	self checkCodeWidgetAndUpdate: [
            namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	    self selectANamespace: namespaceWidget selectedNamespace ]
    ]

    selectANamespace: aNamespace [
	<category: 'browser methods'>

	(namespaceWidget hasSelectedNamespace and: [aNamespace = namespaceWidget selectedNamespace]) ifFalse: [
            namespaceWidget selectANamespace: aNamespace ].
        namespace := aNamespace.
	aNamespace isNil ifTrue: [ ^self ].
        classWidget namespace: aNamespace category: ''.
	state := NamespaceState on: self with: aNamespace
    ]

    onClassChanged [
	<category: 'class events'>

	self checkCodeWidgetAndUpdate: [
            classWidget hasSelectedClass ifFalse: [ ^ self ].
	    self selectAClass: classWidget selectedClass ]
    ]

    selectAClass: aClass [
	<category: 'browser methods'>

	(classWidget hasSelectedClass and: [aClass = classWidget selectedClass]) ifFalse: [
            classWidget selectAClass: aClass ].
        class := aClass.
	aClass isNil ifTrue: [ ^self ].
	methodWidget class: class withCategory: '*'.
	state := CategoryState on: self with: class -> '*'
    ]

    onMethodChanged [
	<category: 'method events'>

	self checkCodeWidgetAndUpdate: [
	    methodWidget hasSelectedMethod ifFalse: [^self].
	    self selectAnInstanceMethod: methodWidget selectedMethodSymbol ]
    ]

    selectAnInstanceMethod: aSymbol [
	<category: 'browser methods'>

	(methodWidget hasSelectedMethod and: [aSymbol = methodWidget selectedMethodSymbol]) ifFalse: [
            methodWidget selectAMethod: aSymbol asString ].
	sourceCodeWidget source: (BrowserMethodSource on: methodWidget selectedMethod).
	state := MethodState on: self with: methodWidget selectedMethod
    ]

    state [
	<category: 'browser methods'>

        ^state
    ]

    classOrMeta [
	<category: 'browser methods'>

	^class
    ]

    loadTest: aPackage [
	<category: 'private'>
	<comment: 'I load the unit tests for one package'>

	| test files |

	aPackage ifNil: [^self].

	test := aPackage test.
	test ifNil: [^self].

	test fileIn.
    ]

    loadTests [
        <category: 'run events'>
	<comment: 'I load the unit tests for the loaded packages'>

	Smalltalk Features do: [:each | |package|
		package := PackageLoader packageAt: each ifAbsent: [nil].
		self loadTest: package.
	]
    ]

    runTest [
	<category: 'run events'>

	| suite results name |
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	suite := TestSuite named: classWidget allClassNames.
	classWidget selectedClasses do: [ :elem |
	    elem selectors do: [ :each |
		(each matchRegex: 'test' from: 1 to: 4)
		    ifTrue: [ suite addTest: (elem selector: each) ] ] ].
	suite logPolicy: TestBacktraceLog new.
	results := suite run.

	successfullWidget results: results passed.
	failedWidget results: results failures.
	errorWidget results: results errors.

	results failures do: [ :each | each "logPolicy logStatus inspect" printNl ].
    ]

    debugTest [
	<category: 'run events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	classWidget selectedClasses do: [ :elem | | test |
	    test := elem new.
	    elem selectors do: [ :each |
		(each matchRegex: 'test' from: 1 to: 4)
		    ifTrue: [ test setTestSelector: each. test debug ] ] ].
    ]

    compileError: aString line: line [
        <category: 'method events'>

        sourceCodeWidget compileError: aString line: line
    ]

    focusedWidget [
	<category: 'events'>

	^sourceCodeWidget focusedWidget
    ]

    acceptIt [
        <category: 'smalltalk events'>

        AcceptItCommand executeOn: self
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

    close [
        <category: 'file events'>

        self saveCodeOr: [ super close ]
    ]

    clearUndo [
        <category: 'source code'>

	sourceCodeWidget clearUndo
    ]

    hasChanged [
        <category: 'testing'>

        ^ sourceCodeWidget hasChanged
    ]

    sourceCode [
        <category: 'accessing'>

        ^ sourceCodeWidget sourceCode
    ]

    codeSaved [
	<category: 'code saved'>

	sourceCodeWidget codeSaved
    ]

    targetObject [
        <category: 'smalltalk event'>

        ^self state classOrMeta
    ]

    doIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget inspectIt: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget printIt: object
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

	^ sourceCodeWidget hasChanged
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

    sourceCodeWidgetHasFocus [
        <category: 'focus'>

        ^ sourceCodeWidget hasFocus
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^sourceCodeWidget selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        ^sourceCodeWidget hasSelection
    ]

]

