"======================================================================
|
| GtkClassSUnitWidget class definition
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

GtkCategorizedClassWidget subclass: GtkClassSUnitWidget [

    addToModel: aClass [

        (aClass superclass environment == self namespace and: [ (aClass superclass category = self category or: [ self category isEmpty ]) and: [ aClass superclass ~~ Smalltalk.TestCase ] ]) 
                    ifFalse: [ model append: aClass class ]
                    ifTrue: [ model append: aClass class parent: aClass superclass class ]
    ]

    root [
	<category: 'accessing'>

        ^ Smalltalk.TestCase
    ]

    selectionMode [
        <category: 'accessing'>

        ^ GTK.Gtk gtkSelectionMultiple
    ]

    allClassNames [
        <category: 'accessing'>

	| classes names |
	classes := self selectedClasses.
	names := classes collect: [ :each | each name asString ].
	^ names fold: [ :a :b | a, ', ', b ]
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ (classesTree treeView getSelection getSelectedRows: nil) ~= nil
    ]

    selectedClass [
        <category: 'accessing'>

	^ self selectedClasses first
    ]

    selectedClasses [
        <category: 'accessing'>

	self hasSelectedClass ifFalse: [ self error: 'Nothing is selected' ].
	^ classesTree treeView selections collect: [:each| each asClass]
    ]

    recategorizedEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super recategorizedEvent: anEvent
    ]

    addEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super addEvent: anEvent
    ]
]

