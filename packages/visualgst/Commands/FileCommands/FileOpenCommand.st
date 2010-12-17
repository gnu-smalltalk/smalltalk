Command subclass: FileOpenCommand [

    item [
	<category: 'menu item'>

	^ 'Open'
    ]

    execute [
        <category: 'command'>

        self browser open
    ]
]
