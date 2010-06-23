Command subclass: ClassCommand [

    valid [
	<category: 'command'>

	^ target state hasSelectedClass
    ]
]

