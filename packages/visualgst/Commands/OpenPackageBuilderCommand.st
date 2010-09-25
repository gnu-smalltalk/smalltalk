Command subclass: OpenPackageBuilderCommand [

    execute [
        <category: 'command'>

        ^ GtkLauncher uniqueInstance showHidePackageBuilder
    ]
]
