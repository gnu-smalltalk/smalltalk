GtkConcreteWidget subclass: GtkCategoryWidget [
    | categoryTree column model class |

    GtkCategoryWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    class: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    class [
	<category: 'accessing'>
    
	^ class
    ]

    class: aClass [
	<category: 'accessing'>

	class := aClass.
	self refreshModel
    ]

    model [
	<category: 'accessing'>

	^ (GtkCategoryModel currentOn: self class)
	    model
    ]

    emptyModel [
	<category: 'accessing'>

	categoryTree setModel: (GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString})
    ]

    refreshModel [
	<category: 'events'>
   
	categoryTree setModel: self model.
	(GtkCategoryModel currentOn: self class) isSorted
            ifFalse: [
                column signalEmitByName: 'clicked' args: {}.
                (GtkCategoryModel currentOn: self class) sorted: true ]
    ]

    buildTreeView [
        <category: 'user interface'>
    
	categoryTree := (GTK.GtkTreeView newWithSortedTextColumn: self model title: 'Method categories')
			    connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
			    yourself.
	column := categoryTree getColumn: 0.
	categoryTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(GtkCategoryModel currentOn: self class) isSorted
	    ifFalse: [
		column signalEmitByName: 'clicked' args: {}.
		(GtkCategoryModel currentOn: self class) sorted: true ].
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
            {'File out a class'. self. #fileoutCategory}}.
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

	| iter string |
	(iter := categoryTree selectedIter) ifNil: [self error: 'Nothing is selected'].
	^ self model getOop: iter column: 0.
    ]

    viewedCategoryModel [
	<category: 'accessing'>

	^ GtkCategoryModel currentOn: self class
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

]

