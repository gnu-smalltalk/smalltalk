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
	    setVersion: (Smalltalk version =~ 'version (.*)' at: 1);
	    setLicense: 'GNU Smalltalk is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later version.

GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  

Please consult the GNU Smalltalk source code for additional permissions
that are specific to this version of GNU Smalltalk.';
	    setWebsite: 'http://smalltalk.gnu.org/';
	    showModalDestroy
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
