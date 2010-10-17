GtkConcreteWidget subclass: GtkCategoryWidget [
    | categoryTree categories model class |

    GtkCategoryWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self initializeCategories.
	self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    initializeCategories [

	categories := Set new.
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #method change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeEvent:'
    ]

    classOrMeta [
	<category: 'accessing'>
    
	^ class
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	class := aClass.
	categories empty.
	model
	    item: (self buildCategory: categories);
	    refresh
    ]

    buildCategory: aSet [
        <category: 'model builder'>

        aSet add: '*'.
	self classOrMeta methodDictionary ifNil: [ ^ aSet ].
        self classOrMeta methodDictionary do: [ :each | aSet add: each methodCategory ].
        ^ aSet asSortedCollection
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
			    connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
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
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    state [
        <category: 'testing'>

        self hasSelectedCategory ifFalse: [ ^ ClassState with: self classOrMeta ].
        ^ CategoryState with: self classOrMeta->self selectedCategory
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
        result := model findIterInACategory: aString.
        categoryTree scrollToCell: (model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        ^ result
    ]

    viewedCategoryWidget [
	<category: 'accessing'>

	^ self
    ]

    viewedCategoryModel [
	<category: 'accessing'>

	^ model
    ]

    newCategory [
        <category: 'category events'>

        AddCategoryCommand on: self
    ]

    renameCategory [
        <category: 'category events'>

        RenameCategoryCommand on: self
    ]

    fileoutCategory [
        <category: 'category events'>

        FileoutCategoryCommand on: self
    ]

    removeEmptyCategory [
	<category: 'update'>

	| set |
	set := Set new.
	self buildCategory: set.
	(categories - set) do: [ :each | 
			model remove: each.
			categories remove: each ]
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ (model hasItem: anEvent item methodCategory) not ]) ifFalse: [ ^ self ].
        categories add: anEvent item methodCategory.
	model append: anEvent item methodCategory.
	self removeEmptyCategory
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ (model hasItem: anEvent item methodCategory) not ]) ifFalse: [ ^ self ].
	self removeEmptyCategory
    ]

]

