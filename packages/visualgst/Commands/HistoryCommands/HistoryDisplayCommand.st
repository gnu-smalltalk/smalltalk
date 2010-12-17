Command subclass: HistoryDisplayCommand [

    item [
	<category: 'menu item'>

	^ 'Show/Hide history pane'
    ]

    accel [
        <category: 'menu item'>

        ^ '<Control>H'
    ]

    execute [
        <category: 'command'>

        target showHideHistory
    ]
]
