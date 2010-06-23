MethodCommand subclass: DeleteMethodCommand [

    execute [
	<category: 'command'>

        (DeleteMethodUndoCommand delete: target state selector in: target state classOrMeta) push
    ]
]

