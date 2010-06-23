MethodCommand subclass: InspectMethodCommand [

    execute [
	<category: 'command'>

        GtkInspector openOn: target state method
    ]
]

