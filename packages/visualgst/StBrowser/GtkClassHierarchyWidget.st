"======================================================================
|
| GtkClassHierarchyWidget class definition
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

GtkConcreteWidget subclass: GtkClassHierarchyWidget [
    | root dic classesTree model classOrMeta |

    GtkClassHierarchyWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	dic := Dictionary new.
	self 
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

       " (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:'
   " ]

    classOrMeta [
	<category: 'accessing'>
    
	^ classOrMeta
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	classOrMeta := aClass asClass.
	dic := Dictionary new.
	self buildSuperclasses.
	model 
	    item: #root;
	    refresh.
	
	classesTree 
		expandAll;
		select: aClass
    ]

    emptyModel [
        classesTree getSelection unselectAll
    ]

    buildSuperclasses [
	| parent |

	parent := self classOrMeta.
	[ parent isNil ] whileFalse: [
	    dic at: (parent superclass ifNil: [ #root ]) put: {parent}.
	    root := parent.
	    parent := parent superclass ].
    ]

    buildTreeView [
	<category: 'user interface'>
   
        classesTree := GTK.GtkTreeView createTreeWithModel: {{GtkColumnTextType title: 'Classes'}}.
        classesTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkTreeModel on: classesTree getModel)
                                        item: #root;
                                        childrenBlock: [ :each |
					    dic at: each ifAbsent: [ | col |
                                                        col := SortedCollection sortBlock: [ :a :b | a asClass name <= b asClass name ].
							col addAll: (each subclasses select: [ :behavior | behavior isClass ]).
                                            col ] ];
                                        contentsBlock: [ :each | {each asClass name asString, ' '} ].
        ^ GTK.GtkScrolledWindow withChild: classesTree 
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree hasSelectedItem
    ]

    selectedClass [
	<category: 'accessing'>

	self hasSelectedClass ifFalse: [ ^ self classOrMeta " self error: 'Nothing is selected' " ].
	^ classesTree selection asClass
    ]

    state [
        <category: 'testing'>

        self hasSelectedClass ifTrue: [ ^ ClassState with: self selectedClass ].
        ^ BrowserState new
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

	self hasSelectedClass ifFalse: [ ^ self ].
	aGtkClassBrowserWidget updateClassHierarchyWidget
    ]
]

