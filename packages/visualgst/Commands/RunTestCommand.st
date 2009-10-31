Command subclass: RunTestCommand [

    execute [
	<category: 'command'>

        target classOrMetaSelected debug: target selectedMethodSymbol
    ]
]

