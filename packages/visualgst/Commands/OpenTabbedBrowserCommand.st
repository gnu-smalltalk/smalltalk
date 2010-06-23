OpenBrowserCommand subclass: OpenTabbedBrowserCommand [

    buildBrowserAndSelect: anAssociation [
	<category: 'user interface'>

	| browser |
        browser := target classBrowser.
        browser selectANamespace: anAssociation key.
        anAssociation value ifNotNil: [ browser selectAClass: anAssociation value ].
    ]

    execute [
        <category: 'command'>

	self buildBrowserAndSelect: self selection
    ]
]

