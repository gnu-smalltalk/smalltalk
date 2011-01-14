DebugCommand subclass: StepIntoDebugCommand [

    item [
        <category: 'menu item'>

        ^ 'Step Into'
    ]

    stockIcon [

        ^ 'Icons/go-next.png'
    ]

    execute [
        <category: 'command'>

        target stepInto
    ]

]

