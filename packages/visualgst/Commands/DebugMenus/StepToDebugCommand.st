DebugCommand subclass: StepToDebugCommand [

    item [
        <category: 'menu item'>

        ^ 'Step To Here'
    ]

    stockIcon [

        ^ 'Icons/go-jump.png'
    ]

    execute [
        <category: 'command'>

        target step
    ]

]

