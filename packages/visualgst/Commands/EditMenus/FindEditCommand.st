Command subclass: FindEditCommand [

    item [
	<category: 'menu item'>

	^ 'Find'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>F'
    ]

    execute [
        <category: 'command'>

        target find
    ]
]
