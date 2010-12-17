Command subclass: CopyEditCommand [

    item [
	<category: 'menu item'>

	^ 'Copy'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>C'
    ]

    execute [
        <category: 'command'>

        target copy
    ]
]
