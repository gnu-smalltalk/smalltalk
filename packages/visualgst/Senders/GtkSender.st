GtkMainWindow subclass: GtkSender [
    GtkSender class [ | LiteralsAndSpecialSelectors | ]

    GtkSender class >> open [
	<category: 'instance creation'>

	^ super open
	    resize: 1024@600;
	    yourself
    ]

    GtkSender class >> openOn: aSelector [
	<category: 'instance creation'>

	^ (self new)
            selector: aSelector;
            initialize;
	    resize: 1024@600;
            showAll;
            yourself
    ]

    GtkSender class >> literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^ LiteralsAndSpecialSelectors ifNil: [
            LiteralsAndSpecialSelectors := Dictionary new.
            "[" CompiledMethod allInstancesDo: [ :each |
                each literalsAndSpecialSelectorsDo: [ :lit |
		    lit isSymbol 
			ifTrue: [ (LiteralsAndSpecialSelectors at: lit ifAbsentPut: [ OrderedCollection new ]) add: each ]
			ifFalse: [  "lit isClass ifTrue: [ lit displayString printNl.
					    (LiteralsAndSpecialSelectors at: lit displayString asSymbol ifAbsentPut: [ OrderedCollection new ]) add: each ]" ]
				 ] ] "] fork".
            LiteralsAndSpecialSelectors ]
    ]

    | imageWidget currentMethod selector senderResults senderModel senderTree classBrowserWidget |

    selector [
	<category: 'accessor'>

	^selector
    ]

    selector: aSymbol [
	<category: 'accessor'>

	selector := aSymbol asSymbol.
	self 
	    clearSenderModel;
	    findInMethod: (imageWidget model matchSelector: aSymbol) values first element.
    ]

    createFileMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Control>O'. '<GtkSender>/File/Open'}.
            {'<Control><Shift>S'. '<GtkSender>/File/SaveAs'}.
            {'<Control>Q'. '<GtkSender>/File/Close'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkSender>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' accelPath: '<GtkSender>/File/Save' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkSender>/File/SaveAs' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkSender>/File/Close' connectTo: self selector: #close}
    ]

    createEditMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control><shift>Z'. '<GtkSender>/Edit/Cancel'}.
            {'<Control>Z'. '<GtkSender>/Edit/Undo'}.
            {'<Control>R'. '<GtkSender>/Edit/Redo'}.
            {'<Control>X'. '<GtkSender>/Edit/Cut'}.
            {'<Control>C'. '<GtkSender>/Edit/Copy'}.
            {'<Control>V'. '<GtkSender>/Edit/Paste'}.
            {'<Control>A'. '<GtkSender>/Edit/SelectAll'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkSender>/Edit/Cancel' connectTo: self selector: #cancel.
            GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkSender>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkSender>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkSender>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkSender>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkSender>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkSender>/Edit/SelectAll' connectTo: self selector: #selectAll}
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
            {'<Control>S'. '<GtkLauncher>/Smalltalk/AcceptIt'}.
            {'<Control>I'. '<GtkLauncher>/Smalltalk/InspectIt'}.
            {'<Alt>D'. '<GtkLauncher>/Smalltalk/DebugIt'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkLauncher>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkLauncher>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkLauncher>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' accelPath: '<GtkLauncher>/Smalltalk/DebugIt' connectTo: self selector: #debugIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Accept It' accelPath: '<GtkLauncher>/Smalltalk/AcceptIt' connectTo: self selector: #acceptIt}
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
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-apply' label: 'Accept')
                                connectSignal: 'clicked' to: self selector: #acceptIt userData: nil;
                                setTooltipText: 'Accept';
                                yourself)
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

	^ (imageWidget := GtkImageWidget new)
				    initialize;
				    whenSelectionChangedSend: #finderSelected to: self;
				    mainWidget
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
			parentWindow: window;
                        initialize;
                        mainWidget);
            yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

	self selector isNil ifFalse: [ ^ self buildSenderAndClassBrowser ].
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
    ]

    postInitialize [
        <category: 'initialization'>

        imageWidget grabFocus.
        window
            connectSignal: 'delete-event' to: self selector: #'delete:event:' userData: nil
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

	| to |	
	senderResults := Dictionary new.
	(self literalsAndSpecialSelectors at: anObject displaySymbol ifAbsent: [ #() ] ) do: [ :each |
	    self senderModel appendItem: {each displayString}.
	    senderResults at: each displayString put: each ].
    ]

    literalsAndSpecialSelectors [
	<category: 'accessing'>

	^ self class literalsAndSpecialSelectors
    ]

    finderSelected [
	<category: 'finder events'>

	self selector: imageWidget selection asSymbol.
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

    back [
        <category: 'history events'>

        classBrowserWidget back
    ]

    forward [
        <category: 'history events'>

        classBrowserWidget forward
    ]

    cancel [
        <category: 'edit events'>

         classBrowserWidget cancel
    ]

    undo [
        <category: 'edit events'>

        classBrowserWidget undo
    ]

    redo [
        <category: 'edit events'>

        classBrowserWidget redo
    ]

    cut [
        <category: 'edit events'>

        classBrowserWidget cut
    ]

    copy [
        <category: 'edit events'>

        classBrowserWidget copy
    ]

    paste [
        <category: 'edit events'>

        classBrowserWidget paste
    ]

    selectAll [
        <category: 'edit events'>

        classBrowserWidget selectAll
    ]

    doIt [
        <category: 'smalltalk events'>

        classBrowserWidget doIt
    ]

    printIt [
        <category: 'smalltalk events'>

        classBrowserWidget printIt
    ]

    inspectIt [
        <category: 'smalltalk events'>

        classBrowserWidget inspectIt
    ]

    debugIt [
        <category: 'smalltalk events'>

        classBrowserWidget debugIt
    ]

    acceptIt [
        <category: 'smalltalk events'>

        classBrowserWidget acceptIt
    ]

    close [
        <category: 'file events'>

        classBrowserWidget hasChanged ifFalse: [ ^ super close ].
        classBrowserWidget doNotCheckCode.
        self saveCodeOnClose: [ super close ] onSave: [ classBrowserWidget saveCode. super close ]
    ]

    delete: aGtkWidget event: aGdkEvent [
        <category: 'window events'>

        classBrowserWidget hasChanged ifFalse: [ ^ window hideAll ].
        self saveCodeOnClose: [ window hideAll ] onSave: [ classBrowserWidget saveCode. window hideAll ].
        ^ true
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
                                tip: 'If you do not save, your changes to %1 will be lost...' % {classBrowserWidget stateString}.

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

