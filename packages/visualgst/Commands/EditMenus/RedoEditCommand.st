Command subclass: RedoEditCommand [

    item [
	<category: 'menu item'>

	^ 'Redo'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>Y'
    ]

    execute [
        <category: 'command'>

        target redo
    ]
]
