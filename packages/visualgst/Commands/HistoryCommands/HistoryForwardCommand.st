Command subclass: HistoryForwardCommand [

    item [
	<category: 'menu item'>

	^ 'Forward'
    ]

    accel [
        <category: 'menu item'>

        ^ '<Alt>Right'
    ]

    execute [
        <category: 'command'>

        target forward
    ]
]
