MethodCommand subclass: DeleteMethodCommand [

    execute [
	<category: 'command'>

        (DeleteMethodUndoCommand delete: target selectedMethodSymbol in: target classOrMetaSelected) push
    ]
]

