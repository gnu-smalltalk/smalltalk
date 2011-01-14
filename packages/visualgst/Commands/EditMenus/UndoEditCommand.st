Command subclass: UndoEditCommand [

    item [
	<category: 'menu item'>

	^ 'Undo'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>Z'
    ]

    stockIcon [

	^ 'gtk-undo'
    ]

    execute [
        <category: 'command'>

        target undo
    ]
]
