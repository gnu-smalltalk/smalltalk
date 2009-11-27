UndoableCommand subclass: AddMethodCommand [

    execute [
	<category: 'command'>

        | category |
        category := target selectedCategory.
        self push: (AddMethodUndoCommand
	    add: target sourceCode
	    classified: category
	    in: target classOrMetaSelected
	    browser: target)
    ]
]

