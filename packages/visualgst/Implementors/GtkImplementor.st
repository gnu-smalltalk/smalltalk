GtkMainWindow subclass: GtkImplementor [
    | imageWidget selector resultModel set resultArray resultTree classBrowserWidget |

    
    GtkImplementor class >> open [
        <category: 'instance creation'>

	^ super open
	    resize: 1024@600;
	    yourself
    ]

    GtkImplementor class >> openOn: aSelector [
        <category: 'instance creation'>

        ^ (self new)
            selector: aSelector;
            initialize;
	    resize: 1024@600;
            showAll;
            yourself
    ]

    createFileMenus [
        <category: 'user interface'>

	self accelGroup append: {{'<Control>O'. '<GtkImplementor>/File/Open'}.
            {'<Control><Shift>S'. '<GtkImplementor>/File/SaveAs'}.
            {'<Control>Q'. '<GtkImplementor>/File/Close'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkImplementor>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkImplementor>/File/SaveAs' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #print.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkImplementor>/File/Close' connectTo: self selector: #close}
    ]

    createEditMenus [
	<category: 'user interface'>

	self accelGroup append: {{'<Control><shift>Z'. '<GtkImplementor>/Edit/Cancel'}.
            {'<Control>Z'. '<GtkImplementor>/Edit/Undo'}.
            {'<Control>R'. '<GtkImplementor>/Edit/Redo'}.
            {'<Control>X'. '<GtkImplementor>/Edit/Cut'}.
            {'<Control>C'. '<GtkImplementor>/Edit/Copy'}.
            {'<Control>V'. '<GtkImplementor>/Edit/Paste'}.
            {'<Control>A'. '<GtkImplementor>/Edit/SelectAll'}}.

	^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Cancel edits' accelPath: '<GtkImplementor>/Edit/Cancel' connectTo: self selector: #cancel.
            GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkImplementor>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkImplementor>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkImplementor>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkImplementor>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkImplementor>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkImplementor>/Edit/SelectAll' connectTo: self selector: #selectAll}
    ]

    createHistoryMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Alt>Left'. '<GtkLauncher>/History/Back'}.
            {'<Alt>Right'. '<GtkLauncher>/History/Forward'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'back' accelPath: '<GtkLauncher>/History/Back' connectTo: self selector: #back.
            GTK.GtkMenuItem menuItem: 'Forward' accelPath: '<GtkLauncher>/History/Forward' connectTo: self selector: #forward}
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

    createHelpMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About Smalltalk Implementor' connectTo: self selector: #aboutImplementor.
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

        self statusMessage: 'Gtk Smalltalk Implementor'
    ]

    createToolbar [
    <category: 'user interface'>

    self
        "appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-new')
		connectSignal: 'clicked' to: OpenWorkspaceCommand selector: #execute userData: nil;
		setTooltipText: 'Create a new workspace';
		yourself);"
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

    resultModel [
        <category: 'model accessing'>

        ^ resultModel ifNil: [
            resultModel := GTK.GtkTreeStore new: 1 varargs: {GTK.GValue gTypeString} ]
    ]

    buildFinderList [
	<category: 'user interface'>

	^ (imageWidget := GtkImageWidget new)
				    initialize;
				    whenSelectionChangedSend: #elementSelected to: self;
				    mainWidget
    ]

    buildResultList [
        <category: 'user interface'>

	resultTree := GTK.GtkTreeView newWithSortedTextColumn: self resultModel title: 'Methods and Classes'.
	(resultTree getColumn: 0) signalEmitByName: 'clicked' args: {}.
        resultTree
            getSelection
                connectSignal: 'changed' to: self selector: #resultSelected userData: nil.
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    buildResultAndClassBrowser [
	<category: 'user interface'>

        ^ GTK.GtkVPaned new
            add1: self buildResultList;
            add2: ((classBrowserWidget := GtkClassBrowserWidget new)
			parentWindow: window;
                        initialize;
                        mainWidget);
            yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

	self selector isNil ifFalse: [ ^self buildResultAndClassBrowser ].
	^ (GTK.GtkHPaned new)
	    add1: self buildFinderList;
	    add2: self buildResultAndClassBrowser;
	    yourself
    ]

    initialize [
        <category: 'initialization'>

        super initialize.
        self
            title: 'GNU Smalltalk Implementor';
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

    aboutImplementor [
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
            setProgramName: 'GNU Smalltalk Implementor';
            run
    ]

    elementSelected [
	<category: 'events'>

        self selector: imageWidget selection
    ]

    resultSelected [
	<category: 'events'>

	| selectedIter selectedString |
	(selectedIter := resultTree selectedIter) ifNil: [ ^ self ].
	selectedString := (self resultModel getOop: selectedIter column: 0).

	(resultArray at: selectedString) updateBrowser: classBrowserWidget.
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

    back [
        <category: 'history events'>

        classBrowserWidget back
    ]

    forward [
        <category: 'history events'>

        classBrowserWidget forward
    ]

    selector [
	<category: 'accessing'>

	^selector
    ]

    selector: aSymbol [
	<category: 'accessing'>

	| iter |
	selector := aSymbol.
	self resultModel clear. 
	resultArray := imageWidget model matchSelector: aSymbol.
	resultArray keysDo: [ :each |
	    iter := GTK.GtkTreeIter new.
	    self resultModel append: iter parent: nil.
	    self resultModel setOop: iter column: 0 value: each ].
	"resultTree getSelection selectPath: GTK.GtkTreePath newFirst"
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

