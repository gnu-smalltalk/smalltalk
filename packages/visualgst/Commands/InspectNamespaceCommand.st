NamespaceCommand subclass: InspectNamespaceCommand [

    execute [
	<category: 'command'>

        GtkInspector openOn: target state namespace
    ]
]

