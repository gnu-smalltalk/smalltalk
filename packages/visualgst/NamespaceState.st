BrowserState subclass: NamespaceState [

    namespace [
	<category: 'accessing'>

	^ state
    ]

    saveSource [
	<category: 'events'>

	browser acceptClassDefinitionForState: self
    ]
]

