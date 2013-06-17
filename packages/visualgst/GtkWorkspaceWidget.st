"======================================================================
|
| GtkWorskpaceWidget class definition
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

GtkTextWidget subclass: GtkWorkspaceWidget [

    | variableWidget variableTracker object |
    
    initialize [
	<category: 'intialization'>

	variableTracker := (WorkspaceVariableTracker new)
				initialize;
				yourself.
	object := variableTracker objectClass new.
	super initialize.
	self connectToWhenPopupMenu: (WorkspaceMenus on: self)
    ]

    postInitialize [
        <category: 'initialize'>

	variableWidget hideAll.
	super postInitialize
    ]

    buildWidget [
        <category: 'user interface'>

        ^ (GTK.GtkHPaned new)
		    add1: (variableWidget := GtkVariableTrackerWidget on: object) mainWidget;
		    add2: super buildWidget;
                    yourself
    ]

    object: anObject [
	<category: 'evaluation'>

        variableTracker := nil.
        object := anObject.
    ]

    targetObject [
	<category: 'evaluation'>

        ^ object
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>

	| text nodes |
        variableTracker isNil ifTrue: [^self].
	text := self selectedText.
	nodes := STInST.RBParser parseExpression: text onError: [ :s :p | self error: s ].
	variableTracker visitNode: nodes
    ]

    afterEvaluation [
        <category: 'smalltalk event'>

	variableWidget refresh
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    showIVar [
	<category: 'smalltalk event'>

	variableWidget mainWidget getVisible 
		ifFalse: [ variableWidget showAll ]
		ifTrue: [ variableWidget hideAll ].
    ]
]
