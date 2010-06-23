ClassCommand subclass: InspectClassCommand [

    execute [
	<category: 'command'>

        GtkInspector openOn: target state classOrMeta
    ]
]
