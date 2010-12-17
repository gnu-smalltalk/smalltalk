MethodCommand subclass: DeleteMethodCommand [

    item [

	^ 'Delete a method'
    ]

    execute [
	<category: 'command'>

        (DeleteMethodUndoCommand delete: target state selector in: target state classOrMeta) push
    ]
]

