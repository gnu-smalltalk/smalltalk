ClassCommand subclass: DeleteClassCommand [

    execute [
	<category: 'command'>

        (DeleteClassUndoCommand delete: target selectedClass) push
    ]
]
