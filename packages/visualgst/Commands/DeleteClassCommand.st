ClassCommand subclass: DeleteClassCommand [

    execute [
	<category: 'command'>

        (DeleteClassUndoCommand delete: target state classOrMeta) push
    ]
]
