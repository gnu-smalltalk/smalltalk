UndoCommand subclass: RenameCategoryUndoCommand [

    | category class newCategory treeStore |

    RenameCategoryUndoCommand class >> rename: aString in: aClass as: aNewName onModel: aGtkTreeStore [
	<category: 'instance creation'>

	^ (self new)
	    rename: aString in: aClass as: aNewName onModel: aGtkTreeStore;
	    "precondition;"
	    yourself
    ]

    rename: aString in: aClass as: aNewName onModel: aGtkTreeStore [
	<category: 'initialize'>

	category := aString.
	class := aClass.
	newCategory := aNewName.
	treeStore := aGtkTreeStore
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a category'
    ]

    precondition [
        <category: 'checking'>

	newCategory = '*' ifTrue: [ ^ self preconditionFailed: 'Can''t create a * category' ].
        (treeStore hasCategory: newCategory asString) ifTrue: [ ^ self preconditionFailed: 'Category is present' ].
	^ true
    ]

    undo [
	<category: 'events'>

	class methodDictionary do: [ :each |
	    each methodCategory = newCategory
		ifTrue: [ each methodCategory: category ] ].
	treeStore
	    removeCategory: newCategory;
	    appendCategory: category
    ]

    redo [
	<category: 'events'>

	class methodDictionary do: [ :each |
            each methodCategory = category
                ifTrue: [ each methodCategory: newCategory ] ].
	treeStore
	    removeCategory: category;
	    appendCategory: newCategory
    ]
]

