BrowserState subclass: ClassState [

    namespace [
	<category: 'accessing'>

	^ state environment
    ]

    classOrMeta [
	<category: 'accessing'>

	^ state
    ]

    saveSource [
	<category: 'events'>

	browser acceptClassDefinitionForState: self
    ]
]

