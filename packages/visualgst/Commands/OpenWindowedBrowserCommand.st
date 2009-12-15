OpenBrowserCommand subclass: OpenWindowedBrowserCommand [

    execute [
        <category: 'command'>

	| browser selection |
	browser := GtkClassBrowser open.
	selection := self selection.
	browser selectANamespace: selection key.
	selection value ifNotNil: [ browser selectAClass: selection value ]
    ]
]

