"======================================================================
|
| GtkCategorizedClassWidgetTest class definition
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

TestCase subclass: GtkCategorizedClassWidgetTest [

    | changed |

    classChanged [

        changed := true
    ]

    testModelBuilding [
        <category: 'testing'>

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''
    ]

    testState [
        <category: 'testing'>

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: nil category: ''.
	self assert: class state namespace isNil.
	self assert: class state classOrMeta isNil.
	self assert: class state category isNil.
	self assert: class state method isNil.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''.
        self assert: class state namespace == Kernel.
        self assert: class state classCategory fullname = ''.
	self assert: class state classOrMeta isNil.
        self assert: class state category isNil.
        self assert: class state method isNil.
	class selectAClass: Kernel.CollectingStream class.
        self assert: class state namespace == Kernel.
        self assert: class state classCategory fullname = 'Examples-Useful tools'.
        self assert: class state classOrMeta == Kernel.CollectingStream.
        self assert: class state category isNil.
        self assert: class state method isNil
    ]

    testSelectionEvents [

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''.
        self assert: class hasSelectedClass not.
        self should: [ class selectedClass ] raise: Error.
	class selectAClass: Kernel.CollectingStream class.
        self assert: class hasSelectedClass.
        self assert: class selectedClass == Kernel.CollectingStream
    ]

    testConnectionEvents [

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: '';
            whenSelectionChangedSend: #classChanged to: self;
            selectAClass: Kernel.CollectingStream class.
        self assert: changed
    ]

    testNotification [
	<category: 'testing'>

        | widget notifier |
        widget := GtkCategorizedClassWidget new.
	widget
            mainWidget: widget buildTreeView;
            namespace: Smalltalk category: ''.

	notifier := SystemChangeNotifier new.
	notifier
            notify: widget ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: widget ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: widget ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:';
            notify: widget ofSystemChangesOfItem: #class change: #Modified using: #'modificationEvent:'.

	"Object subclass: #TestA.
	widget selectAClass: TestA"
    ]
]

