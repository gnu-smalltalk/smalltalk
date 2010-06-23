MethodCommand subclass: RunTestCommand [

    execute [
	<category: 'command'>

        target state classOrMeta debug: target state selector
    ]
]

