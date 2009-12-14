UndoCommand subclass: AddCategoryUndoCommand [
    | categoryWidget category selectedCategory |

    AddCategoryUndoCommand class >> add: aSymbol onWidget: aGtkCategoryWidget [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol onWidget: aGtkCategoryWidget;
	    "precondition;"
	    yourself
    ]

    add: aSymbol onWidget: aGtkCategoryWidget [
	<category: 'initialize'>

	category := aSymbol.
	categoryWidget := aGtkCategoryWidget
    ]

    description [
	<category: 'accessing'>

	^ 'Add a category'
    ]

    precondition [
        <category: 'checking'>

	category = '*' ifTrue: [ ^ self preconditionFailed: 'Can''t create a * category' ].
	(categoryWidget hasCategory: category asString) ifTrue: [ ^ self preconditionFailed: 'Category is present' ].
	categoryWidget hasSelectedCategory ifTrue: [ selectedCategory := categoryWidget selectedCategory ].
	^ true
    ]

    undo [
	<category: 'events'>

	SystemChangeNotifier root categoryRemoved: category asString inClass: categoryWidget classOrMeta.
	categoryWidget selectACategory: selectedCategory
    ]

    redo [
	<category: 'events'>

	SystemChangeNotifier root categoryAdded: category asString inClass: categoryWidget classOrMeta.
	categoryWidget selectACategory: category asString
    ]
]

