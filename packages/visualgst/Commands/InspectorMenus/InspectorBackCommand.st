Command subclass: InspectorBackCommand [

    item [

	^ 'Back'
    ]

    valid [
	<category: 'command'>

        ^ target isStackEmpty not
    ]

    execute [
	<category: 'command'>

        ^ target back
    ]
]

