"======================================================================
|
| GtkInspectorWidget class definition
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

GtkConcreteWidget subclass: GtkInspectorWidget [
    | inspector model object inspectorTree workspaceWidget objectView stack |

    GtkInspectorWidget >> openOn: anObject [
	<category: 'instance creation'>

	^ (super new)
	    initialize;
	    object: anObject;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	stack := OrderedCollection new.
	self mainWidget: self buildView.
	self whenSelectionChangedSend: #onVariableChanged to: self.
    ]

    postInitialize [
	<category: 'initialization'>

	workspaceWidget postInitialize
    ]

    inspector: aGtkInspector [
	<category: 'accessing'>

	inspector := aGtkInspector	
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	objectView := object inspectorView openOn: anObject.
	workspaceWidget object: anObject.
	inspector isNil ifFalse: [ inspector object: anObject ].
	model 
	    item: objectView;
	    refresh
    ]

    buildTreeWidget [
	<category: 'user interface'>

        inspectorTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Variables'}}.
        inspectorTree connectToWhenPopupMenu: (InspectorMenus on: self).
        (model := GtkListModel on: inspectorTree treeView getModel)
                                        contentsBlock: [ :each | {each displayString} ].
        ^ inspectorTree mainWidget
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkWorkspaceWidget new)
			    initialize;
			    showAll;
			    yourself
    ]

    buildView [
        <category: 'user interface'>
   
	^ GTK.GtkHPaned new
	    pack1: self buildTreeWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: true shrink: false;
            yourself
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        inspectorTree treeView getSelection
            connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedValue [
        <category: 'testing'>

        ^ inspectorTree treeView hasSelectedItem 
    ]

    onVariableChanged [
	<category: 'events'>

	self hasSelectedValue ifFalse: [ workspaceWidget text: ''. ^ self ].
	workspaceWidget text: self selectedValue displayString
    ]

    selectedItem [
	<category: 'item selection'>

        self hasSelectedValue ifFalse: [ self error: 'Nothing is selected' ].
        ^ inspectorTree treeView selection
    ]

    targetObject [

	^ self selectedValue
    ]

    selectedValue [
	<category: 'item selection'>

	^ objectView selectedValue: self selectedItem
    ]

    canDive [
	<category: 'events'>

	^ self hasSelectedValue and: [ self selectedItem ~= 'self' and: [ objectView canDive ] ]
    ]

    isStackEmpty [
	<category: 'events'>

        ^ stack isEmpty
    ]

    dive [
	<category: 'events'>

	stack addFirst: self object.
        self object: self selectedValue
    ]

    back [
	<category: 'events'>

	self object: stack removeFirst
    ]

    doIt: object [
        <category: 'smalltalk event'>

        workspaceWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        workspaceWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        GtkInspector openOn: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        workspaceWidget printIt: object
    ]

    copy [
        <category: 'text editing'>

	workspaceWidget copy
    ]

    cut [
        <category: 'text editing'>

	workspaceWidget cut
    ]

    paste [
        <category: 'text editing'>

	workspaceWidget paste
    ]

    selectAll [
        <category: 'text editing'>

	workspaceWidget selectAll
    ]
 
    hasSelection [
	<category:'text testing'>

	^ workspaceWidget hasSelection
    ]
 
    selectedText [
	<category: 'text editing'>

	^ workspaceWidget selectedText
    ]

]

