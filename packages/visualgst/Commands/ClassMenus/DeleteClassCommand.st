ClassCommand subclass: DeleteClassCommand [

    item [

	^ 'Delete a class'
    ]

    execute [
	<category: 'command'>

        (DeleteClassUndoCommand delete: target state classOrMeta) push
    ]
]
