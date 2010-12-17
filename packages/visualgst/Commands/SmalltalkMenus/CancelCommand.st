Command subclass: CancelCommand [

    item [
	<category: 'menu item'>

	^ 'Cancel'
    ]

    execute [
        <category: 'command'>

        target cancel
    ]
]

