Command subclass: InspectorDiveCommand [

    item [

	^ 'Dive'
    ]

    valid [
	<category: 'command'>

        ^ target canDive
    ]

    execute [
	<category: 'command'>

        ^ target dive
    ]
]

