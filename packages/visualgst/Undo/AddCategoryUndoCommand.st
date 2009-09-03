UndoCommand subclass: AddCategoryUndoCommand [

    | category treeStore |

    AddCategoryUndoCommand class >> add: aSymbol onModel: aGtkCategoryModel [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol onModel: aGtkCategoryModel;
	    precondition;
	    yourself
    ]

    add: aSymbol onModel: aGtkCategoryModel [
	<category: 'initialize'>

	category := aSymbol.
	treeStore := aGtkCategoryModel
    ]

    description [
	<category: 'accessing'>

	^ 'Add a category'
    ]

    precondition [
        <category: 'checking'>

	category = '*' ifTrue: [ self error: 'Can''t create a * category' ].
	(treeStore hasCategory: category asString) ifTrue: [ self error: 'Category is present' ]
    ]

    undo [
	<category: 'events'>

	treeStore removeCategory: category asString	
    ]

    redo [
	<category: 'events'>

	treeStore appendCategory: category asString
    ]
]

