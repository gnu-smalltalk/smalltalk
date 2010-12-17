Command subclass: FileSaveCommand [

    item [
	<category: 'menu item'>

	^ 'Save'
    ]

    execute [
        <category: 'command'>

        self browser open
    ]
]
