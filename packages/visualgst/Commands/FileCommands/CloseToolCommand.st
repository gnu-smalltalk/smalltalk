Command subclass: CloseToolCommand [

    item [
	<category: 'menu item'>

	^ 'Close'
    ]

    execute [
        <category: 'command'>

        self browser close
    ]
]
