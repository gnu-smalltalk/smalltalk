ClassCommand subclass: AddMethodCommand [

    execute [
	<category: 'command'>

        (AddMethodUndoCommand
	    add: target sourceCode
	    classified: target selectedCategory 
	    in: target classOrMetaSelected
	    browser: target) push
    ]
]

