Command subclass: DoItCommand [

    item [
	<category: 'menu item'>

	^ 'Do It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>D'
    ]

    execute [
        <category: 'command'>

        target doIt: target targetObject
    ]
]

