GtkConcreteWidget subclass: GtkPackageBuilderWidget [

    | packName namespace provide test classCategory prereq entries |

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
	    add: self buildProvideEntry mainWidget;
	    add: self buildTestsEntry mainWidget;
	    add: self buildClassCategoryEntry mainWidget;
	    add: self buildClassCategory;
	    add: self buildRessourcesEntry;
	    add: self buildButtons;
            yourself
    ]

    buildList: aSymbol labeled: aString [

	| widget |
	entries
            at: aSymbol
	    put: (widget := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: aString}})
				    connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
				    yourself).
        widget getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (GtkListModel on: widget getModel)
                                        contentsBlock: [ :each | {each displayString} ].
        ^ GTK.GtkScrolledWindow withChild: widget
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

	^ self buildList: #prereq labeled: 'Packages prerequired :'
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

	^ provide := GtkEntryWidget labeled: 'Provides :'
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

	^ self buildList: #classes labeled: 'Classes category :'
    ]

    buildRessourcesEntry [
        <category: 'user interface'>

	^ self buildList: #ressources labeled: 'Ressources :'
    ]

    buildButtons [
        <category: 'user interface'>

        | hbox add remove |
        hbox := GTK.GtkHBox new: false spacing: 0.

        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
            setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #buildPackage.

        hbox packStart: add expand: false fill: true padding: 3.

        remove := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
        remove
            setTooltipText: 'Remove the selected file from the list'.
        hbox packStart: remove expand: false fill: true padding: 3.
        ^ hbox
    ]

    addPrereq [

	(entries at: #prereq) getModel appendItem: {prereq text}
    ]

    addCategory [

	(entries at: #classes) getModel appendItem: {packName text}
    ]

    buildPackage [
    ]
]

