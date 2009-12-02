BrowserState subclass: NamespaceState [

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self namespace
    ]

    namespace [
	<category: 'accessing'>

	^ state
    ]

    saveSource [
	<category: 'events'>

	browser acceptClassDefinitionForState: self
    ]
]

