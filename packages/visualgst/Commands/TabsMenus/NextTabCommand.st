Command subclass: NextTabCommand [

    item [
	<category: 'menu item'>

	^ 'Next Tab'
    ]

    execute [
        <category: 'command'>

        target shell nextTab
    ]
]
