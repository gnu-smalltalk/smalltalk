NamespaceCommand subclass: InspectNamespaceCommand [

    item [

	^ 'Inspect a namespace'
    ]

    execute [
	<category: 'command'>

        GtkInspector openOn: target state namespace
    ]
]

