Command subclass: MethodCommand [

    valid [
	<category: 'command'>

	^target state hasSelectedMethod
    ]
]

