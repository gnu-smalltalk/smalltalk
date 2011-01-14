Command subclass: DoItCommand [

    item [
	<category: 'menu item'>

	^ 'Do It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>D'
    ]

    stockIcon [

	^ 'gtk-execute'
    ]

    execute [
        <category: 'command'>

        target doIt: target targetObject
    ]
]

