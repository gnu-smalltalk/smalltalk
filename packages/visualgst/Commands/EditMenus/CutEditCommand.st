Command subclass: CutEditCommand [

    item [
	<category: 'menu item'>

	^ 'Cut'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>X'
    ]

    execute [
        <category: 'command'>

        target cut
    ]
]
