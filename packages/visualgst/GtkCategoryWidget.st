GtkConcreteWidget subclass: GtkCategoryWidget [
    | categoryTree column model class |

    GtkCategoryWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (VisualGST uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #category change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #category change: #Removed using: #'removeEvent:'
    ]

    classOrMeta [
	<category: 'accessing'>
    
	^ class
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	class := aClass.
	model
	    item: self buildCategory;
	    refresh
    ]

    buildCategory [
        <category: 'model builder'>

        | set |
        set := Set new.
        set add: '*'.
	self classOrMeta methodDictionary ifNil: [ ^ set ].
        self classOrMeta methodDictionary do: [ :each | set add: each methodCategory ].
        ^ set asSortedCollection
    ]

    emptyModel [
	<category: 'accessing'>

	self clear
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    buildTreeView [
        <category: 'user interface'>
    
	categoryTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Method categories'}})
			    connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
			    yourself.
	categoryTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: categoryTree getModel)
                                        contentsBlock: [ :each | {each displayString} ].
	^ GTK.GtkScrolledWindow withChild: categoryTree
    ]

    unselectAll [
	<category: 'selection'>

	categoryTree getSelection unselectAll
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Add a category'. self. #newCategory}.
            {'Rename a category'. self. #renameCategory}.
            {'Delete a category'. self. #deleteCategory}.
            {}.
            {'File out a category'. self. #fileoutCategory}}.
        menu attachToWidget: categoryTree detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	categoryTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedCategory [
	<category: 'testing'>

	^ categoryTree hasSelectedItem
    ]

    selectedCategory [
	<category: 'accessing'>

	self hasSelectedCategory ifFalse: [ self error: 'nothing is selected' ].
	^ categoryTree selection
    ]

    selectACategory: aString [
        <category: 'item selection'>

	categoryTree select: aString
    ]

    findIterInACategory: aString [
        <category: 'item selection'>

        | result |

        result := self model findIterInACategory: aString.
        categoryTree scrollToCell: (self model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        ^ result
    ]

    viewedCategoryWidget [
	<category: 'accessing'>

	^ self
    ]

    viewedCategoryModel [
	<category: 'accessing'>

	^ self model
    ]

    newCategory [
        <category: 'category events'>

        AddCategoryCommand on: self
    ]

    renameCategory [
        <category: 'category events'>

        RenameCategoryCommand on: self
    ]

    deleteCategory [
        <category: 'category events'>

        DeleteCategoryCommand on: self
    ]

    fileoutCategory [
        <category: 'category events'>

        FileoutCategoryCommand on: self classOrMeta categorized: self selectedCategory
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent itemClass == self classOrMeta) ifFalse: [ ^ self ].
        "self appendCategory: anEvent item"
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent itemClass == self classOrMeta) ifFalse: [ ^ self ].
        "self removeCategory: anEvent item"
    ]
]

