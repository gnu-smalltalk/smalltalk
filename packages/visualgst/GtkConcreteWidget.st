"======================================================================
|
| GtkConcreteWidget class definition
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

Object subclass: GtkConcreteWidget [
    | child parentWindow popupMenu |

    GtkConcreteWidget class >> parentWindow: aGtkWindow [
	<category: 'instance creation'>

        ^ self new
            parentWindow: aGtkWindow;
            initialize;
            yourself
    ]

    GtkConcreteWidget class >> showAll [
	<category: 'instance creation'>

	^ self new
	    initialize;
	    showAll;
	    yourself
    ]

    initialize [
	<category: 'initialize'>

    ]

    parentWindow: aGtkWindow [
        <category: 'accessing'>

        parentWindow := aGtkWindow
    ]
    
    parentWindow [
	<category: 'accessing'>

	^ parentWindow
    ]

    mainWidget [
	<category: 'accessing'>

	^ child
    ]

    mainWidget: aGtkWidget [
	<category: 'accessing'>

	child ifNotNil: [ child hideAll  ].
	child := aGtkWidget
    ]

    showAll [
	<category: 'user interface'>

	child showAll
    ]

    hideAll [
	<category: 'user interface'>

	child hideAll
    ]

    isVisible [
	<category: 'testing'>

	^ child getVisible
    ]

    hasFocus [
	<category: 'testing'>

        | parent current |
        parent := child.
        [ (current := parent getFocusChild) notNil ] whileTrue: [
            parent := current ].
        ^ self parentWindow getFocus = parent

    ]

    focusedWidget [
	<category: 'focus'>

        self hasFocus ifTrue: [ ^ self ].
        ^ nil
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        ^ self focusedWidget perform: aSymbol
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := popupMenu asPopupMenu.
        menu attachToWidget: self treeView detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    connectToWhenPopupMenu: aMenuBuilder [
	<category: 'user interface'>

	popupMenu := aMenuBuilder.
	^ self treeView connectSignal: 'button-press-event' to: self selector: #'onPress:event:'
    ]

    grabFocus [
	<category: 'user interface'>

    ]

    close [
	<category: 'user interface'>
    ]
]
