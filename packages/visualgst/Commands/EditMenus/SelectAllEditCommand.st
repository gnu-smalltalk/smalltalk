Command subclass: SelectAllEditCommand [

    item [
	<category: 'menu item'>

	^ 'Select all'
    ]

    execute [
        <category: 'command'>

        target selectAll
    ]
]
