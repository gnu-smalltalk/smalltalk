"======================================================================
|
| GtkPackageBuilderWidget class definition
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

GtkConcreteWidget subclass: GtkPackageBuilderWidget [

    | classList ressourceList packName namespace provide provideList test classCategory prereq prereqList entries |

    initialize [
        <category: 'initialization'>

	entries := Dictionary new.
        self mainWidget: (GTK.GtkScrolledWindow withViewport: self buildMainWidget)
    ]

    buildMainWidget [
        <category: 'user interface'>

        ^ (GTK.GtkVBox new: false spacing: 3)
            add: self buildPackageNameEntry mainWidget;
	    add: self buildNamespaceEntry mainWidget;
            add: self buildPackageEntry mainWidget;
	    add: self buildPrereq;
	    add: self buildProvideEntry;
	    add: self buildTestsEntry mainWidget;
	    add: self buildClassCategoryEntry mainWidget;
	    add: self buildClassCategory;
	    add: self buildRessourcesEntry;
	    add: self buildButtons;
            yourself
    ]

    buildPackageNameEntry [
        <category: 'user interface'>

        | completion model |
        completion := GTK.GtkEntryCompletion new.
        completion 
            setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
            setTextColumn: 0.
	Smalltalk.PackageLoader root do: [ :each | model appendItem: {each name} ].
	^ packName := (GtkEntryWidget labeled: 'Package name :')
						completion: completion;
                                                yourself
    ]

    buildNamespaceCompletion: model [

	self buildNamespaceCompletion: Smalltalk on: model
    ]

    buildNamespaceCompletion: aNamespace on: model [

	model appendItem: {aNamespace name asString}.
	aNamespace subspaces do: [ :each |
	    self buildNamespaceCompletion: each on: model ]
    ]

    buildNamespaceEntry [
        <category: 'user interface'>

	| completion model |
	completion := GTK.GtkEntryCompletion new.
	completion 
	    setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
	    setTextColumn: 0.
	self buildNamespaceCompletion: model.
	^ namespace := (GtkEntryWidget labeled: 'Namespace :')
						completion: completion;
						yourself
    ]

    buildPackageEntry [
        <category: 'user interface'>

        | completion model |
        completion := GTK.GtkEntryCompletion new.
        completion
            setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
            setTextColumn: 0.
	Smalltalk.PackageLoader root do: [ :each | model appendItem: {each name} ].
        ^ prereq := (GtkEntryWidget labeled: 'Package :')
                                                completion: completion;
                                                yourself
    ]

    buildPrereqEntry [
        <category: 'user interface'>

	prereqList := GtkSimpleListWidget named: 'Packages prerequired :'.
	^ prereqList mainWidget
    ]

    buildPrereq [

        | hbox vbox add remove |
        hbox := GTK.GtkHBox new: false spacing: 0.

        hbox packStart: self buildPrereqEntry expand: true fill: true padding: 3.
        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
            setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #addPrereq.

        vbox := GTK.GtkVBox new: false spacing: 0.
        vbox packStart: add expand: false fill: true padding: 3.

        remove := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
        remove
            setTooltipText: 'Remove the selected file from the list'.
        vbox packStart: remove expand: false fill: true padding: 3.
        hbox packStart: vbox expand: false fill: true padding: 3.
        ^ hbox
    ]

    buildProvideEntry [
        <category: 'user interface'>

	provideList := GtkSimpleListWidget named: 'Provides :'.
	^ provideList mainWidget
    ]

    buildTestsEntry [
        <category: 'user interface'>

	^ test := GtkEntryWidget labeled: 'Tests :'
    ]

    buildClassCategoryCompletion: model [

	| set |
	set := Set new.
	Class allSubclassesDo: [ :each |
	    (set includes: each category)
		ifFalse: [
		    set add: each category.
		    model appendItem: {each category} ] ]
    ]

    buildClassCategoryEntry [
        <category: 'user interface'>

        | completion model |
        completion := GTK.GtkEntryCompletion new.
        completion
            setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
            setTextColumn: 0.
        self buildClassCategoryCompletion: model.
        ^ packName := (GtkEntryWidget labeled: 'Class category :')
                                                completion: completion;
                                                yourself
    ]

    buildClassCategory [

	| hbox vbox add remove |
	hbox := GTK.GtkHBox new: false spacing: 0.
	
	hbox packStart: self buildFilesEntry expand: true fill: true padding: 3.
        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
	    setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #addCategory.

	vbox := GTK.GtkVBox new: false spacing: 0.
        vbox packStart: add expand: false fill: true padding: 3.

        remove := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
	remove 
	    setTooltipText: 'Remove the selected file from the list'.
        vbox packStart: remove expand: false fill: true padding: 3.
        hbox packStart: vbox expand: false fill: true padding: 3.
	^ hbox
    ]

    buildFilesEntry [
        <category: 'user interface'>

        classList := GtkSimpleListWidget named: 'Class category :'.
        ^ classList mainWidget
    ]

    buildRessourcesEntry [
        <category: 'user interface'>

        ressourceList := GtkSimpleListWidget named: 'Ressources :'.
        ^ ressourceList mainWidget
    ]

    buildButtons [
        <category: 'user interface'>

        | hbox add cancel |
        hbox := GTK.GtkHBox new: false spacing: 0.

        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
            setTooltipText: 'Save the package';
            connectSignal: 'clicked' to: self selector: #buildPackage.

        hbox packStart: add expand: false fill: true padding: 3.

        cancel := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
        cancel
            setTooltipText: 'Cancel'.
        hbox packStart: cancel expand: false fill: true padding: 3.
        ^ hbox
    ]

    addPrereq [

	prereqList getModel appendItem: {prereq text}
    ]

    addCategory [
    ]

    buildPackage [
    ]
]

