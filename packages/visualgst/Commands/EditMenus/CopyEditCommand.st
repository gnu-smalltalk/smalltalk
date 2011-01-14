Command subclass: CopyEditCommand [

    item [
	<category: 'menu item'>

	^ 'Copy'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>C'
    ]

    stockIcon [

	^ 'gtk-copy'
    ]

    execute [
        <category: 'command'>

        target copy
    ]
]
