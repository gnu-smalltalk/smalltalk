GtkMainWindow subclass: GtkAssistant [
    | workspaceNb notebook browserWindows workspaceWindows windowsMenu |

    GtkAssistant class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    aboutBrowser [
	<category: 'help events'>

	(GTK.GtkAboutDialog new)
	    setVersion: '0.2.0';
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
	    setWebsite: 'http://le site du gnu';
	    setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
	    "setAuthors: {'Gwenael Casaccio'. 'Nicolas Petton'};"
	    setProgramName: 'GNU Smalltalk Launcher';
	    showModalDestroy
    ]

    initialize [
	<category: 'initialization'>

	super initialize.
	workspaceNb := 0.
	browserWindows := OrderedCollection new.
	workspaceWindows := OrderedCollection new.
	self
	    title: 'GNU Smalltalk Assistant';
	    createMenus;
	    createToolbar;
	    createStatusBar;
	    centralWidget: self buildCentralWidget
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

        | webview |

        webview := GtkWebView new
                        openUrl: 'http://library.gnome.org/devel/gtk/stable/index.html';
                        showAll;
                        yourself.

	^ (GTK.GtkScrolledWindow withChild: webview)
	    showAll; 
	    yourself
    ]

    createEditMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>Z'. '<GtkLauncher>/Edit/Undo'}.
            {'<Control>R'. '<GtkLauncher>/Edit/Redo'}.
            {'<Control>X'. '<GtkLauncher>/Edit/Cut'}.
            {'<Control>C'. '<GtkLauncher>/Edit/Copy'}.
            {'<Control>V'. '<GtkLauncher>/Edit/Paste'}.
            {'<Control>A'. '<GtkLauncher>/Edit/SelectAll'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Undo' accelPath: '<GtkLauncher>/Edit/Undo' connectTo: self selector: #undo.
            GTK.GtkMenuItem menuItem: 'Redo' accelPath: '<GtkLauncher>/Edit/Redo' connectTo: self selector: #redo.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Cut' accelPath: '<GtkLauncher>/Edit/Cut' connectTo: self selector: #cut.
            GTK.GtkMenuItem menuItem: 'Copy' accelPath: '<GtkLauncher>/Edit/Copy' connectTo: self selector: #copy.
            GTK.GtkMenuItem menuItem: 'Paste' accelPath: '<GtkLauncher>/Edit/Paste' connectTo: self selector: #paste.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Select all' accelPath: '<GtkLauncher>/Edit/SelectAll' connectTo: self selector: #selectAll.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Clear Transcript' connectTo: self selector: #clearTranscriptWidget}
    ]

    createFileMenus [
        <category: 'user interface'>

        self accelGroup append:
            {{'<Control>O'. '<GtkLauncher>/File/Open'}.
            {'<Control>S'. '<GtkLauncher>/File/Save'}.
            {'<Control><Shift>S'. '<GtkLauncher>/File/SaveAs'}.
            {'<Control>Q'. '<GtkAssistant>/File/Close'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkLauncher>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' accelPath: '<GtkLauncher>/File/Save' connectTo: self selector: #save.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkLauncher>/File/SaveAs' connectTo: self selector: #saveAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Print' connectTo: self selector: #printIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkAssistant>/File/Close' connectTo: self selector: #close}
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

        self accelGroup append: {{'<Control>D'. '<GtkLauncher>/Smalltalk/DoIt'}.
            {'<Control>P'. '<GtkLauncher>/Smalltalk/PrintIt'}.
            {'<Control>I'. '<GtkLauncher>/Smalltalk/InspectIt'}.
            {'<Control>M'. '<GtkLauncher>/Smalltalk/Implementors'}.
            {'<Control>N'. '<GtkLauncher>/Smalltalk/Senders'}}.

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'Do It' accelPath: '<GtkLauncher>/Smalltalk/DoIt' connectTo: self selector: #doIt.
            GTK.GtkMenuItem menuItem: 'Print It' accelPath: '<GtkLauncher>/Smalltalk/PrintIt' connectTo: self selector: #printIt.
            GTK.GtkMenuItem menuItem: 'Inspect It' accelPath: '<GtkLauncher>/Smalltalk/InspectIt' connectTo: self selector: #inspectIt.
            GTK.GtkMenuItem menuItem: 'Debug It' connectTo: self selector: #debugIt.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Implementors' accelPath: '<GtkLauncher>/Smalltalk/Implementors' connectTo: self selector: #implementors.
            GTK.GtkMenuItem menuItem: 'Senders' accelPath: '<GtkLauncher>/Smalltalk/Senders' connectTo: self selector: #senders}
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^ self createNewMenuEntry: {GTK.GtkMenuItem menuItem: 'About Assistant' connectTo: self selector: #aboutAssistant.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createToolsMenus [
        <category: 'user interface'>
        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/ClassBrowser'}}.

        ^ self createNewMenuEntry:  {GTK.GtkMenuItem menuItem: 'Browser' connectTo: self selector: #classBrowser.
            GTK.GtkMenuItem menuItem: 'Browser window' accelPath: '<GtkLauncher>/Tools/ClassBrowser' connectTo: self selector: #classBrowserInAWindow.
            GTK.GtkMenuItem menuItem: 'Workspace' connectTo: self selector: #workspace.
            GTK.GtkMenuItem menuItem: 'Inspector' connectTo: self selector: #gtkInspector.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Assistant' connectTo: self selector: #gtkAssistant.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'smallZilla' connectTo: self selector: #webBrowser}
    ]

    createMenus [
	<category: 'user interface'>

	self createMainMenu: {#('File' #createFileMenus).
            #('Edit' #createEditMenus).
            #('Smalltalk' #createSmalltalkMenus).
            #('Tools' #createToolsMenus).
            #('Help' #createHelpMenus)}
    ]

    createStatusBar [
	<category: 'user interface'>

	self statusMessage: 'Gtk Launcher'
    ]

    createToolbar [
	<category: 'user interface'>

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
	    appendToolItem: (GTK.GtkToolButton newFromStock: 'gtk-execute' label: 'Do it')
    ]

    cut [
	<category: 'edit events'>
    ]

    copy [
	<category: 'edit events'>
    ]

    paste [
	<category: 'edit events'>
    ]

    selectAll [
	<category: 'edit events'>
    ]

    searchClassOrMethod [
	<category: 'edit events'>

	GtkFinder open
    ]
]

