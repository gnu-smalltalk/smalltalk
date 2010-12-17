ClassCommand subclass: InspectClassCommand [

    item [

	^ 'Inspect a class'
    ]

    execute [
	<category: 'command'>

        GtkInspector openOn: target state classOrMeta
    ]
]
