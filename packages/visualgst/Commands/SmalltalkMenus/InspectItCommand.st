DoItCommand subclass: InspectItCommand [

    item [
        <category: 'menu item'>

        ^ 'Inspect It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>I'
    ]

    execute [
        <category: 'command'>

        target inspectIt: target targetObject
    ]
]

