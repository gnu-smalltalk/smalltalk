GtkMainWindow subclass: GtkVisualGSTTool [
    <comment: 'I am the base for various tools of VisualGST.'>

    GtkVisualGSTTool class >> version [
        <category: 'accessing'>

        ^ '0.8.0'
    ]

    GtkVisualGSTTool class >> website [
        <category: 'accessing'>

        ^ 'http://github.com/MrGwen/gst-visualgst'
    ]

    GtkVisualGSTTool class >> gstWebsite [
        <category: 'accessing'>

        ^ 'http://smalltalk.gnu.org/'
    ]

    GtkVisualGSTTool class >> license [
        <category: 'accessing'>

        ^
'Permission is hereby granted, free of charge, to any person obtaining
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
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
    ]

    aboutTitle [
        <category: 'widget-skeleton'>
        <comment: 'I return the visible name for the Help->About entry'>
        ^'About VisualGST...'
    ]

    showAboutDialog [
        (GTK.GtkAboutDialog new)
            setVersion: VisualGST.GtkVisualGSTTool version;
            setLicense: VisualGST.GtkVisualGSTTool license;
            setWebsite: VisualGST.GtkVisualGSTTool website;
            setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
            setProgramName: 'VisualGST'; 
            showModalDestroy
    ] 

    createFileMenus [
        <category: 'user interface'>

        | menu |
        self accelGroup append:
            {{'<Control>W'. '<GtkVisualGSTTool>/File/Close'}.
             {'<Control>Q'. '<GtkVisualGSTTool>/File/Quit'}}.

        menu := OrderedCollection withAll: {
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new}.
            menu add: (GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkVisualGSTTool>/File/Close' connectTo: self selector: #closeTab).
        menu add: (GTK.GtkMenuItem menuItem: 'Quit' accelPath: '<GtkVisualGSTTool>/File/Quit' connectTo: self selector: #quit).
        ^menu
    ]

    exitOnClose [
        <category: 'file events'>

        ^ self == GtkLauncher uniqueInstance
    ]

    quit [
        <category: 'file events'>

        GtkLauncher uniqueInstance quit
    ]

    createEditMenus [
        <category: 'user interface'>

	^ EditMenus browserBuildOn: self
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

	^ SmalltalkMenus browserBuildOn: self
    ]

    createToolsMenus [
        <category: 'user interface'>

	^ ToolsMenus browserBuildOn: self
    ]

    state [
	<category: 'tools events'>

	^BrowserState new
    ]

    selectedText [
        <category: 'tools events'>

        "Since #hasSelection returns false, this will never be called."
        self shouldNotImplement
    ]

    selectedMethodSymbol [
        <category: 'tools events'>

        ^STInST.RBParser selectedSymbol: self selectedText
    ]

    hasSelection [
	<category: 'tools events'>

	^false
    ]

    sourceCodeWidgetHasFocus [
	<category: 'tools events'>

	^false
    ]

    browserHasFocus [
	<category: 'tools events'>

	^false
    ]

    launcher [
	<category: 'tools events'>

	^nil
    ]

    newSUnitBrowser [
	<category: 'tools events'>

	OpenSUnitCommand executeOn: self
    ]

    newSenderBrowser [
	<category: 'tools events'>

	OpenSenderCommand executeOn: self
    ]

    newImplementorBrowser [
	<category: 'tools events'>

	OpenImplementorCommand executeOn: self
    ]

    packageBuilder [
        <category: 'tools events'>

        OpenPackageBuilderCommand executeOn: self
    ]

    helpContents [
	<category: 'help events'>

	GtkWebBrowser openOn: 'http://smalltalk.gnu.org/documentation'
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Help Contents' connectTo: self selector: #helpContents.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: self aboutTitle connectTo: self selector: #showAboutDialog.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]

    createToolbar [
        <category: 'user interface'>

        self
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-save')
                                connectSignal: 'clicked' to: SaveImageCommand selector: #execute;
                                setTooltipText: 'Save the image';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-cut')
                                connectSignal: 'clicked' to: self selector: #cut;
                                setTooltipText: 'Cut';
                               yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-copy')
                                connectSignal: 'clicked' to: self selector: #copy;
                                setTooltipText: 'Copy';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-paste')
                                connectSignal: 'clicked' to: self selector: #paste;
                                setTooltipText: 'Paste';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-undo')
                                connectSignal: 'clicked' to: self selector: #undo;
                                setTooltipText: 'Undo';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-redo')
                                connectSignal: 'clicked' to: self selector: #redo;
                                setTooltipText: 'Redo';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-execute' label: 'Do It')
                                connectSignal: 'clicked' to: self selector: #doIt;
                                setTooltipText: 'Do It';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-print' label: 'Print It')
                                connectSignal: 'clicked' to: self selector: #printIt;
                                setTooltipText: 'Print It';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-convert' label: 'Inspect It')
                                connectSignal: 'clicked' to: self selector: #inspectIt;
                                setTooltipText: 'Inspect It';
                                yourself);
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-sort-descending' label: 'Debug It')
                                connectSignal: 'clicked' to: self selector: #debugIt;
                                setTooltipText: 'Debug It';
                                yourself);
            appendSeparator;
            appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-apply' label: 'Accept')
                                connectSignal: 'clicked' to: self selector: #acceptIt;
                                setTooltipText: 'Accept';
                                yourself)
    ]

]

