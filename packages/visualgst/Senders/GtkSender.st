GtkMainWindow subclass: GtkSender [
    GtkSender class [ | LiteralsAndSpecialSelectors | ]

    GtkSender class >> openOn: aSelector [
	<category: 'instance creation'>

	^ (self new)
            initialize;
            selector: aSelector;
            showAll;
            yourself
    ]

    GtkSender class >> literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^ LiteralsAndSpecialSelectors ifNil: [
            LiteralsAndSpecialSelectors := Dictionary new.
            "[" CompiledMethod allInstancesDo: [ :each |
                each literalsAndSpecialSelectorsDo: [ :lit |
		    lit isSymbol ifTrue: [
			(LiteralsAndSpecialSelectors at: lit ifAbsentPut: [ OrderedCollection new ]) add: each ] ] ] "] fork".
            LiteralsAndSpecialSelectors ]
    ]

    | currentMethod selector finderModel finderTree senderResults senderModel senderTree classBrowserWidget searchEntry |

    selector: aSelector [
	<category: 'accessor'>

	selector := aSelector
    ]

    createFileMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Control>O'. '<GtkSender>/File/Open'}.
            {'<Control>S'. '<GtkSender>/File/Save'}.
            {'<Control><Shift>S'. '<GtkSender>/File/SaveAs'}.
            {'<Control>Q'. '<GtkSender>/File/Close'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkSender>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' accelPath: '<GtkSender>/File/Save' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkSender>/File/SaveAs' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkSender>/File/Close' connectTo: self selector: #close}
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

    createHistoryMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Alt>Left'. '<GtkLauncher>/History/Back'}.
            {'<Alt>Right'. '<GtkLauncher>/History/Forward'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'back' accelPath: '<GtkLauncher>/History/Back' connectTo: self selector: #back.
            GTK.GtkMenuItem menuItem: 'Forward' accelPath: '<GtkLauncher>/History/Forward' connectTo: self selector: #forward}
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkLauncher>/Smalltalk/DoIt'}.
            {'<Control>P'. '<GtkLauncher>/Smalltalk/PrintIt'}.
            {'<Control>I'. '<GtkLauncher>/Smalltalk/InspectIt'}.
            {'<Alt>D'. '<GtkLauncher>/Smalltalk/DebugIt'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkLauncher>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkLauncher>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkLauncher>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' accelPath: '<GtkLauncher>/Smalltalk/DebugIt' connectTo: self selector: #debugIt}
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

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About Smalltalk Sender' connectTo: self selector: #aboutSender.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>
        self createMainMenu: {#('File' #createFileMenus).
            #('Edit' #createEditMenus).
            #('History' #createHistoryMenus).
            #('Smalltalk' #createSmalltalkMenus).
            #('Tools' #createToolsMenus).
            #('Help' #createHelpMenus)}
    ]


    createStatusBar [
        <category: 'user interface'>

        self statusMessage: 'Gtk Smalltalk Sender'
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

    buildFinderEntry [
	<category: 'user interface'>

	searchEntry := (GTK.GtkEntry new)
                            connectSignal: 'activate' to: self selector: #searchValidate userData: nil;
                            yourself.
	^ (GTK.GtkHBox new: true spacing: 3)
	    add: (GTK.GtkLabel new: 'Class or method :');
	    add: searchEntry;
	    yourself
    ]

    buildFinderTree [
	<category: 'user interface'>

	finderTree := GTK.GtkTreeView newWithSortedTextColumn: self finderModel gtkModel title: 'Selectors'.
        self finderModel isSorted ifFalse: [
	    (finderTree getColumn: 0) signalEmitByName: 'clicked' args: {}.
	    self finderModel isSorted: true ].
        finderTree
            getSelection
                connectSignal: 'changed' to: self selector: #finderSelected userData: nil.
        ^ GTK.GtkScrolledWindow withChild: finderTree
    ]

    finderModel [
	<category: 'model accessing'>

	^ finderModel ifNil: [
	    finderModel := GtkImageModel current ]
    ]

    senderModel [
        <category: 'model accessing'>

        ^ senderModel ifNil: [
            senderModel := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    clearSenderModel [
	<category: 'model cleaning'>

	self senderModel clear
    ]

    buildFinderList [
	<category: 'user interface'>

	^ GTK.GtkVPaned new
            add1: self buildFinderEntry;
            add2: self buildFinderTree;
            yourself
    ]

    buildSenderList [
        <category: 'user interface'>

	senderTree := GTK.GtkTreeView newWithSortedTextColumn: self senderModel title: 'Senders'.
	(senderTree getColumn: 0) signalEmitByName: 'clicked' args: {}.
        senderTree
            getSelection
                connectSignal: 'changed' to: self selector: #senderSelected userData: nil.
        ^ GTK.GtkScrolledWindow withChild: senderTree
    ]

    buildSenderAndClassBrowser [
	<category: 'user interface'>

        ^ GTK.GtkVPaned new
            add1: self buildSenderList;
            add2: ((classBrowserWidget := GtkClassBrowserWidget new)
                        initialize;
                        mainWidget);
            yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

	^ (GTK.GtkHPaned new)
	    add1: self buildFinderList;
	    add2: self buildSenderAndClassBrowser;
	    yourself
    ]

    initialize [
        <category: 'initialization'>

        super initialize.
        self
            title: 'GNU Smalltalk Sender';
            createMenus;
            createToolbar;
            createStatusBar;
            centralWidget: self buildCentralWidget.
	finderTree setSearchEntry: searchEntry.
    ]

    postInitialize [
        <category: 'initialization'>

        searchEntry grabFocus
    ]

    aboutSender [
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
            setProgramName: 'GNU Smalltalk Sender';
            run
    ]

    findInMethod: anObject [
	<category: 'find'>
	
	senderResults := Dictionary new.
	(self literalsAndSpecialSelectors at: anObject asSymbol ifAbsent: [ #() ] ) do: [ :each |
	    self senderModel appendItem: {each displayString}.
	    senderResults at: each displayString put: each ].
    ]

    literalsAndSpecialSelectors [
	<category: 'accessing'>

	^ self class literalsAndSpecialSelectors
    ]

    finderSelected [
	<category: 'finder events'>

	| iter string |
	(iter := finderTree selectedIter) ifNil: [ ^ self ].

	self 
	    clearSenderModel;
	    findInMethod: (self finderModel selectedItem: iter) values first element.
    ]

    senderSelected [
	<category: 'sender events'>

	| count iter path selectedIter selectedString string |
        (selectedIter := senderTree selectedIter) ifNil: [ ^ self ].
        selectedString := (self senderModel getOop: selectedIter column: 0).
	currentMethod := senderResults at: selectedString ifAbsent: [ ^ self error: selectedString, 'not in the list' ].

        classBrowserWidget
                selectANamespace: currentMethod methodClass environment;
                selectAClass: (currentMethod methodClass isClass ifTrue: [ currentMethod methodClass ] ifFalse: [ currentMethod methodClass instanceClass ]).
        currentMethod methodClass isClass
                ifTrue: [ classBrowserWidget selectAnInstanceMethod: currentMethod selector ]
                ifFalse: [ classBrowserWidget selectAClassMethod: currentMethod selector  ]
    ]

    searchValidate [
        <category: 'search entry events'>

        searchEntry getText isEmpty ifTrue: [ ^ finderTree setModel: (finderModel := GtkImageModel current) gtkModel ].
        finderTree setModel: (finderModel := (GtkImageModel current matchRegex: searchEntry getText)) gtkModel
    ]

    back [
        <category: 'history events'>

        classBrowserWidget back
    ]

    forward [
        <category: 'history events'>

        classBrowserWidget forward
    ]
]

