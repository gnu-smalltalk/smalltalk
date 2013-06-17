"======================================================================
|
| GtkNotebookWidget class definition
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

GtkConcreteWidget subclass: GtkNotebookWidget [
    | currentWidget selectMessage notebook pages labels |

    initialize [
	<category: 'initialization'>

	labels := OrderedCollection new.
	pages := OrderedCollection new.
	self mainWidget: self buildNotebookWidget
    ]

    buildNotebookWidget [
	<category: 'user interface'>

        ^ notebook := GTK.GtkNotebook new
			    connectSignal: 'switch-page'
			    to: self
			    selector: #'switchPageOn:page:number:'
			    userData: nil;
			    setShowTabs: false;
			    yourself
    ]

    whenSelectionChangedSend: aSymbol to: anObject [
        selectMessage := DirectedMessage receiver: anObject selector: aSymbol arguments: #()
    ]

    addWidget: aWidget labeled: aString [
	<category: 'user interface'>

	self addWidget: aWidget labelWidget: (self buildLabelWidget: aString withIcon: GTK.Gtk gtkStockClose at: aWidget)
    ]


    updateWidget: aWidget withLabel: aString [
	<category: 'user interface'>

	notebook setTabLabel: aWidget mainWidget tabLabel: (self buildLabelWidget: aString withIcon: GTK.Gtk gtkStockClose at: aWidget)
    ]

    addPermanentWidget: aWidget labeled: aString [
        <category: 'user interface'>

	self addWidget: aWidget labelWidget: (labels add: (GTK.GtkLabel new: aString))
    ]

    addWidget: aWidget labelWidget: aLabelWidget [
	<category: 'user interface'>

	currentWidget ifNil: [ currentWidget := aWidget ].
        pages addLast: aWidget.
        notebook
            appendPage: aWidget mainWidget tabLabel: aLabelWidget.
        pages size > 1 ifTrue: [ notebook setShowTabs: true ]
    ]

    buildLabelWidget: aString withIcon: aStockString at: aSmallInteger [
        <category: 'user interface'>

        | image close |
        image := GTK.GtkImage newFromStock: aStockString size: GTK.Gtk gtkIconSizeMenu.
        close := (GTK.GtkButton new)
                    setImage: image;
                    setRelief: GTK.Gtk gtkReliefNone;
                    connectSignal: 'pressed' to: self selector: #'closeIt:at:' userData: aSmallInteger;
                    yourself.
        ^ (GTK.GtkHBox new: false spacing: 0)
            add: (labels add: (GTK.GtkLabel new: aString));
            add: close;
            showAll;
            yourself
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
        <category: 'notebook events'>

        currentWidget := pages at: anInteger + 1.
        selectMessage ifNotNil: [ selectMessage send ]
    ]

    closeIt: aGtkButton  at: aGtkConcreteWidget [
        <category: 'notebook events'>

        | pageNb |
        pageNb := notebook pageNum: aGtkConcreteWidget mainWidget.
	aGtkConcreteWidget close.
        pages removeAtIndex: pageNb + 1.
	labels removeAtIndex: pageNb + 1.
        notebook removePage: pageNb.
	pages size = 1 ifTrue: [ notebook setShowTabs: false ]
    ]

    widgetAt: anInteger [
	<category: 'accessing'>

	^ pages at: anInteger
    ]

    currentWidget [
	<category: 'accessing'>

	^ currentWidget
    ]

    focusedWidget [
	<category: 'accessing'>

	^ currentWidget focusedWidget
    ]

    currentPage [
	<category: 'pages'>

	^ notebook getCurrentPage
    ]

    currentPage: aSmallInteger [
	<category: 'pages'>

	notebook setCurrentPage: aSmallInteger
    ]

    showLastPage [
	<category: 'pages'>

	self currentPage: self numberOfPages - 1
    ]

    numberOfPages [
	<category: 'pages'>

	^ notebook getNPages
    ]

    closeCurrentPage [
	<category: 'pages'>

	self numberOfPages = 1 ifTrue: [ ^ self ].
        pages removeAtIndex: self currentPage + 1.
	labels removeAtIndex: self currentPage + 1.
	notebook removePage: self currentPage.
	pages size = 1 ifTrue: [ notebook setShowTabs: false ]
    ]

    showPane [
	<category: 'widget'>

	notebook showAll.
	pages do: [ :each | each postInitialize ]
    ]
]

