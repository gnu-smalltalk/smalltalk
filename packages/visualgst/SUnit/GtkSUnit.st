GtkBrowsingTool subclass: GtkSUnit [
    | namespaceWidget classWidget methodWidget sourceCodeWidget successfullWidget failedWidget errorWidget namespace class |

    createRunMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {
		GTK.GtkMenuItem menuItem: 'Load tests' connectTo: self selector: #loadTests.
		GTK.GtkMenuItem menuItem: 'Run test' connectTo: self selector: #runTest}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Run' withSubmenu: self createRunMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]


    createToolbar [
	<category: 'user interface'>

        | package |
        package := PackageLoader packageAt: 'VisualGST'.
	super createToolbar.
	self
	    appendSeparator;
            appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (package / 'Icons/go-run.png') file displayString) label: 'Run test')
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

	self checkCodeWidget.
        namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	self selectANamespace: namespaceWidget selectedNamespace
    ]

    selectANamespace: aNamespace [
	<category: 'browser methods'>

	aNamespace = namespaceWidget selectedNamespace ifFalse: [
            namespaceWidget selectANamespace: aNamespace ].
        namespace := aNamespace.
	aNamespace isNil ifTrue: [ ^self ].
        classWidget namespace: aNamespace category: ''.
	state := NamespaceState on: self with: aNamespace
    ]

    onClassChanged [
	<category: 'class events'>

	self checkCodeWidget.
        classWidget hasSelectedClass ifFalse: [ ^ self ].
	self selectAClass: classWidget selectedClass
    ]

    selectAClass: aClass [
	<category: 'browser methods'>

	aClass = classWidget selectedClass ifFalse: [
            classWidget selectAClass: aClass ].
        class := aClass.
	aClass isNil ifTrue: [ ^self ].
	methodWidget class: class withCategory: '*'.
	state := CategoryState on: self with: class -> '*'
    ]

    onMethodChanged [
	<category: 'method events'>

	self checkCodeWidget.
	self selectAnInstanceMethod: methodWidget selectedMethodSymbol.
    ]

    selectAnInstanceMethod: aSymbol [
	<category: 'browser methods'>

	aSymbol = methodWidget selectedMethodSymbol ifFalse: [
            methodWidget selectAMethod: aSymbol asString ].
	aSymbol isNil ifTrue: [ ^self ].
	sourceCodeWidget sourceCode: methodWidget sourceCode.
	state := MethodState on: self with: class -> methodWidget selectedMethod
    ]

    classOrMetaSelected [
	<category: 'browser methods'>

	^class
    ]

    selectedCategory [
	<category: 'browser methods'>

	^ methodWidget selectedMethod
	    ifNil: [ 'unit tests' ]
	    ifNotNil: [ :method | method methodCategory ]
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

    onFocusPerform: aSymbol [
	<category: 'events'>

	sourceCodeWidget hasFocus ifTrue: [ sourceCodeWidget perform: aSymbol ]
    ]

    acceptIt [
	<category: 'method events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	AddMethodCommand on: self.
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

        sourceCodeWidget hasChanged ifFalse: [ ^ super close ].
        self saveCodeOnClose: [ super close ] onSave: [ state saveSource. super close ]
    ]

    clearUndo [
	^ sourceCodeWidget clearUndo
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

]

