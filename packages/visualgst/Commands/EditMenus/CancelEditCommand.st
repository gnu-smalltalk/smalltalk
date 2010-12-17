Command subclass: CancelEditCommand [

    item [
	<category: 'menu item'>

	^ 'Cancel edits'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control><shift>Z'
    ]

    execute [
        <category: 'command'>

        target cancel
    ]
]
