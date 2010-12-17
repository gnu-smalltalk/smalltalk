DoItCommand subclass: DebugItCommand [

    item [
        <category: 'menu item'>

        ^ 'Debug It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Alt>D'
    ]

    execute [
        <category: 'command'>

        target debugIt: target targetObject
    ]
]

