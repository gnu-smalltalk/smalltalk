DoItCommand subclass: DebugItCommand [

    item [
        <category: 'menu item'>

        ^ 'Debug It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Alt>D'
    ]

    stockIcon [

        ^ 'gtk-sort-descending'
    ]

    execute [
        <category: 'command'>

        target debugIt: target targetObject
    ]
]

