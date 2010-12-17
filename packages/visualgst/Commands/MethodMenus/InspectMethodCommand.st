MethodCommand subclass: InspectMethodCommand [

    item [

	^ 'Inspect a method'
    ]

    execute [
	<category: 'command'>

        GtkInspector openOn: target state method
    ]
]

