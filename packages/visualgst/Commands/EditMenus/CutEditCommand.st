Command subclass: CutEditCommand [

    item [
	<category: 'menu item'>

	^ 'Cut'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>X'
    ]

    stockIcon [

	^ 'gtk-cut'
    ]

    execute [
        <category: 'command'>

        target cut
    ]
]
