"======================================================================
|
| HistoryStack class definition
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

Object subclass: HistoryStack [

    | previousStack nextStack browser |

    initialize: aGtkClassBrowserWidget [
	<category: 'initialization'>

	previousStack := OrderedCollection new.
	nextStack := OrderedCollection new.
	browser := aGtkClassBrowserWidget.
    ]

    clear [
	<category: 'stack'>

        previousStack empty.
        nextStack empty.
    ]

    current [
	<category: 'stack'>
        ^previousStack isEmpty ifTrue: [ nil ] ifFalse: [ previousStack first ]
    ]

    push: aClass [
	<category: 'stack'>

	(aClass isNil or: [self current == aClass]) ifTrue: [ ^ self ].
	nextStack empty.
	previousStack addFirst: aClass
    ]

    size [
        <category: 'iteration'>

        ^nextStack size + previousStack size
    ]

    do: aBlock [
        <category: 'iteration'>

        nextStack reverseDo: aBlock.
        previousStack do: aBlock.
    ]

    selectedIndex [
	<category: 'undo-redo'>

        ^nextStack size + 1
    ]

    selectItem: anInteger [
	<category: 'undo-redo'>

        | n |
        (anInteger between: 1 and: self size)
            ifFalse: [self error: 'index out of range'].

        [ self selectedIndex < anInteger ] whileTrue: [
            nextStack addFirst: previousStack removeFirst ].
        [ self selectedIndex > anInteger ] whileTrue: [
            previousStack addFirst: nextStack removeFirst ].

        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]

    previous [
	<category: 'undo-redo'>

	previousStack size <= 1 ifTrue: [ ^ self ].

	nextStack addFirst: previousStack removeFirst.
        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]

    next [
        <category: 'undo-redo'>

	nextStack isEmpty ifTrue: [ ^ self ].

	previousStack addFirst: nextStack removeFirst.
        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]
]

