Command subclass: WorkspaceVariableCommand [

    item [
        <category: 'menu item'>

        ^ 'Show/Hide workspace variable(s)'
    ]

    execute [
        <category: 'command'>

	target showIVar
    ]
]

