ClassCommand subclass: AddMethodCommand [

    execute [
	<category: 'command'>

        | category |
        category := target selectedCategory.
        (AddMethodUndoCommand
	    add: target sourceCode
	    classified: category
	    in: target classOrMetaSelected
	    browser: target) push
    ]
]

