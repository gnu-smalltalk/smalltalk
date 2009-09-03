UndoableCommand subclass: DeleteMethodCommand [

    execute [
	<category: 'command'>

        target hasSelectedMethod ifFalse: [ ^ self ].
        self push: (DeleteMethodUndoCommand delete: target selectedMethodSymbol in: target classOrMetaSelected)
    ]
]

