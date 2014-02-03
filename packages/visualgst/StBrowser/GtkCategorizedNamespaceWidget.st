"======================================================================
|
| GtkCategorizedNamespaceWidget class definition
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

GtkConcreteWidget subclass: GtkCategorizedNamespaceWidget [
    | namespaceTree model |

    initialize [
        <category: 'initialization'>

        self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'classRecategorizedEvent:'
    ]

    addToModel: namespace [
        <category: 'model'>

        ^ (namespace subspaces asArray sort: [ :a :b | a name <= b name ]), (namespace categories values sort: [ :a :b | a name <= b name ])
    ]

    buildTreeView [
        <category: 'user interface'>

	namespaceTree := GtkScrollTreeWidget createTreeWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Namespaces'}}.
	namespaceTree connectToWhenPopupMenu: (NamespaceMenus on: self).
	namespaceTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(model := GtkTreeModel on: namespaceTree treeView getModel)
                                        item: FakeNamespace;
                                        childrenBlock: [ :each | self addToModel: each ];
                                        contentsBlock: [ :each | {each icon. each name asString} ];
                                        connectSignal: 'row-has-child-toggled' to: self selector: #'childToggled:path:iter:';
                                        refresh.
	^ namespaceTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        namespaceTree treeView getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    selectANamespace: aNamespace [
        <category: 'item selection'>

	(self hasSelectedNamespace and: [ self selectedNamespace == aNamespace ]) ifTrue: [ ^ self ].
	(namespaceTree treeView)
			    expandAll;
			    select: aNamespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ namespaceTree treeView hasSelectedItem
    ]

    selectedNamespace [
        <category: 'accessing'>

	self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
	^ namespaceTree treeView selection namespace
    ]

    selectedCategory [
        <category: 'accessing'>

        self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
        ^ namespaceTree treeView selection category
    ]

    state [
        <category: 'events'>

        self hasSelectedNamespace ifFalse: [ ^ BrowserState new ].
        ^ (NamespaceState with: self selectedNamespace)
            classCategory: self selectedCategory;
            yourself
    ]

    childToggled: model path: path iter: iter [
	<category: 'signals'>

	namespaceTree treeView collapseRow: path.
	((model at: iter) at: 3) isNamespace ifTrue: [
	    ((model at: iter) at: 3) subspaces isEmpty ifFalse: [
		namespaceTree treeView expandRow: path openAll: false ] ]
    ]

    addEvent: anEvent [
        <category: 'model event'>

	model append: anEvent item parent: anEvent item superspace
    ]

    removeEvent: anEvent [
        <category: 'model event'>

        model remove: anEvent item
    ]

    classRecategorizedEvent: anEvent [
        <category: 'model event'>

        | namespace root toAdd |
        namespace := anEvent item environment.
	(anEvent item category isNil or: [ anEvent item category size = 0 ]) ifTrue: [ ^ self ].
        root := ClassCategory named: anEvent item category into: namespace.
	(model hasItem: root) ifTrue: [ ^ self ].
	toAdd := root.
	[ root parent isNil or: [ (model hasItem: root) ] ] whileFalse: [ 
					toAdd := root.
					root := root parent ].
	root parent ifNil: [ root := namespace ].
	model append: toAdd parent: root
    ]
]

