GtkMainWindow subclass: GtkSUnit [
    | namespaceWidget classWidget methodWidget sourceCodeWidget successfullWidget failedWidget errorWidget namespace class |

    createFileMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Quit' connectTo: self selector: #quit}
    ]

    createEditMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' connectTo: self selector: #selectAll.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Search' connectTo: self selector: #searchClassOrMethod}
    ]

    createRunMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Run test' connectTo: self selector: #runTest}
    ]

    createToolsMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry:
            {GTK.GtkMenuItem menuItem: 'Browser' connectTo: self selector: #classBrowser.
            GTK.GtkMenuItem menuItem: 'Browser window' connectTo: self selector: #classBrowserInAWindow.
            GTK.GtkMenuItem menuItem: 'Workspace' connectTo: self selector: #workspace.
            GTK.GtkMenuItem menuItem: 'Inspector' connectTo: self selector: #gtkInspector.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'SqueakZilla' connectTo: self selector: #squeakzilla}
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About SUnit' connectTo: self selector: #aboutSUnit.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Run' withSubmenu: self createRunMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]


    createStatusBar [
        <category: 'user interface'>

        self statusMessage: 'SUnit'
    ]

    createToolbar [
        <category: 'user interface'>

	| temp |
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
            appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-execute');
	    appendSeparator.
	    temp := (GTK.GtkToolItem new)
                        add: (GTK.GtkEntry new);
                        yourself.
            self toolBar insert: temp pos: -1

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
        self
            title: 'SUnit';
            createMenus;
            createToolbar;
            createStatusBar;
            centralWidget: self buildCentralWidget.
    ]

    aboutSUnit [
        <category: 'events'>

        (GTK.GtkAboutDialog new)
            setVersion: VisualGST version;
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
            setWebsite: VisualGST website;
            setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
            "setAuthors: {'Gwenael Casaccio'. 'Nicolas Petton'};"
            setProgramName: 'GNU Smalltalk SUnit';
            run
    ]

    buildNamespaceWidget [
	<category: 'user interface'>

	namespaceWidget := GtkNamespaceWidget showAll 
				whenSelectionChangedSend: #onNamespaceChanged to: self;
				yourself.
	^ namespaceWidget mainWidget
    ]

    buildClassWidget [
	<category: 'user interface'>

	classWidget := GtkClassSUnitWidget showAll 
				whenSelectionChangedSend: #onClassChanged to: self;
				selectionMode: GTK.Gtk gtkSelectionMultiple
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

        namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
        namespace := namespaceWidget selectedNamespace.
        classWidget namespace: namespace.
    ]

    onClassChanged [
	<category: 'class events'>

        classWidget hasSelectedClass ifFalse: [ ^ self ].
        class := classWidget selectedClass.
	methodWidget class: class first withCategory: '*'.
    ]

    onMethodChanged [
	<category: 'method events'>

	methodWidget hasSelectedMethod ifFalse: [ ^ self ].
	sourceCodeWidget sourceCode: methodWidget sourceCode
    ]

    runTest [
	<category: 'run events'>

	| suite results |
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	suite := TestSuite named: class first name asString.
	class do: [ :elem |
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
]

