"======================================================================
|
| GtkCategorizedClassWidget class definition
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

Smalltalk.String extend [

    fullname [

	^ self
    ]
]

GtkConcreteWidget subclass: GtkCategorizedClassWidget [
    | classesTree column model namespace category |

    GtkCategorizedClassWidget >> on: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    namespace: aNamespace;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self
	    category: '';
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Modified using: #'modificationEvent:'
    ]

    category: aString [
        <category: 'accessing'>

        category := aString.
    ]

    category [
        <category: 'accessing'>

        ^ category
    ]

    namespace [
	<category: 'accessing'>
    
	^ namespace
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace.
    ]

    namespace: aNamespace category: aString [
        <category: 'accessing'>

	(aNamespace == self namespace and: [ aString = self category ]) ifTrue: [ ^ self ].
        self
            category: aString;
            namespace: aNamespace.
	model refresh.
	classesTree treeView expandAll
    ]

    appendClass: aClass to: anArray [
        <category: 'model builder'>

        (aClass environment = self namespace and: [ self category isEmpty or: [ self category = aClass category or: [ (self namespace displayString, '-', self category) = aClass category ] ] ]) 
		    ifTrue: [ anArray add: aClass ]
		    ifFalse: [ aClass subclassesDo: [ :each | self appendClass: each to: anArray ] ]
    ]

    root [
	<category: 'accessing'>

	^ Class
    ]

    selectionMode [
	<category: 'accessing'>

	^ GTK.Gtk gtkSelectionBrowse
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    buildTreeView [
	<category: 'user interface'>
   
        classesTree := GtkScrollTreeWidget createTreeWithModel: {{GtkColumnTextType title: 'Classes'}}.
        classesTree connectToWhenPopupMenu: (ClassMenus on: self).
        classesTree treeView getSelection setMode: self selectionMode.
        (model := GtkTreeModel on: classesTree treeView getModel)
					item: self root;
					childrenBlock: [ :each | | col | 
							    col := SortedCollection sortBlock: [ :a :b | a asClass name <= b asClass name ]. 
							    each subclassesDo: [ :subclasses | self appendClass: subclasses to: col ]. 
							    col ];
                                        contentsBlock: [ :each | {each asClass name asString, ' '} ].
        ^ classesTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    selectionMode: aSelectionMode [
	<category: 'user interface'>

	classesTree treeView getSelection setMode: aSelectionMode.
    ]

    selectedNamespace [
	<category: 'accessing'>

	^ namespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree treeView hasSelectedItem
    ]

    state [
        <category: 'testing'>

        self hasSelectedClass ifTrue: [ ^ ClassState with: self selectedClass ].
        namespace ifNotNil: [ ^ (NamespaceState with: namespace)
				    classCategory: self category;
				    yourself ].
        ^ BrowserState new
    ]

    selectedClass [
	<category: 'accessing'>

	self hasSelectedClass ifFalse: [ self error: 'nothing is selected' ].
	^ classesTree treeView selection asClass
    ]

    selectAClass: aClass [
	<category: 'item selection'>

	classesTree treeView select: aClass
    ]

    addToModel: aClass [

	(model includes: aClass class) ifTrue: [ ^ self ].
	(aClass superclass environment == self namespace and: [ aClass superclass category = self category or: [ self category isEmpty ] ]) 
				    ifFalse: [ model append: aClass class ] 
				    ifTrue: [ model append: aClass class parent: aClass superclass class ]
    ]

    addEvent: anEvent [
        <category: 'model event'>

        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent item category = self category or: [ self category isEmpty ]) ifFalse: [ ^ self ].
	self addToModel: anEvent item
    ]

    removeEvent: anEvent [
        <category: 'model event'>

        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent item category = self category or: [ self category isEmpty ]) ifFalse: [ ^ self ].
        model remove: anEvent item class
    ]

    modificationEvent: anEvent [
        <category: 'model event'>

        (anEvent item environment == self namespace or: [ anEvent isSuperclassModified not ]) ifFalse: [ ^ self ].
        (anEvent oldItem category = self category or: [ anEvent oldItem category isNil and: [ self category isEmpty ] ])
		    ifTrue: [ model remove: anEvent item class ifAbsent: [ nil ] ].
        (anEvent item category = self category or: [ anEvent item category isNil and: [ self category isEmpty ] ]) 
		    ifTrue: [ self addToModel: anEvent item ]
    ]

    recategorizedEvent: anEvent [
        <category: 'model event'>

        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent oldCategory = self category or: [ anEvent oldCategory isNil and: [ self category isEmpty and: [ model includes: anEvent item ] ] ]) ifTrue: [ model remove: anEvent item class ].
        (anEvent item category = self category or: [ anEvent item category isNil and: [ self category isEmpty ] ]) ifTrue: [ self addToModel: anEvent item ]
    ]
]

