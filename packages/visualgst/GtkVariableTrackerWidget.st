"======================================================================
|
| GtkVariableTrackerWidget class definition
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

GtkConcreteWidget subclass: GtkVariableTrackerWidget [
    | model object widget |

    GtkVariableTrackerWidget class >> on: anObject [
	<category: 'instance creation'>

	^ self new
		initialize;
		object: anObject;
		yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildListView
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	self refresh
    ]

    buildListView [
	<category: 'user interface'>

        widget := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Variable'}. {GtkColumnTextType title: 'Value'}}.
        widget connectToWhenPopupMenu: (WorkspaceVariableMenus on: self).
        widget treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: widget treeView getModel)
                                        contentsBlock: [ :each | {each asString. (object instVarNamed: each) displayString} ].
        ^ widget mainWidget
    ]

    refresh [
	<category: 'user interface'>

	model
	    item: object class allInstVarNames;
	    refresh
    ]

    targetObject [
        <category: 'evaluation'>

        ^ object instVarNamed: self selectedValue
    ]

    hasSelectedValue [
        <category: 'smalltalk event'>

        ^widget treeView hasSelectedValue
    ]

    selectedValue [
        <category: 'smalltalk event'>

        ^widget treeView selection
    ]

    inspectIt: anObject [
        <category: 'smalltalk event'>

        GtkInspector openOn: anObject
    ]

    deleteVariable [
	<category: 'event'>

	| ivar |
	widget treeView hasSelectedValue ifFalse: [ ^ self ].
	ivar := self selectedValue.
	model remove: ivar.
	object class removeInstVarName: ivar.
    ]
]

