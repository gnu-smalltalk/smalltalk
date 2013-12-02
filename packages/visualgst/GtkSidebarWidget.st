"======================================================================
|
| GtkSidebarWidget class definition
|
======================================================================"

"======================================================================
|
| Copyright (c) 2013
| Gwenael Casaccio <gwenael.casaccio@gmail.com>,
|
|
| This file is part of VisualGST.
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the
| 'Software'), to deal in the Software without restriction, including
| without limitation the rights to use, copy, modify, merge, publish,
| distribute, sublicense, and/or sell copies of the Software, and to
| permit persons to whom the Software is furnished to do so, subject to
| the following conditions:
|
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|
======================================================================"

GtkConcreteWidget subclass: GtkSidebarWidget [
    | activeWidget widgets widgetEvents paned |

    initialize [
	<category: 'initialization'>

	paned := GTK.GtkNotebook new
				setTabPos: GTK.Gtk gtkPosBottom;
				connectSignal: 'switch-page' to: self selector: #'switchPageOn:page:number:';
				yourself.
	self mainWidget: paned.
	widgetEvents := Dictionary new.
	widgets := OrderedCollection new
    ]

    postInitialize [
	<category: 'initialization'>

	self hideAll
    ]

    add: aGtkWidget labeled: aString [
	<category: 'notebook'>

	paned
            appendPage: aGtkWidget tabLabel: (GTK.GtkLabel new: aString).
	widgets add: aGtkWidget
    ]

    addAll: anArray [
	<category: 'notebook'>

	anArray do: [ :each | self add: each key labeled: each value ]
    ]

    show: anIndex [
	<category: 'notebook'>

	activeWidget ifNotNil: [ :aWidget | aWidget hideAll ].
	self mainWidget showAll.
	self mainWidget setCurrentPage: anIndex - 1.
	activeWidget := (widgets at: anIndex)
					showAll;
					yourself
    ]

    showAll [
	<category: 'notebook'>

	self mainWidget show
    ]

    hideTabs [
	<category: 'notebook'>

	self mainWidget setShowTabs: false
    ]

    hide [
	<category: 'notebook'>

	self hideMainPained
    ]

    hideAll [
	<category: 'notebook'>

	self hideMainPained
    ]

    hideMainPained [
	<category: 'notebook'>

	self mainWidget hideAll
    ]

    panedOrientation [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
        <category: 'notebook events'>

	widgetEvents at: (aGtkNotebook getNthPage: anInteger) ifPresent: [ :msg | msg value ]
    ]

    whenWidgetIsVisible: aGtkWidget send: aSymbol to: anObject [
	<category: 'notebook events'>

	widgetEvents at: aGtkWidget put: (DirectedMessage receiver: anObject selector: aSymbol arguments: #())
    ]
]

