Command subclass: HistoryBackCommand [

    item [
	<category: 'menu item'>

	^ 'Back'
    ]

    accel [
	<category: 'menu item'>

	^ '<Alt>Left'
    ]

    execute [
        <category: 'command'>

        target back
    ]
]
