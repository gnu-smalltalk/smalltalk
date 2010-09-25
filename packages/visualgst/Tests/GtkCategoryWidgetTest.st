TestCase subclass: GtkCategoryWidgetTest [

    | changed |

    categoryChanged [

	changed := true
    ]

    testModelBuilding [
	<category: 'testing'>

	| category |
	category := GtkCategoryWidget new.
	category
	    mainWidget: category buildTreeView;
	    initializeCategories;
	    classOrMeta: Object
    ]

    testState [
        <category: 'testing'>

	| category |
	category := GtkCategoryWidget new.
	category
	    mainWidget: category buildTreeView;
	    initializeCategories;
	    classOrMeta: Object.
        self assert: category state namespace == Smalltalk.
        self assert: category state classOrMeta == Object.
	category selectACategory: 'built ins'.
        self assert: category state namespace == Smalltalk.
        self assert: category state classOrMeta == Object
    ]

    testSelectionEvents [

        | category |
        category := GtkCategoryWidget new.
        category
            mainWidget: category buildTreeView;
            initializeCategories;
            classOrMeta: Object.
        self assert: category hasSelectedCategory not.
        self should: [ category selectedCategory ] raise: Error.
	category selectACategory: 'built ins'.
        self assert: category hasSelectedCategory.
        self assert: category selectedCategory = 'built ins'
    ]

    testConnectionEvents [

        | category |
        category := GtkCategoryWidget new.
        category
            mainWidget: category buildTreeView;
            initializeCategories;
	    whenSelectionChangedSend: #categoryChanged to: self;
            classOrMeta: Object;
	    selectACategory: 'built ins'.
        self assert: changed
    ]
]

