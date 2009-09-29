Command subclass: InspectClassCommand [

    execute [
	<category: 'command'>

	target hasSelectedClass ifFalse: [ ^ self ].
        GtkInspector openOn: target selectedClass
    ]
]
