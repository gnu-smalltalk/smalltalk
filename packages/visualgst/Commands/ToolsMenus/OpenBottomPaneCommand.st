Command subclass: OpenBottomPaneCommand [

    item [
        <category: 'menu item'>

        ^ 'Bottom Pane'
    ]

    accel [
        <category: 'accel'>

        ^ ''
    ]

    execute [
        <category: 'command'>

        ^ GtkLauncher uniqueInstance showHideBottomPane
    ]
]
