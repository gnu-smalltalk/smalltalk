UndoableCommand subclass: DeleteClassCommand [

    execute [
	<category: 'command'>

	target hasSelectedClass ifFalse: [ ^ self ].
        self push: (DeleteClassUndoCommand delete: target selectedClass)
    ]
]
