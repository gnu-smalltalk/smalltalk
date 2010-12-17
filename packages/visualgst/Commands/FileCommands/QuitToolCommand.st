Command subclass: QuitToolCommand [

    item [
	<category: 'menu item'>

	^ 'Quit'
    ]

    execute [
        <category: 'command'>

        self browser quit
    ]
]
