Command subclass: RedoEditCommand [

    item [
	<category: 'menu item'>

	^ 'Redo'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>Y'
    ]

    stockIcon [

	^ 'gtk-redo'
    ]

    execute [
        <category: 'command'>

        target redo
    ]
]
