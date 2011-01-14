DoItCommand subclass: InspectItCommand [

    item [
        <category: 'menu item'>

        ^ 'Inspect It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>I'
    ]

    stockIcon [

        ^ 'gtk-convert'
    ]

    execute [
        <category: 'command'>

        target inspectIt: target targetObject
    ]
]

