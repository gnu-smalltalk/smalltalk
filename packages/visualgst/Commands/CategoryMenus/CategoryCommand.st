Command subclass: CategoryCommand [

    valid [
	<category: 'command'>

	^target state hasSelectedCategory
    ]
]

