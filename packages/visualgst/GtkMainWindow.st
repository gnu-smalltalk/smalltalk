Smalltalk.Object subclass: GtkMainWindow [
    | window container menuBar toolBar centralWidget statusBar accelGroup |

    GtkMainWindow class >> open	[
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    showAll;
	    postInitialize;
	    yourself
    ]

    GtkMainWindow class >> openSized: aPoint [
	<category: 'user interface'>
	
	^ (self new)
	    initialize;
	    resize: aPoint;
	    showAll;
	    postInitialize;
	    yourself
    ]

    centralWidget [
	<category: 'accessing'>

	^ centralWidget
    ]

    centralWidget: aGtkWidget [
	<category: 'accessing'>

	centralWidget := aGtkWidget
    ]

    container [
	<category: 'accessing'>

	^ container ifNil: [ container := GTK.GtkVBox new: false spacing: 0 ]
    ]

    accelGroup [
	<category: 'accessing'>

	^ accelGroup ifNil: [ accelGroup := GTK.GtkAccelGroup new ]
    ]

    menuBar [
	<category: 'accessing'>

	^ menuBar ifNil: [ menuBar := GTK.GtkMenuBar new ]
    ]

    menuBar: aGtkMenuBar [
	<category: 'accessing'>

	menuBar := aGtkMenuBar
    ]

    statusBar [
	<category: 'accessing'>

	^ statusBar ifNil: [ statusBar := GTK.GtkStatusbar new ] 
    ]

    statusBar: aGtkStatusBar [
	<category: 'accessing'>

	statusBar := aGtkStatusBar
    ]

    title [
	<category: 'accessing'>

	^ window title
    ]

    title: aString [
	<category: 'accessing'>

	window setTitle: aString
    ]

    toolBar [
	<category: 'accessing'>

	^ toolBar ifNil: [ toolBar := GTK.GtkToolbar new ]
    ]

    toolBar: aGtkToolBar [
	<category: 'accessing'>

	toolBar := aGtkToolBar
    ]

    aboutGst [
	<category: 'events'>

	(GTK.GtkAboutDialog new)
	    setProgramName: 'GNU Smalltalk';
	    setVersion: '3.1';
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
	    setWebsite: 'http://smalltalk.gnu.org/';
	    runBlockingAndDestroy
    ]

    close [
	<category: 'events'>

	window hideAll
    ]

    initialize [
	<category: 'intialization'>
	
	window := GTK.GtkWindow	new: GTK.Gtk gtkWindowToplevel.
	window addAccelGroup: self accelGroup
    ]

    postInitialize [
	<category: 'initialization'>
    ]

    addMenuItem: aString [
	<category: 'menubar'>

	self menuBar append: (GTK.GtkMenuItem newWithLabel: aString)
    ]

    addMenuItem: aString withSubmenu: aGtkMenu [
	<category: 'menubar'>

	self menuBar append:
	    ((GTK.GtkMenuItem newWithLabel: aString)
		setSubmenu: aGtkMenu)
    ]

    createMainMenu: anArray [
	<category: 'menubar'>

	anArray do: [ :each |
	    self addMenuItem: each first withSubmenu: (self perform: each second) ]
    ]

    createMenuEntry: anArray [
	<category: 'menubar'>

	| menu |
	menu := (GTK.GtkMenu new)
		    setAccelGroup: self accelGroup;
		    yourself.
	anArray do: [ :each |
	    menu append: 
		(each isEmpty
		    ifTrue: [ GTK.GtkMenuItem new ]
		    ifFalse: [ (GTK.GtkMenuItem newWithLabel: (each at: 1))
			    connectSignal: 'activate' to: self selector: (each at: 2) userData: nil;
			    setAccelPath: (each at: 3);
			    yourself ]) ].

	^ menu
    ]

    createNewMenuEntry: anArray [
        <category: 'menubar'>

        | menu |
        menu := (GTK.GtkMenu new)
                    setAccelGroup: self accelGroup;
                    yourself.
        anArray do: [ :each |
            menu append: each ].
        ^ menu
    ]

    statusMessage: aString [
	<category: 'statusbar'>

	self statusBar
	    push: 0 text: aString
    ]

    appendSeparator [
	<category: 'toolbar'>

	self appendToolItem: GTK.GtkSeparatorToolItem new
    ]

    appendToolItem: aGtkToolItem [
	<category: 'toolbar'>

	self toolBar insert: aGtkToolItem pos: -1
    ]

    appendWidget: aGtkWidget [
	<category: 'toolbar'>

	self appendToolItem: ((GTK.GtkToolItem new) add: aGtkWidget)
    ]

    resize: aPoint [
	<category: 'user interface'>

	window resize: aPoint x height: aPoint y
    ]

    showAll [
	{menuBar->false. toolBar->false. centralWidget->true. statusBar->false} do: [ :each |
	    each key ifNotNil: [ self container 
		packStart: each key expand: each value fill: true padding: 0 ] ].

	window 
	    add: self container;
	    showAll
    ]
]
