Command subclass: PasteEditCommand [

    item [
	<category: 'menu item'>

	^ 'Paste'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>V'
    ]

    stockIcon [

	^ 'gtk-paste'
    ]

    execute [
        <category: 'command'>

        target paste
    ]
]
