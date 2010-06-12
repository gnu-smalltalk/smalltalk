Command subclass: MethodCommand [

    valid [
	<category: 'command'>

	^target hasSelectedMethod
    ]
]

