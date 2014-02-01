"======================================================================
|
| GtkSUnitResult class definition
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

GtkConcreteWidget subclass: GtkSUnitResult [
    | model resultTree results |
    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    buildTreeView [
        <category: 'user interface'>

        resultTree := (GTK.GtkTreeView newWithTextColumn: self model title: 'Results')
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    model [
        <category: 'model'>

        ^ model ifNil: [
            model := GTK.GtkTreeStore new: 2 varargs: {GTK.GValue gTypeString. GLib.GType oopType} ]
    ]

    clearModel [
	<category: 'model'>

	self model clear
    ]

    results: aSet [
	<category: 'accessing'>

	self clearModel.
	results := aSet.
	results do: [ :each |
	    self model appendItem: {each displayString. each} ]
    ]

    popupMenuOn: aGtkWidget menu: aGtkMenu [
	<category: 'events'>
	| menuitem symbol |

        symbol := self selectedMethodSymbol.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Run test'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #debugTest userData: nil.
        aGtkMenu append: menuitem.
	"TODO: show test"
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Browse implementors'.
        menuitem
            setSensitive: symbol notNil;
            show;
            connectSignal: 'activate' to: self selector: #browseImplementors userData: nil.
        aGtkMenu append: menuitem.
    ]

    onPress: aGtkWidget event: aGdkEvent [
	<category: 'events'>
	| aGdkButtonEvent menu |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
	self popupMenuOn: aGtkWidget menu: menu.
        menu attachToWidget: resultTree detacher: nil.
        menu showAll.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        ^ true
    ]

    debugTest [
	<category: 'event'>
	
        DebugTestCommand executeOn: self
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ resultTree hasSelectedItem
    ]

    state [
        <category: 'state'>
        resultTree hasSelectedItem ifTrue: [
            ^MethodState on: self selectedResult with: (self selectedResult class lookupSelector: self selectedResult selector) ].
        ^BrowserState new
    ]
	
    selectedMethodSymbol [
        <category: 'accessing'>

        ^ self selectedResult ifNotNil: [ :result | result selector ]
    ]

    selectedMethod [
        <category: 'accessing'>

        self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
        ^ self class compiledMethodAt: self selectedMethodSymbol
    ]

    selectedResult [
        <category: 'accessing'>

	| iter |
        (iter := resultTree selectedIter) ifNil: [ self error: 'Nothing is selected' ].
        ^ self model getOop: iter column: 1
    ]

    browseImplementors [
        OpenImplementorCommand executeOn: self
    ]
]

