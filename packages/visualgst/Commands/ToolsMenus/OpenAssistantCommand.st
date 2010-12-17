Command subclass: OpenAssistantCommand [

    item [
        <category: 'menu item'>

        ^ 'Assistant'
    ]

    execute [
        <category: 'command'>

	GtkAssistant open
    ]
]

