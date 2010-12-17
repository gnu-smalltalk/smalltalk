Command subclass: FileSaveAsCommand [

    item [
	<category: 'menu item'>

	^ 'Save as...'
    ]

    execute [
        <category: 'command'>

        self browser open
    ]
]
