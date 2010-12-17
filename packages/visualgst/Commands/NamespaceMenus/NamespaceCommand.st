Command subclass: NamespaceCommand [

    valid [
	<category: 'command'>

	^target state hasSelectedNamespace
    ]
]

